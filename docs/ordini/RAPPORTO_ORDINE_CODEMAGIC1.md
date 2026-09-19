# RAPPORTO DELL'ORDINE CODEMAGIC1

**La build arriva sugli iPhone, e un rifiuto da Codemagic non deve piu'
accadere.** 16 settembre 2026, ramo
`claude/esoteric-circle-master-order-e798aj`. Parte dal commit `bc81dcde`,
quello su cui la build 2264 e' caduta al passo dodici.

---

## 1. CHE COSA HA FERMATO LA BUILD, LETTO NEL REGISTRO

Il fondatore ha mandato il registro del passo dodici, 1.521.031 byte. Non e'
una ricostruzione: sono le righe.

| dove | cosa dice |
|---|---:|
| riga 705 | `corredo_anteprime_test.dart: Nessuna cattura ha un rapporto di pixel implicito [E]` |
| riga 11.657 | la suite intera chiude a **5.287 prove, 6 saltate, 3 cadute** |
| righe 11.663-11.665 | *"LE PROVE DEL SERVER NON SONO STATE ESEGUITE: manca functions/node_modules"* |
| righe 11.954-13.593 | il corredo a scala 1,3: **quindici catture cadute**, da `Cattura il dono col colore del Maestro, giorno 0` a `Cattura la chat con la barra fuori` |
| riga 13.679 | *"IL CORREDO A SCALA MASSIMA HA MONTATO 182 SCHERMATE"* |
| righe 13.710-13.712 | **ROSSI NUOVI, NON ACCETTATI DA NESSUNO: una riga sola**, e *"L'ARCHIVIO NON SI PRODUCE"* |

**Delle tre prove cadute nella suite intera, due erano gia' accettate dal
fondatore**: l'attribuzione cieca e le soglie delle quattro pose. **La terza
era nuova, ed era mia.**

**E le quindici del corredo a scala 1,3 sono tutte accettate**: i quindici
nomi del registro coincidono uno per uno con le quindici righe `SCALA 1,3:`
di `tool/rossi_accettati.txt`. Il cancello ha fatto esattamente il suo
mestiere: ha lasciato passare cio' che il fondatore aveva accettato e si e'
fermato sulla riga che nessuno aveva mai visto.

---

## 2. LA RIGA CHE HA FERMATO TUTTO, E COME L'HO CHIUSA

**Che cosa era.** `test/anteprima_card_della_rivelazione_test.dart`, scritto
da me nell'ordine DQ voce 14 per far vedere al fondatore la card della
rivelazione, dichiarava `tester.view.devicePixelRatio = 2.0` e scriveva un
PNG. La regola di casa sta in `test/corredo_anteprime_test.dart` riga 28,
`rapportoDichiarato = 3.0`, e vale **per chiunque scriva un'immagine che
qualcuno guardera'**: un'anteprima a rapporto due, messa accanto alle altre,
e' visibilmente meno nitida.

**Come l'ho chiusa.** Rapporto tre, e schermo allargato di conseguenza da 760
per 1200 a 1140 per 1800 pixel, perche' la stessa scatola di punti logici a
rapporto tre vuole piu' pixel veri. L'immagine e' stata rigenerata: adesso e'
**960 per 1304 pixel** invece di 640 per 869.

**Cosa NON ho fatto, ed e' la parte che conta**: nessuna soglia abbassata,
nessuna eccezione aggiunta alla tavola `eccezioniDelRapporto`, nessuna riga
scritta in `tool/rossi_accettati.txt`. La guardia e' rimasta esattamente come
era: si e' spostato il testo che la violava.

---

## 3. PERCHE' QUEL ROSSO E' ARRIVATO FINO AL MAC MINI

**E' la domanda vera, e la risposta non e' tecnica.**

Lo sbarramento locale, sullo stesso albero, era stato girato e aveva scritto
il suo gettone: *"GETTONE SCRITTO: numero 2264, 5288 prove"*. Ma quel giro e'
finito **prima** che l'anteprima della card esistesse: il file e' nato dopo,
nel commit `bc81dcde`, insieme al rapporto dell'ordine DQ, ed e' stato spinto
**senza rigirare il cancello**.

