import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../design_system/theme/maestro_palette.dart';

/// Quanto e' alta una maiuscola del Cinzel rispetto alla dimensione del font.
///
/// Misurata sul file reale `assets/fonts/Cinzel-variable.ttf`: a corpo 200 la X
/// va da 56 a 196, quindi 140 su 200. Serve perche' la riga di testo e' molto
/// piu' alta della lettera (ci stanno dentro anche ascendenti e discendenti che
/// qui non si usano mai): dimensionando sulla riga il testo galleggiava piccolo
/// dentro il cartiglio, dimensionando sulla lettera lo riempie davvero.
const double kCapRatio = 0.70;

/// Lo spazio fra due righe, in frazione dell'altezza della lettera.
///
/// Il respiro verso l'oro lo da' gia' il rettangolo del cartiglio: qui serve
/// solo che le due righe di un nome lungo non si tocchino fra loro.
const double kInterlinea = 0.14;

/// Quanto occupa in altezza un testo di [righe] righe a questo corpo.
///
/// Ogni riga vive in una banda uguale e la lettera vi sta centrata, quindi il
/// vuoto fra due lettere vicine e' la banda meno la lettera. Perche' quel vuoto
/// valga davvero [kInterlinea] volte la lettera, la banda deve essere la
/// lettera piu' l'interlinea: da qui il fattore.
double altezzaOccupata(double fontSize, int righe) =>
    fontSize * kCapRatio * righe * (righe > 1 ? 1 + kInterlinea : 1);

/// L'emblema del seme e' una forma piena, non una lettera: un filo di respiro
/// dentro la banda gli serve.
const double _riempimentoEmblema = 0.88;

/// Rapporto fra spazio tra le lettere e dimensione del font, cosi' la misura
/// scala insieme al testo e la larghezza resta lineare nel font.
const double _lsRatio = 0.025;

/// La misura scelta per il testo di un cartiglio.
class CartiglioAreaFit {
  const CartiglioAreaFit({required this.fontSize, required this.letterSpacing});

  final double fontSize;
  final double letterSpacing;
}

/// La dimensione piu' grande possibile per cui tutte le [righe] stanno dentro
/// l'area utile del cartiglio, sia in larghezza sia in altezza.
///
/// In altezza ci stanno le lettere di tutte le righe piu' le interlinee fra
/// esse. La larghezza la comanda la riga piu' larga. Vince il vincolo piu'
/// stretto dei due, cosi' il testo riempie il cartiglio senza mai uscirne.
CartiglioAreaFit resolveCartiglioArea({
  required List<String> righe,
  required TextStyle base,
  required double maxWidth,
  required double maxHeight,
}) {
  if (righe.isEmpty || maxWidth <= 0 || maxHeight <= 0) {
    return const CartiglioAreaFit(fontSize: 1, letterSpacing: 0);
  }
  const probe = 100.0;

  double larghezzaA(String t, double fs) {
    final tp = TextPainter(
      text: TextSpan(
        text: t,
        style: base.copyWith(fontSize: fs, letterSpacing: fs * _lsRatio),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    return tp.width;
  }

  // Vincolo di altezza: le lettere piu' le interlinee riempiono l'area utile.
  final n = righe.length;
  var fs = maxHeight / (kCapRatio * n * (n > 1 ? 1 + kInterlinea : 1));

  // Vincolo di larghezza: comanda la riga piu' larga.
  for (final riga in righe) {
    final unit = larghezzaA(riga, probe) / probe;
    if (unit > 0) fs = math.min(fs, maxWidth / unit);
  }

  return CartiglioAreaFit(fontSize: fs, letterSpacing: fs * _lsRatio);
}

/// Lo spostamento verticale che porta il centro della lettera al centro della
/// banda, invece del centro della riga di testo.
///
/// La riga ha sopra la lettera lo spazio degli ascendenti e sotto quello dei
/// discendenti, che in un cartiglio tutto maiuscolo restano vuoti: senza questa
/// correzione il numero sembra spinto in alto.
double offsetOtticoVerticale({
  required String testo,
  required TextStyle style,
  required double bandaHeight,
}) {
  final tp = TextPainter(
    text: TextSpan(text: testo, style: style),
    textDirection: TextDirection.ltr,
    maxLines: 1,
  )..layout();
  final baseline = tp.computeDistanceToActualBaseline(TextBaseline.alphabetic);
  final cap = (style.fontSize ?? 0) * kCapRatio;
  // Dove sta ora il centro della lettera dentro la riga, e dove lo voglio.
  final centroLettera = baseline - cap / 2;
  final centroRiga = tp.height / 2;
  final scartoNellaRiga = centroRiga - centroLettera;
  // La riga e' gia' centrata nella banda: resta da togliere solo lo scarto.
  return scartoNellaRiga;
}

/// Una riga di cartiglio, alla misura data, centrata in orizzontale e centrata
/// otticamente in verticale dentro la sua banda.
class CartiglioRiga extends StatelessWidget {
  const CartiglioRiga({
    super.key,
    required this.testo,
    required this.fit,
    required this.base,
    required this.bandaHeight,
  });

  final String testo;
  final CartiglioAreaFit fit;
  final TextStyle base;
  final double bandaHeight;

  @override
  Widget build(BuildContext context) {
    final style = base.copyWith(
      fontSize: fit.fontSize,
      letterSpacing: fit.letterSpacing,
    );
    final dy = offsetOtticoVerticale(
      testo: testo,
      style: style,
      bandaHeight: bandaHeight,
    );
    // Il letter-spacing lascia una coda dopo l'ultima lettera: mezzo passo di
    // rientro e il testo torna centrato davvero.
    final dx = fit.letterSpacing / 2;

    return SizedBox(
      height: bandaHeight,
      child: Center(
        child: OverflowBox(
          minWidth: 0,
          maxWidth: double.infinity,
          minHeight: 0,
          maxHeight: double.infinity,
          alignment: Alignment.center,
          child: Transform.translate(
            offset: Offset(dx, dy),
            child: Text(
              testo,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.visible,
              textAlign: TextAlign.center,
              style: style,
            ),
          ),
        ),
      ),
    );
  }
}

/// L'emblema del seme, inciso in oro, per il cartiglio superiore delle carte di
/// corte.
///
/// Fante, Cavaliere, Regina e Re sono parole troppo lunghe per quella placca
/// stretta: ridotte per entrarci diventavano illeggibili. Il simbolo del seme si
/// legge a colpo d'occhio ed e' la lettura tradizionale del mazzo. Il grado per
/// esteso resta nel cartiglio inferiore e nel nome grande sotto la carta.
enum SuitEmblem { bastoni, coppe, denari, spade }

class SuitEmblemMark extends StatelessWidget {
  const SuitEmblemMark({
    super.key,
    required this.emblem,
    required this.palette,
  });

  final SuitEmblem emblem;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Quadrato, alto quanto la banda, cosi' resta centrato nella placca.
        final lato = math.min(constraints.maxWidth, constraints.maxHeight) *
            _riempimentoEmblema;
        return Center(
          child: SizedBox(
            width: lato,
            height: lato,
            child: CustomPaint(
              painter: _SuitPainter(emblem: emblem, palette: palette),
            ),
          ),
        );
      },
    );
  }
}

