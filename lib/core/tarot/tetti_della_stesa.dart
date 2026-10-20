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
///
/// **DALL'ORDINE GA, voci GA.03 e GA.07, 20 ottobre 2026, le parole stanno in
/// `LaFormaDelResponso` e qui stanno i caratteri.** Il fondatore: *"tutte le
/// risposte composte da paragrafi ognuno con tra 40 a 50 parole ognuno"*. La
/// misura di un paragrafo e' in parole e vive in un punto solo; questi tetti
/// dicono quanto spazio quel paragrafo prende a schermo, e si scrivono dalla
/// misura dei testi nuovi, col margine dichiarato accanto a ciascuno. **Non
/// troncano piu' niente** (GA.07, *"I TESTI RISCRITTI, MAI TRONCATI"*): un
/// testo oltre il tetto e' un difetto del testo, e le prove lo dicono prima
/// che arrivi a schermo.
///
/// **E IL CONSIGLIO NON E' PIU' IL TETTO PIU' ALTO.** Lo era perche' il
/// Consiglio era un blocco di tre paragrafi contro una bolla di uno. Dalla
/// forma nuova ogni paragrafo, del responso principale o di una carta, ha da
/// 40 a 50 parole: il paragrafo di una carta, che viene dal corpus, arriva a
/// 350 caratteri e quello del responso principale di casa a 318. LAPIDE: la
/// prova "il tetto del consiglio e' distinto e piu' alto" (ordine P voce 09,
/// `la_stesa_si_capisce_test.dart`), sostituita da quella che vuole ogni tetto
/// sopra la sua misura col suo margine.
class TettiDellaStesa {
  const TettiDellaStesa._();

  /// La riga forte sopra le tre carte: una frase, non un paragrafo. Misura
  /// del 20 ottobre 2026: la sintesi piu' lunga del mazzo ha 31 caratteri;
  /// l'ordine GA non l'ha toccata e il tetto resta.
  static const int sintesi = 120;

  /// **IL PARAGRAFO DI UNA CARTA**, lo scheletro della posizione piu' il
  /// registro del gruppo (`LeCarteNellaPosizione.letturaDiCasa`), e il suo
  /// "Cosa fare adesso" dal corpus (`LeCarteNellaPosizione.cosaFareDi`).
  /// Ordine GA voce GA.07, misura del 20 ottobre 2026 su **tutte** le
  /// composizioni: 84.240 paragrafi (ogni scheletro di
  /// `scheletriDelleCarte` con ogni registro di `registriDelleCarte`, con
  /// ogni forma di cortesia), il piu' lungo di **350 caratteri**; 5.616 "Cosa
  /// fare" (`cosaFareDelleCarte` con ogni forma di cortesia), il piu' lungo di
  /// 316. Il tetto di prima, 420, tiene il caso peggiore con un margine del
  /// **16,7 per cento**, e resta: la misura lo conferma invece di cambiarlo.
  static const int posizione = 420;

  /// **UN PARAGRAFO DEL RESPONSO PRINCIPALE**, la risposta o il "Cosa fare
  /// adesso". Ordine GA voce GA.07, 20 ottobre 2026.
  ///
  /// **Era il tetto del Consiglio intero**, 1250 caratteri, la bolla piu'
  /// lunga di tutte: tre paragrafi piu' la domanda di chiusura col suo stacco.
  /// La sua storia, ordini P voce 09, S voce 26 e DF: 900, poi 1100 sul caso
  /// peggiore di 884 caratteri, poi 1250 sul caso peggiore di 1056, misurato
  /// su 6.400 composizioni. **La riga di "come si vede se ha funzionato"
  /// restava fuori dal Consiglio** perche' con lei dentro il caso peggiore
  /// passava il tetto e la bolla veniva troncata.
  ///
  /// **Adesso e' il tetto di un paragrafo**, perche' i paragrafi sono due e
  /// ognuno sta fra 40 e 50 parole in ogni composizione. **Il caso peggiore si
  /// calcola e non si campiona**: ogni fessura di `VoceDellaStesa` riempita con
  /// la lente e il nome di carta piu' lunghi in caratteri (*"Sulla decisione da
  /// prendere"*, *"La Ruota della Fortuna rovesciata"*), con ogni marca del
  /// genere, e sommata alle altre. Il paragrafo piu' lungo possibile ha **318
  /// caratteri**, il "Cosa fare adesso" con l'approdo; la risposta 317. Il
  /// paragrafo che scrive il modello sta nella stessa misura in parole
  /// (`LaFormaDelResponso`), e il controllo che lo scarta e' in parole.
  ///
  /// **IL TETTO E' 380**, che tiene 318 piu' un margine del **16,3 per
  /// cento**, lo stesso ordine di grandezza del margine della carta: lo spazio
  /// perche' una forma riscritta un giorno non stia al filo. Lo sorveglia
  /// `il_consiglio_dei_tarocchi_e_la_sua_anatomia_test.dart`, che ricalcola il
  /// caso peggiore e pretende almeno il dieci per cento di margine.
  static const int consiglio = 380;

  /// La domanda di chiusura, che non e' piu' una bolla ma resta un dato: si
  /// salva e ricompare nel dono del mattino dopo. Misura del 20 ottobre 2026:
  /// la piu' lunga delle cinque ha 73 caratteri; l'ordine GA non l'ha toccata.
  static const int domanda = 160;

  /// Tutti gli altri tetti, per la prova che li confronta con la loro misura.
  /// Enumerare invece di elencare a mano: un elenco scritto invecchia appena
  /// nasce una bolla nuova.
  static const List<int> tuttiTranneIlConsiglio = [sintesi, posizione, domanda];

  /// Tronca [testo] al tetto dato senza spezzare una parola a meta'.
  ///
  /// Non lascia mai una frase mozza con tre punti: taglia all'ultimo confine di
  /// parola dentro il tetto. Un tetto che produce monconi e' peggio di nessun
  /// tetto, ed e' lo stesso principio della misura della risposta dei Maestri.
  ///
  /// **Mai sui paragrafi della forma**, ordine GA voce GA.07: un paragrafo
  /// del responso o di una carta che supera il suo tetto si riscrive. Resta
  /// per le righe brevi, come la sintesi.
  static String dentro(String testo, int tetto) {
    if (testo.length <= tetto) return testo;
    final tagliato = testo.substring(0, tetto);
    final ultimo = tagliato.lastIndexOf(' ');
    return (ultimo <= 0 ? tagliato : tagliato.substring(0, ultimo)).trimRight();
  }
}
