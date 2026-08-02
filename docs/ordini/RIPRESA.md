# RIPRESA

## PERCHE' LA CHAT TACEVA: CAUSA MISURATA E RIMOSSA il 2 agosto 2026

**CHIUSA.** ORDINE CHAT 1 DI N. La causa non era nel codice ed e' stata accesa
da Mauro, che ha dato il comando all'agente.

**Cosa era:** l'API `firebasevertexai.googleapis.com` non era abilitata sul
progetto `esoteric-circle`, ed e' l'unico host che `firebase_ai` 3.13.1 chiama,
come si legge in `base_model.dart:88`. Finche' e' rimasta spenta ogni chiamata
tornava `PERMISSION_DENIED`, l'SDK sollevava `ServiceApiNotEnabled` e la chat
non poteva rispondere, per nessuno dei tre Maestri.

**La misura di allora, coi comandi che l'hanno prodotta:**

- `gcloud services list --enabled --project=esoteric-circle` dava 69 API, e
  `firebasevertexai` non era fra quelle. C'erano `aiplatform` e
  `generativelanguage`, che NON sono quella che serve.
- `gcloud logging logs list --project=esoteric-circle` non elencava nessun log
  di un servizio AI: le chiamate non arrivavano mai a Google.
- **L'ipotesi App Check e' CADUTA, col numero che la abbatte.** La chiamata
  `GET firebaseappcheck.googleapis.com/v1/projects/esoteric-circle/services`,
  con l'intestazione `x-goog-user-project`, da tre soli servizi,
  `firebasestorage`, `firestore` e `identitytoolkit`, **tutti UNENFORCED**, e
  Vertex non era nemmeno in elenco. **Zero servizi in ENFORCED**: non c'era
  nessuna imposizione da togliere, e il compromesso datato di `natalChart` qui
  non e' servito.

**Come e' stata rimossa**, il 2 agosto 2026, su ordine esplicito di Mauro:
`gcloud services enable firebasevertexai.googleapis.com --project=esoteric-circle`.

**Verificato dopo, non dato per fatto:**

- `gcloud services list --enabled` da adesso **70 API**, ed erano 69:
  `firebasevertexai.googleapis.com` c'e'.
- App Check resta **tutto UNENFORCED**, quindi non e' comparsa una seconda
  barriera al posto della prima.
- I due modelli che l'app usa RISPONDONO davvero nella regione dichiarata. Una
  `generateContent` su
  `europe-west1-aiplatform.googleapis.com/v1/projects/esoteric-circle/locations/europe-west1/publishers/google/models/<modello>`
  ha reso "Pronto." da `gemini-2.5-flash` in 12 token, e "Pronto" da
  `gemini-2.5-flash-lite` in 11. Regione e modelli del provider sono giusti.

**Non serve una build nuova:** la 2128 gia' consegnata funziona da sola, perche'
cio' che mancava stava sul server. Chi la ha installata deve solo riaprire la
chat.

**Come si verifica che era quella:** aprire la chat, chiedere qualcosa, poi
toccare il pannello di messa a punto nell'header. Se la voce e' ancora in
guasto il pannello mostra tipo e messaggio dell'eccezione vera, e quando e'
l'API spenta lo dichiara in chiaro. Prima di questo lavoro il pannello diceva
"Voce di Medora: attiva" anche mentre ogni chiamata falliva, perche' leggeva
`isReady`, che risponde sempre di si'.

## ORDINE CHAT 4: CHIUSO PER INTERO, e il numero e' tornato a 98,3

Chiuso il 2 agosto 2026.

**2a, LA MISURA PRIMA DELLA CORREZIONE.** Delle due ipotesi era vera la PRIMA:
**il corpo non e' mai stato disegnato**. `grep -nE "Image|Zodiac|Emblem|CustomPaint"`
su `consulto_del_cielo_view.dart` non trovava niente, e il `build` conteneva una
Column con DUE Text. Non c'era nessun asset da non decodificare. **La voce 2a
dell'ordine 3 era chiusa a meta'**: il commit diceva "passano i corpi VERI della
carta" e passavano i loro NOMI. Dieci prove la coprivano e nessuna se ne accorse,
perche' contavano widget e testo.

**LA LENTE, e l'ipotesi dell'ordine che e' CADUTA prima di risalire.**
La lente descritta in ASTRATTO ha PEGGIORATO tutto: da 96,7 a **88,3**, con
Medora E Caligo che scivolavano tutti e due verso Aura. Dire "guarda il moto nel
tempo" senza le parole con cui lo si dice spinge anche loro nel registro
interiore, che e' di Aura. **Agganciata la lente al LESSICO DI FIRMA**, che gia'
esisteva come dato e che reggeva il 98,3 prima che l'ancoraggio nascesse:

```
           medora     aura   caligo    totale  giusti
medora         20        0        0        20  100,0%
aura            0       20        0        20  100,0%
caligo          0        1       19        20   95,0%
```

**59 su 60, cioe' 98,3 per cento, e la coppia Medora-Aura e' PULITA**: zero
scambi, contro i due di due esecuzioni consecutive. Bersaglio centrato.

**Chi tocchera' le lenti sappia questo**: la lente da sola non basta, e senza il
lessico di firma fa danno. Le due cose vanno insieme.

