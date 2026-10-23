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

  testWidgets('nella chat di un Maestro che ne fa parte la domanda e i '
      'pareri ci sono', (tester) async {
    // Calìgo entra davvero nel consulto (da' il suo parere): solo cosi' la
    // sua chat deve mostrare la scheda, ordine GB voce 05.
    IlFiloDelConsulto.annota(
        maestro: Maestro.caligo,
        domanda: 'Quando riceverò una promozione?',
        risposta: 'Chiedila venerdì.');
    await monta(tester, Maestro.caligo);
    expect(find.text('Hai chiesto a Medora: «Quando riceverò una promozione?»'),
        findsOneWidget);
    expect(find.text('I pareri di Medora e Calìgo. Tocca per leggerli.'),
        findsOneWidget);
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
    // **SOGLIA PIU' ALTA DA QUANDO LA SCHEDA MOSTRA UN MAESTRO REALMENTE
    // COINVOLTO** (ordine GB voce 05): la riga chiusa adesso nomina sempre
    // almeno due Maestri ("I pareri di Medora e Calìgo"), mai uno solo,
    // perche' il Maestro che la vede e' uno di loro. 140 lascia lo stesso
    // margine di prima sul testo piu' lungo che questa chat mostra davvero.
    expect(chiusa.height, lessThan(140),
        reason: 'chiusa la scheda ruba troppo spazio alla conversazione');
  });

  // **LA CARTA FILTRA PER MAESTRO. Ordine GB voce 05, 22 ottobre 2026.** Il
  // rapporto dell'ordine GA, punto 5: "la conversazione con Aura mostrava la
  // domanda fatta a Calìgo". Qui il consulto e' tutto e solo di Medora (dal
  // setUp): Aura non ne fa parte e la sua chat non deve mostrare niente.
  testWidgets(
      'nella chat di un Maestro che non ne fa parte la scheda non compare',
      (tester) async {
    await monta(tester, Maestro.aura);
    expect(find.byKey(const Key('filo_in_cima')), findsNothing,
        reason: 'Aura non ha mai preso parte a questo consulto: la sua chat '
            'non deve ricordare una domanda fatta a un altro Maestro');
  });

  testWidgets('con tre Maestri i nomi si dicono come in italiano',
      (tester) async {
    // Visto sul Realme con la build 2299: "Medora e Calìgo e Aura".
    IlFiloDelConsulto.annota(
        maestro: Maestro.caligo,
        domanda: 'Quando riceverò una promozione?',
        risposta: 'Chiedila venerdì.');
    IlFiloDelConsulto.annota(
        maestro: Maestro.aura,
        domanda: 'Quando riceverò una promozione?',
        risposta: 'Respira e poi chiedila.');
    await monta(tester, Maestro.aura);
    expect(find.text('I pareri di Medora, Calìgo e Aura. Tocca per leggerli.'),
        findsOneWidget);
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
