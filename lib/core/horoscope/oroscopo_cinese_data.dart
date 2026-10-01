// GENERATO da tool/_gen_oroscopo_cinese.py a partire da docs/corpus/oroscopo_cinese.md.
// Fonte di verita': il corpus. Non modificare a mano: rigenerare dal corpus.

/// Le frasi dell'oroscopo cinese del giorno (ordine ES voce 08), trascritte
/// dal corpus. Le marche del genere `[m|f|n]` si risolvono alla lettura.
abstract final class OroscopoCineseData {
  /// Scheda Generale: il rapporto fra l'animale del giorno e il tuo.
  static const Map<String, List<String>> rapporti = {
    'armonia': [
      'Oggi le cose fatte in due riescono meglio di quelle fatte in solitudine. Fai la telefonata che rimandi, chiudi un accordo o chiedi l\'aiuto che ti serve. || Oggi è il giorno di {animale_giorno}, che nella tradizione cinese si accorda con {animale_tuo}: è una delle sei coppie in armonia.',
      'Oggi la giornata rende di più accanto a chi ti completa che per conto tuo. Scegli una cosa che stai portando avanti senza aiuto e proponi a una persona precisa di farne metà. || Il giorno lo guida {animale_giorno}: il suo ramo e quello del tuo animale formano una delle sei armonie, due metà che si completano.',
      'Oggi collaborare ti costa meno fatica del solito, anche se niente si muove senza che ti muova tu. Siediti un quarto d\'ora con chi condivide un impegno con te e decidete insieme il prossimo passo. || Il ramo di oggi e quello del tuo anno di nascita sono una coppia che la tradizione cinese chiama "accordo": è una giornata in armonia col tuo animale.',
    ],
    'triplaArmonia': [
      'Oggi funziona ciò che coinvolge più persone: un gruppo, una squadra, la famiglia. Proponi un pranzo o una riunione breve per decidere insieme una cosa che riguarda tutti. || Il ramo di {animale_giorno} e quello di {animale_tuo} appartengono alla stessa terna, il gruppo che la tradizione cinese lega a {elemento_terna}: un\'intesa più larga di una coppia.',
      'Oggi è una giornata buona per ricucire: le persone si ritrovano più volentieri. Rimetti in contatto due persone che da tempo non si parlano, con un messaggio a entrambe o un invito allo stesso tavolo. || Oggi guida {animale_giorno}, che sta nella stessa terna del tuo animale: nell\'almanacco cinese le terne sono alleanze.',
      'Oggi è un buon giorno per coinvolgere gli altri in ciò che non dipende solo da te. Se hai un progetto fermo in attesa di qualcuno, scrivi adesso a quella persona e dille con precisione che cosa ti serve. || Il giorno di {animale_giorno} è alleato del tuo anno: i vostri sono due dei tre rami che insieme fanno {elemento_terna}.',
    ],
    'scontro': [
      'Oggi le spinte vanno in direzioni opposte: non vuol dire che vada male, solo che serve più pazienza. Rimanda a domani la decisione che stavi per prendere di corsa. || Oggi è il giorno di {animale_giorno}, che sta di fronte al tuo animale: l\'almanacco cinese lo chiama scontro.',
      'Oggi è facile trovarsi su fronti opposti, anche per poco. Tieni le cose semplici: fai una cosa alla volta e lascia cadere la discussione che non ti serve vincere. || Il ramo di oggi è l\'opposto del tuo. Gli almanacchi cinesi lo scrivono in chiaro: oggi si scontra con {animale_tuo}.',
      'Oggi ciò che era fermo si muove, anche a strattoni. Se qualcosa si rompe guarda se non era già incrinato; se qualcosa si sblocca lascialo andare senza trattenerlo. || È un giorno di scontro col tuo animale: nella tradizione cinese il ramo di oggi sta di fronte a quello del tuo anno.',
    ],
    'punizione': [
      'Oggi una parola in più pesa più del solito. Misura il tono: rileggi il messaggio prima di inviarlo e cancella la frase che hai scritto solo per avere l\'ultima parola. || Il ramo di oggi e il tuo sono legati da ciò che la tradizione cinese chiama punizione: non un castigo, un attrito che nasce da un eccesso.',
      'Oggi forzare i tempi porta più attrito che risultati. Se qualcuno non ti ha ancora risposto, aspetta a sollecitare. Concedi anche a te una pausa vera fra un impegno e l\'altro. || Oggi {animale_giorno} e {animale_tuo} formano una delle tre punizioni, i gruppi di rami che nella tradizione cinese si puniscono a vicenda.',
      'Oggi la fretta è la parte che si paga. Controlla due volte ciò che firmi o spedisci: un nome, una cifra, un allegato. Se puoi, lascia passare dieci minuti prima di premere invio. || È una giornata di attrito col tuo animale, secondo l\'almanacco cinese: il ramo di oggi e quello del tuo anno stanno in uno dei gruppi che si puniscono.',
    ],
    'punizioneDiSe': [
      'Oggi il rischio sei tu contro di te: tendi a pretendere troppo e a perdonarti poco. Non chiederti più di quanto chiederesti a una persona cara. Scrivi ciò che pretendi da te entro stasera e dimezzalo. || Oggi è il giorno del tuo stesso animale: la tradizione cinese dice che {animale_tuo} con se stesso si punisce.',
      'Oggi i pensieri tendono a girare a vuoto più del solito. Se ti accorgi di rimuginare, fermati e fai una cosa con le mani: lava i piatti, riordina un cassetto, cucina qualcosa. || È il giorno del tuo animale, nella forma che l\'almanacco cinese chiama punizione di sé: Drago, Cavallo, Gallo e Maiale puniscono se stessi quando il giorno ha il loro ramo.',
      'Oggi è facile inciampare per conto proprio, soprattutto con troppe cose in fila. Scegli tre impegni soltanto e portali fino in fondo prima di cominciarne un quarto. || Il ramo di oggi è il tuo. Per {animale_tuo} la tradizione cinese lo legge come un giorno in cui ci si inciampa da soli.',
    ],
    'danno': [
      'Oggi la giornata porta fastidi più che urti, soprattutto dove conti sugli altri. Prima di fare affidamento su una promessa, verificala: chiedi conferma dell\'orario, della consegna, della cifra. || Il giorno è di {animale_giorno}, che disturba l\'accordo del tuo animale: la tradizione cinese lo chiama danno.',
      'Oggi sono possibili piccoli intoppi, un ritardo, un messaggio frainteso: niente di grave, se non lo ingrandisci. Parti dieci minuti prima. Se una risposta ti suona male, chiedi che cosa voleva dire prima di reagire. || Il ramo di oggi e quello del tuo anno sono una delle sei coppie del danno: nella tradizione cinese ognuno dei due rompe l\'accordo dell\'altro.',
      'Oggi ciò che funziona va lasciato in pace: toccarlo rischia di guastarlo. Rimanda la modifica o il cambio di programma che avevi in mente e lascia tutto com\'è fino a domani. || È un giorno di danno per {animale_tuo}, dice l\'almanacco cinese: il ramo di oggi e il suo stanno in una delle sei coppie che si danneggiano.',
    ],
    'armoniaChePunisce': [
      'Oggi con gli altri ci si intende e ci si punzecchia nello stesso momento. Fidati dell\'intesa, ma metti per iscritto i patti: due righe di riepilogo dopo la telefonata bastano. || Oggi {animale_giorno} e {animale_tuo} si accordano e si puniscono insieme: la tradizione cinese conosce questa coppia doppia e la chiama accordo con attrito.',
      'Oggi chi ti somiglia è un buon alleato, anche se non ti capisce al volo come credi. Lavora con quella persona e spiega per intero ciò che ti aspetti, invece di lasciarlo sottinteso. || È una coppia doppia: Serpente e Scimmia sono insieme una delle sei armonie e una delle punizioni, armonia e attrito nello stesso legame.',
      'Oggi la vicinanza fa bene, la confidenza cieca meno. Stai volentieri con chi ti cerca. Tieni però per te la cosa delicata che non hai ancora deciso di raccontare. || Il ramo di oggi e il tuo si cercano e si urtano: nei testi cinesi questa coppia è un accordo che porta con sé un attrito.',
    ],
    'stessoAnimale': [
      'Oggi non è un giorno di favore né di sfida: ciò che fai porta più del solito la tua impronta. Fai a modo tuo una cosa che di solito fai come viene: un lavoro, un messaggio, un piatto. || Oggi è il giorno di {animale_giorno}, il tuo stesso animale: ritorna ogni dodici giorni.',
      'Oggi rendi di più quando fai le cose nel tuo modo che quando ti adatti a quello degli altri. Prenditi il compito che solo tu sai fare così e lascia a qualcun altro quello che chiunque può sbrigare. || Il ramo di oggi è il tuo: torna ogni dodici giorni, e per il tuo animale non è uno dei rapporti che la tradizione classifica.',
      'Oggi la giornata pesa quanto decidi tu, né di più né di meno. Scegli una cosa a cui tieni e mettila per prima, davanti ai messaggi e alle commissioni. || È il giorno del tuo animale: la tradizione cinese non gli dà un peso particolare, perché non è uno dei rapporti classificati.',
    ],
    'nessuno': [
      'Oggi la giornata non ti spinge e non ti frena: va come la porti tu. Per sapere che cosa conviene fare, leggi le righe che seguono e scegli da lì una cosa sola da fare bene. || Oggi guida {animale_giorno}, che col tuo animale non ha legami nella tradizione cinese: né accordo né urto. Il giorno si legge meglio dal suo guardiano.',
      'Oggi è una giornata neutra: quello che ne esce dipende da ciò che ci metti. Decidi adesso una cosa che vuoi vedere fatta entro sera e dedicale la prima ora libera. || Fra {animale_giorno} e {animale_tuo} oggi non c\'è un rapporto classico: né accordo, né terna, né scontro, né punizione, né danno.',
      'Oggi è una buona occasione per le cose ordinarie fatte con cura, senza colpi di scena. Prendi una faccenda di tutti i giorni e falla meglio del solito: la spesa, una risposta da scrivere, la scrivania da riordinare. || Fra il ramo del giorno e quello del tuo anno non c\'è nessun accordo e nessuno scontro: è il caso più frequente nelle tabelle della tradizione cinese.',
      'Oggi niente ti viene incontro e niente ti sbarra la strada: la giornata è libera. Regolati sul consiglio pratico che leggi subito dopo e tieni l\'agenda leggera, con un\'ora vuota da usare come viene. || Il ramo di oggi e il tuo non si cercano e non si respingono: dal lato degli animali la giornata è libera e a parlare resta il guardiano del giorno.',
      'Oggi da fuori non arriva nessuna spinta: il ritmo lo decidi tu. Scegli a che ora cominci e a che ora stacchi, scrivilo e rispettalo come un appuntamento preso con qualcuno. || Oggi {animale_giorno} passa accanto al tuo animale senza toccarlo, dice la tradizione cinese: fra i due rami non c\'è nessun legame.',
    ],
  };

  /// Il titolo in parole della scheda Generale, per rapporto.
  static const Map<String, String> titoliDeiRapporti = {
    'armonia': 'Una giornata d\'intesa',
    'triplaArmonia': 'La forza del gruppo',
    'scontro': 'Una giornata controvento',
    'punizione': 'Misura le parole',
    'punizioneDiSe': 'Non farti la guerra',
    'danno': 'Piccoli intoppi',
    'armoniaChePunisce': 'Intesa con qualche spina',
    'stessoAnimale': 'A modo tuo',
    'nessuno': 'Campo libero',
  };

