import '../astro/zodiac.dart';
import 'animal_catalog.dart';

/// La derivazione dell'animale guida dal segno solare, deterministica e fissa
/// per persona.
///
/// Onesta': nella tradizione sciamanica l'animale di potere si TROVA col
/// viaggio, non si calcola dall'astrologia. La nostra derivazione dal cielo e'
/// un ponte di curatela, dichiarato nel pannello "Fonti e metodo". La tabella e'
/// biiettiva sui dodici segni e sui dodici animali del catalogo gia' a bundle,
/// cosi' ogni segno ha il suo totem e ogni totem il suo segno.
class GuideAnimalDerivation {
  const GuideAnimalDerivation._();

  /// La tabella di curatela segno -> animale. Biiettiva: dodici e dodici.
  static const Map<Zodiac, String> _segnoAnimale = {
    Zodiac.aries: 'Falco',
    Zodiac.taurus: 'Orso',
    Zodiac.gemini: 'Volpe',
    Zodiac.cancer: 'Lupo',
    Zodiac.leo: 'Aquila',
    Zodiac.virgo: 'Gufo',
    Zodiac.libra: 'Cervo',
    Zodiac.scorpio: 'Serpente',
    Zodiac.sagittarius: 'Cavallo',
    Zodiac.capricorn: 'Tartaruga',
    Zodiac.aquarius: 'Corvo',
    Zodiac.pisces: 'Lince',
  };

  /// L'animale guida per il segno dato. Funzione pura: stesso segno, stesso
  /// animale, sempre.
  static GuideAnimal forSign(Zodiac segno) {
    final nome = _segnoAnimale[segno]!;
    return AnimalCatalog.animals.firstWhere((a) => a.name == nome);
  }

  /// Il segno da cui nasce un animale, per il rovescio della tabella.
  static Zodiac signOf(String animalName) => _segnoAnimale.entries
      .firstWhere((e) => e.value == animalName)
      .key;
}
