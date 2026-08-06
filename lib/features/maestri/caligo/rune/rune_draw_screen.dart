import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../../../../core/astro/zodiac.dart';
import '../../../../core/maestro/maestro.dart';
import '../../../../core/rituals/rune_cast.dart';
import '../../../../core/rituals/rune_presage.dart';
import '../../../../design_system/components/cosmos_background.dart';
import '../../../../design_system/components/depth_card.dart';
import '../../../../design_system/components/scroll_reveal.dart';
import '../../../../design_system/theme/maestro_palette.dart';
import '../../../../design_system/tokens/color_tokens.dart';
import '../../../../design_system/tokens/spacing_tokens.dart';
import '../../../../design_system/tokens/typography_tokens.dart';
import '../../../../services/app_services.dart';
import '../../../../core/rituals/runes.dart';
import '../../../rituals/rune_strokes.dart';
import '../../../rituals/sunset_rune_screen.dart' show pathVergineDi;
import '../../chat/chat_openers.dart';
import '../../chat/maestro_chat_screen.dart';
import 'bindrune.dart';
import 'rune_share_card.dart';
import '../../rotta_arte.dart';
import '../../../../core/sensi/palette_sensoriale.dart';

/// L'Estrazione Rune, dominio Caligo: lettura a richiesta e ripetibile, col
/// selettore del tipo di gettata. Il caso e' voluto e autentico, e' gettare le
/// sorti a ogni lancio. Deterministico solo il presagio, zero AI a runtime.
class RuneDrawScreen extends StatefulWidget {
  const RuneDrawScreen({
    super.key,
    required this.userSign,
    this.userBirth,
    this.random,
  });

  final Zodiac userSign;

  /// La data di nascita, se nota. Non usata ora: e' il gancio per la futura
  /// personalizzazione del presagio sul cielo della persona.
  final DateTime? userBirth;

  /// Sorgente del caso, iniettabile nei test e nelle catture per un lancio
  /// riproducibile. A runtime resta null, un vero lancio senza seme.
  final math.Random? random;

  static Route<void> route({
    required Zodiac userSign,
    DateTime? userBirth,
    math.Random? random,
  }) {
    return MaterialPageRoute<void>(
      builder: (_) => SogliaArte(
        id: 'rune_draw',
        maestro: Maestro.caligo,
        child: RuneDrawScreen(
            userSign: userSign, userBirth: userBirth, random: random),
      ),
    );
  }

  @override
  State<RuneDrawScreen> createState() => _RuneDrawScreenState();
}

enum _Fase { preparazione, responso }

class _RuneDrawScreenState extends State<RuneDrawScreen> {
  final TextEditingController _domanda = TextEditingController();
  GettataRune _gettata = gettate.first;
  _Fase _fase = _Fase.preparazione;
  EsitoGettata? _esito;
  bool _animazioni = true;
  StreamSubscription<AccelerometerEvent>? _shakeSub;

  @override
  void initState() {
    super.initState();
    _ascoltaScuotimento();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _animazioni = !ScrollReveal.motionOff(context);
  }

  @override
  void dispose() {
    _shakeSub?.cancel();
    _domanda.dispose();
    super.dispose();
  }

  // Scuotimento: un picco netto dell'accelerazione getta le rune. Il tocco sul
  // pulsante resta il ripiego tattile universale.
  void _ascoltaScuotimento() {
    try {
      _shakeSub = accelerometerEventStream(
        samplingPeriod: const Duration(milliseconds: 66),
      ).listen((e) {
        final m = math.sqrt(e.x * e.x + e.y * e.y + e.z * e.z);
        if (m > 22) _getta();
      }, onError: (_) {}, cancelOnError: false);
    } catch (_) {
      // Nessun accelerometro: si getta col pulsante.
    }
  }

  void _cambiaGettata(GettataRune g) {
    if (g.id == _gettata.id) return;
    setState(() => _gettata = g);
  }

  void _getta() {
    if (_fase == _Fase.responso) return;
    PaletteSensoriale.eseguiSchema(SchemaAptico.conferma);
    _shakeSub?.cancel();
    setState(() {
      _esito = RuneCast.getta(_gettata, random: widget.random);
      _fase = _Fase.responso;
    });
  }

  void _gettaAncora() {
    PaletteSensoriale.eseguiSchema(SchemaAptico.tocco);
    setState(() => _esito = RuneCast.getta(_gettata, random: widget.random));
  }

