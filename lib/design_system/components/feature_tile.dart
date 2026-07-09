import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/feature_flags/feature_flag.dart';
import '../../core/feature_flags/feature_flag_service.dart';
import '../../core/quality/quality_tier.dart';
import '../theme/maestro_scope.dart';
import '../tokens/color_tokens.dart';
import '../tokens/spacing_tokens.dart';
import '../tokens/typography_tokens.dart';
import 'depth_card.dart';
import 'feature_sheet.dart';
import 'status_badge.dart';

/// Tessera di una funzione in Home, che riflette i tre stati.
///
/// - Attiva: piena, colorata, al tocco esegue [onOpen] (o mostra conferma).
/// - Coming soon: velo smerigliato e badge dorato; al tocco apre l'anticipo.
/// - Premium bloccata: velo con lucchetto e badge dorato; al tocco apre
///   l'invito all'upgrade.
///
/// Lo stato viene ricalcolato osservando `FeatureFlagService`, quindi la
/// tessera reagisce in tempo reale al cambio di tier o delle leve remote.
class FeatureTile extends StatelessWidget {
  const FeatureTile({
    super.key,
    required this.feature,
    this.onOpen,
  });

  final FeatureDefinition feature;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final flags = context.watch<FeatureFlagService>();
    final status = flags.statusOf(feature);
    final palette = context.palette;

    final bool isActive = status == FeatureStatus.active;

    return DepthCard(
      onTap: () {
        if (isActive) {
          if (onOpen != null) {
            onOpen!();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${feature.title}: funzione attiva')),
            );
          }
        } else {
          showFeatureSheet(context, feature: feature, status: status);
        }
      },
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: palette.primary.withValues(alpha: 0.32),
                  borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
                  border: Border.all(
                    color: palette.gold.withValues(alpha: 0.45),
                  ),
                ),
                child: Icon(feature.icon, color: palette.goldSoft, size: 22),
              ),
              const SizedBox(height: SpacingTokens.md),
              Text(
                feature.title,
                style: TypographyTokens.display(size: 17),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: SpacingTokens.xxs),
              Text(
                feature.teaser,
                style: TypographyTokens.body(size: 13)
                    .copyWith(color: ColorTokens.textSecondary),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          if (!isActive)
            Positioned.fill(child: _FrostedVeil(status: status)),
          if (!isActive)
            Positioned(
              top: 0,
              right: 0,
              child: StatusBadge(status: status),
            ),
        ],
      ),
    );
  }
}

/// Velo smerigliato per gli stati non attivi. In Quality Tier alto usa un vero
/// blur (glassmorphism), altrove un velo traslucido. Al centro, per il premium,
/// compare il lucchetto dorato.
class _FrostedVeil extends StatelessWidget {
  const _FrostedVeil({required this.status});

  final FeatureStatus status;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final tier = context.watch<QualityTierController>().tier;
    final bool isPremium = status == FeatureStatus.premiumLocked;

    Widget veil = DecoratedBox(
      decoration: BoxDecoration(
        color: palette.deepest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
      ),
      child: isPremium
          ? Center(
              child: Icon(
                Icons.lock_rounded,
                color: palette.goldSoft.withValues(alpha: 0.9),
                size: 30,
              ),
            )
          : const SizedBox.expand(),
    );

    if (tier == QualityTier.high) {
      veil = ClipRRect(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3.5, sigmaY: 3.5),
          child: veil,
        ),
      );
    }
    return veil;
  }
}
