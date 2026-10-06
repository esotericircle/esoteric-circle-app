// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/chat/il_filo_del_consulto.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/design_system/theme/app_theme.dart';
import 'package:esoteric_circle/features/maestri/chat/widgets/il_filo_in_cima.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **IL FILO IN CIMA ALLA CHAT. Ordine FE voce 22**, la richiesta del
/// fondatore del 6 ottobre 2026. In cima alla chat di un Maestro, quando il
/// consulto e' passato da un altro: "Hai chiesto a Medora: «...»" e, al
/// tocco, il parere di ogni Maestro gia' consultato. Non compare quando il
/// consulto e' tutto con lo stesso Maestro, e non compare oltre l'ora del
/// filo.
void main() {
  var ora = DateTime(2026, 10, 6, 10);

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    IlFiloDelConsulto.dimentica();
    ora = DateTime(2026, 10, 6, 10);
    IlFiloDelConsulto.adesso = () => ora;
    IlFiloDelConsulto.annota(
        maestro: Maestro.medora,
        domanda: 'Quando riceverò una promozione?',
        risposta: 'Il cielo ti chiede pazienza.\n'
            '✦ Aspetta la fine del mese prima di chiedere il colloquio.');
  });

  Future<void> monta(WidgetTester tester, Maestro m) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(360, 797);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.dark(),
      home: Scaffold(body: Column(children: [IlFiloInCima(maestro: m)])),
    ));
  }

  testWidgets('nella chat di un altro Maestro la domanda e i pareri ci sono',
      (tester) async {
    await monta(tester, Maestro.aura);
    expect(find.text('Hai chiesto a Medora: «Quando riceverò una promozione?»'),
        findsOneWidget);
    expect(
        find.text('Il parere di Medora. Tocca per leggerlo.'), findsOneWidget);
    expect(find.byKey(const Key('filo_in_cima_medora')), findsNothing);
    final chiusa = tester.getSize(find.byKey(const Key('filo_in_cima')));
    await tester.tap(find.byKey(const Key('filo_in_cima')));
    await tester.pump();
    expect(
        find.text('Medora: «Il cielo ti chiede pazienza. Aspetta la fine del '
            'mese prima di chiedere il colloquio.»'),
        findsOneWidget);
    print('ORDINE FE VOCE 22: la scheda in cima, chiusa alta '
        '${chiusa.height.round()} punti su 797');
    expect(chiusa.height, lessThan(110),
        reason: 'chiusa la scheda ruba troppo spazio alla conversazione');
  });

  testWidgets('con un solo Maestro la scheda non compare', (tester) async {
    await monta(tester, Maestro.medora);
    expect(find.byKey(const Key('filo_in_cima')), findsNothing);
  });

  testWidgets('oltre l\'ora la scheda non compare', (tester) async {
    ora = ora.add(const Duration(minutes: 61));
    await monta(tester, Maestro.aura);
    expect(find.byKey(const Key('filo_in_cima')), findsNothing);
  });
}
