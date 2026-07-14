import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/rituals/daily_elements.dart';
import 'package:esoteric_circle/features/maestri/domain_screen.dart';
import 'package:esoteric_circle/features/rituals/dawn_rite_screen.dart';
import 'package:esoteric_circle/features/rituals/sunset_rune_screen.dart';
import 'package:esoteric_circle/features/santuario/daily_strip.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

Widget _host(Widget child) => MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
      ],
      child: MaterialApp(home: Scaffold(body: child)),
    );

/// La striscia del giorno: i quattro elementi, quello dell'ora attiva in
/// evidenza, e l'apertura diretta a tocco singolo senza dominio intermedio.
void main() {
  void silenceSensors(TestWidgetsFlutterBinding binding) {
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
      (call) async => null,
    );
  }

  testWidgets('Mostra i quattro elementi giornalieri', (tester) async {
    await tester.pumpWidget(_host(DailyStrip(clock: () => DateTime(2026, 7, 14, 12, 30))));
    await tester.pump();
    expect(find.byKey(const Key('santuario_daily_strip')), findsOneWidget);
    for (final e in DailyElement.values) {
      expect(find.byKey(Key('daily_element_${e.name}')), findsOneWidget);
    }
  });

  testWidgets('Un tocco apre l\'elemento, con l\'elemento giusto', (tester) async {
    DailyElement? opened;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: DailyStrip(
          clock: () => DateTime(2026, 7, 14, 12, 30),
          onOpen: (_, element) => opened = element,
        ),
      ),
    ));
    await tester.pump();

    await tester.tap(find.byKey(const Key('daily_element_breath')));
    expect(opened, DailyElement.breath);
  });

  testWidgets('Il tocco apre direttamente il rito, senza passare dal dominio',
      (tester) async {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    silenceSensors(binding);
    await tester.pumpWidget(_host(DailyStrip(clock: () => DateTime(2026, 7, 14, 7, 0))));
    await tester.pump();

    await tester.tap(find.byKey(const Key('daily_element_dawn')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));

    // Si apre il Rito dell'Alba, non lo schermo di dominio di una Guida.
    expect(find.byType(DawnRiteScreen), findsOneWidget);
    expect(find.byType(DomainScreen), findsNothing);
  });

  testWidgets('Ogni elemento apre la sua esperienza', (tester) async {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    silenceSensors(binding);
    await tester.pumpWidget(_host(DailyStrip(clock: () => DateTime(2026, 7, 14, 18, 0))));
    await tester.pump();

    await tester.tap(find.byKey(const Key('daily_element_rune')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.byType(SunsetRuneScreen), findsOneWidget);
  });

  testWidgets('Ogni elemento mostra il suo orario nel riquadro', (tester) async {
    await tester.pumpWidget(
        _host(DailyStrip(clock: () => DateTime(2026, 7, 14, 12, 30))));
    await tester.pump();

    expect(find.text('7:00'), findsOneWidget);
    expect(find.text('10:30'), findsOneWidget);
    expect(find.text('12:30'), findsOneWidget);
    expect(find.text('18:00'), findsOneWidget);
  });

  testWidgets('La "i" apre il popup informativo, non l\'esperienza',
      (tester) async {
    DailyElement? opened;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: DailyStrip(
          clock: () => DateTime(2026, 7, 14, 12, 30),
          onOpen: (_, element) => opened = element,
        ),
      ),
    ));
    await tester.pump();

    // Il cerchio informativo dell'Oracolo esiste ed e' separato dall'icona.
    expect(find.byKey(const Key('daily_info_button_oracle')), findsOneWidget);
    await tester.tap(find.byKey(const Key('daily_info_button_oracle')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Si apre il popup, l'esperienza resta chiusa.
    expect(find.byKey(const Key('daily_info_oracle')), findsOneWidget);
    expect(opened, isNull);
    // Spiega quale Maestro guida l'elemento e a che ora.
    expect(find.textContaining('Medora'), findsOneWidget);
    expect(find.text('Alle 12:30'), findsOneWidget);

    // Si chiude col pulsante, mai un vicolo cieco.
    await tester.tap(find.byKey(const Key('daily_info_close_oracle')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byKey(const Key('daily_info_oracle')), findsNothing);
  });

  testWidgets('Il popup del Rito dell\'Alba nomina il Maestro di turno',
      (tester) async {
    final now = DateTime(2026, 7, 14, 8, 0);
    await tester
        .pumpWidget(_host(DailyStrip(clock: () => now)));
    await tester.pump();

    await tester.tap(find.byKey(const Key('daily_info_button_dawn')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(const Key('daily_info_dawn')), findsOneWidget);
    expect(find.textContaining('Maestro di turno del giorno'), findsOneWidget);
  });
}
