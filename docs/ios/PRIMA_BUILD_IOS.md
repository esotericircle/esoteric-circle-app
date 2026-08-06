# LA PRIMA BUILD IOS, passo per passo

Scritto il 6 agosto 2026, per Mauro, presupponendo che Codemagic non l'abbia mai
visto. Nessuna riga qui presuppone che tu sappia cos'e' un profilo di firma o un
archivio: dove serve, si dice anche quello.

**Una cosa da sapere prima di cominciare, perche' cambia le aspettative.** Questo
progetto non e' mai stato compilato per iOS. La prima build di un progetto iOS
mai compilato **fallisce quasi sempre**, e non e' un guasto: e' il modo in cui si
scoprono le cose che su Windows non si potevano vedere. Il passo 7 dice dove
leggere l'errore, ed e' la parte piu' utile di questo documento.

---

## Cosa c'e' gia', e cosa manca

**Gia' fatto, dal ramo `claude/ios-1-b1e463`:**

- `GoogleService-Info.plist` e' **dichiarato** nel progetto Xcode: come
  riferimento di file, dentro il gruppo Runner, e dentro la fase di copia delle
  risorse del target Runner. Senza quest'ultima l'app si costruisce, parte, e
  crolla appena tocca Firebase.
- La versione minima di iOS e' **15.0** nei tre punti del progetto.
- `codemagic.yaml` sta nella radice del repository.

**Da fare a mano, e sono i passi qui sotto:** il gruppo dei tester, la variabile
con la configurazione Firebase, e il lancio.

### Perche' nella cartella `ios/` non c'e' il Podfile

Non manca niente. Il `Podfile` lo genera Flutter alla prima build **su macOS**,
e su Windows non si puo' produrre: per questo non e' nel repository. Il workflow
lo fa creare da solo, con `flutter build ios --config-only --no-codesign`, prima
di installare i pod. Se apri la cartella `ios/` e non lo trovi, e' normale.

---

## Passo 1. Collegare il repository a Codemagic

1. Vai su **codemagic.io** e accedi.
2. In alto a sinistra c'e' l'elenco delle applicazioni: premi **Add application**.
3. Scegli **GitHub** come sorgente. Se e' la prima volta, Codemagic ti chiede il
   permesso di leggere i repository: dai il consenso solo a
   `esotericircle/esoteric-circle-app`.
4. Nell'elenco che compare, scegli **esoteric-circle-app** e premi
   **Finish: Add application**.
5. Alla domanda sul tipo di progetto scegli **Flutter App (Codemagic YAML)**.
   E' importante: dice a Codemagic di leggere il file `codemagic.yaml` che sta
   nel repository, invece di chiederti la configurazione a video.

## Passo 2. Il gruppo dei tester interni, su App Store Connect

Questo passo si fa su **appstoreconnect.apple.com**, non su Codemagic. Serve
prima della build, altrimenti il caricamento riesce e nessuno riceve niente.

1. Entra su **appstoreconnect.apple.com** con l'ID Apple del team.
2. Premi **App**, poi scegli **Esoteric Circle**.
3. In alto scegli la scheda **TestFlight**.
4. Nella colonna a sinistra, sotto **Tester interni**, premi il **+** accanto a
   **Gruppi**.
5. Chiama il gruppo esattamente **Interni**, con la I maiuscola. Il nome deve
   coincidere con quello scritto in `codemagic.yaml`: se scrivi un nome diverso,
   il caricamento riesce ma il gruppo non viene trovato.
6. Dentro il gruppo, premi **+** accanto a **Tester** e aggiungi te stesso.

**Perche' i tester interni e non quelli esterni.** I tester interni possono
installare appena il caricamento e' stato processato, di solito in una decina di
minuti. I tester esterni aspettano una revisione di Apple, che dura giorni:
per provare l'app non serve.

## Passo 3. La variabile con la configurazione Firebase

Il file `GoogleService-Info.plist` **non sta nel repository**, ed e' una
decisione: porta le chiavi e gli identificativi del progetto Firebase, e il
repository e' pubblico. La macchina di build lo scrive da una variabile cifrata,
esattamente come gia' avviene per Android col `google-services.json`.

### 3a. Generare la stringa dal tuo PC Windows

