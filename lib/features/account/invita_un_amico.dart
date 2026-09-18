import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/condivisione/porta_della_condivisione.dart';
import '../../core/identity/account_del_cerchio.dart';
import '../../core/sigilli/bonus_della_condivisione.dart';

/// **INVITA UN AMICO, quando vuoi. Ordine DW voce 05, 18 settembre 2026.**
///
/// Il censimento del fondatore ha trovato che invitare qualcuno si poteva
/// **solo dalla festa di un Sigillo**: chi non ne aveva acceso nessuno non
/// aveva nessun modo di farlo, e chi l'aveva gia' festeggiato doveva
/// ritrovarlo in fondo al Passaporto, quattro tocchi dopo.
///
/// Da qui parte il link col codice di chi invita, come quello della festa:
/// chi arriva lo incolla quando si registra e il server paga 60 Eos a tutti
/// e due (`riscattaLInvito`). **Nessun premio alla condivisione**: si paga
/// l'ingresso vero, come l'ordine BX voce 02 ha stabilito.
Future<bool> invitaUnAmico(BuildContext context) async {
  String? uid;
  try {
    uid = context.read<AccountDelCerchio>().uid;
  } catch (senzaAccount) {
    uid = null;
  }
  return PortaDellaCondivisione.testo(TestoDellaCondivisione.invitoLibero(
      codiceInvito: TestoDellaCondivisione.codiceDellInvito(uid, null)));
}
