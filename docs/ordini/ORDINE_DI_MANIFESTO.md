# ORDINE DI, IL VIAGGIO DELLO SCIAMANO DIVENTA UN PERCORSO

**Sigla:** DI. **Data:** 12 settembre 2026. **Ramo:**
`claude/esoteric-circle-master-order-e798aj`.

**Vincolo permanente:** tutta l'intelligenza a runtime gira su Gemini e
Vertex AI, mai su API Anthropic. **Nessuna build senza ordine del fondatore.**

VOCI_TOTALI: 17
VOCI_CHIUSE: 3
VOCI_SBLOCCATE_E_APERTE: 0

---

## DI.09, prima cosa: IL VIDEO. VERIFICATO E NEL RAMO

L'ordine chiede di verificare il file **prima di qualunque altra cosa**, e di
fermarsi se non c'e'. **Alla prima verifica non c'era**: la testa remota era
`e0e8b825`, e il file non stava su nessuno dei tredici rami remoti, ne' nella
cartella del progetto, ne' fra Desktop, Download, Documenti, Video e il disco
D:. La voce e' rimasta ferma, senza video sostitutivi e senza segnaposto.

**Il fondatore l'ha poi caricato**, e prima di copiarlo:

| misura | attesa | trovata |
|---|---|---|
| dimensione | 2.262.337 byte | 2.262.337 byte |
| SHA-256 | `0db19531...c12c77d` | identica, sul file caricato e sulla copia |
| misura | 720 x 1280 | 720 x 1280 |
| cadenza | 24 fps | 24/1 |
| durata | 8,000 s | 8,000000 s |
| fotogrammi | 192 | 192 dichiarati e **192 contati** uno per uno |
| codifica | H.264 high | h264, profilo High |
| audio | muto | un solo flusso |
| indice in testa | si' | `ftyp moov free mdat` |

Copiato senza ricodifica ne' rinomina in
`brand_assets/mondo_di_sotto/discesa_v1.mp4`, commit `2928464c`, e **il blob sul
remoto ha la stessa impronta**. La cartella e' dichiarata nel pubspec accanto a
`brand_assets/sentieri/` e `docs/stato_asset.json` la conosce.

---

## DI.09, LA DISCESA DIVENTA UN VIDEO GOVERNATO DAL DITO. CHIUSA NEL CODICE

**Cosa vede la persona adesso.** Dopo la soglia, lo schermo pieno mostra il
primo fotogramma del filmato del fondatore: il bosco dall'alto e le radici che
convergono nel buco. Il tamburo comincia a battere prima del dito. Col dito
premuto il filmato va, e sotto il polpastrello pulsa un alone d'oro alla
cadenza del tamburo; col dito alzato il filmato rallenta in mezzo secondo e si
ferma, e il tamburo continua. Dalla seconda discesa, dopo un secondo e mezzo,
in basso compare *"Salta la discesa"*. In fondo, la luce dorata dell'ultimo
fotogramma si scioglie nella nebbia in mezzo secondo.

**Dove sta.** `lib/features/maestri/caligo/viaggio/la_discesa_in_video.dart`,
nuovo, e la schermata del Viaggio lo monta al posto del tunnel a `Timer`.

