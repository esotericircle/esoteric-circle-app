import 'package:esoteric_circle/core/lunario/il_dial_a_moon.dart';
import 'package:esoteric_circle/core/lunario/il_respiro_della_luna.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/respiro_della_luna/il_respiro_della_luna_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **IL RESPIRO SI COMPIE, COL DITO.** Ordine FY voce FY.06, 16 ottobre
/// 2026. Il fondatore, sulla build 2312: "Il respiro non funziona ne con
/// microfono né con gesto".
///
/// **RISCRITTA DALL'ORDINE GD VOCE GD.23, 23 ottobre 2026, non allentata.**
/// Il fondatore: *"elimina il microfono e lascia solo «tieni premuto per
/// inspirare e per espirare». Se l'utente solleva il dito, l'animazione e
/// conteggio si fermano, ma può riprenderlo tenendo premuto"*. La prova del
/// soffio in un microfono finto misurava un gesto che non esiste piu': al
/// suo posto la prova del dito che si solleva a meta' e riprende. Il dito
/// non si lascia piu' per espirare: tenuto sulla Luna, il rito fa da solo
/// inspiro ed espiro.
///
/// Due giri interi come una persona, dalla voce Respiro della barra in basso
/// fino alla perla accesa: uno col dito sempre sulla Luna, uno sollevandolo
/// a ogni giro e riprendendo. Ognuno pretende che il rito arrivi in fondo
/// ("Respiro compiuto" sulla scena) e che il giorno di oggi risulti
/// respirato, cioe' che la perla di oggi si accenda nella Collana.

IlDialAMoon _offline() =>
    IlDialAMoon(client: MockClient((_) async => http.Response('', 503)));

void main() {
  final adesso = DateTime(2026, 10, 16, 21);
  final tempi = TempiDelRespiroDellaLuna.diOggi(adesso);

  Future<void> apriIlRito(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(
        {'respiro.primaAperturaVista': true});
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => MaestroController())],
      child: MaterialApp(
        home: MaestroScope(
          child: IlRespiroDellaLunaScreen(now: adesso, dialAMoon: _offline()),
        ),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.tap(find.byKey(const Key('luna_voce_respiro')));
    await tester.pump(const Duration(milliseconds: 600));
  }

  Future<bool> respirato() async {
    final r = IlRespiroDellaLuna();
    await r.leggi();
    return r.eRespirato(adesso);
  }

  String gestoSullaScena(WidgetTester tester) => tester
      .widget<Text>(find.byKey(const Key('respiro_gesto_del_momento')))
      .data!;

  Future<void> passa(WidgetTester tester, Duration d) async {
    for (var i = 0; i < d.inMilliseconds ~/ 50; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  Finder luna() => find.byKey(const Key('respiro_la_luna_si_tocca'));

  testWidgets('col dito sempre premuto, fino alla perla accesa',
      (tester) async {
    await apriIlRito(tester);
    expect(gestoSullaScena(tester), 'Tieni premuto sulla Luna');
    final dito = await tester.startGesture(tester.getCenter(luna()));
    await tester.pump(const Duration(milliseconds: 50));
    expect(gestoSullaScena(tester), 'Inspira');
    await passa(tester,
        tempi.ciclo * tempi.cicliPerUnMinuto + const Duration(seconds: 1));
    expect(gestoSullaScena(tester), 'Respiro compiuto');
    await dito.up();
    await tester.pump(const Duration(milliseconds: 300));
    expect(await tester.runAsync(respirato), isTrue,
        reason: 'il respiro col dito non ha acceso la perla di oggi');
  });

  testWidgets(
      'sollevando il dito a ogni giro il rito si ferma, riprende e arriva '
      'alla perla', (tester) async {
    await apriIlRito(tester);
    for (var i = 0; i < tempi.cicliPerUnMinuto; i++) {
      // Meta' giro col dito, poi il dito si solleva per due secondi.
      var dito = await tester.startGesture(tester.getCenter(luna()));
      await passa(tester, tempi.ciclo ~/ 2);
      await dito.up();
      await passa(tester, const Duration(seconds: 2));
      if (i == 0) {
        expect(gestoSullaScena(tester), 'Tieni premuto per riprendere');
      }
      // L'altra meta' del giro, col dito di nuovo sulla Luna.
      dito = await tester.startGesture(tester.getCenter(luna()));
      await passa(tester, tempi.ciclo ~/ 2 + const Duration(milliseconds: 200));
      await dito.up();
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.pump(const Duration(milliseconds: 300));
    expect(gestoSullaScena(tester), 'Respiro compiuto',
        reason: 'col dito sollevato e ripreso il respiro non si compie');
    expect(await tester.runAsync(respirato), isTrue,
        reason: 'il respiro ripreso non ha acceso la perla di oggi');
  });
}
