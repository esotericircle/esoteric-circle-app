import 'package:flutter/foundation.dart';

import '../astro/birth_details.dart';
import '../astro/celestial.dart';
import '../astro/natal_chart.dart';
import '../astro/zodiac.dart';

/// Fatti identitari fissi che nascono dai dati di nascita: la fase della Luna
/// del giorno di nascita (col segno lunare) e il numero della vita.
///
/// E' il modello portato dal branch della Carta Natale (li' si chiamava
/// `BirthIdentity`). Su master-order `BirthIdentity` e' gia' il momento di
/// nascita (data, ora, luogo): per non collidere, qui i fatti identitari
/// prendono il nome piu' esatto di [NatalFacts]. E' un modello riusabile,
/// pensato per stare sia nella carta natale sia nel profilo, e domani nel
/// Cosmic Passport.
@immutable
class NatalFacts {
  const NatalFacts({
    required this.birthDate,
    required this.moonPhase,
    required this.moonPhaseName,
    required this.moonMeaning,
    required this.moonSign,
    required this.lifeNumber,
    required this.lifeTitle,
    required this.lifeMeaning,
  });

  final DateTime birthDate;

  /// Fase reale della Luna del giorno di nascita.
  final MoonIllumination moonPhase;
  final String moonPhaseName;
  final String moonMeaning;

  /// Segno lunare, se noto dalla carta.
  final Zodiac? moonSign;

  /// Numero della vita (1..9, oppure numeri maestri 11, 22, 33).
  final int lifeNumber;
  final String lifeTitle;
  final String lifeMeaning;

  factory NatalFacts.from({
    required BirthDetails details,
    NatalChart? chart,
  }) {
    // Istante di nascita verso UT col tempo medio locale (stessa scelta del
    // cielo reale), cosi' la fase e' coerente. La fase cambia poco in un giorno.
    final local = details.dateTime;
    final offsetMinutes = (details.place.longitude / 15.0 * 60.0).round();
    final utc = DateTime.utc(local.year, local.month, local.day, local.hour,
            local.minute)
        .subtract(Duration(minutes: offsetMinutes));
    final phase = Celestial.moonIllumination(Celestial.julianDay(utc));
    final n = lifePathNumber(details.date);
    return NatalFacts(
      birthDate: details.date,
      moonPhase: phase,
      moonPhaseName: phaseNameOf(phase),
      moonMeaning: phaseMeaningOf(phase),
      moonSign: chart?.moonSign,
      lifeNumber: n,
      lifeTitle: lifeTitleOf(n),
      lifeMeaning: lifeMeaningOf(n),
    );
  }
}

/// Nome della fase lunare in italiano, dalle otto fasi tradizionali.
String phaseNameOf(MoonIllumination m) {
  final f = m.fraction;
  if (f < 0.04) return 'Luna nuova';
  if (f > 0.96) return 'Luna piena';
  if (f >= 0.46 && f <= 0.54) return m.waxing ? 'Primo quarto' : 'Ultimo quarto';
  if (m.waxing) return f < 0.5 ? 'Luna crescente' : 'Gibbosa crescente';
  return f < 0.5 ? 'Luna calante' : 'Gibbosa calante';
}

/// Riga di significato della fase, come tratto identitario (non oroscopo).
String phaseMeaningOf(MoonIllumination m) {
  final f = m.fraction;
  if (f < 0.04) return 'nato al buio della Luna: semi, istinto, nuovi inizi.';
  if (f > 0.96) return 'nato a Luna piena: pienezza, coscienza, culmine.';
  if (f >= 0.46 && f <= 0.54) {
    return m.waxing
        ? 'nato al primo quarto: la volonta\' che agisce e decide.'
        : 'nato all\'ultimo quarto: revisione, taglio, rilascio.';
  }
  if (m.waxing) {
    return f < 0.5
        ? 'Luna crescente: slancio, intenzione, cose che nascono.'
        : 'gibbosa crescente: si affina, si perfeziona, si prepara.';
  }
  return f < 0.5
      ? 'Luna calante: resa, riposo, ritorno al seme.'
      : 'gibbosa calante: gratitudine, raccolto, condivisione.';
}

/// Numero della vita dalla data di nascita, con riduzione numerologica
/// deterministica che conserva i numeri maestri 11, 22 e 33.
int lifePathNumber(DateTime date) {
  final d = _reduce(date.day);
  final m = _reduce(date.month);
  final y = _reduce(date.year);
  return _reduce(d + m + y);
}

int _reduce(int n) {
  var v = n;
  while (v > 9 && v != 11 && v != 22 && v != 33) {
    var s = 0;
    var x = v;
    while (x > 0) {
      s += x % 10;
      x ~/= 10;
    }
    v = s;
  }
  return v;
}

String lifeTitleOf(int n) => switch (n) {
      1 => 'l\'Iniziatore',
      2 => 'il Paciere',
      3 => 'il Creativo',
      4 => 'il Costruttore',
      5 => 'il Libero',
      6 => 'il Custode',
      7 => 'il Cercatore',
      8 => 'il Realizzatore',
      9 => 'il Compassionevole',
      11 => 'il Visionario',
      22 => 'il Costruttore di sogni',
      33 => 'il Maestro del cuore',
      _ => 'il tuo cammino',
    };

String lifeMeaningOf(int n) => switch (n) {
      1 => 'guida, volonta\' e indipendenza: apri le strade.',
      2 => 'sensibilita\', unione e diplomazia: tessi legami.',
      3 => 'espressione, gioia e parola: crei e comunichi.',
      4 => 'ordine, radici e disciplina: costruisci basi solide.',
      5 => 'movimento, cambiamento e sensi: vivi libero.',
      6 => 'amore, cura e responsabilita\': custodisci gli altri.',
      7 => 'introspezione, mistero e sapere: cerchi la verita\'.',
      8 => 'potere, materia e giustizia: realizzi nel mondo.',
      9 => 'dono, compimento e universalita\': doni te stesso.',
      11 => 'intuizione e ispirazione, numero maestro: illumini.',
      22 => 'grandi opere concrete, numero maestro: dai forma ai sogni.',
      33 => 'servizio e guarigione, numero maestro: curi col cuore.',
      _ => 'un filo unico del tuo destino.',
    };

/// Tiene i dati di nascita e la carta, e ne deriva i fatti identitari. Provider
/// condiviso, cosi' carta, profilo e Cosmic Passport leggono la stessa fonte.
///
/// Su master-order la fonte d'origine e' il Risveglio (ProfileController): qui
/// si alimenta con [setBirth] a valle del rito, senza raccogliere nulla due
/// volte.
class BirthIdentityController extends ChangeNotifier {
  BirthDetails? _details;
  NatalChart? _chart;
  NatalFacts? _facts;

  BirthDetails? get details => _details;
  NatalChart? get chart => _chart;
  NatalFacts? get facts => _facts;
  bool get hasBirth => _details != null;

  void setBirth(BirthDetails details, NatalChart? chart) {
    _details = details;
    _chart = chart;
    _facts = NatalFacts.from(details: details, chart: chart);
    notifyListeners();
  }

  void clear() {
    _details = null;
    _chart = null;
    _facts = null;
    notifyListeners();
  }
}
