# ORDINE AO. LE RIPARAZIONI DAL COLLAUDO DELLA 2182

Otto voci, da AO.01 ad AO.08. Ramo `claude/esoteric-circle-master-order-e798aj`,
premesse verificate sulla testa `84a49253` il 18 agosto 2026.

## Come si legge questo file

Una riga per voce, con lo stato in fondo. Stati ammessi: APERTA, CHIUSA,
FERMATA SU PREMESSA FALSA, FERMATA IN ATTESA DI DECISIONE. Finche' una riga
e' APERTA la guardia `test/ordine_ao_guard_test.dart` resta rossa. Le voci
che si vedono o si sentono sul telefono (AO.01, AO.02, AO.05, AO.06, AO.07) a
cura fatta e guardia verde vanno in FERMATA IN ATTESA DI DECISIONE: le chiude
il collaudo di Mauro sulla build di AO.08. Un commit per voce; prove mirate
durante le voci e suite intera UNA volta ad AO.08.

## Perche' quest'ordine esiste

Il collaudo di Mauro sulla 2182. La barra sottile va bene ma il centro deve
dire sempre "Eventi Cosmici"; la barra aperta deve ritirarsi anche con lo
scorrimento; la striscia dei doni occupa troppo spazio verticale; non tutti i
premi dei traguardi arrivano al borsellino; il Test Archetipo riaperto non
permette di fare piu' nulla; il cielo di sfondo si blocca tornando dal
background o dopo alcune funzionalita', e serve una soluzione definitiva senza
rinunciare a profondita' e parallasse; la festa non si vede diversa per ogni
Maestro, che Mauro aveva chiesto.

## Il vincolo permanente, da riportare in ogni ordine futuro

**LA SCRITTA ESPLORA E IL SUO MENU' A SCOMPARSA NON SI TOCCANO**, ed e'
normale che a volte si sovrappongano ad altro. E' una decisione di Mauro del
17 agosto 2026. La segnalazione fatta nel rapporto dell'ordine AN su quella
sovrapposizione e' quindi CHIUSA come NON DIFETTO, e non apre nessuna voce
qui ne' altrove.

## Le premesse, verificate una per una il 18 agosto 2026

1. **P1 VERA.** La barra e' `lib/features/shell/barra_dell_identita.dart`,
   nata con l'ordine AM voce 04 e rivestita dall'ordine AN voce 02. Il centro
   e' `_IlCieloCheViene` (riga 310), che chiama `ProssimiEventi.da` (riga 336)
   e scrive `LinguaDegliEventi.rigaDellaBarra` (riga 382), cioe' il PROSSIMO
   EVENTO col conto alla rovescia; il tocco porta gia' a
   `NavigazioneDellaBarra.alCalendario()` (riga 218). L'apertura e la chiusura
   passano da `_aperta` (riga 82) e dal solo tocco (riga 145).
2. **P2 VERA, COL NUMERO MISURATO E UNA PRECISAZIONE.** La striscia e'
   `lib/features/santuario/daily_strip.dart`. L'altezza RESA, misurata
   montandola a tre larghezze vere, e' **146,0 punti a 360, 390 e 412**, di
   cui **99,0** sono la fila delle icone (la chiave `sfumatura_dei_doni`);
   il resto sono 8 di respiro sopra, la riga "I tuoi doni del giorno" e 6 di
   stacco. Le costanti `_heightLarga` e `_heightStretta` (righe 374 e 375)
   valgono 146 tutte e due, quindi la striscia non si stringe mai.
   **L'avviso con l'orario ESISTE, ed e' uno solo**: il sottotitolo della
   casella del Tramonto, `subtitle: isRuna ? _contoTramonto(now) : null`
   (riga 611), che scrive "tra 1h 20min" e si vede nell'anteprima
   `docs/preview/barra-home.png` sotto la casella. NON e' invece un avviso il
   testo "Alle HH:MM" del popup informativo (riga 250): quello si apre solo
   toccando il punto interrogativo, cioe' e' un'informazione CHIESTA e non
   una che compare, e resta dov'e'.
