import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/design_system/components/zodiac_wheel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// La ruota zodiacale disegnata a vettori: si monta, si tinge, si attenua e
/// resta statica sotto Riduci Movimento.
void main() {
  Widget host(Widget child, {bool reduceMotion = false}) => MediaQuery(
        data: MediaQueryData(disableAnimations: reduceMotion),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox(width: 300, height: 300, child: child),
        ),
      );

  testWidgets('Si monta e disegna, con colore e opacita\'', (tester) async {
    await tester.pumpWidget(host(const ZodiacWheel(
      color: Color(0xFFE4C079),
      opacity: 0.8,
      highlight: Zodiac.gemini,
    )));
    await tester.pump();
    expect(find.byType(ZodiacWheel), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);
  });

  testWidgets('Sotto Riduci Movimento resta statica, senza animazione infinita',
      (tester) async {
    await tester.pumpWidget(host(
      const ZodiacWheel(color: Color(0xFFE4C079)),
      reduceMotion: true,
    ));
    // Se restasse un'animazione in corso, pumpAndSettle andrebbe in timeout.
    await tester.pumpAndSettle();
    expect(find.byType(ZodiacWheel), findsOneWidget);
  });

  testWidgets('Opacita\' a zero non rende nulla ma si monta', (tester) async {
    await tester.pumpWidget(host(const ZodiacWheel(
      color: Color(0xFFE4C079),
      opacity: 0,
      ambientRotation: false,
    )));
    await tester.pump();
    expect(find.byType(ZodiacWheel), findsOneWidget);
  });
}
