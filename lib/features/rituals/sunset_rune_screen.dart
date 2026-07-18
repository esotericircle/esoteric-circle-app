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
      // Slot del fondale condiviso: qui si cabla il PNG del tramonto quando
      // arrivera'. Per ora null, fondo procedurale coerente col cosmo.
      backgroundAsset: null,
      gesture: RitualGesture.shake,
      prompt: 'Scuoti per svelare la runa',
      sensorHint:
          'Scuoti il telefono, oppure tocca: il ripiego tattile vale sempre.',
      visualBuilder: (context, revealed, t) => Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _SunsetPainter(palette: palette, t: t, revealed: revealed),
            ),
          ),
          if (revealed)
            // Svelata, la runa mostra l'arte incisa reale della sua pietra
            // (famiglia rune_bone, misura piena perche' e' a fuoco). Se l'arte
            // manca o non carica, ripiega sul glifo disegnato a tratti, sempre
            // leggibile senza dipendere dal blocco Unicode.
            SizedBox(
              key: const Key('rune_glyph'),
              width: 220,
              height: 260,
              child: rune.hasImage
                  ? Image.asset(
                      rune.fullPath!,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => CustomPaint(
                        painter: RunePainter(
                          runeName: rune.name,
                          color: Colors.white,
                          glow: palette.goldSoft,
                          intensity: 1.0,
                        ),
                      ),
                    )
                  : CustomPaint(
                      painter: RunePainter(
                        runeName: rune.name,
                        color: Colors.white,
                        glow: palette.goldSoft,
                        intensity: 1.0,
                      ),
                    ),
            )
          else
            // Stato chiuso: una pietra runica velata con un bagliore, non un
            // rettangolo nudo. Il segno resta nascosto fino allo scuotimento.
            SizedBox(
              width: 200,
              height: 240,
              child: CustomPaint(
                key: const Key('rune_stone'),
                painter: _RuneStonePainter(palette: palette, t: t),
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

/// La pietra runica velata dello stato chiuso: un monolite verticale con un
/// bagliore che respira e un sigillo coperto al centro, mai un rettangolo nudo.
class _RuneStonePainter extends CustomPainter {
  _RuneStonePainter({required this.palette, required this.t});

  final MaestroPalette palette;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final w = size.width * 0.62;
    final h = size.height * 0.9;
    final rect = Rect.fromCenter(center: center, width: w, height: h);
    final rrect = RRect.fromRectAndCorners(
      rect,
      topLeft: Radius.circular(w * 0.5),
      topRight: Radius.circular(w * 0.5),
      bottomLeft: const Radius.circular(14),
      bottomRight: const Radius.circular(14),
    );

    // Bagliore che respira attorno alla pietra.
    final glow = 0.25 + 0.15 * math.sin(t * math.pi);
    canvas.drawRRect(
      rrect.inflate(18),
      Paint()
        ..color = palette.goldSoft.withValues(alpha: glow)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 26),
    );

    // Corpo della pietra, gradiente di roccia scura.
    canvas.drawRRect(
      rrect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            palette.surfaceElevated,
            palette.deepest,
          ],
        ).createShader(rect),
    );
    // Bordo inciso.
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = palette.gold.withValues(alpha: 0.6),
    );

    // Il velo: una fascia diagonale traslucida che copre il segno.
    canvas.save();
    canvas.clipRRect(rrect);
    final veil = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    for (var i = -2; i <= 3; i++) {
      final dx = i * w * 0.4 + (t - 0.5) * 10;
      canvas.drawLine(Offset(rect.left + dx, rect.top),
          Offset(rect.left + dx + w, rect.bottom), veil..strokeWidth = 10);
    }
    canvas.restore();

    // Sigillo coperto al centro: un cerchio con una barra, il segno sotto il
    // velo, appena intuibile.
    final sealR = w * 0.24;
    canvas.drawCircle(
      center,
      sealR,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = palette.goldSoft.withValues(alpha: 0.5),
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - sealR * 0.7),
      Offset(center.dx, center.dy + sealR * 0.7),
      Paint()
        ..strokeWidth = 1.4
        ..strokeCap = StrokeCap.round
        ..color = palette.goldSoft.withValues(alpha: 0.45),
    );

    // Due chiodi d'oro in alto, come una pietra sigillata.
    for (final sx in [-1.0, 1.0]) {
      canvas.drawCircle(
        Offset(center.dx + sx * w * 0.28, rect.top + h * 0.14),
        3,
        Paint()..color = palette.gold.withValues(alpha: 0.7),
      );
    }
  }

  @override
  bool shouldRepaint(_RuneStonePainter old) =>
      old.t != t || old.palette != palette;
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
