/// LA LEGGE: IL RESPONSO PARTE DALLA DOMANDA. Ordine S voce 15.
///
/// **Il difetto che questa legge chiude.** Oggi il responso descrive il simbolo,
/// cioe' spiega cos'e' Uruz. La persona che ha appena posto una domanda vuole
/// sapere cosa le dice Uruz sulla SUA domanda. E' la ragione per cui accorciare
/// non basta: dimezzare un testo che parla della cosa sbagliata produce un testo
/// sbagliato piu' corto.
///
/// **La legge vive in un punto solo, nominata, e le arti la applicano.** Non e'
/// una raccomandazione in un documento: e' un oggetto del codice che si legge e
/// si cita, cosi' una prova puo' chiedere a chi la applica se la sta applicando.
library;

/// LA LEGGE DEL RESPONSO, in tre articoli e nessuno di piu'.
class LeggeDelResponso {
  const LeggeDelResponso._();

  /// PRIMO: a chi parla il responso.
  ///
  /// Alla persona e alla sua domanda, in seconda persona, con parole di uso
  /// comune. Non al simbolo, e non a un lettore generico.
  static const String primo =
      'Ogni responso si rivolge alla persona e alla sua domanda, in seconda '
      'persona, con parole di uso comune.';

  /// SECONDO: dove sta il simbolo.
  ///
  /// DOPO, per spiegare da dove viene la risposta. Mai prima, come oggetto del
  /// discorso: la runa, la carta e il transito sono la FONTE della risposta, non
  /// il suo argomento.
  static const String secondo =
      'Il simbolo entra dopo, per spiegare da dove viene la risposta. Mai '
      'prima, mai come oggetto del discorso.';

  /// TERZO: cosa succede senza domanda.
  ///
  /// Il responso parla alla giornata della persona, mai al simbolo in astratto.
  /// Una persona che apre un rito senza chiedere niente non e' una persona che
  /// vuole una lezione di simbologia.
  static const String terzo =
      'Se la persona non ha posto una domanda, il responso parla alla sua '
      'giornata, mai al simbolo in astratto.';

  /// I tre articoli in fila, per chi deve mostrarli o mandarli a un modello.
  static const List<String> articoli = [primo, secondo, terzo];

  /// La legge in un blocco di testo, per le istruzioni di sistema del modello.
  ///
  /// **Una porta sola**: le istruzioni non riscrivono la legge con parole loro,
  /// la leggono da qui. Due copie della stessa legge divergono al primo
  /// ritocco, e a quel punto il corpus e il modello obbediscono a due leggi.
  static String get perIlModello =>
      'LA LEGGE DEL RESPONSO, NON NEGOZIABILE:\n'
      '${articoli.map((a) => '- $a').join('\n')}';
}
