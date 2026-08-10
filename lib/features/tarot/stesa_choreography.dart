import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Le scene della Stesa, nell'ordine in cui vanno in onda.
///
/// La regia e' una macchina a stati sola: ogni scena sa cosa mostrare e cosa
/// permettere, e i test possono portarla in una scena precisa senza aspettare
/// il tempo reale.
enum StesaScene {
  /// Il bianco pieno con cui finisce l'intro di Mauro. Flutter parte da qui,
  /// cosi' il taglio fra video e scena viva resta coperto.
  handoff,

  /// Le carte nascono dal fondo stellato, orbitano Medora e scendono a
  /// ventaglio.
  ingresso,

  /// Il ventaglio respira e aspetta: si puo' tagliare, mischiare o scegliere.
  riposo,

  /// Il mazzo si taglia in due meta' che scorrono.
  taglio,

  /// Il vortice a spirale del mescolamento.
  mescolamento,

  /// Le tre carte sono state scelte: la scena si ferma sulla lettura.
  completa;

  /// Vero se il ventaglio accetta i gesti: taglio, mescolamento, scelta.
  bool get accettaGesti => this == StesaScene.riposo;
}

/// I tempi della regia, in un punto solo.
class StesaTiming {
  const StesaTiming._();

  /// La dissolvenza dal bianco dell'intro.
  static const Duration handoff = Duration(milliseconds: 900);

  /// Le carte che nascono dal cosmo, orbitano e scendono a ventaglio.
  static const Duration ingresso = Duration(milliseconds: 2200);

  /// Il battito del ventaglio a riposo.
  static const Duration respiro = Duration(milliseconds: 3400);

  /// Il taglio: raccolta, divisione, ricomposizione e ristesa. Millequattro-
  /// cento perche' quattro atti in settecento millisecondi erano un lampo.
  static const Duration taglio = Duration(milliseconds: 1400);

  /// Il mescolamento: raccolta, mescola e ristesa.
  static const Duration mescolamento = Duration(milliseconds: 1600);

  /// Il volo di una carta dal ventaglio al suo slot.
  static const Duration volo = Duration(milliseconds: 620);

  /// Il mezzo giro che scopre la carta.
  static const Duration flip = Duration(milliseconds: 520);
}

/// La posa di una carta del ventaglio durante l'ingresso.
///
/// L'ingresso e' una spirale: la carta nasce lontana dietro Medora, gira
/// attorno a lei stringendo il raggio e si posa nella sua sede del ventaglio.
/// La formula sta qui, non nel widget, cosi' i test la possono interrogare
/// senza montare nulla.
class SpiralPose {
  const SpiralPose({
    required this.offset,
    required this.scale,
    required this.opacity,
    required this.angle,
  });

  /// Lo scostamento dalla sede finale, in punti.
  final Offset offset;

  final double scale;
  final double opacity;

  /// L'inclinazione, in radianti.
  final double angle;

  /// La posa a riposo: nella sua sede, dritta, piena.
  static const SpiralPose atRest =
      SpiralPose(offset: Offset.zero, scale: 1, opacity: 1, angle: 0);

  /// La posa della carta [index] su [count] al tempo [t], da 0 a 1.
  ///
  /// Ogni carta parte con un ritardo suo, cosi' il gruppo si apre a ventaglio
  /// invece di muoversi come un blocco unico.
  static SpiralPose of({
    required int index,
    required int count,
    required double t,
    required Offset centro,
  }) {
    // Il ritardo distribuito: l'ultima carta parte quando la prima ha gia'
    // percorso meta' strada.
    final ritardo = count <= 1 ? 0.0 : (index / (count - 1)) * 0.45;
    final locale = ((t - ritardo) / (1 - 0.45)).clamp(0.0, 1.0);
    if (locale >= 1) return SpiralPose.atRest;

    final e = Curves.easeOutCubic.transform(locale);
    // La spirale: due giri che si stringono mentre la carta scende.
    final giri = 2 * math.pi * 2 * (1 - e);
    final raggio = (1 - e) * 220;
    return SpiralPose(
      offset: Offset(
        centro.dx + math.cos(giri) * raggio,
        centro.dy + math.sin(giri) * raggio * 0.55,
      ),
      scale: 0.25 + 0.75 * e,
      opacity: e < 0.12 ? e / 0.12 : 1.0,
      angle: giri * 0.12,
    );
  }
}

/// Il vortice del mescolamento: le carte salgono in spirale e tornano giu'.
class VortexPose {
  const VortexPose._();

