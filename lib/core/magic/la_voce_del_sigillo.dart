import 'intention_sigil.dart';

/// **LA VOCE DEL SIGILLO.** Ordine DO voci 01, 04, 05, 10 e 11,
/// 15 settembre 2026.
///
/// I testi di casa della funzione, in un punto solo: le tre righe
/// dell'ingresso, la riga a tracciamento finito, i titoli e i responsi di
/// riserva per quando il modello non risponde o una guardia scarta la sua
/// riga, il testo del compimento di riserva e i messaggi del limite.
///
/// **Nessuna marca di genere serve**: ogni frase parla a chi legge senza un
/// participio ne' un aggettivo accordato, e una guardia lo pretende.
abstract final class LaVoceDelSigillo {
  // ---------------------------------------------------------------------
  // LE TRE INFORMAZIONI ALL'INGRESSO, voce DO.01.
  // ---------------------------------------------------------------------

  /// **COSA STAI PER FARE**, sotto il titolo della schermata.
  static const String cosaStaiPerFare =
      'Un sigillo è un\'intenzione trasformata in un segno. Si scrive, si '
      'traccia col dito e poi si lascia lavorare.';

  /// **COSA TI RESTERA'**, prima del campo dove si scrive.
  static const String cosaTiRestera =
      'Il segno resta tuo. Si accende ogni volta che ci torni e alla data '
      'che scegli ti chiederà com\'è andata.';

  /// **DA DOVE VIENE**, riga breve e verso il basso.
  static const String daDoveViene =
      'Il metodo viene da Austin Osman Spare, The Book of Pleasure, 1913: '
      'l\'intenzione si scrive, si tolgono le lettere ripetute e i segni '
      'rimasti si intrecciano finché non si leggono più.';

  /// **IL PERCHE' DEL NON LEGGERSI**, per il foglio delle fonti: la parte del
  /// metodo che nessuno immagina, e quella che rende il segno una cosa seria.
  static const String illeggibileApposta =
      'Il segno è illeggibile apposta: la mente non deve poter risalire '
      'all\'intenzione, perché un\'intenzione sorvegliata non lavora. Per '
      'questo il segno non porta mai scritta la frase.';

  // ---------------------------------------------------------------------
  // LA DIMENTICANZA LA FA L'APP, voce DO.04.
  // ---------------------------------------------------------------------

  /// **LA RIGA A TRACCIAMENTO FINITO**, una sola.
  static const String lasciaLavorare =
      'Adesso lascialo lavorare. Lo ritrovi nel Libro dei Sigilli quando '
      'vuoi e ti cerco io alla data che hai scelto.';

  // ---------------------------------------------------------------------
  // LA FINE DEL CICLO, voce DO.05.
  // ---------------------------------------------------------------------

  /// La domanda di Caligo alla scadenza.
  static const String laDomanda = 'Questo sigillo è arrivato alla sua data. '
      'Com\'è andata?';

  static const String siECompiuto = 'Si è compiuto';
  static const String loLascioAndare = 'Lo lascio andare';
  static const String loRinnovo = 'Lo rinnovo';

  /// **LA NOTIFICA NON CONTIENE L'INTENZIONE**, voce DO.08: si legge sulla
  /// schermata di blocco, davanti a chiunque passi.
  static const String titoloDellAvviso = 'Un sigillo è arrivato alla sua data';
  static const String testoDellAvviso = 'Caligo ti chiede com\'è andata.';

  /// **IL TESTO DEL COMPIMENTO DI RISERVA**, che nomina l'intenzione scritta.
  /// Voce DO.05: *"non una congratulazione generica, ma una riga che nomina
  /// l'intenzione che aveva scritto"*.
  static String compimento(String intenzione) =>
      'Avevi scritto "${intenzione.trim()}". Quello che era un segno adesso '
      'è una cosa accaduta: resta nel Libro, sigillato.';

  /// **LO LASCI ANDARE**, la riga che chiude senza giudicare.
  static const String lasciato =
      'Resta nel Libro come una cosa chiusa. Non tutto quello che si chiede '
      'deve arrivare per contare.';

  // ---------------------------------------------------------------------
  // IL LIMITE DEL PIANO, voce DO.11: non un muro, una strada.
  // ---------------------------------------------------------------------

  /// A spazio pieno si dice come fare, e si porta al Libro.
  static String pieno(int quanti) => quanti == 1
      ? 'Il tuo piano tiene un sigillo vivo alla volta. Per tracciarne uno '
          'nuovo, chiudi quello che hai nel Libro dei Sigilli.'
      : 'Il tuo piano tiene $quanti sigilli vivi insieme: sono tutti '
          'aperti. Per tracciarne uno nuovo, chiudine uno nel Libro dei '
          'Sigilli.';

  static const String tettoTecnico =
      'Oggi i sigilli tracciati sono dieci. Il prossimo si traccia domani.';

  // ---------------------------------------------------------------------
  // LA RISERVA DEI TITOLI E DEI RESPONSI, voce DO.10.
  // ---------------------------------------------------------------------

  /// I titoli di casa per via: sei parole al massimo, nessun tempo, nessun
  /// genere.
  static const Map<ViaMagica, List<String>> titoli = {
    ViaMagica.rossa: [
      'Il desiderio ha preso forma',
      'Ciò che vuoi ha un segno',
      'Il cuore ha scelto il segno',
      'Uno slancio che resta tuo',
    ],
    ViaMagica.bianca: [
      'La chiarezza ha preso forma',
      'Un confine che si vede',
      'Ciò che proteggi ha un segno',
      'La quiete ha il suo segno',
    ],
    ViaMagica.verde: [
      'Il seme ha preso forma',
      'Un segno che mette radici',
      'Ciò che cresce ha un segno',
      'La radice ha il suo segno',
    ],
  };

  /// I responsi di casa per via: nominano l'intenzione scritta, perche' una
  /// riga generica e' esattamente cio' che l'ordine vuole evitare.
  static const Map<ViaMagica, List<String>> responsi = {
    ViaMagica.rossa: [
      'Hai dato un segno a "{i}". Non si legge apposta: lavora dove la '
          'mente non sorveglia.',
      'Quello che desideri, "{i}", adesso sta in un segno solo. Tornaci '
          'quando vuoi: ogni volta si accende un poco.',
    ],
    ViaMagica.bianca: [
      'Hai dato un segno a "{i}". Non si legge apposta: lavora dove la '
          'mente non sorveglia.',
      'Quello che chiedi, "{i}", adesso sta in un segno solo. Tornaci '
          'quando vuoi: ogni volta si accende un poco.',
    ],
    ViaMagica.verde: [
      'Hai dato un segno a "{i}". Non si legge apposta: lavora dove la '
          'mente non sorveglia.',
      'Quello che vuoi far crescere, "{i}", adesso sta in un segno solo. '
          'Tornaci quando vuoi: ogni volta si accende un poco.',
    ],
  };

  /// Il titolo di casa per [via], scelto dalle lettere dell'intenzione: la
  /// stessa intenzione ha lo stesso titolo, due diverse spesso no.
  static String titoloDiCasa(ViaMagica via, String intenzione) {
    final l = titoli[via]!;
    return l[_seme(intenzione) % l.length];
  }

  static String responsoDiCasa(ViaMagica via, String intenzione) {
    final l = responsi[via]!;
    return l[_seme(intenzione) % l.length].replaceAll('{i}', intenzione.trim());
  }

  static int _seme(String s) {
    var h = 0;
    for (final c in s.codeUnits) {
      h = (h * 31 + c) & 0x7fffffff;
    }
    return h;
  }
}
