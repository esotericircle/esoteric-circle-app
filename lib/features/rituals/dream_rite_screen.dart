import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/identity/birth_moon.dart';
import '../../core/maestro/maestro.dart';
import '../../core/rituals/daily_rituals.dart';
import '../../core/rituals/dream_rite_corpus.dart';
import '../../design_system/components/ritual_backdrop.dart';
import '../../design_system/components/zodiac_figures.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../services/breath_detector.dart';
import '../maestri/aura/meditation/meditation_audio.dart';
import '../tarot/stesa_senses.dart' show TiltListener;
import 'dream_rite_card.dart';

/// Rito del Sogno, ex Rito della Buonanotte: a rotazione fra i tre Maestri di
/// giorno in giorno, come il Rito dell'Alba.
///
/// Guarda al passato e al presente della giornata appena conclusa, mai al
/// futuro. Si apre nella nebbia, che si dirada col fiato; emergono le stelle
/// del cielo notturno reale di questo momento; si uniscono le stelle della
/// costellazione del segno in cui si trova la Luna adesso, letta da NightSky;
/// dalla figura unita scende il saluto della notte, ancorato a segno e fase
/// reali. Deterministico, nessuna AI a runtime.
class DreamRiteScreen extends StatefulWidget {
  const DreamRiteScreen({
    super.key,
    this.now,
    this.player = const SilentTonePlayer(),
  });

  final DateTime? now;

  /// Il lettore dei toni, per il suono opzionale. Di default e' silenzioso,
  /// come nella Meditazione: l'interfaccia c'e', il suono reale non ancora.
  final TonePlayer player;

  static Route<void> route({
    DateTime? now,
    TonePlayer player = const SilentTonePlayer(),
  }) =>
      MaterialPageRoute<void>(
        builder: (_) =>
            MaestroScope(child: DreamRiteScreen(now: now, player: player)),
      );

  @override
  State<DreamRiteScreen> createState() => _DreamRiteScreenState();
}

enum _Fase { nebbia, cielo, messaggio }

