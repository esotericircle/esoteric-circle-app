import 'dart:math' as math;

import 'la_luna_intera.dart';
import 'le_tabelle_dei_pianeti.dart';

/// I PIANETI DI MEEUS, Astronomical Algorithms, 2a ed. 1998. Ordine FD voce
/// 02.
///
/// - Capitolo 32: le posizioni eliocentriche dal VSOP87D (eclittica ed
///   equinozio della data), troncato alla soglia dichiarata in
///   `tool/genera_vsop87_di_meeus.py`.
/// - Capitolo 33: la posizione geocentrica apparente, col tempo di luce,
///   l'aberrazione, la correzione al sistema FK5 e la nutazione in
///   longitudine del capitolo 22 (la stessa di [LaLunaIntera]).
/// - Capitolo 37: Plutone, eliocentrico all'equinozio J2000, portato
///   all'equinozio della data con la precessione del capitolo 21 (21.5).
/// - Il Sole e' la Terra vista al contrario, dallo stesso VSOP87D (capitolo
///   25, metodo di alta precisione).
///
/// Tutto in tempo dinamico: chi chiama passa il giorno giuliano delle
/// effemeridi (JDE). La porta che converte dal tempo universale e dichiara
/// l'intervallo verificato e' `IlCieloDiMeeus`.
abstract final class IPianetiDiMeeus {
  static const double _grad = math.pi / 180.0;

  /// Il tempo di luce per unita' astronomica, in giorni (Meeus 33.3).
  static const double _luce = 0.0057755183;

  static double _norm(double gradi) {
    final r = gradi % 360.0;
    return r < 0 ? r + 360.0 : r;
  }

  static double _serie(SerieVsop s, double tau) {
    var totale = 0.0;
    var potenza = 1.0;
    for (final termini in s) {
      var somma = 0.0;
      for (final t in termini) {
        somma += t[0] * math.cos(t[1] + t[2] * tau);
      }
      totale += somma * potenza;
      potenza *= tau;
    }
    return totale / 1e8;
  }

  /// Longitudine e latitudine in radianti, raggio in unita' astronomiche.
  static ({double l, double b, double r}) _vsop(
      SerieVsop l, SerieVsop b, SerieVsop r, double jde) {
    final tau = (jde - 2451545.0) / 365250.0;
    return (l: _serie(l, tau), b: _serie(b, tau), r: _serie(r, tau));
  }

  static ({double l, double b, double r}) _terra(double jde) =>
      _vsop(vsopTerraL, vsopTerraB, vsopTerraR, jde);

  static ({double l, double b, double r}) _eliocentrica(
      String corpo, double jde) {
    return switch (corpo) {
      'mercurio' => _vsop(vsopMercurioL, vsopMercurioB, vsopMercurioR, jde),
      'venere' => _vsop(vsopVenereL, vsopVenereB, vsopVenereR, jde),
      'marte' => _vsop(vsopMarteL, vsopMarteB, vsopMarteR, jde),
      'giove' => _vsop(vsopGioveL, vsopGioveB, vsopGioveR, jde),
      'saturno' => _vsop(vsopSaturnoL, vsopSaturnoB, vsopSaturnoR, jde),
      'urano' => _vsop(vsopUranoL, vsopUranoB, vsopUranoR, jde),
      'nettuno' => _vsop(vsopNettunoL, vsopNettunoB, vsopNettunoR, jde),
      'plutone' => _plutone(jde),
      _ => throw ArgumentError.value(corpo, 'corpo', 'non è un pianeta'),
    };
  }

  /// Plutone, capitolo 37, riportato all'equinozio della data (21.5).
  static ({double l, double b, double r}) _plutone(double jde) {
    final t = (jde - 2451545.0) / 36525.0;
    final j = 34.35 + 3034.9057 * t;
    final s = 50.08 + 1222.1138 * t;
    final p = 238.96 + 144.96 * t;
    var lon = 0.0, lat = 0.0, rag = 0.0;
    for (var n = 0; n < plutoneArgomenti.length; n++) {
      final a = plutoneArgomenti[n];
      final alfa = _norm(a[0] * j + a[1] * s + a[2] * p) * _grad;
      final sa = math.sin(alfa), ca = math.cos(alfa);
      lon += plutoneLongitudine[n][0] * sa + plutoneLongitudine[n][1] * ca;
      lat += plutoneLatitudine[n][0] * sa + plutoneLatitudine[n][1] * ca;
      rag += plutoneRaggio[n][0] * sa + plutoneRaggio[n][1] * ca;
    }
    final l0 = (238.958116 + 144.96 * t + lon / 1e6) * _grad;
    final b0 = (-3.908239 + lat / 1e6) * _grad;
    final r = 40.7241346 + rag / 1e7;
    // Precessione dall'equinozio J2000 a quello della data, Meeus 21.5 con
    // l'epoca di partenza J2000 (T = 0) e t i secoli fino alla data.
    const sec = math.pi / 180.0 / 3600.0;
    final eta = (47.0029 * t - 0.03302 * t * t + 0.000060 * t * t * t) * sec;
    final pi = 174.876384 * _grad - (869.8089 * t - 0.03536 * t * t) * sec;
    final pp = (5029.0966 * t + 1.11113 * t * t - 0.000006 * t * t * t) * sec;
    final a1 = math.cos(eta) * math.cos(b0) * math.sin(pi - l0) -
        math.sin(eta) * math.sin(b0);
    final b1 = math.cos(b0) * math.cos(pi - l0);
    final c1 = math.cos(eta) * math.sin(b0) +
        math.sin(eta) * math.cos(b0) * math.sin(pi - l0);
    return (l: pp + pi - math.atan2(a1, b1), b: math.asin(c1), r: r);
  }

