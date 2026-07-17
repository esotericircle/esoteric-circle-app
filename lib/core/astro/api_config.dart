import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

/// Configurazione dell'accesso al motore astrologico.
///
/// La chiave dell'API NON e' mai scritta nel codice ne versionata. Si legge
/// dalla variabile d'ambiente `FREEASTRO_API_KEY`, in due modi:
/// - da `--dart-define=FREEASTRO_API_KEY=...` al build (compile-time), utile
///   per le build reali su device;
/// - dall'ambiente di processo (desktop, test, CI), utile in sviluppo.
/// In produzione la chiave restera' lato server (Secret Manager), mai nell'app.
class AstroApiConfig {
  AstroApiConfig._();

  /// Base URL del servizio. Il percorso esatto va confermato sul piano
  /// FreeAstroAPI di Mauro; e' isolato qui per poterlo aggiornare in un punto.
  static const String baseUrl = 'https://freeastroapi.com';

  static const String _compiledKey =
      String.fromEnvironment('FREEASTRO_API_KEY');

  /// Chiave API, o null se non configurata (allora si mostra il cielo essenziale).
  static String? get apiKey {
    if (_compiledKey.isNotEmpty) return _compiledKey;
    if (!kIsWeb) {
      final env = Platform.environment['FREEASTRO_API_KEY'];
      if (env != null && env.isNotEmpty) return env;
    }
    return null;
  }

  static bool get hasKey => apiKey != null;
}
