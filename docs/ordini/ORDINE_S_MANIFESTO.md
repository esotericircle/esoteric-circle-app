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

- **S.01** Il disegno del sentiero e' il protagonista — APERTA
- **S.02** I tre disegni sono fatti bene — APERTA
- **S.03** La schermata dice dove sei, cosa vedi e cosa guadagni — APERTA
- **S.04** Perche' il borsellino e' a zero — APERTA
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
VOCI_CHIUSE: 0
VOCI_FERMATE_SU_PREMESSA_FALSA: 0
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0
