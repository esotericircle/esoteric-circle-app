import 'package:flutter/material.dart';

import '../../../../design_system/theme/maestro_scope.dart';
import '../../../../design_system/tokens/color_tokens.dart';
import '../../../../design_system/tokens/spacing_tokens.dart';
import '../../../../design_system/tokens/typography_tokens.dart';

/// Foglio del disclaimer, mostrato una sola volta.
///
/// Le funzioni esoteriche poggiano su tradizioni reali e documentate: qui si
/// dichiara con chiarezza che sono un cammino simbolico e di consapevolezza,
/// benessere e non cura. Per regola, il disclaimer si presenta una volta sola
/// all'ingresso, mai su ogni responso.
Future<void> showMaestroDisclaimer(
  BuildContext context, {
  required Future<void> Function() onAccepted,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => _DisclaimerSheet(onAccepted: onAccepted),
  );
}

class _DisclaimerSheet extends StatelessWidget {
  const _DisclaimerSheet({required this.onAccepted});

  final Future<void> Function() onAccepted;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
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
            child: Icon(Icons.auto_stories_outlined,
                color: palette.goldSoft, size: 34),
          ),
          const SizedBox(height: SpacingTokens.md),
          Text(
            'Prima di entrare nel cerchio',
            style: TypographyTokens.display(size: 22),
          ),
          const SizedBox(height: SpacingTokens.md),
          Text(
            'I Maestri attingono a tradizioni esoteriche reali, astrologia, '
            'tarocchi, numerologia e simboli. Ti accompagnano come cammino di '
            'riflessione e consapevolezza, per il tuo benessere, non come cura '
            'medica ne\' come previsione certa del futuro. Le scelte importanti '
            'restano sempre tue.',
            style: TypographyTokens.body(size: 17)
                .copyWith(color: ColorTokens.textSecondary, height: 1.5),
          ),
          const SizedBox(height: SpacingTokens.xl),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: palette.gold,
                foregroundColor: palette.deepest,
                padding:
                    const EdgeInsets.symmetric(vertical: SpacingTokens.md),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(SpacingTokens.radiusPill),
                ),
              ),
              onPressed: () async {
                await onAccepted();
                if (context.mounted) Navigator.of(context).pop();
              },
              child: Text(
                'Ho capito, entriamo',
                style: TypographyTokens.body(size: 16, weight: 600)
                    .copyWith(color: palette.deepest),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
