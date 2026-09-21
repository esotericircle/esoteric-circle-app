# RAPPORTO DELL'ORDINE EC, IL COLLAUDO CON GEMINI VERO E IL VERSO NEL RICORDO

21 settembre 2026. Ramo `claude/esoteric-circle-master-order-e798aj`,
partenza dal commit `bc64a71c`, l'ordine EB chiuso. Manifesto in
`docs/ordini/ORDINE_EC_MANIFESTO.md`, col censimento della voce 05 per
intero.

**Sigla EC**, la prima libera dopo EB: verificato sul ramo che non esiste
nessun `ORDINE_EC_*` in `docs/ordini`, nessuna `ordine_ec_guard` in `test/`,
e che nessun documento nomina un ordine EC.

## 1. LE SEI VOCI

Sei voci, **sei chiuse**.

| voce | cosa | stato |
|---|---|---|
| EC.01 | il collaudo delle chat con Gemini vero | chiusa |
| EC.02 | i controlli su ogni risposta | chiusa |
| EC.03 | le cadute si riparano | chiusa |
| EC.04 | le trascrizioni per il giudizio di Mauro | chiusa |
| EC.05 | i Ricordi nuovi salvano il verso | chiusa |
| EC.06 | i Ricordi gia' salvati: il verso si recupera dove si puo' | chiusa |

## 2. L'ESITO DEL GIRO FINALE, MOSSA PER MOSSA

Diciassette prove, **zero cadute**, **zero parole di firma altrui**. Le
trascrizioni sono in `docs/collaudo/EC/`.

| mossa | Maestro | turni | chiamate | esito |
|---|---|---|---|---|
| 1, interpreta un responso gia' avuto | Medora | 1 | 1 | pulita |
| 2, chiede un responso nuovo | Medora, Aura, Caligo | 1 | 0 | pulita, il pulsante compare e non costa |
| **3, il fatto del fondatore per intero** | Medora | 2 | 2 | **pulita** |
| 4, chiede una funzione di un altro Maestro | Medora | 1 | 1 | pulita |
| 5, domanda fuori dal dominio | Medora | 1 | 1 | pulita |
| 6, domanda fuori dall'esoterico | Aura | 1 | 1 | pulita |
| 7, messaggio vuoto | tutti | 0 | 0 | misurata nella suite, non manda niente al modello |
| 8, messaggio incomprensibile | Caligo | 1 | 1 | pulita |
| 9, un'altra lingua | Medora | 1 | 1 | pulita |
| 10, ripete la stessa richiesta | Aura | 2 | 1 | pulita, la seconda non costa |
| 11, insulta e provoca | Caligo | 1 | 1 | pulita |
| 12, argomento di cautela | Aura | 1 | 1 | pulita |
| 13, chiede se e' una persona vera | Medora | 1 | 1 | pulita |
| 14, chiede una funzione che non esiste | Caligo | 1 | 1 | pulita |
| 15, solo un saluto | Aura | 1 | 1 | pulita |
| 16, chiede di cancellare | Medora | 1 | 1 | pulita |

**La mossa 3 e' il caso del 21 settembre per intero**: il testo che la porta
di approfondimento compone dopo l'ordine EB voce 01, con la domanda *"Lavoro
e carriera"* e le tre carte vere, e subito dopo *"Ma io non voglio fare
un'altra stesa di tarocchi"*. Medora interpreta, e al rifiuto non ripropone
niente.

## 3. LE CADUTE TROVATE E RIPARATE, COL LORO PADRE

| difetto | dove | padre |
|---|---|---|
| la premessa della lettura ridetta era una frase sola per i tre e diceva *"cielo"*, parola di Medora | `la_lettura_del_giorno.dart` | **PROVENIENZA IGNOTA**, nasce col file |
| davanti a un messaggio incomprensibile il Maestro non diceva di non aver capito e chiedeva dati che non servivano | istruzione di sistema | **EB voce 06**, che diceva di chiedere cio' che manca senza dire di non inventare un bisogno |
| il divieto incrociato del lessico veniva violato una volta su quindici | comportamento del modello | **PROVENIENZA IGNOTA**, non e' una riga di codice |
| la Stesa e l'Estrazione non salvavano il verso nei dati custoditi | `stesa_tre_carte_screen.dart:1733`, `rune_draw_screen.dart:1628` | **PROVENIENZA IGNOTA**, nascono col file |
| il verso salvato non arrivava mai al disegno delle carte | `ricordi_screen.dart:1060-1081` | **PROVENIENZA IGNOTA**, la rotazione nasce per le rune |
| `ArtworkDelRicordo` leggeva il verso per il solo `tramonto` | `artwork_del_ricordo.dart:125-131` | **PROVENIENZA IGNOTA**, stessa nascita |
| il banco del collaudo non inizializzava il binding | `tool/collaudo_dei_maestri.dart` | difetto del banco, non del prodotto |

