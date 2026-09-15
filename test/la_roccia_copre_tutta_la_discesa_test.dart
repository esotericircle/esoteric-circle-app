import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:esoteric_circle/features/maestri/caligo/viaggio/il_tunnel_che_scende.dart';

/// **LA ROCCIA COPRE TUTTA LA DISCESA, dall'inizio alla fine.** Ordine DG,
/// collaudo a video della 2249, 12 settembre 2026.
///
/// **Parole del fondatore:** *"la discesa del viaggio e' ancora una merda con
/// grafica procedurale e ti ho fornito la grafica con texture roccia"*.
///
/// **IL DIFETTO CHE LA FA NASCERE, visto sul 767f596c.** La texture c'era, e a
/// tre secondi di discesa si vedeva ai soli bordi; **a diciotto secondi era
/// sparita**, restava una striscia in fondo e sopra il blu. Due cause insieme:
/// `FractionalTranslation` spostava la roccia di una frazione della PROPRIA
/// altezza, che era il doppio dello schermo, e gli anelli del pittore erano
/// poligoni pieni fra il 30 e l'85 per cento di opacita'.
///
/// **LA GRANDEZZA MISURATA E' LA GRANA**, cioe' quanto cambiano i pixel da un
/// vicino all'altro, nelle due fasce **in alto e in basso** dello schermo: la
/// roccia ha grana, il blu di fondo no, e il centro non si guarda perche' li'
/// c'e' il buio del punto di fuga, ed e' voluto. Si misura a **venti quote**,
/// perche' il difetto stava a una quota sola e le altre erano giuste.
///
/// **VISTA ROSSA DUE VOLTE, una per causa.** Rimettendo lo spostamento
/// vecchio, fino a due schermi, la grana piu' bassa e' scesa a 1,00 nella
/// fascia bassa gia' a quota 0,05. E rimettendo il pittore a coprire tutto,
/// cioe' il fondo pieno sopra la roccia, e' scesa a 1,00 nella
/// fascia alta gia' alla prima quota.
void main() {
  const scena = Size(390, 844);

  double granaDi(Uint8List b, int larga, Rect r) {
    double luce(int x, int y) {
      final i = (y * larga + x) * 4;
      if (i < 0 || i + 2 >= b.length) return 0;
      return (b[i] + b[i + 1] + b[i + 2]) / 3;
    }

    var somma = 0.0;
    var quanti = 0;
    for (var y = r.top.toInt(); y < r.bottom.toInt() - 1; y++) {
      for (var x = r.left.toInt(); x < r.right.toInt() - 1; x++) {
        somma += (luce(x + 1, y) - luce(x, y)).abs() +
            (luce(x, y + 1) - luce(x, y)).abs();
        quanti++;
      }
    }
    return quanti == 0 ? 0 : somma / quanti;
  }

  testWidgets(
      'a ogni quota della discesa la roccia si vede in alto e in basso',
      (tester) async {
    await tester.binding.setSurfaceSize(scena);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    const quote = [
      0.0, 0.05, 0.10, 0.15, 0.20, 0.25, 0.30, 0.35, 0.40, 0.45, //
      0.50, 0.55, 0.60, 0.65, 0.70, 0.75, 0.80, 0.85, 0.90, 0.95,
    ];
    final alta = Rect.fromLTWH(0, 0, scena.width, scena.height * 0.14);
    final bassa = Rect.fromLTWH(
        0, scena.height * 0.86, scena.width, scena.height * 0.14);

    final peggiori = <String>[];
    var minima = double.infinity;
    var dove = '';

    await tester.runAsync(() async {
      for (final q in quote) {
        await tester.pumpWidget(MaterialApp(
          home: RepaintBoundary(
            key: const Key('foglio'),
            child: SizedBox(
              width: scena.width,
              height: scena.height,
              child: TunnelCheScende(quantoSiEScesi: q, senzaMoto: false),
            ),
          ),
        ));
        await precacheImage(const AssetImage(TunnelCheScende.parete),
            tester.element(find.byType(SizedBox).first));
        await tester.pump(const Duration(milliseconds: 50));
        final foglio = tester.renderObject<RenderRepaintBoundary>(
            find.byKey(const Key('foglio')));
        final img = await foglio.toImage();
        final dati = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
        final b = dati!.buffer.asUint8List();
        for (final (nome, fascia) in [('alta', alta), ('bassa', bassa)]) {
          final g = granaDi(b, scena.width.toInt(), fascia);
          if (g < minima) {
            minima = g;
            dove = 'fascia $nome a quota ${q.toStringAsFixed(2)}';
          }
          if (g < 3.0) {
            peggiori.add('fascia $nome a quota ${q.toStringAsFixed(2)}: '
                'grana ${g.toStringAsFixed(2)}');
          }
        }
      }
    });

    // ignore: avoid_print
    print('ORDINE DG, LA ROCCIA NELLA DISCESA: ${quote.length} quote, due '
        'fasce ciascuna; la grana piu bassa e ${minima.toStringAsFixed(2)} '
        '($dove). Il blu di fondo senza roccia vale zero.');
    expect(peggiori, isEmpty,
        reason: 'IN QUESTI PUNTI DELLA DISCESA LA ROCCIA NON SI VEDE:\n'
            '${peggiori.join('\n')}\n\n'
            'E\' il difetto visto sul 767f596c con la 2249: a diciotto '
            'secondi di discesa la texture era salita via e restava il blu. '
            'Il fondatore le texture le ha fornite, e la discesa deve '
            'mostrarle dall\'inizio alla fine.');
  });
}
