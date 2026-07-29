# ESITO dell'ORDINE DELLE SEI CREAZIONI

## Dichiarazione, scritta prima di toccare il codice

Otto voci, nessuna torna vuota. Ho guardato il codice di ciascuna prima di
stimare, ed ecco cosa mi aspetto.

**Versione piena, senza riserve** (cinque voci):

- **C1, il Sigillo.** La schermata usa `_StepBody`, cioe' l'impalcatura comune
  che tiene il visivo in una scatola in alto: e' quella scatola a spingere il
  sigillo in cima e a lasciare mezzo schermo vuoto sotto. Non e' un difetto di
  posizionamento, e' che il sigillo non dovrebbe stare dentro quell'impalcatura.
  Gli serve un passo tutto suo.
- **C5, l'orologio.** Un quadrante con due lancette e un `AnimationController`
  che interpola l'angolo. La sola insidia e' il percorso piu' breve, che si
  risolve normalizzando la differenza fra meno mezzo giro e piu' mezzo giro.
- **C6, l'anteprima del tono.** Le opzioni esistono gia' (`CourtesyForm`), le
  frasi sono redazione, mentre la scrittura progressiva e' una sottostringa che
  cresce.
- **C7, le immagini tagliate.** La causa e' una sola e l'ho gia' vista:
  `_Miniatura` e' 44 per 44 con `BoxFit.cover`, che riempie ritagliando. Va
  cambiata la proporzione e il criterio di adattamento.
- **C8, le tre verifiche.** Sono sguardi, piu' una anteprima nuova della carta
  natale piena da aggiungere al corredo.

**A rischio di versione semplice** (tre voci), in quest'ordine di rischio
crescente:

- **C2, i due trionfi.** L'Animale ha gia' `AnimalReveal`, quindi la sua
  schermata parte da qualcosa. Gli Angeli no: la loro scena in sequenza e' da
  costruire da zero, insieme all'innesto di tutte e due nel percorso di
  onboarding, che oggi non le prevede.
- **C3, il carosello.** E' fisica di trascinamento con inerzia su una
  schermata da 1192 righe, ed e' la voce che quattro ordini hanno rimandato.
- **C4, il planisfero.** Richiede una sagoma del mondo dentro l'app: non
  esiste un asset e non si scarica nulla a runtime, quindi va incorporata una
  maschera terra e mare abbastanza piccola da non pesare, abbastanza fedele da
  far riconoscere i continenti. Se la sagoma non regge, la versione semplice
  resta un campo di punti col luogo acceso nel punto giusto.

**La versione semplice, se serve, la prendera' l'ultima della lista**, come
l'ordine impone: prima C4, poi C3, mai C1.

Il consuntivo di questa stima sta in fondo, dopo gli otto esiti.

## Stato voce per voce

Otto voci, otto esiti. Nessuna e' rimasta chiusa in un cassetto.

### C1, il Sigillo al centro col trionfo: PIENA

**Perche' in tre build non era cambiato niente.** Il Sigillo viveva dentro
`_StepBody`, l'impalcatura comune dei passi, che tiene il visivo in una
scatola alta 190 in cima e sotto ci mette titolo, sottotitolo e contenuto. Non
era un difetto di posizionamento da correggere con qualche pixel: e' che il
Sigillo non compila niente, e' un gesto, quindi gli serviva una schermata sua. Fino
a che restava dentro quella scatola, nessuna correzione lo avrebbe portato al
centro.

**Cosa c'e' adesso.** Il Sigillo sta sul centro geometrico vero. Il testo e'
"Posa il dito sul numero al centro", parola per parola. Premendo, un anello si
riempie attorno al bordo con la testa luminosa che corre; mollando torna
indietro piu' in fretta di quanto avanza, perche' mollare non deve costare
quanto premere. A tenuta compiuta parte il trionfo: un'onda che si allarga,
dodici raggi come i segni, ventisei particelle deterministiche, col
passaggio che avviene alla FINE, non all'inizio, altrimenti il trionfo non lo
vedrebbe nessuno. Con Riduci Movimento diventa una dissolvenza.

**Otto test, con la prova del rosso.** Rimettendo il Sigillo in alto, le tre
altezze provate cadono con scarti dal centro di 298, 196 e 342 px. Il criterio
delle fasce vuote ha trovato per primo un difetto mio: avevo centrato il
Sigillo lasciando 231 px vuoti sopra, cioe' il 27 per cento, che era lo stesso
difetto ribaltato. Il titolo e' sceso, mentre sotto il gesto e' comparsa la firma
di cio' che si sta sigillando.

### C2, i due trionfi: PIENA

**Perche' Mauro non le trovava.** Non esistevano nel percorso. L'Animale e gli
Angeli comparivano gia' calcolati dentro una tessera della carta natale, come
campi di un modulo: nessuno li rivelava mai.

