import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/feature_flags/feature_catalog.dart';
import '../../core/maestro/maestro.dart';
import '../../design_system/components/depth_card.dart';
import '../../design_system/components/feature_grid.dart';
import '../../design_system/components/section_title.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../core/rituals/daily_rituals.dart';
import '../../services/app_services.dart';
import '../rituals/breath_destiny_screen.dart';
import '../rituals/dawn_rite_screen.dart';
import '../rituals/day_oracle_screen.dart';
import '../rituals/sunset_rune_screen.dart';
import 'ask/ask_maestri_screen.dart';
import 'aura/meditation/meditation_screen.dart';
import 'chat/maestro_chat_screen.dart';
import 'chat/widgets/maestro_avatar.dart';
import 'widgets/maestro_presence.dart';

/// Sezione di un Maestro.
///
/// In C1 e' una schermata di dominio navigabile: intestazione cerimoniale del
/// Maestro e le sue funzioni nei tre stati. Le esperienze vere (chat, oracoli,
/// avatar animati) arrivano nei checkpoint successivi.
class MaestroScreen extends StatelessWidget {
  const MaestroScreen({super.key, required this.maestro});

  final Maestro maestro;

  /// Le tessere dei rituali del giorno per questo Maestro: quello del suo
  /// dominio, e in piu' il Rito dell'Alba se oggi tocca a lui.
  List<Widget> _ritualCards(BuildContext context, Maestro maestro) {
    final cards = <Widget>[];
    if (DailyRituals.dawnMaestro(DateTime.now()) == maestro) {
      cards.add(_DawnRiteCard(maestro: maestro));
    }
    switch (maestro) {
      case Maestro.medora:
        cards.add(_RitualCard(
          cardKey: const Key('ritual_oracle'),
          icon: Icons.brightness_3_rounded,
          title: 'Oracolo del Giorno',
          subtitle: 'La lettura del cielo di oggi, al giroscopio o al dito.',
          onTap: () => Navigator.of(context).push(DayOracleScreen.route()),
        ));
      case Maestro.aura:
        cards.add(_RitualCard(
          cardKey: const Key('ritual_breath'),
          icon: Icons.air_rounded,
          title: 'Soffio del Destino',
          subtitle: 'Un soffio al microfono, o un tocco: il destino parla.',
          onTap: () => Navigator.of(context).push(BreathDestinyScreen.route()),
        ));
      case Maestro.caligo:
        cards.add(_RitualCard(
          cardKey: const Key('ritual_rune'),
          icon: Icons.change_history_rounded,
          title: 'La Runa del Tramonto',
          subtitle: 'Estrai la runa del giorno dall\'antico Futhark.',
          onTap: () => Navigator.of(context).push(SunsetRuneScreen.route()),
        ));
    }
    return [
      for (final card in cards) ...[
        const SizedBox(height: SpacingTokens.md),
        card,
      ],
    ];
  }

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
                  // I rituali del giorno, ciascuno nel suo dominio, piu' il Rito
                  // dell'Alba nel Maestro di turno oggi.
                  ..._ritualCards(context, maestro),
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
                  'Consulta ${maestro.displayName}',
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

/// La tessera del Rito dell'Alba, con il Maestro di turno del giorno visibile:
/// il suo avatar, il suo nome e il suo colore di tema. La rotazione e'
/// deterministica sul giorno dell'anno.
class _DawnRiteCard extends StatelessWidget {
  const _DawnRiteCard({required this.maestro});

  final Maestro maestro;

  @override
  Widget build(BuildContext context) {
    final palette = MaestroPalette.forKey(ThemeKey.of(maestro));
    return DepthCard(
      key: const Key('ritual_dawn'),
      raised: true,
      onTap: () => Navigator.of(context).push(DawnRiteScreen.route()),
      padding: const EdgeInsets.all(SpacingTokens.lg),
      child: Row(
        children: [
          // L'avatar del Maestro di turno, nella sua cornice.
          MaestroAvatar(maestro: maestro, size: 48),
          const SizedBox(width: SpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.wb_twilight_rounded,
                        size: 18, color: palette.goldSoft),
                    const SizedBox(width: 6),
                    // Flexible con ellissi: sul device, con Cinzel, il titolo
                    // entra intero e l'aspetto non cambia; ma il testo non puo'
                    // piu' sforare la tessera se il font reso e' piu' largo del
                    // previsto, come accade nei test headless quando la Row non
                    // era ancora protetta.
                    Flexible(
                      child: Text('Rito dell\'Alba',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TypographyTokens.display(size: 18)),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Oggi la guida è di ${maestro.displayName}.',
                  style: TypographyTokens.body(size: 14)
                      .copyWith(color: palette.goldSoft),
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

/// Tessera di un rituale del giorno nel dominio del Maestro.
class _RitualCard extends StatelessWidget {
  const _RitualCard({
    required this.cardKey,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final Key cardKey;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return DepthCard(
      key: cardKey,
      raised: true,
      onTap: onTap,
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
            child: Icon(icon, color: palette.goldSoft, size: 24),
          ),
          const SizedBox(width: SpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TypographyTokens.display(size: 18)),
                const SizedBox(height: 2),
                Text(
                  subtitle,
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
