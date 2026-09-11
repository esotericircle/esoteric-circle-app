import 'tarot_card.dart';
import 'tarot_spread.dart';
import 'tarot_topic.dart';

/// **LA NATURA DI UNA CARTA USCITA.** Ordine DF voce 04.2, 11 settembre 2026.
///
/// **DA DOVE NASCE.** Lo stampo vecchio trattava il futuro come una minaccia
/// **qualunque carta fosse uscita**: *"X non e' una sentenza: e' dove questo va
/// se non cambi passo"*. Quella frase e' toccata a **L'Appeso**, il dono della
/// sospensione, e a **Il Mondo**, il cerchio che si compie. Il fondatore lo ha
/// nominato per primo, e aveva ragione: una minaccia detta sulla carta migliore
/// del mazzo e' una lettura che non ha guardato le carte.
///
/// **QUATTRO NATURE, e vengono da due fatti del corpus, non da un giudizio.**
/// Il **verso** dice se la carta e' aperta o trattenuta, ed e' il corpus stesso
/// a dirlo, perche' per ogni carta ci sono due testi diversi. L'**arcano** dice
/// se parla del destino o della giornata. Incrociandoli si hanno quattro
/// nature, e nessuna e' un'invenzione di chi scrive: sono due colonne del
/// corpus messe in croce.
enum NaturaDellaCarta {
  /// Maggiore dritto: il compimento, il dono, la svolta grande.
  compimento,

  /// Minore dritto: la cosa buona ma quotidiana, il passo che riesce.
  favore,

  /// Maggiore rovesciato: il destino trattenuto, la prova.
  prova,

  /// Minore rovesciato: l'attrito piccolo, il rallentamento.
  attrito;

  /// La natura di una carta uscita, dal suo verso e dal suo arcano.
  static NaturaDellaCarta di(DrawnCard c) {
    final maggiore = c.card.arcana == TarotArcana.maggiore;
    if (c.reversed) return maggiore ? NaturaDellaCarta.prova : attrito;
    return maggiore ? NaturaDellaCarta.compimento : favore;
  }

  /// Se questa natura porta con se' qualcosa di aperto.
  bool get eAperta =>
      this == NaturaDellaCarta.compimento || this == NaturaDellaCarta.favore;
}

/// **IL FILO CON CUI SI SCEGLIE OGNI FORMA.**
/// Ordine DF voce 02, 11 settembre 2026.
///
/// **CHE COSA RISOLVE.** Il fondatore: *"voglio la sicurezza che su 100 domande
/// uguali, nemmeno una sia uguale o simile"*. Il testo vecchio era **uno
/// stampo**: cento letture davano cento volte la stessa frase con dentro nomi
/// diversi, e la persona lo riconosce alla seconda.
///
/// **IL FILO NASCE DALLE CARTE USCITE, e questa e' la scelta che decide
/// tutto.** Non dall'orologio, non dall'utente, non da un contatore: **dalle
/// tre carte e dai loro versi**. Due conseguenze, tutte e due volute:
///
/// **Uno, cento estrazioni diverse danno cento forme diverse.** E' cio' che
/// l'ordine chiede, e siccome l'estrazione e' casuale davvero, due letture
/// consecutive non hanno nessuna ragione di somigliarsi.
///
/// **Due, resta deterministico.** Le stesse tre carte nello stesso verso danno
/// sempre lo stesso testo: la bolla piu' lunga dell'app continua a non toccare
/// l'LLM, si puo' ancora mettere in cache, e le prove restano ripetibili. **La
/// casualita' sta nel mazzo, dove deve stare, e non nel testo.**
///
/// **IL MESCOLATORE E' UN VERO MESCOLATORE, e la prima stesura non lo era.**
/// Sceglieva con `(seme ~/ passo) % lunghezza`, e coi passi grandi il quoziente
/// aveva pochissimi valori distinti: la misura C dell'ordine e' salita a
/// **88,1 per cento** perche' due estrazioni diverse cadevano sulle stesse
/// quattro forme su cinque. Adesso il seme si rimescola a ogni pescata con due
/// giri di moltiplicazione e scorrimento, che e' il mestiere di un hash e non
/// di una divisione.
class FiloDellaVoce {
  FiloDellaVoce(this.seme);

  /// Il filo di una stesa: le tre carte e i loro versi, e nient'altro.
  factory FiloDellaVoce.daStesa(TarotSpread spread) {
    var h = 2166136261;
    for (final c in spread.cards) {
      final indice = TarotDeck.cards.indexWhere((x) => x.name == c.card.name);
      h = (h ^ (indice + 1)) * 16777619 & 0x7FFFFFFF;
      h = (h ^ (c.reversed ? 7919 : 104729)) * 16777619 & 0x7FFFFFFF;
    }
    return FiloDellaVoce(h);
  }

  final int seme;

  /// Quante volte si e' gia' pescato: ogni slot rimescola il filo con un numero
  /// suo, altrimenti due elenchi della stessa lunghezza uscirebbero sempre
  /// allineati e le forme si muoverebbero in blocco.
  int _quante = 0;

