/// **L'IMPIANTO UNICO CONTRO LE RIPETIZIONI.** Nato nell'ordine DS voce 09
/// dentro la Stesa, generalizzato dall'ordine DT voce 27, 17 settembre 2026.
///
/// **Una domanda sola, qualunque cosa si scelga**: fra candidati gia' messi in
/// ordine di preferenza, il primo che non porta nessuna marca gia' usata. La
/// Stesa lo chiama per non ripetere una figura dentro lo stesso Consiglio, con
/// le forme di una tavola nell'ordine del filo e le figure come marche; l'Arcano
/// dell'Alba lo chiama per non ripetere una parola del giorno o un'apertura
/// dentro il ciclo, con le letture di uno stato nell'ordine dell'utente e le
/// aperture e la parola come marche.
///
/// **Cosa succede quando nessuno e' libero lo decide chi chiama**, perche' e'
/// una scelta di prodotto e non di impianto: la Stesa tiene la forma del filo,
/// l'Alba consegna la lettura meno recente e lo conta. Qui si risponde null.
///
/// **Non aprire una seconda porta.** Due impianti sulla stessa domanda sono la
/// famiglia di difetti che questo progetto paga di piu': chi deve scegliere
/// senza ripetere passa da qui.
abstract final class SceltaSenzaRipetere {
  /// Il primo dei [candidati], nell'ordine in cui arrivano, le cui [marche]
  /// non toccano [usate]; null se nessuno e' libero.
  static T? primoLibero<T>(
    Iterable<T> candidati,
    Set<String> Function(T) marche,
    Set<String> usate,
  ) {
    for (final c in candidati) {
      if (marche(c).intersection(usate).isEmpty) return c;
    }
    return null;
  }
}
