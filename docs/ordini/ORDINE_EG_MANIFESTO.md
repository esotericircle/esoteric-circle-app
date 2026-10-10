# ORDINE EG, IL LIVE DEI MAESTRI: IL NOSTRO CERVELLO, IL VOLTO DI PROTOFACE, LA VOCE A SCELTA

**Sigla:** EG, riverificata sul ramo il 23 settembre 2026: in `docs/ordini`
non c'e' nessun `ORDINE_EG_*`, in `test/` nessuna `ordine_eg_guard`, e
**nessun file del repo nomina un ordine EG** (ricerca su `docs/`, `test/`,
`lib/`, `tool/`, `functions/`: zero righe). **Data:** 23 settembre 2026.
**Ramo:** `claude/esoteric-circle-master-order-e798aj`. Parte dal commit
`a088a3da`, l'ordine EF chiuso e spinto.

VOCI_TOTALI: 9
VOCI_CHIUSE: 2
VOCI_APERTE: 7

Il rapporto stara' in `docs/ordini/RAPPORTO_ORDINE_EG.md`.

---

## COME SI ATTACCA, DECISO DAL FONDATORE

L'ordine vale **quindici-venticinque ore**, cioe' piu' sessioni di lavoro: una
funzione nuova sul server, una dipendenza nativa nuova, cinque motori di voce,
quindici scelte di voce, una schermata nuova, i contatori dei minuti, e tre
Maestri per cinque motori in sessioni vere sul telefono con otto stati da
catturare.

Messo davanti alla scelta il 23 settembre 2026, il fondatore ha risposto
**"Prima una fetta verticale che funziona"**: un Maestro solo e un motore
solo, in una sessione vera sul telefono, dal server fino ai sottotitoli.
**Tutti i rischi veri stanno in quella fetta**: se la catena regge, le altre
quattordici combinazioni sono ripetizione; e se l'illusione non convince, non
si e' costruita quindici volte la cosa sbagliata.

---

## I FATTI VERIFICATI PRIMA DI SCRIVERE UNA RIGA

### 1. Le chiavi ci sono gia', e la voce 07 e' quasi tutta fatta

In Secret Manager del progetto `esoteric-circle` esistono, con una versione
abilitata ciascuna:

| segreto | creato |
|---|---|
| `PROTOFACE_API_KEY` | 2026-09-22T15:49:02 |
| `LIVEKIT_URL` | 2026-09-22T16:01:43 |
| `LIVEKIT_API_KEY` | 2026-09-22T16:02:20 |
| `LIVEKIT_API_SECRET` | 2026-09-22T16:02:52 |

Letto con `gcloud secrets versions list`, **senza leggere nessun valore**.

### 2. La premessa dell'ordine regge

`docs.protoface.com`, pagina d'apertura, letta il 23 settembre 2026:

> *"Protoface Realtime adds a realtime face to your voice agent, **driven by
> the audio it already produces**. It works across languages and with any
> pipeline, whether speech-to-speech or separate STT, LLM, and TTS."*

**Il cervello resta nostro e Protoface mette il volto**, esattamente come la
voce 01 pretende.

### 3. SCARTO SULLA DOCUMENTAZIONE, E CAMBIA L'ARCHITETTURA

L'ordine lascia intendere che la sessione LiveKit la governi Protoface.
`docs.protoface.com/api-reference/sessions/create-a-session` dice il
contrario:

> *"The customer owns the room and mints `worker_token`; **we never touch
> their LiveKit API key or secret**. The worker publishes `protoface-avatar`
> video and `protoface-avatar-audio` output tracks."*

**La stanza e' nostra e il gettone del lavoratore lo firmiamo noi**, dal
server. Protoface entra nella nostra stanza come partecipante. Questo non
toglie niente alla regola dei segreti: anzi, aggiunge un secondo segreto che
non deve mai lasciare il server, perche' **chi ha la chiave di LiveKit puo'
entrare in qualunque stanza**.

### 4. Del LIVE non esiste niente

