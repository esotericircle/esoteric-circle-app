# Manifesto dell'ORDINE S

Creato come primissima azione dell'ordine, prima di qualunque modifica al codice,
come la legge di consegna prescrive. Ogni voce si chiude da sola con la sua
misura: le voci non si rinumerano, non si accorpano e non si dichiarano coperte da
un'altra.

L'ordine si chiama IL CAMMINO SI VEDE, GLI EOS SI CAPISCONO, E I RESPONSI PARLANO
ALLE PERSONE, e il testo integrale sta in `docs/ordini/ORDINE_S.md`.

Stati ammessi, gli stessi dell'ordine P: **APERTA**, **CHIUSA**, **FERMATA SU
PREMESSA FALSA**, **FERMATA IN ATTESA DI DECISIONE**.

Il quarto stato non e' un modo elegante di dire aperta: e' per le voci dove il
lavoro e' finito e cio' che resta e' una scelta che non spetta a chi costruisce.
Chiuderle da soli vorrebbe dire decidere al posto di Mauro, lasciarle aperte
direbbe il falso.

La guardia `test/ordine_s_guard_test.dart` legge questo file e resta rossa finche'
la somma dei tre stati terminali non raggiunge VOCI_TOTALI. **Finche' e' rossa la
build non si fa e il rapporto non si scrive.** Si committa comunque a ogni voce
chiusa: committare non e' consegnare.

---

## Sezione Zero. Quello che la 2177 ha lasciato aperto. Si esegue per prima

- **S.01** Il disegno del sentiero e' il protagonista — CHIUSA
  - Causa: DUE regole dello stesso ordine P che si combattevano. La P.33 vuole il
    disegno come prima cosa che si vede, la P.36 fa scendere lo scorrimento al
    traguardo raggiunto appena la schermata si apre. Vinceva la discesa, quindi
    chi apriva atterrava sull'elenco e il disegno non lo vedeva mai: non era un
    difetto di nessuna delle due, era la loro somma.
  - Decisione di Mauro, e supera la P.36: la discesa automatica si toglie. **Il
    codice della misura non si e' buttato, si e' spostato sul TOCCO**, il comando
    discreto "Vai al punto in cui sei" sotto il disegno: quella misura e' costata
    una voce intera, perche' prima il punto d'arrivo si stimava da un'altezza
    scritta a mano e scivolava.
  - Il disegno non e' piu' un quadrato: `quotaDelDisegno = 0,58` dell'altezza
    UTILE, che si misura dove il viewport la dichiara e non dedotta dallo schermo
    sottraendo barra e intestazione a mano. Misurato sulla resa a 360 per 797:
    **il disegno prende il 58,0 per cento** e all'apertura ci sta dentro tutto.
    Non e' un quadrato e i pittori non ne soffrono: pongono i punti su coordinate
    normalizzate e prendono i raggi dal lato corto.
  - Con Riduci Movimento vale lo stesso: nessuno scorrimento all'apertura, e il
    tocco porta al punto senza volo, misurato su UN solo fotogramma.
  - File: `lib/features/sigilli/sentiero_screen.dart`.
  - Misura: `test/il_disegno_e_il_protagonista_test.dart`, quattro prove. Rosso
    eseguito rimettendo la discesa automatica: lo scorrimento si apriva a 3.042
    punti invece di 0, e a 3.216 con Riduci Movimento.
  - Anteprime rigenerate e GUARDATE: `docs/preview/sentiero-costellazione-apertura.png`,
    `-albero-`, `-loto-`.
