import 'dart:io';
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:flutter_test/flutter_test.dart';

/// ACCENDERE ILLUMINA CON UNA LUCE CALDA, NON CON LA CENERE. Ordine W voce 01,
/// grandezza cambiata dall'ordine AF voce 02.
///
/// **La storia di questa guardia, perche' non si riapra.** Nacque contro il
/// disco d'oro piatto che copriva il gioiello: la pretesa era che accendendo la
/// saturazione della materia non scendesse, cioe' che la luce fosse un velo.
/// **Quella filosofia e' stata ribaltata da Mauro nell'ordine AF**: una perla
/// accesa deve leggersi come una LAMPADINA, e la lampadina RIDIPINGE il disco
/// apposta, bianco caldo e oro caldo col riflesso. Coprire non e' piu' il
/// difetto: e' la decisione.
///
/// **La grandezza nuova, col perche'.** Cio' che resta vero e' che accendere
/// non deve produrre CENERE: la luminanza sale, e la luce che si vede e' calda
/// e colorata, non un grigio slavato. Sui pixel che cambiano, la saturazione
/// mediana da accesi deve restare sopra 0,40: l'oro caldo puro sta a 0,67, il
/// colmo bianco e i riflessi la abbassano, e sotto 0,40 non e' piu' una luce
/// dorata ma un lavaggio. Il vecchio criterio, non scendere rispetto alla
/// materia, oggi direbbe il falso: il lapis a 0,63 DEVE scendere quando sopra
/// ci si ridipinge una lampadina d'oro.
void main() {
  /// Il pavimento della saturazione accesa: sotto, la luce e' cenere.
  const luceCalda = 0.40;

  Future<List<double>> misura(String file) async {
    final byte = await File(file).readAsBytes();
    final codice = await ui.instantiateImageCodec(byte);
    final immagine = (await codice.getNextFrame()).image;
    final dati = (await immagine.toByteData(format: ui.ImageByteFormat.rawRgba))!
        .buffer
        .asUint8List();
    return List<double>.generate(dati.length, (i) => dati[i].toDouble());
  }

  testWidgets('accendere alza la luce e non spegne il colore', (tester) async {
    await tester.runAsync(() async {
      var osservati = 0;
      final sbiaditi = <String>[];
      for (final sentiero in Sentieri.tutti) {
        final spento =
            'docs/preview/journal_${sentiero.name}_due.png';
        final acceso =
            'docs/preview/journal_${sentiero.name}_cinquantacinque.png';
        if (!File(spento).existsSync() || !File(acceso).existsSync()) continue;
        osservati++;
        final a = await misura(spento);
        final b = await misura(acceso);
        var lumA = 0.0, lumB = 0.0, satA = 0.0, satB = 0.0, quanti = 0;
        for (var i = 0; i + 3 < a.length; i += 4) {
          final d = (a[i] - b[i]).abs() +
              (a[i + 1] - b[i + 1]).abs() +
              (a[i + 2] - b[i + 2]).abs();
          if (d <= 30) continue;
          quanti++;
          for (final coppia in [
            [a, 0],
            [b, 1]
          ]) {
            final px = coppia[0] as List<double>;
            final r = px[i], g = px[i + 1], bl = px[i + 2];
            final l = (r * 299 + g * 587 + bl * 114) / 1000.0;
            final mx = [r, g, bl].reduce((x, y) => x > y ? x : y);
            final mn = [r, g, bl].reduce((x, y) => x < y ? x : y);
            final s = mx > 0 ? (mx - mn) / mx : 0.0;
            if (coppia[1] == 0) {
              lumA += l;
              satA += s;
            } else {
              lumB += l;
              satB += s;
            }
          }
        }
        if (quanti == 0) continue;
        lumA /= quanti;
        lumB /= quanti;
        satA /= quanti;
        satB /= quanti;
        // ignore: avoid_print
        print('ORDINE W VOCE 01: ${sentiero.name} spenta lum '
            '${lumA.toStringAsFixed(1)} sat ${satA.toStringAsFixed(2)} -> '
            'accesa lum ${lumB.toStringAsFixed(1)} sat '
            '${satB.toStringAsFixed(2)}, su $quanti pixel');
        if (lumB <= lumA) {
          sbiaditi.add('${sentiero.name}: accendendo la luce non sale');
        }
        if (satB < luceCalda) {
          sbiaditi.add('${sentiero.name}: la luce accesa ha saturazione '
              '${satB.toStringAsFixed(2)}, sotto il pavimento di '
              '${luceCalda.toStringAsFixed(2)}: non e\' una lampadina calda, '
              'e\' cenere');
        }
      }
      // **QUANTE OSSERVAZIONI, e cade se sono zero.**
      // ignore: avoid_print
      print('ORDINE W VOCE 01: sentieri osservati $osservati');
      expect(osservati, greaterThan(0),
          reason: 'nessuna anteprima guardata: la prova gira a vuoto');
      expect(sbiaditi, isEmpty,
          reason: 'accendere un elemento deve lasciarlo quello che era, piu\' '
              'luminoso: qui lo sbiadisce. ${sbiaditi.join(" | ")}');
    });
  });
}
