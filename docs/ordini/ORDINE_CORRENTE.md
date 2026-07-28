# ORDINE D, la sicurezza prima della pubblicazione

Emesso dall'Architetto in Cowork il 29 luglio 2026. Sostituisce l'ordine precedente, che e' chiuso per le tre voci dichiarate.

## Che cosa e'

Quattro voci piccole, tutte dello stesso oggetto: le cose che possono far respingere l'app in revisione oppure esporre Mauro sul piano della conformita'. Nessuna e' estetica, nessuna richiede una decisione di prodotto.

Vengono dall'audit della dimensione sicurezza, mai esaminata prima, chiusa il 29 luglio con cinque reperti confermati su cinque da un verificatore indipendente istruito a refutare.

## Dichiarazione all'inizio, obbligatoria

Prima di scrivere codice, stima e scrivi in `docs/ordini/ESITO_D.md` se chiudi per intero e fin dove arrivi, con la ragione in numeri. Ha funzionato le ultime due volte, quindi resta.

---

## D1. Il diritto all'oblio cancella davvero, foto del volto compresa

**Punto**: `lib/core/identity/profile_store.dart:27` e `lib/features/settings/settings_screen.dart`, dentro `_DeleteDataTile._confirmAndDelete`.

`ProfileStore` custodisce le otto chiavi piu' personali dell'app: `profile.name`, `profile.courtesy`, `profile.birthDate`, `profile.hasBirthTime`, `profile.birthHour`, `profile.birthMinute`, `profile.place` con latitudine e longitudine, e alla riga 37 `profile.avatarPhoto`, che e' il base64 della **fotografia del volto** della persona. La classe espone `load`, `saveProfile`, `saveIdentity`, `loadAvatarPhoto`, `saveAvatarPhoto`, e nessun metodo che cancelli: in tutto il repository non esiste un percorso di codice che rimuova quelle chiavi.

Il tasto "Cancella i miei dati" chiama la sola `services.memory.deleteAllData()`, che cancella esclusivamente il ramo Firestore `users/{uid}`. Il locale resta intero, e siccome `ProfileController.load()` lo rilegge all'avvio, nome, vocativo, data di nascita, luogo e fotografia ricompaiono dopo che la persona ha esercitato la cancellazione.

La finestra di conferma promette il contrario in modo esplicito: "Lasceremo andare tutto il tuo cammino: profilo, ricordi dei Maestri e conversazioni", e la riga dice "Profilo, ricordi e conversazioni. Il tuo diritto all'oblio". Il test in `test/settings_test.dart` si intitola "La cancellazione GDPR chiede conferma e azzera i dati" e verifica soltanto il repository in memoria, quindi il buco non era presidiato.

Sopravvivono anche `device.id`, che tiene stabile l'identita' deterministica dei Doni, e le chiavi di `ritual_streak.dart` e `sunset_rune_memory.dart`.

**Correzione.** Dare a `ProfileStore` un `clear()` che rimuova le otto chiavi `profile.*` piu' `device.id` e le chiavi dei riti. Dare a `ProfileController` un `forget()` che azzeri profilo, identita' e fotografia e chiami quel `clear()`. In `_confirmAndDelete` invocare sia la cancellazione remota sia quella locale, dentro lo stesso try. Poi estendere il test esistente alle chiavi locali, cosi' il titolo che dice "azzera i dati" diventa vero.

## D2. La fotografia del volto non esce col backup automatico di Android

**Punto**: `android/app/src/main/AndroidManifest.xml:20`.

Il tag `<application>` non porta `android:allowBackup="false"`, non porta `android:fullBackupContent` e non porta `android:dataExtractionRules`, e in `android/app/src/main/res/` non esiste alcuna cartella `xml` con regole di backup. Con `minSdk 23` il Backup Automatico di Android e' attivo col valore predefinito, che include i file di `SharedPreferences`. Dentro quei file c'e' `profile.avatarPhoto`, cioe' il volto della persona, insieme alla data e al luogo di nascita.

Due schermate dell'app promettono che nessuna immagine lascia il dispositivo.

