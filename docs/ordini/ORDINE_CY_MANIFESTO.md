# ORDINE CY, MANIFESTO

8 settembre 2026, notte. Tre segnalazioni del fondatore sulla build 2232
appena scaricata, e le prime due hanno una causa sola.

## LE PAROLE DEL FONDATORE

> ho fatto il rito dell'Alba e i testi vengono ripetuti 3 volte CAZZO.

> la musica NON SI FERMA SE METTO L'APP IN BACKGROUND. Il soffio impiega molti
> secondi a comparire la prima volta, come se caricasse. quando compare il
> soffio C'E' ANCORA IL RITO CHE IN QUESTA FUNZIONALITA' DOVEVI ELIMINARE!

---

## LE VOCI

- **CY.01** I testi dell'Alba ripetuti. **CHIUSA, ed e' colpa mia.**

  `DawnGift.orientation` portava dentro il gesto e la via tattile, da sempre.
  **La voce CW.07 ha messo il rituale dentro il riquadro IL MANTRA DI OGGI
  senza toglierlo da li'**, e da quel momento le stesse due frasi escono due
  volte, una sotto l'altra.

  **E la mia guardia non poteva accorgersene**: pretendeva che il riquadro
  CONTENESSE il mantra, e lo conteneva. Non ha mai chiesto se quel testo fosse
  anche ALTROVE. **Ho misurato il pezzo che avevo aggiunto invece
  dell'insieme**, che in questo progetto e' la famiglia piu' costosa di tutte,
  e la duplicazione era **gia' visibile nello screenshot che avevo catturato
  io**, `docs/verifica/CW/55_alba_rituale.png`. Non l'ho vista.

  Adesso `orientation` e' la sola risposta del giorno, e il gesto vive in un
  posto solo.

- **CY.02** Il rito comparso nel Soffio. **CHIUSA, stessa causa.** Tutti e
  cinque i Doni montano la stessa scheda. Nel Soffio il riquadro non c'e',
  quindi quel gesto non era una ripetizione: era **un secondo rito in una
  funzione che un rito da compiere non deve averlo**, perche' il rito del
  Soffio e' il respiro. Parole del fondatore del 7 settembre, disattese dalla
  mia stessa voce sei ore dopo.

- **CY.03** L'apertura ripetuta. **CHIUSA.** La risposta dice *"La Luna e'
  calante: questa e' la proporzione esatta..."* e il gesto riapriva con *"La
  Luna e' calante. Prendi qualcosa..."*: **254 giorni su 365**, misurati.

  I gesti del corpus aprono col fatto del cielo perche', finche' il gesto ERA
  il corpo del responso, doveva bastare a se stesso. Adesso il rito espone due
  campi: **`gesto` intero**, per la card che si condivide e per l'avviso che
  arriva a telefono chiuso, che stanno soli; e **`soloIlGesto`** per il
  riquadro, che ha la risposta un centimetro sopra.

  **Il taglio non e' a occhio**: si toglie la prima frase **solo se** contiene
  il segnaposto del dato che quel gesto dichiara di nominare. Un gesto che
  nomina il cielo a meta' testo, come quello dell'orologio, resta intero. E un
  gesto fatto della sola frase del cielo torna intero, perche' meglio ripetersi
  che lasciare il riquadro senza istruzione.

