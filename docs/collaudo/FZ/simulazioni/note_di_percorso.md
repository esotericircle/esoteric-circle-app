# Note di percorso, simulazione FZ.09 sul Realme 767f596c

Scritte durante la simulazione, per non perdere le osservazioni fatte dal vivo
prima di scrivere il rapporto finale. Non sono ancora il rapporto: sono il
diario di quello che e' successo a video, da cui il rapporto verra' tratto.

## Onboarding: la sequenza reale vista nel codice

`risveglio_journey.dart`, enum `_Phase`: angeli -> animale -> cartaDiNascita
-> heaven (Il tuo Cielo di Nascita) -> chart (NatalChartReveal) -> resonance
-> reveal (MaestroRevealScreen) -> custodia (CustodiaDelCieloStep) ->
`_chiudiIlRisveglio()` (pop, torna al chiamante, arma il Primo Approdo).

## Osservazione 1: "Il tuo Cielo di Nascita" con luogo mancante

Persona che salta il luogo di nascita (come da copione, "luogo skipped"):
alla fase `heaven`, compare il banner "Per il cielo della tua nascita
servono la data e il luogo. Per ora vedi il cielo di adesso. Aggiungi i dati
di nascita" (`_mancaLaNascita`). Il pulsante di proseguimento NON e' "Leggi
la tua carta" ma "Viaggia nel tempo" (`macchina_viaggia_dal_cielo`): bisogna
avviare la "corsa" della macchina del tempo, che calcola comunque un cielo
(quello di adesso, con l'avviso) e SOLO a corsa finita (fase `fermo` +
`_fraseDArrivo` non vuota) compare "Leggi la tua carta". Questo e' il
comportamento PREVISTO dal codice (ordine FN, FR del 13 ottobre 2026), non un
difetto: la persona deve sapere di dover premere "Viaggia nel tempo" per
proseguire, cosa non ovvia la prima volta (io stesso non l'ho capito subito e
ho provato a tornare indietro con BACK invece di cercare il bottone).

**Sospetto da verificare meglio, non confermato**: il primo tocco su
"Viaggia nel tempo" non ha prodotto alcun cambiamento visibile per 10 secondi
(due catture, a 3s e 10s dal tocco, identiche allo stato precedente il
tocco). Il secondo tocco, invece, ha mostrato subito la fase di transizione
("STO ANDANDO AVANTI NEL TEMPO") e dopo altri ~6s e' arrivato a "fermo" con
"Leggi la tua carta" visibile. Non e' chiaro se il primo tocco sia stato
perso dal mio script di automazione (coordinate o timing) o se sia un difetto
reale del codice (es. la guardia "stessoLuogo" in `_avviaLaCorsa` che non fa
partire la corsa silenziosamente, con uno snackbar che io non ho colto in
tempo). Da riprovare con un metodo di tocco piu' affidabile prima di
attribuire un difetto.

## Osservazione 2: tap non confermati visivamente sul pulsante "Rivela il tuo Maestro" (fase resonance)

Alla fase `resonance` (`ResonanceScreen`, pulsante "Rivela il tuo Maestro",
un `FilledButton` qualunque senza logica particolare), **quattro tocchi
consecutivi** (due via tap_by_desc con content-desc, due a coordinate dirette
lette da screenshot) non hanno prodotto ALCUN cambiamento visibile per oltre
un minuto di osservazione, con screenshot ripetuti identici fotogramma per
fotogramma (stesso minuto secondo escluso). `uiautomator dump` su questa
schermata falliva sistematicamente con `ERROR: could not get idle state`,
lasciando il dump bloccato su un XML vecchio (quello della schermata
precedente, "chart").

Poi, dopo uno scroll (gesture di swipe, non un tap) fatto mentre ero tornato
sulla fase `chart` per ripetere il percorso, lo screenshot successivo ha
mostrato **la schermata finale `custodia`** (CONGRATULAZIONI, +10 Eos): la
fase era quindi avanzata fino in fondo (resonance -> reveal -> custodia),
nonostante nessuno dei miei tocchi fosse mai stato confermato a video nel
mentre.

**Ipotesi piu' probabile**: i tocchi sul pulsante "Rivela il tuo Maestro"
ERANO arrivati e avevano funzionato, ma lo screenshot (`adb shell screencap`)
per un periodo non rifletteva il framebuffer reale piu' aggiornato (stessa
famiglia di sintomo del fallimento di `uiautomator dump`, "could not get
idle state": qualcosa su questa schermata o sulla successiva tiene l'albero
UI/il rendering in uno stato che gli strumenti esterni non riescono a
campionare in modo affidabile). Non e' stato possibile isolare la causa
precisa nel tempo disponibile. **Non attribuibile con certezza a nessuna voce
dell'ordine FZ senza ulteriore indagine mirata**: va segnalato come sospetto,
non come difetto confermato (Regola C: PROVENIENZA IGNOTA se non si risale,
ma qui non c'e' nemmeno la certezza che sia un difetto applicativo invece che
un limite del mio metodo di automazione via adb/uiautomator su questo
device).

**Conseguenza pratica**: dopo essere arrivato a `custodia`, il tocco su
"Continua il cammino" (che dovrebbe chiamare `_chiudiIlRisveglio` e fare
`Navigator.pop()`) ha riportato la UI alla fase `chart`, non alla Home/
Cerchio. Sospetto uno stack di navigazione sporco per via della mia
navigazione con BACK/tap ripetuti fuori sequenza durante l'indagine, non un
difetto del codice in condizioni normali. Ho fatto force-stop e riavviato
l'app pulita per ripartire con uno stack di navigazione pulito.

