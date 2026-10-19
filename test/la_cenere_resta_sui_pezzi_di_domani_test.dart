import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/rituals/animal_catalog.dart';
import 'package:esoteric_circle/core/viaggio/la_carta_in_quattro_pezzi.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/features/maestri/caligo/viaggio/il_velo_che_si_scosta.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **LA CENERE RESTA SUI PEZZI DI DOMANI.** Ordine FZ, trovato dalla
/// simulazione da persona del 20 ottobre 2026 sul Realme 767f596c.
///
/// **Il fatto**: alla prima discesa, passando il dito su tutta la carta come
/// fa una persona curiosa, la cenere veniva via quasi tutta e la Lince si
/// vedeva intera, volto compreso
/// (`docs/collaudo/FZ/simulazioni/catture/v2_d1_09.png`). L'ordine FZ.04 dice
/// *"Ogni volta che la persona segue l'ombra di quell'animale, gratta con il
/// dito un pezzo della sua carta. Il volto dell'animale sta nel quarto pezzo e
/// si scopre per ultimo"*.
///
/// **La causa**: la contabilita' contava solo le celle della fascia attiva, ma
/// il solco del dito registrava ogni punto toccato e il pittore scavava la
/// cenere lungo tutto il solco. La guardia di prima
/// (`il_gesto_che_scosta_test.dart`) misurava le celle contate, non i pixel.
/// Padre: ordine FZ voce FZ.04 (commit `4acde9c2`), che ha tolto la nube
/// sopra la testa della vecchia sagoma senza mettere niente al suo posto.
///
/// **Cosa misura**: il solco conservato non contiene punti sopra la fascia
/// che oggi si puo' grattare, e il disegno lascia piena la cenere sopra quella
/// fascia anche quando il pennello morbido lavora sul suo bordo.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  const scena = Size(390, 844);
  const misura = Size(1080, 1920);
  final illustrazione = IlVeloCheSiScosta.doveStaLIllustrazione(scena, misura);

  /// La frazione dall'alto sopra la quale, al pezzo [quale], non si gratta.
  double cima(int quale) =>
      (LaCartaInQuattroPezzi.pezzi - 1 - quale) / LaCartaInQuattroPezzi.pezzi;

  testWidgets(
      'IL SOLCO CONSERVATO NON SALE SOPRA IL PEZZO DI OGGI: un dito che passa '
      'ovunque, ai pezzi 0, 1 e 2, lascia nel Diario solo punti dal pezzo di '
      'oggi in giu', (tester) async {
    await tester.binding.setSurfaceSize(scena);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final animale = AnimalCatalog.animals.first;
    var guardati = 0;
    for (final quale in [0, 1, 2]) {
      List<List<Offset>> conservati = const [];
      await tester.pumpWidget(MaterialApp(
        home: SizedBox(
          width: scena.width,
          height: scena.height,
          child: IlVeloCheSiScosta(
            key: ValueKey('cima$quale'),
            nome: animale.name,
            immagine: animale.fullPath,
            quale: quale,
            giaScoperte: const {},
            quandoCambia: (_) {},
            quandoSolca: (s) => conservati = s,
            palette: MaestroPalette.caligo,
          ),
        ),
      ));
      await tester.pump(const Duration(milliseconds: 50));
      // **IL DITO DELLA PERSONA CURIOSA**: dall'alto in basso, a zig zag su
      // tutta la carta, come sul telefono.
      final g = await tester
          .startGesture(Offset(illustrazione.left + 4, illustrazione.top + 4));
      for (var riga = 0; riga <= 32; riga++) {
        final y = illustrazione.top + illustrazione.height * riga / 32;
        final xs = riga.isEven
            ? [illustrazione.left + 4, illustrazione.right - 4]
            : [illustrazione.right - 4, illustrazione.left + 4];
        for (final x in xs) {
          await g.moveTo(Offset(
              x, y.clamp(illustrazione.top + 1, illustrazione.bottom - 1)));
        }
      }
      await g.up();
      await tester.pump(const Duration(milliseconds: 50));
      final punti = [for (final s in conservati) ...s];
      guardati += punti.length;
      final sopra = punti.where((p) => p.dy < cima(quale) - 1e-9).toList();
      expect(sopra, isEmpty,
          reason: 'al pezzo $quale il solco conservato ha ${sopra.length} '
              'punti sopra la fascia di oggi (cima ${cima(quale)}): sono '
              'cenere scavata su pezzi che si grattano nei giorni dopo, e il '
              'volto si vedrebbe prima della quarta volta');
    }
    // **IL CARDINALE**: se il dito non lasciasse nessun punto la prova
    // sarebbe verde senza aver guardato niente.
    expect(guardati, greaterThan(30),
        reason: 'i solchi conservati sono solo $guardati punti: il gesto non '
            'e\' arrivato al velo');
  });

  testWidgets(
      'IL PENNELLO NON SBAVA SUL PEZZO DI DOMANI: un tratto lecito sul bordo '
      'del pezzo di oggi lascia piena la cenere subito sopra, ai pezzi 0, 1 e '
      '2', (tester) async {
    final size = illustrazione.size;
    final w = size.width.ceil();
    final h = size.height.ceil();
    var righeGuardate = 0;
    for (final quale in [0, 1, 2]) {
      final velo = LaCartaInQuattroPezzi('Lupo', quale);
      // Un tratto orizzontale quattro punti sotto il bordo del pezzo di oggi:
      // dentro la fascia lecita, ma col pennello che arriva oltre il bordo.
      final y = cima(quale) + 4 / size.height;
      late Uint8List px;
      await tester.runAsync(() async {
        final p = PittoreDellaCenere(
          velo: velo,
          coperte: velo.velato,
          quanta: 1,
          solchi: [
            [Offset(0.2, y), Offset(0.8, y)],
          ],
          scoperte: const {},
        );
        final registro = ui.PictureRecorder();
        p.paint(Canvas(registro), size);
        final img = await registro.endRecording().toImage(w, h);
        px = (await img.toByteData(format: ui.ImageByteFormat.rawStraightRgba))!
            .buffer
            .asUint8List();
      });
      // **SOPRA IL BORDO**: tutte le righe del pezzo di domani fino a un punto
      // sopra il bordo. La cenere piena ha l'alfa alta: un pixel sotto 128 e'
      // un buco.
      final bordo = (cima(quale) * size.height).floor();
      final aperti = <String>[];
      for (var yy = 0; yy < bordo - 1; yy++) {
        righeGuardate++;
        for (var x = (0.2 * w).round(); x < (0.8 * w).round(); x++) {
          if (px[(yy * w + x) * 4 + 3] < 128) aperti.add('($x,$yy)');
        }
      }
      expect(aperti, isEmpty,
          reason: 'al pezzo $quale il pennello ha aperto ${aperti.length} '
              'pixel sopra il bordo del pezzo di oggi (riga $bordo), per '
              'esempio ${aperti.take(3).join(' ')}: la cenere di domani va '
              'tenuta piena');
      // **E IL TRATTO SCAVA DAVVERO SOTTO**: altrimenti la prova sarebbe verde
      // perche' il pittore non disegna niente.
      final sotto = (y * size.height).round();
      var apertiSotto = 0;
      for (var x = (0.3 * w).round(); x < (0.7 * w).round(); x++) {
        if (px[(sotto * w + x) * 4 + 3] < 128) apertiSotto++;
      }
      expect(apertiSotto, greaterThan(0),
          reason: 'al pezzo $quale il tratto non ha scavato nemmeno sulla sua '
              'riga: la prova non sta guardando il pennello');
    }
    expect(righeGuardate, greaterThan(100));
  });
}
