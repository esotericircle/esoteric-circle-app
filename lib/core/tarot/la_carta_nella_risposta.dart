import 'tarot_spread.dart';

/// **IL TONO DI UNA CARTA USCITA, letto dal suo significato.** Ordine GA voce
/// GA.06, 21 ottobre 2026.
///
/// **DA DOVE NASCE.** Il lettore cieco dei Tarocchi (`docs/collaudo/GA/
/// lettori_ciechi/esiti/esito_tre_domande_tarocchi.md`) ha trovato la prima
/// frase delle stese di casa scritta su quattro "nature" che venivano solo
/// dall'arcano e dal verso (`NaturaDellaCarta`, ordine DF voce 04.2): un
/// Minore dritto era sempre un *"favore"*. Cosi' il Nove di Spade, l'angoscia
/// della notte, dava *"una situazione che gira a tuo favore"*, il Tre di
/// Spade *"la risposta e' buona"*, il Dieci di Spade *"un favore concreto e
/// vicino"*. Il verso e l'arcano non dicono se una carta apre o chiude: lo
/// dice il suo significato.
///
/// **TRE TONI, e li decide il significato documentato del verso** (il corpus
/// `docs/corpus/tarocchi.md`, cioe' i testi di `TarotDeck.cards`):
/// [favorevole] quando la carta apre, sostiene o libera; [condizionato]
/// quando apre a una condizione che la carta stessa nomina (un'attesa, una
/// pausa, un pezzo che manca); [sfavorevole] quando la carta parla di dolore,
/// blocco, perdita o inganno.
enum TonoDellaCarta { favorevole, condizionato, sfavorevole }

/// **CIO' CHE UNA CARTA PORTA DENTRO LA RISPOSTA**, per carta e verso. Ordine
/// GA voce GA.06: *"Ogni affermazione poggia sul simbolo uscito e sul suo
/// significato documentato, dritto o rovesciato"*.
///
/// - [tono]: se la carta apre, apre a una condizione o chiude (vedi
///   [TonoDellaCarta]).
/// - [tema]: il significato in due a cinque parole, con l'articolo, per
///   nominare la carta accanto ad altre e per il titolo. **Non e' la
///   sintesi del corpus**, che si legge gia' sotto la carta (ordine DF voce
///   04.3: *"i significati scritti due volte nella stessa schermata"*).
/// - [dice]: che cosa la carta dice, scritto per stare dopo *"dice che"*,
///   in minuscolo e senza punto: e' il perche' del verdetto.
/// - [via]: il gesto che la carta chiede, all'imperativo, in minuscolo e
///   senza punto.
/// - [distacco]: la carta parla di una fine, di una partenza o di una
///   liberazione; davanti a una domanda di distacco (*"Devo chiudere
///   l'amicizia?"*) dice si'.
///
/// **LE REGOLE DEI TESTI**, sorvegliate da `la_risposta_viene_dalla_carta_
/// test.dart`: nessuna figura del lessico di `FigureDellaStesa` (la stessa
/// immagine in due pezzi dello stesso responso e' il difetto dell'ordine DS
/// voce 09), nessun futuro, nessuna cifra, nessuna parola che dia un genere
/// a chi legge, mai la virgola prima di "e".
class LaCartaNellaRisposta {
  const LaCartaNellaRisposta(this.tono, this.tema, this.dice, this.via,
      {this.distacco = false, this.legame = false});

  final TonoDellaCarta tono;
  final String tema;
  final String dice;
  final String via;
  final bool distacco;

  /// La carta parla di un legame che ha valore (l'intesa, la casa, la
  /// festa condivisa, la pace): davanti a una domanda di distacco dice di
  /// non chiudere ancora.
  final bool legame;

  /// La chiave di una carta uscita: nome e verso, `dritta` o `capovolta`
  /// come nel corpus delle posizioni.
  static String chiaveDi(DrawnCard d) =>
      '${d.card.name}|${d.reversed ? 'capovolta' : 'dritta'}';

  /// Cio' che la carta [d] porta nella risposta. Non manca mai: la guardia
  /// pretende tutte le centocinquantasei carte-verso.
  static LaCartaNellaRisposta di(DrawnCard d) => tavola[chiaveDi(d)]!;

