// GENERATO da tool/_gen_oroscopo.py a partire da docs/corpus/oroscopo.md.
// Fonte di verita': il corpus. Non modificare a mano: rigenerare dal corpus.
//
// I dati su dispositivo dell'Oroscopo a quattro schede di Medora: le aperture
// personalizzate, il giorno nelle dodici case per i quattro domini, i pool della
// corrente del giorno, le palette del colore del giorno e la riga di disclaimer.

/// Dati dell'Oroscopo, trascritti dal corpus. Chiavi per id del segno
/// (`Zodiac.id`) e per indice del dominio (Generale 0, Amore 1, Carriera 2,
/// Fortuna 3).
class HoroscopeData {
  const HoroscopeData._();

  /// Le aperture personalizzate. Il segnaposto `[Nome]` si sostituisce col
  /// vocativo completo (Caro o Cara piu' il nome, altrimenti Ciao piu' il nome).
  static const String namePlaceholder = '[Nome]';

  static const List<String> openings = [
    '[Nome], oggi il cielo ha qualcosa da dirti.',
    '[Nome], le stelle di oggi ti guardano con favore.',
    '[Nome], oggi Medora ti accompagna passo dopo passo.',
    '[Nome], c\'è un buon vento nelle stelle di oggi.',
    '[Nome], oggi il tuo cielo si accende.',
    '[Nome], lascia che il cielo di oggi ti sorprenda.',
  ];

