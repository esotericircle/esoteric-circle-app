import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../design_system/theme/maestro_palette.dart';
import 'cinzel_ink_metrics.dart';

/// I limiti dell'inchiostro di un testo: dove cominciano e dove finiscono i
/// pixel davvero dipinti, rispetto alla linea di base.
///
/// E' la funzione unica su cui poggiano sia la misura sia la centratura sia i
/// test: se divergessero, il testo tornerebbe fuori centro senza che nessuno se
/// ne accorga.
class InkExtent {
  const InkExtent({
    required this.top,
    required this.bottom,
    this.left = 0,
    this.right = 0,
  });

  /// Sopra la linea di base, quindi negativo.
  final double top;

  /// Sotto la linea di base, quindi positivo o nullo. Vale per le code, come
  /// quella della Q di QUATTRO.
  final double bottom;

  /// Il fianco vuoto a sinistra del primo glifo, dentro il suo passo.
  final double left;

  /// Il fianco vuoto a destra dell'ultimo glifo, dentro il suo passo.
  final double right;

  double get height => bottom - top;

  /// Di quanto il centro dell'inchiostro e' spostato rispetto al centro del
  /// blocco di avanzamento: serve a centrare davvero, non per finta.
  double get offsetOrizzontale => (left - right) / 2;

  /// Il centro dell'inchiostro, rispetto alla linea di base.
  double get center => (top + bottom) / 2;

  bool get isEmpty => height <= 0;
}

/// I limiti dell'inchiostro di [testo] a corpo [fontSize].
///
/// E' l'unione dei limiti dei suoi glifi, presi dalla tavola misurata sul file
/// vero del font. Gli spazi non hanno inchiostro e non contano.
InkExtent inkExtentOf(String testo, double fontSize) {
  final glifi = testo.toUpperCase().split('');
  double? top;
  double? bottom;
  for (final ch in glifi) {
    final m = kCinzelInk[ch];
    if (m == null) continue;
    top = top == null ? m.top : math.min(top, m.top);
    bottom = bottom == null ? m.bottom : math.max(bottom, m.bottom);
  }
  if (top == null || bottom == null) {
    return const InkExtent(top: 0, bottom: 0);
  }
  // I fianchi dipendono solo dal primo e dall'ultimo glifo con inchiostro.
  final conInchiostro = glifi.where(kCinzelInk.containsKey).toList();
  final primo = kCinzelInk[conInchiostro.first]!;
  final ultimo = kCinzelInk[conInchiostro.last]!;
  return InkExtent(
    top: top * fontSize,
    bottom: bottom * fontSize,
    left: primo.left * fontSize,
    right: ultimo.right * fontSize,
  );
}

/// La larghezza del solo inchiostro di [testo], senza i fianchi vuoti che il
/// primo e l'ultimo glifo lasciano dentro il proprio passo, e senza la coda che
/// lo spazio fra le lettere aggiunge dopo l'ultima.
double larghezzaInchiostro({
  required String testo,
  required TextStyle base,
  required double fontSize,
  required double letterSpacing,
}) {
  final tp = TextPainter(
    text: TextSpan(
      text: testo,
      style: base.copyWith(fontSize: fontSize, letterSpacing: letterSpacing),
    ),
    textDirection: TextDirection.ltr,
    maxLines: 1,
  )..layout();
  final ink = inkExtentOf(testo, fontSize);
  return tp.width - letterSpacing - ink.left - ink.right;
}

/// Lo spazio fra due righe, in frazione dell'altezza della lettera.
///
/// Il respiro verso l'oro lo da' gia' il rettangolo del cartiglio: qui serve
/// solo che le due righe di un nome lungo non si tocchino fra loro.
const double kInterlinea = 0.14;

/// Quanto occupa in altezza il blocco di [righe] a questo corpo, contando
/// l'inchiostro vero e le interlinee.
///
/// Ogni riga vive in una banda uguale e il suo inchiostro vi sta centrato,
/// quindi il vuoto fra l'inchiostro di due righe vicine e' la banda meno
/// l'inchiostro. Perche' quel vuoto valga davvero [kInterlinea] volte
/// l'inchiostro, la banda deve essere l'inchiostro piu' l'interlinea.
double altezzaOccupata(List<String> righe, double fontSize) {
  if (righe.isEmpty) return 0;
  final unita = righe
      .map((r) => inkExtentOf(r, fontSize).height)
      .reduce((a, b) => math.max(a, b));
  final n = righe.length;
  return unita * n * (n > 1 ? 1 + kInterlinea : 1);
}

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

  double larghezzaA(String t, double fs) => larghezzaInchiostro(
        testo: t,
        base: base,
        fontSize: fs,
        letterSpacing: fs * _lsRatio,
      );

  // Vincolo di altezza: l'inchiostro piu' le interlinee riempie l'area utile.
  // Si misura a corpo unitario e si scala, perche' l'inchiostro cresce in modo
  // lineare col corpo.
  final unitaria = altezzaOccupata(righe, 1.0);
  var fs = unitaria > 0 ? maxHeight / unitaria : maxHeight;

  // Vincolo di larghezza: comanda la riga piu' larga.
  for (final riga in righe) {
    final unit = larghezzaA(riga, probe) / probe;
    if (unit > 0) fs = math.min(fs, maxWidth / unit);
  }

  return CartiglioAreaFit(fontSize: fs, letterSpacing: fs * _lsRatio);
}