class _SuitPainter extends CustomPainter {
  _SuitPainter({required this.emblem, required this.palette});

  final SuitEmblem emblem;
  final MaestroPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final oro = Paint()
      ..color = palette.goldSoft
      ..style = PaintingStyle.fill;
    final tratto = Paint()
      ..color = palette.goldSoft
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(0.7, w * 0.10)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    switch (emblem) {
      case SuitEmblem.bastoni:
        // Un bastone in diagonale con un solo germoglio: a questa misura due
        // germogli si leggevano come una croce di Sant'Andrea.
        canvas.drawLine(
            Offset(w * 0.18, h * 0.86), Offset(w * 0.82, h * 0.14), tratto);
        canvas.drawLine(
            Offset(w * 0.46, h * 0.54), Offset(w * 0.24, h * 0.40), tratto);
      case SuitEmblem.coppe:
        // Una coppa: calice, stelo e piede.
        final calice = Path()
          ..moveTo(w * 0.22, h * 0.16)
          ..lineTo(w * 0.78, h * 0.16)
          ..quadraticBezierTo(w * 0.74, h * 0.58, w * 0.50, h * 0.60)
          ..quadraticBezierTo(w * 0.26, h * 0.58, w * 0.22, h * 0.16)
          ..close();
        canvas.drawPath(calice, oro);
        canvas.drawLine(
            Offset(w * 0.50, h * 0.60), Offset(w * 0.50, h * 0.80), tratto);
        canvas.drawLine(
            Offset(w * 0.30, h * 0.86), Offset(w * 0.70, h * 0.86), tratto);
      case SuitEmblem.denari:
        // Una moneta: cerchio inciso con pentacolo appena accennato.
        final r = math.min(w, h) * 0.40;
        final c = Offset(w / 2, h / 2);
        canvas.drawCircle(c, r, tratto);
        canvas.drawCircle(c, r * 0.34, oro);
      case SuitEmblem.spade:
        // Una spada con la lama piena e la punta in alto: la sola linea con la
        // traversa si leggeva come una croce.
        final lama = Path()
          ..moveTo(w * 0.50, h * 0.04)
          ..lineTo(w * 0.68, h * 0.34)
          ..lineTo(w * 0.63, h * 0.68)
          ..lineTo(w * 0.37, h * 0.68)
          ..lineTo(w * 0.32, h * 0.34)
          ..close();
        canvas.drawPath(lama, oro);
        // L'elsa, corta, cosi' non prevale sulla lama.
        canvas.drawLine(
            Offset(w * 0.28, h * 0.72), Offset(w * 0.72, h * 0.72), tratto);
    }
  }

  @override
  bool shouldRepaint(_SuitPainter old) =>
      old.emblem != emblem || old.palette != palette;
}
