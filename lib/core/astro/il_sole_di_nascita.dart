import 'dart:math' as math;

import 'la_luna_intera.dart';

/// **IL SOLE DI NASCITA, FUORI DAL MOTORE DEI TRANSITI.** Ordine ES voce
/// 11, 29 settembre 2026.
///
/// Il decano egizio si calcola dal Sole di nascita, e le nascite stanno anche
/// nel secolo scorso. `Effemeridi` e' il motore dei transiti, verificato dal
/// 2020 al 2030, e la guardia `il_motore_locale_e_per_oggi` vieta giustamente
/// di usarlo per una nascita. Qui c'e' il Sole di Meeus, *Astronomical
/// Algorithms*, 2a ed., capitolo 25 (longitudine apparente: centro, nutazione
/// e aberrazione), in tempo delle effemeridi col Delta T di [LaLunaIntera],
/// **misurato** contro il JPL DE440s su quaranta istanti fra il 1900 e il
/// 2100 (`docs/collaudo/ES/riferimenti_sole.csv`, prova
/// `la_luna_intera_test.dart`).
abstract final class IlSoleDiNascita {
  static const double _grad = math.pi / 180.0;

  /// Longitudine eclittica geocentrica apparente del Sole, in gradi [0, 360),
  /// per il giorno giuliano [jdUt] in tempo universale.
  static double longitudine(double jdUt) {
    final anno = 2000 + (jdUt - 2451545.0) / 365.25;
    final jde = jdUt + LaLunaIntera.deltaT(anno) / 86400.0;
    final t = (jde - 2451545.0) / 36525.0;
    final l0 = 280.46646 + 36000.76983 * t + 0.0003032 * t * t;
    final m = (357.52911 + 35999.05029 * t - 0.0001537 * t * t) * _grad;
    final c = (1.914602 - 0.004817 * t - 0.000014 * t * t) * math.sin(m) +
        (0.019993 - 0.000101 * t) * math.sin(2 * m) +
        0.000289 * math.sin(3 * m);
    final vera = l0 + c;
    final omega = (125.04 - 1934.136 * t) * _grad;
    final apparente = vera - 0.00569 - 0.00478 * math.sin(omega);
    final v = apparente % 360.0;
    return v < 0 ? v + 360.0 : v;
  }
}
