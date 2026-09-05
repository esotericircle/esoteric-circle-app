# ESITO dell'ORDINE CORRENTE

## L'identita' completa e un solo sistema di scena

Eseguito da Claude Code il 28 luglio 2026, sul ramo
`claude/esoteric-circle-master-order-e798aj`.

Prima di tutto il resto, la cosa che conta: **questo ordine e' stato eseguito in
parte**. Le Parti 1, 5 e 6 sono fatte, la Parte 2 sui fondali, la Parte 3 sul
permesso di posizione e la Parte 4 sul carosello dei Maestri NON sono state
toccate. L'ordine dice che il criterio di riuscita e' che Mauro non riveda gli
stessi difetti: quelli delle parti non toccate li rivedra', quindi vanno
rimessi in un ordine successivo. Meglio dirlo qui in testa che farlo scoprire dal telefono.

### PARTE 1, l'identita' completa: FATTA

#### Le tre regole di attribuzione, come sono implementate

Stanno tutte in `lib/core/angels/guardian_angels.dart`, in un punto solo, con la
fonte scritta sopra ciascuna.

**Angelo Custode**, `guardianFor(double sunEclipticLongitude)`. Prende la
longitudine eclittica del Sole e la divide per cinque gradi, con il floor, poi
somma uno per passare dall'indice al numero d'ordine. La longitudine arriva da
`Celestial.sunEclipticLongitude`, cioe' dallo stesso motore che disegna il
cielo, non dalla data di calendario: fra le due c'e' quasi sempre un giorno di
scarto, perche' i confini dei segni non cadono a mezzanotte. La longitudine
viene normalizzata in 0..360 prima della divisione, quindi 360 gradi torna al
primo angelo e una longitudine negativa rientra dall'altro capo.

**Angelo del Cuore**, `heartFor(DateTime birthDate)`. Prende il giorno dell'anno
e lo riporta nel ciclo dei settantadue con `((giorno - 1) % 72) + 1`. Il giorno
dell'anno si calcola in `dayOfYear`, sommando i giorni dei mesi precedenti piu'
il giorno del mese, piu' uno se l'anno e' bisestile e il mese e' oltre febbraio.
NON si calcola per differenza fra due DateTime: al cambio dell'ora legale la
giornata dura ventitre' ore oppure venticinque, percio' una differenza assoluta
sposterebbe il giorno ordinale, quindi l'angelo. Due test attraversano i due
cambi d'ora del 1990, il 25 marzo e il 30 settembre, per verificare che i
giorni restino consecutivi.

**Angelo dell'Intelletto**, `intellectFor(int? hour, int? minute)`. Somma ore e
minuti in minuti dalla mezzanotte e divide per venti, che e' 1440 diviso 72.
Senza ora ritorna nullo, che resta nullo lungo tutta la catena: la schermata
mostra al suo posto una tessera dichiarata che invita a inserire l'ora, con lo
stesso tono gia' usato per Ascendente e case.

#### Criteri numerici della Parte 1

- Test sui confini: **passa**. Coperti 0 gradi, 4,999, 5 esatti, 355, 359,9, 360
  e meno uno; 00:00, 00:19, 00:20, 00:39, 00:40, 01:00, 12:00, 23:40, 23:59;
  primo e ultimo giorno dell'anno, 29 febbraio bisestile, i due cambi d'ora. In
  piu' due test di copertura totale: scorrendo il cerchio di mezzo grado in
  mezzo grado escono esattamente 72 angeli distinti; scorrendo i 1440 minuti
  della giornata escono esattamente 72.
- Senza ora l'angelo dell'intelletto non e' mostrato come noto e compare
  l'invito: **passa**, con un test per ciascuno dei due casi.
- Tessera degli Angeli toccabile che apre la schermata: **passa**.
- Tre carte con tre immagini distinte da `assets/img/angeli/`, non ripieghi:
  **passa**. Il test raccoglie i nomi degli asset montati e ne conta almeno tre
  distinti dentro quella cartella.
