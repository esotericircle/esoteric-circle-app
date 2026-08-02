import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'ai/firebase_maestro_ai_provider.dart';
import 'ai/maestro_ai_provider.dart';
import 'ai/registro_dei_guasti.dart';
import 'ai/voce_sorvegliata.dart';
import 'firebase/app_check_debug.dart';
import 'memory/firestore_maestro_memory_repository.dart';
import 'memory/in_memory_maestro_memory_repository.dart';
import 'memory/maestro_memory_repository.dart';

/// Contenitore dei servizi a runtime, costruito una volta all'avvio.
///
/// Tiene insieme il provider AI e il repository di memoria, gia' scelti fra
/// implementazione reale (Firebase, Gemini su Vertex, Firestore) e ripiego
/// inerte. La UI riceve questo oggetto e non sa nulla di come e' stato montato.
class AppServices {
  AppServices._({
    required this.ai,
    required this.guasti,
    required this.memory,
    required this.memoryPersistent,
    this.appCheckDebugToken,
    this.showAppCheckDebugToken = false,
    this.diagnostics,
  });

  /// Monta i servizi avvolgendo la voce nella sorveglianza, sempre.
  ///
  /// E' una fabbrica e non un costruttore diretto proprio per questo: il
  /// campo [ai] non si puo' impostare dal di fuori senza passare di qui, quindi
  /// non esiste un modo di costruire i servizi con una voce non sorvegliata.
  /// Se la voce e' gia' sorvegliata si tiene il SUO registro, altrimenti due
  /// registri diversi si dividerebbero i guasti e il pannello ne mostrerebbe
  /// meta'.
  factory AppServices({
    required MaestroAiProvider ai,
    required MaestroMemoryRepository memory,
    required bool memoryPersistent,
    RegistroDeiGuasti? guasti,
    String? appCheckDebugToken,
    bool showAppCheckDebugToken = false,
    String? diagnostics,
  }) {
    final VoceSorvegliata sorvegliata;
    if (ai is VoceSorvegliata) {
      sorvegliata = ai;
    } else {
      sorvegliata =
          VoceSorvegliata(voce: ai, registro: guasti ?? RegistroDeiGuasti());
    }
    return AppServices._(
      ai: sorvegliata,
      guasti: sorvegliata.registro,
      memory: memory,
      memoryPersistent: memoryPersistent,
      appCheckDebugToken: appCheckDebugToken,
      showAppCheckDebugToken: showAppCheckDebugToken,
      diagnostics: diagnostics,
    );
  }

  /// La voce dei Maestri, SEMPRE sorvegliata. Il costruttore avvolge da se'
  /// qualunque provider gli arrivi: cosi' non esiste un modo di montare i
  /// servizi con una voce che perde gli errori per strada, nemmeno nelle prove
  /// e nemmeno in un ramo di ripiego scritto di fretta.
  final MaestroAiProvider ai;
  final MaestroMemoryRepository memory;

  /// Dove finiscono i guasti della voce. Lo legge il pannello di messa a punto
  /// della chat, ed e' l'unico posto in cui l'errore vero sopravvive.
  final RegistroDeiGuasti guasti;

  /// Vero se la memoria e' davvero persistente (Firestore), falso se solo in
  /// RAM per la sessione.
  final bool memoryPersistent;

  /// Token di debug di App Check da mostrare a schermo, quando in debug. Null in
  /// release o quando non pertinente. Serve solo per l'enforcement.
  final String? appCheckDebugToken;

  /// Vero se il token di debug va mostrato a video, nella striscia in alto e
  /// nella riga in fondo alle Impostazioni. Acceso solo fuori dalla release e
  /// solo dai servizi reali: i servizi offline dei test e delle anteprime lo
  /// lasciano spento, cosi' le catture restano quelle che l'utente vedra'.
  final bool showAppCheckDebugToken;

  /// Nota diagnostica per i log, mai mostrata cruda all'utente.
  final String? diagnostics;

  bool get aiReady => ai.isReady;

  /// Servizi inerti, senza rete: usati nei test e come ripiego assoluto.
  factory AppServices.offline([String? reason]) {
    return AppServices(
      ai: const UnavailableMaestroAiProvider(),
      memory: InMemoryMaestroMemoryRepository(),
      memoryPersistent: false,
      diagnostics: reason ?? 'Servizi offline.',
    );
  }

  /// Monta i servizi reali, con la massima tolleranza ai guasti: qualunque
  /// passo puo' mancare (Firebase non configurato, App Check non pronto, auth
  /// non disponibile) senza mai far crollare l'avvio dell'app. Cio' che non si
  /// riesce a montare degrada verso il ripiego, e la UI lo comunica con garbo.
  static Future<AppServices> bootstrap() async {
    // Passo 1: Firebase. Senza questo si resta del tutto offline.
    try {
      await Firebase.initializeApp();
    } catch (e) {
      return AppServices.offline('Firebase non inizializzato: $e');
    }

    // Passo 2: App Check. Protegge l'AI Logic. In debug si usa il provider di
    // debug con un token che generiamo noi e mostriamo a schermo (da registrare
    // in console per l'enforcement); in release Play Integrity su Android e App
    // Attest su Apple. Best effort.
    String? debugToken;
    try {
      if (kReleaseMode) {
        await FirebaseAppCheck.instance.activate(
          providerAndroid: const AndroidPlayIntegrityProvider(),
          providerApple: const AppleAppAttestProvider(),
        );
      } else {
        debugToken = await AppCheckDebugToken.getOrCreate();
        await FirebaseAppCheck.instance.activate(
          providerAndroid: AndroidDebugProvider(debugToken: debugToken),
          providerApple: AppleDebugProvider(debugToken: debugToken),
        );
      }
    } catch (errore, traccia) {
      // Se App Check non si attiva l'AI puo' ancora funzionare finche' non si
      // impone l'enforcement lato server. Si prosegue, ma si annota: e' il
      // primo sospettato ogni volta che una chiamata viene respinta, e per due
      // giri di lavoro non c'era modo di sapere se fosse partito davvero.
      annotaGuastoInnocuo('attivando App Check', errore, traccia);
    }

    // Il provider AI e' pronto: parla con Gemini su Vertex via Firebase AI.
    final MaestroAiProvider ai = FirebaseMaestroAiProvider();

    // Passo 3: identita' per la memoria. Auth anonima da un uid stabile su cui
    // appendere la memoria dell'utente. Se manca, la chat funziona lo stesso,
    // con memoria solo di sessione.
    MaestroMemoryRepository memory = InMemoryMaestroMemoryRepository();
    bool persistent = false;
    String? note;
    try {
      final auth = FirebaseAuth.instance;
      final user =
          auth.currentUser ?? (await auth.signInAnonymously()).user;
      if (user != null) {
        memory = FirestoreMaestroMemoryRepository(uid: user.uid);
        persistent = true;
      } else {
        note = 'Auth anonima senza utente: memoria solo di sessione.';
      }
    } catch (e) {
      note = 'Memoria persistente non disponibile: $e';
    }

    return AppServices(
      ai: ai,
      memory: memory,
      memoryPersistent: persistent,
      appCheckDebugToken: debugToken,
      showAppCheckDebugToken:
          AppCheckDebugToken.mostraAVideo(releaseMode: kReleaseMode),
      diagnostics: note,
    );
  }
}
