import 'dart:async';
import 'package:flutter/material.dart';
import '../../../sigilli/regia_del_cammino.dart';
import 'package:provider/provider.dart';

import '../../../../core/archetypes/archetype.dart';
import '../../../../core/archetypes/archetype_history.dart';
import '../../../../core/astro/zodiac.dart';
import '../../../../core/maestro/maestro.dart';
import '../../../../core/rituals/animal_catalog.dart';
import '../../../../core/rituals/guide_animal_corpus.dart';
import '../../../../core/rituals/guide_animal_day.dart';
import '../../../../core/rituals/guide_animal_derivation.dart';
import '../../../../design_system/components/cosmos_background.dart';
import '../../../../design_system/components/depth_card.dart';
import '../../../../design_system/components/scroll_reveal.dart';
import '../../../../design_system/theme/maestro_palette.dart';
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
import '../../rotta_arte.dart';

/// Come si entra nell'Animale Guida.
///
/// `viaggio`, dal dominio di Caligo: il viaggio col tamburo, poi il Messaggio
/// del Giorno, uno al giorno dal transito reale che tocca la carta, col blocco
/// di trasparenza che dichiara come nasce. `identita`, dal Cosmic Passport: la
/// lettura fissa di chi e' il tuo animale, natura dono lezione, che non cambia.
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
    this.userBirth,
    this.clock,
    this.modo = GuideAnimalMode.viaggio,
  });

  final Zodiac userSign;

  /// La data di nascita, se nota: serve solo a mostrare la Luna natale nella
  /// trasparenza del Messaggio del Giorno. Il Sole natale e' gia' `userSign`.
  final DateTime? userBirth;
  final DateTime Function()? clock;

  /// Da dove si entra: il viaggio ripetibile o la lettura fissa di identita'.
  final GuideAnimalMode modo;

  /// LA SOGLIA DI QUESTA ARTE, dichiarata una volta sola. Ordine P voce 27.
  ///
  /// **Perche' esiste.** L'identificativo dell'arte e il suo Maestro erano
  /// scritti dentro `route`, cioe' in un punto che solo l'app attraversa. Le
  /// anteprime montavano la schermata NUDA, con un `MaestroScope` costruito a
  /// mano: senza `ArteCorrente` e senza `ConCuore`, quindi senza il cuore delle
  /// arti preferite nella barra, e con la palette presa dal controller invece
  /// che dichiarata dal proprietario. Provavano una scena che l'app non monta.
  ///
  /// Adesso la soglia si chiede da qui, e la chiedono tutti e due: la rotta
  /// dell'app e la cattura dell'anteprima. Un solo punto dichiara chi e' il
  /// proprietario di quest'arte.
  static Widget conLaSoglia(Widget schermata) => SogliaArte(
        id: 'guide_animal',
        maestro: Maestro.caligo,
        child: schermata,
      );

  static Route<void> route({
    required Zodiac userSign,
    DateTime? userBirth,
    DateTime Function()? clock,
    GuideAnimalMode modo = GuideAnimalMode.viaggio,
  }) {
    return MaterialPageRoute<void>(
      builder: (_) => conLaSoglia(GuideAnimalScreen(
          userSign: userSign,
          userBirth: userBirth,
          clock: clock,
          modo: modo,
        )),
    );
  }

  @override
  State<GuideAnimalScreen> createState() => _GuideAnimalScreenState();
}

enum _Fase { viaggio, messaggio }

class _GuideAnimalScreenState extends State<GuideAnimalScreen> {
  late final DateTime Function() _clock = widget.clock ?? DateTime.now;

  /// LO STORICO E' QUELLO DI TUTTI, non uno suo. Qui c'era una seconda copia,
  /// terza nel progetto: chi legge l'archetipo lo legge dal fornitore, che e'
  /// l'unico posto dove quel dato vive. Vedi la nota piu' lunga in
  /// `archetype_test_screen.dart`, dove la copia privata faceva danno vero.
  ArchetypeHistory get _storico => context.read<ArchetypeHistory>();

  bool _pronto = false;
  bool _popupFatto = false;
  Archetype? _archetipo;

  /// La fase vale solo nel modo viaggio. In identita' si va dritti alla lettura.
  late _Fase _fase = _Fase.viaggio;

  GuideAnimal get _animal => GuideAnimalDerivation.forSign(widget.userSign);

  void _viaggioCompiuto() {
    if (mounted) setState(() => _fase = _Fase.messaggio);
  }

