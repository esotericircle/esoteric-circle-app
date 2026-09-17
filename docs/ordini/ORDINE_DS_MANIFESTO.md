# ORDINE DS, IL DEBITO E I DIFETTI DEL 17 SETTEMBRE

**Sigla:** DS. **Data:** 17 settembre 2026. **Ramo:**
`claude/esoteric-circle-master-order-e798aj`. Parte dal commit `c383e6ae`,
con l'ordine DM chiuso.

**NOVE VOCI, SOPRA IL TETTO DI SEI DEL COLLAUDO.** Lo dichiaro qui come
l'ordine chiede. Le sei più rischiose, in ordine di rischio:

1. **DS.06**, la Costellazione del Viso su iPhone: la causa sta nella catena
   fotocamera e modello, e su questa macchina non c'è né un iPhone né un Mac.
   La prova vera la fa un fondatore col suo telefono.
2. **DS.08**, le risposte di Medora: tocca la chat, cioè il punto dove il
   modello parla, e una risposta sbagliata la legge una persona.
3. **DS.05**, la Meditazione: cambia quando parte il suono e come si sceglie, in
   una schermata dove il fondatore ha già approvato respiro, mandala e
   frequenze, che non si toccano.
4. **DS.07**, i pulsanti della chat: una mappa sbagliata manda la persona nella
   funzione sbagliata, e i Maestri sono tre.
5. **DS.01**, le guardie e il sigillo di 89 manifesti: una guardia che legge
   male un formato griderebbe al falso su un ordine chiuso.
6. **DS.09**, la Stesa: il testo è composto a pezzi, e togliere una ripetizione
   può aprirne un'altra altrove.

VOCI_TOTALI: 9
VOCI_CHIUSE: 0
VOCI_APERTE: 8
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0
VOCI_FERMATE_SU_PREMESSA_FALSA: 1

Il rapporto starà in `docs/ordini/RAPPORTO_ORDINE_DS.md`.

---

## LE VOCI

- **DS.01**, ogni manifesto ha la sua guardia ed è coperto dal sigillo
  aggregato, qualunque sia il suo formato. **APERTA.** Il manifesto DD dichiara
  16 voci e ne nomina 17: è elencato e NON corretto, e la decisione è del
  fondatore.
- **DS.02**, un manifesto nuovo senza guardia si vede al primo giro.
  **APERTA.**
- **DS.03**, i documenti che dichiarano uno stato si aggiornano perché qualcosa
  li nomina. **FERMATA SU PREMESSA FALSA.** `RIPRESA.md` non è fermo a DG ed è
  un archivio chiuso per decisione scritta: vedi sotto.
- **DS.04**, la tavola delle esenzioni degli accenti si indicizza sul
  contenuto, con 11 esenzioni e 17 parole prima e dopo. **APERTA.**
- **DS.05**, la Meditazione: il sintomo come via principale, la frequenza da un
  solo controllo, il suono solo al gesto, il conto alla rovescia di cinque
  minuti. **APERTA.**
- **DS.06**, la Costellazione del Viso rileva il volto su iPhone, con l'ovale,
  l'immagine in alto e l'istruzione più grande. **APERTA.** Viene prima di
  tutte, per vincolo dell'ordine.
- **DS.07**, ogni pulsante della chat apre la funzione che promette.
  **APERTA.**
- **DS.08**, le risposte di Medora: la carta del giorno, la stessa lettura per
  la stessa domanda, il cielo dal calcolo, le chiuse fisse. **APERTA.**
- **DS.09**, la Stesa non ripete la stessa immagine e ogni frase dice ciò che
  intende. **APERTA.**

---

## I FATTI RIMISURATI, LA REGOLA ZERO DELL'ORDINE

**Regola DS.00.A**: ogni numero, percorso e riga dell'ordine è stato
rimisurato prima di scrivere codice. Dove il mio numero diverge sta scritto qui
accanto, **col metodo**.

