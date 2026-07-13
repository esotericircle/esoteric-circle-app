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

/// Rito dell'Alba: a rotazione tra i tre Maestri di giorno in giorno.
///
/// Contenuto deterministico dalla data: il Maestro di turno e il suo messaggio
/// del mattino. Livello visivo, un'alba, prima del testo. Gesto tattile
/// universale per riceverlo.
class DawnRiteScreen extends StatelessWidget {
  const DawnRiteScreen({super.key, this.now});

  final DateTime? now;

  static Route<void> route({DateTime? now}) => MaterialPageRoute<void>(
        builder: (_) => MaestroScope(child: DawnRiteScreen(now: now)),
      );

  @override
  Widget build(BuildContext context) {
    final date = now ?? DateTime.now();
    final maestro = DailyRituals.dawnMaestro(date);
    final palette = MaestroPalette.forKey(ThemeKey.of(maestro));
    final message = DailyRituals.dawnMessage(date);

    return RitualView(
      title: 'Rito dell\'Alba',
      palette: palette,
      gesture: RitualGesture.tap,
      prompt: 'Tocca per ricevere il rito',
      sensorHint: 'Un gesto solo: tocca la scena per accogliere l\'alba.',
      footnote:
          'Arte dei Maestri in arrivo dal bucket: qui il segno resta essenziale.',
      visualBuilder: (context, revealed, t) => CustomPaint(
        painter: _DawnPainter(palette: palette, t: t, revealed: revealed),
      ),
      revealed: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('L\'alba di ${maestro.displayName}',
              style: TypographyTokens.display(size: 18)
                  .copyWith(color: palette.goldSoft)),
          const SizedBox(height: SpacingTokens.sm),
          Text(message,
              style: TypographyTokens.body(size: 16)
                  .copyWith(color: ColorTokens.textPrimary, height: 1.5)),
        ],
      ),
    );
  }
}

class _DawnPainter extends CustomPainter {
  _DawnPainter({required this.palette, required this.t, required this.revealed});

  final MaestroPalette palette;
  final double t;
  final bool revealed;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    // Cielo dell'alba: dal profondo del Maestro all'oro caldo sull'orizzonte.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = _sky(size, [
          palette.deepest,
          palette.primary.withValues(alpha: 0.7),
          palette.gold.withValues(alpha: 0.5),
        ]),
    );

    // Il sole che sorge, piu' alto e luminoso dopo il rito.
    final horizon = size.height * 0.78;
    final rise = revealed ? 0.16 : 0.06;
    final sunY = horizon - size.height * (rise + 0.02 * math.sin(t * math.pi));
    final sunC = Offset(size.width / 2, sunY);
    final sunR = size.width * 0.14;
    canvas.drawCircle(
      sunC,
      sunR * 2.6,
      Paint()
        ..shader = _glow(sunC, sunR * 2.6, [
          palette.goldSoft.withValues(alpha: revealed ? 0.5 : 0.28),
          const Color(0x00000000),
        ]),
    );
    canvas.drawCircle(
        sunC, sunR, Paint()..color = palette.goldSoft.withValues(alpha: 0.9));

    // Riga d'orizzonte dorata.
    canvas.drawLine(
      Offset(0, horizon),
      Offset(size.width, horizon),
      Paint()
        ..strokeWidth = 1.2
        ..color = palette.gold.withValues(alpha: 0.5),
    );

    // Qualche stella che si spegne in alto.
    final rng = math.Random(7);
    for (var i = 0; i < 40; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * horizon * 0.7;
      canvas.drawCircle(Offset(x, y), rng.nextDouble() * 1.2 + 0.3,
          Paint()..color = Colors.white.withValues(alpha: 0.35 * (1 - t)));
    }
  }

  Shader _sky(Size size, List<Color> colors) => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: colors,
      ).createShader(Offset.zero & size);

  Shader _glow(Offset c, double r, List<Color> colors) =>
      RadialGradient(colors: colors)
          .createShader(Rect.fromCircle(center: c, radius: r));

  @override
  bool shouldRepaint(_DawnPainter old) =>
      old.t != t || old.revealed != revealed || old.palette != palette;
}
