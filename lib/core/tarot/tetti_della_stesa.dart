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
  /// concede piu' spazio che alle altre. Dentro questo tetto ci stanno la lente
  /// dell'argomento, la RISPOSTA del gruppo, l'AZIONE del gruppo, le due frasi che
  /// poggiano sulle carte uscite e la domanda di chiusura col suo stacco.
  ///
  /// **RIMISURATO DOPO LA VOCE S.26, e il numero vecchio era diventato falso.** Il
  /// commento diceva 703 caratteri di caso peggiore: era la misura PRIMA che la
  /// parte 1 dell'anatomia entrasse nel consiglio. Con la risposta dentro, il piu'
  /// lungo arriva a **884 caratteri** (argomento "nuovoIncontro", seme 131), e il
  /// tetto vecchio di 900 lasciava **16 caratteri di margine**: stava al filo,
  /// mentre il commento continuava a dire che il margine c'era.
  ///
  /// **IL CAMPIONE NON DIPENDE PIU' DAL CAMPIONE.** Sui 16 argomenti per 60 semi il
  /// peggiore e' 877; a 200 semi sale a 884 e a 500 semi resta 884, cioe' il numero
  /// ha smesso di muoversi. Il vecchio 703 era misurato su 60 semi soli, ed e' una
  /// delle ragioni per cui era ottimista.
  ///
  /// **IL TETTO NUOVO E' 1100**, che tiene 884 piu' un margine del 24 per cento. Non
  /// e' il caso peggiore arrotondato: e' il caso peggiore piu' lo spazio perche' una
  /// frase in piu' del corpus non faccia troncare la bolla il giorno che viene
  /// scritta.
  static const int consiglio = 1100;

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
