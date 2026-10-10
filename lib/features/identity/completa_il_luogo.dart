import 'package:flutter/material.dart';

import '../account/dati_di_nascita_screen.dart';

/// DOVE SI VA A COMPLETARE IL LUOGO DI NASCITA, quando un avviso scopre che
/// manca.
///
/// **Perche' esiste.** L'app diceva "per la mappa completa dei pianeti mi
/// serve il tuo luogo di nascita" e da quell'avviso non partiva nessuna
/// strada: la persona doveva indovinare da sola che il posto era il proprio
/// profilo. Questo punto e' quella strada.
///
/// **NON e' una seconda porta, ed e' costato un errore scoprirlo.** La prima
/// stesura apriva un foglio suo, con la sua ricerca delle citta' e la sua
/// scrittura nel profilo: due schermate diverse per lo stesso dato, cioe'
/// esattamente la forma di difetto che questo progetto ha gia' incontrato
/// undici volte. A dirlo e' stata la prova enumerante che conta le porte da
/// cui entrano ora e luogo (`dati_nascita_sbloccano_test`), che le ha viste
/// diventare tre. Il foglio e' stato buttato: qui si apre la schermata che
/// esiste gia' dal giro precedente, `DatiDiNascitaScreen`, che sa correggere
/// data, ora e luogo insieme e rifa' il cielo col dato nuovo.
///
/// Cio' che resta qui e' una cosa sola: la CONOSCENZA di dove si va. Se
/// domani quella schermata cambiasse nome o rotta, a saperlo sarebbe questo
/// punto e nessun altro.
class CompletaIlLuogo {
  const CompletaIlLuogo._();

  /// Porta la persona dove puo' dare il luogo che le manca.
  static Future<void> chiedi(BuildContext context) =>
      Navigator.of(context).push(DatiDiNascitaScreen.route());
}

/// DOVE SI VA A DARE L'ORA CHE MANCA. Ordine CF voce 06.
///
/// **Perche' nasce.** L'ora e' un dato facoltativo, e dall'ordine CF voce
/// 06 la sua assenza non trattiene piu' nessuno dentro il rito: chi
/// rientra col giorno, il luogo e il nome custoditi arriva in home. La
/// guardia dell'ordine AP voce 05 obiettava, con ragione, che cosi'
/// l'Ascendente resterebbe fuori per sempre. **Questa e' la risposta a
/// quell'obiezione**: lo Specchio dei dati dichiarava gia' l'ora mancante
/// e la sua conseguenza, ma non offriva nessun gesto per darla, mentre per
/// il luogo il gesto c'era. Adesso c'e' anche qui.
///
/// **La destinazione e' la stessa**, perche' e' la stessa schermata a
/// correggere data, ora e luogo insieme: cio' che cambia e' il nome della
/// mancanza da cui si parte, e un nome che dice il vero vale la classe.
class CompletaLOra {
  const CompletaLOra._();

  /// Porta la persona dove puo' dare l'ora che le manca.
  static Future<void> chiedi(BuildContext context) =>
      Navigator.of(context).push(DatiDiNascitaScreen.route());
}
