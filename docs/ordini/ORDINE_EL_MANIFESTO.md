# ORDINE EL, L'ALBA SI APRE ALZANDO IL SOLE

**Sigla:** EL, riverificata sul ramo il 24 settembre 2026 prima di cominciare:
in `docs/ordini` non c'era nessun `ORDINE_EL_*` e in `test/` nessuna
`ordine_el_guard`. **Data dell'ordine:** 25 settembre 2026; il lavoro e' del
24 settembre 2026 sull'orologio della macchina, come per l'ordine EK.
**Ramo:** `claude/esoteric-circle-master-order-e798aj`. Il fondatore ha
chiesto di metterlo in coda all'ordine EK e di consegnare, finito tutto, una
build nuova su App Tester: la stima dichiarata prima di cominciare era di
circa sei ore per EK, EL e consegna, e il fondatore ha scelto *"Tutto, una
build"*.

**La seconda voce l'ha aggiunta il fondatore in chat**, la sera del 24
settembre 2026, mentre l'ordine si chiudeva: il Taglia dell'Arcano dell'Alba
che ricompone il mazzo, lo taglia e ristende le carte. Sta nella stessa build.

VOCI_TOTALI: 2
VOCI_CHIUSE: 2
VOCI_APERTE: 0

Le prove stanno in `docs/collaudo/EL/`.

---

## I FATTI VERIFICATI SUL RAMO, E GLI SCARTI FRA L'ORDINE E IL RAMO

### 1. Dove viveva il vecchio ingresso

Il gesto del sole e' nato col commit `bf5661e9` del 15 luglio 2026, *"Rito
dell'Alba completo: gesto del sollevamento, dono del giorno, continuita'"*.
L'ultima versione viva sta nel commit `8a19e6b8`, file
`lib/features/rituals/dawn_rite_screen.dart`, 946 righe:

| pezzo | righe nel commit `8a19e6b8` |
| --- | --- |
| il trascinamento e il rilascio, `_onDragUpdate` e `_onDragEnd` | 252-269 |
| il ripiego tattile e il compimento, `_tapComplete`, `_complete`, `_animateProgressTo` | 271-293 |
| la scena col suo gesto, `GestureDetector` con `onVerticalDragUpdate` | 571-621 |
| l'invito *"Trascina in alto, oppure tocca"*, `_LiftPrompt` | 727-789 |
| il motore del sorgere, `_DawnScenePainter` | 804-946 |

I tre livelli della scena, `assets/ritual_backgrounds/dawn_sky_night.png`,
`dawn_sky_day.png` e `dawn_sun.png`, **erano ancora nel pacchetto**, ma
nessun file di `lib` li usava.

### 2. Chi l'ha tolto

Il commit `47b3c2be` del 17 settembre 2026, ordine DT, *"l'Arcano dell'Alba
nell'app, da cinque doni a quattro"*, ha cancellato
`dawn_rite_screen.dart` intero, e con lui il gesto. Le voci dell'ordine DT
scritte sul ramo dicono: DT.01 *"via il Rito dell'Alba e l'Arcano del Giorno
come voci autonome"*, DT.02 *"l'Arcano dell'Alba: Medora, le sette, un gesto
solo, scegliere una carta coperta e girarla"*
(`docs/ordini/ORDINE_DT_MANIFESTO.md`, righe 44-52). Il gesto solo e' diventato
la carta da girare, e l'ingresso del sole non e' passato nella schermata
nuova.

### 3. La richiesta di tenere l'ingresso non e' scritta sul ramo

L'ordine dice che il fondatore aveva chiesto di tenere l'ingresso. **Sul ramo
quella richiesta non c'e'**: cercata in tutti i manifesti e i rapporti dal DS
all'EK, in `docs/`, nei messaggi dei commit e nelle trascrizioni delle
sessioni presenti su questa macchina, con le parole *"ingresso"*, *"col
dito"*, *"verso il cielo"*, *"alza il sole"*, *"solleva"*, *"stesso ingresso"*
e *"gesto del sole"*. Le trascrizioni del 17 settembre, il giorno degli ordini
DT e DU, su questa macchina non ci sono. **Scarto dichiarato**: l'ordine da'
per scritta una richiesta che sul ramo non si trova.

