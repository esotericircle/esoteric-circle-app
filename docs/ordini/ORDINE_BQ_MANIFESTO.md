# ORDINE BQ, I VIDEO DEI MAESTRI AL POSTO DELLE IMMAGINI

Ordine del fondatore del 25 agosto 2026. Ramo
`claude/esoteric-circle-master-order-e798aj`, guardia
`test/ordine_bq_guard_test.dart`. Testa di partenza `35b8ada`.

**Parole del fondatore**: "facciamo un test: sostituisci i video animati di
rivelazione di Medora, Caligo e Aura al posto delle immagini. il video Aura va
bene, e' gia' 1080x1920 ma gli altri sono da ingrandire e hanno anche il
watermark, ma non importa per ora. tutto i video sono da ottimizzare. dopo
voglio la build per controllare le ultime modifiche".

## Le premesse, verificate sulla testa 35b8ada prima di scrivere una riga

- **P1 VERA.** `video_player: ^2.13.0` e' dichiarato in `pubspec.yaml` alla riga
  110, e il lettore vive gia' in `lib/features/intro/sequenza_intro.dart`, che
  costruisce `VideoPlayerController.asset(SequenzaIntro.video)` alla riga 159 su
  `brand_assets/intro/Intro-Test-3.mp4`. Il lettore non si aggiunge: si riusa
  quel pattern.
- **P2 VERA.** `lib/features/onboarding/maestro_reveal_screen.dart` monta
  `MaestroCardReveal` dentro un `AnimatedSwitcher` alla riga 247, e
  `lib/features/onboarding/widgets/maestro_card.dart` mostra l'avatar con
  `Image.asset(widget.maestro.avatarAsset)` alla riga 137, dentro uno `Stack`
  sopra la cornice a carta.
- **P3 FALSA DA QUESTO CONTENITORE, e non e' un dettaglio: e' il motivo per cui
  due voci di questo ordine si fermano.** I tre file stanno nella cartella del
  fondatore sul suo PC, e questa sessione gira in un contenitore che ha soltanto
  il repository clonato. **Cercati sull'intero filesystem** per nome
  (`*Sorceress*`, `Caligo*.mp4`, `Aura-1.mp4`) e per percorso
  (`*Video*Maestri*`): **zero risultati**. Gli unici due `.mp4` presenti sono
  `brand_assets/intro/Intro-Test-3.mp4` e la sua copia dentro `build/`. Non
  esiste nessun modo di copiare da qui un file che qui non c'e', e inventarne
  uno sarebbe peggio che dichiarare la fermata.
- **P4 NON ESEGUIBILE, per due ragioni indipendenti.** La prima: i file non ci
  sono, quindi non c'e' niente da sondare. La seconda: **`ffprobe` e `ffmpeg` non
  sono installati in questo contenitore**, verificato con `which` e con `ls
  /usr/bin/ff*`. Durata, risoluzione, fotogrammi al secondo, codec e traccia
  audio dei tre video **restano quindi non misurati**, e non si stimano.

## BQ.00, LA RICOGNIZIONE

**COME L'INTRO MONTA IL SUO VIDEO, e le sette cautele che ha gia'.**
`lib/features/intro/sequenza_intro.dart` costruisce
`VideoPlayerController.asset` su `brand_assets/intro/Intro-Test-3.mp4` e porta
dietro sette cautele, tutte pagate da un difetto vero:

1. **Parte dopo il primo fotogramma**, con `addPostFrameCallback`, non dentro
   `initState`.
2. **`try/catch` attorno a `initialize`, che non rilancia mai**: se il filmato
   non parte, per esempio in prova headless dove non c'e' una piattaforma che
   lo decodifichi, si va alla destinazione invece di restare sul nero.
3. **Il volume si mette PRIMA di riprodurre**: un decimo di secondo di audio
   prima del muto e' comunque un suono che nessuno aveva chiesto.
4. **Un ascoltatore riconosce la fine** guardando `isInitialized`, `isPlaying` e
   `position >= duration`.
