import 'dart:math' as math;

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/material.dart';

import '../../core/sensi/ascoltatore_scuotimento.dart';
import '../../core/maestro/maestro.dart';
import '../../core/tarot/tarot_reading.dart';
import '../../core/tarot/tarot_card.dart';
import '../../core/tarot/tarot_spread.dart';
import '../../core/tarot/tarot_topic.dart';
import '../../design_system/components/cosmos_background.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import 'stesa_choreography.dart';
import 'stesa_fan.dart';
import 'stesa_handoff.dart';
import 'stesa_reveal.dart';
import 'stesa_senses.dart';
import 'stesa_share_card.dart';
import 'medora_stage.dart';
import 'tarot_card_art.dart';
import 'tarot_selectors.dart';
import '../maestri/rotta_arte.dart';

/// Il rapporto delle carte del mazzo, due a tre.
const double kTarotAspect = 2 / 3;

/// Stesa a Tre Carte, la headline dei tarocchi di Medora.
///
/// Un ventaglio di carte coperte col dorso di Medora: se ne pescano tre, che si
/// girano con un flip e prendono posto in Passato, Presente, Futuro. Ogni carta
/// esce dritta o rovesciata, e il testo mostrato e' sempre quello del verso in
/// cui e' uscita. Il pescaggio passa da un seme opzionale, cosi' test e anteprima
/// sono riproducibili.
class StesaTreCarteScreen extends StatefulWidget {
  const StesaTreCarteScreen({
    super.key,
    this.seed,
    this.revealAll = false,
    this.topic,
    this.skipIntro = false,
  });

  /// L'argomento di partenza. Se nullo si parte da quello predefinito, la
  /// lettura generale. Serve all'anteprima e, in futuro, al deep link che
  /// arriva gia' con la domanda scelta.
  final TarotTopic? topic;

  /// Seme del pescaggio. Se nullo, ogni apertura e' una stesa nuova.
  final int? seed;

  /// Per l'anteprima e i test: parte con le tre carte gia' rivelate.
  final bool revealAll;

  /// Salta il bianco iniziale, quando la schermata si apre senza intro.
  ///
  /// L'intro cinematografica finisce in bianco pieno e la scena parte da li'
  /// per coprire il taglio. Arrivando da altrove quel bianco sarebbe un lampo
  /// senza motivo, quindi si salta: e' anche il modo in cui girano i test e
  /// l'anteprima.
  final bool skipIntro;

  static Route<void> route({int? seed}) => MaterialPageRoute<void>(
        builder: (_) => SogliaArte(id: 'tarot_spread_three', maestro: Maestro.medora, child: StesaTreCarteScreen(seed: seed)),
      );

  @override
  State<StesaTreCarteScreen> createState() => _StesaTreCarteScreenState();
}

