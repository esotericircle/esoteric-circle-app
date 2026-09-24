# ORDINE EK, LA BUILD SUBITO, MAESTRI DIRETTI, NOMI GIUSTI E VOLTI NITIDI

**Sigla:** EK, riverificata sul ramo il 24 settembre 2026: in `docs/ordini`
non c'era nessun `ORDINE_EK_*` e in `test/` nessuna `ordine_ek_guard`; il
ramo remoto era a `2aa35719`. **Data dell'ordine:** 25 settembre 2026. **Il
lavoro comincia il 24 settembre 2026 sull'orologio della macchina**: la data
dell'ordine e' un giorno avanti, ed e' dichiarata qui invece di corretta.
**Ramo:** `claude/esoteric-circle-master-order-e798aj`. Durante il lavoro il
fondatore ha scritto *"Approvo tutto e ti autorizzo a fare tutto, non fermarti
più e sistema tutto"* e *"Non devi lasciare nulla in coda"*: da li' anche i
guasti trovati fuori dal perimetro sono stati curati; **la seconda build,
la 2280, e' consegnata**: release `49fukh3t6c3n8`, con gli ordini EK ed EL
insieme.

**La fatturazione di Google Cloud si e' chiusa durante l'ordine.** Il 24
settembre 2026, fra le 15:43 e le 16:22 UTC: nei registri del server
l'ultima chiamata riuscita e' delle 15:43:12, la prima respinta con *"billing
is disabled for this project"* delle 16:22:23; in mezzo tace anche il
lavoro che gira ogni quindici minuti. `gcloud billing projects describe`
dice `billingEnabled: false`; il conto "Il mio account di fatturazione"
dice `open: false`. Da allora Vertex AI risponde 403, con
lui i Maestri, il LIVE, la trascrizione, le voci e la lettura dei consumi.
E' il credito di prova che CLAUDE.md dava in scadenza intorno al 23
settembre. **Il fondatore l'ha riaperta la sera stessa**: alle 17:31 UTC
`billingEnabled: true`, conto aperto, Flash e Flash-Lite di nuovo a HTTP 200
in europe-west1; le misure rimaste sul telefono sono state fatte dopo.

VOCI_TOTALI: 5
VOCI_CHIUSE: 2
VOCI_APERTE: 3

Le prove stanno in `docs/collaudo/EK/`.

---

## I FATTI VERIFICATI PRIMA DI SCRIVERE UNA RIGA, E GLI SCARTI FRA L'ORDINE E IL RAMO

I numeri di riga di questa sezione sono quelli del commit di partenza,
`2aa35719`, riletti con `git show`: da allora i file sono cambiati.

### 1. Medora non e' la meno diretta, misurata

L'ordine chiede perche' Medora *"resta la meno diretta"*. Nei tre giri
"prima" dell'ordine EK, sulla build 2279, le risposte non dirette sono state
Medora 3, 3 e 2 su 6, Calìgo 3, 3 e 2, Aura 1, 1 e 2. Nella prova per
esclusione, trenta risposte per voce, Medora e Aura hanno fatto 9 su 30
ciascuna e Calìgo 1 su 30. **Medora non e' la meno diretta: lo e' quanto gli
altri due**; la stessa istruzione ha dato 3 su 18 in un giro e 8 su 18 in un
altro. La causa trovata vale per tutti e tre: sta qui sotto.

### 2. Le regole che mettevano il cielo nella seconda frase

Il giudice della risposta diretta guarda le prime due frasi. Tre regole
nostre ci mettevano il simbolo:
`lib/services/ai/maestro_persona.dart` riga 232, *"La tua prima frase
risponde alla domanda. Il cielo o il simbolo vengono subito dopo"*; `lib/core/maestro/voce_del_maestro.dart` righe 307-311,
l'apertura di Medora, *"L'immagine celeste viene subito dopo, una sola riga"*;
le aperture di Aura e Calìgo, con il respiro e l'immagine di fuoco *"subito
dopo"*. Contraddicevano la regola comune *"Le prime due o tre frasi devono
reggere da sole"*. Con la prima stesura della cura quattro risposte bocciate
su dieci avevano una prima frase diretta seguita dal cielo.

### 3. "Una parola da portare" presa alla lettera

