import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/maestro/maestro.dart';
import 'direzione_della_festa.dart';

/// IL PITTORE DELLE TRE FESTE. Ordine U voce 02.
///
/// **Una scena per Maestro, e si riconosce dal MOVIMENTO prima che dal colore.**
/// La direzione arriva da `FesteDeiMaestri` e non si decide qui: questo file
/// sa disegnare tre direzioni, non sa quale spetta a chi.
///
/// **Le particelle non sono casuali a ogni fotogramma.** Il seme e' fisso, cosi'
/// la stessa festa si ridisegna identica: una scena che cambia a ogni montaggio
/// non si puo' provare a pixel, e non e' piu' la TUA festa.
class PittoreDellaFesta extends CustomPainter {
  PittoreDellaFesta({
    required this.maestro,
    required this.avanzamento,
    required this.oro,
    required this.oroTenue,
    required this.eGrande,
    required this.effettiPieni,
  })  : _festa = FesteDeiMaestri.di(maestro),
        _quante = FesteDeiMaestri.particelleDi(maestro, eGrande: eGrande);

  final Maestro maestro;

  /// Da zero a uno.
  final double avanzamento;

  final Color oro;
  final Color oroTenue;
  final bool eGrande;

  /// **Falso con Riduci Movimento oppure con Quality Tier basso: la festa
  /// DEGRADA, non si spegne.** Restano il velo che scopre e il movimento
  /// essenziale, cade il pieno di particelle. Spegnerla vorrebbe dire non
  /// festeggiare chi ha chiesto meno movimento.
  final bool effettiPieni;

  final FestaDelMaestro _festa;
  final int _quante;

  /// **QUANTE PARTICELLE RESTANO QUANDO SI DEGRADA:** un quinto, e non zero.
  static const double quotaDelDegrado = 0.2;

  @override
  void paint(Canvas tela, Size misura) {
    final quante = effettiPieni
        ? _quante
        : math.max(6, (_quante * quotaDelDegrado).round());
    final caso = math.Random(maestro.index * 7919 + (eGrande ? 31 : 17));
    for (var i = 0; i < quante; i++) {
      // Ogni particella parte con un suo ritardo, cosi' il fronte non e' una
      // riga netta: una festa che arriva tutta insieme e' un lampo, non un
      // movimento.
      final ritardo = caso.nextDouble() * 0.45;
      final t = ((avanzamento - ritardo) / (1 - ritardo)).clamp(0.0, 1.0);
      if (t <= 0) continue;
      _particella(tela, misura, caso, t, i);
    }
  }

  void _particella(
      Canvas tela, Size misura, math.Random caso, double t, int indice) {
    final larghezza = misura.width, altezza = misura.height;
    final quanto = caso.nextDouble();
    final laterale = caso.nextDouble();
    late Offset dove;
    switch (_festa.direzione) {
      case DirezioneDellaFesta.dalCentro:
        // **DAL CENTRO VERSO FUORI**, e il centro e' il punto in cui il
        // traguardo si e' acceso, cioe' il mezzo della scena.
        final angolo = quanto * 2 * math.pi;
        final raggio = t * math.max(larghezza, altezza) * (0.35 + laterale);
        dove = Offset(larghezza / 2 + raggio * math.cos(angolo),
            altezza / 2 + raggio * math.sin(angolo) * 0.9);
      case DirezioneDellaFesta.dallAlto:
        // **DALL'ALTO VERSO IL BASSO**, e quando la cascata finisce sotto di lei
        // restano scoperti il traguardo e il premio.
        dove = Offset(quanto * larghezza, -0.1 * altezza + t * 1.25 * altezza);
      case DirezioneDellaFesta.dalBasso:
        // **DAL BASSO VERSO L'ALTO**, e nel salire scopre cio' che sta sotto.
        // Il polline non sale dritto: ondeggia, ed e' cio' che lo distingue da
        // una pioggia girata al contrario.
        final onda = math.sin(t * math.pi * 2 + indice) * larghezza * 0.06;
        dove = Offset(quanto * larghezza + onda,
            altezza * 1.05 - t * 1.2 * altezza);
    }
    // Le particelle si spengono verso la fine della loro corsa.
    final vigore = (1 - t * t) * (effettiPieni ? 1.0 : 0.75);
    final grandezza = (eGrande ? 1.35 : 1.0) * (5 + laterale * 9);
    final colore = (indice.isEven ? oro : oroTenue)
        .withValues(alpha: (0.85 * vigore).clamp(0.0, 1.0));
    switch (_festa.materia) {
      case MateriaDellaFesta.stelle:
        _stella(tela, dove, grandezza, colore);
      case MateriaDellaFesta.numeri:
        _numero(tela, dove, grandezza, colore, indice);
      case MateriaDellaFesta.polline:
        _polline(tela, dove, grandezza, colore, t);
    }
  }

  void _stella(Canvas tela, Offset centro, double raggio, Color colore) {
    final via = Path();
    for (var p = 0; p < 10; p++) {
      final r = p.isEven ? raggio : raggio * 0.42;
      final a = -math.pi / 2 + p * math.pi / 5;
      final punto =
          Offset(centro.dx + r * math.cos(a), centro.dy + r * math.sin(a));
      p == 0 ? via.moveTo(punto.dx, punto.dy) : via.lineTo(punto.dx, punto.dy);
    }
    via.close();
    tela.drawPath(via, Paint()..color = colore);
  }

  /// **CIFRE VERE, e non scintille**: Caligo e' il Maestro dei numeri e delle
  /// rune, e una pioggia di scintille sarebbe la festa di Medora girata.
  void _numero(
      Canvas tela, Offset centro, double misura, Color colore, int indice) {
    final testo = TextPainter(
      text: TextSpan(
        text: '${indice % 10}',
        style: TextStyle(
          color: colore,
          fontSize: misura * 2.2,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    testo.paint(tela, centro - Offset(testo.width / 2, testo.height / 2));
  }

  void _polline(
      Canvas tela, Offset centro, double misura, Color colore, double t) {
    // Un petalo: due archi che si chiudono a punta, inclinato secondo la salita.
    tela.save();
    tela.translate(centro.dx, centro.dy);
    tela.rotate(t * 1.8);
    final via = Path()
      ..moveTo(0, -misura)
      ..quadraticBezierTo(misura * 0.7, 0, 0, misura)
      ..quadraticBezierTo(-misura * 0.7, 0, 0, -misura)
      ..close();
    tela.drawPath(via, Paint()..color = colore);
    tela.restore();
  }

  @override
  bool shouldRepaint(covariant PittoreDellaFesta vecchio) =>
      vecchio.avanzamento != avanzamento ||
      vecchio.maestro != maestro ||
      vecchio.eGrande != eGrande ||
      vecchio.effettiPieni != effettiPieni;
}