class _StesaTreCarteScreenState extends State<StesaTreCarteScreen>
    with TickerProviderStateMixin {
  /// L'ORDINE DEL MAZZO, che i gesti cambiano davvero.
  ///
  /// **Ordine 2171 voce 6.** Fino al 10 agosto 2026 Taglia e Mischia
  /// lanciavano un'animazione e basta: la stesa restava quella pescata
  /// all'apertura, qualunque cosa facesse la persona. Un gesto che non tocca
  /// il risultato non e' un rito, e' una decorazione.
  late List<int> _mazzo = TarotSpread.mazzoMescolato(seed: widget.seed);

  /// Il seme che decide i versi: resta quello della stesa, cosi' lo stesso
  /// ordine da' sempre la stessa lettura.
  late final int _seme = widget.seed ?? 0;

  late TarotSpread _spread = TarotSpread.dalMazzo(_mazzo, seed: _seme);

  /// LE TRE CARTE CHE IL MAZZO HA IN CIMA IN QUESTO MOMENTO.
  ///
  /// Serve alle prove: a ventaglio coperto i nomi non sono ancora a schermo,
  /// e senza questa finestra l'unico modo di sapere se Mischia ha davvero
  /// mosso il mazzo sarebbe scoprire le carte, cioe' finire il rito.
  @visibleForTesting
  TarotSpread get stesaCorrente => _spread;

  // --- La regia della scena ---

  /// La scena corrente. Ogni scena sa cosa mostrare e quali gesti accettare.
  late StesaScene _scene =
      widget.revealAll ? StesaScene.completa : StesaScene.handoff;

  late final AnimationController _handoff = AnimationController(
      vsync: this, duration: StesaTiming.handoff);
  late final AnimationController _ingresso = AnimationController(
      vsync: this, duration: StesaTiming.ingresso);
  late final AnimationController _respiro = AnimationController(
      vsync: this, duration: StesaTiming.respiro);
  late final AnimationController _taglio = AnimationController(
      vsync: this, duration: StesaTiming.taglio);
  late final AnimationController _mescola = AnimationController(
      vsync: this, duration: StesaTiming.mescolamento);
  late final AnimationController _volo = AnimationController(
      vsync: this, duration: StesaTiming.volo);

  /// Se il pannello dei selettori e' aperto. Parte richiuso, cosi' il
  /// ventaglio resta a portata senza scorrere oltre la configurazione.
  bool _setupAperto = false;

  /// Dove il mazzo e' stato tagliato l'ultima volta.
  int _taglioIndice = TarotSpread.fanSize ~/ 2;

  /// La carta del ventaglio che sta volando verso il suo slot.
  int? _inVolo;

  /// Suono e vibrazione, dietro un solo interruttore di silenzio.
  final SensiDellaStesa _sensi = SensiDellaStesa();

  /// L'interruttore di silenzio, che governa suono e vibrazione insieme.
  bool _silenzio = false;

  /// L'inclinazione delle carte posate, dal giroscopio. Senza sensore le
  /// carte restano ferme e composte, senza errori.
  final TiltListener _tilt = TiltListener();

  /// L'aura elementale della carta appena scoperta.
  late final AnimationController _reveal = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1100));

  /// Quale posizione sta fiorendo, e con quale resa.
  int? _revealSlot;
  RevealSpec? _revealSpec;

  /// Il galleggiamento lento delle carte posate.
  late final AnimationController _galleggio = AnimationController(
      vsync: this, duration: const Duration(seconds: 6));

  /// Lo scuotimento del telefono, quando c'e' l'accelerometro.
  AscoltatoreScuotimento? _shake;

  /// Vero quando le animazioni di sistema sono spente: tutto arriva subito
  /// allo stato finale, senza moto.
  bool _reduceMotion = false;

  bool _avviata = false;

  /// Quante carte sono gia' state pescate, da 0 a 3.
  late int _drawn = widget.revealAll ? SpreadPosition.values.length : 0;

  /// Quali carte del ventaglio sono gia' state prese.
  final Set<int> _taken = {};

  final GlobalKey _cardKey = GlobalKey();
  bool _sharing = false;
  bool _renderCard = false;

  /// I selettori prima della stesa. Le voci non pronte restano Coming soon.
  late TarotSetup _setup = TarotSetup(
      topic: widget.topic ?? TarotTopic.predefinito);

  /// La lettura a sette strati, letta dentro l'argomento scelto. E'
  /// deterministica: stesse carte e stesso argomento danno sempre lo stesso
  /// testo, quindi si puo' mettere in cache senza toccare l'LLM.
  TarotReading get _reading =>
      TarotReading.of(_spread, _setup.topic, depth: _setup.depth);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.of(context).disableAnimations;
    if (_avviata) return;
    _avviata = true;
    _shake = AscoltatoreScuotimento(onScuotimento: _mischia)..start();
    // Il giroscopio e il galleggiamento solo se il moto e' concesso: con
    // Riduci Movimento le carte stanno ferme e composte.
    if (!_reduceMotion) {
      _tilt.start();
      _galleggio.repeat();
    }
    _apriScena();
  }

  /// L'apertura: dal bianco dell'intro alla scena viva, poi le carte che
  /// nascono dal cosmo.
  Future<void> _apriScena() async {
    if (widget.revealAll) {
      // La stesa e' gia' fatta: nessuna coreografia da suonare.
      _handoff.value = 1;
      _ingresso.value = 1;
      return;
    }
    if (_reduceMotion) {
      // Riduci Movimento: si arriva subito alla posa di riposo.
      _handoff.value = 1;
      _ingresso.value = 1;
      if (mounted) setState(() => _scene = StesaScene.riposo);
      return;
    }
    if (widget.skipIntro) {
      _handoff.value = 1;
    } else {
      setState(() => _scene = StesaScene.handoff);
      await _handoff.forward();
      if (!mounted) return;
    }
    setState(() => _scene = StesaScene.ingresso);
    await _ingresso.forward();
    if (!mounted) return;
    setState(() => _scene = StesaScene.riposo);
    _respiro.repeat();
  }

  /// IL TAGLIO, che taglia davvero.
  ///
  /// La coreografia e' quella approvata nelle Decisioni del 3 agosto 2026: il
  /// ventaglio si ricompone in mazzo, il mazzo si divide in due, il taglio si
  /// ricompone, le carte si ristendono a partire dal mazzo.
  ///
  /// **E l'ordine cambia per davvero**: la meta' sotto sale sopra, quindi le
  /// tre carte che si pescheranno sono altre. Con Riduci Movimento il taglio
  /// avviene lo stesso, senza il volo: chi ha tolto le animazioni non perde
  /// il gesto, perde solo il moto.
  Future<void> _taglia() async {
    if (!_scene.accettaGesti) return;
    _sensi.momento(MomentoSensoriale.taglio);
    setState(() {
      _scene = StesaScene.taglio;
      // Il punto di taglio cambia a ogni gesto, ma resta dentro il mazzo.
      _taglioIndice = 2 + (_taglioIndice + 3) % (TarotSpread.fanSize - 3);
    });
    if (!_reduceMotion) {
      await _taglio.forward(from: 0);
      if (!mounted) return;
    }
    _taglio.value = 0;
    setState(() {
      // Il punto vero del taglio nel mazzo intero, non nel solo ventaglio:
      // tagliare nove carte su settantotto sarebbe un taglio finto.
      final punto = (_taglioIndice * TarotDeck.cards.length) ~/
          TarotSpread.fanSize;
      _mazzo = TarotSpread.taglia(_mazzo, punto);
      _spread = TarotSpread.dalMazzo(_mazzo, seed: _seme);
      _scene = StesaScene.riposo;
    });
  }

  /// Il mescolamento a vortice, da scuotimento o dal tasto.
  Future<void> _mischia() async {
    if (!mounted || !_scene.accettaGesti) return;
    _sensi.momento(MomentoSensoriale.mescolamento);
    setState(() => _scene = StesaScene.mescolamento);
    if (!_reduceMotion) {
      await _mescola.forward(from: 0);
      if (!mounted) return;
    }
    _mescola.value = 0;
    setState(() {
      // **IL MAZZO SI MESCOLA DAVVERO.** Senza questa riga il vortice era una
      // bella animazione sopra un mazzo immobile, e le tre carte restavano
      // quelle di prima: e' il difetto che Mauro e Dora hanno segnalato.
      _mazzo = [..._mazzo]..shuffle();
      _spread = TarotSpread.dalMazzo(_mazzo, seed: _seme);
      _scene = StesaScene.riposo;
    });
  }

  @override
  void dispose() {
    _tilt.dispose();
    _reveal.dispose();
    _galleggio.dispose();
    _shake?.dispose();
    _handoff.dispose();
    _ingresso.dispose();
    _respiro.dispose();
    _taglio.dispose();
    _mescola.dispose();
    _volo.dispose();
    super.dispose();
  }

  /// L'ultima carta scoperta: e' quella su cui Medora posa lo sguardo.
  DrawnCard? get _active => _drawn == 0 ? null : _spread.cards[_drawn - 1];

  bool get _complete => _drawn >= SpreadPosition.values.length;

  /// La scelta: la carta si stacca dal ventaglio, vola nel suo slot con una
  /// scia di stelle, poi il flip la gira sulla faccia.
  Future<void> _pick(int fanIndex) async {
    if (_complete || _taken.contains(fanIndex)) return;
    if (!_scene.accettaGesti) return;
    _sensi.momento(MomentoSensoriale.volo);
    setState(() {
      _taken.add(fanIndex);
      _inVolo = fanIndex;
    });
    if (!_reduceMotion) {
      await _volo.forward(from: 0);
      if (!mounted) return;
    }
    final slot = _drawn;
    setState(() {
      _inVolo = null;
      _drawn++;
      if (_complete) _scene = StesaScene.completa;
    });
    // Il flip, poi la fioritura dell'elemento: la carta si scopre e il suo
    // seme parla un istante, prima di lasciarla pulita e leggibile.
    _sensi.momento(MomentoSensoriale.flip);
    await _fiorisci(slot);
  }

  /// L'aura elementale della carta appena scoperta.
  ///
  /// Con Riduci Movimento non c'e' nessun moto: la carta appare gia' composta,
  /// e il momento sensoriale resta comunque, perche' il silenzio ha il suo
  /// interruttore e non si spegne col movimento.
  Future<void> _fiorisci(int slot) async {
    if (slot < 0 || slot >= _spread.cards.length) return;
    final spec = RevealSpec.of(_spread.cards[slot].card);
    _sensi.momento(MomentoSensoriale.reveal, solenne: spec.solenne);
    if (_reduceMotion) return;
    setState(() {
      _revealSlot = slot;
      _revealSpec = spec;
    });
    _reveal.duration = spec.durata;
    await _reveal.forward(from: 0);
    if (!mounted) return;
    // Finita la fioritura non resta nulla sopra la carta.
    setState(() {
      _revealSlot = null;
      _revealSpec = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    // La stesa e' di Medora: blu e oro suoi, sempre.
    final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.medora));

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: palette.goldSoft),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Indietro',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        // Il titolo legge il nome della stesa attiva: e' un dato della sua
        // definizione, non una stringa scritta qui. Quando arriveranno le
        // stese da sette e dieci carte il titolo cambiera' da solo.
        title: Text(_setup.tipo.nome,
            key: const Key('stesa_titolo'),
            style: TypographyTokens.display(size: 20)),
      ),
      body: CosmosBackground(
        seed: 19,
        showZodiac: false,
        child: SafeArea(
          child: Stack(
            children: [
              _content(palette),
              // Il bianco con cui l'intro passa la mano: sta sopra la scena e
              // dissolve, cosi' il taglio fra video e app non si vede.
              AnimatedBuilder(
                animation: _handoff,
                builder: (context, _) => HandoffVeil(
                  key: const Key('stesa_handoff'),
                  opacity: 1 - _handoff.value,
                ),
              ),
              // La carta che vola dal ventaglio al suo slot, con la scia.
              if (_inVolo != null)
                AnimatedBuilder(
                  animation: _volo,
                  builder: (context, _) => _CartaInVolo(
                    key: const Key('stesa_volo'),
                    progress: _volo.value,
                    destinazione: _drawn,
                    palette: palette,
                    seed: _inVolo!,
                  ),
                ),
              if (_renderCard)
                Positioned(
                  left: -3000,
                  top: 0,
                  child: RepaintBoundary(
                    key: _cardKey,
                    child: StesaShareCard(
                      spread: _spread,
                      palette: palette,
                      topic: _setup.topic,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// I tre slot Passato Presente Futuro.
  ///
  /// Stanno sopra il ventaglio mentre si pesca e sopra la lettura quando la
  /// stesa e' fatta: e' lo stesso blocco, cambia solo dove si trova.
  Widget _slots(MaestroPalette palette) {
    return AnimatedBuilder(
      animation: Listenable.merge([_reveal, _galleggio, _tilt]),
      builder: (context, _) => _slotsRow(palette),
    );
  }

  Widget _slotsRow(MaestroPalette palette) {
    return Row(
      key: const Key('stesa_slots'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < SpreadPosition.values.length; i++) ...[
          Expanded(
            child: _Slot(
              position: SpreadPosition.values[i],
              drawn: i < _drawn ? _spread.cards[i] : null,
              palette: palette,
              revealSpec: _revealSlot == i ? _revealSpec : null,
              revealProgress: _revealSlot == i ? _reveal.value : 0,
              tiltX: _tilt.x,
              tiltY: _tilt.y,
              galleggio: _reduceMotion
                  ? 0
                  : TiltListener.fluttuazioneDi(i, _galleggio.value),
            ),
          ),
          if (i < SpreadPosition.values.length - 1)
            const SizedBox(width: SpacingTokens.xs),
        ],
      ],
    );
  }

  Widget _content(MaestroPalette palette) {
    return ListView(
      key: const Key('stesa_list'),
      // Sopra Medora c'era una fascia vuota che sprecava la parte migliore
      // dello schermo: il margine alto ora e' appena quello che serve a non
      // finire sotto la barra del titolo.
      padding: const EdgeInsets.fromLTRB(SpacingTokens.lg, SpacingTokens.xs,
          SpacingTokens.lg, SpacingTokens.lg),
      children: [
        // Medora presiede la stesa. Finche' si pesca sta piu' raccolta: il
        // protagonista in quel momento e' il ventaglio interattivo, e il
        // ventaglio che lei tiene in mano deve restare un dettaglio del
        // ritratto, non un secondo invito in gara col primo.
        MedoraStage(
          palette: palette,
          active: _active,
          height: _complete ? 300 : 170,
          bustoFactor: _complete ? MedoraStage.bustoPieno : 0.34,
          bustoLarghezza: _complete ? 1.0 : 0.72,
        ),
        const SizedBox(height: SpacingTokens.sm),
        // La configurazione, richiusa nella sua riga di riepilogo.
        if (!_complete) ...[
          TarotSetupPanel(
            setup: _setup,
            palette: palette,
            aperto: _setupAperto,
            onToggle: () => setState(() => _setupAperto = !_setupAperto),
            onChanged: (s) => setState(() => _setup = s),
            onLocked: _showComingSoon,
          ),
          const SizedBox(height: SpacingTokens.sm),
        ],
        // Mentre si pesca, gli slot stanno appena SOPRA il ventaglio: cosi'
        // partenza e arrivo del volo sono nello stesso campo visivo e la carta
        // non vola mai verso uno slot fuori schermo.
        if (!_complete) ...[
          _slots(palette),
          const SizedBox(height: SpacingTokens.sm),
        ],
        // Colpo d'occhio: il ventaglio coperto, finche' restano carte da pescare.
        if (!_complete) ...[
          Text(
            _drawn == 0
                ? 'Scegli tre carte dal ventaglio'
                : 'Scegli ancora ${SpreadPosition.values.length - _drawn}',
            key: const Key('stesa_prompt'),
            textAlign: TextAlign.center,
            style: TypographyTokens.label(size: 12).copyWith(
                color: ColorTokens.textSecondary, letterSpacing: 1.2),
          ),
          const SizedBox(height: SpacingTokens.md),
          // Il ventaglio con la sua regia: ingresso a spirale, respiro,
          // taglio e vortice. Si ridisegna col battito delle quattro fasi.
          AnimatedBuilder(
            animation: Listenable.merge(
                [_ingresso, _respiro, _taglio, _mescola]),
            builder: (context, _) => StesaFan(
              palette: palette,
              taken: _taken,
              onPick: _pick,
              scene: _scene,
              ingresso: _ingresso.value,
              respiro: _respiro.value,
              taglio: _taglio.value,
              mescolamento: _mescola.value,
              taglioIndice: _taglioIndice,
              reduceMotion: _reduceMotion,
            ),
          ),
          const SizedBox(height: SpacingTokens.sm),
          // I gesti del mazzo. Lo scuotimento e' un di piu': questi tasti ci
          // sono sempre, cosi' chi non ha l'accelerometro non resta fuori.
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _GestoMazzo(
                key: const Key('stesa_taglia'),
                icona: Icons.content_cut_rounded,
                label: 'Taglia',
                palette: palette,
                attivo: _scene.accettaGesti,
                onTap: _taglia,
              ),
              const SizedBox(width: SpacingTokens.sm),
              _GestoMazzo(
                key: const Key('stesa_mischia'),
                icona: Icons.casino_rounded,
                label: 'Mischia',
                palette: palette,
                attivo: _scene.accettaGesti,
                onTap: _mischia,
              ),
              const SizedBox(width: SpacingTokens.sm),
              // Un solo interruttore per suono e vibrazione: chi zittisce
              // l'app non si aspetta di sentirla ancora vibrare in mano.
              _GestoMazzo(
                key: const Key('stesa_silenzio'),
                icona: _silenzio
                    ? Icons.volume_off_rounded
                    : Icons.volume_up_rounded,
                label: _silenzio ? 'Muto' : 'Suono',
                palette: palette,
                attivo: true,
                onTap: () => setState(() {
                  _silenzio = !_silenzio;
                  _sensi.silenzio = _silenzio;
                }),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _shake?.attivo ?? false
                ? 'Scuoti il telefono per mischiare'
                : 'Tocca Mischia per mescolare il mazzo',
            key: const Key('stesa_suggerimento_gesto'),
            textAlign: TextAlign.center,
            style: TypographyTokens.label(size: 11).copyWith(
                color: ColorTokens.textSecondary, letterSpacing: 0.8),
          ),
          const SizedBox(height: SpacingTokens.lg),
        ],
        // La sintesi memorabile, sopra le tre carte.
        if (_complete) ...[
          Text(_reading.sintesi,
              key: const Key('stesa_synthesis'),
              textAlign: TextAlign.center,
              style: TypographyTokens.display(size: 22)
                  .copyWith(color: palette.goldSoft, height: 1.25)),
          const SizedBox(height: SpacingTokens.md),
        ],
        if (_complete) _slots(palette),
        if (_complete) ...[
          const SizedBox(height: SpacingTokens.lg),
          // Strato 2, le tre posizioni col testo ricco letto nell'argomento.
          // La lente sta qui una volta sola: ripeterla su ogni posizione la
          // rendeva una formula.
          Text('${_reading.posizioni.first.apertura}, carta per carta',
              key: const Key('stesa_lente'),
              style: TypographyTokens.label(size: 11).copyWith(
                  color: palette.goldSoft.withValues(alpha: 0.9),
                  letterSpacing: 1.2)),
          const SizedBox(height: SpacingTokens.xs),
          for (final letta in _reading.posizioni) ...[
            _StratoPosizione(
              key: Key('stesa_letta_${letta.drawn.position.name}'),
              letta: letta,
              palette: palette,
            ),
            const SizedBox(height: SpacingTokens.sm),
          ],
          const SizedBox(height: SpacingTokens.xs),
          // Strato 3, le carte che dialogano.
          _Strato(
            key: const Key('stesa_dialogo'),
            titolo: 'Le carte che dialogano',
            testo: _reading.dialogo.text,
            palette: palette,
          ),
          const SizedBox(height: SpacingTokens.sm),
          // Strato 4, la carta chiave.
          _Strato(
            key: const Key('stesa_chiave'),
            titolo: 'La carta chiave',
            occhiello: _reading.chiave.drawn.displayName,
            testo: _reading.chiave.perche,
            palette: palette,
          ),
          const SizedBox(height: SpacingTokens.sm),
          // Strato 5, il consiglio di Medora.
          _Strato(
            key: const Key('stesa_consiglio'),
            titolo: 'Il consiglio di Medora',
            testo: _reading.consiglio,
            palette: palette,
            inEvidenza: true,
          ),
          const SizedBox(height: SpacingTokens.sm),
          // Strato 6, la domanda che apre a Chiedi ai Maestri.
          _Strato(
            key: const Key('stesa_domanda'),
            titolo: 'La domanda che ti lascio',
            testo: _reading.domanda,
            palette: palette,
            corsivo: true,
          ),
          const SizedBox(height: SpacingTokens.sm),
          Text(TarotSpread.closing,
              key: const Key('stesa_closing'),
              textAlign: TextAlign.center,
              style: TypographyTokens.body(size: 15).copyWith(
                  color: palette.goldSoft,
                  height: 1.4,
                  fontStyle: FontStyle.italic)),
          const SizedBox(height: SpacingTokens.lg),
          Center(
            child: FilledButton.icon(
              key: const Key('stesa_share'),
              onPressed: _sharing ? null : _onShare,
              style: FilledButton.styleFrom(
                backgroundColor: palette.gold,
                foregroundColor: palette.deepest,
                padding: const EdgeInsets.symmetric(
                    horizontal: SpacingTokens.xl, vertical: SpacingTokens.sm),
              ),
              icon: _sharing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.ios_share_rounded, size: 18),
              label: Text(_sharing ? 'Preparo la card' : 'Condividi',
                  style: TypographyTokens.label(size: 13)
                      .copyWith(letterSpacing: 0.6)),
            ),
          ),
        ],
            // IL DISCLAIMER E' USCITO DA QUI, ed era uno di SETTE.
            //
            // Le linee guida dicevano da sempre "una volta sola", e per
            // sette volte ognuno ha pensato che il proprio fosse quella
            // volta. Un disclaimer ripetuto smette di essere letto e
            // diventa un modo di scaricare la responsabilita' invece di
            // dirla. Adesso sta in un posto solo, nell'area privacy.
      ],
    );
  }

  void _showComingSoon(String voce) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$voce arriva presto nel Cerchio.')),
    );
  }

  Future<void> _onShare() async {
    setState(() {
      _sharing = true;
      _renderCard = true;
    });
    try {
      await WidgetsBinding.instance.endOfFrame;
      await Future<void>.delayed(const Duration(milliseconds: 80));
      await shareStesaCard(
        boundaryKey: _cardKey,
        text: 'La mia stesa a tre carte. Esoteric Circle.',
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Non riesco a preparare la card ora.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _sharing = false;
          _renderCard = false;
        });
      }
    }
  }
}

