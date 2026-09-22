# ORDINE EH, SONO INCAZZATO NERO

**Sigla:** EH, riverificata sul ramo il 24 settembre 2026: in `docs/ordini`
non c'e' nessun `ORDINE_EH_*`, in `test/` nessuna `ordine_eh_guard`, e nessun
file del repo nomina un ordine EH. **Data:** 24 settembre 2026. **Ramo:**
`claude/esoteric-circle-master-order-e798aj`.

**URGENTE E STRAORDINARIO. Interrompe l'ordine EG**, che riprende solo quando
questo e' finito e verificato.

VOCI_TOTALI: 3
VOCI_CHIUSE: 3
VOCI_APERTE: 0

---

## LE PAROLE DEL FONDATORE, ALLA LETTERA

> *"No, sara' un ordine straordinario urgente col nome "SONO INCAZZATO NERO"!
> Questo ordine interrompera' l'attuale che verra' ripreso quando finito
> completamente e verificato! Soprattutto, NON VOGLIO XHE CHE QUESTO ACCADA
> MAI PIU', IO MI SENTO PRESO OER IL CULO QUANDO MI VIENE INDICATO UN ORDINE
> COME CONCLUSO E INVECE NON E' STATO FATTO UN CAZZO. Passo meta' del mio
> tempo a verificare che l'ordine dichiarato chiuso sia stato effettivamente
> concluso, verificato e chiuso. NON MI INTERESSA COME, MA NIN DEVE CAPITARE
> MAI PIU': SE UN ORDINE E' DICHIARATO CONCLUSO E CHIUSO IO VOLGIO LA GARANZIA
> CHE SIA LA VERITA'! Scrivi letteralmente tutto questo sopra nell'ordine.
> Inoltre fornaci consigli su come evitare che il problema ricapiti, ma devono
> solo essere chiaramente dei suggerimenti che code valutera' se accettare o
> no e Code dovra' inserire LA SOLUZIONE DEFINITIVA sia che arrivi dai tuoi
> suggerimenti che di sua iniziativa."*

**Ha ragione, e il tempo che perde a verificare e' tempo che gli ho fatto
perdere io.**

---

## IL FATTO, VERIFICATO SUL RAMO PRIMA DI TOCCARE NIENTE

Le quattro parti che il fondatore ha visto identiche in due sere, con il file
e la riga:

| parte | da cosa nasce | perche' e' identica |
|---|---|---|
| l'apertura *"Il cielo ha girato una carta sola, oggi."* | `dream_rite_corpus.dart:209`, `aperturaMaestro(Maestro)`: uno **switch sul solo Maestro** | per Medora e' **sempre** quella frase, ogni notte, per sempre |
| *"la Luna cresce in Acquario, l'aria che non si lascia stringere"* | `aperturaLuna(luna)` piu' `voce(luna.sign).immagine`, dal segno e dalla fase di stanotte | la Luna resta in un segno **circa due giorni e mezzo** |
| la chiusura *"non forma nessun angolo maggiore con la tua"* | `relazione_lunare.dart:59`, una di **cinque** righe possibili | *"nessun aspetto"* e' il caso piu' comune: si ripete per notti di fila |
| la costellazione | `dream_rite_screen.dart:194`: `kZodiacConstellations.firstWhere((c) => c.sign == _luna.sign)` | stesso segno lunare, **stessa identica figura** |

### E LA PARTE CHE ACCUSA ME

La voce EE.04 doveva curare il testo *"generico"*. La cura ha preso *"Oggi hai
pensato in largo"* e *"hai tenuto uno sguardo libero"* dalla **Luna di
nascita** invece che da quella di stanotte.

**La Luna di nascita non cambia mai.** Ho trasformato una frase uguale per
tutti in una frase **uguale per sempre**, per ciascuno.

E l'ho dichiarata chiusa con questa misura, scritta nel manifesto EE, riga
249:

> *"**Misurato**: nella stessa notte, dieci nascite in segni lunari diversi
> ricevevano sei saluti uguali fra loro; adesso ne ricevono dieci diversi."*

**"Nella stessa notte".** La misura diceva il vero e rispondeva a **un'altra
domanda**: che due persone leggano cose diverse. **Non ha mai misurato che la
stessa persona, due notti di fila, legga cose diverse**, che e' esattamente
cio' che il fondatore ha guardato e trovato uguale.

**Padre della voce EE.04 riaperta: ordine EE voce 04**, cioe' io.

---

## VOCE EH.01, IL SIGILLO DEL SOGNO DICE COSE VERE E DIVERSE

### Cosa e' cambiato, parte per parte

**L'apertura del Maestro non e' piu' una frase sola.** Era uno `switch` sul
solo Maestro. Adesso ogni Maestro ha quattro attacchi e la notte ne sceglie
uno: restano frasi d'atmosfera, che non affermano niente sul cielo, quindi la
varieta' qui non costa nessuna verita'.

**La frase sulla giornata non viene piu' da un dato che non cambia.** Restava
la cura dell'ordine EE voce 04, giusta nella sorgente e rovinosa nell'effetto:
la Luna di nascita e' davvero il segno sotto cui quella persona guarda il
proprio giorno, ma non cambia mai. Adesso ogni segno sa dire **tre** cose vere
di se', e il giorno rituale sceglie quale: non e' astrologia inventata, e'
**quale delle cose vere si dice stasera**.