`lib/services/ai/maestro_persona.dart` riga 214: *"La tua chiusura NOMINA una
parola da portare"*. Serve all'Eco e resta; ma "da portare" faceva chiudere
portando qualcosa, *"Porta con te in riunione la consapevolezza che..."*,
*"Trova il tuo segno di Fehu e portalo con te"*: il giudice del passo
concreto le bocciava.

### 4. Il diario dell'Alba che Firestore rifiutava

`lib/core/rituals/arcano_dell_alba/diario_dell_alba.dart` riga 350 manda
`'registro': registro`, una lista di liste; Firestore la rifiuta con
*"Property arcanoDellAlba contains an invalid nested entity"*; con lei
cadeva `statoDelCerchio` intera dal 23 settembre 2026 alle 11:50 UTC, 182
cadute quel giorno e 18 il 24. Padre: ordine DU, commit `b8cf8106`.

### 5. La sessione di Protoface che non si chiudeva

Uscendo dal LIVE il telefono lasciava la stanza di LiveKit e nessuno chiamava
`POST /v1/sessions/{id}/end`, che la documentazione offre: la sessione restava
accesa fino al silenzio tollerato, 60 secondi. Sul registro del server 13
secondi a video sono stati fatturati 70, due crediti. Padre: ordine EG,
commit `1104da29` e `3687c223`.

### 6. Lo schermo che si spegneva durante il LIVE

Alla prova della voce 03 sul Realme lo schermo si e' spento da solo alle
13:24:05, cinque minuti dopo l'ultimo tocco, mentre Medora rispondeva: il
microfono e' andato a -100 decibel e il LIVE si e' chiuso dopo trenta secondi
di silenzio. La schermata non chiedeva di tenere acceso lo schermo
(`FLAG_KEEP_SCREEN_ON` su Android, `isIdleTimerDisabled` su iOS). Padre:
ordine EG, la schermata del LIVE.

### 7. Le immagini e il video

Le immagini caricate su Protoface erano davvero ingrandimenti: Medora da
847 x 1264 a 1700 x 1200 (3,49 volte), Calìgo da 848 x 1261 a 1700 x 1200
(3,17), Aura da 848 x 1261 a 1200 x 1200 (3,16). L'ordine dice il video
*"ingrandito da 3 a 4 volte sullo schermo"*: a 512 pixel e' 2,95 volte,
misurato nell'ordine EJ.

### 8. Il passo concreto non era in ogni risposta

L'ordine dice che restano *"i risultati già ottenuti in EJ: zero chiusure
ripetute, zero anticipazioni dei doni, il passo concreto in ogni
risposta"*. I primi due sono veri, il terzo no: nei tre giri "prima" le
risposte senza passo concreto sono state 5, 3 e 2 su 18
(`docs/collaudo/EK/risposte/prima1/_conto.txt` e seguenti); il rapporto EJ
diceva *"Il passo concreto c'e' quasi sempre"*
(`docs/ordini/RAPPORTO_ORDINE_EJ.md`, voce EJ.06).

### 9. L'attribuzione cieca non giudica le risposte del collaudo

L'ordine chiede il giro *"sulle risposte dopo il lavoro della voce 02"*.
`tool/attribuzione_cieca.dart` non legge risposte gia' scritte: pone le sue
venti domande neutre ai tre Maestri con l'istruzione vera dell'app e fa
giudicare quelle. Il giro e' stato fatto sull'istruzione dopo la voce 02,
che e' cio' che la misura puo' dire.

### 10. Una nuova allucinazione della trascrizione, figlia della cura dei nomi

Sul Realme, con la cura della voce 03, un pezzo di frase ancora in ascolto
e' stato trascritto *"Medora Aura Calìgo"*: il modello ha scritto l'elenco
dei nomi dell'istruzione invece di cio' che sentiva. Padre: ordine EK voce
03, `lib/services/voce/l_orecchio_del_live.dart`, l'elenco dei nomi
nell'istruzione. La cura sta nella voce 03.

### 11. L'attribuzione cieca non era piu' fra i rossi accettati

L'ordine dice che l'attribuzione cieca *"resta fra i rossi accettati"*. Sul
ramo non c'era piu': l'ordine EJ aveva tolto la riga *"l'attribuzione cieca
e' valida su QUESTA istruzione"* da `tool/rossi_accettati.txt`, riga 26, col
commit `8aa44dcd`, perche' la misura era tornata sopra la soglia. Riportare
`attribuzioneValida` a falso avrebbe scritto il falso in un dato, cosa che
`lib/services/ai/impronta_dell_istruzione.dart` vieta per costruzione: la
volonta' del fondatore sta in un rosso nuovo, che dice il vero (voce 05).