  @override
  Widget build(BuildContext context) {
    final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.caligo));
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: BarraArte(
        titolo: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text('Estrazione Rune',
              maxLines: 1, style: TypographyTokens.display(size: 19)),
        ),
        azioni: [
          IconButton(
            key: const Key('rune_sources'),
            icon: const Icon(Icons.info_outline_rounded),
            tooltip: 'Fonti e metodo',
            onPressed: () => _mostraFonti(context, palette),
          ),
        ],
      ),
      body: CosmosBackground(
        seed: 10,
        showZodiac: false,
        child: SafeArea(
          child: _fase == _Fase.preparazione
              ? _Preparazione(
                  palette: palette,
                  gettata: _gettata,
                  domanda: _domanda,
                  animazioni: _animazioni,
                  onGettata: _cambiaGettata,
                  onGetta: _getta,
                )
              : _Responso(
                  palette: palette,
                  esito: _esito!,
                  domanda: _domanda.text.trim(),
                  animazioni: _animazioni,
                  onAncora: _gettaAncora,
                ),
        ),
      ),
    );
  }

  void _mostraFonti(BuildContext context, MaestroPalette palette) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheet) => Container(
        key: const Key('rune_sources_sheet'),
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Fonti e metodo',
                    style: TypographyTokens.display(size: 19)
                        .copyWith(color: palette.goldSoft)),
                const SizedBox(height: SpacingTokens.sm),
                Text(kRuneFontiEMetodo,
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
      ),
    );
  }
}

/// La soglia: la voce di Caligo, il selettore col testo dinamico, il disclaimer,
/// la domanda coi suggerimenti, poi il Pozzo di Urdhr in attesa del lancio.
class _Preparazione extends StatelessWidget {
  const _Preparazione({
    required this.palette,
    required this.gettata,
    required this.domanda,
    required this.animazioni,
    required this.onGettata,
    required this.onGetta,
  });

  final MaestroPalette palette;
  final GettataRune gettata;
  final TextEditingController domanda;
  final bool animazioni;
  final ValueChanged<GettataRune> onGettata;
  final VoidCallback onGetta;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const Key('rune_preparazione'),
      padding: const EdgeInsets.all(SpacingTokens.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: SpacingTokens.sm),
          Text(
            'Sono Caligo, custode delle soglie. Le rune non comandano il tuo '
            'domani, lo rischiarano: gettale con una domanda nel cuore e ascolta '
            'il segno.',
            key: const Key('rune_intro'),
            textAlign: TextAlign.center,
            style: TypographyTokens.body(size: 16)
                .copyWith(color: ColorTokens.textPrimary, height: 1.5),
          ),
          const SizedBox(height: SpacingTokens.lg),
          // LE PIETRE COPERTE, prima che la sorte le scopra.
          _PietreCoperte(
              palette: palette,
              quante: gettata.libera ? gettata.sparse : gettata.numero),
          const SizedBox(height: SpacingTokens.lg),
          // IL SELETTORE delle gettate.
          _SelettoreGettate(
              corrente: gettata, palette: palette, onSelect: onGettata),
          const SizedBox(height: SpacingTokens.md),
          // IL TESTO DINAMICO, che cambia con la scelta.
          DepthCard(
            key: const Key('rune_dynamic_text'),
            padding: const EdgeInsets.all(SpacingTokens.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${gettata.nome} · ${gettata.sottotitolo}',
                    style: TypographyTokens.label(size: 12).copyWith(
                        color: palette.goldSoft, letterSpacing: 0.6)),
                const SizedBox(height: SpacingTokens.xs),
                Text(gettata.testoDinamico,
                    style: TypographyTokens.body(size: 14).copyWith(
                        color: ColorTokens.textPrimary, height: 1.5)),
              ],
            ),
          ),
            // IL DISCLAIMER E' USCITO DA QUI, ed era uno di SETTE.
            //
            // Le linee guida dicevano da sempre "una volta sola", e per
            // sette volte ognuno ha pensato che il proprio fosse quella
            // volta. Un disclaimer ripetuto smette di essere letto e
            // diventa un modo di scaricare la responsabilita' invece di
            // dirla. Adesso sta in un posto solo, nell'area privacy.
          const SizedBox(height: SpacingTokens.lg),
          // LA DOMANDA, solo intenzione, coi suggerimenti tappabili.
          Text('La tua domanda',
              style: TypographyTokens.label(size: 12)
                  .copyWith(color: palette.goldSoft, letterSpacing: 0.6)),
          const SizedBox(height: SpacingTokens.xs),
          TextField(
            key: const Key('rune_question_field'),
            controller: domanda,
            maxLines: 2,
            minLines: 1,
            style: TypographyTokens.body(size: 15)
                .copyWith(color: ColorTokens.textPrimary),
            decoration: InputDecoration(
              hintText: 'Tieni in mente una domanda, oppure scrivila.',
              hintStyle: TypographyTokens.body(size: 14)
                  .copyWith(color: ColorTokens.textSecondary),
              filled: true,
              fillColor: palette.deepest.withValues(alpha: 0.4),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
                borderSide:
                    BorderSide(color: palette.gold.withValues(alpha: 0.4)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
                borderSide:
                    BorderSide(color: palette.gold.withValues(alpha: 0.8)),
              ),
            ),
          ),
          const SizedBox(height: SpacingTokens.sm),
          Wrap(
            key: const Key('rune_suggestions'),
            spacing: SpacingTokens.xs,
            runSpacing: SpacingTokens.xs,
            children: [
              for (final q in kRuneDomandeSuggerite)
                _Suggerimento(
                  testo: q,
                  palette: palette,
                  onTap: () => domanda.text = q,
                ),
            ],
          ),
          const SizedBox(height: SpacingTokens.lg),
          // IL POZZO DI URDHR in attesa, col lancio.
          _PozzoUrdhr(
            palette: palette,
            gettata: gettata,
            esito: null,
            animazioni: animazioni,
          ),
          const SizedBox(height: SpacingTokens.md),
          FilledButton.icon(
            key: const Key('rune_cast_button'),
            style: FilledButton.styleFrom(
                backgroundColor: palette.primary,
                foregroundColor: palette.onPrimary,
                minimumSize: const Size.fromHeight(52)),
            onPressed: onGetta,
            icon: const Icon(Icons.casino_outlined),
            label: const Text('Getta le rune'),
          ),
          const SizedBox(height: SpacingTokens.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.vibration, size: 13, color: palette.goldSoft),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                    'Scuoti il telefono, oppure tocca: il ripiego vale sempre.',
                    style: TypographyTokens.label(size: 11).copyWith(
                        color: palette.goldSoft.withValues(alpha: 0.7),
                        letterSpacing: 0.3)),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.xxxl),
        ],
      ),
    );
  }
}

