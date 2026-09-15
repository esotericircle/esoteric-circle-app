// ignore_for_file: avoid_print
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/viaggio/diario_dei_viaggi.dart';
import 'package:esoteric_circle/core/viaggio/dove_sta_la_testa.dart';
import 'package:esoteric_circle/core/viaggio/il_velo_dell_animale.dart';
import 'package:esoteric_circle/core/viaggio/le_sagome_in_celle.dart';
import 'package:esoteric_circle/features/maestri/caligo/viaggio/il_velo_che_si_scosta.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **IL VELO DI CENERE, CONTINUO.** Ordine DQ voce 05, 15 settembre 2026.
///
/// *"Fa veramente cagare, non sembra proprio cenere ed e' tutta pixellata"*:
/// il velo scostava celle intere di una griglia a quaranta colonne. **Qui si
/// misura il disegno**, rasterizzato: che il bordo del solco segua il dito e
/// non le celle, che la testa resti coperta anche col dito sopra, che la
/// grana sia della risoluzione dello schermo e non una piastrella, che le
/// braci si accendano e si spengano, che la cenere si assottigli vicino ai
/// solchi e si accumuli ai lati.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  const scena = Size(390, 844);
  const r = IlVeloDellAnimale.raggioDelPennello;

  /// Il Lupo: la sua illustrazione nella scena, e un tratto diagonale sul
  /// corpo, lontano dalla testa.
  final velo = IlVeloDellAnimale('Lupo');
  final illustrazione =
      IlVeloCheSiScosta.doveStaLIllustrazione(scena, LeSagome.misure['Lupo']!);
  final size = illustrazione.size;

  /// Un tratto diagonale dentro il corpo: dal centro di massa delle celle
  /// scostabili, trenta punti in su a sinistra e trenta in giu' a destra.
  (Offset, Offset) tratto() {
    var sx = 0.0, sy = 0.0;
    for (final i in velo.scostabile) {
      sx += velo.centro(i).dx;
      sy += velo.centro(i).dy;
    }
    final c = Offset(sx / velo.scostabile.length, sy / velo.scostabile.length);
    final d = Offset(30 / size.width, 30 / size.height);
    return (c - d, c + d);
  }

  /// La cenere dipinta da sola su un fondo trasparente: il canale alfa e' la
  /// cenere. [solchi] in frazioni.
  Future<(Uint8List, int, int)> dipingi(
      WidgetTester tester, List<List<Offset>> solchi,
      {Set<int>? scoperte}) async {
    late (Uint8List, int, int) fatto;
    await tester.runAsync(() async {
      final p = PittoreDellaCenere(
        velo: velo,
        coperte: velo.velato.difference(scoperte ?? {}),
        quanta: 1,
        solchi: solchi,
        scoperte: scoperte ?? {},
      );
      final registro = ui.PictureRecorder();
      p.paint(Canvas(registro), size);
      final w = size.width.ceil();
      final h = size.height.ceil();
      final img = await registro.endRecording().toImage(w, h);
      // **I COLORI VERI**, non premoltiplicati: dove la cenere e' sottile
      // il premoltiplicato abbassa la luce e confonderebbe la cresta.
      final dati =
          await img.toByteData(format: ui.ImageByteFormat.rawStraightRgba);
      fatto = (dati!.buffer.asUint8List(), w, h);
    });
    return fatto;
  }

  double distanza(Offset p, Offset a, Offset b) {
    final ab = b - a;
    final l2 = ab.dx * ab.dx + ab.dy * ab.dy;
    final t = (((p - a).dx * ab.dx + (p - a).dy * ab.dy) / l2).clamp(0.0, 1.0);
    return (p - (a + ab * t)).distance;
  }

  testWidgets(
      'IL SOLCO SEGUE IL DITO SENZA SCALINI: il suo bordo sta a una distanza '
      'costante dal tratto, e non sui lati delle celle', (tester) async {
    final (a, b) = tratto();
    final (px, w, h) = await dipingi(tester, [
      [a, b]
    ]);
    final pa = Offset(a.dx * size.width, a.dy * size.height);
    final pb = Offset(b.dx * size.width, b.dy * size.height);
    bool aperto(int x, int y) => px[(y * w + x) * 4 + 3] < 128;
    // **IL BORDO**: i pixel aperti con un vicino coperto, attorno al tratto
    // e non oltre le sue punte, dove il pennello e' un semicerchio.
    final distanze = <double>[];
    for (var y = 1; y < h - 1; y++) {
      for (var x = 1; x < w - 1; x++) {
        final q = Offset(x + 0.5, y + 0.5);
        final ab = pb - pa;
        final t = ((q - pa).dx * ab.dx + (q - pa).dy * ab.dy) /
            (ab.dx * ab.dx + ab.dy * ab.dy);
        if (t < 0.15 || t > 0.85) continue;
        final d = distanza(q, pa, pb);
        if (d > r * 1.6) continue;
        if (!aperto(x, y)) continue;
        if (aperto(x + 1, y) && aperto(x - 1, y) && aperto(x, y + 1) &&
            aperto(x, y - 1)) {
          continue;
        }
        distanze.add(d);
      }
    }
    distanze.sort();
    // **IL CARDINALE**: il solco c'e', e ha un bordo lungo.
    expect(distanze.length, greaterThan(60),
        reason: 'il tratto non ha aperto un solco nella cenere');
    final q1 = distanze[distanze.length ~/ 4];
    final q3 = distanze[distanze.length * 3 ~/ 4];
    final mediana = distanze[distanze.length ~/ 2];
    print('ORDINE DQ VOCE 05, IL BORDO DEL SOLCO: ${distanze.length} pixel, '
        'mediana ${mediana.toStringAsFixed(1)} punti dal tratto, fra il primo '
        'e il terzo quarto ${(q3 - q1).toStringAsFixed(2)} punti');
    // **LO SCALINO SI MISURA COSI'**: un bordo fatto dai lati delle celle,
    // larghe quasi dieci punti, sta dal tratto a distanze che variano quanto
    // una cella; il bordo di un pennello tondo sta tutto alla stessa
    // distanza. Soglia: tre punti fra il primo e il terzo quarto.
    expect(q3 - q1, lessThan(3),
        reason: 'il bordo del solco non segue il dito: sta dal tratto a '
            'distanze che variano di ${(q3 - q1).toStringAsFixed(1)} punti, '
            'come i lati di una griglia');
    expect(mediana, inInclusiveRange(r * 0.7, r * 1.1),
        reason: 'il solco non e largo quanto il pennello');
  });

  testWidgets(
      'LA TESTA RESTA COPERTA ANCHE COL DITO SOPRA, e il solco le si ferma '
      'contro col bordo sfumato', (tester) async {
    final t = DoveStaLaTesta.di('Lupo')!;
    final (a, _) = tratto();
    // Il tratto parte dal corpo e attraversa tutta la testa.
    final (px, w, h) = await dipingi(tester, [
      [a, t.center, Offset(t.right + 0.02, t.top - 0.02)]
    ]);
    var guardati = 0;
    final scoperti = <String>[];
    for (var ix = 0; ix <= 20; ix++) {
      for (var iy = 0; iy <= 20; iy++) {
        final x = ((t.left + t.width * ix / 20) * size.width).floor().clamp(0, w - 1);
        final y = ((t.top + t.height * iy / 20) * size.height).floor().clamp(0, h - 1);
        guardati++;
        final alfa = px[(y * w + x) * 4 + 3];
        if (alfa < 250) scoperti.add('($x,$y) $alfa');
      }
    }
    expect(guardati, 441);
    expect(scoperti, isEmpty,
        reason: 'il dito ha scoperto un pezzo di testa: ${scoperti.take(5)}');
    // **IL BORDO SFUMATO**: lungo il tratto, fra il corpo aperto e la testa
    // coperta, la cenere sale per piu' pixel, non in un colpo.
    final da = Offset(a.dx * size.width, a.dy * size.height);
    final verso =
        Offset(t.center.dx * size.width, t.center.dy * size.height);
    final valori = <int>[];
    for (var k = 0; k <= 200; k++) {
      final p = Offset.lerp(da, verso, k / 200)!;
      valori.add(px[(p.dy.floor().clamp(0, h - 1) * w +
                  p.dx.floor().clamp(0, w - 1)) *
              4 +
          3]);
    }
    final intermedi = valori.where((v) => v > 30 && v < 225).length;
    print('ORDINE DQ VOCE 05, LA TESTA: 441 punti coperti; lungo il tratto '
        '$intermedi campioni fra aperto e coperto');
    expect(intermedi, greaterThanOrEqualTo(3),
        reason: 'il solco si ferma contro la testa di taglio netto');
  });

  test(
      'LA GRANA SI CALCOLA ALLA RISOLUZIONE DELLO SCHERMO, a piu ottave, e '
      'non si ripete', () {
    const larga = 600, alta = 400;
    final g = GranaDellaCenere.pixelAllaScena(
        (larga: larga, alta: alta, seme: 7, densita: 1, periodica: false));
    int luce(int x, int y) {
      final i = (y * larga + x) * 4;
      return g[i] + g[i + 1] + g[i + 2];
    }

    // **NON E' UNA PIASTRELLA**: a duecentocinquantasei pixel di distanza,
    // il lato della piastrella di riserva, la grana non torna uguale.
    var diversi = 0.0;
    for (var y = 0; y < alta; y += 3) {
      for (var x = 0; x < larga - 256; x += 3) {
        diversi += (luce(x, y) - luce(x + 256, y)).abs() / 3;
      }
    }
    diversi /= (alta / 3) * ((larga - 256) / 3);
    // **UN PIXEL DI GRANA PER UN PIXEL VERO**: due pixel vicini uguali sono
    // una grana ingrandita.
    var uguali = 0, coppie = 0;
    for (var y = 0; y < alta; y++) {
      for (var x = 0; x < larga - 1; x++) {
        coppie++;
        if (luce(x, y) == luce(x + 1, y)) uguali++;
      }
    }
    // **A PIU' OTTAVE**: le medie di blocchi da cento pixel non sono tutte
    // uguali, i toni si addensano e si diradano.
    final medie = <double>[];
    for (var by = 0; by + 100 <= alta; by += 100) {
      for (var bx = 0; bx + 100 <= larga; bx += 100) {
        var s = 0.0;
        for (var y = by; y < by + 100; y++) {
          for (var x = bx; x < bx + 100; x++) {
            s += luce(x, y) / 3;
          }
        }
        medie.add(s / 10000);
      }
    }
    final m = medie.reduce((a, b) => a + b) / medie.length;
    final spread = math.sqrt(
        medie.map((v) => (v - m) * (v - m)).reduce((a, b) => a + b) /
            medie.length);
    print('ORDINE DQ VOCE 05, LA GRANA: a 256 pixel differisce di '
        '${diversi.toStringAsFixed(1)}, vicini uguali '
        '${(uguali * 100 / coppie).toStringAsFixed(1)} per cento, i blocchi '
        'da cento pixel variano di ${spread.toStringAsFixed(1)}');
    expect(diversi, greaterThan(6));
    expect(uguali / coppie, lessThan(0.2));
    expect(spread, greaterThan(1.5));
  });

  testWidgets('la grana alla scena si prepara della misura dello schermo',
      (tester) async {
    GranaDellaCenere.accesa = true;
    addTearDown(() => GranaDellaCenere.accesa = false);
    await tester.runAsync(() async {
      var pronta = false;
      expect(GranaDellaCenere.allaScena(const Size(100, 80), 2.5, () {
        pronta = true;
      }), isNull);
      for (var k = 0; k < 200 && !pronta; k++) {
        await Future<void>.delayed(const Duration(milliseconds: 20));
      }
      expect(pronta, isTrue);
      final img = GranaDellaCenere.allaScena(const Size(100, 80), 2.5, () {});
      expect(img?.width, 250);
      expect(img?.height, 200);
    });
  });

  testWidgets('LE BRACI SI ACCENDONO SOTTO IL DITO E SI SPENGONO', (tester) async {
    Future<(int, int, int, int)> centro(Duration eta) async {
      late (int, int, int, int) c;
      await tester.runAsync(() async {
        final registro = ui.PictureRecorder();
        PittoreDelleBraci(
          braci: [
            const UnaBrace(
                da: Offset(0.3, 0.5), a: Offset(0.7, 0.5), nata: Duration.zero)
          ],
          adesso: eta,
          materia: null,
        ).paint(Canvas(registro), const Size(200, 200));
        final img = await registro.endRecording().toImage(200, 200);
        final d = (await img.toByteData(format: ui.ImageByteFormat.rawRgba))!;
        const i = (100 * 200 + 100) * 4;
        c = (d.getUint8(i), d.getUint8(i + 1), d.getUint8(i + 2),
            d.getUint8(i + 3));
      });
      return c;
    }

    final accesa = await centro(Duration.zero);
    final spenta = await centro(IlVeloCheSiScosta.vitaDellaBrace);
    print('ORDINE DQ VOCE 05, LE BRACI: accesa $accesa, spenta $spenta');
    expect(accesa.$4, greaterThan(150), reason: 'la brace non si vede');
    expect(accesa.$1, greaterThan(accesa.$2 + 60),
        reason: 'la brace non e un calore rosso');
    expect(spenta.$4, 0, reason: 'la brace non si spegne');
  });

  testWidgets(
      'IL VELO SI ASSOTTIGLIA VICINO AI SOLCHI, e la cenere spostata si '
      'accumula ai lati piu chiara', (tester) async {
    final (a, b) = tratto();
    final (px, w, h) = await dipingi(tester, [
      [a, b]
    ]);
    final pa = Offset(a.dx * size.width, a.dy * size.height);
    final pb = Offset(b.dx * size.width, b.dy * size.height);
    // Le celle coperte lontane dal tratto: la cenere piena.
    final lontane = <int>[], cresta = <int>[], sottile = <int>[];
    final luceLontana = <int>[], luceCresta = <int>[];
    for (final i in velo.scostabile) {
      final c = velo.centro(i);
      final p = Offset(c.dx * size.width, c.dy * size.height);
      final x = p.dx.floor(), y = p.dy.floor();
      if (x < 0 || y < 0 || x >= w || y >= h) continue;
      final k = (y * w + x) * 4;
      final d = distanza(p, pa, pb);
      final luce = px[k] + px[k + 1] + px[k + 2];
      if (d > r * 5) {
        lontane.add(px[k + 3]);
        luceLontana.add(luce);
      } else if (d > r * 1.05 && d < r * 1.3) {
        cresta.add(px[k + 3]);
        luceCresta.add(luce);
      } else if (d > r * 1.5 && d < r * 2.0) {
        sottile.add(px[k + 3]);
      }
    }
    double media(List<int> l) => l.reduce((a, b) => a + b) / l.length;
    print('ORDINE DQ VOCE 05, LA CENERE: lontana alfa ${media(lontane).toStringAsFixed(0)} '
        'luce ${media(luceLontana).toStringAsFixed(0)}, cresta luce '
        '${media(luceCresta).toStringAsFixed(0)}, vicino al solco alfa '
        '${media(sottile).toStringAsFixed(0)}');
    expect(lontane, isNotEmpty);
    expect(cresta, isNotEmpty);
    expect(sottile, isNotEmpty);
    expect(media(lontane), greaterThan(250), reason: 'la cenere lontana non e piena');
    expect(media(sottile), lessThan(media(lontane) - 8),
        reason: 'il velo non si assottiglia vicino al solco');
    expect(media(luceCresta), greaterThan(media(luceLontana) + 20),
        reason: 'ai lati del solco non si accumula la cenere spostata');
  });

  test('I SOLCHI SI CONSERVANO NEL DIARIO, e cambiare domanda li porta via',
      () async {
    final d = DiarioDeiViaggi();
    await d.carica();
    await d.segnaISolchi('Lupo', [
      [const Offset(0.123, 0.456), const Offset(0.2, 0.5)],
      [const Offset(0.7, 0.71)],
    ]);
    final r2 = DiarioDeiViaggi();
    await r2.carica();
    expect(r2.solchiDi('Lupo'), [
      [const Offset(0.123, 0.456), const Offset(0.2, 0.5)],
      [const Offset(0.7, 0.71)],
    ]);
    expect(r2.solchiDi('Aquila'), isEmpty);
    await r2.cambiaLaDomanda();
    final r3 = DiarioDeiViaggi();
    await r3.carica();
    expect(r3.solchiDi('Lupo'), isEmpty);
  });

  testWidgets('I SOLCHI DI IERI SI RIDIPINGONO UGUALI', (tester) async {
    final (a, b) = tratto();
    final (px, w, h) = await dipingi(tester, [
      [a, b]
    ]);
    final m = Offset((a.dx + b.dx) / 2 * size.width, (a.dy + b.dy) / 2 * size.height);
    expect(px[(m.dy.floor() * w + m.dx.floor()) * 4 + 3], lessThan(20),
        reason: 'al centro del solco di ieri la cenere e tornata');
    expect(h, greaterThan(0));
  });
}
