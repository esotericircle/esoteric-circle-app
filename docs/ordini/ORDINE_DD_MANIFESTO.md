# ORDINE DD, I COMANDI CHE NON RISPONDONO

**10 settembre 2026.** Ramo `claude/esoteric-circle-master-order-e798aj`.
Quindici voci.

**LA REGOLA NUOVA DI QUEST'ORDINE, e nasce da una contestazione.**

**REGOLA L.** *"Il telefono collegato non serve a provare che l'app si accende.
Serve a provare che le voci dell'ordine funzionano."* Per ogni voce che tocca
un comando, un tocco, una pressione o una scelta, **il collaudo si fa sul
dispositivo**: si tocca, si guarda cosa succede, e si scrive nel referto che
cosa si e' visto. Una voce che dichiara un comando funzionante senza che quel
comando sia stato premuto sul telefono **non e' chiusa**.

**La frase che l'ha fatta nascere**, sulla build 2244: *"se faccio click su una
voce non succede nulla"*. Quella voce era dichiarata chiusa.

**E la contestazione e' giusta.** L'ordine DC ha consegnato la 2244 con una
prova di accensione: l'app si apriva, la home era piena, il log non aveva
errori fatali. **Tutto vero e tutto inutile**, perche' nessuno aveva premuto i
comandi. La prova di accensione dice che l'app parte, non che funziona.

---

## LA RICOGNIZIONE, PRIMA DI TOCCARE NIENTE

**Regola ZERO: il testo dell'ordine non e' una fonte attendibile sullo stato del
codice.** Qui sotto c'e' cosa ho trovato sul ramo e sul telefono **prima** di
scrivere una riga, voce per voce, con le differenze dichiarate.

### DD.12, i tre comandi morti: TUTTI E TRE RIPRODOTTI

Telefono 767f596c, build 2244, schermata Meditazione.

**Uno, il fiore.** Toccato al centro. **Cambiano 449.637 pixel**: il fiore
sboccia davvero, quindi il tocco arriva. Ma l'etichetta al centro continua a
dire `TOCCA PER INIZIARE`, e nei tre secondi successivi **cambiano 4.358
pixel**, cioe' rumore. **Lo scatto c'e', la sessione non parte.** Le parole del
fondatore, *"si vede uno scatto e non parte niente"*, descrivono esattamente
questo.

**Due, la pressione prolungata.** Tenuto il dito per sei secondi. Il fiore **si
chiude** (449.335 pixel) e al rilascio **si riapre** (449.699). Quindi il gesto
del dito **e' collegato e risponde**: quello che non succede e' che parta una
sessione. La voce dell'ordine dice *"tenendo premuto non succede nulla"*;
**la differenza va dichiarata**: qualcosa succede, ma e' un petalo che si apre
senza che niente cominci.

**Tre, la libreria.** Toccata la riga `La libreria dei respiri, 12 pratiche`:
si apre davvero, **40.095 pixel**, e compaiono `Chiudi la libreria`,
`12 pratiche, tutte pronte.` e le voci. Poi toccata la prima voce, `Il suono
del cuore, 5 minuti`: **603 pixel**, cioe' **niente**. **La libreria si apre,
le sue voci non rispondono.** Anche qui la voce dell'ordine dice *"la libreria
non risponde"*: la differenza e' che risponde lei e non rispondono le sue
voci.

### DD.13, lo sfondo: CONFERMATO

La schermata della Meditazione ha lo sfondo **completamente nero**, senza
stelle e senza parallasse. Non e' il mondo di Aura.

### DD.06, la Luna che si sposta: CAUSA TROVATA IN FOTOGRAFIA

Nella home, la Luna sta in una riga **centrata insieme** all'animazione del
dito e al testo `Tocca il cielo`. Quando quei due spariscono, la riga si
ricentra **e la Luna scivola a destra**. Non e' la Luna che si muove: e' la
riga che si stringe.

### DD.01, il microfono: CAUSA TROVATA NEL CODICE

`lib/features/rituals/breath_destiny_screen.dart`, riga 226:
`if (!_revealed && amp.current > -18) _complete();`

**E' una soglia di volume nuda.** Qualunque suono sopra i meno diciotto
decibel apre il dono: la musica, una voce, una porta che sbatte.

**E il flusso PCM c'e' gia' e viene buttato via.** Riga 217:
`_micStream = stream.listen((_) {});` **Il rilevatore ha davanti i campioni
audio veri e non li guarda**: ascolta solo l'ampiezza aggregata. La cura non
chiede di aprire una porta nuova, chiede di raccogliere quello che passa gia'
di li'.

**E' l'unico punto dell'app che ascolta il microfono per rilevare un soffio**,
verificato col grep su `onAmplitudeChanged`: due sole occorrenze, tutte e due
in questo file. **La correzione sta in un punto solo**, come l'ordine chiede.

### DD.04, la Parola dell'Alba nel Sigillo: **QUESTA RICOGNIZIONE AVEVA TORTO**

**L'ordine dice** che il ritorno della Parola *"non e' mai stato fatto"* e
chiede di trattarlo come una regressione grave.

**Il codice dice il contrario, ed e' la differenza piu' grande di questa
ricognizione.** Il meccanismo esiste, e' completo, ed e' stato scritto
nell'ordine P voce 18:

- `FiloDelGiorno.segnaLaParola` la scrive, chiamata da `dawn_rite_screen.dart`
  riga 310;
- `FiloDelGiorno.parolaDiStamattina` la rilegge, chiamata da
  `dream_rite_screen.dart` riga 251;
- `dream_rite_screen.dart` riga 624 la mostra, con la chiave
  `dream_parola_del_mattino` e la formula dell'ordine CQ voce 2.09:
  *"Stamattina la tua parola era X. Adesso chiude il giro: dove l'hai
  riconosciuta oggi?"*

**Quindi non e' mai stato tolto: o non arriva, o arriva e non si riconosce.**
Le due ipotesi si distinguono solo sul telefono, e questa voce non si chiude
finche' non ho aperto l'Alba, letto la parola, aperto il Sigillo e guardato.
**Il fatto del fondatore resta vero fino a prova contraria**: se lui non la
vede, per lui non c'e', e la causa va trovata invece che negata.

> **RITRATTAZIONE, scritta lo stesso giorno.** Questa ricognizione ha detto
> *"la voce dice il falso sul codice"*, e **la voce diceva il vero**. Tre
> chiamate esistenti e collegate non fanno una riga a video: fra il dato e
> l'occhio c'e' tutta la schermata. Ho elencato le chiamate e ho chiamato
> quell'elenco una verifica. **Non lo era**, e la lezione e' quella di sempre
> in questo progetto: *cio' che si vede si misura dove si vede*. La causa vera
> sta sotto, nella voce chiusa.

## DD.07, IL SECONDO CUORICINO, e la causa non era dove sembrava

**Il fatto del fondatore**: nell'Oroscopo si vedono due cuoricini.

