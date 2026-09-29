import 'i_termini_solari.dart';

/// Il rapporto fra l'animale del giorno e quello della persona.
enum RapportoFraAnimali {
  scontro,
  punizione,
  danno,
  armonia,
  triplaArmonia,
  stessoAnimale,
  nessuno,

  /// Serpente e Scimmia: armonia e punizione insieme, detta "armonia che
  /// punisce"; il corpus ha le sue frasi.
  armoniaChePunisce,
}

/// I Dieci Dei del BaZi, nell'ordine della tabella di Yuanhai Ziping.
enum DioDelGiorno {
  compagno('il Compagno'),
  rivale('il Rivale'),
  nutrimento('il Nutrimento'),
  ufficialeFerito('l\'Ufficiale Ferito'),
  ricchezzaIndiretta('la Ricchezza indiretta'),
  ricchezzaDiretta('la Ricchezza diretta'),
  setteUccisioni('le Sette Uccisioni'),
  ufficialeDiretto('l\'Ufficiale diretto'),
  sigilloIndiretto('il Sigillo indiretto'),
  sigilloDiretto('il Sigillo diretto');

  const DioDelGiorno(this.nome);
  final String nome;
}

/// I cinque elementi, dal Legno.
enum Elemento {
  legno('il legno', 'verde-azzurro', [3, 8], 'est'),
  fuoco('il fuoco', 'rosso', [2, 7], 'sud'),
  terra('la terra', 'giallo', [5, 10], 'centro'),
  metallo('il metallo', 'bianco', [4, 9], 'ovest'),
  acqua('l\'acqua', 'nero', [1, 6], 'nord');

  const Elemento(this.nome, this.colore, this.numeri, this.direzione);
  final String nome;

  /// Il colore della tradizione (Liji, Yueling). Il legno ha il qing, che
  /// comprende il verde e l'azzurro.
  final String colore;

  /// I numeri dello He Tu.
  final List<int> numeri;
  final String direzione;
}

/// **L'ALMANACCO CINESE DEL GIORNO, ordine ES voce 08.**
///
/// Tutto calcolato sul telefono, senza modello, dalle regole dell'almanacco
/// (Tong Shu) e del BaZi, verificate in `docs/collaudo/ES/cinese.txt`:
/// - **il pilastro del giorno**, tronco e ramo, dal ciclo dei sessanta che
///   gira senza interruzioni: tronco = (JDN + 9) mod 10, ramo = (JDN + 1)
///   mod 12, sulla data civile del luogo (40.543 giorni su 40.543 uguali a
///   `lunar_python`, 1950-2060);
/// - **il guardiano del giorno** (Jian Chu): (ramo del giorno - ramo del mese
///   solare) mod 12, col mese solare dai jie all'ora di Pechino
///   ([ITerminiSolari]); il giorno del jie ripete il guardiano del giorno
///   prima, e la formula lo fa da se';
/// - **il rapporto** fra il ramo del giorno e il ramo dell'anno di nascita
///   (Sanming Tonghui, Wuxing Dayi), con la precedenza scontro, punizione,
///   danno, armonia, tripla armonia, stesso animale, nessuno;
/// - **i Dieci Dei** dal tronco del giorno di nascita contro quello di oggi
///   (Yuanhai Ziping), per elemento e polarita' (100 coppie su 100);
/// - **l'elemento del giorno**, dal tronco, col suo colore e i suoi numeri;
///   la direzione del Dio della Gioia e del Dio della Ricchezza.
abstract final class LAlmanaccoCinese {
  static const List<String> guardiani = [
    'Stabilire',
    'Togliere',
    'Pieno',
    'Livellare',
    'Fissare',
    'Tenere',
    'Rompere',
    'Pericolo',
    'Compiere',
    'Raccogliere',
    'Aprire',
    'Chiudere',
  ];

  /// Il numero del giorno giuliano della data civile [g].
  static int giornoGiuliano(DateTime g) =>
      DateTime.utc(g.year, g.month, g.day).millisecondsSinceEpoch ~/ 86400000 +
      2440588;

  /// Il tronco (0 Jia ... 9 Gui) del giorno civile [g].
  static int tronco(DateTime g) => (giornoGiuliano(g) + 9) % 10;

  /// Il ramo (0 Topo ... 11 Maiale) del giorno civile [g].
  static int ramo(DateTime g) => (giornoGiuliano(g) + 1) % 12;

  /// L'elemento di un tronco: Jia e Yi legno, Bing e Ding fuoco, ...
  static Elemento elementoDelTronco(int t) => Elemento.values[t ~/ 2];

  /// Il ramo del mese solare del giorno civile [g]: quello aperto
  /// dall'ultimo jie la cui data (a Pechino) non supera [g]. Null fuori
  /// dalla tabella (1900-2100).
  static int? ramoDelMese(DateTime g) {
    final lo = indiceDelJie(g);
    return lo == null ? null : (ITerminiSolari.ramoDelPrimo + lo) % 12;
  }