### 4. Perche' non e' stato fatto, e il padre

Padre della regressione: **ordine DT, voci DT.01 e DT.02, commit `47b3c2be`**.
Chi ha eseguito l'ordine DT ha lavorato dalle voci scritte, che chiedevano di
togliere il Rito dell'Alba e di aprire l'Arcano con la carta da girare; la
richiesta di tenere il sole, se c'era, non e' arrivata in nessun testo che
sia sul ramo. **Nessuna prova se n'e' accorta**, perche' le prove del Rito
sono state tolte insieme al Rito, e quelle dell'Arcano misuravano il tavolo.
La guardia nuova di quest'ordine esiste per questo.

---

## VOCE EL.01, L'INGRESSO DEL SOLE

**La domanda.** *"Mi sono accorto di una regressione sul dono Arcano
dell'Alba. Avevo chiesto e mai compiuto che l'ingresso del dono doveva essere
lo stesso del precedente ovvero l'utente che col dito alza il sole verso il
cielo e la scena si illumina, era già fatto e funzionava."*

**Fatto.** Il motore del sole e' tornato in un file suo,
`lib/features/rituals/il_sole_dell_alba.dart` (`IlSoleDellAlba` e
`PittoreDellAlba`), com'era nel commit `8a19e6b8`: il cielo passa dalla notte
al giorno, il sole sale dall'orizzonte al posto della luna, il mare e il
riflesso si accendono; 220 punti di trascinamento lo alzano del tutto, oltre
lo 0,55 al rilascio l'alba si compie da sola, un tocco o un tocco prolungato
la compiono comunque, Riduci Movimento e' rispettato. La sola aggiunta: a
sole salito la scena resta illuminata 450 millesimi prima che arrivino le
carte. Nell'Arcano dell'Alba (`arcano_dell_alba_screen.dart`) il sole sta
sopra la scena finche' la persona non lo alza; poi si dissolve in 700
millesimi mentre il tavolo dei ventidue entra a spirale, e **da li' in avanti
niente e' cambiato**. Riaprendo il dono nello stesso giorno si torna al
responso e il sole non si ripete, come ha deciso il fondatore il 17 settembre.

