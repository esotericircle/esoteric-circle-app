# ESITO dell'ORDINE DELLE SEI CREAZIONI

## Dichiarazione, scritta prima di toccare il codice

Otto voci, nessuna torna vuota. Ho guardato il codice di ciascuna prima di
stimare, e questo e' quello che mi aspetto.

**Versione piena, senza riserve** (cinque voci):

- **C1, il Sigillo.** La schermata usa `_StepBody`, cioe' l'impalcatura comune
  che tiene il visivo in una scatola in alto: e' quella scatola a spingere il
  sigillo in cima e a lasciare mezzo schermo vuoto sotto. Non e' un difetto di
  posizionamento, e' che il sigillo non dovrebbe stare dentro quell'impalcatura.
  Gli serve un passo tutto suo.
- **C5, l'orologio.** Un quadrante con due lancette e un `AnimationController`
  che interpola l'angolo. La sola insidia e' il percorso piu' breve, che si
  risolve normalizzando la differenza fra meno mezzo giro e piu' mezzo giro.
- **C6, l'anteprima del tono.** Le opzioni esistono gia' (`CourtesyForm`), le
  frasi sono redazione, e la scrittura progressiva e' una sottostringa che
  cresce.
- **C7, le immagini tagliate.** La causa e' una sola e l'ho gia' vista:
  `_Miniatura` e' 44 per 44 con `BoxFit.cover`, che riempie ritagliando. Va
  cambiata la proporzione e il criterio di adattamento.
- **C8, le tre verifiche.** Sono sguardi, piu' una anteprima nuova della carta
  natale piena da aggiungere al corredo.

**A rischio di versione semplice** (tre voci), in quest'ordine di rischio
crescente:

- **C2, i due trionfi.** L'Animale ha gia' `AnimalReveal`, quindi la sua
  schermata parte da qualcosa. Gli Angeli no: la loro scena in sequenza e' da
  costruire da zero, insieme all'innesto di tutte e due nel percorso di
  onboarding, che oggi non le prevede.
- **C3, il carosello.** E' fisica di trascinamento con inerzia su una
  schermata da 1192 righe, ed e' la voce che quattro ordini hanno rimandato.
- **C4, il planisfero.** Richiede una sagoma del mondo dentro l'app: non
  esiste un asset e non si scarica nulla a runtime, quindi va incorporata una
  maschera terra e mare abbastanza piccola da non pesare, abbastanza fedele da
  far riconoscere i continenti. Se la sagoma non regge, la versione semplice
  resta un campo di punti col luogo acceso nel punto giusto.

**La versione semplice, se serve, la prendera' l'ultima della lista**, come
l'ordine impone: prima C4, poi C3, mai C1.

Il consuntivo di questa stima sta in fondo, dopo gli otto esiti.

## Stato voce per voce

Si compila mentre il lavoro procede.
