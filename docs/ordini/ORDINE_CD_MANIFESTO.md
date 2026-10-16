# ORDINE CD, IL CENSIMENTO E LA SINASTRIA

Ordine del fondatore del 30 agosto 2026, due voci. Le sue parole sono quelle del
29 agosto, riportate verbatim e integrali. Guardia
`test/ordine_cd_guard_test.dart`.

Porta le tre regole degli ordini precedenti:

- **REGOLA ZERO.** Il testo di quest'ordine non e' affidabile e l'Architetto non
  e' affidabile: ogni affermazione si verifica sul ramo prima di usarla,
  compresa la lettera dell'ordine.
- **REGOLA UNO.** Non ci si ferma, si risolve, e ogni scelta si motiva.
- **REGOLA DUE.** Qui dentro ci sono solo le parole del fondatore.

## Le due voci

- **CD.01** Il censimento delle dimensioni dei caratteri. **CHIUSA.** Era gia' fatto per intero dall'ordine CC voce 05, verificato sul codice e non sul manifesto: 22 arti, zero fuori misura, e i titoli gialli controllati come lui aveva chiesto.
- **CD.02** La Sinastria VIP, nove richieste. **CHIUSA.** Otto erano gia' fatte dall'ordine CC voce 06. Il lavoro nuovo e' quello che l'ordine chiede e che nessuno aveva fatto: **guardare**. Guardando sono usciti tre difetti veri.

VOCI_TOTALI: 2
VOCI_CHIUSE: 2
VOCI_APERTE: 0
VOCI_FERMATE_SU_PREMESSA_FALSA: 0
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0
VOCI_FERMATE_SU_DECISIONE_DEL_FONDATORE: 0

## LE AFFERMAZIONI DI QUESTO ORDINE CHE HO TROVATO FALSE

| # | l'ordine dice | esito | cosa ho trovato davvero, e come |
| --- | --- | --- | --- |
| P1 | la lettera libera e' CD | **vera** | in `docs/ordini/` ci sono CA, CB e CC; nessun `ORDINE_CD_*` |
| P2 | alcune richieste potrebbero essere gia' chiuse da CC.05 e CC.06 | **vera, e per quasi tutte** | verificate una per una **sul codice**: CD.01 gia' fatta per intero, e otto delle nove richieste di CD.02 gia' fatte. La tabella qui sotto le elenca |
| CD.02 | "Le sue richieste dentro quel blocco sono **otto** e nessuna si esclude" | **FALSA, sono nove** | l'ordine stesso le elenca da a) a i), che sono nove voci. Contate: a, b, c, d, e, f, g, h, i. Il numero scritto e' otto, l'elenco ne porta nove, e ho lavorato sull'elenco |

**Una terza cosa, che non e' un'affermazione ma un fatto del testo.** Dentro le
parole del fondatore, verbatim, c'e' la stringa `e5anxira` al posto di una
parola: "questo difetto e5anxira peggiore nella sinastria con 2 vip". E' un
refuso di battitura, e il senso resta chiaro, cioe' che il difetto e' **ancora
peggiore** con due VIP. L'ho letto cosi' e l'ho trattato cosi', senza correggere
le sue parole.

## COSA ERA GIA' FATTO

Verificato **sul codice del ramo**, non sul manifesto dell'ordine CC, come la
premessa P2 chiede. Ogni riga porta la misura che l'ho verificata.