| voce dell'ordine | come e' fatta | chi la pretende |
|---|---|---|
| dito premuto: play | al tocco `velocita(0.1)` e `avvia`, nello stesso istante | *il dito governa il filmato* |
| dito alzato: da 1.0 a 0 in 500 ms, poi pause | dieci gradini da 50 ms, 0,9 ... 0,1 e al decimo `sospendi` | *la rampa del dito* e *il dito governa il filmato* |
| dito ripremuto: da 0 a 1.0 in 500 ms | al tocco un decimo, poi nove gradini: uno pieno a 450 ms | *la rampa del dito* |
| nessun `seekTo` | la parola non c'e' nel sorgente, e `avvia` a filmato finito non chiama `play`, che tornerebbe all'inizio con un salto | *il lettore vero non salta mai* |
| si inizializza mentre si sceglie la domanda | il lettore nasce con la soglia, `initState` della schermata | la strada di ogni prova del Viaggio |
| primo fotogramma fermo, mai nero | `discesa_v1_primo_fotogramma.webp` sotto, e il filmato sopra **solo dopo il primo fotogramma vero**: una texture appena nata puo' essere nera | *mai uno schermo nero*, fotografata: 2,4 per cento di nero, varianza 549 |
| tamburo separato, continuo, anche a dito alzato | quarto lettore del motore unico, in ciclo, dalla palette; la musica gli scende sotto finche' batte | *il tamburo comincia con la discesa* |
| alone sotto il polpastrello, circa 4,5 al secondo | `AloneDelPolpastrello`, col `Timer` e non col controller; il primo battito cade sul tocco | *l alone sta sotto il polpastrello* e *pulsa a quattro battiti e mezzo*: 45 in dieci secondi |
| nessuna barra di avanzamento | nessun indicatore nel sorgente | *il lettore vero non salta mai e non mostra barre* |
| dissolvenza di 500 ms verso la nebbia | sopra la nebbia svanisce l'ultimo fotogramma vero, poi il decodificatore si libera | *alla fine del filmato*: 1,00, 0,52 a meta', poi niente |
| "Salta la discesa" dalla seconda, dopo 1,5 s | fuori dalla zona del dito, cosi' toccarlo non fa partire il filmato | *alla prima non si salta* e *dalla seconda compare* |
| il tunnel resta come riserva | se il lettore fallisce si scende nel tunnel, con la stessa rampa e la stessa durata | *se il filmato non si prepara* e *la discesa dura quanto il filmato*: 8,22 s |
| il codice mai raggiunto del pittore | tolto: diciotto anelli, spirale e filo di luce, che si disegnavano solo senza roccia | `la_discesa_riempie_lo_schermo`, riscritta sul widget vero |
| riprendere da `RivelazioneInVideo` | stessa porta, `LettoreDellaDiscesa`, stessa promessa di non lanciare, stessa copertura `BoxFit.cover` | |
| nessuna dipendenza nuova | `video_player` e `audioplayers` c'erano gia' | |

**LA DURATA E' CAMBIATA, e lo dico per nome.** La discesa durava venti secondi
col dito premuto, ordini DE voce 06 e DG voce 06. Adesso dura quanto il
filmato, otto secondi, e con la rampa del tocco 8,22. Le due costanti
`primaDiscesa` e `discesaConosciuta` non ci sono piu', e la guardia che le
misurava si chiama adesso `la_discesa_dura_quanto_il_filmato`. Anche la
dissolvenza verso la nebbia passa da un secondo e due decimi a mezzo secondo,
come chiede l'ordine.

**IL TAMBURO NON SUONA ANCORA, perche' il file non c'e'.** Nel progetto non
esiste nessun suono di tamburo: il *tamburo* del richiamo e' una vibrazione. Lo
slot e' pronto, `assets/audio/tamburo_della_discesa.mp3`, e le misure per
sceglierlo stanno in `assets/audio/LEGGIMI.md`: tamburo a cornice, 4,5 battiti
al secondo, anello senza cucitura. Non l'ho sintetizzato: il fondatore ha gia'
detto del responso che un suono che non ha scelto lui non lo vuole. Finche'
manca la discesa resta muta e la musica non si abbassa sotto un silenzio.

**UN SECONDO DIFETTO, trovato dalla suite intera, e chiuso.** La guardia `nessuna_sorgente_resta_accesa_in_sottofondo` ha preso il lettore del filmato, che non ascoltava il ciclo di vita dell'app. Il filmato e' muto, ma `video_player` al ritorno riprende da solo cio' che stava andando: chi riceveva una telefonata col dito premuto, tornando, avrebbe visto la discesa ripartire senza dito. Adesso ci si ferma allo stato `inactive`, prima che `video_player` guardi. **Padre: DI.09**, prima stesura.

**UN DIFETTO TROVATO STRADA FACENDO, e chiuso.** La prova della durata ha
visto un battito da cinquanta millisecondi restare acceso dopo ogni discesa: il
dito che si alza dopo la fine arriva lo stesso al widget smontato, perche' il
sistema consegna l'alzata a chi ha ricevuto il tocco. Adesso a discesa finita
non si riaccende niente. **Padre: questa stessa voce, DI.09**, nella prima
stesura del widget.

**COSA NON HO POTUTO VEDERE.** Tutto cio' che sta qui sopra e' misurato al
banco, con un lettore finto per il filmato. Il filmato vero sul telefono, cioe'
la fluidita' della rampa di `setPlaybackSpeed` su Android e il passaggio dal
fotogramma fermo alla texture, si vede solo con una build, e **nessuna build
parte senza l'ordine del fondatore**.

**LE GUARDIE, tutte viste rosse.**

