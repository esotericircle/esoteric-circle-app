import 'dart:math' as math;

import 'moon_phase.dart';
import 'zodiac.dart';

/// Cielo del momento, ancorato all'ora di adesso invece che alla nascita.
///
/// Nel repo non c'e' ancora un motore a effemeridi con il catalogo J2000 e le
/// coordinate equatoriali reali: quello, con la posizione dell'osservatore,
/// arrivera' dopo (vedi la relazione). Qui si usa comunque astronomia vera per
/// cio' che non dipende dal luogo: la longitudine eclittica del Sole dalla
/// data, e quindi quali costellazioni dello zodiaco stanno all'opposizione,
/// cioe' culminano a mezzanotte e sono "alte stanotte". Le figure sono gli
/// asterismi stilizzati ma fedeli gia' presenti (`zodiac_figures.dart`), la
/// Luna e' nella fase reale del momento.
class NightSky {
  const NightSky._();

  /// Longitudine eclittica del Sole in gradi [0, 360), formula a bassa
  /// precisione ma reale (errore inferiore al grado), sufficiente a sapere in
  /// quale segno si trova il Sole e quali costellazioni gli stanno di fronte.
  static double sunEclipticLongitude(DateTime date) {
    final n = MoonPhase.julianDay(date) - 2451545.0; // giorni da J2000.0
    final l = 280.460 + 0.9856474 * n; // longitudine media
    final g = _rad(357.528 + 0.9856003 * n); // anomalia media
    final lambda = l + 1.915 * math.sin(g) + 0.020 * math.sin(2 * g);
    return _norm360(lambda);
  }

  /// Segno in cui si trova il Sole adesso (tropicale, Ariete a 0 gradi).
  static Zodiac sunSign(DateTime date) =>
      _signOfLongitude(sunEclipticLongitude(date));

  /// Longitudine eclittica della Luna in gradi [0, 360). Formula a bassa
  /// precisione ma reale (termini periodici principali, errore sotto il grado),
  /// sufficiente a sapere in quale segno si trova la Luna in una certa data.
  static double moonEclipticLongitude(DateTime date) {
    final d = MoonPhase.julianDay(date) - 2451545.0; // giorni da J2000.0
    final lp = 218.316 + 13.176396 * d; // longitudine media della Luna
    final m = _rad(134.963 + 13.064993 * d); // anomalia media della Luna
    final ms = _rad(357.529 + 0.985600 * d); // anomalia media del Sole
    final dd = _rad(297.850 + 12.190749 * d); // elongazione media
    final lambda = lp +
        6.289 * math.sin(m) -
        1.274 * math.sin(m - 2 * dd) +
        0.658 * math.sin(2 * dd) -
        0.186 * math.sin(ms) -
        0.059 * math.sin(2 * m - 2 * dd) +
        0.053 * math.sin(m + 2 * dd) +
        0.046 * math.sin(2 * dd - ms) +
        0.041 * math.sin(m - ms) -
        0.035 * math.sin(dd) -
        0.031 * math.sin(m + ms);
    return _norm360(lambda);
  }

  /// Segno in cui si trova la Luna in una certa data (tropicale).
  static Zodiac moonSign(DateTime date) =>
      _signOfLongitude(moonEclipticLongitude(date));

  /// Le costellazioni dello zodiaco alte stanotte, la piu' prominente per prima.
  ///
  /// Il punto opposto al Sole (longitudine + 180) culmina a mezzanotte: la sua
  /// costellazione e' la piu' alta, le due adiacenti sorgono la sera e verso
  /// l'alba. Ne restituisce [count], centrate sull'opposizione.
  static List<Zodiac> constellationsHighTonight(DateTime date, {int count = 3}) {
    final opposition = _norm360(sunEclipticLongitude(date) + 180.0);
    final center = (opposition / 30).floor() % 12; // indice del segno opposto
    final order = <int>[0]; // centro
    for (var d = 1; order.length < count; d++) {
      order.add(d); // vicino a est
      if (order.length < count) order.add(-d); // vicino a ovest
    }
    return [
      for (final off in order.take(count))
        Zodiac.values[(center + off) % 12 < 0
            ? (center + off) % 12 + 12
            : (center + off) % 12],
    ];
  }

  /// Riga breve, nella voce di Medora, su cosa e' una costellazione. Fedele
  /// all'asterismo reale, poche parole.
  static String describe(Zodiac sign) => _lore[sign]!;

  /// Riga breve sulla Luna, dalla sua fase reale, nella voce di Medora.
  ///
  /// La stessa riga serve due cieli, quello di stasera e quello della notte in
  /// cui la persona e' nata, che sono due tempi diversi: con [birth] vero la
  /// frase guarda indietro. Senza questa distinzione la nascita veniva
  /// raccontata al presente, con uno "stanotte" che parlava di decenni fa.
  static String describeMoon(MoonPhase moon, {bool birth = false}) {
    if (moon.italianName == 'Luna nuova') {
      return 'Luna nuova, il cielo trattiene il fiato: tempo di intenzioni.';
    }
    if (moon.italianName == 'Luna piena') {
      return 'Luna piena, la luce si versa intera: guarda cosa illumina.';
    }
    final verso = moon.waxing ? 'cresce e semina' : 'cala e lascia andare';
    final quando = birth ? 'quella notte' : 'stanotte';
    return '${moon.italianName}, la luce $verso $quando.';
  }

  static Zodiac _signOfLongitude(double deg) =>
      Zodiac.values[(deg / 30).floor() % 12];

  static double _rad(double deg) => deg * math.pi / 180.0;

  static double _norm360(double deg) {
    final r = deg % 360.0;
    return r < 0 ? r + 360.0 : r;
  }

  static const Map<Zodiac, String> _lore = {
    Zodiac.aries: 'Ariete, il primo balzo dello zodiaco, poche stelle e molto slancio.',
    Zodiac.taurus: "Toro, la V delle Iadi e l'occhio rosso di Aldebaran.",
    Zodiac.gemini: 'Gemelli, i fratelli Castore e Polluce, fianco a fianco.',
    Zodiac.cancer: 'Cancro, discreto, custodisce l\'alveare del Presepe.',
    Zodiac.leo: 'Leone, la falce del cuore, con Regolo a battere il tempo.',
    Zodiac.virgo: 'Vergine, distesa e ampia, con Spica che brilla bassa.',
    Zodiac.libra: 'Bilancia, l\'equilibrio del cielo, tra Vergine e Scorpione.',
    Zodiac.scorpio: 'Scorpione, il gancio della coda e il rosso Antares nel petto.',
    Zodiac.sagittarius: 'Sagittario, la teiera che versa verso il cuore della galassia.',
    Zodiac.capricorn: 'Capricorno, il capro marino, un triangolo sommesso.',
    Zodiac.aquarius: 'Acquario, l\'acqua che scorre, stelle tenui e pazienti.',
    Zodiac.pisces: 'Pesci, il lungo cordone che lega i due pesci del cielo.',
  };
}
