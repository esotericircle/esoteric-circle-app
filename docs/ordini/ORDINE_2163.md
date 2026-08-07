# ORDINE 2163. La build di riferimento.

CODE PORTA A TERMINE TUTTO L'ORDINE, OGNI VOCE, FINO ALLA CONSEGNA. Non si ferma a meta', non rimanda voci, non lascia lavoro da ordinare di nuovo. Se il contesto si stringe, comprime i rapporti e non il lavoro. L'unica fermata ammessa e' una premessa falsa.

Ramo canonico `claude/esoteric-circle-master-order-e798aj`. Ultima testa nota `c2ced9cbb9a7529454de0d520a1295f0b70f70b4`, build 2162 consegnata, release `4sg81tbkhsfa8`.

**Cos'e' questo ordine.** Mauro ha guardato la 2162 sul suo Realme e ha mandato tredici screenshot. Questa e' la build che poi diventera' quella iOS, quindi si chiude bene la chat, il Consiglio, il Soffio e l'onboarding, e non si apre nient'altro. Quattro blocchi, dodici voci.

**Tutti i difetti qui sotto sono stati visti sui pixel degli screenshot**, non dedotti dal codice. Dove c'e' scritto "visto" e' un fatto osservato, dove c'e' scritto "ipotesi" va verificato prima di correggere.

## Premesse da abbattere

- **A.** La testa del canonico e' ancora `c2ced9cb`, il contatore di versione a 2162. Se il ramo si e' mosso, dichiara la testa nuova.
- **B.** La prova di accensione dentro `tool/consegna.py` esiste ed e' viva. Se non c'e', fermati: senza quella questa build non si consegna.
- **C.** Il pannello dei suggerimenti a due famiglie esiste gia' e si apre dall'icona a stelline accanto al campo di scrittura. Accerta il widget e il punto in cui riceve il colore.
- **D.** Nell'onboarding, alla schermata dell'animale guida e a quella dei tre angeli, **accerta se il dato che spiega la SCELTA e' disponibile a quella schermata**: quale elemento della carta natale ha eletto quell'animale e quei tre angeli. Rispondi con il nome del campo e la porta da cui arriva. Se la ragione della scelta non e' esposta a quella schermata, dillo, perche' cambia la Voce 11 e la Voce 12.
- **E.** Ne' `CLAUDE.md` ne' gli agenti in `.claude/agents/` vietano quanto ordinato qui.

---

# BLOCCO 1. LA CHAT DEI MAESTRI

## VOCE 1. Il campo di scrittura diventa opaco e smette di galleggiare sul contenuto

**Visto in sei screenshot su tredici**, ed e' il difetto peggiore di tutti: il testo delle bolle e delle frasi si legge ATTRAVERSO il riquadro "Scrivi a Caligo", e anche il pulsante tondo di invio e' semitrasparente col contenuto che ci passa dietro. In una schermata la frase del Maestro entra nel campo e riesce dall'altra parte.

Cosa deve fare: il campo di scrittura e il suo pulsante di invio hanno un fondo **opaco**, oppure un vetro con una sfocatura vera sotto, mai una trasparenza semplice che lascia leggere quello che ci sta dietro. Il contenuto scorre SOTTO e sparisce, non si intravede.

**Prova a guardia:** una prova a pixel rende la chat con una bolla lunga sotto il campo e verifica che dentro il rettangolo del campo non ci siano pixel del testo della bolla. Rosso da eseguire: rimetti la trasparenza e la prova cade col conto dei pixel.

## VOCE 2. Il pannello dei suggerimenti prende il colore del Maestro

**Visto:** nella chat di Medora, che e' blu notte, il pannello si apre **rosso di Caligo**.

Il colore del pannello si deriva dal Maestro della schermata, e si legge da un punto solo. Vale la regola gia' scritta il 5 agosto: il colore si deriva e non si sceglie tre volte, e se il contrasto col testo non basta il colore si scurisce finche' non basta, invece di sceglierne uno a mano.

