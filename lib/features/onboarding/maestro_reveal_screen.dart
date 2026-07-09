import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/astro/natal_chart.dart';
import '../../core/astro/natal_chart_controller.dart';
import '../../core/astro/natal_poetics.dart';
import '../../core/identity/identity_controller.dart';
import '../../core/maestro/maestro.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../services/breath_detector.dart';
import 'widgets/maestro_card.dart';
import 'widgets/ritual_object.dart';

/// Rivelazione del Maestro col rito del soffio.
///
/// Il Maestro assegnato si svela soffiando sull'oggetto rituale vivo (sfera di
/// cristallo per Medora, candela per Caligo, soffione per Aura): il microfono
/// misura il soffio con una soglia, ma c'e' sempre il fallback tattile (si
/// trascina il dito, in stile gratta e vinci). Dopo tre secondi compare un
/// tutorial visivo. Al termine il Maestro entra in scena in modo cinematografico.
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

class _MaestroRevealScreenState extends State<MaestroRevealScreen> {
  final BreathDetector _breath = BreathDetector();
  StreamSubscription<double>? _levelSub;
  Timer? _tick;
  Timer? _tutorialTimer;

  double _progress = 0;
  double _micLevel = 0;
  double _dragPulse = 0;
  bool _micAvailable = false;
  bool _showTutorial = false;
  bool _revealed = false;
  int _idle = 0;

  static const _blowThreshold = 0.12;

  double get _reactLevel => math.max(_micLevel, _dragPulse);

  @override
  void initState() {
    super.initState();
    _startMic();
    _tick = Timer.periodic(const Duration(milliseconds: 60), _onTick);
    _tutorialTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && !_revealed) setState(() => _showTutorial = true);
    });
  }

  Future<void> _startMic() async {
    final ok = await _breath.start();
    if (!mounted) return;
    setState(() => _micAvailable = ok);
    if (ok) _levelSub = _breath.level.listen((l) => _micLevel = l);
  }

  void _onTick(Timer _) {
    if (_revealed) return;
    final blowing = _micAvailable && _micLevel > _blowThreshold;
    setState(() {
      _dragPulse *= 0.85;
      if (blowing) {
        _progress = (_progress + 0.05).clamp(0.0, 1.0);
        _idle = 0;
      } else {
        _idle++;
        if (_idle > 8) _progress = (_progress - 0.01).clamp(0.0, 1.0);
      }
    });
    if (_progress >= 1.0) _complete();
  }

  void _onDrag(DragUpdateDetails d) {
    if (_revealed) return;
    setState(() {
      _progress = (_progress + d.delta.distance / 1400).clamp(0.0, 1.0);
      _dragPulse = 1;
      _idle = 0;
    });
    if (_progress >= 1.0) _complete();
  }

  void _complete() {
    if (_revealed) return;
    _revealed = true;
    _tick?.cancel();
    _tutorialTimer?.cancel();
    _levelSub?.cancel();
    _breath.stop();
    HapticFeedback.mediumImpact(); // la nebbia si dirada, il Maestro appare
    setState(() {
      _progress = 1;
      _showTutorial = false;
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    _tutorialTimer?.cancel();
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

    return GestureDetector(
      onPanUpdate: _onDrag,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.lg),
        child: Column(
          children: [
            const SizedBox(height: SpacingTokens.md),
            Text(
              _revealed ? 'Il tuo Maestro' : 'La rivelazione',
              style: TypographyTokens.body(size: 12)
                  .copyWith(color: palette.goldSoft, letterSpacing: 3),
            ),
            const SizedBox(height: SpacingTokens.xs),
            Text(
              _revealed ? widget.maestro.displayName : _title,
              style: TypographyTokens.display(size: 26),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: SpacingTokens.lg),
            Expanded(
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 600),
                  child: _revealed
                      ? MaestroCardReveal(
                          key: const ValueKey('card'),
                          maestro: widget.maestro,
                          palette: palette,
                        )
                      : _RitualStage(
                          key: const ValueKey('ritual'),
                          maestro: widget.maestro,
                          palette: palette,
                          progress: _progress,
                          level: _reactLevel,
                          showTutorial: _showTutorial,
                          micAvailable: _micAvailable,
                        ),
                ),
              ),
            ),
            const SizedBox(height: SpacingTokens.lg),
            if (_revealed)
              _RevealedFooter(
                maestro: widget.maestro,
                palette: palette,
                identity: identity,
                chart: chart,
                onEnter: () => widget.onRevealed(widget.maestro),
              )
            else
              Text(
                _micAvailable
                    ? 'Soffia dolcemente, oppure trascina il dito per svelare'
                    : 'Trascina il dito per svelare, come un gratta e vinci',
                textAlign: TextAlign.center,
                style: TypographyTokens.body(size: 13)
                    .copyWith(color: ColorTokens.textSecondary),
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
    required this.showTutorial,
    required this.micAvailable,
  });

  final Maestro maestro;
  final MaestroPalette palette;
  final double progress;
  final double level;
  final bool showTutorial;
  final bool micAvailable;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 340,
      child: Stack(
        alignment: Alignment.center,
        children: [
          RitualObject(
            maestro: maestro,
            palette: palette,
            progress: progress,
            level: level,
            size: 210,
          ),
          // Anello di progresso attorno all'oggetto.
          SizedBox(
            width: 240,
            height: 240,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 2,
              backgroundColor: palette.gold.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation(palette.goldSoft),
            ),
          ),
          if (showTutorial)
            Positioned(
              bottom: 4,
              child: _Tutorial(micAvailable: micAvailable, palette: palette),
            ),
        ],
      ),
    );
  }
}

class _Tutorial extends StatelessWidget {
  const _Tutorial({required this.micAvailable, required this.palette});
  final bool micAvailable;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.md,
        vertical: SpacingTokens.xs,
      ),
      decoration: BoxDecoration(
        color: palette.deepest.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
        border: Border.all(color: palette.gold.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            micAvailable ? Icons.face_retouching_natural : Icons.touch_app,
            color: palette.goldSoft,
            size: 20,
          ),
          const SizedBox(width: 6),
          Icon(micAvailable ? Icons.air : Icons.gesture,
              color: palette.goldSoft, size: 18),
          const SizedBox(width: SpacingTokens.xs),
          Text(
            micAvailable ? 'Soffia qui' : 'Trascina qui',
            style: TypographyTokens.body(size: 13)
                .copyWith(color: ColorTokens.textPrimary),
          ),
        ],
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
          style: TypographyTokens.display(size: 18)
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
            child: Text(
              first,
              textAlign: TextAlign.center,
              style: TypographyTokens.body(size: 14)
                  .copyWith(color: ColorTokens.textPrimary, height: 1.45),
            ),
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
            child: Text('Entra nel Santuario',
                style: TypographyTokens.body(size: 15, weight: 600)
                    .copyWith(color: palette.deepest)),
          ),
        ),
      ],
    );
  }
}