3. **P3 VERA.** Il client chiede il premio per NOME e mai per importo
   (`lib/core/sigilli/bonus_della_condivisione.dart`), il server decide in
   `functions/src/borsellino.ts`, e dall'ordine AN esistono
   `lib/core/sigilli/libro_degli_accrediti.dart` e la sincronia che parte
   all'avvio in `lib/features/sigilli/regia_del_cammino.dart`.
4. **P4 VERA.** Sul server l'unico tetto e' `TETTO_CONDIVISIONI_PREMIATE = 3`
   (`functions/src/borsellino.ts` riga 71), che riguarda le condivisioni:
   nessun tetto giornaliero sui premi dei traguardi, ne' altrove. Mauro ha
   dichiarato il 18 agosto che il tetto NON si fa: non si costruisce e non si
   predispone niente.
5. **P5 VERA.** `lib/features/sigilli/direzione_della_festa.dart` esiste e
   porta le tre feste con conteggi diversi: Medora 90 particelle, Caligo 40,
   Aura 90, ciascuna con la sua direzione. In
   `lib/features/sigilli/celebrazione.dart` il Maestro della festa si prende
   da `sentieri.first.maestro` alle righe 261, 565 e 703, riletti oggi.
6. **P6 VERA.** Il cielo e'
   `lib/design_system/components/cosmos_background.dart`. La sospensione e' un
   INTERRUTTORE: il bool `_coperto` (riga 138) e il contatore
   `quantiSospesi` (riga 34), mossi da `didPushNext` (riga 148) e
   `didPopNext` (riga 161), che sono due eventi opposti del RouteObserver.
   `AppLifecycleState` NON compare nel file: **zero occorrenze**, contate.
7. **P7 VERA.** `_TesseraArchetipo` in
   `lib/features/passport/cosmic_passport_screen.dart` (riga 736) mostra
   l'emblema dentro una `Image.asset` (riga 768) e non ha nessun tocco:
   nessun InkWell, nessun GestureDetector, nessun Navigator nel corpo della
   classe, cercati per enumerazione.
8. **P8 VERA.** L'archetipo e' UN DATO SOLO dal 6 agosto 2026, registrato in
   `docs/STATO_VIVO.md`, e le linee guida trasversali
   (`docs/03_Linee_Guida_UX_Trasversali.md` riga 101) dicono che le feature
   identitarie fisse, archetipo compreso, espongono una card di messaggio del
   giorno VARIABILE SUI TRANSITI: la figura sta ferma, la lettura cambia.

## Le voci

- **AO.01** Il centro della barra dice "Eventi Cosmici" — FERMATA IN ATTESA DI DECISIONE
  (`_IlCieloCheViene` diventa `_PortaDegliEventiCosmici`: una scritta sola,
  la stessa da chiusa e da aperta, che da aperta cresce senza diventare
  un'altra cosa. **IL TOCCO PORTA AL CALENDARIO SEMPRE**, e non piu' solo da
  aperta: la regola dell'ordine AM voce 04, per cui il primo tocco apriva
  soltanto la fascia, nasceva quando qui c'era una NOTIZIA da ingrandire, e
  una porta col nome scritto sopra che al primo tocco fa altro insegna a non
  fidarsi del proprio dito. La barra si apre dal volto e dalla fascia, che
  restano dov'erano. Il conto alla rovescia esce dalla barra e resta nel
  Calendario, che lo mostra gia' per ogni evento; il motore `ProssimiEventi`
  di AN.01 resta intero e la guardia lo verifica in positivo, insieme al
  fatto che il Calendario continua a chiederlo. Sei import morti tolti dalla
  barra. Guardia `test/il_centro_della_barra_dice_eventi_cosmici_test.dart`
  con quattro rossi provati; tre prove sorelle cambiate di grandezza col
  perche' scritto accanto, piu' la cattura dell'anteprima che ora apre il
  Calendario con un tocco solo invece di due; anteprima rigenerata e
  guardata. Chiude il collaudo di Mauro sulla 2183)
