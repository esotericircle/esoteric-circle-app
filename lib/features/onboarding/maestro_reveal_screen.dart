import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/astro/natal_chart.dart';
import '../../core/astro/natal_chart_controller.dart';
import '../../core/astro/natal_poetics.dart';
import '../../core/identity/identity_controller.dart';
import '../../core/maestro/maestro.dart';
import '../../core/permissions/app_permission.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../design_system/typography/paragrafi_di_lettura.dart';
import '../../services/breath_detector.dart';
import 'widgets/maestro_card.dart';
import 'widgets/ritual_object.dart';
import 'widgets/sensory_reveal.dart';
import '../../core/sensi/palette_sensoriale.dart';

/// Rivelazione del Maestro col rito del soffio.
///
/// Il Maestro assegnato si svela soffiando sull'oggetto rituale vivo (sfera di
/// cristallo su piedistallo per Medora, candela per Caligo, soffione per Aura):
/// il microfono misura il soffio con una soglia generosa, ma il tocco e' sempre
/// la via garantita. La scala dell'aiuto universale ([RevealHelp]) governa i
/// gradini: l'oggetto invita col movimento, dopo tre secondi le silhouette
/// senza sfondo, al primo input il feedback e' immediato, e poco dopo appare
/// l'invito sempre toccabile "Tocca per svelare". Rispetta Riduci Movimento.
class MaestroRevealScreen extends StatefulWidget {
  const MaestroRevealScreen({
    super.key,
    required this.maestro,
    required this.onRevealed,
  });

  final Maestro maestro;
  final ValueChanged<Maestro> onRevealed;

  @override
  State<MaestroRevealScreen> createState() => _MaestroRevealScreenState();
}

