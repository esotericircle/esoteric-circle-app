/// Com'e' finito un turno con un Maestro.
///
/// E' l'elenco CHIUSO di tutti gli esiti possibili: chi ne aggiunge uno viene
/// costretto dal compilatore a dire se costa una domanda, invece di dimenticarlo.
enum EsitoDelTurno {
  /// Il Maestro ha risposto con la sua voce. E' l'unico esito che costa.
  rispostaVera,

  /// L'app ha messo una lettura al posto della voce, dichiarandolo.
  ripiego,

  /// L'attestazione dell'app non e' riuscita e la chiamata non e' partita.
  erroreDiAttestazione,

  /// Qualunque altro guasto: rete, quota, servizio spento.
  erroreGenerico,

  /// La domanda e' stata rifiutata perche' il limite era gia' raggiunto.
  limiteRaggiunto,

  /// La richiesta apriva una funzione immersiva: il costo vive dentro quella.
  instradamento,
}

/// Quanto costa un turno, e la regola sta QUI.
///
/// **Il dato che ha fatto nascere questa classe.** Il 2 agosto 2026, sul
/// telefono: alle 13:23 la domanda a Medora riceve un ripiego, cioe' nessuna
/// risposta. Alle 13:24 e alle 13:25 Caligo e Aura dicono che per oggi ha
/// finito. **L'unica domanda del giorno se l'era presa un messaggio d'errore.**
///
/// La regola viveva in DUE punti e sbagliava in tutti e due: la chat contava
/// PRIMA di generare, quindi pagava anche i guasti; il Consulta contava a lente
/// risolta, ma la lente poteva essere un ripiego dell'oracolo. Adesso vive qui,
/// e le superfici chiedono invece di decidere: la terza che nascera' domani non
/// potra' sbagliarlo.
class CostoDelTurno {
  const CostoDelTurno._();

  /// Vero se questo esito costa una domanda del giorno.
  ///
  /// Costa SOLO la risposta vera. Non costano il ripiego, l'errore di
  /// attestazione, l'errore generico, il rifiuto per limite gia' raggiunto e
  /// l'instradamento verso una funzione immersiva.
  ///
  /// **Un Riprova riuscito costa**, perche' il Maestro ha risposto davvero, e
  /// il tentativo fallito che lo precede non aveva pagato niente: la persona
  /// paga una domanda per una risposta, mai per un errore.
  static bool consuma(EsitoDelTurno esito) =>
      esito == EsitoDelTurno.rispostaVera;
}
