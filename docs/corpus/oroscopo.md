# Corpus dell'Oroscopo a quattro schede, Medora, Esoteric Circle

La headline di Medora nella Demo. Quattro schede per segno, Generale, Amore, Carriera, Fortuna, ognuna col suo indicatore visivo. Contenuto curato, deterministico, su dispositivo: si accende senza backend e senza Gemini. A runtime, quando Vertex e Gemini sono accesi, questo stesso impianto diventa il fallback e Gemini ci ricama la personalizzazione sul cielo reale del giorno. Voce di Medora, elegante e calda, seconda persona, registro conciso. Astrologia tropicale reale nella cornice di consapevolezza, mai fatalismo, mai giudizio su chi legge. Livello visivo prima del testo. Disclaimer una sola volta.

## Come si compone una scheda

Ogni scheda si monta da tre strati, concatenati in questo ordine:

1. Titolo e prima parte del giorno. Dall'ordine ER voce 14 li sceglie la casa solare che la Luna attraversa quel giorno, contata dal segno, con una delle tre varianti della casa: cambiano ogni giorno e restano gli stessi fino a mezzanotte (sezione "Il giorno nelle dodici case"). Fino all'ordine ER questo strato era l'ancora del segno, una frase stabile che diceva la natura vera del segno in quel dominio, elemento e pianeta e tema, e non cambiava mai: lo strato identitario. Le ancore restano scritte qui sotto.
2. Corrente del giorno. Una frase pescata dal pool del dominio, scelta con un seme deterministico da segno e giorno. Cambia ogni giorno ed è diversa da segno a segno, ma è riproducibile: stesso segno stesso giorno, stesso testo.
3. Indicatore visivo. Un valore da due a cinque, calcolato in modo deterministico da segno e giorno e dominio. Il pavimento è due, così nessuna scheda appare mai desolante.

