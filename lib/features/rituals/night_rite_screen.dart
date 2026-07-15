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

/// Rito della Buonanotte: a rotazione tra i tre Maestri di giorno in giorno,
/// come il Rito dell'Alba.
///
/// Due minuti di rilascio a fine giornata. Contenuto deterministico dalla data:
/// il Maestro di turno e la sua parola calmante. Livello visivo, un cielo
/// notturno che si acquieta, prima del testo. Gesto tattile universale per
/// lasciare andare il giorno.
class NightRiteScreen extends StatelessWidget {
  const NightRiteScreen({super.key, this.now});

  final DateTime? now;

  static Route<void> route({DateTime? now}) => MaterialPageRoute<void>(
        builder: (_) => MaestroScope(child: NightRiteScreen(now: now)),
      );

  @override
  Widget build(BuildContext context) {
    final date = now ?? DateTime.now();
    final maestro = DailyRituals.nightMaestro(date);
    final palette = MaestroPalette.forKey(ThemeKey.of(maestro));
    final message = DailyRituals.nightMessage(date);

    return RitualView(
      title: 'Rito della Buonanotte',
      palette: palette,
      // Slot del fondale condiviso: qui si cabla il PNG della notte quando
      // arrivera'. Per ora null, fondo procedurale coerente col cosmo.
      backgroundAsset: null,
      gesture: RitualGesture.tap,
      prompt: 'Tocca per lasciare andare il giorno',
      sensorHint:
          'Un respiro lungo, poi tocca la scena: il ripiego tattile vale sempre.',
      footnote: 'Un suono di frequenze è opzionale, il gesto basta da solo.',
      visualBuilder: (context, revealed, t) => CustomPaint(
        painter: _NightPainter(palette: palette, t: t, revealed: revealed),
      ),
      revealed: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('La buonanotte di ${maestro.displayName}',
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

class _NightPainter extends CustomPainter {
  _NightPainter({required this.palette, required this.t, required this.revealed});

  final MaestroPalette palette;
  final double t;
  final bool revealed;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    // Cielo notturno: dal profondo del Maestro al nero quieto verso il basso.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            palette.primary.withValues(alpha: 0.5),
            palette.deepest,
            const Color(0xFF010208),
          ],
        ).createShader(rect),
    );

    // La Luna alta, che dopo il rito si addolcisce in un alone piu' ampio.
    final moonC = Offset(size.width * 0.5, size.height * 0.34);
    final moonR = size.width * 0.12;
    final breathe = 0.5 + 0.5 * math.sin(t * math.pi);
    canvas.drawCircle(
      moonC,
      moonR * (revealed ? 3.0 : 2.2) * (0.9 + 0.1 * breathe),
      Paint()
        ..shader = RadialGradient(colors: [
          palette.goldSoft.withValues(alpha: revealed ? 0.4 : 0.22),
          const Color(0x00000000),
        ]).createShader(
            Rect.fromCircle(center: moonC, radius: moonR * 3.0)),
    );
    canvas.drawCircle(
        moonC, moonR, Paint()..color = palette.goldSoft.withValues(alpha: 0.85));

    // Un campo di stelle quiete, che pulsano appena.
    final rng = math.Random(23);
    for (var i = 0; i < 70; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height * 0.85;
      final twinkle = 0.3 + 0.4 * math.sin((t + rng.nextDouble()) * math.pi * 2);
      canvas.drawCircle(
        Offset(x, y),
        rng.nextDouble() * 1.1 + 0.3,
        Paint()..color = Colors.white.withValues(alpha: twinkle * 0.6),
      );
    }
  }

  @override
  bool shouldRepaint(_NightPainter old) =>
      old.t != t || old.revealed != revealed || old.palette != palette;
}