/// Il responso: la gettata posata nel Pozzo, la domanda, la rivelazione a
/// scorrimento, il presagio, Getta ancora, poi Condividi e Parlane con Caligo.
class _Responso extends StatelessWidget {
  const _Responso({
    required this.palette,
    required this.esito,
    required this.domanda,
    required this.animazioni,
    required this.onAncora,
  });

  final MaestroPalette palette;
  final EsitoGettata esito;
  final String domanda;
  final bool animazioni;
  final VoidCallback onAncora;

  @override
  Widget build(BuildContext context) {
    final presagio = RunePresagio.componi(esito);
    return SingleChildScrollView(
      key: const Key('rune_result'),
      padding: const EdgeInsets.all(SpacingTokens.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: SpacingTokens.sm),
          Center(
            child: Text(esito.gettata.nome.toUpperCase(),
                key: const Key('rune_result_title'),
                style: TypographyTokens.display(size: 24)
                    .copyWith(color: palette.goldSoft)),
          ),
          const SizedBox(height: SpacingTokens.md),
          // IL POZZO con le rune posate, i cerchi e i fili delle Norne.
          _PozzoUrdhr(
            palette: palette,
            gettata: esito.gettata,
            esito: esito,
            animazioni: animazioni,
          ),
          if (domanda.isNotEmpty) ...[
            const SizedBox(height: SpacingTokens.md),
            DepthCard(
              key: const Key('rune_question_shown'),
              padding: const EdgeInsets.all(SpacingTokens.md),
              child: Row(
                children: [
                  Icon(Icons.help_outline_rounded,
                      size: 16, color: palette.goldSoft),
                  const SizedBox(width: SpacingTokens.xs),
                  Expanded(
                    child: Text(domanda,
                        style: TypographyTokens.body(size: 15).copyWith(
                            color: ColorTokens.textPrimary,
                            fontStyle: FontStyle.italic)),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: SpacingTokens.lg),
          // LA RIVELAZIONE, una runa per volta.
          for (var i = 0; i < esito.rune.length; i++) ...[
            _LetturaRuna(
                runa: esito.rune[i],
                indice: i,
                palette: palette,
                libera: esito.gettata.libera),
            const SizedBox(height: SpacingTokens.md),
          ],
          // IL PRESAGIO, la lettura sola che intreccia le rune.
          ScrollReveal(
            depth: 1,
            child: DepthCard(
              key: const Key('rune_presage'),
              raised: true,
              padding: const EdgeInsets.all(SpacingTokens.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_awesome, size: 16, color: palette.goldSoft),
                      const SizedBox(width: SpacingTokens.xs),
                      Text('Il presagio di Caligo',
                          style: TypographyTokens.label(size: 12).copyWith(
                              color: palette.goldSoft, letterSpacing: 0.6)),
                    ],
                  ),
                  const SizedBox(height: SpacingTokens.xs),
                  Text(presagio,
                      key: const Key('rune_presage_text'),
                      style: TypographyTokens.body(size: 16).copyWith(
                          color: ColorTokens.textPrimary, height: 1.55)),
                ],
              ),
            ),
          ),
          const SizedBox(height: SpacingTokens.md),
          // IL SIGILLO DEL GIORNO, la bindrune che intreccia le rune uscite.
          ScrollReveal(
            depth: 1,
            child: DepthCard(
              key: const Key('rune_sigillo'),
              raised: true,
              padding: const EdgeInsets.all(SpacingTokens.md),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.workspaces_outline,
                          size: 16, color: palette.goldSoft),
                      const SizedBox(width: SpacingTokens.xs),
                      Text('Il sigillo del giorno',
                          style: TypographyTokens.label(size: 12).copyWith(
                              color: palette.goldSoft, letterSpacing: 0.6)),
                    ],
                  ),
                  const SizedBox(height: SpacingTokens.sm),
                  BindruneSigillo(
                    runeNames: [for (final r in esito.rune) r.rune.name],
                    oro: palette.gold,
                    alone: palette.goldSoft,
                    lato: 168,
                  ),
                  const SizedBox(height: SpacingTokens.sm),
                  Text(kRuneBindruneNota,
                      textAlign: TextAlign.center,
                      style: TypographyTokens.label(size: 11).copyWith(
                          color: ColorTokens.textSecondary, height: 1.4)),
                ],
              ),
            ),
          ),
          const SizedBox(height: SpacingTokens.md),
          OutlinedButton.icon(
            key: const Key('rune_recast'),
            style: OutlinedButton.styleFrom(
                foregroundColor: palette.goldSoft,
                side: BorderSide(color: palette.gold.withValues(alpha: 0.6))),
            onPressed: onAncora,
            icon: const Icon(Icons.casino_outlined),
            label: const Text('Getta ancora'),
          ),
          const SizedBox(height: SpacingTokens.md),
          _Azioni(palette: palette, esito: esito, presagio: presagio),
          const SizedBox(height: SpacingTokens.xxxl),
        ],
      ),
    );
  }
}