---

## VOCE EK.01, LA BUILD SUBITO

**Fatto.** Build **2279** col lavoro dell'ordine EJ, dal commit `b8b4a6a7`,
consegnata su App Distribution il 24 settembre 2026, release
`6gqoq7qjcg7eg`. Sbarramento passato con 5.823 prove e i soli rossi
dichiarati; prova di accensione sul Realme passata (processo vivo, primo
fotogramma disegnato, nessun crash); note rilette dal server in Unicode;
un invito accettato. Detta al fondatore nello stesso messaggio. Registro
`docs/versione_distribuita.json` e note nel commit `76be6933`, spinto e
verificato con `ls-remote`.

**CHIUSA.**
DOMANDA: "Sì, build subito"
PROVA: docs/collaudo/EK/consegna_2279.txt
MISURA: build 2279, release 6gqoq7qjcg7eg, inviti accettati 1, prova di accensione passata, sbarramento a 5823 prove

## VOCE EK.02, I MAESTRI SEMPRE DIRETTI

**La domanda.** *"Ho sempre detto che le persone VOGLIONO RISPOSTE DIRETTE,
NON VOGLIONO GIRI DI PAROLE DOVE ALLA FINE NON VIENE DETTO NULLA!"*

**Il metro.** Lo stesso di EJ: `tool/collaudo_ej.dart`, lanciato con
`--dart-define=ORDINE=EK`, le stesse sei conversazioni per Maestro, la stessa
persona (Ascendente Gemelli, Sole in Cancro, numero della vita 3), gli
stessi giudici di `tool/giudici_ej.dart` (`gemini-2.5-flash`, ragionamento
512, a maggioranza su tre). Una risposta e' diretta se le prime due frasi
dicono alla persona, in modo specifico per quella domanda, che cosa fare,
che cosa succedera' o che cosa significa. Diciotto risposte per giro.

**I conti, giro per giro e Maestro per Maestro** (non dirette su 6 per
Maestro; poi, su 18, le risposte senza passo concreto e i dati della persona
ripetuti; chiusure ripetute, anticipazioni dei doni, frasi vietate ed errori
di regola sono zero in tutti i giri):

| giro | istruzione | Medora | Aura | Calìgo | non dirette | senza passo | dati ripetuti | grammatica |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| prima1 | build 2279 | 3 | 1 | 3 | 7 | 5 | 3 | 1 |
| prima2 | build 2279 | 3 | 1 | 3 | 7 | 3 | 1 | 1 |
| prima3 | build 2279 | 2 | 2 | 2 | 6 | 2 | 5 | 0 |
| dopo1 | prima stesura | 0 | 1 | 1 | 2 | 0 | 5 | 0 |
| dopo2 | prima stesura | 2 | 1 | 0 | 3 | 0 | 2 | 0 |
| dopo3 | prima stesura | 1 | 0 | 1 | 2 | 3 | 4 | 1 |
| dopo4 | seconda stesura | 0 | 0 | 0 | 0 | 0 | 14 | 0 |
| dopo5 | seconda stesura | 1 | 0 | 1 | 2 | 0 | 5 | 0 |
| dopo6 | seconda, ritoccata | 0 | 1 | 1 | 2 | 4 | 6 | 2 |
| dopo7 | seconda, ritoccata | 0 | 2 | 0 | 2 | 0 | 1 | 0 |
| dopo8 | seconda, ritoccata | 1 | 0 | 3 | 4 | 2 | 7 | 1 |
| dopo9 | terza stesura, tolta | 0 | 1 | 1 | 2 | 1 | 2 | 0 |
| dopo10 | terza stesura, tolta | 0 | 0 | 1 | 1 | 1 | 5 | 1 |
| dopo11 | terza stesura, tolta | 4 | 2 | 0 | 6 | 0 | 3 | 1 |

