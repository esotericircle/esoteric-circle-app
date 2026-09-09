# ORDINE DB, MANIFESTO

9 settembre 2026. La Meditazione che ricorda. Tredici voci.

**La sigla DB era libera**, verificato contando le sigle in `docs/ordini/`:
ottantaquattro manifesti, le lettere arrivavano fino a **CZ**, nessun file
cominciava per `ORDINE_D`.

---

## DB.01, LA LIBRERIA DEI RESPIRI. CHIUSA

Dieci pratiche pronte, **trentasei previste**, in
`lib/core/maestro/libreria_dei_respiri.dart`. Ogni voce porta il suo centro, la
sua durata dichiarata e la sua tradizione nominata.

**L'ampiezza si dichiara senza gonfiarla.** L'ordine chiede il numero in home
come fa la Z-App, e una guardia pretende due cose insieme: che le previste
siano **piu'** delle pronte, altrimenti non c'e' niente da promettere, e che
non siano **piu' di otto volte** quelle pronte, altrimenti e' un numero da
vetrina che chi arriva in fondo scopre vuoto.

**Nessuna voce nomina una condizione**, e non e' una promessa: e' una guardia
che legge tutti i testi della libreria, **trentadue**, contro un vocabolario
clinico dichiarato.

## DB.02, LE FONTI, E IL SOLFEGGIO DETTO PER QUELLO CHE E'. CHIUSA

Quattro tradizioni, ognuna con **autore e anno**, e una guardia che pretende
l'anno con un'espressione regolare: senza data non e' una fonte, e' un
riferimento vago.

| tradizione | fonte |
| --- | --- |
| suoni seme | Purnananda, Sat-Cakra-Nirupana, **1577**, tradotto da Woodroffe, **1919** |
| respiro di risonanza | Lehrer e Gevirtz, **2014** |
| solfeggio | Puleo e Horowitz, **1999** |
| binaurali | Dove, **1839** |

**Il solfeggio e' dichiarato come convenzione contemporanea**, e l'attribuzione
a Guido d'Arezzo si nomina **per dire che non regge**: tacerla lascerebbe chi
la conosce a crederla vera.

**Un difetto mio, la dodicesima volta della stessa famiglia**: la guardia che
vieta la parola *millenaria* cadeva sul mio stesso testo che diceva *"non una
tradizione millenaria"*. E' l'asserzione che pesca il proprio testo. Riscritta.

## DB.03, IL RESPIRO A SEI AL MINUTO. CHIUSA

Il riferimento era **quattro secondi**, un numero comodo per il disegno.
Adesso e' **cinque secondi per mezzo respiro**, cioe' sei atti al minuto, che
e' 0,1 hertz, la frequenza di risonanza del sistema cardiovascolare umano e
l'unica cosa in questa funzione con letteratura peer reviewed alle spalle.

**Non e' un ritmo da rispettare**, e il codice lo dichiara: chi respira col
dito tiene il suo, e l'app conosce il riferimento solo per la lettura finale.

## DB.04, IL LOTO CHE RESPIRA. CHIUSA, E SONO MISURE

La prima stesura era stata respinta. **I due difetti che questa chiude**: la
figura piccola con la cornice vuota attorno, e il bianco e nero.

**Le misure, tutte pretese da una guardia:**

| | preteso | misurato |
| --- | ---: | ---: |
| larghezza al culmine dell'inspiro | ≥ 85% | **88,0%** |
| larghezza al fondo dell'espiro | ≥ 50% | **54,0%** |
| corone | ≥ 4 | **4** |
| petali | crescenti | **7, 11, 17, 23** |
| colori distinti in una settimana | 7 | **7** |
| forme vive al culmine | < 200 | **125** |