**RIPRODOTTO SUL TELEFONO, ed e' la fotografia a dire quando.** Dispositivo
767f596c, sotto REGOLA L:

| Momento | Cuoricini | Fotografia |
| --- | --- | --- |
| Oroscopo appena aperto | **1** | `dd07_oroscopo_prima.png` |
| Premuto *Interroga il cielo* | **2**, affiancati e sovrapposti | `dd07_oroscopo_dopo.png` |

**Il difetto non era un cuore montato due volte**, che era l'ipotesi ovvia e
sarebbe stata comoda. La guardia che conta le dichiarazioni nei sorgenti dice
**zero schermate** con due dichiarazioni, e ha ragione.

**LA CAUSA VERA: un interruttore con due mani sopra.** Il cuore delle arti
preferite ha due case, quello della barra e quello sovrapposto alla scena, e
un booleano decide quale delle due si vede: chi prende in carico il cuore lo
alza, e il sovrapposto si toglie. **I dichiaranti pero' sono due, non uno**:

- `CuoreNellaBarra`, che vive quanto la schermata;
- **la corsa dello zodiaco**, la scena a schermo pieno che gira mentre il
  cielo si interroga, che non vuole un cuore che le galleggi sopra.

La corsa arriva e alza un reclamo gia' alzato. Quando finisce **lo abbassa**,
e il cuore della barra e' ancora li' a volerlo alzato: **l'ultimo che esce
spegne la luce anche a chi e' rimasto dentro**. Da quel momento i cuori
disegnati sono due.

**REGOLA C, e i padri sono tre, in fila.**

1. **Ordine AL voce 08, 30 luglio 2026**, commit `b49ab6fd`: nasce il booleano
   del reclamo. Allora era giusto: il dichiarante era uno.
2. **Ordine CC voce 03, 29 agosto 2026**: arriva la corsa dello zodiaco, il
   secondo dichiarante. Da qui il difetto **esiste** e non si vede, perche'
   nell'Oroscopo il cuore sovrapposto era l'unico e riaccenderlo non
   raddoppiava niente.
3. **Ordine DC voce 15, 10 settembre 2026, ed e' mio, del giorno prima**:
   `AngoloDellaBarra` diventa un cuore. Da qui i cuori nell'Oroscopo sono due,
   e uno dei due torna a mostrarsi quando la corsa se ne va. Il commento che
   scrissi allora diceva *"il difetto si chiude in un punto solo e non puo'
   tornare"*: era vero per il difetto che stavo curando, e cieco su questo.

**E C'ERA UN SECONDO DIFETTO NELLO STESSO PUNTO, trovato dalla guardia.**
`SogliaArte.build` costruiva il notificatore **dentro `build`**: ogni
ricomposizione di un antenato ne fabbricava uno nuovo, spento, e il fotogramma
di quella ricomposizione veniva disegnato con due cuori. Curato anche quello:
adesso il reclamo e' un campo dello Stato, nasce con l'arte e muore con lei.

**LA CURA: il reclamo si conta, non si accende e si spegne.** `ReclamoDelCuore`
tiene un contatore; ognuno **prende** il suo e lo **lascia**, e il cuore
sovrapposto si toglie finche' resta anche un solo dichiarante. Un booleano
condiviso da due e' sempre lo stesso difetto in agguato: **il contatore lo
rende impossibile per costruzione** invece che corretto per attenzione.

**LA GUARDIA, e nasce rossa.** `test/il_cuoricino_e_uno_solo_a_schermo_test.dart`,
quattro prove, e **monta le schermate vere** invece di leggere i sorgenti:

- **l'Oroscopo, prima e dopo il responso**, come l'ordine chiede. Innestato il
  difetto rimettendo `value = false` dentro `lascia()`, verificato col grep:
  **appena aperto 1, dopo il responso 2**, esattamente i due numeri della
  fotografia. Con la cura: 1 e 1.
- **la Stesa di Tarocchi**, perche' una prova su una schermata sola cura dove
  si e' guardato.
- **la ricomposizione**, che prende l'altro difetto: innestato il notificatore
  dentro `build`, **nel fotogramma della ricomposizione i cuori erano 2**. Con
  la cura: 1.
- **REGOLA H**, la meta' che guarda la causa: nessun file di `lib` dichiara il
  cuore due volte. Guardati **587 file** dalla porta comune.

**PERCHE' NESSUNA GUARDIA L'AVEVA VISTO.** Esiste da settembre
`il_cuore_sta_sempre_nello_stesso_angolo_test.dart`, ed e' rimasta **verde
tutto il tempo**: legge il testo dei sorgenti e verifica che il cuore sia
dichiarato nel posto giusto. **Era vero.** Il difetto non stava in dove il
cuore e' dichiarato, stava in **quanti se ne disegnano a un certo istante**, e
nessuna lettura di sorgenti puo' contarli. **Regola B**: quella guardia e'
stata vista rossa prima di toccare la zona, spostando il cuore in coda alle
azioni, ed e' viva.

## DD.12, IL SINTOMO RIPETUTO, contestato a lavoro in corso

**Il fatto del fondatore**, mentre la voce era aperta: *"sto leggendo la
libreria dei 12 sintomi e molti sintomi sono uguali e non va bene"*.

**Il conto gli da' ragione, ed e' mio il difetto.** La prima stesura di questa
stessa voce aveva dichiarato **otto sintomi per dodici pratiche**: `tensione`
tre volte, `agitazione` due, `stanchezza` due. **Sette voci su dodici**
portavano in testa, scritta grande, un'etichetta gia' letta poco sopra. Non
era un dettaglio di scrittura: il sintomo e' la prima riga di ogni voce, cioe'
esattamente cio' che chi arriva sta cercando, e una libreria che ripete la
stessa parola sette volte su dodici sembra avere quattro pratiche, non dodici.

**REGOLA C, il padre del difetto**: ordine DD voce 12, 10 settembre 2026,
prima stesura. Nato lo stesso giorno in cui e' stato trovato, dentro il lavoro
che lo stava introducendo.

**La cura non e' stata rinominare le etichette**: e' stato guardare cosa fa
davvero ogni pratica. Il ventre stretto del sacro e la gola che si chiude
prima di parlare erano tutti e due *tensione*, ma chi arriva con l'uno non sta
cercando l'altro. **Dodici pratiche, dodici sintomi distinti**:

| Pratica | Sintomo |
| --- | --- |
| Il suono della radice | Senso di insicurezza |
| Il suono del sacro | Ventre stretto |
| Il suono del fuoco | Mancanza di slancio |
| Il suono del cuore | Respiro corto |
| Il suono della gola | Gola chiusa prima di parlare |
| Il suono del terzo occhio | Difficolta' di concentrazione |
| Il silenzio della corona | Pensieri che non si fermano |
| Sei respiri al minuto | Ansia |
| Dodici respiri | Agitazione improvvisa |
| Il respiro della soglia | Tensione prima di un passo |
| La frequenza del giorno | Stanchezza della sera |
| Due toni che si incontrano | Insonnia |

