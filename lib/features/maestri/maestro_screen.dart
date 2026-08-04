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
import '../../design_system/components/art_card.dart';
import '../../design_system/components/depth_card.dart';
import '../../design_system/components/collasso.dart';
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
import '../../core/arts/arti_preferite.dart';

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
              Collassabile(
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
            Collassabile(
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
          FreccettaDelCollasso(aperto: open, color: palette.goldSoft),
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
              FreccettaDelCollasso(aperto: soonOpen, color: palette.goldSoft),
            ],
          ),
        ),
      ),
    );
  }
}

/// Un'arte del cerchio nella striscia "Scopri altre arti del Cerchio": il
/// Maestro a cui appartiene, la funzione immersiva che apre, l'icona e il nome.
/// Un'arte della striscia del cerchio, col Maestro a cui appartiene.
///
/// Pubblica apposta, come il painter del sigillo: il colore della bolla e' una
/// cosa che un test deve poter misurare senza montare l'intero dominio con i
/// suoi servizi.
class CircleArt {
  const CircleArt({
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
/// Di chi e' un'arte, dal catalogo.
Maestro _maestroDi(ArtEntry a) {
  for (final m in Maestro.values) {
    if (ArtCatalog.activeOf(m).any((x) => x.id == a.id)) return m;
  }
  return Maestro.medora;
}

/// IL CRITERIO DELLA STRISCIA, come dato e non come lista scritta a mano.
///
/// **Perche' la lista e' sparita.** `_curatedArts` era una seconda fonte di
/// verita' accanto a `ArtCatalog`, e le due erano gia' divergenti: "Respiro
/// guidato" non esisteva nel catalogo, "Oracolo del Giorno" e "Runa del
/// Tramonto" non erano id del catalogo, e la Sinastria VIP apriva una schermata
/// dal catalogo e un'altra dalla striscia. Due elenchi che descrivono le stesse
/// arti divergono sempre: il secondo non viene aggiornato quando cambia il
/// primo, perche' nessuno si ricorda che esiste.
///
/// Adesso la striscia LEGGE IL CATALOGO e applica queste regole, che sono il
/// criterio e non un elenco:
/// - solo arti attive, mai quelle in arrivo;
/// - mai arti del Maestro il cui dominio si sta guardando;
/// - mai due voci sulla stessa rotta, che sarebbero due nomi per la stessa
///   schermata;
/// - mai arti gia' presenti nello scaffale personale;
/// - al massimo una per Maestro;
/// - ordine che ruota col giorno, cosi' la striscia non e' sempre uguale.
List<ArtEntry> artiDaScoprire(
  Maestro corrente, {
  required Set<String> gia,
  required DateTime giorno,
}) {
  final altri = Maestro.values.where((m) => m != corrente).toList();
  // La rotazione col giorno: da quale Maestro si comincia.
  final salto = giorno.difference(DateTime(2026)).inDays % altri.length;
  final ordinati = [
    ...altri.sublist(salto),
    ...altri.sublist(0, salto),
  ];

  final rotteViste = <String>{};
  final fuori = <ArtEntry>[];
  for (final m in ordinati) {
    final vive = ArtCatalog.activeOf(m).where((a) => !gia.contains(a.id));
    for (final a in vive) {
      // Due voci sulla stessa rotta sono due nomi per la stessa schermata, che
      // e' la bugia da cui e' nata questa voce: Meditazione e Respiro guidato
      // erano la stessa cosa con due nomi e due icone.
      final rotta = rottaDiProva(a.id);
      if (rotta == null || !rotteViste.add(rotta)) continue;
      fuori.add(a);
      break; // al massimo una per Maestro
    }
  }
  return fuori;
}

/// L'identita' della rotta di un'arte, per non mettere due voci sullo stesso
/// posto.
///
/// In esercizio si usa l'id: costruire il widget della rotta per confrontarne
/// il tipo funziona in prova e non qui, perche' alcune rotte leggono il
/// contesto nel proprio builder e un contesto finto le fa cadere. I doppioni
/// veri, cioe' due id che aprono la STESSA schermata, li smaschera una prova
/// che le costruisce in un albero vero.
String? rottaDiProva(String id) => artRouteFor(id) == null ? null : id;



/// La striscia orizzontale "Scopri altre arti del Cerchio": le arti degli altri
/// Maestri, ciascuna tessera nel COLORE del Maestro a cui l'arte appartiene,
/// cosi' si vede da subito di chi e'. Scorre in orizzontale, con un accenno di
/// contenuto oltre il bordo.
class _OtherArtsStrip extends StatelessWidget {
  const _OtherArtsStrip({required this.current});

  final Maestro current;

  @override
  Widget build(BuildContext context) {
    final gia = context.watch<ArtiPreferiteController?>()?.ids.toSet() ??
        const <String>{};
    final arts = artiDaScoprire(current, gia: gia, giorno: DateTime.now());

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
            itemBuilder: (context, i) => CircleArtTile(
              art: arts[i],
              maestro: _maestroDi(arts[i]),
              // Il colore del Maestro di quell'arte, non un neutro.
              palette:
                  MaestroPalette.forKey(ThemeKey.of(_maestroDi(arts[i]))),
            ),
          ),
        ),
      ],
    );
  }
}