**PERCHE' SETTE, UNDICI, DICIASSETTE E VENTITRE'.** Sette e' il numero dei
centri e sta al cuore, dove la traccia mostra quale centro e' spento. Gli altri
tre sono **numeri primi crescenti**: due corone con petali in rapporto intero
allineano i loro petali su raggi comuni e disegnano braccia, cioe' la stella a
punte da cui questo fiore deve stare lontano. **La guardia pretende che nessuna
corona sia multipla di un'altra.**

**L'ONDA, ed e' la cosa che rende il respiro leggibile.** A meta' inspiro il
cuore e' aperto al **50 per cento** e il bordo al **18**: il centro e' gia'
aperto mentre l'anello esterno sta ancora salendo. Senza questo il fiore e' una
figura che si ingrandisce, che e' esattamente cio' che era stato respinto.

**Il colore viene dal centro del giorno**, sette tinte distinte in una
settimana, ogni anello con la sua sfumatura e un filo di luce sul bordo. **La
corrispondenza arcobaleno e' dichiarata per quello che e'**: una convenzione
occidentale del Novecento, non una tradizione sanscrita, dove i colori sono
altri e il rosso sta in cima.

**Con Riduci Movimento** i petali non si animano, la parallasse si spegne, **il
colore resta**, e una guardia lo pretende.

## DB.05, LA SEQUENZA DI AURA. CHIUSA

Da due a quattro pratiche, un nome, e la sequenza e' sua.

**Perche' non quante si vuole**: una sequenza di dieci pratiche dura un'ora e
non la finisce nessuno, e la prima volta che si lascia a meta' smette di essere
un rito e diventa un elenco di cose non fatte.

**Ogni rifiuto dice perche'**: un rifiuto muto lascia chi compone a chiedersi
cosa ha sbagliato.

## DB.06, IL CAMMINO DEI SETTE CENTRI. PROPOSTA, NON MONTATA

La traccia esiste gia' dall'ordine CZ voce 10: il fiore si riempie **coi
centri, non con le sessioni**, e un centro mai respirato resta spento.

**I tre traguardi che l'ordine chiede di proporre, misurati contro il catalogo
dei traguardi del Loto**, che oggi ne conta **55**:

| proposta | condizione | collide? |
| --- | --- | --- |
| **I sette centri respirati almeno una volta** | `VarietaDelDettaglio('meditazione', 'centro', 7)` | **No.** Nessuno dei 55 guarda i centri. **E la condizione non va inventata**: il tipo esiste gia' e serve la varieta' del dettaglio. Manca una cosa sola, e sta fuori dal catalogo: la schermata manda il gesto **senza dettagli** (`meditation_screen.dart:244`), quindi il centro non arriva al diario. Una riga. |
| **Il decimo giorno in cui si respira** | `GestiCompiuti('meditazione', 10, inGiorniDiversi: true)` | **No, ma sta dentro una scala.** Il catalogo ha gia' `meditazione, 3`, `meditazione, 5` e `meditazione, 140`: **fra il cinque e il centoquaranta non c'e' niente**, e il dieci riempie il primo buco. Non collide, ma va messo dove la scala lo vuole. |
| **Tre giorni di seguito sullo stesso centro** | tre giorni consecutivi, stesso centro | **Impossibile, verificato nel codice.** `meditation_screen.dart:247` dichiara *"Il centro non si sceglie: e' quello acceso nel giorno in cui si respira"*, e la mappa e' `(weekday - 1) % 7`, cioe' biiettiva: **tre giorni consecutivi portano sempre tre centri diversi.** Il traguardo non si accenderebbe mai. |

**Il terzo si puo' salvare cambiandolo**: *"tre volte sullo stesso centro"*,
senza il vincolo dei giorni consecutivi, e' una condizione vera e misurabile,
e vuole almeno tre settimane. **Li scrive il fondatore**: qui sono proposti con
la condizione gia' misurata, come l'ordine chiede.

## DB.07, LA MEMORIA. CHIUSA

`MemoriaDelRespiro`, in `lib/core/maestro/memoria_del_respiro.dart`. Novanta
sessioni, sul telefono, sotto il prefisso `loto.` che la dimenticanza gia'
porta via.