  /// Lo scostamento della carta [index] su [count] al tempo [t], da 0 a 1.
  ///
  /// Sale e riscende: a meta' vortice le carte sono al culmine, alla fine sono
  /// tornate esattamente nella loro sede.
  static Offset offsetOf({
    required int index,
    required int count,
    required double t,
  }) {
    if (t <= 0 || t >= 1) return Offset.zero;
    // Una campana: zero agli estremi, massimo a meta'.
    final ampiezza = math.sin(t * math.pi);
    final fase = (index / math.max(1, count)) * 2 * math.pi + t * 4 * math.pi;
    return Offset(
      math.cos(fase) * 46 * ampiezza,
      -math.sin(fase).abs() * 70 * ampiezza,
    );
  }

  /// L'inclinazione della carta durante il vortice.
  static double angleOf({
    required int index,
    required int count,
    required double t,
  }) {
    if (t <= 0 || t >= 1) return 0;
    final ampiezza = math.sin(t * math.pi);
    return math.sin((index / math.max(1, count)) * 2 * math.pi + t * 4 * math.pi) *
        0.5 *
        ampiezza;
  }
}

/// Il taglio del mazzo: le due meta' si scostano e tornano.
class CutPose {
  const CutPose._();

  /// Di quanto scorre la meta' che contiene la carta [index], al tempo [t].
  ///
  /// La meta' alta va da una parte, quella bassa dall'altra, poi si
  /// ricompongono: e' un gesto che si legge, non un semplice riordino.
  static Offset offsetOf({
    required int index,
    required int count,
    required int taglioA,
    required double t,
  }) {
    if (t <= 0 || t >= 1) return Offset.zero;
    final ampiezza = math.sin(t * math.pi);
    final sopra = index >= taglioA;
    return Offset(sopra ? 34 * ampiezza : -34 * ampiezza,
        sopra ? -18 * ampiezza : 10 * ampiezza);
  }
}

// IL ShakeListener NON VIVE PIU' QUI. Era una delle quattro porte che
// ascoltavano lo scuotimento ognuna per conto suo, e passava al sensore il
// samplingPeriod che su un telefono senza accelerometro solleva
// un'eccezione asincrona: la porta unica e' AscoltatoreScuotimento in
// core/sensi, senza quel parametro e con l'antirimbalzo dentro.


/// LA COREOGRAFIA VERA DEL MESCOLAMENTO, approvata il 3 agosto 2026.
///
/// Tre atti dentro un solo tempo [t]: il ventaglio si RICOMPONE IN MAZZO, il
/// mazzo si MESCOLA, le carte si RISTENDONO. Prima di quest'ordine il vortice
/// girava sopra il ventaglio disteso: il mazzo cambiava davvero, ma la scena
/// raccontava un'altra cosa, e una scena che non racconta il gesto e' il
/// difetto, non un ornamento mancante.
///
/// La posa e' ASSOLUTA e non additiva: per ricomporre il mazzo serve annullare
/// lo sventagliamento, quindi la posa riceve la [sede] della carta nel
/// ventaglio e il punto del [mazzo], e decide lei dove sta la carta.
class MischiaPose {
  const MischiaPose._();

  /// I confini dei tre atti, esposti perche' i test e le anteprime possano
  /// mettersi ESATTAMENTE dentro un atto invece di indovinare il momento.
  static const double fineRaccolta = 0.30;
  static const double fineMescola = 0.70;

