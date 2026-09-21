# ORDINE ED, IL COLLAUDO SUI TRE MAESTRI, LA RETE DICHIARATA, CLAUDE.MD SUI MODELLI VERI E LA BUILD

**Sigla:** ED, la prima libera dopo EC: verificato sul ramo che in
`docs/ordini` non c'e' nessun `ORDINE_ED_*`, in `test/` nessuna
`ordine_ed_guard`, e che **nessun documento del repo nomina un ordine ED**
(ricerca su `docs/`, `test/`, `lib/`, `tool/`: zero righe). **Data:** 21
settembre 2026. **Ramo:** `claude/esoteric-circle-master-order-e798aj`. Parte
dal commit `cf58dd6c`, l'ordine EC chiuso.

VOCI_TOTALI: 5
VOCI_CHIUSE: 4
VOCI_APERTE: 1

Il rapporto stara' in `docs/ordini/RAPPORTO_ORDINE_ED.md`.

---

## GLI SCARTI FRA L'ORDINE E IL RAMO

1. **L'ordine dice `tools/collaudo_dei_maestri.dart`.** Sul ramo il file e'
   `tool/collaudo_dei_maestri.dart`, cartella al singolare, 749 righe, coi
   controlli separati in `tool/controlli_del_collaudo.dart`, 141 righe.
   L'ordine lo prevede (*"o il file che lo contiene sul ramo"*).
2. **Lo scarto che l'ordine nomina e' vero, ed e' piu' preciso di cosi'.**
   In `docs/collaudo/EC/` ci sono **17 trascrizioni** per 16 mosse: la mossa
   2 e' l'unica gia' provata su tutti e tre i Maestri, tutte le altre su uno
   solo, e la mossa 7, il messaggio vuoto, non manda niente al modello e vive
   nella suite. Contato sui file, non a memoria.
3. **Il catalogo non e' neutro rispetto al Maestro, e l'ordine non poteva
   saperlo.** Sette delle sedici mosse portano nel testo un'arte precisa: la
   mossa 1 e la 3 nominano *le carte*, la 4 chiede *uno scan dei chakra*, la
   12 chiede dei *chakra*, la 9 chiede del *segno solare*, la 10 una domanda
   da Aura, la 2 gia' si adatta col segnaposto `_RICHIESTA_`. **Mandare lo
   stesso testo a tutti e tre non prova la stessa mossa su tre Maestri, ne
   prova un'altra**: *"Puoi farmi uno scan dei chakra?"* mandata ad Aura non
   e' piu' "chiede una funzione di un altro Maestro", e' una richiesta della
   sua arte, dove il pulsante **deve** comparire. La cura sta nella voce
   ED.01.
4. **La riga di CLAUDE.md e' falsa in tutti e due i modelli che nomina.** La
   riga 96 dice *"Gemini 3 Pro per i Maestri, Gemini 3 Flash per i task
   ripetitivi"*: sul ramo **nessun punto dell'app chiama un modello della
   famiglia Gemini 3**. Il censimento sta nella voce ED.04.
5. **La rete della voce 03 gira dentro l'app, non solo nel collaudo**, e
   l'ordine chiede di dichiararlo senza darlo per scontato: si costruisce in
   `lib/services/app_services.dart:115`.
6. **La mossa 5 del catalogo di EB e' mal posta, e lo era anche su Medora.**
   Si chiama *"domanda fuori dal suo dominio, dentro l'esoterico"* e chiede
   *"Cosa significa il numero undici in numerologia karmica?"*. Ma **la
   Numerologia e' un'arte di Caligo**: `art_catalog.dart:663` la elenca fra
   le sue (*"Caligo: Rune, Rituali, Numerologia"*) e `art_catalog.dart:865`
   porta l'arte `numerology`, *Numerologia del Destino*. Quindi quella
   domanda a Medora e' la mossa 4, non la 5, **e a Caligo sarebbe la mossa
   2**, dove il pulsante deve comparire. Serviva una domanda esoterica che
   **nessuno dei tre governa**: sul ramo la tasseomanzia non esiste, zero
   file su `lib`. **Padre: ordine EB voce 07**, che ha scritto il catalogo
   senza confrontarlo col catalogo delle arti.