  /// Scheda Generale: il guardiano del giorno, da Stabilire a Chiudere.
  static const List<List<String>> guardiani = [
    [
      'È il momento di mettere in piedi qualcosa di nuovo. Comincia il corso, l\'abitudine o il progetto che rimandi: basta il primo passo, un\'iscrizione o la prima mezz\'ora. || Il guardiano di oggi è Stabilire, il primo dei dodici: nel calendario cinese è il giorno in cui qualcosa si mette in piedi.',
      'Vanno bene gli inizi e le partenze, meno il rivoltare ciò che è già al suo posto. Prenota il viaggio o scegli la data in cui parti. Se avevi in mente uno scavo in giardino, rimandalo. || Oggi veglia Stabilire: la tradizione cinese lo vuole per gli inizi e per mettersi in viaggio, lo sconsiglia per i lavori di scavo.',
      'È un buon momento per prendere un impegno nuovo e dirlo a voce alta. Accetta l\'incarico o annuncia a qualcuno ciò che hai deciso di fare. Lascia per un altro giorno i traslochi di cose pesanti. || Stabilire guida il giorno: fra i dodici guardiani è quello adatto a prendere un incarico, non ai grandi spostamenti di cose.',
    ],
    [
      'La giornata è adatta a portare via ciò che ingombra. Svuota un armadio, salda un piccolo debito o prenota il controllo che rimandi da mesi: una sola di queste cose basta. || Oggi il guardiano è Togliere: la tradizione cinese lo dedica a ciò che si porta via, dal pulire al curarsi al liberarsi del vecchio.',
      'Conviene fare spazio prima di aggiungere: una cosa tolta vale più di tre cose nuove. Butta dieci oggetti che non usi, disdici un abbonamento inutile o libera la scrivania prima di prendere altro. || Togliere veglia sul giorno: è il guardiano che il calendario cinese lega al pulire e al liberarsi del vecchio.',
      'Vanno bene la cura di te e i conti in sospeso da sistemare, meno le partenze. Prenditi un\'ora per un bagno lungo o per rispondere a chi aspetta da te una risposta. Se puoi, sposta il viaggio a un altro giorno. || È una giornata di Togliere, dice l\'almanacco cinese: buona per curarsi e per liberarsi del vecchio, sconsigliata per partenze e traslochi.',
    ],
    [
      'È un giorno per festeggiare ciò che c\'è già, più che per inseguire altro. Organizza una cena con i tuoi o di\' un grazie per bene, a voce, alla persona che se lo merita da tempo. || Oggi veglia Pieno, il guardiano del raccolto: il calendario cinese lo lega alle celebrazioni e agli incontri di famiglia.',
      'La giornata parla di abbondanza, non di avidità: va bene incassare e fare il punto, non caricarti di impegni nuovi. Chiedi un pagamento che ti spetta e rimanda la risposta a chi ti propone un incarico. || Il guardiano Pieno dice abbondanza: è adatto a cercare un guadagno, non a prendere un nuovo incarico.',
      'Meglio restare dove sei e goderti ciò che hai raccolto. Brinda a un risultato, anche piccolo, con chi ti ha dato una mano. Scatoloni, traslochi e lavori in giardino possono aspettare. || È un giorno di Pieno: la tradizione cinese lo vuole per le celebrazioni e i guadagni, non per i traslochi né per i lavori di terra.',
    ],
    [
      'La giornata è piana, né favorevole né contraria: perfetta per aggiustare ciò che è storto. Ripara la cosa rotta che hai in casa da settimane: la lampadina, la cerniera, il rubinetto che gocciola. || Il guardiano di oggi è Livellare: nel calendario cinese è il giorno adatto a riparare, sistemare e abbellire.',
      'Non è una giornata da svolte: conviene rimettere in pari ciò che è rimasto indietro. Riordina una stanza, aggiorna l\'agenda o ricambia il favore a chi ultimamente ha dato più di te. || Oggi veglia Livellare: la tradizione cinese lo vuole per sistemare e lo sconsiglia per ciò che chiama "scavare canali", cioè aprire strade nuove.',
      'Le cose ordinarie vanno bene, le deviazioni meno. Finisci di sistemare quello che c\'è prima di avviare altro: completa la pratica a metà, rispondi ai messaggi arretrati, poi pensa al resto. || Livellare guida il giorno: fra i dodici guardiani è quello che vuole sistemare ciò che c\'è, non aprire strade nuove.',
    ],
    [
      'Riescono meglio le cose che devono durare. Metti per iscritto un piano in cinque righe e scegli una data precisa per il primo passo: scrivila in agenda. || Oggi veglia Fissare: la tradizione cinese lo lega a ciò che deve restare, dai piani alle decisioni che devono durare.',
      'Serve stabilità: si decide bene a mente fredda, si discute male. Prendi con calma la decisione che aspetta da giorni. Se una lite si affaccia, di\' che ne riparlate domani. || Il guardiano Fissare chiede stabilità: l\'almanacco cinese lo dà adatto alle decisioni che devono durare e sconsigliato per liti e cause.',
      'Conviene restare, costruire e programmare più che muoversi. Prepara il programma della settimana o del mese. Il viaggio e il confronto duro spostali a un giorno più adatto. || È un giorno di Fissare: nel calendario cinese va bene per pianificare, mentre partenze e liti hanno giorni migliori.',
    ],
    [
      'È una giornata per trattenere e concludere, non per lasciare andare. Riprendi una cosa iniziata e portala a termine prima di sera: il lavoro a metà, il libro all\'ultimo capitolo, la pratica in sospeso. || Il guardiano di oggi è Tenere: la tradizione cinese lo vuole per trattenere, non per lasciare andare.',
      'Meglio custodire ciò che hai costruito che cercare altrove. Fai manutenzione a una cosa tua: una copia delle carte importanti, un controllo alla bici, una telefonata a chi ti è vicino da anni. Compravendite e partenze, un altro giorno. || Oggi veglia Tenere: per compravendite e partenze l\'almanacco cinese consiglia altri giorni.',
      'Presa salda e pochi movimenti: è così che la giornata rende. Pianta qualcosa, anche solo un vaso sul balcone. Se ti chiedono una firma in fretta, prenditi un giorno per rileggere. || Tenere guida il giorno: nel calendario cinese è adatto a costruire, piantare e portare a termine, non a commerciare.',
    ],
    [
      'Non è il momento di cominciare cose importanti: la giornata serve piuttosto a farla finita con ciò che non regge più. Smonta il mobile rotto, svuota la cantina, butta ciò che tieni solo per abitudine. || Oggi il guardiano è Rompere, il più severo dei dodici: gli almanacchi cinesi sconsigliano di cominciare cose importanti.',
      'Niente firme e niente inizi: la giornata è fatta per tagliare. Di\' un no chiaro a una richiesta che ti pesa e disdici un impegno che hai preso controvoglia. || Rompere veglia sul giorno: gli almanacchi cinesi ne scrivono "nessuna impresa conviene" e lo tengono buono per demolire il vecchio.',
      'I programmi vanno tenuti leggeri: le cose nuove possono aspettare. Sposta a domani l\'avvio di ciò che conta. Usa il tempo che si libera per te: una camminata, una dormita, un\'ora senza telefono. || È un giorno di Rompere: la tradizione cinese lo vuole solo per demolire il vecchio e per cercare cure.',
    ],
    [
      'Serve prudenza, senza rischi fisici inutili. Guida con calma e parti qualche minuto prima. Se dovevi salire su una scala o su un tetto, fallo un altro giorno o fatti aiutare. || Il guardiano di oggi è Pericolo: la tradizione cinese chiede prudenza con l\'altezza e con l\'acqua, sconsiglia di salire in alto e di andare per mare.',
      'Nessun presagio, solo un invito alla cautela: la giornata è buona per raccoglierti, meno per spostarti. Resta in zona e ritagliati mezz\'ora di silenzio, a casa o in un posto tranquillo. || Oggi veglia Pericolo: il calendario cinese lo dà adatto alle cerimonie e al raccoglimento, non ai traslochi.',
      'Tutto va meglio se fai con calma ciò che di solito fai in fretta. Scendi le scale senza telefono in mano, attraversa guardando due volte. In cantiere o su una scala a pioli, un occhio in più. || Pericolo guida il giorno: fra i dodici guardiani è quello che vuole cautela, soprattutto dove si sale in alto.',
    ],
    [
      'Poche giornate sono così favorevoli a ciò che deve arrivare in fondo. Consegna il lavoro pronto, conferma l\'appuntamento, firma l\'accordo che avete già discusso. || Oggi veglia Compiere, uno dei guardiani più favorevoli: la tradizione cinese lo vuole per ciò che deve arrivare in fondo.',
      'Le cose rimaste a metà hanno una buona occasione per concludersi. Se hai un sì da dare o da chiedere, fallo entro sera con una telefonata. Lascia fuori le discussioni. || Il guardiano Compiere porta a termine: nel calendario cinese è adatto agli accordi, sconsigliato per liti e cause.',
      'Vanno bene gli accordi, le partenze e gli inizi di coppia. Scegli il giorno della partenza, proponi l\'uscita a chi ti piace o stringi la mano su un\'intesa. Evita solo di trascinare qualcuno in una lite. || È un giorno di Compiere: accordi, partenze e inizi di coppia vanno bene secondo l\'almanacco cinese, liti e cause no.',
    ],
    [
      'Si tirano le somme più che avviare cose nuove. Incassa ciò che ti devono, archivia le carte sparse, fai il bilancio del mese in una pagina. || Il guardiano di oggi è Raccogliere: la tradizione cinese lo lega al raccolto e ai frutti da incassare.',
      'Non è il momento di seminare ma di prendere ciò che è maturo. Chiedi il compenso che ti spetta, con un messaggio cortese e la cifra scritta. Poi rimetti in ordine ciò che hai guadagnato. || Oggi veglia Raccogliere: fra i dodici guardiani è quello adatto a incassare e a raccogliere i frutti.',
      'Rendono bene lo studio e il mettere da parte, meno le partenze. Dedica un\'ora a imparare una cosa che ti serve e metti via qualcosa, anche una piccola somma. Il viaggio può slittare. || Raccogliere guida il giorno: il calendario cinese lo dà buono per studiare e per mettere da parte, mentre le partenze le rimanda.',
    ],
    [
      'Le porte si aprono più volentieri a chi bussa. Presentati a una persona che vuoi conoscere o fai la richiesta che tieni in sospeso: un aumento, un favore, un appuntamento. || Oggi veglia Aprire, il guardiano delle porte che si aprono: la tradizione cinese lo vuole per inaugurare, presentarsi, chiedere.',
      'Rende di più farti vedere che aspettare che ti cerchino. Manda la candidatura, fai la proposta, rispondi a chi aspetta da te un cenno e invitalo a entrare. || Il guardiano Aprire invita a farsi vedere: nel calendario cinese è il giorno adatto a chiedere e a cominciare.',
      'Gli inizi vanno bene quasi tutti. Avvia la cosa nuova a cui pensi: il primo giorno di un\'attività, il primo invito a una persona, la prima sera nella casa nuova. Lascia stare soltanto gli scavi e i lavori in giardino. || È un giorno di Aprire: buono per gli inizi, secondo l\'almanacco cinese, che lascia fuori solo i lavori di terra e i riti funebri.',
    ],
    [
      'È una giornata buona per rientrare in te e mettere al sicuro ciò che conta. Stasera spegni il telefono un\'ora prima del solito e vai a letto presto: il riposo è la cosa più utile che puoi fare. || Il guardiano di oggi è Chiudere: la tradizione cinese lo lega al riposo e a ciò che si mette al sicuro.',
      'Niente inaugurazioni e niente grandi richieste: conviene tappare le falle. Salva una copia di ogni file importante, ripara la serratura che non tiene, controlla che porte e finestre siano a posto. || Oggi veglia Chiudere: l\'almanacco cinese lo sconsiglia per le inaugurazioni e per cercare guadagni, lo vuole per mettere al sicuro.',
      'È il caso di tenerti stretto ciò che hai, senza avviare altro né metterti in viaggio. Metti in ordine i documenti e le chiavi, riponi ciò che è in giro. Tutto il resto lo riprendi domani. || Chiudere guida il giorno: l\'almanacco cinese lo sconsiglia per aprire un\'attività e per partire.',
    ],
  ];