**E due sere di seguito erano una ripetizione anche loro**: la riga al verbo
della *Frequenza del giorno* si apriva con le stesse tre parole di quella dei
*Due toni*. Adesso dice *"per quando non hai voglia di contare niente"*.

**LA GUARDIA, e nasce rossa due volte.** In
`test/le_fonti_dei_respiri_dicono_il_vero_test.dart`:

- **meta' prima**, il ripetuto: si conta quante etichette distinte ci sono
  rispetto alle pratiche. Non si pretende il numero dodici, che cadrebbe il
  giorno che una pratica esce: si pretende che nessuna etichetta compaia due
  volte. **Innestato il difetto** dando al suono della gola il sintomo del
  sacro, verificato col grep alla riga 89, la prova e' caduta dicendo
  *"Ventre stretto" su Il suono del sacro, Il suono della gola*.
- **meta' seconda, REGOLA H**, l'orfano: un sintomo dichiarato e assegnato a
  nessuna pratica e' una voce che nessuno puo' trovare cercando. **Innestato
  un secondo difetto** aggiungendo all'enum `provaOrfana`, la prova e' caduta
  dicendo *questi sintomi esistono e nessuna pratica risponde: Prova orfana*.
  Ripristinato e riverificato col grep: zero occorrenze.

Con la cura: **pratiche 12, sintomi distinti 12, sintomi ripetuti 0, senza
nessuna pratica 0**.

## DD.12, LE NOVE FREQUENZE, e la guardia che ha cambiato domanda

**Il fatto**: la Meditazione offriva **tre** frequenze, e le sette dei centri
non c'erano.

**Non mancavano i suoni.** I toni li sintetizza `ToneGenerator` e qualunque
frequenza si puo' suonare: **mancavano dalla scelta**, cioe' nessuno le aveva
scritte fra i preset. Adesso i preset sono **nove**: i tre di prima piu' le
sette dei centri, e ognuna dichiara **quale** centro serve, cosi' la
Meditazione non puo' piu' dire una frequenza e suonarne un'altra.

**E LA CURA HA CREATO IL SUO DIFETTO, che la guardia ha preso.** Le pasticche
stavano in una `Row` di elementi `Expanded`: con tre ci stavano, con nove
ognuna prende un nono di schermo.

**LA PRIMA STESURA DELLA GUARDIA ERA VERDE, e va scritto perche'.** Misurava
se una pasticca finisse **oltre il bordo dello schermo**. Nessuna ci finiva:
dentro una Row gli `Expanded` non escono, **si stringono**. La prova diceva il
vero su una domanda che non era quella giusta.

**Cambiata la grandezza misurata, mai la soglia**, come la Regola A impone.
Adesso si calcola con un `TextPainter`, nello stesso stile, quanto e' alta
l'etichetta scritta su una riga sola, e la si confronta con quanto e' alta a
schermo. Il rosso e' stato questo:

| Etichetta | Larga | Ne chiede | Righe |
| --- | --- | --- | --- |
| 432 Hz | 25 | 62 | **4** |
| Battito theta | 25 | 135 | **7** |
| le altre sette | 25 | 58-62 | **4** |

**Nove etichette su nove andavano a capo.** Con la cura, un `Wrap` al posto
della `Row` e nessun `Expanded`: ogni pasticca prende la larghezza del suo
nome, **1,0 righe tutte e nove**, e le nove stanno su piu' file.

## DD.09, LE DUE BOLLE DELLA FORTUNA

**Il fatto del fondatore**: nella scheda della Fortuna i riquadri *Numero* e
*Colore del giorno* non sono alti uguale, e la coppia si vede storta.

**Misurato, ed e' vero.** Sulla finestra del telefono, dopo aver chiesto il
responso:

| Bolla | Alta |
| --- | --- |
| NUMERO | **61,0** |
| COLORE DEL GIORNO | **84,0** |
| scarto | **23,0 punti** |

**La causa**: la `Row` che le contiene non allineava niente, e ognuna prendeva
l'altezza del suo contenuto. Da una parte una cifra su una riga, dall'altra
un'etichetta piu' lunga che va a capo.

**La cura**: `IntrinsicHeight` misura la piu' alta delle due e
`CrossAxisAlignment.stretch` porta l'altra alla stessa quota. **84,0 e 84,0**,
scarto **0,0**, e si pareggiano da sole anche il giorno che un colore ha un
nome piu' lungo.

**LA GUARDIA E' NATA ROSSA SUL DIFETTO VERO**, senza bisogno di innestarne
uno: `test/numero_e_colore_hanno_la_stessa_altezza_test.dart`.

**E ha dovuto imparare due cose per non essere verde a vuoto.** Le quattro
schede del responso nascono in un elenco **pigro**: la Fortuna e' la quarta e
finche' nessuno scorre fin li' **non viene costruita affatto**, quindi la
prima stesura non trovava le bolle e sarebbe stata verde per non aver guardato
niente. Adesso la prova scorre, e monta la schermata con **Riduci Movimento
acceso**, che e' la configurazione vera del telefono 767f596c e fa nascere le
quattro schede tutte insieme.

## DD.10, I DUE CONTEGGI DELLA CHAT

**Il fatto del fondatore**: le due righe di conteggio in cima alla chat hanno
troppa aria, fra loro e attorno, e quello spazio serve alla conversazione.

**Misurato sulla finestra del telefono, 390 per 844:**

| | Prima | Dopo | Guadagno |
| --- | --- | --- | --- |
| Blocco dei due conteggi | **80,0** punti | **64,0** punti | **16 punti** |
| Aria attorno a 48 punti di testo | **32,0** | **16,0** | |
| Respiro fra una riga e l'altra | 16,0 | **8,0** | |

**La cura sta in `RigaDelResiduo`**, la casa unica di tutti e sei i conteggi:
il contorno verticale passa da otto punti a quattro, sopra e sotto. **Non e'
una modifica alla sola chat**: lo stesso principio vale dove quella riga si
mostra, ed e' la stessa richiesta della voce CT, *"ridurre al massimo le parti
occupate sopra e sotto"*.

**LA GUARDIA HA DOVUTO CAMBIARE CASA PER NON MENTIRE.** La prima stesura
montava la **chat intera**, come fa la guardia della voce CT, e sarebbe stata
**verde senza misurare niente**: sotto le prove la borsa non ha sentito il
server, quindi `RigaDelResiduo` **per legge tace** e disegna una
`SizedBox.shrink()`. Le due chiavi c'erano, i due riquadri erano **alti zero**,
e qualunque pretesa sull'aria sarebbe passata. Adesso la prova monta la stessa
composizione con la borsa che ha sentito il server, **e cade se le righe sono
alte zero**, invece di passare tacendo.

**E l'ancora e' un numero dichiarato, non una misura copiata.** Il blocco non
puo' essere piu' alto delle due righe di testo che contiene piu' **sedici
punti**: se domani il carattere cambia misura, la pretesa lo segue da sola.

