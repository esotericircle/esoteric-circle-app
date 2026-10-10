# MANIFESTO DELL'ORDINE FI, LA STESA DI TAROCCHI

Testo dell'ordine: `docs/ordini/ORDINE_FI_TESTO.md`. Rapporto: `docs/ordini/RAPPORTO_ORDINE_FI.md`. Da dove si riparte: `docs/ordini/RIPRESA.md`.

Una voce CHIUSA porta sotto di se' DOMANDA, PROVA e MISURA. Le voci aperte dicono perche' lo sono.

## VOCE FI.01

**CHIUSA.** Le cinque stese, con le posizioni di ciascuna come dato.

DOMANDA: "bisogna inserire la stesa a 1 carta e quelle delle tradizioni piu' popolari"
PROVA: test/le_stese_del_cerchio_test.dart
MISURA: stese nel catalogo da 3 a 5 (1, 3, 4, 7 e 10 carte), ognuna con posizioni, posto sul tavolo e fonte; aperta resta solo quella a tre carte

## VOCE FI.02

**CHIUSA.** La geometria e' un dato accanto alle posizioni.

DOMANDA: "la croce di Dora e' una croce: la prima in basso, la seconda a sinistra, la terza a destra, l'ultima in alto"
PROVA: test/le_stese_del_cerchio_test.dart
MISURA: posti sul tavolo dichiarati da 0 a 25 (1, 3, 4, 7 e 10); la Croce Celtica con 1 carta di traverso sulla prima e 4 nel bastone dal basso in alto

## VOCE FI.03

**APERTA IN ATTESA DI VERIFICA.** La regola di Dora (l'esito passa attraverso i due lati) si aggancia quando la croce avra' il corpus delle sue posizioni e la sua lettura a video: prima nessuno la puo' vedere.

## VOCE FI.04

**CHIUSA.** Le diciassette posizioni.

DOMANDA: "Porta SpreadPosition da tre a diciassette voci. Tre esistono gia' e non si toccano."
PROVA: test/le_stese_del_cerchio_test.dart
MISURA: posizioni da 3 a 17; la stesa a tre carte legge ancora le sue 3 (26 usi nel codice e 34 nelle prove portati su SpreadPosition.treCarte)

## VOCE FI.05

**CHIUSA.** "Te stesso" passa dalla marca del genere.

DOMANDA: "L'etichetta "Te stesso" cade sotto la guardia del genere"
PROVA: test/le_stese_del_cerchio_test.dart
MISURA: forme a video da 1 a 3: Te stesso, Te stessa, Tu

## VOCE FI.06

**CHIUSA.** Le quattro chiavi con la loro tradizione.

DOMANDA: "eliminerei quella di Caligo e inserirei tradizione e fonti reali" e "confermo che voglio la quarta"
PROVA: test/le_chiavi_e_la_matrice_dei_tarocchi_test.dart
MISURA: chiavi da 3 a 4, etichette col nome di una persona o di un Maestro da 2 a 0, chiavi con la fonte dichiarata da 0 a 4

## VOCE FI.07

**CHIUSA.** La chiave arriva al modello come voce.

DOMANDA: "Nel prompt la chiave entra come istruzione di voce."
PROVA: test/la_stesa_interpreta_davvero_test.dart
MISURA: chiavi che cambiano l'istruzione da 0 a 3 (la Predittiva la lascia identica a prima)

## VOCE FI.08

**CHIUSA.** La lettura di casa dice la sua chiave.

DOMANDA: "lo DICHIARA a chi legge, invece di spacciare un ripiego per la chiave scelta"
PROVA: test/la_stesa_interpreta_davvero_test.dart
MISURA: righe che dichiarano la lettura di casa da 0 a 1, solo quando il modello non risponde e la chiave non e' la Predittiva

## VOCE FI.13

**APERTA IN ATTESA DI VERIFICA.** La misura e' fatta (54.871.350 byte, 54,9 MB in base 1000, 52,3 MiB in base 1024, archivio da 260.267.304 byte a circa 315 MB) e la domanda e' girata al fondatore: i due mazzi nell'app o sul bucket con CDN.

## VOCE FI.16

**CHIUSA.** I cartigli delle due cartelle sono vuoti.

DOMANDA: "Misura la fascia dei due cartigli su TUTTE le definitive dei due mazzi"
PROVA: docs/collaudo/FI/cartigli.txt
MISURA: carte misurate da 4 (le quattro dell'Architetto) a 156; carte con testo nei cartigli: 0; un testo inciso a mano su una copia ne fa scostare da 263 a 1630 pixel

## VOCE FI.26

**CHIUSA.** Il seme della stesa non decide piu' la stesa compiuta.

DOMANDA: "il tuo suggerimento", cioe' la via che conserva
PROVA: test/la_stesa_si_conserva_test.dart
MISURA: rientri con la stessa domanda che ritrovano le stesse carte da 0 a 1 su 1 nella guardia

## VOCE FI.27

**CHIUSA.** La stesa si conserva per la giornata, e la schermata lo dice.

DOMANDA: "chi riapre la stessa stesa con la stessa domanda ritrova le sue carte"
PROVA: test/la_stesa_si_conserva_test.dart
MISURA: righe di Medora al rientro da 0 a 1; carte spese per rileggere la stesa conservata da 3 a 0

## VOCE FI.28

**CHIUSA.** Taglio e mescolamento restano vivi dentro la stesa in corso.

DOMANDA: "Taglio, mescolamento e scuotimento continuano a funzionare DENTRO la stesa in corso"
PROVA: test/la_carta_estratta_non_cambia_test.dart
MISURA: righe del motore del mescolamento cambiate: 0 su 0; prove della stesa in corso verdi da 911 a 911

## VOCE FI.32

**CHIUSA.** La matrice dei tarocchi nel catalogo dei piani.

DOMANDA: "tabella ok"
PROVA: test/le_chiavi_e_la_matrice_dei_tarocchi_test.dart
MISURA: righe della matrice da 41 a 51; righe toccate fra quelle esistenti (carte al giorno e stesa da dieci): 0

## VOCE FI.41

**CHIUSA.** La guardia della stesa conservata, dall'avvio vero.

DOMANDA: "Monta l'app dall'avvio vero, fa una stesa su una domanda, esce dalla schermata, rientra con la stessa domanda e pretende le stesse carte."
PROVA: test/la_stesa_si_conserva_test.dart
MISURA: innesti che la fanno cadere da 0 a 2 su 2 (ricerca spenta, conservazione spenta)

## VOCE FI.45

**APERTA IN ATTESA DI VERIFICA.** Fatte le anteprime della schermata dei selettori (docs/preview/prima_dopo/fi_selettori_tipo_prima.png e le altre tre); quelle della croce, del ferro di cavallo, della Croce Celtica e della card aspettano che quelle stese abbiano il loro tavolo e il loro corpus.
