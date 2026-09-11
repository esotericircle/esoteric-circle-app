import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../../core/rituals/animal_catalog.dart';
import '../../../../core/viaggio/i_quattro_viaggi.dart';

/// **LE QUATTRO IMPRONTE CHE FORMANO UN CAMMINO.**
/// Ordine DE voce 09, 11 settembre 2026.
///
/// **CHE COSA C'ERA PRIMA, sotto la Regola D.** Quattro trattini d'oro larghi
/// trentaquattro punti e alti quattro, in fila e tutti uguali, accesi quanti
/// erano i viaggi fatti. Funzionavano: dicevano a che punto si e'. Ma erano
/// **una barra di avanzamento**, cioe' la cosa che l'ordine DC voce 04 aveva
/// gia' vietato al Passaporto, e non dicevano niente di **chi** aveva lasciato
/// quel segno.
///
/// **L'ORDINE CHIEDE DUE COSE, e la seconda e' quella difficile.**
///
/// *"Le quattro non stanno in fila per caso: compongono un percorso che alla
/// quarta porta esattamente dove l'animale aspetta."* Quindi non una riga:
/// **un cammino**, che sale da sinistra in basso verso destra in alto, dove al
/// quarto passo c'e' qualcuno.
///
/// *"Le impronte sono quelle del suo animale, non generiche, e si ricavano
/// dalla stessa immagine."* E qui c'e' il problema vero: **prima della quarta
/// discesa il suo animale non si sa ancora**. La cura non e' inventarne uno:
/// **ogni impronta e' la sagoma dell'ombra che si e' seguita QUELLA volta**,
/// presa dal canale alpha di quella illustrazione. Chi ha seguito il lupo tre
/// volte vede tre impronte di lupo; chi ha cambiato idea vede il proprio
/// cambio di idea disegnato.
///
/// **E alla quarta il cammino si chiude su se stesso**: l'animale che le
/// quattro scelte hanno scelto e' quello che ha lasciato piu' impronte, quindi
/// **chi guarda indietro dopo la rivelazione vede che il cammino c'era gia'
/// dal primo giorno**, che e' esattamente la riga dell'ordine.
class LeQuattroImpronte extends StatelessWidget {
  const LeQuattroImpronte({
    super.key,
    required this.seguiti,
    required this.riconosciuto,
  });

  /// I nomi seguiti a ogni discesa, in ordine di tempo. Puo' essere piu' corta
  /// di quattro: quelle che mancano sono il cammino che resta da fare.
  final List<String> seguiti;

  /// Se il nome e' gia' stato detto: allora l'ultima impronta e' l'animale, e
  /// non un passo.
  final bool riconosciuto;

  /// **QUANTO E' ALTO IL CAMMINO**, in punti.
  ///
  /// Settantadue: sotto, la curva si appiattisce e torna a leggersi come una
  /// fila; sopra, ruba alla soglia lo spazio della promessa.
  static const double altezza = 72;

  /// **DOVE CADE OGNI IMPRONTA**, in frazione della larghezza e dell'altezza.
  ///
  /// **Non sono equidistanti e non stanno sulla stessa quota**, e nessuna
  /// delle due cose e' un vezzo: quattro punti allineati a passo costante
  /// sono una barra, quattro punti che salgono a passi diversi sono un
  /// cammino. L'ultima sta **in alto a destra**, dove aspetta l'animale, e
  /// piu' lontana delle altre: l'ultimo passo e' il piu' lungo.
  static const List<Offset> dove = [
    Offset(0.07, 0.86),
    Offset(0.30, 0.62),
    Offset(0.52, 0.44),
    Offset(0.86, 0.16),
  ];

  /// Quante impronte sono lasciate, cioe' quante discese sono state fatte.
  int get quanteLasciate =>
      seguiti.length.clamp(0, IQuattroViaggi.quanteDiscese);

