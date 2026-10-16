# DB.06, I TRAGUARDI DEL RESPIRO: proposta al fondatore

Ordine DB voce 06, 9 settembre 2026. **Non montati.** L'ordine dice: *"Proponi
al fondatore, senza montarli, i traguardi che nascono da qui... Li scrive lui.
Tu li proponi con la condizione gia' misurata contro il catalogo dei 165,
dichiarando per ciascuno se collide con un traguardo esistente."*

## Il catalogo, contato non stimato

| sentiero | traguardi |
| --- | ---: |
| Loto (Aura) | 55 |
| Albero (Medora) | 55 |
| Costellazione (Caligo) | 55 |
| **totale** | **165** |

I traguardi che nominano il gesto `meditazione`, **tutti nel sentiero del
Loto**, letti riga per riga:

| riga | condizione |
| ---: | --- |
| 86 | `GestiCompiuti('meditazione', 3, inGiorniDiversi: true)` |
| 152 | `GestiCompiuti('meditazione', 5, inGiorniDiversi: true)` |
| 285 | `GiornateInsieme(['alba', 'meditazione', 'soffio'], 16)` |
| 419 | `GiornateInsieme(['alba', 'meditazione'], 40)` |
| 656 | `GestiCompiuti('meditazione', 140, inGiorniDiversi: true)` |
| 895 | `GiornateInsieme([...sei gesti...])` |

**Nessuno dei 165 guarda quale centro e' stato respirato.** Le condizioni
esistenti contano gesti, giornate e coincidenze: il centro non compare mai.

---

## PRIMO, I sette centri respirati almeno una volta

**Condizione proposta**: `VarietaDelDettaglio('meditazione', 'centro', 7)`

**Collide?** No. Nessuno dei 55 del Loto misura la varieta' dei centri.

**E la condizione non va inventata.** `VarietaDelDettaglio` esiste gia' in
`lib/core/sigilli/traguardo.dart:279` e fa esattamente questo: conta i valori
distinti di un dettaglio del gesto. Il tipo e' pronto e provato.

**Manca una cosa sola, e sta fuori dal catalogo.** Oggi la schermata manda il
gesto **senza dettagli**:

```dart
// lib/features/maestri/aura/meditation/meditation_screen.dart:244
unawaited(RegiaDelCammino.dopoUnGesto(context, 'meditazione'));
```

`dopoUnGesto` accetta gia' un `Map<String, Object?> dettagli`, e il centro e'
gia' calcolato due righe sotto (`centro: _indiceDelCentro`, riga 269). Servono
**due parole**, non una funzione nuova.

**Quanto costa a chi lo insegue.** Il centro segue il giorno della settimana,
quindi sette centri distinti vogliono **almeno sette giorni diversi**, uno per
giorno della settimana. In pratica una settimana intera senza saltarne uno,
oppure piu' settimane a buchi. E' il costo giusto per un traguardo che apre il
fiore intero.

---

## SECONDO, Il decimo giorno in cui si respira

**Condizione proposta**: `GestiCompiuti('meditazione', 10, inGiorniDiversi: true)`

**Collide?** No, **ma sta dentro una scala che esiste gia'**, e va messo dove
la scala lo vuole.

La scala oggi e': **3**, **5**, poi **140**. Fra il cinque e il centoquaranta
**non c'e' niente**: chi ha respirato cinque giorni non ha piu' nessun gradino
davanti per quattro mesi e mezzo. Il dieci riempie il primo buco, ed e' proprio
il punto in cui una pratica smette di essere una prova e diventa un'abitudine.

**Nota mia, che il fondatore puo' scartare**: il buco vero e' piu' largo di un
gradino solo. Fra 5 e 140 ci starebbero **10, 30 e 70** senza che nessuno dei
tre sembri arbitrario. Ne propongo uno perche' l'ordine ne chiede uno.

---

## TERZO, Tre giorni di seguito sullo stesso centro: NON SI PUO'

**Condizione proposta dall'ordine**: tre giorni consecutivi sullo stesso centro.

**Collide?** Non collide con niente. **E' impossibile, e la verifica sta nel
codice.**

```dart
// lib/features/maestri/aura/meditation/meditation_screen.dart:247
// Il centro non si sceglie: e' quello acceso nel giorno in cui si respira,
```

e il centro del giorno e' `(giorno.weekday - 1) % 7`, che e' una mappa
**biiettiva** fra i sette giorni della settimana e i sette centri. **Tre giorni
consecutivi portano sempre tre centri diversi**, senza eccezioni. Un traguardo
scritto cosi' non si accenderebbe mai per nessuno, e sarebbe il peggior tipo di
traguardo: uno che sta nel catalogo e non si vede mai acceso.

### Come si salva, e sono due strade

