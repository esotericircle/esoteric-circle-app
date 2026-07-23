import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/archetypes/archetype.dart';
import '../../../../core/archetypes/archetype_history.dart';
import '../../../../core/archetypes/archetype_sky.dart';
import '../../../../core/archetypes/archetype_transits.dart' show Pianeta;
import '../../../../core/astro/zodiac.dart';
import '../../../../core/maestro/maestro.dart';
import '../../../../core/rituals/animal_catalog.dart';
import '../../../../core/rituals/guide_animal_corpus.dart';
import '../../../../core/rituals/guide_animal_derivation.dart';
import '../../../../design_system/components/cosmos_background.dart';
import '../../../../design_system/components/depth_card.dart';
import '../../../../design_system/components/scroll_reveal.dart';
import '../../../../design_system/theme/maestro_palette.dart';
import '../../../../design_system/theme/maestro_scope.dart';
import '../../../../design_system/tokens/color_tokens.dart';
import '../../../../design_system/tokens/spacing_tokens.dart';
import '../../../../design_system/tokens/typography_tokens.dart';
import '../../../../services/app_services.dart';
import '../../../maestri/aura/archetype/archetype_test_screen.dart';
import '../../chat/chat_openers.dart';
import '../../chat/maestro_chat_screen.dart';
import 'animal_journey.dart';
import 'animal_reveal.dart';
import 'guide_animal_share_card.dart';

/// Come si entra nell'Animale Guida.
///
/// `viaggio`, dal dominio di Caligo: il viaggio col tamburo, poi il messaggio
/// del momento, sempre nuovo, con Chiedi ancora. E' l'esperienza ripetibile, il
/// motivo per tornare. `identita`, dal Cosmic Passport: la lettura fissa di chi
/// e' il tuo animale, natura dono lezione, che non cambia mai.
enum GuideAnimalMode { viaggio, identita }

/// L'Animale Guida, dominio Caligo.
///
/// L'animale si deriva dal segno solare, deterministico e fisso per persona
/// (`GuideAnimalDerivation`), col cielo come ponte di curatela dichiarato.
/// Se manca il Test Archetipo, all'ingresso un popup evocativo invita al Test ma
/// lascia proseguire. Se un archetipo c'e', alla lettura di identita' si aggiunge
/// la sezione che lo intreccia col totem, senza cambiare l'animale. Il messaggio
/// del momento e' scelto dal giorno e dal cielo, deterministico, nessuna AI.
class GuideAnimalScreen extends StatefulWidget {
  const GuideAnimalScreen({
    super.key,
    required this.userSign,
    this.clock,
    this.pianetiDelGiorno,
    this.modo = GuideAnimalMode.viaggio,
  });

  final Zodiac userSign;
  final DateTime Function()? clock;
  final Set<Pianeta> Function(DateTime)? pianetiDelGiorno;

  /// Da dove si entra: il viaggio ripetibile o la lettura fissa di identita'.
  final GuideAnimalMode modo;

  static Route<void> route({
    required Zodiac userSign,
    DateTime Function()? clock,
    Set<Pianeta> Function(DateTime)? pianetiDelGiorno,
    GuideAnimalMode modo = GuideAnimalMode.viaggio,
  }) {
    return MaterialPageRoute<void>(
      builder: (_) => MaestroScope(
        child: GuideAnimalScreen(
          userSign: userSign,
          clock: clock,
          pianetiDelGiorno: pianetiDelGiorno,
          modo: modo,
        ),
      ),
    );
  }

  @override
  State<GuideAnimalScreen> createState() => _GuideAnimalScreenState();
}

enum _Fase { viaggio, messaggio }

class _GuideAnimalScreenState extends State<GuideAnimalScreen> {
  late final DateTime Function() _clock = widget.clock ?? DateTime.now;
  late final ArchetypeHistory _storico = ArchetypeHistory(clock: _clock);

  bool _pronto = false;
  bool _popupFatto = false;
  Archetype? _archetipo;

  /// La fase vale solo nel modo viaggio. In identita' si va dritti alla lettura.
  late _Fase _fase = _Fase.viaggio;

  /// Quante volte l'utente ha chiesto ancora, entro il piccolo limite del corpus.
  int _tiro = 0;

