# ORDINE U. UN TRAGUARDO, UNA FESTA

Tre voci. Nessuna consegna in fondo: la build si fa una volta sola alla fine
della serie di ordini, ed e' una deroga dichiarata.

Deroga dichiarata anche alla regola delle due voci per ordine: la U.00 non e'
un terzo oggetto ma una precondizione, perche' una suite che cambia colore col
giorno rende sporca qualunque misura presa dalle altre due.

## Come si legge questo file

Una riga per voce, con lo stato in fondo. I quattro stati terminali ammessi
sono CHIUSA, FERMATA SU PREMESSA FALSA, FERMATA IN ATTESA DI DECISIONE e
APERTA. Finche' una riga e' APERTA la guardia `test/ordine_u_guard_test.dart`
resta rossa. I marcatori si contano sulle righe, non si scrivono a memoria.

## Le premesse, abbattute prima di toccare il codice

Tutte e cinque reggono, e le due che chiedevano una misura la portano.

1. **VERA, tutte e due le meta'.** Le tre prove di
   `la_festa_arriva_sempre_test.dart` falliscono anche al commit `e0b7c39`,
   cioe' prima dell'ordine T, e questo l'avevo gia' misurato. **La dipendenza
   dal cielo l'avevo ipotizzata e adesso e' provata:** una `gettata` sola accende
   il traguardo `cal_6` e nient'altro, e lo accende **solo quando il cielo del
   giorno porta `luna_nuova`**. Misurato su quattro giorni: 13 agosto un
   traguardo, 14 agosto un traguardo, 15 agosto **zero**, 16 agosto zero. La
   finestra si chiude fra il 14 e il 15, ed e' esattamente il giorno in cui le
   tre prove hanno cambiato colore.
2. **VERA, e il censimento e' completo.** I traguardi che compaiono in piu' di un
   sentiero sono **tre**, e ognuno compare in tutti e tre: la carta natale
   (`med_1`, `cal_1`, `aur_1`, posizione 1), l'Angelo Custode (`med_2`, `cal_2`,
   `aur_2`, posizione 2), l'Animale Guida (`med_3`, `cal_3`, `aur_3`, posizione
   3). Sono i tre gia' dichiarati in `Sentieri.agganciTrasversali`.
3. **VERA.** Le celebrazioni sono due: `CelebrazioneAScermoPieno`, per i grandi e
   per il primissimo Sigillo, e `_FasciaDellaCelebrazione` per i mini. La forma e
   la direzione non cambiano da un Maestro all'altro, cambia solo la palette.
4. **VERA.** La voce P.34 e' viva: `Celebrazione.festeggia` torna vero solo se la
   festa e' comparsa davvero, e quando non c'e' dove ospitarla la festa entra in
   `CodaDelleFeste` invece di perdersi.
5. **VERA.** Il Quality Tier e' `QualityTierController`, con `richEffects` che
   dice se gli effetti pesanti sono attivi; Riduci Movimento si riversa su
   `MediaQuery.disableAnimations` in `lib/app.dart`.

## Le voci

- **U.00** Una prova che legge il cielo dichiara il suo istante — CHIUSA
  - **IL CENSIMENTO, per enumerazione e non a occhio: quattordici prove
    pescavano dall'orologio.** Dodici costruivano `DiarioDelCammino()` senza
    orologio, e da li' passava il cielo del giorno; due chiamavano `DateTime.now`
    direttamente.
  - **LA CORREZIONE: l'istante si dichiara in un punto solo**,
    `test/istante_dichiarato.dart`, ed e' il **14 agosto 2026 a mezzogiorno**.
    **Non e' il giorno che fa passare le prove: e' un giorno in cui c'e'
    qualcosa da vedere.** Una prova che sorveglia la festa ha bisogno che un
    traguardo si accenda, e sceglierne uno in cui non si accende niente vorrebbe
    dire sorvegliare il nulla. Dodici file corretti.
  - **LE TRE PROVE DELLA FESTA SONO VERDI con un istante dichiarato**, e non per
    aver cambiato cio' che sorvegliano.
  - **LA GUARDIA CHIUDE LA FAMIGLIA invece di ripulirla una volta sola**, ed e' la
    differenza fra un filtro e un vincolo: `test/una_prova_dichiara_il_suo_istante_test.dart`
    enumera i file di prova e cade se uno costruisce il Diario senza orologio o
    chiama `DateTime.now` senza essere dichiarato. Tre file sono dichiarati e
    accanto a ognuno sta scritto **cosa sorveglia**, non solo che e' esentato; una
    terza riga pretende che le dichiarazioni siano vive, cioe' che il file esista
    ancora e che la ragione sia una ragione. **La guardia non guarda se stessa**,
    perche' porta nei suoi messaggi le parole che cerca.
  - **ROSSO ESEGUITO, con l'iniezione VERIFICATA prima di leggere l'esito:**
    rimesso un `DiarioDelCammino()` nudo dentro `il_sentiero_si_legge_test.dart`,
    verificato che fosse davvero entrato, la guardia e' caduta col nome del file.
    Poi ripristinato.
  - **PRIMA quattordici, DOPO zero** prove che pescano dall'orologio senza
    dichiararlo.
