import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/tarot/tarot_card.dart';
import '../../design_system/components/vip_frame.dart' show CartiglioText;
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/typography_tokens.dart';

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

  // Placche blu misurate: alta x 0.395..0.603 y 0.017..0.069,
  // bassa x 0.352..0.678 y 0.924..0.965. Qui sotto, gia' rientrate.

  /// Cartiglio superiore, per il numerale.
  static const Rect cartiglioNumero = Rect.fromLTRB(0.403, 0.021, 0.595, 0.065);

  /// Cartiglio inferiore, per il nome della carta.
  static const Rect cartiglioNome = Rect.fromLTRB(0.365, 0.927, 0.665, 0.962);

  /// Le placche blu grezze, senza margine: confine dell'oro, per i test.
  static const Rect placcaNumero = Rect.fromLTRB(0.395, 0.017, 0.603, 0.069);
  static const Rect placcaNome = Rect.fromLTRB(0.352, 0.924, 0.678, 0.965);
}

/// Una carta del mazzo con i cartigli riempiti a runtime: il numerale in alto e
/// il nome in basso, in oro, come la cornice VIP.
///
/// Se la carta e' rovesciata l'artwork ruota di mezzo giro, ma numero e nome
/// restano dritti e leggibili: i cartigli stanno fuori dalla rotazione.
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.hasBoundedHeight
            ? constraints.maxHeight
            : w / TarotFrame.aspect;
        Rect px(Rect n) =>
            Rect.fromLTRB(n.left * w, n.top * h, n.right * w, n.bottom * h);

        return ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: palette.gold.withValues(alpha: 0.5)),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // L'artwork, girato di mezzo giro se la carta e' rovesciata.
                reversed ? Transform.rotate(angle: math.pi, child: art) : art,
                if (showCartigli) ...[
                  // I cartigli restano sempre dritti, anche sulla rovesciata.
                  Positioned.fromRect(
                    rect: px(TarotFrame.cartiglioNumero),
                    child: CartiglioText(text: card.numeral, palette: palette),
                  ),
                  Positioned.fromRect(
                    rect: px(TarotFrame.cartiglioNome),
                    child: CartiglioText(
                        text: card.name,
                        palette: palette,
                        preserveWordGap: true),
                  ),
                ],
              ],
            ),
          ),
        );
      },
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
