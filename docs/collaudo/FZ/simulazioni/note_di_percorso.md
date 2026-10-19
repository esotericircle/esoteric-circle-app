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

## AGGIORNAMENTO 19 ottobre, sessione ripresa dopo il blocco del device

Il Realme e' tornato raggiungibile il 19 ottobre (richiesta PIN della SIM2
dopo il riavvio di ieri, gestita dal fondatore di persona, non da me). Account
"ProvaFZ2" risultava gia' dentro il Cerchio con l'onboarding completato: la
confusione di ieri sera (fase "custodia" raggiunta poi tornata a "chart")
era quindi un sintomo dello stesso difetto sui tocchi, non una perdita di
progresso reale.

**Il difetto si conferma su una TERZA schermata, diversa dalle prime due**:
il pulsante "Scendi" del Viaggio dello Sciamano (la schermata "Sei qui per
questo" che precede ogni discesa dalla seconda in poi) non ha risposto a
**18 tentativi consecutivi** (tap singoli, tocchi prolungati fino a 8
secondi, tentativi distanziati di 3-5 secondi), verificati uno per uno con
screenshot. La prima discesa (dalla soglia iniziale, "tieni premuto per
scendere") e' riuscita con relativa facilita' (un tentativo da 8 secondi);
sono le discese SUCCESSIVE, dalla schermata "Sei qui per questo" con la
domanda gia' scritta, a restare bloccate.

**Osservazione che rafforza l'ipotesi di ieri**: tutte e tre le schermate
colpite (CieloRealeScreen/"Il tuo Cielo di Nascita", ResonanceScreen/"La
Risonanza", e ora questa schermata del Viaggio) hanno in comune uno SFONDO
ANIMATO CONTINUO (il cielo stellato, le tre aure pulsanti, la galleria di
animali del Mondo di Sotto che scorre dietro il testo). `uiautomator dump`
fallisce sistematicamente su tutte e tre con lo stesso errore ("could not
get idle state"). Le schermate dell'onboarding SENZA sfondo animato continuo
(Angeli, Animale, Carta di Nascita, Chart) non hanno mai mostrato il
sintomo. Questo sposta il sospetto da un difetto specifico di una singola
schermata a un pattern piu' generale legato a QUALUNQUE schermata con
un'animazione di sfondo continua in esecuzione: potrebbe trattarsi di un
problema di contesa del thread di rendering o di una ri-pianificazione
continua dei frame che, in qualche condizione non ancora isolata, impedisce
al motore di gesti di Flutter di riconoscere un tocco (non e' un problema
del dispositivo in generale: nello stesso lasso di tempo `KEYCODE_BACK` e i
pulsanti di altre schermate hanno sempre risposto subito).

## OSSERVAZIONE APERTA, non confermata: il cammino sembra azzerato dopo un riavvio

Dopo i 25+ tentativi falliti sul pulsante "Scendi" della seconda discesa, ho
fatto un riavvio dell'app (force-stop + restart) nella speranza di sbloccare
la situazione, come ieri. Al rientro nel Viaggio dello Sciamano, la soglia
mostra di nuovo "Non si e' ancora mostrato, ne mancano quattro" (0 su 4),
non piu' "ne mancano tre" (1 su 4, confermato due volte prima del riavvio,
dopo la prima discesa completata con successo): il cammino con la domanda
"Devo cambiare lavoro questo anno" non c'e' piu', si riparte dalla scelta
del tema come alla primissima apertura.

**Due spiegazioni possibili, nessuna delle due verificata**:
1. Un difetto reale di persistenza: la scrittura del Diario dopo "Risali"
   e' asincrona (`unawaited`, pattern gia' visto altrove nel codice) e il
   force-stop l'ha interrotta prima che toccasse il disco.
2. Un effetto collaterale del difetto dei tocchi gia' documentato: durante
   i 25+ tentativi sul pulsante "Scendi", il dialogo "Cambia la domanda"
   potrebbe essersi riaperto senza che io me ne accorgessi (e' successo gia'
   una volta in questa sessione, per errore di coordinate), e uno dei tocchi
   "perduti" potrebbe aver colpito "Comincio un altro viaggio" invece di
   "Tengo questa domanda" quando sembrava non fare nulla: quell'azione
   azzera il cammino per sua stessa natura (non e' un errore, e' la
   funzione esatta di quel pulsante), quindi non lascerebbe traccia diversa
   da un vero reset volontario.

Non si puo' distinguere le due ipotesi dagli screenshot raccolti. Da provare
di nuovo con piu' cautela: completare una discesa, chiudere l'app con
`am force-stop` SENZA aver toccato nient'altro nel frattempo, riaprire e
verificare se il cammino resta. Scritto qui per onesta', non come difetto
confermato: **PROVENIENZA IGNOTA se risultasse un difetto reale**, nessuna
voce di FZ ha toccato la persistenza del Diario in modo che possa spiegarlo.

## LA CAUSA TECNICA TROVATA: uso di CPU anomalo e continuo sulle schermate con sfondo animato

Dopo aver escluso un problema di iniezione del tocco a livello di sistema
(verificato con `monkey`, che inietta con un meccanismo diverso da `adb
shell input` e genera comunque nessun effetto su un tocco fuori bersaglio,
e verificato che un RADIO BUTTON qualsiasi della stessa schermata, non solo
il pulsante "Scendi", non risponde piu' a nessun tocco), ho controllato
l'uso di CPU del processo con `top`:

```
21734 u0_a267 ... 76G 549M 239M R  120   7.3  16:15.98 com.esotericircle.esoteric_circle
21734 u0_a267 ... 76G 553M 239M R 81.8   7.4  16:19.09 com.esotericircle.esoteric_circle
21734 u0_a267 ... 76G 553M 239M R  120   7.4  16:22.17 com.esotericircle.esoteric_circle
```

**80-120 per cento di CPU, costante, su una schermata quasi del tutto
ferma** (soltanto lo sfondo con gli animali del Mondo di Sotto che scorre
lentamente dietro il testo). Questo e' il dato che spiega tutto il resto:
- Perche' `uiautomator dump` fallisce sempre su queste schermate ("could
  not get idle state"): il sistema non vede mai un fotogramma fermo.
- Perche' i tocchi a volte "funzionano" dopo molti tentativi: probabilmente
  per puro caso, quando il tocco cade in una delle rare finestre in cui il
  thread che dovrebbe gestirlo non e' occupato a ridisegnare.
- Perche' il problema e' PEGGIORATO fra ieri sera e oggi, sulla STESSA
  sessione dell'app riaperta piu' volte: coerente con un'animazione (o piu'
  di una, accumulate da schermate precedenti mai davvero richiuse) che non
  si ferma mai e consuma sempre piu' risorse piu' l'app resta aperta.

**Non e' piu' un'ipotesi**: e' una misura, presa con `top -n 1 -b`, ripetuta
tre volte a due secondi di distanza, sempre sopra l'80 per cento su un
device a piu' core. Resta da isolare CON IL CODICE quale animazione di
sfondo (del Viaggio, del Cielo Reale, della Risonanza) sia la causa
tecnica precisa: il sospetto piu' concreto, da verificare, e' un
`AnimationController` con `.repeat()` senza `vsync` corretto o senza
fermarsi quando il widget non e' piu' quello attivo, o un `CustomPainter`
che ridisegna ad ogni frame anche quando il contenuto non e' cambiato.

## Un piccolo difetto reale trovato cercando la causa, ma non basta a spiegarla

Cercando nel codice la fonte del consumo di CPU, in
`viaggio_dello_sciamano_screen.dart` il `Timer.periodic` `_respiro`
(`RespiroCheDirada.passo`, 60 millisecondi, righe 600-601) che anima la
nebbia dell'incontro si cancella da solo solo quando la nebbia finisce di
diradarsi naturalmente (riga 787) o quando il widget si smonta (`dispose`,
riga 418): **se la fase cambia per un'altra via mentre la nebbia e' ancora
a meta' (tornando indietro, per esempio), il timer resta attivo**, e la sua
callback (`_unRespiroDiNebbia`, riga 780) continua a essere chiamata circa
16 volte al secondo per sempre, controllando una fase che non torna mai
vera e non facendo altro. E' un difetto reale, va segnalato (PROVENIENZA
IGNOTA, nessuna voce di FZ ha toccato questo file), ma **non spiega la
misura di CPU presa oggi**: la sessione corrente, dal riavvio dell'app,
non e' mai arrivata alla fase "nebbia" (tutti i tentativi si sono fermati
prima, sul pulsante "Scendi"), quindi questo timer non puo' essere mai
partito in questo giro. La vera causa del consumo dell'80-120 per cento
resta da trovare, probabilmente con un profiler vero (Flutter DevTools),
non raggiungibile dalla sola automazione adb di questa sessione.

