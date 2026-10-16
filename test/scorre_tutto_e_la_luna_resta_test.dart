import 'package:esoteric_circle/core/lunario/il_dial_a_moon.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/respiro_della_luna/il_respiro_della_luna_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **SCORRE TUTTO, LA LUNA RESTA; MEDORA TORNA COL RESPIRO.** Ordine FY voci
/// FY.04 e FY.05, 16 ottobre 2026. Il fondatore: "Non vogliono riquadro a
/// scorrimento, semplicemente scorre tutto compreso Medora, ma la luna resta
/// sempre presente. Medora torna quando utente fa click su "respiro"".
void main() {
  Future<void> apri(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'respiro.primaAperturaVista': true});
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => MaestroController())],
      child: MaterialApp(
        home: MaestroScope(
          child: IlRespiroDellaLunaScreen(
              now: DateTime(2026, 10, 16, 21),
              dialAMoon: IlDialAMoon(
                  client:
                      MockClient((_) async => http.Response('', 503)))),
        ),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
  }

  double opacitaDellaLunaFissa(WidgetTester tester) => tester
      .widget<AnimatedOpacity>(find
          .ancestor(
              of: find.byKey(const Key('respiro_luna_fissa')),
              matching: find.byType(AnimatedOpacity))
          .first)
      .opacity;

  testWidgets('scorre la schermata intera, Medora compresa, e la Luna resta',
      (tester) async {
    await apri(tester);
    // Nessun riquadro che scorre dentro la schermata: un solo scorrimento,
    // quello della schermata intera, e la scena ci sta dentro.
    expect(find.byType(Scrollable), findsOneWidget,
        reason: 'c\'e\' piu\' di uno scorrimento: un riquadro scorre dentro '
            'la schermata');
    expect(
        find.descendant(
            of: find.byKey(const Key('respiro_tutto_scorre')),
            matching: find.byKey(const Key('respiro_scena'))),
        findsOneWidget,
        reason: 'la scena con Medora non scorre con il resto');
    final primaDellaScena =
        tester.getRect(find.byKey(const Key('respiro_cielo_senza_luna'))).top;
    expect(opacitaDellaLunaFissa(tester), 0,
        reason: 'la Luna fissa in cima si vede gia\' a schermata ferma');

    await tester.drag(
        find.byKey(const Key('respiro_tutto_scorre')), const Offset(0, -600));
    await tester.pump(const Duration(milliseconds: 400));
    final dopo =
        tester.getRect(find.byKey(const Key('respiro_cielo_senza_luna'))).top;
    expect(dopo, lessThan(primaDellaScena - 300),
        reason: 'la scena con Medora non e\' salita con lo scorrimento');
    expect(opacitaDellaLunaFissa(tester), 1,
        reason: 'la scena e\' uscita in alto e la Luna non e\' rimasta');
    final fissa = tester.getRect(find.byKey(const Key('respiro_luna_fissa')));
    expect(fissa.top, greaterThanOrEqualTo(0));
    expect(fissa.bottom, lessThan(200),
        reason: 'la Luna fissa non sta in cima');
  });

  testWidgets('toccando Respiro la scena con Medora torna intera',
      (tester) async {
    await apri(tester);
    await tester.drag(
        find.byKey(const Key('respiro_tutto_scorre')), const Offset(0, -600));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.byKey(const Key('luna_voce_respiro')));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    final scena = tester.getRect(find.byKey(const Key('respiro_scena')));
    expect(scena.top, closeTo(0, 1),
        reason: 'toccando Respiro la scena non e\' tornata in cima');
    final cielo =
        tester.getRect(find.byKey(const Key('respiro_cielo_senza_luna')));
    expect(scena.bottom, greaterThanOrEqualTo(cielo.bottom - 1),
        reason: 'nella voce Respiro la scena non e\' intera: Medora e\' '
            'tagliata in basso');
  });
}