**Il censimento che l'ordine chiede, fatto prima di scrivere una riga.** La
memoria dell'utente oggi e' `MaestroMemory` su Firestore, **una per Maestro**,
fatta di frasi che il modello distilla dalla conversazione, piu' `UserProfile`
e `NatalContext`, piu' le tracce locali delle singole funzioni.

**Perche' questa non e' una seconda memoria.** Il respiro produce **numeri**,
non frasi: scriverli dentro la sintesi di un Maestro vorrebbe dire farli
rileggere a ogni turno e farli sapere ad Aura e non a Medora. Il dato grezzo
resta dove nasce; **il riassunto** entra nel contesto, ed e' esattamente la
relazione che c'e' gia' fra la carta natale e `NatalContext`.

**Ricorda per ogni sessione**: centro, durata, compiuta o interrotta, ritmo
medio di inspiro ed espiro, ora del giorno, guidato o proprio.

**E l'andamento**: giorni di pratica, giorni di fila, centro piu' frequentato,
centri mai toccati, se le sessioni si allungano, l'ora in cui si torna.

**Ogni andamento ha una soglia sotto la quale non si dichiara**: la durata
vuole **sei** sessioni, l'ora ne vuole **tre** e pretende che una fascia si
stacchi dalle altre. Con meno non c'e' andamento, c'e' rumore.

## DB.08, I MAESTRI LEGGONO. CHIUSA

**Il contesto si compone in OTTO punti**, tutti in
`maestro_chat_controller.dart`, tutti con gli stessi quattro parametri.
L'ordine chiede di ricondurli a uno prima di aggiungere: **aggiungere un quinto
parametro avrebbe voluto dire toccarli tutti e otto**, e al primo dimenticato
due Maestri saprebbero cose diverse della stessa persona.

**Allora non si aggiunge un parametro.** Il riassunto entra **fra i fatti**,
che al modello arrivano gia' da tutte e otto le strade, e l'innesto e' in **un
punto solo**, dove la memoria viene caricata. Vale per tutti e tre i Maestri,
perche' quel controllore e' lo stesso per tutti.

**Il vincolo e' provato**: nessuna frase dichiara di osservare, e una guardia
cerca *"ti osservo"*, *"ho notato"*, *"sto monitorando"*, *"i tuoi dati"*.

## DB.09, IL WOW CHE NASCE DALLA MEMORIA. CHIUSA

Cinque osservazioni possibili, **una sola alla volta**, e **solo quando e'
vera**.

**L'ordine di scelta e' motivato: vince la piu' rara.** La prima volta su un
centro capita sette volte in una vita di pratica; la terza sera di fila capita
spesso. Dire la cosa comune quando ce n'era una rara e' sprecare l'unico
momento in cui l'app poteva stupire.

**Le soglie, e sono la difesa contro la frase falsa:**

| osservazione | nasce da |
| --- | --- |
| prima volta su un centro | almeno una sessione precedente |
| ritorno dopo l'assenza | **7 giorni** |
| la striscia | **3 sere**, perche' due capitano per caso |
| le sessioni si allungano | **6 sessioni** e uno scarto del **20%** |
| ti manca un centro solo | quando ne resta **uno** |

**Alla primissima sessione Aura non dice niente**, ed e' il caso piu'
importante: chi apre per la prima volta non ha passato, e qualunque cosa
sarebbe inventata.

**Una frase, mai due**, e una guardia conta i periodi: due osservazioni di fila
diventano un rapporto sulla persona, e il vincolo della voce 08 dice che il
Maestro deve sapere senza dichiarare di sapere.

## DB.10, LA CARD DEL RESPIRO. CHIUSA, E CHIUDE ANCHE CZ.09

La voce CZ.09 era ferma su lavoro non montato: la figura era calcolata e
provata, il disegno non esisteva. **Adesso esiste.**