Nota: il Maestro della schermata si chiede alla ROTTA e non al controller, come gia' imparato spostando la barra.

**Prova a guardia:** una prova enumera i tre Maestri, apre il pannello in ciascuno e verifica che il colore dominante sia quello di quel Maestro. Rosso: fissa il rosso per tutti e tre e la prova cade nominando Medora e Aura.

## VOCE 3. Il pannello mostra le due famiglie insieme, non a linguette

**Visto:** oggi sono due schede alternative, "Domande frequenti" e "Domande personali", e se ne vede una per volta.

Mauro le vuole tutte e due dentro lo stesso riquadro, divise per categoria, senza dover cambiare scheda. Quindi: un solo pannello scorrevole, con l'intestazione "DOMANDE FREQUENTI" e sotto le sue voci, poi l'intestazione "DOMANDE PERSONALI" e sotto le sue. Le intestazioni restano appiccicate in alto mentre si scorre la loro sezione, cosi' si sa sempre in quale categoria si sta.

Il pannello resta sempre raggiungibile dall'icona a stelline accanto al campo di scrittura, in qualunque momento della conversazione, anche a chat piena.

Le domande personali che nascono da un dato che la persona non ha ancora NON compaiono, invece di uscire con un segnaposto.

**Prova a guardia:** una prova apre il pannello e verifica che tutte e due le intestazioni siano presenti nello stesso albero senza toccare nulla; una seconda prova apre il pannello a conversazione avviata e verifica che sia raggiungibile.

## VOCE 4. Via la colonna dei suggerimenti dalla schermata

**Visto:** prima di aprire il pannello, i suggerimenti sono una colonna lunghissima in mezzo alla schermata. Scorrono dietro al campo di scrittura e dietro alla barra, hanno larghezze diverse una dall'altra, e la scritta ESPLORA finisce stampata sopra un suggerimento.

Sono una **seconda porta** per la stessa cosa: se esiste il pannello, quella colonna non deve esistere. Togli la porta, non correggerla.

Al posto suo, all'apertura di una chat vuota, resta il benvenuto del Maestro e l'invito a toccare le stelline. Se serve un assaggio, al massimo tre voci in una riga che scorre in orizzontale, dentro i margini, mai una colonna che occupa la schermata.

**Prova a guardia:** una prova enumera i punti che mostrano suggerimenti e cade se ne esiste piu' di uno oltre al pannello.

## VOCE 5. L'emblema dell'attesa sta dentro la sua scena

**Visto:** la volpe da Caligo e i Gemelli da Medora sono grandi mezzo schermo e passano SOPRA le bolle e sopra le carte della conversazione. La frase "Sto guardando la Luna della tua nascita" cade sopra la bollicina dei tre puntini e sopra il ritratto del Maestro.

Cosa deve fare: la scena di attesa vive in un suo riquadro dichiarato, con l'emblema ridimensionato dentro quel riquadro e la frase sotto di lui, e non si sovrappone a nulla di cio' che sta gia' nella conversazione. La conversazione sotto puo' scorrere, ma la scena non ci passa sopra.

Attenzione a non perdere quello che si e' appena guadagnato con l'ordine 2161: la scena deve restare a video per tutto il minimo garantito, cioe' emblema che si compone in 3 secondi, frasi da 2 secondi l'una, minimo due frasi complete. Quella prova resta viva e non si allenta.

**Prova a guardia:** una prova a pixel verifica che dentro il rettangolo dell'ultima bolla non ci siano pixel dell'emblema dell'attesa. Rosso: rimetti l'emblema fuori dal suo riquadro e la prova cade.

## VOCE 6. La barra dice dove sei, e prende il colore della schermata

**Visto due volte:** nel Consiglio dei Maestri la barra in fondo mostra **Caligo acceso** mentre la schermata e' il Consiglio. E nella chat di Medora, che e' blu, il fondo della barra resta rosso.

Cosa deve fare: la voce accesa e il colore della barra si derivano dalla ROTTA corrente, non da un Maestro scelto in precedenza. Nel Consiglio, che non e' di nessuno dei tre, nessuna voce di Maestro e' accesa e il fondo e' neutro.

