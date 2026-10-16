import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/tarot/tarot_card.dart';
import '../../design_system/theme/maestro_palette.dart';

/// L'elemento con cui una carta si presenta quando si scopre.
///
/// Viene dal seme per i Minori, ed e' la luce d'oro del cielo per i Maggiori,
/// che non hanno seme. Non e' una decorazione a caso: l'elemento e' quello
/// tradizionale del mazzo, e la stessa carta si scopre sempre allo stesso modo.
enum RevealElemento {
  fuoco,
  acqua,
  terra,
  aria,

  /// Gli Arcani Maggiori: nessun seme, la loro fioritura e' piu' solenne.
  cielo;

  /// L'elemento di una carta, dal suo seme.
  static RevealElemento of(TarotCard card) {
    switch (card.seme) {
      case TarotSeme.bastoni:
        return RevealElemento.fuoco;
      case TarotSeme.coppe:
        return RevealElemento.acqua;
      case TarotSeme.denari:
        return RevealElemento.terra;
      case TarotSeme.spade:
        return RevealElemento.aria;
      case null:
        return RevealElemento.cielo;
    }
  }

  /// Quante scintille compongono il moto: poche, e' un accenno non una festa.
  int get particelle {
    switch (this) {
      case RevealElemento.fuoco:
        return 14;
      case RevealElemento.acqua:
        return 10;
      case RevealElemento.terra:
        return 8;
      case RevealElemento.aria:
        return 12;
      case RevealElemento.cielo:
        return 18;
    }
  }

  /// Da dove parte il moto e dove va.
  ///
  /// Il fuoco sale, l'acqua ondeggia e scende, la terra si posa, l'aria si
  /// allarga di lato, il cielo si apre in tutte le direzioni.
  Offset direzioneDi(double angolo, double t) {
    switch (this) {
      case RevealElemento.fuoco:
        return Offset(math.sin(angolo * 3 + t * 4) * 0.25, -1.0 - t * 0.4);
      case RevealElemento.acqua:
        return Offset(math.sin(angolo * 2 + t * 3) * 0.6, 0.7);
      case RevealElemento.terra:
        return Offset(math.cos(angolo) * 0.35, 0.9 + t * 0.3);
      case RevealElemento.aria:
        return Offset(math.cos(angolo) * 1.1, math.sin(angolo) * 0.3 - 0.2);
      case RevealElemento.cielo:
        return Offset(math.cos(angolo), math.sin(angolo));
    }
  }
}

/// Come si scopre una carta: elemento, colori e ampiezza.
///
/// Tutto deterministico da seme e arcano: nessun caso, nessun tempo di sistema,
/// quindi la stessa carta si scopre identica a ogni apertura ed e' verificabile
/// da un test senza guardarla.
class RevealSpec {
  const RevealSpec({
    required this.elemento,
    required this.solenne,
    required this.ampiezza,
    required this.durata,
  });

  final RevealElemento elemento;

  /// Vero per gli Arcani Maggiori: la loro fioritura e' piu' ampia e lunga.
  final bool solenne;

  /// Quanto si allarga l'aura, in frazione del lato della carta.
  final double ampiezza;

  final Duration durata;

  /// La resa di una carta, dal suo seme e dal suo arcano.
  static RevealSpec of(TarotCard card) {
    final solenne = card.arcana == TarotArcana.maggiore;
    return RevealSpec(
      elemento: RevealElemento.of(card),
      solenne: solenne,
      // I Maggiori pesano di piu' nella lettura, e si vede.
      ampiezza: solenne ? 0.62 : 0.34,
      durata: solenne
          ? const Duration(milliseconds: 1100)
          : const Duration(milliseconds: 780),
    );
  }

  /// I colori dell'aura, nella palette del Maestro.
  ///
  /// Restano dentro il blu e oro di Medora: l'elemento si legge dal moto e da
  /// una punta di tinta, non da un arcobaleno che sfonderebbe il tono.
  List<Color> coloriIn(MaestroPalette palette) {
    // Tutti nell'oro di Medora: l'elemento si legge dal MOTO, non dalla
    // tinta. Provando col blu della palette le scintille sembravano puntini
    // spenti caduti sull'artwork, non un'aura.
    switch (elemento) {
      case RevealElemento.cielo:
        return [palette.goldSoft, palette.gold, palette.goldSoft];
      default:
        return [palette.goldSoft, palette.gold];
    }
  }
}

/// L'aura elementale che accompagna la carta appena scoperta.
///
/// Dura un attimo e sparisce: a riposo la carta resta pulita e leggibile, senza
/// niente sopra. Con Riduci Movimento non c'e' nessun moto, la carta appare
/// gia' composta.
class ElementalReveal extends StatelessWidget {
  const ElementalReveal({
    super.key,
    required this.spec,
    required this.progress,
    required this.palette,
  });

  final RevealSpec spec;

  /// L'avanzamento dell'effetto, da 0 a 1. A 1 non resta nulla.
  final double progress;

  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    if (progress <= 0 || progress >= 1) return const SizedBox.shrink();
    return IgnorePointer(
      child: CustomPaint(
        painter: _RevealPainter(
          spec: spec,
          t: progress,
          palette: palette,
        ),
      ),
    );
  }
}

class _RevealPainter extends CustomPainter {
  _RevealPainter({
    required this.spec,
    required this.t,
    required this.palette,
  });

  final RevealSpec spec;
  final double t;
  final MaestroPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    final centro = Offset(size.width / 2, size.height / 2);
    final lato = size.shortestSide;
    final colori = spec.coloriIn(palette);

    // L'alone che si apre e si spegne: una campana, non un lampo.
    final vita = math.sin(t * math.pi);
    final raggio = lato * (0.5 + spec.ampiezza * t);
    canvas.drawCircle(
      centro,
      raggio,
      Paint()
        ..shader = RadialGradient(
          colors: [
            colori.first.withValues(alpha: 0.0),
            colori.first.withValues(alpha: 0.34 * vita),
            Colors.transparent,
          ],
          stops: const [0.55, 0.78, 1.0],
        ).createShader(Rect.fromCircle(center: centro, radius: raggio)),
    );

    // Le scintille dell'elemento, che seguono il suo moto.
    for (var i = 0; i < spec.elemento.particelle; i++) {
      final angolo = i / spec.elemento.particelle * 2 * math.pi;
      final dir = spec.elemento.direzioneDi(angolo, t);
      // Le scintille partono dal BORDO della carta e si allontanano: l'aura
      // fiorisce attorno, non sopra l'artwork, che deve restare leggibile.
      final dist = lato * (0.58 + spec.ampiezza * t);
      final p = centro + Offset(dir.dx * dist, dir.dy * dist);
      final r = lato * 0.032 * vita * (spec.solenne ? 1.4 : 1.0);
      canvas.drawCircle(
        p,
        r,
        Paint()
          ..color = colori[i % colori.length].withValues(alpha: 0.85 * vita),
      );
    }

    // Sui Maggiori un anello che si allarga, la fioritura piu' solenne.
    if (spec.solenne) {
      canvas.drawCircle(
        centro,
        lato * (0.45 + 0.5 * t),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = lato * 0.022 * vita
          ..color = palette.goldSoft.withValues(alpha: 0.65 * vita),
      );
    }
  }

  @override
  bool shouldRepaint(_RevealPainter old) =>
      old.t != t || old.spec.elemento != spec.elemento;
}
