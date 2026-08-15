import 'dart:io';
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:flutter_test/flutter_test.dart';

/// ACCENDERE ILLUMINA, NON COPRE. Ordine W voce 01.
///
/// **Il difetto, con tre facce e una causa.** La sfera dell'Albero passava da
/// perla di peltro con ombra e riflesso a disco d'oro piatto; l'orbo di lapis
/// della Costellazione passava da blu profondo a crema. **Il premio per aver
/// raggiunto un traguardo era veder spegnere il gioiello**, ed e' il contrario
/// di cio' che una ricompensa deve fare. La causa era un riempimento pieno al
/// settantadue per cento steso sopra l'elemento, che cancellava il modellato e
/// il colore sotto.
///
/// **Il criterio e' in numeri e non a occhio**, e si misura sulle anteprime
/// vere: fra lo stato a due traguardi e quello a cinquantacinque, sui pixel che
/// cambiano, la luminanza deve salire e **la saturazione non deve scendere**.
/// Salire di luce perdendo colore non e' accendere, e' sbiadire.
void main() {
  /// Quanto si tollera che la saturazione scenda. **Zero e' il vero criterio**,
  /// e questo numero non lo ammorbidisce: dichiara solo il rumore della misura,
  /// perche' due immagini compresse in PNG non danno mai lo stesso identico
  /// centesimo.
  const rumore = 0.02;

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
        if (satB < satA - rumore) {
          sbiaditi.add('${sentiero.name}: accendendo la saturazione scende da '
              '${satA.toStringAsFixed(2)} a ${satB.toStringAsFixed(2)}');
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