- Carta natale con le sei presenze: **fatta, misurata in parte**. Sole, Luna e i
  pianeti erano gia' nella legenda, l'Ascendente nella sua nota, il Numero della
  Vita nei fatti identitari; ho aggiunto Animale Guida e i tre Angeli con
  `BirthCompanions`. Il test verifica le due presenze nuove e l'apertura della
  schermata, non conta tutte e sei in una volta sola.
- Le tre animazioni di trionfo: **una su tre**. Quella dei tre Angeli esiste,
  dura 2200 ms, verificata maggiore di zero e sotto il tetto di 2500 ms
  chiesto, piu' verificata ferma con Riduci Movimento. Il Sigillo
  dell'onboarding e l'Animale Guida NON sono stati toccati.
- Centro del sigillo fra il 45 e il 55 per cento: **non fatto**.

#### Il contenuto degli angeli

`docs/corpus/angeli.md` non esiste nel repository, quindi il catalogo e' stato
costruito come l'ordine prevede per questo caso. I settantadue nomi vengono
dagli stem degli asset in `assets/img/angeli/`, che nascono dallo stesso Corpus:
nome e immagine non possono divergere, perche' il percorso si ricava dal numero
e dallo slug. Un test verifica che tutti e settantadue i file esistano.

Ci sono numero, nome, coro, arcangelo del coro e dominio del coro, coi nove cori
da otto verificati da un test. NON ci sono virtu' e salmo del singolo angelo,
che l'ordine dichiara non verificati: al loro posto ogni carta dice che quello
strato arriva. Quando il Corpus sara' depositato, i campi si aggiungono al
catalogo e le schermate li mostrano senza altre modifiche.

### PARTE 5, testi: FATTA in due punti su cinque

- "Entra nel Santuario" e' diventato "Entra nel Cerchio". La barra di
  navigazione diceva gia' "Il Cerchio", quindi quella era l'unica occorrenza a
  video: **misurato**, zero stringhe con la parola Santuario nei testi mostrati.
- Il vocativo capitalizza il nome: "mauro" diventa "Mauro". Vale su ogni parola,
  cosi' i nomi composti restano a posto. Il resto delle lettere non si tocca,
  perche' De Luca non deve diventare De luca.
- Il nome Medora che va a capo, l'avatar che copre i titoli e la silhouette
  infelice NON sono stati toccati.

### PARTE 6, ciclo e integrita': FATTA in due punti su tre

- **Un solo APK**: la build usa ora `--target-platform android-arm64` e produce
  `app-debug.apk`, non piu' tre archivi.
- **Controllo di integrita'**: `tool/verifica_apk.py` apre l'archivio costruito e
  conta i file di ogni famiglia dentro `assets/flutter_assets/`, confrontandoli
  col manifest. Provato in rosso su un APK sintetico privo dei tarocchi: esce
  con codice 1 e dice quale famiglia manca e di quanto. Sull'APK vero passa, con
  otto famiglie complete in piena e in miniatura.
- **Ripristino del Risveglio in debug**: NON fatto.

### Suite e analisi

`flutter test`: **807 test verdi**, erano 790 prima di questo ordine, quindi i
diciassette nuovi si sommano senza rompere niente. `flutter analyze`: pulito.

Due test esistenti sono diventati rossi per causa mia, ed erano rossi giusti.
Il primo, `language_rule_test`, ha colto una virgola seguita dalla congiunzione
in un testo nuovo della schermata degli Angeli. Il secondo, `passport_test`,
contava esattamente tre righe "Valore d'esempio" e ne ha trovate quattro,
perche' la tessera degli Angeli e' una tessera viva in piu': il conteggio e'
stato portato a quattro, con la tessera nuova verificata per chiave.

### APK e consegna

