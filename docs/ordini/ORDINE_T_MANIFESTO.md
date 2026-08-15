# ORDINE T. I TRE SENTIERI PRENDONO L'ARTE

Due voci. Nessuna consegna in fondo: la build si fa alla fine della serie di
quattro ordini, e questa e' una deroga dichiarata alla regola della consegna,
non una dimenticanza.

## Come si legge questo file

Una riga per voce, con lo stato in fondo. Gli stati terminali ammessi sono
quattro e sono quelli di sempre:

- **CHIUSA**, il lavoro e' finito e provato;
- **FERMATA SU PREMESSA FALSA**, la voce chiedeva di correggere qualcosa che
  misurato non risulta;
- **FERMATA IN ATTESA DI DECISIONE**, il lavoro di Code e' finito e resta solo
  una scelta di Mauro;
- **APERTA**, e finche' una riga e' aperta la guardia
  `test/ordine_t_guard_test.dart` resta rossa.

I marcatori in fondo si contano sulle righe, non si scrivono a memoria: la
guardia cade se dicono un numero diverso da quello che le righe portano.

## Le premesse, abbattute prima di toccare il codice

Tutte e cinque reggono, e due vanno riportate con la misura perche' l'ordine
lo chiede.

1. **VERA.** `GeometriaDelSentiero` porta cinque gruppi da undici punti con un
   grande per gruppo su tutti e tre i sentieri, e ogni punto ha gia' la
   coordinata relativa e il gruppo.
2. **VERA.** I tre pittori vivono in `lib/features/sigilli/disegno_del_sentiero.dart`
   e il fondo lo dipingono dentro `paint`.
3. **VERA, e le misure sono queste**: `albero.png` 941 per 1672, `costellazione.png`
   940 per 1672, `loto.png` 941 per 1672, tutte e tre RGBA a 8 bit con canale
   alfa vero (l'albero ha il 48,5 per cento di pixel completamente trasparenti,
   la costellazione il 69,2, il loto il 31,5). Le proporzioni sono 0,5628,
   0,5622 e 0,5628 contro lo 0,5625 di 1080 per 1920: **coincidono**, e la
   costellazione e' larga un pixel in meno delle altre due.
4. **VERA nel merito, falsa alla lettera, e l'ordine lo prevedeva.** In
   `pubspec.yaml` non era registrata `brand_assets/` intera ma solo
   `brand_assets/santuario/` e `brand_assets/intro/`: la sottocartella nuova
   **non era coperta**, ed e' stata aggiunta come l'ordine dice.
5. **VERA.** Nel repository non esiste nessun lettore che ricavi coordinate da
   pixel. I tre punti che toccano `toByteData` (`circle_seal_screen.dart`,
   `sky_postcard.dart`, `sinastria_share_card.dart`) ESPORTANO un'immagine, non
   la leggono. Fra gli strumenti Python, `normalizza_avatar.py` ritaglia al
   contenuto, che e' un riquadro solo e non un riconoscimento di elementi.

## Le voci

