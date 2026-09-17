# RAPPORTO DELL'ORDINE DS, IL DEBITO E I DIFETTI DEL 17 SETTEMBRE

**Data:** 17 settembre 2026. **Ramo:** `claude/esoteric-circle-master-order-e798aj`.
**Manifesto:** `docs/ordini/ORDINE_DS_MANIFESTO.md`, con le misure rifatte e il
metodo di ognuna. **Catture del telefono:** `docs/collaudo/DS/`, Realme
767f596c, build 2265 di collaudo.

**Nove voci, sopra il tetto di sei del collaudo**, dichiarato in testa al
manifesto con le sei più rischiose.

| voce | stato |
|---|---|
| DS.01, le guardie proprie e il sigillo aggregato | **CHIUSA** |
| DS.02, il debito non si riforma | **CHIUSA** |
| DS.03, i documenti che nessuno nomina | **FERMATA SU PREMESSA FALSA** |
| DS.04, la tavola degli accenti | **CHIUSA** |
| DS.05, la Meditazione | **CHIUSA** |
| DS.06, la Costellazione del Viso | **FERMATA IN ATTESA DELLE MANI DEL FONDATORE**: serve un iPhone |
| DS.07, i pulsanti della chat | **CHIUSA** |
| DS.08, le risposte di Medora | **CHIUSA** |
| DS.09, la Stesa | **CHIUSA** |

**Ordine di esecuzione:** DS.06 per prima, per vincolo; poi DS.07, DS.08
(la carta del giorno insieme a DS.07, perché passa dagli stessi pulsanti),
DS.09, DS.05, DS.04, DS.01 e DS.02 insieme, il censimento di DS.03.

**Le due fermate, dette subito.**

1. **DS.03 si è fermata prima del codice.** L'ordine dice che `RIPRESA.md` è
   fermo a DG, 12 settembre. Sul ramo non lo è: il commit *"DG: la build sale a
   2250"* tocca solo `pubspec.yaml` e `RIPRESA.md` è fermo al 1 settembre. E
   soprattutto **dal 24 agosto la sua testata lo dichiara archivio chiuso**, per
   una decisione scritta anche in `STATO_VIVO.md`. Riallinearlo vuol dire
   rovesciare quella decisione: la divergenza cambia la natura del lavoro e
   decidere è del fondatore.
2. **DS.06 non è chiusa e non è aperta.** La causa del mancato rilevamento su
   iPhone è trovata e curata nel codice, ma **la prova sul telefono la può fare
   solo un fondatore**: qui non c'è né un iPhone né un Mac. Lasciarla APERTA
   avrebbe tenuto rosso lo sbarramento e senza sbarramento la build per
   Codemagic che serve a quella prova non sarebbe uscita.

---

## DS.01, LE GUARDIE PROPRIE E IL SIGILLO AGGREGATO

### Quanti manifesti erano scoperti e quanti lo sono adesso

| | prima | dopo |
|---|---|---|
| manifesti `ORDINE_XX_MANIFESTO.md` | 88 | **89**, con DS |
| con la guardia propria | 70 | **89** |
| **senza guardia propria** | **18**: CW, CY, CZ, DA, DB, DC, DD, DE, DF, DG, DI, DJ, DK, DL, DN, DO, DP, DQ | **0** |
| nel sigillo aggregato | **6**: CG, CM, CN, CO, CP, CQ | **89** |
| **fuori dal sigillo** | **82** | **0** |

L'ordine diceva 91 manifesti e 19 senza guardia. **Il 91 non si ottiene con
nessun metodo che ho provato**: 88 manifesti più il file
`ORDINE_DB_MEDITAZIONE.md`, che porta un `VOCI_TOTALI` ma è il testo
archiviato dell'ordine DB, fa 89. **E CX non ha un manifesto affatto**:
`ORDINE_CX_VISO.md` è il testo dell'ordine del fondatore, senza marcatori. Il
debito di CX è diverso da quello degli altri diciotto: manca il manifesto, non
la guardia. **Non l'ho scritto**: il manifesto di un ordine chiuso lo scrive chi
l'ha eseguito e ricostruirlo a posteriori vorrebbe dire inventare gli stati
delle sue voci.

### Come si leggono tutti i formati

