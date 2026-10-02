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

E l'EX Aggiunta 3, le domande alzate: `docs/collaudo/EX/le_domande_alzate.txt`.

## Le voci aperte, e che cosa manca

- **EX.04**, il Vai piu' a fondo scritto insieme: 20 tocchi su 24 senza
  chiamata (prima 0), 0,17 chiamate al tocco invece di 0.
- **EX.05**, la cache garantita: la parte comune e' in testa, ma la cache
  implicita non e' garantita e quella esplicita oggi costerebbe piu' di quanto
  fa risparmiare.
- **EX.07**, meno risposte rifatte: da 2,46 a 1,71 chiamate per risposta,
  l'obiettivo verso 1,3 non e' raggiunto.
- **EX.10**, la scena del Viaggio senza modello: le tre vie misurate peggiorano
  il merito; il codice resta com'e'.

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
