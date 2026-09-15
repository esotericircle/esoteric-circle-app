import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/astro/zodiac.dart';

/// La ruota zodiacale come firma disegnata dal codice, a vettori, non dipinta in
/// una foto.
///
/// E' un componente riutilizzabile e parametrico: si tinge del colore del
/// Maestro del momento con [color], si attenua con [opacity], animabile
/// dall'esterno, cosi' puo' svanire quando la luce di un gesto cresce e tornare
/// quando la scena si calma. La ruota ha una lenta rotazione d'ambiente che le
/// da' vita, ferma sotto Riduci Movimento: la sua versione statica.
///
/// I dodici simboli sono tracciati vettoriali, non caratteri di un font, cosi'
/// la ruota si rende identica ovunque, senza dipendere dai glifi disponibili.
///
/// Nota d'uso: e' montata come firma in basso sul fondale del Rito dell'Alba,
/// ora rigenerato senza la ruota dipinta nella foto, cosi' non ci sono doppioni.
/// La' l'opacita' e' pilotata dall'esterno perche' la ruota si attenui mentre la
/// luce del sollevamento cresce e torni quando la scena si calma.
class ZodiacWheel extends StatefulWidget {
  const ZodiacWheel({
    super.key,
    required this.color,
    this.opacity = 1.0,
    this.ambientRotation = true,
    this.highlight,
  });

  /// Tinta della ruota, il colore del Maestro del momento.
  final Color color;

  /// Opacita' complessiva, da 0 a 1. Pensata per essere animata dall'esterno.
  final double opacity;

  /// Lenta rotazione d'ambiente. Ferma comunque sotto Riduci Movimento.
  final bool ambientRotation;

  /// Segno da evidenziare, per esempio quello dell'utente. Null per nessuno.
  final Zodiac? highlight;

  @override
  State<ZodiacWheel> createState() => _ZodiacWheelState();
}

class _ZodiacWheelState extends State<ZodiacWheel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin;

  // Ampiezza dell'oscillazione d'ambiente: pochi gradi, cosi' i simboli restano
  // leggibili e non si capovolgono mai.
  static const double _sway = 4 * math.pi / 180;

  @override
  void initState() {
    super.initState();
    // Una lenta oscillazione avanti e indietro: una firma viva, mai un
    // movimento che distrae o che rovescia i simboli.
    _spin = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncSpin();
  }

  @override
  void didUpdateWidget(ZodiacWheel old) {
    super.didUpdateWidget(old);
    if (old.ambientRotation != widget.ambientRotation) _syncSpin();
  }

  void _syncSpin() {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final shouldSpin = widget.ambientRotation && !reduceMotion;
    if (shouldSpin && !_spin.isAnimating) {
      _spin.repeat();
    } else if (!shouldSpin && _spin.isAnimating) {
      _spin.stop();
    }
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _spin,
        builder: (context, _) => CustomPaint(
          size: Size.infinite,
          painter: _ZodiacWheelPainter(
            color: widget.color,
            opacity: widget.opacity.clamp(0.0, 1.0),
            rotation: math.sin(_spin.value * 2 * math.pi) * _sway,
            highlight: widget.highlight,
          ),
        ),
      ),
    );
  }
}

class _ZodiacWheelPainter extends CustomPainter {
  _ZodiacWheelPainter({
    required this.color,
    required this.opacity,
    required this.rotation,
    required this.highlight,
  });

