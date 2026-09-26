import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_screen.dart';
import 'package:esoteric_circle/features/maestri/domain_screen.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **IL PULSANTE "CONSULTA" IN HOME.** Ordine EO voce 08, 26 settembre 2026.
///
/// Il fondatore: *"Meglio il tuo pulsante in alto ma sotto il pulsante
/// "entra nel dominio" perche' c'e' spazio."* e *"No, il click sul maestro
/// apre il dominio."*
///
/// **Lo spazio sotto l'abbiamo misurato, e sul formato del suo telefono non
/// c'e'.** Il blocco d'ingresso cresce verso l'alto: il secondo pulsante
/// prende 44 punti al busto, e la suite intera ha visto cadere tre guardie
/// dei Maestri (busto centrale da oltre 260 a 245, Maestri dal 30 al 28 per
/// cento della prima schermata). Quindi "Consulta" sta **sotto** dove sotto
/// il busto non perde niente, e **accanto a "Entra", in tondo**, dove sotto
/// costerebbe punti ai Maestri. Qui si provano le due scene, e in tutte e due
/// che porti il nome del Maestro davanti, che apra la sua chat e che il tocco
/// sul Maestro apra ancora il dominio.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  /// Il formato del telefono del fondatore, e uno schermo molto alto dove lo
  /// spazio sotto c'e' (misurati con la sonda dell'ordine EO: "accanto" fino
  /// a 430 per 932, "sotto" a 480 per 1067).
  const telefonoDelFondatore = Size(1080, 2392);
  const schermoAlto = Size(1440, 3200);

  Future<void> monta(WidgetTester tester,
      {Size dimensione = telefonoDelFondatore, double scala = 1}) async {
    final messenger = binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
        (call) async => null);
    for (final nome in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      messenger.setMockStreamHandler(EventChannel(nome),
          MockStreamHandler.inline(onListen: (args, events) {}));
    }
    SharedPreferences.setMockInitialValues({'onboarding.done': true});
    tester.view.physicalSize = dimensione;
    tester.view.devicePixelRatio = 3.0;
    tester.platformDispatcher.textScaleFactorTestValue = scala;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(
        EsotericCircleApp(conIntro: false, services: AppServices.offline()));
    await tester.pump();
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
  }

  /// Il Maestro che sta davanti, letto dal pulsante del dominio.
  Maestro davanti(WidgetTester tester) {
    for (final m in Maestro.values) {
      if (find
          .text('Entra nel Dominio di ${m.displayName}')
          .evaluate()
          .isNotEmpty) {
        return m;
      }
    }
    throw StateError('nessun pulsante del dominio a video');
  }

  Future<void> aspetta(WidgetTester tester) async {
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Future<void> apreLaChat(WidgetTester tester, Maestro m) async {
    await tester.tap(find.byKey(const Key('santuario_consulta')));
    await aspetta(tester);
    final chat = find.byType(MaestroChatScreen);
    expect(chat, findsOneWidget, reason: '"Consulta" non apre la chat');
    expect(tester.widget<MaestroChatScreen>(chat).maestro, m,
        reason: 'la chat aperta non e\' quella del Maestro davanti');
    expect(find.byType(DomainScreen), findsNothing,
        reason: '"Consulta" deve aprire la chat, non il dominio');
  }

  testWidgets(
      'EO.08: sul telefono del fondatore "Consulta" sta accanto a "Entra", in '
      'tondo, dice il suo nome alla voce e apre la chat', (tester) async {
    await monta(tester);
    final m = davanti(tester);
    final entra =
        tester.getRect(find.byKey(const Key('santuario_enter_domain')));
    final consulta = find.byKey(const Key('santuario_consulta'));
    expect(consulta, findsOneWidget, reason: 'in home non c\'e\' "Consulta"');
    final tondo = tester.getRect(consulta);
    // ignore: avoid_print
    print('EO.08 MISURA telefono del fondatore: "Entra" '
        '${entra.left.toStringAsFixed(1)}-${entra.right.toStringAsFixed(1)}, '
        '"Consulta" ${tondo.left.toStringAsFixed(1)}-'
        '${tondo.right.toStringAsFixed(1)}, alto ${tondo.height}');
    expect(tondo.left, greaterThanOrEqualTo(entra.right),
        reason: 'dove sotto non c\'e\' spazio, "Consulta" sta accanto');
    expect((tondo.center.dy - entra.center.dy).abs(), lessThan(3));
    expect(tondo.height, greaterThanOrEqualTo(44),
        reason: 'il tondo deve restare toccabile');
    expect(find.bySemanticsLabel('Consulta ${m.displayName}'), findsOneWidget,
        reason: 'il tondo senza parole deve dire il suo nome alla voce');
    await apreLaChat(tester, m);
  });

  testWidgets(
      'EO.08: dove lo spazio c\'e\', "Consulta" sta sotto "Entra", col nome del '
      'Maestro, e apre la chat', (tester) async {
    await monta(tester, dimensione: schermoAlto);
    final m = davanti(tester);
    final consulta = find.byKey(const Key('santuario_consulta'));
    expect(
        find.descendant(
            of: consulta, matching: find.text('Consulta ${m.displayName}')),
        findsOneWidget,
        reason: 'sotto, il pulsante porta il nome del Maestro davanti');
    final entra =
        tester.getRect(find.byKey(const Key('santuario_enter_domain')));
    final sotto = tester.getRect(consulta);
    // ignore: avoid_print
    print('EO.08 MISURA schermo alto: "Entra" ${entra.top.toStringAsFixed(1)}-'
        '${entra.bottom.toStringAsFixed(1)}, "Consulta" '
        '${sotto.top.toStringAsFixed(1)}-${sotto.bottom.toStringAsFixed(1)}');
    expect(sotto.top, greaterThanOrEqualTo(entra.bottom),
        reason: 'dove lo spazio c\'e\', "Consulta" sta SOTTO "Entra"');
    expect((sotto.center.dx - entra.center.dx).abs(), lessThan(1),
        reason: 'i due pulsanti devono stare in colonna, centrati');
    await apreLaChat(tester, m);
  });

  testWidgets('EO.08: girato il cerchio, "Consulta" cambia col Maestro',
      (tester) async {
    await monta(tester);
    final prima = davanti(tester);
    await tester.tap(find.byKey(const Key('santuario_side_right')));
    await aspetta(tester);
    final dopo = davanti(tester);
    expect(dopo, isNot(prima), reason: 'il cerchio non ha girato');
    expect(
        find.bySemanticsLabel('Consulta ${dopo.displayName}'), findsOneWidget,
        reason: 'girato il cerchio, "Consulta" dice ancora ${prima.name}');
  });

  testWidgets('EO.08: il tocco sul Maestro apre ancora il dominio',
      (tester) async {
    await monta(tester);
    final m = davanti(tester);
    await tester.tap(find.byKey(const Key('santuario_central_bust')));
    await aspetta(tester);
    expect(find.byType(DomainScreen), findsOneWidget,
        reason: 'il tocco sul Maestro non apre piu\' il dominio');
    expect(find.byType(MaestroChatScreen), findsNothing);
    expect(tester.widget<DomainScreen>(find.byType(DomainScreen)).maestro, m);
  });

  testWidgets('EO.08: col testo grande "Consulta" sta accanto, in tondo',
      (tester) async {
    await monta(tester, scala: 1.6);
    final entra =
        tester.getRect(find.byKey(const Key('santuario_enter_domain')));
    final tondo = tester.getRect(find.byKey(const Key('santuario_consulta')));
    expect(tondo.left, greaterThanOrEqualTo(entra.right),
        reason: 'col testo grande sul telefono del fondatore sotto non ci '
            'sta');
  });
}