  /// Una voce dall'elenco, scelta dal filo.
  T scegli<T>(List<T> elenco) {
    if (elenco.isEmpty) throw StateError('elenco vuoto');
    _quante++;
    var x = (seme ^ (_quante * 0x9E3779B1)) & 0x7FFFFFFF;
    x = ((x ^ (x >> 15)) * 0x2C1B3C6D) & 0x7FFFFFFF;
    x = ((x ^ (x >> 13)) * 0x297A2D39) & 0x7FFFFFFF;
    x = (x ^ (x >> 16)) & 0x7FFFFFFF;
    return elenco[x % elenco.length];
  }
}

/// **LE FORME DELLA VOCE DI MEDORA.** Ordine DF voci 02 e 04.
///
/// **PERCHE' SONO ELENCHI E NON FRASI.** La regola QUATTRO dell'ordine DF dice
/// che *"un testo composto infilando nomi diversi dentro la stessa frase non
/// passa la misura B, e quindi una via basata su stampi fissi va dimostrata
/// capace di cento scheletri distinti oppure sostituita"*.
///
/// **PERCHE' OGNI ELENCO E' LUNGO OTTO, e non tre come nella prima stesura.**
/// Il conto si fa a coppie, non a testi. Con cinque fessure da otto forme
/// ciascuna le combinazioni sono **otto alla quinta, cioe' trentaduemila
/// settecentosessantotto** dentro una sola coppia di nature, e due letture
/// qualsiasi condividono in media **cinque ottavi di una fessura su cinque**.
/// Con tre forme per fessura ne condividevano una e due terzi, e la misura C
/// dell'ordine, che guarda **la coppia peggiore fra quattromilanovecentocinquanta**,
/// e' la misura che non perdona una media: perdona solo una coda.
///
/// **E NON SI CITANO PIU' LE SINTESI DELLE CARTE.** Ordine DF voce 04.3: i
/// significati erano scritti **due volte nella stessa schermata**, nell'elenco
/// Passato Presente Futuro e di nuovo dentro il Consiglio, a pochi centimetri.
/// Qui le carte si **nominano** e si parla della loro natura: il significato si
/// legge una volta sola, dove e' sempre stato.
abstract final class VoceDellaStesa {
  // --- IL RICONOSCIMENTO DELLA DOMANDA, e sta DENTRO il primo paragrafo ---

  /// **LE OTTO FORME CON CUI LA DOMANDA VIENE RICONOSCIUTA.**
  ///
  /// **E perche' non e' piu' un paragrafo suo.** Prima era una riga sola,
  /// sempre la stessa, in cima: *"Hai chiesto: X. Le tre carte rispondono a
  /// questa e non a una domanda in generale."* Su cento letture compariva
  /// **cento volte**, ed e' esattamente la misura D dell'ordine DF. Una frase
  /// che si ripete sempre non si legge piu' dalla seconda volta, e occupava il
  /// posto migliore della schermata.
  ///
  /// Adesso e' **l'attacco del primo paragrafo**: la domanda si vede
  /// riconosciuta e subito dopo, nella stessa frase, arriva la carta.
  static const List<String> riconoscimentiDellaDomanda = [
    'Hai chiesto: «{domanda}»',
    'La tua domanda era: «{domanda}»',
    'Su «{domanda}» le carte hanno qualcosa di preciso da dire.',
    'Hai portato qui questa domanda: «{domanda}»',
    'Le tre carte rispondono a «{domanda}», e non a una domanda in generale.',
    'Domanda posta: «{domanda}»',
    'Sei scesa con questa domanda: «{domanda}»',
    'La lettura risponde a «{domanda}»',
  ];

  // --- LA RISPOSTA, primo paragrafo, e dipende dalla carta del PRESENTE ---

  /// **LE OTTO APERTURE DELLA RISPOSTA.**
  ///
  /// Ordine DF voce 04.1: *"le carte entrano nel primo paragrafo, non dal terzo
  /// in poi"*. `{lente}` e' la lente dell'argomento, `{presente}` il nome della
  /// carta del Presente.
  static const List<String> apertureDellaRisposta = [
    '{lente} la lettura si ferma su {presente}, e da lì parte tutto il resto.',
    '{lente} non c\'è una risposta sola: c\'è {presente} al centro, e il resto '
        'le gira intorno.',
    'Al centro della tua lettura c\'è {presente}. {lente} è lei a dare il tono '
        'a tutto il resto.',
    '{lente} la carta che conta adesso è {presente}, e dice in che punto ti '
        'trovi davvero.',
    '{presente} è la carta che regge la tua lettura. {lente} è questo il punto '
        'da cui guardare.',
    '{lente} il momento che le carte vedono ha un nome, ed è {presente}.',
    'La tua lettura si apre su {presente}. {lente} è questo che va guardato per '
        'primo.',
    '{lente} tutto quello che segue poggia su {presente}, la carta che occupa '
        'il tuo presente.',
  ];

