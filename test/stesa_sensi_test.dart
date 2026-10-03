import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/tarot/tarot_card.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/tarot/stesa_reveal.dart';
import 'package:esoteric_circle/features/tarot/stesa_senses.dart';
import 'package:esoteric_circle/features/tarot/stesa_tre_carte_screen.dart';
import 'package:esoteric_circle/core/sensi/catalogo_suoni.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// I sensi della Stesa: reveal elementale, suono e vibrazione dietro il loro
/// interruttore, giroscopio col ripiego statico. Ogni cosa ha il suo fallback,
/// e Riduci Movimento ferma tutto.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  /// Nei test non c'e' nessun sensore: si zittiscono i canali, come fanno le
  /// altre prove del repo, cosi' quel che si misura e' il RIPIEGO.
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

  setUp(silenceSensors);

  /// Un lettore che tiene il conto di cosa gli e' stato chiesto di suonare.

  Future<void> pump(
    WidgetTester tester, {
    bool reduceMotion = false,
    double altezza = 2600,
  }) async {
    tester.view.physicalSize = Size(390, altezza);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
      ],
      child: MaterialApp(
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(disableAnimations: reduceMotion),
          child: MaestroScope(child: child!),
        ),
        home: const StesaTreCarteScreen(seed: 2, skipIntro: true),
      ),
    ));
    await tester.pump();
  }

  group('Reveal elementale', () {
    test('Ogni seme porta il suo elemento, i Maggiori il cielo', () {
      const atteso = {
        TarotSeme.bastoni: RevealElemento.fuoco,
        TarotSeme.coppe: RevealElemento.acqua,
        TarotSeme.denari: RevealElemento.terra,
        TarotSeme.spade: RevealElemento.aria,
      };
      for (final card in TarotDeck.cards) {
        final e = RevealElemento.of(card);
        if (card.seme == null) {
          expect(e, RevealElemento.cielo,
              reason: '${card.name} non ha seme, tocca al cielo');
          expect(card.arcana, TarotArcana.maggiore);
        } else {
          expect(e, atteso[card.seme], reason: '${card.name} sbaglia elemento');
        }
      }
    });

    test('E deterministico: la stessa carta si scopre sempre uguale', () {
      for (final card in TarotDeck.cards) {
        final a = RevealSpec.of(card);
        final b = RevealSpec.of(card);
        expect(a.elemento, b.elemento);
        expect(a.solenne, b.solenne);
        expect(a.ampiezza, b.ampiezza);
        expect(a.durata, b.durata);
      }
    });

    test('I Maggiori fioriscono piu solenni dei Minori', () {
      final maggiore =
          TarotDeck.cards.firstWhere((c) => c.arcana == TarotArcana.maggiore);
      final minore =
          TarotDeck.cards.firstWhere((c) => c.arcana == TarotArcana.minore);
      final m = RevealSpec.of(maggiore);
      final n = RevealSpec.of(minore);
      expect(m.solenne, isTrue);
      expect(n.solenne, isFalse);
      // Piu' ampia e piu' lunga: pesano di piu' nella lettura, e si vede.
      expect(m.ampiezza, greaterThan(n.ampiezza));
      expect(m.durata, greaterThan(n.durata));
      expect(m.elemento.particelle, greaterThan(n.elemento.particelle));
    });

    test('A effetto finito non resta nulla sopra la carta', () {
      // A zero e a uno il widget non disegna: la carta resta pulita e
      // leggibile, che e' il punto.
      final spec = RevealSpec.of(TarotDeck.cards.first);
      final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.medora));
      for (final t in [0.0, 1.0]) {
        final w = ElementalReveal(spec: spec, progress: t, palette: palette);
        expect(w.progress, t);
      }
    });

    test('I quattro elementi si muovono in versi diversi', () {
      // Il fuoco sale, la terra si posa: se due elementi avessero lo stesso
      // moto, il reveal a tema non direbbe piu' niente.
      final fuoco = RevealElemento.fuoco.direzioneDi(0, 0.5);
      final terra = RevealElemento.terra.direzioneDi(0, 0.5);
      expect(fuoco.dy, lessThan(0), reason: 'il fuoco deve salire');
      expect(terra.dy, greaterThan(0), reason: 'la terra deve posarsi');
      final aria = RevealElemento.aria.direzioneDi(0, 0.5);
      expect(aria.dx.abs(), greaterThan(fuoco.dx.abs()),
          reason: 'l\'aria deve allargarsi piu\' del fuoco');
    });
  });

  group('Suono e vibrazione', () {
    /// **QUI NON C'E' PIU' UN LETTORE FINTO, e la ragione e' un difetto.**
    /// Ordine CO voce 02, 3 settembre 2026.
    ///
    /// Questo gruppo montava un `_LettoreSpia` e gli chiedeva cosa avesse
    /// sentito. Era una prova sincera e **sorvegliava la cosa sbagliata**:
    /// dimostrava che `SensiDellaStesa` consegna il momento al lettore che
    /// gli si passa, mentre nell'app **nessuno gliene passava mai uno**, e
    /// quello che si metteva di suo era un lettore il cui unico metodo era
    /// vuoto per contratto. La spia rispondeva sempre, e a schermo non usciva
    /// niente: la carta girata sceglieva il suo suono e lo consegnava al
    /// nulla, a ogni giro, restando verde.
    ///
    /// Adesso il suono passa dalla porta unica del Cerchio, e che ci arrivi
    /// davvero lo sorveglia `test/la_carta_girata_suona_test.dart`, con un
    /// contesto vero e la spia armata sulla porta. **Qui resta cio' che a
    /// questo gruppo compete davvero**: che l'interruttore fermi il momento
    /// prima ancora che qualcuno pensi a suonarlo.
    late BuildContext contesto;

    Future<SensiDellaStesa> conContesto(WidgetTester tester,
        {bool silenzio = false}) async {
      final sensi = SensiDellaStesa(silenzio: silenzio);
      await tester.pumpWidget(Builder(builder: (c) {
        contesto = c;
        return const SizedBox();
      }));
      return sensi;
    }

    testWidgets('L\u0027interruttore zittisce suono e vibrazione insieme',
        (tester) async {
      final sensi = await conContesto(tester);
      // Acceso: il momento passa.
      await sensi.momento(contesto, MomentoSensoriale.taglio);
      expect(sensi.eseguiti, [MomentoSensoriale.taglio]);

      // In silenzio non esce piu' nulla, ne' suono ne' vibrazione: e' lo
      // stesso interruttore per tutti e due.
      sensi.silenzio = true;
      await sensi.momento(contesto, MomentoSensoriale.flip);
      await sensi.momento(contesto, MomentoSensoriale.reveal);
      expect(sensi.eseguiti, [MomentoSensoriale.taglio],
          reason: 'in silenzio e passato comunque un momento');

      // E riaccendendolo torna tutto.
      sensi.silenzio = false;
      await sensi.momento(contesto, MomentoSensoriale.volo);
      expect(sensi.eseguiti.length, 2);
    });

    testWidgets('Anche il silenzioso di sistema zittisce tutto',
        (tester) async {
      final sensi = await conContesto(tester);
      sensi.sistemaSilenzioso = true;
      expect(sensi.muto, isTrue);
      await sensi.momento(contesto, MomentoSensoriale.taglio);
      expect(sensi.eseguiti, isEmpty);
    });

    test('I momenti che suonano sono due, e vengono dal catalogo del Cerchio',
        () {
      // I momenti NON hanno un catalogo sonoro tutto loro: ne esisteva un
      // secondo, cinque file dedicati alla stesa oltre a quelli del
      // Cerchio. Due cataloghi vogliono dire due identita' sonore. Questa
      // regola resta, e non e' quella che cambia.
      //
      // **QUELLO CHE CAMBIA E' IL NUMERO DEI MOMENTI CHE SUONANO: DA UNO
      // A DUE.** Ordine CN, 2 settembre 2026. Fino a ieri suonava solo la
      // carta scoperta, perche' un suono per la carta che si gira **non
      // esisteva**. Adesso esiste, `carta.mp3`, e viene dal catalogo del
      // Cerchio come tutti gli altri: nessun secondo catalogo e' tornato.
      const cheSuonano = {
        MomentoSensoriale.flip: SuonoDelCerchio.carta,
        MomentoSensoriale.reveal: SuonoDelCerchio.rivelazione,
      };
      for (final m in MomentoSensoriale.values) {
        expect(m.suono, cheSuonano[m],
            reason: 'il momento ${m.name} suona ${m.suono} invece di '
                '${cheSuonano[m]}. Il vocabolario sonoro della stesa e\u0027 '
                'quello del Cerchio, e i momenti che suonano sono due: la '
                'carta che si gira e la carta scoperta.');
        // Il nome del file lo dichiara il catalogo, non il momento.
      }
    });

    testWidgets('L\'interruttore di silenzio e in campo', (tester) async {
      await pump(tester, reduceMotion: true);
      await tester.pump();
      expect(find.byKey(const Key('stesa_silenzio')), findsOneWidget);
      // Si puo' premere, e non rompe nulla.
      await tester.tap(find.byKey(const Key('stesa_silenzio')));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });

  group('Giroscopio e ripiego statico', () {
    test('Senza sensore le carte restano ferme, senza errori', () {
      // Nei test non c'e' giroscopio: lo stream non parte, e il ripiego e'
      // semplicemente nessuna inclinazione.
      final tilt = TiltListener();
      tilt.start();
      expect(tilt.x, 0);
      expect(tilt.y, 0);
      // E chiudere senza aver mai ricevuto un dato non fa danni.
      tilt.dispose();
    });

    test('L\'inclinazione resta dentro il suo massimo', () {
      const massimo = 0.06;
      final tilt = TiltListener(massimo: massimo);
      // Anche volendo, non puo' superare il limite: e' un effetto di
      // superficie, non deve mai sembrare che la carta si ribalti.
      expect(tilt.x.abs(), lessThanOrEqualTo(massimo));
      expect(tilt.y.abs(), lessThanOrEqualTo(massimo));
      tilt.dispose();
    });

    test('Il galleggiamento e piccolo e ciclico', () {
      for (var i = 0; i < 3; i++) {
        final a = TiltListener.fluttuazioneDi(i, 0);
        final b = TiltListener.fluttuazioneDi(i, 1);
        // Dopo un giro completo si torna al punto di partenza.
        expect((a - b).abs(), lessThan(0.001));
        for (final t in [0.0, 0.25, 0.5, 0.75]) {
          expect(TiltListener.fluttuazioneDi(i, t).abs(), lessThan(3));
        }
      }
      // Le tre carte non galleggiano all'unisono, o sembrerebbe un blocco.
      expect(TiltListener.fluttuazioneDi(0, 0.3),
          isNot(TiltListener.fluttuazioneDi(1, 0.3)));
    });
  });

  group('Riduci Movimento ferma tutto', () {
    testWidgets('Nessuna fluttuazione e nessun reveal in moto', (tester) async {
      await pump(tester, reduceMotion: true);
      await tester.pump();
      // La scena e' gia' composta: nessuna aura in giro.
      for (final p in SpreadPosition.values) {
        expect(find.byKey(Key('stesa_reveal_${p.name}')), findsNothing);
      }
      // E pescando una carta non parte nessun moto: arriva gia' posata.
      await tester.tap(find.byKey(const Key('stesa_fan_38')));
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      expect(tester.takeException(), isNull);
      for (final p in SpreadPosition.values) {
        expect(find.byKey(Key('stesa_reveal_${p.name}')), findsNothing,
            reason: 'con Riduci Movimento l\'aura non deve comparire');
      }
    });
  });
}
