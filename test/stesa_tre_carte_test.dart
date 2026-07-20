import 'dart:io';

import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/tarot/tarot_card.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/horoscope/answer_depth.dart';
import 'package:esoteric_circle/core/tarot/tarot_reading.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread_type.dart';
import 'package:esoteric_circle/core/tarot/tarot_topic.dart';
import 'package:esoteric_circle/features/tarot/medora_stage.dart';
import 'package:esoteric_circle/features/tarot/stesa_share_card.dart';
import 'package:esoteric_circle/features/tarot/stesa_tre_carte_screen.dart';
import 'package:esoteric_circle/features/tarot/tarot_selectors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// Stesa a Tre Carte: pescaggio distinto e riproducibile, versi coerenti col
/// testo del corpus, arte mappata per ogni carta, card condivisibile solida.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> loadFonts() async {
    for (final f in const [
      ['Cinzel', 'assets/fonts/Cinzel-variable.ttf'],
      ['EBGaramond', 'assets/fonts/EBGaramond-variable.ttf'],
    ]) {
      final loader = FontLoader(f[0]);
      loader.addFont(
          Future.value(ByteData.view(File(f[1]).readAsBytesSync().buffer)));
      await loader.load();
    }
  }

  final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.medora));

  /// Monta la schermata con tutti i controller che il cosmo richiede.
  Future<void> pumpScreen(WidgetTester tester, {int seed = 2}) async {
    await loadFonts();
    // Alta abbastanza da tenere in campo tutti e sette gli strati: quel che
    // la lista non costruisce, il test non lo troverebbe.
    tester.view.physicalSize = const Size(390, 4400);
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
        home: MaestroScope(
          child: StesaTreCarteScreen(seed: seed, revealAll: true),
        ),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
  }



  group('Pescaggio', () {
    test('La stesa pesca tre carte distinte', () {
      for (var seed = 0; seed < 200; seed++) {
        final spread = TarotSpread.draw(seed: seed);
        expect(spread.cards.length, 3);
        final stems = spread.cards.map((c) => c.card.stem).toSet();
        expect(stems.length, 3, reason: 'carta ripetuta col seme $seed');
        // Le tre posizioni sono quelle giuste, nell'ordine di lettura.
        expect(spread.cards.map((c) => c.position).toList(),
            SpreadPosition.values);
      }
    });

    test('Con seme fisso la stesa e\' sempre la stessa', () {
      final a = TarotSpread.draw(seed: 12345);
      final b = TarotSpread.draw(seed: 12345);
      for (var i = 0; i < a.cards.length; i++) {
        expect(a.cards[i].card.stem, b.cards[i].card.stem);
        expect(a.cards[i].reversed, b.cards[i].reversed);
      }
      expect(a.reading, b.reading);
      expect(a.synthesis, b.synthesis);
    });

    test('Il rovesciato esce, ma resta la minoranza', () {
      var reversed = 0;
      var total = 0;
      for (var seed = 0; seed < 400; seed++) {
        for (final drawn in TarotSpread.draw(seed: seed).cards) {
          total++;
          if (drawn.reversed) reversed++;
        }
      }
      final quota = reversed / total;
      // Intorno a 0,30, con margine largo perche' e' pur sempre un caso.
      expect(quota, greaterThan(0.20));
      expect(quota, lessThan(0.42));
    });
  });

  group('Versi coerenti col corpus', () {
    test('Il testo mostrato segue sempre il verso della carta', () {
      for (var seed = 0; seed < 200; seed++) {
        for (final drawn in TarotSpread.draw(seed: seed).cards) {
          if (drawn.reversed) {
            expect(drawn.meaning, drawn.card.reversed);
            expect(drawn.summary, drawn.card.reversedSummary);
            // La parola del rovescio e' accordata alla carta, dal catalogo.
            expect(drawn.displayName,
                '${drawn.card.name} ${drawn.card.reversedWord}');
          } else {
            expect(drawn.meaning, drawn.card.upright);
            expect(drawn.summary, drawn.card.uprightSummary);
            expect(drawn.displayName, drawn.card.name);
            expect(drawn.displayName, drawn.card.name);
          }
        }
      }
    });

    test('La sintesi viene dalla carta del Presente', () {
      for (var seed = 0; seed < 50; seed++) {
        final spread = TarotSpread.draw(seed: seed);
        expect(spread.synthesis, spread.presente.summary);
        expect(spread.presente.position, SpreadPosition.presente);
      }
    });

    test('La lettura concatena le tre posizioni', () {
      final spread = TarotSpread.draw(seed: 7);
      for (final drawn in spread.cards) {
        expect(spread.reading, contains(drawn.displayName));
        expect(spread.reading, contains(drawn.meaning));
      }
    });
  });

  group('Mazzo e arte', () {
    test('Settantotto carte, stem unici', () {
      expect(TarotDeck.cards.length, 78);
      expect(TarotDeck.cards.map((c) => c.stem).toSet().length, 78);
    });

    test('Ogni carta ha la sua arte mappata, piena e miniatura', () {
      for (final card in TarotDeck.cards) {
        expect(File(card.fullPath).existsSync(), isTrue,
            reason: 'arte mancante per ${card.name}: ${card.fullPath}');
        expect(File(card.thumbPath).existsSync(), isTrue,
            reason: 'miniatura mancante per ${card.name}');
      }
      // E il dorso di Medora per le carte coperte.
      expect(File(TarotDeck.dorsoFull).existsSync(), isTrue);
    });

    test('Ogni carta porta entrambi i versi, non vuoti', () {
      for (final card in TarotDeck.cards) {
        expect(card.name.trim(), isNotEmpty);
        expect(card.uprightSummary.trim(), isNotEmpty);
        expect(card.upright.trim(), isNotEmpty);
        expect(card.reversedSummary.trim(), isNotEmpty);
        expect(card.reversed.trim(), isNotEmpty);
      }
      // I Minori hanno seme e numero, i Maggiori no.
      for (final card in TarotDeck.cards) {
        if (card.arcana == TarotArcana.minore) {
          expect(card.seme, isNotNull, reason: '${card.name} senza seme');
          expect(card.number, isNotNull);
        } else {
          expect(card.seme, isNull);
        }
      }
    });
  });

  group('Accenti veri, mai apostrofo al posto dell\'accento', () {
    final vowelApostrophe = RegExp("[aeiou]'", caseSensitive: false);
    final letter = RegExp('[a-zA-Zàèéìòù]');

    String? offending(String s) {
      for (final m in vowelApostrophe.allMatches(s)) {
        final apo = m.end - 1;
        if (apo + 1 < s.length && letter.hasMatch(s[apo + 1])) continue;
        final vowel = m.start;
        final prev = vowel > 0 ? s[vowel - 1].toLowerCase() : '';
        final pair = '$prev${s[vowel].toLowerCase()}';
        const troncamenti = {'po', 'mo', 'be', 'di', 'fa', 'da', 'va'};
        if (troncamenti.contains(pair)) continue;
        final start = (vowel - 10).clamp(0, s.length);
        return s.substring(start, (apo + 2).clamp(0, s.length));
      }
      return null;
    }

    test('Nessun apostrofo-accento nel mazzo e nei testi della stesa', () {
      for (final card in TarotDeck.cards) {
        for (final s in [
          card.name,
          card.uprightSummary,
          card.upright,
          card.reversedSummary,
          card.reversed,
        ]) {
          expect(offending(s), isNull, reason: 'in "$s"');
        }
      }
      expect(offending(TarotSpread.closing), isNull);
      expect(offending(TarotSpread.disclaimer), isNull);
      for (var seed = 0; seed < 30; seed++) {
        expect(offending(TarotSpread.draw(seed: seed).reading), isNull);
      }
    });

    test('Nessuna virgola seguita da e nei testi della stesa', () {
      final vietato = RegExp(r',\s+ed?\b');
      expect(vietato.hasMatch(TarotSpread.closing), isFalse);
      expect(vietato.hasMatch(TarotSpread.disclaimer), isFalse);
    });
  });

  group('Card di condivisione', () {
    testWidgets('Si costruisce senza overflow su un campione ampio di stese',
        (tester) async {
      await loadFonts();
      for (var seed = 0; seed < 24; seed++) {
        final spread = TarotSpread.draw(seed: seed);
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Center(
                child: StesaShareCard(spread: spread, palette: palette),
              ),
            ),
          ),
        ));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull,
            reason: 'overflow nella card col seme $seed');

        // I tre arcani col loro verso e la loro posizione ci sono. Il nome sta
        // su una riga sua e il verso sotto, cosi' nessuna parola si spezza.
        for (final drawn in spread.cards) {
          // Il nome puo' comparire due volte: nella lista delle tre posizioni
          // e, se e' lei, come carta chiave in evidenza.
          expect(find.text(drawn.displayName), findsWidgets);
          expect(find.text(drawn.position.label.toUpperCase()), findsWidgets);
        }
        expect(find.text(spread.synthesis), findsOneWidget);
      }
    });
  });

  group('Espressione di Medora', () {
    test('Nasce in modo deterministico dalla carta attiva', () {
      final maggiore =
          TarotDeck.cards.firstWhere((c) => c.arcana == TarotArcana.maggiore);
      final minore =
          TarotDeck.cards.firstWhere((c) => c.arcana == TarotArcana.minore);
      DrawnCard d(TarotCard c, bool r) => DrawnCard(
          card: c, position: SpreadPosition.presente, reversed: r);

      expect(MedoraExpression.forCard(null), MedoraExpression.serena);
      expect(MedoraExpression.forCard(d(maggiore, false)),
          MedoraExpression.sorrisoCaldo);
      expect(MedoraExpression.forCard(d(minore, false)),
          MedoraExpression.serena);
      // Il rovesciato porta ombra, Maggiore o Minore che sia.
      expect(MedoraExpression.forCard(d(maggiore, true)),
          MedoraExpression.sguardoGrave);
      expect(MedoraExpression.forCard(d(minore, true)),
          MedoraExpression.sguardoGrave);
      // E resta stabile a ogni chiamata.
      expect(MedoraExpression.forCard(d(maggiore, false)),
          MedoraExpression.forCard(d(maggiore, false)));
    });
  });

  group('Selettori prima della stesa', () {
    test('Le voci pronte e quelle in arrivo sono quelle giuste', () {
      expect(ReadingKey.predittiva.available, isTrue);
      expect(ReadingKey.riflessione.available, isFalse);
      expect(ReadingKey.esoterica.available, isFalse);
      expect(TarotDeckStyle.riderWaite.available, isTrue);
      expect(TarotDeckStyle.marsiglia.available, isFalse);
      expect(TarotDeckStyle.thoth.available, isFalse);
      // Jodorowsky e' citato come ispirazione, mai come marchio.
      final nota = ReadingKey.riflessione.note!;
      expect(nota.toLowerCase(), contains('ispirata'));
      expect(nota.toLowerCase(), contains('senza rapporto ufficiale'));
    });

    test('Le impostazioni di partenza sono quelle del gratuito', () {
      const setup = TarotSetup();
      expect(setup.key, ReadingKey.predittiva);
      expect(setup.deck, TarotDeckStyle.riderWaite);
      expect(setup.depth, AnswerDepth.free);
      // Le carte rovesciate sono incluse di default.
      expect(setup.includeReversed, isTrue);
    });


    testWidgets('Di base la configurazione sta richiusa in una riga',
        (tester) async {
      await loadFonts();
      var aperto = false;
      await tester.pumpWidget(StatefulBuilder(
        builder: (context, setState) => MaterialApp(
          home: Scaffold(
            body: Center(
              child: TarotSetupPanel(
                setup: const TarotSetup(),
                palette: palette,
                aperto: aperto,
                onToggle: () => setState(() => aperto = !aperto),
                onChanged: (_) {},
                onLocked: (_) {},
              ),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      // Richiusa: si vede il riepilogo, non i selettori.
      expect(find.byKey(const Key('stesa_setup_riga')), findsOneWidget);
      expect(find.byKey(const Key('stesa_setup')), findsNothing);
      expect(find.byKey(const Key('stesa_chiave')), findsNothing);
      const setup = TarotSetup();
      for (final pezzo in [
        setup.topic.label.split(',').first,
        setup.deck.label,
      ]) {
        expect(find.textContaining(pezzo), findsOneWidget,
            reason: 'il riepilogo non dice $pezzo');
      }

      // Al tocco si apre, e nessun selettore e' andato perso.
      await tester.tap(find.byKey(const Key('stesa_setup_riga')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('stesa_setup')), findsOneWidget);
      for (final chiave in const [
        'stesa_tipo',
        'stesa_topic',
        'stesa_chiave',
        'stesa_mazzo',
        'stesa_depth',
        'stesa_reversed_switch',
      ]) {
        expect(find.byKey(Key(chiave)), findsOneWidget,
            reason: 'manca il selettore $chiave');
      }

      // E si richiude.
      await tester.tap(find.byKey(const Key('stesa_setup_chiudi')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('stesa_setup_riga')), findsOneWidget);
    });

    testWidgets('Le voci in arrivo stanno dentro la loro tendina',
        (tester) async {
      await loadFonts();
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: TarotSetupPanel(
              setup: const TarotSetup(),
              palette: palette,
              aperto: true,
              onChanged: (_) {},
              onLocked: (_) {},
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      // Da chiuse, le tendine non occupano righe con le voci bloccate: prima
      // Chiave e Mazzo si mangiavano tre righe ciascuno.
      expect(find.text('Riflessione Jodorowsky'), findsNothing);
      expect(find.text('Marsiglia'), findsNothing);

      // Aperta la Chiave, le voci in arrivo sono li' col lucchetto e la nota.
      await tester.tap(find.byKey(const Key('stesa_chiave')));
      await tester.pumpAndSettle();
      expect(find.text('Riflessione Jodorowsky'), findsOneWidget);
      expect(find.text('Esoterica Caligo'), findsOneWidget);
      expect(find.text('Coming soon'), findsNWidgets(2));
      // La nota etica compare in contesto, sulla sua voce.
      expect(find.textContaining('Jodorowsky, senza rapporto ufficiale'),
          findsOneWidget);
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      // E il Mazzo si comporta allo stesso modo.
      await tester.tap(find.byKey(const Key('stesa_mazzo')));
      await tester.pumpAndSettle();
      expect(find.text('Marsiglia'), findsOneWidget);
      expect(find.text('Thoth'), findsOneWidget);
      expect(find.text('Coming soon'), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    });
  });

  group('Schermata della stesa', () {
    testWidgets('Medora presiede, i nomi sono grandi, la firma c\'e\'',
        (tester) async {
      await pumpScreen(tester);
      expect(tester.takeException(), isNull);
      // Medora in scena.
      expect(find.byKey(const Key('medora_stage')), findsOneWidget);
      expect(find.byType(MedoraStage), findsOneWidget);
      // Sotto ogni carta: la posizione, poi il nome grande in chiaro.
      final spread = TarotSpread.draw(seed: 2);
      for (final drawn in spread.cards) {
        expect(find.byKey(Key('stesa_name_${drawn.position.name}')),
            findsOneWidget);
        final testo = tester.widget<Text>(
            find.byKey(Key('stesa_name_${drawn.position.name}')));
        // Il nome grande porta la stessa spezzatura del cartiglio.
        expect(testo.data!.replaceAll('\n', ' '), drawn.card.name);
        // Grande davvero, non la misura del cartiglio.
        expect(testo.style!.fontSize, greaterThanOrEqualTo(15.0));
        // La posizione e' scritta in maiuscoletto sopra il nome.
        expect(find.text(drawn.position.label.toUpperCase()), findsWidgets);
        if (drawn.reversed) {
          expect(find.byKey(Key('stesa_reversed_${drawn.position.name}')),
              findsOneWidget);
        }
      }
      // Il sigillo e' stato tolto: era un abbellimento senza valore per chi
      // legge, ne' un consiglio ne' una sua caratteristica.
      expect(find.byKey(const Key('stesa_signature')), findsNothing);
      expect(find.text('SIGILLO'), findsNothing);
    });
  });

  group('Presenza di Medora, rifiniture', () {
    test('Medora e piu grande, con l\'innesto intatto', () {
      // La scala e cresciuta: il mezzo busto riempie la scena.
      const stage = MedoraStage(palette: MaestroPalette.neutral);
      expect(stage.height, greaterThanOrEqualTo(300.0),
          reason: 'il mezzo busto e tornato piccolo');
      // L'innesto non e stato toccato: stesso asset segnaposto, stesso respiro,
      // stessa mappa delle espressioni. Qui cambia solo la scala, perche'
      // l'animazione Rive prendera' il posto del segnaposto senza rifare nulla.
      expect(MedoraStage.placeholderAsset,
          'brand_assets/avatars/Medora-1.png');
      expect(stage.breathe, isTrue);
      expect(stage.active, isNull);
      expect(MedoraExpression.values.length, 3);
    });
  });

  group('Argomento e profondita nella schermata', () {
    testWidgets('La tendina argomento mostra i sedici in tre gruppi',
        (tester) async {
      await loadFonts();
      var scelto = TarotTopic.predefinito;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Center(
            child: TendinaSelettore<TarotTopic>(
              chiave: const Key('stesa_topic'),
              titolo: 'Scegli argomento',
              corrente: scelto,
              voci: TarotTopic.values,
              palette: palette,
              etichetta: (t) => t.label,
              gruppo: (t) => t.group.label,
              bloccata: (_) => false,
              onSelect: (t) => scelto = t,
              onLocked: (_) {},
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text(TarotTopic.predefinito.label), findsOneWidget);

      await tester.tap(find.byKey(const Key('stesa_topic')));
      await tester.pumpAndSettle();
      for (final g in TarotTopicGroup.values) {
        expect(find.text(g.label.toUpperCase()), findsOneWidget);
      }
      for (final t in TarotTopic.values) {
        expect(find.text(t.label), findsWidgets,
            reason: 'manca l argomento ${t.label}');
      }
      for (final vietato in const ['Salute', 'Legale', 'Malattia']) {
        expect(find.text(vietato), findsNothing);
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('La profondita e una sola per tutta la lettura',
        (tester) async {
      await pumpScreen(tester);
      // Nessun selettore per posizione: le tre posizioni sono una lettura
      // unica e continua, e una profondita' per posizione darebbe un racconto
      // sbilanciato.
      for (final p in SpreadPosition.values) {
        expect(find.byKey(Key('stesa_depth_${p.name}')), findsNothing,
            reason: 'e rimasta una profondita in ${p.label}');
      }
      // Quella che governa tutto vive nella configurazione, con Breve libera.
      const setup = TarotSetup();
      expect(setup.depth, AnswerDepth.free);
      expect(AnswerDepth.free.premium, isFalse);
      for (final d in AnswerDepth.values.where((d) => d != AnswerDepth.free)) {
        expect(d.premium, isTrue, reason: '${d.label} dovrebbe essere Premium');
      }
      // E la lettura la porta con se', una sola per tutti i testi.
      final reading = TarotReading.of(
          TarotSpread.draw(seed: 2), TarotTopic.predefinito,
          depth: AnswerDepth.lunga);
      expect(reading.depth, AnswerDepth.lunga);
    });

    testWidgets('Il titolo segue la stesa attiva', (tester) async {
      await pumpScreen(tester);
      // Il nome non e' scritto a mano nella schermata: viene dalla
      // definizione della stesa, quindi cambiera' da solo quando arriveranno
      // quelle da sette e dieci carte.
      expect(find.byKey(const Key('stesa_titolo')), findsOneWidget);
      final titolo =
          tester.widget<Text>(find.byKey(const Key('stesa_titolo')));
      expect(titolo.data, TarotSpreadType.predefinita.nome);
      expect(titolo.data, 'Stesa a Tre Carte');
    });

    test('Le tre stese esistono, solo la prima e aperta', () {
      expect(TarotSpreadType.values.length, 3);
      expect(TarotSpreadType.treCarte.disponibile, isTrue);
      expect(TarotSpreadType.treCarte.carte, 3);
      for (final t in const [
        TarotSpreadType.setteCarte,
        TarotSpreadType.dieciCarte,
      ]) {
        expect(t.disponibile, isFalse, reason: '${t.nome} non e Coming soon');
      }
      // Ogni stesa porta il proprio nome, e sono tutti diversi.
      expect(TarotSpreadType.values.map((t) => t.nome).toSet().length, 3);
      for (final t in TarotSpreadType.values) {
        expect(t.nome, contains('Stesa'));
        expect(t.carte, greaterThan(0));
      }
    });

    testWidgets('La schermata mostra i sette strati', (tester) async {
      await pumpScreen(tester);
      final spread = TarotSpread.draw(seed: 2);
      final reading = TarotReading.of(spread, TarotTopic.predefinito);

      // 1. Sintesi forte, dal Presente.
      expect(find.byKey(const Key('stesa_synthesis')), findsOneWidget);
      expect(
          tester
              .widget<Text>(find.byKey(const Key('stesa_synthesis')))
              .data,
          reading.sintesi);
      // 2. Le tre posizioni col testo ricco.
      for (final p in SpreadPosition.values) {
        expect(find.byKey(Key('stesa_letta_${p.name}')), findsOneWidget);
      }
      // 3, 4, 5, 6. Dialogo, chiave, consiglio, domanda.
      for (final chiave in const [
        'stesa_dialogo',
        'stesa_chiave',
        'stesa_consiglio',
        'stesa_domanda',
      ]) {
        expect(find.byKey(Key(chiave)), findsOneWidget, reason: 'manca $chiave');
      }
      // 7. Azioni piu' disclaimer, una sola volta.
      expect(find.byKey(const Key('stesa_share')), findsOneWidget);
      expect(find.byKey(const Key('stesa_disclaimer')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
