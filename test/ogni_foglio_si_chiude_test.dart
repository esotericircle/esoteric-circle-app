// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/horoscope/astro_tradition.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/design_system/transizioni/velo_del_cerchio.dart';
import 'package:esoteric_circle/features/horoscope/la_testa_della_tradizione.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **OGNI FOGLIO SI CHIUDE.** Il fondatore, 1 ottobre 2026, sulla nota della
/// tradizione cinese: *"si apre dal basso un pannello bolla informativa, ma
/// poi non posso più chiuderla: inserisci in basso una scritta "fatto" per
/// chiudere oppure utilizzando il gesto del dito dall'alto al basso per
/// chiudere la scheda informativa. Controlla che sia così dappertutto"*.
///
/// Si misura:
/// 1. il gesto: un foglio alto quanto lo schermo, col testo che scorre,
///    aperto da `foglioDelCerchio` (la porta di tutti i fogli dell'app), si
///    chiude col dito che scende quando il testo e' in cima, e non si chiude
///    col dito che scorre il testo;
/// 2. la nota della tradizione: "Fatto" c'e', in vista senza scorrere, e la
///    chiude;
/// 3. il censimento: i fogli che si leggono soltanto, quelli senza un altro
///    pulsante che li chiude (contati il 1 ottobre 2026 leggendo i 41 punti
///    che aprono un foglio), portano "Fatto".
void main() {
  Future<void> apri(WidgetTester tester, WidgetBuilder foglio) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (ctx) => Center(
            child: TextButton(
              key: const Key('apri'),
              onPressed: () => foglioDelCerchio<void>(
                  context: ctx, isScrollControlled: true, builder: foglio),
              child: const Text('apri'),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.byKey(const Key('apri')));
    await tester.pumpAndSettle();
  }

  Widget testoLungo(BuildContext _) => SizedBox(
        height: 800,
        child: SingleChildScrollView(
          key: const Key('testo'),
          child: Column(children: [
            for (var i = 0; i < 80; i++) Text('riga $i del foglio'),
          ]),
        ),
      );

  testWidgets('il dito che scende chiude il foglio che scorre', (tester) async {
    await apri(tester, testoLungo);
    expect(find.byKey(const Key('testo')), findsOneWidget);
    // Prima si scorre il testo in giu' (il dito sale): il foglio resta.
    await tester.drag(find.byKey(const Key('testo')), const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('testo')), findsOneWidget,
        reason: 'scorrere il testo ha chiuso il foglio');
    // Si torna in cima e il dito continua a scendere: il foglio si chiude.
    await tester.drag(find.byKey(const Key('testo')), const Offset(0, 300));
    await tester.pumpAndSettle();
    await tester.drag(find.byKey(const Key('testo')), const Offset(0, 200));
    await tester.pumpAndSettle();
    final chiuso = find.byKey(const Key('testo')).evaluate().isEmpty;
    print('OGNI FOGLIO SI CHIUDE: il foglio che scorre col dito che scende '
        'dalla cima ${chiuso ? 'si chiude' : 'resta aperto'}');
    expect(chiuso, isTrue,
        reason: 'col testo in cima il dito che scende non chiude il foglio');
  });

  testWidgets('la nota della tradizione ha "Fatto" in vista, e la chiude',
      (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (ctx) => Center(
            child: TextButton(
              key: const Key('apri'),
              onPressed: () =>
                  apriLaNota(ctx, AstroTradition.cinese, MaestroPalette.medora),
              child: const Text('apri'),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.byKey(const Key('apri')));
    await tester.pumpAndSettle();
    final fatto = find.byKey(const Key('foglio_fatto'));
    expect(fatto, findsOneWidget, reason: 'la nota non ha "Fatto"');
    final r = tester.getRect(fatto);
    print('OGNI FOGLIO SI CHIUDE: "Fatto" della nota cinese da '
        '${r.top.toStringAsFixed(0)} a ${r.bottom.toStringAsFixed(0)} su 640');
    expect(r.bottom, lessThanOrEqualTo(640),
        reason: '"Fatto" sta sotto il bordo dello schermo');
    await tester.tap(fatto);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('oroscopo_foglio_nota_cinese')), findsNothing,
        reason: '"Fatto" non chiude la nota');
  });

  test('i fogli che si leggono soltanto portano "Fatto"', () {
    const fogliDaLeggere = [
      'lib/features/horoscope/la_testa_della_tradizione.dart',
      'lib/features/home/widgets/demo_controls.dart',
      'lib/features/synastry/ritratto_ingrandito.dart',
      'lib/features/angels/angels_screen.dart',
      'lib/features/santuario/sky_overview_screen.dart',
      'lib/features/maestri/widgets/foglio_delle_fonti.dart',
      'lib/features/maestri/chat/widgets/diagnostics_dialog.dart',
      'lib/features/sigilli/la_mappa_del_sentiero.dart',
      'lib/features/maestri/live/il_selettore_delle_voci.dart',
    ];
    final senza = [
      for (final f in fogliDaLeggere)
        if (!File(f).readAsStringSync().contains('FattoDelFoglio(')) f,
    ];
    cardinaleMinimo(fogliDaLeggere.length, 9,
        cosa: 'fogli che si leggono soltanto',
        perche: 'contati il 1 ottobre 2026 sui 41 punti che aprono un foglio');
    // La porta di tutti i fogli chiude col dito.
    final porta = File('lib/design_system/transizioni/velo_del_cerchio.dart')
        .readAsStringSync();
    expect(porta, contains('ChiusuraColDito(child: builder(ctx))'),
        reason: 'la porta dei fogli non chiude piu\' col dito');
    print('OGNI FOGLIO SI CHIUDE: fogli che si leggono senza "Fatto" '
        '${senza.length} su ${fogliDaLeggere.length}');
    expect(senza, isEmpty, reason: senza.join('\n'));
  });
}
