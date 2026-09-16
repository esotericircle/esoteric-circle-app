# RAPPORTO DELL'ORDINE DQ

**Il Viaggio dello Sciamano si chiude per davvero, e l'app smette di essere
rifiutabile da Apple.** 15 e 16 settembre 2026, ramo
`claude/esoteric-circle-master-order-e798aj`. Segue l'ordine DO, build 2263.
Nell'ordine c'e' scritto "segue l'ordine DP, commit b885e2d, build 2262": sul
ramo la DP e' il commit `834606ef`, e dopo di lei e' venuto l'ordine DO con la
2263. Si e' lavorato sopra la 2263.

Nell'ordine della voce DQ.16: le premesse, le misure da A a G, le percentuali
prima e dopo la seconda chiamata coi motivi, il costo, i cinquanta asset, i
fotogrammi del velo, la prova a video, le purpose string, la validazione
dell'archivio, e la riga finale.

---

## 1. LE PREMESSE

Verificate prima di toccare il codice. Nessuna era falsa, quindi l'ordine
si e' eseguito; due erano imprecise, e lo scrivo.

| premessa | esito |
|---|---|
| P1, griglia a quaranta colonne da `tool/genera_sagome.py`, il velo scosta celle intere | **vera**: `LeSagome.colonne = 40`, e il pittore della cenere era l'unione dei rettangoli delle celle coperte |
| P2, le tre cartelle degli asset vuote sul ramo | **vera** |
| P3, Info.plist ha `NSLocationWhenInUseUsageDescription` e non `NSLocationAlwaysAndWhenInUseUsageDescription` | **vera** |
| P4, nessun `PrivacyInfo.xcprivacy` nel progetto | **vera**: nessuno in `ios/`; ne portano uno i pod, vedi DQ.12 |
| P5, `geolocator ^14.0.3` usato dal cielo, solo ad app aperta | **vera**: l'app chiede solo la posizione ad app aperta; legge lo stato "sempre" solo per riconoscerlo |
| P6, titolo 70,9, risposta 66,4, gesto 84,0, sette guasti non curati | **vera**, dal rapporto DN |
| P7, una riga scartata non fa richiamare il modello | **vera**: `chiediTutto` richiamava solo per la scena fuori vocabolario |
| P8, la domanda si chiede a ogni discesa e non si conserva | **vera**: la soglia ripartiva sempre dal campo vuoto |
| P9, "il tuo spazio" nel gergo | **vera**, `le_guardie_del_responso.dart` |
| DQ.08, "il banco delle trenta domande" | **imprecisa**: le domande erano trentasei, col minimo dichiarato a trenta. Ne ho aggiunte cinque, quarantuno, e il minimo e' salito a trentacinque |
| DQ.10, tamburo "a 214 battiti al minuto", 2,325 secondi | **imprecisa**: l'onda decodificata dice otto colpi in 2,286 secondi, 210 al minuto. Il fondatore ha scelto il numero del file, 3,5 al secondo |

---

## 2. LE MISURE DA A A G, DQ.13

**Mille e cento discese col modello vero**, `la_prova_a_cento_discese`, undici
casi da cento: i sei temi della tavola e cinque domande libere, ognuno girato
senza rete e con rete. Le misure A-F sono quelle dell'ordine DI voce 16, la G
e' nuova di quest'ordine.

| caso | A, la scena ha i suoi quattro pezzi | B, il vocabolario | C, la coppia piu' ripetuta | D, discese identiche | E, il responso col modello | F, finestre ripetute |
|---|---|---|---|---|---|---|
| tema scelta | 100/100 | 100, max 1 | 25,5% | 1 | 97/100 | 0 |
| tema persona | 100/100 | 100, max 1 | 30,0% | 1 | 92/100 | 0 |
| tema blocco | 100/100 | 100, max 1 | 26,1% | 1 | 89/100 | 0 |
| tema attesa | 100/100 | 100, max 1 | 17,7% | 1 | 89/100 | 0 |
| tema direzione | 100/100 | 100, max 1 | 21,1% | 1 | 96/100 | 0 |
| tema finito | 100/100 | 100, max 1 | 18,3% | 1 | 100/100 | 0 |
| libera 1 | 100/100 | 100, max 1 | 22,2% | 1 | 83/100 | 0 |
| libera 2 | 100/100 | 100, max 1 | 30,1% | 1 | 84/100 | 0 |
| libera 3 | 100/100 | 100, max 1 | 26,3% | 1 | 86/100 | 0 |
| libera 4 | 100/100 | 100, max 1 | 23,4% | 1 | 78/100 | 0 |
| libera 5 | 100/100 | 100, max 1 | 24,8% | 1 | 74/100 | 0 |