**Prova a guardia:** la prova che enumera le cinque schermate esiste gia' dall'ordine 2161: allargala perche' verifichi anche **quale voce e' accesa** e **il colore del fondo**, non solo cosa c'e' sotto la barra. Rosso: accendi Caligo nel Consiglio e la prova cade nominando la schermata.

## VOCE 7. La scritta ESPLORA smette di stampare sopra le carte

**Visto:** la scritta copre la carta "Chiedi anche agli altri", e nel Consiglio copre la riga di chiusura del Maestro.

Il titolo e' una nota di servizio e non deve mai coprire contenuto: o sta dentro la superficie della barra col suo fondo, oppure lo spazio sotto il contenuto cresce di quanto serve. Non un margine indovinato: la misura viene dall'altezza vera del titolo.

**Prova a guardia:** una prova a pixel verifica che nel rettangolo del titolo non ci siano pixel di contenuto sottostante, nelle cinque schermate enumerate.

## VOCE 8. La bolla della persona e il suo ritratto

**Visto:** la bolla di chi scrive e' **verde oliva**, non e' un colore della palette, e resta uguale in tutte le chat mentre quella del Maestro cambia. E l'avatar della persona e' **l'emblema dei Gemelli** dentro un tondo dorato, che si legge come un'icona di sistema invece che come la persona.

Cosa deve fare la bolla: un colore della palette, neutro e coerente, che si distingua dalla bolla del Maestro in tutte e tre le chat senza litigare col colore del Maestro. Il contrasto del testo dentro la bolla si misura, non si giudica a occhio.

Cosa deve fare il ritratto: vale la catena di ripieghi che esiste gia' in `UserAvatar.forUser`, cioe' foto, emblema del segno, iniziali, sigillo neutro. Se oggi salta direttamente all'emblema del segno, verifica perche' la foto e le iniziali non vengono prima. **Ipotesi da verificare prima di correggere:** la persona non ha una foto e le iniziali non vengono provate.

**Prova a guardia:** una prova enumera le tre chat e verifica il colore della bolla della persona e il contrasto del suo testo.

## VOCE 9. Le rifiniture della chat, tutte insieme

Tre cose piccole viste sugli screenshot, e stanno in una voce sola perche' sono lo stesso tipo di lavoro.

**Il testo di benvenuto e' grigio su rosso scuro.** E' la prima cosa che si legge entrando nel dominio ed e' la meno leggibile della schermata. Portalo al contrasto minimo dichiarato, misurato e non stimato.

**Il ritratto tondo del Maestro nell'intestazione si sovrappone alla freccia indietro** e schiaccia il titolo contro il bordo. L'intestazione si ricompone perche' freccia, ritratto e titolo non si tocchino, con le distanze dichiarate.

**Gli spazi morti.** In quattro schermate c'e' mezzo schermo vuoto sotto il campo di scrittura. Accerta da dove viene quel vuoto e toglilo: se e' un'altezza fissa data a qualcosa che non la usa, la si fa scendere sul contenuto.

---

# BLOCCO 2. IL CONSIGLIO DEI MAESTRI

## VOCE 10. L'ordine delle voci, la macchina da scrivere che non riparte, la scheda che si adatta

Tre difetti nella stessa schermata, due dichiarati da Mauro e uno visto sugli screenshot.

**Primo, l'ordine.** Il confronto deve partire dall'alto con il Maestro **da cui si e' aperto il confronto**, cioe' l'ultimo interpellato, e sotto le risposte degli altri due. Oggi l'ordine non e' quello.

**Secondo, e questo e' quello che da' piu' fastidio.** Le risposte compaiono con l'animazione a macchina da scrivere, come concordato. Ma scorrendo in basso per leggere le altre e poi risalendo alla prima, **quella si cancella e riparte da capo**. Una risposta gia' mostrata resta ferma per sempre. Ipotesi da verificare prima di correggere: la scheda viene ricostruita quando esce e rientra nella finestra visibile, e l'animazione riparte perche' il suo stato vive nel widget invece che nel dato. La correzione giusta e' che lo stato "gia' scritta" viva nel dato, non nella scheda: e' la stessa regola di sempre.

