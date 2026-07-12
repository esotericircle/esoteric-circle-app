import 'dart:math' as math;

/// Fase lunare reale calcolata dalla data, senza rete ne' asset.
///
/// Il repo non aveva un motore astronomico condiviso, quindi questa e' una
/// prima versione autosufficiente e deterministica: parte dalla luna nuova di
/// riferimento del 6 gennaio 2000 e dal mese sinodico medio. Basta per animare
/// la Luna del Santuario nella sua fase attuale. Quando arrivera' il motore
/// astronomico completo (giorno giuliano, effemeridi), si sostituisce qui
/// dietro la stessa forma.
class MoonPhase {
  const MoonPhase({
    required this.fraction,
    required this.illumination,
    required this.waxing,
    required this.italianName,
  });

  /// Posizione nel ciclo, da 0 (luna nuova) a 1: 0.5 e' la luna piena.
  final double fraction;

  /// Frazione illuminata del disco, da 0 (nuova) a 1 (piena).
  final double illumination;

  /// Vero in fase crescente, falso in fase calante.
  final bool waxing;

  final String italianName;

  static const double _synodicMonth = 29.530588853;
  static const double _referenceNewMoonJd = 2451550.1;

  /// Giorno giuliano dalla data in UTC.
  static double julianDay(DateTime date) {
    final utc = date.toUtc();
    final dayFraction =
        (utc.hour + utc.minute / 60.0 + utc.second / 3600.0) / 24.0;
    var year = utc.year;
    var month = utc.month;
    if (month <= 2) {
      year -= 1;
      month += 12;
    }
    final a = (year / 100).floor();
    final b = 2 - a + (a / 4).floor();
    return (365.25 * (year + 4716)).floor() +
        (30.6001 * (month + 1)).floor() +
        utc.day +
        b -
        1524.5 +
        dayFraction;
  }

  /// Calcola la fase per una data.
  factory MoonPhase.forDate(DateTime date) {
    final jd = julianDay(date);
    var fraction = (jd - _referenceNewMoonJd) / _synodicMonth;
    fraction -= fraction.floorToDouble(); // normalizza in [0, 1)
    final illumination = (1 - math.cos(2 * math.pi * fraction)) / 2;
    final waxing = fraction < 0.5;
    return MoonPhase(
      fraction: fraction,
      illumination: illumination,
      waxing: waxing,
      italianName: _nameFor(fraction),
    );
  }

  static String _nameFor(double f) {
    const edge = 0.035; // ampiezza dei quarti e delle fasi esatte
    if (f < edge || f > 1 - edge) return 'Luna nuova';
    if ((f - 0.25).abs() < edge) return 'Primo quarto';
    if ((f - 0.5).abs() < edge) return 'Luna piena';
    if ((f - 0.75).abs() < edge) return 'Ultimo quarto';
    if (f < 0.25) return 'Luna crescente';
    if (f < 0.5) return 'Gibbosa crescente';
    if (f < 0.75) return 'Gibbosa calante';
    return 'Luna calante';
  }
}
