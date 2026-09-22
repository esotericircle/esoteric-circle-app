# RAPPORTO DELL'ORDINE EH, SONO INCAZZATO NERO

**Ramo:** `claude/esoteric-circle-master-order-e798aj`. **Date:** 24 settembre
2026. **Voci:** 3, tutte chiuse.

---

## LA RISPOSTA ALLA DOMANDA, IN CIMA E IN QUATTRO RIGHE

Il fondatore ha chiesto una cosa sola: *"SE UN ORDINE E' DICHIARATO CONCLUSO E
CHIUSO IO VOLGIO LA GARANZIA CHE SIA LA VERITA'"*.

**Da oggi una voce puo' essere scritta CHIUSA solo se il manifesto porta sotto
di lei tre righe che una macchina legge: `DOMANDA`, con le sue parole alla
lettera; `PROVA`, il percorso di un file che esiste sul disco; `MISURA`, la
grandezza con i numeri.** Una guardia lo pretende su ogni manifesto del
progetto, e **un cancello dello sbarramento senza deroghe impedisce a
qualunque build di uscire** se anche una sola voce chiusa non le porta.

**Non e' una promessa, e' una prova che cade.** Ed e' gia' caduta: rimesso a
mano il difetto, la build si ferma e stampa la ragione.

---

## LE TRE VOCI, CON LA LORO PROVA

| voce | cosa e' stato fatto | prova sul disco | misura |
|---|---|---|---|
| **EH.01** | il Sigillo del Sogno non ripete la notte prima | `docs/collaudo/EH/sette_notti.txt` | 7 notti di fila, stessa persona: saluti identici **da 1 coppia a 0**; modi di dire la giornata **da 1 a 3**; la riga che spiega la figura compare **16 volte su 30** e tace 14 |
| **EH.02** | la garanzia che un ordine chiuso sia chiuso | `test/ogni_voce_chiusa_porta_la_sua_prova_test.dart` | **105 manifesti** letti, **99** con chiusure, **404 guardie nominate** controllate una per una |
| **EH.03** | le chiusure gia' dichiarate si rileggono | `docs/collaudo/EH/i_tre_doni.txt` | 3 Doni del giorno su 7 giorni: il Sogno **da 1 distinto su 7 a 7 su 7**, Tramonto e Alba gia' sani; **17 guardie fantasma** riparate |

---

## VOCE EH.01, IL DIFETTO CHE HA VISTO LUI, E CHI L'AVEVA MESSO

> *"sto facendo dei test sul dono sigillo del sogno e mi sembra il testo uguale
> a ieri"*

Aveva ragione, **e il padre del difetto sono io**: ordine EE voce 04. Quella
cura ha portato le due frasi *"Oggi hai..."* e *"Se guardi indietro, hai..."*
dal segno della Luna di stanotte a quello della **Luna di nascita**. La
sorgente e' giusta, ed e' il segno sotto cui quella persona guarda il proprio
giorno; ma **la Luna di nascita non cambia mai**. Ho trasformato una frase
uguale per tutti in una frase uguale **per sempre**, per ciascuno.

**E la misura che chiudeva quella voce diceva il vero.** Diceva: *"nella stessa
notte, dieci nascite in segni lunari diversi ricevono dieci saluti diversi"*.
Misurava che **due persone** leggessero cose diverse. Il fondatore guardava
**una persona in due notti**. Questo e' il difetto che ha generato tutto
l'ordine: **una misura vera che risponde alla domanda accanto**.

**Cosa e' cambiato.** Ogni segno sa dire adesso **tre** cose vere di se', e il
giorno rituale sceglie quale: non e' astrologia inventata, e' quale delle cose
vere si dice stasera. L'apertura del Maestro non e' piu' una frase sola: ogni
Maestro ha quattro attacchi d'atmosfera, che non affermano niente sul cielo.

**La costellazione resta quella del segno lunare, per decisione sua**, ed e'
uno scarto dichiarato rispetto all'ordine, che ne chiedeva una diversa ogni
sera. Alla sua richiesta, *"l'utente deve sapere perche' in 2 righe dichiarate
subito sotto"*, risponde una riga che compare **solo quando serve**: *"La Luna
resta in Pesci ancora 2 notti: per tutte queste sere la figura del cielo e'
questa."* Su trenta notti appare 16 volte e tace 14, cioe' tace esattamente
quando la Luna cambia segno e non c'e' niente da spiegare.

---

## VOCE EH.02, LA SOLUZIONE DEFINITIVA

### Perche' proprio la DOMANDA, e non un controllo di date

**La prova della voce EE.04 esisteva ed era fresca.** Nessun controllo di
esistenza, nessun controllo di freschezza, nessun conteggio di prove l'avrebbe
presa. Il difetto era che la misura rispondeva a una domanda **vicina** a
quella del fondatore.