**Terzo, visto sugli screenshot.** La scheda e' alta quanto lo schermo anche quando il testo e' corto, quindi resta mezzo schermo vuoto dentro il riquadro; e in un altro screenshot il testo si tronca a meta' parola, "Un rito puo' essere un d". La scheda si adatta al testo che contiene, e il testo non si taglia mai a meta' parola: o entra tutto, oppure c'e' un modo dichiarato per aprirlo.

**Prove a guardia:** una prova scorre fino in fondo e risale, e verifica che il testo della prima scheda sia ancora intero e non ricominci da zero; una prova verifica che la prima scheda sia quella del Maestro di partenza, enumerando i tre casi; una prova a pixel verifica che dentro la scheda non ci sia un'area vuota piu' grande di una soglia dichiarata; una prova verifica che il testo non finisca troncato.

**Rossi da eseguire:** rimetti lo stato dell'animazione dentro la scheda e la prova del ritorno cade; fissa l'ordine su Medora sempre prima e la prova sull'ordine cade partendo da Caligo.

---

# BLOCCO 3. IL SOFFIO DEL DESTINO

## VOCE 11. L'invito a cominciare, e il conto alla rovescia

Oggi, disperso il soffione, compare il riquadro "Preparati a respirare" e a un certo punto il respiro parte da solo. Mauro vuole che parta quando decide lui.

Cosa deve fare, nell'ordine esatto:

1. Sotto "Preparati a respirare" compare un invito a toccare. Il testo lo scegli fra questi due, non altri: **"Tocca per cominciare"** oppure **"Tocca quando sei pronto"**. E' un pulsante vero con area di tocco piena, non una scritta.
2. Al tocco parte un **conto alla rovescia da 3 a 0** al centro dello schermo, numeri grandi che **rimpiccioliscono e svaniscono uno dopo l'altro**, uno al secondo.
3. Finito il conto, comincia il respiro guidato che esiste gia', con "Inspira" ed "Espira" e i numeri veri presi dai tempi del corpus.

Vincoli: niente parte prima del tocco; con Riduci Movimento i numeri appaiono e spariscono senza rimpicciolire, e il conto resta; il conto e' deterministico e non dipende dal caso.

**Prova a guardia:** una prova monta il Soffio, verifica che senza tocco il respiro NON parta neanche dopo un tempo lungo, poi tocca e verifica che il respiro cominci solo dopo il conto, misurando i tempi. Rosso: fai partire il respiro da solo e la prova cade.

**Anteprime:** l'invito sotto "Preparati a respirare", e il conto a "2", tutte e due a 1080x2391 dentro l'app.

---

# BLOCCO 4. L'ONBOARDING

## VOCE 12. Il riquadro dell'animale guida e quello dei tre angeli

Alla comparsa dell'animale guida assegnato resta molto spazio libero sotto. Mauro vuole riempirlo con un riquadro che riassuma le caratteristiche di quell'animale **e perche' e' stato scelto sulla base della carta natale**. Lo stesso riquadro, nella stessa forma, sotto l'assegnazione dei tre angeli.

**Questa voce dipende dalla premessa D**, e va letta insieme a quella.

- Se il dato che spiega la scelta e' disponibile a quella schermata: il riquadro dice le caratteristiche E la ragione vera, nominando l'elemento della carta che ha eletto quell'animale e quei tre angeli.
- Se quel dato NON e' disponibile: il riquadro dice le sole caratteristiche, e la riga della ragione **non compare**, come gia' si fa nel Rito dell'Alba col campo della tradizione. **Non si inventa una ragione plausibile.** Dichiaralo nel rapporto, cosi' diventa una voce da aprire.

Vincoli sul contenuto, e non sono negoziabili: le caratteristiche vengono da una tradizione reale e nominata, mai scritte a mano; niente promesse di guarigione, salute, fertilita', vittoria, ricchezza o protezione, che il filtro rifiuta nel generatore e non nella schermata; cio' che scriviamo noi si dichiara come chiave di lettura del Maestro e non come tradizione.