**Le guardie.** Regola B: otto guardie della zona viste rosse prima di
metterci mano (`l_arcano_dell_alba_si_gira`, `il_tavolo_dei_ventidue`,
`il_mischia_ricompone_il_mazzo`, `l_alba_si_legge`,
`il_responso_si_legge_ovunque`, `il_censimento_dei_caratteri`, `rito_alba` e
la cattura dell'Arcano delle anteprime). Regola A: la guardia nuova
`l_arcano_dell_alba_si_apre_col_sole_test.dart`, cinque prove, vista rossa in
cinque giri d'innesto verificati col conteggio letterale. Le prove che aprono
l'Arcano passano dal gesto vero con l'aiuto comune `test/alzare_il_sole.dart`,
che pretende il sole prima delle carte.

**La prova sul Realme** (`docs/collaudo/EL/prova_del_sole.txt`): la
registrazione dello schermo dal tocco sul dono dell'Alba nella striscia dei
doni, 83 fotogrammi in dieci secondi. A 0,54 secondi dal tocco si apre la
notte col sole sull'orizzonte e l'invito; il dito sale e il cielo schiarisce
con lui, luminosita' 66, 104, 147, 185 fino a **215 a 5,71 secondi**, la
scena illuminata; a **6,14 secondi** le carte, *"La carta del destino di
oggi"*, i ventidue dorsi, Mischia e Taglia. Il Realme ha le animazioni di
sistema a 0,0, quindi li' la dissolvenza e la spirale non si vedono: l'app
rispetta Riduci Movimento. Con le animazioni accese ci sono, e le mostrano
le anteprime `docs/preview/arcano-alba-sole-*.png`. **Il giudizio a video
resta del fondatore.**

**CHIUSA.**
DOMANDA: "l'ingresso del dono doveva essere lo stesso del precedente ovvero l'utente che col dito alza il sole verso il cielo e la scena si illumina"
PROVA: docs/collaudo/EL/registrazione_del_sole.mp4
MISURA: prima dell'ordine EL zero secondi di sole, il dono si apriva sulle carte; sul Realme il cielo sale col dito da 49 a 215 di luminosita' fra 4,31 e 5,71 secondi dal tocco sul dono, e le carte arrivano a 6,14

---

## VOCE EL.02, IL TAGLIA RICOMPONE IL MAZZO

**La domanda**, in chat la sera del 24 settembre 2026: *"Già che ci sei, nel
Arcano dell'alba con il click al tasto "Mischia" le carte si devono
ricomporre in un mazzo, il mazzo viene tagliato e poi dal mazzo le carte si
ristendono"*, e subito dopo: *"Scusa non Mischia. Ma "taglia". Il pulsante
"Mischia" è già ok"*.

**Cosa faceva prima.** Il Taglia e' nato col tavolo, ordine DU, commit
`5e1064f2` del 17 settembre 2026: in 900 millesimi le due meta' del ventaglio
si scostavano a destra e a sinistra e tornavano ognuna al suo posto, e a
corsa finita i posti si scambiavano di colpo. Nessun mazzo e nessun taglio da
vedere. Col movimento ridotto, cioe' sul Realme che ha le animazioni di
sistema a zero, i posti si scambiavano subito e a video non cambiava niente,
perche' i ventidue dorsi sono uguali. **Misurato sul Realme con la build di
prova di prima** (`docs/collaudo/EL/taglio_prima_carte_nel_tempo.txt`): il
tavolo largo 849 pixel e in un gruppo solo prima e dopo il tocco, **e fra
0,60 e 1,61 secondi dal tocco il tavolo vuoto**, le carte sparite per circa
un secondo (`taglio_prima_tavolo_vuoto.png`).

**Fatto**, in `lib/features/rituals/tavolo_dei_ventidue.dart`. Il Taglia
dura 2.000 millesimi, in cinque tempi letti da un solo controllore: fino a
0,25 le carte si radunano nel mazzo, nello stesso punto del Mischia, e si
raddrizzano; fra 0,31 e 0,49 il pacchetto di sopra si alza e va a destra
mentre l'altro scivola a sinistra, e i due restano affiancati; a 0,52, con i
pacchetti separati, i posti si scambiano (`_scambiaNelTaglio`), cosi' nessuna
carta salta; fra 0,55 e 0,73 il pacchetto che era sotto si alza e si posa
sopra l'altro; da 0,73 le carte si ristendono dal mazzo. Il mazzo ha uno
spessore di mezzo punto per carta, e il pacchetto che si alza si vede
staccarsi. **Il taglio si vede anche con le animazioni di sistema spente**:
il suo controllore dichiara `AnimationBehavior.preserve`, come il volo dei
semi del Soffio (ordine EF), perche' e' il contenuto del pulsante.
**Il Mischia resta com'era**, come ha detto il fondatore: col movimento
ridotto cambia i posti senza animazione, come l'ha lasciato l'ordine EE, e se
il fondatore vuole che si veda anche lui sul telefono con le animazioni
spente e' una riga. Mentre uno dei due gesti corre, nessun dorso si sceglie.

**E il tavolo vuoto di un secondo.** Con la build nuova non si e' ripetuto
in tre registrazioni, e la sua causa esatta non si e' potuta riprodurre: la
build vecchia era aperta da tre ore. **Il meccanismo che poteva svuotare il
tavolo pero' c'era, e ora e' misurato e tolto.** Le carte stanno nella pila
in ordine di posto e la chiave stava sul dorso, due livelli sotto: a ogni
scambio di posti Flutter ricreava tutte e ventidue le immagini, che restano
vuote finche' non ritrovano il loro disegno (misurato: 22 su 22). E il dorso
cambiava forma quando il tocco si spegneva, con lo stesso effetto. Adesso la
chiave sta sul figlio della pila e il dorso ha sempre la stessa forma:
immagini ricreate **0 su 22**, col movimento pieno e con quello ridotto.

**Le guardie.** Regola B, prima di toccare il tavolo: `il_tavolo_dei_ventidue`
vista rossa consegnando il posto invece della carta, `il_mischia_ricompone_il_mazzo`
vista rossa portando l'attesa di meta' corsa a corsa intera. **E la prima
delle due era cieca proprio sul Taglia**: toccava Taglia a 1.550 millesimi dal
Mischia, che dall'ordine EE voce 01 (commit `14088e9f`, da 1.100 a 1.800
millesimi) era ancora in corsa, e il tocco veniva ignorato. Il primo rimedio
contava le carte mosse e dava verde lo stesso, perche' in quel mezzo secondo
le muoveva il Mischia; misurando il mazzo raccolto la prova e' caduta, carte
sparse per 83,4 punti, e con l'attesa giusta e' verde. Regola A: la guardia
nuova `il_taglia_ricompone_il_mazzo_test.dart`, quattro prove, nata rossa sul
Taglia di prima (carte mai raccolte, sparse per 156,3 punti, e un salto di
224,7 punti a corsa finita) e poi vista rossa con quattro innesti verificati
col conteggio letterale: lo scambio dei posti a corsa finita, il taglio senza
`AnimationBehavior.preserve`, la chiave tolta dal figlio della pila, il tocco
lasciato libero durante il gesto. La prova delle immagini e' nata rossa sul
difetto vero, 22 su 22. `etichette_e_lettura` e' caduta nella suite intera su
un difetto della voce EL.01, l'invito del sole in un file nuovo: l'elenco
degli ammessi portava ancora il file del Rito dell'Alba cancellato dall'ordine
DT, e ora porta `il_sole_dell_alba.dart`.

