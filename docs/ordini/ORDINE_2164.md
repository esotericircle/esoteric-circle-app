# ORDINE 2164. Solo pulizia. Mauro ha fretta.

CODE PORTA A TERMINE TUTTO L'ORDINE, OGNI VOCE, FINO ALLA CONSEGNA. Non si ferma a meta', non rimanda voci, non lascia lavoro da ordinare di nuovo. Se il contesto si stringe, comprime i rapporti e non il lavoro. L'unica fermata ammessa e' una premessa falsa.

Ramo canonico `claude/esoteric-circle-master-order-e798aj`. Ultima testa nota `39baa7b5368678f5c2f1f929c72bd274af4900a1`, build 2163 consegnata, release `5v3q3mrklurfg`.

**Cosa e' questo ordine.** Mauro ha guardato la 2163 e ha chiesto SOLO pulizia. Otto voci, nessuna funzione nuova, niente altro. Non aprire nulla che non sia scritto qui.

**Due delle correzioni disfano decisioni dell'ARCHITETTO, non errori di Code.** Sono segnate come tali dentro le voci: non sono regressioni, sono scelte di Mauro che le superano, e vanno scritte accanto al codice perche' nessuno le ribalti domani.

## Premesse da abbattere

- **A.** La testa e' ancora `39baa7b`, il contatore a 2163. Se il ramo si e' mosso, dichiara la testa nuova.
- **B.** Il riquadro della scena di attesa introdotto con l'ordine 2163 voce 5 esiste, con la chiave `riquadro_attesa`, fondo opaco e bordo oro.
- **C.** Il pannello dei suggerimenti oggi e' un solo scorrevole con le intestazioni appiccicate, e il selettore a segmenti e' stato tolto con l'ordine 2163 voce 3.
- **D.** Sul primo schermo della chat convivono TRE porte ai suggerimenti: il pulsante "Tocca per tutte le domande", la riga orizzontale di assaggio, e l'icona a stelline accanto al campo.
- **E.** La superficie della barra e' opaca dall'ordine 2163 voce 7, e la fascia dietro il titolo e' misurata col `TextPainter`.

---

## VOCE 1. Emblema e frasi SENZA riquadro e senza fondo

**Disfa una decisione dell'Architetto, scritta nella voce 5 dell'ordine 2163.** Il riquadro dichiarato con fondo opaco e bordo oro era una decisione mia per fermare le sovrapposizioni, e Mauro lo rifiuta. Non e' una regressione: e' una scelta sua che la supera. Scrivi questa riga accanto al codice.

Visto sullo screenshot: il riquadro copre la bolla della persona sotto, dove si legge "amore?" tagliato a meta'.

Cosa deve fare, e sono le parole di Mauro: **gli emblemi compaiono in alto al centro, dall'alto verso il basso, SENZA SFONDO, ordinati.** Niente riquadro, niente cornice, niente fondo opaco: l'emblema e le frasi si compongono direttamente sopra il cosmo della schermata.

Il problema che il riquadro risolveva resta e va risolto in un altro modo: **la scena non si sovrappone a niente.** La conversazione sotto NON deve passarci dietro. Quindi la scena occupa il suo spazio in cima e il contenuto si ferma sotto di lei, invece di scorrerle sotto. Se serve, la lista perde altezza per il tempo dell'attesa.

Non si tocca nient'altro della scena: i tempi del 4 agosto restano, cioe' emblema che si compone in 3 secondi, frasi da 2 secondi l'una, minimo garantito due frasi complete, e la prova del 2161 sul tempo a video resta viva e verde.

**Prova a guardia:** una prova a pixel verifica che nessun pixel della scena cada dentro il rettangolo dell'ultima bolla, e una seconda verifica che la scena non abbia un fondo opaco proprio, cioe' che dietro l'emblema si veda il cosmo. Rosso: rimetti il riquadro e tutte e due cadono.

## VOCE 2. Il pannello torna ai due titoli selezionabili

**Disfa una decisione dell'Architetto, scritta nella voce 3 dell'ordine 2163.** L'ordine diceva "le due famiglie insieme, non a linguette": era una lettura sbagliata delle parole di Mauro. Lui vuole i due titoli, e nelle build precedenti era cosi'. Scrivi la riga accanto al codice.