**L'istruzione finale e' la seconda stesura ritoccata**, giri dopo6, dopo7 e
dopo8: 2, 2 e 4 risposte non dirette, **8 su 54 contro 20 su 54 prima**;
Medora 0, 0 e 1, Aura 1, 2 e 0, Calìgo 1, 0 e 3. Senza passo concreto 6 su
54 contro 10; dati ripetuti 14 contro 9; errori di grammatica 3 contro 2.

Le risposte per intero, giro per giro, stanno in
`docs/collaudo/EK/risposte/<giro>/`, col conto in `_conto.txt`.

**Perche' le risposte non erano dirette, con il file e la riga.** Non una
causa di Medora: una causa comune, le tre regole dello scarto 2 che
mettevano il cielo o il simbolo nella seconda frase, che e' proprio quella
che il giudice legge. La prima stesura le ha tolte: le prime due frasi
rispondono, il cielo viene dopo a dire perche'. Da 20 su 54 a 7 su 54.
La seconda stesura ha tolto il "subito dopo" dalle aperture di Aura e
Calìgo, ha dato a Medora un esempio che parla d'altro (un esempio sullo
stesso tema viene ricopiato alla lettera: *"Domani ascolta più di quanto
parli"* tornava identico) e ha fatto della chiusura un'azione nel mondo:
*"Riflettere, esaminare, visualizzare o immaginare non sono azioni"*. Il
ritocco ha tolto al perche' di Medora i dati natali (*"il transito o la fase
del momento spiegano perché"*), perche' nel primo giro della seconda stesura
nominava l'Ascendente o il Sole in ogni risposta.