Nessun file di `lib/`, `functions/` o `test/` nomina Protoface o LiveKit
salvo un commento di intenzione in `lib/core/sensi/motore_audio.dart:22`.
`livekit_client` **non e' fra le dipendenze**: e' una dipendenza nativa nuova,
e va dichiarata come tale perche' pesa sulla build e domani su iOS.

**Cio' che invece c'e' gia' e si riusa**: `record` e `speech_to_text` fra le
dipendenze, e tutta l'impalcatura dell'entitlement in
`lib/core/entitlement/`, dai tier alle allowance.

---

### 5. I TRE AVATAR ESISTONO, E SONO STATI RICAVATI DAL SERVER

La porta `gliAvatarDiProtoface`, distribuita il 23 settembre 2026, li ha
elencati **senza che la chiave lasciasse mai Secret Manager**:

| Maestro | identificativo | stato |
|---|---|---|
| Medora-1 | `av_01M0N4GC9M1791PVH6NDD4FMMG` | ready |
| Aura-Protoface | `av_01KZVCNV16EAMMG75TXFC9D475` | ready |
| Caligo-Protoface | `av_01KZVB6FCP27NR3GZQ47WJ7QJG` | ready |

**La prima chiamata aveva reso venti `av_stock_*` e nessuno dei tre.**
Mancava `scope=org`, che la documentazione dichiara: *"all (default — platform
stock plus your org's), platform (only built-in stock), or org (only your
custom)"*. **E' il modo in cui una porta risponde benissimo a una domanda
sbagliata**, e senza rileggere la pagina si sarebbe concluso che gli avatar
non c'erano.

**DUE MEDORA, e la scelta e' dichiarata.** L'elenco `org` ne porta quattro:
oltre ai tre c'e' `av_01KZ9637K1YZ45H3GNZE95YN6E`, *Proto-Medora-1*. Si usa il
piu' recente, **Medora-1**, e il volto si vede nella prima cattura della
fetta verticale: se e' quello sbagliato, cambia una riga.

**Era quello sbagliato, e la riga e' cambiata.** Medora-1 era a figura
intera, mentre tutti gli altri avatar sono a mezzobusto. Il fondatore, 23
settembre 2026: *"ho eliminato l'avatar intero che tu hai usato come
collegamento [...] Usa l'altro"*. Adesso Medora e'
`av_01KZ9637K1YZ45H3GNZE95YN6E`, *Proto-Medora-1*, in `functions/src/live.ts`.

---

## VOCE EG.01, IL NOSTRO CERVELLO, IL VOLTO DI PROTOFACE

Nel LIVE risponde il nostro Maestro, con le personalita', la memoria e le
regole della chat scritta. Il testo di personalita' del file Protoface non si
usa. Tutta l'intelligenza su Vertex e Gemini.

Le chiavi vivono solo sul server. Una sessione nasce soltanto dal server, dopo
che ha verificato diritto e minuti.

### Cosa e' stato fatto

Il server c'era gia' dalla prima parte dell'ordine, interrotta dall'EH: tre
porte in `functions/src/live.ts`, agganciate all'indice. **Adesso c'e' il lato
telefono**, `lib/services/live/porta_del_live.dart`, e **non porta nessuna
chiave**: riceve dal server un gettone gia' fatto, buono per **una stanza
sola**.

**Perche' e' la cosa piu' importante di tutta la voce.** Chi avesse il segreto
di LiveKit potrebbe entrare **in qualunque stanza di chiunque**, cioe' nella
sessione privata di un'altra persona. La guardia cerca `PROTOFACE_API_KEY`,
`LIVEKIT_API_SECRET`, `LIVEKIT_API_KEY` e perfino l'indirizzo
`api.protoface.com` in **tutti i 675 file di `lib`**, ed e' nata rossa
innestando quell'indirizzo nella porta.

**RIAPERTA IL 23 SETTEMBRE 2026, dopo la prova del fondatore sulla 2277.**
Parole sue: *"compare la figura intera di Medora ma e' fissa e muta, nessun
tipo di reazione, ne' da microfono, ne' da altoparlante e nemmeno testuale"*.

