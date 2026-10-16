/// **I GIORNI CHE LA PERSONA NOMINA NELLA DOMANDA.** Ordine EX Aggiunta 4,
/// voce EX.07, 2 ottobre 2026.
///
/// Al banco della qualita' (giro fine4) le domande sul cielo di un altro
/// giorno (*"Com'è il cielo domani?"*, *"Il 15 novembre è un buon giorno per
/// firmare un contratto?"*, *"In che segno sarà Giove il primo gennaio
/// 2028?"*) costavano una chiamata in piu' ciascuna: il modello chiedeva il
/// cielo alla funzione, l'app lo calcolava, e solo dopo lui rispondeva. Il
/// giorno pero' sta gia' scritto nella domanda: qui si legge, e il cielo di
/// quel giorno arriva al modello insieme alla domanda, come quello di oggi
/// dall'ordine EX voce 08. La funzione resta per i giorni che questa lettura
/// non riconosce.
///
/// Si riconoscono: *domani*, *dopodomani*, *ieri*, i giorni della settimana
/// (il prossimo; oggi stesso non conta, il suo cielo c'e' gia'), *"il 15
/// novembre"*, *"il primo gennaio 2028"*, *"15/11/2026"*. Un giorno e un mese
/// senza anno sono il prossimo: *"il 20 luglio"* detto a ottobre e' quello
/// dell'anno dopo.
abstract final class IGiorniNominati {
  /// Al massimo tanti giorni per domanda: oltre, il blocco peserebbe piu'
  /// della chiamata che risparmia.
  static const int alMassimo = 3;

  static const List<String> _mesi = [
    'gennaio', 'febbraio', 'marzo', 'aprile', 'maggio', 'giugno', //
    'luglio', 'agosto', 'settembre', 'ottobre', 'novembre', 'dicembre'
  ];

  static const List<String> _giorniDellaSettimana = [
    'lunedì', 'martedì', 'mercoledì', 'giovedì', 'venerdì', 'sabato', //
    'domenica'
  ];

  static final RegExp _dataConIlMese = RegExp(
      r'(?<!\p{L})(primo|1º|\d{1,2})\s+(' +
          _mesi.join('|') +
          r')(?:\s+(?:del\s+)?(\d{4}))?(?!\p{L})',
      caseSensitive: false,
      unicode: true);

  static final RegExp _dataInCifre = RegExp(
      r'(?<!\d)(\d{1,2})[/.-](\d{1,2})[/.-](\d{4})(?!\d)',
      unicode: true);

  static final RegExp _relativo = RegExp(
      r"(?<!\p{L})(dopodomani|domani|l['’]altro ieri|altroieri|ieri)(?!\p{L})",
      caseSensitive: false,
      unicode: true);

  static final RegExp _settimana = RegExp(
      '(?<!\\p{L})(${_giorniDellaSettimana.join('|')}|'
      'lunedi|martedi|mercoledi|giovedi|venerdi)(?!\\p{L})',
      caseSensitive: false,
      unicode: true);

  /// I giorni nominati in [testo], diversi da [oggi], nell'ordine in cui
  /// compaiono e senza doppioni; al massimo [alMassimo].
  static List<DateTime> in_(String testo, DateTime oggi) {
    final base = DateTime(oggi.year, oggi.month, oggi.day);
    final trovati = <(int, DateTime)>[];

    for (final m in _dataConIlMese.allMatches(testo)) {
      final g = m.group(1)!.toLowerCase();
      final giorno = g == 'primo' || g == '1º' ? 1 : int.parse(g);
      final mese = _mesi.indexOf(m.group(2)!.toLowerCase()) + 1;
      final anno = m.group(3);
      var d = _valida(anno == null ? base.year : int.parse(anno), mese, giorno);
      if (d == null) continue;
      if (anno == null && d.isBefore(base)) {
        d = _valida(base.year + 1, mese, giorno);
        if (d == null) continue;
      }
      trovati.add((m.start, d));
    }
    for (final m in _dataInCifre.allMatches(testo)) {
      final d = _valida(int.parse(m.group(3)!), int.parse(m.group(2)!),
          int.parse(m.group(1)!));
      if (d != null) trovati.add((m.start, d));
    }
    for (final m in _relativo.allMatches(testo)) {
      final parola = m.group(1)!.toLowerCase();
      final scarto = switch (parola) {
        'dopodomani' => 2,
        'domani' => 1,
        'ieri' => -1,
        _ => -2,
      };
      trovati
          .add((m.start, DateTime(base.year, base.month, base.day + scarto)));
    }
    for (final m in _settimana.allMatches(testo)) {
      final parola = m.group(1)!.toLowerCase();
      var indice = _giorniDellaSettimana.indexOf(parola);
      if (indice < 0) {
        indice = _giorniDellaSettimana.indexWhere((g) =>
            g.substring(0, g.length - 1) ==
            parola.substring(0, parola.length - 1));
      }
      if (indice < 0) continue;
      final avanti = (indice + 1 - base.weekday) % 7;
      if (avanti == 0) continue;
      trovati
          .add((m.start, DateTime(base.year, base.month, base.day + avanti)));
    }

    trovati.sort((a, b) => a.$1.compareTo(b.$1));
    final giorni = <DateTime>[];
    for (final (_, d) in trovati) {
      if (d == base || giorni.contains(d)) continue;
      giorni.add(d);
      if (giorni.length == alMassimo) break;
    }
    return giorni;
  }

  /// Il giorno, se esiste davvero: il 31 aprile no.
  static DateTime? _valida(int anno, int mese, int giorno) {
    if (mese < 1 || mese > 12 || giorno < 1 || giorno > 31) return null;
    final d = DateTime(anno, mese, giorno);
    return d.month == mese && d.day == giorno ? d : null;
  }
}
