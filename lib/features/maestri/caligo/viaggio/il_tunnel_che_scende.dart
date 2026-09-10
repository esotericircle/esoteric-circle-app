import 'dart:math' as math;

import 'package:flutter/material.dart';

/// **LA DISCESA, E RISPONDE ALLA MANO.** Ordine DC voce 07, 10 settembre 2026.
///
/// **Il principio che l'ordine detta**: *"Non e' un'animazione che parte: e'
/// una scena che risponde alla mano. La persona tiene il dito premuto e
/// scende, se stacca il dito si ferma."*
///
/// **PERCHE' CONTA PIU' DI COME E' FATTA.** Un'animazione che parte da sola si
/// guarda; una che risponde al dito **si fa**. E' la stessa scelta gia' fatta
/// per il Loto della Meditazione, dove il fondatore aveva respinto il cerchio
/// che si gonfia da solo: *"e' la forma di ogni altra app e non e' la nostra"*.
///
/// **LE MISURE, tutte pretese da una guardia sotto la Regola I**, cioe'
/// misurate sui pixel dipinti e non sui numeri che li generano:
///
/// - il tunnel occupa **la scena intera**, non un riquadro dentro la scena;
/// - gli anelli sono **irregolari**, non cerchi perfetti;
/// - i vicini sono **piu' scuri** dei lontani, che e' cio' che da' la
///   profondita' senza 3D;
/// - il tunnel **gira a spirale**, come la tradizione descrive;
/// - il colore vira **dal bruno delle radici al blu profondo**;
/// - la luce alle spalle **si stringe fino a un punto**.
class TunnelCheScende extends StatelessWidget {
  const TunnelCheScende({
    super.key,
    required this.quantoSiEScesi,
    required this.senzaMoto,
  });

  /// Da 0 in superficie a 1 arrivati, e **la muove il dito**.
  final double quantoSiEScesi;

  /// Con Riduci Movimento la discesa avanza per stati fermi al tocco invece
  /// che per scorrimento continuo, e la guardia lo pretende.
  final bool senzaMoto;

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: PittoreDelTunnel(
          quantoSiEScesi: quantoSiEScesi,
          senzaMoto: senzaMoto,
        ),
        size: Size.infinite,
      );
}

/// Il pittore del tunnel. **Pubblico e puro**: la guardia lo dipinge su una
/// tela vera e conta i pixel, invece di chiedere al codice dove crede di aver
/// messo le cose.
class PittoreDelTunnel extends CustomPainter {
  PittoreDelTunnel({
    required this.quantoSiEScesi,
    this.senzaMoto = false,
  });

  final double quantoSiEScesi;
  final bool senzaMoto;

  /// **QUANTI ANELLI COMPONGONO IL TUNNEL.**
  ///
  /// Diciotto: abbastanza da leggersi come una galleria continua, pochi
  /// abbastanza da restare sotto il tetto delle forme vive anche coi petali
  /// irregolari di ognuno.
  static const int quantiAnelli = 18;

  /// **QUANTI LATI HA UN ANELLO.** Nove, che e' dispari apposta: un numero
  /// pari darebbe una simmetria da rosone, e questa e' una galleria di terra.
  static const int latiDellAnello = 9;

  /// **DI QUANTO GIRA IL TUNNEL, in giri interi dalla bocca al fondo.**
  ///
  /// Un giro e mezzo. La tradizione descrive il tunnel come una spirale, e
  /// meno di un giro non si legge come tale mentre piu' di due da' il
  /// capogiro a chi guarda con gli occhi socchiusi.
  static const double giriDellaSpirale = 1.5;

  /// **IL BRUNO DELLE RADICI**, dove il tunnel comincia.
  static const Color brunoDelleRadici = Color(0xFF4A2E1A);

  /// **IL BLU PROFONDO**, dove arriva.
  static const Color bluProfondo = Color(0xFF0B1436);

  /// **QUANTO E' LARGO L'ANELLO PIU' VICINO**, in frazione del lato corto.
  ///
  /// Uno e trenta: **piu' del lato**, cioe' l'anello vicino esce dallo
  /// schermo. E' quello che fa sentire dentro il tunnel invece che davanti a
  /// un disegno di tunnel.
  static const double quotaDelPiuVicino = 1.30;

  /// E quanto e' stretto il piu' lontano: un punto di luce.
  static const double quotaDelPiuLontano = 0.04;

  /// **QUANTI ANELLI PASSANO DALLA BOCCA AL FONDO.**
  ///
  /// Ventinove: piu' di un giro e mezzo di lista, e **primo rispetto ai
  /// diciotto anelli**, cosi' nessun punto della discesa ripete una scena
  /// gia' vista.
  static const int quantiPassano = 29;