Un solo archivio, `build/app/outputs/flutter-apk/app-debug.apk`, **244.457.589
byte, cioe' 233,13 MiB**. Lo split per ABI non si usa piu': prima la stessa
build ne produceva tre.

Il controllo di integrita' passa sull'archivio di consegna, con le otto famiglie
tutte complete in piena e in miniatura: angeli 73, animali 12, archetipi 12,
cristalli 12, mazzo-tarocchi 79, ritratti-vip 50, rune_bone 24, zodiac 12. Il
token di App Check e' dentro il kernel, cercato e trovato.

Consegna riuscita, un solo destinatario come chiesto: release 0.1.0 (1), note
applicate, distribuzione conclusa.

- Console Firebase:
  `https://console.firebase.google.com/project/esoteric-circle/appdistribution/app/android:com.esotericircle.esoteric_circle/releases/4a2r5i2srlsfo`
- Pagina per i tester:
  `https://appdistribution.firebase.google.com/testerapps/1:425821975933:android:1b1ca4db8d4df69b940814/releases/4a2r5i2srlsfo`

Il link diretto al binario resta fuori da qui: porta un token valido un'ora, il
repository e' pubblico.

Una nota sul percorso: la prima build di questo ordine ha riportato fallimento
pur avendo prodotto l'APK: avevo lanciato la suite di test in parallelo, quindi
le due contendevano la cartella `build/`. Rifatta da sola, e' passata in 44
secondi. Errore mio di conduzione, non del codice.

### PARTI 2, 3 e 4: NON FATTE

Restano intere, coi loro criteri numerici. Non c'e' una riga di codice che le
riguardi in questo lavoro.

- Parte 2, gli otto sistemi di fondale restano otto, l'ampiezza del sensore resta
  a 2,16 px sul piano principale, il fondale resta ripetuto, `ScrollReveal` resta
  legato al montaggio.
- Parte 3, il permesso di posizione resta senza comando toccabile e senza via
  d'uscita dal rifiuto permanente.
- Parte 4, il carosello dei Maestri resta senza transizione e senza
  trascinamento.

Sono tre rifacimenti profondi: l'unificazione dei fondali tocca sette classi e
ogni schermata immersiva dell'app. Vanno fatti con la stessa cura delle Parti 1
e 6, non in coda a un lavoro gia' lungo.


## L'identita' di nascita diventa vera, ordine chiuso del 28 luglio

Eseguito da Claude Code il 28 luglio 2026, notte, sul ramo
`claude/esoteric-circle-master-order-e798aj`.

### A. Il luogo di nascita si puo' scegliere davvero

Il meccanismo c'era gia' e non era rotto: `_PlaceField` mostrava i suggerimenti,
ognuno era un tocco vero con la sua chiave, la CTA cambiava gia' etichetta da
"Salta per ora" a "Continua". Quel che mancava erano i DATI: in catalogo
c'erano settanta citta', quindi digitando "busto Arsizio" non compariva niente e
la CTA non aveva mai motivo di cambiare. La diagnosi dell'ordine descriveva
bene il sintomo, la causa era piu' in basso.

L'elenco vero e' `assets/data/luoghi.csv`, generato da `tool/genera_luoghi.py`
dai dump pubblici di GeoNames, licenza CC BY 4.0: 7896 comuni italiani, cioe'
tutti, piu' 542 localita' italiane che comune non sono (Mestre, Marghera e
simili, dove pure si nasce), piu' 3130 citta' estere sopra i duecentomila
abitanti e tutte le capitali. In tutto 11.568 righe, 412.621 byte.

Formato compatto, letto una volta sola e indicizzato in memoria: prima riga la
versione, seconda la tabella dei fusi, poi una riga per luogo con nome, nome
alternativo, area, coordinate e indice del fuso. L'area e' la sigla della
provincia per l'Italia e il nome della nazione in italiano per l'estero, cosi'
gli omonimi si distinguono. Le righe sono ordinate per popolazione decrescente,
quindi la ricerca che le scorre in ordine restituisce Roma prima di Romano di
Lombardia senza dover portare la popolazione dentro l'app.

