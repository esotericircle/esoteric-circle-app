import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/quality/quality_tier.dart';
import '../theme/maestro_scope.dart';
import 'starfield.dart';

/// Sfondo immersivo full-bleed nella palette del Maestro attivo.
///
/// Poiche' legge `context.palette` (interpolata durante la transizione),
/// lo sfondo sfuma con continuita' al cambio di Maestro. Sopra il gradiente
/// c'e' un cielo stellato dorato la cui densita' dipende dal Quality Tier, e
/// un alone radiale tenue del colore del Maestro nella parte alta.
///
/// Lo spazio scuro centrale e inferiore lascia respiro all'interfaccia,
/// coerente con lo stile pittorico atmosferico degli sfondi dei Maestri.
class GradientBackground extends StatelessWidget {
  const GradientBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final quality = context.watch<QualityTierController>();

    return Stack(
      children: [
        // Gradiente di fondo.
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: palette.backgroundGradient,
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),
        // Alone luminoso del Maestro in alto.
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.85),
                radius: 1.1,
                colors: [
                  palette.glow.withValues(alpha: quality.richEffects ? 0.28 : 0.16),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // Cielo stellato.
        Positioned.fill(
          child: Starfield(
            starCount: quality.starDensity,
            color: palette.goldSoft,
          ),
        ),
        child,
      ],
    );
  }
}