Cosa deve fare, esatto: in cima al pannello due titoli affiancati, **DOMANDE FREQUENTI** e **DOMANDE PERSONALI**. All'apertura e' gia' selezionato **DOMANDE FREQUENTI**, con sotto **le dieci domande piu' frequenti**. Toccando **DOMANDE PERSONALI** l'elenco sotto si aggiorna e mostra le personali. Il titolo selezionato si distingue da quello spento in modo evidente.

Il selettore a segmenti che e' stato tolto ieri va rimesso, oppure rifatto: quello che conta e' il comportamento sopra.

Regole che non cambiano: le liste restano dove sono, in `SuggestionSets`, nessun secondo elenco; le personali passano dal filtro del vero, e una domanda che nomina un dato assente non compare; il pannello resta raggiungibile in qualunque momento dall'icona a stelline.

Se le frequenti di un Maestro sono meno di dieci, si mostrano tutte quelle che ci sono e non si riempie con altro.

**Prova a guardia:** una prova apre il pannello nei tre domini, verifica che all'apertura sia selezionato Domande frequenti, tocca Domande personali e verifica che l'elenco sotto CAMBI. Rosso: rimetti il pannello unico scorrevole e la prova cade.

## VOCE 3. Via il pulsante "Tocca per tutte le domande"

E' una ripetizione: la stessa cosa la fa l'icona a stelline accanto al campo. Togli il pulsante, non nasconderlo.

## VOCE 4. Via la riga di bolle orizzontali

L'assaggio di tre domande in riga orizzontale sul primo schermo va tolto. Parole di Mauro: bolle inutili e ripetitive.

Dopo la voce 3 e la voce 4 resta **una porta sola** ai suggerimenti, l'icona a stelline. La prova enumerante che conta le porte va aggiornata: da tre a una, e cade se qualcuno ne riapre una seconda.

Il primo schermo resta col benvenuto del Maestro e basta.

## VOCE 5. Via il fondo nero della riga del campo, e il campo smette di coprire il contenuto

Due cose nella stessa voce, perche' sono lo stesso pezzo di schermo.

**Il fondo.** Sotto e attorno alla riga con stelline, campo e freccia c'e' una fascia scura piena. Va tolta: restano il campo e il tondo di invio, che sono opachi loro e devono restarlo, appoggiati sul cosmo senza nessuna barra dietro.

**La copertura.** Visto sullo screenshot di Caligo: il campo opaco copre la fine della risposta del Maestro e copre le carte "Vai piu' a fondo" e "Chiedi anche agli altri". Prima si leggeva attraverso, adesso non si legge affatto, ed e' peggio.

Cosa deve fare: la lista dei messaggi deve poter scorrere fino a portare **l'ultima riga di contenuto sopra il campo**, cioe' lo spazio in fondo alla lista vale almeno l'altezza del campo piu' la barra. Nessun contenuto deve restare irraggiungibile sotto il campo.

**Prova a guardia:** una prova porta la lista a fondo corsa e verifica che l'ultimo elemento sia interamente visibile sopra il campo, in tutte e tre le chat. Rosso: togli lo spazio in fondo e la prova cade col conto dei punti coperti.

## VOCE 6. Le stelline si abbassano e si allineano al campo

Oggi l'icona a stelline con la scritta "Suggerimenti" sta piu' in alto del campo e la scritta finisce sopra il contenuto.

Cosa deve fare: icona e scritta scendono e si allineano **verticalmente al centro del campo di scrittura**, sulla stessa riga, come la freccia di invio dall'altro lato. La scritta "Suggerimenti" resta sotto l'icona ma dentro la stessa riga, senza sbordare su cio' che sta sopra.

**Misura:** distanza fra il centro verticale dell'icona e il centro verticale del campo, prima e dopo, con la soglia dichiarata.

## VOCE 7. La barra a scomparsa torna trasparente

**Attenzione, e' un compromesso e va scritto nel codice.** La superficie della barra e' stata resa opaca ieri, con la voce 7 dell'ordine 2163, per impedire che la scritta ESPLORA stampasse sopra le carte. Mauro vuole la barra trasparente. Tolto il fondo, quel difetto tornerebbe.

Quindi: la barra torna **trasparente**, con al massimo una sfumatura morbida che nasce dal basso e non un fondo pieno. Il titolo ESPLORA non prende una fascia piena: prende un'**ombra morbida** oppure un contorno appena percepibile, quanto basta a restare leggibile sopra qualunque cosa passi sotto.

