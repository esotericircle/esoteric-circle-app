# La scansione dell'app, ordine CS parte seconda

6 settembre 2026. Ordinata dal fondatore dopo aver letto nel tooltip degli
Angeli che le tavole originali non erano state consultate:

> *"Adesso ho il dubbio che ci siano altre funzionalita' che sono state trattate
> con superficialita'. sistema tutto e fai fare una scansione a Code di tutta
> l'app: NON SOLO DEVE INDIVIDUARE DEBOLEZZE E SUPERFICIALITA', ma anche
> VERIFICARE SE NON SI POSSA FARE DI PIU' OVVERO SE CI SONO MANCANZE DA
> COLMARE."*

**Questa scansione non ripara niente**, tranne gli angeli della parte prima.
Produce un elenco: cosa riparare, in quale ordine e quando lo decide il
fondatore leggendo.

---

## I NUMERI IN TESTA

| | |
|---|---|
| Funzioni scansionate | **15** |
| di cui arti dichiarate attive nel catalogo | 9 |
| di cui Doni del giorno | 5 |
| di cui vive ma NON dichiarate attive | 1 |
| Arti nel catalogo, in tutto | 57 |
| Voci **GRAVI** | **0** |
| Voci **SERIE** | **7** |
| Voci **MINORI** | **4** |
| Voci **OCCASIONE** | **5** |
| Funzioni risultate NON VERIFICABILI senza un telefono | **2** |
| Funzioni dichiarate NON VERIFICATE in questa scansione | **1** |

**Il primo conto diceva otto arti attive, ed era sbagliato.** Il comando che
lo produceva guardava sei righe sopra ogni stato e perdeva le voci col
teaser lungo. Ricontate riga per riga risalendo all'id piu' vicino, sono
**nove**, e la Meditazione era fra quelle perse. Il conto giusto e' scritto
qui perche' il primo era stato gia' detto.

**Due accuse del Backlog sono state riverificate per prime, come l'ordine
chiede, e tutte e due sono SCADUTE.** Erano le candidate a essere le voci piu'
gravi dell'intera scansione, e non lo sono piu': il dettaglio nelle voci S1 e
M1.

---

# GRAVE

*L'app dice il falso alla persona, o produce un responso senza il dato che
dichiara di usare.*

**Nessuna voce.** Il difetto della Costellazione del Viso, che era l'unico
esemplare accertato di questa famiglia, e' stato chiuso il 6 settembre con
l'ordine CR: il motore adesso pretende due punteggi di confidenza e il cancello
rifiuta una lettura piu' vecchia di quattro decimi di secondo.

**Va detto che questo livello e' vuoto per misura, non per fiducia**: le tre
forme che l'ordine chiedeva di cercare sono state cercate tutte e tre. I
ripieghi che si attivano da soli esistono ancora in due punti, la carta natale
e la chat, ma **si dichiarano entrambi a chi legge**, con la causa e con la
distinzione fra cio' che la persona puo' risolvere e cio' che non dipende da
lei.

---

# SERIO

*La fonte e' di seconda mano, o la promessa e' piu' grande di cio' che il codice
fa.*

## S1. L'Oroscopo non usa piu' l'hash, ma la meta' delle persone riceve un ripiego

**Famiglia due.** Il Backlog dichiara che *"l'Oroscopo Personalizzato non calcola
transiti, usa un hash FNV-1a su segno, giorno, anno e dominio"*.

**Misurato: non e' piu' vero.** `lib/core/horoscope/cielo_di_oggi.dart` calcola
il cielo reale, cioe' gli aspetti fra i pianeti di oggi e la carta natale, la
casa che ogni pianeta attraversa e chi e' retrogrado. La schermata lo chiama a
`oroscopo_screen.dart:377` e usa `cielo.ceCieloVero`.

**Cio' che resta serio.** L'hash FNV c'e' ancora in `horoscope.dart` ed e' il
ripiego di chi non ha una carta natale completa. `CorrenteDelCielo.notaDelLivello`
lo dichiara a video con due frasi diverse, una per chi ha solo il segno e una per
chi ha la carta senza ora. **Questo e' fatto bene.** Il punto serio e' un altro:
non e' misurato **quante persone** finiscono nel ripiego, e senza quel numero non
si sa se il cielo vero e' la regola o l'eccezione.

