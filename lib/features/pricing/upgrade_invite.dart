import 'package:flutter/material.dart';

import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import 'pricing_screen.dart';

/// Invito gentile all'upgrade, mai un vicolo cieco.
///
/// Quando un blocco premium si presenta (per esempio il limite giornaliero di
/// domande del Free), non si chiude una porta: si apre un invito elegante, con
/// la via ai piani. Restituisce true se l'utente e' andato ai piani.
Future<bool> showUpgradeInvite(
  BuildContext context, {
  required String title,
  required String message,
}) async {
  final palette = context.palette;
  final result = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => Container(
      key: const Key('upgrade_invite'),
      padding: const EdgeInsets.fromLTRB(SpacingTokens.lg, SpacingTokens.md,
          SpacingTokens.lg, SpacingTokens.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [palette.surfaceElevated, palette.deepest],
        ),
        borderRadius: const BorderRadius.vertical(
            top: Radius.circular(SpacingTokens.radiusXl)),
        border: Border.all(color: palette.gold.withValues(alpha: 0.3)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: palette.goldSoft, size: 22),
                const SizedBox(width: SpacingTokens.sm),
                Expanded(
                  child: Text(title,
                      style: TypographyTokens.display(size: 19)
                          .copyWith(color: palette.goldSoft)),
                ),
              ],
            ),
            const SizedBox(height: SpacingTokens.sm),
            Text(message,
                style: TypographyTokens.body(size: 15)
                    .copyWith(color: ColorTokens.textSecondary, height: 1.4)),
            const SizedBox(height: SpacingTokens.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(sheetContext).pop(false),
                  child: Text('Non ora',
                      style: TypographyTokens.label(size: 13)
                          .copyWith(color: ColorTokens.textSecondary)),
                ),
                const SizedBox(width: SpacingTokens.sm),
                TextButton(
                  key: const Key('upgrade_see_plans'),
                  onPressed: () => Navigator.of(sheetContext).pop(true),
                  child: Text('Vedi i piani',
                      style: TypographyTokens.label(size: 13)
                          .copyWith(color: palette.goldSoft)),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  if (result == true && context.mounted) {
    await Navigator.of(context).push(PricingScreen.route());
    return true;
  }
  return false;
}
