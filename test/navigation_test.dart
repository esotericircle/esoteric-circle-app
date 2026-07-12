import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/features/shell/santuario_bottom_bar.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// Navigazione viva, mai un vicolo cieco: Santuario, dominio, chat e ritorno,
/// con la pila che si riavvolge. Piu' la bottom bar che sceglie il Maestro
/// centrale e l'ordine fisso dei tre.
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

  NavigatorState navOf(WidgetTester tester) =>
      tester.state<NavigatorState>(find.byType(Navigator).first);

  testWidgets('Santuario, dominio, chat e ritorno riavvolgono la pila',
      (tester) async {
    silenceSensors();
    await tester.pumpWidget(EsotericCircleApp(services: AppServices.offline()));
    await step(tester);
    final ctx = tester.element(find.byType(MaterialApp));

    // Al Santuario non c'e' nulla da riavvolgere.
    expect(navOf(tester).canPop(), isFalse);

    // Porta Medora al centro ed entra nel dominio dal busto.
    ctx.read<MaestroController>().selectMaestro(Maestro.medora);
    await step(tester);
    await tester.tap(find.byKey(const Key('santuario_central_bust')));
    await step(tester);
    await step(tester);
    expect(find.text('Parla con Medora'), findsOneWidget);
    // Il dominio ha la sua freccia Indietro.
    expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    expect(navOf(tester).canPop(), isTrue);

    // Dal dominio entra nella chat.
    await tester.tap(find.text('Parla con Medora'));
    await step(tester);
    await step(tester);
    // Il disclaimer si apre come foglio una volta sola: chiudilo, cosi' il
    // ritorno riguarda la pila vera (dominio, Santuario).
    final accept = find.text('Ho capito, entriamo');
    if (accept.evaluate().isNotEmpty) {
      await tester.tap(accept);
      await step(tester);
    }
    expect(find.text('Scrivi a Medora'), findsOneWidget);
    // Anche la chat ha la sua freccia Indietro.
    expect(find.byIcon(Icons.arrow_back_rounded), findsWidgets);

    // Il tasto di sistema Android e lo scorrimento dal bordo popano la stessa
    // pila: dalla chat si torna al dominio.
    await navOf(tester).maybePop();
    await step(tester);
    await step(tester);
    expect(find.text('Parla con Medora'), findsOneWidget);
    expect(find.text('Scrivi a Medora'), findsNothing);

    // Dal dominio si torna al Santuario.
    await navOf(tester).maybePop();
    await step(tester);
    await step(tester);
    expect(find.text('Parla con Medora'), findsNothing);
    expect(find.text('Passport'), findsWidgets);
    expect(navOf(tester).canPop(), isFalse);
  });

  testWidgets('L\'icona Maestro nella bottom bar porta al suo dominio',
      (tester) async {
    silenceSensors();
    await tester.pumpWidget(EsotericCircleApp(services: AppServices.offline()));
    await step(tester);
    final maestro =
        tester.element(find.byType(MaterialApp)).read<MaestroController>();

    // L'icona nella barra non centra soltanto: apre il dominio del Maestro.
    await tester.tap(find.text('Aura'));
    await step(tester);
    await step(tester);
    expect(find.text('Parla con Aura'), findsOneWidget);
    expect(maestro.activeMaestro, Maestro.aura);
  });

  testWidgets('Il carosello cambia il Maestro centrale restando nel Santuario',
      (tester) async {
    silenceSensors();
    await tester.pumpWidget(EsotericCircleApp(services: AppServices.offline()));
    await step(tester);
    final ctx = tester.element(find.byType(MaterialApp));
    final maestro = ctx.read<MaestroController>();

    // Al centro c'e' il preferito (Medora); i laterali sono Caligo e Aura.
    expect(maestro.activeMaestro, isNull);
    // Toccando un busto laterale lo si porta al centro, senza lasciare il
    // Santuario: nessun dominio spinto, cambia solo il centro.
    await tester.tap(find.byKey(const Key('santuario_side_left')));
    await step(tester);
    expect(maestro.activeMaestro, Maestro.caligo);
    expect(find.byType(SantuarioBottomBar), findsOneWidget);
    expect(find.text('Parla con Caligo'), findsNothing);
  });

  testWidgets('I tre Maestri nella bottom bar rispettano l\'ordine fisso',
      (tester) async {
    silenceSensors();
    await tester.pumpWidget(EsotericCircleApp(services: AppServices.offline()));
    await step(tester);

    final labels = tester
        .widgetList<Text>(find.descendant(
          of: find.byType(SantuarioBottomBar),
          matching: find.byType(Text),
        ))
        .map((t) => t.data)
        .whereType<String>()
        .toList();

    final medora = labels.indexOf('Medora');
    final caligo = labels.indexOf('Caligo');
    final aura = labels.indexOf('Aura');
    expect(medora, greaterThanOrEqualTo(0));
    expect(medora < caligo && caligo < aura, isTrue,
        reason: 'ordine atteso Medora, Caligo, Aura: $labels');
  });
}
