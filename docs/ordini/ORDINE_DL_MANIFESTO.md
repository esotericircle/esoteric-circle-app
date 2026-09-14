# ORDINE DL, IL GENERE SCELTO VALE OVUNQUE, E IL RESPONSO RISPONDE

**Sigla:** DL. **Data:** 14 settembre 2026. **Ramo:**
`claude/esoteric-circle-master-order-e798aj`. Segue l'ordine DK, commit
`57c56e1b`, build 2250 consegnata. Con l'aggiunta del fondatore, voci DL.13 e
DL.14.

**Vincolo permanente:** tutta l'intelligenza a runtime gira su Gemini e
Vertex AI, mai su API Anthropic. **La build di quest'ordine l'ha ordinata il
fondatore**, dopo il rapporto sulle premesse: *"ok, prosegui senza fermarti.
se hai domande, trova la risposta ideale. alla fine crea build, testa sul
cell e consegna"*.

VOCI_TOTALI: 15
VOCI_CHIUSE: 15
VOCI_SBLOCCATE_E_APERTE: 0

Il rapporto, con le misure, sta in `docs/ordini/RAPPORTO_ORDINE_DL.md`; il
censimento del genere prima e dopo, stringa per stringa, in
`docs/ordini/DL_CENSIMENTO_DEL_GENERE.md`.

---

## LE PREMESSE

Verificate tutte prima di toccare una riga, e riferite al fondatore prima di
eseguire.

| premessa | esito |
|---|---|
| P1, `CourtesyForm` con quattro valori | **vera** |
| P2, `agree` chiamata da due soli file | **vera** |
| P3, `AddressForm` con `pick` e `welcome`, mai salvato | **vera** |
| P4, due switch scritti a mano nell'onboarding | **vera** |
| P5, la guardia sorveglia due coppie | **vera** |
| P6, la lettura del mese impone il femminile | **vera** |
| P7, *"lei ha gia' letto"* dentro la chat | **vera** |
| P8, nel Viaggio una sola stringa col genere | **vera** |
| P9, titolo e risposta da elenchi costanti | **vera** |
| P10, il nutrimento vibra e non suona; nessun audio nella cartella | **falsa a meta'**: la cartella non ha audio, vero; ma il nutrimento **faceva partire il battito continuo della discesa**, ordine DI voce 13, e al tocco vibrava soltanto |
| P11, il tetto conta le chiamate, due per discesa | **falsa a meta'**: conta le chiamate, vero; ma una discesa ne fa **da una a tre** (il classificatore solo per la domanda scritta a mano, la scena, la scena richiesta se la prima si scarta), e **in Demo il tetto non contava affatto** |

E una frase della voce DL.09, *"il codice traccia la fonte del tema, quindi la
risposta esiste gia'"*, **era falsa**: `FonteDelTema` si calcolava e la
schermata la buttava, e il registro dei guasti vive in memoria e muore col
processo. Riferito; il fondatore ha detto di proseguire e di scegliere le
risposte migliori. Le scelte stanno alle voci DL.09, DL.11 e DL.14.

---

## DL.00, IL FATTO SUL GENERE, MISURATO. CHIUSA

Il censimento rifatto col criterio della guardia della voce DL.06: **110
stringhe** rivolte alla persona portano il genere, **10 concordate, il 9,1
per cento**, e **37** contengono *te stesso* o *te stessa*. L'ordine ne
misurava ottantatre' col criterio piu' stretto; e' un censimento invecchiato
e non una premessa falsa, come l'ordine stesso dice. Dopo: **123 stringhe,
123 concordate, zero *te stesso***. L'elenco intero, prima e dopo, nella
appendice.

---

## DL.01, UNA PORTA SOLA. CHIUSA

- **`AddressForm` rimosso**, con `setForm`, `pick` e `welcome`:
  `identity_controller.dart` tiene solo il nome. Il campo mai salvato non
  esiste piu'.
- **La porta**: `lib/core/chat/la_marca_del_genere.dart`. `CourtesyForm.agree`
  e `vocativeLabel` le delegano; `ProfileController` le annuncia la forma
  scelta a ogni cambio.
- **I due switch dell'onboarding passano dalla porta**: `anteprima_tono` con
  la sua frase marcata, `scena_del_ritrovamento` col saluto marcato.
- **`Gender` di `birth_details.dart` resta al calcolo**: la prova verifica
  che nessuno lo usi per la lingua.

Prova: `il_genere_si_decide_in_un_posto_solo`, **una decisione sola**. Rossa
con una seconda decisione innestata; **e rossa senza innesto** su un difetto
vero della voce DL.07: `formeContrarieAllaForma` sceglieva la desinenza con un
suo `masculine ? 'a' : 'o'`. Riparata facendola passare dalla porta.

---

## DL.02, LA MARCA DENTRO IL TESTO. CHIUSA