class _DreamRiteScreenState extends State<DreamRiteScreen>
    with TickerProviderStateMixin {
  late final DateTime _date = widget.now ?? DateTime.now();
  late final Maestro _maestro = DailyRituals.nightMaestro(_date);
  late final MaestroPalette _palette = MaestroPalette.forKey(ThemeKey.of(_maestro));
  late final BirthMoon _luna = DreamRiteCorpus.lunaDi(_date);
  late final ZodiacConstellation _figura =
      kZodiacConstellations.firstWhere((c) => c.sign == _luna.sign);

  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..repeat(reverse: true);

  final BreathDetector _fiato = BreathDetector();
  final TiltListener _tilt = TiltListener();
  StreamSubscription<double>? _livelli;
  Timer? _battito;

  _Fase _fase = _Fase.nebbia;

  /// Quanto la nebbia si e' diradata, da 0 (fitta) a 1 (aperta).
  double _nebbia = 0;
  double _micLivello = 0;
  double _spintaDito = 0;

  /// Le stelle gia' unite, in ordine.
  final List<int> _accese = [];
  bool _completa = false;

  /// Lo spostamento della vista col dito, quando il giroscopio non c'e'.
  Offset _panDito = Offset.zero;

  bool _riduciMovimento = false;
  bool _suono = false;

  @override
  void initState() {
    super.initState();
    _tilt.start();
    _tilt.addListener(_ridisegna);
    _avviaFiato();
    _battito = Timer.periodic(const Duration(milliseconds: 60), _passoFiato);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _riduciMovimento = MediaQuery.of(context).disableAnimations;
  }

  @override
  void dispose() {
    _battito?.cancel();
    _livelli?.cancel();
    _fiato.dispose();
    _tilt.removeListener(_ridisegna);
    _tilt.dispose();
    _pulse.dispose();
    if (_suono) widget.player.stop();
    super.dispose();
  }

  void _ridisegna() {
    if (mounted) setState(() {});
  }

  // Il fiato reale, quando il microfono c'e'. Se manca, resta il dito.
  Future<void> _avviaFiato() async {
    final acceso = await _fiato.start();
    if (!acceso || !mounted) return;
    _livelli = _fiato.level.listen((v) => _micLivello = v);
  }

  double get _reazione => math.max(_micLivello, _spintaDito);

  void _passoFiato(Timer _) {
    if (_fase != _Fase.nebbia || !mounted) return;
    final prima = _nebbia;
    if (_reazione > 0.10) {
      _nebbia = (_nebbia + 0.035).clamp(0.0, 1.0);
    } else if (_nebbia > 0 && _nebbia < 1) {
      _nebbia = (_nebbia - 0.004).clamp(0.0, 1.0);
    }
    _spintaDito = (_spintaDito - 0.06).clamp(0.0, 1.0);
    if (_nebbia >= 1 && prima < 1) {
      _apriIlCielo();
    } else if (_nebbia != prima) {
      setState(() {});
    }
  }

  void _apriIlCielo() {
    if (_fase != _Fase.nebbia) return;
    // Il fiato ha finito il suo compito: si spegne il battito e il microfono.
    _battito?.cancel();
    _battito = null;
    _livelli?.cancel();
    _livelli = null;
    _fiato.stop();
    setState(() {
      _nebbia = 1;
      _fase = _Fase.cielo;
    });
  }

  void _tocca(int indice) {
    if (_fase != _Fase.cielo || _completa) return;
    if (indice != _accese.length) return; // si uniscono in sequenza
    setState(() => _accese.add(indice));
    if (_accese.length == _figura.points.length) {
      _completa = true;
      Future<void>.delayed(const Duration(milliseconds: 900), () {
        if (mounted) setState(() => _fase = _Fase.messaggio);
      });
    }
  }

  Future<void> _cambiaSuono() async {
    setState(() => _suono = !_suono);
    if (_suono) {
      await widget.player.play(MeditationPreset.thetaBeat);
    } else {
      await widget.player.stop();
    }
  }

  Offset get _spostamento {
    if (_riduciMovimento) return Offset.zero;
    return Offset(_tilt.x, _tilt.y) * 300 + _panDito;
  }

  @override
  Widget build(BuildContext context) {
    final saluto = DreamRiteCorpus.saluto(_date);
    return Scaffold(
      backgroundColor: ColorTokens.neutralDeepest,
      appBar: AppBar(
        backgroundColor: _palette.deepest.withValues(alpha: 0.4),
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: _palette.goldSoft),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Indietro',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text('Rito del Sogno',
            style: TypographyTokens.display(size: 20)),
        actions: [
          IconButton(
            key: const Key('dream_sources'),
            icon: const Icon(Icons.info_outline_rounded),
            tooltip: 'Da dove nasce questo dono',
            onPressed: _mostraProvenienza,
          ),
        ],
      ),
      body: RitualBackdrop(
        palette: _palette,
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            key: const Key('dream_rite'),
            padding: const EdgeInsets.fromLTRB(SpacingTokens.lg, SpacingTokens.md,
                SpacingTokens.lg, SpacingTokens.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _scena(),
                const SizedBox(height: SpacingTokens.md),
                if (_fase == _Fase.nebbia) ..._nelBuio(),
                if (_fase == _Fase.cielo) ..._sottoIlCielo(),
                if (_fase == _Fase.messaggio) ..._ilSaluto(saluto),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- La scena: cielo, nebbia, costellazione ---

  Widget _scena() {
    const alto = 380.0;
    return SizedBox(
      height: alto,
      child: LayoutBuilder(
        builder: (context, box) {
          final w = box.maxWidth;
          return AnimatedBuilder(
            animation: _pulse,
            builder: (context, _) {
              final t = _riduciMovimento ? 0.5 : _pulse.value;
              return Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _CieloPainter(
                        palette: _palette,
                        t: t,
                        luce: _nebbia,
                        quieta: _fase == _Fase.messaggio,
                      ),
                    ),
                  ),
                  // La costellazione, che si muove col telefono o col dito.
                  if (_fase != _Fase.nebbia)
                    Positioned.fill(
                      child: Transform.translate(
                        offset: _spostamento,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: CustomPaint(
                                painter: _FiguraPainter(
                                  figura: _figura,
                                  palette: _palette,
                                  accese: _accese,
                                  completa: _completa,
                                  t: t,
                                ),
                              ),
                            ),
                            for (var i = 0; i < _figura.points.length; i++)
                              _stellaToccabile(i, w, alto, t),
                          ],
                        ),
                      ),
                    ),
                  // La nebbia, fitta all'inizio, che si apre col fiato.
                  if (_fase == _Fase.nebbia)
                    Positioned.fill(
                      child: GestureDetector(
                        key: const Key('dream_fog'),
                        behavior: HitTestBehavior.opaque,
                        onPanUpdate: (d) =>
                            _spintaDito = (_spintaDito + d.delta.distance / 90)
                                .clamp(0.0, 1.0),
                        child: CustomPaint(
                          painter: _NebbiaPainter(
                            palette: _palette,
                            apertura: _nebbia,
                            t: t,
                          ),
                        ),
                      ),
                    ),
                  // Il cielo si sposta anche col dito, quando serve.
                  if (_fase == _Fase.cielo && !_riduciMovimento)
                    Positioned.fill(
                      child: GestureDetector(
                        key: const Key('dream_pan'),
                        behavior: HitTestBehavior.translucent,
                        onPanUpdate: (d) => setState(() {
                          _panDito = Offset(
                            (_panDito.dx + d.delta.dx).clamp(-40.0, 40.0),
                            (_panDito.dy + d.delta.dy).clamp(-40.0, 40.0),
                          );
                        }),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  /// Una stella toccabile della figura. La prossima da unire pulsa.
  Widget _stellaToccabile(int i, double w, double h, double t) {
    final p = _figura.points[i];
    final x = (0.12 + p.dx * 0.76) * w;
    final y = (0.14 + p.dy * 0.70) * h;
    final unita = _accese.contains(i);
    final prossima = !_completa && i == _accese.length;
    final battito = prossima ? 0.7 + 0.3 * math.sin(t * math.pi * 2) : 1.0;
    return Positioned(
      left: x - 22,
      top: y - 22,
      child: GestureDetector(
        key: Key('dream_star_$i'),
        behavior: HitTestBehavior.opaque,
        onTap: () => _tocca(i),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: Container(
              width: unita ? 13 : 11 * battito,
              height: unita ? 13 : 11 * battito,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: unita ? Colors.white : Colors.white.withValues(alpha: 0.75),
                boxShadow: [
                  BoxShadow(
                    color: (unita ? _palette.goldSoft : _palette.gold)
                        .withValues(alpha: prossima ? 0.8 : 0.45),
                    blurRadius: prossima ? 18 : 10,
                    spreadRadius: prossima ? 3 : 1,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- I tre momenti sotto la scena ---

  List<Widget> _nelBuio() => [
        Text(DreamRiteCorpus.invitoNebbia(_maestro),
            key: const Key('dream_invito'),
            textAlign: TextAlign.center,
            style: TypographyTokens.body(size: 16)
                .copyWith(color: ColorTokens.textPrimary, height: 1.55)),
        const SizedBox(height: SpacingTokens.md),
        _Riga(
          palette: _palette,
          icona: Icons.air,
          testo: 'Respira piano verso il telefono, oppure passa il dito sulla '
              'nebbia: il ripiego vale sempre.',
        ),
        const SizedBox(height: SpacingTokens.sm),
        // La barra del fiato, che dice quanto si e' aperto.
        ClipRRect(
          borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
          child: LinearProgressIndicator(
            key: const Key('dream_breath_bar'),
            value: _nebbia,
            minHeight: 6,
            backgroundColor: _palette.deepest.withValues(alpha: 0.6),
            valueColor: AlwaysStoppedAnimation<Color>(_palette.goldSoft),
          ),
        ),
        const SizedBox(height: SpacingTokens.sm),
        TextButton(
          key: const Key('dream_fog_skip'),
          onPressed: _apriIlCielo,
          child: Text('Dirada la nebbia',
              style: TypographyTokens.label(size: 12)
                  .copyWith(color: _palette.goldSoft)),
        ),
      ];

  List<Widget> _sottoIlCielo() => [
        Text(
            _completa
                ? 'La figura è unita.'
                : (_accese.isEmpty
                    ? 'Alza il telefono verso il cielo.'
                    : 'Unisci le stelle.'),
            key: const Key('dream_invito_cielo'),
            textAlign: TextAlign.center,
            style: TypographyTokens.display(size: 20)
                .copyWith(color: _palette.goldSoft)),
        const SizedBox(height: SpacingTokens.xs),
        Text(
            'La costellazione di ${_luna.sign.italianName}, il segno in cui si '
            'trova la Luna adesso. Stelle unite ${_accese.length} su '
            '${_figura.points.length}.',
            key: const Key('dream_conteggio'),
            textAlign: TextAlign.center,
            style: TypographyTokens.body(size: 14)
                .copyWith(color: ColorTokens.textSecondary, height: 1.45)),
        const SizedBox(height: SpacingTokens.sm),
        _Riga(
          palette: _palette,
          icona: Icons.screen_rotation_alt_outlined,
          testo: _riduciMovimento
              ? 'Riduci Movimento è attivo: il cielo resta fermo, tocca le '
                  'stelle nel loro ordine.'
              : 'Muovi il telefono per guardarti intorno, oppure trascina col '
                  'dito. Tocca la stella che pulsa.',
        ),
      ];

  List<Widget> _ilSaluto(String saluto) => [
        Text('Il saluto di ${_maestro.displayName}',
            key: const Key('dream_message_title'),
            style: TypographyTokens.display(size: 19)
                .copyWith(color: _palette.goldSoft)),
        const SizedBox(height: SpacingTokens.xs),
        Text(DreamRiteCorpus.parola(_luna.sign).toUpperCase(),
            key: const Key('dream_word'),
            style: TypographyTokens.display(size: 32).copyWith(
                color: _palette.goldSoft, letterSpacing: 1.6)),
        const SizedBox(height: SpacingTokens.sm),
        Text(saluto,
            key: const Key('dream_message'),
            style: TypographyTokens.body(size: 16)
                .copyWith(color: ColorTokens.textPrimary, height: 1.6)),
        const SizedBox(height: SpacingTokens.sm),
        Text(DreamRiteCorpus.provenienza(_luna),
            key: const Key('dream_provenienza'),
            style: TypographyTokens.label(size: 11).copyWith(
                color: _palette.goldSoft.withValues(alpha: 0.85),
                letterSpacing: 0.5)),
        const SizedBox(height: SpacingTokens.lg),
        _Azioni(
          palette: _palette,
          luna: _luna,
          saluto: saluto,
          maestroNome: _maestro.displayName,
        ),
        const SizedBox(height: SpacingTokens.sm),
        TextButton.icon(
          key: const Key('dream_sound'),
          onPressed: _cambiaSuono,
          icon: Icon(_suono ? Icons.graphic_eq : Icons.music_note_outlined,
              size: 18, color: _palette.goldSoft),
          label: Text(
              _suono ? 'Battito theta acceso' : 'Battito theta, se lo vuoi',
              style: TypographyTokens.label(size: 12)
                  .copyWith(color: _palette.goldSoft)),
        ),
      ];

  void _mostraProvenienza() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheet) => Container(
        key: const Key('dream_sources_sheet'),
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
                Text('Da dove nasce questo dono',
                    style: TypographyTokens.display(size: 19)
                        .copyWith(color: _palette.goldSoft)),
                const SizedBox(height: SpacingTokens.sm),
                Text(DreamRiteCorpus.daDoveNasce(_luna),
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
}

/// Una riga di suggerimento, icona piu' testo, come negli altri riti.
class _Riga extends StatelessWidget {
  const _Riga(
      {required this.palette, required this.icona, required this.testo});

  final MaestroPalette palette;
  final IconData icona;
  final String testo;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icona, size: 14, color: palette.goldSoft),
        const SizedBox(width: 6),
        Expanded(
          child: Text(testo,
              style: TypographyTokens.label(size: 11).copyWith(
                color: palette.goldSoft.withValues(alpha: 0.75),
                letterSpacing: 0.2,
                height: 1.4,
              )),
        ),
      ],
    );
  }
}

/// Condividi la carta della notte, con la carta fuori campo per lo scatto.
class _Azioni extends StatefulWidget {
  const _Azioni({
    required this.palette,
    required this.luna,
    required this.saluto,
    required this.maestroNome,
  });

  final MaestroPalette palette;
  final BirthMoon luna;
  final String saluto;
  final String maestroNome;

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
      await shareDreamRiteCard(boundaryKey: _boundary, luna: widget.luna);
    } finally {
      if (mounted) setState(() => _condividendo = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            key: const Key('dream_share'),
            style: OutlinedButton.styleFrom(
                foregroundColor: widget.palette.goldSoft,
                side: BorderSide(
                    color: widget.palette.gold.withValues(alpha: 0.6))),
            onPressed: _condividendo ? null : _condividi,
            icon: const Icon(Icons.ios_share_rounded),
            label: const Text('Condividi la carta della notte'),
          ),
        ),
        if (_rendi)
          Positioned(
            left: -3000,
            top: 0,
            child: RepaintBoundary(
              key: _boundary,
              child: DreamRiteCard(
                luna: widget.luna,
                palette: widget.palette,
                saluto: widget.saluto,
                maestroNome: widget.maestroNome,
              ),
            ),
          ),
      ],
    );
  }
}

/// Il cielo notturno: campo di stelle che emerge col diradarsi della nebbia, e
/// che alla fine si acquieta, con le stelle che calano di luce.
class _CieloPainter extends CustomPainter {
  _CieloPainter({
    required this.palette,
    required this.t,
    required this.luce,
    required this.quieta,
  });

  final MaestroPalette palette;
  final double t;

  /// Quanto il cielo e' emerso, da 0 a 1.
  final double luce;

  /// Vero a rito concluso: il cielo si acquieta.
  final bool quieta;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            palette.primary.withValues(alpha: 0.28 * luce),
            palette.deepest,
            const Color(0xFF010208),
          ],
        ).createShader(rect),
    );

    final calo = quieta ? 0.55 : 1.0;
    final rng = math.Random(23);
    for (var i = 0; i < 90; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final brillio = 0.35 + 0.4 * math.sin((t + rng.nextDouble()) * math.pi * 2);
      canvas.drawCircle(
        Offset(x, y),
        rng.nextDouble() * 1.2 + 0.3,
        Paint()
          ..color = Colors.white
              .withValues(alpha: (brillio * 0.7 * luce * calo).clamp(0.0, 1.0)),
      );
    }
  }

  @override
  bool shouldRepaint(_CieloPainter old) =>
      old.t != t || old.luce != luce || old.quieta != quieta;
}

