// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/tarot/la_lettura_dal_modello.dart';
import 'package:esoteric_circle/core/tarot/le_carte_nella_posizione.dart';
import 'package:esoteric_circle/core/tarot/stesa_in_corso.dart';
import 'package:esoteric_circle/core/tarot/tarot_card.dart';
import 'package:esoteric_circle/core/tarot/tarot_reading.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread_type.dart';
import 'package:esoteric_circle/core/tarot/tarot_topic.dart';
import 'package:esoteric_circle/core/tarot/voce_della_stesa.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/tarot/il_tavolo_della_stesa.dart';
import 'package:esoteric_circle/features/tarot/stesa_tre_carte_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'cardinale_minimo.dart';

/// LA STESA DI N CARTE. Ordine FK, aggiunta 2 voci A8, A9, A10 e A12, 12
/// ottobre 2026.
///
/// Prima `TarotSpread` era una stesa a tre carte per costruzione, la lettura
/// del modello conosceva tre posizioni su quindici e la schermata metteva tre
/// carte in fila; le altre stese non si potevano leggere. Qui si misura che
/// ogni stesa porti le sue posizioni nell'ordine di lettura (anche la croce,
/// dove `lato` torna due volte), che il modello riceva un campo per posto,
/// che le fonti vuote stiano solo nella Croce Celtica chiusa, che le due
/// stese aperte si leggano, e che sul tavolo nessuna carta esca dallo schermo
/// alla larghezza vera.

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  group('A8, la stesa', () {
    test('ogni stesa pesca le sue posizioni, nell\'ordine, anche ripetute', () {
      cardinaleMinimo(TarotSpreadType.values.length, 4, cosa: 'stese');
      for (final t in TarotSpreadType.values) {
        final s = TarotSpread.draw(seed: 7, posizioni: t.posizioni);
        expect(s.cards, hasLength(t.carte), reason: t.name);
        expect(s.posizioni, t.posizioni, reason: t.name);
        expect(s.cards.map((c) => c.card.name).toSet(), hasLength(t.carte),
            reason: '${t.name}: una carta e\' uscita due volte');
      }
      final croce = TarotSpread.draw(
          seed: 7, posizioni: TarotSpreadType.croceQuattro.posizioni);
      expect(
          croce.posizioni.where((p) => p == SpreadPosition.lato), hasLength(2),
          reason: 'i due lati della croce sono diventati uno');
    });

    test('la stesa in corso conta i posti, non le posizioni', () {
      final posizioni = TarotSpreadType.croceQuattro.posizioni;
      var s = StesaInCorso.nuova(
          mazzo: List<int>.generate(78, (i) => i),
          seme: 3,
          posizioni: posizioni);
      for (var i = 0; i < posizioni.length; i++) {
        s = s.assegnaAlPosto(i, dalVentaglio: i);
      }
      expect(s.eCompleta, isTrue);
      final carte = s.stesaCompiuta!.cards;
      expect(carte.map((c) => c.position).toList(), posizioni);
      expect(carte[1].card.name, isNot(carte[2].card.name));
      // E per posizione: il secondo lato va nel secondo posto libero.
      var p = StesaInCorso.nuova(
          mazzo: List<int>.generate(78, (i) => i), posizioni: posizioni);
      p = p.assegna(SpreadPosition.lato, dalVentaglio: 0);
      p = p.assegna(SpreadPosition.lato, dalVentaglio: 1);
      expect(p.assegnate[1], isNotNull);
      expect(p.assegnate[2], isNotNull);
    });
  });

  group('A9, la richiesta al modello', () {
    test('un campo per posto, e i due lati sono due campi', () {
      TarotSpread di(TarotSpreadType t) =>
          TarotSpread.draw(seed: 11, posizioni: t.posizioni);
      expect(LaLetturaDellaStesa.chiaviPer(di(TarotSpreadType.treCarte)),
          ['passato', 'presente', 'futuro']);
      expect(LaLetturaDellaStesa.chiaviPer(di(TarotSpreadType.unaCarta)),
          ['cartaSola']);
      final croce = di(TarotSpreadType.croceQuattro);
      expect(LaLetturaDellaStesa.chiaviPer(croce),
          ['consultante', 'lato_1', 'lato_2', 'esito']);
      expect(LaLetturaDellaStesa.campiPer(croce).keys.toList(), [
        'risposta',
        'consultante',
        'lato_1',
        'lato_2',
        'esito',
        'legame',
        'consiglio',
        'titolo',
      ]);
      final r = LaLetturaDellaStesa.richiesta(croce,
          domanda: 'Devo cambiare lavoro?', argomento: 'Lavoro');
      for (final c in croce.cards) {
        expect(r, contains(c.displayName));
        expect(r, contains(c.meaning));
      }
      expect(r, contains('Campo: lato_2'));
      expect(r, contains('La posizione vuol dire:'));
    });

    test('l\'istruzione non nomina piu\' tre posizioni fisse', () {
      final i = LaLetturaDellaStesa.istruzione(CourtesyForm.neutral);
      expect(i, isNot(contains('PASSATO, PRESENTE, FUTURO')));
      expect(i, isNot(contains('una stesa di tre carte')));
      expect(i, contains('leggila nella sua posizione'));
    });

    test('la lettura della croce si legge, si guarda e si rilegge', () {
      final croce = TarotSpread.draw(
          seed: 11, posizioni: TarotSpreadType.croceQuattro.posizioni);
      final chiavi = LaLetturaDellaStesa.chiaviPer(croce);
      final l = LetturaDelModello(
        risposta: 'Le carte indicano che puoi cambiare, se prima chiarisci '
            'che cosa cerchi.',
        carte: [
          for (final c in croce.cards)
            '${c.card.name} in questa posizione dice che la tua questione '
                'chiede chiarezza.',
        ],
        chiavi: chiavi,
        legame: 'Le carte vanno da una domanda a una scelta.',
        consiglio: 'Questa settimana scrivi che cosa cerchi.',
      );
      expect(LaLetturaDellaStesa.scarto(l, croce), isNull);
      final tornata = LetturaDelModello.daJson(l.toJson(), chiavi: chiavi);
      expect(tornata?.carte, l.carte);
      final reading =
          TarotReading.of(croce, TarotTopic.lavoroTrovare, dalModello: l);
      expect(reading.posizioni.map((p) => p.testo).toList(), l.carte);
    });
  });

  group('A9 e A12, le fonti e le stese aperte', () {
    // **LAPIDE: "le posizioni senza fonte stanno solo nella Croce Celtica
    // chiusa"** (ordine FK aggiunta 2, che ne contava quattro). Dall'ordine FM
    // le quindici posizioni hanno tutte la fonte: la prova pretende adesso
    // che nessuna ne resti senza, e che ogni stesa abbia la fonte in ogni
    // suo posto. La Croce Celtica resta chiusa per il tavolo, non per i testi.
    test('ogni posizione di ogni stesa ha la sua fonte', () {
      final senza = [
        for (final p in SpreadPosition.values)
          if (!LeCarteNellaPosizione.haLaFonte(p)) p,
      ];
      print('ORDINE FM: posizioni senza fonte $senza');
      cardinaleMinimo(SpreadPosition.values.length, 15, cosa: 'posizioni');
      expect(senza, isEmpty, reason: 'posizioni senza fonte: $senza');
      for (final t in TarotSpreadType.values) {
        expect(t.posizioni.every(LeCarteNellaPosizione.haLaFonte), isTrue,
            reason: '${t.name} ha una posizione senza fonte');
      }
    });

    test('aperte tutte e quattro le stese, Croce Celtica compresa', () {
      // **LA CROCE CELTICA SI APRE, ordine FQ, 13 ottobre 2026.** Qui si
      // pretendeva chiusa per il motivo scritto accanto a `costruita` in
      // `tarot_spread_type.dart`: la fila in piedi del tavolo di Medora
      // metteva le sue dieci carte affiancate a 26 punti, illeggibili.
      // **Quel motivo non vale piu' dall'ordine FM aggiunta 1 (12 ottobre
      // 2026)**: la fila in piedi ora dispone piu' di quattro carte in
      // righe bilanciate (dieci carte, 4+3+3), con le carte sempre almeno a
      // 70 punti, provato in `il_tavolo_di_medora_test.dart`
      // ("FM aggiunta 1: la Croce Celtica in piedi sta in righe bilanciate,
      // al piu' quattro per riga"). Il fondatore ha chiesto lo sblocco: il
      // lavoro grafico che lo motivava era gia' fatto, e la guardia qui
      // pretendeva ancora la decisione vecchia.
      for (final t in TarotSpreadType.values) {
        expect(t.disponibile, isTrue, reason: '${t.name} non e\' disponibile');
      }
    });

    test('le due stese aperte si leggono anche senza modello', () {
      final guasti = <String>[];
      var quante = 0, latiUguali = 0;
      for (final t in [
        TarotSpreadType.unaCarta,
        TarotSpreadType.croceQuattro
      ]) {
        for (final topic in TarotTopic.values) {
          for (var seme = 0; seme < 6; seme++) {
            quante++;
            final s = TarotSpread.draw(
                seed: seme * 13 + topic.index, posizioni: t.posizioni);
            final l = TarotReading.of(s, topic);
            if (l.paragrafi.length != 3) {
              guasti.add('${t.name} ${topic.name}: ${l.paragrafi.length} '
                  'paragrafi');
            }
            if (l.titolo.trim().isEmpty) guasti.add('${t.name}: senza titolo');
            // I nomi delle carte non contano: "Tre di Bastoni" non e' il
            // numero delle carte della stesa.
            var senzaNomi = l.consiglio;
            for (final c in TarotDeck.cards) {
              senzaNomi = senzaNomi.replaceAll(c.name, '');
            }
            // Ne' il conto dei Maggiori usciti, che e' un fatto della stesa.
            senzaNomi = senzaNomi.replaceAll('tre Arcani Maggiori', '');
            if (!VoceDellaStesa.valeOvunque(senzaNomi)) {
              guasti.add('${t.name} ${topic.name}: il consiglio parla di tre '
                  'carte o del passato: ${l.consiglio}');
            }
            if (l.posizioni.any((p) => p.testo.trim().isEmpty)) {
              guasti.add('${t.name} ${topic.name}: una carta senza testo');
            }
            if (t == TarotSpreadType.croceQuattro &&
                l.posizioni[1].testo == l.posizioni[2].testo) {
              latiUguali++;
            }
          }
        }
      }
      cardinaleMinimo(quante, 100, cosa: 'letture');
      print('ORDINE FK AGGIUNTA 2: letture di casa $quante, guaste '
          '${guasti.length}, croci coi due lati uguali $latiUguali');
      expect(guasti, isEmpty, reason: guasti.take(6).join('\n'));
      expect(latiUguali, 0,
          reason: 'le due carte del lato danno lo stesso testo');
    });
  });

  group('A10, il tavolo', () {
    test('a 360 punti nessuna carta esce dallo schermo, in nessuna stesa', () {
      const larghezza = 360.0 - 2 * 16;
      final fuori = <String>[];
      for (final t in TarotSpreadType.values) {
        final d =
            TavoloDellaStesa.disponi(t.tavolo, larghezza, (w) => w * 1.5 + 64);
        for (var i = 0; i < d.angoli.length; i++) {
          final a = d.angoli[i];
          if (a.dx < -0.01 || a.dx + d.larghezza > larghezza + 0.01) {
            fuori.add('${t.name} posto $i: da ${a.dx} a ${a.dx + d.larghezza}');
          }
        }
        // Due celle non si coprono, tranne la carta di traverso.
        for (var i = 0; i < d.angoli.length; i++) {
          for (var j = i + 1; j < d.angoli.length; j++) {
            if (t.tavolo[i].diTraverso || t.tavolo[j].diTraverso) continue;
            final ri = d.angoli[i] & Size(d.larghezza, d.altezza);
            final rj = d.angoli[j] & Size(d.larghezza, d.altezza);
            if (ri.intersect(rj).width > 0.01 &&
                ri.intersect(rj).height > 0.01) {
              fuori.add('${t.name}: i posti $i e $j si coprono');
            }
          }
        }
      }
      expect(fuori, isEmpty, reason: fuori.join('\n'));
    });

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

    for (final t in [
      TarotSpreadType.unaCarta,
      TarotSpreadType.treCarte,
      TarotSpreadType.croceQuattro,
    ]) {
      testWidgets('${t.name}: le carte a video stanno nello schermo a 360',
          (tester) async {
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
        tester.view.physicalSize = const Size(360, 4400);
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
                seed: 5,
                revealAll: true,
                skipIntro: true,
                topic: TarotTopic.bivio,
                tipo: t,
              ),
            ),
          ),
        ));
        await tester.pump();
        await tester.pump(const Duration(seconds: 3));
        final stesa = tester
            .state<StesaTreCarteScreenState>(find.byType(StesaTreCarteScreen))
            .stesaCorrente;
        expect(stesa.posizioni, t.posizioni);
        for (var i = 0; i < t.carte; i++) {
          final r = tester.getRect(find.byKey(ValueKey('tavolo_posto_$i')));
          expect(r.left, greaterThanOrEqualTo(0), reason: '${t.name} posto $i');
          expect(r.right, lessThanOrEqualTo(360), reason: '${t.name} posto $i');
        }
        // Una bolla per carta, ognuna col suo nome.
        expect(find.byType(BollaDellaPosizione), findsNWidgets(t.carte));
        for (final c in stesa.cards) {
          expect(find.textContaining(c.displayName), findsWidgets);
        }
        // Nessuna eccezione di impaginazione.
        expect(tester.takeException(), isNull);
      });
    }
  });

  test('il mazzo intero sta nel catalogo', () {
    expect(TarotDeck.cards, hasLength(78));
  });
}
