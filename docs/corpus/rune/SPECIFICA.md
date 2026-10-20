# Le rune senza modello: la specifica del corpus per l'Architetto

Ordine EX, voce EX.03, e la sua Aggiunta "La specifica delle rune per
prima". Scritta da Code il 2 ottobre 2026 sul codice del commit `666d0745`.

> *"Voglio corpus grandi, non voglio ripetizioni per almeno 60gg"*;
> *"pensavo che l'estrazione rune fosse a zero AI"*; *"Si certo."* (le rune
> deterministiche col corpus dell'Architetto).

**L'ORDINE GA, VOCE GA.07, ORDINA DI RISCRIVERE I TESTI DELLE RUNE.**
Integrazione del 20 ottobre 2026, sul commit `297cd46f`. Il fondatore, 19
ottobre 2026 alle 23:08: *"bisogna cambiare le regole per i responsi delle
funzionalità oroscopo, tarocchi, arcano angelo, estrazione rune: tutte le
risposte composte da paragrafi ognuno con tra 40 a 50 parole ognuno. Per le
risposte brevi 2 paragrafi di cui il secondo messo in evidenza in un riquadro
e questo riquadro deve intitolarsi "cosa fare adesso" e di conseguenza
adattare il testo."* (voce GA.03) e *"IMPORTANTE: risposte dirette
immediatamente, l'utente deve avere subito e sempre risposte senza fronzoli o
criptiche o includenti o sibilline."* (voce GA.06). La voce GA.07: *"I
corpora e i compositori delle quattro arti si riscrivono nella forma di GA.03
e con la regola di GA.06 [...] Nessun testo si tronca per rientrare nella
misura. Restano le regole di non ripetizione di ogni corpus"*. Le sezioni
qui sotto portano la forma nuova accanto a quella dell'ordine EX: dove le
due dicono cose diverse vale quella dell'ordine GA. Le rune restano a zero
modello: tutti i testi vengono dal corpus.

**Code non scrive nessun testo del corpus.** I testi sono materiale
dell'Architetto (Linee Guida, sezione 8). Qui ci sono la struttura, i campi,
le lunghezze, i numeri e le regole che le prove pretenderanno. Gli esempi di
forma usano `‹testo›` al posto delle parole. **Dall'ordine GA voce GA.07** i
testi li riscrivono gli scrittori di Code per ordine del fondatore, con le
liste di lavoro e gli strumenti della sezione 8; la regola di prima vale per
tutto ciò che quell'ordine non nomina.

**Finché il corpus non entra, la lettura resta quella di oggi** (Gemini 2.5
Flash, con la lettura di casa come riserva). Il passaggio avviene col corpus,
tutto insieme: nessuna lettura mezza dal modello e mezza dal corpus. Al 20
ottobre 2026 il corpus è entrato tutto (cinque campi, ogni gruppo pieno) e il
ramo del modello non si raggiunge più.

## 1. Com'è fatta oggi la lettura delle rune

### Le gettate

`lib/core/rituals/rune_cast.dart`. La persona sceglie la gettata (quella
proposta è la Runa di Odino).

| Gettata | Rune lette | Posizioni (titolo e glossa) | La pietra che decide |
|---|---|---|---|
| Runa di Odino | 1 | La runa di Odino, il consiglio essenziale | l'unica |
| Le tre Norne | 3 | Urdhr, ciò che fu; Verdhandi, ciò che diviene; Skuld, ciò che sarà | Skuld |
| La Croce delle Cinque | 5 | Cuore, il cuore della questione; Radice, la radice; Ostacolo, l'ostacolo; Consiglio, il consiglio; Esito, l'esito | Esito |
| Il getto sul telo | 7 | in ordine di distanza dal centro: Al centro, la voce che pesa di più; Presso il centro, la voce di mezzo; Ai margini, la voce più lieve (dalla terza in poi tutte ai margini) | Al centro |

"La pietra che decide" è una scelta di questa specifica: è la pietra su cui si
appoggiano la prima frase della risposta e il gesto (sezione 2).

### Le rune e il verso

- 24 rune del Futhark antico, tutte diverse in una gettata, a caso vero.
- **8 rune simmetriche escono sempre dritte**: Gebo, Hagalaz, Isa, Jera,
  Eihwaz, Sowilo, Ingwaz, Dagaz.
- Le altre 16 escono in **merkstave** (rovesciate, "in ombra") al 50 per cento
  nelle gettate fisse e al 35 per cento sul telo.
- Le rune si dividono in tre famiglie (aett) di otto: **Freyr** (da Fehu a
  Wunjo), **Hagal** (da Hagalaz a Sowilo), **Tyr** (da Tiwaz a Othala).

### Come entra la domanda della persona

La domanda è **facoltativa**:
- una delle **domande del Cerchio** (`lib/core/domande/domande_del_cerchio.dart`):
  otto per tutti ("Cosa devo sapere sul mio momento?", "In amore, dove sto
  andando?", "Nel lavoro, quale passo fare?", "Una scelta mi blocca: cosa la
  scioglie?", "Cosa mi sfugge di questa situazione?", "Cosa conviene lasciare
  andare adesso?", "Su cosa vale la pena insistere?", "Cosa non sto guardando
  di me?") e quattro personali, che si mostrano solo se il dato c'è ("La runa
  di ieri sera: cosa continua oggi?", "La parola di stamattina: dove la
  ritrovo?", "Il mio animale guida: cosa mi dice ora?", "Il mio archetipo:
  quale passo mi somiglia?");
- oppure una **domanda scritta a mano**;
- oppure **nessuna domanda**: allora la lettura parla della giornata.

### Che cosa vede la persona

Sulla schermata `RuneDrawScreen`, nei quattro strati delle Linee Guida:
1. **il colpo d'occhio**: il nome della gettata, le pietre posate (rovesciate
   se in ombra), il residuo del giorno, la domanda se c'è;
2. **la sintesi**: la prima frase della risposta (anche nella card da
   condividere, fino a 90 caratteri);
3. **il presagio di Calìgo**, scritto oggi dal modello, in tre parti:
   - **la risposta**: due frasi;
   - **cosa puoi fare**: il riquadro dorato, un gesto;
   - **da dove viene**: un paragrafo con una lettura per ogni pietra (la runa,
     la sua posizione, che cosa dice sulla domanda o sulla giornata) e il
     legame fra le pietre;
4. **le azioni**: Condividi, Custodisci, Parlane.

Sotto il presagio: **una scheda per ogni runa** (il nome, la posizione, il
verso, la parola chiave, il significato, la riga dritta o d'ombra, la Voce
della Runa, "Da dove nasce questa runa") e il **Sigillo del giorno**. Le schede
e il Sigillo sono **già deterministici** e restano come sono.

**Che cosa cambia col corpus**: solo il presagio di Calìgo, cioè le tre parti
del punto 3. Tutto il resto della schermata non cambia.

**La forma dell'ordine GA** (voci GA.03, GA.04 e GA.05; il codice dell'app
la mostrerà dopo la riscrittura dei testi). Ogni paragrafo ha da 40 a 50
parole, contate separate da uno spazio come `LaFormaDelResponso.parole`.
- **Il responso principale**, nella bolla del presagio:
  - **il titolo**: la riga dritta o d'ombra (`runes.dart`) della **pietra che
    decide**, la stessa su cui poggiano la risposta e il gesto;
  - **il paragrafo 1, la risposta**: RISPOSTA della pietra che decide più
    VERDETTO del tono e della famiglia, uniti in un paragrafo da 40 a 50
    parole; la prima frase risponde alla domanda (GA.06);
  - **il paragrafo 2, nel riquadro "Cosa fare adesso"**: GESTO della pietra
    che decide, scritto per il titolo, che dice che cosa fare o non fare;
  - **nella Lunga, dall'Iniziato in su**: il paragrafo 3, che approfondisce
    (LEGAME della gettata e del tono) e il paragrafo 4 nel riquadro "Il
    galdr propiziatorio", il canto del nome della pietra che decide, da
    `docs/corpus/riti/galdr_delle_rune.md` (una voce per runa e verso);
  - **"Da dove viene"**, in corsivo, una volta sola in fondo alla
    consultazione: lo compone il codice dalle fonti delle rune uscite (i poemi
    runici di `rune.md` e, nella Lunga, la pratica del galdr), non il corpus.
