/// IL CARDINALE MINIMO DI UNA GUARDIA. Ordine CL voce 04.
///
/// **Il difetto che questa porta uccide, e ne uccide due specie su quattro.**
///
/// Una guardia che gira su un insieme scoperto a esecuzione, cioe' che scorre
/// i sorgenti, i file, le rotte o i widget montati, **diventa VERDE quando
/// quell'insieme e' vuoto**. Non fallisce: non ha niente da controllare,
/// quindi non trova niente di sbagliato, quindi passa. E' la differenza fra
/// una prova che asserisce su un VALORE, che se il valore sparisce non
/// compila, e una che asserisce su un INSIEME, che se l'insieme si svuota
/// tace.
///
/// **Nell'ordine CI ne sono state trovate quattro cosi', per caso, mentre si
/// lavorava ad altro.** Tutte e quattro erano verdi. Erano verdi perche' la
/// cosa che dovevano misurare era assente, e **l'assenza non fa rumore**.
///
/// **Le due specie che questa riga uccide.**
///
/// - **Vuota per costruzione**: l'insieme e' vuoto dall'inizio, il ciclo non
///   esegue nessuna asserzione. Con un cardinale dichiarato diventa rossa
///   subito, il giorno che nasce.
/// - **Degradata**: era viva, e una modifica successiva le ha tolto il
///   bersaglio. Senza cardinale diventa muta e nessuno se ne accorge per
///   ordini interi; col cardinale cade **dentro lo stesso lavoro che l'ha
///   causata**, che e' il solo momento in cui costa poco ripararla.
///
/// **Il numero non e' un'opinione.** E' quello che la guardia trova oggi, meno
/// un margine dichiarato: si scrive accanto alla misura e mai dentro la
/// logica, perche' una soglia nascosta dentro un ciclo e' una soglia che
/// nessuno rilegge.
///
/// **E il messaggio dice la cosa giusta.** Quando cade, non dice "il contenuto
/// e' sbagliato": dice **che l'insieme si e' svuotato**, perche' sono due
/// guasti diversi e chi legge deve sapere quale dei due sta guardando.
///
/// **Perche' non usa `expect`.** Lo usava, fino al 1 settembre 2026. Poi due
/// guardie hanno chiamato la porta comune al livello di `main()`, per
/// calcolare il corpus una volta sola prima dei loro `test()`, **che e' un
/// modo legittimo di scrivere una prova**, e sono morte al caricamento con un
/// `OutsideTestException` senza messaggio: `expect` vive solo dentro il corpo
/// di una prova. Un cardinale che funziona in un posto e muore muto
/// nell'altro non e' un cardinale. Qui si solleva [InsiemeSvuotato], che il
/// suo messaggio lo porta con se' in tutti e due i posti.
library;

/// L'insieme su cui una guardia doveva girare si e' svuotato.
///
/// Ha un `toString` che restituisce il messaggio per intero: le eccezioni
/// senza `toString` proprio, al caricamento di una prova, si stampano come
/// "Instance of ..." e portano via con se' la ragione del guasto.
class InsiemeSvuotato implements Exception {
  const InsiemeSvuotato(this.messaggio);

  final String messaggio;

  @override
  String toString() => messaggio;
}

void cardinaleMinimo(
  int quanti,
  int minimo, {
  required String cosa,
  String? perche,
}) {
  if (quanti >= minimo) return;
  throw InsiemeSvuotato('QUESTA GUARDIA HA GUARDATO $quanti $cosa, e ne '
      'pretende almeno $minimo.\n'
      'Non e\' il contenuto a essere sbagliato: **e\' l\'insieme che si e\' '
      'svuotato**, e una guardia che gira su un insieme vuoto e\' verde senza '
      'aver controllato niente.\n'
      '${perche ?? ''}'
      '\nO il bersaglio e\' stato tolto da un lavoro recente, e allora la '
      'cosa da riparare e\' quella; oppure e\' stato spostato, e allora '
      'questa guardia va portata dove e\' andato. In nessuno dei due casi si '
      'abbassa questo numero per farla tacere.');
}