**Sul metodo.** L'ordine avverte di diffidare dei conteggi fatti con una
ricerca testuale, perché un commento somiglia a una riga di codice. Le voci dei
manifesti NON le ho contate col grep di una sigla: una menzione nella prosa
(*"la voce DD.04 aveva torto"*) non dichiara una voce, la cita. Le ho contate
solo nelle **posizioni che dichiarano**: all'inizio di una riga d'elenco
(`- **XX.NN**`), in un'intestazione (`## XX.NN`, prendendo **tutti** i numeri
della riga, perché `## DI.11, DI.12, DI.13 e DI.14` sono quattro voci), nella
prima cella di una tabella, in testa a un paragrafo in grassetto. Il
programma sta in `tool/` come sorgente della guardia, non in un conto a mano.

### DS.01

| premessa | l'ordine dice | la mia misura | esito |
|---|---|---|---|
| manifesti in `docs/ordini` | 91 | **89 file portano `VOCI_TOTALI:`**, di **88 ordini**: DB ne ha due, `ORDINE_DB_MANIFESTO.md` e `ORDINE_DB_MEDITAZIONE.md`. I file `*_MANIFESTO.md` sono 88; i file che cominciano con `ORDINE_` sono 102, e i 13 in più sono testi d'ordine (`ORDINE_P.md`, `ORDINE_S.md`, `ORDINE_2161.md`...), non manifesti. Nessun metodo che ho provato dà 91 | **DIVERGE** |
| ordini senza guardia propria | 19, da CW a DQ, CX compreso | **18**: CW, CY, CZ, DA, DB, DC, DD, DE, DF, DG, DI, DJ, DK, DL, DN, DO, DP, DQ. **CX non ha un manifesto**: `ORDINE_CX_VISO.md` è il testo dell'ordine del fondatore, senza marcatori e senza righe di stato. Metodo: per ogni sigla con un file a marcatori, esiste `test/ordine_<sigla>_guard_test.dart`? | **DIVERGE, e CX è un debito diverso**: manca il manifesto, non la guardia |
| il sigillo hardcoda `{CG:16, CM:11, CN:16, CO:20, CP:10, CQ:61}` alle righe 37-42 | righe 37-42 | **vera**, righe 37-44 del file con la graffa | **VERA** |
| la guardia conta solo `- **XX.NN**` e i manifesti da DI in poi usano `## XX.NN` | vero | **vera**, la riga che conta è `RegExp('^- \\*\\*$ordine\\.\\d\\d\\*\\*')` | **VERA** |
| e cerca `VOCI_APERTE` mentre quelli scrivono `VOCI_SBLOCCATE_E_APERTE` | vero | **vera a metà**: `VOCI_APERTE` lo portano 78 manifesti su 89, `VOCI_SBLOCCATE_E_APERTE` 8. Gli stati scritti a macchina sono **quindici** nomi diversi | **VERA, più larga** |
| **il 61 di CQ** | 61 scritto a mano | **61**: 61 righe `- **CQ.NN**`, numeri da CQ.01 a CQ.61, tutti diversi. Marcatori: 60 chiuse e 1 ferma su decisione del fondatore, somma 61 | **VERA, ora misurata** |

**I MANIFESTI CHE NON TORNANO, dopo aver imparato i formati.** Il primo conto
ne dava dieci; imparati i formati ne restano tre, e uno era un errore mio.

- **DN** dichiara 10 e ne trovavo 11: **DN.00 è la regola di verifica**
  (*"PERCHE' IL 77 PER CENTO"*), non una voce. Esclusa la voce zero, torna.
- **DF** dichiara 7 e non ne elenca nessuna col suo numero: le sette voci
  esistono nella prosa ma **non si possono contare dal file**. Non è un falso,
  è un manifesto **non enumerato**, e lo dichiaro così.
