import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_screen.dart';
import 'package:esoteric_circle/features/maestri/chat/widgets/la_porta_del_vivo.dart';
import 'package:esoteric_circle/features/shell/barra_del_cerchio.dart';
import 'package:esoteric_circle/features/shell/santuario_bottom_bar.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **LA BARRA CHE SI NASCONDE E LA PASTIGLIA "DAL VIVO".** Ordine EJ voci 09
/// e 10, 25 settembre 2026.
///
/// Voce 09, il fondatore: *"le chat dei maestri partono all'apertura della
/// schermata con il menù sotto ESPLORA visibile e non mi piace, occupa spazio
/// inutile"*. Voce 10: *"vorrei un pulsante in bella vista grigio se non hai
/// abbonamento almeno tier 2 con avviso elegante"*.
///
/// Si monta l'app intera, perche' la barra sta sopra il Navigator e una chat
/// montata da sola non la vedrebbe. Si prova su tutti e tre i Maestri.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  void silenzia() {
    final messenger = binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
      (call) async => null,
    );
    for (final nome in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      messenger.setMockStreamHandler(
        EventChannel(nome),
        MockStreamHandler.inline(onListen: (args, events) {}),
      );
    }
  }

  const schermo = Size(390, 844);

  Future<NavigatorState> monta(WidgetTester tester) async {
    silenzia();
    SharedPreferences.setMockInitialValues({'onboarding.done': true});
    tester.view.physicalSize = schermo * 3;
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
        EsotericCircleApp(conIntro: false, services: AppServices.offline()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    return tester.state<NavigatorState>(find.byType(Navigator).last);
  }

  Future<void> apriLaChat(
      WidgetTester tester, NavigatorState nav, Maestro m) async {
    nav.push(
        MaestroChatScreen.route(maestro: m, services: AppServices.offline()));
    // Piu' fotogrammi: la barra si ritira con un'animazione che parte nel
    // fotogramma dopo l'apertura, e uno solo la vedrebbe ancora ferma.
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }
  }

  double cimaDiEsplora(WidgetTester tester) =>
      tester.getRect(find.byKey(const Key('barra_titolo'))).top;

  Rect ilCampo(WidgetTester tester) =>
      tester.getRect(find.byType(TextField).first);

  /// Il dito scende sulla conversazione: si va verso i messaggi di prima.
  Future<void> scorriIndietro(WidgetTester tester) async {
    final gesto = await tester.startGesture(const Offset(195, 400));
    await gesto.moveBy(const Offset(0, kDragSlopDefault));
    await tester.pump();
    for (var i = 0; i < 8; i++) {
      await gesto.moveBy(const Offset(0, BarraDelCerchio.corsa / 6));
      await tester.pump();
    }
    await gesto.up();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  group('EJ.09 la barra nella chat', () {
    testWidgets('nella home la barra resta in vista all\'apertura',
        (tester) async {
      await monta(tester);
      expect(cimaDiEsplora(tester), lessThan(schermo.height - 60),
          reason: 'la voce 09 vale solo nelle chat: la home non si tocca');
    });

    for (final m in Maestro.values) {
      testWidgets(
          '${m.displayName}: si apre nascosta, compare scorrendo, si ritira '
          'toccando il campo', (tester) async {
        final nav = await monta(tester);
        await apriLaChat(tester, nav, m);

        // All'apertura la barra e' sotto lo schermo, e il campo sta in fondo.
        expect(cimaDiEsplora(tester), greaterThanOrEqualTo(schermo.height - 1),
            reason: 'all\'apertura della chat di ${m.displayName} la barra '
                'Esplora si vede ancora');
        final campoAllApertura = ilCampo(tester);

        // Scorrendo verso i messaggi di prima la barra compare.
        await scorriIndietro(tester);
        final cima = cimaDiEsplora(tester);
        expect(
            cima, lessThan(schermo.height - SantuarioBottomBar.altezzaResa / 2),
            reason: 'scorrendo la barra non e\' comparsa');
        final campoConLaBarra = ilCampo(tester);
        final guadagnati = campoConLaBarra.top - campoAllApertura.top;
        // ignore: avoid_print
        print(
            'EJ.09 ${m.displayName}: campo a ${campoAllApertura.top.toStringAsFixed(1)} '
            'all\'apertura, a ${campoConLaBarra.top.toStringAsFixed(1)} con la '
            'barra: la conversazione guadagna ${(-guadagnati).toStringAsFixed(1)} '
            'punti');
        expect(-guadagnati, greaterThan(SantuarioBottomBar.altezzaResa - 2),
            reason: 'la conversazione non ha guadagnato lo spazio della barra');

        // Toccando il campo la barra si ritira.
        await tester.tap(find.byType(TextField).first);
        for (var i = 0; i < 4; i++) {
          await tester.pump(const Duration(milliseconds: 150));
        }
        expect(cimaDiEsplora(tester), greaterThanOrEqualTo(schermo.height - 1),
            reason: 'chi comincia a scrivere ha ancora la barra davanti');
      });
    }
  });

  group('EJ.10 la pastiglia "Dal vivo"', () {
    for (final m in Maestro.values) {
      testWidgets(
          '${m.displayName}: grigia col lucchetto, apre il foglio del '
          'Maestro', (tester) async {
        final nav = await monta(tester);
        await apriLaChat(tester, nav, m);
        final chiusa = find.byKey(const Key('chat_dal_vivo_chiusa'));
        expect(chiusa, findsOneWidget,
            reason: 'il Viandante deve vedere la pastiglia grigia');
        expect(
            find.descendant(
                of: chiusa, matching: find.byIcon(Icons.lock_rounded)),
            findsOneWidget);

        // Non copre il nome ne' le arti.
        final pastiglia = tester.getRect(chiusa);
        final nome =
            tester.getRect(find.byKey(const Key('chat_nome_del_maestro')));
        expect(pastiglia.overlaps(nome), isFalse,
            reason: 'la pastiglia copre il nome del Maestro');
        expect(pastiglia.left, greaterThanOrEqualTo(nome.right),
            reason: 'la pastiglia sta sopra il nome');

        // Non si muove quando si scorre.
        await scorriIndietro(tester);
        expect(tester.getRect(chiusa), pastiglia,
            reason: 'la pastiglia si e\' mossa scorrendo');

        await tester.tap(chiusa);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 600));
        expect(find.byKey(const Key('chat_foglio_dal_vivo')), findsOneWidget,
            reason: 'il tocco sulla pastiglia grigia non apre il foglio');
        expect(find.text(IlFoglioDelVivo.parole(m)), findsOneWidget);
        expect(
            find.byKey(const Key('chat_foglio_dal_vivo_piani')), findsOneWidget,
            reason: 'il foglio deve portare ai piani: mai un vicolo cieco');
        await tester.tap(find.byKey(const Key('chat_foglio_dal_vivo_non_ora')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 600));
        expect(find.byKey(const Key('chat_foglio_dal_vivo')), findsNothing);
      });
    }

    testWidgets('dal tier 2 in su e\' d\'oro, sotto no', (tester) async {
      final nav = await monta(tester);
      await apriLaChat(tester, nav, Maestro.medora);
      final servizio = tester
          .element(find.byType(MaestroChatScreen))
          .read<EntitlementService>();
      for (final t in Tier.values) {
        servizio.setTier(t);
        await tester.pump();
        final aperta = t.level >= 2;
        expect(find.byKey(const Key('chat_dal_vivo_aperta')),
            aperta ? findsOneWidget : findsNothing,
            reason: '${t.label}: la pastiglia dovrebbe essere '
                '${aperta ? 'd\'oro' : 'grigia'}');
      }
      servizio.setTier(Tier.free);
      await tester.pump();
    });

    test('le parole dei tre Maestri sono tre, e portano al piano', () {
      final parole = {
        for (final m in Maestro.values) IlFoglioDelVivo.parole(m)
      };
      expect(parole, hasLength(3));
      for (final p in parole) {
        expect(p, contains('Adepto'));
        expect(p, isNot(contains('—')), reason: 'trattino lungo');
        expect(p.toLowerCase(), isNot(contains('errore')));
      }
    });
  });
}
