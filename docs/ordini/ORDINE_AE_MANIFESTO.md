# ORDINE AE. IL LOTO DELLE PERLE: CODE SCONTORNA, TROVA LE PERLE, ACCENDE

Cinque voci, da AE.01 a AE.05. Ramo `claude/esoteric-circle-master-order-e798aj`,
premesse verificate sulla testa `489553e` il 16 agosto 2026.

## Perche' quest'ordine esiste

Mauro ha rifatto l'arte del Loto: cinque fiori, e su ogni petalo una perla
grigia con riflesso bianco. Cinquanta perle piu' cinque centri d'oro fanno
cinquantacinque bersagli. **Cambia la legge delle luci del Loto: si illuminano
le perle e i centri, non piu' i petali**, e il problema dei ventidue petali veri
contro trentatre' bagliori di ripiego muore qui. Il sorgente e'
`docs/preview/journal_loto_nuovo-1.png`, censito dall'ordine AD come non
tracciato: da questo ordine in avanti e' suo, e non si modifica mai sul posto.

## Come si legge questo file

Una riga per voce, con lo stato in fondo. Stati ammessi: CHIUSA, FERMATA SU
PREMESSA FALSA, FERMATA IN ATTESA DI DECISIONE, APERTA. Finche' una riga e'
APERTA la guardia `test/ordine_ae_guard_test.dart` resta rossa. Le voci non si
rinumerano, non si accorpano e non si dichiarano coperte da un'altra. I
marcatori in fondo si contano sulle righe.

## Le premesse, verificate una per una il 16 agosto 2026

1. **P1 VERA, rimisurata.** Il sorgente e' 819 per 1456, RGBA, alfa minimo 238 e
   massimo 255, zero pixel del tutto trasparenti, angolo bianco pieno.
2. **P2 VERA.** `loto.png` e `loto_pallini.png` sono 941 per 1672, misurati, e
   il Loto passa dai pallini: `sorgenteDi` lo dichiara alla riga 107 di
   `regole_delle_tre_arti.dart`.
3. **P3 FALSA ALLA LETTERA, e si dichiara col meccanismo vero.** La premessa
   dice che i gruppi si assegnano per vicinanza al grande col colore come sola
   controprova. Letto in `lettura_degli_ancoraggi.dart` righe 288 e 292: la
   vicinanza e' la strada dell'ARTE, mentre **sul file dei pallini il gruppo e'
   DICHIARATO dal colore**, che il codice stesso motiva come dato migliore di
   una distanza. **La voce AE.02 resta eseguibile senza adattare niente**:
   questo ordine genera sia i raggruppamenti spaziali sia i colori, i due
   coincidono per costruzione, e la vicinanza diventa la controprova del colore
   invece del contrario. Nessuna azione della voce cambia.
4. **P4 VERA.** Le forme del Loto sono 55, di cui 33 ripieghi, contate nel dato.
5. **P5 VERA.** `ArteDelSentiero.acceso` e' `true`, riga 53.

## Le cinque voci

- **AE.01** Lo scontorno e la misura giusta — CHIUSA
- **AE.02** Le perle si trovano, i pallini si generano, gli ancoraggi si rifanno — CHIUSA
- **AE.03** Le forme diventano le perle — CHIUSA
- **AE.04** Le anteprime, e i cerchi sopra l'arte per gli occhi di Mauro — CHIUSA
  (decisione di Mauro del 17 agosto 2026, riportata dall'Architetto: i suoi
  occhi sono arrivati attraverso gli ordini AF e AG, le anteprime vanno bene
  e l'arte del Loto con le lampadine resta com'e'.)
- **AE.05** Il manifesto e il rapporto — CHIUSA

## Cosa guarda Mauro per chiudere la AE.04

Quattro immagini: `journal_loto_due`, `journal_loto_dodici` e
`journal_loto_cinquantacinque`, la schermata `sentiero-loto-meta`, e la mappa
`loto_perle_trovate`, tutte in `docs/preview/`. I suoi difetti vengono prima di
quelli dell'Architetto. Due fatti gia' visti da Code e non corretti perche'
nessuna voce li copre: **le sacche di fondo bianco opache fra i petali e gli
steli**, dichiarate dalla AE.01, che sul fondo scuro dell'app si vedono forte; e
la riga di sintesi che dice ancora "petali accesi", testo del corpus fuori da
quest'ordine.

## I marcatori, contati sulle righe

VOCI_TOTALI: 5
VOCI_APERTE: 0
VOCI_CHIUSE: 5
VOCI_FERMATE_SU_PREMESSA_FALSA: 0
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0
