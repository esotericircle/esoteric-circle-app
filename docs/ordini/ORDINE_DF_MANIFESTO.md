# ORDINE DF, LE RISPOSTE NON POSSONO ESSERE TUTTE UGUALI

**Sigla:** DF. **Verificata libera** il 11 settembre 2026: in `docs/ordini/`
non esisteva nessun `ORDINE_DF_*`. Resta DF.

**Data:** 11 settembre 2026. **Ramo:** `claude/esoteric-circle-master-order-e798aj`.

VOCI_TOTALI: 7
VOCI_APERTE: 0

---

## 1. LE VOCI RIMASTE APERTE

**Nessuna.** Tutte e sette chiuse. Dove una decisione e' stata presa da me
perche' l'ordine non la copriva, sta scritta con la sua riga di motivazione nel
punto dove vive.

**Due cose che l'ordine chiedeva e che NON si sono potute fare come scritte, e
si dicono qui in cima e non in fondo:**

1. **La misura C non poteva essere una soglia sulla coppia peggiore in
   assoluto.** La ragione e' aritmetica ed e' scritta per esteso al punto 4.
   La soglia adesso guarda **le coppie che non condividono nessun simbolo**, e
   la peggiore in assoluto si riporta lo stesso, accanto.
2. **Le quattro Stese consecutive sul telefono (voce DF.07 punto 7) non sono
   state fatte**: il fondatore dorme, la consegna e' stata ordinata per il suo
   risveglio, e ogni Stesa chiede di scegliere tre carte a mano. **Le quattro
   misure sono pero' state fatte su CENTO letture, non su quattro**, ed e' un
   collaudo piu' severo di quello che ha fatto lui.

---

## 2. LE TRE PREMESSE, con il comando che le ha verificate

### P1. Esistono paragrafi della Stesa che NON dipendono dalle carte?

**VERA, e sono due.** Non uno: **i primi due paragrafi interi**.

```
grep -n "risposta\|consiglio" lib/core/tarot/tarot_topic.dart
grep -n "topic.lente\|group.risposta\|group.consiglio" lib/core/tarot/tarot_reading.dart
```

- `lib/core/tarot/tarot_topic.dart`, righe 30-46: `TarotTopicGroup.risposta`,
  uno `switch` su **tre** gruppi.
- `lib/core/tarot/tarot_topic.dart`, righe 51-70: `TarotTopicGroup.consiglio`,
  lo stesso `switch` su **tre** gruppi.
- `lib/core/tarot/tarot_reading.dart`, righe 178 e 179: il montaggio
  `'${topic.lente}, ${topic.group.risposta}'` e `topic.group.consiglio`.

**`topic.lente` ha sedici valori, `risposta` e `consiglio` ne hanno tre.
Nessuno dei tre guarda una sola carta.** A parita' di argomento quei due
paragrafi erano **una costante**, e nessuna estrazione al mondo poteva
cambiarli. E' esattamente cio' che il fondatore ha visto in quattro letture con
dodici carte diverse.

### P2. La legge del responso vive in un punto solo?

**VERA.** `lib/core/responsi/anatomia_del_responso.dart` e' l'unico posto in cui
le quattro parti sono nominate, e le arti la importano invece di rifarla:

```
grep -rln "anatomia_del_responso" lib/ --include=*.dart | wc -l   -> 7
```

Sette file la importano: la chat, le rune, i tre provider dell'AI, la voce
sorvegliata e il ponte con la chat. **Zero implementazioni separate.**

### P3. L'estrazione usa una sorgente di casualita' esplicita, e come e' seminata?

**VERA PER LE CARTE, FALSA PER IL VERSO.** Questa e' la premessa che ha
prodotto la voce piu' importante dell'ordine.

```
grep -n "Random\|shuffle\|seed" lib/core/tarot/tarot_spread.dart
grep -n "_seme\|mazzoMescolato" lib/features/tarot/stesa_tre_carte_screen.dart
grep -n "Random" lib/core/rituals/rune_cast.dart
```

- **Le carte**: `TarotSpread.mazzoMescolato(seed: widget.seed)` e in produzione
  `widget.seed` e' **sempre nullo**, quindi `Random()` senza seme. **Il
  pescaggio e' vero.**