Il lettore sta in `test/lettore_dei_manifesti.dart` e **conta una voce solo in
una posizione che dichiara**: riga d'elenco `- **XX.NN**`, intestazione `##
XX.NN` con tutti i numeri della riga, prima cella di una tabella, testa di un
paragrafo in grassetto. Una citazione nella prosa non è una voce. La prova del
formato monta due manifesti, uno con le intestazioni e uno con l'elenco e
pretende che tutti e due si leggano e che la citazione di una voce nella prosa
non si conti.

### Il 61 di CQ

**CQ ha 61 voci vere**, accanto al 61 scritto a mano: 61 righe `- **CQ.NN**`, da
CQ.01 a CQ.61, tutte diverse. Marcatori: 60 chiuse e 1 ferma su decisione del
fondatore.

### I manifesti che dichiarano il falso, elencati e NON corretti

| manifesto | voci lette in posizione di dichiarazione | marcatori | cosa |
|---|---|---|---|
| **DD** | **15**: DD.01...DD.13, DD.16, DD.17. **Nominate 17**, con DD.14 e DD.15 nel marcatore `QUALI_RESTANO` | `VOCI_TOTALI: 16`, `VOCI_CHIUSE: 14`, `VOCI_APERTE: 2` | DD.16, l'animazione del respiro nella Meditazione, esiste ed è citata nel codice, ma nel conto non entra |
| **DN** | **11**: DN.00...DN.10, tutte `CHIUSA` | `VOCI_TOTALI: 10`, `VOCI_CHIUSE: 10` | DN.00 è scritta come DL.00, che il manifesto DL conta fra le sue voci |

**Una correzione, perché l'avevo detta durante il lavoro.** Alla prima misura
avevo escluso DN.00 dicendo che è la regola di verifica e non una voce e DN
tornava. **Era leggere il contenuto per far tornare un conto.** Nessun formato
distingue una voce zero che conta da una che non conta: AT.00, U.00 e DL.00
sono voci contate nei loro totali. Tolta l'esclusione, DN dichiara il falso come
DD.

**Due manifesti non sono falsi e hanno un formato loro, imparato:** DF dichiara
7 voci e non ne scrive nessuna col numero, quindi il conto non si rifà dal
file; DE e DF portano il totale e le aperte senza le chiuse, che sono il resto.

**Il sigillo non accetta il falso**: pretende che resti **esattamente** quello
riportato. Se il fondatore decide e DD o DN cambiano, la prova cade e la riga si
toglie; se il falso si allarga, cade lo stesso. Nessuna riga in
`tool/rossi_accettati.txt`.

### Le prove e il loro rosso

- `i_manifesti_sono_sigillati_test.dart`, allargata: ogni manifesto nel
  sigillo, ognuno con la sua guardia, nessun file coi marcatori senza nome, il
  lettore legge i due formati. **Rossa** col manifesto CW col `VOCI_TOTALI`
  cambiato (poi rimesso, sha1 uguale prima e dopo) e col lettore privato delle
  intestazioni.
- **Diciotto guardie proprie**, `test/ordine_cw_guard_test.dart` fino a
  `ordine_dq_guard_test.dart`, da un aiutante comune: il manifesto chiuso non si
  riscrive, voci e marcatori al numero. **Rosse tutte e diciotto** con un
  innesto nell'aiutante.

---

## DS.02, IL DEBITO NON SI RIFORMA

**Il meccanismo.** Il sigillo non ha più un elenco scritto a mano dei manifesti
da guardare: **li scopre dal filesystem a ogni giro** e ne pretende tre cose.
Che ciascuno stia nella tavola delle voci misurate, che ciascuno abbia il file
`test/ordine_<sigla>_guard_test.dart` e che quel file nomini il manifesto; e che
nessun file di `docs/ordini` porti `VOCI_TOTALI` senza chiamarsi
`ORDINE_XX_MANIFESTO.md` o essere dichiarato come testo d'ordine.

**Perché regge dove finora nessuna strada ha retto.** Il debito è arrivato a
diciotto perché il controllo era un elenco scritto a mano e un elenco scritto a
mano **non vede ciò che non contiene**: l'ordine CQ ha sigillato sei manifesti e
ogni ordine dopo è nato fuori. Adesso l'elenco lo fa la cartella e un manifesto
nuovo è dentro il controllo dal momento in cui esiste. E la prova gira **nello
sbarramento**, che precede ogni consegna e **sul cancello gratuito di GitHub**
a ogni spinta: un manifesto senza guardia non arriva a una build. Non dipende
dal collaudo, che arriva giorni dopo.

**La prova del rosso, fatta prima.**

- Un manifesto finto `ORDINE_ZZ_MANIFESTO.md` senza guardia: **due prove
  rosse al primo giro**, *"questi manifesti non sono nel sigillo: [ZZ]"* e
  *"questi manifesti non hanno la guardia propria: [... ZZ]"*.
- Un file `ORDINE_ZY_ALTRO_NOME.md` con `VOCI_TOTALI`: **rossa la terza**,
  *"portano VOCI_TOTALI e non si chiamano ORDINE_XX_MANIFESTO.md"*.
- Tutti e due tolti e la cartella verificata vuota di `ORDINE_Z*`.

---

## DS.03, I DOCUMENTI CHE NESSUNO NOMINA

**FERMATA SU PREMESSA FALSA** e il perché sta in testa a questo rapporto.
Quello che l'ordine chiede di elencare, lo elenco.

### I file del repository che dichiarano uno stato e chi li nomina

Metodo: `git log -1` per l'ultimo commit, `git grep -l` sul nome del file per
chi lo nomina, contando a parte manifesti e testi d'ordine e poi codice, prove e
strumenti.

| file | ultimo commit | lo nominano | di cui ordini | di cui codice, prove, strumenti |
|---|---|---|---|---|
| `docs/STATO_VIVO.md` | 17/09/2026 | 28 file | 9 | 6: i due agenti della memoria, l'aggancio che lo inietta, una prova |
| `docs/ordini/RIPRESA.md` | **01/09/2026** | 40 | 5 | 10: `functions/src/index.ts`, `sky.dart`, `santuario_screen.dart` e prove del cielo, **come citazioni d'archivio** |
| `docs/HANDOFF_FASE_C.md` | **09/07/2026** | 2 | **0** | **0** |
| `docs/STATO_ASSET.md` | **13/07/2026** | 2 | **0** | **0** |
| `docs/stato_asset.json` | 15/09/2026 | 11 | 3 | 5, fra cui `stato_asset_test.dart` |
| `docs/stato_funzioni.json` | 30/07/2026 | 9 | 1 | 4, fra cui `stato_funzioni_test.dart` |
| `docs/guardie.md` | 17/09/2026 | 10 | 4 | 3, fra cui `il_registro_delle_guardie_quadra_test.dart` |
| `docs/versione_distribuita.json` | 16/09/2026 | 27 | 13 | 5, fra cui `tool/consegna.py` |
| `docs/ordini/CODA.md` | 13/08/2026 | 3 | 2 | 0 |
| `docs/ordini/ORDINE_CORRENTE.md` | 28/07/2026 | 3 | 2 | 0 |
| `docs/tipografia/censimento.md` | 15/09/2026 | 8 | 1 | 5, rigenerato da `tool/censimento_tipografia.dart` |
| `docs/traduzione/censimento.md` | 17/09/2026 | 8 | 1 | 5, rigenerato da `tool/censimento_stringhe.dart` |
| `CLAUDE.md` | 13/09/2026 | 13 | 5 | 4 |
| `tool/rossi_accettati.txt` | 12/09/2026 | 16 | 7 | 4, fra cui `tool/sbarramento.sh` |

**Cosa dice la tavola.** I file di stato che restano veri sono quelli che
**qualcosa legge**: una prova, lo sbarramento, la consegna, un aggancio. Due
file sono fermi da luglio e **nessun ordine e nessuna prova li nomina**,
`HANDOFF_FASE_C.md` e `STATO_ASSET.md`: sono la stessa specie del difetto che
l'ordine attribuisce a RIPRESA. E `CLAUDE.md` dichiara ancora *"Checkpoint
corrente: C1"*. **Nessuno dei tre l'ho toccato**: sono dello stesso genere della
decisione che il fondatore deve prendere su RIPRESA. I due censimenti hanno lo
stesso nome, `censimento.md` e il conto per nome li mescola: il numero dei
loro chiamanti è quello dei due insieme.

**La prova chiesta**, *"cade quando un file di stato è più vecchio dell'ultimo
manifesto chiuso"*, **non l'ho scritta**: oggi cadrebbe su RIPRESA, che è
vecchio per decisione e su tre file che nessuno ha deciso. Prima serve sapere
quali file di stato devono vivere.

---

## DS.04, LA TAVOLA DEGLI ACCENTI

**Undici esenzioni e diciassette parole sorvegliate, prima e dopo.** La prova
le stampa: *"esenzioni 11, parole sorvegliate 17, morte 0, ambigue 0, che non
esentano niente 0"*.

**La chiave è la riga intera**, senza gli spazi in testa e in coda, al posto del
numero. **La tavola non è più larga, è più stretta.** Una prova nuova pretende
che ogni esenzione trovi **esattamente una riga** nel suo file e la usi: se la
riga cambia l'esenzione muore e la prova cade, se il testo compare due volte
l'esenzione è ambigua e la prova cade. Prima un'esenzione rimasta su un numero
sbagliato esentava in silenzio una riga qualunque.

**La prova dello spostamento**: ogni file esentato, sei in tutto, riceve sette
righe in testa; le esenzioni valgono come prima e una stringa sbagliata nuova
innestata nello stesso file cade lo stesso. **Rossa** su tutte e tre le prove
con uno spazio in più dentro la riga esentata di `euphonic.dart`, rimessa uguale.

---

## DS.05, LA MEDITAZIONE

| richiesta | com'è adesso | prova |
|---|---|---|
| la frequenza da un pulsante che apre un menù | **FREQUENZA: 639 Hz ▾**, un menù con le nove; le nove bolle e la loro classe se ne sono andate | *le bolle non ci sono più*, rossa sul codice di prima |
| il sintomo come via principale | **SCEGLI IL SINTOMO** in alto, il menù della frequenza sotto | `la_libreria_si_apre...`: il sintomo sta sopra la frequenza |
| la scheda del sintomo dice la sua frequenza | *"Frequenza: 639 Hz, il cuore"* su ogni scheda; sulle quattro senza centro *"Frequenza: quella scelta, 639 Hz"* | tutte e dodici enumerate |
| il suono non parte da solo | scegliere un sintomo o una frequenza **sceglie**; parte il play | nessuna riproduzione all'apertura né alla scelta; al play suona la frequenza scelta |
| il conto alla rovescia di cinque minuti | **Mancano 5:00**, sotto il play, solo a sessione viva | da 5:00 a 3:59 a 0:01 e a zero la sessione si compie |

**Contraddizione fra ordini, dichiarata.** L'ordine DD voce 12 voleva la pratica
avviata al tocco del sintomo. **Vince la voce più recente** e le guardie di
prima portano scritto perché.

**Divergenza di misura, dichiarata nel manifesto.** La sessione durava **132
secondi**. Adesso quella del giorno dura cinque minuti; **una pratica scelta
dura quanto la sua scheda dichiara**, perché sette pratiche su dodici sono da 5
minuti e le altre dicono 2, 3, 7, 7 e 10: un 5:00 sotto *"10 minuti"* direbbe il
falso. Provato: *"Due toni che si incontrano, 10 minuti, il conto dice Mancano
10:00"*.

**Cosa non si è toccato**: il respiro, il loto, le frequenze e il loro suono, la
cornice di benessere e la riga *"Le frequenze Solfeggio e il 432 sono
tradizione culturale, non un fatto medico"*, al suo posto.

**Sul telefono**: `05a` la schermata aperta dice *Premi play*; `05b` i sintomi
con la frequenza; `05c` scelto *Respiro corto*, la schermata dice *Premi play*;
`05d` il menù delle frequenze; `05e` dopo il play, *Mancano 4:44*.

Sette prove di prima aggiornate col loro perché: il nome del pulsante, le nove
frequenze nel menù, il sintomo prima della frequenza, la lunghezza delle voci
del menù, il preset binaurale e le due prove che misuravano i 132 secondi. **La
prova *fermarsi a metà non è compiere*** aspettava 150 secondi dopo lo stop: con
cinque minuti di sessione sarebbe stata verde anche col timer vivo. **Adesso
aspetta 330 secondi.**

---

## DS.06, LA COSTELLAZIONE DEL VISO

### La causa del mancato rilevamento su iPhone

**Tre scelte scritte una volta per tutti i telefoni, giuste solo su Android.**

1. **Il formato.** La fotocamera chiedeva `ImageFormatGroup.nv21`. Su iOS NV21
   non esiste: `camera_avfoundation` 0.9.23+2 lo fa ricadere in **BGRA8888**. Il
   motore passava quei byte a `FaceMeshNv21Image` e `processNv21`, cioè leggeva
   quattro byte di colore per punto come se fossero luminanza. Il README di
   `mediapipe_face_mesh` 2.9.0 lo scrive: NV21 *"for Android camera frames"* e
   per BGRA *"use process(...) instead of processNv21(...)"*.
2. **La rotazione.** Al modello arrivava `sensorOrientation`, di solito 90. Su
   iOS il plugin consegna il fotogramma **già girato come il dispositivo**:
   `DefaultCamera.swift` chiama `updateOrientation` sull'uscita video. Girarlo
   ancora di novanta gradi metteva il volto di lato.
3. **Lo specchio.** Su iOS la frontale è **già specchiata** dal plugin,
   `connection.isVideoMirrored = true` e il codice la specchiava una seconda
   volta.

**La cura** sta in `lib/core/face/ingresso_del_fotogramma.dart`: le tre scelte
insieme, per piattaforma. Su iOS BGRA, `FaceMeshImage` con `process`, la
rotazione del dispositivo e nessuno specchio, come l'esempio del pacchetto. **Su
Android niente cambia**: NV21, la rotazione del sensore e la frontale
specchiata, come prima e una prova lo pretende per ogni orientamento. La
maschera dei punti usa la **stessa** rotazione del modello: col sensore su iOS
avrebbe scambiato i lati.

### La cattura che prova che adesso rileva

**Non c'è.** Su questa macchina non c'è un iPhone e non c'è un Mac. La prova
tocca a un fondatore, con la build Codemagic di quest'ordine: aprire la
Costellazione del Viso, inquadrarsi nell'ovale e mandare la cattura della
maschera dei punti accesa sul volto. **Finché quella cattura non arriva la voce
non è chiusa.** Su Android la schermata è vista sul telefono, catture `06a`,
`06b` e `06c`, con l'anteprima viva della fotocamera; un volto davanti
all'obiettivo non l'ho potuto mettere.

### L'istruzione dei movimenti, prima e dopo

| dove | prima | dopo |
|---|---|---|
| sulla soglia, *"Quattro pose guidate: destra, sinistra, alto, basso"* | **16 punti**, didascalia grigia, **sotto** il pulsante | **22 punti**, titolo di sezione in oro, **sopra** il pulsante |
| durante la scansione, la guida delle pose | **16 punti**, didascalia | **22 punti**, titolo di sezione |

### Il resto

- **L'ovale**, `ovale_dell_inquadratura.dart`, al centro dell'inquadratura:
  tenue senza volto, acceso quando il motore misura un volto nel fotogramma.
  Un ovale acceso davanti a un muro direbbe che la macchina trova qualcosa. La
  guida dice adesso *"Centra il viso nell'ovale"*: diceva *"nel cerchio"* e
  l'ha trovato l'anteprima.
- **Via il riquadro** *"Tutto resta sul tuo dispositivo..."*. **La garanzia
  resta**: il motore non importa nessun client di rete.
- **Via la bolla** *"Lega al cielo di oggi"* col suo interruttore e il suo
  testo. **Nessuna lettura cambia**: valeva spenta all'inizio e l'interruttore
  che lega il responso ai transiti vive già nel responso e resta.
- **L'immagine in alto**: un volto stilizzato coi tratti uniti in costellazione.
  È la sagoma e la costellazione che la funzione già disegna, non un disegno
  nuovo e sta per prima.
- Il disclaimer della funzione e la chiave iOS della fotocamera non sono stati
  toccati.

**Prova**: `la_costellazione_del_viso_si_capisce_e_parte_su_iphone_test.dart`,
**sette rosse sul codice di prima** e
`il_fotogramma_entra_come_la_piattaforma_lo_consegna_test.dart`, rossa con lo
specchio di iOS riacceso.

---

## DS.07, I PULSANTI DELLA CHAT

**Controllati: quattordici pulsanti, dei tre Maestri. Sbagliati: sei.**

| pulsante | apriva | cosa c'era di sbagliato |
|---|---|---|
| Caligo, *"Apri le rune"* | la Runa del Tramonto | **il difetto del fondatore**: è il dono del giorno, non l'Estrazione |
| Medora, *"Apri l'Arcano del Giorno"* per chi chiede l'oroscopo | l'Arcano del Giorno | si chiedeva l'oroscopo e si riceveva una carta, mentre l'Oroscopo esiste |
| Medora, *"Apri la stesa"* | *"Arriva presto"* | la Stesa si apre dallo scaffale |
| Aura, *"Apri la Costellazione del viso"* | *"Arriva presto"* | si apre dallo scaffale |
| Caligo, *"Apri il Sigillo"* | *"Arriva presto"* | il Sigillo dell'Intenzione si apre dallo scaffale |
| Aura, respiro e frequenze | la Meditazione | l'etichetta non diceva che apre la Meditazione |

**La causa non era un pulsante, era una mappa.** La chat aveva la sua tavola
delle destinazioni accanto a quella dello scaffale e le due si erano separate.
**Adesso la chat non nomina nessuna schermata**: ogni pulsante nomina un'arte e
la rotta la decide `artRouteFor`, la stessa funzione dello scaffale, con la
stessa nascita. **Dopo: quindici pulsanti, zero sbagliati.** Il quindicesimo è
la carta del giorno di DS.08.

I cinque pulsanti di arti che non esistono ancora, carta natale, chakra,
I-Ching, pendolo e candela, dicono che arrivano presto ed è vero.

**Sul telefono**: *"Tira le rune per me"* a Caligo, il pulsante *"Apri
l'Estrazione Rune"* e al tocco la schermata **Estrazione Rune** con le quattro
gettate, catture `07a` e `07b`.

**Prova**: `ogni_pulsante_della_chat_apre_cio_che_promette_test.dart`, rossa
sulle destinazioni vecchie scritte nella forma nuova.

---

## DS.08, LE RISPOSTE DI MEDORA

### Cosa c'era davvero dietro i cinque fatti

1. **"Carta del giorno" non consegnava nessuna carta.** Il suggerimento si
   chiama *"Tira una carta per me"* e la domanda andava nuda al modello: nessuna
   parola chiave la riconosceva. **Adesso la carta non la sceglie il modello**:
   è l'Arcano del Giorno, la stessa carta che il Dono mostra e il pulsante sotto
   la apre.
2. **Due letture opposte a due minuti.** Il modello gira a temperatura 0,9,
   senza seme e senza memoria del giorno. **La regola esiste**, ma non nella
   legge 6 di RETENTION, che dice *"Non si amputa, si mette in ordine"*: sta nel
   briefing operativo, sezione 15, *"la stessa domanda nello stesso giorno dà lo
   stesso responso"*. **Adesso la lettura già data si ridice**, dichiarandolo e
   il modello non si chiama.
3. **Il Primo quarto e la "luna crescente".** **Il punto 3 non è del modello.**
   *"Ripassa quando sarà luna crescente"* era una stringa dell'app, in
   `consiglio_finale.dart`, che guardava la fase di domani e la dava per futura
   anche quando era quella di oggi. In un anno, due volte al giorno, **la chiusa
   smentiva il calcolo 352 volte**.
4. **Il segno opposto fra tre giorni.** **Il punto 4 è un transito vero, letto
   male di un giorno.** Al modello arrivava il blocco calcolato *CIÒ CHE ARRIVA*
   e il 17 settembre alle 00:21 per un Sole in Cancro diceva *"Primo quarto: fra
   2 giorni"* e *"La Luna nel segno opposto: fra 3 giorni"*. La Luna entra in
   Capricorno il 19 alle 8, cioè fra due giorni e il Primo quarto comincia il 18
   alle 10, cioè domani. **La causa**: il motore guarda il cielo a mezzanotte e
   dava l'evento al giorno dopo quello in cui comincia. Misurato ora per ora,
   **205 eventi della Luna su 220 in tre mesi portavano la data sbagliata**;
   adesso 0. **E l'obiezione dell'ordine sui tredici giorni partiva da un'altra
   premessa**: vedi la sezione DOVE L'ORDINE SBAGLIAVA.
5. **La chiusa fissa.** Adesso dice **quando il cielo cambia davvero**, il
   prossimo ingresso della Luna o la prossima fase, calcolati: *"Rivediamoci fra
   2 giorni: la Luna entra in Capricorno"*, *"Ripassa fra 9 giorni, per la Luna
   piena"*. *"Quel che vedi cambia con lei"* se n'è andato: identico sotto due
   letture diverse, sembrava parlare di quelle.

**E il cielo detto dal modello si controlla.** `IlCieloDetto` legge nelle
risposte le affermazioni controllabili sulla Luna e le confronta col calcolo; una
frase smentita non arriva a schermo e si annota nel registro dei guasti. Al
modello arriva adesso anche **la Luna di oggi**, calcolata, accanto agli eventi
in arrivo: prima riceveva solo la fase lunare di nascita.

### Le tre letture della stessa domanda, per intero

Sul telefono 767f596c, 17 settembre 2026, fra le 03:21 e le 03:27, col modello
vero.

**Una premessa onesta sulla prima domanda.** La prima volta la domanda è arrivata
come *"TCosa mi dice il cielo oggi sul lavoro?"*, con una **T** in più lasciata
dalla tastiera durante l'inserimento via adb. L'app l'ha trattata come un'altra
domanda ed è giusto: le tre domande identiche sono la seconda, la terza e la
quarta. Per completezza, la risposta alla prima:

> Il cielo di oggi ti vede con la Luna in Sagittario, un transito che porta a
> guardare oltre i confini del noto.
>
> Per te, Gemelli, questo significa che nel lavoro potresti sentire un desiderio
> di espansione, di cercare nuove vie o di approfondire conoscenze che ti aprano
> orizzonti differenti. Osserva con attenzione le opportunità che si presentano,
> anche quelle che sembrano distanti dal tuo quotidiano.
>
> ✦ Il desiderio di espansione nel tuo lavoro è sostenuto dal transito della Luna
> in Sagittario. Rivediamoci fra 2 giorni: la Luna entra in Capricorno.

**Prima lettura**, domanda *"Cosa mi dice il cielo oggi sul lavoro?"*, il
modello chiamato:

> Un vento leggero soffia tra le stelle, portando un invito alla riflessione.
>
> Oggi, il cielo suggerisce che la tua mente, sempre attiva, possa trovare nuovi
> spunti nel lavoro se ti concederai un momento di pausa. La tua Luna di nascita,
> in fase Gibbosa calante, ti invita a discernere ciò che è essenziale da ciò che
> può essere lasciato andare. Non è il tempo di nuove iniziative, ma di
> raffinare le strategie.
>
> ✦ Valuta attentamente le priorità del tuo lavoro. Rivediamoci fra 2 giorni: la
> Luna entra in Capricorno.

**Seconda lettura**, stessa domanda, il modello non chiamato:

> Me l'hai già chiesto oggi. Il cielo di oggi non è cambiato: la lettura resta
> questa.
>
> Un vento leggero soffia tra le stelle, portando un invito alla riflessione.
>
> Oggi, il cielo suggerisce che la tua mente, sempre attiva, possa trovare nuovi
> spunti nel lavoro se ti concederai un momento di pausa. La tua Luna di nascita,
> in fase Gibbosa calante, ti invita a discernere ciò che è essenziale da ciò che
> può essere lasciato andare. Non è il tempo di nuove iniziative, ma di
> raffinare le strategie.
>
> ✦ Valuta attentamente le priorità del tuo lavoro. Rivediamoci fra 2 giorni: la
> Luna entra in Capricorno.

**Terza lettura**, stessa domanda: identica alla seconda, al carattere. Il
contatore è rimasto a *"Ti restano 48 domande ai Maestri su 50"*: le due
ridette non hanno consumato niente.

**Non si contraddicono perché sono la stessa lettura.** E un limite, detto: **una
domanda che differisce di un carattere è una domanda nuova**, come la prima con
la T. Non ho allargato la somiglianza, perché *"lui mi ama"* e *"lei mi ama"*
differiscono di un carattere e sono due domande diverse.

### La carta del giorno

*"Carta del giorno"* a Medora: *"La tua carta di oggi è La Giustizia: la
bilancia della verità. Resta la stessa fino a domani. Aprila e guardala per
intero."* Il pulsante apre l'Arcano del Giorno e la carta rivelata è **XI, La
Giustizia**: la stessa. Catture `08a`, `08b`, `08c`.

**Prove**: la carta del giorno nominata, su tre forme della domanda e uguale al
Dono (`intent_routing_test.dart`); la stessa domanda tre volte con una chiamata
sola e il giorno dopo una lettura nuova; la frase sul cielo smentita che non
arriva a schermo; `la_prossima_data_e_il_giorno_in_cui_comincia_test.dart` e
`il_cielo_detto_e_il_cielo_calcolato_test.dart`. **Tutte viste rosse prima della
cura.**

---

## DS.09, LA STESA

1. **L'immagine ripetuta.** Una figura è una famiglia di parole: *nodo* e
   *sciogliere* sono la stessa immagine, *muro* e *ostacolo* la stessa
   barriera. Il Consiglio si compone a pezzi e adesso **ogni pezzo sa quali
   figure hanno già detto gli altri**: se la forma che il filo sceglie ne
   ripete una, si prende la successiva della stessa tavola che non la ripete. Le
   letture che non incontravano una ripetizione restano identiche al carattere.
   **Su duemila Consigli, con e senza cielo, le figure ripetute fra due pezzi
   erano 708, sei delle quali la barriera del fondatore; adesso 0.**
2. **"che si sta sciogliendo".** La coda del transito si appendeva dopo il punto
   di nascita. Adesso segue l'aspetto: *"Oggi Venere forma al tuo Sole di
   nascita una quadratura che si sta sciogliendo"*. **Su 120 giorni i fatti del
   giorno ambigui erano 75; adesso 0.** Vale anche per le sei forme della frase
   dell'Oroscopo, che avevano lo stesso difetto.
3. **"E il cielo di oggi lo accompagna"** diventa *"Accanto a queste tre carte
   c'è il cielo di oggi."*

**Una grandezza cambiata prima di nascere**: la guardia contava le figure per
frase e un pezzo solo che riprende la sua parola, *"ha una radice. E la radice
è il Fante di Bastoni"*, sembrava una ripetizione. Adesso conta per pezzo.

### Dieci stese generate di fila, per intero

Col cielo vero del 17 settembre 2026 alle 00:37, sulla carta natale di prova
della guardia; argomenti a rotazione. Nessuna ripete una figura fra due pezzi.

#### Stesa 1

**Carte:** Nove di Spade, Nove di Coppe (rovesciata), L'Imperatrice.

**Titolo:** L'appagamento vuoto.

> È un attrito piccolo, di quelli che non si vedono da fuori e che rallentano tutto da dentro. Nel tuo quadro affettivo, il momento che le carte vedono ha un nome. Ed è Nove di Coppe rovesciato.
>
> Togli oggi l'intoppo più piccolo dei tre che hai in mente. Serve a togliere l'incertezza. E l'incertezza è la parte che stanca. La mossa che Nove di Coppe rovesciato suggerisce si può fare questa settimana.
>
> Quello che hai davanti oggi ha una radice. E la radice è Nove di Spade. Davanti a te c'è L'Imperatrice. Ed è una delle carte che si vogliono vedere in fondo a una lettura: quello che stai facendo porta lì. C'è un solo rovescio nella stesa: un punto che frena. E uno solo. Accanto a queste tre carte c'è il cielo di oggi. Oggi Saturno forma alla tua Luna di nascita una congiunzione che si sta sciogliendo. Nessuna di queste tre carte decide per te: mostrano il terreno. E il passo è tuo.
>
> Qual è la verità che stai rimandando di dirti?

#### Stesa 2

**Carte:** L'Imperatore, La Morte, Fante di Coppe.

**Titolo:** La fine che libera.

> La Morte è la carta che regge la tua lettura. Su cosa prova per te, è questo il punto da cui guardare. Racconta un pieno, non un vuoto. La domanda giusta non è cosa manca, è cosa farne.
>
> Segna il traguardo da qualche parte dove potrai ritrovarlo. Qui conta muoversi, non trovare il momento perfetto. Se La Morte è la carta del tuo presente, il passo è questo.
>
> Quello che hai davanti oggi ha una radice. E la radice è L'Imperatore. Chiude Fante di Coppe. Piccola, dritta. E con i piedi per terra. Tre carte dritte su tre. È una lettura pulita. E le letture pulite chiedono di essere prese sul serio. due Arcani Maggiori su tre carte sono tanti: quello che stai chiedendo tocca una cosa grande. Accanto a queste tre carte c'è il cielo di oggi. Oggi Saturno forma alla tua Luna di nascita una congiunzione che si sta sciogliendo. Prendi quello che ti serve e lascia il resto: una lettura serve a decidere, non a obbedire.
>
> Di cosa hai davvero bisogno, oltre a ciò che chiedi?

#### Stesa 3

**Carte:** Fante di Coppe, Sei di Spade, Il Mondo.

**Titolo:** La traversata calma.

> Parla di un passo che riesce, di quelli che non fanno rumore e che poi si vede che hanno spostato tutto. Al centro della tua lettura c'è Sei di Spade. Sul ritorno che aspetti, è lei a dare il tono a tutto il resto.
>
> Scegli una sola cosa fra quelle aperte e portala a termine. È la mossa che costa meno di tutte quelle che stai considerando. La mossa che Sei di Spade suggerisce si può fare questa settimana.
>
> Il futuro della lettura porta Il Mondo: qui non c'è niente da temere, c'è qualcosa da riconoscere. La lettura non parte da oggi. Parte da Fante di Coppe. Ed è lì che si capisce il resto. Nessun rovescio in questa stesa: quello che le carte dicono, lo dicono senza riserve. Accanto a queste tre carte c'è il cielo di oggi. Oggi Saturno forma alla tua Luna di nascita una congiunzione che si sta sciogliendo. Questa lettura indica una direzione, non un destino: la scelta resta tua.
>
> Di cosa hai davvero bisogno, oltre a ciò che chiedi?

#### Stesa 4

**Carte:** Il Diavolo (rovesciata), Regina di Denari (rovesciata), Re di Spade.

**Titolo:** La cura dispersa.

> È una carta minore al rovescio: il fastidio è reale e la sua misura è quella di un fastidio. Sulla fiducia in gioco, non c'è una risposta sola: c'è Regina di Denari rovesciata al centro. E il resto le gira intorno.
>
> Regina di Denari rovesciata porta con sé un compito. E il compito è breve. Rifai con calma il passaggio che la prima volta hai fatto di corsa. È la mossa che costa meno di tutte quelle che stai considerando.
>
> La casella del passato porta Il Diavolo rovesciato: è quello che hai già attraversato per arrivare qui. In fondo alla stesa c'è Re di Spade, che parla di cose che si vedono e si contano. È la parte di futuro su cui hai davvero presa. Più carte di traverso che dritte: il tempo di questa cosa non è ancora il tuo. E conviene saperlo adesso. Accanto a queste tre carte c'è il cielo di oggi. Oggi Saturno forma alla tua Luna di nascita una congiunzione che si sta sciogliendo. Torna a guardarla fra qualche giorno: quello che oggi sembra il punto principale spesso non lo era.
>
> Qual è la verità che stai rimandando di dirti?

#### Stesa 5

**Carte:** Due di Denari, Sei di Coppe, Asso di Denari.

**Titolo:** Il dono dell'infanzia.

> Sei di Coppe è la carta che regge la tua lettura. Sull'incontro che cerchi, è questo il punto da cui guardare. Parla di una porta socchiusa. Non si apre da sola, ma non è chiusa a chiave.
>
> Fissa tu la prima scadenza, prima che te la fissi qualcun altro. Qui conta muoversi, non trovare il momento perfetto. Se Sei di Coppe è la carta del tuo presente, il passo è questo.
>
> Chiude Asso di Denari. Piccola, dritta. E con i piedi per terra. Due di Denari racconta la strada fatta fin qui. Non è un rimprovero, è il filo. Nessun rovescio in questa stesa: quello che le carte dicono, lo dicono senza riserve. Accanto a queste tre carte c'è il cielo di oggi. Oggi Saturno forma alla tua Luna di nascita una congiunzione che si sta sciogliendo. Le carte dicono da dove soffia il vento. La rotta la tieni tu.
>
> Cosa puoi lasciare andare per fare spazio a questo?

#### Stesa 6

**Carte:** Tre di Bastoni (rovesciata), Cavaliere di Denari (rovesciata), Cinque di Bastoni.

**Titolo:** Il passo bloccato.

> Segnala uno spreco. Stai mettendo energia in un punto che non la restituisce. Sulla scelta fra i due, non c'è una risposta sola: c'è Cavaliere di Denari rovesciato al centro. E il resto le gira intorno.
>
> Togli oggi l'intoppo più piccolo dei tre che hai in mente. Da lì in poi la situazione smette di dipendere solo dall'attesa. Se Cavaliere di Denari rovesciato è la carta del tuo presente, il passo è questo.
>
> In fondo alla stesa c'è Cinque di Bastoni, che parla di cose che si vedono e si contano. È la parte di futuro su cui hai davvero presa. Il filo comincia da Tre di Bastoni rovesciato. Quello che vedi oggi è il suo seguito, non il suo contrario. Ci sono più rovesci che dritte. Non è un disastro: è una lettura che chiede di rallentare. Accanto a queste tre carte c'è il cielo di oggi. Oggi Saturno forma alla tua Luna di nascita una congiunzione che si sta sciogliendo. Il resto lo scrivi tu. E le carte lo sanno.
>
> Cosa puoi lasciare andare per fare spazio a questo?

#### Stesa 7

**Carte:** Regina di Spade, Asso di Spade, L'Eremita.

**Titolo:** La lama della verità.

> Parla di un passo che riesce, di quelli che non fanno rumore e che poi si vede che hanno spostato tutto. Sul lavoro che cerchi, il momento che le carte vedono ha un nome. Ed è Asso di Spade.
>
> Se traduci Asso di Spade in un gesto, viene fuori questo. Chiedi a voce quello che finora hai solo sperato ti venisse offerto. Finché resta nella testa è un pensiero; appena esce diventa una cosa che si può maneggiare.
>
> Davanti a te c'è L'Eremita. Ed è una delle carte che si vogliono vedere in fondo a una lettura: quello che stai facendo porta lì. Dietro Asso di Spade si vede Regina di Spade: una cosa è nata dall'altra. Nessun rovescio in questa stesa: quello che le carte dicono, lo dicono senza riserve. Accanto a queste tre carte c'è il cielo di oggi. Oggi Saturno forma alla tua Luna di nascita una congiunzione che si sta sciogliendo. Quello che hai letto vale finché non fai la prima mossa. Poi vale quello che hai fatto.
>
> Qual è la verità che stai rimandando di dirti?

#### Stesa 8

**Carte:** Cinque di Spade (rovesciata), Dieci di Denari (rovesciata), Sei di Coppe.

**Titolo:** Le radici da rassodare.

> Sulla tua crescita, non c'è una risposta sola: c'è Dieci di Denari rovesciato al centro. E il resto le gira intorno. Segnala uno spreco. Stai mettendo energia in un punto che non la restituisce.
>
> Dai trenta minuti a questa cosa, oggi. E non un minuto di più. Da lì in poi la situazione smette di dipendere solo dall'attesa. Ecco che cosa farne, stando a Dieci di Denari rovesciato.
>
> Il passato della lettura porta Cinque di Spade rovesciato. E spiega perché Dieci di Denari rovesciato si presenta proprio così. Alla fine c'è Sei di Coppe, una carta di mestiere. Il futuro qui è una conseguenza, non una sorpresa. Ci sono più rovesci che dritte. Non è un disastro: è una lettura che chiede di rallentare. Accanto a queste tre carte c'è il cielo di oggi. Oggi Saturno forma alla tua Luna di nascita una congiunzione che si sta sciogliendo. Questa lettura indica una direzione, non un destino: la scelta resta tua.
>
> Se il cielo inclina e non obbliga, qual è il primo passo che spetta a te?

#### Stesa 9

**Carte:** Cinque di Denari (rovesciata), Regina di Denari (rovesciata), Re di Coppe (rovesciata).

**Titolo:** La cura dispersa.

> Sul denaro che ti riguarda, la lettura si ferma su Regina di Denari rovesciata. Da lì parte tutto il resto. Dice che ti manca un'informazione, non una forza. Cercare batte insistere.
>
> Controlla la cosa più banale prima di cercare la causa complicata. Finché resta nella testa è un pensiero; appena esce diventa una cosa che si può maneggiare. Regina di Denari rovesciata non lascia il consiglio nel vago.
>
> Quello che hai davanti oggi ha una radice. E la radice è Cinque di Denari rovesciato. Alla fine arriva Re di Coppe rovesciato, una carta minore al rovescio: il fastidio è reale e la sua misura è quella di un fastidio. Ci sono più rovesci che dritte. Non è un disastro: è una lettura che chiede di rallentare. Accanto a queste tre carte c'è il cielo di oggi. Oggi Saturno forma alla tua Luna di nascita una congiunzione che si sta sciogliendo. Non c'è niente di scritto qui che tu non possa cambiare camminando.
>
> Cosa puoi lasciare andare per fare spazio a questo?

#### Stesa 10

**Carte:** Due di Denari, Otto di Spade, La Ruota della Fortuna (rovesciata).

**Titolo:** La prigione dei pensieri.

> Sulla decisione da prendere, la lettura si ferma su Otto di Spade. Da lì parte tutto il resto. È una carta di mestiere. Premia chi conosce il proprio lavoro. E tu lo conosci meglio di come lo racconti.
>
> Ecco che cosa farne, stando a Otto di Spade. Chiedi a voce quello che finora hai solo sperato ti venisse offerto. È il genere di gesto che non fa rumore e che poi si vede che ha spostato tutto.
>
> La Ruota della Fortuna rovesciata chiude la stesa con una prova. Le carte non dicono che finisce male: dicono che costa. Se guardi indietro trovi Due di Denari. E da lì si capisce perché oggi la lettura si ferma dove si ferma. C'è un solo rovescio nella stesa: un punto che frena. E uno solo. Accanto a queste tre carte c'è il cielo di oggi. Oggi Saturno forma alla tua Luna di nascita una congiunzione che si sta sciogliendo. Il resto lo scrivi tu. E le carte lo sanno.
>
> Qual è la verità che stai rimandando di dirti?

---

## LE GUARDIE

**Sei nuove nel registro**, 436 in tutto e due allargate. Tutte viste rosse sul
codice di prima; le righe del registro portano il come.

| guardia | cosa |
|---|---|
| `la_costellazione_del_viso_si_capisce_e_parte_su_iphone` | la catena del fotogramma per piattaforma e la soglia |
| `la_meditazione_parte_quando_lo_decidi` | nessun suono senza gesto, niente bolle, la frequenza sulle schede, il conto |
| `ogni_pulsante_della_chat_apre_cio_che_promette` | una porta sola per chat e scaffale |
| `la_prossima_data_e_il_giorno_in_cui_comincia` | la data degli eventi della Luna, ora per ora |
| `il_cielo_detto_e_il_cielo_calcolato` | la chiusa di Medora per un anno e il verificatore |
| `la_stesa_non_ripete_la_stessa_figura` | le figure per pezzo e la coda del transito |
| `accenti_veri`, allargata | le esenzioni sul contenuto |
| `i_manifesti_sono_sigillati`, allargata | tutti i manifesti, con la loro guardia |

Più le **diciotto guardie proprie dei manifesti**, che pretendono un valore e
non entrano nel conto del registro, come le altre guardie d'ordine. **Nessuna
riga aggiunta a `tool/rossi_accettati.txt`. Nessuna soglia abbassata.**

### Due guardie di casa rotte dal mio lavoro e riparate

Le ha trovate lo sbarramento, non una rilettura.

1. **`un_ripiego_non_costa_test.dart` si è appesa per venti minuti.** Padre:
   **ordine DS voce 08**. La prova brucia le domande del giorno mandando sempre
   *"ancora"*, finché non ne restano: da quando la stessa domanda nello stesso
   giorno è ridetta senza consumare, il ciclo non finiva più. **Non era un
   difetto dell'app, era la prova che contava su un comportamento cambiato
   apposta.** Adesso manda una domanda diversa a ogni giro e ha un tetto di cento
   giri, perché un ciclo che aspetta un conto non deve poter appendere lo
   sbarramento. Gli altri due cicli del genere, in `l_app_non_dice_il_falso`,
   consumano il conto direttamente e non mandano domande: sani.
2. **`le_lunghezze_dei_responsi_test.dart`, la tabella generata non tornava.**
   Padre: **ordine DS voce 09**. Il Consiglio dei Tarocchi è cambiato: mediana da
   829 a **842** caratteri, massimo fermo a **994**. Rigenerata; nessun tetto
   superato.
3. **Il cancello gratuito di GitHub è caduto sulla spinta di `eac1e559`**,
   prima ancora dello sbarramento. Padre: **ordine DS voce 06**. `flutter
   analyze` sull'intero progetto segnalava un'informazione, un import superfluo
   di `foundation.dart` nella prova dell'ingresso del fotogramma, e il passo di
   analisi esce con 1 anche per un'informazione. Io l'avevo fatto girare solo
   sulle cartelle toccate. Tolto l'import, l'analisi dell'intero progetto dice
   *No issues found*.

### L'esito dello sbarramento

Sul commit `ee85fe43`, prima della spinta: suite Flutter con **tre rossi**, due
dichiarati e voluti nei rossi accettati (*l'attribuzione cieca è valida su
QUESTA istruzione* e *le soglie delle quattro pose sono state misurate su un
telefono*) e uno solo nuovo, **"il ramo locale non ha commit che il remoto non
conosce"**, che si chiude spingendo; **le prove del server 98 su 98**; il
corredo a scala 1,3 con 182 schermate montate e i soli rossi già accettati.

**Rifatto dopo la spinta**, sul commit `eac1e559`: **solo rossi accettati,
l'archivio si produce**, gettone scritto per la build **2265** con **5.443
prove**; server 98 su 98.

**Una stesura mia che mentiva, rimediata prima di consegnare**: nel registro
avevo scritto *"figure ripetute in 704 Consigli"*; il numero misurato è 708
ripetizioni su duemila Consigli. Corretto.

---

## DOVE L'ORDINE SBAGLIAVA

1. **"docs/ordini contiene 91 manifesti."** Sono 88 prima di quest'ordine, 89
   con DS. Il file in più coi marcatori è il testo archiviato dell'ordine DB.
2. **"DICIANNOVE ordini non hanno una guardia propria", CX compreso.** Erano
   diciotto: CX non ha un manifesto e il suo debito è un altro.
3. **"RIPRESA.md è fermo al 12 settembre, all'ordine DG, col commit DG: la build
   sale a 2250."** Quel commit tocca solo `pubspec.yaml`; RIPRESA è fermo al 1
   settembre ed è un archivio chiuso per decisione scritta dal 24 agosto.
4. **"Il suono parte da solo appena si apre la schermata."** All'apertura non
   partiva; partiva al tocco di un sintomo o di una frequenza. La sostanza,
   *il suono parte senza che si sia detto comincia*, era vera.
5. **"La legge 6 del documento RETENTION vieta la ricompensa variabile sui
   responsi."** La legge 6 di RETENTION è *"Non si amputa, si mette in ordine"*
   e la ricompensa variabile in quel documento non compare. La regola vera sta
   nel briefing operativo, sezione 15.
6. **"Il segno opposto al Cancro è il Capricorno, e la Luna impiega circa
   tredici giorni ad arrivare all'opposto, non tre."** La frase di Medora non
   diceva che la Luna era in Cancro: il **Sole** del fondatore è in Cancro e il
   blocco calcolato parla del segno opposto **al Sole**. Il 17 settembre la Luna
   è in Sagittario e entra in Capricorno il 19. **Il numero giusto era due**, non
   tredici; il tre di Medora era sbagliato di un giorno e il difetto era vero, ma
   non quello che l'ordine descrive.
7. **Il punto 3 attribuito al modello, "due affermazioni astronomiche che si
   contraddicono fra loro".** La seconda affermazione, *"ripassa quando sarà luna
   crescente"*, non era del modello: era la chiusa scritta dall'app.
8. **"Nessuna immagine può ripetersi" come difetto del solo Consiglio della
   Stesa.** Vero e più largo: la coda *"che si sta sciogliendo"* si attaccava al
   punto di nascita anche nelle sei forme della frase dell'Oroscopo.
9. **"Un conto alla rovescia di cinque minuti."** Vero per la sessione del
   giorno; cinque pratiche su dodici dichiarano un'altra durata nella loro
   scheda e per quelle il conto segue la scheda.

---

## PER IL FONDATORE, DA DECIDERE

1. **DD e DN dichiarano il falso**: correggere i marcatori, o lasciarli come
   storia di quei giorni. Il sigillo cade quando cambiano, in tutti e due i casi.
2. **RIPRESA.md**: resta archivio chiuso, o torna vivo. E con lui
   `HANDOFF_FASE_C.md`, `STATO_ASSET.md` e il *"Checkpoint corrente: C1"* di
   `CLAUDE.md`, che nessuno aggiorna da luglio.
3. **CX non ha un manifesto.**
4. **DS.06 aspetta la cattura dal tuo iPhone**: la maschera dei punti accesa sul
   volto nella Costellazione del Viso, con la build Codemagic di quest'ordine.
