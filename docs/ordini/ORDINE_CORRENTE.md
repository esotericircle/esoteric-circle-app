# ORDINE A2, un solo sistema di scena

Emesso dall'Architetto in Cowork il 29 luglio 2026. **Questo ordine ha un oggetto solo.** Non ci sono voci facili accanto, apposta.

## Perché è da solo

Gli ultimi due ordini contenevano molte voci ciascuno, e in entrambi i casi si sono chiuse quelle leggere mentre il rifacimento pesante è rimasto intatto. Un elenco si svuota sempre dal lato leggero. Quindi qui non c'è nessun lato leggero.

Non toccare nient'altro. Non le animazioni di trionfo, non il permesso di posizione, non il carosello, non i testi, non il Sigillo. Se avanza tempo, **non passare ad altro**: usa il tempo per rendere questo più solido.

## Dichiarazione all'inizio, obbligatoria

Prima di scrivere una riga di codice, stima se riesci a chiudere questo ordine per intero e **scrivilo subito** in `docs/ordini/ESITO_A2.md`, in una riga. Se la risposta è no, dillo prima e di' fin dove arrivi. Scoprirlo all'inizio vale un'ora; scoprirlo alla fine ce l'ha già fatta perdere due volte.

## L'oggetto

Nel codice coesistono otto modi diversi di disegnare il cielo di fondo. Tre leggono il sensore, cinque no. Nel Santuario due si sovrappongono leggendo lo stesso controller con coefficienti diversi. Esistono due iscrizioni indipendenti all'accelerometro, la globale in `app.dart:57` e una privata in `birth_sky_hero.dart:49`.

1. `CosmosBackground` + `_CosmosPainter`, `design_system/components/cosmos_background.dart:28` e `:204`. Sensore sì.
2. `_SkyAccentsPainter`, `features/santuario/santuario_screen.dart:1216`. Sensore sì, sovrapposto al primo.
3. `_CircleEllipsePainter`, `santuario_screen.dart:695`. Statico.
4. `RitualBackdrop` + `_BackdropPainter`, `design_system/components/ritual_backdrop.dart:29` e `:145`. Nessun sensore, solo deriva sinusoidale.
5. `_SkyFieldPainter`, `features/santuario/sky_overview_screen.dart:636`. Sensore più dito.
6. `BirthSkyHero` + `_SkyPainter`, `features/onboarding/birth_sky_hero.dart:27` e `:250`. Sensore, con controller privato.
7. `_PortalSkyPainter`, `features/identity/widgets/identity_widgets.dart:212`. Nessun sensore, solo un timer di 8 secondi. È questo che rende statica la carta natale e il portale del Passport.
8. `SkyPostcard`, `features/santuario/sky_postcard.dart:31`. **Resta separato**, non è una scena viva: serve alla condivisione e va lasciato com'è.

**Unifica i sette in uno.** Un solo sistema di scena, con una sola iscrizione al sensore, che le schermate configurano invece di reimplementare.

## Le tre cose che devono cambiare per l'utente

**Primo, il movimento si deve sentire.** `parallax_controller.dart:42` ha `tiltRange = 18` px. Sul campo stellare principale del cielo la profondità è 0,12, quindi lo spostamento massimo da sensore è **2,16 pixel**. Il dito si muove uno a uno fino a 160 px in orizzontale e 280 in verticale, cioè fra le nove e le quindici volte tanto. Mauro ha descritto l'effetto come "si sposta di due millimetri", ed è una misura giusta. Nel codice non esiste alcun giroscopio, la sorgente è l'accelerometro: la sorgente va bene, l'ampiezza no.

**Secondo, ogni schermata reagisce.** Oggi la carta natale, il portale del Passport, "Chi risuona in te" e il benvenuto di Medora hanno un fondale che non legge alcun sensore. Dopo l'unificazione devono reagire tutte.

**Terzo, il cielo non si ripete.** Lo stesso fondale con la stessa costellazione rettangolare in alto a destra compare identico in tre schermate. Viola la regola 21 delle Linee Guida UX, per cui il visivo è a tema e non si ripete. Il sistema unificato accetta un seme per schermata: stesso motore, cielo diverso.

## Criteri di accettazione, in numeri

- In tutto `lib/` resta **una sola** classe che disegna il cielo di fondo vivo, esclusa `SkyPostcard`. Un test le conta e fallisce a due.
- Esiste **una sola** iscrizione all'accelerometro in tutta l'app. Un test lo verifica.
- Lo spostamento massimo da sensore sul piano principale del cielo è almeno **24 px logici**, contro i 2,16 di oggi.
- Il rapporto fra ampiezza del dito e ampiezza del sensore non supera **3 a 1** su entrambi gli assi. Un test calcola i due valori e li confronta, e riporta i numeri nell'esito.
- Carta natale, portale del Passport, "Chi risuona in te" e benvenuto di Medora reagiscono al sensore. Un test lo verifica su tutte e quattro.
- Quattro schermate diverse hanno quattro semi di fondale diversi. Un test lo verifica.
- Nessuna schermata perde il proprio aspetto: le anteprime vanno rigenerate e confrontate una per una, e ogni differenza voluta va dichiarata nell'esito.
- Riduci Movimento continua a fermare tutto.
- Suite intera verde, `flutter analyze` pulito, zero nuovi avvisi, integrità dell'APK verde, numero di versione non inferiore a 2100.

## Autorizzazione

Itera da solo finché i numeri passano, debug incluso. Non chiedere conferme su scelte interne. Questo è un rifacimento: sei autorizzato a cancellare codice, a spostare file e a cambiare le firme dei widget, purché la suite resti verde e le anteprime non peggiorino.

## Alla fine

```
flutter build apk --debug --target-platform android-arm64 --dart-define=APP_CHECK_DEBUG_TOKEN=2f4013f2-e6e7-49b2-a3aa-402f28cd365a
```

```
firebase appdistribution:distribute "build/app/outputs/flutter-apk/app-debug.apk" --app 1:425821975933:android:1b1ca4db8d4df69b940814 --testers "cloud@esotericircle.app" --release-notes "Un solo sistema di scena"
```

Esito in `docs/ordini/ESITO_A2.md`, con i numeri misurati e non gli aggettivi: ampiezza prima e dopo, rapporto dito su sensore, classi di fondale rimaste, iscrizioni al sensore rimaste.

**Poi fermati.** Non aprire altri ordini della coda: questo lo decide l'Architetto dopo aver visto l'esito.

Niente trattino lungo. Niente proposizione dopo la virgola che inizia con la lettera e.