## DIFETTO CRITICO CONFERMATO: "Rivela il tuo Maestro" spesso non risponde al tocco

**Status: CONFERMATO, riproducibile, bloccante per l'intero onboarding.**

Sul Realme 767f596c (animazioni permanentemente disabilitate dal fondatore),
il pulsante "Rivela il tuo Maestro" della `ResonanceScreen` (fase
`resonance`, penultima fase del Risveglio) spesso non risponde al tocco,
anche a tocchi ripetuti. Osservato su DUE account di prova distinti, in DUE
sessioni separate (riavvio completo dell'app fra le due):

- Account "ProvaFZ" (prima sessione): 4 tocchi falliti consecutivi (due via
  content-desc, due a coordinate dirette), poi un quinto (dopo uno scroll
  fatto su un'ALTRA schermata) ha fatto avanzare la fase fino in fondo
  (custodia) in un colpo solo, senza mai mostrare uno stato intermedio
  osservabile: sintomo di uno o piu' tocchi "in coda" che si sono risolti
  tutti insieme, non di un singolo tocco riuscito.
- Account "ProvaFZ2" (seconda sessione, ripartita da zero apposta per
  escludere uno stato sporco ereditato dalla prima): **13 tocchi falliti
  consecutivi**, verificati uno per uno con screenshot (non solo per
  dimensione file, che da' falsi positivi: una ricattura della STESSA
  schermata puo' avere una dimensione PNG leggermente diversa anche senza
  cambiamenti visibili, per via dello sfondo stellato animato). Provati:
  tocco singolo a coordinate dirette, tocco via content-desc,
  doppio tocco ravvicinato (100ms), tocco prolungato (150ms), swipe corto
  orizzontale e verticale sul pulsante, cinque tocchi in rapida sequenza.
  Nessuno ha prodotto alcun cambiamento.

**Non e' un problema generale di responsivita' del device**: nello stesso
lasso di tempo, `KEYCODE_BACK` ha sempre funzionato immediatamente (torna
alla fase precedente), e tutti gli altri pulsanti dell'onboarding (Angeli,
Animale, Carta di Nascita, Chart) hanno sempre risposto al primo tocco senza
eccezioni. Nessuna eccezione Dart/Flutter nei log (`adb logcat --pid`) nel
momento dei tocchi falliti; nessun errore di layout (`RenderFlex overflowed`
e simili, assenti). Il device risulta sveglio, con l'app giusta in primo
piano, per tutta la durata delle prove.

**Anche un pulsante diverso ha mostrato lo stesso sintomo**: "Scopri chi
risuona con te" (fondo di `NatalChartReveal`, il pulsante che porta DENTRO
`ResonanceScreen`) e' risultato non toccabile in un'occasione, in modo
indistinguibile dal sintomo su "Rivela il tuo Maestro": questo sposta il
sospetto da "difetto specifico del widget `_MaestroAura`" a qualcosa di piu'
generale legato a QUESTE DUE transizioni di fase (`chart` -> `resonance` e
`resonance` -> `reveal`), entrambe raggiunte tramite lo stesso
`AnimatedSwitcher(duration: 450ms)` che avvolge `_buildPhase()` in
`risveglio_journey.dart` (riga ~354), SENZA alcuna gestione esplicita di
`MediaQuery.disableAnimations`. Non e' stato possibile, nel tempo di questa
sessione, isolare la causa esatta: l'ipotesi piu' sostenuta da quanto
osservato (nessun'altra schermata dell'onboarding mostra il sintomo, e sono
proprio le due dopo le quali compare un Maestro/pianeta "vivo" nel layout)
e' che il widget uscente dell'`AnimatedSwitcher`, in qualche condizione,
resti nell'albero e intercetti ancora gli hit test sopra il nuovo pulsante,
ma e' un'ipotesi NON verificata col debugger, va scritta come tale.

**Conseguenza per FZ.09**: il blocco impedisce a QUALSIASI persona (incluse
tutte quelle delle previsioni scritte) di completare l'onboarding su questo
device in modo affidabile al primo tentativo. Va attribuito con
PROVENIENZA IGNOTA (Regola C): nessun ordine FZ ha toccato
`risveglio_journey.dart`, `resonance_screen.dart` o l'`AnimatedSwitcher` che
le avvolge; il difetto preesiste a questo ordine e non e' stato introdotto
da esso, ma e' stato scoperto durante la simulazione FZ.09, che e' proprio
il suo compito.

## Stato alla ripartenza pulita

Dopo `am force-stop` + `am start`, l'app riparte dalla schermata "Il
Risveglio" (landing), con le due scelte "Inizia il rito" / "Faccio gia'
parte del Cerchio". L'account "ProvaFZ" della sessione precedente non risulta
riagganciato automaticamente (la landing non salta a una Home), quindi
l'onboarding NON era stato completato in modo persistito, o l'app non
riconosce sessioni anonime pregresse da questa schermata. Prossimo passo:
ripetere con un metodo di tocco piu' lento e verificato ad ogni fase, con
attese piu' lunghe specialmente sulla fase `resonance`, usando preferibilmente
`uiautomator dump` con retry quando serve e screenshot multipli ravvicinati
per cogliere transizioni lente.
