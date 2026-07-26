import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show Ticker;
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../../core/astro/sky_location.dart';
import '../../core/astro/sunset_time.dart';
import '../../core/astro/zodiac.dart';
import '../../core/identity/profile_controller.dart';
import '../../core/maestro/maestro.dart';
import '../../core/rituals/sunset_rune.dart';
import '../../core/rituals/sunset_rune_corpus.dart';
import '../../core/rituals/sunset_rune_memory.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../services/app_services.dart';
import '../maestri/caligo/rune/bindrune.dart';
import '../maestri/chat/chat_openers.dart';
import '../maestri/chat/maestro_chat_screen.dart';
import 'rune_strokes.dart';
import 'sunset_rune_card.dart';

/// La Runa del Tramonto, dominio Caligo, versione definitiva.
///
/// Il Dono appartiene al tramonto. La runa nasce deterministica dal giorno
/// rituale incrociato con la carta di nascita e il segno; il responso e' runa,
/// verso, fase lunare reale e segno solare. Si getta la pietra scuotendo o
/// toccando, la si incide tenendo il dito, poi due voci: cosa lasci fuori e cosa
/// porti dentro la notte. Alla settima sera le rune si legano in una bindrune.
/// Zero rete, zero AI, ogni sensore ha il suo ripiego tattile.
class SunsetRuneScreen extends StatefulWidget {
  const SunsetRuneScreen({
    super.key,
    this.now,
    this.dataNascita,
    this.segno,
    this.location = const DisabledSkyLocation(),
  });

  final DateTime? now;
  final DateTime? dataNascita;
  final Zodiac? segno;

  /// Sorgente della posizione per l'ora del tramonto, non bloccante. Di default
  /// spenta: l'ora e' stimata dal fuso, come nelle anteprime e nei test.
  final SkyLocation location;

  static Route<void> route({
    DateTime? now,
    DateTime? dataNascita,
    Zodiac? segno,
    SkyLocation location = const GeolocatorSkyLocation(),
  }) =>
      MaterialPageRoute<void>(
        builder: (_) => MaestroScope(
          child: SunsetRuneScreen(
            now: now,
            dataNascita: dataNascita,
            segno: segno,
            location: location,
          ),
        ),
      );

  @override
  State<SunsetRuneScreen> createState() => _SunsetRuneScreenState();
}

enum _Fase { getto, incisione, lettura }

