import 'dart:io';
import 'dart:math' as math;

import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/rituals/rune_cast.dart';
import 'package:esoteric_circle/core/sensi/ascoltatore_scuotimento.dart';
import 'package:esoteric_circle/core/settings/settings_controller.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/caligo/rune/rune_draw_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// LO SCUOTIMENTO HA UNA PORTA SOLA, E DOPO UNA GETTATA FUNZIONA ANCORA.
///
/// Il difetto di oggi, misurato sul codice: la schermata delle rune apriva il
/// proprio flusso, lo CANCELLAVA alla prima gettata e nessuno lo riarmava,
/// quindi lo scuotimento valeva una volta per vita della schermata. In piu'
/// quattro superfici ascoltavano ognuna per conto suo, passando al sensore il
/// samplingPeriod che su un telefono senza accelerometro solleva
/// un'eccezione asincrona. Adesso la porta e' una, AscoltatoreScuotimento, e
/// queste prove la enumerano e la misurano.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  group('la porta e\' una', () {
    test('accelerometerEventStream vive in due soli file, parallasse e '
        'porta dello scuotimento', () {
      final fuori = <String>[];
      for (final f in Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))) {
        if (!f.readAsStringSync().contains('accelerometerEventStream')) {
          continue;
        }
        final via = f.path.replaceAll('\\', '/');
        if (!via.endsWith('core/motion/parallax_controller.dart') &&
            !via.endsWith('core/sensi/ascoltatore_scuotimento.dart')) {
          fuori.add(via);
        }
      }
      expect(fuori, isEmpty,
          reason: 'Queste superfici ascoltano il sensore per conto loro: '
              '$fuori. La porta dello scuotimento e\' una.');
    });

    test('la porta non passa samplingPeriod al sensore', () {
      final testo = File('lib/core/sensi/ascoltatore_scuotimento.dart')
          .readAsStringSync();
      // Si guarda il CODICE, non i commenti: la parola compare nei commenti
      // proprio per spiegare perche' non deve comparire nel codice.
      final codice = testo
          .split('\n')
          .where((r) => !r.trimLeft().startsWith('//') &&
              !r.trimLeft().startsWith('///'))
          .join('\n');
      expect(codice.contains('samplingPeriod'), isFalse,
          reason: 'La porta passa samplingPeriod al sensore: su un telefono '
              'senza accelerometro il metodo di configurazione solleva '
              'un\'eccezione asincrona che nessun try prende.');
    });
  });

  group('la soglia e l\'antirimbalzo, misurati', () {
    test('oltre soglia parte, sotto soglia no', () {
      var partite = 0;
      final ascoltatore = AscoltatoreScuotimento(
          onScuotimento: () => partite++,
          orologio: () => DateTime(2026, 8, 7, 12));
      ascoltatore.provaCampione(0, 0, 15); // maneggio ordinario
      expect(partite, 0,
          reason: 'Quindici metri al secondo quadro non sono uno '
              'scuotimento: e\' alzare il telefono.');
      ascoltatore.provaCampione(0, 0, 23); // gesto deliberato
      expect(partite, 1, reason: 'Il gesto oltre soglia non e\' partito.');
    });

    test('due picchi ravvicinati sono UNA gettata', () {
      var partite = 0;
      var istante = DateTime(2026, 8, 7, 12);
      final ascoltatore = AscoltatoreScuotimento(
          onScuotimento: () => partite++, orologio: () => istante);
      ascoltatore.provaCampione(0, 0, 30);
      istante = istante.add(const Duration(milliseconds: 300));
      ascoltatore.provaCampione(0, 0, 30);
      expect(partite, 1,
          reason: 'Due picchi a trecento millisecondi hanno prodotto '
              '$partite gettate: uno scuotimento vero e\' una raffica di '
              'campioni, non una raffica di gettate.');
      istante = istante.add(const Duration(milliseconds: 1000));
      ascoltatore.provaCampione(0, 0, 30);
      expect(partite, 2,
          reason: 'Passata la finestra, il gesto nuovo deve valere.');
    });
  });

  group('sul percorso vero della schermata', () {
    void silenzia({bool sensoreRotto = false}) {
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
          MockStreamHandler.inline(onListen: (args, events) {
            if (sensoreRotto &&
                nome.endsWith('accelerometer')) {
              events.error(code: 'nessun_sensore');
            }
          }),
        );
      }
    }

    Future<AscoltatoreScuotimento> monta(WidgetTester tester,
        {AscoltatoreScuotimento? ascoltatore,
        bool sensoreRotto = false}) async {
      silenzia(sensoreRotto: sensoreRotto);
      SharedPreferences.setMockInitialValues({});
      tester.view.physicalSize = const Size(1080, 2391);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider(
              create: (_) => MaestroController(
                  initial: const ThemeKey.of(Maestro.caligo))),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
          ChangeNotifierProvider(create: (_) => EntitlementService(initial: Tier.tier1, )),
        ChangeNotifierProvider(create: (_) => QuestionAllowance()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
          ChangeNotifierProvider(create: (_) => SettingsController()),
        ],
        child: MaterialApp(
          builder: (ctx, child) => MediaQuery(
            data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
            child: MaestroScope(child: child!),
          ),
          home: RuneDrawScreen(
              userSign: Zodiac.aries,
              random: math.Random(3),
              scuotimento: ascoltatore),
        ),
      ));
      await tester.pump(const Duration(milliseconds: 400));
      return ascoltatore ?? AscoltatoreScuotimento();
    }

    testWidgets('lo scuotimento getta, e DOPO una gettata getta ancora',
        (tester) async {
      // IL ROSSO CHE PRENDE IL DIFETTO DI OGGI: prima, la sottoscrizione
      // moriva alla prima gettata e il secondo scuotimento cadeva nel vuoto.
      var istante = DateTime(2026, 8, 7, 12);
      final ascoltatore = AscoltatoreScuotimento(orologio: () => istante);
      addTearDown(ascoltatore.dispose);
      await monta(tester, ascoltatore: ascoltatore);

      // Il primo scuotimento: dalla preparazione al responso.
      ascoltatore.provaCampione(0, 0, 30);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byKey(const Key('rune_result')), findsOneWidget,
          reason: 'Il primo scuotimento non ha gettato.');
      final primaRuna = tester
          .widget<Text>(find.descendant(
              of: find.byKey(const Key('rune_card_0')),
              matching: find.byType(Text)).first)
          .data;

      // Il secondo, oltre la finestra dell'antirimbalzo: getta ANCORA.
      istante = istante.add(const Duration(seconds: 2));
      ascoltatore.provaCampione(0, 0, 30);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      final secondaRuna = tester
          .widget<Text>(find.descendant(
              of: find.byKey(const Key('rune_card_0')),
              matching: find.byType(Text)).first)
          .data;
      // Con Random(3), la seconda estrazione della Runa di Odino e' un'altra
      // runa: se il nome non cambia, il secondo scuotimento e' caduto nel
      // vuoto, che e' esattamente il difetto di oggi.
      final attesa1 = RuneCast.getta(gettataOdino, random: math.Random(3));
      final rng = math.Random(3);
      RuneCast.getta(gettataOdino, random: rng);
      final attesa2 = RuneCast.getta(gettataOdino, random: rng);
      expect(primaRuna, attesa1.rune.first.rune.name);
      expect(secondaRuna, attesa2.rune.first.rune.name,
          reason: 'Dopo la prima gettata lo scuotimento non getta piu\': la '
              'sottoscrizione e\' morta e nessuno l\'ha riarmata.');
    });

    testWidgets('senza sensore, il ripiego c\'e\', e\' toccabile e si '
        'dichiara a schermo', (tester) async {
      await monta(tester, sensoreRotto: true);
      await tester.pump(const Duration(milliseconds: 100));

      final riga = tester
          .widget<Text>(find.byKey(const Key('rune_ripiego_riga')));
      expect(riga.data, contains('non offre lo scuotimento'),
          reason: 'Il telefono senza sensore non dichiara il ripiego: la '
              'riga promette ancora lo scuotimento.');

      await tester.ensureVisible(find.byKey(const Key('rune_cast_button')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('rune_cast_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byKey(const Key('rune_result')), findsOneWidget,
          reason: 'Il pulsante di ripiego non ha gettato: senza sensore la '
              'persona resta senza la sua arte.');
    });
  });
}
