import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/maestro/maestro.dart';
import '../../../design_system/theme/maestro_palette.dart';
import '../../../design_system/tokens/spacing_tokens.dart';

/// Un busto del Maestro sul palco del Santuario: la figura in una cornice a
/// carta, con la testa che rompe il bordo superiore e l'aura nel suo colore.
///
/// Il busto centrale ([featured]) e' vivo, con respiro, galleggiamento e aura
/// che pulsa; i laterali sono quasi fermi e piu' sobri, arretrati ai lati.
/// L'animazione a stati e i saluti veri arrivano a C3. Rispetta Riduci Movimento
/// e il Quality Tier tramite [alive].
class MaestroBust extends StatefulWidget {
  const MaestroBust({
    super.key,
    required this.maestro,
    required this.palette,
    required this.featured,
    this.width = 200,
    this.alive = true,
  });

  final Maestro maestro;
  final MaestroPalette palette;
  final bool featured;

  /// Larghezza della cornice.
  final double width;

  /// Se false (Riduci Movimento o Quality Tier basso), niente moto continuo.
  final bool alive;

  @override
  State<MaestroBust> createState() => _MaestroBustState();
}

class _MaestroBustState extends State<MaestroBust>
    with SingleTickerProviderStateMixin {
  late final AnimationController _idle;

  @override
  void initState() {
    super.initState();
    _idle = AnimationController(
        vsync: this, duration: const Duration(seconds: 6));
    if (widget.alive && widget.featured) _idle.repeat();
  }

  @override
  void didUpdateWidget(MaestroBust old) {
    super.didUpdateWidget(old);
    final shouldRun = widget.alive && widget.featured;
    if (shouldRun && !_idle.isAnimating) {
      _idle.repeat();
    } else if (!shouldRun && _idle.isAnimating) {
      _idle.stop();
    }
  }

  @override
  void dispose() {
    _idle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.palette;
    final w = widget.width;
    final h = w * 1.42;
    return AnimatedBuilder(
      animation: _idle,
      builder: (context, _) {
        final phase = _idle.value * 2 * math.pi;
        final floatY = widget.featured ? math.sin(phase) * 5 : 0.0;
        final breath = widget.featured ? 1 + 0.01 * math.sin(phase) : 1.0;
        final auraPulse =
            widget.featured ? 0.5 + 0.5 * math.sin(phase) : 0.25;

        return Opacity(
          opacity: widget.featured ? 1 : 0.62,
          child: Transform.translate(
            offset: Offset(0, floatY),
            child: Transform.scale(
              scale: breath,
              child: SizedBox(
                width: w,
                height: h + 54, // spazio per la testa che esce
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.bottomCenter,
                  children: [
                    // Aura del Maestro.
                    Positioned(
                      bottom: 16,
                      child: Container(
                        width: w * 1.18,
                        height: w * 1.18,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              p.glow.withValues(
                                  alpha: (widget.featured ? 0.28 : 0.14) +
                                      0.18 * auraPulse),
                              p.primary.withValues(alpha: 0.08),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                    ),
                    // Cornice a carta.
                    Positioned(bottom: 0, child: _Frame(palette: p, width: w, height: h)),
                    // La figura, la testa rompe il bordo.
                    Positioned(
                      bottom: 6,
                      child: SizedBox(
                        height: h + 46,
                        child: Image.asset(
                          widget.maestro.avatarAsset,
                          fit: BoxFit.contain,
                          alignment: Alignment.bottomCenter,
                          errorBuilder: (_, __, ___) => Icon(
                            widget.maestro.icon,
                            size: w * 0.5,
                            color: p.goldSoft,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Frame extends StatelessWidget {
  const _Frame({required this.palette, required this.width, required this.height});
  final MaestroPalette palette;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [palette.surfaceElevated, palette.deepest],
        ),
        border: Border.all(color: palette.gold.withValues(alpha: 0.7), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
            border:
                Border.all(color: palette.gold.withValues(alpha: 0.3), width: 1),
          ),
        ),
      ),
    );
  }
}
