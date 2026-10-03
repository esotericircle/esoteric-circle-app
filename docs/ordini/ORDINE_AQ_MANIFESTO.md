# ORDINE AQ. QUELLO CHE MAURO HA VISTO SUL TELEFONO, E NON DEVE PIU' VEDERE

Sei voci, da AQ.01 ad AQ.06. Ramo `claude/esoteric-circle-master-order-e798aj`,
premesse verificate sulla testa `87da699` il 19 agosto 2026.

## Come si legge questo file

Una riga per voce, con lo stato in fondo. Stati ammessi: APERTA, CHIUSA,
FERMATA SU PREMESSA FALSA, FERMATA IN ATTESA DI DECISIONE. Finche' una riga
e' APERTA la guardia `test/ordine_aq_guard_test.dart` resta rossa. Un commit
per voce; l'ipotesi si verifica PRIMA di correggere.

## La regola che viene prima di tutte, e vale da quest'ordine in poi

**NESSUNA VOCE VISIVA SI CHIUDE SENZA CHE L'APP SIA STATA ACCESA SU UN
DISPOSITIVO E LA SCENA GUARDATA.** Dieci consegne di fila hanno saltato la
prova di accensione, e tutti i difetti di quest'ordine si vedevano in un
minuto su un telefono. Se nessun dispositivo e' collegato, la voce resta
FERMATA e il rapporto lo dichiara IN TESTA, non in fondo.

**Le anteprime che dimostrano una scena si generano montando la scena vera
dell'app, mai da uno strumento che compone il pittore.** Uno strumento
dimostra che il pittore sa disegnare, non che la persona vede.

**LA MISURA DEL 19 AGOSTO 2026, e comanda l'esito di quest'ordine.**
`flutter devices` trova tre dispositivi e nessuno e' un telefono: Windows
desktop, Chrome e Edge. `adb` non e' nemmeno nel PATH di questa macchina.
Quindi le cinque voci visive (AQ.01, AQ.02, AQ.03, AQ.04, AQ.05) restano
FERMATE IN ATTESA DI DECISIONE anche a cura fatta e guardia verde: le chiude
il collaudo di Mauro sulla 2185.

## Perche' quest'ordine esiste

Collaudo di Mauro sulla 2184, con schermate alla mano: il cosmo di sfondo non
si muove piu' e va a scatti, peggio della 2181 che lui aveva approvato; le
feste dei traguardi si vedono tutte uguali; la barra sottile compare durante
l'onboarding, per esempio sull'assegnazione dell'Animale Guida, e da li' si
puo' uscire dal rito; la schermata "Bentornato nel Cerchio" e' vuota; la
schermata "Non perdere il tuo cielo" e' confusionaria e scritta troppo
piccola.

## Il vincolo permanente, riportato come vuole l'ordine AO

**LA SCRITTA ESPLORA E IL SUO MENU' A SCOMPARSA NON SI TOCCANO**, ed e'
normale che a volte si sovrappongano ad altro. Decisione di Mauro del 17
agosto 2026.

## Le premesse, verificate una per una il 19 agosto 2026

1. **P1 VERA, alla lettera.** `lib/features/sigilli/celebrazione.dart` righe
   613, 614 e 615: `Icons.star_rounded` per la Costellazione,
   `Icons.spa_rounded` per l'Albero, `Icons.local_florist_rounded` per il
   Loto. Sono tre glifi di sistema, e `spa_rounded` E' un fiore di loto:
   due sentieri su tre mostrano alla persona lo stesso fiore.
2. **P2 DA MISURARE dentro la voce 02.** La differenza per Maestro esiste nel
   pittore: `direzione_della_festa.dart` dichiara 90 particelle per Medora, 40
   per Caligo e 90 per Aura, con direzioni diverse. L'anteprima
   `le-tre-feste-affiancate.png` viene da `tool/anteprime_delle_feste.dart`,
   cioe' da uno strumento. Cosa si veda nella scena VERA, e per quanti
   fotogrammi, e' la misura della voce.
3. **P3 DA MISURARE dentro la voce 01.** La sentinella esiste e batte ogni due
   secondi (`cosmos_background.dart` riga 298, `Timer.periodic`), e lo stato
   e' calcolato a ogni `build` da `_deveGirare` (riga 172), che interroga
   `ModalRoute.of(context)` e il ciclo di vita. Quanto costi e' da misurare,
   non da supporre.
4. **P4 VERA, ed e' un vincolo.** Il conto degli elementi segue l'area del
   telo: `quantiSulTelo` in `cosmos_background.dart` riga 522. Quella resa
   non si tocca.
