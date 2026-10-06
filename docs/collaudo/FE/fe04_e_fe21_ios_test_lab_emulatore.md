# Ordine FE, voci 04, 21.3 e 21.1: misure dell'agente

Data: 6 ottobre 2026. Tutto in sola lettura: nessun file del repo modificato,
nessun commit, nessuna API accesa, nessun documento utente letto.
Worktree: `C:\Users\user\Desktop\esoteric-circle-app\.claude\worktrees\esoteric-circle-v3-realignment-a88835`
(nel seguito, percorsi relativi a questo).

---

## COMPITO 1, FE.04: i crash su iOS

### a) Crashlytics e' inizializzato anche su iOS? SI'

- `lib/main.dart` righe 67-100: nessun ramo per piattaforma. Dietro
  `if (Firebase.apps.isNotEmpty)` (riga 82) arma `FlutterError.onError` con
  `recordFlutterFatalError` (righe 83-88), `PlatformDispatcher.instance.onError`
  con `recordError(..., fatal: true)` (righe 89-92), e i non fatali di
  `GuastiVersoIlCruscotto.inoltro` (righe 96-98). Vale identico su iOS.
- `lib/services/app_services.dart` riga 184: `await Firebase.initializeApp();`
  senza opzioni, quindi su iOS legge `GoogleService-Info.plist` dal bundle.
- `pubspec.yaml` riga 89: `firebase_crashlytics: 5.2.4`; riga 69:
  `firebase_core: 4.11.0`.
- `ios/Runner/Info.plist` e `ios/Runner/AppDelegate.swift`: nessuna chiave
  `FirebaseCrashlyticsCollectionEnabled` (grep di "firebase|crashlytics": zero
  righe), quindi la raccolta e' accesa per difetto.
- `GoogleService-Info.plist`: NON e' nel repo (`.gitignore` riga 145,
  confermato da `git check-ignore -v`). E' agganciato al progetto Xcode:
  `ios/Runner.xcodeproj/project.pbxproj` righe 12, 63, 126 e 238 (nella fase
  Resources del bersaglio Runner). In build lo scrive Codemagic dalla variabile
  cifrata `GOOGLE_SERVICE_INFO_PLIST`: `codemagic.yaml` righe 236-267, con
  controllo che contenga `GOOGLE_APP_ID` (riga 264). Una copia locale non
  versionata esiste nel checkout principale
  (`C:\Users\user\Desktop\esoteric-circle-app\ios\Runner\GoogleService-Info.plist`):
  `GOOGLE_APP_ID = 1:425821975933:ios:02367eef4fafaaf0940814` (riga 32),
  `BUNDLE_ID = com.esotericircle.esotericCircle` (riga 16).
- `ios/Podfile`: `platform :ios, '15.5'` (riga 17), `use_frameworks!` e
  `flutter_install_all_ios_pods` (righe 46-49). Firebase su iOS NON passa da
  CocoaPods ma da Swift Package Manager (commento in `codemagic.yaml` righe
  371-376 e `docs/STATO_VIVO.md` riga 294: da CocoaPods passano solo
  google_mlkit_commons, google_mlkit_face_detection, record_darwin).

### b) Esiste la fase che carica i dSYM? SI', in Codemagic, non in Xcode

