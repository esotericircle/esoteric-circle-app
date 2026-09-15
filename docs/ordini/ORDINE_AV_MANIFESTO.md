# ORDINE AV, il manifesto

**QUATTRO COSE E BASTA.** Cinque voci, dalla AV.00 alla AV.04, sul ramo
`claude/esoteric-circle-master-order-e798aj`.

**Nasce dal collaudo del fondatore sulla 2189.** L'ordine dice una cosa che
vale quanto le quattro voci: *niente altro entra qui, per quanto sensato*.

## Come si legge questo file

Ogni voce porta uno stato fra cinque: CHIUSA, APERTA, FERMATA SU PREMESSA
FALSA, FERMATA IN ATTESA DI DECISIONE, FERMATA SU DECISIONE DEL FONDATORE. In
fondo ci sono i marcatori, che la guardia `test/ordine_av_guard_test.dart`
conta sulle righe.

## Le premesse, verificate prima di toccare

- **`drawAtlas` non compare in nessun punto di `lib/`**, contato per
  enumerazione: zero occorrenze. La premessa dell'ordine e' vera, ed e' la
  prima volta che si usa.
- **I tre WebP ci sono**, `stella_medora`, `stella_caligo`, `stella_aura`.
- **UNA IMPRECISIONE MINIMA, e si dichiara lo stesso**: l'ordine parla di "le
  tre voci in pubspec.yaml". La voce e' UNA sola, `- assets/transizioni/`, che
  dichiara la cartella intera. Si toglie quella.

## Due decisioni del fondatore che ne cambiano altre sue

- **La festa non e' piu' diversa per Maestro.** L'ordine AT aveva dato a
  ciascuno il suo filmato; adesso l'animazione e' UNA sola, disegnata dal
  codice, uguale per tutti e tre.
- **Lo spazio in home si prende dal cielo, mai dai Maestri.** L'ordine AU voce
  05 diceva che le due zone non si devono toccare senza dire da quale prendere,
  e lo spazio e' stato preso dai Maestri: sono i protagonisti dell'app.

## Le voci

- **AV.00** Il manifesto prima di tutto. Stato: CHIUSA
  (questo file, nato prima di ogni altra modifica, con la guardia
  `test/ordine_av_guard_test.dart` che pretende zero voci APERTE alla
  consegna)
