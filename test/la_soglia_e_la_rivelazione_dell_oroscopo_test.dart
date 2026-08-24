import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/horoscope/riflessione_del_cielo.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/sensi/catalogo_suoni.dart';
import 'package:esoteric_circle/core/sensi/palette_sensoriale.dart';
import 'package:esoteric_circle/core/settings/settings_controller.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/horoscope/oroscopo_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// LA SOGLIA E LA RIVELAZIONE. Ordine BK voce 04.
///
/// Al tocco su "Interroga il cielo" suona la soglia con una vibrazione
/// leggera; alla comparsa del responso suona la rivelazione. Nessun asset
/// nuovo: sono gia' nel catalogo dei suoni del Cerchio, e passano dalla porta
/// unica, cioe' dallo stesso interruttore che governa suono e vibrazione
/// insieme. Non nasce un secondo interruttore.
///
/// **La misura e' vera e non strutturale.** Finora i suoni si verificavano
/// leggendo il codice sorgente, perche' in prova il plugin audio non c'e': una
/// prova cosi' dice se una riga esiste, non se il suono e' partito una volta o
/// due. Qui la spia di `PaletteSensoriale` li conta davvero.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // **IL CANALE DELLA PIATTAFORMA DEVE RISPONDERE, o la catena si ferma prima
  // del suono.** La porta unica manda PRIMA la vibrazione e poi il suono, e
  // l'aptica passa da `SystemChannels.platform`: in prova nessuno risponde su
  // quel canale, quindi l'attesa non finisce mai e il suono non parte. Non e'
  // un difetto del codice, e' l'ambiente: qui il canale riceve una risposta
  // vuota, come farebbe un telefono senza motore aptico.
  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async => null);
  });
  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  final emessi = <SuonoDelCerchio>[];
  final quando = <SuonoDelCerchio, Duration>{};
  var orologio = Duration.zero;

  setUp(() {
    emessi.clear();
    quando.clear();
    orologio = Duration.zero;
    PaletteSensoriale.dimenticaSessione();
    PaletteSensoriale.spia = (s) {
      emessi.add(s);
      quando.putIfAbsent(s, () => orologio);
    };
  });

  tearDown(() => PaletteSensoriale.spia = null);

  Future<void> monta(WidgetTester tester,
      {bool suonoAcceso = true, DateTime? adesso}) async {
    tester.view.physicalSize = const Size(360, 797) * 3.0;
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(
            create: (_) => EntitlementService(initial: Tier.tier1)),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider(create: (_) => BirthIdentityController()),
        ChangeNotifierProvider(
            create: (_) =>
                SettingsController(suonoEVibrazione: suonoAcceso)),
      ],
      child: MaterialApp(
        builder: (ctx, child) => MaestroScope(child: child!),
        home: OroscopoScreen(
            userSign: Zodiac.leo,
            now: adesso ?? DateTime.utc(2026, 8, 5, 12)),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  /// **I SUONI PASSANO DA UN CANALE DI PIATTAFORMA, e non escono nello stesso
  /// fotogramma del gesto.** La porta unica manda prima la vibrazione e poi il
  /// suono, e fra le due c'e' un `await` su un canale: qualche fotogramma a
  /// TEMPO FERMO lascia assestare la catena senza spostare l'orologio, cosi'
  /// le misure di quando un suono e' uscito restano vere.
  Future<void> assesta(WidgetTester tester) async {
    for (var i = 0; i < 4; i++) {
      await tester.pump(Duration.zero);
    }
  }

  /// Avanza il tempo tenendo il conto, cosi' si sa QUANDO ogni suono e' uscito.
  Future<void> avanza(WidgetTester tester, Duration d) async {
    orologio += d;
    await tester.pump(d);
    await assesta(tester);
  }

  testWidgets('la soglia al tocco, la rivelazione alla comparsa del responso',
      (tester) async {
    SharedPreferences.setMockInitialValues(const {});
    await monta(tester);

    expect(emessi, isEmpty, reason: 'prima del gesto non suona niente');

    await tester.tap(find.byKey(const Key('oroscopo_interroga')));
    await tester.pump();
    await assesta(tester);
    expect(emessi, [SuonoDelCerchio.soglia],
        reason: 'il tocco apre la soglia, e nient\'altro');

    // Fino alla fine della riflessione la rivelazione non parte.
    await avanza(tester, RiflessioneDelCielo.intera(piena: true) -
        const Duration(milliseconds: 100));
    expect(emessi, [SuonoDelCerchio.soglia],
        reason: 'la rivelazione appartiene al responso, non all\'attesa');

    // Finita la riflessione, il responso compare e la rivelazione suona.
    await avanza(tester, const Duration(milliseconds: 200));
    expect(emessi, [SuonoDelCerchio.soglia, SuonoDelCerchio.rivelazione]);

    // E nessuno dei due si ripete mentre le schede finiscono di comporsi.
    await avanza(tester, const Duration(seconds: 8));
    expect(emessi, [SuonoDelCerchio.soglia, SuonoDelCerchio.rivelazione],
        reason: 'ogni suono parte UNA volta sola per consulto');
  });

  testWidgets('i due suoni non si sovrappongono mai', (tester) async {
    SharedPreferences.setMockInitialValues(const {});
    await monta(tester);
    await tester.tap(find.byKey(const Key('oroscopo_interroga')));
    await tester.pump();
    await assesta(tester);
    // A PASSI PICCOLI, perche' l'istante sia misurato e non stimato: un solo
    // balzo di otto secondi direbbe soltanto "prima di otto secondi".
    for (var i = 0; i < 80; i++) {
      await avanza(tester, const Duration(milliseconds: 100));
    }

    final soglia = quando[SuonoDelCerchio.soglia]!;
    final rivelazione = quando[SuonoDelCerchio.rivelazione]!;
    final distanza = rivelazione - soglia;
    // ignore: avoid_print
    print('BK.04 MISURA: soglia a ${soglia.inMilliseconds} millesimi, '
        'rivelazione a ${rivelazione.inMilliseconds}, distanza '
        '${distanza.inMilliseconds}, coda della soglia '
        '${SuonoDelCerchio.soglia.durataAttesa.inMilliseconds}');
    expect(distanza, greaterThan(SuonoDelCerchio.soglia.durataAttesa),
        reason: 'la rivelazione deve partire dopo che la soglia e\' finita: '
            'due suoni sovrapposti non fanno un momento piu\' ricco, fanno '
            'rumore');
  });

  testWidgets('il gesto chiamato due volte non suona due volte',
      (tester) async {
    SharedPreferences.setMockInitialValues(const {});
    await monta(tester);
    // Due tocchi di seguito sullo stesso pulsante: il secondo non deve
    // aprire un secondo consulto ne' un secondo suono.
    await tester.tap(find.byKey(const Key('oroscopo_interroga')));
    await tester.pump();
    final pulsante = find.byKey(const Key('oroscopo_interroga'));
    if (pulsante.evaluate().isNotEmpty) await tester.tap(pulsante);
    await tester.pump();
    await assesta(tester);
    // **SI CONTA A CONSULTO FINITO, e non subito dopo i due tocchi.** Un suono
    // che si ripete non si ripete per forza nello stesso fotogramma: se
    // ripartisse al secondo momento, contare qui direbbe "una volta sola" e la
    // prova sarebbe cieca proprio al difetto che porta il nome.
    for (var i = 0; i < 80; i++) {
      await avanza(tester, const Duration(milliseconds: 100));
    }
    expect(emessi.where((s) => s == SuonoDelCerchio.soglia).length, 1,
        reason: 'la soglia parte una volta sola per consulto');
    expect(emessi.where((s) => s == SuonoDelCerchio.rivelazione).length, 1,
        reason: 'la rivelazione parte una volta sola per consulto');
  });

  testWidgets('con l\'interruttore spento non suona niente', (tester) async {
    SharedPreferences.setMockInitialValues(const {});
    await monta(tester, suonoAcceso: false);
    await tester.tap(find.byKey(const Key('oroscopo_interroga')));
    await tester.pump();
    await assesta(tester);
    await avanza(tester, const Duration(seconds: 8));
    expect(emessi, isEmpty,
        reason: 'suono e vibrazione stanno dietro l\'interruttore unico che '
            'c\'e\' gia\': non ne nasce un secondo per l\'Oroscopo');
  });

  test('i due suoni sono quelli del catalogo, senza asset nuovi', () {
    expect(SuonoDelCerchio.soglia.file, 'soglia.mp3');
    expect(SuonoDelCerchio.rivelazione.file, 'rivelazione.mp3');
  });
}
