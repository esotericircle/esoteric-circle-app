import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/arts/art_catalog.dart';
import '../../core/astro/night_sky.dart';
import '../../core/astro/zodiac.dart';
import '../../core/chat/immersive_intents.dart';
import '../../core/config/app_flags.dart';
import '../../core/entitlement/plan_catalog.dart';
import '../../core/lang/euphonic.dart';
import '../../core/identity/natal_identity.dart';
import '../../core/identity/profile_controller.dart';
import '../../core/maestro/maestro.dart';
import '../../core/maestro/maestro_controller.dart';
import '../../design_system/components/art_card.dart';
import '../../design_system/components/depth_card.dart';
import '../../design_system/components/scroll_reveal.dart';
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
///
/// Niente qui e' cablato su un Maestro: pilastri, sottocategorie, stati di
/// apertura e conteggi nascono tutti dal catalogo, quindi la stessa struttura
/// vale identica per Medora, Aura e Caligo.
class MaestroScreen extends StatefulWidget {
  const MaestroScreen({
    super.key,
    required this.maestro,
    this.demo = AppFlags.isDemo,
  });

  final Maestro maestro;

  /// La vista: quella Demo per gli investitori mostra tutto il piano, quella
  /// della persona si ferma alla soglia delle fasi. Iniettabile per i test.
  final bool demo;

  @override
  State<MaestroScreen> createState() => _MaestroScreenState();
}

class _MaestroScreenState extends State<MaestroScreen> {
  /// Se il corpo della sottocategoria e' aperto. Una sottocategoria con almeno
  /// un'arte viva nasce aperta, una tutta in cammino nasce chiusa.
  final Map<String, bool> _open = {};

  /// Se dentro una sottocategoria mista e' aperto il gruppo delle arti in
  /// arrivo, che di suo nasce chiuso.
  final Map<String, bool> _soon = {};

  List<ArtSection> get _sections =>
      ArtCatalog.visibleFor(widget.maestro, demo: widget.demo);