- **AV.01** La spirale di stelle, e i filmati spariscono. Stato: CHIUSA
  (**LE CINQUE MISURE, tutte verificate e nessuna creduta.** M1 stelle vive al
  culmine: **2.600**, contro le quattrocento chieste. M2 tempo di disegno al
  culmine: **0,71 millesimi** di mediana su venti passate, contro un tetto di
  otto. M3: **una sola `drawAtlas`**, zero altre chiamate di disegno, zero
  filtri, contati da una tela finta che registra cio' che arriva davvero al
  motore. M4 copertura al culmine: **71,4 per cento**, misurata sui pixel.
  **AGGIORNATO DALL'ORDINE CE VOCE 14, e il debito lo salda l'ordine CF:**
  quel vincolo e' sceso al **59,9 per cento**. Il numero qui sopra resta
  scritto perche' e' la misura di quel giorno e non si riscrive la storia,
  ma **cio' che la guardia pretende oggi e' 59,9**: chi legge questa riga
  cercando la soglia viva la trova li', non qui.
  M5: la scheda si accende a **800 millesimi esatti**.
  **DEMOLITO PER INTERO**: la cartella `assets/transizioni/` con i tre WebP, la
  voce in `pubspec.yaml`, `transizione_di_stelle.dart`, e le tre prove che lo
  sorvegliavano, riscritte sulla spirale. Zero richiami al lettore restano in
  `lib`. **La riga `transition/` resta in `.gitignore`**, come l'ordine chiede.
  `MaestroDellaFesta` e' sopravvissuto a due demolizioni perche' la risposta
  che da' serve ancora, il colore della scena: adesso ha una casa sua.
  **DUE DIFETTI VERI, TROVATI GUARDANDO L'ANTEPRIMA E NON DA UNA MISURA.**
  Il primo: l'istante di partenza usava `Duration.zero` come sentinella, e **il
  primo tick puo' arrivare proprio con zero**; la condizione tornava vera a
  ogni giro, il tempo restava zero e le stelle non nascevano mai. **Lo stesso
  identico difetto stava nel lettore di WebP dell'ordine AT**, riga per riga:
  anche la transizione dei filmati restava ferma al primo fotogramma, e nessuno
  se n'era accorto perche' nessuna prova guardava i pixel. Il secondo: il
  precaricamento delle immagini nelle catture gira dentro `runAsync` e **fa
  scorrere il tempo VERO**, quindi la spirale arrivava a fine corsa prima dello
  scatto: la cattura ora precarica e rimonta la scena, e **pretende di aver
  visto piu' di mille stelle prima di scattare**.
  **E UNA COMBINAZIONE CHE PASSAVA LA MISURA ED ERA SBAGLIATA.** Milleduecento
  stelle con scala 3,2 davano il 74,4 per cento e superavano M4, ma a schermo
  erano **macchie larghe ottanta pixel**, un muro d'oro sopra il traguardo. La
  stessa copertura si ottiene con stelle piccole e molte, 2.600 con scala 1,1,
  che restano scintille: possibile solo perche' con `drawAtlas`
  duemilaseicento costano quanto milleduecento. **L'alone si disegna una volta
  sola nell'immagine sorgente**, non e' un filtro per fotogramma.
  **E SI DIRADA DAVVERO, misurato**: la scena coperta passa da 71,4 per cento
  al culmine a 43,8 a 1200 millesimi, 6,8 a 1600 e **zero** a 1900. Il
  traguardo si libera.
  **La festa e' una sola e uguale per tutti e tre i Maestri**, e questo cambia
  la decisione precedente del fondatore sulla festa diversa per Maestro)
