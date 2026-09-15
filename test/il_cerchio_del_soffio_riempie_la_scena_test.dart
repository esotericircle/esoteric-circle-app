import 'package:esoteric_circle/features/rituals/breath_destiny_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'attorno_al_soffio.dart';

/// **IL CERCHIO DEL SOFFIO RIEMPIE LA SCENA.** Ordine DD voce 03,
/// 10 settembre 2026.
///
/// **Il fatto del fondatore**: nel Soffio del Destino il cerchio del respiro e'
/// piccolo, e non e' centrato sul soffione.
///
/// **REGOLA I: si monta la schermata vera, in una finestra vera.** Montare la
/// sola [GuidaDelRespiro] direbbe quanto e' grande il cerchio rispetto a
/// niente: la quota che conta e' quella dello **schermo**, e lo schermo esiste
/// solo dentro la schermata.
///
/// **La quota chiesta**: al culmine dell'inspirazione il cerchio occupa almeno
/// il **settanta per cento** della larghezza dello schermo.
///
/// **E il culmine e' un istante preciso, non un momento qualunque.** La misura
/// della figura va da 0,55 a 1,0 e torna indietro: presa a caso, la stessa
/// scena darebbe numeri diversi a ogni giro. Qui si pompa fino alla fine della
/// prima inspirazione, dove la misura vale uno.
void main() {
  const larghezza = 390.0;

  Future<Rect> cerchioAlCulmine(WidgetTester tester) async {
    tester.view.physicalSize = const Size(larghezza, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(attornoAlSoffio(
      BreathDestinyScreen(now: DateTime(2026, 9, 10, 7, 30)),
      finestra: const Size(larghezza, 844),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    // Il rito si scopre col gesto, e il ripiego tattile c e sempre: il
    // respiro compare a dono rivelato.
    await tester.longPress(find.byKey(const Key('ritual_gesture')));
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }

    final figura = find.byKey(const Key('respiro_figura'));
    expect(figura, findsOneWidget,
        reason: 'la figura del respiro non e a schermo: senza di lei questa '
            'prova non misura niente');

    // **SI MISURA IL DIPINTO, NON IL RIQUADRO.** REGOLA I. La chiave sta su
    // un `Transform.scale`, e un Transform **non cambia la misura del
    // riquadro che occupa**: `getRect` direbbe centoquaranta punti a
    // qualunque momento del respiro, anche mentre la figura si contrae a
    // meta. La larghezza vera e il riquadro moltiplicato per la scala, che
    // si legge dal primo elemento della matrice.
    double scala() => (tester
            .widget<Transform>(figura)
            .transform
            .storage[0])
        .abs();

    // Il conto alla rovescia, poi la prima inspirazione fino al culmine.
    await tester.pump(const Duration(seconds: 5));
    var piuGrande = tester.getRect(figura);
    var laPiuLarga = piuGrande.width * scala();
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 250));
      final r = tester.getRect(figura);
      final larga = r.width * scala();
      if (larga > laPiuLarga) {
        laPiuLarga = larga;
        piuGrande = Rect.fromCenter(
            center: r.center, width: larga, height: r.height * scala());
      }
    }
    return piuGrande;
  }

  testWidgets('AL CULMINE IL CERCHIO PRENDE ALMENO IL SETTANTA PER CENTO',
      (tester) async {
    final r = await cerchioAlCulmine(tester);
    final quota = r.width / larghezza;
    // ignore: avoid_print
    print('ORDINE DD VOCE 03: al culmine il cerchio e largo '
        '${r.width.toStringAsFixed(1)} punti su ${larghezza.toStringAsFixed(0)} '
        'di schermo, cioe il ${(quota * 100).toStringAsFixed(1)} per cento');
    expect(quota, greaterThanOrEqualTo(0.70),
        reason: 'al culmine dell inspirazione il cerchio occupa il '
            '${(quota * 100).toStringAsFixed(1)} per cento della larghezza '
            'dello schermo, contro il settanta chiesto: e un cerchietto in '
            'mezzo a una scena che non lo aspetta');
  });

  testWidgets('E STA AL CENTRO DELLO SCHERMO, dove sta il soffione',
      (tester) async {
    // **La seconda meta.** Un cerchio grande e spostato di lato sarebbe verde
    // sulla prima pretesa e sbagliato lo stesso: il fondatore chiede che sia
    // centrato sul soffione, e il soffione sta al centro della scena.
    final r = await cerchioAlCulmine(tester);
    final scarto = (r.center.dx - larghezza / 2).abs();
    // ignore: avoid_print
    print('ORDINE DD VOCE 03: il cerchio ha il centro a '
        '${r.center.dx.toStringAsFixed(1)}, lo schermo a '
        '${(larghezza / 2).toStringAsFixed(1)}, scarto '
        '${scarto.toStringAsFixed(1)} punti');
    expect(scarto, lessThan(2.0),
        reason: 'il cerchio non e centrato: il suo centro cade a '
            '${r.center.dx.toStringAsFixed(1)} mentre il soffione sta a '
            '${(larghezza / 2).toStringAsFixed(1)}');

    // **E NON SBORDA.** Un cerchio che passa i bordi sarebbe grande e tagliato,
    // che non e' cio che l ordine chiede.
    expect(r.left, greaterThanOrEqualTo(-0.5),
        reason: 'il cerchio esce dal bordo sinistro, a ${r.left}');
    expect(r.right, lessThanOrEqualTo(larghezza + 0.5),
        reason: 'il cerchio esce dal bordo destro, a ${r.right}');
  });
}
