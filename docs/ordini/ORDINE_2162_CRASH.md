# ORDINE 2162, IL CRASH ALL'AVVIO. Emergenza.

CODE PORTA A TERMINE TUTTO L'ORDINE, OGNI VOCE, FINO ALLA CONSEGNA. Non si ferma a meta', non rimanda voci, non lascia lavoro da ordinare di nuovo. Se il contesto si stringe, comprime i rapporti e non il lavoro. L'unica fermata ammessa e' una premessa falsa, oppure la Voce 3 se la causa impone di disfare qualcosa che Mauro ha ordinato.

Ramo canonico `claude/esoteric-circle-master-order-e798aj`. Ultima testa nota `2448d5e009140c0868a66a8d664c3868444a78bf`, build 2161 consegnata, release `0qvhpvp86fve0`.

**Il fatto.** Mauro ha installato la 2161 sul suo Realme 14 Pro e l'app **si chiude subito**, senza mostrare nulla, con la finestra di sistema "l'app continua a interrompersi". La 2158 sullo stesso telefono funzionava.

**Cosa NON si fa.** Non si tira a indovinare la causa, non si corregge un sospetto, non si costruisce niente prima di avere lo stack. Il telefono e' collegato al PC col debug USB attivo: la risposta si prende, non si deduce.

**Il pacchetto** e' `com.esotericircle.esoteric_circle`, letto dalla console Crashlytics.

**Un fatto che restringe il campo.** Crashlytics dichiara "App rilevata, siamo in attesa di un arresto anomalo": ha visto l'app ma NON ha ricevuto nessun crash. Quindi la strada Crashlytics e' chiusa e non la si insegue.

## Premesse da abbattere

- **A.** La testa del canonico e' ancora `2448d5e0`. Se il ramo si e' mosso, dichiara la testa nuova.
- **B.** `adb devices` mostra UN dispositivo in stato `device`, non `unauthorized` e non `offline`. Se e' `unauthorized`, fermati e dillo: la finestra di autorizzazione va accettata sul telefono e non la puoi toccare tu.
- **C.** L'APK installato sul telefono e' davvero la 2161. Leggilo dal dispositivo con `adb shell dumpsys package com.esotericircle.esoteric_circle | findstr versionCode`, non dal pubspec.

## VOCE 1. Prendere lo stack vero

Sequenza, e si esegue in quest'ordine.

1. `adb devices` e dichiara cosa risponde.
2. `adb logcat -c` per svuotare il buffer.
3. `adb shell am force-stop com.esotericircle.esoteric_circle`
4. Avvia la cattura in un processo che resta aperto: `adb logcat -v threadtime > crash_2161.txt`
5. Fai partire l'app dal PC: `adb shell monkey -p com.esotericircle.esoteric_circle -c android.intent.category.LAUNCHER 1`
6. Aspetta che il crash avvenga, poi ferma la cattura.
7. Raccogli anche i due buffer dedicati, perche' contengono cose che il principale non ha: `adb logcat -b crash -d > crash_buffer.txt` e `adb shell dumpsys dropbox --print > dropbox.txt`

Poi LEGGI, e cerca in quest'ordine:

- `FATAL EXCEPTION` e `AndroidRuntime`, che e' un crash Java o Kotlin: prendi la classe, il messaggio e le prime venti righe di stack.
- `*** *** ***` con `signal 11` oppure `signal 6`, che e' un crash nativo: prendi la libreria e l'indirizzo.
- `E/flutter` con `Unhandled Exception`, che e' un crash Dart.
- Le righe `FirebaseApp`, `FirebaseInitProvider`, `Crashlytics`, `GoogleServices`, `ContentProvider` durante l'avvio.

**Nel rapporto incolla le righe vere del log, non il tuo riassunto.** Un crash raccontato a parole non e' un crash: le righe si copiano.

Nota per non perdere tempo: la 2161 e' una build di rilascio, quindi lo stack Java puo' essere offuscato da R8. Se lo e', dillo e usa `flutter symbolize` per la parte Dart e la mapping di R8 in `build/app/outputs/mapping/release/mapping.txt` per la parte Java, invece di arrenderti a un nome illeggibile.

## VOCE 2. Confermare la causa prima di correggere

Quando lo stack nomina un colpevole, **quella e' un'ipotesi finche' non la dimostri**. La dimostrazione e' differenziale: disattiva o rimetti la sola cosa sospetta, ricostruisci, installa sul telefono collegato, e verifica che il crash sparisca oppure resti.

`adb install -r <apk>` per reinstallare senza disinstallare.

Se lo stack non basta a restringere, il campo va ristretto per bisezione, e non a caso: fra la 2158 che funziona e la 2161 che no ci sono, nell'ordine, `738a402` (Crashlytics), `aaee9d3` (ricerca dSYM), `b6bc55b` (build diagnostica) e poi le undici voci dell'ordine 2161. **I primi tre sono lavoro iOS mai installato su un telefono Android**, quindi la bisezione parte da li' e non dalle undici voci.