**La regola di casa esisteva gia'**, si chiama *"suite intera prima di
spingere"* e sta scritta fra le lezioni del progetto. L'ho violata io, alle
cinque del mattino, alla fine di una notte di lavoro.

### E QUI C'E' IL FATTO CHE NON AVEVO VISTO, ED E' PIU' GRAVE DI TUTTO IL RESTO

**Avevo scritto, in questo stesso rapporto e nel manifesto, che nessun
automatismo avrebbe fermato quella spinta. Era falso, e l'ho scoperto solo
dopo aver spinto il lavoro di quest'ordine**, leggendo il registro delle
azioni di GitHub, che e' pubblico e si interroga senza credenziali.

Il cancello gratuito **era gia' rosso** sul commit `bc81dcde`. Il giro
`35052608849` e' partito alle 03:39 UTC del 16 settembre, ha girato diciotto
minuti, ed e' caduto al passo *Test*. **Tre ore prima che Codemagic cadesse.**

E non e' un caso isolato. Sui **1.055 giri** che il registro conserva:

| misura | numero |
|---|---:|
| giri conservati di `verde.yml` | 1.055 |
| finiti verdi | 130 |
| finiti rossi | 924 |
| **l'ultimo verde** | **29 luglio 2026, commit `74625665`** |
| **giri rossi consecutivi da allora** | **920** |
| **giorni di rosso ininterrotto** | **48** |

**Un cancello rosso da quarantotto giorni non e' un cancello: e' una spia
guasta.** Nessuno guarda una spunta che e' rossa comunque, e chi la guardasse
non saprebbe distinguere il rosso di sempre da un rosso nuovo. Questa e' la
ragione vera per cui il rosso dell'anteprima e' arrivato fino al mac mini, e
non e' la mia dimenticanza delle cinque del mattino: **la mia dimenticanza e'
stata l'ultimo anello, non il primo.**

**Perche' era rosso comunque, ed e' il punto che chiude la voce 02**:
`flutter test` nudo **non conosce il registro dei rossi accettati**. I due
rossi che il fondatore ha acceso e voluto, l'attribuzione cieca dal 13 agosto
e le soglie delle quattro pose dal 6 settembre, lo facevano cadere a ogni
singola spinta. Un cancello che non sa distinguere un rosso voluto da un rosso
nuovo **non puo' essere verde nemmeno quando tutto e' a posto**, e quindi non
puo' dire niente a nessuno.

**Dello scivolamento di fine luglio non so dire il padre.** L'ultimo verde e'
del 29 luglio e il primo rosso del 30, sul commit `6fea3d43`, ma i registri
dei giri di GitHub vogliono un'autenticazione che da qui non ho, e i due rossi
accettati sono nati dopo. **PROVENIENZA IGNOTA**, per la regola C, e la
dicitura dice esattamente la cosa che va detta: quel rosso e' entrato senza
lasciare traccia leggibile, ed e' rimasto acceso per quarantotto giorni senza
che nessuno se ne accorgesse.

**Per questo il secondo risultato dell'ordine non si ottiene ricordandosi di
girare il cancello**, e nemmeno rendendolo piu' severo: si ottiene rendendolo
**capace di tornare verde**. Lo sbarramento conosce i rossi accettati, li
lascia passare e si ferma solo su un rosso nuovo. E' la prima volta da fine
luglio che quella spunta puo' voler dire qualcosa.

---

## 4. LA STRADA SCELTA, E PERCHE' REGGE

**Il cancello gratuito diventa lo stesso cancello a pagamento.**

`.github/workflows/verde.yml` gira a ogni push sul ramo, su macchina GitHub,
e finora eseguiva `flutter test`. Adesso esegue **`bash tool/sbarramento.sh`**,
che e' parola per parola il comando del passo dodici di `codemagic.yaml`.

