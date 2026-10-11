# MANIFESTO DELL'ORDINE FK, IL DART NON RIGENERATO, LA FONTE DI WAITE, LA FONTE DEI SIGNIFICATI

Testo dell'ordine: `docs/ordini/ORDINE_FK_TESTO.md`. Rapporto: `docs/ordini/RAPPORTO_ORDINE_FK.md`.

Una voce per ciascuna delle 36 voci dell'ordine. Una voce CHIUSA porta sotto di se' DOMANDA, PROVA e MISURA. Le decisioni della Parte 2 sono di Code, per la frase del fondatore "In ordine di importanza: 1 Code, 2 agenti e subagenti, 3 tu", con la ragione nel rapporto.

VOCI_TOTALI: 36
VOCI_CHIUSE: 33
VOCI_APERTE: 3
VOCI_DA_FARE: 0

## VOCE FK.01

**CHIUSA.** La cartella portata a 24cf424, pulita.

DOMANDA: "Porta la tua cartella a 24cf424 prima di toccare qualsiasi file."
PROVA: docs/collaudo/FK/il_punto_di_partenza.txt
MISURA: modifiche non salvate prima del pull 0; commit mancanti da 6 a 0 (l'ordine diceva due, erano sei)

## VOCE FK.02

**CHIUSA.** Il Dart rigenerato dalla fonte.

DOMANDA: "Lancia python tool/genera_carte_nella_posizione.py. Se si ferma, il difetto è nella fonte e lo dichiari con la riga esatta."
PROVA: docs/collaudo/FK/il_dart_e_la_fonte.txt
MISURA: testi nel Dart da 936 a 2.340; il tool si e' fermato su 2 righe (carta_sola.md riga 361, esito.md riga 623), dichiarate e corrette con una parola ciascuna (docs/collaudo/FK/le_quattro_frasi_della_fonte.txt); uscita poi 0

## VOCE FK.03

**CHIUSA.** La dichiarazione della guardia del corpus e' di nuovo quella vera.

DOMANDA: "Quel file dichiara ancora cartaSola: 0, consultante: 0, esito: 0 e registriConsegnati = false, mentre le prime tre fonti sono piene a 468."
PROVA: test/il_corpus_delle_posizioni_test.dart
MISURA: cartaSola, consultante ed esito da 0 a 3 varianti; posizioni dichiarate da 14 a 15 (`dietro`, FK.08); `registriConsegnati` resta falso, ed e' giusto: i registri sono 0 su 468

## VOCE FK.04

**CHIUSA.** I ventidue gruppi del lato rinfrescati, verificati testo per testo.

DOMANDA: "Verifica che dopo il giro non resti nessuna divergenza fra lato.md e il Dart, e dichiara come l'hai verificato."
PROVA: docs/collaudo/FK/il_dart_e_la_fonte.txt
MISURA: gruppi del lato diversi dalla fonte da 22 a 0; testi uguali fra fonte e Dart 2.340 su 2.340, letti con un'espressione regolare indipendente dal tool

## VOCE FK.05

**CHIUSA.** Il colore delle guardie del corpus, prima e dopo.

DOMANDA: "fai girare le guardie del corpus delle posizioni e dichiara il loro esito."
PROVA: docs/collaudo/FK/fk_regola_b.txt
MISURA: il_corpus_delle_posizioni rossa prima del tool (490 scostamenti fra fonte e Dart), verde dopo (8 prove su 8)

## VOCE FK.06

**CHIUSA.** Decisione di Code: prima i registri.

DOMANDA: "I registri prima oppure dopo le sette posizioni che mancano"
PROVA: docs/ordini/RAPPORTO_ORDINE_FK.md
MISURA: letture del modello che il registro raggiunge appena arriva: tutte quelle della stesa aperta; letture che le sette posizioni raggiungono appena arrivano: 0, finche' la Croce Celtica non ha la sua schermata

## VOCE FK.07

**CHIUSA.** Decisione di Code: la variante 1 non si riscrive.

DOMANDA: "Lo stampo della variante 1 di passato, presente e futuro"
PROVA: docs/ordini/RAPPORTO_ORDINE_FK.md
MISURA: guadagno misurato togliendo lo stampo 2 giudizi su 381; testi da riscrivere 0 su 468; le varianti 2 e 3 si scrivono col repertorio

## VOCE FK.08

**CHIUSA.** Decisione di Code: `dietro` ha un file proprio, `davanti` no; fatto.

DOMANDA: "Se dietro e davanti prendono un file proprio"
PROVA: lib/core/tarot/tarot_spread.dart
MISURA: posizioni da 14 a 15; file della fonte vuoti pronti per l'Architetto da 0 a 1 (`dietro.md`, 468 posti con la glossa vera di Waite in testa); testi in piu' da scrivere 468, non 936; la Croce Celtica al quinto posto legge `dietro`

## VOCE FK.09

**CHIUSA.** Decisione di Code: la trascrizione basta, il facsimile non si compra.

DOMANDA: "Se la trascrizione di grado basso basta, oppure se il facsimile si compra"
PROVA: docs/ordini/RAPPORTO_ORDINE_FK.md
MISURA: righe del ramo che citano le glosse estese da correggere 0 (FK.14); spese chieste al fondatore 0

## VOCE FK.10

**CHIUSA.** Decisione di Code: la guardia sulla fonte tiene le tre regole e le coppie trovate leggendo.

DOMANDA: "Il fondatore ha stabilito che l'Architetto non decide, quindi la scelta torna a te coi numeri misurati."
PROVA: test/la_fonte_dei_significati_non_si_confonde_test.dart
MISURA: coppie note da 28 a 37; coppie note sopra 5,0: 0; frasi di sei parole in comune fra carte diverse 0; massimo delle altre coppie da 23,60 a 23,42

## VOCE FK.11

**CHIUSA.** La glossa vera della quinta carta sta dove si scrive `dietro`.

DOMANDA: "La glossa della quinta carta nomina due stati, non uno"
PROVA: docs/corpus/tarocchi_posizione/dietro.md
MISURA: punti del ramo che portano la glossa intera con la virgola e "is now" da 0 a 4 (dietro.md, il tool, tarot_spread.dart, tarot_spread_type.dart); forma mozza nel ramo 0

## VOCE FK.12

**CHIUSA.** Il confine fra sotto e dietro si ritraccia nel file proprio di `dietro`.

DOMANDA: "La domanda che la decisione deve risolvere è se un testo solo possa reggere entrambi gli stati che Waite distingue."
PROVA: docs/corpus/tarocchi_posizione/dietro.md
MISURA: posizioni che leggono il passato della stesa a tre carte per la quinta carta della Croce Celtica da 1 a 0; testata di dietro.md che nomina il confine col fondamento 1

## VOCE FK.13

**CHIUSA.** Le due regole di citazione di Waite tenute nelle citazioni nuove.

DOMANDA: "il volume usa le grafie arcaiche shews e connexion; ogni glossa comincia con la formula parlata"
PROVA: docs/corpus/tarocchi_posizione/verifica_waite_1911.md
MISURA: citazioni nuove di questo ordine che cominciano con la formula parlata "This is behind him." 4 su 4

## VOCE FK.14

**CHIUSA.** La forma mozza non era nel ramo: verificato col grep.

DOMANDA: "Il metodo del grep sta accanto al risultato perché un grep che non trova niente si confonde facilmente con un grep fatto male."
PROVA: docs/collaudo/FK/i_grep_di_waite.txt
MISURA: file con una delle sette forme al commit 019612d 0 per tutte e sette

## VOCE FK.15

**CHIUSA.** "this crowns him" dichiarata da vedere, ne' corretta ne' confermata.

DOMANDA: "Non la correggere e non la confermare: dichiara nel rapporto che resta da vedere."
PROVA: lib/core/tarot/tarot_spread.dart
MISURA: formule corrette 0; formule dichiarate da vedere nel commento e nel rapporto 1

## VOCE FK.16

**CHIUSA.** Il luogo esatto nella stringa della fonte, toccata per FK.08.

DOMANDA: "Correggila quando toccherai quelle stringhe, non prima"
PROVA: lib/core/tarot/tarot_spread_type.dart
MISURA: stringhe che dicono "capitolo" per Waite nel codice da 1 a 0; "Parte III, sezione 7" da 0 a 1 (l'ordine FI e' un testo consegnato e non si tocca)

## VOCE FK.17

**APERTA IN ATTESA DI VERIFICA.** L'Imperatrice e la Regina di Denari corrette nella fonte (docs/collaudo/FK/correzioni_della_fonte.md): la dritta della Regina perde "fioriscono nelle tue mani" e l'abbondanza, la capovolta dell'Imperatrice passa dalla cura di se' alla fertilita' ferma. Radici rare in comune sulla dritta da 21,13 a 3,66 (docs/collaudo/FK/la_fonte_prima_e_dopo.txt). Sulla capovolta erano gia' a zero: e' una collisione di senso, e la verifica la fa un lettore alla prossima prova appaiata.

## VOCE FK.18

**APERTA IN ATTESA DI VERIFICA.** Il Sole e la Regina di Bastoni corretti nella fonte: il calore e la luce di chi ti sta vicino restano alla Regina, il Sole tiene la riuscita del tempo; la capovolta della Regina diventa la gelosia e la gara, non la luce coperta. Radici rare in comune sulla dritta da 12,38 a 4,36; sulla capovolta gia' zero, quindi anche qui decide il lettore.

## VOCE FK.19

**CHIUSA.** Le tre voci senza cardine hanno il loro cardine scritto.

DOMANDA: "Quattro di Denari: la voce DRITTA porta dentro il monito della propria capovolta [...] Nove di Bastoni capovolta: il tratto distintivo la fonte lo dà in forma NEGATIVA [...] Asso di Coppe capovolta: il tratto va DEDOTTO dalla voce dritta"
PROVA: docs/collaudo/FK/correzioni_della_fonte.md
MISURA: voci senza cardine da 3 a 0 (la dritta del Quattro senza il monito, col conservare come mestiere; il Nove di Bastoni capovolta detto in positivo; la sorgente sola nominata nell'Asso di Coppe capovolta); il Quattro capovolto e il Re di Denari capovolto da 7,33 a 0 di radici rare in comune

## VOCE FK.20

**CHIUSA.** Decisione di Code: per il Tre di Coppe cede il metro, per la Temperanza cede la fonte.

DOMANDA: "Decidi quale delle due cede e scrivilo."
PROVA: docs/collaudo/FK/correzioni_della_fonte.md
MISURA: parole vietate dal metro nella fonte della Temperanza ("guarisce") da 2 a 0; voce del Tre di Coppe toccata 0 (l'amicizia e' il cardine contro il Quattro di Bastoni)

## VOCE FK.21

**CHIUSA.** I due reperti ritirati non sono eseguiti.

DOMANDA: "Non eseguirli, e la voce esiste perché resti la traccia."
PROVA: lib/core/tarot/tarot_spread.dart
MISURA: reperti eseguiti 0 su 2; marca del genere su "Te stesso" presente 1 (`seStesso('[Te stesso|Te stessa|Tu]')`)

## VOCE FK.22

**CHIUSA.** lato.md non rimanda piu' a un numero che il reperto non porta.

DOMANDA: "La testata di docs/corpus/tarocchi_posizione/lato.md dice \"le cinque carte che restano irriconoscibili\", mentre docs/corpus/tarocchi_posizione/collisioni_della_fonte.md oggi ne elenca dodici in tabella."
PROVA: docs/corpus/tarocchi_posizione/lato.md
MISURA: numeri senza la loro misura accanto nella testata da 1 a 0 (cinque alla prova del lato, dodici misurate poi su consultante ed esito)

## VOCE FK.23

**CHIUSA.** La mappa delle gemelle conta le posizioni vere.

DOMANDA: "docs/corpus/tarocchi_posizione/mappa_delle_gemelle.md dice \"la stessa per tutte e diciassette\""
PROVA: docs/corpus/tarocchi_posizione/mappa_delle_gemelle.md
MISURA: posizioni dichiarate da 17 a 15, con la storia fra parentesi

## VOCE FK.24

**CHIUSA.** Decisione di Code: i verbali restano verbali, ma un numero non si contraddice.

DOMANDA: "Decidi tu se si correggono oppure se restano come verbale."
PROVA: docs/STATO_VIVO.md
MISURA: righe del bullet FI che si contraddicono da 1 a 0 ("diciassette file di posizione all'ordine FI", con quattordici e quindici datati fra parentesi)

## VOCE FK.25

**CHIUSA.** Ventidue carte-verso, non ventuno.

DOMANDA: "26 voci, VENTIDUE carte-verso distinte, venti carte distinte."
PROVA: docs/ordini/ORDINE_FJ_MANIFESTO.md
MISURA: punti che dicevano 21 da 3 a 1 (STATO_VIVO e manifesto FJ corretti; il corpo del rapporto FJ consegnato non si corregge e riceve una riga in coda)

## VOCE FK.26

**CHIUSA.** Le undici voci aperte dell'ordine FJ, una per una.

DOMANDA: "Per ciascuna: dichiara nel rapporto di FK se quest'ordine la chiude, se la lascia aperta con la stessa ragione di prima, oppure se la ragione è cambiata."
PROVA: docs/ordini/ORDINE_FJ_MANIFESTO.md
MISURA: voci aperte di FJ da 11 a 3 (chiuse FJ.08, FJ.13, FJ.26-FJ.29, FJ.35, FJ.36; aperte FJ.05 con ragione nuova, FJ.12 e FJ.16)

## VOCE FK.27

**CHIUSA.** I controlli di casa sui 1.404 testi nuovi, prima della suite.

DOMANDA: "Fai girare i controlli di casa su quei testi PRIMA della suite intera, e dichiara quanti falsi allarmi sono usciti e su quali frasi."
PROVA: docs/collaudo/FK/le_quattro_frasi_della_fonte.txt
MISURA: falsi allarmi 0; allarmi veri 2 (due participi maschili, nel lato e nell'esito), corretti; controlli di casa da 1 rosso a 0

## VOCE FK.28

**CHIUSA.** Le guardie delle zone viste rosse prima.

DOMANDA: "Nel rapporto scrivi l'elenco delle guardie viste rosse prima, con la data."
PROVA: docs/collaudo/FK/fk_regola_b.txt
MISURA: guardie delle zone toccate viste rosse prima di toccarle 7 su 7 (il corpus delle posizioni, la fonte dei significati, il genere, la virgola e il trattino, il testo ricco, le stese, il manifesto FJ); innesti sbagliati miei rifatti 2

## VOCE FK.29

**CHIUSA.** I dieci rossi del secondo giro di FJ, attribuiti.

DOMANDA: "Non c'è niente da rifare: la voce esiste perché la Regola C del protocollo delle guardie è stata rispettata e va riconosciuto."
PROVA: docs/ordini/RAPPORTO_ORDINE_FJ.md
MISURA: rossi col loro padre 10 su 10

## VOCE FK.30

**CHIUSA.** La matrice dei mazzi resta.

DOMANDA: "1 va bene la matrice attuale con limitazioni."
PROVA: lib/core/tarot/i_mazzi_dei_tarocchi.dart
MISURA: righe della matrice toccate 0; prezzi in Eos inventati 0

## VOCE FK.31

**CHIUSA.** I due mazzi restano fuori dall'APK.

DOMANDA: "Ok, allora lasciali fuori."
PROVA: lib/core/tarot/i_mazzi_scaricati.dart
MISURA: mazzi aggiunti al binario 0; mazzi sul bucket 2 prima e dopo

## VOCE FK.32

**CHIUSA.** Niente Cloud CDN e niente R2.

DOMANDA: "vorrei passare il bucket a cloudflare R2... Ma cmq non adesso. Per ora restiamo così."
PROVA: lib/core/tarot/i_mazzi_scaricati.dart
MISURA: bilanciatori, backend bucket e migrazioni fatti 0

## VOCE FK.33

**CHIUSA.** Nessuna build.

DOMANDA: "la Build quando ci saranno tutti i corpus di ogni posizione."
PROVA: docs/ordini/RAPPORTO_ORDINE_FK.md
MISURA: build ordinate o chieste 0

## VOCE FK.34

**CHIUSA.** Le cinque premesse sbagliate dell'ordine FJ, attribuite all'Architetto.

DOMANDA: "il padre di questi cinque è l'ordine FJ dell'Architetto."
PROVA: docs/ordini/RAPPORTO_ORDINE_FJ.md
MISURA: premesse col loro padre 5 su 5

## VOCE FK.35

**APERTA IN ATTESA DI VERIFICA.** Il ruolo c'e' gia': l'account di Code e' `roles/billing.admin` sul conto di fatturazione (letto con `gcloud billing accounts get-iam-policy`), che comprende il permesso di vedere i costi, quindi il documento dei costi descrive un limite che oggi non c'e'. Da riga di comando pero' i costi non si leggono: l'esportazione in BigQuery non e' attiva (zero dataset nel progetto), e attivarla e' una configurazione che non tocco. Il report in console non l'ho aperto: la misura del credito usato resta quella stimata.

## VOCE FK.36

**CHIUSA.** Il rapporto e il manifesto dell'ordine.

DOMANDA: "Il rapporto va in docs/ordini/RAPPORTO_ORDINE_FK.md, e in cima porta l'elenco delle voci chiuse con accanto la prova di ciascuna"
PROVA: docs/ordini/RAPPORTO_ORDINE_FK.md
MISURA: voci nel manifesto 36 su 36; rapporto registrato con tool/i_rapporti_consegnati.py alla consegna