**Cosa servirebbe per chiuderla:** un conto, anche solo in sviluppo, di quante
carte natali risultano complete, senza ora e assenti.

## S2. Tarocchi, Sinastria VIP, Sigillo e Soffio non dichiarano nessuna fonte a video

**Famiglia uno.** E' lo stesso difetto che ha aperto questo ordine, in quattro
punti diversi.

| funzione | dichiarazioni di fonte nella schermata |
|---|---|
| Estrazione Rune | 8 |
| Runa del Tramonto | 8 |
| Oroscopo | 8 |
| Arcano del Giorno | 5 |
| Sigillo del Sogno | 3 |
| Rito dell'Alba | 2 |
| **Stesa di Tarocchi** | **0** |
| **Sinastria VIP** | **0** |
| **Sigillo dell'Intenzione** | **0** |
| **Soffio del Destino** | **0** |
| Meditazione | 2 |

**Il caso piu' netto e' il Sigillo dell'Intenzione**, perche' la fonte c'e' e non
arriva a chi legge: il commento in testa a
`sigillo_intenzione_screen.dart:23` dichiara *"il metodo e' quello di Austin
Osman Spare per le lettere e la Rosa dei Petali della Golden Dawn per la ruota"*.
Due tradizioni precise, nominate nel codice e mai a video.

**Lo stesso vale per la Sinastria VIP**: `altre_affinita.dart:19` scrive
*"dalle qualita' cardinale, fissa e mobile (stessa fonte, I.12)"*, e quella
fonte in schermata non compare da nessuna parte.

**Cosa servirebbe per chiuderla:** quattro tooltip *Fonti e metodo*, sul modello
di quello degli Angeli.

## S3. L'Angelo Custode e' vivo e il catalogo lo dice «in arrivo»

**Famiglia tre, ed e' la promessa al contrario.** `art_catalog.dart:362` dichiara
`guardian_angel` come `ArtState.inArrivo`. Ma `AngelsScreen` e' raggiungibile da
due punti dell'app, `birth_companions.dart:88` e
`cosmic_passport_screen.dart:425`, **e il fondatore l'ha aperta lui stesso**: e'
da li' che nasce questo ordine.

**Perche' e' seria e non minore.** Il catalogo delle arti e' cio' che una persona
legge per sapere cosa l'app fa. Una funzione viva marcata «in arrivo» e' un
pezzo di prodotto che nessuno trova, e chi lo trova per caso non sa se puo'
fidarsi di quello che vede.

**Cosa servirebbe per chiuderla:** cambiare uno stato, e verificare se ce ne sono
altri nella stessa condizione. **Non l'ho fatto**, perche' questa parte non
ripara.

## S4. La personalizzazione del Rito dell'Alba vale solo per il segno solare

**Famiglia due, forma c.** Il seme dell'Alba, `rito_alba.dart:549`, e' costruito
su tre cose: la data, il Maestro di turno e **il solo segno solare** di nascita.
Il Maestro di turno e' lo stesso per tutti quel giorno.

**Il conto:** in un dato giorno esistono al massimo **dodici** Riti dell'Alba
diversi in tutto il mondo. Due persone dello stesso segno leggono la stessa
identica cosa.

**Perche' e' seria.** L'Arcano del Giorno ha risolto lo stesso identico problema
con l'ordine CQ voce 2.05, e la ragione e' scritta nel codice:
*"due persone con la stessa carta natale vedevano la stessa carta ogni giorno,
per sempre"*. Adesso l'Arcano usa la data di nascita intera e l'ora. **L'Alba e'
rimasta indietro**, e nessuno se n'e' accorto perche' la correzione era stata
fatta su un'arte sola.

**Cosa servirebbe per chiuderla:** portare nel seme dell'Alba la data di nascita
intera, come l'Arcano gia' fa. E' una riga.

## S4bis. La Meditazione era stata saltata da questa scansione

**Famiglia uno, e la voce nasce da un mio errore di conto.** La Meditazione e'
la nona arte attiva e il primo passaggio non l'aveva vista. Ricontrollata:
dichiara la fonte a video in due punti, e non rientra quindi nella voce S2.