  GuideAnimal get _animal => GuideAnimalDerivation.forSign(widget.userSign);

  void _viaggioCompiuto() {
    if (mounted) setState(() => _fase = _Fase.messaggio);
  }

  void _chiediAncora() {
    if (_tiro >= GuideAnimalCorpus.maxTiri) return;
    setState(() => _tiro++);
  }

  void _apriIdentita() {
    Navigator.of(context).push(GuideAnimalScreen.route(
      userSign: widget.userSign,
      clock: widget.clock,
      pianetiDelGiorno: widget.pianetiDelGiorno,
      modo: GuideAnimalMode.identita,
    ));
  }

  @override
  void initState() {
    super.initState();
    _storico.carica().then((_) {
      if (!mounted) return;
      setState(() {
        _archetipo = _storico.ultimo?.dominante;
        _pronto = true;
      });
      // Se manca il Test Archetipo, il popup evocativo, che lascia proseguire.
      if (_archetipo == null && !_popupFatto) {
        _popupFatto = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _mostraPopup(context);
        });
      }
    });
  }

  @override
  void dispose() {
    _storico.dispose();
    super.dispose();
  }

  Set<Pianeta> get _pianeti {
    final f = widget.pianetiDelGiorno ?? ArchetypeSky.pianetiDelGiorno;
    return f(_clock());
  }

  String get _origine => _archetipo != null
      ? 'Dal tuo cielo, ${widget.userSign.italianName}, intrecciato col tuo archetipo'
      : 'Dal tuo cielo, ${widget.userSign.italianName}';

  @override
  Widget build(BuildContext context) {
    final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.caligo));
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: palette.deepest.withValues(alpha: 0.35),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: palette.goldSoft),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Indietro',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text('Animale Guida',
              maxLines: 1, style: TypographyTokens.display(size: 19)),
        ),
        actions: [
          IconButton(
            key: const Key('animal_sources'),
            icon: const Icon(Icons.info_outline_rounded),
            tooltip: 'Fonti e metodo',
            onPressed: () => _mostraFonti(context, palette),
          ),
        ],
      ),
      body: CosmosBackground(
        showZodiac: false,
        child: SafeArea(
          child: !_pronto
              ? const SizedBox.shrink()
              : widget.modo == GuideAnimalMode.identita
                  ? _Identita(
                      palette: palette,
                      animal: _animal,
                      userSign: widget.userSign,
                      archetipo: _archetipo,
                      origine: _origine,
                    )
                  : switch (_fase) {
                      _Fase.viaggio => AnimalJourney(
                          palette: palette, onComplete: _viaggioCompiuto),
                      _Fase.messaggio => _Messaggio(
                          palette: palette,
                          animal: _animal,
                          origine: _origine,
                          messaggio: GuideAnimalCorpus.messaggioDelGiorno(
                              _animal, _clock(), _pianeti,
                              tiro: _tiro),
                          puoAncora: _tiro < GuideAnimalCorpus.maxTiri,
                          onAncora: _chiediAncora,
                          onIdentita: _apriIdentita,
                        ),
                    },
        ),
      ),
    );
  }

  void _mostraPopup(BuildContext context) {
    final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.caligo));
    final verdeAura = MaestroPalette.forKey(const ThemeKey.of(Maestro.aura));
    showDialog<void>(
      context: context,
      barrierColor: palette.deepest.withValues(alpha: 0.7),
      builder: (dialog) => Dialog(
        key: const Key('animal_test_popup'),
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(SpacingTokens.lg),
        child: Container(
          padding: const EdgeInsets.all(SpacingTokens.lg),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [palette.surfaceElevated, palette.deepest],
            ),
            borderRadius: BorderRadius.circular(SpacingTokens.radiusXl),
            border: Border.all(color: palette.gold.withValues(alpha: 0.4)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Il tuo animale ti sta cercando',
                  style: TypographyTokens.display(size: 21)
                      .copyWith(color: palette.goldSoft)),
              const SizedBox(height: SpacingTokens.sm),
              Text(
                'Posso rivelarlo ora, leggendolo dal tuo cielo di nascita. Ma se '
                'prima ascolti chi sei nel profondo, il tuo totem ti somiglierà '
                'di più. Il Test Archetipo dura tre minuti e rende questa '
                'rivelazione tua fino in fondo.',
                style: TypographyTokens.body(size: 15).copyWith(
                    color: ColorTokens.textPrimary, height: 1.5),
              ),
              const SizedBox(height: SpacingTokens.lg),
              // Verde di Aura, non rosso di Caligo: il Test Archetipo e' un'arte
              // di Aura, e il colore segnala dove porta il pulsante.
              FilledButton(
                key: const Key('animal_popup_test'),
                style: FilledButton.styleFrom(
                    backgroundColor: verdeAura.primary,
                    foregroundColor: verdeAura.onPrimary,
                    minimumSize: const Size.fromHeight(48)),
                onPressed: () {
                  Navigator.of(dialog).pop();
                  Navigator.of(context).push(ArchetypeTestScreen.route());
                },
                child: const Text('Fai il Test Archetipo'),
              ),
              const SizedBox(height: SpacingTokens.sm),
              OutlinedButton(
                key: const Key('animal_popup_reveal'),
                style: OutlinedButton.styleFrom(
                    foregroundColor: palette.goldSoft,
                    minimumSize: const Size.fromHeight(48),
                    side:
                        BorderSide(color: palette.gold.withValues(alpha: 0.6))),
                onPressed: () => Navigator.of(dialog).pop(),
                child: const Text('Rivelalo dal mio cielo'),
              ),
              const SizedBox(height: SpacingTokens.sm),
              Text(
                'Potrai tornare e rivederlo quando vuoi, o dopo aver fatto il Test.',
                style: TypographyTokens.label(size: 11).copyWith(
                    color: ColorTokens.textSecondary, letterSpacing: 0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostraFonti(BuildContext context, MaestroPalette palette) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheet) => Container(
        key: const Key('animal_sources_sheet'),
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
              Text('Fonti e metodo',
                  style: TypographyTokens.display(size: 19)
                      .copyWith(color: palette.goldSoft)),
              const SizedBox(height: SpacingTokens.sm),
              Text(GuideAnimalCorpus.fontiEMetodo,
                  style: TypographyTokens.body(size: 15).copyWith(
                      color: ColorTokens.textPrimary, height: 1.45)),
              const SizedBox(height: SpacingTokens.lg),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(sheet).pop(),
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
}

/// Il messaggio del momento, dopo il viaggio col tamburo: il totem affiora dalla
/// nebbia e l'animale porta un segno sempre nuovo. Sotto, Chiedi ancora per un
/// secondo tiro, il rimando alla lettura di chi e' il tuo animale, poi Condividi
/// e Parlane con Caligo. E' l'esperienza ripetibile, il motivo per tornare.
class _Messaggio extends StatelessWidget {
  const _Messaggio({
    required this.palette,
    required this.animal,
    required this.origine,
    required this.messaggio,
    required this.puoAncora,
    required this.onAncora,
    required this.onIdentita,
  });

  final MaestroPalette palette;
  final GuideAnimal animal;
  final String origine;
  final String messaggio;
  final bool puoAncora;
  final VoidCallback onAncora;
  final VoidCallback onIdentita;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const Key('animal_result'),
      padding: const EdgeInsets.all(SpacingTokens.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: SpacingTokens.sm),
          // LA RIVELAZIONE del totem nella nebbia.
          Center(
            child: AnimalReveal(
                assetTotem: animal.fullPath, palette: palette, lato: 300),
          ),
          const SizedBox(height: SpacingTokens.md),
          Center(
            child: Text(animal.name.toUpperCase(),
                key: const Key('animal_name'),
                style: TypographyTokens.display(size: 30)
                    .copyWith(color: palette.goldSoft)),
          ),
          Center(
            child: Text(animal.summary,
                textAlign: TextAlign.center,
                style: TypographyTokens.body(size: 16).copyWith(
                    color: ColorTokens.textSecondary,
                    fontStyle: FontStyle.italic)),
          ),
          const SizedBox(height: SpacingTokens.lg),
          // IL MESSAGGIO DEL MOMENTO, il segno che l'animale porta ora.
          ScrollReveal(
            depth: 1,
            child: DepthCard(
              key: const Key('animal_daily_message'),
              raised: true,
              padding: const EdgeInsets.all(SpacingTokens.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.nightlight_round,
                          size: 16, color: palette.goldSoft),
                      const SizedBox(width: SpacingTokens.xs),
                      Text('Messaggio dall\'Animale',
                          style: TypographyTokens.label(size: 12).copyWith(
                              color: palette.goldSoft, letterSpacing: 0.6)),
                    ],
                  ),
                  const SizedBox(height: SpacingTokens.xs),
                  Text(messaggio,
                      key: const Key('animal_message_text'),
                      style: TypographyTokens.body(size: 16).copyWith(
                          color: ColorTokens.textPrimary, height: 1.5)),
                ],
              ),
            ),
          ),
          const SizedBox(height: SpacingTokens.md),
          // CHIEDI ANCORA, per un altro tiro dal repertorio, entro il limite.
          OutlinedButton.icon(
            key: const Key('animal_ask_again'),
            style: OutlinedButton.styleFrom(
                foregroundColor: palette.goldSoft,
                side: BorderSide(
                    color: palette.gold
                        .withValues(alpha: puoAncora ? 0.6 : 0.2))),
            onPressed: puoAncora ? onAncora : null,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(puoAncora
                ? 'Chiedi ancora'
                : 'Torna domani per un nuovo segno'),
          ),
          const SizedBox(height: SpacingTokens.sm),
          // CHI E' IL TUO ANIMALE, il rimando alla lettura fissa di identita'.
          TextButton.icon(
            key: const Key('animal_identity_link'),
            onPressed: onIdentita,
            icon: Icon(Icons.auto_stories_outlined,
                size: 18, color: palette.goldSoft),
            label: Text("Chi è il tuo animale",
                style: TypographyTokens.label(size: 13)
                    .copyWith(color: palette.goldSoft)),
          ),
          const SizedBox(height: SpacingTokens.md),
          _Azioni(palette: palette, animal: animal, origine: origine),
          const SizedBox(height: SpacingTokens.xxxl),
        ],
      ),
    );
  }
}

