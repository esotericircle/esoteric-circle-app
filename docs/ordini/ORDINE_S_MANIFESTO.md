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
  - **CORREZIONE DEL 13 AGOSTO, trovata guardando l'anteprima delle rune.** Col
    borsellino della voce S.06 la barra dell'Estrazione Rune ha tre azioni a destra
    e al titolo restano circa novanta punti: a quattordici, cioe' al minimo
    dichiarato, la parola "Estrazione" ne chiede novantotto, e il motore di testo ha
    fatto l'unica cosa che sa fare, l'ha spezzata. Si leggeva "ESTRAZION / E RUNE",
    ed e' esattamente il difetto che questa voce doveva chiudere.
  - **LA REGOLA DI MAURO HA UN ORDINE, e qui i suoi due articoli si scontravano:**
    prima viene "a capo fra le parole, mai dentro una parola", poi "la misura scende
    fino a entrare, entro un minimo dichiarato". Vince il primo, quindi la misura
    scende di altri due punti fino al pavimento tipografico dell'app, dodici, e non
    un punto sotto.
  - **E SERVIVA ANCHE UN MARGINE, perche' la scatola misurata e quella dipinta non
    coincidono al decimo:** la parola entrava per meno di due punti e si spezzava
    comunque. Il margine dichiarato e' quattro punti, e senza di lui il secondo giro
    da solo non bastava: verificato guardando l'anteprima nei tre stati.
  - **UNA LETTURA SBAGLIATA, e va detta:** a bassa risoluzione ho letto come rotto
    anche lo stato GIA' corretto, e ho aggiunto il margine sopra una diagnosi che
    credevo fallita. Il margine serviva davvero, ma l'ho scoperto ingrandendo
    l'immagine: le anteprime si guardano alla larghezza vera E alla risoluzione
    vera.
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
- **S.12** L'Oracolo del Giorno dichiara cosa e' e cosa da' — CHIUSA
  - **SI E' PRESA LA STRADA (a), come raccomandava l'Architetto:** il disco resta e
    acquista un senso. Buttarlo perche' non era spiegato sarebbe stato risolvere un
    problema di parole togliendo l'unico punto dell'app in cui il cielo reagisce al
    movimento del telefono.
  - Il disco dichiara cosa e': "La ruota del cielo di questo momento, sopra di te: le
    dodici case e i corpi che vi stanno adesso." La didascalia vive nel rito che la
    dichiara, non dentro il guscio: `RitualView` la ospita e resta nulla per i riti il
    cui livello visivo si spiega da se', perche' il sole che si solleva non ha bisogno
    di una didascalia.
  - **E COSA SUCCEDE MUOVENDOLO STA ACCANTO A LUI.** La riga del ripiego tattile
    ("Inclina il telefono, oppure scorri col dito") stava in fondo alla schermata,
    DOPO il responso: adesso e' salita sotto il disco, che e' la casa della frase che
    dice cosa fa muovere una cosa. In fondo non si ripete: una prova conta le
    occorrenze e cade se diventano due.
  - **LA DICHIARAZIONE RESTA DOPO IL GESTO, ed e' li' il difetto vero.** La riga del
    gesto compariva solo PRIMA della rivelazione: dopo il gesto il disco restava li',
    nudo. Una prova che guardasse solo la schermata appena aperta passerebbe col
    difetto in piedi, quindi la misura tocca il disco, aspetta il responso e guarda di
    nuovo.
  - Misura: `test/il_disco_dellOracolo_dice_cosa_e_test.dart`, due prove. Rosso
    eseguito rimettendo la didascalia solo prima della rivelazione: cade su "dopo il
    gesto il disco torna nudo".
  - Anteprima GUARDATA: `docs/preview/oracolo-giorno.png`.
  - **RIDONDANZA VISTA E NON CHIUSA, e va detta:** sotto il disco la riga del ripiego
    dice "Inclini il telefono oppure scorri col dito" e due righe piu' sotto il "Cosa
    fai" del rito dice la stessa cosa con altre parole. Il ripiego tattile e'
    obbligatorio e resta; il testo del "Cosa fai" e' corpus della voce P.17, e
    riscriverlo e' materiale di Mauro. **E' la stessa famiglia della voce S.24**, la
    ridondanza nelle schede delle rune: si propone di trattarla la'.