class _SunsetRuneScreenState extends State<SunsetRuneScreen>
    with TickerProviderStateMixin {
  late final DateTime _ora = widget.now ?? DateTime.now();
  EstrazioneTramonto? _estrazione;
  EstrazioneTramonto get _e => _estrazione!;
  DateTime? _nascita;
  bool _risolta = false;
  final MaestroPalette _palette =
      MaestroPalette.forKey(const ThemeKey.of(Maestro.caligo));

  // Ingresso della pietra, respiro dell'alone, rimbalzo del getto, incisione
  // automatica di ripiego, flip della rotazione.
  late final AnimationController _ingresso = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1200))
    ..forward();
  late final AnimationController _alone = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 3400))
    ..repeat(reverse: true);
  late final AnimationController _rimbalzo =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 620));
  late final AnimationController _flip =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 900));

  Ticker? _incisioneTicker;
  StreamSubscription<AccelerometerEvent>? _shakeSub;
  Duration _ultimoTick = Duration.zero;

  _Fase _fase = _Fase.getto;
  double _incisione = 0; // 0..1, quanto e' scavato il segno
  int _trattiFatti = 0; // per il feedback aptico a ogni tratto
  bool _completa = false; // crossfade tratti verso l'asset avvenuto
  bool _premuto = false;
  bool _giroFatto = false;
  bool _riduciMovimento = false;

  // L'ora del tramonto.
  DateTime? _tramonto;
  bool _stimata = true;

  // La settimana e la cerniera.
  List<SeraSalvata> _settimana = [];

  int get _numeroTratti => (kRuneStrokes[_e.rune.name]?.length ?? 1);

  @override
  void initState() {
    super.initState();
    _ascoltaScuotimento();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _riduciMovimento = MediaQuery.of(context).disableAnimations;
    if (_risolta) return;
    _risolta = true;
    // La runa nasce dalla carta dell'utente: la data di nascita arriva dai
    // parametri o dal profilo, quando c'e' e non e' l'esempio.
    DateTime? nascita = widget.dataNascita;
    if (nascita == null) {
      try {
        final id = context.read<ProfileController>().identity;
        if (!id.isExample) nascita = id.birthMoment;
      } catch (_) {
        // Nessun profilo nel contesto, per esempio nei test: resta anonimo.
      }
    }
    _nascita = nascita;
    _estrazione =
        SunsetRune.estrai(_ora, dataNascita: nascita, segno: widget.segno);
    _calcolaTramonto();
    _controllaRitorno();
  }

  @override
  void dispose() {
    _incisioneTicker?.dispose();
    _shakeSub?.cancel();
    _ingresso.dispose();
    _alone.dispose();
    _rimbalzo.dispose();
    _flip.dispose();
    super.dispose();
  }

  Future<void> _calcolaTramonto() async {
    final offset = _ora.timeZoneOffset;
    // Prima l'ora stimata dal fuso, sempre disponibile.
    var lat = SunsetTime.latDiRipiego;
    var lon = SunsetTime.longitudineDaFuso(offset);
    var stimata = true;
    // Poi, se la posizione e' attiva, l'ora vera. Non blocca l'ingresso.
    final luogo = await widget.location.resolve();
    if (luogo != null) {
      lat = luogo.latitude;
      lon = luogo.longitude;
      stimata = false;
    }
    final t = SunsetTime.perData(_e.giornoRituale,
            lat: lat, lon: lon, offset: offset) ??
        SunsetTime.oraMedia(_e.giornoRituale);
    if (mounted) {
      setState(() {
        _tramonto = t;
        _stimata = stimata;
      });
    }
  }

  void _ascoltaScuotimento() {
    try {
      _shakeSub = accelerometerEventStream(
              samplingPeriod: const Duration(milliseconds: 66))
          .listen((ev) {
        final m = math.sqrt(ev.x * ev.x + ev.y * ev.y + ev.z * ev.z);
        if (m > 22) _getta();
      }, onError: (_) {}, cancelOnError: false);
    } catch (_) {
      // Nessun accelerometro: resta il tocco.
    }
  }

  // --- Gesto uno: il getto ---
  void _getta() {
    if (_fase != _Fase.getto) return;
    HapticFeedback.mediumImpact();
    _shakeSub?.cancel();
    _shakeSub = null;
    if (!_riduciMovimento) _rimbalzo.forward(from: 0);
    setState(() => _fase = _Fase.incisione);
  }

  // --- Gesto due: l'incisione ---
  void _inizioIncisione() {
    if (_fase != _Fase.incisione || _completa) return;
    _premuto = true;
    _ultimoTick = Duration.zero;
    _incisioneTicker ??= createTicker(_passoIncisione);
    if (_riduciMovimento) {
      // Ripiego accessibile: un tocco incide in un tempo fisso.
      _incisioneTicker!.stop();
    }
    if (!_incisioneTicker!.isActive) _incisioneTicker!.start();
    setState(() {});
  }

  void _fineIncisione() {
    if (_fase != _Fase.incisione) return;
    _premuto = false;
    // Il progresso resta dov'e': nessun reset, nessuna punizione.
    setState(() {});
  }

  void _passoIncisione(Duration elapsed) {
    final dt = (elapsed - _ultimoTick).inMilliseconds / 1000.0;
    _ultimoTick = elapsed;
    // Con Riduci Movimento l'incisione va da se' in 1.2 secondi; altrimenti
    // avanza solo mentre il dito preme, e la durata cresce coi tratti.
    final durata = _riduciMovimento ? 1.2 : _numeroTratti * 0.55;
    if (!_riduciMovimento && !_premuto) return;
    final prima = _incisione;
    _incisione = (_incisione + dt / durata).clamp(0.0, 1.0);
    // Feedback aptico a ogni tratto completato.
    final trattiOra = (_incisione * _numeroTratti).floor();
    if (trattiOra > _trattiFatti) {
      _trattiFatti = trattiOra;
      HapticFeedback.selectionClick();
    }
    if (_incisione >= 1 && prima < 1) {
      _completaIncisione();
    }
    setState(() {});
  }

  void _completaIncisione() {
    _incisioneTicker?.stop();
    HapticFeedback.mediumImpact();
    setState(() => _completa = true);
    // Crossfade dai tratti all'arte incisa, poi la lettura.
    Future<void>.delayed(const Duration(milliseconds: 1200), () async {
      if (!mounted) return;
      setState(() => _fase = _Fase.lettura);
      await _apriLettura();
    });
  }

  Future<void> _apriLettura() async {
    // Salva la sera e carica la settimana, per la striscia e il sigillo.
    final lasciare = _vocePrima();
    final porta = _vocePortare();
    await SunsetRuneMemory.scriviEstrazione(
        SunsetRuneMemory.seraDa(_e, lasciare: lasciare, porta: porta));
    final settimana = await SunsetRuneMemory.settimanaCorrente(_e.giornoRituale);
    if (mounted) setState(() => _settimana = settimana);
  }

  // La clausola di insistenza, se la runa e' gia' tornata nei sette giorni.
  String? _insistenza;
  bool _ritorno = false;

  Future<void> _controllaRitorno() async {
    final ripetuta = await SunsetRuneMemory.runaRipetutaNegliUltimi7(
        _e.rune.name, _e.giornoRituale);
    if (ripetuta && mounted) {
      setState(() {
        _ritorno = true;
        _insistenza = SunsetRuneCorpus.insistenza(
            SunsetRune.indiceInsistenza(_e, _nascita));
      });
    }
  }

  String _vocePrima() =>
      SunsetRuneCorpus.vocePrimaLasciare(_e, insistenzaClausola: _insistenza);
  String _vocePortare() =>
      SunsetRuneCorpus.vocePortare(_e, insistenzaClausola: _insistenza);

  void _gira() {
    if (_giroFatto) return;
    HapticFeedback.selectionClick();
    setState(() => _giroFatto = true);
    if (!_riduciMovimento) _flip.forward(from: 0);
  }

  bool get _settimaSera => _settimana.length >= 7;

  List<String> get _runeSettimana =>
      _settimana.map((s) => s.rune).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: _palette.deepest.withValues(alpha: 0.32),
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: _palette.goldSoft),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Indietro',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text('La Runa del Tramonto',
            style: TypographyTokens.display(size: 19)),
        actions: [
          IconButton(
            key: const Key('sunset_sources'),
            icon: const Icon(Icons.info_outline_rounded),
            tooltip: 'Fonti e metodo',
            onPressed: _mostraFonti,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Il fondale del tramonto, coi tre slot webp e il ripiego procedurale.
          Positioned.fill(
            child: _Fondale(
              palette: _palette,
              completa: _completa,
              momento: _completa
                  ? 2
                  : (_fase == _Fase.getto ? 0 : 1),
            ),
          ),
          SafeArea(
            child: _fase == _Fase.lettura
                ? _lettura()
                : _scenaPietra(),
          ),
        ],
      ),
    );
  }

  // La scena della pietra: getto e incisione, la pietra al centro.
  Widget _scenaPietra() {
    return Column(
      key: const Key('sunset_rune'),
      children: [
        const SizedBox(height: SpacingTokens.xxl),
        Expanded(
          child: Center(
            child: AnimatedBuilder(
              animation: Listenable.merge([_ingresso, _alone, _rimbalzo]),
              builder: (context, _) {
                final salita = _riduciMovimento
                    ? 0.0
                    : (1 - Curves.easeOutCubic.transform(_ingresso.value)) * 60;
                final gradi = _riduciMovimento
                    ? 0.0
                    : (1 - _ingresso.value) * 4 * math.pi / 180;
                final pop = _rimbalzo.isAnimating
                    ? 1 + 0.06 * (1 - Curves.easeOut.transform(_rimbalzo.value))
                    : 1.0;
                return Transform.translate(
                  offset: Offset(0, salita),
                  child: Transform.rotate(
                    angle: gradi,
                    child: Transform.scale(scale: pop, child: _pietra()),
                  ),
                );
              },
            ),
          ),
        ),
        _rigaOra(),
        const SizedBox(height: SpacingTokens.sm),
        _pillolaEgesti(),
        const SizedBox(height: SpacingTokens.xl),
      ],
    );
  }

  Widget _rigaOra() {
    final t = _tramonto;
    final ora = t == null
        ? ''
        : '${t.hour.toString().padLeft(2, '0')}:'
            '${t.minute.toString().padLeft(2, '0')}';
    if (!_stimata) {
      return Text('Tramonto delle $ora',
          key: const Key('sunset_ora'),
          style: TypographyTokens.label(size: 11).copyWith(
              color: _palette.goldSoft.withValues(alpha: 0.8),
              letterSpacing: 0.4));
    }
    return Column(
      children: [
        Text(
            t == null
                ? 'Ora stimata, la posizione non e\' attiva'
                : 'Ora stimata delle $ora, la posizione non e\' attiva',
            key: const Key('sunset_stimata'),
            textAlign: TextAlign.center,
            style: TypographyTokens.label(size: 11).copyWith(
                color: ColorTokens.textSecondary, letterSpacing: 0.3)),
        TextButton(
          key: const Key('sunset_attiva'),
          onPressed: _attivaPosizione,
          child: Text('Attiva la posizione',
              style: TypographyTokens.label(size: 11)
                  .copyWith(color: _palette.goldSoft)),
        ),
      ],
    );
  }

  Future<void> _attivaPosizione() async {
    // Riprova a risolvere la posizione, non blocca la scena.
    final luogo = await const GeolocatorSkyLocation().resolve();
    if (luogo == null || !mounted) return;
    final offset = _ora.timeZoneOffset;
    final t = SunsetTime.perData(_e.giornoRituale,
            lat: luogo.latitude, lon: luogo.longitude, offset: offset) ??
        SunsetTime.oraMedia(_e.giornoRituale);
    setState(() {
      _tramonto = t;
      _stimata = false;
    });
  }

  Widget _pietra() {
    const lato = 240.0;
    if (_fase == _Fase.getto) {
      // Pietra velata, in attesa del getto.
      return GestureDetector(
        key: const Key('sunset_getto_gesture'),
        behavior: HitTestBehavior.opaque,
        onTap: _getta,
        child: SizedBox(
          width: lato,
          height: lato,
          child: CustomPaint(
            key: const Key('sunset_stone'),
            painter: _PietraVelataPainter(
                palette: _palette, respiro: _alone.value),
          ),
        ),
      );
    }
    // Incisione: si tiene il dito e il segno si scava un tratto alla volta.
    return GestureDetector(
      key: const Key('sunset_incisione_gesture'),
      behavior: HitTestBehavior.opaque,
      onLongPressStart: (_) => _inizioIncisione(),
      onLongPressEnd: (_) => _fineIncisione(),
      onTap: _riduciMovimento ? _inizioIncisione : null,
      child: SizedBox(
        width: lato,
        height: lato,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // I tratti scavati, che sfumano quando arriva l'asset.
            AnimatedOpacity(
              opacity: _completa ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 500),
              child: CustomPaint(
                key: const Key('sunset_incisione'),
                size: const Size(lato, lato),
                painter: _IncisionePainter(
                  runeName: _e.rune.name,
                  progresso: _incisione,
                  palette: _palette,
                  completa: _completa,
                ),
              ),
            ),
            // L'arte incisa vera, che appare al completamento.
            if (_completa)
              AnimatedOpacity(
                opacity: 1.0,
                duration: const Duration(milliseconds: 500),
                child: SizedBox(
                  key: const Key('rune_glyph'),
                  width: lato * 0.9,
                  height: lato * 0.9,
                  child: _glifoAsset(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _glifoAsset() {
    final r = _e.rune;
    final glifo = r.hasImage
        ? Image.asset(r.fullPath!,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => CustomPaint(
                  painter: RunePainter(
                      runeName: r.name,
                      color: Colors.white,
                      glow: _palette.goldSoft,
                      intensity: 1.0),
                ))
        : CustomPaint(
            painter: RunePainter(
                runeName: r.name,
                color: Colors.white,
                glow: _palette.goldSoft,
                intensity: 1.0),
          );
    return _e.inOmbra
        ? Transform.rotate(angle: math.pi, child: glifo)
        : glifo;
  }

  Widget _pillolaEgesti() {
    final testo = _fase == _Fase.getto
        ? 'Scuoti per gettare la runa'
        : (_incisione > 0 && _incisione < 1 && !_premuto
            ? 'Il segno non e\' compiuto'
            : 'Tieni il dito sulla pietra');
    final ripiego = _fase == _Fase.getto
        ? 'Se preferisci, tocca la pietra per gettarla.'
        : (_riduciMovimento
            ? 'Un tocco incide il segno per intero.'
            : 'Tieni premuto: il segno si scava fino a dove arrivi.');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.lg),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: SpacingTokens.md, vertical: SpacingTokens.sm),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
              color: _palette.deepest.withValues(alpha: 0.5),
              border: Border.all(color: _palette.gold.withValues(alpha: 0.5)),
            ),
            child: Text(testo,
                key: const Key('sunset_prompt'),
                style: TypographyTokens.label(size: 12)
                    .copyWith(color: _palette.goldSoft, letterSpacing: 0.6)),
          ),
          const SizedBox(height: SpacingTokens.sm),
          Text(ripiego,
              textAlign: TextAlign.center,
              style: TypographyTokens.label(size: 11).copyWith(
                  color: Colors.white.withValues(alpha: 0.78),
                  letterSpacing: 0.2)),
        ],
      ),
    );
  }

  // --- La lettura: due voci, striscia, sigillo, azioni ---
  Widget _lettura() {
    return SingleChildScrollView(
      key: const Key('sunset_rune'),
      padding: const EdgeInsets.fromLTRB(
          SpacingTokens.lg, SpacingTokens.xxl, SpacingTokens.lg, SpacingTokens.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_ritorno)
            Padding(
              padding: const EdgeInsets.only(bottom: SpacingTokens.sm),
              child: Text(SunsetRuneCorpus.intestazioneRitorno(_e.rune.name),
                  key: const Key('sunset_ritorno'),
                  textAlign: TextAlign.center,
                  style: TypographyTokens.label(size: 12).copyWith(
                      color: _palette.goldSoft, letterSpacing: 0.4, height: 1.4)),
            ),
          // La pietra che gira per svelare la seconda voce.
          Center(child: _pietraGirata()),
          const SizedBox(height: SpacingTokens.md),
          Center(
            child: Text(_e.rune.name.toUpperCase(),
                key: const Key('sunset_nome'),
                style: TypographyTokens.display(size: 30)
                    .copyWith(color: _palette.goldSoft)),
          ),
          Center(
            child: Text(_e.rune.keyword.toUpperCase(),
                style: TypographyTokens.label(size: 11).copyWith(
                    color: ColorTokens.textSecondary, letterSpacing: 1.4)),
          ),
          const SizedBox(height: 2),
          Center(
            child: Text(
                _e.simmetrica
                    ? SunsetRuneCorpus.noteSimmetrica
                    : (_e.inOmbra ? 'verso d\'ombra' : 'verso dritto'),
                style: TypographyTokens.label(size: 12).copyWith(
                    color: _palette.goldSoft.withValues(alpha: 0.8),
                    letterSpacing: 0.6)),
          ),
          const SizedBox(height: SpacingTokens.lg),
          // Voce A: cosa lasci fuori.
          _bloccoVoce('Cosa lasci fuori', _vocePrima(), const Key('sunset_voce_uno')),
          const SizedBox(height: SpacingTokens.sm),
          Text(SunsetRuneCorpus.trasparenza(_e),
              key: const Key('sunset_trasparenza'),
              style: TypographyTokens.label(size: 11).copyWith(
                  color: ColorTokens.textSecondary, letterSpacing: 0.2)),
          const SizedBox(height: SpacingTokens.lg),
          // Voce B dietro la rotazione della pietra.
          if (!_giroFatto)
            _invitoGira()
          else
            _bloccoVoce('Cosa porti dentro la notte', _vocePortare(),
                const Key('sunset_voce_due')),
          const SizedBox(height: SpacingTokens.lg),
          _striscia(),
          if (_settimaSera) ...[
            const SizedBox(height: SpacingTokens.lg),
            _sigilloSettimana(),
          ],
          const SizedBox(height: SpacingTokens.lg),
          _azioni(),
          const SizedBox(height: SpacingTokens.xxxl),
        ],
      ),
    );
  }

  Widget _pietraGirata() {
    return AnimatedBuilder(
      animation: Listenable.merge([_alone, _flip]),
      builder: (context, _) {
        final giro = _giroFatto ? math.pi * _flip.value : 0.0;
        final m = Matrix4.identity()
          ..setEntry(3, 2, 0.0015)
          ..rotateY(giro);
        return Transform(
          alignment: Alignment.center,
          transform: m,
          child: SizedBox(width: 150, height: 168, child: _glifoAsset()),
        );
      },
    );
  }

  Widget _invitoGira() {
    return GestureDetector(
      key: const Key('sunset_gira_doppio'),
      onDoubleTap: _gira,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(SpacingTokens.md),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
          border: Border.all(color: _palette.gold.withValues(alpha: 0.4)),
        ),
        child: Column(
          children: [
            Text('Gira la pietra',
                key: const Key('sunset_gira'),
                style: TypographyTokens.display(size: 18)
                    .copyWith(color: _palette.goldSoft)),
            const SizedBox(height: SpacingTokens.xs),
            Text(
                'Inclina il telefono sull\'asse lungo, oppure tocca due volte: '
                'la pietra mostra il suo rovescio.',
                textAlign: TextAlign.center,
                style: TypographyTokens.label(size: 11).copyWith(
                    color: ColorTokens.textSecondary, height: 1.4)),
          ],
        ),
      ),
    );
  }

  Widget _bloccoVoce(String titolo, String testo, Key key) {
    return Container(
      key: key,
      padding: const EdgeInsets.all(SpacingTokens.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
        color: _palette.deepest.withValues(alpha: 0.42),
        border: Border.all(color: _palette.gold.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titolo.toUpperCase(),
              style: TypographyTokens.label(size: 12)
                  .copyWith(color: _palette.goldSoft, letterSpacing: 0.8)),
          const SizedBox(height: SpacingTokens.xs),
          Text(testo,
              style: TypographyTokens.body(size: 16)
                  .copyWith(color: ColorTokens.textPrimary, height: 1.55)),
        ],
      ),
    );
  }

  Widget _striscia() {
    final giorni = _settimana.map((s) => s.giorno).toSet();
    final oggiIso = _e.giornoIso;
    // Sette caselle: piene le sere fatte, appena accennate le altre.
    return Column(
      key: const Key('sunset_settimana'),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (var i = 0; i < 7; i++)
              _casella(i, giorni, oggiIso),
          ],
        ),
        const SizedBox(height: SpacingTokens.xs),
        Text(_rigaSettimana(),
            key: const Key('sunset_settimana_riga'),
            textAlign: TextAlign.center,
            style: TypographyTokens.label(size: 11)
                .copyWith(color: ColorTokens.textSecondary, letterSpacing: 0.2)),
      ],
    );
  }

  Widget _casella(int i, Set<String> giorni, String oggiIso) {
    // Le caselle in ordine dalla piu' vecchia a oggi, riempite dove c'e' una sera.
    final piena = i < _settimana.length;
    final oggi = piena && _settimana[i].giorno == oggiIso;
    return Container(
      width: 30,
      height: 38,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: piena
            ? _palette.surfaceElevated.withValues(alpha: 0.95)
            : Colors.transparent,
        border: Border.all(
            color: _palette.gold.withValues(alpha: piena ? 0.7 : 0.22),
            width: oggi ? 2 : 1),
        boxShadow: oggi
            ? [
                BoxShadow(
                    color: _palette.goldSoft.withValues(alpha: 0.5),
                    blurRadius: 8)
              ]
            : null,
      ),
      child: piena
          ? Center(
              child: Text(_settimana[i].rune.substring(0, 1),
                  style: TypographyTokens.label(size: 13)
                      .copyWith(color: _palette.goldSoft)))
          : null,
    );
  }

  String _rigaSettimana() {
    final n = _settimana.length;
    if (n <= 1) {
      return 'La prima delle sette. Questa striscia si riempie una sera per volta.';
    }
    if (n >= 7) {
      return 'Sette sere su sette. Le tue rune si sono legate.';
    }
    const parole = ['zero', 'prima', 'seconda', 'terza', 'quarta', 'quinta', 'sesta'];
    return '${_capitale(parole[n])} sera su sette. '
        'Alla settima le tue rune si legheranno.';
  }

  String _capitale(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  Widget _sigilloSettimana() {
    // Le due rune dominanti della settimana, oppure la prima e l'ultima.
    final rune = _runeSettimana;
    final conteggi = <String, int>{};
    for (final r in rune) {
      conteggi[r] = (conteggi[r] ?? 0) + 1;
    }
    final ordinate = conteggi.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final dueDom = ordinate.any((e) => e.value > 1)
        ? ordinate.take(2).map((e) => e.key).toList()
        : [rune.first, rune.last];
    final incompleta = rune.length < 7;
    return Container(
      key: const Key('sunset_sigillo'),
      padding: const EdgeInsets.all(SpacingTokens.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
        color: _palette.deepest.withValues(alpha: 0.5),
        border: Border.all(color: _palette.gold.withValues(alpha: 0.35)),
      ),
      child: Column(
        children: [
          Text('IL SIGILLO DELLA SETTIMANA',
              style: TypographyTokens.label(size: 12)
                  .copyWith(color: _palette.goldSoft, letterSpacing: 0.8)),
          const SizedBox(height: SpacingTokens.sm),
          BindruneSigillo(
            runeNames: rune,
            oro: _palette.gold,
            alone: _palette.goldSoft,
            lato: 168,
            deduplica: true,
          ),
          const SizedBox(height: SpacingTokens.sm),
          Text(
              incompleta
                  ? '${_capitale(_numeroParola(rune.length))} rune, '
                      '${_numeroParola(rune.length)} sere. Il sigillo porta i '
                      'vuoti che hai lasciato.'
                  : 'La settimana lega ${dueDom.first} e ${dueDom.last}: '
                      'due segni che tornano, un legame solo.',
              textAlign: TextAlign.center,
              style: TypographyTokens.body(size: 14)
                  .copyWith(color: ColorTokens.textPrimary, height: 1.5)),
        ],
      ),
    );
  }

  String _numeroParola(int n) {
    const p = ['zero', 'una', 'due', 'tre', 'quattro', 'cinque', 'sei', 'sette'];
    return n >= 0 && n < p.length ? p[n] : '$n';
  }

  Widget _azioni() {
    return _Azioni(palette: _palette, estrazione: _e);
  }

  void _mostraFonti() {
    final tramonto = _tramonto;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheet) => Container(
        key: const Key('sunset_sources_sheet'),
        padding: const EdgeInsets.fromLTRB(SpacingTokens.lg, SpacingTokens.md,
            SpacingTokens.lg, SpacingTokens.xl),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_palette.surfaceElevated, _palette.deepest],
          ),
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(SpacingTokens.radiusXl)),
          border: Border.all(color: _palette.gold.withValues(alpha: 0.3)),
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
                        .copyWith(color: _palette.goldSoft)),
                const SizedBox(height: SpacingTokens.sm),
                Text(_fontiEMetodo(tramonto),
                    style: TypographyTokens.body(size: 15).copyWith(
                        color: ColorTokens.textPrimary, height: 1.45)),
                const SizedBox(height: SpacingTokens.lg),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(sheet).pop(),
                    child: Text('Va bene',
                        style: TypographyTokens.label(size: 13)
                            .copyWith(color: _palette.goldSoft)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _fontiEMetodo(DateTime? tramonto) {
    final ora = tramonto == null
        ? 'in calcolo'
        : '${tramonto.hour.toString().padLeft(2, '0')}:'
            '${tramonto.minute.toString().padLeft(2, '0')}';
    final oraRiga = _stimata
        ? 'Il tramonto e\' stimato dal fuso, la posizione non e\' attiva: $ora.'
        : 'Il tramonto di stasera e\' calcolato sul tuo luogo: $ora.';
    return "L'Elder Futhark e' l'alfabeto runico germanico di ventiquattro segni, "
        "nelle tre aett di Freyr, Hagal e Tyr, qui nell'ordine tradizionale. Il "
        "verso d'ombra o merkstave e' una convenzione moderna: otto segni sono "
        "simmetrici e non lo hanno, quindi restano sempre dritti.\n\n"
        "L'estrazione e' deterministica: nasce dalla data del tramonto incrociata "
        "con la tua data di nascita e col tuo segno, quindi la runa e' tua e non "
        "la stessa per tutti. Il responso si compone di quattro fattori reali: la "
        "runa, il suo verso, la fase lunare vera della sera e il tuo segno solare.\n\n"
        "$oraRiga L'ora usa l'algoritmo NOAA, sul dispositivo, senza rete.\n\n"
        "Per intrattenimento e crescita personale, nessuna promessa deterministica.";
  }
}