**Perche' regge, e la ragione e' una sola**: prima le due macchine facevano
**due domande diverse**. `flutter test` non fa girare le prove del server, non
fa il corredo a scala 1,3 e non guarda il registro dei rossi accettati; lo
sbarramento fa tutte e tre le cose e in piu' distingue un rosso accettato da
un rosso nuovo. **Un cancello a valle piu' severo di quello a monte e' un
cancello che scopre i guasti dove si paga.** Adesso la domanda e' la stessa:
perche' Codemagic cada su una prova rossa, quella prova deve essere rossa
prima su GitHub, dove costa zero e si vede in minuti.

**E una guardia lo tiene fermo nel tempo**:
`test/ordine_codemagic1_guard_test.dart` pretende che **tutti e due i file
contengano lo stesso comando** e che `verde.yml` non torni a eseguire
`flutter test` come passo a se'. Se qualcuno li fa divergere di nuovo, cade
una prova, non una build.

**Le cause che non sono le prove, e qui l'ordine chiede onesta'.** Questa
strada non copre: la firma e i profili, i pod, lo spazio sul disco della
macchina, la versione di Xcode, e la validazione dell'archivio da parte di
Apple. **Nessuna macchina Linux gratuita costruisce un archivio iOS firmato**,
quindi su quelle cause un cancello gratuito non puo' dire niente. Cio' che si
puo' dire e' che nel registro della 2264 quelle undici fasi erano **tutte
verdi**, e sono costate in tutto meno di tre minuti: `Preparing build machine`
19 secondi, `Fetching app sources` 43, `Installing SDKs` 48, i pod 15, il
portachiavi meno di un secondo, certificato e profili 3 e 3. **La famiglia di
cadute che questa strada toglie e' quella che e' costata i ventinove minuti.**

---

## 5. LA SECONDA SUITE, CHE NON AVEVA MAI GIRATO

Il registro dice che le prove del server non sono state eseguite perche'
mancava `functions/node_modules`. **Non era un caso di quella build**: in
`codemagic.yaml` non c'era **nessun comando npm**, quindi quella cartella su
quella macchina non e' mai esistita, e la seconda suite non e' mai stata
guardata in nessuna build. Lo sbarramento lo diceva a voce alta e andava
avanti, che e' il comportamento giusto per un cancello che non vuole mentire.

**Adesso tutte e due le macchine installano le dipendenze con `npm ci`**, che
installa esattamente cio' che `functions/package-lock.json` dichiara: due
macchine che installassero versioni diverse sarebbero di nuovo due cancelli
diversi.

**Girata qui per la prima volta, la seconda suite dice: 83 prove, zero
cadute.** Non c'era niente di rotto dietro quella porta chiusa, e adesso si
sa invece di sperarlo.

---

## 6. IL CANCELLO, RIGIRATO QUI PRIMA DI SPINGERE

**Girato intero sull'albero di questo lavoro**, 16 settembre 2026, quaranta
minuti di macchina. Le tre parti, coi numeri che ha stampato:

| parte | esito |
|---|---|
| la suite intera di Flutter | **5.292 prove, 6 saltate, 3 cadute** |
| le prove del server, `npm test` in `functions/` | **83 prove, zero cadute** |
| il corredo a scala 1,3 | **182 schermate montate, 15 catture cadute** |

**Le quindici catture sono le quindici accettate**, una per una le stesse
righe `SCALA 1,3:` di `tool/rossi_accettati.txt`. **Due delle tre cadute della
suite sono le due accettate**, l'attribuzione cieca e le soglie delle quattro
pose. **La terza non c'e' piu'**: `corredo_anteprime_test.dart` non trova piu'
nessuna cattura a rapporto due, che e' la voce 01 chiusa e misurata invece che
raccontata.

**Il cancello si e' fermato lo stesso, e su una riga sola**:

```
ROSSI NUOVI, NON ACCETTATI DA NESSUNO:
    l'albero di lavoro non tiene lavoro che nessun commit contiene
```