  @override
  void initState() {
    super.initState();
    for (final s in _sections) {
      _open[s.title] = ArtCatalog.hasActive(s);
      _soon[s.title] = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sections = _sections;

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
                  // In cima la presenza del Maestro: il nome e i tre pilastri
                  // del dominio stanno gia' nella barra, quindi qui nessuna
                  // carta identitaria ridondante.
                  MaestroPresence(maestro: widget.maestro, height: 250),
                  const SizedBox(height: SpacingTokens.md),
                  // Poi il titolo del dominio, poi l'azione principale.
                  SectionTitle(
                    title: 'Le Arti di ${widget.maestro.displayName}',
                    subtitle:
                        'Il suo dominio, dalle arti vive a quelle in cammino.',
                  ),
                  const SizedBox(height: SpacingTokens.md),
                  // Una sola voce per la conversazione: la chat, dove si dialoga
                  // e dove il confronto a piu' voci vive dentro l'esperienza.
                  _ConsultaMaestroCard(maestro: widget.maestro),
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
              itemBuilder: (context, i) {
                final s = sections[i];
                return _ArtSectionBox(
                  maestro: widget.maestro,
                  section: s,
                  demo: widget.demo,
                  open: _open[s.title] ?? true,
                  soonOpen: _soon[s.title] ?? false,
                  onToggleSection: () =>
                      setState(() => _open[s.title] = !(_open[s.title] ?? true)),
                  onToggleSoon: () =>
                      setState(() => _soon[s.title] = !(_soon[s.title] ?? false)),
                );
              },
            ),
          ),
          // In fondo, oltre il dominio del Maestro, il ponte al cerchio
          // condiviso: le arti degli altri Maestri.
          SliverToBoxAdapter(
            child: _OtherArtsStrip(current: widget.maestro),
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
///
/// Il collasso lo guida lo STATO delle arti, non una scelta scritta a mano.
/// Dove c'e' qualcosa di vivo, le arti attive e le Premium restano sempre in
/// vista e solo quelle in cammino si raccolgono dietro un apri e chiudi. Dove
/// non c'e' ancora nulla di vivo, l'intera sottocategoria nasce chiusa e si
/// annuncia per quel che e'.
class _ArtSectionBox extends StatelessWidget {
  const _ArtSectionBox({
    required this.maestro,
    required this.section,
    required this.demo,
    required this.open,
    required this.soonOpen,
    required this.onToggleSection,
    required this.onToggleSoon,
  });

  final Maestro maestro;
  final ArtSection section;
  final bool demo;
  final bool open;
  final bool soonOpen;
  final VoidCallback onToggleSection;
  final VoidCallback onToggleSoon;

  String get _slug => section.title.toLowerCase();
  bool get _hasActive => ArtCatalog.hasActive(section);

  List<ArtEntry> get _subito => [
        for (final a in section.arts)
          if (a.state != ArtState.inArrivo) a,
      ];

  List<ArtEntry> get _inCammino => [
        for (final a in section.arts)
          if (a.state == ArtState.inArrivo) a,
      ];

  /// Il segno solare della persona, che serve alle arti che lo chiedono.
  Zodiac _userSign(BuildContext context) {
    final birth = context.read<BirthIdentityController>();
    final chart = birth.chart;
    if (chart != null) return chart.sunSign;
    return NightSky.sunSign(
        context.read<ProfileController>().identity.birthMoment);
  }

  Future<void> _openArt(BuildContext context, ArtEntry art) async {
    final profile = context.read<ProfileController>();
    final route = artRouteFor(
      art.id,
      userSign: _userSign(context),
      userBirth:
          profile.identity.isExample ? null : profile.identity.birthMoment,
      userName: profile.hasName ? profile.vocative : null,
    );
    if (route != null) {
      await Navigator.of(context).push(route);
      return;
    }
    // Mai un vicolo cieco: un anticipo elegante che dice a che punto e'.
    if (!context.mounted) return;
    await showArtPreview(context, art: art, maestro: maestro);
  }

  Widget _card(BuildContext context, ArtEntry art) => ScrollReveal(
        depth: 1,
        child: ArtCard(
          art: art,
          palette: context.palette,
          showPhase: demo,
          onTap: () => _openArt(context, art),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final subito = _subito;
    final inCammino = _inCammino;
    return Container(
      key: Key('art_section_$_slug'),
      padding: const EdgeInsets.all(SpacingTokens.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusXl),
        color: palette.deepest.withValues(alpha: 0.35),
        border: Border.all(color: palette.gold.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ScrollReveal(child: _header(context, palette)),
          // Dove c'e' del vivo, quel che si puo' fare adesso resta sempre in
          // vista: nel collasso finiscono soltanto le arti in cammino.
          if (_hasActive) ...[
            for (var i = 0; i < subito.length; i++) ...[
              if (i > 0) const SizedBox(height: SpacingTokens.sm),
              _card(context, subito[i]),
            ],
            if (inCammino.isNotEmpty) ...[
              const SizedBox(height: SpacingTokens.sm),
              _soonToggle(context, palette, inCammino.length),
              _Collassabile(
                aperto: soonOpen,
                child: Column(
                  children: [
                    for (final a in inCammino) ...[
                      const SizedBox(height: SpacingTokens.sm),
                      _card(context, a),
                    ],
                  ],
                ),
              ),
            ],
          ] else
            // Nessuna arte viva: tutta la sottocategoria sta dietro il collasso.
            _Collassabile(
              aperto: open,
              child: Column(
                children: [
                  for (final a in section.arts) ...[
                    const SizedBox(height: SpacingTokens.sm),
                    _card(context, a),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// L'intestazione: titolo, contatore delle arti visibili nella vista corrente
  /// e, quando non c'e' nulla di vivo, la dicitura onesta piu' la freccetta.
  /// Tutta la riga e' area di tocco, non la sola freccetta.
  Widget _header(BuildContext context, MaestroPalette palette) {
    final riga = Row(
      children: [
        // Il titolo si rimpicciolisce invece di spezzarsi a meta' parola: in
        // Cinzel, tutto maiuscolo, "Lunologia" andava a capo come LUNOL OGIA.
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              section.title,
              maxLines: 1,
              style: TypographyTokens.display(size: 18)
                  .copyWith(color: palette.goldSoft),
            ),
          ),
        ),
        const SizedBox(width: SpacingTokens.xs),
        // Il contatore delle arti della sottocategoria: dice a colpo d'occhio
        // quanto e' ampio il territorio, contando quel che si vede davvero.
        Text(
          '· ${section.arts.length}',
          key: Key('art_section_count_$_slug'),
          style: TypographyTokens.label(size: 13).copyWith(
            color: palette.goldSoft.withValues(alpha: 0.75),
            letterSpacing: 0.4,
          ),
        ),
        if (!_hasActive) ...[
          const SizedBox(width: SpacingTokens.xs),
          Text(
            '· In arrivo',
            key: Key('art_section_soon_$_slug'),
            style: TypographyTokens.label(size: 12).copyWith(
              color: ColorTokens.textSecondary,
              letterSpacing: 0.4,
            ),
          ),
          const Spacer(),
          _Freccetta(aperto: open, color: palette.goldSoft),
        ],
      ],
    );
    if (_hasActive) {
      return Padding(
        padding: const EdgeInsets.only(
            left: SpacingTokens.xs, bottom: SpacingTokens.sm),
        child: riga,
      );
    }
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: Key('art_section_header_$_slug'),
        onTap: onToggleSection,
        borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: SpacingTokens.xs, vertical: 4),
          child: riga,
        ),
      ),
    );
  }

  /// L'apri e chiudi delle sole arti in cammino, dentro una sottocategoria che
  /// ha gia' qualcosa di vivo.
  Widget _soonToggle(
      BuildContext context, MaestroPalette palette, int quante) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: Key('art_soon_toggle_$_slug'),
        onTap: onToggleSoon,
        borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: SpacingTokens.xs, vertical: 6),
          child: Row(
            children: [
              Text(
                'Altre arti in arrivo · $quante',
                style: TypographyTokens.label(size: 12).copyWith(
                  color: ColorTokens.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              _Freccetta(aperto: soonOpen, color: palette.goldSoft),
            ],
          ),
        ),
      ),
    );
  }
}