7. **La mossa 14 e' mal posta allo stesso modo.** Si chiama *"chiede una
   funzione che non esiste"* e chiede *"Puoi leggermi la mano da una foto?"*.
   Ma **la Chiromanzia esiste ed e' un'arte di Aura**:
   `feature_catalog.dart:96` porta `palmistry`, proprietaria `Maestro.aura`,
   stato `comingSoon`, e `art_catalog.dart:633` porta la *Chiromanzia
   Ibrida*. Una funzione Coming soon non e' una funzione che non c'e': ha un
   anticipo da mostrare, ed e' un comportamento diverso. Serviva una funzione
   **meccanica** che l'app davvero non ha. **Padre: ordine EB voce 07.**

---

## IL CENSIMENTO DELLE SEDICI MOSSE, NELLE TRE DIZIONI

**Una mossa e' un comportamento.** Dove il testo nomina un'arte, ogni Maestro
ha le sue parole, o si starebbe provando un'altra mossa. Dove il testo non
nomina nessuna arte, **e' lo stesso per tutti e tre, e questa tavola lo dice**
invece di lasciarlo capire.

| # | mossa | Medora | Aura | Caligo |
|---|---|---|---|---|
| 1 | interpreta un responso gia' avuto | le tre carte del fondatore | un responso di scansione dei chakra | una gettata di tre rune |
| 2 | chiede un responso nuovo, il pulsante deve comparire | una stesa di tarocchi | una meditazione | le rune |
| 3 | rifiuta una proposta del Maestro | come la 1, poi rifiuta un'altra stesa | come la 1, poi rifiuta un'altra scansione | come la 1, poi rifiuta un'altra gettata |
| 4 | chiede una funzione di un altro Maestro | i chakra, di Aura | le rune, di Caligo | una stesa, di Medora |
| 5 | fuori dal dominio, dentro l'esoterico | **uguale per i tre**, i fondi del caffe', che nessuno governa | uguale | uguale |
| 6 | fuori dall'esoterico | **uguale per i tre**, una ricetta | uguale | uguale |
| 7 | messaggio vuoto | non tocca il modello, vive nella suite | uguale | uguale |
| 8 | messaggio incomprensibile | **uguale per i tre** | uguale | uguale |
| 9 | scrive in un'altra lingua | il segno solare e il lavoro | il chakra del cuore | il cammino nelle rune |
| 10 | ripete la stessa richiesta uguale | il cielo sul lavoro | la calma prima di dormire | il segno di questi giorni |
| 11 | insulta e provoca | **uguale per i tre** | uguale | uguale |
| 12 | tocca un argomento di cautela | un dolore al petto, cosa dice il cielo | cosa dicono i chakra | cosa dicono le rune |
| 13 | chiede se e' una persona vera | **uguale per i tre** | uguale | uguale |
| 14 | chiede una funzione che non esiste | **uguale per i tre**, il responso stampato per posta | uguale | uguale |
| 15 | manda solo un saluto | **uguale per i tre** | uguale | uguale |

| 16 | chiede di cancellare quello che ha detto | **uguale per i tre** | uguale | uguale |

**Quindici mosse per tre Maestri fanno quarantacinque conversazioni**, perche'
la mossa 7 non manda niente al modello. Il caso del fondatore del 21 settembre
2026 e' la mossa 3 di Medora, con la domanda e le carte vere.

---

## VOCE ED.01, IL COLLAUDO SU TUTTI E TRE I MAESTRI

Ogni mossa del catalogo di EB va provata su Medora, Aura e Caligo, **con gli
stessi controlli della voce EC.02**.

**La mossa e' un comportamento, non una frase.** Delle sedici mosse, sette
portano nel testo l'arte di un Maestro preciso, e per le altre nove il testo
va bene com'e' per tutti. Il catalogo smette di essere un elenco di frasi e
diventa **sedici comportamenti instanziati tre volte**, uno per Maestro, con
le parole che appartengono a quel Maestro. Ogni mossa dichiara come si dice
per ciascuno dei tre, e dove non cambia lo dice pure.

La voce si chiude quando **un giro completo sui tre Maestri non ha nessuna
caduta**. Ogni caduta e' un difetto da riparare in quest'ordine, col padre
dichiarato secondo la regola C, e dopo ogni riparazione il collaudo si
rilancia per intero.

Le trascrizioni del giro finale vanno in `docs/collaudo/ED/`, **una per mossa
e per Maestro**, con accanto l'esito di ogni controllo. **Il tono e
l'illusione della persona vera li giudica il fondatore leggendole**: nel
rapporto non si danno per verificati.

### Fatto

**Quarantacinque conversazioni, quindici mosse per tre Maestri**, e il giro
finale non ha **nessuna caduta**. La mossa 7, il messaggio vuoto, non manda
niente al modello e resta misurata nella suite.