**Cio' che resta da guardare e non ho guardato:** se le tracce audio della
Meditazione siano quelle scelte dal fondatore o i segnaposto generati che
l'ordine CQ ha misurato in `assets/audio`. Quella misura riguardava i suoni
dell'Oroscopo, e **non e' stata rifatta qui**: la dichiaro NON VERIFICATA
invece di estenderle il giudizio di un'altra funzione.

## S5. Nessuna funzione dichiara quale porzione del suo corpus e' verificata

**Famiglia uno.** Il corpus degli Angeli porta un campo `confidence` per voce, e
il corpus delle Rune dichiara le sue strofe con la fonte. **Nessuna delle due
cose arriva a video come misura**: la persona vede un responso e non sa se quella
riga poggia su una fonte primaria, su un repertorio o sulla curatela redazionale.

Il corpus degli Angeli lo dice esplicitamente di se stesso: *"Sulle chiavi di
lettura e sull'ombra: sono scritte in redazione, non sono tradizione documentata
e i verificatori lo hanno segnalato in ogni coro. Vanno mostrate come chiave di
lettura del Maestro, mai attribuite alla tradizione"*.

**Cosa servirebbe per chiuderla:** una regola di presentazione unica, che separi
visibilmente il documentato dal redazionale in tutte le arti.

## S6. Due funzioni non sono verificabili senza un telefono

**Famiglia due.** Sono la **Costellazione del Viso** e tutto cio' che passa dai
sensori. Le guardie provano la logica; che la fotocamera veda un volto, che i
punti si posino sui tratti giusti e che l'occhio sinistro sia il sinistro **non
si prova senza un dispositivo**.

Lo scrivo qui come l'ordine chiede, invece di darle per buone: **NON
VERIFICABILI** con gli strumenti di questa scansione.

---

# MINORE

*Imprecisioni, commenti stantii, dichiarazioni imperfette.*

## M1. I pool statici dei Doni esistono ancora e non li chiama piu' nessuno

**Famiglia due, e l'accusa del Backlog e' scaduta.** Il Backlog dichiara che *"i
Doni del Giorno sono pool statici per giorno ordinale"*.

**Misurato, contando i chiamanti in `lib/`:**

| funzione in `daily_rituals.dart` | chiamanti |
|---|---|
| `dawnMessage` | **0** |
| `nightMessage` | **0** |
| `destinyFragment` | **0** |
| `dayOracle` | **0** |
| `dawnMaestro` | 10 |

I quattro pool statici sono **codice morto**. I Doni hanno motori propri:
`rito_alba.dart`, `risposta_del_soffio.dart`, `arcano_del_giorno.dart`,
`SunsetRune.estrai`. **L'unica cosa ancora viva e' la rotazione del Maestro di
turno**, che e' una rotazione dichiarata e non una personalizzazione promessa.

**Perche' e' minore e non nulla:** codice morto che descrive un comportamento
che l'app non ha piu' e' una trappola per chi legge dopo. Il commento alla riga
50 dello stesso file, che spiega perche' la Runa del Tramonto e' stata tolta da
li', e' invece un ottimo esempio del contrario.

## M2. Il Backlog dichiara un corpus dell'I Ching che non esiste

**Famiglia quattro, pista verificata e caduta.** L'ordine indicava fra le piste
*"il corpus dei sessantaquattro esagrammi dell'I Ching, scritto e mai usato da
alcuna funzione"*.

**Misurato: quel corpus non esiste.** In `docs/corpus/` non c'e' nessun file
degli esagrammi, e in tutto il repository la parola compare solo in
`docs/03_Linee_Guida_UX_Trasversali.md` e negli elenchi delle arti future.
L'arte `i_ching` esiste nel catalogo come voce non attiva.

**Non e' un'occasione**, e per la voce CS.07 non la conto come tale.

## M3. Tre voci del corpus degli Angeli non dichiarano la numerazione dei salmi

**Famiglia uno.** Sono la 20 Pahaliah, la 22 Ieiaiel e la 24 Haheuiah. Dal salmo
9 in poi la numerazione della Vulgata e quella ebraica divergono di uno, quindi
un numero senza la sua numerazione e' ambiguo. Le altre sessantanove la
dichiarano. Dettaglio in `docs/angeli_verifica_lenain.md`.

