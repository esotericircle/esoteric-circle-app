# ORDINE DG, IL VIAGGIO DELLO SCIAMANO DA CAPO

**Sigla:** DG. **Verificata libera** l'11 settembre 2026: in `docs/ordini/`
esistono i manifesti da DA a DF, e nessun DG. Resta DG.

**Data:** 11 settembre 2026. **Ramo:** `claude/esoteric-circle-master-order-e798aj`.

VOCI_TOTALI: 9
VOCI_CHIUSE_NEL_CODICE: 8
VOCI_APERTE: 1
CORREZIONI_DAL_VIVO: 9
CORREZIONI_CHIUSE_NEL_CODICE: 9

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

---

## 7. LA SECONDA TORNATA, nove correzioni dal vivo

**Il fondatore ha camminato la 2248 e ha parlato mentre camminava.** Non e' un
ordine nuovo: e' la stessa voce DG, guardata a video. Nove correzioni, tutte
accolte, tutte chiuse nel codice il 12 settembre 2026.

### 7.1 La scheda dell'animale va SUBITO DOPO GLI ANGELI

*"la schermata c'e' con l'animale oscurato, ma andrebbe messa dopo la
rivelazione degli angeli. adesso e' dopo la rivelazione del maestro."*

**ATTRIBUZIONE: mia, DG voce 04.** La voce diceva *"dopo gli angeli, per
ultima"* e io avevo scelto **la seconda meta' della frase**, motivandola come la
piu' stretta. Era una lettura, non un fatto, e il fondatore ha corretto.

L'ordine adesso e': **angeli, animale, carta di nascita, cielo, carta natale,
risonanza, Maestro, custodia**. I due pulsanti hanno cambiato parole, perche'
dicevano dove si andava: *"Continua"* e' diventato *"Chi altro ti accompagna"*,
*"Custodisci il mio cielo"* e' diventato *"La tua Carta di Nascita"*.

### 7.2 L'animale resta velato IN TUTTI I POSTI

*"nel Passport mi fa gia' vedere il lupo. il mio animale."*

**ATTRIBUZIONE: ordine DC, e prima ancora la nascita della funzione.** Il
difetto non era una schermata: era **una regola senza casa**. Il Passaporto
sapeva che il nome si dice dopo quattro discese **e lo sapeva da solo**, dentro
il suo `build`. Gli altri posti che mostrano l'animale non lo sapevano affatto.

**La cura e' un file:** `lib/core/viaggio/il_nome_si_puo_dire.dart`. Due modi di
chiedere, e la differenza conta: chi puo' aspettare legge l'archivio, chi
disegna dentro un `build` sincrono legge l'ultimo conto noto, **e quando non sa
niente risponde di no**.

I posti riparati sono quattro: la **carta natale**, che scriveva *Lupo* a
lettere intere accanto al totem a colori, ed e' la piu' grave perche' si apre
**due schermate dopo** la scheda che promette di non svelarlo; la **lettura
dell'animale**, che e' la rivelazione intera; il **simbolo dell'attesa di
Caligo**, che mostrava il totem mentre il Maestro componeva; il **bosco del
Cerchio**, che accendeva la tessera del tuo.

### 7.3 La rivelazione della Carta di Nascita entra nell'onboarding

*"nell'onboarding manca anche la schermata di rivelazione della carta di
nascita. ti avevo dato ordine con istruzioni dettagliate se non sbaglio."*

**ATTRIBUZIONE: ordine DC voce 14, 10 settembre 2026, e la colpa e' mia due
volte.** Il file esisteva, era provato da una guardia che confronta **576
istanti dell'animazione coi numeri del calcolo**, e **non lo chiamava nessuno**.
Il rapporto di quell'ordine scriveva *"vive nell'onboarding"*: non era vero, ed
e' un rapporto che ha dichiarato il falso.

**Nessuna guardia poteva vederlo**, perche' tutte guardavano il contenuto e
nessuna la strada. Adesso ce n'e' una.

### 7.4 La parete di roccia nella discesa

*"la discesa del viaggio e' ancora una merda con grafica procedurale e ti ho
fornito la grafica con texture roccia."*

**ATTRIBUZIONE: mia, e il manifesto diceva il falso.** `tunnel_parete_v1.webp`
era nel ramo e dichiarato in `pubspec.yaml`, **e non lo usava nessuno**: zero
occorrenze in tutto `lib`. Gli slot che aspettavano gli asset erano due, la
soglia e il fondo di nebbia; **per il tunnel lo slot non esisteva affatto**.

