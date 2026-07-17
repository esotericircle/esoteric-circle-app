import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/astro/resonance.dart';
import '../../core/maestro/maestro.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';

/// La risonanza coi tre Maestri: tre aure che pulsano a intensita' diversa. La
/// piu' forte si fa avanti, ed e' il Maestro che risuona con il tuo cielo.
class ResonanceScreen extends StatelessWidget {
  const ResonanceScreen({
    super.key,
    required this.resonance,
    required this.onContinue,
  });

  final Resonance resonance;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    // Ordine: vincitore al centro, gli altri ai lati.
    final others =
        Maestro.values.where((m) => m != resonance.winner).toList();
    final ordered = [others.first, resonance.winner, others.last];

    return Padding(
      padding: const EdgeInsets.all(SpacingTokens.lg),
      child: Column(
        children: [
          const SizedBox(height: SpacingTokens.sm),
          Text('LA RISONANZA',
              style: TypographyTokens.label(size: 13)
                  .copyWith(color: palette.goldSoft, letterSpacing: 3)),
          const SizedBox(height: SpacingTokens.xs),
          Text('Chi risuona con te',
              style: TypographyTokens.display(size: 28),
              textAlign: TextAlign.center),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (final m in ordered)
                  _MaestroAura(
                    maestro: m,
                    intensity: resonance.scoreOf(m),
                    isWinner: m == resonance.winner,
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(SpacingTokens.md),
            decoration: BoxDecoration(
              color: palette.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
              border: Border.all(color: palette.gold.withValues(alpha: 0.3)),
            ),
            child: Text(
              resonance.reason,
              textAlign: TextAlign.center,
              style: TypographyTokens.body(size: TypographyTokens.guide)
                  .copyWith(color: ColorTokens.textPrimary, height: 1.45),
            ),
          ),
          const SizedBox(height: SpacingTokens.lg),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: palette.gold,
                foregroundColor: palette.deepest,
                padding: const EdgeInsets.symmetric(vertical: SpacingTokens.md),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(SpacingTokens.radiusPill),
                ),
              ),
              onPressed: onContinue,
              child: Text('Rivela il tuo Maestro',
                  style: TypographyTokens.body(size: 17, weight: 600)
                      .copyWith(color: palette.deepest)),
            ),
          ),
          const SizedBox(height: SpacingTokens.sm),
        ],
      ),
    );
  }
}

class _MaestroAura extends StatefulWidget {
  const _MaestroAura({
    required this.maestro,
    required this.intensity,
    required this.isWinner,
  });

  final Maestro maestro;
  final double intensity;
  final bool isWinner;

  @override
  State<_MaestroAura> createState() => _MaestroAuraState();
}

class _MaestroAuraState extends State<_MaestroAura>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = MaestroPalette.forKey(ThemeKey.of(widget.maestro));
    final base = widget.isWinner ? 96.0 : 58.0;
    // La piu' forte pulsa piu' ampia e viva.
    final pulseAmp = 0.08 + widget.intensity * 0.14;

    return Expanded(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final ph = _c.value * 2 * math.pi;
          final pulse = 1 + pulseAmp * math.sin(ph);
          final forward = widget.isWinner ? -8 + 4 * math.sin(ph) : 0.0;
          return Transform.translate(
            offset: Offset(0, forward),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 150,
                  child: Center(
                    child: CustomPaint(
                      size: Size(base * 1.6, base * 1.6),
                      painter: _OrbPainter(
                        color: p.glow,
                        gold: p.goldSoft,
                        radius: base / 2 * pulse,
                        intensity: widget.intensity,
                        winner: widget.isWinner,
                      ),
                    ),
                  ),
                ),
                Text(
                  widget.maestro.displayName,
                  style: TypographyTokens.display(
                    size: widget.isWinner ? 24 : 20,
                  ).copyWith(
                    color: widget.isWinner
                        ? p.goldSoft
                        : ColorTokens.textSecondary,
                  ),
                ),
                Text(
                  '${(widget.intensity * 100).round()}%',
                  style: TypographyTokens.body(size: 11).copyWith(
                      color: ColorTokens.textMuted, letterSpacing: 1),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _OrbPainter extends CustomPainter {
  _OrbPainter({
    required this.color,
    required this.gold,
    required this.radius,
    required this.intensity,
    required this.winner,
  });

  final Color color;
  final Color gold;
  final double radius;
  final double intensity;
  final bool winner;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    // Alone.
    canvas.drawCircle(
        c,
        radius * 1.5,
        Paint()
          ..color = color.withValues(alpha: 0.15 + intensity * 0.3)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 14 + intensity * 14));
    // Corpo dell'aura.
    canvas.drawCircle(
      c,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Color.lerp(color, Colors.white, 0.3)!,
            color.withValues(alpha: 0.7),
            color.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.6, 1.0],
        ).createShader(Rect.fromCircle(center: c, radius: radius)),
    );
    if (winner) {
      canvas.drawCircle(
          c,
          radius + 5,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.4
            ..color = gold.withValues(alpha: 0.8));
    }
  }

  @override
  bool shouldRepaint(_OrbPainter old) =>
      old.radius != radius || old.intensity != intensity;
}
