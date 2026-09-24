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

VOCI_TOTALI: 1
VOCI_CHIUSE: 1
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
