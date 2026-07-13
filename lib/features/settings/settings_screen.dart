import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/entitlement/entitlement_service.dart';
import '../../core/entitlement/plan_catalog.dart';
import '../../core/settings/settings_controller.dart';
import '../../design_system/components/cosmos_background.dart';
import '../../design_system/components/depth_card.dart';
import '../../design_system/components/section_title.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../services/app_services.dart';
import '../pricing/pricing_screen.dart';

/// Schermata Impostazioni, in stile 2.5D e nella palette del Maestro attivo.
///
/// Sezioni: Aspetto (Riduci animazioni, Modalita' semplice), Voce e sottotitoli
/// (Sottotitoli, segnaposto in attesa della voce), Privacy e dati (Cancella i
/// miei dati, che chiama la cancellazione GDPR con una conferma di custodia),
/// Account (segnaposto). Freccia Indietro, mai un vicolo cieco.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static Route<void> route() => MaterialPageRoute<void>(
        builder: (_) => const MaestroScope(child: SettingsScreen()),
      );

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final settings = context.watch<SettingsController>();

    return Scaffold(
      key: const Key('settings_screen'),
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: palette.deepest.withValues(alpha: 0.35),
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: palette.goldSoft),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Indietro',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text('Impostazioni', style: TypographyTokens.display(size: 20)),
      ),
      body: CosmosBackground(
        showZodiac: false,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              SpacingTokens.lg,
              SpacingTokens.md,
              SpacingTokens.lg,
              SpacingTokens.xxxl,
            ),
            children: [
              const SectionTitle(
                title: 'Il tuo piano',
                subtitle: 'Quanto lontano portare il cammino.',
              ),
              const SizedBox(height: SpacingTokens.sm),
              DepthCard(
                raised: true,
                child: _PlanTile(palette: palette),
              ),
              const SizedBox(height: SpacingTokens.xl),

              const SectionTitle(
                title: 'Aspetto',
                subtitle: 'Come si muove e si mostra il cerchio.',
              ),
              const SizedBox(height: SpacingTokens.sm),
              DepthCard(
                raised: true,
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _ToggleRow(
                      itemKey: const Key('settings_reduce'),
                      icon: Icons.motion_photos_paused_rounded,
                      title: 'Riduci animazioni',
                      subtitle: 'Meno movimento e parallasse.',
                      value: settings.reduceAnimations,
                      onChanged: settings.setReduceAnimations,
                      palette: palette,
                    ),
                    _divider(palette),
                    _ToggleRow(
                      itemKey: const Key('settings_simple'),
                      icon: Icons.blur_off_rounded,
                      title: 'Modalità semplice',
                      subtitle: 'Grafica alleggerita, più fluida.',
                      value: settings.simpleMode,
                      onChanged: settings.setSimpleMode,
                      palette: palette,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: SpacingTokens.xl),

              const SectionTitle(
                title: 'Voce e sottotitoli',
                subtitle: 'La voce dei Maestri arriverà presto.',
              ),
              const SizedBox(height: SpacingTokens.sm),
              DepthCard(
                raised: true,
                padding: EdgeInsets.zero,
                child: _ToggleRow(
                  itemKey: const Key('settings_subtitles'),
                  icon: Icons.subtitles_rounded,
                  title: 'Sottotitoli',
                  subtitle: 'Attivi di default, in attesa della voce.',
                  value: settings.subtitles,
                  onChanged: settings.setSubtitles,
                  palette: palette,
                ),
              ),
              const SizedBox(height: SpacingTokens.xl),

              const SectionTitle(
                title: 'Privacy e dati',
                subtitle: 'Il tuo cammino è tuo.',
              ),
              const SizedBox(height: SpacingTokens.sm),
              DepthCard(
                raised: true,
                child: _DeleteDataTile(palette: palette),
              ),
              const SizedBox(height: SpacingTokens.xl),

              const SectionTitle(
                title: 'Account',
                subtitle: 'Accesso e profilo.',
              ),
              const SizedBox(height: SpacingTokens.sm),
              DepthCard(
                raised: true,
                opacity: 0.6,
                child: Row(
                  children: [
                    Icon(Icons.person_outline_rounded,
                        color: palette.goldSoft, size: 22),
                    const SizedBox(width: SpacingTokens.md),
                    Expanded(
                      child: Text(
                        'Account',
                        style: TypographyTokens.display(size: 16),
                      ),
                    ),
                    _VeilBadge(palette: palette),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _divider(MaestroPalette palette) => Divider(
        height: 1,
        thickness: 1,
        indent: SpacingTokens.md,
        endIndent: SpacingTokens.md,
        color: palette.gold.withValues(alpha: 0.12),
      );
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.itemKey,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.palette,
  });

  final Key itemKey;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.md,
        vertical: SpacingTokens.xs,
      ),
      child: Row(
        children: [
          Icon(icon, color: palette.goldSoft, size: 22),
          const SizedBox(width: SpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TypographyTokens.display(size: 16)),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TypographyTokens.body(size: 13)
                      .copyWith(color: ColorTokens.textSecondary),
                ),
              ],
            ),
          ),
          Switch(
            key: itemKey,
            value: value,
            onChanged: onChanged,
            thumbColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected)
                  ? palette.deepest
                  : palette.goldSoft.withValues(alpha: 0.7),
            ),
            trackColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected)
                  ? palette.gold
                  : palette.surfaceElevated,
            ),
            trackOutlineColor: WidgetStateProperty.all(
              palette.gold.withValues(alpha: 0.35),
            ),
          ),
        ],
      ),
    );
  }
}