**La figura e' una corona di raggi, uno per respiro**, e il raggio viene dalla
**quota del dentro**, cioe' da quanto pesa l'inspiro sul respiro intero.

**PERCHE' QUI LA PROMESSA REGGE E SULLA CARD DEL VISO NON REGGEVA.** Quella
diceva *"una costellazione su 104.976 possibili"*, e a **382 utenti** era piu'
probabile che due card fossero identiche che il contrario: nasceva da
**caselle**. Questa nasce da numeri in virgola mobile misurati al millisecondo.
**La differenza non e' di grado, e' di natura.** Misurato: due serie che
differiscono di un centesimo su un solo respiro danno figure distanti
**0,001667**, e la stessa serie da' sempre la stessa figura.

**Chi ha usato il ritmo guidato lo legge sulla card**, dichiarato: sarebbe la
figura dell'app e non la sua, e spacciarla per sua sarebbe la prima bugia di
questa funzione.

**Passa dal punto unico della condivisione**, e una guardia pretende che non
conosca ne' rete ne' storage.

## DB.11, IL CONFINE. CHIUSO, COL VOCABOLARIO DICHIARATO

**Il vocabolario, quattro famiglie**, come l'ordine chiede di dichiarare:

- **promesse di guarigione**: guarisc, guarigione, guarire, curare, cura del,
  terapia, terapeutic, risana, risanare, sana il, rimedio
- **condizioni e sintomi**: malattia, malattie, sintomo, sintomi, disturbo,
  disturbi, diagnosi, patologia, infiammazion, insonnia, depression, ansia
  patologica, emicrania, dolore cronico
- **parti del corpo da trattare**: fegato, reni, intestino, tiroide, pressione
  sanguigna, sistema immunitario, ossa, articolazion
- **effetti fisiologici promessi**: ripara il dna, riparazione del dna,
  abbassa la pressione, toglie il dolore, riduce il dolore, effetto sul corpo,
  battito cardiaco scende, rallenta il battito

**La guardia dimostra l'assenza in tutti i punti**, come la Regola H pretende:
scopre i file della funzione invece di elencarli, e dichiara quanti ne ha
guardati. Misurato: **19 file, 203 righe di testo, zero sconfinamenti.**

**E il vocabolario e' provato a sua volta**: quattro frasi finte che promettono
devono essere riconosciute, altrimenti la guardia sarebbe verde per non sapere
cosa cercare.

**Si guardano le stringhe, non i commenti.** In un commento la parola
*guarigione* compare proprio per spiegare che non si promette.

## DB.12, LO SPAZIO PER LE MIE IDEE

### Uno: cosa puo' fare questa memoria che non e' stato chiesto

**L'ora in cui torni e' gia' nella memoria, e l'app non la usa.** Chi medita
sempre alle 22:30 e chi medita alle 7 sono due persone diverse, e oggi ricevono
la stessa app. Con quel dato, **e senza chiedere niente a nessuno**, l'avviso
del Soffio potrebbe spostarsi da solo sull'ora in cui quella persona torna
davvero, invece di stare dove sta per tutti. E' possibile oggi: `oraPiuFrequente`
esiste gia' e ha la sua soglia di tre sessioni.

**La sessione interrotta e' un dato che nessuno guarda.** La memoria sa se una
sessione e' stata lasciata a meta' e **a che punto**. Chi interrompe sempre
dopo due minuti non ha bisogno di una pratica da dieci: **ha bisogno che Aura
gliene proponga una da tre.** E' l'unico caso in cui l'app puo' accorgersi che
sta chiedendo troppo, invece di aspettare che la persona smetta.

### Due: dove il gesto del dito si rompera' davvero

**Si rompe quando la persona chiude gli occhi**, ed e' proprio quello che le
si chiede di fare. Un dito sullo schermo a occhi chiusi scivola, e uno scivolo
oggi vale come un dito alzato: il respiro risulta finito quando non lo e'.