class _MaestroRevealScreenState extends State<MaestroRevealScreen>
    with SingleTickerProviderStateMixin {
  final BreathDetector _breath = BreathDetector();
  static const _help = RevealHelp();

  StreamSubscription<double>? _levelSub;
  // Un solo ticker vsync fa da orologio del rito: cosi' i gradini d'aiuto
  // seguono lo stesso tempo dell'oggetto animato, senza dipendere da un timer.
  late final Ticker _ticker;
  Duration _lastFrame = Duration.zero;

  double _progress = 0;
  double _micLevel = 0;
  double _dragPulse = 0;
  bool _micAvailable = false;
  bool _revealed = false;
  bool _autoFinishing = false;

  int _elapsedMs = 0;
  int _lastInputMs = 0;
  bool _attempted = false;
  double _idleMs = 0;

  bool _showCoach = false;
  bool _showSafetyTap = false;

  // Soglie generose e perdonanti: il soffio piu' lieve basta e il dito reagisce
  // subito.
  static const _blowThreshold = 0.10;

  double get _reactLevel => math.max(_micLevel, _dragPulse);

  bool _micAsked = false;

  @override
  void initState() {
    super.initState();
    // Nessuna richiesta di microfono all'apertura: si soffia col dito, e il
    // microfono si chiede solo quando l'utente sceglie di usare la voce.
    _ticker = createTicker(_onFrame)..start();
  }

  String get _ritualObjectName => switch (widget.maestro) {
        Maestro.medora => 'sulla sfera di cristallo',
        Maestro.caligo => 'sulla candela',
        Maestro.aura => 'sul soffione',
      };

  Future<void> _askMic() async {
    setState(() => _micAsked = true);
    final palette = MaestroPalette.forKey(ThemeKey.of(widget.maestro));
    final granted = await requestPermissionWithPrelude(
      context,
      permission: AppPermission.microphone,
      palette: palette,
      maestro: widget.maestro,
      copy: PermissionCopy(
        icon: Icons.mic_none_rounded,
        title: '${widget.maestro.displayName} ha bisogno del microfono',
        body:
            'Per soffiare $_ritualObjectName, il microfono ascolta solo il tuo soffio, non registra nulla né conserva audio.',
        cta: 'Attiva il microfono',
      ),
      systemRequest: () => _breath.start(),
    );
    if (!mounted) return;
    setState(() => _micAvailable = granted);
    if (granted) _levelSub = _breath.level.listen((l) => _micLevel = l);
  }

  void _onFrame(Duration elapsed) {
    if (_revealed) return;
    final dtMs = (elapsed - _lastFrame).inMilliseconds.clamp(0, 100).toDouble();
    _lastFrame = elapsed;
    _elapsedMs = elapsed.inMilliseconds;
    final k = dtMs / 60.0; // passo normalizzato a un tick di 60ms
    final blowing = _micAvailable && _micLevel > _blowThreshold;
    setState(() {
      _dragPulse *= math.pow(0.85, k).toDouble();
      if (_autoFinishing) {
        // Il tocco di sicurezza porta a termine da solo la dispersione.
        _progress = (_progress + 0.06 * k).clamp(0.0, 1.0);
        _dragPulse = math.max(_dragPulse, 0.6);
      } else if (blowing) {
        _progress = (_progress + 0.05 * k).clamp(0.0, 1.0);
        _lastInputMs = _elapsedMs;
        _attempted = true;
        _idleMs = 0;
      } else {
        _idleMs += dtMs;
        // Rientro molto lento: il progresso guadagnato non si perde in fretta.
        if (_idleMs > 840) _progress = (_progress - 0.006 * k).clamp(0.0, 1.0);
      }

      final sinceStart = Duration(milliseconds: _elapsedMs);
      final idleSinceInput = _elapsedMs - _lastInputMs;
      final attemptStalled =
          _attempted && _progress > 0.02 && _progress < 1 && idleSinceInput > 1100;
      _showCoach = _help.showCoach(sinceStart: sinceStart, progress: _progress);
      _showSafetyTap = !_autoFinishing &&
          _help.showSafetyTap(
              sinceStart: sinceStart,
              attemptStalled: attemptStalled,
              progress: _progress);
    });
    if (_progress >= 1.0) _complete();
  }

  void _onDrag(DragUpdateDetails d) {
    if (_revealed) return;
    setState(() {
      // Feedback immediato: anche un tocco minimo muove il rito e accende
      // l'oggetto.
      _progress = (_progress + math.max(d.delta.distance / 900, 0.004))
          .clamp(0.0, 1.0);
      _dragPulse = 1;
      _attempted = true;
      _lastInputMs = _elapsedMs;
      _idleMs = 0;
    });
    if (_progress >= 1.0) _complete();
  }

  void _finishByTap() {
    // La via garantita: un tocco completa la dispersione, sensori a parte.
    setState(() {
      _autoFinishing = true;
      _attempted = true;
      _showSafetyTap = false;
    });
    PaletteSensoriale.eseguiSchema(SchemaAptico.tocco);
  }

  void _complete() {
    if (_revealed) return;
    _revealed = true;
    _ticker.stop();
    _levelSub?.cancel();
    _breath.stop();
    // La nebbia si dirada e il Maestro appare: e' LA rivelazione, quindi due
      // colpi crescenti e non un colpo medio come una conferma qualunque.
      PaletteSensoriale.eseguiSchema(SchemaAptico.rivelazione);
    setState(() {
      _progress = 1;
      _showCoach = false;
      _showSafetyTap = false;
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    _levelSub?.cancel();
    _breath.dispose();
    super.dispose();
  }

  String get _title => switch (widget.maestro) {
        Maestro.medora => 'Soffia sulla sfera di cristallo',
        Maestro.caligo => 'Soffia per spegnere la candela',
        Maestro.aura => 'Soffia per disperdere il soffione',
      };

  @override
  Widget build(BuildContext context) {
    final palette = MaestroPalette.forKey(ThemeKey.of(widget.maestro));
    final identity = context.read<IdentityController>();
    final chart = context.read<NatalChartController>().chart;
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return GestureDetector(
      onPanUpdate: _onDrag,
      onTapDown: _revealed ? null : (_) => _onDrag(DragUpdateDetails(
            globalPosition: Offset.zero,
            delta: const Offset(9, 0),
          )),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.lg),
        child: Column(
          children: [
            const SizedBox(height: SpacingTokens.md),
            Text(
              _revealed ? 'Il tuo Maestro' : 'La rivelazione',
              style: TypographyTokens.etichetta()
                  .copyWith(color: palette.goldSoft, letterSpacing: 3),
            ),
            const SizedBox(height: SpacingTokens.xs),
            Text(
              _revealed ? widget.maestro.displayName : _title,
              style: TypographyTokens.cerimoniale(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: SpacingTokens.md),
            Expanded(
              child: Center(
                child: AnimatedSwitcher(
                  duration: Duration(milliseconds: reduceMotion ? 0 : 600),
                  child: _revealed
                      ? MaestroCardReveal(
                          key: const ValueKey('card'),
                          maestro: widget.maestro,
                          palette: palette,
                          reduceMotion: reduceMotion,
                        )
                      : _RitualStage(
                          key: const ValueKey('ritual'),
                          maestro: widget.maestro,
                          palette: palette,
                          progress: _progress,
                          level: _reactLevel,
                          showCoach: _showCoach,
                          micAvailable: _micAvailable,
                          reduceMotion: reduceMotion,
                        ),
                ),
              ),
            ),
            const SizedBox(height: SpacingTokens.md),
            if (_revealed)
              _RevealedFooter(
                maestro: widget.maestro,
                palette: palette,
                identity: identity,
                chart: chart,
                onEnter: () => widget.onRevealed(widget.maestro),
              )
            else
              // LA SCELTA RESTA, senza limite di tempo.
              //
              // Qui c'era un `else if (_showSafetyTap)` che SOSTITUIVA questo
              // blocco: dopo qualche secondo l'invito a soffiare spariva e
              // restava il solo "Tocca per svelare". Chi stava ancora
              // decidendo si vedeva togliere una delle due strade sotto gli
              // occhi. Adesso il tocco si AGGIUNGE come aiuto, e il soffio non
              // sparisce finche' la persona non ha deciso.
              Column(
                children: [
                  ParagrafiDiLettura(testo: _micAvailable
                        ? 'Soffia dolcemente, oppure trascina il dito per svelare'
                        : 'Trascina il dito per svelare, come un gratta e vinci', textAlign: TextAlign.center, stile: TypographyTokens.lettura()
                        .copyWith(color: ColorTokens.textPrimary, height: 1.4)),
                  // Il microfono si chiede solo qui, quando l'utente sceglie la
                  // voce, con un pre-avviso in tono. Rifiutare non blocca nulla.
                  if (!_micAvailable && !_micAsked) ...[
                    const SizedBox(height: SpacingTokens.sm),
                    _VoiceInvite(
                        key: const Key('reveal_voice_invite'),
                        palette: palette,
                        onTap: _askMic),
                  ],
                  if (_showSafetyTap) ...[
                    const SizedBox(height: SpacingTokens.sm),
                    _SafetyTapInvite(
                        key: const Key('reveal_safety_tap'),
                        palette: palette,
                        onTap: _finishByTap),
                  ],
                ],
              ),
            const SizedBox(height: SpacingTokens.md),
          ],
        ),
      ),
    );
  }
}

class _RitualStage extends StatelessWidget {
  const _RitualStage({
    super.key,
    required this.maestro,
    required this.palette,
    required this.progress,
    required this.level,
    required this.showCoach,
    required this.micAvailable,
    required this.reduceMotion,
  });

  final Maestro maestro;
  final MaestroPalette palette;
  final double progress;
  final double level;
  final bool showCoach;
  final bool micAvailable;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final side = math.min(constraints.maxHeight, constraints.maxWidth);
      final objectSize = side.clamp(240.0, 320.0);
      return SizedBox.expand(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Atmosfera: alone del Maestro e particelle, cosi' l'oggetto non e'
            // mai un puntino nel nero.
            Positioned.fill(
              child: _Atmosphere(palette: palette, reduceMotion: reduceMotion),
            ),
            RitualObject(
              maestro: maestro,
              palette: palette,
              progress: progress,
              level: level,
              reduceMotion: reduceMotion,
              size: objectSize,
            ),
            // Anello di progresso attorno all'oggetto.
            SizedBox(
              width: objectSize * 1.06,
              height: objectSize * 1.06,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 2.4,
                backgroundColor: palette.gold.withValues(alpha: 0.12),
                valueColor: AlwaysStoppedAnimation(palette.goldSoft),
              ),
            ),
            // Le silhouette guida, grandi e senza sfondo.
            if (showCoach)
              Positioned(
                bottom: 0,
                child: GestureCoach(
                  palette: palette,
                  reduceMotion: reduceMotion,
                  gestures: micAvailable
                      ? const [CoachGesture.blow, CoachGesture.swipe]
                      : const [CoachGesture.swipe],
                ),
              ),
          ],
        ),
      );
    });
  }
}