## Ricerca della causa nel codice, due sospetti esclusi

Cercati tutti gli `AnimationController`/`Ticker` nella cartella
`lib/features/maestri/caligo/viaggio/`. Due widget con animazioni
continue o ripetute, entrambi gia' esclusi perche' rispettano
correttamente `MediaQuery.disableAnimations` (sempre vero sul
767f596c) fermandosi o non disegnando affatto:
- `GirandolaDegliAnimali` (`la_girandola_degli_animali.dart`): il giro di
  sessanta secondi dei dodici totem si ferma con `_giro.stop()` quando
  `disableAnimations` e' vero (riga 64-69).
- `ApparizioneDellAnimale` (`apparizione_dell_animale.dart`): la sagoma
  che attraversa il cielo non si disegna affatto con `disableAnimations`
  (riga 68-70), e comunque userebbe `.forward()` una volta sola, non
  `.repeat()`.

`SfondoDelMondoDiSotto` non ha nessun controller/timer/builder animato:
e' uno sfondo statico. La causa esatta del consumo di CPU non e' stata
isolata nel tempo di questa sessione: resta da cercare con un profiler
vero (Flutter DevTools), non raggiungibile dalla sola automazione adb.
**Confermato che il problema e' riproducibile fin dal primo istante dopo
un riavvio pulito dell'app** (non e' un accumulo progressivo nel tempo):
misura ripetuta a distanza di minuti, sempre fra 80 e 126 per cento di
CPU con l'app in primo piano su questa schermata, contro il 13-19 per
cento con l'app in background.

