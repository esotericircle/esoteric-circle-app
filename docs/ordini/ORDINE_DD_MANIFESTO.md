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

### DD.04, la Parola dell'Alba nel Sigillo: LA VOCE DICE IL FALSO SUL CODICE

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

---

VOCI_TOTALI: 15
VOCI_CHIUSE: 0
VOCI_APERTE: 15
RICOGNIZIONE_FATTA: 6 voci su 15
DIFFORMITA_DALL_ORDINE_GIA_DICHIARATE: 3
