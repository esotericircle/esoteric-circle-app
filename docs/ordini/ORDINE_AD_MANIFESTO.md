# ORDINE AD. LA CUSTODIA CON GOOGLE PASSA AL FLUSSO NATIVO

Tre voci, da AD.01 a AD.03. Ramo `claude/esoteric-circle-master-order-e798aj`,
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

## Le tre voci

- **AD.01** La via Google diventa nativa — APERTA
- **AD.02** La correzione del test del server entra nella storia — APERTA
- **AD.03** Il manifesto e il rapporto — APERTA

## I marcatori, contati sulle righe

VOCI_TOTALI: 3
VOCI_APERTE: 3
VOCI_CHIUSE: 0
VOCI_FERMATE_SU_PREMESSA_FALSA: 0
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0
