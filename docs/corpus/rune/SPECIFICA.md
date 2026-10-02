# Le rune senza modello: la specifica del corpus per l'Architetto

Ordine EX, voce EX.03, e la sua Aggiunta "La specifica delle rune per
prima". Scritta da Code il 2 ottobre 2026 sul codice del commit `666d0745`.

> *"Voglio corpus grandi, non voglio ripetizioni per almeno 60gg"*;
> *"pensavo che l'estrazione rune fosse a zero AI"*; *"Si certo."* (le rune
> deterministiche col corpus dell'Architetto).

**Code non scrive nessun testo del corpus.** I testi sono materiale
dell'Architetto (Linee Guida, sezione 8). Qui ci sono la struttura, i campi,
le lunghezze, i numeri e le regole che le prove pretenderanno. Gli esempi di
forma usano `‹testo›` al posto delle parole.

**Finché il corpus non entra, la lettura resta quella di oggi** (Gemini 2.5
Flash, con la lettura di casa come riserva). Il passaggio avviene col corpus,
tutto insieme: nessuna lettura mezza dal modello e mezza dal corpus.

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

## 2. La lettura deterministica

Il presagio si compone da **cinque campi**, ognuno diviso in **gruppi**. Per
ogni gruppo l'Architetto scrive tante voci quante ne servono (sezione 4), e
l'app ne sceglie una (sezione 5).

| Parte a video | Campo | Da che cosa dipende il gruppo | Gruppi |
|---|---|---|---|
| La risposta, prima frase | **RISPOSTA** | la pietra che decide: la runa e il verso | 40 |
| La risposta, seconda frase | **VERDETTO** | il tono della gettata e la famiglia che domina | 9 |
| Da dove viene, una per pietra | **PIETRA** | la runa e il verso | 40 |
| Da dove viene, in fondo | **LEGAME** | la gettata e il tono | 11 |
| Cosa puoi fare | **GESTO** | la pietra che decide: la runa e il verso | 40 |

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

**Il nome della runa** non è uno spazio: le voci di RISPOSTA, VERDETTO e GESTO
**non nominano nessuna runa** (il simbolo non apre mai, Linee Guida sezione
2). Le voci di PIETRA la nominano, perché lì si dice da dove viene la lettura.

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

**La forma del file.** Un file per campo in `docs/corpus/rune/`:
`risposta.md`, `verdetto.md`, `pietra.md`, `legame.md`, `gesto.md`. Dentro,
un titolo per gruppo e le voci numerate:

```
## Fehu, in ombra
1. ‹testo›
2. ‹testo›

## misto, Hagal
1. ‹testo›
```

I titoli dei gruppi: `## <Runa>, dritta` e `## <Runa>, in ombra` per
RISPOSTA, PIETRA e GESTO; `## <tono>, <famiglia>` per VERDETTO;
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

**Perché PIETRA pesa tanto.** Sul telo si leggono sette pietre per gettata: al
massimo, in 60 giorni, sono 1.260 pietre, e una runa dritta simmetrica (Dagaz,
Hagalaz, Gebo...) può uscire fino a 77 volte, perché non si divide fra dritta e
ombra. Le simmetriche hanno bisogno di circa 90 voci, le altre di 40-70.

**Perché il telo misto pesa 196.** Chi getta sempre il telo ha il tono misto
quasi sempre: lo stesso gruppo serve fino a 163 volte in 60 giorni.

**Gruppo per gruppo.**

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

## 8. Come si consegna

L'Architetto può consegnare i cinque file anche in tempi diversi, ma **il
passaggio dal modello al corpus avviene quando ci sono tutti e cinque e
passano le prove**. Fino ad allora l'app legge col modello come oggi.
