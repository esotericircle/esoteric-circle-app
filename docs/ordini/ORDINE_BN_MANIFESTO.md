# ORDINE BN, LA REVISIONE DELLA STESA DI TAROCCHI

Ordine del fondatore del 25 agosto 2026. Vale il mandato esteso di BF. Ramo
`claude/esoteric-circle-master-order-e798aj`, guardia
`test/ordine_bn_guard_test.dart`.

## Le premesse, verificate sulla testa d64b3d0

- **P1 VERA, e la meccanica e' peggiore di come suona.** `_pick` riceve
  l'indice nel VENTAGLIO e lo passa come indice del MAZZO RESIDUO. Il
  ventaglio ha **settantotto posizioni fisse** (`stesa_fan.dart`,
  `carte = 78`), il residuo si accorcia a ogni carta e si riordina a ogni
  mischia o taglio, e oltre la sua lunghezza `assegna` **ripiegava su zero**.
- **P5 VERA**: la riga richiusa mostrava `setup.riepilogo` senza titolo, e il
  pannello aperto diceva "LA TUA STESA".
- **P7 VERA**: in `lib/features/tarot/` non esiste nessuna chiamata al
  contatore, al listino, al riscatto o all'invito. Le uniche occorrenze della
  parola residuo sono commenti sul mazzo. `rune_draw_screen.dart` invece ha
  `QuestionAllowance`, `corredoDelRiscatto` e `showUpgradeInvite`.
- **P8 VERA**: `functions/src/budget.ts` porta quattro budget, e
  `gettate: [1, null, null, null]`.

## BN.00, LA RICOGNIZIONE

**I gesti della scena, e quali sono senza risposta.** Gli unici `onTap` sono
il ventaglio, il taglio e la mischia. **Le carte gia' estratte non hanno
nessun gesto**: sono l'oggetto della scena e non rispondono al dito (curato da
BN.04). Il pannello delle scelte si apre e si chiude.

**Le stringhe che dovrebbero venire da altrove.** Nessuna cifra di prezzo e
nessun conto di residuo e' scritto nella schermata, per la ragione che non ce
ne sono affatto: la stesa non ha gating (BN.09).

## Le voci

- **BN.00** La ricognizione. CHIUSA: questo capitolo.
- **BN.01** Il nome della prima bolla. CHIUSA: il nome vive in una costante sola, `PannelloDelleScelte.titolo`, ed e' lo stesso nei due stati; la riga richiusa porta il titolo sopra e il riassunto delle scelte sotto, perche' il titolo dice cosa puoi fare e il riassunto cosa hai scelto.
- **BN.02** La carta che esce e' quella toccata. CHIUSA: **la strada scelta e' non avere due indici.** Il mazzo si tiene DISPOSTO (`mazzoDisposto`, una voce per ogni posizione dell'arco, nulla dove la carta e' stata presa) e chi assegna passa la posizione toccata; `mazzoResiduo` resta come VISTA derivata e non come secondo dato. Mischia e taglio riordinano le carte SOTTO le posizioni ancora libere, che e' cio' che quei gesti promettono a chi li guarda, e le posizioni gia' prese restano vuote perche' quelle carte sono sul tavolo. Una posizione presa o inesistente adesso **non da' niente**, invece di ripiegare sulla prima carta del mazzo: un gesto senza risposta e' meglio di una risposta falsa. **MISURA CHE CHIUDE**: cento giri, tre carte per giro, con una mischia e un taglio fra una carta e l'altra e la posizione scelta alta nell'arco apposta, dove il ripiego scattava: **trecento estrazioni su trecento** danno la carta che stava sotto il dito, e nessuna esce vuota. **Rosso dimostrato**: rimesso il vecchio passaggio dell'indice e verificata l'iniezione prima di leggere l'esito, al secondo giro sotto il dito c'era `denari_02` e usciva `spade_07`.
- **BN.03** Il lampo del responso. APERTA.
- **BN.04** La carta si apre al tocco. APERTA.
- **BN.05** La carta chiave si vede anche nella stesa. APERTA.
- **BN.06** Il consiglio di Medora. APERTA.
- **BN.07** Il cielo di oggi entra nella lettura. APERTA.
- **BN.08** Il filo fra le tre carte. APERTA.
- **BN.09** Il gating della stesa, che oggi non esiste. APERTA.

MARCATORI, per la guardia:
VOCI_TOTALI: 10
VOCI_APERTE: 7
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0
VOCI_FERMATE_SU_PREMESSA_FALSA: 0
VOCI_FERMATE_SU_DECISIONE_DEL_FONDATORE: 0
VOCI_CHIUSE: 3
