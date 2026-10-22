import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:esoteric_circle/features/scene/la_scena_in_video.dart';

/// **OGNI SCENA SI SALTA ANCHE SCORRENDO.** Ordine GB voce 02, 22 ottobre
/// 2026. Il fondatore, sulle scene d'apertura: *"si saltano al semplice tap
/// o con scrolling"*.
///
/// `IlToccoCheSalta` e' il punto unico (ordine FU voce FU.15) da cui passa
/// ogni scena dell'app: un tocco in qualunque punto, mentre il video gira,
/// chiama [IlToccoCheSalta.onSalta]. Questa prova pretende che lo stesso
/// valga per un gesto di scorrimento, non solo per il tocco secco: il velo
/// che copre lo schermo durante il video deve rispondere anche a un dito che
/// scorre, non solo a un dito che tocca e lascia subito.
void main() {
  Future<void> monta(WidgetTester tester, VoidCallback onSalta,
      {bool inCorso = true}) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: IlToccoCheSalta(
          inCorso: inCorso,
          onSalta: onSalta,
          child: const SizedBox.expand(),
        ),
      ),
    ));
  }

  testWidgets('un tocco secco salta, come da sempre', (tester) async {
    var chiamato = false;
    await monta(tester, () => chiamato = true);
    await tester.tap(find.byKey(const Key('il_tocco_che_salta')));
    expect(chiamato, isTrue,
        reason: 'il tocco secco non chiama piu\' onSalta: regressione su '
            'FU.15');
  });

  testWidgets('uno scorrimento verticale salta', (tester) async {
    var chiamato = false;
    await monta(tester, () => chiamato = true);
    await tester.dragFrom(const Offset(200, 400), const Offset(200, 100));
    await tester.pump();
    expect(chiamato, isTrue,
        reason: 'scorrendo durante il video, onSalta non viene chiamato: '
            'GB.02 chiede che il tocco e lo scorrimento saltino allo stesso '
            'modo');
  });

  testWidgets('uno scorrimento orizzontale salta', (tester) async {
    var chiamato = false;
    await monta(tester, () => chiamato = true);
    await tester.dragFrom(const Offset(200, 400), const Offset(50, 400));
    await tester.pump();
    expect(chiamato, isTrue,
        reason: 'scorrendo in orizzontale durante il video, onSalta non '
            'viene chiamato');
  });

  testWidgets('a scena ferma (inCorso falso) lo scorrimento non e\' rubato',
      (tester) async {
    var chiamato = false;
    await monta(tester, () => chiamato = true, inCorso: false);
    await tester.dragFrom(const Offset(200, 400), const Offset(200, 100));
    await tester.pump();
    expect(chiamato, isFalse,
        reason: 'a scena gia\' ferma il velo non deve esistere: uno '
            'scorrimento non deve chiamare onSalta ne\' rubare il gesto a '
            'chi sta sotto');
  });
}