  static GuideAnimal? _animale(String nome) {
    for (final a in AnimalCatalog.animals) {
      if (a.name == nome) return a;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) => SizedBox(
        key: const Key('viaggio_le_quattro_impronte'),
        height: altezza,
        width: double.infinity,
        child: LayoutBuilder(
          builder: (context, vincoli) {
            final larga = vincoli.maxWidth.isFinite ? vincoli.maxWidth : 320.0;
            // **L'IMPRONTA E' GRANDE QUANTO IL PASSO**, non quanto la scena:
            // su una soglia stretta il cammino si stringe e le impronte con
            // lui, invece di sovrapporsi.
            final segno = (larga * 0.12).clamp(18.0, 34.0);
            return Stack(
              children: [
                // **IL SENTIERO SOTTO**, che e' cio' che le lega: senza, sono
                // quattro segni sparsi e non un percorso.
                Positioned.fill(
                  child: CustomPaint(
                    painter: _PittoreDelSentiero(quante: quanteLasciate),
                  ),
                ),
                for (var i = 0; i < IQuattroViaggi.quanteDiscese; i++)
                  Positioned(
                    left: larga * dove[i].dx - segno / 2,
                    top: altezza * dove[i].dy - segno / 2,
                    width: segno,
                    height: segno,
                    child: _unImpronta(i, segno),
                  ),
              ],
            );
          },
        ),
      );

  Widget _unImpronta(int quale, double segno) {
    final lasciata = quale < quanteLasciate;
    final nome = lasciata ? seguiti[quale] : null;
    final animale = nome == null ? null : _animale(nome);
    // **L'ULTIMA, A RICONOSCIMENTO FATTO, E' L'ANIMALE E NON UN PASSO.**
    final eLArrivo = riconosciuto && quale == IQuattroViaggi.quanteDiscese - 1;
    if (!lasciata || animale == null) {
      // **IL PASSO CHE RESTA DA FARE**, un anello vuoto: dice che c'e' e che
      // non e' ancora stato fatto, senza dire quanto manca in cifre.
      return DecoratedBox(
        key: Key('viaggio_impronta_vuota_$quale'),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
              color: const Color(0xFFD6A868).withValues(alpha: 0.30),
              width: 1.2),
        ),
      );
    }
    return ColorFiltered(
      // **`srcIn` TIENE LA FORMA E BUTTA IL COLORE**: cio' che resta e'
      // esattamente il canale alpha di quella illustrazione, cioe' la sagoma
      // vera dell'animale seguito. E' la stessa tecnica dell'ombra
      // dell'incontro, e viene dalla stessa immagine.
      colorFilter: ColorFilter.mode(
          eLArrivo
              ? const Color(0xFFE8C88A)
              : const Color(0xFFD6A868).withValues(alpha: 0.78),
          BlendMode.srcIn),
      child: ImageFiltered(
        // Un filo di sfocatura: **un'impronta e' un segno lasciato, non un
        // ritaglio**, e alla misura di un'impronta il bordo netto di una
        // sagoma legge come un adesivo.
        imageFilter: ui.ImageFilter.blur(
            sigmaX: eLArrivo ? 0.2 : 0.9,
            sigmaY: eLArrivo ? 0.2 : 0.9,
            tileMode: TileMode.decal),
        child: Image.asset(
          animale.fullPath,
          key: Key('viaggio_impronta_$quale'),
          width: segno,
          height: segno,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
        ),
      ),
    );
  }
}

/// Il sentiero che lega le quattro impronte.
class _PittoreDelSentiero extends CustomPainter {
  _PittoreDelSentiero({required this.quante});

  final int quante;

  @override
  void paint(Canvas canvas, Size size) {
    Offset punto(int i) => Offset(size.width * LeQuattroImpronte.dove[i].dx,
        size.height * LeQuattroImpronte.dove[i].dy);
    final cammino = Path()..moveTo(punto(0).dx, punto(0).dy);
    for (var i = 1; i < LeQuattroImpronte.dove.length; i++) {
      final a = punto(i - 1);
      final b = punto(i);
      // **UNA CURVA E NON UNA SPEZZATA.** Un cammino fatto di segmenti dritti
      // e' un grafico; il punto di controllo a meta' strada, spostato in
      // basso, gli da' l'andatura di qualcosa che ha camminato li'.
      cammino.quadraticBezierTo(
          (a.dx + b.dx) / 2, (a.dy + b.dy) / 2 + size.height * 0.10, b.dx, b.dy);
    }
    canvas.drawPath(
      cammino,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFFD6A868).withValues(alpha: 0.22),
    );
  }

  @override
  bool shouldRepaint(_PittoreDelSentiero vecchio) => vecchio.quante != quante;
}