**Come lo farei io**: il dito alzato conta come espiro solo dopo **una soglia
di tempo**, duecento millisecondi, e sotto quella e' rumore. E' la stessa cosa
che si fa con i pulsanti per il tremolio del contatto, e costa una riga.

**Si rompe una seconda volta con la telefonata che arriva.** L'app va in
secondo piano col dito giu', e al ritorno il respiro e' aperto da tre minuti.
**Un respiro piu' lungo di sessanta secondi non e' un respiro**: va chiuso e
scartato, invece di finire nella figura e nella media.

**E si rompe una terza volta a mani occupate**, che e' il caso di chi medita
sdraiato. Li' il dito non e' la via giusta e nessuna soglia lo salva: servirebbe
poter dire *"respiro da solo"* e lasciare che il fiore segua il riferimento.
Quella porta oggi non c'e'.

### Tre: quale altra funzione paga due volte

**Il Sigillo del Sogno.** E' il rito che chiude la giornata e chiede cosa
resta: sapere che quella persona ha respirato stasera, e su quale centro,
gli da' la sola cosa che oggi non ha, **un fatto della giornata** invece di una
domanda generica. E la parola del giorno e il centro del giorno sono due fili
che si incontrano li' senza che nessuno debba costruire niente.

**E la chat dei Maestri**, che paga subito: il riassunto ci entra da oggi, e
Caligo che propone un rito a chi non respira da tre settimane parla a una
persona diversa da chi respira ogni sera.

## DB.13, LA PROVA VISIVA, E HA TROVATO UN DIFETTO CHE NESSUNA PROVA VEDEVA

Fatta sul dispositivo 767f596c col metodo a due passi. **Ed e' servita**: il
loto a riposo occupava il **18,1 per cento** della larghezza dello schermo
dentro una scena quasi vuota, cioe' **esattamente cio' che la voce DB.04
doveva chiudere**, mentre la sua guardia dichiarava 54 ed era verde.

**PERCHE' LA GUARDIA ERA VERDE SU UNA SCENA ROTTA.** C'erano **due verita'
sulla stessa larghezza**. `raggioDellaCorona` prometteva la quota, il pittore
disegnava il petalo lungo `raggio * (0,34 + 0,66 * apertura)`, quindi da chiuso
la punta si fermava a **un terzo** del raggio dichiarato, e la guardia
interrogava **la formula** invece della **forma**. E' la famiglia "misurare il
pezzo sano accanto al pezzo rotto", e stavolta l'ha trovata il telefono.

**LA GRANDEZZA MISURATA E' CAMBIATA, NON LA SOGLIA.** Adesso la guardia
dipinge il loto su una tela vera e conta i pixel accesi.

| | prima | adesso |
| --- | ---: | ---: |
| misurato sul telefono, a riposo | **18,1%** | da riverificare a video |
| misurato dalla guardia, a riposo | 54,0% dichiarati | **53,8% dipinti** |
| misurato dalla guardia, al culmine | 88,0% dichiarati | **88,5% dipinti** |

**La prova che la misura nuova e' quella giusta**: col difetto ancora in
piedi, la guardia riscritta ha misurato **19,0 per cento** in laboratorio
contro i **18,1** letti sui pixel della cattura del telefono. Un punto di
scarto fra il banco e la realta'.

**La riparazione e' una riga**: la punta del petalo arriva al raggio della sua
corona. Il respiro resta leggibile lo stesso, perche' il raggio cresce da solo
da 0,54 a 0,88 del lato, e i petali passano da sottili a pieni.

### E IL SECONDO GIRO A VIDEO HA TROVATO UN SECONDO DIFETTO

Rimesso il fiore sul telefono, occupava il **35,0 per cento dello schermo**
pur occupando il 53,8 del suo riquadro. **Il riquadro non era lo schermo**: il
loto stava in un `Expanded` sopra la colonna di testo e prendeva solo l'altezza
che avanzava, 710 punti su uno schermo largo 1080.

