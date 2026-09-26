# ORDINE ACCELERA, LO SBARRAMENTO DIVISO SU PIU' MACCHINE E LA CONSEGNA COL VERDETTO DI GITHUB

**Sigla:** ACCELERA, 26 settembre 2026, dopo la consegna della build 2284
dell'ordine EP.
**Ramo:** `claude/esoteric-circle-master-order-e798aj`.

**Le parole del fondatore**, durante lo sbarramento della 2284: *"Ma non c'è
modo di accelerare Suite, sbarramenti, ecc? Ho il piano Max e ho risorse da
sfruttare"*, *"Ma se l'accelerazione è sempre disponibile, usala sempre"*,
*"Ma ancora sbarramentii da 40 Min?"*; e sulla domanda di come procedere,
*"Subito dopo questa build"*.

**I fatti misurati prima di cominciare.** Il PC e' un Intel Core i5-3450 del
2012, 4 processori logici, 16 GB. `flutter test` fa girare in parallelo meta'
dei processori, cioe' due file alla volta. La suite intera (1.071 file, 5.921
prove) durava circa 38 minuti in locale, lo sbarramento locale circa 45, lo
sbarramento su GitHub circa 33 minuti per commit su una macchina sola.

VOCI_TOTALI: 4
VOCI_CHIUSE: 3
VOCI_APERTE: 1

Le prove stanno in `docs/collaudo/ACCELERA/`.

---

## VOCE ACCELERA.01, LA SUITE DIVISA PER FILE

`tool/i_pezzi_della_suite.py` divide i file di prova in pezzi di peso
simile: ogni file intero in un pezzo solo, cosi' ogni macchina compila solo
i suoi e le prove di uno stesso file restano insieme. I pesi sono i secondi
misurati sul PC (`tool/pesi_delle_prove.json`, rifatti con
`--pesi-da <registro>`); un file nuovo pesa la mediana. **Non la divisione di
Flutter** (`--total-shards`), che spezza le prove dentro ogni file e fa
ricompilare tutti i file a ogni macchina: l'ha trovato l'agente che ha
mappato le modifiche, leggendo `test_core`.

**CHIUSA.**
DOMANDA: "Ma non c'è modo di accelerare Suite, sbarramenti, ecc? Ho il piano Max e ho risorse da sfruttare"
PROVA: docs/collaudo/ACCELERA/la_divisione_dei_file.txt
MISURA: file di prova in un pezzo, 1.072 su 1.072, doppi 0; sei pezzi da 658 secondi ciascuno dei tempi del PC, contro 3.948 su una macchina sola

## VOCE ACCELERA.02, LO SBARRAMENTO DI GITHUB SU PIU' MACCHINE

`.github/workflows/verde.yml` lancia sei macchine per i pezzi della suite,
una per il corredo a scala 1,3, una per il server e le chiusure, una per
l'analisi; l'ultima, "analyze e sbarramento", riunisce i registri e decide
con lo sbarramento di sempre. Lo sbarramento ha due modalita' nuove, accese
solo da variabili d'ambiente: `SBARRAMENTO_SOLO` (una fase, registro ed esito
conservati, nessuna decisione) e `SBARRAMENTO_DA_REGISTRI` (decide sui
registri, e un pezzo che manca ferma il cancello). Senza variabili fa cio'
che faceva prima: il PC e la Ronda non cambiano.

**Il primo giro vero, sul commit `91c21317`, e' durato 7,5 minuti** contro
i 33 di una macchina sola, ed e' stato **rosso**
(`docs/collaudo/ACCELERA/primo_giro_su_github.txt`). Difetto di questa voce:
le variabili della modalita' pezzo arrivavano anche alle prove che il pezzo
faceva girare, e le prove che lanciano una copia dello sbarramento la
trovavano in modalita' pezzo; 21 prove cadute su tutte le macchine, verdi sul
PC dove quelle variabili non ci sono. Curato: lo sbarramento, lette le
variabili, le toglie dall'ambiente; la prova nuova e' nata rossa sul difetto
vero.

**Il secondo giro, dopo la cura, e' verde in 9,6 minuti**, sul commit
`62824ada`: il pezzo piu' lento 8,7 minuti, gli altri fra 4,7 e 6,6, la
decisione finale 0,8. I pesi vengono dai tempi del PC: il pezzo 0 porta il
corredo, e si potra' bilanciare meglio coi tempi di GitHub.

**CHIUSA.**
DOMANDA: "Ma ancora sbarramentii da 40 Min?"
PROVA: docs/collaudo/ACCELERA/secondo_giro_su_github.txt
MISURA: sbarramento su GitHub dalla spinta al verdetto da 33,4 minuti su una macchina sola a 9,6 minuti su dieci macchine, verde; il primo giro diviso, rosso per un difetto curato, 7,5 minuti

## VOCE ACCELERA.03, LA CONSEGNA COL VERDETTO DI GITHUB

`tool/consegna.py` chiede prima a GitHub se il cancello e' verde **sul
commit da cui si e' costruito**, con la stessa porta di Codemagic
(`tool/il_cancello_ha_detto_verde.sh`), e lo accetta solo se l'albero non ha
modifiche fuori dai commit, il commit e' sul ramo canonico, il numero di
build del commit e' quello dell'archivio e l'archivio e' piu' recente del
commit. Se GitHub non e' verde vale il gettone del PC, come prima. Il
registro della consegna scrive quale cancello l'ha fatta passare.

Provato sul PC: lo script del cancello, chiamato da `consegna.py` col bash
di Git, dice verde sul commit `cfefb7c1`; con l'albero sporco la consegna
rifiuta.

**APERTA IN ATTESA DI VERIFICA**: la prima consegna vera senza lo
sbarramento del PC, cioe' la risposta alla domanda del fondatore *"Ma ancora
sbarramentii da 40 Min?"*.

## VOCE ACCELERA.04, DUE DIFETTI CHE LO SBARRAMENTO AVEVA GIA'

Trovati leggendo lo sbarramento per dividerlo:
- **il gettone non si cancellava su tutte le uscite rosse**, solo in fondo:
  dopo un corredo che non aveva guardato abbastanza, dopo le chiusure senza
  prova o dopo righe di troppo fra i rossi accettati, un gettone verde di
  prima con lo stesso numero di build restava valido. Padri: ordine CM voce
  10, ordine EH voce 03 e ordine CH voce 04, che hanno aggiunto quelle uscite
  dopo il gettone dell'ordine CZ voce 14;
- **l'elenco dei rossi nuovi si stampava vuoto** quando la suite cadeva
  senza nominare nessuna prova: l'azzeramento stava dopo il nome.
  PROVENIENZA IGNOTA.

**CHIUSA.**
DOMANDA: "Ma ancora sbarramentii da 40 Min?"
PROVA: docs/collaudo/ACCELERA/regola_a_innesti.txt
MISURA: uscite rosse che lasciano il gettone da 5 a 0; elenco dei rossi nuovi vuoto su una suite caduta senza nomi da 1 a 0; le due prove nate rosse rimettendo i difetti