- **U.01** Un gesto, una festa, un pagamento — CHIUSA
  - **IL CENSIMENTO E' COMPLETO: i traguardi che compaiono in piu' di un sentiero
    sono TRE**, e ognuno compare in tutti e tre. Carta natale (med_1, cal_1,
    aur_1, posizione 1), Angelo Custode (med_2, cal_2, aur_2, posizione 2),
    Animale Guida (med_3, cal_3, aur_3, posizione 3).
  - **LA GUARDIA E' SCRITTA E NASCE ROSSA, ed e' giusto cosi': dice il vero.**
    `test/un_gesto_una_festa_un_pagamento_test.dart` enumera i 165 traguardi e
    raggruppa per FIRMA della condizione, che e' il dato e non il testo: due
    traguardi con la stessa firma si accendono insieme, sempre. Trova tre
    condizioni ripetute. **La misura del difetto: la carta natale accende tre
    traguardi e paga 60 Eos per un gesto solo.** Torna verde quando i sei
    sostitutivi sono montati, e non si porta a verde allentando cio' che chiede.
  - **LA VERIFICA CHE L'ALLEGATO D CHIEDE PRIMA DEL MONTAGGIO E' FATTA, per
    enumerazione su tutte e 165 le voci: NESSUNO DEI SEI COLLIDE.** Il tipo
    `GestiCompiuti(gesto, 1)` non compare mai in nessuno dei tre sentieri: le
    progressioni cominciano tutte da tre, quindi lo spazio delle prime volte e'
    libero. Sull'oracolo la Costellazione ha gia' due, tre, cinque, sette e
    quattordici giorni di seguito; sulla gettata l'Albero ha tre, cinque, dieci,
    venti, trenta e cinquanta; sul tramonto due, tre, cinque, sette e quattordici
    sere; sul soffio il Loto ha tre, cinque, venti e cinquanta; sull'archetipo
    solo la combinazione di tre arti nello stesso giorno; sul chakra i sette
    centri diversi e lo stesso centro tre volte. Nessuna e' una prima volta.
  - **I SEI SOSTITUTIVI SONO MONTATI VERBATIM**, coi testi dell'Allegato D e le
    sei frasi della festa arrivate dopo. Le condizioni sono sei prime volte:
    `GestiCompiuti(gesto, 1)` su oracolo, gettata, tramonto, soffio, archetipo e
    chakra, sei gesti che esistevano gia' nell'app.
  - **LA GUARDIA E' DIVENTATA VERDE DA SOLA: zero condizioni ripetute** su 165
    traguardi, e il caso peggiore passa da tre traguardi e sessanta Eos a uno e
    venti. Non e' stata toccata per farla passare.
  - **`agganciTrasversali` RESTA, VUOTA, e non si cancella.** Serve alle prove che
    distinguono una ripetizione voluta da una sbagliata: cancellarla vorrebbe dire
    togliere il posto dove una ripetizione futura andrebbe dichiarata, e allora la
    prossima nascerebbe in silenzio come queste tre. Il commento che stava li'
    diceva che ripetere l'identita' era una scelta, perche' "chiedere tre volte la
    stessa cosa sarebbe una tassa": **ma non era chiesta tre volte, era PAGATA tre
    volte**, che e' il contrario.
  - **L'OBIETTIVO DELL'ALLEGATO D NON HA UN CAMPO CHE LO OSPITI, e non l'ho
    infilato dove capita.** `Traguardo` porta `nome`, `frase`, `percheConta` e
    `cosaApre`: quattro testi, e l'Obiettivo sarebbe un quinto. Oggi cosa fare per
    accendere un traguardo lo dice la CONDIZIONE, che e' un dato e non una frase.
    I sei Obiettivi restano nell'Allegato e nel manifesto.
  - **IL NODO L'HA SCIOLTO MAURO, e la coda della voce ha trovato un secondo
    difetto che la prima guardia non poteva vedere.**
  - **LA PROVA MISURAVA LA FIRMA, e l'unita' e' il GESTO.** `identita:archetipo` e
    `gesti:archetipo:1:false` sono due firme DIVERSE che lo stesso gesto accende
    insieme: la guardia per firma era verde su un difetto vivo, cioe' `cal_27` e
    `aur_2` accesi da un compimento solo del Test Archetipo, **due feste e trenta
    Eos**. La prova nuova costruisce, per ogni gesto registrato, uno stato da zero
    come se quel gesto fosse stato compiuto una volta sola, e conta quanti dei 165
    si accendono: al massimo uno. **Osserva 43 gesti.**
  - **IL ROSSO E' STATO SCRITTO ED ESEGUITO PRIMA DELLA CORREZIONE**, come la voce
    chiede: `archetipo accende 2 traguardi: cal_27, aur_2`. Poi `cal_27` e'
    diventato un traguardo di giornata e **la prova e' tornata verde da sola,
    senza toccarla.**
  - **IL LEGAME FRA GESTO E PEZZO DELL'IDENTITA' NON E' STATO RICOPIATO NELLA
    PROVA.** I nove pezzi vivevano scritti a mano dentro `regia_del_cammino.dart`:
    adesso stanno in `lib/core/sigilli/pezzi_dell_identita.dart` e li leggono sia
    la regia sia la prova. La regia non ha piu' la lista scritta a mano.
  - **cal_27 E' CAMBIATO, coi testi di Mauro verbatim:** "Il giorno affidato alle
    pietre", famiglia `giornata`, condizione `GestiNelloStessoGiorno(['gettata',
    'tramonto', 'sogno'])`, id e posizione invariati. Accenti veri, come per i sei
    dell'Allegato D.
  - **LA GUARDIA DELLE FAMIGLIE HA CAMBIATO CIO' CHE MISURA, e il perche' e'
    aritmetico.** Il minimo di cinque per sentiero non era raggiungibile e non lo
    era nemmeno prima: i pezzi dell'identita' sono **nove**, piu' i **tre** grandi
    di posizione 50 di quella famiglia, cioe' **dodici caselle contro le quindici**
    che tre sentieri per cinque pretendono. Il conto tornava solo perche' carta
    natale, angelo e animale ne occupavano nove invece di tre: **il minimo stava in
    piedi appoggiato al difetto che questa voce ha tolto.** Al suo posto tre
    pretese, e la prima **non esisteva**: ogni pezzo dell'identita' e' nominato da
    al piu' UN traguardo fra tutti e 165, contando sia `PezzoDellIdentita(pezzo)`
    sia `GestiCompiuti(pezzo, 1)`. **Vieta per sempre la triplicazione, che il
    minimo per sentiero invece incoraggiava.** Le altre due: almeno dodici di
    identita' in tutto, almeno tre per sentiero. Le altre sette famiglie e il tetto
    del Cerchio non sono stati toccati.
  - **IL TEST DEI TRE AGGANCIO NON PASSA PIU' SU ZERO IN SILENZIO.** Guardava una
    lista vuota, faceva zero osservazioni e passava, mentre il titolo dichiarava
    che erano tre. Adesso stampa quante ripetizioni dichiarate ha guardato e il
    titolo dice cio' che pretende, non un numero che non c'e' piu'.
  - **L'INTESTAZIONE DELLA GUARDIA DICEVA IL FALSO** e l'ho riscritta: sosteneva
    di nascere rossa e che tre condizioni erano ripetute. Adesso dice quando e'
    diventata verde, in due tempi, e **cosa la fa tornare rossa**.
  - **LE CONTE A FINE LAVORO, famiglia per famiglia e sentiero per sentiero:**

    | famiglia | costellazione | albero | loto |
    |---|---|---|---|
    | ampiezza | 5 | 5 | 5 |
    | cerchio | 4 | 4 | 4 |
    | cielo | 11 | 11 | 11 |
    | giornata | 5 | 6 | 5 |
    | identita | 5 | 3 | 4 |
    | memoria | 6 | 6 | 6 |
    | profondita | 10 | 11 | 11 |
    | ritorno | 9 | 9 | 9 |

    Identita' in tutto: **12 su 12 caselle possibili.** Pezzi dell'identita'
    osservati dalla prova: **9**. Gesti osservati: **43**.
  - **LA PROVA AVEVA UN PUNTO CIECO, e l'ha trovato una prova di casa lo stesso
    giorno.** Costruendo lo stato "da zero", come la voce chiedeva alla lettera,
    il CIELO restava vuoto: ma `la_festa_arriva_sempre_test.dart`, che dichiara
    il 14 agosto come istante, e' diventato rosso dicendo che una festa restava
    in coda. La causa: **una gettata in un giorno di luna nuova accende `cal_1`,
    la prima gettata, E `cal_6`, la finestra del cielo.** Due feste e due
    accrediti per un gesto solo, cioe' esattamente cio' che questa voce vieta.
  - **LA PROVA E' STATA ALLARGATA, non allentata:** adesso guarda ogni gesto anche
    sotto ogni evento del cielo, uno per volta. **1.290 coppie gesto e cielo
    osservate**, e ne trova **ventiquattro** che accendono due traguardi.
  - **NON E' UN CASO RARO E NON SI PUO' LASCIARE:** il cielo non e' un'eccezione,
    e' un giorno su tanti, e capita proprio alla prima volta di qualcuno. Le
    ventiquattro coppie sono tutte della stessa forma: **una PRIMA VOLTA dei sei
    montati oggi** (prima gettata `cal_1`, primo soffio `aur_1`, primo tramonto
    `cal_2`) che cade nello stesso giorno di una **finestra del cielo** che chiede
    quello stesso gesto. Undici sulla gettata, nove sul soffio, quattro sul
    tramonto.
  - **LA DECISIONE E' ARRIVATA: la pretesa non era soddisfacibile, e la ragione e'
    misurata.** Delle trenta finestre del cielo, **sette non chiedono nessun
    gesto** (med_35 equinozio, med_41 luna piena nel tuo segno, med_50 ritorno
    solare, cal_19 solstizio, cal_35 saturno diretto, cal_41 luna nuova nel tuo
    segno, aur_41 tre transiti insieme): si accendono da sole, senza che nessuno
    abbia toccato l'app. E dentro `EventiDelCielo.diOggi` la riga che aggiunge
    luna crescente oppure calante **non ha condizioni**, quindi uno dei due e'
    acceso tutti i giorni dell'anno. **Un tetto sul numero lo romperebbe il cielo
    da solo, in un giorno qualunque, senza che nessuno tocchi il codice.**
  - **LA REGOLA, e distingue due cose che si somigliano solo a guardarle male.**
    Lo stesso FATTO non si festeggia due volte: tre traguardi che chiedono la
    carta natale sono lo stesso fatto scritto tre volte, e quella e' la
    ripetizione vera. **Fatti DIVERSI che cadono nello stesso istante sono due
    feste meritate:** la prima gettata e la gettata a luna nuova non sono la
    stessa cosa detta in due modi, perche' **una la decidi tu e l'altra te la
    regala il calendario e non la puoi cercare.** Chi le fa cadere insieme ha
    fatto una cosa piu' rara di chi le fa cadere separate, e togliergli una festa
    sarebbe punirlo.
  - **DUE MESTIERI SEPARATI, e non si confondono.** La GUARDIA enumera i gesti a
    cielo vuoto e pretende al massimo un traguardo, perche' quello e' cio' che una
    persona puo' ottenere quando vuole: **43 gesti osservati, verde, e non e'
    stata toccata per farla passare.** La MISURA enumera gesto per cielo, non ha
    soglia e cade solo se non guarda niente: **1.290 coppie osservate, massimo
    trovato 2, raggiunto da 137 coppie.**
  - **IL SECONDO NUMERO DELLA MISURA E' UN LIMITE SUPERIORE, non un giorno vero:
    12, sul gesto gettata.** Uno per il traguardo che il gesto accende da solo,
    piu' le quattro finestre che chiedono la gettata, piu' le sette che non
    chiedono niente. **Nessun giorno vero puo' raggiungerlo**, perche' alcuni
    eventi si escludono a vicenda e la somma li conta tutti insieme: crescente
    contro calante, nuova contro piena, i quattro quarti fra loro.
  - **UN ERRORE MIO, trovato misurando e non ragionando.** La prima stesura del
    limite contava le finestre dalla FIRMA, e la firma di una finestra senza gesto
    finisce con la parola "presenza", che e' **anche il nome di un gesto vero**:
    il gesto `presenza` si prendeva le sette finestre di nessuno e poi se le vedeva
    sommare un'altra volta, e il limite usciva 15 invece di 12. Adesso si guarda
    la condizione e non la firma.
  - **IL DOPPIONE VERO RESTA VIETATO, verificato:** la prova delle firme in
    `test/i_traguardi_del_cammino_test.dart` cade ancora se due traguardi portano
    la stessa identica condizione, stesso evento e stesso gesto. Non e' toccata da
    questa decisione, e resta verde con zero condizioni ripetute su 165.
  - **NESSUN TESTO DI TRAGUARDO E' STATO TOCCATO.** Le sei prime volte
    dell'Allegato D restano `GestiCompiuti(gesto, 1)` con le loro frasi, comprese
    le parole "la prima"; le ventitre finestre con `conGesto` restano come sono e
    non hanno ricevuto nessuna condizione aggiuntiva.

  - **IL SETTIMO OBIETTIVO, quello di cal_27, resta fuori dal dato come i sei:**
    compiere gettata, runa del tramonto e rito del sogno nello stesso giorno.
    `Traguardo` porta `nome`, `frase`, `percheConta` e `cosaApre`, e cosa fare per
    accendere un traguardo lo dice la CONDIZIONE, che e' un dato e non una frase.

- **U.02** Tre celebrazioni, una per Maestro — APERTA
  - **NIENTE NELLO STATO ATTUALE CONTRADDICE LA VOCE, misurato prima di
    costruire.** Le celebrazioni erano due, `CelebrazioneAScermoPieno` e
    `_FasciaDellaCelebrazione`, uguali per i tre Maestri tranne la palette; il
    tocco che salta **non esisteva**; `disableAnimations` era gia' gestito e
    degradava invece di spegnere; le durate erano 1800 e 900 millesimi con sei
    secondi di permanenza.
  - **FATTO: la direzione e' un dato, non un effetto che si intuisce guardando.**
    `lib/features/sigilli/direzione_della_festa.dart` dichiara per ogni Maestro
    la direzione e la MATERIA: Medora dal centro verso fuori con le stelle,
    Caligo dall'alto verso il basso con le **cifre**, Aura dal basso verso l'alto
    col polline. Una prova enumera i tre e pretende tre direzioni diverse; una
    seconda pretende tre materie diverse, perche' **una pioggia che cade e una
    che sale sono la stessa festa girata**.
  - **FATTO: il grande e' piu' ampio e piu' lungo del mini, in due numeri.** Una
    volta e mezzo le particelle, un terzo di tempo in piu', dichiarati come
    RAPPORTI e non come misure: mini 1.800 millesimi, grande 2.394.
  - **FATTO: la durata si sceglie sul tempo di LETTURA**, e la soglia non deriva
    dalla durata scelta: viene da quanto ci mette un occhio a leggere due righe
    brevi, piu' di un secondo e mezzo.
  - **FATTO: il tocco che salta, che non c'era.** Porta subito al traguardo e al
    premio, perche' una festa da cui non si puo' uscire diventa un ostacolo alla
    seconda volta.
  - **FATTO: degradare non e' spegnere.** Con Riduci Movimento resta un quinto
    delle particelle, e la prova legge quel numero **dal pittore** invece di
    ricopiarlo, che e' l'errore appena corretto nella U.01.
  - **ROSSO ESEGUITO, con l'iniezione verificata prima di leggere l'esito:** data
    ad Aura la direzione di Medora, la guardia e' caduta nominando i due.
  - **NON FATTO: OTTO ANTEPRIME SU NOVE.** Il generatore
    `tool/anteprime_delle_feste.dart` produce il primo fotogramma e poi non
    arriva in fondo, **stesso sintomo delle anteprime dei Journal della voce T.02**:
    catture ripetute dentro una prova sola scadono dopo dieci minuti. La prima,
    `docs/preview/festa_medora_inizio.png`, l'ho guardata e la direzione si legge:
    stelle d'oro che si aprono dal centro, col traguardo e il premio sotto.
    **Le altre otto no, e sono quelle su cui Mauro deve dire se e' una festa**,
    quindi la voce resta APERTA.

## Marcatori

VOCI_TOTALI: 3
VOCI_CHIUSE: 2
VOCI_APERTE: 1
VOCI_FERMATE_SU_PREMESSA_FALSA: 0
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0
