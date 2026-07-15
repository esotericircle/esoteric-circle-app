import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/rituals/daily_elements.dart';
import 'package:esoteric_circle/features/maestri/domain_screen.dart';
import 'package:esoteric_circle/features/rituals/dawn_rite_screen.dart';
import 'package:esoteric_circle/features/rituals/night_rite_screen.dart';
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

/// La striscia degli appuntamenti quotidiani: i cinque elementi, quello dell'ora
/// attiva in evidenza, l'header, il "?" per etichetta e l'apertura diretta a
/// tocco singolo senza dominio intermedio.
void main() {
  void silenceSensors(TestWidgetsFlutterBinding binding) {
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
      (call) async => null,
    );
  }

  testWidgets('Mostra i cinque appuntamenti sotto l\'header', (tester) async {
    await tester.pumpWidget(_host(DailyStrip(clock: () => DateTime(2026, 7, 14, 13, 0))));
    await tester.pump();
    expect(find.byKey(const Key('santuario_daily_strip')), findsOneWidget);
    // La riga sottile che annuncia la striscia.
    expect(find.text('I tuoi doni del giorno'), findsOneWidget);
    expect(DailyElement.values.length, 5);
    for (final e in DailyElement.values) {
      expect(find.byKey(Key('daily_element_${e.name}')), findsOneWidget);
    }
    // Il quinto appuntamento, il Rito della Buonanotte, e' presente.
    expect(find.byKey(const Key('daily_element_night')), findsOneWidget);
    expect(find.text('Notte'), findsOneWidget);
  });

  testWidgets('Nessun orario a vista nella striscia', (tester) async {
    await tester.pumpWidget(_host(DailyStrip(clock: () => DateTime(2026, 7, 14, 13, 0))));
    await tester.pump();
    // Gli orari vivono solo nel popup, non sulla striscia.
    for (final label in const ['7:00', '10:30', '13:00', '18:30', '22:30']) {
      expect(find.text(label), findsNothing);
    }
  });

  testWidgets('L\'header e\' centrato orizzontalmente', (tester) async {
    await tester.pumpWidget(_host(DailyStrip(clock: () => DateTime(2026, 7, 14, 13, 0))));
    await tester.pump();
    final headerX =
        tester.getCenter(find.text('I tuoi doni del giorno')).dx;
    final stripX =
        tester.getCenter(find.byKey(const Key('santuario_daily_strip'))).dx;
    expect((headerX - stripX).abs(), lessThan(1.0));
  });

  testWidgets('Le cinque icone sono distinte, il Tramonto non e\' una luna',
      (tester) async {
    await tester.pumpWidget(_host(DailyStrip(clock: () => DateTime(2026, 7, 14, 13, 0))));
    await tester.pump();

    // Ogni elemento ha la sua icona dedicata.
    for (final e in DailyElement.values) {
      expect(find.byKey(Key('daily_icon_${e.name}')), findsOneWidget);
    }

    Finder inItem(String name, Finder matching) => find.descendant(
          of: find.byKey(Key('daily_element_$name')),
          matching: matching,
        );

    // Oracolo sole pieno, Notte luna con stella, Soffio vento: icone Material
    // chiaramente diverse.
    expect(inItem('oracle', find.byIcon(Icons.wb_sunny_rounded)), findsOneWidget);
    expect(inItem('night', find.byIcon(Icons.nights_stay_rounded)),
        findsOneWidget);
    expect(inItem('breath', find.byIcon(Icons.air_rounded)), findsOneWidget);

    // Alba e Tramonto sono soli disegnati sull'orizzonte, non icone Material e
    // soprattutto mai lune: nessun'icona nei loro riquadri.
    expect(inItem('dawn', find.byType(Icon)), findsNothing);
    expect(inItem('rune', find.byType(Icon)), findsNothing);
    // E restano due disegni distinti, uno per l'alba e uno per il tramonto.
    expect(find.byKey(const Key('daily_icon_dawn')), findsOneWidget);
    expect(find.byKey(const Key('daily_icon_rune')), findsOneWidget);
  });

  testWidgets('Nessuna etichetta viene troncata, "Tramonto" resta intero',
      (tester) async {
    await tester.pumpWidget(_host(DailyStrip(clock: () => DateTime(2026, 7, 14, 13, 0))));
    await tester.pump();
    for (final label in const [
      'Alba',
      'Soffio',
      'Oracolo',
      'Tramonto',
      'Notte',
    ]) {
      expect(find.text(label), findsOneWidget);
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

    // Si apre il Rito dell'Alba, non lo schermo di dominio di un Maestro.
    expect(find.byType(DawnRiteScreen), findsOneWidget);
    expect(find.byType(DomainScreen), findsNothing);
  });

  testWidgets('Ogni elemento apre la sua esperienza', (tester) async {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    silenceSensors(binding);
    await tester.pumpWidget(_host(DailyStrip(clock: () => DateTime(2026, 7, 14, 19, 0))));
    await tester.pump();

    await tester.tap(find.byKey(const Key('daily_element_rune')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.byType(SunsetRuneScreen), findsOneWidget);
  });

  testWidgets('Il Rito della Buonanotte apre la sua esperienza', (tester) async {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    silenceSensors(binding);
    await tester.pumpWidget(_host(DailyStrip(clock: () => DateTime(2026, 7, 14, 23, 0))));
    await tester.pump();

    await tester.tap(find.byKey(const Key('daily_element_night')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.byType(NightRiteScreen), findsOneWidget);
    expect(find.byType(DomainScreen), findsNothing);
  });

  testWidgets('Il "?" apre il popup con l\'orario dentro, non l\'esperienza',
      (tester) async {
    DailyElement? opened;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: DailyStrip(
          clock: () => DateTime(2026, 7, 14, 13, 0),
          onOpen: (_, element) => opened = element,
        ),
      ),
    ));
    await tester.pump();

    // Il cerchio "?" dell'Oracolo esiste ed e' separato dall'icona.
    expect(find.byKey(const Key('daily_help_button_oracle')), findsOneWidget);
    await tester.tap(find.byKey(const Key('daily_help_button_oracle')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Si apre il popup, l'esperienza resta chiusa.
    expect(find.byKey(const Key('daily_info_oracle')), findsOneWidget);
    expect(opened, isNull);
    // Spiega quale Maestro guida l'elemento e a che ora, che vive solo qui.
    expect(find.textContaining('Medora'), findsOneWidget);
    expect(find.text('Alle 13:00'), findsOneWidget);

    // Si chiude col pulsante, mai un vicolo cieco.
    await tester.tap(find.byKey(const Key('daily_info_close_oracle')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byKey(const Key('daily_info_oracle')), findsNothing);
  });

  testWidgets('Il popup del Rito della Buonanotte nomina il Maestro di turno',
      (tester) async {
    final now = DateTime(2026, 7, 14, 23, 0);
    await tester.pumpWidget(_host(DailyStrip(clock: () => now)));
    await tester.pump();

    await tester.tap(find.byKey(const Key('daily_help_button_night')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(const Key('daily_info_night')), findsOneWidget);
    expect(find.textContaining('Maestro di turno del giorno'), findsOneWidget);
    expect(find.text('Alle 22:30'), findsOneWidget);
  });
}