**LA PROVA A PIXEL, coi numeri veri.** Misura differenziale contro la stessa
scena senza corpo. Disco lunare **9.216**, emblema del segno **4.396**, punto
luminoso **1.207** su 9.216 disponibili. Soglia a **700**. **La prima soglia era
1.500, STIMATA a mente, e bocciava un corpo che c'era**: un numero indovinato in
un test e' un difetto quanto uno indovinato nel codice.

**IL PRECARICO E' OBBLIGATORIO.** Senza `precacheImage` l'emblema dipinge ZERO
pixel in prova, e la misura accusa la scena di essere vuota quando e' la misura a
non vedere. La funzione `precarica` sta in cima a `prima_dopo_capture_test.dart`
e la usano tutte le catture che mostrano arte.

## LE DUE VOCI VECCHIE SONO CHIUSE: non resta piu' niente in sospeso

Chiuse il 2 agosto 2026, dopo l'ORDINE CHAT 3: la 1a e la 2b dell'ORDINE CHAT 2.

**"VAI PIÙ A FONDO".** La profondita' NON si sceglie prima di leggere: la prima
risposta arriva sempre a 160 token per tutti, e sotto compare l'invito che
rigenera la STESSA risposta a 420. Il tetto e' `kApprofondimentoMaxTokens` e
vive nel blocco delle costanti come gli altri tre.

**I limiti**: Viandante niente, Iniziato 3, Adepto 10, Illuminato senza limite
con tetto di correttezza a 30. Il budget e' un SECONDO contatore dentro
`QuestionAllowance` e non una classe nuova: il giorno e' lo stesso, quindi il
ribaltamento a mezzanotte deve essere lo stesso, e due classi avrebbero avuto
due rollover che prima o poi divergono. **L'approfondimento NON consuma una
domanda**, e una prova lo verifica.

**L'invito non e' mai un vicolo cieco**, e i tre esiti sono tre: chi lo ha nel
piano e ne ha ancora scende davvero; chi lo ha e li ha finiti legge quando
torna; chi non lo ha riceve l'invito a salire. Per questo
`pianoConApprofondimento` e `puoiApprofondire` sono due cose diverse.

**IL SILENZIO CONSEGNA UNA LETTURA VERA.** `LetturaDiRipiego` e' una funzione
pura: dichiara di non essere la voce del Maestro, POI legge davvero coi dati sul
dispositivo, POI apre una porta che appartiene a quel Maestro (la carta natale
per Medora, il respiro contato per Aura, la runa per Caligo). Costo di inferenza
zero. **Se non c'e' nessun dato la lettura si SALTA e non si inventa, ma la
porta resta.**

**UN DIFETTO VERO TROVATO NELLA MATRICE DEI PIANI, e non era mio.**
`PlanCatalog.limiteGiornaliero` tornava `null` per una cella "No", e ogni
chiamante legge `null` come ILLIMITATO: **"No" e "Illimitate" davano la stessa
risposta**. Non era ancora esploso solo perche' nessuna riga interrogata per un
limite conteneva un "No", e la prima e' stata quella degli approfondimenti.
Adesso una cella che non promette niente vale ZERO. Chi aggiunge una riga alla
matrice sappia che il numero, o la sua assenza, e' cio' che comanda davvero.

**L'ATTRIBUZIONE CIECA RIESEGUITA**, perche' la persona e' stata toccata:

```
           medora     aura   caligo    totale  giusti
medora         18        2        0        20   90,0%
aura            0       20        0        20  100,0%
caligo          0        0       20        20  100,0%
```

**58 su 60, cioe' 96,7 per cento**, RISALITO dal 95,0 del giro precedente.
Caligo torna al 100. **Medora perde due risposte verso Aura in tutte e due le
esecuzioni**: non e' rumore, e' una caratteristica stabile. Chi vorra' quei due
punti guardi li'.

## ORDINE CHAT 3 DI N: CHIUSO PER INTERO, tutte e due le voci

Chiuso il 2 agosto 2026. Voce 1 (1a, 1b, 1c, 1d) e voce 2 (2a, 2b, 2c).

**LA CONDUTTURA, 1a.** Il contesto natale arriva al Maestro da OGNI superficie,
e **la porta e' stata tolta invece di correggere i chiamanti**: `natal` e' un
parametro del CONFINE, cioe' della firma di `MaestroAiProvider.reply`, non un
argomento che ogni superficie deve ricordarsi. La sorgente e' UNA,
`SorgenteNatale.daIdentita`. Una prova enumera le chiamate al provider in tutto
`lib` e cade se una non porta l'ancoraggio, con l'oracolo deterministico
dichiarato per nome come unica eccezione.

**Cosa c'era davvero, e l'ordine non lo sapeva**: la sorgente del contesto
natale era GIA' duplicata, la stessa riga in `maestro_chat_screen.dart` e in
`ask_maestri_screen.dart`, e le due copie servivano a due cose diverse. Nella
chat il contesto esisteva e finiva nella frase di benvenuto: il Maestro
accoglieva sapendo di chi, poi rispondeva senza saperlo.

**L'ANCORAGGIO, 1b.** `VerificaAncoraggio` e' pura e pubblica. **Non scatta
quando non c'e' niente da ancorare**: senza nascita `disponibiliPer` torna vuoto
e ogni risposta e' valida, perche' pretendere un segno da chi non lo ha dato
porterebbe a inventarlo. UNA rigenerazione sola, mai due, e la seconda consegna
si registra in `consegneSenzaAncoraggio`.