- **DD dichiara il falso.** Marcatori: `VOCI_TOTALI: 16, quindici dell'ordine
  più la voce 17`, `VOCI_CHIUSE: 14`, `VOCI_APERTE: 2`, `QUALI_RESTANO: DD.14
  e DD.15`. Voci nominate: DD.01...DD.13, **DD.16** e DD.17 con la loro
  sezione, DD.14 e DD.15 nel marcatore. **Sono diciassette.** DD.16, *"l'animazione
  del respiro nella Meditazione"*, esiste davvero ed è citata nel codice
  (`meditation_screen.dart`, *"Ordine DD voce 16"*), ma nel conto non entra.
  **Elencato e NON corretto: la decisione è del fondatore.**

**E tre manifesti hanno marcatori che non coprono tutti gli stati**, senza per
questo dire il falso: DB meditazione porta solo `VOCI_TOTALI: 13`, DE porta 16
totali e 2 aperte senza le chiuse, DF porta 7 totali e 0 aperte senza le chiuse.
DA porta anche `VOCI_SENZA_GUARDIA_PROPRIA: 1`, che è un attributo e non uno
stato: tolto quello, 6 e 6 tornano.

### DS.03

| premessa | l'ordine dice | la mia misura | esito |
|---|---|---|---|
| `RIPRESA.md` è fermo al 12 settembre, all'ordine DG, col commit *"DG: la build sale a 2250"* | fermo a DG | **Falso sul ramo.** Il commit `e0e8b825` *"DG: la build sale a 2250"* tocca **solo `pubspec.yaml`**. L'ultimo commit che tocca `RIPRESA.md`, sul canonico e sul locale, è `d14e8e46` del **1 settembre**, ordine CM | **FALSA** |
| si aggiorna perché qualcosa lo nomina, come STATO_VIVO | da riallineare | **Dal 24 agosto 2026 (`9675d016`) la sua testata dice "RIPRESA, ARCHIVIO CHIUSO... Qui NON si aggiunge più niente"**, e `docs/STATO_VIVO.md` alla sezione *"LE FONTI DELLO STATO SONO DUE, E RIPRESA.MD NON È UNA DI QUELLE"* ne dà la ragione: una terza copia dello stesso stato invecchierebbe in silenzio | **LA DIVERGENZA CAMBIA LA NATURA DEL LAVORO** |

**Mi fermo qui, come DS.00 prescrive.** Riallineare `RIPRESA.md` vuol dire
rovesciare una decisione scritta, e decidere se un archivio chiuso torna vivo
spetta al fondatore. Il censimento dei file che dichiarano uno stato lo faccio
comunque e va nel rapporto.

### DS.04

| premessa | l'ordine dice | la mia misura | esito |
|---|---|---|---|
| esenzioni | 11 | **11**, contate come chiavi della mappa `conRagioneScritta` | **VERA** |
| parole sorvegliate | 17 | **17**, chiavi della mappa `sbagliate`: undici più le sei dell'ordine CO | **VERA** |
| l'ultimo spostamento, 473 alla 474 per un import di DM | vero | **vera**, `sky_overview_screen.dart:474` | **VERA** |

### DS.05

| premessa | l'ordine dice | la mia misura | esito |
|---|---|---|---|
| il suono parte da solo appena si apre la schermata | parte all'apertura | **All'apertura NON parte.** `initState` non chiama il lettore; `play` sta in tre punti: il pulsante di avvio, **la scelta di un sintomo** e **la scelta di una frequenza**, che a sessione ferma avviano la sessione. È ciò che il fondatore vede: tocca una bolla e il suono parte senza aver detto *"comincia"* | **DIVERGE NEL PUNTO, VERA NELLA SOSTANZA** |
| la scelta della frequenza si fa fra molte bolle | molte | **nove** pastiglie `MeditationPreset` nel pannello della libreria | **VERA** |
| durante la sessione non si sa quanto manca | vero | **vera**: la sessione dura **12 cicli da 11 secondi, 132 secondi**, e l'unico conto alla rovescia è quello della fase del respiro | **VERA** |
| la scheda del sintomo dice quale frequenza comporta | da fare | **dei 12 sintomi, 4 non hanno un centro** e quindi nessuna frequenza propria: oggi suonano la frequenza già scelta | **DA DICHIARARE A SCHERMO** |

