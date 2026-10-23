# ORDINE CODEMAGIC2, LA BUILD IOS VA IN TIMEOUT

**Sigla:** CODEMAGIC2. **Data:** 17 settembre 2026. **Ramo:**
`claude/esoteric-circle-master-order-e798aj`. Parte dal commit `65bd5811`.

**Urgente, e sospende l'ordine DT**, che resta sul ramo locale e non e' stato
spinto. **Nessuna build**: la ordina Mauro.

VOCI_TOTALI: 8
VOCI_CHIUSE: 8
VOCI_APERTE: 0
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0

Il rapporto sta in `docs/ordini/RAPPORTO_ORDINE_CODEMAGIC2.md`.

---

## I FATTI, RISCONTRATI

| cosa dice l'ordine | il riscontro | esito |
|---|---|---|
| i tempi dei passi della build fallita | **non verificabili da qui**: il registro sta su Codemagic. Sono **coerenti col file**: i nomi dei passi coincidono con quelli di `codemagic.yaml`, lo sbarramento era il passo prima dell'archivio (righe 308-326 a `65bd5811`) e il tetto e' `max_build_duration: 60` (riga 26). La somma dei passi leggibili fa **57 minuti e 53 secondi**; con il recupero del codice, non leggibile, arriva ai sessanta | **CREDUTA, E COERENTE** |
| CODEMAGIC1 doveva far girare lo sbarramento su GitHub *in modo che Codemagic non lo ripetesse* | **falsa**. CODEMAGIC1 ha reso uguali le due domande e **le ha tenute tutte e due**: la voce CODEMAGIC1.02 dice *"il cancello gratis diventa lo stesso del cancello a pagamento"*, e la sua guardia pretendeva `bash tool/sbarramento.sh` in `codemagic.yaml` (`test/ordine_codemagic1_guard_test.dart`, righe 96-100 a `65bd5811`). Ha toccato il workflow iOS, aggiungendo `npm ci` (righe 289-306), e non ha tolto lo sbarramento: non era nel suo scopo | **SMENTITA** |
| il ramo `main` e' fermo al 9 luglio | non rilevante per la correzione: il controllo della build rifiuta qualunque ramo diverso da quello canonico | **NON MISURATA** |
| aumentare `max_build_duration` e' il rimedio suggerito | il massimo documentato e' **120 minuti su tutti i piani** | **VERA** |

---

## LE VOCI

- **CODEMAGIC2.01**, la causa del timeout: 46 minuti e 23 secondi di
  sbarramento sul Mac, prima dell'archivio, dentro un tetto di 60. **CHIUSA**
- **CODEMAGIC2.02**, cosa e' successo a CODEMAGIC1: ha toccato il workflow
  iOS, ha tenuto lo sbarramento di proposito e l'ha blindato con la sua
  guardia; i due workflow non divergono, sono uguali e ripetuti. **CHIUSA**
- **CODEMAGIC2.03**, il cancello GitHub: `verde.yml` gira a ogni spinta sul
  ramo canonico; **verde su `65bd5811`** in 24 minuti e 47 secondi, di cui
  22 minuti e 24 secondi di sbarramento, e verde su `3cf58e32`; rosso su
  `eac1e559` e `ea3f11cb`, commit che nessuna build ha costruito. **CHIUSA**
- **CODEMAGIC2.04**, la scelta: **lo sbarramento esce da Codemagic** e al suo
  posto il primo passo chiede a GitHub il verdetto del cancello su quel commit
  (`tool/il_cancello_ha_detto_verde.sh`), e si ferma su tutto cio' che non e'
  verde. `max_build_duration` resta **60**. Tolte anche le dipendenze del
  server dal Mac, che servivano solo allo sbarramento. Il workflow Android non
  esiste su Codemagic e `android-build.yml` non esegue prove: **lo sbarramento
  non girava due volte per Android**. **CHIUSA**
- **CODEMAGIC2.05**, il tetto reale: **120 minuti su tutti i piani**, dalla
  pagina dei prezzi di Codemagic e dalla documentazione del file
  (*"min 1, max 120"*); 60 e' dentro. **CHIUSA**
- **CODEMAGIC2.06**, il ramo: il workflow non ha `triggering` e parte solo a
  mano; la documentazione non offre un campo che vincoli il ramo di una build
  manuale, quindi **il vincolo e' nel primo passo**: se `CM_BRANCH` non e'
  `claude/esoteric-circle-master-order-e798aj` la build si ferma. **CHIUSA**
- **CODEMAGIC2.07**, nessuna build lanciata. **CHIUSA**
- **CODEMAGIC2.08**, il manifesto, la guardia
  `test/ordine_codemagic2_guard_test.dart`, le due guardie di CODEMAGIC1 e
  dello sbarramento riscritte perche' leggevano i commenti, e il rapporto.
  **CHIUSA**

---

## I TEST

- `test/ordine_codemagic2_guard_test.dart`, **nuova**, vista rossa su due
  innesti: lo sbarramento rimesso in `codemagic.yaml` (una rossa) e un
  controllo che scambia *finito* per *verde* (rossi e annullati passavano, due
  rosse). Fa girare lo script vero su **nove risposte finte**: verde passa;
  rosso, annullato, in corso, mai partito, verde su un altro commit, GitHub che
  rifiuta, risposta illeggibile e ramo `main` fermano la build. Pretende che
  la build non rifaccia lo sbarramento, che il controllo sia il primo passo e
  stia prima dell'archivio, il tetto fra 1 e 120, e che il cancello gratuito
  giri a ogni spinta sul ramo con lo sbarramento, `npm ci` e lo stesso
  Flutter del Mac.
- `test/ordine_codemagic1_guard_test.dart` e
  `test/lo_sbarramento_distingue_i_rossi_test.dart`, **riscritte**: dopo la
  modifica restavano verdi **perche' trovavano il comando nel commento** che
  racconta perche' e' uscito. Adesso leggono le righe di codice, e sono state
  viste rosse togliendo il controllo da `codemagic.yaml`.
- Lo script, provato anche **contro GitHub vero**: verde su `65bd5811`, rosso
  su `eac1e559`, mai partito su un commit inesistente, fermo sul ramo `main`,
  lasciato passare con `SPEDISCO_SU_ROSSO`.