- **AO.02** La barra aperta si ritira da sola — FERMATA IN ATTESA DI DECISIONE
  (le quattro vie sono i quattro modi di smettere di guardarla, e due
  esistevano gia': il cambio di schermata copriva l'apertura di una rotta e
  il ritorno indietro, mentre lo SCORRIMENTO e il TOCCO FUORI non ritiravano
  niente, misurato a 88 punti su 30. La cura sta in `_ritira()` dentro
  `_BarraDellIdentitaState`, con due ascolti sopra tutta l'app e nessuna
  schermata che sappia della barra: un `Listener` a
  `HitTestBehavior.translucent` e un `NotificationListener` sugli
  scorrimenti, che restituisce falso perche' la notizia continui a salire.
  **Due tentativi sbagliati, misurati e non indovinati**: `deferToChild` non
  faceva scattare il ritiro sul fondo cosmico, dove nessun widget partecipa
  all'esame del tocco; e il punto scelto per la prova e' stato spostato due
  volte, perche' il primo apriva il dominio dal carosello e il secondo
  cadeva dentro la barra di navigazione del Cerchio, che vive in un altro
  ramo. Ritiro morbido misurato su un fotogramma solo, e SECCO con Riduci
  Movimento, dichiarato alla finestra come fa il sistema operativo. Guardia
  `test/la_barra_si_ritira_da_sola_test.dart` con sette prove e ROSSO
  PROVATO SU TUTTE E QUATTRO LE VIE, spegnendo prima gli ascolti e poi anche
  il ritiro sul cambio di rotta. Chiude il collaudo di Mauro sulla 2183)
- **AO.03** La striscia dei doni occupa meno spazio — CHIUSA
  (**da 146,0 a 122,0 punti**, misurati prima e dopo montandola a 360, 390 e
  412: ventiquattro punti tornati al cielo e alla carta del Maestro. Dodici
  vengono dallo SLOT MORTO del conto alla rovescia, che stava sotto ogni
  casella per scrivere sotto una sola, e dodici dai quattro stacchi interni,
  da otto e sei a quattro ciascuno. **Nessuno dall'area di tocco**: cerchio
  dell'icona 46 e bersaglio dell'aiuto 44 per 44, misurati dopo la cura.
  L'avviso col conto alla rovescia esisteva davvero, come dice la P2, e se
  n'e' andato con lui il battito ogni TRENTA SECONDI che lo faceva scorrere,
  cioe' centoventi ricostruzioni all'ora: al suo posto una sveglia sola al
  primo istante che cambia qualcosa, il tramonto o il mezzogiorno rituale.
  L'ora del dono non e' andata perduta, resta dove si CHIEDE, nella
  spiegazione del punto interrogativo, e una prova la cerca li'. Guardia
  `test/la_striscia_dei_doni_non_ruba_spazio_test.dart` con sei prove e
  rosso provato sulle tre altezze; tre prove sorelle di `daily_strip_test`
  cambiate di grandezza col perche' accanto, perche' misuravano il conto che
  non esiste piu' e ora misurano l'ACCENSIONE della casella, che e' quello
  che la persona vede. **Due trappole trovate misurando** e scritte accanto
  alla prova: la casella e' accesa anche solo perche' la Runa e' l'elemento
  corrente fra le 18:30 e le 22:30, e con una posizione italiana il tramonto
  cade sempre prima delle 22:30, quindi per distinguere la posizione vera
  dalla stima dal fuso serve un luogo molto a ovest del suo fuso. Anteprime
  rigenerate e guardate)