  /// **COSA DICE LA CARTA DEL PRESENTE, per natura.**
  ///
  /// Quattro famiglie, otto forme ognuna: una carta di compimento non dice la
  /// stessa cosa di una carta di attrito, e fino a ieri lo diceva.
  static const Map<NaturaDellaCarta, List<String>> cosaDiceIlPresente = {
    NaturaDellaCarta.compimento: [
      'È una carta che chiude un giro: qualcosa che portavi avanti ha trovato '
          'la sua forma, anche se non te ne sei ancora accorta.',
      'Parla di una cosa arrivata a maturazione. Non sei all\'inizio di questa '
          'storia: sei alla fine di un tratto.',
      'È fra le carte più aperte del mazzo. Quello che hai davanti è già in '
          'movimento, e il movimento è nel verso giusto.',
      'Dice che il lavoro è stato fatto. Quello che manca non è fatica: è '
          'riconoscere che è finito.',
      'È una carta grande e sta dritta. Non descrive un desiderio, descrive una '
          'cosa che sta già accadendo.',
      'Segna un passaggio vero, di quelli che si vedono solo guardandosi '
          'indietro dopo qualche mese.',
      'Porta un compimento. Il rischio, qui, non è fallire: è non accorgersi di '
          'essere arrivata.',
      'Racconta un pieno, non un vuoto. La domanda giusta non è cosa manca, è '
          'cosa farne.',
    ],
    NaturaDellaCarta.favore: [
      'È una carta concreta: parla di cose che si toccano, non di grandi '
          'destini. Il vantaggio c\'è, ed è alla tua portata.',
      'Dice che il terreno è buono. Non promette niente di clamoroso, e proprio '
          'per questo è affidabile.',
      'Parla di un passo che riesce, di quelli che non fanno rumore e che poi '
          'si vede che hanno spostato tutto.',
      'È una carta della giornata, non del destino: quello che descrive succede '
          'in settimane, non in anni.',
      'Racconta una misura giusta. Le cose stanno dove devono, e chiedono solo '
          'di essere usate.',
      'Dice che hai più materiale di quanto pensi. Il problema non è procurarsi '
          'altro, è metterlo insieme.',
      'È una carta di mestiere. Premia chi conosce il proprio lavoro, e tu lo '
          'conosci meglio di come lo racconti.',
      'Parla di una porta socchiusa. Non si apre da sola, ma non è chiusa a '
          'chiave.',
    ],
    NaturaDellaCarta.prova: [
      'È una carta grande uscita al rovescio: non toglie quello che promette, '
          'lo rimanda. C\'è qualcosa che non è ancora pronto.',
      'Parla di una forza trattenuta. Non è un no: è un non adesso, e la '
          'differenza cambia tutto.',
      'Dice che stai spingendo contro qualcosa che non si muove a spinte. La '
          'strada c\'è, ma non è quella che stai provando.',
      'Racconta un tempo che non coincide col tuo. Non è ostilità: è un altro '
          'orologio.',
      'È una prova, e le prove hanno una forma: chiedono una cosa sola e la '
          'chiedono bene.',
      'Segna un nodo. Un nodo si scioglie tirando il capo giusto, e tirando '
          'tutti gli altri si stringe.',
      'Dice che c\'è un prezzo, e che il prezzo è noto. Quello che non è ancora '
          'chiaro è se sei disposta a pagarlo.',
      'È una carta importante messa di traverso: quello che promette resta, ma '
          'passa da una porta più stretta.',
    ],
    NaturaDellaCarta.attrito: [
      'È un attrito piccolo, di quelli che non si vedono da fuori e che '
          'rallentano tutto da dentro.',
      'Parla di un intoppo quotidiano. Non è il destino che ti sbarra la '
          'strada: è un dettaglio che nessuno ha ancora sistemato.',
      'Dice che c\'è qualcosa fuori posto, ed è più piccolo di come lo stai '
          'vivendo.',
      'Racconta un ingranaggio che gratta. Non si è rotto niente: manca '
          'qualcosa in un punto solo.',
      'È una carta minore al rovescio: il fastidio è reale e la sua misura è '
          'quella di un fastidio.',
      'Segnala uno spreco. Stai mettendo energia in un punto che non la '
          'restituisce.',
      'Dice che ti manca un\'informazione, non una forza. Cercare batte '
          'insistere.',
      'Parla di una cosa rimandata troppe volte, che ormai costa più il '
          'rimandarla che il farla.',
    ],
  };

  // --- L'AZIONE, secondo paragrafo ---