Nessun geocoding online, come chiesto: nessuna chiave, nessun costo, nessuna
latenza, nessuna dipendenza dalla rete. Il caricamento parte in sottofondo
all'apertura del Risveglio e chi digita prima che sia pronto cerca nel seme
compilato, con la ricerca che si rifa' da sola appena l'elenco pieno arriva.

Due difetti nel generatore, trovati e corretti mentre lo scrivevo. Il primo:
l'esonimo italiano veniva applicato a ogni omonimo, quindi London in Ontario
diventava "Londra, Canada"; ora vale solo per la prima occorrenza, che essendo
l'elenco ordinato per popolazione e' quella giusta. Il secondo, piu' serio:
l'offset di riserva veniva calcolato sulla longitudine zero per tutti i fusi
non in tabella, quindi meta' mondo finiva a UTC. Risolto alla radice prendendo
gli offset da `timeZones.txt` di GeoNames, colonna rawOffset, invece di
stimarli: Lagos sta sul meridiano di Greenwich ma segue l'ora dell'Europa
centrale, quindi la stima la sbagliava di un'ora piena. Un test lo blocca.

Aggiunta la riga che il GATE chiede: senza luogo la schermata dichiara che
restano fuori l'Ascendente e le case, mentre il resto del cielo resta saldo. La
riga tace mentre l'elenco dei suggerimenti e' aperto, perche' li' la persona sta
scegliendo e non saltando, oltre al fatto che con otto risultati sopra finiva
sotto il bordo dello schermo, cioe' era scritta per nessuno. Questo si e' visto
solo guardando l'anteprima a video, non dai test.

### B. Basta coordinate inventate

`BirthDetails.place` e' ora nullable, ed e' questa la correzione vera: finche' il
modello obbligava un luogo, il codice era obbligato a inventarlo. Il compilatore
ha poi indicato da solo tutti e cinque i punti che davano per scontate le
coordinate.

`_placeForChart()` non fabbrica piu' niente e torna nullo. `FreeAstroClient`
si ferma prima di chiamare e solleva, quindi nessun payload puo' partire con
latitudine zero e longitudine zero. `buildSkySnapshot` vuole il luogo come
parametro esplicito, perche' una volta celeste senza un punto da cui guardarla
non esiste. La scena del cielo di nascita, senza luogo, dice che la volta non si
ricostruisce invece di disegnarne una altrui. La frase d'apertura cambia: non
si promette "questo e' il cielo della notte in cui sei nato" mentre si mostra
altro. Per la sola fase lunare si resta sul tempo universale, che non e' un
luogo inventato ma l'assenza di correzione locale, che sulla fase pesa meno
di un'ora di Luna: e' dichiarato nel codice.

### C. Il Passport legge l'identita' vera

Una riga in `app_shell.dart`, che ora passa l'identita' del `ProfileController`.
Con essa spariscono insieme il numero della vita d'esempio, la fase lunare del
15 giugno 1990, l'animale guida della data sbagliata e la riga "Valore
d'esempio", perche' tutte le tessere leggono la stessa identita'.

Il primo test che avevo scritto passava l'identita' direttamente alla schermata,
poi passava al primo colpo: non provava niente, perche' il difetto stava nel
tratto fra il profilo persistito e la schermata, che nessuno percorreva. Rifatto
montando l'app come alla vera accensione, con le preferenze gia' scritte, il
rosso e' arrivato.

### D. Il testo del cielo di nascita

`NightSky.describeMoon` prende ora il contesto temporale e la schermata glielo
passa: la stessa riga serve due cieli, quello di stasera e quello della notte in
cui la persona e' nata, quindi il tempo verbale deve seguire il contesto. Controllati
tutti i testi della schermata: l'unico altro che nomina stanotte e' il messaggio
del permesso di posizione, che nel cielo di nascita non si presenta mai, perche'
li' la posizione non si chiede.

