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

  /// **QUANDO NEL FILMATO COMPAIONO LE CARTE**, ordine GA voce GA.08, 20
  /// ottobre 2026, misurato sui fotogrammi del file (720 per 1280, 24 al
  /// secondo, 192 fotogrammi, 8 secondi) in
  /// `docs/collaudo/GA/ga08_le_carte_nel_filmato.txt`: fino al fotogramma
  /// 23 sulla scala scende solo polvere dorata; al fotogramma 24 (1,00 s) il
  /// bordo della prima carta alata compare in cima alla scala, dal 40 (1,67
  /// s) le carte scendono intere, fra il 110 e il 130 (da 4,6 a 5,4 s) si
  /// posano sull'altare.
  static const Duration primaCartaNelFilmato = Duration(milliseconds: 1000);

  /// **IL FILMATO SI FERMA PRIMA DELLE CARTE** (GA.08): il fondatore,
  /// *"L'oracolo degli angeli non mostra all'inizio, all'apertura, nessuna
  /// Carta prima che l'utente le scelga"*. Finche' non arrivano i due asset
  /// del fondatore (le carte che spariscono in polvere dorata), la scena si
  /// ferma qui e sfuma sulla scena ferma con la dissolvenza del salto
  /// (`IlFilmatoCheSfuma.dissolvenza`, 450 ms): il lettore legge la posizione
  /// a passi di circa cento millisecondi, quindi la dissolvenza finisce entro
  /// 400 + 100 + 450 = 950 ms, prima del fotogramma 24.
  static const Duration finoAlleCarte = Duration(milliseconds: 400);

  static const Size fotogramma = Size(1080, 1920);

  /// **IL TAGLIO DELLA SCENA**: il fotogramma riempie lo schermo, centrato.
  /// Non e' una miniatura di un angelo che si mutila (guardia
  /// miniature_intere): e' la scena intera, e la geometria dell'altare qui
  /// sotto e' misurata proprio su questo taglio, come nella Stesa.
  static const BoxFit taglio = BoxFit.cover;

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