- **CY.04** La musica non si ferma in secondo piano. **CHIUSA, e la voce CW.01
  aveva riparato meta' del difetto.**

  L'ordine delle attese era sbagliato davvero, e sul telefono la pausa arriva
  alla piattaforma **un secondo dopo il tasto Home**: quella misura era vera, e
  **non bastava a dire che la musica taceva**.

  La seconda meta' e' `RegiaDellaMusica`, che tiene un `Timer.periodic` da due
  secondi. Esiste per una ragione buona: nella 2219 il tappeto risultava
  chiesto e non suonava, e la regia credeva alla propria memoria invece di
  guardare il lettore. **Quel guardiano non sapeva niente del secondo piano**:
  vedeva la musica ferma, concludeva che si era persa, e la faceva ripartire
  mentre l'app era fuori. Due secondi di silenzio, e poi di nuovo musica.

  **PERCHE' NON L'HO VISTO SUL DISPOSITIVO DI COLLAUDO.** Su quel telefono il
  tappeto non e' mai entrato in `state:started`, e l'ho dichiarato nel referto
  dell'ordine CW. Con la musica che non parte, la sentinella non ha niente da
  far ripartire: **il caso che rompe non si presentava.** La misura che avevo
  era giusta e parziale, e la parte che mancava era proprio quella che il
  fondatore sente.

  Adesso il motore dichiara `inSecondoPiano`, ed e' **un fatto diverso** da "la
  musica stava suonando": il secondo vale solo per chi aveva il tappeto acceso,
  il primo vale sempre, perche' **a musica ferma cio' che si vede e' identico
  in secondo piano e in una schermata muta**. La sentinella lo chiede a chi lo
  sa invece di dedurlo.

- **CY.05** Il Soffio lento alla prima apertura. **DICHIARATA, NON RIPARATA.**

  Lo sfondo del soffione, `assets/ritual_backgrounds/breath_dandelion.png`,
  pesa **783.483 byte**, e la scena non disegna finche' non e' decodificato:
  `_loadLayers` lo risolve in `initState` e la scena aspetta `_dandelionImg`.

  E' il candidato piu' solido e **non e' misurato sul telefono**. Si scrive
  invece di ripararlo alla cieca: una cura applicata a una causa supposta e'
  come una guardia che nasce verde.

---

## LE DUE GUARDIE NUOVE, tutte e due nate rosse

- **`l_alba_non_si_ripete_mai`** misura il DATO su 365 giorni, prima ancora
  della schermata. Rossa su **365 giorni col gesto dentro il responso** e su
  **254 con l'apertura ripetuta**. Il primo giro cercava il gesto dentro
  `rito.risposta.risposta` e restava VERDE: il gesto non stava li', stava in
  `DawnGift.orientation`. **Misurare il campo accanto a quello rotto e'
  esattamente l'errore che ha prodotto questa voce**, e l'ho commesso di nuovo
  mentre la scrivevo.
- **`la_sentinella_dorme_in_secondo_piano`** non compilava nemmeno, perche' il
  fatto che pretende non esisteva.

---

## LA VERIFICA A VIDEO

Dispositivo 767f596c, build 2233 installata e accesa.

| file | cosa dimostra |
| --- | --- |
| `docs/verifica/CY/01_alba.png` | il responso chiude, e sotto IL MANTRA DI OGGI porta la sola istruzione, senza la frase del cielo e senza ripetizione |
| `docs/verifica/CY/03_soffio_responso.png` | il Soffio dice *"Il respiro non cambia il cielo: ti mette nel passo in cui il cielo si trova adesso"*, e nessun gesto da compiere |

**La musica**: dopo venti secondi in secondo piano la sentinella non ha
parlato, e il lettore dell'app resta `state:paused`. **Non e' la prova
completa**, perche' su questo telefono il tappeto non parte: la prova vera e'
l'orecchio del fondatore.

## LA CONSEGNA

**Build 2233**, release `1r7u0qg4ifb60` su App Distribution, distribuita a
cloud@esotericircle.app, un invito accettato riletto dal server. Numero 2233
letto con aapt2 dall'archivio contro il 2232 dell'ultima consegnata. Prova di
accensione FATTA sul dispositivo di collaudo.

---

VOCI_TOTALI: 5
VOCI_CHIUSE: 4
VOCI_APERTE: 0
VOCI_FERMATE_SU_PREMESSA_FALSA: 0
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0
VOCI_FERMATE_SU_MISURA_MANCANTE: 1
GUARDIE_NUOVE: 2
VERIFICA_A_VIDEO: 767f596c
