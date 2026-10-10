/// I CINQUE OGGETTI DEL CIELO PROFONDO IN SCENA. Ordine FH parte 10.
///
/// Ogni oggetto sta alle sue coordinate J2000 vere ([kCieloProfondo], voce
/// 10.1) e si gira sull'orizzonte con la stessa rotazione della Via Lattea,
/// i tre assi del cielo di quell'istante: nel fotogramma nove moltiplicazioni
/// per oggetto, niente di nuovo.
///
/// **Quanto e' grande.** La larghezza in primi d'arco decide la misura a
/// schermo, che segue il campo visivo come per le stelle. Negli asset la parte
/// accesa occupa circa il settanta per cento del lato (misurato il 10 ottobre
/// 2026 sulle colonne con luce media oltre 12: Pleiadi 160-868, Orione
/// 185-863, Andromeda 194-818, Laguna 149-880, Doppio Ammasso 142-861 su
/// 1024), e il resto e' il nero in cui l'immagine sfuma: il lato si
/// disegna quindi largo [kFrazioneAccesa] volte di meno della larghezza vera,
/// cosi' e' la parte accesa ad avere la larghezza del catalogo. Gli asset non
/// si ritagliano (voce 10.2).
library;

import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import '../../core/astro/real_time_cosmo/i_bersagli_del_cielo.dart';
import '../../core/astro/real_time_cosmo/la_camera_del_cielo.dart';

/// L'opacita' degli oggetti, in composizione luminosa (voce 10.2).
const double kOpacitaDelCieloProfondo = 0.85;

/// La parte accesa di ogni asset rispetto al suo lato.
const double kFrazioneAccesa = 0.70;

class CieloProfondoInScena {
  CieloProfondoInScena(this.immagini)
      : assert(immagini.length == kCieloProfondo.length) {
    const g = math.pi / 180;
    for (var i = 0; i < kCieloProfondo.length; i++) {
      final o = kCieloProfondo[i];
      final cd = math.cos(o.decGradi * g);
      _equatoriali[i * 3] = cd * math.cos(o.raGradi * g);
      _equatoriali[i * 3 + 1] = cd * math.sin(o.raGradi * g);
      _equatoriali[i * 3 + 2] = math.sin(o.decGradi * g);
    }
  }

  /// Gli asset, nell'ordine di [kCieloProfondo].
  final List<ui.Image> immagini;

  /// Il pennello: composizione luminosa a 0,85.
  final ui.Paint pennello = ui.Paint()
    ..blendMode = ui.BlendMode.screen
    ..filterQuality = ui.FilterQuality.medium
    ..color = const ui.Color.fromRGBO(255, 255, 255, kOpacitaDelCieloProfondo);

  final Float32List _equatoriali = Float32List(kCieloProfondo.length * 3);

  /// Il versore orizzontale di ogni oggetto nell'ultimo fotogramma.
  final Float32List versori = Float32List(kCieloProfondo.length * 3);

  /// Centro e lato a schermo, e se si vede, per ogni oggetto.
  final Float32List x = Float32List(kCieloProfondo.length);
  final Float32List y = Float32List(kCieloProfondo.length);
  final Float32List lato = Float32List(kCieloProfondo.length);
  final Uint8List visibile = Uint8List(kCieloProfondo.length);
  final List<double> _p = [0, 0];

  void prepara(OrientamentoDellaCamera o, ProiezioneDelCielo p,
      Float64List assi, Float64List? poi, double t,
      {double spostamentoX = 0, double spostamentoY = 0}) {
    var m0 = assi[0], m1 = assi[1], m2 = assi[2];
    var m3 = assi[3], m4 = assi[4], m5 = assi[5];
    var m6 = assi[6], m7 = assi[7], m8 = assi[8];
    if (poi != null && t > 0) {
      m0 += (poi[0] - m0) * t;
      m1 += (poi[1] - m1) * t;
      m2 += (poi[2] - m2) * t;
      m3 += (poi[3] - m3) * t;
      m4 += (poi[4] - m4) * t;
      m5 += (poi[5] - m5) * t;
      m6 += (poi[6] - m6) * t;
      m7 += (poi[7] - m7) * t;
      m8 += (poi[8] - m8) * t;
    }
    final ppg = p.puntiPerGrado;
    for (var i = 0; i < kCieloProfondo.length; i++) {
      final ex = _equatoriali[i * 3],
          ey = _equatoriali[i * 3 + 1],
          ez = _equatoriali[i * 3 + 2];
      var vx = ex * m0 + ey * m3 + ez * m6;
      var vy = ex * m1 + ey * m4 + ez * m7;
      var vz = ex * m2 + ey * m5 + ez * m8;
      final l = math.sqrt(vx * vx + vy * vy + vz * vz);
      vx /= l;
      vy /= l;
      vz /= l;
      versori[i * 3] = vx;
      versori[i * 3 + 1] = vy;
      versori[i * 3 + 2] = vz;
      if (p.proietta(o, vx, vy, vz, _p)) {
        x[i] = _p[0] + spostamentoX;
        y[i] = _p[1] + spostamentoY;
        lato[i] =
            kCieloProfondo[i].larghezzaInPrimi / 60 * ppg / kFrazioneAccesa;
        visibile[i] = 1;
      } else {
        visibile[i] = 0;
      }
    }
  }
}