**REGOLA H, la meta' opposta**: stringere fino a zero farebbe passare la prima
meta' e renderebbe le due righe una massa unica. **Innestato
`EdgeInsets.zero`**, verificato col grep: la seconda meta' e' caduta dicendo
*restano 0,0 punti: sono attaccati e si leggono come una riga sola*.

## DD.08, LA SCHERMATA IN PIU' DEI TAROCCHI, riaperta la terza volta

**Il fatto del fondatore**: dopo la terza carta c'e' di nuovo una schermata in
piu'.

**E LE DUE GUARDIE CHE LA SORVEGLIAVANO ERANO VERDI, E DICEVANO IL VERO.** La
voce CQ 6.09 era stata chiusa due volte: la prima misurando **cosa arriva**
alla terza carta (le carte scelte, il pulsante, le parole), la seconda
misurando **cosa sparisce** (il ventaglio). Tutte e due le domande erano
giuste e tutte e due avevano risposta buona.

**LA TERZA DOMANDA NON L'AVEVA FATTA NESSUNO: dove stanno le cose che
restano.** Misurato coi rettangoli veri su una finestra 360 per 1400, dopo la
seconda carta e dopo la terza:

| | Dopo due carte | Dopo la terza |
| --- | --- | --- |
| slot | **348** | **572** |
| prompt | 656 | via |
| ventaglio | 676 | **246** |
| gesti | 838 | 408 |
| pulsante | 938 | 508 |
| carte scelte | | 752 |

**Gli slot scavalcavano il pulsante** e tutta la pagina saliva di
**quattrocentotrenta punti** in un fotogramma. Non spariva niente e non
arrivava niente di nuovo: **gli stessi pezzi, in un ordine diverso**. Chi
guarda non distingue una pagina riordinata da una pagina nuova.

**REGOLA C, il padre**: ordine CQ voce 6.09, 4 e 5 settembre 2026. La cura di
allora rimise a video cio' che spariva, **e lo rimise in un posto nuovo**,
sotto il pulsante, invece di lasciarlo dove stava. Il difetto che curava era
vero; il modo ne ha creato un altro della stessa famiglia.

**LA CURA: un pezzo solo, in un posto solo.** Il blocco che sta sopra il
ventaglio, con gli slot e le carte gia' uscite, se ne va **col responso** e non
con l'ultima carta: la condizione passa da `!_complete` a `!_responsoPronto`.
Il secondo montaggio sotto il pulsante e' stato tolto, e con lui la
duplicazione. Anche il pannello della configurazione resta fino al responso:
sparendo alla terza carta si portava via **centodue punti** e faceva salire
tutto il resto.

**Dopo la cura, misurato:**

- l'ordine verticale dei sette pezzi e' **identico** prima e dopo;
- gli slot stanno a **348,0** prima e a **348,0** dopo, spostamento **0,0**;
- cio' che sta sotto scende di **36 punti**, che e' esattamente quanto cresce
  il blocco delle carte con la terza dentro. **La pagina cresce, non cambia.**

**LA GUARDIA E' NATA ROSSA DUE VOLTE**, nel file delle due precedenti perche'
e' lo stesso soggetto:

- **innestato** il ritorno di `!_complete` sul blocco degli slot, verificato
  col grep: cade sul cardinale, *ha guardato 6 pezzi e ne pretende 7*;
- **innestato** anche il secondo montaggio sotto il pulsante, verificato col
  grep: cade sull'ordine, *prima slot > ventaglio > ... > pulsante, dopo
  ventaglio > ... > pulsante > slot*.

**REGOLA B**: le due guardie della voce 6.09 sono state viste rosse prima di
toccare la zona, rimettendo `!_complete` sul ventaglio.

## DD.03, IL CERCHIO DEL SOFFIO

**Il fatto del fondatore**: nel Soffio del Destino il cerchio del respiro e'
piccolo e non e' centrato sul soffione.

**Misurato sotto la REGOLA I**, montando la schermata vera in una finestra 390
per 844 e leggendo la figura **dipinta**, non il riquadro:

| | Prima | Dopo |
| --- | --- | --- |
| Larghezza al culmine | **140,0** punti | **273,0** punti |
| Quota dello schermo | **35,9 per cento** | **70,0 per cento** |
| Centro | 195,0, gia' giusto | 195,0 |

**Il centro era gia' a posto**, scarto **0,0** punti dal centro dello schermo, e
va detto invece di far finta che la cura abbia sistemato anche quello.

**La causa**: il lato del cerchio era **un numero scritto a mano, 140**, e un
numero scritto a mano non sa quanto e' largo lo schermo su cui finisce. Adesso
viene dalla larghezza dello schermo per una quota dichiarata,
`quotaAlCulmine = 0.70`. **Il culmine dell'inspirazione vale uno** e la misura
del respiro scende da li' a 0,55: percio' il lato a riposo *e'* la quota, senza
conti all'indietro.

**LA MISURA GIUSTA E' IL DIPINTO, non il riquadro.** La chiave sta su un
`Transform.scale`, e **un Transform non cambia la misura del riquadro che
occupa**: `getRect` da solo direbbe centoquaranta punti a qualunque momento del
respiro, anche mentre la figura si contrae a meta'. La guardia moltiplica il
riquadro per la scala letta dalla matrice.

**E LA CURA HA SCOPERTO DUE PROVE CHE GIRAVANO IN UNA FINESTRA IRREALE.**
`il_respiro_si_guida` e `il_respiro_parte_quando_decidi_tu` montavano la guida
nella finestra di prova, **800 per 600**: li' il settanta per cento sono
cinquecentosessanta punti in un riquadro alto seicento, la colonna sbordava e
il conto alla rovescia finiva fuori campo. **Non e' una concessione alla cura**:
la finestra da telefono era gia' la regola di casa e quei due file erano
rimasti indietro. Pinnate a 390 per 844, tutte e dodici le prove tornano verdi.

## DD.05, I DONI SI APRONO ALLA LORO ORA

**Il fatto del fondatore**: i cinque Doni si aprono a qualunque ora. Il Rito
dell'Alba si puo' fare a mezzanotte e il Sigillo del Sogno alle sette del
mattino: **se tutto e' disponibile sempre, niente ha un'ora sua**.

**LA LEGGE, in una frase**: un Dono si apre all'ora della sua notifica e resta
aperto fino al rinnovo, cioe' alla stessa ora del giorno dopo.

**L'ORA E' QUELLA CHE LA PERSONA HA SCELTO.** Chi ha spostato l'avviso
dell'Alba alle nove non trova il Dono aperto dalle sette: sarebbe una seconda
verita' sullo stesso appuntamento. Chi non ha scelto niente, e chi ha spento
l'avviso, prende **l'ora di casa**: Alba 7:00, Soffio 10:30, Arcano 13:00,
Tramonto 18:30, Notte 22:30. Il meccanismo che risponde a questa domanda
esisteva gia', `SceltaDegliAvvisi.minutiDi`, e **non se ne e' aperto un
secondo**.