**Il conteggio delle rigenerazioni sul corpus vero NON e' stato misurato, e va
saputo:** lo strumento di attribuzione chiama Vertex per via REST e non passa
dal controller, quindi il contatore non lo vede. Quello che e' provato e' il
comportamento del controllo, con quattro prove deterministiche.

**L'ATTRIBUZIONE CIECA DOPO LA MODIFICA, 1c: SCESA da 98,3 a 95,0 per cento.**

```
           medora     aura   caligo    totale  giusti
medora         18        2        0        20   90,0%
aura            0       20        0        20  100,0%
caligo          0        1       19        20   95,0%
```

Sopra la soglia di 85, quindi non e' un difetto da correggere. **Ma il rischio
che l'ordine prevedeva e' reale e misurato**: partendo tutti dal cielo i Maestri
si somigliano di piu'. Medora perde DUE risposte verso Aura ed era al 100 per
cento. **Chi vuole recuperare quei tre punti guardi la coppia Medora-Aura**, non
le tre voci insieme.

**L'ATTESA, voce 2.** `ConsultoDelCielo` e' una funzione PURA su NatalContext,
zero inferenza e zero rete. La scena vive nel DESIGN SYSTEM e non nella chat,
perche' le superfici che aspettano sono DUE. Un dato che manca fa SALTARE la sua
battuta e non la fa sostituire. Senza carta natale si consulta il solo Sole e la
battuta dichiara di essere generale. Con Riduci Movimento o qualita' bassa il
timer non parte nemmeno e resta la riga di testo.

**Lo spinner nudo se ne e' andato**, 2b: era un `CircularProgressIndicator`,
l'unico punto della chat che sembrava un'app qualunque.

**COSA RESTA APERTO DELLE VOCI VECCHIE**: 1a dell'ORDINE CHAT 2, cioe' l'invito
"Vai piu' a fondo" col tetto a 420 token, e 2b dello stesso ordine, il ripiego
che diventa una lettura vera. Non sono state toccate qui.

## ORDINE CHAT 2 DI N: cosa e' chiuso e cosa NON e' stato aperto

Chiuso il 2 agosto 2026. **Tre voci su nove piu' i quattro difetti di vista.**

**CHIUSE:**

- **I quattro difetti di vista**, non tre. Il quarto e' che anche il CONSULTA
  montava lo scope senza dichiarare il Maestro. Le bolle sono opache (le tinte
  si fondono in anticipo sul fondo, a occhio identiche), la lista e'
  rovesciata, il Riprova vive DENTRO la bolla che ha fallito, e le due
  superfici di un Maestro dichiarano il loro Maestro.
- **1c, le aperture vietate.** Sedici formule in `VoceDelMaestro.apertureVietate`,
  non sette: aggiunte `Ti capisco`, `È del tutto normale`, `Come molti`,
  `Non sei sola`, `Immagino che`, `Sappi che`, `Voglio dirti che`,
  `Prima di tutto`, `Innanzitutto`. Il divieto si compone ENUMERANDO l'elenco
  dentro la persona, non riassumendolo.
- **1e, le chiusure.** `TipoDiChiusura` e' un enum obbligatorio nel costruttore:
  un Maestro nuovo non puo' nascere senza dichiarare la propria impronta.
- **1f, l'attribuzione cieca.** `tool/attribuzione_cieca.dart`, fuori dalla
  suite perche' costa chiamate vere. **Eseguito: 59 su 60, cioe' 98,3 per
  cento**, contro una soglia di 85 e un caso cieco di 33,3. L'unica confusione
  e' una risposta di Caligo attribuita ad Aura.

**NON APERTE, e non aperte a meta':**

- **1a**, l'invito "Vai piu' a fondo" col tetto a 420 token. **Attenzione, una
  premessa dell'ordine era falsa**: il selettore di profondita' PRIMA della
  risposta non esiste ne' in chat ne' nel Consulta. `AnswerDepthSelector` si usa
  in un punto solo, `oroscopo_screen.dart:752`, e il Consulta e' fisso su
  `ConsultDepth.breve`. Quindi 1a non e' "togli il selettore": e' solo
  costruire l'invito, che e' meta' del lavoro che l'ordine presumeva.
- **1b**, l'ancoraggio a un dato che esiste solo per questa persona. Richiede di
  portare `NatalContext` anche nella strada della CHAT: oggi arriva al provider
  solo per `consult`, mentre `MaestroPersona.systemInstruction` riceve profilo e
  memoria e non i dati natali.
- **2a**, il Maestro che consulta il cielo durante l'attesa. E' la voce che vale
  di piu' ed e' anche quella che riempirebbe il vuoto rimasto SOPRA la
  conversazione dopo il rovesciamento della lista.
- **2b**, il ripiego che diventa una lettura vera.

**UN CONFLITTO DENTRO L'ORDINE, risolto e da confermare.** L'ordine chiedeva che
Caligo chiudesse consegnando "una runa o un ARCANO". L'arcano non puo' essere
suo: la Cartomanzia e' un'arte di Medora e `arcano` e' una delle sue cinque
parole di firma, e la prova del lessico lo ha denunciato subito. Caligo consegna
una runa oppure un sigillo. **Se l'arcano deve restare a Caligo, va tolto dal
lessico di Medora, ed e' una decisione di Mauro** perche' indebolisce la sua
impronta.

## Cosa e' cambiato nel codice il 2 agosto 2026