/// Lo spostamento verticale che porta il centro dell'INCHIOSTRO al centro della
/// banda, invece del centro della riga di testo.
///
/// La riga ha sopra e sotto lo spazio di ascendenti e discendenti, che in un
/// cartiglio tutto maiuscolo resta in gran parte vuoto: senza questa correzione
/// il numero sembra spinto in alto e lo spazio sopra e sotto non e' uguale.
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
  final ink = inkExtentOf(testo, style.fontSize ?? 0);
  // Dove sta ora il centro dell'inchiostro dentro la riga, e dove lo voglio.
  final centroInchiostro = baseline + ink.center;
  return tp.height / 2 - centroInchiostro;
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
    // Due scarti da compensare per centrare l'inchiostro e non il blocco: la
    // coda che lo spazio fra le lettere lascia dopo l'ultima, e i fianchi vuoti
    // che il primo e l'ultimo glifo hanno dentro il proprio passo.
    final ink = inkExtentOf(testo, fit.fontSize);
    final dx = fit.letterSpacing / 2 + ink.offsetOrizzontale;

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

/// Un tratto dell'emblema: il suo percorso e quanto e' spesso il segno.
///
/// Lo spessore serve per sapere dove arriva davvero l'inchiostro: un percorso
/// disegnato a linea sporge di mezzo tratto oltre il suo profilo.
class _Segno {
  const _Segno(this.path, {this.spessore = 0});

  final Path path;

  /// Zero per le forme piene, la larghezza del segno per quelle a linea.
  final double spessore;

  Rect get inchiostro => path.getBounds().inflate(spessore / 2);
}

/// I tratti di un emblema, in coordinate di comodo. Non serve che stiano in un
/// riquadro preciso: ci pensa [_SuitPainter] a centrarli sul loro inchiostro.
List<_Segno> _segniDi(SuitEmblem emblem, double spessore) {
  switch (emblem) {
    case SuitEmblem.bastoni:
      // Un bastone in diagonale con un solo germoglio: a questa misura due
      // germogli si leggevano come una croce di Sant'Andrea.
      return [
        _Segno(Path()..moveTo(0.18, 0.86)..lineTo(0.82, 0.14),
            spessore: spessore),
        _Segno(Path()..moveTo(0.46, 0.54)..lineTo(0.24, 0.40),
            spessore: spessore),
      ];
    case SuitEmblem.coppe:
      // Una coppa: calice, stelo e piede.
      return [
        _Segno(Path()
          ..moveTo(0.22, 0.16)
          ..lineTo(0.78, 0.16)
          ..quadraticBezierTo(0.74, 0.58, 0.50, 0.60)
          ..quadraticBezierTo(0.26, 0.58, 0.22, 0.16)
          ..close()),
        _Segno(Path()..moveTo(0.50, 0.60)..lineTo(0.50, 0.80),
            spessore: spessore),
        _Segno(Path()..moveTo(0.30, 0.86)..lineTo(0.70, 0.86),
            spessore: spessore),
      ];
    case SuitEmblem.denari:
      // Una moneta: cerchio inciso col punto al centro.
      return [
        _Segno(Path()..addOval(Rect.fromCircle(center: const Offset(0.5, 0.5), radius: 0.40)),
            spessore: spessore),
        _Segno(Path()
          ..addOval(Rect.fromCircle(center: const Offset(0.5, 0.5), radius: 0.136))),
      ];
    case SuitEmblem.spade:
      // Una spada con la lama piena e la punta in alto: la sola linea con la
      // traversa si leggeva come una croce.
      return [
        _Segno(Path()
          ..moveTo(0.50, 0.04)
          ..lineTo(0.68, 0.34)
          ..lineTo(0.63, 0.68)
          ..lineTo(0.37, 0.68)
          ..lineTo(0.32, 0.34)
          ..close()),
        // L'elsa, corta, cosi' non prevale sulla lama.
        _Segno(Path()..moveTo(0.28, 0.72)..lineTo(0.72, 0.72),
            spessore: spessore),
      ];
  }
}

class _SuitPainter extends CustomPainter {
  _SuitPainter({required this.emblem, required this.palette});

  final SuitEmblem emblem;
  final MaestroPalette palette;

  /// Lo spessore del segno, in coordinate di comodo.
  static const double _spessore = 0.10;

  /// Il riquadro dell'inchiostro dell'emblema, in coordinate di comodo.
  ///
  /// Come per il testo, si centra e si dimensiona su questo, non sul riquadro
  /// di comodo: i tratti non riempiono mai il loro quadrato, quindi centrare il
  /// quadrato lascerebbe l'emblema fuori asse.
  static Rect inchiostroDi(SuitEmblem emblem) {
    Rect? r;
    for (final s in _segniDi(emblem, _spessore)) {
      r = r == null ? s.inchiostro : r.expandToInclude(s.inchiostro);
    }
    return r ?? const Rect.fromLTRB(0, 0, 1, 1);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final ink = inchiostroDi(emblem);
    // Porta l'inchiostro a riempire il riquadro dato, centrato nei due sensi.
    final scala = math.min(size.width / ink.width, size.height / ink.height);
    canvas.save();
    canvas.translate(
      size.width / 2 - ink.center.dx * scala,
      size.height / 2 - ink.center.dy * scala,
    );
    canvas.scale(scala);

    for (final segno in _segniDi(emblem, _spessore)) {
      final paint = Paint()..color = palette.goldSoft;
      if (segno.spessore > 0) {
        paint
          ..style = PaintingStyle.stroke
          ..strokeWidth = segno.spessore
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;
      } else {
        paint.style = PaintingStyle.fill;
      }
      canvas.drawPath(segno.path, paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SuitPainter old) =>
      old.emblem != emblem || old.palette != palette;

}