  /// **IL GIORNO NELLE DODICI CASE**, ordine ER voce 14: per ogni dominio e
  /// per ogni casa solare che la Luna attraversa (da 1 a 12, all'indice da 0
  /// a 11), tre titoli e tre prime parti. Sostituiscono le ancore fisse dei
  /// segni.
  static const Map<int, List<List<String>>> titoliDelGiorno = {
    0: [
      ['Il centro sei tu', 'Il primo passo è tuo', 'Presenza in prima linea'],
      ['Ciò che vale davvero', 'Mani che sanno tenere', 'Il valore delle cose'],
      [
        'Pensieri in viaggio',
        'Parole che aprono strade',
        'Il filo delle parole'
      ],
      [
        'Il ritorno alle radici',
        'Il nido che protegge',
        'Fondamenta che reggono'
      ],
      [
        'Il gioco che accende',
        'Creare per il piacere',
        'Una scintilla di gioia'
      ],
      ['Il ritmo che sostiene', 'Piccoli gesti quotidiani', 'Ordine nelle ore'],
      [
        'Lo specchio dell\'altro',
        'Incontri che insegnano',
        'Accordi da rinnovare'
      ],
      [
        'Ciò che si trasforma',
        'Fiducia in profondità',
        'Lasciare per rinnovarsi'
      ],
      ['Orizzonti più ampi', 'Il senso del viaggio', 'Una mappa nuova'],
      ['La vetta in vista', 'Il nome che costruisci', 'Obiettivi in chiaro'],
      [
        'Amici e progetti',
        'Il cerchio che sostiene',
        'Sguardo verso il futuro'
      ],
      ['Il silenzio che nutre', 'Chiudere un cerchio', 'Il riposo necessario'],
    ],
    1: [
      [
        'Il fascino che irradia',
        'Attrazione a viso aperto',
        'Il primo gesto d\'amore'
      ],
      ['Tenerezza concreta', 'Il valore del legame', 'Gesti che nutrono'],
      ['Parole che avvicinano', 'Messaggi dal cuore', 'Il dialogo che scalda'],
      ['L\'amore di casa', 'Calore tra le mura', 'Radici del cuore'],
      ['Il gioco della seduzione', 'Cuore che si diverte', 'Amore in festa'],
      [
        'Amore nei gesti piccoli',
        'Cura di ogni giorno',
        'La tenerezza pratica'
      ],
      ['Due passi insieme', 'Il patto a due', 'Incontro che specchia'],
      ['Intimità senza difese', 'Fiducia che unisce', 'Passione che trasforma'],
      ['Amore oltre i confini', 'Il viaggio a due', 'Un sogno condiviso'],
      [
        'Un legame che si mostra',
        'Progetti di coppia',
        'La direzione del cuore'
      ],
      [
        'Amicizia e tenerezza',
        'Amore tra gli amici',
        'Desideri a lungo termine'
      ],
      [
        'Sentimenti in silenzio',
        'L\'amore che si custodisce',
        'Chiudere con dolcezza'
      ],
    ],
    2: [
      ['L\'iniziativa che conta', 'Mettersi in gioco', 'La mossa d\'apertura'],
      ['Il valore del lavoro', 'Competenze in vetrina', 'Mattoni solidi'],
      ['Comunicare con chiarezza', 'Contatti utili', 'Idee da condividere'],
      ['Basi da rafforzare', 'Lavoro dal nido', 'Fondamenta del mestiere'],
      ['Talento in scena', 'La creatività al lavoro', 'Il piacere di fare'],
      ['Metodo e costanza', 'Il mestiere quotidiano', 'Un passo alla volta'],
      [
        'Alleanze che rafforzano',
        'Accordi ben scritti',
        'Trattative con garbo'
      ],
      ['Risorse in comune', 'Il cambiamento utile', 'Dietro i numeri'],
      [
        'Studio che apre porte',
        'Visione a lungo raggio',
        'Oltre il proprio ufficio'
      ],
      [
        'Il passo verso la vetta',
        'Il riconoscimento giusto',
        'Ruolo in primo piano'
      ],
      ['La forza della rete', 'Progetti di squadra', 'Visione condivisa'],
      [
        'Lavoro dietro le quinte',
        'Preparazione silenziosa',
        'Chiudere le pratiche'
      ],
    ],
    3: [
      [
        'La fortuna ti somiglia',
        'Fiuto per le occasioni',
        'Il colpo d\'occhio giusto'
      ],
      ['Ciò che hai già', 'Un oggetto ritrovato', 'Occasioni concrete'],
      ['Notizie che sorprendono', 'Un incontro per strada', 'La parola giusta'],
      ['Fortuna tra le mura', 'Il dono delle radici', 'Scoperte in casa'],
      ['Sorte che sorride', 'Il colpo di genio', 'Gioia che attira'],
      [
        'Fortuna nella routine',
        'Il dettaglio che cambia',
        'Ordine che porta bene'
      ],
      ['Fortuna in coppia', 'L\'incontro che apre', 'Alleati inattesi'],
      ['L\'intuito profondo', 'Ciò che si rivela', 'Fortuna condivisa'],
      ['La fortuna viaggia', 'Una porta lontana', 'Coincidenze parlanti'],
      ['Fortuna nel lavoro', 'L\'occasione visibile', 'Salire di un gradino'],
      ['Amici portafortuna', 'Il gruppo che rilancia', 'Desideri in cammino'],
      ['Fortuna silenziosa', 'La protezione invisibile', 'Sogni che indicano'],
    ],
  };

