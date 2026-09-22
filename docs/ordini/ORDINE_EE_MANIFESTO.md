# ORDINE EE, I DONI DEL GIORNO, IL CONSIGLIO DEI MAESTRI, IL VIAGGIO DELLO SCIAMANO E I DATI SULL'ACCOUNT

**Sigla:** EE, riverificata sul ramo il 23 settembre 2026: in `docs/ordini`
non c'e' nessun `ORDINE_EE_*`, in `test/` nessuna `ordine_ee_guard`, e
**nessun documento del repo nomina un ordine EE** (ricerca su `docs/`,
`test/`, `lib/`, `tool/`: zero righe). **Data:** 23 settembre 2026. **Ramo:**
`claude/esoteric-circle-master-order-e798aj`. Parte dal commit `0ebaaec8`,
l'ordine ED chiuso e la build 2275 consegnata.

VOCI_TOTALI: 14
VOCI_CHIUSE: 13
VOCI_APERTE: 1

Il rapporto stara' in `docs/ordini/RAPPORTO_ORDINE_EE.md`.

---

## LO SCARTO DI QUESTO MANIFESTO, dichiarato per primo

**Questo manifesto e' stato scritto dopo il codice delle voci 11, 12 e 13, e
la casa vuole il contrario.** La ragione: la voce 13 chiedeva per prima cosa
di verificare **quale versione delle funzioni fosse distribuita**, e quella
verifica ha trovato il server fermo al 16 settembre con sette commit di
scarto. Distribuire e' stata la prima cosa utile da fare, e da li' il lavoro
e' proseguito sulla causa. **Non e' una scusa: e' lo scarto, e sta qui in
cima perche' si veda.**

---

## GLI SCARTI FRA L'ORDINE E IL RAMO

1. **`tools/collaudo_dei_maestri.dart`** e' `tool/`, al singolare, come gia'
   per l'ordine ED.
2. **La voce 13 chiede di verificare le distribuzioni: erano tutte da fare, e
   le ho fatte io.** Questa macchina e' autenticata come
   `cloud@esotericircle.app` e ha la CLI di Firebase: **dal PC del fondatore
   non serve niente**. Le funzioni sul server erano ferme al **16 settembre**
   (`updateTime 2026-09-16T15:27`) contro **sette commit** del ramo su
   `functions/src/` fatti dopo.
3. **`statoDelCerchio` era gia' distribuita** dal 16 settembre, quindi il
   PASSO 8 di `DISTRIBUZIONI_DAL_TUO_PC.md` non era in sospeso come l'ordine
   suppone. Quello che mancava era tutto il resto.