Apri **PowerShell** e incolla questo comando, tutto insieme. Ti mette la stringa
gia' negli appunti, cosi' non devi selezionarla a mano:

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("C:\Users\user\Desktop\esoteric-circle-app\ios\Runner\GoogleService-Info.plist")) | Set-Clipboard
```

Non compare niente a video: e' giusto cosi', la stringa e' negli appunti.

Se vuoi vederla prima di incollarla, usa questo invece:

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("C:\Users\user\Desktop\esoteric-circle-app\ios\Runner\GoogleService-Info.plist"))
```

E' una riga lunga di lettere e numeri, senza spazi e senza a capo. Deve
cominciare con `PD94bWwg`, che e' come si scrive `<?xml ` in base64: se comincia
in un altro modo, hai copiato il file sbagliato.

### 3b. Incollarla su Codemagic

1. Su Codemagic, dalla pagina dell'applicazione, premi **Settings**.
2. Nella colonna a sinistra scegli **Environment variables**.
3. Compila i tre campi:
   - **Variable name**: `GOOGLE_SERVICE_INFO_PLIST`
     Scritto esattamente cosi', tutto maiuscolo, con gli underscore. Se sbagli
     una lettera la build si ferma al primo passo con un messaggio chiaro.
   - **Variable value**: incolla la stringa del passo 3a (in PowerShell,
     `Ctrl+V` la incolla).
   - **Variable group**: scrivi `firebase` e premi invio per crearlo.
4. **Spunta la casella `Secure`.** E' quella che rende la variabile cifrata: da
   quel momento nessuno, te compreso, potra' piu' rileggerla da Codemagic, e nei
   registri comparira' come `***`. Se un giorno serve di nuovo, si rigenera col
   comando del passo 3a.
5. Premi **Add**.

**Il gruppo `firebase` va poi collegato al workflow.** Nella stessa pagina, in
alto, controlla che sotto il workflow `ios-testflight` il gruppo `firebase`
risulti selezionato; se non lo e', spuntalo.

## Passo 4. Controllare che la chiave di Apple sia collegata

L'integrazione si chiama **esoteric_asc** ed e' gia' configurata: e' la chiave
di App Store Connect, quella che permette a Codemagic di firmare e caricare
senza il tuo Mac.

1. Su Codemagic, in alto a destra, premi sull'icona del tuo profilo, poi
   **Teams**, poi il tuo team.
2. Scegli **Integrations**, poi **App Store Connect**.
3. Controlla che nell'elenco compaia **esoteric_asc**. Deve esserci: il file
   `codemagic.yaml` la nomina con questo nome esatto.

Se non c'e', o se ha un altro nome, **non rinominarla su Codemagic**: dimmelo, e
cambio il nome dentro `codemagic.yaml`. Cambiarlo da una parte sola rompe la
firma.

## Passo 5. Il numero di build

Su TestFlight ogni caricamento deve avere un numero **piu' alto** del
precedente, esattamente come su Android. Il numero e' uno solo per tutte e due
le piattaforme e sta in `pubspec.yaml`, alla riga `version:`.

Oggi vale **2157**, ed e' gia' stato consegnato su Android. Il primo caricamento
iOS deve quindi partire almeno da **2158**.

**Chi lo alza:** lo alza chi prepara la consegna, in `pubspec.yaml`, prima di
lanciare la build. Non lo alza Codemagic e non lo alza uno script, per una
ragione precisa: il contatore e' condiviso con Android, e due macchine che lo
alzano per conto proprio lo fanno divergere. Se la build iOS lo alzasse da sola,
la prossima consegna Android partirebbe da un numero gia' bruciato.

## Passo 6. Lanciare la build

1. Su Codemagic, dalla pagina dell'applicazione, premi **Start new build** in
   alto a destra.
2. Nella finestra che si apre:
   - **Branch**: scegli il ramo dove sta il lavoro iOS.
   - **Workflow**: deve comparire **iOS, archivio e caricamento su TestFlight**.
     E' l'unico, perche' il piano gratuito da' cinquecento minuti al mese e due
     workflow li finirebbero prima di avere una app installabile.
3. Premi **Start new build**.