/// La lettura fissa di identita': chi e' il tuo animale, natura dono lezione,
/// quando ti guida, l'invito, e se c'e' il Test, l'intreccio con l'archetipo.
/// Non cambia mai, e' la carta d'identita' del tuo totem. Si apre dal Cosmic
/// Passport e dal rimando nel messaggio del momento.
class _Identita extends StatelessWidget {
  const _Identita({
    required this.palette,
    required this.animal,
    required this.userSign,
    required this.archetipo,
    required this.origine,
  });

  final MaestroPalette palette;
  final GuideAnimal animal;
  final Zodiac userSign;
  final Archetype? archetipo;
  final String origine;

  @override
  Widget build(BuildContext context) {
    final r = GuideAnimalCorpus.di(animal.name);
    return SingleChildScrollView(
      key: const Key('animal_identity'),
      padding: const EdgeInsets.all(SpacingTokens.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: SpacingTokens.sm),
          Center(
            child: AnimalReveal(
                assetTotem: animal.fullPath, palette: palette, lato: 300),
          ),
          const SizedBox(height: SpacingTokens.md),
          Center(
            child: Text(animal.name.toUpperCase(),
                key: const Key('animal_name'),
                style: TypographyTokens.display(size: 30)
                    .copyWith(color: palette.goldSoft)),
          ),
          Center(
            child: Text(animal.summary,
                textAlign: TextAlign.center,
                style: TypographyTokens.body(size: 16).copyWith(
                    color: ColorTokens.textSecondary,
                    fontStyle: FontStyle.italic)),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(origine,
                  textAlign: TextAlign.center,
                  style: TypographyTokens.label(size: 11).copyWith(
                      color: palette.goldSoft.withValues(alpha: 0.8),
                      letterSpacing: 0.5)),
            ),
          ),
          const SizedBox(height: SpacingTokens.lg),
          _Bolla(chiave: 'animal_natura', titolo: 'La sua natura', testo: r.natura, palette: palette),
          const SizedBox(height: SpacingTokens.md),
          _Bolla(chiave: 'animal_dono', titolo: 'Il dono', testo: r.dono, palette: palette),
          const SizedBox(height: SpacingTokens.md),
          _Bolla(chiave: 'animal_lezione', titolo: 'La lezione', testo: r.lezione, palette: palette),
          const SizedBox(height: SpacingTokens.md),
          _Bolla(chiave: 'animal_quando', titolo: 'Quando ti guida', testo: r.quando, palette: palette),
          const SizedBox(height: SpacingTokens.md),
          _Bolla(chiave: 'animal_invito', titolo: "L'invito", testo: r.invito, palette: palette),

          // LA SEZIONE DELL'ARCHETIPO, solo se c'e' un risultato del Test.
          if (archetipo != null) ...[
            const SizedBox(height: SpacingTokens.md),
            _Bolla(
              chiave: 'animal_archetipo',
              titolo: 'Con il tuo archetipo',
              testo: GuideAnimalCorpus.intreccioArchetipo(animal, archetipo!),
              palette: palette,
            ),
          ],

          const SizedBox(height: SpacingTokens.lg),
          _Azioni(palette: palette, animal: animal, origine: origine),
          const SizedBox(height: SpacingTokens.xxxl),
        ],
      ),
    );
  }
}

