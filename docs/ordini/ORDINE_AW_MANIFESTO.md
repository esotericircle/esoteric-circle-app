# ORDINE AW, il manifesto

**IL CIELO FLUIDO, E BASTA.** Due voci, AW.00 e AW.01, sul ramo
`claude/esoteric-circle-master-order-e798aj`.

**Una voce sola di lavoro.** L'ordine dice una cosa che vale quanto la voce:
*non toccare nient'altro, per nessun motivo*.

## Come si legge questo file

Ogni voce porta uno stato fra cinque: CHIUSA, APERTA, FERMATA SU PREMESSA
FALSA, FERMATA IN ATTESA DI DECISIONE, FERMATA SU DECISIONE DEL FONDATORE. In
fondo ci sono i marcatori, che la guardia `test/ordine_aw_guard_test.dart`
conta sulle righe.

## I cinque fatti, verificati prima di toccare

- **F1 CONFERMATO.** `parallax_controller.dart` chiede i campioni ogni **66
  millesimi**, cioe' circa quindici al secondo.
- **F2 CONFERMATO nella sostanza.** **Zero `Ticker` in tutto il file**,
  contati. Il cielo cambia solo quando arriva un campione del sensore o uno
  scorrimento. **Una imprecisione di riferimento e si dichiara**: le chiamate a
  `notifyListeners` sono TRE e non due, alle righe 130, 156 e 395, cioe'
  `updateScroll`, la porta delle prove e `_onAccel`. Il fatto non cambia.
- **F3 CONFERMATO.** `fondoCorsa = sin(16 gradi)`.
- **F4 CONFERMATO, ed e' il piu' importante.** La riga diagnostica mostra
  `parallasse.tiltX`, che e' **la risposta dopo la curva** e non la deviazione:
  per questo saturava a 1,00 e per questo la diagnosi e' stata sbagliata tre
  volte.
- **F5 CONFERMATO.** `layerOffset` somma `- _scroll * 40 * depth` sull'asse Y,
  e la riga mostrava quel numero insieme a quello del sensore senza dirlo.

## Le voci

- **AW.00** Il manifesto prima di tutto. Stato: CHIUSA
  (questo file, nato prima di ogni altra modifica, con la guardia
  `test/ordine_aw_guard_test.dart` che pretende zero voci APERTE alla
  consegna, e i cinque fatti verificati sul ramo prima di toccare il codice)
- **AW.01** Il cielo si muove a ogni fotogramma. Stato: CHIUSA
  (**M1, LA MISURA CHE MANCAVA, ED E' STATA FATTA PRIMA E DOPO CON LA STESSA
  FORMULA.** Prima: **cambia il 12,5 per cento dei fotogrammi** e il salto
  peggiore vale **2,11 punti**. Dopo: **99,4 per cento e 0,21 punti**. Le due
  tabelle vivono nello stesso file e nello stesso metro, grazie a un
  interruttore che rimette il comportamento vecchio: **un confronto scritto in
  due rapporti di giorni diversi non e' un confronto**.
  **E LA PROVA DISTINGUE LE DUE CURE.** Col sensore lasciato rado a 66
  millesimi, come prima dell'ordine, il cielo resta fluido lo stesso: **100 per
  cento dei fotogrammi, salto 0,34**. Se a interpolare fosse il campione e non
  il fotogramma, quel numero crollerebbe.
  **I QUATTRO PEZZI.** Uno: il sensore sposta un BERSAGLIO e a dipingere e' un
  `Ticker` alla frequenza dello schermo, con il passo calcolato sul **dt vero**
  del fotogramma, cosi' a 120 al secondo non si muove il doppio che a 60;
  costante di tempo 90 millesimi; **il ticker si ferma quando e' arrivato**.
  Due: campioni da 66 a **16 millesimi**, e il periodo nominale sta in un posto
  solo, perche' se lo stream chiedesse sedici e il filtro credesse sessantasei
  **il taglio sbaglierebbe di quattro volte**. Tre: fondo corsa da sedici a
  **trenta gradi**. Quattro: la riga diagnostica.
  **LE ALTRE MISURE**: M2 continuita' da 0 a 35 gradi, **salto massimo 2,8
  punti** sugli 80 (0, 0, 11,1, 24,8, 38,9, 53,0, 66,9, 79,5 a 0-5-10-15-20-25-
  30-35 gradi); M3 sul tavolo **0,000**; M4 in mano fermo **0,00**; M5 quindici
  gradi **27,0 punti**, dentro la fascia 25-40 in cui **si puo' dosare**; M6
  meta' corsa dopo **80 millesimi**; M7 il cielo si ridipinge 855 volte in
  dieci secondi di movimento, e finito il gesto **45 volte per arrivare a
  destinazione e poi ZERO**.
  **M5 SOSTITUISCE LA MISURA VECCHIA, e la sostituzione spiega il difetto.**
  Fino a ieri si pretendeva **oltre sessanta punti a quindici gradi** col fondo
  corsa a sedici: un movimento normale del polso arrivava al massimo e da li'
  non restava niente da dosare. E' l'"incontrollabile" del fondatore, ed era
  scritto nella sua riga diagnostica senza che nessuno potesse leggerlo.
  **LA RIGA DIAGNOSTICA DICEVA DUE BUGIE, e adesso ha quattro righe con quattro
  nomi.** Chiamava "inclinazione dal riposo" un numero che era **la risposta
  dopo la curva**, saturo a 1,00 molto prima del fondo corsa della mano: per
  questo la diagnosi e' stata sbagliata tre volte. E sommava i punti del
  sensore con quelli dello SCORRIMENTO senza dirlo: con inclinazione dichiarata
  0,00 il piano verticale correva meno tredici punti, e quei punti erano il
  dito. Adesso si leggono, separati: i gradi della mano, la risposta da 0 a 1,
  i punti della mano e quelli del dito, e **i fotogrammi al secondo a cui il
  cielo si ridipinge**, che e' il numero che avrebbe fatto trovare questo
  difetto due giorni fa.
  **QUATTRO PROVE DEL CIELO SONO STATE RI-MIRATE, nessuna allentata**: leggevano
  il tilt subito dopo un campione, e col cielo fluido quello e' il valore prima
  che il fotogramma lo muova. Adesso fanno passare i fotogrammi. Quarantaquattro
  prove del cielo restano verdi.
  **M1 SU DISPOSITIVO NON E' MISURATA e si dichiara**: quella qui sopra e' la
  misura del VALORE DIPINTO fotogramma per fotogramma, che e' la causa; **il
  fondatore deve guardare se lo scatto e' sparito** inclinando piano il
  telefono in home, e leggere nella messa a punto la riga dei fotogrammi al
  secondo, che deve dire molto piu' di quindici mentre muove)

## I marcatori

VOCI_TOTALI: 2
VOCI_APERTE: 0
VOCI_CHIUSE: 2
VOCI_FERMATE_SU_PREMESSA_FALSA: 0
VOCI_FERMATE_SU_DECISIONE_DEL_FONDATORE: 0
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0