/// Alone del Maestro e particelle sospese dietro l'oggetto rituale.
class _Atmosphere extends StatefulWidget {
  const _Atmosphere({required this.palette, required this.reduceMotion});
  final MaestroPalette palette;
  final bool reduceMotion;

  @override
  State<_Atmosphere> createState() => _AtmosphereState();
}

class _AtmosphereState extends State<_Atmosphere>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(seconds: 18));
    if (!widget.reduceMotion) _c.repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) => CustomPaint(
        painter: _AtmospherePainter(
            palette: widget.palette,
            t: widget.reduceMotion ? 0.0 : _c.value),
      ),
    );
  }
}

class _AtmospherePainter extends CustomPainter {
  _AtmospherePainter({required this.palette, required this.t});
  final MaestroPalette palette;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    // Grande alone morbido del Maestro.
    canvas.drawCircle(
        c,
        size.shortestSide * 0.55,
        Paint()
          ..shader = RadialGradient(
            colors: [
              palette.glow.withValues(alpha: 0.22),
              palette.primary.withValues(alpha: 0.08),
              Colors.transparent,
            ],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(Rect.fromCircle(
              center: c, radius: size.shortestSide * 0.55)));

    // Particelle sospese che ruotano lente.
    final rng = math.Random(7);
    for (var i = 0; i < 22; i++) {
      final base = rng.nextDouble() * 2 * math.pi;
      final rad = size.shortestSide * (0.20 + rng.nextDouble() * 0.32);
      final a = base + t * 2 * math.pi * (0.2 + rng.nextDouble() * 0.3);
      final p = c + Offset(math.cos(a), math.sin(a) * 0.8) * rad;
      final tw = 0.3 + 0.7 * (0.5 + 0.5 * math.sin(t * 6 + i));
      canvas.drawCircle(
          p,
          0.8 + rng.nextDouble() * 1.6,
          Paint()
            ..color = palette.goldSoft.withValues(alpha: 0.4 * tw)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2));
    }
  }

  @override
  bool shouldRepaint(_AtmospherePainter old) => old.t != t;
}