**Questa voce era stata chiusa misurando meta' di quello che chiede**: che le
chiavi non scendessero sul telefono. La voce chiede invece che **nel LIVE
risponda il nostro Maestro**, e nella stanza non c'era nessun agente che
ascoltasse, chiedesse a Gemini e parlasse: Protoface anima l'audio che
riceve, e non riceveva niente. E' il difetto dell'ordine EH, **una misura
vera che risponde alla domanda accanto**, commesso dentro l'ordine che doveva
impedirlo. **Padre: ordine EG, questa voce, chiusa male.** La sessione del
fondatore, `sess_01M377F0BQ5CM44DW8B47RZGFX`, si e' aperta davvero alle
13:32:13 e il suo testo "chi sei?" non e' arrivato a nessuno.

### LA CATENA VERA, RIFATTA E PROVATA SUL TELEFONO PRIMA DI CONSEGNARE

**Il cervello e' la chat scritta, lo stesso controller.** Il LIVE riceve il
`MaestroChatController` della conversazione aperta: stesso Maestro, stessa
memoria, stesse regole, e ogni turno detto a voce resta scritto nella chat.

**La voce nasce sul server**, porta `laVoceDelMaestro`, con
`gemini-2.5-flash-tts` in `europe-west1` (verificato con una chiamata vera e
aggiunto a `la_regione_dei_dati.dart` dopo aver visto rossa la guardia della
regione), **e arriva a flusso**: `streamGenerateContent` sul server,
`HttpsCallable.stream` sul telefono.

**Il telefono la manda al volto** sul flusso di byte `lk.audio_stream`, PCM a
16 bit con tasso e canali negli attributi, destinato all'identita' del
lavoratore che il server dichiara; e aspetta che il volto dica
`lk.playback_finished` prima di tornare ad ascoltare. **Protoface lo dice
davvero**: in ogni turno misurato il log porta "lo ha detto lui".

**La persona parla o scrive.** La dettatura del telefono nella lingua
dell'app; il turno si chiude un secondo e mezzo dopo l'ultima parola.

**Tre difetti trovati dal fondatore mentre provava, e tutti e tre curati
prima della build:**

1. *"La voce e' rallentata parecchio"*. Il modo di Medora diceva "calda,
   **lenta** e brunita": 8,0 caratteri al secondo. Adesso "a ritmo sciolto
   e spedito": fra 13,1 e 14,7 per le tre voci, due giri ciascuna. **Padre:
   ordine EG voce 03**, il modo scritto da me senza misurarlo.
2. *"La risposta arriva molti secondi dopo"*. La voce intera di una frase
   costava da 4,4 a 11,7 secondi; a flusso il primo suono arriva in 0,61-0,80.
   **E sotto ce n'era un secondo**: la chat consegna la risposta dopo almeno
   quattro secondi di scena, anche nel LIVE dove la scena non si vede; il
   Realme di collaudo ha le animazioni spente e li' la pausa scende a 0,7,
   per questo al banco non si notava. **Padre: ordine EG voce 01**, il LIVE
   agganciato alla chat senza guardare i suoi tempi.
3. *"Non ti resta nessuna domanda ai Maestri, oggi"*, letto dopo una prova a
   voce. La strada principale del turno addebitava la domanda a mano, fuori
   da `_applicaIlCosto` dove il LIVE spegne il costo. **Padre: ordine EG voce
   06**, il mio `nelLive` messo in un punto solo dei tre.

DOMANDA: "compare la figura intera di Medora ma è fissa e muta, nessun tipo di reazione, né da microfono, né da altoparlante e nemmeno testuale"
PROVA: docs/collaudo/EG/la_bocca_di_medora_parla_e_tace.png
MISURA: bocca fra fotogrammi consecutivi, differenza media 20,86 mentre parla contro 2,12 mentre tace (prima: nessuna voce mandata al volto, 0 turni); turno a voce dalla fine della frase alla voce del Maestro 5,2 s (prima 13-18 s), primo suono 0,64-0,80 s in 13 turni su 15 e 1,27 e 3,26 s nei due con la funzione del server fredda, fine confermata dal volto 13 su 13 letti

