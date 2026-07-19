import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/tarot/tarot_card.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/typography_tokens.dart';
import 'tarot_cartiglio.dart';

/// Le misure della cornice madre delle carte, identica su tutte e settantotto.
///
/// Ricavate misurando l'artwork reale (853 per 1280) su tutte le carte: si cerca
/// la placca blu piatta dei due cartigli e si prende la colonna libera, poi si
/// rientra dalle volute d'oro con un margine di sicurezza. Cosi' il testo vive
/// sempre sul blu e non tocca mai l'oro.
class TarotFrame {
  const TarotFrame._();

  /// Rapporto della carta, due a tre come l'artwork.
  static const double aspect = 2 / 3;

  // Le due placche blu, misurate sull'artwork reale (853 per 1280) su dodici
  // carte diverse: i valori coincidono, la cornice madre e' la stessa su tutte.
  // Si cerca la banda di blu piatto e si prende il suo bordo vero.

  /// La placca del numerale: il confine dell'oro.
  ///
  /// La misura precedente partiva da 0,017 e comprendeva anche la modanatura
  /// dorata che corre a 0,022..0,026: e' per quello che il numero sembrava
  /// toccare il bordo alto, gli veniva dato spazio che non era suo.
  static const Rect placcaNumero = Rect.fromLTRB(0.393, 0.031, 0.604, 0.069);

  /// La placca del nome: il confine dell'oro.
  ///
  /// Anche questa era stretta rispetto al vero, di circa 0,008 in alto e di
  /// 0,03 in larghezza: da qui lo spazio ritrovato per il nome su due righe.
  static const Rect placcaNome = Rect.fromLTRB(0.321, 0.918, 0.679, 0.966);

  /// Il respiro fra il testo e l'oro, in frazione dell'altezza della placca.
  ///
  /// Proporzionale e non assoluto: un valore fisso mangerebbe una fetta enorme
  /// della placca bassa, che e' molto piu' schiacciata di quella alta.
  static const double margineTesto = 0.08;

  /// L'area utile di una placca: la placca meno il respiro, uguale sui quattro
  /// lati in pixel.
  static Rect areaUtile(Rect placca) {
    final my = placca.height * margineTesto;
    // La carta e' piu' alta che larga: per un respiro uguale in pixel, in
    // frazione l'orizzontale e' piu' grande del verticale.
    final mx = my / aspect;
    return Rect.fromLTRB(
      placca.left + mx,
      placca.top + my,
      placca.right - mx,
      placca.bottom - my,
    );
  }

  /// Cartiglio superiore, per il numerale.
  static final Rect cartiglioNumero = areaUtile(placcaNumero);

  /// Cartiglio inferiore, per il nome della carta.
  static final Rect cartiglioNome = areaUtile(placcaNome);
}

/// Divide il nome della carta in due righe quando e' lungo.
///
/// Si spezza sul "di" (CAVALIERE, poi DI BASTONI), altrimenti sullo spazio piu'
/// vicino alla meta'. Ritorna una sola riga per i nomi corti.
List<String> splitNomeCartiglio(String nome, {int sogliaCaratteri = 13}) {
  final testo = nome.trim();
  if (testo.length <= sogliaCaratteri) return [testo];

  final di = testo.toLowerCase().indexOf(' di ');
  if (di > 0) {
    return [testo.substring(0, di), testo.substring(di + 1)];
  }
  // Nessun "di": si spezza sullo spazio piu' vicino alla meta'.
  final spazi = <int>[];
  for (var i = 0; i < testo.length; i++) {
    if (testo[i] == ' ') spazi.add(i);
  }
  if (spazi.isEmpty) return [testo];
  final meta = testo.length / 2;
  var scelto = spazi.first;
  for (final s in spazi) {
    if ((s - meta).abs() < (scelto - meta).abs()) scelto = s;
  }
  return [testo.substring(0, scelto), testo.substring(scelto + 1)];
}

/// Lo stile di partenza dei cartigli: oro del Maestro, inciso sul blu.
TextStyle cartiglioBaseStyle(MaestroPalette palette) =>
    TypographyTokens.display(size: 40).copyWith(
      color: palette.goldSoft,
      shadows: [Shadow(color: palette.deepest, blurRadius: 2)],
    );

/// Il testo di un cartiglio, alla massima misura che riempie l'area utile.
///
/// Una riga sola per i testi corti, due righe per i nomi lunghi: in ogni caso il
/// testo occupa il cartiglio, non ci galleggia dentro piccolo.
class CartiglioTesto extends StatelessWidget {
  const CartiglioTesto({
    super.key,
    required this.righe,
    required this.palette,
  });