| richiesta | gia' fatta? | dove, e la misura di oggi |
| --- | --- | --- |
| **CD.01**, tutte le descrizioni alla misura del responso dei Tarocchi | **si', per intero** | ordine CC voce 05. Misurato oggi: **22 arti censite, 0 senza la misura del responso**; **48 testi da leggere per intero, 0 fuori misura**; la misura di riferimento e' letta dal token, 18 punti con interlinea 1,55 |
| **CD.01**, "i titoli gialli vanno bene in generale, ma controllali" | **contati si', controllati no** | CC.05 li aveva contati, 119, per impedirne la crescita. **Non ne aveva guardato i valori.** Fatto adesso, qui sotto |
| **CD.02a**, le mappe con citta' di riferimento | **si'** | ordine CC voce 06a, `RiferimentiDellaMappa` in `mappa_della_distanza.dart`, fino a sei citta' prese dal catalogo per popolazione |
| **CD.02a**, le citta' dove vivono | **si'** | stesso file: il pittore riceve `tuaCitta` e `suaCitta` e le scrive accanto ai due punti |
| **CD.02a**, "nemmeno la nazione" | **NO** | nessuna nazione era scritta da nessuna parte. Fatto in quest'ordine |
| **CD.02b**, le linee da un punto all'altro del cerchio | **si'** | ordine CC voce 06b, `chiamata_del_vip.dart`: tutti e due i capi passano da `puntoDi(..., centro, raggio)`. Misurato oggi: **2 capi su 2 posati sul cerchio** |
| **CD.02c**, tre quarti alla risposta e un quarto ai transiti | **si'** | ordine CC voce 06c. Misurato oggi: corpo di 349 caratteri, di cui **58 tecnici, cioe' il 17 per cento** contro il 36 di prima |
| **CD.02d**, il paragrafo sull'attualita' | **si'** | ordine CC voce 06d, `_lAttualita` in `responso_della_sinastria.dart`. **Quattro frasi provvisorie e marcate come tali**: il corpus e' materia del fondatore |
| **CD.02e**, il testo goliardico | **si'** | ordine CC voce 06e. Misurato allora che il registro goliardico c'era gia' in tutte e quattro le famiglie del corpus: cio' che stonava era la clausola tecnica, uscita con la voce c |
| **CD.02f**, le barre subito dopo la bolla | **si'** | ordine CC voce 06f. Misurato oggi, in punti verticali: **bolla a 36.268, barre a 38.823, mappa a 41.338, fili a 41.900** |
| **CD.02g**, via il testo sull'ora ignota, e due righe al suo posto | **si'** | ordine CC voce 06g. Misurato oggi: le due righe ci sono in **ogni** responso, con SCONOSCIUTO quando il dato manca |
| **CD.02h**, il nome del personaggio nei tre transiti | **si'** | ordine CC voce 06h. Misurato oggi: "il Mercurio di Fedez in sestile alla tua Venere", e fra due VIP "il Mercurio di Fedez in sestile alla Venere di Chiara". **Aspetti calcolati 5, senza il nome 0** |
| **CD.02i**, i cartigli della carta ingrandita | **si'** | ordine CC voce 06i, `ritratto_ingrandito.dart` monta `VipFramedPortrait` invece dell'arte nuda |
| **CD.02**, le anteprime a 360 punti che l'ordine pretende | **NO, per la mappa e per la carta** | nessuna immagine esisteva ne' della mappa ne' della carta ingrandita. Fatte in quest'ordine, ed e' guardandole che sono usciti i difetti |

## CD.01, il censimento delle dimensioni dei caratteri

**CHIUSA.** Il lavoro era fatto; qui c'e' la verifica indipendente e la parte
che mancava.

### La verifica, rifatta sul codice

| misura | numero di oggi |
| --- | ---: |
| misura di riferimento, letta dal token del responso dei Tarocchi | 18,0 punti, interlinea 1,55 |
| arti censite | 22 |
| arti senza la misura del responso | **0** |
| testi da leggere per intero | 48 |
| testi fuori misura | **0** |

### La parte che mancava: i titoli gialli, controllati

Il fondatore aveva scritto "la grandezza dei titoli gialli vanno bene in
generale, **ma controllali**". CC.05 li aveva **contati**, 119, e messo una
guardia perche' quel numero non crescesse. **Nessuno ne aveva guardato i
valori.** Misurati adesso, su tutto `lib` fuori dai token:

| punti | quante volte |
| ---: | ---: |
| 16 | 21 |
| 17 | 8 |
| 18 | 19 |
| 19 | 14 |
| 20 | 25 |
| 21 | 2 |
| 22 | 9 |
| 24 | 4 |
| 26 | 4 |
| 28 | 3 |
| 30 | 4 |
| 32 | 2 |
| 36 | 1 |
| 40 | 2 |
| 64 | 1 |