- **Le schede delle rune singole**, solo nelle gettate con più di una pietra
  (le tre Norne, la Croce delle Cinque, il getto sul telo; la Runa di Odino
  non ha schede, il responso principale è già la sua runa): la testata di oggi
  (nome, posizione e glossa, verso, parola chiave), poi un paragrafo (PIETRA)
  e il riquadro "Cosa fare adesso" (CONSIGLIO, campo nuovo). Le schede hanno
  sempre la forma breve.

## 2. La lettura deterministica

Il presagio si compone da **cinque campi**, ognuno diviso in **gruppi**. Per
ogni gruppo l'Architetto scrive tante voci quante ne servono (sezione 4), e
l'app ne sceglie una (sezione 5).

| Parte a video (ordine EX) | Parte a video (ordine GA) | Campo | Da che cosa dipende il gruppo | Gruppi |
|---|---|---|---|---|
| La risposta, prima frase | il paragrafo 1, prima metà | **RISPOSTA** | la pietra che decide: la runa e il verso | 40 |
| La risposta, seconda frase | il paragrafo 1, seconda metà | **VERDETTO** | il tono della gettata e la famiglia che domina | 9 |
| Da dove viene, una per pietra | il paragrafo della scheda di ogni runa | **PIETRA** | la runa e il verso | 40 |
| Da dove viene, in fondo | il paragrafo 3 della Lunga, l'approfondimento | **LEGAME** | la gettata e il tono | 11 |
| Cosa puoi fare | il paragrafo 2, il riquadro "Cosa fare adesso" | **GESTO** | la pietra che decide: la runa e il verso | 40 |
| (non c'era) | il riquadro "Cosa fare adesso" della scheda di ogni runa | **CONSIGLIO** | la runa e il verso | 40 |

Il sesto campo, **CONSIGLIO**, sta in `docs/corpus/rune/consiglio.md`, coi
gruppi di PIETRA. **Il galdr propiziatorio** (paragrafo 4 della Lunga) non è
un campo di questo corpus: sta in `docs/corpus/riti/galdr_delle_rune.md`, una
voce per runa e verso: è **escluso dalla prova dei 60 giorni**, con la
stessa ragione del rito dell'Oracolo degli Angeli: è un gesto da ripetere, il
canto della stessa runa che torna uguale ogni volta che quella pietra decide.

**Quaranta gruppi** per runa e verso: 24 dritte e 16 in ombra (le 8 simmetriche
non escono mai in ombra).

**Il tono della gettata**: *luce* se nessuna pietra è in ombra; *ombra* se più
della metà delle pietre è in ombra; *misto* negli altri casi. La Runa di Odino
non ha il misto (una pietra sola).

**La famiglia che domina**: l'aett con più pietre nella gettata; a parità vale
quella della pietra che decide.

### Gli spazi che l'app riempie

Ogni voce può portare questi spazi, scritti fra graffe; l'app li riempie e la
voce deve leggersi bene con ognuno dei valori possibili.

| Spazio | Dove | Che cosa ci mette l'app |
|---|---|---|
| `{cosa}` | RISPOSTA, VERDETTO, PIETRA, GESTO | ciò di cui la persona chiede, **con l'articolo**: per le domande del Cerchio un valore fisso per domanda ("il tuo momento", "l'amore", "il lavoro", "la scelta che ti blocca", "questa situazione", "ciò che va lasciato", "ciò su cui insistere", "ciò che non guardi di te", e per le quattro personali "ciò che continua da ieri sera", "la parola di stamattina", "il tuo animale guida", "il tuo archetipo"); per una domanda scritta a mano la cosa che l'app riconosce con le famiglie di parole che usa oggi (l'amore, il lavoro, la casa, la famiglia...), altrimenti "ciò che hai chiesto"; senza domanda "la tua giornata" |
| `{posizione}` | PIETRA | il titolo della posizione ("Skuld", "Ostacolo", "Al centro") |
| `{glossa}` | PIETRA | la glossa ("ciò che sarà", "l'ostacolo", "la voce che pesa di più") |
| `{gettata}` | LEGAME | il nome della gettata ("le tre Norne") |
| `[m\|f\|n]` | ovunque | la marca del genere della persona, come nei corpora di oggi (`LaMarcaDelGenere`) |

**Gli spazi nell'ordine GA.** Uno spazio cambia il conto delle parole:
`{cosa}` vale da 1 parola ("l’amore", "l’amicizia") a 6 ("ciò che continua
da ieri sera", "ciò che non guardi di te"), `{glossa}` da 1 a 6, `{gettata}`
da 3 a 4. Con due spazi nello stesso paragrafo la finestra da 40 a 50 parole
si rispetterebbe solo con un numero esatto di parole: per questo **ogni voce
porta al più uno spazio** e cambia dove gli spazi si possono usare:

| Spazio | Dove, dall'ordine GA |
|---|---|
| `{cosa}` | RISPOSTA (esattamente uno), PIETRA (esattamente uno), GESTO e LEGAME (al più uno); mai in VERDETTO né in CONSIGLIO |
| `{posizione}`, `{glossa}` | in nessun campo: la testata della scheda mostra già posizione e glossa |
| `{gettata}` | LEGAME (al più uno spazio in tutto); il gruppo fissa la gettata, quindi il valore è uno solo per gruppo |
| `[m\|f\|n]` | ovunque, come prima; si misura in tutte e tre le forme |

I valori si leggono dal sorgente, non a memoria:
`tool/controlla_il_corpus_delle_rune.py` prende quelli di `{cosa}` da
`lib/core/rituals/il_presagio_dal_corpus.dart` (le cose delle domande del
Cerchio, le famiglie di parole, "la tua giornata", "ciò che hai chiesto":
venti valori diversi al 20 ottobre 2026) e quelli di `{gettata}`,
`{posizione}` e `{glossa}` da `lib/core/rituals/rune_cast.dart`; poi misura
ogni voce con ognuno.

**Il nome della runa** non è uno spazio: le voci di RISPOSTA, VERDETTO e GESTO
**non nominano nessuna runa** (il simbolo non apre mai, Linee Guida sezione
2). Le voci di PIETRA la nominano, perché lì si dice da dove viene la lettura.
Dall'ordine GA: neppure LEGAME e CONSIGLIO nominano una runa; PIETRA continua
a nominare la sua e nessun'altra.

## 3. I campi di ogni voce e le lunghezze

Ogni voce è una riga numerata sotto il suo gruppo. L'identificativo lo
costruisce il generatore dal campo, dal gruppo e dal numero (per esempio
`PIETRA/Fehu/ombra/17`): **non si riusa e non si rinumera**. Una voce tolta
lascia il suo numero vuoto, così la memoria di chi l'ha già letta resta
giusta.

| Campo | Che cosa dice | Lunghezza | Regole |
|---|---|---|---|
| RISPOSTA | che cosa la gettata vede su `{cosa}`, a partire dal senso della pietra che decide; prende posizione | una frase, da 60 a 160 caratteri | nessun nome di runa, nessun astro |
| VERDETTO | come pesa l'insieme della gettata su `{cosa}` (luce, ombra, misto) nel colore della famiglia | una frase, da 60 a 160 caratteri | nessun nome di runa |
| PIETRA | la runa nella sua posizione: che cosa dice su `{cosa}` da `{posizione}` | una o due frasi, da 80 a 240 caratteri | nomina la runa, usa `{posizione}` o `{glossa}`; non ripete il significato della scheda della runa parola per parola |
| LEGAME | il filo fra le pietre di quella gettata e di quel tono | una o due frasi, da 60 a 200 caratteri | nessun nome di runa |
| GESTO | un gesto concreto che la persona può fare oggi o nei prossimi giorni, legato al senso della pietra che decide | una frase, da 40 a 140 caratteri | si può fare davvero; mai "ascolta te stesso"; nessun nome di runa |

**Le lunghezze dell'ordine GA, in parole** (contate separate da uno spazio,
con OGNI valore degli spazi e ogni forma del genere). Sostituiscono la
colonna "Lunghezza" qui sopra; le regole della colonna "Regole" restano.

| Campo | Che cosa dice, dall'ordine GA | Parole | Spazi |
|---|---|---|---|
| RISPOSTA | la prima metà del paragrafo 1: che cosa la pietra che decide dice su `{cosa}`; la prima frase risponde alla domanda | da 19 a 22 fuori dallo spazio, cioè da 20 a 28 riempita | esattamente un `{cosa}` |
| VERDETTO | la seconda metà del paragrafo 1: come pesa l'insieme della gettata, nel tono e nel colore della famiglia; segue qualunque RISPOSTA | da 20 a 22 | nessuno |
| RISPOSTA + VERDETTO | il paragrafo 1 a video | da 40 a 50 per OGNI coppia e ogni valore (ogni verdetto può seguire ogni risposta) | |
| GESTO | il riquadro "Cosa fare adesso": che cosa fare o non fare, scritto per il titolo (la riga della pietra che decide) | da 40 a 50 (da 39 a 44 fuori dallo spazio, se c'è) | al più un `{cosa}` |
| LEGAME | il paragrafo 3 della Lunga: approfondisce la risposta col filo fra le pietre di quella gettata e di quel tono | da 40 a 50 (da 39 a 44 fuori da `{cosa}`) | al più uno, `{cosa}` o `{gettata}` |
| PIETRA | il paragrafo della scheda: che cosa dice questa runa, nel suo verso, su `{cosa}` | da 39 a 44 fuori dallo spazio, da 40 a 50 riempita | esattamente un `{cosa}`; niente `{glossa}` né `{posizione}` |
| CONSIGLIO | il riquadro "Cosa fare adesso" della scheda: che cosa fare o non fare, dal senso di questa runa in questo verso; non ripete PIETRA | da 40 a 50 | nessuno |

Il galdr (`docs/corpus/riti/galdr_delle_rune.md`) sta anche lui fra 40 e 50
parole, formula compresa (voce GA.04): lo misura il suo strumento.

**Le regole che valgono per tutte le voci** (Linee Guida, sezioni 2, 8, 11, 15
e 16, e le regole di casa):
- la voce di Calìgo: profonda, solenne, autorevole, mai oscura o minacciosa;
- il confine del responso: nessuna previsione data per certa, nessun
  consiglio medico, legale o finanziario, e nessuna delle parole che
  `docs/corpus/rune.md` vieta (guarigione, salute, malattia, fertilità,
  longevità, vittoria, protezione dalle armi, ricchezza, ritrovamento di
  tesori);
- niente astrologia: le rune sono senza cielo, per decisione del fondatore;
- nessun trattino lungo, nessuna virgola prima della "e", accenti veri;
- una voce non dichiara mai da dove viene il testo (niente "il corpus", "il
  sistema").

**Le regole di lingua dell'ordine GA** (regola R7 dell'ordine e voce GA.06),
che si sommano a quelle qui sopra; lo strumento di controllo prende quelle
che una macchina sa vedere:
- la risposta diretta: la prima frase della RISPOSTA risponde alla domanda,
  niente preamboli, niente immagini al posto della risposta, niente frasi che
  valgono per tutti; ogni affermazione poggia sulla runa e sul suo verso;
- il tu; nessun aggettivo col genere riferito a chi legge, oppure la marca
  `[maschile|femminile|neutra]` come fanno i corpora;
- niente "!", niente cifre (i numeri in lettere), niente futuro in "-rai"
  ("troverai", "sarai"): nessuna previsione data per certa, niente
  "sicuramente", "di certo", "senza dubbio";
- niente salute, denaro o questioni legali, oltre alle parole vietate di
  `rune.md`;
- la voce di Calìgo resta solenne e mai minacciosa (niente maledizioni,
  sventure, morte);
- nessuna voce uguale a un'altra e **nessuna frase uguale** in tutto il
  corpus (una frase di almeno sei parole non torna in due voci).

**La forma del file.** Un file per campo in `docs/corpus/rune/`:
`risposta.md`, `verdetto.md`, `pietra.md`, `legame.md`, `gesto.md` e,
dall'ordine GA, `consiglio.md` (stessi titoli di PIETRA). Dentro,
un titolo per gruppo e le voci numerate:

```
## Fehu, in ombra
1. ‹testo›
2. ‹testo›

## misto, Hagal
1. ‹testo›
```

I titoli dei gruppi: `## <Runa>, dritta` e `## <Runa>, in ombra` per
RISPOSTA, PIETRA, GESTO e CONSIGLIO; `## <tono>, <famiglia>` per VERDETTO;
`## <gettata>, <tono>` per LEGAME (gettata: odino, norne, croce, telo).

## 4. Quante voci servono per 60 giorni senza ripetere

**Il conto.** `tool/le_voci_che_servono_alle_rune.py` simula le gettate come le
fa l'app, per 60 giorni al massimo dell'Illuminato (3 gettate al giorno, 180
gettate), su 4.000 persone in due scenari: **misto** (gettata e domanda a
caso) e **peggiore** (sempre il telo, cioè sette pietre per gettata, e sempre
la stessa domanda). Per ogni gruppo prende quante volte, al massimo, lo stesso
gruppo serve alla stessa persona in 60 giorni, il massimo fra i due scenari, e
aggiunge il 20 per cento. Con la regola di scelta della sezione 5 **una voce
non torna finché il suo gruppo non è finito**: un gruppo con almeno queste
voci non ripete in 60 giorni. L'elenco completo:
`docs/corpus/rune/le_voci_che_servono.txt`.

| Campo | Gruppi | Voci per gruppo | Voci in tutto |
|---|---|---|---|
| RISPOSTA | 40 | da 12 a 26 | **712** |
| VERDETTO | 9 | da 23 a 86 | **467** |
| PIETRA | 40 | da 40 a 93 | **2.451** |
| LEGAME | 11 | da 20 a 196 | **587** |
| GESTO | 40 | da 12 a 26 | **712** |
| **Totale** | **140** | | **4.929** |
| CONSIGLIO, dall'ordine GA | 40 | da 40 a 93 | **2.451** |
| **Totale dall'ordine GA** | **180** | | **7.380** |

**Il CONSIGLIO ha lo stesso fabbisogno di PIETRA**, gruppo per gruppo: è il
riquadro della scheda di ogni pietra, una voce per pietra come PIETRA; la
regola del fondatore resta (*"non voglio ripetizioni per almeno 60gg"*).
`tool/le_voci_che_servono_alle_rune.py` lo copia da PIETRA invece di
contarlo a parte: la simulazione resta quella di prima carattere per
carattere (rigirata il 20 ottobre 2026, i numeri degli altri cinque campi
sono usciti identici) e i due campi non possono separarsi. Il conto di PIETRA
resta quello di prima anche se dall'ordine GA la Runa di Odino non ha schede:
il caso peggiore è sempre il telo: togliere Odino abbassa solo lo scenario
misto. **Il galdr è escluso dal conto** (sezione 2).

**Perché PIETRA pesa tanto.** Sul telo si leggono sette pietre per gettata: al
massimo, in 60 giorni, sono 1.260 pietre, e una runa dritta simmetrica (Dagaz,
Hagalaz, Gebo...) può uscire fino a 77 volte, perché non si divide fra dritta e
ombra. Le simmetriche hanno bisogno di circa 90 voci, le altre di 40-70.

**Perché il telo misto pesa 196.** Chi getta sempre il telo ha il tono misto
quasi sempre: lo stesso gruppo serve fino a 163 volte in 60 giorni.

**Gruppo per gruppo.**

Nella tabella qui sotto le colonne di PIETRA valgono anche per CONSIGLIO.

| Runa | RISPOSTA dritta | RISPOSTA in ombra | PIETRA dritta | PIETRA in ombra | GESTO dritta | GESTO in ombra |
|---|---|---|---|---|---|---|
| Fehu | 18 | 15 | 63 | 40 | 18 | 15 |
| Uruz | 17 | 12 | 66 | 45 | 17 | 12 |
| Thurisaz | 18 | 16 | 65 | 44 | 18 | 16 |
| Ansuz | 20 | 14 | 66 | 41 | 20 | 14 |
| Raidho | 22 | 15 | 65 | 42 | 22 | 15 |
| Kenaz | 17 | 14 | 63 | 44 | 17 | 14 |
| Gebo | 23 | mai in ombra | 92 | mai in ombra | 23 | mai in ombra |
| Wunjo | 16 | 15 | 63 | 42 | 16 | 15 |
| Hagalaz | 26 | mai in ombra | 93 | mai in ombra | 26 | mai in ombra |
| Nauthiz | 17 | 16 | 66 | 41 | 17 | 16 |
| Isa | 24 | mai in ombra | 89 | mai in ombra | 24 | mai in ombra |
| Jera | 23 | mai in ombra | 89 | mai in ombra | 23 | mai in ombra |
| Eihwaz | 23 | mai in ombra | 92 | mai in ombra | 23 | mai in ombra |
| Perthro | 17 | 15 | 68 | 42 | 17 | 15 |
| Algiz | 18 | 17 | 66 | 41 | 18 | 17 |
| Sowilo | 22 | mai in ombra | 90 | mai in ombra | 22 | mai in ombra |
| Tiwaz | 17 | 15 | 65 | 42 | 17 | 15 |
| Berkano | 17 | 15 | 70 | 41 | 17 | 15 |
| Ehwaz | 17 | 15 | 64 | 40 | 17 | 15 |
| Mannaz | 18 | 15 | 68 | 41 | 18 | 15 |
| Laguz | 18 | 15 | 65 | 46 | 18 | 15 |
| Ingwaz | 23 | mai in ombra | 92 | mai in ombra | 23 | mai in ombra |
| Dagaz | 26 | mai in ombra | 93 | mai in ombra | 26 | mai in ombra |
| Othala | 17 | 14 | 64 | 42 | 17 | 14 |
| **Totale** | **712** | | **2451** | | **712** | |

| VERDETTO, tono | Freyr | Hagal | Tyr |
|---|---|---|---|
| luce | 35 | 48 | 40 |
| misto | 86 | 82 | 83 |
| ombra | 36 | 23 | 34 |
| **Totale** | **467** | | |

| LEGAME, gettata | luce | misto | ombra |
|---|---|---|---|
| odino | 58 | non esiste | 34 |
| norne | 35 | 47 | 33 |
| croce | 20 | 58 | 27 |
| telo | 53 | 196 | 26 |
| **Totale** | **587** | | |

## 5. La regola di scelta

- **La memoria della persona.** L'app tiene, per ogni persona, l'identificativo
  di ogni voce letta e il giorno in cui l'ha letta, per 60 giorni.
- **Dentro un gruppo, la voce che la persona non ha mai letto o ha letto da
  più tempo.** Fra le voci mai lette l'ordine è una permutazione del gruppo
  propria della persona (seminata dal suo identificativo), così due persone
  con la stessa gettata non leggono la stessa voce.
- **Mai la stessa voce due volte nello stesso presagio.** Due pietre dello
  stesso gruppo in un telo (non succede: le rune di una gettata sono tutte
  diverse) o due campi che pescano lo stesso testo non sono possibili per
  costruzione; la prova lo controlla lo stesso.
- **Lo stesso giorno, la stessa gettata con la stessa domanda dà lo stesso
  presagio** (Linee Guida, sezione 5: il responso resta valido per la
  giornata).
- **Il gruppo finito.** Se un gruppo non ha più voci non lette nei 60 giorni,
  torna la voce letta da più tempo: con i numeri della sezione 4 non succede
  nella simulazione, ed è la ragione del margine.

## 6. Che cosa c'è oggi e che cosa si può tenere

| Che cosa | Dove | Oggi a video? | Che cosa se ne fa |
|---|---|---|---|
| Strofe dei poemi runici (anglosassone per tutte e 24, islandese e norvegese per 15), materia attestata | `docs/corpus/rune.md`, generate in `rune_lore.g.dart` | sì, nella porta "Da dove nasce questa runa" | **restano** dove sono; non entrano nel presagio |
| "Merkstave" o "Riga d'ombra", una riga per runa | `docs/corpus/rune.md` | no | materiale per i gruppi in ombra di PIETRA e RISPOSTA |
| "Chiave di Calìgo", dritto e in ombra, due o tre frasi per verso | `docs/corpus/rune.md` | **no**: il generatore non la porta nel codice | **la base più vicina a PIETRA**: è già la voce di Calìgo per runa e verso; le 24 dritte e le 24 in ombra possono diventare le prime voci dei gruppi di PIETRA (in ombra solo per le 16 non simmetriche), riscritte con `{posizione}` e `{cosa}` |
| Significato, parola chiave, riga dritta e d'ombra (al massimo 55 caratteri) | `lib/core/rituals/runes.dart`, scritti a mano | sì, nelle schede delle rune | **restano** nelle schede; una voce del presagio non le ripete |
| Le 12 cornici delle domande e quella della giornata (apertura e chiusura) | `lib/core/domande/cornici_del_presagio.dart` | sì, nella lettura di casa | restano finché il corpus non entra; poi la lettura di casa non serve più |
| Le forme della lettura di casa (16 per la posizione, 8 per il coro del telo, 12 e 8 per l'equilibrio, 16 per "da dove viene") | `lib/core/rituals/rune_presage.dart` | sì, quando il modello non risponde | come sopra |
| Il preambolo di `rune.md` | riga 3 | | **superato**: dice ancora "Gemini personalizza sul cielo" |

## 7. Le prove che leggeranno il corpus

Quando i file dell'Architetto entrano in `docs/corpus/rune/`, il generatore li
porta nel codice e la suite pretende:
1. **la forma**: ogni gruppo della sezione 2 esiste; ogni voce ha un
   identificativo unico; gli spazi sono solo quelli permessi nel suo campo; le
   lunghezze stanno nella tabella della sezione 3; il confine del responso, le
   parole vietate, il trattino lungo e la virgola prima della "e"; nessun nome
   di runa dove non va; la marca del genere scritta bene;
2. **la quantità**: ogni gruppo ha almeno le voci di
   `docs/corpus/rune/le_voci_che_servono.txt`;
3. **le ripetizioni a 60 giorni**: 60 giorni di gettate simulate al massimo
   dell'Illuminato, nei due scenari, su almeno mille persone: **zero voci
   ripetute** alla stessa persona;
4. **la parola per parola**: il testo nel codice è quello dei file
   dell'Architetto, carattere per carattere;
5. **le chiamate al modello per gettata**: oggi 1,85 in media (ordine EW), col
   corpus **zero**.

**Dall'ordine GA voce GA.07** la misura della forma si conta in parole, con
ogni valore degli spazi (sezione 3) e comprende il paragrafo composto
RISPOSTA più VERDETTO e il sesto campo CONSIGLIO. La controlla
`tool/controlla_il_corpus_delle_rune.py` prima che i testi entrino nel
codice; la prova `test/il_corpus_delle_rune_test.dart` misura ancora in
caratteri i cinque campi dell'ordine EX: si aggiorna insieme al codice
dell'app che mostra la forma nuova (con la regola A delle guardie: vista
rossa prima).

## 8. Come si consegna

L'Architetto può consegnare i cinque file anche in tempi diversi, ma **il
passaggio dal modello al corpus avviene quando ci sono tutti e cinque e
passano le prove**. Fino ad allora l'app legge col modello come oggi.

### La riscrittura dell'ordine GA voce GA.07

I testi si riscrivono da più scrittori in parallelo, su gruppi disgiunti,
ognuno con la sua lista di lavoro (il campo, i gruppi, i numeri da riscrivere
col testo di oggi accanto, quelli da togliere, quante voci nuove e da quale
numero, la finestra, gli spazi). Ogni scrittore consegna un **file di parte**
nella forma del corpus:

```
## Fehu, dritta
3. ‹testo nuovo della voce 3›
17.
30. ‹voce nuova›
```

- `N. testo` con N già nel gruppo **sostituisce** la voce N: l'identificativo
  resta;
- `N.` senza testo **toglie** la voce N: il numero resta vuoto e non si riusa;
- `N. testo` con N oltre l'ultima voce **aggiunge** una voce: i numeri nuovi
  partono dal primo libero e si seguono senza buchi.

Gli strumenti:
1. `python tool/controlla_il_corpus_delle_rune.py --parte <campo> <parte.md>`
   controlla una parte prima della consegna: i numeri contro il corpus, la
   misura e gli spazi di ogni voce, il paragrafo composto contro le voci del
   corpus già a misura, le regole di lingua, voci e frasi uguali;
2. `python tool/applica_le_riscritture_delle_rune.py <campo> <parte.md>...`
   rimette le voci al loro posto; si ferma senza scrivere niente se un numero
   da sostituire non c'è o se il controllo trova un difetto nelle voci
   toccate;
3. `python tool/controlla_il_corpus_delle_rune.py` sul corpus intero, coi
   conti per campo (`--conti` per i soli conti);
4. `python tool/genera_corpus_del_presagio.py` porta i sei campi nel codice.

**La fase 1** è il responso principale (RISPOSTA, VERDETTO, GESTO, LEGAME):
con lei la Runa di Odino è completa. **La fase 2** sono le schede (PIETRA e
CONSIGLIO), che pesano il doppio di tutto il resto.

**La memoria dei 60 giorni.** Una voce riscritta tiene il suo numero, quindi
chi l'ha già letta non la rivede per 60 giorni anche se il testo è nuovo: è
voluto. Con i campi nuovi l'elenco `diOggi` della memoria
(`il_presagio_dal_corpus.dart`) cambia forma: il codice che mostra la forma
nuova versiona la chiave della memoria.
