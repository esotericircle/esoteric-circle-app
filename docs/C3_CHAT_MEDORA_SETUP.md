# C3, passo 1: chat con Medora. Setup dal telefono, senza PC

Questa guida e' pensata per farti accendere e provare la chat di Medora avendo
solo un telefono Android, senza usare il computer. Niente riga di comando,
niente `flutterfire`, niente `flutter run`, niente `firebase deploy`. Tutto si
fa dal browser del telefono (console Firebase e GitHub) e dall'app.

Regola d'oro rispettata: nessuna chiave Gemini nel client, nessun segreto su
Git. La chat passa da Firebase AI Logic, che chiama Gemini su Vertex e si
protegge con App Check. La memoria, quando Firestore e' pronto, sta su
Firestore; se non e' pronto, la chat gira lo stesso con memoria di sessione.

## Cosa devi fare tu, in breve

1. In console Firebase, registra l'app Android e abilita AI Logic.
2. Scarica `google-services.json` e mettilo su GitHub come secret.
3. Lancia la build da GitHub, scarica l'APK, installalo, prova.

App Check resta in modalita' debug senza enforcement, quindi la prima prova
risponde senza dover leggere nessun token. Firestore non serve per la prima
prova.

## Cosa NON serve piu'

- `firebase_options.dart`: non serve. Su Android, Firebase e firebase_ai si
  configurano dal solo `google-services.json`. Non devo generare nessun file
  Dart aggiuntivo, e non ti serve `flutterfire`.
- Nessun comando da PC in nessun passo.

## Passo 1: registra l'app Android nella console Firebase

Dal browser del telefono, sulla console Firebase del progetto
`esoteric-circle`:

1. Apri Impostazioni progetto, sezione Le tue app, e aggiungi un'app Android.
2. Nome del pacchetto, esattamente: `com.esotericircle.esoteric_circle`.
3. Completa la registrazione e scarica il file `google-services.json` che la
   console ti offre. Salvalo sul telefono, lo useremo al passo 3.

## Passo 2: abilita Firebase AI Logic

Sempre in console Firebase:

1. Apri la voce AI Logic (in alcune console e' sotto Build, o si chiama
   Firebase AI).
2. Scegli il provider Vertex AI Gemini e completa l'attivazione, confermando
   quando ti chiede di abilitare le API necessarie. Il billing e' gia' su
   Blaze, non serve altro.

## Passo 3: metti google-services.json su GitHub come secret

Il file di configurazione non va su Git: lo diamo alla build come secret.

1. Apri il contenuto di `google-services.json` come testo (un qualsiasi editor
   di testo o app file sul telefono lo apre).
2. Su GitHub, nel repository, apri Settings, poi Secrets and variables, poi
   Actions, e crea un secret chiamato `GOOGLE_SERVICES_JSON`.
3. Incolla dentro il contenuto del file. Puoi incollare il JSON cosi' com'e',
   oppure la sua versione in base64 se preferisci: la build accetta entrambi.

## Passo 4: App Check in debug, senza enforcement (per ora)

1. In console Firebase apri App Check e registra l'app Android.
2. Lascia l'enforcement disattivato per l'API AI Logic. Cosi' la prima prova
   risponde senza bisogno di alcun token.
3. L'app usa il provider di debug di App Check, quindi i token vengono comunque
   generati.

Quando vorrai attivare l'enforcement, non servira' il PC: dentro la chat, in
alto a destra, il tasto Messa a punto mostra a schermo il token di debug di App
Check, con un tasto per copiarlo. Lo incolli poi in console, nella lista dei
token di debug dell'app. Se all'inizio dice non disponibile, invia un messaggio
e riapri: il token compare dopo la prima chiamata.

## Passo 5: costruisci l'APK da GitHub e installalo

1. Su GitHub apri la scheda Actions.
2. Scegli il workflow Android build (APK debug) e premi Run workflow sul branch
   `claude/esoteric-circle-master-order-e798aj`. Parte anche da solo a ogni
   push su quel branch.
3. Al termine, nella pagina del run, scarica l'artifact
   `esoteric-circle-debug-apk`. Dentro c'e' `app-debug.apk`.
4. Apri l'APK sul telefono e installalo (potresti dover consentire
   l'installazione da origini sconosciute).

## Passo 6: prova

1. Apri l'app, dalla barra in basso entra nella sezione di Medora, tocca Parla
   con Medora.
2. Alla prima apertura compare il disclaimer, una volta sola.
3. Scrivi: la chat risponde in italiano, con la voce di Medora, e tiene il filo
   del discorso.

## Firestore, dopo la prima prova

La memoria persistente su Firestore non serve per la prima prova: se Firestore
non e' pronto, la chat gira con memoria di sessione (si ricorda dentro la stessa
apertura, non fra un avvio e l'altro). Quando vorrai attivarla:

1. In console Firebase crea il database Firestore in modalita' produzione,
   regione europe-west1.
2. Apri la scheda Regole e incolla il contenuto del file `firestore.rules` di
   questo repository, poi pubblica. Ogni utente vedra' solo il proprio ramo di
   memoria.

Da quel momento la chat ricorda anche fra un avvio e l'altro, e nel pannello
Messa a punto la voce Memoria diventa persistente.

## Lo screenshot automatico della chat

Ho aggiunto un secondo workflow, Chat screenshot (Medora), che gira su un
emulatore, apre la chat e cattura la schermata. Usa un Medora offline con
risposte gia' pronte, quindi non serve nessun secret ne' rete: valida solo la
UI. Lo trovi in Actions, e lo screenshot esce come artifact
`medora-chat-screenshot`. La prova della risposta vera di Vertex resta l'APK sul
telefono.

## Se qualcosa non risponde

- Se la chat mostra Il cerchio non e' ancora acceso: manca il
  `google-services.json` (secret) o l'AI Logic non e' attiva. Rivedi i passi 1,
  2 e 3.
- Se scrive Le stelle si sono velate: la richiesta e' partita ma non e'
  tornata. Con l'enforcement disattivato di solito e' l'API AI Logic non ancora
  abilitata, oppure il progetto senza billing attivo.
- Il modello di Medora e' `gemini-2.5-flash`, scelto per costo e velocita' nella
  Demo. Si alza a un modello Pro cambiando una sola costante in
  `firebase_maestro_ai_provider.dart`, quando vorrai la voce piu' ricca.

## Cosa NON e' in questo passo (arriva dopo, uno alla volta)

- Voce Gemini-TTS.
- Avatar animati a stati (idle, speaking, greeting).
- Cablaggio delle funzioni Coming soon al runtime.
