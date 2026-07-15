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

/// Oracolo del Giorno, dominio Medora.
///
/// La rivelazione arriva al giroscopio sul device, inclinando il telefono; qui,
/// e sempre, il ripiego universale e' lo scorrimento del dito. L'oracolo e'
/// deterministico dal giorno.
class DayOracleScreen extends StatelessWidget {
  const DayOracleScreen({super.key, this.now});

  final DateTime? now;

  static Route<void> route({DateTime? now}) => MaterialPageRoute<void>(
        builder: (_) => MaestroScope(child: DayOracleScreen(now: now)),
      );

  @override
  Widget build(BuildContext context) {
    final date = now ?? DateTime.now();
    final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.medora));
    final oracle = DailyRituals.dayOracle(date);

    return RitualView(
      title: 'Oracolo del Giorno',
      palette: palette,
      // Slot del fondale condiviso: qui si cabla il PNG dell'oracolo quando
      // arrivera'. Per ora null, fondo procedurale coerente col cosmo.
      backgroundAsset: null,
      gesture: RitualGesture.swipe,
      prompt: 'Inclina o scorri per rivelare',
      sensorHint:
          'Inclina il telefono, oppure scorri col dito: il ripiego tattile vale sempre.',
      visualBuilder: (context, revealed, t) => CustomPaint(
        painter: _OraclePainter(palette: palette, t: t, revealed: revealed),
      ),
      revealed: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Il cielo di oggi dice',
              style: TypographyTokens.display(size: 18)
                  .copyWith(color: palette.goldSoft)),
          const SizedBox(height: SpacingTokens.sm),
          Text(oracle,
              style: TypographyTokens.body(size: 16)
                  .copyWith(color: ColorTokens.textPrimary, height: 1.5)),
        ],
      ),
    );
  }
}

class _OraclePainter extends CustomPainter {
  _OraclePainter(
      {required this.palette, required this.t, required this.revealed});

  final MaestroPalette palette;
  final double t;
  final bool revealed;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.shortestSide * 0.34;

    // Disco celeste, un velo che si dirada rivelando la luce.
    canvas.drawCircle(
      center,
      r * 1.6,
      Paint()
        ..shader = RadialGradient(colors: [
          palette.glow.withValues(alpha: revealed ? 0.45 : 0.2),
          Colors.transparent,
        ]).createShader(Rect.fromCircle(center: center, radius: r * 1.6)),
    );

    // Anelli concentrici, come una carta del cielo.
    for (var k = 1; k <= 4; k++) {
      canvas.drawCircle(
        center,
        r * k / 4,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8
          ..color = palette.gold.withValues(alpha: 0.18),
      );
    }

    // Dodici raggi con piccole stelle sui vertici.
    for (var i = 0; i < 12; i++) {
      final a = 2 * math.pi * i / 12 - math.pi / 2 + t * 0.2;
      final dir = Offset(math.cos(a), math.sin(a));
      canvas.drawLine(
        center + dir * r * 0.2,
        center + dir * r,
        Paint()
          ..strokeWidth = 0.8
          ..color = palette.gold.withValues(alpha: revealed ? 0.4 : 0.16),
      );
      canvas.drawCircle(center + dir * r, revealed ? 2.4 : 1.4,
          Paint()..color = Colors.white.withValues(alpha: revealed ? 0.9 : 0.4));
    }

    // Cuore luminoso, piu' acceso da rivelato.
    canvas.drawCircle(
      center,
      r * 0.18,
      Paint()
        ..shader = RadialGradient(colors: [
          Colors.white.withValues(alpha: revealed ? 0.95 : 0.5),
          palette.goldSoft.withValues(alpha: 0.0),
        ]).createShader(Rect.fromCircle(center: center, radius: r * 0.4)),
    );
  }

  @override
  bool shouldRepaint(_OraclePainter old) =>
      old.t != t || old.revealed != revealed || old.palette != palette;
}