// ===========================================================================
// I painter della scena.
// ===========================================================================

/// Il fondale del tramonto: se ci sono i tre webp li usa, altrimenti dipinge un
/// cielo di tramonto procedurale, orizzonte basso e sole per meta' sotto la
/// linea, rame verso viola, una stella singola. Nessun cerchio, nessuna raggiera.
class _Fondale extends StatelessWidget {
  const _Fondale({
    required this.palette,
    required this.completa,
    required this.momento,
  });

  final MaestroPalette palette;
  final bool completa;

  /// Zero prima del getto, uno durante l'incisione, due dopo il completamento.
  final int momento;

  // I tre slot dipinti, cablati come costanti. I file non esistono ancora: a
  // runtime l'errorBuilder ripiega sul procedurale, senza toccare stato_asset.
  static const List<String> _slots = [
    'assets/ritual_backgrounds/tramonto_prima_v1.webp',
    'assets/ritual_backgrounds/tramonto_al_v1.webp',
    'assets/ritual_backgrounds/tramonto_dopo_v1.webp',
  ];

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      _slots[momento.clamp(0, 2)],
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => CustomPaint(
          painter: _TramontoPainter(palette: palette, completa: completa)),
    );
  }
}

class _TramontoPainter extends CustomPainter {
  _TramontoPainter({required this.palette, required this.completa});

