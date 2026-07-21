import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/features/maestri/aura/meditation/meditation_screen.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// La striscia "Scopri altre arti del Cerchio" nel dominio del Maestro: le arti
/// degli ALTRI Maestri, in tessere, che aprono la funzione giusta.
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
    await tester.pump(const Duration(milliseconds: 400));
  }

  /// Apre il dominio di un Maestro dal Santuario e scorre fino alla striscia,
  /// che vive in fondo alla schermata come sliver, costruito solo allo scroll.
  Future<void> openDomain(WidgetTester tester, Maestro maestro) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(430, 1200);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(EsotericCircleApp(services: AppServices.offline()));
    await step(tester);
    final ctx = tester.element(find.byType(MaterialApp));
    ctx.read<MaestroController>().selectMaestro(maestro);
    await step(tester);
    await tester.tap(find.byKey(const Key('santuario_central_bust')));
    await step(tester);
    await step(tester);

    // Scorre il verticale fino a far comparire la striscia.
    await tester.scrollUntilVisible(
      find.byKey(const Key('other_arts_strip')),
      400,
      scrollable: find.byType(Scrollable).first,
    );
  }

  /// Scorre la striscia orizzontale fino alla tessera data.
  Future<void> revealTile(WidgetTester tester, String targetName) async {
    await tester.scrollUntilVisible(
      find.byKey(Key('other_art_$targetName')),
      160,
      scrollable: find.descendant(
        of: find.byKey(const Key('other_arts_strip')),
        matching: find.byType(Scrollable),
      ),
    );
  }

  testWidgets('Nel dominio di Medora la striscia mostra arti di altri Maestri',
      (tester) async {
    silenceSensors();
    await openDomain(tester, Maestro.medora);

    expect(find.byKey(const Key('other_arts_strip')), findsOneWidget);

    // Ci sono arti di Aura e di Caligo.
    await revealTile(tester, 'meditazione');
    expect(find.byKey(const Key('other_art_meditazione')), findsOneWidget);
    await revealTile(tester, 'lancioRune');
    expect(find.byKey(const Key('other_art_lancioRune')), findsOneWidget);
    // Le arti di Medora (dominio corrente) NON stanno nella striscia.
    expect(find.byKey(const Key('other_art_oroscopoGiorno')), findsNothing);
    expect(find.byKey(const Key('other_art_sinastriaVip')), findsNothing);
  });

  testWidgets('Toccando una tessera si apre la funzione giusta', (tester) async {
    silenceSensors();
    await openDomain(tester, Maestro.medora);
    await revealTile(tester, 'meditazione');

    await tester.tap(find.byKey(const Key('other_art_meditazione')));
    await step(tester);
    await step(tester);
    // Si e' aperta la Meditazione di Aura.
    expect(find.byType(MeditationScreen), findsOneWidget);
  });

  testWidgets('Nel dominio di Caligo la striscia mostra le arti di Medora e Aura',
      (tester) async {
    silenceSensors();
    await openDomain(tester, Maestro.caligo);

    expect(find.byKey(const Key('other_arts_strip')), findsOneWidget);
    // La runa (arte di Caligo, dominio corrente) non e' nella striscia.
    expect(find.byKey(const Key('other_art_lancioRune')), findsNothing);
    await revealTile(tester, 'oroscopoGiorno');
    expect(find.byKey(const Key('other_art_oroscopoGiorno')), findsOneWidget);
  });
}
