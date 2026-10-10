import 'dart:math' as math;

import 'package:flutter/material.dart';

/// L'ICONA DEGLI EOS, disegnata da noi. Ordine S voce 05.
///
/// **Il difetto: in barra il saldo era `Icons.auto_awesome`**, cioe' la scintilla
/// di serie di Android, con accanto un numero e nessuna parola. Nessuno capisce
/// che sono Eos, e chi ci prova legge "stelle". Quella scintilla e' anche l'icona
/// che il framework mette su mezza app, quindi il denaro del Cerchio aveva lo
/// stesso segno di un effetto speciale qualunque.
///
/// **Perche' un'alba e non una moneta.** Eos e' l'aurora: il segno e' un sole che
/// sorge sopra la linea dell'orizzonte, con tre raggi. Una moneta o un gettone
/// avrebbero detto "valuta di gioco", che e' precisamente cio' che gli Eos non
/// devono sembrare; un'alba dice l'inizio, ed e' la stessa parola che il nome
/// porta.
///
/// **Deve reggere a sedici punti**, perche' e' la misura con cui vive in barra:
/// per questo il disegno ha quattro tratti in tutto e nessun dettaglio sotto il
/// mezzo punto. Il tratto e' proporzionale alla misura, quindi a ventotto punti
/// non diventa un filo e a sedici non diventa una macchia.
///
/// **Vive in un punto solo e ogni schermata la prende da qui.** Se ne nascesse una
/// seconda, il saldo in barra e il premio nella celebrazione finirebbero per non
/// somigliarsi, ed e' il difetto che questa voce chiude.
class IconaDegliEos extends StatelessWidget {
  const IconaDegliEos({super.key, this.misura = 16, required this.colore});

  /// Il lato, in punti logici. Sedici e' la misura della barra.
  final double misura;

  final Color colore;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: misura,
        height: misura,
        child: CustomPaint(painter: _PittoreDegliEos(colore: colore)),
      );
}

class _PittoreDegliEos extends CustomPainter {
  const _PittoreDegliEos({required this.colore});

  final Color colore;

  @override
  void paint(Canvas tela, Size misura) {
    final lato = math.min(misura.width, misura.height);
    // L'orizzonte sta sotto il centro: un sole che sorge non e' un sole al
    // centro del cielo.
    final orizzonte = misura.height * 0.72;
    final centro = Offset(misura.width / 2, orizzonte);
    final raggio = lato * 0.30;

    final pieno = Paint()..color = colore;
    final tratto = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = lato * 0.085
      ..color = colore;

    // 1. IL SOLE, la meta' sopra l'orizzonte.
    tela.drawArc(Rect.fromCircle(center: centro, radius: raggio), math.pi,
        math.pi, true, pieno);

    // 2. L'ORIZZONTE, che esce dai fianchi del sole: e' la riga che dice
    // "sorge" invece di "sta".
    tela.drawLine(Offset(lato * 0.08, orizzonte),
        Offset(misura.width - lato * 0.08, orizzonte), tratto);

    // 3. I TRE RAGGI, uno in verticale e due obliqui. Tre e non cinque: a sedici
    // punti il quarto e il quinto si toccano e diventano una macchia.
    for (final angolo in const [
      -math.pi / 2,
      -math.pi / 2 - 0.85,
      -math.pi / 2 + 0.85
    ]) {
      final da = Offset(centro.dx + math.cos(angolo) * raggio * 1.35,
          centro.dy + math.sin(angolo) * raggio * 1.35);
      final a = Offset(centro.dx + math.cos(angolo) * raggio * 1.95,
          centro.dy + math.sin(angolo) * raggio * 1.95);
      tela.drawLine(da, a, tratto);
    }
  }

  @override
  bool shouldRepaint(covariant _PittoreDegliEos vecchio) =>
      vecchio.colore != colore;
}
