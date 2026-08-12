/// I TETTI DI LUNGHEZZA DELLE BOLLE DEL RESPONSO, in un punto solo.
///
/// **Ordine P voce 09.** Il tetto del consiglio e' distinto dagli altri e piu'
/// alto, e sta qui insieme agli altri invece di essere scritto a mano nel punto
/// di chiamata. La ragione e' la stessa per cui i tetti dei token vivono in
/// `MisuraDellaRisposta` e non sparsi nei provider: due numeri che devono
/// restare in rapporto fra loro, scritti in due posti diversi, prima o poi non
/// lo restano piu'.
///
/// **Sono caratteri, non token.** Questi testi non passano dall'LLM: la lettura
/// e' deterministica e cacheabile, cioe' e' esattamente il settanta per cento
/// di richieste che non tocca il modello. Il tetto serve a governare quanto
/// spazio una bolla prende a schermo, non quanto costa.
class TettiDellaStesa {
  const TettiDellaStesa._();

  /// La riga forte sopra le tre carte: una frase, non un paragrafo.
  static const int sintesi = 120;

  /// Una bolla di posizione, col testo ricco della carta letto nell'argomento.
  static const int posizione = 420;

  /// IL CONSIGLIO, LA BOLLA PIU' LUNGA DI TUTTE.
  ///
  /// **E' la bolla che la persona porta via**, quindi e' l'unica a cui si
  /// concede piu' spazio che alle altre. Dentro questo tetto ci stanno il
  /// consiglio del gruppo, le due frasi che poggiano sulle carte uscite e la
  /// domanda di chiusura col suo stacco: misurato sui 16 argomenti per 60 semi
  /// il piu' lungo arriva a 703 caratteri, quindi il tetto tiene margine invece
  /// di stare al filo.
  static const int consiglio = 900;

  /// La domanda di chiusura, che non e' piu' una bolla ma resta un dato: si
  /// salva e ricompare nel dono del mattino dopo.
  static const int domanda = 160;

  /// Tutti gli altri tetti, per la prova che verifica che il consiglio sia
  /// davvero il piu' alto. Enumerare invece di elencare a mano: un elenco
  /// scritto invecchia appena nasce una bolla nuova.
  static const List<int> tuttiTranneIlConsiglio = [sintesi, posizione, domanda];

  /// Tronca [testo] al tetto dato senza spezzare una parola a meta'.
  ///
  /// Non lascia mai una frase mozza con tre punti: taglia all'ultimo confine di
  /// parola dentro il tetto. Un tetto che produce monconi e' peggio di nessun
  /// tetto, ed e' lo stesso principio della misura della risposta dei Maestri.
  static String dentro(String testo, int tetto) {
    if (testo.length <= tetto) return testo;
    final tagliato = testo.substring(0, tetto);
    final ultimo = tagliato.lastIndexOf(' ');
    return (ultimo <= 0 ? tagliato : tagliato.substring(0, ultimo)).trimRight();
  }
}