/// La nebbia fitta dell'apertura, che si apre dal centro col fiato.
class _NebbiaPainter extends CustomPainter {
  _NebbiaPainter(
      {required this.palette, required this.apertura, required this.t});

  final MaestroPalette palette;
  final double apertura;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final velo = (1 - apertura).clamp(0.0, 1.0);
    // Il buio ovattato che copre il cielo.
    canvas.drawRect(
      rect,
      Paint()..color = const Color(0xFF05060C).withValues(alpha: 0.92 * velo),
    );
    // Banchi di nebbia che respirano, sempre piu' radi.
    final rng = math.Random(7);
    for (var i = 0; i < 9; i++) {
      final cx = rng.nextDouble() * size.width;
      final cy = rng.nextDouble() * size.height;
      final r = size.width * (0.2 + rng.nextDouble() * 0.28);
      final onda = 0.9 + 0.1 * math.sin((t + i / 9) * math.pi * 2);
      canvas.drawCircle(
        Offset(cx, cy),
        r * onda,
        Paint()
          ..color = palette.surfaceElevated.withValues(alpha: 0.16 * velo)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.5),
      );
    }
  }

  @override
  bool shouldRepaint(_NebbiaPainter old) =>
      old.apertura != apertura || old.t != t;
}

/// La costellazione reale del segno della Luna: le stelle gia' unite coi fili
/// d'oro, che pulsano quando la figura si chiude.
class _FiguraPainter extends CustomPainter {
  _FiguraPainter({
    required this.figura,
    required this.palette,
    required this.accese,
    required this.completa,
    required this.t,
  });

  final ZodiacConstellation figura;
  final MaestroPalette palette;
  final List<int> accese;
  final bool completa;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    Offset map(Offset p) => Offset(
          (0.12 + p.dx * 0.76) * size.width,
          (0.14 + p.dy * 0.70) * size.height,
        );
    final battito = completa ? 0.7 + 0.3 * math.sin(t * math.pi * 2) : 1.0;
    final filo = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = completa ? 2.2 : 1.6
      ..strokeCap = StrokeCap.round
      ..color = palette.gold.withValues(alpha: (0.75 * battito).clamp(0.0, 1.0));
    // Si disegna uno spigolo solo quando entrambe le stelle sono unite.
    for (final (a, b) in figura.edges) {
      if (accese.contains(a) && accese.contains(b)) {
        canvas.drawLine(map(figura.points[a]), map(figura.points[b]), filo);
      }
    }
    if (completa) {
      // Un alone attorno alla figura chiusa.
      for (final p in figura.points) {
        canvas.drawCircle(
          map(p),
          16 * battito,
          Paint()
            ..color = palette.goldSoft.withValues(alpha: 0.18 * battito)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_FiguraPainter old) =>
      old.accese.length != accese.length ||
      old.completa != completa ||
      old.t != t;
}
