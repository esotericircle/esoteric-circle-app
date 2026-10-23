import 'dart:math' as math;

import 'il_cielo_di_meeus.dart';

/// **L'ALBA E IL TRAMONTO AL MINUTO, per il Rahu Kalam.** Ordine ES voce 09,
/// 29 settembre 2026.
///
/// Il Rahu Kalam e' un ottavo del giorno di luce: un minuto di errore
/// sull'alba o sul tramonto e' un minuto di errore sui suoi estremi, e Drik
/// Panchang, la fonte che la tradizione consulta, li stampa al minuto. Qui
/// l'alba e il tramonto si calcolano col Sole apparente di Meeus
/// e il tempo siderale apparente (cap. 12 e 22), dalla porta
/// [IlCieloDiMeeus] (ordine FD voce 02), iterando sull'istante finche' il
/// centro del Sole sta a -0,8333 gradi: il bordo superiore con la rifrazione
/// standard, senza quota, la convenzione che Drik dichiara. Dall'ordine FD
/// anche `SunsetTime` passa da qui: la sua formula NOAA, un secondo Sole,
/// e' stata tolta.
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
      final jd = IlCieloDiMeeus.giornoGiuliano(t);
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

  /// Ascensione retta e declinazione apparenti del Sole, in radianti, dalla
  /// porta del cielo: Sole, obliquita' vera e conversione sono quelli di
  /// tutta l'app (ordine FD voce 02).
  static (double, double) _ascensioneEDeclinazione(double jdUt) {
    final e = IlCieloDiMeeus.equatoriali(
        IlCieloDiMeeus.longitudine(CorpoCeleste.sole, jdUt), 0, jdUt);
    return (e.ascensioneRetta * _g, e.declinazione * _g);
  }

  /// Il tempo siderale apparente di Greenwich, in gradi, dalla porta.
  static double _tempoSiderale(double jdUt) =>
      IlCieloDiMeeus.tempoSiderale(jdUt);
}
