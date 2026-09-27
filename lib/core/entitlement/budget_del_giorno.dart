import 'tier.dart';
import 'question_allowance.dart';

/// I BUDGET DEL GIORNO, IN UN ELENCO SOLO. Ordine CE voce 04.
///
/// **Le parole del fondatore, verbatim:** "in sinastria vip, non avevo chiesto
/// che doveva esserci il conteggio delle sinastrie rimaste? l'utente deve
/// Sapere quante ne mancano. ma questo vale per tutte le funzionalita'
/// limitate o dove e' previsto l'acquisto."
///
/// **Perche' un elenco e non sei righe sparse.** Il difetto misurato era
/// esattamente questo: sei budget vivevano in `QuestionAllowance` come sei
/// coppie di metodi senza nessun posto che li tenesse insieme, e cosi' cinque
/// punti su otto non dicevano niente prima del gesto, il foglio del borsellino
/// ne dichiarava quattro su sei, e `sinastrieRimaste` esisteva senza che
/// nessuna schermata la leggesse. **Con un elenco la prova puo' ENUMERARE**, e
/// il punto che nasce domani o entra qui dentro o cade.
///
/// **Il residuo si legge dal server e non si scrive mai a mano**, ed e' la
/// legge dell'ordine BG voce 04: `QuestionAllowance` e' cio' che il server ha
/// detto. Quando il limite non c'e' ancora si torna nullo e **si tace**, invece
/// di indovinare un numero.
enum BudgetDelGiorno {
  /// Le domande ai Maestri in chat.
  domande(
    uno: 'domanda ai Maestri',
    molti: 'domande ai Maestri',
    femminile: true,
  ),

  /// Gli approfondimenti, cioe' il "Vai piu' a fondo" sotto una risposta.
  approfondimenti(uno: 'approfondimento', molti: 'approfondimenti'),

  /// I confronti fra i Maestri: la stessa domanda chiesta anche agli altri
  /// due, da "Chiedi anche agli altri" e da "Chiedi ai Maestri".
  ///
  /// **LE PAROLE DICONO FRA CHI, ordine EQ voce 07.** Erano *"confronto"* e
  /// *"confronti"*, e sotto la bolla la riga diceva soltanto *"Oggi te ne
  /// restano 20 su 20"*: accanto a *"Oggi hai 50 domande ai Maestri"* nella
  /// testata il fondatore ha letto due conti della stessa cosa che non
  /// tornavano. Sono due tetti diversi, e adesso lo dicono.
  confronti(uno: 'confronto fra i Maestri', molti: 'confronti fra i Maestri'),

  /// Le gettate di rune.
  gettate(uno: 'gettata di rune', molti: 'gettate di rune', femminile: true),

  /// Le stese di tarocchi a tre carte.
  stese(uno: 'stesa', molti: 'stese', femminile: true),

  /// I confronti di Sinastria con un VIP.
  sinastrie(uno: 'sinastria', molti: 'sinastrie', femminile: true);

  const BudgetDelGiorno({
    required this.uno,
    required this.molti,
    this.femminile = false,
  });

  /// Come si chiama UNA di queste cose, come se ne chiamano tante, e se la
  /// parola e' femminile: senza questi tre l'italiano si rompe, ed e' gia'
  /// successo con "Non ti resta nessun domanda".
  final String uno;
  final String molti;
  final bool femminile;

  /// Il tetto del giorno per questo piano, oppure nullo se non c'e' un conto
  /// da tenere.
  int? limite(QuestionAllowance borsa, Tier tier) => switch (this) {
        BudgetDelGiorno.domande => borsa.dailyLimit(tier),
        BudgetDelGiorno.approfondimenti => borsa.limiteApprofondimenti(tier),
        BudgetDelGiorno.confronti => borsa.limiteConfronti(tier),
        BudgetDelGiorno.gettate => borsa.limiteGettate(tier),
        BudgetDelGiorno.stese => borsa.limiteStese(tier),
        BudgetDelGiorno.sinastrie => borsa.limiteSinastrie(tier),
      };

  /// Quanti ne restano oggi, oppure nullo quando non c'e' un tetto.
  int? rimasti(QuestionAllowance borsa, Tier tier) => switch (this) {
        BudgetDelGiorno.domande =>
          borsa.dailyLimit(tier) == null ? null : borsa.remaining(tier),
        BudgetDelGiorno.approfondimenti => borsa.approfondimentiRimasti(tier),
        BudgetDelGiorno.confronti => borsa.confrontiRimasti(tier),
        BudgetDelGiorno.gettate => borsa.gettateRimaste(tier),
        BudgetDelGiorno.stese => borsa.steseRimaste(tier),
        BudgetDelGiorno.sinastrie => borsa.sinastrieRimaste(tier),
      };

  /// **LA RIGA CHE DICE QUANTO RESTA, e nulla quando non c'e' niente da dire.**
  ///
  /// Nullo vuol dire **tacere**: senza tetto non c'e' un residuo da dichiarare,
  /// e senza risposta del server non si indovina. E' la legge dell'ordine BG
  /// voce 04, che nasce dal giorno in cui una schermata scriveva un numero
  /// suo mentre il server ne aveva un altro.
  String? riga(QuestionAllowance borsa, Tier tier) {
    if (!borsa.dalServer) return null;
    // **E QUI SI TACE DAVVERO, ordine CF voce 11.** La documentazione qui
    // sopra lo dichiarava gia' da due ordini, e il codice non lo faceva: senza
    // la risposta del server la borsa ha comunque i suoi contatori locali, e
    // la riga scriveva quel numero come se fosse il vero. **Fra il codice e il
    // commento vince il fondatore: si tace.**
    final tetto = limite(borsa, tier);
    if (tetto == null) return null;
    final resta = rimasti(borsa, tier);
    if (resta == null) return null;
    return QuestionAllowance.residuoDiCosa(resta, tetto,
        uno: uno, molti: molti, femminile: femminile);
  }
}