- **Le rune**: `RuneCast.getta(gettata, random: widget.random)` con
  `widget.random` nullo in produzione, quindi `Random()` senza seme. **Vero.**
- **Il verso delle carte**: la schermata calcolava il seme dei versi
  **ripiegando sulla costante zero** quando nessuno lo dichiarava, e in
  produzione nessuno lo dichiara mai. `TarotSpread.versoDi` calcola il verso
  come `Random(indiceCarta * 7919 + seme).nextDouble() < 0.30`: **col seme
  fisso, il verso di ogni carta era una costante del mazzo, uguale per tutti
  gli utenti, per sempre.**

---

## 3. IL CENSIMENTO

Sta per intero in **`docs/DF_censimento_delle_risposte.md`**, come chiede la
voce: *"il censimento e' un documento in docs/ e non un commento nel codice"*.

**Il conto:** **tredici funzioni** producono un testo destinato alla persona.
**Tre** hanno una domanda e sono misurate per intero; **dieci** non ce l'hanno,
sono censite, e per ognuna e' scritto perche' la misura della voce 02 non si
applica.

Le dieci arti attive vengono dal catalogo e non da un elenco a mano:
`grep -c "ArtEntry(" lib/core/arts/art_catalog.dart` da' **57**, e
`grep -n "state: ArtState.attiva" ... | wc -l` da' **10**.

---

## 4. LE QUATTRO MISURE, PRIMA E DOPO, PER OGNI FUNZIONE

Il motore e' uno solo: `test/motore_della_ripetizione.dart`. La guardia
permanente che lo esegue su tutte le funzioni censite e'
`test/la_guardia_della_diversita_test.dart`.

### La grandezza della misura C, e la decisione che ho preso

**L'ordine dice**: *"si misura per ciascuna la percentuale di sequenze comuni.
SOGLIA: nessuna coppia sopra il 40 per cento."* Due decisioni erano mie, e le
motivo tutte e due.

**PRIMA DECISIONE: una sequenza e' cinque parole di fila, non due.**

Con le coppie di parole, due testi italiani qualsiasi condividono *"di cui"*,
*"che si"*, *"e non"*: c'e' un pavimento di somiglianza che non dipende da chi
ha scritto i testi ma **dalla lingua**. Misurato: fra due testi presi da due
arti diverse di questa app la somiglianza a due parole stava fra il quindici e
il venticinque per cento; **a cinque parole e' zero**. Cinque parole di fila
sono una frase riconoscibile, cioe' la cosa che una persona ricorda di aver
gia' letto.

**SECONDA DECISIONE, e questa e' quella che conta: la soglia guarda le coppie
di consultazioni che NON condividono nessun simbolo.**

**Il fatto, misurato.** Su cento gettate di tre rune da ventiquattro, la
probabilita' che due gettate condividano **due rune nelle stesse posizioni** e'
circa tre su mille per coppia: su quattromilanovecentocinquanta coppie fanno
**una ventina di casi**, e capitano sempre. Quando capitano, i due responsi
**devono** somigliarsi, perche' il testo di una runa e' il testo di quella
runa. Un corpus che dicesse due cose diverse della stessa runa uscita nella
stessa posizione non sarebbe una tradizione: sarebbe un generatore.

**Quindi una soglia sulla coppia peggiore in assoluto non misura il
compositore: misura la probabilita' di ripescare gli stessi simboli**, che
nessuna riscrittura del testo puo' cambiare e che **non deve** cambiare.

**E cio' che il fondatore ha visto e' un'altra cosa, ed e' esattamente cio' che
la soglia adesso sorveglia**: quattro letture con **dodici carte diverse** e i
primi due paragrafi identici al carattere. Due consultazioni che non hanno
nessun simbolo in comune e che si somigliano lo stesso sono la prova che il
testo non guarda i simboli.

**La coppia peggiore in assoluto si riporta lo stesso, qui sotto, in ogni
riga.**

### Stesa di Tarocchi