  final MaestroPalette palette;
  final bool completa;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    // Gradiente rame verso viola, che dopo l'incisione scende di un gradino.
    final alto = completa
        ? const Color(0xFF2A1230)
        : const Color(0xFF7A3B1E);
    final medio = completa
        ? const Color(0xFF3A1840)
        : const Color(0xFFB8632C);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF120818),
            alto,
            medio,
            palette.deepest,
          ],
          stops: const [0.0, 0.4, 0.66, 1.0],
        ).createShader(rect),
    );
    final orizzonte = size.height * 0.72;
    // Sole per meta' sotto la linea dell'orizzonte.
    final sole = Offset(size.width * 0.5, orizzonte);
    canvas.drawCircle(
      sole,
      size.width * 0.5,
      Paint()
        ..shader = RadialGradient(colors: [
          (completa ? const Color(0xFFCC8877) : const Color(0xFFFFE0A8))
              .withValues(alpha: completa ? 0.18 : 0.4),
          const Color(0x00000000),
        ]).createShader(Rect.fromCircle(center: sole, radius: size.width * 0.5)),
    );
    canvas.drawCircle(
      sole,
      size.width * 0.16,
      Paint()
        ..color = (completa ? const Color(0xFFB86A5A) : const Color(0xFFFFCE7A))
            .withValues(alpha: completa ? 0.5 : 0.85),
    );
    // La linea dell'orizzonte copre la meta' bassa del sole.
    canvas.drawRect(
      Rect.fromLTRB(0, orizzonte, size.width, size.height),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            medio.withValues(alpha: 0.9),
            palette.deepest,
          ],
        ).createShader(Rect.fromLTRB(0, orizzonte, size.width, size.height)),
    );
    // Una stella singola, sola nel cielo del tramonto.
    canvas.drawCircle(
      Offset(size.width * 0.7, size.height * 0.22),
      2.2,
      Paint()..color = Colors.white.withValues(alpha: 0.9),
    );
    canvas.drawCircle(
      Offset(size.width * 0.7, size.height * 0.22),
      7,
      Paint()
        ..shader = RadialGradient(colors: [
          Colors.white.withValues(alpha: 0.4),
          const Color(0x00000000),
        ]).createShader(Rect.fromCircle(
            center: Offset(size.width * 0.7, size.height * 0.22), radius: 7)),
    );
  }

  @override
  bool shouldRepaint(_TramontoPainter old) => old.completa != completa;
}

