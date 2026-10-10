# RAPPORTO DELL'ORDINE EX, IL COSTO AI SOTTO IL 30 PER CENTO SENZA PERDERE QUALITA'

2 ottobre 2026. Manifesto: `docs/ordini/ORDINE_EX_MANIFESTO.md`.

## Le voci chiuse, con la prova di ciascuna

- **EX.01**, i minuti del LIVE scendono davvero: `docs/collaudo/EX/minuti_del_live.txt`
- **EX.02**, la matrice nuova: `docs/collaudo/EX/la_matrice_nuova.txt`
- **EX.03**, le rune dal corpus: `docs/collaudo/EX/rune_senza_ripetizioni.txt`
- **EX.06**, i Ricordi nella regione dei dati: `docs/collaudo/EX/regione_dei_ricordi.txt`
- **EX.08**, il cielo di oggi nella richiesta: `docs/collaudo/EX/il_cielo_nella_richiesta.txt`
- **EX.09**, la memoria compatta: `docs/collaudo/EX/memoria_compatta.txt`
- **EX.11**, la misura finale: `docs/costi/costo_per_utente_dopo_ex.md`
- **EX.04**, il Vai piu' a fondo gia' pronto (EX Aggiunta 4): `docs/collaudo/EX/realme/vai_piu_a_fondo_2294_registro.txt`
- **EX.05**, la cache spenta, con la soglia e il motivo (EX Aggiunta 5): `docs/collaudo/EX/la_cache_garantita.txt`
- **EX.10**, il Viaggio col risultato misurato (EX Aggiunta 5): `docs/collaudo/EX/la_scena_con_meno_scarti.txt`
- **EX.12**, il gesto in Settimana, Mese e Anno (EX Aggiunta 5), a video sul Realme con la build 2295: `docs/collaudo/EX/realme/ex12_e_piani_2295.txt`
- **EX Aggiunta 6**, i minuti del LIVE 80 e 150 e le descrizioni dei piani: `docs/collaudo/EX/minuti_e_descrizioni.txt`

E l'EX Aggiunta 3, le domande alzate: `docs/collaudo/EX/le_domande_alzate.txt`.

## Le voci aperte, e che cosa manca

**Dopo le EX Aggiunte 5 e 6 (3 ottobre 2026) resta aperta una voce sola,
l'EX.07.** Le parole riservate si correggono corte e nessuna risposta
peggiora (0 su 27 consegnate con una parola altrui, prima e dopo; alla cieca
il codice finale e' pari o meglio su ogni misura), ma le chiamate per risposta
sono 1,38, 1,29 e 1,25 nei tre giri finali: l'1,3 non regge in tutti i giri.
Le chiamate in piu' vengono soprattutto dalla rete delle certezze. E
l'attribuzione alla cieca arriva a 58 su 60 in un giro su tre (57, 58, 56),
con l'istruzione identica a quella dell'Aggiunta 4.
`docs/collaudo/EX/le_ultime_voci.txt`. Le righe qui sotto sono lo stato di
prima, com'era.

- **EX.04**, il Vai piu' a fondo scritto insieme: 20 tocchi su 24 senza
  chiamata (prima 0), 0,17 chiamate al tocco invece di 0. **Dopo l'EX
  Aggiunta 4**: 0 chiamate al tocco in sei giri su sei (144 tocchi), il
  seguito che non arriva con la risposta si prepara in sottofondo; seguito
  alla cieca 20 e 21 contro 14 e 18 su 24. Manca il tocco guardato a video
  sul Realme con la build nuova.
- **EX.05**, la cache garantita: la parte comune e' in testa, ma la cache
  implicita non e' garantita e quella esplicita oggi costerebbe piu' di quanto
  fa risparmiare. **Dopo l'EX Aggiunta 4**: scritta e provata (soglia 23
  richieste all'ora, spenta sotto 18; traffico simulato 2 su 2; risparmio 50 per
  cento a 50 all'ora, 80 a 200), ma la via della cache peggiora il cielo (7
  contro 10 su 10) e il seguito alla lettura alla cieca: resta spenta, niente
  da pubblicare. `docs/collaudo/EX/la_cache_garantita.txt`.
