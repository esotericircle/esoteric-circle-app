import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/quality/quality_tier.dart';
import '../tokens/color_tokens.dart';
import '../tokens/elevation_tokens.dart';
import '../tokens/spacing_tokens.dart';
import '../theme/maestro_scope.dart';
import 'package:provider/provider.dart';

/// Superficie in vetro con profondita' 2.5D.
///
/// Combina i primitivi (colori della palette, ombre stratificate, raggi) in un
/// componente riutilizzabile: gradiente di superficie, bordo dorato tenue,
/// luce radente in alto, ombra scura in basso e alone colorato del Maestro.
/// Il blur del glassmorphism e' attivo solo con Quality Tier alto.
///
/// Riferimento: design system Materico 2.5D e glassmorphism per le card.
class DepthCard extends StatelessWidget {
  const DepthCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(SpacingTokens.md),
    this.onTap,
    this.raised = false,
    this.borderRadius,
    this.opacity = 1.0,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool raised;
  final BorderRadius? borderRadius;

  /// Opacita' complessiva, usata per lo stato Coming soon.
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final quality = context.watch<QualityTierController>();
    final radius =
        borderRadius ?? BorderRadius.circular(SpacingTokens.radiusLg);

    final shadows = raised
        ? ElevationTokens.raised(glow: palette.glow)
        : ElevationTokens.resting(glow: palette.glow);

    Widget surface = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            palette.surfaceElevated.withValues(alpha: 0.92),
            palette.surface.withValues(alpha: 0.78),
          ],
        ),
        border: Border.all(
          color: palette.gold.withValues(alpha: 0.28),
          width: 1,
        ),
        boxShadow: shadows,
      ),
      child: Stack(
        children: [
          // Luce radente superiore.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: radius.topLeft),
                gradient: const LinearGradient(
                  colors: [
                    Colors.transparent,
                    ElevationTokens.topHighlight,
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Padding(padding: padding, child: child),
        ],
      ),
    );

    if (quality.richEffects) {
      surface = ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: surface,
        ),
      );
    }

    Widget card = Opacity(opacity: opacity, child: surface);

    if (onTap != null) {
      card = Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          splashColor: palette.glow.withValues(alpha: 0.18),
          highlightColor: ColorTokens.glassTint,
          onTap: onTap,
          child: card,
        ),
      );
    }

    return card;
  }
}
