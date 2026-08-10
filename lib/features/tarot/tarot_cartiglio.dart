import 'dart:math' as math;

import 'package:flutter/material.dart';

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

/// L'altezza dell'inchiostro della riga piu' alta, a questo corpo.
double unitaInchiostro(List<String> righe, double fontSize) => righe.isEmpty
    ? 0
    : righe
        .map((r) => inkExtentOf(r, fontSize).height)
        .reduce((a, b) => math.max(a, b));

/// Quanto occupa in altezza il blocco di [righe] a questo corpo: l'inchiostro
/// delle righe piu' le interlinee che stanno FRA loro.
///
/// Le interlinee sono una in meno delle righe. La formula precedente contava
/// un'interlinea per riga, quindi ne metteva mezza anche sopra la prima e sotto
/// l'ultima: il blocco risultava piu' alto del vero e il testo su due righe si
/// fermava prima di riempire la placca.
double altezzaOccupata(List<String> righe, double fontSize) {
  if (righe.isEmpty) return 0;
  final unita = unitaInchiostro(righe, fontSize);
  final n = righe.length;
  return unita * n + unita * kInterlinea * (n - 1);
}

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
    // IL RAMO IN CUI NON C'E' NIENTE DA SCRIVERE, e la misura che restituisce
    // e' una misura di CARATTERE, non un fattore di scala: finisce dritta nel
    // `fontSize` di un TextStyle vero, poche righe piu' sotto. Il numero uno
    // era percio' una misura sotto il pavimento dell'app, anche se nessuno la
    // vedeva mai a video, perche' ci si arriva solo quando le righe sono vuote
    // o l'area e' nulla, cioe' quando non c'e' testo da disegnare.
    //
    // Resta zero, e non il pavimento: a un carattere che non esiste non si da'
    // una misura leggibile, gli si da' NIENTE. Dodici punti qui vorrebbero dire
    // riservare l'altezza di una riga a un cartiglio vuoto.
    return const CartiglioAreaFit(fontSize: 0, letterSpacing: 0);
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
