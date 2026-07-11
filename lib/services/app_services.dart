import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'ai/firebase_maestro_ai_provider.dart';
import 'ai/maestro_ai_provider.dart';
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
  const AppServices({
    required this.ai,
    required this.memory,
    required this.memoryPersistent,
    this.appCheckDebugToken,
    this.diagnostics,
  });

  final MaestroAiProvider ai;
  final MaestroMemoryRepository memory;

  /// Vero se la memoria e' davvero persistente (Firestore), falso se solo in
  /// RAM per la sessione.
  final bool memoryPersistent;

  /// Token di debug di App Check da mostrare a schermo, quando in debug. Null in
  /// release o quando non pertinente. Serve solo per l'enforcement.
  final String? appCheckDebugToken;

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
    } catch (_) {
      // Se App Check non si attiva l'AI puo' ancora funzionare finche' non si
      // impone l'enforcement lato server. Si prosegue.
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
      diagnostics: note,
    );
  }
}
