/// I quattro elementi tradizionali.
enum ZodiacElement { fire, earth, air, water }

/// I dodici segni e le dodici costellazioni dello zodiaco.
///
/// E' un concetto di dominio, indipendente dal disegno: la forma astronomica
/// stilizzata vive nel design system (`zodiac_figures.dart`). Qui restano id,
/// nome italiano, simbolo, elemento e l'intervallo di date del segno solare.
enum Zodiac {
  aries(id: 'aries', italianName: 'Ariete', symbol: '♈', element: ZodiacElement.fire, from: (3, 21), to: (4, 19)),
  taurus(id: 'taurus', italianName: 'Toro', symbol: '♉', element: ZodiacElement.earth, from: (4, 20), to: (5, 20)),
  gemini(id: 'gemini', italianName: 'Gemelli', symbol: '♊', element: ZodiacElement.air, from: (5, 21), to: (6, 20)),
  cancer(id: 'cancer', italianName: 'Cancro', symbol: '♋', element: ZodiacElement.water, from: (6, 21), to: (7, 22)),
  leo(id: 'leo', italianName: 'Leone', symbol: '♌', element: ZodiacElement.fire, from: (7, 23), to: (8, 22)),
  virgo(id: 'virgo', italianName: 'Vergine', symbol: '♍', element: ZodiacElement.earth, from: (8, 23), to: (9, 22)),
  libra(id: 'libra', italianName: 'Bilancia', symbol: '♎', element: ZodiacElement.air, from: (9, 23), to: (10, 22)),
  scorpio(id: 'scorpio', italianName: 'Scorpione', symbol: '♏', element: ZodiacElement.water, from: (10, 23), to: (11, 21)),
  sagittarius(id: 'sagittarius', italianName: 'Sagittario', symbol: '♐', element: ZodiacElement.fire, from: (11, 22), to: (12, 21)),
  capricorn(id: 'capricorn', italianName: 'Capricorno', symbol: '♑', element: ZodiacElement.earth, from: (12, 22), to: (1, 19)),
  aquarius(id: 'aquarius', italianName: 'Acquario', symbol: '♒', element: ZodiacElement.air, from: (1, 20), to: (2, 18)),
  pisces(id: 'pisces', italianName: 'Pesci', symbol: '♓', element: ZodiacElement.water, from: (2, 19), to: (3, 20));

  const Zodiac({
    required this.id,
    required this.italianName,
    required this.symbol,
    required this.element,
    required this.from,
    required this.to,
  });

  final String id;
  final String italianName;
  final String symbol;
  final ZodiacElement element;

  /// Intervallo di date del segno solare, come (mese, giorno).
  final (int, int) from;
  final (int, int) to;

  static Zodiac? fromId(String? id) {
    for (final z in Zodiac.values) {
      if (z.id == id) return z;
    }
    return null;
  }

  /// Segno solare per una data di nascita (zodiaco tropicale).
  ///
  /// E' un calcolo deterministico locale: il segno solare dipende solo dalla
  /// data, quindi resta disponibile anche quando l'API astrologica non lo e'.
  static Zodiac fromDate(DateTime date) {
    final m = date.month;
    final d = date.day;
    for (final z in Zodiac.values) {
      final (fromMonth, fromDay) = z.from;
      final (toMonth, toDay) = z.to;
      final afterStart = m == fromMonth && d >= fromDay;
      final beforeEnd = m == toMonth && d <= toDay;
      // Vale anche per il Capricorno che attraversa l'anno (dic -> gen).
      if (afterStart || beforeEnd) return z;
    }
    return Zodiac.capricorn;
  }
}
