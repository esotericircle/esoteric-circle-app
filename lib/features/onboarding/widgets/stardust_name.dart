import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../design_system/tokens/color_tokens.dart';

/// Il nome dell'utente che si compone in calligrafia dorata di polvere di
/// stelle: mentre scrive, il nome brilla con un riflesso che scorre e una
/// nuvola di scintille dorate lo avvolge.
class StardustName extends StatefulWidget {
  const StardustName({super.key, required this.name, this.placeholder = 'il tuo nome'});

  final String name;
  final String placeholder;

  @override
  State<StardustName> createState() => _StardustNameState();
}

class _StardustNameState extends State<StardustName>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 5))
      ..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasName = widget.name.trim().isNotEmpty;
    final text = hasName ? widget.name.trim() : widget.placeholder;

    return SizedBox(
      height: 110,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Scintille dorate attorno al nome.
              Positioned.fill(
                child: CustomPaint(
                  painter: _SparklePainter(t: _c.value, active: hasName),
                ),
              ),
              // Il nome con riflesso dorato che scorre.
              ShaderMask(
                shaderCallback: (rect) {
                  final shift = (_c.value * 2 - 0.5);
                  return LinearGradient(
                    begin: Alignment(-1 + shift, 0),
                    end: Alignment(1 + shift, 0),
                    colors: const [
                      ColorTokens.goldDeep,
                      ColorTokens.goldBright,
                      ColorTokens.gold,
                      ColorTokens.goldBright,
                      ColorTokens.goldDeep,
                    ],
                    stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
                  ).createShader(rect);
                },
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Cinzel',
                    fontSize: 40,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                    color: Colors.white
                        .withValues(alpha: hasName ? 1 : 0.35),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SparklePainter extends CustomPainter {
  _SparklePainter({required this.t, required this.active});
  final double t;
  final bool active;

  @override
  void paint(Canvas canvas, Size size) {
    if (!active) return;
    final rng = math.Random(23);
    const count = 40;
    final paint = Paint()..style = PaintingStyle.fill;
    for (var i = 0; i < count; i++) {
      final bx = rng.nextDouble();
      final by = rng.nextDouble();
      final phase = rng.nextDouble();
      final tw = 0.5 + 0.5 * math.sin(2 * math.pi * (t * 2 + phase));
      // Le scintille si concentrano sulla fascia centrale (dove sta il nome).
      final y = (0.28 + by * 0.44) * size.height;
      final x = bx * size.width;
      final r = (0.4 + rng.nextDouble() * 1.4) * tw;
      paint.color = ColorTokens.goldLight.withValues(alpha: 0.15 + 0.5 * tw);
      canvas.drawCircle(Offset(x, y), r, paint);
    }
  }

  @override
  bool shouldRepaint(_SparklePainter old) => true;
}