  final Color color;
  final double opacity;
  final double rotation;
  final Zodiac? highlight;

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0.001) return;
    final center = size.center(Offset.zero);
    // La ruota vive nel cerchio inscritto, con un piccolo margine.
    final r = math.min(size.width, size.height) / 2 * 0.94;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);

    Color c(double a) => color.withValues(alpha: a * opacity);
    Paint stroke(double width, double a) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..color = c(a);

    // --- Anelli portanti ---
    canvas.drawCircle(Offset.zero, r, stroke(r * 0.006, 0.55));
    canvas.drawCircle(Offset.zero, r * 0.90, stroke(r * 0.004, 0.4));
    canvas.drawCircle(Offset.zero, r * 0.66, stroke(r * 0.004, 0.4));
    canvas.drawCircle(Offset.zero, r * 0.40, stroke(r * 0.004, 0.35));
    canvas.drawCircle(Offset.zero, r * 0.16, stroke(r * 0.004, 0.3));

    // --- Ticche di grado sulla corona esterna ---
    for (var i = 0; i < 72; i++) {
      final a = 2 * math.pi * i / 72;
      final dir = Offset(math.cos(a), math.sin(a));
      final major = i % 6 == 0; // ogni 30 gradi, confine di segno
      final inner = major ? r * 0.84 : r * 0.87;
      canvas.drawLine(dir * inner, dir * r * 0.90,
          stroke(major ? r * 0.007 : r * 0.004, major ? 0.6 : 0.35));
    }

    // --- Dodici settori: raggi ai confini, simbolo al centro del settore ---
    for (var i = 0; i < 12; i++) {
      final boundary = 2 * math.pi * i / 12 - math.pi / 2;
      final bdir = Offset(math.cos(boundary), math.sin(boundary));
      canvas.drawLine(bdir * r * 0.40, bdir * r * 0.66, stroke(r * 0.004, 0.3));

      final sign = Zodiac.values[i];
      final mid = boundary + math.pi / 12; // centro del settore
      final gpos = Offset(math.cos(mid), math.sin(mid)) * r * 0.78;
      final lit = sign == highlight;
      final gs = r * 0.058;
      drawZodiacGlyph(canvas, sign, gpos, gs,
          stroke(r * 0.010, lit ? 0.95 : 0.7)..color = c(lit ? 0.95 : 0.7));
      if (lit) {
        canvas.drawCircle(gpos, gs * 1.7, stroke(r * 0.005, 0.5));
      }
    }

    // --- Trama interna: dodecagramma sottile, la firma geometrica ---
    final web = stroke(r * 0.003, 0.16);
    final pts = [
      for (var i = 0; i < 12; i++)
        Offset(math.cos(2 * math.pi * i / 12 - math.pi / 2),
                math.sin(2 * math.pi * i / 12 - math.pi / 2)) *
            r *
            0.40,
    ];
    for (var i = 0; i < 12; i++) {
      canvas.drawLine(pts[i], pts[(i + 5) % 12], web);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_ZodiacWheelPainter old) =>
      old.color != color ||
      old.opacity != opacity ||
      old.rotation != rotation ||
      old.highlight != highlight;
}