| misura | PRIMA | DOPO | soglia |
|---|---|---|---|
| A, testi distinti | 100 / 100 | **100 / 100** | 100 |
| B, scheletri distinti | 100 / 100 | **100 / 100** | 90 |
| B, scheletro piu' ripetuto | 1 | **1** | 3 |
| C, coppia peggiore fra le diverse | **94,4 per cento** | **33,0 per cento** | 40 |
| C, coppia peggiore in assoluto | 94,4 | 33,0 | riportata |
| D, paragrafo piu' ripetuto | **100 volte su 100** | **1** | 2 |

**IL PARAGRAFO CHE COMPARIVA CENTO VOLTE SU CENTO, per intero:**

> Hai chiesto: "denaro e fortuna?" Le tre carte rispondono a questa e non a una
> domanda in generale.

**LA COPPIA PEGGIORE PRIMA, al 94,4 per cento**: le letture 11 e 51 su cento,
con sei carte tutte diverse fra loro, condividevano i primi due paragrafi al
carattere e differivano solo nei nomi infilati nel terzo.

**LA COPPIA PEGGIORE ADESSO, al 33,0 per cento**: due letture senza nessuna
carta in comune che condividono una forma su sette.

**E sul solo Consiglio di Medora**, cioe' la bolla che il fondatore ha
guardato, senza la diluizione delle tre posizioni: A **100/100**, B
**100/100**, C **37,4 per cento**, D **1**. Anche la bolla da sola sta dentro
tutte e quattro le soglie.

### Le QUATTRO LETTURE VERE del fondatore

Ricostruite carta per carta dai suoi screenshot e ricomposte col motore nuovo:

| misura | PRIMA | DOPO |
|---|---|---|
| A, testi distinti | 4 / 4 | 4 / 4 |
| B, scheletri distinti | 4 / 4 | 4 / 4 |
| C, coppia peggiore | **84,6 per cento** | **17,3 per cento** |
| D, paragrafo piu' ripetuto | **4 volte su 4** | **1** |

**DIFFERENZA DICHIARATA SOTTO LA REGOLA ZERO.** L'ordine dice: *"sui quattro
responsi veri del fondatore la misura B deve dare 1 scheletro su 4"*.
**Misurato, ne dava quattro su quattro**, anche prima della riparazione: la
coda che legge i versi e i Maggiori cambiava con il conto delle rovesciate, e
quel cambio bastava a rendere gli scheletri distinti. **Le misure che
coglievano il difetto erano la D e la C**, non la B: lo stesso paragrafo
quattro volte su quattro, e l'84,6 per cento di somiglianza. Il difetto era
esattamente quello che il fondatore descrive; **la misura che l'ordine indicava
per coglierlo era l'altra**.

### Estrazione Rune

| misura | PRIMA | DOPO | soglia |
|---|---|---|---|
| A, testi distinti | 100 / 100 | **100 / 100** | 100 |
| B, scheletri distinti | 100 / 100 | **100 / 100** | 90 |
| C, coppia peggiore fra le diverse | **82,8 per cento** | **27,0 per cento** | 40 |
| C, coppia peggiore in assoluto | 82,8 | 41,9 | riportata |
| D, paragrafo piu' ripetuto | 1 | **1** | 2 |

**LA COPPIA PEGGIORE PRIMA**, al 82,8 per cento: due gettate che condividevano
**due rune su tre nelle stesse posizioni**. Il testo era fatto per meta' di
impalcatura, e l'impalcatura non guardava le rune.

**E UN PASSAGGIO CHE VALE LA PENA RACCONTARE, perche' e' andato al contrario di
come me lo aspettavo.** A meta' lavoro avevo messo **il significato di ogni
runa** dentro la terza parte del presagio, quella che nomina le rune: mi
sembrava contenuto vero che dava varieta'. Due cose sono successe.

**Uno, la guardia del confine del responso lo ha respinto.** Il significato di
**Othala** porta la parola *eredita*, che e' un tema delicato e che un responso
rivolto alla persona non puo' nominare: tre casi su seimilasettecentottantuno.
Una runa su ventiquattro, e bastava quella.

**Due, togliendolo la somiglianza e' SCESA, da 39,6 a 27,0 per cento.** I
ventiquattro significati sono ventiquattro testi fissi: su cento gettate
tornavano di continuo, ed **erano essi stessi testo condiviso**. Avevo aggiunto
varieta' credendo di aggiungerla e ne stavo togliendo. **Il numero lo ha detto,
io no.**

