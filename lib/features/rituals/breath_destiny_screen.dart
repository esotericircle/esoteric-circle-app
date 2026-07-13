import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/maestro/maestro.dart';
import '../../core/rituals/daily_rituals.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import 'ritual_view.dart';

/// Soffio del Destino, dominio Aura.
///
/// Il microfono coglie il soffio sul device; qui, e sempre, il ripiego tattile
/// universale e' tenere premuto. Il frammento del destino e' deterministico dal
/// giorno.
class BreathDestinyScreen extends StatelessWidget {
  const BreathDestinyScreen({super.key, this.now});

  final DateTime? now;

  static Route<void> route({DateTime? now}) => MaterialPageRoute<void>(
        builder: (_) => MaestroScope(child: BreathDestinyScreen(now: now)),
      );

  @override
  Widget build(BuildContext context) {
    final date = now ?? DateTime.now();
    final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.aura));
    final fragment = DailyRituals.destinyFragment(date);

    return RitualView(
      title: 'Soffio del Destino',
      palette: palette,
      gesture: RitualGesture.hold,
      prompt: 'Tieni premuto e soffia',
      sensorHint:
          'Soffia nel microfono, oppure tieni premuto: il ripiego tattile vale sempre.',
      footnote:
          'Il microfono si attiva sul device. Qui il gesto tattile compie il rito.',
      visualBuilder: (context, revealed, t) => CustomPaint(
        painter: _BreathPainter(palette: palette, t: t, revealed: revealed),
      ),
      revealed: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Il tuo soffio parla',
              style: TypographyTokens.display(size: 18)
                  .copyWith(color: palette.goldSoft)),
          const SizedBox(height: SpacingTokens.sm),
          Text(fragment,
              style: TypographyTokens.body(size: 16)
                  .copyWith(color: ColorTokens.textPrimary, height: 1.5)),
        ],
      ),
    );
  }
}

class _BreathPainter extends CustomPainter {
  _BreathPainter(
      {required this.palette, required this.t, required this.revealed});

  final MaestroPalette palette;
  final double t;
  final bool revealed;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final base = size.shortestSide * (revealed ? 0.34 : 0.24);
    final r = base * (0.9 + 0.12 * math.sin(t * math.pi));

    canvas.drawCircle(
      center,
      r * 2.2,
      Paint()
        ..shader = RadialGradient(colors: [
          palette.glow.withValues(alpha: revealed ? 0.4 : 0.22),
          Colors.transparent,
        ]).createShader(Rect.fromCircle(center: center, radius: r * 2.2)),
    );

    // Particelle di respiro che salgono, piu' vive dopo il soffio.
    final rng = math.Random(21);
    final count = revealed ? 60 : 34;
    for (var i = 0; i < count; i++) {
      final a = rng.nextDouble() * 2 * math.pi;
      final dist = r * (0.6 + rng.nextDouble() * 1.4);
      final drift = (t + rng.nextDouble()) % 1.0;
      final p = center +
          Offset(math.cos(a), math.sin(a) - drift * 0.6) * dist;
      canvas.drawCircle(
        p,
        rng.nextDouble() * 2.0 + 0.6,
        Paint()
          ..color = palette.goldSoft
              .withValues(alpha: (0.5 * (1 - drift)).clamp(0.0, 0.6)),
      );
    }

    canvas.drawCircle(
      center,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = palette.gold.withValues(alpha: 0.6),
    );
  }

  @override
  bool shouldRepaint(_BreathPainter old) =>
      old.t != t || old.revealed != revealed || old.palette != palette;
}
