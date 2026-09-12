import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_flags.dart';
import 'tetti_del_viaggio.dart';

/// **IL TETTO DELLE CHIAMATE AL MODELLO, per la sola difesa dai costi.**
/// Ordine DI voce 15, 12 settembre 2026.
///
/// **Le parole dell'ordine:** *"tetto tecnico oltre il piano, per la sola
/// difesa dai costi: dieci chiamate al modello al giorno per utente, contando
/// discese e segni insieme"*.
///
/// **NON E' UN LIMITE CHE LA PERSONA VEDE.** Il piano dice quante discese e
/// quanti segni; questo tetto dice quante volte, in un giorno, il Viaggio puo'
/// chiedere a Gemini. Oltre la decima chiamata la persona continua a scendere
/// e a ricevere risposte: le danno le vie di riserva, la tabella delle parole
/// e la composizione deterministica, e **non glielo si dice**, come non le si
/// dice mai quale delle due vie ha risposto.
///
/// **Si conta la chiamata, non la discesa.** Una discesa con la domanda scritta
/// a mano ne fa due, la domanda capita e la scena; una con la domanda scelta
/// ne fa una. E' il costo vero, ed e' il numero che l'ordine chiede.
///
/// **IN DEMO NON CONTA**, come ogni altro tetto del Viaggio: il fondatore deve
/// poter valutare il modello per tutte le discese che vuole, e una scena che
/// dopo la decima prova passasse di nascosto alla riserva gli farebbe giudicare
/// la riserva credendo di giudicare il modello.
abstract final class IlTettoDelleChiamate {
  static const String _chiave = 'viaggio.chiamateAlModello';

  /// **PRENDE UNA CHIAMATA**, se oggi ce n'e' ancora una. Torna vero se si puo'
  /// chiamare il modello, e in quel caso la chiamata e' gia' contata.
  ///
  /// **Se l'archivio non risponde si chiama lo stesso.** E' una difesa dai
  /// costi, non una regola del metodo: una persona che resta senza modello
  /// perche' il telefono non ha scritto un numero perderebbe qualcosa di vero
  /// per salvare qualcosa di trascurabile.
  static Future<bool> prendiUnaChiamata({
    DateTime? adesso,
    bool demo = AppFlags.isDemo,
  }) async {
    if (demo) return true;
    final oggi = _giorno(adesso ?? DateTime.now());
    try {
      final prefs = await SharedPreferences.getInstance();
      final salvato = prefs.getString(_chiave) ?? '';
      final parti = salvato.split('|');
      final fatte =
          parti.length == 2 && parti[0] == oggi ? int.tryParse(parti[1]) ?? 0 : 0;
      if (fatte >= TettiDelViaggio.chiamateAlModelloAlGiorno) return false;
      await prefs.setString(_chiave, '$oggi|${fatte + 1}');
      return true;
    } catch (errore) {
      return true;
    }
  }

  /// Quante chiamate sono state prese oggi. Serve alle prove e al rapporto.
  static Future<int> quanteOggi({DateTime? adesso}) async {
    final oggi = _giorno(adesso ?? DateTime.now());
    try {
      final prefs = await SharedPreferences.getInstance();
      final parti = (prefs.getString(_chiave) ?? '').split('|');
      return parti.length == 2 && parti[0] == oggi
          ? int.tryParse(parti[1]) ?? 0
          : 0;
    } catch (errore) {
      return 0;
    }
  }

  static String _giorno(DateTime d) => '${d.year}-${d.month}-${d.day}';
}
