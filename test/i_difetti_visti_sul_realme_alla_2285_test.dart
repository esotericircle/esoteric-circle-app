// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/synastry/collezione_delle_coppie.dart';
import 'package:esoteric_circle/core/synastry/gemello_astrale.dart';
import 'package:esoteric_circle/core/synastry/vip_catalog.dart';
import 'package:esoteric_circle/design_system/components/cosmos_background.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/design_system/tokens/typography_tokens.dart';
import 'package:esoteric_circle/features/synastry/podio_del_gemello.dart';
import 'package:esoteric_circle/features/synastry/porta_della_sinastria.dart';
import 'package:esoteric_circle/features/synastry/schermata_del_gemello.dart';
import 'package:esoteric_circle/features/synastry/sinastria_gallery_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **I DIFETTI VISTI SUL REALME ALLA BUILD 2285.** Ordine ER, 27 settembre
/// 2026, sessione sul telefono di prova.
///
/// - Il fondatore: *"La schermata del nastro delle carte ha sfondo nero,
///   perche'? Dovrebbe essere cosmico"*. Padre: ordine CF voce 14, ereditato
///   dalla voce ER.06.
/// - Sul podio del Gemello "Damian / o David", "Priyank / a Chop", e la seconda
///   riga sotto il gradino. Padre: il podio del 31 agosto (commit d24b7308).
/// - La ricerca "beyonce" non trovava Beyoncé. Padre: la voce ER.19, che le ha
///   dato l'accento.
/// - Sotto la carta "Tu", "Aggiungi la tu...". Padre: la voce ER.04.
///
/// Nessuna delle guardie della zona li prendeva: viste verdi col difetto
/// innestato (`docs/collaudo/ER/realme_regola_b.txt`).
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  void silenzia() {
    SharedPreferences.setMockInitialValues(const {});
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

  // Il cielo del telefono di prova: Gemelli, 15 giugno 1990. Porta sul
  // podio Giorgio Armani, Damiano David e Priyanka Chopra, i nomi che sulla
  // 2285 si spezzavano.
  const segno = Zodiac.gemini;
  final nascita = DateTime(1990, 6, 15);

  Future<void> laPorta(WidgetTester tester,
      {double scala = 1.0, Size schermo = const Size(360, 800)}) async {
    silenzia();
    tester.view.physicalSize = schermo;
    tester.view.devicePixelRatio = 1.0;
    tester.platformDispatcher.textScaleFactorTestValue = scala;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider(create: (_) => CollezioneDelleCoppie()),
      ],
      child: MaterialApp(
        builder: (ctx, child) => MaestroScope(child: child!),
        home: PortaDellaSinastria(
          userSign: segno,
          userName: 'Collaudo',
          userBirth: nascita,
        ),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  Future<void> ilGemello(WidgetTester tester, {double scala = 1.0}) async {
    await laPorta(tester, scala: scala, schermo: const Size(360, 3200));
    final porta = find.byKey(Key(ModoDellaSinastria.gemelloAstrale.chiave));
    await tester.ensureVisible(porta);
    await tester.pump();
    await tester.tap(porta);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets('il Gemello sta sul cielo, non sul nero', (tester) async {
    await ilGemello(tester);
    final cielo = find.descendant(
        of: find.byType(SchermataDelGemello),
        matching: find.byType(CosmosBackground));
    print('ORDINE ER, 2285: cieli sotto il Gemello '
        '${cielo.evaluate().length}');
    expect(cielo, findsOneWidget, reason: 'il Gemello e\' sul fondo nero');
  });

  for (final scala in [1.0, 1.3]) {
    testWidgets(
        'i nomi sul podio sono interi, stanno nella loro casella e sopra il '
        'gradino, a scala $scala', (tester) async {
      await ilGemello(tester, scala: scala);
      final g = GemelloAstrale.per(
          SchermataDelGemello.cieloPer(segno: segno, nascita: nascita))!;
      await tester.tap(find.byKey(const Key('gemello_cerca')));
      await tester.pump();
      await tester.pump(SchermataDelGemello.corsaDelNastro);
      await tester.pump(SchermataDelGemello.ilResponso);
      await tester.pump(const Duration(milliseconds: 100));
      final colpe = <String>[];
      for (final v in g.podio) {
        final casella = find.byKey(Key('gemello_podio_nome_${v.posto}'));
        expect(casella, findsOneWidget);
        final righe = [
          for (final e in find
              .descendant(of: casella, matching: find.byType(Text))
              .evaluate())
            (e.widget as Text).data!,
        ];
        final parole = v.vip.name.split(' ');
        if (righe.join(' ') != v.vip.name ||
            righe.any((r) => r.split(' ').any((p) => !parole.contains(p)))) {
          colpe.add('${v.vip.name} scritto $righe');
        }
        // **OGNI A CAPO VERO**, riga per riga del paragrafo dipinto: un a
        // capo dentro una parola e' la colpa della 2285, e un testo che
        // chiede piu' altezza della sua casella esce sotto il gradino anche
        // se la casella no.
        for (final e in find
            .descendant(of: casella, matching: find.byType(Text))
            .evaluate()) {
          final t = e.widget as Text;
          final p = tester.renderObject<RenderParagraph>(find.descendant(
              of: find.byWidget(t), matching: find.byType(RichText)));
          final tp = TextPainter(
              text: TextSpan(text: t.data, style: t.style),
              textDirection: TextDirection.ltr,
              textScaler: p.textScaler,
              maxLines: t.maxLines)
            ..layout(maxWidth: p.constraints.maxWidth);
          for (final l in tp.computeLineMetrics().skip(1)) {
            final inizio = tp
                .getPositionForOffset(Offset(0, l.baseline - l.ascent + 1))
                .offset;
            if (inizio > 0 && t.data![inizio - 1] != ' ') {
              colpe.add('${v.vip.name} va a capo dentro una parola: '
                  '"${t.data!.substring(0, inizio)}|${t.data!.substring(inizio)}"');
            }
          }
          final chiesta = tp.height *
              (p.size.width < tp.width ? p.size.width / tp.width : 1.0);
          if (chiesta > tester.getRect(casella).height + 0.5) {
            colpe.add('${v.vip.name} chiede ${chiesta.toStringAsFixed(1)} '
                'punti in una casella di '
                '${tester.getRect(casella).height.toStringAsFixed(1)}');
          }
        }
        final nome = tester.getRect(casella);
        final gradino =
            tester.getRect(find.byKey(Key('gemello_podio_gradino_${v.posto}')));
        if (nome.bottom > gradino.top + 0.5) {
          colpe.add('${v.vip.name} finisce sotto il gradino di '
              '${(nome.bottom - gradino.top).toStringAsFixed(1)} punti');
        }
      }
      print('ORDINE ER, 2285: podio a scala $scala, nomi '
          '${g.podio.map((v) => v.vip.name).toList()}, colpe $colpe');
      expect(tester.takeException(), isNull);
      expect(colpe, isEmpty, reason: colpe.join('; '));
    });
  }

  test(
      'ogni nome del catalogo si scrive sul podio in righe di parole intere, '
      'e nessuna riga si stringe sotto il 70 per cento', () {
    final stile = TypographyTokens.etichetta();
    const larga = 78.0; // la carta piu' stretta del podio
    final colpe = <String>[];
    var minima = 1.0;
    for (final v in VipCatalog.vips) {
      final righe = NomeSulPodio.righe(v.name);
      if (righe.join(' ') != v.name || righe.length > 2) {
        colpe.add('${v.name}: $righe');
      }
      for (final r in righe) {
        final tp = TextPainter(
            text: TextSpan(text: r, style: stile),
            textDirection: TextDirection.ltr)
          ..layout();
        final s = tp.width <= larga ? 1.0 : larga / tp.width;
        if (s < minima) minima = s;
        if (s < 0.7) colpe.add('${v.name}: "$r" stretta a $s');
      }
    }
    print('ORDINE ER, 2285: VIP ${VipCatalog.vips.length}, stretta minima '
        '${minima.toStringAsFixed(2)}, colpe $colpe');
    expect(VipCatalog.vips.length, greaterThanOrEqualTo(50));
    expect(colpe, isEmpty, reason: colpe.join('; '));
  });

  test('la ricerca trova ogni VIP anche scritto senza segni', () {
    final colpe = <String>[];
    var coiSegni = 0;
    for (final v in VipCatalog.vips) {
      final senza = v.name
          .replaceAll(RegExp('[àáâäã]'), 'a')
          .replaceAll(RegExp('[èéêë]'), 'e')
          .replaceAll(RegExp('[ìíîï]'), 'i')
          .replaceAll(RegExp('[òóôöõ]'), 'o')
          .replaceAll(RegExp('[ùúûü]'), 'u')
          .toLowerCase();
      if (senza != v.name.toLowerCase()) coiSegni++;
      if (!perLaRicerca(v.name).contains(perLaRicerca(senza))) {
        colpe.add(v.name);
      }
    }
    print('ORDINE ER, 2285: VIP coi segni $coiSegni, non trovati senza '
        '${colpe.length} $colpe');
    expect(coiSegni, greaterThanOrEqualTo(2),
        reason: 'il catalogo non ha piu\' nomi coi segni: la prova non misura');
    expect(colpe, isEmpty);
    expect(perLaRicerca('Beyoncé').contains(perLaRicerca('beyonce')), isTrue);
  });

  testWidgets('nella galleria vera, "beyonce" trova Beyoncé', (tester) async {
    silenzia();
    tester.view.physicalSize = const Size(360, 1600);
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
        ChangeNotifierProvider(create: (_) => CollezioneDelleCoppie()),
      ],
      child: MaterialApp(
        builder: (ctx, child) => MaestroScope(child: child!),
        home: SinastriaGalleryScreen(
            userSign: segno, userName: 'Collaudo', userBirth: nascita),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.enterText(
        find.byKey(const Key('sinastria_search')), 'beyonce');
    await tester.pump(const Duration(milliseconds: 300));
    final trovate = find.byKey(const Key('vip_Beyoncé')).evaluate().length;
    print('ORDINE ER, 2285: nella galleria "beyonce" trova $trovate carte di '
        'Beyoncé');
    expect(trovate, 1, reason: 'chi scrive "beyonce" non trova Beyoncé');
  });

  testWidgets('la riga sotto la carta Tu si legge intera, senza puntini',
      (tester) async {
    await laPorta(tester);
    final riga = find.byKey(const Key('sinastria_suggerimento_tu'));
    expect(riga, findsOneWidget);
    final p = tester.renderObject<RenderParagraph>(
        find.descendant(of: riga, matching: find.byType(RichText)));
    final testo = (tester.widget<Text>(riga)).data!;
    print('ORDINE ER, 2285: riga sotto Tu "$testo", va oltre le righe '
        '${p.didExceedMaxLines}');
    expect(p.didExceedMaxLines, isFalse,
        reason: '"$testo" non ci sta: la persona legge i tre puntini');
  });
}
