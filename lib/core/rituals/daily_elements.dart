import '../maestro/maestro.dart';

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
  ),
  breath(
    title: 'Soffio del Destino',
    shortLabel: 'Soffio',
    anchorHour: 10,
    anchorMinute: 30,
    guide: Maestro.aura,
  ),
  oracle(
    title: 'Oracolo del Giorno',
    shortLabel: 'Oracolo',
    anchorHour: 12,
    anchorMinute: 30,
    guide: Maestro.medora,
  ),
  rune(
    title: 'La Runa del Tramonto',
    shortLabel: 'Tramonto',
    anchorHour: 18,
    anchorMinute: 0,
    guide: Maestro.caligo,
  );

  const DailyElement({
    required this.title,
    required this.shortLabel,
    required this.anchorHour,
    required this.anchorMinute,
    required this.guide,
  });

  final String title;
  final String shortLabel;
  final int anchorHour;
  final int anchorMinute;

  /// La Guida che presta il colore all'elemento. Null per il Rito dell'Alba,
  /// che resta oro.
  final Maestro? guide;

  int get anchorMinutes => anchorHour * 60 + anchorMinute;

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
}
