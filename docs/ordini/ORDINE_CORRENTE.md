# ORDINE CORRENTE per Claude Code

Emesso dall'Architetto in Cowork il 28 luglio 2026. Sostituisce integralmente l'ordine precedente.

## Titolo

L'identità completa e un solo sistema di scena.

## Avvertenza che vale su tutto l'ordine

**NON cancellare gli asset in `assets/img/angeli`.** L'ordine precedente ti chiedeva di valutarne la rimozione dal bundle: quella istruzione è ANNULLATA. Quelle settantadue immagini servono, e questo ordine le mette in scena.

Questo ordine è grande perché nasce dalla prova dell'app sul telefono più dalla rilettura dei quattro briefing V3, che ha fatto emergere una omissione grossa. Il criterio di riuscita non è avere toccato ogni punto: è che alla prossima installazione Mauro non riveda gli stessi difetti.

---

# PARTE 1, L'IDENTITA' COMPLETA

## 1.1 Perché

Il Briefing Operativo MVP colloca l'Angelo Custode fra le funzioni di Medora dichiarate **Attive** nella Demo, dentro il sotto insieme prioritario da rifinire al cento per cento. Il Briefing di Progetto lo mette fra i momenti wow del Risveglio e fra le identità del Cosmic Passport. Il Master Tecnico, sezione 47, precisa che sono "i 72 calcolati come grado astrologico dalla posizione del Sole", di dominio Medora, e che riusa interamente il motore astrologico.

Oggi non esiste in nessuna forma. È la dimenticanza più grave emersa dalla rilettura.

In parallelo l'Animale Guida esiste ma vive come tessera isolata nel Passport, mentre l'identità dovrebbe essere una cosa sola.

## 1.2 I tre angeli, regole di attribuzione

La tradizione cabalistica dello Shemhamphorash assegna a ogni persona **tre** angeli, con tre sorgenti diverse. Implementale tutte e tre.

**Angelo Custode, detto del corpo fisico.** Dalla longitudine eclittica del Sole alla nascita. I settantadue governano cinque gradi ciascuno, partendo da zero gradi dell'Ariete: angelo 1 da 0 a 5 gradi, angelo 2 da 5 a 10, e così via fino a 360. Riusa la longitudine solare che il motore già calcola, non ricavarla dalla data di calendario.

**Angelo del Cuore, detto del corpo astrale.** Dal giorno di nascita. I settantadue si susseguono un giorno ciascuno e il ciclo si ripete lungo l'anno.

**Angelo dell'Intelletto, detto delle missioni.** Dall'ora di nascita. Ventiquattro ore divise per settantadue danno venti minuti per angelo: l'angelo 1 governa da 00:00 a 00:20, il 2 da 00:20 a 00:40, e così via. **Senza ora di nascita questo angelo non esiste**, e la schermata lo dichiara invitando a inserire l'ora quando la si troverà, esattamente come già previsto per Ascendente e case.

Metti le tre regole in un solo punto del codice, documentate con la fonte, e coprile con test che verifichino i confini: primo grado, ultimo grado, mezzanotte esatta, 00:20 esatto, cambio di giorno.

## 1.3 Contenuto degli angeli

Il corpus dei settantadue nomi ESISTE e va usato: sta nel Project come `claude/Corpus_Angeli_Custodi_Caligo_Esoteric_Circle`. Contiene i settantadue nomi esatti verificati da fonte, ordinati, raccolti nei nove cori da otto angeli ciascuno, ognuno col suo arcangelo e il dominio del coro.

Se il file `docs/corpus/angeli.md` non esiste ancora nel repository, l'Architetto lo depositerà: leggi da lì. Se non c'è al momento in cui lavori, costruisci comunque il motore e le schermate leggendo da un catalogo che si aspetta quei campi, e riporta nell'esito che il contenuto è in attesa.

Il dettaglio per singolo angelo, cioè virtù e salmo, **non esiste ancora da fonte verificata e non va inventato**. Mostra ciò che è verificato: nome dell'angelo, numero, coro, arcangelo che governa il coro, dominio del coro, e la spiegazione di come quell'angelo è stato scelto per questa persona. Dove il dettaglio manca, non lasciare un vuoto muto: dichiara che quello strato arriva.

Nota di dominio, dal Backlog delle arti: gli angeli sono **tutti di Medora**, non di Caligo. Il nome del file di corpus dice Caligo per ragioni storiche, ignoralo. Nel catalogo delle arti non deve restare nessuna voce con la parola Angeli sotto Caligo.

## 1.4 Dove vivono

