import 'horoscope.dart';

/// Un mese dell'anno della persona, coi giorni favorevoli di ogni dominio.
class MeseDellAnno {
  const MeseDellAnno({
    required this.da,
    required this.a,
    this.favorevoli,
    this.livelli,
  });

  /// Il primo giorno del mese, compreso.
  final DateTime da;

  /// Il primo giorno del mese dopo, escluso.
  final DateTime a;

  /// I giorni favorevoli (livello 4 o 5 nella scheda del Giorno di quel
  /// giorno), uno per dominio nell'ordine di [HoroscopeDomain.values].
  /// Nell'Occidentale.
  final List<int>? favorevoli;

  /// Il livello del mese (2-5) per dominio, quando la tradizione legge il
  /// mese col suo pilastro (la Cinese) o col transito del mese (la Vedica).
  final List<int>? livelli;

  /// I giorni del mese.
  int get giorni => DateTime.utc(a.year, a.month, a.day)
      .difference(DateTime.utc(da.year, da.month, da.day))
      .inDays;

  /// Quanto e' favorevole il mese nel dominio [d], da 0 a 1: la parte dei
  /// giorni favorevoli, o il livello del mese su cinque.
  double quota(HoroscopeDomain d) =>
      livelli != null ? livelli![d.index] / 5 : favorevoli![d.index] / giorni;

  /// Il gradino del colore (1-5) nel dominio [d].
  int gradino(HoroscopeDomain d) =>
      livelli != null ? livelli![d.index] : IDodiciMesi.gradino(quota(d));
}

/// **I DODICI MESI DELL'ANNO**, il fondatore il 1 ottobre 2026: *"Hai messo
/// infografica anche per oroscopo annuale? Magari per i 12 mesi indicando i
/// migliori o quello che ritieni migliore."*
///
/// Ogni mese dell'anno della persona (dal ritorno del Sole, dal compleanno o
/// dal Capodanno lunare, secondo la tradizione) si misura coi giorni
/// favorevoli che ha, cioe' i giorni in cui la scheda del Giorno di quel
/// giorno ha il livello 4 o 5, con la stessa regola del Giorno, della
/// Settimana e del Mese: l'anno resta coerente col giorno per giorno. La
/// media dei livelli e' stata scartata perche' in un mese si appiattisce
/// intorno al 3 e le dodici barre sarebbero uguali, il difetto che il
/// fondatore aveva visto sulla Settimana.
class IDodiciMesi {
  const IDodiciMesi._();

  static final Map<String, List<MeseDellAnno>> _memo = {};

  /// Il giorno [giorno] del mese [mese] (anche oltre dodici), fermato
  /// all'ultimo giorno del mese: chi comincia l'anno il 31 ha il 30 aprile.
  static DateTime _stessoGiorno(int anno, int mese, int giorno) {
    final ultimo = DateTime(anno, mese + 1, 0).day;
    return DateTime(anno, mese, giorno > ultimo ? ultimo : giorno);
  }

  /// I dodici mesi dell'anno che comincia il giorno [inizio], coi livelli dei
  /// giorni dati da [livelli]. [chiave] dice di chi e' l'anno e in quale
  /// tradizione: due chiamate con la stessa chiave e lo stesso inizio non
  /// rifanno il conto.
  static List<MeseDellAnno> di({
    required String chiave,
    required DateTime inizio,
    required List<int> Function(DateTime giorno) livelli,
  }) {
    final memo = '$chiave|${inizio.year}-${inizio.month}-${inizio.day}';
    final gia = _memo[memo];
    if (gia != null) return gia;
    final mesi = <MeseDellAnno>[];
    for (var i = 0; i < 12; i++) {
      final da = _stessoGiorno(inizio.year, inizio.month + i, inizio.day);
      final a = _stessoGiorno(inizio.year, inizio.month + i + 1, inizio.day);
      final favorevoli = List<int>.filled(HoroscopeDomain.values.length, 0);
      for (var g = da;
          g.isBefore(a);
          g = DateTime(g.year, g.month, g.day + 1)) {
        final l = livelli(g);
        for (var d = 0; d < favorevoli.length; d++) {
          if (l[d] >= 4) favorevoli[d]++;
        }
      }
      mesi.add(MeseDellAnno(da: da, a: a, favorevoli: favorevoli));
    }
    return _memo[memo] = mesi;
  }

  /// **I MESI DELLA VEDICA E DELLA CINESE**, letti col mese e non coi
  /// giorni: i giorni della Cinese tornano ogni dodici (l'animale del giorno)
  /// e quelli della Vedica ogni ventisette (la Luna), quindi ogni mese ha gli
  /// stessi giorni favorevoli e le dodici barre sarebbero uguali (misurato il
  /// 1 ottobre 2026: da 6 a 9 giorni favorevoli in tutti i mesi cinesi). Il
  /// mese ha la sua lettura nella tradizione: [livelliDelMese] la da' per il
  /// mese che va da `da` ad `a`.
  static List<MeseDellAnno> perLivelli({
    required String chiave,
    required DateTime inizio,
    required List<int> Function(DateTime da, DateTime a) livelliDelMese,
  }) {
    final memo = 'mese|$chiave|${inizio.year}-${inizio.month}-${inizio.day}';
    final gia = _memo[memo];
    if (gia != null) return gia;
    final mesi = <MeseDellAnno>[
      for (var i = 0; i < 12; i++)
        () {
          final da = _stessoGiorno(inizio.year, inizio.month + i, inizio.day);
          final a =
              _stessoGiorno(inizio.year, inizio.month + i + 1, inizio.day);
          return MeseDellAnno(da: da, a: a, livelli: livelliDelMese(da, a));
        }(),
    ];
    return _memo[memo] = mesi;
  }

  /// I tre mesi migliori nel dominio [d], dal migliore; a pari giorni
  /// favorevoli vince il primo.
  static List<MeseDellAnno> migliori(List<MeseDellAnno> mesi, HoroscopeDomain d,
      {int quanti = 3}) {
    final ordinati = [...mesi]..sort((x, y) {
        final c = y.quota(d).compareTo(x.quota(d));
        return c != 0 ? c : x.da.compareTo(y.da);
      });
    return ordinati.take(quanti).toList();
  }

  /// Il gradino del colore (1-5) di una quota di giorni favorevoli.
  static int gradino(double quota) => quota < 0.2
      ? 1
      : quota < 0.35
          ? 2
          : quota < 0.5
              ? 3
              : quota < 0.65
                  ? 4
                  : 5;

  /// Per le prove: dimentica i conti fatti.
  static void dimentica() => _memo.clear();
}
