import 'package:esoteric_circle/core/rituals/animal_catalog.dart';
import 'package:esoteric_circle/core/viaggio/diario_dei_viaggi.dart';
import 'package:esoteric_circle/core/viaggio/la_carta_in_quattro_pezzi.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/features/maestri/caligo/viaggio/il_velo_che_si_scosta.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **IL GESTO CHE SCOSTA, SULLA CARTA INTERA.** Ordine DI voce 10,
/// 13 settembre 2026, riscritto con l'ordine FZ voce FZ.04, 17 ottobre 2026.
///
/// **La misura dell'ordine DI, ancora vera nel disegno**: il bordo non e'
/// piu' geometrico, lo disegna la mano. **Cio' che l'ordine FZ.04 cambia**:
/// non piu' un quarto del corpo di una sagoma, con la testa mai prima della
/// quarta, ma un pezzo intero (una fascia) per discesa, su una carta
/// rettangolare intera, **nessun pezzo escluso**: anche il quarto, il volto,
/// si gratta col dito come gli altri.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  const scena = Size(390, 844);

  Future<void> monta(WidgetTester tester, GuideAnimal animale, int quale,
      Set<int> gia, void Function(Set<int>) quandoCambia) async {
    await tester.pumpWidget(MaterialApp(
      home: SizedBox(
        width: scena.width,
        height: scena.height,
        child: IlVeloCheSiScosta(
          key: ValueKey('${animale.name}$quale${gia.length}'),
          nome: animale.name,
          immagine: animale.fullPath,
          quale: quale,
          giaScoperte: gia,
          quandoCambia: quandoCambia,
          palette: MaestroPalette.caligo,
        ),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 50));
  }

  /// **UN DITO CHE PASSA OVUNQUE**: riga per riga a zig zag su tutta la
  /// carta, e oltre i bordi fin dove c'e' schermo.
  Future<void> passaOvunque(WidgetTester tester, GuideAnimal animale) async {
    final velo = LaCartaInQuattroPezzi(animale.name, 0);
    final r = IlVeloCheSiScosta.doveStaLIllustrazione(scena, velo.misura);
    final sinistra = (r.left - 10).clamp(1.0, scena.width - 1);
    final destra = (r.right + 10).clamp(1.0, scena.width - 1);
    final g = await tester.startGesture(Offset(sinistra, r.top));
    for (var riga = 0; riga <= velo.righe; riga++) {
      final y = r.top + r.height * riga / velo.righe;
      final xs = riga.isEven ? [sinistra, destra] : [destra, sinistra];
      for (final x in xs) {
        await g.moveTo(Offset(x, y));
      }
    }
    await g.up();
    await tester.pump(const Duration(milliseconds: 50));
  }

  testWidgets(
      'OGNI DISCESA SCOSTA ESATTAMENTE UN PEZZO, poi il dito non scopre '
      'piu, e gli altri pezzi restano, per tutti e dodici e i quattro pezzi',
      (tester) async {
    await tester.binding.setSurfaceSize(scena);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    expect(AnimalCatalog.animals.length, 12);

    final righe = <String>[];
    for (final animale in AnimalCatalog.animals) {
      var gia = <int>{};
      final perDiscesa = <int>[];
      for (var quale = 0; quale < LaCartaInQuattroPezzi.pezzi; quale++) {
        final velo = LaCartaInQuattroPezzi(animale.name, quale);
        expect(velo.perDiscesa, velo.scostabile.length,
            reason: '${animale.name} pezzo $quale: la quantita\' per '
                'discesa non e\' la misura esatta del pezzo');
        Set<int>? ultime;
        await monta(tester, animale, quale, gia, (c) => ultime = c);
        await passaOvunque(tester, animale);
        // **E UN SECONDO PASSAGGIO, che non deve scoprire piu' niente.**
        await passaOvunque(tester, animale);
        expect(ultime, isNotNull,
            reason: '${animale.name}: il gesto finito non consegna le celle');
        final nuove = ultime!.difference(gia);
        expect(nuove, velo.scostabile,
            reason: '${animale.name} alla discesa ${quale + 1}: scostate '
                '${nuove.length} celle, il pezzo ne ha ${velo.scostabile.length}');
        expect(ultime!.containsAll(gia), isTrue,
            reason: '${animale.name}: cio\' che era scostato ieri oggi e\' '
                'di nuovo coperto');
        expect(find.text('Per oggi hai scostato abbastanza.'), findsOneWidget,
            reason: '${animale.name}: il pezzo e\' finito ma l\'istruzione '
                'non lo dice');
        perDiscesa.add(nuove.length);
        gia = ultime!;
      }
      righe.add('${animale.name} ${perDiscesa.join('+')}');
    }
    // ignore: avoid_print
    print('ORDINE FZ VOCE FZ.04, LA QUANTITA\': ${righe.join('; ')}');
  });

  testWidgets(
      'IL BORDO LO DISEGNA LA MANO: un tratto verticale scopre soltanto '
      'attorno al dito, e nessuna fascia', (tester) async {
    await tester.binding.setSurfaceSize(scena);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    var controllati = 0;
    for (final animale in AnimalCatalog.animals) {
      final velo = LaCartaInQuattroPezzi(animale.name, 0);
      final r = IlVeloCheSiScosta.doveStaLIllustrazione(scena, velo.misura);
      Set<int>? ultime;
      await monta(tester, animale, 0, {}, (c) => ultime = c);
      // Il tratto: dall'alto in basso, nella colonna del pezzo piu' piena.
      final perColonna = List.filled(velo.colonne, 0);
      for (final i in velo.scostabile) {
        perColonna[i % velo.colonne]++;
      }
      final colonna =
          perColonna.indexOf(perColonna.reduce((a, b) => a > b ? a : b));
      final x = r.left + r.width * (colonna + 0.5) / velo.colonne;
      await tester.dragFrom(Offset(x, r.top + 2), Offset(0, r.height - 4));
      await tester.pump(const Duration(milliseconds: 50));
      expect(ultime, isNotEmpty,
          reason: '${animale.name}: il tratto non ha scostato niente');
      final righeToccate = <int>{};
      for (final i in ultime!) {
        controllati++;
        righeToccate.add(i ~/ velo.colonne);
        // **IN PUNTI E NON IN CELLE**, ordine DQ voce 05: il pennello ha
        // il raggio in punti logici, e una cella conta scoperta quando la
        // maschera al suo centro e' almeno a meta'.
        final dx = ((i % velo.colonne + 0.5) - (colonna + 0.5)) *
            r.width /
            velo.colonne;
        expect(
            dx.abs(),
            lessThanOrEqualTo(LaCartaInQuattroPezzi.raggioDelPennello *
                    LaCartaInQuattroPezzi.doveContaIlPennello +
                0.01),
            reason: '${animale.name}: la cella $i sta a ${dx.abs()} punti '
                'dal dito. Il velo si apre dove il dito non e\' passato: '
                'e\' una fascia, non una mano');
      }
      expect(righeToccate.length, greaterThanOrEqualTo(4),
          reason: '${animale.name}: il tratto verticale ha scostato solo '
              '${righeToccate.length} righe');
    }
    // **IL CARDINALE**: un pezzo e' alto solo otto righe (contro le decine
    // della vecchia sagoma), e il tratto ne scopre meno; la soglia e' sotto
    // il misurato (96 su dodici animali) con margine, non scelta a occhio.
    expect(controllati, greaterThan(12 * 5));
  });

  test(
      'LA CENERE COPRE OGNI CELLA COPERTA PER INTERO: il pezzo di ogni cella la '
      'contiene coi suoi angoli, e il tracciato contiene il pezzo, per tutti e '
      'dodici e a tre misure', () {
    var celle = 0;
    var nelTracciato = 0;
    for (final animale in AnimalCatalog.animals) {
      final velo = LaCartaInQuattroPezzi(animale.name, 0);
      for (final telefono in const [
        Size(320, 568),
        Size(390, 844),
        Size(1080, 2400),
      ]) {
        final r = IlVeloCheSiScosta.doveStaLIllustrazione(telefono, velo.misura);
        for (final i in velo.velato) {
          celle++;
          final pezzo = PittoreDellaCenere.pezzo(velo, i, r.size);
          final c = velo.cella(i);
          final inPunti = Rect.fromLTRB(c.left * r.width, c.top * r.height,
              c.right * r.width, c.bottom * r.height);
          for (final angolo in [inPunti.topLeft, inPunti.topRight,
              inPunti.bottomLeft, inPunti.bottomRight]) {
            expect(pezzo.contains(angolo), isTrue,
                reason: '${animale.name} a $telefono: l\'angolo $angolo della '
                    'cella $i resta fuori dal suo pezzo di cenere, e fra due '
                    'celle vicine resta un filo di manto');
          }
        }
        // **E IL TRACCIATO CONTIENE DAVVERO I PEZZI**: un campione di celle,
        // perche' il tracciato intero ha migliaia di figure.
        final forma = PittoreDellaCenere.forma(velo, velo.velato, r.size);
        for (final i in velo.velato.where((i) => i % 17 == 0)) {
          nelTracciato++;
          final c = PittoreDellaCenere.pezzo(velo, i, r.size).deflate(0.7);
          for (final p in [c.center, c.topLeft, c.bottomRight]) {
            expect(forma.contains(p), isTrue,
                reason: '${animale.name}: il tracciato della cenere non '
                    'contiene la cella $i');
          }
        }
      }
    }
    expect(celle, greaterThan(12 * 3 * 500));
    expect(nelTracciato, greaterThan(12 * 3 * 25));
  });

  test(
      'I SOLCHI SI CONSERVANO NEL DIARIO PER PIU ANIMALI INSIEME, e cambiare '
      'domanda non li porta via (ordine FZ voce 04: il riconoscimento conta '
      'su tutta la vita del Diario, non sulla domanda di oggi)', () async {
    final d = DiarioDeiViaggi();
    await d.carica();
    await d.segnaISolchi('Lupo', [
      [const Offset(0.123, 0.456), const Offset(0.2, 0.5)],
      [const Offset(0.7, 0.71)],
    ]);
    // **UN SECONDO ANIMALE, SENZA TOCCARE IL PRIMO**: chi segue ombre
    // diverse ha piu' carte scoperte a meta' insieme.
    await d.segnaISolchi('Aquila', [
      [const Offset(0.3, 0.3)],
    ]);
    final r2 = DiarioDeiViaggi();
    await r2.carica();
    expect(r2.solchiDi('Lupo'), [
      [const Offset(0.123, 0.456), const Offset(0.2, 0.5)],
      [const Offset(0.7, 0.71)],
    ]);
    expect(r2.solchiDi('Aquila'), [
      [const Offset(0.3, 0.3)],
    ]);
    expect(r2.solchiDi('Orso'), isEmpty);
    await r2.cambiaLaDomanda();
    final r3 = DiarioDeiViaggi();
    await r3.carica();
    expect(r3.solchiDi('Lupo'), isNotEmpty,
        reason: 'cambiare domanda non deve piu\' azzerare i solchi: il '
            'riconoscimento conta a prescindere dalla domanda');
    expect(r3.solchiDi('Aquila'), isNotEmpty);
  });
}