## M4. Due angeli condividono lo stesso versetto, e la cosa non e' spiegata

**Famiglia uno.** Achaiah, il settimo, e Daniel, il cinquantesimo, ricevono lo
stesso versetto. **Sta cosi' nella fonte del 1823**, verificato leggendo le due
voci. Ma chi apre l'app e per caso vede tutti e due si trova davanti a un
doppione che sembra un errore nostro, e nessuna riga glielo spiega.

---

# OCCASIONE

*Cio' che si potrebbe fare con quello che gia' esiste.*

## O1. Settantatre arte degli Angeli nel pacchetto, e nessun Oracolo che le usi

**Costo stimato: medio.** In `assets/img/angeli/` ci sono **73 file**, cioe' i
settantadue piu' il dorso, gia' dentro il pacchetto dell'app. Il corpus dei
settantadue e' completo, verificato sulla fonte primaria con la parte prima di
questo ordine. L'arte `angels_oracle`, *"La stesa dei settantadue nomi, per una
risposta alta"*, e' `ArtState.inArrivo`.

**Cosa esiste gia':** le immagini, i nomi, i cori, gli archi di gradi, i salmi,
la chiave di lettura, la politica di pubblicazione, e la meccanica di una stesa
funzionante nei Tarocchi.

## O2. Dodici cristalli disegnati, e nessun Oracolo dei Cristalli

**Costo stimato: medio.** In `assets/img/cristalli/` ci sono **12 file**. Il
corpus `docs/corpus/cristalli.md` esiste. L'arte `crystal_oracle`, *"Estrai la
pietra che ti parla oggi"*, e' `ArtState.inArrivo`.

E' la stessa forma dell'occasione O1, con un mazzo piu' piccolo e quindi piu'
rapido da montare.

## O3. La Carta di Nascita dei Tarocchi entra solo in un seme

**Costo stimato: basso.** `CartaDiNascitaDeiTarocchi.numeroDi` calcola l'Arcano
maggiore che corrisponde alla data di nascita di una persona, ed e' un legame
che la tradizione del mazzo offre per nome. **Oggi entra come uno dei fattori
del seme dell'Arcano del Giorno, e da nessun'altra parte.**

Chi apre l'app non vede mai qual e' la propria Carta di Nascita, ne' cosa dice.

**Cosa esiste gia':** il calcolo, il corpus dei ventidue Arcani maggiori con le
letture diritte, e le immagini del mazzo.

## O4. Il cielo di oggi si calcola per l'Oroscopo e per nient'altro

**Costo stimato: basso.** `CieloDiOggi` produce i fatti astronomici veri di
oggi sopra una persona: aspetti sui punti natali, case attraversate, retrogradi.
**Lo consuma soltanto l'Oroscopo.**

Il Calendario degli Eventi legge il livello di personalizzazione ma non i fatti;
la Sinastria ha un suo `cielo_del_giorno_sulla_coppia.dart` che lavora in
parallelo. Un fatto calcolato una volta e usato da una funzione sola e'
esattamente la forma che l'ordine chiede di cercare.

## O5. Il Rito dell'Alba puo' diventare individuale con una riga

**Costo stimato: molto basso.** E' l'altra faccia della voce S4. L'Arcano del
Giorno ha gia' il codice che fa esattamente questo, e il commento che spiega
perche' serve. Portarlo nell'Alba e' una modifica di un seme.

---

## COSA QUESTA SCANSIONE NON HA GUARDATO, dichiarato

- **Il listino dei piani e i testi delle soglie** non sono stati confrontati riga
  per riga col codice degli entitlement. Esiste gia' nel progetto una guardia che
  ancora le affermazioni della privacy policy al codice, e l'ordine chiede di
  dire se puo' essere estesa: **puo'**, e' la stessa forma, un elenco di
  affermazioni e un punto del codice per ognuna. Non l'ho fatto perche' questa
  parte non ripara.
- **Le 48 arti non attive** del catalogo, che sono dichiarazioni di intenzione
  e non promesse mantenute o tradite.
- **I testi dei Maestri nella chat**, che passano dall'AI e non da un corpus
  fisso, e che una scansione statica non puo' misurare.
