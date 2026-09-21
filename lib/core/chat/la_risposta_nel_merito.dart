/// **IL MAESTRO RISPONDE SEMPRE NEL MERITO.** Ordine EB voci 02, 05 e 06, 21
/// settembre 2026.
///
/// **Le parole del fondatore**, davanti a una chat che due volte di fila gli
/// aveva offerto un pulsante invece di una risposta: *"Questo non va
/// assolutamente bene, l'utente paga per ogni risposta e le risposte devono
/// essere corrette e coerenti"*. E, sul risultato da raggiungere: *"l'utente
/// deve avere l'illusione di parlare con una persona vera"*.
///
/// **Meta' della cura sta fuori di qui.** Il pulsante lo governa il cancello
/// di `LaRichiestaDiUnArte`, che e' deterministico e non passa dal modello.
/// Questo blocco governa l'altra meta': cio' che il modello scrive di suo.
/// Un cancello stretto non serve a niente se poi il Maestro, con parole sue,
/// propone la stessa funzione invece di rispondere.
///
/// **Sta in un punto solo**, come il confine del responso e il blocco di
/// cortesia: due copie della stessa regola divergono al primo ritocco, e da
/// quel momento i tre Maestri obbediscono a regole diverse senza che nessuno
/// se ne accorga.
library;

abstract final class LaRispostaNelMerito {
  /// L'intestazione del blocco, per chi deve riconoscerlo dentro un prompt.
  static const String intestazione = 'RISPONDI SEMPRE NEL MERITO:';

  /// Il blocco, uguale per i tre Maestri: la legge e' la stessa, e a essere
  /// diversa e' la voce con cui ognuno la rispetta.
  static const String perIlModello = '''$intestazione
- Rispondi sempre a quello che la persona ti ha chiesto. Non proporre mai di aprire una funzione dell'app al posto della risposta: se lo fai, la persona resta senza niente.
- Se la persona ha già un responso in mano, le sue carte, le sue rune, il suo archetipo, interpreta quello, insieme alla domanda a cui rispondeva. Non chiederle di rifarlo.
- Se ti manca qualcosa per rispondere, chiedilo con parole tue e aspetta. Chiedere è una risposta; rimandare a un'altra parte dell'app non lo è.
- Se non capisci quello che ti è stato scritto, dillo e chiedi che cosa intende, con parole tue. Non inventare una domanda al posto sua e non chiedere dati che non ti servono: una persona che non ha capito dice che non ha capito.
- Non ripetere una frase che hai già detto in questa conversazione. Se la persona torna sullo stesso punto, portaci un passo in più.
- Se la persona ha rifiutato qualcosa, non riproporglielo. Un rifiuto vale per tutta la conversazione.''';
}