  static ({Offset offset, double angolo, double scala}) of({
    required Offset sede,
    required Offset mazzo,
    required int index,
    required int count,
    required double t,
    double angoloSede = 0,
  }) {
    if (t <= 0 || t >= 1) {
      return (offset: sede, angolo: angoloSede, scala: 1);
    }
    if (t < fineRaccolta) {
      // ATTO UNO: il ventaglio si ricompone in mazzo. Ogni carta scivola
      // dalla sua sede al punto del mazzo, con un filo di ritardo per indice
      // cosi' la chiusura si legge come un gesto e non come un taglio.
      final locale = (t / fineRaccolta).clamp(0.0, 1.0);
      final ritardo = count <= 1 ? 0.0 : (index / (count - 1)) * 0.25;
      final e = Curves.easeInOutCubic
          .transform(((locale - ritardo) / (1 - 0.25)).clamp(0.0, 1.0));
      return (
        offset: Offset.lerp(sede, mazzo, e)!,
        angolo: angoloSede * (1 - e),
        scala: 1,
      );
    }
    if (t < fineMescola) {
      // ATTO DUE: il mazzo si mescola. Le carte, impilate, si sfilano a
      // coppie alternate e rientrano: e' la riffle vista di lato, con lo
      // scarto che cresce e muore dentro l'atto.
      final locale = ((t - fineRaccolta) / (fineMescola - fineRaccolta))
          .clamp(0.0, 1.0);
      final ampiezza = math.sin(locale * math.pi);
      final lato = index.isEven ? 1.0 : -1.0;
      final onda = math.sin(locale * math.pi * 3 + index * 0.9);
      return (
        offset: mazzo +
            Offset(lato * 30 * ampiezza * onda.abs(), -6 * ampiezza * onda),
        angolo: lato * 0.10 * ampiezza * onda,
        scala: 1,
      );
    }
    // ATTO TRE: le carte si ristendono dal mazzo alle loro sedi nuove.
    final locale = ((t - fineMescola) / (1 - fineMescola)).clamp(0.0, 1.0);
    final ritardo = count <= 1 ? 0.0 : (index / (count - 1)) * 0.35;
    final e = Curves.easeOutCubic
        .transform(((locale - ritardo) / (1 - 0.35)).clamp(0.0, 1.0));
    return (
      offset: Offset.lerp(mazzo, sede, e)!,
      angolo: angoloSede * e,
      scala: 1,
    );
  }
}

/// LA COREOGRAFIA VERA DEL TAGLIO, approvata il 3 agosto 2026.
///
/// Quattro atti: il ventaglio si ricompone in mazzo, il mazzo si DIVIDE IN
/// DUE, il taglio si RICOMPONE con le meta' scambiate, le carte si ristendono
/// a partire dal mazzo.
class TaglioPose {
  const TaglioPose._();

  static const double fineRaccolta = 0.28;
  static const double fineDivisione = 0.52;
  static const double fineRicomposizione = 0.72;

  static ({Offset offset, double angolo, double scala}) of({
    required Offset sede,
    required Offset mazzo,
    required int index,
    required int count,
    required int taglioA,
    required double t,
    double angoloSede = 0,
  }) {
    if (t <= 0 || t >= 1) {
      return (offset: sede, angolo: angoloSede, scala: 1);
    }
    final sopra = index >= taglioA;
    if (t < fineRaccolta) {
      final locale = (t / fineRaccolta).clamp(0.0, 1.0);
      final ritardo = count <= 1 ? 0.0 : (index / (count - 1)) * 0.25;
      final e = Curves.easeInOutCubic
          .transform(((locale - ritardo) / (1 - 0.25)).clamp(0.0, 1.0));
      return (
        offset: Offset.lerp(sede, mazzo, e)!,
        angolo: angoloSede * (1 - e),
        scala: 1,
      );
    }
    if (t < fineDivisione) {
      // La meta' alta esce da una parte, la bassa dall'altra: due blocchi
      // netti, non una nuvola.
      final locale = ((t - fineRaccolta) / (fineDivisione - fineRaccolta))
          .clamp(0.0, 1.0);
      final e = Curves.easeOutCubic.transform(locale);
      return (
        offset: mazzo +
            Offset(sopra ? 64 * e : -64 * e, sopra ? -26 * e : 12 * e),
        angolo: (sopra ? 0.06 : -0.05) * e,
        scala: 1,
      );
    }
    if (t < fineRicomposizione) {
      // Il taglio si ricompone: le due meta' rientrano sul mazzo.
      final locale =
          ((t - fineDivisione) / (fineRicomposizione - fineDivisione))
              .clamp(0.0, 1.0);
      final e = 1 - Curves.easeInCubic.transform(locale);
      return (
        offset: mazzo +
            Offset(sopra ? 64 * e : -64 * e, sopra ? -26 * e : 12 * e),
        angolo: (sopra ? 0.06 : -0.05) * e,
        scala: 1,
      );
    }
    // La ristesa, dal mazzo alle sedi.
    final locale =
        ((t - fineRicomposizione) / (1 - fineRicomposizione)).clamp(0.0, 1.0);
    final ritardo = count <= 1 ? 0.0 : (index / (count - 1)) * 0.35;
    final e = Curves.easeOutCubic
        .transform(((locale - ritardo) / (1 - 0.35)).clamp(0.0, 1.0));
    return (
      offset: Offset.lerp(mazzo, sede, e)!,
      angolo: angoloSede * e,
      scala: 1,
    );
  }
}
