# ORDINE DG, IL VIAGGIO DELLO SCIAMANO DA CAPO

**Sigla:** DG. **Verificata libera** l'11 settembre 2026: in `docs/ordini/`
esistono i manifesti da DA a DF, e nessun DG. Resta DG.

**Data:** 11 settembre 2026. **Ramo:** `claude/esoteric-circle-master-order-e798aj`.

VOCI_TOTALI: 9
VOCI_CHIUSE_NEL_CODICE: 8
VOCI_APERTE: 1

---

## 1. LA VOCE RIMASTA APERTA, in cima e non in fondo

**DG.09, il rapporto con le catture dal telefono.** Il codice e' scritto,
misurato e verde al banco; **le catture non sono state prese**, e la ragione
sta nell'ordine stesso: *"La build la ordina il fondatore. Se serve costruire,
la domanda si gira a lui."* Per guardare a video queste otto voci serve una
build nuova sul 767f596c, e quella build la ordina il fondatore.

**Tutto il resto e' pronto perche' quel giro si faccia in venti minuti**: il
comando di Demo della voce DG.08 esiste e riporta il Viaggio a zero discese
senza toccare l'account.

---

## 2. LE QUATTRO PREMESSE, con i comandi che le hanno verificate

### P1. Esistono due calcoli distinti dell'animale guida? **VERA.**

```
grep -rn "GuideAnimalDerivation\." lib/ --include=*.dart | grep -v derivation.dart:
grep -rn "seguitoDaLeQuattroScelte" lib/ --include=*.dart
```

- **Porta della nascita**: `GuideAnimalDerivation.forSign(Zodiac)` in
  `lib/core/rituals/guide_animal_derivation.dart` riga 33. Tabella biiettiva
  segno verso animale, funzione pura. **Dodici chiamanti.**
- **Porta del Viaggio**: `IQuattroViaggi.seguitoDaLeQuattroScelte(scelte)` in
  `lib/core/viaggio/i_quattro_viaggi.dart` riga 113, *"vince quello seguito
  piu' volte, a parita' l'ultimo"*. **Cinque chiamanti.**

### P2. Il Passaporto legge la prima e il Viaggio la seconda? **VERA, e peggio.**

Il Passaporto leggeva **tutte e due, a dieci righe di distanza**:
`cosmic_passport_screen.dart` righe 515 e 517. Da li' il Lupo e l'Aquila nella
stessa schermata.

### P3. Il Sigillo del Sogno ha gia' un diradamento a movimento continuo? **VERA.**

`lib/features/rituals/dream_rite_screen.dart` riga 454: `onPanUpdate` accumula
`_spintaDito` con `d.delta.distance / 90`; un battito ogni 60 ms alza la nebbia
di 0,035 finche' la spinta supera 0,10 e la riabbassa di 0,004 quando il dito
si ferma; la spinta cala da sola di 0,06 a ogni battito. Il pittore e'
`_FoschiaPainter`.

### P4. Esiste un comando per rigiocare i quattro giorni? **FALSA.**

In `DiarioDeiViaggi` c'erano `carica`, `segna` e `nutri`. Nessun azzeramento.
**La voce DG.08 lo crea**, e la premessa si dichiara falsa invece di far finta.

---

## 3. LE OTTO VOCI, una per una

### DG.01, l'animale guida e' uno solo e nasce dalla nascita

**Che cosa e' cambiato.** `seguitoDaLeQuattroScelte` **non esiste piu'**. Al
suo posto `nomeDopoLeQuattroDiscese(discese, animale)`, che risponde **se** il
nome si puo' dire e non **quale**: il quale viene sempre da
`GuideAnimalDerivation.forSign`. I cinque chiamanti passano tutti di li'.

**ATTRIBUZIONE: ordine DC voce 04, 10 settembre 2026.** Il commento del file lo
dichiarava da se': *"Il cielo restringe: la data di nascita porta a tre
candidati, non a uno. Le scelte decidono"*. La seconda porta e' nata li', con
le migliori intenzioni.

