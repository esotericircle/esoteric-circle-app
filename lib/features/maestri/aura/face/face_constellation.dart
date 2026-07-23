import 'dart:math' as math;
import 'dart:ui' show Offset;

import 'package:flutter/foundation.dart';

import '../../../../core/face/face_classifier.dart';

/// La costellazione del viso: le stelle sui punti chiave e le linee che le
/// uniscono, ricavate dai contorni in modo deterministico.
///
/// Le stelle stanno in coordinate normalizzate nel riquadro del volto (da zero a
/// uno), cosi' la stessa costruzione vale per il volto dal vivo e per la sagoma
/// neutra del ripiego: chi disegna la scala alla sua superficie.
@immutable
class FaceConstellation {
  const FaceConstellation({required this.stelle, required this.linee});

  /// Le stelle, in coordinate da zero a uno nel riquadro del volto.
  final List<Offset> stelle;

  /// Le linee, come coppie di indici nelle stelle.
  final List<List<int>> linee;

  /// Le stelle scalate a una superficie di lato [lato], con un margine.
  List<Offset> scalate(double lato, {double margine = 0.08}) {
    final m = lato * margine;
    final utile = lato - 2 * m;
    return [
      for (final s in stelle) Offset(m + s.dx * utile, m + s.dy * utile),
    ];
  }

  /// Costruisce la costellazione dai contorni del volto. I punti chiave si
  /// normalizzano nel riquadro del volto, cosi' l'esito non dipende dalla scala.
  static FaceConstellation da(FaceContours c) {
    final box = _box(c.volto);
    Offset norm(Offset o) => Offset(
          box.w <= 0 ? 0.5 : (o.dx - box.minX) / box.w,
          box.h <= 0 ? 0.5 : (o.dy - box.minY) / box.h,
        );

    final cx = (box.minX + box.maxX) / 2;
    final fronte = _estremoY(c.volto, alto: true);
    final mento = _estremoY(c.volto, alto: false);
    final zSx = c.guanciaSx ?? _estremoFascia(c.volto, box, 0.40, 0.60, sinistra: true);
    final zDx = c.guanciaDx ?? _estremoFascia(c.volto, box, 0.40, 0.60, sinistra: false);
    final mSx = _estremoFascia(c.volto, box, 0.68, 0.88, sinistra: true);
    final mDx = _estremoFascia(c.volto, box, 0.68, 0.88, sinistra: false);
    final sopSxIn = _versoCentro(c.sopraccioSx, cx, vicino: true);
    final sopSxOut = _versoCentro(c.sopraccioSx, cx, vicino: false);
    final sopDxIn = _versoCentro(c.sopraccioDx, cx, vicino: true);
    final sopDxOut = _versoCentro(c.sopraccioDx, cx, vicino: false);
    final occSx = _centro(c.occhioSx);
    final occDx = _centro(c.occhioDx);
    final naso = _centro(c.nasoBase);
    final labbra = [...c.labbroSopra, ...c.labbroSotto];
    final boccaSx = _estremoX(labbra, sinistra: true);
    final boccaDx = _estremoX(labbra, sinistra: false);

    final punti = <Offset>[
      fronte, // 0
      sopSxIn, sopSxOut, // 1 2
      sopDxIn, sopDxOut, // 3 4
      occSx, occDx, // 5 6
      naso, // 7
      boccaSx, boccaDx, // 8 9
      mento, // 10
      zSx, zDx, // 11 12
      mSx, mDx, // 13 14
    ];

    return FaceConstellation(
      stelle: [for (final p in punti) norm(p)],
      linee: const [
        [1, 2], [3, 4], [1, 3], // sopracciglia e ponte
        [1, 5], [3, 6], // sopracciglio verso occhio
        [5, 7], [6, 7], // occhi verso naso
        [7, 8], [7, 9], [8, 9], // naso verso bocca
        [8, 10], [9, 10], // bocca verso mento
        [11, 5], [12, 6], // zigomo verso occhio
        [11, 13], [12, 14], // zigomo verso mascella
        [13, 10], [14, 10], // mascella verso mento
        [0, 1], [0, 3], // fronte verso sopracciglia
        [0, 11], [0, 12], // fronte verso zigomi
      ],
    );
  }

  // --- aiuti geometrici ---

  static ({double minX, double minY, double maxX, double maxY, double w, double h})
      _box(List<Offset> p) {
    var minX = double.infinity, minY = double.infinity;
    var maxX = -double.infinity, maxY = -double.infinity;
    for (final o in p) {
      minX = math.min(minX, o.dx);
      minY = math.min(minY, o.dy);
      maxX = math.max(maxX, o.dx);
      maxY = math.max(maxY, o.dy);
    }
    if (p.isEmpty) return (minX: 0, minY: 0, maxX: 1, maxY: 1, w: 1, h: 1);
    return (minX: minX, minY: minY, maxX: maxX, maxY: maxY, w: maxX - minX, h: maxY - minY);
  }

  static Offset _estremoY(List<Offset> p, {required bool alto}) {
    var best = p.first;
    for (final o in p) {
      if (alto ? o.dy < best.dy : o.dy > best.dy) best = o;
    }
    return best;
  }

  static Offset _estremoX(List<Offset> p, {required bool sinistra}) {
    var best = p.first;
    for (final o in p) {
      if (sinistra ? o.dx < best.dx : o.dx > best.dx) best = o;
    }
    return best;
  }

  static Offset _estremoFascia(
      List<Offset> volto, dynamic box, double da, double a,
      {required bool sinistra}) {
    final y0 = box.minY + box.h * da;
    final y1 = box.minY + box.h * a;
    final dentro = volto.where((o) => o.dy >= y0 && o.dy <= y1).toList();
    if (dentro.isEmpty) {
      return sinistra
          ? Offset(box.minX, box.minY + box.h * (da + a) / 2)
          : Offset(box.maxX, box.minY + box.h * (da + a) / 2);
    }
    return _estremoX(dentro, sinistra: sinistra);
  }

  static Offset _versoCentro(List<Offset> p, double cx, {required bool vicino}) {
    if (p.isEmpty) return Offset(cx, 0);
    var best = p.first;
    for (final o in p) {
      final d = (o.dx - cx).abs();
      final db = (best.dx - cx).abs();
      if (vicino ? d < db : d > db) best = o;
    }
    return best;
  }

  static Offset _centro(List<Offset> p) {
    if (p.isEmpty) return const Offset(0, 0);
    var x = 0.0, y = 0.0;
    for (final o in p) {
      x += o.dx;
      y += o.dy;
    }
    return Offset(x / p.length, y / p.length);
  }
}