/// L'invito di sicurezza, sempre toccabile, che completa il rito con un tocco.
class _SafetyTapInvite extends StatelessWidget {
  const _SafetyTapInvite({super.key, required this.palette, required this.onTap});
  final MaestroPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.lg, vertical: SpacingTokens.sm),
        decoration: BoxDecoration(
          color: palette.gold.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
          border: Border.all(color: palette.gold.withValues(alpha: 0.7)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.touch_app, color: palette.goldSoft, size: 24),
            const SizedBox(width: SpacingTokens.xs),
            ParagrafiDiLettura(testo: 'Tocca per svelare', stile: TypographyTokens.lettura(weight: 600)
                    .copyWith(color: palette.goldSoft)),
          ],
        ),
      ),
    );
  }
}

/// Invito, sempre facoltativo, a soffiare con la voce. Al tocco parte il
/// pre-avviso gentile del microfono.
class _VoiceInvite extends StatelessWidget {
  const _VoiceInvite({super.key, required this.palette, required this.onTap});
  final MaestroPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.md, vertical: SpacingTokens.xs),
        decoration: BoxDecoration(
          color: ColorTokens.glassTint,
          borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
          border: Border.all(color: palette.gold.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.mic_none_rounded, color: palette.goldSoft, size: 20),
            const SizedBox(width: 6),
            Text('Soffia con la voce',
                style: TypographyTokens.corpo()
                    .copyWith(color: palette.goldSoft)),
          ],
        ),
      ),
    );
  }
}

class _RevealedFooter extends StatelessWidget {
  const _RevealedFooter({
    required this.maestro,
    required this.palette,
    required this.identity,
    required this.chart,
    required this.onEnter,
  });

  final Maestro maestro;
  final MaestroPalette palette;
  final IdentityController identity;
  final NatalChart? chart;
  final VoidCallback onEnter;

  @override
  Widget build(BuildContext context) {
    final first = chart != null
        ? NatalPoetics.firstMoment(
            chart: chart!, maestro: maestro, identity: identity)
        : null;

    return Column(
      children: [
        // Il Maestro saluta per nome e nella forma scelta.
        Text(
          identity.welcome(),
          textAlign: TextAlign.center,
          style: TypographyTokens.titoloSezione()
              .copyWith(color: palette.goldSoft),
        ),
        const SizedBox(height: SpacingTokens.sm),
        if (first != null)
          Container(
            padding: const EdgeInsets.all(SpacingTokens.md),
            decoration: BoxDecoration(
              color: palette.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
              border: Border.all(color: palette.gold.withValues(alpha: 0.3)),
            ),
            child: ParagrafiDiLettura(testo: first, textAlign: TextAlign.center, stile: TypographyTokens.lettura()
                  .copyWith(color: ColorTokens.textPrimary, height: 1.5)),
          ),
        const SizedBox(height: SpacingTokens.md),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: palette.gold,
              foregroundColor: palette.deepest,
              padding: const EdgeInsets.symmetric(vertical: SpacingTokens.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
              ),
            ),
            onPressed: onEnter,
            child: Text('Entra nel Cerchio',
                style: TypographyTokens.corpo(weight: 600)
                    .copyWith(color: palette.deepest)),
          ),
        ),
      ],
    );
  }
}