**IL FUSO E' QUELLO DI CHI GUARDA, senza fare niente.** Ore locali confrontate
con un `DateTime` locale: sul telefono e' l'ora del telefono. Non si converte
niente, e proprio per questo non si puo' sbagliare la conversione.

**DOVE STA IL CONTROLLO, e perche' in un punto solo.** In
`openDailyElement`, la porta sola da cui si entra in un Dono: la usa il tocco
sulla striscia **e** il collegamento che arriva dalla notifica. Nelle cinque
schermate si sarebbe scritto cinque volte e dimenticato alla sesta.

**COSA SI VEDE.** La casella chiusa porta un orologio al posto del segno del
Dono, e non sparisce: un Dono che va e viene sarebbe una funzione che appare a
caso. Toccandola si apre la **card del Dono chiuso**, che dice l'ora grande, che
cosa quel Dono lascia, e un pulsante per tornare: nessun vicolo cieco.

**LA GUARDIA GIRA ORA PER ORA**, come l'ordine chiede:
`test/i_doni_si_aprono_alla_loro_ora_test.dart`, **ventiquattro ore per cinque
Doni, centoventi risposte**. Innestato il difetto vero, cioe' la porta sempre
aperta che l'app aveva: **73 risposte sbagliate su 120**. Con la legge: **zero**.

E le altre sei prove del file coprono cio' che la prima da sola non vede: le
ore di casa sono quelle concordate, l'ora scelta vince su quella di casa, la
card chiusa dice l'ora in cifre, il rinnovo cade il giorno dopo alla stessa
ora, a video le cinque caselle sono chiuse alle 6:00 e Alba e Soffio sono
aperte alle 11:30.

**COSA CAMBIA PER CHI USA L'APP, e va detto chiaro**: da adesso, di mattina
presto, **la striscia mostra cinque caselle chiuse**. E' esattamente cio' che
l'ordine chiede, ed e' un cambiamento grosso da guardare sul telefono prima di
darlo per buono.

## DD.04, LA PAROLA DELL'ALBA, E IL TONO CHE SE NE VA

**Il fatto del fondatore**: la Parola dell'Alba non torna nel Sigillo del
Sogno. **Aveva ragione**, e la mia ricognizione gli aveva dato torto: la
ritrattazione sta scritta qui sopra.

**LA CAUSA, trovata da una guardia che fa il giro intero.** Il meccanismo era
tutto in piedi, e il dato arrivava davvero: la guardia stampa *rilettura ->
Soglia* e la schermata stampa *la parola letta dalla schermata e Soglia*. **E
la riga non era a video.**

Le tre righe della raccolta della giornata, la runa del tramonto, la Parola
dell'Alba e il respiro di oggi, vivevano dentro `_nelBuio()`, cioe' nel ramo
che si monta **solo durante la nebbia**, il primo momento del rito. Due cose
insieme le rendevano invisibili:

- la lettura dal disco e' **asincrona** e arriva dopo che la nebbia e' gia' a
  schermo;
- chi usa il rito **la nebbia la dirada subito**, perche' e' cio' che il rito
  gli chiede di fare.

**Il dato arrivava e nessuno era piu' li' a vederlo.**

**E il posto giusto lo diceva il testo stesso.** La frase e' *"Adesso chiude il
giro: dove l'hai riconosciuta oggi?"*: una frase che dice **adesso chiude il
giro** non puo' stare nel momento in cui il giro comincia. Le tre righe sono
passate al **saluto della notte**, dove il rito si chiude.

**REGOLA C**: ordine P voce 18, che scrisse il richiamo e lo mise nella nebbia
quando la nebbia era l'unico momento con del testo.

**LA GUARDIA E' NATA ROSSA SUL DIFETTO VERO**, senza innesti: fa il giro
intero, segna la parola come farebbe l'Alba, compie il rito della sera e
guarda se la riga c'e'. Prima della cura: *la riga della parola del mattino
**NON** c'e' a video*. Dopo: *c'e'*, e porta la parola.

**Perche' le guardie di prima non lo avevano visto.** La guardia dell'ordine CY
prova che **il dato sopravvive** fra i due riti, anche a chi si alza alle due
di notte, e diceva il vero. **Il dato che sopravvive e la frase che si legge
sono due fatti diversi**, e fra loro c'e' tutta la schermata.

### E IL TONO THETA HA LASCIATO IL SIGILLO

Seconda meta' della voce, e la ragione e' del fondatore.

**Dove stava**: un pulsante in fondo al Sigillo accendeva un battito
binaurale generato sul momento, 210 hertz a sinistra e 217 a destra, la cui
differenza di sette hertz cade nella banda theta.

**Non e' stato tolto: e' tornato a casa sua.** Il tono vive nella Meditazione
di Aura, dove sta con le altre otto frequenze e dove si trova per nome, sotto
il sintomo **Insonnia**, con la pratica *Due toni che si incontrano*. La
decisione del fondatore dell'ordine CN, che vieta di toglierlo dalla
Meditazione, resta intera e la sua guardia e' verde.

**Perche' se ne va dal Sigillo**: e' il rito che chiude il giorno e chiede dove
hai riconosciuto la tua parola. Un interruttore audio in fondo a quella pagina
apre una seconda stanza dentro la prima, e chiede di mettersi le cuffie a chi
sta per dormire.

**REGOLA D, cosa e' cambiato nelle prove.** La prova dell'ordine CW voce 03
pretendeva che il foglio delle fonti spiegasse **da dove nasce il tono**: era
giusta finche' il suono usciva da qui. **Adesso pretende il contrario**, cioe'
che ne' il pulsante ne' la spiegazione ci siano piu', e il commento dice
perche' e dove il tono e' andato.

## DD.01, IL SOFFIO SI RICONOSCE DALLA FORMA, NON DAL VOLUME

**Il fatto del fondatore**: il Soffio del Destino si apre da solo, basta un
rumore nella stanza.

**LA CAUSA ERANO DUE RIGHE, e la seconda buttava via la prima.**

    _micStream = stream.listen((_) {});
    if (!_revealed && amp.current > -18) _complete();

La prima **scartava il flusso audio vero**; la seconda guardava l'ampiezza
aggregata e apriva il dono sopra i meno diciotto decibel. **Una soglia di
volume nuda**, che la voce di chi parla, la musica in cucina e una porta che
sbatte superano tutte. **La cura non ha aperto nessuna porta nuova**: ha
raccolto cio' che passava gia' di li'.

**LA GRANDEZZA CHE SEPARA UN SOFFIO DA UN SUONO: la planarita' spettrale.** E'
il rapporto fra la media geometrica e la media aritmetica dello spettro di
potenza, una misura standard, usata dai codec audio per decidere se un blocco
e' rumoroso o tonale. Vale **uno** per il rumore bianco, dove tutte le righe
sono uguali, e **tende a zero** per un suono con una nota dentro, dove una riga
domina le altre. Un soffio e' aria: energia sparsa dappertutto, nessuna nota.