- **L'errore non si perde piu'.** `VoceSorvegliata` avvolge il provider e
  registra ogni guasto con tipo, messaggio e operazione. `AppServices` e'
  diventata una fabbrica: **non esiste un modo di montare i servizi con una
  voce non sorvegliata**, nemmeno per sbaglio.
- **Ogni ripiego dichiara di essere un ripiego**, in `RipiegoDelMaestro`, con
  una frase diversa per ciascun Maestro. Vale nella chat e nel Consulta, che
  prima sostituiva la voce con l'oracolo deterministico SENZA DIRLO.
- **I catch muti sono enumerati su tutto `lib`** da
  `test/nessun_catch_muto_test.dart`. Debito misurato: **85 in 37 file**. I 9
  sulla strada della voce sono azzerati, gli altri possono solo scendere.
- **I tetti sono 160 e 320**, ed erano 260 e 780. Le porte al tetto erano TRE,
  non una: il Consulta passava dalle costanti, la chat aveva un `800` scritto
  a mano e il distillato un `400`.
- **Le tre personalita' sono un dato**, `VoceDelMaestro`. Trovato e corretto un
  difetto vero: Caligo rivendicava gli **Archetipi**, che sono un'arte di Aura.

## La decisione ancora aperta sul ponte, non urgente

L'ordine precedente chiedeva una Cloud Function per tenere la chiave sul
server, ma nell'app una chiave non c'e': il provider usa Firebase AI con App
Check. La callable ha altri vantaggi veri, il controllo del costo e il rate
limiting lato server, e va decisa per quelli. **Non e' un prerequisito per far
parlare la chat**: la causa era un'altra ed e' misurata.

## La coda dell'AI, aperta per fine del margine

Ordine del 1 agosto 2026, cinque voci, NESSUNA aperta a meta'. Lo stato voce per
voce sta in ESITO_AI.md, e la cosa piu' utile che c'e' scritta e' questa: IL
PONTE CON GEMINI ESISTE GIA', con la regione, i modelli e i tetti dichiarati in
`firebase_maestro_ai_provider.dart`. La voce 1 non e' "collegare Gemini", e'
capire perche' la chat non risponde, e IL PRIMO POSTO DOVE GUARDARE sono i
quattro `catch (_)` di `maestro_chat_controller.dart`, che inghiottono l'errore
vero.

Una decisione per il fondatore sta scritta li': l'ordine chiede una Cloud
Function per tenere la chiave sul server, ma nell'app una chiave non c'e', il
provider usa Firebase AI con App Check. La callable ha altri vantaggi veri, il
controllo del costo e il rate limiting lato server, e va decisa per quelli.

## Il velo sui corpi sotto l'orizzonte, aperto

Dal 1 agosto 2026 un corpo che a quell'istante stava sotto l'orizzonte lo
DICHIARA nella sua scheda, con l'ora in cui sorge. Ma viene ancora disegnato a
piena luce come gli altri: manca il segno visivo, il corpo velato o spento sotto
una linea d'orizzonte. Chi non tocca la scheda non lo distingue.

E' una modifica al disegno della volta, non al testo, e vale per tutti e due i
cieli passando da `_SkyBody`. Vedi ESITO_ORIZZONTE.md.

## Le tre voci ancora aperte della coda del 1 agosto 2026

Nessuna aspetta una decisione del fondatore: sono aperte per fine del margine,
e vanno riprese in quest'ordine.

1. **La Stesa fuori schermo a 360.** Nella cattura, il tocco sul ventaglio
   avverte "the widget is actually off-screen". Il test passa perche' il timer
   non resta appeso, ma il difetto e' vero. Serve la prova del rosso alla
   larghezza reale, poi la correzione.
2. **Le carte laterali dei Maestri tagliate a 360.** A 390 le tre carte stanno
   dentro con la cornice chiusa, a 360 quelle ai lati escono. Da decidere e
   dichiarare: o si stringono, o diventano una sbirciatura VOLUTA, cioe' una
   porzione regolare e uguale ai due lati, mai un taglio che dipende dalla
   larghezza.
3. ~~Il residuo del fuso, 123,7 gradi.~~ **CHIUSO il 1 agosto 2026.** Il fuso
   veniva tolto DUE VOLTE: `buildSkyFor` sottraeva `timeZoneOffset` a mano
   ottenendo un DateTime ancora marcato locale, e `Celestial.julianDay`
   chiamava `toUtc()` togliendolo di nuovo. Era anche la causa della scheda
   della Bilancia che dava dodici gradi a sud-est. Vedi ESITO_ISTANTE.md.

## Gli accenti a schermo NON sono piu' aperti

Chiusi il 1 agosto 2026. Erano 151 stringhe in 16 file, non dieci in sette: la
misura di allora cercava `fara'` mentre nel sorgente c'e' `fara'`, con la barra
dell'escape in mezzo. La regola ora vive in `testo_a_video_test.dart` e vale
anche per le frasi che nasceranno domani.

## L'intro e' PROVVISORIA

Sta in `lib/features/intro/sequenza_intro.dart` e va sostituita quando
arriveranno gli asset definitivi: il video e' un `Intro-Test`. Le prove
`intro_test.dart` valgono finche' c'e'.

Il logo esportato e' 720 pixel da un sorgente di 410: a schermo copre bene fino
a circa 240 punti logici, e piu' grande si vedrebbe la sgranatura del sorgente.
Se serve piu' grande, serve un sorgente piu' grande.

