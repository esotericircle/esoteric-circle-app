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
      'assets/img/oracolo_angeli/oracolo_primo_fotogramma_v2.webp';
  static const String ultimoFotogramma =
      'assets/img/oracolo_angeli/oracolo_ultimo_fotogramma_v2.webp';

  /// **IL FILMATO V2, IL TAVOLO CHE RESTA VUOTO.** GC Aggiunta, 22 ottobre
  /// 2026. Il fondatore: *"alla fine non devono restare le carte sul tavolo,
  /// il tavolo deve restare vuoto"*, *"la ruota dietro giri e si illumini"*,
  /// *"comprimerlo in 10 secondi"*, poi *"Ottimo"*. Consegnato nella
  /// cartella "Oracolo degli Angeli" del fondatore, verificato (10,000
  /// secondi, 1080 per 1920, 24 al secondo, 240 fotogrammi, audio AAC
  /// stereo) e ricompresso a 720 per 1280 da `tool/gli_asset_dell_ordine_gc.py`
  /// (`docs/collaudo/GC/gc_asset.txt`). Le carte alate scendono dalla scala,
  /// si posano, evaporano in polvere dorata e risalgono; l'ultimo fotogramma
  /// ha l'altare vuoto.
  ///
  /// **LAPIDE, ordine GA voce GA.08 (`finoAlleCarte`, 400 millisecondi).** Il
  /// v1 finiva con le tre carte sull'altare, e il filmato si fermava prima
  /// che scendessero: durava meno di un secondo, che e' il difetto della voce
  /// GC.07 (*"il video introduttivo dura meno di un secondo"*). PADRE: ordine
  /// GA voce GA.08. Col v2 il filmato dura per intero e si ferma sul suo
  /// ultimo fotogramma; il tocco e lo scorrimento lo saltano e il salto sfuma
  /// sullo stesso fotogramma ([ultimoFotogramma]).
  static const String filmato =
      'brand_assets/oracolo_angeli/medora_scala_di_luce_v2.mp4';
  static const String dorso = 'assets/img/angeli/ang_dorso_medora_v1.webp';

  /// **QUANTO DURA IL FILMATO** (GC.07): 240 fotogrammi a 24 al secondo.
  static const Duration durataDelFilmato = Duration(seconds: 10);

  static const Size fotogramma = Size(1080, 1920);

  /// **IL TAGLIO DELLA SCENA**: il fotogramma riempie lo schermo, centrato.
  /// Non e' una miniatura di un angelo che si mutila (guardia
  /// miniature_intere): e' la scena intera, e la geometria dell'altare qui
  /// sotto e' misurata proprio su questo taglio, come nella Stesa.
  static const BoxFit taglio = BoxFit.cover;

  static double scala(double larghezza) => larghezza / fotogramma.width;
  static double altezza(double larghezza) =>
      fotogramma.height * scala(larghezza);

  /// **LA SCENA FINISCE SUL BORDO DEL PIANO**, il fondatore il 22 ottobre
  /// 2026 alle 21:30, sul Realme: *"Devi alzare il selettore delle Domande
  /// subito sotto il piano dove atterrano le carte"*. Il bordo d'oro del piano
  /// sta alla riga 1717 del fotogramma (misurato riga per riga sull'ultimo
  /// fotogramma del v2: luminanza 105 alla 1717, sotto il basamento nero fino
  /// alla 1920); la scena si taglia alla 1725, col bordo intero. Le carte
  /// posate e quelle in piedi poggiano alla riga [basso], 1685, sopra il
  /// taglio.
  static const double bordoDelPiano = 1725;
  static double altezzaVisibile(double larghezza) =>
      bordoDelPiano * scala(larghezza);

  /// **I TRE DORSI SULL'ALTARE**, misurati a occhio sull'ultimo fotogramma
  /// (`oracolo_ultimo_fotogramma_v1.jpg`, il v1 dove le carte restavano
  /// posate; nel v2 si posano negli stessi tre posti prima di evaporare)
  /// con una griglia ogni 50 pixel
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
  /// diventa la carta, FU.02). [alzata] da 0 a 1 la raddrizza in piedi
  /// (GC.14): la prospettiva e l'inclinazione scendono insieme a zero.
  static Matrix4 posa(double larghezzaSchermo,
      {double giro = 0, double alzata = 0}) {
    final s = scala(larghezzaSchermo);
    final resta = 1 - alzata.clamp(0.0, 1.0);
    return Matrix4.identity()
      // Il segno meno: in Flutter la profondita' cresce verso chi guarda,
      // e il lato alto deve allontanarsi (misurato dalla prova).
      ..setEntry(3, 2, -prospettiva / s * resta)
      ..rotateX(angolo * resta)
      ..rotateY(math.pi * giro);
  }

  /// **IL RIQUADRO VISTO DELLA CARTA POSATA** (GC.12), nelle misure dello
  /// schermo: il trapezio in prospettiva dentro il suo rettangolo, largo
  /// quanto il lato basso e alto quanto l'altezza vista. E' dove arriva la
  /// carta in volo.
  static Rect sullAltare(int i, double larghezzaSchermo) {
    final s = scala(larghezzaSchermo);
    return Rect.fromLTWH((centriInBasso[i] - larghezzaInBasso / 2) * s,
        (basso - altezzaVista) * s, larghezzaInBasso * s, altezzaVista * s);
  }

  /// **LA CARTA IN PIEDI, INGRANDITA** (GC.14), nelle misure dello schermo,
  /// col lato basso sul bordo dell'altare.
  ///
  /// **LE TRE OCCUPANO QUASI TUTTA LA LARGHEZZA**, ordine GD voce GD.07, 23
  /// ottobre 2026. Il fondatore: *"Dopo la lettura le carte si mettono in
  /// verticale e si devono ingrandire di più, fino ad occupare quasi tutta
  /// l'area orizzontale"*. La fila delle tre lascia [margineInPiedi] dello
  /// schermo a ogni lato e [spazioInPiedi] fra una carta e l'altra: ogni
  /// carta e' larga [larghezzaInPiedi], e la fila il 94 per cento dello
  /// schermo. LAPIDE: larghe 0,23 dello schermo e centrate sopra i loro
  /// posti dell'altare, la fila ne occupava il 72 per cento.
  /// [larghezzaDellaSola] per la carta del momento, che e' una sola al
  /// centro (la voce GD.07 parla delle tre, la sola resta com'era).
  static const double margineInPiedi = 0.03;
  static const double spazioInPiedi = 0.015;
  static const double larghezzaInPiedi =
      (1 - 2 * margineInPiedi - 2 * spazioInPiedi) / 3;
  static const double larghezzaDellaSola = 0.30;

  static Rect inPiedi(int i, double larghezzaSchermo, {bool unaSola = false}) {
    final s = scala(larghezzaSchermo);
    if (unaSola) {
      final w = larghezzaSchermo * larghezzaDellaSola;
      final h = w * 1.5;
      return Rect.fromLTWH(centriInBasso[i] * s - w / 2, basso * s - h, w, h);
    }
    final w = larghezzaSchermo * larghezzaInPiedi;
    final h = w * 1.5;
    final sinistra = larghezzaSchermo *
        (margineInPiedi + i * (larghezzaInPiedi + spazioInPiedi));
    return Rect.fromLTWH(sinistra, basso * s - h, w, h);
  }

  /// **I DIECI PIXEL DEL TELEFONO** (GC.10). Il fondatore: *"alza il video di
  /// 10 pixel, c'è troppo spazio tra la testa di Medora e la barra del
  /// titolo"*, e alla domanda dell'Architetto *"1 del telefono"*: pixel
  /// fisici, che la schermata converte in punti col rapporto di pixel del
  /// dispositivo.
  static const double pixelDaAlzare = 10;
}