  /// Quale jie della tabella apre il mese solare del giorno civile [g]:
  /// l'ultimo la cui data non supera [g]. Null prima del primo.
  static int? indiceDelJie(DateTime g) {
    final chiave = g.year * 10000 + g.month * 100 + g.day;
    const date = ITerminiSolari.date;
    if (chiave < date.first) return null;
    var lo = 0;
    var hi = date.length - 1;
    while (lo < hi) {
      final mid = (lo + hi + 1) ~/ 2;
      if (date[mid] <= chiave) {
        lo = mid;
      } else {
        hi = mid - 1;
      }
    }
    return lo;
  }

  /// Il guardiano (0 Stabilire ... 11 Chiudere) del giorno civile [g].
  static int? guardiano(DateTime g) {
    final mese = ramoDelMese(g);
    if (mese == null) return null;
    return (ramo(g) - mese) % 12;
  }

  static const List<(int, int)> _armonie = [
    (0, 1), (2, 11), (3, 10), (4, 9), (5, 8), (6, 7), //
  ];
  static const List<List<int>> _terne = [
    [8, 0, 4], [11, 3, 7], [2, 6, 10], [5, 9, 1], //
  ];
  static const List<(int, int)> _punizioni = [
    (2, 5), (5, 8), (8, 2), (1, 10), (10, 7), (7, 1), (0, 3), (3, 0), //
  ];
  static const Set<int> _punisconoSeStessi = {4, 6, 9, 11};
  static const List<(int, int)> _danni = [
    (0, 7), (1, 6), (2, 5), (3, 4), (8, 11), (9, 10), //
  ];

  static bool _coppia(List<(int, int)> elenco, int a, int b) =>
      elenco.any((c) => (c.$1 == a && c.$2 == b) || (c.$1 == b && c.$2 == a));

  /// Il rapporto fra l'animale di nascita [nascita] e quello del giorno
  /// [giorno], per precedenza.
  static RapportoFraAnimali rapporto(int nascita, int giorno) {
    if (_coppia(const [(5, 8)], nascita, giorno)) {
      return RapportoFraAnimali.armoniaChePunisce;
    }
    if ((nascita - giorno).abs() == 6) return RapportoFraAnimali.scontro;
    if (_coppia(_punizioni, nascita, giorno) ||
        (nascita == giorno && _punisconoSeStessi.contains(nascita))) {
      return RapportoFraAnimali.punizione;
    }
    if (_coppia(_danni, nascita, giorno)) return RapportoFraAnimali.danno;
    if (_coppia(_armonie, nascita, giorno)) return RapportoFraAnimali.armonia;
    if (nascita != giorno &&
        _terne.any((t) => t.contains(nascita) && t.contains(giorno))) {
      return RapportoFraAnimali.triplaArmonia;
    }
    if (nascita == giorno) return RapportoFraAnimali.stessoAnimale;
    return RapportoFraAnimali.nessuno;
  }

  /// L'elemento della terna di un ramo (per la tripla armonia).
  static Elemento elementoDellaTerna(int r) => switch (r) {
        8 || 0 || 4 => Elemento.acqua,
        11 || 3 || 7 => Elemento.legno,
        2 || 6 || 10 => Elemento.fuoco,
        _ => Elemento.metallo,
      };

  /// Il Dio del tronco di oggi [oggi] per il signore del giorno [signore].
  static DioDelGiorno dio(int signore, int oggi) {
    final e1 = signore ~/ 2;
    final e2 = oggi ~/ 2;
    final stessa = signore % 2 == oggi % 2;
    // Il ciclo che genera: legno, fuoco, terra, metallo, acqua.
    if (e1 == e2) return stessa ? DioDelGiorno.compagno : DioDelGiorno.rivale;
    if ((e1 + 1) % 5 == e2) {
      return stessa ? DioDelGiorno.nutrimento : DioDelGiorno.ufficialeFerito;
    }
    if ((e1 + 2) % 5 == e2) {
      return stessa
          ? DioDelGiorno.ricchezzaIndiretta
          : DioDelGiorno.ricchezzaDiretta;
    }
    if ((e2 + 2) % 5 == e1) {
      return stessa
          ? DioDelGiorno.setteUccisioni
          : DioDelGiorno.ufficialeDiretto;
    }
    return stessa ? DioDelGiorno.sigilloIndiretto : DioDelGiorno.sigilloDiretto;
  }

  /// La direzione del Dio della Gioia per il tronco del giorno.
  static const List<String> dioDellaGioia = [
    'nord-est', 'nord-ovest', 'sud-ovest', 'sud', 'sud-est', //
    'nord-est', 'nord-ovest', 'sud-ovest', 'sud', 'sud-est',
  ];

  /// La direzione del Dio della Ricchezza per il tronco del giorno.
  static const List<String> dioDellaRicchezza = [
    'nord-est', 'nord-est', 'sud-ovest', 'sud-ovest', 'nord', //
    'nord', 'est', 'est', 'sud', 'sud',
  ];
}
