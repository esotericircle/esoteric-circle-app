import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_screen.dart';
import 'package:esoteric_circle/features/maestri/domain_screen.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **IL PULSANTE "CONSULTA" SOTTO "ENTRA NEL DOMINIO".** Ordine EO voce 08,
/// 26 settembre 2026.
///
/// Il fondatore: *"Meglio il tuo pulsante in alto ma sotto il pulsante
/// "entra nel dominio" perche' c'e' spazio."* e *"No, il click sul maestro
/// apre il dominio."* Si misura sull'app intera: il pulsante c'e', sta sotto,
/// porta il nome del Maestro che sta davanti e cambia con lui, apre la chat
/// di quel Maestro; il tocco sul Maestro apre ancora il dominio.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> monta(WidgetTester tester, {double scala = 1}) async {
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
    tester.view.physicalSize = const Size(1080, 2392);
    tester.view.devicePixelRatio = 3.0;
    tester.platformDispatcher.textScaleFactorTestValue = scala;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(
        EsotericCircleApp(conIntro: false, services: AppServices.offline()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
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

  testWidgets(
      'EO.08: "Consulta" sta sotto "Entra", porta il nome del Maestro davanti '
      'e apre la sua chat', (tester) async {
    await monta(tester);
    final m = davanti(tester);
    final consulta = find.byKey(const Key('santuario_consulta'));
    expect(consulta, findsOneWidget, reason: 'in home non c\'e\' "Consulta"');
    expect(
        find.descendant(
            of: consulta, matching: find.text('Consulta ${m.displayName}')),
        findsOneWidget,
        reason: 'il pulsante non porta il nome del Maestro che sta davanti');
    final entra =
        tester.getRect(find.byKey(const Key('santuario_enter_domain')));
    final sotto = tester.getRect(consulta);
    // ignore: avoid_print
    print('EO.08 MISURA: "Entra" ${entra.top.toStringAsFixed(1)}-'
        '${entra.bottom.toStringAsFixed(1)}, "Consulta" '
        '${sotto.top.toStringAsFixed(1)}-${sotto.bottom.toStringAsFixed(1)}');
    expect(sotto.top, greaterThanOrEqualTo(entra.bottom),
        reason: '"Consulta" deve stare SOTTO "Entra nel Dominio"');
    expect((sotto.center.dx - entra.center.dx).abs(), lessThan(1),
        reason: 'i due pulsanti devono stare in colonna, centrati');

    await tester.tap(consulta);
    await aspetta(tester);
    final chat = find.byType(MaestroChatScreen);
    expect(chat, findsOneWidget, reason: '"Consulta" non apre la chat');
    expect(tester.widget<MaestroChatScreen>(chat).maestro, m,
        reason: 'la chat aperta non e\' quella del Maestro davanti');
    expect(find.byType(DomainScreen), findsNothing,
        reason: '"Consulta" deve aprire la chat, non il dominio');
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
        find.descendant(
            of: find.byKey(const Key('santuario_consulta')),
            matching: find.text('Consulta ${dopo.displayName}')),
        findsOneWidget,
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

  testWidgets(
      'EO.08: col testo grande "Consulta" sta accanto, in tondo, e si legge '
      'con la voce', (tester) async {
    await monta(tester, scala: 1.6);
    final m = davanti(tester);
    final consulta = find.byKey(const Key('santuario_consulta'));
    expect(consulta, findsOneWidget);
    final entra =
        tester.getRect(find.byKey(const Key('santuario_enter_domain')));
    final tondo = tester.getRect(consulta);
    expect(tondo.left, greaterThanOrEqualTo(entra.right),
        reason: 'col testo grande il tondo deve stare accanto a "Entra"');
    expect((tondo.center.dy - entra.center.dy).abs(), lessThan(3));
    expect(find.bySemanticsLabel('Consulta ${m.displayName}'), findsOneWidget,
        reason: 'il tondo senza parole deve dire il suo nome alla voce');
  });
}
