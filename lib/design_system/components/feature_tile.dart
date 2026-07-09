import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/feature_flags/feature_flag.dart';
import '../../core/feature_flags/feature_flag_service.dart';
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
/// - Coming soon: velata e in grigio, con badge; al tocco apre l'anticipo.
/// - Premium bloccata: velata con lucchetto; al tocco apre l'invito all'upgrade.
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
    final bool isLocked = status == FeatureStatus.premiumLocked;

    return DepthCard(
      opacity: isActive ? 1.0 : 0.62,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: palette.primary.withValues(alpha: 0.35),
                  borderRadius:
                      BorderRadius.circular(SpacingTokens.radiusMd),
                  border: Border.all(
                    color: palette.gold.withValues(alpha: 0.35),
                  ),
                ),
                child: Icon(
                  isLocked ? Icons.lock_rounded : feature.icon,
                  color: palette.goldSoft,
                  size: 22,
                ),
              ),
              const Spacer(),
              StatusBadge(status: status),
            ],
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
    );
  }
}