**Quindici valori distinti su 119 usi, e il piu' piccolo e' 16.** Sedici non e'
un caso: e' il **pavimento** della famiglia display, e una prova che esiste gia',
`tipografia_minimi_test`, pretende che nessuna misura scenda sotto il minimo del
suo token, **con zero eccezioni dichiarate**. I valori alti non sono
incoerenza: 64 e' il numero dentro la ruota del respiro, 40 sono le carte da
condividere, 36 il titolo grande della Sinastria. **Sono titoli di cose diverse,
e il fondatore aveva detto che vanno bene.**

**Cosa difende oggi il codice, dopo il controllo:** il conto non puo' crescere
(guardia di CC.05), nessuna misura puo' scendere sotto il pavimento (guardia
esistente), e ogni descrizione sta alla misura del responso dei Tarocchi.

### Il rosso, dimostrato

Non nasce nessuna prova nuova, perche' la voce era gia' chiusa: si dimostra che
la guardia esistente **non dorme**. Rimessa `corpo()` al posto di `lettura()`
sull'annuncio di un'arte, verificato col grep che nel file non restasse nessuna
`lettura()` **prima** di leggere l'esito, la prova e' diventata rossa nominando
l'arte. Rimessa, verde.

### La frase di accettazione della voce CD.01

**Apri due arti qualsiasi e confronta i loro responsi: si leggono della stessa
misura, che e' quella del responso dei Tarocchi.**

## CD.02, la Sinastria VIP

**CHIUSA.** Otto richieste su nove erano gia' costruite. Il lavoro
di quest'ordine e' quello che l'ordine stesso pretende e che nessuno aveva
fatto: **guardare le voci visive a 360 punti**. Non esisteva nessuna immagine
ne' della mappa ne' della carta ingrandita, e l'unica immagine della schermata
mentiva.

### I tre difetti che sono usciti guardando

**1. L'anteprima della Sinastria mostrava ZERO PER CENTO.** L'anello grande era
vuoto col numero a zero, e le barre erano righe senza riempimento, mentre i
numeri accanto dicevano 62, 54, 74, 92. **Non era un difetto dell'app**,
verificato: `overall` vale 60 e su tutti e cinquanta i VIP **non e' mai zero**.
Era l'anteprima che scattava troppo presto. La schermata ha due scene in fila,
la chiamata e poi il verdetto che si compone contando, e la cattura aspettava
sei secondi; **l'ordine CA voce 03 ha portato la chiamata da 4.100 a 5.000
millesimi**, e da allora al sesto secondo il conteggio era appena partito.
Adesso la cattura aspetta la somma delle due scene con margine, e l'anello dice
**62 per cento** con il suo arco d'oro.

**Questo e' il difetto piu' grave dei tre**, e non perche' fosse rotto qualcosa:
perche' il fondatore ha giudicato per giorni una schermata che non esiste.

**2. La mappa non diceva la nazione, e lui l'aveva chiesta.** Le sue parole:
"non si capisce visivamente dove si trovano, **nemmeno la nazione**". Le citta'
di riferimento dell'ordine CC voce 06a rispondevano a meta': a chi conosce
Torino e Bologna dicono l'Italia, a chiunque altro no, e su due punti stranieri
non dicono niente. **Adesso sotto il nome della citta' c'e' il paese**, piu'
piccolo e piu' spento, e compare una volta sola quando i due punti stanno nello
stesso paese.

**Nessun dato nuovo:** la nazione si ricava dal catalogo dei luoghi che la mappa
gia' apre per scegliere i riferimenti, prendendo il paese della citta' piu'
vicina. Con i **40.846** luoghi che il catalogo ha dopo l'ordine CC voce 07, il
piu' vicino a una capitale e' la capitale stessa. Oltre tre gradi di distanza da
qualunque citta' conosciuta **non si dichiara niente**: meglio tacere che
scrivere il paese sbagliato per un punto in mezzo al mare.

**3. La cattura della mappa non esisteva**, e non per dimenticanza: sulla
schermata intera la mappa compare solo se l'app sa dove sei, e nell'anteprima
quel dato non c'e'. Adesso il pezzo si cattura con dati veri, Roma contro
Milano, che e' il caso duro che il fondatore descrive, cioe' due punti vicini.

### Le misure, in numeri

