import 'package:flutter/material.dart';

import '../../core/feature_flags/feature_flag.dart';
import '../theme/maestro_scope.dart';
import '../tokens/spacing_tokens.dart';

/// Badge dorato che comunica lo stato non attivo di una funzione: "Coming soon"
/// oppure "Premium" con lucchetto.
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final FeatureStatus status;

  @override
  Widget build(BuildContext context) {
    if (status == FeatureStatus.active) return const SizedBox.shrink();
    final palette = context.palette;

    final bool isPremium = status == FeatureStatus.premiumLocked;
    final String label = isPremium ? 'Premium' : 'Coming soon';
    final IconData? icon = isPremium ? Icons.lock_rounded : null;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.xs,
        vertical: SpacingTokens.xxs,
      ),
      decoration: BoxDecoration(
        color: palette.gold.withValues(alpha: isPremium ? 0.22 : 0.14),
        borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
        border: Border.all(
          color: palette.gold.withValues(alpha: 0.7),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: palette.goldSoft),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: palette.goldSoft,
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}
