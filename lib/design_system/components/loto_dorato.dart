import 'package:flutter/material.dart';

import '../tokens/color_tokens.dart';

/// IL LOTO CHE ASPETTA DI APRIRSI, disegnato e non caricato.
///
/// **Perche' disegnato.** Come immagine non esiste: cercato in `assets/` e in
/// `brand_assets/` il 6 agosto 2026, nessun file con "lot", "loto" o "lotus".
/// Invece di rimandare la scena a quando l'arte ci sara', il fiore si traccia
/// con qualche curva, che e' poco codice e non aspetta nessuno.
///
/// **E' UN RIPIEGO, e lo dichiara.** Accanto agli altri simboli, che sono arte
/// Total Metal incisa, un loto vettoriale in oro piatto **si vedra' che e'
/// un'altra cosa**. E' una scelta presa sapendolo: meglio un fiore semplice e
/// onesto che un quadrato vuoto, e meglio ancora un'arte vera il giorno in cui
/// arrivera'. Quando quel file esistera', questo widget va sostituito da un
/// `Image.asset` e cancellato.
///
/// **Non e' uno dei dodici archetipi.** E' la ragione per cui puo' stare dove
/// sta: non dichiara alla persona un archetipo che non ha, dice che c'e'
/// qualcosa che deve ancora nascere.
class LotoDorato extends StatelessWidget {
  const LotoDorato({super.key, required this.lato, this.colore});

  /// Il lato del quadrato in cui il fiore si iscrive, lo stesso degli altri
  /// simboli, cosi' entra nello stesso ritaglio che scende dall'alto.
  final double lato;

  /// L'oro. Di difetto quello del progetto.
  final Color? colore;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: lato,
        height: lato,
        child: CustomPaint(
          painter: _PittoreDelLoto(colore ?? ColorTokens.gold),
          // L'etichetta serve a chi non vede: il fiore non e' decorazione, e'
          // l'unica cosa a schermo che dice cosa manca.
          child: const SizedBox.expand(),
        ),
      );
}

class _PittoreDelLoto extends CustomPainter {
  const _PittoreDelLoto(this.oro);

  final Color oro;

  /// Quanti petali. Sette e' il numero delle raffigurazioni piu' comuni del
  /// loto, e in dispari il fiore resta simmetrico attorno al petalo centrale.
  static const int petali = 7;

  @override
  void paint(Canvas canvas, Size size) {
    final l = size.shortestSide;
    final base = Offset(size.width / 2, size.height * 0.80);
    final tratto = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = l * 0.018
      ..strokeCap = StrokeCap.round
      ..color = oro;
    final velo = Paint()
      ..style = PaintingStyle.fill
      ..color = oro.withValues(alpha: 0.14);

    // I petali si aprono a ventaglio dal centro della base. Quello centrale sta
    // dritto, gli altri si inclinano a coppie: cosi' il fiore resta simmetrico
    // e chiuso, non spalancato. Un loto spalancato direbbe "sei arrivato",
    // mentre qui la cosa deve ancora succedere.
    for (var i = 0; i < petali; i++) {
      final passo = i - (petali - 1) / 2;
      final inclinazione = passo * 0.34; // radianti
      // I petali esterni sono piu' corti, come in un fiore vero.
      final altezza = l * (0.52 - 0.055 * passo.abs());
      final larghezza = l * (0.15 - 0.011 * passo.abs());

      final petalo = Path();
      petalo.moveTo(0, 0);
      petalo.quadraticBezierTo(larghezza, -altezza * 0.55, 0, -altezza);
      petalo.quadraticBezierTo(-larghezza, -altezza * 0.55, 0, 0);

      canvas.save();
      canvas.translate(base.dx, base.dy);
      canvas.rotate(inclinazione);
      canvas.drawPath(petalo, velo);
      canvas.drawPath(petalo, tratto);
      canvas.restore();
    }

    // La riga d'acqua sotto: due tratti corti, appena accennati. Senza, il
    // fiore galleggia nel vuoto e sembra caduto invece che nato.
    final acqua = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = l * 0.014
      ..strokeCap = StrokeCap.round
      ..color = oro.withValues(alpha: 0.55);
    canvas.drawLine(
      Offset(base.dx - l * 0.30, base.dy + l * 0.045),
      Offset(base.dx - l * 0.06, base.dy + l * 0.045),
      acqua,
    );
    canvas.drawLine(
      Offset(base.dx + l * 0.06, base.dy + l * 0.045),
      Offset(base.dx + l * 0.30, base.dy + l * 0.045),
      acqua,
    );

    // Il bocciolo al centro, piccolo: il cuore che non si e' ancora aperto.
    canvas.drawCircle(
      Offset(base.dx, base.dy - l * 0.50),
      l * 0.030,
      Paint()..color = oro.withValues(alpha: 0.85),
    );
  }

  @override
  bool shouldRepaint(covariant _PittoreDelLoto vecchio) => vecchio.oro != oro;
}