**Quella riga e' la casa che dice l'ordine giusto.** I file di quest'ordine
erano ancora sull'albero e in nessun commit, e la guardia
`niente_lavoro_non_spinto` vuole l'albero pulito su una macchina di chi
sviluppa. Su Codemagic
e su GitHub torna verde da se', perche' li' il codice **arriva** dal remoto:
la guardia si esenta da sola leggendo `CM_BUILD_ID` e `GITHUB_ACTIONS`, e lo
dichiara nel suo commento invece di tacerlo.

### E QUI SI E' VISTA UNA COSA CHE NESSUNO AVEVA MAI NOMINATO

Il giro si e' ripetuto sull'albero **committato**, per far tacere quella
guardia, e al suo posto ne e' caduta **l'altra dello stesso file**: *"il ramo
locale non ha commit che il remoto non conosce"*.

**Non e' una sfortuna, e' una proprieta'.** `niente_lavoro_non_spinto` ha due
prove che chiudono i due lati della stessa domanda: l'albero non tiene lavoro
senza commit, e il commit non resta senza spinta. Su una macchina di chi
sviluppa **una delle due e' per forza rossa finche' il lavoro non e' spinto**,
e prima di spingere il lavoro, per definizione, non lo e'.

**Conseguenza, e riguarda la regola di casa**: *"suite intera prima di
spingere"* **non puo' dare un verde pieno**, mai, su questa macchina. Il verde
pieno esiste solo dopo la spinta. Chi gira il cancello qui deve leggere il suo
esito sapendolo, e la cosa giusta da guardare prima di spingere e' **la lista
dei rossi nuovi meno le due prove di quel file**. Il verde pieno, quello che
non ha bisogno di sottrazioni, e' quello di GitHub: e' un'altra ragione per
cui il cancello gratuito di questo ordine non e' un lusso.

**Cosa vuol dire, detto senza girarci intorno**: sull'albero di questo lavoro
non esiste nessun rosso nuovo oltre a quello che chiede di committare. Il giro
vero, sull'albero pulito, e' quello che gira **da solo su GitHub al push**, ed
e' la prima volta che il cancello gratuito fa la stessa domanda del cancello a
pagamento. **La sua spunta e' il semaforo per Codemagic.**

---

## 6-BIS. IL PRIMO GIRO DEL CANCELLO GRATUITO, E COS'HA INSEGNATO

**Il giro `35065403117`, sul commit `e99a9279`: ventotto minuti e sette
secondi, caduto al passo *Lo sbarramento*.** I sette passi prima, checkout,
Flutter, Node, le due famiglie di dipendenze e l'analisi statica, tutti verdi.

**I numeri, presi dalle annotazioni pubbliche del giro**, che si leggono con
una chiamata sola e senza chiave:

| suite | il giro su Linux | il giro qui, su Windows |
|---|---|---|
| Flutter | **5.293 passate, 2 cadute, 6 saltate** | 5.292 passate, 3 cadute, 6 saltate |
| corredo a scala 1,3 | **167 passate, 15 cadute** | 167 passate, 15 cadute |

**Le due cadute di Flutter sono i due rossi accettati**, e la terza di qui non
c'e' perche' e' la guardia del lavoro non committato, che su una macchina di
build si esenta da sola. **Le quindici del corredo sono quindici anche li'.**
I conti combaciano con cio' che il fondatore ha accettato, uno per uno.

**E allora perche' e' uscito rosso?** Lo sbarramento esce uno solo per due
ragioni, e tutte e due guardano i **nomi**, non i conti: un nome caduto che il
registro non ha, oppure un nome nel registro che oggi non cade piu'. **Quale
delle due sia, e su quale cattura, da qui non si e' potuto leggere**, e questa
e' la cosa che ha generato la voce 05.

**Il fatto nuovo, e va detto per intero**: i registri dei giri di GitHub **non
si leggono senza essere autenticati, nemmeno su un repository pubblico**.
Provato in due modi: l'API risponde **403**, e la pagina web dice *"Sign in to
view logs"*. Un cancello il cui verdetto si legge solo entrando con le
credenziali del fondatore parla a una persona sola, e chi deve ripararlo deve
chiedere. **Le annotazioni invece sono pubbliche**: e' da li' che vengono i
numeri di questa tabella, ed e' li' che adesso va anche il verdetto.

