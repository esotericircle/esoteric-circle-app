# Manifesto dell'ORDINE P

Creato come primissima azione dell'ordine, prima di qualunque modifica al
codice, come la legge di consegna prescrive. Ogni voce si chiude da sola con la
sua misura: le voci non si rinumerano, non si accorpano e non si dichiarano
coperte da un'altra.

Stati ammessi: **APERTA**, **CHIUSA**, **FERMATA SU PREMESSA FALSA**,
**FERMATA IN ATTESA DI DECISIONE**.

Il quarto stato e' a ZERO da quando Mauro ha scelto la proposta A per la voce
25, il 12 agosto 2026. Resta dichiarato fra gli stati ammessi perche' e' una
categoria vera e servira' di nuovo, non perche' ci sia una voce dentro.

Il quarto stato nasce con la quarta sessione e non e' un modo elegante di
dire aperta: il lavoro della voce e' finito e consegnato, e cio' che resta
non e' lavoro ma una scelta che non spetta a chi costruisce. La voce 25 ne e'
il caso: due composizioni alternative, montate entrambe e guardate entrambe,
e la scelta di Mauro. Una voce cosi' non si puo' chiudere da soli, e lasciarla
aperta direbbe il falso, perche' non c'e' niente da fare.

La guardia `test/ordine_p_guard_test.dart` legge questo file e resta rossa
finche' la somma dei tre stati terminali non raggiunge VOCI_TOTALI.

---

## Sezione Zero. Si esegue per prima, prima di ogni altra voce

Otto voci aggiunte dalla Sezione Zero, che ha priorita' su tutto, comprese
P.01, P.02 e P.03. Il manifesto nasceva con 32 righe perche' e' stato creato
prima che la Sezione Zero esistesse: VOCI_TOTALI passa da 32 a 40.

- **P.33** I tre sentieri si disegnano davvero — CHIUSA
  - Causa: `sentiero_screen.dart` montava un `ListView.builder` di `ListTile`
    con le icone di serie del framework, nessun `CustomPainter`, e i tre
    sentieri differivano per la sola palette sopra lo stesso
    `CosmosBackground(seed: 19)`. La sezione 13 del Briefing non era costruita.
  - File: `lib/features/sigilli/disegno_del_sentiero.dart` (nuovo, geometria e
    tre pittori), `lib/features/sigilli/sentiero_screen.dart`.
  - Misura: `test/i_tre_sentieri_si_disegnano_test.dart`, otto prove. Rosso
    eseguito spegnendo i tre pittori: 0 pixel su 176.400.
- **P.34** La celebrazione parte sempre e non dipende dal server — CHIUSA
  - Causa vera: l'accredito stava PRIMA della festa e senza protezione, e la
    porta del Cerchio RILANCIA su `unauthenticated`, `permission-denied`,
    `invalid-argument` e `failed-precondition`. Ipotesi 1 confermata, ipotesi 2
    caduta: nessuno chiamava `guardaCosaSiAccende` all'avvio.
  - File: `lib/features/sigilli/regia_del_cammino.dart`,
    `lib/core/sigilli/coda_delle_feste.dart` (nuovo), `celebrazione.dart`,
    `lib/app.dart`.
  - Misura: `test/la_festa_arriva_sempre_test.dart`, quattro prove. Rosso
    eseguito rimettendo l'ordine vecchio: cadono tutte e tre.
- **P.35** La stesa dei tarocchi entra nel cammino, e con lei tutte le arti — CHIUSA
  - File: `lib/core/sigilli/gesti_delle_arti.dart` (nuovo),
    `lib/core/sigilli/ora_rituale.dart` (nuovo), stesa, tramonto, oracolo,
    sogno, oroscopo, sinastria, archetipo, viso, sigillo, angeli, animale
    guida, Cosmic Passport, `diario_del_cammino.dart`, `regia_del_cammino.dart`.
  - Misura: `test/ogni_arte_entra_nel_cammino_test.dart`. Rosso eseguito
    staccando le rune: accusa `rune_draw_screen.dart` per nome.
- **P.36** La discesa al punto raggiunto: il conto e' rovesciato — CHIUSA
  - File: `lib/features/sigilli/sentiero_screen.dart`. L'altezza non si assume
    piu': si misura col viewport.
  - Misura: `test/la_discesa_arriva_al_punto_test.dart`, cinque prove. Rosso
    eseguito con la formula vecchia: il traguardo finiva a 4.539 con il
    viewport da 56 a 797.