| rosso innestato | esito |
|---|---|
| il filmato a schermo prima del primo fotogramma | rossa |
| il primo fotogramma tolto, resta il fondo | rossa: varianza della scena 0 contro 549 |
| la rampa che si ferma al primo gradino | rossa |
| l'alone che non si disegna | rossa |
| *Salta* anche alla prima discesa | rossa |
| *Salta* dentro la zona del dito | rossa: il tocco fa partire il filmato |
| sopra la nebbia svanisce il tunnel invece del filmato | rossa |
| il tamburo che si ferma col dito | rossa |
| il tamburo chiesto senza file | rossa |
| il tunnel di riserva che non arriva mai | rossa |
| un `seekTo` nel lettore vero | rossa |
| il filmato che ignora l'app che se ne va | rossa: al ritorno ripartiva senza dito |
| la durata riportata a venti secondi | rossa: 20,22 s |
| la roccia ferma, nel tunnel di riserva | rossa: 0,0 per cento della parete cambiata |
| la roccia spinta fuori dalla finestra | rossa: 8,3 per cento dipinto |

**Due non erano rossi al primo giro, e l'errore era mio.** La grana del primo
fotogramma si misurava sulla finestra intera, dove la barra e la scritta
facevano varianza da sole; e l'innesto del pulsante aveva le virgolette nel
filtro della prova, che non girava affatto. Misurata la grana dentro la scena,
e innestato il pulsante davvero dentro la zona del dito, rossi tutti e due. Il
ripristino dopo ogni innesto e' stato verificato al byte.

---

## DI.01, IL TEMA DELLA DOMANDA ARRIVA DAVVERO. CHIUSA

**La premessa dell'ordine e' vera, riletta sul codice.** Lo schermo assegnava
`_temaScelto = d.tema`, l'etichetta *"Una scelta da fare"*; la voce del Mondo di
Sotto cercava `d.id == idDomanda`, l'identificatore `scelta`. E c'era una
seconda riga col confronto sbagliato, quella che decideva quale domanda
apparisse accesa.

**Il campo faceva tre mestieri**: portava l'etichetta, portava `'incontro'` per
la terza via, e faceva da semaforo per saltare il controllo del testo. E'
questo che ha permesso a un'etichetta di entrarci senza che niente se ne
accorgesse.

**LA CURA E' IL TIPO.** `TemaDellaDomanda` e' un enum dei sei temi,
`_temaScelto` e' un `TemaDellaDomanda?`, e l'id delle sei domande **non si
scrive piu' a mano**: si legge dall'enum. **Scrivere l'etichetta dove va il
tema non compila**, provato: il compilatore dice *"A value of type 'String'
can't be assigned to a variable of type 'TemaDellaDomanda?'"*. La terza via e il
semaforo si leggono dalla via scelta. Il diario salva l'id e lo ritraduce in
parole per il riassunto dei Maestri, capendo anche i diari vecchi, che
contengono le etichette.

**LA PROVA FA LA STRADA INTERA**, perche' la guardia dell'ordine DG voce 07 era
verde proprio chiamando il compositore direttamente, con l'id giusto in mano:
**misurava il contenuto, non la strada**. `il_tema_della_domanda_arriva_alla_risposta`
tocca la domanda sullo schermo, scende col dito, apre la nebbia, segue
l'ombra, risale, e legge la risposta **come arriva a schermo**. **Sei domande,
sei riprese.** Vista rossa: col tema nullo nella chiamata, sei cadute su sei.

**Cosa si legge a schermo adesso**, e va detto perche' **non e' ancora
eccellente**: *"Con te e' scesa un tempo che non arriva"* sbaglia il genere;
*"Sei sceso"* da' per scontato un lettore uomo; *"era qualcosa che e' finito.
E' finito."* ripete. Rientrano nella rilettura integrale della voce DI.05.

### Il censimento della stessa famiglia

L'ordine chiede di censire ogni punto dove un'etichetta per persone viene
confrontata con un identificatore stabile. **Tre passate**: i confronti diretti
fra un campo id e un campo etichetta (nessuno); le undici funzioni che cercano
per id una stringa venuta da fuori, coi loro chiamanti (tutte con id scritti
dal codice, e due verificate a fondo: il segno del ricordo dell'oroscopo, che
chi lo rilegge accetta di proposito in tre forme, e i pianeti degli eventi del
cielo, `sun` da tutte e due le parti); le etichette usate come chiave di mappa
o di confronto. **Due parenti veri**:

1. **La matrice dei piani cercava le righe per etichetta**, e ogni ricerca a
   etichetta non trovata ripiegava in silenzio: `haMemoria` su **vero**, cioe'
   la memoria dei Maestri gratis per tutti; `limiteGiornaliero` su **nullo**,
   cioe' illimitato, l'abuso chiuso dall'ordine CE voce 08; `haProfondita` su
   **falso**, cioe' la Profonda tolta a chi l'ha pagata. Bastava ritoccare una
   parola della tabella. E le etichette erano scritte **due volte**, nella
   matrice e nelle costanti `rigaDomande` e sorelle. **Curata col tipo**:
   `RigaDelPiano`, dieci chiavi, ricerche per chiave, l'etichetta resta per la
   tabella. I nomi delle costanti sono gli stessi, e' cambiato il loro tipo.
2. **Il registro lunare delle rune del tramonto era indicizzato col nome
   italiano della fase.** Qui il nome e' l'identita' stessa della fase nel
   modulo lunare, e passarlo a un tipo vorrebbe dire rifare il motore
   astronomico: **curato con una guardia**, che pretende che le chiavi del
   registro siano esattamente i nomi che la fase sa produrre.

**E la cura della matrice ha reso piu' forte una prova vecchia**, che ha
subito trovato due righe con un numero che non sono tetti d'uso: *Eos in dono
alla sottoscrizione*, una quantita' regalata una volta, e *Domanda al Maestro
reale*, **una quota mensile di un servizio umano che nel codice non impone
nessuno**. Dichiarate per nome e ragione. **La seconda va al fondatore**:
l'Illuminato si vede promettere *"una domanda al mese al Maestro reale,
risposta entro 48 ore"*, e niente la implementa.

**LE GUARDIE:** `il_tema_della_domanda_arriva_alla_risposta` e
`le_etichette_non_fanno_da_chiave`, registro a **397**.

---

## DI.02, LA DOMANDA LIBERA VIENE CAPITA. CHIUSA NEL CODICE

**La premessa e' vera.** Nessun classificatore esisteva: il testo della
persona entrava in un punto solo, come ingresso dell'hash che sceglie i pezzi
della scena. E c'era di peggio: appena si scriveva nel campo, lo schermo
azzerava il tema, quindi la risposta usava sempre le frasi *"senza domanda"*.

**LA VIA DI RISERVA**, `IlTemaDellaDomandaLibera`, una tabella di parole e
locuzioni per tema, coi pesi: tre per le locuzioni che dicono **cosa si sta
chiedendo**, uno per i nomi che dicono **di chi o di cosa si parla**, quattro
per le perdite. A parita', a zero, **o sotto i due punti**, il tema resta nullo.

### La tabella che l'ordine chiede, a rete staccata

| ok | domanda | atteso | ottenuto | punti |
|---|---|---|---|---|
| SI | Mia sorella diventerà presto mamma? | attesa | attesa | attesa 6, persona 2 |
| SI | Quando arriverà la risposta del colloquio? | attesa | attesa | attesa 7 |
| SI | Aspetto da mesi una notizia che non arriva mai. | attesa | attesa | attesa 8, blocco 1 |
| SI | Riuscirò finalmente ad avere un figlio? | attesa | attesa | attesa 6, persona 1 |
| SI | Devo accettare il nuovo lavoro o restare dove sono? | scelta | scelta | scelta 7 |
| SI | Non so se trasferirmi a Milano o rimanere qui. | scelta | scelta | scelta 9 |
| SI | Firmo il contratto oppure aspetto un’offerta migliore? | scelta | scelta | attesa 3, scelta 7 |
| SI | Quale delle due case dovrei comprare? | scelta | scelta | scelta 3 |
| SI | Cosa prova davvero Marco per me? | persona | persona | persona 4 |
| SI | Posso fidarmi della mia collega? | persona | persona | persona 4 |
| SI | Perché mia madre è sempre così fredda con me? | persona | persona | persona 3 |
| SI | Perché non riesco mai a finire quello che inizio? | blocco | blocco | blocco 4 |
| SI | Ho paura di parlare in pubblico e mi blocco ogni volta. | blocco | blocco | blocco 8 |
| SI | Come faccio a smettere di rimandare tutto? | blocco | blocco | blocco 8 |
| SI | Che strada devo prendere nella vita? | direzione | direzione | scelta 1, direzione 6 |
| SI | Mi sento perso, non so cosa voglio fare da grande. | direzione | direzione | direzione 9 |
| SI | Qual è il mio scopo? | direzione | direzione | direzione 3 |
| SI | Come supero la fine della mia relazione? | finito | finito | finito 3 |
| SI | Mio padre è morto e non riesco ad andare avanti. | finito | finito | persona 1, blocco 3, finito 8 |
| SI | Mi hanno licenziato dopo dieci anni, e adesso? | finito | finito | finito 6 |