/// La lettura di una runa: la pietra che brilla, il nome, la posizione con la
/// sua glossa, il verso, la parola chiave e la riga dal corpus.
class _LetturaRuna extends StatelessWidget {
  const _LetturaRuna(
      {required this.runa,
      required this.indice,
      required this.palette,
      this.libera = false});

  final RunaGettata runa;
  final int indice;
  final MaestroPalette palette;

  /// Nel getto libero le rune lette sono in luce, non hanno il verso d'ombra.
  final bool libera;

  @override
  Widget build(BuildContext context) {
    return ScrollReveal(
      depth: 1,
      child: DepthCard(
        key: Key('rune_card_$indice'),
        raised: true,
        padding: const EdgeInsets.all(SpacingTokens.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PietraRuna(runa: runa, palette: palette),
                const SizedBox(width: SpacingTokens.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(runa.rune.name,
                          style: TypographyTokens.display(size: 20)
                              .copyWith(color: palette.goldSoft)),
                      Text(
                          '${runa.posizione.titolo} · ${runa.posizione.glossa}',
                          style: TypographyTokens.label(size: 11).copyWith(
                              color: palette.goldSoft.withValues(alpha: 0.8),
                              letterSpacing: 0.4)),
                      const SizedBox(height: 2),
                      Text(
                          libera
                              ? 'in luce'
                              : (runa.inOmbra ? 'in merkstave' : 'diritta'),
                          style: TypographyTokens.label(size: 11).copyWith(
                              color: ColorTokens.textSecondary,
                              letterSpacing: 0.6)),
                      const SizedBox(height: 2),
                      Text(runa.rune.keyword,
                          style: TypographyTokens.body(size: 14).copyWith(
                              color: ColorTokens.textPrimary,
                              fontStyle: FontStyle.italic)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: SpacingTokens.sm),
            Text(runa.riga,
                style: TypographyTokens.body(size: 15).copyWith(
                    color: ColorTokens.textPrimary, height: 1.5)),
          ],
        ),
      ),
    );
  }
}

