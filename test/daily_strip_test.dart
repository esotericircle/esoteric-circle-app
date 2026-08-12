import 'package:esoteric_circle/core/astro/sky_location.dart';
import 'package:esoteric_circle/core/astro/solar_time.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/rituals/daily_elements.dart';
import 'package:esoteric_circle/core/rituals/sunset_rune.dart';
import 'package:esoteric_circle/features/maestri/domain_screen.dart';
import 'package:esoteric_circle/features/rituals/dawn_rite_screen.dart';
import 'package:esoteric_circle/features/rituals/dream_rite_screen.dart';
import 'package:esoteric_circle/features/rituals/sunset_rune_screen.dart';
import 'package:esoteric_circle/features/santuario/daily_strip.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// Una posizione finta, sempre disponibile, per il conto alla rovescia.
class _LuogoFinto extends SkyLocation {
  const _LuogoFinto(this._luogo);
  final SkyPlace _luogo;
  @override
  bool get available => true;
  @override
  Future<SkyPlace?> resolve() async => _luogo;
  @override
  Future<SkyPlace?> resolveSeConcesso() async => _luogo;
}

/// Una sorgente che registra se qualcuno ha CHIESTO il permesso: `resolve` e' la
/// via che apre il dialogo di sistema, `resolveSeConcesso` no. Con permesso non
/// concesso, la seconda torna null.
class _LuogoSpia extends SkyLocation {
  _LuogoSpia();

  int chiesto = 0;
  int guardato = 0;

  @override
  bool get available => true;

  @override
  Future<SkyPlace?> resolve() async {
    chiesto++;
    return null; // permesso negato
  }

  @override
  Future<SkyPlace?> resolveSeConcesso() async {
    guardato++;
    return null; // permesso non concesso: nessuna posizione, nessun dialogo
  }
}

