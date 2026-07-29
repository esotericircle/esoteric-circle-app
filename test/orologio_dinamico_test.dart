import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/features/onboarding/orologio_dinamico.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// L'orologio si muove come un orologio.
///
/// Prima la schermata dell'ora mostrava un orizzonte disegnato che non
/// cambiava mai: girando i selettori non succedeva niente, quindi la scelta
/// non aveva riscontro.
void main() {
  group('Il quadrante conta come un orologio vero', () {
    test('La lancetta delle ore avanza in proporzione ai minuti', () {
      // Alle sette e mezza sta a META' fra il sette e l'otto, non ancora sul
      // sette: e' la differenza fra un orologio e un contatore a scatti.
      final sette = OrologioDinamico.giroOre(7, 0);
      final setteEMezza = OrologioDinamico.giroOre(7, 30);
      final otto = OrologioDinamico.giroOre(8, 0);
      expect(setteEMezza, closeTo((sette + otto) / 2, 1e-9));
      expect(setteEMezza, greaterThan(sette));
      expect(setteEMezza, lessThan(otto));
    });

    test('Il quadrante ha dodici ore, non ventiquattro', () {
      expect(OrologioDinamico.giroOre(15, 0),
          closeTo(OrologioDinamico.giroOre(3, 0), 1e-9));
      expect(OrologioDinamico.giroOre(0, 0), 0);
    });

    test('I minuti fanno un giro intero in un\'ora', () {
      expect(OrologioDinamico.giroMinuti(0), 0);
      expect(OrologioDinamico.giroMinuti(30), 0.5);
      expect(OrologioDinamico.giroMinuti(45), 0.75);
    });
  });

  group('La strada e\' sempre la piu\' corta', () {
    test('Da undici a una si va avanti, non indietro', () {
      final da = OrologioDinamico.giroOre(11, 0);
      final a = OrologioDinamico.piuVicino(OrologioDinamico.giroOre(1, 0), da);
      expect(a, greaterThan(da),
          reason: 'la lancetta torna indietro attraversando il quadrante');
      expect(a - da, closeTo(2 / 12, 1e-9), reason: 'due ore, non dieci');
    });

    test('Da uno a undici si va indietro', () {
      final da = OrologioDinamico.giroOre(1, 0);
      final a = OrologioDinamico.piuVicino(OrologioDinamico.giroOre(11, 0), da);
      expect(a, lessThan(da));
      expect(da - a, closeTo(2 / 12, 1e-9));
    });

    test('Nessuna corsa supera mezzo giro', () {
      for (var da = 0; da < 12; da++) {
        for (var a = 0; a < 12; a++) {
          final p = OrologioDinamico.giroOre(da, 0);
          final q = OrologioDinamico.piuVicino(OrologioDinamico.giroOre(a, 0), p);
          expect((q - p).abs(), lessThanOrEqualTo(0.5 + 1e-9),
              reason: 'da $da a $a la lancetta fa il giro lungo');
        }
      }
    });
  });

  testWidgets('Cambiando l\'ora le lancette si spostano un poco per volta',
      (tester) async {
    Widget host(int ora, int minuto) => MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 200,
                height: 200,
                child: OrologioDinamico(
                  ora: ora,
                  minuto: minuto,
                  palette: MaestroPalette.neutral,
                ),
              ),
            ),
          ),
        );

    await tester.pumpWidget(host(3, 0));
    await tester.pump();

    double giroOre() => _leggiGiro(tester);

    final partenza = giroOre();
    await tester.pumpWidget(host(9, 0));
    await tester.pump(const Duration(milliseconds: 60));
    final subito = giroOre();

    // Dopo sessanta millesimi la lancetta si e' mossa, ma non e' arrivata:
    // se arrivasse subito sarebbe uno scatto, che e' il difetto.
    expect(subito, isNot(partenza), reason: 'la lancetta non si e\' mossa');
    final arrivo = OrologioDinamico.piuVicino(
        OrologioDinamico.giroOre(9, 0), partenza);
    expect((subito - arrivo).abs(), greaterThan(0.02),
        reason: 'la lancetta e\' arrivata di colpo, senza percorso');

    await tester.pump(OrologioDinamico.corsa);
    expect((giroOre() - arrivo).abs(), lessThan(0.001),
        reason: 'la lancetta non e\' mai arrivata');
  });
}

/// Legge il giro corrente della lancetta delle ore dal painter a schermo.
double _leggiGiro(WidgetTester tester) {
  final cp = tester.widget<CustomPaint>(find.descendant(
    of: find.byType(OrologioDinamico),
    matching: find.byType(CustomPaint),
  ));
  return (cp.painter! as QuadrantePainter).giroOre;
}