4. **La causa vera della voce 12 non era il catalogo dei luoghi: era una
   porta mai aperta.** La callable `cercaIlLuogoNelMondo` esiste nel codice
   dal **16 settembre** (commit `bda25b14`, ordine DR) e il suo `createTime`
   sul server e' **2026-09-22T01:33:55**, cioe' la distribuzione di
   stanotte. **Per sei giorni la ricerca nel mondo ha chiamato una funzione
   che non esisteva, fallendo in silenzio** (`il_mondo_intero.dart:71-84`
   inghiotte l'errore e torna un elenco vuoto). **Padre: ordine DR**, il cui
   stesso commit avvertiva *"Il server va distribuito perche' la porta si
   apra"*.
5. **Il Viaggio dello Sciamano non ha un modulo suo.** L'ordine parla di *"una
   finestra schermata"* che il Viaggio apre: e' **la stessa**
   `DatiDiNascitaScreen` del menu' utente (`art_navigation.dart:89-91`).
   Stesso widget, stessa rotta. Quindi il censimento della voce 11 non trova
   tre porte ma **due**, ed e' una guardia a imporlo
   (`dati_nascita_sbloccano_test.dart`, Anello 5).
6. **Il Viaggio dello Sciamano non aveva nessuna porta verso il Cerchio**:
   zero chiamate al server in tutto `diario_dei_viaggi.dart`. Non era un
   difetto di sincronizzazione, era un dato che non aveva mai lasciato il
   telefono.
7. **E un dato veniva perso in transito, non dimenticato.** Il telefono
   spedisce nove campi dell'identita', fra cui la **forma di cortesia**
   (`cammino_da_custodire.dart:228`) e lo **scarto UTC**
   (`:236`); `IdentitaCustodita` in `functions/src/cammino.ts` ne dichiarava
   **sette**, e gli altri due venivano scartati al primo parsing. Il ramo del
   telefono che riadotta la forma **non si e' mai acceso in vita sua**, e il
   codice e' commentato come se funzionasse. **Padre: ordine CF voce 07**,
   che ha aggiunto l'invio senza il campo dall'altra parte.

---

## IL CENSIMENTO DELLA VOCE 11, OGNI PUNTO CHE CHIEDE UN LUOGO

**Le porte in cui la persona SCRIVE un luogo sono due**, e una guardia lo
impone. Tutti gli altri punti che "chiedono un luogo" o mandano a una di
queste due, oppure leggono la posizione dal GPS senza nessun elenco da
scrivere.

| # | dove | file e riga del campo | quale ricerca usa |
|---|---|---|---|
| 1 | Risveglio, passo del luogo di nascita | `onboarding_screen.dart:1579` | `RicercaDelLuogo` piu' `RicercaNelMondo` |
| 2 | Menu' utente, dati di nascita, luogo di nascita | `dati_di_nascita_screen.dart:310` | la stessa |
| 3 | Menu' utente, dati di nascita, dove vivi adesso | `dati_di_nascita_screen.dart:370` | la stessa |
| 4 | **Viaggio dello Sciamano** | non ha un campo suo: apre la 2 e la 3 | la stessa |
| 5 | Angelo Custode, Oroscopo, Sinastria VIP, Calendario | mandano alla 2 | la stessa |
| 6 | Specchio dei dati, rivelazione della carta natale | `completa_il_luogo.dart:31` e `:53` | la stessa |
| 7 | Il cielo di adesso, dal GPS | `sky_location.dart:184` | nessun elenco: geocodifica inversa |
| 8 | Dove sono adesso | `luogo_attuale.dart:40` | nessun elenco |
| 9 | Panoramica del cielo | `sky_overview_screen.dart:396` | nessun elenco |
| 10 | Sinastria, distanza fra due luoghi | `mappa_della_distanza.dart:133` | catalogo in sola lettura |

**La ricerca e' una sola e a due gradini**, da CF voce 08: prima il catalogo
locale (`ricerca_del_luogo.dart:41`), e **solo se tace** la domanda al mondo
(`:91`), che passa da `il_mondo_intero.dart` alla callable
`cercaIlLuogoNelMondo` e da li' a OpenStreetMap.

**La fonte dei luoghi**: `assets/data/luoghi.csv`, **40.848 righe** di cui
due di intestazione, quindi **circa 40.846 luoghi**, generato da
`tool/genera_luoghi.py`. Piu' un **seme compilato di 65 citta'** in
`city_catalog.dart:282-743`, che vale finche' l'asset non e' letto. Piu' il
mondo intero via OpenStreetMap, per tutto il resto.

---

## PARTE PRIMA, I DONI DEL GIORNO

## VOCE EE.01, ARCANO DELL'ALBA: IL MISCHIA

Al tocco di "Mischia" le carte si ricompongono in un mazzo, il mazzo si
mescola a vista e poi le carte si stendono di nuovo a ventaglio su tre righe.
La disposizione resta quella di adesso, e resta valida ogni regola gia'
decisa per l'Arcano dell'Alba, a partire dal verso deciso dal sistema e
invisibile prima del flip.

### Fatto

**Il gesto era un'onda sul ventaglio, non un mazzo.** Ogni carta girava
attorno al **proprio** posto e ci tornava: nessun mazzo si componeva. **Padre:
PROVENIENZA IGNOTA**, il gesto nasce cosi' col file.

**Adesso ha tre tempi**, letti dal solo valore dell'animazione: fino a 0,35 le
carte si radunano nel mazzo al centro e si raddrizzano; da 0,35 a 0,65 il
mazzo si mescola restando dov'e'; da 0,65 in poi si stendono verso il posto
**nuovo**, che la griglia a tre righe ha gia' assegnato.

**E i posti cambiano a mazzo chiuso, non a corsa finita.** Prima si
mescolavano alla fine, quindi per tutta l'animazione le carte puntavano al
posto vecchio: anche con una raccolta al centro, la stesa le avrebbe
riportate dov'erano. La durata sale da 1100 a 1800 millesimi, perche' tre
tempi in 1100 sono uno strappo.

Guardia `il_mischia_ricompone_il_mazzo`, **nata rossa sul difetto vero**, cioe'
rimettendo la mescolata a corsa finita. **La prova vera la fa il fondatore a
video: la guardia guarda il sorgente e lo dichiara**, perche' ventidue dorsi
uguali rasterizzati direbbero dove sono le macchie scure, non quale carta sia
quale. **CHIUSA.**


## VOCE EE.02, SOFFIO DEL DESTINO: RESPIRA IL SOFFIONE, E TUTTO SALE

Il cerchio d'oro sovrapposto sparisce: a seguire il respiro, allargandosi e
stringendosi, e' **il soffione stesso**. Il soffione e il riquadro "Preparati
a respirare" salgono, e lo spazio liberato va alla bolla descrittiva sotto,
che diventa piu' alta.

Il fondatore aveva gia' chiesto di togliere quel cerchio: **va cercato
sul ramo l'ordine che lo chiedeva e dichiarato perche' il cerchio e' ancora
li'**, col padre secondo la regola C.

### Fatto

**Il cerchio d'oro non c'e' piu': a respirare e' il soffione.** Il Soffio non
passava nessuna figura alla guida, quindi la guida disegnava il suo cerchio di
ripiego. Adesso la figura e' vuota e la misura del respiro esce da un canale
suo, che la scena legge per scalare la testa del soffione attorno al proprio
centro.

**L'ordine chiedeva di dire perche' il cerchio fosse ancora li'. La risposta
e' che quella richiesta non e' mai entrata in un ordine scritto**: cercata su
tutti i manifesti e su `docs/`, non esiste. **Padre: nessuno**, e questa
dicitura e' essa stessa un'informazione, cioe' che una parola del fondatore si
e' persa fra la chat e l'ordine.

**IL SOFFIONE ERA MOLTO PIU' PICCOLO DEL CERCHIO CHE SOSTITUISCE**, e
toglierlo e basta avrebbe peggiorato cio' che l'ordine DD voce 03 aveva
curato: **36,4 per cento della larghezza contro il settanta preteso**. Il
soffione e' salito dal 62 all'86 per cento dell'altezza (50,8 per cento) e la
corsa del respiro si e' aperta da 0,80 a 1,40: **al culmine prende il 71,0 per
cento**, e va da 172 a 277 punti su 390.

**E il soffione e' salito**, dal 52 al 46 per cento dell'altezza: i sei punti
percentuali vanno alla bolla descrittiva sotto, che era la parte piu' stretta
della schermata.

**Tre guardie di DD voce 03 misuravano il cerchio.** Messo davanti al
conflitto fra i due ordini, il fondatore ha deciso di **riscrivere la misura
sul soggetto nuovo** invece di spegnerla: nasce `il_soffione_respira`, che
dipinge il pittore vero e misura i pixel, e due prove hanno preso una lapide
che dice dov'e' andata la misura. **CHIUSA.**


## VOCE EE.03, RUNA DEL TRAMONTO: SETTE SERE DI FILA

Prima di cambiare qualunque cosa va dichiarato **col file e la riga** come la
striscia ricorda oggi le sere precedenti, cosa accade se si salta una sera,
quando e come nasce oggi il riassunto e dove finisce.

La regola diventa: il riassunto arriva **solo dopo sette Rune del Tramonto in
sette sere consecutive**, e una sera saltata fa ripartire la striscia dalla
prima. **L'utente lo capisce dalla schermata**: la frase la scrivo io, nel
tono di Caligo, e la giudica il fondatore sulla build. Alla settima sera il
riassunto entra da solo nel Cosmic Journal **come evento speciale**, distinto
dalle voci normali.

### Fatto

**Come funzionava, dichiarato prima di cambiarlo.** Non era nessuna delle due
ipotesi del fondatore: era una **finestra mobile su sette giorni di
calendario** (`sunset_rune_memory.dart`), in cui i giorni saltati **non
consumavano posto**. Chi faceva la runa il primo, il terzo e il quinto giorno
si trovava *"terza sera su sette"* senza che niente glielo spiegasse. **Padre:
PROVENIENZA IGNOTA**, la finestra nasce col file.

**Adesso e' una serie**: si risale un giorno per volta finche' le sere si
toccano, e alla prima mancante ci si ferma. Misurato: **col salto del settimo
giorno la striscia passa da sei sere a una**.

**La schermata lo dice**, e la frase la scrivo io nel tono di Caligo: *"La
prima di sette sere di fila. Salti una sera e il filo si spezza: si riparte da
qui."* **Il tono lo giudica il fondatore sulla build.**

**Alla settima sera il riassunto entra da solo nel Cosmic Journal come evento
speciale.** Nasce `ComeENato.evento`, il terzo modo in cui un Ricordo nasce,
distinto dal gesto e dalla condivisione: chi rilegge il diario deve poter
sapere che quella voce non l'ha messa lui. La frase del riassunto vive in un
punto solo, che il sigillo a schermo e il Ricordo leggono in due.

Guardia `sette_sere_di_fila`, **nata rossa rimettendo la finestra mobile**.
**CHIUSA.**


## VOCE EE.04, SIGILLO DEL SOGNO: UN TESTO GIUSTO E NON GENERICO

Va dichiarato come nasce il testo del riquadro, col file e la riga, e
verificato che **ogni fatto che afferma sia vero per quella persona e quella
notte**: fase e segno della Luna, aspetto con la Luna natale, richiamo alla
carta del giorno. **Ogni frase che vale uguale per chiunque** va sostituita
con cio' che i dati dicono davvero. Titolo e parte iniziale restano.

### Fatto

**Come nasce il testo**: `DreamRiteCorpus.saluto`, che compone l'apertura del
Maestro di turno, la fase e il segno reali della Luna, l'immagine del segno,
due frasi sulla giornata e la riga dell'angolo con la Luna natale.

**Cosa era vero e cosa no.** La fase e il segno erano **veri**, l'angolo con
la Luna natale era **vero**, il richiamo alla carta dell'alba c'era. **Erano
false le due frasi che parlano della sua giornata**: *"Oggi hai pensato in
largo, per tutti"* e *"hai tenuto uno sguardo libero"* venivano dal segno
della Luna **di stanotte**, che stanotte e' lo stesso per chiunque apra
l'app. **Il rito diceva a tutti gli utenti che avevano passato la stessa
giornata.**

**La cura non aggiunge un dato: usa quello che c'era e nessuno leggeva**, la
Luna di nascita, che e' il segno sotto cui quella persona guarda il proprio
giorno. L'immagine e la posa restano della Luna di stanotte, perche' parlano
della notte e non di lei.

**Misurato**: nella stessa notte, dieci nascite in segni lunari diversi
ricevevano **sei** saluti uguali fra loro; adesso ne ricevono **dieci
diversi**. Chi non ha dato la nascita ha esattamente il saluto di prima.

**Padre: PROVENIENZA IGNOTA**: il saluto nasce sulla sola Luna di stanotte, e
l'ordine CE voce 13, che ha aggiunto la nascita, l'ha usata per il solo
angolo. **CHIUSA.**


## VOCE EE.05, SIGILLO DEL SOGNO: IL SALUTO NON RIPETE IL TITOLO

Il titolo grande e' *"Lascia andare il pensiero, la notte non chiede visione,
chiede riposo."* e il testo sotto lo ripete parola per parola. Il saluto non
ripete il titolo, ne' per intero ne' quasi.

### Fatto

**Il titolo E' la frase che il saluto ripeteva.** L'ordine CO voce 17 ha
promosso la `posa` a titolo della schermata, *"perche' la gerarchia vuole al
primo posto un titolo diretto che sia gia' una risposta"*, e il suo stesso
commento dichiara che *"il saluto per intero non cambia di una virgola"*: era
vero, ed e' precisamente il difetto. **Padre: ordine CO voce 17**, che ha
aggiunto il titolo senza togliere la coda.

Adesso la posa sta dove CO l'ha messa, nel titolo, e il saluto chiude sul
riconoscimento. Guardia `il_saluto_della_notte_non_ripete_il_titolo`, che
misura **tutti e dodici i segni** e non il solo Acquario della cattura, **nata
rossa rimettendo la posa in fondo**. **CHIUSA.**


## VOCE EE.06, SIGILLO DEL SOGNO: VIA L'ETICHETTA "RESPIRO"

Sopra il titolo si legge *"Respiro · Il saluto di Medora"*. **"Respiro" e'
parola di firma di Aura** (`voce_del_maestro.dart:350`) e il Sigillo del
Sogno e' di **Medora** (`daily_elements.dart:10`). Quella parola viene dal
corpus delle dodici parole della notte, una per segno lunare:
`dream_rite_corpus.dart:145`, il segno **Acquario**. Va verificato che
nessun altro testo fisso del rito porti parole di firma di Aura o di Caligo,
con l'esito nel rapporto.

### Fatto

**Non era un'etichetta scritta a mano: era la parola della notte
dell'Acquario**, una delle dodici del corpus, che il rito mostra sopra il
titolo.

**Il censimento ha trovato tre violazioni su cinquantacinque campi, non una**:
*Radice* per il Toro e *Respiro* per l'Acquario, parole di firma di Aura, piu'
*"hai fatto sentire qualcuno a casa"* per il Cancro, dove *sentire* e' di Aura
pure lui. Sono diventate **Terra**, **Spazio** e *"hai dato a qualcuno un
posto dove stare"*. **Il tono di queste tre lo giudica il fondatore.**

**Padre: PROVENIENZA IGNOTA.** Il divieto incrociato dell'ordine BP voce 1
vive nell'istruzione che va al modello, e **i testi fissi non passano di li'**.

Guardia `il_sigillo_del_sogno_parla_con_la_voce_di_medora`, che misura i
sessanta campi del corpus **col metro della casa**, `LaVoceNonSiConfonde`, lo
stesso che sorveglia le risposte di Gemini. **Nata rossa rimettendo Respiro
all'Acquario**: zero violazioni su sessanta campi. **CHIUSA.**


---

## IL COLLAUDO DEI MAESTRI, E COSA NON E' STATO RILANCIATO

Le voci 07 e 10 chiedono di rilanciare `tool/collaudo_dei_maestri.dart`, che
dall'ordine ED manda le sedici mosse del catalogo a tutti e tre i Maestri.

**Non e' stato rilanciato, e si dichiara.** La voce 07 e' stata curata nel
codice e provata senza rete su sei casi presi dalle risposte vere del giro
dell'ordine ED; la voce 10 ha la sua prima meta' provata allo stesso modo.
**Quello che manca e' il collaudo del CONSIGLIO**, che oggi il collaudo non
prova: prova le chat. Estenderlo e' il lavoro che la seconda meta' della voce
10 richiede, ed e' il motivo per cui quella voce resta aperta.

---

## PARTE SECONDA, LA CHAT E IL CONSIGLIO DEI MAESTRI

## VOCE EE.07, IL CHIARIMENTO NON COSTA

Un turno in cui il Maestro **chiede** un chiarimento o i dati che gli mancano
**non fa scendere nessun contatore**: ne' le domande, ne' gli approfondimenti,
ne' i confronti, ne' gli Eos. Il contatore scende solo sul turno in cui il
Maestro risponde nel merito.

**Lo scarto con l'ordine EB e' dichiarato**: `ORDINE_EB_MANIFESTO.md` voce
EB.06 dice *"Una domanda del Maestro e' una risposta vera, quindi consuma"*,
e il catalogo segna `consuma: si'` per la mossa 8. **Padre: EB voce 06.** Il
catalogo delle mosse si aggiorna qui, e il collaudo si rilancia sui tre
Maestri con le trascrizioni in `docs/collaudo/EE/`.

### Fatto

Nasce `EsitoDelTurno.chiarimentoChiesto`, che **non consuma niente**: ne' le
domande, ne' gli approfondimenti, ne' i confronti, ne' gli Eos. La regola vive
dove viveva, in `CostoDelTurno`, che e' un punto solo.

**IL CANCELLO E' LARGO APPOSTA**, e la ragione sta in cosa costa sbagliare:
non riconoscere un chiarimento fa pagare una risposta mai ricevuta, cioe' il
difetto che questa voce cura; riconoscerne uno che non c'era regala una
risposta. **In dubbio non si paga.**

**Il punto interrogativo, che l'ordine EC aveva scartato, qui basta.** Li'
serviva a **giudicare** se il Maestro avesse chiesto, cioe' a far cadere un
collaudo, e per quello ci voleva il modello. Qui serve solo a decidere **se
far pagare**, con l'asimmetria qui sopra: uno strumento che sbaglia verso il
gratis va bene, e un giudice a ogni turno costerebbe piu' della domanda che
risparmia.

**Lo scarto con EB voce 06 e' dichiarato** nel codice, nella guardia e qui.
**Padre: EB voce 06.** Guardia `il_chiarimento_non_costa`, **nata rossa
facendo costare il chiarimento**, con sei casi presi dalle risposte vere del
collaudo dell'ordine ED. **CHIUSA.**


## VOCE EE.08, IL CONFRONTO COMPRATO CON GLI EOS

Un confronto comprato con gli Eos **compare subito nel contatore** come
disponibile, e una volta aperto mostra **tutti e tre i Maestri** piu' la
sintesi. Va dichiarato col file e la riga cosa e' stato comprato con quei 150
Eos, cosa e' stato consegnato, e cosa accade oggi a chi paga e riceve meno.

### Fatto

**LA CAUSA ERA UNA RIGA.** Il Consiglio chiedeva a `canCompare`, che guarda
**il piano**: sul piano senza confronti la risposta e' no, e **le altre due
letture non venivano nemmeno chieste**. Ma chi compra un confronto con gli Eos
**non cambia piano**: il riscatto porta il contatore sotto zero, e il credito
vive nei **rimasti**.

**Misurato**: col credito comprato, `canCompare` risponde **false** e
`puoiConfrontare` risponde **true**. Ecco perche' il fondatore ha visto la sola
Medora, e perche' sottoscrivendo l'abbonamento tutto e' tornato a posto: con
l'abbonamento il piano dice di si' da se'.

**Padre: ordine BG voce 05.** Quella voce ha scritto la regola giusta, *"il
cancello guarda i rimasti, non il piano, cosi' il credito riscattato con gli
Eos si spende davvero"*, e l'ha applicata agli approfondimenti e alle stese:
**la porta del confronto e' rimasta fuori**.

Guardia `il_confronto_comprato_si_riceve`, **nata rossa rimettendo
`canCompare`**. **Cosa resta da guardare a video**: che il contatore mostri il
credito appena comprato, che si vede solo comprando davvero. **CHIUSA.**


## VOCE EE.09, LA SINTESI CHE NON CONOSCE IL NOME

La sintesi comparativa comincia con *"Caro, non conosco il tuo nome, ma se
vuoi puoi dirmelo."* mentre nella stessa schermata Aura e Caligo chiamano il
fondatore per nome. La sintesi riceve i dati della persona come li ricevono i
Maestri, e non dice mai di non conoscere un nome che l'app conosce.

### Fatto

**La sintesi era l'unica chiamata della catena a non ricevere il profilo.**
`synthesisInstruction` prendeva la sola forma di cortesia e si costruiva un
`UserProfile` **vuoto**: un profilo senza nome fa scrivere al blocco di
cortesia *"Non conosci ancora il nome della persona. Puoi chiederglielo"*, e
il modello ha obbedito. I Maestri il profilo ce l'hanno, perche' `reply` lo
riceve.

Adesso il profilo viaggia da `AskMaestriScreen` fino all'istruzione, per
tutta la catena: firma, voce sorvegliata, provider. **Padre: PROVENIENZA
IGNOTA**, `synthesize` nasce senza profilo e nessun ordine ha messo a
confronto la sua firma con quella di `reply`.

Guardia `la_sintesi_conosce_il_tuo_nome`, **nata rossa rimettendo il profilo
vuoto**, e con la meta' che tiene aperta la porta: chi non ha dato il nome
deve poterlo ancora sentire chiedere. **CHIUSA.**


## VOCE EE.10, TESTI CORRETTI E COERENTI NEL CONSIGLIO

Due difetti gia' visti:

1. Caligo scrive *"la Tre di Denari"* e *"La Tre di Coppe"*: il genere giusto
   e' **"il Tre di Denari"**, e la regola vale per tutti i numeri e per tutti
   e tre i Maestri.
2. La sintesi comparativa **ripete** le tre risposte con frasi valide per
   chiunque (*"La Ruota della Fortuna, per tutti, segna un ciclo che si
   rinnova"*) invece di **confrontare** i tre sguardi: dove concordano, dove
   divergono e perche'.

Il collaudo si estende al Consiglio e alla sintesi su almeno una stesa vera.

### Fatto

**IL GENERE DELLE CARTE, prima meta'.** L'app il genere lo sa dove scrive lei,
`ReversedAgreement`, ma i nomi dentro le letture li scrive il modello, e a lui
non arrivava niente: *carta* e' femminile, *tre* no, e la concordanza la decide
il numero che fa da nome. La regola nasce in un punto solo,
`LaLinguaDelModello.ilGenereDelleCarte`, e arriva ai tre Maestri **e alla
sintesi comparativa**. Dice anche il femminile delle figure, o si scriverebbe
*"il Regina di Coppe"*. **Padre: PROVENIENZA IGNOTA**, la regola non e' mai
esistita.

Guardia `il_genere_delle_carte_arriva_ai_maestri`, **nata rossa togliendo la
regola**: tre Maestri su tre senza. La guardia misura che la regola **arrivi**,
non che il modello la rispetti: quello si misura col collaudo, ed e' scritto
nel rapporto.

**LA SINTESI CHE RIPETE INVECE DI CONFRONTARE, seconda meta': NON FATTA.**
L'istruzione della sintesi gia' chiede di *"mettere a confronto le loro prese
di posizione, dove convergono e dove divergono, senza ripetere per intero ogni
lettura"*, e il modello non la rispetta. **E' lo stesso quadro dell'ordine EC
voce 03**: una regola che c'e' e non ha morso, e quell'ordine ha insegnato che
rafforzarla non serve e che serve una misura prima e dopo. **Quella misura
vuole un giro di collaudo sul Consiglio con una stesa vera, e non e' stata
fatta.** Si dichiara invece di darla per chiusa.

**La prima meta' e' fatta e provata. La seconda no, e questa voce resta
APERTA invece di dichiararsi chiusa a meta': una voce mezza chiusa e' una
voce aperta con una parola gentile davanti.**

**APERTA.**


---

## PARTE TERZA, IL VIAGGIO DELLO SCIAMANO E I DATI SULL'ACCOUNT

## VOCE EE.11, IL LUOGO NEL MODULO DEL VIAGGIO DELLO SCIAMANO

Nel modulo che il Viaggio apre quando mancano i dati, la ricerca del luogo
funziona come nel menu' utente. Il censimento per intero sta qui sopra.

### Fatto

**La causa era una riga, e il censimento intero sta qui sopra.** Il Viaggio
dello Sciamano non ha un modulo suo: apre **la stessa** `DatiDiNascitaScreen`
del menu' utente, e la apre **se e solo se** l'identita' e' d'esempio. In
quella schermata `CityCatalog.ensureLoaded()` stava **dopo** il `return` sui
dati d'esempio, quindi il catalogo non si caricava **esattamente e soltanto
nel caso in cui la schermata serviva a raccogliere i dati**: restavano le
sessantacinque citta' del seme compilato invece delle circa 40.846 dell'asset.
Dal menu' utente il `return` non scatta, e infatti funzionava. **Padre:
PROVENIENZA IGNOTA.**

**E si rifa' la ricerca quando l'asset arriva**, come fa il Risveglio: le
lettere battute nei primi decimi di secondo cadevano sul seme senza che
nessuno le ripetesse.

**Riparata anche l'altra meta' del fatto, il *"forzando l'invio non
funziona"*.** Il tasto Salva si accendeva con la sola data, e chi non aveva un
luogo di prima usciva col luogo a `null` **senza che niente glielo dicesse**.
Adesso il tasto pretende il luogo, e **chi corregge non e' toccato**: se un
luogo c'e' gia', si puo' correggere la sola ora come prima.

**Le due guardie che coprivano la zona sono state viste VERDI col catalogo
spento**: non coprivano, ed e' il caso che la Regola B prevede. Nasce
`il_catalogo_si_carica_anche_a_mani_vuote`, **nata rossa** rimettendo
l'ordine vecchio delle righe. **CHIUSA.**


## VOCE EE.12, TUTTI I LUOGHI DEL MONDO

La ricerca trova ogni citta', paese e villaggio del mondo, e **"Borgo di
Rivalta" si puo' scegliere**. Va dichiarato perche' mancava, col padre, quale
fonte si usa dopo il lavoro e quanti luoghi contiene.

### Fatto

**LA PORTA VERSO IL MONDO NON ERA MAI STATA APERTA.** La callable
`cercaIlLuogoNelMondo` esiste nel codice dal **16 settembre** (commit
`bda25b14`, ordine DR) e il suo `createTime` sul server e'
**2026-09-22T01:33:55**, cioe' la distribuzione fatta durante quest'ordine.
**Per sei giorni la ricerca nel mondo ha chiamato una funzione che non
esisteva, fallendo in silenzio**: `il_mondo_intero.dart` inghiotte l'errore e
torna un elenco vuoto, che e' l'unico catch muto autorizzato del progetto.

**Padre: ordine DR**, il cui stesso commit avvertiva *"Il server va
distribuito perche' la porta si apra; finche' non lo e', l'app fa come
prima"*.

**Perche' Borgo di Rivalta mancava**: non e' nel catalogo offline e non puo'
esserci. `assets/data/luoghi.csv` ha **40.848 righe**, due di intestazione,
quindi **circa 40.846 luoghi**, e contiene *Rivalta di Torino* e *Rivalta
Bormida*, non *Borgo di Rivalta*. Si trova **solo** passando da OpenStreetMap,
cioe' da quella callable.

**La fonte dei luoghi dopo il lavoro**: il catalogo di circa 40.846 luoghi per
primo, e per tutto il resto il mondo intero via OpenStreetMap, adesso
raggiungibile. **Cosa resta da guardare a video**: che scrivendo *Borgo di
Rivalta* il suggerimento compaia, che dipende anche dalla rete del telefono.
**CHIUSA.**


## VOCE EE.13, I DATI DELLA PERSONA VIVONO SUL SUO ACCOUNT

Dati di nascita, progressi, traguardi e Viaggio dello Sciamano concluso
sopravvivono all'aggiornamento, al cambio di telefono e al login altrove.
Per ciascun tipo di dato va dichiarato dove viene salvato oggi, col file e la
riga, e dove dopo il lavoro.

### Fatto

**LE DISTRIBUZIONI ERANO TUTTE DA FARE, E LE HO FATTE IO.** Questa macchina e'
autenticata come `cloud@esotericircle.app` e ha la CLI di Firebase: **dal PC
del fondatore non serve niente**. Le funzioni erano ferme al **16 settembre**
contro **sette commit** del ramo su `functions/src/`; funzioni e hosting
distribuiti, verificato sul server col loro `updateTime`.

**IL VIAGGIO DELLO SCIAMANO NON AVEVA NESSUNA PORTA VERSO IL CERCHIO**: otto
chiavi di `SharedPreferences` e **zero chiamate al server** in tutto
`diario_dei_viaggi.dart`. Non era un difetto di sincronizzazione: era un dato
che non aveva mai lasciato il telefono, e che il diario stesso dichiara
costare **quattro giorni**. Adesso viaggia nel cammino custodito come
sacchetto opaco, col criterio di fusione suo: **chi ha riconosciuto batte chi
no, e a parita' vince chi ha piu' discese**. **Padre: PROVENIENZA IGNOTA.**

**E UN DATO VENIVA PERSO IN TRANSITO, non dimenticato.** Il telefono spedisce
nove campi dell'identita', fra cui la **forma di cortesia** e lo **scarto
UTC**; `IdentitaCustodita` ne dichiarava **sette**, e gli altri due venivano
scartati al primo parsing. **Il ramo del telefono che riadotta la forma non si
e' mai acceso in vita sua**, e il codice e' commentato come se funzionasse.
**Padre: ordine CF voce 07.**

**Dove vive ogni dato, prima e dopo:**

| dato | prima | dopo |
|---|---|---|
| data, ora, luogo di nascita | server, gia' custoditi | invariato |
| forma di cortesia e scarto UTC | spediti e **scartati dal server** | custoditi |
| progressi, traguardi, Sigilli | server, fusione non distruttiva | invariato |
| Arcano dell'Alba | server | invariato |
| **Viaggio dello Sciamano** | **solo telefono** | **custodito** |
| Eos e contatori | server | invariato |
| luogo dove si vive | solo telefono | **resta sul telefono, dichiarato** |

**Cosa resta fuori, e si dichiara**: il **luogo dove si vive** vive ancora
nelle sole preferenze. Non e' nell'elenco dei dati che l'ordine nomina, e
aggiungerlo avrebbe voluto dire toccare l'identita' custodita una seconda
volta nello stesso ordine.

**Prove del server: 115 verdi.** Due guardie nuove lato telefono, **tutte e
due nate rosse**. **Cosa resta da guardare a video**: che il Viaggio concluso
ricompaia dopo un aggiornamento, che si vede solo aggiornando l'app. **CHIUSA.**


## VOCE EE.14, "SCENDI" SOLO DOPO UNA SCELTA

Nel Viaggio dello Sciamano il pulsante "Scendi" e' attivo soltanto quando
l'utente ha scelto o scritto una domanda, oppure ha scelto "Solo incontro".

### Fatto

**Il difetto stava in `perche == null`, e non era una svista.** Quel `perche`
e' il motivo per cui la domanda scritta **non va bene**, e a mani vuote non
c'e' nessun motivo: quindi era nullo e il pulsante si accendeva. **Lo faceva
per decisione**, ordini DC voce 05 e DQ voce 03: *"la domanda e' facoltativa
alla prima discesa di un cammino"*. **Padre dello scarto: ordine DC voce 05**,
ripreso da DQ voce 03; la parola del fondatore e' del 23 settembre e prevale.

**La porta per chi non vuole chiedere resta**, ed e' "Solo incontro":
scegliere di non chiedere e' una scelta, non toccare niente non lo e'.

Guardia `si_scende_dopo_una_scelta`, che monta la schermata vera e misura il
pulsante a mani vuote e col solo incontro, **nata rossa rimettendo `perche ==
null`**. **CHIUSA.**

