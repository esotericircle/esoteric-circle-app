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
- **S.05** Gli Eos hanno un nome e una loro icona — APERTA
- **S.06** Il borsellino e' sempre visibile — APERTA
- **S.07** Gli Eos volano dalla celebrazione al borsellino — APERTA
- **S.08** I tre pulsanti della celebrazione grande non fanno niente — APERTA
- **S.09** Le celebrazioni si sovrappongono, e il fondo non si oscura — APERTA
- **S.10** Il vuoto sotto i tre Maestri in home — APERTA
- **S.11** Il Rito del Tramonto: i testi soffocano la runa — APERTA
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
VOCI_CHIUSE: 4
VOCI_FERMATE_SU_PREMESSA_FALSA: 0
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0
