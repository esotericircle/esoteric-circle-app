# ORDINE CW, MANIFESTO

7 settembre 2026. Otto voci nate dalla prova del fondatore, piu' la coda
dell'Alba e del Soffio che lui ha riaperto a voce durante il lavoro.

**E' il primo ordine chiuso con la verifica visiva sul dispositivo di
collaudo.** Seriale 767f596c, Realme RMX3081. Ogni voce che tocca una
schermata porta lo screenshot che dimostra la correzione, e gli screenshot
stanno in `docs/verifica/CW/`. Questo cambia il peso di cio' che segue: dove
prima c'era una guardia verde, adesso c'e' una guardia verde **e** una
fotografia.

---

## REGOLA ZERO, applicata

L'ordine avvisava che il suo testo non e' una fonte attendibile sul codice.
**Tre voci su otto avevano la premessa sbagliata**, e sono state corrette
prima di lavorarci:

- **CW.02** diceva che il Sigillo del Sogno non ruota il Maestro. Ruota: la
  rotazione esiste e funziona da sempre. **Era il solo pulsante** a portare
  `Maestro.caligo` scritto a mano.
- **CW.05** era data come regressione. Non lo era: **la correzione non era
  mai stata fatta**, la voce CQ1.07 aveva misurato un'altra cosa.
- **CW.06** attribuiva la perdita delle notifiche al fuso orario. Il fuso era
  gia' stato riparato dall'ordine CQ voce 1.09. La causa era altrove, ed
  erano **due** cause, non una: vedi sotto.

---

## LE VOCI

- **CW.01** La musica non si ferma quando l'app va in secondo piano.
  **CHIUSA**, e la causa non era il governo del ciclo di vita: quello c'era e
  chiamava il metodo giusto. Era **l'ordine delle attese**. `fermaTutto`
  spegneva tre sorgenti una dopo l'altra con tre `await` in fila, e la
  chiamata di `audioplayers` su una sorgente che non torna **impedisce di
  arrivare alla seconda**, cioe' proprio alla musica. Adesso le tre chiamate
  partono tutte e si aspettano insieme, con un tetto di due secondi.
  Al ritorno la musica **riprende dov'era, ma solo se stava suonando quando
  siamo usciti**: chi era in una schermata muta e chi l'aveva spenta dalle
  impostazioni hanno in comune che non stava suonando, e a nessuno dei due
  l'app deve accendere qualcosa che non aveva chiesto.
  Guardie nuove `nessuna_sorgente_resta_accesa_in_sottofondo` e
  `la_musica_riprende_solo_se_stava_suonando`, nate rosse con una sorgente
  che non torna mai.
  **Misurato sul telefono:** premuto il tasto Home alle 22:43:24, alle
  **22:43:25.102** la piattaforma registra `player piid:1127 state:paused`
  sul lettore della musica dell'app. Un secondo.

- **CW.02** Il Sigillo del Sogno nomina due Maestri diversi. **CHIUSA**: il
  testo del responso prendeva il Maestro del giorno, il pulsante ne aveva uno
  scritto a mano. Adesso decide una sorgente sola.
  Guardia nuova `il_sigillo_del_sogno_nomina_un_maestro_solo`.
  **Visto a video:** `48_sigillo_responso.png` dice *"Oggi Medora ha letto il
  tuo momento"*, e `49_sigillo_pulsante.png` dice **Parlane con Medora**.

- **CW.03** Il battito theta: da dove nasce, e cos'e'. **CHIUSA senza togliere
  niente**, come l'ordine chiedeva. Le tre risposte:
  **origine** ordine BM voce 04; **non e' una traccia registrata**, il
  Cerchio genera due toni sul momento; **generato, e adesso lo dichiara**.
  L'etichetta a video dice *"Tono theta generato, con le cuffie"*, e il
  foglio delle fonti porta i numeri: 210 hertz a sinistra, 217 a destra, la
  differenza di 7 hertz e' il battito, e nasce solo con le cuffie perche' ha
  bisogno di un orecchio per canale.
  **Visto a video:** `41_sigillo_tono.png` e `49_sigillo_pulsante.png`.