### Criteri di accettazione, uno per uno

- Elenco con almeno 7900 comuni italiani e 200 estere: **passa con uno
  scostamento da dichiarare**. I comuni italiani sono 7896 in tutto, non 7900:
  il numero dell'ordine era di poco sopra la realta'. Sono coperti tutti. Le
  voci italiane sono 8438 contando le localita' che comune non sono, quindi il
  test conta le voci italiane e verifica che siano almeno 7900. Le estere sono
  3130. Nessun campo vuoto, nessuna coordinata nulla, fuso IANA per tutte.
- `busto` fra i primi cinque: passa, Busto Arsizio e' il primo.
- `citta di cast` senza accento: passa, Citta' di Castello.
- `roma` con omonimi distinguibili: passa, come si vede anche nell'anteprima:
  Roma RM, poi Romano Banco MI, Romano di Lombardia BG, Romano d'Ezzelino VI,
  Romagnano Sesia NO, ognuno con la sua provincia.
- Etichetta "Salta per ora" senza luogo e "Continua" col luogo scelto: passa,
  un test verifica entrambe attraversando il rito.
- Payload mai con lat zero e lng zero: passa, con in piu' che senza luogo non parte
  nessuna chiamata.
- Passport con identita' reale senza "Valore d'esempio" e col numero della vita
  della data vera, piu' il contrario senza identita': passano tutti e due.
- Nessuna occorrenza di "stanotte" nella schermata del cielo di nascita: passa,
  su tutti i testi montati e non solo su quelli in vista.
- Suite intera verde e analyze pulito: passano, 790 test contro i 773 di prima.
- **Peso dell'APK: NON passa. La ragione va letta.** Vedi sotto.

### Il peso dell'APK: cosa rivela

L'arm64 e' passato da 228.770.276 a 255.244.433 byte, cioe' da 218,2 a 243,4
MiB: piu' 25,2 MiB, contro un criterio che ne concedeva 2. L'asset che ho
aggiunto pesa pero' 412.621 byte, cioe' 0,39 MiB.

La differenza e' identica su tutti e tre gli ABI, 26.474.157 byte esatti, il
che esclude il codice nativo, che per ogni ABI ha dimensioni diverse. Il
conto torna con precisione: 255.244.433 meno i 26.292.806 byte delle 79
immagini del mazzo di tarocchi meno il CSV compresso da' esattamente il peso di
ieri notte.

Cioe': **l'APK distribuito ieri notte era privo delle immagini dei tarocchi**.
La spiegazione piu' probabile e' il merge degli asset di Gradle rimasto sporco
dopo i due fallimenti di compilazione di quella sera, poi riusato dalla build
riuscita; toccando un asset questa volta il merge e' stato rifatto da zero e ha
incluso tutto. L'APK di adesso e' completo, verificato aprendo l'archivio: 79
file nel mazzo, 73 angeli, 50 ritratti VIP, 24 rune, 12 animali, 12 cristalli,
12 archetipi, 24 zodiac, coerenti col manifest.

Il criterio quindi non e' rispettato alla lettera, ma non per questo lavoro: il
mio contributo al peso e' 0,39 MiB, dentro la soglia. Il riferimento dei 218,2
MiB era un APK incompleto. Se Mauro ha gia' installato quella release, nella
Stesa vedeva i ripieghi dipinti al posto delle carte.

### Ricostruzione e consegna

Build rifatta col token fissato e distribuita, riuscita al primo tentativo:
release 0.1.0 (2001), note di rilascio applicate, distribuzione ai due tester
conclusa. Il token e' dentro il binario, verificato di nuovo cercandolo nel
kernel estratto dall'APK; l'elenco dei luoghi e' nel bundle con tutte le 11.568
righe.

