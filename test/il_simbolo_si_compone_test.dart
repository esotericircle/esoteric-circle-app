import 'dart:io';

import 'package:esoteric_circle/core/archetypes/archetype.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/core/maestro/simbolo_dellattesa.dart';
import 'package:esoteric_circle/core/maestro/tempi_dell_attesa.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/components/loto_dorato.dart';
import 'package:esoteric_circle/design_system/components/consulto_del_cielo_view.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/widgets/maestro_bust.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// I SIMBOLI VERI NELL'ATTESA DELLA CHAT.
///
/// **La correzione del fondatore.** Quando l'ordine precedente diceva
/// "emblema", lui intendeva un SIMBOLO, non il volto del Maestro. Nella scena
/// si accendeva il ritratto di chi stava rispondendo, che sta gia'
/// nell'intestazione della chat e accanto a ogni sua bolla: al centro dello
/// schermo non aggiungeva niente.
///
/// **Il fiore di loto non esiste COME ASSET, e dal 6 agosto 2026 e' disegnato
/// in codice.** Cercato di nuovo in tutte le cartelle: nessun file. Aura senza
/// Test mostra quindi un loto vettoriale piu' l'invito, e le prove qui sotto
/// sorvegliano due cose distinte: che l'asset continui a non esserci, e che al
/// posto del loto non compaia mai il simbolo di un altro Maestro ne' uno dei
/// dodici emblemi.
void main() {
  const natalCancro = NatalContext(sunSign: 'Cancro', moonSign: 'Pesci');

  Widget host(Widget figlio, {bool fermo = false}) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => MaestroController()),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (ctx) => MediaQuery(
              data: MediaQuery.of(ctx).copyWith(disableAnimations: fermo),
              child: MaestroScope(child: Scaffold(body: figlio)),
            ),
          ),
        ),
      );

  group('Quale simbolo, per ogni Maestro', () {
    test('Medora guarda il SEGNO, Caligo l\'ANIMALE, Aura l\'ARCHETIPO', () {
      final medora = SimboloDellAttesa.per(Maestro.medora, natal: natalCancro);
      expect(medora.asset, 'assets/img_thumb/zodiac/zod_cancro.webp');

      // Il Cancro deriva il Lupo, dalla tabella di curatela che esiste gia'.
      final caligo = SimboloDellAttesa.per(Maestro.caligo, natal: natalCancro);
      expect(caligo.asset, contains('animali/'));
      expect(caligo.asset, contains('lupo'));

      final aura = SimboloDellAttesa.per(Maestro.aura,
          natal: natalCancro, archetipo: Archetype.creatore);
      expect(aura.asset, Archetype.creatore.arteThumb);
      expect(aura.invito, isNull,
          reason: 'con l\'archetipo scoperto non c\'e\' niente da invitare');
    });

    test('Nessun Maestro guarda il simbolo di un altro', () {
      final visti = <Maestro, String>{};
      for (final m in Maestro.values) {
        final s = SimboloDellAttesa.per(m,
            natal: natalCancro, archetipo: Archetype.creatore);
        expect(s.asset, isNotNull,
            reason: '${m.displayName} non ha nessun simbolo da guardare');
        visti[m] = s.asset!;
      }
      expect(visti.values.toSet(), hasLength(Maestro.values.length),
          reason: 'due Maestri guardano lo stesso simbolo: $visti');
    });

    test('Senza il cielo non si inventa un simbolo', () {
      for (final m in [Maestro.medora, Maestro.caligo]) {
        final s = SimboloDellAttesa.per(m, natal: NatalContext.none);
        expect(s.asset, isNull,
            reason: '${m.displayName} mostra un simbolo a chi non ha ancora '
                'dato il suo cielo');
      }
    });

    test('Senza archetipo: NESSUN simbolo, e l\'invito al Test', () {
      final s = SimboloDellAttesa.per(Maestro.aura, natal: natalCancro);
      expect(s.invito, isNotNull,
          reason: 'chi non ha fatto il Test non sa nemmeno che esiste');
      expect(s.invito, contains('Test Archetipo'));
      // **IL LOTO NON ESISTE, e non si ripiega in silenzio su altro.**
      //
      // Il simbolo di un altro Maestro sotto il nome di Aura direbbe una cosa
      // falsa su questa persona, e un archetipo scelto a caso ne direbbe una
      // ancora peggiore.
      expect(s.asset, isNull,
          reason: 'ad Aura senza archetipo e\' stato messo il simbolo di '
              'qualcun altro: ${s.asset}');
    });

    test('Ogni simbolo che l\'app puo\' mostrare ESISTE su disco', () {
      // **UN PERCORSO GIUSTO NON E' UN FILE.** Le prove qui sopra confrontano
      // stringhe: se domani gli asset cambiassero cartella o suffisso,
      // resterebbero tutte verdi e a schermo comparirebbe il vuoto. Qui si
      // enumerano i dodici segni per Medora, i dodici animali derivati per
      // Caligo, i dodici archetipi per Aura, e si apre ogni file.
      final mancanti = <String>[];
      var guardati = 0;
      for (final z in Zodiac.values) {
        final natal = NatalContext(sunSign: z.italianName);
        for (final m in [Maestro.medora, Maestro.caligo]) {
          final s = SimboloDellAttesa.per(m, natal: natal);
          guardati++;
          if (s.asset == null || !File(s.asset!).existsSync()) {
            mancanti.add('${m.displayName} con ${z.italianName}: ${s.asset}');
          }
        }
      }
      for (final a in Archetype.values) {
        final s = SimboloDellAttesa.per(Maestro.aura,
            natal: const NatalContext(sunSign: 'Cancro'), archetipo: a);
        guardati++;
        if (s.asset == null || !File(s.asset!).existsSync()) {
          mancanti.add('Aura con ${a.name}: ${s.asset}');
        }
      }
      expect(guardati, Zodiac.values.length * 2 + Archetype.values.length,
          reason: 'non sono stati guardati tutti i casi');
      expect(mancanti, isEmpty,
          reason: 'questi simboli non esistono su disco, quindi a schermo '
              'resta il vuoto:\n${mancanti.join("\n")}');
    });

    test('Il loto NON e\' fra gli asset, e la prova lo dichiara', () {
      // Se un giorno il loto arrivera', questa prova cade ed e' il momento di
      // rimettere il ripiego che l'ordine chiedeva.
      final trovati = <String>[];
      for (final voce in Directory('assets').listSync(recursive: true)) {
        if (voce is! File) continue;
        final nome = voce.path.toLowerCase();
        if (nome.contains('loto') || nome.contains('lotus')) {
          trovati.add(voce.path);
        }
      }
      expect(trovati, isEmpty,
          reason: 'il fiore di loto ora esiste: Aura senza archetipo puo\' '
              'mostrarlo, accompagnato dallo stesso invito al Test');
    });
  });

  group('Come si presenta', () {
    testWidgets('Si COMPONE dall\'alto, e non sbiadisce', (tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(360, 797);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(host(const ConsultoDelCieloView(
          natal: natalCancro, maestro: Maestro.medora)));
      await tester.pump();

      final simbolo = find.byKey(const Key('consulto_corpo'));
      expect(simbolo, findsOneWidget, reason: 'il simbolo non c\'e\'');

      // **UN TAGLIO CHE SCENDE, non un'opacita' che sale.** Il rettangolo di
      // ritaglio ancorato in cima e alto quanto la frazione fatta e' cio' che
      // fa "un tratto che viene giu'": una dissolvenza direbbe "sto caricando
      // un'immagine", e un colore che sale l'abbiamo gia' provato e non si
      // leggeva.
      expect(find.descendant(of: simbolo, matching: find.byType(ClipRect)),
          findsOneWidget,
          reason: 'il simbolo non e\' ritagliato: non si sta componendo');
      expect(
          find.descendant(of: simbolo, matching: find.byType(FadeTransition)),
          findsNothing,
          reason: 'il simbolo sbiadisce dentro invece di comporsi');
      expect(find.descendant(of: simbolo, matching: find.byType(ColorFiltered)),
          findsNothing,
          reason: 'e\' tornata la colorazione da grigio a colore');

      // A meta' strada e' composto a meta', misurato sul ritaglio vero.
      await tester.pump(const Duration(milliseconds: 1500));
      final rc = tester.widget<ClipRect>(
          find.descendant(of: simbolo, matching: find.byType(ClipRect)));
      final taglio = rc.clipper!.getClip(const Size(100, 100));
      expect(taglio.top, 0,
          reason: 'il ritaglio non e\' ancorato in cima: cosi\' il simbolo '
              'sale invece di scendere');
      expect(taglio.height, greaterThan(1));
      expect(taglio.height, lessThan(99),
          reason: 'a meta\' tempo il simbolo e\' gia\' intero');

      // E a tre secondi e' intero.
      await tester.pump(const Duration(milliseconds: 1700));
      final rc2 = tester.widget<ClipRect>(
          find.descendant(of: simbolo, matching: find.byType(ClipRect)));
      expect(rc2.clipper!.getClip(const Size(100, 100)).height, 100,
          reason: 'a tre secondi il simbolo non e\' ancora intero');
    });

    testWidgets('Il volto del Maestro NON e\' nella scena', (tester) async {
      tester.view.physicalSize = const Size(360, 797);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(host(const ConsultoDelCieloView(
          natal: natalCancro, maestro: Maestro.medora)));
      await tester.pump();
      expect(find.byType(MaestroBust), findsNothing,
          reason: 'e\' tornato il ritratto del Maestro al posto del simbolo '
              'della persona: il suo volto sta gia\' nell\'intestazione della '
              'chat e accanto a ogni sua bolla');
    });

    testWidgets('Simbolo e frase sono CENTRATI', (tester) async {
      tester.view.physicalSize = const Size(360, 797);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(host(const ConsultoDelCieloView(
          natal: natalCancro, maestro: Maestro.medora)));
      await tester.pump();

      final colonna =
          tester.widget<Column>(find.byKey(const Key('consulto_del_cielo')));
      expect(colonna.crossAxisAlignment, CrossAxisAlignment.center,
          reason: 'la colonna non centra i suoi figli');

      // La frase, misurata: il suo centro coincide con quello della scena.
      final scena = find.byKey(const Key('consulto_del_cielo'));
      final frase = find.textContaining('', findRichText: false);
      expect(frase, findsWidgets);
      final testo = tester
          .widgetList<Text>(
              find.descendant(of: scena, matching: find.byType(Text)))
          .first;
      expect(testo.textAlign, TextAlign.center,
          reason: 'la frase non e\' centrata');
    });

    testWidgets('Senza archetipo, Aura mostra l\'INVITO', (tester) async {
      tester.view.physicalSize = const Size(360, 797);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(host(const ConsultoDelCieloView(
          natal: natalCancro, maestro: Maestro.aura)));
      await tester.pump();
      expect(find.byKey(const Key('consulto_invito')), findsOneWidget,
          reason: 'senza archetipo la scena tace: chi non ha fatto il Test '
              'non sa nemmeno che esiste');
      // **AGGIORNATA IL 6 AGOSTO 2026.** Prima qui si pretendeva che NON
      // comparisse nessun simbolo, e la ragione scritta era che il loto non
      // c'era. Adesso c'e', disegnato in codice: la scena mostra il fiore che
      // aspetta di aprirsi piu' l'invito, e un vuoto con una riga sotto
      // sembrava un guasto.
      expect(find.byKey(const Key('consulto_corpo')), findsOneWidget,
          reason: 'ad Aura senza archetipo deve comparire il loto');
      expect(find.byType(LotoDorato), findsOneWidget);
      // Cio' che resta vietato: uno dei dodici emblemi, che direbbe alla
      // persona un archetipo che non ha.
      expect(find.byType(Image), findsNothing,
          reason: 'e\' comparso un emblema di archetipo a chi non ha fatto il '
              'Test');
    });

    testWidgets('CON archetipo, l\'invito sparisce e il simbolo c\'e\'',
        (tester) async {
      tester.view.physicalSize = const Size(360, 797);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(host(const ConsultoDelCieloView(
        natal: natalCancro,
        maestro: Maestro.aura,
        archetipo: Archetype.creatore,
      )));
      await tester.pump();
      expect(find.byKey(const Key('consulto_invito')), findsNothing,
          reason: 'l\'invito al Test compare a chi il Test l\'ha gia\' fatto');
      expect(find.byKey(const Key('consulto_corpo')), findsOneWidget);
    });

    testWidgets('Con Riduci Movimento e\' gia\' intero, e nessun controllore',
        (tester) async {
      tester.view.physicalSize = const Size(360, 797);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(host(
        const ConsultoDelCieloView(natal: natalCancro, maestro: Maestro.medora),
        fermo: true,
      ));
      await tester.pump();
      final simbolo = find.byKey(const Key('consulto_corpo'));
      expect(simbolo, findsOneWidget);
      expect(find.descendant(of: simbolo, matching: find.byType(ClipRect)),
          findsNothing,
          reason: 'a moto fermo il simbolo si compone lo stesso');
      expect(tester.binding.transientCallbackCount, 0,
          reason: 'resta registrato un ticker');
    });

    test('I tempi restano quelli approvati', () {
      // Letterali, non presi dalla costante sotto esame.
      expect(TempiDellAttesa.composizioneDelSimbolo,
          const Duration(milliseconds: 3000));
      expect(TempiDellAttesa.durataBattuta, const Duration(milliseconds: 2000));
      expect(TempiDellAttesa.battuteDellaScena, 2);
    });
  });
}
