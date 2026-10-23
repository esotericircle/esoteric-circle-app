import 'dart:io';
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/lunario/il_dial_a_moon.dart';
import 'package:esoteric_circle/core/lunario/il_respiro_della_luna.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/permissions/app_permission.dart';
import 'package:esoteric_circle/core/permissions/avviso_del_permesso.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/respiro_della_luna/il_respiro_della_luna_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **VIA IL MICROFONO, RESTA IL TIENI PREMUTO.** Ordine GD voce GD.23, 23
/// ottobre 2026. Il fondatore: *"per il respiro della luna e solo nella
/// funzione «Respira», espira e inspira con il microfono non funziona perché
/// è difficile determinare se l'utente sta inspirando o espirando, elimina il
/// microfono e lascia solo «tieni premuto per inspirare e per espirare». Se
/// l'utente solleva il dito, l'animazione e conteggio si fermano, ma può
/// riprenderlo tenendo premuto. Ma deve essere chiaro per l'utente cosa deve
/// fare ovvero tenere premuto"*.
///
/// Tre misure: il sorgente del Respiro non nomina il microfono; aprendo il
/// rito e respirando nessuna chiamata arriva al canale del registratore e il
/// permesso del microfono non risulta mai chiesto; i tre stati a video,
/// prima del gesto, dito premuto, dito sollevato, coi numeri della Luna e del
/// giro. Con `--dart-define=CATTURE=true` i tre stati lasciano la loro
/// cattura in `docs/collaudo/GD/ef/`.
const bool _scrivi = bool.fromEnvironment('CATTURE');

const String _sorgente =
    'lib/features/respiro_della_luna/il_respiro_della_luna_screen.dart';

/// Il canale del pacchetto `record`, quello che `BreathDetector` usa per il
/// microfono (record_platform_interface, `record_method_channel_mixin`).
const MethodChannel _registratore =
    MethodChannel('com.llfbandit.record/messages');

IlDialAMoon _offline() =>
    IlDialAMoon(client: MockClient((_) async => http.Response('', 503)));