**Venti su venti.** Ma va detto come si legge questo numero: le domande del
gruppo dell'ordine le ho scritte io prima della tabella, e la tabella le
conosceva mentre la scrivevo. **E' una prova di regressione, non una misura.**

### La misura onesta, e come ci si e' arrivati

1. Un **secondo gruppo** di dodici domande doveva essere indipendente, e non
   lo era: la tabella ne ricalcava parola per parola le locuzioni. Il suo
   dodici su dodici non misurava niente, **e l'ho dichiarato invece di
   tenerlo**.
2. Congelata la tabella, un **terzo gruppo** scritto dopo: **3 capite su
   12, e 2 SBAGLIATE**, *"Mia figlia e' felice con il suo ragazzo?"* finita
   nell'attesa e *"Cosa dovrei cambiare per sentirmi piu' realizzato?"* nella
   scelta.
3. Due cambi di principio, e non ritocchi su quelle domande: **una parola
   d'argomento da sola non decide** (minimo due punti), e **il figlio e' una
   persona** (stava nell'attesa per colpa di *"avere un figlio"*).
4. Congelata di nuovo, un **quarto gruppo** scritto dopo: **4 capite su 12,
   zero sbagliate**. E' la misura onesta di oggi.

**La guardia pretende zero temi sbagliati, non un numero di giusti**: senza
tema si cade sul ramo senza domanda, che l'ordine dice legittimo; col tema
sbagliato la persona riceve una risposta su un'altra cosa. **La tabella da
sola capisce una domanda su tre: e' una rete di sicurezza prudente, il capire
e' del modello.**

### LA VIA PRINCIPALE, col modello

`LaDomandaCapita`: chiamata secca, temperatura zero, istruzione costruita dalle
sei domande scritte, e **risposta vincolata a un elenco chiuso**
(`text/x.enum`): il modello non puo' scrivere altro che uno dei sei id.
**Due secondi di pazienza**, poi la tabella, senza che la persona se ne
accorga; il guasto va nel registro dei guasti, mai alla persona. **La
classificazione parte al tocco di Scendi e lavora durante i venti secondi della
discesa**: quando si risale e' pronta da un pezzo.

**I MODELLI DELL'ORDINE ESISTONO, MA SOLO DALL'ENDPOINT `global`.** Verificato
il 12 settembre 2026 contando i token con ogni modello: `gemini-3.5-flash-lite`
e `gemini-3.6-flash` rispondono da `global` e danno 404 da `europe-west1`,
dove l'app fissa Vertex di proposito. **E' una scelta di residenza dei dati, ed
e' del fondatore.** Provati col modello vero sulle 56 domande di prova, con la
stessa istruzione e lo stesso elenco chiuso:

| | giuste | tempo mediano | peggiore | oltre 2 s |
|---|---|---|---|---|
| `gemini-2.5-flash-lite`, `europe-west1` | 53 su 56 | 0,44 s | 1,30 s | 0 |
| `gemini-3.5-flash-lite`, `global` | 54 su 56 | 0,69 s | **20,04 s** | 1 |

**Misurati con l'istruzione che il codice usa davvero**: una prima misura era
stata fatta su una formulazione poi corretta dalle guardie di casa, e si e'
rifatta. **Due misure di fila hanno trovato su `global` una chiamata da circa
venti secondi** (18,99 e 20,04): coi due secondi di pazienza la persona non se
ne accorge, perche' decide la tabella, ma e' un dato per la scelta. La
differenza di precisione fra i due modelli e' **una domanda su 56**.

**Finche' il fondatore non sceglie, e' montato il primo**, che tiene i dati in
Europa e non ha mai sforato i due secondi: modello e regione sono una
costante ciascuno.

**La domanda del fondatore, adesso, a rete staccata:** *"Mia sorella
diventera' presto mamma?"* riceve *"Sotto sei andato per un tempo che non
arriva. Datti una data. Se passa, hai la tua risposta."* Prima riceveva *"Non
hai chiesto niente. Hai visto lo stesso."* **E' una risposta sull'attesa, ma
non ancora sulla sua domanda**: non nomina ne' la sorella ne' il diventare
madre. Quello e' il lavoro delle voci DI.03 e DI.04.

**LE GUARDIE:** `la_domanda_libera_viene_capita`, con la via di riserva, i
quattro gruppi, e il modello iniettato in cinque comportamenti (giusto, con le
virgolette, fuori dai sei, in errore, oltre i due secondi: la persona aspetta
2,002 secondi); e la strada intera con la domanda scritta a mano. Viste rosse:
col minimo per decidere a uno, due temi sbagliati nominati; senza la
classificazione al tocco di Scendi, la frase senza domanda.
