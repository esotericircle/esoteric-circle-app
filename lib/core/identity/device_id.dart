import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

/// L'identita' stabile del dispositivo, per i Doni deterministici di chi non ha
/// ancora dato la data di nascita. Senza questa, ogni utente anonimo riceverebbe
/// la stessa runa, lo stesso verso, la stessa insistenza, in contraddizione con
/// la promessa "la runa e' tua e non la stessa per tutti".
///
/// E' un id casuale generato una volta e conservato in `shared_preferences`. Non
/// e' un identificatore hardware ne' un dato personale: solo sedici byte casuali
/// che restano sul dispositivo. Best-effort: se le preferenze non rispondono,
/// ritorna una costante nota senza mai propagare l'errore.
class DeviceId {
  const DeviceId._();

  static const String _chiave = "device.id";

  /// Il valore di ripiego quando le preferenze non sono disponibili. Stabile,
  /// cosi' anche in errore l'estrazione resta deterministica sul dispositivo.
  static const String sconosciuto = "sconosciuto";

  static String? _cache;

  /// L'id del dispositivo, esadecimale minuscolo. Lo legge dalle preferenze, e
  /// se manca ne genera uno nuovo con `Random.secure`, lo scrive e lo restituisce.
  static Future<String> corrente() async {
    final memorizzato = _cache;
    if (memorizzato != null) return memorizzato;
    try {
      final prefs = await SharedPreferences.getInstance();
      final salvato = prefs.getString(_chiave);
      if (salvato != null && salvato.isNotEmpty) {
        _cache = salvato;
        return salvato;
      }
      final nuovo = _genera();
      await prefs.setString(_chiave, nuovo);
      _cache = nuovo;
      return nuovo;
    } catch (_) {
      return sconosciuto;
    }
  }

  /// Sedici byte da `Random.secure`, in esadecimale minuscolo.
  static String _genera() {
    final rng = Random.secure();
    final buf = StringBuffer();
    for (var i = 0; i < 16; i++) {
      buf.write(rng.nextInt(256).toRadixString(16).padLeft(2, '0'));
    }
    return buf.toString();
  }
}
