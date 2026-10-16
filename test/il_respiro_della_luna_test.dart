import 'package:esoteric_circle/core/lunario/il_dial_a_moon.dart';
import 'package:esoteric_circle/core/lunario/il_giorno_lunare.dart';
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

/// **MAI UNA CHIAMATA DI RETE VERA IN PROVA.** La schermata chiede la Luna
/// vera al Dial-A-Moon (FX.03): questo client finto fallisce sempre e
/// subito, cosi' la prova resta offline e deterministica e cade subito sul
/// ripiego locale (`LeLuneDellaNasa`), come fa `test/il_dial_a_moon_test.dart`
/// per la stessa classe.
IlDialAMoon _dialAMoonOffline() =>
    IlDialAMoon(client: MockClient((request) async => http.Response('', 503)));

/// **IL RESPIRO DELLA LUNA.** Ordine FX voce FX.04, 16 ottobre 2026.
///
/// Prova i tempi accordati alla fase (la scelta e' dichiarata e motivata in
/// `TempiDelRespiroDellaLuna`), il flag "respirato oggi" che persiste sul
/// telefono ed e' idempotente, e che la schermata vera risponde al gesto
/// doppio (il dito tenuto giu' accende la Luna, come farebbe il microfono).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('I tempi del Respiro della Luna, accordati alla fase', () {
    test('alla crescente l\'inspiro dura piu\' dell\'espiro', () {
      for (final fase in [
        FaseLunare.crescente,
        FaseLunare.primoQuarto,
        FaseLunare.gibbosaCrescente,
      ]) {
        final t = TempiDelRespiroDellaLuna.perFase(fase);
        expect(t.inspiro, const Duration(seconds: 5), reason: '$fase');
        expect(t.espiro, const Duration(seconds: 3), reason: '$fase');
      }
    });

    test('alla calante l\'espiro dura piu\' dell\'inspiro', () {
      for (final fase in [
        FaseLunare.gibbosaCalante,
        FaseLunare.ultimoQuarto,
        FaseLunare.calante,
      ]) {
        final t = TempiDelRespiroDellaLuna.perFase(fase);
        expect(t.inspiro, const Duration(seconds: 3), reason: '$fase');
        expect(t.espiro, const Duration(seconds: 5), reason: '$fase');
      }
    });

    test('alle due sizigie i due tempi pesano uguale', () {
      for (final fase in [FaseLunare.nuova, FaseLunare.piena]) {
        final t = TempiDelRespiroDellaLuna.perFase(fase);
        expect(t.inspiro, t.espiro, reason: '$fase');
        expect(t.inspiro, const Duration(seconds: 4));
      }
    });

    test('il rito intero resta vicino a un minuto, a cicli interi', () {
      for (final fase in FaseLunare.values) {
        final t = TempiDelRespiroDellaLuna.perFase(fase);
        expect(t.reggono, isTrue, reason: '$fase');
        expect(t.cicliPerUnMinuto, greaterThan(0), reason: '$fase');
        final scarto = (t.interoRito.inSeconds - 60).abs();
        expect(scarto, lessThanOrEqualTo(t.ciclo.inSeconds),
            reason: 'il rito di $fase dura ${t.interoRito.inSeconds}s, '
                'troppo lontano da un minuto');
      }
    });
  });

  group('I giorni respirati, persistiti e idempotenti', () {
    test('un giorno respirato si ricorda, e rifarlo non duplica niente',
        () async {
      SharedPreferences.setMockInitialValues({});
      final flag = IlRespiroDellaLuna();
      await flag.leggi();
      final oggi = DateTime(2026, 10, 16);
      expect(flag.eRespirato(oggi), isFalse);

      await flag.segnaRespirato(oggi);
      expect(flag.eRespirato(oggi), isTrue);
      expect(flag.giorni.length, 1);

      // Rifare il rito lo stesso giorno non accende una seconda perla.
      await flag.segnaRespirato(oggi);
      expect(flag.giorni.length, 1,
          reason: 'segnaRespirato non e\' idempotente');
    });

    test('il flag sopravvive a una nuova lettura, come lo troverebbe FX.05',
        () async {
      SharedPreferences.setMockInitialValues({});
      final primo = IlRespiroDellaLuna();
      await primo.leggi();
      await primo.segnaRespirato(DateTime(2026, 10, 10));

      final secondo = IlRespiroDellaLuna();
      await secondo.leggi();
      expect(secondo.eRespirato(DateTime(2026, 10, 10)), isTrue);
      expect(secondo.eRespirato(DateTime(2026, 10, 11)), isFalse);
    });
  });

  group('La schermata vera', () {
    Widget host(Widget scena) => MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => MaestroController()),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            home: MaestroScope(child: scena),
          ),
        );

    testWidgets(
        'risponde al dito: tenuto giu\' accende la Luna, lasciato la vela',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final adesso = DateTime(2026, 10, 16, 12);
      final tempi = TempiDelRespiroDellaLuna.diOggi(adesso);

      await tester.pumpWidget(host(IlRespiroDellaLunaScreen(
          now: adesso, dialAMoon: _dialAMoonOffline())));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(seconds: 2));

      expect(find.text('Il Respiro della Luna'), findsOneWidget);
      expect(find.byKey(const Key('respiro_luna_vera')), findsOneWidget);

      // **IL RITO SI APRE DALLA SUA VOCE** (FXA.09): la schermata si apre
      // sulla Luna da consultare, il respiro sta nella voce Respiro della
      // barra in basso.
      await tester.tap(find.byKey(const Key('luna_voce_respiro')));
      await tester.pump(const Duration(milliseconds: 100));

      // L'opacita' piu' vicina alla foto: quella che segue il respiro (piu'
      // in alto c'e' la comparsa della scena, FXA.08).
      double opacitaDellaLuna() => tester
          .widget<Opacity>(find
              .ancestor(
                of: find.byKey(const Key('respiro_luna_vera')),
                matching: find.byType(Opacity),
              )
              .first)
          .opacity;

      final veloAllInizio = opacitaDellaLuna();

      // IL GESTO: si tiene premuto sulla Luna per inspirare.
      final dito = await tester.startGesture(tester.getCenter(find.byKey(
        const Key('respiro_luna_vera'),
      )));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(tempi.inspiro);

      final luceAlCulmine = opacitaDellaLuna();
      expect(luceAlCulmine, greaterThan(veloAllInizio),
          reason: 'la Luna non si e\' accesa tenendo premuto il dito');

      // Si lascia: l'espiro vela la Luna di nuovo, e un giro si completa.
      await dito.up();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(tempi.espiro);

      final veloDopoUnGiro = opacitaDellaLuna();
      expect(veloDopoUnGiro, lessThan(luceAlCulmine),
          reason: 'la Luna non si e\' velata lasciando il dito');

      if (tempi.cicliPerUnMinuto > 1) {
        // Il giro si legge sulla scena, sotto la Luna (ordine FY voce FY.06).
        expect(
            tester.widget<Text>(find.byKey(const Key('respiro_giro'))).data,
            startsWith('Giro 2 di'),
            reason: 'un giro intero (inspiro piu\' espiro) non ha fatto '
                'avanzare il conteggio');
      }
    });
  });
}
