import 'package:shared_preferences/shared_preferences.dart';

/// **LA LUNGA DI OGGI COMPRATA CON GLI EOS, ordine EU voce 15.**
///
/// La tabella della voce ES.06, approvata dal fondatore (*"Approvo
/// tutto."*): *"Occidentale del giorno, Approfondita: 50 Eos, per la
/// giornata e le quattro schede"*; e alla domanda del 30 settembre *"Chi può
/// scegliere la profondità Lunga?"*, *"Premium più Eos"*. Chi non ha un piano
/// con la Lunga la apre per il giorno civile in cui la compra, sulle quattro
/// schede dell'Oroscopo occidentale del giorno; qui si ricorda quale giorno.
abstract final class LaLungaDiOggi {
  static const String _chiave = 'oroscopo_lunga_comprata_il';

  static String _giorno(DateTime g) =>
      '${g.year}-${g.month.toString().padLeft(2, '0')}-'
      '${g.day.toString().padLeft(2, '0')}';

  /// Se la Lunga del giorno [oggi] e' gia' stata comprata.
  static Future<bool> comprata(DateTime oggi) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_chiave) == _giorno(oggi);
    } catch (errore) {
      return false;
    }
  }

  /// Segna la Lunga del giorno [oggi] come comprata.
  static Future<void> segna(DateTime oggi) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_chiave, _giorno(oggi));
    } catch (errore) {
      // Se il disco non scrive vale per questa apertura: la schermata la
      // tiene in memoria.
    }
  }
}