  void _apriIdentita() {
    Navigator.of(context).push(GuideAnimalScreen.route(
      userSign: widget.userSign,
      userBirth: widget.userBirth,
      clock: widget.clock,
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
      // L'ANIMALE GUIDA ENTRA NEL CAMMINO, ordine P voce 35: terzo Sigillo
      // di aggancio trasversale.
      unawaited(RegiaDelCammino.dopoUnGesto(context, 'animale_guida'));
      // Se manca il Test Archetipo, il popup evocativo, che lascia proseguire.
      if (_archetipo == null && !_popupFatto) {
        _popupFatto = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _mostraPopup(context);
        });
      }
    });
  }

  // NESSUN dispose dello storico: non e' di questa schermata, e chiuderlo
  // uscendo dal viaggio spegnerebbe il dato anche per la chat e il Passaporto.

  String get _origine => _archetipo != null
      ? 'Dal tuo cielo, ${widget.userSign.italianName}, intrecciato col tuo archetipo'
      : 'Dal tuo cielo, ${widget.userSign.italianName}';

  @override
  Widget build(BuildContext context) {
    final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.caligo));
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: BarraArte(
        titolo: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text('Animale Guida',
              maxLines: 1, style: TypographyTokens.display(size: 19)),
        ),
        azioni: [
          IconButton(
            key: const Key('animal_sources'),
            icon: const Icon(Icons.info_outline_rounded),
            tooltip: 'Fonti e metodo',
            onPressed: () => _mostraFonti(context, palette),
          ),
        ],
      ),
      body: CosmosBackground(
        seed: 9,
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
                          palette: palette,
                          animal: _animal,
                          onComplete: _viaggioCompiuto),
                      _Fase.messaggio => _Messaggio(
                          palette: palette,
                          animal: _animal,
                          origine: _origine,
                          messaggio: GuideAnimalDay.per(
                            animale: _animal,
                            soleNatale: widget.userSign,
                            giorno: _clock(),
                            nascita: widget.userBirth,
                          ),
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
                style: TypographyTokens.corpo().copyWith(
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
                style: TypographyTokens.etichetta().copyWith(
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
                  style: TypographyTokens.corpo().copyWith(
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

/// Il Messaggio del Giorno, dopo il viaggio col tamburo: il totem affiora dalla
/// nebbia e l'animale porta un segno, uno solo al giorno, dal transito reale che
/// tocca la carta dell'utente. Sotto il messaggio, il blocco di trasparenza che
/// dichiara come nasce, poi il rimando alla lettura di identita', Condividi e
/// Parlane con Caligo. Deterministico dalla data e dalla carta, nessuna AI.
class _Messaggio extends StatelessWidget {
  const _Messaggio({
    required this.palette,
    required this.animal,
    required this.origine,
    required this.messaggio,
    required this.onIdentita,
  });

  final MaestroPalette palette;
  final GuideAnimal animal;
  final String origine;
  final MessaggioDelGiorno messaggio;
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
          // IL MESSAGGIO DEL GIORNO, il segno che l'animale porta oggi.
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
                      Text('Messaggio del Giorno',
                          style: TypographyTokens.label(size: 12).copyWith(
                              color: palette.goldSoft, letterSpacing: 0.6)),
                    ],
                  ),
                  const SizedBox(height: SpacingTokens.xs),
                  Text(messaggio.testo,
                      key: const Key('animal_message_text'),
                      style: TypographyTokens.body(size: 16).copyWith(
                          color: ColorTokens.textPrimary, height: 1.5)),
                ],
              ),
            ),
          ),
          const SizedBox(height: SpacingTokens.md),
          // LA TRASPARENZA: come nasce il messaggio di oggi, in chiaro.
          _Trasparenza(palette: palette, messaggio: messaggio),
          const SizedBox(height: SpacingTokens.md),
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

/// Il blocco di trasparenza, dichiarato in chiaro: da dove nasce il messaggio di
/// oggi. Il transito in parole e i dati della carta natale usati nel calcolo,
/// generati dagli stessi dati, non scritti a mano caso per caso.
class _Trasparenza extends StatelessWidget {
  const _Trasparenza({required this.palette, required this.messaggio});

  final MaestroPalette palette;
  final MessaggioDelGiorno messaggio;

  @override
  Widget build(BuildContext context) {
    final etichetta = TypographyTokens.etichetta()
        .copyWith(color: palette.goldSoft, letterSpacing: 0.5);
    final corpo = TypographyTokens.corpo()
        .copyWith(color: ColorTokens.textPrimary, height: 1.4);
    return DepthCard(
      key: const Key('animal_transparency'),
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.public_outlined, size: 15, color: palette.goldSoft),
              const SizedBox(width: SpacingTokens.xs),
              Text('Come nasce il messaggio di oggi',
                  style: TypographyTokens.label(size: 12).copyWith(
                      color: palette.goldSoft, letterSpacing: 0.6)),
            ],
          ),
          const SizedBox(height: SpacingTokens.sm),
          Text('Il transito di oggi', style: etichetta),
          const SizedBox(height: 2),
          Text(messaggio.transito, key: const Key('animal_transit'), style: corpo),
          const SizedBox(height: SpacingTokens.sm),
          Text('Dalla tua carta natale', style: etichetta),
          const SizedBox(height: 2),
          Text(messaggio.datiNatali,
              key: const Key('animal_natal_data'), style: corpo),
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
                  style: TypographyTokens.etichetta().copyWith(
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
