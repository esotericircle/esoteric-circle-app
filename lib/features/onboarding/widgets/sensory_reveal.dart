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
    this.size = 92,
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

  // Viso di profilo che soffia: guance che si gonfiano e fiato che esce.
  void _blow(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final puff = 0.5 + 0.5 * math.sin(t * 2 * math.pi); // ciclo del respiro
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..color = color;

    // Profilo del viso rivolto a destra (fronte, naso, labbra, mento).
    final cx = w * 0.34, cy = h * 0.5;
    final face = Path()
      ..moveTo(cx - w * 0.18, cy - h * 0.30)
      ..cubicTo(cx + w * 0.10, cy - h * 0.34, cx + w * 0.16, cy - h * 0.16,
          cx + w * 0.14, cy - h * 0.06) // fronte verso il naso
      ..lineTo(cx + w * (0.20 + 0.03 * puff), cy) // punta del naso
      ..lineTo(cx + w * 0.12, cy + h * 0.05) // sotto il naso
      ..cubicTo(cx + w * (0.20 + 0.05 * puff), cy + h * 0.10,
          cx + w * (0.18 + 0.05 * puff), cy + h * 0.16, cx + w * 0.10,
          cy + h * 0.16) // guancia gonfia e labbra unite
      ..cubicTo(cx + w * 0.12, cy + h * 0.26, cx - w * 0.02, cy + h * 0.30,
          cx - w * 0.18, cy + h * 0.28); // mento e mascella
    canvas.drawPath(face, line);

    // Occhio.
    canvas.drawCircle(Offset(cx + w * 0.01, cy - h * 0.12), 1.8,
        Paint()..color = color);

    // Fiato che esce dalle labbra, tre soffi in movimento verso destra.
    final mouth = Offset(cx + w * 0.16, cy + h * 0.10);
    for (var i = 0; i < 3; i++) {
      final f = ((t + i / 3) % 1.0);
      final x = mouth.dx + f * w * 0.42;
      final spread = h * (0.03 + 0.10 * f);
      final alpha = ((1 - f) * 0.9).clamp(0.0, 0.9);
      canvas.drawArc(
        Rect.fromCenter(
            center: Offset(x, mouth.dy + math.sin(f * 3) * h * 0.02),
            width: w * 0.16,
            height: spread * 2),
        -math.pi / 2,
        math.pi,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round
          ..color = color.withValues(alpha: alpha),
      );
    }
  }

  // Un dito che scorre da sinistra a destra, con scia.
  void _swipe(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final travel = (t % 1.0);
    final x = w * (0.18 + 0.6 * Curves.easeInOut.transform(travel));
    final y = h * 0.56;
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color;

    // Scia puntinata dietro il dito.
    for (var i = 1; i <= 5; i++) {
      final tx = x - i * w * 0.06;
      if (tx < w * 0.12) continue;
      canvas.drawCircle(Offset(tx, y + h * 0.02), 1.6,
          Paint()..color = color.withValues(alpha: (0.5 - i * 0.09).clamp(0.0, 0.5)));
    }

    // Dito stilizzato (polpastrello + falange), inclinato.
    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(-0.5);
    final finger = Path()
      ..moveTo(-w * 0.05, h * 0.16)
      ..lineTo(-w * 0.05, -h * 0.04)
      ..cubicTo(-w * 0.05, -h * 0.14, w * 0.07, -h * 0.14, w * 0.07, -h * 0.04)
      ..lineTo(w * 0.07, h * 0.16);
    canvas.drawPath(finger, line);
    // Unghia.
    canvas.drawArc(
        Rect.fromCircle(center: Offset(w * 0.01, -h * 0.06), radius: w * 0.045),
        math.pi, math.pi, false, line);
    canvas.restore();

    // Freccia direzione.
    final ax = w * 0.86;
    canvas.drawLine(Offset(ax - w * 0.08, y - h * 0.22),
        Offset(ax, y - h * 0.22), line);
    canvas.drawLine(Offset(ax - w * 0.04, y - h * 0.25),
        Offset(ax, y - h * 0.22), line);
    canvas.drawLine(Offset(ax - w * 0.04, y - h * 0.19),
        Offset(ax, y - h * 0.22), line);
  }

  @override
  bool shouldRepaint(_CoachPainter old) => old.t != t || old.color != color;
}
