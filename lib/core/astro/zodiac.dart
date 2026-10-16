/// I quattro elementi tradizionali.
enum ZodiacElement { fire, earth, air, water }

/// I dodici segni e le dodici costellazioni dello zodiaco.
///
/// E' un concetto di dominio, indipendente dal disegno: la forma astronomica
/// stilizzata vive nel design system (`zodiac_figures.dart`). Qui restano id,
/// nome italiano, simbolo ed elemento. **Nessuna data**: il segno di una
/// data lo dice solo `IlSegnoDelCielo` (ordine FC voce 10), dalla
/// posizione reale del Sole, perche' una tabella di date fisse sbaglia le
/// cuspidi.
enum Zodiac {
  aries(
      id: 'aries',
      italianName: 'Ariete',
      symbol: '♈',
      element: ZodiacElement.fire),
  taurus(
      id: 'taurus',
      italianName: 'Toro',
      symbol: '♉',
      element: ZodiacElement.earth),
  gemini(
      id: 'gemini',
      italianName: 'Gemelli',
      symbol: '♊',
      element: ZodiacElement.air),
  cancer(
      id: 'cancer',
      italianName: 'Cancro',
      symbol: '♋',
      element: ZodiacElement.water),
  leo(
      id: 'leo',
      italianName: 'Leone',
      symbol: '♌',
      element: ZodiacElement.fire),
  virgo(
      id: 'virgo',
      italianName: 'Vergine',
      symbol: '♍',
      element: ZodiacElement.earth),
  libra(
      id: 'libra',
      italianName: 'Bilancia',
      symbol: '♎',
      element: ZodiacElement.air),
  scorpio(
      id: 'scorpio',
      italianName: 'Scorpione',
      symbol: '♏',
      element: ZodiacElement.water),
  sagittarius(
      id: 'sagittarius',
      italianName: 'Sagittario',
      symbol: '♐',
      element: ZodiacElement.fire),
  capricorn(
      id: 'capricorn',
      italianName: 'Capricorno',
      symbol: '♑',
      element: ZodiacElement.earth),
  aquarius(
      id: 'aquarius',
      italianName: 'Acquario',
      symbol: '♒',
      element: ZodiacElement.air),
  pisces(
      id: 'pisces',
      italianName: 'Pesci',
      symbol: '♓',
      element: ZodiacElement.water);

  const Zodiac({
    required this.id,
    required this.italianName,
    required this.symbol,
    required this.element,
  });

  final String id;
  final String italianName;
  final String symbol;
  final ZodiacElement element;

  static Zodiac? fromId(String? id) {
    for (final z in Zodiac.values) {
      if (z.id == id) return z;
    }
    return null;
  }
}