/// La pietra d'osso in stato velato, con un alone caldo che respira e un sigillo
/// coperto al centro. Mai un rettangolo nudo.
class _PietraVelataPainter extends CustomPainter {
  _PietraVelataPainter({required this.palette, required this.respiro});

  final MaestroPalette palette;
  final double respiro;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final w = size.width * 0.52;
    final h = size.height * 0.82;
    final rect = Rect.fromCenter(center: c, width: w, height: h);
    final rrect = RRect.fromRectAndCorners(
      rect,
      topLeft: Radius.circular(w * 0.5),
      topRight: Radius.circular(w * 0.5),
      bottomLeft: const Radius.circular(16),
      bottomRight: const Radius.circular(16),
    );
    // Alone caldo che respira fra alpha 0.25 e 0.40.
    final a = 0.25 + 0.15 * respiro;
    canvas.drawRRect(
      rrect.inflate(20),
      Paint()
        ..color = palette.goldSoft.withValues(alpha: a)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28),
    );
    // Ombra 2.5D morbida.
    canvas.drawRRect(
      rrect.shift(const Offset(0, 8)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [palette.surfaceElevated, palette.deepest],
        ).createShader(rect),
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = palette.gold.withValues(alpha: 0.6),
    );
    // Sigillo coperto al centro, appena intuibile.
    canvas.drawCircle(
      c,
      w * 0.22,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = palette.goldSoft.withValues(alpha: 0.45),
    );
  }

  @override
  bool shouldRepaint(_PietraVelataPainter old) => old.respiro != respiro;
}

