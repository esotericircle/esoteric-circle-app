/// **UN MAESTRO NON PARLA DA PROGRAMMA.** Ordine EN voce 06, 25 settembre
/// 2026.
///
/// **Il fatto, dal collaudo con Gemini vero** (`docs/collaudo/EN/risposte/`):
/// alla richiesta di riprovare, in tre giri su sei un Maestro ha risposto come
/// un programma che spiega se stesso. Medora, sul codice della 2281: *"Il mio
/// sistema mi dice che ho già risposto a questa domanda"*. Calìgo, nel terzo
/// giro: *"la risposta precedente è stata inviata per errore"*. Calìgo,
/// nell'ultimo giro, con la regola *"sei un Maestro, non un programma"* gia'
/// scritta nell'istruzione: *"Non ho memoria delle conversazioni precedenti,
/// salvo l'ultima riga con ✦"*. La regola ha abbassato il conto, non l'ha
/// portato a zero.
///
/// **Qui la si guarda a valle**, come la risposta ripetuta: se la risposta
/// parla di se' come di un sistema, di una memoria che non ha o di messaggi
/// inviati, il controller la chiede di nuovo, una volta sola, nominando al
/// modello la risposta da non dare.
///
/// **I segni sono frasi, non parole.** "Sistema" e "memoria" stanno anche in
/// risposte buone (*"il sistema nervoso"*, *"la memoria del corpo"*), e un
/// Maestro che dice *"nelle nostre conversazioni precedenti mi hai parlato di
/// Argo"* sta facendo la cosa giusta (voce EN.09): si cercano soltanto le
/// frasi con cui un programma parla di se'.
///
/// **E non si cerca "intelligenza artificiale"**, di proposito: a chi chiede
/// sinceramente se sta parlando con un'intelligenza artificiale il Maestro
/// non deve mentire, e una rete che gli toglie quelle parole lo spingerebbe a
/// farlo.
abstract final class LaRispostaDaProgramma {
  /// Le frasi di un programma che parla di se'.
  static final RegExp segni = RegExp(
    r'il mio sistema|'
    r'non ho memoria delle (?:conversazioni|sessioni|chat)|'
    r'non ho accesso (?:alle|ai|a)|'
    r'inviat[ao] per errore|'
    r"(?:risposta|messaggio) precedente (?:è|e') stat[ao] inviat|"
    r'riga con ✦',
    caseSensitive: false,
  );

  /// La frase da programma nella risposta, o null se non ce n'e'.
  static String? segno(String risposta) => segni.firstMatch(risposta)?.group(0);
}
