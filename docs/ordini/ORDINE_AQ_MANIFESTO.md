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

- **AQ.01** Il cosmo torna fluido, e la fluidita' vince. Stato: APERTA
  (misurare prima, sulla testa di oggi e su quella della 2181; verificare P3;
  la resa di AM.02 non si tocca; se blocco e fluidita' sono in conflitto
  vince la fluidita')
- **AQ.02** Le feste si vedono davvero diverse. Stato: APERTA
  (via i glifi di sistema, il segno di ogni Maestro disegnato da noi; misurare
  le particelle nella scena vera e curarle; tre anteprime dall'app vera)
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
VOCI_APERTE: 6
VOCI_CHIUSE: 0
VOCI_FERMATE_SU_PREMESSA_FALSA: 0
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0
