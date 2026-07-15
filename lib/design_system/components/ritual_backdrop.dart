import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/quality/quality_tier.dart';
import '../theme/maestro_palette.dart';

/// Slot di fondale condiviso dei cinque rituali quotidiani.
///
/// Un solo componente parametrico, usato da tutti e cinque gli screen (alba,
/// soffio, oracolo, runa del tramonto, buonanotte). Accetta il percorso di un
/// asset PNG di fondale: quando c'e', lo rende full-bleed; quando manca, o non
/// si carica, rende un fondo procedurale coerente col cosmo della home, stesso
/// linguaggio di [CosmosBackground], nebulose fredde e campo stellare per
/// Quality Tier, con la tinta del Maestro dell'elemento come accento e una
/// parallasse leggera fermata da Riduci Movimento.
///
/// Obiettivo: quando arriveranno i PNG definitivi basta cablarli nello slot
/// [assetPath], senza toccare altro.
///
/// La tinta viene dalla [palette] passata dallo screen, cioe' quella
/// dell'elemento del rito, non da `context.palette`: nei riti alba e
/// buonanotte il Maestro ruota col giorno e non coincide con quello attivo
/// nello shell.
class RitualBackdrop extends StatelessWidget {
  const RitualBackdrop({
    super.key,
    required this.palette,
    required this.child,
    this.assetPath,
  });

  /// Palette dell'elemento del rito, per la tinta dell'accento.
  final MaestroPalette palette;

  /// Percorso dell'asset PNG di fondale, quando disponibile. Null, o asset non
  /// caricabile, ripiega sul fondo procedurale.
  final String? assetPath;

  /// Contenuto del rito, disegnato sopra il fondale.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final path = assetPath;
    if (path != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            path,
            fit: BoxFit.cover,
            // Se il PNG manca o non si decodifica, non si resta con un buco:
            // si ripiega sul fondo procedurale, stesso slot, stessa tinta.
            errorBuilder: (context, error, stack) =>
                _ProceduralBackdrop(palette: palette),
          ),
          child,
        ],
      );
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        _ProceduralBackdrop(palette: palette),
        child,
      ],
    );
  }
}

/// Il fondo procedurale: cielo tinto, nebulose fredde e campo stellare, regolati
/// dal Quality Tier, con una deriva lenta come parallasse leggera. Non dipende
/// da alcun provider obbligatorio: il Quality Tier si legge se presente, altrimenti
/// si assume medio, cosi' lo slot rende anche montato da solo in un test.
class _ProceduralBackdrop extends StatefulWidget {
  const _ProceduralBackdrop({required this.palette});

  final MaestroPalette palette;

  @override
  State<_ProceduralBackdrop> createState() => _ProceduralBackdropState();
}

class _ProceduralBackdropState extends State<_ProceduralBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Un unico ciclo lungo governa pulsazione e deriva, come nel cosmo della home.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Quality Tier senza dipendenza obbligatoria: se il provider c'e' si usa, cosi'
  // il fondale segue l'interruttore di qualita' dell'app; altrimenti medio.
  QualityTier _tier(BuildContext context) {
    try {
      return Provider.of<QualityTierController>(context).tier;
    } catch (_) {
      return QualityTier.medium;
    }
  }

  @override
  Widget build(BuildContext context) {
    final quality = _tier(context);
    // Riduci Movimento: fondale fermo, nessuna deriva.
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    if (quality == QualityTier.low || reduceMotion) {
      if (_controller.isAnimating) _controller.stop();
    } else {
      if (!_controller.isAnimating) _controller.repeat();
    }

    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size.infinite,
          painter: _BackdropPainter(
            animation: _controller,
            palette: widget.palette,
            tier: quality,
            reduceMotion: reduceMotion,
          ),
        ),
      ),
    );
  }
}