**Tutte passano le soglie di sempre**: A cento su cento, B tutto dal
vocabolario con al massimo una ripetizione, C sotto il quaranta per cento, D
nessuna coppia di discese identiche oltre l'una ammessa, F nessuna finestra
ripetuta. **Senza rete le stesse misure danno A 100, C fra 25,0 e 32,8, D 2,
E 100 su 100**: la casa da sola regge, e il modello non e' una stampella.

### La misura G, che l'ordine chiede nuova

*"Venti cammini interi, e nessuno strato che ripete uno di prima."*

| | cammini | strati che ripetono | somiglianza peggiore fra due strati dello stesso cammino |
|---|---|---|---|
| senza rete | 20 | **0** | 8,5% |
| con rete, modello vero | 20 | **0** | 5,0% |

**L'istruzione degli strati di prima funziona**: col modello vero la
somiglianza peggiore fra due strati dello stesso cammino e' del cinque per
cento, cioe' i quattro strati parlano di quattro cose diverse della stessa
domanda. Senza rete e' dell'8,5, perche' la voce di casa pesca da un
vocabolario piu' stretto.

---

## 3. LE PERCENTUALI PRIMA E DOPO LA SECONDA CHIAMATA, DQ.06

Sulle 1.100 discese, quanta parte del responso finale viene dal modello e non
dalla voce di casa, **prima** della seconda chiamata e **dopo**:

| riga | prima | dopo | l'ordine chiede |
|---|---:|---:|---|
| titolo | 73,0% | **91,2%** | oltre 85 |
| risposta | 64,2% | **84,3%** | oltre 85 |
| gesto | 80,2% | **91,6%** | oltre 85 |

**Il titolo e il gesto passano il bersaglio, la risposta lo manca di sette
decimi**, e il numero sta qui come chiede la voce: *"se il bersaglio non si
raggiunge, riferire il numero"*. **Nessuna guardia di sostanza e' stata
allentata**: le tre percentuali sono salite di diciotto, venti e undici punti
solo perche' il modello viene richiamato una volta con il motivo dello scarto
scritto in parole sue.

**I motivi che piu' spesso vengono recuperati alla seconda chiamata**, cioe'
quelli su cui il modello si corregge: previsione certa sulla risposta 52,
titolo troppo lungo 52, risposta che non nomina la domanda 48, titolo
ripetuto 46, gergo nella risposta 45, titolo che dice lo stato di un terzo
44, risposta che anticipa la scena 38, il fuoco nel gesto 33.

**E i motivi che restano**, cioe' le righe che dopo due chiamate vanno
comunque alla voce di casa: sulla persona lo stato di un terzo (13 risposte
su cento) e il titolo ripetuto (8); sulla scelta la previsione certa (9) e il
gergo (5). **Sono i due limiti veri del modello su questa funzione**: parla
del terzo come se lo conoscesse, e promette. Le guardie li prendono tutti e
due, e il prezzo e' una riga di casa.

---

## 4. IL COSTO, DQ.13

**0,001723 dollari a discesa.** Sulle 1.100 discese: **2.343 chiamate al
modello**, 4.387.164 token in ingresso e 263.518 in uscita.

| chiamata | quante | token in ingresso, in media | token in uscita, in media |
|---|---:|---:|---:|
| la scena, `gemini-2.5-flash` | 1.856 | 2.211 | 136,1 |
| il tema della domanda, `gemini-2.5-flash-lite` | 485 | 585 | 22,4 |

**1.856 chiamate su 1.100 discese** vuol dire che **il 69 per cento delle
discese si accontenta della prima**: la seconda chiamata costa in media sette
decimi di chiamata a discesa, non una. Il costo per discesa sale da 0,001695
a **0,001723 dollari**, cioe' **l'uno virgola sei per cento**, per venti
punti di risposta dal modello. I prezzi vengono dal listino Cloud Billing:
Flash 0,30 dollari per milione in ingresso e 2,50 in uscita, Flash Lite 0,10
e 0,40.

**Il segno col modello vero**, dodici domande: dodici accettate su dodici,
con i tre gesti distribuiti (si avvicina 4, si allontana 5, si volta 3).

