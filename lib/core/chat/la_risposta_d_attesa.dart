import '../maestro/consiglio_finale.dart';

/// **LA RISPOSTA CHE DICE SOLO DI ASPETTARE.** Ordine EQ voce 03, 27
/// settembre 2026.
///
/// **Il fatto, dalle catture del fondatore**: nel LIVE, a *"Ok, le ho scritte
/// e adesso cosa faccio?"*, Calìgo risponde *"Il tuo gesto è compiuto. Ora
/// lascia che il tempo faccia il suo corso."*; a *"Ok, gli ho scritto
/// adesso."*, *"Hai fatto un passo. Ora attendi la sua risposta."*. Non dice
/// niente, e il fondatore l'ha scritto: *"C'è un grosso problema con le chat
/// e sono incazzato nero!"*.
///
/// **La regola nell'istruzione non basta**, ed e' misurato: nella seconda
/// sonda del collaudo (`docs/collaudo/EQ/eq03/sonda_2/`), con la regola
/// "«aspetta» da solo non è una risposta" gia' scritta, Calìgo con Flash ha
/// risposto alla stessa domanda *"Ora il tuo compito è la pazienza. Non
/// forzare l'esito, lascia che il tempo riveli il suo disegno."*. Qui la si
/// guarda a valle, come la risposta ripetuta e quella da programma: il
/// controller la chiede di nuovo, una volta sola, nominando al modello la
/// risposta da non dare.
///
/// **Si guardano le prime due frasi del corpo**, cioe' la risposta: la riga
/// con ✦ resta fuori, e una frase d'attesa in fondo a una risposta concreta
/// non la rende vuota. **E l'attesa misurata passa**: *"Aspetta sette giorni
/// prima di scrivergli di nuovo"* dice quanto, ed e' un passo.
///
/// **I segni sono frasi, non parole**, come per la risposta da programma:
/// "attendi" o "pazienza" stanno anche in risposte buone.
abstract final class LaRispostaDAttesa {
  /// Le frasi di un'attesa senza misura, quelle delle catture e delle sonde.
  static final RegExp segni = RegExp(
    r"(?:il tuo |il )?gesto (?:è|e') compiuto|"
    r'lascia(?:re)? che (?:il tempo|le cose)|'
    r'\b(?:resta|rimani|restare|rimanere) in attesa\b|'
    r'\b(?:un|il) (?:momento|tempo) di (?:pazienza|attesa)\b|'
    r'il tempo (?:farà|dirà|rivelerà|porterà|ti dirà)|'
    r"il tempo (?:è|e') di attesa|"
    r'(?:^|[.!?]\s+|,\s*)(?:ora|adesso),? (?:attendi|aspetta)\b|'
    r'\battendi (?:la|una) (?:sua )?risposta|'
    r'(?:attendi|aspetta) (?:con pazienza|con serenità|senza fretta|'
    r'senza aspettative|il momento propizio)|'
    r"il tuo compito (?:è|e') la pazienza|"
    r"la pazienza (?:è|e') la tua (?:migliore )?alleata|"
    r"non (?:forzare|spingere) (?:l'esito|il fiume|i tempi|gli eventi|"
    r"le cose)|"
    r'ascolta il tempo',
    caseSensitive: false,
  );

  /// Un'attesa con la sua misura: quanto, oppure entro quando.
  static final RegExp misura = RegExp(
    r'\b(?:\d+|un|una|due|tre|quattro|cinque|sei|sette|otto|nove|dieci|'
    r'quindici|venti|trenta) (?:giorn[oi]|settiman[ae]|or[ae]|mes[ei]|'
    r'nott[ei])\b|\bentro\b',
    caseSensitive: false,
  );

  /// Le prime due frasi del corpo della risposta, senza la riga con ✦.
  static String primeDueFrasi(String risposta) {
    final corpo = ConsiglioFinale.corpoDa(risposta);
    final prima = ConsiglioFinale.primaFraseDi(corpo);
    final resto = corpo.substring(prima.length).trim();
    return '$prima ${ConsiglioFinale.primaFraseDi(resto)}'.trim();
  }

  /// La frase d'attesa senza misura nelle prime due frasi, o null se non ce
  /// n'e'.
  static String? segno(String risposta) {
    final testa = primeDueFrasi(risposta);
    if (misura.hasMatch(testa)) return null;
    return segni.firstMatch(testa)?.group(0)?.trim();
  }
}