Le righe dei turni stanno in `docs/collaudo/EG/la_voce_viva_misurata.txt`.

**CHIUSA.**


## VOCE EG.02, IL MOTORE DI VOCE A SCELTA

Cinque motori intercambiabili: Gemini Live, Gemini 2.5 Flash TTS, Chirp 3 HD,
Neural2, WaveNet. Nella schermata LIVE i fondatori cambiano motore e leggono
il costo stimato al minuto; per le altre persone il motore e' uno, deciso dal
server senza una build nuova.

**APERTA.**

## VOCE EG.03, LE VOCI LE SCEGLI TU

Quindici scelte, una per Maestro e per motore, dalla parte del file
`Protoface-Addestreamento- Avatar.txt` che descrive voce, ritmo e pronuncia:
Medora femminile adulta calda e brunita, Aura femminile adulta chiara e
luminosa, Caligo maschile grave e matura.

**APERTA.**

## VOCE EG.04, IL PULSANTE LIVE

Nella testata della chat dei tre Maestri. Sotto il tier 2 nello stato Premium
bloccata, mai vicolo cieco. Dal tier 2 in su apre un foglio col nome, i minuti
rimasti, il permesso del microfono e il pulsante per cominciare. Finche' il
fondatore non lo apre, attivo solo per i fondatori, con un interruttore del
server.

**APERTA.**

## VOCE EG.05, LA SCHERMATA LIVE

Il Maestro a mezzobusto, i sottotitoli, il pulsante per chiudere. Si parla al
microfono **oppure si scrive**, che e' il ripiego tattile che `CLAUDE.md`
rende obbligatorio.

### LA MACCHINA DEGLI STATI STA FUORI DAL WIDGET, E NON E' UNA PREFERENZA

**E' la lezione dell'ordine EI.** Li' la frase del riassunto delle sette sere
viveva dentro uno `State` privato: la leggeva l'utente nel diario e **nessuna
prova poteva chiamarla**, ed e' per questo che un terzo di quella voce e'
rimasto senza copertura fino a che il fondatore non l'ha riaperta.

Qui i momenti, il conto del tempo, il ripiego tattile e le frasi dei rifiuti
vivono in `stato_della_schermata_live.dart`, dove una prova li raggiunge. Il
widget disegna e basta.

### LE DUE REGOLE DI CASA CHE QUI RISCHIAVANO DI SALTARE

**Si puo' scrivere anche mentre il volto non e' ancora arrivato.** Se si
potesse solo a sessione viva, chi ha il microfono rotto resterebbe fermo a
guardare un volto che non arriva. Vista rossa togliendo proprio quella meta'
della condizione.

**Le tre ragioni del rifiuto danno tre frasi diverse, e nessuna e' un
messaggio d'errore.** Chi non ha diritto riceve un invito, chi ha finito i
minuti riceve il saluto del Maestro, chi trova un guasto torna alla chat
scritta. La prova cerca le parole da errore e pretende che ognuna offra la
chat: **nessuno dei tre stati e' un vicolo cieco.**

### E LA SCHERMATA NON SI PRENDE L'IMMAGINE DA SE'

La prima stesura faceva `Image.asset` dell'avatar, e la guardia di casa
`il_busto_e_la_forma_del_maestro` l'ha presa: **ogni file che sceglie
l'immagine da se' e' una seconda porta**, e due porte sullo stesso asset
divergono al primo ritocco. Adesso passa da `BustoDelMaestro`, che sa anche
farlo respirare.

**RIAPERTA anche questa**, per la stessa prova del fondatore: la schermata c'e'
ma mostra un ritratto fermo con due bande bianche ai lati, e il testo scritto
non arriva a nessuno. Il commento nel codice che diceva il contrario era
un'affermazione mai verificata.

