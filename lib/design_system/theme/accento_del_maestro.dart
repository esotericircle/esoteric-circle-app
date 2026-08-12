import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/maestro/maestro.dart';
import 'maestro_palette.dart';

/// L'ACCENTO DI UN MAESTRO SU UNA SUPERFICIE CHIARA, leggibile per costruzione.
///
/// **Una regola sola per tutti e tre, e serve.** Preso com'e', il verde di Aura
/// su un vetro chiaro ha un contrasto di 2,9, sotto la soglia di 4,5 che rende
/// leggibile un testo: sarebbe un accento che si vede peggio degli altri due
/// proprio dove va letto. Invece di scegliere a mano tre colori diversi, che e'
/// il modo di sbagliarne uno senza accorgersene, il colore del Maestro si
/// scurisce finche' il contrasto non basta. Blu e rosso passano al primo giro e
/// restano quelli della palette; il verde scende di quanto serve e non di piu'.
///
/// **Viveva dentro `ritual_gift_card.dart`**, privato a quel file, e la scheda
/// del Rito dell'Alba era l'unica superficie che sapesse essere leggibile.
/// Adesso e' un punto solo, perche' le superfici che portano il colore del
/// Maestro del giorno sono piu' d'una e devono dire la stessa cosa.
class AccentoDelMaestro {
  const AccentoDelMaestro._();

  /// Il contrasto minimo fra accento e superficie, dalle WCAG per il testo
  /// normale.
  static const double contrastoMinimo = 4.5;

  /// La superficie chiara di casa: il vetro delle schede dei Doni.
  static const Color vetro = Color(0xFFFBF4E2);

  /// L'accento di [maestro] su [superficie], portato quanto basta a leggersi.
  ///
  /// **La direzione la decide la superficie, non una scelta scritta qui.** Su
  /// un vetro chiaro il colore scende, su un fondale scuro sale: la regola
  /// scritta in un verso solo avrebbe reso illeggibili proprio le schermate dei
  /// riti, che sono le piu' scure dell'app.
  static Color su(Maestro maestro, {Color superficie = vetro}) => portatoSu(
        MaestroPalette.forKey(ThemeKey.of(maestro)).primary,
        superficie,
      );

  /// QUALUNQUE COLORE, portato su [superficie] quanto basta a leggersi.
  ///
  /// **Perche' e' stata generalizzata, ordine P voce 12.** La regola valeva solo
  /// per i tre colori dei Maestri, quindi il regime chiaro aveva un inchiostro
  /// muto scelto a mano: `0xFF6E5B33`, che sulla superficie DICHIARATA misurava
  /// 4,25 a 1 e su quella RESA 3,82. Un colore scelto a mano invecchia appena la
  /// superficie sotto cambia, e la superficie sotto qui e' una fotografia del
  /// sole che sale. Adesso anche l'inchiostro muto passa da questa porta.
  static Color portatoSu(Color partenza, Color superficie,
      [double soglia = contrastoMinimo]) {
    var colore = partenza;
    final versoIlBasso = _luminanzaRelativa(superficie) > 0.18;
    final passo = versoIlBasso ? 0.95 : 1.0 / 0.95;
    // Venti passi bastano e avanzano: ogni passo sposta il cinque per cento, e
    // dopo venti si e' a un terzo oppure al doppio della luminosita' di
    // partenza. Il tetto e' una cintura contro un ciclo infinito, non un limite
    // atteso.
    for (var i = 0; i < 20; i++) {
      if (contrastoFra(colore, superficie) >= soglia) return colore;
      // TUTTO IN FRAZIONI DI UNO, e non a meta' per canale.
      //
      // Qui c'era `Color.fromARGB`, che vuole gli interi da zero a 255, e i tre
      // canali di colore glieli si passava moltiplicati per 255. L'alpha no:
      // `colore.a` vale gia' 1.0, cioe' opaco pieno, e arrotondato diventava
      // **1 su 255**. Il testo veniva dipinto trasparente, e mordeva SOLO
      // AURA, perche' blu e rosso tornano prima di arrivare a questa riga.
      colore = Color.from(
        alpha: colore.a,
        red: (colore.r * passo).clamp(0.0, 1.0),
        green: (colore.g * passo).clamp(0.0, 1.0),
        blue: (colore.b * passo).clamp(0.0, 1.0),
      );
    }
    return colore;
  }

  /// Il rapporto di contrasto fra due colori, secondo le WCAG.
  static double contrastoFra(Color a, Color b) {
    final la = _luminanzaRelativa(a);
    final lb = _luminanzaRelativa(b);
    final chiaro = la > lb ? la : lb;
    final scuro = la > lb ? lb : la;
    return (chiaro + 0.05) / (scuro + 0.05);
  }

  static double _luminanzaRelativa(Color colore) {
    double canale(double v) =>
        v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
    return 0.2126 * canale(colore.r) +
        0.7152 * canale(colore.g) +
        0.0722 * canale(colore.b);
  }
}
