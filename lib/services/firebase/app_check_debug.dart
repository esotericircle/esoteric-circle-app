import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

/// Token di debug di App Check, generato dall'app e stabile nel tempo.
///
/// Passandolo direttamente al provider di debug, l'app usa un token che
/// conosciamo gia', quindi lo si puo' mostrare a schermo e registrare in
/// console senza leggere logcat ne' usare un PC. Resta lo stesso fra un avvio e
/// l'altro grazie alle preferenze locali, cosi' una volta registrato continua a
/// valere. Serve solo per l'enforcement di App Check, non per la prima prova.
class AppCheckDebugToken {
  const AppCheckDebugToken._();

  static const String _key = 'app_check_debug_token';

  /// Restituisce il token salvato, oppure ne crea uno nuovo e lo conserva.
  static Future<String> getOrCreate() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_key);
    if (existing != null && existing.isNotEmpty) return existing;
    final token = _uuidV4();
    await prefs.setString(_key, token);
    return token;
  }

  /// Genera un identificativo in forma UUID versione 4, il formato atteso dal
  /// token di debug di App Check.
  static String _uuidV4() {
    final rnd = Random.secure();
    final bytes = List<int>.generate(16, (_) => rnd.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    String hex(int b) => b.toRadixString(16).padLeft(2, '0');
    final h = bytes.map(hex).join();
    return '${h.substring(0, 8)}-${h.substring(8, 12)}-${h.substring(12, 16)}'
        '-${h.substring(16, 20)}-${h.substring(20)}';
  }
}