**Cosa NON si puo' ancora dire, e non si dira' finche' non e' misurato**: la
spiegazione piu' probabile e' che la scala 1,3 rompa su Linux catture in parte
diverse da quelle che rompe su macOS, perche' il disegno del testo cambia col
sistema, e il registro dei rossi accettati e' stato scritto guardando il mac
mini. **E' un'ipotesi, non una misura**: il prossimo giro la confermera' o la
smentira' con i nomi, senza che nessuno debba entrare da nessuna parte. Se
fosse vera, la conseguenza e' seria e riguarda questo ordine da vicino: **due
macchine con lo stesso comando non sono ancora lo stesso cancello**, finche'
un pezzo di cio' che misurano dipende da come il sistema disegna le lettere.

**Per la build di oggi non cambia niente, ed e' l'unica cosa che non e'
un'ipotesi**: le quindici catture accettate sono state lette **sul registro
del mac mini della 2264**, cioe' sulla stessa macchina e sullo stesso sistema
che costruisce l'archivio.

---

## 6-TER. L'IPOTESI ERA SBAGLIATA, E IL VERDETTO L'HA DETTO

**Il verdetto della voce 05 ha parlato al primo giro utile**, e non ha detto
quello che mi aspettavo. Non era la scala 1,3 che si comporta diversamente su
Linux. Era questo:

```
IL CORREDO A SCALA MASSIMA HA GUARDATO 0 SCHERMATE.
```

**Zero**, mentre le annotazioni dello stesso giro contavano 167 catture
passate e 15 cadute. Le due cose non possono essere vere insieme, e la
seconda era quella giusta.

**La causa, misurata accendendo `GITHUB_ACTIONS=true` su questa macchina**, e
non dedotta: `flutter test` **sceglie da se' come stampare**, e su GitHub
sceglie un rapporto diverso. Al posto delle righe
`00:03 +10 -1: nome [E]` stampa `✅ nome` e, alla fine, `6 tests passed.`.

**Tutto lo sbarramento legge quelle righe**: i nomi delle prove cadute, il
conto delle schermate montate, il confronto col registro dei rossi accettati.
Con l'altro rapporto **non leggeva niente**. Il cancello si fermava lo stesso,
ma si fermava per la guardia del cardinale minimo, cioe' per *"non hai
misurato niente"*, e non per cio' che aveva trovato: **la guardia che esiste
apposta per questo caso ha fatto il suo mestiere**, e senza di lei il giro
sarebbe stato verde senza aver guardato niente.

**E qui l'ordine prende la sua forma piu' dura**: due macchine non sono lo
stesso cancello perche' eseguono lo stesso comando. Lo sono quando **leggono
la stessa lingua**. Adesso il rapporto e' fissato con `-r expanded` in tutte
e due le chiamate, e una guardia pretende che **nessuna chiamata di
`flutter test` resti senza rapporto**: non che ci sia scritta una certa
parola, ma che nessuna macchina possa piu' scegliere da se'.

---

## 6-QUATER. IL CANCELLO GRATUITO E' VERDE, E NON LO ERA DAL 29 LUGLIO

| | |
|---|---|
| giro | `35103144149`, commit `bda25b14` |
| esito | **success**, 27 minuti e 43 secondi |
| i passi | tutti e otto verdi, sbarramento compreso |
| il passo del verdetto | **saltato**, perche' gira solo quando si cade |

**Il numero che dice cosa vuol dire.** Prima di quest'ordine il registro
contava **1.055 giri** di `verde.yml`: 130 verdi, 924 rossi, e **920 rossi
consecutivi** dal 29 luglio 2026. Questo e' il giro numero **921 dopo
l'ultimo verde**, ed e' il primo a non essere rosso **mentre esegue una
domanda piu' severa** di quella che prima falliva sempre: la suite intera, le
prove del server, il corredo a scala 1,3 e il registro dei rossi accettati.

**La spia che era rossa comunque adesso dice qualcosa.** E' il secondo
risultato che l'ordine chiedeva, e adesso e' misurato invece che promesso.

