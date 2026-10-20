import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/rituals/animal_catalog.dart';
import 'package:esoteric_circle/core/viaggio/la_carta_in_quattro_pezzi.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/features/maestri/caligo/viaggio/il_velo_che_si_scosta.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **LA CENERE RESTA SUI PEZZI DI DOMANI, E SUL VOLTO.** Ordine FZ, trovato
/// dalla simulazione da persona del 20 ottobre 2026 sul Realme 767f596c.
///
/// **Il fatto**: alla prima discesa, passando il dito su tutta la carta come
/// fa una persona curiosa, la cenere veniva via quasi tutta e la Lince si
/// vedeva intera, volto compreso
/// (`docs/collaudo/FZ/simulazioni/catture/v2_d1_09.png`). L'ordine FZ.04 dice
/// *"Ogni volta che la persona segue l'ombra di quell'animale, gratta con il
/// dito un pezzo della sua carta. Il volto dell'animale sta nel quarto pezzo e
/// si scopre per ultimo"*.
///
/// **La causa**: la contabilita' contava solo le celle del pezzo attivo, ma
/// il solco del dito registrava ogni punto toccato e il pittore scavava la
/// cenere lungo tutto il solco. Padre: ordine FZ voce FZ.04 (commit
/// `4acde9c2`).
///
/// **Riscritta lo stesso giorno per la geometria nuova** (il volto misurato
/// di ogni animale e' il quarto pezzo, il resto in tre fasce dal basso): il
/// grattabile non e' piu' una fascia continua sopra una riga, e la misura
/// guarda la sua forma vera, cella per cella.
///
/// **Cosa misura**: il solco conservato non contiene punti fuori dal
/// grattabile di oggi, e il disegno lascia piena la cenere su ogni cella dei
/// pezzi dei giorni dopo e del volto, anche con un pennello che passa
/// dappertutto.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  const scena = Size(390, 844);
  /// Dove sta l'immagine di [nome] nella scena, con la sua misura vera.
  Rect illustrazioneDi(String nome) => IlVeloCheSiScosta.doveStaLIllustrazione(
      scena, LaCartaInQuattroPezzi(nome, 0).misura);

  /// Il dito della persona curiosa, in frazioni della carta: a zig zag su
  /// tutta la carta, dall'alto in basso.
  List<Offset> ziczac(int righe) => [
        for (var riga = 0; riga <= righe; riga++)
          for (final x in riga.isEven ? [0.01, 0.99] : [0.99, 0.01])
            Offset(x, (riga / righe).clamp(0.002, 0.998)),
      ];

  testWidgets(
      'IL SOLCO CONSERVATO STA SOLO DOVE OGGI SI GRATTA: un dito che passa '
      'ovunque, ai pezzi 0, 1 e 2, lascia nel Diario solo punti dei pezzi '
      'fatti e di oggi, mai del volto', (tester) async {
    await tester.binding.setSurfaceSize(scena);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    var guardati = 0;
    for (final nome in ['Cavallo', 'Lince', 'Serpente']) {
      final animale = AnimalCatalog.animals.firstWhere((a) => a.name == nome);
      for (final quale in [0, 1, 2]) {
        List<List<Offset>> conservati = const [];
        await tester.pumpWidget(MaterialApp(
          home: SizedBox(
            width: scena.width,
            height: scena.height,
            child: IlVeloCheSiScosta(
              key: ValueKey('$nome$quale'),
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
        final punti = ziczac(32);
        final illustrazione = illustrazioneDi(nome);
        Offset inScena(Offset f) => Offset(
            illustrazione.left + f.dx * illustrazione.width,
            illustrazione.top + f.dy * illustrazione.height);
        final g = await tester.startGesture(inScena(punti.first));
        for (final p in punti.skip(1)) {
          await g.moveTo(inScena(p));
        }
        await g.up();
        await tester.pump(const Duration(milliseconds: 50));
        final velo = LaCartaInQuattroPezzi(animale.name, quale);
        // **I TRATTI, NON SOLO I PUNTI**: il pittore scava lungo il segmento
        // fra due punti conservati, quindi si guarda ogni segmento campionato
        // ogni mezzo centesimo. E si misura col pezzo della cella, non con
        // `siGratta`, che e' proprio cio' che la prova sorveglia.
        final tutti = <Offset>[
          for (final s in conservati) ...[
            if (s.length == 1) s.first,
            for (var k = 1; k < s.length; k++)
              for (var t = 0; t <= 200; t++)
                Offset.lerp(s[k - 1], s[k], t / 200)!,
          ],
        ];
        guardati += tutti.length;
        // **SUL CONFINE FRA DUE CELLE IL PUNTO E' DI TUTTE E DUE**: un punto
        // conservato esattamente sulla riga fra due fasce, ricampionato, puo'
        // cadere di un milionesimo nella cella sopra. E' fuori solo se
        // nessuna cella lecita lo tocca entro quel milionesimo.
        bool lecito(Offset p) {
          const e = 1e-6;
          for (final dx in [-e, 0.0, e]) {
            for (final dy in [-e, 0.0, e]) {
              if (velo.pezzoDi(velo.cellaSotto(p + Offset(dx, dy))) <= quale) {
                return true;
              }
            }
          }
          return false;
        }

        final fuori = tutti.where((p) => !lecito(p)).toList();
        expect(fuori, isEmpty,
            reason: '$nome al pezzo $quale: il solco conservato ha '
                '${fuori.length} punti fuori dal grattabile di oggi, per '
                'esempio ${fuori.take(3).join(' ')}: e\' cenere scavata su '
                'pezzi dei giorni dopo o sul volto');
        // **SULLE CELLE DEL VOLTO**: il quarto pezzo e' fatto delle celle
        // che toccano il volto, ed e' su quelle che il dito non deve scavare.
        // Come sopra: sul confine esatto fra il volto e una fascia il punto
        // e' di tutte e due, ed e' nel volto solo se nessuna cella fuori dal
        // volto lo tocca entro un milionesimo.
        bool soloVolto(Offset p) {
          const e = 1e-6;
          for (final dx in [-e, 0.0, e]) {
            for (final dy in [-e, 0.0, e]) {
              if (velo.pezzoDi(velo.cellaSotto(p + Offset(dx, dy))) !=
                  LaCartaInQuattroPezzi.pezzi - 1) {
                return false;
              }
            }
          }
          return true;
        }

        final nelVolto = tutti.where(soloVolto).length;
        expect(nelVolto, 0,
            reason: '$nome al pezzo $quale: $nelVolto punti del solco sul '
                'volto, che si scopre per ultimo');
      }
    }
    // **IL CARDINALE**: se il dito non lasciasse nessun punto la prova
    // sarebbe verde senza aver guardato niente.
    expect(guardati, greaterThan(9000),
        reason: 'i solchi conservati sono solo $guardati punti: il gesto non '
            'e\' arrivato al velo');
  });

  testWidgets(
      'IL PENNELLO NON APRE NIENTE FUORI DAL GRATTABILE: un pennello che passa '
      'dappertutto lascia piena la cenere su ogni cella dei giorni dopo e del '
      'volto, ai pezzi 0, 1 e 2, per tutti e dodici', (tester) async {
    var pixelGuardati = 0;
    var apertiDentro = 0;
    final sbagliati = <String>[];
    for (final animale in AnimalCatalog.animals) {
      final size = illustrazioneDi(animale.name).size;
      final w = size.width.ceil();
      final h = size.height.ceil();
      for (final quale in [0, 1, 2]) {
        final velo = LaCartaInQuattroPezzi(animale.name, quale);
        late Uint8List px;
        await tester.runAsync(() async {
          final p = PittoreDellaCenere(
            velo: velo,
            coperte: velo.velato,
            quanta: 1,
            // **IL SOLCO SENZA IL TAGLIO DELLA LENTE**: qui si guarda il
            // pittore da solo, con un pennello che passa anche sul volto.
            solchi: [ziczac(40)],
            scoperte: const {},
          );
          final registro = ui.PictureRecorder();
          p.paint(Canvas(registro), size);
          final img = await registro.endRecording().toImage(w, h);
          px = (await img.toByteData(
                  format: ui.ImageByteFormat.rawStraightRgba))!
              .buffer
              .asUint8List();
        });
        var aperti = 0;
        for (var i = 0; i < velo.colonne * velo.righe; i++) {
          final r = velo.cella(i);
          // **IL CUORE DELLA CELLA**, un pixel dentro i bordi: sul bordo il
          // taglio passa esatto, e l'arrotondamento non e' un difetto.
          final x0 = (r.left * size.width).ceil() + 1;
          final x1 = (r.right * size.width).floor() - 1;
          final y0 = (r.top * size.height).ceil() + 1;
          final y1 = (r.bottom * size.height).floor() - 1;
          final lecita = velo.grattabile.contains(i);
          for (var y = y0; y <= y1; y++) {
            for (var x = x0; x <= x1; x++) {
              final aperto = px[(y * w + x) * 4 + 3] < 128;
              if (lecita) {
                if (aperto) apertiDentro++;
              } else {
                pixelGuardati++;
                if (aperto) aperti++;
              }
            }
          }
        }
        if (aperti > 0)
          sbagliati.add('${animale.name} al pezzo $quale: $aperti');
      }
    }
    expect(sbagliati, isEmpty,
        reason: 'il pennello ha aperto la cenere fuori dal grattabile (pezzi '
            'dei giorni dopo o volto): ${sbagliati.join(', ')}');
    // **I DUE CARDINALI**: abbastanza pixel vietati guardati, e il pennello
    // che scava davvero dove si puo', o la prova sarebbe verde perche' il
    // pittore non disegna niente.
    expect(pixelGuardati, greaterThan(100000));
    expect(apertiDentro, greaterThan(10000),
        reason: 'il pennello non ha scavato nemmeno dove si puo\': la prova '
            'non sta guardando il pennello');
  });
}