- Console Firebase:
  `https://console.firebase.google.com/project/esoteric-circle/appdistribution/app/android:com.esotericircle.esoteric_circle/releases/435t9o8jf4csg`
- Pagina per i tester:
  `https://appdistribution.firebase.google.com/testerapps/1:425821975933:android:1b1ca4db8d4df69b940814/releases/435t9o8jf4csg`

Il link diretto al binario non entra qui, come la volta scorsa: porta un token
valido un'ora, il repository e' pubblico.

### Fuori scope, come chiesto

Non toccati i due motori lunari, le due implementazioni del numero della vita,
`docs/STATO_VIVO.md`, `ORDINE_ENTITLEMENT.md`.

### Una correzione a quanto avevo riportato ieri

Nell'esito precedente ho scritto che le anteprime non erano cambiate e ne ho
dato come ragione che la striscia del token non entra nelle catture. Il fatto
era giusto, la ragione no: `docs/preview` si riscrive soltanto lanciando la
suite con `AGGIORNA_ANTEPRIME=1`, altrimenti le catture finiscono in
`build/preview`, quindi quel `git status` pulito non provava quello che gli
facevo dire. Che la striscia non entri nelle catture resta vero, perche' i
servizi offline hanno il flag spento, ed e' verificato da un test dedicato.
Questa volta le anteprime sono state rigenerate per davvero: e' cambiata
`risveglio-luogo.png`, che mostra l'elenco vero, ed e' l'unica che tengo. Le
altre quattro toccate cambiano a ogni esecuzione perche' dipendono dall'ora
corrente, quindi sono state riportate indietro invece di gonfiare il repo.

## Consegna al telefono con App Distribution, ordine chiuso del 27 luglio

Eseguito da Claude Code il 27 luglio 2026, notte fonda, sul ramo
`claude/esoteric-circle-master-order-e798aj`.

Comando eseguito, uguale a quello dell'ordine salvo le barre del percorso, che
in questa shell vanno in avanti:

```
firebase appdistribution:distribute "build/app/outputs/flutter-apk/app-arm64-v8a-debug.apk" --app 1:425821975933:android:1b1ca4db8d4df69b940814 --testers "cloud@esotericircle.app,info@esotericircle.com" --release-notes "Prima accensione. Token App Check fissato nel binario."
```

Prima di lanciarlo ho verificato due cose invece di darle per buone. L'App ID
nell'ordine coincide col campo `mobilesdk_app_id` di
`android/app/google-services.json`, dove il progetto e' `esoteric-circle` e il
pacchetto e' `com.esotericircle.esoteric_circle`. Il CLI, versione 15.22.4,
risulta autenticato come `cloud@esotericircle.app`, come diceva l'ordine.

Esito: riuscito al primo tentativo, senza nessuna abilitazione da fare. Il
punto 2 dell'ordine non si e' presentato: App Distribution era gia' attivo sul
progetto, il CLI non ha chiesto nulla e non ha stampato nessun link da seguire.

Il caricamento ha prodotto la release **0.1.0 (2001)**, con le note di rilascio
applicate e la distribuzione ai due tester conclusa. Le tre righe di conferma del
CLI sono state, nell'ordine, release caricata, note aggiunte, distribuzione ai
tester eseguita.

Link stabili:

- Console Firebase della release:
  `https://console.firebase.google.com/project/esoteric-circle/appdistribution/app/android:com.esotericircle.esoteric_circle/releases/2dir9c8k5lpno`
- Pagina per i tester:
  `https://appdistribution.firebase.google.com/testerapps/1:425821975933:android:1b1ca4db8d4df69b940814/releases/2dir9c8k5lpno`