Testo finale di una scheda uguale a: prima parte del giorno, spazio, corrente del giorno (fino all'ordine ER: ancora del segno, spazio, corrente del giorno). Le due frasi sono entrambe autonome e concatenabili con qualunque segno, così la composizione non sbaglia mai la grammatica.

## Regole deterministiche, per Code

- Indice del segno, da 0 Ariete a 11 Pesci. Giorno, l'ordinale del giorno nell'anno. Dominio, un intero fisso da 0 a 3, Generale 0, Amore 1, Carriera 2, Fortuna 3.
- Seme di base: una funzione hash stabile e riproducibile su (indiceSegno, giorno, anno, dominio). Niente Random di sistema, niente ora, niente fuso. Stesso ingresso, stessa uscita, sempre.
- Indice della corrente del giorno: seme modulo lunghezza del pool del dominio.
- Valore dell'indicatore: due piu' (secondo seme modulo quattro), quindi sempre nell'intervallo da due a cinque unita' piene su cinque.
- Numero fortunato della scheda Fortuna: uno piu' (terzo seme modulo novanta), quindi da uno a novanta.
- Colore del giorno della scheda Fortuna: quarto seme modulo lunghezza della palette del segno, che pesca uno dei colori elencati sotto per quel segno.

Gli indicatori sono quattro icone diverse per dominio, riempite da due a cinque: Generale l'energia, Amore i cuori, Carriera la spinta che sale, Fortuna il quadrifoglio. Sotto le icone, la scheda Fortuna mostra anche numero fortunato e colore del giorno.

## Disclaimer, una sola volta nella schermata

Il cielo inclina, non obbliga: nessun destino è scritto, la scelta resta tua.

## Aperture personalizzate

L'oroscopo e' personalizzato: il primo testo apre col nome della persona e sta prima del testo della Generale. Il vocativo lo decide la forma di cortesia scelta all'onboarding: Caro o Cara piu' il nome quando il genere e' noto, altrimenti Ciao piu' il nome. Il segnaposto [Nome] si sostituisce con quel vocativo completo.

Il seme e' lo stesso del giorno, quindi l'apertura e' deterministica e riproducibile. A runtime, quando Gemini e' acceso, l'apertura la personalizza lui sul cielo reale e sulla memoria della persona: questo resta il fallback su dispositivo.

1. [Nome], oggi il cielo ha qualcosa da dirti.
2. [Nome], le stelle di oggi ti guardano con favore.
3. [Nome], oggi Medora ti accompagna passo dopo passo.
4. [Nome], c'è un buon vento nelle stelle di oggi.
5. [Nome], oggi il tuo cielo si accende.
6. [Nome], lascia che il cielo di oggi ti sorprenda.

## Le ancore dei dodici segni

Dall'ordine ER voce 14 le ancore non si mostrano più nelle schede: il fondatore ha chiesto che titolo e prima parte cambino ogni giorno. Restano qui come la natura dei dodici segni nei quattro domini, materiale del progetto.

### Ariete, fuoco cardinale, Marte
- Generale, "Il fuoco che apre": Sei l'inizio fatto persona, la scintilla che accende prima che gli altri abbiano finito di decidere. Il coraggio del primo passo è la tua misura e ogni giorno gli sceglie una direzione diversa.
- Amore, "Cuore in avanti": In amore vai diretto, come vuole la tua natura di fuoco e la tua sincerità disarma perché chi ti ama sceglie proprio il tuo slancio. Dove quello slancio serva davvero, cambia col cielo.
- Carriera, "Slancio da guidare": Sul lavoro apri varchi dove altri vedono muri e la tua spinta è un dono che chiede una direzione più che un freno. La direzione la porta il giorno.
- Fortuna, "L'audacia premiata": La sorte, con te, ama chi osa e un rischio calcolato ti rende più di mille attese prudenti. Quale rischio valga la pena, lo mostra il giorno.

### Toro, terra fisso, Venere
- Generale, "La forza della calma": La tua natura di terra cerca stabilità e bellezza concreta e costruisci meglio di chiunque quando nessuno ti mette fretta. Dove posare il prossimo mattone, lo indica il giorno.
- Amore, "Tenerezza che dura": Ami coi sensi e con la fedeltà, attraverso i gesti più che le parole e la tua dolcezza paziente è ciò che fa sentire l'altro a casa. Quale gesto conti adesso, cambia col cielo.
- Carriera, "Il valore che resta": Sul lavoro ottieni per costanza ciò che altri inseguono per foga e la tua tenacia è la tua firma. Quanto sia vicino il raccolto, lo dice il giorno.
- Fortuna, "L'abbondanza concreta": La tua fortuna ha radici e non ali e premia ciò che curi con pazienza. Quale seme sia pronto a fruttare lo scrive il giorno.

### Gemelli, aria mobile, Mercurio
- Generale, "La mente che collega": Vivi di scambi, di parole e di idee che rimbalzano e la curiosità ti fa da bussola meglio di qualunque piano. Quale filo seguire, te lo indica il giorno.
- Amore, "Il gioco della parola": Ti innamori delle menti vivaci e delle conversazioni che non finiscono e una frase leggera può accendere più di un gesto solenne. Con chi vada spesa, cambia col cielo.
- Carriera, "Idee in movimento": Sul lavoro brilli collegando ciò che gli altri tengono separato e la versatilità è forza finché una pista la porti fino in fondo. Quale sia la tua pista, lo indica il cielo.
- Fortuna, "Il caso curioso": La tua fortuna passa dagli incontri e dall'informazione giusta al momento giusto ed è un dono che si presenta senza bussare. Da che parte stia arrivando lo racconta il giorno.

### Cancro, acqua cardinale, Luna
- Generale, "Il cuore che protegge": Senti tutto e ricordi tutto e la tua forza si chiama cura, non durezza. Verso chi rivolgerla lo suggerisce il giorno.
- Amore, "Il nido degli affetti": Ami con tenerezza e dedizione e hai bisogno di sentirti al sicuro prima di aprirti del tutto. Quanto sicuro sia il terreno, cambia col cielo.
- Carriera, "La cura che costruisce": Sul lavoro proteggi e nutri ciò che ti sta a cuore e la tua sensibilità legge le persone prima che parlino. Cosa stia chiedendo di essere letto, lo scrive il giorno.
- Fortuna, "La marea gentile": La tua fortuna segue le maree dell'intuito e sotto la superficie sai già dove guardare. Quale marea stia salendo, lo segna il cielo.

### Leone, fuoco fisso, Sole
- Generale, "La gioia di brillare": Sei calore, creatività e generosità che scalda e la tua luce fa spazio agli altri invece di toglierlo. Dove accenderla, lo indica il giorno.
- Amore, "Il cuore generoso": Ami con slancio e con teatro, doni molto e chiedi di essere visto e la tua lealtà calorosa è irresistibile quando non la trattieni. A chi stia arrivando, cambia col cielo.
- Carriera, "Il palco è tuo": Sul lavoro convinci con la passione più che con la logica fredda e il tuo entusiasmo diventa contagioso quando ha un'idea al centro. Quale idea mettere al centro, te lo suggerisce il cielo.
- Fortuna, "Il favore del Sole": La tua fortuna risponde al tuo calore e più doni e più crei, più la vita ti risponde. Da dove ti risponda lo racconta il giorno.

### Vergine, terra mobile, Mercurio
- Generale, "La cura del dettaglio": Osservi, distingui e migliori e trovi il sacro nelle piccole cose fatte bene. Quale piccola cosa rimetta in pace anche la mente, lo indica il giorno.
- Amore, "L'amore nei piccoli gesti": Ami rendendoti utile, con attenzione e discrezione e ti riesce più facile dare che ricevere. Da dove possa arrivare la cura per te, cambia col cielo.
- Carriera, "La maestria del metodo": Sul lavoro cogli il dettaglio che sfugge a tutti e la precisione è il tuo vantaggio finché non scambi un difetto per il tutto. Dove metterla, lo segna il giorno.
- Fortuna, "Il frutto del lavoro": La tua fortuna nasce dal fare bene ciò che tocchi e un miglioramento minimo ti apre porte grandi. Quale porta sia socchiusa lo scrive il giorno.

### Bilancia, aria cardinale, Venere
- Generale, "L'arte dell'equilibrio": Cerchi armonia, bellezza e giustizia e fiorisci nell'incontro più che nella solitudine. Cosa rimettere al centro per ritrovare la pace, lo suggerisce il giorno.
- Amore, "Il piacere di stare in due": Qui l'amore è la tua arte, cerchi eleganza e sintonia e un gesto di grazia ti vale più di una discussione vinta. Dove quel gesto serva, cambia col cielo.
- Carriera, "La forza della misura": Sul lavoro la tua diplomazia è un talento raro e medi dove gli altri litigano avanzando senza rumore. Quale tavolo ci sia da ricomporre, lo mostra il cielo.
- Fortuna, "L'incontro giusto": La tua fortuna arriva dalle persone giuste e dalla bellezza condivisa e un incontro ti vale più di mille sforzi solitari. Da che parte arrivi lo racconta il giorno.

### Scorpione, acqua fisso, Marte e Plutone
- Generale, "La forza di rinascere": Vivi tutto in profondità, senza mezze misure e la tua forza cresce attraversando invece di evitare. Cosa ci sia da attraversare lo indica il giorno.
- Amore, "L'intensità vera": Ami senza vie di mezzo e vuoi verità e la tua sfida non è sentire ma fidarti. Dove il terreno regga la fiducia, cambia col cielo.
- Carriera, "La strategia paziente": Sul lavoro ti muovi sotto controllo fino al momento giusto e la determinazione silenziosa ti vale più di ogni proclama. Se il momento sia arrivato, lo dice il cielo.
- Fortuna, "Il tesoro nascosto": La tua fortuna sta dove gli altri non osano guardare e un dettaglio sottovalutato diventa il tuo vantaggio. Quale dettaglio sia, lo scrive il giorno.

### Sagittario, fuoco mobile, Giove
- Generale, "La fame di orizzonte": Cerchi senso, libertà e avventura e la mente ti porta lontano prima dei piedi. Verso quale orizzonte guardare, lo indica il giorno.
- Amore, "Il volo condiviso": Ti innamori dell'avventura e della crescita a due e l'amore che ti somiglia non è mai una gabbia. Dove trovare quella leggerezza, cambia col cielo.
- Carriera, "La spinta verso l'alto": Sul lavoro il tuo entusiasmo apre porte e puntare in grande ti riesce naturale quando curi anche il passo dopo il passo. Quale passo venga per primo, lo decide il giorno.
- Fortuna, "Il favore di Giove": La tua fortuna ama l'ottimismo e il movimento e un sì detto con fiducia ti porta più lontano del previsto. A cosa dirlo lo racconta il giorno.

### Capricorno, terra cardinale, Saturno
- Generale, "La pazienza che scala": Costruisci nel tempo, con disciplina e responsabilità e le vette non ti hanno mai spaventato. Quale passo concreto ti avvicini davvero, lo indica il giorno.
- Amore, "La fedeltà che dura": Sotto il riserbo custodisci una fedeltà profonda e mostrare un lato morbido non toglie niente alla tua forza. Quando valga la pena mostrarlo, cambia col cielo.
- Carriera, "La vetta un passo alla volta": Sul lavoro nessuno costruisce per i propri obiettivi come te e i tuoi risultati parlano al posto tuo prima che tu apra bocca. Quanto siano stati notati, te lo racconta il cielo.
- Fortuna, "Il merito premiato": La tua fortuna si costruisce mattone su mattone e ciò che hai guadagnato con fatica prima o poi ti dà ragione. Quando cominci a vederlo lo scrive il giorno.

### Acquario, aria fisso, Saturno e Urano
- Generale, "La visione del futuro": Pensi diverso e guardi avanti e ami la libertà quanto le persone. Quale idea fuori dagli schemi meriti spazio, lo indica il giorno.
- Amore, "Il legame che libera": Ami in modo originale e paritario e per te l'amante è anche un complice. Dove la tua autenticità venga accolta, cambia col cielo.
- Carriera, "L'idea che apre strade": Sul lavoro vedi ciò che gli altri non osano immaginare e la tua originalità è una risorsa quando smette di temere il giudizio. Con chi condividerla, lo apre il giorno.
- Fortuna, "La sorpresa geniale": La tua fortuna arriva quando pensi in grande e per tutti e la via inattesa è quasi sempre la tua. Quale via si stia aprendo lo racconta il giorno.

### Pesci, acqua mobile, Giove e Nettuno
- Generale, "L'anima senza confini": Senti l'invisibile, sogni e ti fondi col tutto e l'intuito ti serve meglio quando gli dai dei confini. Dove tracciarli, lo indica il giorno.
- Amore, "La dolcezza che avvolge": Ami in modo tenero e avvolgente, quasi senza riserve e la tua dolcezza merita di essere ricambiata quanto è donata. Da chi possa tornarti, cambia col cielo.
- Carriera, "L'ispirazione che guida": Sul lavoro la tua sensibilità coglie ciò che sfugge ai numeri e un'intuizione ti vale un piano quando la metti a terra. Su cosa metterla, te lo indica il cielo.
- Fortuna, "Il dono dell'intuito": La tua fortuna passa dai segni sottili e dalle coincidenze e la prima sensazione ti guida bene più spesso di quanto ammetti. Verso dove ti stia guidando lo scrive il giorno.

## Il giorno nelle dodici case

Ordine ER voce 14, 27 settembre 2026. Il fondatore: "la prima metà delle schede, oggi uguale tutti i giorni", e sull'ordine "Sì, con l'Oroscopo".

Titolo e prima parte di ogni scheda li sceglie il cielo del giorno: la casa solare che la Luna attraversa, contata dal segno della persona (casa 1 la Luna nel segno, casa 2 nel segno dopo, e così via), calcolata sul dispositivo a mezzogiorno del giorno. È la tecnica tradizionale dei transiti lunari nelle case solari. Per ogni dominio e ogni casa ci sono tre titoli e tre prime parti; la variante è il resto della divisione per tre del giorno dell'anno. Due giorni di fila non hanno mai lo stesso resto, e la Luna resta in una casa al più tre giorni: titolo e prima parte non sono mai quelli del giorno prima, e sono gli stessi fino a mezzanotte.

Le frasi non nominano astri: la prima frase della scheda dice di che cosa è fatta la giornata, il pianeta lo nomina la corrente che segue. Sono state scritte per l'ordine ER e controllate sulle regole della lingua di casa.

### Generale, casa 1
T: Il centro sei tu | Il primo passo è tuo | Presenza in prima linea
P: La giornata ruota intorno a te, al tuo corpo e alla tua iniziativa, quindi scegli una cosa che rimandi da tempo e cominciala.
P: Senti con chiarezza ciò che vuoi perché l'energia torna nelle tue mani, così hai la forza per decidere senza chiedere permesso.
P: Prenditi cura di come ti presenti al mondo, dal modo di muoverti allo sguardo, perché la tua presenza parla prima delle parole.

### Generale, casa 2
T: Ciò che vale davvero | Mani che sanno tenere | Il valore delle cose
P: Metti in ordine ciò che possiedi, oggetti, tempo e capacità, per vedere con chiarezza quali risorse ti sostengono davvero.
P: La giornata chiede concretezza, quindi dai peso a quello che sai fare bene perché il tuo talento è una ricchezza che spesso sottovaluti.
P: Riconosci il tuo valore senza misurarlo sugli altri, poi concediti un piacere semplice legato ai sensi, un buon pasto o un tessuto morbido.

### Generale, casa 3
T: Pensieri in viaggio | Parole che aprono strade | Il filo delle parole
P: Le parole scorrono con facilità, quindi scrivi quel messaggio che tieni in sospeso o chiama una persona che non senti da tempo.
P: Piccoli spostamenti e conversazioni di passaggio portano idee utili, perciò esci anche solo per una commissione con la curiosità accesa.
P: Un fratello, una sorella o un vicino possono offrirti lo spunto giusto, quindi ascolta con attenzione anche le chiacchiere più leggere.

### Generale, casa 4
T: Il ritorno alle radici | Il nido che protegge | Fondamenta che reggono
P: Il bisogno di casa si fa sentire, quindi riserva tempo alle tue stanze, a chi ci vive con te o a un ricordo di famiglia.
P: Torna a ciò che ti protegge, un luogo, un sapore d'infanzia, una voce familiare, per ritrovare il centro prima di ripartire.
P: Sistema un angolo della tua casa, anche piccolo, perché mettere ordine fuori aiuta a sentire più saldo il terreno sotto i piedi.

### Generale, casa 5
T: Il gioco che accende | Creare per il piacere | Una scintilla di gioia
P: Il piacere torna protagonista, quindi concediti qualcosa che fai solo perché ti diverte, senza chiederti a cosa serva.
P: Dai spazio alla tua vena creativa con un disegno, una ricetta, una canzone cantata a voce alta, perché esprimerti ti rimette in circolo.
P: Ridere con chi ami o giocare con i più piccoli di casa porta leggerezza, quindi lascia che la giornata abbia un tono più giocoso.

### Generale, casa 6
T: Il ritmo che sostiene | Piccoli gesti quotidiani | Ordine nelle ore
P: Le abitudini fanno la differenza, quindi scegli un gesto quotidiano da migliorare, come l'ora del risveglio o una pausa senza schermo.
P: Metti ordine nelle tue giornate con una lista breve di cose da fare, perché un ritmo chiaro alleggerisce la mente.
P: Prenditi cura del corpo con attenzioni semplici, una camminata, un pasto con calma, qualche respiro lento, perché la cura quotidiana ti rende più presente.

### Generale, casa 7
T: Lo specchio dell'altro | Incontri che insegnano | Accordi da rinnovare
P: L'attenzione si sposta sulle persone accanto a te, quindi ascolta davvero chi ti sta di fronte prima di rispondere.
P: Un accordo, una collaborazione o un rapporto a due chiede chiarezza, perciò esprimi con garbo ciò che ti serve per sentirti in equilibrio.
P: Chi incontri ti restituisce qualcosa di te, come uno specchio, quindi osserva cosa ti colpisce negli altri per conoscerti meglio.

### Generale, casa 8
T: Ciò che si trasforma | Fiducia in profondità | Lasciare per rinnovarsi
P: La giornata scende in profondità, quindi dai spazio a un sentimento che tieni nascosto e condividilo con una persona di cui ti fidi.
P: Qualcosa chiede di cambiare pelle, un'abitudine o un modo di pensare, perciò congeda ciò che non ti somiglia più.
P: Quello che condividi con gli altri, spazi, progetti, fiducia, merita uno sguardo onesto, così puoi capire dove dai troppo e dove ricevi.

### Generale, casa 9
T: Orizzonti più ampi | Il senso del viaggio | Una mappa nuova
P: La mente cerca spazio, quindi leggi qualcosa che ti porti lontano o pianifica un viaggio anche solo con l'immaginazione.
P: Una domanda di senso ti accompagna, perciò regalati il tempo di pensare in grande a ciò in cui credi davvero.
P: Imparare qualcosa di nuovo ti fa bene, un corso, una lingua, una conversazione con chi viene da lontano, perché allarga il tuo sguardo.

### Generale, casa 10
T: La vetta in vista | Il nome che costruisci | Obiettivi in chiaro
P: I tuoi obiettivi tornano al centro, quindi scrivi il traguardo che ti sta più a cuore insieme al primo passo concreto per avvicinarlo.
P: Ciò che fai si vede più del solito, perciò cura i dettagli del tuo impegno pubblico come se fossero la tua firma.
P: È il momento di assumerti una responsabilità che senti tua, perché la direzione della tua vita si decide con scelte visibili.

### Generale, casa 11
T: Amici e progetti | Il cerchio che sostiene | Sguardo verso il futuro
P: Gli amici hanno un ruolo speciale, quindi cerca la compagnia di chi condivide i tuoi ideali per dare forma a un progetto comune.
P: Il futuro chiede di essere immaginato, perciò annota un desiderio a lungo termine senza preoccuparti ancora di come realizzarlo.
P: Un gruppo, una comunità o una rete di persone può darti slancio, quindi partecipa senza timore di portare la tua voce.

### Generale, casa 12
T: Il silenzio che nutre | Chiudere un cerchio | Il riposo necessario
P: La giornata invita al raccoglimento, quindi riduci gli impegni dove puoi e ascolta ciò che emerge nel silenzio.
P: Un ciclo si sta chiudendo, perciò ringrazia ciò che hai vissuto prima di ricominciare, senza fretta di riempire subito il vuoto.
P: Il riposo non è tempo perso, quindi concediti qualche ora per dormire, sognare o restare in disparte a riordinare i pensieri.

### Amore, casa 1
T: Il fascino che irradia | Attrazione a viso aperto | Il primo gesto d'amore
P: Hai un magnetismo naturale che si nota, quindi fai tu il primo gesto verso chi ti interessa senza aspettare il momento perfetto.
P: Nell'amore conta come ti senti nella tua pelle, perciò dedica attenzione a te prima di cercare conferme negli occhi altrui.
P: Mostrati per ciò che sei, con i tuoi desideri dichiarati, perché la sincerità del corpo e dello sguardo attira legami veri.

### Amore, casa 2
T: Tenerezza concreta | Il valore del legame | Gesti che nutrono
P: Nel legame cerchi stabilità, così un gesto concreto vale più di mille parole, una cena preparata con cura o un regalo semplice.
P: Dare valore a ciò che provi è il primo passo, perciò non svenderti in una relazione che ti chiede meno di quanto meriti.
P: Sensi e tenerezza guidano i sentimenti, quindi regala tempo al contatto, a un abbraccio lungo, a un profumo che ami.

### Amore, casa 3
T: Parole che avvicinano | Messaggi dal cuore | Il dialogo che scalda
P: Scrivere diventa il ponte dell'affetto, perciò manda un messaggio tenero senza un motivo preciso a chi occupa i tuoi pensieri.
P: Una conversazione leggera può trasformarsi in complicità, così vale la pena proporre una breve passeggiata insieme per parlare con calma.
P: Dire ciò che senti con semplicità scioglie i nodi, perciò scegli parole gentili anche quando esprimi un bisogno o un piccolo dubbio.

### Amore, casa 4
T: L'amore di casa | Calore tra le mura | Radici del cuore
P: L'affetto abita tra le mura domestiche, quindi rendi accogliente uno spazio dove condividere tempo lento con chi ami.
P: Famiglia e sentimenti si intrecciano, perciò dedica una telefonata o una visita a chi ti ha insegnato per primo cosa significa voler bene.
P: Cerchi un amore che sappia di casa, così una cena semplice o una coperta condivisa dicono più di qualsiasi grande promessa.

### Amore, casa 5
T: Il gioco della seduzione | Cuore che si diverte | Amore in festa
P: L'amore ha voglia di giocare, quindi organizza qualcosa di divertente e imprevisto, un invito spontaneo o una sorpresa leggera.
P: Corteggiare e lasciarti corteggiare è un piacere, perciò vesti la tua parte migliore e goditi gli sguardi senza pensare al dopo.
P: Romanticismo e creatività vanno a braccetto, così una lettera scritta a mano o una canzone dedicata possono accendere la complicità.

### Amore, casa 6
T: Amore nei gesti piccoli | Cura di ogni giorno | La tenerezza pratica
P: L'amore passa dalla cura quotidiana, quindi aiuta chi ami in una piccola incombenza o dividi con equità i compiti di casa.
P: Nei gesti di ogni giorno si vede quanto tieni a qualcuno, perciò prepara un caffè, ricorda un impegno, lascia un biglietto sul tavolo.
P: Ritmi diversi possono creare attriti, così vale la pena accordare gli orari con chi ami per ritagliare momenti di calma condivisa.

### Amore, casa 7
T: Due passi insieme | Il patto a due | Incontro che specchia
P: La coppia è al centro della scena, quindi dedica al partner un'attenzione piena, ascoltando più di quanto parli.
P: Un incontro può avere il sapore di uno specchio, perciò se vivi da single osserva chi ti attrae per capire cosa cerchi davvero.
P: Gli accordi di coppia chiedono di essere rinnovati, così parla apertamente di ciò che desideri costruire insieme nei prossimi mesi.

### Amore, casa 8
T: Intimità senza difese | Fiducia che unisce | Passione che trasforma
P: L'intimità chiede profondità, quindi lascia cadere una difesa e mostra a chi ami una parte di te che di solito custodisci.
P: Passione e fiducia camminano insieme, perciò dai valore ai momenti a due dove il corpo parla con sincerità.
P: Un legame può cambiare forma per diventare più vero, così affronta con delicatezza un tema che tra voi resta sospeso da tempo.

### Amore, casa 9
T: Amore oltre i confini | Il viaggio a due | Un sogno condiviso
P: L'amore chiede orizzonti, quindi progetta con chi ami un viaggio o una gita fuori porta che rompa la routine.
P: Condividere valori e visioni rende il legame più profondo, perciò parla con chi ami dei valori che vi tengono insieme.
P: Una persona lontana o di un'altra cultura può incuriosirti, così lascia che la differenza diventi occasione di scoperta.

### Amore, casa 10
T: Un legame che si mostra | Progetti di coppia | La direzione del cuore
P: Il legame chiede una direzione, quindi parla con chi ami degli obiettivi comuni, di dove desideri arrivare insieme.
P: Mostrare i tuoi sentimenti senza nasconderli ha valore, perciò presenta con orgoglio chi ami alle persone che contano per te.
P: Tra impegni e affetti serve equilibrio, così proteggi uno spazio per la relazione anche nelle giornate più piene di lavoro.

### Amore, casa 11
T: Amicizia e tenerezza | Amore tra gli amici | Desideri a lungo termine
P: Tra gli amici c'è spazio per la tenerezza, quindi accetta un invito di gruppo dove puoi mostrarti con leggerezza.
P: Con chi ami condividi anche i sogni futuri, perciò racconta un desiderio che vorresti realizzare insieme tra qualche anno.
P: Amicizia e sentimento si toccano, così una persona del tuo cerchio può mostrarti un volto nuovo se la guardi con occhi liberi.

### Amore, casa 12
T: Sentimenti in silenzio | L'amore che si custodisce | Chiudere con dolcezza
P: I sentimenti lavorano nel silenzio, quindi concediti tempo per capire cosa provi davvero prima di dirlo ad alta voce.
P: Una vecchia storia può tornare nei pensieri, perciò lasciala andare con gratitudine senza cercare contatti che riaprono ferite.
P: Un gesto d'amore fatto in segreto ha un valore speciale, così prenditi cura di chi ami senza chiedere nulla in cambio.

### Carriera, casa 1
T: L'iniziativa che conta | Mettersi in gioco | La mossa d'apertura
P: Sul lavoro serve la tua iniziativa, quindi proponi un'idea o prendi in mano un compito senza aspettare che qualcuno te lo chieda.
P: Presentarti con decisione fa la differenza, perciò cura il modo in cui ti poni in riunione o in un colloquio importante.
P: Hai energia per partire con un progetto nuovo, così scegli una priorità unica da portare avanti con passo deciso.

### Carriera, casa 2
T: Il valore del lavoro | Competenze in vetrina | Mattoni solidi
P: Le tue competenze sono una risorsa concreta, quindi fai un elenco di ciò che sai fare per dare valore al tuo lavoro.
P: Valuta con lucidità quanto tempo ed energie dedichi a ogni compito, perché le risorse ben distribuite rendono di più.
P: Costruire con pazienza porta stabilità, perciò consolida ciò che hai già avviato invece di aprire nuovi fronti.

### Carriera, casa 3
T: Comunicare con chiarezza | Contatti utili | Idee da condividere
P: Il lavoro passa dalle parole, quindi scrivi quella mail, prepara quella presentazione o fai la telefonata che rimandi.
P: Colleghi e contatti vicini offrono spunti preziosi, perciò scambia idee in modo informale durante una pausa o un breve incontro.
P: Brevi spostamenti di lavoro, riunioni o commissioni possono sbloccare una situazione, così muoviti con agilità da un impegno all'altro.

### Carriera, casa 4
T: Basi da rafforzare | Lavoro dal nido | Fondamenta del mestiere
P: Riordina archivi, strumenti e procedure prima di lanciarti in nuove sfide, perché il lavoro chiede basi solide da cui partire.
P: Lavorare da casa o in un ambiente raccolto ti rende più efficace, così scegli un luogo tranquillo per i compiti più delicati.
P: Famiglia e impegni professionali cercano un equilibrio, perciò stabilisci un orario chiaro per staccare dal lavoro.

### Carriera, casa 5
T: Talento in scena | La creatività al lavoro | Il piacere di fare
P: La tua creatività è una risorsa professionale, quindi proponi una soluzione originale anche se esce dagli schemi abituali.
P: Mettere passione in ciò che fai rende il lavoro più leggero, perciò comincia dal compito che ti diverte di più.
P: Un progetto personale merita spazio, così dedica un'ora a quell'idea che coltivi per piacere perché può rivelare un talento spendibile.

### Carriera, casa 6
T: Metodo e costanza | Il mestiere quotidiano | Un passo alla volta
P: La giornata di lavoro premia il metodo, quindi organizza le attività in blocchi brevi con una pausa tra l'uno e l'altro.
P: Curare i dettagli fa la differenza, perciò rileggi, controlla, sistema quello che di solito lasceresti per dopo.
P: Con i colleghi conta la collaborazione pratica, così offri una mano concreta in un compito lungo o ripetitivo.

### Carriera, casa 7
T: Alleanze che rafforzano | Accordi ben scritti | Trattative con garbo
P: Collaborazioni e accordi sono al centro, quindi leggi con attenzione ogni proposta prima di firmare o di dare la tua parola.
P: Un socio, un cliente o un collega stretto ha qualcosa da dirti, perciò ascolta il suo punto di vista prima di difendere il tuo.
P: Negoziare con calma porta risultati migliori, così cerca un terreno comune dove entrambe le parti si sentano rispettate.

### Carriera, casa 8
T: Risorse in comune | Il cambiamento utile | Dietro i numeri
P: Accogli un cambiamento di ruolo o di metodo come occasione per rinnovarti, perché il lavoro attraversa una fase di trasformazione.
P: Progetti condivisi e risorse comuni chiedono chiarezza, perciò definisci bene chi fa cosa per evitare malintesi.
P: Scavare in profondità ti dà un vantaggio, così analizza dati, documenti o dettagli che altri trascurano.

### Carriera, casa 9
T: Studio che apre porte | Visione a lungo raggio | Oltre il proprio ufficio
P: Allargare le competenze ti fa crescere, quindi iscriviti a un corso o leggi un testo che approfondisca il tuo mestiere.
P: Contatti lontani o progetti internazionali possono aprire strade, perciò rispondi a quella proposta che viene da fuori.
P: Guardare il quadro generale ti aiuta a scegliere, così chiediti dove vuoi arrivare professionalmente nei prossimi anni.

### Carriera, casa 10
T: Il passo verso la vetta | Il riconoscimento giusto | Ruolo in primo piano
P: I tuoi obiettivi professionali sono in primo piano, quindi presenta i risultati raggiunti a chi può valorizzarli.
P: È un buon momento per chiedere un confronto sulla tua crescita, perciò prepara con cura cosa vuoi dire ai tuoi responsabili.
P: La tua reputazione si costruisce con coerenza, così mantieni le promesse fatte anche nelle piccole cose.

### Carriera, casa 11
T: La forza della rete | Progetti di squadra | Visione condivisa
P: Scrivi a un contatto professionale che stimi per condividere un'idea, perché la tua rete può aprire strade inattese.
P: Il lavoro di squadra rende più di quello individuale, perciò coinvolgi gli altri in un progetto e riconosci il contributo di ciascuno.
P: Guardare avanti dà forma ai tuoi piani, così traccia una bozza del progetto che vorresti realizzare nel prossimo anno.

### Carriera, casa 12
T: Lavoro dietro le quinte | Preparazione silenziosa | Chiudere le pratiche
P: Il lavoro più utile avviene dietro le quinte, quindi porta avanti con discrezione ciò che non ha ancora bisogno di essere mostrato.
P: Preparare in silenzio è una forza, perciò studia, rifinisci, prepara il terreno per il momento in cui uscire allo scoperto.
P: Chiudere le pratiche in sospeso libera energia, così concludi un compito vecchio prima di aprirne uno nuovo.

### Fortuna, casa 1
T: La fortuna ti somiglia | Fiuto per le occasioni | Il colpo d'occhio giusto
P: Fai tu la prima mossa quando senti che il momento è giusto, perché la fortuna risponde alla tua iniziativa personale.
P: Il tuo intuito è acceso, perciò segui la prima impressione davanti a una scelta rapida invece di perderti nei dubbi.
P: Piccoli colpi di fortuna arrivano a chi si mostra, così esci, fatti vedere, accetta un invito all'ultimo momento.

### Fortuna, casa 2
T: Ciò che hai già | Un oggetto ritrovato | Occasioni concrete
P: Le occasioni passano dalle cose concrete, quindi guarda con occhi nuovi ciò che possiedi perché un oggetto dimenticato può tornare utile.
P: Un'occasione può nascere da un talento che dai per scontato, perciò offri le tue capacità a chi ne ha bisogno.
P: Riconoscere il valore di ciò che hai già attira altre occasioni, così ringrazia per le piccole comodità della tua giornata.

### Fortuna, casa 3
T: Notizie che sorprendono | Un incontro per strada | La parola giusta
P: Una notizia inattesa o una parola ascoltata per caso può indicarti la strada, quindi tieni le orecchie aperte.
P: I piccoli spostamenti portano sorprese, perciò cambia percorso abituale o fai una commissione a piedi per incrociare l'occasione giusta.
P: Rispondi con prontezza a chi ti cerca con una proposta, perché un messaggio o una telefonata possono aprire una porta.

### Fortuna, casa 4
T: Fortuna tra le mura | Il dono delle radici | Scoperte in casa
P: Ascolta il consiglio di una persona di famiglia, perché la fortuna si nasconde vicino a te, tra le tue mura.
P: Riordinare un cassetto o una soffitta può riservare una bella sorpresa, perciò dedica un momento a mettere mano alle tue cose.
P: Nelle tradizioni di famiglia c'è una piccola chiave, così recupera un'abitudine o un gesto portafortuna tramandato.

### Fortuna, casa 5
T: Sorte che sorride | Il colpo di genio | Gioia che attira
P: Fai qualcosa per puro piacere, perché la sorte premia la leggerezza e favorisce le iniziative creative.
P: Un'idea creativa può rivelarsi un piccolo colpo di fortuna, perciò annotala subito e dalle forma con entusiasmo.
P: Divertirti accende il tuo magnetismo, così accetta un invito a uno spettacolo, una festa o un pomeriggio di svago.

### Fortuna, casa 6
T: Fortuna nella routine | Il dettaglio che cambia | Ordine che porta bene
P: Presta attenzione alle piccole coincidenze sul lavoro o nelle commissioni, perché le occasioni si annidano nei dettagli quotidiani.
P: Prova un orario nuovo, una strada diversa, un metodo alternativo, perché cambiare abitudine può aprire una possibilità inattesa.
P: Mettere ordine libera spazio anche per la buona sorte, così sistema la scrivania prima di cominciare le attività della giornata.

### Fortuna, casa 7
T: Fortuna in coppia | L'incontro che apre | Alleati inattesi
P: Accetta l'aiuto o il consiglio di chi ti sta accanto, perché la buona occasione passa attraverso un'altra persona.
P: Presentati con apertura a chi incroci sulla tua strada, perché un incontro casuale può trasformarsi in un'alleanza utile.
P: Collaborare porta più fortuna che agire in solitudine, così proponi a qualcuno di unire le forze per un piccolo obiettivo comune.

### Fortuna, casa 8
T: L'intuito profondo | Ciò che si rivela | Fortuna condivisa
P: Fidati di una sensazione forte anche se non sai spiegarla del tutto, perché il tuo intuito scava in profondità.
P: Ascolta con discrezione ciò che ti viene confidato, perché nella fiducia di una persona vicina può esserci il consiglio che cerchi.
P: Condividere risorse e fiducia crea occasioni, così proponi uno scambio di favori con chi conosci bene.

### Fortuna, casa 9
T: La fortuna viaggia | Una porta lontana | Coincidenze parlanti
P: Rispondi a un invito fuori città o a un contatto di un altro paese, perché le occasioni vengono da lontano.
P: Studiare o leggere per curiosità può offrirti l'intuizione giusta, perciò apri quel libro che aspetta da tempo sul comodino.
P: Le coincidenze parlano la lingua del senso, così annota le frasi o le immagini che si ripetono nella tua giornata.

### Fortuna, casa 10
T: Fortuna nel lavoro | L'occasione visibile | Salire di un gradino
P: Candidati, proponiti o chiedi lo spazio che senti di meritare, perché la buona sorte guarda ai tuoi obiettivi.
P: Una persona influente può notarti, perciò cura la qualità del tuo lavoro anche quando pensi che nessuno stia guardando.
P: Conta il tempismo più del solito, così scegli con attenzione il momento per presentare un'idea a chi decide.

### Fortuna, casa 11
T: Amici portafortuna | Il gruppo che rilancia | Desideri in cammino
P: Gli amici portano fortuna, quindi accetta un invito di gruppo perché da una conversazione può nascere un'occasione.
P: Racconta un desiderio per il futuro a qualcuno di cui ti fidi, perché condividerlo gli dà sostegno e concretezza.
P: Una rete di contatti può offrirti una scorciatoia, così chiedi un'informazione o un consiglio senza timore di disturbare.

### Fortuna, casa 12
T: Fortuna silenziosa | La protezione invisibile | Sogni che indicano
P: Affidati ai segnali sottili, un sogno, una sensazione, una coincidenza, perché la buona sorte agisce in silenzio.
P: Chi rallenta coglie ciò che gli altri non vedono, perciò concediti un momento di quiete prima di ogni scelta importante.
P: Offri il tuo aiuto senza aspettarti riconoscimenti, perché un gesto generoso fatto in segreto apre porte inattese.

## I pool della corrente del giorno, per dominio

Validi per tutti i segni. Il seme del giorno ne pesca una. Ogni frase è autonoma e si concatena dopo l'ancora di qualunque segno.

### Generale, dieci correnti
1. Oggi parti dal primo passo, il resto si chiarisce strada facendo.
2. Una piccola scelta di oggi vale più di un grande piano rimandato.
3. Il ritmo giusto lo detti tu, non chi ti corre intorno.
4. Ascolta cosa ti chiede il corpo prima di riempire l'agenda.
5. Un imprevisto può rivelarsi la parte migliore della giornata.
6. Concediti una pausa vera, la lucidità torna nel silenzio.
7. Di' un sì convinto o un no chiaro, i forse oggi ti pesano.
8. La giornata premia chi resta presente, non chi anticipa tutto.
9. Rimetti al centro una cosa che conta, lascia cadere il rumore.
10. Fidati di ciò che senti, oggi la tua intuizione ci vede lungo.

### Amore, dieci correnti
1. Oggi la sincerità apre più porte di qualsiasi strategia.
2. Un gesto piccolo dice più di mille parole rimandate.
3. Chi ti sta vicino aspetta un tuo passo, fallo senza timore.
4. Lascia respirare l'altro, la giusta distanza avvicina.
5. Una conversazione sospesa oggi può ritrovare il suo filo.
6. Mostra il lato che di solito proteggi, verrà accolto.
7. Se sei in coppia, la tenerezza conta più della ragione.
8. Se [sei da solo|sei da sola|non hai qualcuno accanto], un incontro leggero merita attenzione.
9. Perdona una piccola ruvidezza, non tutto va discusso.
10. Ascolta davvero, prima di rispondere fai un respiro.

### Carriera, dieci correnti
1. Un'idea proposta al momento giusto oggi trova ascolto.
2. Concentra le forze su una cosa sola e portala a termine.
3. Chiedi ciò che ti spetta con calma, la fermezza paga.
4. Un collega può diventare un alleato, apri uno spiraglio.
5. Rimanda la mossa rischiosa, oggi la pazienza rende di più.
6. Il dettaglio che curi adesso ti evita un problema domani.
7. Fatti notare per come risolvi, non per quanto corri.
8. Una porta che sembrava chiusa merita un secondo bussare.
9. Metti ordine prima di aggiungere, la chiarezza sblocca.
10. Il tuo valore si vede nei fatti, lascia che parlino.

### Fortuna, dieci correnti
1. La sorte oggi premia chi osa un piccolo passo in più.
2. Tieni gli occhi aperti, un'occasione arriva travestita da caso.
3. Un incontro inatteso porta con sé una buona notizia.
4. Segui la coincidenza, oggi non è affatto casuale.
5. La fortuna gira dalla tua parte nel pomeriggio, [fatti trovare pronto|fatti trovare pronta|tieniti a disposizione].
6. Un no di ieri libera lo spazio per un sì migliore.
7. Rischia con misura, il cielo accompagna chi si fida.
8. Una parola detta al momento giusto ti apre una via.
9. Cerca il bello nelle piccole cose, oggi si moltiplica.
10. Un vecchio contatto può tornare utile, non stupirti.

## Le palette del colore del giorno, per segno

Il seme pesca uno di questi per la scheda Fortuna.

- Ariete: rosso, oro, corallo, cremisi
- Toro: verde salvia, terracotta, ottone, rosa antico
- Gemelli: giallo, azzurro, argento, lilla
- Cancro: argento, bianco perla, blu notte, glicine
- Leone: oro, ambra, arancio, porpora
- Vergine: verde bosco, beige, blu polvere, bronzo
- Bilancia: rosa cipria, verde acqua, oro rosa, celeste
- Scorpione: rosso scuro, nero, bordeaux, verde smeraldo
- Sagittario: viola, indaco, oro, turchese
- Capricorno: grigio pietra, marrone, verde scuro, antracite
- Acquario: turchese, blu elettrico, argento, blu ghiaccio
- Pesci: verde mare, lavanda, argento, blu oltremare

## Nota per il runtime

A C3, con Vertex e Gemini accesi, l'ancora resta il seme del significato e la corrente del giorno diventa il fallback. Gemini riceve segno, dominio, cielo reale del giorno e memoria della persona e restituisce una versione personalizzata nella voce di Medora, senza contraddire l'ancora del segno. Gli indicatori e il numero e il colore restano deterministici, così restano coerenti tra un'apertura e l'altra nello stesso giorno.