Da qui in avanti guardi i passi scorrere. La prima build e' la piu' lenta,
perche' la macchina deve scaricare tutti i pod: metti in conto una ventina di
minuti, e ricorda che quei minuti si scalano dai cinquecento.

---

## Passo 7. QUANDO LA BUILD FALLISCE

Fallira'. Non e' pessimismo: e' la prima compilazione di un progetto iOS mai
compilato, e su Windows non c'era modo di verificarla. Ecco dove guardare.

### Dove sta l'errore vero

Nella pagina della build, i passi sono in fila e quello caduto ha la crocetta
rossa. **Premi sul nome di quel passo**: si apre il registro.

**L'errore vero non e' l'ultima riga.** L'ultima riga dice quasi sempre soltanto
`Command failed`, che non serve a niente. L'errore vero sta piu' su, ed e' la
prima riga che contiene `error:` in minuscolo. Nel registro c'e' un campo di
ricerca: cerca `error:` e leggi la **prima** occorrenza, non l'ultima.

Se il passo caduto e' l'archivio, in fondo alla pagina della build trovi anche
gli **Artifacts**: fra questi c'e' `xcodebuild_logs`. Quello e' il registro
completo di Xcode, ed e' li' che sta la ragione quando il riassunto a video non
la dice.

### I fallimenti che aspetto, e cosa vogliono dire

**"Manca la variabile GOOGLE_SERVICE_INFO_PLIST"**
Il passo 3 non e' stato fatto, oppure il nome della variabile ha una lettera
diversa, oppure il gruppo `firebase` non e' collegato al workflow. Non e' un
guasto di iOS: e' il controllo che ho messo apposta per non scoprirlo dopo, sul
telefono.

**Un errore che nomina `deployment target` o `minimum iOS version`**
Un pacchetto pretende una versione di iOS piu' alta dei 15.0 che il progetto
dichiara. Copiami il nome del pacchetto e la versione che chiede: si alza il
numero nei tre punti del progetto, con la ragione scritta accanto.

**Un errore che nomina `provisioning profile` o `signing`**
La firma automatica non e' riuscita a ottenere il profilo da Apple. Di solito e'
uno di tre motivi: l'identificativo del pacchetto non esiste ancora sul
Developer Portal, la chiave `esoteric_asc` non ha i permessi giusti, oppure il
contratto di sviluppatore non e' stato accettato. Il registro dice quale dei tre.

**Un errore dentro `pod install`, che nomina `CocoaPods`**
Due pacchetti pretendono versioni incompatibili della stessa libreria. Copiami
le righe che nominano i due pacchetti: si risolve in `pubspec.yaml`, non qui.

**Un errore che nomina `Swift Compiler` e un file `.swift`**
Codice nativo che non compila. E' il caso in cui i registri di Xcode servono
davvero: mandami il file e il numero di riga.

**Il caricamento riesce ma su TestFlight non compare niente**
Aspetta dieci minuti: Apple processa l'archivio prima di renderlo installabile.
Se dopo mezz'ora ancora non c'e', guarda su App Store Connect, scheda
**TestFlight**: se la build c'e' ma e' in giallo, Apple sta ancora processando;
se c'e' un avviso rosso, Apple l'ha rifiutata e la ragione e' scritta li'.

### Cosa mandarmi quando fallisce

Tre cose, e bastano:

1. Il **nome del passo** caduto, come si legge nella colonna dei passi.
2. Le **venti righe attorno** alla prima occorrenza di `error:`.
3. Se il passo era l'archivio, il file `xcodebuild_logs` dagli Artifacts.

Non serve che tu capisca l'errore: serve che io lo veda.

---

## Cosa NON va fatto, mai

- **Non mettere il file `.p8` nel repository.** E' la chiave privata di Apple:
  chi ce l'ha puo' caricare app a tuo nome. Sta su Codemagic, dentro
  l'integrazione, e li' resta.
- **Non togliere `GoogleService-Info.plist` dal `.gitignore`.** Il repository e'
  pubblico. Una prova, `test/il_progetto_ios_dichiara_firebase_test.dart`, cade
  se quel file finisce sotto Git.
- **Non alzare il numero di build su Codemagic.** Il contatore e' condiviso con
  Android: si alza in `pubspec.yaml`, in un posto solo.
