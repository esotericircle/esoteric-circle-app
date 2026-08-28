import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/synastry/cielo_della_sinastria.dart';
import 'package:esoteric_circle/core/synastry/possibilita_di_incontro.dart';
import 'package:esoteric_circle/core/synastry/synastry_report.dart';
import 'package:esoteric_circle/core/synastry/vip_catalog.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/synastry/mappa_della_distanza.dart';
import 'package:esoteric_circle/features/synastry/sinastria_vip_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// LA CARTA SI APRE, LA LETTURA SI ESPLORA, LA MAPPA MISURA.
/// Ordine BO voci 08 e 09.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  void silenzia() {
    final m = binding.defaultBinaryMessenger;
    m.setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
        (call) async => null);
    for (final nome in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      m.setMockStreamHandler(
          EventChannel(nome), MockStreamHandler.inline(onListen: (a, e) {}));
    }
  }

  final tuo = CieloDiSinastria.perIdentita(
      BirthIdentity.fromParts(birthDate: DateTime(1988, 3, 14)));

  Widget attorno(Widget scena) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => ZodiacController()),
        ],
        child: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            home: MaestroScope(child: scena),
          ),
        ),
      );

  Future<void> monta(WidgetTester tester, Vip vip) async {
    silenzia();
    tester.view.physicalSize = const Size(440, 2200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(attorno(SinastriaVipScreen(
        key: UniqueKey(), vip: vip, saltaLaChiamata: true, userName: 'Tu')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
  }

  // --- BO.08 ---

  testWidgets('la carta del VIP si apre al tocco, col nome e il luogo',
      (tester) async {
    final vip = VipCatalog.conNome('Zendaya')!;
    await monta(tester, vip);
    final polo = find.byKey(const Key('sinastria_pole_vip'));
    expect(polo, findsOneWidget);
    // Il bersaglio non scende sotto i 48 punti.
    final r = tester.getRect(polo);
    expect(r.width, greaterThanOrEqualTo(48.0));
    expect(r.height, greaterThanOrEqualTo(48.0));

    // **IL TOCCO ADESSO CHIEDE COSA FARE.** Ordine del fondatore del 28
    // agosto 2026: "l'utente fa click sulla carta e puo' cambiare il vip". Il
    // ritratto si apre dalla prima voce del foglio; la carta resta
    // ingrandibile al click, che era il difetto 2 dell'ordine BO.
    await tester.tap(polo);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('sinastria_scelte_carta')), findsOneWidget,
        reason: 'il tocco sulla carta non offre piu\' nessuna scelta');
    await tester.tap(find.byKey(const Key('sinastria_apri_carta')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('ritratto_figura')), findsOneWidget,
        reason: 'il ritratto del VIP non si apre: era il difetto 2 del '
            'fondatore, "la Carta vip deve essere ingrandibile al click"');
    expect(find.byKey(const Key('ritratto_nome')), findsOneWidget);
    expect(find.byKey(const Key('ritratto_categoria')), findsOneWidget);
    final nascita =
        tester.widget<Text>(find.byKey(const Key('ritratto_nascita'))).data!;
    expect(nascita, contains(vip.note),
        reason: 'la carta non porta la data di nascita');
    expect(nascita, contains(vip.luogoDiNascita!.nome),
        reason: 'la carta non porta il luogo di nascita');

    // Si chiude col tocco fuori.
    await tester.tapAt(const Offset(10, 10));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byKey(const Key('ritratto_figura')), findsNothing);
  });

  testWidgets('la carta si chiude anche col gesto indietro del sistema',
      (tester) async {
    await monta(tester, VipCatalog.conNome('Zendaya')!);
    await tester.tap(find.byKey(const Key('sinastria_pole_vip')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('sinastria_apri_carta')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('ritratto_figura')), findsOneWidget);
    // E' una rotta, quindi il gesto indietro ce l'ha per costruzione.
    Navigator.of(tester.element(find.byType(MaestroScope).first)).maybePop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byKey(const Key('ritratto_figura')), findsNothing);
  });

  testWidgets('toccando un filo si apre cosa significa, con lo stesso testo',
      (tester) async {
    final vip = VipCatalog.conNome('Zendaya')!;
    await monta(tester, vip);
    final fili = find.byKey(const Key('sinastria_fili_toccabili'));
    expect(fili, findsOneWidget, reason: 'i fili non sono esplorabili');

    final report = SynastryReport.perCieli(
        tuo: SinastriaVipScreenState.cieloDiRipiego(
            BirthIdentity.example.birthMoment, null, 'Tu'),
        vip: vip);
    final primo = report.aspettiPiuForti.first;
    final chip = find.byKey(Key('sinastria_filo_${primo.titolo}'));
    expect(chip, findsOneWidget);
    final r = tester.getRect(chip);
    expect(r.height, greaterThanOrEqualTo(48.0),
        reason: 'il filo è più basso del bersaglio del dito');

    await tester.tap(chip);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byKey(const Key('sinastria_significato')), findsOneWidget);
    // **IL TESTO E' IDENTICO CARATTERE PER CARATTERE**, perché è lo stesso
    // oggetto da cui nasce il responso, non una seconda copia.
    final fatto = tester
        .widget<Text>(find.byKey(const Key('sinastria_significato_fatto')))
        .data!;
    expect(fatto, primo.fatto);
    expect(report.reading, contains(primo.fatto),
        reason: 'il responso e la bolla del filo dicono cose diverse: sono '
            'due copie, e al primo che ne cambia una divergono');
  });

  test('ogni aspetto possibile ha un significato, e mai vuoto', () {
    var quanti = 0;
    for (final vip in VipCatalog.vips) {
      final r = SynastryReport.perCieli(tuo: tuo, vip: vip);
      for (final a in r.aspetti) {
        expect(a.significato, isNotEmpty, reason: a.titolo);
        expect(a.significato.trim().endsWith('.'), isTrue, reason: a.titolo);
        expect(a.fatto, isNotEmpty, reason: a.titolo);
        quanti++;
      }
    }
    expect(quanti, greaterThan(200),
        reason: 'con così pochi aspetti la copertura non dice niente');
  });

  // --- BO.09 ---

  test('la mappa parte stretta e arriva a tenere dentro i due punti', () {
    const tu = (lat: 45.4642, lon: 9.1920); // Milano
    const lui = (lat: 34.0522, lon: -118.2437); // Los Angeles
    final partenza = InquadraturaDellaMappa.a(0, tu: tu, lui: lui);
    final arrivo = InquadraturaDellaMappa.a(1, tu: tu, lui: lui);
    expect(partenza.larghezzaInGradi, InquadraturaDellaMappa.partenza);
    expect(arrivo.larghezzaInGradi,
        greaterThan(partenza.larghezzaInGradi * 100),
        reason: 'lo zoom non si allarga abbastanza da tenere dentro Los '
            'Angeles');
    // **E L\'INQUADRATURA FINALE CONTIENE DAVVERO I DUE PUNTI, ordine BX
    // voce 06, quinto rilievo.**
    //
    // **La grandezza misurata e\' cambiata, e la soglia no.** Qui si guardava
    // solo la LARGHEZZA, e la larghezza bastava: il difetto stava nel
    // CENTRO, che a fine corsa si fermava sulla citta\' del VIP invece che a
    // meta\' strada, e il tuo punto restava fuori dal riquadro. Una prova
    // sulla larghezza non poteva vederlo, ed e\' per questo che il fondatore
    // ha dovuto segnalarlo lui: "le mappe si vedono troppo ingrandite".
    // Adesso si chiede all\'inquadratura se contiene i punti, che e\' la
    // domanda vera.
    // ignore: avoid_print
    print('ORDINE BX VOCE 6: a fine corsa il centro sta a '
        '${arrivo.centro.lat.toStringAsFixed(2)}, '
        '${arrivo.centro.lon.toStringAsFixed(2)}; contiene te? '
        '${arrivo.contiene(tu)}; contiene lui? ${arrivo.contiene(lui)}');
    expect(arrivo.contiene(tu), isTrue,
        reason: 'a fine corsa il TUO punto sta fuori dall\'inquadratura: la '
            'mappa mostra una citta\' sola ingrandita');
    expect(arrivo.contiene(lui), isTrue,
        reason: 'a fine corsa il punto del VIP sta fuori dall\'inquadratura');
  });

  test('nella stessa città lo zoom NON si allarga, e quella è la sorpresa',
      () {
    const tu = (lat: 45.4642, lon: 9.1920);
    const lui = (lat: 45.4700, lon: 9.1990); // due passi più in là
    final arrivo = InquadraturaDellaMappa.a(1, tu: tu, lui: lui);
    expect(arrivo.larghezzaInGradi, InquadraturaDellaMappa.partenza,
        reason: 'lo zoom si allarga anche per due punti nella stessa città: '
            'la sorpresa era che non si allargasse');
    // ignore: avoid_print
    print('ORDINE BO VOCE 09: stessa città, inquadratura finale '
        '${arrivo.larghezzaInChilometri.toStringAsFixed(1)} km');
    expect(arrivo.larghezzaInChilometri, lessThan(20),
        reason: 'l\'inquadratura finale è larga '
            '${arrivo.larghezzaInChilometri} km, sopra i venti che l\'ordine '
            'concede');
  });

  test('la distanza mostrata è quella calcolata, entro l\'uno per cento', () {
    const milano = DoveSei(
        citta: 'Milano', latitudine: 45.4642, longitudine: 9.1920);
    for (final v in VipCatalog.vips) {
      final i = PossibilitaDiIncontro.per(vip: v, doveSei: milano);
      if (i.chilometri == null) continue;
      final sue = i.sueCoordinate!;
      final ricalcolata = PossibilitaDiIncontro.chilometriFra(
          milano.latitudine, milano.longitudine, sue.lat, sue.lon);
      expect(i.chilometri!, closeTo(ricalcolata, ricalcolata * 0.01),
          reason: '${v.name}: la distanza mostrata non è quella delle '
              'coordinate');
    }
  });

  testWidgets('per chi non c\'è più la mappa non esiste in albero',
      (tester) async {
    await monta(tester, VipCatalog.conNome('Giorgio Armani')!);
    expect(find.byKey(const Key('sinastria_mappa')), findsNothing,
        reason: 'la mappa dell\'incontro c\'è per chi non c\'è più');
    expect(find.byKey(const Key('sinastria_mappa_chilometri')), findsNothing);
  });
}