/// Il ventaglio di carte coperte, col dorso di Medora.
class _Slot extends StatelessWidget {
  const _Slot({
    required this.position,
    required this.drawn,
    required this.palette,
    this.revealSpec,
    this.revealProgress = 0,
    this.tiltX = 0,
    this.tiltY = 0,
    this.galleggio = 0,
  });

  final SpreadPosition position;
  final DrawnCard? drawn;
  final MaestroPalette palette;

  /// L'aura elementale, quando questa carta si sta scoprendo.
  final RevealSpec? revealSpec;
  final double revealProgress;

  /// L'inclinazione dal giroscopio e il galleggiamento lento. A zero la carta
  /// resta ferma e composta: e' il ripiego statico.
  final double tiltX;
  final double tiltY;
  final double galleggio;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // La carta posata fluttua piano e si inclina col giroscopio, come
        // sospesa davanti a chi guarda. E' un effetto di superficie: non tocca
        // il testo sotto ne' il pescaggio.
        Transform.translate(
          offset: Offset(0, galleggio),
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0012)
              ..rotateX(tiltY)
              ..rotateY(tiltX),
            child: Stack(
              alignment: Alignment.center,
              // L'aura deve poter uscire dal bordo della carta: e' attorno a
              // lei che l'elemento fiorisce, non dentro.
              clipBehavior: Clip.none,
              children: [
                AspectRatio(
                  aspectRatio: kTarotAspect,
                  child: drawn == null
                      ? _EmptySlot(palette: palette)
                      : _FlipCard(
                          key: ValueKey('${position.name}_${drawn!.card.stem}'),
                          drawn: drawn!,
                          palette: palette),
                ),
                // L'aura elementale, mentre la carta si scopre.
                if (revealSpec != null && revealProgress > 0)
                  Positioned.fill(
                    child: ElementalReveal(
                      key: Key('stesa_reveal_${position.name}'),
                      spec: revealSpec!,
                      progress: revealProgress,
                      palette: palette,
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: SpacingTokens.xs),
        Text(position.label.toUpperCase(),
            textAlign: TextAlign.center,
            style: TypographyTokens.label(size: 11).copyWith(
                color: palette.goldSoft, letterSpacing: 1.2)),
        if (drawn != null) ...[
          // Il nome in chiaro, grande e leggibile: nel cartiglio resta piccolo
          // e decorativo.
          // Il minimo tipografico non scende sotto una certa misura: qui si
          // rimpicciolisce la riga intera, cosi' il nome resta su due righe e
          // nessuna parola va a capo da sola.
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(splitNomeCartiglio(drawn!.card.name).join('\n'),
                key: Key('stesa_name_${position.name}'),
                textAlign: TextAlign.center,
                style: TypographyTokens.display(size: 16)
                    .copyWith(color: ColorTokens.textPrimary, height: 1.15)),
          ),
          if (drawn!.reversed)
            Text(drawn!.versoLabel,
                key: Key('stesa_reversed_${position.name}'),
                textAlign: TextAlign.center,
                style: TypographyTokens.label(size: 11).copyWith(
                    color: palette.goldSoft, letterSpacing: 0.6)),
          const SizedBox(height: 2),
          // Sotto la carta resta la sintesi breve: il testo ricco ha il suo
          // strato piu' sotto, ripeterlo qui in colonna stretta lo rendeva
          // illeggibile.
          Text(drawn!.summary,
              key: Key('stesa_meaning_${position.name}'),
              textAlign: TextAlign.center,
              style: TypographyTokens.body(size: 13).copyWith(
                  color: ColorTokens.textSecondary, height: 1.35)),
        ],
      ],
    );
  }
}