**Strada A, si cambia il traguardo.** *"Tre volte sullo stesso centro"*, senza
il vincolo dei giorni consecutivi:

```dart
CoincidenzaDelDettaglio('meditazione', 'centro', 3)
```

Anche questo tipo esiste gia' (`traguardo.dart:308`) e conta le ripetizioni
massime di uno stesso valore. **Costo reale**: tre volte lo stesso giorno della
settimana, cioe' **almeno tre settimane**. E' un traguardo di costanza vera,
e non collide con nessuno dei 165.

**Strada B, si cambia l'app.** Si lascia scegliere il centro, e allora il
traguardo originale diventa possibile. **Sconsigliata**: la voce CZ.06 ha
deciso che il centro non si sceglie proprio per avere una verita' sola sul
centro del giorno, e riaprirla per un traguardo vorrebbe dire far decidere al
premio come funziona il rito.

**Consiglio la strada A.**

---

## LA CORREZIONE E' STATA ACCOLTA, E DUE FATTI NUOVI

**10 settembre 2026, ordine DC voce 17.** Il fondatore ha accolto la
correzione: il terzo traguardo diventa **tre volte sullo stesso centro**,
senza vincolo di consecutivita', cioe' la strada A.

**E ADESSO C'E' UNA GUARDIA PERMANENTE.** L'ordine chiede che *"nessun
traguardo possa avere una condizione che una simulazione di un anno non
accende mai"*, e questa e'
`test/nessun_traguardo_e_irraggiungibile_test.dart`. Costruisce la fotografia
piu' generosa che un anno possa produrre, chi ha fatto tutto ogni giorno in
ogni ora con ogni varieta', e pretende che ogni condizione si accenda li'
dentro. **Se una resta spenta anche cosi', non e' difficile: e' impossibile.**

**Il risultato, misurato**: sui **165** traguardi del catalogo, **zero** sono
irraggiungibili. Il difetto che l'ordine DB aveva trovato era nella proposta,
non nel catalogo.

**MA I TRE TRAGUARDI RESTANO NON MONTATI, e non per pigrizia.** Misurando
dove metterli e' emerso un vincolo che questa proposta non conosceva:

**I traguardi sono 55 per sentiero per legge**, e una guardia lo pretende
(`i_traguardi_del_cammino_test.dart`, riga 77). I grandi stanno nelle
posizioni 11, 22, 33, 44 e 55, e **la posizione segue il costo**. Quindi:

- **non se ne possono aggiungere tre al solo Loto** senza rompere la
  struttura di tutti e tre i sentieri;
- il traguardo dei sette centri costa **circa una settimana**, quindi
  vorrebbe una posizione bassa, dove i posti sono occupati da traguardi
  validi;
- l'unico modo sarebbe **togliere tre traguardi esistenti**, che peggiora il
  catalogo invece di migliorarlo.

**Un fatto emerso dal censimento, e vale la pena dirlo.** La coda alta del
sentiero del Loto e' fatta di **conteggi puri e crescenti**:

| posizione | traguardo | condizione |
| ---: | --- | --- |
| 54 | Trecentoquaranta Soffi | `soffio, 340` |
| 50 | Duecentottanta volti | `viso, 280` |
| 45 | Centonovantuna albe | `alba, 191` |
| 42 | Centosessantacinque Archetipi | `archetipo, 165` |
| 39 | Centoquaranta meditazioni | `meditazione, 140` |

Sono tutti *"fai la stessa cosa N volte"*, con N che cresce. Sono
raggiungibili, quindi la guardia non li accusa, ma **quasi nessuno li vedra'
mai** e nessuno di loro insegna niente. **Se il fondatore vuole i tre
traguardi del respiro nel catalogo, quello e' il posto da cui prenderli**: si
sostituisce la condizione di alcuni di questi, mantenendo id, posizione e Eos,
e il catalogo migliora invece di allargarsi.

**Non lo faccio di mia iniziativa**: cambiare la condizione di un traguardo e'
un cambio di verita' per chi lo avesse gia' acceso, e questa e' una decisione
del fondatore.

---

## Riassunto per il fondatore

| | condizione | tipo gia' esistente? | collide? | cosa serve prima |
| --- | --- | --- | --- | --- |
| Sette centri | `VarietaDelDettaglio('meditazione', 'centro', 7)` | Sì | No | due parole in `meditation_screen.dart:244` |
| Decimo giorno | `GestiCompiuti('meditazione', 10, inGiorniDiversi: true)` | Sì | No | niente |
| Stesso centro | `CoincidenzaDelDettaglio('meditazione', 'centro', 3)` | Sì | No | le stesse due parole del primo |

**I nomi e i testi li scrive il fondatore.** Qui ci sono le condizioni, gia'
misurate contro il catalogo.