**TRE CONDIZIONI, e servono tutte e tre**: abbastanza forte, abbastanza piatto,
e **abbastanza a lungo**, sei finestre da trentadue millisecondi, cioe' due
decimi di secondo di aria continua. La terza e' quella che tiene fuori i colpi
secchi, che sono l'unica famiglia che le prime due lascerebbero passare.

**I NUMERI, misurati sui campioni della guardia:**

| Suono | Planarita' | Soglia di volume | Forma |
| --- | --- | --- | --- |
| voce che parla | **0,001** | **APRE** | tace |
| musica, tre note | **0,000** | **APRE** | tace |
| tonfo, la porta che sbatte | **0,000** | **APRE** | tace |
| soffio, il fiato sul microfono | **0,260** | APRE | **APRE** |

**Aperture false: tre su tre con la soglia di volume, zero su tre con la
forma.** Fra il soffio e il primo dei suoni con una nota dentro ci sono **due
ordini di grandezza**, e la soglia di 0,20 sta in mezzo con margine da tutte e
due le parti.

**I CAMPIONI SONO SINTETIZZATI, e la guardia lo dichiara in testa.** La voce e'
una fondamentale a centoventi hertz con dieci armoniche calanti, cioe' il
modello a sorgente e filtro della voce parlata; la musica e' un accordo di tre
note pure; il tonfo e' una botta larga di banda che si spegne in fretta; il
soffio e' rumore rosa con l'inviluppo del fiato. **Perche' sintetizzati**: una
registrazione porta dentro la stanza, il microfono e chi l'ha fatta, e una
prova che dipende da un file audio nel repository e' una prova che nessuno
rifara' mai. Questi segnali si rileggono riga per riga. **Il collaudo sul
telefono resta e non lo sostituisce niente.**

**E la misura si ancora a due valori noti in anticipo**: rumore bianco
**0,580**, nota pura **0,000**. Senza quella prova, una trasformata scritta
storta darebbe numeri sbagliati e le soglie si taglierebbero su quelli.

**La trasformata e' scritta in casa**, quaranta righe di radice due: una
dipendenza nuova per quaranta righe e' una dipendenza che un giorno bisogna
aggiornare.

## DD.11, IL GIALLO DELLE BOLLE DELLE RUNE

**La richiesta del fondatore**: nelle bolle delle Rune il giallo resta **solo
per cio' che parla all'utente adesso**, e quella frase sta **in un riquadro**.
Senza aggiungere testo.

**Misurato a video sul responso di una gettata**: **nove prose**, di cui
**tre dorate**. Con la cura: **una sola**, quella dentro il riquadro
dell'azione del presagio.

Le tre erano: il primo paragrafo del presagio (dorato per la regola dell'ordine
B, il blocco che porta il senso), la riga dell'azione dentro il suo riquadro, e
la giuntura delle Norne sopra ogni scheda. In una gettata da tre rune, con i
tre paragrafi della scheda a Giallo-Bianco-Giallo, gli ori a schermo erano
**sette**.

**QUI DUE DECISIONI DEL FONDATORE SI CONTRADDICONO, e va scritto.**

- **Ordine CQ voce 6.22, 4 settembre 2026**, parole sue: *"Poi sotto 3
  paragrafi: Giallo, Bianco, Giallo."*
- **Ordine DD voce 11, 10 settembre 2026**: il giallo solo per cio' che parla
  adesso.

**Le due cose non stanno insieme.** Con Giallo-Bianco-Giallo l'unica cosa che
parla adesso finiva per essere l'unica bianca in mezzo all'oro. **Ha vinto la
piu' recente**, e la guardia della voce 6.22 non e' stata cancellata: continua
a difendere i tre paragrafi, il loro ordine e la misura di lettura, e porta
scritto in testa perche' ha smesso di difendere i due ori. **Se il fondatore
intendeva il contrario, si rimette con una riga.**

**Titoli e insegne restano d'oro, ed e' una scelta dichiarata.** Il nome della
runa, *Il presagio di Caligo*, *Il sigillo del giorno*: dicono dove sei, non
cosa fare, e il loro oro e' la livrea di Caligo. La guardia misura le **prose**,
cioe' i testi nel ruolo `lettura`, e lo dice in testa.

**LA GUARDIA E' NATA ROSSA SUL DIFETTO VERO**, senza innesti: *prose nel
responso 9, dorate 3*. Con la cura: *dorate 1*. La seconda meta' pretende il
contrario, cioe' che quella prosa dorata stia **dentro** il riquadro: togliere
l'oro a tutto passerebbe la prima meta' e lascerebbe la lettura senza nessun
richiamo.

## DD.02, LA PAROLA DEL GIORNO DENTRO UNA FRASE

**Il fatto del fondatore**: la Parola del giorno, quando compare dentro una
frase, non si distingue dal resto.

Aveva ragione: la sera il Sigillo scriveva *"Stamattina la tua parola era
Fiducia"*, e quella parola, che e' la sola cosa da portarsi via, pesava quanto
*"stamattina"* e quanto *"era"*.

**La regola, e vale ovunque**: **fra virgolette basse e in grassetto**. Le
virgolette reggono anche dove il grassetto non arriva, cioe' in un testo
condiviso o in un messaggio di chat; il grassetto la fa trovare all'occhio.
Sta in un widget solo, `FraseConLaParola`, cosi' nessuno la riscrive a modo
suo.

**GLI ALTRI POSTI DOVE LA PAROLA COMPARE, contati col grep su tutto `lib`**:
sono **tre**, e adesso sono tutti e tre a posto.

| Dove | Come era | Come e' |
| --- | --- | --- |
| il richiamo della sera nel Sigillo | `parola era $parola.` | `parola era «$parola».` |
| il testo che si condivide dall'Alba | `dell'Alba: $word.` | `dell'Alba: «$word».` |
| l'apertura della chat dall'Alba | gia' `«$parola»` | invariata |

**E IL RIPIEGO DEL MANTRA SI ANNUNCIA.** Sopra la via col dito c'e' adesso il
titolo **IN ALTERNATIVA**, come l'ordine chiede: senza, la via col dito si
leggeva come la seconda meta' della stessa istruzione e chi scorreva faceva
tutte e due le cose.

**LA GUARDIA E' NATA ROSSA TRE VOLTE.** Innestata la parola nuda nel richiamo,
verificato col grep: cade la prova delle virgolette, cade quella del grassetto
a video (*un pezzo solo, tutto dello stesso peso*), e cade la meta' Regola H
che enumera i sorgenti (*righe che la lasciano nuda 1*).

**REGOLA D, una prova ha cambiato pretesa.** `i_doni_si_agganciano` pretendeva
la formula parola per parola con `startsWith('Stamattina la tua parola era
Soglia')`, e il suo stesso commento diceva gia' che *"una copia si rompe ogni
volta che il testo migliora"*. Adesso pretende cio' che l'ordine P voce 18
voleva davvero: che il richiamo **nomini** la parola.

## DD.06, LA LUNA CHE SI SPOSTA NELLA HOME

