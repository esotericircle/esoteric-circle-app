# ORDINE A, il rifacimento immersivo

Emesso dall'Architetto in Cowork la notte del 28 luglio 2026. Primo ordine della coda in `docs/ordini/CODA.md`.

## Che cosa è

Sono le parti dell'ordine precedente che hai lasciato aperte, più tre cose emerse dopo. La tua scelta di consegnare due parti intere invece di sei abbozzate era giusta e la confermo: questo ordine chiude il resto, con lo stesso criterio.

Quello che hai già fatto e non va rifatto: i tre angeli e la loro schermata, il controllo di integrità dell'APK, "Entra nel Cerchio", il vocativo con la maiuscola.

---

## A1. Il numero di versione, per primo

L'APK di stanotte ha numero di versione 1, quello di ieri 2001, perché `--split-per-abi` aggiungeva duemila per l'ABI arm64 e togliendolo il numero è tornato a uno. Android rifiuta l'installazione di un numero più basso sopra uno più alto, quindi quella release non si sovrappone.

Correggi in modo che il numero di versione **cresca sempre**, indipendentemente dal modo in cui si costruisce. Non ci deve più essere un caso in cui una build nuova non si installa sopra la precedente. Un test verifica che il numero sia maggiore dell'ultimo distribuito.

## A2. Un solo sistema di scena

Coesistono otto modi diversi di disegnare il cielo di fondo. Tre leggono il sensore, cinque no. Nel Santuario due si sovrappongono leggendo lo stesso controller con coefficienti diversi. Esistono due iscrizioni indipendenti all'accelerometro, la globale in `app.dart:57` e una privata in `birth_sky_hero.dart:49`.

1. `CosmosBackground` + `_CosmosPainter`, `design_system/components/cosmos_background.dart:28` e `:204`. Sensore sì.
2. `_SkyAccentsPainter`, `features/santuario/santuario_screen.dart:1216`. Sensore sì, sovrapposto al primo.
3. `_CircleEllipsePainter`, `santuario_screen.dart:695`. Statico.
4. `RitualBackdrop` + `_BackdropPainter`, `design_system/components/ritual_backdrop.dart:29` e `:145`. Nessun sensore.
5. `_SkyFieldPainter`, `features/santuario/sky_overview_screen.dart:636`. Sensore più dito.
6. `BirthSkyHero` + `_SkyPainter`, `features/onboarding/birth_sky_hero.dart:27` e `:250`. Sensore, controller privato.
7. `_PortalSkyPainter`, `features/identity/widgets/identity_widgets.dart:212`. Nessun sensore, solo un timer di 8 secondi. È questo che rende statica la carta natale e il portale del Passport.
8. `SkyPostcard`, `features/santuario/sky_postcard.dart:31`. Resta separato, non è una scena viva.

Unificali in un sistema solo, con una sola iscrizione al sensore, che le schermate **configurano** invece di reimplementare.

**L'ampiezza è sbagliata, ed è il numero che conta.** `parallax_controller.dart:42` ha `tiltRange = 18` px. Sul campo stellare principale del cielo la profondità è 0,12, quindi lo spostamento massimo da sensore è **2,16 pixel**, mentre il dito si muove uno a uno fino a 160 px in orizzontale e 280 in verticale. L'utente inclina il telefono e non vede nulla. Nel codice non esiste alcun giroscopio, la sorgente è l'accelerometro: va bene, sbagliata è l'ampiezza.

**Il fondale non si ripete.** Lo stesso cielo con la stessa costellazione rettangolare in alto a destra compare in carta natale, "Chi risuona in te" e benvenuto di Medora. Viola la regola 21 delle Linee Guida. Il sistema unificato accetta un seme per schermata: stesso motore, cielo diverso.

**La comparsa in scorrimento non è legata allo scorrimento.** `ScrollReveal`, `design_system/components/scroll_reveal.dart:23`, parte in `didChangeDependencies` alla riga 100, cioè al montaggio. Lo usa una sola schermata. Legalo alla posizione reale nello schermo e applicalo ovunque ci sia scorrimento, carta natale e ruota comprese.

## A3. Il permesso di posizione

`sky_location.dart:67` contiene l'unica `requestPermission` dell'app, dentro `resolve()`. Ma:

- in `sky_overview_screen.dart` non esiste alcun comando toccabile per la posizione: l'unica richiesta parte da sola all'apertura, righe 98-108, con la guardia `_askedLocation` alle righe 104-105 che la blocca dopo il primo rifiuto per tutta la visita;
- `sky_location.dart:64`: col servizio di localizzazione spento la funzione esce prima di `requestPermission`, quindi nessun dialogo di sistema compare mai;
- `sky_location.dart:68-71`: con permesso negato in modo permanente, ripiego silenzioso;
- non esiste alcuna chiamata che apra le impostazioni: dal rifiuto permanente non si esce;
- convivono due meccanismi di pre-avviso, quello condiviso in `core/permissions/app_permission.dart:82` che nessuno usa, e uno scritto a mano in `sky_overview_screen.dart:125-196`.