- **AO.04** I premi dei traguardi arrivano tutti — CHIUSA
  (**IL FILO DEI PREMI E' INTERO, e il difetto stava prima.** L'enumerazione
  ha percorso i sette passi, dal gesto al saldo, e i quattro candidati
  dell'ordine: il premio si chiede per NOME e mai per importo; il server che
  rifiuta NON fa segnare il libro, quindi quei premi restano da riprendere;
  la rete assente lascia il Sigillo acceso e il premio in lista; la
  sincronia li riprende TUTTI; tre scritture del libro nello stesso istante
  non ne perdono nessuna. **Criterio di accettazione soddisfatto**: in una
  festa unita da tre traguardi, tre movimenti distinti e 40 Eos accreditati
  contro 40 attesi.
  **LA CAUSA VERA ERA CHE IL TRAGUARDO NON MATURAVA**, e viene dalla stessa
  famiglia della voce AN.04: `DiarioDelCammino` veniva costruito con
  `..carica()` senza attesa, e chi apriva l'app e faceva subito un gesto
  incontrava questa sequenza: `segna` contava il gesto su mappe ancora
  VUOTE, portando le stese da tre a uno; `_salva` scriveva quel conto povero
  sul disco, cancellando la storia; e il caricamento, atterrando, rileggeva
  cio' che era appena stato scritto. Il cammino tornava al primo giorno e i
  traguardi che aspettavano un conteggio si allontanavano. **Il difetto era
  gia' stato incontrato e AGGIRATO DENTRO UNA PROVA** invece che curato: il
  commento della guardia della lampadina lo descriveva parola per parola, e
  quell'aggiramento adesso non serve piu'.
  **La cura fonde invece di aspettare, e la prima cura era sbagliata**: far
  attendere ogni scrittura fino a lettura avvenuta e' giusto nell'app ma
  velenoso nelle prove, dove un gesto compiuto nel tempo vero mentre il
  caricamento dorme nel tempo finto aspetta per sempre, e due guardie sono
  rimaste appese otto minuti invece di cadere. Adesso chi scrive scrive
  subito, `_salva` RIMANDA finche' il disco non e' stato letto per non
  cancellare la storia sotto la lettura, e il caricamento SOMMA i conteggi
  invece di sostituirli, unisce gli elenchi e tiene la serie piu' lunga.
  Guardie `test/i_premi_dei_traguardi_arrivano_tutti_test.dart` (cinque
  prove, l'enumerazione) e `test/il_diario_non_riparte_da_zero_test.dart`
  (tre prove, la causa), con rosso misurato: una stesa invece di quattro,
  disco riscritto povero e Sigillo acceso sparito. NESSUN TETTO
  GIORNALIERO, vedi P4)
- **AO.05** Ogni Maestro ha la sua festa, e si vede — APERTA
  (la festa porta il Maestro del traguardo che si sta celebrando, e nella
  festa unita la scena dichiara come sceglie; tre anteprime affiancate)
- **AO.06** L'archetipo si rilegge, e dal Passport si apre — APERTA
  (emblema piu' lettura di oggi dai transiti; il test si rifa' dopo tre mesi
  con la data dichiarata a schermo; l'emblema del Passport diventa toccabile;
  LA CARTA NATALE NON CAMBIA MAI)
- **AO.07** Il cielo non si ferma piu', e la profondita' resta intera — APERTA
  (la sospensione da interruttore diventa stato calcolato su rotta in cima E
  app in primo piano, rivalutato a ogni cambio di rotta, di ciclo di vita e a
  ogni ricostruzione, piu' una sentinella che riparte e registra; la resa
  dell'ordine AM voce 02 non si tocca)
- **AO.08** Il manifesto, la suite, la build 2183 — APERTA
  (stati veri e marcatori contati; se qualcosa tocca functions le prove del
  server girano prima e il deploy lo esegue Mauro; suite intera una volta,
  verde sui rossi di legge dichiarati; build 2183 arm64 e distribuzione coi
  comandi e le note dell'ordine)

## I marcatori, contati sulle righe

VOCI_TOTALI: 8
VOCI_APERTE: 4
VOCI_CHIUSE: 2
VOCI_FERMATE_SU_PREMESSA_FALSA: 0
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 2