/// Disegna il simbolo di un segno come tracciato vettoriale, centrato in [g],
/// entro un raggio [s]. Forme stilizzate ma riconoscibili, indipendenti dal
/// font. Riutilizzabile ovunque serva un glifo zodiacale disegnato dal codice,
/// per esempio nella corona del sole del Rito dell'Alba.
void drawZodiacGlyph(
    Canvas canvas, Zodiac sign, Offset g, double s, Paint paint) {
  {
    final path = Path();
    switch (sign) {
      case Zodiac.aries:
        // Due corna che si aprono da uno stelo centrale.
        path.moveTo(g.dx, g.dy - s * 0.1);
        path.lineTo(g.dx, g.dy + s * 0.7);
        path.moveTo(g.dx, g.dy - s * 0.1);
        path.cubicTo(g.dx - s * 0.15, g.dy - s, g.dx - s, g.dy - s * 0.8,
            g.dx - s * 0.75, g.dy - s * 0.05);
        path.moveTo(g.dx, g.dy - s * 0.1);
        path.cubicTo(g.dx + s * 0.15, g.dy - s, g.dx + s, g.dy - s * 0.8,
            g.dx + s * 0.75, g.dy - s * 0.05);
      case Zodiac.taurus:
        // Cerchio con corna aperte verso l'alto.
        canvas.drawCircle(Offset(g.dx, g.dy + s * 0.35), s * 0.5, paint);
        path.addArc(
            Rect.fromCircle(
                center: Offset(g.dx, g.dy - s * 0.35), radius: s * 0.65),
            math.pi,
            math.pi);
      case Zodiac.gemini:
        // Due verticali con archi sopra e sotto, i Gemelli.
        path.moveTo(g.dx - s * 0.45, g.dy - s * 0.6);
        path.lineTo(g.dx - s * 0.45, g.dy + s * 0.6);
        path.moveTo(g.dx + s * 0.45, g.dy - s * 0.6);
        path.lineTo(g.dx + s * 0.45, g.dy + s * 0.6);
        path.addArc(
            Rect.fromLTRB(g.dx - s * 0.6, g.dy - s * 0.85, g.dx + s * 0.6,
                g.dy - s * 0.45),
            math.pi,
            math.pi);
        path.addArc(
            Rect.fromLTRB(g.dx - s * 0.6, g.dy + s * 0.45, g.dx + s * 0.6,
                g.dy + s * 0.85),
            0,
            math.pi);
      case Zodiac.cancer:
        // Due spirali contrapposte, come 69.
        canvas.drawCircle(
            Offset(g.dx - s * 0.35, g.dy - s * 0.28), s * 0.2, paint);
        canvas.drawCircle(
            Offset(g.dx + s * 0.35, g.dy + s * 0.28), s * 0.2, paint);
        path.addArc(
            Rect.fromCircle(
                center: Offset(g.dx - s * 0.05, g.dy - s * 0.28),
                radius: s * 0.55),
            math.pi * 0.9,
            math.pi * 1.05);
        path.addArc(
            Rect.fromCircle(
                center: Offset(g.dx + s * 0.05, g.dy + s * 0.28),
                radius: s * 0.55),
            -math.pi * 0.1,
            math.pi * 1.05);
      case Zodiac.leo:
        // Cerchietto col codino che si arriccia, il Leone.
        canvas.drawCircle(
            Offset(g.dx - s * 0.35, g.dy + s * 0.3), s * 0.32, paint);
        path.moveTo(g.dx - s * 0.05, g.dy + s * 0.3);
        path.cubicTo(g.dx + s * 0.2, g.dy - s * 0.2, g.dx - s * 0.2,
            g.dy - s * 0.9, g.dx + s * 0.25, g.dy - s * 0.75);
        path.cubicTo(g.dx + s * 0.6, g.dy - s * 0.6, g.dx + s * 0.7,
            g.dy - s * 0.1, g.dx + s * 0.55, g.dy + s * 0.35);
      case Zodiac.virgo:
        // Una M con l'ultima gamba che si chiude in un cappio, la Vergine.
        path.moveTo(g.dx - s * 0.7, g.dy + s * 0.7);
        path.lineTo(g.dx - s * 0.7, g.dy - s * 0.6);
        path.lineTo(g.dx - s * 0.3, g.dy + s * 0.5);
        path.lineTo(g.dx - s * 0.3, g.dy - s * 0.6);
        path.lineTo(g.dx + s * 0.1, g.dy + s * 0.5);
        path.lineTo(g.dx + s * 0.1, g.dy - s * 0.6);
        path.lineTo(g.dx + s * 0.5, g.dy + s * 0.4);
        path.addArc(
            Rect.fromCircle(
                center: Offset(g.dx + s * 0.45, g.dy + s * 0.1),
                radius: s * 0.35),
            math.pi * 0.5,
            math.pi * 1.4);
      case Zodiac.libra:
        // Barra con un piccolo arco sopra: la Bilancia.
        path.moveTo(g.dx - s * 0.75, g.dy + s * 0.55);
        path.lineTo(g.dx + s * 0.75, g.dy + s * 0.55);
        path.moveTo(g.dx - s * 0.75, g.dy + s * 0.1);
        path.lineTo(g.dx - s * 0.2, g.dy + s * 0.1);
        path.addArc(
            Rect.fromLTRB(g.dx - s * 0.2, g.dy - s * 0.35, g.dx + s * 0.2,
                g.dy + s * 0.15),
            math.pi,
            math.pi);
        path.moveTo(g.dx + s * 0.2, g.dy + s * 0.1);
        path.lineTo(g.dx + s * 0.75, g.dy + s * 0.1);
      case Zodiac.scorpio:
        // Una M con la coda a freccia, lo Scorpione.
        path.moveTo(g.dx - s * 0.7, g.dy + s * 0.6);
        path.lineTo(g.dx - s * 0.7, g.dy - s * 0.6);
        path.lineTo(g.dx - s * 0.3, g.dy + s * 0.5);
        path.lineTo(g.dx - s * 0.3, g.dy - s * 0.6);
        path.lineTo(g.dx + s * 0.1, g.dy + s * 0.5);
        path.lineTo(g.dx + s * 0.1, g.dy - s * 0.6);
        path.lineTo(g.dx + s * 0.55, g.dy + s * 0.5);
        // Punta di freccia.
        path.moveTo(g.dx + s * 0.55, g.dy + s * 0.5);
        path.lineTo(g.dx + s * 0.75, g.dy + s * 0.2);
        path.moveTo(g.dx + s * 0.55, g.dy + s * 0.5);
        path.lineTo(g.dx + s * 0.3, g.dy + s * 0.35);
      case Zodiac.sagittarius:
        // Freccia in diagonale con la traversa, il Sagittario.
        path.moveTo(g.dx - s * 0.6, g.dy + s * 0.6);
        path.lineTo(g.dx + s * 0.6, g.dy - s * 0.6);
        path.moveTo(g.dx + s * 0.6, g.dy - s * 0.6);
        path.lineTo(g.dx + s * 0.15, g.dy - s * 0.6);
        path.moveTo(g.dx + s * 0.6, g.dy - s * 0.6);
        path.lineTo(g.dx + s * 0.6, g.dy - s * 0.15);
        path.moveTo(g.dx - s * 0.05, g.dy + s * 0.05);
        path.lineTo(g.dx - s * 0.4, g.dy - s * 0.05);
      case Zodiac.capricorn:
        // Cappio e coda, stilizzazione del Capricorno.
        path.moveTo(g.dx - s * 0.7, g.dy - s * 0.4);
        path.lineTo(g.dx - s * 0.15, g.dy + s * 0.5);
        path.moveTo(g.dx - s * 0.15, g.dy + s * 0.5);
        path.cubicTo(g.dx + s * 0.1, g.dy - s * 0.6, g.dx + s * 0.5,
            g.dy - s * 0.5, g.dx + s * 0.45, g.dy - s * 0.05);
        canvas.drawCircle(
            Offset(g.dx + s * 0.25, g.dy + s * 0.35), s * 0.28, paint);
      case Zodiac.aquarius:
        // Due onde parallele, l'Acquario.
        for (final dy in [-s * 0.28, s * 0.28]) {
          path.moveTo(g.dx - s * 0.75, g.dy + dy);
          path.lineTo(g.dx - s * 0.4, g.dy + dy - s * 0.22);
          path.lineTo(g.dx - s * 0.05, g.dy + dy);
          path.lineTo(g.dx + s * 0.3, g.dy + dy - s * 0.22);
          path.lineTo(g.dx + s * 0.65, g.dy + dy);
        }
      case Zodiac.pisces:
        // Due archi uniti da una traversa, i Pesci.
        path.addArc(
            Rect.fromLTRB(
                g.dx - s * 0.9, g.dy - s * 0.7, g.dx - s * 0.1, g.dy + s * 0.7),
            -math.pi / 2,
            math.pi);
        path.addArc(
            Rect.fromLTRB(
                g.dx + s * 0.1, g.dy - s * 0.7, g.dx + s * 0.9, g.dy + s * 0.7),
            math.pi / 2,
            math.pi);
        path.moveTo(g.dx - s * 0.5, g.dy);
        path.lineTo(g.dx + s * 0.5, g.dy);
    }
    canvas.drawPath(path, paint);
  }
}
