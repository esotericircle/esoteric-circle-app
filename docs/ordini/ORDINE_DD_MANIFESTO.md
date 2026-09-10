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

---

VOCI_TOTALI: 15
VOCI_CHIUSE: 0
VOCI_APERTE: 15
RICOGNIZIONE_FATTA: 6 voci su 15
DIFFORMITA_DALL_ORDINE_GIA_DICHIARATE: 3