Nessuna macchina puo' giudicare se una misura risponde a una domanda. **Ma una
persona che le vede scritte a due righe di distanza ci mette tre secondi.** La
riga `DOMANDA` esiste per quello: mette le sue parole accanto al numero, e
rende visibile a occhio nudo lo scarto che nessun controllo automatico vede.

### Il terzo stato

Prima gli stati erano due, CHIUSA e APERTA, e una voce fatta a meta' doveva
sceglierne uno: **sceglieva CHIUSA**. Adesso c'e' `APERTA IN ATTESA DI
VERIFICA`, e dichiararlo non costa niente a chi lavora.

### Dove vive la regola

- la legge: `CLAUDE.md`, sezione *Protocollo della chiusura*;
- la guardia: `test/ogni_voce_chiusa_porta_la_sua_prova_test.dart`;
- **il cancello**: `tool/sbarramento.sh`, *IL QUARTO CANCELLO*, che gira
  **sempre**, anche quando si passa un corredo ristretto, e **non passa dai
  rossi accettati**. Una riga fra gli accettati vorrebbe dire *"si puo'
  dichiarare chiusa una voce senza prova"*, che e' la cosa vietata.

### E LA PROVA DEL ROSSO HA COLTO IL CANCELLO CIECO

Vale la pena raccontarlo per esteso, perche' e' il caso che giustifica una
regola intera. Il cancello nuovo, scritto la prima volta come
`if ! flutter test ... | tee "$REGISTRO"`, **leggeva l'uscita di `tee`, che e'
sempre zero**. Con il difetto innestato a mano lo sbarramento si e' fermato lo
stesso, ma **per un altro motivo**, e il cancello nuovo non ha stampato una
riga.

Un cancello cosi' e' peggio di nessun cancello: **sembra esserci**, e chi legge
il file lo conta fra le difese. Nessuna lettura attenta del codice lo avrebbe
preso; l'ha preso il fatto di aver **guardato l'esito con il difetto dentro**,
che e' l'unica cosa che la Regola A chiede. Riparato con `PIPESTATUS`, come gli
altri tre cancelli del file, e riprovato sul blocco vero: **col difetto uscita
1 e il suo messaggio stampato, senza difetto uscita 0**.

**E POI HA COLTO UN SECONDO DIFETTO, NELLA GRANDEZZA MISURATA.** Riparato il
primo, il cancello fermava la build ogni volta che non trovava la guardia, e
cosi' ha fatto cadere **dodici prove** di `lo_sbarramento_distingue_i_rossi`,
che monta lo sbarramento in cartelle finte. Le due assenze non si somigliano:
**la guardia sparita mentre il progetto c'e'** e' qualcuno che ha tolto la
rete, e la build si ferma; **nessun albero del progetto affatto** e' una
cartella di prova, e si dichiara non eseguito a voce alta.

La prima distinzione, *"esiste la cartella `test/`?"*, ha lasciato rossa una
prova su dodici: la tana del corredo a scala massima una `test/` ce l'ha, col
solo corredo finto dentro. **Si e' cambiata la grandezza, non la soglia**,
come pretende la Regola A: un albero di questo progetto si riconosce dal
`pubspec.yaml`, che c'e' sempre in un albero vero e mai in una cartella
temporanea.

**I quattro casi, misurati sulla versione finale**: albero a posto **0**;
albero vero con la guardia cancellata **1**, col suo messaggio; tana senza
pubspec **0**, dichiarato non eseguito; manifesto con una chiusura senza prova
**1**, col suo messaggio.

---

## VOCE EH.03, COSA HA TROVATO LA RILETTURA

### I tre Doni del giorno, misurati sulla stessa grandezza

La domanda giusta non era *"il Sigillo e' curato?"* ma *"gli altri hanno lo
stesso male?"*: nascono dallo stesso cielo e li ha scritti la stessa mano.

| Dono | prima | dopo |
|---|---|---|
| Sigillo del Sogno | **1 modo** di dire la giornata su 7 notti | **7 su 7** |
| Runa del Tramonto | 7 su 7, gia' sano | invariato |
| Arcano dell'Alba | 7 su 7, gia' sano | invariato |

### LE DICIASSETTE GUARDIE CHE NON ESISTEVANO PIU'

La guardia nuova, girata su tutti i manifesti, ha trovato **17 guardie
nominate come vive in sei manifesti, e cancellate nel frattempo**. Chi apriva
quei documenti per controllare una chiusura leggeva di una rete che non c'era.