  static const Map<int, List<List<String>>> primeDelGiorno = {
    0: [
      [
        'La giornata ruota intorno a te, al tuo corpo e alla tua iniziativa, quindi scegli una cosa che rimandi da tempo e cominciala.',
        'Senti con chiarezza ciò che vuoi perché l\'energia torna nelle tue mani, così hai la forza per decidere senza chiedere permesso.',
        'Prenditi cura di come ti presenti al mondo, dal modo di muoverti allo sguardo, perché la tua presenza parla prima delle parole.'
      ],
      [
        'Metti in ordine ciò che possiedi, oggetti, tempo e capacità, per vedere con chiarezza quali risorse ti sostengono davvero.',
        'La giornata chiede concretezza, quindi dai peso a quello che sai fare bene perché il tuo talento è una ricchezza che spesso sottovaluti.',
        'Riconosci il tuo valore senza misurarlo sugli altri, poi concediti un piacere semplice legato ai sensi, un buon pasto o un tessuto morbido.'
      ],
      [
        'Le parole scorrono con facilità, quindi scrivi quel messaggio che tieni in sospeso o chiama una persona che non senti da tempo.',
        'Piccoli spostamenti e conversazioni di passaggio portano idee utili, perciò esci anche solo per una commissione con la curiosità accesa.',
        'Un fratello, una sorella o un vicino possono offrirti lo spunto giusto, quindi ascolta con attenzione anche le chiacchiere più leggere.'
      ],
      [
        'Il bisogno di casa si fa sentire, quindi riserva tempo alle tue stanze, a chi ci vive con te o a un ricordo di famiglia.',
        'Torna a ciò che ti protegge, un luogo, un sapore d\'infanzia, una voce familiare, per ritrovare il centro prima di ripartire.',
        'Sistema un angolo della tua casa, anche piccolo, perché mettere ordine fuori aiuta a sentire più saldo il terreno sotto i piedi.'
      ],
      [
        'Il piacere torna protagonista, quindi concediti qualcosa che fai solo perché ti diverte, senza chiederti a cosa serva.',
        'Dai spazio alla tua vena creativa con un disegno, una ricetta, una canzone cantata a voce alta, perché esprimerti ti rimette in circolo.',
        'Ridere con chi ami o giocare con i più piccoli di casa porta leggerezza, quindi lascia che la giornata abbia un tono più giocoso.'
      ],
      [
        'Le abitudini fanno la differenza, quindi scegli un gesto quotidiano da migliorare, come l\'ora del risveglio o una pausa senza schermo.',
        'Metti ordine nelle tue giornate con una lista breve di cose da fare, perché un ritmo chiaro alleggerisce la mente.',
        'Prenditi cura del corpo con attenzioni semplici, una camminata, un pasto con calma, qualche respiro lento, perché la cura quotidiana ti rende più presente.'
      ],
      [
        'L\'attenzione si sposta sulle persone accanto a te, quindi ascolta davvero chi ti sta di fronte prima di rispondere.',
        'Un accordo, una collaborazione o un rapporto a due chiede chiarezza, perciò esprimi con garbo ciò che ti serve per sentirti in equilibrio.',
        'Chi incontri ti restituisce qualcosa di te, come uno specchio, quindi osserva cosa ti colpisce negli altri per conoscerti meglio.'
      ],
      [
        'La giornata scende in profondità, quindi dai spazio a un sentimento che tieni nascosto e condividilo con una persona di cui ti fidi.',
        'Qualcosa chiede di cambiare pelle, un\'abitudine o un modo di pensare, perciò congeda ciò che non ti somiglia più.',
        'Quello che condividi con gli altri, spazi, progetti, fiducia, merita uno sguardo onesto, così puoi capire dove dai troppo e dove ricevi.'
      ],
      [
        'La mente cerca spazio, quindi leggi qualcosa che ti porti lontano o pianifica un viaggio anche solo con l\'immaginazione.',
        'Una domanda di senso ti accompagna, perciò regalati il tempo di pensare in grande a ciò in cui credi davvero.',
        'Imparare qualcosa di nuovo ti fa bene, un corso, una lingua, una conversazione con chi viene da lontano, perché allarga il tuo sguardo.'
      ],
      [
        'I tuoi obiettivi tornano al centro, quindi scrivi il traguardo che ti sta più a cuore insieme al primo passo concreto per avvicinarlo.',
        'Ciò che fai si vede più del solito, perciò cura i dettagli del tuo impegno pubblico come se fossero la tua firma.',
        'È il momento di assumerti una responsabilità che senti tua, perché la direzione della tua vita si decide con scelte visibili.'
      ],
      [
        'Gli amici hanno un ruolo speciale, quindi cerca la compagnia di chi condivide i tuoi ideali per dare forma a un progetto comune.',
        'Il futuro chiede di essere immaginato, perciò annota un desiderio a lungo termine senza preoccuparti ancora di come realizzarlo.',
        'Un gruppo, una comunità o una rete di persone può darti slancio, quindi partecipa senza timore di portare la tua voce.'
      ],
      [
        'La giornata invita al raccoglimento, quindi riduci gli impegni dove puoi e ascolta ciò che emerge nel silenzio.',
        'Un ciclo si sta chiudendo, perciò ringrazia ciò che hai vissuto prima di ricominciare, senza fretta di riempire subito il vuoto.',
        'Il riposo non è tempo perso, quindi concediti qualche ora per dormire, sognare o restare in disparte a riordinare i pensieri.'
      ],
    ],
    1: [
      [
        'Hai un magnetismo naturale che si nota, quindi fai tu il primo gesto verso chi ti interessa senza aspettare il momento perfetto.',
        'Nell\'amore conta come ti senti nella tua pelle, perciò dedica attenzione a te prima di cercare conferme negli occhi altrui.',
        'Mostrati per ciò che sei, con i tuoi desideri dichiarati, perché la sincerità del corpo e dello sguardo attira legami veri.'
      ],
      [
        'Nel legame cerchi stabilità, così un gesto concreto vale più di mille parole, una cena preparata con cura o un regalo semplice.',
        'Dare valore a ciò che provi è il primo passo, perciò non svenderti in una relazione che ti chiede meno di quanto meriti.',
        'Sensi e tenerezza guidano i sentimenti, quindi regala tempo al contatto, a un abbraccio lungo, a un profumo che ami.'
      ],
      [
        'Scrivere diventa il ponte dell\'affetto, perciò manda un messaggio tenero senza un motivo preciso a chi occupa i tuoi pensieri.',
        'Una conversazione leggera può trasformarsi in complicità, così vale la pena proporre una breve passeggiata insieme per parlare con calma.',
        'Dire ciò che senti con semplicità scioglie i nodi, perciò scegli parole gentili anche quando esprimi un bisogno o un piccolo dubbio.'
      ],
      [
        'L\'affetto abita tra le mura domestiche, quindi rendi accogliente uno spazio dove condividere tempo lento con chi ami.',
        'Famiglia e sentimenti si intrecciano, perciò dedica una telefonata o una visita a chi ti ha insegnato per primo cosa significa voler bene.',
        'Cerchi un amore che sappia di casa, così una cena semplice o una coperta condivisa dicono più di qualsiasi grande promessa.'
      ],
      [
        'L\'amore ha voglia di giocare, quindi organizza qualcosa di divertente e imprevisto, un invito spontaneo o una sorpresa leggera.',
        'Corteggiare e lasciarti corteggiare è un piacere, perciò vesti la tua parte migliore e goditi gli sguardi senza pensare al dopo.',
        'Romanticismo e creatività vanno a braccetto, così una lettera scritta a mano o una canzone dedicata possono accendere la complicità.'
      ],
      [
        'L\'amore passa dalla cura quotidiana, quindi aiuta chi ami in una piccola incombenza o dividi con equità i compiti di casa.',
        'Nei gesti di ogni giorno si vede quanto tieni a qualcuno, perciò prepara un caffè, ricorda un impegno, lascia un biglietto sul tavolo.',
        'Ritmi diversi possono creare attriti, così vale la pena accordare gli orari con chi ami per ritagliare momenti di calma condivisa.'
      ],
      [
        'La coppia è al centro della scena, quindi dedica al partner un\'attenzione piena, ascoltando più di quanto parli.',
        'Un incontro può avere il sapore di uno specchio, perciò se vivi da single osserva chi ti attrae per capire cosa cerchi davvero.',
        'Gli accordi di coppia chiedono di essere rinnovati, così parla apertamente di ciò che desideri costruire insieme nei prossimi mesi.'
      ],
      [
        'L\'intimità chiede profondità, quindi lascia cadere una difesa e mostra a chi ami una parte di te che di solito custodisci.',
        'Passione e fiducia camminano insieme, perciò dai valore ai momenti a due dove il corpo parla con sincerità.',
        'Un legame può cambiare forma per diventare più vero, così affronta con delicatezza un tema che tra voi resta sospeso da tempo.'
      ],
      [
        'L\'amore chiede orizzonti, quindi progetta con chi ami un viaggio o una gita fuori porta che rompa la routine.',
        'Condividere valori e visioni rende il legame più profondo, perciò parla con chi ami dei valori che vi tengono insieme.',
        'Una persona lontana o di un\'altra cultura può incuriosirti, così lascia che la differenza diventi occasione di scoperta.'
      ],
      [
        'Il legame chiede una direzione, quindi parla con chi ami degli obiettivi comuni, di dove desideri arrivare insieme.',
        'Mostrare i tuoi sentimenti senza nasconderli ha valore, perciò presenta con orgoglio chi ami alle persone che contano per te.',
        'Tra impegni e affetti serve equilibrio, così proteggi uno spazio per la relazione anche nelle giornate più piene di lavoro.'
      ],
      [
        'Tra gli amici c\'è spazio per la tenerezza, quindi accetta un invito di gruppo dove puoi mostrarti con leggerezza.',
        'Con chi ami condividi anche i sogni futuri, perciò racconta un desiderio che vorresti realizzare insieme tra qualche anno.',
        'Amicizia e sentimento si toccano, così una persona del tuo cerchio può mostrarti un volto nuovo se la guardi con occhi liberi.'
      ],
      [
        'I sentimenti lavorano nel silenzio, quindi concediti tempo per capire cosa provi davvero prima di dirlo ad alta voce.',
        'Una vecchia storia può tornare nei pensieri, perciò lasciala andare con gratitudine senza cercare contatti che riaprono ferite.',
        'Un gesto d\'amore fatto in segreto ha un valore speciale, così prenditi cura di chi ami senza chiedere nulla in cambio.'
      ],
    ],
    2: [
      [
        'Sul lavoro serve la tua iniziativa, quindi proponi un\'idea o prendi in mano un compito senza aspettare che qualcuno te lo chieda.',
        'Presentarti con decisione fa la differenza, perciò cura il modo in cui ti poni in riunione o in un colloquio importante.',
        'Hai energia per partire con un progetto nuovo, così scegli una priorità unica da portare avanti con passo deciso.'
      ],
      [
        'Le tue competenze sono una risorsa concreta, quindi fai un elenco di ciò che sai fare per dare valore al tuo lavoro.',
        'Valuta con lucidità quanto tempo ed energie dedichi a ogni compito, perché le risorse ben distribuite rendono di più.',
        'Costruire con pazienza porta stabilità, perciò consolida ciò che hai già avviato invece di aprire nuovi fronti.'
      ],
      [
        'Il lavoro passa dalle parole, quindi scrivi quella mail, prepara quella presentazione o fai la telefonata che rimandi.',
        'Colleghi e contatti vicini offrono spunti preziosi, perciò scambia idee in modo informale durante una pausa o un breve incontro.',
        'Brevi spostamenti di lavoro, riunioni o commissioni possono sbloccare una situazione, così muoviti con agilità da un impegno all\'altro.'
      ],
      [
        'Riordina archivi, strumenti e procedure prima di lanciarti in nuove sfide, perché il lavoro chiede basi solide da cui partire.',
        'Lavorare da casa o in un ambiente raccolto ti rende più efficace, così scegli un luogo tranquillo per i compiti più delicati.',
        'Famiglia e impegni professionali cercano un equilibrio, perciò stabilisci un orario chiaro per staccare dal lavoro.'
      ],
      [
        'La tua creatività è una risorsa professionale, quindi proponi una soluzione originale anche se esce dagli schemi abituali.',
        'Mettere passione in ciò che fai rende il lavoro più leggero, perciò comincia dal compito che ti diverte di più.',
        'Un progetto personale merita spazio, così dedica un\'ora a quell\'idea che coltivi per piacere perché può rivelare un talento spendibile.'
      ],
      [
        'La giornata di lavoro premia il metodo, quindi organizza le attività in blocchi brevi con una pausa tra l\'uno e l\'altro.',
        'Curare i dettagli fa la differenza, perciò rileggi, controlla, sistema quello che di solito lasceresti per dopo.',
        'Con i colleghi conta la collaborazione pratica, così offri una mano concreta in un compito lungo o ripetitivo.'
      ],
      [
        'Collaborazioni e accordi sono al centro, quindi leggi con attenzione ogni proposta prima di firmare o di dare la tua parola.',
        'Un socio, un cliente o un collega stretto ha qualcosa da dirti, perciò ascolta il suo punto di vista prima di difendere il tuo.',
        'Negoziare con calma porta risultati migliori, così cerca un terreno comune dove entrambe le parti si sentano rispettate.'
      ],
      [
        'Accogli un cambiamento di ruolo o di metodo come occasione per rinnovarti, perché il lavoro attraversa una fase di trasformazione.',
        'Progetti condivisi e risorse comuni chiedono chiarezza, perciò definisci bene chi fa cosa per evitare malintesi.',
        'Scavare in profondità ti dà un vantaggio, così analizza dati, documenti o dettagli che altri trascurano.'
      ],
      [
        'Allargare le competenze ti fa crescere, quindi iscriviti a un corso o leggi un testo che approfondisca il tuo mestiere.',
        'Contatti lontani o progetti internazionali possono aprire strade, perciò rispondi a quella proposta che viene da fuori.',
        'Guardare il quadro generale ti aiuta a scegliere, così chiediti dove vuoi arrivare professionalmente nei prossimi anni.'
      ],
      [
        'I tuoi obiettivi professionali sono in primo piano, quindi presenta i risultati raggiunti a chi può valorizzarli.',
        'È un buon momento per chiedere un confronto sulla tua crescita, perciò prepara con cura cosa vuoi dire ai tuoi responsabili.',
        'La tua reputazione si costruisce con coerenza, così mantieni le promesse fatte anche nelle piccole cose.'
      ],
      [
        'Scrivi a un contatto professionale che stimi per condividere un\'idea, perché la tua rete può aprire strade inattese.',
        'Il lavoro di squadra rende più di quello individuale, perciò coinvolgi gli altri in un progetto e riconosci il contributo di ciascuno.',
        'Guardare avanti dà forma ai tuoi piani, così traccia una bozza del progetto che vorresti realizzare nel prossimo anno.'
      ],
      [
        'Il lavoro più utile avviene dietro le quinte, quindi porta avanti con discrezione ciò che non ha ancora bisogno di essere mostrato.',
        'Preparare in silenzio è una forza, perciò studia, rifinisci, prepara il terreno per il momento in cui uscire allo scoperto.',
        'Chiudere le pratiche in sospeso libera energia, così concludi un compito vecchio prima di aprirne uno nuovo.'
      ],
    ],
    3: [
      [
        'Fai tu la prima mossa quando senti che il momento è giusto, perché la fortuna risponde alla tua iniziativa personale.',
        'Il tuo intuito è acceso, perciò segui la prima impressione davanti a una scelta rapida invece di perderti nei dubbi.',
        'Piccoli colpi di fortuna arrivano a chi si mostra, così esci, fatti vedere, accetta un invito all\'ultimo momento.'
      ],
      [
        'Le occasioni passano dalle cose concrete, quindi guarda con occhi nuovi ciò che possiedi perché un oggetto dimenticato può tornare utile.',
        'Un\'occasione può nascere da un talento che dai per scontato, perciò offri le tue capacità a chi ne ha bisogno.',
        'Riconoscere il valore di ciò che hai già attira altre occasioni, così ringrazia per le piccole comodità della tua giornata.'
      ],
      [
        'Una notizia inattesa o una parola ascoltata per caso può indicarti la strada, quindi tieni le orecchie aperte.',
        'I piccoli spostamenti portano sorprese, perciò cambia percorso abituale o fai una commissione a piedi per incrociare l\'occasione giusta.',
        'Rispondi con prontezza a chi ti cerca con una proposta, perché un messaggio o una telefonata possono aprire una porta.'
      ],
      [
        'Ascolta il consiglio di una persona di famiglia, perché la fortuna si nasconde vicino a te, tra le tue mura.',
        'Riordinare un cassetto o una soffitta può riservare una bella sorpresa, perciò dedica un momento a mettere mano alle tue cose.',
        'Nelle tradizioni di famiglia c\'è una piccola chiave, così recupera un\'abitudine o un gesto portafortuna tramandato.'
      ],
      [
        'Fai qualcosa per puro piacere, perché la sorte premia la leggerezza e favorisce le iniziative creative.',
        'Un\'idea creativa può rivelarsi un piccolo colpo di fortuna, perciò annotala subito e dalle forma con entusiasmo.',
        'Divertirti accende il tuo magnetismo, così accetta un invito a uno spettacolo, una festa o un pomeriggio di svago.'
      ],
      [
        'Presta attenzione alle piccole coincidenze sul lavoro o nelle commissioni, perché le occasioni si annidano nei dettagli quotidiani.',
        'Prova un orario nuovo, una strada diversa, un metodo alternativo, perché cambiare abitudine può aprire una possibilità inattesa.',
        'Mettere ordine libera spazio anche per la buona sorte, così sistema la scrivania prima di cominciare le attività della giornata.'
      ],
      [
        'Accetta l\'aiuto o il consiglio di chi ti sta accanto, perché la buona occasione passa attraverso un\'altra persona.',
        'Presentati con apertura a chi incroci sulla tua strada, perché un incontro casuale può trasformarsi in un\'alleanza utile.',
        'Collaborare porta più fortuna che agire in solitudine, così proponi a qualcuno di unire le forze per un piccolo obiettivo comune.'
      ],
      [
        'Fidati di una sensazione forte anche se non sai spiegarla del tutto, perché il tuo intuito scava in profondità.',
        'Ascolta con discrezione ciò che ti viene confidato, perché nella fiducia di una persona vicina può esserci il consiglio che cerchi.',
        'Condividere risorse e fiducia crea occasioni, così proponi uno scambio di favori con chi conosci bene.'
      ],
      [
        'Rispondi a un invito fuori città o a un contatto di un altro paese, perché le occasioni vengono da lontano.',
        'Studiare o leggere per curiosità può offrirti l\'intuizione giusta, perciò apri quel libro che aspetta da tempo sul comodino.',
        'Le coincidenze parlano la lingua del senso, così annota le frasi o le immagini che si ripetono nella tua giornata.'
      ],
      [
        'Candidati, proponiti o chiedi lo spazio che senti di meritare, perché la buona sorte guarda ai tuoi obiettivi.',
        'Una persona influente può notarti, perciò cura la qualità del tuo lavoro anche quando pensi che nessuno stia guardando.',
        'Conta il tempismo più del solito, così scegli con attenzione il momento per presentare un\'idea a chi decide.'
      ],
      [
        'Gli amici portano fortuna, quindi accetta un invito di gruppo perché da una conversazione può nascere un\'occasione.',
        'Racconta un desiderio per il futuro a qualcuno di cui ti fidi, perché condividerlo gli dà sostegno e concretezza.',
        'Una rete di contatti può offrirti una scorciatoia, così chiedi un\'informazione o un consiglio senza timore di disturbare.'
      ],
      [
        'Affidati ai segnali sottili, un sogno, una sensazione, una coincidenza, perché la buona sorte agisce in silenzio.',
        'Chi rallenta coglie ciò che gli altri non vedono, perciò concediti un momento di quiete prima di ogni scelta importante.',
        'Offri il tuo aiuto senza aspettarti riconoscimenti, perché un gesto generoso fatto in segreto apre porte inattese.'
      ],
    ],
  };