- `codemagic.yaml` righe 363-409, passo "I simboli dSYM su Crashlytics", dopo
  "L'archivio" (riga 336): trova il dSYM in
  `build/ios/archive/Runner.xcarchive/dSYMs` (riga 381, si ferma se manca),
  cerca `upload-symbols` nel checkout SPM di firebase-ios-sdk (riga 387, si
  ferma se ne trova 0 o piu' di 1), lo lancia con
  `-gsp ios/Runner/GoogleService-Info.plist -p ios .../dSYMs` (righe 407-409).
- `ios/Runner.xcodeproj/project.pbxproj`: `DEBUG_INFORMATION_FORMAT =
  "dwarf-with-dsym"` righe 359 e 561 (i dSYM si producono). Nessuna fase
  Run Script di Crashlytics: le uniche `PBXShellScriptBuildPhase` sono "Thin
  Binary" (riga 260, `xcode_backend.sh embed_and_thin`) e "Run Script"
  (riga 275, `xcode_backend.sh build`).
- Storia: la 2158 cadeva in quel passo con status 127 (cercava il caricatore in
  `ios/Pods/FirebaseCrashlytics`, che con SPM non esiste); corretto il 7 agosto
  sera (`docs/STATO_VIVO.md` riga 294).
- Non misurabile da qui: se l'ultimo giro Codemagic abbia caricato i simboli con
  successo (servono i registri del giro su Codemagic o la pagina "dSYM
  mancanti" della console Crashlytics). L'API v1alpha non espone i simboli.

Conclusione b): non manca una fase. Un'alternativa (non necessaria) sarebbe la
fase Run Script in Xcode con `${BUILD_DIR%/Build/*}/SourcePackages/checkouts/firebase-ios-sdk/Crashlytics/run`;
il passo Codemagic fa la stessa cosa dopo l'archivio e si ferma rumorosamente,
quindi la sconsiglio come doppione.

### c) Crashlytics ha ricevuto eventi dall'app iOS? NO, zero in 88 giorni

Come interroga lo strumento: `tool/i_crash_degli_utenti.py` righe 31-45:
`GET https://firebasecrashlytics.googleapis.com/v1alpha/projects/esoteric-circle/apps/{app}`
con `Authorization: Bearer $(gcloud auth print-access-token)` e
`x-goog-user-project: esoteric-circle`; l'app id lo prende SOLO da
`android/app/google-services.json` (righe 31-35), quindi lo strumento oggi non
sa leggere iOS.

Comandi (Git Bash, `T=$(gcloud auth print-access-token)`):

1. App iOS registrata, API di gestione Firebase:
   `curl -H "Authorization: Bearer $T" -H "x-goog-user-project: esoteric-circle" https://firebase.googleapis.com/v1beta1/projects/esoteric-circle/iosApps`
   Esito: `"appId": "1:425821975933:ios:02367eef4fafaaf0940814"`,
   `"displayName": "Esoteric Circle iOS"`, `"bundleId": "com.esotericircle.esotericCircle"`,
   `"state": "ACTIVE"`. Coincide col plist locale.
2. `GET .../apps/1:425821975933:ios:02367eef4fafaaf0940814/reports/topIssues?page_size=50`
   Esito: HTTP 200, corpo con solo `name`, `displayName: "Top Issues"`,
   `usage`; NESSUN campo `groups`.
3. Stessa chiamata con
   `&filter.interval.start_time=2026-07-10T00:00:00Z&filter.interval.end_time=2026-10-06T00:00:00Z`
   (88 giorni, prima dell'arrivo di Crashlytics il 7 agosto):
   iOS `topIssues` HTTP 200 gruppi 0; iOS `topVersions` HTTP 200 gruppi 0.
4. Controllo che la stessa chiamata funzioni, sull'app Android
   `1:425821975933:android:1b1ca4db8d4df69b940814`, stessa finestra:
   `topIssues` HTTP 200 gruppi 14 (il primo con `eventsCount 686`,
   `totalUsersCount 69`); `topVersions` gruppi 32; `topIssues` senza finestra
   (default 2026-09-29 / 2026-10-06) gruppi 4.
5. `GET .../apps/<ios>/events?page_size=20` senza filtro: HTTP 400
   `INVALID_ARGUMENT` (l'endpoint vuole un filtro, lo strumento passa sempre
   `filter.issue.id`; non e' un segnale su iOS).

Lettura: l'interrogazione e' giusta (su Android risponde con 14 problemi), su
iOS Crashlytics non ha MAI ricevuto un evento, fatale o non fatale, in 88
giorni. Questo NON distingue fra "nessun crash" e "SDK che non spedisce":
- su iOS i rapporti partono al riavvio successivo, e mai se il crash avviene
  col debugger attaccato;
- le uccisioni del sistema per memoria (jetsam) non sono crash e Crashlytics
  non le vede: e' quanto successo l'8 agosto, "Crashlytics vivo e muto",
  `docs/STATO_VIVO.md` riga 333;
- pero' anche i NON fatali (`GuastiVersoIlCruscotto`, `lib/main.dart` righe
  96-98) sono zero, e su Android sono decine: o l'iPhone di collaudo non ha mai
  avuto un guasto inoltrato, o su iOS gli eventi non arrivano. Non misurabile
  senza una prova.

### Cosa manca per iOS, descritto e NON fatto

1. Una prova che il canale iOS spedisce davvero. Proposta: una build TestFlight
   in cui un gesto nascosto di collaudo chiami
   `FirebaseCrashlytics.instance.recordError(Exception('prova FE.04 iOS'), StackTrace.current, reason: 'prova del canale iOS', fatal: false)`
   (non fatale: non serve far crollare l'app), aprire l'app sull'iPhone 13
   senza debugger, chiuderla e riaprirla, poi rifare la chiamata del punto 3.
   Finche' non c'e' un evento iOS letto, la voce FE.04 per iOS resta
   APERTA IN ATTESA DI VERIFICA.
2. Lo strumento `tool/i_crash_degli_utenti.py` legge solo Android (righe
   31-35). Modifica: aggiungere un'opzione `--ios` e, quando c'e', usare l'app id
   `1:425821975933:ios:02367eef4fafaaf0940814` (oppure leggerlo con
   `plistlib` da `ios/Runner/GoogleService-Info.plist` se il file c'e', con
   ripiego sulla costante perche' nel repo il plist non c'e'). In concreto:
   `def l_app(ios=False):` che ritorna la costante iOS se `ios`, e `chiedi`
   che riceve l'app id invece di chiamare `l_app()` a ogni richiesta; in
   `main()` `a.add_argument('--ios', action='store_true')`. Utile anche passare
   `filter.interval.start_time` ed `end_time` (oggi lo strumento vede solo gli
   ultimi 7 giorni, default dell'API, misurato al punto 4).
3. dSYM: nessuna modifica. Verificare solo sul registro dell'ultimo giro
   Codemagic iOS che il passo "I simboli dSYM su Crashlytics" sia verde.

Come si leggono i crash, da scrivere nel rapporto: Android e iOS con la stessa
API `firebasecrashlytics.googleapis.com/v1alpha/projects/esoteric-circle/apps/<app id>/reports/topIssues`
e `/events?filter.issue.id=...`; app id Android
`1:425821975933:android:1b1ca4db8d4df69b940814`, iOS
`1:425821975933:ios:02367eef4fafaaf0940814`; oppure console Firebase,
progetto esoteric-circle, Crashlytics, selettore dell'app.

---

## COMPITO 2, FE.21.3: il costo di Test Lab

### Listino ufficiale

`https://firebase.google.com/docs/test-lab/usage-quotas-pricing`, letto il 6
ottobre 2026 (WebFetch):
- "$5 per hour for each physical device"; "$1 per hour for each virtual device";
- piano Blaze, quota senza costo: 30 minuti al giorno sui fisici, 60 sui
  virtuali (Spark: 5 prove al giorno sui fisici, 10 sui virtuali);
- arrotondamento al minuto per eccesso: "a 22-second test is billed for one
  minute, while a 75-second test is billed for two minutes";
- "You are charged only for the time spent running tests (the time it takes to
  install your app and collect test results will not be charged)".
- La pagina non dice in quale fuso si conta "il giorno".

### Da dove vengono i minuti

- I file in `docs/collaudo/FE/test_lab/giro_*` non portano durate fatturabili
  (sono estratti di registro, video e, nel giro 1, `test_result_1.xml` e
  `instrumentation.results`).
- API Tool Results, che ha `deviceUsageDuration` per ogni passo:
  `curl ... https://toolresults.googleapis.com/toolresults/v1beta3/projects/esoteric-circle/histories`
  Esito: HTTP 403 `SERVICE_DISABLED`, "Cloud Tool Results API has not been used
  in project esoteric-circle before or it is disabled". Non l'ho accesa (sarebbe
  una modifica di configurazione).
- API Testing (`testing.googleapis.com/v1/projects/esoteric-circle/testMatrices/<id>`):
  funziona solo con l'id `matrix-...`. `matrix-1rh64u6ryqgzm` (giro 1):
  `FINISHED FAILURE`, `houji` API 35, "Test timed out", toolResultsStep
  `executionId 8233950107987997366`. Il numero `7235979973329992315` scritto
  nei registri del giro 3 e' un id di esecuzione di Tool Results, non di
  matrice: 404 sull'API Testing. Gli id `matrix-` degli altri giri non sono
  scritti da nessuna parte nel repo.
- Quindi ho misurato la durata di ogni dispositivo dal suo `logcat` nel bucket
  dei risultati `gs://test-lab-fbt34a4rtt0j6-hdmtwm4twzy7z/` (sola lettura,
  `gcloud storage ls` e `gcloud storage cat -r` sui primi e ultimi 200 kB):
  primo e ultimo istante del registro (orologio del dispositivo, UTC-7).
  Script: `scratchpad/spans.py`, uscita `scratchpad/spans.txt`. E' un TETTO:
  il registro comprende anche installazione e raccolta, che non si pagano.

Modelli (`gcloud firebase test android models describe`): `a16x` = samsung
Galaxy A16 5G, PHYSICAL; `a35x` = samsung Galaxy A35 5G, PHYSICAL; `houji` =
Xiaomi 14, PHYSICAL; `MediumPhone.arm` = Generic, VIRTUAL.

Nota: il LEGGIMI (righe 13-20) parla solo dello Xiaomi 14, ma i giri 3, 4 e
tappe sono girati su due Samsung con Android 16, non sullo Xiaomi.

### Tabella giro per giro (tetto dal logcat, 5 $/ora = 0,0833 $/minuto)

| Giro (cartella docs) | Cartella nel bucket | Dispositivo | Durata registro | Minuti (per eccesso) | Costo a listino |
|---|---|---|---|---|---|
| giro_1 | 2026-10-06_00:16:52_kgOd | Xiaomi 14 houji API 35 it | 650 s | 11 | 0,92 $ |
| giro_2_robo | 2026-10-06_00:36:20_xNJw | Xiaomi 14 houji API 35 it | 66 s | 2 | 0,17 $ |
| giro_3_a16x | 2026-10-06_02:29:15_SELu | Galaxy A16 5G API 36 it | 132 s | 3 | 0,25 $ |
| giro_3_a35x | 2026-10-06_02:29:15_SELu | Galaxy A35 5G API 36 it | 93 s | 2 | 0,17 $ |
| giro_3_innesto_a35x | 2026-10-06_02:32:32_Coda | Galaxy A35 5G API 36 it | 102 s | 2 | 0,17 $ |
| (non in docs) | 2026-10-06_02:43:19_QMom | Galaxy A16 en | 148 s | 3 | 0,25 $ |
| (non in docs) | 2026-10-06_02:43:19_QMom | Galaxy A16 it | 147 s | 3 | 0,25 $ |
| (non in docs) | 2026-10-06_02:43:19_TslX | Galaxy A16 it | 114 s | 2 | 0,17 $ |
| (non in docs) | 2026-10-06_02:53:29_ULdT | Galaxy A16 de | 139 s | 3 | 0,25 $ |
| (non in docs) | 2026-10-06_02:53:29_ULdT | Galaxy A16 en | 131 s | 3 | 0,25 $ |
| (non in docs) | 2026-10-06_02:53:29_ULdT | Galaxy A16 fr | 114 s | 2 | 0,17 $ |
| (non in docs) | 2026-10-06_02:53:29_ULdT | Galaxy A16 it | 126 s | 3 | 0,25 $ |
| giro_tappe_a16x (en) | 2026-10-06_03:08:36_JWZz | Galaxy A16 en | 116 s | 2 | 0,17 $ |
| giro_tappe_a16x (fr) | 2026-10-06_03:08:36_JWZz | Galaxy A16 fr | 128 s | 3 | 0,25 $ |
| giro_tappe_a16x (it) | 2026-10-06_03:08:36_JWZz | Galaxy A16 it | 145 s | 3 | 0,25 $ |
| giro_4_a16x-36-en | 2026-10-06_03:40:09_RKgj | Galaxy A16 en | 144 s | 3 | 0,25 $ |
| giro_4_a16x-36-fr | 2026-10-06_03:40:09_RKgj | Galaxy A16 fr | 136 s | 3 | 0,25 $ |
| giro_4_a16x-36-it | 2026-10-06_03:40:09_RKgj | Galaxy A16 it | 142 s | 3 | 0,25 $ |
| giro_4_a35x-36-it | 2026-10-06_03:40:09_RKgj | Galaxy A35 it | 81 s | 2 | 0,17 $ |

Abbinamento cartelle docs e bucket: dalla riga 2 dei `registro_estratto.txt`
dei giri 1, 2, 3 e innesto (che citano il percorso del bucket), e dagli orari
dei registri per tappe (18:14-18:15, cartella JWZz) e giro 4 (18:45-18:46,
cartella RKgj, commit d7e025b0).

Totale fisici: 58 minuti, 4,83 $ a listino. Giri documentati in docs: 13 (giri
1-2) + 7 (giro 3 e innesto) + 8 (tappe) + 11 (giro 4) = 39 minuti; i 19 minuti
di QMom, TslX e ULdT (sette dispositivi, due APK `fe_misura_cura.apk` e
`fe_misura_pezzi.apk`, una lingua `de`) non hanno cartella in docs.

Dentro la quota gratuita? Dipende dal fuso del "giorno", che la pagina non dice:
- se il giorno e' quello UTC: 5 ottobre 13 minuti (giri 1-2, 22:21-22:43 UTC)
  dentro i 30; 6 ottobre 45 minuti (00:33-01:48 UTC), 15 oltre la quota, 1,25 $;
- se il giorno e' quello del Pacifico (orologio dei dispositivi, tutti fra le
  15:22 e le 18:47 del 5 ottobre): 58 minuti in un giorno, 28 oltre la quota,
  2,33 $.
In ogni caso un tetto: il costo vero e' sotto, perche' installazione e raccolta
non si pagano. Il numero esatto si legge solo in Fatturazione (o accendendo
Tool Results, che decide il fondatore).

Scostamenti dal LEGGIMI (righe 67-72): giro 1, LEGGIMI 12 minuti (00:22:34-
00:33:47), registro 650 s cioe' 11; giro 2, LEGGIMI 1 minuto (23 secondi del
crawl), registro 66 s cioe' 2 (il registro comprende l'avvio). La frase
"Tredici minuti in tutto" (riga 72) vale solo per i giri 1 e 2: la notte ne ha
usati 58 sui fisici.

