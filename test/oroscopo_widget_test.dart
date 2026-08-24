import 'dart:io';

import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/astro/natal_chart.dart';
import 'package:esoteric_circle/core/horoscope/cielo_di_oggi.dart';
import 'package:esoteric_circle/core/horoscope/horoscope.dart';
import 'package:esoteric_circle/core/horoscope/horoscope_data.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/components/zodiac_glyph.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/horoscope/answer_depth.dart';
import 'package:esoteric_circle/features/horoscope/horoscope_visuals.dart';
import 'package:esoteric_circle/features/horoscope/oroscopo_screen.dart';
import 'package:esoteric_circle/features/horoscope/oroscopo_share_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/horoscope/riflessione_del_cielo.dart';
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
          ChangeNotifierProvider(create: (_) => EntitlementService()),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
          ChangeNotifierProvider(create: (_) => ZodiacController()),
          ChangeNotifierProvider(create: (_) => ProfileController()),
          // Il cielo di chi guarda: da qui l'Oroscopo prende la carta natale
          // per comporre dai transiti veri invece che dalla hash. Senza questo
          // provider la schermata non si monta, ed e' giusto cosi': una
          // schermata che si arrangia da sola quando manca un dato e' una
          // schermata che nasconde il dato mancante.
          ChangeNotifierProvider(create: (_) => BirthIdentityController()),
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
      // **IL CIELO SI INTERROGA, ordine 2171 voce 5.** Dal 10 agosto 2026
      // l'oroscopo non si apre gia' scritto: prima del tocco non c'e' nessun
      // responso da misurare, e queste prove misurano i responsi.
      final interroga = find.byKey(const Key('oroscopo_interroga'));
      if (interroga.evaluate().isNotEmpty) {
        await tester.tap(interroga);
        await tester.pump();
        // **ORDINE BK: dopo il tocco c'e' la riflessione, poi le schede si
        // compongono a CASCATA.** Prima bastava attendere la scrittura; adesso
        // il responso arriva quando i due momenti sono passati e l'ultima
        // scheda ha finito. Il numero viene dal dato e non e' battuto qui.
        await tester.pump(RiflessioneDelCielo.finoAllUltimaScheda(
            HoroscopeDomain.values.length,
            piena: true));
        await tester.pump(const Duration(milliseconds: 200));
        await tester.pump(const Duration(milliseconds: 600));
      }
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
      final opening =
          tester.widget<Text>(find.byKey(const Key('oroscopo_opening'))).data!;
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

    testWidgets('Il disclaimer non compare qui, ne\' altrove', (tester) async {
      await pumpScreen(tester);
      expect(find.byKey(const Key('oroscopo_disclaimer')), findsNothing);
    });

    testWidgets('Cinque icone di livello riempite da sinistra, col numero',
        (tester) async {
      await pumpScreen(tester);
      final levels =
          tester.widgetList<DomainLevel>(find.byType(DomainLevel)).toList();
      expect(levels.length, 4);
      for (final l in levels) {
        expect(l.value, inInclusiveRange(1, 5));
        expect(find.text('${l.value} su 5'), findsWidgets);
        // Cinque icone per scheda, sempre, qualunque sia il livello.
        final icone = find.descendant(
          of: find.byWidget(l),
          matching: find.byType(CustomPaint),
        );
        expect(tester.widgetList(icone).length,
            greaterThanOrEqualTo(Horoscope.indicatorMax));
      }
    });

    testWidgets('L\'infografica sta sotto titolo e categoria', (tester) async {
      await pumpScreen(tester);
      for (final domain in HoroscopeDomain.values) {
        final card = find.byKey(Key('oroscopo_card_${domain.name}'));
        final categoria = tester.getTopLeft(find.descendant(
            of: card, matching: find.text(domain.label.toUpperCase())));
        final livello = tester.getTopLeft(
            find.descendant(of: card, matching: find.byType(DomainLevel)));
        expect(livello.dy, greaterThan(categoria.dy),
            reason:
                'l\'infografica di ${domain.label} non sta sotto la categoria');
      }
    });

    test('Le due voci mostrate sono Breve e Profonda, con Media latente', () {
      expect(AnswerDepth.shown.map((d) => d.label).toList(),
          ['Breve', 'Profonda']);
      expect(AnswerDepth.free, AnswerDepth.breve);
      expect(AnswerDepth.breve.premium, isFalse);
      expect(AnswerDepth.profonda.premium, isTrue);
      // La Media resta nel codice ma spenta, fuori dalla vista.
      expect(AnswerDepth.media.premium, isTrue);
      expect(AnswerDepth.media.visible, isFalse);
      expect(AnswerDepth.breve.visible, isTrue);
      expect(AnswerDepth.profonda.visible, isTrue);
    });

    testWidgets('Ogni bolla ha il selettore, chiuso su Breve e bloccato',
        (tester) async {
      await pumpScreen(tester);
      for (final domain in HoroscopeDomain.values) {
        final card = find.byKey(Key('oroscopo_card_${domain.name}'));
        final selector = find.byKey(Key('oroscopo_depth_${domain.name}'));
        expect(selector, findsOneWidget);
        // Il selettore mostra il titolo e la voce corrente, che nel gratuito
        // e' Breve, non Media.
        expect(find.descendant(of: selector, matching: find.text('PROFONDITÀ')),
            findsOneWidget);
        expect(find.descendant(of: selector, matching: find.text('Breve')),
            findsOneWidget);
        expect(find.descendant(of: selector, matching: find.text('Media')),
            findsNothing);
        // Sul chip NON c'e' il lucchetto: la voce mostrata e' Breve, che e'
        // gratuita. Il lucchetto sta sulle due voci Premium dentro la tendina,
        // come si verifica nel test che la apre.
        expect(
            find.descendant(
                of: selector, matching: find.byIcon(Icons.lock_rounded)),
            findsNothing);
        // Sta in alto a destra della bolla.
        final cardRect = tester.getRect(card);
        final selRect = tester.getRect(selector);
        expect(selRect.center.dx, greaterThan(cardRect.center.dx));
        expect(selRect.top - cardRect.top, lessThan(cardRect.height / 2));
      }
    });

    testWidgets('La tendina si apre con la sola Profonda bloccata, senza Media',
        (tester) async {
      await pumpScreen(tester);
      await tester.tap(find.byKey(const Key('oroscopo_depth_generale')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Le due voci mostrate sono nell'elenco aperto.
      for (final depth in AnswerDepth.shown) {
        expect(find.text(depth.label), findsWidgets,
            reason: '${depth.label} manca nella tendina');
      }
      // La Media latente non compare nella tendina.
      expect(find.text('Media'), findsNothing);
      // Un solo lucchetto nell'elenco, per la Profonda.
      final lucchettiNellaTendina = find.descendant(
        of: find.byType(PopupMenuItem<AnswerDepth>),
        matching: find.byIcon(Icons.lock_rounded),
      );
      expect(tester.widgetList(lucchettiNellaTendina).length, 1);
    });

    testWidgets('Nella Demo il controllo non cambia la profondita\'',
        (tester) async {
      await pumpScreen(tester);
      await tester.tap(find.byKey(const Key('oroscopo_depth_generale')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      // Si tocca Profonda, che e' bloccata.
      await tester.tap(find.descendant(
          of: find.byType(PopupMenuItem<AnswerDepth>),
          matching: find.text('Profonda')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // La profondita' resta Breve e arriva l'invito ad abbonarsi.
      // DALL'ORDINE L l'invito e' la bolla del Maestro, showUpgradeInvite,
      // non piu' una SnackBar di sistema col fondo bianco.
      expect(
          find.descendant(
              of: find.byKey(const Key('oroscopo_depth_generale')),
              matching: find.text('Breve')),
          findsOneWidget);
      expect(find.byKey(const Key('upgrade_invite')), findsOneWidget);
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('Le bolle sono nel blu di Medora, non nel viola neutro',
        (tester) async {
      await pumpScreen(tester);
      final medora = MaestroPalette.forKey(const ThemeKey.of(Maestro.medora));
      const neutro = MaestroPalette.neutral;
      final container = tester
          .widget<Container>(find.byKey(const Key('oroscopo_card_generale')));
      final deco = container.decoration! as BoxDecoration;
      final tinta = (deco.gradient! as LinearGradient).colors.first;
      expect(tinta.toARGB32(),
          medora.surfaceElevated.withValues(alpha: 0.95).toARGB32());
      expect(tinta.toARGB32(),
          isNot(neutro.surfaceElevated.withValues(alpha: 0.95).toARGB32()));
    });

    testWidgets('L\'emblema e\' grande e il blocco parte in alto',
        (tester) async {
      await pumpScreen(tester);
      final emblema = tester.getRect(find.byKey(const Key('oroscopo_emblem')));
      expect(emblema.width, greaterThanOrEqualTo(240),
          reason: 'emblema troppo piccolo');
      // **NESSUN VUOTO SOPRA, e adesso sopra c'e' il nome del segno.**
      // Ordine 2171 voce 5: il nome e' salito sopra l'emblema, perche' e' la
      // prima cosa che la persona cerca e stava sotto la figura. Quello che
      // non deve esserci resta il VUOTO: si misura quindi da dove comincia il
      // nome, e che l'emblema gli stia subito sotto.
      final lista = tester.getRect(find.byKey(const Key('oroscopo_list')));
      final nome = tester.getRect(find.byKey(const Key('oroscopo_sign_name')));
      expect(nome.top - lista.top, lessThan(40),
          reason: 'sopra il nome del segno si e\' aperto un vuoto');
      expect(emblema.top - nome.bottom, lessThan(24),
          reason: 'fra il nome e l\'emblema si e\' aperto un vuoto');
      expect(emblema.top - lista.top, lessThan(90),
          reason: 'troppo vuoto sopra l\'emblema');
    });
  });

  group('Card di condivisione', () {
    testWidgets('Si costruisce senza overflow per tutti i dodici segni',
        (tester) async {
      await loadFonts();
      for (final sign in Zodiac.values) {
        final cards = Horoscope.forSign(sign: sign, dayOfYear: 200, year: 2026);
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

    testWidgets('La riga del cielo entra nella card, e solo se il cielo c\'e\'',
        (tester) async {
      // **ORDINE P VOCE 25, la composizione scelta da Mauro il 12 agosto 2026.**
      // La card mostrava la sola frase del segno: il transito, nel solo posto in
      // cui l'Oroscopo diventa un'immagine che si manda agli altri, non
      // compariva. Due proposte sono state montate e guardate, e ha vinto la
      // riga in oro sotto la sintesi.
      //
      // Due prove in una, e la seconda vale quanto la prima: la riga c'e' quando
      // il cielo e' stato letto davvero, e NON c'e' quando la corrente viene
      // dalla hash. Una card che scrivesse comunque una riga del cielo direbbe
      // il falso nel posto piu' pubblico che l'app abbia.
      await loadFonts();
      final carta = NatalChart(
        sunSign: Zodiac.aries,
        planets: const [
          PlanetPosition(
              id: 'sun',
              name: 'Sole',
              glyph: '\u2609',
              longitude: 18.4,
              sign: Zodiac.aries),
          PlanetPosition(
              id: 'venus',
              name: 'Venere',
              glyph: '\u2640',
              longitude: 40.2,
              sign: Zodiac.taurus),
          PlanetPosition(
              id: 'saturn',
              name: 'Saturno',
              glyph: '\u2644',
              longitude: 300.5,
              sign: Zodiac.aquarius),
        ],
        ascendantLongitude: 205.0,
        midheavenLongitude: 115.0,
        houses: [
          for (var n = 1; n <= 12; n++)
            HouseCusp(number: n, longitude: (205.0 + (n - 1) * 30.0) % 360.0),
        ],
        hasTime: true,
      );
      final cielo = CieloDiOggi.perIlGiorno(
          adesso: DateTime.utc(2026, 7, 9, 12), carta: carta);
      expect(cielo.ceCieloVero, isTrue,
          reason: 'il cielo del giorno scelto non porta fatti: la prova non '
              'starebbe misurando quello che crede');

      Future<void> monta(List<HoroscopeCard> schede) async {
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Center(
                child: OroscopoShareCard(
                  sign: Zodiac.aries,
                  cards: schede,
                  palette:
                      MaestroPalette.forKey(const ThemeKey.of(Maestro.medora)),
                ),
              ),
            ),
          ),
        ));
        await tester.pumpAndSettle();
      }

      // COL CIELO VERO la riga c'e', e porta il testo della scheda Generale.
      final conCielo = Horoscope.forSign(
          sign: Zodiac.aries, dayOfYear: 190, year: 2026, cielo: cielo);
      await monta(conCielo);
      expect(find.byKey(const Key('share_transito_riga')), findsOneWidget,
          reason: 'la card non porta la riga del cielo: chi condivide manda '
              'agli altri la sola parte generica');
      final attesa = conCielo
          .firstWhere((c) => c.domain == HoroscopeDomain.generale)
          .rigaDelCielo!;
      expect(find.text(attesa), findsOneWidget,
          reason: 'la riga a schermo non e\' quella della scheda: la card ha '
              'ricomposto il testo per conto suo');
      // E la sintesi resta la frase che si legge: la gerarchia non e' cambiata.
      final sintesi = conCielo
          .firstWhere((c) => c.domain == HoroscopeDomain.generale)
          .synthesis;
      expect(tester.getCenter(find.text(sintesi)).dy,
          lessThan(tester.getCenter(find.text(attesa)).dy),
          reason: 'la riga del cielo e\' finita sopra la sintesi: e\' la '
              'proposta che Mauro NON ha scelto');

      // SENZA CIELO la riga non c'e', e non si inventa niente.
      await monta(
          Horoscope.forSign(sign: Zodiac.aries, dayOfYear: 190, year: 2026));
      expect(find.byKey(const Key('share_transito_riga')), findsNothing,
          reason: 'la card scrive una riga del cielo anche quando il cielo non '
              'e\' stato letto: e\' una promessa che il dato non mantiene');
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
      final numero = tester.getSize(find
          .ancestor(of: find.text('NUMERO'), matching: find.byType(Container))
          .first);
      final colore = tester.getSize(find
          .ancestor(of: find.text('COLORE'), matching: find.byType(Container))
          .first);
      expect((numero.width - colore.width).abs(), lessThan(1.0),
          reason: 'le bolle Numero e Colore hanno larghezza diversa');
      expect((numero.height - colore.height).abs(), lessThan(1.0),
          reason: 'le bolle Numero e Colore hanno altezza diversa');
    });

    testWidgets('Il titolo della Carriera non e\' troncato', (tester) async {
      await loadFonts();
      for (final sign in Zodiac.values) {
        final cards = Horoscope.forSign(sign: sign, dayOfYear: 190, year: 2026);
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
