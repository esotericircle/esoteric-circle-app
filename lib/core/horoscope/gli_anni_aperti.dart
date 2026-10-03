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
class GliAnniAperti {
  const GliAnniAperti._();

  static const String _chiave = 'oroscopo_annuale_aperti';

  static Future<Set<int>> letti() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return {
        for (final s in prefs.getStringList(_chiave) ?? const <String>[])
          if (int.tryParse(s) != null) int.parse(s),
      };
    } catch (errore) {
      return {};
    }
  }

  static Future<void> apri(int anno) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final gia = prefs.getStringList(_chiave) ?? const <String>[];
      if (gia.contains('$anno')) return;
      await prefs.setStringList(_chiave, [...gia, '$anno']);
    } catch (errore) {
      // Il disco che non scrive non toglie l'anno aperto adesso: la
      // schermata lo tiene in memoria fino a quando resta aperta.
    }
  }
}