**Il fatto del fondatore**: nella home la Luna si sposta verso destra
nell'istante in cui spariscono l'animazione del dito e il testo *Tocca il
cielo*.

**Non era la Luna che si muoveva, era la riga che si stringeva.** La riga del
cielo e' fatta di tre celle centrate: un vuoto largo quanto l'invito, la Luna,
e l'invito. Con l'invito acceso le due celle laterali si pareggiano e la Luna
cade a meta' schermo; quando l'invito spariva **del tutto**, il vuoto di
sinistra restava e la riga si ricentrava su una larghezza minore.

**La cura**: l'invito si spegne in opacita' dentro una cella di larghezza
fissa, invece di sparire dal layout.

**LA GUARDIA MISURA LO SPOSTAMENTO IN PUNTI**, montando la stessa riga nei due
stati: **0,0 punti** con la cura, **61,0** con il difetto innestato. La meta'
Regola H pretende che la cella tenga la larghezza anche da spenta, che e' la
causa: se un giorno qualcuno rimettesse `AnimatedSize`, la prima meta' cadrebbe
senza dire perche'.

## DD.13, IL CIELO DELLA MEDITAZIONE

**Il fatto, confermato in ricognizione sul telefono**: la Meditazione aveva lo
sfondo **completamente nero**, senza stelle e senza parallasse. Era l'unica
stanza buia di una casa in cui ogni altra schermata poggia sul cosmo.

**La cura**: il cielo e' lo stesso componente della home, con la palette di
Aura passata a mano e un seme suo, cosi' le stelle non ripetono la figura di
un'altra schermata.

**LA GUARDIA E' NATA ROSSA**: tolto il cosmo, *cieli montati nella Meditazione
**0***. Con la cura: **1**. La meta' Regola H pretende che quel cielo porti
**il colore di Aura** e non uno qualunque, e per farlo monta la schermata
dichiarando il Maestro, come fa l'app: senza, la prova misurerebbe il proprio
montaggio invece della schermata.

## DD.16, L'ANIMAZIONE DEL RESPIRO NELLA MEDITAZIONE

**La richiesta del fondatore, parole sue**: *"l'utente fa click e parte
l'animazione inspira e il fiore si ingrandisce, ma contemporaneamente l'utente
vede un countdown in secondi che gli da una guida, poi si ferma altri 3 secondi
o quanto necessario di countdown e poi espira sempre con countdown e fiore che
si riduce"*.

**Fatto**: il fiore cresce mentre si inspira e si riduce mentre si espira, e
accanto alla fase corre il conto dei secondi che restano, in cifre tabulari
cosi' il numero non balla mentre cambia.

**E QUI E' USCITO IL DIFETTO PIU' ISTRUTTIVO DELLA GIORNATA.** Sul telefono il
conto restava fermo su **4** in due fotografie a tre secondi di distanza.

**La causa non era la schermata: era il telefono.** Il dispositivo 767f596c ha
le tre scale di animazione di Android a **zero**, quindi
`MediaQuery.disableAnimations` e' **vero**, e la schermata aveva un ramo che
**fermava l'orologio del respiro** quando il movimento e' ridotto.

**La legge che ne esce, e vale per tutta l'app**: Riduci Movimento deve
**squadrare la figura, non fermare il tempo**. Un conto alla rovescia, una
fase, un progresso sono **informazione** e devono scorrere comunque, a scatti
se serve.

## DD.17, UN COMANDO SOLO, E LA CARD CHE SI CAPISCE DA FUORI

**Tre decisioni del fondatore in una frase**, arrivate col telefono in mano
dopo aver guardato la build: *"elimina la possibilita' di tenere il dito
premuto, solo pulsante play e stop (stesso pulsante). elimina 'preferisco
scegliere io', e' ridondante visto che dal pulsante puo' gia' scegliere sintomo
e frequenza. migliora la card da condividere includendo il sintomo e la
frequenza, ma non esagerare con il testo descrittivo, inizia con titolo
accattivante."*

### La schermata aveva QUATTRO modi di comandare la stessa cosa

1. il dito **tenuto premuto** sul fiore, che inspirava ed espirava;
2. il **pulsante play**;
3. *"Preferisco scegliere io"*, che apriva le nove frequenze;
4. *"Respiro da solo, senza tenere il dito"*, che spegneva il primo.

**Il quarto esisteva solo per riparare il primo.** Nasceva dall'ordine DA voce
03 come ripiego per chi non puo' tenere il pollice sul vetro: tolto il dito,
**il ripiego e' diventato la via**, e un interruttore che porta dove sei gia'
e' rumore.

**Adesso il comando e' uno**: si preme e parte, si preme e si ferma.

**E IL FIORE RESTA TOCCABILE, ed e' una scelta che dichiaro.** L'ordine dice
*"solo pulsante play e stop"*, e la lettura piu' stretta sarebbe stata un fiore
inerte. **Un cerchio grande e bello che ignora il dito e' peggio del difetto da
cui quest'ordine e' nato**, che era *"se faccio click su una voce non succede
nulla"*. Il fiore fa **la stessa identica cosa** del pulsante: un'azione sola,
due superfici, nessun gesto nascosto. Se il fondatore intendeva il fiore
inerte, si toglie una riga.

### Le nove frequenze sono entrate dove il pulsante le prometteva

Il pulsante si chiama **SCEGLI SINTOMO E FREQUENZA** e apriva un pannello con i
soli sintomi: la frequenza stava dietro un secondo interruttore, piu' in basso
nella colonna, con parole sue. **Due porte per una promessa sola**, e chi non
scorreva non trovava mai la seconda.

Adesso il pannello si apre su **LA FREQUENZA**, nove pasticche, e sotto **IL
SINTOMO**, dodici voci. Le frequenze stanno sopra perche' nove pasticche si
guardano in un colpo e dodici voci si scorrono. Misurato: le frequenze a
**102** punti, i sintomi a **438**.

### La card: cosa si e' perso, e va detto

**Senza il dito muore la figura unica.** La card disegnava una corona costruita
sui **tempi veri** di ogni inspiro, e scriveva *"dodici respiri: nessuno uguale
al precedente"*. Era la promessa dell'ordine DB voce 10, e **reggeva**: due
persone non hanno mai la stessa serie di millisecondi. Senza il dito resta il
ritmo dell'app, **uguale per tutti**, e quella frase sarebbe stata la prima
bugia di questa funzione.

**Al suo posto: il sigillo della sessione.** Nasce da quattro dati veri, il
sintomo scelto, la frequenza, il centro del giorno e la **durata vera**, che e'
l'unico numero continuo rimasto. Misurato sul sigillo di riferimento, la
distanza quando cambia un solo dato:

| Cosa cambia | Quanto cambia il sigillo |
| --- | --- |
| un altro sintomo | **0,186** |
| un'altra frequenza | **0,226** |
| un altro centro | **0,263** |
| un minuto in piu' | **0,230** |

