import 'dart:io';

import 'package:esoteric_circle/design_system/transizioni/passaggio_del_cerchio.dart';
import 'package:esoteric_circle/design_system/transizioni/velo_del_cerchio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// IL VELO E' UNO SOLO: fogli, dialoghi e rotte. Ordine CF voce 09.
///
/// **Il fatto del fondatore, verbatim**: "avevo chiesto che OGNI SCHERMATA DI
/// FUNZIONALITA' DOVEVA APPARIRE CON UN FLASH NERO!" E la richiesta
/// originale, dall'ordine CC: "voglio che questo flash sia nero e che ci sia
/// sempre ad ogni cambio schermata. niente deve apparire di botto."
///
/// **PERCHE' LA PROVA DELL'ORDINE CC ERA VERDE, ed e' il caso da manuale di
/// una prova che misura la grandezza sbagliata.** Quel censimento contava le
/// ROTTE, e sulle rotte diceva il vero: rimisurato oggi sono ancora tutte
/// sotto la legge, con le due eccezioni dichiarate. Ma un foglio che sale e un
/// dialogo che appare non SONO rotte: non passano da `Navigator.push`, non
/// hanno una `PageRoute`, e quel censimento non aveva nessun modo di vederli.
/// Per la persona davanti allo schermo, pero', sono cambi di schermata
/// identici a una rotta.
///
/// **Le due prove misurano due cose diverse.** La prima guarda i PIXEL: apre
/// un foglio vero e legge il colore che il velo dipinge davvero. La seconda
/// guarda il sorgente, perche' senza di lei basterebbe una chiamata diretta
/// in un file nuovo per riaprire il buco senza che nessuno se ne accorga.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Color? barrieraDipinta(WidgetTester tester) {
    final barriere = tester.widgetList<ModalBarrier>(find.byType(ModalBarrier));
    for (final b in barriere) {
      if (b.color != null) return b.color;
    }
    return null;
  }

  testWidgets('il velo dietro un foglio e\' il nero del Cerchio',
      (tester) async {
    late BuildContext dentro;
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (c) {
        dentro = c;
        return const Scaffold(body: SizedBox());
      }),
    ));
    foglioDelCerchio<void>(
      context: dentro,
      builder: (_) => const SizedBox(height: 100),
    );
    await tester.pumpAndSettle();
    final colore = barrieraDipinta(tester);
    // ignore: avoid_print
    print('ORDINE CF VOCE 09: il velo del foglio e\' $colore, il nero del '
        'passaggio e\' ${PassaggioDelCerchio.nero}');
    expect(colore, isNotNull,
        reason: 'dietro il foglio non c\'e\' nessun velo: la schermata di '
            'sotto resta in piena luce e il foglio arriva di botto');
    expect(colore!.toARGB32(), VeloDelCerchio.barriera.toARGB32(),
        reason: 'il velo dietro il foglio e\' $colore invece del nero del '
            'Cerchio: sul cosmo blu il grigio del framework si vede, ed e\' '
            'la ragione per cui i fogli sembravano di un\'altra app');
  });

  testWidgets('il velo dietro un dialogo e\' lo stesso', (tester) async {
    late BuildContext dentro;
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (c) {
        dentro = c;
        return const Scaffold(body: SizedBox());
      }),
    ));
    dialogoDelCerchio<void>(
      context: dentro,
      builder: (_) => const AlertDialog(content: Text('x')),
    );
    await tester.pumpAndSettle();
    final colore = barrieraDipinta(tester);
    // ignore: avoid_print
    print('ORDINE CF VOCE 09: il velo del dialogo e\' $colore');
    expect(colore?.toARGB32(), VeloDelCerchio.barriera.toARGB32(),
        reason: 'il dialogo non ha lo stesso velo del foglio: due materie '
            'diverse per lo stesso gesto');
  });

  test('nessuno chiama piu\' il framework per conto suo', () {
    // **LE ECCEZIONI SI DICHIARANO PER NOME.** Oggi non ce n'e' nessuna: la
    // porta e' una sola, e il file della porta e' l'unico posto dove le
    // funzioni del framework si nominano.
    const porta = 'lib/design_system/transizioni/velo_del_cerchio.dart';
    const eccezioni = <String>{};
    const dirette = <String>[
      'showModalBottomSheet',
      'showDialog',
      'showGeneralDialog',
    ];
    final colpe = <String>[];
    var quante = 0;
    for (final f in Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))) {
      final percorso = f.path.replaceAll(r'\', '/');
      if (percorso == porta || eccezioni.contains(percorso)) continue;
      final sorgente = f
          .readAsStringSync()
          .split('\n')
          .where((r) =>
              !r.trimLeft().startsWith('//') && !r.trimLeft().startsWith('///'))
          .join('\n');
      for (final nome in dirette) {
        // Solo le chiamate: il nome seguito da parentesi o da generici.
        final trovate = RegExp('$nome[<(]').allMatches(sorgente).length;
        if (trovate > 0) {
          quante += trovate;
          colpe.add('$percorso chiama $nome $trovate volte');
        }
      }
    }
    // ignore: avoid_print
    print('ORDINE CF VOCE 09: chiamate diritte al framework $quante, '
        'eccezioni dichiarate ${eccezioni.length}');
    expect(colpe, isEmpty,
        reason: 'questi punti aprono un foglio o un dialogo senza passare dal '
            'velo del Cerchio, quindi arrivano su un fondo che non e\' il '
            'nostro: $colpe');
  });
}
