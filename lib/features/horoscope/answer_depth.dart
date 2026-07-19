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
enum AnswerDepth {
  breve('Breve'),
  media('Media'),
  approfondita('Approfondita');

  const AnswerDepth(this.label);

  final String label;
}

/// Il selettore di profondita' della risposta, in alto a destra di ogni scheda.
///
/// Nella Demo e' bloccato dietro l'abbonamento: si vede, mostra il lucchetto e
/// invita con un tooltip, ma non cambia nulla. Lo stato per scheda e' gia'
/// predisposto in [current], cosi' quando il gating si apre basta accendere
/// [locked] a falso e collegare [onSelect].
class AnswerDepthSelector extends StatelessWidget {
  const AnswerDepthSelector({
    super.key,
    required this.current,
    required this.palette,
    this.locked = true,
    this.onSelect,
    this.onLockedTap,
  });

  final AnswerDepth current;
  final MaestroPalette palette;
  final bool locked;
  final ValueChanged<AnswerDepth>? onSelect;
  final VoidCallback? onLockedTap;

  @override
  Widget build(BuildContext context) {
    final control = Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
        color: palette.deepest.withValues(alpha: 0.45),
        border: Border.all(color: palette.gold.withValues(alpha: 0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final depth in AnswerDepth.values) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Text(
                depth.label,
                style: TypographyTokens.label(size: 8).copyWith(
                  color: depth == current
                      ? palette.goldSoft.withValues(alpha: locked ? 0.7 : 1.0)
                      : ColorTokens.textSecondary
                          .withValues(alpha: locked ? 0.45 : 0.8),
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
          if (locked)
            Padding(
              padding: const EdgeInsets.only(left: 2),
              child: Icon(Icons.lock_rounded,
                  size: 10, color: palette.goldSoft.withValues(alpha: 0.65)),
            ),
        ],
      ),
    );

    if (!locked) return control;
    return Tooltip(
      message:
          'La profondita\' della risposta e\' del Cerchio Premium. Abbonati per scegliere quanto approfondire, scheda per scheda.',
      child: GestureDetector(
        onTap: onLockedTap,
        behavior: HitTestBehavior.opaque,
        child: control,
      ),
    );
  }
}