**Nella Carta Natale.** L'identità di nascita deve essere una cosa sola. Alla carta natale, insieme a Sole, Luna, Ascendente e Numero della Vita, aggiungi l'Animale Guida e i tre Angeli. L'Animale Guida oggi vive solo come tessera del Passport: portalo anche qui, senza toglierlo di là.

**Nel Cosmic Passport.** La tessera degli Angeli è nuova ed è **toccabile**, come già lo è quella dell'Animale Guida. Al tocco apre una schermata dedicata.

**La schermata dei tre Angeli.** Mostra le tre carte degli angeli assegnati, una per angelo, ciascuna con l'immagine reale da `assets/img/angeli/ang_NN_nome_v1.webp`, il nome, il numero, il coro e il suo arcangelo, e la spiegazione di quale parte della persona quell'angelo governa. In fondo, una sezione che spiega **come vengono scelti e assegnati**, cioè le tre regole del punto 1.2 dette in linguaggio piano. Disclaimer sulla tradizione una volta sola, secondo la regola di progetto.

## 1.5 Animazioni di trionfo

Sono traguardi raggiunti e vanno celebrati, non semplicemente mostrati. Tre animazioni, tutte con ripiego in dissolvenza quando Riduci Movimento è attivo.

**Il Sigillo, nell'onboarding.** Oggi il cerchio col numero sta nel terzo alto mentre la frase dice "Posa il dito al centro", e Mauro ha premuto al centro dello schermo perché la frase è giusta e la posizione è sbagliata. Porta il sigillo al centro ottico. Aggiungi sopra un titolo e una riga che spieghi che quel numero è il Numero della Vita ricavato dalla data di nascita, perché oggi compare senza che nulla dica cosa sia. Animazione: il cerchio col numero entra da fuori schermo molto grande e ruotando, si riduce, arriva al centro e si ferma perfettamente dritto. Ingresso dal basso, scala da 3,0 a 1,0, rotazione da due giri interi a zero, durata circa 1400 ms, curva in uscita morbida senza rimbalzo.

**L'Animale Guida, alla rivelazione.** Stessa dignità: l'animale non compare, arriva. Il Master Tecnico prevede per lui "un'animazione di nebbia che si dirada": realizzala, la nebbia si apre e l'animale emerge.

**I tre Angeli, alla rivelazione.** Le tre carte non compaiono insieme e ferme: entrano una dopo l'altra con un ritardo fra loro, ciascuna con una luce che si accende dietro e si posa. Durata complessiva sotto i due secondi e mezzo, perché è un trionfo, non un'attesa.

---

# PARTE 2, UN SOLO SISTEMA DI SCENA

## 2.1 Otto fondali invece di uno

Verificato: coesistono otto modi diversi di disegnare il cielo. Tre leggono il sensore, cinque no. Nel Santuario due si sovrappongono leggendo lo stesso controller con coefficienti diversi. Esistono due iscrizioni indipendenti all'accelerometro, la globale in `app.dart:57` e una privata in `birth_sky_hero.dart:49`.

1. `CosmosBackground` + `_CosmosPainter`, `design_system/components/cosmos_background.dart:28` e `:204`. Sensore sì.
2. `_SkyAccentsPainter`, `features/santuario/santuario_screen.dart:1216`. Sensore sì, sovrapposto al primo.
3. `_CircleEllipsePainter`, `santuario_screen.dart:695`. Statico.
4. `RitualBackdrop` + `_BackdropPainter`, `design_system/components/ritual_backdrop.dart:29` e `:145`. Nessun sensore.
5. `_SkyFieldPainter`, `features/santuario/sky_overview_screen.dart:636`. Sensore più dito.
6. `BirthSkyHero` + `_SkyPainter`, `features/onboarding/birth_sky_hero.dart:27` e `:250`. Sensore, con controller privato.
7. `_PortalSkyPainter`, `features/identity/widgets/identity_widgets.dart:212`. Nessun sensore, solo un timer di 8 secondi. È questo che rende statica la carta natale.
8. `SkyPostcard`, `features/santuario/sky_postcard.dart:31`. Resta separato, non è una scena viva.

**Unificali in un solo sistema**, con una sola iscrizione al sensore, che tutte le schermate configurano invece di reimplementare.

## 2.2 L'ampiezza del movimento è sbagliata

`parallax_controller.dart:42` ha `tiltRange = 18` px. Sul campo stellare principale del cielo la profondità è 0,12, quindi lo spostamento massimo da sensore è **2,16 pixel**. Il dito si muove uno a uno fino a 160 px in orizzontale e 280 in verticale, cioè fra le nove e le quindici volte tanto. L'utente inclina il telefono e non vede nulla.

Nota: nel codice non esiste alcun giroscopio, la sorgente è l'accelerometro. Va bene per la parallasse, sbagliata è l'ampiezza.

