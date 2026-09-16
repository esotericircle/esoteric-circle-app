/// **QUANDO IL MONDO DI SOTTO NON PARLA, L'APP LO DICE.**
/// Ordine DR voce 07, 16 settembre 2026.
///
/// **Il fatto, dal fondatore**: una discesa con la domanda scritta a mano,
/// *"quando mi sposerò?"*, ha dato quattro strati che parlavano d'attesa e
/// mai di matrimonio. *"Sembra una risposta di ripiego per quattro volte."*
/// Ed era esattamente quello: quando le guardie scartano la riga del modello,
/// il responso lo scrive la voce di casa, che parla del **tema** e non della
/// domanda.
///
/// **La decisione dell'ordine**: a chi ha scritto una domanda sua non si dà
/// più un testo di casa travestito da risposta. Se dopo tre tentativi non
/// passa niente, o se la rete non c'è, la persona legge che oggi il Mondo di
/// Sotto non ha parlato, **e la discesa non si consuma**: il cammino resta
/// dov'era e si può riprovare.
///
/// **È la legge 4 del documento RETENTION applicata al Viaggio**: quando non
/// c'è niente di vero da dire, non si dice niente. Un'app che tace è più
/// credibile di una che riempie.
///
/// **Vale solo per la domanda scritta a mano.** Chi sceglie un tema dalla
/// tavola ha chiesto proprio quello, e la voce di casa che parla di quel tema
/// gli risponde davvero; chi scende senza domanda non ha una domanda a cui
/// mancare.
abstract final class IlSilenzioDelMondoDiSotto {
  /// La riga grande, quella che dice cosa è successo.
  static const String titolo = 'Oggi il Mondo di Sotto non ha parlato';

  /// **COSA È SUCCESSO, senza incolpare la persona e senza fingere.**
  ///
  /// **Nessun participio riferito a chi legge**, regola di casa dall'ordine
  /// DI voce 05: qui c'era *"Sei sceso con la tua domanda"*, che a una donna
  /// diceva di essere un uomo. La domanda è il soggetto, e la marca del
  /// genere non serve.
  static const String spiegazione =
      'La tua domanda è scesa con te e da sotto non è tornato niente che le '
      'somigliasse. Non ti diamo una risposta qualunque al posto della tua.';

  /// **COSA SUCCEDE ADESSO**, ed è la parte che conta: la discesa non è
  /// andata persa.
  static const String cosaResta =
      'La discesa non conta: il tuo cammino è rimasto dov\'era e la domanda '
      'è ancora la tua. Riprova quando vuoi.';

  /// L'etichetta del pulsante che riporta alla soglia.
  static const String siRisale = 'Risali';

  /// Le tre righe in fila, per chi le vuole in una stringa sola.
  static String get tutto => '$titolo. $spiegazione $cosaResta';
}
