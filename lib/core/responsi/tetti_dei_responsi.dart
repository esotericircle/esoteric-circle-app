/// I TETTI DEI RESPONSI, in un blocco unico. Ordine S voce 18.
///
/// **I tetti non si scrivono nel punto di chiamata**, e non si scelgono a occhio:
/// nascono dalla tabella misurata in `docs/responsi/lunghezze.md`, e ognuno porta
/// qui accanto il numero da cui viene. Un tetto scritto dove serve e' un tetto che
/// nessuno confronta piu' con la misura.
///
/// **I tetti della stesa di tarocchi NON stanno qui**, e non e' una dimenticanza:
/// vivono in `TettiDellaStesa` da prima di questo ordine, insieme alla funzione che
/// accorcia senza spezzare le parole. Spostarli avrebbe voluto dire toccare quattro
/// numeri verificati per ragioni di ordine, e un blocco nuovo che ne fa una copia
/// sarebbe la famiglia delle due porte. Chi cerca un tetto guarda in due posti
/// dichiarati invece di uno, e i due non si sovrappongono.
library;

/// I tetti nati dall'ordine S.
class TettiDeiResponsi {
  const TettiDeiResponsi._();

  /// IL RESPONSO DI UNA SINGOLA RUNA, NEI DUE VERSI. Ordine S voce 20.
  ///
  /// **Cinquantacinque caratteri: la meta' della mediana misurata**, che era 106
  /// per il verso dritto e 111 per quello d'ombra. Si prende la meta' della piu'
  /// alta delle due, cosi' i due versi condividono UN tetto: due numeri per lo
  /// stesso tipo di testo sarebbero due regole, e la prima volta che una runa le
  /// sfiora entrambe nessuno saprebbe quale vale.
  ///
  /// **Il tetto non taglia: dichiara.** I quarantotto testi sono stati RISCRITTI
  /// per starci dentro, e nella forma breve resta la risposta mentre cade la
  /// descrizione del simbolo, che vive nel campo `meaning` della runa, nella sua
  /// scheda e nel pannello delle fonti. Un testo tagliato e' un testo non scritto,
  /// ed e' gia' costato una voce nell'ordine P.
  static const int runaBreve = 55;
}
