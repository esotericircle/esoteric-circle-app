# ORDINE CORRENTE per Claude Code

Emesso dall'Architetto in Cowork il 28 luglio 2026, notte. Sostituisce l'ordine precedente, che è chiuso.

## Titolo

L'identità di nascita diventa vera.

## Perché, con le prove

Prima accensione dell'app su dispositivo reale, ieri notte. Osservato, non ipotizzato.

1. Il Cosmic Passport mostra sempre il profilo d'esempio. `lib/features/shell/app_shell.dart:48` costruisce `const CosmicPassport()` senza passare l'identità, e `lib/features/passport/cosmic_passport_screen.dart:49` ripiega su `BirthIdentity.example`. L'identità reale però esiste ed è persistita: `onboarding_screen.dart:153` chiama `profile.setIdentity`, che salva in `profile_store.dart:145`. Il dato c'è, nessuno glielo passa. A schermo si vede numero della vita 4 invece di 3, fase lunare del 15 giugno 1990, animale guida della data sbagliata, più la riga "Valore d'esempio" sempre accesa da `cosmic_passport_screen.dart:416`.

2. La schermata del luogo di nascita non permette di scegliere nulla. Digitando "busto Arsizio" non compare alcun suggerimento, non esiste un elenco da toccare, e la sola azione in fondo è "Salta per ora" (`onboarding_screen.dart:398-427`). Il testo di aiuto promette un elenco che non esiste.

3. Saltando il luogo il codice non lascia il campo vuoto, lo inventa. `onboarding_screen.dart:182-186`, `_placeForChart()` ritorna `latitude: 0, longitude: 0, timezone: 'UTC'`. La carta natale viene quindi chiesta a FreeAstroAPI per un punto nel Golfo di Guinea, e Ascendente e dodici case che l'utente legge come proprie sono di quel punto. È una violazione del punto 9 del GATE UX nella forma più grave: la schermata dichiara "il cielo autentico della tua notte" mentre calcola un altro luogo.

4. Nella schermata "Il tuo cielo di nascita" la didascalia della Luna dice "la luce cala e lascia andare stanotte". È testo scritto per il cielo di stanotte, riusato senza cambiare tempo.

## Cosa fare

### A. Il luogo di nascita si può scegliere davvero

Metti nell'app un elenco offline di luoghi, con nome, latitudine, longitudine e fuso IANA. Niente servizio di geocoding online: porterebbe una chiave, un costo, una latenza e una dipendenza dalla rete, contro il principio deterministico su dispositivo del progetto.

Copertura minima: tutti i comuni italiani, più una selezione di città del mondo sufficiente a coprire le capitali e i grandi centri. Formato compatto, caricato una volta e indicizzato in memoria.

La ricerca è per prefisso, insensibile agli accenti e alle maiuscole. Mostra i risultati sotto il campo mentre si digita, ognuno toccabile, con il nome della località e la sua provincia o nazione per distinguere gli omonimi.

La scelta è esplicita: si tocca un risultato, il campo mostra il luogo scelto, e solo allora l'azione in fondo diventa "Continua". Senza luogo l'azione resta "Salta per ora" e la schermata dichiara con una riga sola che cosa si perde saltando, cioè Ascendente e case.

**Vincolo architetturale, aggiunto il 28 luglio dopo la decisione sulla modifica dei dati di nascita.** La ricerca del luogo va scritta come componente riusabile, con il suo indice e la sua logica di ricerca separati dalla schermata dell'onboarding. Non incollarla dentro `onboarding_screen.dart`. La stessa identica ricerca servirà fra due ordini nella schermata di correzione dei dati di nascita, che verrà costruita nel Passport. Se la scrivi legata all'onboarding, fra due ordini si riscrive da capo.

### B. Basta coordinate inventate

`_placeForChart()` non deve più fabbricare `0, 0, UTC`. Se il luogo manca, la carta natale non si chiede con coordinate finte: si chiede senza luogo, oppure non si chiede affatto, e l'app dichiara che Ascendente e case non sono calcolabili. Nessun numero mostrato all'utente può nascere da un luogo che non è il suo.