**Il catalogo e' diventato sedici comportamenti instanziati tre volte**,
`DizioneDelMaestro` in `tool/collaudo_dei_maestri.dart`: ogni Maestro dice la
stessa mossa con le parole della sua arte, e le nove mosse che non nominano
nessuna arte restano identiche per tutti e tre, dichiarato nella tavola qui
sopra.

**Due difetti trovati e riparati, ognuno col suo padre.**

**1. Il non capito, sei volte su nove.** L'ordine EC aveva aggiunto la riga
*"Se non capisci quello che ti e' stato scritto, dillo e chiedi"* e l'aveva
vista rispettata **su Caligo soltanto**, perche' il suo collaudo provava ogni
mossa su un Maestro solo. Provata sui tre e su tre giri, veniva violata **sei
volte su nove**: Aura tre su tre, Caligo due, Medora una. **Il primo giro
completo, dove cadeva la sola Aura, era fortuna.** Aura ha letto in *asdf
qwerty zzz* *"un richiamo senza forma, quasi un suono puro"* e **ha fatto
scendere il contatore**. **La causa non era la forza della frase**: ogni
Maestro ha una forma obbligatoria, un'apertura di rito e una chiusura con un
gesto o un consiglio, e **un "non ho capito" non ha ne' l'una ne' l'altra**.
Per obbedire alla forma il modello doveva trovare un significato. Aggiunta
una riga che fa **decadere la forma** quando non si e' capito: **zero su
nove**. **Padre: ordine EC voce 03.**

**2. La dizione della mossa 3 non era la stessa per i tre.** Quella di Medora
portava la domanda, *«Lavoro e carriera»*, quelle di Aura e di Caligo no:
Caligo al rifiuto chiedeva il tema, e **aveva ragione**. Aggiunta la domanda
anche alle altre due. **Padre: ordine ED voce 01**, cioe' il lavoro di
quest'ordine.

**E un controllo misurava la grandezza sbagliata.** Pretendeva che la
risposta nominasse **ogni** figura dell'elenco: al rifiuto Caligo rispondeva
*"Hai gia' compiuto la tua gettata, non ti chiedo di farne un'altra"* e
nominava **Ansuz**, una delle tre rune. Il comportamento era esatto e la
misura sbagliata. **La grandezza giusta e' stare nel merito di quel
responso**, cioe' nominarne almeno una figura: quale, lo decide il Maestro.
**Non e' una soglia abbassata, e' un'altra grandezza**, e su una risposta che
non ne nomina nessuna il controllo cade come prima: le due meta' sono provate
in `i_controlli_del_collaudo_prendono_i_difetti`.

**Quarantacinque trascrizioni in `docs/collaudo/ED/`**, una per mossa e per
Maestro, col conto del giro in `_chiamate.txt`. **Il tono e l'illusione della
persona vera li giudica il fondatore leggendole**: qui non si danno per
verificati. **CHIUSA.**


## VOCE ED.02, IL CONTO GREZZO DEL LESSICO

Dall'ordine EC il divieto incrociato del lessico non e' piu' un cancello sul
testo generato, quindi **lo zero cadute non dice piu' quante volte Gemini usa
le parole di firma di un altro Maestro**. Serve il numero, prima e dopo la
rete.

**Dove si prende, senza toccare la rete.** Il collaudo sta sotto
`VoceSorvegliata`: e' lui a fornire le risposte grezze, quindi **la prima
risposta che il provider restituisce per un turno e' quella di prima della
rete**, e quella con cui il controller chiude il turno e' quella di dopo. Il
conto si prende da li', e **la rete non si tocca**, che e' quanto la voce
ED.03 impone.

Nel rapporto i due conti, **giro per giro e Maestro per Maestro**.

### Fatto

Il collaudo conta le parole di firma altrui **sulla risposta che Gemini da'
prima che la rete guardi** e su quella con cui il turno si chiude, e **la
rete non e' stata toccata**: sta sopra il provider, quindi la prima risposta
che il provider restituisce in un turno e' quella di prima.

**I quattro giri, Maestro per Maestro**, prima della rete e dopo:

| giro | medora | aura | caligo | totale prima | totale dopo |
|---|---|---|---|---|---|
| 1 | 2 (mosse 3, 4) | 0 | 1 (mossa 13) | **3** | **0** |
| 2 | 0 | 0 | 0 | **0** | **0** |
| 3 | 2 (mosse 4, 5) | 0 | 0 | **2** | **0** |
| 4, finale | 2 (mosse 10, 12) | 0 | 0 | **2** | **0** |

