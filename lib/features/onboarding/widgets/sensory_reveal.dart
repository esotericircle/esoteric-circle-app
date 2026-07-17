import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../design_system/theme/maestro_palette.dart';

/// La scala dell'aiuto universale, condivisa da tutte le esperienze basate su
/// sensori (soffio, scuotimento, giroscopio, fotocamera). Non e' legata a un
/// sensore: riceve solo il tempo trascorso, se c'e' stato un tentativo che si e'
/// arenato e l'avanzamento, e decide quale livello d'aiuto mostrare.
///
/// I quattro gradini:
/// a) l'oggetto invita da subito col suo movimento (nessun testo);
/// b) dopo [coachAfter] compaiono le silhouette grandi e senza sfondo;
/// c) al primo input, anche minimo, il feedback e' immediato (gestito
///    dall'oggetto stesso, che reagisce al livello);
/// d) dopo [tapAfter], oppure dopo un tentativo che non basta, appare l'invito
///    sempre toccabile "Tocca per svelare", via garantita che completa da sola.
class RevealHelp {
  const RevealHelp({
    this.coachAfter = const Duration(seconds: 3),
    this.tapAfter = const Duration(seconds: 8),
  });

  final Duration coachAfter;
  final Duration tapAfter;

  /// Le silhouette guida vanno mostrate quando l'attesa supera [coachAfter] e il
  /// rito non e' quasi concluso.
  bool showCoach({required Duration sinceStart, required double progress}) =>
      sinceStart >= coachAfter && progress < 0.9;

  /// L'invito toccabile di sicurezza appare dopo [tapAfter], oppure subito dopo
  /// un tentativo che si e' arenato senza completare.
  bool showSafetyTap({
    required Duration sinceStart,
    required bool attemptStalled,
    required double progress,
  }) =>
      progress < 1.0 && (attemptStalled || sinceStart >= tapAfter);
}

/// Il gesto che la guida illustra. La stessa componente serve tutte le
/// esperienze sensoriali: per ora soffio e scorrimento del dito sono disegnati,
/// gli altri riusano la medesima scala d'aiuto.
enum CoachGesture { blow, swipe }

/// Silhouette guida grandi, chiare e animate, senza alcun banner o sfondo: un
/// viso di profilo che soffia (labbra unite, guance gonfie) e un dito che scorre
/// da sinistra a destra. Rispetta Riduci Movimento restando su un fotogramma
/// fermo ma leggibile.
class GestureCoach extends StatefulWidget {
  const GestureCoach({
    super.key,
    required this.gestures,
    required this.palette,
    this.reduceMotion = false,
    this.size = 108,
  });

  final List<CoachGesture> gestures;
  final MaestroPalette palette;
  final bool reduceMotion;
  final double size;

  @override
  State<GestureCoach> createState() => _GestureCoachState();
}