  /// I pool della corrente del giorno, dieci frasi per dominio, per tutti i segni.
  static const Map<int, List<String>> dayPools = {
    0: [
      'Oggi parti dal primo passo, il resto si chiarisce strada facendo.',
      'Una piccola scelta di oggi vale più di un grande piano rimandato.',
      'Il ritmo giusto lo detti tu, non chi ti corre intorno.',
      'Ascolta cosa ti chiede il corpo prima di riempire l\'agenda.',
      'Un imprevisto può rivelarsi la parte migliore della giornata.',
      'Concediti una pausa vera, la lucidità torna nel silenzio.',
      'Di\' un sì convinto o un no chiaro, i forse oggi ti pesano.',
      'La giornata premia chi resta presente, non chi anticipa tutto.',
      'Rimetti al centro una cosa che conta, lascia cadere il rumore.',
      'Fidati di ciò che senti, oggi la tua intuizione ci vede lungo.',
    ],
    1: [
      'Oggi la sincerità apre più porte di qualsiasi strategia.',
      'Un gesto piccolo dice più di mille parole rimandate.',
      'Chi ti sta vicino aspetta un tuo passo, fallo senza timore.',
      'Lascia respirare l\'altro, la giusta distanza avvicina.',
      'Una conversazione sospesa oggi può ritrovare il suo filo.',
      'Mostra il lato che di solito proteggi, verrà accolto.',
      'Se sei in coppia, la tenerezza conta più della ragione.',
      'Se [sei da solo|sei da sola|non hai qualcuno accanto], un incontro leggero merita attenzione.',
      'Perdona una piccola ruvidezza, non tutto va discusso.',
      'Ascolta davvero, prima di rispondere fai un respiro.',
    ],
    2: [
      'Un\'idea proposta al momento giusto oggi trova ascolto.',
      'Concentra le forze su una cosa sola e portala a termine.',
      'Chiedi ciò che ti spetta con calma, la fermezza paga.',
      'Un collega può diventare un alleato, apri uno spiraglio.',
      'Rimanda la mossa rischiosa, oggi la pazienza rende di più.',
      'Il dettaglio che curi adesso ti evita un problema domani.',
      'Fatti notare per come risolvi, non per quanto corri.',
      'Una porta che sembrava chiusa merita un secondo bussare.',
      'Metti ordine prima di aggiungere, la chiarezza sblocca.',
      'Il tuo valore si vede nei fatti, lascia che parlino.',
    ],
    3: [
      'La sorte oggi premia chi osa un piccolo passo in più.',
      'Tieni gli occhi aperti, un\'occasione arriva travestita da caso.',
      'Un incontro inatteso porta con sé una buona notizia.',
      'Segui la coincidenza, oggi non è affatto casuale.',
      'La fortuna gira dalla tua parte nel pomeriggio, [fatti trovare pronto|fatti trovare pronta|tieniti a disposizione].',
      'Un no di ieri libera lo spazio per un sì migliore.',
      'Rischia con misura, il cielo accompagna chi si fida.',
      'Una parola detta al momento giusto ti apre una via.',
      'Cerca il bello nelle piccole cose, oggi si moltiplica.',
      'Un vecchio contatto può tornare utile, non stupirti.',
    ],
  };

