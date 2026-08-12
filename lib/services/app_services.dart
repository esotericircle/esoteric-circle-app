import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'ai/firebase_maestro_ai_provider.dart';
import 'ai/maestro_ai_provider.dart';
import 'ai/registro_dei_guasti.dart';
import 'ai/voce_sorvegliata.dart';
import 'firebase/app_check_debug.dart';
import 'firebase/attestazione.dart';
import 'memory/firestore_maestro_memory_repository.dart';
import 'memory/in_memory_maestro_memory_repository.dart';
import 'server/porta_del_cerchio.dart';
import '../core/identity/account_del_cerchio.dart';
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
    this.attestazione = EsitoAttestazione.installata,
    this.appCheckDebugToken,
    this.showAppCheckDebugToken = false,
    this.diagnostics,
    this.porta = const PortaSpentaDelCerchio(),
    this.identita,
  });

  /// LA PORTA DEL SERVER, ordine N: contatori, memoria e saldo passano di
  /// qui. Spenta nei servizi offline e nelle prove, viva nell'app vera.
  final PortaDelCerchio porta;

  /// LA PORTA DELL'IDENTITA', per elevare l'account anonimo ad account vero
  /// senza perdere niente. Nulla quando Firebase non e' partito.
  final PortaDellIdentita? identita;

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
    EsitoAttestazione attestazione = EsitoAttestazione.installata,
    String? appCheckDebugToken,
    bool showAppCheckDebugToken = false,
    String? diagnostics,
    PortaDelCerchio porta = const PortaSpentaDelCerchio(),
    PortaDellIdentita? identita,
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
      attestazione: attestazione,
      appCheckDebugToken: appCheckDebugToken,
      showAppCheckDebugToken: showAppCheckDebugToken,
      diagnostics: diagnostics,
      porta: porta,
      identita: identita,
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

  /// Com'e' andata l'attestazione dell'app. Il pannello di messa a punto la
  /// mostra con la sua ragione: nessuno deve poter credere che l'attestazione
  /// funzioni quando non e' installata.
  final EsitoAttestazione attestazione;

  /// Nota diagnostica per i log, mai mostrata cruda all'utente.
  final String? diagnostics;

  bool get aiReady => ai.isReady;

  /// Servizi inerti, senza rete: usati nei test e come ripiego assoluto.
  ///
  /// [porta] si puo' sostituire: serve alle prove della voce P.34, che devono
  /// poter montare una porta che SOLLEVA e una che non risponde mai, perche'
  /// e' esattamente cosi' che la porta vera si comporta con le funzioni non
  /// ancora distribuite. Senza questo, quel difetto non sarebbe provabile.
  factory AppServices.offline([String? reason, PortaDelCerchio? porta]) {
    return AppServices(
      ai: const UnavailableMaestroAiProvider(),
      memory: InMemoryMaestroMemoryRepository(),
      memoryPersistent: false,
      diagnostics: reason ?? 'Servizi offline.',
      porta: porta ?? const PortaSpentaDelCerchio(),
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

    // Passo 2: l'attestazione dell'app.
    //
    // NON si tocca `FirebaseAppCheck.instance` quando l'attestazione non puo'
    // riuscire, e la ragione sta tutta in `Attestazione`: il servizio si
    // registra sul FirebaseApp SOLO quando qualcuno tocca `instance`, e
    // `firebase_ai` lo cerca con `app.getService<FirebaseAppCheck>()`. Non
    // toccandolo, l'SDK salta l'intestazione e la chiamata parte, invece di
    // morire su `getToken()` con "App attestation failed".
    final registro = RegistroDeiGuasti();
    String? debugToken;
    final esitoAttestazione = await Attestazione.installa(
      releaseMode: kReleaseMode,
      registro: registro,
      installatore: _InstallatoreVero(
        onDebugToken: (t) => debugToken = t,
      ),
    );

    // Il provider AI e' pronto: parla con Gemini su Vertex via Firebase AI.
    final MaestroAiProvider ai = FirebaseMaestroAiProvider();

    // Passo 3: identita' per la memoria. Auth anonima da un uid stabile su cui
    // appendere la memoria dell'utente. Se manca, la chat funziona lo stesso,
    // con memoria solo di sessione.
    MaestroMemoryRepository memory = InMemoryMaestroMemoryRepository();
    bool persistent = false;
    String? note;
    // LA PORTA DEL SERVER E QUELLA DELL'IDENTITA', ordine N.
    //
    // Da qui in avanti i contatori del giorno, il saldo Eos e le scritture
    // della memoria passano dalle callable: le regole di Firestore vietano al
    // telefono di scrivere sotto `users/{uid}`, quindi questa non e' una via
    // preferita, e' l'unica.
    PortaDelCerchio porta = const PortaSpentaDelCerchio();
    PortaDellIdentita? identita;
    try {
      identita = PortaDellIdentitaFirebase();
      final uid = await identita.assicuraUnAccount();
      if (uid != null) {
        porta = PortaVeraDelCerchio();
        memory = FirestoreMaestroMemoryRepository(uid: uid, porta: porta);
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
      porta: porta,
      identita: identita,
      guasti: registro,
      attestazione: esitoAttestazione,
      appCheckDebugToken: debugToken,
      showAppCheckDebugToken:
          AppCheckDebugToken.mostraAVideo(releaseMode: kReleaseMode),
      diagnostics: note,
    );
  }
}

/// L'installatore vero: il fornitore di debug fuori dalla release, Play
/// Integrity e App Attest in release.
///
/// E' l'UNICO punto del progetto che tocca `FirebaseAppCheck.instance`, ed e'
/// per questo che non toccarlo basta a non registrare il servizio.
class _InstallatoreVero implements InstallatoreAttestazione {
  _InstallatoreVero({required this.onDebugToken});

  /// Il token di debug appena creato, per mostrarlo a schermo.
  final void Function(String) onDebugToken;

  @override
  Future<void> installa() async {
    if (kReleaseMode) {
      await FirebaseAppCheck.instance.activate(
        providerAndroid: const AndroidPlayIntegrityProvider(),
        providerApple: const AppleAppAttestProvider(),
      );
      return;
    }
    final token = await AppCheckDebugToken.getOrCreate();
    onDebugToken(token);
    await FirebaseAppCheck.instance.activate(
      providerAndroid: AndroidDebugProvider(debugToken: token),
      providerApple: AppleDebugProvider(debugToken: token),
    );
  }
}