| misura | prima | dopo |
| --- | --- | --- |
| anello dell'anteprima della Sinastria | **0%**, arco vuoto | **62%**, arco d'oro |
| barre dell'anteprima | righe vuote | riempite, 62 / 54 / 74 / 92 / 52 |
| secondi che la cattura aspetta | 6 | **12**, cioe' chiamata piu' verdetto piu' margine |
| nazioni scritte sulla mappa | **0** | **1 per paese distinto**, "Italia" sotto Roma |
| citta' di riferimento sulla mappa Roma-Milano | 6 | 6, invariate: Torino, Genova, Verona, Venezia, Trieste, Bologna |
| anteprime della Sinastria che esistono | 3 | **5**, con la mappa e la carta ingrandita |

### Le anteprime, guardate una per una

- `docs/preview/sinastria-vip.png`, rigenerata: l'anello dice 62 per cento e le
  barre sono piene. **Prima diceva zero.**
- `docs/preview/sinastria-vip-basso.png`, rigenerata: le sette barre col loro
  riempimento, le due righe Ora di Nascita e Luogo di Residenza, i tre pulsanti
  dei transiti.
- `docs/preview/sinastria-mappa-vicini.png`, **nuova**: Roma e Milano a 477
  chilometri, sei citta' di riferimento attorno, e "Italia" sotto Roma.
- `docs/preview/sinastria-carta-ingrandita.png`, **nuova**: i due cartigli
  pieni, "CHIARA FERRAGNI" in alto e "7 MAGGIO 1987" in basso. La richiesta i)
  e' verificata guardando, non piu' soltanto leggendo il sorgente.

### Il rosso, dimostrato

**Sulla nazione**, che e' il lavoro nuovo: tolta la scrittura della nazione dal
pittore, verificato col grep che nel file non restasse nessun `tuaNazione`
scritto sulla tela **prima** di leggere l'esito, e la prova nuova e' diventata
rossa. Rimessa, verde.

### La frase di accettazione della voce CD.02

**Apri la Sinastria con un VIP che vive in una citta' nota: la mappa dice le due
citta', sei citta' attorno per capire dove sei, e sotto il tuo punto il nome del
paese. E l'anello grande non dice piu' zero.**

## LE SCELTE CHE HO PRESO IO E PERCHE'

- **La nazione si ricava dal catalogo dei luoghi e non da un campo nuovo.**
  Aggiungere il paese a `DoveSei` e a `PossibilitaDiIncontro` avrebbe voluto
  dire toccare quattro file per un dato che il catalogo gia' contiene, e avrebbe
  lasciato senza nazione le mappe fra due VIP.
- **Il paese si cerca una volta sola fuori dal pittore.** Il pittore ridipinge a
  ogni fotogramma della corsa dello zoom, e cercare la citta' piu' vicina fra
  quarantamila a ogni fotogramma sarebbe uno spreco che si vede.
- **Oltre tre gradi non si dichiara nessuna nazione.** Un punto in mezzo al mare
  prenderebbe il paese della costa piu' vicina, e scrivere il paese sbagliato e'
  peggio che non scriverne nessuno.
- **Il paese non si ripete quando e' lo stesso.** Due volte "Italia" su una
  mappa italiana e' rumore.
- **La mappa si cattura da sola e non dentro la schermata intera.** Sulla
  schermata la mappa compare solo se l'app sa dove sei, e seminare quel dato
  nell'anteprima avrebbe voluto dire una finta in piu' proprio nell'immagine che
  serve a giudicare la cosa vera.
- **Per la mappa si prendono Roma e Milano.** Il fondatore descrive il caso duro
  come "quando sono vicini": due punti a 477 chilometri sono quel caso, e Chiara
  Ferragni e' l'unica del catalogo che vive in Italia.
- **La cattura aspetta dodici secondi e non un numero a caso.** E' la somma
  delle due scene, la chiamata piu' il verdetto, piu' un secondo di margine.
- **Per CD.01 non nasce nessuna prova nuova.** La voce era chiusa e le due
  guardie che la difendono esistono gia': aggiungerne una terza sarebbe stato un
  doppione, e un doppione diverge. Si e' dimostrato invece che quelle non
  dormono.