/// L'incisione tratto per tratto, nell'ordine reale di kRuneStrokes, col raggio
/// che scende dall'orizzonte e la punta dove si sta scavando.
class _IncisionePainter extends CustomPainter {
  _IncisionePainter({
    required this.runeName,
    required this.progresso,
    required this.palette,
    required this.completa,
  });

  final String runeName;
  final double progresso;
  final MaestroPalette palette;
  final bool completa;

  @override
  void paint(Canvas canvas, Size size) {
    final strokes = kRuneStrokes[runeName];
    if (strokes == null) return;
    // La tavola di pietra scoperta su cui si scava: la stessa sagoma ad arco
    // della pietra velata, senza il velo, cosi' il getto atterra qui e la
    // superficie da incidere e' sempre visibile, anche prima del primo tratto.
    _tavola(canvas, size);
    final lato = size.shortestSide * 0.6;
    final left = (size.width - lato) / 2;
    final top = (size.height - lato) / 2;
    Offset map(Offset p) => Offset(left + p.dx * lato, top + p.dy * lato);

    // Lunghezze cumulative dei tratti, per scavare in proporzione.
    final lunghezze = <double>[];
    var totale = 0.0;
    for (final poly in strokes) {
      var l = 0.0;
      for (var i = 1; i < poly.length; i++) {
        l += (map(poly[i]) - map(poly[i - 1])).distance;
      }
      lunghezze.add(l);
      totale += l;
    }
    final daScavare = totale * progresso.clamp(0.0, 1.0);

    final glow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = lato * 0.05
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = const Color(0xFFFFF3D0).withValues(alpha: 0.5)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, lato * 0.03);
    final solco = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = lato * 0.03
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = completa ? const Color(0xFFCC4B22) : const Color(0xFFFFF6DA);

