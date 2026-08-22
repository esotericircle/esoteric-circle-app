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
- **AV.03** I Maestri tornano grandi. Stato: APERTA
- **AV.04** Le perle grandi non portano a niente. Stato: APERTA

## I marcatori

VOCI_TOTALI: 5
VOCI_APERTE: 3
VOCI_CHIUSE: 2
VOCI_FERMATE_SU_PREMESSA_FALSA: 0
VOCI_FERMATE_SU_DECISIONE_DEL_FONDATORE: 0
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0
