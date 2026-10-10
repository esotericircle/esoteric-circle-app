/// La profondita' di una consultazione, nel confine AI: la versione neutra e
/// senza UI di `AnswerDepth`, cosi' il provider sceglie modello, tetto di token
/// e ragionamento senza dipendere da un widget.
///
/// Due voci, come vuole lo spec: [breve] e [profonda]. Il gradino intermedio di
/// `AnswerDepth` resta latente nella UI e qui non serve.
enum ConsultDepth {
  /// Risposta breve e densa, per il Free e la Demo.
  breve,

  /// Risposta adattiva, lunga quanto serve fino al tetto, del Cerchio Premium.
  profonda,
}
