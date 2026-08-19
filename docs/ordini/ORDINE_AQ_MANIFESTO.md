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

- **AQ.01** Il cosmo torna fluido, e la fluidita' vince. Stato: FERMATA IN ATTESA DI DECISIONE
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
- **AQ.02** Le feste si vedono davvero diverse. Stato: FERMATA IN ATTESA DI DECISIONE
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
- **AQ.03** La barra sottile non esiste fino alla home. Stato: APERTA
  (l'elenco per ENUMERAZIONE delle rotte del rito, in un punto solo; guardia
  che cade se una sola scena del rito la mostra, e che pretende la barra
  presente dalla home in poi)
- **AQ.04** Il Bentornato si riempie. Stato: APERTA
  (emblema del segno dagli asset esistenti, nome, e le righe dei dati veri:
  nessun numero d'esempio, e cio' che non c'e' non compare)
- **AQ.05** "Non perdere il tuo cielo" diventa leggibile. Stato: APERTA
  (una promessa, una riga, i pulsanti; il testo superfluo si toglie invece di
  rimpicciolirlo; misure prima e dopo)
- **AQ.06** Il manifesto, la suite, l'accensione e la build 2185. Stato: APERTA
  (stati veri; suite intera una volta; numero a 2185; **l'accensione non si
  salta**, e se nessun dispositivo e' collegato il rapporto lo dichiara in
  testa e le voci visive restano fermate)

## I marcatori, contati sulle righe

VOCI_TOTALI: 6
VOCI_APERTE: 4
VOCI_CHIUSE: 0
VOCI_FERMATE_SU_PREMESSA_FALSA: 0
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 2