/// La pietra incisa di una runa, che brilla, capovolta se in merkstave.
class _PietraRuna extends StatelessWidget {
  const _PietraRuna({required this.runa, required this.palette});

  final RunaGettata runa;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    final img = runa.rune.hasImage
        ? Image.asset(runa.rune.fullPath!,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => CustomPaint(
                  painter: RunePainter(
                      runeName: runa.rune.name,
                      color: Colors.white,
                      glow: palette.goldSoft,
                      intensity: 1.0),
                ))
        : CustomPaint(
            painter: RunePainter(
                runeName: runa.rune.name,
                color: Colors.white,
                glow: palette.goldSoft,
                intensity: 1.0),
          );
    return Container(
      width: 78,
      height: 94,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [
          palette.gold.withValues(alpha: 0.22),
          palette.gold.withValues(alpha: 0.0),
        ]),
      ),
      child: runa.inOmbra ? Transform.rotate(angle: math.pi, child: img) : img,
    );
  }
}

/// Condividi e Parlane con Caligo, piu' la card fuori campo per lo scatto.
class _Azioni extends StatefulWidget {
  const _Azioni(
      {required this.palette, required this.esito, required this.presagio});

  final MaestroPalette palette;
  final EsitoGettata esito;
  final String presagio;

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
      await shareRuneCard(boundaryKey: _cardBoundary, esito: widget.esito);
    } finally {
      if (mounted) setState(() => _condividendo = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OutlinedButton.icon(
                key: const Key('rune_share'),
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
                key: const Key('rune_consulta'),
                style: FilledButton.styleFrom(
                    backgroundColor: palette.primary,
                    foregroundColor: palette.onPrimary),
                onPressed: () {
                  final services = context.read<AppServices>();
                  final nomi =
                      widget.esito.rune.map((r) => r.rune.name).toList();
                  Navigator.of(context).push(MaestroChatScreen.route(
                      maestro: Maestro.caligo,
                      services: services,
                      initialUserMessage: ChatOpeners.runa(
                          widget.esito.gettata.nome, nomi)));
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
              child: RuneShareCard(
                  esito: widget.esito, presagio: widget.presagio),
            ),
          ),
      ],
    );
  }
}

/// Il selettore delle gettate, a pillole che vanno a capo. Estensibile: legge da
/// [gettate], una quarta gettata compare da sola. Ogni pillola e' dimensionata
/// sul suo contenuto, cosi' il nome si legge sempre per intero, mai troncato.
class _SelettoreGettate extends StatelessWidget {
  const _SelettoreGettate(
      {required this.corrente, required this.palette, required this.onSelect});

  final GettataRune corrente;
  final MaestroPalette palette;
  final ValueChanged<GettataRune> onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      key: const Key('rune_selector'),
      alignment: WrapAlignment.center,
      spacing: SpacingTokens.xs,
      runSpacing: SpacingTokens.xs,
      children: [
        for (final g in gettate)
          GestureDetector(
            key: Key('rune_segment_${g.id}'),
            behavior: HitTestBehavior.opaque,
            onTap: () => onSelect(g),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                  horizontal: SpacingTokens.md, vertical: SpacingTokens.sm),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
                color: g.id == corrente.id
                    ? palette.gold.withValues(alpha: 0.2)
                    : palette.deepest.withValues(alpha: 0.4),
                border: Border.all(
                    color: palette.gold
                        .withValues(alpha: g.id == corrente.id ? 0.7 : 0.3)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Nome per intero, senza ellissi: la pillola cresce col testo.
                  Text(g.nome,
                      textAlign: TextAlign.center,
                      style: TypographyTokens.label(size: 12).copyWith(
                        color: g.id == corrente.id
                            ? palette.goldSoft
                            : ColorTokens.textSecondary,
                        letterSpacing: 0.2,
                      )),
                  Text(g.sottotitolo,
                      textAlign: TextAlign.center,
                      style: TypographyTokens.label(size: 11).copyWith(
                        color: g.id == corrente.id
                            ? palette.goldSoft.withValues(alpha: 0.8)
                            : ColorTokens.textSecondary.withValues(alpha: 0.7),
                      )),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Un suggerimento di domanda tappabile, a pillola.
class _Suggerimento extends StatelessWidget {
  const _Suggerimento(
      {required this.testo, required this.palette, required this.onTap});

  final String testo;
  final MaestroPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.sm, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
          color: palette.deepest.withValues(alpha: 0.4),
          border: Border.all(color: palette.gold.withValues(alpha: 0.35)),
        ),
        child: Text(testo,
            style: TypographyTokens.label(size: 11)
                .copyWith(color: palette.goldSoft, letterSpacing: 0.2)),
      ),
    );
  }
}

