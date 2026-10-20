import 'dart:io';
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/rituals/animal_catalog.dart';
import 'package:esoteric_circle/core/viaggio/la_carta_in_quattro_pezzi.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/caligo/viaggio/il_velo_che_si_scosta.dart';
import 'package:esoteric_circle/features/maestri/caligo/viaggio/viaggio_dello_sciamano_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cardinale_minimo.dart';
import 'la_soglia_si_guarda_prima_di_leggerla_test.dart'
    show DiarioDelloSciamanoDiProva;

/// **IL VOLTO SI SCOPRE PER ULTIMO, SULL'ANIMALE DI LATO.** Ordine FZ voce
/// FZ.04: *"Il volto dell'animale sta nel quarto pezzo e si scopre per
/// ultimo"*; il fondatore, 20 ottobre 2026: *"Per la cenere da scostare, non
/// devi usare il video, ma l'immagine dell'animale di lato"*.
///
/// **I fatti, dalla simulazione da persona del 20 ottobre 2026 sul Realme
/// 767f596c**: al terzo pezzo la testa del Cavallo si vedeva gia'
/// (`docs/collaudo/FZ/simulazioni/catture/v2_d7_carta.png`), perche' i pezzi
/// erano quattro fasce uguali dal basso; l'immagine di lato era stirata in un
/// rettangolo 1080x1920; il pezzo in cima stava dietro le barre; e con le
/// celle di un Diario vecchio il volto si apriva da solo alla quarta.
/// Padre: ordine FZ voce FZ.04.
///
/// **Cosa misura**: per tutti e dodici gli animali ogni punto del volto
/// misurato appartiene al quarto pezzo, e prima della quarta non si gratta;
/// le misure dichiarate sono quelle vere dei file; con le celle vecchie il
/// volto resta coperto all'arrivo; la lente mostra l'animale di lato; la
/// carta parte sotto lo spazio delle barre in cima.
void main() {
  // **LA GRANA DELLA CENERE SI PREPARA PRIMA DI TUTTO, IN TEMPO VERO**: si
  // prepara una volta sola (`GranaDellaCenere.prepara`), e se la cominciasse
  // una prova di questo file nel suo tempo finto non finirebbe mai, e la
  // prova dei pixel qui sotto la aspetterebbe fino al limite dei dieci
  // minuti. E' successo alla sua prima stesura, il 20 ottobre 2026.
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(GranaDellaCenere.prepara);
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test(
      'PER TUTTI E DODICI IL VOLTO E\' IL QUARTO PEZZO: ogni punto del volto '
      'sta in una cella del quarto pezzo, e prima della quarta discesa non si '
      'gratta', () {
    cardinaleMinimo(AnimalCatalog.animals.length, 12,
        cosa: 'animali del catalogo',
        perche: 'un catalogo vuoto farebbe passare la prova senza guardare');
    var puntiGuardati = 0;
    for (final animale in AnimalCatalog.animals) {
      expect(LaCartaInQuattroPezzi.volti.containsKey(animale.name), isTrue,
          reason: '${animale.name} non ha il volto misurato: prenderebbe '
              'quello medio, che non e\' il suo');
      final volto = LaCartaInQuattroPezzi.volti[animale.name]!;
      expect(volto.left >= 0 && volto.top >= 0, isTrue);
      expect(volto.right <= 1 && volto.bottom <= 1, isTrue);
      for (var quale = 0; quale < LaCartaInQuattroPezzi.pezzi; quale++) {
        final velo = LaCartaInQuattroPezzi(animale.name, quale);
        // **OGNI PUNTO DEL VOLTO**, su una griglia di venti per venti.
        for (var ix = 0; ix <= 20; ix++) {
          for (var iy = 0; iy <= 20; iy++) {
            final p = Offset(volto.left + volto.width * ix / 20,
                volto.top + volto.height * iy / 20);
            puntiGuardati++;
            expect(velo.pezzoDi(velo.cellaSotto(p)),
                LaCartaInQuattroPezzi.pezzi - 1,
                reason: '${animale.name}: il punto $p del volto sta in un '
                    'pezzo che si gratta prima del quarto');
            if (quale < LaCartaInQuattroPezzi.pezzi - 1) {
              expect(velo.siGratta(p), isFalse,
                  reason: '${animale.name} al pezzo $quale: il volto si '
                      'gratta prima della quarta discesa');
            }
          }
        }
        expect(velo.scostabile, isNotEmpty,
            reason: '${animale.name} pezzo $quale senza celle');
      }
    }
    expect(puntiGuardati, 12 * 4 * 21 * 21);
  });

  testWidgets(
      'CON LE CELLE DI UN DIARIO VECCHIO, ALLA QUARTA IL VOLTO E\' ANCORA '
      'SOTTO LA CENERE ALL\'ARRIVO, per tutti e dodici', (tester) async {
    // **IL CASO VISTO SUL REALME**, 20 ottobre 2026 (27 sulla data spostata):
    // le celle salvate con le fasce uguali di prima coprivano anche il volto,
    // e alla quarta discesa del Cavallo il volto si apriva da solo, con
    // "Per oggi hai scostato abbastanza" prima di aver toccato niente.
    const scena = Size(390, 844);
    await tester.binding.setSurfaceSize(scena);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    for (final animale in AnimalCatalog.animals) {
      final tutte = LaCartaInQuattroPezzi(animale.name, 0).velato;
      await tester.pumpWidget(MaterialApp(
        home: SizedBox(
          width: scena.width,
          height: scena.height,
          child: IlVeloCheSiScosta(
            key: ValueKey(animale.name),
            nome: animale.name,
            immagine: animale.fullPath,
            quale: 3,
            giaScoperte: tutte,
            // **E I SOLCHI VECCHI SU TUTTA LA CARTA**, a zig zag: il dito dei
            // giorni scorsi passato anche dove oggi c'e' il volto. Visto sul
            // Realme: la testa del Cavallo aperta all'arrivo.
            giaSolchi: [
              [
                for (var riga = 0; riga <= 32; riga++)
                  for (final x in riga.isEven ? [0.01, 0.99] : [0.99, 0.01])
                    Offset(x, (riga / 32).clamp(0.002, 0.998)),
              ],
            ],
            quandoCambia: (_) {},
            palette: MaestroPalette.caligo,
          ),
        ),
      ));
      await tester.pump(const Duration(milliseconds: 50));
      final pittore = tester
          .widget<CustomPaint>(find.byKey(const Key('viaggio_cenere')))
          .painter! as PittoreDellaCenere;
      final volto = LaCartaInQuattroPezzi(animale.name, 3).scostabile;
      final aperte = volto.where(pittore.scoperte.contains).length;
      expect(aperte, 0,
          reason: '${animale.name}: alla quarta $aperte celle del volto sono '
              'gia\' aperte all\'arrivo, prima di grattare');
      expect(find.text('Scosta la cenere con il dito.'), findsOneWidget,
          reason: '${animale.name}: all\'arrivo la lente dice gia\' che per '
              'oggi basta');
      // **NESSUN TRATTO DEI SOLCHI VECCHI TOCCA IL VOLTO**: si campiona ogni
      // segmento passato al pittore, e un punto e' sul volto solo se nessuna
      // cella fuori dal volto lo tocca entro un milionesimo.
      final velo3 = LaCartaInQuattroPezzi(animale.name, 3);
      bool soloVolto(Offset p) {
        const e = 1e-6;
        for (final dx in [-e, 0.0, e]) {
          for (final dy in [-e, 0.0, e]) {
            if (velo3.pezzoDi(velo3.cellaSotto(p + Offset(dx, dy))) != 3) {
              return false;
            }
          }
        }
        return true;
      }

      var sulVolto = 0;
      var campioni = 0;
      for (final s in pittore.solchi) {
        for (var k = 1; k < s.length; k++) {
          for (var t = 0; t <= 100; t++) {
            campioni++;
            if (soloVolto(Offset.lerp(s[k - 1], s[k], t / 100)!)) sulVolto++;
          }
        }
      }
      expect(sulVolto, 0,
          reason: '${animale.name}: alla quarta $sulVolto punti dei solchi '
              'vecchi stanno sul volto, e lo aprono prima di grattare');
      expect(campioni, greaterThan(1000),
          reason: '${animale.name}: i solchi vecchi non sono arrivati al '
              'pittore, la prova non guarda niente');
    }
  });

  testWidgets(
      'LA CARTA PARTE SOTTO LE BARRE IN CIMA: con lo spazio della barra nel '
      'margine alto, la carta comincia sotto, intera', (tester) async {
    const scena = Size(360, 719);
    await tester.binding.setSurfaceSize(scena);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final cavallo =
        AnimalCatalog.animals.firstWhere((a) => a.name == 'Cavallo');
    const sopra = 142.0;
    await tester.pumpWidget(MaterialApp(
      home: MediaQuery(
        data: const MediaQueryData(
            size: scena, padding: EdgeInsets.only(top: sopra)),
        child: SizedBox(
          width: scena.width,
          height: scena.height,
          child: IlVeloCheSiScosta(
            nome: cavallo.name,
            immagine: cavallo.fullPath,
            quale: 0,
            giaScoperte: const {},
            quandoCambia: (_) {},
            palette: MaestroPalette.caligo,
          ),
        ),
      ),
    ));
    await tester.pump();
    final carta = tester.getRect(find.byKey(const Key('viaggio_animale_vero')));
    expect(carta.top, greaterThanOrEqualTo(sopra),
        reason: 'la carta comincia a ${carta.top.toStringAsFixed(0)} punti, '
            'dietro le barre che finiscono a $sopra: il pezzo in cima non si '
            'vede e il dito li\' tocca i pulsanti della barra');
    // **GRANDE QUANTO LO SPAZIO PERMETTE**: con la sua proporzione vera
    // un'immagine quasi quadrata riempie la larghezza, una alta riempie
    // l'altezza fra le barre e l'istruzione. Una delle due deve toccare.
    final altoUtile = scena.height * 0.78 - sopra;
    expect(
        carta.width >= scena.width - 1 || carta.height >= altoUtile - 1, isTrue,
        reason: 'la carta e\' ${carta.size}: non riempie ne\' la larghezza '
            '(${scena.width}) ne\' l\'altezza utile '
            '(${altoUtile.toStringAsFixed(0)})');
  });

  /// **LA CENERE NON SALE SULLE BARRE, NEMMENO COL SUO BORDO.** Il fatto,
  /// dalla seconda simulazione da persona (l) del 20 ottobre 2026 sul Realme
  /// 767f596c: al quinto giorno, sulla carta del Cervo, i morsi sfrangiati in
  /// cima alla cenere coprivano il fondo di *"Sciamano"*, la terza riga del
  /// titolo (`docs/collaudo/FZ/simulazioni/catture/l2_g5_carta.png`). La
  /// prova qui sopra era verde, perche' misura dove comincia l'immagine: il
  /// bordo della cenere esce dall'immagine di un raggio di pennello e un
  /// quarto. Padre: ordine FZ voce FZ.04, la cura del 20 ottobre che ha messo
  /// la carta sotto le barre contando l'immagine e non il suo bordo.
  ///
  /// **Si misurano i pixel dipinti** sopra lo spazio delle barre, a velo
  /// intero, per tutti e dodici: devono essere zero. Il cardinale: sotto le
  /// barre la cenere dipinge decine di migliaia di pixel, o la prova non
  /// guarda niente.
  testWidgets('LA CENERE NON SALE SULLE BARRE, NEMMENO COL SUO BORDO',
      (tester) async {
    const scena = Size(360, 719);
    const sopra = 142.0;
    await tester.binding.setSurfaceSize(scena);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    cardinaleMinimo(AnimalCatalog.animals.length, 12, cosa: 'animali');
    final sulleBarre = <String>[];
    await tester.runAsync(() async {
      await GranaDellaCenere.prepara();
      for (final animale in AnimalCatalog.animals) {
        await tester.pumpWidget(MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
                size: scena, padding: EdgeInsets.only(top: sopra)),
            child: RepaintBoundary(
              key: const Key('foglio'),
              child: SizedBox(
                width: scena.width,
                height: scena.height,
                child: IlVeloCheSiScosta(
                  key: ValueKey(animale.name),
                  nome: animale.name,
                  immagine: 'assets/img/animali/nessuno.webp',
                  quale: 0,
                  giaScoperte: const {},
                  quandoCambia: (_) {},
                  palette: MaestroPalette.caligo,
                ),
              ),
            ),
          ),
        ));
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pump(IlVeloCheSiScosta.vitaDellaParticella);
        final foglio = tester.renderObject<RenderRepaintBoundary>(
            find.byKey(const Key('foglio')));
        final quadro = await foglio.toImage();
        final dati =
            (await quadro.toByteData(format: ui.ImageByteFormat.rawRgba))!
                .buffer
                .asUint8List();
        var su = 0;
        var giu = 0;
        for (var y = 0; y < scena.height.toInt(); y++) {
          for (var x = 0; x < scena.width.toInt(); x++) {
            if (dati[(y * scena.width.toInt() + x) * 4 + 3] <= 25) continue;
            if (y < sopra) {
              su++;
            } else {
              giu++;
            }
          }
        }
        expect(giu, greaterThan(20000),
            reason: '${animale.name}: sotto le barre la cenere dipinge solo '
                '$giu pixel, e allora la prova non guarda la cenere');
        if (su > 0) sulleBarre.add('${animale.name} $su');
      }
    });
    expect(sulleBarre, isEmpty,
        reason: 'LA CENERE SALE SULLE BARRE, pixel dipinti sopra $sopra: '
            '${sulleBarre.join(', ')}. Il bordo sfrangiato copre il titolo.');
  });

  testWidgets('LA LENTE GRATTA L\'ANIMALE DI LATO, con la sua proporzione vera',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
      ],
      child: MaterialApp(
        home: MaestroScope(
          child: ViaggioDelloSciamanoScreen(
            userSign: Zodiac.sagittarius,
            now: DateTime(2026, 9, 12, 12),
            diario: DiarioDelloSciamanoDiProva(1, nome: 'Cavallo'),
          ),
        ),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.ensureVisible(find.text('Una scelta da fare'));
    await tester.tap(find.text('Una scelta da fare'));
    await tester.pump();
    await tester.ensureVisible(find.byKey(const Key('viaggio_scendi')));
    await tester.tap(find.byKey(const Key('viaggio_scendi')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.tap(find.byKey(const Key('viaggio_salta_la_discesa')));
    await tester.pump(const Duration(seconds: 1));
    final nebbia = find.byKey(const Key('viaggio_nebbia'));
    for (var i = 0; i < 80 && nebbia.evaluate().isNotEmpty; i++) {
      await tester.drag(nebbia, const Offset(120, 40));
      await tester.pump(const Duration(milliseconds: 60));
    }
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const Key('viaggio_ombra_Cavallo')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    final immagine =
        tester.widget<Image>(find.byKey(const Key('viaggio_animale_vero')));
    final nome = (immagine.image as AssetImage).assetName;
    expect(nome, contains('animali/ani_cavallo'),
        reason: 'la lente gratta $nome, e non l\'immagine del Cavallo di lato');
    // **SENZA STIRARLA**: il rettangolo ha la proporzione vera del file.
    final r = tester.getRect(find.byKey(const Key('viaggio_animale_vero')));
    const vera = 878 / 844;
    expect(r.width / r.height, closeTo(vera, 0.01),
        reason: 'il Cavallo di lato sta in un rettangolo di proporzione '
            '${(r.width / r.height).toStringAsFixed(3)} invece di '
            '${vera.toStringAsFixed(3)}: e\' stirato');
  });

  test('LE MISURE DICHIARATE SONO QUELLE VERE DEI DODICI FILE', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    var guardati = 0;
    for (final animale in AnimalCatalog.animals) {
      final dati = File(animale.fullPath).readAsBytesSync();
      final codec = await ui.instantiateImageCodec(dati);
      final frame = await codec.getNextFrame();
      final vera =
          Size(frame.image.width.toDouble(), frame.image.height.toDouble());
      expect(LaCartaInQuattroPezzi.misure[animale.name], vera,
          reason: '${animale.name}: misura dichiarata '
              '${LaCartaInQuattroPezzi.misure[animale.name]}, il file e\' '
              '$vera');
      guardati++;
    }
    expect(guardati, 12);
  });
}