    var fatto = 0.0;
    Offset? punta;
    for (var s = 0; s < strokes.length; s++) {
      final poly = strokes[s];
      if (fatto >= daScavare) break;
      final path = Path()..moveTo(map(poly.first).dx, map(poly.first).dy);
      var ultimo = poly.first;
      for (var i = 1; i < poly.length; i++) {
        final segLen = (map(poly[i]) - map(poly[i - 1])).distance;
        if (fatto + segLen <= daScavare) {
          path.lineTo(map(poly[i]).dx, map(poly[i]).dy);
          fatto += segLen;
          ultimo = poly[i];
        } else {
          final resto = (daScavare - fatto) / segLen;
          final p = Offset.lerp(poly[i - 1], poly[i], resto.clamp(0.0, 1.0))!;
          path.lineTo(map(p).dx, map(p).dy);
          fatto = daScavare;
          ultimo = p;
          break;
        }
      }
      canvas.drawPath(path, glow);
      canvas.drawPath(path, solco);
      punta = map(ultimo);
    }

    // Il raggio dall'orizzonte alla punta dell'incisione, mentre si scava.
    if (!completa && progresso > 0 && progresso < 1 && punta != null) {
      canvas.drawLine(
        Offset(size.width / 2, size.height),
        punta,
        Paint()
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round
          ..color = const Color(0xFFFFF3D0).withValues(alpha: 0.55),
      );
      // Qualche scintilla sulla punta.
      final rng = math.Random((progresso * 1000).floor());
      for (var i = 0; i < 4; i++) {
        canvas.drawCircle(
          punta + Offset((rng.nextDouble() - 0.5) * 10, (rng.nextDouble() - 0.5) * 10),
          rng.nextDouble() * 1.4 + 0.4,
          Paint()..color = Colors.white.withValues(alpha: 0.8),
        );
      }
    }
  }

  // La pietra scoperta, superficie del segno. Sagoma condivisa con la pietra
  // velata: arco in alto, base squadrata, bordo oro, ombra 2.5D morbida.
  void _tavola(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final w = size.width * 0.52;
    final h = size.height * 0.82;
    final rect = Rect.fromCenter(center: c, width: w, height: h);
    final rrect = RRect.fromRectAndCorners(
      rect,
      topLeft: Radius.circular(w * 0.5),
      topRight: Radius.circular(w * 0.5),
      bottomLeft: const Radius.circular(16),
      bottomRight: const Radius.circular(16),
    );
    canvas.drawRRect(
      rrect.shift(const Offset(0, 8)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [palette.surfaceElevated, palette.deepest],
        ).createShader(rect),
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = palette.gold.withValues(alpha: 0.6),
    );
  }

  @override
  bool shouldRepaint(_IncisionePainter old) =>
      old.progresso != progresso || old.completa != completa;
}