## Il profilo di allocazione, collegandosi al Dart VM Service

Trovata la porta del VM service (`adb shell cat /proc/net/tcp`, la riga
dell'UID dell'app in stato LISTEN su localhost), fatto `adb forward` e letto
`getAllocationProfile` via HTTP. Numeri che saltano all'occhio sull'isolate
principale:

- **3564 `SemanticsConfiguration`** e altrettanti `_RenderObjectSemantics`,
  **2949 `SingleChildRenderObjectElement`**: cifre enormi per una schermata
  che mostra solo cinque righe radio e un pulsante. Una schermata cosi'
  semplice non dovrebbe avere piu' di qualche centinaio di nodi semantici.
- **91604 istanze di `_OneByteString`** (61 MB) e **274415 di `_List`**
  (16 MB): un tasso di allocazione di stringhe e liste molto alto, coerente
  con rebuild ripetuti che ricreano oggetti invece di riusarli.
- La memoria del processo e' salita da 540 MB (al momento del restart,
  14:39) a **926 MB** quaranta minuti dopo, con l'app rimasta quasi sempre
  sulla stessa schermata: coerente con un accumulo progressivo, non un
  picco isolato.

**Ipotesi piu' sostenuta da questi numeri**: l'albero dei widget non si sta
ripulendo quando si naviga via da una schermata (Home, Calìgo, le varie fasi
del Viaggio attraversate in questa sessione), e resta tutto vivo in memoria,
continuando a essere ricalcolato (layout, semantics, paint) a ogni frame
anche se non visibile: questo spiegherebbe sia il consumo di CPU sia perche'
il problema e' presente fin dal primo istante dopo un riavvio pulito
dell'app (bastano le poche schermate attraversate per arrivare al Viaggio a
costruire un albero gia' troppo pesante). **Non verificato con certezza**:
serve ispezionare l'albero dei widget con Flutter DevTools vero (Widget
Inspector, "Debug Paint", il conteggio dei widget mostrati) per confermare
se ci sono alberi di schermate precedenti ancora montati, cosa che questa
sola lettura del VM service non puo' dire con certezza.

**Isolate doppio, scagionato**: trovati due isolate entrambi chiamati
"main" all'avvio (uno con `livePorts:1`, l'altro con `livePorts:0`); dato
che il progetto usa Firebase Messaging, e' quasi certamente il normale
isolate di servizio per i messaggi in background, non un bug.

## Verifica rigorosa finale: coordinate confermate corrette, difetto confermato reale

Durante i tentativi di oggi ho scoperto un mio errore metodologico: in alcuni
tocchi stimati visivamente dagli screenshot ho dimenticato di applicare il
fattore di scala (le catture arrivano a 900x2000, lo schermo vero e'
1080x2400, fattore 1,2), sbagliando il bersaglio. Corretto l'errore e
rifatta la prova con rigore: domanda scritta di nuovo ("Cosa devo capire
adesso", confermata a video, 23/140 caratteri), pulsante "Scendi" rosso e
attivo, tocco a coordinate ricalcolate con cura (540, 1787, verificate
contro lo screenshot con riga di controllo) e tenuta per 2,5 secondi: **nessun
cambiamento**. Altri due tentativi, stesso risultato. **Il difetto e' quindi
confermato reale, non un artefatto del mio metodo di stima delle
coordinate**: le coordinate erano giuste, il tocco non ha avuto effetto.

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