`[maschile|femminile|neutro]`, con la forma sconosciuta che vale il neutro e
`[[` e `]]` per le quadre letterali. Un passaggio solo sul testo.
**La regola della lingua sta in una classe sola**, `LinguaItaliana`, dietro
un'interfaccia: `LinguaSenzaGenere` risolve sempre il terzo campo, cioe' in
inglese la marca sparisce. Una marca malformata, nell'app, lascia il testo
com'e' invece di fermare lo schermo; nella prova del risolutore solleva, e
`il_genere_non_si_indovina` pretende che ogni marca di `lib` abbia i suoi tre
campi. Prova: `la_marca_del_genere_test`.

---

## DL.03, LA CONVERSIONE, AREA PER AREA. CHIUSA

Tutte le aree dell'ordine, nell'ordine dato, piu' quelle trovate strada
facendo: la tavola per area nell'appendice. **I corpora generati si sono
cambiati alla fonte**: `docs/corpus/angeli.md` con `tool/genera_angeli.py`,
`docs/corpus/oroscopo.md` con `tool/_gen_oroscopo.py`, i traguardi con
`tool/corpus_traguardi.py`. Nelle classi costanti il testo marcato sta in un
campo grezzo e si legge da un getter che risolve; le schermate risolvono prima
di sostituire i segnaposti (la domanda, il nome delle carte).

- **Il Viaggio**: *"Chiediti quale racconterai meglio fra dieci anni."*
- **"Sei nato"**, una riformulazione sola dappertutto:
  `[quando sei nato|quando sei nata|alla tua nascita]`, o *"della tua
  nascita"* dove la frase lo regge senza marca.

---

## DL.04, I PROMPT DICHIARANO LA FORMA. CHIUSA

**Il blocco di cortesia sta in un file solo**, `il_blocco_di_cortesia.dart`,
e entra in tutti gli otto prompt che scrivono prosa per la persona: la chat,
il consulto, il presagio delle rune, la sintesi comparativa, il distillato di
memoria, la lettura del mese, il segno dell'animale, e la scena col titolo, la
risposta e il gesto del Viaggio. **La lettura del mese non impone piu' il
femminile.** Il distillato non deduce piu' la forma: la riceve.

**Fuori, e dichiarato**: il classificatore della domanda libera, che
restituisce un identificatore di tema e l'oggetto della domanda, non una
frase.

Prova: `ogni_prompt_di_prosa_dichiara_la_forma`. Per ogni prompt e ogni forma
il blocco c'e' e dice quella forma e nessun'altra; **del genere si parla solo
nel blocco**; ogni file di `lib` che manda un'istruzione al modello e'
dichiarato. Tre rossi: il blocco tolto, il femminile imposto dentro una frase,
un mandante nuovo.

---

## DL.05, LA CONTRADDIZIONE DENTRO IL PROMPT DELLA CHAT. CHIUSA

*"Questo è ciò che hai già scritto e che la persona ha già letto"*. **La
rassegna dei frammenti concatenati** nei prompt ne ha trovati altri due col
genere: il blocco di cortesia diceva *"riferiti a lei"*, ora *"alla
persona"*; e le aperture vietate della voce del Maestro elencavano *"Non sei
solo"* e *"Non sei sola"*, ora il prefisso *"Non sei sol"*, che le prende
tutte e due.

---

## DL.06, LA GUARDIA CHE IMPEDISCE IL RITORNO. CHIUSA

`il_genere_non_si_indovina`, riscritta. Il dizionario dell'ordine intero, i
vocativi, *te stesso* e *te stessa*, in `lib/core/chat/le_forme_del_genere.dart`,
dove lo usano anche le guardie dei testi del modello. **Nata rossa** sul
codice di prima; **il dizionario non si e' mai allargato, il criterio si e'
stretto**: il verbo alla seconda persona accanto alla parola, l'infinito solo
in apertura di frase o dopo *di*, i vocativi. Porte dichiarate: la marca e il
profilo. Cardinale sulle stringhe guardate.

---

## DL.07, IL TITOLO E LA RISPOSTA LI SCRIVE IL MODELLO. CHIUSA

**La stessa chiamata della scena** restituisce anche `titolo`, `risposta` e,
con l'aggiunta DL.13, `azione`. Nessuna chiamata in piu'; tetto di uscita da
256 a 640 token.

**Le guardie**, in `le_guardie_del_responso.dart`, una riga alla volta:
vuota, troppo lunga, domanda, due punti, trattino lungo, virgola seguita da
*e*, prima persona, **previsione certa** (anche quella senza futuro, *"la casa
e' gia' venduta"*, *"non e' ancora il momento"*, trovate dalla sonda col
modello vero), **promessa** su salute, denaro, morte, gravidanza, legge,
**diagnosi**, **nome proprio** che la domanda non ha, **genere contrario**
alla forma scelta, **risposta che non nomina la domanda**, **risposta che
anticipa la scena**.

**Il determinismo**: il Diario conserva il titolo, la risposta e il gesto
letti, e la fonte di ogni pezzo. **La riserva** resta intera, e il prompt
riceve sei titoli e cinque gesti di casa come esempi di voce. Le misure da A a
F col testo generato, gli scarti per guardia e il costo nel rapporto.