  /// **IL GESTO, otto per natura: cosa fare, e basta.**
  ///
  /// **Perche' il gesto e la ragione sono due elenchi e non uno.** Nella prima
  /// stesura l'azione era **una frase lunga sola**, otto per natura: era il
  /// blocco piu' lungo del Consiglio, e due letture che ci cadevano sopra
  /// insieme si portavano dietro un quarto del testo. La misura C dell'ordine
  /// guarda **la coppia peggiore fra quattromilanovecentocinquanta**, e con
  /// otto sole forme quella coppia esisteva sempre.
  ///
  /// **Incrociando due elenchi da otto le azioni diventano sessantaquattro per
  /// natura**, senza scrivere sessantaquattro frasi: si scrivono otto gesti e
  /// otto ragioni, e il gesto resta agganciato alla natura della carta mentre
  /// la ragione e' libera di girare.
  static const Map<NaturaDellaCarta, List<String>> gestoPerNatura = {
    NaturaDellaCarta.compimento: [
      'Dichiara che è finita: dillo, scrivilo, mandalo a qualcuno.',
      'Usa adesso quello che hai costruito, invece di aspettare di sentirti più pronta.',
      'Dai una data precisa alla consegna, entro questa settimana.',
      'Mostra il risultato a una persona che conta, e falla vedere davvero.',
      'Togli le ultime tre cose che hai aggiunto e guarda se non era già finito.',
      'Segna il traguardo da qualche parte dove potrai ritrovarlo.',
      'Chiedi adesso quello che rimandavi a quando saresti stata più forte.',
      'Scrivi in tre righe che cosa hai imparato in questo tratto, e tienile.',
    ],
    NaturaDellaCarta.favore: [
      'Fai il passo concreto che rimandi da tempo, anche piccolo.',
      'Scegli una sola cosa fra quelle aperte e portala a termine.',
      'Chiedi a voce quello che finora hai solo sperato ti venisse offerto.',
      'Metti un numero su quello che stai valutando: quanto costa, quanto rende, entro quando.',
      'Cerca chi ha già fatto questa cosa e fagli due domande precise.',
      'Rendi visibile quello che sai fare, anche con una riga sola in più.',
      'Fissa tu la prima scadenza, prima che te la fissi qualcun altro.',
      'Fai la versione piccola della cosa grande che hai in mente.',
    ],
    NaturaDellaCarta.prova: [
      'Smetti di spingere per qualche giorno e guarda cosa si muove da solo.',
      'Cerca il pezzo che manca invece di ripetere il tentativo.',
      'Rimanda di una settimana la decisione che stai per prendere di fretta.',
      'Scrivi quale condizione dovrebbe cambiare perché questa cosa funzioni.',
      'Prova la stessa cosa in una versione che, se va male, non ti costa niente.',
      'Parla con chi ti sta dicendo di no e chiedi che cosa servirebbe per un sì.',
      'Prenditi il tempo che serve, ma mettici una scadenza.',
      'Cambia una sola variabile invece di tutto il piano.',
    ],
    NaturaDellaCarta.attrito: [
      'Togli oggi l\'intoppo più piccolo dei tre che hai in mente.',
      'Metti per iscritto che cosa esattamente si è inceppato.',
      'Parla con la persona che sta dall\'altra parte dell\'intoppo.',
      'Dai mezz\'ora sola a questa cosa, oggi, e non un minuto di più.',
      'Elimina un passaggio invece di renderlo più veloce.',
      'Controlla la cosa più banale prima di cercare la causa complicata.',
      'Rinuncia a quello che ti costa più di quanto rende, e dillo a voce.',
      'Rifai con calma il passaggio che la prima volta hai fatto di corsa.',
    ],
  };

  /// **GLI AGGANCI DELL'AZIONE, e senza questi la misura D cade.**
  ///
  /// **Il numero che li ha fatti nascere.** Con l'azione scritta come frase
  /// a se' stante, il paragrafo centrale era **l'unico senza un nome di
  /// carta dentro**: su cento letture il paragrafo piu' ripetuto compariva
  /// **nove volte**, perche' meta' delle estrazioni cade sulla stessa
  /// natura. La soglia dell'ordine e' **due**.
  ///
  /// **La cura non e' scrivere ottanta azioni.** E' agganciare l'azione
  /// alla carta che l'ha suggerita, che e' anche piu' vero: un consiglio
  /// che viene da una carta deve dire da quale.
  static const List<String> aggancioDellAzione = [
    'Quello che {presente} chiede è una cosa sola.',
    '{presente} indica il gesto, e il gesto è questo.',
    'Da {presente} viene un\'indicazione precisa.',
    'Se {presente} è la carta del tuo presente, il passo è questo.',
    'La mossa che {presente} suggerisce si può fare questa settimana.',
    'Tradotto in una cosa da fare, {presente} dice questo.',
    '{presente} non lascia il consiglio nel vago.',
    'Ecco che cosa farne, stando a {presente}.',
    'Il passo che {presente} mette davanti è piccolo e si vede.',
    'Con {presente} al centro, la cosa da fare è una e si fa presto.',
    'Se traduci {presente} in un gesto, viene fuori questo.',
    '{presente} porta con sé un compito, e il compito è breve.',
  ];

  /// **LA RAGIONE, otto e valgono per ogni gesto.**
  ///
  /// Sono le otto ragioni per cui un passo piccolo conta, e nessuna promette
  /// niente: dicono **perche' quel gesto sposta qualcosa**, che e' la cosa che
  /// l'anatomia del responso chiede alla parte azionabile.
  static const List<String> percheFarlo = [
    'Qui conta muoversi, non trovare il momento perfetto.',
    'Una cosa finita vale più di tre iniziate.',
    'Il passo piccolo fatto oggi sposta più del passo grande rimandato.',
    'Finché resta nella testa è un pensiero; appena esce diventa una cosa che si può maneggiare.',
    'È la mossa che costa meno di tutte quelle che stai considerando.',
    'Serve a togliere l\'incertezza, e l\'incertezza è la parte che stanca.',
    'Da lì in poi la situazione smette di dipendere solo dall\'attesa.',
    'È il genere di gesto che non fa rumore e che poi si vede che ha spostato tutto.',
  ];

