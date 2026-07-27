# ESITO dell'ORDINE CORRENTE

## Consegna al telefono con App Distribution

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

## Ordine precedente, chiuso: l'APK col token di App Check

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