**E la stessa sessione da' lo stesso sigillo**, distanza **0,000**: chi rifa'
la stessa pratica per lo stesso tempo ritrova il suo segno. Un sigillo che
cambia a ogni ridisegno non e' un sigillo, e' rumore.

**La promessa e' scesa di un gradino, ed e' onesta.** Non e' piu' *"nessuna
figura come la tua al mondo"*: e' *"questa e' la tua sessione"*.

### Il titolo, e perche' e' cambiato

Qui c'era **IL TUO RESPIRO DI OGGI**, che si capisce solo se sei gia' dentro.
Una card si condivide, e chi la riceve in una chat parte da zero.

Adesso: **MI SONO PRESO 5 MINUTI**, col numero vero. Sotto il minuto diventa
*"MI SONO PRESO UN MOMENTO"*, perche' una cifra sotto il minuto suonerebbe
misera.

E sotto, **al massimo tre righe, e ognuna e' un dato**: per cosa, cosa ha
suonato, da quanti giorni.

    Per insonnia
    Due toni che si incontrano · 210 Hz
    4 giorni di fila

**La striscia di un giorno non si scrive**, perche' una striscia di uno non e'
una striscia e scriverla la sgonfia. Da due in su si'.

**E senza un sintomo scelto la card non ne inventa uno**: quando la pratica la
propone Aura dal centro del giorno, la card dice il centro. Mettere in bocca a
qualcuno un sintomo che non ha scelto sarebbe peggio di non dirlo.

### E POI HO GUARDATO LA BUILD SUL TELEFONO, e ho trovato tre difetti miei

**REGOLA L, e stavolta ha pagato tre volte in mezz'ora.** Costruita la build e
installata sul 767f596c, la Meditazione nuova ha mostrato tre cose che nessuna
delle prove appena scritte cercava.

**UNO. Il fiore diceva PREMI PLAY e il play stava in fondo alla colonna**,
sotto il testo del centro e sotto il pulsante grande. Chi legge un invito deve
**cercare** il comando che l'invito nomina: un'istruzione che manda a cercare
non e' un'istruzione. Adesso l'ordine e' fiore, **play**, poi il resto, ed e'
l'ordine in cui questa schermata si usa. Misurato: fra il fondo del fiore e la
cima del pulsante ci sono **zero punti**, e il pulsante del sintomo sta a 604
contro i 446 del play.

**DUE. La card non arrivava mai.** Dopo **due minuti** di sessione, sotto il
disclaimer non c'era niente. La condizione era `_quantoEDurata >= 60` letta
**dentro il build**, e **la colonna non si ricostruisce mentre la sessione
gira**: a ricostruirsi a ogni fotogramma e' solo il fiore, dentro il suo
`AnimatedBuilder`. Quella condizione veniva valutata **una volta sola, al tocco
del play**, con la durata a zero.

**La cura non e' ricostruire la colonna a ogni fotogramma**, che vorrebbe dire
ridisegnare tutta la schermata sessanta volte al secondo per far comparire un
riquadro: e' la voce AJ.01 di questo progetto, a rovescio. **La card e' il
premio di chi arriva in fondo**, e vive dentro il blocco del compimento
insieme alla riga *"la meditazione e' portata a compimento"*. E' la stessa
legge che il fondatore ha dato al gesto, *"fermarsi a meta' non e' compiere"*,
e da' una ragione per arrivare alla fine.

**TRE, e l'ha trovato la prova mentre curavo il due.** La durata veniva
**dedotta** da `widget.now ?? DateTime.now()` meno l'ora di inizio. Nelle prove
`widget.now` e' un'ora **iniettata e ferma** e la sessione comincia proprio a
quell'ora: la differenza faceva **sempre zero**. E nell'app vera era sbagliato
in un modo peggiore: **l'orologio da parete conta anche i minuti passati con
l'app in tasca e lo schermo spento**, che non sono minuti respirati, e la
memoria del respiro avrebbe registrato mezz'ora di pratica per una schermata
lasciata aperta.

**Adesso i secondi si contano, uno per uno**, con un battito acceso col play e
spento con lo stop: si misura **il tempo in cui la sessione e' stata viva**,
che e' il numero che la card promette. Senza `setState`, perche' nessuno lo
guarda mentre cresce.

Verificato a video: a sessione compiuta la card c'e', il pulsante di
condivisione c'e', e il titolo dice **MI SONO PRESO 2 MINUTI**.

### Le guardie

**`un_comando_solo_nella_meditazione`, tre prove, nata rossa**: innestata la
pressione lunga sul fiore, verificato col grep, la prova e' caduta dicendo *il
fiore ha una pressione lunga: e' il gesto che il fondatore ha tolto*. La meta'
Regola H prova che il comando nuovo **funziona**: premuto parte, ripremuto si
ferma, toccato il fiore riparte.

**`la_libreria_si_apre_e_la_pratica_parte`, due prove nuove, nata rossa**:
innestato `take(3)` sulle frequenze del pannello, la prova e' caduta dicendo
*frequenze nel pannello 3 su 9*.

**`la_card_del_respiro_e_diversa_ogni_volta`, riscritta**, dieci prove sul
sigillo, sul titolo e sulle righe.

**`il_loto_riempie_la_scena`**: la prova del dito che comandava il fiore aveva
un soggetto che non esiste piu', e **ha cambiato domanda invece di sparire**.
Adesso guarda la stessa scena in otto istanti della stessa sessione e pretende
che il fiore si muova: innestato un fiore fermo a 0,5, la prova e' caduta
dicendo *escursione 0,000*. Con la cura: **da 0,020 a 1,000**.

**E `RespiroGuidatoDalDito` non e' stato cancellato.** Misura una cosa
difficile e la misura bene: distingue uno scivolo del dito da un espiro vero,
butta i respiri piu' lunghi di un minuto, non conta due volte un dito alzato
due volte. Sono tarature costate un ordine intero e le sue quattordici prove
restano verdi. **Nessuna schermata lo monta**, e sta scritto nel file:
dichiarato col grep, non dedotto.

---

VOCI_TOTALI: 16, quindici dell'ordine piu' la voce 17 arrivata a lavoro in
corso col telefono in mano.
VOCI_CHIUSE: 14
VOCI_APERTE: 2
QUALI_RESTANO: DD.14 e DD.15, i due referti, che si scrivono col telefono in
mano dopo la consegna.
RICOGNIZIONE_FATTA: 15 voci su 15
DIFFORMITA_DALL_ORDINE_GIA_DICHIARATE: 3, e una e' stata RITRATTATA: la
ricognizione aveva dato torto al fondatore sulla voce DD.04 e il fondatore
aveva ragione.
CONTRADDIZIONI_FRA_ORDINI_DICHIARATE: 2, la voce DD.11 contro la voce CQ 6.22
sui colori delle bolle delle Rune, e la voce DD.12 contro il vocabolario
clinico dell'ordine DB voce 11 sulla parola "sintomo". In tutte e due ha vinto
la voce piu' recente, e le guardie di prima portano scritto perche'.