  /// Le palette del colore del giorno, per id del segno.
  static const Map<String, List<String>> palettes = {
    'aries': ['rosso', 'oro', 'corallo', 'cremisi'],
    'taurus': ['verde salvia', 'terracotta', 'ottone', 'rosa antico'],
    'gemini': ['giallo', 'azzurro', 'argento', 'lilla'],
    'cancer': ['argento', 'bianco perla', 'blu notte', 'glicine'],
    'leo': ['oro', 'ambra', 'arancio', 'porpora'],
    'virgo': ['verde bosco', 'beige', 'blu polvere', 'bronzo'],
    'libra': ['rosa cipria', 'verde acqua', 'oro rosa', 'celeste'],
    'scorpio': ['rosso scuro', 'nero', 'bordeaux', 'verde smeraldo'],
    'sagittarius': ['viola', 'indaco', 'oro', 'turchese'],
    'capricorn': ['grigio pietra', 'marrone', 'verde scuro', 'antracite'],
    'aquarius': ['turchese', 'blu elettrico', 'argento', 'blu ghiaccio'],
    'pisces': ['verde mare', 'lavanda', 'argento', 'blu oltremare'],
  };

  /// La riga di disclaimer, mostrata una sola volta.
  static const String disclaimer =
      'Il cielo inclina, non obbliga: nessun destino è scritto, la scelta resta tua.';
}