  final List<String> righe;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    final maiuscole = [for (final r in righe) r.toUpperCase()];
    final base = cartiglioBaseStyle(palette);

    return LayoutBuilder(
      builder: (context, constraints) {
        final fit = resolveCartiglioArea(
          righe: maiuscole,
          base: base,
          maxWidth: constraints.maxWidth,
          maxHeight: constraints.maxHeight,
        );
        // Ogni riga sta in una banda alta quanto il suo inchiostro, e fra due
        // righe c'e' l'interlinea, niente di piu'. Dividere l'altezza in bande
        // uguali lasciava mezza interlinea anche sopra e sotto il blocco.
        final unita = unitaInchiostro(maiuscole, fit.fontSize);
        final interlinea = unita * kInterlinea;
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < maiuscole.length; i++) ...[
              if (i > 0) SizedBox(height: interlinea),
              CartiglioRiga(
                testo: maiuscole[i],
                fit: fit,
                base: base,
                bandaHeight: unita,
              ),
            ],
          ],
        );
      },
    );
  }
}

/// Il nome nel cartiglio inferiore: una riga se corto, due righe se lungo, alla
/// misura piu' grande che entra nel blu.
class CartiglioNome extends StatelessWidget {
  const CartiglioNome({super.key, required this.nome, required this.palette});

  final String nome;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) =>
      CartiglioTesto(righe: splitNomeCartiglio(nome), palette: palette);
}

/// Il contenuto del cartiglio superiore: il numerale, oppure l'emblema del seme
/// per le carte di corte.
class CartiglioNumero extends StatelessWidget {
  const CartiglioNumero({super.key, required this.card, required this.palette});

  final TarotCard card;
  final MaestroPalette palette;

  /// L'emblema che spetta a una carta di corte, dal suo seme.
  static SuitEmblem? emblemFor(TarotCard card) {
    if (!card.isCorte) return null;
    switch (card.seme) {
      case TarotSeme.bastoni:
        return SuitEmblem.bastoni;
      case TarotSeme.coppe:
        return SuitEmblem.coppe;
      case TarotSeme.denari:
        return SuitEmblem.denari;
      case TarotSeme.spade:
        return SuitEmblem.spade;
      case null:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final emblem = emblemFor(card);
    if (emblem != null) {
      return SuitEmblemMark(emblem: emblem, palette: palette);
    }
    return CartiglioTesto(righe: [card.numeral], palette: palette);
  }
}

/// Una carta del mazzo con i cartigli riempiti a runtime: il numerale in alto e
/// il nome in basso, in oro.
///
/// Se la carta e' rovesciata gira tutta la carta, cartigli compresi, come una
/// carta vera girata in mano.
class TarotCardArt extends StatelessWidget {
  const TarotCardArt({
    super.key,
    required this.card,
    required this.palette,
    this.reversed = false,
    this.showCartigli = true,
    this.borderRadius = 6,
  });

  final TarotCard card;
  final MaestroPalette palette;
  final bool reversed;

  /// Alle misure molto piccole i cartigli non si leggono: si possono spegnere.
  final bool showCartigli;

  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final art = Image.asset(
      card.fullPath,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _PaintedCard(card: card, palette: palette),
    );

    final carta = LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.hasBoundedHeight
            ? constraints.maxHeight
            : w / TarotFrame.aspect;
        Rect px(Rect n) =>
            Rect.fromLTRB(n.left * w, n.top * h, n.right * w, n.bottom * h);

        return Stack(
          fit: StackFit.expand,
          children: [
            art,
            if (showCartigli) ...[
              Positioned.fromRect(
                rect: px(TarotFrame.cartiglioNumero),
                child: CartiglioNumero(card: card, palette: palette),
              ),
              Positioned.fromRect(
                rect: px(TarotFrame.cartiglioNome),
                child: CartiglioNome(nome: card.name, palette: palette),
              ),
            ],
          ],
        );
      },
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: palette.gold.withValues(alpha: 0.5)),
        ),
        // La rovesciata gira per intero, cartigli inclusi.
        child:
            reversed ? Transform.rotate(angle: math.pi, child: carta) : carta,
      ),
    );
  }
}

/// Ripiego dipinto se l'arte di una carta mancasse: mai una carta vuota.
class _PaintedCard extends StatelessWidget {
  const _PaintedCard({required this.card, required this.palette});

  final TarotCard card;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: palette.surfaceElevated,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(6),
      child: Text(card.name,
          textAlign: TextAlign.center,
          style: TypographyTokens.display(size: 12)
              .copyWith(color: palette.goldSoft)),
    );
  }
}
