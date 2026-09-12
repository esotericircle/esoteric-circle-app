import 'package:flutter/material.dart';

import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';

/// Quanto lunga vuole la risposta la persona, per singola scheda.
///
/// Sta su ogni scheda e non e' un controllo unico: cosi' si potra' approfondire
/// solo le categorie che interessano, e a runtime i testi lunghi si generano
/// soltanto dove servono, senza bruciare token dove non serve.
///
/// Nel gratuito e nella Demo la profondita' e' fissa su [breve]: la [profonda]
/// e' del Cerchio Premium. La [media] resta latente e spenta, fuori dalla vista,
/// pronta a riaccendersi un giorno: l'app dice due voci ovunque.
///
/// La [profonda] e' adattiva, lunga quanto serve fino al tetto di token, non
/// gonfiata a forza: il tetto vive nel provider AI, non qui.
enum AnswerDepth {
  breve('Breve', premium: false, visible: true),

  /// Gradino intermedio tenuto latente e spento: non compare nel selettore, ma
  /// resta nel codice per riaccenderlo senza rifare l'impianto.
  media('Media', premium: true, visible: false),

  profonda('Profonda', premium: true, visible: true);

  const AnswerDepth(this.label, {required this.premium, required this.visible});

  final String label;

  /// Vero se la voce richiede l'abbonamento.
  final bool premium;

  /// Vero se la voce si mostra nel selettore. La [media] e' latente, quindi no.
  final bool visible;

  /// La profondita' del gratuito, quella su cui si resta senza Premium.
  static const AnswerDepth free = AnswerDepth.breve;

  /// Le voci mostrate nel selettore, due sole: Breve e Profonda.
  static List<AnswerDepth> get shown => values.where((d) => d.visible).toList();
}

/// Il selettore di profondita' della risposta, in alto a destra di ogni scheda.
///
/// E' un menu a tendina compatto: mostra il titolo "Profondità" e la voce
/// corrente, col lucchetto quando non si e' Premium. Al tocco apre le due voci
/// Breve e Profonda: senza abbonamento solo Breve e' selezionabile, la Profonda
/// porta il lucchetto e l'invito ad abbonarsi.
class AnswerDepthSelector extends StatelessWidget {
  const AnswerDepthSelector({
    super.key,
    required this.current,
    required this.palette,
    this.premiumUnlocked = false,
    this.onSelect,
    this.onLockedTap,
    this.compact = false,
  });

  final AnswerDepth current;
  final MaestroPalette palette;

  /// Vero quando l'abbonamento e' attivo e le voci lunghe si sbloccano.
  final bool premiumUnlocked;

  final ValueChanged<AnswerDepth>? onSelect;

  /// Invito all'abbonamento, quando si tocca una voce bloccata.
  final ValueChanged<AnswerDepth>? onLockedTap;

  /// In colonna stretta l'etichetta si toglie e resta la sola voce corrente.
  ///
  /// Serve dove la colonna e' larga poco piu' di cento punti, come sotto le
  /// carte della stesa: la parola PROFONDITÀ e' chiesta a corpo 8 ma il design
  /// system non scende sotto `minLabel`, quindi andava a capo spezzata. Il
  /// tooltip continua a dire di cosa si tratta, e il menu resta identico.
  final bool compact;

  bool _locked(AnswerDepth depth) => depth.premium && !premiumUnlocked;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<AnswerDepth>(
      tooltip: premiumUnlocked
          ? 'Scegli quanto approfondire questa scheda'
          : 'La profondità della risposta è del Cerchio Premium. Abbonati per scegliere quanto approfondire, scheda per scheda.',
      position: PopupMenuPosition.under,
      color: palette.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
        side: BorderSide(color: palette.gold.withValues(alpha: 0.35)),
      ),
      onSelected: (depth) {
        if (_locked(depth)) {
          onLockedTap?.call(depth);
          return;
        }
        onSelect?.call(depth);
      },
      itemBuilder: (context) => [
        for (final depth in AnswerDepth.shown)
          PopupMenuItem<AnswerDepth>(
            value: depth,
            height: 40,
            child: Row(
              children: [
                Icon(
                  depth == current
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  size: 15,
                  color: depth == current
                      ? palette.goldSoft
                      : ColorTokens.textSecondary.withValues(alpha: 0.7),
                ),
                const SizedBox(width: SpacingTokens.xs),
                Expanded(
                  child: Text(depth.label,
                      style: TypographyTokens.didascalia().copyWith(
                        color: _locked(depth)
                            ? ColorTokens.textSecondary
                            : ColorTokens.textPrimary,
                      )),
                ),
                if (_locked(depth))
                  Icon(Icons.lock_rounded,
                      size: 14,
                      color: palette.goldSoft.withValues(alpha: 0.75)),
              ],
            ),
          ),
      ],
      padding: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SpacingTokens.radiusSm),
          color: palette.deepest.withValues(alpha: 0.5),
          border: Border.all(color: palette.gold.withValues(alpha: 0.35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!compact) ...[
              Text('PROFONDITÀ',
                  style: TypographyTokens.etichetta().copyWith(
                      color: ColorTokens.textSecondary, letterSpacing: 0.8)),
              const SizedBox(height: 2),
            ],
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(current.label,
                    style: TypographyTokens.didascalia()
                        .copyWith(color: palette.goldSoft)),
                const SizedBox(width: 4),
                // Il lucchetto sul chip solo se la voce MOSTRATA e' bloccata.
                // Breve e' gratuita: mettercelo sopra faceva sembrare bloccata
                // anche lei, quando invece e' quella che si sta usando. Le voci
                // Premium il lucchetto ce l'hanno dentro il menu aperto.
                if (_locked(current))
                  Icon(Icons.lock_rounded,
                      size: 12, color: palette.goldSoft.withValues(alpha: 0.7)),
                Icon(Icons.arrow_drop_down_rounded,
                    size: 16,
                    color: ColorTokens.textSecondary.withValues(alpha: 0.9)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