**PERCHE' SOPRAVVIVE LA NASCITA, e non lo decide questo ordine.** Master
Briefing, Linee Guida UX Trasversali, sezione 5: fra i dati **identitari e
fissi**, deterministici e immutabili, elenca *"carta natale, Angelo Custode,
archetipo, **Animale Guida**"*. Le arti a esito variabile stanno in un altro
elenco.

**LA MISURA:** `test/l_animale_guida_ha_una_porta_sola_test.dart`.

- **12.000 esecuzioni** su dodici nascite: sempre lo stesso animale.
- **Il caso del fondatore e' nominato**: chi nasce sotto il Cancro ha il Lupo,
  e la prova tiene ferma quella riga della tabella.
- **604 file di lib** guardati: nessuno apre una seconda porta.

**NATA ROSSA:** rimesso `seguitoDaLeQuattroScelte` nel Passaporto, la guardia
ha detto *"seconde porte trovate 1, lib/features/passport/cosmic_passport_screen.dart riga 521"*.

### DG.02, il Viaggio rivela e non estrae

**Le quattro discese mostrano sempre lo stesso animale**, il suo. Cambia quanta
luce gli arriva addosso e quanto se ne scopre con la lente; il file e' sempre
lo stesso.

**LA DECISIONE CHE L'ORDINE LASCIA A CHI ESEGUE: una sola ombra.** L'ordine
dice *"chi esegue decide se tenerle o mostrarne una sola, e lo motiva"*.

**Una sola**, perche' con l'animale deciso dalla nascita scegliere fra tre
sarebbe **una scelta che non cambia niente**: la persona crede di decidere e
non decide, che e' peggio del non farla decidere affatto. In Harner il
riconoscimento sta nel **ritorno**, non nella selezione fra candidati.

**LA MISURA:** `test/l_ombra_e_il_suo_animale_test.dart`.