Giro virtuale in piu': `gs://.../1:425821975933:android:1b1ca4db8d4df69b940814/12d92pon7vjao/.../MediumPhone.arm-30-en_US-portrait/`,
3 ottobre 2026 22:37 UTC, registro 643 s, 11 minuti virtuali, 0,18 $ a
listino, dentro i 60 gratuiti. La cartella per app id fa pensare a un giro
automatico (Robo di App Distribution o simile), non lanciato a mano: PROVENIENZA
da confermare.

---

## COMPITO 3, FE.21.1: l'emulatore

### Le due frasi

- `docs/collaudo/FE/emulatore/avvio_su_questo_pc.txt` righe 21-22:
  "ERROR | x86_64 emulation currently requires hardware acceleration!" e
  "CPU acceleration status: Android Emulator hypervisor driver is not installed
  on this machine". Righe 13-14: "hasCompatibleHypervisor ... Ok".
- `docs/collaudo/FE/test_lab/LEGGIMI.md` righe 89-91: "l'emulatore non parte,
  perché la virtualizzazione è spenta nel firmware".

### Misure (sola lettura)

- `systeminfo`: "ERRORE: Classe non valida" (exit 36). Nessuna sezione
  "Requisiti Hyper-V" stampata.
- `Get-CimInstance Win32_Processor | Select VirtualizationFirmwareEnabled`:
  "Classe non valida", HRESULT 0x80041010.