- **EX.07**, meno risposte rifatte: da 2,46 a 1,71 chiamate per risposta,
  l'obiettivo verso 1,3 non e' raggiunto. **Dopo l'EX Aggiunta 4**: 1,29 di
  media sui sette giri, ma 1,33 e 1,38 sui due giri del codice finale; il
  residuo e' la rete del lessico ("sentire", "ascendente"), 5 risposte su 24.
  Le risposte non peggiorano: merito 27 e 27 contro 27 e 25.
  `docs/collaudo/EX/risposte_rifatte.txt`.
- **EX.10**, la scena del Viaggio senza modello: le tre vie misurate peggiorano
  il merito; il codice resta com'e'. **Dopo l'EX Aggiunta 4**: scena da 2,70 a
  1,80-1,90 chiamate per discesa con le stesse guardie (la frase scartata tolta
  in casa, due riserve dalla stessa chiamata), merito pari; gli obiettivi 1,5 e
  2,5 non sono raggiunti. `docs/collaudo/EX/la_scena_con_meno_scarti.txt`.

L'EX Aggiunta 4 per intero, con domanda, prova e misura di ogni voce:
`docs/collaudo/EX/le_quattro_voci_sistemate.txt`.

## La build 2295 e Codemagic (EX Aggiunte 5 e 6)

- Build Android 2295 dal commit `aafdd96b` (cancello verde,
  `refs/verde/aafdd96ba1bee2dc28bb48aaf3b2f20e62e60275`), consegnata su App
  Tester il 3 ottobre 2026: release `12d92pon7vjao`, distribuita a
  cloud@esotericircle.app, 1 invito accettato; `docs/versione_distribuita.json`
  da 2294 a 2295.
