# ESITO dell'ORDINE D, la sicurezza prima della pubblicazione

## Dichiarazione, scritta prima di toccare il codice

**Chiudo D1, D2 e D3. Su D4 chiudo la validazione, sui suoi test non prometto.**

La ragione in numeri. D1 tocca due file gia' noti, `profile_store.dart` e
`settings_screen.dart`, con otto chiavi da rimuovere piu' tre di contorno: il
`clear()` che serve esiste gia' da ieri, va esteso e collegato al tasto, col
test scritto in Dart come tutti gli altri. D2 e' un attributo nel manifest
piu' due file di regole. D3 e' un blocco di quindici righe nel Gradle.

D4 e' diverso per un motivo che non riguarda la difficolta' della validazione,
che e' semplice, ma il modo di verificarla: `functions/package.json` non ha
alcun runner di test, ne' jest ne' mocha, con due sole dipendenze. I sei corpi
malformati che l'ordine chiede vanno eseguiti da qualche parte, che oggi non
esiste. Node 20 porta `node:test` di suo, quindi la strada c'e'
senza aggiungere pacchetti, ma passa dalla compilazione TypeScript e da un
comando di prova che non ho mai lanciato in questo repository. Se fila, i sei
test ci sono; se non fila, la validazione resta, con la mancanza scritta qui.

Le regole Firestore le guardo nella stessa passata, dichiarando come le ho
verificate: senza emulatore avviato non si eseguono, quindi al massimo posso
leggerle.

## D1, il diritto all'oblio: FATTO

Il `clear()` che serviva era nato ieri per il ripristino del Risveglio, ma
copriva le sole otto chiavi del profilo, mentre dal tasto della cancellazione
non lo chiamava nessuno.

Ora si cancella **per prefisso** invece che per elenco chiuso: `profile.`,
`sunset_rune.`, `archetipo.`, `allowance.`, `ritual.`, `streak.`, `greeting.`,
piu' `device.id` per nome. Una chiave personale aggiunta domani sotto uno di
quei prefissi cade da sola, mentre un elenco scritto a mano resta indietro senza
che nessuno se ne accorga: il diritto all'oblio non puo' dipendere da chi si
ricorda di aggiornare una lista. Non si svuotano tutte le preferenze, perche'
li' dentro stanno pure cose che della persona non parlano.

`ProfileController.forget()` azzera profilo, identita' e fotografia in memoria,
poi chiama quel `clear()`. Il tasto invoca **entrambe** le meta' dentro lo stesso
try, la remota su Firestore piu' la locale.

Il test parte da un telefono pieno e verifica, dopo la cancellazione: zero
chiavi `profile.*`, zero `device.id`, zero chiavi dei riti, la fotografia non
piu' recuperabile **sul valore e non sulla chiave**, il token di debug di App
Check ancora al suo posto perche' della persona non parla, piu' il controller
ricostruito che non conosce piu' ne' il nome ne' l'anno di nascita.

## D2, il backup: FATTO, con la strada migliore

Scelta la strada migliore invece del minimo `allowBackup="false"`:
`dataExtractionRules` per Android 12 e successivi, `fullBackupContent` per i
precedenti, in due file nuovi sotto `res/xml/`. Escludono il solo
`FlutterSharedPreferences.xml`, dove stanno la fotografia del volto, la data e
il luogo della nascita. Il backup resta attivo per il resto, quindi cambiando
telefono non si perde tutto: si perde il Risveglio, che dura un minuto.

Il test legge il manifest e i due file, per verificare che escludano davvero le
preferenze: dichiarare le regole senza escludere niente non servirebbe.

## D3, la firma di release: FATTO, dopo due errori miei

Il Gradle legge chiave, alias e password da `android/key.properties`, gia'
coperto da `.gitignore`. Se il file manca la build di release si ferma con un
messaggio chiaro.

Due errori miei lungo la strada, tutti e due colti dalla build.

Il primo, il piu' istruttivo: avevo messo la guardia dentro
`buildTypes { release { ... } }`, ma Gradle valuta quel blocco a OGNI build, non
solo quando costruisce una release. Il risultato e' che bloccava anche il debug,
cioe' rompeva il ciclo di prova. Ora la guardia sta in un `doFirst` sui task di
Release: scatta all'esecuzione, tace in tutti gli altri casi.

Il secondo: dentro il blocco `android` del DSL Kotlin, `java.util.Properties` e
`java.io.FileInputStream` non si risolvono senza import in testa al file.

**Provato in tutti e due i versi**, che e' l'unico modo per dire che funziona:
`flutter build apk --debug` costruisce, `flutter build apk --release` si ferma
con "Firma di release assente: manca android/key.properties".

## D4, la callable: FATTO, test compresi

Nella dichiarazione avevo detto che sui test non promettevo, perche'
`functions/package.json` non aveva alcun runner. Node 20 porta `node:test` di
suo, quindi la strada c'era senza aggiungere pacchetti: `npm test` dentro
`functions/` compila e lancia.

La validazione sta in `functions/src/validate.ts`, senza dipendenze da Firebase
cosi' si prova senza emulatori. Il corpo non viene filtrato, viene
**ricostruito campo per campo**: quel che parte verso il servizio a consumo e'
solo cio' che la validazione ha scritto: un campo estraneo non passa nemmeno
per distrazione.

**Undici test, tutti verdi.** I sei chiesti dall'ordine ci sono tutti: campo
mancante, tipo sbagliato, latitudine fuori intervallo, longitudine fuori
intervallo, mese impossibile, campo estraneo. Piu' cinque che ho aggiunto
guardando i modi in cui una data puo' essere finta: il 30 febbraio, il 29
febbraio in un anno non bisestile, i fusi che non sono nomi IANA, gli anni prima
del 1900 oppure nel futuro, i corpi che non sono oggetti.

### Le regole Firestore

Aggiunto un tetto di centomila byte per documento, con la condizione di
scrittura spostata in due funzioni leggibili. Senza tetto, un client compromesso puo'
riempire il progetto scrivendo documenti da un megabyte l'uno, che e' il limite
di Firestore.

**Come le ho verificate, detto per intero: le ho lette, non eseguite.** Le regole
girano sul server oppure nell'emulatore, che qui non e' avviato. Un
test Dart controlla che il tetto sia scritto nel file, il che impedisce che
sparisca per distrazione, senza pero' provare che si comporti come credo. La prova vera
si fa con l'emulatore. Non l'ho fatta.

## Suite, APK, consegna

`flutter test`: **824 test verdi**, erano 820. `flutter analyze`: pulito.
`npm test` in `functions/`: 11 verdi. APK unico arm64, **271.010.150 byte, cioe'
258,46 MiB**, integrita' verde sulle otto famiglie, versione 2100.

Un test esistente e' diventato rosso per causa mia, ed era rosso giusto: il
tasto della cancellazione ora legge il `ProfileController` dal contesto, che
`settings_test.dart` non forniva.

**La consegna NON e' avvenuta.** Il CLI di Firebase risponde "Your credentials
are no longer valid. Please run firebase login --reauth": le credenziali con cui
ho distribuito cinque release oggi sono scadute nel frattempo. Rifare il login
richiede un'autenticazione interattiva che non tocca a me: la fa Mauro con

    firebase login --reauth

e poi il comando di distribuzione dell'ordine, che e' pronto. L'APK e'
costruito, verificato e fermo sul disco, quindi manca solo il caricamento.
