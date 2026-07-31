import 'package:flutter/material.dart';

import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../pricing/pricing_screen.dart';
import '../settings/settings_screen.dart';
import 'profile_screen.dart';
import 'dati_di_nascita_screen.dart';

/// L'area account, aperta dall'icona Utente in alto a destra nel Cerchio.
///
/// Raccoglie le voci personali (Profilo, Impostazioni, Abbonamento, Notifiche,
/// Privacy), distinte dal Cosmic Passport, che resta il profilo esoterico nella
/// barra in basso. Alcune voci portano gia' alla loro schermata, altre sono in
/// arrivo e lo dichiarano, mai un vicolo cieco.
class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  static Route<void> route() => MaterialPageRoute<void>(
        builder: (_) => const AccountScreen(),
      );

  @override
  Widget build(BuildContext context) {
    final entries = <_AccountEntry>[
      _AccountEntry(
        id: 'profilo',
        title: 'Profilo',
        subtitle: 'Nome, avatar e dati personali',
        icon: Icons.person_outline_rounded,
        onTap: (context) => Navigator.of(context).push(ProfileScreen.route()),
      ),
      // I DATI DI NASCITA SI CORREGGONO. Prima si raccoglievano una volta sola
      // nel Risveglio e non c'era piu' modo di toccarli: chi l'aveva concluso
      // senza dare l'ora non poteva piu' darla, e si rivedeva per sempre
      // "l'Ascendente e le Case restano velati". Un dato che si raccoglie una
      // volta sola e mai piu' non e' un dato, e' una trappola.
      _AccountEntry(
        id: 'nascita',
        title: 'I tuoi dati di nascita',
        subtitle: 'Giorno e ora esatta, per Ascendente e Case',
        icon: Icons.cake_outlined,
        onTap: (context) =>
            Navigator.of(context).push(DatiDiNascitaScreen.route()),
      ),
      _AccountEntry(
        id: 'impostazioni',
        title: 'Impostazioni',
        subtitle: 'Preferenze, lingua, qualità grafica',
        icon: Icons.settings_outlined,
        onTap: (context) =>
            Navigator.of(context).push(SettingsScreen.route()),
      ),
      _AccountEntry(
        id: 'abbonamento',
        title: 'Abbonamento',
        subtitle: 'Il tuo piano e i livelli del Cerchio',
        icon: Icons.workspace_premium_outlined,
        onTap: (context) =>
            Navigator.of(context).push(PricingScreen.route()),
      ),
      const _AccountEntry(
        id: 'notifiche',
        title: 'Notifiche',
        subtitle: 'Gli appuntamenti che ti avvisano',
        icon: Icons.notifications_none_rounded,
      ),
      const _AccountEntry(
        id: 'privacy',
        title: 'Privacy',
        subtitle: 'Dati, consensi e sicurezza',
        icon: Icons.shield_outlined,
      ),
    ];

    return Scaffold(
      backgroundColor: ColorTokens.neutralDeepest,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          color: ColorTokens.textPrimary,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text('Il tuo account',
            style: TypographyTokens.display(size: 20)),
      ),
      body: SafeArea(
        top: false,
        child: ListView.separated(
          key: const Key('account_list'),
          padding: const EdgeInsets.fromLTRB(SpacingTokens.lg, SpacingTokens.md,
              SpacingTokens.lg, SpacingTokens.xxxl),
          itemCount: entries.length,
          separatorBuilder: (_, __) => const SizedBox(height: SpacingTokens.sm),
          itemBuilder: (context, i) => _AccountTile(entry: entries[i]),
        ),
      ),
    );
  }
}

class _AccountEntry {
  const _AccountEntry({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onTap,
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;

  /// Azione della voce. Se assente, la sezione e' ancora in arrivo.
  final void Function(BuildContext context)? onTap;

  bool get isLive => onTap != null;
}

class _AccountTile extends StatelessWidget {
  const _AccountTile({required this.entry});

  final _AccountEntry entry;

  void _open(BuildContext context) {
    if (entry.onTap != null) {
      entry.onTap!(context);
      return;
    }
    // Mai un vicolo cieco: un anticipo elegante per le sezioni in arrivo.
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        key: const Key('account_coming_soon'),
        padding: const EdgeInsets.fromLTRB(SpacingTokens.lg, SpacingTokens.md,
            SpacingTokens.lg, SpacingTokens.xl),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [ColorTokens.neutralSurface, ColorTokens.neutralDeepest],
          ),
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(SpacingTokens.radiusXl)),
          border: Border.all(color: ColorTokens.gold.withValues(alpha: 0.3)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(entry.icon, color: ColorTokens.goldLight, size: 24),
                  const SizedBox(width: SpacingTokens.sm),
                  Text(entry.title,
                      style: TypographyTokens.display(size: 19)
                          .copyWith(color: ColorTokens.goldLight)),
                ],
              ),
              const SizedBox(height: SpacingTokens.sm),
              Text(
                'Questa sezione sta per aprirsi nel Cerchio. Torna presto per '
                'trovarla pronta.',
                style: TypographyTokens.body(size: 15)
                    .copyWith(color: ColorTokens.textSecondary, height: 1.4),
              ),
              const SizedBox(height: SpacingTokens.lg),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  child: Text('Va bene',
                      style: TypographyTokens.label(size: 13)
                          .copyWith(color: ColorTokens.goldLight)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: Key('account_${entry.id}'),
        onTap: () => _open(context),
        borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(SpacingTokens.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
            color: ColorTokens.neutralSurface.withValues(alpha: 0.5),
            border: Border.all(color: ColorTokens.gold.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ColorTokens.neutralDeep,
                  border:
                      Border.all(color: ColorTokens.gold.withValues(alpha: 0.4)),
                ),
                alignment: Alignment.center,
                child: Icon(entry.icon, color: ColorTokens.goldLight, size: 22),
              ),
              const SizedBox(width: SpacingTokens.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.title,
                        style: TypographyTokens.display(size: 17)),
                    const SizedBox(height: 2),
                    Text(entry.subtitle,
                        style: TypographyTokens.body(size: 13).copyWith(
                            color: ColorTokens.textSecondary, height: 1.3)),
                  ],
                ),
              ),
              const SizedBox(width: SpacingTokens.sm),
              if (!entry.isLive)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(SpacingTokens.radiusPill),
                    color: ColorTokens.gold.withValues(alpha: 0.16),
                    border:
                        Border.all(color: ColorTokens.gold.withValues(alpha: 0.5)),
                  ),
                  child: Text('In arrivo',
                      style: TypographyTokens.label(size: 11)
                          .copyWith(color: ColorTokens.goldLight)),
                ),
              const SizedBox(width: SpacingTokens.xs),
              Icon(
                entry.isLive
                    ? Icons.chevron_right_rounded
                    : Icons.lock_clock_rounded,
                size: 20,
                color: ColorTokens.goldLight
                    .withValues(alpha: entry.isLive ? 0.9 : 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
