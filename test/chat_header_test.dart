import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/design_system/components/cosmos_background.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_screen.dart';
import 'package:esoteric_circle/features/shell/app_shell.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// Anti-regressione dell'header della chat.
///
/// In passato il "rettangolo a portale", la costellazione quadrata in alto a
/// destra, e' stato rimosso piu' volte e continuava a tornare. Nella chat il
/// cosmo di sfondo non deve disegnare alcuna costellazione, cosi' quella forma
/// non puo' ricomparire dietro l'header. Questo test lo blinda: se qualcuno
/// riattiva le costellazioni nella chat, il test fallisce.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  // In headless i sensori non esistono: si silenziano per evitare l'eccezione
  // asincrona della parallasse.
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
    await tester.pump(const Duration(milliseconds: 400));
  }

  Future<void> openMedoraChat(WidgetTester tester) async {
    await tester.pumpWidget(EsotericCircleApp(services: AppServices.offline()));
    await step(tester);
    final ctx = tester.element(find.byType(MaterialApp));
    ctx.read<MaestroController>().selectMaestro(Maestro.medora);
    await step(tester);
    await tester.tap(find.text('Parla con Medora'));
    await step(tester);
  }

  testWidgets('Il cosmo della chat non disegna costellazioni nell\'header',
      (tester) async {
    silenceSensors();
    await openMedoraChat(tester);

    final chatCosmos = tester.widget<CosmosBackground>(
      find.descendant(
        of: find.byType(MaestroChatScreen),
        matching: find.byType(CosmosBackground),
      ),
    );
    expect(
      chatCosmos.showZodiac,
      isFalse,
      reason: 'La chat non deve mostrare la costellazione quadrata (rettangolo '
          'a portale) dietro l\'header.',
    );
  });

  testWidgets('L\'header della chat non mostra il pulsante Messa a punto',
      (tester) async {
    silenceSensors();
    await openMedoraChat(tester);
    // Il simbolo a cursori non deve comparire nell'header: nessuno strumento da
    // sviluppatore nella build normale o da Demo.
    expect(find.byIcon(Icons.tune_rounded), findsNothing);
  });

  testWidgets('Il Santuario mantiene invece il cosmo completo con le '
      'costellazioni', (tester) async {
    silenceSensors();
    await tester.pumpWidget(EsotericCircleApp(services: AppServices.offline()));
    await step(tester);

    final homeCosmos = tester.widget<CosmosBackground>(
      find.descendant(
        of: find.byType(AppShell),
        matching: find.byType(CosmosBackground),
      ),
    );
    expect(homeCosmos.showZodiac, isTrue);
  });
}