- **P.37** I traguardi non raggiunti sono illeggibili — CHIUSA
  - Misura: `test/il_sentiero_si_legge_test.dart`. Rosso eseguito: alfa
    effettivo 0,273 e contrasto 1,76 a 1 nel caso peggiore, contro i 4,85 a 1
    di adesso.
- **P.38** "I tuoi Stella. I tuoi Frutto. I tuoi Petalo." — CHIUSA
  - File: `lib/core/sigilli/traguardo.dart` (`NomeDelTraguardo`),
    `cosmic_passport_screen.dart`, `card_del_traguardo.dart`.
  - Misura: `test/il_nome_dichiara_la_sua_forma_test.dart`. Rosso eseguito.
- **P.39** Il sottotitolo tagliato a meta' frase — CHIUSA
  - Misura: `test/il_sentiero_si_legge_test.dart`, tutti e 165 montati alla
    larghezza reale. Rosso eseguito rimettendo `maxLines: 2`.
- **P.40** La card del cielo di nascita coperta dalla barra — FERMATA SU PREMESSA FALSA
  - La trasparenza della barra e' una decisione di Mauro, ordine 2164 voce 1,
    scritta nel codice con l'avviso di non ribaltarla; che il contenuto scorra
    sotto la barra e' la decisione del 7 agosto 2026. Misurato: a fine corsa
    nessun contenuto resta sotto la barra e la card si porta tutta allo
    scoperto. Presidio lasciato in `test/il_passaporto_non_si_copre_test.dart`.

## Sezione A. I presidi

