import 'package:flutter/material.dart';

import '../../../design_system/tokens/color_tokens.dart';

/// **LA CORNICE DELLA FINESTRA DEL VOLTO.** Ordine EN voce 03, 25 settembre
/// 2026.
///
/// Il fondatore: *"i maestri stanno all'interno di una finestra a cupola con
/// contorno dorato semplice, è minimal ma troppo semplice, vorrei qualcosa di
/// elegante Senza esagerare e sempre dorato."*
///
/// **La forma non cambia**: arco in alto, bordo basso dritto sul taglio del
/// busto, la fascia d'oro della finestra in `schermata_live.dart`. Cambia cio' che le sta
/// attorno, e sono i gesti di una cornice d'altare, non di una cornice
/// barocca:
///
/// - un **filo d'oro esterno**, sottile, staccato dalla fascia di
///   [distanzaDelFilo] punti: la fascia sola e' un contorno, due linee
///   parallele sono una cornice;
/// - un **filetto interno** chiaro, appena dentro il volto, che fa da
///   battuta come in una tela incorniciata;
/// - la **chiave di volta** in cima all'arco, una losanga d'oro;
/// - il **davanzale** sotto il busto, una riga d'oro con due borchie che
///   escono appena dai fianchi.
///
/// **Tutto d'oro e tutto uguale per i tre Maestri**: il colore del Maestro
/// resta nell'alone e nel fondo, la cornice e' della casa.
class LaCorniceDellaFinestra extends CustomPainter {
  const LaCorniceDellaFinestra(
      {required this.fascia, required this.raggioBasso});

  /// Lo spessore della fascia d'oro della finestra.
  final double fascia;

  /// Il raggio degli angoli bassi della finestra.
  final double raggioBasso;

  /// Quanto il filo esterno sta fuori dalla fascia.
  static const double distanzaDelFilo = 5;

  /// Quanto il filetto interno sta dentro la fascia.
  static const double distanzaDelFiletto = 3;

  /// Mezza larghezza e mezza altezza della chiave di volta.
  static const Size chiave = Size(7, 10);

  /// Quanto il davanzale esce dai fianchi della finestra.
  static const double sporgenzaDelDavanzale = 10;

  /// L'arco della finestra allargato di [d] punti, o ristretto se negativo:
  /// in alto un semicerchio pieno, in basso gli angoli appena smussati.
  static Path arco(Rect finestra, double d, double raggioBasso) {
    final r = finestra.inflate(d);
    final alto = Radius.circular(r.width / 2);
    final basso = Radius.circular((raggioBasso + d).clamp(0, 40).toDouble());
    return Path()
      ..addRRect(RRect.fromRectAndCorners(r,
          topLeft: alto,
          topRight: alto,
          bottomLeft: basso,
          bottomRight: basso));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final finestra = Offset.zero & size;
    final oro = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        ColorTokens.goldBright,
        ColorTokens.gold,
        ColorTokens.goldDeep,
        ColorTokens.gold,
      ],
    ).createShader(finestra.inflate(sporgenzaDelDavanzale + 4));

    // Il filo esterno.
    canvas.drawPath(
      arco(finestra, distanzaDelFilo, raggioBasso),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..shader = oro,
    );

    // Il filetto interno, sul volto: chiaro e sottile, una battuta.
    canvas.drawPath(
      arco(finestra, -(fascia + distanzaDelFiletto), raggioBasso),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = ColorTokens.goldLight.withValues(alpha: 0.55),
    );

    // La chiave di volta, a cavallo della fascia in cima all'arco.
    final cima = Offset(finestra.center.dx, finestra.top + fascia / 2);
    final losanga = Path()
      ..moveTo(cima.dx, cima.dy - chiave.height)
      ..lineTo(cima.dx + chiave.width, cima.dy)
      ..lineTo(cima.dx, cima.dy + chiave.height)
      ..lineTo(cima.dx - chiave.width, cima.dy)
      ..close();
    canvas.drawPath(losanga, Paint()..shader = oro);
    canvas.drawPath(
      losanga,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = ColorTokens.goldDeep,
    );
    canvas.drawCircle(cima, 1.6, Paint()..color = ColorTokens.goldBright);

    // Il davanzale sotto il busto, con le sue due borchie.
    final y = finestra.bottom + distanzaDelFilo;
    final sinistra = finestra.left - sporgenzaDelDavanzale;
    final destra = finestra.right + sporgenzaDelDavanzale;
    canvas.drawLine(
      Offset(sinistra, y),
      Offset(destra, y),
      Paint()
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round
        ..shader = oro,
    );
    for (final x in [sinistra, destra]) {
      canvas.drawCircle(Offset(x, y), 2.6, Paint()..shader = oro);
    }
  }

  @override
  bool shouldRepaint(LaCorniceDellaFinestra vecchia) =>
      vecchia.fascia != fascia || vecchia.raggioBasso != raggioBasso;
}
