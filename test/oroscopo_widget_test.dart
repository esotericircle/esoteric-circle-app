import 'dart:io';

import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/horoscope/horoscope.dart';
import 'package:esoteric_circle/core/horoscope/horoscope_data.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/components/zodiac_glyph.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/horoscope/horoscope_visuals.dart';
import 'package:esoteric_circle/features/horoscope/oroscopo_screen.dart';
import 'package:esoteric_circle/features/horoscope/oroscopo_share_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// Oroscopo, i tre interventi lato widget: emblema brandizzato mai di sistema,
/// forme a tema legate al valore, card condivisibile senza overflow.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

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

  group('Zodiaco brandizzato, due asset distinti per segno', () {
    test('Emblema e simbolo sono due percorsi diversi per ogni segno', () {
      for (final z in Zodiac.values) {
        final emblem = ZodiacArt.emblemPath(z);
        final symbol = ZodiacArt.symbolPath(z);
        expect(emblem, startsWith('assets/img/zodiac/'));
        expect(symbol, startsWith('assets/img_thumb/zodiac/'));
        expect(emblem, isNot(equals(symbol)),
            reason: 'emblema e simbolo coincidono per ${z.id}');
      }
    });

    test('Tutti i ventiquattro asset esistono nel bundle', () {
      for (final z in Zodiac.values) {
        expect(File(ZodiacArt.emblemPath(z)).existsSync(), isTrue,
            reason: 'emblema mancante: ${ZodiacArt.emblemPath(z)}');
        expect(File(ZodiacArt.symbolPath(z)).existsSync(), isTrue,
            reason: 'simbolo mancante: ${ZodiacArt.symbolPath(z)}');
      }
    });

    testWidgets('La testa carica l\'emblema, il chip carica il simbolo',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              ZodiacEmblem(
                  sign: Zodiac.leo, size: 60, art: ZodiacEmblemArt.emblem),
              ZodiacEmblem(
                  sign: Zodiac.leo, size: 30, art: ZodiacEmblemArt.symbol),
            ],
          ),
        ),
      ));
      await tester.pump();
      final names = tester
          .widgetList<Image>(find.byType(Image))
          .map((i) => (i.image as AssetImage).assetName)
          .toList();
      // Due immagini distinte, la miniatura non e' l'emblema scalato.
      expect(names, contains(ZodiacArt.emblemPath(Zodiac.leo)));
      expect(names, contains(ZodiacArt.symbolPath(Zodiac.leo)));
    });
  });

  group('Schermata personalizzata', () {
    Future<void> pumpScreen(WidgetTester tester,
        {Zodiac sign = Zodiac.aries}) async {
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
      tester.view.physicalSize = const Size(440, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
          ChangeNotifierProvider(create: (_) => ZodiacController()),
          ChangeNotifierProvider(create: (_) => ProfileController()),
        ],
        child: MaterialApp(
          builder: (ctx, child) => MediaQuery(
            data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
            child: MaestroScope(child: child!),
          ),
          home: OroscopoScreen(userSign: sign, now: DateTime(2026, 7, 10)),
        ),
      ));
      // Niente pumpAndSettle: la pulsazione dell'emblema si ripete all'infinito.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
    }

    testWidgets('Non c\'e\' piu\' il selettore dei segni', (tester) async {
      await pumpScreen(tester);
      for (final z in Zodiac.values) {
        expect(find.byKey(Key('oroscopo_sign_${z.id}')), findsNothing,
            reason: 'il chip di ${z.italianName} e\' ancora nella schermata');
      }
      // Resta solo l'emblema del segno della persona.
      expect(find.byKey(const Key('oroscopo_emblem')), findsOneWidget);
    });

    testWidgets('Intestazione, data e selettore del periodo', (tester) async {
      await pumpScreen(tester);
      expect(find.byKey(const Key('oroscopo_heading')), findsOneWidget);
      expect(find.byKey(const Key('oroscopo_date')), findsOneWidget);
      expect(find.text('10 luglio 2026'), findsOneWidget);
      // Tre voci, con Settimana e Mese bloccate dal lucchetto.
      expect(find.byKey(const Key('oroscopo_period_giorno')), findsOneWidget);
      expect(find.byKey(const Key('oroscopo_lock_settimana')), findsOneWidget);
      expect(find.byKey(const Key('oroscopo_lock_mese')), findsOneWidget);
      expect(find.byKey(const Key('oroscopo_lock_giorno')), findsNothing);
    });

    testWidgets('L\'apertura personalizzata porta il nome della persona',
        (tester) async {
      await pumpScreen(tester);
      final opening = tester
          .widget<Text>(find.byKey(const Key('oroscopo_opening')))
          .data!;
      // Il profilo della Demo e' Sofia, femminile: vocativo "Cara Sofia".
      expect(opening, startsWith('Cara Sofia,'));
      // E resta una delle aperture del pool.
      final pool = HoroscopeData.openings
          .map((o) => o.replaceAll(HoroscopeData.namePlaceholder, 'Cara Sofia'))
          .toList();
      expect(pool, contains(opening));
    });

    testWidgets('Ogni scheda mostra il livello col numero', (tester) async {
      await pumpScreen(tester);
      final levels =
          tester.widgetList<DomainLevel>(find.byType(DomainLevel)).toList();
      expect(levels.length, 4);
      for (final l in levels) {
        expect(l.value, inInclusiveRange(1, 5));
        expect(find.text('${l.value} su 5'), findsWidgets);
      }
    });

    testWidgets('Il disclaimer compare una volta sola', (tester) async {
      await pumpScreen(tester);
      expect(find.byKey(const Key('oroscopo_disclaimer')), findsOneWidget);
    });
  });

  group('Card di condivisione', () {
    testWidgets('Si costruisce senza overflow per tutti i dodici segni',
        (tester) async {
      await loadFonts();
      for (final sign in Zodiac.values) {
        final cards =
            Horoscope.forSign(sign: sign, dayOfYear: 200, year: 2026);
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Center(
                child: OroscopoShareCard(
                    sign: sign, cards: cards, palette: palette),
              ),
            ),
          ),
        ));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull,
            reason: 'overflow nella card di ${sign.italianName}');

        // I livelli a tema restano legati al valore deterministico, da 1 a 5.
        final levels =
            tester.widgetList<DomainLevel>(find.byType(DomainLevel)).toList();
        expect(levels.length, 4);
        for (final l in levels) {
          final expected =
              cards.firstWhere((c) => c.domain == l.domain).indicator;
          expect(l.value, expected);
          expect(l.value, inInclusiveRange(1, 5));
          // Il numero esplicito accanto alla forma.
          expect(find.text('${l.value} su 5'), findsWidgets);
        }
      }
    });

    testWidgets('Numero e Colore sono due bolle uguali col titolo sopra',
        (tester) async {
      await loadFonts();
      final cards =
          Horoscope.forSign(sign: Zodiac.aries, dayOfYear: 190, year: 2026);
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Center(
              child: OroscopoShareCard(
                  sign: Zodiac.aries, cards: cards, palette: palette),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      // I due titoli ci sono.
      expect(find.text('NUMERO'), findsOneWidget);
      expect(find.text('COLORE'), findsOneWidget);
      // Le due bolle hanno la stessa misura.
      final numero = tester.getSize(find.ancestor(
          of: find.text('NUMERO'), matching: find.byType(Container)).first);
      final colore = tester.getSize(find.ancestor(
          of: find.text('COLORE'), matching: find.byType(Container)).first);
      expect((numero.width - colore.width).abs(), lessThan(1.0),
          reason: 'le bolle Numero e Colore hanno larghezza diversa');
      expect((numero.height - colore.height).abs(), lessThan(1.0),
          reason: 'le bolle Numero e Colore hanno altezza diversa');
    });

    testWidgets('Il titolo della Carriera non e\' troncato', (tester) async {
      await loadFonts();
      for (final sign in Zodiac.values) {
        final cards =
            Horoscope.forSign(sign: sign, dayOfYear: 190, year: 2026);
        final carriera =
            cards.firstWhere((c) => c.domain == HoroscopeDomain.carriera);
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Center(
                child: OroscopoShareCard(
                    sign: sign, cards: cards, palette: palette),
              ),
            ),
          ),
        ));
        await tester.pumpAndSettle();

        // Il titolo compare per intero, e nessun testo della card usa l'ellissi.
        expect(find.text(carriera.title), findsOneWidget,
            reason: 'titolo Carriera mancante per ${sign.italianName}');
        final troncati = tester
            .widgetList<Text>(find.byType(Text))
            .where((t) => t.overflow == TextOverflow.ellipsis)
            .where((t) => t.data == carriera.title);
        expect(troncati, isEmpty,
            reason: 'titolo Carriera troncato per ${sign.italianName}');
      }
    });
  });
}