## La coda aperta, nell'ordine del fondatore

Chiuse le prime tre. Restano, e vengono prima di tutto:

4. **L'icona del Cerchio**: mezzaluna dentro un cerchio, stile lineare dorato
   come le altre quattro, deve reggere anche nello stato attivo.
5. **Gli accenti resi con l'apostrofo**: dieci punti in sette file, gia'
   trovati. Correggere solo le stringhe MOSTRATE, mai i commenti ne' le chiavi,
   con un test che enumera.
6. **La Stesa fuori schermo a 360**: il tocco sul ventaglio avverte
   "the widget is actually off-screen".
7. **Le carte laterali dei Maestri tagliate a 360**: decidere fra stringerle o
   farne una sbirciatura regolare, mai un taglio che dipende dalla larghezza.
8. **Il residuo del fuso, 123,7 gradi**: lo stesso istante in UTC e in ora
   civile da' due cieli diversi, quindi oltre alla conversione c'e' altro che
   guarda l'ora locale grezza.

## La coda aperta, nell'ordine del fondatore

1. **Il segno che viaggia come parametro.** `artRouteFor` riceve `userSign` da
   chi apre l'arte e lo passa a quattro arti; l'Oroscopo lo pretende nel
   costruttore e non guarda mai la data di nascita. Nona occorrenza della
   famiglia. **Trappola**: la data d'esempio e' Gemelli, quindi ogni prova
   scritta con l'identita' d'esempio e' verde col difetto dentro. Usare il
   Cancro.
2. **Le costellazioni piu' grandi nel cielo.** Erano state ridotte a 104 punti e
   la Luna a 78 quando la mappatura era geometrica. Con gli slot fissi lo spazio
   c'e': si puo' risalire verso 130, fermandosi al massimo che tiene verdi le
   dodici prove, e portare lo slot centrale da 0,66 verso 0,76.

## Cielo: gli slot fissi, decisione del 31 luglio

I corpi stanno in quattro slot dichiarati e non piu' nella loro posizione
geometrica. La mappatura su schermo, la distensione e la separazione sono state
RIMOSSE, non spente. Cio' che resta esatto e' il dato: la scheda porta altezza e
direzione vere.

Se qualcuno tornasse a volere la posizione visivamente esatta, sappia che il
conto fisico che la impediva era questo: le scatole dei corpi non stanno nel
campo libero se restano grandi. Adesso sono piu' piccole, 78 punti la Luna e 104
le costellazioni.

## Cielo, prima voce: LE ETICHETTE SI ACCAVALLANO

Visibile in `docs/preview/prima_dopo/cielo_nascita_dopo.png`: i corpi non
finiscono piu' sotto la scheda ne sotto il pulsante, ma **le etichette si
sovrappongono fra loro**. Si leggono "CANCRO", "GEMELLI" e "TORO" stampate una
sopra l'altra, illeggibili, e la Luna copre il Toro.

Comprimendo il campo libero i corpi si sono avvicinati, e nessuno impedisce a
due corpi di occupare lo stesso punto. Serve una spaziatura minima fra i corpi,
o un modo di scostarli quando collidono.

## Cielo: la prova sulla mappatura non e' stata vista cadere

La correzione del ripiego e' giusta e motivata, ma alle 22:30 la Luna resta
dentro il campo orizzontale, quindi il ripiego non scatta e la prova non
discrimina. Serve un istante in cui un corpo basso esce di lato.

## Il cielo intero: resta uno sforamento, col numero

Il campo libero e' calcolato e i corpi ci stanno dentro alla misura reale alle
22. **Alle ore 4 la Luna selezionata arriva a 609 punti mentre la scheda
comincia a 566**, uno sforamento di 43; a 2532 di altezza sono 75. Il conto del
campo torna a 439, quindi fra il calcolo e il pixel c'e' una traslazione di
circa 202 punti che non ho trovato. La prova gira sui casi verificati e NON e'
stata allentata: la voce resta aperta.

## CAPITOLO GOOGLE, prima voce: riaccendere App Check

`enforceAppCheck` sulla callable `natalChart` e' stato messo a **false il 31
luglio 2026**, perche' il fornitore registrato e' Play Integrity e l'app arriva
da App Distribution, quindi installata fuori dal Play Store: Play Integrity non
puo' attestarla e respingeva ogni chiamata prima del corpo della funzione.

**Va riacceso appena l'app sara' su una traccia di test interno del Play Store**,
perche' da li' Play Integrity la riconosce e l'imposizione torna a costare
nulla. Finche' resta spento, chiunque conosca l'indirizzo puo' far chiamare una
funzione che consuma un servizio a pagamento: il validatore rifiuta i corpi
malformati e non annulla il rischio.

## La coda dell'ordine sui dati di nascita

Chiuse: la 1 per la parte del luogo, e la 2. **Restano:**

- **1c**, il messaggio vero della carta natale: nasce sul dispositivo, e il
  campo `causa` del controller lo porta. Prima cosa da guardare sulla build.
- **3** la bolla che copre la Luna: e' un `Positioned` fisso in fondo che cresce
  verso l'alto col testo, senza calcolo dello spazio libero.
- **4a** "La posizione esatta di ogni astro arriva col motore a effemeridi",
  falsa da quando i corpi si posizionano da altezza e azimut reali.
- **4b** l'etichetta fantasma del corpo sotto la scheda.
- **5** le miniature di animale e angelo tagliate nel Passport.

