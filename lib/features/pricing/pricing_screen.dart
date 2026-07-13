import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/entitlement/entitlement_service.dart';
import '../../core/entitlement/plan_catalog.dart';
import '../../core/entitlement/tier.dart';
import '../../design_system/components/depth_card.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';

/// La schermata dei piani del Cerchio, in stile 2.5D.
///
/// Mostra i quattro piani con i loro benefici e mette in evidenza quello
/// consigliato e il piano attuale. Il pagamento non e' integrato nella Demo:
/// l'acquisto reale arrivera' dal web (modello reader app). Per provare i tier
/// sul simulatore resta un'attivazione dichiarata di Demo. Mai un vicolo cieco.
class PricingScreen extends StatelessWidget {
  const PricingScreen({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
      builder: (_) => const MaestroScope(child: PricingScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final current = context.watch<EntitlementService>().tier;

    return Scaffold(
      backgroundColor: ColorTokens.neutralDeepest,
      appBar: AppBar(
        backgroundColor: palette.deepest.withValues(alpha: 0.4),
        elevation: 0,
        iconTheme: IconThemeData(color: palette.goldSoft),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Indietro',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text('I piani del Cerchio',
            style: TypographyTokens.display(size: 20)),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          key: const Key('pricing_list'),
          padding: const EdgeInsets.fromLTRB(SpacingTokens.lg, SpacingTokens.md,
              SpacingTokens.lg, SpacingTokens.xxxl),
          children: [
            Text(
              'Scegli quanto lontano portare il tuo cammino. Ogni piano apre '
              'nuove porte del cerchio.',
              style: TypographyTokens.body(size: 15)
                  .copyWith(color: ColorTokens.textSecondary),
            ),
            const SizedBox(height: SpacingTokens.lg),
            for (final plan in PlanCatalog.plans) ...[
              _PlanCard(
                plan: plan,
                isCurrent: plan.tier == current,
                palette: palette,
              ),
              const SizedBox(height: SpacingTokens.md),
            ],
            const SizedBox(height: SpacingTokens.sm),
            // Nota onesta sul pagamento.
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 14, color: palette.goldSoft),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Nella Demo il pagamento non è attivo: l\'acquisto reale '
                    'arriverà dal web. Qui puoi provare un piano in modalità '
                    'Demo.',
                    style: TypographyTokens.label(size: 10).copyWith(
                      color: palette.goldSoft.withValues(alpha: 0.7),
                      letterSpacing: 0.3,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// La tessera di un piano, in profondita' 2.5D: piu' sollevata e dorata quella
/// consigliata, con un segno per il piano attuale.
class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.isCurrent,
    required this.palette,
  });

  final Plan plan;
  final bool isCurrent;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    final free = plan.tier == Tier.free;
    return DepthCard(
      key: Key('plan_${plan.tier.name}'),
      raised: plan.highlighted,
      opacity: plan.highlighted ? 1.0 : 0.7,
      padding: const EdgeInsets.all(SpacingTokens.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(plan.name,
                    style: TypographyTokens.display(size: 22)),
              ),
              if (isCurrent)
                _Badge(text: 'Piano attuale', palette: palette)
              else if (plan.highlighted)
                _Badge(text: 'Consigliato', palette: palette),
            ],
          ),
          const SizedBox(height: 2),
          Text(plan.tagline,
              style: TypographyTokens.body(size: 14)
                  .copyWith(color: palette.goldSoft)),
          const SizedBox(height: SpacingTokens.md),
          for (final benefit in plan.benefits) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.check_circle_outline,
                    size: 16, color: palette.goldSoft),
                const SizedBox(width: SpacingTokens.sm),
                Expanded(
                  child: Text(benefit,
                      style: TypographyTokens.body(size: 14).copyWith(
                          color: ColorTokens.textPrimary, height: 1.3)),
                ),
              ],
            ),
            const SizedBox(height: SpacingTokens.xs),
          ],
          if (!free && !isCurrent) ...[
            const SizedBox(height: SpacingTokens.sm),
            _ChoosePlanButton(plan: plan, palette: palette),
          ],
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text, required this.palette});

  final String text;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.sm, vertical: SpacingTokens.xxs),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
        color: palette.primary.withValues(alpha: 0.5),
        border: Border.all(color: palette.gold.withValues(alpha: 0.5)),
      ),
      child: Text(text,
          style:
              TypographyTokens.label(size: 10).copyWith(color: palette.goldSoft)),
    );
  }
}

/// Il pulsante per scegliere un piano. Nella Demo apre il foglio che spiega il
/// pagamento e consente la prova in modalita' Demo.
class _ChoosePlanButton extends StatelessWidget {
  const _ChoosePlanButton({required this.plan, required this.palette});

  final Plan plan;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: Key('choose_${plan.tier.name}'),
          borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
          onTap: () => _openSheet(context),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: SpacingTokens.sm),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
              gradient: LinearGradient(colors: [
                palette.primary.withValues(alpha: 0.7),
                palette.surfaceElevated.withValues(alpha: 0.7),
              ]),
              border: Border.all(color: palette.gold.withValues(alpha: 0.6)),
            ),
            child: Text('Scegli ${plan.name}',
                style: TypographyTokens.display(size: 15)
                    .copyWith(color: palette.goldSoft)),
          ),
        ),
      ),
    );
  }

  void _openSheet(BuildContext context) {
    final entitlement = context.read<EntitlementService>();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
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
              Text('Passa a ${plan.name}',
                  style: TypographyTokens.display(size: 20)
                      .copyWith(color: palette.goldSoft)),
              const SizedBox(height: SpacingTokens.sm),
              Text(
                'Nella Demo il pagamento non è attivo: l\'abbonamento reale '
                'arriverà dal web. Puoi comunque provare questo piano in '
                'modalità Demo, per vedere cosa apre.',
                style: TypographyTokens.body(size: 14)
                    .copyWith(color: ColorTokens.textSecondary),
              ),
              const SizedBox(height: SpacingTokens.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    child: Text('Chiudi',
                        style: TypographyTokens.label(size: 13)
                            .copyWith(color: ColorTokens.textSecondary)),
                  ),
                  const SizedBox(width: SpacingTokens.sm),
                  TextButton(
                    key: const Key('activate_demo'),
                    onPressed: () {
                      entitlement.setTier(plan.tier);
                      Navigator.of(sheetContext).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                '${plan.name} attivo in Demo. Il pagamento vero arriva dal web.')),
                      );
                    },
                    child: Text('Attiva in Demo',
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
  }
}