  /// Che cosa conviene e che cosa no col guardiano, da Stabilire a Chiudere.
  static const List<(String, String)> consigliDelGuardiano = [
    (
      'cominciare un percorso, partire, prendere un incarico',
      'lavori di scavo, grandi spostamenti di cose'
    ),
    (
      'pulire, curarsi, liberarsi del vecchio, piccoli affari',
      'partenze, traslochi, candidature a un incarico'
    ),
    (
      'celebrare, incontri di famiglia, aprire un\'attività, cercare un guadagno',
      'traslochi, lavori di terra, prendere un nuovo incarico'
    ),
    (
      'riparare, sistemare, abbellire',
      'aprire strade nuove (la tradizione dice "scavare canali")'
    ),
    (
      'pianificare, decisioni che devono durare, cerimonie',
      'liti, cause, partenze'
    ),
    (
      'tenere fermo ciò che hai, costruire, piantare, portare a termine',
      'aprire un\'attività, commerciare, traslocare, partire'
    ),
    (
      'demolire il vecchio, cercare cure',
      'ogni cosa importante di buon augurio (gli almanacchi scrivono "诸事不宜", nessuna impresa conviene)'
    ),
    ('cerimonie, raccoglimento', 'salire in alto, andare per mare, traslocare'),
    (
      'aprire, firmare accordi, cominciare un\'unione, partire, traslocare, curarsi',
      'liti e cause'
    ),
    ('incassare, raccogliere i frutti, studiare', 'partire, i riti funebri'),
    (
      'aprire un\'attività, inizi di coppia, entrare in casa nuova, chiedere',
      'lavori di terra, i riti funebri'
    ),
    (
      'riposo, mettere al sicuro, chiudere falle',
      'aprire un\'attività, sposarsi, partire, cercare guadagni'
    ),
  ];

