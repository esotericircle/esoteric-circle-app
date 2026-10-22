// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/tarot/tarot_card.dart';
import 'package:esoteric_circle/core/tarot/tarot_reading.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread_type.dart';
import 'package:esoteric_circle/core/tarot/tarot_topic.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/tarot/le_barre_dei_semi.dart';
import 'package:esoteric_circle/features/tarot/stesa_tre_carte_screen.dart';
import 'package:esoteric_circle/features/tarot/tarot_card_art.dart';
import 'package:esoteric_circle/features/tarot/tarot_selectors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'cardinale_minimo.dart';

/// **ORDINE GC, PARTE A: LA STESA DI TAROCCHI.** 22 ottobre 2026.
///
/// Le prove delle voci GC.01, GC.04, GC.05 e GC.06 (GC.02 sta in
/// `nessuna_fascia_sotto_la_barra_della_stesa_test.dart`, GC.03 in
/// `la_scena_della_stesa_e_un_filmato_test.dart`). Nessuna chiamata al
/// modello (R2): la lettura e' quella di casa.

/// Quanti byte occupa in memoria un'arte decodificata, dal nome del file e
/// dalla misura chiesta: la miniatura e' 333 per 500, la piena 853 per 1280,
/// una decodifica a larghezza `w` tiene la proporzione della piena.
int _byteDi(ImageProvider immagine) {
  int? larga;
  var chiave = immagine;
  if (immagine is ResizeImage) {
    larga = immagine.width;
    chiave = immagine.imageProvider;
  }
  final nome = (chiave as AssetImage).assetName;
  final miniatura = nome.contains('img_thumb');
  final w = larga ?? (miniatura ? 333 : 853);
  final h = (w * 1.5).round();
  return w * h * 4;
}