class _EmptySlot extends StatelessWidget {
  const _EmptySlot({required this.palette});

  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
            color: palette.gold.withValues(alpha: 0.28),
            style: BorderStyle.solid),
        color: palette.deepest.withValues(alpha: 0.35),
      ),
      child: Center(
        child: Icon(Icons.auto_awesome,
            size: 18, color: palette.gold.withValues(alpha: 0.35)),
      ),
    );
  }
}

/// La carta che si gira: dorso, mezzo giro, faccia. La rovesciata si mostra
/// ruotata di mezzo giro.
class _FlipCard extends StatefulWidget {
  const _FlipCard(
      {super.key, required this.drawn, required this.palette});

  final DrawnCard drawn;
  final MaestroPalette palette;

  @override
  State<_FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<_FlipCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  );

  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (MediaQuery.of(context).disableAnimations) {
      _controller.value = 1;
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = Curves.easeInOut.transform(_controller.value);
        final angle = (1 - t) * math.pi;
        final showBack = angle > math.pi / 2;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0012)
            ..rotateY(angle),
          // A meta' giro il contenuto e' specchiato: va contro-ruotato il DORSO,
          // che si vede quando l'angolo e' oltre il quarto di giro. La faccia,
          // che si vede ad angolo zero, non va toccata, altrimenti resterebbe
          // specchiata a riposo e i cartigli si leggerebbero al contrario.
          child: showBack
              ? Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateY(math.pi),
                  child: CardBack(palette: widget.palette),
                )
              : _CardFace(drawn: widget.drawn, palette: widget.palette),
        );
      },
    );
  }
}