5. **P5 VERA.** `soglieSenzaBarraSottile` in
   `lib/features/shell/dove_si_vede_la_barra.dart` righe 113-122 ha QUATTRO
   soli nomi: `OnboardingScreen`, `RisveglioJourney`, `MaestroRevealScreen`,
   `ArtIntroScreen`. Tutto il resto del rito non e' dichiarato.
6. **P6 VERA.** `lib/features/onboarding/scena_del_ritrovamento.dart` riga 67
   mostra il titolo, sotto una riga sola, e poi le voci solo per cio' che c'e'
   davvero. Con un server che non custodisce ancora il cammino, l'unica riga
   con un dato e' quella degli Eos, che vengono dal borsellino: e' esattamente
   la schermata che Mauro ha visto vuota.
7. **P7 VERA.** `lib/features/onboarding/custodia_del_cielo_step.dart` porta
   titolo, DUE blocchi di testo di seguito (la ragione e "Collegalo a te in un
   tocco"), l'eventuale riga del guaio, l'eventuale "Continua come", TRE
   pulsanti e il "Piu' tardi": su un telefono sono nove elementi in colonna.

## Le voci

- **AQ.01** Il cosmo torna fluido, e la fluidita' vince. Stato: CHIUSA. Chiusa il 24 agosto 2026 (BF.03): la cura su inactive e' in ramo, la fluidita' definitiva e' arrivata con AW e il collaudo 2196 e' stato approvato.
  (**LA PREMESSA P3 E' FALSA, e la misura lo dice con i numeri.** Nasce
  `test/quanto_costa_il_cielo_test.dart`, che monta il cielo e la home vere e
  cronometra i fotogrammi; la stessa misura e' stata eseguita su un albero di
  lavoro separato fermo alla testa della 2181, `69ff2d69`. Microsecondi per
  fotogramma, tre giri per numero: cielo da freddo oggi 1271, 1204, 1210
  contro 1050, 1077, 1216 sulla 2181; cielo dopo essere tornati da una scena
  aperta oggi 804, 779, 797 contro 810, 752, 816; home ferma oggi 8880, 8531,
  8758 contro 8036, 8976, 8557; home mentre il dito scorre oggi 12375 contro
  11756. **Nessuno scarto**: dove c'e' una differenza sta dentro la
  variazione fra tre giri della stessa testa. E la sentinella, in dieci
  secondi, non ha dovuto riaccendere il cielo nemmeno una volta.
  **LA CAUSA VERA STAVA IN UNA RIGA SOLA, e nessuna misura di tempo poteva
  trovarla.** AO.07 ha scritto che il cielo gira solo se il ciclo di vita e'
  `resumed`, e in quel "solo" ci sta anche `inactive`. Su Android `inactive`
  NON vuol dire che l'app e' sparita: arriva a schermo acceso e app visibile,
  col pannello delle notifiche che scende, con un avviso di sistema, in certe
  transizioni. Misurato: mandando `inactive` il cielo si FERMA. Ogni volta si
  inchiodava fino al battito successivo della sentinella, fino a due secondi
  dopo, ed e' esattamente il fermarsi e ripartire che Mauro descrive, che
  sulla 2181 non c'era perche' prima di AO.07 il ciclo di vita non entrava
  nella decisione. Adesso ci si ferma solo quando l'app e' davvero via
  (`paused`, `hidden`, `detached`): **vince la fluidita'**, come l'ordine
  chiede, e il blocco di AO.07 non si riapre, perche' restano sia la domanda
  a `ModalRoute.isCurrent` sia la sentinella.
  La resa di AM.02 non e' stata toccata. Guardia con le soglie prese dal
  misurato e non da un'idea, e rosso provato: prima della cura la prova del
  ciclo di vita cadeva stampando `inactive: false`.
  **Nessun telefono ha acceso questa cura**: la chiude il collaudo di Mauro
  sulla 2185)
- **AQ.02** Le feste si vedono davvero diverse. Stato: CHIUSA. Chiusa il 24 agosto 2026 (BF.03): la meta' delle particelle e' stata superata dalla decisione del fondatore in AV, la meta' dei tre segni disegnati vive in segno_del_sentiero.dart ed e' in produzione.
  (**P1 era vera e la cura e' completa**: i tre glifi di Material sono spariti
  e nasce `lib/features/sigilli/segno_del_sentiero.dart`, che disegna tre
  forme distinte con la stessa mano, linee d'oro senza riempimenti: una
  stella a sei raggi con tre compagne per la Costellazione, un tronco che si
  divide in tre rami con le gemme per l'Albero, una corolla di cinque petali
  che si apre per il Loto. Sono dichiarate PROVVISORIE nel loro stesso file:
  nascono dal codice e non dagli asset di brand.
  **P2 e' risultata FALSA nella parte che accusava, e la misura lo dice.**
  Nasce `test/le_feste_si_vedono_diverse_test.dart`, che monta la scena VERA
  e la fotografa: fra due istanti della corsa cambiano dai 42 ai 66 pixel su
  mille, e ai bordi, dove passa solo cio' che vola, dai 28 ai 66. Nella scena
  vera le particelle ci sono e si muovono. Una misura intermedia era verde
  per il motivo sbagliato, e va detto: guardare "i bordi" prendeva dentro
  anche i testi dei traguardi, che sono diversi per sentiero; la finestra
  giusta e' la fascia ALTA, dove non arrivano ne' la scheda ne' le parole.
  **Cio' che si e' trovato cercando, e non era nell'ordine**: con Riduci
  Movimento la scena portava il segno subito a fine corsa, quindi la festa
  veniva dipinta nell'istante in cui il volo e' gia' finito, cioe' la coda e
  non la festa. Adesso il pittore riceve `posaDelCampoPieno`, l'istante in cui
  tutte le particelle sono nate e nessuna e' svanita: nessun movimento per chi
  ha chiesto di non averne, ma la materia del proprio Maestro si vede tutta.
  Tre anteprime nuove generate MONTANDO L'APP VERA, `festa-costellazione`,
  `festa-albero` e `festa-loto`, e guardate: la Costellazione riempie lo
  schermo di stelle, il Loto di polline dorato, e in cima si vede il segno
  disegnato del sentiero. Rosso provato sulla guardia dei glifi, rimettendo
  un'icona di sistema.
  **Un'osservazione nata dall'anteprima e non curata qui**, perche' non
  appartiene a nessuna delle sei voci: in fondo alla festa la scheda "Il
  prossimo" mostra il traguardo APPENA raggiunto invece del successivo.
  **Nessun telefono ha acceso questa cura**: la chiude il collaudo sulla 2185)
- **AQ.03** La barra sottile non esiste fino alla home. Stato: CHIUSA. Chiusa il 24 agosto 2026 (BF.03): l'elenco delle scene del rito vive nella casa unica, e il caso limite della tendina e' stato chiuso da BE.02.
  (**LA DICHIARAZIONE C'ERA E NON ARRIVAVA A NESSUNO**, ed e' la scoperta di
  questa voce. L'ordine AP voce 07 aveva gia' messo `RisveglioJourney` fra le
  soglie, eppure Mauro vedeva la barra sull'Animale Guida: il motivo e' che
  chi guarda la pila (`tipoDellaRotta` in `barra_del_cerchio.dart`) visita
  l'albero della rotta in cima e si ferma al primo widget dal nome
  CONOSCIUTO, dove conosciuto voleva dire "presente nella mappa della barra
  STORICA". Nessuna scena del rito lo era, quindi la risposta era NULLA, e
  per il nulla `barraSottileSiVede` risponde vero. La dichiarazione esisteva e
  non veniva nemmeno cercata.
  Adesso i nomi conosciuti sono l'unione dei due elenchi
  (`nomiDiSchermataConosciuti`), e le scene del rito sono enumerate in un
  punto solo, `dove_si_vede_la_barra.dart`: oltre alle quattro di prima ci
  sono il trionfo dell'Animale Guida, quello degli Angeli, il cielo di
  nascita, la panoramica, la risonanza, la custodia del cielo, il Sigillo e il
  Bentornato. Guardia `test/la_barra_sottile_non_esiste_nel_rito_test.dart`
  con quattro prove, che guardano tutti e due i versi (nel rito mai, dalla
  home in poi sempre) e che pretendono anche che il guscio SAPPIA riconoscere
  quei nomi, cioe' la riga che mancava. Rosso provato togliendo una scena
  dall'elenco.
  **Nessun telefono ha acceso questa cura**: la chiude il collaudo sulla 2185)
- **AQ.04** Il Bentornato si riempie. Stato: CHIUSA. Chiusa il 24 agosto 2026 (BF.03): la scena del ritrovamento porta l'emblema ed e' stata vista piena sul telefono del fondatore durante AZ.
  (la scena si apre col LIVELLO VISIVO e non piu' con una riga di testo:
  l'EMBLEMA del proprio segno, 120 punti, preso da `assets/img/zodiac` che il
  Cerchio ha gia', poi il nome, poi le righe di cio' che e' tornato coi numeri
  veri. **Il segno non e' un dato in piu' da custodire**: nasce dal giorno di
  nascita restituito, come nasce ovunque nell'app, e se il giorno non e'
  tornato l'emblema NON compare, perche' l'emblema di qualcun altro sarebbe
  peggio di nessun emblema. Prova nuova in
  `test/l_onboarding_non_si_rifa_test.dart`: col 12 aprile nasce l'Ariete,
  senza giorno il segno resta nullo. Anteprima `ritrovamento.png` rigenerata
  dall'app vera e guardata: emblema, nome, carta natale, tre Sigilli, 340 Eos.
  **Nessun telefono ha acceso questa cura**: la chiude il collaudo sulla 2185)
- **AQ.05** "Non perdere il tuo cielo" diventa leggibile. Stato: CHIUSA. Chiusa il 24 agosto 2026 (BF.03): la riga unica vive in custodia_del_cielo_step.dart e il passo e' stato percorso e rilavorato in AZ sul dispositivo.
  (**il testo si e' TOLTO, non rimpicciolito**, ed e' la parte che conta: il
  corpo resta quello di casa, sedici punti, che e' gia' il minimo del
  progetto e non andava toccato. Prima: scudo, titolo, DUE blocchi di testo
  di seguito (la ragione lunga che nominava il Maestro e "Collegalo a te in
  un tocco"), l'eventuale guaio, l'eventuale "Continua come", tre pulsanti e
  il "Piu' tardi", cioe' nove elementi in colonna. Adesso: scudo, titolo, UNA
  riga sola, i pulsanti, la via alternativa, il "Piu' tardi".
  **Chi e' gia' riconosciuto non la legge affatto**: la riga sparisce invece
  di restare grigia, perche' per lui la strada e' il "Continua come" e le
  parole che non servono vanno tolte di mezzo.
  Anteprima nuova `docs/preview/custodia-del-cielo.png`, montata DALL'APP
  VERA alla larghezza vera di 360 punti e guardata.
  **Nessun telefono ha acceso questa cura**: la chiude il collaudo sulla 2185)
- **AQ.06** Il manifesto, la suite, l'accensione e la build 2185. Stato: CHIUSA
  (suite intera UNA volta: **2974 verdi e 12 rossi**, dei quali i SETTE di
  legge gia' dichiarati in AM.05 (l'attribuzione cieca, albero e loto fuori
  tela, `un_traguardo_acceso_pesa_uguale`, e le guardie degli ordini AC, T e
  U ancora aperti), la guardia di quest'ordine rossa apposta finche' non si
  e' chiusa questa riga, e QUATTRO code vere, tutte curate: le tre anteprime
  nuove delle feste risultavano ORFANE, perche' il corredo ne componeva il
  nome a pezzi e un nome composto non compare nei sorgenti che la guardia
  legge; una frase nuova della custodia aveva la virgola prima della "e",
  contro la regola di casa; e la cattura delle feste costruiva il Diario
  senza dichiarare il suo istante, cioe' pescava il giorno vero e sarebbe
  stata verde o rossa a seconda di quando la si lancia.
  Build `0.1.0+2185`, 161.110.875 byte (153,6 MB) per arm64, integrita'
  dell'archivio verificata famiglia per famiglia, consegnata su Firebase App
  Distribution il 19 agosto 2026, release `0fd0hee8sp4mo`, registro
  `docs/versione_distribuita.json` aggiornato da 2184 a 2185 dentro la
  procedura. **Due tester come chiede l'ordine**: `tool/consegna.py` conosce
  solo `cloud@esotericircle.app`, quindi il secondo passo `:distribute` e'
  stato rifatto a mano con tutti e due gli indirizzi, aggiungendo
  `info@esotericircle.com`, e la release e' stata riletta dal server.
  **L'ACCENSIONE: NON E' STATA FATTA, e non per scelta.** `flutter devices`
  trova Windows, Chrome ed Edge, nessun telefono, e `adb` non e' nel PATH di
  questa macchina: e' l'undicesimo giro senza accensione. Per la regola che
  quest'ordine mette prima di tutte, le cinque voci visive restano FERMATE IN
  ATTESA DI DECISIONE e questo sta scritto IN TESTA al manifesto e in testa al
  rapporto)

## I marcatori, contati sulle righe

VOCI_TOTALI: 6
VOCI_APERTE: 0
VOCI_CHIUSE: 6
VOCI_FERMATE_SU_PREMESSA_FALSA: 0
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0