### IL FONDO BIANCO, E LA FINESTRA CHIESTA DAL FONDATORE

Parole sue, mentre provava: *"credevo che l'avatar fosse con canale alpha e
invece vedo un riquadro bianco dietro l'avatar che fa schifo. Se non si puo'
togliere, almeno mettiamo uno sfondo nero"*; e subito dopo: *"Una soluzione
elegante potrebbe essere un riquadro al cui interno c'e' l'avatar [...] cosi'
il taglio in basso dell'avatar coinciderebbe con il bordo basso del
riquadro, come se fosse all'interno di una finestra. Adesso ai lati
dell'avatar c'e' molto troppo spazio"*.

**Il bianco sta dentro il video.** WebRTC non porta il canale alpha, e la
documentazione di Protoface, letta lo stesso giorno, non ha nessuna opzione di
sfondo nella sessione ne' un'anteprima dell'avatar. Un fondo nero della
schermata avrebbe lasciato il riquadro bianco dov'era. **Lo toglie un filtro
colore sul video**: trasparenti i pixel sopra una media di 250 per canale,
pieni sotto 230, sfumati in mezzo. La schermata e' nera ovunque: la prima
prova col fondo blu notte lasciava intuire di nuovo il rettangolo del video.

**Il filtro colore lasciava un filo chiaro lungo tutta la sagoma**, e il
fondatore l'ha visto subito: *"Il contorno bianco intorno all'avatar non va
bene, trova soluzione elegante"*. I pixel di bordo sono una miscela fra il
Maestro e il bianco, e per luminosita' non si distinguono da un punto chiaro
del viso. **Adesso lo toglie uno shader**, `shaders/volto_senza_fondo.frag`,
che guarda il vicinato di ogni pixel: sparisce se ha fondo bianco a un passo
(2, 4 e 6 pixel) **e** anche piu' in la' (10 e 14 pixel); e per fondo conta
solo il **bianco neutro**, canali alti e quasi uguali. Se lo shader non si
carica resta il filtro colore.

**Sei stesure sul telefono, ognuna guardata da vicino**, perche' ognuna
sbagliava in un punto diverso: il riflesso bianco sulla spalla di Medora
bucato di nero; lo spiraglio fra orecchino e collo che tornava bianco con i
raggi dritti; il cristallo della spilla di Caligo bucato; la pelle chiara del
petto di Medora bucata sotto il ciondolo. **Due di queste cose nessuna regola
automatica le distingue**, e sono dichiarate a mano in
`InquadraturaDelVolto`: sulla spalla di Medora c'e' un **buco dell'immagine
da cui l'avatar e' nato**, contato sul fotogramma col fondo bianco (pixel
336-362 per 644-658 su 1.080), ed e' una **toppa** che si riempie col colore
del mantello; il cristallo di Caligo e' una **zona intatta** dove il bianco e'
figura. **Lo shader riceve la finestra, non il video intero**: la toppa
espressa in coordinate del video non riempiva niente, ed e' stato il telefono
a dirlo. **Padre del filo chiaro: ordine EG voce 05**, il filtro colore
consegnato come soluzione senza guardarlo da vicino.

**E un'app di terze parti si mette davanti dopo ogni installazione**: Clean
Master, sul Realme. I tocchi automatici della prova sono caduti una volta sul
suo AppLock; non e' stato attivato niente (la sua schermata dice ancora "piu'
di 4 app possono essere protette"). Da li' in avanti ogni tocco controlla
prima che in primo piano ci sia l'app.

