/// GLI STATI POSSIBILI DI UN SIGILLO NEL JOURNAL. Ordine P voce 21.
///
/// **Perche' un'enumerazione e non una manciata di booleani.** Il gradino del
/// sentiero decideva il suo aspetto da tre booleani sparsi, `acceso`,
/// `prossimo`, `bloccato`, combinati a mente in ogni punto che li leggeva. Con
/// tre booleani gli stati possibili sono otto, ma solo quattro hanno senso, e
/// nessuno poteva enumerarli per verificare che nessuno di loro lasciasse una
/// casella grigia dopo un traguardo raggiunto. Adesso gli stati sono un dato:
/// si contano, si disegnano uno per uno e una prova li attraversa tutti.
///
/// **La contraddizione chiusa dall'ordine P voce 19.** Le Linee Guida UX,
/// sezione 17, dicevano due cose opposte sui Sigilli sospesi. Vale questa: IL
/// SIGILLO SI ACCENDE SEMPRE AL RAGGIUNGIMENTO DEL TRAGUARDO, a prescindere
/// dalla condivisione. La condivisione governa soltanto il bonus in Eos.
enum StatoDelSigillo {
  /// Non ancora raggiunto, e non e' il prossimo: resta leggibile, mai invisibile.
  spento,

  /// Il prossimo da raggiungere: si distingue, perche' e' l'unico che chiede
  /// qualcosa adesso.
  prossimo,

  /// Oltre il piano: si vede, dichiara il perche' e invita, mai un vicolo cieco.
  bloccato,

  /// RAGGIUNTO E ANCORA DA CONDIVIDERE: acceso, con una pulsazione lenta e una
  /// marcatura sua. Il bonus in Eos resta in attesa e si incassa anche
  /// settimane dopo, riaprendo la card.
  sospeso,

  /// Raggiunto e condiviso: acceso e fermo. Il ciclo di quel traguardo e'
  /// chiuso.
  compiuto;

  /// Vero se il traguardo e' stato raggiunto. Il Sigillo si accende qui, non
  /// alla condivisione.
  bool get raggiunto =>
      this == StatoDelSigillo.sospeso || this == StatoDelSigillo.compiuto;

  /// Vero se il Sigillo si accende, cioe' se NON lascia una casella grigia.
  bool get acceso => raggiunto;

  /// Vero se pulsa piano. Solo il sospeso, e solo perche' ha ancora qualcosa
  /// da dare: una pulsazione su un Sigillo che non offre nulla sarebbe rumore.
  bool get pulsa => this == StatoDelSigillo.sospeso;

  /// Vero se al tocco riapre la sua card. Ogni Sigillo acceso lo fa, sospeso o
  /// compiuto: nessun traguardo raggiunto resta senza una via per condividerlo.
  bool get riapreLaCard => raggiunto;

  /// La marcatura che il gradino porta accanto al nome, oppure nulla.
  String? get marcatura =>
      this == StatoDelSigillo.sospeso ? 'Eos in attesa' : null;
}

/// LO STATO DI UN SIGILLO, in un punto solo.
///
/// **Non c'e' nessun magazzino nuovo qui, ed e' una scelta.** La prima stesura
/// apriva uno store suo per ricordare quali Sigilli fossero gia' stati
/// condivisi: `DiarioDelCammino` lo sapeva gia', con `eStatoCondiviso`, e una
/// seconda porta sullo stesso dato e' la famiglia di difetti piu' frequente di
/// questo progetto. Qui vive solo la REGOLA, che e' una funzione pura: chi la
/// chiama porta i quattro fatti che gia' possiede.
class StatoDeiSigilli {
  const StatoDeiSigilli._();

  static StatoDelSigillo di({
    required bool raggiunto,
    required bool condiviso,
    required bool bloccato,
    required bool eIlProssimo,
  }) {
    // IL RAGGIUNGIMENTO VINCE SU TUTTO, e questa riga e' la contraddizione
    // chiusa dalla voce 19: un traguardo raggiunto non torna grigio ne' per il
    // piano ne' perche' non e' stato condiviso.
    if (raggiunto) {
      return condiviso ? StatoDelSigillo.compiuto : StatoDelSigillo.sospeso;
    }
    if (bloccato) return StatoDelSigillo.bloccato;
    return eIlProssimo ? StatoDelSigillo.prossimo : StatoDelSigillo.spento;
  }
}