5. **Un timer di scorta** pari alla durata piu' un margine, per il caso in cui
   l'ascoltatore non scatti mai.
6. **L'app che passa dietro CHIUDE l'intro, non la mette in pausa**, e la muta
   comunque, perche' il lettore ha un osservatore suo che al ritorno fa
   ripartire da solo cio' che aveva messo in pausa.
7. **La dissolvenza prima di smontare**: fra il video e cio' che c'e' sotto non
   passa nessun colore intermedio, quindi nessun lampo.

**Cosa ho riusato e cosa no, dichiarato.** Riusate la 1, la 2, la 3, la 4, la 6
e il `dispose` che libera sempre. **Non riusata la 5**, il timer di scorta: qui
non serve niente che porti la scena altrove, perche' quando il filmato finisce
non si va da nessuna parte, si scopre l'immagine che sta sotto. **Non riusata la
7**, la dissolvenza: non c'e' niente da dissolvere, per la stessa ragione.

**OGNI PUNTO IN CUI L'AVATAR DEL MAESTRO COMPARE NELLA RIVELAZIONE.** Uno solo:
`lib/features/onboarding/widgets/maestro_card.dart` riga 137,
`Image.asset(widget.maestro.avatarAsset)` dentro lo `Stack` di
`MaestroCardReveal`, sopra la cornice a carta e con un `errorBuilder` che ripiega
sull'icona del Maestro. La scena `maestro_reveal_screen.dart` non disegna nessun
avatar per conto proprio: monta la carta dentro un `AnimatedSwitcher` alla riga
247.

**Fuori dalla rivelazione l'avatar compare in altri tre punti, che questo ordine
NON tocca e che elenco perche' chi cerchera' "il video del Maestro" li
trovera'**: `features/santuario/widgets/maestro_bust.dart` riga 118,
`features/maestri/widgets/busto_del_maestro.dart` riga 92 e
`features/maestri/widgets/maestro_bust.dart` riga 258. La sorgente e' sempre
`Maestro.avatarAsset`, cioe' i tre WebP in `assets/avatars_webp/`.

**I ROSSI DELLA SUITE CON TZ=Europe/Rome**, misurati sulla testa di partenza
`35b8ada` ad albero fermo: **3.644 verdi e 3 rossi**. Il rosso vero e' **uno
solo**, l'attribuzione cieca in `i_doni_e_la_chat_davanti_all_anatomia_test.dart`,
rosso per dichiarazione dall'ordine BP e rimisurabile solo dal PC del fondatore.
Gli altri due erano le due prove di `niente_lavoro_non_spinto`, che dicono il
vero soltanto ad albero pulito e si sono chiuse col commit e con la spinta.

## Le voci