## 2.3 Il fondale ripetuto

Lo stesso cielo con la stessa costellazione rettangolare in alto a destra compare nella carta natale, in "Chi risuona in te" e nel benvenuto di Medora. Viola la regola 21 delle Linee Guida UX, per cui il visivo è a tema e non si ripete. Il sistema unificato accetta un seme per schermata: stesso motore, cielo diverso.

## 2.4 La comparsa in scorrimento non è legata allo scorrimento

`ScrollReveal`, `design_system/components/scroll_reveal.dart:23`, parte in `didChangeDependencies` alla riga 100, cioè al montaggio, non all'ingresso nello schermo. Lo usa una sola schermata. Legalo alla posizione reale e applicalo ovunque ci sia scorrimento, carta natale e ruota comprese.

---

# PARTE 3, IL PERMESSO DI POSIZIONE

Verificato: `sky_location.dart:67` contiene l'unica `requestPermission` dell'app, dentro `resolve()`. Ma:

- in `sky_overview_screen.dart` NON esiste alcun comando toccabile per la posizione: l'unica richiesta parte da sola all'apertura, righe 98-108, con la guardia `_askedLocation` alle righe 104-105 che la blocca dopo il primo rifiuto per tutta la visita;
- `sky_location.dart:64`: col servizio di localizzazione del telefono spento la funzione esce prima di `requestPermission`, quindi nessun dialogo di sistema compare mai;
- `sky_location.dart:68-71`: con permesso negato in modo permanente, ripiego silenzioso;
- in tutto il codice non esiste alcuna chiamata che apra le impostazioni: dal rifiuto permanente non si esce;
- convivono due meccanismi di pre-avviso, quello condiviso in `core/permissions/app_permission.dart:82` che nessuno usa, e uno scritto a mano in `sky_overview_screen.dart:125-196`.

**Cosa fare.** Un comando toccabile ed esplicito nella schermata del cielo. Un solo meccanismo di pre-avviso, quello condiviso. Se il servizio di localizzazione è spento, dirlo e offrire di aprirlo. Se il permesso è negato in modo permanente, offrire di aprire le impostazioni dell'app. Mai un vicolo cieco.

---

# PARTE 4, I MAESTRI DELLA HOME

`_Carousel` in `santuario_screen.dart:545`. Al tocco di un laterale, `_selectSide` alle righe 149-151 cambia solo il Maestro nel controller: nessuna transizione, le tre posizioni si ricostruiscono al fotogramma dopo. Nessun `onHorizontalDrag` esiste nel file.

Rotazione animata sull'anello: al tocco i tre bustini ruotano lungo un arco fino alla nuova posizione, chi va dietro si smorza mentre chi arriva davanti si accende. Aggiungi il trascinamento orizzontale che ruota la corona con la stessa animazione. Ripiego in dissolvenza con Riduci Movimento.

---

# PARTE 5, TESTI E DISPOSIZIONE

- Il nome dell'utente compare come "mauro" minuscolo nella bolla del benvenuto di Medora. Va con la maiuscola ovunque compaia il vocativo.
- Il pulsante dice "Entra nel Santuario". A video il Santuario non esiste più, si chiama **Cerchio**. Sostituisci ogni occorrenza mostrata all'utente. I nomi di file e classi restano come sono.
- In "Chi risuona in te" il nome Medora va a capo lasciando la "a" sulla riga sotto. Deve stare su una riga sola, rimpicciolendo se serve.
- Nel benvenuto di Medora l'avatar copre i titoli. Nella home del Cerchio i bustini coprono le scritte sotto. Il testo non deve mai finire sotto una figura.
- La silhouette animata che invita a toccare ha una forma infelice. Va ridisegnata: mano stilizzata oppure il fantasma del gesto del punto 8 del GATE UX, mai una forma allungata verticale.

---

# PARTE 6, VELOCITA' DEL CICLO E INTEGRITA'

**Un solo APK**, arm64. Non più `--split-per-abi`, che ne costruisce tre.

**Controllo di integrità degli asset.** Il 27 luglio un APK è partito privo delle 79 immagini dei tarocchi, con 765 test verdi e analyze pulito, e nessuno se ne è accorto fino all'analisi del peso. Il lucchetto esistente confronta il pubspec col manifest, cioè due dichiarazioni fra loro. Serve un controllo che apra l'archivio APK costruito e verifichi che ogni famiglia dichiarata sia dentro col conteggio giusto.

**Ripristino del Risveglio in debug.** Una voce nelle Impostazioni, visibile solo nelle build di debug come la striscia del token, che azzera profilo e identità e fa ripartire l'onboarding con un tocco.

