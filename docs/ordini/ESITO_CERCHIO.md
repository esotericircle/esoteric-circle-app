# ESITO dell'ORDINE UNICO: I DATI, IL CERCHIO, L'ONBOARDING

## Dichiarazione, scritta prima di toccare il codice

Tredici voci. Ne ho gia' trovate tre leggendo, e le dichiaro adesso perche'
cambiano la stima.

**D3, la seconda porta e' in `onboarding_screen.dart:562`**: il sottotitolo
del passo dice ancora "accorderemo ogni frase al vocativo che preferisci". Ne
avevo corretta un'altra e non questa, che e' esattamente il difetto che
l'ordine mi contesta per la terza volta. Cerchero' tutte le porte e ne
dichiarero' il numero.

**B1, la causa e' in `MaestroController._setKey`**: `if (key == _activeKey)
return`. All'ingresso la chiave e' gia' quella giusta, quindi non parte
nessuna notifica e la scena resta com'era nata, cioe' neutra. E' la stessa
famiglia del nome minuscolo e del limite della chat: una regola applicata alla
transizione invece che allo stato.

**A2, il difetto e' `enabled: _timeKnown == true`**: con lo stato iniziale
nullo, ne' acceso ne' spento, quella condizione e' falsa, quindi i selettori
nascono disabilitati. La regressione l'ho introdotta io togliendo la
preselezione, e me ne assumo la responsabilita'.

**La stima, per gruppi.**

- **Parte 1 (A1, A2): piena, e per prima.** Tolgono dati alla persona, quindi
  hanno la precedenza su tutto. A1 ha gia' un `PopScope` che evidentemente non
  copre il gesto di sistema: devo capire perche', e questa e' la sola incognita
  vera della parte 1.
- **Parte 2 (B1, B2, B3, B4): B1, B2 e B3 piene.** B4 e' una funzione intera:
  scaffale precompilato dalla Risonanza, cuore dentro l'arte, cuore alla
  pressione lunga, matita con l'elenco a spunte, tetto, ripristino,
  persistenza. La dichiaro **piena, con una riserva sulla matita**: se il
  tempo stringe, la versione semplice e' lo scaffale precompilato piu' il
  cuore, senza l'elenco a spunte, e lo dico.
- **Parte 3 (C1, C2, C3, C4): piene.** C2 chiede di guardare a meta'
  animazione, che e' il posto giusto dove cercarlo.
- **Parte 4 (D1, D2, D3): D1 e D3 piene.**

**Su D2 devo essere chiaro subito.** L'ordine chiede di verificarlo "sull'app
in esecuzione e non solo con un test". Non ho un emulatore ne' un dispositivo:
posso rigenerare le anteprime e guardarle, che e' piu' di un test e meno di
un'app in mano. Quindi su D2 faro' la correzione e la verifica per immagine, e
**non dichiarero' chiuso cio' che non ho visto muoversi**: lo scrivero' come
verificato per immagine, non in esecuzione.

**Se il tempo finisce**, finiscono le ultime: prima la matita di B4, poi C4,
poi D2. Mai la parte 1.

## Stato voce per voce

### A1, il gesto che portava via i dati: CHIUSA

**Le porte erano due, non una.** La prima nell'onboarding: `canPop: _step ==
_Step.accoglienza` lasciava uscire dal primo passo. Sembrava innocuo, perche' al
primo passo non c'e' ancora niente da perdere, ma l'onboarding e' una rotta
spinta SOPRA lo shell: uscirne non chiude l'app, rivela la home che sta gia'
sotto. Bastava retrocedere fino al primo passo e insistere una volta.

La seconda porta era il **Risveglio**, che non aveva nessun `PopScope`. Il
Maestro si assegna alla rivelazione, cioe' all'ultima fase, quindi uscire prima
voleva dire entrare nel Cerchio senza Maestro, per di piu' senza che
l'onboarding tornasse a proporsi, dato che il lanciatore lo aveva gia'
considerato gestito. Questa porta l'ordine non la nominava: l'ho trovata
cercando la gemella.

Adesso, in tutti e due, il gesto retrocede di un passo come la freccia e dal
primo non fa nulla. L'unica uscita dal Risveglio e' la rivelazione, che usa
`pop` diretto proprio perche' `maybePop` passerebbe dal PopScope.

**Quattro test**, tre visti rossi prima: al terzo passo il gesto torna al
secondo, dal primo non apre la home, insistendo sette volte non apre la home,
dal Risveglio non si esce.

Un'asserzione l'ho **tolta invece di adattarla**: controllava
`needsOnboarding`, che nasce falso finche' il controller non ha letto le
preferenze, quindi sarebbe stata verde a prescindere dal difetto.

### A2, i selettori dell'ora: CHIUSA

**Regressione mia**, come avevo scritto nella stima: `enabled: _timeKnown ==
true` con `_timeKnown` che parte nullo e' sempre falso, quindi i selettori
nascevano spenti e per scegliere l'ora bisognava passare da "Non la so" e
tornare indietro.

Tre cose corrette insieme:

- I selettori sono **sempre** usabili. Toccarne uno vale come dire che l'ora si
  sa, quindi non serve dichiararlo due volte.
- `_hour` e `_minute` sono diventati **nullabili**, quindi l'invito "Ora" e
  "Minuti" che nel codice esisteva gia' ora si vede davvero. Prima le pillole
  dichiaravano 12 e 00, un'ora che nessuno aveva scelto e che finiva dritta
  nella carta natale.
- **Contrasto del quadrante alzato**: il cerchio dell'orologio da 0,45 a 0,75,
  le tacche da 0,75 e 0,40 a 0,95 e 0,65, e la velatura da 0,35 a 0,55 quando
  l'ora e' dichiarata ignota.

**Cinque test**, quattro visti rossi, su **entrambe le altezze**. Le due altezze
stanno in due prove separate: rimontare due volte nella stessa prova non
ripartiva pulito, e il verde che ne usciva diceva piu' sul test che sullo
schermo.

### B1, il colore al primo ingresso: CHIUSA

**La causa non era quella che avevo scritto nella stima.** Avevo indicato
l'uscita anticipata di `MaestroController._setKey`, ma quel controller e'
corretto: non notificare quando nulla cambia e' giusto. La causa vera stava in
`_CircleArtTile._open`, cioe' **nella tessera che apre l'arte**: era lei a
virare il tema prima di navigare. Funzionava per chi passava da li' e per
nessun altro. Chi apriva la stessa arte dallo scaffale del proprio Maestro,
dalla chat o da una rotta diretta entrava col colore di chi stava guardando
prima, e al primo ingresso col neutro. Per di piu' il ripristino era
condizionato a `previous != null`, quindi partendo dal neutro il colore
dell'arte restava addosso al Cerchio anche dopo essere usciti.

E' la quarta volta che incontro la stessa forma: **una regola messa in una
porta mentre le porte sono molte**. Quindi il colore ora si dichiara nello
stato, non nella transizione: `MaestroScope` accetta un proprietario, e quando
c'e' vince sempre, senza nemmeno osservare il Maestro attivo, cosi' un cambio di
tema avvenuto fuori non fa virare il colore sotto i piedi di chi sta usando
l'arte. **Tredici rotte** lo dichiarano, assegnate leggendo `art_catalog`, non a
intuito.

**Diciotto test.** Uno di essi, il primo che avevo scritto, misurava l'assenza
di `operator ==` su `MaestroPalette` invece del difetto: confrontava oggetti che
non sono mai uguali fra loro, quindi era rosso anche nel caso che doveva
passare. L'ho riscritto sul colore primario, che e' la cosa che si vede.

### B2, ogni bolla nel colore del suo Maestro: CHIUSA

Le bolle erano tutte nel viola condiviso: la striscia diceva a parole di chi
fosse ogni arte, con una scritta piccola sotto il nome, senza mostrarlo. Ora il
colore del proprietario sta nel fondo, nel bordo, nel cerchietto dell'icona e
nel nome del Maestro, col viola condiviso che resta sotto velato, cosi' la
striscia rimane una striscia sola e non tre accostate.

La tessera e' diventata pubblica, come il painter del sigillo, per la stessa
ragione: il colore di una bolla deve poter essere misurato senza montare
l'intero dominio coi suoi servizi.

**Due test**, entrambi visti rossi. Il secondo l'ho dovuto **riscrivere**: la
prima versione chiedeva che la componente dominante coincidesse, ma il verde
smeraldo di Aura ha di suo una componente blu alta, e sul viola quel blu passa
davanti al verde di un centesimo pur restando inequivocabilmente il colore di
Aura. Adesso misura la **vicinanza**: ogni bolla deve stare piu' vicina al
proprio Maestro che a ciascuno degli altri due.

### B3, i Doni fuori dall'elenco: CHIUSA

L'Oracolo del Giorno e la Runa del Tramonto stavano in **due posti nella stessa
schermata**: nella striscia del giorno in cima, che e' la loro casa, e di nuovo
nell'elenco delle funzioni sotto l'eroe. Tolti dall'elenco.

**Tre test**: nessun Dono nell'elenco, l'elenco resta abitato con almeno sei
voci vive, tutti e tre i Maestri restano rappresentati. Gli ultimi due servono a
non scambiare un doppione con un buco.

Il manifest `docs/stato_funzioni.json` e' stato allineato: il suo test lo ha
preso, ed e' andata come deve andare.

### B4, "Le tue arti": CHIUSA IN VERSIONE PIENA

Avevo dichiarato una riserva sulla matita. **Non serve: consegnata intera.**

Le tre regole vivono nel **dato**, in `lib/core/arts/arti_preferite.dart`, non
nelle schermate che lo mostrano.

1. **Non parte mai vuoto.** Il seme sono le arti vive del Maestro assegnato piu'
   una per ciascuno degli altri due, deterministico, senza numeri casuali. Non
   parte nemmeno monocolore: chi nasce con Caligo vede anche che Medora e Aura
   esistono. Prima della Risonanza il seme e' la prima arte viva di ciascuno,
   quindi abitato comunque. Anche il primissimo frame, prima che il disco
   risponda, mostra il seme invece di un vuoto: un lampo di scaffale spoglio
   all'avvio sarebbe indistinguibile dal difetto.
2. **Svuotandolo torna il seme.** Togliere l'ultima arte ripristina, e la
   schermata lo dice.
3. **Nessun piano lo tocca.** Un test legge il file e verifica che le parole
   tier, entitlement, premium, abbonamento e PlanCatalog non compaiano nel
   codice. Guarda solo il codice e non i commenti, perche' i commenti quelle
   parole le nominano proprio per dire che non si usano.

Il tetto e' **sei**: le arti vive sono nove, quindi sei lascia una scelta vera
senza ridiventare l'elenco completo. Chi prova ad aggiungere la settima se lo
sente dire, invece di vedere il tocco ignorato in silenzio.

**Il cuore sta in un punto solo.** Invece di metterlo a mano in nove schermate
ho creato `SogliaArte`, che porta insieme il colore del proprietario e il cuore:
le nove rotte d'arte passano da li', quindi chi aggiunge un'arte domani ottiene
entrambe le cose con una riga. Il cuore c'e' **dentro** l'arte, in alto a
destra, perche' si decide che un'arte piace mentre la si usa, e sulla bolla
tramite la **pressione lunga**, che dice sempre cosa e' successo.

**Un difetto trovato mentre lavoravo**: `rune_draw` e `magic_sigil`, cioe'
l'Estrazione Rune e il Sigillo dell'Intenzione, sono arti vive che nell'elenco
del Santuario non c'erano, quindi dal Santuario non si raggiungevano. Ora sono
fra le selezionabili, che e' il modo giusto di rimediare.

**Sedici test** in due file, nove sul dato e sette a schermo.

### C1, i trionfi dopo il numero della vita: CHIUSA

Il numero della vita chiude l'onboarding, nel passo del Sigillo, e il Risveglio
partiva dal cielo di nascita: fra il numero e i suoi trionfi si infilava
un'altra schermata. Adesso l'ordine e' Animale, Angeli, cielo, carta, risonanza,
rivelazione.

I trionfi hanno la freccia indietro **dove un indietro esiste**: il primo non ce
l'ha, perche' una freccia che non porta da nessuna parte e' peggio di nessuna
freccia. La freccia del cielo non ha avuto bisogno di codice nuovo: fa
`maybePop`, che passa dal PopScope messo per A1 e retrocede di fase. Gesto e
freccia sono diventati la stessa cosa.

**Quattro test**, tre visti rossi.

### C2, il quadrato rosso prima dell'animale: CHIUSA

La nebbia di Caligo era un `drawRect` su tutta l'area, con l'ultimo stop del
gradiente radiale OPACO: il riquadro finiva di netto contro il fondo. Adesso la
nebbia sta dentro un ovale ritagliato sul canvas, quindi **nessun angolo puo'
essere dipinto per costruzione**, l'ultimo stop e' trasparente e i banchi di
nebbia hanno raggi piu' raccolti.

**Due tentativi di misura buttati prima di trovarne una che funzionasse**, e
vale la pena scriverlo perche' e' la parte utile.

1. Il matcher `paints..rect`: verde senza che avessi corretto nulla. Non
   misurava il difetto.
2. L'intensita' assoluta agli angoli: sempre verde, perche' i colori di Caligo
   su fondo nero sono scuri di per se'. Una **prova di vista** aggiunta apposta
   ha mostrato che l'angolo valeva 0,044 e il centro 0,017: i pixel c'erano ma
   erano tutti scuri. Il quadrato non si vede per quanto e' rosso, si vede
   perche' ha un bordo netto.

La misura buona confronta la striscia appena dentro il bordo con quella appena
fuori. Rosso misurato: gradino 0,036 al primo frame, 0,030 a un quinto. E c'e'
una **prova di vista permanente** che fotografa un quadrato dichiaratamente
pieno e verifica che la misura lo denunci: se un giorno diventasse cieca, lo
direbbe invece di dare un verde vuoto.

Guardato al primo frame, a un quinto e **a meta' animazione**, come chiede
l'ordine.

### C3, le tre tessere dietro il velo: CHIUSA

Due delle tre descrivevano cose **gia' vive**.

- **Carta natale**: si calcola sulle effemeridi e si vede nel Risveglio. Ora ha
  la sua tessera viva e apribile nel passaporto. Non promette la Carta Natale
  interattiva coi transiti, che nel catalogo e' in arrivo ed e' un'altra cosa.
- **Angelo custode**: la tessera "I tuoi Angeli", poche righe sopra nello stesso
  passaporto, era gia' viva e apriva la triade calcolata. Erano due tessere per
  la stessa cosa, una accesa e una spenta.

Promettere come futuro qualcosa che l'app fa gia' e' peggio di non prometterlo:
chi legge conclude che non ce l'ha.

**L'Archetipo resta velato**, perche' il fatto identitario non e' calcolato ne'
conservato: il Test Archetipo di Aura e' un'arte che si puo' fare, non un dato
del passaporto. Il suo titolo non si spezza piu' a meta' parola, con lo stesso
rimedio gia' usato per "Meditazione".

**Un difetto trovato dai miei stessi test.** I test di C3 leggono i sorgenti, e
sono passati mentre il codice **non compilava**: una prova che un test
strutturale non basta. L'ho scoperto con `flutter analyze` un istante dopo, e
va detto perche' e' il limite di quel tipo di prova.

### C4, il permesso che spariva: CHIUSA

Il foglio che spiega perche' serve il microfono era un bottom sheet ordinario:
`isDismissible` ed `enableDrag` valgono true per difetto, quindi un tocco fuori
o uno sfioramento lo chiudevano. Succedeva proprio dove succede di piu', cioe'
nella schermata del soffio, dove si tocca e si trascina per far muovere la
scena. Adesso si esce con una scelta dichiarata, e anche il gesto Indietro vale
come "non ora" invece di una chiusura muta.

Nelle Impostazioni c'e' la voce **Permessi**, che apre le impostazioni di
sistema dell'app: un permesso negato una volta non si puo' richiedere di nuovo,
il sistema smette di mostrare la richiesta. Usa `Geolocator.openAppSettings()`,
la stessa via che il cielo usa gia': nessuna dipendenza nuova per una riga. La
voce dichiara che ogni esperienza funziona anche col solo tocco.

**Sei test**, tre visti rossi.

### D1, la mano: CHIUSA, e il difetto l'ha trovato l'anteprima

Terza stesura, **bianca**, non nel colore del Maestro: e' un suggerimento di
gesto, non un elemento del tema.

Le due precedenti erano state bocciate per ragioni diverse, e la seconda aveva
le PROPORZIONI sbagliate: indice lungo diciannove punti su quarantotto e largo
sette, cioe' un moncone grosso quanto un dito intero, con tre nocche della
stessa misura.

**Poi e' arrivato il difetto vero, e l'ho visto solo guardando.** Sistemate le
proporzioni, la sagoma con l'indice al CENTRO del pugno si leggeva come un
gesto volgare. Nel codice non si vedeva. Ingrandita era evidente, e non l'avrei
mai consegnata cosi'. Da li' lo scostamento: l'indice sta sul lato sinistro,
dove sta in una mano vera, il pugno resta piu' largo a destra e il pollice
sporge in fuori e in basso.

L'anteprima e' in `docs/preview/mano-terza-stesura.png`, con tre istanti
affiancati, e il painter e' diventato pubblico proprio per poterlo montare
ingrandito.

### D2, ScrollReveal: CORRETTA, verificata per IMMAGINE e non in esecuzione

**Il codice era corretto, il difetto era nella misura del tempo.** La comparsa
durava 260 millisecondi, cioe' sotto la soglia di quello che l'occhio registra
come movimento, e la transizione di una rotta ne dura circa 300: la comparsa si
consumava mentre la schermata stava ancora entrando. Adesso dura 420.

**Una mia ipotesi si e' rivelata sbagliata, e i test lo hanno dimostrato.**
Avevo scritto tre prove partendo dall'idea che la comparsa fosse coperta dalla
transizione della rotta: sono passate tutte e tre subito, quindi il momento
andava bene e il difetto era altrove.

**Un difetto che ho introdotto io e che ho poi ritirato.** Avevo alzato anche
l'ampiezza, da dieci pixel a ventidue: tre prove del dominio sono diventate
rosse. La causa e' che ogni strato e' traslato di una quantita' diversa, quindi
con ventidue gli elementi vicini si SOVRAPPONGONO durante la comparsa e un
tocco che arriva in quel momento finisce sulla voce sbagliata. L'ho trovato
mettendo da parte tutte le modifiche e riportandole una per una. L'ampiezza e'
tornata a dieci, con un test che fissa il limite e dice perche', cosi' nessuno
lo alza senza prima sospendere il tocco.

**Quello che NON ho potuto fare.** L'ordine chiede di verificarlo sull'app in
esecuzione. Non ho un emulatore ne' un dispositivo: ho rigenerato le anteprime
e le ho guardate, che e' piu' di un test e meno di un'app in mano. Lo avevo
dichiarato nella stima e lo confermo qui: **corretto e verificato per immagine,
non in esecuzione.** Su un dispositivo resta da guardare.

### D3, "vocativo": CHIUSA, e le porte erano tre

**Il numero esatto, come chiede l'ordine.** Tre occorrenze dentro letterali in
tutto `lib`, di cui **una sola visibile**: il sottotitolo del passo. Le altre
due sono `titoloEvocativo` della Costellazione del Viso, che e' un'altra parola,
e la chiave di un widget, che non si vede. In un ordine precedente avevo
corretto un'altra occorrenza lasciando questa.

Il test non guarda un file, **guarda tutto il codice**: e' la sola difesa che
vale contro questa forma di difetto. Prova del rosso fatta rimettendo la parola
per un istante: rosso con, verde senza.

**La frase neutra non elencava participi**: e' "Ti do il benvenuto", una forma
senza desinenza. Ho cercato in tutto il codice testi con due desinenze separate
da barra e non ce ne sono. Un test lo verifica su tutte le forme di cortesia,
cosi' resta vero.

## Stima contro consegnato

| Voce | Dichiarato | Consegnato |
|---|---|---|
| A1, A2 | piene, per prime | piene, per prime |
| B1, B2, B3 | piene | piene |
| B4 | piena, con riserva sulla matita | **piena, riserva non servita** |
| C1..C4 | piene | piene |
| D1, D3 | piene | piene |
| D2 | non verificabile in esecuzione | corretta, **verificata per immagine** |

**Dove la stima ha sbagliato.** Avevo indicato come causa di B1 l'uscita
anticipata di `MaestroController._setKey`. Quel controller e' corretto: non
notificare quando nulla cambia e' giusto. La causa vera era la tessera che
apriva l'arte. Ho corretto la causa, non il sintomo che avevo previsto.

**Cio' che ho previsto bene**: A2 era una mia regressione, D3 era la seconda
porta, e D2 non era verificabile in esecuzione.

## La forma di difetto che torna

Quattro volte, ormai: **una regola messa in una porta mentre le porte sono
piu' d'una.** Il nome minuscolo, il limite delle domande, la parola "vocativo",
e oggi il colore del Maestro. Due volte in questo stesso ordine ho trovato la
porta gemella cercandola invece di aspettare che me la segnalassero: il
Risveglio in A1, che l'ordine non nominava, e la seconda tessera degli Angeli
in C3.

Per questo, dove ho potuto, la regola e' finita nel dato o in un punto unico:
il proprietario dentro `MaestroScope`, il cuore e il colore dentro
`SogliaArte`, il seme e il tetto dentro `ArtiPreferiteController`.

## I numeri finali

- Suite: **1029 test verdi**, zero rossi.
- `flutter analyze` su lib e test: **pulito**, zero avvisi.
- Test nuovi: **cinquantatre'**, in sedici file.
- Test esistenti aggiornati: **sei**, in cinque file, tutti per conseguenze
  dichiarate delle correzioni.
- Test buttati perche' non misuravano: **tre**, cioe' il matcher `paints`,
  l'intensita' agli angoli e l'asserzione su `needsOnboarding`.
- Anteprime rigenerate e diverse dalle precedenti: **cinquantuno**, piu' una
  nuova.
- Peso dell'archivio: **194,3 MB**, invariato. La prima misura diceva 219,8:
  era un residuo della build precedente, come mi era gia' capitato. Misurata di
  nuovo dopo una build pulita.

## Consegna

- Identificativo della release: **`4an73rv7rqu2g`**
- Versione: 0.1.0, build **2108**
- Esito del caricamento: **`RELEASE_CREATED`**
- Destinatario unico: `cloud@esotericircle.app`
- Commit del codice: `de74517`, spinto su origin. Hash locale e remoto
  coincidono.

**Da installare: la 2108.**

La suite era verde PRIMA del caricamento, e la consegna non e' stata
parallelizzata con la verifica.

## Correzione della consegna, dopo la segnalazione di Mauro

**La 2108 era stata creata ma non assegnata a nessuno, e la colpa era di un nome
di campo.**

I passi dell'API sono due e distinti: il caricamento crea la release, la
distribuzione la assegna. Il caricamento era andato a buon fine
(`RELEASE_CREATED`). Nella distribuzione avevo mandato

    {"emails": ["cloud@esotericircle.app"]}

mentre il campo si chiama `testerEmails`. L'API **ignora i campi sconosciuti**,
quindi ha risposto `{}` con HTTP 200 avendo distribuito a una lista vuota. Ho
letto quel `{}` come conferma, e non lo era.

**Rieseguito il solo secondo passo**, col campo corretto, senza ricaricare
l'archivio: HTTP 200.

**La prova, che non e' il 200.** Ho verificato che il 200 non significa nulla:
la stessa chiamata con `{"testerEmails": ["non-e-una-email"]}` risponde 200 e
`{}`. Quindi ho cercato una prova indipendente, confrontando la 2108 con la
2107, che era arrivata davvero:

- Nel GET della 2108 fatto PRIMA della distribuzione corretta il campo
  `acceptedInvitationCount` **non c'era**.
- Nel GET fatto DOPO c'e': `acceptedInvitationCount: 1`, lo stesso valore della
  2107.

E' comparso per effetto della distribuzione, ed e' l'unico segnale che l'API
espone: non esiste un endpoint che elenchi i tester di una release, e `v1alpha`
risponde 404.

**Nessuna sporcizia lasciata.** L'email malformata usata per la prova non ha
creato alcun tester: nel progetto restano i due di sempre.

**Resta una differenza, e non blocca**: la 2108 porta
`androidPackageRegistrationState: NOT_REGISTERED`, che riguarda la registrazione
del dispositivo del tester e si risolve aprendo il link.

**Regola nuova, per gli ordini futuri.** Dopo ogni distribuzione si verifica la
comparsa di `acceptedInvitationCount` sulla release, perche' il codice HTTP 200
di quell'endpoint non distingue una consegna riuscita da una richiesta ignorata.