**Contraddizione fra ordini, dichiarata.** L'ordine DD voce 12 aveva scritto
*"Scelto il sintomo, Aura fa partire la pratica adatta subito, senza altri
passaggi da confermare"*. DS.05 dice il contrario: *"Aprire la schermata non è
un consenso a sentire un suono"* e il suono parte quando l'utente decide. **Vince
la voce più recente**, come in DD, e la guardia di prima porterà scritto perché.

### DS.06

| premessa | l'ordine dice | la mia misura | esito |
|---|---|---|---|
| su iPhone il volto non si rileva | non rileva | **la causa è nel codice, e sono tre difetti in fila.** Il controllo della fotocamera chiede `ImageFormatGroup.nv21`, che su iOS **non esiste**: `camera_avfoundation` 0.9.23+2 lo fa ricadere in **BGRA8888**. Il motore poi passa quei byte BGRA a `FaceMeshNv21Image` e `processNv21`, cioè li legge come un NV21 che non sono. Il pacchetto `mediapipe_face_mesh` 2.9.0 lo dice nel suo README: NV21 *"for Android camera frames"*, BGRA per iOS con `process`. **E anche coi byte giusti** la rotazione usa `sensorOrientation`, che su iOS non è la rotazione da dare al modello, e il fotogramma viene specchiato una seconda volta. L'esempio del pacchetto su iOS usa BGRA, la rotazione del dispositivo e **nessuno specchio** | **VERA, CAUSA TROVATA** |
| il riquadro della riservatezza, la bolla del cielo, l'istruzione sotto la piega | vero | **vera**: `face_privacy`, `face_sky_setting` con *"Lega al cielo di oggi"*, e l'avviso degli accessori dopo | **VERA** |
| l'istruzione dei movimenti è la meno visibile | vero | l'istruzione durante la cattura è `face_guide`, **`TypographyTokens.didascalia()`, 16 punti, peso 400** | **MISURA PRIMA: 16 punti** |
| togliendo l'interruttore del cielo qualche lettura cambia contenuto | da verificare | **No.** L'interruttore della soglia vale `false` all'inizio e decide solo se la riga dei transiti compare nel risultato; **nel risultato c'è già un secondo interruttore, "Lega ai transiti"**, che fa la stessa cosa e resta. Chi apre la funzione e non tocca niente riceve la stessa lettura di prima, e chi vuole il cielo lo accende dove lo legge | **NESSUNA LETTURA CAMBIA** |

### DS.07