**La terza stesura e' stata provata e tolta.** Diceva cio' che il giudice
misura e l'istruzione non diceva, *"Una frase che andrebbe bene per chiunque
non risponde"*, nella riga comune dell'apertura; toglieva anche a Calìgo la
parola "sentenze", che in italiano vuol dire anche massima. Tre giri: 2, 1 e
6, cioe' 9 su 54 contro 8. Non migliorava; in dopo11 Medora ha aperto
quattro volte su sei commentando la situazione (*"Il tuo lavoro richiede un
impegno che va oltre la semplice esecuzione"*): la riga nuova le chiedeva di
nominare cio' di cui la persona parlava: lei lo nominava invece di
rispondere. Aggiungere istruzioni non cura: tolta; ripristinata la seconda
stesura ritoccata byte per byte (blob `ca0817c5`, lo stesso misurato dai
giri dopo6-8 e dall'attribuzione cieca).

**Il rumore fra un giro e l'altro e' grande quanto le cure.** La stessa
istruzione ha dato 0 e 2 (dopo4, dopo5), 2, 2 e 4 (dopo6-8); la terza 2, 1 e
6. Con diciotto risposte per giro una cura che sposta una o due risposte non
si distingue dal caso; si distingue solo la prima, da 20 a 7 su 54.

**Cio' che resta.** Due conversazioni tornano bocciate in quasi tutti i
giri: Aura su *"Faccio fatica a dormire, penso sempre al lavoro"*, che apre
dalla diagnosi dei centri (*"l'energia è concentrata nella corona"*) invece
che dal che cosa fare; Calìgo su *"Ho paura di sbagliare e di pentirmene"*,
che apre con una massima (*"Non temere l'errore."*). Sono domande che non
chiedono niente in modo esplicito: il Maestro risponde all'emozione.

**"Senti il calmo del tuo respiro" entra nel controllo della lingua**:
`tool/controlli_ej.dart`, la regola `calmo`, provata in
`test/i_controlli_ej_prendono_i_difetti_test.dart` su due frasi sbagliate e
una giusta. Nelle 252 risposte dei giri dell'ordine EK non e' comparso, ne'
prima ne' dopo.

**APERTA.** Lo zero non c'e': nei tre giri dell'istruzione finale le
risposte non dirette sono 2, 2 e 4 su 18; l'ultimo giro ne ha 4, una di
Medora e tre di Calìgo. Dei risultati di EJ restano zero chiusure ripetute e
zero anticipazioni in tutti i quattordici giri; il passo concreto in ogni
risposta non c'era nemmeno prima (scarto 8) e resta assente in 6 risposte su
54. Per arrivare a zero non basta riscrivere l'istruzione: servirebbe un
controllo dopo la risposta, che la faccia riscrivere quando le prime due
frasi non rispondono. Costa una chiamata in piu' in circa una risposta su
sette e qualche secondo di attesa in quelle; la scelta e' del fondatore.

## VOCE EK.03, I NOMI GIUSTI NELLA TRASCRIZIONE DEL LIVE

**La domanda.** Il rapporto EJ: *"la trascrizione del LIVE ha scritto
"Mezz'ora" invece di "Medora""*; il fondatore: *"è Calìgo e non Càligo"*.

**Il metro.** Sei frasi con diciannove nomi (i tre Maestri, arcani, rune,
segni e chakra), dette dal portatile al Realme con la voce italiana di
Windows, nel LIVE di Medora; si leggono le righe *"LIVE: frase ...
trascritta"* del registro del telefono.

**Prima, sulla 2279: 7 nomi giusti su 19**
(`docs/collaudo/EK/nomi/prima_2279.txt`): "Nei giorni d'oggi" per Medora,
"Canigo" per Calìgo, "Laura" per Aura, "Vicenza" per Vishuddha.

**La prima cura**: chi trascrive riceve i nomi dei Maestri e delle arti,
presi dai cataloghi dell'app (`LaTrascrizione.nomiDelleArti`). Sulla 2280
di prova, ancora su Flash-Lite: **15 su 19**
(`docs/collaudo/EK/nomi/dopo_2280_flash_lite.txt`). Ma un pezzo di frase
ancora in ascolto e' tornato *"Medora Aura Calìgo"* (scarto 10).

**Il banco** (`docs/collaudo/EK/nomi/banco_orecchio.txt`, stessi audio e
stessa istruzione del telefono, due giri per modello): Flash-Lite ha
risposto con l'elenco intero dei nomi, settantadue, al posto della frase in
due frasi su sei, ha scritto "Medora" su tre secondi di fruscio e "Ariete"
dentro una frase interrotta; **Flash nessuna delle tre cose, 42 nomi giusti
su 44 contro 40, tempo mediano 1.060 ms contro 1.161**. La seconda cura: la
trascrizione la fa Flash, che sta nella regione dei dati; una trascrizione
fatta solo di tre o piu' nomi consecutivi dell'elenco vale come silenzio;
"Caligo" e "Càligo" diventano "Calìgo".

**La musica sotto il LIVE.** Alla prova finale nessuna frase si chiudeva:
l'orecchio segnava "parlato" di continuo. Il fondatore: *"il rumore di
fondo è anche la musica di sottofondo dell'app"*. Sul Realme il lettore
della musica ha suonato dalle 15:47:13 alle 15:57:33 (ora del telefono,
UTC+2), attraverso il LIVE delle 15:49: `SchermataLive` non e' fra i nomi che la regia della musica
riconosce (`lib/features/shell/quale_musica_suona.dart`), quindi sotto il
LIVE suonava la traccia del Maestro: il microfono la sentiva come una
persona che parla. Padre: ordine EG, la schermata del LIVE. Curato come il
velo dell'intro: `liveCheZittisce`, alzato dal LIVE quando si apre e lasciato
cadere quando si chiude. Le altre prove fallite erano voci nella stanza:
adesso la sessione di prova aspetta il silenzio prima di ogni frase.

**Dopo, sulla 2280 con tutte le cure:** una frase sola, prima che la
fatturazione di Google Cloud si chiudesse
(`docs/collaudo/EK/nomi/finale_2280.txt`). Alle 14:59:30 UTC la frase 1 e'
tornata *«Medora, ho pescato la Torre e poi l'Appeso. Cosa vogliono dire per
me?»*, tre nomi su tre (con Flash-Lite erano gia' tre su tre, sulla 2279 uno
su tre). Le altre cinque frasi non si sono potute dire: alle 14:58:45 UTC il
fondatore ha chiesto il telefono e il portatile (*"mettiti in pausa, ho
bisogno di cell e pc"*); alla ripresa, alle 16:24 UTC, Vertex AI
rispondeva gia' 403, *"This API method requires billing to be enabled"*, mentre
il LIVE sul Realme mostrava *«La voce non arriva, stasera»*.

**Dopo la riapertura della fatturazione**, due prove sul Realme.

La prima (`docs/collaudo/EK/nomi/riaperta_2280.txt`, 17:35 UTC) ha misurato
**la musica nel LIVE**: nessuna traccia di musica dell'app finche' il LIVE e'
a schermo, la musica di nuovo sei secondi dopo l'uscita. E ha trovato **un
difetto dell'orologio del silenzio**: la frase detta 28 secondi dopo il
saluto si e' trascritta in 1,6 secondi, quei secondi contavano come
silenzio, e a 30 il LIVE si e' chiuso 134 millisecondi prima che la domanda
tornasse scritta. Padre: ordine EJ voce 01, commit `5b160747`. Curato col
commit `61c937cb`: la regola sta in `QuadroDelLive.eUnSecondoDiSilenzio`, e
la schermata conta le frasi in trascrizione in un `finally`.

La seconda (`docs/collaudo/EK/nomi/cura_silenzio_2280.txt`, 18:54-19:01
UTC), con la cura dentro: **18 nomi giusti su 19**. Medora 2 su 2 e Calìgo 2
su 2 con l'accento, tutti gli arcani, le rune, i segni e i chakra; **Aura
scritta "Laura"**, una volta su una. Dopo il saluto 30,6 secondi di voci
nella stanza e il LIVE e' rimasto aperto; la musica spenta nel LIVE e di
nuovo accesa all'uscita, come nella prima.

**APERTA.** Le due segnalazioni del fondatore sono risolte: Medora non e'
piu' "Mezz'ora" e Calìgo ha il suo accento. Ma la voce chiede anche Aura, e
Aura e' stata scritta "Laura". Non c'e' una correzione a macchina:
"Laura" in apertura di frase puo' essere una persona vera di cui si parla.
La scelta e' del fondatore: una prova con la sua voce, perche' quella di
prova e' la voce sintetica di Windows, o una regola solo per il LIVE di
Aura.

## VOCE EK.04, LE IMMAGINI DEI MEZZIBUSTI

**Gli originali.** Riconosciuti con SIFT fra ogni immagine della cartella del
fondatore e quella caricata su Protoface:

| Maestro | originale | caricata su Protoface | ingrandimento |
| --- | --- | --- | ---: |
| Medora | `Ok/Medora-1.png`, 847 x 1264 | `Protoface/Medora-Protoface.png`, 1700 x 1200 | 3,49 |
| Calìgo | `Ok/Caligo-1.png`, 848 x 1261 | `Protoface/Caligo-Protoface.png`, 1700 x 1200 | 3,17 |
| Aura | `Ok/Aura/Aura-1.png`, 848 x 1261 | `Protoface/Aura-Protoface.png`, 1200 x 1200 | 3,16 |

Le versioni HD della cartella `Ok` sono ingrandimenti degli stessi
originali: piu' pixel, nessun dettaglio in piu'.

**Il restauro.** Imagen 4 upscale non e' accessibile al progetto (404 in
europe-west1, us-central1 e global). Usato `gemini-3-pro-image` su Vertex AI,
endpoint global, uscita 4K, con gli attributi di ciascun Maestro scritti
nella richiesta perche' non cambino, poi riallineato con SIFT alla tela
caricata. Medora al secondo tentativo (il primo cambiava gli occhi e il
diadema, scartato), Calìgo e Aura al primo. Quattro chiamate in tutto.

**L'inquadratura B e gli avatar nuovi.** Il fondatore ha approvato Medora e
l'inquadratura quadrata. Da ogni tela restaurata un quadrato testa e spalle
(Medora 1100, Calìgo 1275, Aura 1060 pixel di lato); con un'immagine
quadrata il video di Protoface e' il quadrato stesso. Creati su Protoface
dalla porta `gliAvatarNuoviDiProtoface`, chiusa dall'IAM (la chiave resta
sul server) e agganciati a `configurazione/live.avatar` solo da pronti:
Aura `av_01M39N47R0743K6EJJMQR76XZ0` e Calìgo `av_01M39N4G8A4YJAEBX34BSDHB82`
alle 12:39:06 UTC, Medora `av_01M39QP0C5N598DQZHG77PJGDR` alle 12:55:31 UTC.
L'app riconosce dalla sessione quale avatar le arriva e sceglie
l'inquadratura giusta (`InquadraturaDelVolto.di`); gli avatar di prima
restano su Protoface e nel codice come ripiego.

**Il buco sulla spalla di Medora.** Il primo avatar quadrato di Medora,
`av_01M39N3ZQ0EA9YT3P1Y6JQS9NS`, sul Realme aveva una macchia nera sulla
spalla sinistra in 4 catture su 4: un bianco puro chiuso nel bordo dorato
del manto, che il filtro del LIVE toglie come fondo. Curato nell'immagine
(1.019 pixel ridipinti coi colori attorno), avatar rifatto e riagganciato:
la macchia manca in 4 catture su 4. Padre: ordine EK voce 04.

**La misura sul Realme** (quattro catture per Maestro e per fase,
`docs/collaudo/EK/volti/misure.txt`):

| Maestro | pixel del video sul volto, prima | dopo | per lato | video -> schermo, prima | dopo |
| --- | ---: | ---: | ---: | ---: | ---: |
| Medora | 78 x 66 | 121 x 102 | 1,55 | 2,88 | 2,26 |
| Calìgo | 93 x 51 | 124 x 68 | 1,33 | 2,92 | 2,26 |
| Aura | 107 x 73 | 121 x 82 | 1,13 | 2,23 | 2,26 |

**Quanto puo' migliorare, con onesta'.** Il video resta di 512 pixel e
nessuna immagine lo cambia: si puo' solo dare al volto una parte piu' grande
di quei 512, ed e' cio' che fa l'inquadratura B piu' del restauro. Medora e
Calìgo guadagnano molto, Aura poco perche' era gia' quadrata. Per mostrare il
volto largo 275 pixel di schermo senza ingrandire il video servirebbe piu'
del doppio dei pixel di oggi: un'inquadratura quasi solo sul volto, o un
video piu' grande che Protoface non offre. **Il file delle voci,
`Protoface-Addestreamento- Avatar.txt`, non e' stato toccato.**

**APERTA IN ATTESA DI VERIFICA.** Le immagini, gli avatar e l'aggancio sono
fatti e misurati sul Realme; se il volto nel LIVE e' piu' nitido lo giudica
il fondatore guardandolo, dalla build 2280.

## VOCE EK.05, UN ALTRO GIRO DELL'ATTRIBUZIONE CIECA

**Fatto sull'istruzione finale della voce 02.** `tool/attribuzione_cieca.dart`,
tre esecuzioni una dopo l'altra alle 12:55, 12:55 e 12:56 UTC: le venti
domande neutre dello strumento ai tre Maestri con l'istruzione vera
dell'app, sessanta risposte per giro scritte ogni volta da capo
(temperatura 0,9), un giudice che non sa chi le ha scritte. La stringa
misurata e' quella finale: il blob `ca0817c5` di `voce_del_maestro.dart` e
`maestro_persona.dart` del commit `a936c133`, le cui impronte stanno adesso
in `lib/services/ai/impronta_dell_istruzione.dart`.

| giro | attribuzione corretta | Medora | Aura | Calìgo |
| --- | ---: | ---: | ---: | ---: |
| 1 | 58 su 60, 96,7 per cento | 20 | 20 | 18 (2 creduto Aura) |
| 2 | 57 su 60, 95,0 per cento | 17 (3 creduta Aura) | 20 | 20 |
| 3 | 58 su 60, 96,7 per cento | 20 | 20 | 18 (2 creduto Aura) |

Media 96,1 per cento, 173 su 180, nessun verdetto illeggibile; nell'ordine
EJ 95,0, 100,0 e 91,7, media 95,6. Il giro piu' basso sale da 91,7 a 95,0.
Nel secondo giro una risposta di Medora apriva con *"Ascolta il tuo respiro
per ritrovare la direzione che cerchi"*: il respiro e' di Aura: il giudice
l'ha data a lei.

**Resta fra i rossi accettati, come vuole il fondatore, senza mettere il
falso in un dato.** `attribuzioneValida` resta vera, perche' la misura e'
valida e passa la soglia; la decisione del fondatore sta in un campo nuovo,
`ImprontaDellIstruzione.chiusaDalFondatore`, falso; sta anche nella prova
*"l'attribuzione cieca l'ha chiusa il fondatore"*, rossa per costruzione e
scritta in `tool/rossi_accettati.txt` (scarto 11). Si spegne quando il
fondatore la chiude in un ordine.

**CHIUSA.**
DOMANDA: "Ancora un giro"
PROVA: docs/collaudo/EK/attribuzione/giro_1.txt
MISURA: attribuzione corretta sull'istruzione finale 58, 57 e 58 su 60 (96,7, 95,0 e 96,7 per cento, media 96,1), contro 57, 60 e 55 su 60 dell'ordine EJ (95,0, 100,0 e 91,7, media 95,6); giro piu' basso da 91,7 a 95,0

---

## FUORI DALLE VOCI: IL LAVORO CHIESTO DURANTE L'ORDINE

**Le voci dei Maestri, scelte dal fondatore.** Durante l'ordine il
fondatore ha scritto *"vorrei un selettore con le voci in modo che posso
sceglierle io. Quelle sentite finora fanno schifo"*; poi *"Prova ad
aggiungere anche le voci Chirp nel selettore"*. Non e' una voce dell'ordine
e non cambia i conti qui sopra.

- La pagina "Le voci dei Maestri",
  https://claude.ai/artifact/7xJ4NGT3tcVTGjB9C6dboQ: tutte le voci di
  Gemini-TTS del genere del Maestro (quattordici femminili per Medora e Aura,
  sedici maschili per Calìgo), ciascuna sulla frase del Maestro con Flash e
  con Pro, 88 campioni; la scelta e una nota per Maestro si salvano nella
  pagina e le legge Claude. Alle 16:50 UTC del 24 settembre nessuna scelta
  salvata.
- Il server, commit `d7d98447`, pubblicato alle 15:23 UTC: le candidate sono
  tutte le voci del genere del Maestro (`LE_VOCI_DI_GEMINI` e `LE_CANDIDATE`
  in `functions/src/live.ts`); il modo chiede la pronuncia di una madrelingua
  italiana e una calma naturale al posto di *"a ritmo sciolto e spedito"*; il
  modello si sceglie per Maestro in `configurazione/live.modelliDellaVoce`
  fra `gemini-2.5-flash-tts` e `gemini-2.5-pro-tts`: vale solo se e' fra i
  due. Pro e' entrato in `lib/core/config/la_regione_dei_dati.dart` dopo una
  chiamata vera in europe-west1 (primo suono a flusso 1,06-1,13 secondi,
  Flash 0,66-0,75); la guardia della regione l'ha visto rosso prima che ci
  entrasse. Le prove del server sono 123, verdi; le due nuove viste rosse con
  due innesti.
- Il modo nuovo parla piu' lento, misurato sulla stessa voce e sulla stessa
  frase, un campione ciascuno, dal primo all'ultimo suono (soglia al 2 per
  cento del massimo): Medora Sulafat 9,5 caratteri al secondo contro 10,1
  del modo di prima, Aura Autonoe 10,9 contro 13,6, Calìgo Algenib 8,5
  contro 9,1. Il 23 settembre il fondatore aveva trovato *"rallentata
  parecchio"* una voce a 8,0. La pagina fa sentire lo stesso modo del LIVE:
  il giudizio sul ritmo e' del fondatore.
