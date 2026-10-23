/// LA DECLINAZIONE MAGNETICA, ordine FG parte 2 (voce 2.9).
///
/// La bussola del telefono indica il nord magnetico; il cielo e' calcolato sul
/// nord vero. La differenza, la declinazione, cambia col luogo (in Italia fra
/// due e cinque gradi est, a Vancouver sedici est, in Patagonia dieci ovest) e
/// col tempo. Qui la si calcola col World Magnetic Model 2025 della NOAA NCEI e
/// del British Geological Survey, sviluppo in armoniche sferiche fino al grado
/// dodici, coefficienti in `coefficienti_wmm2025.dart` (generati da
/// `tool/i_coefficienti_del_wmm.py`). Materiale del governo degli Stati Uniti,
/// non soggetto a protezione del diritto d'autore (17 U.S.C. 403).
///
/// L'algoritmo e' la traduzione del programma di riferimento della NOAA
/// (geomag, versione C del WMM). Si prova contro i valori di prova ufficiali
/// del modello, `WMM2025_TestValues.txt`, in
/// `test/real_time_cosmo_la_declinazione_magnetica_test.dart`.
///
/// **Il modello vale dal 2025,0 al 2030,0.** Fuori da quell'intervallo
/// [declinazioneMagnetica] usa l'anno piu' vicino dentro e lo DICHIARA in
/// [DeclinazioneMagnetica.ripiego]: e' un ripiego, e chi mostra il cielo lo
/// deve sapere (regola R9).
library;

import 'dart:math' as math;

import 'coefficienti_wmm2025.dart';

/// La declinazione in gradi (positiva a est) e se e' stata calcolata fuori
/// dall'intervallo del modello.
class DeclinazioneMagnetica {
  const DeclinazioneMagnetica(this.gradi, {this.ripiego = false});
  final double gradi;

  /// Vero quando l'anno chiesto stava fuori dal 2025,0-2030,0 e si e' usato
  /// il bordo piu' vicino: il valore e' plausibile, non garantito.
  final bool ripiego;
}

const double kPrimoAnnoWmm = 2025.0;
const double kUltimoAnnoWmm = 2030.0;

const int _ordine = 12;

class _Tabelle {
  _Tabelle() {
    for (final r in kCoefficientiWmm) {
      final n = r[0].toInt(), m = r[1].toInt();
      c[m][n] = r[2];
      cd[m][n] = r[4];
      if (m != 0) {
        c[n][m - 1] = r[3];
        cd[n][m - 1] = r[5];
      }
    }
    // La normalizzazione di Schmidt, una volta sola.
    final snorm = List<double>.filled(13 * 13, 0);
    snorm[0] = 1;
    for (var n = 1; n <= _ordine; n++) {
      snorm[n] = snorm[n - 1] * (2 * n - 1) / n;
      var j = 2.0;
      for (var m = 0; m <= n; m++) {
        k[m][n] = ((n - 1) * (n - 1) - m * m) / ((2 * n - 1) * (2 * n - 3));
        if (m > 0) {
          final flnmj = ((n - m + 1) * j) / (n + m);
          snorm[n + m * 13] = snorm[n + (m - 1) * 13] * math.sqrt(flnmj);
          j = 1;
          c[n][m - 1] = snorm[n + m * 13] * c[n][m - 1];
          cd[n][m - 1] = snorm[n + m * 13] * cd[n][m - 1];
        }
        c[m][n] = snorm[n + m * 13] * c[m][n];
        cd[m][n] = snorm[n + m * 13] * cd[m][n];
      }
    }
  }

  final c = List.generate(13, (_) => List<double>.filled(13, 0));
  final cd = List.generate(13, (_) => List<double>.filled(13, 0));
  final k = List.generate(13, (_) => List<double>.filled(13, 0));
}

final _Tabelle _tabelle = _Tabelle();

