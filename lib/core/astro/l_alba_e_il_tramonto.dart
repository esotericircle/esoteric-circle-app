import 'dart:math' as math;

import 'il_sole_di_nascita.dart';
import 'la_luna_intera.dart';

/// **L'ALBA E IL TRAMONTO AL MINUTO, per il Rahu Kalam.** Ordine ES voce 09,
/// 29 settembre 2026.
///
/// Il Rahu Kalam e' un ottavo del giorno di luce: un minuto di errore
/// sull'alba o sul tramonto e' un minuto di errore sui suoi estremi, e Drik
/// Panchang, la fonte che la tradizione consulta, li stampa al minuto. Qui
/// l'alba e il tramonto si calcolano col Sole apparente di Meeus
/// ([IlSoleDiNascita], cap. 25) e il tempo siderale apparente (cap. 12 e
/// 22), iterando sull'istante finche' il centro del Sole sta a -0,8333 gradi:
/// il bordo superiore con la rifrazione standard, senza quota, la convenzione
/// che Drik dichiara. `SunsetTime` resta com'e' per chi lo usa: la sua
/// formula semplificata basta a un'ora del giorno, non al minuto.
abstract final class LAlbaEIlTramonto {
  static const double _g = math.pi / 180.0;

  /// Altezza del centro del Sole all'alba e al tramonto, in gradi.
  static const double altezza = -0.8333;

  /// L'alba e il tramonto del giorno civile [giorno] alla latitudine [lat] e
  /// longitudine [lon] (est positiva), in UTC. Null dove il Sole quel giorno
  /// non sorge o non tramonta. [offset] e' lo scarto del fuso del luogo quel
  /// giorno: ancora il calcolo al mezzogiorno locale.
  static ({DateTime alba, DateTime tramonto})? delGiorno(
    DateTime giorno, {
    required double lat,
    required double lon,
    required Duration offset,
  }) {
    final mezzogiorno = DateTime.utc(giorno.year, giorno.month, giorno.day, 12)
        .subtract(offset);
    final alba = _estremo(mezzogiorno, lat, lon, sorge: true);
    final tramonto = _estremo(mezzogiorno, lat, lon, sorge: false);
    if (alba == null || tramonto == null) return null;
    return (alba: alba, tramonto: tramonto);
  }

  static DateTime? _estremo(DateTime mezzogiorno, double lat, double lon,
      {required bool sorge}) {
    var t = mezzogiorno.add(Duration(hours: sorge ? -6 : 6));
    for (var i = 0; i < 8; i++) {
      final jd = LaLunaIntera.giornoGiuliano(t);
      final (alfa, delta) = _ascensioneEDeclinazione(jd);
      final cosH0 =
          (math.sin(altezza * _g) - math.sin(lat * _g) * math.sin(delta)) /
              (math.cos(lat * _g) * math.cos(delta));
      if (cosH0 < -1 || cosH0 > 1) return null;
      final h0 = math.acos(cosH0) / _g;
      // L'angolo orario del Sole adesso, fra -180 e 180.
      var h = _tempoSiderale(jd) + lon - alfa / _g;
      h = (h + 540) % 360 - 180;
      final voluto = sorge ? -h0 : h0;
      // Il Sole avanza di 360,9856 gradi di angolo orario al giorno.
      final passo = (voluto - h) / 360.985647;
      t = t.add(Duration(microseconds: (passo * 86400e6).round()));
      if (passo.abs() * 86400 < 0.5) break;
    }
    return t;
  }

  /// Ascensione retta e declinazione apparenti del Sole, in radianti.
  static (double, double) _ascensioneEDeclinazione(double jdUt) {
    final lambda = IlSoleDiNascita.longitudine(jdUt) * _g;
    final anno = 2000 + (jdUt - 2451545.0) / 365.25;
    final jde = jdUt + LaLunaIntera.deltaT(anno) / 86400.0;
    final t = (jde - 2451545.0) / 36525.0;
    final omega = (125.04 - 1934.136 * t) * _g;
    // L'obliquita' vera, per la posizione apparente (Meeus 25.8).
    final eps = (23.4392911 - 0.0130042 * t + 0.00256 * math.cos(omega)) * _g;
    final alfa = math.atan2(math.cos(eps) * math.sin(lambda), math.cos(lambda));
    final delta = math.asin(math.sin(eps) * math.sin(lambda));
    return (alfa < 0 ? alfa + 2 * math.pi : alfa, delta);
  }

  /// Il tempo siderale apparente di Greenwich, in gradi (Meeus 12.4 con la
  /// nutazione in ascensione retta).
  static double _tempoSiderale(double jdUt) {
    final t = (jdUt - 2451545.0) / 36525.0;
    final medio = 280.46061837 +
        360.98564736629 * (jdUt - 2451545.0) +
        0.000387933 * t * t -
        t * t * t / 38710000.0;
    final anno = 2000 + (jdUt - 2451545.0) / 365.25;
    final jde = jdUt + LaLunaIntera.deltaT(anno) / 86400.0;
    final nut = LaLunaIntera.nutazioneInLongitudine(jde);
    final eps = (23.4392911 - 0.0130042 * t) * _g;
    return (medio + nut * math.cos(eps)) % 360.0;
  }
}
