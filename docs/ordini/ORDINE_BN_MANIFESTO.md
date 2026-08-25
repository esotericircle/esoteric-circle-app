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
- **BN.03** Il lampo del responso. CHIUSA: **era la stessa forma di difetto dell'ordine BK, due stati diversi che condividono lo stesso valore.** Il responso si mostrava se la stesa era compiuta e l'attesa non era PIENA, ma `assente` valeva sia prima che l'attesa cominciasse sia dopo che era finita; fra il tocco della terza carta e l'inizio dell'attesa c'e' la fioritura dell'elemento, che dura, e in quella finestra il responso entrava in albero. Adesso c'e' un fatto suo, `_responsoPronto`, vero **una volta sola** e solo quando l'attesa e' finita davvero. **MISURA CHE CHIUDE**: dalla terza carta fino alla comparsa del responso, controllato ogni 100 millesimi, i caratteri del responso in albero sono **ZERO**, compreso il primo fotogramma dopo il tocco. La grandezza misurata ha dovuto stringersi due volte, e le due volte sono scritte nella prova: fuori dal conto la scena dell'attesa, che porta le righe di Medora mentre pensa, e le CARTE, che portano il proprio nome (un nome che compare perche' la carta si e' scoperta non e' il responso). **Rosso dimostrato** rimettendo la condizione vecchia.
- **BN.04** La carta si apre al tocco. CHIUSA: `lib/features/tarot/carta_ingrandita.dart`. La carta si gira verso chi guarda occupando la scena, il suo elemento si accende attorno riusando `ElementalReveal`, cioe' la stessa fioritura che la carta ha avuto quando e' uscita, e il testo sale da sotto. **Il testo non si riscrive**: e' `PosizioneLetta.testo`, lo stesso oggetto che riempie la bolla. Anche la figura e' la stessa: `_CardFace` e' diventata `FacciaDellaCarta` pubblica invece di nascere una seconda copia del disegno. Tre uscite, come approvato: tocco fuori (il velo e' `barrierDismissible`), gesto indietro del sistema (e' una rotta, quindi lo ha per costruzione) e trascinamento verso il basso. Si apre solo a responso pronto, perche' prima non esiste nessuna descrizione da mostrare e un ingrandimento vuoto sarebbe una porta su niente. **MISURE**: su tutte e tre le posizioni il testo mostrato e' **identico** a uno di quelli della sua bolla; il bersaglio di ogni carta e' almeno **48 per 48** punti, dichiarato con un vincolo esplicito cosi' nessuna futura riduzione della carta puo' scendere sotto senza che una prova lo dica; con Riduci Movimento la carta e' composta e leggibile **al primo fotogramma**, senza rotazione. **Rosso dimostrato**: aggiunto un solo spazio al testo dell'ingrandimento, la prova cade dicendo che sono due copie.
- **BN.05** La carta chiave si vede anche nella stesa. APERTA.
- **BN.06** Il consiglio di Medora. APERTA.
- **BN.07** Il cielo di oggi entra nella lettura. APERTA.
- **BN.08** Il filo fra le tre carte. APERTA.
- **BN.09** Il gating della stesa, che oggi non esiste. APERTA.

MARCATORI, per la guardia:
VOCI_TOTALI: 10
VOCI_APERTE: 5
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0
VOCI_FERMATE_SU_PREMESSA_FALSA: 0
VOCI_FERMATE_SU_DECISIONE_DEL_FONDATORE: 0
VOCI_CHIUSE: 5
