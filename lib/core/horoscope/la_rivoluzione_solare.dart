import 'dart:math' as math;

import '../astro/effemeridi.dart';
import '../astro/il_cielo_del_jpl.dart';
import '../astro/il_sole_di_nascita.dart';
import '../astro/la_luna_intera.dart';
import '../astro/il_segno_del_cielo.dart';

/// Il tema della Rivoluzione Solare di un anno.
class TemaDellaRivoluzione {
  const TemaDellaRivoluzione({
    required this.istante,
    required this.ascendente,
    required this.medioCielo,
    required this.longitudini,
  });

  /// L'istante, in UTC, in cui il Sole torna alla longitudine della nascita.
  final DateTime istante;

  /// Ascendente e Medio Cielo del luogo, in gradi eclittici.
  final double ascendente;
  final double medioCielo;

  /// Le longitudini dei corpi della lettura, in gradi.
  final Map<CorpoCeleste, double> longitudini;

  /// Il segno (0 Ariete ... 11 Pesci) di una longitudine.

  int get segnoDellAscendente =>
      IlSegnoDelCielo.dellaLongitudine(ascendente).index;
  int get segnoDelMedioCielo =>
      IlSegnoDelCielo.dellaLongitudine(medioCielo).index;

  /// **LA CASA, a case equali dall'Ascendente**: la prima casa sono i trenta
  /// gradi che seguono l'Ascendente. E' una scelta dell'app, dichiarata nella
  /// nota del metodo: si calcola sul telefono, senza tavole delle case. Il
  /// settore di trenta gradi contato dall'Ascendente e' la stessa aritmetica
  /// del segno, e passa dalla stessa porta (ordine FC voce 10).
  int casaDi(CorpoCeleste c) =>
      IlSegnoDelCielo.dellaLongitudine(longitudini[c]! - ascendente).index + 1;
}

/// **LA RIVOLUZIONE SOLARE, ordine ES voce 04.**
///
/// L'annuale dal compleanno: il tema dell'istante in cui il Sole torna al
/// grado che aveva alla nascita, nel luogo in cui la persona si trova. Tutto
/// sul telefono.
///
/// **Il Sole viene dal JPL** ([IlCieloDelJpl], 1900-2050): un centesimo di
/// grado sul Sole sono quattordici minuti sull'istante del ritorno, e
/// l'Ascendente si muove di un grado ogni quattro minuti. Col Sole di Meeus
/// l'istante sbagliava fino a 638 secondi e l'Ascendente fino a 2,7 gradi
/// (`la_rivoluzione_solare_test.dart`). Anche Venere, Giove e Saturno vengono
/// dal JPL; la Luna da [LaLunaIntera]. Ascendente e Medio Cielo col tempo
/// siderale apparente e l'obliquita' vera.
abstract final class LaRivoluzioneSolare {
  static const double _g = math.pi / 180.0;

  static double _jd(DateTime utc) => LaLunaIntera.giornoGiuliano(utc);

  /// Il Sole apparente: dal JPL, o da Meeus fuori dal 1900-2050.
  static double sole(double jd) =>
      IlCieloDelJpl.longitudine(CorpoCeleste.sole, jd) ??
      IlSoleDiNascita.longitudine(jd);

  /// L'istante del ritorno del Sole alla longitudine [soleNatale] nell'anno
  /// [anno], cercato attorno al compleanno [giorno]/[mese].
  static DateTime ritorno(double soleNatale, int anno, int mese, int giorno) {
    var t = DateTime.utc(anno, mese, giorno, 12);
    for (var i = 0; i < 12; i++) {
      var d = soleNatale - sole(_jd(t));
      d = (d + 540) % 360 - 180;
      // Il Sole fa circa 0,9856 gradi al giorno.
      final passo = d / 0.985647;
      t = t.add(Duration(microseconds: (passo * 86400e6).round()));
      if (passo.abs() * 86400 < 0.1) break;
    }
    return t;
  }

