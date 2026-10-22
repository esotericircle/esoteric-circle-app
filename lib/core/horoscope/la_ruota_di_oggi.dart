import 'package:shared_preferences/shared_preferences.dart';

/// **IL FILMATO DELLA RUOTA, VISTO UNA VOLTA AL GIORNO.** Ordine GB voce 02,
/// 22 ottobre 2026.
///
/// Il filmato d'apertura dell'Oroscopo (la ruota dello zodiaco, circa nove
/// secondi) si vede per intero la prima volta che la persona apre la
/// funzione in un giorno civile; alle aperture seguenti dello stesso giorno
/// la scena parte gia' ferma, come se il video fosse gia' stato saltato.
/// Fonte: la proposta dell'Architetto nel rapporto dell'ordine GA,
/// approvata dal fondatore il 22 ottobre 2026 ("Ok per tutto").
///
/// Stessa forma di [LaLungaDiOggi]: una chiave sola, il giorno civile scritto
/// come stringa, mai un contatore che si possa sbagliare di uno.
abstract final class LaRuotaDiOggi {
  static const String _chiave = 'oroscopo_ruota_vista_il';

  static String _giorno(DateTime g) =>
      '${g.year}-${g.month.toString().padLeft(2, '0')}-'
      '${g.day.toString().padLeft(2, '0')}';

  /// Se la ruota del giorno [oggi] e' gia' stata vista.
  static Future<bool> vistaOggi(DateTime oggi) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_chiave) == _giorno(oggi);
    } catch (errore) {
      // Se il disco non legge, vale la vecchia regola: si vede il filmato.
      return false;
    }
  }

  /// Segna la ruota del giorno [oggi] come vista.
  static Future<void> segna(DateTime oggi) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_chiave, _giorno(oggi));
    } catch (errore) {
      // Se il disco non scrive vale per questa apertura: la prossima
      // rivedra' il filmato, che non e' un errore grave quanto bloccarla.
    }
  }
}
