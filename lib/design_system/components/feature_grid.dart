import 'package:flutter/material.dart';

import '../../core/feature_flags/feature_flag.dart';
import '../tokens/spacing_tokens.dart';
import 'feature_tile.dart';

/// Griglia responsiva a due colonne di tessere funzione.
class FeatureGrid extends StatelessWidget {
  const FeatureGrid({super.key, required this.features});

  final List<FeatureDefinition> features;

  @override
  Widget build(BuildContext context) {
    const spacing = SpacingTokens.sm;
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - spacing) / 2;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final feature in features)
              SizedBox(
                width: itemWidth,
                child: FeatureTile(feature: feature),
              ),
          ],
        );
      },
    );
  }
}
