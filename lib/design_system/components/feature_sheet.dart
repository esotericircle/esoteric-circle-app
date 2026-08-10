import 'package:flutter/material.dart';

import '../../core/feature_flags/feature_flag.dart';
import '../theme/maestro_palette.dart';
import '../theme/maestro_scope.dart';
import '../tokens/color_tokens.dart';
import '../tokens/spacing_tokens.dart';
import '../tokens/typography_tokens.dart';

/// Mostra l'anticipo elegante (Coming soon) o l'invito all'upgrade (premium).
///
/// Al tocco di una funzione non attiva non compare mai un errore o un vicolo
/// cieco: si apre un foglio inferiore in tono, che spiega cosa arrivera' o
/// come sbloccare la funzione.
///
/// Riferimento: Linee Guida UX sezione 4 e 14, tooltip di sblocco.
Future<void> showFeatureSheet(
  BuildContext context, {
  required FeatureDefinition feature,
  required FeatureStatus status,
}) {
  final palette = context.palette;
  final bool isPremium = status == FeatureStatus.premiumLocked;

  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => _FeatureSheetContent(
      feature: feature,
      isPremium: isPremium,
      palette: palette,
    ),
  );
}

class _FeatureSheetContent extends StatelessWidget {
  const _FeatureSheetContent({
    required this.feature,
    required this.isPremium,
    required this.palette,
  });

  final FeatureDefinition feature;
  final bool isPremium;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
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
          Row(
            children: [
              Icon(
                isPremium ? Icons.lock_rounded : feature.icon,
                color: palette.goldSoft,
                size: 28,
              ),
              const SizedBox(width: SpacingTokens.sm),
              Expanded(
                child: Text(
                  feature.title,
                  style: TypographyTokens.display(size: 22),
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.md),
          Text(
            feature.teaser,
            style: TypographyTokens.body(size: 16)
                .copyWith(color: ColorTokens.textSecondary),
          ),
          const SizedBox(height: SpacingTokens.xl),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: palette.gold,
                foregroundColor: palette.deepest,
                padding: const EdgeInsets.symmetric(vertical: SpacingTokens.md),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(SpacingTokens.radiusPill),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                isPremium
                    ? 'Scopri l\'abbonamento (${feature.requiredTier.label})'
                    : 'Avvisami quando arriva',
                style: TypographyTokens.corpo(weight: 600)
                    .copyWith(color: palette.deepest),
              ),
            ),
          ),
          const SizedBox(height: SpacingTokens.sm),
          Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Chiudi',
                style: TypographyTokens.corpo()
                    .copyWith(color: ColorTokens.textMuted),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
