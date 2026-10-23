// ignore_for_file: avoid_print
import 'package:esoteric_circle/features/angels/oracolo/la_geometria_dell_altare.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// **LE CARTE SI GIRANO NELLA POSIZIONE ESATTA DEI DORSI.** Ordine FU voce
/// FU.02: "i tre dorsi dell'ultimo fotogramma si girano nelle tre carte
/// vere, nella posizione esatta".
///
/// Si applica la posa come la applica `Transform` con `alignment:
/// Alignment.bottomCenter` (sposta l'origine al lato basso, trasforma,
/// rimette l'origine) e si confrontano i quattro angoli disegnati con quelli
/// misurati sul fotogramma: lato alto largo 195 pixel, lato basso 235,
/// altezza vista 150, alla scala del fotogramma 1080.
///
/// I conti: una carta 2:3 larga 235 e' alta 352,5. Il lato basso resta dov'e'
/// (profondita' zero); il lato alto, ruotato di un angolo a, sale di
/// 352,5 cos a e si allontana di 352,5 sen a, e la prospettiva lo divide per
/// w = 1 + p 352,5 sen a. Larghezza in alto 235 / w = 195 da' w = 1,205;
/// altezza vista 352,5 cos a / w = 150 da' cos a = 0,513, a = 59,1 gradi,
/// e p = 0,205 / (352,5 sen a) = 0,000678 per pixel del fotogramma.
void main() {
  for (final larghezza in const [360.0, 390.0, 430.0]) {
    test('a $larghezza punti i quattro angoli coincidono col fotogramma', () {
      final s = GeometriaDellAltare.scala(larghezza);
      for (var i = 0; i < 3; i++) {
        final r = GeometriaDellAltare.cartaDritta(i, larghezza);
        final origine = r.bottomCenter;
        final m = Matrix4.translationValues(origine.dx, origine.dy, 0)
          ..multiply(GeometriaDellAltare.posa(larghezza))
          ..multiply(Matrix4.translationValues(-origine.dx, -origine.dy, 0));
        Offset p(Offset o) => MatrixUtils.transformPoint(m, o);
        final alSx = p(r.topLeft), alDx = p(r.topRight);
        final baSx = p(r.bottomLeft), baDx = p(r.bottomRight);
        final larghezzaAlta = (alDx.dx - alSx.dx) / s;
        final larghezzaBassa = (baDx.dx - baSx.dx) / s;
        final alto = alSx.dy / s;
        final bassoY = baSx.dy / s;
        final centro = (alSx.dx + alDx.dx) / 2 / s;
        print('FU.02 carta ${i + 1} a $larghezza: alto ${alto.toStringAsFixed(1)} '
            'basso ${bassoY.toStringAsFixed(1)}, larga in alto '
            '${larghezzaAlta.toStringAsFixed(1)} e in basso '
            '${larghezzaBassa.toStringAsFixed(1)}, centro ${centro.toStringAsFixed(1)}');
        expect(larghezzaBassa, closeTo(235, 1));
        expect(larghezzaAlta, closeTo(195, 2));
        expect(bassoY, closeTo(1685, 1));
        expect(alto, closeTo(1535, 2));
        expect(centro, closeTo(GeometriaDellAltare.centriInBasso[i], 1));
      }
    });
  }

  test('a meta\' giro la carta e\' di taglio, alla fine e\' di nuovo larga', () {
    const larghezza = 390.0;
    final r = GeometriaDellAltare.cartaDritta(1, larghezza);
    double larghezzaBassa(double giro) {
      final o = r.bottomCenter;
      final m = Matrix4.translationValues(o.dx, o.dy, 0)
        ..multiply(GeometriaDellAltare.posa(larghezza, giro: giro))
        ..multiply(Matrix4.translationValues(-o.dx, -o.dy, 0));
      final a = MatrixUtils.transformPoint(m, r.bottomLeft);
      final b = MatrixUtils.transformPoint(m, r.bottomRight);
      return (b.dx - a.dx).abs();
    }

    expect(larghezzaBassa(0.5), lessThan(1));
    expect(larghezzaBassa(1), closeTo(r.width, 0.5));
  });
}