---

## 5. IL VELO DI CENERE, DQ.05

**Le misure delle guardie**, `il_velo_di_cenere_continuo`, sui pixel
rasterizzati e non sull'albero dei widget:

| che cosa | misura | soglia |
|---|---|---|
| il bordo del solco segue il dito | fra il primo e il terzo quarto **0,02 punti** | sotto 3 |
| lo stesso bordo col pittore a celle | 4,24 punti | e' il difetto che si voleva prendere |
| la testa resta coperta, dito sopra | **441 punti su 441**, 12 campioni nel bordo sfumato | tutti |
| la grana non e' una piastrella | differisce di **10,4 livelli** a 256 pixel, vicini uguali 3,1% | oltre 6 |
| la grana non lascia cuciture | riga peggiore **3,9 volte** la mediana | sotto 6 |
| la cenere si assottiglia e si accumula | cresta a 223 di luce contro 120 del velo, alfa 236 dove si assottiglia | la cresta e' piu' chiara |
| le braci si accendono e si spengono | accesa (175, 51, 13) con alfa 232, spenta alfa 0 | acceso poi spento |

**I fotogrammi al secondo sul 767f596c**, misurati con
`dumpsys SurfaceFlinger --timestats` mentre il dito scosta, e sono il difetto
piu' grosso trovato dalla prova a video: 

**Come si misura.** `dumpsys SurfaceFlinger --timestats` azzerato, due
passate del dito da due secondi l'una con `input swipe`, e si contano i
fotogrammi **presentati** nella finestra. Lo schermo va a 60 Hz. Non si usa
`--latency`, che su questo telefono torna una tabella di zeri, ne'
`gfxinfo`, che conta i fotogrammi di HWUI e non quelli di Flutter: il primo
giro di misure li aveva usati tutti e due e diceva zero.

| quando | fotogrammi al secondo |
|---|---:|
| la nebbia della stessa schermata, per confronto | **60,2** |
| il velo di cenere, com'era | **19,4 e 20,2** |
| col solo solco vivo ridisegnato, i finiti cotti in un'immagine | 33,6 e 35,1 |
| cuocendo anche il solco vivo, un segmento alla volta | 30,8, 34,3 e 33,4 |
| col margine della coltre da 220 punti a 40 | **32,6, 38,3 e 35,1** |

**Il velo sta a trentacinque fotogrammi al secondo, e l'ordine ne chiede
cinquanta.** Il numero sta qui perche' e' quello vero.

**E la densita' della grana non c'entra**, che e' la leva che la voce DQ.05
nominava: la grana si calcola **una volta sola**, in un altro filo, e finisce
in un'immagine; abbassarla avrebbe cambiato di che cosa e' fatta la cenere
senza spostare un fotogramma. **La causa vera, misurata**: a ogni fotogramma
il pittore apriva un livello fuori schermo grande quanto la coltre e ci
ridisegnava sopra **tutti i solchi di tutte le discese**, tre tratti sfocati
e due o tre cerchi sfocati per punto, e quei punti crescono a ogni
millimetro che il dito percorre.

**Le tre cure, ognuna misurata da sola**: cuocere i solchi finiti in
un'immagine vale **quindici fotogrammi**, da venti a trentacinque, ed e'
quella che conta; cuocere anche il solco vivo un segmento alla volta non ha
spostato la misura, ma toglie la crescita col gesto lungo, che e' il difetto
visto alla prima discesa; il margine della coltre, che era **un terzo del
lato piu' lungo**, cioe' 220 punti su questa scena, e' sceso a 40, e le due
immagini della coltre da 2,8 volte la scena sono passate a 1,35.

**Cosa resta da fare, per chi lo riprendera'**: il livello fuori schermo di
ogni fotogramma, `saveLayer`, e il cumulo della testa ridipinto sopra.
Cuocendo anche quelli nell'immagine il disegno per fotogramma diventerebbe
una copia sola, e il velo andrebbe a sessanta. Non l'ho fatto stanotte
perche' cambia l'ordine delle fusioni fra i livelli, che e' esattamente il
punto dove il velo si puo' rompere, e le prove del velo misurano i pixel ma
non tutte le fusioni.

---

---

## 6. I CINQUANTA ASSET, DQ.10

