# ORDINE CORRENTE per Claude Code

Emesso dall'Architetto in Cowork il 27 luglio 2026, notte. Sostituisce l'ordine precedente, che è chiuso.

## Contesto

L'APK arm64 è pronto a `build/app/outputs/flutter-apk/app-arm64-v8a-debug.apk`, 218,2 MiB. Mauro è a casa e deve installarlo sul telefono. Il ponte fra il suo PC e l'Architetto è andato in timeout su un file di quella dimensione, quindi la consegna non passa di lì.

## Obiettivo unico

Consegnare l'APK al telefono di Mauro con Firebase App Distribution, che sul PC è già autenticato come `cloud@esotericircle.app`.

## Cosa fare

**1. Distribuisci.**

```
firebase appdistribution:distribute "build\app\outputs\flutter-apk\app-arm64-v8a-debug.apk" --app 1:425821975933:android:1b1ca4db8d4df69b940814 --testers "cloud@esotericircle.app,info@esotericircle.com" --release-notes "Prima accensione. Token App Check fissato nel binario."
```

L'App ID è stato letto da `android/app/google-services.json`, campo `mobilesdk_app_id`, non dedotto.

**2. Se il comando chiede di abilitare App Distribution** sul progetto, segui il link che stampa, abilita, ripeti il comando. Riporta comunque cosa hai dovuto abilitare.

**3. Riporta l'esito** in `docs/ordini/ESITO_CORRENTE.md`: comando eseguito, esito, eventuale link di download che il CLI stampa, e per esteso qualunque errore.

**4. Non toccare altro.** Non `docs/STATO_VIVO.md`, non `ORDINE_ENTITLEMENT.md`, nessun file di codice.

## Nota sul peso, da non risolvere adesso

218 MiB per un APK di debug è fuori scala per una distribuzione, anche interna. La causa quasi certa sono gli asset delle sei famiglie esoteriche bundlati in-app a due misure. Non intervenire ora: serve per la prima accensione e va bene così. Va però messo a registro come fronte aperto, perché una Demo che pesa così non si mostra a nessuno.

Niente trattino lungo. Niente proposizione dopo la virgola che inizia con la lettera e.
