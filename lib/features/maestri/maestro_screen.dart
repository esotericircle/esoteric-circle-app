import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/feature_flags/feature_catalog.dart';
import '../../core/maestro/maestro.dart';
import '../../design_system/components/depth_card.dart';
import '../../design_system/components/feature_grid.dart';
import '../../design_system/components/section_title.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../services/app_services.dart';
import 'ask/ask_maestri_screen.dart';
import 'aura/meditation/meditation_screen.dart';
import 'chat/maestro_chat_screen.dart';
import 'widgets/maestro_presence.dart';

/// Sezione di un Maestro.
///
/// In C1 e' una schermata di dominio navigabile: intestazione cerimoniale del
/// Maestro e le sue funzioni nei tre stati. Le esperienze vere (chat, oracoli,
/// avatar animati) arrivano nei checkpoint successivi.
class MaestroScreen extends StatelessWidget {
  const MaestroScreen({super.key, required this.maestro});

  final Maestro maestro;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final features = FeatureCatalog.forMaestro(maestro);

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                SpacingTokens.lg,
                SpacingTokens.lg,
                SpacingTokens.lg,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Presenza del Maestro: avatar reale con respiro e aura.
                  MaestroPresence(maestro: maestro, height: 250),
                  const SizedBox(height: SpacingTokens.md),
                  DepthCard(
                    raised: true,
                    padding: const EdgeInsets.all(SpacingTokens.lg),
                    child: Row(
                      children: [
                        Icon(maestro.icon, color: palette.goldSoft, size: 30),
                        const SizedBox(width: SpacingTokens.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(maestro.displayName,
                                  style: TypographyTokens.display(size: 26)),
                              Text(
                                maestro.domainTitle,
                                style: TypographyTokens.body(size: 13)
                                    .copyWith(color: palette.goldSoft),
                              ),
                              const SizedBox(height: SpacingTokens.xs),
                              Text(
                                maestro.tagline,
                                style: TypographyTokens.body(size: 14)
                                    .copyWith(
                                        color: ColorTokens.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // La conversazione e' attiva per tutti e tre i Maestri, con
                  // la stessa struttura e la voce del rispettivo dominio.
                  const SizedBox(height: SpacingTokens.md),
                  _TalkToMaestroCard(maestro: maestro),
                  const SizedBox(height: SpacingTokens.md),
                  _AskMaestroCard(maestro: maestro),
                  // La Meditazione di Aura e' gia' viva: suono generato a
                  // runtime, cimatica e guida al respiro.
                  if (maestro == Maestro.aura) ...[
                    const SizedBox(height: SpacingTokens.md),
                    const _MeditationCard(),
                  ],
                  const SizedBox(height: SpacingTokens.xl),
                  SectionTitle(
                    title: 'Le Arti di ${maestro.displayName}',
                    subtitle: 'Il dominio del Maestro, ancora dietro il velo.',
                  ),
                  const SizedBox(height: SpacingTokens.md),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding:
                const EdgeInsets.symmetric(horizontal: SpacingTokens.lg),
            sliver: SliverToBoxAdapter(
              child: FeatureGrid(features: features, forceComingSoon: true),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: SpacingTokens.xxxl),
          ),
        ],
      ),
    );
  }
}

/// La porta a "Chiedi ai Maestri", che parte da questo Maestro: una domanda,
/// la sua risposta, poi l'invito a portarla anche a un altro Maestro.
class _AskMaestroCard extends StatelessWidget {
  const _AskMaestroCard({required this.maestro});

  final Maestro maestro;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return DepthCard(
      key: const Key('domain_ask_card'),
      raised: true,
      onTap: () => Navigator.of(context)
          .push(AskMaestriScreen.route(starter: maestro)),
      padding: const EdgeInsets.all(SpacingTokens.lg),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: palette.primary.withValues(alpha: 0.5),
              border: Border.all(color: palette.gold.withValues(alpha: 0.6)),
            ),
            alignment: Alignment.center,
            child: Icon(Icons.balance, color: palette.goldSoft, size: 24),
          ),
          const SizedBox(width: SpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chiedi a ${maestro.displayName}',
                  style: TypographyTokens.display(size: 18),
                ),
                const SizedBox(height: 2),
                Text(
                  'Una domanda, poi lo sguardo di un altro Maestro a confronto.',
                  style: TypographyTokens.body(size: 14)
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

/// La porta alla Meditazione di Aura: suono, cimatica e respiro.
class _MeditationCard extends StatelessWidget {
  const _MeditationCard();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return DepthCard(
      key: const Key('aura_meditation_card'),
      raised: true,
      onTap: () => Navigator.of(context).push(MeditationScreen.route()),
      padding: const EdgeInsets.all(SpacingTokens.lg),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: palette.primary.withValues(alpha: 0.5),
              border: Border.all(color: palette.gold.withValues(alpha: 0.6)),
            ),
            alignment: Alignment.center,
            child: Icon(Icons.self_improvement, color: palette.goldSoft, size: 24),
          ),
          const SizedBox(width: SpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Meditazione con suono e cimatica',
                  style: TypographyTokens.display(size: 18),
                ),
                const SizedBox(height: 2),
                Text(
                  'Toni a 432 e 528 Hz, un mandala che pulsa col respiro.',
                  style: TypographyTokens.body(size: 14)
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

/// Invito a entrare nel dialogo col Maestro: la porta della chat.
///
/// Il livello visivo, avatar e aura, e' gia' sopra nella schermata; qui la
/// tessera dorata offre l'azione con una frase sola, coerente col dominio.
class _TalkToMaestroCard extends StatelessWidget {
  const _TalkToMaestroCard({required this.maestro});

  final Maestro maestro;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return DepthCard(
      raised: true,
      onTap: () {
        final services = context.read<AppServices>();
        Navigator.of(context).push(
          MaestroChatScreen.route(maestro: maestro, services: services),
        );
      },
      padding: const EdgeInsets.all(SpacingTokens.lg),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: palette.primary.withValues(alpha: 0.5),
              border: Border.all(color: palette.gold.withValues(alpha: 0.6)),
            ),
            alignment: Alignment.center,
            child: Icon(Icons.forum_outlined, color: palette.goldSoft, size: 24),
          ),
          const SizedBox(width: SpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Parla con ${maestro.displayName}',
                  style: TypographyTokens.display(size: 18),
                ),
                const SizedBox(height: 2),
                Text(
                  'Apri il dialogo, con memoria del vostro cammino.',
                  style: TypographyTokens.body(size: 14)
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