/// Condividi e Parlane con Caligo, con la carta fuori campo per lo scatto.
class _Azioni extends StatefulWidget {
  const _Azioni({required this.palette, required this.estrazione});

  final MaestroPalette palette;
  final EstrazioneTramonto estrazione;

  @override
  State<_Azioni> createState() => _AzioniState();
}

class _AzioniState extends State<_Azioni> {
  final GlobalKey _boundary = GlobalKey();
  bool _condividendo = false;
  bool _rendi = false;

  Future<void> _condividi() async {
    setState(() {
      _condividendo = true;
      _rendi = true;
    });
    try {
      await WidgetsBinding.instance.endOfFrame;
      await Future<void>.delayed(const Duration(milliseconds: 80));
      await shareSunsetRuneCard(
          boundaryKey: _boundary, estrazione: widget.estrazione);
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
                key: const Key('sunset_share'),
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
                key: const Key('sunset_consulta'),
                style: FilledButton.styleFrom(
                    backgroundColor: palette.primary,
                    foregroundColor: palette.onPrimary),
                onPressed: () {
                  final services = context.read<AppServices>();
                  final verso = widget.estrazione.inOmbra
                      ? 'in merkstave'
                      : 'dritta';
                  Navigator.of(context).push(MaestroChatScreen.route(
                      maestro: Maestro.caligo,
                      services: services,
                      initialUserMessage: ChatOpeners.runaTramonto(
                          widget.estrazione.rune.name, verso)));
                },
                icon: const Icon(Icons.forum_outlined),
                label: const Text('Parlane con Caligo'),
              ),
            ],
          ),
        ),
        if (_rendi)
          Positioned(
            left: -3000,
            top: 0,
            child: RepaintBoundary(
              key: _boundary,
              child: SunsetRuneCard(
                  estrazione: widget.estrazione, palette: widget.palette),
            ),
          ),
      ],
    );
  }
}