  /// Longitudine eclittica geocentrica apparente di un pianeta, in gradi
  /// [0, 360), all'equinozio vero della data, per il giorno giuliano [jde]
  /// in tempo dinamico. [corpo] e' uno fra mercurio, venere, marte, giove,
  /// saturno, urano, nettuno, plutone.
  static double longitudine(String corpo, double jde) {
    final g = _geocentrica(corpo, jde);
    final terra = g.terra;
    final lambda = g.lambda;
    final beta = g.beta;
    final t = (jde - 2451545.0) / 36525.0;
    // L'aberrazione, Meeus 23.2, col Sole visto dalla Terra.
    final e = 0.016708634 - t * (0.000042037 + t * 0.0000001267);
    final pie = (102.93735 + t * (1.71946 + t * 0.00046)) * _grad;
    final sole = terra.l + math.pi;
    const k = 20.49552; // secondi d'arco
    final aberrazione = k *
        (-math.cos(sole - lambda) + e * math.cos(pie - lambda)) /
        math.cos(beta);
    // La correzione al sistema FK5, Meeus 32.3.
    final lp = lambda - (1.397 * t + 0.00031 * t * t) * _grad;
    final fk5 =
        -0.09033 + 0.03916 * (math.cos(lp) + math.sin(lp)) * math.tan(beta);
    final gradi = lambda / _grad +
        (aberrazione + fk5) / 3600.0 +
        LaLunaIntera.nutazioneInLongitudine(jde);
    return _norm(gradi);
  }

  /// Latitudine eclittica geocentrica di un pianeta, in gradi, per il giorno
  /// giuliano [jde] in tempo dinamico, col tempo di luce (Meeus 33.3) e
  /// senza le correzioni di secondi d'arco (aberrazione e FK5 sulla beta
  /// restano sotto il secondo e mezzo). Ordine FG parte 2: il cielo del Real
  /// Time Cosmo disegna i pianeti dove sono, e con la sola longitudine
  /// Plutone sbaglierebbe fino a diciassette gradi.
  static double latitudine(String corpo, double jde) =>
      _geocentrica(corpo, jde).beta / _grad;

  /// La posizione geocentrica geometrica di un pianeta, col tempo di luce:
  /// la parte comune a [longitudine] e [latitudine].
  static ({
    double lambda,
    double beta,
    ({double l, double b, double r}) terra
  }) _geocentrica(String corpo, double jde) {
    final terra = _terra(jde);
    final ct = math.cos(terra.b);
    final x0 = terra.r * ct * math.cos(terra.l);
    final y0 = terra.r * ct * math.sin(terra.l);
    final z0 = terra.r * math.sin(terra.b);
    var x = 0.0, y = 0.0, z = 0.0;
    var tau = 0.0;
    // Il tempo di luce, iterato (Meeus 33.3): due giri bastano al decimo di
    // secondo d'arco anche per Mercurio.
    for (var giro = 0; giro < 3; giro++) {
      final p = _eliocentrica(corpo, jde - tau);
      final cb = math.cos(p.b);
      x = p.r * cb * math.cos(p.l) - x0;
      y = p.r * cb * math.sin(p.l) - y0;
      z = p.r * math.sin(p.b) - z0;
      tau = _luce * math.sqrt(x * x + y * y + z * z);
    }
    return (
      lambda: math.atan2(y, x),
      beta: math.atan2(z, math.sqrt(x * x + y * y)),
      terra: terra,
    );
  }

  /// Longitudine eclittica geocentrica apparente del Sole, in gradi [0, 360),
  /// all'equinozio vero della data, per il giorno giuliano [jde] in tempo
  /// dinamico: la Terra del VSOP87D vista al contrario, con la correzione al
  /// FK5, la nutazione e l'aberrazione (Meeus 25.9 e 25.10).
  static double sole(double jde) {
    final terra = _terra(jde);
    final t = (jde - 2451545.0) / 36525.0;
    final theta = terra.l / _grad + 180.0;
    final beta = -terra.b;
    final lp = (theta - 1.397 * t - 0.00031 * t * t) * _grad;
    final fk5 =
        -0.09033 + 0.03916 * (math.cos(lp) + math.sin(lp)) * math.tan(beta);
    final aberrazione = -20.4898 / terra.r;
    return _norm(theta +
        (fk5 + aberrazione) / 3600.0 +
        LaLunaIntera.nutazioneInLongitudine(jde));
  }
}
