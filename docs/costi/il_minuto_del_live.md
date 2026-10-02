# Il minuto del LIVE con Protoface

Ordine EW, voce EW.07, 2 ottobre 2026.

> *"Vorrei anche essere sicuro del costo di Protoface e del costo al minuto
> per la chat live attraverso Protoface."*

## In breve

- **Un minuto di LIVE in conversazione costa circa 0,021 dollari**, due
  centesimi: misurato su una sessione vera di 7 minuti col Realme il 2
  ottobre 2026.
- **Piu' della meta' e' il volto di Protoface**: 0,0113 al minuto (un credito
  da un centesimo al minuto, arrotondato al minuto intero per sessione). Il
  resto e' Gemini: la voce 0,0040, le risposte 0,0034, l'ascolto 0,0025.
  LiveKit 0 finche' il progetto sta nei minuti compresi del suo piano.
- **Un minuto di LIVE aperto senza conversazione** (silenzio interrotto dal
  rumore, una televisione) costa 0,0125: volto e ascolto.
- **Coi minuti del codice**, 100 al mese per l'Adepto e 250 per
  l'Illuminato, il LIVE costa al massimo **2,13 e 5,32 dollari al mese**.
- **Ma oggi quei minuti non scendono mai**: il server li legge e nessuno li
  scrive (sotto, "Il difetto dei minuti"). Il vero limite del LIVE oggi sono
  le **domande del giorno** (ogni turno detto a voce costa una domanda, 10
  all'Adepto e 50 all'Illuminato) e i **20 minuti per sessione**.
- **Il piano Protoface sottoscritto e' almeno il Launch** (99,99 $ al mese,
  7.500 minuti compresi): una sessione del 30 settembre e' durata 14 minuti e
  45 secondi, oltre i 10 dello Starter. Launch o Scale lo dice il pannello di
  Protoface: lo chiedo al fondatore (sotto, "Cosa serve dal fondatore").

## La sessione misurata

Realme 767f596c, build 2292, account del fondatore (piano Illuminato per i
fondatori), LIVE con Medora, qualita' del volto "lite" (la scelta di
`configurazione/live`). Quattro domande dette dalle casse del PC con la voce
italiana di Windows, poi silenzio fino alla chiusura automatica.

| Che cosa | Da dove | Valore |
|---|---|---|
| Apertura (tocco su LIVE) | orologio del PC, `docs/collaudo/EW/live_tempi_del_pc.txt` | 06:17:21 |
| Sessione aperta dal server | registro del server, "LIVE aperto" | 06:17:27 (sessione `sess_01M3XD9MYX1T3QBS3SBPTWJHFZ`) |
| Chiusura | registro del telefono, "chiusa dopo 30 secondi di silenzio" | 06:24:25 |
| **Minuti per il telefono** | dal tocco alla chiusura | **7:04** |
| **Minuti per l'app** (il contatore della schermata, da 20:00) | catture `live_05.jpg` e `live_07.jpg` | **6:58** (si e' fermato a 13:02) |
| **Secondi per Protoface** (`billable_seconds`) | due righe "Uso di Protoface nel mese" del server, alle due aperture | 562 - 139 = **423 s, 7:03** |
| **Crediti Protoface** (`credits_charged`) | le stesse due righe | 11 - 3 = **8 crediti, 0,08 $** (7,05 minuti arrotondati a 8) |
| Minuti per LiveKit | nessun accesso al pannello di LiveKit | da leggere dal fondatore (sotto) |

**I tre orologi dicono la stessa cosa a pochi secondi**: telefono 7:04,
Protoface 7:03, contatore dell'app 6:58 (parte quando il volto si accende,
non al tocco). **Protoface fattura 8 minuti per 7 minuti e 3 secondi**:
l'arrotondamento al minuto intero, per sessione. Una sessione corta paga un
minuto intero: la seconda apertura di prova, 13 secondi, ha pagato 1 credito.

**Un fatto che non e' del LIVE dell'app.** Fra il 28 settembre alle 14:07 e il
30 settembre alle 10:42 i crediti di Protoface del mese sono saliti da 463 a
1.188 (725 crediti, 7,25 dollari) mentre i secondi del LIVE sono saliti solo
di 288 (una sessione). Quei crediti non vengono dalle sessioni dell'app:
Protoface conta anche i video generati in Studio e le chiamate di generazione
(`by_billing_surface`, `by_operation` nel riepilogo `/v1/usage`). **Il
fondatore lo ha confermato il 2 ottobre: e' un suo video extra**, non l'app.

## Il minuto, pezzo per pezzo

Costi della sessione misurata, divisi per i 7,05 minuti fatturati
(`tool/i_conti_del_costo_ew.py`, uscita in `docs/costi/i_conti_del_costo.txt`):

