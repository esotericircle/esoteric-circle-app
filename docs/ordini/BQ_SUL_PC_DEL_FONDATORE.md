# I CINQUE LAVORI CHE SOLO IL PC DEL FONDATORE PUO' FARE

Questo file esiste perche' l'ordine dei cinque lavori e' arrivato a una sessione
che **non gira sul PC del fondatore**: gira in un contenitore Linux in cloud, e
li' non ci sono ne' i video, ne' `ffprobe`, ne' `gcloud`, ne' `firebase`, ne'
l'SDK Android. Verificato e non supposto, il 25 agosto 2026:

| cosa | esito della verifica |
|---|---|
| sistema | `Linux vm 6.18.44-fc-v21 x86_64`, cartella `/home/user/esoteric-circle-app` |
| `D:\Clienti Roogly\...` | non esiste, ne' come `D:` ne' come `/mnt/d` |
| `ffprobe`, `ffmpeg` | assenti |
| `gcloud` | assente |
| `firebase` | assente |
| `adb`, `aapt2` | assenti |
| `ANDROID_HOME` | vuoto |

**Cio' che la sessione in cloud ha potuto fare lo ha fatto**, ed e' scritto in
fondo. Tutto il resto sta qui sotto in una sequenza sola, da eseguire in
PowerShell dal PC del fondatore. **Nessuna credenziale compare in questo file e
nessuna va incollata in chat.**

## Prima di tutto

```powershell
cd C:\Users\user\Desktop\esoteric-circle-app
git fetch origin claude/esoteric-circle-master-order-e798aj
git pull --ff-only origin claude/esoteric-circle-master-order-e798aj
```

## 1. I tre video nel repository

Copia, non spostare: gli originali restano dove sono.

```powershell
$da = "D:\Clienti Roogly\Rituali Cartomanzia\App\Video Maestri\OK"
$a  = "C:\Users\user\Desktop\esoteric-circle-app\brand_assets\maestri"

Copy-Item -LiteralPath "$da\Medora Sorceress Video.mp4" -Destination "$a\medora_rivelazione.mp4"
Copy-Item -LiteralPath "$da\Caligo.mp4"                 -Destination "$a\caligo_rivelazione.mp4"
Copy-Item -LiteralPath "$da\Aura-1.mp4"                 -Destination "$a\aura_rivelazione.mp4"

Get-ChildItem $a -Filter *.mp4 | Select-Object Name, Length
```

I nomi devono essere **esattamente** questi: minuscoli, senza spazi. Il codice li
compone da solo con `RivelazioneInVideo.assetDi`, e una prova nella suite
pretende che siano tutti minuscoli, senza spazi e distinti fra loro.

## 2. I dati dei tre video, misurati

Se `ffprobe` non risponde, si installa con `winget install Gyan.FFmpeg` e poi si
riapre PowerShell.

```powershell
Get-ChildItem $a -Filter *.mp4 | ForEach-Object {
  Write-Host "===" $_.Name $_.Length "byte"
  ffprobe -v error -show_entries format=duration,bit_rate `
          -show_entries stream=codec_type,codec_name,width,height,r_frame_rate `
          -of default=noprint_wrappers=1 -- $_.FullName
}
```

Per ognuno dei tre serve: **durata, risoluzione, fotogrammi al secondo, codec,
presenza o assenza di traccia audio, peso**. Se in uscita compare un solo blocco
`codec_type=video` e nessun `codec_type=audio`, quel filmato **non ha audio**, ed
e' un dato da scrivere e non da dare per scontato. Il velo mette il volume a zero
comunque, quindi un audio presente non si sentirebbe: ma sapere se c'e' cambia
il peso che si puo' togliere quando i video verranno ottimizzati.

## 3. Il commit, un file per volta

**Mai un `git add` di tutto**: il 22 agosto tre filmati entrati insieme hanno
fatto morire il push per ore.

```powershell
git add brand_assets/maestri/medora_rivelazione.mp4
git commit -m "BQ.01: il video di rivelazione di Medora"
git add brand_assets/maestri/caligo_rivelazione.mp4
git commit -m "BQ.01: il video di rivelazione di Caligo"
git add brand_assets/maestri/aura_rivelazione.mp4
git commit -m "BQ.01: il video di rivelazione di Aura"
git push -u origin claude/esoteric-circle-master-order-e798aj
git ls-remote origin claude/esoteric-circle-master-order-e798aj
```

L'ultima riga deve stampare lo stesso identificativo di `git rev-parse HEAD`.