Scompattati dalla radice, nessuno rinominato, e **l'impronta SHA-256 di
ognuno verificata contro il `MANIFESTO.txt` del pacco: cinquanta su
cinquanta**. I nomi sono esattamente quelli che il codice costruisce:
`GestiDelSegno.disegniAttesi` per i trentasei disegni,
`VersiDegliAnimali.percorsoPer` per i dodici versi,
`IlTamburoDellaDiscesa` e `IlColpoDelTamburo` per i due tamburi. Le tre
cartelle erano gia' dichiarate nel `pubspec.yaml`.

| cartella | file | peso |
|---|---:|---|
| `assets/img/mondo_di_sotto/gesti/` | 36 | da 15.536 a 271.346 byte |
| `assets/audio/mondo_di_sotto/` | 2 | `tamburo_discesa.mp3` 37.660, `tamburo_colpo.mp3` 12.164 |
| `assets/audio/animali/` | 12 | da 24.703 a 41.839 byte |

**Due numeri del codice seguono i file**: la cadenza del tamburo,
`IlTamburoDellaDiscesa.battitiAlSecondo`, da 4,5 a **3,5**, dentro la
forbice di Harner, 205-220 al minuto; la durata del colpo,
`IlColpoDelTamburo.durata`, da 400 a **700 millesimi**, quanto dura il file.
Il LEGGIMI del tamburo porta le misure vere e la forbice del colpo portata a
0,2-0,8 secondi, come chiedeva il fondatore.

---

## 7. LE PURPOSE STRING, DQ.11

**Le due chiavi della posizione continua sono entrate**:
`NSLocationAlwaysAndWhenInUseUsageDescription` e
`NSLocationAlwaysUsageDescription`, col testo dell'ordine **e con una frase in
piu'**. Il testo dell'ordine finiva con *"Le coordinate restano sul
dispositivo."*, e cosi' non e' vero: per scrivere il nome della citta' sotto
il cielo le coordinate vanno ai servizi di sistema di Apple. La chiave che
c'era gia' lo diceva, e la guardia `il_cielo_dice_da_dove` esiste proprio per
questo: le ho dato la stessa seconda meta', *"...; per scrivere il nome della
citta' sotto il cielo le chiedo ai servizi di sistema."*. La guardia prendeva
la promessa solo al singolare, *"resta sul dispositivo"*: adesso anche al
plurale, ed e' caduta sul testo dell'ordine parola per parola.

**Cosa dice il rapporto dell'ordine, e lo riporto**: l'avviso 90683 non
blocca TestFlight e non e' la causa per cui i fondatori non installano le
build vecchie; diventa serio alla revisione per la pubblicazione.

**Le purpose string presenti, col pacchetto che le richiede**, lette nei
sorgenti nativi dei pacchetti e non a memoria:

| chiave | pacchetto | per cosa |
|---|---|---|
| `NSLocationWhenInUseUsageDescription` | geolocator | il cielo sopra di te, ad app aperta |
| `NSLocationAlwaysAndWhenInUseUsageDescription` | geolocator, per il binario | posizione continua, **mai chiesta** |
| `NSLocationAlwaysUsageDescription` | geolocator, per il binario | posizione continua, **mai chiesta** |
| `NSMicrophoneUsageDescription` | record, speech_to_text | il soffio del Soffio del Destino, la dettatura ai Maestri |
| `NSSpeechRecognitionUsageDescription` | speech_to_text | la dettatura |
| `NSCameraUsageDescription` | camera, image_picker, google_mlkit_face_detection, mediapipe_face_mesh | la Costellazione del Viso, la foto della Sinastria |
| `NSPhotoLibraryUsageDescription` | image_picker | la foto della Sinastria dalla galleria |
| `NSPhotoLibraryAddUsageDescription` | gal, share_plus | il Sigillo nelle foto |
| `NSMotionUsageDescription` | sensors_plus | il cielo che respira, le rune scosse |