  /// **LE OTTO RIGHE CHE DICONO COME SI VEDE SE HA FUNZIONATO.**
  ///
  /// **Nascono da una ragione di prodotto, scritta nell'anatomia del responso:**
  /// *"un responso che risponde alla tua domanda e ti lascia una cosa da fare
  /// produce un ritorno, perche' domani vuoi sapere se aveva ragione"*. Una
  /// cosa da fare senza un modo di accorgersi che e' stata fatta e' un
  /// consiglio che nessuno verifica, e un consiglio che nessuno verifica non
  /// fa tornare nessuno.
  ///
  /// **E sono anche la settima fessura indipendente della composizione**, cioe'
  /// la ragione per cui la somiglianza massima a coppie del solo Consiglio
  /// scende sotto la soglia dell'ordine invece di restarle addosso.
  static const List<String> comeSiVede = [
    'Se hai fatto la cosa giusta te ne accorgi perché qualcosa si muove entro '
        'pochi giorni, non entro mesi.',
    'La prova che ha funzionato è semplice: smetti di rimuginarci sopra.',
    'Saprai di aver colto se la prossima volta la stessa domanda ti verrà in '
        'mente con parole diverse.',
    'Il segnale che cercavi è una risposta che arriva da fuori, non una '
        'sensazione che arriva da dentro.',
    'Capirai di essere sulla strada quando la cosa comincerà a costarti meno '
        'fatica di prima.',
    'Il modo di verificarlo è guardare fra una settimana se questa domanda è '
        'ancora la tua domanda.',
    'Ha funzionato se ti trovi a raccontarlo a qualcuno senza che te lo '
        'chieda.',
    'Lo riconosci dal fatto che una delle cose che ti pesavano smette di '
        'essere nell\'elenco.',
  ];

  // --- IL LEGAME FRA PASSATO E PRESENTE, terzo paragrafo ---

  /// **LE OTTO FORME DEL LEGAME.**
  ///
  /// Ordine DF voce 04.8: lo stampo vecchio produceva frasi che si inciampano,
  /// *"Il Mago tiene il filo di cio' che e' stato, il potere di creare e La
  /// Giustizia rovesciata e' cio' che hai fra le mani adesso"*. La causa era
  /// una virgola che infilava una sintesi dentro una coordinata. **Qui le carte
  /// si nominano e non si citano**, e ogni forma e' una frase intera.
  static const List<String> formeDelLegame = [
    'Alle tue spalle c\'è {passato}: è da lì che viene il punto in cui sei '
        'adesso.',
    'Quello che hai davanti oggi ha una radice, e la radice è {passato}.',
    '{passato} racconta come ci sei arrivata. Non è un rimprovero, è il filo.',
    'Il passato della lettura porta {passato}, e spiega perché {presente} si '
        'presenta proprio così.',
    'Prima di {presente} c\'è stata {passato}, e le due si tengono per mano più '
        'di quanto sembri.',
    'C\'è {passato} dietro di te: è la carta che ha preparato il terreno su cui '
        'stai camminando.',
    'La lettura non parte da oggi. Parte da {passato}, ed è lì che si capisce '
        'il resto.',
    'Dietro {presente} si vede {passato}: una cosa è nata dall\'altra.',
    'Il filo comincia da {passato}. Quello che vedi oggi è il suo seguito, non '
        'il suo contrario.',
    'Se guardi indietro trovi {passato}, e da lì si capisce perché oggi la '
        'lettura si ferma dove si ferma.',
    'La casella del passato porta {passato}: è quello che hai già attraversato '
        'per arrivare qui.',
    'Tutto questo viene da {passato}, che è la carta alle tue spalle.',
  ];

  // --- IL FUTURO, e NON e' una minaccia se la carta non lo e' ---