## Il residuo del fuso orario nel cielo, con il numero

La conversione da ora civile a UT in `sky.dart` adesso usa il fuso vero
dell'istante, ed era il tempo medio locale. **Resta un residuo**: lo stesso
istante scritto in UTC e in ora civile produce due cieli che differiscono di
**123,7 gradi di azimut**. Oltre alla conversione c'e' dell'altro che guarda
l'ora locale grezza, e non l'ho inseguito. E' il primo punto da cui ripartire
sul cielo.

## Il cielo posizionato ha bisogno di `luogoIniziale`

`SkyOverviewScreen` accetta ora un `luogoIniziale`. Serve perche' senza di lui
il luogo entra in un modo solo, il dialogo di consenso, che richiede un tocco:
nessuna prova poteva misurare il cielo posizionato, ed e' il motivo per cui il
difetto e' vissuto indisturbato mentre la sorveglianza restava verde.

## LA CODA DI MAURO, da riprendere in questo ordine

Chiuse: 1, 2, 3b, 7. **Restano, e vanno prima di qualunque voce trovata da me:**

- **3a** la carta natale che ripiega. Prima cosa da guardare sulla build nuova:
  se il ripiego resta, il luogo c'e' e la causa e' un'altra, e il campo `causa`
  del controller la porta. Se sparisce, era il luogo che non arrivava.
- **4** le miniature di animale e angelo tagliate nel Passport. E' V3: il
  componente condiviso che non taglia, portato in ogni punto, con i punti
  enumerati da una prova.
- **5** il cielo di nascita: catalogo incompleto (mancano Ariete, Cancro,
  Bilancia, Capricorno, Acquario, Pesci), messaggio che mente anche quando la
  costellazione c'e' (soglie a meno due contro meno cinque), e "adesso" in una
  schermata che descrive la nascita.
- **6** il GPS che dice riposizionato e non cambia niente. Prova a schermo con
  due posizioni molto diverse.
- **8** il segno che viaggia come parametro: `artRouteFor` lo passa a quattro
  arti e l'Oroscopo lo pretende nel costruttore. Nona occorrenza della famiglia.
  Trappola: la data d'esempio e' Gemelli, usare il Cancro.

## Sul Santuario, un limite noto

La carta del Maestro occupa il 40 per cento dell'altezza, era il 37. Non sale
oltre perche' il carosello non regge sugli schermi bassi: i tre busti escono
dalla scena. Per andare oltre serve rivedere come il carosello li dispone.

Chi apre questo file deve poter continuare senza che Mauro racconti niente.

