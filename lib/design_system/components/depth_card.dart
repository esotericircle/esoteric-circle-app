import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/quality/quality_tier.dart';
import '../tokens/color_tokens.dart';
import '../tokens/elevation_tokens.dart';
import '../tokens/spacing_tokens.dart';
import '../theme/maestro_scope.dart';
import 'package:provider/provider.dart';

import 'scroll_reveal.dart';
import '../theme/maestro_palette.dart';

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
    this.reveal = true,
    this.palette,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool raised;
  final BorderRadius? borderRadius;

  /// Opacita' complessiva, usata per lo stato Coming soon.
  final double opacity;

  /// La tavolozza da usare, quando la card non deve seguire il tema attivo.
  ///
  /// Serve alle tessere che appartengono a un Maestro diverso da quello in
  /// scena: senza questo la card leggeva sempre `context.palette`, quindi tutte
  /// le tessere uscivano nel colore del tema, cioe' tutte blu quando il tema era
  /// di Medora, mentre l'emblema al loro interno portava il colore giusto. Un
  /// dettaglio nel colore del proprietario dentro una card nel colore di un
  /// altro non fa riconoscere niente.
  final MaestroPalette? palette;

  /// La comparsa in scorrimento vive QUI, nel componente che ogni elenco
  /// dell'app gia' usa: cosi' vale ovunque senza che ogni schermata debba
  /// ricordarsene, e chi ha una regia propria la spegne con [reveal] falso.
  /// Fuori da uno scorrimento la card si rivela al montaggio, senza attese.
  final bool reveal;

  @override
  Widget build(BuildContext context) {
    final palette = this.palette ?? context.palette;
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

    if (!reveal) return card;
    return ScrollReveal(child: card);
  }
}
