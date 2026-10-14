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
      ];
      expect(r, hasLength(4), reason: 'le etichette della croce non sono 4');
      // **LAPIDE: la distanza in orizzontale fra etichette in fila.** Dalla
      // aggiunta 1 dell'ordine FM la croce in piedi resta croce, e due
      // scritte stanno nella stessa colonna una sopra l'altra: si toccano se
      // i loro rettangoli si sovrappongono.
      final toccate = <String>[];
      for (var i = 0; i < r.length; i++) {
        for (var j = i + 1; j < r.length; j++) {
          if (r[i].overlaps(r[j])) toccate.add('${r[i]} e ${r[j]}');
        }
      }
      print('ORDINE FL VOCE 05: etichette della croce che si toccano '
          '${toccate.length}');
      expect(toccate, isEmpty,
          reason: 'due etichette della croce si toccano: $toccate');
    });

    // **LE CARTE IN PIEDI NELLA FORMA DELLA STESA**, aggiunta 1 dell'ordine
    // FM. Il fondatore, 12 ottobre 2026: "Nella croce a 4, le carte si
    // sollevano mantenendo la disposizione a croce", la Croce Celtica "in 2
    // righe da 5 carte", e "In entrambi i casi le carte in verticale devono
    // vedersi bene".
    List<Rect> inPiedi(WidgetTester tester, int n) => [
          for (var i = 0; i < n; i++)
            tester.getRect(find.byKey(ValueKey('tavolo_posto_$i'))),
        ];

    testWidgets(
        'FM aggiunta 1: la croce a quattro in piedi resta croce, e le carte si '
        'vedono bene', (tester) async {
      await monta(tester, revealAll: true, tipo: TarotSpreadType.croceQuattro);
      // Nell'ordine della stesa: consultante in basso, i due lati, l'esito in
      // alto.
      final c = inPiedi(tester, 4);
      final (consultante, sinistro, destro, esito) = (c[0], c[1], c[2], c[3]);
      print('FM AGGIUNTA 1: croce in piedi, larghezza ${esito.width} punti; '
          'esito a ${esito.top}, lati a ${sinistro.top}, consultante a '
          '${consultante.top}');
      expect(esito.center.dx, closeTo(consultante.center.dx, 1),
          reason: 'l\'esito e il consultante non stanno sullo stesso asse');
      expect(esito.top, lessThan(consultante.top),
          reason: 'l\'esito non sta sopra il consultante');
      expect(sinistro.center.dx, lessThan(esito.left),
          reason: 'il lato sinistro non sta a sinistra dell\'asse');
      expect(destro.center.dx, greaterThan(esito.right),
          reason: 'il lato destro non sta a destra dell\'asse');
      expect(sinistro.top, greaterThan(esito.top));
      expect(sinistro.top, lessThan(consultante.top),
          reason: 'i lati non stanno a meta\' fra l\'esito e il consultante');
      expect(esito.width, greaterThanOrEqualTo(90),
          reason: 'le carte della croce in piedi sono strette: '
              '${esito.width} punti');
    });

    testWidgets(
        'FM aggiunta 1: la Croce Celtica in piedi sta in righe bilanciate, al '
        'piu\' quattro per riga', (tester) async {
      await monta(tester, revealAll: true, tipo: TarotSpreadType.dieciCarte);
      final c = inPiedi(tester, 10);
      final righe = <double>[];
      final contoPerRiga = <int>[];
      for (final r in c) {
        final i = righe.indexWhere((y) => (y - r.top).abs() < 1);
        if (i < 0) {
          righe.add(r.top);
          contoPerRiga.add(1);
        } else {
          contoPerRiga[i]++;
        }
      }
      print('FM AGGIUNTA 1: Croce Celtica in piedi, carte per riga '
          '$contoPerRiga, larghezza ${c.first.width} punti');
      // Il fondatore, 12 ottobre 2026: "Puoi disporle in verticale anche in
      // 2 file da 3 carte e una da 4 carte": tre righe, non due, nessuna di
      // cinque.
      expect(righe, hasLength(3),
          reason: 'la Croce Celtica in piedi non sta in tre righe: $righe');
      for (final n in contoPerRiga) {
        expect(n, lessThanOrEqualTo(4),
            reason: 'una riga della Croce Celtica ha piu\' di quattro carte: '
                '$contoPerRiga');
      }
      expect(contoPerRiga.reduce((a, b) => a + b), 10);
      expect(c.first.width, greaterThanOrEqualTo(70),
          reason: 'le carte della Croce Celtica in piedi sono strette: '
              '${c.first.width} punti');
    });

    // **LE CARTE SUL TAVOLO, PIU' GRANDI**, aggiunta 1 dell'ordine FM. Il
    // fondatore, 12 ottobre 2026: "anche quando le carte sono posizionate
    // appoggiate sul tavolo, cerca di ingrandirle in modo da occupare quasi
    // tutta la superficie del tavolo". Prima un tetto a 0,34 volte il piano
    // teneva la carta sola a un terzo del tavolo anche con tutto il campo
    // libero.
    Future<Rect> cartaSulTavolo(
        WidgetTester tester, TarotSpreadType tipo, int quante) async {
      await monta(tester, tipo: tipo);
      for (var k = 0; k < quante; k++) {
        final carta = find.byKey(Key('stesa_fan_${38 + k}'));
        final r = tester.getRect(carta);
        await tester.tapAt(Offset(r.left + 6, r.center.dy));
        for (var i = 0; i < 8; i++) {
          await tester.pump(const Duration(milliseconds: 250));
        }
      }
      return tester.getRect(find.byKey(const Key('tavolo_carta_0')));
    }

    testWidgets(
        'FM aggiunta 1: la carta sola sul tavolo occupa quasi tutta la '
        'superficie del piano', (tester) async {
      final r = await cartaSulTavolo(tester, TarotSpreadType.unaCarta, 1);
      print('FM AGGIUNTA 1: la carta sola sul tavolo e\' larga ${r.width} '
          'punti');
      // Il vecchio tetto, 0,34 del piano a schermo 360, dava circa 97 punti:
      // la carta sola cresce ben oltre.
      expect(r.width, greaterThan(150),
          reason: 'la carta sola sul tavolo resta piccola: ${r.width} punti '
              '(il vecchio tetto dava circa 97)');
    });

    testWidgets(
        'FM aggiunta 1: la croce a quattro sul tavolo cresce quanto il campo '
        'reale lo permette', (tester) async {
      final r = await cartaSulTavolo(tester, TarotSpreadType.croceQuattro, 4);
      print('FM AGGIUNTA 1: la croce a quattro sul tavolo e\' larga '
          '${r.width} punti');
      // La croce occupa quattro righe logiche (y da -1,6 a 1,6): il limite
      // vero e' l'altezza del campo reale del velluto, non un tetto di
      // larghezza. Il margine del campo e' stato stretto da 0,86 a 0,97
      // volte il piano (docs/collaudo/FM/aggiunta_1/a1_margine_del_tavolo.txt),
      // che porta la croce da 52,6 a oltre 58 punti.
      expect(r.width, greaterThan(58),
          reason: 'le carte della croce sul tavolo restano piccole: '
              '${r.width} punti');
    });
  });

  test(
      'FM aggiunta 1: la Croce Celtica sul tavolo e\' quella di Waite, carta '
      'per carta', () {
    // Waite 1911, Parte III, sezione 7 (letto sulla trascrizione di
    // docs/corpus/tarocchi_posizione/verifica_waite_1911.md): la prima copre,
    // la seconda "across the FIRST", la terza "above", la quarta "below", la
    // quinta "on the side of the Significator from which he is looking", la
    // sesta "on the side that the Significator is facing", con la figura
    // "facing to the left"; le ultime quattro "one above the other in a line,
    // on the right hand side of the cross", dalla settima in basso.
    final t = TarotSpreadType.dieciCarte.tavolo;
    expect(t, hasLength(10));
    expect((t[0].x, t[0].y), (0.0, 0.0), reason: 'la prima non sta al centro');
    expect((t[1].x, t[1].y, t[1].diTraverso), (0.0, 0.0, true),
        reason: 'la seconda non attraversa la prima');
    expect(t[2].x == 0 && t[2].y < 0, isTrue, reason: 'la terza non e\' sopra');
    expect(t[3].x == 0 && t[3].y > 0, isTrue,
        reason: 'la quarta non e\' sotto');
    expect(t[4].x > 0 && t[4].y == 0, isTrue,
        reason: 'la quinta, cio\' che e\' dietro, non sta a destra');
    expect(t[5].x < 0 && t[5].y == 0, isTrue,
        reason: 'la sesta, cio\' che e\' davanti, non sta a sinistra');
    final croce = t.take(6).map((p) => p.x).reduce((a, b) => a > b ? a : b);
    for (var i = 6; i < 10; i++) {
      expect(t[i].x, greaterThan(croce),
          reason: 'la carta ${i + 1} non sta nella linea a destra della croce');
      if (i > 6) {
        expect(t[i].y, lessThan(t[i - 1].y),
            reason: 'la carta ${i + 1} non sta sopra la $i');
      }
    }
  });

  test('FL.08: il pubspec dichiara la cartella del tavolo, e i file ci sono',
      () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec, contains('    - assets/img/tavolo/'));
    expect(File(GeometriaDelTavolo.sfondo).existsSync(), isTrue);
    // LAPIDE: `GeometriaDelTavolo.busto`, la Medora ferma dell'ordine FL.
    // Dall'ordine FS aggiunta (14 ottobre 2026) la scena e' il video del
    // vortice, e Medora ferma e' una delle sue due pose.
    expect(File(GeometriaDelTavolo.posaDelMazzo).existsSync(), isTrue);
    expect(File(GeometriaDelTavolo.posaDellInvito).existsSync(), isTrue);
  });
}
