import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import '../../core/astro/zodiac.dart';
import '../../core/identity/circle_seal.dart';

/// Disegna il Sigillo del Cerchio in modo procedurale e deterministico, come
/// un'esperienza che si compone da sola.
///
/// La ruota dello zodiaco si traccia, il Sole scende dall'alto e si posa sulla
/// posizione del segno, il colore dell'elemento invade la scena, la geometria
/// sacra fiorisce e il Numero della vita si forma al centro con un bagliore.
/// Profondita' 2.5D con ombre e aloni, non semplici linee su fondo nero. Il
/// parametro [progress] compone il sigillo, da 0 a 1. La base e' procedurale e
/// dichiaratamente sostituibile con l'arte definitiva.
class SealPainter extends CustomPainter {
  SealPainter({required this.seal, this.progress = 1.0});

  final CircleSeal seal;
  final double progress;

  static const Color _gold = Color(0xFFE8C463);

  int get _symmetry {
    final n = seal.lifePath;
    if (n >= 11) return (n ~/ 11) + 5; // maestri: forme piu' ricche
    return n.clamp(3, 9);
  }

  double _phase(double start, double end) {
    if (progress <= start) return 0;
    if (progress >= end) return 1;
    return (progress - start) / (end - start);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.shortestSide / 2 * 0.9;
    final color = seal.color;

    _paintElementFlood(canvas, center, r, color);
    _paintDepthPlate(canvas, center, r, color);
    _paintRing(canvas, center, r, color);
    _paintWheel(canvas, center, r, color);
    _paintSun(canvas, center, r);
    _paintSacredGeometry(canvas, center, r, color);
    _paintNumber(canvas, center, r, color);
  }