/// La declinazione magnetica in gradi, positiva a est, alla latitudine e
/// longitudine geodetiche date (gradi), all'altezza in chilometri sul
/// livello del mare, nell'anno decimale [anno].
DeclinazioneMagnetica declinazioneMagnetica({
  required double latitudine,
  required double longitudine,
  required double anno,
  double altezzaKm = 0,
}) {
  final fuori = anno < kPrimoAnnoWmm || anno > kUltimoAnnoWmm;
  final a0 = anno.clamp(kPrimoAnnoWmm, kUltimoAnnoWmm);
  final t = _tabelle;
  const a = 6378.137, b = 6356.7523142, re = 6371.2;
  const a2 = a * a, b2 = b * b, c2 = a2 - b2;
  const a4 = a2 * a2, b4 = b2 * b2, c4 = a4 - b4;
  final dt = a0 - kEpocaWmm;
  final rlat = latitudine * math.pi / 180;
  final rlon = longitudine * math.pi / 180;
  final srlon = math.sin(rlon), crlon = math.cos(rlon);
  final srlat = math.sin(rlat), crlat = math.cos(rlat);
  final srlat2 = srlat * srlat, crlat2 = crlat * crlat;
  final alt = altezzaKm;

  // Da geodetiche a sferiche.
  final q = math.sqrt(a2 - c2 * srlat2);
  final q1 = alt * q;
  final q2 = math.pow((q1 + a2) / (q1 + b2), 2).toDouble();
  final ct = srlat / math.sqrt(q2 * crlat2 + srlat2);
  final st = math.sqrt(1 - ct * ct);
  final r2 = alt * alt + 2 * q1 + (a4 - c4 * srlat2) / (q * q);
  final r = math.sqrt(r2);
  final d = math.sqrt(a2 * crlat2 + b2 * srlat2);
  final ca = (alt + d) / r;
  final sa = c2 * crlat * srlat / (r * d);

  final sp = List<double>.filled(13, 0);
  final cp = List<double>.filled(13, 0);
  cp[0] = 1;
  sp[1] = srlon;
  cp[1] = crlon;
  for (var m = 2; m <= _ordine; m++) {
    sp[m] = sp[1] * cp[m - 1] + cp[1] * sp[m - 1];
    cp[m] = cp[1] * cp[m - 1] - sp[1] * sp[m - 1];
  }

  final p = List.generate(13, (_) => List<double>.filled(13, 0));
  final dp = List.generate(13, (_) => List<double>.filled(13, 0));
  final pp = List<double>.filled(13, 0);
  final tc = List.generate(13, (_) => List<double>.filled(13, 0));
  p[0][0] = 1;
  pp[0] = 1;

  final aor = re / r;
  var ar = aor * aor;
  var br = 0.0, bt = 0.0, bp = 0.0, bpp = 0.0;
  for (var n = 1; n <= _ordine; n++) {
    ar *= aor;
    for (var m = 0; m <= n; m++) {
      if (n == m) {
        p[m][n] = st * p[m - 1][n - 1];
        dp[m][n] = st * dp[m - 1][n - 1] + ct * p[m - 1][n - 1];
      } else if (n == 1 && m == 0) {
        p[m][n] = ct * p[m][n - 1];
        dp[m][n] = ct * dp[m][n - 1] - st * p[m][n - 1];
      } else if (n > 1 && n != m) {
        if (m > n - 2) {
          p[m][n - 2] = 0;
          dp[m][n - 2] = 0;
        }
        p[m][n] = ct * p[m][n - 1] - t.k[m][n] * p[m][n - 2];
        dp[m][n] =
            ct * dp[m][n - 1] - st * p[m][n - 1] - t.k[m][n] * dp[m][n - 2];
      }
      tc[m][n] = t.c[m][n] + dt * t.cd[m][n];
      if (m != 0) tc[n][m - 1] = t.c[n][m - 1] + dt * t.cd[n][m - 1];

      final par = ar * p[m][n];
      double temp1, temp2;
      if (m == 0) {
        temp1 = tc[m][n] * cp[m];
        temp2 = tc[m][n] * sp[m];
      } else {
        temp1 = tc[m][n] * cp[m] + tc[n][m - 1] * sp[m];
        temp2 = tc[m][n] * sp[m] - tc[n][m - 1] * cp[m];
      }
      bt -= ar * temp1 * dp[m][n];
      bp += m * temp2 * par;
      br += (n + 1) * temp1 * par;
      // Ai poli st vale zero e la componente est si ricava a parte.
      if (st == 0 && m == 1) {
        pp[n] = n == 1 ? pp[n - 1] : ct * pp[n - 1] - t.k[m][n] * pp[n - 2];
        bpp += m * temp2 * ar * pp[n];
      }
    }
  }
  bp = st == 0 ? bpp : bp / st;

  final bx = -bt * ca - br * sa;
  final by = bp;
  final gradi = math.atan2(by, bx) * 180 / math.pi;
  return DeclinazioneMagnetica(gradi, ripiego: fuori);
}

/// L'anno decimale di un istante, per il modello.
double annoDecimale(DateTime istante) {
  final u = istante.toUtc();
  final inizio = DateTime.utc(u.year);
  final fine = DateTime.utc(u.year + 1);
  return u.year +
      u.difference(inizio).inMilliseconds / fine.difference(inizio).inMilliseconds;
}