class _GestureCoachState extends State<GestureCoach>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    if (!widget.reduceMotion) _c.repeat();
  }

  @override
  void didUpdateWidget(GestureCoach old) {
    super.didUpdateWidget(old);
    if (widget.reduceMotion && _c.isAnimating) {
      _c.stop();
      _c.value = 0.5;
    } else if (!widget.reduceMotion && !_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) => Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (final g in widget.gestures)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: SizedBox(
                width: widget.size,
                height: widget.size,
                child: CustomPaint(
                  painter: _CoachPainter(
                    gesture: g,
                    color: widget.palette.goldSoft,
                    t: widget.reduceMotion ? 0.5 : _c.value,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CoachPainter extends CustomPainter {
  _CoachPainter({required this.gesture, required this.color, required this.t});

  final CoachGesture gesture;
  final Color color;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    switch (gesture) {
      case CoachGesture.blow:
        _blow(canvas, size);
      case CoachGesture.swipe:
        _swipe(canvas, size);
    }
  }

  // Viso di profilo che soffia: guancia che si gonfia, labbra a soffio, fiato.
  void _blow(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final puff = 0.5 + 0.5 * math.sin(t * 2 * math.pi); // ciclo del respiro
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..color = color;

    final cx = w * 0.30, cy = h * 0.48;
    final cheek = w * 0.04 * puff; // la guancia che si gonfia
    // Profilo rivolto a destra: fronte, naso, labbra sporte, mento, mascella.
    final face = Path()
      ..moveTo(cx - w * 0.16, cy - h * 0.28) // alto della fronte
      ..cubicTo(cx + w * 0.14, cy - h * 0.34, cx + w * 0.20, cy - h * 0.14,
          cx + w * 0.16, cy - h * 0.05) // fronte che scende al naso
      ..cubicTo(cx + w * 0.24, cy - h * 0.03, cx + w * 0.25, cy + h * 0.02,
          cx + w * 0.18, cy + h * 0.03) // punta del naso e narice
      ..cubicTo(cx + w * 0.22, cy + h * 0.06, cx + w * 0.22, cy + h * 0.10,
          cx + w * 0.16, cy + h * 0.10) // labbro superiore sporto (soffio)
      ..cubicTo(cx + w * 0.20, cy + h * 0.13, cx + w * 0.17, cy + h * 0.17,
          cx + w * 0.12, cy + h * 0.16) // labbro inferiore e mento
      ..cubicTo(cx + w * (0.14 + 0.02) + cheek, cy + h * 0.24,
          cx - w * 0.02, cy + h * 0.30, cx - w * 0.16, cy + h * 0.27); // mascella
    canvas.drawPath(face, line);

    // Guancia gonfia suggerita da un breve arco interno.
    canvas.drawArc(
        Rect.fromCircle(
            center: Offset(cx + w * 0.06, cy + h * 0.06),
            radius: w * (0.07 + 0.02 * puff)),
        -0.5,
        1.8,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4
          ..color = color.withValues(alpha: 0.4));

    // Occhio.
    canvas.drawCircle(
        Offset(cx + w * 0.03, cy - h * 0.12), 2.0, Paint()..color = color);

    // Fiato che esce dalle labbra in soffi curvi verso destra.
    final mouth = Offset(cx + w * 0.19, cy + h * 0.12);
    for (var i = 0; i < 3; i++) {
      final f = ((t + i / 3) % 1.0);
      final x = mouth.dx + f * w * 0.40;
      final spread = h * (0.03 + 0.11 * f);
      final alpha = ((1 - f) * 0.85).clamp(0.0, 0.85);
      canvas.drawArc(
        Rect.fromCenter(
            center: Offset(x, mouth.dy + math.sin(f * 3) * h * 0.02),
            width: w * 0.15,
            height: spread * 2),
        -math.pi / 2,
        math.pi,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2
          ..strokeCap = StrokeCap.round
          ..color = color.withValues(alpha: alpha),
      );
    }
  }

  // Una mano con il solo indice esteso che scorre da sinistra a destra.
  void _swipe(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final travel = (t % 1.0);
    final x = w * (0.30 + 0.40 * Curves.easeInOut.transform(travel)); // polpastrello
    final y = h * 0.52;

    // Scia puntinata sotto il polpastrello.
    for (var i = 1; i <= 6; i++) {
      final tx = x - i * w * 0.05;
      if (tx < w * 0.08) continue;
      canvas.drawCircle(Offset(tx, y + h * 0.08), 1.7,
          Paint()..color = color.withValues(alpha: (0.5 - i * 0.08).clamp(0.0, 0.5)));
    }

    final fill = Paint()..color = color.withValues(alpha: 0.16);
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..color = color;

    // La sagoma della mano si compone unendo forme pulite, cosi' il contorno e'
    // unico e netto: indice esteso, pugno, pollice.
    final ff = h * 0.05; // mezzo spessore dell'indice
    final fl = w * 0.34; // lunghezza dell'indice (dalla nocca alla punta)
    final fistW = w * 0.24, fistH = h * 0.30;
    final fistCx = x - fl - fistW * 0.30;
    final fistCy = y + fistH * 0.16;

    final index = Path()
      ..addRRect(RRect.fromRectAndRadius(
          Rect.fromLTRB(x - fl, y - ff, x + ff * 0.4, y + ff),
          Radius.circular(ff)));
    final fist = Path()
      ..addRRect(RRect.fromRectAndRadius(
          Rect.fromCenter(
              center: Offset(fistCx, fistCy), width: fistW, height: fistH),
          Radius.circular(h * 0.10)));
    final thumb = Path()
      ..addOval(Rect.fromCircle(
          center: Offset(fistCx + fistW * 0.12, fistCy - fistH * 0.42),
          radius: h * 0.055));

    var hand = Path.combine(PathOperation.union, fist, index);
    hand = Path.combine(PathOperation.union, hand, thumb);
    canvas.drawPath(hand, fill);
    canvas.drawPath(hand, line);

    // Unghia sul polpastrello.
    canvas.drawArc(
        Rect.fromCircle(center: Offset(x - ff * 0.2, y), radius: ff * 0.5),
        -math.pi / 2, math.pi, false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4
          ..color = color.withValues(alpha: 0.6));
    // Solchi delle dita chiuse sul davanti del pugno.
    for (var k = 0; k < 3; k++) {
      final gx = fistCx + fistW * 0.30;
      final gy = fistCy - fistH * 0.22 + k * fistH * 0.24;
      canvas.drawArc(
          Rect.fromCircle(center: Offset(gx, gy), radius: h * 0.03),
          -math.pi / 2, math.pi, false,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.4
            ..strokeCap = StrokeCap.round
            ..color = color.withValues(alpha: 0.45));
    }

    // Freccia di direzione sopra la mano.
    final ax = w * 0.92;
    final ay = y - h * 0.28;
    canvas.drawLine(Offset(ax - w * 0.16, ay), Offset(ax, ay), line);
    canvas.drawLine(Offset(ax - w * 0.05, ay - h * 0.035), Offset(ax, ay), line);
    canvas.drawLine(Offset(ax - w * 0.05, ay + h * 0.035), Offset(ax, ay), line);
  }

  @override
  bool shouldRepaint(_CoachPainter old) => old.t != t || old.color != color;
}