  /// **LE CENTOCINQUANTASEI CARTE-VERSO**, scritte da Code il 21 ottobre
  /// 2026 leggendo il significato di ciascuna in `tarot_card.dart`.
  static const Map<String, LaCartaNellaRisposta> tavola = {
    // --- GLI ARCANI MAGGIORI ---
    'Il Matto|dritta': LaCartaNellaRisposta(
        _f,
        'un inizio fatto con fiducia',
        'è il momento di cominciare con fiducia, anche senza vedere tutto il '
            'percorso',
        'comincia adesso con una prima mossa concreta, senza aspettare di '
            'avere tutto chiaro',
        distacco: true),
    'Il Matto|capovolta': LaCartaNellaRisposta(
        _s,
        'uno slancio senza direzione',
        'c\'è uno slancio senza direzione, oppure una paura che ti trattiene '
            'proprio sull\'orlo',
        'fermati e chiediti se ti spinge il coraggio o la voglia di fuggire'),
    'Il Mago|dritta': LaCartaNellaRisposta(
        _f,
        'la capacità di fare',
        'hai già gli strumenti che servono e l\'idea chiede di diventare un '
            'gesto concreto',
        'trasforma oggi l\'idea in un gesto, come una telefonata, una pagina, una '
            'prova'),
    'Il Mago|capovolta': LaCartaNellaRisposta(
        _s,
        'un talento lasciato fermo',
        'le parole promettono più di quanto le mani mantengono e un talento '
            'resta fermo',
        'mantieni una sola delle cose che hai promesso, prima di prometterne '
            'altre'),
    'La Papessa|dritta': LaCartaNellaRisposta(
        _c,
        'una risposta che matura piano',
        'la risposta matura nel silenzio e non tutto va deciso adesso',
        'aspetta qualche giorno prima di decidere e ascolta che cosa senti '
            'davvero'),
    'La Papessa|capovolta': LaCartaNellaRisposta(
        _s,
        'l\'intuito messo da parte',
        'stai coprendo col rumore una parte di te che sa già la risposta',
        'prenditi mezz\'ora di silenzio senza telefono e scrivi la prima cosa '
            'che senti'),
    'L\'Imperatrice|dritta': LaCartaNellaRisposta(
        _f,
        'una cosa viva che cresce',
        'qualcosa di vivo sta prendendo forma e chiede cura, non fretta',
        'nutri quello che sta nascendo con un gesto di cura, senza forzarne i '
            'tempi'),
    'L\'Imperatrice|capovolta': LaCartaNellaRisposta(
        _s,
        'una crescita bloccata',
        'ciò che volevi far nascere è fermo, oppure lo stai forzando prima del '
            'tempo',
        'smetti di forzare e torna a curare le basi di ciò che vuoi far '
            'crescere'),
    'L\'Imperatore|dritta': LaCartaNellaRisposta(
        _f,
        'l\'ordine che protegge',
        'è il momento dell\'ordine e delle fondamenta solide; ciò che '
            'costruisci con regola dura',
        'dai una struttura alla cosa, con tempi, compiti e una regola chiara'),
    'L\'Imperatore|capovolta': LaCartaNellaRisposta(
        _s,
        'un controllo che soffoca',
        'il controllo è diventato troppo stretto, oppure mancano le basi e '
            'tutto vacilla',
        'allenta una regola che soffoca oppure metti la prima base che '
            'manca'),
    'Il Papa|dritta': LaCartaNellaRisposta(
        _f,
        'il consiglio di chi sa',
        'ti aiuta un consiglio esperto, una guida che conosce già la questione',
        'chiedi il parere di una persona esperta di cui ti fidi'),
    'Il Papa|capovolta': LaCartaNellaRisposta(
        _c,
        'una regola da rivedere',
        'una regola ricevuta non ti appartiene più e la risposta va cercata '
            'fuori dal solito schema',
        'scegli secondo ciò che ti fa respirare, non secondo ciò che si '
            'aspettano gli altri'),
    'Gli Amanti|dritta': LaCartaNellaRisposta(
        _f,
        'una scelta di cuore',
        'è una scelta di cuore e di valori, da fare con testa e sentimento '
            'insieme',
        'scegli l\'opzione in cui testa e cuore dicono la stessa cosa'),
    'Gli Amanti|capovolta': LaCartaNellaRisposta(
        _c,
        'un accordo interiore che manca',
        'dentro di te ciò in cui credi e ciò che desideri non sono ancora '
            'd\'accordo',
        'mettiti d\'accordo con te prima di decidere con un\'altra persona'),
    'Il Carro|dritta': LaCartaNellaRisposta(
        _f,
        'la volontà che avanza',
        'hai direzione e forza; è il momento di prendere le redini e andare '
            'avanti',
        'fissa la meta e muoviti adesso, tenendo insieme le spinte contrarie'),
    'Il Carro|capovolta': LaCartaNellaRisposta(
        _s,
        'una corsa che sbanda',
        'forze opposte ti fanno sbandare, oppure stai correndo senza sapere '
            'bene dove',
        'fermati, scegli una sola direzione e solo dopo riparti'),
    'La Giustizia|dritta': LaCartaNellaRisposta(
        _c,
        'il conto onesto dei fatti',
        'torna indietro ciò che hai seminato; la bilancia pende verso chi '
            'agisce con onestà',
        'metti per iscritto i fatti così come stanno, senza sconti'),
    'La Giustizia|capovolta': LaCartaNellaRisposta(
        _s,
        'un conto rimasto aperto',
        'c\'è un conto rimasto aperto, una conseguenza che non stai '
            'riconoscendo come tua',
        'riconosci la tua parte del conto aperto e chiudilo con un gesto'),
    'L\'Eremita|dritta': LaCartaNellaRisposta(
        _c,
        'un ritiro che chiarisce',
        'è tempo di ritiro e di ricerca interiore; la risposta arriva un '
            'tratto alla volta',
        'prenditi del tempo per te prima di decidere'),
    'L\'Eremita|capovolta': LaCartaNellaRisposta(
        _s,
        'una solitudine che isola',
        'la solitudine che doveva chiarire ti sta allontanando dagli altri',
        'esci dal ritiro e cerca una persona con cui parlarne'),
    'La Ruota della Fortuna|dritta': LaCartaNellaRisposta(
        _f,
        'una svolta che arriva',
        'un ciclo gira e porta una svolta, spesso quando meno te lo aspetti',
        'accogli il cambiamento invece di aggrapparti a com\'era prima'),
    'La Ruota della Fortuna|capovolta': LaCartaNellaRisposta(
        _c,
        'un ciclo in sosta',
        'il ciclo sembra fermo ma è una sosta, non la fine del movimento',
        'usa la sosta per raccogliere le forze, senza forzare i tempi'),
    'La Forza|dritta': LaCartaNellaRisposta(
        _f,
        'la calma che regge',
        'il coraggio qui è calma; ciò che ti agita si placa con fermezza '
            'gentile',
        'affronta la cosa con calma e fermezza, senza alzare i toni'),
    'La Forza|capovolta': LaCartaNellaRisposta(
        _s,
        'una tenuta che vacilla',
        'dubiti della tua tenuta, oppure ti tratti con troppa durezza',
        'tratta te e la situazione con mitezza invece che con la stretta'),
    'L\'Appeso|dritta': LaCartaNellaRisposta(
        _c,
        'un\'attesa che insegna',
        'fermarsi e guardare la cosa da un\'altra angolazione vale più che '
            'agire subito',
        'rimanda la mossa di qualche giorno e guarda la cosa dal punto di vista '
            'opposto'),
    'L\'Appeso|capovolta': LaCartaNellaRisposta(
        _s,
        'un\'attesa diventata stallo',
        'l\'attesa non insegna più niente e sa di stallo, o di un sacrificio '
            'inutile',
        'smetti di aspettare e fai una mossa, oppure rinuncia a un sacrificio '
            'che non serve'),
    'La Morte|dritta': LaCartaNellaRisposta(
        _c,
        'una fine che trasforma',
        'qualcosa si chiude perché qualcos\'altro possa nascere',
        'lascia andare ciò che è finito e fai spazio a quello che viene',
        distacco: true),
    'La Morte|capovolta': LaCartaNellaRisposta(
        _s,
        'un cambiamento trattenuto',
        'stai resistendo a un cambiamento già arrivato; trattenere fa più '
            'male che lasciare',
        'accetta che una fase è finita e smetti di trattenerla'),
    'La Temperanza|dritta': LaCartaNellaRisposta(
        _f,
        'la pazienza che accorda',
        'la pazienza e il giusto dosaggio rimettono d\'accordo ciò che era '
            'diviso',
        'vai piano e trova una via di mezzo fra le due parti',
        legame: true),
    'La Temperanza|capovolta': LaCartaNellaRisposta(
        _s,
        'un equilibrio perduto',
        'ci sono eccessi e fretta; il ritmo giusto si è perso',
        'rallenta e togli un eccesso, uno soltanto, da questa settimana'),
    'Il Diavolo|dritta': LaCartaNellaRisposta(
        _s,
        'un legame che trattiene',
        'c\'è un legame o un\'abitudine che ti tiene più di quanto ammetti',
        'dai un nome a ciò che ti trattiene e scrivilo, senza vergogna'),
    'Il Diavolo|capovolta': LaCartaNellaRisposta(
        _f,
        'una catena che si spezza',
        'ti accorgi di una catena che ti tratteneva; vederla è già metà della '
            'libertà',
        'spezza adesso, con un gesto concreto, il legame che hai riconosciuto',
        distacco: true),
    'La Torre|dritta': LaCartaNellaRisposta(
        _s,
        'un crollo improvviso',
        'cade all\'improvviso ciò che era costruito sul falso; sul momento '
            'fa male',
        'guarda che cosa resta in piedi e riparti solo da quello',
        distacco: true),
    'La Torre|capovolta': LaCartaNellaRisposta(
        _c,
        'una scossa rimandata',
        'stai rimandando una scossa necessaria, oppure ne stai uscendo a '
            'fatica',
        'lascia cadere ora ciò che è falso, prima che il crollo diventi più '
            'grande'),
    'La Stella|dritta': LaCartaNellaRisposta(
        _f,
        'la fiducia ritrovata',
        'dopo la tempesta torna la fiducia; sei nella direzione giusta anche '
            'se costa fatica',
        'coltiva la fiducia con un gesto piccolo ogni giorno'),
    'La Stella|capovolta': LaCartaNellaRisposta(
        _c,
        'una fiducia stanca',
        'la fiducia è stanca e la speranza sembra lontana, ma non è spenta',
        'cerca un segno piccolo di ciò che sta già andando bene e annotalo'),
    'La Luna|dritta': LaCartaNellaRisposta(
        _c,
        'una situazione non chiara',
        'non tutto è chiaro, le paure parlano e le cose non sono come sembrano',
        'non decidere finché i fatti non sono chiari e verifica ciò che temi'),
    'La Luna|capovolta': LaCartaNellaRisposta(
        _f,
        'una confusione che si chiarisce',
        'la confusione si sta chiarendo e ciò che faceva paura si mostra più '
            'piccolo',
        'guarda in faccia ciò che ti spaventava e chiarisci il punto rimasto '
            'confuso'),
    'Il Sole|dritta': LaCartaNellaRisposta(
        _f,
        'una riuscita piena',
        'è un tempo in cui le cose riescono e si vedono',
        'mostra quello che hai e vivilo apertamente, senza nasconderti'),
    'Il Sole|capovolta': LaCartaNellaRisposta(
        _c,
        'una gioia trattenuta',
        'la gioia c\'è, ma qualcosa la copre e fatichi a sentirla',
        'lascia cadere il pensiero vecchio che ti toglie la gioia'),
    'Il Giudizio|dritta': LaCartaNellaRisposta(
        _f,
        'una chiamata a rinascere',
        'una chiamata ti invita a una vita più vera ed è il momento del '
            'bilancio',
        'rispondi alla chiamata con una decisione presa adesso'),
    'Il Giudizio|capovolta': LaCartaNellaRisposta(
        _s,
        'un bilancio rimandato',
        'stai rimandando un bilancio necessario, oppure ti giudichi con troppa '
            'durezza',
        'fai il bilancio che rimandi, con giustizia e senza durezza verso di te'),
    'Il Mondo|dritta': LaCartaNellaRisposta(
        _f,
        'un compimento pieno',
        'c\'è pienezza e armonia; ciò che hai costruito trova il suo '
            'compimento',
        'riconosci ciò che hai raggiunto e goditelo, senza correre già oltre'),
    'Il Mondo|capovolta': LaCartaNellaRisposta(
        _c,
        'un pezzo che manca',
        'la meta è vicina, ma manca ancora un pezzo da sistemare',
        'trova il pezzo che manca e completalo, senza fermarti proprio adesso'),
    // --- BASTONI ---
    'Asso di Bastoni|dritta': LaCartaNellaRisposta(
        _f,
        'un impulso nuovo',
        'c\'è un impulso nuovo e ardente ed è il momento giusto per iniziare',
        'comincia adesso, finché lo slancio è vivo'),
    'Asso di Bastoni|capovolta': LaCartaNellaRisposta(
        _s,
        'una partenza che slitta',
        'lo slancio è bloccato e la partenza continua a slittare, forse per '
            'paura di sbagliare',
        'ritrova il motivo per cui volevi partire, poi fissa il giorno '
            'dell\'inizio'),
    'Due di Bastoni|dritta': LaCartaNellaRisposta(
        _f,
        'un progetto che si allarga',
        'un progetto prende forma e chiede di scegliere una direzione oltre ciò '
            'che conosci',
        'scegli la direzione e pianifica il primo tratto con ambizione'),
    'Due di Bastoni|capovolta': LaCartaNellaRisposta(
        _c,
        'una direzione ancora confusa',
        'c\'è paura di osare, oppure una direzione ancora confusa che ti tiene '
            'sull\'uscio',
        'chiarisci per iscritto che cosa vuoi davvero prima di muoverti'),
    'Tre di Bastoni|dritta': LaCartaNellaRisposta(
        _f,
        'un risultato già in arrivo',
        'hai messo in moto qualcosa e i risultati sono già in viaggio',
        'tieni d\'occhio ciò che hai avviato e preparati ad accoglierlo'),
    'Tre di Bastoni|capovolta': LaCartaNellaRisposta(
        _c,
        'un ritorno diverso dall\'attesa',
        'ciò che hai lanciato torna, ma in una forma diversa da quella attesa',
        'rileggi le aspettative su ciò che arriva davvero, non su ciò che '
            'speravi'),
    'Quattro di Bastoni|dritta': LaCartaNellaRisposta(
        _f,
        'una stabilità da festeggiare',
        'c\'è stabilità e una meta da festeggiare; le fondamenta reggono',
        'festeggia ciò che hai costruito con le persone che contano',
        legame: true),
    'Quattro di Bastoni|capovolta': LaCartaNellaRisposta(
        _c,
        'una festa rimandata',
        'la festa è rimandata o vissuta a metà; la meta non trova il suo '
            'momento',
        'fissa una data per celebrare ciò che hai raggiunto'),
    'Cinque di Bastoni|dritta': LaCartaNellaRisposta(
        _c,
        'un confronto acceso',
        'c\'è un confronto acceso, una competizione in cui le energie si '
            'scontrano',
        'usa il confronto per migliorare, non per vincere a ogni costo'),
    'Cinque di Bastoni|capovolta': LaCartaNellaRisposta(
        _s,
        'un attrito che stanca',
        'ci sono tensioni inutili, oppure attriti che lasci covare senza '
            'affrontarli',
        'scegli l\'unica discussione che conta e lascia cadere le altre'),
    'Sei di Bastoni|dritta': LaCartaNellaRisposta(
        _f,
        'un riconoscimento meritato',
        'arriva un riconoscimento meritato, un successo che gli altri vedono',
        'presenta il tuo risultato a chi deve vederlo'),
    'Sei di Bastoni|capovolta': LaCartaNellaRisposta(
        _c,
        'un merito che tarda',
        'il riconoscimento tarda e il dubbio su di te pesa più del dovuto',
        'elenca tre risultati che hai ottenuto, senza aspettare l\'applauso di '
            'nessuno'),
    'Sette di Bastoni|dritta': LaCartaNellaRisposta(
        _c,
        'una posizione da tenere',
        'c\'è pressione ma il vantaggio è tuo; è il momento di tenere il '
            'punto',
        'difendi la tua posizione con calma, senza cedere proprio adesso'),
    'Sette di Bastoni|capovolta': LaCartaNellaRisposta(
        _s,
        'una difesa stanca',
        'la difesa è stanca, oppure stai in guardia anche quando non serve',
        'scegli dove vale la pena resistere e dove puoi lasciare'),
    'Otto di Bastoni|dritta': LaCartaNellaRisposta(
        _f,
        'un\'accelerazione improvvisa',
        'le cose accelerano e notizie ed eventi si muovono in fretta',
        'rispondi subito alle notizie che arrivano, senza rimandare'),
    'Otto di Bastoni|capovolta': LaCartaNellaRisposta(
        _c,
        'una fretta mal riposta',
        'ci sono ritardi, oppure una fretta mal riposta che fa inciampare',
        'rallenta quel tanto che basta per rimettere ordine'),
    'Nove di Bastoni|dritta': LaCartaNellaRisposta(
        _c,
        'la tenacia dell\'ultimo tratto',
        'la meta è vicina e adesso conta la tenacia dell\'ultimo tratto',
        'tieni duro nell\'ultimo tratto e non mollare adesso'),
    'Nove di Bastoni|capovolta': LaCartaNellaRisposta(
        _s,
        'una diffidenza di troppo',
        'la diffidenza è di troppo e ti difendi anche da chi vuole solo '
            'avvicinarsi',
        'abbassa la guardia con una persona che viene in pace'),
    'Dieci di Bastoni|dritta': LaCartaNellaRisposta(
        _s,
        'un carico troppo grande',
        'porti un carico troppo grande, che ti curva le spalle',
        'decidi che cosa posare e lascia almeno un compito che non è tuo'),
    'Dieci di Bastoni|capovolta': LaCartaNellaRisposta(
        _c,
        'un fardello da restituire',
        'porti un fardello che forse non ti appartiene, per abitudine o per '
            'dovere',
        'restituisci un compito che non è tuo e dillo con chiarezza'),
    'Fante di Bastoni|dritta': LaCartaNellaRisposta(
        _f,
        'un\'idea giovane da provare',
        'arriva un\'idea giovane, una curiosità che chiede di essere esplorata',
        'prova l\'idea nuova in piccolo, questa settimana'),
    'Fante di Bastoni|capovolta': LaCartaNellaRisposta(
        _s,
        'un entusiasmo che si spegne',
        'l\'entusiasmo si accende e si spegne prima di dare frutti',
        'scegli una sola idea e portala avanti per un mese'),
    'Cavaliere di Bastoni|dritta': LaCartaNellaRisposta(
        _f,
        'il coraggio di partire',
        'è un tempo per osare; passione e azione portano verso ciò che '
            'desideri',
        'parti con coraggio, ma scrivi prima la meta',
        distacco: true),
    'Cavaliere di Bastoni|capovolta': LaCartaNellaRisposta(
        _s,
        'un\'impazienza che brucia',
        'c\'è impazienza, uno slancio senza meta che rischia di bruciare tutto',
        'dai una meta alla tua energia prima di lanciarti'),
    'Regina di Bastoni|dritta': LaCartaNellaRisposta(
        _f,
        'un calore che attira',
        'la tua sicurezza e il tuo calore attirano le persone giuste',
        'mostrati per ciò che sei, con generosità'),
    'Regina di Bastoni|capovolta': LaCartaNellaRisposta(
        _s,
        'una gelosia che divide',
        'una gelosia o il bisogno di brillare ti fa vivere gli altri come '
            'rivali',
        'torna al tuo centro e smetti di misurarti con chi ti sta accanto'),
    'Re di Bastoni|dritta': LaCartaNellaRisposta(
        _f,
        'una guida che dà l\'esempio',
        'serve una guida che apra la questione con l\'esempio',
        'prendi tu la direzione e fai per primo ciò che chiedi agli altri'),
    'Re di Bastoni|capovolta': LaCartaNellaRisposta(
        _s,
        'un\'autorità che non ascolta',
        'c\'è un\'autorità impaziente che spinge senza ascoltare',
        'ascolta prima di decidere e guida senza travolgere'),
    // --- COPPE ---
    'Asso di Coppe|dritta': LaCartaNellaRisposta(
        _f,
        'un\'emozione nuova',
        'un\'emozione nuova sgorga come una fonte e il cuore si apre',
        'lascia che quello che senti si veda, con un gesto o una parola',
        legame: true),
    'Asso di Coppe|capovolta': LaCartaNellaRisposta(
        _s,
        'un sentimento trattenuto',
        'un sentimento resta trattenuto, per timore di soffrire',
        'concediti di sentire e dillo a una persona di fiducia'),
    'Due di Coppe|dritta': LaCartaNellaRisposta(
        _f,
        'un\'intesa a due',
        'c\'è un\'unione, un\'intesa a due che si riconosce',
        'cura il rapporto con chi è coinvolto, con un gesto reciproco',
        legame: true),
    'Due di Coppe|capovolta': LaCartaNellaRisposta(
        _s,
        'un\'armonia incrinata',
        'c\'è un malinteso, un equilibrio incrinato fra due persone che si '
            'vogliono bene',
        'parlatevi a cuore aperto e ascolta davvero l\'altra parte'),
    'Tre di Coppe|dritta': LaCartaNellaRisposta(
        _f,
        'una gioia condivisa',
        'c\'è amicizia e festa; la gioia condivisa raddoppia',
        'condividi la notizia con le persone che ti vogliono bene',
        legame: true),
    'Tre di Coppe|capovolta': LaCartaNellaRisposta(
        _c,
        'un gruppo da curare meglio',
        'c\'è un eccesso, oppure un gruppo di persone che va curato meglio',
        'torna alle persone che ti sostengono davvero e lascia i rapporti di '
            'facciata'),
    'Quattro di Coppe|dritta': LaCartaNellaRisposta(
        _c,
        'un\'offerta non vista',
        'c\'è noia; un\'offerta ti passa accanto senza che tu la veda',
        'guarda di nuovo l\'offerta che stai rifiutando senza pensarci'),
    'Quattro di Coppe|capovolta': LaCartaNellaRisposta(
        _f,
        'un interesse che si risveglia',
        'esci dal torpore e una curiosità nuova ti risveglia',
        'segui la curiosità nuova con una prima mossa concreta'),
    'Cinque di Coppe|dritta': LaCartaNellaRisposta(
        _s,
        'una perdita che pesa',
        'c\'è una perdita e lo sguardo resta fisso su ciò che è andato',
        'riconosci il dolore e poi guarda ciò che ti resta in piedi'),
    'Cinque di Coppe|capovolta': LaCartaNellaRisposta(
        _f,
        'una ripresa dopo il dolore',
        'arriva la ripresa dopo il dolore e ti stai voltando verso ciò che c\'è '
            'ancora',
        'fai un gesto verso ciò che ti resta e che ti fa bene'),
    'Sei di Coppe|dritta': LaCartaNellaRisposta(
        _f,
        'un affetto che torna',
        'un affetto sincero torna dal passato e ti scalda',
        'riprendi contatto con una persona del passato che può aiutarti',
        legame: true),
    'Sei di Coppe|capovolta': LaCartaNellaRisposta(
        _c,
        'la nostalgia che trattiene',
        'il rischio è vivere nei ricordi di un tempo che non c\'è più',
        'onora ciò che è stato e scegli una cosa da fare nel presente'),
    'Sette di Coppe|dritta': LaCartaNellaRisposta(
        _c,
        'un miraggio fra molte possibilità',
        'ci sono molte possibilità e qualche illusione; non tutte mantengono '
            'ciò che promettono',
        'scegli una sola possibilità e verificala con i piedi per terra'),
    'Sette di Coppe|capovolta': LaCartaNellaRisposta(
        _f,
        'un desiderio riconosciuto',
        'la confusione si dirada e riconosci un desiderio vero',
        'scegli il desiderio che hai riconosciuto e rinuncia agli altri'),
    'Otto di Coppe|dritta': LaCartaNellaRisposta(
        _c,
        'una partenza silenziosa',
        'lasci ciò che non ti nutre più per cercare qualcosa di più vero',
        'allontanati da ciò che ti svuota, anche senza conoscere ancora la '
            'meta',
        distacco: true),
    'Otto di Coppe|capovolta': LaCartaNellaRisposta(
        _c,
        'un\'indecisione fra restare e andare',
        'un\'indecisione fra restare e andare ti tiene sulla porta',
        'chiediti se è tempo di lasciare e datti una data per rispondere'),
    'Nove di Coppe|dritta': LaCartaNellaRisposta(
        _f,
        'una soddisfazione piena',
        'un desiderio si avvera; è la carta del cuore contento',
        'goditi ciò che hai ottenuto e ringrazia chi ti ha aiutato'),
    'Nove di Coppe|capovolta': LaCartaNellaRisposta(
        _c,
        'una soddisfazione di facciata',
        'la soddisfazione è di facciata e non colma davvero',
        'chiediti se ciò che desideri ti nutre davvero o ti distrae soltanto'),
    'Dieci di Coppe|dritta': LaCartaNellaRisposta(
        _f,
        'l\'armonia negli affetti',
        'c\'è armonia negli affetti, una pienezza condivisa',
        'condividi la cosa di persona con chi ti è caro',
        legame: true),
    'Dieci di Coppe|capovolta': LaCartaNellaRisposta(
        _s,
        'tensioni negli affetti',
        'ci sono tensioni negli affetti e in casa ognuno tira dalla sua parte',
        'riunisci le persone coinvolte e cerca un punto su cui siete '
            'd\'accordo'),
    'Fante di Coppe|dritta': LaCartaNellaRisposta(
        _f,
        'un\'emozione sincera che affiora',
        'affiora un\'emozione nuova, fragile e sincera',
        'ascolta l\'emozione nuova e dalle spazio con un messaggio gentile'),
    'Fante di Coppe|capovolta': LaCartaNellaRisposta(
        _s,
        'una sensibilità ferita',
        'la sensibilità è ferita e il cuore si è chiuso per proteggersi',
        'proteggi la tua sensibilità senza murarla e apriti con una persona '
            'fidata'),
    'Cavaliere di Coppe|dritta': LaCartaNellaRisposta(
        _f,
        'una proposta gentile',
        'arriva una proposta, un invito fatto con grazia',
        'accogli la proposta che arriva oppure falla tu, con garbo'),
    'Cavaliere di Coppe|capovolta': LaCartaNellaRisposta(
        _s,
        'una promessa vaga',
        'ci sono promesse vaghe che non mettono a terra niente',
        'verifica che alle parole seguano i fatti, tuoi e dell\'altra persona'),
    'Regina di Coppe|dritta': LaCartaNellaRisposta(
        _f,
        'l\'empatia che capisce',
        'l\'empatia e l\'intuito sono la tua forza in questo momento',
        'ascolta con il cuore e fidati di ciò che intuisci'),
    'Regina di Coppe|capovolta': LaCartaNellaRisposta(
        _s,
        'un\'emozione che sommerge',
        'ti perdi negli stati d\'animo degli altri fino a smarrire i tuoi',
        'riporta un po\' di cura su di te prima di occuparti degli altri'),
    'Re di Coppe|dritta': LaCartaNellaRisposta(
        _f,
        'una calma che governa',
        'serve calma emotiva; chi governa i sentimenti con serenità tiene la '
            'direzione',
        'rispondi con calma e senza farti trascinare dall\'umore'),
    'Re di Coppe|capovolta': LaCartaNellaRisposta(
        _s,
        'un umore instabile',
        'gli sbalzi d\'umore prendono il posto della guida',
        'aspetta che l\'umore si calmi prima di parlare o decidere'),
    // --- DENARI ---
    'Asso di Denari|dritta': LaCartaNellaRisposta(
        _f,
        'un\'occasione concreta',
        'c\'è un\'occasione concreta, un inizio solido per qualcosa di '
            'materiale',
        'cogli l\'occasione concreta con una prima mossa pratica'),
    'Asso di Denari|capovolta': LaCartaNellaRisposta(
        _c,
        'un\'occasione che rischia di sfumare',
        'un\'occasione rischia di sfumare, oppure è stata valutata male',
        'guarda meglio l\'occasione che hai davanti prima che sfumi'),
    'Due di Denari|dritta': LaCartaNellaRisposta(
        _f,
        'un equilibrio flessibile',
        'tieni insieme più cose con flessibilità e buon ritmo',
        'organizza gli impegni con leggerezza, uno alla volta'),
    'Due di Denari|capovolta': LaCartaNellaRisposta(
        _s,
        'un ritmo perso negli impegni',
        'ci sono troppe cose insieme, il ritmo si è perso e qualcosa scivola',
        'scegli le due priorità vere e rimanda il resto'),
    'Tre di Denari|dritta': LaCartaNellaRisposta(
        _f,
        'una collaborazione che funziona',
        'la collaborazione funziona e il tuo lavoro è visto e apprezzato',
        'lavora insieme agli altri e mostra il risultato comune'),
    'Tre di Denari|capovolta': LaCartaNellaRisposta(
        _s,
        'una collaborazione confusa',
        'i ruoli sono confusi e il lavoro comune non ingrana',
        'chiarisci compiti e aspettative con chi lavora con te'),
    'Quattro di Denari|dritta': LaCartaNellaRisposta(
        _c,
        'la prudenza che conserva',
        'è il momento di proteggere ciò che hai e di conservare',
        'metti al sicuro ciò che hai prima di fare mosse nuove'),
    'Quattro di Denari|capovolta': LaCartaNellaRisposta(
        _s,
        'una presa troppo stretta',
        'la paura di restare senza ti fa stringere troppo',
        'allenta la presa su una cosa che trattieni per paura'),
    'Cinque di Denari|dritta': LaCartaNellaRisposta(
        _s,
        'una mancanza da attraversare',
        'c\'è una mancanza, un senso di esclusione, un inverno da attraversare',
        'chiedi aiuto senza vergogna a chi può darlo'),
    'Cinque di Denari|capovolta': LaCartaNellaRisposta(
        _f,
        'un sostegno che torna',
        'il periodo duro comincia ad allentarsi e torna un sostegno',
        'accetta l\'aiuto che torna e riprendi un tratto alla volta'),
    'Sei di Denari|dritta': LaCartaNellaRisposta(
        _f,
        'uno scambio equo',
        'c\'è uno scambio equo, un aiuto che va e viene con giustizia',
        'dai e chiedi con equilibrio, nella stessa misura',
        legame: true),
    'Sei di Denari|capovolta': LaCartaNellaRisposta(
        _s,
        'uno scambio sbilanciato',
        'lo scambio è sbilanciato e dai troppo a chi non ricambia',
        'verifica che lo scambio sia equo e smetti di dare a senso unico'),
    'Sette di Denari|dritta': LaCartaNellaRisposta(
        _c,
        'un raccolto che chiede pazienza',
        'ciò che hai coltivato matura lentamente e serve pazienza',
        'aspetta il tempo giusto e intanto valuta con calma i risultati'),
    'Sette di Denari|capovolta': LaCartaNellaRisposta(
        _s,
        'uno sforzo mal ripagato',
        'c\'è impazienza, oppure uno sforzo che sembra mal ripagato',
        'rivedi dove metti l\'energia prima di insistere'),
    'Otto di Denari|dritta': LaCartaNellaRisposta(
        _f,
        'il mestiere che cresce',
        'impegno e mestiere portano risultati, un dettaglio alla volta',
        'perfeziona una cosa sola, con pazienza, un dettaglio alla volta'),
    'Otto di Denari|capovolta': LaCartaNellaRisposta(
        _s,
        'un lavoro senza senso',
        'il lavoro è diventato monotono e ha perso il suo senso',
        'ritrova il senso di ciò che fai oppure valuta di cambiare direzione'),
    'Nove di Denari|dritta': LaCartaNellaRisposta(
        _f,
        'un raccolto meritato',
        'raccogli i frutti meritati del tuo lavoro, in autonomia',
        'goditi ciò che hai costruito e difendi la tua autonomia'),
    'Nove di Denari|capovolta': LaCartaNellaRisposta(
        _s,
        'un\'autonomia che vacilla',
        'l\'indipendenza che hai costruito vacilla per spese o per apparenza',
        'proteggi ciò che hai costruito e taglia una spesa di facciata'),
    'Dieci di Denari|dritta': LaCartaNellaRisposta(
        _f,
        'una stabilità che dura',
        'c\'è una stabilità profonda, qualcosa di solido che dura nel tempo',
        'cura le basi comuni della tua famiglia e di ciò che resta nel tempo',
        legame: true),
    'Dieci di Denari|capovolta': LaCartaNellaRisposta(
        _s,
        'una contesa in famiglia',
        'c\'è una contesa in famiglia su cose che appartengono a più persone',
        'metti i fatti per iscritto prima di discutere di chi ha diritto a '
            'cosa'),
    'Fante di Denari|dritta': LaCartaNellaRisposta(
        _f,
        'un impegno da studiare',
        'c\'è un apprendimento, un progetto concreto che chiede impegno',
        'studia con costanza e metti subito in pratica ciò che impari'),
    'Fante di Denari|capovolta': LaCartaNellaRisposta(
        _s,
        'un impegno lasciato a metà',
        'un progetto si è fermato a metà e l\'impegno preso aspetta ancora',
        'riprendi l\'impegno lasciato a metà con un\'ora fissa al giorno'),
    'Cavaliere di Denari|dritta': LaCartaNellaRisposta(
        _f,
        'una costanza che arriva',
        'l\'andatura è lenta ma costante; chi non si ferma arriva',
        'avanza con metodo, un tratto fisso ogni giorno'),
    'Cavaliere di Denari|capovolta': LaCartaNellaRisposta(
        _s,
        'una prudenza diventata immobilità',
        'la prudenza è diventata immobilità e l\'avanzare si è fermato',
        'fai oggi la tappa che rimandi per eccesso di prudenza'),
    'Regina di Denari|dritta': LaCartaNellaRisposta(
        _f,
        'una cura concreta',
        'c\'è cura concreta e senso pratico, cuore e concretezza insieme',
        'prenditi cura della cosa con un gesto pratico e concreto'),
    'Regina di Denari|capovolta': LaCartaNellaRisposta(
        _c,
        'una cura che dimentica te',
        'ti occupi di tutti e dimentichi te',
        'metti anche te nell\'elenco delle cose da curare'),
    'Re di Denari|dritta': LaCartaNellaRisposta(
        _f,
        'una prosperità gestita con misura',
        'c\'è stabilità e un successo concreto, gestito con misura',
        'gestisci con misura ciò che hai e condividilo'),
    'Re di Denari|capovolta': LaCartaNellaRisposta(
        _s,
        'una ricchezza ferma',
        'ciò che hai costruito resta fermo e non dà frutto',
        'rimetti in movimento una risorsa ferma'),
    // --- SPADE ---
    'Asso di Spade|dritta': LaCartaNellaRisposta(
        _f,
        'una chiarezza netta',
        'c\'è chiarezza, un taglio netto che separa il vero dal falso',
        'di\' le cose come stanno, con onestà e poche parole'),
    'Asso di Spade|capovolta': LaCartaNellaRisposta(
        _s,
        'una mente annebbiata',
        'le idee sono annebbiate, oppure le parole tagliano male',
        'schiarisci le idee prima di parlare o decidere'),
    'Due di Spade|dritta': LaCartaNellaRisposta(
        _c,
        'una decisione rimandata',
        'c\'è uno stallo, una decisione rimandata a occhi chiusi',
        'scrivi ciò che stai evitando di guardare e decidi su quello'),
    'Due di Spade|capovolta': LaCartaNellaRisposta(
        _f,
        'una verità che riaffiora',
        'la verità riaffiora e il blocco si allenta',
        'affronta adesso la scelta che hai rimandato'),
    'Tre di Spade|dritta': LaCartaNellaRisposta(
        _s,
        'un dolore che ferisce',
        'c\'è un dolore, una delusione che ferisce',
        'dai spazio al dolore e parlane con una persona di fiducia'),
    'Tre di Spade|capovolta': LaCartaNellaRisposta(
        _c,
        'una ferita che guarisce',
        'il dolore comincia a sfumare e la ferita si rimargina',
        'prenditi cura della ferita e fai una mossa verso il perdono'),
    'Quattro di Spade|dritta': LaCartaNellaRisposta(
        _c,
        'una pausa necessaria',
        'serve una pausa, perché il riposo restituisce forza',
        'fermati qualche giorno e recupera le forze prima di agire'),
    'Quattro di Spade|capovolta': LaCartaNellaRisposta(
        _f,
        'la ripartenza dopo la sosta',
        'la sosta ha fatto il suo lavoro ed è tempo di rimettersi in moto',
        'riparti con calma, senza strafare all\'inizio'),
    'Cinque di Spade|dritta': LaCartaNellaRisposta(
        _s,
        'una vittoria amara',
        'è una vittoria amara, un conflitto che costa più di quanto vale',
        'chiediti se vincere questa discussione vale ciò che perdi'),
    'Cinque di Spade|capovolta': LaCartaNellaRisposta(
        _f,
        'la voglia di fare pace',
        'nasce la voglia di riconciliazione, di deporre le armi',
        'fai tu la prima mossa verso la pace, anche se pensi di avere ragione',
        legame: true),
    'Sei di Spade|dritta': LaCartaNellaRisposta(
        _f,
        'una traversata verso acque calme',
        'è una transizione verso acque più calme',
        'lascia la tempesta dietro di te e procedi un tratto alla volta',
        distacco: true),
    'Sei di Spade|capovolta': LaCartaNellaRisposta(
        _c,
        'un distacco che costa',
        'il distacco costa e fatichi a lasciare il passato',
        'parti anche con la valigia pesante, decidendo che cosa portare'),
    'Sette di Spade|dritta': LaCartaNellaRisposta(
        _c,
        'una prudenza astuta',
        'serve astuzia e prudenza, ma senza ingannare nessuno',
        'agisci con tatto e senza mentire, nemmeno a te'),
    'Sette di Spade|capovolta': LaCartaNellaRisposta(
        _s,
        'un inganno che affiora',
        'un inganno pesa sulla coscienza e sta venendo a galla',
        'torna alla trasparenza e di\' la verità che manca'),
    'Otto di Spade|dritta': LaCartaNellaRisposta(
        _s,
        'una trappola fatta di pensieri',
        'ti senti in trappola, ma i limiti stanno soprattutto nei pensieri',
        'elenca le vie d\'uscita che hai davvero, sono più di quanto credi'),
    'Otto di Spade|capovolta': LaCartaNellaRisposta(
        _f,
        'una liberazione',
        'le corde cadono e si apre una via d\'uscita dopo il senso di trappola',
        'esci con una prima mossa dalla situazione che ti bloccava',
        distacco: true),
    'Nove di Spade|dritta': LaCartaNellaRisposta(
        _s,
        'l\'ansia notturna',
        'l\'ansia e i pensieri della notte ingigantiscono le paure',
        'separa i fatti dalle paure e scrivili su due colonne'),
    'Nove di Spade|capovolta': LaCartaNellaRisposta(
        _c,
        'una paura che allenta',
        'la paura allenta la presa e il peggio della notte è alle tue spalle',
        'parla di ciò che ti angoscia con una persona di fiducia'),
    'Dieci di Spade|dritta': LaCartaNellaRisposta(
        _s,
        'una fine dolorosa',
        'un ciclo doloroso si chiude e quella battaglia è finita',
        'accetta che quella battaglia è finita e smetti di combatterla',
        distacco: true),
    'Dieci di Spade|capovolta': LaCartaNellaRisposta(
        _c,
        'una ripartenza da zero',
        'ti rialzi dopo una chiusura completa e si riparte da zero',
        'rimetti in piedi una cosa alla volta, cominciando dalla più piccola'),
    'Fante di Spade|dritta': LaCartaNellaRisposta(
        _c,
        'una vigilanza attenta',
        'serve vigilanza, cioè osservare e informarsi prima di parlare',
        'raccogli informazioni e scegli con cura le parole'),
    'Fante di Spade|capovolta': LaCartaNellaRisposta(
        _s,
        'una parola che ferisce',
        'ci sono parole che feriscono, pettegolezzi senza costrutto',
        'verifica prima di parlare e non riportare voci altrui'),
    'Cavaliere di Spade|dritta': LaCartaNellaRisposta(
        _c,
        'una determinazione veloce',
        'c\'è determinazione e velocità, ma con il rischio di travolgere '
            'qualcuno',
        'vai dritto allo scopo, ma senza travolgere chi ti sta accanto'),
    'Cavaliere di Spade|capovolta': LaCartaNellaRisposta(
        _s,
        'una fretta imprudente',
        'c\'è fretta, con parole lanciate senza pensare',
        'rallenta e prendi un istante di pausa prima di rispondere'),
    'Regina di Spade|dritta': LaCartaNellaRisposta(
        _f,
        'una franchezza lucida',
        'servono lucidità e franchezza, cioè dire il vero senza giri',
        'di\' con chiarezza ciò che pensi e metti un confine'),
    'Regina di Spade|capovolta': LaCartaNellaRisposta(
        _s,
        'una durezza difensiva',
        'una durezza difensiva tiene lontani gli altri',
        'ammorbidisci il giudizio, a partire da quello su di te'),
    'Re di Spade|dritta': LaCartaNellaRisposta(
        _f,
        'un giudizio equo',
        'serve un giudizio equo, la ragione al servizio del cuore',
        'decidi in base ai fatti e con equità'),
    'Re di Spade|capovolta': LaCartaNellaRisposta(
        _s,
        'una freddezza che ferisce',
        'c\'è un rigore freddo che dimentica le persone',
        'unisci alla logica un gesto di comprensione'),
  };
}

const TonoDellaCarta _f = TonoDellaCarta.favorevole;
const TonoDellaCarta _c = TonoDellaCarta.condizionato;
const TonoDellaCarta _s = TonoDellaCarta.sfavorevole;
