import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/sigilli/sentieri.dart';

/// IL SEGNO DEI TRE SENTIERI, DISEGNATO DA NOI. Ordine AQ voce 02.
///
/// **Perche' non sono piu' icone.** Fino alla 2184 la celebrazione mostrava
/// tre glifi di Material: `star_rounded` per la Costellazione, `spa_rounded`
/// per l'Albero e `local_florist_rounded` per il Loto. Il primo problema e'
/// la regola di casa, nessuna forma di sistema in una scena che la persona
/// guarda. Il secondo e' peggio: **`spa_rounded` E' un fiore di loto**,
/// quindi due sentieri su tre mostravano alla persona lo stesso fiore, ed e'
/// una delle ragioni per cui a Mauro le feste sembravano tutte uguali.
///
/// **Come sono fatti, e perche' cosi'.** Tre forme che si riconoscono da
/// lontano e a occhio nudo, tracciate con la stessa mano: linee sottili in
/// oro su fondo scuro, nessun riempimento pieno, nessuna ombra.
/// La Costellazione e' una stella a sei raggi con tre compagne minori
/// attorno; l'Albero e' un tronco che si divide in tre rami che salgono; il
/// Loto e' una corolla di cinque petali che si apre da un punto.
/// **Sono provvisorie e lo dicono**: nascono dal codice e non dagli asset di
/// brand, e il giorno che l'arte definitiva arrivera' basta cambiare qui.
class SegnoDelSentiero extends StatelessWidget {
  const SegnoDelSentiero({
    super.key,
    required this.sentiero,
    required this.colore,
    this.misura = 32,
    this.avanzamento = 1,
  });

  final Sentiero sentiero;
  final Color colore;
  final double misura;

  /// Da zero a uno: il segno si traccia, non compare tutto insieme.
  final double avanzamento;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      key: Key('segno_disegnato_${sentiero.name}'),
      size: Size.square(misura),
      painter: _PittoreDelSegno(
        sentiero: sentiero,
        colore: colore,
        avanzamento: avanzamento.clamp(0.0, 1.0),
      ),
    );
  }
}

class _PittoreDelSegno extends CustomPainter {
  _PittoreDelSegno({
    required this.sentiero,
    required this.colore,
    required this.avanzamento,
  });

  final Sentiero sentiero;
  final Color colore;
  final double avanzamento;

  @override
  void paint(Canvas tela, Size size) {
    final lato = math.min(size.width, size.height);
    // Il tratto segue la misura: lo stesso segno a 32 e a 96 punti deve
    // pesare uguale all'occhio, non avere lo stesso spessore in pixel.
    final penna = Paint()
      ..color = colore.withValues(alpha: avanzamento)
      ..style = PaintingStyle.stroke
      ..strokeWidth = lato * 0.055
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final centro = Offset(size.width / 2, size.height / 2);
    switch (sentiero) {
      case Sentiero.costellazione:
        _stella(tela, penna, centro, lato);
      case Sentiero.albero:
        _albero(tela, penna, centro, lato);
      case Sentiero.loto:
        _loto(tela, penna, centro, lato);
    }
  }

  /// LA COSTELLAZIONE: una stella a sei raggi, con tre compagne minori.
  void _stella(Canvas tela, Paint penna, Offset centro, double lato) {
    final raggio = lato * 0.32 * avanzamento;
    for (var i = 0; i < 6; i++) {
      final angolo = i * math.pi / 3;
      // I raggi lunghi e quelli corti si alternano: una stella tutta uguale
      // sembra una ruota.
      final quanto = i.isEven ? raggio : raggio * 0.55;
      tela.drawLine(
        centro,
        centro + Offset(math.cos(angolo) * quanto, math.sin(angolo) * quanto),
        penna,
      );
    }
    final piccole = Paint()
      ..color = penna.color
      ..style = PaintingStyle.fill;
    for (final punto in const [
      Offset(0.78, 0.22),
      Offset(0.24, 0.30),
      Offset(0.70, 0.76),
    ]) {
      tela.drawCircle(
        Offset(punto.dx * lato, punto.dy * lato),
        lato * 0.028 * avanzamento,
        piccole,
      );
    }
  }

  /// L'ALBERO: un tronco che si divide in tre rami che salgono.
  void _albero(Canvas tela, Paint penna, Offset centro, double lato) {
    final base = Offset(centro.dx, lato * 0.86);
    final biforcazione = Offset(centro.dx, lato * 0.52);
    final quanto = avanzamento;
    tela.drawLine(
      base,
      Offset.lerp(base, biforcazione, quanto)!,
      penna,
    );
    if (quanto < 0.35) return;
    final t = ((quanto - 0.35) / 0.65).clamp(0.0, 1.0);
    for (final ramo in const [
      Offset(-0.26, -0.28),
      Offset(0, -0.36),
      Offset(0.26, -0.28),
    ]) {
      final fine = biforcazione + Offset(ramo.dx * lato, ramo.dy * lato);
      tela.drawLine(biforcazione, Offset.lerp(biforcazione, fine, t)!, penna);
    }
    // Le tre gemme in punta: il segno che l'albero e' vivo.
    if (t < 0.8) return;
    final gemma = Paint()
      ..color = penna.color
      ..style = PaintingStyle.fill;
    for (final ramo in const [
      Offset(-0.26, -0.28),
      Offset(0, -0.36),
      Offset(0.26, -0.28),
    ]) {
      tela.drawCircle(
        biforcazione + Offset(ramo.dx * lato, ramo.dy * lato),
        lato * 0.03,
        gemma,
      );
    }
  }

  /// IL LOTO: cinque petali che si aprono da un punto.
  void _loto(Canvas tela, Paint penna, Offset centro, double lato) {
    final base = Offset(centro.dx, lato * 0.74);
    const quanti = 5;
    for (var i = 0; i < quanti; i++) {
      // I petali si aprono a ventaglio, dal centro verso l'esterno.
      final apertura = (i - (quanti - 1) / 2) * 0.42;
      final altezza = lato * (0.40 - apertura.abs() * 0.07) * avanzamento;
      final punta = base +
          Offset(math.sin(apertura) * altezza * 1.15,
              -math.cos(apertura) * altezza);
      final petalo = Path()
        ..moveTo(base.dx, base.dy)
        ..quadraticBezierTo(
          base.dx + math.sin(apertura - 0.35) * altezza,
          base.dy - math.cos(apertura) * altezza * 0.62,
          punta.dx,
          punta.dy,
        )
        ..quadraticBezierTo(
          base.dx + math.sin(apertura + 0.35) * altezza,
          base.dy - math.cos(apertura) * altezza * 0.62,
          base.dx,
          base.dy,
        );
      tela.drawPath(petalo, penna);
    }
  }

  @override
  bool shouldRepaint(_PittoreDelSegno vecchio) =>
      vecchio.avanzamento != avanzamento ||
      vecchio.sentiero != sentiero ||
      vecchio.colore != colore;
}