- dodici file, **900 per 700, alpha vero** su tutti e dodici;
- **l'ombra coincide con la sagoma della sua illustrazione dal 97,4 per cento
  in su** (il peggiore e' il Cavallo);
- **due ombre di animali diversi si somigliano al massimo per il 70,6 per
  cento** (Aquila e Falco), che e' la seconda meta' senza cui la prima non
  direbbe niente.

**LA PRIMA STESURA DELLA MISURA ERA SBAGLIATA, e si dice.** Confrontava le
maschere **nella stessa posizione** e dava 27 per cento sul Cervo: le ombre
sono ricentrate con margine del dieci per cento, mentre le illustrazioni hanno
ognuna la sua forma. **Si e' cambiata la grandezza misurata**, cioe' la forma
dentro il riquadro dei pixel opachi, **e non la soglia**.

**NATA ROSSA:** copiata l'ombra del Lupo su quella dell'Aquila, la guardia ha
detto *"due ombre diverse si somigliano al 100 per cento: Aquila e Lupo"*, e
l'Aquila e' scesa al 50,8 per cento con la propria illustrazione. Ripristino
verificato coi byte (24.486) e con `git status`.

### DG.03, il Passaporto e l'onboarding non anticipano

**03.1** L'onboarding mostrava **l'illustrazione a colori** sotto la frase che
prometteva di non dirlo. Adesso mostra **la sua ombra**, la stessa che si
incontrera' scendendo.

**ATTRIBUZIONE: ordine DC voce 02**, che aveva tolto **il nome** e lasciato
**il ritratto**. Un animale si riconosce guardandolo: lasciare il ritratto era
consumarlo lo stesso.

**03.2** Nel Passaporto la casella portava una sagoma disegnata da una formula,
`PittoreDellAnimale`, che **faceva sempre un quadrupede**: e' lo stesso difetto
di verita' che l'ordine DE aveva gia' tolto dall'incontro, e qui era rimasto.
Adesso e' la sagoma vera del suo animale, velata.

**E il pittore procedurale e' uscito di scena**, come l'ordine chiede: al suo
posto una lapide che dice perche' non c'e' piu'.

### DG.04, la scheda dell'animale va per ultima

`angeli, heaven, chart, resonance, reveal, **animale**, custodia`.

**Fra le due richieste del fondatore, *dopo gli angeli* e *per ultima*, vale la
seconda**, che e' la piu' stretta: sta in fondo a tutte le schede, subito prima
della custodia del cielo, che non e' una scheda ma il congedo.

**E il testo del pulsante lo dice**: non piu' *"Chi altro veglia su di me"*, che
prometteva gli angeli, ma *"Custodisci il mio cielo"*, che e' quello che viene
dopo davvero.

### DG.05, la nebbia si dirada col dito

**I tre tocchi sono spariti.** `onPanUpdate` accumula la spinta, un battito
ogni 60 ms alza la nebbia, e la spinta cala da sola: **fermarsi non tiene
aperto**.

**LA TARATURA VIENE DAL SIGILLO DEL SOGNO e adesso vive in un posto solo**,
`lib/core/sensi/respiro_che_dirada.dart`. Due copie dello stesso numero si
sarebbero separate alla prima ritoccata, e allora una nebbia si diraderebbe in
un modo e l'altra in un altro: e' la famiglia delle due porte, in forma di
numero.

**ATTRIBUZIONE: ordine DC voce 05**, che aveva scritto la nebbia a varchi.

**LA MISURA:** chiarore medio della scena a nebbia chiusa **100,9**, a meta'
strada **68,4**, aperta **25,6**. Con la mano che si muove la nebbia si apre in
**29 passi da 60 ms, cioe' 1,7 secondi**. A dito fermo torna indietro.

### DG.06, la discesa dura venti secondi

**Erano nove.** La prima discesa era gia' a venti; **la discesa conosciuta**,
cioe' tutte le altre, era a nove secondi, messi li' dall'ordine DC come *"meno
della meta' della prima"*. Il fondatore aveva fissato **venti** nell'ordine DE,
e nove non e' venti: quella non era una discesa, era una scorciatoia.

**La misura col cronometro sul telefono manca**, e sta nella voce DG.09.

### DG.07, le risposte seguono le regole

**Erano una frase sola**: apertura piu' corpo piu' chiusura, e dentro non
c'era ne' la domanda con cui eri sceso, ne' un gesto da fare, ne' la fonte.

**Adesso sono quattro pezzi**, come le altre risposte di casa:

1. **il titolo**, che a colpo d'occhio e' gia' una risposta;
2. **la risposta**, che nomina **la domanda con cui sei sceso**;
3. **cosa puoi fare**, un gesto solo e concreto, col suo quando;
4. **da dove viene**, cioe' la scena, che e' la fonte e sta verso la fine.

**LE QUATTRO MISURE, su cento discese con la stessa domanda, per tutte e sei le
domande:**

| | soglia di casa | misurato |
|---|---|---|
| **A**, testi distinti | 100 su 100 | **100 su 100** |
| **B**, scheletri distinti | almeno 90 | **100 su 100** |
| **C**, coppia piu' simile | al massimo 40 per cento | **da 28,2 a 34,3 per cento** |
| **D**, paragrafo piu' ripetuto | al massimo 2 | **2** |

**Nessuna soglia e' stata toccata.** Ci sono voluti cinque giri, e **ogni giro
l'ha deciso un numero**:

1. **D 32** era il titolo, che aveva quattro forme per tema: una su quattro.
2. **D 16, poi 6** era il paradosso del compleanno: con poche centinaia di
   combinazioni la collisione tripla su cento estrazioni e' probabile, e non e'
   un difetto del compositore. Si sono alzate le combinazioni a
   **millesettecentoventotto**, non la soglia.
3. **A 98** erano due scene identiche in due giorni diversi: il vocabolario e'
   finito e la ripetizione della **scena** e' matematica, quella del **testo**
   no. Il filo adesso conosce il giorno.
4. **D 3** erano tre scelte consecutive dello stesso filo, che su semi vicini
   camminano insieme: adesso ogni paragrafo ha il suo.
5. **C 42,9 per cento** su un solo tema era il tema stesso, *"un blocco che non
   si supera"*, sei parole ripetute in ogni ripresa: adesso meta' delle riprese
   lo nominano in due parole.

### DG.08, il comando di Demo per rigiocare

`DiarioDeiViaggi.ricomincia()` toglie **le due chiavi del Viaggio e
nient'altro**: `viaggio.diario` e `viaggio.nutrimenti`, nominate una per una.
Non l'account, non il cammino, non i sigilli.

**Solo in Demo**, perche' il riconoscimento costa quattro giorni: un comando che
lo annulla, a portata di dito di chiunque, toglierebbe alle quattro discese la
cosa che le rende quattro.

Il pulsante sta **sulla soglia, accanto al numero che azzera**, e non tre
schermate piu' in la'.

---

## 4. I QUINDICI ASSET

Presi da `C:\Users\user\Desktop\esoteric-circle-app\assets\img\mondo_di_sotto\`,
portati nel ramo, dichiarati in `pubspec.yaml` e in `docs/stato_asset.json`.

**Gli slot li aspettavano dall'ordine DC**: `SfondoDelMondoDiSotto` puntava
gia' a `soglia_bosco_v1.webp` e a `fondo_nebbia_v1.webp`. Mancavano i file,
quindi ogni `Image.asset` cadeva nel suo `errorBuilder` e a schermo arrivava il
disegno procedurale. **Da qui la frase del fondatore**: *"quando apro la
funzionalita', non ci sono tutte le immagini che ho creato con nano banana"*.

| file | misura | alpha |
|---|---|---|
| `soglia_bosco_v1.webp` | 1240 x 1000 | senza |
| `fondo_nebbia_v1.webp` | 1080 x 2040 | senza |
| `tunnel_parete_v1.webp` | 1024 x 1024 | senza |
| dodici `ani_ombra_*_v1.webp` | 900 x 700 | **vero, verificato** |

**Ogni sagoma occupa l'ottanta per cento di un lato della sua tela**, misurato
file per file: e' il margine del dieci per cento dichiarato dall'ordine.

---

## 5. CHE COSA HANNO PRESO LE GUARDIE DI CASA

Sul testo nuovo, come sempre e in un colpo solo:

- **quattordici righe** con la virgola piu' *e*, che la regola di casa vieta;
- **due apostrofi al posto dell'accento** nelle stringhe di lib;
- **una barra dentro la stringa del percorso** delle ombre, che
  `niente_vocativo_a_schermo` legge come un elenco di participi: il percorso si
  compone da cinque costanti, com'era gia' stato fatto per i versi.

---

## 6. LE PROVE VECCHIE CHE DIFENDEVANO IL DIFETTO

**Non si cancellano: si riscrive la grandezza misurata e si dice perche'.**

- *"LE TRE OMBRE SONO TRE, DIVERSE, E SEMPRE LE STESSE"* pretendeva che
  l'incontro mostrasse tre animali fra cui scegliere. Adesso misura che ogni
  segno porti a **un** animale, sempre lo stesso, e che la sua ombra esista.
- *"IL NOME NON SI DICE PRIMA DELLA QUARTA DISCESA"* lo verificava **contando
  le scelte**, cioe' passando dalla seconda porta.
- *"AL QUARTO VIAGGIO OCCUPA ALMENO IL 60 PER CENTO DELL ALTEZZA"* misurava il
  pittore procedurale. Adesso rasterizza il widget vero col file vero, e misura
  **il lato che riempie** invece dell'altezza: la scena del ritorno e' larga e
  i dodici hanno forme diverse, quindi la stessa figura grande dava 74 per
  cento su un animale e 21 su un altro.
- **le tre prove della nebbia** misuravano i varchi, cioe' erano la prova che i
  tre tocchi funzionassero.
