/// **IL RESPIRO CHE DIRADA, e vale per tutte le nebbie del Cerchio.**
/// Ordine DG voce 05, 11 settembre 2026.
///
/// **Da dove vengono questi cinque numeri.** Dal Sigillo del Sogno, dove il
/// diradamento col fiato e col dito esiste dall'ordine P ed e' l'unico che il
/// fondatore abbia approvato guardandolo: *"il sigillo del sogno che il
/// diradamento e' fatto bene"*. Il Viaggio invece chiedeva **tre tocchi**, e
/// il fondatore li ha contati.
///
/// **Perche' stanno qui e non in ognuna delle due schermate.** Perche' due
/// copie della stessa taratura si separano alla prima ritoccata, e allora una
/// delle due nebbie si dirada in un modo e l'altra in un altro: e' la famiglia
/// delle due porte, in forma di numero.
abstract final class RespiroCheDirada {
  /// Ogni quanto il respiro fa un passo.
  static const Duration passo = Duration(milliseconds: 60);

  /// Quanto si apre a ogni passo, se il dito si sta muovendo abbastanza.
  static const double quantoApre = 0.035;

  /// Quanto si richiude a ogni passo, se il dito si e' fermato.
  static const double quantoRichiude = 0.004;

  /// Sotto questa spinta il dito non conta come movimento.
  static const double spintaMinima = 0.10;

  /// Quanto cala la spinta a ogni passo: **fermarsi non tiene aperto.**
  static const double quantoCalaLaSpinta = 0.06;

  /// **QUANTO VALE UN MOVIMENTO DEL DITO.** La distanza percorsa si divide
  /// per questo numero, quindi novanta punti di dito valgono spinta piena.
  static const double quantiPuntiPerUnaSpinta = 90;

  /// La spinta dopo un movimento di [distanza] punti.
  static double spintaDopo(double spinta, double distanza) =>
      (spinta + distanza / quantiPuntiPerUnaSpinta).clamp(0.0, 1.0);

  /// L'apertura al passo successivo, e la spinta che resta.
  static (double apertura, double spinta) unPasso(
      double apertura, double spinta) {
    var aperta = apertura;
    if (spinta > spintaMinima) {
      aperta = (apertura + quantoApre).clamp(0.0, 1.0);
    } else if (apertura > 0 && apertura < 1) {
      aperta = (apertura - quantoRichiude).clamp(0.0, 1.0);
    }
    return (aperta, (spinta - quantoCalaLaSpinta).clamp(0.0, 1.0));
  }
}