- **T.01** I cinquantacinque ancoraggi si ricavano dall'arte — FERMATA IN ATTESA DI DECISIONE
  - **LO STATO IN UNA RIGA: la macchina e' finita e provata, l'Albero e' letto e
    guardato, e mancano due immagini che deve fare Mauro.** La voce non e' chiusa
    perche' due sentieri su tre non hanno ancora i loro ancoraggi, e non e'
    aperta perche' non resta lavoro di Code: resta una decisione e due file.
  - **LA MACCHINA E' FATTA E VALE PER TUTTI E TRE.** `lib/core/sigilli/lettura_degli_ancoraggi.dart`
    riconosce le macchie, decide chi e' grande, assegna i gruppi, ordina e
    convalida; `lib/core/sigilli/regole_delle_tre_arti.dart` porta la regola di
    ciascuna arte; `tool/ancoraggi_dai_sentieri.dart` scrive il dato in
    `lib/core/sigilli/ancoraggi_dei_sentieri.dart` e disegna l'immagine di
    verifica. **Il lavoro non si rifa' a ogni apertura della schermata**, perche'
    riconoscere le macchie su un milione e mezzo di pixel costa troppo: si fa
    una volta, e una prova lo rifa' e confronta.
  - **L'ORDINE DEI PUNTI SI RICAVA, e Mauro non numera niente.** I cinque gruppi
    dal basso verso l'alto, perche' il cammino sale; dentro un gruppo i dieci
    piccoli in senso orario attorno al grande, partendo dal piu' in alto. Una
    regola sola per tutti e tre.
  - **DUE SOGLIE, e nessuna delle due deriva dalla grandezza che giudica.** Un
    elemento e' largo almeno **20 pixel** sull'arte a 941, che e' la misura sotto
    la quale si sta guardando un riflesso e non una sfera (la sfera piccola vera
    ne misura una trentina, la grande una sessantina). Un elemento e' GRANDE se
    il suo diametro e' almeno **una volta e mezzo il diametro mediano**: e' un
    rapporto, quindi vale anche se l'arte cambia risoluzione.
  - **L'ALBERO: la strada automatica funziona, e il segno e' l'assenza di
    colore.** Misurato prima di scrivere la regola: una sfera vale rgb 195/175/173
    oppure 163/149/137, cioe' rosso e blu quasi uguali; l'oro che la circonda vale
    130/62/15, con centoquindici punti fra rosso e blu. Con la regola "croma sotto
    il trenta per cento del canale piu' alto, luminanza sopra 45, opaco" le macchie
    trovate sono **esattamente cinquantacinque**: cinque grandi da 2.558 a 3.483
    pixel di area e cinquanta piccole da 539 a 661, con un solo intruso da 105
    pixel nelle radici che il diametro minimo esclude. **La separazione fra grandi
    e piccoli e' un baratro**, 661 contro 2.558, non una soglia scelta con cura.
  - **L'IMMAGINE DI VERIFICA C'E' E E' STATA GUARDATA:** `docs/preview/ancoraggi_albero.png`,
    l'arte coi cinquantacinque punti cerchiati, numerati da 1 a 55 e colorati per
    gruppo. I cerchi cadono sulle sfere, i cinque gruppi salgono dal basso, il 55
    e' la corona. **Il primo tentativo mostrava rettangoli al posto dei numeri**,
    perche' in `flutter test` il font predefinito disegna scatole: senza il
    caricamento esplicito di Cinzel l'unica cosa che serviva a Mauro non c'era.
  - **COSTELLAZIONE E LOTO: la strada automatica NON arriva, ed e' misurato e non
    stimato.** Sulla costellazione ho provato cinque strade: la maschera del blu
    (24.442 pixel, 717 componenti, 40 tonde), il blu con chiusura ed erosione (23
    macchie), la densita' del blu in una finestra (35 candidati al meglio), la
    trasformata di distanza sui pixel scuri (47 picchi coi raggi da 10 a 13,3
    pixel, senza nessun salto), e il rivelatore di **disco scuro dentro un anello
    d'oro**, che e' la struttura vera di quelle stelle. Nessuna produce un salto
    fra il cinquantacinquesimo candidato e il cinquantaseiesimo: i punteggi
    scendono lisci da 85 a 55. **Ho disegnato i primi cinquantacinque sull'arte e
    li ho guardati: prendono le perline d'oro sulle linee e la filigrana, e
    saltano la maggior parte delle stelle vere.** La ragione e' nell'arte e non nel
    metodo: gli orbi di lapis sono spezzati dai riflessi dorati, e le mezzelune e
    le fasce curve portano lo stesso smalto blu degli orbi.
  - Sul loto il problema e' diverso e piu' duro: i cinquanta petali **si toccano
    fra loro** e nell'arte ci sono foglie decorative dello stesso verde e della
    stessa forma dei petali. Separare due petali attaccati non e' un problema di
    soglia. I cinque cuori d'oro invece si vedono bene, ma cinque su
    cinquantacinque non e' una strada.
  - **QUINDI SI CHIEDE LA STRADA B, e si chiede per due sentieri su tre.** Serve
    un secondo PNG per la costellazione e uno per il loto, alla stessa misura
    dell'arte, con cinquantacinque pallini pieni su fondo trasparente: cinque
    colori, undici pallini per colore, e il grande con diametro almeno doppio.
    **Il lettore di quei file e' gia' scritto e gia' provato** su tavole
    fabbricate dal codice: appena i due PNG arrivano si scrive una riga in
    `RegoleDelleTreArti.per` e non cambia altro.
  - **QUATTRO PROVE DEL ROSSO, tutte con l'iniezione VERIFICATA prima di leggere
    l'esito**, e la verifica ha morso davvero: la prima stesura della prova sulla
    sovrapposizione puntava a due indici sbagliati e i due punti distavano 533
    pixel invece di meno di venti, quindi la prova sarebbe passata su un difetto
    mai iniettato. Le quattro: un gruppo con nove piccoli (iniezione entrata, 50
    elementi invece di 55), due grandi per gruppo (entrata, 10 grandi invece di
    5), due punti a 7,5 pixel di distanza (entrata, sotto il minimo di 20), un
    punto a x uguale a 1,4 cioe' fuori dalla tela (entrata). Tutte e quattro
    cadono col messaggio che dice QUALE gruppo e QUANTI punti ha.
