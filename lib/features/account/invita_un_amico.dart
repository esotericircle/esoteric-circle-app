import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/condivisione/porta_della_condivisione.dart';
import '../../core/entitlement/question_allowance.dart';
import '../../core/sigilli/bonus_della_condivisione.dart';

/// **INVITA UN AMICO, quando vuoi. Ordine DW voce 05, 18 settembre 2026.**
///
/// Il censimento del fondatore ha trovato che invitare qualcuno si poteva
/// **solo dalla festa di un Sigillo**: chi non ne aveva acceso nessuno non
/// aveva nessun modo di farlo, e chi l'aveva gia' festeggiato doveva
/// ritrovarlo in fondo al Passaporto, quattro tocchi dopo.
///
/// Da qui parte il link col codice di chi invita, come quello della festa:
/// chi arriva lo incolla quando si registra e il server paga il premio a
/// tutti e due (`riscattaLInvito`; la cifra la dice il server). **Nessun
/// premio alla condivisione**: si paga l'ingresso vero, come l'ordine BX
/// voce 02 ha stabilito. **Il codice e' quello opaco del server, ordine EY
/// voce 17**: lo aggiunge la porta della condivisione, e qui non passa
/// nessun uid.
Future<bool> invitaUnAmico(BuildContext context) async {
  int? premio;
  try {
    premio = context.read<QuestionAllowance>().premioDellInvito;
  } catch (senzaBorsa) {
    premio = null;
  }
  return PortaDellaCondivisione.testo(
      TestoDellaCondivisione.invitoLibero(premioInvito: premio));
}