La forma del riquadro e' la stessa nei due posti, e vive in un componente solo usato due volte, non copiato.

**Prova a guardia:** una prova monta le due schermate e verifica che il riquadro ci sia e che non resti spazio vuoto oltre una soglia dichiarata; una prova cerca le parole vietate e cade se ne trova una; una prova verifica che, tolto il dato della ragione, la riga sparisca invece di mostrare un segnaposto.

**Anteprime:** animale guida col riquadro, e tre angeli col riquadro, a 1080x2391.

---

# Come si lavora

1. Ogni ipotesi si verifica PRIMA di correggere, e l'esito si dichiara anche quando cade.
2. Ogni prova nuova ha il suo ROSSO ESEGUITO DAVVERO. Se il rosso non scatta, non allentare la prova: cambia la grandezza misurata e scrivi nel test perche'.
3. Molti di questi difetti sono di SOVRAPPOSIZIONE, e una prova che conta widget non li prende, perche' i widget ci sono tutti. Si misura a pixel, oppure si misurano i rettangoli sulla resa vera.
4. Su ogni voce, nel messaggio di commit: questa regola dove vive, e quante porte ci arrivano.
5. Si commette a ogni voce chiusa. Durante il lavoro solo le prove dell'area toccata, la suite intera alla fine di ogni voce.
6. `git add -A` non si usa.
7. Anteprime a 360 punti logici, cioe' 1080 pixel, montate come e' montato cio' che provano, con `pump` e non `step`, e `AGGIORNA_ANTEPRIME=1` nell'ambiente. Dopo ogni modifica al punto comune rigenera tutto e leggi il guardiano, riportandone il numero e quante anteprime sono cambiate.
8. **Nessun rapporto nomina un file generato senza averne verificato l'esistenza nel repository dopo il push.**
9. Ogni voce visiva porta la sua coppia prima e dopo in `docs/preview/prima_dopo/`.
10. Lingua: italiano, mai il trattino lungo, mai la virgola prima della "e" o della "ed" congiunzione, accenti veri nei testi a video. La prova sulla lingua ricompone la stringa come la legge la persona.
11. Ogni ripiego dichiara di essere un ripiego. Un campo che aspetta qualcosa non compare: sparisce.
12. Uno sha si cita solo dopo averlo letto dal remoto a push avvenuto. Un esito riportato da un canale che non ha eseguito il comando non e' l'esito del comando.
13. Aggiorna `docs/STATO_VIVO.md` alla fine, nelle sezioni corrette e mai come addendum.

# La consegna

**Questa e' la build di riferimento**, quella da cui nascera' la versione iOS: va guardata con quell'occhio.

Solo dopo che la prova di accensione e' verde. Analyze col conto e quanti nuovi. Suite verde. Commit per percorsi espliciti. Push senza `--force`, locale e remoto che coincidono.

`flutter build apk --release --target-platform android-arm64`, un solo APK arm64, numero di build **2163**, consegna con App Distribution al destinatario unico `cloud@esotericircle.app`.

Dichiara il numero letto con aapt2, la release, il comando esatto, il peso nelle due unita' e la differenza rispetto alla 2162 che pesava 152.565.573 byte. Aggiorna `docs/versione_distribuita.json` dentro la procedura. `kDiagnosiAttiva` resta spento.

# Il rapporto finale

L'esito delle cinque premesse, e per la premessa D la risposta piena, perche' governa la Voce 12.

Per ogni voce: la misura prima e dopo col metodo, il rosso eseguito e cosa ha stampato, la coppia prima e dopo, e la FRASE DI ACCETTAZIONE, cioe' cosa deve vedere Mauro sul telefono.

Riporta il numero dei catch muti, che sta a 71.

Ogni file nominato deve esistere nel repository dopo il push, verificato. Dichiara ogni immagine che non prova niente invece di lasciarla interpretare.
