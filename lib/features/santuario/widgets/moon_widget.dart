import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/astro/moon_phase.dart';

/// La Luna del Santuario, in alto, nella sua fase reale attuale.
///
/// Slot pronto per la grafica reale: quando l'asset [imageAsset] esiste, la Luna
/// e' quella foto; sopra ci va uno strato di oscuramento in trasparenza che
/// copre la porzione non illuminata secondo la fase corrente, cosi' la stessa
/// immagine rende ogni fase. In attesa dell'immagine, un ripiego dipinto (un
/// disco lunare tenue, mai una sfera grigia piatta) tiene la scena viva.
class MoonWidget extends StatelessWidget {
  const MoonWidget({
    super.key,
    required this.phase,
    this.size = 96,
    this.glowColor = const Color(0xFFF4F1E8),
    this.imageAsset = 'brand_assets/santuario/moon.png',
  });

  /// Fase corrente, oppure null per la Luna neutra di ripiego.
  final MoonPhase? phase;
  final double size;
  final Color glowColor;

  /// L'immagine reale della Luna. Se manca (asset non ancora fornito) si ripiega
  /// sul disco dipinto, senza errori a schermo.
  final String imageAsset;

  @override
  Widget build(BuildContext context) {
    // L'alone occupa un'area piu' ampia del disco; il disco sta al centro.
    // Footprint contenuto, cosi' non lascia troppo vuoto attorno alla Luna.
    final area = size * 1.5;
    return SizedBox(
      width: area,
      height: area,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Alone diffuso che illumina la parte alta della scena.
          CustomPaint(
            size: Size(area, area),
            painter: _MoonGlowPainter(glow: glowColor),
          ),
          // Il disco: immagine reale se c'e', altrimenti il ripiego dipinto.
          SizedBox(
            width: size,
            height: size,
            child: ClipOval(
              child: Image.asset(
                imageAsset,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    CustomPaint(painter: _MoonDiscFallbackPainter(glow: glowColor)),
              ),
            ),
          ),
          // Ombra della fase: copre in trasparenza la porzione non illuminata,
          // modellata sul terminatore. Piu' l'immagine reale, questa da' la fase.
          SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: _MoonPhaseShadowPainter(phase: phase, glow: glowColor),
            ),
          ),
        ],
      ),
    );
  }
}

/// L'alone morbido attorno alla Luna.
class _MoonGlowPainter extends CustomPainter {
  _MoonGlowPainter({required this.glow});

  final Color glow;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          glow.withValues(alpha: 0.26),
          glow.withValues(alpha: 0.07),
          Colors.transparent,
        ],
        stops: const [0.0, 0.42, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: size.width / 2));
    canvas.drawCircle(center, size.width / 2, glowPaint);
  }

  @override
  bool shouldRepaint(_MoonGlowPainter old) => old.glow != glow;
}

/// Ripiego dipinto del disco quando l'immagine reale non c'e': un disco lunare
/// sfumato, con un accenno di rilievo, non una sfera grigia piatta.
class _MoonDiscFallbackPainter extends CustomPainter {
  _MoonDiscFallbackPainter({required this.glow});

  final Color glow;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.width / 2;
    // Sfumatura sferica: piu' chiara verso l'alto a sinistra, come una luce
    // radente, cosi' il disco ha volume invece di essere piatto.
    final disc = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.35, -0.35),
        radius: 1.1,
        colors: [
          Colors.white,
          Color.lerp(Colors.white, glow, 0.55)!,
          Color.lerp(glow, const Color(0xFF20242E), 0.5)!,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: r));
    canvas.drawCircle(center, r, disc);

    // Qualche mare lunare appena accennato, per non sembrare una palla liscia.
    final rng = math.Random(11);
    final seaPaint = Paint()..color = glow.withValues(alpha: 0.10);
    for (var i = 0; i < 5; i++) {
      final a = rng.nextDouble() * 2 * math.pi;
      final d = rng.nextDouble() * r * 0.6;
      final rr = r * (0.08 + rng.nextDouble() * 0.12);
      canvas.drawCircle(
          center + Offset(math.cos(a) * d, math.sin(a) * d), rr, seaPaint);
    }
  }

  @override
  bool shouldRepaint(_MoonDiscFallbackPainter old) => old.glow != glow;
}

/// Lo strato di oscuramento della fase: copre in trasparenza la parte non
/// illuminata della Luna, con il bordo modellato sul terminatore. Nuova Luna
/// quasi tutta in ombra, Luna piena senza ombra.
class _MoonPhaseShadowPainter extends CustomPainter {
  _MoonPhaseShadowPainter({required this.phase, required this.glow});

  final MoonPhase? phase;
  final Color glow;

  /// L'ombra e' scura ma trasparente: vela la porzione non illuminata senza
  /// cancellarla del tutto, cosi' l'immagine reale (o il disco di ripiego)
  /// resta intuibile, come la luce cinerea che non lascia mai la Luna nera.
  static const Color _shadow = Color(0xAA0A0D18);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.width / 2;

    final p = phase;
    // Bordo tenue del disco, sempre, per staccarlo dal cielo.
    void rim() {
      canvas.drawCircle(
        center,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = glow.withValues(alpha: 0.45),
      );
    }

    if (p == null) {
      rim();
      return;
    }

    final circle = Path()..addOval(Rect.fromCircle(center: center, radius: r));

    if (p.illumination < 0.01) {
      // Luna nuova: ombra su quasi tutto il disco.
      canvas.drawPath(circle, Paint()..color = _shadow);
      rim();
      return;
    }
    if (p.illumination > 0.99) {
      // Luna piena: nessuna ombra.
      rim();
      return;
    }

    final f = p.fraction;
    final waxing = p.waxing;
    final gibbous = p.illumination > 0.5;
    final rx = math.cos(2 * math.pi * f).abs() * r;
    final top = Offset(center.dx, center.dy - r);
    final bottom = Offset(center.dx, center.dy + r);
    final termClockwise = gibbous ? waxing : !waxing;

    // La porzione illuminata, la stessa geometria del terminatore.
    final lit = Path()
      ..moveTo(top.dx, top.dy)
      ..arcToPoint(bottom, radius: Radius.circular(r), clockwise: waxing)
      ..arcToPoint(top,
          radius: Radius.elliptical(rx, r), clockwise: termClockwise)
      ..close();

    // L'ombra e' il disco meno la porzione illuminata.
    final shadow = Path.combine(PathOperation.difference, circle, lit);
    canvas.drawPath(shadow, Paint()..color = _shadow);
    rim();
  }

  @override
  bool shouldRepaint(_MoonPhaseShadowPainter old) =>
      old.phase?.fraction != phase?.fraction ||
      old.phase?.illumination != phase?.illumination ||
      old.glow != glow;
}
