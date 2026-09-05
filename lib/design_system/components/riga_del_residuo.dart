import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/entitlement/budget_del_giorno.dart';
import '../../core/entitlement/entitlement_service.dart';
import '../../core/entitlement/question_allowance.dart';
import '../tokens/color_tokens.dart';
import '../tokens/spacing_tokens.dart';
import '../tokens/typography_tokens.dart';
import '../theme/maestro_scope.dart';

/// QUANTO TE NE RESTA, DETTO PRIMA DEL GESTO. Ordine CE voce 04.
///
/// **Le parole del fondatore, verbatim:** "l'utente deve Sapere quante ne
/// mancano. ma questo vale per tutte le funzionalita' limitate o dove e'
/// previsto l'acquisto."
///
/// **Una casa sola per tutti e sei i budget.** Ogni punto che consuma monta
/// questa riga col proprio [budget], e una prova enumera
/// `BudgetDelGiorno.values` per pretendere che ognuno abbia il suo posto: cosi'
/// il punto che nasce domani o si dichiara o cade.
///
/// **Quando non c'e' niente da dire, non si disegna niente.** Senza tetto non
/// c'e' un residuo, e senza la risposta del server non si indovina: e' la legge
/// dell'ordine BG voce 04, e qui diventa una `SizedBox.shrink()`.
///
/// **Non blocca e non spaventa.** E' una riga sottile, del colore del testo
/// secondario, che sta accanto al gesto e non davanti: il fondatore ha appena
/// fatto togliere due fogli perche' si mettevano in mezzo.
class RigaDelResiduo extends StatelessWidget {
  const RigaDelResiduo({
    super.key,
    required this.budget,
    this.allineamento = MainAxisAlignment.start,
  });

  final BudgetDelGiorno budget;
  final MainAxisAlignment allineamento;

  /// La chiave con cui la prova trova questa riga, una per budget.
  static Key chiaveDi(BudgetDelGiorno b) => Key('residuo_${b.name}');

  @override
  Widget build(BuildContext context) {
    final borsa = _forse<QuestionAllowance>(context);
    final piano = _forse<EntitlementService>(context)?.tier;
    if (borsa == null || piano == null) return const SizedBox.shrink();
    final detto = budget.riga(borsa, piano);
    if (detto == null) return const SizedBox.shrink();
    final palette = MaestroScope.forse(context);
    return Padding(
      key: chiaveDi(budget),
      padding: const EdgeInsets.symmetric(vertical: SpacingTokens.xs),
      child: Row(
        mainAxisAlignment: allineamento,
        children: [
          Icon(Icons.hourglass_bottom_rounded,
              size: 14,
              color: palette?.goldSoft.withValues(alpha: 0.8) ??
                  ColorTokens.textSecondary),
          const SizedBox(width: SpacingTokens.xs),
          Flexible(
            child: Text(
              detto,
              style: TypographyTokens.didascalia()
                  .copyWith(color: ColorTokens.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  /// **SE L'ALBERO NON PORTA LA BORSA non si dice niente e non si cade**:
  /// succede in ogni prova che monta una schermata da sola e in ogni anteprima,
  /// e una scena che casca perche' manca un provider sarebbe un difetto
  /// peggiore del conto mancato.
  static T? _forse<T>(BuildContext context) {
    try {
      return context.watch<T>();
    } catch (errore) {
      return null;
    }
  }
}