**E il cancello di questa macchina, sullo stesso commit**: suite intera
**5.338 prove, 6 saltate, 2 cadute**, che sono le due accettate; prove del
server **98, zero cadute**; corredo **182 schermate montate, 15 cadute**, che
sono le quindici accettate. *"ROSSI ACCETTATI, E SOLO QUELLI. L'ARCHIVIO SI
PRODUCE."*, e il gettone porta il numero 2264.

---

## 7. LA BUILD, I TENTATIVI E LA RELEASE

**Non e' ancora successa, e questa riga resta qui finche' non succede.** La
build la fa partire il fondatore da Codemagic: da questa macchina non si
costruisce un archivio iOS firmato, e non si vede il registro di quella
macchina.

**Quello che si puo' dire adesso, e sono fatti**: il rosso che ha fermato la
2264 non c'e' piu'; il numero di build 2264 e' ancora libero, perche' quella
corsa e' caduta prima dell'archivio e su App Store Connect non e' salito
niente; il gettone dello sbarramento di questa macchina porta quel numero; e
**la stessa identica domanda, su GitHub, e' verde**.

**Cosa resta fuori dalla portata di questo ordine**, e va ripetuto qui perche'
e' dove la build puo' ancora cadere: la firma, i profili, i pod, lo spazio sul
disco della macchina, la versione di Xcode e la validazione dell'archivio da
parte di Apple. Su quelle un cancello Linux gratuito non puo' dire niente.

**Le voci DQ.11 e DQ.12 restano aperte** finche' un archivio non e' stato
validato senza ITMS-91053.

---

## 8. DOVE L'ORDINE SBAGLIAVA

**L'elenco e' corto, e i fatti misurabili erano tutti veri.**

- **Il nome del rosso.** L'ordine lo chiama
  *"anteprima_card_della_rivelazione_test.dart cattura a rapporto 2.0 invece
  di 3.0"*: e' il **messaggio** dell'errore, e nomina il file colpevole. Il
  nome della **prova caduta**, quello che il registro stampa e che lo
  sbarramento confronta con `rossi_accettati.txt`, e' un altro: *"Nessuna
  cattura ha un rapporto di pixel implicito"*, e vive in
  `corredo_anteprime_test.dart`. **La differenza non e' accademica**: se un
  giorno il fondatore volesse accettare quel rosso, la riga da scrivere
  porterebbe il nome della prova, non quello del file.
- **Il passo 12 e i 29 minuti e 11 secondi**: non li ho potuti verificare dal
  ramo, perche' il registro della build vive su Codemagic. Il fondatore li ha
  poi confermati con le schermate, e il tempo del passo rosso si legge nella
  sua cartolina: **29m 11s**. Nel manifesto erano scritti come creduti sulla
  parola, adesso sono visti.
- **"I fondatori hanno solo iPhone"**: non e' verificabile da qui, e resta
  creduto sulla parola. Cambia la fretta dell'ordine, non il lavoro.

**Tutto il resto tornava**: le quindici catture a scala 1,3, i due rossi
accettati, il `functions/node_modules` mancante, i due workflow che eseguono
comandi diversi, il repository pubblico.

### E DOVE SBAGLIAVO IO

**Una cosa sola, ed e' la piu' grossa del documento.** Avevo scritto
*"nessun automatismo l'avrebbe fermata"*, e l'avevo scritto **senza guardare
il registro delle azioni di GitHub**, che e' pubblico e si legge con una
chiamata sola. L'automatismo c'era, era rosso tre ore prima di Codemagic, ed
era rosso da quarantotto giorni. **Ho dedotto invece di contare**, che e'
esattamente la cosa che il protocollo di casa vieta alla prima riga, e l'ho
fatto dentro un ordine che nasce per togliere le deduzioni di mezzo.

Il numero e' nella sezione 3. La correzione non cambia il lavoro fatto, lo
rende piu' necessario: se avessi creduto alla mia stessa frase, avrei consegnato
un cancello nuovo senza sapere che quello vecchio era guasto da luglio.