La parete si ripete a piastrella, sei giri su tutta la discesa, e gli anelli del
pittore restano **sopra** di lei col fondo portato a velo: la materia e' vera,
la profondita' resta disegnata.

### 7.5 La discesa dura venti secondi, misurati

*"dura ancora troppo, devi ridurre la discesa a 20 secondi."*

La discesa conosciuta stava a **nove** secondi, scelti dall'ordine DC come
*"meno della meta' della prima"*: il fondatore aveva gia' fissato venti
nell'ordine DE, e nove non e' venti. Adesso sono venti tutte e due, **e li
misura una guardia col cronometro**, non leggendo la costante: quella diceva
venti anche quando la discesa ne durava quarantasei.

### 7.6 Il velo non dipende piu' da un'animazione

**ATTRIBUZIONE: PROVENIENZA IGNOTA, e va detto per esteso.** Il difetto e' stato
visto a video **due volte**, sulla 2247 e sulla 2248: l'animale intero, testa
compresa, mentre lo schermo diceva *"la lente scopre solo dove puo', oggi"*. La
prima volta l'avevo attribuito allo `ShaderMask` con `BlendMode.dstIn`; tolto
quello, il difetto e' tornato identico. **Quindi la mia attribuzione era
sbagliata.**

Cio' che e' rimasto uguale fra le due build e' `Opacity(opacity: _caduta.value)`
con un `AnimationController` dietro, e **il 767f596c ha le tre scale di
animazione a zero**. Un velo che vale zero e' un velo che non c'e'. Adesso,
finche' c'e' da coprire, **il velo si disegna pieno e senza `Opacity`**.

### 7.7 La rivelazione e' cumulativa, e la testa e' dell'ultimo giorno

*"il secondo giorno dovrei vedere in chiaro quello che ho scoperto con la lente
il giorno prima e cosi' via. solo l'ultimo giorno la lente scoprira' la testa
dell'animale."*

**Erano due cose, e ne mancavano due.** Ogni discesa ripartiva da zero: il velo
tornava su tutto e quello che si era scoperto spariva. E **alla quarta discesa
il velo non c'era affatto**: l'area era l'immagine intera, quindi la lente non
scopriva la testa, **la testa era gia' li'**.

Adesso le tre fasce sotto la testa si aprono dal basso, una per discesa, e
restano aperte; alla quarta resta velata **la sola testa**, e l'area della lente
**e' la testa**. Il velo cade dopo, ed e' la card della rivelazione.

### 7.8 Il velo stringe alla prima discesa

*"l'animale sfocato con la lente si capisce benissimo cos'e', e' ancora troppo
evidente."*

Sfocatura e buio erano **costanti**. La prima discesa e la terza non hanno lo
stesso compito: alla prima non si deve riconoscere niente, alla terza si e' gia'
visto due terzi del corpo e nasconderlo sarebbe una finzione. Adesso la
sfocatura va da 0,060 a 0,035, la coltre da 0,88 a 0,80, e il fantasma sfocato
dal trentotto al cinquantacinque per cento.

**La guardia non legge quei numeri**, misura la nitidezza dei pixel: alla prima
discesa la testa velata sta al **72,8 per cento** della nitidezza che ha alla
terza, nel caso peggiore dei dodici.

### 7.9 La dissolvenza che introduce la nebbia

*"quando si scende, dovrebbe esserci una dissolvenza che introduce la nebbia."*

Al colpo di gong dei venti secondi la fase passava **in un fotogramma**: il
tunnel spariva e al suo posto compariva la nebbia gia' fatta. Adesso la nebbia
c'e' gia' sotto e **la galleria si dissolve sopra di lei** in un secondo e due
decimi, con l'istruzione che arriva a dissolvenza finita.

**E la dissolvenza e' un battito, non un `AnimationController`**: e' la lezione
del velo, pagata due volte.

---

## 8. LE TRE GUARDIE NUOVE, e che cosa hanno preso mentre nascevano

| guardia | cosa misura | com'e' nata rossa |
|---|---|---|
| `l_animale_resta_velato_ovunque` | ogni file che deriva l'animale dal segno sa della soglia | **su due file veri**: il bosco del Cerchio e il Risveglio |
| `nessuna_schermata_del_risveglio_e_orfana` | nessun widget dell'onboarding senza chiamanti, nessuna tappa senza assegnazione | due volte, una per meta' |
| `la_discesa_dura_venti_secondi` | il tempo col dito premuto, e l'opacita' vera della dissolvenza | la discesa conosciuta a nove secondi; la dissolvenza saltata a uno |

