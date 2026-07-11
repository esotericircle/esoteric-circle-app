import 'package:flutter/material.dart';

import '../../../../core/maestro/maestro.dart';
import '../../../../design_system/theme/maestro_palette.dart';
import '../../../../design_system/theme/maestro_scope.dart';
import '../../../../design_system/tokens/color_tokens.dart';
import '../../../../design_system/tokens/spacing_tokens.dart';
import '../../../../design_system/tokens/typography_tokens.dart';
import '../../widgets/maestro_presence.dart';

/// Apertura della chat prima del primo messaggio: la presenza del Maestro con
/// la sua aura, un invito caldo e alcuni spunti toccabili. Il livello visivo
/// arriva prima del testo, come vuole la legge del visivo.
class ChatEmptyState extends StatelessWidget {
  const ChatEmptyState({
    super.key,
    required this.maestro,
    required this.greeting,
    required this.suggestions,
    required this.onSuggestion,
  });

  final Maestro maestro;
  final String greeting;
  final List<String> suggestions;
  final ValueChanged<String> onSuggestion;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.lg,
        vertical: SpacingTokens.xl,
      ),
      child: Column(
        children: [
          MaestroPresence(maestro: maestro, height: 190),
          const SizedBox(height: SpacingTokens.lg),
          Text(
            greeting,
            textAlign: TextAlign.center,
            style: TypographyTokens.body(size: 18).copyWith(
              color: ColorTokens.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: SpacingTokens.xl),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: SpacingTokens.xs,
            runSpacing: SpacingTokens.xs,
            children: [
              for (final s in suggestions)
                _SuggestionChip(
                  label: s,
                  onTap: () => onSuggestion(s),
                  palette: palette,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({
    required this.label,
    required this.onTap,
    required this.palette,
  });

  final String label;
  final VoidCallback onTap;
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