### C. Il Passport legge l'identità vera

`app_shell.dart:48` deve passare l'identità reale, quella di `ProfileController`. Che sia la fonte giusta è già dimostrato dall'uso che ne fa `maestro_screen.dart` in `_userSign`. Con identità reale la riga "Valore d'esempio" sparisce, con identità assente resta.

Ricadono nella stessa correzione il portale del cielo di nascita (`cosmic_passport_screen.dart:135`), il Sigillo (137) e l'animale guida (139), che oggi ricevono tutti il dato d'esempio.

### D. Il testo del cielo di nascita

Togli "stanotte" dalla didascalia della Luna nella schermata del cielo di nascita. Quel testo parla della notte in cui la persona è nata, non di stasera. Controlla nello stesso passaggio che nessun altro testo di quella schermata sia stato preso in prestito dal cielo di stanotte.

## Criteri di accettazione, in numeri

- L'elenco dei luoghi contiene almeno 7900 comuni italiani e almeno 200 località estere, ciascuna con latitudine, longitudine e fuso IANA non nulli. Un test conta le righe e verifica che nessun campo sia vuoto.
- Digitando `busto` la voce "Busto Arsizio" compare fra i primi cinque risultati.
- Digitando `citta di cast`, senza accento, compare "Città di Castello".
- Digitando `roma` compaiono sia Roma sia gli omonimi, distinguibili dalla provincia.
- Con luogo nullo l'azione in fondo ha etichetta "Salta per ora"; con luogo scelto ha etichetta "Continua". Un test verifica entrambe.
- Un test verifica che il payload inviato alla callable NON contenga mai `lat: 0` insieme a `lng: 0` come valore di ripiego.
- Un test monta l'app con un'identità reale registrata e verifica che nel Passport la riga "Valore d'esempio" NON compaia, e che il numero della vita mostrato coincida con quello calcolato dalla data reale. Lo stesso test con identità assente verifica il contrario.
- Nessuna occorrenza della parola "stanotte" nei testi della schermata del cielo di nascita.
- Il peso dell'APK non cresce di più di 2 MB rispetto ai 218,2 MiB attuali.
- Suite intera verde, `flutter analyze` pulito, zero nuovi avvisi.

## GATE UX per la schermata del luogo

Una sola azione vera in fondo, con area di tocco piena. Una sola riga di guida. I risultati della ricerca sono tocchi veri, non testo decorativo. Se l'utente salta, glielo si dice una volta sola e senza colpevolizzare. Arte brandizzata, mai glifi di sistema. Accenti veri, niente trattino lungo, mai una proposizione dopo la virgola che inizi con la lettera e.

## Fuori scope, non toccare adesso

I due motori lunari e le due implementazioni del numero della vita restano come sono: sono il prossimo ordine e vanno corretti insieme, alla radice. Non toccare `docs/STATO_VIVO.md`. Non toccare `ORDINE_ENTITLEMENT.md`.

## Alla fine

Ricostruisci e distribuisci, così Mauro verifica dal telefono:

```
flutter build apk --debug --split-per-abi --dart-define=APP_CHECK_DEBUG_TOKEN=2f4013f2-e6e7-49b2-a3aa-402f28cd365a
```

```
firebase appdistribution:distribute "build/app/outputs/flutter-apk/app-arm64-v8a-debug.apk" --app 1:425821975933:android:1b1ca4db8d4df69b940814 --testers "cloud@esotericircle.app,info@esotericircle.com" --release-notes "Luogo di nascita reale, Passport con identita' vera"
```

## Autorizzazione

Itera da solo finché i numeri passano, debug incluso. Non chiedere conferme su scelte interne di implementazione.

## Come riportare

In `docs/ordini/ESITO_CORRENTE.md`: cosa hai fatto per ciascuno dei quattro punti, esito di ogni criterio numerico, percorso e peso del nuovo APK, esito della distribuzione, e per esteso qualunque cosa sia andata storta.
