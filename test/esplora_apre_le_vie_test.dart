import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_screen.dart';
import 'package:esoteric_circle/features/maestri/domain_screen.dart';
import 'package:esoteric_circle/features/passport/cosmic_passport_screen.dart';
import 'package:esoteric_circle/features/shell/app_shell.dart';
import 'package:esoteric_circle/features/shell/esplora.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// LE VOCI DI ESPLORA APRONO DAVVERO, misurato nella chat.
///
/// Nella chat i tocchi sulle voci non aprivano niente. Questa prova non guarda
/// il tocco, guarda la ROTTA: tocca ogni voce e pretende che la schermata in
/// cima alla pila sia cambiata. Un tocco che parte ma non arriva da nessuna
/// parte e' esattamente il difetto, quindi contare i tocchi non basterebbe.
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

  Future<NavigatorState> montaInChat(WidgetTester tester) async {
    silenzia();
    SharedPreferences.setMockInitialValues({'onboarding.done': true});
    tester.view.physicalSize = const Size(1080, 2391);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
        EsotericCircleApp(conIntro: false, services: AppServices.offline()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    final nav = tester.state<NavigatorState>(find.byType(Navigator).last);
    nav.push(MaestroChatScreen.route(
        maestro: Maestro.medora, services: AppServices.offline()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    return nav;
  }

  /// Apre la striscia toccando la linguetta, che e' il gesto vero.
  ///
  /// Le vie stanno sempre nell'albero e rientrano dietro la linguetta con un
  /// movimento continuo: aperta si misura in punti, non contando widget.
  Future<void> apriLaStriscia(WidgetTester tester) async {
    final linguetta = find.byKey(const Key('esplora_linguetta'));
    expect(linguetta, findsOneWidget,
        reason: 'Nella chat la linguetta deve esserci: senza di lei non c\'e\' '
            'nessuna voce da toccare.');
    await tester.tap(linguetta);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    final scesa = tester.getTopLeft(find.byKey(const Key('esplora_vie'))).dy -
        tester.getTopLeft(find.byType(EsploraStriscia)).dy;
    expect(scesa, lessThan(1.0),
        reason: 'Toccando la linguetta le vie devono salire in vista: sono '
            'ancora scese di ${scesa.toStringAsFixed(1)} punti.');
  }

  testWidgets('la voce del Cerchio riporta al Cerchio', (tester) async {
    await montaInChat(tester);
    await apriLaStriscia(tester);

    await tester.tap(find.byKey(const Key('esplora_cerchio')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.byType(MaestroChatScreen, skipOffstage: false), findsNothing,
        reason: 'Toccando Il Cerchio la chat deve essere stata sfilata: la '
            'voce non ha aperto niente.');
    expect(find.byType(AppShell, skipOffstage: false), findsOneWidget,
        reason: 'Dopo Il Cerchio si deve essere sul guscio.');
  });

  testWidgets('la voce del Passport porta al Passport', (tester) async {
    await montaInChat(tester);
    await apriLaStriscia(tester);

    await tester.tap(find.byKey(const Key('esplora_passport')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.byType(MaestroChatScreen, skipOffstage: false), findsNothing,
        reason: 'Toccando il Passport la chat deve essere stata sfilata.');
    expect(find.byType(CosmicPassport, skipOffstage: false), findsOneWidget,
        reason: 'Il Passport e\' una VISTA del guscio: toccandolo il guscio '
            'deve mostrarla, senza spingere una seconda rotta.');
  });

  for (final maestro in Maestro.fixedOrder) {
    testWidgets('la voce di ${maestro.displayName} apre il suo dominio',
        (tester) async {
      await montaInChat(tester);
      await apriLaStriscia(tester);

      await tester.tap(find.byKey(Key('esplora_${maestro.id}')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.byType(DomainScreen, skipOffstage: false), findsOneWidget,
          reason: 'Toccando ${maestro.displayName} il suo dominio non si e\' '
              'aperto: il tocco non arriva, oppure la rotta non viene spinta.');
    });
  }
}