---

# CRITERI DI ACCETTAZIONE, IN NUMERI

**Identità**
- I tre angeli sono calcolati e coperti da test sui confini: 0 gradi, 359,9 gradi, 00:00, 00:19, 00:20, ultimo giorno dell'anno.
- Senza ora di nascita l'angelo dell'intelletto non viene mostrato come noto, e compare l'invito a inserire l'ora. Un test verifica entrambi i casi.
- La tessera degli Angeli nel Passport è toccabile e apre la schermata dedicata. Un test lo verifica.
- La schermata dei tre Angeli mostra tre carte con tre immagini distinte prese da `assets/img/angeli/`, non ripieghi dipinti.
- La carta natale contiene Sole, Luna, Ascendente, Numero della Vita, Animale Guida e i tre Angeli. Un test conta le sei presenze.
- Le tre animazioni di trionfo esistono e hanno durata maggiore di zero, e sono disattivate con Riduci Movimento. Un test verifica entrambi gli stati.
- Il centro del sigillo cade fra il 45 e il 55 per cento dell'altezza utile.

**Scena**
- In tutto `lib/` resta **una sola** classe che disegna il cielo di fondo vivo, esclusa `SkyPostcard`. Un test le conta.
- Esiste **una sola** iscrizione all'accelerometro in tutta l'app. Un test lo verifica.
- Lo spostamento massimo da sensore sul piano principale del cielo passa da 2,16 px ad almeno **24 px logici**. Il rapporto fra ampiezza del dito e ampiezza del sensore non supera **3 a 1** su entrambi gli assi. Un test calcola i due valori e li confronta.
- Carta natale, portale del Passport, "Chi risuona in te" e benvenuto di Medora reagiscono al sensore. Un test lo verifica.
- Quattro schermate diverse hanno quattro semi di fondale diversi. Un test lo verifica.
- `ScrollReveal` è guidato dalla posizione nello schermo: una scheda fuori vista non è ancora comparsa. Un test lo verifica.

**Posizione**
- Nella schermata del cielo esiste un comando toccabile con la sua chiave, e al tocco viene invocata la richiesta di permesso. Con servizio spento oppure permesso negato in modo permanente compare una via d'uscita verso le impostazioni. Un test copre i tre casi.

**Maestri**
- Il tocco su un laterale produce una transizione animata di durata maggiore di zero, e il trascinamento orizzontale cambia il Maestro centrale. Un test verifica entrambi.

**Testi**
- Zero occorrenze della parola "Santuario" nei testi mostrati a video. Un test scandaglia le stringhe.
- Il vocativo ha sempre l'iniziale maiuscola, verificato su un nome scritto minuscolo.
- Nessuna sovrapposizione fra figura e testo nelle due schermate segnalate, misurata sulle anteprime rigenerate.

**Sempre**
- L'APK prodotto è uno solo, arm64.
- Il controllo di integrità degli asset è verde, e fallisce se si toglie una famiglia dal bundle senza aggiornare il manifest.
- Suite intera verde, `flutter analyze` pulito, zero nuovi avvisi.

---

# GATE UX

Apri il gate a dieci voci prima di toccare ogni schermata. In particolare il punto 8 sugli inviti e le affordance, e il punto 9 sulla promessa mantenuta.

# FUORI SCOPE

Non toccare i due motori lunari né le due implementazioni del numero della vita: blocco successivo. Non spostare gli asset su CDN. Non toccare `docs/STATO_VIVO.md` né `ORDINE_ENTITLEMENT.md`.

# ALLA FINE

```
flutter build apk --debug --target-platform android-arm64 --dart-define=APP_CHECK_DEBUG_TOKEN=2f4013f2-e6e7-49b2-a3aa-402f28cd365a
```

```
firebase appdistribution:distribute "build/app/outputs/flutter-apk/app-debug.apk" --app 1:425821975933:android:1b1ca4db8d4df69b940814 --testers "cloud@esotericircle.app" --release-notes "Identita completa e un solo sistema di scena"
```

Un solo destinatario, `cloud@esotericircle.app`.

# AUTORIZZAZIONE

Itera da solo finché i numeri passano, debug incluso. Non chiedere conferme su scelte interne.

# COME RIPORTARE

In `docs/ordini/ESITO_CORRENTE.md`: ogni criterio numerico col valore misurato, non con un aggettivo. Voglio leggere l'ampiezza in pixel prima e dopo, il rapporto dito su sensore, il conteggio delle classi di fondale rimaste, e le tre regole di attribuzione degli angeli come le hai implementate.

Niente trattino lungo. Niente proposizione dopo la virgola che inizia con la lettera e.