**Toglierle era lecito: un ordine dopo puo' demolire cio' che un ordine prima
sorvegliava. Il reato era lasciarle scritte come vive.** Ognuna ha adesso il
suo padre, con l'ordine e il commit, scritto nel manifesto che la nominava:

| manifesto | quante | chi le ha cancellate |
|---|---|---|
| AO | 2 | ordine AR.10 `3ba909f9`, ordine AT.03/04 `f268cd69` |
| AS | 3 | ordine AT.03/04 `f268cd69`, ordine DT `47b3c2be` |
| AT | 2 | ordine AV.01 `994311be` |
| AU | 1 | ordine DT `47b3c2be` |
| DT | 8 | ordine DT `47b3c2be`, ordine DU `72723db7` |
| S | 1 | ordine BF.05.g `b0bccfaf` |

La forma e' una riga sola che la guardia sa leggere:
`GUARDIA RIMOSSA: <nome> - <ordine e commit>: <ragione>`.

### I DUE ERRORI MIEI, DENTRO QUESTO STESSO LAVORO

**La mia misura ha quasi accusato l'Arcano dell'Alba.** La prima stesura
confrontava `r.toString()`: un oggetto senza `toString` proprio rende sempre
la stessa stringa, quindi diceva *"un rito distinto su sette"* su **qualunque**
codice. Il difetto stava nella prova, non nell'Alba.

**E la mia soglia ha quasi lasciato passare il difetto vero.** La guardia
chiedeva cinque testi distinti su sette; rimesso il difetto a mano, il Sogno ne
rendeva **esattamente cinque** e la guardia restava verde. La soglia era stata
scelta a occhio. Adesso e' quella del fondatore, *"non deve essere uguale a
ieri"*, cioe' **sette su sette**.

Sono i due casi che l'ordine serviva a impedire, colti dentro l'ordine stesso.

---

## CIO' CHE RESTA FUORI, E IL FONDATORE DECIDE

**Cinquantasette voci in forma vecchia.** I manifesti dall'ordine DX all'EA
tengono lo stato dentro una tabella e non sotto la voce: nessun conto
automatico puo' rileggerle. Non vuol dire che il lavoro non ci sia, vuol dire
che una macchina non lo sa dire. Una passata a mano non stava in quest'ordine.

**Dodici voci chiuse senza prova apribile**, fra i manifesti gia' in forma
nuova: EB.01, EB.06, EC.01, EC.02, EC.03, ED.02, EE.03, EE.10, EE.12, EF.01,
EF.02, EF.04. Molte hanno numeri misurati nel testo; sotto la regola nuova non
si potrebbero chiudere cosi'.

**La regola nuova vale dall'ordine EH in avanti**, apposta: farla valere
all'indietro avrebbe reso rossa la suite per un lavoro che in gran parte
esiste, e una guardia rossa che nessuno puo' riparare subito e' una guardia che
si impara a ignorare. **La decisione su quali di quelle dodici riaprire e'
sua.**

---

## I SUGGERIMENTI DELL'ARCHITETTO

Il fondatore ha chiesto che i suggerimenti dell'Architetto fossero valutati uno
per uno, accettati o respinti con la ragione. **Non li ho piu' alla lettera**:
il testo dell'ordine e' uscito dalla mia memoria di lavoro durante una
compattazione, e ho cercato di ripescarlo dai registri della sessione senza
trovarlo. **Lo scrivo invece di ricostruirli a memoria**, che in un ordine
nato proprio contro le affermazioni a memoria sarebbe la cosa peggiore da
fare. Se li rimanda, li valuto uno per uno in coda a quest'ordine.

---

## I DIFETTI DI LINGUA TROVATI SUL CODICE NUOVO

La suite intera ha trovato **tre guardie di casa rosse** sul testo scritto per
la EH.01, tutte con lo stesso padre, **ordine EH voce 01**, cioe' io:

- `language_rule_test` e `dream_rite_test`: **sei stringhe** con la virgola
  prima della *"e"*, che in questa casa non si usa;
- `il_genere_non_si_indovina_test`: **due stringhe** che davano del maschile a
  chi legge, *"sei stato il punto fermo"* e *"non ti sei accontentato"*.

Riscritte tutte e dieci senza genere e senza quella virgola.

**Due rosse restano, e sono rosse per suo ordine**, non difetti nuovi:
`le_soglie_della_scansione_sono_provvisorie` (CR.13, le soglie aspettano una
misura su un telefono vero) e `i_doni_e_la_chat_davanti_all_anatomia`
(l'attribuzione cieca sotto la soglia di 85).

---

## COSA CHIEDO

**Nessuna build**, perche' nessun ordine l'ha chiesta. Quando la vorra', il
quarto cancello e' gia' in mezzo alla strada: la build non esce se un manifesto
vanta una chiusura che non puo' provare.