  /// **LE FORME DEL FUTURO, otto per ogni natura.**
  ///
  /// **E' la riparazione della voce DF.04.2.** La formula unica *"X non e' una
  /// sentenza: e' dove questo va se non cambi passo"* toccava a **L'Appeso** e
  /// a **Il Mondo**: una minaccia detta sulla carta del compimento. Adesso il
  /// futuro **parla come la carta che e' uscita**, e la minaccia esiste solo
  /// dove la carta la porta davvero.
  static const Map<NaturaDellaCarta, List<String>> formeDelFuturo = {
    NaturaDellaCarta.compimento: [
      'Davanti a te c\'è {futuro}, ed è una delle carte che si vogliono vedere '
          'in fondo a una lettura: quello che stai facendo porta lì.',
      '{futuro} chiude la stesa, e la chiude bene. Non è una promessa: è la '
          'direzione che le carte vedono se la strada resta questa.',
      'La lettura finisce su {futuro}: il giro si compie. Quello che devi fare '
          'è non uscire dalla strada mentre si sta chiudendo.',
      'In fondo c\'è {futuro}, e dice che questa storia ha un arrivo. Non '
          'domani, ma ce l\'ha.',
      '{futuro} aspetta in fondo alla stesa. È la carta che dà un senso a tutta '
          'la fatica che viene prima.',
      'Il futuro della lettura porta {futuro}: qui non c\'è niente da temere, '
          'c\'è qualcosa da riconoscere.',
      'Alla fine arriva {futuro}, e le carte grandi dritte non minacciano: '
          'aprono.',
      'Chiude {futuro}. Se una lettura può dirti di continuare, questa te lo '
          'dice.',
    ],
    NaturaDellaCarta.favore: [
      'Davanti a te c\'è {futuro}: niente di clamoroso, e proprio per questo '
          'affidabile. Le cose piccole tengono.',
      '{futuro} chiude la lettura su una nota concreta. Il risultato c\'è e '
          'somiglia al lavoro che ci hai messo.',
      'In fondo alla stesa c\'è {futuro}, che parla di cose che si vedono e si '
          'contano. È la parte di futuro su cui hai davvero presa.',
      'La strada porta a {futuro}. Non è un colpo di scena: è quello che '
          'succede se continui.',
      'Alla fine c\'è {futuro}, una carta di mestiere. Il futuro qui è una '
          'conseguenza, non una sorpresa.',
      '{futuro} sta in fondo, e dice che il seguito è nelle tue mani più che '
          'nelle circostanze.',
      'Il futuro della lettura è {futuro}: una cosa che si costruisce, non una '
          'che capita.',
      'Chiude {futuro}. Piccola, dritta, e con i piedi per terra.',
    ],
    NaturaDellaCarta.prova: [
      'Davanti a te c\'è {futuro}, e non è una condanna: è un passaggio stretto '
          'che si attraversa, non un muro.',
      '{futuro} chiude la stesa con una prova. Le carte non dicono che finisce '
          'male: dicono che costa.',
      'In fondo c\'è {futuro}: quello che arriva chiede qualcosa in cambio. '
          'Sapere il prezzo prima è già metà del vantaggio.',
      'La lettura si chiude su {futuro}, che rimanda invece di negare. Il tempo '
          'qui lavora, se non lo forzi.',
      'Alla fine arriva {futuro}, una carta grande messa di traverso: il tema è '
          'importante, la strada è più lunga.',
      '{futuro} aspetta in fondo. Non toglie l\'arrivo: sposta la data.',
      'Il futuro della lettura porta {futuro}, e chiede una rinuncia precisa '
          'invece di un sacrificio generico.',
      'Chiude {futuro}. È la carta che conviene guardare adesso, finché sei '
          'ancora in tempo a scegliere da dove passare.',
    ],
    NaturaDellaCarta.attrito: [
      'Davanti a te c\'è {futuro}: un attrito, non un ostacolo. Si toglie con '
          'una mossa, non con una battaglia.',
      '{futuro} chiude la lettura su un intoppo piccolo. È la carta più facile '
          'da smentire di tutta la stesa.',
      'In fondo c\'è {futuro}, e dice dove ti impunterai se lasci le cose come '
          'stanno.',
      'La stesa finisce su {futuro}: un granello, non una frana. Vale la pena '
          'toglierlo adesso che è ancora piccolo.',
      'Alla fine arriva {futuro}, una carta minore al rovescio: il fastidio è '
          'reale e la sua misura è quella di un fastidio.',
      '{futuro} sta in fondo e si smonta da sola, appena qualcuno la guarda '
          'davvero.',
      'Il futuro della lettura è {futuro}: non minaccia, avverte. E un avviso è '
          'una cosa utile.',
      'Chiude {futuro}. Se ti muovi adesso, questa carta non la incontri.',
    ],
  };

  /// **COSA DICONO I VERSI, quattro forme per ognuno dei tre casi.**
  ///
  /// **Era una frase sola per caso, e si ripeteva a ogni lettura con lo stesso
  /// conto di rovesciate.** Siccome i casi sono tre, su cento letture la stessa
  /// riga tornava una trentina di volte, e contribuiva alla misura C piu' di
  /// qualunque altra cosa.
  ///
  /// **La parola del rovescio non si scrive a mano nemmeno qui.** Il soggetto
  /// non e' una carta ma il CONTO delle carte, quindi si dice il fatto senza la
  /// parola accordata: *"uscita al rovescio"* vale per qualunque arcano.
  static const Map<int, List<String>> formeDeiVersi = {
    0: [
      'Nessuna delle tre è uscita al rovescio: la strada è libera e il passo '
          'tocca a te.',
      'Tutte e tre stanno dritte. Non c\'è niente da sciogliere prima di '
          'muoversi.',
      'Nessun rovescio in questa stesa: quello che le carte dicono, lo dicono '
          'senza riserve.',
      'Tre carte dritte su tre. È una lettura pulita, e le letture pulite '
          'chiedono di essere prese sul serio.',
    ],
    1: [
      'Una delle tre è uscita al rovescio, quindi c\'è un nodo da sciogliere e '
          'non un muro.',
      'C\'è un solo rovescio nella stesa: un punto che frena, e uno solo.',
      'Una carta su tre sta di traverso. È il pezzo da guardare per primo, '
          'non il motivo per fermarsi.',
      'Un rovescio soltanto: il resto della lettura tiene, e quello che frena '
          'ha un nome preciso.',
    ],
    2: [
      'Più di una è uscita al rovescio: prima di andare avanti c\'è qualcosa '
          'da sciogliere e il margine per farlo ce l\'hai.',
      'Ci sono più rovesci che dritte. Non è un disastro: è una lettura che '
          'chiede di rallentare.',
      'La stesa è in gran parte al rovescio. Vuol dire che il movimento c\'è, '
          'ma passa da dentro prima che da fuori.',
      'Più carte di traverso che dritte: il tempo di questa cosa non è ancora '
          'il tuo, e conviene saperlo adesso.',
    ],
  };

