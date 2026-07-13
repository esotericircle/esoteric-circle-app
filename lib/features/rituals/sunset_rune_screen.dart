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
import 'rune_strokes.dart';

/// La Runa del Tramonto, dominio Caligo.
///
/// Estrazione di una runa dell'Elder Futhark, deterministica dal giorno, con il
/// suo significato reale. Il glifo runico e' testo Unicode, non un asset: qui e'
/// gia' quello vero. Gesto tattile per estrarla.
class SunsetRuneScreen extends StatelessWidget {
  const SunsetRuneScreen({super.key, this.now});

  final DateTime? now;

  static Route<void> route({DateTime? now}) => MaterialPageRoute<void>(
        builder: (_) => MaestroScope(child: SunsetRuneScreen(now: now)),
      );

  @override
  Widget build(BuildContext context) {
    final date = now ?? DateTime.now();
    final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.caligo));
    final rune = DailyRituals.sunsetRune(date);

    return RitualView(
      title: 'La Runa del Tramonto',
      palette: palette,
      gesture: RitualGesture.tap,
      prompt: 'Tocca per estrarre la runa',
      sensorHint: 'Un gesto solo: tocca per estrarre la runa del giorno.',
      footnote:
          'Arte incisa di brand in arrivo dal bucket: qui il glifo runico è testo vero.',
      visualBuilder: (context, revealed, t) => Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _SunsetPainter(palette: palette, t: t, revealed: revealed),
            ),
          ),
          // Il glifo runico disegnato a tratti, non un carattere di font: cosi'
          // e' sempre leggibile, senza dipendere dal blocco runico Unicode.
          SizedBox(
            width: 180,
            height: 180,
            child: CustomPaint(
              key: const Key('rune_glyph'),
              painter: RunePainter(
                runeName: rune.name,
                color: Colors.white,
                glow: palette.goldSoft,
                intensity: revealed ? 1.0 : 0.35,
              ),
            ),
          ),
        ],
      ),
      revealed: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(rune.name,
                  style: TypographyTokens.display(size: 22)
                      .copyWith(color: palette.goldSoft)),
              const SizedBox(width: SpacingTokens.sm),
              Text(rune.keyword,
                  style: TypographyTokens.label(size: 12).copyWith(
                    color: ColorTokens.textSecondary,
                    letterSpacing: 1.2,
                  )),
            ],
          ),
          const SizedBox(height: SpacingTokens.sm),
          Text(rune.meaning,
              style: TypographyTokens.body(size: 16)
                  .copyWith(color: ColorTokens.textPrimary, height: 1.5)),
        ],
      ),
    );
  }
}

class _SunsetPainter extends CustomPainter {
  _SunsetPainter(
      {required this.palette, required this.t, required this.revealed});

  final MaestroPalette palette;
  final double t;
  final bool revealed;

  @override
  void paint(Canvas canvas, Size size) {
    // Cielo del tramonto: rosso e oro di Caligo che sprofonda nel buio.
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            palette.deepest,
            palette.primary.withValues(alpha: 0.6),
            palette.gold.withValues(alpha: 0.4),
          ],
        ).createShader(Offset.zero & size),
    );

    // Sole basso al tramonto, dietro il glifo.
    final horizon = size.height * 0.7;
    final sunC = Offset(size.width / 2, horizon);
    canvas.drawCircle(
      sunC,
      size.width * 0.42,
      Paint()
        ..shader = RadialGradient(colors: [
          palette.gold.withValues(alpha: revealed ? 0.35 : 0.2),
          Colors.transparent,
        ]).createShader(
            Rect.fromCircle(center: sunC, radius: size.width * 0.42)),
    );

    canvas.drawLine(
      Offset(0, horizon),
      Offset(size.width, horizon),
      Paint()
        ..strokeWidth = 1.0
        ..color = palette.gold.withValues(alpha: 0.4),
    );

    // Scintille che salgono dal fuoco, appena percepibili.
    final rng = math.Random(13);
    for (var i = 0; i < 24; i++) {
      final x = rng.nextDouble() * size.width;
      final drift = (t + rng.nextDouble()) % 1.0;
      final y = horizon - drift * size.height * 0.4;
      canvas.drawCircle(Offset(x, y), rng.nextDouble() * 1.4 + 0.3,
          Paint()..color = palette.goldSoft.withValues(alpha: 0.4 * (1 - drift)));
    }
  }

  @override
  bool shouldRepaint(_SunsetPainter old) =>
      old.t != t || old.revealed != revealed || old.palette != palette;
}