class _BackdropPainter extends CustomPainter {
  _BackdropPainter({
    required this.animation,
    required this.palette,
    required this.tier,
    required this.reduceMotion,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final MaestroPalette palette;
  final QualityTier tier;
  final bool reduceMotion;

  int get _fieldStars => switch (tier) {
        QualityTier.high => 70,
        QualityTier.medium => 40,
        QualityTier.low => 18,
      };
  int get _nebulaClusters => switch (tier) {
        QualityTier.high => 3,
        QualityTier.medium => 2,
        QualityTier.low => 0,
      };
  bool get _animate => tier != QualityTier.low && !reduceMotion;

  @override
  void paint(Canvas canvas, Size size) {
    final t = _animate ? animation.value : 0.0;
    final rect = Offset.zero & size;

    // Cielo di fondo, tinto verso l'accento del Maestro, come CosmosBackground.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            palette.deepest,
            Color.lerp(palette.deepest, palette.backgroundGradient[1], 0.6)!,
            palette.deepest,
          ],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(rect),
    );

    // Parallasse leggera: una deriva lenta e automatica dei due piani, ferma
    // sotto Riduci Movimento. Nessun giroscopio, cosi' il fondale vale anche
    // dove il sensore non c'e'.
    final drift = _animate ? math.sin(2 * math.pi * t) : 0.0;
    final farOff = Offset(drift * 6, -drift * 4);
    final midOff = Offset(drift * 12, -drift * 8);

    if (_nebulaClusters > 0) _paintNebula(canvas, size, midOff, t);
    _paintFieldStars(canvas, size, farOff, t);
    _paintElementGlow(canvas, size);
  }

  // Nebulose fredde, piano intermedio: grappoli morbidi tinti verso l'accento.
  void _paintNebula(Canvas canvas, Size size, Offset off, double t) {
    const centers = [
      Offset(0.24, 0.22),
      Offset(0.78, 0.46),
      Offset(0.5, 0.82),
    ];
    final drift = _animate ? math.sin(2 * math.pi * t) * 8 : 0.0;
    final blur = tier == QualityTier.high ? 84.0 : 44.0;
    final rng = math.Random(53);

    for (var i = 0; i < _nebulaClusters; i++) {
      final base =
          Offset(centers[i].dx * size.width, centers[i].dy * size.height) +
              off +
              Offset(drift, -drift);
      const blobs = 4;
      for (var b = 0; b < blobs; b++) {
        final dx = (rng.nextDouble() - 0.5) * size.width * 0.28;
        final dy = (rng.nextDouble() - 0.5) * size.height * 0.14;
        final radius = size.width * (0.16 + rng.nextDouble() * 0.22);
        final color = b.isEven ? palette.primary : palette.glow;
        canvas.drawCircle(
          base + Offset(dx, dy),
          radius,
          Paint()
            ..color = color.withValues(alpha: 0.10 + rng.nextDouble() * 0.05)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur),
        );
      }
    }
  }

  // Campo di stelle bianche con pulsazione dolce.
  void _paintFieldStars(Canvas canvas, Size size, Offset off, double t) {
    final rng = math.Random(7);
    final paint = Paint()..style = PaintingStyle.fill;
    for (var i = 0; i < _fieldStars; i++) {
      final x = rng.nextDouble();
      final y = rng.nextDouble();
      final radius = 0.6 + rng.nextDouble() * 1.8;
      final phase = rng.nextDouble();
      final baseAlpha = 0.3 + rng.nextDouble() * 0.6;
      final twinkle =
          _animate ? 0.5 + 0.5 * math.sin(2 * math.pi * (t * 6 + phase)) : 0.8;
      final alpha = (baseAlpha * (0.55 + 0.45 * twinkle)).clamp(0.0, 1.0);
      final center = Offset(x * size.width, y * size.height) + off;
      if (radius > 1.4) {
        canvas.drawCircle(
          center,
          radius * 2.6,
          Paint()
            ..color = const Color(0xFFFFFFFF).withValues(alpha: alpha * 0.25)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
        );
      }
      paint.color = const Color(0xFFFFFFFF).withValues(alpha: alpha);
      canvas.drawCircle(center, radius, paint);
    }
  }

  // Alone dell'elemento in alto, la tinta del Maestro come accento.
  void _paintElementGlow(Canvas canvas, Size size) {
    final alpha = tier == QualityTier.high ? 0.26 : 0.15;
    final center = Offset(size.width * 0.5, -size.height * 0.05);
    final radius = size.width * 1.15;
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = RadialGradient(
          colors: [
            palette.glow.withValues(alpha: alpha),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
  }

  @override
  bool shouldRepaint(_BackdropPainter old) =>
      old.palette != palette ||
      old.tier != tier ||
      old.reduceMotion != reduceMotion;
}
