import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/maestro/maestro.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../services/breath_detector.dart';

/// Rivelazione del Maestro col rito del soffio.
///
/// Il Maestro assegnato si svela soffiando sull'oggetto rituale: il microfono
/// misura il soffio con una soglia, ma c'e' sempre il fallback tattile (si
/// trascina il dito per svelare, in stile gratta e vinci). Dopo tre secondi
/// compare un tutorial visivo: la silhouette del viso che soffia, oppure, in
/// fallback, la silhouette del dito che cancella.
class MaestroRevealScreen extends StatefulWidget {
  const MaestroRevealScreen({
    super.key,
    required this.maestro,
    required this.onRevealed,
  });

  final Maestro maestro;

  /// Chiamato quando il rito e' compiuto (il Maestro e' svelato).
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
  bool _micAvailable = false;
  bool _showTutorial = false;
  bool _revealed = false;
  int _idle = 0;

  static const _blowThreshold = 0.12;

  @override
  void initState() {
    super.initState();
    _startMic();
    _tick = Timer.periodic(const Duration(milliseconds: 60), _onTick);
    // Dopo tre secondi compare il tutorial visivo.
    _tutorialTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && !_revealed) setState(() => _showTutorial = true);
    });
  }

  Future<void> _startMic() async {
    final ok = await _breath.start();
    if (!mounted) return;
    setState(() => _micAvailable = ok);
    if (ok) {
      _levelSub = _breath.level.listen((l) => _micLevel = l);
    }
  }

  void _onTick(Timer _) {
    if (_revealed) return;
    final blowing = _micAvailable && _micLevel > _blowThreshold;
    setState(() {
      if (blowing) {
        _progress = (_progress + 0.05).clamp(0.0, 1.0);
        _idle = 0;
      } else {
        _idle++;
        if (_idle > 8) {
          _progress = (_progress - 0.01).clamp(0.0, 1.0);
        }
      }
    });
    if (_progress >= 1.0) _complete();
  }

  void _onDrag(DragUpdateDetails d) {
    if (_revealed) return;
    setState(() {
      _progress = (_progress + d.delta.distance / 1400).clamp(0.0, 1.0);
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

  @override
  Widget build(BuildContext context) {
    // La palette e' quella del Maestro assegnato (impostata dal flusso), cosi'
    // la scena e' gia' nel suo colore.
    final palette = MaestroPalette.forKey(ThemeKey.of(widget.maestro));

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
              style: TypographyTokens.body(size: 12).copyWith(
                color: palette.goldSoft,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: SpacingTokens.xs),
            Text(
              _revealed ? widget.maestro.displayName : _ritual.title,
              style: TypographyTokens.display(size: 28),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: SpacingTokens.xl),
            Expanded(
              child: Center(
                child: _RevealStage(
                  maestro: widget.maestro,
                  palette: palette,
                  progress: _progress,
                  ritual: _ritual,
                  showTutorial: _showTutorial,
                  micAvailable: _micAvailable,
                ),
              ),
            ),
            const SizedBox(height: SpacingTokens.lg),
            if (_revealed)
              _RevealedFooter(
                maestro: widget.maestro,
                palette: palette,
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

  _RitualObject get _ritual => switch (widget.maestro) {
        Maestro.medora => const _RitualObject(
            title: 'Soffia sulla sfera di cristallo',
            icon: Icons.blur_on,
          ),
        Maestro.caligo => const _RitualObject(
            title: 'Soffia per spegnere la candela',
            icon: Icons.local_fire_department,
          ),
        Maestro.aura => const _RitualObject(
            title: 'Soffia per disperdere il soffione',
            icon: Icons.spa,
          ),
      };
}

class _RitualObject {
  const _RitualObject({required this.title, required this.icon});
  final String title;
  final IconData icon;
}

class _RevealStage extends StatelessWidget {
  const _RevealStage({
    required this.maestro,
    required this.palette,
    required this.progress,
    required this.ritual,
    required this.showTutorial,
    required this.micAvailable,
  });

  final Maestro maestro;
  final MaestroPalette palette;
  final double progress;
  final _RitualObject ritual;
  final bool showTutorial;
  final bool micAvailable;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 360,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Aura pulsante dietro.
          Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  palette.glow.withValues(alpha: 0.12 + 0.2 * progress),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          // Il Maestro che affiora man mano.
          Opacity(
            opacity: progress,
            child: Image.asset(
              maestro.avatarAsset,
              height: 340,
              fit: BoxFit.contain,
              alignment: Alignment.bottomCenter,
              errorBuilder: (_, __, ___) => Icon(maestro.icon,
                  size: 120, color: palette.goldSoft),
            ),
          ),
          // Il velo con l'oggetto rituale, che si dissolve col progresso.
          Opacity(
            opacity: (1 - progress).clamp(0.0, 1.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 150,
                  height: 150,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        palette.surfaceElevated.withValues(alpha: 0.9),
                        palette.deepest.withValues(alpha: 0.7),
                      ],
                    ),
                    border: Border.all(
                        color: palette.gold.withValues(alpha: 0.5)),
                  ),
                  child: Icon(ritual.icon,
                      size: 60, color: palette.goldSoft),
                ),
              ],
            ),
          ),
          // Anello di progresso.
          SizedBox(
            width: 170,
            height: 170,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 2.5,
              backgroundColor: palette.gold.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation(palette.goldSoft),
            ),
          ),
          // Tutorial visivo dopo tre secondi.
          if (showTutorial)
            Positioned(
              bottom: 0,
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
    // Silhouette del viso che soffia, oppure del dito che cancella.
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
            style: TypographyTokens.body(size: 13).copyWith(
              color: ColorTokens.textPrimary,
            ),
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
    required this.onEnter,
  });

  final Maestro maestro;
  final MaestroPalette palette;
  final VoidCallback onEnter;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Ti guidera\' nel cerchio: ${maestro.domainTitle}.',
          textAlign: TextAlign.center,
          style: TypographyTokens.body(size: 14)
              .copyWith(color: ColorTokens.textSecondary),
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