- La suite intera sul commit `cae0d3e5`: +6580 ~11 -11, sette rosse accettate
  e quattro nuove, curate nel commit `aafdd96b` (padre: la prima stesura
  dell'EX.07). Lo sbarramento sul commit `aafdd96b`: 6.584 prove, solo i rossi
  accettati.
- Per Codemagic: il commit `aafdd96b`, col cancello verde.
- Sul Realme, la stessa build: Settimana, Mese e Anno col gesto nelle tre
  tradizioni e l'oroscopo dell'amico (EX.12 chiusa); le card e la tabella dei
  piani coi numeri della matrice.
- **Una funzione del server da pubblicare, la pubblica il fondatore**:
  `apriUnaSessioneLive`, l'unica che legge `MINUTI_DEL_MESE`. Da PowerShell,
  nella copia di lavoro: `cd C:\Users\user\Desktop\esoteric-circle-app`,
  `git pull`, `firebase deploy --only functions:apriUnaSessioneLive`. Finche'
  non e' ripubblicata il server dice 60 e 120 minuti e le card 80 e 150.
  **Pubblicata** dal fondatore il 4 ottobre 2026 alle 01:02, dalla copia
  di lavoro di Code al commit `f414b0f6` ("Deploy complete!"; in sola
  lettura `updateTime` 2026-10-03T23:02:12Z, stato ACTIVE).
- I testi degli store: lasciati stare, i prodotti negli store non esistono
  ancora (decisione del fondatore).

## La build 2294 e Codemagic (EX Aggiunta 4)

- Build Android 2294 dal commit `6d96fb91` (cancello verde), consegnata su App
  Tester il 3 ottobre 2026: release `4l2al7v4k1480`, distribuita a
  cloud@esotericircle.app, 1 invito accettato; `docs/versione_distribuita.json`
  da 2293 a 2294.
- Lo sbarramento: 6.575 prove, solo i rossi accettati dal fondatore; al primo
  giro aveva preso un si' con l'apostrofo nello storico delle impronte
  (padre: l'aggiunta), corretto prima della consegna.
- Per Codemagic: il commit `6d96fb91`, col cancello verde.
- Sul Realme, la stessa build: il Vai piu' a fondo si apre senza chiamata
  (EX.04 chiusa).
- Nessuna funzione del server da pubblicare.

## La build 2293 e Codemagic

- Build Android 2293 dal commit `2a811596` (cancello verde), consegnata su App
  Tester: release `2hhg5dlk19l30`, distribuita a cloud@esotericircle.app, 1
  invito accettato; `docs/versione_distribuita.json` da 2292 a 2293.
- Lo sbarramento: 6.548 prove, solo i rossi accettati dal fondatore.
- Per Codemagic: il commit e il cancello stanno nell'ultimo messaggio di Code
  al fondatore e in STATO_VIVO; il codice dell'app e' quello di `2a811596`.

## Il costo per piano, prima e dopo, accanto al tetto

Al massimo per trenta giorni, senza cache, LIVE compreso
(`docs/costi/costo_per_utente_dopo_ex.md`):

| Piano | Prima | Dopo l'EX.02 (3, 6, 10, 13 domande) | Dopo l'EX Aggiunta 3 (3, 12, 18, 22 domande) | Tetto |
|---|---|---|---|---|
| Viandante | 0,84 $ | 0,53 $ | 0,53 $ | |
| Iniziato | 5,66 $ | 1,28 $ | 2,18 $ | 2,36 $ |
| Adepto | 11,90 $ | 3,34 $ | 4,54 $ | 4,72 $ |
| Illuminato | 31,73 $ | 5,42 $ | 6,77 $ | 7,08 $ |

Sotto il tetto starebbero ancora, al giorno, circa 7 domande in piu'
all'Iniziato, 9 all'Adepto e 11 all'Illuminato.

## Il confronto alla cieca, voce per voce

Due giudici per confronto, il secondo legge all'indietro; rumore fra due giri
dello stesso codice circa 2 o 3 punti per misura.

| Voce | Confronto | Giudice 1 | Giudice 2 |
|---|---|---|---|
| Tutte le voci della chat (EX.04, 05, 07, 08, 09) | banco intero, giro finale fine4 contro prima2, 30 casi | regole 29-28, memoria 9-8, cielo 9-9, merito 27-25, seguito 14-16 | regole 28-29, memoria 9-10, cielo 9-9, merito 26-24, seguito 13-14 |
| EX.04 prima della cura | giro fine3 | seguito 9-13 | seguito 7-11 |
| EX.07 | correzione corta contro intera, stessa risposta scartata, due giri sommati | regole 39-39, memoria 28-25, merito 36-35 | regole 38-36, memoria 27-24, merito 38-39 |
| EX.09 | dettaglio detto prima, 10 conversazioni | memoria 7-4, merito 8-7 | memoria 7-4, merito 8-5 |
| EX.10 | scena di casa | merito 1-12 | merito 0-12 |
| EX.10 | un tentativo | merito 3-11 | merito 6-10 |
| EX.10 | due tentativi | merito 7-10 | merito 6-9 |
| EX.05 | attribuzione dei Maestri | 56 su 60, ogni Maestro sopra 85 per cento | |

I fascicoli e i giudizi: `docs/collaudo/EX/qualita/` (finale4, finale3,
corta_giro1, corta, memoria_compatta, viaggio, viaggio1, viaggio2).

## La specifica delle rune per l'Architetto

`docs/corpus/rune/SPECIFICA.md`, spinta per prima (commit `44004806`): 4.929
voci in 140 gruppi per 60 giorni senza ripetere. L'Architetto ha consegnato
5.411 voci; tutte le prove passano.

## Il costo delle prove

Al massimo 3,19 dollari di Gemini in europe-west1, nessun costo di Protoface
(`docs/collaudo/EX/il_costo_delle_prove.txt`).

## I difetti, ognuno col padre

Dalle EX Aggiunte 5 e 6:
- La correzione corta del lessico toglieva la parola dalla risposta e la
  rimetteva nel seguito che riscriveva: padre la prima stesura dell'EX.07 di
  quest'aggiunta; curato (A29).
- La correzione corta da sola consegnava 2 risposte su 27 con una parola
  altrui contro 0 del codice di prima: padre la prima stesura dell'EX.07;
  curato col ripiego sulla risposta intera (A30).
- Quattro prove della suite intera rosse: la rete del lessico spostata nel
  controller scattava anche con le voci finte, che non passano dalla voce
  sorvegliata, e chiedeva la risposta intera due volte: padre la prima
  stesura dell'EX.07; curato.
- 28 prove dell'oroscopo rosse con le letture dietro il gesto, poi due per la
  card della Settimana legata alla fase: padre la prima stesura dell'EX.12;
  curato con l'interruttore spento nella suite e la condizione della card.
- I conti del costo scritti da Python su Windows in cp1252: padre questa
  aggiunta; rigenerati in UTF-8.
- I giri del banco `ex07k` sovrascritto per un nome gia' usato
  dall'Aggiunta 4: padre questa aggiunta; rimesso dal commit, i giri nuovi
  hanno il prefisso `ag5_`.

Dall'EX Aggiunta 4:
- La preparazione del seguito partiva anche all'apertura della chat, una
  chiamata a ogni apertura: padre EX Aggiunta 4, EX.04; tolta.
- Il sollecito del rimando sostituiva la risposta buona con "ho bisogno che tu
  mi dica quale data" quando il cielo del giorno era gia' dato: padre EX
  Aggiunta 4, EX.07; curato (A20).
- "Da dove riparto?" letta da si' o no: padre ordine ET voce 01; curato (A16).
- La rete delle certezze scartava il cielo calcolato: padre ordine ET voce 01;
  curato (A19).
- La rete del lessico contava le parole scritte dalla persona: padre ordine EC
  voce 03; curato (A18).
- La guardia delle etichette era cieca alle chiamate dal template: padre
  ordine EW voce 03; allargata (A25).
- Il controllo delle parole dopo il controllo finale (prima_la_sua_arte), il
  settimo punto di ripulitura diventato ottavo (consulta_maestro), l'impronta
  dell'istruzione cambiata: padre EX Aggiunta 4, presi dalla suite intera e
  curati.
- Il pareggio della cache scritto 33,4 invece di 33,3: padre EX Aggiunta 4,
  preso dalla prova stessa.
- Nella via della cache il cielo di oggi si confonde col giorno chiesto e il
  seguito e' piu' generico: padre EX Aggiunta 4, EX.05; non curato, la via
  resta spenta.

- Il seguito nascosto arrivava in 6 risposte su 24: padre **EX.04**, curato.
- Il seguito giudicato generico (9-13, 7-11): padre **EX.04**, curato con le
  righe su cosa deve portare.
- "Giove in Cancro" scritto da una correzione corta: padre **EX.07**, curato.
- Il blocco del cielo copiato in una risposta: padre **EX.08**, curato.
- Il Consiglio dei Maestri mostrava solo il Maestro di partenza a un
  Iniziato che aveva pagato il suo unico confronto del giorno: padre **EX.02**
  (la chat registra il confronto e il Consiglio ricontrollava i rimasti; con
  tre confronti al giorno il difetto non si vedeva). Preso dalla cattura del
  Consiglio nella suite intera, curato.
- La memoria delle rune (`rune.presagio.`) fuori dalla verita' unica dei dati
  della persona: non si cancellava e non si consegnava. Padre **EX.03**,
  preso da `niente_resta_di_te`, curato.
- Le domande della gettata scritte una seconda volta nel codice del presagio:
  padre **EX.03**, curato (vengono da `DomandeDelCerchio`).
- Due virgole prima della "e" in istruzioni di Code (il seguito e la
  correzione): padri **EX.04** ed **EX.07**, curate.
- La frase "domande senza limiti" quando finiscono le domande: **PROVENIENZA
  IGNOTA**, curata.
- Il listino degli Eos disallineato dalla matrice, non montato da nessuna
  schermata: **PROVENIENZA IGNOTA**, da decidere.
- Il preambolo di `docs/corpus/rune.md` dice ancora "Gemini personalizza sul
  cielo": superato dalle rune senza cielo e dal corpus; e' un testo, lo
  aggiorna l'Architetto.

## Le due voci delle rune da correggere, per l'Architetto

- `pietra.md`, Uruz dritta, voce 56: "resti ben piantato" dice a chi legge di
  essere un uomo.
- `pietra.md`, Mannaz in ombra, voce 38: "giudichi te stesso", lo stesso.

Le ha fermate la guardia del genere nella suite intera. Code non le ha
toccate; il codice non le sceglie finche' non arrivano corrette
(`IlPresagioDalCorpus.vociTrattenute`). Altre quattordici voci segnalate dalle
guardie di casa sono figure del parlare o concordano con un'altra parola, e
sono dichiarate a frase: l'elenco e' in `docs/collaudo/EX/rune_senza_ripetizioni.txt`.

## Il Briefing, sezione 22

Non toccato. Le differenze fra il Briefing e la matrice nuova stanno in
`docs/costi/costo_per_utente_dopo_ex.md`, ultima sezione.

## Le decisioni prese con la scelta consigliata

Dalle EX Aggiunte 5 e 6:
- **La rete del lessico, dopo la correzione corta, ripiega sulla risposta
  intera** quando la parola resta: la regola NESSUNA RISPOSTA PEGGIORA viene
  prima del numero delle chiamate.
- **Il controller corregge il lessico solo con la voce sorvegliata**, che
  nell'app c'e' sempre: con le voci finte delle prove il turno resta com'era.
- **L'interruttore del gesto fuori dal Giorno e' spento nella suite**
  (`test/flutter_test_config.dart`) e riacceso nella sua prova, come il
  seguito in sottofondo.
- **L'amico ha solo il giorno**: Settimana, Mese e Anno non esistono per gli
  amici, il gesto c'e' sul giorno.

Dall'EX Aggiunta 4:
- **La via della cache resta spenta** in tre punti (l'interruttore dell'app,
  la funzione non esportata, la regola di Firestore fuori dal repository):
  alla lettura alla cieca peggiora il cielo e il seguito.
- **Il Viaggio resta a tre tentativi**: con due si scendeva a 1,65 chiamate,
  ma il merito perdeva 1 e 2 punti.
- **La preparazione del seguito e' spenta nella suite** (test/flutter_test_config.dart)
  e riaccesa nella sua prova: le prove che contano le chiamate della risposta
  ne vedrebbero una in piu' che non e' loro.
- **Le impronte dell'istruzione aggiornate** dopo l'attribuzione cieca
  sull'istruzione finale, 58 su 60.

- **EX.05**: la cache esplicita non si accende adesso; conviene sopra circa 33
  richieste all'ora della chat.
- **EX.10**: il Viaggio resta col modello finche' non c'e' una via che non
  peggiora il merito.
- **La memoria delle rune torna con l'account** (famiglia "rune" delle
  memorie custodite) e si scarica coi tuoi dati: senza, un telefono nuovo
  ripeterebbe voci gia' lette. Chi getta il telo al massimo ogni giorno puo'
  superare il peso di una famiglia (60.000 caratteri): allora il Cerchio
  tiene quella di prima.
- **La suite intera** sul commit finale prima di spingere: 6.546 verdi, 11
  saltate, 9 rosse; sette sono i rossi accettati dal fondatore (le soglie
  della scansione e le sei guardie degli ordini EI-EN), due nascevano dalla
  memoria delle rune e sono curati e rifatti uno per uno.
- **Build di collaudo sul Realme** col numero 2292, lo stesso della build
  installata: e' solo per guardare, non e' consegnata.