- **S.13** Il respiro guidato esce dal Rito dell'Alba — CHIUSA
  - Il fatto: la voce P.17 aveva ragione a togliere l'istruzione scritta ("tre dentro
    e tre fuori, sei giri"), che era un compito da contare a mente davanti a una figura
    ferma. Ma il rimedio ha portato il respiro guidato DENTRO ogni dono del giorno: il
    rito del mattino e' diventato il contenitore di un rito che non e' suo.
  - **IL RESPIRO GUIDATO VIVE NEL SOFFIO DEL DESTINO, e in nessun altro rito.** Dalla
    scheda del dono si va al respiro con un INVITO DI UNA RIGA, e la riga e' una porta
    vera: la tocchi e sei nel Soffio. Un invito che non porta da nessuna parte sarebbe
    un vicolo cieco travestito da ponte.
  - Misura: `test/il_respiro_vive_nel_soffio_test.dart`, quattro prove. **La prima
    ENUMERA i montaggi della guida del respiro in tutto `lib` e ammette un solo
    padrone**: la domanda della voce non e' "l'Alba ce l'ha?" ma "chi ce l'ha, e ha il
    diritto di averla?". La quarta monta il Rito dell'Alba vero, compie il gesto,
    **porta il ponte in vista come farebbe un dito** e lo tocca: la scheda del dono e'
    piu' alta dello schermo, e una riga sotto il taglio senza modo di arrivarci non
    sarebbe un ponte.
  - Rosso eseguito scollegando il ponte: cade su "e' un annuncio, e un annuncio che non
    porta da nessuna parte e' un vicolo cieco".
  - **UN DIFETTO DEL BANCO, e sta scritto nella prova:** il tocco spingeva la rotta e
    la rotta cadeva costruendosi, perche' si porta il suo `MaestroScope` e nel banco
    non c'era il Maestro attivo. La prova vedeva un ponte che non apriva niente per un
    difetto suo, non del codice.
  - Anteprima nuova: `docs/preview/alba-ponte-al-soffio.png`. **GUARDATA, e va detto
    che non mostra il ponte:** la scheda del dono e' piu' alta dello schermo e il suo
    scorrimento interno non ha corsa, quindi l'anteprima si ferma dove si fermava
    prima. Il ponte si raggiunge, e lo dimostra la prova che lo porta in vista e lo
    tocca; **che l'anteprima non sappia arrivarci e' un limite del corredo**, non del
    codice, e resta scritto qui.