/// La faccia della carta, con i cartigli riempiti a runtime.
class _CardFace extends StatelessWidget {
  const _CardFace({required this.drawn, required this.palette});

  final DrawnCard drawn;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return TarotCardArt(
      card: drawn.card,
      palette: palette,
      reversed: drawn.reversed,
    );
  }
}


/// Dorso dipinto di ripiego: un cielo con la stella di Medora.

/// Uno strato della lettura: titolo in maiuscoletto, poi il testo.
class _Strato extends StatelessWidget {
  const _Strato({
    super.key,
    required this.titolo,
    required this.testo,
    required this.palette,
    this.occhiello,
    this.inEvidenza = false,
    this.corsivo = false,
  });

  final String titolo;
  final String testo;
  final MaestroPalette palette;

  /// Una riga forte sopra il testo, come il nome della carta chiave.
  final String? occhiello;

  /// Il consiglio si stacca dagli altri strati, e' quello che si porta a casa.
  final bool inEvidenza;
  final bool corsivo;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(SpacingTokens.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
        color: inEvidenza
            ? palette.primary.withValues(alpha: 0.42)
            : palette.surfaceElevated.withValues(alpha: 0.55),
        border: Border.all(
            color: palette.gold.withValues(alpha: inEvidenza ? 0.55 : 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titolo.toUpperCase(),
              style: TypographyTokens.label(size: 11).copyWith(
                  color: palette.goldSoft.withValues(alpha: 0.85),
                  letterSpacing: 1.4)),
          const SizedBox(height: 6),
          if (occhiello != null) ...[
            Text(occhiello!,
                style: TypographyTokens.display(size: 17)
                    .copyWith(color: palette.goldSoft, height: 1.2)),
            const SizedBox(height: 4),
          ],
          Text(testo,
              style: TypographyTokens.body(size: 16).copyWith(
                color: inEvidenza ? palette.goldSoft : ColorTokens.textPrimary,
                height: 1.5,
                fontStyle: corsivo ? FontStyle.italic : FontStyle.normal,
              )),
        ],
      ),
    );
  }
}

