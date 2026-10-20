import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/rituals/animal_catalog.dart';
import 'package:esoteric_circle/core/viaggio/la_carta_in_quattro_pezzi.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/caligo/viaggio/il_segno_che_risponde.dart';
import 'package:esoteric_circle/features/maestri/caligo/viaggio/il_velo_che_si_scosta.dart';
import 'package:esoteric_circle/features/maestri/caligo/viaggio/viaggio_dello_sciamano_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cardinale_minimo.dart';
import 'la_soglia_si_guarda_prima_di_leggerla_test.dart'
    show DiarioDelloSciamanoDiProva;

/// **IL VOLTO SI SCOPRE PER ULTIMO, SULLA CARTA VERA.** Ordine FZ voce FZ.04:
/// *"Ogni animale ha la sua carta: il file *_carta_da_grattare_v1.jpg ... a
/// quasi tutto schermo"*, *"Il volto dell'animale sta nel quarto pezzo e si
/// scopre per ultimo"*; il fondatore: *"non l'animale da scoprire, ma una
/// card intera"*.
///
/// **I fatti, dalla simulazione da persona del 20 ottobre 2026 sul Realme
/// 767f596c**: al terzo pezzo la testa del Cavallo si vedeva gia'
/// (`docs/collaudo/FZ/simulazioni/catture/v2_d7_carta.png`); la lente
/// grattava l'illustrazione dell'animale su fondo blu, non la carta; il pezzo
/// in cima stava dietro le barre. Misurate le dodici carte, in nessuna il
/// volto sta nella fascia piu' alta. Padre: ordine FZ voce FZ.04.
///
/// **Cosa misura**: per tutti e dodici gli animali ogni punto del volto
/// appartiene al quarto pezzo e a nessun altro, e nessun pezzo prima del
/// quarto lo rende grattabile; la lente mostra la carta vera; la carta parte
/// sotto lo spazio delle barre in cima.
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
            immagine: IlSegnoCheRisponde.posaDi(cavallo),
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
    expect(carta.height, greaterThan(scena.height / 2),
        reason: 'la carta e\' alta solo ${carta.height.toStringAsFixed(0)} '
            'punti: non e\' piu\' a quasi tutto schermo');
  });

  testWidgets(
      'LA LENTE GRATTA LA CARTA VERA, non l\'illustrazione dell\'animale',
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
    expect(nome, contains('_carta_da_grattare_v1'),
        reason: 'la lente gratta $nome: e\' l\'animale da scoprire, non la '
            'carta intera che chiede l\'ordine');
  });
}