/// Una bolla di lettura: etichetta oro e testo, nello stile dei responsi.
class _Bolla extends StatelessWidget {
  const _Bolla({
    required this.chiave,
    required this.titolo,
    required this.testo,
    required this.palette,
  });

  final String chiave;
  final String titolo;
  final String testo;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return ScrollReveal(
      depth: 1,
      child: DepthCard(
        key: Key(chiave),
        raised: true,
        padding: const EdgeInsets.all(SpacingTokens.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titolo,
                style: TypographyTokens.label(size: 12)
                    .copyWith(color: palette.goldSoft, letterSpacing: 0.6)),
            const SizedBox(height: SpacingTokens.xs),
            Text(testo,
                style: TypographyTokens.body(size: 16)
                    .copyWith(color: ColorTokens.textPrimary, height: 1.55)),
          ],
        ),
      ),
    );
  }
}

/// Condividi e Parlane con Caligo, piu' la card fuori campo per lo scatto.
class _Azioni extends StatefulWidget {
  const _Azioni({required this.palette, required this.animal, required this.origine});

  final MaestroPalette palette;
  final GuideAnimal animal;
  final String origine;

  @override
  State<_Azioni> createState() => _AzioniState();
}

class _AzioniState extends State<_Azioni> {
  final GlobalKey _cardBoundary = GlobalKey();
  bool _condividendo = false;
  bool _renderCard = false;

