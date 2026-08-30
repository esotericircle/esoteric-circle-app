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

  /// I confronti nel Cerchio, fra due persone.
  confronti(uno: 'confronto', molti: 'confronti'),

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
        BudgetDelGiorno.approfondimenti =>
          borsa.approfondimentiRimasti(tier),
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
    final tetto = limite(borsa, tier);
    if (tetto == null) return null;
    final resta = rimasti(borsa, tier);
    if (resta == null) return null;
    return QuestionAllowance.residuoDiCosa(resta, tetto,
        uno: uno, molti: molti, femminile: femminile);
  }
}