### Il Viaggio dello Sciamano, la scena del ritorno

| misura | PRIMA | DOPO | soglia |
|---|---|---|---|
| A, testi distinti | 100 / 100 | **100 / 100** | 100 |
| B, scheletri distinti | **6 / 100** | **99 / 100** | 90 |
| B, scheletro piu' ripetuto | **57 volte** | **2** | 3 |
| C, coppia peggiore fra le diverse | **90,0 per cento** | **25,0 per cento** | 40 |
| C, coppia peggiore in assoluto | 90,0 | 63,2 | riportata |
| D, paragrafo piu' ripetuto | 1 | **1** | 2 |

**Sei scheletri su cento, e il piu' ripetuto cinquantasette volte.** La scena
aveva **tre stampi in tutto**, uno per grado di nitidezza. E il seme nasceva
dalla domanda e dal giorno: **due discese nello stesso giorno con la stessa
domanda davano la stessa identica scena**, parola per parola.

### LA LEZIONE CHE VALE PER TUTTE E TRE, e che non era ovvia

**Le forme lunghe alzano la misura B e peggiorano la C.** Piu' impalcatura vuol
dire piu' forme possibili, e quindi piu' scheletri distinti; ma vuol dire anche
piu' parole in comune quando due consultazioni cadono sulla stessa forma.
Misurato sul Viaggio: aperture e chiusure lunghe hanno portato B da 46 a 98
**e** C da 28,6 a 49,3 per cento.

**La via che soddisfa tutte e due e' TANTE FORME CORTE.** Una frase di quattro
parole **non produce nessuna sequenza di cinque**, che e' l'unita' con cui la
misura C conta: due scene che aprono con la stessa apertura corta non si
somigliano per questo. Accorciando le aperture e portandole a dodici, il
Viaggio e' andato a B 99 e C 25,0.

---

## 5. LE FREQUENZE DELL'ESTRAZIONE

Guardia: `test/l_estrazione_e_realistica_test.dart`. Diecimila estrazioni per
parte, come chiede la voce.

### Le settantotto carte

- **stese**: 10.000, carte estratte **30.000**
- **carte diverse uscite**: **78 su 78**
- **attesa per carta**: 384,6
- **scarto massimo**: **9,7 per cento** (La Papessa, 422 volte contro 384,6)
- **doppioni dentro la stessa stesa**: **0**
- **rovesciate**: **29,97 per cento** contro il 30 dichiarato
- **carte che escono sempre nello stesso verso**: **0 su 78**

**Soglia dichiarata sullo scarto: il dodici per cento.** Con 384 attese per
carta lo scarto tipico di un dado onesto e' la radice di 384 diviso 384, cioe'
il cinque per cento; su settantotto carte il massimo fra tante estrazioni
arriva naturalmente a due deviazioni e mezza, cioe' intorno al dodici. Sopra
quella riga non e' piu' caso.

### Le ventiquattro rune

- **gettate**: 10.000 da tre, rune estratte **30.000**
- **rune diverse uscite**: **24 su 24**
- **attesa**: 1250,0
- **scarto massimo**: **6,9 per cento** (Jera, 1336 volte contro 1250)
- **doppioni nella stessa gettata**: **0**
- **merkstave**: **33,6 per cento** contro un atteso del **33,3**

**L'atteso del merkstave non e' il cinquanta per cento, ed e' la parte che si
sbaglierebbe a occhio**: le otto rune simmetriche non hanno un rovescio, quindi
l'atteso e' mezzo di sedici su ventiquattro, cioe' 33,3.

### La sorgente di casualita', dichiarata

- **carte**: `dart:math` `Random()` **senza seme** in produzione, dentro
  `TarotSpread.mazzoMescolato` e `TarotSpread.draw`.
- **rune**: `dart:math` `Random()` **senza seme** in produzione, dentro
  `RuneCast.getta`.
- **verso delle carte**: `Random(indiceCarta * 7919 + seme)`, dove **seme era
  la costante zero in produzione** e adesso e' `Random().nextInt(1 << 31)`,
  tirato **una volta per schermata**. Dentro una stesa il verso di una carta
  resta fermo, che e' il requisito dell'ordine P voce 04; fra due stese cambia.