- **CW.04** Il tooltip che confessava GPS e bussola mancanti. **CHIUSA**, ed
  e' la stessa famiglia della confessione degli Angeli che ha aperto l'ordine
  CS. **Misurato sensore per sensore: nessuno dei tre serviva al calcolo.**
  Segno e fase della Luna vengono dalla sola data e sono gli stessi in ogni
  punto della Terra; la bussola orienterebbe la scena e non il rito; le
  effemeridi ci sono gia' e girano sul dispositivo. La riga diceva anche una
  cosa falsa.
  **Due guardie tenevano viva quella frase**, in `dream_rite_screen_test` e
  in `dream_rite_test`: due prove che pretendono la stessa confessione sono
  due ragioni per non toglierla mai.
  **Censimento delle altre ammissioni a video, cinque, elencate e non
  riparate** come l'ordine chiedeva, con la riga esatta:
  - `lib/core/permissions/esito_del_permesso.dart:117`, *"Qui manca il
    sensore che servirebbe"*.
  - `lib/features/rituals/sunset_rune_screen.dart:833`, *"Ora stimata, la
    posizione non e' attiva"*.
  - `lib/features/rituals/sunset_rune_screen.dart:834`, *"Ora stimata delle
    ..., la posizione non e' attiva"*.
  - `lib/features/rituals/sunset_rune_screen.dart:835`, la chiave
    `sunset_stimata` che le porta a video.
  - `lib/features/rituals/sunset_rune_screen.dart:1690`, *"Il tramonto e'
    stimato dal fuso, la posizione non e' attiva"*.

  **Non sono tutte della stessa specie del tooltip**, e la differenza conta:
  quelle del Tramonto dichiarano che l'ora e' STIMATA, cioe' dicono qualcosa
  di vero su cio' che si legge. La formula *"la posizione non e' attiva"*
  resta pero' una confessione di un'assenza, e la voce chiedeva l'elenco, non
  la cura.
  **Visto a video:** `40_sigillo_fonti.png`.

- **CW.05** I punti della costellazione finiscono dentro il titolo.
  **CHIUSA**, e **non era una regressione**: la correzione non era mai stata
  fatta. Adesso la stella piu' alta si ferma sotto il rettangolo VERO del
  titolo, letto con `getRect`, piu' un margine dichiarato di 12 punti.
  Guardia nuova `nessun_punto_cade_dentro_il_titolo`. La prova del rosso ha
  richiesto due tentativi: **a inclinazione zero le stelle stanno gia' sotto
  la barra**, e il rosso e' scattato solo guidando il ripiego a dito.
  **Visto a video:** `39_sigillo_nebbia.png`, la prima stella della
  costellazione, e `48_sigillo_responso.png`, tutte e sette unite: nessuna
  dentro il titolo.

