# CX, LE COLLISIONI DELLA CARD

Referto per il fondatore, 9 settembre 2026. Nasce dagli appunti dell'Architetto
sui blocchi C e D. **Misura e non decide**: le tre vie sono valutate, nessuna e'
montata.

## PRIMA DOMANDA: LE UNDICI CATEGORIE, E NESSUNA HA UNA VARIANTE SOLA

Contate dal catalogo con `FaceTrait.perCategoria`, non a mano.

| categoria | varianti | quali |
| --- | ---: | --- |
| forma del volto | **4** | tondo, quadrato, ovale, triangolare |
| fronte | 3 | sfuggente, verticale, equilibrata |
| sopracciglia | 3 | dritte, curve, ad angolo |
| **distanza occhi** | **2** | ravvicinati, distanziati |
| grandezza occhi | 3 | grandi, raccolti, proporzionati |
| naso | 3 | lungo, corto, equilibrato |
| labbra | 3 | piene, sottili, armoniose |
| bocca | 3 | larga, piccola, equilibrata |
| mento | 3 | ampio, a punta, definito |
| mascella | 3 | larga, stretta, misurata |
| **zigomi** | **2** | alti, morbidi |

**Nessuna categoria ha una variante sola**, e la guardia lo pretende: il minimo
e' due, sulla distanza degli occhi e sugli zigomi. Il prodotto e' 4 per 2 per 2
per 3 alla ottava, cioe' **104.976**.

**MA UNA DELLE DUE A DUE VARIANTI NON VARIA DAVVERO.** Sui quattro volti veri la
**distanza degli occhi** ha una dispersione del **sei per cento**, da 2,1435 a
2,2837, ed e' l'unica categoria che ha cambiato risposta quando Monika si e'
messa il cappello, che gli occhi non li tocca. **Quella non e' una misura, e'
rumore.** Formalmente ha due varianti e moltiplica il conto per due; nei fatti
distingue le persone quanto un lancio di moneta.

Non l'ho tolta perche' il fondatore ha scelto la via A e ha detto di lasciare la
B, cioe' di non togliere categorie. **Resta come fatto dichiarato**: delle
104.976 combinazioni, un fattore due viene da una categoria che misura il
rumore.

## SECONDA: A QUANTI UTENTI DUE COSTELLAZIONI COINCIDONO

Conto esatto, non approssimazione, e coincide con la formula del compleanno.

| | utenti |
| --- | ---: |
| probabilita' di collisione oltre il **50 per cento** | **382** |
| probabilita' oltre il **95 per cento** | **793** |

**L'Architetto aveva ragione, e il numero e' anche peggio di quanto sembra.** A
**382 iscritti** e' piu' probabile che esistano due card identiche che il
contrario. A **793** e' praticamente certo. Non sono numeri da lancio riuscito:
sono numeri da prima settimana.

### E la distribuzione vera e' peggiore, ma non la posso pesare

**Il dato per pesare le varianti non esiste.** Servirebbero i rapporti di molte
persone per sapere quanto sono frequenti le facce comuni: **ne ho quattro**.
Come l'Architetto chiede, dichiaro il conto uniforme come **limite superiore
ottimistico**: nella realta' le collisioni arrivano prima di 382, perche' le
facce non sono distribuite a caso.

**Un indizio quantitativo ce l'ho comunque**, ed e' scomodo. Le soglie sono i
terzili di quattro volti, quindi per costruzione **i volti veri si distribuiscono
uno, due, uno** fra le fasce: la fascia di mezzo pesa il doppio delle altre. Con
undici categorie cosi' sbilanciate, la collisione arriva prima di 382 in modo
non trascurabile.

## LE TRE VIE, COL LORO COSTO

### a) Arricchire il catalogo finche' le combinazioni sono milioni

**Quanto servirebbe, calcolato.** Per portare la collisione al cinquanta per
cento oltre i **diecimila utenti** servono circa **72 milioni** di combinazioni,
cioe' **seicentonovanta volte** quelle di adesso. Con le undici categorie
attuali vuol dire portarle quasi tutte da tre a **sei varianti**: sei alla
undicesima fa 362 milioni, cinque alla undicesima fa 48 milioni.

