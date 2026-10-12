// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread_type.dart';
import 'package:esoteric_circle/core/tarot/tarot_topic.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/tarot/il_tavolo_di_medora.dart';
import 'package:esoteric_circle/features/tarot/stesa_fan.dart';
import 'package:esoteric_circle/features/tarot/stesa_tre_carte_screen.dart';
import 'package:esoteric_circle/features/tarot/tarot_card_art.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'cardinale_minimo.dart';

/// IL TAVOLO DI MEDORA. Ordine FL, 12 ottobre 2026.
///
/// Il fondatore: lo sfondo nuovo con Medora "tagliata alla vita come se
/// fosse dietro il tavolo", le carte che "si stendono sul tavolo mantenendo
/// la stessa prospettiva del tavolo", la sequenza dopo il pulsante (girate
/// una alla volta, "dopo un secondo dall'ultima girata" in piedi), e la
/// chiave "illuminata da sotto, non e' piu' grande". Le anteprime le mostrano
/// (docs/preview/FL/); questa guardia misura cio' che le anteprime fanno
/// vedere, perche' un'anteprima si guarda una volta e una prova ogni giorno.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  group('FL.01 e FL.03, la geometria', () {
    test('gli angoli del campo stanno dentro il bordo ricamato del velluto',
        () {
      // **MISURATI A MANO SULL'IMMAGINE**, in pixel, e scritti qui e non
      // presi dal codice: una prova che confronta il codice con se' stesso
      // e' verde qualunque angolo si scelga (Regola A, primo innesto verde).
      // Le linee interne del bordo ricamato: in fondo a y 909, x da 140 a
      // 525; davanti a y 1172, x da 52 a 615.
      const lontano = (y: 909.0, sx: 140.0, dx: 525.0);
      const vicino = (y: 1172.0, sx: 52.0, dx: 615.0);
      const c = GeometriaDelTavolo.campo;
      for (final p in [c[0], c[1]]) {
        expect(p.dy, inInclusiveRange(lontano.y, lontano.y + 30));
        expect(p.dx, inInclusiveRange(lontano.sx, lontano.dx));
      }
      for (final p in [c[2], c[3]]) {
        expect(p.dy, inInclusiveRange(vicino.y - 30, vicino.y));
        expect(p.dx, inInclusiveRange(vicino.sx, vicino.dx));
      }
    });

    test('il piano piatto va sui quattro angoli del velluto', () {
      for (final w in [360.0, 390.0, 430.0]) {
        final p = GeometriaDelTavolo.piano(w);
        final da = [
          Offset.zero,
          Offset(p.width, 0),
          Offset(p.width, p.height),
          Offset(0, p.height),
        ];
        for (var i = 0; i < 4; i++) {
          final atteso =
              GeometriaDelTavolo.nellaScena(GeometriaDelTavolo.campo[i], w);
          final avuto = GeometriaDelTavolo.proietta(da[i], w);
          expect((avuto - atteso).distance, lessThan(0.5),
              reason: 'a $w punti l\'angolo $i del piano non va sul velluto');
        }
      }
    });

    test('la vita di Medora sul bordo lontano, la testa intera nella scena',
        () {
      for (final w in [360.0, 390.0, 430.0]) {
        final m = GeometriaDelTavolo.medora(w);
        final vita = GeometriaDelTavolo.nellaScena(
                const Offset(0, GeometriaDelTavolo.bordoLontano), w)
            .dy;
        expect(m.bottom, closeTo(vita, 0.01));
        final testa = GeometriaDelTavolo.testaDiMedora(w);
        expect(testa, greaterThanOrEqualTo(0),
            reason: 'a $w punti la testa di Medora esce in alto dalla scena');
        expect(testa, lessThan(12),
            reason: 'a $w punti la testa di Medora non sfiora piu\' la barra '
                'del titolo: sta a ${testa.toStringAsFixed(1)} punti');
      }
    });

    test('le carte di ogni stesa stanno dentro il campo del velluto', () {
      cardinaleMinimo(TarotSpreadType.values.length, 4, cosa: 'stese');
      for (final t in TarotSpreadType.values) {
        final p = GeometriaDelTavolo.piano(360);
        final c = GeometriaDelTavolo.carteSulPiano(t.tavolo, 360);
        for (final a in c.angoli) {
          final r = a & Size(c.larghezza, c.larghezza / kAspettoDellaCarta);
          expect(r.left, greaterThanOrEqualTo(-0.01), reason: t.name);
          expect(r.right, lessThanOrEqualTo(p.width + 0.01), reason: t.name);
          expect(r.top, greaterThanOrEqualTo(-0.01), reason: t.name);
          expect(r.bottom, lessThanOrEqualTo(p.height + 0.01), reason: t.name);
        }
      }
    });
  });

  group('FL.02, FL.05 e FL.04, a video', () {
    void silenzia() {
      final m = binding.defaultBinaryMessenger;
      m.setMockMethodCallHandler(
          const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
          (call) async => null);
      for (final nome in const [
        'dev.fluttercommunity.plus/sensors/accelerometer',
        'dev.fluttercommunity.plus/sensors/user_accel',
        'dev.fluttercommunity.plus/sensors/gyroscope',
        'dev.fluttercommunity.plus/sensors/magnetometer',
      ]) {
        m.setMockStreamHandler(
            EventChannel(nome), MockStreamHandler.inline(onListen: (a, e) {}));
      }
    }

    Future<void> monta(WidgetTester tester,
        {bool revealAll = false, TarotSpreadType? tipo}) async {
      silenzia();
      for (final f in const [
        ['Cinzel', 'assets/fonts/Cinzel-variable.ttf'],
        ['EBGaramond', 'assets/fonts/EBGaramond-variable.ttf'],
      ]) {
        final loader = FontLoader(f[0]);
        loader.addFont(
            Future.value(ByteData.view(File(f[1]).readAsBytesSync().buffer)));
        await loader.load();
      }
      tester.view.physicalSize = const Size(360, 3000);
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
          debugShowCheckedModeBanner: false,
          home: MaestroScope(
            child: StesaTreCarteScreen(
              seed: 2,
              revealAll: revealAll,
              skipIntro: true,
              topic: TarotTopic.bivio,
              tipo: tipo,
            ),
          ),
        ),
      ));
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 300));
      }
    }

    Finder nellaScena(Finder f) =>
        find.descendant(of: find.byKey(const Key('stesa_slots')), matching: f);

    testWidgets(
        'FL.02: dall\'alto la scena, poi il selettore, il ventaglio e '
        'il pulsante', (tester) async {
      await monta(tester);
      final y = [
        tester.getRect(find.byKey(const Key('tavolo_medora'))).top,
        tester.getRect(find.byType(StesaFan)).top,
        tester.getRect(find.byKey(const Key('stesa_inizia'))).top,
      ];
      print('ORDINE FL VOCE 02: Medora a ${y[0]}, il ventaglio a ${y[1]}, il '
          'pulsante a ${y[2]}');
      expect(y[0] < y[1] && y[1] < y[2], isTrue,
          reason: 'l\'ordine dall\'alto non e\' scena, ventaglio, pulsante');
    });

    testWidgets(
        'FL.05: le carte scelte stanno coperte sul tavolo, poi si '
        'girano una alla volta e un secondo dopo si alzano', (tester) async {
      await monta(tester);
      for (final indice in [38, 39, 40]) {
        final carta = find.byKey(Key('stesa_fan_$indice'));
        final r = tester.getRect(carta);
        await tester.tapAt(Offset(r.left + 6, r.center.dy));
        for (var i = 0; i < 8; i++) {
          await tester.pump(const Duration(milliseconds: 250));
        }
      }
      // Coperte: tre dorsi sul tavolo e nessuna faccia.
      expect(nellaScena(find.byType(CardBack)), findsNWidgets(3),
          reason: 'prima del pulsante le carte non sono coperte sul tavolo');
      expect(nellaScena(find.byType(TarotCardArt)), findsNothing,
          reason: 'prima del pulsante una carta e\' gia\' scoperta');

      await tester.tap(find.byKey(const Key('stesa_inizia')),
          warnIfMissed: false);
      final attesa = find.byKey(const Key('stesa_attesa'));
      for (var i = 0; i < 300 && attesa.evaluate().isEmpty; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      for (var i = 0; i < 600 && attesa.evaluate().isNotEmpty; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      // Le girate, misurate a passi piccoli: quante facce sul tavolo.
      final girate = <int>[];
      var tempoDellUltima = 0;
      var tempoDellAlzata = -1;
      var facceDelMazzo = 0;
      for (var t = 0; t < 6000; t += 50) {
        await tester.pump(const Duration(milliseconds: 50));
        final facce = nellaScena(find.byType(TarotCardArt)).evaluate().length;
        // Il mazzo scelto: la faccia sul tavolo e' quella della schermata
        // (FacciaDellaCarta, che legge il mazzo della stesa), non un
        // Rider-Waite fisso. Primo giro dell'ordine FL: era fisso.
        final delMazzo =
            nellaScena(find.byType(FacciaDellaCarta)).evaluate().length;
        if (delMazzo > facceDelMazzo) facceDelMazzo = delMazzo;
        final alzando = find
            .byKey(const ValueKey('tavolo_carta_che_si_alza_0'))
            .evaluate()
            .isNotEmpty;
        if (alzando && tempoDellAlzata < 0) {
          tempoDellAlzata = t;
          break;
        }
        if (girate.isEmpty || facce != girate.last) {
          girate.add(facce);
          if (facce == 3) tempoDellUltima = t;
        }
      }
      print('ORDINE FL VOCE 05: facce sul tavolo nel tempo $girate, ultima '
          'girata a $tempoDellUltima ms, alzata a $tempoDellAlzata ms');
      expect(girate.where((n) => n > 0).toList(), [1, 2, 3],
          reason: 'le carte non si girano una alla volta');
      expect(facceDelMazzo, 3,
          reason: 'sul tavolo la carta girata non ha la faccia del mazzo '
              'scelto');
      expect(tempoDellAlzata - tempoDellUltima, greaterThanOrEqualTo(900),
          reason: 'le carte si alzano prima del secondo dopo l\'ultima girata');
    });

    testWidgets(
        'FL.04: in piedi le carte hanno la stessa misura, e la chiave '
        'ha la sua luce', (tester) async {
      await monta(tester, revealAll: true);
      final posti = [
        for (var i = 0; i < 3; i++) find.byKey(ValueKey('tavolo_posto_$i')),
      ];
      for (final p in posti) {
        expect(p, findsOneWidget, reason: 'la fila in piedi non c\'e\'');
      }
      // La carta DIPINTA, con la sua scala: la cella e' la stessa per tutte,
      // e una chiave ingrandita da un Transform la cella non la vede.
      final larghezze = [
        for (final nome in const ['passato', 'presente', 'futuro'])
          tester
              .getRect(find.byKey(Key('stesa_carta_$nome')))
              .width
              .roundToDouble(),
      ];
      expect(larghezze.toSet(), hasLength(1),
          reason: 'le carte in piedi non hanno la stessa misura: $larghezze');
      final luce = find.byKey(const Key('stesa_luce_della_chiave'));
      expect(luce, findsOneWidget, reason: 'la chiave non ha la luce da sotto');
      // Il fondatore, 12 ottobre 2026: "dovrebbe essere meno esteso e uscire
      // dai 4 lati della carta chiave". Quanto la luce esce su ogni lato, in
      // punti, dalla carta dipinta.
      final l = tester.getRect(luce);
      // La carta che porta la luce, qualunque posto sia la chiave: la carta
      // dipinta nella stessa pila della luce.
      final pila = find.ancestor(of: luce, matching: find.byType(Stack)).first;
      final c = tester.getRect(
          find.descendant(of: pila, matching: find.byType(AspectRatio)).first);
      final lati = [
        c.left - l.left,
        c.top - l.top,
        l.right - c.right,
        l.bottom - c.bottom
      ];
      print('ORDINE FL VOCE 04: la luce esce dai quattro lati di $lati punti');
      for (final d in lati) {
        expect(d, inInclusiveRange(8, 20),
            reason: 'la luce non esce stretta da tutti e quattro i lati: '
                '$lati');
      }
    });

    testWidgets(
        'FL.05: in piedi le etichette delle quattro carte della croce non si '
        'toccano', (tester) async {
      await monta(tester, revealAll: true, tipo: TarotSpreadType.croceQuattro);
      final r = [
        for (final e in find
            .byWidgetPredicate((w) =>
                w is Text &&
                w.key is ValueKey<String> &&
                (w.key! as ValueKey<String>)
                    .value
                    .startsWith('stesa_etichetta_'))
            .evaluate())
          tester.getRect(find.byWidget(e.widget)),
      ]..sort((a, b) => a.left.compareTo(b.left));
      expect(r, hasLength(4), reason: 'le etichette della croce non sono 4');
      final spazi = [
        for (var i = 1; i < r.length; i++) r[i].left - r[i - 1].right
      ];
      print('ORDINE FL VOCE 05: fra le etichette della croce $spazi punti');
      for (final s in spazi) {
        expect(s, greaterThanOrEqualTo(0),
            reason: 'due etichette della croce si toccano: $spazi');
      }
    });
  });

  test('FL.08: il pubspec dichiara la cartella del tavolo, e i file ci sono',
      () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec, contains('    - assets/img/tavolo/'));
    expect(File(GeometriaDelTavolo.sfondo).existsSync(), isTrue);
    expect(File(GeometriaDelTavolo.busto).existsSync(), isTrue);
  });
}