/// La freccetta che ruota per dire aperto o chiuso. Con movimento spento cambia
/// verso all'istante, senza rotazione.
class _Freccetta extends StatelessWidget {
  const _Freccetta({required this.aperto, required this.color});

  final bool aperto;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final immobile = ScrollReveal.motionOff(context);
    return AnimatedRotation(
      turns: aperto ? 0.5 : 0,
      duration: immobile ? Duration.zero : const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      child: Icon(Icons.expand_more_rounded, size: 22, color: color),
    );
  }
}

/// Il contenuto di un gruppo che si apre e si chiude.
///
/// L'apertura e' breve e coerente col resto; con Riduci Movimento di sistema o
/// con Quality Tier basso non c'e' animazione, il gruppo appare e sparisce
/// all'istante. La regola e' la stessa di `ScrollReveal.motionOff`, letta da un
/// punto solo.
class _Collassabile extends StatelessWidget {
  const _Collassabile({required this.aperto, required this.child});

  final bool aperto;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // A movimento spento non si mette nemmeno in mezzo il riquadro animato: il
    // gruppo c'e' o non c'e', senza nessuna misura da interpolare.
    if (ScrollReveal.motionOff(context)) {
      return aperto ? child : const SizedBox.shrink();
    }
    return AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: aperto
          ? child
          : const SizedBox(width: double.infinity, height: 0),
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
                          style: TypographyTokens.display(size: 16)
                              .copyWith(color: palette.textPrimary)),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(art.maestro.displayName,
                      style: TypographyTokens.label(size: 11).copyWith(
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
  // La fase e' un dato di piano: alla persona si dice soltanto che l'arte sta
  // arrivando, il dettaglio resta nella vista Demo per gli investitori.
  final fase = AppFlags.isDemo && art.phase != null
      ? ' La sua fase di lavorazione è ${art.phase}.'
      : '';
  final riga = art.state == ArtState.premium
      ? 'Questa arte è pronta e vive nel Cerchio: si apre '
          '${art.requiredTier == null ? 'con l\'abbonamento' : conPiano(PlanCatalog.forTier(art.requiredTier!).name)}.'
      : 'Questa arte è in cammino. Quando sarà pronta la troverai qui.$fase';
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
            // Le arti che la dichiarano portano sempre la loro cornice onesta.
            if (art.cornice) ...[
              const SizedBox(height: SpacingTokens.sm),
              Row(
                key: const Key('art_disclaimer_cornice'),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.eco_outlined, size: 15, color: palette.goldSoft),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      ArtCatalog.disclaimerCornice,
                      style: TypographyTokens.body(size: 13).copyWith(
                        color: ColorTokens.textSecondary,
                        height: 1.4,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ],
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
