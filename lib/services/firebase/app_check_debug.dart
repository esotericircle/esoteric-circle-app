import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

/// Token di debug di App Check, stabile nel tempo e leggibile a video.
///
/// Passandolo direttamente al provider di debug, l'app usa un token che
/// conosciamo gia', quindi lo si puo' mostrare a schermo e registrare in
/// console senza leggere logcat ne' usare un PC. Resta lo stesso fra un avvio e
/// l'altro grazie alle preferenze locali, cosi' una volta registrato continua a
/// valere. Serve solo per l'enforcement di App Check, non per la prima prova.
///
/// Quando la build porta `--dart-define=APP_CHECK_DEBUG_TOKEN=...`, quel token
/// vince su qualunque altro: e' il caso dell'APK che si installa da casa, dove
/// dal telefono non si puo' registrare in console un token appena generato, e
/// quindi il token deve essere gia' valido al primo avvio.
class AppCheckDebugToken {
  const AppCheckDebugToken._();

  static const String _key = 'app_check_debug_token';

  /// Token fissato alla compilazione, vuoto se la build non lo passa.
  static const String tokenFissato =
      String.fromEnvironment('APP_CHECK_DEBUG_TOKEN');

  /// Vero se il token va mostrato a video. Solo fuori dalla release: in release
  /// non compare mai, ne' nella striscia ne' nelle Impostazioni.
  static bool mostraAVideo({required bool releaseMode}) => !releaseMode;

  /// Restituisce il token fissato dalla build, altrimenti quello salvato,
  /// altrimenti ne crea uno nuovo e lo conserva.
  ///
  /// Il parametro [fissato] esiste per i test, che non possono passare una
  /// `--dart-define`: a runtime resta sempre [tokenFissato].
  static Future<String> getOrCreate({String fissato = tokenFissato}) async {
    final prefs = await SharedPreferences.getInstance();
    if (fissato.isNotEmpty) {
      // Riallinea anche le preferenze, cosi' chi legge di la' non trova un
      // token diverso da quello che l'app sta davvero presentando.
      if (prefs.getString(_key) != fissato) {
        await prefs.setString(_key, fissato);
      }
      return fissato;
    }
    final existing = prefs.getString(_key);
    if (existing != null && existing.isNotEmpty) return existing;
    final token = _uuidV4();
    await prefs.setString(_key, token);
    return token;
  }

  /// Il token da mostrare: quello che i servizi hanno gia' in mano, oppure,
  /// se l'attivazione di App Check e' fallita e quindi non c'e', quello letto
  /// dalle preferenze, che non dipende da Firebase. Null solo se nemmeno le
  /// preferenze rispondono.
  static Future<String?> risolvi(String? daiServizi) async {
    if (daiServizi != null && daiServizi.isNotEmpty) return daiServizi;
    try {
      return await getOrCreate();
    } catch (_) {
      return null;
    }
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
