import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/maestro/maestro.dart';
import '../../../design_system/theme/maestro_palette.dart';
import '../../../design_system/theme/maestro_scope.dart';
import '../../../design_system/tokens/color_tokens.dart';
import '../../../design_system/tokens/spacing_tokens.dart';
import '../../../design_system/tokens/typography_tokens.dart';
import '../../shell/navigation_controller.dart';

/// Tre riquadri per scegliere il Maestro direttamente dalla Home.
///
/// Toccarne uno naviga alla sua sezione e cambia il tema con la dissolvenza
/// cromatica. Il riquadro del Maestro attivo e' evidenziato.
class MaestroSelector extends StatelessWidget {
  const MaestroSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavigationController>();
    return Row(
      children: [
        for (final maestro in Maestro.fixedOrder) ...[
          Expanded(
            child: _MaestroChip(
              maestro: maestro,
              selected: nav.current == AppDestination.forMaestro(maestro),
              onTap: () =>
                  nav.goTo(AppDestination.forMaestro(maestro)),
            ),
          ),
          if (maestro != Maestro.fixedOrder.last)
            const SizedBox(width: SpacingTokens.sm),
        ],
      ],
    );
  }
}

class _MaestroChip extends StatelessWidget {
  const _MaestroChip({
    required this.maestro,
    required this.selected,
    required this.onTap,
  });

  final Maestro maestro;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Ogni riquadro mostra il proprio colore, cosi' i tre temi sono leggibili
    // a colpo d'occhio anche quando il tema globale e' un altro.
    final own = MaestroPalette.forKey(ThemeKey.of(maestro));
    final active = context.palette;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(
          vertical: SpacingTokens.md,
          horizontal: SpacingTokens.xs,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [own.surfaceElevated, own.deepest],
          ),
          borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
          border: Border.all(
            color: selected
                ? active.gold
                : own.gold.withValues(alpha: 0.25),
            width: selected ? 1.6 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: own.glow.withValues(alpha: 0.5),
                    blurRadius: 20,
                    spreadRadius: -4,
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(maestro.icon, color: own.goldSoft, size: 30),
            const SizedBox(height: SpacingTokens.xs),
            Text(
              maestro.displayName,
              style: TypographyTokens.display(size: 16),
            ),
            const SizedBox(height: 2),
            Text(
              maestro.domainTitle,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TypographyTokens.body(size: 11)
                  .copyWith(color: ColorTokens.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
