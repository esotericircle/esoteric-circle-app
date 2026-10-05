import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/entitlement/il_consenso_della_spesa.dart';
import '../../core/entitlement/question_allowance.dart';
import '../theme/maestro_palette.dart';
import '../theme/maestro_scope.dart';
import '../tokens/color_tokens.dart';
import '../tokens/typography_tokens.dart';
import '../transizioni/velo_del_cerchio.dart';

/// LA CONFERMA DELLA SPESA, una sola per tutta l'app. Ordine FD voce 01.
///
/// Nessuna funzione consuma minuti, Eos o denaro al primo tocco: prima
/// compare questa conferma, col costo, col saldo e con due pulsanti. Solo il
/// pulsante di conferma restituisce un [ConsensoDellaSpesa], e senza consenso
/// nessuna porta di spesa si puo' chiamare.
///
/// I testi sono quelli dell'ordine FD, alla lettera.
class LaConfermaDellaSpesa {
  LaConfermaDellaSpesa._();

  static const String titoloDeiMinuti =
      'Stai per aprire una sessione dal vivo.';
  static const String confermaDeiMinuti = 'Apri la sessione';
  static const String titoloDegliEos = 'Stai per usare i tuoi Eos.';
  static const String confermaDegliEos = 'Procedi';
  static const String nonOra = 'Non ora';

  /// "Questa sessione consuma NN minuti dei tuoi MM minuti disponibili."
  ///
  /// **Un minuto si dice al singolare**: "consuma 1 minuti" sarebbe un errore
  /// a video. E' l'unico scarto dal testo dell'ordine, ed e' dichiarato nel
  /// rapporto.
  static String corpoDeiMinuti(int nn, int mm) =>
      'Questa sessione consuma $nn ${nn == 1 ? 'minuto' : 'minuti'} dei tuoi '
      '$mm ${mm == 1 ? 'minuto disponibile' : 'minuti disponibili'}.';

  /// "Questa richiesta costa NN Eos. Nel tuo borsellino ce ne sono MM."
  static String corpoDegliEos(int nn, int mm) =>
      'Questa richiesta costa $nn Eos. Nel tuo borsellino ce ne sono $mm.';

  /// Col saldo che non basta: "Questa richiesta costa NN Eos e nel tuo
  /// borsellino ce ne sono MM."
  static String corpoDegliEosCheNonBastano(int nn, int mm) =>
      'Questa richiesta costa $nn Eos e nel tuo borsellino ce ne sono $mm.';

  /// La conferma degli Eos. Il saldo si legge dal borsellino della persona,
  /// [QuestionAllowance.saldoEos], lo stesso che mostra la barra.
  static Future<ConsensoDellaSpesa?> degliEos(
    BuildContext context, {
    required int costo,
  }) {
    final saldo = context.read<QuestionAllowance>().saldoEos;
    final basta = saldo >= costo;
    return _chiedi(
      context,
      quanti: costo,
      titolo: titoloDegliEos,
      corpo: basta
          ? corpoDegliEos(costo, saldo)
          : corpoDegliEosCheNonBastano(costo, saldo),
      conferma: confermaDegliEos,
      attiva: basta,
    );
  }

  /// La conferma dei minuti del LIVE: [minuti] e' quanto puo' durare la
  /// sessione, [disponibili] i minuti del mese che restano, letti dal server.
  static Future<ConsensoDellaSpesa?> deiMinuti(
    BuildContext context, {
    required int minuti,
    required int disponibili,
  }) {
    return _chiedi(
      context,
      quanti: minuti,
      titolo: titoloDeiMinuti,
      corpo: corpoDeiMinuti(minuti, disponibili),
      conferma: confermaDeiMinuti,
      attiva: disponibili > 0 && minuti > 0,
    );
  }

  static Future<ConsensoDellaSpesa?> _chiedi(
    BuildContext context, {
    required int quanti,
    required String titolo,
    required String corpo,
    required String conferma,
    required bool attiva,
  }) async {
    final palette = MaestroScope.forse(context) ?? MaestroPalette.neutral;
    final si = await dialogoDelCerchio<bool>(
      context: context,
      builder: (c) => AlertDialog(
        key: const Key('conferma_spesa'),
        backgroundColor: MaestroPalette.neutral.surfaceElevated,
        title: Text(titolo,
            key: const Key('conferma_spesa_titolo'),
            style: TypographyTokens.titoloScheda()
                .copyWith(color: palette.goldSoft)),
        content: Text(corpo,
            key: const Key('conferma_spesa_corpo'),
            style: TypographyTokens.corpo()
                .copyWith(color: ColorTokens.textPrimary)),
        actions: [
          TextButton(
            key: const Key('conferma_spesa_non_ora'),
            style: TextButton.styleFrom(foregroundColor: palette.goldSoft),
            onPressed: () => Navigator.of(c).pop(false),
            child: const Text(nonOra),
          ),
          FilledButton(
            key: const Key('conferma_spesa_procedi'),
            style: FilledButton.styleFrom(
              backgroundColor: palette.gold,
              foregroundColor: palette.onPrimary,
            ),
            // **COL SALDO CHE NON BASTA IL PULSANTE E' SPENTO**, e la conferma
            // non puo' restituire un consenso.
            onPressed: attiva ? () => Navigator.of(c).pop(true) : null,
            child: Text(conferma),
          ),
        ],
      ),
    );
    if (si != true) return null;
    return ConsensoDellaSpesa.dato(quanti);
  }
}