  /// Fortuna, Lavoro e Amore: i Dieci Dei, per scheda e per dio.
  static const Map<String, Map<String, List<String>>> dei = {
    'fortuna': {
      'compagno': [
        'Oggi il denaro si muove meglio nelle spese fatte insieme che nei guadagni personali. Se c\'è un conto da dividere, una cena o una bolletta, dividilo subito e alla pari. || Il dio di oggi nel BaZi è il Compagno: il giorno ha il tuo stesso elemento con la tua stessa polarità e divide con te ciò che c\'è.',
        'Oggi quello che entra non è solo tuo: entra per più persone. Prima di incassare o di spendere chiarisci a voce chi mette quanto e chi prende quanto, così nessuno resta col dubbio. || Il Compagno è di turno: nel BaZi chi ha il tuo stesso elemento contende la Ricchezza in forma leggera. Ciò che c\'è si spartisce fra pari.',
        'Oggi sul denaro non ci sono colpi di fortuna, c\'è qualche spesa in compagnia. Stasera segna quello che hai speso, voce per voce, per sapere a che punto sei. || È la giornata del Compagno, il dio che ha il tuo stesso elemento: nel BaZi contende la Ricchezza, ma senza strappi.',
      ],
      'rivale': [
        'Oggi il denaro tende a scivolare via più facilmente del solito. Tieni fermo il portafoglio davanti a prestiti, acquisti d\'impulso e offerte troppo belle. || Il dio di oggi nel BaZi è il Rivale, che la tradizione chiama "chi prende la ricchezza".',
        'Oggi non è giornata da spese importanti: i soldi escono senza che tu te ne accorga. Rimanda a un altro giorno la spesa grande che hai in mente, anche se l\'occasione sembra buona. || Il Rivale è di turno: ha il tuo stesso elemento con polarità opposta. Non annuncia un furto, dice che oggi il denaro tende a uscire.',
        'Oggi qualcuno può chiederti più soldi o più favori di quanto ti conviene dare. Rispondi con un no gentile; se proprio vuoi aiutare, fissa prima una cifra che non ti pesa. || È la giornata del Rivale, che nel BaZi contende ciò che hai: il suo nome cinese vuol dire alla lettera "rapina della ricchezza".',
      ],
      'nutrimento': [
        'Oggi il denaro passa da quello che sai fare bene, non dalla sorte. Scegli il lavoro che ti riesce meglio e curalo fino in fondo: è quello che oggi ha più valore. || Il dio di oggi nel BaZi è il Nutrimento: il tuo elemento lo genera e lui a sua volta genera la Ricchezza. È la vena da cui nasce il guadagno.',
        'Oggi è un buon giorno per far pagare il giusto ciò che crei. Proponi il tuo lavoro a una persona che può volerlo e di\' il prezzo con calma, senza abbassarlo prima che te lo chiedano. || Il Nutrimento è di turno: nel BaZi è ciò che produci con calma. La regola dice che genera la Ricchezza: il guadagno viene da ciò che sai fare.',
        'Oggi il guadagno è lento ma pulito. Avvia una cosa piccola che rende nel tempo: un preventivo mandato, un contatto ripreso, una tua capacità messa in vetrina. || È la giornata del Nutrimento: il tuo elemento lo genera con la stessa polarità. Nel BaZi alimenta la Ricchezza senza fretta.',
      ],
      'ufficialeFerito': [
        'Oggi un\'idea originale può trasformarsi in guadagno, a patto di rispettare gli accordi già presi. Scrivila in tre righe e falla vedere a chi potrebbe pagarla. || Il dio di oggi nel BaZi è l\'Ufficiale Ferito: il tuo elemento lo genera con polarità opposta. È talento che corre e genera la Ricchezza, ma con impeto.',
        'Oggi i soldi passano da un\'iniziativa tua, fuori dagli schemi. Prima di muoverti rileggi il contratto o il patto che hai in corso: le clausole oggi non si saltano. || L\'Ufficiale Ferito è di turno: nel BaZi genera la Ricchezza come il Nutrimento, però è l\'espressione che rompe le regole.',
        'Oggi sul denaro sei brillante e impaziente insieme. Metti la fantasia in un progetto e lascia fermo il conto: nessuna spesa decisa in meno di un\'ora. || È la giornata dell\'Ufficiale Ferito: nel BaZi la sua forza è creare ciò che porta guadagno, il suo rischio è l\'impeto con cui lo fa.',
      ],
      'ricchezzaIndiretta': [
        'Oggi una proposta di guadagno può arrivare da una strada insolita. Ascoltala fino in fondo, fatti dire cifre e tempi, poi prenditi una notte prima di rispondere. || Il dio di oggi nel BaZi è la Ricchezza indiretta: il tuo elemento la governa con la stessa polarità. È il denaro delle occasioni, che arriva di lato.',
        'Oggi il denaro si muove: entra ed esce con facilità. È un buon giorno per trattare un prezzo o un compenso, non per affidarti al caso: niente scommesse. || La Ricchezza indiretta è di turno: nel BaZi è il denaro che circola, quello che non viene dal guadagno regolare.',
        'Oggi può capitare un\'entrata fuori dal solito, ma anche una spesa fuori dal solito. Sta a te quale lasciar passare: fissa adesso un tetto per le spese non previste di oggi. || È la giornata della Ricchezza indiretta: il tuo elemento la governa. Nel BaZi sono occasioni e denaro che circola, in entrata come in uscita.',
      ],
      'ricchezzaDiretta': [
        'Oggi il denaro premia il metodo più dell\'inventiva. Prendi mezz\'ora per mettere in fila ricevute, scadenze e pagamenti del mese: sapere a che punto sei vale già qualcosa. || Il dio di oggi nel BaZi è la Ricchezza diretta: il tuo elemento la governa con polarità opposta. È il denaro guadagnato con metodo.',
        'Oggi non ci sono colpi di scena: le entrate vengono da dove devono venire. Approfittane per mettere da parte una cifra, anche piccola, prima di spendere il resto. || La Ricchezza diretta è di turno: nel BaZi è il guadagno regolare, frutto del lavoro, quello che non sorprende.',
        'Oggi si può raccogliere ciò che hai seminato col tuo lavoro. Manda la fattura rimasta nel cassetto o ricorda a chi ti deve del denaro la data che avevate concordato. || È la giornata della Ricchezza diretta: nel BaZi è ciò che il tuo elemento governa con le sue forze, il frutto che gli spetta.',
      ],
      'setteUccisioni': [
        'Oggi il denaro va verso spese che non hai scelto: scadenze, obblighi, conti da saldare. Paga quelle per prime, poi concediti una pausa senza pensarci più. || Il dio di oggi nel BaZi sono le Sette Uccisioni, la pressione: governano il tuo elemento. La regola dice che la Ricchezza le nutre, cioè va verso gli obblighi.',
        'Oggi i soldi servono a difenderti, non a crescere. Lascia stare ogni rischio e controlla di avere coperto gli impegni di questa settimana: affitto, rate, bollette. || Le Sette Uccisioni sono di turno: nel BaZi governano il tuo elemento con la stessa polarità. La Ricchezza si consuma per farvi fronte.',
        'Oggi qualcuno può pretendere soldi o metterti fretta su un pagamento. Rispondi con i numeri alla mano: date, importi, ricevute. Se serve, chiedi un giorno per verificare. || È la giornata delle Sette Uccisioni: nel BaZi sono pressione e sfida. Sul denaro prendono la forma di richieste che vengono da fuori.',
      ],
      'ufficialeDiretto': [
        'Oggi il denaro va dove c\'è una regola da rispettare. Paga una tassa o una bolletta in sospeso, oppure affronta una spesa che serve al tuo buon nome. || Il dio di oggi nel BaZi è l\'Ufficiale diretto: governa il tuo elemento con polarità opposta. La Ricchezza lo nutre, quindi il denaro va verso posizione e doveri.',
        'Oggi spendere per ciò che ti rende affidabile è un buon uso del denaro. Salda un piccolo debito o rinnova ciò che ti serve per lavorare in regola; gli sfizi possono aspettare. || L\'Ufficiale diretto è di turno: nel BaZi è regola, responsabilità, riconoscimento. La Ricchezza lo alimenta.',
        'Oggi sul denaro viene prima l\'ordine. Riprendi una cosa rimasta indietro, un modulo da consegnare o una ricevuta da archiviare: mettila a posto entro sera. || È la giornata dell\'Ufficiale diretto: nella lettura dei Dieci Dei consuma la Ricchezza, che si spende per i doveri prima che per i desideri.',
      ],
      'sigilloIndiretto': [
        'Oggi sul fronte del denaro la cosa preziosa è un\'informazione o un\'intuizione, non un\'entrata. Tieni le orecchie aperte e verifica la notizia che ti colpisce prima di contarci. || Il dio di oggi nel BaZi è il Sigillo indiretto: genera il tuo elemento con la stessa polarità e non tocca la Ricchezza. Il suo sostegno ha una forma insolita.',
        'Oggi c\'è poco movimento sul conto e molto nella testa. Quando ti viene un\'idea su come guadagnare o risparmiare scrivila subito su un foglio, per valutarla con calma un altro giorno. || Il Sigillo indiretto è di turno: nel BaZi è sostegno insolito e intuizione. Con la Ricchezza non ha legami, né per darla né per toglierla.',
        'Oggi il denaro non è il tema della giornata. Dedica un\'ora a imparare una cosa che ti serve nel lavoro o nella gestione di casa: una lezione, un capitolo, una guida pratica. || È la giornata del Sigillo indiretto: nella lettura dei Dieci Dei i Sigilli generano il tuo elemento e lasciano ferma la Ricchezza.',
      ],
      'sigilloDiretto': [
        'Oggi il denaro è protetto più che in crescita. È un buon giorno per chiedere un consiglio a chi ne sa più di te su un dubbio di soldi che ti porti dietro da tempo. || Il dio di oggi nel BaZi è il Sigillo diretto: genera il tuo elemento con polarità opposta. Protegge più che arricchire.',
        'Oggi la buona sorte ha la forma di un sostegno, da una persona o da un\'istituzione. Se qualcuno ti offre un aiuto accettalo con un grazie, senza sentirti in debito. || Il Sigillo diretto è di turno: nel BaZi è protezione, studio, cura. Porta sostegno, non guadagno.',
        'Oggi sul fronte del denaro la giornata è tranquilla. Custodisci ciò che hai: controlla che risparmi e documenti importanti siano al loro posto, poi lascia stare ogni azzardo. || È la giornata del Sigillo diretto: nella lettura dei Dieci Dei i Sigilli non toccano la Ricchezza, la lasciano dov\'è.',
      ],
    },
    'lavoro': {
      'compagno': [
        'Oggi al lavoro si va meglio in squadra che in solitaria; farsi notare da chi decide è più difficile. Prendi un compito da fare a quattro mani e portalo avanti con un collega. || Il dio di oggi nel BaZi è il Compagno: il giorno ha il tuo stesso elemento con la tua stessa polarità. Sul lavoro sono i pari grado, le persone come te.',
        'Oggi il lavoro scorre in orizzontale, fra colleghi più che verso i capi. Chiedi una mano a chi ha già risolto il tuo problema; in cambio offri la tua su una cosa che sai fare. || Il Compagno è di turno: nel BaZi chi ha il tuo stesso elemento sta al tuo fianco, non sopra di te. Per il lavoro vuol dire collaborazione orizzontale.',
        'Oggi sul lavoro conta la rete delle persone al tuo livello. Coltivala senza metterti a confronto: un caffè con una collega, un grazie a chi ti ha dato una mano la settimana scorsa. || È la giornata del Compagno: nella scheda del lavoro il BaZi guarda all\'Ufficiale, l\'autorità, mentre il Compagno porta il confronto fra pari.',
      ],
      'rivale': [
        'Oggi al lavoro c\'è concorrenza: qualcuno punta al tuo stesso posto o al tuo stesso risultato. Resta sui fatti e lascia traccia scritta di ciò che fai, con un messaggio di riepilogo. || Il dio di oggi nel BaZi è il Rivale: ha il tuo stesso elemento con polarità opposta e contende ciò che hai. Sul lavoro è la concorrenza fra pari.',
        'Oggi sul lavoro non tutti giocano a carte scoperte. L\'idea a cui tieni raccontala solo a chi conosci bene; con gli altri aspetta che sia pronta. || Il Rivale è di turno: nel BaZi ha il tuo stesso elemento, quindi ti somiglia, ma contende ciò che hai.',
        'Oggi sul lavoro la competizione si sente. Rispondi col lavoro finito, non con le parole: consegna una cosa completa prima di sera e lascia cadere le frecciate. || È la giornata del Rivale: nella lettura dei Dieci Dei lui e il Compagno portano sul lavoro la gara fra chi sta allo stesso livello.',
      ],
      'nutrimento': [
        'Oggi il lavoro ti viene con naturalezza, specie dove hai mano. Dedica le ore migliori al compito che ti riesce meglio e consegnalo senza presentazioni: si spiega da solo. || Il dio di oggi nel BaZi è il Nutrimento: il tuo elemento lo genera con la stessa polarità. È ciò che produci con calma, il talento che lavora senza sforzo.',
        'Oggi al lavoro la qualità conta più della velocità. Se qualcuno ti mette fretta, rispondi con una cosa fatta bene e con una data di consegna realistica: la pressione la regge la competenza. || Il Nutrimento è di turno: la regola del BaZi dice che doma le Sette Uccisioni, cioè che il talento tiene a bada la pressione.',
        'Oggi è un buon giorno per creare, scrivere, insegnare: i risultati vengono senza forzare. Spiega a un collega una cosa che sai fare, oppure butta giù la prima stesura di un testo. || È la giornata del Nutrimento: nella lettura dei Dieci Dei è la vena che produce, quella che il tuo elemento genera da sé.',
      ],
      'ufficialeFerito': [
        'Oggi al lavoro hai idee brillanti e pazienza corta. Con i capi scegli le parole prima di parlare: una critica giusta detta male oggi diventa un problema tuo. || Il dio di oggi nel BaZi è l\'Ufficiale Ferito: il tuo elemento lo genera con polarità opposta. La regola dice che urta l\'Ufficiale, cioè i superiori e le regole.',
        'Oggi la voglia di cambiare le regole del lavoro è forte. Metti la proposta per iscritto, con un esempio e con i costi, invece di lanciarla a caldo in riunione. || L\'Ufficiale Ferito è di turno: nel BaZi è l\'espressione che rompe le regole. Quando incontra l\'Ufficiale, che è l\'autorità, nasce attrito.',
        'Oggi sul lavoro la creatività paga, la sfida a chi comanda no. Usa l\'inventiva per risolvere un problema concreto del tuo gruppo e tieni per te la battuta sul capo. || È la giornata dell\'Ufficiale Ferito: nella lettura dei Dieci Dei è il dio che attacca l\'Ufficiale, cioè la regola, l\'autorità, la carriera.',
      ],
      'ricchezzaIndiretta': [
        'Oggi al lavoro può presentarsi un\'occasione laterale: un contatto nuovo, un progetto che non era previsto. Ascolta tutta la proposta e fai due domande prima di dire no. || Il dio di oggi nel BaZi è la Ricchezza indiretta: il tuo elemento la governa con la stessa polarità. Sono le occasioni che arrivano di lato.',
        'Oggi il lavoro cresce attraverso le relazioni. Telefona a una persona del tuo giro che non senti da tempo, anche solo per chiedere come va: può aprire qualcosa. || La Ricchezza indiretta è di turno: la regola del BaZi dice che la Ricchezza nutre l\'Ufficiale, cioè che le risorse alimentano la carriera.',
        'Oggi le risorse che sostengono il tuo lavoro vengono da fuori: un aiuto, uno strumento, una segnalazione. Accoglile con metodo: segna chi ti ha dato cosa e per quando. || È la giornata della Ricchezza indiretta: nel BaZi è ciò che circola e arriva di lato. Letta sul lavoro, nutre l\'Ufficiale, cioè la carriera.',
      ],
      'ricchezzaDiretta': [
        'Oggi al lavoro le risorse ci sono: sta a te usarle bene. Prendi un\'ora per organizzare budget, tempi e strumenti della settimana, con una lista scritta. || Il dio di oggi nel BaZi è la Ricchezza diretta: il tuo elemento la governa con polarità opposta. Sono le risorse regolari, frutto del lavoro.',
        'Oggi è il lavoro concreto a tenere salda la tua posizione. Chiudi le pratiche aperte e consegna ciò che è quasi finito, invece di cominciare altro. || La Ricchezza diretta è di turno: la regola del BaZi dice che la Ricchezza nutre l\'Ufficiale, cioè che il frutto del lavoro sostiene la posizione.',
        'Oggi il lavoro fatto con ordine si nota. Scrivi i compiti dal più urgente al meno urgente e procedi uno alla volta, spuntandoli man mano che li chiudi. || È la giornata della Ricchezza diretta: nel BaZi è il guadagno regolare, frutto del lavoro. Letta sul lavoro, dà peso a chi procede con ordine.',
      ],
      'setteUccisioni': [
        'Oggi al lavoro c\'è pressione: richieste dure, una sfida che ti mette alla prova. Si regge con la disciplina: fissa un orario per ogni compito e rispettalo. || Il dio di oggi nel BaZi sono le Sette Uccisioni: governano il tuo elemento con la stessa polarità. Sono una forza che mette alla prova.',
        'Oggi sul lavoro qualcuno può alzare la voce o la posta. Rispondi con calma e con un piano: tre punti scritti, chi fa cosa, entro quando. || Le Sette Uccisioni sono di turno: nel BaZi stanno con l\'Ufficiale diretto fra ciò che controlla il tuo elemento, cioè la regola e l\'autorità.',
        'Oggi il lavoro chiede coraggio. Affronta la cosa più difficile per prima, al mattino, finché hai energie; le faccende leggere lasciale al pomeriggio. || È la giornata delle Sette Uccisioni: nella lettura dei Dieci Dei governano il tuo elemento. Sul lavoro vogliono dire pressione e sfida.',
      ],
      'ufficialeDiretto': [
        'Oggi al lavoro è più facile farsi riconoscere per la serietà. È un buon giorno per parlare con chi decide: chiedi un colloquio e porta una richiesta precisa. || Il dio di oggi nel BaZi è l\'Ufficiale diretto: governa il tuo elemento con polarità opposta. È regola, responsabilità, riconoscimento.',
        'Oggi sul lavoro correttezza e puntualità contano più del solito. Arriva cinque minuti prima, con i documenti già pronti e le risposte alle domande che puoi prevedere. || L\'Ufficiale diretto è di turno: nel BaZi è ciò che controlla il tuo elemento, cioè la regola, l\'autorità, la carriera.',
        'Oggi la tua affidabilità è sotto gli occhi di tutti. Mantieni la parola data: se hai promesso una risposta o una consegna, falla avere oggi, anche in due righe. || È la giornata dell\'Ufficiale diretto: nella lettura dei Dieci Dei è il dio a cui la scheda del lavoro guarda per primo.',
      ],
      'sigilloIndiretto': [
        'Oggi al lavoro ti vengono soluzioni non convenzionali. Ritagliati un paio d\'ore senza interruzioni per il compito che chiede più concentrazione, col telefono in silenzio. || Il dio di oggi nel BaZi è il Sigillo indiretto: genera il tuo elemento con la stessa polarità. È intuizione, sostegno insolito, studio personale.',
        'Oggi sul lavoro capisci le cose di traverso, per intuito più che per ragionamento. Annota quello che ti sembra di aver capito e rimanda a domani la verifica, prima di agire. || Il Sigillo indiretto è di turno: la regola del BaZi dice che i Sigilli trasformano l\'Ufficiale in sostegno. Qui il sostegno passa dall\'intuizione.',
        'Oggi al lavoro rende di più pensare che discutere. Sposta una riunione che non serve e usa quel tempo per imparare una competenza nuova, anche una sola funzione di uno strumento. || È la giornata del Sigillo indiretto: nella lettura dei Dieci Dei genera il tuo elemento e ti sostiene in una forma insolita.',
      ],
      'sigilloDiretto': [
        'Oggi al lavoro puoi contare su un sostegno: un superiore, un maestro, un\'istituzione. Chiedi una guida a una di queste figure su un passaggio che non ti è chiaro. || Il dio di oggi nel BaZi è il Sigillo diretto: genera il tuo elemento con polarità opposta. È protezione, studio, cura, che vengono dall\'alto.',
        'Oggi è un buon giorno per formarti sul lavoro. Iscriviti a un corso, informati su una certificazione o chiedi a chi ha più esperienza di mostrarti come fa. || Il Sigillo diretto è di turno: la regola del BaZi dice che l\'Ufficiale genera il Sigillo che sostiene te. L\'autorità diventa insegnamento.',
        'Oggi sul lavoro qualcuno ti copre le spalle. Ringrazia quella persona a voce e ricambia nel modo più semplice: fai bene la tua parte, fino all\'ultimo dettaglio. || È la giornata del Sigillo diretto: nel BaZi l\'Ufficiale genera il Sigillo e il Sigillo sostiene te. Per questo si parla di protezione dall\'alto.',
      ],
    },
    'amoreDonna': {
      'compagno': [
        'Oggi il cuore sta bene fra le persone che ti somigliano, più che nei momenti a due. Organizza una serata con gli amici di sempre: ti rimette in contatto con quello che sei. || Il dio di oggi nel BaZi è il Compagno: ha il tuo stesso elemento e la tua stessa polarità. Nell\'amore di una donna porta altre persone nel quadro.',
        'Fra te e chi ami oggi la complicità viene prima della passione. Parla alla pari con chi ami, come in un\'amicizia fidata: racconta una cosa della tua giornata che di solito tieni per te. || Oggi è di turno il Compagno, fra i Dieci Dei del BaZi: ha il tuo stesso elemento e la tua stessa polarità. Nell\'amore di una donna porta altre persone nel quadro.',
        'Il legame oggi somiglia più a un\'amicizia che a un desiderio. Va bene così: proponi una cosa da fare fianco a fianco, una passeggiata o un film, senza chiederti che cosa manca. || Nel BaZi il giorno di oggi ti porta il Compagno: ha il tuo stesso elemento e la tua stessa polarità. Nell\'amore di una donna porta altre persone nel quadro.',
      ],
      'rivale': [
        'Oggi in amore può sembrarti che qualcuno si metta in mezzo. Prima di costruirci sopra un film fai una domanda chiara a chi ami, poi giudica da ciò che ti risponde. || Il dio di oggi nel BaZi è il Rivale: ha il tuo stesso elemento con polarità opposta, contende ciò che hai. Nell\'amore di una donna porta altre persone nel quadro.',
        'La gelosia oggi scatta per poco. Se un dettaglio ti punge lascialo riposare fino a sera, senza controllare telefoni né profili: un\'ombra non è ancora una storia. || Oggi è di turno il Rivale, fra i Dieci Dei del BaZi: ha il tuo stesso elemento con polarità opposta, contende ciò che hai. Nell\'amore di una donna porta altre persone nel quadro.',
        'In amore oggi è facile metterti a confronto con altre persone, o con l\'idea che hai di te. Lascia stare i paragoni: ripensa a un fatto concreto che ti ha dato fiducia in questo legame. || Nel BaZi il giorno di oggi ti porta il Rivale: ha il tuo stesso elemento con polarità opposta, contende ciò che hai. Nell\'amore di una donna porta altre persone nel quadro.',
      ],
      'nutrimento': [
        'Oggi l\'amore è dolce, fatto di piaceri semplici. Cucina per qualcuno a cui tieni oppure lascia che qualcuno cucini per te: a tavola ci si avvicina. || Il dio di oggi nel BaZi è il Nutrimento: il tuo elemento lo genera con la stessa polarità, è ciò che produci con calma. Nella scheda dell\'amore è dolcezza, piacere semplice.',
        'Il legame oggi cresce con i gesti piccoli, più che con le dichiarazioni. Porta un caffè, manda un messaggio a metà giornata, tieni un posto libero accanto a te. || Oggi è di turno il Nutrimento, fra i Dieci Dei del BaZi: il tuo elemento lo genera con la stessa polarità, è ciò che produci con calma. Nella scheda dell\'amore è dolcezza, piacere semplice.',
        'Fra voi oggi c\'è tenerezza, con un passo lento. Rimanda i bilanci di coppia a un altro giorno: stasera scegli una cosa piacevole da fare insieme, senza discuterne. || Nel BaZi il giorno di oggi ti porta il Nutrimento: il tuo elemento lo genera con la stessa polarità, è ciò che produci con calma. Nella scheda dell\'amore è dolcezza, piacere semplice.',
      ],
      'ufficialeFerito': [
        'Oggi in amore la lingua corre più del cuore, una critica di troppo pesa più del previsto. Prima di parlare conta fino a dieci, poi tieni solo l\'osservazione che serve davvero. || Il dio di oggi nel BaZi è l\'Ufficiale Ferito: il tuo elemento lo genera con polarità opposta, è l\'espressione che rompe le regole. Urta l\'Ufficiale, la figura del partner: per una donna è il segno classico dell\'attrito.',
        'Con chi ami oggi senti il bisogno di dire tutto. Dillo con dolcezza, una cosa alla volta; poi fermati, ascolta la risposta fino in fondo senza preparare la replica. || Oggi è di turno l\'Ufficiale Ferito, fra i Dieci Dei del BaZi: il tuo elemento lo genera con polarità opposta, è l\'espressione che rompe le regole. Urta l\'Ufficiale, la figura del partner: per una donna è il segno classico dell\'attrito.',
        'In amore oggi hai fascino e insofferenza nello stesso momento. Decidi prima quale dei due mostrare: se uscite insieme lascia fuori dalla serata il punto che ti irrita da giorni. || Nel BaZi il giorno di oggi ti porta l\'Ufficiale Ferito: il tuo elemento lo genera con polarità opposta, è l\'espressione che rompe le regole. Urta l\'Ufficiale, la figura del partner: per una donna è il segno classico dell\'attrito.',
      ],
      'ricchezzaIndiretta': [
        'Oggi in amore paga la generosità. Fai un gesto che non era in programma: offri tu la cena oppure proponi un\'uscita decisa all\'ultimo momento. || Il dio di oggi nel BaZi è la Ricchezza indiretta: il tuo elemento la governa con la stessa polarità. La Ricchezza nutre l\'Ufficiale, che per una donna è la figura del partner.',
        'Il legame oggi si scalda con una sorpresa. Libera due ore in agenda, porta chi ami in un posto dove non siete mai stati: basta un quartiere diverso dal solito. || Oggi è di turno la Ricchezza indiretta, fra i Dieci Dei del BaZi: il tuo elemento la governa con la stessa polarità. La Ricchezza nutre l\'Ufficiale, che per una donna è la figura del partner.',
        'L\'amore oggi chiede di dare senza tenere il conto. Regala qualcosa al rapporto, anche piccolo: un favore, un pensiero preso per strada, il tuo tempo senza guardare l\'orologio. || Nel BaZi il giorno di oggi ti porta la Ricchezza indiretta: il tuo elemento la governa con la stessa polarità. La Ricchezza nutre l\'Ufficiale, che per una donna è la figura del partner.',
      ],
      'ricchezzaDiretta': [
        'Oggi in amore si costruisce. È un buon giorno per parlare di progetti concreti: scegliete un argomento solo, le vacanze o le spese comuni, mettetelo nero su bianco. || Il dio di oggi nel BaZi è la Ricchezza diretta: il tuo elemento la governa con polarità opposta. La Ricchezza nutre l\'Ufficiale, che per una donna è la figura del partner.',
        'In coppia oggi la cura pratica vale quanto una carezza. Fai per chi ami una cosa utile che aspetta da tempo: una commissione, una telefonata noiosa, una riparazione. || Oggi è di turno la Ricchezza diretta, fra i Dieci Dei del BaZi: il tuo elemento la governa con polarità opposta. La Ricchezza nutre l\'Ufficiale, che per una donna è la figura del partner.',
        'È la stabilità, oggi, a fare bene al legame. Pianifica qualcosa per due: prenota un tavolo, blocca una data in agenda, decidi dove passare il prossimo fine settimana. || Nel BaZi il giorno di oggi ti porta la Ricchezza diretta: il tuo elemento la governa con polarità opposta. La Ricchezza nutre l\'Ufficiale, che per una donna è la figura del partner.',
      ],
      'setteUccisioni': [
        'Oggi in amore l\'attrazione è forte, a tratti scomoda. Senti tutto quello che c\'è da sentire, ma rimanda a domani ogni decisione: niente messaggi definitivi scritti di notte. || Il dio di oggi nel BaZi sono le Sette Uccisioni: governano il tuo elemento con la stessa polarità, sono pressione e sfida. Per una donna sono l\'amante o il legame intenso, che mette alla prova.',
        'Passione e tensione oggi stanno nello stesso respiro. Se la conversazione diventa una prova di forza lascia la stanza per dieci minuti: non c\'è niente da vincere. || Oggi sono di turno le Sette Uccisioni, fra i Dieci Dei del BaZi: governano il tuo elemento con la stessa polarità, sono pressione e sfida. Per una donna sono l\'amante o il legame intenso, che mette alla prova.',
        'Un incontro oggi può colpirti più del solito. Guarda chi hai davanti per quello che fa, non per quello che promette: aspetta un gesto concreto prima di aprirti. || Nel BaZi il giorno di oggi ti porta le Sette Uccisioni: governano il tuo elemento con la stessa polarità, sono pressione e sfida. Per una donna sono l\'amante o il legame intenso, che mette alla prova.',
      ],
      'ufficialeDiretto': [
        'Oggi è un buon giorno per la coppia stabile. Se c\'è una parola seria che aspetta dilla adesso: una proposta, una data, un sì che hai già deciso dentro di te. || Il dio di oggi nel BaZi è l\'Ufficiale diretto: governa il tuo elemento con polarità opposta, è regola e responsabilità. Per una donna è il partner, la figura dell\'unione.',
        'In coppia oggi contano il rispetto e le parole mantenute: fai la cosa che avevi promesso. Se non hai un legame dai il tuo tempo a una conoscenza seria prima che a una leggera. || Oggi è di turno l\'Ufficiale diretto, fra i Dieci Dei del BaZi: governa il tuo elemento con polarità opposta, è regola e responsabilità. Per una donna è il partner, la figura dell\'unione.',
        'In amore oggi pesano l\'impegno e la fiducia. Fatti trovare: arriva puntuale, rispondi alla chiamata, resta fino alla fine anche se hai altro da fare. || Nel BaZi il giorno di oggi ti porta l\'Ufficiale diretto: governa il tuo elemento con polarità opposta, è regola e responsabilità. Per una donna è il partner, la figura dell\'unione.',
      ],
      'sigilloIndiretto': [
        'Oggi in amore hai bisogno di uno spazio tutto tuo. Non è distanza, è ricarica: prenditi mezz\'ora senza telefono, avvisa chi ami che dopo ci sei. || Il dio di oggi nel BaZi è il Sigillo indiretto: genera il tuo elemento con la stessa polarità, è sostegno insolito e intuizione. Nell\'amore di una donna i Sigilli addolciscono l\'Ufficiale, la figura del partner.',
        'Ti sembra, oggi, di capire chi ami senza bisogno di parole. Può essere vero oppure no: prima di muoverti su un\'impressione fai una domanda semplice, poi aspetta la risposta. || Oggi è di turno il Sigillo indiretto, fra i Dieci Dei del BaZi: genera il tuo elemento con la stessa polarità, è sostegno insolito e intuizione. Nell\'amore di una donna i Sigilli addolciscono l\'Ufficiale, la figura del partner.',
        'Il cuore oggi si capisce meglio in silenzio. Ritagliati un\'ora per conto tuo, una camminata o un bagno caldo: dopo è più facile essere presente con chi ami. || Nel BaZi il giorno di oggi ti porta il Sigillo indiretto: genera il tuo elemento con la stessa polarità, è sostegno insolito e intuizione. Nell\'amore di una donna i Sigilli addolciscono l\'Ufficiale, la figura del partner.',
      ],
      'sigilloDiretto': [
        'Oggi in amore c\'è aria di protezione, di famiglia. Lasciati accudire: accetta il passaggio, la cena pronta, l\'aiuto che di solito rifiuti per abitudine. || Il dio di oggi nel BaZi è il Sigillo diretto: genera il tuo elemento con polarità opposta, è protezione e cura. Nell\'amore di una donna i Sigilli addolciscono l\'Ufficiale, la figura del partner.',
        'Il legame oggi è un rifugio. Chiedi un abbraccio senza spiegare perché ti serve: bastano due parole, poi resta lì un minuto in più. || Oggi è di turno il Sigillo diretto, fra i Dieci Dei del BaZi: genera il tuo elemento con polarità opposta, è protezione e cura. Nell\'amore di una donna i Sigilli addolciscono l\'Ufficiale, la figura del partner.',
        'Stai bene, oggi, fra gli affetti sicuri di sempre. Chiama chi ti vuole bene da una vita, un genitore o un\'amicizia storica: dieci minuti di voce, non un messaggio. || Nel BaZi il giorno di oggi ti porta il Sigillo diretto: genera il tuo elemento con polarità opposta, è protezione e cura. Nell\'amore di una donna i Sigilli addolciscono l\'Ufficiale, la figura del partner.',
      ],
    },
    'amoreUomo': {
      'compagno': [
        'Oggi in amore gli amici e i fratelli tirano dalla loro parte. Stai pure con loro, ma non trascurare chi ami: prima di uscire di\' a che ora torni, poi rispetta l\'orario. || Il dio di oggi nel BaZi è il Compagno: ha il tuo stesso elemento e la tua stessa polarità. Per un uomo contende la Ricchezza, che è la figura della partner.',
        'La tua attenzione oggi è divisa fra chi ami e la tua cerchia. Invece di tenere le due cose separate uniscile: porta chi ami alla serata con gli amici e presenta qualcuno a cui tieni. || Oggi è di turno il Compagno, fra i Dieci Dei del BaZi: ha il tuo stesso elemento e la tua stessa polarità. Per un uomo contende la Ricchezza, che è la figura della partner.',
        'Fra voi oggi c\'è più amicizia che corteggiamento. Va bene, se lo sai: non pretendere la serata perfetta, proponi una cosa semplice da fare insieme, come fra vecchi amici. || Nel BaZi il giorno di oggi ti porta il Compagno: ha il tuo stesso elemento e la tua stessa polarità. Per un uomo contende la Ricchezza, che è la figura della partner.',
      ],
      'rivale': [
        'Oggi in amore girano gelosie, confronti, il nome di un terzo nei discorsi. Invece di competere rassicura: spiega con parole semplici che cosa conta per te in questo legame. || Il dio di oggi nel BaZi è il Rivale: ha il tuo stesso elemento con polarità opposta, contende ciò che hai. Per un uomo la contesa riguarda la Ricchezza, che è la figura della partner.',
        'Viene la tentazione, oggi, di metterti in gara per chi ami. Lascia perdere: niente prove di bravura, niente regali per battere qualcuno. Un legame si regge su una scelta, non su una vittoria. || Oggi è di turno il Rivale, fra i Dieci Dei del BaZi: ha il tuo stesso elemento con polarità opposta, contende ciò che hai. Per un uomo la contesa riguarda la Ricchezza, che è la figura della partner.',
        'In amore oggi le parole sulle storie passate e sugli altri pesano il doppio. Tienile fuori dalla conversazione: se il discorso ci finisce cambia argomento con una domanda su chi hai davanti. || Nel BaZi il giorno di oggi ti porta il Rivale: ha il tuo stesso elemento con polarità opposta, contende ciò che hai. Per un uomo la contesa riguarda la Ricchezza, che è la figura della partner.',
      ],
      'nutrimento': [
        'Oggi in amore va bene a chi è gentile: il legame cresce da ciò che offri. Fai a chi ami un\'attenzione inattesa, il dolce preferito o un passaggio al lavoro. || Il dio di oggi nel BaZi è il Nutrimento: il tuo elemento lo genera con la stessa polarità, è ciò che produci con calma. Genera la Ricchezza, che per un uomo è la figura della partner.',
        'Il tuo fascino oggi è la calma. Cucina per chi ami oppure proponi di uscire, poi lascia parlare: fai due domande, ascolta le risposte senza guardare il telefono. || Oggi è di turno il Nutrimento, fra i Dieci Dei del BaZi: il tuo elemento lo genera con la stessa polarità, è ciò che produci con calma. Genera la Ricchezza, che per un uomo è la figura della partner.',
        'L\'amore oggi è dolcezza semplice, senza grandi discorsi. Scegli un gesto concreto al posto delle parole: ripara una cosa che serve in due, apparecchia tu, prepara la colazione. || Nel BaZi il giorno di oggi ti porta il Nutrimento: il tuo elemento lo genera con la stessa polarità, è ciò che produci con calma. Genera la Ricchezza, che per un uomo è la figura della partner.',
      ],
      'ufficialeFerito': [
        'Oggi in amore hai brillantezza e fascino, ma poca pazienza. Usa l\'ironia, mai il sarcasmo: se una battuta punge invece di far ridere chiedi scusa subito. || Il dio di oggi nel BaZi è l\'Ufficiale Ferito: il tuo elemento lo genera con polarità opposta, è l\'espressione che rompe le regole. Genera con impeto la Ricchezza, che per un uomo è la figura della partner.',
        'Hai voglia, oggi, di stupire chi ami. Fallo con un\'idea: un posto nuovo, un biglietto scritto a mano, un programma deciso da te. La provocazione lasciala stare. || Oggi è di turno l\'Ufficiale Ferito, fra i Dieci Dei del BaZi: il tuo elemento lo genera con polarità opposta, è l\'espressione che rompe le regole. Genera con impeto la Ricchezza, che per un uomo è la figura della partner.',
        'Quello che senti oggi esce con forza. Dillo pure, in poche frasi; poi taci, lascia a chi ami lo spazio per rispondere anche se la risposta tarda ad arrivare. || Nel BaZi il giorno di oggi ti porta l\'Ufficiale Ferito: il tuo elemento lo genera con polarità opposta, è l\'espressione che rompe le regole. Genera con impeto la Ricchezza, che per un uomo è la figura della partner.',
      ],
      'ricchezzaIndiretta': [
        'Oggi in amore c\'è aria leggera. Se non hai un legame accetta un invito, parla con chi non conosci; se sei in coppia porta quella leggerezza nel legame con un\'uscita improvvisata. || Il dio di oggi nel BaZi è la Ricchezza indiretta: il tuo elemento la governa con la stessa polarità. Per un uomo è la figura della compagna non ufficiale, l\'incontro.',
        'Le occasioni sociali oggi portano sguardi e attenzioni. Vivile con onestà verso di te e verso chi hai accanto: non fare niente che stasera non potresti raccontare. || Oggi è di turno la Ricchezza indiretta, fra i Dieci Dei del BaZi: il tuo elemento la governa con la stessa polarità. Per un uomo è la figura della compagna non ufficiale, l\'incontro.',
        'Il cuore oggi si muove, in più direzioni. Tocca a te scegliere dove fermarlo: prima di rispondere a un messaggio che ti lusinga decidi fin dove vuoi arrivare. || Nel BaZi il giorno di oggi ti porta la Ricchezza indiretta: il tuo elemento la governa con la stessa polarità. Per un uomo è la figura della compagna non ufficiale, l\'incontro.',
      ],
      'ricchezzaDiretta': [
        'Oggi è un buon giorno per la coppia. Mettete mano a un progetto comune: scegliete insieme una cosa da fare entro il mese, poi dividetevi i compiti. || Il dio di oggi nel BaZi è la Ricchezza diretta: il tuo elemento la governa con polarità opposta. Per un uomo è la figura della moglie, la compagna stabile.',
        'Il legame oggi chiede presenza costante, non gesti che fanno scena. Esserci basta: torna all\'ora detta, sedetevi a tavola insieme, chiedi com\'è andata. || Oggi è di turno la Ricchezza diretta, fra i Dieci Dei del BaZi: il tuo elemento la governa con polarità opposta. Per un uomo è la figura della moglie, la compagna stabile.',
        'In amore oggi conta la serietà più della quantità. Se non hai un legame dai il tuo tempo a una persona sola, con un invito vero: un incontro serio vale più di dieci leggeri. || Nel BaZi il giorno di oggi ti porta la Ricchezza diretta: il tuo elemento la governa con polarità opposta. Per un uomo è la figura della moglie, la compagna stabile.',
      ],
      'setteUccisioni': [
        'Oggi le pressioni di fuori tolgono spazio all\'amore. Proteggi un\'ora solo per voi due: telefono in un\'altra stanza, nessun discorso di scadenze. || Il dio di oggi nel BaZi sono le Sette Uccisioni: governano il tuo elemento con la stessa polarità, sono pressione e sfida. La Ricchezza, la figura della partner, si consuma verso di loro.',
        'Hai i nervi tesi, oggi: in amore rischia di farne le spese chi ti sta vicino. Non portare a tavola la battaglia del giorno, prima di rientrare fai due passi per lasciare lì la rabbia. || Oggi sono di turno le Sette Uccisioni, fra i Dieci Dei del BaZi: governano il tuo elemento con la stessa polarità, sono pressione e sfida. La Ricchezza, la figura della partner, si consuma verso di loro.',
        'In amore oggi si sente la fatica che porti addosso. Invece di chiuderti dilla: bastano due frasi su che cosa ti pesa, senza chiedere a chi ami di risolverlo. || Nel BaZi il giorno di oggi ti porta le Sette Uccisioni: governano il tuo elemento con la stessa polarità, sono pressione e sfida. La Ricchezza, la figura della partner, si consuma verso di loro.',
      ],
      'ufficialeDiretto': [
        'Oggi doveri e impegni passano davanti all\'amore. Non lasciarlo sparire dalla giornata: manda un messaggio a metà pomeriggio, tieni libera la cena. || Il dio di oggi nel BaZi è l\'Ufficiale diretto: governa il tuo elemento con polarità opposta, è regola e responsabilità. L\'Ufficiale consuma la Ricchezza, che per un uomo è la figura della partner.',
        'Anche in coppia oggi valgono la correttezza e la parola data. Mantieni ciò che hai promesso: la telefonata, la commissione, quel sabato che avevi detto di tenere per voi. || Oggi è di turno l\'Ufficiale diretto, fra i Dieci Dei del BaZi: governa il tuo elemento con polarità opposta, è regola e responsabilità. L\'Ufficiale consuma la Ricchezza, che per un uomo è la figura della partner.',
        'In amore oggi rassicura più l\'affidabilità dei gesti teneri. Al posto del fiore scegli un gesto che si può contare: arriva in orario, sbriga tu la pratica rimasta indietro. || Nel BaZi il giorno di oggi ti porta l\'Ufficiale diretto: governa il tuo elemento con polarità opposta, è regola e responsabilità. L\'Ufficiale consuma la Ricchezza, che per un uomo è la figura della partner.',
      ],
      'sigilloIndiretto': [
        'Oggi in amore hai bisogno di pensare, con del tempo per conto tuo. Dillo chiaramente a chi ami, con un orario di rientro: così non sembra distanza. || Il dio di oggi nel BaZi è il Sigillo indiretto: genera il tuo elemento con la stessa polarità, è sostegno insolito e intuizione. Nella scheda dell\'amore è il bisogno di pensare.',
        'Ti vengono, oggi, intuizioni su chi ami, non tutte esatte. Prima di agire chiedi conferma: una domanda aperta, poi credi a quello che ti viene risposto. || Oggi è di turno il Sigillo indiretto, fra i Dieci Dei del BaZi: genera il tuo elemento con la stessa polarità, è sostegno insolito e intuizione. Nella scheda dell\'amore è il bisogno di pensare.',
        'Il legame oggi sta bene nel silenzio condiviso. Stare accanto senza parlare vale: leggete nella stessa stanza, guidate senza musica, camminate senza riempire i vuoti. || Nel BaZi il giorno di oggi ti porta il Sigillo indiretto: genera il tuo elemento con la stessa polarità, è sostegno insolito e intuizione. Nella scheda dell\'amore è il bisogno di pensare.',
      ],
      'sigilloDiretto': [
        'Oggi in amore contano la cura, la famiglia, le radici. Passa a trovare i tuoi oppure cucina tu stasera per chi ami, senza programmi fuori. || Il dio di oggi nel BaZi è il Sigillo diretto: genera il tuo elemento con polarità opposta, è protezione e cura. Nella scheda dell\'amore è cura, famiglia, radici.',
        'In amore oggi fa bene ricevere. Lasciati accudire senza orgoglio: se chi ami ti offre un aiuto o ti prepara qualcosa, ringrazia invece di rispondere che ce la fai. || Oggi è di turno il Sigillo diretto, fra i Dieci Dei del BaZi: genera il tuo elemento con polarità opposta, è protezione e cura. Nella scheda dell\'amore è cura, famiglia, radici.',
        'Il legame oggi è protezione che va in due direzioni. Chiedi una mano su una cosa precisa a chi ami, poi offri la tua su qualcosa che pesa a quella persona. || Nel BaZi il giorno di oggi ti porta il Sigillo diretto: genera il tuo elemento con polarità opposta, è protezione e cura. Nella scheda dell\'amore è cura, famiglia, radici.',
      ],
    },
    'amoreNeutro': {
      'compagno': [
        'Oggi in amore vincono l\'amicizia e la complicità. Parla alla pari con chi ami: chiedi un parere su una cosa tua, poi dai il tuo su una cosa sua. || Il dio di oggi nel BaZi è il Compagno: ha il tuo stesso elemento e la tua stessa polarità. La scheda dell\'amore lo legge come le persone che hai intorno.',
        'L\'affetto oggi passa anche dagli amici, non solo dalla coppia. Dai loro del tempo: chiama una persona amica che non senti da settimane, fissate un caffè. || Oggi è di turno il Compagno, fra i Dieci Dei del BaZi: ha il tuo stesso elemento e la tua stessa polarità. La scheda dell\'amore lo legge come le persone che hai intorno.',
        'Il legame oggi è prima di tutto un\'alleanza. Trova una cosa da affrontare in due, un problema pratico o una decisione: mettetevi dalla stessa parte del tavolo. || Nel BaZi il giorno di oggi ti porta il Compagno: ha il tuo stesso elemento e la tua stessa polarità. La scheda dell\'amore lo legge come le persone che hai intorno.',
      ],
      'rivale': [
        'Oggi in amore è facile sentirsi in competizione con qualcuno. Prima di immaginare chiedi: una domanda sola, fatta con calma, vale più di una sera di sospetti. || Il dio di oggi nel BaZi è il Rivale: ha il tuo stesso elemento con polarità opposta, contende ciò che hai. La scheda dell\'amore lo legge come le persone che hai intorno.',
        'La gelosia oggi è a portata di mano. Scegli la fiducia con un gesto: non controllare orari né telefoni, chiedi invece a chi ami di raccontarti la sua giornata. || Oggi è di turno il Rivale, fra i Dieci Dei del BaZi: ha il tuo stesso elemento con polarità opposta, contende ciò che hai. La scheda dell\'amore lo legge come le persone che hai intorno.',
        'Viene voglia, oggi, di mettersi in gara per chi ami. Non farlo: niente confronti con altre persone, niente dimostrazioni. Passate un\'ora insieme senza parlare di nessun altro. || Nel BaZi il giorno di oggi ti porta il Rivale: ha il tuo stesso elemento con polarità opposta, contende ciò che hai. La scheda dell\'amore lo legge come le persone che hai intorno.',
      ],
      'nutrimento': [
        'Oggi l\'amore è fatto di dolcezza, con gesti semplici. Cucina qualcosa, invita chi ti piace o chi ami, poi ascolta più di quanto parli. || Il dio di oggi nel BaZi è il Nutrimento: il tuo elemento lo genera con la stessa polarità, è ciò che produci con calma. La scheda dell\'amore lo legge come il tuo modo di esprimerti.',
        'Il legame oggi cresce da ciò che offri con calma. Regala un\'attenzione senza aspettare niente in cambio: un passaggio, una tazza di tè, dieci minuti di ascolto vero. || Oggi è di turno il Nutrimento, fra i Dieci Dei del BaZi: il tuo elemento lo genera con la stessa polarità, è ciò che produci con calma. La scheda dell\'amore lo legge come il tuo modo di esprimerti.',
        'In amore oggi sta bene chi si gode il piacere semplice. Lascia stare i bilanci: una passeggiata, un gelato, un film scelto insieme bastano a fare la giornata. || Nel BaZi il giorno di oggi ti porta il Nutrimento: il tuo elemento lo genera con la stessa polarità, è ciò che produci con calma. La scheda dell\'amore lo legge come il tuo modo di esprimerti.',
      ],
      'ufficialeFerito': [
        'Oggi in amore le parole escono prima dei pensieri. Una frase dolce vale più di una frase giusta: se devi correggere chi ami comincia da ciò che apprezzi. || Il dio di oggi nel BaZi è l\'Ufficiale Ferito: il tuo elemento lo genera con polarità opposta, è l\'espressione che rompe le regole. La scheda dell\'amore lo legge come il tuo modo di esprimerti.',
        'Hai bisogno, oggi, di dire tutto a chi ami. Dillo in modo chiaro, senza alzare la voce; poi fai silenzio, lascia all\'altra persona tutto il tempo per rispondere. || Oggi è di turno l\'Ufficiale Ferito, fra i Dieci Dei del BaZi: il tuo elemento lo genera con polarità opposta, è l\'espressione che rompe le regole. La scheda dell\'amore lo legge come il tuo modo di esprimerti.',
        'In amore oggi porti fascino e insofferenza insieme. Scegli quale mostrare: tieni la battuta brillante, rimanda a domani il rimprovero che hai sulla punta della lingua. || Nel BaZi il giorno di oggi ti porta l\'Ufficiale Ferito: il tuo elemento lo genera con polarità opposta, è l\'espressione che rompe le regole. La scheda dell\'amore lo legge come il tuo modo di esprimerti.',
      ],
      'ricchezzaIndiretta': [
        'Oggi in amore c\'è movimento: incontri, sorprese, uscite fuori programma. Rispondi di sì a un invito dell\'ultimo momento oppure proponine uno tu. || Il dio di oggi nel BaZi è la Ricchezza indiretta: il tuo elemento la governa con la stessa polarità. La scheda dell\'amore la legge come la figura dell\'altro.',
        'Il cuore oggi si muove, a volte verso più di una persona. Mantieni l\'onestà con te e con chi hai accanto: non promettere a nessuno ciò che non intendi mantenere. || Oggi è di turno la Ricchezza indiretta, fra i Dieci Dei del BaZi: il tuo elemento la governa con la stessa polarità. La scheda dell\'amore la legge come la figura dell\'altro.',
        'L\'amore oggi chiede generosità. Dai qualcosa al legame senza fare conti: un\'ora in più, un piccolo regalo, un favore che nessuno ti ha chiesto. || Nel BaZi il giorno di oggi ti porta la Ricchezza indiretta: il tuo elemento la governa con la stessa polarità. La scheda dell\'amore la legge come la figura dell\'altro.',
      ],
      'ricchezzaDiretta': [
        'Oggi in amore si costruisce. Parla di progetti concreti con chi ami: un viaggio, un trasloco, una spesa da fare in due. Uscitene con una data. || Il dio di oggi nel BaZi è la Ricchezza diretta: il tuo elemento la governa con polarità opposta. La scheda dell\'amore la legge come la figura dell\'altro.',
        'La cura pratica oggi vale quanto una carezza. Fai una cosa utile per chi ami: ritira un pacco, sbriga una commissione, sistema ciò che si è rotto. || Oggi è di turno la Ricchezza diretta, fra i Dieci Dei del BaZi: il tuo elemento la governa con polarità opposta. La scheda dell\'amore la legge come la figura dell\'altro.',
        'È la stabilità, oggi, a fare bene al legame. Tieni fermo un appuntamento fisso, la cena di metà settimana o la telefonata della sera: non spostarlo. || Nel BaZi il giorno di oggi ti porta la Ricchezza diretta: il tuo elemento la governa con polarità opposta. La scheda dell\'amore la legge come la figura dell\'altro.',
      ],
      'setteUccisioni': [
        'Oggi in amore c\'è un\'attrazione forte oppure una tensione forte. Senti tutto, ma decidi con calma: dormici sopra prima di dire una cosa che cambia i rapporti. || Il dio di oggi nel BaZi sono le Sette Uccisioni: governano il tuo elemento con la stessa polarità, sono pressione e sfida. La scheda dell\'amore le legge come la figura dell\'altro.',
        'Il legame oggi rischia di diventare una prova di forza. Cedi tu su una cosa piccola, il ristorante o l\'orario: mostra che non stai tenendo il punteggio. || Oggi sono di turno le Sette Uccisioni, fra i Dieci Dei del BaZi: governano il tuo elemento con la stessa polarità, sono pressione e sfida. La scheda dell\'amore le legge come la figura dell\'altro.',
        'In amore oggi le promesse contano poco, i fatti molto. Guarda chi hai davanti per quello che fa: ripassa che cosa è successo nell\'ultima settimana, non le parole di ieri sera. || Nel BaZi il giorno di oggi ti porta le Sette Uccisioni: governano il tuo elemento con la stessa polarità, sono pressione e sfida. La scheda dell\'amore le legge come la figura dell\'altro.',
      ],
      'ufficialeDiretto': [
        'Oggi in amore contano l\'impegno e la fiducia. Dai una parola, poi mantienila entro sera: l\'orario di un appuntamento, una chiamata, una risposta che devi da giorni. || Il dio di oggi nel BaZi è l\'Ufficiale diretto: governa il tuo elemento con polarità opposta, è regola e responsabilità. La scheda dell\'amore lo legge come la figura dell\'altro.',
        'Esserci oggi vale più di qualunque gesto. Fatti trovare dove hai detto, per tutto il tempo: metti via il telefono, resta fino alla fine. || Oggi è di turno l\'Ufficiale diretto, fra i Dieci Dei del BaZi: governa il tuo elemento con polarità opposta, è regola e responsabilità. La scheda dell\'amore lo legge come la figura dell\'altro.',
        'L\'amore oggi è una cosa seria, fatta di poche parole mantenute. Prometti una sola cosa a chi ami, piccola e precisa, poi falla prima di parlare d\'altro. || Nel BaZi il giorno di oggi ti porta l\'Ufficiale diretto: governa il tuo elemento con polarità opposta, è regola e responsabilità. La scheda dell\'amore lo legge come la figura dell\'altro.',
      ],
      'sigilloIndiretto': [
        'Oggi in amore hai bisogno di uno spazio tuo. Dillo a chi ami con parole chiare, aggiungi quando torni: così non sembra distanza. || Il dio di oggi nel BaZi è il Sigillo indiretto: genera il tuo elemento con la stessa polarità, è sostegno insolito e intuizione. La scheda dell\'amore legge i Sigilli come la cura.',
        'Ti pare, oggi, di intuire che cosa passa per la testa di chi ami. Verifica con una domanda prima di darlo per buono: chiedi, non dedurre. || Oggi è di turno il Sigillo indiretto, fra i Dieci Dei del BaZi: genera il tuo elemento con la stessa polarità, è sostegno insolito e intuizione. La scheda dell\'amore legge i Sigilli come la cura.',
        'Anche il silenzio condiviso oggi è vicinanza. Passate del tempo nella stessa stanza facendo ognuno la sua cosa: non serve riempire ogni pausa di parole. || Nel BaZi il giorno di oggi ti porta il Sigillo indiretto: genera il tuo elemento con la stessa polarità, è sostegno insolito e intuizione. La scheda dell\'amore legge i Sigilli come la cura.',
      ],
      'sigilloDiretto': [
        'Oggi in amore contano la cura e la famiglia. Lasciati accudire: accetta il piatto caldo, la coperta, l\'aiuto offerto, senza dire che non ce n\'è bisogno. || Il dio di oggi nel BaZi è il Sigillo diretto: genera il tuo elemento con polarità opposta, è protezione e cura. La scheda dell\'amore legge i Sigilli come la cura.',
        'Il legame oggi è un rifugio. Chiedi un abbraccio a voce, senza aspettare che l\'altra persona indovini: poi restaci dentro qualche secondo in più. || Oggi è di turno il Sigillo diretto, fra i Dieci Dei del BaZi: genera il tuo elemento con polarità opposta, è protezione e cura. La scheda dell\'amore legge i Sigilli come la cura.',
        'L\'affetto che conta oggi è quello di lunga data. Chiama chi ti vuole bene da sempre, un genitore o un\'amicizia storica: una telefonata vera, non un messaggio. || Nel BaZi il giorno di oggi ti porta il Sigillo diretto: genera il tuo elemento con polarità opposta, è protezione e cura. La scheda dell\'amore legge i Sigilli come la cura.',
      ],
    },
  };