- **BQ.00** La ricognizione. CHIUSA: questo capitolo.
- **BQ.01** I tre video entrano nel repository. **FERMATA SU PREMESSA FALSA**: i tre file non esistono in questo contenitore e non c'e' nessun modo di farli comparire. Cercati sull'intero filesystem per nome e per percorso, zero risultati; gli unici `.mp4` presenti sono l'intro e la sua copia dentro `build/`. **CIO' CHE SI POTEVA FARE SENZA I FILE E' STATO FATTO TUTTO, e il giorno che arrivano non serve toccare una riga di codice**: la cartella `brand_assets/maestri/` esiste ed e' dichiarata nel `pubspec.yaml` accanto a `brand_assets/intro/`, come gia' si fa per `assets/audio/` che e' dichiarata anche da vuota; i tre nomi attesi sono `medora_rivelazione.mp4`, `aura_rivelazione.mp4` e `caligo_rivelazione.mp4`, **composti dall'identificativo del Maestro e non scritti in un elenco**, quindi un quarto Maestro avrebbe il suo video il giorno che nasce; una prova pretende che i tre percorsi siano tutti minuscoli, senza spazi, distinti fra loro e dentro la cartella dichiarata, perche' l'originale di Medora si chiamava "Medora Sorceress Video.mp4" e uno spazio dentro il nome di un asset e' una trappola che si paga molto piu' tardi. **LO STATO PROVVISORIO E' SCRITTO IN DUE POSTI**, in `lib/core/maestro/rivelazione_in_video.dart` accanto ai percorsi e in `brand_assets/maestri/LEGGIMI.md`, con le parole del fondatore: sono un test, due su tre portano il watermark e vanno ingranditi, tutti e tre vanno ottimizzati. **IL PESO NON E' STATO MISURATO E NON SI STIMA**: i tre file pesano 1.353.869, 1.006.574 e 10.287.476 byte, cioe' **12.647.919 byte in tutto**, ma questi numeri vengono dall'ordine e non da un `ls` mio, e il peso del pacchetto dopo si potra' dire solo quando i file saranno dentro. **COSA DEVE FARE IL FONDATORE**: copiare i tre file in `brand_assets/maestri/` coi tre nomi qui sopra e aggiungerli al commit **uno per uno**, mai con un `git add` di tutto, come dice l'ordine e come insegna il 22 agosto.
- **BQ.02** Il video al posto dell'immagine. CHIUSA: `lib/features/onboarding/widgets/velo_di_rivelazione.dart`. **IL VIDEO NON SOSTITUISCE L'IMMAGINE, LE STA SOPRA, ed e' la decisione che regge questa voce e la successiva.** Un widget che scambia l'immagine col video avrebbe avuto tre modi di lasciare la scena vuota: mentre il filmato si prepara, se il file non c'e', e nel fotogramma fra l'ultimo quadro e il ritorno all'immagine. Cosi' invece l'immagine e' SEMPRE in albero e il video le si posa davanti: quando finisce, o se non parte affatto, **non c'e' nessun passaggio da fare e quindi nessun nero possibile**. Il lettore dell'intro e' riusato e non riscritto: `video_player` vive dietro `LettoreDiRivelazione`, una porta sola, e chi usa il velo non sa che esista. **MISURE**: il video parte entro **0 millesimi** su tutti e tre i Maestri, cioe' dentro il primo fotogramma dopo il montaggio, contro un tetto di 400; ogni Maestro chiede il PROPRIO video; il filmato **non cicla** e nessuno lo fa ripartire quando finisce; l'immagine e' in albero su **tutti e 30 i fotogrammi** controllati uno per uno attorno alla fine del video, perche' un nero di un fotogramma solo si vede a occhio e non si vede in due controlli agli estremi; **dieci aperture e chiusure della scena creano dieci lettori e ne lasciano vivi zero**. **UNA CAUTELA PRESA DALLA RICOGNIZIONE, che l'ordine non chiedeva**: l'app che passa in secondo piano CHIUDE il filmato invece di metterlo in pausa, come gia' fa l'intro, altrimenti chi rientra mezz'ora dopo trova il Maestro bloccato a meta' gesto invece del suo ritratto. **Rosso dimostrato**: tolto il `chiudi()` dal `dispose`, dopo dieci aperture restano **dieci lettori vivi** e la prova cade; l'iniezione e' stata verificata nel sorgente prima di leggere l'esito. **UNA SECONDA PROVA DEL ROSSO, sullo STRUMENTO e non sul codice**: il cronometro conta a fotogrammi pompati e non a orologio, perche' un orologio dentro una prova misura la macchina e questo repository lo ha gia' pagato nell'ordine BO; per dimostrare che sa cadere ho ritardato l'apertura di un secondo, e la misura e' salita a **400 millesimi** facendo cadere la prova.
- **BQ.03** Se il video non parte, l'immagine c'e' lo stesso. CHIUSA: e' un ramo solo, tre righe, e non ha bisogno di sapere PERCHE' il filmato non c'e': file assente, codec rifiutato o lettore fallito finiscono tutti li', senza un messaggio e senza un'attesa. Il lettore vero promette una cosa sola, **non lanciare mai**: un fallimento si dichiara con `pronto` falso. **MISURE**: col file assente la scena mostra l'immagine e non lancia niente in faccia a nessuno; con **Riduci Movimento nessun lettore viene creato**, e non creato-e-messo-in-pausa, perche' un filmato aperto e fermo occupa comunque un decodificatore; e **anche col lettore VERO**, cioe' `video_player` senza nessuna piattaforma che decodifichi, che e' il caso di questo contenitore ed e' anche il caso del telefono a cui manca il file, la scena mostra il Maestro. **LA PROVA NON GUARDA SOLO L'ALBERO, guarda anche cosa c'e' sopra**: pretende che col filmato non pronto il velo disegni il NULLA, perche' un riquadro nero al posto del video lascerebbe l'immagine in albero e lo schermo nero lo stesso. **Rosso dimostrato**: messo quel riquadro nero al posto del nulla, la prova cade dicendo che il velo disegna qualcosa sopra l'immagine; l'iniezione e' stata verificata nel sorgente prima di leggere l'esito.
- **BQ.04** La suite e il peso. CHIUSA per la parte misurabile, **e la parte non misurabile e' dichiarata invece di essere stimata**. `flutter analyze` sul progetto intero: **zero avvisi**. **IL PESO PRIMA**, contato sommando i file di tutte e ventinove le voci dichiarate fra gli asset del `pubspec.yaml`: **122.002.668 byte, cioe' 116,35 MiB**. I tre pesi maggiori sono il mazzo dei tarocchi con 25,07 MiB, gli Angeli con 23,82 e i ritratti VIP con 12,14; l'intro da sola pesa 5,87 MiB. **IL PESO DOPO NON SI PUO' MISURARE, e non si stima**: i tre video non sono in questo contenitore. Dai numeri dell'ordine peserebbero 1.353.869 piu' 1.006.574 piu' 10.287.476, cioe' **12.647.919 byte**, che porterebbero gli asset dichiarati a 134.650.587 byte, **128,41 MiB**, cioe' un aumento del **10,4 per cento**; ma quei tre numeri vengono dall'ordine e non da un `ls` mio, quindi il totale che ne discende e' un conto e non una misura. **E il peso degli asset NON e' il peso dell'APK**: l'archivio comprime, e il peso vero si legge solo dall'archivio costruito, che questa sessione non puo' costruire (vedi BQ.05). **UN GRAMMO DI ZAVORRA DICHIARATO**: `brand_assets/maestri/LEGGIMI.md` pesa 1.641 byte ed entra nel pacchetto, perche' e' dentro una cartella dichiarata; e' la stessa cosa che gia' succede a `assets/audio/LEGGIMI.md`, quindi la scelta e' coerente con cio' che il progetto fa gia', e il giorno che qualcuno vorra' togliere tutti i LEGGIMI dal pacchetto li togliera' insieme. **DUE GUARDIE DI CASA HANNO PRESO IL MIO CODICE NUOVO, e nessuna delle dodici prove che ho scritto io le guardava**: `stato_asset_test` ha visto che il `pubspec.yaml` dichiarava `brand_assets/maestri/` mentre `docs/stato_asset.json` non la conosceva, cioe' due elenchi di asset che si erano gia' separati; `nessun_catch_muto_test` ha visto il `catch (_)` del lettore vero e ha preteso che dichiarasse PERCHE' ignora l'errore. Adesso il manifest degli asset porta la cartella con la sua nota, e il catch nomina l'errore, lo scrive in console e spiega che sotto il velo c'e' gia' il ritratto, quindi non c'e' niente da salvare. **Le ha trovate la suite intera e non la rilettura**, ed e' il secondo ordine di fila in cui succede.
- **BQ.05** La build, ordinata dal fondatore. **FERMATA SU PREMESSA FALSA**, e le ragioni sono DUE e indipendenti, tutte e due verificate. **La prima: questa sessione non puo' costruire.** `flutter doctor` dice `[X] Android toolchain, Unable to locate Android SDK`, `ANDROID_HOME` e' vuoto e non esiste nessuna cartella dell'SDK; `which firebase` non trova niente, quindi non c'e' nemmeno il modo di consegnare. **La seconda, e vale anche se domani la prima cadesse: una build fatta da qui NON conterrebbe i tre video**, perche' i file non ci sono (vedi BQ.01), e servirebbe a controllare esattamente l'unica cosa che il fondatore ha chiesto di controllare. Consegnare un archivio senza i tre filmati chiamandolo "la build dei video dei Maestri" sarebbe la promessa mancata piu' grossa di tutto l'ordine. **`docs/versione_distribuita.json` NON e' stato toccato**, perche' registra l'ultimo numero DAVVERO consegnato e nessuna consegna e' avvenuta: resta 2205, release `479aqgmv17r18`. Il capitolo *La build, quando i video ci saranno* qui sotto porta la sequenza esatta.