- **S.02** I tre disegni sono fatti bene — CHIUSA
  - **Tutte e nove le anteprime rigenerate e GUARDATE**, e il giudizio sulle tre
    domande del criterio sta nel rapporto, sentiero per sentiero e stato per
    stato. La prima stesura della voce era stata dichiarata con sei anteprime
    guardate su nove, ed e' rimasta aperta finche' non sono state nove.
  - **Quattro difetti trovati dall'Architetto sulle tre anteprime che
    mancavano**, e tutti e quattro corretti: l'Albero era un'antenna, il Loto
    aveva il fiore GIA' APERTO a zero, il Loto era un soffione (e il soffione
    nell'app esiste gia', e' il Soffio del Destino), lo stelo si prendeva mezza
    altezza.
  - L'ALBERO: il tronco si assottiglia salendo e non sporge oltre il primo e
    l'ultimo nodo; i rami CURVANO, si alternano in altezza invece di specchiarsi
    a coppie, e si assottigliano verso la punta; alla base ci sono le radici,
    perche' un albero che finisce nel vuoto galleggia; il tronco si ACCENDE fino
    a dove sei arrivato, ed e' per questo che l'ossatura non porta segmenti fra
    le Sefirot: sono il tronco. Via il cerchietto bianco spostato dentro i nodi,
    che sui grandi si leggeva come una mezzaluna appiccicata.
  - IL LOTO: pochi petali larghi e appuntiti su cinque giri di forma DIVERSA, non
    la stessa forma ruotata; i giri sono 6, 8, 10, 12 e 14 mini piu' il petalo
    centrale che e' il grande, e fanno cinquanta esatti. **Un petalo chiuso e'
    chiuso**: piu' corto, piu' stretto e tirato verso il verticale, quindi a zero
    si vede un BOCCIOLO. Il fiore prende l'altezza e lo stelo e' il dettaglio in
    fondo che era.
  - Numeri corretti dopo una prova rossa della voce P.33: col giro esterno a 0,52
    del lato corto i petali estremi uscivano dalla tela, cinquanta pixel sui
    fianchi misurati. Adesso 0,40 e il fiore ci sta dentro.
  - **L'ULTIMO GRANDE DA' ALLA FIGURA QUALCOSA CHE PRIMA NON AVEVA, non un pezzo
    in piu'.** Era la regola che mancava, e la sua assenza si misurava: da meta' a
    completa il Loto cambiava il 3 per cento della propria impronta, cioe' un
    petalo su cinquanta, cioe' niente. Sull'Albero era gia' vero senza avere un
    nome, perche' Keter porta una corona di luce che le altre Sefirot non hanno, e
    quella e' il modello.
    - LOTO: quando il cuore si apre, **la luce nasce dal centro** e si propaga
      verso i petali. Il fiore completo non e' un petalo in piu' aperto, e' un
      fiore ACCESO. **L'ordine di apertura NON si inverte**: il cuore si apre per
      ultimo, perche' e' come si schiude un loto vero ed e' cio' che dice la riga
      del Passport, il loto si schiude quando il respiro ha smesso di essere una
      decisione.
    - COSTELLAZIONE: quando l'ultima stella principale si accende, tutta
      l'ossatura porta un alone continuo sotto le linee, e la figura si legge come
      UNA cosa invece che come cinquantaquattro segmenti piu' uno.
  - Misura del compimento: la differenza fra l'anteprima a meta' e quella
    completa deve toccare piu' del 45 per cento dell'IMPRONTA della figura, cioe'
    dei pixel che la figura occupa in tutto. E' un confronto della figura con se
    stessa, quindi non dipende da quanto e' grande la tela. Rosso eseguito
    spegnendo il compimento: il Loto scende al **3 per cento** e la prova cade
    dicendo che l'ultimo traguardo non sta dando niente.
  - UNA FIGURA SOLA, non cinque figurine: i cinque principali stanno su una
    SPINA e ogni parte cresce da lei con due braccia. I cinque grandi sono le
    stelle che reggono la forma, i cinquanta mini la riempiono.
  - Tre grandezze dichiarate come dato, `GrandezzaDelPunto`: principale 0,0290,
    media 0,0165, piccola 0,0098 del lato corto. Quale punto sia di quale
    grandezza sta nella geometria.
  - Le linee si disegnano SOLO fra punti accesi, `ossatura` piu' i segmenti
    dichiarati: a zero traguardi non c'e' nessun segmento, quindi la forma
    finale non si vede prima di meritarla.
  - I punti spenti sono punti PIENI e tenui, non anelli: un cerchio col centro
    vuoto si legge come una casella da spuntare.
  - LA FASCIA DEI CINQUE GRANDI NON C'E' PIU', punto 7, ed era la strada
    raccomandata: le cinque stelle principali si vedono spente in anticipo
    dentro il disegno, quindi la tessera punti e' il disegno.
  - Trovato guardando: l'Albero era un ABETE, cinque coppie di rami identici e
    orizzontali. Adesso i rami hanno lunghezze e pendenze diverse per parte, si
    assottigliano verso la punta (lo spessore e' un dato del segmento), e Keter
    porta una corona di luce che le altre Sefirot non hanno.
  - Trovato guardando: il LOTO non era un fiore ma un mandala geometrico, perche'
    legare i dieci petali di un giro con segmenti dritti disegna un decagono, e
    cinque giri disegnavano cinque decagoni coi loro spigoli. **Il Loto non ha
    ossatura**: la sua figura sola sono i giri concentrici attorno allo stesso
    cuore, e la crescita si vede nei petali che si aprono.
  - Misura: `test/una_figura_sola_test.dart`, diciassette prove sui tre sentieri,
    a pixel su una tela vera e per DIFFERENZA fra la tela a zero e quella piena,
    perche' il tronco e lo stelo sono struttura e in una misura assoluta
    passavano per segmenti. Rosso eseguito rimettendo il reticolo intero: cadono
    tre prove su tre sentieri.
- **S.03** La schermata dice dove sei, cosa vedi e cosa guadagni — CHIUSA
  - **PRIMA DELLE TRE RIGHE, IL CONTO: e' 55.** A schermo i conti erano DUE e
    stavano per diventare tre: la lista diceva "50 di 50" col cinquanta scritto a
    mano, mentre le posizioni per sentiero sono cinquantacinque. Il conto scelto e'
    **55, per decisione di Mauro**, perche' i cinque grandi sono traguardi a tutti
    gli effetti: valgono Eos, hanno le loro condizioni, e dalla voce S.02 sono le
    cinque stelle principali del disegno. Un totale che li esclude dice alla
    persona che quelle cinque cose non contano.
  - Il conto vive in un punto solo, `Sentieri.quantiInTutto`, e da lui leggono la
    riga in alto e i sottotitoli della lista. Nasce anche
    `Sentieri.ordineNelCammino`, da 1 a 55, perche' **la posizione non e'
    l'ordine**: le posizioni dei mini vanno da 1 a 50 e i grandi stanno a 10, 20,
    30, 40 e 50, quindi i due elenchi si sovrappongono, e un grande CHIUDE la sua
    decina, cioe' viene dopo il mini che porta il suo numero.
  - Le tre righe stanno in `lib/features/sigilli/le_tre_righe_del_sentiero.dart`,
    un punto solo, e i tre sentieri le compongono dalla stessa struttura cambiando
    la sola voce: DOVE SEI col numero dal dato e scritto in parole, COSA VEDI in
    una frase del Maestro, COSA GUADAGNI detto una volta.
  - **NON SI DICHIARA UNICO CIO' CHE UNICO NON E'.** La Costellazione personale e'
    inventata e nel cielo di nessun altro esiste, quindi la sua riga puo' dirlo.
    L'Albero della Vita NO: le dieci Sefirot, i ventidue sentieri e la loro
    disposizione sono gli stessi per chiunque, e il loto e' un simbolo condiviso.
    Cio' che e' unico sono i frutti maturati e i petali aperti: la struttura e' di
    tutti, il cammino sopra e' suo. L'Albero lo diceva gia' cosi', "questo porta i
    TUOI frutti"; il Loto diceva soltanto cosa fa un loto e non nominava la parte
    che e' della persona, ed e' stata riscritta: "Il loto e' un simbolo di tutti:
    questi petali li hai aperti tu." Una prova vieta le rivendicazioni di unicita'
    sull'Albero e sul Loto e le PRETENDE sulla Costellazione, e chiede che le due
    righe nominino la parte che e' della persona. Rosso eseguito mettendo sul Loto
    "Nessun altro loto e' come questo: e' solo tuo."
  - **La riga "cosa vedi" NON spiega il disegno.** Adesso che il disegno e' buono,
    spiegarne il meccanismo lo insulterebbe: dice cosa E' la figura. Una prova
    vieta le parole del tutorial ("tocca", "scorri", "quando accendi", "vedrai")
    dentro quella riga.
  - I numeri sono in parole e non in cifre, da zero a cinquantacinque: un
    intervallo chiuso, quindi nessuna dipendenza in piu' e nessun convertitore
    generale. Con la vocale che cade dove deve, ventuno e non ventiuno.
  - Misura: `test/il_conto_e_uno_solo_test.dart`, otto prove. Una ENUMERA i file
    di `lib/features` e cade se un punto qualsiasi scrive un totale del sentiero a
    mano, perche' e' cosi' che i conti tornano a essere due. Verificato a video su
    `docs/preview/sentiero-costellazione-meta.png`: "Ventisei stelle accese su
    cinquantacinque", e nella lista "54 di 55".
- **S.04** Perche' il borsellino e' a zero — CHIUSA
  - **PRIMO PASSO FATTO: il fallimento e' leggibile.** Il `catch` attorno
    all'accredito non registrava niente, quindi se l'accredito falliva non lo
    sapeva nessuno: ne' la persona, ne' un registro, ne' una prova. Finche' era
    cosi' la causa non era leggibile da fuori e ogni ipotesi valeva come le altre.
    Adesso i due modi di fallire, il server che non risponde e l'eccezione, vanno
    nel `RegistroDeiGuasti`, che e' la stessa porta dove finiscono i silenzi della
    voce: un secondo registro dividerebbe i guasti e nessun pannello li mostrerebbe
    tutti.
  - **E UNA CAUSA E' STATA TROVATA mentre si rendeva leggibile il guasto.** Il
    saldo nuovo arriva DENTRO la risposta dell'accredito, ed era buttato: si
    chiamava `sincronizza`, cioe' una SECONDA chiamata al server per tutto lo stato
    del giorno. Se quella non risponde, e senza rete non risponde, il numero in
    barra resta quello vecchio anche con l'accredito riuscito, e la persona vede
    "+10 Eos" nella festa e zero nel borsellino. E' la strada (b) delle quattro
    dell'ordine. Nasce `QuestionAllowance.applicaSaldo`, che applica il numero che
    il server ha appena detto, avvisa chi guarda e lo scrive su disco.
  - Misura: `test/il_saldo_cambia_a_schermo_test.dart`, sette prove. Fra loro:
    ogni traguardo dei 165 chiede un premio con un motivo che il server conosce
    (chiude la strada di un motivo sconosciuto che renderebbe l'accredito un errore
    per sempre), e la porta spenta NON finge un accredito, perche' un saldo
    inventato in barra e' peggio di un saldo fermo. Rosso eseguito rimettendo il
    catch muto e la seconda chiamata.
  - **IL CRITERIO DI CHIUSURA E' SODDISFATTO**, ed e' il giro intero dalla regia
    alla barra: `test/il_saldo_in_barra_si_muove_test.dart` monta un albero vero
    con una porta che risponde, compie tre stese (il traguardo `med_5` chiede tre
    gesti: con uno solo non si accende niente e la prova misurerebbe soltanto che
    non e' successo nulla), e legge il NUMERO A VIDEO. Rosso eseguito rimettendo
    la seconda chiamata al posto di `applicaSaldo`: la barra resta a zero e la
    prova cade dicendo che la persona vede "+10 Eos" nella festa e zero nel
    borsellino.
  - La prova gemella misura il contrario, e serve: **se il server tace il numero
    resta fermo** e il guasto e' scritto nel registro. Senza di lei si potrebbe far
    passare la prima inventando un saldo quando il server non risponde, e una cifra
    che sul server non esiste e' peggio di una cifra ferma.
  - Le due prove non usano `pumpAndSettle`: la celebrazione porta animazioni che
    non si assestano mai, e la prova cadrebbe per un tempo scaduto invece che per
    il saldo. Si avanza a passi dichiarati.
  - **LE STRADE (c) E (d) SONO VERIFICA DI MAURO SUL DISPOSITIVO, e non lavoro
    lasciato indietro.** (c) l'utente anonimo che dopo una disinstallazione ha un
    ramo diverso sul server, quindi un saldo che esiste e non e' il suo: si vede
    solo installando, disinstallando e reinstallando su un telefono. (d) le
    marcature "Eos in attesa", che segnalerebbero un bonus di condivisione mai
    incassato: dipendono dalla voce S.08, perche' finche' i tre pulsanti della
    celebrazione non fanno niente quel bonus non e' incassabile da nessuno. Qui non
    c'e' nessun dispositivo, e tenere la riga aperta per una cosa che in questa
    stanza non si puo' fare sarebbe lasciare il conto in sospeso su un lavoro
    inesistente.
- **S.05** Gli Eos hanno un nome e una loro icona — CHIUSA
  - Il difetto: in barra il saldo era `Icons.auto_awesome`, la scintilla di serie
    di Android, con accanto un numero e nessuna parola. Nessuno capiva che fossero
    Eos, e chi ci provava leggeva "stelle". Peggio: quella scintilla e' l'icona che
    il framework mette su mezza app, quindi il denaro del Cerchio portava lo stesso
    segno di un effetto speciale qualunque.
  - **Un'alba e non una moneta**, e la ragione sta nel nome: Eos e' l'aurora. Il
    segno e' un sole che sorge sopra la linea dell'orizzonte con tre raggi, in
    `lib/design_system/components/icona_degli_eos.dart`, un punto solo da cui ogni
    schermata la prende. Una moneta o un gettone avrebbero detto "valuta di gioco",
    che e' precisamente cio' che gli Eos non devono sembrare. Tre raggi e non
    cinque: a sedici punti il quarto e il quinto si toccano e diventano una macchia.
  - Agganciata in quattro punti: il saldo in barra (con la parola Eos accanto al
    numero), il premio di ogni riga dell'elenco, la card del traguardo, e gli Eos
    che si contano nella celebrazione.
  - Misura: `test/gli_eos_hanno_un_nome_test.dart`, cinque prove. ENUMERA i punti
    che mostrano Eos e cade col nome del file se uno non usa l'icona del design
    system; e una prova cade se un file NUOVO mostra Eos e non e' nell'elenco,
    perche' e' l'unico modo in cui un'enumerazione resta vera invece di invecchiare
    in silenzio. L'ultima misura che l'icona DIPINGA davvero a sedici punti, fra il
    4 e il 55 per cento dei pixel: un'icona vuota passerebbe qualunque prova
    strutturale. Rosso eseguito rimettendo la scintilla in barra.
  - **LA GRANDEZZA MISURATA E' CAMBIATA DUE VOLTE**, e sta scritto nella prova. La
    prima stesura cercava la scintilla in tutto il file e accusava un'icona che non
    e' quella del saldo, il segno del Sigillo acceso nelle righe dell'elenco: si
    guarda percio' la VICINANZA, sei righe attorno a un numero in Eos. La seconda
    accusava un COMMENTO, quello che spiega quale icona c'era prima: un commento non
    disegna niente, e si salta cio' che comincia con la doppia barra.
  - Difetto trovato GUARDANDO l'anteprima: con la parola Eos accanto al numero la
    riga in barra e' cresciuta e il titolo e' tornato a troncarsi in "Costellazio ne
    persona...", che e' il difetto che l'ordine P aveva chiuso. Il saldo si e'
    stretto di cio' che era margine e non contenuto.
  - **LA CORREZIONE DEL TITOLO, decisa da Mauro e valida per TUTTE le arti.** Il
    nome del sentiero non si accorcia: "Costellazione personale" vive nel briefing,
    nel Cosmic Passport e nella schermata, e cambiarlo in un posto solo creerebbe
    due nomi per la stessa cosa, che e' la famiglia delle due porte. Si adatta
    percio' la misura del testo e non il testo, in quest'ordine: a capo FRA le
    parole e mai dentro una parola; se la parola piu' lunga non entra, il titolo
    scende di misura fino a entrare, entro un minimo dichiarato di quattordici punti
    che sta sopra il pavimento tipografico dell'app; non si tronca e non si mettono
    i puntini, perche' l'ellissi e' gia' costata una voce nell'ordine P.
  - Fatto in `lib/design_system/components/titolo_che_non_si_rompe.dart`, un punto
    solo. **Basta guardare la parola piu' lunga**: un motore di testo spezza una
    parola solo quando quella parola, da sola, non sta in una riga, quindi se la
    piu' lunga entra nessuna si spezza.
  - **IL DIFETTO VERO ERA IL SOFTWRAP EREDITATO, e va detto perche' nessuna misura
    sulle righe poteva vederlo.** L'AppBar avvolge il titolo in un
    `DefaultTextStyle` con `softWrap: false`: un `Text` che non lo dichiara eredita
    quel no, resta su UNA riga e, con `overflow: visible`, dipinge fuori dalla
    propria scatola passando sopra le azioni della barra. Una riga non supera mai il
    tetto di due, percio' `didExceedMaxLines` non scattava: la prova adesso
    confronta l'ALTEZZA resa con quella che il testo occuperebbe andando a capo.
  - Misura: `test/il_titolo_non_si_rompe_test.dart`, quattro prove che montano la
    schermata VERA dalla sua rotta, con le sue azioni, il saldo e il cuore, e
    misurano la larghezza dalla resa. La prima stesura scriveva 176 punti presi a
    occhio e passava col difetto in piedi, percio' si e' buttata: a quella larghezza
    inventata la parola lunga entrava, nella barra vera no.
  - **UNA PORTA SOLA per tutte le arti**, e la prova le ENUMERA. Tre schermate
    (Viso, Animale Guida, Estrazione Rune) avvolgevano il titolo in un `FittedBox`,
    che lo rimpicciolisce senza fondo per tenerlo su una riga e percio' puo' finire
    sotto il pavimento tipografico, e non va a capo mai; il Test Archetipo passava
    un `Text` nudo. Sono tre modi diversi di rompere lo stesso titolo, e adesso una
    prova cade col nome del file se una barra monta il titolo per conto suo.
  - Rossi eseguiti: `Text` con l'ellissi al posto del componente (cade su "la parola
    viene spezzata a meta'" e su "tornato a poter mettere i puntini"), e togliendo il
    `softWrap: true` (cade su "sta dipingendo fuori dalla sua scatola e passa sopra
    le azioni della barra").
  - GUARDATE alla larghezza reale cinque barre: "Costellazione / personale",
    "Costellazione / del Viso", "Estrazione / Rune", "Animale Guida" e "Test
    Archetipo". Nomi interi, a capo fra le parole, nessuna sovrapposizione con
    l'icona degli Eos ne' col cuore.
- **S.06** Il borsellino e' sempre visibile — CHIUSA
  - Il difetto: il saldo esisteva in UNA schermata, il sentiero dei Sigilli, ed era
    disegnato dentro di essa. Da ogni altra parte gli Eos non c'erano. Un numero che
    appare e scompare non si impara, e chi non lo vede non sa nemmeno di averne.
  - **UNA FORMA SOLA, UN POSTO SOLO**, in
    `lib/design_system/components/borsellino.dart`: l'icona degli Eos, il numero, la
    parola, in coda alle azioni della barra e prima del cuore. La riga disegnata a
    mano nel sentiero e' stata TOLTA, non copiata: lasciarla sarebbe stato il secondo
    borsellino, cioe' due numeri da tenere d'accordo per sempre.
  - **LA BARRA DELLE ARTI LO MONTA DA SE'**, quindi le sei schermate che passano da
    `BarraArte` lo hanno senza una riga in piu' e nella stessa posizione. Le altre
    tredici hanno una AppBar propria e montano lo stesso widget. Nel Dominio di un
    Maestro sta dentro lo Stack del titolo e non fra le azioni: li' il titolo occupa
    tutta la barra per tenere il nome esattamente al centro, e un'azione vera glielo
    avrebbe spostato.
  - **DICIANNOVE CON, DIECI ESENTI, e ogni esenzione porta la sua ragione scritta.**
    La chat di un Maestro tiene l'intestazione volutamente vuota, ed e' una scelta
    gia' scritta nel suo sorgente; le superfici immersive non hanno barra; account,
    impostazioni, dati di nascita, identita' e prezzario non sono la pratica, e nel
    prezzario un saldo accanto ai piani confonderebbe l'offerta.
  - **IL PORTAFOGLIO, e le tre cose sono tre perche' rispondono a tre domande
    diverse.** Quanto ho e' il saldo. Quando ne avro' di piu' e' la ricarica. Da dove
    vengono e' la fiducia. Si apre toccando il segno, ed e' un foglio inferiore in
    tono, non una schermata nuova.
  - **QUI SI DECIDE DI NON INVENTARE NIENTE.** Gli Eos non si ricaricano da soli:
    cio' che torna ogni giorno sono i gesti del giorno, e il giorno lo dice il
    server. Il bonus mensile la matrice lo promette con una parola e non con una
    cifra (No, Medio, Alto, Massimo): il portafoglio dice che il piano ne porta, non
    quanto, perche' una cifra inventata nel borsellino e' peggio di una cifra
    assente. `PlanCatalog.eosOgniMese` legge quella riga come `haMemoria` legge la
    sua, e non traduce il livello in un numero.
  - **DA DOVE SONO ARRIVATI GLI ULTIMI EOS: serviva un registro, e non c'era.** Il
    diario del cammino tiene i traguardi accesi in un INSIEME, che per costruzione
    non ha ne' ordine ne' momento: "gli ultimi" non era una domanda a cui si potesse
    rispondere. Adesso `RegistroDegliEos` segna il movimento nell'istante in cui
    l'app lo compie, con la ragione in parole della persona ("Il primo passo", non
    "traguardo id_3"), ne tiene otto e sopravvive alla chiusura dell'app.
  - **IL REGISTRO RACCONTA, NON CONTA.** Sommare i movimenti darebbe un secondo saldo
    accanto a quello del server, e al primo movimento perso i due discorderebbero:
    la persona vedrebbe due numeri diversi nella stessa schermata. Una prova cade se
    il registro comincia a sommare, e un'altra semina dieci Eos nel registro con
    sette sul server e pretende che a schermo si legga sette.
  - **UN DIFETTO TROVATO STRADA FACENDO, e non e' del borsellino.** Nella regia del
    cammino, quando l'accredito non riceve risposta, c'era un `return` dentro il
    ciclo dei traguardi maturati: un accredito muto si portava via anche gli altri,
    nessuna festa e nessun Sigillo acceso, con un solo guasto scritto per tutti.
    Adesso e' un `continue`, e il premio di quello si riprende alla prossima
    sincronia.
  - Misura: `test/il_borsellino_si_vede_sempre_test.dart`, sei prove. **ENUMERA**: ogni
    schermata con una barra deve stare in UNA delle due liste, e una schermata nuova
    cade col suo nome invece di passare in silenzio. Una prova monta il sentiero VERO,
    tocca il segno e pretende le tre cose nel foglio. Rossi eseguiti: togliendo il
    borsellino dal Rito dell'Alba (cade col nome del file) e togliendo il terzo blocco
    del portafoglio (cade su "non dice da dove sono arrivati gli Eos").
  - **IL FOGLIO PRENDE LA PALETTE DA CHI LO APRE**, e la prima stesura cadeva: un
    foglio inferiore vive nell'Overlay del Navigator, cioe' SOPRA la rotta che lo ha
    aperto, e il `MaestroScope` dell'arte sta dentro la rotta. E' la stessa scelta
    del foglio delle funzioni.
  - **IL SEGNO NON FA CADERE UNA SCHERMATA CHE NON HA LA BORSA.** Le prove montano
    scene d'arte da sole: pretendere il provider avrebbe fatto cadere schermate
    intere per un numero in un angolo, e infatti ha fatto cadere la prova
    dell'archetipo. Che il segno ci sia dove deve non lo garantisce quel controllo,
    lo garantisce l'enumerazione.
  - Anteprima nuova, GUARDATA: `docs/preview/portafoglio-aperto.png`, saldo, ricarica
    e tre movimenti con la loro ragione. **La prima cattura mostrava "0 Eos" accanto a
    tre movimenti in entrata**, cioe' il difetto del borsellino a zero della voce
    S.04: il saldo era seminato prima del `load()` del guscio, che legge il disco in
    asincrono e lo sovrascriveva. Adesso si semina per ultimo.
- **S.07** Gli Eos volano dalla celebrazione al borsellino — CHIUSA
  - Le due cose sono due, e possono rompersi da sole: **il numero che sale contando
    e' la notizia, il volo delle scintille e' il modo in cui si vede arrivare.** Con
    Riduci Movimento si toglie la seconda e la prima resta, perche' cio' che si
    toglie e' il moto e non la notizia.
  - **IL VOLO PARTE QUANDO LA FESTA SE NE VA, e non quando il server risponde.** La
    celebrazione grande copre la barra: lanciarlo all'accredito vorrebbe dire
    attraversare una scena a schermo pieno per arrivare a un borsellino coperto, e
    non lo vedrebbe nessuno. `Celebrazione.festeggia` ha percio' un gancio nuovo,
    `allaChiusura`, che vale per entrambe le forme: la rotta grande quando viene
    chiusa, la fascia quando se ne va da se'.
  - **IL NUMERO SI SA DOPO, e per questo c'e' una scatola.** La festa parte prima
    che il server risponda, e il gancio della chiusura scatta dopo: `_QuantiSonoArrivati`
    porta il numero dall'uno all'altro senza far attendere la festa, che e' il
    difetto della voce P.34 al contrario. Se la festa si chiude prima della risposta
    resta a zero e non vola niente: giusto, non c'e' ancora nulla da far arrivare.
  - **DOVE ARRIVANO NON SI INDOVINA.** Il segno del borsellino DICHIARA la propria
    scatola in `DoveStaIlBorsellino`, e il volo la chiede: scrivere l'angolo in alto
    a destra dentro il volo sarebbe stato tenere d'accordo per sempre due punti che
    nessuno confronta. Senza borsellino a schermo il volo non parte affatto, che e'
    meglio di un volo verso il nulla.
  - **SEI SCINTILLE AL MASSIMO, non una per Eos**: un traguardo grande ne porta
    trenta, e trenta scintille sono una nuvola. Partono a scaglioni e su archi
    diversi, altrimenti sei punti sulla stessa retta sembrano uno.
  - **IL CONTO NON PARTE ALL'APERTURA.** Il segno ricorda l'ultimo numero mostrato e
    conta solo quando cambia: un saldo che conta da zero ogni volta che apri una
    schermata racconterebbe un premio appena arrivato che non e' arrivato.
    L'`ArrivoDegliEos` fa ricominciare il conto da prima del premio, perche' il
    saldo era gia' cambiato dietro la festa.
  - Misura: `test/gli_eos_volano_nel_borsellino_test.dart`, quattro prove.
    **SI MISURA DOVE ARRIVANO**, non che il widget esista: si legge la posizione
    della prima scintilla e si confronta con la scatola che il borsellino dichiara.
    Una prova fa il giro intero con una porta finta che accredita, aspetta la festa,
    e pretende che NIENTE voli finche' la festa e' a schermo e che il volo parta
    appena se ne va.
  - Rossi eseguiti: portando la durata del conto a zero (cade su "il numero e'
    scattato subito a 40: e' cambiato senza che si veda cambiare") e spostando il
    volo all'accredito invece che alla chiusura (cade su "gli Eos volano mentre la
    festa copre ancora la barra").
  - **DUE DIFETTI TROVATI DALLE PROVE, e sono di quelli che passano.** La partenza
    veniva da `MediaQuery.sizeOf`, che in una prova con un MediaQuery proprio vale
    zero: le scintille partivano dall'angolo in alto a sinistra, cinquecento punti
    fuori posto, e adesso la partenza e' il centro della TELA su cui si vola. E il
    primo Sigillo in assoluto si festeggia a schermo pieno e quella scena non se ne
    va da se': aspetta un tocco, e la prova che aspettava dieci secondi accusava il
    volo di un difetto che era una festa in attesa.
  - Anteprima nuova, GUARDATA: `docs/preview/eos-in-volo.png`, colta a meta' corsa,
    perche' e' l'unico fotogramma in cui il volo si vede: all'inizio le scintille
    sono un punto al centro, alla fine sono spente sopra il numero.
- **S.08** I tre pulsanti della celebrazione grande non fanno niente — CHIUSA
  - Il difetto: `condividiIlTraguardo` segnava il traguardo come condiviso e chiedeva
    il bonus al server, e **nessun foglio di sistema si apriva**. Toccando "Condividi
    pubblicamente" non partiva niente verso nessuno: un controllo o e' collegato a
    qualcosa o e' dichiarato inattivo, e non esiste la terza possibilita'. Peggio del
    solito, perche' quei tre pulsanti sono l'unico posto da cui il bonus si incassa:
    finche' non funzionavano il bonus graduato non esisteva per nessuno. E c'era un
    danno in piu' che l'ordine non nomina: **il bonus veniva chiesto per un gesto mai
    avvenuto**, cioe' Eos regalati.
  - **L'ORDINE ADESSO E': si condivide, e solo dopo si incassa.** Se la condivisione
    non parte non si segna niente e non si chiede niente. `false` dalla porta non e'
    solo un guasto: e' anche la persona che ha aperto il foglio di sistema e ha
    cambiato idea, e in quel caso il bonus non e' dovuto.
  - Passa dalla PORTA UNICA della condivisione, quella della voce P.28. Non se ne e'
    scritta una quarta strada.
  - **TRE TESTI, perche' i tre gesti sono tre**, in `TestoDellaCondivisione`: l'invito
    parla a chi non e' ancora nel Cerchio e porta il link, perche' senza link non c'e'
    nessun download da attribuire; il pubblico si legge davanti a estranei e non da'
    del tu a nessuno; il privato e' un messaggio a una persona sola. Il link e' quello
    di `Brand.url`, che e' l'unico posto in cui il dominio vive.
  - Il saldo si applica col numero che il server ha appena detto, e il movimento
    finisce nel registro come "Hai condiviso ...": prima si chiamava `sincronizza`,
    una seconda chiamata che se non risponde lascia il numero vecchio in barra, ed e'
    il difetto della voce S.04.
  - Misura: `test/i_tre_pulsanti_condividono_davvero_test.dart`, quattro prove.
    **Si sostituisce la piattaforma di `share_plus` con una che REGISTRA**: e' l'unico
    punto oltre il quale il gesto lascia l'app, quindi la prova legge il testo esatto
    che sarebbe partito. Una prova che cercasse la porta nel sorgente passerebbe anche
    con un pulsante scollegato. La quarta prova misura il contrario: se la
    condivisione non parte, il bonus non si chiede.
  - Rosso eseguito scollegando UNO dei tre, il pubblico: cade su "toccando «Condividi
    pubblicamente» non e' partito niente".
  - **UN INGANNO DELLA LIBRERIA, e va scritto.** `SharePlus.instance` e' un
    `static final` che cattura la piattaforma al PRIMO accesso: sostituirla a ogni
    prova non ha effetto, e le chiamate continuano ad arrivare al finto della prova
    precedente. Si vedeva bene: la prima delle tre prove passava, le altre due
    trovavano il registro vuoto. Un finto solo per tutto il file, e si azzera.
  - **RESTA UNA COSA DA DECIDERE A MAURO, e non e' codice:** il link dell'invito e'
    `https://esotericircle.app`, il dominio del brand. Se l'invito deve portare a uno
    store o a un link dinamico che attribuisce il download, quel valore e' di Mauro e
    vive in un punto solo, `Brand.url`.
- **S.09** Le celebrazioni si sovrappongono, e il fondo non si oscura — CHIUSA
  - **(a) UNA ALLA VOLTA.** La causa stava nel ciclo della regia: piu' Sigilli
    maturano con lo stesso gesto, e per ognuno si chiedeva la festa senza attendere
    la precedente. La coda esisteva ma serializzava cio' che si ACCODA, non cio' che
    si dipinge. Adesso il conto delle feste a schermo e' uno, `FesteInCorso`, e
    `Celebrazione.festeggia` rifiuta se ce n'e' gia' una: chi chiama la mette in coda,
    che e' quello che fa gia' quando non c'e' dove ospitarla.
  - **IL CONTO SI SEGNA ALLA PORTA, non nello stato del widget.** Un widget si
    costruisce al fotogramma dopo, e il ciclo della regia chiama due volte dentro lo
    stesso fotogramma: segnato in `initState`, la seconda chiamata trovava il conto a
    zero e si dipingeva sopra. Lo ha detto la prova del rosso, non la lettura.
  - **(b) IL FONDO SI OSCURA, e il velo e' un numero solo.** La forma grande aveva la
    sua barriera scritta a mano dentro la rotta, la fascia un gradiente radiale che ai
    bordi finiva TRASPARENTE: due numeri per la stessa promessa, e uno la tradiva.
    Adesso `VeloDellaCelebrazione` dichiara l'opacita' e le due forme la leggono.
  - **E il primo rimedio non bastava, e la misura lo ha detto.** Un `BoxDecoration`
    che porta insieme un colore e un gradiente dipinge il GRADIENTE e ignora il
    colore: il velo messo come colore accanto al bagliore non copriva niente, e nella
    fascia alta il testo di sotto restava al quarantacinque per cento. Adesso sono due
    strati: il velo pieno, e sopra il bagliore che aggiunge luce senza togliere
    copertura.
  - Il velo entra e **si dissolve alla fine**: prima la fascia spariva di colpo, e una
    scena che si spegne a scatto sembra un errore di disegno invece della fine di una
    festa. Con Riduci Movimento non si dissolve niente e si esce subito.
  - **(c) LA CELEBRAZIONE BREVE.** Resta a tutto schermo, breve, e porta gli Eos col
    loro segno. **Difetto trovato guardando l'anteprima**: gli Eos erano scritti DUE
    volte, "+20 Eos" come testo e "+20 Eos" col segno appena sotto. La riga di testo
    porta adesso la SERIE, che e' l'unica cosa che il segno non sa dire.
  - Misura: `test/una_festa_alla_volta_e_il_fondo_si_oscura_test.dart`, tre prove.
    **DUE MISURE BUTTATE PRIMA DI QUESTE, e sta scritto nel file.** La prima contava
    le feste dopo tre `dopoUnGesto`: ogni chiamata guarda l'elenco per conto suo,
    quindi i traguardi maturavano uno per passaggio e due feste non si incontravano
    mai. La seconda segnava sei gesti e chiedeva un solo passaggio: con quei gesti
    matura UN traguardo, verificato stampando il diario. Entrambe restavano verdi
    togliendo il presidio, cioe' passavano per la ragione sbagliata. Adesso si misura
    ALLA PORTA: due `festeggia` di fila, che e' esattamente il ciclo della regia con
    due Sigilli.
  - **LA SOGLIA DEL VELO NON PUO' DERIVARE DAL VELO, e anche questo lo ha detto un
    rosso.** La misura calcolava il massimo ammesso come `1 - opacita`: diluendo il
    velo da 0,92 a 0,35 la soglia si allargava insieme al difetto e la prova restava
    verde col testo perfettamente leggibile. Adesso la soglia e' una soglia di
    LEGGIBILITA' dichiarata, ventiquattro livelli di luce su 255, e la grandezza
    misurata e' un DIFFERENZIALE: la stessa scena col testo e senza, sotto il velo,
    pixel per pixel. Tutto il resto e' identico nelle due, quindi si cancella.
  - **DUE INGANNI DELLA MISURA, scritti nella prova.** Il rettangolo guardato stava al
    centro, dove la festa scrive il PROPRIO testo: si misurava il contrasto della
    celebrazione invece di quello di sotto. E il pixel piu' luminoso era la fascetta
    DEBUG di Flutter, dipinta sopra ogni velo in alto a destra.
  - Rossi eseguiti: togliendo il presidio (cade su "la seconda festa si e' dipinta
    sopra la prima") e diluendo il velo a 0,35 (cade su "del testo di sotto passano
    141.9 livelli di luce su 255").
  - **IL PRESIDIO ERA UN CONTATORE, E UN CONTATORE PERDE.** La prima stesura contava
    chi entra e chi esce: se l'uscita non arriva, e succede quando un albero viene
    buttato senza chiudere la rotta, il conto resta a uno e **nessuna festa si mostra
    piu'**. Lo hanno detto due prove della coda, che chiedevano una festa e non la
    vedevano arrivare. Adesso ogni festa lascia una DOMANDA a cui si sa rispondere,
    "sei ancora a schermo?": la rotta risponde guardando se e' attiva, la fascia con
    una bandiera che si spegne sia al ritiro sia allo smontaggio. Chi non risponde piu'
    di si' esce da se'.
  - E la domanda della fascia non puo' essere `fascia.mounted`: una voce dell'Overlay
    diventa montata al fotogramma DOPO l'inserimento, e il ciclo della regia chiama
    due volte nello stesso fotogramma. Anche questo lo ha detto una prova.
  - **IL VELO E' SALITO A 0,96 GUARDANDO L'ANTEPRIMA**, non misurando: al 92 per cento
    le tre righe del sentiero restavano un fantasma che si leggeva, e la prova non lo
    vedeva perche' la sua soglia lo ammetteva. Le anteprime vedono cio' che le prove
    non cercano.
  - Anteprima nuova, GUARDATA: `docs/preview/celebrazione-breve-col-velo.png`, la
    festa sopra il sentiero, che di testo ne ha molto.
  - **DIFETTO TROVATO E NON CHIUSO, e va detto:** il simbolo al centro della
    celebrazione e' un'icona di serie (`Icons.star_rounded` per la Costellazione,
    `Icons.spa_rounded` per l'Albero, `Icons.local_florist_rounded` per il Loto).
    E' la stessa famiglia della scintilla degli Eos della voce S.05, nel punto piu'
    cerimoniale dell'app, e la precisazione della voce S.02 vieta le icone di serie
    nella figura del sentiero. Tre simboli disegnati a mano sono lavoro a se', della
    stessa mano dei tre disegni: **si propone a Mauro come voce nuova** invece di
    inventarli dentro questa.
- **S.10** Il vuoto sotto i tre Maestri in home — CHIUSA, col residuo dichiarato
  - **PRIMA 176,3 PUNTI, DOPO 158,0**, misurati sulla resa a 360 per 797, fra il
    fondo della riga delle arti del Maestro e la cima del titolo "Le tue arti".
  - **PERCHE' NESSUNA MISURA LO AVEVA VISTO**, e l'ordine lo diceva: il censimento
    degli spazi conta i vuoti SCRITTI, cioe' i `SizedBox` che qualcuno ha messo nel
    codice. Questo vuoto non era scritto da nessuno: nasceva dalla somma di tre cose
    ognuna giusta da sola.
  - **LE TRE COSE, in punti.** L'eroe lascia sotto la zona d'ingresso la propria aria
    (13,3); subito dopo l'eroe c'era un'aria pari all'altezza INTERA della barra
    (134); e lo scaffale portava in cima un distacco da `lg` (24). Le due arie si
    sommavano: adesso quella dopo l'eroe TOGLIE cio' che l'eroe ha gia' lasciato, e il
    distacco dello scaffale scende a `md`.
  - **IL RESIDUO E' L'ALTEZZA DELLA BARRA, e va detto invece di nasconderlo.** Dei 158
    punti, 134 sono l'altezza che la barra si riserva: a riposo la' c'e' la barra, e
    quella non e' fascia morta. Mentre si scorre la barra si ritira, e quei 134 punti
    diventano cielo vuoto: e' cio' che si vede nell'anteprima. Farli seguire lo stato
    della barra vorrebbe dire un contenuto che salta a ogni comparsa della barra, e
    l'ordine M voce 1e ha scartato quella strada di proposito. **Il pavimento vero e'
    dunque l'altezza della barra piu' un distacco di sezione, cioe' 150: siamo a 158,
    e gli otto punti che restano sono la misura dell'aria dell'eroe.** Andare sotto
    quel pavimento e' una decisione di Mauro sulla barra, non un lavoro.
  - **LA BARRA NON SPRECA NIENTE, verificato.** Si riserva 134 punti e ne occupa 136,
    quindi non avanza spazio: il confronto fra la misura dichiarata e la resa esiste
    gia' in `una_barra_sola_test`, con tolleranza dichiarata di due punti. Scriverne
    un secondo con una tolleranza mia sarebbe stata la seconda porta sulla stessa
    misura, e la prova che avevo aggiunto si e' tolta.
  - Misura: `test/il_vuoto_sotto_i_maestri_test.dart`, due prove. La soglia e' DERIVATA
    da `SpazioDellaBarraNelloScroll.quanto` piu' un distacco di sezione. **La prima
    stesura sommava a mano l'altezza della barra a un padding che la conteneva gia'**:
    la soglia saliva a 178 e il vuoto di 176 passava, cioe' la soglia cresceva col
    difetto. E' lo stesso inganno del velo nella voce S.09, ed e' la seconda volta in
    questo ordine.
  - Rosso eseguito rimettendo l'aria doppia: cade dichiarando 168,3 punti.
  - Anteprima nuova, GUARDATA: `docs/preview/home-giuntura-scaffale.png`, la giuntura
    alla larghezza reale. **Difetto della cattura, trovato guardando:** la prima
    versione muoveva `find.byType(Scrollable).first`, che e' la striscia ORIZZONTALE
    dei doni del giorno, e l'immagine restava in cima alla home.
- **S.11** Il Rito del Tramonto: i testi soffocano la runa — CHIUSA
  - Il difetto: le tre righe "Cosa fai", "Perche'" e "Cosa ti resta" stavano SOPRA la
    pietra, nella stessa colonna, fra chi parla e la pietra. Tre etichette con tre
    frasi spingono la pietra in basso, e la schermata si legge come un foglio di
    istruzioni con una runa in mezzo.
  - **LE RIGHE RESTANO E SCENDONO SOTTO LA PIETRA.** La voce P.17 le ha volute e la
    terza e' la sola che produce ritorno: si leggono dopo aver visto la pietra, che e'
    l'ordine in cui una persona guarda una cosa e poi chiede cosa sia.
  - Misura a schermo, alla misura del telefono: **la pietra comincia a 140 punti su
    797 e finisce a 308; le tre righe cominciano a 525.** Prima la pietra cominciava a
    294 e le righe a 140. Due condizioni, non una: il testo sta sotto la pietra, e la
    pietra sta nel primo terzo dello schermo, perche' se cominciasse a meta' la prima
    cosa che si vede sarebbe ancora altro.
  - **IL PRINCIPIO E' TRASVERSALE, e l'ordine chiedeva di guardare gli altri riti.**
    Guardati: dei quattro che montano le tre righe, TRE non avevano il difetto, e la
    ragione e' che il loro livello visivo non sta nella stessa colonna. Alba e Soffio
    mostrano il dono in una SCHEDA che poggia sopra la scena, e il sole sollevato
    occupa i due terzi alti: le tre righe in cima alla scheda vengono comunque dopo.
    Lo stesso per il saluto della notte, che arriva dopo il cielo, e per l'Oracolo,
    dove il disco sta sopra la lettura.
  - Misure: `test/il_livello_visivo_prima_del_testo_nei_riti_test.dart`, tre prove che
    ENUMERANO i riti, piu' la misura a schermo dentro
    `test/l_invito_sta_subito_sotto_la_pietra_test.dart`. La guardia trasversale
    sorveglia l'ordine di dichiarazione solo dove il visivo vive nella STESSA colonna,
    perche' solo li' quell'ordine decide chi si vede prima; per gli altri pretende una
    ragione scritta, e cade se un rito nuovo monta le tre righe senza dichiarare dove
    sta il suo livello visivo.
  - Rosso eseguito rimettendo le righe sopra la pietra: cade dicendo "le tre righe
    cominciano a 140.0 e la pietra finisce a 462.0".
  - Anteprima GUARDATA: `docs/preview/runa-tramonto-voce-uno.png`. Adesso si legge
    barra, la riga di chi parla, la pietra, "Gira la pietra", il nome della runa, e
    solo dopo le tre righe.
- **S.12** L'Oracolo del Giorno dichiara cosa e' e cosa da' — APERTA
- **S.13** Il respiro guidato esce dal Rito dell'Alba — APERTA
- **S.14** L'accesso si apre davvero: Google su Android e su iPhone, Apple su iPhone — APERTA

## Sezione A. La convenzione trasversale del responso

- **S.15** La legge: il responso parte dalla domanda — APERTA
- **S.16** L'anatomia del responso, quattro parti e un ordine — APERTA
- **S.17** Il confine, e non si supera mai — APERTA
- **S.18** Le lunghezze si misurano prima di deciderle — APERTA

## LA DECISIONE DI MAURO SULLA SEZIONE B

Ha priorita' sul testo delle voci S.19, S.20 e S.21, e sta qui perche' e' qui che
si legge lo stato.

1. **RIORDINO AUTORIZZATO: S.21 si esegue PRIMA di S.19 e S.20.** La legge di
   consegna vieta di RINUMERARE e ACCORPARE, non di eseguire in un ordine diverso:
   il manifesto resta questo, cambia la sequenza.
2. **Il determinismo riguarda QUALE RUNA ESCE, non le parole con cui viene
   raccontata.** La decisione di inizio agosto nasceva da un difetto preciso, che
   alla stessa domanda nello stesso giorno Caligo affidava due rune diverse. La
   pietra resta determinata, il testo no.
3. **MODELLO MISTO.** Il presagio della voce S.19 lo COMPONE IL MODELLO da due
   dati: la runa uscita col suo significato dal corpus, e la domanda scelta. E'
   l'unica bolla che deve davvero rispondere ed e' UNA SOLA per gettata, quindi una
   generazione al giorno per utente nel piano gratuito e non quattro. **Ripiego
   deterministico obbligatorio senza rete, e il ripiego non dichiara di essere un
   ripiego: funziona e basta.** Le ventiquattro rune singole della voce S.20
   restano CORPUS, per famiglie di domanda: brevi, dimezzate, ancorate al simbolo,
   e non si scrivono 576 testi.
4. **LE FAMIGLIE DI DOMANDA nascono nella S.21 e sono la chiave anche del corpus
   della S.20.** Poche, cinque o sei. NON si scelgono da soli: l'elenco delle
   famiglie e l'elenco chiuso delle domande si propongono a Mauro PRIMA di scrivere
   un solo testo, perche' da quella scelta dipende quanto corpus va scritto e quel
   corpus e' materiale suo.
5. Il confine della voce S.17 va nelle istruzioni di sistema del presagio, in un
   punto solo, e una prova verifica che l'istruzione sia presente e unica.
6. **LA PROVA CHE IL PRESAGIO RISPONDE misura DUE cose e non una**, perche' testi
   diversi fra loro non bastano: (a) a parita' di runa, due domande diverse danno
   presagi che condividono meno di una soglia dichiarata delle loro parole piene;
   (b) ogni presagio condivide almeno N parole piene con LA SUA domanda. Rosso
   eseguito rimettendo la composizione a hash sulle liste fisse: deve cadere il
   punto b.
7. **La famiglia delle due porte si prende sul serio**: S.15, S.16 e S.17 si
   applicano in TUTTI E DUE i posti per la stessa arte, corpus e istruzioni di
   sistema. Se se ne applica uno solo il registro cambia a meta' schermata e la
   persona lo vede. Una prova enumera le arti a due porte e cade se una delle due
   non ha recepito la legge.
8. **Voce S.04: prima si rende leggibile il fallimento, poi si cerca la causa.**
   Sono due passi e il primo e' una correzione a se', non un mezzo. E' lo stesso
   caso di inizio agosto, quando la causa dell'accesso anonimo era gia' catturata
   in `AppServices.diagnostics` e non la leggeva nessuno.
9. Premessa 4 caduta, accettata: la voce S.10 resta valida e si misura sulla resa.

## Sezione B. Le rune

- **S.19** Il presagio di Caligo e' la prima bolla — APERTA
- **S.20** I responsi delle singole rune scendono alla meta' — APERTA
- **S.21** La domanda prima della gettata: in alto, in tendina, in due famiglie — APERTA
- **S.22** Lo spazio eccessivo dopo i pulsanti del tipo di gettata — APERTA
- **S.23** I pulsanti di scelta della stesa restano dopo il getto — APERTA
- **S.24** La ridondanza nelle schede delle rune — APERTA
- **S.25** Il Sigillo del Giorno non e' piu' uno scarabocchio — APERTA

## Sezione C. Le altre arti, perche' la regola e' trasversale

- **S.26** I tarocchi — APERTA
- **S.27** L'Oroscopo personalizzato — APERTA
- **S.28** I doni quotidiani e la chat dei Maestri — APERTA

## Sezione D. Documenti e consegna

- **S.29** Le Linee Guida recepiscono, e la consegna — APERTA

---

## Le quattro premesse, ABBATTUTE PRIMA DI TOCCARE IL CODICE

Non sono voci e non hanno una riga di stato: sono cio' che va accertato prima di
lavorare, perche' una di loro puo' cambiare l'ordine del lavoro. **Una lo ha
cambiato.**

### 2. LA DOMANDA NON ARRIVA AL TESTO. Verificata per prima, come l'ordine chiede

**Misurata sul codice e con una sonda eseguita**, non ragionata. Il risultato
cambia l'ordine del lavoro della Sezione B.

- `RunePresagio.componi(esito)` **non riceve la domanda affatto**: non e' nella
  firma. Il presagio, cioe' la prima bolla che la voce S.19 vuole risponda alla
  domanda, oggi non puo' rispondere a niente. Con la stessa gettata sono 434
  caratteri identici qualunque cosa la persona abbia chiesto.
- `RuneVoce.voce(runa:, persona:, giorno:, domanda:)` la riceve, ma la usa in due
  modi che NON sono il contenuto: entra nella chiave FNV che pesca l'apertura, il
  ponte e la chiusa da tre liste fisse, e aggiunge UNA frase costante, "Dentro la
  tua domanda, e' qui che guarda."
- La sonda, otto domande diverse sulla stessa runa e lo stesso giorno: otto testi
  distinti, ma la differenza e' solo QUALE variante e' stata pescata. Delle parole
  piene delle otto domande ne ricompare una sola nel testo, "questa", e per
  coincidenza col corpus. **Il contenuto della domanda non tocca il testo.**

**Cosa comporta, ed e' la ragione per cui l'ordine chiedeva di verificarla per
prima.** Il corpus delle rune e' deterministico: un testo scritto a mano non puo'
rispondere a una domanda scritta a mano libera, perche' le combinazioni sono
infinite. Quindi **la voce S.21 viene PRIMA delle voci S.19 e S.20**: solo quando
le domande sono un elenco CHIUSO, la tendina a due famiglie, un corpus puo' avere
una risposta per ogni coppia di domanda e runa. Riscrivere i testi prima di
chiudere l'elenco vorrebbe dire riscriverli due volte.

### 1. DA DOVE VENGONO I TESTI. Accertato file per file

- **Corpus scritto e deterministico**, nessun modello: rune (`runes.dart`,
  `rune_presage.dart`, `rune_voce.dart`, `rune_lore.g.dart`), tarocchi
  (`tarot_reading.dart`), Oroscopo (`horoscope_data.dart` piu' il cielo vero
  calcolato in locale), i cinque doni del giorno.
- **Modello a runtime**, Gemini via `firebase_ai`: **solo** la chat dei Maestri,
  da `lib/features/maestri/chat/maestro_chat_controller.dart`, governata dalle
  istruzioni di sistema di `lib/services/ai/maestro_persona.dart`. E' l'unico
  punto dell'app che chiama il modello.
- **FAMIGLIA DELLE DUE PORTE, e va dichiarata**: l'elemento oracolare e la sua
  prima lettura sono corpus, mentre il SEGUITO che il Maestro scrive sotto e' del
  modello (`seguito_della_lettura.dart`), con un ripiego deterministico quando la
  voce tace (`lettura_di_ripiego.dart`). Quindi le voci S.15, S.16 e S.17 vanno
  applicate in DUE posti per la stessa arte: nel corpus e nelle istruzioni di
  sistema.

### 3. IL SALDO A ZERO: la causa NON e' ancora una sola, e si dice

Cosa e' verificato nei file:

- L'accredito esiste e passa dal server per nome e non per importo,
  `PremioDelTraguardo.accredita` verso la callable `muoviGliEos`.
- La callable **e' distribuita e accetta la causale**: `premio_sigillo` sta in
  `CAUSALI_CHIEDIBILI`, e `VALORE_DEL_PREMIO` porta i valori dei traguardi.
- La borsa si risincronizza **solo se il server ha risposto**
  (`if (saldo != null) await borsa.sincronizza()`).
- **E il `catch` attorno all'accredito non registra niente.** Se l'accredito
  fallisce, nessuno lo sa: ne' la persona, ne' un registro, ne' una prova. E'
  questo che rende la causa illeggibile da fuori, ed e' la prima cosa da
  correggere nella voce S.04, prima di scegliere fra le quattro strade.

Le strade (a) e (b) dell'ordine restano entrambe in piedi; (c) e (d) richiedono un
dispositivo. La voce S.04 parte dal rendere visibile il guasto, non
dall'indovinare quale sia.

### 4. IL VUOTO IN HOME NON E' SCRITTO NEL SORGENTE. La premessa cade

In `santuario_screen.dart` non esiste nessuno spazio scritto di quell'ordine di
grandezza: il blocco eroe distribuisce l'altezza in PROPORZIONE
(`centralH = h * 0.60` col tetto `math.max(220, h * 0.54)`, zona d'ingresso a
`h * 0.02`), quindi il vuoto e' un risultato della resa e non un numero da
cambiare. **Ed e' esattamente il motivo per cui nessuna misura lo aveva visto**:
il censimento degli spazi conta i `SizedBox` senza figlio, cioe' i vuoti scritti.
La voce S.10 si misura sulla resa, come l'ordine prevede.

---

VOCI_TOTALI: 29
VOCI_CHIUSE: 11
VOCI_FERMATE_SU_PREMESSA_FALSA: 0
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0