Nessuna chiave per firebase_messaging e flutter_local_notifications (il
permesso si chiede a runtime), geocoding, audioplayers, video_player,
path_provider, shared_preferences, i pacchetti Firebase e google_sign_in
(che vuole lo schema di ritorno, gia' presente). `camera` vorrebbe anche il
microfono per registrare video con l'audio: l'app lo spegne,
`enableAudio: false`.

**Due testi che non dicevano il vero, corretti nella stessa passata**:

- **il microfono** diceva solo il soffio, e la dettatura dei Maestri lo usa
  anche lei: chi dettava per primo si sarebbe visto chiedere il microfono
  *"per liberare i semi"*. Adesso nomina tutte e due le cose;
- **il riconoscimento vocale** prometteva *"le tue parole diventano testo sul
  dispositivo"*, e `dettatura_vera.dart` non chiede il riconoscimento sul
  dispositivo: su iPhone lo fa il servizio di Apple. Adesso lo dice. **Da
  decidere per il fondatore**: la privacy policy dice che il microfono ascolta
  il soffio senza registrare, e non parla della dettatura trascritta da Apple
  o da Google. Non l'ho toccata, perche' e' un testo legale.

---

## 8. IL MANIFESTO DELLA PRIVACY, DQ.12

**Creato `ios/Runner/PrivacyInfo.xcprivacy`, e aggiunto al bersaglio
Runner** a mano nel `project.pbxproj`, con le quattro righe simmetriche a
quelle del `GoogleService-Info.plist`: riferimento di file, gruppo Runner,
fase di copia delle risorse di Runner, voce di copia. La guardia
`il_manifesto_della_privacy` lo pretende, ed e' caduta su tre innesti: il
tracciamento acceso, un motivo pubblicitario, la copia tolta da Runner.

**Come e' ricavato, voce per voce come chiede l'ordine**:

1. **I pacchetti che portano gia' il loro manifesto**, contati nella cache dei
   pacchetti: camera_avfoundation, firebase_messaging,
   flutter_local_notifications, gal, geocoding_ios, geolocator_apple,
   google_sign_in_ios, image_picker_ios, package_info_plus, record_darwin,
   sensors_plus, share_plus, shared_preferences_foundation,
   video_player_avfoundation, e TensorFlow Lite dentro mediapipe_face_mesh. Il
   motore di Flutter porta il suo (data dei file, tempo dall'accensione).
   **Firebase 12.15.0**, che arriva da Swift Package Manager, porta i suoi:
   letti sul repository di Google quelli di FirebaseCore e di Crashlytics,
   che dichiara i dati dei guasti. **ML Kit** porta i manifesti dalla 5.0.0,
   febbraio 2024, dalle note di rilascio di Google: l'app usa la 9.0.0.
2. **I pacchetti senza manifesto**, audioplayers_darwin, speech_to_text, gli
   involucri Flutter di Firebase tranne messaging, google_mlkit: nei loro
   sorgenti nativi **nessuna interfaccia a motivo obbligatorio**, cercate per
   nome. Un solo falso positivo, `creationDate` in firebase_auth, che e' la
   data di nascita dell'account e non di un file.
3. **Per l'app**: nessun tracciamento, nessun dominio di tracciamento. **I
   dati raccolti** vengono dalla privacy policy dell'app,
   `lib/core/legal/privacy_policy.dart`, che una guardia sua ancora al codice:
   email (anche l'impronta cifrata contro le frodi: Apple la conta come email),
   nome, identificativo dell'account, contenuti della persona (le domande ai
   Maestri, la memoria, i responsi custoditi), interazione col prodotto (il
   cammino, i Sigilli, gli Eos, e col consenso i cinque gesti contati), il
   gettone delle notifiche, e i dati di nascita col fuso e le ore scelte.
   Nessuno per la pubblicita', nessuno per il tracciamento. **Non ci sono** la
   posizione, le foto e l'audio, che restano sul telefono. **Le interfacce di
   sistema**: le preferenze, `NSUserDefaults`, col motivo CA92.1, tramite
   shared_preferences; il codice del Runner non ne chiama nessun'altra.

**La dichiarazione della Play Console non e' nel repository**, e non ho modo
di leggerla: il manifesto e' ricavato dalla privacy policy, che e' la fonte
scritta e sorvegliata. **Il fondatore la confronti con la scheda "Sicurezza
dei dati" della Play Console**: se una delle due dice di piu', una delle due
va corretta.

**La verifica sull'archivio**: su questa macchina Xcode non c'e'. Ho messo in
`codemagic.yaml` un passo dopo l'archivio, *"Il manifesto della privacy e'
dentro il pacchetto"*: apre l'`.ipa`, elenca tutti i manifesti che ci sono,
controlla con `plutil` quello dell'app, e **ferma la build se manca**. **La validazione dell'archivio non e' ancora stata fatta**, e le voci DQ.11 e
DQ.12 restano aperte fino a quella: su questa macchina Xcode non c'e', e
l'unico modo di vedere l'`.ipa` vero e' Codemagic. **Il fondatore lancia il
workflow su questa build**; il passo si ferma da solo se il manifesto non e'
nel pacchetto, e l'esito da cercare nel log di App Store Connect e'
**nessun ITMS-91053**. Quando arriva, le due voci si chiudono.

---

## 9. LA PROVA A VIDEO, DQ.14

**Sul 767f596c**, un Realme a 1080 per 2400 pixel, densita' 480, cioe' **360
punti di larghezza**, schermo a 60 Hz, scale di animazione a zero. Con la
build di collaudo del cammino, `--dart-define=COLLAUDO_DEL_CAMMINO=true`, e
il comando del tetto acceso nella zona Demo: quattro discese di fila senza
toccare il Viaggio vero del telefono. Le schermate stanno in
`docs/collaudo/DQ/`.

| punto | esito | schermata |
|---|---|---|
| 1, prima discesa: si scrive la domanda, torna il primo strato | **fatto**: *"Non riesco a decidere se cambiare lavoro"*, e risale *"Primo strato: che cosa hai portato giu' davvero"*, titolo *"La direzione non e' la soluzione"* | `01_la_domanda_si_scrive.png`, `02_primo_strato.png` |
| 2, seconda discesa: la domanda si legge e il secondo strato aggiunge | **fatto**: *"Sei qui per questo"* col profilo neutro, la domanda in una card che non si scrive, *"Oggi scendi al secondo strato: che cosa ti trattiene"*. Il primo strato diceva la paura di cio' che aspetta, il secondo dice che non riesci a immaginarti altrove: **aggiunge** | `03_la_domanda_si_legge.png`, `05_secondo_strato.png` |
| 3, terza e quarta: gli strati proseguono, e alla quarta l'animale si rivela insieme alla risposta | **fatto**: terzo strato *"che cosa hai gia' in mano"*, le persone attorno; quarto *"che cosa fare"*, **con la Volpe intera nello stesso momento**, e sotto *"E' la Volpe. Adesso la conosci."* | `06_terzo_strato.png`, `08_il_velo_cade_da_solo.png`, `09_quarto_strato_e_animale.png`, `10_il_riconoscimento.png` |
| 4, i quattro strati si rileggono di fila nel Diario | **fatto**, dal pulsante *"Rileggi i quattro strati"*: la domanda, *"Quattro strati su quattro, dal 16 settembre 2026"*, e i quattro di seguito in una card sola | `11_il_diario_dei_viaggi.png` |
| 5, l'avviso del cambio con le parole della voce DQ.03 | **fatto**, parola per parola, coi due pulsanti *"Tengo questa domanda"* e *"Comincio un altro viaggio"*. Scelto di tenere la domanda, il cammino prosegue | `07_avviso_del_cambio.png` |
| 6, il velo: il solco segue il dito, la cenere ha grana, sotto si intravedono le braci, la testa resta protetta | **fatto**, e qui la prova a video ha trovato **due difetti veri**, la cucitura della grana e i venti fotogrammi: vedi la tavola dei difetti | `04_il_velo_di_cenere.png` |
| 7, il tamburo nella discesa e il colpo che risponde al dito | **fatto**: nel nutrimento ogni tocco apre una `low-latency-playback` sull'uscita audio del telefono, letta nel log di sistema, e la Volpe si avvicina a ogni colpo | `12_il_tamburo_che_nutre.png` |
| 8, il segno mostra il disegno del gesto e non l'illustrazione intera | **fatto**: *"Devo accettare il lavoro nuovo"* -> *"La Volpe si avvicina. La risposta e' si', puoi andare avanti."*, col disegno della Volpe **che si avvicina** | `13_il_segno_della_volpe.png` |
| 9, il verso dell'animale quando previsto | **non colto a video**: il verso suona **una volta sola nella vita**, nell'istante in cui la testa esce dal velo, e quando e' successo il registro dell'audio non era armato. Lo copre la guardia del cammino sulla schermata vera, che stampa *"Ordine DE voce 07: verso udito = true"*, e le impronte dei dodici file sono verificate dalla voce DQ.10 | -- |
| 10, con un profilo femminile nessun testo da' del maschile | **coperto dalle guardie, non dal telefono**: il profilo del 767f596c e' neutro, e infatti la barra dice *"Sei qui per questo"*. Il femminile lo prova `il_viaggio_parla_al_femminile`, che scende con la porta del genere al femminile e pretende *"Sei scesa"*, e la pulizia della voce di casa in `il_responso_risponde` | -- |

**E una cosa che la prova a video ha confermato**: la card del Viaggio nel
dominio di Caligo, nella build di collaudo, **non** mostra la Volpe
riconosciuta nel cammino di collaudo. E' come deve essere: quel Diario vive
nella sola schermata del Viaggio e non scrive sul telefono.

---

---

## 11. LE DECISIONI PRESE, E PERCHE'

- **"Sei sceso per questo" porta la marca del genere**:
  `[Sei sceso|Sei scesa|Sei qui] per questo`. Il participio dice il genere di
  chi legge, e la regola di casa dell'ordine DI voce 05 non lo da' a chi non
  l'ha detto. Al femminile *"Sei scesa per questo"*, al neutro *"Sei qui per
  questo"*. Il telefono di collaudo ha il profilo neutro.
- **Nella frase del riquadro del cambio manca una virgola**, quella prima di
  *"e l'animale si mostra"*. La regola di casa vieta la virgola davanti alla
  *e* nelle stringhe, e il fondatore ha gia' negato la deroga per un testo suo
  consegnato parola per parola, le cornici del presagio: la virgola era
  stilistica e si tolse senza cambiare il senso. Tutto il resto e' parola per
  parola.
- **"Che cosa di lui ti somiglia" e' "Che cosa dell'animale ti somiglia"**:
  prima della quarta discesa non si sa se e' il Lupo o la Volpe.
- **Il riconoscimento legge le apparizioni del cammino** e non piu' le
  discese di sempre, in tutti i punti che lo leggevano: il Viaggio, il
  Passaporto, il Santuario, la card nei Maestri, il nome nelle chat. **Chi
  aveva gia' riconosciuto il suo animale lo tiene**; chi era a meta' prosegue
  con la domanda della sua ultima discesa, dallo strato a cui era arrivato.
- **Il Diario dei viaggi e' una pagina nuova.** C'era dall'ordine DC voce 09
  come archivio sul telefono, e nessuna schermata lo mostrava: si apre dal
  libro nella barra del Viaggio e dal pulsante *"Rileggi i quattro strati"*
  alla rivelazione.
- **La build di collaudo del cammino**: con `--dart-define=COLLAUDO_DEL_CAMMINO`
  il Viaggio usa un Diario senza archivio, che vive per la sessione e non
  scrive sul telefono. Serve a provare i quattro strati da capo **senza
  toccare "Ricomincia il viaggio (Demo)" ne' il Viaggio gia' riconosciuto del
  telefono**. Nella build che si consegna il ramo non esiste, e una guardia
  controlla che ne' Codemagic ne' la consegna lo accendano.

---

## 12. I DIFETTI TROVATI STRADA FACENDO, COI LORO PADRI

Regola C.

| difetto | padre | la cura |
|---|---|---|
| la guardia dei due tempi contava il gesto, la coda e la scena, non il corpo della risposta di casa: 174 responsi su 2.100 dicevano due tempi e passavano | ordine DN voce 08, la guardia dei due tempi | contato anche il corpo; sette risposte di casa riscritte senza tempo |
| la ripresa del tema persona taceva il fratello per non far leggere *le* su un uomo | ordine DN voce 08, la cura della 2253 | tolte le marche di genere dalle risposte, la ripresa nomina di chi si chiede |
| la guardia del cielo prendeva la promessa della posizione solo al singolare | la guardia `il_cielo_dice_da_dove`, commit `fcb80a84` dell'8 agosto 2026 | anche al plurale, se la frase non dice dei servizi di sistema |
| il microfono non diceva la dettatura; la voce prometteva la trascrizione sul dispositivo | il microfono dal commit `21f46cf0` del 17 luglio 2026, quando la dettatura non c'era; la voce dall'ordine CU del 7 settembre 2026 | testi corretti |
| quattro frasi nuove con la virgola davanti alla *e*, nelle parole dei motivi per il modello e nell'istruzione dell'incontro | ordine DQ voci 06 e 02, mie | tolte prima di spingere; le ha prese `language_rule` |
| il Diario dei viaggi cadeva senza `MaestroScope` sopra la sua rotta | ordine DQ voce 02, mio | la rotta si veste di Caligo; trovato dalla prova del cammino |
| la guardia degli accenti cadeva su quattro righe: due eccezioni scritte per numero di riga erano scese, e la tavola nuova dei non nomi porta *perche* e *se* come li digita la persona | ordine DQ voce 08, mio: le guardie della zona le avevo viste, questa trasversale no | eccezioni aggiornate col loro perche'; trovata dalla suite intera, prima di spingere |
| **la cucitura della grana**: dentro la cenere correva una riga dritta e sotto di lei il tono cambiava. La grana della scena si dipinge grande quanto l'illustrazione e si ripete per coprire la coltre, che e' piu' larga di un margine per lato, e quella grana non si richiude su se' stessa | ordine DQ voce 05, mio | si ripete **allo specchio**, dove i due lati combaciano per costruzione. Guardia nuova `LA GRANA NON LASCIA UNA CUCITURA DRITTA`, nata rossa a 14 volte la mediana, adesso 3,9 |
| **il titolo della barra tagliato**: col libro del Diario le azioni diventano tre, al titolo restano meno di 140 punti, e sotto quella larghezza in due righe si taglia a qualunque misura. Si leggeva *"Il Viaggio dello"* | ordine DQ voce 02, mio: il libro nella barra e' di quest'ordine | tre righe e barra alta 68 punti invece di 56. Guardia nuova `il_titolo_del_viaggio_ci_sta_tutto`, vista rossa col difetto in casa |
| **venti fotogrammi al secondo sul velo**, contro i sessanta della nebbia della stessa schermata: i tre tratti sfocati e i morsi del bordo si ridisegnavano a ogni fotogramma su tutti i solchi di tutte le discese, e crescono a ogni punto che il dito aggiunge | ordine DQ voce 05, mio | i solchi **finiti** si cuociono in un'immagine, una per gesto; a ogni fotogramma resta il solo solco vivo. **Da venti a trentacinque fotogrammi al secondo**, misurati; i cinquanta che l'ordine chiede non sono stati raggiunti, e il numero sta nella sezione 5 |
| **il nome dell'animale senza articolo sulla card della rivelazione**: si leggeva *"MI HA TROVATO VOLPE"*. Detto dal fondatore guardando la card sul telefono, alle 2 e 48 del 16 settembre | la card nasce con l'ordine DC voce 08; il titolo e' sempre stato `MI HA TROVATO ${nome}` | due righe: *"MI HA TROVATO"* e sotto, piu' grande, **il nome col suo articolo**, che `GuideAnimal.articolo` sapeva gia' scrivere ed elide davanti a vocale. Guardia nuova `il_nome_sulla_card_ha_l_articolo`, vista rossa su dodici animali su dodici |
| la card del Viaggio nei Maestri, nella build di collaudo, non mostra l'animale riconosciuto nel cammino di collaudo | nessuno: e' **voluto**. Il Diario di collaudo vive nella sola schermata del Viaggio e non scrive sul telefono, quindi fuori di li' nessuno lo vede. Nella build che si consegna non esiste |

---

## 13. LA RIGA FINALE

**Sedici voci, quattordici chiuse e due in attesa dell'archivio**, DQ.11 e
DQ.12, che si chiudono col primo caricamento su App Store Connect senza
ITMS-91053. **La build e' la @@NUMERO@@**, consegnata ai fondatori con
`tool/consegna.py`; la prova a video sta nella sezione 9 e le schermate in
`docs/collaudo/DQ/`.

**Il Viaggio dello Sciamano si chiude qui per davvero**: la domanda accompagna
quattro discese, ogni discesa aggiunge uno strato invece di ripetere, alla
quarta l'animale e la risposta arrivano insieme, e i quattro strati restano da
rileggere nel Diario. **Il velo e' cenere**, non piu' una griglia. **Il
modello scrive nove titoli su dieci, otto risposte e nove gesti su dieci**, e
le guardie di sostanza sono tutte in piedi.

**Cosa resta sul tavolo del fondatore**, e non si chiude senza di lui:

- **lanciare Codemagic** su questa build, per la validazione dell'archivio;
- **la privacy policy non parla della dettatura trascritta da Apple o da
  Google**: e' un testo legale e non l'ho toccato;
- **la scheda "Sicurezza dei dati" della Play Console** va confrontata col
  manifesto della privacy: se una delle due dice di piu', una delle due va
  corretta;
- **la risposta dal modello e' all'84,3 per cento contro un bersaglio di 85**:
  il divario e' di sette decimi, e per chiuderlo servirebbe toccare le
  guardie di sostanza, cosa che l'ordine vieta.

