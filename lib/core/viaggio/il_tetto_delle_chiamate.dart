import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_flags.dart';
import 'tetti_del_viaggio.dart';

/// **IL TETTO TECNICO DEL MODELLO, per la sola difesa dai costi.** Ordini DI
/// voce 15 e DL voci 09 e 14.
///
/// **NON E' UN LIMITE CHE LA PERSONA VEDE.** Il piano dice quante discese e
/// quanti segni; questo tetto dice quante volte, in un giorno, il Viaggio puo'
/// chiedere a Gemini. Oltre, la persona continua a scendere e a ricevere
/// risposte: le danno le vie di riserva, la tabella delle parole e la voce di
/// casa, e **non glielo si dice**.
///
/// **CONTA LE DISCESE E I SEGNI, NON LE CHIAMATE.** Ordine DL voce 09. Qui si
/// contavano le chiamate, dieci al giorno contando discese e segni insieme: e
/// una discesa ne fa da una a tre, il classificatore della domanda scritta a
/// mano, la scena, e la scena richiesta quando la prima si scarta. Dieci
/// chiamate valevano da tre a dieci discese, e nessuno se ne era accorto,
/// perche' il piano concede discese. **Adesso il numero resta dieci e cambia
/// l'unita'**: dieci discese e dieci segni al giorno, contati per conto loro, e
/// le chiamate seguono.
///
/// **E CONTA ANCHE IN DEMO.** Ordine DL voce 14. Fino a quest'ordine in Demo il
/// tetto non contava, e chi provava vedeva sempre il modello. Ma chi prova
/// deve vedere l'app come la vedra' chi la usa, e sapere quando guarda la
/// riserva: il Diario lo scrive, voce DL.14. **Per le prove lunghe c'e' il
/// comando di collaudo**, [alzatoPerIlCollaudo], che esiste solo in Demo.
abstract final class IlTettoDelleChiamate {
  static const String _chiaveDiscese = 'viaggio.tetto.discese';
  static const String _chiaveSegni = 'viaggio.tetto.segni';

  /// **IL COMANDO DI COLLAUDO CHE ALZA IL TETTO.** Ordine DL voce 14.
  ///
  /// **Vive in memoria e parte spento**: non si attiva da solo in nessun caso,
  /// e al riavvio dell'app e' spento di nuovo. Lo accende e lo spegne soltanto
  /// la voce del comando di Demo della soglia del Viaggio; spento, il tetto
  /// torna quello di sempre subito, senza riavviare niente. **Fuori dalla Demo
  /// non vale**, anche se qualcuno lo accendesse: vedi [alzato].
  static bool alzatoPerIlCollaudo = false;

  /// Vero quando il tetto e' alzato davvero: in Demo, col comando acceso.
  static bool alzato({bool demo = AppFlags.isDemo}) =>
      demo && alzatoPerIlCollaudo;

  /// **IL PERMESSO SEMPRE CONCESSO**, per chi l'ha gia' preso: la discesa
  /// prende il tetto una volta al tocco di Scendi, e le sue chiamate lo
  /// portano con se'.
  static Future<bool> sempre() async => true;

  /// **PRENDE UNA DISCESA**, se oggi ce n'e' ancora una per il modello. Torna
  /// vero se si puo' chiamare il modello, e in quel caso la discesa e' gia'
  /// contata.
  ///
  /// **Se l'archivio non risponde si chiama lo stesso.** E' una difesa dai
  /// costi, non una regola del metodo.
  static Future<bool> prendiUnaDiscesa({
    DateTime? adesso,
    bool demo = AppFlags.isDemo,
  }) =>
      _prendi(_chiaveDiscese, TettiDelViaggio.disceseAlModelloAlGiorno,
          adesso: adesso, demo: demo);

  /// **PRENDE UN SEGNO**, come [prendiUnaDiscesa], sul conto dei segni.
  static Future<bool> prendiUnSegno({
    DateTime? adesso,
    bool demo = AppFlags.isDemo,
  }) =>
      _prendi(_chiaveSegni, TettiDelViaggio.segniAlModelloAlGiorno,
          adesso: adesso, demo: demo);

  /// Quante discese hanno preso il modello oggi. Serve alle prove e al
  /// rapporto.
  static Future<int> quanteDisceseOggi({DateTime? adesso}) =>
      _quante(_chiaveDiscese, adesso);

  /// Quanti segni hanno preso il modello oggi.
  static Future<int> quantiSegniOggi({DateTime? adesso}) =>
      _quante(_chiaveSegni, adesso);

  static Future<bool> _prendi(String chiave, int tetto,
      {DateTime? adesso, required bool demo}) async {
    if (alzato(demo: demo)) return true;
    final oggi = _giorno(adesso ?? DateTime.now());
    try {
      final prefs = await SharedPreferences.getInstance();
      final parti = (prefs.getString(chiave) ?? '').split('|');
      final fatte = parti.length == 2 && parti[0] == oggi
          ? int.tryParse(parti[1]) ?? 0
          : 0;
      if (fatte >= tetto) return false;
      await prefs.setString(chiave, '$oggi|${fatte + 1}');
      return true;
    } catch (errore) {
      return true;
    }
  }

  static Future<int> _quante(String chiave, DateTime? adesso) async {
    final oggi = _giorno(adesso ?? DateTime.now());
    try {
      final prefs = await SharedPreferences.getInstance();
      final parti = (prefs.getString(chiave) ?? '').split('|');
      return parti.length == 2 && parti[0] == oggi
          ? int.tryParse(parti[1]) ?? 0
          : 0;
    } catch (errore) {
      return 0;
    }
  }

  static String _giorno(DateTime d) => '${d.year}-${d.month}-${d.day}';
}