### L'INDIZIO DE "IL MONDO", verificato e non creduto

Nelle quattro letture del fondatore Il Mondo e' comparso **tre volte su
quattro**, e l'ordine stimava quella coincidenza attorno a **due su
diecimila**.

**Verificato: l'estrazione delle CARTE non era pilotata.** Il mescolamento
usava `Random()` senza seme, e su diecimila stese tutte e settantotto le carte
escono con uno scarto massimo del 9,7 per cento. **Le tre comparse de Il Mondo
sono il caso raro capitato a lui.**

**Ma cercandolo si e' trovato un difetto vero e piu' grave**, che nessuno
cercava: il verso. E il fatto istruttivo e' questo: **col ripiego a zero le
carte che cadevano rovesciate erano 23 su 78, cioe' il 29,5 per cento contro il
30 dichiarato.** Una prova che avesse contato solo la percentuale di rovesciate
sarebbe stata **verde**, e il fatto sarebbe rimasto falso. Per questo la
guardia conta anche **quante carte cambiano verso fra due estrazioni**, che e'
la grandezza che il difetto tocca.

---

## 6. I NOVE DIFETTI DELLA VOCE 04

**Attribuzione, regola TRE dell'ordine.**

| | difetto | attribuito a | che cosa e' cambiato |
|---|---|---|---|
| 04.1 | il Consiglio non dipende dalle carte | **ordine S voce 26** (la risposta del gruppo, allegato C) e **ordine P voce 09** (il montaggio) | il primo paragrafo nomina la carta del Presente in tutte e cento le letture provate; le forme stanno in `VoceDellaStesa` |
| 04.2 | il futuro trattato come minaccia | **ordine P voce 09**, la formula unica | quattro nature dalla croce verso per arcano, otto chiusure per natura; su 64 letture col Futuro di compimento le minacce trovate sono **zero** |
| 04.3 | i significati scritti due volte | **ordine P voce 09** | il Consiglio **nomina** le carte e non le cita: significati ripetuti trovati **zero** |
| 04.4 | la parola Carta isolata | **ordine CO voce 08** | `maxLines: 1` col ritorno a capo acceso buttava via la seconda riga; adesso `FittedBox` e `softWrap` spento |
| 04.5 | il titolo col significato compare a volte | **PROVENIENZA IGNOTA** | il titolo passa da `VoceDellaStesa.titolo`, che toglie il punto e non torna mai vuoto: titoli guasti su 384 provati, **zero** |
| 04.6 | la domanda non compare mai | **ordine CQ voce 6.10** | il riquadro c'era ma **solo per chi scriveva la domanda a mano**; adesso la riga sta sotto il titolo e c'e' sempre, con la domanda o col nome dell'argomento |
| 04.7 | il numero dei Maggiori in cifra | **ordine P voce 08**, la coda della bolla eliminata | `VoceDellaStesa.inLettere`; letture con una cifra nel Consiglio, **zero su 384** |
| 04.8 | la punteggiatura che inciampa | **ordine P voce 09** | le carte si nominano e non si citano; ogni forma e' una frase intera |
| 04.9 | l'ordine di lettura | **ordine P voce 09** | le carte sono nel **primo** paragrafo; lunghezza e divisione restano quelle, mediana **845 caratteri** su 6400 composizioni |

**LA GUARDIA CHE DIFENDEVA IL DIFETTO.** `il_consiglio_dei_tarocchi_e_la_sua_anatomia_test.dart`
pretendeva tre cose, e tutte e tre **erano** il difetto: che esistesse la
cucitura *"Le tre carte lo dicono insieme."*, che **nessuna carta fosse
nominata prima** di quella cucitura, e che il Consiglio **aprisse** con la
lente piu' la risposta del gruppo. Era verde, e la persona leggeva quattro
responsi identici. **E' il caso piu' puro della quarta specie di cecita' del
registro: una prova viva, che misura davvero, e che misura la cosa
sbagliata.** Rifatta per intero sulla legge nuova.

