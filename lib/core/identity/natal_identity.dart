import 'package:flutter/foundation.dart';

import '../astro/birth_details.dart';
import 'birth_identity.dart';
import '../astro/celestial.dart';
import '../astro/natal_chart.dart';
import '../astro/zodiac.dart';
import '../astro/moon_phase.dart';

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
    //
    // Senza luogo si resta sul tempo universale, cioe' scarto zero. Non e' un
    // luogo inventato: e' l'assenza di correzione locale, e sulla sola fase
    // lunare pesa meno di un'ora di Luna, che a occhio non si distingue. Quel
    // che il luogo determina davvero, Ascendente e case, qui non si calcola.
    final local = details.dateTime;
    final offsetMinutes =
        ((details.place?.longitude ?? 0) / 15.0 * 60.0).round();
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
///
/// **Delega, non ricalcola.** Qui viveva una SECONDA nomenclatura, con soglie
/// sulla frazione illuminata invece che sulla posizione nel ciclo: coerente in
/// se', diversa dall'altra. La stessa Luna poteva quindi prendere due nomi a
/// seconda di chi la chiedeva, e nessuno dei due era sbagliato in modo evidente,
/// che e' il tipo di difetto peggiore da trovare.
///
/// Ora la nomenclatura sta in un punto solo, `MoonPhase.nomeItaliano`, che
/// lavora sulla posizione nel ciclo e non sulla luce: la luce da sola non
/// distingue una crescente da una calante.
String phaseNameOf(MoonIllumination m) =>
    MoonPhase.nomeItaliano(m.elongationDeg / 360.0);

/// Riga di significato della fase, come tratto identitario (non oroscopo).
String phaseMeaningOf(MoonIllumination m) {
  final f = m.fraction;
  if (f < 0.04) return 'nato al buio della Luna: semi, istinto, nuovi inizi.';
  if (f > 0.96) return 'nato a Luna piena: pienezza, coscienza, culmine.';
  if (f >= 0.46 && f <= 0.54) {
    return m.waxing
        ? 'nato al primo quarto: la volontà che agisce e decide.'
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
      1 => 'guida, volontà e indipendenza: apri le strade.',
      2 => 'sensibilità, unione e diplomazia: tessi legami.',
      3 => 'espressione, gioia e parola: crei e comunichi.',
      4 => 'ordine, radici e disciplina: costruisci basi solide.',
      5 => 'movimento, cambiamento e sensi: vivi libero.',
      6 => 'amore, cura e responsabilità: custodisci gli altri.',
      7 => 'introspezione, mistero e sapere: cerchi la verità.',
      8 => 'potere, materia e giustizia: realizzi nel mondo.',
      9 => 'dono, compimento e universalità: doni te stesso.',
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

  /// RIPRENDE I DATI DI NASCITA DAL PROFILO, che e' l'unico posto dove sono
  /// persistiti.
  ///
  /// **Perche' esiste.** `setBirth` era chiamato in UN SOLO punto di tutto il
  /// progetto, alla fine del Risveglio, e questo controller vive solo in
  /// memoria: chi riapriva l'app lo trovava vuoto. Da li' l'app diceva "Senza
  /// l'ora di nascita l'Ascendente e le Case restano velati" a chi l'ora
  /// l'aveva data eccome, e la carta natale partiva senza luogo, che il client
  /// rifiuta prima ancora di chiamare la rete. Un'unica causa per due difetti
  /// che sembravano distinti: l'ora persa e il cielo sempre in ripiego.
  ///
  /// L'ora e il luogo NON si perdevano nell'archivio: l'archivio li scrive e li
  /// rilegge. Si perdevano qui, in un secondo posto dove la stessa verita' viveva
  /// senza essere persistita.
  void riprendiDa(BirthIdentity identita) {
    if (identita.isExample) return;
    final gia = _details;
    final nuovi = identita.toBirthDetails();
    // Idempotente: chiamarlo a ogni cambio del profilo non deve rifare niente
    // se i dati sono gli stessi, altrimenti si notifica in cerchio.
    if (gia != null &&
        gia.date == nuovi.date &&
        gia.time == nuovi.time &&
        gia.place?.latitude == nuovi.place?.latitude &&
        gia.place?.longitude == nuovi.place?.longitude) {
      return;
    }
    setBirth(nuovi, _chart);
  }

  void clear() {
    _details = null;
    _chart = null;
    _facts = null;
    notifyListeners();
  }
}
