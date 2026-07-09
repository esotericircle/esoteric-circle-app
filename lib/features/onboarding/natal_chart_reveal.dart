import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/astro/natal_chart.dart';
import '../../core/astro/natal_chart_controller.dart';
import '../../design_system/components/depth_card.dart';
import '../../design_system/components/natal_wheel.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';

/// Mostra la carta natale calcolata: la ruota 2.5D che si costruisce e una
/// sintesi. Se il cielo e' essenziale (API non disponibile) o parziale (senza
/// ora) lo comunica in tono, con un invito a completare, mai un errore.
class NatalChartReveal extends StatelessWidget {
  const NatalChartReveal({super.key, required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<NatalChartController>();
    final palette = context.palette;

    if (controller.status != ChartStatus.ready || controller.chart == null) {
      return _Loading();
    }
    final chart = controller.chart!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(SpacingTokens.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: SpacingTokens.sm),
          Text('IL TUO CIELO',
              style: TypographyTokens.body(size: 12).copyWith(
                color: palette.goldSoft,
                letterSpacing: 3,
              )),
          const SizedBox(height: SpacingTokens.xs),
          Text('La Carta Natale',
              style: TypographyTokens.display(size: 30)),
          const SizedBox(height: SpacingTokens.lg),
          NatalWheel(chart: chart, size: 300),
          const SizedBox(height: SpacingTokens.lg),
          _SummaryCard(chart: chart, note: controller.note),
          const SizedBox(height: SpacingTokens.lg),
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
              onPressed: onContinue,
              child: Text('Incontra il tuo Maestro',
                  style: TypographyTokens.body(size: 15, weight: 600)
                      .copyWith(color: palette.deepest)),
            ),
          ),
          const SizedBox(height: SpacingTokens.lg),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.chart, required this.note});
  final NatalChart chart;
  final String? note;

  @override
  Widget build(BuildContext context) {
    return DepthCard(
      raised: true,
      padding: const EdgeInsets.all(SpacingTokens.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _row(context, 'Sole', chart.sunSign.italianName),
          if (chart.moonSign != null)
            _row(context, 'Luna', chart.moonSign!.italianName),
          if (chart.ascendant != null)
            _row(context, 'Ascendente', chart.ascendant!.italianName),
          if (chart.isPartial) ...[
            const SizedBox(height: SpacingTokens.sm),
            _hint(
              context,
              'Senza l\'ora di nascita l\'Ascendente e le Case restano velati. Potrai aggiungerla per completare il cielo.',
            ),
          ],
          if (note != null) ...[
            const SizedBox(height: SpacingTokens.sm),
            _hint(context, note!),
          ],
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: TypographyTokens.body(size: 15)
                    .copyWith(color: palette.goldSoft)),
          ),
          Text(value, style: TypographyTokens.display(size: 18)),
        ],
      ),
    );
  }

  Widget _hint(BuildContext context, String text) {
    return Text(
      text,
      style: TypographyTokens.body(size: 13)
          .copyWith(color: ColorTokens.textSecondary, height: 1.4),
    );
  }
}

class _Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 42,
            height: 42,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(palette.goldSoft),
            ),
          ),
          const SizedBox(height: SpacingTokens.md),
          Text('Traccio il tuo cielo...',
              style: TypographyTokens.body(size: 15)
                  .copyWith(color: ColorTokens.textSecondary)),
        ],
      ),
    );
  }
}
