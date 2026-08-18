import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/features/account/account_screen.dart';
import 'package:esoteric_circle/features/shell/capsula_dell_identita.dart';
import 'package:esoteric_circle/features/shell/navigation_controller.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// LA CAPSULA DELL'IDENTITA' SU OGNI SCHERMATA. Ordine AL voce 08, forma
/// decisa da Mauro.
///
/// **Questa prova SOSTITUISCE la_pillola_e_la_porta_su_ogni_principale, e la
/// grandezza cambia per decisione di Mauro, non per comodo**: la' si
/// pretendeva una copia di pillola e porta per ogni testata principale; il
/// collaudo della 2179 ha deciso la capsula UNICA sopra il Navigator, in
/// alto a destra, col volto sopra e il saldo con la moneta d'oro sotto. Le
/// testate hanno perso le copie: la regola delle due porte vale anche qui.
///
/// Le pretese: la capsula c'e' sulla home, sul Passaporto e sulle rotte
/// spinte sopra (il sentiero, che non ha nemmeno la barra); il volto e il
/// saldo sono UNICI in tutto l'albero; il saldo a quattro cifre si mostra
/// intero senza traboccare; il tocco sul volto apre AccountScreen anche coi
/// doni del giorno sotto, che e' la prova che niente le passa sopra; sulle
/// soglie del Risveglio la capsula non c'e'.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  void silenzia() {
    final m = binding.defaultBinaryMessenger;
    m.setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
        (c) async => null);
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

  Future<void> app(WidgetTester tester,
      {Map<String, Object> prefs = const {
        'onboarding.done': true,
        'santuario.greeted': true,
      }}) async {
    silenzia();
    SharedPreferences.setMockInitialValues(prefs);
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(360, 797);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
        EsotericCircleApp(conIntro: false, services: AppServices.offline()));
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
  }

  testWidgets('la capsula e\' una, sta in alto a destra e porta volto e '
      'saldo unici', (tester) async {
    await app(tester);
    final capsula = find.byKey(const Key('capsula_dell_identita'));
    expect(capsula, findsOneWidget,
        reason: 'la capsula non sta sulla home');
    // UNICITA': il volto e il saldo vivono SOLO nella capsula.
    expect(find.byKey(const Key('porta_dell_account')), findsOneWidget,
        reason: 'il volto ha piu\' di una casa: la regola delle due porte');
    expect(find.byKey(const Key('borsellino')), findsOneWidget,
        reason: 'la pillola ha piu\' di una casa');
    expect(find.byKey(const Key('moneta_eos')), findsOneWidget,
        reason: 'il saldo non porta la moneta d\'oro di Mauro');
    // In alto a destra, dentro la larghezza dichiarata.
    final rettangolo = tester.getRect(capsula);
    expect(rettangolo.right, greaterThan(360 - CapsulaDellIdentita.larghezza),
        reason: 'la capsula non sta al bordo destro');
    expect(rettangolo.top, lessThan(80),
        reason: 'la capsula non sta in alto');
    expect(rettangolo.width, lessThanOrEqualTo(CapsulaDellIdentita.larghezza),
        reason: 'la capsula e\' piu\' larga di quanto dichiara: i doni le '
            'riservano ${CapsulaDellIdentita.larghezza} punti');

    // IL SALDO A QUATTRO CIFRE, intero e senza traboccare.
    tester
        .element(capsula)
        .read<QuestionAllowance>()
        .applicaSaldo(1234);
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }
    expect(find.text('1.234'), findsOneWidget,
        reason: 'il saldo a quattro cifre non si legge intero');
    expect(tester.takeException(), isNull,
        reason: 'il saldo a quattro cifre fa traboccare la capsula');

    // IL TOCCO SUL VOLTO APRE L'ACCOUNT, coi doni del giorno sotto: se
    // qualcosa passasse sopra la capsula, il tocco colpirebbe quello.
    await tester.tap(find.byKey(const Key('porta_dell_account')),
        warnIfMissed: false);
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
    expect(find.byType(AccountScreen), findsOneWidget,
        reason: 'il tocco sul volto non apre l\'account: qualcosa passa '
            'sopra la capsula');
    // E ANCHE SULL'ACCOUNT la capsula resta: e' persistente, non della home.
    expect(find.byKey(const Key('capsula_dell_identita')), findsOneWidget,
        reason: 'la capsula sparisce sulle rotte spinte sopra il guscio');
  });

  testWidgets('la capsula sta anche sul Passaporto e sul sentiero, che non '
      'hanno la loro copia', (tester) async {
    await app(tester);
    tester
        .element(find.byType(Navigator).first)
        .read<NavigationController>()
        .goToPassport();
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
    expect(find.byKey(const Key('capsula_dell_identita')), findsOneWidget,
        reason: 'la capsula non sta sul Passaporto');
    expect(find.byKey(const Key('porta_dell_account')), findsOneWidget,
        reason: 'il Passaporto ha ancora la sua copia della porta');
    expect(find.byKey(const Key('borsellino')), findsOneWidget,
        reason: 'il Passaporto ha ancora la sua copia della pillola');

    // Una rotta spinta sopra, senza barra: il sentiero dalla bolla.
    final bolla = find.byKey(const Key('bolla_dei_traguardi'));
    await tester.scrollUntilVisible(bolla, 200,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(
        find
            .descendant(of: bolla, matching: find.byType(ListTile))
            .first,
        warnIfMissed: false);
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
    expect(find.byKey(const Key('capsula_dell_identita')), findsOneWidget,
        reason: 'la capsula non segue le rotte spinte sopra il guscio');
  });

  testWidgets('sulle soglie del Risveglio la capsula non c\'e\'',
      (tester) async {
    await app(tester, prefs: const {});
    expect(find.byKey(const Key('capsula_dell_identita')), findsNothing,
        reason: 'la capsula sta sopra il rito d\'ingresso, dove la persona '
            'non ha ancora ne\' volto ne\' saldo');
  });
}
