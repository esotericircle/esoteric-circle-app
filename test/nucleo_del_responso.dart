import 'package:esoteric_circle/core/tarot/figure_della_stesa.dart';

/// **IL NUCLEO DI UN TESTO, per le prove sul corpus dell'Arcano dell'Alba.**
/// Ordine DT voci 09, 13 e 24, 17 settembre 2026.
///
/// Due testi **condividono il nucleo** quando dicono la stessa immagine o la
/// stessa sostanza. Si misura in due modi, e ne basta uno:
///
/// 1. **la stessa figura**, con il lessico delle figure della Stesa: e' lo
///    stesso lessico, non un secondo, perche' l'impianto contro le
///    ripetizioni e' uno solo (voce 27);
/// 2. **almeno due radici di contenuto in comune**, cioe' parole piene di
///    quattro lettere o piu', troncate a cinque, fuori dall'elenco delle
///    parole vuote. Una radice sola in comune e' lessico, due sono un tema.
///
/// **Le parole vuote non sono un modo di far passare il corpus.** Sono le
/// parole di servizio della lingua e quelle della cornice del dono, che ogni
/// responso deve poter dire: *carta*, *mazzo*, *segno*, *mattino*, *oggi*.
abstract final class NucleoDelResponso {
  static const Set<String> vuote = {
    // la lingua
    'anche', 'ancora', 'adesso', 'allora', 'altro', 'altra', 'altri', 'altre',
    'avere', 'aveva', 'bene', 'certo', 'come', 'cosa', 'cose', 'cosi',
    'dalla', 'dalle', 'dallo', 'degli', 'della', 'delle', 'dello', 'dentro',
    'dopo', 'dove', 'essere', 'fare', 'fatto', 'fino', 'meno', 'mentre',
    'molto', 'nella', 'nelle', 'nello', 'niente', 'nulla', 'ogni', 'pero',
    'perche', 'poco', 'prima', 'proprio', 'qualche', 'qualcosa', 'qualcuno',
    'quale', 'quando', 'quanto', 'quello', 'quella', 'quelli', 'quelle',
    'questa', 'questo', 'questi', 'queste', 'sempre', 'senza', 'solo',
    'soltanto', 'sono', 'sopra', 'sotto', 'stesso', 'stessa', 'stessi',
    'tanto', 'tutto', 'tutta', 'tutti', 'tutte', 'verso', 'volta', 'davvero',
    'alla', 'alle', 'agli', 'allo', 'hanno', 'sulla', 'sulle', 'negli',
    // le preposizioni che l'apostrofo tronca: dell'Aria, nell'elemento
    'dell', 'nell', 'sull', 'dall', 'quell',
    // la cornice del dono
    'oggi', 'ieri', 'domani', 'giorno', 'giornata', 'mattino', 'mattina',
    'mattine', 'stamattina', 'stamani', 'sera', 'stasera', 'carta', 'carte',
    'mazzo', 'dorso', 'arcano', 'arcani', 'maggiori', 'lettera', 'madre',
    'doppia', 'semplice', 'segno', 'segni', 'elemento', 'pianeta', 'governo',
    'dritto', 'dritta', 'dritti', 'rovesciato', 'rovesciata', 'rovesciati',
  };

  static String _senzaAccenti(String s) {
    const mappa = {
      'à': 'a', 'á': 'a', 'è': 'e', 'é': 'e', 'ì': 'i', 'í': 'i', //
      'ò': 'o', 'ó': 'o', 'ù': 'u', 'ú': 'u',
    };
    return s.toLowerCase().split('').map((c) => mappa[c] ?? c).join();
  }

  /// Le parole di [testo], in minuscolo e senza accenti.
  static List<String> parole(String testo) => RegExp(r'[a-z]+')
      .allMatches(_senzaAccenti(testo))
      .map((m) => m.group(0)!)
      .toList();

  /// Le radici di contenuto di [testo].
  static Set<String> radici(String testo) => {
        for (final p in parole(testo))
          if (p.length >= 4 && !vuote.contains(p))
            p.length > 5 ? p.substring(0, 5) : p,
      };

  /// Cio' che [a] e [b] hanno in comune, se condividono il nucleo; null se no.
  static String? condiviso(String a, String b) {
    final figure = FigureDellaStesa.di(_senzaAccenti(a))
        .intersection(FigureDellaStesa.di(_senzaAccenti(b)));
    if (figure.isNotEmpty) return 'la figura ${figure.join(', ')}';
    final comuni = radici(a).intersection(radici(b));
    if (comuni.length >= 2) return 'le radici ${comuni.join(', ')}';
    return null;
  }

  /// Se [testo] contiene una parola che comincia come [parola]: *"valori"*
  /// prende *"valore"*, *"resa"* non prende *"sorpresa"*.
  static bool nomina(String testo, String parola) {
    final radice = parole(parola).join(' ');
    if (radice.isEmpty) return false;
    final corta = radice.length > 5 ? radice.substring(0, 5) : radice;
    return parole(testo).any((p) => p.startsWith(corta));
  }

  /// Gli articoli e le preposizioni che stanno dentro il nome di una carta e
  /// non sono il suo nome: *"gli"* degli Amanti, *"della"* della Ruota della
  /// Fortuna. Ordine DU voce 12: senza questo elenco una frase che comincia
  /// con *"Gli affetti"* risultava nominare gli Amanti.
  static const servizio = {
    'del',
    'dei',
    'della',
    'delle',
    'dello',
    'degli',
    'dell',
    'il',
    'lo',
    'la',
    'i',
    'gli',
    'le',
    'un',
    'uno',
    'una',
  };

  /// Se [testo] contiene una qualunque delle parole piene di [nome]: anche
  /// solo *"Fortuna"* nomina la Ruota della Fortuna.
  static bool contieneIlNome(String testo, String nome) {
    final piene = [
      for (final p in parole(nome))
        if (p.length >= 3 && !vuote.contains(p) && !servizio.contains(p)) p,
    ];
    if (piene.isEmpty) return false;
    final t = parole(testo);
    return piene.any(t.contains);
  }
}