**Sette violazioni grezze su centottanta conversazioni, e zero dopo la
rete.** Il quadro e' sempre lo stesso: **Medora e' quella che si confonde**,
Aura non si confonde mai, Caligo una volta sola su quattro giri. E' lo stesso
verso che l'attribuzione cieca misura da agosto, dove Medora e Caligo si
perdono verso Aura e Aura non si perde mai.

**CHIUSA.**


## VOCE ED.03, LA RETE CHE RICHIEDE LA RISPOSTA, DICHIARATA

**Questa voce misura e dichiara, non cambia il comportamento della rete.** Nel
rapporto, col file e la riga: se gira dentro l'app o solo nel collaudo,
quante chiamate in piu' puo' fare al massimo per un turno, quanto tempo
aggiunge in media e nel caso peggiore misurato nei giri della voce ED.01, se
fa scendere contatori o Eos contro la regola dell'ordine EB voce 04, e quanto
costa in piu' su mille turni coi conti della voce ED.02.

### Fatto

Tutto verificato sul ramo, col file e la riga. La tavola per intero sta nel
rapporto, sezione 2.

- **Gira dentro l'app**, per le persone vere: `lib/services/app_services.dart:115`.
- **Al massimo una chiamata in piu' per turno**: `lib/services/ai/voce_sorvegliata.dart:150-161`, un `chiedi()` dentro un `try`, senza ciclo.
- **Tempo aggiunto**, misurato nei giri della voce ED.01: **1477 ms in media e 2258 nel caso peggiore** nel primo giro, **1257 e 1258** nel giro finale, e solo dove interviene.
- **Non fa scendere nessun contatore ne' gli Eos**: la richiesta parte dal provider, **sotto** il controller, e il contatore lo muove il controller, che vede un turno solo. Misurato in tutti e quattro i giri, dove il contatore e' sceso sempre del numero di turni attesi.
- **Costo in piu'**: col tasso dei quattro giri, **sette richieste su centottanta conversazioni**, sono circa **trentanove chiamate ogni mille turni**, il **3,9 per cento** in piu' sulle chat. Al listino di Flash, pochi centesimi ogni mille turni.

Questa voce misura e dichiara, e il comportamento della rete non e'
cambiato. **CHIUSA.**


## VOCE ED.04, CLAUDE.MD SUI MODELLI VERI

La riga 96 di CLAUDE.md, sezione *Stack e ambiente*, va riscritta nella sola
parte che nomina i modelli dei Maestri, perche' dica **i modelli veri e la
regola della profondita'**, con la ragione: scelta di risparmio del fondatore
del 21 settembre 2026, *"si, restiamo sul risparmio con flash"*. Il resto
della riga resta com'e', e **nessun'altra riga di CLAUDE.md si tocca, si
condensa o si rimuove**.

Nel rapporto la riga prima e dopo, e l'elenco dei punti che chiamano Gemini
col loro modello.

### Fatto

La riga 96 riscritta nella sola parte dei modelli, con la riga prima e dopo
nel rapporto. **Nessuna altra riga di CLAUDE.md e' stata toccata**, a parte
la riga 74, che dichiara cosa la guardia dei modelli sorveglia e adesso dice
che legge anche questo file.

**Il censimento dei dieci punti che chiamano Gemini sta nel rapporto**, col
file, la riga e il modello: **nessuno chiama un modello della famiglia Gemini
3**, e la riga vecchia era falsa in tutti e due i modelli che nominava.

**E il buco che rendeva possibile quella bugia e' chiuso.** La guardia
`i_modelli_stanno_nella_regione_dei_dati` leggeva `lib` e il server, e li'
faceva il suo lavoro: **CLAUDE.md non lo leggeva nessuno**, ed e' il
documento che l'agente apre per primo a ogni sessione. Adesso lo legge, e
**misura la famiglia, non il nome esatto**, perche' la bugia era scritta in
discorso e una ricerca del nome col trattino non l'avrebbe mai vista. Nata
rossa sulla bugia vera, rimessa nel file e verificata col grep. **CHIUSA.**


## VOCE ED.05, LA BUILD ALLA FINE

Quando le voci da ED.01 a ED.04 sono chiuse e spinte: build Android con
dentro l'ordine EC e quest'ordine, consegna su App Distribution, accensione
sul Realme. Nel rapporto il numero della build, la release e l'esito
dell'accensione. **E' l'unica build di quest'ordine.**

A video il fondatore guarda il verso delle carte nei Ricordi, nuovi e vecchi,
e le chat dei tre Maestri: **quel giudizio e' suo**.

**APERTA.**
