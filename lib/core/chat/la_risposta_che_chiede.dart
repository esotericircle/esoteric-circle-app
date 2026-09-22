/// **QUANDO IL MAESTRO CHIEDE INVECE DI RISPONDERE.** Ordine EE voce 07, 23
/// settembre 2026.
///
/// **Decisione del fondatore, verbatim**: *"Chiede lui i dati"*, con
/// l'opzione *"Nessun consumo finche' non risponde davvero"*.
///
/// **IL CANCELLO E' LARGO APPOSTA, e la ragione sta in cosa costa
/// sbagliare.** Un riconoscimento si taglia guardando cosa succede quando
/// non scatta, e qui i due errori non pesano uguale:
///
/// - **non riconoscere un chiarimento** vuol dire far pagare alla persona una
///   risposta che non ha ricevuto, ed e' esattamente il difetto che questa
///   voce cura;
/// - **riconoscerne uno che non c'era** vuol dire non far pagare una risposta
///   vera, cioe' regalarle qualcosa.
///
/// Il primo e' un danno per chi paga, il secondo un danno per noi. **In
/// dubbio, non si paga.**
///
/// **PERCHE' IL PUNTO INTERROGATIVO, che l'ordine EC aveva scartato.**
/// Nell'ordine EC il punto interrogativo era stato provato e bocciato, ma per
/// un mestiere diverso: li' si voleva **giudicare** se il Maestro avesse
/// chiesto, cioe' dire un vero o un falso su cui far cadere un collaudo, e
/// per quello serviva il modello. Qui si decide solo **se far pagare**, con
/// l'asimmetria qui sopra: uno strumento che sbaglia verso il gratis va
/// benissimo, e uno che chiama Gemini a ogni turno per deciderlo costerebbe
/// piu' della domanda che risparmia.
library;

abstract final class LaRispostaCheChiede {
  /// Vero se [testo] e' una domanda rivolta alla persona invece di una
  /// lettura.
  ///
  /// **Si guarda la FINE**, non tutto il testo: un Maestro che risponde nel
  /// merito e in mezzo fa una domanda retorica sta rispondendo, e la sua
  /// risposta si paga. Chi chiede per poter rispondere, invece, chiude
  /// chiedendo, perche' aspetta.
  static bool eUnaDomanda(String testo) {
    final pulito = testo.trim();
    if (pulito.isEmpty) return false;
    // L'ultimo carattere che non sia spazio, virgolette o un segno di
    // chiusura: i Maestri chiudono a volte con una riga di gesto o una
    // virgoletta.
    final ultimo = pulito.replaceAll(RegExp(r'[\s"»“”\)\]]+$'), '');
    if (ultimo.isEmpty) return false;
    return ultimo.endsWith('?');
  }
}