Poi in `docs/ordini/ORDINE_BQ_MANIFESTO.md` la voce **BQ.01** passa da
`FERMATA SU PREMESSA FALSA` a `CHIUSA`, con la data e coi dati veri di `ffprobe`,
e i marcatori in fondo al file diventano `VOCI_FERMATE_SU_PREMESSA_FALSA: 1` e
`VOCI_CHIUSE: 5`. **La guardia `test/ordine_bq_guard_test.dart` conta le righe e
i marcatori: se i due non coincidono, cade.**

## 4. La build

Il numero di versione **e' gia' stato portato a `0.1.0+2206`** dalla sessione in
cloud, insieme a questo file: non va toccato di nuovo.

```powershell
$env:TZ = "Europe/Rome"
flutter test
```

**L'unico rosso ammesso e' l'attribuzione cieca**, dichiarato dall'ordine BP. Su
qualunque altro rosso ci si ferma e non si spedisce.

```powershell
flutter build apk --release --target-platform android-arm64
(Get-Item "build\app\outputs\flutter-apk\app-release.apk").Length
aapt2 dump badging "build\app\outputs\flutter-apk\app-release.apk" | Select-String versionCode
```

Un solo archivio arm64, **mai `--split-per-abi`**, che sommava duemila al numero.
Il numero vero si legge dall'archivio e non dal `pubspec`. Il peso dell'APK va
dichiarato **prima e dopo i video**: il "prima" e' quello dell'ultima build
consegnata, il "dopo" e' questo.

```powershell
firebase appdistribution:distribute "build/app/outputs/flutter-apk/app-release.apk" --app 1:425821975933:android:1b1ca4db8d4df69b940814 --testers "cloud@esotericircle.app" --release-notes "I tre video di rivelazione dei Maestri, provvisori: due col watermark e da ingrandire, tutti da ottimizzare"
```

Poi `docs/versione_distribuita.json` si aggiorna col numero appena consegnato e
con la release restituita dal comando, **dopo** la consegna riuscita e mai prima.

## 5. L'attribuzione cieca, tre giri

```powershell
gcloud auth list
flutter test tool/attribuzione_cieca.dart
flutter test tool/attribuzione_cieca.dart
flutter test tool/attribuzione_cieca.dart
```

Per ogni giro servono quattro cose: la **matrice di confusione** per intero, la
riga **`Attribuzione corretta`**, la riga **`Verdetti illeggibili`** e il blocco
**`RITMO DELLE VOCI`**, che prima dell'ordine BP non esisteva.

**COSA GUARDARE NEL RITMO, ed e' la ragione per cui quel blocco e' stato
scritto.** Il registro di Caligo, riscritto dalla voce BP.02, chiede frasi mai
oltre una dozzina di parole e **nessuna domanda**. Nel blocco del ritmo la riga
di `caligo` porta la frase mediana in parole e il numero di domande:

- se la **frase mediana di Caligo e' scesa** rispetto a quella degli altri due e
  le sue **domande sono a zero**, il registro nuovo ha morso. Se in quel caso
  l'attribuzione resta sotto la soglia, **la causa non e' piu' il registro** e
  cercarla li' e' tempo perso;
- se invece la frase mediana e' rimasta lunga o le domande ci sono ancora, il
  registro **non** e' arrivato al modello come chiesto, e li' si torna a
  lavorare.

I tre giri si scrivono in `lib/services/ai/impronta_dell_istruzione.dart` come
prescrive BP.05, e le impronte non vanno toccate: se la prova
`l'impronta dell'istruzione coincide con quella registrata` e' verde, i tre giri
sono presi sulla stringa giusta. **`attribuzioneValida` resta FALSO e la soglia
resta 85** finche' i numeri non dicono altro.

## Cosa ha gia' fatto la sessione in cloud

- Allineamento col remoto verificato: locale e `origin` sono lo stesso commit.
- **Versione portata a `0.1.0+2206`** nel `pubspec.yaml`, con le due prove di
  `test/versione_build_test.dart` verdi.
- **Suite intera con `TZ=Europe/Rome` ad albero fermo**, cioe' il cancello del
  punto 4, gia' sulla versione 2206: **3.659 verdi e 2 rossi**. Il rosso vero e'
  uno solo, l'attribuzione cieca, dichiarato; l'altro e'
  `niente_lavoro_non_spinto`, che dice il vero solo ad albero pulito e si e'
  chiuso col commit di questo file. **Il cancello e' aperto**: sul PC restano da
  rifare solo i test toccati dai tre video, ma il codice che li aspetta e' gia'
  passato per intero.
- Questo file.

Cio' che **non** ha fatto, e non poteva: copiare i video, misurarli, commetterli,
chiudere BQ.01, costruire, consegnare, eseguire l'attribuzione cieca. Nessuna di
quelle cose e' stata dichiarata fatta da nessuna parte.