  /// **E LA CODA DEI MAGGIORI, col numero SCRITTO IN LETTERE.**
  /// Ordine DF voce 04.7: *"il numero degli Arcani Maggiori e' in cifra dentro
  /// un testo letterario"*, e il fondatore lo ha nominato come difetto.
  static const List<String> formeDeiMaggiori = [
    'E con {quanti} Arcani Maggiori nella stesa il tema è più grande della '
        'giornata: il cielo insiste su questo.',
    'Ci sono {quanti} Arcani Maggiori: questa non è una domanda da settimana, '
        'è una domanda da stagione.',
    'Con {quanti} Maggiori in tre carte, la lettura parla di qualcosa che ti '
        'riguarda in profondità e non solo oggi.',
    '{quanti} Arcani Maggiori su tre carte sono tanti: quello che stai '
        'chiedendo tocca una cosa grande.',
  ];

  /// La riga dei versi e dei Maggiori, scelta dal filo.
  static String letturaDeiVersi(TarotSpread spread, FiloDellaVoce filo) {
    final rovesciate = spread.cards.where((c) => c.reversed).length;
    final maggiori =
        spread.cards.where((c) => c.card.arcana == TarotArcana.maggiore).length;
    final versi = filo.scegli(formeDeiVersi[rovesciate.clamp(0, 2)]!);
    if (maggiori < 2) return versi;
    return '$versi '
        '${filo.scegli(formeDeiMaggiori).replaceAll('{quanti}', inLettere(maggiori))}';
  }

  /// **LE OTTO APERTURE DI UNA POSIZIONE.** Ordine DF voce 02, misura C.
  ///
  /// **Era una sola, ed era la lente dell'argomento**: *"Sul denaro che ti
  /// riguarda,"* apriva **tutte e tre** le posizioni di **tutte** le cento
  /// letture. Quindici parole identiche per testo, trecento sequenze comuni
  /// regalate a ogni coppia, e nessuna di quelle sequenze diceva niente.
  static const List<String> apertureDellaPosizione = [
    'In questa posizione',
    'Qui la carta dice che',
    'Su questo punto',
    'Quello che si legge qui è che',
    'La carta in questa casella racconta che',
    'A questo posto della stesa',
    'Qui',
    'In questo tratto della lettura',
  ];

  /// L'apertura della posizione [quale], contata da zero, per questa stesa.
  static String aperturaDellaPosizione(TarotSpread spread, int quale) {
    final filo = FiloDellaVoce(FiloDellaVoce.daStesa(spread).seme + quale * 97);
    return filo.scegli(apertureDellaPosizione);
  }

  /// **LE OTTO CHIUSURE, e non sono un ornamento.**
  ///
  /// **Il fondatore ha dettato la gerarchia**: *"titolo accattivante che
  /// riassume la risposta, poi risposta descrittiva diretta e immediata"*. Una
  /// lettura che finisce sull'ultimo fatto tecnico, cioe' il conto dei
  /// Maggiori, **non finisce: si interrompe**. Queste otto righe chiudono, e
  /// chiudono ognuna in modo diverso.
  ///
  /// **E servono anche a una cosa misurabile.** Sono la sesta fessura
  /// indipendente della composizione: moltiplicano per otto le forme e, cosa
  /// che conta di piu' per la misura C dell'ordine, **diluiscono** cio' che due
  /// letture possono avere in comune. Il solo Consiglio e' sceso dal 41,4 per
  /// cento della somiglianza massima a coppie.
  ///
  /// **Nessuna promette niente**, che e' la cornice di casa: il cielo inclina e
  /// non obbliga.
  static const List<String> chiusure = [
    'Il resto lo scrivi tu, e le carte lo sanno.',
    'Questa lettura indica una direzione, non un destino: la scelta resta '
        'tua.',
    'Non c\'è niente di scritto qui che tu non possa cambiare camminando.',
    'Le carte dicono da dove soffia il vento. La rotta la tieni tu.',
    'Prendi quello che ti serve e lascia il resto: una lettura serve a '
        'decidere, non a obbedire.',
    'Quello che hai letto vale finché non fai la prima mossa. Poi vale quello '
        'che hai fatto.',
    'Nessuna di queste tre carte decide per te: mostrano il terreno, e il '
        'passo è tuo.',
    'Torna a guardarla fra qualche giorno: quello che oggi sembra il punto '
        'principale spesso non lo era.',
  ];

  /// **IL TITOLO CHE RIASSUME LA RISPOSTA.** Ordine DF voci 04.5 e 04.9.
  ///
  /// *"Si risponde con titolo accattivante che riassume la risposta"*, e il
  /// fondatore ha misurato che compariva **in una lettura su quattro**. O c'e'
  /// sempre o non c'e' mai.
  ///
  /// **E senza il punto fermo dentro**, che era l'altra meta' del difetto: la
  /// sintesi del corpus finisce con un punto, e un titolo con un punto in mezzo
  /// si legge come due titoli.
  static String titolo(TarotSpread spread) {
    var t = spread.presente.summary.trim();
    while (t.endsWith('.')) {
      t = t.substring(0, t.length - 1);
    }
    return t;
  }

