// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/tarot/i_mazzi_dei_tarocchi.dart';
import 'package:esoteric_circle/core/tarot/la_lettura_dal_modello.dart';
import 'package:esoteric_circle/core/tarot/le_fonti_dei_tarocchi.dart';
import 'package:esoteric_circle/core/tarot/tarot_reading.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread_type.dart';
import 'package:esoteric_circle/core/tarot/tarot_topic.dart';
import 'package:esoteric_circle/core/tarot/voce_della_stesa.dart';
import 'package:esoteric_circle/design_system/components/riquadro_in_evidenza.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/tarot/stesa_tre_carte_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'cardinale_minimo.dart';

/// IL FORMATO DEL RESPONSO DEI TAROCCHI. Ordine FK, aggiunta voci A2, A3 e
/// A5, 11 ottobre 2026.
///
/// Il fondatore: *"Prendi spunto dalle risposte dell'oroscopo come
/// formattazione: 3 paragrafi, il secondo e' evidenziato in riquadro e solo
/// alla fine un piccolo paragrafo in corsivo 'da dove viene'."* Piu' il titolo
/// che e' gia' la risposta (voce A1), le bolle per carta che restano col loro
/// titolo (voce A3) e il pannello delle fonti col mazzo e la stesa veri (voce
/// A5).

LetturaDelModello _buona(TarotSpread s, {String titolo = ''}) =>
    LetturaDelModello(
      risposta: 'Le carte indicano che puoi accettare, a patto di chiarire '
          'prima le condizioni. ${s.presente.card.name} nel presente dice che '
          'la decisione e\' matura.',
      passato: '${s.passato.card.name} nel passato racconta da dove parti.',
      presente: '${s.presente.card.name} nel presente dice che hai gli '
          'strumenti per scegliere.',
      futuro: '${s.futuro.card.name} nel futuro indica un ambiente nuovo.',
      legame: 'Dal passato al futuro le carte vanno da una chiusura a un '
          'inizio.',
      consiglio: 'Questa settimana chiedi per iscritto orari e compenso.',
      titolo: titolo,
    );

