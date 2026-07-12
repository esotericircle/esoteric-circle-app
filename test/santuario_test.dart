import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/design_system/components/cosmos_background.dart';
import 'package:esoteric_circle/features/santuario/santuario_screen.dart';
import 'package:esoteric_circle/features/santuario/sky_overview_screen.dart';
import 'package:esoteric_circle/features/shell/app_shell.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Rifiniture estetiche del Santuario, blindate.
///
/// Due garanzie: nel Santuario non compare alcuna figura zodiacale nell'angolo
/// in alto a destra (niente riquadro a portale, niente asterismi), e il
/// Santuario, che e' la home, non ha una X di chiusura.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  void silenceSensors() {
    final messenger = binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
      (call) async => null,
    );
    for (final name in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      messenger.setMockStreamHandler(
        EventChannel(name),
        MockStreamHandler.inline(onListen: (args, events) {}),
      );
    }
  }

  Future<void> step(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

  testWidgets(
      'Il Santuario non mostra figure zodiacali nell\'angolo in alto a destra',
      (tester) async {
    silenceSensors();
    await tester.pumpWidget(EsotericCircleApp(services: AppServices.offline()));
    await step(tester);

    // Il Santuario e' montato.
    expect(find.byType(SantuarioScreen), findsOneWidget);

    // Il cosmo che avvolge lo shell non disegna le costellazioni: e' proprio la
    // leva che generava il riquadro a portale con l'asterismo del segno.
    final cosmos = tester.widget<CosmosBackground>(
      find.descendant(
        of: find.byType(AppShell),
        matching: find.byType(CosmosBackground),
      ),
    );
    expect(
      cosmos.showZodiac,
      isFalse,
      reason: 'Nessuna figura zodiacale nel cielo del Santuario, in nessun '
          'angolo. Il segno solare in oro vive solo nel cielo di nascita.',
    );
  });

  testWidgets('Le schede della bottom bar non hanno X ne freccia Indietro',
      (tester) async {
    silenceSensors();
    await tester.pumpWidget(EsotericCircleApp(services: AppServices.offline()));
    await step(tester);

    // Santuario: la home non si chiude, e' il punto di ritorno.
    expect(find.byType(SantuarioScreen), findsOneWidget);
    expect(find.byIcon(Icons.close), findsNothing);
    expect(find.byIcon(Icons.close_rounded), findsNothing);
    expect(find.byIcon(Icons.arrow_back_rounded), findsNothing);

    // Passport: altra scheda della barra, nessun pulsante di chiusura o
    // Indietro. La freccia vive solo sulle schermate spinte (dominio, chat).
    await tester.tap(find.text('Passport'));
    await step(tester);
    expect(find.byIcon(Icons.close), findsNothing);
    expect(find.byIcon(Icons.close_rounded), findsNothing);
    expect(find.byIcon(Icons.arrow_back_rounded), findsNothing);
  });

  testWidgets('Il cielo in alto e\' toccabile e apre la sua schermata',
      (tester) async {
    silenceSensors();
    // Superficie del telefono, cosi' la composizione verticale e' quella
    // reale: il cielo in alto non finisce sotto i busti.
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(EsotericCircleApp(services: AppServices.offline()));
    await step(tester);

    // Tocco sulla zona del cielo e della Luna: apre "Il cielo sopra di te".
    await tester.tap(find.byKey(const Key('santuario_sky_tap')));
    await step(tester);
    await step(tester);
    expect(find.byType(SkyOverviewScreen), findsOneWidget);
    // Ha la sua freccia Indietro: mai un vicolo cieco.
    expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);

    // Indietro torna al Santuario.
    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    await nav.maybePop();
    await step(tester);
    await step(tester);
    expect(find.byType(SkyOverviewScreen), findsNothing);
    expect(find.byType(SantuarioScreen), findsOneWidget);
  });
}
