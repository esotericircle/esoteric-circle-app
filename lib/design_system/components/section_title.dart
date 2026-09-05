import 'package:flutter/material.dart';

import '../theme/maestro_scope.dart';
import '../tokens/color_tokens.dart';
import '../tokens/spacing_tokens.dart';
import '../tokens/typography_tokens.dart';

/// Titolo di sezione con filo dorato, comune alle schermate.
class SectionTitle extends StatelessWidget {
  const SectionTitle({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 24,
              height: 2,
              color: palette.gold.withValues(alpha: 0.8),
            ),
            const SizedBox(width: SpacingTokens.xs),
            // Flessibile: un titolo lungo va a capo invece di sforare la riga.
            Flexible(
              child: Text(
                title.toUpperCase(),
                style: TypographyTokens.titoloDiRiga(weight: 600)
                    .copyWith(letterSpacing: 2, color: palette.goldSoft),
              ),
            ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: SpacingTokens.xxs),
          Text(
            subtitle!,
            style: TypographyTokens.corpo()
                .copyWith(color: ColorTokens.textSecondary),
          ),
        ],
      ],
    );
  }
}