- **S.14** L'accesso si apre davvero, Google e Apple — CHIUSA
  - **LA CHIUSURA E' NEL PROGETTO, e la verifica a video e' di Mauro** dopo due build
    nuove, una Android e una iOS. Sta scritto qui e nel rapporto, perche' non si da'
    per riuscito cio' che nessuno ha acceso.
  - **CAUSA 1, ANDROID: NON RIAPERTA E NON RITOCCATA.** La ha chiusa Mauro, e il file
    e' escluso dal repository. La prova RIFERISCE cio' che c'e' nell'albero di lavoro:
    `google-services.json` contiene **due oauth_client di tipo 1**, con le impronte
    `5e30c4da2dc6c4f2b0543c62185006cf59ec832d` (release) e
    `6d6a584253758a90cbe02965de44f665fa0db7f7` (debug), che sono esattamente quelle
    dichiarate nell'ordine. La prova cade solo se il file c'e' e NON ha nessun tipo 1,
    cioe' se e' tornato indietro. **Serve una build Android nuova**, perche' il file
    finisce dentro l'archivio e la 2177 porta ancora quello vecchio.
  - **CAUSA 2, IPHONE E GOOGLE: aggiunto lo schema di ritorno.** `ios/Runner/Info.plist`
    non aveva nessun `CFBundleURLTypes`: il giro di accesso apriva Safari e non
    rientrava mai nell'app, cioe' la persona si autenticava e restava fuori. Adesso
    dichiara `com.googleusercontent.apps.425821975933-vq6jtskejop8aibnlrqjs7v15ud66849`,
    che e' il `REVERSED_CLIENT_ID` del `GoogleService-Info.plist`. **Dato portato da
    fuori il repository**, letto sul disco: quel file e' escluso, e la prova lo legge
    se c'e' e cade se i due valori divergono, perche' sono due porte sullo stesso dato.
  - **CAUSA 3, IPHONE E APPLE: creato `ios/Runner/Runner.entitlements`** con
    `com.apple.developer.applesignin` e il valore `Default`. Sul portale la capacita'
    c'era gia' e non bastava: senza questo file non e' dichiarata DENTRO l'app.
  - **AGGANCIATO A TUTTE E TRE LE CONFIGURAZIONI** del bersaglio Runner, non solo a
    Release: una sola configurazione agganciata e' il modo in cui questa cosa funziona
    in TestFlight e non in debug, o viceversa. I due file stanno NEL REPOSITORY, quindi
    valgono sia da Xcode sia con la build in cloud.
  - Misura: `test/l_accesso_si_apre_davvero_test.dart`, tre prove che **girano senza un
    Mac** perche' sono prove sui file. La seconda conta le configurazioni del Runner
    leggendo il progetto Xcode e pretende tanti agganci quante sono: non un numero
    scritto a mano, che invecchierebbe al primo bersaglio nuovo.
  - Rossi eseguiti: togliendo un aggancio (cade dicendo "agganciate a 2 configurazioni
    su 3") e cambiando lo schema di ritorno (cade dicendo "lo schema di ritorno e il
    REVERSED_CLIENT_ID divergono", coi due valori).
  - **QUESTE PROVE NON DICONO CHE L'ACCESSO FUNZIONA SU UN TELEFONO.** Dicono che nel
    progetto c'e' cio' senza cui non puo' funzionare. **La verifica a video la fa Mauro
    dopo le due build nuove, una Android e una iOS**, e qui non si da' per riuscito cio'
    che nessuno ha acceso.
  - **COSA FUNZIONA GIA' ADESSO, e serve per i fondatori:** email e password, e
    l'ingresso anonimo, su tutte e due le piattaforme.
  - Facebook, Instagram e TikTok non entrano in questo ordine, per decisione di Mauro
    del 12 agosto 2026.

## Sezione A. La convenzione trasversale del responso

- **S.15** La legge: il responso parte dalla domanda — CHIUSA
  - **La legge vive in un punto solo, nominata**, in
    `lib/core/responsi/legge_del_responso.dart`: tre articoli e nessuno di piu'. Il
    responso si rivolge alla persona e alla sua domanda, in seconda persona, con
    parole di uso comune; il simbolo entra DOPO, per dire da dove viene la risposta;
    senza domanda si parla alla giornata della persona, mai al simbolo in astratto.
  - **NON E' UN DOCUMENTO, E' UN OGGETTO DEL CODICE**, e questa e' la differenza che
    conta: una raccomandazione scritta in un file di prosa non si puo' interrogare,
    una costante si'. Le istruzioni di sistema dei tre Maestri **leggono** la legge da
    la' invece di riscriverla con parole loro, e una prova pretende che ci sia e che
    compaia UNA volta sola: una regola scritta due volte sono due regole, e divergono
    al primo ritocco.
  - Rosso eseguito togliendo la legge dalle istruzioni: cade su "le istruzioni di
    medora non portano la legge del responso".
  - **RESTA DA FARE, ed e' il lavoro delle Sezioni B e C:** le arti la APPLICANO. La
    legge adesso esiste e arriva al modello; i corpora deterministici delle singole
    arti si riscrivono voce per voce (S.19, S.20, S.26, S.27, S.28), e qui non si e'
    riscritto niente per non farlo di corsa.
- **S.16** L'anatomia del responso, quattro parti e un ordine — CHIUSA
  - Le quattro parti sono nominate nel codice come STRUTTURA, in
    `lib/core/responsi/anatomia_del_responso.dart`: la risposta (2 a 4 righe), cosa
    puoi fare (1 a 2), da dove viene (1 a 2), la tradizione. Ognuna dichiara che
    lavoro fa e quante righe le spettano.
  - **LA QUARTA NON STA NEL RESPONSO**, ed e' il punto che si dimentica: la tradizione
    scende nel pannello delle fonti e del metodo che esiste gia'. Per questo
    `Responso` ha TRE campi e non quattro, e chiedere la tradizione a un responso
    torna vuoto invece di un testo inventato.
  - **L'ORDINE E' LA FORMA DELL'OGGETTO, non una convenzione:** chi ha in mano un
    `Responso` non puo' mettere il simbolo per primo nemmeno volendo. Se ogni arte
    rimettesse in fila le parti per conto suo, in due mesi avremmo quattro ordini
    diversi delle stesse quattro parti e nessuna prova potrebbe dire quale sia quello
    giusto.
  - **LA RETENTION E' SCRITTA ACCANTO AL CODICE**, perche' e' una ragione di prodotto
    e non di stile: un responso che spiega un simbolo si esaurisce quando lo leggi, uno
    che risponde alla tua domanda e ti lascia una cosa da fare produce un ritorno,
    perche' domani vuoi sapere se aveva ragione. `cosaPuoiFare` e' la parte che fa
    tornare.
- **S.17** Il confine, e non si supera mai — CHIUSA
  - Il confine vive in `lib/core/responsi/confine_del_responso.dart` con le due liste
    dichiarate: cosa si puo' (seconda persona, concretezza, un'azione, dire cosa
    osservare o rimandare) e cosa non si puo' mai (annunciare un evento futuro come
    certo, dare indicazioni mediche, legali o finanziarie, parlare di malattia, morte,
    gravidanza, denaro altrui o esiti giudiziari come previsioni).
  - **QUATTROMILASEICENTOCINQUANTA RESPONSI COMPOSTI E GUARDATI, zero violazioni.** Si
    misurano i responsi COMPOSTI e non le costanti del corpus: una previsione certa
    puo' nascere dall'unione di due pezzi innocenti, e guardare i mattoni non la
    vedrebbe.
  - **LA GRANDEZZA MISURATA E' CAMBIATA UNA VOLTA, e la prima misura aveva torto.** La
    prima stesura vietava le radici in assoluto e ha accusato VENTICINQUE responsi
    delle rune per la parola "eredita'": e' il significato tradizionale di **Othala**,
    "l'eredita' e la casa", che non promette niente a nessuno. Una prova che accusa il
    falso insegna a ignorarla. Adesso la regola e' quella dell'ordine, letta alla
    lettera: **un tema delicato e' una violazione quando e' RIVOLTO ALLA PERSONA**, e
    si guarda frase per frase. La previsione data per certa, invece, vale da sola: non
    conta di cosa parla, conta che sia annunciata come certa.
  - **UNA GUARDIA CHE NON HA MAI VISTO UN COLPEVOLE NON E' UNA GUARDIA:** una prova
    mostra al confine le due frasi che l'ordine porta come esempio, quella ammessa
    ("questa runa ti chiede di rimandare la decisione di qualche giorno") e quella
    vietata ("nei prossimi giorni perderai il lavoro"), e pretende che le distingua.
  - Per i testi del modello la stessa regola arriva dalle istruzioni di sistema,
    LETTA dal punto unico: la riga che diceva la stessa cosa con parole sue e' stata
    sostituita, perche' due copie divergono al primo ritocco e da quel momento il
    corpus e il modello obbediscono a due confini diversi.
  - Il disclaimer e' quello GIA' in uso, `ArtCatalog.disclaimerCornice`: il confine
    dichiara dove vive e non ne scrive un secondo, e una prova cade se se lo scrive.
  - Misura: `test/il_confine_del_responso_test.dart`, cinque prove. Rossi eseguiti:
    togliendo il futuro in seconda persona dalle forme della previsione (cade su "il
    confine non riconosce «perderai»") e togliendo la legge dalle istruzioni.
- **S.18** Le lunghezze si misurano prima di deciderle — CHIUSA
  - **LA TABELLA C'E', ed e' generata**: `docs/responsi/lunghezze.md`, prodotta dalla
    prova `test/le_lunghezze_dei_responsi_test.dart` e rigenerabile con
    `--dart-define=AGGIORNA_LUNGHEZZE=1`. Senza il comando la prova la CONFRONTA e
    cade se il documento e i corpora si sono allontanati: un documento che nessuno
    rigenera mostra uno stato vecchio, ed e' peggio di nessun documento.
  - **SI MISURANO I RESPONSI COMPOSTI, non le stringhe del sorgente:** un corpus e'
    fatto di pezzi che si uniscono a runtime, e contare i caratteri delle costanti
    direbbe quanto e' lungo un mattone, non quanto e' lungo il muro.
  - La battuta e' DICHIARATA: dove il corpus e' finito si percorre intero (le quattro
    forme della gettata, i sedici argomenti, i dodici segni), dove il testo varia col
    giorno si percorre un anno intero, e le gettate si ripetono su duecento semi.
  - **COSA DICE LA MISURA, in caratteri (mediana e massimo).** Rune, presagio: telo
    737 e 760, croce 536 e 568, norne 427 e 447, odino 316 e 327. Tarocchi: consiglio
    541 e 696, posizione 196 e 325, domanda 52 e 73, sintesi 22 e 28. Oroscopo, le
    quattro schede: fra 167 e 194 di mediana, massimo 210. Oracolo del Giorno 73 e 76.
    Rito del Sogno 68 e 74. Rito dell'Alba 75 e 76.
  - **NESSUN TETTO ESISTENTE TAGLIA NIENTE, verificato:** una prova confronta i quattro
    tetti della stesa con i massimi misurati e cade se un tetto sta sotto. Un tetto
    sotto il massimo vero e' un troncamento che aspetta il giorno giusto, e un testo
    tagliato e' un testo non scritto: e' gia' costato una voce nell'ordine P.
  - **I TETTI NUOVI NASCERANNO DA QUESTA TABELLA**, nelle voci che chiedono di
    accorciare (S.20, S.22, S.26), e vivranno nel blocco unico delle costanti. Qui non
    si e' accorciato niente, perche' l'ordine chiede la misura PRIMA della decisione.

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

## LA DECISIONE D5 DI MAURO, 13 agosto 2026, sulla voce S.19 e sul punto 6

Nasce dal rapporto in cui ho dichiarato la S.19 chiusa senza aver riletto la
decisione sulla Sezione B, e da una domanda che avevo posto male.

1. **LA MISURA (a) SI RICLASSIFICA, e non e' mai stata una prova.** A parita' di
   runa, due domande diverse devono dare presagi che condividono meno di una
   soglia dichiarata delle parole piene: e' una MISURA eseguita una volta contro
   il modello vero e riportata col numero nel rapporto, come l'attribuzione cieca
   delle tre voci dei Maestri, che sta al 98,3 per cento e non e' mai stata una
   guardia verde. **Non si dichiara "non misurabile offline": si dichiara come
   misura, e si esegue quando il modello e' agganciato.** L'errore era mio, e
   stava nel confondere le due cose.
2. **LA MISURA (b) RESTA UNA PROVA DELLA SUITE**, e deve mordere anche sul
   ripiego: ogni presagio condivide almeno N parole piene con LA SUA domanda.
3. **IL MODELLO SI AGGANCIA AL PRESAGIO**, come da decisione D3: metodo nuovo sul
   confine `MaestroAiProvider`, il confine della voce S.17 nelle istruzioni di
   sistema in un punto solo, e il ripiego che non si dichiara MAI come ripiego.
4. **LE SEDICI CORNICI DEL RIPIEGO LE SCRIVE L'ARCHITETTO** e arrivano come
   allegato: una per domanda, otto generiche e otto personali, e **NON variano per
   runa**. La runa continua a portare la sua frase di corpus, la cornice porta la
   domanda: e' per questo che non sono 576. Ogni cornice apre nominando l'area
   della domanda con le parole della persona e non con quelle del simbolo, e
   lascia il posto in cui la frase della runa si innesta. Nessun nome di runa
   dentro la cornice.
5. **LA S.19 SI CHIUDE QUANDO LE CORNICI ARRIVANO.** Nel frattempo non si aspetta:
   si prosegue con S.22, S.23, S.24 e S.25, che sono difetti visivi delle rune e
   non chiedono decisioni.
6. **LE ANTEPRIME DELLE VOCI GIA' CHIUSE SI RIGENERANO E SI RIGUARDANO**, perche'
   erano state giudicate quando il responso non si dipingeva. Un giudizio a video
   dato su un'immagine vuota non e' un giudizio, e non si sa quante voci ne siano
   state toccate: il rapporto dichiara quali si sono riguardate e se qualcuna
   cambia esito.

### Il punto 6 eseguito: le anteprime giudicate su immagini incomplete

**LO STRUMENTO.** Non si poteva sapere a occhio quali anteprime fossero
incomplete, quindi si e' costruita una misura: l'interruttore
`--dart-define=ANTEPRIME_LENTE=true` da' a ogni scatto otto frame invece di uno e
scrive in `build/preview_lento`. Poi si confronta l'INCHIOSTRO delle due
versioni, cioe' quanti pixel chiari porta l'immagine: le stelle del fondale si
muovono fra i due scatti e non cambiano il conto, ma un contenuto dipinto a
opacita' zero lo cambia di molto. Il primo tentativo, il confronto byte a byte,
aveva risposto 120 immagini diverse su 161, cioe' non aveva risposto niente.

**LA CAUSA VERA, e non era ScrollReveal.** Ventisei anteprime su 161 mostravano
inchiostro diverso oltre il cinque per cento. Guardandole: il difetto sta nel
CAMBIO DI MISURA DELLO SCHERMO. `montaLoSchermo` allarga la finestra e cio' che
stava sotto la piega adesso ci sta dentro, ma i figli nuovi di una lista pigra non
nascono nel frame in cui la finestra cresce. Un frame non basta, tre si': ora
l'attesa sta dentro `montaLoSchermo`, che e' il punto unico attraversato da tutti
e cinquanta i punti che cambiano misura.

**COSA ERA DAVVERO ROTTO, con i numeri:**
- `piani.png`, la schermata dei Piani: **due livelli su quattro non c'erano**,
  l'Iniziato e l'Adepto, cioe' i piani che si pagano. Inchiostro 8.266 con un
  frame, 27.027 con tre.
- `dominio-medora.png`, `dominio-aura.png`, `dominio-caligo.png`: rapporti 1,41,
  1,28 e 1,26. Le arti in fondo al dominio non si dipingevano.

**E UNA RIPARAZIONE DI CONTORNO, che vale per l'app e non per il corredo.**
`ScrollReveal` aveva UNA sola occasione per far partire la comparsa, il postFrame
di `didChangeDependencies`: se in quel frame la scatola non aveva ancora
geometria, l'elemento restava dipinto a opacita' zero e lo salvava solo il primo
scorrimento, che e' un gesto che la persona potrebbe non fare. Adesso riprova per
dieci frame, e il numero e' dichiarato con la sua ragione.

**LE ALTRE VENTISEI DIFFERENZE SONO MOMENTI SCELTI, non difetti**, e due si sono
guardate per esserne sicuri: `rito-sogno-costellazione.png` col giro lento mostra
il rito ANDATO AVANTI, cioe' il dono e il saluto di Caligo invece dell'istante in
cui la figura si unisce, che e' quello che l'anteprima vuole; `santuario-medora.png`
col giro lento mostra in piu' l'invito "Tocca il cielo", che compare in ritardo di
proposito. Nella lista stanno anche `consulto-simbolo-inizio` (15,04),
`guide-animale-rivelazione` (5,12), `stesa-attesa-di-medora` (4,65),
`barra-meta-corsa`, `barra-home-fuori`, `eos-in-volo` e
`barra-assente-in-immersiva`: portano nel nome il momento che scelgono.

**LE VOCI GIA' CHIUSE, e se cambia esito.** NON compaiono nella lista, quindi il
giudizio a video su di esse resta valido: i tre disegni del sentiero (S.01, S.02,
S.03), il borsellino e il portafoglio (S.06), gli Eos in volo (S.07), i tre
pulsanti della condivisione (S.08), la celebrazione col velo (S.09), la pietra del
Tramonto (S.11), il disco dell'Oracolo (S.12), il respiro (S.13) e tutte le rune
(S.19, S.20, S.21). **Cambia invece il quadro della voce S.10**, il vuoto sotto i
Maestri: le sue tre anteprime del dominio erano incomplete. La MISURA della S.10
non ne dipende, perche' era presa sulla resa dentro una prova e non sull'immagine,
ma il giudizio a video era dato su un'immagine mutila: riguardata adesso, il
dominio si legge intero, ritratto, arti vive e "Altre arti in arrivo" col suo
chevron. L'esito della S.10 non cambia.

**UNA CATTURA CADE COL GIRO LENTO, e va detto:** "Cattura le quattro fasi del
taglio". Le quattro fasi sono momenti di un'animazione, e dando piu' tempo la
scena passa alla fase dopo: e' la conferma che il giro lento e' uno strumento di
diagnosi e non una regola da applicare a tutti gli scatti.

## Sezione B. Le rune

- **S.19** Il presagio di Caligo e' la prima bolla — APERTA
  - **DICHIARATA CHIUSA E RIAPERTA NELLO STESSO GIORNO, e la ragione va scritta.**
    Il quarto stato aspettava la decisione D4, la D4 e' arrivata, il testo e' stato
    riscritto secondo l'anatomia e ho scritto CHIUSA. **Non lo era:** la decisione
    di Mauro sulla Sezione B, che sta piu' sopra in questo stesso documento, chiede
    per questa voce tre cose che non erano fatte, e non le avevo rilette prima di
    dichiarare. Sono il punto 3 (modello misto), il punto 5 (il confine nelle
    istruzioni di sistema) e il punto 6 (la prova a due misure). **Meglio una riga
    che dice di essersi sbagliata che un marcatore che conta una voce finita.**
  - **QUEL CHE E' FATTO, verificato:** la posizione, l'anatomia, il ripiego
    deterministico che risponde alla domanda, e le anteprime guardate.
  - **LE SEDICI CORNICI SONO ARRIVATE il 13 agosto 2026**, allegato B, e sono
    montate: vivono in `lib/core/domande/cornici_del_presagio.dart` VERBATIM,
    accostate alla domanda per TESTO ESATTO e non per posizione. Il montaggio e'
    quello dell'allegato: apertura della cornice, la frase della runa dal corpus
    che non si tocca, chiusura della cornice, poi la riga che nomina la runa e il
    verso. Le nove indicazioni per famiglia restano a chi getta senza domanda.
  - **MISURA (b) ESEGUITA E VERDE**, in `test/le_sedici_cornici_test.dart`, sette
    prove: ogni domanda ha la sua cornice e ogni cornice la sua domanda nei due
    versi, nessuna cornice nomina una runa, il montaggio e' quello dichiarato, il
    ripiego senza cornice parla alla giornata e non usa mai una delle sedici.
    **Il minimo misurato di parole piene condivise fra presagio e sua domanda e'
    UNO**, con soglia dichiarata uno.
  - **LA SOGLIA DELLA (b) L'AVEVO DICHIARATA DUE, e l'ho abbassata a uno scrivendo
    perche'.** Due era un principio inventato a tavolino; la misura ha risposto che
    cinque cornici su sedici condividono una sola parola piena, e quella parola e'
    il NOME DELL'AREA (momento, amore, insistere, Ascendente), cioe' esattamente
    cio' che il vincolo 2 dell'allegato chiede. Il conto e' per token esatti e non
    conosce le forme: "mostro" della domanda e "mostri" della cornice sono due
    parole diverse per la prova. Pretenderne due vorrebbe dire pretendere che la
    cornice ripeta la domanda.
  - **UNA CORNICE NON PASSA LA (b), ed e' la G8**, "Cosa non sto guardando di me?":
    zero parole piene condivise. La deroga sta scritta nella prova col suo nome,
    perche' la cornice e' materiale dell'Architetto e Code non la riformula. Bastava
    togliere "cosa" dalle parole vuote per farla passare a uno: sarebbe stato
    allargare la soglia attorno al difetto. **Chiesta a Mauro una G8 che nomini la
    sua area.**
  - **UNDICI TESTI SU TRENTADUE CONTENGONO VIRGOLA PIU' "E"**, per esempio "Chiede
    una cosa sola, e le pietre indicano quale". Sono due regole di Mauro che si
    scontrano, verbatim contro la regola della virgola, e ha vinto la piu'
    specifica: la deroga vale per quel file e per nessun altro, sta scritta in
    `test/language_rule_test.dart`, **e il trattino lungo NON e' in deroga**, con
    una prova a parte che lo guarda anche la' dentro.
  - **PUNTO 5 DELLA D5, il confine nelle istruzioni di sistema: era gia' vero e non
    lo presidiava nessuno.** Il confine della voce S.17 arriva al modello da quando
    la S.17 lo ha messo in `_commonRules`, che e' la porta unica di tutte le
    istruzioni; la riga del manifesto che diceva "non e' ancora agganciato a
    nessuna istruzione" era sbagliata. Adesso c'e' la prova che pretende che ci sia
    e che ci sia UNA volta sola, e **al primo giro ha preso me**: scrivendola avevo
    aggiunto una seconda copia del confine poche righe sopra la prima.
  - **QUEL CHE MANCA, dalla decisione di Mauro sulla Sezione B:**
    - **Punto 3, MODELLO MISTO.** Il presagio lo deve COMPORRE IL MODELLO da due
      dati, la runa uscita col suo significato dal corpus e la domanda scelta. E'
      l'unica bolla che deve davvero rispondere ed e' una sola per gettata, quindi
      una generazione al giorno per utente nel piano gratuito. Cio' che c'e' ora e'
      soltanto il RIPIEGO, che l'ordine pretende comunque e che non dichiara di
      essere un ripiego: funziona e basta.
    - ~~Punto 5, il confine nelle istruzioni di sistema~~: FATTO, vedi sopra.
    - **Punto 6, la misura (b): FATTA e verde.** La misura (a) resta da eseguire
      contro il modello vero, e si esegue quando il modello e' agganciato: la
      decisione D5 la riclassifica come misura da riportare col numero, non come
      guardia della suite.
    - **LA DICIASSETTESIMA CORNICE, quella della giornata.** L'allegato vieta di
      usare una delle sedici per chi non sceglie una domanda, perche' direbbe alla
      persona che ha chiesto una cosa che non ha chiesto, e dichiara che quella
      cornice la scrive l'Architetto. Ci sono arrivato: il ripiego senza domanda
      esiste e apre con una riga PROVVISORIA scritta da me, dichiarata provvisoria
      nel codice. Chiesta a Mauro.
  - **IL PRESAGIO E' SALITO IN CIMA.** Stava in fondo, dopo le rune una per una: la
    persona leggeva tre frammenti e doveva montarli da sola, e la lettura che li
    tiene insieme arrivava quando aveva gia' finito di interpretare. Adesso e' la
    prima cosa che si legge dopo la gettata, e le rune singole vengono dopo, come
    dettaglio di cio' che il presagio ha gia' detto.
  - **LA SUA LUNGHEZZA NON SI TOCCA, e la prova e' un presidio AL CONTRARIO.** Tutte
    le altre prove della sezione difendono un tetto; questa difende un pavimento,
    perche' l'ordine dichiara che la lunghezza del presagio e' l'unica gia' giusta.
    Il pavimento e' il tetto delle rune brevi per tre: se un presagio scendesse
    sotto, vorrebbe dire che qualcuno lo ha uniformato alle bolle brevi.
  - **IL TESTO HA PRESO LA FORMA DELL'ANATOMIA della voce S.16.** Era un paragrafo
    unico che apriva col nome della gettata e poi nominava una runa per posizione:
    **il simbolo veniva PRIMA della risposta**, cioe' chiedeva alla persona di
    sapere cosa vuol dire Perthro prima di ricevere qualcosa, e dopo averlo letto
    non c'era niente da fare. Adesso e' un `Responso` a tre parti: la risposta, che
    tiene le posizioni e NON nomina nessuna runa; cosa puoi fare; da dove viene, ed
    e' la' che le rune compaiono coi loro versi.
  - **E RISPONDE ALLA DOMANDA POSTA**, che e' la parte che aspettava: con una
    domanda il presagio apre dicendo che a quella sta rispondendo, senza domanda
    parla alla giornata. **La domanda non si ricopia dentro**, perche' sta gia' a
    schermo nella sua scatola subito sopra, e perche' una domanda scritta dalla
    persona puo' contenere qualunque cosa: ricopiarla farebbe entrare nel responso
    del testo che non e' nostro.
  - **NOVE COSE DA FARE, non una:** tre famiglie di rune per tre equilibri di luce e
    ombra. La famiglia dice di che cosa si tratta, l'equilibrio con quanta cautela.
    Una sola indicazione per tutte le gettate si riconoscerebbe alla seconda
    lettura e smetterebbe di essere un consiglio.
  - **LE TRE PARTI SI VEDONO A SCHERMO**, e non e' decorazione: in un paragrafo
    unico la cosa da fare si perde in mezzo, ed e' la parte che fa tornare. La
    risposta passa dai paragrafi di lettura, cosa puoi fare ha la sua cornice, da
    dove viene sta in didascalia secondaria.
  - Misure: `test/il_presagio_e_la_prima_bolla_test.dart`, due prove sulla posizione
    e sul pavimento; `test/il_presagio_risponde_alla_domanda_test.dart`, sette
    prove che ENUMERANO le quattro gettate per sessanta semi: il responso e' intero,
    nessun nome di runa compare nelle prime due parti, la terza li nomina TUTTI (il
    presidio opposto, perche' togliere il simbolo dall'inizio non vuol dire
    buttarlo), la domanda cambia il testo, la domanda non si ricopia, ogni cosa da
    fare dichiara un QUANDO e non e' una formula vuota, la tradizione resta fuori.
    Piu' una prova a schermo in
    `test/la_domanda_scelta_arriva_al_responso_test.dart`, che pretende dal
    presagio la riga della domanda: la scatola sopra la lettura dimostrava solo che
    la domanda era arrivata, non che il presagio l'avesse usata.
  - **PROVA DEL ROSSO fatta:** togliendo al presagio la distinzione fra domanda e
    giornata la prova e' caduta sola, con la gettata nel messaggio. Rimessa a
    posto, sette verdi.
  - **TRE DIFETTI DI CUCITURA trovati dalle prove e uno guardando l'anteprima.** La
    riga del corpus comincia con la maiuscola perche' nata per stare da sola, e
    dopo "Per cio' che fu," si leggeva "Per cio' che fu, Una luce si accende": ora
    scende in minuscola. L'apertura chiudeva la frase col punto e "Da dove viene:"
    ne aggiungeva un secondo. E "Da dove viene: Le tre Norne" aveva la maiuscola
    dopo i due punti: **minuscolizzarla era impossibile**, perche' "odino ha
    parlato" e' peggio della maiuscola, quindi la frase e' scritta per il posto che
    occupa e la vecchia apertura non serve piu' a nessuno. Tre indicazioni su nove
    non dichiaravano un quando, e la prova le ha nominate una per una.
  - GUARDATA l'anteprima `rune-norne.png` alla larghezza reale e alla risoluzione
    vera: il presagio e' la prima bolla, apre senza nomi di runa, la cosa da fare
    sta nella sua cornice, i nomi con i versi arrivano in fondo. E guardata
    `rune-getto.png`, che ha trovato la litania delle glosse.
- **S.20** I responsi delle singole rune scendono alla meta' — CHIUSA
  - **IL TETTO VIENE DALLA MISURA: 55 caratteri.** La mediana misurata alla voce
    S.18 era 106 per il verso dritto e 111 per quello d'ombra: si prende la meta'
    della piu' alta, arrotondata PER DIFETTO, e vale per entrambi i versi. Un tetto
    per verso sarebbero due regole sullo stesso tipo di testo, e la prima volta che
    una runa le sfiora entrambe nessuno saprebbe quale vale. Vive in
    `lib/core/responsi/tetti_dei_responsi.dart`, non nel punto di chiamata.
  - **QUARANTOTTO TESTI RISCRITTI, non tagliati.** Nella forma breve resta la
    risposta, cioe' cio' che la runa dice a te, e cade la descrizione del simbolo,
    che vive nel campo `meaning` della runa, nella sua scheda e nel pannello delle
    fonti. Dopo la riscrittura la mediana e' 43 per il dritto e 44 per l'ombra, col
    massimo a 51 e 52.
  - Esempio, per far vedere cosa e' caduto e cosa e' restato. Prima: "L'abbondanza
    che scorre. Beni ed energia che circolano: non da trattenere, ma da far muovere
    perche' fruttino." Dopo: "Fai muovere cio' che hai: fermo si consuma."
  - Misura: `test/i_responsi_delle_rune_sono_brevi_test.dart`, quattro prove.
    ENUMERA le ventiquattro rune nei due versi e cade col nome della runa se una
    supera il tetto o se una e' vuota; una seconda prova pretende che la descrizione
    del simbolo NON sia caduta nel nulla, perche' senza di lei avremmo accorciato
    buttando; una terza passa i quarantotto testi dal confine della voce S.17.
  - **LA META' SI ARROTONDA PER DIFETTO**, e la prima stesura della prova
    arrotondava al piu' vicino: 111 mezzi fanno 55,5, e un tetto che arrotonda per
    eccesso si concede mezzo carattere senza una ragione.
- **S.21** La domanda prima della gettata: in alto, in tendina, in due famiglie — CHIUSA
  - **LA DECISIONE D4 DI MAURO, presa il 13 agosto 2026, in tre punti.** Uno:
    l'elenco unico delle domande vive in un PUNTO NUOVO IN CORE, e le chat vi
    attingono. Due: le PERSONALI nascono da CARTA E CAMMINO insieme, e una domanda
    il cui dato manca non si mostra. Tre: OTTO E OTTO, otto generiche e otto
    personali.
  - **IL PUNTO UNICO E' `lib/core/domande/domande_del_cerchio.dart`.** Prima le
    domande proposte stavano in DUE case: cinque in `kRuneDomandeSuggerite` dentro
    `rune_cast.dart` e sessanta nella vista dei suggerimenti della chat. Due
    elenchi della stessa cosa sono due elenchi da tenere d'accordo a mano, e
    nessuna prova poteva dire quale fosse quello giusto. Ora
    `SuggestionSets` e' una VISTA sul punto unico, e la costante vecchia si e'
    ritirata lasciando al suo posto la riga che dice dove sono andate le domande.
  - **LE SESSANTA DELLA CHAT SI SONO SPOSTATE PAROLA PER PAROLA, nello stesso
    ordine.** Questa voce sposta la loro casa, non le riscrive: riscriverle era un
    altro lavoro, e mescolarlo a questo avrebbe reso impossibile dire quale delle
    due cose ha rotto qualcosa. Le cinque della gettata sono diventate le prime
    cinque generiche, anche loro parola per parola, con tre di sblocco in aggiunta.
  - **LA DOMANDA E' SALITA SOPRA IL PULSANTE.** Stava sotto il getto, cioe' dopo:
    si gettava e poi si trovava il campo di una domanda che non aveva piu' modo di
    entrare nella gettata. Adesso si pone prima, e la lettura ne tiene conto (il
    seme della gettata e l'eco dentro la voce della runa la usavano gia', ma
    nessuno poteva scriverla in tempo).
  - **UNA TENDINA, NON DUE ELENCHI APERTI.** Sopra il pulsante lo spazio e' quello
    che e': sedici voci in chiaro avrebbero spinto il getto sotto la piega, cioe'
    avrebbero rifatto il difetto che questa voce chiude. Il menu porta le due
    famiglie come sezioni, coi nomi che la chat mostra da sempre, e sotto resta il
    campo libero per chi la vuole scrivere con parole sue.
  - **LE PERSONALI CHE NON HANNO IL LORO DATO NON COMPAIONO**, e ognuna dichiara
    quale dato la regge. Nella schermata delle rune arrivano il segno, il Sole
    quando c'e' la data di nascita, la runa di ieri sera e la parola di stamattina
    dal filo fra i riti: **Luna, Ascendente, animale guida e archetipo non sono
    ancora agganciati**, perche' questa schermata non riceve la carta natale ne' il
    risultato del Test, e passarli qui e' un lavoro che si fa quando le loro voci
    servono. Meglio quattro voci in meno che quattro voci che nominano cio' che
    l'app non sa.
  - **LA DOMANDA NON DIVENTA UN PEDAGGIO.** Spostarla sopra il pulsante la mette
    sulla strada del getto, ed e' il punto esatto in cui una schermata comincia a
    pretendere qualcosa prima di funzionare. La riga a schermo lo dichiara, "Puoi
    anche gettare senza domanda", e una prova getta senza domanda e pretende il
    responso.
  - Misura: `test/la_domanda_scelta_arriva_al_responso_test.dart`, sei prove. La
    prima scegli una domanda dalla tendina, getta, e pretende di RITROVARE quel
    TESTO dentro il responso: non la presenza della scatola, che passerebbe anche
    vuota. Una seconda getta senza domanda. Una terza guarda l'ordine di
    dichiarazione, tendina e campo sopra il pulsante. Una quarta e' il PRESIDIO DEL
    PUNTO UNICO: enumera i file di `lib` e cade se tre o piu' testi di domanda
    rinascono in un file che non e' la loro casa.
  - **PROVA DEL ROSSO fatta:** azzerata la domanda passata al responso, la prima
    prova e' caduta sola, le altre cinque sono restate verdi. Rimessa a posto,
    sei verdi.
  - **UNA MISURA SBAGLIATA, buttata e non aggiustata.** La prova dell'ordine
    cercava `Key('rune_tendina_domande')`, che vive DENTRO il widget della tendina,
    in fondo al file: cadeva dicendo che la domanda sta sotto il pulsante mentre a
    schermo stava sopra. Si e' cambiata la grandezza misurata, il punto di
    CHIAMATA, non la soglia.
  - GUARDATA l'anteprima `rune-soglia.png` alla larghezza reale: etichetta, tendina
    chiusa, campo libero e riga del "senza domanda" stanno sopra il pulsante, e il
    getto e' ancora sopra la piega.
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
VOCI_CHIUSE: 20
VOCI_FERMATE_SU_PREMESSA_FALSA: 0
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0