/// Le letture di casa: ogni argomento per [quanti] semi.
Iterable<(TarotTopic, TarotSpread, TarotReading)> _letture(int quanti) sync* {
  for (final t in TarotTopic.values) {
    for (var seme = 0; seme < quanti; seme++) {
      final s = TarotSpread.draw(seed: seme * 31 + t.index);
      yield (t, s, TarotReading.of(s, t));
    }
  }
}

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  group('il titolo', () {
    test('A1: un titolo per ogni cosa che il presente puo\' dire', () {
      var quanti = 0;
      for (final n in NaturaDellaCarta.values) {
        final titoli = VoceDellaStesa.titoliDelPresente[n]!;
        quanti += titoli.length;
        expect(titoli.length, VoceDellaStesa.cosaDiceIlPresente[n]!.length,
            reason: '${n.name}: i titoli non sono uno per risposta');
        for (final t in titoli) {
          expect(t.endsWith('.'), isFalse, reason: '"$t" finisce col punto');
          expect(
              t.length, lessThanOrEqualTo(LaLetturaDellaStesa.tettoDelTitolo),
              reason: '"$t" supera il tetto del titolo');
        }
      }
      cardinaleMinimo(quanti, 32, cosa: 'titoli della lettura di casa');
    });

    test('A1: la lettura di casa ha sempre il titolo della sua risposta', () {
      final guasti = <String>[];
      var quante = 0;
      for (final (t, s, l) in _letture(12)) {
        quante++;
        final natura = NaturaDellaCarta.di(s.presente);
        if (!VoceDellaStesa.titoliDelPresente[natura]!.contains(l.titolo)) {
          guasti.add('${t.name}: "${l.titolo}" non e\' un titolo di '
              '${natura.name}');
        }
        // Il titolo non e' piu' il significato della carta del Presente.
        if (s.presente.summary.startsWith(l.titolo)) {
          guasti.add('${t.name}: il titolo e\' la sintesi della carta');
        }
        for (final d in s.cards) {
          if (LaLetturaDellaStesa.nominaLaCarta(l.titolo, d.card.name)) {
            guasti.add('${t.name}: il titolo nomina ${d.card.name}');
          }
        }
      }
      cardinaleMinimo(quante, 100, cosa: 'letture');
      print('ORDINE FK VOCE A1: letture di casa $quante, titoli guasti '
          '${guasti.length}');
      expect(guasti, isEmpty, reason: guasti.take(6).join('\n'));
    });

    test('A1: il titolo del modello vince, se c\'e\' e non nomina le carte',
        () {
      final s = TarotSpread.draw(seed: 3);
      const suo = 'Accetta, ma prima metti tutto per iscritto';
      final r = TarotReading.of(s, TarotTopic.lavoroTrovare,
          dalModello: _buona(s, titolo: '$suo.'));
      expect(r.titolo, suo, reason: 'il punto in fondo si toglie');
      final conLaCarta = TarotReading.of(s, TarotTopic.lavoroTrovare,
          dalModello: _buona(s, titolo: 'Lo dice ${s.presente.card.name}'));
      expect(VoceDellaStesa.titoliDelPresente.values.expand((v) => v),
          contains(conLaCarta.titolo),
          reason: 'un titolo che nomina la carta apre col simbolo: parla '
              'quello di casa');
      final senza =
          TarotReading.of(s, TarotTopic.lavoroTrovare, dalModello: _buona(s));
      expect(senza.titolo, isNotEmpty);
    });

    test('A1: il modello riceve la richiesta del titolo, per ultimo', () {
      final i = LaLetturaDellaStesa.istruzione(CourtesyForm.neutral);
      expect(i, contains('- TITOLO:'));
      expect(i, contains('"consiglio" e "titolo"'));
      expect(LaLetturaDellaStesa.campi.keys.last, 'titolo');
      final s = TarotSpread.draw(seed: 3);
      final lungo = _buona(s, titolo: 'parola ' * 20);
      expect(LaLetturaDellaStesa.scarto(lungo, s), 'titolo troppo lungo');
      // Il titolo del primo giro vero, che l'istruzione vietava.
      expect(
          LaLetturaDellaStesa.scarto(
              _buona(s, titolo: 'Vendita casa: lascio andare o resto'), s),
          'il titolo ha i due punti o il punto di domanda');
      expect(
          LaLetturaDellaStesa.scarto(
              _buona(s, titolo: 'Lo dice ${s.presente.card.name}'), s),
          startsWith('il titolo nomina'));
      expect(LaLetturaDellaStesa.scarto(_buona(s), s), isNull,
          reason: 'un titolo vuoto non fa cadere la lettura');
      expect(LetturaDelModello.daJson({..._buona(s).toJson()})?.titolo, '',
          reason: 'una lettura senza titolo non cade: il titolo lo da\' casa');
    });
  });

  group('i tre paragrafi', () {
    test('A2: la lettura di casa ha tre paragrafi, il secondo e\' il gesto',
        () {
      final guasti = <String>[];
      for (final (t, _, l) in _letture(8)) {
        if (l.paragrafi.length != 3) {
          guasti.add('${t.name}: ${l.paragrafi.length} paragrafi');
        }
      }
      expect(guasti, isEmpty, reason: guasti.take(6).join('\n'));
    });

    test('A2: la lettura del modello ha la stessa forma', () {
      final s = TarotSpread.draw(seed: 4);
      final l = _buona(s);
      final senza =
          TarotReading.of(s, TarotTopic.momentoCheVivo, dalModello: l);
      expect(senza.paragrafi, hasLength(3));
      expect(senza.paragrafi[0], l.risposta);
      expect(senza.paragrafi[1], l.consiglio);
      expect(senza.paragrafi[2], startsWith(l.legame));
      expect(senza.paragrafi[2], endsWith(senza.domanda));
      final con = TarotReading.of(s, TarotTopic.momentoCheVivo,
          domandaScritta: 'Devo cambiare casa?', dalModello: l);
      expect(con.paragrafi, hasLength(3));
    });

    test('A2: da dove viene nomina le carte, il mazzo e la stesa', () {
      final s = TarotSpread.draw(seed: 5);
      final d = TarotReading.daDoveViene(s,
          mazzo: TarotDeckStyle.marsiglia.label,
          stesa: TarotSpreadType.treCarte.nome);
      for (final c in s.cards) {
        expect(d, contains(c.displayName));
      }
      expect(d, contains('Marsiglia'));
      expect(d, contains(TarotSpreadType.treCarte.nome));
    });
  });

  group('il pannello delle fonti', () {
    test('A5: ogni mazzo e ogni stesa portano la loro fonte', () {
      var quanti = 0;
      for (final m in TarotDeckStyle.values) {
        for (final st in TarotSpreadType.values) {
          quanti++;
          final t = LeFontiDeiTarocchi.testo(m, st);
          expect(t, contains(st.fonte));
          expect(t, contains(st.nome));
          expect(t, contains(LeFontiDeiTarocchi.delMazzo(m)));
        }
      }
      cardinaleMinimo(quanti, 12, cosa: 'coppie di mazzo e stesa');
      final croce = LeFontiDeiTarocchi.testo(
          TarotDeckStyle.riderWaite, TarotSpreadType.dieciCarte);
      expect(croce, contains('Parte III, sezione 7'));
      expect(croce, contains(LeFontiDeiTarocchi.gradoDiWaite));
      expect(croce.toLowerCase(), isNot(contains('capitolo')));
    });
  });

  group('a video', () {
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

    Future<void> monta(WidgetTester tester) async {
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
        child: const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: MaestroScope(
            child: StesaTreCarteScreen(
              seed: 2,
              revealAll: true,
              skipIntro: true,
              topic: TarotTopic.bivio,
            ),
          ),
        ),
      ));
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));
    }

    String testoSotto(WidgetTester tester, Finder dove) => [
          for (final t in tester.widgetList<Text>(
              find.descendant(of: dove, matching: find.byType(Text))))
            t.data ?? '',
        ].join(' ');

    testWidgets('A1 e A2: il titolo, tre paragrafi, il riquadro, da dove viene',
        (tester) async {
      await monta(tester);
      final titolo =
          testoSotto(tester, find.byKey(const Key('stesa_synthesis')));
      expect(VoceDellaStesa.titoliDelPresente.values.expand((v) => v),
          contains(titolo),
          reason: 'il titolo in cima non e\' quello della risposta: "$titolo"');
      for (var i = 0; i < 3; i++) {
        expect(find.byKey(Key('responso_paragrafo_$i')), findsOneWidget);
      }
      expect(
          find.descendant(
              of: find.byType(RiquadroInEvidenza),
              matching: find.byKey(const Key('responso_paragrafo_1'))),
          findsOneWidget,
          reason: 'il secondo paragrafo non sta nel riquadro');
      expect(
          find.descendant(
              of: find.byType(RiquadroInEvidenza),
              matching: find.byKey(const Key('responso_paragrafo_0'))),
          findsNothing);
      final dove = find.byKey(const Key('responso_da_dove_viene'));
      expect(dove, findsOneWidget);
      expect(tester.widget<Text>(dove).style!.fontStyle, FontStyle.italic);
      expect(
          tester.getTopLeft(dove).dy,
          greaterThan(tester
              .getBottomLeft(find.byKey(const Key('responso_paragrafo_2')))
              .dy),
          reason: 'da dove viene non sta in fondo');
    });

    testWidgets('A3: le bolle per carta restano, ognuna col suo titolo',
        (tester) async {
      await monta(tester);
      final stesa = tester
          .state<StesaTreCarteScreenState>(find.byType(StesaTreCarteScreen))
          .stesaCorrente;
      cardinaleMinimo(stesa.cards.length, 3, cosa: 'carte della stesa');
      for (final d in stesa.cards) {
        final bolla = find.byKey(Key('stesa_letta_${d.position.name}'));
        expect(bolla, findsOneWidget,
            reason: 'manca la bolla di ${d.position.name}');
        final dentro = testoSotto(tester, bolla);
        expect(dentro, contains(d.displayName));
        expect(dentro, contains(d.position.label.toUpperCase()));
      }
    });
  });
}
