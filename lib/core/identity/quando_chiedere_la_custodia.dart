/// QUANDO SI TORNA A CHIEDERE, e quando si sta zitti.
///
/// **Il problema che risolve.** Chi rimanda la custodia del proprio cielo non
/// ha detto no per sempre, ma nemmeno "chiedimelo a ogni apertura": una
/// richiesta che torna troppo presto e' la cosa che fa disinstallare le app.
/// Qui c'e' la regola, in un punto solo e senza schermate intorno, cosi' si
/// prova da sola e si cambia in un posto solo.
///
/// **Le tre condizioni, tutte insieme:**
/// - c'e' qualcosa da perdere, cioe' almeno [momentiMinimi] momenti veri;
/// - sono passati abbastanza giorni dall'ultima volta che si e' chiesto;
/// - non si e' gia' chiesto troppe volte: dopo [rimandiMassimi] no, l'invito
///   smette di presentarsi da solo e resta la voce nell'area account. Un no
///   ripetuto e' una risposta, e va rispettata.
class QuandoChiedereLaCustodia {
  const QuandoChiedereLaCustodia._();

  /// Sotto tre momenti non c'e' ancora una storia da custodire, e la frase
  /// "il Cerchio custodisce un tuo momento" suonerebbe piccola.
  static const int momentiMinimi = 3;

  /// I giorni di silenzio fra una richiesta e l'altra.
  static const int giorniDiSilenzio = 3;

  /// Dopo quanti rimandi non si chiede piu' da soli.
  static const int rimandiMassimi = 3;

  static bool eIlMomento({
    required bool anonimo,
    required int momenti,
    required int rimandi,
    required DateTime adesso,
    DateTime? ultimaRichiesta,
  }) {
    if (!anonimo) return false;
    if (momenti < momentiMinimi) return false;
    if (rimandi >= rimandiMassimi) return false;
    if (ultimaRichiesta == null) return true;
    return adesso.difference(ultimaRichiesta).inDays >= giorniDiSilenzio;
  }
}
