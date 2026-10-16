import 'la_lingua_del_cerchio.dart';

/// IN CHE LINGUA RISPONDE IL MODELLO. Ordine DM voce 04.
///
/// **Il fatto misurato.** Prima di quest'ordine la lingua della risposta era
/// **scritta dentro i prompt**, nove volte in quattro file: *"- Scrivi sempre
/// e solo in italiano."*, *"- I tre campi in italiano"*, *"scrivi UNA riga in
/// italiano"*, *"- Italiano con gli accenti veri"*. Nove righe da trovare e
/// cambiare il giorno della seconda lingua, sparse in quattro file che nessun
/// indice collegava.
///
/// **Qui la lingua della risposta e' un parametro.** Chi scrive un prompt
/// nomina [nome], e il giorno che l'app parlera' un'altra lingua quella parola
/// cambia in un posto solo.
///
/// **E I PROMPT RESTANO IN ITALIANO, ed e' una scelta dichiarata.** Le
/// istruzioni al modello sono scritte in italiano perche' le legge il modello,
/// non una persona: tradurle non servirebbe a nessuno e costerebbe una
/// riscrittura di tutti i corpora di prompt. Cio' che quest'ordine rende
/// parametrico e' **la lingua della risposta**, che e' cio' che una persona
/// legge, non la lingua della domanda.
///
/// **In italiano ogni stringa e' identica al byte a quella di prima.** E' la
/// regola dell'ordine: il comportamento visibile in italiano non cambia di un
/// carattere, e un prompt che cambiasse di una virgola cambierebbe le risposte
/// del modello, che in italiano e' esattamente cio' che si vieta.
abstract final class LaLinguaDelModello {
  /// Come si chiama, **in italiano**, la lingua in cui il modello deve
  /// rispondere. In italiano perche' la frase che la contiene e' in italiano:
  /// *"Scrivi sempre e solo in italiano"*, *"Scrivi sempre e solo in
  /// inglese"*.
  static String get nome => LaLinguaDelCerchio.corrente.value.nomeInItaliano;

  /// Lo stesso nome con l'iniziale grande, per le righe che cominciano con
  /// lui: *"- Italiano con gli accenti veri"*.
  static String get nomeMaiuscolo => nome[0].toUpperCase() + nome.substring(1);

  /// La riga che dice al modello in che lingua scrivere, nella forma piu'
  /// usata. Le altre sette occorrenze hanno frasi proprie e nominano [nome].
  static String get laRiga => '- Scrivi sempre e solo in $nome.';

  /// La stessa riga, con la richiesta degli accenti. **Vale solo dove la
  /// lingua ne ha**: in inglese la frase resta comprensibile e innocua, e il
  /// giorno che si aggiungera' una lingua senza accenti si decidera' qui, in
  /// un posto solo, invece che in tre prompt lontani.
  static String get laRigaConGliAccenti =>
      '- Scrivi sempre e solo in $nome, con accenti veri.';

  /// **IL GENERE DEI NOMI DELLE CARTE.** Ordine EE voce 10, 23 settembre
  /// 2026.
  ///
  /// **Il fatto del fondatore, sulla cattura del Consiglio**: Caligo scriveva
  /// *"la Tre di Denari"* e *"La Tre di Coppe"*. Il numero di una carta e'
  /// maschile: **il** Tre di Denari, **il** Dieci di Spade, **l'**Asso di
  /// Coppe.
  ///
  /// **Nessuna regola lo diceva**, e il modello tirava a indovinare: "carta"
  /// e' femminile, "tre" no, e in italiano la concordanza la decide il numero
  /// che fa da nome. L'app il genere lo sa da se' dove scrive lei
  /// (`ReversedAgreement` in `tarot_card.dart`), ma i Maestri i nomi li
  /// scrivono di loro, e li' non arrivava niente.
  ///
  /// **Vale per tutti e tre i Maestri**, non per il solo Caligo: la carta
  /// puo' comparire in qualunque lettura.
  static const String ilGenereDelleCarte =
      "- I numeri delle carte sono maschili: si scrive «il Tre di Denari», "
      "«il Dieci di Spade», «l’Asso di Coppe», mai «la Tre» o «la Dieci». "
      "Le figure seguono il loro genere: il Re, il Cavaliere, il Fante, "
      "la Regina.";
}