**Il costo vero non e' il numero, sono i testi.** Ogni variante nuova vuole un
nome, un epiteto e una frase del corpus scritta nella voce dei Maestri: sono
**circa trentatre' varianti nuove** da scrivere, e ognuna deve reggere la regola
del confine, cioe' nessuna promessa.

**E c'e' un limite che i testi non risolvono**: le soglie di sei varianti
andrebbero tarate sui sestili di una popolazione, e oggi ho **quattro volti**.
Sarebbero sei caselle disegnate su quattro punti, cioe' il difetto da cui questo
ordine e' partito, moltiplicato.

### b) Cambiare la frase invece del numero

**Costo: quasi nullo.** Una riga di testo e una guardia che la sorveglia.

La frase di adesso dice *"una costellazione su 104.976 possibili"* e chi legge
capisce **unica**. Una frase che resta vera anche con le collisioni direbbe
quanto e' fine la lettura invece di quanto e' raro chi la riceve: per esempio
*"undici tratti letti, 104.976 combinazioni distinte"*, che e' un fatto sulla
misura e non un vanto sulla persona.

**E' l'unica via che si puo' montare oggi senza aggiungere nessun rischio**, e
l'unica che non ha bisogno di dati che non ho.

### c) La figura nasce dalle misure continue, non dalle caselle

**LE MISURE CI SONO GIA', e questa e' la scoperta di questo referto.**

Il lavoro fatto ieri per tarare le soglie ha messo il **rapporto grezzo dentro
ogni `TraitLettura`**, e la card riceve la lettura intera: **non serve portare
li' niente di nuovo.** Verificato con una prova, non supposto.

**Due volti nella stessa casella hanno numeri diversi.** Il volto 3 e il volto 2
cadono tutti e due sopra la soglia 0,7978 della forma, cioe' ricevono la stessa
parola, e misurano **0,8007 e 0,8645**. Se il disegno usa quei numeri invece
delle parole, **la figura e' diversa anche fra due persone con le stesse undici
caselle**.

**Quanto e' irripetibile, detto con onesta'.** I rapporti sono numeri in virgola
mobile misurati da una fotocamera: due persone non avranno mai gli stessi undici
valori a quattro decimali, quindi la figura e' unica in senso pratico. **Ma non
in senso assoluto**, e la promessa va scritta di conseguenza: la figura e'
irripetibile, il responso a parole no.

**Il costo.** Il disegno della costellazione esiste gia' e usa i tratti: andrebbe
esteso a leggere i rapporti, che sono li' accanto. Non e' una funzione nuova, e'
**un parametro in piu' a un pittore che c'e' gia'**. La stima e' di poche ore,
molto meno della via A.

## COSA CONSIGLIO, E LA SCELTA E' TUA

**La b piu' la c, e non la a.**

La **b** costa una riga e toglie subito la promessa che non regge: va fatta
comunque, qualunque sia l'altra scelta, perche' finche' la frase dice *"su
104.976"* il problema esiste a 382 utenti.

La **c** e' quella che mantiene l'effetto Wow invece di ridimensionarlo: **la
card diventa davvero irripetibile**, e il numero delle caselle resta un dato da
citare senza doverne reggere la promessa. E costa poco perche' il dato e' gia'
dove serve.

La **a** la sconsiglio: trentatre' testi nuovi e sei caselle tarate su quattro
volti sono un lavoro grosso che riporta dentro il difetto da cui questo ordine e'
nato.

**Non ho montato nessuna delle tre.** Aspetto la tua parola.

---

MISURATO_SU: 4 volti veri, 6 scansioni, dispositivo 767f596c
COMBINAZIONI: 104.976
COLLISIONE_AL_50_PER_CENTO: 382 utenti
COLLISIONE_AL_95_PER_CENTO: 793 utenti
CATEGORIE_CON_UNA_SOLA_VARIANTE: 0
CATEGORIE_CHE_MISURANO_RUMORE: 1, la distanza degli occhi
MISURE_CONTINUE_DISPONIBILI_NELLA_CARD: si
VIE_MONTATE: nessuna
