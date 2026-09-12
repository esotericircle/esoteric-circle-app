import 'package:flutter/material.dart';

/// L'ICONA DEL CERCHIO: una mezzaluna DENTRO un cerchio.
///
/// Chiesta dal fondatore: la voce "Il Cerchio" era una mezzaluna sola, e la
/// mezzaluna da sola dice la Luna e basta. Dentro il cerchio dice le due cose
/// insieme, la Luna e il Sole, la luce e l'oscurita', che e' quello che il
/// Cerchio e'.
///
/// **Perche' e' disegnata e non scelta.** Fra le icone di Material non esiste
/// una falce dentro un anello: `brightness_3` e' la sola falce, `circle` e' il
/// solo anello, e sovrapporle darebbe due tratti di peso diverso che a 21 punti
/// si vedono. Qui il tratto e' uno, dichiarato una volta, uguale per l'anello e
/// per la falce.
///
/// **Il peso ottico e' quello delle altre quattro.** Le icone lineari di
/// Material vivono in un riquadro di 24 con circa 2 di margine e un tratto di 2,
/// quindi qui l'anello sta in un riquadro di 24 con raggio 10 e il tratto e' 2:
/// affiancata a `badge_outlined` non e' ne' piu' grassa ne' piu' magra.
class IconaDelCerchio extends StatelessWidget {
  const IconaDelCerchio(
      {super.key, required this.colore, this.dimensione = 21});

  final Color colore;
  final double dimensione;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: dimensione,
      height: dimensione,
      // L'etichetta la porta gia' il testo sotto l'icona, quindi qui il disegno
      // e' decorativo: nominarlo di nuovo lo farebbe leggere due volte.
      child: ExcludeSemantics(
        child: CustomPaint(
          painter: _PittoreCerchio(colore: colore),
        ),
      ),
    );
  }
}

class _PittoreCerchio extends CustomPainter {
  const _PittoreCerchio({required this.colore});

  final Color colore;

  /// Il riquadro di riferimento, come le icone di Material: si disegna a 24 e si
  /// scala, cosi' le proporzioni non dipendono dalla dimensione richiesta.
  static const double _riquadro = 24;
  static const double _tratto = 2;

  @override
  void paint(Canvas canvas, Size size) {
    final scala = size.shortestSide / _riquadro;
    canvas.save();
    canvas.scale(scala);

    final penna = Paint()
      ..color = colore
      ..style = PaintingStyle.stroke
      ..strokeWidth = _tratto
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    const centro = Offset(_riquadro / 2, _riquadro / 2);

    // L'anello esterno, il Cerchio.
    canvas.drawCircle(centro, 10 - _tratto / 2, penna);

    // La falce, ricavata togliendo un disco spostato da un disco: e' il modo in
    // cui la Luna fa una falce davvero, non due archi accostati a mano.
    //
    // Il disco pieno e' spostato A DESTRA del centro, e non e' un capriccio: la
    // falce che ne esce pesa tutta dalla parte della sua schiena, quindi un
    // disco centrato darebbe una falce appoggiata al bordo sinistro con un
    // vuoto a destra. Spostando il disco, e' la FALCE a stare in mezzo
    // all'anello, che e' quello che si guarda.
    final piena = Path()
      ..addOval(Rect.fromCircle(
        center: centro + const Offset(1.4, 0),
        radius: 5.5,
      ));
    final ombra = Path()
      ..addOval(Rect.fromCircle(
        center: centro + const Offset(4.4, -1.4),
        radius: 5.4,
      ));
    final falce = Path.combine(PathOperation.difference, piena, ombra);

    // La falce e' piena: una falce in contorno a questa scala diventa due fili
    // che si toccano alle punte e a 21 punti si impastano.
    canvas.drawPath(
      falce,
      Paint()
        ..color = colore
        ..style = PaintingStyle.fill
        ..isAntiAlias = true,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(_PittoreCerchio vecchio) => vecchio.colore != colore;
}