/// Riga di cancellazione dei dati, con conferma di custodia (mai punitiva).
class _DeleteDataTile extends StatelessWidget {
  const _DeleteDataTile({required this.palette});

  final MaestroPalette palette;

  Future<void> _confirmAndDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: palette.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
          side: BorderSide(color: palette.gold.withValues(alpha: 0.3)),
        ),
        title: Text('Cancellare i tuoi dati?',
            style: TypographyTokens.display(size: 20)),
        content: Text(
          'Lasceremo andare tutto il tuo cammino: profilo, ricordi dei Maestri '
          'e conversazioni. Non è una perdita, è il tuo diritto. Il cerchio '
          'ti accoglierà di nuovo come il primo giorno.',
          style: TypographyTokens.body(size: 15)
              .copyWith(color: ColorTokens.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text('Resta',
                style:
                    TypographyTokens.body(size: 15).copyWith(color: palette.goldSoft)),
          ),
          FilledButton(
            key: const Key('settings_delete_confirm'),
            style: FilledButton.styleFrom(
              backgroundColor: palette.gold,
              foregroundColor: palette.deepest,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Cancella i miei dati'),
          ),
        ],
      ),
    );

    if (ok != true || !context.mounted) return;
    final services = context.read<AppServices>();
    try {
      await services.memory.deleteAllData();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fatto. Il cerchio riparte da capo, quando vorrai.'),
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Non è stato possibile ora. Riprova più tardi.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: const Key('settings_delete'),
      borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
      onTap: () => _confirmAndDelete(context),
      child: Row(
        children: [
          Icon(Icons.delete_outline_rounded, color: palette.goldSoft, size: 22),
          const SizedBox(width: SpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Cancella i miei dati',
                    style: TypographyTokens.display(size: 16)),
                const SizedBox(height: 2),
                Text(
                  'Profilo, ricordi e conversazioni. Il tuo diritto all\'oblio.',
                  style: TypographyTokens.body(size: 13)
                      .copyWith(color: ColorTokens.textSecondary),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: palette.goldSoft),
        ],
      ),
    );
  }
}

/// Riga del piano attuale, con la via ai piani del Cerchio.
class _PlanTile extends StatelessWidget {
  const _PlanTile({required this.palette});

  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    final tier = context.watch<EntitlementService>().tier;
    final plan = PlanCatalog.forTier(tier);
    return InkWell(
      key: const Key('settings_plans'),
      borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
      onTap: () => Navigator.of(context).push(PricingScreen.route()),
      child: Row(
        children: [
          Icon(Icons.workspace_premium_outlined,
              color: palette.goldSoft, size: 22),
          const SizedBox(width: SpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Piano ${plan.name}',
                    style: TypographyTokens.display(size: 16)),
                const SizedBox(height: 2),
                Text(
                  'Vedi i piani del Cerchio e cosa aprono.',
                  style: TypographyTokens.body(size: 13)
                      .copyWith(color: ColorTokens.textSecondary),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: palette.goldSoft),
        ],
      ),
    );
  }
}

class _VeilBadge extends StatelessWidget {
  const _VeilBadge({required this.palette});

  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.xs,
        vertical: SpacingTokens.xxs,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
        border: Border.all(color: palette.gold.withValues(alpha: 0.35)),
      ),
      child: Text(
        'Dietro il velo',
        style: TypographyTokens.label(size: 10).copyWith(color: palette.gold),
      ),
    );
  }
}
