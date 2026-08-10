import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/astro/zodiac.dart';
import '../../../core/astro/zodiac_controller.dart';
import '../../../core/entitlement/entitlement_service.dart';
import '../../../core/entitlement/tier.dart';
import '../../../core/quality/quality_tier.dart';
import '../../../design_system/theme/maestro_scope.dart';
import '../../../design_system/tokens/color_tokens.dart';
import '../../../design_system/tokens/spacing_tokens.dart';
import '../../../design_system/tokens/typography_tokens.dart';

/// Pannello dimostrativo per il checkpoint C1.
///
/// Permette a Mauro di cambiare in tempo reale il tier dell'utente (per vedere
/// le funzioni premium sbloccarsi) e il Quality Tier (per vedere gli effetti
/// grafici degradare). Non fa parte dell'esperienza utente finale: e' uno
/// strumento di revisione. In produzione il tier arrivera' dallo stato reale
/// di abbonamento.
Future<void> showDemoControls(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => const _DemoControlsSheet(),
  );
}

class _DemoControlsSheet extends StatelessWidget {
  const _DemoControlsSheet();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final entitlement = context.watch<EntitlementService>();
    final quality = context.watch<QualityTierController>();
    final zodiac = context.watch<ZodiacController>();

    return Container(
      padding: EdgeInsets.only(
        left: SpacingTokens.lg,
        right: SpacingTokens.lg,
        top: SpacingTokens.lg,
        bottom: SpacingTokens.xl + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [palette.surfaceElevated, palette.deepest],
        ),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(SpacingTokens.radiusXl),
        ),
        border: Border.all(color: palette.gold.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: palette.gold.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
              ),
            ),
          ),
          const SizedBox(height: SpacingTokens.lg),
          Text('Controlli dimostrativi',
              style: TypographyTokens.display(size: 20)),
          const SizedBox(height: SpacingTokens.xxs),
          Text(
            'Strumento di revisione del checkpoint, non visibile in produzione.',
            style: TypographyTokens.corpo()
                .copyWith(color: ColorTokens.textSecondary),
          ),
          const SizedBox(height: SpacingTokens.lg),
          Text('Tier utente (sblocca le funzioni premium)',
              style: TypographyTokens.corpo(weight: 600)),
          const SizedBox(height: SpacingTokens.xs),
          Wrap(
            spacing: SpacingTokens.xs,
            children: [
              for (final tier in Tier.values)
                _Choice(
                  label: tier.label,
                  selected: entitlement.tier == tier,
                  onTap: () => entitlement.setTier(tier),
                ),
            ],
          ),
          const SizedBox(height: SpacingTokens.lg),
          Text('Quality Tier (degradazione degli effetti)',
              style: TypographyTokens.corpo(weight: 600)),
          const SizedBox(height: SpacingTokens.xs),
          Wrap(
            spacing: SpacingTokens.xs,
            children: [
              for (final q in QualityTier.values)
                _Choice(
                  label: q.name,
                  selected: quality.tier == q,
                  onTap: () => quality.setTier(q),
                ),
            ],
          ),
          const SizedBox(height: SpacingTokens.lg),
          Text('Segno solare (evidenzia la costellazione nel cosmo)',
              style: TypographyTokens.corpo(weight: 600)),
          const SizedBox(height: SpacingTokens.xs),
          Wrap(
            spacing: SpacingTokens.xs,
            runSpacing: SpacingTokens.xs,
            children: [
              _Choice(
                label: 'Nessuno',
                selected: zodiac.sunSign == null,
                onTap: () => zodiac.setSunSign(null),
              ),
              for (final sign in Zodiac.values)
                _Choice(
                  label: '${sign.symbol} ${sign.italianName}',
                  selected: zodiac.sunSign == sign,
                  onTap: () => zodiac.setSunSign(sign),
                ),
            ],
          ),
          const SizedBox(height: SpacingTokens.lg),
        ],
      ),
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.md,
          vertical: SpacingTokens.xs,
        ),
        decoration: BoxDecoration(
          color: selected
              ? palette.gold.withValues(alpha: 0.2)
              : ColorTokens.glassTint,
          borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
          border: Border.all(
            color: selected
                ? palette.gold
                : ColorTokens.glassStroke,
          ),
        ),
        child: Text(
          label,
          style: TypographyTokens.corpo(weight: 600)
              .copyWith(
            color: selected ? palette.goldSoft : ColorTokens.textSecondary,
          ),
        ),
      ),
    );
  }
}