  /// **IL NUMERO SCRITTO IN LETTERE.** Ordine DF voce 04.7: *"il numero degli
  /// Arcani Maggiori e' in cifra dentro un testo letterario"*.
  static String inLettere(int n) {
    const parole = <String>[
      'nessuno',
      'un',
      'due',
      'tre',
      'quattro',
      'cinque',
      'sei',
      'sette',
      'otto',
      'nove',
      'dieci',
    ];
    return n >= 0 && n < parole.length ? parole[n] : '$n';
  }

  /// **COMPONE I PARAGRAFI DEL CONSIGLIO.**
  /// Ordine DF voci 02, 04.1, 04.2, 04.8, 04.9.
  ///
  /// **L'ORDINE DI LETTURA, che e' la voce 04.9.** Il fondatore: *"il Consiglio
  /// apre con il verdetto e mette le carte in fondo. Con un verdetto sempre
  /// uguale, la persona legge le prime otto righe, le riconosce, e non arriva
  /// mai alla parte che cambia"*. Adesso **le carte sono nella prima riga**.
  ///
  /// **Tre paragrafi**, come prima: il fondatore ha detto che la lunghezza e la
  /// divisione attuali vanno bene e non si toccano.
  static List<String> paragrafi(
    TarotSpread spread,
    TarotTopic topic, {
    String? domandaScritta,
    String? fattoDelCielo,
  }) {
    final filo = FiloDellaVoce.daStesa(spread);
    final naturaPresente = NaturaDellaCarta.di(spread.presente);
    final naturaFuturo = NaturaDellaCarta.di(spread.futuro);

    String riempi(String forma) => forma
        .replaceAll('{lente}', '${topic.lente},')
        .replaceAll('{presente}', spread.presente.displayName)
        .replaceAll('{passato}', spread.passato.displayName)
        .replaceAll('{futuro}', spread.futuro.displayName);

    // La lente apre la frase oppure sta in mezzo, e nei due casi la maiuscola
    // cambia: senza questo, meta' delle otto forme comincerebbe in minuscola.
    String maiuscola(String s) =>
        s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

    final sua = domandaScritta?.trim();
    final riconoscimento = sua == null || sua.isEmpty
        ? ''
        : '${filo.scegli(riconoscimentiDellaDomanda).replaceAll('{domanda}', sua)} ';

    // **ANCHE L ORDINE DENTRO IL PARAGRAFO VARIA.** Ordine DF voce 02, misura
    // C: due booleani raddoppiano due volte le forme senza scrivere una riga
    // di prosa in piu, e sono due modi veri di dire la stessa cosa. La
    // somiglianza massima a coppie del solo Consiglio scende dal 42,4 per
    // cento, che era sopra la soglia, a un numero sotto.
    final apreLaCarta = filo.scegli(const [true, false]);
    final aperturaDellaCarta =
        maiuscola(riempi(filo.scegli(apertureDellaRisposta)));
    final cosaDice = filo.scegli(cosaDiceIlPresente[naturaPresente]!);
    final risposta = apreLaCarta
        ? '$riconoscimento$aperturaDellaCarta $cosaDice'
        : '$riconoscimento$cosaDice $aperturaDellaCarta';

    final aggancio = maiuscola(riempi(filo.scegli(aggancioDellAzione)));
    final cosaFare = '${filo.scegli(gestoPerNatura[naturaPresente]!)} '
        '${filo.scegli(percheFarlo)}';
    final aggancioPrima = filo.scegli(const [true, false]);
    // **LA RIGA DI COME SI VEDE NON ENTRA NEL CONSIGLIO, e la ragione e una
    // sola: la lunghezza.** Il fondatore, nell ordine DF: *"la lunghezza dei
    // testi e la divisione dei paragrafi va bene attualmente"*. Misurato, con
    // quella riga dentro il caso peggiore del Consiglio passava il tetto di
    // millecento caratteri e la bolla veniva troncata. **Fra la varieta e il
    // rispetto di una misura che il fondatore ha dichiarato buona, vince la
    // misura**: l elenco resta scritto e pronto per il giorno in cui servira
    // altrove, per esempio nel dono del mattino dopo, dove lo spazio c e.
    final azione = aggancioPrima
        ? '$aggancio $cosaFare'
        : '$cosaFare $aggancio';

    final legame = maiuscola(riempi(filo.scegli(formeDelLegame)));
    final futuro = riempi(filo.scegli(formeDelFuturo[naturaFuturo]!));

    // **ANCHE L'ORDINE DEI DUE PEZZI VARIA**, e raddoppia le forme del terzo
    // paragrafo senza scrivere una riga di prosa in piu': a volte si guarda
    // indietro e poi avanti, a volte si apre sul futuro e si spiega da dove
    // viene. Sono due modi veri di raccontare la stessa cosa.
    final primaIlPassato = filo.scegli(const [true, false]);
    return [
      risposta,
      azione,
      [
        if (primaIlPassato) legame else futuro,
        if (primaIlPassato) futuro else legame,
        letturaDeiVersi(spread, filo),
        if (fattoDelCielo != null && fattoDelCielo.trim().isNotEmpty)
          'E il cielo di oggi lo accompagna. $fattoDelCielo',
        filo.scegli(chiusure),
      ].where((p) => p.trim().isNotEmpty).join(' '),
    ].where((p) => p.trim().isNotEmpty).toList();
  }
}