**Correzione.** Disattivare il backup per le chiavi personali. La strada minima e' `android:allowBackup="false"`. La strada migliore, se non costa molto, e' tenere il backup attivo escludendo le chiavi personali con `dataExtractionRules` per Android 12 e successivi piu' `fullBackupContent` per i precedenti, cosi' l'utente non perde le preferenze innocue cambiando telefono. Scegli tu e dichiara quale hai scelto.

## D3. La build di release non e' piu' firmata con la chiave di debug

**Punto**: `android/app/build.gradle.kts:35`.

Il blocco `release` porta `signingConfig = signingConfigs.getByName("debug")`, col commento generato da Flutter che dice di sostituirlo. Ogni build di release e' quindi firmata con la chiave di debug, che sta sul disco di chiunque abbia Flutter: la firma non identifica nessuno, l'app e' falsificabile, e Google Play rifiuta il caricamento.

**Correzione.** Predisporre la configurazione di firma che legge chiave, alias e password da un file `key.properties` **non versionato**, con il percorso dichiarato nel `.gitignore`. Non serve che la chiave esista adesso: serve che il Gradle sia pronto e che la build di release fallisca con un messaggio chiaro se il file manca, invece di firmare con quella di debug in silenzio. La generazione del keystore vero la fara' Mauro quando pubblicheremo.

## D4. La callable natalChart guarda cosa le viene mandato

**Punto**: `functions/src/index.ts:45`.

La funzione inoltra al servizio a pagamento il corpo che le manda il client senza validarlo. Chi possiede un token App Check valido, che si ottiene semplicemente installando l'app, puo' quindi far fare al progetto chiamate arbitrarie verso un servizio a consumo.

**Correzione.** Validare i campi attesi prima di inoltrare: anno, mese, giorno, ora, minuto, latitudine, longitudine, fuso. Tipi giusti, intervalli plausibili, nessun campo estraneo inoltrato. Rifiutare con un errore esplicito quello che non passa. Aggiungere un limite di frequenza per utente se e' poco costoso, altrimenti dichiararlo come cosa non fatta.

Nella stessa passata guarda `firestore.rules:15`: le regole non impongono ne' forma ne' dimensione a quello che il client scrive sotto il proprio ramo. Metti almeno un tetto alla dimensione dei documenti e ai campi ammessi.

---

## Criteri di accettazione, in numeri

- Dopo la cancellazione, zero delle chiavi `profile.*` sopravvive nelle preferenze. Un test le elenca una per una e le verifica tutte, poi ricostruisce il controller e verifica che l'app non conosca piu' la persona.
- La fotografia del volto non e' piu' recuperabile dopo la cancellazione. Il test lo verifica sul valore, non sulla chiave.
- Il manifest esclude i dati personali dal backup. Un test legge il manifest e fallisce se l'esclusione manca.
- La build di release non usa la configurazione di firma di debug. Un test legge il Gradle e fallisce se ci trova `getByName("debug")` dentro il blocco release.
- La callable rifiuta almeno sei corpi malformati diversi: campo mancante, tipo sbagliato, latitudine fuori intervallo, longitudine fuori intervallo, mese impossibile, campo estraneo. Un test per ciascuno.
- Le regole Firestore impongono un tetto di dimensione. Dichiara come lo hai verificato.
- Suite intera verde, `flutter analyze` pulito, zero nuovi avvisi, integrita' verde, numero di versione non inferiore a 2100.

## Autorizzazione

Itera da solo finche' i numeri passano, debug incluso. Non chiedere conferme su scelte interne.

## Alla fine

```
flutter build apk --debug --target-platform android-arm64 --dart-define=APP_CHECK_DEBUG_TOKEN=2f4013f2-e6e7-49b2-a3aa-402f28cd365a
```

```
firebase appdistribution:distribute "build/app/outputs/flutter-apk/app-debug.apk" --app 1:425821975933:android:1b1ca4db8d4df69b940814 --testers "cloud@esotericircle.app" --release-notes "Sicurezza prima della pubblicazione"
```

Esito in `docs/ordini/ESITO_D.md` coi numeri misurati. **Poi fermati.**

Niente trattino lungo. Mai la virgola prima della "e" congiunzione.