**Le anteprime** `docs/preview/arcano-alba-taglio-*.png`: il mazzo a 0,60
secondi, il pacchetto di sopra che si alza a 0,80, i due pacchetti affiancati
a 1,04, quello che era sotto che si posa sopra a 1,28, le carte che si
ristendono a 1,65.

**La prova sul Realme** (`docs/collaudo/EL/prova_del_taglio.txt`), build 2280
con la sha1 `7ba2996a1cf8`, animazioni di sistema a 0,0: 83 fotogrammi
di `screencap` dal tocco su Taglia. Il tavolo largo 849 pixel si raccoglie in
un mazzo largo 121 pixel a 0,60 secondi; **fra 1,08 e
1,52 secondi le carte sono due gruppi**, i due pacchetti affiancati,
larghi insieme fino a 363 pixel; poi un gruppo solo di nuovo, il
mazzo rifatto, e a 2,21 secondi il tavolo e' di nuovo largo 849 pixel.
Nessun fotogramma senza carte. **Il giudizio a video resta del fondatore.**

**CHIUSA.**
DOMANDA: "le carte si devono ricomporre in un mazzo, il mazzo viene tagliato e poi dal mazzo le carte si ristendono"
PROVA: docs/collaudo/EL/registrazione_del_taglio.mp4
MISURA: prima dell'ordine, sul Realme, il tavolo restava largo 849 pixel e in un gruppo solo per tutto il tocco su Taglia, e vuoto fra 0,60 e 1,61 secondi; con la build 2280 mazzo largo 121 pixel a 0,60 secondi, due pacchetti fra 1,08 e 1,52 secondi, tavolo di nuovo largo 849 pixel a 2,21 secondi, nessun fotogramma senza carte
