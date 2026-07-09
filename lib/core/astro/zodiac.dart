/// I dodici segni e le dodici costellazioni dello zodiaco.
///
/// E' un concetto di dominio, indipendente dal disegno: la forma astronomica
/// stilizzata vive nel design system (`zodiac_figures.dart`). Qui restano id,
/// nome italiano e simbolo.
enum Zodiac {
  aries(id: 'aries', italianName: 'Ariete', symbol: '♈'),
  taurus(id: 'taurus', italianName: 'Toro', symbol: '♉'),
  gemini(id: 'gemini', italianName: 'Gemelli', symbol: '♊'),
  cancer(id: 'cancer', italianName: 'Cancro', symbol: '♋'),
  leo(id: 'leo', italianName: 'Leone', symbol: '♌'),
  virgo(id: 'virgo', italianName: 'Vergine', symbol: '♍'),
  libra(id: 'libra', italianName: 'Bilancia', symbol: '♎'),
  scorpio(id: 'scorpio', italianName: 'Scorpione', symbol: '♏'),
  sagittarius(id: 'sagittarius', italianName: 'Sagittario', symbol: '♐'),
  capricorn(id: 'capricorn', italianName: 'Capricorno', symbol: '♑'),
  aquarius(id: 'aquarius', italianName: 'Acquario', symbol: '♒'),
  pisces(id: 'pisces', italianName: 'Pesci', symbol: '♓');

  const Zodiac({
    required this.id,
    required this.italianName,
    required this.symbol,
  });

  final String id;
  final String italianName;
  final String symbol;

  static Zodiac? fromId(String? id) {
    for (final z in Zodiac.values) {
      if (z.id == id) return z;
    }
    return null;
  }
}