- `(Get-CimInstance Win32_ComputerSystem).HypervisorPresent`: "Classe non
  valida", HRESULT 0x80041010.
- `wmic cpu get ...`: "cpu - Alias non trovato."
- `winmgmt /verifyrepository`: "Verifica dell'archivio WMI non riuscita, Codice
  errore 0x80041003, Accesso negato" (serve l'amministratore).
  Quindi su questo PC il registro WMI non risponde alle classi base: i tre
  comandi chiesti NON possono misurare la virtualizzazione nel firmware.
- `sc query aehd`: TIPO 1 KERNEL_DRIVER, STATO 1 STOPPED,
  CODICE_USCITA_WIN32 4294967201 (0xffffffa1).
- `sc qc aehd`: TIPO_AVVIO 1 SYSTEM_START, binario
  `\SystemRoot\system32\DRIVERS\aehd.sys`, NOME_VISUALIZZATO "Android Emulator
  hypervisor driver Service". Il driver E' installato.
- `sc query gvm`: "[SC] ... 1060: Il servizio specificato non esiste come
  servizio installato."
- `sc query hvservice`: STOPPED, CODICE_USCITA_WIN32 1077 (mai avviato): il
  hypervisor di Hyper-V non gira (requisito di AEHD rispettato).
  `vmcompute` RUNNING (Host Compute Service, non e' il hypervisor).
- `emulator.exe -accel-check` (Sdk\emulator): "accel: 6", "Android Emulator
  hypervisor driver is not installed on this machine".
- `wevtutil qe System` eventi 7000/7026: 5 ottobre 11:21:51Z e 11:17:38Z,
  7000 "Il servizio Android Emulator hypervisor driver Service non è stato
  avviato per il seguente errore: %%4294967201"; 2 ottobre 03:01:07Z, 7026
  "All'avvio non è stato possibile caricare i seguenti driver: aehd, dam".
- CPU (registro `HKLM\HARDWARE\DESCRIPTION\System\CentralProcessor\0`):
  "Intel(R) Core(TM) i5-3450 CPU @ 3.10GHz" (Ivy Bridge; la scheda Intel ARK
  non si e' caricata, timeout, quindi il supporto VT-x/EPT del modello non e'
  verificato online da me).
- Requisiti AEHD (github.com/google/android-emulator-hypervisor-driver):
  "CPU has virtualization extension and BIOS has NOT disabled the extension." e
  "Hyper-V must be disabled."

### Quale e' vero

Letterale: e' vero il messaggio dell'emulatore, ma e' impreciso. Il driver AEHD
e' installato (sc qc) e fallisce l'avvio a ogni accensione con 0xffffffa1;
l'emulatore, non trovandolo in esecuzione, dice "not installed".
La frase del LEGGIMI ("virtualizzazione spenta nel firmware") e' la causa piu'
probabile di quel fallimento (Hyper-V spento, driver presente che rifiuta di
partire), ma NON e' misurata: i comandi che la misurerebbero falliscono per il
WMI rotto. Formulazione onesta per il LEGGIMI: "il driver dell'emulatore (aehd)
e' installato ma non parte (errore 0xffffffa1 all'avvio, eventi 7000 e 7026);
la causa probabile e' la virtualizzazione spenta nel BIOS, non misurabile da
Windows perche' il WMI risponde 'Classe non valida'. Si misura entrando nel
BIOS, o dal Task Manager, scheda Prestazioni, CPU, riga Virtualizzazione".

