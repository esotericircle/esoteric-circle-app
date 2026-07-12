import 'package:flutter/material.dart';

import '../../../../core/maestro/maestro.dart';
import '../../../../design_system/theme/maestro_palette.dart';
import '../../../../design_system/theme/maestro_scope.dart';
import '../../../../design_system/tokens/color_tokens.dart';
import '../../../../design_system/tokens/spacing_tokens.dart';
import '../../../../design_system/tokens/typography_tokens.dart';
import '../../widgets/maestro_presence.dart';

/// Apertura della chat prima del primo messaggio.
///
/// Immersione a riposo: il Maestro col mezzo busto piu' grande in alto, con la
/// sola animazione idle di respiro (segnaposto), un invito caldo e alcuni chip
/// di avvio al centro. Al primo messaggio tutto questo sparisce e il busto si
/// rimpicciolisce nell'avatar dell'header. Il livello visivo arriva prima del
/// testo, come vuole la legge del visivo.
class ChatEmptyState extends StatelessWidget {
  const ChatEmptyState({
    super.key,
    required this.maestro,
    required this.greeting,
    required this.starters,
    required this.onStarter,
    this.enabled = true,
  });

  final Maestro maestro;
  final String greeting;
  final List<String> starters;
  final ValueChanged<String> onStarter;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.lg,
        vertical: SpacingTokens.lg,
      ),
      child: Column(
        children: [
          // Mezzo busto piu' grande, respiro idle come segnaposto.
          MaestroPresence(maestro: maestro, height: 280),
          const SizedBox(height: SpacingTokens.md),
          Text(
            greeting,
            textAlign: TextAlign.center,
            style: TypographyTokens.body(size: 18).copyWith(
              color: ColorTokens.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: SpacingTokens.lg),
          Opacity(
            opacity: enabled ? 1.0 : 0.4,
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: SpacingTokens.xs,
              runSpacing: SpacingTokens.xs,
              children: [
                for (final s in starters)
                  _StarterChip(
                    label: s,
                    onTap: enabled ? () => onStarter(s) : null,
                    palette: palette,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StarterChip extends StatelessWidget {
  const _StarterChip({
    required this.label,
    required this.onTap,
    required this.palette,
  });

  final String label;
  final VoidCallback? onTap;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.md,
          vertical: SpacingTokens.xs,
        ),
        decoration: BoxDecoration(
          color: palette.surface.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
          border: Border.all(color: palette.gold.withValues(alpha: 0.35)),
        ),
        child: Text(
          label,
          style: TypographyTokens.body(size: 15)
              .copyWith(color: palette.goldSoft),
        ),
      ),
    );
  }
}
