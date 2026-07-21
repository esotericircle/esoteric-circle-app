import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/arts/art_catalog.dart';
import '../../core/astro/night_sky.dart';
import '../../core/astro/zodiac.dart';
import '../../core/chat/immersive_intents.dart';
import '../../core/entitlement/plan_catalog.dart';
import '../../core/identity/natal_identity.dart';
import '../../core/identity/profile_controller.dart';
import '../../core/maestro/maestro.dart';
import '../../core/maestro/maestro_controller.dart';
import '../../design_system/components/art_card.dart';
import '../../design_system/components/depth_card.dart';
import '../../design_system/components/section_title.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../services/app_services.dart';
import 'art_navigation.dart';
import 'chat/maestro_chat_screen.dart';
import 'immersive_navigation.dart';
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
    final sections = ArtCatalog.forMaestro(maestro);

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
                  // In cima la presenza del Maestro: il nome e' gia' nella barra
                  // e nell'immagine, quindi nessuna carta identitaria ridondante.
                  MaestroPresence(maestro: maestro, height: 250),
                  const SizedBox(height: SpacingTokens.md),
                  // Subito il titolo del dominio, poi l'azione principale.
                  SectionTitle(
                    title: 'Le Arti di ${maestro.displayName}',
                    subtitle:
                        'Il suo dominio, dalle arti vive a quelle in cammino.',
                  ),
                  const SizedBox(height: SpacingTokens.md),
                  // Una sola voce per la conversazione: la chat, dove si dialoga
                  // e dove il confronto a piu' voci vive dentro l'esperienza.
                  _ConsultaMaestroCard(maestro: maestro),
                  const SizedBox(height: SpacingTokens.lg),
                ],
              ),
            ),
          ),
          // I riquadri delle sottocategorie: a colpo d'occhio si sceglie la
          // sezione, e dentro le arti coi loro tre stati.
          SliverPadding(
            padding:
                const EdgeInsets.symmetric(horizontal: SpacingTokens.lg),
            sliver: SliverList.separated(
              itemCount: sections.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: SpacingTokens.lg),
              itemBuilder: (context, i) =>
                  _ArtSectionBox(maestro: maestro, section: sections[i]),
            ),
          ),
          // In fondo, oltre il dominio del Maestro, il ponte al cerchio
          // condiviso: le arti degli altri Maestri.
          SliverToBoxAdapter(
            child: _OtherArtsStrip(current: maestro),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: SpacingTokens.xxxl),
          ),
        ],
      ),
    );
  }
}

/// Il riquadro di una sottocategoria: il suo titolo e le arti che contiene, coi
/// tre stati. Un solo linguaggio di card, lo stato le distingue.
class _ArtSectionBox extends StatelessWidget {
  const _ArtSectionBox({required this.maestro, required this.section});

  final Maestro maestro;
  final ArtSection section;

  /// Il segno solare della persona, che serve alle arti che lo chiedono.
  Zodiac _userSign(BuildContext context) {
    final birth = context.read<BirthIdentityController>();
    final chart = birth.chart;
    if (chart != null) return chart.sunSign;
    return NightSky.sunSign(
        context.read<ProfileController>().identity.birthMoment);
  }

  Future<void> _open(BuildContext context, ArtEntry art) async {
    final route = artRouteFor(art.id, userSign: _userSign(context));
    if (route != null) {
      await Navigator.of(context).push(route);
      return;
    }
    // Mai un vicolo cieco: un anticipo elegante che dice a che punto e'.
    if (!context.mounted) return;
    await showArtPreview(context, art: art, maestro: maestro);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      key: Key('art_section_${section.title.toLowerCase()}'),
      padding: const EdgeInsets.all(SpacingTokens.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusXl),
        color: palette.deepest.withValues(alpha: 0.35),
        border: Border.all(color: palette.gold.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
                left: SpacingTokens.xs, bottom: SpacingTokens.sm),
            child: Text(
              section.title,
              style: TypographyTokens.display(size: 18)
                  .copyWith(color: palette.goldSoft),
            ),
          ),
          for (var i = 0; i < section.arts.length; i++) ...[
            if (i > 0) const SizedBox(height: SpacingTokens.sm),
            ArtCard(
              art: section.arts[i],
              palette: palette,
              onTap: () => _open(context, section.arts[i]),
            ),
          ],
        ],
      ),
    );
  }
}