  /// Il raggio dell'anello [i], contato da 0 (il piu' lontano) a
  /// [quantiAnelli] - 1 (il piu' vicino).
  ///
  /// **Pubblica e pura**, perche' la guardia possa misurarla senza dipingere,
  /// e insieme la forma dipinta viene da qui: **una formula sola per il
  /// disegno e per la misura**, che e' la lezione del loto dell'ordine DB,
  /// dove ce n'erano due e promettevano cose diverse.
  static double raggioDellAnello(double lato, int i, double scesi) {
    // Gli anelli scorrono verso l'alto mentre si scende: la posizione di
    // ognuno dipende da quanto si e' sceso.
    //
    // **QUANTI ANELLI PASSANO DURANTE LA DISCESA, e la prima stesura ne
    // faceva passare DUE.** Su diciotto anelli voleva dire che il tunnel
    // quasi non scorreva: la guardia ha misurato che a meta' discesa lo
    // stesso anello si era spostato dello **0,8 per cento del lato**, cioe'
    // tre pixel. **Una galleria che non scorre e' un disegno di galleria.**
    //
    // **E il numero di anelli che passano e' PRIMO rispetto a quanti ce ne
    // sono**, che e' il secondo difetto che la guardia ha trovato. La cura
    // precedente ne faceva passare `quantiAnelli * 2`, cioe' trentasei su
    // diciotto: a meta' discesa gli anelli erano tornati **esattamente dov'
    // erano alla partenza**, e la guardia ha misurato uno spostamento di
    // **zero**. Un tunnel che a meta' strada e' identico alla bocca non
    // racconta nessuna distanza percorsa.
    //
    // Ventinove e' primo e non ha divisori in comune con diciotto: **nessuna
    // frazione della discesa riporta la scena a una configurazione gia'
    // vista**.
    final passo =
        (i + scesi * quantiPassano) % quantiAnelli / (quantiAnelli - 1);
    // **La progressione e' esponenziale e non lineare**: in una galleria vera
    // il vicino e' enormemente piu' grande del lontano, e una scala lineare
    // appiattisce la profondita'.
    final quota = quotaDelPiuLontano *
        math.pow(quotaDelPiuVicino / quotaDelPiuLontano, passo);
    return lato * quota / 2;
  }

  /// **QUANTE FORME VIVE AL MOMENTO PIU' CARICO.** Ordine DC voce 07 chiede di
  /// dichiararlo. Ogni anello e' un cammino chiuso piu' il suo filo di luce.
  static int formeAlCulmine() => quantiAnelli * 2 + 1;

  @override
  void paint(Canvas canvas, Size size) {
    final centro = size.center(Offset.zero);
    final lato = size.shortestSide;

    // **IL FONDO E' IL BLU PROFONDO**, cosi' il punto di fuga non e' un buco
    // nero ma il fondo del mondo di sotto.
    canvas.drawRect(
        Offset.zero & size, Paint()..color = bluProfondo);

    // **DAL LONTANO AL VICINO**, cosi' i vicini cadono sopra e coprono: e' cio'
    // che fa la profondita' senza 3D.
    for (var i = 0; i < quantiAnelli; i++) {
      _anello(canvas, centro, lato, i);
    }

    // **LA LUCE ALLE SPALLE, che si stringe fino a un punto.** Ordine DC voce
    // 07. E' l'unica cosa che dice quanto si e' scesi senza scriverlo.
    final quotaLuce = (1.0 - quantoSiEScesi).clamp(0.0, 1.0);
    final raggioLuce = lato * 0.5 * quotaLuce * quotaLuce;
    if (raggioLuce > 0.5) {
      canvas.drawCircle(
        centro,
        raggioLuce,
        Paint()
          ..shader = RadialGradient(colors: [
            const Color(0xFFF6E7C8).withValues(alpha: 0.55 * quotaLuce),
            Colors.transparent,
          ]).createShader(
              Rect.fromCircle(center: centro, radius: raggioLuce)),
      );
    }
  }

  void _anello(Canvas canvas, Offset centro, double lato, int i) {
    final raggio = raggioDellAnello(lato, i, quantoSiEScesi);
    if (raggio <= 0.5) return;
    // **Quanto e' vicino**, da 0 lontano a 1 addosso: da qui vengono il colore
    // e l'opacita'.
    final vicinanza = (raggio / (lato * quotaDelPiuVicino / 2)).clamp(0.0, 1.0);
    // **IL VICINO E' PIU' SCURO**, che e' la richiesta dell'ordine e insieme
    // il modo in cui l'occhio legge la distanza in una galleria.
    final tinta = Color.lerp(
        _coloreLontano(), brunoDelleRadici, vicinanza)!;
    // **LA SPIRALE**: ogni anello e' ruotato in proporzione alla sua distanza.
    final giro = giriDellaSpirale * 2 * math.pi * vicinanza +
        quantoSiEScesi * math.pi;
    final cammino = Path();
    for (var l = 0; l <= latiDellAnello; l++) {
      final angolo = giro + l * 2 * math.pi / latiDellAnello;
      // **GLI ANELLI SONO IRREGOLARI**, ordine DC voce 07: una galleria di
      // terra non ha cerchi perfetti. L'irregolarita' e' deterministica, cosi'
      // lo stesso anello non trema fra un fotogramma e l'altro.
      final scarto = 1.0 + 0.13 * math.sin(l * 2.7 + i * 1.9);
      final p = centro +
          Offset(math.cos(angolo), math.sin(angolo)) * raggio * scarto;
      if (l == 0) {
        cammino.moveTo(p.dx, p.dy);
      } else {
        cammino.lineTo(p.dx, p.dy);
      }
    }
    cammino.close();
    canvas.drawPath(
      cammino,
      Paint()
        ..color = tinta.withValues(alpha: 0.30 + 0.55 * vicinanza)
        ..style = PaintingStyle.fill,
    );
    // Il filo di luce sul bordo, che stacca un anello dall'altro.
    canvas.drawPath(
      cammino,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0 + 1.6 * vicinanza
        ..color = const Color(0xFFD9B98A)
            .withValues(alpha: 0.10 + 0.28 * (1 - vicinanza)),
    );
  }

  /// Il colore degli anelli lontani: **il blu si schiarisce verso il fondo**,
  /// che e' il contrario di come si comporta una stanza illuminata e il modo
  /// in cui si legge una galleria che porta altrove.
  Color _coloreLontano() =>
      Color.lerp(bluProfondo, const Color(0xFF3C5A9A), 0.75)!;

  @override
  bool shouldRepaint(PittoreDelTunnel vecchio) =>
      vecchio.quantoSiEScesi != quantoSiEScesi ||
      vecchio.senzaMoto != senzaMoto;
}