  /// La longitudine del Sole alla nascita, dall'istante [nascitaUtc].
  static double soleNatale(DateTime nascitaUtc) => sole(_jd(nascitaUtc));

  /// **L'ANNO CHE CORRE**: la Rivoluzione dell'ultimo compleanno non oltre
  /// [adesso]. Prima del compleanno di quest'anno vale quella dell'anno prima.
  static DateTime ritornoInCorso(DateTime nascitaUtc, DateTime adesso) {
    final s = soleNatale(nascitaUtc);
    final quest = ritorno(s, adesso.year, nascitaUtc.month, nascitaUtc.day);
    if (!quest.isAfter(adesso.toUtc())) return quest;
    return ritorno(s, adesso.year - 1, nascitaUtc.month, nascitaUtc.day);
  }

  /// Il prossimo compleanno solare, dopo [adesso].
  static DateTime prossimoRitorno(DateTime nascitaUtc, DateTime adesso) {
    final s = soleNatale(nascitaUtc);
    final quest = ritorno(s, adesso.year, nascitaUtc.month, nascitaUtc.day);
    if (quest.isAfter(adesso.toUtc())) return quest;
    return ritorno(s, adesso.year + 1, nascitaUtc.month, nascitaUtc.day);
  }

  /// Il tema all'istante [istante] nel luogo [lat], [lon] (est positiva).
  static TemaDellaRivoluzione tema(DateTime istante, double lat, double lon) {
    final jd = _jd(istante.toUtc());
    final t = (jd - 2451545.0) / 36525.0;
    final anno = 2000 + (jd - 2451545.0) / 365.25;
    final jde = jd + LaLunaIntera.deltaT(anno) / 86400.0;
    final te = (jde - 2451545.0) / 36525.0;
    // Obliquita' media (Meeus 22.2) piu' la nutazione in obliquita' (22.A,
    // i due termini maggiori).
    final omega = (125.04452 - 1934.136261 * te) * _g;
    final lSole = (280.4665 + 36000.7698 * te) * _g;
    final media = 23.4392911 -
        (46.8150 * te + 0.00059 * te * te - 0.001813 * te * te * te) / 3600;
    final deps = (9.20 * math.cos(omega) + 0.57 * math.cos(2 * lSole)) / 3600;
    final eps = (media + deps) * _g;
    // Tempo siderale apparente (Meeus 12.4 piu' l'equazione degli equinozi).
    final gmst = 280.46061837 +
        360.98564736629 * (jd - 2451545.0) +
        0.000387933 * t * t -
        t * t * t / 38710000.0;
    final gast =
        gmst + LaLunaIntera.nutazioneInLongitudine(jde) * math.cos(eps);
    final ramc = ((gast + lon) % 360) * _g;
    final phi = lat * _g;
    var asc = math.atan2(math.cos(ramc),
            -math.sin(ramc) * math.cos(eps) - math.tan(phi) * math.sin(eps)) /
        _g;
    asc = (asc % 360 + 360) % 360;
    var mc = math.atan2(math.sin(ramc), math.cos(ramc) * math.cos(eps)) / _g;
    mc = (mc % 360 + 360) % 360;
    double corpo(CorpoCeleste c) =>
        IlCieloDelJpl.longitudine(c, jd) ??
        Effemeridi.longitudineEclittica(c, jd);
    return TemaDellaRivoluzione(
      istante: istante.toUtc(),
      ascendente: asc,
      medioCielo: mc,
      longitudini: {
        CorpoCeleste.sole: sole(jd),
        CorpoCeleste.luna: LaLunaIntera.longitudine(jd),
        CorpoCeleste.venere: corpo(CorpoCeleste.venere),
        CorpoCeleste.giove: corpo(CorpoCeleste.giove),
        CorpoCeleste.saturno: corpo(CorpoCeleste.saturno),
      },
    );
  }
}
