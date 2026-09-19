import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/entitlement/question_allowance.dart';
import '../../core/entitlement/registro_degli_eos.dart';

import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/components/icona_degli_eos.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import 'pricing_screen.dart';
import '../../design_system/transizioni/velo_del_cerchio.dart';

/// Invito gentile all'upgrade, mai un vicolo cieco.
///
/// Quando un blocco premium si presenta (per esempio il limite giornaliero di
/// domande del Free), non si chiude una porta: si apre un invito elegante, con
/// la via ai piani. Restituisce true se l'utente e' andato ai piani.
///
/// **LA SECONDA STRADA, quella degli Eos. Ordine BG voce 05.** Il gating a
/// due strade dell'ordine AN dice Eos oppure abbonamento, mai un vicolo
/// cieco: quando chi chiama passa [riscattoLabel] e [onRiscatta], l'invito
/// porta anche il pulsante del riscatto col prezzo in chiaro. Con
/// [riscattoLabel] senza [onRiscatta] la riga compare muta: e' il caso del
/// saldo che non basta, e si dice quanto manca invece di nascondere la
/// strada. Il tocco chiude il foglio e affida l'esito a chi ha chiamato.
Future<bool> showUpgradeInvite(
  BuildContext context, {
  required String title,
  required String message,
  String? riscattoLabel,
  Future<void> Function()? onRiscatta,
}) async {
  final palette = context.palette;
  final result = await foglioDelCerchio<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => Container(
      key: const Key('upgrade_invite'),
      padding: const EdgeInsets.fromLTRB(SpacingTokens.lg, SpacingTokens.md,
          SpacingTokens.lg, SpacingTokens.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [palette.surfaceElevated, palette.deepest],
        ),
        borderRadius: const BorderRadius.vertical(
            top: Radius.circular(SpacingTokens.radiusXl)),
        border: Border.all(color: palette.gold.withValues(alpha: 0.3)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: palette.goldSoft, size: 22),
                const SizedBox(width: SpacingTokens.sm),
                Expanded(
                  child: Text(title,
                      style: TypographyTokens.titoloDiSchermata()
                          .copyWith(color: palette.goldSoft)),
                ),
              ],
            ),
            const SizedBox(height: SpacingTokens.sm),
            Text(message,
                style: TypographyTokens.corpo()
                    .copyWith(color: ColorTokens.textSecondary, height: 1.4)),
            const SizedBox(height: SpacingTokens.lg),
            if (riscattoLabel != null) ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  key: const Key('invito_riscatto'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: onRiscatta == null
                        ? ColorTokens.textSecondary
                        : palette.goldSoft,
                    side: BorderSide(
                        color: palette.gold.withValues(
                            alpha: onRiscatta == null ? 0.25 : 0.6)),
                  ),
                  onPressed: onRiscatta == null
                      ? null
                      : () async {
                          Navigator.of(sheetContext).pop(false);
                          await onRiscatta();
                        },
                  // L'icona del denaro del Cerchio, non un gettone di
                  // serie: la legge di S.05 vale anche qui, dove il numero
                  // in Eos e' un prezzo. Il colore segue lo stato della riga.
                  icon: IconaDegliEos(
                      misura: 18,
                      colore: onRiscatta == null
                          ? ColorTokens.textSecondary
                          : palette.goldSoft),
                  label: Text(riscattoLabel, style: TypographyTokens.label()),
                ),
              ),
              const SizedBox(height: SpacingTokens.sm),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(sheetContext).pop(false),
                  child: Text('Non ora',
                      style: TypographyTokens.label(size: 13)
                          .copyWith(color: ColorTokens.textSecondary)),
                ),
                const SizedBox(width: SpacingTokens.sm),
                TextButton(
                  key: const Key('upgrade_see_plans'),
                  onPressed: () => Navigator.of(sheetContext).pop(true),
                  child: Text('Vedi i piani',
                      style: TypographyTokens.label(size: 13)
                          .copyWith(color: palette.goldSoft)),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  if (result == true && context.mounted) {
    await Navigator.of(context).push(PricingScreen.route());
    return true;
  }
  return false;
}

/// **IL CORREDO DEL RISCATTO per un budget del giorno.** Ordine BG voce 05.
///
/// Compone etichetta e azione per [showUpgradeInvite]: prezzo in chiaro dal
/// listino del server, azione viva solo se il saldo basta (se manca, la riga
/// dice quanto manca e resta muta). A riscatto avvenuto scrive il movimento
/// nel registro con parole di persona, dice l'esito con una snackbar e
/// chiama [onSuccesso], con cui chi ha chiamato puo' rifare il gesto subito.
/// Torna (null, null) se il server non ha ancora detto il prezzo: senza
/// prezzo non si promette niente.
({String? label, Future<void> Function()? azione}) corredoDelRiscatto(
  BuildContext context, {
  required String budget,
  required String cosaUna,
  void Function(int prezzo)? onSuccesso,
}) {
  final QuestionAllowance borsa;
  try {
    borsa = context.read<QuestionAllowance>();
  } catch (errore) {
    return (label: null, azione: null);
  }
  final prezzo = borsa.prezzoDelRiscatto(budget);
  if (prezzo == null) return (label: null, azione: null);
  final saldo = borsa.saldoEos;
  if (saldo < prezzo) {
    return (
      label: 'Riscatta $cosaUna · $prezzo Eos (te ne mancano '
          '${prezzo - saldo})',
      azione: null,
    );
  }
  RegistroDegliEos? registro;
  try {
    registro = context.read<RegistroDegliEos>();
  } catch (errore) {
    registro = null;
  }
  final messaggero = ScaffoldMessenger.maybeOf(context);
  return (
    label: 'Riscatta $cosaUna · $prezzo Eos',
    azione: () async {
      final pagato = await borsa.riscatta(budget);
      if (pagato == null) {
        messaggero?.showSnackBar(const SnackBar(
          key: Key('riscatto_non_riuscito'),
          content: Text('Il riscatto non è riuscito: il Cerchio non ha '
              'risposto. Gli Eos sono al loro posto, riprova fra un momento.'),
        ));
        return;
      }
      await registro?.segna(quanti: -pagato, perche: 'Hai riscattato $cosaUna');
      messaggero?.showSnackBar(SnackBar(
        key: const Key('riscatto_fatto'),
        content: Text('Riscatto compiuto: $cosaUna. Spesi $pagato Eos.'),
      ));
      onSuccesso?.call(pagato);
    },
  );
}