- **CW.06** Due notifiche su cinque. **CHIUSA, e le cause erano due.**
  - **La prima, il manifest.** Non c'era nessun receiver: senza
    `RECEIVE_BOOT_COMPLETED` e senza `ScheduledNotificationBootReceiver` la
    coda si svuota al riavvio del telefono **e a ogni aggiornamento
    dell'app**. Chi installa una build nuova quasi ogni giorno azzerava le
    cinque chiamate ogni giorno. Aggiunte le tre azioni, `BOOT_COMPLETED`,
    `MY_PACKAGE_REPLACED` e i due `QUICKBOOT_POWERON`.
  - **La seconda l'ha trovata il telefono, non il banco.** Con `dumpsys
    alarm`, dopo aver concesso il permesso dentro il Rito dell'Alba, nella
    coda del sistema c'era **una sveglia sola**. All'avvio la regia guarda il
    permesso, non lo trova e torna a mani vuote; poi il rito ottiene il
    permesso e programma **solo se stesso**. Le altre quattro aspettavano
    l'apertura successiva dell'app, e quel giorno non suonavano. Adesso il
    rito passa dalla regia, che e' la porta di tutte e cinque, e subito dopo
    riscrive l'Alba sullo stesso id con l'ora del sorgere.
    Guardia nuova `il_permesso_appena_dato_accende_tutte_e_cinque`, nata
    rossa con il numero esatto del difetto: *"arrivano 1 chiamate su 5"*.
  - **L'ora esatta resta NON richiesta, ed e' una scelta.** Da Android 14
    `USE_EXACT_ALARM` e' ristretta e Google Play la concede solo a sveglie e
    calendari: chiederla farebbe rifiutare la pubblicazione. La guardia la
    blinda, cosi' nessuno la aggiunge credendo di curare le notifiche.
  - **Misurato sul telefono, dopo la correzione:** cinque sveglie in coda,
    alle ore giuste e nel fuso giusto. 22:30 stanotte, poi 07:00, 10:30,
    13:00, 18:30 di domani.
  - **Cosa NON sono riuscito a dimostrare, e lo dico invece di darlo per
    visto.** La sveglia delle 22:30 e' partita, la coda lo conferma, ma
    **nessuna notifica e' comparsa nella tendina**. La ragione non l'ho
    trovata stanotte e non la invento: la prova vera e' la chiamata delle
    07:00 di domani mattina sul telefono del fondatore.
  - **Visto a video:** `53_notifiche.png`, i cinque appuntamenti e i cinque
    interruttori accesi.

- **CW.07** Il rituale in evidenza dentro il Rito dell'Alba. **CHIUSA**: un
  riquadro col bordo visibile, un titolo maiuscolo esatto, e dentro il solo
  rituale. Il titolo prende il ruolo `didascalia` e non `etichetta`, perche'
  la regola P.13 vieta il maiuscoletto su quel ruolo: il maiuscolo lo chiede
  l'ordine, la forma la decide la casa.
  **LA PAROLA E' DEL FONDATORE.** L'ordine diceva *IL RITUALE DI OGGI*; visto
  a video, lui ha scelto **IL MANTRA DI OGGI**, e quella e' la parola che
  vive. Cambiata la costante, le quattro chiavi, la guardia e il suo nome:
  chi cerca `del_rituale` non trova piu' niente, perche' un nome vecchio
  lasciato in una chiave e' la seconda verita' del giorno dopo.
  Guardia nuova `il_mantra_di_oggi_ha_il_suo_riquadro`, e la parola nuova le
  e' passata davanti **rossa**: cambiato il titolo in `lib` senza toccarla,
  la guardia e' caduta sul titolo esatto. E' la prova che sorveglia la
  parola e non la sua forma.
  **Visto a video:** `55_alba_rituale.png` porta ancora la parola vecchia,
  ed e' lo screenshot su cui il fondatore ha deciso. La conferma della parola
  nuova e' `56_alba_mantra.png`.

- **CW.08** I due pulsanti del Soffio non si leggono. **CHIUSA**, e **non era
  il colore scelto male: era il regime sbagliato.** Il Soffio passava
  `suChiaro: true` copiato dall'Alba, col commento *"il fondo qui e' chiaro"*:
  vero per l'Alba, falso per lui. I due pulsanti dipingevano l'inchiostro del
  regime chiaro sul vetro notturno, **1,11 a uno**. Adesso misurano
  **15,29 a uno** sulla soglia dichiarata di 4,5, che e' il minimo AA per il
  testo normale e si dichiara perche' nelle linee guida del progetto una
  regola di contrasto per i pulsanti non c'era.
  **Premuto e disabilitato sono misurati per nome**, come l'ordine chiedeva.
  Guardia nuova `i_due_pulsanti_del_soffio_si_leggono`.
  **Visto a video:** `33_soffio_pulsanti.png`, oro su vetro notturno.

## LA CODA, aperta dal fondatore a voce durante il lavoro

- **CW.09** *"I RESPONSI DI ALBA E SOFFIO SONO ANCORA UGUALI, CAZZO.
  PERCHE'?"* **CHIUSA**, e la ragione e' mia: la cura dell'ordine CQ era
  **condizionata e non dichiarata**. Funzionava per chi ha una carta natale
  completa, e per tutti gli altri il Soffio ripiegava sulla risposta
  dell'Alba. Chi non ha dato l'ora di nascita, che e' il caso piu' comune,
  vedeva due volte la stessa frase.
  Adesso il Soffio ha una risposta sua anche senza cielo, costruita su fase
  lunare e segno della Luna, che si leggono dalla sola data.
  Guardia nuova `l_alba_e_il_soffio_non_dicono_mai_lo_stesso`.

- **CW.10** *"bisogna dichiarare a cosa serve, cosa si ottiene quel giorno
  facendo il respiro"*. **CHIUSA**: il titolo del Soffio adesso dice a cosa
  serve il respiro di oggi, non cosa fa il cielo.
  **Visto a video:** `32_soffio_gesto.png`, *"Il respiro di oggi ti serve a
  lasciare andare una cosa che pesa"*, contro l'Alba di `55_alba_rituale.png`
  che dice *"Oggi il tuo giorno vuole aperto"*. Profilo senza ora di nascita,
  cioe' esattamente il caso che il fondatore ha segnalato.

---

## REGOLA D, cosa funzionava prima e cosa funziona adesso

Le tre schermate toccate, percorse a mano sul telefono dopo la correzione.

**Sigillo del Sogno.** Prima: la nebbia si dirada col dito, le sette stelle si
uniscono, il responso arriva, il tono theta si accende, si condivide e si
custodisce. Adesso: **tutto quanto sopra**, piu' il pulsante che nomina il
Maestro giusto, il tono che dichiara di essere generato, il tooltip che non
confessa piu' niente e le stelle che non entrano nel titolo. Percorso intero
a video, dall'apertura al responso.

**Rito dell'Alba.** Prima: il gesto solleva l'alba, il dono compare, il
permesso degli avvisi si chiede una volta sola con la sua spiegazione, la
continuita' si segna, si condivide. Adesso: **tutto quanto sopra**, piu' il
riquadro del rituale col suo titolo, piu' le cinque chiamate accese invece di
una. Percorso intero a video, permesso concesso compreso.

**Soffio del Destino.** Prima: il gesto del soffio col ripiego a dito, la
guida al respiro, la risposta, la continuita', i tre pulsanti. Adesso: **tutto
quanto sopra**, piu' i due pulsanti leggibili e una risposta che non somiglia
piu' a quella dell'Alba. Percorso intero a video.

---

## COSA HA TROVATO IL TELEFONO, E CHE SENZA DI LUI AVREI CONSEGNATO SBAGLIATO

Il fondatore ha chiesto questa sezione per nome. E' il conto onesto di cosa ha
prodotto il collegamento vivo col dispositivo, separato da cio' che le guardie
avevano gia' garantito.

**UNA COSA SAREBBE STATA CONSEGNATA ROTTA, e la voce era gia' dichiarata
CHIUSA.**

**La seconda causa della voce CW.06.** Avevo riparato il manifest, aggiunto il
receiver, scritto la guardia, vista rossa, e chiuso la voce. Sul banco tutto
tornava: cinque Doni accesi di partenza, cinque pianificazioni distinte,
nessuna scartata, nessuna nel passato. **Il difetto vero stava dove nessuna
prova di questo progetto puo' guardare, cioe' dentro la coda delle sveglie di
Android.** L'ho visto solo perche' ho chiesto `dumpsys alarm` al telefono dopo
aver concesso il permesso a mano dentro il rito: **una sveglia sola invece di
cinque**. La causa e' un ordine di eventi che nessun test unitario incontra,
perche' vive fra due sessioni dell'app: all'avvio la regia guarda il permesso e
non lo trova, poi il rito lo ottiene e programma solo se stesso.

Senza telefono avrei consegnato una build in cui **chi installa e prova subito
riceve una chiamata su cinque quel giorno**, con la voce che diceva CHIUSA e la
guardia verde. E' esattamente il difetto che il fondatore aveva segnalato, e lo
avrei consegnato dentro l'ordine che doveva ripararlo.

**UNA PAROLA SAREBBE STATA SBAGLIATA.** Il riquadro del Rito dell'Alba. Il
titolo lo avevo preso alla lettera dall'ordine, *IL RITUALE DI OGGI*, e la
guardia lo pretendeva alla lettera: verde, corretta, e sbagliata. Il fondatore
l'ha letta sullo screenshot e ha scelto **IL MANTRA DI OGGI**. Senza la
fotografia quella parola sarebbe entrata in produzione e sarebbe tornata
indietro come segnalazione al collaudo successivo, insieme alle quattro chiavi
e al nome del file che la portavano dentro.

**QUATTRO DIFETTI CHE NON SAREBBERO STATI NEMMENO VISTI**, e stanno nella
sezione qui sotto: la barra di conferma che non se ne va piu' e copre il terzo
basso dello schermo, il tappeto musicale che non entra mai in `started`, le due
etichette inglesi del selettore dell'ora, il foglio delle fonti che passa sotto
la barra degli Eos. Nessuna guardia di questo progetto li cercava, e nessuna li
avrebbe trovati: **tre su quattro non sono nel codice dell'app**, sono
nell'incontro fra l'app e il sistema che la ospita.

**UNA DOMANDA CHE SENZA IL TELEFONO NON AVREI POTUTO NEMMENO PORRE.** La
sveglia delle 22:30 e' partita, e nessuna notifica e' comparsa. Non ho la
risposta, ma so che la domanda esiste, e sul banco non sarebbe esistita.

**E ADESSO LA META' ONESTA DEL CONTO: cosa il telefono ha soltanto
CONFERMATO.** Sei voci su dieci erano gia' giuste quando le ho portate a video,
e le guardie bastavano: il Maestro nominato una volta sola, l'etichetta del
tono theta, il tooltip senza confessioni, le sette stelle sotto il titolo, i
due pulsanti del Soffio leggibili, l'Alba e il Soffio che dicono cose diverse.
Su queste il collegamento vivo non ha corretto niente: ha aggiunto la certezza,
che non e' poco, ma non e' una riparazione. **La distinzione vale quanto le
riparazioni**, perche' dire che il telefono ha salvato dieci voci quando ne ha
salvate due sarebbe lo stesso genere di bugia che questo progetto combatte.

---

## COSA HO VISTO SUL TELEFONO CHE NON E' UNA VOCE DI QUESTO ORDINE

Si scrive qui perche' l'ho misurato, non perche' l'ordine lo chiedesse. Non e'
riparato, ed e' materia del prossimo ordine.

1. **La barra di conferma dell'ora non se ne va piu'.** Dopo aver toccato
   l'ora di una notifica, *"Rito dell'Alba ti chiamera' alle 07:00"* resta a
   video, segue la persona nelle altre schermate e copre il terzo basso dello
   schermo, riquadro del rituale compreso. Ha resistito a un'attesa lunga e a
   una scacciata a dito. Misurato due volte.
2. **Il tappeto musicale non suona mai su questo telefono.** Il lettore viene
   creato con `USAGE_MEDIA` e `CONTENT_TYPE_MUSIC`, e non entra mai in
   `state:started`. Riceve la pausa e la riceve puntuale, cioe' la voce CW.01
   e' vera, ma la musica non si sente. Il sospetto sta in una memoria di casa,
   il fuoco audio esclusivo, e resta un sospetto.
3. **Il selettore dell'ora parla inglese.** Le due etichette del selettore di
   Material dicono *Hour* e *Minute* dentro un dialogo tutto italiano. Manca
   il delegato di localizzazione italiano.
4. **Il foglio "Da dove nasce questo dono" passa sotto la barra degli Eos.**
   Il titolo del foglio finisce dietro la barra in cima e non si legge.

---

VOCI_TOTALI: 10
VOCI_CHIUSE: 10
VOCI_APERTE: 0
VOCI_FERMATE_SU_PREMESSA_FALSA: 0
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0
VOCI_FERMATE_SU_DECISIONE_DEL_FONDATORE: 0
GUARDIE_NUOVE: 9
PREMESSE_DELL_ORDINE_CORRETTE: 3
VERIFICA_A_VIDEO: 767f596c