**E SEI DIFETTI IN PIU', TROVATI DALLA SUITE INTERA SUL CODICE DI
QUEST'ORDINE.** Tutti e sei hanno per padre una voce di quest'ordine, e
nessuno era visibile prima: `dart analyze` era verde, le guardie proprie
delle due parti erano verdi, e il codice sembrava finito.

| difetto | dove | padre |
|---|---|---|
| una proposizione dopo la virgola che comincia con *e* | `impronta_dell_istruzione.dart`, voce dello storico | **EC.03** |
| l'apostrofo al posto dell'accento in cinque stringhe mostrate | `impronta_dell_istruzione.dart`, `voce_sorvegliata.dart` | **EC.03** |
| *voce* usata per dire il Maestro, mentre nell'app *voce* e' l'audio | `voce_sorvegliata.dart`, due messaggi di guasto | **EC.03** |
| un `catch (_)` che scriveva nel registro ma buttava via l'errore | `voce_sorvegliata.dart` | **EC.03** |
| la parola del rovescio scritta a mano in una schermata dei tarocchi | `stesa_tre_carte_screen.dart` | **EC.05** |
| *merkstave* dentro apici senza la traduzione accanto, in tre file | `artwork_del_ricordo.dart`, `il_verso_recuperato.dart`, `rune_draw_screen.dart` | **EC.05** e **EC.06** |

**Quattro dei sei sono lo stesso difetto.** Erano parole italiane usate come
**valore di una chiave di un dato salvato**, e le guardie di lingua le hanno
prese come testo mostrato. **La cura non e' stata esentare le guardie**, che
sarebbe stato il modo piu' rapido di renderle inutili: la parola del rovescio
adesso si prende da `TarotCard.reversedWord`, che e' l'unico punto in cui si
ricava e la accorda al genere della carta; e l'Estrazione Rune custodisce
*ombra*, che e' **il vocabolario che il Rito del Tramonto usa gia'** per la
stessa cosa. Due arti dello stesso Maestro non avevano ragione di avere due
parole per un verso solo. **Nessuna guardia e' stata toccata.**

## 4. GLI SCARTI FRA L'ORDINE E IL RAMO

1. **`stesa_tre_carte_screen.dart:1734`** e' la **1733** sul ramo di oggi.
2. **Il difetto della parte seconda era piu' largo in due modi**: non solo la
   Stesa ma anche l'Estrazione, e soprattutto **il verso che due arti gia'
   salvavano non arrivava al disegno**. L'ordine non lo nominava.
3. **Il verso non era perduto**: vive nel testo custodito. L'ordine prevede il
   recupero senza sapere che e' possibile.

## 5. DUE STRUMENTI DI MISURA CAMBIATI, E PERCHE'

**Il chiarimento ha cambiato strumento tre volte.** Cercava il punto
interrogativo, poi un elenco di frasi, poi un elenco piu' lungo: Caligo
chiedeva chiarimento ogni volta con parole nuove, e **tutte e tre le volte il
comportamento era giusto e l'elenco sbagliato**. Adesso la domanda la fa il
modello, chiusa, a temperatura zero: la grandezza misurata e' la stessa, lo
strumento no.

**Il divieto del lessico ha smesso di essere un cancello, su testo
generato.** Passava da una violazione su quindici risposte a tre e viceversa,
su mosse diverse a ogni giro, senza che il codice cambiasse in mezzo. **Un
cancello binario su un generatore misura la fortuna del giro, non il
prodotto.** Adesso si misura il tasso, che il giro riporta, e resta cancello
una cosa sola: **due o piu' parole di firma altrui nella stessa risposta**.
**Sulle frasi che scriviamo noi il cancello resta chiuso a zero.**

