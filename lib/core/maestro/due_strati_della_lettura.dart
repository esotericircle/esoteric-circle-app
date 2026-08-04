/// LA LETTURA HA DUE STRATI, E UNA GENERAZIONE SOLA.
///
/// **Cosa faceva prima, e quanto costava.** "Vai piu' a fondo" buttava via la
/// risposta appena letta e ne chiedeva un'altra al Maestro, con tutta l'attesa
/// da capo. La freccia in giu' prometteva "qui sotto c'e' altro testo": vera
/// come intenzione, falsa come funzionamento, perche' sotto non c'era ancora
/// niente.
///
/// **Il conto, misurato il 3 agosto 2026 su dieci risposte vere.** Ingresso
/// 1807 token mediani, uscita 116. Due chiamate costano 1807+116 e poi
/// 1807+350, una sola costa 1807+350: l'ingresso e' il 94 per cento della
/// spesa, quindi togliere la seconda chiamata vale piu' di quanto costi
/// l'uscita piu' lunga. Non e' una stima, sono i numeri di `usageMetadata`.
///
/// **E il secondo testo non puo' piu' contraddire il primo**, perche' non e'
/// un secondo testo: e' lo stesso, letto piu' giu'.
library;

/// I due strati di una lettura, ricavati dal testo che il Maestro ha scritto.
///
/// Lo strato breve e' un PREFISSO del lungo, non una seconda versione: e' la
/// sola forma che rende impossibile a un estratto dire qualcosa che l'intero
/// non dice. Chi rivela non legge un testo nuovo, continua quello che stava
/// leggendo.
abstract final class DueStratiDellaLettura {
  /// Quante parole legge chi non ha ancora toccato la freccia.
  ///
  /// **Cinquanta, ed e' il numero gia' tarato.** Veniva da due misure su
  /// risposte vere: chiedendone novanta la mediana e' stata 94, chiedendone
  /// sessanta e' stata 80. Cinquanta e' il punto in cui la mediana attesa cade
  /// sotto le ottanta parole decise dal fondatore. Qui non si chiede piu' al
  /// modello di stare corto, si taglia il suo testo: la misura resta quella,
  /// perche' e' la lunghezza che una persona legge senza sentirsi addosso un
  /// muro, e quella non dipende da chi ha scritto.
  static const int paroleDelPrimoStrato = 50;

  /// Quante parole devono avanzare perche' valga la pena rivelare.
  ///
  /// Sotto questa soglia il secondo strato sarebbe una riga o due, cioe' una
  /// freccia che promette e mantiene pochissimo, che e' un altro modo di non
  /// mantenere. Dieci parole sono circa una frase intera.
  static const int paroleMinimeDelSecondo = 10;

  /// I segni con cui una frase italiana finisce.
  static const List<String> fineDiFrase = ['.', '!', '?', '…', ':'];

  /// Il primo strato: il prefisso del testo, chiuso all'ultima frase intera
  /// prima delle [paroleDelPrimoStrato] parole.
  ///
  /// **Si taglia a fine frase, mai a meta'.** E' la stessa regola per cui al
  /// Maestro si chiede di non lasciare mai una frase aperta: un testo troncato
  /// a meta' parola non e' uno strato, e' un guasto. Se nessuna frase finisce
  /// entro la misura, si tiene la prima frase intera qualunque sia la sua
  /// lunghezza, perche' meglio uno strato lungo di uno spezzato.
  static String breve(String intero) {
    final testo = intero.trim();
    if (testo.isEmpty) return testo;

    var parole = 0;
    var ultimaFine = -1;
    var primaFine = -1;
    for (var i = 0; i < testo.length; i++) {
      if (testo[i] == ' ') parole++;
      if (!fineDiFrase.contains(testo[i])) continue;
      // Il punto va contato come fine solo se dopo c'e' uno spazio o la fine
      // del testo: altrimenti "3.5" o "ecc." spezzerebbero la frase.
      final dopo = i + 1 < testo.length ? testo[i + 1] : ' ';
      if (dopo != ' ' && dopo != '\n') continue;
      if (primaFine < 0) primaFine = i + 1;
      if (parole <= paroleDelPrimoStrato) ultimaFine = i + 1;
    }

    // Nessuna frase finisce entro la misura: si tiene la prima intera.
    if (ultimaFine < 0) ultimaFine = primaFine;
    // Nessuna frase finisce affatto: lo strato e' tutto il testo.
    if (ultimaFine < 0) return testo;
    return testo.substring(0, ultimaFine);
  }

  /// Il resto, cioe' cio' che la freccia rivela. Vuoto quando non c'e' resto.
  static String resto(String intero) {
    final testo = intero.trim();
    return testo.substring(breve(testo).length).trim();
  }

  /// Vero quando la freccia ha davvero qualcosa da mostrare.
  ///
  /// Una freccia che non rivela niente e' decorazione, e la decorazione che
  /// somiglia a un comando e' peggio di nessun comando.
  static bool ceUnSecondoStrato(String intero) {
    final avanza = resto(intero);
    if (avanza.isEmpty) return false;
    return avanza.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).length >=
        paroleMinimeDelSecondo;
  }

  /// Cosa si mostra, dato il testo e se la persona ha gia' rivelato.
  ///
  /// Un punto solo: la bolla della chat non decide da sola dove tagliare, e
  /// nessuna seconda superficie puo' tagliare in un altro punto.
  static String daMostrare(String intero, {required bool rivelato}) =>
      rivelato || !ceUnSecondoStrato(intero) ? intero.trim() : breve(intero);
}