/// Una posizione letta dentro l'argomento: apertura, nome della carta, testo
/// ricco dal corpus.
class _StratoPosizione extends StatelessWidget {
  const _StratoPosizione({
    super.key,
    required this.letta,
    required this.palette,
  });

  final PosizioneLetta letta;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(SpacingTokens.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
        color: palette.surfaceElevated.withValues(alpha: 0.55),
        border: Border.all(color: palette.gold.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(letta.drawn.position.label.toUpperCase(),
              style: TypographyTokens.label(size: 11).copyWith(
                  color: palette.goldSoft.withValues(alpha: 0.85),
                  letterSpacing: 1.4)),
          const SizedBox(height: 4),
          Text(letta.drawn.displayName,
              style: TypographyTokens.display(size: 17)
                  .copyWith(color: palette.goldSoft, height: 1.2)),
          const SizedBox(height: 6),
          Text(letta.testo,
              style: TypographyTokens.body(size: 16).copyWith(
                  color: ColorTokens.textPrimary, height: 1.5)),
        ],
      ),
    );
  }
}

/// Un gesto sul mazzo: taglia o mischia.
///
/// Resta sempre in campo, anche quando il telefono ha l'accelerometro: lo
/// scuotimento e' un di piu', mai l'unica strada per mescolare.
class _GestoMazzo extends StatelessWidget {
  const _GestoMazzo({
    super.key,
    required this.icona,
    required this.label,
    required this.palette,
    required this.attivo,
    required this.onTap,
  });

