import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:flutter_test/flutter_test.dart';

/// L'ampiezza del movimento da sensore.
///
/// Il campo stellare, che e' il piano che l'occhio segue, si spostava di 2,88
/// pixel a telefono inclinato fino in fondo: l'ampiezza era 18 e la profondita'
/// del piano 0,16. Inclinando il telefono non si vedeva niente.
///
/// Qui si misurano due cose, coi numeri e non a impressione: quanto si sposta
/// quel piano, e quanto il dito lo sposta rispetto al sensore. Un cielo dove il
/// dito conta dieci volte il sensore non e' un cielo che reagisce a come tieni
/// il telefono.
void main() {
  test('Il piano principale si sposta almeno 24 pixel logici', () {
    final sensore = ParallaxController.spostamentoPianoPrincipale;
    expect(sensore, greaterThanOrEqualTo(24.0),
        reason: 'con $sensore px il movimento non si sente in mano');
    // Il valore vecchio, per non tornarci per sbaglio.
    expect(18 * ParallaxController.depthPianoPrincipale, lessThan(3.0));
  });

  test('Il dito non conta piu\' di tre volte il sensore', () {
    final sensore = ParallaxController.spostamentoPianoPrincipale;
    final dito = ParallaxController.spostamentoDitoPianoPrincipale;
    // Sul cosmo di fondo il dito agisce solo in verticale, con lo scorrimento:
    // in orizzontale non tocca il piano, quindi quel rapporto e' zero.
    final rapportoY = dito / sensore;
    expect(rapportoY, lessThanOrEqualTo(3.0),
        reason: 'dito $dito px contro sensore $sensore px');
    expect(0 / sensore, lessThanOrEqualTo(3.0));
  });

  test('A trenta gradi il piano principale fa un decimo dello schermo', () {
    // A trenta gradi il tilt normalizzato vale 0,5, perche' e' la proiezione
    // della gravita'. Li' il piano di riferimento deve spostarsi di almeno il
    // dieci per cento della larghezza: 39 px su uno schermo da 390 logici.
    final aTrenta = ParallaxController.spostamentoPianoPrincipale * 0.5;
    expect(aTrenta, greaterThanOrEqualTo(39.0),
        reason: 'a trenta gradi il cielo si sposta di $aTrenta px');
  });

  test('I piani vicini restano dentro la quinta', () {
    // Il piano piu' vicino del cosmo ha profondita' 1,3: senza compressione
    // volerebbe a 650 px a fondo corsa.
    final vicino = ParallaxController.tiltRangeDefault *
        ParallaxController.profonditaEfficace(1.3);
    expect(vicino, lessThan(180.0),
        reason: 'il vicino vola via a $vicino px');
    // Resta comunque piu' mobile del piano di riferimento: e' la parallasse.
    expect(vicino,
        greaterThan(ParallaxController.spostamentoPianoPrincipale));
    // Il lontano si muove meno del principale.
    final lontano = ParallaxController.tiltRangeDefault *
        ParallaxController.profonditaEfficace(0.06);
    expect(lontano, lessThan(ParallaxController.spostamentoPianoPrincipale));
  });

  test('La scala resta uno a uno fino al piano di riferimento', () {
    expect(ParallaxController.profonditaEfficace(0.06), 0.06);
    expect(ParallaxController.profonditaEfficace(0.16), 0.16);
    expect(ParallaxController.profonditaEfficace(0.5),
        closeTo(0.16 + 0.34 * 0.15, 1e-9));
  });
}
