import '../astro/moon_phase.dart';
import '../astro/night_sky.dart';
import '../astro/zodiac.dart';

/// Fase lunare di nascita: la fase e il segno lunare del giorno di nascita.
///
/// Riusa il motore reale gia' presente: la fase da `MoonPhase.forDate` e il
/// segno da `NightSky.moonSign` (longitudine eclittica della Luna, formula
/// reale a bassa precisione). Deterministico, senza rete ne' asset. L'ora
/// precisa affinera' il segno quando ci sara' il dato reale di nascita.
class BirthMoon {
  const BirthMoon({required this.phase, required this.sign, required this.meaning});

  final MoonPhase phase;
  final Zodiac sign;

  /// Una riga di significato: la Luna del temperamento emotivo, nel segno.
  final String meaning;

  /// Etichetta compatta: fase piu' segno, per esempio "Gibbosa crescente in
  /// Bilancia".
  String get label => '${phase.italianName} in ${sign.italianName}';

  factory BirthMoon.forDate(DateTime date) {
    final phase = MoonPhase.forDate(date);
    final sign = NightSky.moonSign(date);
    return BirthMoon(
      phase: phase,
      sign: sign,
      meaning: _meanings[sign]!,
    );
  }

  /// Il significato del segno lunare, per chi ha gia' il segno e non la data.
  /// Stesso corpus di [meaning], esposto per riusarlo senza ricalcolare la fase:
  /// lo usa il Rito del Sogno per fondare il messaggio sul sentire del segno.
  static String meaningFor(Zodiac sign) => _meanings[sign]!;

  // Il segno lunare parla del sentire, non della volonta' del Sole: una riga
  // per ciascuno, nella voce di Medora.
  static const Map<Zodiac, String> _meanings = {
    Zodiac.aries: 'Senti d\'impulso e con ardore: le emozioni arrivano come lampi.',
    Zodiac.taurus: 'Senti con calma e costanza: cerchi conforto stabile e concreto.',
    Zodiac.gemini: 'Senti con curiosità e parole: le emozioni si fanno racconto.',
    Zodiac.cancer: 'Senti in profondità e proteggi: la Luna qui è a casa sua.',
    Zodiac.leo: 'Senti con calore e generosità: il cuore chiede di brillare.',
    Zodiac.virgo: 'Senti prendendoti cura dei dettagli: ami servendo con precisione.',
    Zodiac.libra: 'Senti cercando armonia: la relazione è il tuo specchio.',
    Zodiac.scorpio: 'Senti con intensità e verità: le emozioni scavano a fondo.',
    Zodiac.sagittarius: 'Senti con slancio e fiducia: cerchi orizzonti e significato.',
    Zodiac.capricorn: 'Senti con misura e responsabilità: proteggi ciò che dura.',
    Zodiac.aquarius: 'Senti con libertà e ampiezza: il cuore abbraccia tutti.',
    Zodiac.pisces: 'Senti con empatia e sogno: confini morbidi, immaginazione viva.',
  };
}
