import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// **IL GIRO DELLA TENDINA DELLA SINASTRIA EVOLUTIVA**, per le prove. Ordine
/// GD voci GD.14-GD.17: dal pulsante in basso, Offline, una persona nuova, il
/// modulo (nome, data col calendario di sistema, ora non nota), il legame e,
/// se chiesta, la Lunga; poi "Scopri la compatibilità". Si ferma prima della
/// riflessione: chi la chiama decide quanto tempo far passare.
///
/// Le prove della Sinastria che prima compilavano "La sua nascita" (ordine
/// FY voce FY.11) passano da qui: dall'ordine GD la persona si sceglie dalla
/// tendina che sale sopra la scena.
Future<void> compilaLaTendina(
  WidgetTester tester, {
  String nome = 'Giulia',
  String legame = 'amicizia',
  bool lunga = false,
  bool apri = true,
}) async {
  Future<void> passa([int volte = 4]) async {
    for (var i = 0; i < volte; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }
  }

  Future<void> tocca(Key chiave) async {
    final f = find.byKey(chiave);
    await tester.ensureVisible(f);
    await passa(2);
    await tester.tap(f);
    await passa();
  }

  if (apri) {
    final scelta = find.byKey(const Key('sinastria_scegli_la_persona'));
    await tester.ensureVisible(scelta);
    await passa(2);
    await tester.tap(scelta);
    await passa(6);
  }
  await tocca(const Key('sinastria_tendina_offline'));
  await tocca(const Key('sinastria_tendina_nuovo'));
  await tester.enterText(find.byKey(const Key('sinastria_modulo_nome')), nome);
  await passa(2);
  await tocca(const Key('sinastria_modulo_data'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
  await tocca(const Key('sinastria_modulo_ora_non_nota'));
  await tocca(Key('sinastria_legame_$legame'));
  if (lunga) {
    await tocca(const Key('sinastria_profondita'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lunga').last);
    await tester.pumpAndSettle();
  }
  await tocca(const Key('sinastria_scopri'));
  await passa(4);
}
