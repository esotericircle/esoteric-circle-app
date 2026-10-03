import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../design_system/theme/maestro_scope.dart';

/// Indicatore di attesa mentre il Maestro compone: tre punti luce che pulsano
/// come piccole stelle, nel colore del Maestro. E' il segno visivo a tema che
/// precede il testo, coerente con la legge del visivo prima della parola.
class AstralTypingIndicator extends StatefulWidget {
  const AstralTypingIndicator({super.key});

  @override
  State<AstralTypingIndicator> createState() => _AstralTypingIndicatorState();
}

class _AstralTypingIndicatorState extends State<AstralTypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final phase = _controller.value * 2 * math.pi + i * 0.9;
            final glow = 0.35 + 0.65 * (0.5 + 0.5 * math.sin(phase));
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: palette.goldSoft.withValues(alpha: glow),
                  boxShadow: [
                    BoxShadow(
                      color: palette.glow.withValues(alpha: 0.5 * glow),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
