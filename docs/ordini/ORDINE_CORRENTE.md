# ORDINE CORRENTE per Claude Code

Emesso dall'Architetto in Cowork il 27 luglio 2026, sera.
Ramo `claude/esoteric-circle-master-order-e798aj`, testa `b9c1185`.

## Obiettivo unico

Produrre un APK di debug installabile sul telefono di Mauro, che al primo avvio mostri a schermo il token di debug di App Check, così che lui possa registrarlo in console da casa senza toccare il PC dell'ufficio.

Questo ordine finisce qui. Le sette voci sugli entitlement stanno in `docs/ordini/ORDINE_ENTITLEMENT.md` e si eseguono dopo, non adesso.

## Contesto verificato stasera, non ricontrollarlo

- La callable `natalChart` è viva in europe-west1, revisione `natalchart-00002-soq`, stato ACTIVE.
- Il segreto `FREEASTRO_API_KEY` è alla versione 2 e contiene la chiave vera.
- Il servizio Cloud Run accetta ora le chiamate non autenticate: `allUsers` ha `roles/run.invoker`. Prima le respingeva tutte, ed era quello il blocco storico di FreeAstroAPI.
- `android/app/google-services.json` esiste da stasera. Prima mancava, quindi la build Android falliva e Firebase non si inizializzava affatto.
- L'app non è MAI stata eseguita su un dispositivo. Nessuna funzione ha mai raggiunto lo stato "verificato a video".

## Cosa fare

**1. Proteggi la configurazione.** Il repository è PUBBLICO. Aggiungi `android/app/google-services.json` a `.gitignore` se non c'è già, e assicurati che non entri in nessun commit. Se risulta già tracciato, toglilo dall'indice senza cancellarlo dal disco.

**2. Usa un token di App Check fissato, già registrato in console.**

Questo token è stato registrato stasera nella console Firebase per l'app Android:

```
2f4013f2-e6e7-49b2-a3aa-402f28cd365a
```

`AppCheckDebugToken.getOrCreate()` deve preferirlo a qualunque token generato: se `String.fromEnvironment('APP_CHECK_DEBUG_TOKEN')` non è vuoto, usa quello e salvalo nelle preferenze, altrimenti mantieni il comportamento attuale che ne genera uno nuovo.

Il motivo è pratico e vincolante: Mauro installerà l'APK sul telefono da casa, e dal telefono non può registrare un token in console. Il token deve quindi essere già valido al primo avvio.

**2b. Rendi comunque visibile il token.** Serve da rete di sicurezza, per capire subito quale token l'app stia usando davvero.

Mostralo in due punti, entrambi solo quando `kDebugMode` è vero, mai in release:

- sulla prima schermata che compare all'avvio, come striscia sottile in alto, richiudibile;
- nelle Impostazioni, come riga in fondo.

In entrambi i casi il tocco copia il token negli appunti e conferma con un messaggio breve. La riga non deve mai essere vuota in debug: se `AppServices.appCheckDebugToken` è null perché l'attivazione di App Check è fallita, leggi comunque il token da `AppCheckDebugToken.getOrCreate()`, che non dipende da Firebase.

Il motivo dei due punti è pratico: per arrivare alle Impostazioni bisogna attraversare l'onboarding, e l'onboarding senza App Check funzionante ripiega sul cielo essenziale. Mauro deve poter leggere il token prima di tutto.

**3. Costruisci l'APK.**

```
flutter build apk --debug --split-per-abi --dart-define=APP_CHECK_DEBUG_TOKEN=2f4013f2-e6e7-49b2-a3aa-402f28cd365a
```

Riporta il percorso completo e la dimensione di `app-arm64-v8a-debug.apk`.

**4. Non toccare `docs/STATO_VIVO.md`.** Lo aggiorniamo insieme dopo la prova sul telefono, quando sapremo cosa funziona davvero.

## Criteri di accettazione, in numeri

- L'APK arm64 esiste, pesa più di 20 MB e meno di 250 MB.
- Due test: uno verifica che in debug la striscia col token compaia e che il testo mostrato sia un UUID di 36 caratteri; l'altro verifica che in release non compaia.
- Un terzo test verifica che, con `APP_CHECK_DEBUG_TOKEN` valorizzato, il token usato sia esattamente quello e non uno generato a caso.
- Suite intera verde, `flutter analyze` pulito, zero nuovi avvisi.
- `git status` non elenca `google-services.json` fra i file da committare.

## Autorizzazione

Itera da solo finché i numeri passano. Debug incluso. Non chiedere conferme su scelte interne.

## Come riportare

In `docs/ordini/ESITO_CORRENTE.md`:

- percorso e dimensione dell'APK arm64
- esito dei due test
- conteggio finale dei test e esito di `flutter analyze`
- qualunque cosa sia andata storta nella build Android, per esteso

Niente trattino lungo. Niente proposizione dopo la virgola che inizia con la lettera e.
