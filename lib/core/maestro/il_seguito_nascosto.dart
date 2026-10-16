/// **IL "VAI PIU' A FONDO" SCRITTO INSIEME ALLA RISPOSTA. Ordine EX voce 04.**
///
/// Il fondatore: *"il "vai più a fondo" dovrebbe essere già generato, va solo
/// scoperto, in modo da non fare un'altra chiamata, o sbaglio?"*. Fino a
/// quest'ordine il seguito si chiedeva al tocco, con una seconda chiamata
/// intera (al banco della qualita' 1,45 chiamate a tocco, con l'istruzione,
/// la conversazione e le funzioni del cielo di nuovo). Adesso, per chi ha il
/// "Vai più a fondo" nel piano, il Maestro lo scrive nella stessa risposta,
/// dopo un segno; il controller lo separa prima delle reti e lo tiene
/// nascosto nel messaggio, e al tocco si mostra senza chiamare nessuno.
abstract final class IlSeguitoNascosto {
  /// Il segno fra la risposta e il seguito. Non arriva mai a video: il
  /// controller divide il testo prima di qualunque altra cosa.
  static const String segno = '[[SEGUITO]]';

  /// L'istruzione, in fondo a quella della risposta. Le regole del seguito
  /// sono quelle della richiesta al tocco (`SeguitoDellaLettura.istruzione`),
  /// dette per un seguito che la persona leggera' solo se lo chiede.
  ///
  /// **SEMPRE, E FUORI DALLA RISPOSTA.** Al banco finale dell'ordine EX il
  /// seguito arrivava in 6 risposte su 24: la regola del consiglio finale
  /// dice "chiudi con una riga a sé, l'ultima", e il modello si fermava li'.
  /// L'istruzione dice adesso che il segno e il seguito stanno dopo la
  /// risposta, che l'app li toglie, e che una risposta senza segno e'
  /// incompleta.
  static const String istruzione = 'DOPO LA RISPOSTA, IL SEGUITO DA SCOPRIRE, '
      'SEMPRE.\n'
      'Il tuo testo ha sempre due parti. Prima la risposta, che finisce con la '
      'riga col carattere speciale: quella resta l\'ultima riga della '
      'risposta. Poi, su una riga a sé, soltanto $segno e sotto il seguito: '
      'ciò che diresti se la persona ti chiedesse di scendere più a fondo, '
      'circa centotrenta parole. Il segno e il seguito non fanno parte della '
      'risposta: l\'app li toglie prima di mostrarla e li tiene da parte, la '
      'persona li leggerà solo se lo chiede. Un testo che finisce senza $segno '
      'e il seguito è incompleto. La risposta sopra deve stare in piedi da '
      'sola e non deve annunciare il seguito.\n'
      '- Riprendi da dove hai lasciato, con cose nuove. Non riassumere, non '
      'riformulare, non ripetere con altre parole ciò che hai già detto: chi '
      'rilegge due volte la stessa cosa si sente preso in giro.\n'
      // **COSA PORTA IL SEGUITO.** Al giro finale dell'ordine EX i giudici
      // alla cieca davano il seguito scritto insieme alla risposta peggiore
      // di quello chiesto al tocco (9 contro 13, 7 contro 11 su 24):
      // "generico", "ripete". Le righe dicono adesso che cosa deve esserci.
      '- Porta almeno due cose nuove e concrete sulla stessa domanda, che la '
      'risposta non ha detto: perché la lettura dice così proprio per questa '
      'persona, un secondo passo dopo quello della riga finale (quando, con '
      'chi, come), un dettaglio del simbolo o del cielo che riguarda la sua '
      'situazione. Nessuna frase che andrebbe bene a chiunque.\n'
      '- Resta sulla domanda e sulla risposta data: non cambiare argomento, '
      'non contraddirla, non promettere come andrà.\n'
      '- Riparti dallo stesso ancoraggio e dallo stesso simbolo della '
      'risposta, la runa o la carta o il transito: non nominarne un altro.\n'
      '- Non scrivere un\'altra riga finale col carattere speciale.\n'
      '- Attacca direttamente col contenuto, senza aperture del tipo "come '
      'dicevo" o "riprendendo".';

  /// La risposta e il seguito, divisi al [segno]. Senza segno il seguito e'
  /// nullo e la risposta e' tutto il testo.
  static (String, String?) dividi(String testo) {
    final i = testo.indexOf(segno);
    if (i < 0) return (testo, null);
    final risposta = testo.substring(0, i).trimRight();
    final seguito = testo.substring(i + segno.length).trim();
    return (risposta, seguito.isEmpty ? null : seguito);
  }
}
