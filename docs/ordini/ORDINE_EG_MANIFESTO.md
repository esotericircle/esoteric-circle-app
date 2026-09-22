# ORDINE EG, IL LIVE DEI MAESTRI: IL NOSTRO CERVELLO, IL VOLTO DI PROTOFACE, LA VOCE A SCELTA

**Sigla:** EG, riverificata sul ramo il 23 settembre 2026: in `docs/ordini`
non c'e' nessun `ORDINE_EG_*`, in `test/` nessuna `ordine_eg_guard`, e
**nessun file del repo nomina un ordine EG** (ricerca su `docs/`, `test/`,
`lib/`, `tool/`, `functions/`: zero righe). **Data:** 23 settembre 2026.
**Ramo:** `claude/esoteric-circle-master-order-e798aj`. Parte dal commit
`a088a3da`, l'ordine EF chiuso e spinto.

VOCI_TOTALI: 9
VOCI_CHIUSE: 0
VOCI_APERTE: 9

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

---

## VOCE EG.01, IL NOSTRO CERVELLO, IL VOLTO DI PROTOFACE

Nel LIVE risponde il nostro Maestro, con le personalita', la memoria e le
regole della chat scritta. Il testo di personalita' del file Protoface non si
usa. Tutta l'intelligenza su Vertex e Gemini.

Le chiavi vivono solo sul server. Una sessione nasce soltanto dal server, dopo
che ha verificato diritto e minuti.

**APERTA.**

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
rende obbligatorio. Se la connessione cede si torna alla chat scritta senza
perdere niente. Tutto entra nella conversazione e nella memoria.

**APERTA.**

## VOCE EG.06, I MINUTI

Tier 2 cento minuti al mese, tier 3 duecentocinquanta. Il LIVE consuma solo i
suoi minuti. Venti minuti al massimo per sessione, col saluto prima della
fine. A posti esauriti un messaggio del Maestro, mai un errore.

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
Da compilare mentre si lavora.

**Regola A, le guardie nuove, ognuna col suo innesto.** Fra queste, per nome
dall'ordine: una che fallisce se una chiave di Protoface o di LiveKit compare
nel codice dell'app o su Git.

**Regola C, ogni difetto col suo padre.**
Da compilare mentre si lavora.