  // Il colore dell'elemento invade la scena, un lavacro radiale che cresce.
  void _paintElementFlood(Canvas canvas, Offset center, double r, Color color) {
    final flood = _phase(0.28, 0.9);
    if (flood <= 0) return;
    canvas.drawCircle(
      center,
      r * 1.15,
      Paint()
        ..shader = RadialGradient(
          colors: [
            color.withValues(alpha: 0.30 * flood),
            color.withValues(alpha: 0.10 * flood),
            const Color(0x00000000),
          ],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: r * 1.15)),
    );
    // Texture dell'elemento: anelli concentrici tenui, non linee piatte.
    for (var i = 1; i <= 3; i++) {
      canvas.drawCircle(
        center,
        r * (0.5 + i * 0.14),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.6
          ..color = color.withValues(alpha: 0.10 * flood),
      );
    }
  }

  // Profondita' 2.5D: una piastra scura leggermente ribassata dietro la ruota e
  // un tocco di luce, cosi' il sigillo ha spessore.
  void _paintDepthPlate(Canvas canvas, Offset center, double r, Color color) {
    final p = _phase(0.0, 0.4);
    if (p <= 0) return;
    // Ombra portata, sfumata e spostata in basso.
    canvas.drawCircle(
      center + Offset(0, r * 0.05),
      r * 0.9,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.5 * p)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24),
    );
    // Piastra del disco, con un gradiente che simula la concavita'.
    canvas.drawCircle(
      center,
      r * 0.9,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.4),
          colors: [
            color.withValues(alpha: 0.18 * p),
            const Color(0xFF0B0B12).withValues(alpha: 0.7 * p),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: r * 0.9)),
    );
  }

  // Anello esterno dorato, si traccia per primo, con un filo interno d'elemento.
  void _paintRing(Canvas canvas, Offset center, double r, Color color) {
    final ringP = _phase(0.0, 0.4);
    if (ringP <= 0) return;
    // Alone dell'oro sotto l'anello, per lo spessore.
    canvas.drawCircle(
      center,
      r * 0.92,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..color = _gold.withValues(alpha: 0.18 * ringP)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r * 0.92),
      -math.pi / 2,
      2 * math.pi * ringP,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..strokeCap = StrokeCap.round
        ..color = _gold.withValues(alpha: 0.9),
    );
    canvas.drawCircle(
      center,
      r * 0.82,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = color.withValues(alpha: 0.5 * ringP),
    );
  }

  // Ruota dello zodiaco: dodici raggi, il segno solare acceso e piu' luminoso.
  void _paintWheel(Canvas canvas, Offset center, double r, Color color) {
    final wheelP = _phase(0.12, 0.55);
    if (wheelP <= 0) return;
    final signIndex = Zodiac.values.indexOf(seal.sign);
    for (var i = 0; i < 12; i++) {
      final a = 2 * math.pi * i / 12 - math.pi / 2;
      final dir = Offset(math.cos(a), math.sin(a));
      final lit = i == signIndex;
      canvas.drawLine(
        center + dir * r * 0.5,
        center + dir * r * 0.82,
        Paint()
          ..strokeWidth = lit ? 2.4 : 0.8
          ..color = (lit ? _gold : color)
              .withValues(alpha: (lit ? 0.95 : 0.32) * wheelP),
      );
      canvas.drawCircle(
        center + dir * r * 0.82,
        lit ? 4.0 * wheelP : 2.0 * wheelP,
        Paint()
          ..color = (lit ? _gold : color).withValues(alpha: 0.85 * wheelP),
      );
    }
  }

  // Il Sole scende dall'alto e si posa sulla posizione del segno sulla ruota.
  void _paintSun(Canvas canvas, Offset center, double r) {
    final sunP = _phase(0.32, 0.66);
    if (sunP <= 0) return;
    final signIndex = Zodiac.values.indexOf(seal.sign);
    final a = 2 * math.pi * signIndex / 12 - math.pi / 2;
    final target = center + Offset(math.cos(a), math.sin(a)) * r * 0.82;
    final start = center + Offset(0, -r * 1.25);
    final t = Curves.easeInOutCubic.transform(sunP);
    final pos = Offset.lerp(start, target, t)!;
    final sunR = lerpDouble(r * 0.12, r * 0.075, t)!;
    final landing = _phase(0.6, 0.78); // piccolo lampo all'arrivo

    // Alone del Sole.
    canvas.drawCircle(
      pos,
      sunR * (2.6 + landing),
      Paint()
        ..color = _gold.withValues(alpha: 0.35 + 0.2 * landing)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, sunR * 1.4),
    );
    // Raggi del Sole, un glifo vero disegnato dal codice.
    for (var i = 0; i < 12; i++) {
      final ra = 2 * math.pi * i / 12;
      final dir = Offset(math.cos(ra), math.sin(ra));
      canvas.drawLine(
        pos + dir * sunR * 1.35,
        pos + dir * sunR * (1.9 + 0.3 * landing),
        Paint()
          ..strokeWidth = 1.6
          ..strokeCap = StrokeCap.round
          ..color = _gold.withValues(alpha: 0.85),
      );
    }
    // Disco del Sole, con luce in alto a sinistra per il volume.
    canvas.drawCircle(
      pos,
      sunR,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.4, -0.4),
          colors: [Color(0xFFFFF3D0), _gold, Color(0xFFC79A3A)],
          stops: [0.0, 0.55, 1.0],
        ).createShader(Rect.fromCircle(center: pos, radius: sunR)),
    );
  }

  // Geometria sacra centrale, simmetria dal Numero della vita, e una corona di
  // tacche pari al numero.
  void _paintSacredGeometry(
      Canvas canvas, Offset center, double r, Color color) {
    final geoP = _phase(0.55, 0.85);
    if (geoP <= 0) return;
    final sym = _symmetry;
    final path = Path();
    for (var i = 0; i <= sym; i++) {
      final a = 2 * math.pi * i / sym - math.pi / 2;
      final p = center + Offset(math.cos(a), math.sin(a)) * r * 0.42 * geoP;
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..strokeJoin = StrokeJoin.round
        ..color = _gold.withValues(alpha: 0.7 * geoP),
    );
    final ticks = seal.lifePath.clamp(1, 33);
    for (var i = 0; i < ticks; i++) {
      final a = 2 * math.pi * i / ticks - math.pi / 2;
      final dir = Offset(math.cos(a), math.sin(a));
      canvas.drawCircle(center + dir * r * 0.6, 1.6 * geoP,
          Paint()..color = color.withValues(alpha: 0.7 * geoP));
    }
  }

  // Cifra del Numero della vita al centro, per ultima, con un bagliore.
  void _paintNumber(Canvas canvas, Offset center, double r, Color color) {
    final numP = _phase(0.72, 1.0);
    if (numP <= 0) return;
    canvas.drawCircle(
      center,
      r * 0.28,
      Paint()
        ..shader = RadialGradient(colors: [
          color.withValues(alpha: 0.5 * numP),
          const Color(0x00000000),
        ]).createShader(Rect.fromCircle(center: center, radius: r * 0.32)),
    );
    final tp = TextPainter(
      text: TextSpan(
        text: '${seal.lifePath}',
        style: TextStyle(
          fontFamily: 'Cinzel',
          fontSize: r * 0.42,
          color: Colors.white.withValues(alpha: numP),
          shadows: [
            Shadow(color: _gold.withValues(alpha: 0.85 * numP), blurRadius: 18),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(SealPainter old) =>
      old.progress != progress || old.seal != seal;
}
