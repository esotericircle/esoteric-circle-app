import 'package:flutter/material.dart';

import '../../core/cerchio/il_cerchio_sociale.dart';

/// **L'ORA NEL FORMATO DEL TELEFONO.** Ordine FC, Aggiunta della voce FC.10,
/// parte prima, 5 ottobre 2026.
///
/// Il fondatore: *"L'ora segue il formato del telefono: ventiquattro ore
/// oppure dodici ore con l'indicazione del mattino o del pomeriggio, secondo
/// l'impostazione del sistema. Non si scrive a mano un formato fisso. Un
/// telefono impostato a dodici ore deve leggere 'Il Cerchio come era alle
/// 9:47 PM.'"*
///
/// L'impostazione del sistema arriva da [MediaQuery.alwaysUse24HourFormatOf].
/// A ventiquattro ore l'ora la scrive [MaterialLocalizations]; a dodici ore
/// le localizzazioni italiane scriverebbero comunque le ventiquattro (e' il
/// formato della lingua), quindi l'ora del periodo e l'indicazione del
/// mattino o del pomeriggio si prendono una per una dalle stesse
/// localizzazioni.
String oraDelTelefono(BuildContext context, DateTime quando) {
  final t = TimeOfDay.fromDateTime(quando.toLocal());
  final l = MaterialLocalizations.of(context);
  if (MediaQuery.alwaysUse24HourFormatOf(context)) {
    return l.formatTimeOfDay(t, alwaysUse24HourFormat: true);
  }
  final ora = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
  final periodo = t.period == DayPeriod.am
      ? l.anteMeridiemAbbreviation
      : l.postMeridiemAbbreviation;
  return '$ora:${l.formatMinute(t)} $periodo';
}

/// "Il Cerchio come era alle 21:47.", con l'ora in cui l'istantanea e' stata
/// presa, nel formato del telefono. La usano la tendina e la rubrica.
String rigaDellUltimoDato(BuildContext context, DateTime quando) =>
    IlCerchioSociale.rigaDellUltimoDato(oraDelTelefono(context, quando));