Un comando toccabile ed esplicito nella schermata del cielo. Un solo meccanismo di pre-avviso, quello condiviso. Servizio spento: dirlo e offrire di aprirlo. Permesso negato in modo permanente: offrire di aprire le impostazioni dell'app. Mai un vicolo cieco.

## A4. I Maestri della home ruotano

`_Carousel` in `santuario_screen.dart:545`. Al tocco di un laterale, `_selectSide` alle righe 149-151 cambia solo il Maestro nel controller: nessuna transizione, le posizioni si ricostruiscono al fotogramma dopo. Nessun `onHorizontalDrag` esiste nel file.

Rotazione animata sull'anello: al tocco i tre bustini ruotano lungo un arco fino alla nuova posizione, chi va dietro si smorza mentre chi arriva davanti si accende. Aggiungi il trascinamento orizzontale che ruota la corona con la stessa animazione. Ripiego in dissolvenza con Riduci Movimento.

## A5. Le due animazioni di trionfo mancanti

**Il Sigillo.** Oggi sta nel terzo alto mentre la frase dice "Posa il dito al centro", e Mauro ha premuto al centro dello schermo perché la frase è giusta e la posizione è sbagliata. Portalo al centro ottico. Sopra, un titolo e una riga che spieghi che quel numero è il Numero della Vita ricavato dalla data di nascita. Animazione: il cerchio col numero entra da fuori schermo molto grande e ruotando, si riduce, arriva al centro e si ferma dritto. Ingresso dal basso, scala da 3,0 a 1,0, rotazione da due giri interi a zero, durata circa 1400 ms, curva in uscita morbida senza rimbalzo.

**L'Animale Guida.** Il Master Tecnico, sezione 50, prescrive "un animazione di nebbia che si dirada". Realizzala: la nebbia si apre e l'animale emerge.

Entrambe con ripiego in dissolvenza quando Riduci Movimento è attivo.

## A6. I tre punti di disposizione rimasti

- In "Chi risuona in te" il nome Medora va a capo lasciando la "a" sulla riga sotto. Una riga sola, rimpicciolendo se serve.
- Nel benvenuto di Medora l'avatar copre i titoli. Nella home del Cerchio i bustini coprono le scritte sotto. Il testo non deve mai finire sotto una figura.
- La silhouette animata che invita a toccare ha una forma infelice, che Mauro ha descritto senza mezzi termini. Ridisegnala: mano stilizzata oppure il fantasma del gesto del punto 8 del GATE UX, mai una forma allungata verticale.

## A7. Ripristino del Risveglio in debug

Una voce nelle Impostazioni, visibile solo nelle build di debug come la striscia del token, che azzera profilo e identità e fa ripartire l'onboarding con un tocco. Serve a Mauro per non svuotare i dati dell'app a ogni prova.

---

## Criteri di accettazione, in numeri

- Il numero di versione della build nuova è maggiore di 2001. Un test lo verifica.
- In tutto `lib/` resta **una sola** classe che disegna il cielo di fondo vivo, esclusa `SkyPostcard`. Un test le conta.
- Esiste **una sola** iscrizione all'accelerometro. Un test lo verifica.
- Lo spostamento massimo da sensore sul piano principale del cielo passa da 2,16 px ad almeno **24 px logici**, e il rapporto fra ampiezza del dito e ampiezza del sensore non supera **3 a 1** su entrambi gli assi. Un test calcola i due valori e li confronta.
- Carta natale, portale del Passport, "Chi risuona in te" e benvenuto di Medora reagiscono al sensore. Un test lo verifica.
- Quattro schermate diverse hanno quattro semi di fondale diversi.
- Una scheda fuori vista non è ancora comparsa. Un test lo verifica.
- Nella schermata del cielo esiste un comando toccabile con la sua chiave, e al tocco viene invocata la richiesta di permesso. Con servizio spento oppure permesso negato in modo permanente compare una via d'uscita verso le impostazioni. Un test copre i tre casi.
- Il tocco su un laterale produce una transizione animata di durata maggiore di zero, e il trascinamento orizzontale cambia il Maestro centrale.
- Il centro del sigillo cade fra il 45 e il 55 per cento dell'altezza utile.
- Le due animazioni di trionfo esistono, hanno durata maggiore di zero e sono disattivate con Riduci Movimento. Un test verifica entrambi gli stati.
- Nessuna sovrapposizione fra figura e testo nelle due schermate segnalate, misurata sulle anteprime rigenerate.
- Suite intera verde, `flutter analyze` pulito, zero nuovi avvisi, integrità dell'APK verde.

## Alla fine

```
flutter build apk --debug --target-platform android-arm64 --dart-define=APP_CHECK_DEBUG_TOKEN=2f4013f2-e6e7-49b2-a3aa-402f28cd365a
```

```
firebase appdistribution:distribute "build/app/outputs/flutter-apk/app-debug.apk" --app 1:425821975933:android:1b1ca4db8d4df69b940814 --testers "cloud@esotericircle.app" --release-notes "Rifacimento immersivo"
```

Scrivi l'esito in `docs/ordini/ESITO_A.md`, con ogni criterio numerico e il suo valore misurato, non un aggettivo. Poi apri il prossimo ordine della coda.

Niente trattino lungo. Niente proposizione dopo la virgola che inizia con la lettera e.
