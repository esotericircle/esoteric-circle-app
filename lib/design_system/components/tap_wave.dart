import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/quality/quality_tier.dart';
import '../theme/maestro_scope.dart';

/// Propaga una leggera onda luminosa del colore del Maestro dal punto toccato.
///
/// Avvolge l'app: a ogni tocco nasce un anello che si espande e sfuma
/// nell'accento del Maestro attivo. E' un tocco di atmosfera, disattivato in
/// Quality Tier basso per non pesare sui device deboli.
class TapWaveLayer extends StatefulWidget {
  const TapWaveLayer({super.key, required this.child});

  final Widget child;

  @override
  State<TapWaveLayer> createState() => _TapWaveLayerState();
}

class _TapWaveLayerState extends State<TapWaveLayer>
    with TickerProviderStateMixin {
  final List<_Ripple> _ripples = [];

  void _spawn(Offset position, Color color) {
    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 720),
    );
    final ripple = _Ripple(position: position, color: color, controller: controller);
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _ripples.remove(ripple));
        controller.dispose();
      }
    });
    setState(() => _ripples.add(ripple));
    controller.forward();
  }

  @override
  void dispose() {
    for (final r in _ripples) {
      r.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tier = context.watch<QualityTierController>().tier;

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (event) {
        if (tier == QualityTier.low) return;
        _spawn(event.localPosition, context.palette.glow);
      },
      child: Stack(
        children: [
          widget.child,
          if (_ripples.isNotEmpty)
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: Listenable.merge(
                    _ripples.map((r) => r.controller).toList(),
                  ),
                  builder: (context, _) =>
                      CustomPaint(painter: _RipplePainter(_ripples)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Ripple {
  _Ripple({
    required this.position,
    required this.color,
    required this.controller,
  });

  final Offset position;
  final Color color;
  final AnimationController controller;
}

class _RipplePainter extends CustomPainter {
  _RipplePainter(this.ripples);

  final List<_Ripple> ripples;

  @override
  void paint(Canvas canvas, Size size) {
    for (final r in ripples) {
      final t = Curves.easeOut.transform(r.controller.value);
      final radius = 12 + t * 120;
      final fade = (1 - t).clamp(0.0, 1.0);

      // Alone morbido.
      canvas.drawCircle(
        r.position,
        radius,
        Paint()..color = r.color.withValues(alpha: 0.16 * fade),
      );
      // Anello luminoso.
      canvas.drawCircle(
        r.position,
        radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2 * fade
          ..color = r.color.withValues(alpha: 0.5 * fade),
      );
    }
  }

  @override
  bool shouldRepaint(_RipplePainter oldDelegate) => true;
}
