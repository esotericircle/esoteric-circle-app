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
- **AV.01** La spirale di stelle, e i filmati spariscono. Stato: APERTA
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
- **AV.03** I Maestri tornano grandi. Stato: FERMATA IN ATTESA DI DECISIONE
  (**SUL TELEFONO DEL FONDATORE LE DUE COSE STANNO INSIEME, ed e' cio' che
  l'ordine pretende comunque.** Su 360 per 797: **il busto passa da 188,7 a
  220,0 punti** e **i pixel di testo coperti restano ZERO**. La carta del
  Maestro torna al 34 per cento dello spazio dell'eroe, come l'ordine chiede.
  **M3 VERDE**: le tre prove di navigazione che erano diventate rosse in AU.05,
  `chat_header`, `accents` e `navigation`, sono verdi. Il tocco sul busto
  centrale apre il dominio e i Maestri stanno dentro lo schermo senza scorrere.
  **DA DOVE VIENE LO SPAZIO**: dal blocco del cielo, come l'ordine detta. La
  riga personale sotto la Luna sta su UNA riga sola e si accorcia coi puntini
  invece di andare a capo, e ogni capo che non prende e' una fascia che torna
  al carosello. Lo spazio concesso al busto sale da 188,7 a **209,2 punti**.
  **PERCHE' LA VOCE E' FERMATA, e l'ordine lo prevede.** Su uno schermo medio,
  375 per 667, e su uno basso, 320 per 568, **M1 e M2 non stanno insieme**, e i
  due numeri sono questi: lo spazio concesso al busto e' **88,4 punti sul medio
  e MENO 3,6 sul basso**, cioe' sotto zero, e col busto riportato grande i
  pixel di testo coperti **peggiorano da 9.802 a 24.768 sul basso**. Li' la
  scelta e' fra Maestri piccoli e testo coperto, e nessuna delle due e' la
  cura: **la cura e' comprimere il blocco del cielo, e cambia cio' che si
  legge**. E' una decisione dell'Architetto, e non si prende di nascosto.
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
VOCI_APERTE: 1
VOCI_CHIUSE: 3
VOCI_FERMATE_SU_PREMESSA_FALSA: 0
VOCI_FERMATE_SU_DECISIONE_DEL_FONDATORE: 0
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 1