/// Un'arte del cerchio nella striscia "Scopri altre arti del Cerchio": il
/// Maestro a cui appartiene, la funzione immersiva che apre, l'icona e il nome.
class _CircleArt {
  const _CircleArt({
    required this.maestro,
    required this.target,
    required this.icon,
    required this.title,
  });

  final Maestro maestro;
  final ImmersiveTarget target;
  final IconData icon;
  final String title;
}

/// La selezione curata delle arti vive del cerchio, una per arte. Non e' un
/// ordinamento per popolarita' reale, che alla Demo non esiste: e' una scelta
/// curata; la telemetria un giorno la riordinera'. Ogni voce apre una funzione
/// gia' viva, con la sua rotta condivisa (`immersiveRouteFor`).
const List<_CircleArt> _curatedArts = [
  _CircleArt(
    maestro: Maestro.medora,
    target: ImmersiveTarget.oroscopoGiorno,
    icon: Icons.brightness_3_rounded,
    title: 'Oracolo del Giorno',
  ),
  _CircleArt(
    maestro: Maestro.medora,
    target: ImmersiveTarget.sinastriaVip,
    icon: Icons.favorite_rounded,
    title: 'Sinastria VIP',
  ),
  _CircleArt(
    maestro: Maestro.aura,
    target: ImmersiveTarget.meditazione,
    icon: Icons.self_improvement_rounded,
    title: 'Meditazione',
  ),
  _CircleArt(
    maestro: Maestro.aura,
    target: ImmersiveTarget.breathwork,
    icon: Icons.air_rounded,
    title: 'Respiro guidato',
  ),
  _CircleArt(
    maestro: Maestro.caligo,
    target: ImmersiveTarget.lancioRune,
    icon: Icons.change_history_rounded,
    title: 'Runa del Tramonto',
  ),
];

/// La striscia orizzontale "Scopri altre arti del Cerchio": le arti degli altri
/// Maestri, ciascuna tessera nel COLORE del Maestro a cui l'arte appartiene,
/// cosi' si vede da subito di chi e'. Scorre in orizzontale, con un accenno di
/// contenuto oltre il bordo.
class _OtherArtsStrip extends StatelessWidget {
  const _OtherArtsStrip({required this.current});

  final Maestro current;

  @override
  Widget build(BuildContext context) {
    final arts =
        _curatedArts.where((a) => a.maestro != current).toList(growable: false);

    return Column(
      key: const Key('other_arts_strip'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: SpacingTokens.xl),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: SpacingTokens.lg),
          child: SectionTitle(
            title: 'Scopri altre arti del Cerchio',
            subtitle: 'Le arti degli altri Maestri, oltre il tuo dominio.',
          ),
        ),
        const SizedBox(height: SpacingTokens.md),
        SizedBox(
          height: 148,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding:
                const EdgeInsets.symmetric(horizontal: SpacingTokens.lg),
            itemCount: arts.length,
            separatorBuilder: (_, __) =>
                const SizedBox(width: SpacingTokens.sm),
            itemBuilder: (context, i) => _CircleArtTile(
              art: arts[i],
              // Il colore del Maestro di quell'arte, non un neutro.
              palette: MaestroPalette.forKey(ThemeKey.of(arts[i].maestro)),
            ),
          ),
        ),
      ],
    );
  }
}

/// Una tessera della striscia, nel colore del Maestro dell'arte. Al tocco apre
/// la funzione e vira il tema su quel Maestro, poi lo ripristina al ritorno.
class _CircleArtTile extends StatelessWidget {
  const _CircleArtTile({required this.art, required this.palette});

  final _CircleArt art;
  final MaestroPalette palette;