- **T.02** Le tre immagini prendono il posto del painter, e si accende la forma — APERTA
  - **LE CINQUE PREMESSE DELLA RISCRITTURA REGGONO, misurate da me.** I cinque
    file ci sono: `albero.png` 941 per 1672, `costellazione.png` e
    `costellazione_pallini.png` 1023 per 1537, `loto.png` e `loto_pallini.png`
    941 per 1672, tutti RGBA a 8 bit. Le proporzioni sono 0,6656 per la
    costellazione e 0,5628 per gli altri due: diverse, e di proposito. Arte e
    pallini coincidono di misura in tutte e due le coppie. Ogni file di pallini
    porta **55 dischi in cinque colori, undici per colore, e in ogni colore uno
    solo da 41 pixel di diametro contro 17**: piu' del doppio. La lettura
    automatica dell'Albero e' ancora valida, la prova gira verde.
  - **FATTO E GUARDATO: tutti e tre i sentieri leggono i loro ancoraggi.** La
    sorgente e' un dato per sentiero in `RegoleDelleTreArti.sorgenteDi`: Albero
    dall'arte, Costellazione e Loto dai pallini. Sui pallini **il gruppo viene dal
    COLORE e non dalla vicinanza**, ed e' un dato migliore: su un loto due petali
    di fiori diversi possono essere piu' vicini fra loro che al proprio cuore.
    Lo strumento si rifiuta di lavorare se pallini e arte hanno misure diverse.
    Le tre immagini di verifica stanno in `docs/preview/` e le ho guardate:
    cinquantacinque punti ciascuna, cinque gruppi, ordine dal basso in alto e in
    senso orario. La guardia adesso rilegge **tutti e tre** e confronta 165
    ancoraggi: prima guardava il solo Albero, ed era vero allora.
  - **MISURATO, E CONTRADDICE LA VOCE: il contorno NON e' lo stesso muro nelle tre
    immagini.** La voce dice che si cresce la regione dal seme e ci si ferma sul
    bordo dorato inciso, uguale per tutte e tre. Provato: con la regola "opaco e
    non oro luminoso" la crescita sul Loto **scappa dal petalo** e arriva al tetto
    su tutti e cinquantacinque, e sull'Albero fa lo stesso perche' fra i rami il
    fondo scuro e' libero quanto la sfera. Il muro unico non c'e'.
  - **LA REGOLA CHE INVECE FUNZIONA e' un'altra: si cresce sulla MATERIA
    dell'elemento**, cioe' sul colore mediano attorno al seme, e il bordo dorato
    diventa un muro perche' e' di un'altra materia. Con questa, tetto all'uno per
    cento della tela e pavimento all'area del bagliore tondo: **Loto 36 forme e
    19 ripieghi, mediana 2.257 pixel; Costellazione 52 forme e 3 ripieghi,
    mediana 432; Albero 5 forme e 50 ripieghi.** L'Albero ripiega quasi sempre, e
    non e' un difetto da nascondere ne' una scelta da vantare: la sfera E' tonda,
    quindi il bagliore tondo li' e' gia' la forma giusta, ma il numero resta 50 su
    55 e va scritto cosi'.
  - **E I SEMI DEL LOTO NON STANNO AL CENTRO DEI PETALI.** Guardato a piena
    risoluzione coi semi disegnati sopra: alcuni cadono sulla filigrana d'oro fra
    un petalo e l'altro, non dentro la materia verde. E' la ragione dei diciannove
    ripieghi, e si corregge nel file dei pallini, non nel codice.
  - **NON FATTO:** la forma accesa disegnata davvero, il fondo come strato, il
    montaggio dell'immagine con la tela che prende la proporzione della sua arte,
    la riga del conteggio dentro l'immagine, le sei anteprime, e le tre serie di
    misure (spazio, scontorno, compimento). La macchina della forma e' misurata ma
    non scritta in Dart ne' disegnata.

## Marcatori

VOCI_TOTALI: 2
VOCI_CHIUSE: 0
VOCI_APERTE: 1
VOCI_FERMATE_SU_PREMESSA_FALSA: 0
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 1
