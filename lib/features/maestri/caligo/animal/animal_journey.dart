import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../design_system/components/scroll_reveal.dart';
import '../../../../design_system/theme/maestro_palette.dart';
import '../../../../design_system/tokens/color_tokens.dart';
import '../../../../design_system/tokens/spacing_tokens.dart';
import '../../../../design_system/tokens/typography_tokens.dart';

/// Il viaggio sciamanico prima della rivelazione, fedele al core shamanism di
/// Harner: l'animale di potere non viene detto, lo trovi viaggiando col tamburo.
///
/// L'utente tocca a ritmo il tamburo di Caligo, alone rosso e oro, e a ogni
/// battito la nebbia si apre un poco; dopo pochi battiti si accendono gli occhi
/// dell'animale e il viaggio si conclude, passando alla rivelazione. Piccola
/// fatica prima del dono, mai un gioco difficile. Ripiego sempre presente: con
/// Riduci Movimento basta un tocco solo, e c'e' comunque il tasto per arrivare
/// subito. Deterministico, nessuna AI.
class AnimalJourney extends StatefulWidget {
  const AnimalJourney({
    super.key,
    required this.palette,
    required this.onComplete,
  });

  final MaestroPalette palette;
  final VoidCallback onComplete;

  @override
  State<AnimalJourney> createState() => _AnimalJourneyState();
}

class _AnimalJourneyState extends State<AnimalJourney>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);

  /// Quanti battiti servono. Con Riduci Movimento basta un tocco.
  int _soglia = 6;
  int _battiti = 0;
  bool _fatto = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (ScrollReveal.motionOff(context)) {
      _soglia = 1;
      _pulse.stop();
      _pulse.value = 1.0;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  double get _progresso => (_battiti / _soglia).clamp(0.0, 1.0);

  void _colpisci() {
    if (_fatto) return;
    HapticFeedback.mediumImpact();
    setState(() => _battiti++);
    if (_battiti >= _soglia) _concludi();
  }

  void _concludi() {
    if (_fatto) return;
    _fatto = true;
    // Un attimo perche' gli occhi restino accesi, poi la rivelazione.
    Future<void>.delayed(const Duration(milliseconds: 350), () {
      if (mounted) widget.onComplete();
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    return Padding(
      key: const Key('animal_journey'),
      padding: const EdgeInsets.all(SpacingTokens.lg),
      child: Column(
        children: [
          const SizedBox(height: SpacingTokens.sm),
          Text('Tocca il tamburo a ritmo per chiamare il tuo animale dalla nebbia.',
              key: const Key('animal_journey_guide'),
              textAlign: TextAlign.center,
              style: TypographyTokens.body(size: 16)
                  .copyWith(color: ColorTokens.textPrimary, height: 1.5)),
          const SizedBox(height: SpacingTokens.lg),
          Expanded(
            child: Center(
              child: GestureDetector(
                key: const Key('animal_drum'),
                onTap: _colpisci,
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  width: 300,
                  height: 300,
                  child: AnimatedBuilder(
                    animation: _pulse,
                    builder: (context, _) => CustomPaint(
                      painter: _TamburoPainter(
                        palette: palette,
                        pulsazione: _pulse.value,
                        progresso: _progresso,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: SpacingTokens.lg),
          // I battiti, in pallini che si accendono a ogni tocco.
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < _soglia; i++) ...[
                if (i > 0) const SizedBox(width: SpacingTokens.xs),
                Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i < _battiti
                        ? palette.goldSoft
                        : palette.gold.withValues(alpha: 0.2),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: SpacingTokens.sm),
          TextButton(
            key: const Key('animal_journey_skip'),
            onPressed: _concludi,
            child: Text('Portami all\'animale',
                style: TypographyTokens.label(size: 12)
                    .copyWith(color: palette.goldSoft)),
          ),
        ],
      ),
    );
  }
}

/// Il tamburo di Caligo con l'alone rosso e oro che pulsa, e la nebbia intorno
/// che si apre col progredire del viaggio, gli occhi che si accendono in cima.
class _TamburoPainter extends CustomPainter {
  _TamburoPainter({
    required this.palette,
    required this.pulsazione,
    required this.progresso,
  });

  final MaestroPalette palette;
  final double pulsazione;
  final double progresso;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.shortestSide * 0.34;

    // Alone caldo che respira, rosso e oro.
    final alone = 0.85 + 0.15 * pulsazione;
    canvas.drawCircle(
      c,
      r * 1.7 * alone,
      Paint()
        ..shader = RadialGradient(colors: [
          palette.gold.withValues(alpha: 0.35 * pulsazione),
          palette.primary.withValues(alpha: 0.0),
        ]).createShader(Rect.fromCircle(center: c, radius: r * 1.7 * alone)),
    );

    // La pelle del tamburo.
    canvas.drawCircle(
        c,
        r,
        Paint()
          ..shader = RadialGradient(colors: [
            palette.surfaceElevated,
            palette.deepest,
          ]).createShader(Rect.fromCircle(center: c, radius: r)));
    // Il cerchio d'oro del bordo.
    canvas.drawCircle(
        c,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..color = palette.gold.withValues(alpha: 0.85));
    // I tiranti a raggiera, incisi.
    final tirante = Paint()
      ..strokeWidth = 2
      ..color = palette.gold.withValues(alpha: 0.5);
    for (var i = 0; i < 8; i++) {
      final a = i * math.pi / 4;
      canvas.drawLine(c + Offset(math.cos(a), math.sin(a)) * (r * 0.35),
          c + Offset(math.cos(a), math.sin(a)) * r, tirante);
    }
    // Il centro, un sole inciso.
    canvas.drawCircle(c, r * 0.16,
        Paint()..color = palette.gold.withValues(alpha: 0.7 + 0.3 * pulsazione));

    // Gli occhi dell'animale che affiorano in cima col progredire del viaggio.
    if (progresso > 0.01) {
      final cy = c.dy - r * 1.9;
      final dx = size.width * 0.09;
      for (final segno in [-1, 1]) {
        final centro = Offset(c.dx + segno * dx, cy);
        canvas.drawCircle(
            centro,
            10,
            Paint()
              ..color = palette.gold.withValues(alpha: 0.5 * progresso)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
        canvas.drawCircle(centro, 3.2,
            Paint()..color = palette.goldSoft.withValues(alpha: progresso));
      }
    }
  }

  @override
  bool shouldRepaint(_TamburoPainter old) =>
      old.pulsazione != pulsazione || old.progresso != progresso;
}