Il CLI stampa anche un terzo link, quello del binario in chiaro. Quel link NON
viene scritto qui, con una motivazione precisa: porta in coda un token di
accesso valido un'ora, questo repository e' pubblico, la regola ferrea dice che
i segreti non stanno su Git. Chiunque potrebbe scaricare l'APK entro l'ora,
col token di debug di App Check dentro. Il link e' stato consegnato a Mauro
direttamente in chat, dove serve. Per installare bastano comunque i due link
stabili qui sopra, che non scadono.

Nessun file di codice e' stato toccato, come chiesto dal punto 4. Non e' stato
toccato ne' `docs/STATO_VIVO.md` ne' `ORDINE_ENTITLEMENT.md`.

### Fronte aperto da mettere a registro: il peso dell'APK

L'ordine chiede di registrare il peso come fronte aperto senza intervenire. Non
posso scriverlo in `docs/STATO_VIVO.md`, che il punto 4 mette fuori dalle mani,
quindi lo lascio qui perche' l'Architetto lo trascriva nella sezione giusta.

L'APK arm64 di debug pesa 218,2 MiB, fuori scala anche per una distribuzione
interna. La causa e' quasi certamente il bundling in-app degli asset delle sei
famiglie esoteriche a due misure, cioe' piena e miniatura, quando le stesse
famiglie sono gia' pubblicate su CDN. Va bene per la prima accensione. Non va
bene per una Demo: prima di mostrarla a qualcuno la voce va affrontata.

## L'APK col token di App Check, ordine chiuso del 27 luglio

Eseguito da Claude Code il 27 luglio 2026, notte.
Ramo `claude/esoteric-circle-master-order-e798aj`, testa di partenza `b9c1185`.

### APK

`build\app\outputs\flutter-apk\app-arm64-v8a-debug.apk`, 228.770.276 byte, cioe'
218,2 MiB. Dentro la finestra chiesta, sopra i 20 MB e sotto i 250 MB. Il peso
alto viene dagli asset a bundle dei mazzi, non dal codice.

Costruiti nello stesso passaggio anche gli altri due tagli dello split per ABI:
`app-armeabi-v7a-debug.apk` da 204.717.048 byte e `app-x86_64-debug.apk` da
215.974.282 byte. Quello da installare sul telefono e' l'arm64.

Il token fissato e' davvero dentro il binario, verificato e non dedotto:
estraendo `assets/flutter_assets/kernel_blob.bin` dall'APK arm64 e cercandoci
dentro `2f4013f2-e6e7-49b2-a3aa-402f28cd365a` si trova una occorrenza. La
`--dart-define` e' arrivata a destinazione, quindi al primo avvio l'app presenta
il token gia' registrato in console e non uno generato a caso.

### I test chiesti

Otto casi nuovi in `test/app_check_debug_test.dart`, tutti verdi. Scritti prima
del codice e visti rossi, col rosso che nominava le API mancanti.

I tre chiesti dai criteri di accettazione:

1. In debug la striscia compare e il testo mostrato e' il token: uguale a quello
   registrato, lungo trentasei caratteri, conforme alla forma UUID verificata
   con una espressione regolare. Il test controlla anche che la striscia stia
   SOPRA la schermata e non al suo posto.
2. In release la striscia non compare: nessuna chiave della striscia, nessuna
   chiave del testo, nessuna traccia del token in nessun punto dell'albero. Lo
   stesso e' verificato per la riga delle Impostazioni.
3. Col token fissato valorizzato, il token usato e' esattamente quello: viene
   restituito, finisce nelle preferenze, vince anche quando nelle preferenze
   c'e' gia' un token diverso salvato da un avvio precedente. Senza costante il
   comportamento resta quello di prima, cioe' un UUID nuovo e stabile fra le
   chiamate.

Gli altri cinque coprono il tocco che copia negli appunti con la conferma che se
ne va da sola, la chiusura che non fa tornare la striscia, il ripiego che legge
il token dalle preferenze quando App Check non si e' attivato, la presenza della
riga in fondo alle Impostazioni e la regola pura della visibilita' interrogata
nei due versi.