/// Il Pozzo di Urdhr, il wow: le rune cadono sull'acqua immobile alla radice di
/// Yggdrasil, coi cerchi concentrici dove ognuna tocca e i fili sottili delle
/// Norne che le collegano. Con Riduci Movimento o Quality Tier basso, niente
/// increspature ne parallasse: la gettata resta statica, gia' posata.
class _PozzoUrdhr extends StatefulWidget {
  const _PozzoUrdhr({
    required this.palette,
    required this.gettata,
    required this.esito,
    required this.animazioni,
  });

  final MaestroPalette palette;
  final GettataRune gettata;
  final EsitoGettata? esito;
  final bool animazioni;

  @override
  State<_PozzoUrdhr> createState() => _PozzoUrdhrState();
}

class _PozzoUrdhrState extends State<_PozzoUrdhr>
    with SingleTickerProviderStateMixin {
  late final AnimationController _onde = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void initState() {
    super.initState();
    if (widget.esito != null && widget.animazioni) _onde.forward(from: 0);
  }

  @override
  void didUpdateWidget(_PozzoUrdhr old) {
    super.didUpdateWidget(old);
    // A ogni nuova gettata, l'acqua torna a incresparsi dal punto di caduta.
    if (widget.esito != null &&
        widget.animazioni &&
        !identical(widget.esito, old.esito)) {
      _onde.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _onde.dispose();
    super.dispose();
  }

  /// Le posizioni normalizzate delle rune nel pozzo, per gettata.
  List<Offset> _punti(GettataRune g) {
    switch (g.id) {
      case 'norne':
        return const [Offset(0.2, 0.5), Offset(0.5, 0.5), Offset(0.8, 0.5)];
      case 'croce':
        return const [
          Offset(0.5, 0.5), // Cuore
          Offset(0.5, 0.82), // Radice
          Offset(0.2, 0.5), // Ostacolo
          Offset(0.8, 0.5), // Consiglio
          Offset(0.5, 0.18), // Esito
        ];
      default:
        return const [Offset(0.5, 0.5)];
    }
  }

  @override
  Widget build(BuildContext context) {
    final libera = widget.gettata.libera;
    final esito = widget.esito;
    // Le pietre da posare con la loro posizione, piu' i punti di lettura per i
    // fili e i cerchi: le posizioni fisse, oppure lo scatter libero sul telo.
    final pietre = <MapEntry<RunaGettata, Offset>>[];
    final puntiLettura = <Offset>[];
    if (esito != null) {
      if (libera) {
        for (final s in esito.sparse) {
          if (s.punto != null) pietre.add(MapEntry(s, s.punto!));
        }
        for (final r in esito.rune) {
          if (r.punto != null) puntiLettura.add(r.punto!);
        }
      } else {
        final punti = _punti(widget.gettata);
        for (var i = 0; i < esito.rune.length && i < punti.length; i++) {
          pietre.add(MapEntry(esito.rune[i], punti[i]));
          puntiLettura.add(punti[i]);
        }
      }
    }
    return SizedBox(
      key: const Key('rune_well'),
      height: 300,
      child: LayoutBuilder(
        builder: (context, box) {
          final w = box.maxWidth;
          const h = 300.0;
          return AnimatedBuilder(
            animation: _onde,
            builder: (context, _) {
              return Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _PozzoPainter(
                        palette: widget.palette,
                        punti: puntiLettura,
                        posato: esito != null,
                        libera: libera,
                        onda: (esito != null && _onde.isAnimating)
                            ? _onde.value
                            : -1,
                      ),
                    ),
                  ),
                  for (final e in pietre)
                    Positioned(
                      left: e.value.dx * w - 26,
                      top: e.value.dy * h - 32,
                      child: _PietraPosata(
                          runa: e.key,
                          palette: widget.palette,
                          coperta: e.key.coperta),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

/// Una pietra posata, piccola, capovolta se in merkstave. Sul telo, se coperta
/// resta velata, il verso d'ombra della sorte libera.
class _PietraPosata extends StatelessWidget {
  const _PietraPosata(
      {required this.runa, required this.palette, this.coperta = false});

  final RunaGettata runa;
  final MaestroPalette palette;
  final bool coperta;

  @override
  Widget build(BuildContext context) {
    final img = SizedBox(
      width: 52,
      height: 64,
      child: runa.rune.hasImage
          ? Image.asset(runa.rune.thumbPath!,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => CustomPaint(
                    painter: RunePainter(
                        runeName: runa.rune.name,
                        color: Colors.white,
                        glow: palette.goldSoft,
                        intensity: 1.0),
                  ))
          : CustomPaint(
              painter: RunePainter(
                  runeName: runa.rune.name,
                  color: Colors.white,
                  glow: palette.goldSoft,
                  intensity: 1.0),
            ),
    );
    final pietra =
        runa.inOmbra ? Transform.rotate(angle: math.pi, child: img) : img;
    return coperta ? Opacity(opacity: 0.35, child: pietra) : pietra;
  }
}

/// L'acqua immobile del Pozzo, le radici di Yggdrasil, i cerchi concentrici dai
/// punti di caduta e i fili delle Norne. Statico quando le onde sono spente.
class _PozzoPainter extends CustomPainter {
  _PozzoPainter({
    required this.palette,
    required this.punti,
    required this.posato,
    required this.onda,
    this.libera = false,
  });

  final MaestroPalette palette;
  final List<Offset> punti;
  final bool posato;

  /// Vero per il getto sul telo: il fondo e' un panno bianco, i fili partono dal
  /// centro verso le rune lette per vicinanza.
  final bool libera;

  /// Avanzamento dell'onda, da zero a uno, negativo se ferma.
  final double onda;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    if (libera) {
      _telo(canvas, size, rect);
    } else {
      _acqua(canvas, size, rect);
    }

    if (!posato) return;

    final centri = [
      for (final p in punti) Offset(p.dx * size.width, p.dy * size.height),
    ];

    // I fili sottili delle Norne. Sul telo partono dal centro verso le rune
    // lette; nelle stese fisse dal primo punto verso gli altri.
    final filo = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = palette.goldSoft.withValues(alpha: libera ? 0.55 : 0.4);
    if (libera) {
      final centro = Offset(size.width / 2, size.height / 2);
      for (final c in centri) {
        canvas.drawLine(centro, c, filo);
      }
    } else if (centri.length > 1) {
      for (var i = 1; i < centri.length; i++) {
        canvas.drawLine(centri.first, centri[i], filo);
      }
    }

    // I cerchi concentrici dove ogni runa tocca l'acqua.
    for (final c in centri) {
      // Anelli fermi, sempre presenti, come pietre gia' posate.
      for (var k = 1; k <= 2; k++) {
        canvas.drawCircle(
          c,
          14.0 * k,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2
            ..color = palette.goldSoft.withValues(alpha: 0.18 / k),
        );
      }
      // Onde vive che si propagano, solo mentre l'animazione gira.
      if (onda >= 0) {
        for (var k = 0; k < 3; k++) {
          final fase = (onda - k * 0.18).clamp(0.0, 1.0);
          if (fase <= 0) continue;
          canvas.drawCircle(
            c,
            fase * size.shortestSide * 0.32,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2.2 * (1 - fase)
              ..color = palette.goldSoft.withValues(alpha: 0.5 * (1 - fase)),
          );
        }
      }
    }
  }

  /// L'acqua immobile del Pozzo di Urdhr, scura, con le radici di Yggdrasil che
  /// scendono e un alone caldo al centro.
  void _acqua(Canvas canvas, Size size, Rect rect) {
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, -0.1),
          radius: 0.9,
          colors: [
            palette.surfaceElevated.withValues(alpha: 0.9),
            palette.deepest,
          ],
        ).createShader(rect),
    );
    final radice = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = palette.gold.withValues(alpha: 0.18);
    for (var i = 0; i < 5; i++) {
      final x = size.width * (0.15 + 0.175 * i);
      final path = Path()..moveTo(x, 0);
      path.cubicTo(x + 12, size.height * 0.18, x - 14, size.height * 0.3,
          x + 6, size.height * 0.42);
      canvas.drawPath(path, radice);
    }
    canvas.drawCircle(
      Offset(size.width / 2, size.height * 0.45),
      size.shortestSide * 0.5,
      Paint()
        ..shader = RadialGradient(colors: [
          palette.gold.withValues(alpha: 0.12),
          palette.primary.withValues(alpha: 0.0),
        ]).createShader(Rect.fromCircle(
            center: Offset(size.width / 2, size.height * 0.45),
            radius: size.shortestSide * 0.5)),
    );
  }

  /// Il panno bianco di Tacito: un telo chiaro e caldo con una trama leggera e
  /// un segno d'oro al centro, dove la vicinanza pesa.
  void _telo(Canvas canvas, Size size, Rect rect) {
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF0E7D3), Color(0xFFD2C09B)],
        ).createShader(rect),
    );
    // Trama del tessuto, righe tenui nelle due direzioni.
    final trama = Paint()
      ..strokeWidth = 1
      ..color = const Color(0xFF7A6A4A).withValues(alpha: 0.08);
    for (var i = 1; i < 10; i++) {
      final y = size.height * i / 10;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), trama);
      final x = size.width * i / 10;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), trama);
    }
    // Il centro del telo, dove la vicinanza pesa di piu'.
    final c = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(
      c,
      size.shortestSide * 0.06,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = palette.gold.withValues(alpha: 0.5),
    );
    canvas.drawCircle(
        c, 2.5, Paint()..color = palette.gold.withValues(alpha: 0.6));
  }

  @override
  bool shouldRepaint(_PozzoPainter old) =>
      old.onda != onda ||
      old.posato != posato ||
      old.punti != punti ||
      old.libera != libera;
}

