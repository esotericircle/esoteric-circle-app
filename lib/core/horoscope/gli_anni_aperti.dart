import 'package:shared_preferences/shared_preferences.dart';

/// **GLI ANNI APERTI CON GLI EOS, ordine ES voce 04.**
///
/// Chi non ha l'Adepto apre l'oroscopo dell'anno che corre con 300 Eos: qui
/// si ricorda quale anno (quello dell'istante della Rivoluzione Solare), cosi'
/// riaprendo la schermata non si paga due volte. Sta sul telefono: il saldo
/// degli Eos lo scala il server, ma l'anno aperto non ha una casa sul server,
/// e lo dice il rapporto.
///
/// Best-effort come gli altri store: senza preferenze torna l'insieme vuoto.
///
/// **PER SOGGETTO, ordine FC voce 02.** Dall'ordine FC l'Oroscopo legge anche
/// un amico: aprire con gli Eos l'anno di un amico non apre il proprio, e
/// viceversa. [soggetto] e' la chiave del soggetto
/// (`IlSoggettoDellOroscopo.chiave`); nullo per la lettura propria, che resta
/// sulla chiave di prima.
class GliAnniAperti {
  const GliAnniAperti._();

  static const String _chiave = 'oroscopo_annuale_aperti';

  static String _di(String? soggetto) =>
      soggetto == null ? _chiave : '$_chiave|$soggetto';

  static Future<Set<int>> letti({String? soggetto}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return {
        for (final s in prefs.getStringList(_di(soggetto)) ?? const <String>[])
          if (int.tryParse(s) != null) int.parse(s),
      };
    } catch (errore) {
      return {};
    }
  }

  static Future<void> apri(int anno, {String? soggetto}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final gia = prefs.getStringList(_di(soggetto)) ?? const <String>[];
      if (gia.contains('$anno')) return;
      await prefs.setStringList(_di(soggetto), [...gia, '$anno']);
    } catch (errore) {
      // Il disco che non scrive non toglie l'anno aperto adesso: la
      // schermata lo tiene in memoria fino a quando resta aperta.
    }
  }
}