Widget _host(Widget child) => MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        // Il cosmo condiviso del Rito del Sogno chiede parallasse e zodiaco.
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
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
    // Il quinto appuntamento, il Rito del Sogno, e' presente.
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

  testWidgets('La casella della Runa mostra il conto alla rovescia al tramonto',
      (tester) async {
    // Primo pomeriggio: il tramonto e' piu' tardi, il conto e' a vista.
    await tester
        .pumpWidget(_host(DailyStrip(clock: () => DateTime(2026, 7, 14, 13, 0))));
    await tester.pump();
    final conto = find.byKey(const Key('daily_conto_rune'));
    expect(conto, findsOneWidget);
    expect(tester.widget<Text>(conto).data, startsWith('tra '));
    // Solo la Runa ha il conto: le altre caselle no.
    for (final e in DailyElement.values) {
      if (e == DailyElement.rune) continue;
      expect(find.byKey(Key('daily_conto_${e.name}')), findsNothing);
    }
  });

  testWidgets('A tramonto passato il conto sparisce, la casella si accende',
      (tester) async {
    // Notte fonda: il tramonto e' gia' avvenuto, nessun conto alla rovescia.
    await tester
        .pumpWidget(_host(DailyStrip(clock: () => DateTime(2026, 7, 14, 23, 0))));
    await tester.pump();
    expect(find.byKey(const Key('daily_conto_rune')), findsNothing);
  });

  testWidgets('Aprire la striscia non chiede mai il permesso di posizione',
      (tester) async {
    // Con permesso non concesso: la striscia guarda, non chiede, e ripiega sul
    // tramonto stimato dal fuso.
    final spia = _LuogoSpia();
    final now = DateTime(2026, 7, 14, 13, 0);
    await tester.pumpWidget(_host(DailyStrip(clock: () => now, location: spia)));
    await tester.pump();
    await tester.pump();

    expect(spia.chiesto, 0, reason: 'nessuna richiesta di permesso all\'apertura');
    expect(spia.guardato, greaterThan(0), reason: 'ha guardato senza chiedere');
    // Ripiego sul tramonto stimato dal fuso: il conto c'e' e coincide.
    final stimato = SunsetTime.perData(SunsetRune.giornoRituale(now),
        lat: SunsetTime.latDiRipiego,
        lon: SunsetTime.longitudineDaFuso(now.timeZoneOffset),
        offset: now.timeZoneOffset)!;
    final minuti = stimato.difference(now).inMinutes;
    final atteso = minuti >= 60
        ? 'tra ${minuti ~/ 60}h ${minuti % 60}min'
        : 'tra ${minuti % 60}min';
    expect(find.text(atteso), findsOneWidget);
  });

  testWidgets('Il confine di giornata e\' quello rituale, come la schermata',
      (tester) async {
    // Alle 03:00 il giorno rituale e' ancora ieri: la runa di ieri e' quella
    // servita dalla schermata, quindi la striscia non deve annunciare un
    // tramonto lontano diciassette ore, e la casella non e' spenta.
    final notte = DateTime(2026, 7, 14, 3, 0);
    expect(SunsetRune.giornoRituale(notte), DateTime(2026, 7, 13));
    await tester
        .pumpWidget(_host(DailyStrip(clock: () => notte)));
    await tester.pump();
    // Il tramonto del giorno rituale (ieri) e' passato: nessun conto.
    expect(find.byKey(const Key('daily_conto_rune')), findsNothing);

    // Alle 13:00 il giorno rituale e' oggi e il tramonto e' ancora davanti.
    final pomeriggio = DateTime(2026, 7, 14, 13, 0);
    expect(SunsetRune.giornoRituale(pomeriggio), DateTime(2026, 7, 14));
    await tester
        .pumpWidget(_host(DailyStrip(clock: () => pomeriggio)));
    await tester.pump();
    final conto = find.byKey(const Key('daily_conto_rune'));
    expect(conto, findsOneWidget);
    // E il conto e' quello del giorno rituale corrente, poche ore, non diciassette.
    final testo = tester.widget<Text>(conto).data!;
    final ore = int.parse(RegExp(r'tra (\d+)h').firstMatch(testo)!.group(1)!);
    expect(ore, lessThan(12), reason: 'conto sul giorno rituale, non su domani');
  });

  testWidgets('Il bersaglio del controllo di aiuto e\' almeno 44 per 44',
      (tester) async {
    await tester.pumpWidget(
        _host(DailyStrip(clock: () => DateTime(2026, 7, 14, 13, 0))));
    await tester.pump();
    for (final e in DailyElement.values) {
      final t = find.byKey(Key('daily_help_target_${e.name}'));
      expect(t, findsOneWidget, reason: e.name);
      final size = tester.getSize(t);
      expect(size.width, greaterThanOrEqualTo(44), reason: e.name);
      expect(size.height, greaterThanOrEqualTo(44), reason: e.name);
    }
  });

  testWidgets('Un tocco lontano dal cerchio apre comunque l\'aiuto',
      (tester) async {
    await tester.pumpWidget(
        _host(DailyStrip(clock: () => DateTime(2026, 7, 14, 13, 0))));
    await tester.pump();
    // Sedici punti sotto il centro del cerchietto: fuori dai 18 disegnati, ma
    // dentro il bersaglio da quarantaquattro.
    final centro =
        tester.getCenter(find.byKey(const Key('daily_help_button_rune')));
    await tester.tapAt(centro + const Offset(0, 16));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byKey(const Key('daily_info_close_rune')), findsOneWidget);
  });

  testWidgets('Il conto usa la posizione reale, la stessa fonte della schermata',
      (tester) async {
    // Con una posizione nota, il conto della striscia deve coincidere con il
    // tramonto calcolato su quella posizione, non sulla stima dal fuso.
    final now = DateTime(2026, 6, 21, 14, 0);
    const luogo = _LuogoFinto(SkyPlace(latitude: 41.9, longitude: 12.5));
    await tester.pumpWidget(_host(
        DailyStrip(clock: () => now, location: luogo)));
    await tester.pump(); // risolve la posizione
    await tester.pump();

    final tramonto = SunsetTime.perData(now,
        lat: 41.9, lon: 12.5, offset: now.timeZoneOffset)!;
    final minuti = tramonto.difference(now).inMinutes;
    final h = minuti ~/ 60;
    final m = minuti % 60;
    final atteso = h > 0 ? 'tra ${h}h ${m}min' : 'tra ${m}min';
    expect(find.text(atteso), findsOneWidget);
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

  testWidgets('Il Rito del Sogno apre la sua esperienza', (tester) async {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    silenceSensors(binding);
    await tester.pumpWidget(_host(DailyStrip(clock: () => DateTime(2026, 7, 14, 23, 0))));
    await tester.pump();

    await tester.tap(find.byKey(const Key('daily_element_night')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.byType(DreamRiteScreen), findsOneWidget);
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

  testWidgets('Il popup del Rito del Sogno nomina il Maestro di turno',
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