/// LE PIETRE COPERTE, cioe' il sacchetto prima della sorte.
///
/// **Perche' esiste.** Senza un retro non si puo' mostrare una pietra coperta,
/// e senza pietre coperte il lancio non ha un prima: la schermata passava dal
/// pulsante alle rune gia' scoperte, e la sorte non si vedeva accadere.
///
/// **Il retro e' quello della SUA pietra.** Non c'e' un dorso unico: ogni runa
/// ha il proprio osso, con la sua forma e la sua venatura, e coperta si vede
/// quello. Qui la sorte non e' ancora stata gettata, quindi le pietre mostrate
/// sono le prime del catalogo e non anticipano niente: un retro non dice quale
/// runa sia, ed e' esattamente il motivo per cui serve.
class _PietreCoperte extends StatelessWidget {
  const _PietreCoperte({required this.palette, required this.quante});

  final MaestroPalette palette;
  final int quante;

  @override
  Widget build(BuildContext context) {
    // Al massimo cinque: oltre, in una riga da telefono, diventano francobolli.
    final n = quante.clamp(1, 5);
    return SizedBox(
      key: const Key('rune_pietre_coperte'),
      height: 96,
      // **RIENTRANO INVECE DI SFORARE.** Cinque pietre da sessantadue punti
      // piu' i margini fanno trecentocinquanta su una larghezza utile di
      // trecentododici: la riga sforava di trentotto pixel, e l'ha preso la
      // cattura. Si rimpiccioliscono, come fanno le tessere delle arti.
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < n; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Transform.rotate(
                // Un filo di inclinazione alternata: pietre allineate in
                // riga sembrano un menu, non un pugno di sassi.
                angle: (i.isEven ? 1 : -1) * 0.06 * (i + 1),
                child: _RetroDellaPietra(
                    stem: kElderFuthark[i % kElderFuthark.length].stem,
                    palette: palette),
              ),
            ),
        ],
        ),
      ),
    );
  }
}

/// Il retro di una pietra, con lo stesso ripiego dipinto delle altre superfici.
class _RetroDellaPietra extends StatelessWidget {
  const _RetroDellaPietra({required this.stem, required this.palette});

  final String? stem;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    final percorso = pathVergineDi(stem);
    return SizedBox(
      width: 62,
      height: 76,
      child: percorso == null
          ? _ripiego()
          : Image.asset(percorso,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => _ripiego()),
    );
  }

  /// Quando il retro manca, un sasso dipinto: mai un vuoto al posto di una
  /// pietra, che si leggerebbe come un guasto.
  Widget _ripiego() => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const RadialGradient(colors: [
            Color(0xFFE8DFC9),
            Color(0xFFCFC3A6),
          ]),
          border: Border.all(color: palette.gold.withValues(alpha: 0.25)),
        ),
      );
}