## La build, quando i video ci saranno

**Serve una cosa sola prima di tutto: i tre file.** Copiali in
`brand_assets/maestri/` con questi nomi esatti, minuscoli e senza spazi:

| da | a |
|---|---|
| `Medora Sorceress Video.mp4` | `brand_assets/maestri/medora_rivelazione.mp4` |
| `Aura-1.mp4` | `brand_assets/maestri/aura_rivelazione.mp4` |
| `Caligo.mp4` | `brand_assets/maestri/caligo_rivelazione.mp4` |

Poi, dalla cartella del progetto, **uno per uno e mai un `git add` di tutto**,
perche' il 22 agosto tre filmati entrati con un add generale hanno fatto morire
il push per ore:

```
git add brand_assets/maestri/medora_rivelazione.mp4
git commit -m "BQ.01: il video di rivelazione di Medora"
git add brand_assets/maestri/aura_rivelazione.mp4
git commit -m "BQ.01: il video di rivelazione di Aura"
git add brand_assets/maestri/caligo_rivelazione.mp4
git commit -m "BQ.01: il video di rivelazione di Caligo"
git push -u origin claude/esoteric-circle-master-order-e798aj
```

Il codice non va toccato: la cartella e' gia' dichiarata negli asset e i nomi
sono gia' quelli che il codice compone da solo.

