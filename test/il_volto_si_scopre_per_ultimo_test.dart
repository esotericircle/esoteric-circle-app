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

  testWidgets(
      'LA LENTE GRATTA L\'ANIMALE DI LATO, con la sua proporzione vera',
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
      final vera = Size(
          frame.image.width.toDouble(), frame.image.height.toDouble());
      expect(LaCartaInQuattroPezzi.misure[animale.name], vera,
          reason: '${animale.name}: misura dichiarata '
              '${LaCartaInQuattroPezzi.misure[animale.name]}, il file e\' '
              '$vera');
      guardati++;
    }
    expect(guardati, 12);
  });
}
