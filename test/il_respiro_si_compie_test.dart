import 'dart:async';

import 'package:esoteric_circle/core/lunario/il_dial_a_moon.dart';
import 'package:esoteric_circle/core/lunario/il_respiro_della_luna.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/permissions/esito_del_permesso.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/respiro_della_luna/il_respiro_della_luna_screen.dart';
import 'package:esoteric_circle/services/breath_detector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **IL RESPIRO SI COMPIE, COL DITO E COL SOFFIO.** Ordine FY voce FY.06, 16
/// ottobre 2026. Il fondatore, sulla build 2312: "Il respiro non funziona ne
/// con microfono né con gesto".
///
/// Due giri interi come una persona, dalla voce Respiro della barra in basso
/// fino alla perla accesa: uno tenendo premuto sulla Luna e lasciando, uno
/// soffiando in un microfono finto. Ognuno pretende che il rito arrivi in
/// fondo ("Respiro compiuto" sulla scena) e che il giorno di oggi risulti
/// respirato, cioe' che la perla di oggi si accenda nella Collana.

/// Un microfono finto: concesso, e soffia quando glielo si dice. Il livello
/// che manda e' quello della misura dell'aria (`soloAria`): uno se passa il
/// fiato, zero se no.
class _MicrofonoFinto extends BreathDetector {
  _MicrofonoFinto() : super(soloAria: true);

  final StreamController<double> _livelli =
      StreamController<double>.broadcast();

  @override
  Stream<double> get level => _livelli.stream;

  @override
  EsitoDelPermesso? get esitoDelPermesso => EsitoDelPermesso.concesso;

  @override
  Future<bool> start() async => true;

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() async {}

  void soffia(double livello) => _livelli.add(livello);
}

IlDialAMoon _offline() =>
    IlDialAMoon(client: MockClient((_) async => http.Response('', 503)));

void main() {
  final adesso = DateTime(2026, 10, 16, 21);
  final tempi = TempiDelRespiroDellaLuna.diOggi(adesso);

  Future<void> apriIlRito(WidgetTester tester,
      {BreathDetector? rilevatore}) async {
    SharedPreferences.setMockInitialValues(
        {'respiro.primaAperturaVista': true});
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => MaestroController())],
      child: MaterialApp(
        home: MaestroScope(
          child: IlRespiroDellaLunaScreen(
              now: adesso, dialAMoon: _offline(), rilevatore: rilevatore),
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

  testWidgets('col dito: tieni premuto e lascia, fino alla perla accesa',
      (tester) async {
    await apriIlRito(tester);
    expect(gestoSullaScena(tester), 'Tieni premuto sulla Luna');
    for (var i = 0; i < tempi.cicliPerUnMinuto; i++) {
      final dito = await tester.startGesture(
          tester.getCenter(find.byKey(const Key('respiro_la_luna_si_tocca'))));
      await tester.pump(const Duration(milliseconds: 50));
      if (i == 0) expect(gestoSullaScena(tester), 'Inspira');
      await tester.pump(tempi.inspiro + const Duration(milliseconds: 100));
      await dito.up();
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(tempi.espiro + const Duration(milliseconds: 100));
    }
    await tester.pump(const Duration(milliseconds: 300));
    expect(gestoSullaScena(tester), 'Respiro compiuto');
    expect(await tester.runAsync(respirato), isTrue,
        reason: 'il respiro col dito non ha acceso la perla di oggi');
  });

  testWidgets('col soffio: il microfono sente il fiato, fino alla perla accesa',
      (tester) async {
    final mic = _MicrofonoFinto();
    await apriIlRito(tester, rilevatore: mic);
    for (var i = 0; i < tempi.cicliPerUnMinuto; i++) {
      // Il soffio: il livello dell'aria a uno per tutto l'inspiro, una
      // volta ogni 200 millisecondi come un microfono vero.
      final passi = tempi.inspiro.inMilliseconds ~/ 200 + 2;
      for (var k = 0; k < passi; k++) {
        mic.soffia(1);
        await tester.pump(const Duration(milliseconds: 200));
      }
      // Smette: passata la grazia del microfono, l'espiro vela la Luna.
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pump(tempi.espiro + const Duration(milliseconds: 200));
    }
    await tester.pump(const Duration(milliseconds: 300));
    expect(gestoSullaScena(tester), 'Respiro compiuto',
        reason: 'il soffio nel microfono non ha compiuto il respiro');
    expect(await tester.runAsync(respirato), isTrue,
        reason: 'il respiro col soffio non ha acceso la perla di oggi');
  });
}
