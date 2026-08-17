# ORDINE AG. LE PERLE DEL LOTO: UGUALI, CENTRATE, E MAI BLU

Quattro voci, da AG.01 a AG.04. Ramo `claude/esoteric-circle-master-order-e798aj`,
premesse verificate sulla testa `a70b457` il 17 agosto 2026.

## Perche' quest'ordine esiste

Mauro ha guardato le lampadine dell'ordine AF e ha dato tre difetti, tutti sul
Loto: le perle sui petali non sono tutte uguali; alcune non sono centrate sul
petalo; alcuni petali cambiano colore e tendono al blu quando la perla sopra e'
illuminata. L'Architetto aggiunge un fatto della stessa famiglia: due lampade
su cinquantacinque escono azzurre invece che oro caldo.

## Come si legge questo file

Una riga per voce, con lo stato in fondo. Stati ammessi: CHIUSA, FERMATA SU
PREMESSA FALSA, FERMATA IN ATTESA DI DECISIONE, APERTA. Finche' una riga e'
APERTA la guardia `test/ordine_ag_guard_test.dart` resta rossa. Le voci non si
rinumerano, non si accorpano e non si dichiarano coperte da un'altra. Prove
mirate durante le voci, suite intera UNA volta sola in fondo prima del push.

## Le premesse, verificate una per una il 17 agosto 2026

1. **P1 VERA, misurata.** Le perle spente sono pixel dell'arte e variano: i
   raggi dei cinquanta mini vanno da 20,0 a 37,0 contro la mediana di 27,9, e
   su un campione di dieci petali lo scostamento fra il centro della perla e
   l'asse del petalo va da 0,4 a 21,0 pixel, mediana 12,3.
2. **P2 VERA, ipotesi confermata e misurata.** Il disco della lampadina e' a
   palette fissa, ma l'ALONE e le linee ereditano `_luceDi(forma.colore)`, che
   tiene la TINTA della materia e alza la saturazione al pavimento 0,74. Due
   dischi su cinquantacinque, gli indici 13 e 46, hanno tinta fredda (190 e
   220 gradi) con saturazione quasi nulla (0,050 e 0,032): alzata a 0,74
   diventa azzurro pieno. La causa vera del blu e' l'eredita' del colore nel
   gradiente dell'alone, non il modo della fusione.
3. **P3 VERA, contata.** Gli ancoraggi del Loto sono 55 in cinque gruppi da
   undici, dieci mini piu' un grande ciascuno, e il tocco sul Journal passa
   dagli stessi ancoraggi (`disegno_del_sentiero.dart`, `_toccoSullArte`).
4. **P4 VERA.** `docs/preview/journal_loto_nuovo-1.png` e' in storia dal
   manifesto dell'ordine AE e non si modifica mai sul posto: ogni derivato e'
   un file nuovo o `brand_assets/sentieri/loto.png`. L'albero e' pulito su
   tutti e due.

## Le quattro voci

- **AG.01** Le perle le disegna il codice, uguali e centrate — APERTA
- **AG.02** Mai piu' blu — APERTA
- **AG.03** Le anteprime tornano vere — APERTA
- **AG.04** Il manifesto e il rapporto — APERTA

## I marcatori, contati sulle righe

VOCI_TOTALI: 4
VOCI_APERTE: 4
VOCI_CHIUSE: 0
VOCI_FERMATE_SU_PREMESSA_FALSA: 0
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0
