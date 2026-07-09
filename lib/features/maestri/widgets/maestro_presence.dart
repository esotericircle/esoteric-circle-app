import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/maestro/maestro.dart';
import '../../../core/quality/quality_tier.dart';
import '../../../design_system/theme/maestro_scope.dart';
import '../../../design_system/tokens/spacing_tokens.dart';

/// Presenza del Maestro attivo: il suo avatar reale con respiro lento e aura
/// che pulsa nel suo colore.
///
/// In idle l'avatar galleggia dolcemente e l'alone respira; su Quality Tier
/// basso il moto si ferma e resta la presenza statica. Se l'immagine non e'
/// disponibile, si ripiega sull'icona lineare del Maestro.
class MaestroPresence extends StatefulWidget {
  const MaestroPresence({
    super.key,
    required this.maestro,
    this.height = 260,
  });

  final Maestro maestro;
  final double height;

  @override
  State<MaestroPresence> createState() => _MaestroPresenceState();
}

class _MaestroPresenceState extends State<MaestroPresence>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final tier = context.watch<QualityTierController>().tier;
    final animate = tier != QualityTier.low;

    if (animate && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!animate && _controller.isAnimating) {
      _controller.stop();
    }

    return SizedBox(
      height: widget.height,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final phase = _controller.value * 2 * math.pi;
          final floatY = animate ? math.sin(phase) * 6 : 0.0;
          final auraPulse = animate ? 0.5 + 0.5 * math.sin(phase) : 0.6;

          return Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // Aura che pulsa nel colore del Maestro.
              Center(
                child: Container(
                  width: widget.height * 0.9,
                  height: widget.height * 0.9,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        palette.glow.withValues(alpha: 0.10 + 0.22 * auraPulse),
                        palette.primary.withValues(alpha: 0.10),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),
              // Avatar galleggiante.
              Transform.translate(
                offset: Offset(0, floatY),
                child: child,
              ),
            ],
          );
        },
        child: _Avatar(maestro: widget.maestro, height: widget.height),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.maestro, required this.height});

  final Maestro maestro;
  final double height;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Image.asset(
      maestro.avatarAsset,
      height: height,
      fit: BoxFit.contain,
      alignment: Alignment.bottomCenter,
      errorBuilder: (context, error, stack) {
        // Fallback: icona lineare dorata dentro un cerchio.
        return Container(
          width: height * 0.5,
          height: height * 0.5,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: palette.primary.withValues(alpha: 0.4),
            border: Border.all(
              color: palette.gold.withValues(alpha: 0.6),
              width: 1.4,
            ),
          ),
          child: Icon(maestro.icon,
              color: palette.goldSoft, size: height * 0.2),
        );
      },
    );
  }
}

/// Variante compatta per il Santuario neutro: invito alla scelta del Maestro,
/// senza un avatar specifico.
class SantuarioPresence extends StatelessWidget {
  const SantuarioPresence({super.key, this.height = 180});

  final double height;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return SizedBox(
      height: height,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.brightness_3, color: palette.goldSoft, size: 44),
            const SizedBox(height: SpacingTokens.sm),
            Text(
              'Il cerchio ti attende',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      ),
    );
  }
}