/// Una tessera della striscia, nel colore del Maestro dell'arte. Al tocco apre
/// la funzione e vira il tema su quel Maestro, poi lo ripristina al ritorno.
class CircleArtTile extends StatelessWidget {
  const CircleArtTile({
    super.key,
    required this.art,
    required this.maestro,
    required this.palette,
  });

  /// L'arte, presa dal CATALOGO e non da una lista scritta a mano.
  final ArtEntry art;

  /// Il Maestro a cui l'arte appartiene, per il colore della tessera.
  final Maestro maestro;

  final MaestroPalette palette;

  Future<void> _open(BuildContext context) async {
    final route = artRouteFor(art.id);
    if (route == null) return;
    // Nessun cambio di tema qui. Il colore dell'arte lo dichiara l'arte
    // stessa, tramite il proprietario del suo MaestroScope, quindi c'e' dal
    // primo frame da qualunque strada si arrivi.
    //
    // Prima il tema veniva virato QUI, cioe' in questa singola tessera: chi
    // apriva la stessa arte dallo scaffale del suo Maestro, dalla chat o da
    // una rotta diretta entrava col colore di chi stava guardando prima, e al
    // primo ingresso nell'app col neutro. Per di piu' il ripristino era
    // condizionato a `previous != null`, quindi partendo dal tema neutro il
    // colore dell'arte restava addosso al Cerchio anche dopo essere usciti.
    await Navigator.of(context).push(route);
  }

  @override
  Widget build(BuildContext context) {
    // Il colore del PROPRIETARIO dell'arte, non quello del dominio in cui la
    // striscia sta ne' quello del tema attivo. Prima le bolle erano tutte nel
    // viola condiviso: la striscia diceva a parole di chi fosse ogni arte, con
    // una scritta piccola sotto il nome, senza mostrarlo. Il colpo d'occhio
    // visivo viene prima del testo, quindi il proprietario si riconosce senza
    // leggere.
    //
    // Il fondo condiviso resta sotto, velato: la striscia continua a essere
    // una striscia sola, non tre strisce accostate.
    final propria = MaestroPalette.forKey(ThemeKey.of(maestro));
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: Key('other_art_${art.id}'),
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
                // Il colore del Maestro sopra il viola condiviso: si riconosce
                // il proprietario senza che la tessera urli.
                Color.alphaBlend(
                  propria.primary.withValues(alpha: 0.55),
                  palette.surfaceElevated,
                ).withValues(alpha: 0.92),
                Color.alphaBlend(
                  propria.primary.withValues(alpha: 0.22),
                  palette.surface,
                ).withValues(alpha: 0.78),
              ],
            ),
            border: Border.all(color: propria.gold.withValues(alpha: 0.45)),
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
                  color: propria.primary,
                  border:
                      Border.all(color: propria.gold.withValues(alpha: 0.75)),
                ),
                alignment: Alignment.center,
                child: Icon(art.icon, color: propria.goldSoft, size: 22),
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
                  Text(maestro.displayName,
                      style: TypographyTokens.label(size: 11).copyWith(
                        color: propria.goldSoft.withValues(alpha: 0.95),
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
                  'Dialoga, chiedi e metti a confronto gli sguardi del Cerchio.',
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
            // LA CORNICE ONESTA E' USCITA DA QUI, ed era uno dei SETTE
            // disclaimer a schermo. Le linee guida dicevano da sempre
            // "una volta sola", e per sette volte ognuno ha pensato
            // che il proprio fosse quella volta. Adesso sta in un
            // posto solo, nell'area privacy.
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