| Pezzo | Come si e' misurato | Nella sessione | Al minuto |
|---|---|---|---|
| **Protoface, il volto** | 8 crediti × 0,01 $ (registro del server) | 0,0800 | **0,0113** |
| **La voce del Maestro** (Gemini TTS, Erinome) | 12 chiamate nel registro del server ("voce del Maestro"), 1.276 caratteri, 113,3 secondi di audio a 24 kHz; 25 token al secondo a 10 $ al milione | 0,0285 | **0,0040** |
| **Le risposte** (chat nel LIVE, Flash) | 4 risposte (registro del telefono, "la chat ha risposto") × 0,00596, il costo medio senza cache del banco | 0,0238 | **0,0034** |
| **L'ascolto** (trascrizione, Flash con l'audio) | circa 66 chiamate (registro del telefono: 25 trascrizioni anticipate, 19 controlli del sottofondo, 12 chiusure, 10 seconde trascrizioni senza il sottofondo) × 0,00027, il costo medio del banco | 0,0177 | **0,0025** |
| **LiveKit** | 2 partecipanti (il telefono e il volto di Protoface) × 7,05 minuti = 14,1 minuti di connessione; compresi nel piano finche' non si superano | 0 | **0** (0,0010 oltre i compresi) |
| **Totale** | | **0,1500** | **0,0213** |

**Il saluto** del Maestro all'apertura e' una delle 12 chiamate di voce.

**L'ascolto chiama Gemini quasi dieci volte al minuto**, anche quando nessuno
parla: ogni rumore che supera la soglia e' una frase da trascrivere (dieci
volte e' tornato vuoto ed e' stato trascritto una seconda volta senza il
sottofondo). Costa poco a chiamata, ma e' la sola parte del LIVE che cresce col
rumore della stanza e non con la conversazione.

**Il confronto con la stima dell'ordine EK** (`RAPPORTO_ORDINE_EK.md`, 0,0205
al minuto): la misura vera e' 0,0213, il 4 per cento sopra.

## Il listino di Protoface (pubblico, letto il 2 ottobre 2026)