| premessa | l'ordine dice | la mia misura | esito |
|---|---|---|---|
| il pulsante delle rune di Caligo apre la Runa del Tramonto | vero | **vera**: `ImmersiveTarget.lancioRune` va a `SunsetRuneScreen.route()` in `lib/features/maestri/immersive_navigation.dart` | **VERA** |
| la regola del vero sta a `chat_suggestions.dart` riga 212 | riga 212 | **vera**, righe 211-212, in un commento | **VERA** |
| gli altri pulsanti | da verificare | **14 pulsanti**, 4 di Medora, 5 di Aura, 5 di Caligo. **La chat usa una mappa sua**, `immersiveRouteFor`, diversa da `artRouteFor` dello scaffale: due porte per la stessa cosa. Sbagliati: **le rune** (Runa del Tramonto invece dell'Estrazione); **la Stesa, la Costellazione del Viso e il Sigillo**, che la chat dichiara *"Questa esperienza sta per aprirsi nel cerchio. Arriva presto"* mentre dallo scaffale si aprono davvero; **l'oroscopo del giorno**, che apre l'Arcano del Giorno mentre `OroscopoScreen` esiste. Onesti: Sinastria, Meditazione, respiro, frequenze, e i cinque che non esistono ancora (carta natale, chakra, I-Ching, pendolo, candela) | **VERA E PIÙ LARGA: 6 sbagliati su 14** |

### DS.08

| premessa | l'ordine dice | la mia misura | esito |
|---|---|---|---|
| "Carta del giorno" non consegna una carta | vero | **vera, ed ecco perché.** Il suggerimento di Medora si chiama **"Tira una carta per me"** e *"carta del giorno"* in `lib` non è un comando. Il testo va nudo al modello: le parole chiave della Stesa sono `stesa`, `tira le carte`, `tarocchi`..., e *"tira una carta"* non ne tocca nessuna. **Nessuna carta viene estratta**, mentre `ArcanoDelGiorno.di` esiste e dà la carta del giorno in modo deterministico | **VERA, CAUSA TROVATA** |
| due letture opposte a due minuti | vero | **vera per costruzione**: `temperature: 0.9`, nessun seme, nessuna memoria del giorno per la stessa domanda | **VERA** |
| legge 6 di RETENTION, la ricompensa variabile | legge 6 | **la legge 6 di `docs/RETENTION.md` è "Non si amputa, si mette in ordine"**, e in quel documento la ricompensa variabile non compare. **La regola che l'ordine cita esiste, ma sta altrove**: `docs/04_Briefing_Operativo_MVP_Demo.md`, sezione 15, *"La regola di coerenza dei responsi"*: la stessa domanda nello stesso giorno dà lo stesso responso, perché il cielo del giorno è quello | **DIVERGE NELLA FONTE, VERA NELLA REGOLA** |
| punti 3 e 4, il Primo Quarto e il segno opposto fra tre giorni | da verificare | **Il modello non riceve né la fase di oggi né il segno della Luna di oggi.** Riceve la fase lunare **di nascita** e un blocco di al più tre *eventi in arrivo* calcolati (`Primo quarto: fra N giorni`, `La Luna nel segno opposto: fra N giorni`, i retrogradi). **La chiusa "Ripassa quando sarà luna crescente" è una stringa del codice**, `consiglio_finale.dart`, costruita sulla fase di **domani** e uguale per tutti per tutto il giorno. Il punto 3 è quindi un difetto del codice e non del modello. Per il punto 4 la misura vera va fatta sui dati del 17 settembre: se il blocco diceva davvero *"segno opposto fra 3 giorni"*, **"opposto" è letto male rispetto a quale segno**; se non lo diceva, lo ha inventato il modello | **DA CHIUDERE CON IL CALCOLO DEL GIORNO** |

### DS.09

| premessa | l'ordine dice | la mia misura | esito |
|---|---|---|---|
| "non un muro" due volte | vero | **vera per costruzione**: in `lib/core/tarot/voce_della_stesa.dart` la figura sta in **due tavole diverse** (le forme del futuro e le forme dei versi) che non si conoscono | **VERA** |
| "che si sta sciogliendo" si attacca al Sole | vero | **vera**: in `lib/core/horoscope/corrente_del_cielo.dart` la coda del transito si appende **dopo** il bersaglio, due punti | **VERA** |
| "E il cielo di oggi lo accompagna" | vero | **vera**, in `voce_della_stesa.dart`, prima del fatto del cielo | **VERA** |
| la cura del Viaggio a strati può valere | può | la guardia del Viaggio confronta **cinque parole di fila**, e *"non un muro"* ne ha tre: **quella misura non la prenderebbe**. Serve una misura sulla **figura** | **VERA NELL'IDEA, NON NELLA MISURA** |

---

## L'ORDINE DI ESECUZIONE

DS.06 per prima, per vincolo. Poi DS.07, DS.05, DS.09, DS.08, DS.04, DS.01 e
DS.02 insieme perché il meccanismo della seconda vive nella prima, e il
censimento di DS.03. Ogni guardia nuova si vede rossa prima della cura.