  final IconData icona;
  final String label;
  final MaestroPalette palette;
  final bool attivo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: attivo,
      label: label,
      child: GestureDetector(
        onTap: attivo ? onTap : null,
        child: AnimatedOpacity(
          opacity: attivo ? 1 : 0.4,
          duration: const Duration(milliseconds: 200),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
              color: palette.surfaceElevated.withValues(alpha: 0.6),
              border:
                  Border.all(color: palette.gold.withValues(alpha: 0.45)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icona, size: 15, color: palette.goldSoft),
                const SizedBox(width: 6),
                Text(label,
                    style: TypographyTokens.body(size: 14)
                        .copyWith(color: palette.goldSoft)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// La carta che si stacca dal ventaglio e vola nel suo slot.
///
/// Sale dal ventaglio verso Passato, Presente o Futuro, si illumina lungo la
/// strada e lascia dietro di se' una scia di stelle. Arrivata a destinazione
/// sparisce, e il flip dello slot la gira sulla faccia.
class _CartaInVolo extends StatelessWidget {
  const _CartaInVolo({
    super.key,
    required this.progress,
    required this.destinazione,
    required this.palette,
    required this.seed,
  });

  /// Il punto del volo, da 0 a 1.
  final double progress;

  /// L'indice dello slot verso cui va, da 0 a 2.
  final int destinazione;

  final MaestroPalette palette;

  /// La carta del ventaglio da cui e' partita: da qui nasce la sua scia.
  final int seed;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;
            // Gli slot stanno in tre colonne, il ventaglio in basso.
            final colonna = (destinazione.clamp(0, 2) * 2 + 1) / 6;
            final e = Curves.easeInOutCubic.transform(progress.clamp(0.0, 1.0));
            final partenzaX = w * (0.2 + 0.6 * ((seed % 9) / 8));
            final x = partenzaX + (w * colonna - partenzaX) * e;
            final y = h * 0.72 + (h * 0.34 - h * 0.72) * e;
            const cardW = 66.0;

            return Stack(
              children: [
                Positioned(
                  left: x - cardW / 2,
                  top: y,
                  width: cardW,
                  child: Opacity(
                    // Sfuma sul finire: lo slot prende il testimone col flip.
                    opacity: progress > 0.88 ? (1 - progress) / 0.12 : 1,
                    child: Transform.scale(
                      // Si alza dal ventaglio, quindi cresce appena.
                      scale: 1 + 0.12 * math.sin(e * math.pi),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: palette.goldSoft.withValues(
                                  alpha: 0.45 * math.sin(e * math.pi)),
                              blurRadius: 18,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: AspectRatio(
                          aspectRatio: kTarotAspect,
                          child: CardBack(palette: palette),
                        ),
                      ),
                    ),
                  ),
                ),
                // La scia di stelle, dietro la carta.
                Positioned(
                  left: x - cardW,
                  top: y,
                  width: cardW * 2,
                  height: h * 0.4,
                  child: StardustTrail(
                    progress: e,
                    palette: palette,
                    seed: seed,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
