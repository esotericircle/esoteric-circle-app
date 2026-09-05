import 'effemeridi.dart';
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

  /// Longitudine eclittica del Sole in gradi [0, 360).
  ///
  /// **La firma resta, il calcolo no.** Qui stava la seconda copia della
  /// formula del Sole, gemella di quella di `Celestial`: due scritture a mano
  /// dello stesso numero, che prima o poi divergono. Ora la risposta viene da
  /// `Effemeridi`, la porta sola. La formula e' la stessa, quindi i valori non
  /// si sono mossi.
  static double sunEclipticLongitude(DateTime date) =>
      Effemeridi.longitudineEclittica(
          CorpoCeleste.sole, MoonPhase.julianDay(date));

  /// Segno in cui si trova il Sole adesso (tropicale, Ariete a 0 gradi).
  static Zodiac sunSign(DateTime date) =>
      _signOfLongitude(sunEclipticLongitude(date));

  /// Longitudine eclittica della Luna in gradi [0, 360).
  ///
  /// **La firma resta, il calcolo no.** Questa era la piu' ricca delle tre
  /// serie lunari che convivevano, e ha vinto: `Effemeridi` la usa, piu' il
  /// termine da 0,214 gradi che solo `Celestial.moonEquatorial` aveva.
  static double moonEclipticLongitude(DateTime date) =>
      Effemeridi.longitudineEclittica(
          CorpoCeleste.luna, MoonPhase.julianDay(date));

  /// Segno in cui si trova la Luna in una certa data (tropicale).
  static Zodiac moonSign(DateTime date) =>
      _signOfLongitude(moonEclipticLongitude(date));

  /// Le costellazioni dello zodiaco alte in quel momento, la piu' alta prima.
  ///
  /// Il punto opposto al Sole (longitudine + 180) culmina a MEZZANOTTE: la sua
  /// costellazione e' la piu' alta a quell'ora. Da li' in poi la volta ruota
  /// con la Terra, quindici gradi ogni ora, quindi il punto che culmina
  /// avanza di altrettanto. Ne restituisce [count], centrate sul culminante.
  ///
  /// Senza il termine orario questa funzione dava la stessa identica volta a
  /// tutte le ore dello stesso giorno: chi nasceva alle sette del mattino e
  /// chi nasceva alle sette di sera vedevano il medesimo cielo, che e' falso.
  /// L'ora di nascita e' il dato che l'onboarding chiede con piu' cura, e va
  /// usata.
  ///
  /// Resta l'approssimazione dichiarata di tutto questo file: la longitudine
  /// eclittica sta al posto dell'ascensione retta, quindi la rotazione e'
  /// giusta nell'ordine di grandezza, non al grado. Le posizioni esatte
  /// arrivano dal motore a effemeridi.
  static List<Zodiac> constellationsHighTonight(DateTime date,
      {int count = 3}) {
    final opposition = _norm360(sunEclipticLongitude(date) + 180.0);
    final oreDaMezzanotte =
        date.hour + date.minute / 60.0 + date.second / 3600.0;
    final culminante = _norm360(opposition + 15.0 * oreDaMezzanotte);
    final center = (culminante / 30).floor() % 12;
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

  static double _norm360(double deg) {
    final r = deg % 360.0;
    return r < 0 ? r + 360.0 : r;
  }

  static const Map<Zodiac, String> _lore = {
    Zodiac.aries:
        'Ariete, il primo balzo dello zodiaco, poche stelle e molto slancio.',
    Zodiac.taurus: "Toro, la V delle Iadi e l'occhio rosso di Aldebaran.",
    Zodiac.gemini: 'Gemelli, i fratelli Castore e Polluce, fianco a fianco.',
    Zodiac.cancer: 'Cancro, discreto, custodisce l\'alveare del Presepe.',
    Zodiac.leo: 'Leone, la falce del cuore, con Regolo a battere il tempo.',
    Zodiac.virgo: 'Vergine, distesa e ampia, con Spica che brilla bassa.',
    Zodiac.libra: 'Bilancia, l\'equilibrio del cielo, tra Vergine e Scorpione.',
    Zodiac.scorpio:
        'Scorpione, il gancio della coda e il rosso Antares nel petto.',
    Zodiac.sagittarius:
        'Sagittario, la teiera che versa verso il cuore della galassia.',
    Zodiac.capricorn: 'Capricorno, il capro marino, un triangolo sommesso.',
    Zodiac.aquarius: 'Acquario, l\'acqua che scorre, stelle tenui e pazienti.',
    Zodiac.pisces: 'Pesci, il lungo cordone che lega i due pesci del cielo.',
  };
}