### Suite e analisi

`flutter test`: 773 test, tutti verdi. Erano 765 prima di questo ordine, quindi
gli otto nuovi si sommano senza rompere nulla.

`flutter analyze`: No issues found, zero nuovi avvisi.

Le anteprime in `docs/preview/` non sono cambiate: `git status` su quella
cartella e' pulito dopo la corsa della suite. Era il rischio principale del
lavoro a video, perche' `kDebugMode` e' vero anche sotto `flutter test`, quindi
una striscia legata direttamente a quella costante sarebbe comparsa in ogni
cattura. La visibilita' passa invece dal campo `showAppCheckDebugToken` di
`AppServices`, acceso solo dai servizi reali fuori dalla release e spento nei
servizi offline che usano i test e le catture.

### Cosa e' andato storto nella build Android

Due fallimenti prima del successo, per un solo guasto a monte, nessuno dei due
causato dal codice di questo ordine.

`record 5.2.1` vincola `record_linux` a `>=0.5.0 <1.0.0` ma lascia libero
`record_platform_interface` a `^1.2.0`. La risoluzione accoppia quindi
`record_linux 0.7.2` con un'interfaccia 1.5 o superiore, che nel frattempo ha
aggiunto `startStream` e ha dato a `hasPermission` un argomento denominato in
piu'. La 0.7.2 non li implementa, quindi la classe `RecordLinux` risulta
incompleta.

Il punto che rende il guasto fatale anche su Android e' il registrant dei plugin
generato da Flutter, `.dart_tool/flutter_build/dart_plugin_registrant.dart`, che
importa i pacchetti di TUTTE le piattaforme, Linux compreso. Quel codice si
compila anche quando il bersaglio e' Android, quindi la build cade su
`kernel_snapshot_program` prima ancora di arrivare a Gradle.

Il primo tentativo di correzione era sbagliato: abbassare
`record_platform_interface` alla 1.5.0 non serve, perche' la 1.5.0 contiene gia'
entrambi i cambiamenti. La misura del rosso lo ha mostrato subito, con lo stesso
errore e il numero di versione cambiato nel percorso del file.

La correzione buona agisce sul pezzo giusto: `record_linux` portato a 1.3.1, che
dichiara `record_platform_interface: ^1.5.0` e quindi l'interfaccia la
implementa davvero. E' l'unico `dependency_overrides` del progetto, documentato
in `pubspec.yaml` con la ragione e con la condizione per toglierlo. Su Android e
iOS non cambia niente, perche' li' l'implementazione in uso e' `record_android`
oppure `record_darwin`. Il Rito del Soffio non e' toccato.

Un difetto vero e' emerso dalla suite, non dalla build: il testo della riga delle
Impostazioni portava una virgola seguita dalla congiunzione, vietata dalle regole
ferree: `test/language_rule_test.dart` lo ha fatto cadere. Corretto spezzando la
frase in due.

Da segnalare senza agire, perche' fuori dallo scope di questo ordine: la build
avverte che sei plugin applicano ancora il Kotlin Gradle Plugin, cioe'
`camera_android_camerax`, `cloud_functions`, `firebase_ai`, `firebase_app_check`,
`record_android` piu' `sensors_plus`. Avverte anche che le prossime versioni di
Flutter non costruiranno piu' un'app che li usa.

### Cosa NON e' stato fatto

`docs/STATO_VIVO.md` non e' stato toccato, come chiesto. Va aggiornato insieme
dopo la prova sul telefono, quando si sapra' cosa funziona davvero.

Il punto 1 dell'ordine non ha richiesto nessuna modifica: `android/app/google-services.json`
era gia' in `.gitignore` alla riga 146 e `git ls-files` non lo elenca, quindi non
e' mai entrato in un commit.

Le sette voci sugli entitlement di `ORDINE_ENTITLEMENT.md` restano intatte, da
eseguire dopo.
