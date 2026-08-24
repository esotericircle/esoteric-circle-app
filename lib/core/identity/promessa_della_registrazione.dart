import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../entitlement/question_allowance.dart';

/// LA PROMESSA DELLA REGISTRAZIONE, in una casa sola. Ordine BH voce 01.
///
/// Parole del fondatore: "all'atto della prima registrazione inserire il
/// premio [in Eos] proprio scritto nell'invito a registrarsi, cosi'
/// l'utente e' piu' motivato". Il numero e' del SERVER (viaggia nel listino
/// della registrazione con lo stato del Cerchio): qui lo si legge e lo si
/// scrive, e quando il server non ha ancora parlato la promessa resta viva
/// ma senza numero, perche' un numero inventato e' una bugia in attesa.
///
/// La frase dice "prima registrazione" ed e' esatta anche per chi ha gia'
/// consumato il benvenuto con la stessa email in passato: per quella email
/// la prima registrazione c'e' gia' stata, e la lapide del server (BH.05)
/// non paghera' una seconda volta.
class PromessaDellaRegistrazione {
  const PromessaDellaRegistrazione._();

  /// La riga da mostrare negli inviti a registrarsi.
  static String frase(BuildContext context) {
    final premio = _premio(context);
    if (premio == null) {
      return 'E alla prima registrazione il Cerchio ti fa un dono di '
          'benvenuto in Eos.';
    }
    return 'E alla prima registrazione il Cerchio ti dona $premio Eos.';
  }

  /// La forma corta, per i sottotitoli del menu.
  static String fraseCorta(BuildContext context) {
    final premio = _premio(context);
    if (premio == null) return 'Alla prima registrazione, un dono in Eos';
    return 'Alla prima registrazione, $premio Eos in dono';
  }

  static int? _premio(BuildContext context) {
    // La borsa si legge con prudenza: queste righe compaiono anche su
    // alberi parziali (le prove, l'onboarding), e pretendere il provider
    // da un servizio condiviso ha gia' fatto cadere quaranta prove una
    // volta. Senza borsa la promessa resta senza numero.
    try {
      return context.watch<QuestionAllowance>().premioDellaRegistrazione;
    } catch (senzaProvider) {
      return null;
    }
  }
}
