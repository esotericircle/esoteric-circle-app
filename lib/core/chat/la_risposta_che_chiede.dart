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
  /// Le parole con cui un Maestro chiede **prima di poter rispondere**.
  ///
  /// **E' un elenco chiuso, e va detto che lo e'.** Un elenco chiuso dice la
  /// verita' su ieri e non su domani: se un Maestro imparera' a chiedere con
  /// parole nuove, qui non ci saranno. **Lo si accetta solo per l'asimmetria
  /// dichiarata sopra**, in dubbio non si paga. Queste voci vengono dalle
  /// risposte vere del collaudo del 23 settembre 2026, una per Maestro.
  static final _chiesteGiaViste = RegExp(
    r'\b(riformul\w*|chiaris\w*|ho bisogno di|formula una domanda|'
    r'dimmi (?:di piu|cosa|quale)|puoi dirmi)\b',
    caseSensitive: false,
  );

  /// La riga del gesto con cui ogni risposta si chiude, dalla stella in poi.
  static final _rigaDelGesto = RegExp(r'\n\s*[✦✧✴].*$');

  static bool eUnaDomanda(String testo) {
    final pulito = testo.trim();
    if (pulito.isEmpty) return false;

    // **VIA LA RIGA DEL GESTO PRIMA DI GUARDARE LA FINE.** Ordine EI voce 02,
    // 23 settembre 2026, ed e' il difetto vero.
    //
    // Ogni risposta dei Maestri si chiude con una riga che comincia con la
    // stella, e **quella riga non e' mai una domanda**: e' un'azione. Quindi
    // "si guarda la fine" guardava sempre il gesto, e il chiarimento non
    // scattava **mai** su una risposta vera.
    //
    // La prova che avrebbe dovuto prenderlo si chiamava *"la chiusura col
    // gesto non nasconde la domanda"* e **non metteva nessun gesto**: provava
    // uno spazio in coda e una virgoletta. **Un nome che promette piu' di
    // quello che misura e' peggio di nessuna prova**, perche' chi lo legge
    // smette di cercare.
    final senzaGesto = pulito.replaceAll(_rigaDelGesto, '').trim();
    final corpo = senzaGesto.isEmpty ? pulito : senzaGesto;

    final ultimo = corpo.replaceAll(RegExp(r'[\s"»“”\)\]]+$'), '');
    if (ultimo.isEmpty) return false;
    if (ultimo.endsWith('?')) return true;

    // **E UNA RICHIESTA NON PORTA SEMPRE UN PUNTO INTERROGATIVO.** Nel
    // collaudo del 23 settembre 2026 tutti e tre i Maestri, davanti a un
    // messaggio incomprensibile, hanno chiesto un chiarimento **senza**
    // chiudere con "?": *"puoi riformulare la tua domanda."*, *"ho bisogno di
    // sentire la tua domanda"*, *"Chiarisci il tuo intento, formula una
    // domanda definita."*. Tutti e tre facevano scendere il contatore.
    return _chiesteGiaViste.hasMatch(corpo);
  }
}
