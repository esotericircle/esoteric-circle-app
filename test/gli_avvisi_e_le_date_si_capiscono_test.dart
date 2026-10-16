import 'package:esoteric_circle/core/lunario/il_dial_a_moon.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/design_system/components/interruttore_del_cerchio.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/respiro_della_luna/i_pezzi_della_consultazione.dart';
import 'package:esoteric_circle/features/respiro_della_luna/il_respiro_della_luna_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **GLI AVVISI DETTI CHIARI, LE DATE INTERE.** Ordine FY voci FY.09 e FY.22,
/// 16 ottobre 2026.
///
/// FY.09, il fondatore: "gli avvisi della luna non si capisce a cosa
/// servono". Ogni interruttore dice in una riga che cosa arriva e quando.
///
/// FY.22, l'Architetto sulla cattura del fondatore: le date sotto il
/// righello del Respiro sono tagliate ai lati ("venerdi'" a sinistra). Ogni
/// data a schermo sta tutta dentro lo schermo, a ogni larghezza.
void main() {
  testWidgets('ogni avviso dice che cosa arriva e quando', (tester) async {
    SharedPreferences.setMockInitialValues(
        {'respiro.primaAperturaVista': true});
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => MaestroController())],
      child: MaterialApp(
        // Il pavimento dei fogli, come nell'app (ordine AL voce 04): lo scope
        // sopra il Navigator, perche' il foglio degli avvisi e' una rotta.
        builder: (c, figlio) => MaestroScope(child: figlio!),
        home: MaestroScope(
          child: IlRespiroDellaLunaScreen(
              now: DateTime(2026, 10, 16, 21),
              dialAMoon: IlDialAMoon(
                  client: MockClient((_) async => http.Response('', 503)))),
        ),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.scrollUntilVisible(
        find.byKey(const Key('respiro_apri_avvisi')), 200,
        scrollable: find.byType(Scrollable).first);
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -200));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const Key('respiro_apri_avvisi')));
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    final interruttori = tester.widgetList<InterruttoreDelCerchio>(
        find.byType(InterruttoreDelCerchio));
    expect(interruttori.length, 2);
    final senzaSpiegazione = [
      for (final i in interruttori)
        if (!(i.sottotitolo ?? '').startsWith('Ti avviso ')) i.titolo,
    ];
    expect(senzaSpiegazione, isEmpty,
        reason: 'avvisi che non dicono che cosa arriva e quando: '
            '$senzaSpiegazione');
    expect(find.byKey(const Key('respiro_avvisi_spiegati')), findsOneWidget);
  });

  for (final larghezza in const [320.0, 360.0, 390.0, 430.0]) {
    testWidgets('le date sotto il righello stanno intere, $larghezza punti',
        (tester) async {
      tester.view.physicalSize = Size(larghezza, 300);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      final tagliate = <String>[];
      var viste = 0;
      // Il tempo scorre lungo un giorno intero, ogni due ore: le date
      // passano da un bordo all'altro.
      for (var ora = 0; ora < 24; ora += 2) {
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: IlRighelloDelTempo(
                tempoVisto: DateTime(2026, 10, 16, ora), onTrascina: (_) {}),
          ),
        ));
        for (final e in find
            .descendant(
                of: find.byType(IlRighelloDelTempo),
                matching: find.byType(RichText))
            .evaluate()) {
          final r = tester.getRect(find.byWidget(e.widget));
          viste++;
          if (r.left < -0.5 || r.right > larghezza + 0.5) {
            tagliate.add('ore $ora: ${r.left.toStringAsFixed(0)}-'
                '${r.right.toStringAsFixed(0)}');
          }
        }
      }
      expect(viste, greaterThan(5),
          reason: 'nessuna data guardata: la prova non misura niente');
      expect(tagliate, isEmpty, reason: 'date tagliate ai lati: $tagliate');
    });
  }
}