**La guardia era di nuovo verde e la scena era di nuovo quella respinta**,
perche' la voce 04 nomina *"la larghezza dello schermo"* e la guardia misurava
la larghezza del riquadro.

Adesso la guardia **monta la scena vera** in una finestra dove testo e loto si
contendono l'altezza, 360 per 700, e misura la quota sullo schermo. Rossa a
**61,6 per cento** col difetto in piedi, verde a **88,0** dopo. La riparazione:
il riquadro e' un quadrato largo quanto lo schermo e il testo scorre sotto,
cosi' **la misura non dipende piu' da quanto testo c'e'**.

**Riverificato sul telefono**: a riposo il fiore misura **54,1 per cento dello
schermo** contro i 53,8 che la guardia dichiara. Tre decimi di scarto fra il
banco e il vetro.

### IL GESTO DEL DITO: provato in laboratorio, non provabile con adb

Tenendo il dito premuto sul telefono con `adb shell input motionevent DOWN`,
il fiore **non si apriva**: 584 pixel a riposo e 584 col dito giu'. **Non e'
una prova che il gesto sia rotto**: `input motionevent` inietta l'evento e il
processo che l'ha iniettato esce, quindi il dito non resta giu'.

**Allora la domanda si e' spostata dove si puo' rispondere.** Una prova nuova
monta la scena due volte, con lo stesso tempo trascorso, una col dito giu' e
una senza: **senza dito l'apertura e' 0,908, col dito 0,004.** Il dito comanda
il fiore e non il respiro dell'app.

**La prima stesura di quella prova era cieca, e si e' visto subito.** Chiedeva
soltanto che l'apertura fosse maggiore di zero: innestato il difetto, cioe'
ignorando il dito, restava **verde con 0,908**, perche' il respiro dell'app da
solo supera qualunque soglia positiva. Misurava *"qualcosa si muove"* invece di
*"si muove per il dito"*. **La grandezza misurata e' diventata un confronto**,
e cosi' il difetto la fa cadere.

**Resta da guardare con un dito vero**, e quello puo' farlo solo il fondatore.

### TRE PROVE HANNO SMESSO DI COLPIRE, e non era colpa loro

Con la pagina che scorre, tre prove che toccavano un punto sotto la piega
cadevano su una finestra da **800 per 600**, che non e' nessun telefono. Fra
queste `il_suono_si_ferma_test.dart`, che sarebbe tornata a chiudere una
schermata muta: **esattamente il difetto che quella prova aveva gia' avuto una
volta.** Pinnata la finestra a 390 per 844 e portati i bersagli sotto gli
occhi prima di toccarli.

---

VOCI_TOTALI: 13
VOCI_CHIUSE: 12
VOCI_PROPOSTE_E_NON_MONTATE: 1, la DB.06 come l'ordine chiede
VOCI_APERTE: 0
GUARDIE_NUOVE: 7
PROVE_NUOVE_DENTRO_GUARDIE_ESISTENTI: 2, la scena vera e il dito
GUARDIE_RISCRITTE_PERCHE_MISURAVANO_LA_COSA_SBAGLIATA: 1, il loto
DIFETTI_MIEI_TROVATI_DALLE_GUARDIE: 6, cinque virgole seguite da "e", un accento perso
DIFETTI_TROVATI_A_VIDEO_E_NON_DALLE_PROVE: 2, il loto al 18,1 per cento e il riquadro al 35,0
GUARDIE_NATE_CIECHE_E_RIFATTE_SUBITO: 1, il dito verde con 0,908
RESTA_DA_GUARDARE_CON_UN_DITO_VERO: il gesto del respiro, non provabile con adb
VOCABOLARIO_CLINICO: 4 famiglie, 48 parole
FILE_SORVEGLIATI_DAL_CONFINE: 19
TRAGUARDI_DEL_CATALOGO_MISURATI: 165
VERIFICA_A_VIDEO: 767f596c