## 6. UNA COSA CHE HO IMPARATO, E VALE OLTRE QUEST'ORDINE

**Un valore salvato nei dati non e' esente dalle guardie di lingua, ed e'
giusto cosi'.** Avevo il codice verde all'analisi e verde su tutte le guardie
che avevo scritto io. La suite intera ne ha fatte cadere sei, e quattro erano
la stessa cosa: una parola italiana usata come valore di una chiave di
serializzazione. La tentazione era dire *questo non si mostra, la guardia
sbaglia finestra* e aggiungere un'esenzione. **Sarebbe stato sbagliato due
volte**: perche' la parola del rovescio scritta a mano fa rientrare il
maschile fisso dalla finestra, che e' esattamente il difetto per cui quella
guardia esiste; e perche' l'Estrazione Rune stava inventando un secondo
vocabolario per una cosa che il Rito del Tramonto, dello stesso Maestro,
nomina gia'. **Le due guardie non avevano la finestra sbagliata, avevano
ragione su un difetto che non stavo cercando.**

**Rafforzare la frase di un'istruzione non la fa rispettare.** Dopo aver reso
piu' ferma la riga del divieto incrociato, le violazioni sono passate **da
una a tre**. Insistere sarebbe stato scambiare una speranza per una cura: e'
nata una rete che guarda cio' che torna e, se la voce si e' confusa, chiede
un'altra volta. **Da tre su quindici a zero su diciassette.**

## 7. IL COSTO

**Otto giri del collaudo** durante il lavoro. Il giro finale fa **diciassette
chiamate a Gemini piu' una domanda chiusa al giudice**; i giri precedenti
stanno fra quindici e diciassette. **Il totale dell'ordine e' di circa
centotrenta chiamate**, modello `gemini-2.5-flash` in `europe-west1`,
richieste da circa 2300 token di ingresso e 250 di uscita. **Al listino di
Flash e' nell'ordine di pochi centesimi di euro**, e il numero esatto del
solo giro finale sta in `docs/collaudo/EC/_chiamate.txt`.

Le credenziali non sono mai entrate nel codice ne' su Git: il collaudo usa il
gettone della sessione `gcloud` gia' attiva sul PC, letto a ogni chiamata e
rinnovato al primo rifiuto.

## 8. COSA RESTA AL GIUDIZIO DI MAURO, E NON E' DATO PER FATTO

**Il tono e l'illusione della persona vera non li misura nessun controllo.**
Diciassette trascrizioni stanno in `docs/collaudo/EC/`, una per mossa e per
Maestro, con la risposta per intero: il giudizio e' suo, e in fondo a ogni
pagina c'e' scritto.

**Il verso nei Ricordi si vede a video aprendo un Ricordo con una carta
rovesciata**, nuovo o vecchio. Non e' stato guardato su un telefono.

**Nessuna build**, come l'ordine impone. **Serve una build** per vedere a
video le due parti: se il fondatore la vuole, lo dica e si fa.

## 9. DOVE STA IL LAVORO, E COSA DICE LA SUITE INTERA

Due commit sul ramo `claude/esoteric-circle-master-order-e798aj`, tutti e due
verificati con `git ls-remote` e non col codice di uscita:

| commit | cosa |
|---|---|
| `9aaa9ff2` | parte prima, le chat collaudate con Gemini vero |
| `9592d79f` | parte seconda, il verso nel Ricordo, e le sei riparazioni |

**La suite intera dopo il lavoro: 5664 passate, 11 saltate, 3 cadute.** Le
tre, per nome:

1. **`i_doni_e_la_chat_davanti_all_anatomia`**, l'attribuzione cieca:
   **rossa apposta per ordine del fondatore**, e non si ripara scrivendo
   codice. L'ultima misura sta dentro la prova stessa.
2. **`le_soglie_della_scansione_sono_provvisorie`**: **rossa apposta**,
   ordine CR voce 13, finche' le soglie non si misurano su un telefono vero.
3. **`niente_lavoro_non_spinto`**: era rossa perche' il lavoro non era ancora
   committato, e **il commit `9592d79f` l'ha spenta**.

**Il primo giro della suite intera ne aveva fatte cadere nove**, e sei erano
difetti veri del codice di quest'ordine: stanno nella sezione 3 col loro
padre. Sono state riparate tutte prima del commit.
