import 'package:esoteric_circle/core/archetypes/archetype_history.dart';
import 'package:esoteric_circle/core/astro/natal_chart_controller.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/rituals/carta_di_nascita_dei_tarocchi.dart';
import 'package:esoteric_circle/core/tarot/tarot_card.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/passport/cosmic_passport_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// LA CARTA DI NASCITA SI VEDE. Ordine CS, voce O3.
///
/// **Il difetto.** `CartaDiNascitaDeiTarocchi` calcolava l'Arcano Maggiore
/// legato alla data di nascita, e quel numero serviva a una cosa sola: era uno
/// dei fattori del seme dell'Arcano del Giorno. Chi apriva l'app non vedeva
/// mai qual e' la propria Carta di nascita ne' cosa dice. Anche `cartaDi`, che
/// gia' sapeva darla, non la chiamava nessun file di `lib`.
///
/// **La verita' di riscontro non e' il codice che si sta provando.** Il numero
/// atteso e' calcolato a mano qui sotto, cifra per cifra, secondo la regola
/// della tradizione: se domani qualcuno cambiasse la riduzione, queste prove
/// non lo seguirebbero.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  void silenzio() {
    final m = binding.defaultBinaryMessenger;
    m.setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
        (c) async => null);
    for (final n in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      m.setMockStreamHandler(
          EventChannel(n), MockStreamHandler.inline(onListen: (a, e) {}));
    }
  }

  Widget veste(Widget child) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => ArchetypeHistory()),
          ChangeNotifierProvider(create: (_) => NatalChartController()),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
          ChangeNotifierProvider(create: (_) => ZodiacController()),
          ChangeNotifierProvider(create: (_) => ProfileController()),
        ],
        child: MaterialApp(home: MaestroScope(child: child)),
      );

  Future<void> monta(WidgetTester tester, DateTime nascita) async {
    silenzio();
    tester.view.physicalSize = const Size(440, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(veste(Scaffold(
        body: CosmicPassport(
            identity: BirthIdentity(birthMoment: nascita)))));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  final tessera = find.byKey(const Key('passport_carta_di_nascita'));

  /// I ventidue Maggiori nell'ordine del mazzo, dal Matto al Mondo.
  final maggiori = TarotDeck.cards
      .where((c) => c.arcana == TarotArcana.maggiore)
      .toList(growable: false);

  /// **LA VERITA' DI RISCONTRO, calcolata a mano e non dal codice provato.**
  ///
  /// La regola della tradizione: si sommano le cifre di giorno, mese e anno, e
  /// si riduce finche' la somma non sta sotto il ventidue.
  ///
  /// - 10 agosto 1990: 1+0 fa 1, il mese 8, 1+9+9+0 fa 19. Totale 28, che si
  ///   riduce a 2+8, cioe' **10**.
  /// - 1 gennaio 2000: 1, 1 e 2. Totale **4**, che non si riduce.
  /// - 31 dicembre 1975: 3+1 fa 4, 1+2 fa 3, 1+9+7+5 fa 22. Totale 29, che si
  ///   riduce a 2+9, cioe' **11**.
  const attesi = <String, int>{
    '1990-08-10': 10,
    '2000-01-01': 4,
    '1975-12-31': 11,
  };

  final date = <String, DateTime>{
    '1990-08-10': DateTime(1990, 8, 10, 12),
    '2000-01-01': DateTime(2000, 1, 1, 12),
    '1975-12-31': DateTime(1975, 12, 31, 12),
  };

  test('Il numero della Carta di nascita segue la regola della tradizione',
      () {
    expect(attesi.length, greaterThanOrEqualTo(3),
        reason: 'le date di riscontro sono ${attesi.length}: con meno di tre '
            'questa prova non copre ne\' la riduzione ne\' il caso senza '
            'riduzione');
    attesi.forEach((chiave, atteso) {
      expect(CartaDiNascitaDeiTarocchi.numeroDi(date[chiave]!), atteso,
          reason: 'per la data $chiave la regola della tradizione da\' '
              '$atteso, il codice no');
    });
  });

  test('Il numero e la carta si corrispondono, e le tre date danno tre carte',
      () {
    expect(maggiori.length, 22,
        reason: 'i Maggiori nel mazzo sono ${maggiori.length} invece di '
            'ventidue: la corrispondenza col numero non puo\' reggere');
    final carte = <String>{};
    attesi.forEach((chiave, numero) {
      final carta = CartaDiNascitaDeiTarocchi.cartaDi(date[chiave]!);
      expect(carta.name, maggiori[numero % maggiori.length].name,
          reason: 'per $chiave il numero e\' $numero, ma la carta non e\' '
              'quella che quel numero indica nel mazzo');
      carte.add(carta.name);
    });
    expect(carte.length, attesi.length,
        reason: 'tre date di nascita distinte danno ${carte.length} carte '
            'invece di tre, quindi la Carta di nascita non distingue le '
            'persone');
  });

  testWidgets('Il Passaporto mostra la Carta di nascita, col nome e il testo',
      (tester) async {
    final nascita = date['1990-08-10']!;
    await monta(tester, nascita);
    expect(tessera, findsOneWidget,
        reason: 'la tessera della Carta di nascita non c\'e\': il calcolo '
            'resta un fattore di un seme e nessuno vede la propria carta');

    final carta = maggiori[attesi['1990-08-10']! % maggiori.length];
    final dentro = find.descendant(of: tessera, matching: find.byType(Text));
    final testi = tester
        .widgetList<Text>(dentro)
        .map((t) => t.data)
        .whereType<String>()
        .join(' ');
    expect(testi, contains(carta.name),
        reason: 'a video la tessera non porta il nome della carta, che per '
            'questa data e\' ${carta.name}');
    expect(testi, contains(carta.numeral),
        reason: 'manca il numerale ${carta.numeral}, che e\' il modo in cui '
            'la tradizione chiama questa carta');
    expect(testi.length, greaterThan(carta.name.length + 60),
        reason: 'la tessera mostra il nome e poco altro: la persona vede qual '
            'e\' la sua carta e non cosa dice');
  });

  testWidgets('Al tocco la carta si apre, e porta la sua lettura',
      (tester) async {
    await monta(tester, date['1990-08-10']!);
    await tester.ensureVisible(tessera);
    await tester.tap(tessera);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('carta_ingrandita_figura')), findsOneWidget,
        reason: 'il tocco sulla tessera non apre la carta ingrandita');
    expect(find.byKey(const Key('carta_ingrandita_testo')), findsOneWidget,
        reason: 'la carta si apre senza la sua lettura');
  });

  testWidgets('La tradizione della Carta di nascita si puo\' leggere',
      (tester) async {
    await monta(tester, date['1990-08-10']!);
    final porta = find.byKey(const Key('fonti_carta_di_nascita_bottone'));
    expect(porta, findsOneWidget,
        reason: 'la Carta di nascita non offre le sue fonti: il calcolo '
            'sembra una regola inventata dall\'app');
    await tester.ensureVisible(porta);
    await tester.tap(porta);
    await tester.pumpAndSettle();
    final foglio = find.byKey(const Key('fonti_carta_di_nascita'));
    expect(foglio, findsOneWidget,
        reason: 'la porta delle fonti si tocca e non apre niente');
    final testi = tester
        .widgetList<Text>(find.descendant(of: foglio, matching: find.byType(Text)))
        .map((t) => t.data)
        .whereType<String>()
        .join(' ');
    for (final nome in const ['Golden Dawn', 'Arrien', 'Greer']) {
      expect(testi, contains(nome),
          reason: 'il foglio delle fonti non nomina $nome, cioe\' non dice '
              'da dove viene il metodo');
    }
  });
}
