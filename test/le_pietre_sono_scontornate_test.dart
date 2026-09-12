import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

/// OGNI PIETRA E' SCONTORNATA DAVVERO, fronte e retro. Ordine 2161, voce 5.
///
/// La regressione: Uruz e' arrivata su un fondale nero pieno, 94,2 per cento
/// di pixel opachi contro la mediana di 71,4 delle altre ventitre, e nessuna
/// prova e' caduta. Una pietra quadrata in mezzo a pietre scontornate si vede
/// a occhio, ma l'occhio non e' una guardia: questa prova misura TUTTE le
/// pietre, cosi' la prossima runa consegnata su un fondale fa cadere il verde
/// prima di arrivare a video.
///
/// Due misure, ciascuna col suo perche':
/// - il PERIMETRO deve essere quasi tutto trasparente: una pietra vive in
///   mezzo alla sua aria, un asset squadrato tocca i bordi con pixel pieni;
/// - la QUOTA DI PIXEL OPACHI di ogni pietra deve stare vicino alla mediana
///   del mazzo: e' la misura dell'ordine, e la banda dichiarata tiene conto
///   che le pietre hanno forme diverse (dal 62 all'82 per cento oggi).
void main() {
  /// Oltre questa distanza dalla mediana una pietra non e' piu' una forma
  /// diversa: e' un fondale. Uruz squadrata stava a +22,8 dalla mediana.
  const bandaDallaMediana = 14.0;

  /// Sul perimetro si tollera solo il rumore di compressione: mezzo punto
  /// percentuale. Uruz squadrata aveva il perimetro pieno.
  const perimetroOpacoMassimo = 0.5;

  Future<Map<String, List<double>>> misura(Directory dir) async {
    final misure = <String, List<double>>{};
    for (final f in dir.listSync().whereType<File>().toList()
      ..sort((a, b) => a.path.compareTo(b.path))) {
      if (!f.path.endsWith('.webp')) continue;
      final codec = await ui.instantiateImageCodec(f.readAsBytesSync());
      final img = (await codec.getNextFrame()).image;
      final dati = (await img.toByteData(format: ui.ImageByteFormat.rawRgba))!;
      final byte = dati.buffer.asUint8List();
      final w = img.width, h = img.height;
      var opachi = 0;
      var perimetroOpachi = 0;
      var perimetro = 0;
      for (var y = 0; y < h; y++) {
        for (var x = 0; x < w; x++) {
          final a = byte[(y * w + x) * 4 + 3];
          final pieno = a >= 128;
          if (pieno) opachi++;
          if (y == 0 || y == h - 1 || x == 0 || x == w - 1) {
            perimetro++;
            if (pieno) perimetroOpachi++;
          }
        }
      }
      img.dispose();
      misure[f.uri.pathSegments.last] = [
        opachi * 100 / (w * h),
        perimetroOpachi * 100 / perimetro,
      ];
    }
    return misure;
  }

  double mediana(List<double> valori) {
    final v = [...valori]..sort();
    return v.length.isOdd
        ? v[v.length ~/ 2]
        : (v[v.length ~/ 2 - 1] + v[v.length ~/ 2]) / 2;
  }

  for (final cartella in const [
    'assets/img/rune_bone',
    'assets/img/rune_bone_vergine',
    'assets/img_thumb/rune_bone',
  ]) {
    testWidgets('in $cartella nessuna pietra e\' un fondale', (tester) async {
      await tester.runAsync(() async {
        final misure = await misura(Directory(cartella));
        expect(misure.length, 24,
            reason: 'in $cartella le pietre non sono ventiquattro');
        final colpe = <String>[];
        misure.forEach((nome, m) {
          // La mediana delle ALTRE: la pietra sotto esame non vota su
          // se stessa, altrimenti un mazzo mezzo squadrato si assolverebbe.
          final altre = misure.entries
              .where((e) => e.key != nome)
              .map((e) => e.value[0])
              .toList();
          final med = mediana(altre);
          if ((m[0] - med).abs() > bandaDallaMediana) {
            colpe.add('$nome: opachi ${m[0].toStringAsFixed(1)}% contro la '
                'mediana ${med.toStringAsFixed(1)} delle altre, oltre la '
                'banda di $bandaDallaMediana');
          }
          if (m[1] > perimetroOpacoMassimo) {
            colpe.add('$nome: perimetro opaco al '
                '${m[1].toStringAsFixed(1)}%, una pietra scontornata '
                'non tocca i bordi del suo riquadro');
          }
        });
        expect(colpe, isEmpty, reason: colpe.join('\n'));
      });
    });
  }
}
