import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../design_system/theme/maestro_palette.dart';

/// **IL LOTO CHE RESPIRA.** Ordine CZ voce 08, 8 settembre 2026.
///
/// **Parole del fondatore**: *"Il cerchio che si gonfia esce. E' la forma di
/// ogni altra app di meditazione e non e' la nostra. Al suo posto respira il
/// fiore del Loto: i petali si aprono mentre l'utente inspira e si chiudono
/// mentre espira, in 2.5D, con l'alone che pulsa sul ritmo."*
///
/// **Il 2.5D, e cosa vuol dire qui.** Non c'e' nessuna terza dimensione vera:
/// c'e' la profondita' che il design system di questa app chiama Materico,
/// cioe' due corone di petali sfalsate, quella dietro piu' scura e piu'
/// stretta, e un'ombra che cade dal centro. Un fiore piatto e uno con questa
/// profondita' costano lo stesso e sembrano due oggetti diversi.
///
/// **La traccia, dentro il fiore.** Il centro porta le gocce dei giorni: ogni
/// sessione ne lascia una, e il petalo di un centro mai respirato resta
/// spento. E' il richiamo a tornare che non ha bisogno di nessuna notifica.
class LotoCheRespira extends StatelessWidget {
  const LotoCheRespira({
    super.key,
    required this.apertura,
    required this.palette,
    this.gocce = const [],
    this.centroDiOggi = 0,
    this.senzaMoto = false,
  });

  /// Quanto e' aperto il fiore, da 0 a 1. Viene dal respiro vero.
  final double apertura;

  final MaestroPalette palette;

  /// Le gocce per centro, una per petalo: quante volte quel centro e' stato
  /// respirato. Vuota finche' la traccia non e' stata caricata.
  final List<int> gocce;

  /// Quale petalo e' quello di oggi, per accenderlo piu' degli altri.
  final int centroDiOggi;

  /// **CON RIDUCI MOVIMENTO I PETALI NON SI ANIMANO.** Ordine CZ voce 08: la
  /// fase cambia con uno stato fermo e visibile, e la vibrazione resta.
  final bool senzaMoto;

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: _PittoreDelLoto(
          apertura: senzaMoto ? (apertura > 0.5 ? 1.0 : 0.0) : apertura,
          palette: palette,
          gocce: gocce,
          centroDiOggi: centroDiOggi,
        ),
      );
}

class _PittoreDelLoto extends CustomPainter {
  _PittoreDelLoto({
    required this.apertura,
    required this.palette,
    required this.gocce,
    required this.centroDiOggi,
  });

  final double apertura;
  final MaestroPalette palette;
  final List<int> gocce;
  final int centroDiOggi;

  /// **SETTE PETALI, uno per centro**, e non un numero scelto per estetica:
  /// il fiore deve poter mostrare quale centro e' spento, e per farlo i petali
  /// devono essere tanti quanti i centri.
  static const int quantiPetali = 7;

  @override
  void paint(Canvas canvas, Size size) {
    final centro = size.center(Offset.zero);
    final raggio = size.shortestSide / 2 * 0.92;

    // L'alone pulsa col respiro, e resta tenue quando il fiore e' chiuso.
    canvas.drawCircle(
      centro,
      raggio * (0.55 + 0.45 * apertura),
      Paint()
        ..shader = RadialGradient(colors: [
          palette.glow.withValues(alpha: 0.10 + 0.16 * apertura),
          Colors.transparent,
        ]).createShader(
            Rect.fromCircle(center: centro, radius: raggio)),
    );

    // **LA CORONA DIETRO, sfalsata di mezzo petalo.** E' meta' della
    // profondita': senza, il fiore e' una stella piatta.
    _corona(canvas, centro, raggio * 0.82,
        sfasamento: math.pi / quantiPetali,
        alpha: 0.30 + 0.20 * apertura,
        dietro: true);

    // La corona davanti, coi petali che portano la traccia.
    _corona(canvas, centro, raggio,
        sfasamento: 0, alpha: 0.55 + 0.35 * apertura, dietro: false);

    // Il cuore del fiore, che si accende col respiro.
    canvas.drawCircle(
      centro,
      raggio * (0.10 + 0.06 * apertura),
      Paint()
        ..shader = RadialGradient(colors: [
          palette.goldSoft.withValues(alpha: 0.85),
          palette.gold.withValues(alpha: 0.25),
        ]).createShader(
            Rect.fromCircle(center: centro, radius: raggio * 0.16)),
    );
  }

  void _corona(Canvas canvas, Offset centro, double raggio,
      {required double sfasamento,
      required double alpha,
      required bool dietro}) {
    for (var i = 0; i < quantiPetali; i++) {
      final angolo = sfasamento + i * 2 * math.pi / quantiPetali - math.pi / 2;

      // **QUANTO SI APRE QUESTO PETALO.** Chiuso e' raccolto sul centro,
      // aperto e' disteso: e' l'apertura del respiro, non un'animazione.
      final lungo = raggio * (0.42 + 0.58 * apertura);
      final largo = raggio * (0.14 + 0.16 * apertura);

      // **IL PETALO SPENTO E IL PETALO ACCESO.** Ordine CZ voce 10: un centro
      // mai respirato resta spento, ed e' la domanda che il fiore pone da
      // solo. Chi non ha ancora nessuna traccia vede tutti i petali uguali e
      // tenui, che e' il fiore di chi comincia oggi.
      final quante = i < gocce.length ? gocce[i] : 0;
      final acceso = quante > 0;
      final suo = i == centroDiOggi;
      var opacita = alpha * (acceso ? 1.0 : 0.34);
      if (suo) opacita = (opacita * 1.25).clamp(0.0, 1.0);

      final colore = dietro
          ? palette.deepest
          : (acceso ? palette.glow : palette.primary);

      final petalo = Path();
      final punta = Offset(centro.dx + lungo * math.cos(angolo),
          centro.dy + lungo * math.sin(angolo));
      final destra = Offset(
          centro.dx + largo * math.cos(angolo + math.pi / 2),
          centro.dy + largo * math.sin(angolo + math.pi / 2));
      final sinistra = Offset(
          centro.dx + largo * math.cos(angolo - math.pi / 2),
          centro.dy + largo * math.sin(angolo - math.pi / 2));
      petalo.moveTo(centro.dx, centro.dy);
      petalo.quadraticBezierTo(destra.dx, destra.dy, punta.dx, punta.dy);
      petalo.quadraticBezierTo(sinistra.dx, sinistra.dy, centro.dx, centro.dy);
      petalo.close();

      canvas.drawPath(
          petalo,
          Paint()
            ..style = PaintingStyle.fill
            ..color = colore.withValues(alpha: opacita));

      // Il bordo d'oro solo davanti, e solo sui petali accesi: e' cio' che
      // fa vedere a colpo d'occhio quali centri sono stati respirati.
      if (!dietro && acceso) {
        canvas.drawPath(
            petalo,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = suo ? 2.0 : 1.2
              ..color = palette.gold.withValues(alpha: 0.30 + 0.30 * apertura));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PittoreDelLoto vecchio) =>
      vecchio.apertura != apertura ||
      vecchio.centroDiOggi != centroDiOggi ||
      vecchio.gocce.length != gocce.length;
}
