# C3, passo 1: chat con Medora. Cosa serve per vederla dal telefono

Questo documento raccoglie i pochi passi manuali che restano a te, Mauro, per
accendere la chat di Medora e provarla su un telefono Android. Il codice e'
gia' pronto e strutturato cosi': la UI non conosce ne' Firebase ne' Gemini,
parla solo con uno strato astratto (`MaestroAiProvider` e
`MaestroMemoryRepository`). Domani ci si potra' mettere davanti il gateway di
caching senza toccare la UI.

Regola d'oro rispettata: nessuna chiave Gemini nel client, nessun segreto su
Git. La chat passa da Firebase AI Logic, che chiama Gemini su Vertex e si
protegge con App Check. La memoria della Demo sta su Firestore.

I passi sono da fare una volta sola. Dove serve, presuppongo zero conoscenza
tecnica pregressa.

## Riepilogo di cosa e' stato costruito

- Strato AI astratto e sostituibile (`lib/services/ai/`), con l'implementazione
  reale su Gemini via Firebase AI Logic (backend Vertex, regione europe-west1).
- Persona di Medora e regole di lingua (`maestro_persona.dart`): italiano, niente
  trattino lungo, niente proposizione dopo la virgola che inizia con "e",
  fondamento su tradizioni reali, benessere e non cura.
- Memoria persistente su Firestore (`lib/services/memory/`): profilo, fatti,
  sintesi di sessione. Evoluzione futura verso Cloud SQL con pgvector dietro la
  stessa astrazione.
- Schermata di chat a tema Medora (`lib/features/maestri/chat/`): livello visivo
  prima del testo (presenza del Maestro e indicatore astrale), disclaimer una
  sola volta, avviso in tono se l'AI non e' ancora configurata, mai un errore
  crudo.
- Avvio tollerante ai guasti: se manca la configurazione, l'app parte lo stesso
  e la chat lo segnala con garbo.

## Passo 1: abilita Firebase AI Logic sul progetto

1. Vai sulla console Firebase del progetto `esoteric-circle`.
2. Nel menu a sinistra apri la voce AI Logic (in alcune console si chiama
   "Firebase AI" o sta sotto Build).
3. Scegli il provider Vertex AI Gemini e segui la procedura guidata di
   attivazione. Conferma quando ti chiede di abilitare le API necessarie
   (Vertex AI). Il billing e' gia' su Blaze, quindi non serve altro.

## Passo 2: registra le app e scarica la configurazione

Il modo piu' semplice, dal tuo PC, nella cartella del progetto:

1. Installa una volta lo strumento: `dart pub global activate flutterfire_cli`.
2. Esegui: `flutterfire configure --project=esoteric-circle`.
3. Quando chiede le piattaforme, seleziona Android (e iOS se vuoi, per ora
   basta Android).
4. Per Android usa come identificativo dell'app esattamente
   `com.esotericircle.esoteric_circle`.

Questo crea `lib/firebase_options.dart` e scarica
`android/app/google-services.json`. Sono file di configurazione, non segreti in
senso stretto, ma per igiene restano fuori da Git (li ho gia' messi in
`.gitignore`) e si iniettano in build.

In alternativa, senza flutterfire: dalla console Firebase aggiungi un'app
Android con quel package name e scarica a mano `google-services.json` in
`android/app/`.

## Passo 3: attiva App Check

1. In console Firebase apri App Check.
2. Registra l'app Android con provider Play Integrity.
3. Per provare subito su un telefono in debug: alla prima apertura l'app stampa
   nel log un token di debug di App Check. In App Check, nella gestione dei
   token di debug dell'app, incolla quel token. Da quel momento le richieste
   passano anche con l'enforcement attivo.
4. Consiglio: attiva l'enforcement sull'API AI Logic solo quando la chat gia'
   funziona, cosi' escludi una variabile alla prima prova. Il codice attiva
   comunque App Check, quindi i token vengono generati fin da subito.

## Passo 4: pubblica le regole di Firestore

Ho aggiunto `firestore.rules`: ogni utente vede solo il proprio ramo di
memoria. Per pubblicarle, dal PC nella cartella del progetto:

```
firebase deploy --only firestore:rules
```

Se Firestore non fosse ancora inizializzato, la console ti guida a crearlo in
modalita' produzione, regione europe-west1 (come gia' previsto).

## Passo 5: la build con GitHub Actions

In questo ambiente Flutter e Dart non compilano, quindi la build la fa un
workflow che ho aggiunto: `.github/workflows/android-build.yml`. Produce un APK
di debug da installare sul telefono.

Prima serve dare al workflow la configurazione Firebase, senza metterla su Git:

1. Sul tuo PC, trasforma il file in una riga di testo (base64):
   - macOS o Linux: `base64 -i android/app/google-services.json`
   - Windows PowerShell:
     `[Convert]::ToBase64String([IO.File]::ReadAllBytes("android/app/google-services.json"))`
2. Copia tutto il testo risultante.
3. Su GitHub, nel repository, vai in Settings, poi Secrets and variables, poi
   Actions, e crea un secret chiamato `GOOGLE_SERVICES_JSON` incollando quel
   testo.
4. Su GitHub apri la scheda Actions, scegli il workflow "Android build (APK
   debug)" e premi Run workflow sul branch
   `claude/esoteric-circle-master-order-e798aj`. Parte anche da solo a ogni
   push su quel branch.
5. Al termine, nella pagina del run, scarica l'artifact
   `esoteric-circle-debug-apk`. Dentro c'e' `app-debug.apk`.

## Passo 6: installa e prova

1. Trasferisci l'APK sul telefono Android e installalo (potrebbe servire
   consentire l'installazione da origini sconosciute).
2. Apri l'app, entra nella sezione di Medora dalla barra in basso, tocca "Parla
   con Medora".
3. Alla prima apertura compare il disclaimer, una volta sola. Poi scrivi: la
   chat risponde in italiano, con la voce di Medora, e ricorda il filo del
   discorso.

In alternativa alla build su GitHub, se hai il telefono collegato via USB al PC,
puoi anche fare piu' rapidamente `flutter run` dalla cartella del progetto, dopo
il passo 2.

## Se qualcosa non risponde

- Se la chat mostra "Il cerchio non e' ancora acceso": manca la configurazione
  Firebase o l'AI Logic non e' attiva. Rivedi i passi 1 e 2.
- Se scrive "Le stelle si sono velate": la richiesta e' partita ma non e'
  tornata. Spesso e' App Check con enforcement attivo senza il token di debug
  registrato (passo 3), oppure l'API AI Logic non abilitata.
- Il modello usato per Medora e' `gemini-2.5-flash`, scelto per costo e
  velocita' nella Demo. Si alza a un modello Pro cambiando una sola costante in
  `firebase_maestro_ai_provider.dart`, quando vorrai la voce piu' ricca.

## Cosa NON e' in questo passo (arriva dopo, uno alla volta)

- Voce Gemini-TTS.
- Avatar animati a stati (idle, speaking, greeting).
- Cablaggio delle funzioni Coming soon al runtime.