Secondo sospetto, da tenere presente e non da presumere: `kDiagnosiAttiva` e' passato da un'espressione a runtime a una costante falsa. Se qualcosa veniva inizializzato solo dentro quel ramo, oggi non lo inizializza piu' nessuno.

Dichiara nel rapporto l'ipotesi, la prova differenziale e l'esito, anche quando l'ipotesi cade.

## VOCE 3. Correggere la causa trovata

Correggi la causa, non il sintomo. Se il difetto e' un'inizializzazione che manca, si aggiunge dove deve stare, non si avvolge in un `try` che nasconde l'errore: un ripiego che tace e' peggio di un ripiego che sbaglia.

**Ci si ferma e si chiede a Mauro in un caso solo:** se togliere la causa significa disfare qualcosa che lui ha ordinato, per esempio spegnere Crashlytics che serve al fronte iOS. In quel caso scrivi le due strade con il loro costo e aspetta.

## VOCE 4. La prova di accensione, dentro la procedura di consegna

E' la voce che vale piu' della correzione, perche' impedisce che accada di nuovo.

Duemilaquarantasei prove sono verdi e nessuna avvia l'archivio: girano tutte in `flutter test`, dove Firebase e i plugin nativi non partono affatto. Per questo un crash all'avvio e' arrivato in mano a Mauro con la suite verde.

Costruisci dentro `tool/consegna.py`, PRIMA del caricamento, una prova di accensione che:

1. installa l'APK appena costruito su un dispositivo collegato oppure su un emulatore avviato per l'occasione;
2. svuota il log, avvia l'app, aspetta un tempo dichiarato;
3. verifica che il processo sia VIVO e che l'app abbia disegnato il primo fotogramma, per esempio con `adb shell dumpsys gfxinfo` oppure leggendo `Displayed` in logcat;
4. verifica che nel log non ci sia nessun `FATAL EXCEPTION`;
5. **fa fallire la consegna** se una di queste cade, stampando le righe del log.

Se non c'e' nessun dispositivo ne' emulatore disponibile, la consegna si ferma e lo dichiara: non si consegna al buio.

Rosso da eseguire: rimetti la causa del crash trovata nella Voce 2, lancia la procedura, e la consegna deve fermarsi da sola prima di caricare.

## VOCE 5. Le venti domande, perche' due versioni non coincidono

Mauro dichiara che **fino alla 2157 o 2158 le domande suggerite erano venti per ogni Maestro**. Il rapporto dell'ordine 2161 attribuisce la riduzione a tre al commit `93e1481` del 12 luglio. Le due cose non possono essere vere insieme.

Verifica leggendo il codice all'albero della 2158, non a memoria: quante domande mostrava quella build nella prima schermata del dominio, e da quale widget. Poi dichiara quale delle due ricostruzioni regge, e se quella del 12 luglio era sbagliata dillo apertamente e trova il commit vero.

Non e' una correzione: nella 2161 le due famiglie sono gia' state ripristinate. E' sapere se la ricostruzione di cui ci siamo fidati era falsa.

## Fuori da questo ordine, dichiarato

Il fronte iOS va portato su un ramo suo, e nessuna consegna Android deve partire da un albero che contiene lavoro di piattaforma non provato. **Non si fa adesso**: riorganizzare i rami mentre si insegue un crash e' il modo di averne due. Entra nel primo ordine dopo che la 2162 funziona.

## La consegna

Solo dopo che la prova di accensione della Voce 4 e' verde.

`flutter build apk --release --target-platform android-arm64`, un solo APK arm64, numero di build **2162**, consegna con App Distribution al destinatario unico `cloud@esotericircle.app`.

Dichiara: il numero letto dall'archivio con aapt2, la release, il comando esatto, il peso nelle due unita' base 1000 e base 1024. Aggiorna `docs/versione_distribuita.json` dentro la procedura.

`kDiagnosiAttiva` resta spento, e la sua guardia resta viva.

## Il rapporto finale

1. L'esito delle tre premesse.
2. **Le righe vere del log**, copiate, non riassunte.
3. La causa, con la prova differenziale che la dimostra e l'esito delle ipotesi cadute.
4. La correzione, e dove vive la regola che la protegge.
5. La prova di accensione, col suo rosso eseguito.
6. La risposta sulla Voce 5, cioe' quale ricostruzione regge.
7. La frase di accettazione: cosa deve vedere Mauro aprendo la 2162.

Uno sha si cita solo dopo averlo letto dal remoto a push avvenuto. Un esito riportato da un canale che non ha eseguito il comando non e' l'esito del comando.
