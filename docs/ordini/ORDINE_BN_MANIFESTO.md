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
- **BN.05** La carta chiave si vede anche nella stesa. CHIUSA: il segno e' della STESSA famiglia visiva della bolla, cioe' l'oro pieno contro l'oro tenue, e non un secondo linguaggio: una cornice a due punti con l'alone, sopra la carta e sotto l'aura, che non tocca la figura. **MISURA, sui PIXEL e mai sui rettangoli** come vuole il metodo di AX.02, perche' le carte escono dal proprio riquadro: si conta l'oro in una cornice di sei punti attorno alla carta. Su tre semi, con la chiave che cade su tutte e tre le posizioni (futuro, presente, passato): **3.232 contro 495 e 481**, **2.971 contro 504 e 483**, **3.319 contro 503 e 488**, cioe' sempre oltre sei volte le altre contro la soglia di una volta e mezza. **Rosso dimostrato** togliendo il segno. **La FORMA e' una decisione visiva del fondatore**: l'anteprima a 360 punti gli e' stata consegnata, e se la vuole diversa si cambia la forma senza toccare la misura.
- **BN.06** Il consiglio di Medora. CHIUSA: **i paragrafi esistevano gia' e nessuno li vedeva.** Alla domanda dell'ordine (dove vive quel testo) la risposta e' che il consiglio nasce come CINQUE pezzi dichiarati in `TarotReading.consiglioDi`, appiattiti da un `join(' ')` in un muro solo. Non si e' tagliato niente: i pezzi si raggruppano per SENSO in tre paragrafi (la lente con la risposta e il consiglio del gruppo; le tre carte dal passato al futuro; i versi e i Maggiori), e quando la lettura dei versi non c'e' restano due, che l'ordine ammette. Nessuna frase e' spezzata perche' non si taglia: si uniscono pezzi che erano gia' interi. Il TITOLO sale da `etichetta` (il pavimento della scala, dodici punti, la misura piu' piccola dell'app data alla bolla che la persona porta via) a `titoloScheda`, diciotto: il gradino pieno successivo, preso dalla scala e non scelto qui. **MISURE**: su cinque semi per sedici argomenti, cioe' ottanta letture, i paragrafi sono sempre due o tre e **nessuno comincia con una minuscola**, cioe' a meta' di una frase; il titolo cresciuto resta su una riga sola a 360 punti. **Rosso dimostrato** rimettendo il blocco unico.
- **BN.07** Il cielo di oggi entra nella lettura. CHIUSA: **P9 risolta**, e la risposta e' che alla stesa non mancava un dato ma la domanda: `BirthIdentityController` vive nel guscio dell'app ed e' raggiungibile da qualunque schermata, ed e' la stessa porta dell'Oroscopo. Mentre Medora pensa compare UNA riga col fatto vero del giorno, da `CorrenteDelCielo.fattoDelGiorno`, e il consiglio la raccoglie in coda all'ultimo paragrafo. **MISURE**: il fatto che la stesa userebbe e' lo STESSO oggetto che l'Oroscopo nomina nello stesso giorno, verificato confrontando le due porte, quindi coincide per costruzione e non per copia; senza carta natale `ceCieloVero` e' falso, il fatto e' nullo, la riga non esiste e il consiglio resta **identico** a quello di oggi; la durata dell'attesa non cambia in nessuno dei due casi. **Il cielo sta in CODA all'ultimo paragrafo e non ne apre uno quarto**, perche' le due voci dello stesso ordine devono stare in piedi insieme: la voce 06 ne ammette due o tre, e la prova lo verifica anche col cielo acceso. **Rosso dimostrato**: fatta comparire una frase generica senza carta natale, la prova cade dicendo che sarebbe una promessa non mantenuta.
- **BN.08** Il filo fra le tre carte. CHIUSA: `lib/features/tarot/filo_fra_le_carte.dart`. Corre quando esce la terza carta e **prima** che Medora cominci a pensare, quindi due momenti in fila e non due cose sovrapposte. **Parte sempre dalla carta chiave**, che e' il modo visivo di dire da dove il senso viene, e non un tratto che unisce da sinistra a destra. **MISURE**: dura **720** millesimi, dentro la finestra 600..900; l'ordine dei tratti mette la chiave per prima su tutte e tre le posizioni possibili; il disegno e' **un solo tracciato** con una sola penna, invece di tre `drawLine` con altrettanti Paint, ed e' la scelta che tiene il costo per fotogramma sotto il budget; con Riduci Movimento il filo compare fermo al pieno del vigore per la stessa durata, e non si salta. **Rosso dimostrato**: portata la durata a 1.500 millesimi, la prova cade dicendo che non e' piu' un istante leggibile.
- **BN.09** Il gating della stesa, che oggi non esiste. APERTA.

MARCATORI, per la guardia:
VOCI_TOTALI: 10
VOCI_APERTE: 1
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0
VOCI_FERMATE_SU_PREMESSA_FALSA: 0
VOCI_FERMATE_SU_DECISIONE_DEL_FONDATORE: 0
VOCI_CHIUSE: 9