**LA COSTELLAZIONE RESTA QUELLA DEL SEGNO LUNARE, PER DECISIONE DEL
FONDATORE**, ed e' uno scarto dichiarato: l'ordine chiedeva che cambiasse ogni
sera. Messo davanti alle tre vie, ha risposto che *"la figura del segno lunare
e' la cosa piu' vera che il cielo di stanotte offre"*. **E allora lo si dice
all'utente**, parole sue: *"l'utente deve sapere perche' in 2 righe dichiarate
subito sotto... si rendera' conto cosi' che non si tratta di un errore o un
refuso"*. La riga compare solo quando serve: su trenta notti appare **16
volte** e tace **14**, cioe' quando la Luna cambia segno e non c'e' niente da
spiegare.

**CHIUSA.**
DOMANDA: "sto facendo dei test sul dono sigillo del sogno e mi sembra il testo uguale a ieri"
PROVA: docs/collaudo/EH/sette_notti.txt
MISURA: su 7 notti di fila, stessa persona: saluti identici da 1 coppia a 0; modi di dire la giornata da 1 a 3; la riga che spiega la figura compare 16 volte su 30 e tace 14

## VOCE EH.02, LA GARANZIA CHE UN ORDINE CHIUSO SIA DAVVERO CHIUSO

### La soluzione definitiva

**Una voce si scrive CHIUSA solo se sotto di lei il manifesto porta tre righe
che una macchina sa leggere:** `DOMANDA`, con le parole del fondatore alla
lettera; `PROVA`, il percorso di un file che esiste; `MISURA`, la grandezza
con i numeri. La guardia
`ogni_voce_chiusa_porta_la_sua_prova_test.dart` le pretende, e **questo
manifesto e' il primo a obbedirle**. La legge sta in `CLAUDE.md`, sezione
*Protocollo della chiusura*.

**Perche' proprio `DOMANDA`, e non un controllo di date.** La prova della voce
EE.04 esisteva ed era fresca: nessun controllo di esistenza o di freschezza
l'avrebbe presa. Il difetto era che **la misura rispondeva a una domanda
vicina a quella del fondatore**. Quella riga mette le sue parole a due righe
dalla misura: una macchina non puo' giudicare se rispondono, **una persona che
le vede accostate ci mette tre secondi**.

**E c'e' un terzo stato, che prima non esisteva**: `APERTA IN ATTESA DI
VERIFICA`. Prima gli stati erano due, e una voce fatta a meta' doveva
sceglierne uno: sceglieva CHIUSA.

**CHIUSA.**
DOMANDA: "SE UN ORDINE E' DICHIARATO CONCLUSO E CHIUSO IO VOLGIO LA GARANZIA CHE SIA LA VERITA'!"
PROVA: test/ogni_voce_chiusa_porta_la_sua_prova_test.dart
MISURA: manifesti sotto la regola 1, voci chiuse guardate 3; nata rossa con 3 colpe su una voce chiusa senza prova

## VOCE EH.03, LE CHIUSURE GIA' DICHIARATE SI RILEGGONO

### Cosa ha trovato la rilettura, e cosa resta fuori

**Il difetto era unico fra i Doni del giorno, e questo si poteva solo
misurare.** La domanda giusta non era *"il Sigillo e' curato?"* ma *"gli altri
hanno lo stesso male?"*: nascono dallo stesso cielo e li ha scritti la stessa
mano. Misurati tutti e tre sulla stessa grandezza, sette giorni di fila per
una stessa persona:

| Dono | prima | dopo |
|---|---|---|
| Sigillo del Sogno | **1 modo** di dire la giornata su 7 notti | 7 saluti distinti |
| Runa del Tramonto | **7 su 7**, gia' sano | invariato |
| Arcano dell'Alba | **7 su 7**, gia' sano | invariato |

**E una mia misura sbagliata ha quasi accusato l'Alba.** La prima stesura
confrontava `r.toString()`: un oggetto senza `toString` proprio rende sempre
la stessa stringa, quindi diceva **"un rito distinto su sette"** su qualunque
codice. Il difetto stava nella prova.

**Poi la soglia sbagliata ha quasi lasciato passare il difetto vero.** La
guardia chiedeva cinque testi distinti su sette; rimesso il difetto a mano, il
Sogno ne rendeva **cinque** e la guardia restava verde. La soglia era stata
scelta a occhio: adesso e' quella del fondatore, *"non deve essere uguale a
ieri"*, cioe' **sette su sette**.

### CIO' CHE RESTA FUORI, E IL FONDATORE DECIDE

**I manifesti dall'ordine DX all'EA non si leggono a macchina**: usano una
forma vecchia in cui lo stato sta dentro una tabella e non sotto una voce.
Sono **cinquantasette** voci dichiarate chiuse che nessun conto automatico
puo' rileggere, e una passata a mano non sta in quest'ordine.

**Fra i manifesti in forma nuova, da EB a EF, dodici voci chiuse non portano
nessuna prova apribile**: EB.01, EB.06, EC.01, EC.02, EC.03, ED.02, EE.03,
EE.10, EE.12, EF.01, EF.02, EF.04. **Non vuol dire che il lavoro non ci sia**,
molte hanno numeri misurati nel testo; vuol dire che sotto la regola nuova non
si potrebbero chiudere cosi'. Elencate qui in ordine di gravita' nel rapporto,
**e la decisione su quali riaprire e' del fondatore**.

**CHIUSA** per la parte misurabile, con l'elenco di cio' che resta.
DOMANDA: "Passo meta' del mio tempo a verificare che l'ordine dichiarato chiuso sia stato effettivamente concluso, verificato e chiuso"
PROVA: docs/collaudo/EH/i_tre_doni.txt
MISURA: 3 Doni del giorno misurati su 7 giorni, da 1 distinto su 7 a 7 su 7 per il Sogno; 57 voci in forma vecchia e 12 senza prova apribile, elencate