Future<void> _carattere() async {
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

Widget _ospite(Widget figlio) => MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: MaestroScope(child: figlio),
      ),
    );

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
        (call) async => null);
  });

  group('GC.01 la stesa a dieci carte non rallenta e non chiude l\'app', () {
    test('la carta si decodifica alla misura in cui si vede', () {
      // Una carta piccola (la bolla, 54 punti a densita' 3) dalla miniatura,
      // una media (in piedi sul tavolo) alla misura media, l'ingrandita
      // piena.
      expect(TarotCardArt.gradinoPer(54 * 3).miniatura, isTrue);
      expect(TarotCardArt.gradinoPer(333).miniatura, isTrue);
      expect(TarotCardArt.gradinoPer(334),
          (miniatura: false, decodifica: TarotCardArt.latoMedio));
      expect(TarotCardArt.gradinoPer(900),
          (miniatura: false, decodifica: null));
    });

    // **LA SOGLIA, RICAVATA DALLA MISURA SUL REALME**
    // (`docs/collaudo/GC/gc01_la_croce_celtica.md`): prima della cura la
    // Croce Celtica rivelata decodificava dieci arti piene, 43,7 MB di
    // pixel, e sul telefono la memoria grafica saliva di 54 MB con tredici
    // fotogrammi oltre i 130 millisecondi. La cura le porta alla miniatura:
    // dieci per 0,67 MB. La soglia sta a 16 MB, sotto la meta' di prima e con
    // margine per due carte decodificate alla misura media.
    const sogliaInMegabyte = 16;

    for (final schermo in const [Size(360, 800), Size(390, 844)]) {
      testWidgets(
          'a ${schermo.width.toInt()} punti, densita\' 3, la Croce Celtica '
          'rivelata decodifica meno di $sogliaInMegabyte MB di arte',
          (tester) async {
        await _carattere();
        tester.view.physicalSize = schermo * 3;
        tester.view.devicePixelRatio = 3;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(_ospite(const StesaTreCarteScreen(
          seed: 2,
          revealAll: true,
          skipIntro: true,
          topic: TarotTopic.momentoCheVivo,
          tipo: TarotSpreadType.dieciCarte,
        )));
        for (var i = 0; i < 8; i++) {
          await tester.pump(const Duration(milliseconds: 300));
        }
        final arti = <Object, int>{};
        for (final img in tester.widgetList<Image>(find.descendant(
            of: find.byType(TarotCardArt), matching: find.byType(Image)))) {
          final chiave = img.image is ResizeImage
              ? (img.image as ResizeImage).imageProvider
              : img.image;
          if (chiave is! AssetImage) continue;
          arti['${chiave.assetName}@${img.image is ResizeImage ? (img.image as ResizeImage).width : 0}'] =
              _byteDi(img.image);
        }
        cardinaleMinimo(arti.length, 10,
            cosa: 'arti di carta decodificate',
            perche: 'la Croce Celtica ha dieci carte');
        final mega = arti.values.fold<int>(0, (a, b) => a + b) / 1e6;
        print('GC.01: Croce Celtica rivelata a ${schermo.width.toInt()} '
            'punti, ${arti.length} arti, ${mega.toStringAsFixed(1)} MB');
        expect(mega, lessThan(sogliaInMegabyte),
            reason: 'le carte della Croce Celtica tornano a decodificarsi '
                'grandi: ${mega.toStringAsFixed(1)} MB');
      });
    }
  });

  group('GC.04 la domanda scelta e la domanda scritta non si confondono', () {
    const scelta = TarotTopic.bivio;
    test('scelgo poi scrivo: la scelta si annulla e la tendina torna vuota',
        () {
      final s = const TarotSetup()
          .conLaDomandaScelta(scelta)
          .conLaDomandaScritta('Devo cambiare casa?');
      expect(s.argomentoScelto, isFalse);
      expect(s.domandaScritta, 'Devo cambiare casa?');
      expect(s.argomento, TarotTopic.predefinito,
          reason: 'la scelta annullata entra ancora nella lettura');
      expect(s.riepilogo.contains(scelta.label.split(',').first), isFalse);
    });
    test('scrivo poi scelgo: il testo scritto si cancella', () {
      final s = const TarotSetup()
          .conLaDomandaScritta('Devo cambiare casa?')
          .conLaDomandaScelta(scelta);
      expect(s.argomentoScelto, isTrue);
      expect(s.domandaScritta, isNull);
      expect(s.argomento, scelta);
    });
    test('scelgo due volte: vale la seconda, nessun testo', () {
      final s = const TarotSetup()
          .conLaDomandaScelta(TarotTopic.momentoCheVivo)
          .conLaDomandaScelta(scelta);
      expect(s.topic, scelta);
      expect(s.domandaScritta, isNull);
    });
    test('scrivo e cancello: torna la scelta di prima, una domanda sola', () {
      final s = const TarotSetup()
          .conLaDomandaScelta(scelta)
          .conLaDomandaScritta('Devo')
          .conLaDomandaScritta('');
      expect(s.argomentoScelto, isTrue);
      expect(s.domandaScritta, isNull);
      expect(s.argomento, scelta);
    });

    testWidgets('a video: scritta la domanda, la tendina mostra il vuoto',
        (tester) async {
      await _carattere();
      tester.view.physicalSize = const Size(390, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      var setup = const TarotSetup().conLaDomandaScelta(scelta);
      await tester.pumpWidget(_ospite(StatefulBuilder(
        builder: (context, aggiorna) => Scaffold(
          body: SingleChildScrollView(
            child: TarotSetupPanel(
              setup: setup,
              palette: MaestroScope.of(context),
              aperto: true,
              onToggle: () {},
              onChanged: (s) => aggiorna(() => setup = s),
              onLocked: (_) {},
            ),
          ),
        ),
      )));
      await tester.pump();
      expect(find.byKey(const Key('tendina_vuota')), findsNothing);
      await tester.enterText(
          find.byKey(const Key('stesa_domanda_scritta')), 'Devo partire?');
      await tester.pump();
      expect(find.byKey(const Key('tendina_vuota')), findsOneWidget,
          reason: 'scritta la domanda, la scelta non si e\' annullata');
      expect(find.text(TendinaSelettore.testoDelVuoto), findsOneWidget);
    });
  });

  group('GC.05 la singola carta ha il titolo e un solo paragrafo', () {
    test('in ogni stesa ogni carta e\' titolo e un paragrafo, il principale '
        'ha il riquadro', () {
      final guasti = <String>[];
      var carte = 0;
      for (final tipo in TarotSpreadType.values) {
        for (var seme = 0; seme < 4; seme++) {
          final s = TarotSpread.draw(seed: seme * 7 + 1, posizioni: tipo.posizioni);
          final r = TarotReading.of(s, TarotTopic.momentoCheVivo,
              nomeDellaStesa: tipo.nome);
          if (r.principale.singola || r.principale.cosaFare.trim().isEmpty) {
            guasti.add('${tipo.name} $seme: il principale ha perso il '
                'riquadro');
          }
          for (final p in r.posizioni) {
            carte++;
            final c = p.responso!;
            if (!c.singola ||
                c.cosaFare.isNotEmpty ||
                c.paragrafi.length != 1 ||
                c.titolo.trim().isEmpty) {
              guasti.add('Tarocchi, ${tipo.name} $seme, '
                  '${p.drawn.displayName}: ${c.paragrafi.length} paragrafi, '
                  'riquadro "${c.cosaFare}"');
            }
            guasti.addAll(c.difetti(conLaFonte: false));
          }
        }
      }
      cardinaleMinimo(carte, 4 * (1 + 3 + 4 + 10),
          cosa: 'carte singole', perche: 'quattro stese per quattro semi');
      print('GC.05: carte singole $carte, difetti ${guasti.length}');
      expect(guasti, isEmpty, reason: guasti.take(6).join('\n'));
    });
  });

  group('GC.06 il livello visivo del responso della Stesa', () {
    test('le barre seguono le carte uscite', () {
      DrawnCard d(String nome) => DrawnCard(
          card: TarotDeck.cards.firstWhere((c) => c.name == nome),
          position: SpreadPosition.presente,
          reversed: false);
      final carte = [d('Asso di Coppe'), d('Due di Coppe'), d('Il Matto')];
      final conti = LeBarreDeiSemi.contaISemi(carte);
      expect(conti[TarotSeme.coppe], 2);
      expect(conti[TarotSeme.bastoni], 0);
      expect(LeBarreDeiSemi.contaIMaggiori(carte), 1);
      expect(LeBarreDeiSemi.pienezza(carte, TarotSeme.coppe), closeTo(2 / 3, 1e-9));
      // La stesa a una carta: il suo elemento acceso, gli altri spenti.
      final sola = [d('Re di Spade')];
      expect(LeBarreDeiSemi.pienezza(sola, TarotSeme.spade), 1);
      for (final s in [TarotSeme.bastoni, TarotSeme.coppe, TarotSeme.denari]) {
        expect(LeBarreDeiSemi.pienezza(sola, s), 0);
      }
    });
  });
}