- **AV.02** Lo sfondo che sta fermo e poi scatta. Stato: CHIUSA
  (**LA TABULAZIONE DELL'ARCHITETTO E' ESATTA AL DECIMO**, rifatta prima di
  toccare il codice: 0, 0, 0, 0,9, 3,7, 14,9, 31,9, 50,7, 70,9, 78,2, 79,5. E
  il numero che l'ordine non dava: **il salto peggiore fra un grado e il
  successivo valeva 9,5 punti**, fra i dieci e gli undici gradi, sopra la
  soglia di 8. La prova M1 sulla curva di ieri cade, come l'ordine prevede.
  **L'ERRORE DI METODO E' DICHIARATO DALL'ARCHITETTO E CONFERMATO DALLA
  MISURA**: le accettazioni dell'ordine AU voce 04 erano due punti soli, zero
  al riposo e oltre sessanta a quindici gradi, e **una curva che salta li
  rispetta tutti e due**. Adesso la continuita' si misura grado per grado da
  zero a venticinque, e **quella prova resta nel repository per sempre**.
  **I DUE NUMERI DELL'ORDINE NON STAVANO INSIEME, e si dichiara.** Provata la
  terna esatta che l'ordine indica, zona morta 0,07 e fondo corsa a diciotto
  gradi con esponente 1,1: la continuita' passa, ma **la mano ferma arriva a
  3,63 punti invece che sotto 2, e quindici gradi ne danno 52,3 invece che
  oltre 60**. Non e' un difetto dell'idea: una curva con esponente basso non
  schiaccia piu' la deviazione della mano ferma come faceva la quadratica,
  quindi il tremore esce dalla soglia.
  **CERCATE TUTTE LE TERNE SUL CONTROLLER VERO**, ne restano NOVE che tengono
  insieme le cinque accettazioni. Scelta quella col margine piu' largo fra
  quelle che tengono l'esponente 1,1 dell'ordine: **zona morta 0,085, fondo
  corsa 16 gradi, esponente 1,1**.
  **UN MODELLO DEL PROPRIO CODICE E' UN SECONDO CODICE.** La prima ricerca era
  stata fatta su un modello scritto a parte che riproduceva a mano il riposo,
  il filtro e la curva: dava per buona una terna che sul controller vero
  lasciava quindici gradi a 54,3 punti invece che sopra 60. La seconda ricerca
  ha girato sul `ParallaxController` vero.
  **LE CINQUE ACCETTAZIONI, misurate**: M1 continuita' **salto massimo 6,4
  punti** contro i 9,5 di ieri; M2 sul tavolo 0,000; M3 in mano fermo **0,00 e
  0,00**; M4 quindici gradi **60,3**; M5 ritardo **66 millesimi**. E i tre
  Maestri con la mano ferma si spostano di **0,00 pixel**.
  **La `tanh` e' stata TOLTA e non solo aggirata**: era lei a comprimere tutta
  la corsa in una fascia di sei gradi, e adesso non la usa piu' nessuno.
  Le venti prove del cielo gia' esistenti restano verdi)
- **AV.03** I Maestri tornano grandi. Stato: CHIUSA. Chiusa il 24 agosto 2026 (BF.03): assolta da BD.01 e BD.04, e il vincolo dei zero pixel coperti e' stato sciolto dal fondatore stesso nella coda di BC.01 (i Maestri stanno davanti, una copertura leggera e' accettata); BE.01 ha aggiunto la fluttuazione.
  (**SUL TELEFONO DEL FONDATORE LE DUE COSE STANNO INSIEME, ed e' cio' che
  l'ordine pretende comunque.** Su 360 per 797: **il busto passa da 188,7 a
  220,0 punti**, cioe' torna alla grandezza della 2188, e **i pixel di testo
  coperti restano ZERO**. La carta del Maestro torna al 34 per cento dello
  spazio dell'eroe. **M3 VERDE**: le tre prove di navigazione diventate rosse
  in AU.05, `chat_header`, `accents` e `navigation`, sono verdi; il tocco sul
  busto centrale apre il dominio e i Maestri stanno dentro lo schermo senza
  scorrere.
  **DA DOVE VIENE LO SPAZIO**: dal blocco del cielo, come l'ordine detta. La
  riga personale sotto la Luna sta su UNA riga sola e si accorcia coi puntini
  invece di andare a capo, e lo spazio concesso al busto sale da 188,7 a
  **209,2 punti**.
  **UNA PROVA HA ACCUSATO IL FALSO, e la spiegazione vale piu' della cura.**
  Messa l'ellissi, la prova che misura i PIXEL dichiarava la riga personale
  **coperta al 74 per cento**. Cercato chi la coprisse, widget per widget:
  **nessuno**. La prova ricostruisce ogni testo per confrontarlo con la scena,
  e lo ricostruiva **senza l'overflow**: nella scena il testo era troncato coi
  puntini, nella ricostruzione no, e i pixel divergevano per un motivo che non
  era una copertura. Adesso le si passa anche quello. **E' anche la
  spiegazione del falso positivo che quella prova dichiarava di non sapersi
  spiegare**, quello della chat del Maestro e dell'Oroscopo: sono testi
  troncati.
  **PERCHE' LA VOCE RESTA FERMATA, e l'ordine lo prevede.** Su uno schermo
  medio, 375 per 667, e su uno basso, 320 per 568, **M1 e M2 non stanno
  insieme**: lo spazio concesso al busto e' **88,4 punti sul medio e MENO 3,6
  sul basso**, cioe' sotto zero, e col busto riportato grande i pixel di testo
  coperti sono **9.299 sul medio e 24.768 sul basso**. Li' la scelta e' fra
  Maestri piccoli e testo coperto, e nessuna delle due e' la cura: **la cura e'
  comprimere il blocco del cielo, e cambia cio' che si legge**. E' una
  decisione dell'Architetto, e non si prende di nascosto dentro un'altra voce.
  **La seconda fonte di spazio che l'ordine indica non basta**: la fascia dei
  doni del giorno vale un centinaio di punti, e su uno schermo basso ne
  mancherebbero circa duecento.
  **L'inversione dell'ordine di pila resta vietata**, come l'ordine conferma)
- **AV.04** Le perle grandi non portano a niente. Stato: CHIUSA
  (**IL FONDATORE HA RAGIONE AL NUMERO.** Enumerate tutte e centosessantacinque
  le perle dei tre sentieri, toccate una per una sul proprio ancoraggio:
  **scollegate CINQUE per sentiero, e sono precisamente i cinque grandi**.
  `med_11, med_22, med_33, med_44, med_55` e le due terne corrispondenti. Le
  cinquanta mini funzionavano tutte, su tutti e tre.
  **LA CAUSA**: l'elenco sotto il disegno costruiva `Sentieri.miniDi(...)`,
  cioe' i cinquanta mini. I grandi non avevano una riga, quindi non avevano una
  chiave, quindi `offsetDelTraguardo` non trovava niente e lo scorrimento non
  partiva. **La perla si illuminava lo stesso**, perche' quello lo fa un altro
  campo, ed e' esattamente cio' che il fondatore descrive: si illumina e non
  porta da nessuna parte.
  **LA CURA**: l'elenco porta tutti e cinquantacinque, e i grandi stanno al
  loro posto nel cammino, alle posizioni 11, 22, 33, 44 e 55, non in fondo ne'
  in un elenco a parte. **Adesso le scollegate sono ZERO su tutti e tre.**
  **DUE DIFETTI DELLA PROVA, trovati e corretti prima di fidarsi del numero.**
  Il primo: dopo il primo tocco l'elenco scorre e la tela del disegno esce di
  vista, quindi tutte le misure successive fallivano per un motivo che non
  c'entrava, e la prova dichiarava "la tela non c'e'" su quaranta perle. Il
  secondo, piu' insidioso: il centro della perla si calcolava moltiplicando la
  posizione per la larghezza della tela, mentre **l'arte e' montata con
  `BoxFit.contain` e va riportata con la stessa scala centrata che usa chi
  disegna**. Con quel conto sbagliato si toccava un petalo qualunque e la prova
  accusava cinquanta perle su cinquantacinque, cioe' anche quelle sane. **Un
  numero grosso non e' una prova migliore: era solo piu' sbagliato.**
  Guardia `test/ogni_perla_porta_alla_sua_voce_test.dart`, che tocca tutte e
  165 le perle e cade se una sola smette)

## I marcatori

VOCI_TOTALI: 5
VOCI_APERTE: 0
VOCI_CHIUSE: 5
VOCI_FERMATE_SU_PREMESSA_FALSA: 0
VOCI_FERMATE_SU_DECISIONE_DEL_FONDATORE: 0
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0
## La consegna

**Build `0.1.0+2190`** arm64, **161.176.767 byte**, cioe' **5.267.801 in meno
della 2189**: quasi esattamente il peso dei tre filmati tolti.
`tool/verifica_apk.py` verde su tutte e nove le famiglie grafiche. Consegnata
il 22 agosto 2026, release `6d23qgl7hfgf8`, a `cloud@esotericircle.app` e
`info@esotericircle.com`, inviti accettati 2.

**La prova di accensione e' stata SALTATA e si dichiara**: il fondatore non ha
un telefono collegato al PC e l'ordine chiede comunque la consegna.

## Le prove

**Le prove rosse residue sono SEI, tutte PRECEDENTI a quest'ordine**: le tre
guardie degli ordini AC, T e U, rosse apposta perche' quegli ordini hanno
ancora voci aperte; il disegno di albero e loto che tocca il bordo della tela;
l'attribuzione cieca dei doni; e il peso dell'alone di un traguardo acceso, che
varia di 5,1 volte fra i tre sentieri.

**Tre prove sono state ri-mirate, nessuna allentata.** Quella del corredo, che
pretendeva il precaricamento dentro `capture`: adesso guarda il corpo intero e
in piu' pretende che resti il comportamento predefinito. Quella del manifesto
degli asset, che dichiarava ancora la cartella dei filmati. E quella dei testi
coperti, che accusava il falso sui testi troncati: la spiegazione vale piu'
della cura, perche' era anche il falso positivo che quella prova dichiarava di
non sapersi spiegare.
