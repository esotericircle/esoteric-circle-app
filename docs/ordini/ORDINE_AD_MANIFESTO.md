# ORDINE AD. LA CUSTODIA CON GOOGLE PASSA AL FLUSSO NATIVO

Cinque voci, da AD.01 a AD.05: le prime tre dell'ordine, le due della coda iOS. Ramo `claude/esoteric-circle-master-order-e798aj`,
premesse verificate sulla testa `fef509e` il 16 agosto 2026.

## Perche' quest'ordine esiste

Il 16 agosto 2026, su telefono vero (RMX5056, Android 16, build 0.1.0+2178 in
profile), la custodia con Google e' morta al ritorno dal consenso con l'errore
"Unable to process request due to missing initial state ... signInWithRedirect
in a storage-partitioned browser environment", fotografato. E' il flusso web via
redirect che i browser Android con lo storage partizionato non reggono: nessuna
configurazione di console lo salva, e la console e' gia' a posto. La via
d'uscita e' il flusso nativo di Google agganciato con `linkWithCredential`.

## Come si legge questo file

Una riga per voce, con lo stato in fondo. Gli stati ammessi sono quattro:

- **CHIUSA**, il lavoro e' finito e provato;
- **FERMATA SU PREMESSA FALSA**, la voce chiedeva di correggere qualcosa che
  misurato non risulta;
- **FERMATA IN ATTESA DI DECISIONE**, il lavoro di Code e' finito e resta solo
  una scelta del founder;
- **APERTA**, e finche' una riga e' aperta la guardia
  `test/ordine_ad_guard_test.dart` resta rossa.

Le voci non si rinumerano, non si accorpano e non si dichiarano coperte da
un'altra. I marcatori in fondo si contano sulle righe, non si scrivono a
memoria.

## Le premesse, verificate una per una il 16 agosto 2026

1. **P1 VERA.** `lib/core/identity/account_del_cerchio.dart` riga 155: il ramo
   google di `eleva` chiama `utente.linkWithProvider(GoogleAuthProvider())`.
2. **P2 VERA.** `pubspec.yaml` non contiene `google_sign_in`, cercato: zero
   occorrenze.
3. **P3 VERA, e l'ordine puo' procedere.** `android/app/google-services.json`
   sul disco porta tre `oauth_client`, e uno ha `client_type` 3: il client web
   da cui nasce l'idToken esiste.
4. **P4 VERA.** Le prove che nominano `PortaDellIdentita` o `AccountDelCerchio`
   sono due, `l_elevazione_non_perde_niente_test.dart` e
   `prima_dopo_capture_test.dart`, e nessuna delle due importa `firebase_auth`.
5. **P5 VERA.** L'albero porta la modifica non committata a
   `functions/src/cerchio.test.ts`: l'aspettativa sulle gettate free passa da 3
   a 1, e `functions/src/budget.ts` porta gia' `gettate: [1, null, null, null]`.
   Nell'albero ci sono anche due file non tracciati, `docs/preview/
   journal_loto_nuovo-1.png` e `preview.webp`, che nessuna voce copre e che non
   si toccano.

**Le premesse della coda, verificate il 16 agosto 2026:**

6. **P6 VERA.** `ios/Runner/GoogleService-Info.plist` esiste sul disco e porta
   `REVERSED_CLIENT_ID` con valore
   `com.googleusercontent.apps.425821975933-vq6jtskejop8aibnlrqjs7v15ud66849`.
   **Non e' committato**: il gitignore lo esclude alla riga 145. **Codemagic lo
   prende dalla variabile d'ambiente `GOOGLE_SERVICE_INFO_PLIST`**: lo script in
   `codemagic.yaml` righe 131 e seguenti la decodifica da base64, o la scrive
   come XML grezzo, dentro `ios/Runner/GoogleService-Info.plist` a ogni build.
7. **P7 FALSA, e il lavoro esiste gia'.** `ios/Runner/Info.plist` DICHIARA
   `CFBundleURLTypes` con lo schema esattamente uguale al `REVERSED_CLIENT_ID`
   del file sul disco, messo li' dall'ordine S voce 14 causa 2, col commento che
   lo spiega.
8. **P8 FALSA, e il lavoro esiste gia'.** `ios/Runner/Runner.entitlements`
   esiste, e' COMMITTATO, porta `com.apple.developer.applesignin` al valore
   `Default`, ed e' agganciato con `CODE_SIGN_ENTITLEMENTS` in TUTTE e tre le
   configurazioni di `project.pbxproj`. Ordine S voce 14 causa 3. Il commento nel
   file dichiara anche che il portale Apple ha gia' la capacita' accesa
   sull'identificativo `com.esotericircle.esotericCircle`.

**Le guardie che la coda avrebbe chiesto esistono gia'**, in
`test/l_accesso_si_apre_davvero_test.dart`, e sono verdi: lo schema di ritorno
confrontato col `REVERSED_CLIENT_ID` vero (con il salto dichiarato quando il
file manca), e le entitlements agganciate a tutte e tre le configurazioni,
contate.

## Le cinque voci

- **AD.01** La via Google diventa nativa — CHIUSA. Chiusa il 24 agosto 2026 (BF.03): il collaudo e' avvenuto di fatto, il fondatore ha percorso il flusso Google nativo dalla 2183 fino alla cancellazione e nuova registrazione di BF.01, e l'errore missing initial state non e' mai piu' comparso.
- **AD.02** La correzione del test del server entra nella storia — CHIUSA
- **AD.03** Il manifesto e il rapporto — CHIUSA
- **AD.04** Lo schema URL di Google nel progetto iOS — FERMATA SU PREMESSA FALSA
- **AD.05** Sign in with Apple, la parte che vive nel repository — FERMATA SU PREMESSA FALSA

## Cosa deve provare il founder perche' la AD.01 si chiuda

Sul telefono, con la build in profile che porta la via nativa: aprire la
custodia, scegliere Google, completare il flusso nella FINESTRA NATIVA (non piu'
una pagina web su firebaseapp.com), e leggere l'esito a schermo. Se l'account
Google scelto e' maobatta@gmail.com, che in console esiste gia' dal 14 agosto,
l'esito giusto a schermo e' quello del "gia' di un altro Cerchio", non un
errore generico: anche quello e' un collaudo riuscito, perche' dice la verita'.

## I marcatori, contati sulle righe

VOCI_TOTALI: 5
VOCI_APERTE: 0
VOCI_CHIUSE: 3
VOCI_FERMATE_SU_PREMESSA_FALSA: 2
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0