### Lo schermo del Redmi Note 14 Pro 5G

- Fonte ufficiale Xiaomi, `https://www.mi.com/uk/product/redmi-note-14-pro-5g/specs/`
  (HTTP 200, letta con curl): "6.67” AMOLED display". Risoluzione
  "2712 x 1220 (1.5K resolution)" (stessa pagina e
  `https://www.mi.com/global/product/redmi-note-14-pro-5g/specs/`). La pagina
  global via WebFetch rispondeva 403; via curl con user agent da browser 200.
  Il codice modello 24090RA29G non compare nell'estratto che ho cercato.
- `docs/collaudo/FE/emulatore/config_redmi_note_14_pro_5g.ini`: NON dichiara i
  pollici (nessuna chiave di diagonale). Dichiara `hw.lcd.width=1220` (r.132),
  `hw.lcd.height=2712` (r.133), `hw.lcd.density=440` (r.134),
  `hw.device.name=Redmi Note 14 Pro 5G (24090RA29G)` (r.135). Diagonale
  implicita: sqrt(1220^2+2712^2) = 2973,8 px / 440 = 6,76 pollici, contro i
  6,67 ufficiali; la densita' fisica vera e' 2973,8 / 6,67 = circa 446 ppi
  (440 e' il bucket Android piu' vicino, scarto 1,3 per cento).
