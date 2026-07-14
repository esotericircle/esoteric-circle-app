import '../maestro/maestro.dart';
import 'daily_rituals.dart';

/// I quattro elementi giornalieri del Santuario, con l'ora della loro fascia e
/// la Guida che ne porta il colore.
///
/// Il Rito dell'Alba non ha una Guida fissa (ruota di giorno in giorno) e il suo
/// accento resta l'oro; gli altri tre seguono la loro Guida: Soffio del Destino
/// verde di Aura, Oracolo del Giorno blu di Medora, Runa del Tramonto rosso di
/// Caligo.
enum DailyElement {
  dawn(
    title: 'Rito dell\'Alba',
    shortLabel: 'Alba',
    anchorHour: 7,
    anchorMinute: 0,
    guide: null,
    description:
        'Apre la giornata con una parola guida e l\'energia dell\'alba, '
        'per orientare le tue prossime ore.',
  ),
  breath(
    title: 'Soffio del Destino',
    shortLabel: 'Soffio',
    anchorHour: 10,
    anchorMinute: 30,
    guide: Maestro.aura,
    description:
        'Un respiro guidato che allinea il tuo destino del momento e '
        'scioglie la tensione.',
  ),
  oracle(
    title: 'Oracolo del Giorno',
    shortLabel: 'Oracolo',
    anchorHour: 12,
    anchorMinute: 30,
    guide: Maestro.medora,
    description:
        'Il responso centrale del giorno, che illumina la domanda che porti '
        'con te.',
  ),
  rune(
    title: 'La Runa del Tramonto',
    shortLabel: 'Tramonto',
    anchorHour: 18,
    anchorMinute: 0,
    guide: Maestro.caligo,
    description:
        'La runa della sera che raccoglie e custodisce quello che il giorno '
        'ti ha lasciato.',
  );

  const DailyElement({
    required this.title,
    required this.shortLabel,
    required this.anchorHour,
    required this.anchorMinute,
    required this.guide,
    required this.description,
  });

  final String title;
  final String shortLabel;
  final int anchorHour;
  final int anchorMinute;

  /// Il Maestro che presta il colore all'elemento. Null per il Rito dell'Alba,
  /// che resta oro e ruota di giorno in giorno.
  final Maestro? guide;

  /// La spiegazione breve dell'elemento, cosa e' e a cosa serve, per il popup
  /// informativo della striscia.
  final String description;

  int get anchorMinutes => anchorHour * 60 + anchorMinute;

  /// L'orario di apertura della fascia, nel formato h:mm (ad esempio 7:00,
  /// 10:30). Serve al riquadro orario nella striscia del giorno.
  String get clockLabel =>
      '$anchorHour:${anchorMinute.toString().padLeft(2, '0')}';

  /// L'id stabile per il deep-link da notifica push.
  String get id => name;

  static DailyElement? fromId(String? id) {
    for (final e in values) {
      if (e.name == id) return e;
    }
    return null;
  }
}

/// La selezione deterministica dell'elemento della fascia oraria attiva.
class DailyElements {
  const DailyElements._();

  /// L'elemento "corrente", scelto dalla fascia oraria attiva sull'ora locale.
  /// La fascia va da un'ancora alla successiva; prima dell'alba resta la Runa
  /// della sera precedente, cosi' la notte appartiene a Caligo.
  static DailyElement current(DateTime now) {
    final minutes = now.hour * 60 + now.minute;
    if (minutes < DailyElement.dawn.anchorMinutes) return DailyElement.rune;
    if (minutes < DailyElement.breath.anchorMinutes) return DailyElement.dawn;
    if (minutes < DailyElement.oracle.anchorMinutes) return DailyElement.breath;
    if (minutes < DailyElement.rune.anchorMinutes) return DailyElement.oracle;
    return DailyElement.rune;
  }

  /// Il Maestro attivo di un elemento: per il Rito dell'Alba, che ruota, e' il
  /// Maestro di turno del giorno; per gli altri tre e' la loro Guida fissa,
  /// Soffio ad Aura, Oracolo a Medora, Runa a Caligo.
  static Maestro maestroFor(DailyElement element, DateTime now) =>
      element.guide ?? DailyRituals.dawnMaestro(now);
}