**L'Animale Guida** ha ora la sua schermata: la nebbia si dirada (la metafora
di Caligo, che esisteva gia' ed e' qui messa al servizio di una
rivelazione), il totem emerge intero, mentre il nome arriva DOPO che l'animale si e'
visto, perche' prima si riconosce e poi si impara come si chiama.

**I tre Angeli** arrivano uno alla volta, ciascuno con la sua luce che si
accende, la sua carta e il suo ruolo (Custode, Del cuore, Dell'intelletto).
Mai tutti e tre insieme: tre luci che si accendono insieme sono un'immagine,
tre luci in fila sono un racconto, mentre i tre non hanno lo stesso ruolo.

**Dove stanno nel percorso.** Fra la carta natale e la risonanza: a quel punto
la persona ha appena visto il proprio cielo, quindi sa di che si parla, mentre non
ha ancora incontrato il Maestro, quindi i compagni arrivano prima della guida.

La tessera "I tuoi Angeli" era gia' cliccabile e gia' apriva la schermata
dedicata col testo del corpus: fatto in un ordine precedente, verificato qui.

### C3, il carosello che ruota: PIENA

**La causa.** Tre riquadri a posizione fissa (sinistra, destra, centro)
assegnati per indice. Cambiando il Maestro al centro, i tre cambiavano posto
nello stesso fotogramma: non era una rotazione, era un taglio di montaggio.

**Cosa c'e' adesso.** Ognuno ha un ANGOLO sul cerchio, mentre cio' che si anima e'
l'angolo. Da un angolo continuo discendono da soli la posizione orizzontale,
la scala, l'altezza sulla scena, la penombra e perfino l'ordine di
sovrapposizione: nessuno decide piu' a mano chi va a sinistra, lo decide il
seno dell'angolo. Il dito trascina e il cerchio segue; al rilascio il lancio
sposta il bersaglio di al piu' un posto, poi ci si assesta. La strada e' sempre
la piu' corta, anche passando dal terzo posto al primo.

Due accorgimenti che fanno la differenza fra ruotare e sparire: le chiavi
seguono il RUOLO visivo (chi sta davanti si chiama sempre allo stesso modo),
mentre ogni busto porta la propria chiave d'identita', altrimenti Flutter lo
ricostruirebbe da capo a ogni fotogramma invece di spostarlo.

**Tre test, con la prova del rosso.** Togliendo l'animazione, Medora salta di
250 px in un fotogramma solo. La prima prova del rosso che avevo fatto non era
valida, perche' la modifica non era stata applicata al file: me ne sono
accorto, quindi l'ho rifatta.

### C4, il planisfero a punti: PIENA

**Il problema da risolvere prima di disegnare.** Serviva una sagoma del mondo
dentro l'app: nessun asset esiste e non si scarica niente a runtime. Il primo
tentativo e' stato usare le 11.546 citta' dell'elenco offline come
campionamento della terra emersa, senza riuscirci: 675 celle su 4608,
perche' le citta' stanno dove sta la gente e lasciano vuoti Sahara, Siberia e
Australia interna.

**La soluzione.** Diciassette poligoni in gradi veri di latitudine e
longitudine, scritti nel codice; i punti nascono dove una griglia regolare
cade dentro un poligono. Contorni grossolani, dichiarati tali nel commento:
servono a far riconoscere il mondo con la coda dell'occhio, non a misurare
confini. La proiezione e' equirettangolare, la piu' semplice, che e' anche
quella che permette di accendere la stella nel punto giusto con una formula
diretta.

**Guardato, non dedotto.** I continenti si riconoscono. Scegliendo Roma, la
stella con alone e quattro raggi si accende sull'Italia. I punti pulsano pochi
per volta, sfasati in modo deterministico, mentre la scena segue il giroscopio come
il resto dell'app.

### C5, l'orologio dinamico: PIENA

Prima c'era un orizzonte disegnato, bello ma muto: girando i selettori non
cambiava nulla, quindi la scelta non aveva riscontro.

Ora la lancetta delle ore avanza in proporzione ai minuti, come su un
quadrante vero: alle sette e mezza sta fra il sette e l'otto. La corsa sceglie
sempre la strada piu' corta, quindi da undici a una gira in avanti di due ore.
Cambiando scelta a meta' corsa riparte da dove si trova adesso, non dal
vecchio bersaglio: e' questo che distingue un movimento da uno scatto. Con
Riduci Movimento le lancette arrivano senza percorso.

Sette test, compreso quello che prova tutte le 144 coppie di ore e verifica
che nessuna corsa superi mezzo giro.

### C6, l'anteprima del tono: PIENA

I toni sono quelli che esistono davvero nel codice, `CourtesyForm`, non
inventati. Ogni tono ha la sua frase, con frasi che dicono LA STESSA COSA in modi
diversi: e' l'unico modo perche' il confronto sia onesto, perche' se
cambiassero anche di contenuto chi sceglie sceglierebbe il contenuto e non il
tono. La frase si scrive lettera per lettera col cursore, poi cambiando scelta
si riscrive da capo. Senza scelta compare un invito, non una frase finta.

Sei test, compreso quello che vieta le promesse di esito: niente guarigioni,
denaro o eventi garantiti, che e' una regola della casa e non un gusto.

### C7, le immagini tagliate: PIENA

**Una causa sola per due difetti.** `_Miniatura` era un riquadro quadrato da
44 px con adattamento al riempimento: quel modo riempie ritagliando cio' che
avanza, quindi un totem verticale ci perdeva la testa.

Adesso l'adattamento e' contenuto, l'animale sta in 64 px (in 44 sarebbe
diventato un francobollo), mentre le carte degli Angeli sono verticali in
proporzione due terzi, che e' quella della loro arte.