Fonte: `GET https://api.protoface.com/v1/billing/plans`, che la
documentazione dichiara senza autenticazione (*"This endpoint is
unauthenticated so signup and pricing UI can render the same catalog used by
checkout and enforcement"*); copia in
`docs/collaudo/EW/protoface_piani_pubblici_2026-10-02.json`. La regola del
consumo: `docs.protoface.com/reference/quotas.md`, copia in
`docs/collaudo/EW/protoface_crediti_e_limiti_2026-10-02.md`.

| Piano (famiglia realtime) | Prezzo al mese | Crediti compresi | Sessione piu' lunga | Sessioni insieme | Credito in piu' |
|---|---|---|---|---|---|
| Free | 0 | 50 | 2 minuti | 1 | 0,01 $ |
| Starter | 20,00 $ | 500 | 10 minuti | 2 | 0,01 $ |
| Launch | 99,99 $ | 7.500 | 20 minuti | 10 | 0,01 $ |
| Scale | 299,99 $ | 25.000 | 60 minuti | senza limite | 0,01 $ |

*"Session time rounds up to the nearest minute, at one credit per minute."*
I crediti gratuiti del mese non passano al mese dopo, quelli comprati si'.

**Il piano sottoscritto: non letto.** Nessun documento del progetto lo
scrive; il codice assume il Launch (`functions/src/live.ts`, il commento sul
tetto di venti minuti, `max_duration_seconds` 1200). **Il registro del server
dice che e' almeno il Launch**: fra le 101 righe "Uso di Protoface nel mese"
dal 24 settembre, fra l'apertura del 30 settembre alle 10:42 UTC e quella delle
12:40 i secondi sono saliti di 885 e le sessioni di una sola (da 128 a 129),
cioe' una sessione di 14 minuti e 45 secondi. Lo Starter chiude le sessioni a
10 minuti, il Launch a 20. Col Launch i 1.215 crediti di settembre stanno nei
7.500 compresi. Fra Launch e Scale il registro non decide: l'endpoint che lo
dice, `GET /v1/billing/quota`, vuole
la chiave di Protoface: Code ha provato a leggerla da Secret Manager per
questa sola lettura e il controllo dei permessi l'ha negato. **Lo dice il
fondatore** dal pannello di Protoface (Billing), senza mandare nessuna
credenziale.

**Cosa cambia col piano.** Il credito in piu' costa 0,01 $ in tutti i piani,
ma col Launch i primi 7.500 minuti del mese **sono gia' pagati dal canone** di
99,99 $: dentro i compresi il minuto di volto non costa niente in piu', e il
canone diviso per 7.500 fa 1,3 centesimi al minuto se li si usa tutti. **Il
canone e' un costo fisso, non per utente**: a settembre i minuti di LIVE sono
stati circa 400, cioe' 25 centesimi a minuto di canone. Il costo al minuto di
questo documento (0,0113 per il volto) e' il prezzo del credito, ed e' quello
giusto per il conto per utente quando i compresi finiscono; dentro i compresi
il minuto di volto costa zero in piu' e il LIVE costa solo la parte di Gemini,
0,0099 al minuto.

## Il listino di LiveKit (pubblico, letto il 2 ottobre 2026)

Fonte: `livekit.com/pricing`. I minuti sono *"time an end user spends
connected to our network via WebRTC"*, per partecipante.

| Piano | Al mese | Minuti WebRTC compresi | Oltre |
|---|---|---|---|
| Build | 0 | 5.000 | 0,0005 $ al minuto |
| Ship | 50 $ | 150.000 | 0,0005 $ al minuto |
| Scale | 500 $ | 1.500.000 | 0,0004 $ al minuto |

Un minuto di LIVE sono **due** connessioni (il telefono e il volto), se
LiveKit conta anche il volto come utente. Col Build i 5.000 minuti valgono
quindi **2.500 minuti di LIVE al mese per tutta l'app**: 25 Adepti che usano
tutti i loro 100 minuti. Il piano sottoscritto di LiveKit non si legge da
nessuna parte a cui Code ha accesso (l'indizio del Build e' nel rapporto
dell'ordine EK): **lo legge il fondatore** nel pannello di LiveKit, insieme
ai minuti della sessione `live_iToukegmg2P3LBmlyYGJjkxvFbs1_1790914646252` del
2 ottobre, 04:17-04:24 UTC.

## I minuti del LIVE per piano

| | Viandante | Iniziato | Adepto | Illuminato |
|---|---|---|---|---|
| Minuti al mese nel codice (`functions/src/live.ts`) | 0 | 0 | 100 | 250 |
| Minuti per sessione | | | 20 | 20 |
| Voce dei Maestri nel Briefing §22 | No | No | Esclusiva | Si' |
| Minuti del LIVE nel Briefing §22 | la riga non esiste | | | |
| **Se usati tutti, al mese** | 0 | 0 | **2,13 $** | **5,32 $** |

Il Briefing §22 non ha una riga dei minuti del LIVE: i numeri 100 e 250 sono
del codice (ordine EG). La voce dei Maestri, nel codice, esiste solo nel LIVE.

## Il difetto dei minuti, e cosa vuol dire per il costo

**I minuti del mese non scendono mai.** `functions/src/live.ts` legge
`users/{uid}/stato/live.minutiUsati` per decidere se aprire il LIVE, e
nessuna riga del codice lo scrive. Lo conferma la sessione di oggi: il server
ha scritto `"rimasti": 250` all'apertura delle 04:17 e di nuovo alle 04:28,
dopo sette minuti di LIVE. Padre: ordine EG, voce EG.06, che ha introdotto la
lettura senza la scrittura.

Cosa vuol dire oggi, con i limiti che restano:

- **Il turno detto a voce costa una domanda** (decisione del fondatore,
  ordine EQ voce 07: *"I turni Live contano come domande."*; verificato sul
  telefono: quattro domande nel LIVE hanno portato le domande del giorno da 50
  a 46). Le risposte del LIVE sono quindi al massimo 10 al giorno per
  l'Adepto e 50 per l'Illuminato, cioe' **al massimo 0,33 e 1,64 dollari al
  giorno di LIVE in conversazione** (una risposta, la sua voce e il suo
  minuto di volto: circa 0,033 $ a turno).
- **Il LIVE aperto senza conversazione non ha un tetto al mese.** Ogni
  sessione dura al massimo 20 minuti e si chiude dopo 30 secondi senza voce, ma
  il rumore della stanza azzera il silenzio ("voce chiara senza parole, il
  silenzio riparte da zero" nel registro del telefono). Chi riapre il LIVE ogni
  20 minuti con una televisione accesa spende 0,0125 $ al minuto, **0,75 $
  l'ora**, senza limite. E' il caso peggiore del LIVE di oggi, ed e' una leva
  della voce EW.06.

## Cosa serve dal fondatore

1. **Il piano Protoface** sottoscritto (pannello di Protoface, Billing): il nome
   del piano e i crediti rimasti. Nessuna credenziale.
2. **Il piano LiveKit** e i minuti della sessione del 2 ottobre 04:17-04:24 UTC,
   dal pannello di LiveKit: per confrontarli coi 7:03 di Protoface e i 7:04
   del telefono, e per sapere se LiveKit conta uno o due partecipanti.