void main() {
  final adesso = DateTime(2026, 10, 16, 21);
  final tempi = TempiDelRespiroDellaLuna.diOggi(adesso);
  final radice = GlobalKey();

  Future<void> scatta(WidgetTester tester, String nome) async {
    if (!_scrivi) return;
    await tester.runAsync(() async {
      for (final e in find.byType(Image).evaluate()) {
        try {
          await precacheImage((e.widget as Image).image, e);
        } catch (_) {
          // Un'immagine che manca davvero la gestisce gia' l'errorBuilder.
        }
      }
    });
    await tester.pump(const Duration(milliseconds: 16));
    await tester.runAsync(() async {
      final rb =
          radice.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final img = await rb.toImage(pixelRatio: 1.0);
      final dati = await img.toByteData(format: ui.ImageByteFormat.png);
      final dir = Directory('docs/collaudo/GD/ef');
      if (!dir.existsSync()) dir.createSync(recursive: true);
      File('${dir.path}/$nome.png')
          .writeAsBytesSync(dati!.buffer.asUint8List());
      img.dispose();
    });
  }

  Future<void> apriIlRito(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(
        {'respiro.primaAperturaVista': true});
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    tester.view.padding = const FakeViewPadding(top: 75 * 3, bottom: 48 * 3);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(RepaintBoundary(
      key: radice,
      child: MultiProvider(
        providers: [ChangeNotifierProvider(create: (_) => MaestroController())],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: MaestroScope(
            child: IlRespiroDellaLunaScreen(now: adesso, dialAMoon: _offline()),
          ),
        ),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.tap(find.byKey(const Key('luna_voce_respiro')));
    await tester.pump(const Duration(milliseconds: 600));
  }

  String gesto(WidgetTester tester) => tester
      .widget<Text>(find.byKey(const Key('respiro_gesto_del_momento')))
      .data!;
  String giro(WidgetTester tester) =>
      tester.widget<Text>(find.byKey(const Key('respiro_giro'))).data!;
  double luce(WidgetTester tester) => tester
      .widget<Opacity>(find
          .ancestor(
              of: find.byKey(const Key('respiro_luna_vera')),
              matching: find.byType(Opacity))
          .first)
      .opacity;
  Future<void> passa(WidgetTester tester, Duration d) async {
    final passi = d.inMilliseconds ~/ 50;
    for (var i = 0; i < passi; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  test('il sorgente del Respiro non nomina piu\' il microfono', () {
    final s = File(_sorgente).readAsStringSync();
    for (final nome in const [
      'BreathDetector',
      'breath_detector.dart',
      'AppPermission.microphone',
      'package:record/',
    ]) {
      expect(s.contains(nome), isFalse,
          reason: '$_sorgente nomina ancora "$nome": il microfono torna nel '
              'Respiro, che deve usare il solo dito (GD.23)');
    }
  });

  testWidgets(
      'respirando col dito il microfono non si apre e il suo permesso non '
      'si chiede', (tester) async {
    final chiamate = <String>[];
    tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(_registratore, (c) async {
      chiamate.add(c.method);
      // Se qualcuno chiedesse il permesso, il telefono finto direbbe di si'.
      return true;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(_registratore, null));
    await apriIlRito(tester);
    final dito = await tester.startGesture(
        tester.getCenter(find.byKey(const Key('respiro_la_luna_si_tocca'))));
    await passa(tester, tempi.ciclo);
    await dito.up();
    await tester.pump(const Duration(milliseconds: 300));

    expect(chiamate, isEmpty,
        reason: 'il Respiro ha parlato col registratore del microfono: '
            '$chiamate');
    final prefs = await SharedPreferences.getInstance();
    expect(
        prefs.getBool('permesso.${AppPermission.microphone.name}.gia_chiesto'),
        isNull,
        reason: 'il Respiro ha chiesto il permesso del microfono');
    expect(
        find.byWidgetPredicate((w) =>
            w is AvvisoDelPermesso && w.permesso == AppPermission.microphone),
        findsNothing,
        reason: 'il Respiro mostra ancora l\'avviso del microfono');
  });

  testWidgets(
      'i tre stati: prima del gesto la scritta, col dito premuto il giro '
      'avanza, col dito sollevato tutto fermo', (tester) async {
    await apriIlRito(tester);
    final schermo = tester.view.physicalSize / tester.view.devicePixelRatio;

    // 1. PRIMA DEL GESTO: e' scritto di tenere premuto, sulla scena e a
    // video, e niente si muove.
    expect(gesto(tester), 'Tieni premuto sulla Luna');
    final dove =
        tester.getRect(find.byKey(const Key('respiro_gesto_del_momento')));
    expect(dove.top >= 0 && dove.bottom <= schermo.height, isTrue,
        reason: 'la scritta del gesto e\' fuori dallo schermo: $dove');
    final istruzione = find.byKey(const Key('respiro_istruzione_sulla_scena'));
    expect('${gesto(tester)} ${tester.widget<Text>(istruzione).data}',
        'Tieni premuto sulla Luna per inspirare e per espirare',
        reason: 'la scena non dice di tenere premuto con le parole del '
            'fondatore');
    final doveIstruzione = tester.getRect(istruzione);
    expect(doveIstruzione.top >= 0 && doveIstruzione.bottom <= schermo.height,
        isTrue,
        reason: 'la scritta "tieni premuto" e\' fuori dallo schermo: '
            '$doveIstruzione');
    expect(giro(tester), 'Giro 1 di ${tempi.cicliPerUnMinuto}');
    final luceAlRiposo = luce(tester);
    await passa(tester, const Duration(seconds: 3));
    expect(luce(tester), luceAlRiposo,
        reason: 'senza dito la Luna si muove da sola');
    await scatta(tester, 'gd23_1_prima_del_gesto');

    // 2. DITO PREMUTO: inspiro, poi espiro, e il giro avanza senza mai
    // sollevare il dito.
    final dito = await tester.startGesture(
        tester.getCenter(find.byKey(const Key('respiro_la_luna_si_tocca'))));
    await passa(tester, tempi.inspiro ~/ 2);
    expect(gesto(tester), 'Inspira');
    final luceAMetaInspiro = luce(tester);
    expect(luceAMetaInspiro, greaterThan(luceAlRiposo + 0.1),
        reason: 'col dito premuto la Luna non si accende');
    await scatta(tester, 'gd23_2_dito_premuto');
    await passa(tester, tempi.inspiro ~/ 2 + tempi.espiro ~/ 2);
    expect(gesto(tester), 'Espira',
        reason: 'tenendo premuto l\'inspiro non passa all\'espiro');
    await passa(tester, tempi.espiro ~/ 2 + const Duration(milliseconds: 200));
    expect(giro(tester), 'Giro 2 di ${tempi.cicliPerUnMinuto}',
        reason: 'un giro intero col dito premuto non fa avanzare il conteggio');

    // 3. DITO SOLLEVATO a meta' dell'inspiro: la Luna e il giro restano
    // dove sono per cinque secondi.
    await passa(tester, tempi.inspiro ~/ 2);
    await dito.up();
    await tester.pump(const Duration(milliseconds: 50));
    final luceFerma = luce(tester);
    final giroFermo = giro(tester);
    expect(gesto(tester), 'Tieni premuto per riprendere');
    expect(
        tester
            .widget<Text>(
                find.byKey(const Key('respiro_istruzione_sulla_scena')))
            .data,
        'Hai sollevato il dito: il respiro è fermo');
    await passa(tester, const Duration(seconds: 5));
    expect(luce(tester), luceFerma,
        reason: 'col dito sollevato l\'animazione della Luna non si ferma');
    expect(giro(tester), giroFermo,
        reason: 'col dito sollevato il conteggio non si ferma');
    expect(giroFermo, 'Giro 2 di ${tempi.cicliPerUnMinuto}, fermo');
    await scatta(tester, 'gd23_3_dito_sollevato');

    // E RIPRENDE tenendo premuto di nuovo, dal punto in cui si era fermato.
    final ancora = await tester.startGesture(
        tester.getCenter(find.byKey(const Key('respiro_la_luna_si_tocca'))));
    await passa(tester, const Duration(milliseconds: 500));
    expect(gesto(tester), 'Inspira');
    expect(luce(tester), greaterThan(luceFerma),
        reason: 'premendo di nuovo il respiro non riprende');
    await ancora.up();
    await tester.pump(const Duration(milliseconds: 100));
  });
}