La prova della voce 7 di ieri, quella a pixel sul rettangolo del titolo, **va cambiata e non allentata**: non misura piu' che zero pixel cambino, perche' con la trasparenza cambieranno. Misura il **contrasto del titolo** contro cio' che gli passa dietro, nelle quattro schermate, con la soglia dichiarata. Scrivi nel test perche' la grandezza e' cambiata.

## VOCE 8. Il pulsante del Soffio non lo taglia nessuno

Visto sullo screenshot: sotto "Preparati a respirare" il pulsante **"Tocca per cominciare" e' tagliato a meta'** dalla scheda dell'intenzione del giorno che gli sale sopra. Il pulsante che Mauro ha chiesto oggi non si puo' nemmeno premere per intero.

Seconda cosa vista nello stesso scatto: dietro il titolo "Preparati a respirare" c'e' una macchia scura che entra sopra il mandala.

Cosa deve fare: il pulsante e' interamente visibile e interamente toccabile, con la scheda dell'intenzione che gli sta sotto e non sopra; la macchia dietro il titolo sparisce oppure diventa una sfumatura che non tocca il mandala.

**Prova a guardia:** una prova verifica che il rettangolo del pulsante non sia coperto da nessun altro widget e che il tocco al suo centro faccia partire il conto. Rosso: rimetti la scheda sopra e la prova cade.

---

## Come si lavora

1. Nessuna funzione nuova. Solo le otto voci.
2. Molti di questi sono difetti di SOVRAPPOSIZIONE: una prova che conta widget non li prende, perche' i widget ci sono tutti. Si misura a pixel oppure sui rettangoli della resa vera.
3. Ogni prova nuova col suo ROSSO ESEGUITO. Se il rosso non scatta, si cambia la grandezza misurata e si scrive nel test perche'.
4. Le due voci che disfano decisioni dell'Architetto, la 1 e la 2, portano la loro riga accanto al codice: sono scelte di Mauro che superano le mie, non difetti da ricorreggere domani.
5. Si commette a ogni voce chiusa. `git add -A` non si usa.
6. Anteprime a 1080 pixel di larghezza, montate come e' montato cio' che provano, con `pump` e `AGGIORNA_ANTEPRIME=1`. Coppia prima e dopo per ogni voce visiva.
7. Nessun rapporto nomina un file generato senza averne verificato l'esistenza nel repository dopo il push.
8. **Durante il rosso non si usa `git checkout` sui file con modifiche non committate.** E' successo due volte in due ordini, e due volte ha distrutto lavoro. Il rosso si mette e si toglie con un edit mirato.
9. Lingua: italiano, mai il trattino lungo, mai la virgola prima della "e" o della "ed" congiunzione, accenti veri.
10. Uno sha si cita solo dopo averlo letto dal remoto a push avvenuto.
11. Aggiorna `docs/STATO_VIVO.md` alla fine, nelle sezioni corrette e mai come addendum.

## La consegna

La prova di accensione **e' obbligatoria**: la 2163 e' partita al buio per un ordine di Mauro e quella deroga vale solo per quella. Se non c'e' un dispositivo collegato, fermati e dillo.

`flutter build apk --release --target-platform android-arm64`, numero di build **2164**, consegna con App Distribution a `cloud@esotericircle.app`.

**Una misura chiesta apposta, prima di costruire.** Il peso della 2163 e' risultato identico a quello della 2162, zero byte di differenza dopo dodici voci. Puo' essere l'allineamento delle librerie native che assorbe la crescita, ma non e' stato verificato. Confronta **dimensione e sha256 della sola voce `lib/arm64-v8a/libapp.so`** fra l'archivio della 2162 e quello della 2163, e riporta i due valori. Se sono identici, la 2163 non conteneva il lavoro di ieri e va detto subito.

Dichiara il numero letto con aapt2, la release, il comando, il peso nelle due unita' e la differenza dalla 2163, che pesava 152.565.573 byte. Aggiorna `docs/versione_distribuita.json` dentro la procedura. `kDiagnosiAttiva` resta spento.

## Il rapporto finale

L'esito delle cinque premesse. Per ogni voce: la misura prima e dopo, il rosso eseguito e cosa ha stampato, la coppia prima e dopo, e la frase di accettazione. Piu' i due valori di `libapp.so` chiesti sopra.