**La finestra e' ad arco**, doppio filo d'oro e un alone del colore del
Maestro. La cornice VIP del design system e' stata guardata e scartata: porta
pallone, pellicola, chiave di violino e racchetta, e' fatta per i VIP. **Il
ritaglio e' misurato Maestro per Maestro** in `InquadraturaDelVolto`, perche'
ognuno sta nel video a modo suo: il taglio di Medora cade a 0,852 del lato,
quello di Aura a 0,998, quello di Caligo a 0,851. **La misura di Caligo e'
stata presa due volte**: la prima dava 0,885 e sotto il busto restava una
fascia nera, perche' il suo saluto sta su una riga sola e il video stava piu'
in basso di quanto la misura supponeva. **Padre: ordine EG voce 05**, la
misura presa fuori dalla finestra; ripresa dentro la finestra, dove il bordo
e' noto.

**Due cose arrivate insieme alla finestra.** Il sottotitolo ha un tetto di un
quinto dello schermo e oltre scorre: una risposta di trenta secondi, scritta
per intero, spingeva il volto a meta'. E la dettatura del LIVE ascolta nella
lingua dell'app, come quella della chat: senza, su iPhone, "quindi" diventa
"Indicate" (ordine DX voce 02). **Padre: ordine EG voce 05**, la dettatura
creata senza la lingua.

**Trenta secondi senza conversazione chiudono la voce viva.** Parole del
fondatore: *"dovrebbe esserci una interruzione automatica se non c'e'
conversazione per oltre 30 secondi"*. Il silenzio si conta solo quando
nessuno sta facendo niente, ogni parola detta o scritta lo azzera, e alla
chiusura il Maestro dice perche' e offre il ritorno alla conversazione. Sotto
il telefono c'e' la rete del server: Protoface chiude da se' dopo 60 secondi
senza audio, prima erano 180, per quando l'app muore e non puo' chiudere.

**Un difetto mio, preso prima di consegnare.** Per accorciare l'attesa della
frase avevo abbassato a 1,5 secondi la pausa della dettatura: valeva anche per
il silenzio iniziale, e l'ascolto moriva prima che la persona cominciasse a
parlare. Sul telefono il turno a voce non e' partito. **Padre: ordine EG voce
05**, questa sessione. La cura giusta e' un orologio che parte solo dalla
prima parola.

DOMANDA: "Una soluzione elegante potrebbe essere un riquadro al cui interno c'è l'avatar. Ma deve essere un bel riquadro, così il taglio in basso dell'avatar coinciderebbe con il bordo basso del riquadro, come se fosse all'interno di una finestra. Adesso ai lati dell'avatar c'è molto troppo spazio"
PROVA: docs/collaudo/EG/la_finestra_dei_tre_maestri.png
MISURA: busto di Medora 59 per cento della larghezza visibile prima, 95 per cento dopo; fascia fra il taglio e il bordo basso 160 pixel prima (fondo bianco), 0 pixel dopo per Medora, Aura e Caligo (il busto entra nell'oro alla riga 1.609 per Medora e Aura e 1.645 per Caligo, senza fessura nera ne' filo chiaro in nessuno dei tre); Caligo alla prima misura 48 pixel di fascia nera, 0 alla seconda

**CHIUSA.**

## VOCE EG.06, I MINUTI

Tier 2 cento minuti al mese, tier 3 duecentocinquanta. Il LIVE consuma solo i
suoi minuti. Venti minuti al massimo per sessione, col saluto prima della
fine. A posti esauriti un messaggio del Maestro, mai un errore.

**Una meta' e' fatta e provata: il LIVE non consuma le domande della chat.**
Il fondatore ha trovato *"Non ti resta nessuna domanda ai Maestri, oggi"* dopo
una prova a voce: il turno principale della chat addebitava la domanda a
mano, fuori dal punto unico `_applicaIlCosto` dove il LIVE spegne il costo, e
anche il Riprova faceva lo stesso. Adesso tutte e tre le strade passano di
li'. La prova `il_live_consuma_solo_i_suoi_minuti_test.dart` e' nata rossa
rimettendo l'addebito a mano, e ha una gemella che pretende che fuori dal LIVE
lo stesso turno costi. **Padre: ordine EG voce 06**, il `nelLive` messo in un
punto solo dei tre.