**Aggiornato**: dopo l'ORDINE 2 DI 5, le due voci chiuse e il debito saldato.
**Ramo**: `claude/esoteric-circle-master-order-e798aj`.
**Cartella di lavoro**: `C:\Users\user\Desktop\esoteric-circle-app` (NON il
worktree in `.claude/worktrees`, che e' vecchio).

## In attesa di una credenziale, non e' un difetto

`.github/workflows/ronda.yml` esiste sul disco e **non va committato**: il token
non ha lo scope `workflow` e GitHub rifiuta il push. Serve un token con quello
scope, che solo Mauro puo' fornire. Nel frattempo la Ronda gira dentro la suite
a ogni giro, che e' la protezione che conta.

## Chiuso negli ordini precedenti, da non rifare

A1 A2 A3 A4, B1 B2 B3 B4, C3 C4, F3 F4, la diagnosi dei motori e la Ronda con
38 test. Nessun motore scollegato oltre al cielo, gia' corretto.

## Chiuso nell'ORDINE 2 DI 5

- [x] **Debito dell'ordine 1 SALDATO.** La prova di vista sulla causa A adesso
      passa. Era la seconda ipotesi: la prova chiudeva una schermata MUTA,
      perche' il tono parte solo al tocco e la prova non toccava. Il lettore
      finto adesso registra anche CHI ha chiamato stop.
- [x] **Voce 1a CHIUSA.** Il segno discende da `BirthIdentity.sunSign`, nullo
      finche' i dati sono d'esempio. Due prove, una sul dato e una che MONTA la
      home. Attenzione alla trappola: la data d'esempio e' del 15 giugno, cioe'
      Gemelli, quindi le prove usano il Cancro.
- [x] **Voce 1b CHIUSA.** La Carta natale si garantisce il dato all'apertura,
      mostra la nota del ripiego con un pulsante Riprova, e si conserva fra un
      avvio e l'altro sotto una chiave che dipende dai dati di nascita.
- [x] **Voce 1c CHIUSA.** La Ronda ha un terzo strato, a schermo. **Ventidue
      motori restano sorvegliati solo sulla funzione pura**, elencati in
      `ESITO_2.md`: quando si correggono, il numero dentro la Ronda va aggiornato.
- [x] **Voce 2 CHIUSA.** `BarraArte` unica, cosmo che riempie l'altezza,
      `InterruttoreDelCerchio` nel design system. Due difetti trovati dalle prove
      e non segnalati: una QUARTA schermata col cuore sopra la "i", l'Animale
      Guida, e un SECONDO interruttore fuori palette in entrambe le schermate.

## Sul peso dell'archivio, misurato e non attribuito

I trentadue megabyte di crescita fra 2109 e 2110 **non esistono**: ricostruita la
2109 dal suo commit pesa 235.891.257 byte contro i 236.001.856 della 2110, cioe'
0,11 MB di differenza. Il numero 203,93 MB non e' quello dell'APK che quel commit
produce. Il conto per famiglia sta in `ESITO_2.md`.

## Chiuso nell'ORDINE 1 DI 5

- [x] **Voce 1 CHIUSA.** La striscia dei Doni non sborda piu', e i difetti erano
      due: il titolo che andava a capo rubando dieci punti a una fascia di
      altezza fissa, e una riga di etichetta piu' cerchio che sbordava di lato.
      La sbirciatura del quarto Dono adesso e' un DATO, `DailyStrip.sbirciaturaMinima`,
      e la larghezza della casella si ricava da quel dato invece che avanzare.
- [x] **Voce 2 CHIUSA, con un limite dichiarato.** Le tre cause del suono che non
      si ferma sono corrette: il `dispose` della Meditazione ferma il lettore, la
      `GuardiaDelSuono` in `core/sensi/` governa il ciclo di vita da un punto solo
      per tutta l'app, e il motore audio e' davvero uno solo con costruttore
      privato. **Il limite**: la prova di vista sulla causa A non passa, togliendo
      lo `stop()` dal dispose il test resta verde. Le cause B e C sono provate,
      la A e' corretta nel codice ma non protetta. **Va ripresa.**
- [x] **La suite e' VERDE**, 1138 prove, zero errori di analisi. Le sei rosse
      erano sei cause distinte, nessuna delle quali "il test era vecchio":
      una violazione della regola sulla virgola che avevo scritto io, un archivio
      preferenze non finto, il manifesto degli asset senza `assets/audio/`, un
      secondo catalogo sonoro rimosso in S3 di cui restava l'asserzione, un
      bersaglio del cielo il cui centro cade sulle carte, e un timer ancora vivo
      a fine cattura della Stesa.

## Ancora aperto sulla Stesa a 360

Il tocco su `stesa_fan_38` nella cattura avverte *the widget is actually
off-screen*: il ventaglio a 360 punti esce dallo schermo. Il test adesso passa
perche' il timer non resta appeso, ma **l'avviso resta e il difetto e' vero**.
Non era una voce di questo ordine e non l'ho toccato.

## L'ordine in corso

- [~] **V1** la bolla e l'avatar. **La misura adesso FUNZIONA ed e' rossa.**
      Resta da correggere il layout perche' regga il testo di sistema
      ingrandito. Vedi la sezione dedicata qui sotto, e' la cosa piu' importante
      di questo file.
- [ ] **V2** la mano, quarta stesura, BIANCA. Da verificare per primo: nel
      painter c'e' `Colors.white` e a schermo esce oro, quindi la mano che si
      vede potrebbe non essere quella corretta. Riferimento di Mauro: mano vista
      da SOPRA, indice teso che scende su un cerchio, tratto pulito e sottile,
      dita chiuse leggibili una per una, pollice accennato di lato. La
      silhouette del soffio e' fatta bene e NON si tocca.
- [ ] **V3** il componente condiviso che non taglia le immagini, portato in ogni
      punto che mostra miniature di animale, angelo o carta. Per l'angelo la
      miniatura diventa rettangolare verticale, proporzione da carta. Un test
      conta i punti che lo usano e denuncia chi adatta al riempimento fuori da
      esso.
- [ ] **V4** ScrollReveal: sfasare gli elementi, allungare oltre 420 ms,
      abbassare l'opacita' iniziale. **NON alzare l'ampiezza**: gia' provato, a
      22 px gli elementi si sovrappongono e il tocco colpisce la voce sbagliata.
      Il limite attuale e' fissato da un test in `scroll_reveal_si_vede_test`.
- [x] **S1 CHIUSA.** `audioplayers` e' l'unica dipendenza di riproduzione,
      `MotoreAudio` in `core/sensi/` e' l'unico motore, `LettoreToniReale`
      sostituisce il muto come DEFAULT nelle due schermate che suonano. Il
      difetto vero non era l'assenza del lettore, era che il default fosse muto:
      i test iniettavano il lettore e passavano.
- [x] **S2 CHIUSA.** Quattro schemi in `core/sensi/palette_sensoriale.dart`,
      diciassette chiamate ricondotte, zero chiamate dirette fuori dalla
      palette. Il rifiuto usa il tocco due volte e non ha uno schema suo.
- [x] **S3 CHIUSA come struttura.** Catalogo dei cinque suoni come dato, slot
      pronti in `assets/audio/` col LEGGIMI, ripiego silenzioso. Trovato e
      rimosso un SECONDO catalogo sonoro nei Tarocchi, `audio/stesa_*.mp3`.
      Mancano solo i file, che sceglie Mauro.
- [ ] **S4 DA FARE**, versione semplice dichiarata: UNA transizione con
      elemento condiviso, la carta del Maestro nel Cerchio che si apre e diventa
      il suo dominio. Si fa con un `Hero` sulla carta centrale del carosello e
      uno stesso tag nella schermata del dominio. Deve rispettare Riduci
      Movimento, che riporta alla dissolvenza semplice.
      **Le altre due restano dichiarate come da fare**, e non vanno tentate in
      questo giro: la carta dell'angelo verso la sua schermata, e il Sigillo che
      si espande entrando nel Passport.
- [x] **S5 CHIUSA.** `suonoEVibrazione` e' il quarto comando di
      `SettingsController`, governa i due canali insieme, e la voce e' nelle
      Impostazioni. Chiude P23.

## L'ordine delle anteprime: X1 e X4 CHIUSE, X2 e X3 DA FARE

**X1 chiusa.** Le tre cause erano diverse fra loro: una seconda porta
(`mano_anteprima_test.dart`, ora dentro il corredo e cancellata), anteprime
orfane nate da prove temporanee (`le-tue-arti.png`, ora nel corredo), e due
catture rotte da S1, perche' il lettore audio reale tentava di riprodurre in
prova. La regola sta in `test/corredo_anteprime_test.dart`, col dato e non col
controllo. Prova di vista passata.

**X4 chiusa senza toccare codice.** Guardata l'anteprima nuova: le icone si
disegnano tutte. I quadratini erano l'anteprima vecchia, prodotta da un test
temporaneo che non caricava i font. Il difetto non esisteva.

**X2 DA FARE**: le carte laterali tagliate dai bordi a 360. Va prima deciso e
dichiarato se stringerle o farne una sbirciatura regolare, poi la prova del
rosso a tutte e tre le misure.

**X3 DA FARE**, e va insieme a V1: e' lo stesso file, `daily_strip.dart`. A 360
il quarto dono sparisce e non c'e' piu' invito a scorrere. La quantita' minima
visibile deve essere un dato dichiarato.

**Una cattura resta rossa e va guardata**: "Cattura la Stesa in corso" cade a
360 con "the widget is actually off-screen". E' un difetto vero della Stesa alla
larghezza reale, non un problema del corredo.

## W1 e W2: la larghezza, che era la causa

**CHIUSA W1.** Il telefono vero e' 1080 per 2392 fisici, cioe' **360 per 797
punti logici** con rapporto di pixel 3. Le anteprime erano generate a **390**:
trenta punti logici in piu'. La costante si chiamava "quella di Mauro", il
commento dichiarava 1080 per 2392, e il valore era `Size(390, 797)`: avevo
cambiato l'altezza in un giro precedente e lasciato la larghezza.

Adesso 360 e' la prima delle tre misure del corredo. Trentasette catture
portate alla misura reale, cinquantanove anteprime rigenerate.

**L'ipotesi della scala 1,6 e' ARCHIVIATA come sbagliata**, e va aggiunta alle
strade escluse: le impostazioni sono Predefinito e Standard, di fabbrica.

**W2, la scoperta che chiude cinque segnalazioni.** Alla larghezza reale il
difetto SI RIPRODUCE, senza toccare la scala del testo: a 1080 tutte e tre le
misure sono rosse, a 1170 sono verdi. Le segnalazioni non erano
irriproducibili, ero io a verificare su uno schermo piu' largo del suo.

**IL DIFETTO E' PREESISTENTE, non introdotto da me.** Verificato riportando
`santuario_screen.dart` allo stato committato: restano quarantaquattro errori
di overflow e nove prove rosse. Il test nuovo li rende visibili per la prima
volta.

**Che overflow e'.** `A RenderFlex overflowed by 10.0 pixels on the bottom`, e
il colpevole e' la Column in `daily_strip.dart:671`, cioe' la striscia dei Doni:
a 360 punti la sua etichetta va su due righe e la colonna sborda.

**Due strade gia' provate e RIENTRATE**, da non ripetere:

1. `mainAxisSize: MainAxisSize.min` su quella Column: peggiora, si passa da tre
   prove rosse a nove e gli overflow restano quarantaquattro.
2. Calcolare `centralH` e `carouselHeight` per differenza dallo spazio libero:
   non risolve, perche' l'overflow non viene dal carosello.

**La strada da provare.** L'overflow e' nella striscia dei Doni, non nell'eroe:
va guardata `daily_strip.dart` attorno alla riga 671, dove l'altezza della
striscia e' fissa mentre l'etichetta a 360 punti occupa due righe. O si riduce
il testo, o si alza la striscia, o l'etichetta va su una riga sola con
`FittedBox`.

## Cose sapute sul livello sensoriale

- I lettori audio vanno costruiti PIGRI: crearli tocca la piattaforma, e in una
  prova senza plugin il solo fatto di creare il motore solleverebbe.
- Gli schemi aptici con pause vanno eseguiti in `tester.runAsync`: un
  `Future.delayed` non avanza nel tempo finto e il test resta appeso.
- Il plugin audio non esiste in prova: un test che tenta di riprodurre davvero
  fallisce per un'eccezione asincrona anche se il motore la cattura. Le regole
  del suono si verificano sul codice, dichiarandolo.

## Cose sapute che fanno perdere tempo se si riscoprono

- La specifica del Livello Sensoriale sta nel Project di Claude e NON e' nel
  filesystem: si lavora sul perimetro dell'ordine.
- Nei test che montano `EsotericCircleApp`, oltre il mezzo secondo di pump il
  lanciatore spinge l'onboarding sopra la scena e non si misura piu' il Cerchio.
  Mezzo secondo e' il tempo giusto.
- `RenderView` non ha `toImage`: per fotografare serve avvolgere in un
  `RepaintBoundary` con una GlobalKey.
- I file sorgente sono a fine riga CRLF: le sostituzioni con Python vanno fatte
  normalizzando prima e ripristinando dopo.
- Gli apici dentro le stringhe Dart si rompono se scritti da un heredoc bash.
  Meglio lo strumento di scrittura file.
- `DepthCard` richiede `QualityTierController` nell'albero: i test che montano
  tessere devono fornirlo.