  /// Il titolo in parole di Fortuna, Lavoro e Amore, per scheda e per dio.
  static const Map<String, Map<String, String>> titoliDeiDei = {
    'fortuna': {
      'compagno': 'Spese da dividere',
      'rivale': 'Il portafoglio chiuso',
      'nutrimento': 'Il tuo saper fare',
      'ufficialeFerito': 'Un\'idea che rende',
      'ricchezzaIndiretta': 'Il denaro che gira',
      'ricchezzaDiretta': 'Conti in ordine',
      'setteUccisioni': 'Prima le scadenze',
      'ufficialeDiretto': 'Mettersi in regola',
      'sigilloIndiretto': 'Vale ciò che impari',
      'sigilloDiretto': 'Soldi al sicuro',
    },
    'lavoro': {
      'compagno': 'Lavoro di squadra',
      'rivale': 'Lascia parlare i fatti',
      'nutrimento': 'Il lavoro ben fatto',
      'ufficialeFerito': 'Pesa le parole',
      'ricchezzaIndiretta': 'Un contatto nuovo',
      'ricchezzaDiretta': 'Ordine e consegne',
      'setteUccisioni': 'Una prova da reggere',
      'ufficialeDiretto': 'Parla con chi decide',
      'sigilloIndiretto': 'Tempo per concentrarti',
      'sigilloDiretto': 'Le spalle coperte',
    },
    'amoreDonna': {
      'compagno': 'Complici prima di tutto',
      'rivale': 'Chiedi, non immaginare',
      'nutrimento': 'Tenerezza senza fretta',
      'ufficialeFerito': 'Misura le parole',
      'ricchezzaIndiretta': 'Un gesto a sorpresa',
      'ricchezzaDiretta': 'Costruire in due',
      'setteUccisioni': 'Passione a mente fredda',
      'ufficialeDiretto': 'Una parola seria',
      'sigilloIndiretto': 'Uno spazio tuo',
      'sigilloDiretto': 'Lasciati accudire',
    },
    'amoreUomo': {
      'compagno': 'Attenzione da dividere',
      'rivale': 'Rassicura, non competere',
      'nutrimento': 'La calma che conquista',
      'ufficialeFerito': 'Ironia, non sarcasmo',
      'ricchezzaIndiretta': 'Leggerezza e onestà',
      'ricchezzaDiretta': 'Esserci basta',
      'setteUccisioni': 'Un\'ora solo per voi',
      'ufficialeDiretto': 'La promessa mantenuta',
      'sigilloIndiretto': 'Silenzio condiviso',
      'sigilloDiretto': 'Cura e radici',
    },
    'amoreNeutro': {
      'compagno': 'Un legame alla pari',
      'rivale': 'Scegli la fiducia',
      'nutrimento': 'Gesti semplici',
      'ufficialeFerito': 'Una parola dolce',
      'ricchezzaIndiretta': 'Fuori programma',
      'ricchezzaDiretta': 'Progetti concreti',
      'setteUccisioni': 'Senti, poi decidi',
      'ufficialeDiretto': 'La parola data',
      'sigilloIndiretto': 'Spazio per respirare',
      'sigilloDiretto': 'Un rifugio sicuro',
    },
  };