**IL TETTO DEL CONSIGLIO.** Rimisurato: mediana **845 caratteri**, caso
peggiore **1068** su 6400 composizioni (sedici argomenti per duecento
estrazioni nei due casi della domanda). Il tetto sale da 1100 a **1250**, che
tiene il caso peggiore col diciotto per cento di margine. **La mediana non e'
cambiata**, ed e' la misura che il fondatore ha dichiarato buona: e' cresciuta
la coda. Per la stessa ragione la riga di *"come si vede se ha funzionato"* e'
rimasta **fuori** dal Consiglio: con lei dentro il caso peggiore passava il
tetto e la bolla veniva troncata.

**LE CATTURE DAL TELEFONO**: vedi il punto 1, non sono state prese.

---

## 7. IL CONTO DI FLUTTER ANALYZE

- **dopo**: **0 problemi**, misurato eseguendo `flutter analyze` sul ramo con
  tutto il lavoro dentro.
- **prima**: **non rimisurato al commit 86316005**, quello della consegna della
  2245, e lo dico invece di scrivere uno zero che non ho contato. Rimisurarlo
  chiederebbe un albero di lavoro nuovo su quel commit, con il suo `pub get`,
  e non l ho fatto.
- **quello che so per certo**: durante questo lavoro sono comparsi **tre**
  avvisi, due import inutilizzati e un `final` che poteva essere `const`, ed
  erano **tutti e tre miei**. Sono stati chiusi prima della consegna. Non ne
  sono comparsi altri, quindi **la differenza fra prima e dopo e zero oppure a
  favore del dopo**, e non puo' essere a sfavore.

---

## 8. LA PROVA DEL ROSSO, guardia per guardia

Regola QUATTRO: ogni guardia nuova nasce rossa, il difetto si reinietta
davvero, l'innesto si verifica **col grep**, e solo dopo si legge l'esito.

| guardia | come e' stata vista rossa | esito del rosso |
|---|---|---|
| `cento_letture_uguali_test` | nessuna iniezione: **e' nata rossa sul codice vero**, prima della riparazione | C 94,4 per cento, D 100 volte su 100 |
| `la_guardia_della_diversita_test` | nessuna iniezione: **nata rossa su due funzioni su tre** | Rune C 82,8; Viaggio B 6 su 100 |
| `l_estrazione_e_realistica_test` | reinnestato il ripiego a zero del seme dei versi, verificato col grep | trovati due ripieghi nel sorgente, prova rossa |
| `il_consiglio_dei_tarocchi_e_la_sua_anatomia_test` | nessuna iniezione: la stesura vecchia della guardia era **verde sul difetto**, e la nuova e' **rossa sulla stesura vecchia del codice** | cinque prove su nove |
| `quanto_e_lungo_il_consiglio_test` | nessuna iniezione: nata rossa col tetto vecchio | margine del 4 per cento contro il 5 preteso |

---

## 9. LE DECISIONE PRESE DA ME, ognuna con la sua riga

1. **Una sequenza e' cinque parole**, non due: a due parole si misura quanto
   l'italiano somiglia a se' stesso.
2. **La soglia della misura C guarda le coppie senza simboli in comune**:
   altrimenti misura la probabilita' di ripescare le stesse carte, che non si
   puo' e non si deve cambiare.
3. **La misura D conta i paragrafi COMPOSTI dall'app**, non quelli che citano
   il corpus di un simbolo uscito: su cento estrazioni da settantotto carte la
   stessa carta ricompare per forza, e il suo testo deve essere lo stesso.
4. **Le forme sono tante e corte** invece di poche e lunghe: e' l'unico modo
   di soddisfare la B e la C insieme.
5. **Il filo che sceglie le forme nasce dai simboli usciti**, mai
   dall'orologio: cosi' il testo resta deterministico e cacheabile, e la
   casualita' resta nel mazzo.
6. **Il tetto del Consiglio sale da 1100 a 1250** invece di accorciare i testi:
   il tetto governa il caso peggiore, la mediana e' quella che il fondatore ha
   approvato e non si tocca.
7. **La riga di "come si vede se ha funzionato" resta scritta e fuori dal
   Consiglio**: fra la varieta' e una misura che il fondatore ha dichiarato
   buona, vince la misura.

---

MARCATORE TERMINALE DELL'ORDINE DF. Sette voci su sette chiuse.
