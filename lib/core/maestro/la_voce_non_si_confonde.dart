/// **LA VOCE DI UN MAESTRO NON SI CONFONDE CON QUELLA DI UN ALTRO.** Ordine
/// EC voce 03, 21 settembre 2026.
///
/// **Il fatto, misurato col modello vero.** Il collaudo della voce EC.01 ha
/// mandato le mosse del catalogo a Gemini due volte. In trenta risposte,
/// **quattro contenevano una parola di firma di un altro Maestro**: Medora
/// che dice *respiro* e poi *presagio* e *sentiero*, Caligo che dice *lama*.
/// E **cambiavano a ogni giro**, cioe' non e' un difetto fisso del codice:
/// e' un'istruzione che il modello rispetta quasi sempre e ogni tanto no.
///
/// **Perche' una rete e non una riga in piu' nell'istruzione.** Il divieto
/// incrociato nell'istruzione c'e' dall'ordine BP voce 1, ed e' stato anche
/// rafforzato in quest'ordine: fra il primo giro e il secondo le violazioni
/// sono passate da una a tre. **Scrivere la regola piu' forte non la fa
/// rispettare**, e insistere sarebbe stato scambiare una speranza per una
/// cura. Quello che si puo' fare e' guardare cio' che torna e, se si e'
/// confuso, chiedere un'altra volta.
///
/// **Il ritentativo e' UNO SOLO, e non blocca mai la persona.** Se anche la
/// seconda risposta si confonde, passa quella con meno parole altrui e il
/// guasto va nel registro: una risposta imperfetta vale piu' di nessuna
/// risposta, e la persona non deve aspettare due volte per niente.
library;

import 'maestro.dart';
import 'voce_del_maestro.dart';

abstract final class LaVoceNonSiConfonde {
  /// Le parole di firma degli ALTRI due Maestri che [testo] contiene.
  ///
  /// Si guardano come parole intere: *lama* non scatta dentro *lamenta*, e
  /// *runa* non scatta dentro *pruna*.
  static List<String> paroleAltruiIn(Maestro maestro, String testo) {
    final basso = testo.toLowerCase();
    return [
      for (final parola in VoceDelMaestro.lessicoDegliAltri(maestro))
        if (RegExp('\\b${RegExp.escape(parola.toLowerCase())}\\b')
            .hasMatch(basso))
          parola,
    ];
  }

  /// Vero se [testo] porta almeno una parola di firma di un altro Maestro.
  static bool siConfonde(Maestro maestro, String testo) =>
      paroleAltruiIn(maestro, testo).isNotEmpty;

  /// Fra due risposte, quella che si confonde di meno.
  ///
  /// A parita' resta la prima: non si scambia una risposta con un'altra
  /// uguale solo perche' e' arrivata dopo.
  static String laMenoConfusa(Maestro maestro, String prima, String poi) =>
      paroleAltruiIn(maestro, poi).length <
              paroleAltruiIn(maestro, prima).length
          ? poi
          : prima;
}