Prove: `il_responso_risponde`, una riga per ogni motivo dello scarto;
`la_prova_a_cento_discese`, con lo schema e i campi obbligatori della chiamata
dell'app.

---

## DL.08, LA RISPOSTA NOMINA LA COSA. CHIUSA

Il classificatore restituisce `{tema, oggetto}`. **L'oggetto si mette in
forma prima di entrare nella ripresa**: parole prese dalla domanda per
radice, mai la prima persona, mai solo parole vuote, le maiuscole dei nomi
propri riprese dalla domanda, **l'articolo davanti al possessivo** tranne che
coi nomi di parentela, e **il possessivo solo se la domanda diceva *mio***:
*"Mio figlio trovera' lavoro?"* da' *"il lavoro"*, non *"il tuo lavoro"*. La
ripresa usa la preposizione articolata, *"sul trasloco"*, *"su tua
sorella"*. Senza oggetto valido vale la categoria.

---

## DL.09, LA TABELLA, IL TETTO CHE CONTA LE DISCESE, IL BANCO. CHIUSA

- **La lettura della fonte del tema nella build 2250 non si puo' fare**: la
  fonte non si registrava, il registro dei guasti muore col processo, e il
  registro del telefono comincia dopo la prova. **Da quest'ordine la fonte si
  scrive nel Diario, per ogni discesa.** Cio' che si puo' dire, nel rapporto.
- **La tabella**: le parole del rapporto con un altro (*non mi parla*,
  *cercarla*, *sentirlo*, *riavvicinarsi*) e dei futuri di un altro
  (*trovera'*, *tornera'*).
- **Il prompt**: due esempi di attesa per un terzo, uno di persona col *non so
  se*, uno di persona col conflitto che si ripete, uno di direzione senza
  alternative.
- **Il tetto**: dieci discese e dieci segni al giorno, contati per conto loro;
  una discesa prende il tetto una volta al tocco di Scendi, con tutte le sue
  chiamate. **E conta anche in Demo**, voce DL.14.
- **Il banco**: trentasei domande scritte a mano, `il_banco_delle_domande_libere`.

---

## DL.10, I TRE GESTI CHE PORTANO GIA' UN TEMPO. CHIUSA

I tre gesti non ricevono il quando, e non ricevono l'apertura *"Il passo di
oggi"*. **La prova a cento discese e' diventata rossa da sola**: senza il
quando il loro paragrafo tornava identico tre volte su cento, misura D.
Riparata facendo girare le sette aperture senza tempo sulla storia del gesto.

Prova: nessun paragrafo del gesto ha due pezzi che dicono un tempo, su
duemilacento discese. **La grandezza e' il pezzo, non la parola**: *"nei
prossimi tre giorni"* e' un tempo solo.

---

## DL.11, IL TAMBURO SI SENTE QUANDO L'APP CHIEDE IL GESTO. CHIUSA

`IlColpoDelTamburo`, `assets/audio/mondo_di_sotto/tamburo_colpo.mp3`, a ogni
tocco del nutrimento insieme alla vibrazione, al volume degli effetti e sotto
il loro interruttore; il lettore degli effetti ferma il colpo di prima prima di
far partire il nuovo. **Il battito continuo non parte piu' nel nutrimento.**
Senza il file: vibra soltanto, nessun errore, la musica non si abbassa, una
riga nel diario di sviluppo una volta sola. Cartella, chiave, LEGGIMI e stato
degli asset pronti. Prova: `il_tamburo_che_nutre_si_sente`.

---

## DL.12, IL RAPPORTO. CHIUSA

`docs/ordini/RAPPORTO_ORDINE_DL.md` e l'appendice del censimento.

---

## DL.13, IL GESTO LO SCRIVE IL MODELLO. CHIUSA

Nella stessa chiamata. Le guardie del gesto: una cosa sola, al massimo due
frasi e trenta parole, non un consiglio di vita ne' un invito a riflettere,
**col suo tempo dentro**, niente che tocchi un terzo in modo che possa
ferirlo, niente salute, farmaci, soldi, atti legali. Il paragrafo del gesto
del modello prende un'apertura di casa senza tempo e nessun quando. Riserva
dei venti gesti intera. Misure nel rapporto.

---

## DL.14, IL COMANDO DI COLLAUDO CHE ALZA IL TETTO. CHIUSA

Nella soglia del Viaggio, accanto a *Ricomincia il Viaggio (Demo)*: *"Tetto
del modello alzato (Demo)"*. **Esiste solo in Demo**, parte spento, vive in
memoria e non si accende da solo; spento, il tetto torna subito. Acceso,
sotto la scena si legge la fonte di ogni pezzo; **il Diario la scrive
sempre**. Prova: `il_comando_di_collaudo_del_tetto`, fuori dalla Demo il
comando non si raggiunge.