**Il diritto e' aperto ai tier 2 e 3.** Scelta del fondatore del 23 settembre
2026, *"Apri adesso al tier 2 e 3"*: in `configurazione/live` l'interruttore
`apertoAlTier2` e' acceso, e i fondatori restano per uid.

**Restano da provare** i contatori dei cento e duecentocinquanta minuti al
mese e il saluto prima dei venti minuti: nessuna sessione di questo collaudo
e' arrivata a toccarli.

**APERTA.**

## VOCE EG.07, I PASSI DI MAURO

**Quasi tutta fatta prima di cominciare**: le quattro chiavi sono gia' in
Secret Manager. Restano da ricavare gli identificativi dei tre avatar, e si
ricavano **dal server**, che e' l'unico posto dove la chiave puo' stare.

**APERTA.**

## VOCE EG.08, IL COLLAUDO

Sessioni vere sul Realme, tre Maestri per cinque motori, otto stati catturati
in `docs/collaudo/EG/`. Per ogni motore il tempo fra la fine della frase della
persona e la prima parola del Maestro, e il costo reale al minuto preso dai
consumi e non stimato.

**APERTA.**

## VOCE EG.09, LA BUILD ALLA FINE

Solo quando le voci da 01 a 08 sono chiuse e spinte.

**APERTA.**

---

## PROTOCOLLO DELLE GUARDIE

**Regola B, le guardie che coprono le zone toccate, viste rosse prima.**
**Non applicata per intero, e va detto.** Il controller della chat e la
dettatura sono stati toccati senza vedere prima rosse le guardie che li
coprono; la rete e' stata la suite intera, girata prima dello sbarramento, e
la guardia dei grigi ha preso cosi' il pulsante del congedo. La guardia della
regione dei dati invece e' stata vista rossa prima di toccare l'elenco dei
modelli.

**Regola A, le guardie nuove, ognuna col suo innesto verificato col grep:**

| guardia | innesto | esito |
|---|---|---|
| `i_modelli_stanno_nella_regione_dei_dati` | `gemini-2.5-flash-tts` nel server, fuori dall'elenco | rossa, poi verde con la verifica del 23/09 |
| `il_parlato_del_maestro_test` | l'ultimo pezzo della risposta non si aggiunge | rossa, due prove su tre |
| `il_live_consuma_solo_i_suoi_minuti_test`, il costo | l'addebito a mano rimesso sul turno | rossa |
| `il_live_consuma_solo_i_suoi_minuti_test`, la pausa | il ramo `nelLive` tolto dalla pausa | rossa, 4.003 ms |
| `la_finestra_sul_volto_test` | la finestra piu' alta di 0,05 sotto il taglio | rossa su Medora |

La guardia delle chiavi di Protoface e di LiveKit, chiesta per nome
dall'ordine, e' `la_porta_del_live_non_porta_chiavi_test.dart`, nata rossa
nella prima parte.

**Regola C, ogni difetto col suo padre.**

| difetto | padre |
|---|---|
| volto fermo e muto nella 2277 | EG voce 01, chiusa misurando le chiavi e non la voce |
| voce rallentata, 8,0 caratteri al secondo | EG voce 03, il modo "lenta" scritto senza misura |
| risposta dopo molti secondi: voce intera per frase | EG voce 01 |
| risposta dopo molti secondi: pausa scenica di 4 s nel LIVE | EG voce 01, il LIVE agganciato alla chat senza guardarne i tempi |
| il LIVE consuma le domande della chat | EG voce 06 |
| riquadro bianco dietro il volto | EG voce 05, il video di Protoface mostrato senza guardarlo |
| dettatura del LIVE senza la lingua dell'app | EG voce 05 |
| ascolto che muore prima che si parli, pausa di 1,5 s | EG voce 05, preso sul telefono prima della build |
| fascia nera sotto Caligo | EG voce 05, misura presa fuori dalla finestra |
| pulsante del congedo nel viola del tema | EG voce 05, preso dalla guardia dei grigi |
| diciannove file riformattati da un `dart format` sulla cartella | EG voce 05, riportati allo stato del commit prima di committare |
