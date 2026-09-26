/// **UNA DOMANDA FINITA NON ASPETTA DUE SECONDI.** Ordine EO voce 14, 26
/// settembre 2026.
///
/// Il fondatore: *"nelle chat live bisogna ridurre il tempo in cui la
/// risposta viene scritta e il tempo di risposta del maestro, il più
/// possibile."* Sul Realme, prima di quest'ordine, la frase si chiudeva
/// sempre dopo due secondi di silenzio (ordine EJ voce 01): e' il pezzo piu'
/// lungo dell'attesa, prima ancora della risposta del modello.
///
/// **I due secondi restano la regola**, perche' una pausa per pensare non
/// deve troncare la domanda. Si accorcia soltanto quando la trascrizione
/// cominciata in pausa (ordine EM voce 11) torna con **una domanda gia'
/// finita**: il punto interrogativo alla fine, almeno tre parole. Allora la
/// frase parte dopo [silenzioMinimo] di silenzio invece di due secondi. Chi
/// fa una pausa a meta' domanda non ha ancora un punto interrogativo, e chi
/// dice una frase senza domanda resta sui due secondi.
abstract final class LaDomandaFinita {
  /// Il silenzio che basta dopo una domanda finita.
  static const Duration silenzioMinimo = Duration(milliseconds: 1300);

  /// Le parole che una domanda finita deve avere almeno.
  static const int paroleMinime = 3;

  /// Vero se [testo], trascritto in pausa, e' una domanda gia' finita.
  static bool eFinita(String testo) {
    final t = testo.trim();
    if (!t.endsWith('?')) return false;
    final parole = t
        .replaceAll('?', ' ')
        .split(RegExp(r'\s+'))
        .where((p) => RegExp(r'[A-Za-zÀ-ÿ]').hasMatch(p))
        .length;
    return parole >= paroleMinime;
  }

  /// Quanto manca ancora da aspettare, dato il silenzio gia' passato.
  static Duration daAspettare(Duration silenzioPassato) {
    final resto = silenzioMinimo - silenzioPassato;
    return resto.isNegative ? Duration.zero : resto;
  }
}