  Future<void> _condividi() async {
    setState(() {
      _condividendo = true;
      _renderCard = true;
    });
    try {
      await WidgetsBinding.instance.endOfFrame;
      await Future<void>.delayed(const Duration(milliseconds: 80));
      await shareGuideAnimalCard(
          boundaryKey: _cardBoundary, animal: widget.animal);
    } finally {
      if (mounted) setState(() => _condividendo = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    return Stack(
      children: [
        // Larghezza piena e pulsanti stirati, cosi' sono centrati orizzontalmente
        // come negli altri responsi, non piu' a sinistra col Column a contenuto.
        SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OutlinedButton.icon(
                key: const Key('animal_share'),
                style: OutlinedButton.styleFrom(
                    foregroundColor: palette.goldSoft,
                    side:
                        BorderSide(color: palette.gold.withValues(alpha: 0.6))),
                onPressed: _condividendo ? null : _condividi,
                icon: const Icon(Icons.ios_share_rounded),
                label: const Text('Condividi'),
              ),
              const SizedBox(height: SpacingTokens.sm),
              FilledButton.icon(
                key: const Key('animal_consulta'),
                style: FilledButton.styleFrom(
                    backgroundColor: palette.primary,
                    foregroundColor: palette.onPrimary),
                onPressed: () {
                  final services = context.read<AppServices>();
                  Navigator.of(context).push(MaestroChatScreen.route(
                      maestro: Maestro.caligo,
                      services: services,
                      initialUserMessage:
                          ChatOpeners.animale(widget.animal.name)));
                },
                icon: const Icon(Icons.forum_outlined),
                label: const Text('Parlane con Caligo'),
              ),
            ],
          ),
        ),
        if (_renderCard)
          Positioned(
            left: -3000,
            top: 0,
            child: RepaintBoundary(
              key: _cardBoundary,
              child: GuideAnimalShareCard(
                  animal: widget.animal, origine: widget.origine),
            ),
          ),
      ],
    );
  }
}