- **P.01** Il cielo di sfondo torna a scorrere — CHIUSA
  - PREMESSA 1 CADUTA e dichiarata: il cielo si muove gia', la regressione era
    dell'ordine M, causa `8326b55` dell'8 agosto 2026 ("Il cielo si dipinge una
    volta: i piani statici vivono in immagini"), fatta per una ragione giusta,
    il costo di ridisegno su iOS. Questa voce blinda, non ripara.
  - L'elenco vive in un punto solo, `lib/design_system/components/dove_si_muove_il_cielo.dart`,
    e adesso dichiara anche CHI porta il cielo a ciascuna schermata.
  - Difetto vero trovato e chiuso: `SkyOverviewScreen` dichiarava il fondo in
    movimento e non ne aveva nessuno, essendo una rotta spinta fuori dal
    guscio. Adesso monta `CosmosBackground(seed: 11)`.
- **P.02** Tre lucchetti sul cielo, diversi fra loro — CHIUSA
  - Lucchetto 1, il dato; lucchetto 2, il pixel; lucchetto 3,
    l'enumerazione; piu' il quarto su Riduci Movimento. Il secondo cadeva su
    una MissingPluginException dei sensori, cioe' non misurava: adesso i
    canali si silenziano. Il terzo misurava il TESTO del sorgente e accusava
    quattro schermate sane: cambiata la grandezza misurata, non la soglia.
  - Rosso eseguito per tutti e tre: spenta la deriva cadono il primo e il
    terzo; con l'animazione ferma il secondo misura 0 pixel su tre secondi.
- **P.03** Non si spedisce su rosso, e questa volta e' un blocco — CHIUSA
  - Causa: in `codemagic.yaml` il passo delle prove portava
    `ignore_failure: true`, cioe' il permesso scritto di spedire su rosso.
  - File: `tool/sbarramento.sh` (nuovo), `codemagic.yaml`.
  - Scavalco unico e dichiarato: **SPEDISCO_SU_ROSSO**, che stampa il proprio
    nome nel registro insieme ai test caduti.
  - Rosso eseguito: rotto un test di proposito, lo sbarramento esce con
    codice 1 e nomina il file caduto, quindi l'archivio non si produce.

## Sezione B. Stesa di tarocchi

- **P.04** La carta estratta non cambia mai piu' — CHIUSA
  - Causa vera: la stesa non era un dato ma una FUNZIONE del mazzo
    (`TarotSpread.dalMazzo`, sempre le prime tre dell'ordine corrente), quindi
    mischiando cambiavano le carte gia' scelte. Causa (a) dell'ordine, nella
    forma piu' radicale: le carte uscite non erano mai state salvate.
  - File: `lib/core/tarot/stesa_in_corso.dart` (nuovo, la legge del dominio),
    `lib/core/tarot/tarot_spread.dart`, `lib/features/tarot/stesa_tre_carte_screen.dart`.
  - Misura: sei prove in `test/la_carta_estratta_non_cambia_test.dart`, fra cui
    le tre chieste dall'ordine; rosso eseguito rimettendo la stesa ricalcolata
    dal mazzo, output nel rapporto.
- **P.05** L'animazione del taglio si capisce — CHIUSA
  - Quattro fasi con durata dichiarata in un punto solo, `TaglioFasi`, e il
    totale non e' scritto: e' la somma. Soglia = il mescolamento gia'
    approvato. La meta' di sotto passa SOPRA (`TaglioPose.quotaDi`). Le carte
    gia' estratte sono immobili: l'ambiente si FERMA dove sta invece di
    azzerarsi, perche' azzerarlo faceva scattare la carta di 2,2 punti. Con
    Riduci Movimento le quattro fasi sono quattro stati in dissolvenza, prima
    erano zero.
  - Misura: `test/la_stesa_si_capisce_test.dart`. Rosso eseguito: 0 fasi su
    quattro, e quota 0,0 contro 0,0 sulla meta' di sotto.
  - **DIFETTO TROVATO GUARDANDO L'ANTEPRIMA, alla quarta sessione, e chiuso.**
    Le quattro fasi non erano mai state guardate: prodotte le immagini, la
    seconda e la terza mostravano un mazzetto unico che si spostava, senza
    nessuna divisione. La causa erano DUE UNITA' DI MISURA per un solo numero.
    Il punto di taglio viveva fra 2 e 7, contato su `TarotSpread.fanSize`, cioe'
    su quante carte si pescano; il ventaglio lo confronta con gli indici delle
    settantotto, e la finestra montata a schermo ne mostra quindici attorno alla
    meta'. Il punto cadeva sempre fuori: tutte le carte a video stavano dalla
    stessa parte del taglio. Dall'altro lato la stessa confusione si vedeva in
    una moltiplicazione, `punto = indice * 78 / 9`, che riportava il numero
    nell'unita' giusta per il dato e non per il disegno: a schermo si divideva in
    un punto e nel mazzo se ne tagliava un altro.
  - Rimedio: il numero e' un indice di carta e basta, dichiarato tale, vicino
    alla meta' del mazzo come un taglio vero; la moltiplicazione non c'e' piu';
    e all'inizio del gesto l'arco torna a guardare dove si taglia, cosi' chi ha
    sfogliato fino al fondo vede la divisione comunque.
  - Misura nuova: `le due meta' si dividono DAVANTI A CHI GUARDA`, che chiede
    tre cose insieme: che il punto sia un indice di carta (nel terzo centrale
    del mazzo), che le carte montate stiano da tutte e due le parti, e che fra le
    due meta' si apra un vuoto piu' largo del doppio del passo fra due dorsi.
    Rosso eseguito rimettendo la vecchia formula: punto di taglio 3, a 36 carte
    dalla meta' contro una soglia di 13.
  - Anteprime rigenerate e GUARDATE: `docs/preview/stesa-taglio-1-raccolta.png`,
    `-2-divisione.png`, `-3-ricomposizione.png`, `-4-ristesa.png`.
- **P.06** Medora ci pensa, prima di rispondere — CHIUSA
  - `lib/features/tarot/attesa_di_medora.dart` (nuovo): cerchio di dodici
    stelle che gira, ritratto di Medora dalla porta unica del busto, cinque
    righe nella sua voce. I tempi vengono da `TempiDellAttesa` e non sono
    riscritti.
  - Rosso eseguito: `stesa_attesa` trovata 0 volte, il responso appariva di
    colpo.
  - Anteprima prodotta e GUARDATA alla quarta sessione,
    `docs/preview/stesa-attesa-di-medora.png`: il cerchio di dodici stelle
    attorno al ritratto e la riga "Medora cerca il filo che lega le tre carte."
    Prima non esisteva nessuna immagine di questa voce.
- **P.07** La bolla chiave e' la bolla della carta — CHIUSA
  - `BollaDellaPosizione` con lo stato di chiave: primario piu' intenso, bordo
    a 2 punti, alone e marcatura che dice perche'.
  - Misura DIFFERENZIALE A PIXEL con soglia dichiarata nel codice,
    `scartoMinimoAPixel = 18`. Rosso eseguito: scarto 0,1 livelli contro 18,
    mentre fra le due bolle normali vale 1,1.
- **P.08** Due bolle spariscono — CHIUSA
  - Tolte la bolla della carta chiave e quella del dialogo, widget, testi e
    GENERAZIONE: `Dialogo`, la sua enumerazione di nove regole e la funzione
    che le applicava non esistono piu' in `tarot_reading.dart`, e la riga e'
    uscita anche dalla card da condividere.
  - Rosso: al commit precedente i tre nomi vivono in `tarot_reading.dart`.
- **P.09** Il consiglio di Medora e' la prima cosa, ed e' la piu' lunga — CHIUSA
  - Prima bolla del responso, tetto distinto e piu' alto in
    `lib/core/tarot/tetti_della_stesa.dart`, nomina TUTTE E TRE le carte
    (verificato su 60 semi per 16 argomenti), e la domanda e' l'ultimo
    paragrafo dopo una riga di stacco invece di una bolla sua.
  - RETENTION: la domanda si salva in `FiloDelGiorno` e torna nel dono del
    mattino dopo.
- **P.10** Il testo sotto la carta smette di andare a capo ogni due parole — CHIUSA
  - Il blocco esce dalla colonna della miniatura e va in un `Wrap` a piena
    larghezza. Rosso: "Cinque di Spade" su 2 righe in 156 punti su 328.
  - Difetto trovato di rimbalzo e chiuso: con `revealAll` nessuna carta usciva
    mai rovesciata, perche' la stesa non veniva assegnata davvero.

## Sezione C. Rito dell'Alba

- **P.11** Misurare prima di correggere — CHIUSA
  - `docs/tipografia/alba_contrasto.md`, scritto dalla misura e non a mano:
    nove testi, file e riga, ruolo, misura, inchiostro, FONDO CAMPIONATO dal
    fotogramma vero e contrasto WCAG.
- **P.12** Il regime chiaro diventa ufficiale — CHIUSA
  - `lib/design_system/tokens/regime_chiaro.dart`: quattro token, tre soglie,
    e l'elenco delle superfici chiare dichiarate.
  - Difetto vero trovato dalla misura: la superficie dichiarata era il vetro,
    ma il vetro e' semitrasparente sopra il sole che sale. Adesso la
    superficie dichiarata e' il FONDO PEGGIORE MISURATO e tutti gli inchiostri
    discendono da lei.
- **P.13** Le etichette dell'Alba — CHIUSA
  - Ruolo didascalia, niente maiuscoletto, colori dalla porta unica.
  - Rosso eseguito: cinque testi sotto 4,5 a 1, da 3,29 a 3,74, a dodici punti.
- **P.14** Il presidio si estende al contrasto — CHIUSA
  - `tool/censimento_contrasto.dart` con COPPIE_CENSITE: 85 e
    SOTTO_IL_CONTRASTO: 8, letti a cricchetto da
    `test/tipografia_nel_dato_test.dart`, che verifica anche che le due copie
    della formula WCAG diano lo stesso numero.
- **P.15** L'Alba entra nei presidi intoccabili — CHIUSA
  - `test/presidi_intoccabili_test.dart`: sette presidi dichiarati, ognuno col
    suo perche', e una prova che cade se uno viene cancellato o svuotato.

## Sezione D. I doni del giorno

- **P.16** L'Oracolo del Giorno ricostruito — CHIUSA
  - IL MODO ESATTO IN CUI NON FUNZIONAVA: il commento e la riga a schermo
    dicevano di inclinare il telefono, e `RitualGesture` non aveva un valore
    per l'inclinazione. Nessuna riga leggeva il giroscopio per l'Oracolo.
  - Adesso `RitualGesture.tilt` esiste, la vista ascolta la porta unica
    `TiltListener`, il cielo si SPOSTA con l'inclinazione, il ripiego tattile
    resta obbligatorio, una riga dice cosa stai per ricevere e il ripiego col
    Riprova e' agganciato.
- **P.17** Ogni rito dichiara cosa fa, perche', e cosa resta — CHIUSA
  - Tre campi su `DailyElement`, un componente solo,
    `LeTreRigheDelRito`, montato in tutte e quattro le famiglie di schermate.
  - Il respiro contato esce dal testo e diventa `GuidaDelRespiro`, quella gia'
    costruita per il Soffio: una sola in tutto il progetto, verificato.
- **P.18** I doni si agganciano fra loro — CHIUSA
  - `lib/core/rituals/filo_del_giorno.dart`: la parola del mattino torna nel
    Sogno, la domanda di Medora torna nel dono del mattino DOPO. Il giorno e'
    quello rituale, non la mezzanotte. La runa del tramonto entrava gia' nel
    Sogno e non si e' aperta una seconda porta.

## Sezione E. Traguardi e Cosmic Journal

- **P.19** I 165 traguardi: obiettivi dell'ordine O, testi dall'Allegato A — CHIUSA
  - Correzione di Mauro del 12 agosto 2026, che ha priorita' su P.19: le tre
    guardie quantitative dell'ordine O restano in vigore e vincono
    sull'Allegato A, gli obiettivi non si sostituiscono, dall'Allegato si
    prendono NOME, PERCHE' CONTA e COSA APRE dove migliorano, il campo cosa
    apre diventa obbligatorio su tutti e 165, e l'aritmetica resta 2.010 per
    sentiero e 6.030 in tutto.
- **P.20** La celebrazione — CHIUSA
  - Le due intensita' c'erano gia'; mancava il salto al punto del journal, che
    adesso c'e' (`celebrazione_vai_al_sigillo`).
- **P.21** Il Sigillo sospeso si comporta come deciso — CHIUSA
  - `lib/core/sigilli/stato_del_sigillo.dart`: cinque stati enumerati, il
    sospeso pulsa piano e porta la marcatura. La prova attraversa tutte e
    sedici le combinazioni e cade se una lascia una casella grigia.

## Sezione F. I nove difetti ereditati

- **P.22** Il velo sui corpi sotto l'orizzonte — CHIUSA
  - Ancora aperta, chiusa adesso. Il corpo sotto il suolo si vela al 25 per
    cento e porta la linea dell'orizzonte: prima la scheda diceva "sta sotto il
    suolo" e la scena lo disegnava a piena luce. Passa da `_SkyBody`, quindi
    vale per tutti e due i cieli, e chi sta sopra si legge da `nomiVisibili`,
    cioe' dalla soglia del motore e non da una seconda.
- **P.23** Il luogo attuale nel profilo contro quello di nascita — CHIUSA
  - **UNA META' DELLA PREMESSA ERA GIA' CADUTA, e va detto.** Il difetto
    originale, coordinate dal luogo di NASCITA e scarto di fuso dall'orologio
    del telefono, e' stato chiuso da un ordine precedente:
    `PosizioneDiStamattina` garantisce per costruzione che le due cose vengano
    dalla stessa origine. Restava il caso di gran lunga piu' frequente, che
    nessuno aveva chiuso.
  - **Il campo**: `lib/core/astro/luogo_attuale.dart` (nuovo). Una citta'
    scelta dal catalogo e' una TERZA origine dell'alba, `dichiarata`, e vale
    quanto il dispositivo: il sorgere dipende da latitudine e longitudine, e
    dentro una citta' la differenza fra un quartiere e l'altro non arriva al
    minuto. Il dispositivo resta prima di lei, perche' chi viaggia ha concesso
    la posizione e l'alba e' dove sei adesso.
  - **La conservazione**: `DoveSonoAdesso`, su preferenze. Si conserva anche il
    luogo venuto dal dispositivo, e non e' un doppione del GPS: il servizio puo'
    essere spento, si puo' essere in metropolitana, e l'ultimo posto noto e'
    meglio di una stima dal fuso. L'origine resta scritta, quindi nessuno lo
    confonde con una lettura fresca.
  - **Il punto in cui si chiede, che pesa piu' delle altre due**:
    `lib/features/rituals/dove_sei_adesso.dart` (nuovo), dentro il dono del
    mattino e SOLO quando l'ora del sorgere non si puo' dichiarare, cioe' quando
    il rito sta rinunciando a dire una cosa vera. Due strade: il permesso col
    suo pre-avviso, che dice l'unica cosa che ottiene invece del testo generico,
    e la citta' scelta dal catalogo, che non chiede niente a nessuno. Chi dice
    no al permesso non resta fuori, ed e' la differenza fra chiedere con garbo e
    chiedere e basta.
  - Misura: `test/dove_sei_adesso_test.dart`, undici prove. Rosso eseguito
    togliendo il ramo dichiarato: l'origine torna `stimataDalFuso`, l'ora non e'
    dichiarabile e la riga sparisce dall'Alba.
- **P.24** La giuntura dell'Oroscopo che ripete se stessa — CHIUSA per la parte meccanica
  - **La riscrittura delle quarantotto ancore ESCE DALL'ORDINE P** e diventa una
    voce sua: sono materiale di Mauro, si guardano frase per frase e non si
    fanno di corsa, come l'ordine stesso prescrive. Qui si chiude il modo in cui
    la giuntura viene SCELTA.
  - Difetto uno: variava sul GIORNO e non sul dominio, quindi le quattro schede
    dello stesso oroscopo aprivano con la stessa frase, una sotto l'altra.
    Adesso `dominio.index` entra nell'indice: quattro resti distinti su cinque
    giunture, sempre, perche' quattro e' minore di cinque.
  - Difetto due, trovato misurando: le due famiglie di giunture erano lo stesso
    testo con la punteggiatura cambiata, identiche parola per parola a tre
    indici su cinque. La scelta fra punto e due punti era grammaticale, giusta e
    invisibile.
  - Misura: `test/la_giuntura_non_si_ripete_test.dart`, cinque prove su tutti i
    366 giorni per dodici segni. Rosso eseguito: tutti e cinque gli indici
    condividevano le prime tre parole, e il dominio non era nell'indice.
- **P.25** La card da condividere dell'Oroscopo senza transito — CHIUSA
  - Il difetto, confermato: la card verticale mostra emblema, nome del segno, la
    frase di sintesi dell'ancora, le quattro bolle e numero piu' colore. Il
    transito vero non compare da nessuna parte, quindi cio' che la gente manda
    agli altri e' la parte generica, e la parte che nessun'altra app puo' dare
    resta dentro l'app.
  - **La riga del cielo non e' un campo nuovo: c'era gia'.** `HoroscopeCard.text`
    e' la sintesi piu' la corrente del giorno attaccate, e `synthesis` e' la sola
    sintesi: `rigaDelCielo` stacca il resto e torna nulla quando la corrente
    viene dalla hash. Aggiungere un campo avrebbe voluto dire scrivere due volte
    la stessa stringa.
  - **NON SI E' DECISO DA SOLI, e la decisione e' arrivata: VINCE LA PROPOSTA A**,
    la riga in oro sotto la sintesi. Scelta di Mauro del 12 agosto 2026. La card
    porta adesso quella e nient'altro: l'enumerazione delle due disposizioni non
    esiste piu', perche' tenere montata la proposta scartata sarebbe codice morto
    che il prossimo lettore prende per una scelta ancora aperta.
  - La riga compare SOLO quando il cielo e' stato letto davvero: con la corrente
    presa dalla hash `rigaDelCielo` e' nulla e la riga non si disegna. Una card
    che scrivesse comunque una riga del cielo direbbe il falso nel posto piu'
    pubblico che l'app abbia.
  - **LA GIUNTURA NON E' STATA TOCCATA.** "Il cielo di oggi lo dice cosi'" e'
    corpus di Mauro e resta fuori dall'ordine, come le quarantotto ancore della
    voce 24: qui si dispone il testo, non si riscrive.
  - Misura: `La riga del cielo entra nella card, e solo se il cielo c'e'` in
    `test/oroscopo_widget_test.dart`, che chiede tre cose: che la riga ci sia col
    cielo vero, che porti la stessa stringa della scheda invece di ricomporla, e
    che stia SOTTO la sintesi, cioe' che non sia la proposta scartata. Rosso
    eseguito spegnendo la condizione: chiave trovata 0 volte.
  - Anteprima rigenerata e GUARDATA, `docs/preview/oroscopo-card.png`, che adesso
    monta un cielo vero: prima la cattura passava dalla hash, quindi avrebbe
    mostrato la card di prima facendo credere che la scelta non fosse applicata.
    Un guardiano nella cattura pretende la riga a schermo prima di scattare.
  - Le due immagini del confronto sono state RIMOSSE dal corredo: la scelta e'
    fatta, e un'anteprima che nessuno rigenera mostra uno stato vecchio. Cio' che
    resta e' la card vera.
  - Storia della decisione, che resta scritta qui perche' non si perda. Far
    entrare il transito era una scelta di composizione, quindi di Mauro. Due
    proposte, montate entrambe:
    `DisposizioneDelTransito.rigaSottoLaSintesi` (proposta A, una riga in oro con
    un glifo sotto la bolla, la gerarchia non cambia) e `fasciaInCima`
    (proposta B, una fascia sopra l'emblema con l'etichetta IL CIELO DI OGGI: la
    prima cosa che si legge diventa il cielo e il segno passa secondo).
  - Osservazione dalla proposta B, vista guardandola, ed e' una delle ragioni per
    cui non ha vinto: sotto l'etichetta la giuntura si ripeteva, "IL CIELO DI
    OGGI" e subito "Il cielo di oggi lo dice cosi'". Non era un difetto della
    disposizione, era il suo prezzo: sceglierla avrebbe voluto dire togliere la
    giuntura dalla riga della card, cioe' toccare il corpus.
  - File: `lib/core/horoscope/horoscope.dart`,
    `lib/features/horoscope/oroscopo_share_card.dart`,
    `test/screenshot_capture_test.dart`.
  - Le due anteprime del confronto erano
    `oroscopo-transito-A-riga-sotto-la-sintesi.png` e
    `oroscopo-transito-B-fascia-in-cima.png`, alla larghezza vera e col cielo
    vero, perche' senza fatti veri sarebbero state identiche fra loro e nessuno
    avrebbe visto la differenza da scegliere.
- **P.26** Il prato del Soffio — CHIUSA
  - **Scritta e rimessa indietro una volta, chiusa alla seconda.** Il prato non
    era un fondale: era un livello dentro un pittore che sulla stessa tela
    disegna il soffione e i semi. Il costo vero non era il prato, erano i
    QUATTRO FILE DI PROVA che montavano il Soffio nudo: `CosmosBackground`
    pretende un `MaestroScope`, che pretende un `Provider<MaestroController>`.
  - L'impalcatura vive adesso in un punto solo, `test/attorno_al_soffio.dart`,
    invece di essere riscritta quattro volte.
  - Difetto trovato GUARDANDO l'anteprima e non ragionando: tolto il prato, lo
    stelo del soffione finiva nel vuoto a 637 punti su 741. Il prato copriva
    quella terminazione, ed e' il secondo modo in cui non era solo un fondale.
    Rimedio: un orizzonte sfumato col verde di Aura che assorbe lo stelo, sopra
    il soffione e sotto i semi. Non una seconda fotografia.
  - Difetto trovato di rimbalzo e chiuso: la prova della concentricita' prendeva
    `Stack.first`, che col cosmo davanti e' quello del cosmo, alto 797 invece di
    741. Dichiarava 41,4 punti di scarto mentre l'inseguimento, misurato,
    converge a zero. Adesso la scena si chiama per nome, `soffio_scena`.
  - File: `breath_destiny_screen.dart`, `dove_si_muove_il_cielo.dart`,
    `test/attorno_al_soffio.dart` (nuovo), piu' i quattro file rifondati.
  - Anteprima rigenerata e GUARDATA: `docs/preview/soffio-destino.png`.
- **P.27** Le sedici anteprime che montano una scena che l'app non monta — CHIUSA
  - Il criterio dell'ordine: un'anteprima deve essere montata come e' montato
    cio' che prova. Sedici catture in quattro flussi montavano la schermata NUDA
    dentro un `MaterialApp` con un `MaestroScope` costruito a mano, mentre l'app
    le monta dentro `SogliaArte`, che porta la palette fissata sul proprietario
    dell'arte, l'arte corrente e IL CUORE DELLE ARTI PREFERITE nella barra. Il
    cuore non compariva in nessuna delle sedici.
  - **Un solo punto dichiara chi e' il proprietario di un'arte**: ogni schermata
    espone `conLaSoglia`, e la rotta chiede a lei invece di ripetere id e
    Maestro. Prima quei due dati vivevano dentro `route`, cioe' in un punto che
    solo l'app attraversa: chi montava la schermata da fuori doveva indovinarli.
  - Difetto trovato di rimbalzo GUARDANDO l'anteprima: dentro la soglia il cuore
    ancora non compariva, perche' `CuorePreferita` legge
    `ArtiPreferiteController` e le catture non fornivano lo scaffale. Le due
    cose insieme erano il difetto, e una sola delle due non bastava.
  - File: `face_constellation_screen.dart`, `guide_animal_screen.dart`,
    `rune_draw_screen.dart`, `test/screenshot_capture_test.dart`.
  - Misura: `test/anteprime_montano_cio_che_l_app_monta_test.dart`, sei prove.
    Due misure sono state corrette perche' misuravano male: contare
    l'identificativo nudo dava quattro dove le dichiarazioni sono una, perche' la
    parola compare anche in un percorso di import e in una chiave di widget.
- **P.28** Il gesto di condividere in tredici posti — CHIUSA
  - Ancora aperta, chiusa adesso: erano TREDICI file a chiamare `SharePlus`
    per conto loro. Adesso c'e'
    `lib/core/condivisione/porta_della_condivisione.dart` e nessun altro file
    importa piu' `share_plus`. La prova ENUMERA i chiamanti invece di
    visitarne uno.
- **P.29** La rinomina di sunset_time.dart in solar_time.dart — CHIUSA
  - Ancora aperta, chiusa adesso, con `git mv` e i dieci importatori
    aggiornati. Il file contiene anche il sorgere, e la prova lo verifica: e'
    la ragione della rinomina.
- **P.30** Uruz non scontornata — CHIUSA
  - GIA' CHIUSA DA UN ORDINE PRECEDENTE, con la prova che lo dimostra:
    misurata, Uruz ha il 70,8 per cento di pixel opachi, dentro la fascia
    delle altre ventitre, che va dal 62,2 di Ansuz all'81,9 di Algiz. Il 94,3
    per cento dell'ordine non c'e' piu': l'ha tolto `tool/pulisci_uruz.py`.
    Resta il presidio, che confronta Uruz con le sue sorelle invece che con un
    numero scelto.

## Sezione G. Consegna

- **P.31** Il manifesto e la guardia — CHIUSA
  - **LA VOCE DI SCARTO, e lo scarto era proprio qui.** Il lavoro di questa
    voce e' finito con la SECONDA sessione: il manifesto esiste, e' stato
    creato come primissima azione prima di qualunque codice, ed e' stato
    portato da 32 a 40 righe quando la Sezione Zero e' nata. Ma la sua RIGA e'
    rimasta APERTA per due sessioni, mentre la prosa di tutti e due i rapporti
    la dava per chiusa.
  - Il conto che non tornava: la seconda sessione ha dichiarato 12 voci
    terminali e ne ha nominate tredici, otto della Sezione Zero, tre della
    Sezione A, piu' P.04 e questa. La terza ha dichiarato 7 voci aperte e ne ha
    nominate sei con del lavoro dentro, perche' questa lavoro non ne aveva piu'.
    La stessa riga, sbagliata in due direzioni opposte.
  - **Perche' e' successo, e non e' una svista qualunque.** Lo stato di una
    voce vive in un posto solo, la sua riga; la prosa di un rapporto e' un
    racconto. Per due sessioni il racconto e' stato piu' aggiornato del dato, e
    nessuna prova poteva accorgersene: la guardia conta le righe e i marcatori,
    e i marcatori erano coerenti con le righe. Erano entrambi coerenti e
    entrambi in ritardo sul fatto.
  - File: `docs/ordini/ORDINE_P_MANIFESTO.md`, `test/ordine_p_guard_test.dart`.
  - Misura: la guardia legge questo file, pretende quaranta righe da P.01 a
    P.40, uno stato solo per riga fra i tre ammessi, e marcatori che coincidono
    col conto vero delle righe. Un accorpamento la fa cadere invece di
    passarci in mezzo.
- **P.32** Il rapporto — CHIUSA
  - `docs/ordini/RAPPORTO_ORDINE_P.md`, riscritto alla quarta sessione con tutte
    e quaranta le righe, una per una, ognuna col suo stato letto da questo file e
    non dalla prosa di un rapporto. Un rapporto con meno di quaranta righe non e'
    valido.
  - Dichiara la voce dello scarto, P.31, e come e' stata riconciliata; quante
    stringhe sono state convertite in ortografia e come e' stata corretta la
    prova che accusava un'elisione legittima; le tre prove del colore riverificate
    e verdi; le anteprime della Sezione B rigenerate e GUARDATE, con cosa in
    ognuna e' disegnato da noi e non dal framework.
  - Non nomina nessun numero di build: quello lo decide Mauro.

---

VOCI_TOTALI: 40
VOCI_CHIUSE: 39
VOCI_FERMATE_SU_PREMESSA_FALSA: 1
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0