  /// La spiegazione di una riga di ognuno dei Dieci Dei.
  static const Map<String, String> spiegazioni = {
    'compagno':
        'il giorno ha il tuo stesso elemento con la tua stessa polarità',
    'rivale':
        'il tuo stesso elemento, con polarità opposta: contende ciò che hai',
    'nutrimento':
        'il tuo elemento lo genera, stessa polarità: ciò che produci con calma',
    'ufficialeFerito':
        'il tuo elemento lo genera, polarità opposta: espressione che rompe le regole',
    'ricchezzaIndiretta':
        'il tuo elemento lo governa, stessa polarità: guadagni che arrivano di lato',
    'ricchezzaDiretta':
        'il tuo elemento lo governa, polarità opposta: il guadagno regolare',
    'setteUccisioni':
        'governa il tuo elemento, stessa polarità: pressione, sfida',
    'ufficialeDiretto':
        'governa il tuo elemento, polarità opposta: regola, responsabilità, riconoscimento',
    'sigilloIndiretto':
        'genera il tuo elemento, stessa polarità: sostegno insolito, intuizione',
    'sigilloDiretto':
        'genera il tuo elemento, polarità opposta: protezione, studio, cura',
  };

  /// La riga del colore e dei numeri.
  static const List<String> coloreENumeri = [
    'Il giorno è di {elemento}: il suo colore nella tradizione è il {colore}, i suoi numeri {numeri}.',
    'Elemento del giorno: {elemento}. Colore {colore}, numeri {numeri}, secondo la figura dello He Tu.',
    'Oggi governa {elemento}. Nella tradizione cinese gli appartengono il {colore} e i numeri {numeri}.',
  ];
  static const List<String> direzioneGioia = [
    'Per l\'incontro a cui tieni di più, oggi conta anche dove lo metti. Se puoi, fissa l\'appuntamento che conta in un posto a {direzione_gioia} rispetto a casa tua. || Gli almanacchi cinesi mettono oggi il Dio della Gioia a {direzione_gioia}: il posto viene dal tronco del giorno.',
    'La direzione buona della giornata è una sola, per le cose che fanno piacere. Se esci per una passeggiata o per vedere qualcuno, scegli una meta a {direzione_gioia} del punto da cui parti. || La direzione del giorno è {direzione_gioia}, dove l\'almanacco cinese colloca il Dio della Gioia.',
    'Quando oggi hai qualcosa da decidere, puoi aiutarti con un gesto simbolico. Siediti con lo sguardo a {direzione_gioia}, fai un respiro lungo e solo dopo di\' il tuo sì o il tuo no. || Il Dio della Gioia oggi sta a {direzione_gioia}, secondo il calendario cinese, che ne dà il posto giorno per giorno.',
  ];
  static const List<String> direzioneRicchezza = [
    'Per le faccende di denaro, oggi c\'è un lato da cui conviene passare. Se hai una commissione che riguarda i soldi, scegli lo sportello, il negozio o l\'ufficio che sta a {direzione_ricchezza} rispetto a casa tua. || L\'almanacco cinese pone oggi il Dio della Ricchezza a {direzione_ricchezza}: il posto viene dal tronco del giorno.',
    'Quando oggi ti occupi di soldi, puoi farlo con un piccolo gesto simbolico. Siediti al tavolo con lo sguardo a {direzione_ricchezza} mentre controlli le spese, prepari una richiesta o fai il punto del mese. || La direzione della ricchezza oggi è {direzione_ricchezza}, secondo il calendario cinese e la tabella degli almanacchi.',
    'Sul denaro la giornata indica una direzione, non una cifra. Tieni il portafoglio e le carte da sistemare sul lato della stanza che sta a {direzione_ricchezza}: è da lì che oggi conviene fare i conti. || Il Dio della Ricchezza, dicono gli almanacchi cinesi, oggi sta a {direzione_ricchezza}.',
  ];
  static const String notaGenerale =
      'L\'animale del giorno è il ramo del giorno nel ciclo dei sessanta; il rapporto col tuo animale viene dalle tabelle del Sanming Tonghui (1578). Il guardiano del giorno è uno dei dodici del calendario, contato dal mese solare.';
  static const String notaDei =
      'Il tuo giorno di nascita ha un tronco celeste, il giorno di oggi un altro: il loro rapporto fra i cinque elementi dà uno dei Dieci Dei del BaZi. La scheda prende il livello da quel dio come lo leggono lo Yuanhai Ziping e il Ziping Zhenquan; il testo è scelto per quel livello.';
  static const String notaColore =
      'Colore e numeri sono quelli dell\'elemento del giorno nella tradizione, non colori o numeri portafortuna.';
}