**La prima e' nata rossa su un difetto che non avevo visto.** Il bosco del
Cerchio derivava l'animale dal segno e accendeva la sua tessera: chi ci fosse
arrivato senza aver fatto il Viaggio avrebbe letto il proprio animale in un
elenco di dodici. L'avevo cercato in tre posti e il quarto me l'ha trovato la
guardia.

**E la seconda ne ha trovati altri quattro che c'erano gia'.** Il fondatore ha
risposto *"finisci tutto cio' che e' indietro"*, e sono stati chiusi tutti e
quattro, in due modi diversi perche' erano due cose diverse.

**Tre erano orfani veri, e sono stati tolti.** `IntertwinedAuras`, `SkyThread` e
`StardustName` sono tre animazioni decorative del **vecchio** onboarding, e la
storia di Git lo dice per nome: erano montate nei commit `202dc99c`, `70f3f9a9`
e `7d15c077`, poi la rilavorazione dell'arco di onboarding ha cancellato le
schermate che le montavano **lasciando i file**. Non erano lavoro perso da
riagganciare: erano tre disegni la cui parete non esiste piu'. Riagganciarli
avrebbe voluto dire rimettere mano al disegno dell'onboarding, che nessuno ha
chiesto; tenerli avrebbe voluto dire far scorrere ogni guardia futura su
quattrocento righe che nessuno vede. Tolti, e la storia se li tiene.

**Il quarto non era un orfano, e crederlo tale e' stato un mio errore di
lettura.** `DomandaDellInvito` non la monta nessuno **perche' il fondatore l'ha
fatta togliere**: *"e' una demo per ora, si toglie e accettiamo che per ora
nessuno riscuote i 60 EOS, ma va sistemato prima della pubblicazione"*. C'e'
gia' una guardia che lo presidia, `l_invito_porta_il_suo_premio`, e **pretende**
che il Santuario non la chiami; la strada a mano resta nel menu' Account. Una
decisione presa non e' una dimenticanza, e il debito e' gia' scritto in
`docs/ordini/RIPRESA.md`.

**Il censimento della guardia adesso e' vuoto**, e non e' una formalita': finche'
resta vuoto, ogni nome che quella prova mostrera' e' un difetto **nuovo**, e
nessuno dovra' chiedersi se sia invece uno vecchio che qualcuno aveva accettato.

**Togliere i tre file ha fatto cadere due guardie, ed era giusto cosi'.**
`chi_misura_il_testo_usa_la_scala` teneva una deroga dichiarata per
`sky_thread.dart` e ha detto *"il file non esiste piu'"*: una scusa scaduta e'
il modo in cui una regola smette di significare qualcosa. E
`tipografia_nel_dato` ha detto che il debito era sceso da 82 misure a 81 e da 34
file a 33, **e che il censimento non lo sapeva ancora**: rigenerato e
committato insieme al codice.

---

## 9. LE PROVE CHE DIFENDEVANO L'ORDINE VECCHIO

**Sei prove sono state riscritte, e nessuna cancellata.** Tutte dicevano il
vero su una regola che il fondatore ha cambiato, e una diceva il vero su una
lettura mia che era sbagliata.

| prova | cosa pretendeva | cosa pretende adesso |
|---|---|---|
| `onboarding_ordine` | l'animale per ultimo | l'animale subito dopo gli angeli, poi la carta di nascita |
| `trionfi_dopo_il_numero` | fra angeli e cielo non c'e' l'animale | fra angeli e cielo **c'e'** l'animale |
| `la_testa_non_si_vede_prima_della_quarta` | alla quarta l'area e' l'immagine intera | alla quarta l'area **e' la testa**, e il velo cade dopo |
| `il_velo_c_e_davvero_sul_telefono` | il metro della testa scoperta era la discesa 3 | il metro e' la discesa 4, piu' due misure nuove |
| `il_simbolo_si_compone` | Caligo guarda sempre il totem | l'ombra senza Viaggio, il totem dopo |
| `guide_animal_screen` e `il_responso_si_legge_ovunque` | aprivano la lettura da un diario vuoto | partono da un diario con le quattro discese |
