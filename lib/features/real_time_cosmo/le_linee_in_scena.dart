/// LE LINEE DELLE FIGURE IN SCENA. Ordine FH parti 3 e 4.
///
/// Le 187 coppie del file si disegnano in UNA chiamata per fotogramma (voce
/// 3.2): ogni linea e' un nastro di due triangoli, e tutti i nastri stanno in
/// un buffer di vertici nato una volta sola alla misura del file, riscritto a
/// ogni fotogramma e consegnato a `drawVertices`. Un nastro e non un tratto di
/// penna perche' la figura al centro ha lo spessore 2,0 e le altre 1,2 (voce
/// 3.3): con `drawRawPoints` sarebbero servite due chiamate, una per
/// spessore. L'alfa di ogni linea porta la forza della sua figura (voce 4.3).
///
/// Nessuna sfocatura, nessuno shader: i colori sono nei vertici.
library;

import 'dart:math' as math;
import 'dart:typed_data';

import '../../core/astro/real_time_cosmo/il_cielo_in_un_istante.dart';
import '../../core/astro/real_time_cosmo/la_camera_del_cielo.dart';
import '../../core/astro/real_time_cosmo/le_linee_delle_figure.dart';

/// Il colore delle linee, 226, 178, 86 (voce 3.3), senza alfa.
const int kColoreDelleLinee = (226 << 16) | (178 << 8) | 86;

/// Gli spessori in punti logici (voce 3.3).
const double kSpessoreDellaFiguraAlCentro = 2.0;
const double kSpessoreDelleAltre = 1.2;

/// La luce piena di una linea, prima della forza: le linee accompagnano le
/// stelle, non le coprono.
const double kLuceDelleLinee = 0.62;

/// Oltre questo margine fuori dallo schermo una linea non si disegna.
const double kMargineDelleLinee = 200;

class LineeInScena {
  LineeInScena(this.linee)
      : posizioni = Float32List(linee.numeroDiLinee * 12),
        colori = Int32List(linee.numeroDiLinee * 6),
        disegnate = Int32List(linee.numeroDiLinee);

  final LeLineeDelleFigure linee;

  /// Sei vertici per linea, due numeri per vertice.
  final Float32List posizioni;
  final Int32List colori;

  /// Gli indici delle linee disegnate nell'ultimo fotogramma, per la guardia
  /// 15.3: il codice disegna le coppie del file e nessun'altra.
  final Int32List disegnate;

  /// Quanti vertici e quante linee ha scritto l'ultimo fotogramma.
  int vertici = 0;
  int quante = 0;

  final List<double> _p1 = [0, 0], _p2 = [0, 0];

  /// Riempie il buffer. [figuraAlCentro] e' l'indice in `linee.figure` della
  /// figura che porta il velo, o nulla. [luceSotto] moltiplica le linee sotto
  /// l'orizzonte.
  void prepara({
    required CieloInUnIstante cielo,
    CieloInUnIstante? poi,
    double t = 0,
    required OrientamentoDellaCamera orientamento,
    required ProiezioneDelCielo proiezione,
    double spostamentoX = 0,
    double spostamentoY = 0,
    int? figuraAlCentro,
    double luceSotto = 1,
  }) {
    final w = proiezione.larghezza, h = proiezione.altezza;
    var v = 0, n = 0;
    for (var k = 0; k < linee.numeroDiLinee; k++) {
      final i1 = linee.da[k], i2 = linee.a[k];
      var x1 = cielo.x[i1], y1 = cielo.y[i1], z1 = cielo.z[i1];
      var x2 = cielo.x[i2], y2 = cielo.y[i2], z2 = cielo.z[i2];
      final b = poi;
      if (b != null && t > 0) {
        x1 += (b.x[i1] - x1) * t;
        y1 += (b.y[i1] - y1) * t;
        z1 += (b.z[i1] - z1) * t;
        x2 += (b.x[i2] - x2) * t;
        y2 += (b.y[i2] - y2) * t;
        z2 += (b.z[i2] - z2) * t;
      }
      if (!proiezione.proietta(orientamento, x1, y1, z1, _p1) ||
          !proiezione.proietta(orientamento, x2, y2, z2, _p2)) {
        continue;
      }
      final ax = _p1[0] + spostamentoX, ay = _p1[1] + spostamentoY;
      final bx = _p2[0] + spostamentoX, by = _p2[1] + spostamentoY;
      if ((ax < -kMargineDelleLinee && bx < -kMargineDelleLinee) ||
          (ax > w + kMargineDelleLinee && bx > w + kMargineDelleLinee) ||
          (ay < -kMargineDelleLinee && by < -kMargineDelleLinee) ||
          (ay > h + kMargineDelleLinee && by > h + kMargineDelleLinee)) {
        continue;
      }
      final dx = bx - ax, dy = by - ay;
      final lunghezza = math.sqrt(dx * dx + dy * dy);
      if (lunghezza < 0.5) continue;
      final figura = linee.figuraDellaLinea[k];
      final spessore = figura == figuraAlCentro
          ? kSpessoreDellaFiguraAlCentro
          : kSpessoreDelleAltre;
      final nx = -dy / lunghezza * spessore / 2;
      final ny = dx / lunghezza * spessore / 2;
      var luce = kLuceDelleLinee * linee.figure[figura].forza;
      if (z1 < 0 && z2 < 0) luce *= luceSotto;
      final colore = ((luce * 255).round().clamp(0, 255) << 24) | kColoreDelleLinee;
      final o = v * 2;
      // Due triangoli: (a+n, a-n, b+n) e (b+n, a-n, b-n).
      posizioni[o] = ax + nx;
      posizioni[o + 1] = ay + ny;
      posizioni[o + 2] = ax - nx;
      posizioni[o + 3] = ay - ny;
      posizioni[o + 4] = bx + nx;
      posizioni[o + 5] = by + ny;
      posizioni[o + 6] = bx + nx;
      posizioni[o + 7] = by + ny;
      posizioni[o + 8] = ax - nx;
      posizioni[o + 9] = ay - ny;
      posizioni[o + 10] = bx - nx;
      posizioni[o + 11] = by - ny;
      for (var c = 0; c < 6; c++) {
        colori[v + c] = colore;
      }
      v += 6;
      disegnate[n] = k;
      n++;
    }
    vertici = v;
    quante = n;
  }
}
