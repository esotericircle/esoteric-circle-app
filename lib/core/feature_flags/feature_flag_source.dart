import 'feature_flag.dart';

/// Sorgente delle leve remote dei feature flag.
///
/// Astrae DA DOVE arrivano i valori: in C1 la sorgente e' locale e restituisce
/// i default del catalogo, cosi' l'app gira su qualsiasi device senza dover
/// configurare Firebase. Quando in un checkpoint successivo si aggiungera'
/// Firebase Remote Config (dopo `flutterfire configure`), bastera' fornire una
/// implementazione `RemoteConfigFeatureFlagSource` senza toccare il resto:
/// il `FeatureFlagService` non cambia.
///
/// Riferimento: Master Tecnico sezione 28, feature flags via Firebase Remote
/// Config; nessuna chiave o file di configurazione va versionato.
abstract class FeatureFlagSource {
  /// Carica le leve remote. Chiave = id della funzione, valore = disponibilita'
  /// forzata da remoto. Le funzioni non presenti usano il default del catalogo.
  Future<Map<String, RemoteAvailability>> load();
}

/// Sorgente locale di default.
///
/// Non forza nulla da remoto: ogni funzione usa la `defaultAvailability`
/// dichiarata nel catalogo. E' la sorgente attiva in C1.
class LocalFeatureFlagSource implements FeatureFlagSource {
  const LocalFeatureFlagSource();

  @override
  Future<Map<String, RemoteAvailability>> load() async =>
      const <String, RemoteAvailability>{};
}