  Future<void> _open(BuildContext context) async {
    final route = immersiveRouteFor(art.target);
    if (route == null) return;
    final controller = context.read<MaestroController>();
    final previous = controller.activeMaestro;
    // Il tema vira sul Maestro dell'arte per la durata della funzione.
    controller.selectMaestro(art.maestro);
    await Navigator.of(context).push(route);
    // Al ritorno, il dominio riprende il suo tema.
    if (context.mounted && previous != null) {
      controller.selectMaestro(previous);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Palette neutra esplicita: la tessera non segue il tema del Maestro del
    // dominio, ma il viola scuro del cerchio condiviso.
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: Key('other_art_${art.target.name}'),
        onTap: () => _open(context),
        borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
        child: Container(
          width: 172,
          padding: const EdgeInsets.all(SpacingTokens.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                palette.surfaceElevated.withValues(alpha: 0.92),
                palette.surface.withValues(alpha: 0.78),
              ],
            ),
            border: Border.all(color: palette.gold.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: palette.primary.withValues(alpha: 0.5),
                  border:
                      Border.all(color: palette.gold.withValues(alpha: 0.6)),
                ),
                alignment: Alignment.center,
                child: Icon(art.icon, color: palette.goldSoft, size: 22),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Il nome si adatta a scendere invece di spezzarsi a meta'
                  // parola: "Meditazione" e' una parola sola e in Cinzel, che e'
                  // tutto maiuscolo, andava a capo male.
                  SizedBox(
                    width: double.infinity,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(art.title,
                          maxLines: 1,
                          style: TypographyTokens.display(size: 14)
                              .copyWith(color: palette.textPrimary)),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(art.maestro.displayName,
                      style: TypographyTokens.label(size: 10).copyWith(
                        color: palette.goldSoft.withValues(alpha: 0.85),
                        letterSpacing: 0.6,
                      )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


/// L'azione principale del dominio: una sola voce per la conversazione.
///
/// "Parla con" e "Consulta" erano due porte per la stessa cosa: qui restano una
/// sola, Consulta [Nome], che apre la chat. Il confronto a piu' voci non e'
/// orfano, vive dentro l'esperienza: dall'header della chat, col tasto della
/// bilancia, la stessa domanda va agli altri Maestri e torna con la sintesi.
class _ConsultaMaestroCard extends StatelessWidget {
  const _ConsultaMaestroCard({required this.maestro});

  final Maestro maestro;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return DepthCard(
      key: const Key('domain_consulta_card'),
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
                  'Consulta ${maestro.displayName}',
                  style: TypographyTokens.display(size: 18),
                ),
                const SizedBox(height: 2),
                Text(
                  'Dialoga, chiedi e metti a confronto le voci del Cerchio.',
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

/// L'anticipo di un'arte non ancora apribile: dice con onesta' a che punto e' e
/// cosa dara', senza mai lasciare un vicolo cieco.
Future<void> showArtPreview(
  BuildContext context, {
  required ArtEntry art,
  required Maestro maestro,
}) {
  final palette = MaestroPalette.forKey(ThemeKey.of(maestro));
  final riga = art.state == ArtState.premium
      ? 'Questa arte e\' pronta e vive nel Cerchio: si apre con '
          '${art.requiredTier == null ? 'l\'abbonamento' : PlanCatalog.forTier(art.requiredTier!).name}.'
      : 'Questa arte e\' in cammino, pianificata per ${art.phase ?? 'una fase futura'}. '
          'Quando sara\' pronta la troverai qui.';
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => Container(
      key: const Key('art_preview'),
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
            Row(
              children: [
                Icon(art.icon, color: palette.goldSoft, size: 24),
                const SizedBox(width: SpacingTokens.sm),
                Expanded(
                  child: Text(art.title,
                      style: TypographyTokens.display(size: 19)
                          .copyWith(color: palette.goldSoft)),
                ),
              ],
            ),
            const SizedBox(height: SpacingTokens.sm),
            Text(art.teaser,
                style: TypographyTokens.body(size: 15)
                    .copyWith(color: ColorTokens.textPrimary, height: 1.4)),
            const SizedBox(height: SpacingTokens.sm),
            Text(riga,
                style: TypographyTokens.body(size: 14)
                    .copyWith(color: ColorTokens.textSecondary, height: 1.4)),
            const SizedBox(height: SpacingTokens.lg),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(sheetContext).pop(),
                child: Text('Va bene',
                    style: TypographyTokens.label(size: 13)
                        .copyWith(color: palette.goldSoft)),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