**Guardato sull'anteprima ingrandita:** la volpe ha coda e zampe, le tre carte
d'angelo hanno la cornice intera su tutti e quattro i lati, i nomi si leggono
sotto ciascuna. Nessuna delle quattro immagini perde un bordo.

### C8, le tre verifiche mai fatte: PIENA

**L'avatar e la bolla nella Home.** Guardate sull'anteprima rigenerata dopo il
carosello nuovo: gli avatar laterali non toccano ne' "LUNA NUOVA" ne' la riga
personale sotto, mentre la bolla "Entra nel Dominio di Medora" resta staccata da
Medora. Nessuna sovrapposizione. Non ho scritto nessun test: come dice
l'ordine, misurare il rettangolo del widget non prova niente su un elemento
che sfora, mentre un test per immagine non l'ho costruito.

**Le linee d'aspetto, col buco permanente.** Ho aggiunto al corredo delle
anteprime una CARTA NATALE PIENA: dieci pianeti, angoli, case e aspetti,
costruita a mano nel test: la ragione e' che la carta d'anteprima e' sempre stata quella
essenziale, senza pianeti, quindi quella ruota non si e' mai potuta guardare.

Alla prima cattura le linee NON si vedevano. La causa non era il prodotto, era
la mia cattura: la ruota entra in 3,6 secondi e gli aspetti compaiono
nell'ultimo quinto, mentre io fotografavo dopo 2 secondi. Fotografare troppo
presto e concludere che una cosa non c'e' e' lo stesso errore di dedurre dal
codice, solo travestito da verifica.

Catturando dopo l'ingresso, **le linee si vedono**: azzurre gli aspetti
armonici, rosse quelli di tensione, spesse abbastanza da leggersi. Lo spessore
scritto nell'ordine precedente e mai visto e' ora visto.

## Stima contro consegnato

Avevo dichiarato piene senza riserve C1, C5, C6, C7 e C8, poi a rischio di
versione semplice C2, C3 e C4, in quest'ordine di rischio crescente.

**Consegnate tutte e otto in versione piena.** Nessuna e' scesa alla versione
semplice, nemmeno C4, che era la piu' a rischio: la sagoma del mondo regge, i
punti pulsano, il giroscopio e' collegato.

**Dove la stima ha sbagliato, in meglio.** Avevo sopravvalutato C2, perche'
l'Animale aveva gia' la sua rivelazione con la nebbia, quindi ne restava da
costruire solo meta'. E avevo sopravvalutato C3: la fisica del trascinamento
faceva paura da fuori, ma il difetto vero era concettuale, cioe' tre posizioni
assegnate per indice; una volta sostituite con un angolo continuo tutto il
resto (scala, penombra, ordine di sovrapposizione) e' venuto da se'. Le cose
che quattro ordini avevano rimandato erano piu' piccole della loro fama: erano
rimaste indietro perche' in un elenco misto la correzione vince sempre, non
perche' fossero difficili.

## Segnalazioni, come chiede l'ordine: cose viste e NON toccate

- I glifi dei pianeti nella ruota natale escono come quadratini vuoti nelle
  anteprime. E' il font dei simboli astronomici che non viene caricato nella
  cattura headless, non un difetto della schermata: sul dispositivo vero i
  glifi ci sono. Va confermato guardando la build.
- La sfera del soffio nella rivelazione del Maestro resta il segnaposto in
  attesa dell'asset, voce P55: non toccata, come l'ordine vieta.
- Esistono DUE classi `BirthPlace`, una in `core/astro` e una in
  `core/identity`, con campi diversi, nomi identici. Non e' un difetto
  visibile e non l'ho toccata, ma e' una trappola: chi scrive un test le
  confonde, come e' successo a me.