**La build, con il numero che deve crescere.** In `pubspec.yaml` la versione e'
`0.1.0+2205` e l'ultima consegnata registrata in `docs/versione_distribuita.json`
e' la **2205**: il numero va portato almeno a **2206**, altrimenti Android
rifiuta di installare sopra quella che il telefono ha gia' e
`test/versione_build_test.dart` lo impedisce prima.

```
flutter build apk --release --target-platform android-arm64
```

Un solo archivio arm64, mai `--split-per-abi`, che sommava duemila al numero. Il
numero vero si legge **dall'archivio** e non dal `pubspec`:

```
aapt2 dump badging build\app\outputs\flutter-apk\app-release.apk
```

**La consegna**, agli stessi indirizzi delle precedenti:

```
firebase appdistribution:distribute "build/app/outputs/flutter-apk/app-release.apk" --app 1:425821975933:android:1b1ca4db8d4df69b940814 --testers "cloud@esotericircle.app" --release-notes "I tre video di rivelazione dei Maestri, provvisori: due col watermark e da ingrandire, tutti da ottimizzare"
```

Poi si aggiorna `docs/versione_distribuita.json` col numero appena consegnato e
con la release restituita dal comando, **dopo** la consegna riuscita e mai prima.

**Non si spedisce su rosso.** La suite deve avere un rosso solo, l'attribuzione
cieca: se ne compare un altro, ci si ferma e lo si dice.

MARCATORI, per la guardia:
VOCI_TOTALI: 6
VOCI_APERTE: 0
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0
VOCI_FERMATE_SU_PREMESSA_FALSA: 2
VOCI_FERMATE_SU_DECISIONE_DEL_FONDATORE: 0
VOCI_CHIUSE: 4
