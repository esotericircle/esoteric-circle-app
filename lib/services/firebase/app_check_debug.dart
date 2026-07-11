import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Ponte verso il token di debug di App Check, per mostrarlo a schermo.
///
/// Serve quando si vorra' attivare l'enforcement di App Check senza un PC: il
/// token va registrato in console, e qui si legge dal telefono cosi' Mauro lo
/// copia. Per la prima prova l'enforcement resta spento e il token non serve.
class AppCheckDebug {
  const AppCheckDebug._();

  static const MethodChannel _channel =
      MethodChannel('esoteric_circle/app_check');

  /// Forza App Check a generare e scambiare un token, cosi' il segreto di debug
  /// viene creato e diventa leggibile. Best effort: gli errori si ignorano.
  static Future<void> prime() async {
    try {
      await FirebaseAppCheck.instance.getToken();
    } catch (_) {
      // Senza rete o senza configurazione non fa nulla: nessun impatto.
    }
  }

  /// Legge il segreto di debug di App Check dal dispositivo Android. Restituisce
  /// null su altre piattaforme, o se il token non e' ancora stato generato.
  static Future<String?> androidDebugToken() async {
    if (defaultTargetPlatform != TargetPlatform.android) return null;
    try {
      final token = await _channel.invokeMethod<String>('getDebugToken');
      return (token != null && token.isNotEmpty) ? token : null;
    } catch (_) {
      return null;
    }
  }
}
