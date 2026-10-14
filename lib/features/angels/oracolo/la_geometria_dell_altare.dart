import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// **LA GEOMETRIA DELLA SCENA DELL'ORACOLO.** Ordine FU voce FU.02, 15
/// ottobre 2026.
///
/// La scena e' il fotogramma intero del video della Scala di Giacobbe, 1080
/// per 1920, a tutta larghezza dello schermo: le misure qui sono in pixel di
/// quel fotogramma e si scalano con [scala].
abstract final class GeometriaDellAltare {
  static const String primoFotogramma =
      'assets/img/oracolo_angeli/oracolo_primo_fotogramma_v1.webp';
  static const String ultimoFotogramma =
      'assets/img/oracolo_angeli/oracolo_ultimo_fotogramma_v1.webp';
  static const String filmato =
      'brand_assets/oracolo_angeli/medora_scala_di_luce_v1.mp4';
  static const String dorso = 'assets/img/angeli/ang_dorso_medora_v1.webp';

  static const Size fotogramma = Size(1080, 1920);

  static double scala(double larghezza) => larghezza / fotogramma.width;
  static double altezza(double larghezza) =>
      fotogramma.height * scala(larghezza);

  /// **I TRE DORSI SULL'ALTARE**, misurati a occhio sull'ultimo fotogramma
  /// (`oracolo_ultimo_fotogramma_v1.jpg`) con una griglia ogni 50 pixel
  /// (docs/collaudo/FU/fu02_scena_oracolo.txt): tre trapezi in prospettiva,
  /// larghi 195 pixel in alto e 235 in basso, alti 150, dal pixel 1535 al
  /// 1685. Qui il lato basso di ciascuno: centro e larghezza.
  static const List<double> centriInBasso = [274.5, 539.5, 805.5];
  static const double basso = 1685;
  static const double larghezzaInBasso = 235;
  static const double larghezzaInAlto = 195;
  static const double altezzaVista = 150;

  /// **LA PROSPETTIVA**, ricavata dalle misure e non provata a occhio: una
  /// carta di proporzione 2:3 (le carte dei 72 sono 853 per 1280) larga
  /// [larghezzaInBasso], ruotata attorno al lato basso di [angolo] e vista
  /// con la prospettiva [prospettiva], ha il lato alto largo
  /// [larghezzaInAlto] e l'altezza vista [altezzaVista]. Conti nel commento
  /// della prova `test/l_altare_dell_oracolo_test.dart`, che misura i quattro
  /// angoli disegnati contro quelli del fotogramma.
  static const double altezzaDellaCarta = larghezzaInBasso * 1.5;
  static final double angolo = math.acos(
      altezzaVista * (larghezzaInBasso / larghezzaInAlto) / altezzaDellaCarta);
  static final double prospettiva = ((larghezzaInBasso / larghezzaInAlto) - 1) /
      (altezzaDellaCarta * math.sin(angolo));

  /// Il riquadro della carta dritta, prima della prospettiva, nelle misure
  /// dello schermo: il lato basso sta sull'altare.
  static Rect cartaDritta(int i, double larghezzaSchermo) {
    final s = scala(larghezzaSchermo);
    final w = larghezzaInBasso * s;
    final h = altezzaDellaCarta * s;
    return Rect.fromLTWH(centriInBasso[i] * s - w / 2, basso * s - h, w, h);
  }

  /// La trasformazione che posa la carta dritta sull'altare, attorno al suo
  /// lato basso. [giro] da 0 a 1 la fa girare su se stessa (il dorso che
  /// diventa la carta, FU.02).
  static Matrix4 posa(double larghezzaSchermo, {double giro = 0}) {
    final s = scala(larghezzaSchermo);
    return Matrix4.identity()
      // Il segno meno: in Flutter la profondita' cresce verso chi guarda,
      // e il lato alto deve allontanarsi (misurato dalla prova).
      ..setEntry(3, 2, -prospettiva / s)
      ..rotateX(angolo)
      ..rotateY(math.pi * giro);
  }
}