- Chirp: l'API Text-to-Speech, rifiutata a fatturazione chiusa con
  *"UREQ_PROJECT_BILLING_NOT_OPEN"*, e' stata accesa dopo la riapertura.
  **Le Chirp 3 HD non stanno nella regione dei dati**: in europe-west1 la
  sintesi risponde *"Voice it-IT-Chirp3-HD-Aoede not found"*, le trenta
  voci italiane rispondono su "eu" e "global". In europe-west1 ci sono solo
  tre **Chirp HD**: D maschile, F e O femminili. Sulla pagina 49 campioni in
  piu', le Chirp 3 segnate *"Chirp 3 · eu"* e le Chirp HD *"nella regione
  dei dati"*. Il LIVE parla ancora solo con Gemini: la strada per Chirp
  si scrive quando il fondatore sceglie, e per una Chirp 3 serve prima il
  suo si' a un'eccezione alla regola dei modelli nella regione dei dati.

**Il cancello che cadeva a macchina ferma.** La prova
`il_cancello_aspetta_il_limite` ha letto due volte 82 secondi invece di 92:
`tool/il_cancello_ha_detto_verde.sh` sceglieva Python provando anche il
rimando `python3` del negozio di Windows, che senza console impiega 3,1
secondi a uscire con errore. Adesso il rimando, che sta sempre in
`WindowsApps`, non si prova (commit `335b0126`). Padre: ordine CODEMAGIC2,
commit `a216d443`; il 24 settembre mattina lo stesso codice passava.
