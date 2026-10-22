# Le opzioni provate, collaudo delle sei voci dell'ordine GB

Collaudo eseguito sul Realme 767f596c, app in release, account di collaudo (piano Iniziato, 3 domande ai Maestri al giorno, 135 Eos). Data del telefono non spostata. Nessun dato di produzione inserito (nessuna data di nascita, nessun nome o luogo reale diverso da quelli gia' sull'account).

## 1. L'Oroscopo, il filmato della ruota e lo scorrimento (GB.02)

Opzioni previste e provate:

- **Apertura 1, aspettare che il video finisca da solo.** Va bene. Alla prima apertura dell'Oroscopo Universale lo schermo mostra Medora che indica la ruota zodiacale con i segni ancora vuoti (fermo immagine catturato subito dopo il tocco), e in circa due secondi, senza alcun tocco, la schermata si risolve da sola nel contenuto vero (Gemelli, Oroscopo del giorno, 22 ottobre 2026).
- **Apertura 2, toccare per saltare il video.** Non verificabile in modo isolato. Il video dura solo uno o due secondi: un tocco durante quell'intervallo e l'attesa naturale producono lo stesso risultato quasi nello stesso istante, e con gli strumenti adb non sono riuscito a isolare un fotogramma del video abbastanza a lungo da dimostrare che il tocco lo chiude prima del previsto. Nessun blocco o comportamento anomalo osservato.
- **Riapertura nello stesso giorno (uscita e rientro nella funzione).** Va bene. Ho chiuso l'Oroscopo e l'ho riaperto: la schermata e' comparsa gia' ferma e pronta (Gemelli, Oroscopo del giorno), il video non e' ripartito.
- **Scorrimento durante il video su un'altra schermata (Stesa di Tarocchi).** Va bene, con riserva. Ho aperto Stesa di Tarocchi e scorso lo schermo nello stesso istante: e' comparso un fotogramma di transizione (Medora con una posa diversa, nessun pannello di testo ancora caricato) seguito subito dal contenuto completo e corretto ("Scegli la tua stesa"). Non sono riuscito a isolare con certezza se lo scorrimento abbia accelerato la sparizione del video rispetto all'attesa naturale, perche' anche questa transizione dura meno di un secondo. Nessun blocco osservato.
- **Apertura di Oracolo degli Angeli (altra schermata con transizione d'apertura).** Va bene. Contenuto completo caricato correttamente entro due secondi, nessuna anomalia.

## 2. La carta "Hai chiesto a..." nella chat dei Maestri (GB.05)

Rifatto il 22 ottobre 2026 sotto l'eccezione SPESE autorizzata dal fondatore (ordine GB, col si' "ok per eccezione", scritta in `CLAUDE.md` nella sezione SPESE). Opzioni previste e provate:

- **Verifica del borsellino e del contatore all'apertura.** 135 Eos, e il contatore mostra gia' "Non ti resta nessuna domanda ai Maestri, oggi" su Medora, Aura e Calìgo. Il limite condiviso era gia' esaurito dalla sessione precedente dello stesso giorno civile (le tre domande vere di stamattina: Medora 09:01, poi Aura e Calìgo), senza che io spostassi la data del telefono.
- **Ricerca nel Diario Cosmico delle due conversazioni reali di stamattina e riapertura di entrambe.** Trovate e riaperte: Medora 09:01 ("Che energia porta il cielo di oggi per me") e Aura 09:14 ("Cosa dicono i miei chakra oggi"). Il testo generato da Aura cita esplicitamente Medora ("Medora ti invitava a guardare in profondità e io ti accompagno a fare lo stesso con il corpo"), prova indiretta che il contesto incrociato era arrivato al modello al momento della generazione reale. La scheda cliccabile "Hai chiesto a Medora: ... Tocca per leggere i pareri" perо NON compare nello storico riaperto dal Diario: restano solo il testo della domanda e quello della risposta, nessun elemento interattivo di confronto. La scheda sembra un elemento mostrato solo dal vivo al momento dell'invio, non persistito nella trascrizione salvata.
- **Tentativo di generare un nuovo confronto scrivendo una domanda vera e nuova ad Aura** ("Cosa mi serve sapere adesso"), sotto l'eccezione appena concessa, proprio per rivedere la scheda dal vivo. L'invio ha incontrato subito il cancello del limite condiviso (gia' esaurito): nessuna nuova chiamata reale al modello e' partita, quindi nessuna scheda e' comparsa. Zero domande vere nuove effettivamente consumate in questo tentativo.
- **Tentativo di riscattare una domanda in più con gli 80 Eos del conto di collaudo** (valuta virtuale gia' presente sull'account, non denaro reale), per sbloccare la domanda vera necessaria a vedere la scheda dal vivo. L'azione e' stata bloccata dal classificatore di sicurezza della sessione come "transazione del mondo reale", che richiede un permesso esplicito non disponibile in modalita' automatica. Rispettato il blocco: chiuso il dialogo con "Non ora", 135 Eos invariati, nessun addebito, nessuna domanda sbloccata.
- **Esito.** La scheda "Hai chiesto a..." non e' stata rivista dal vivo in questo giro, per la combinazione di limite gia' esaurito e blocco di sicurezza sul riscatto. Resta **APERTA IN ATTESA DI VERIFICA**: serve il reset naturale del limite domani, oppure il si' esplicito di Mauro (con la stima di costo in euro, o l'autorizzazione diretta a spendere Eos) per completare un nuovo consulto dal vivo e catturare la scheda.

## 3. Il messaggio del limite delle domande, con il pulsante (GB.06)

Rifatto il 22 ottobre 2026 sotto la stessa eccezione. Opzioni previste e provate:

- **Verifica del limite gia' esaurito all'apertura** (vedi sopra). Il contatore "Non ti resta nessuna domanda ai Maestri, oggi" e' coerente su tutti e tre i Maestri, confermando che il limite e' condiviso, non per Maestro.
- **Scrittura di un messaggio vero ad Aura** ("Cosa mi serve sapere adesso") a limite gia' esaurito. Il messaggio del limite compare DENTRO la chat come risposta di Aura stessa: "Per oggi ci siamo dette abbastanza: il tuo cammino prevede tre domande al giorno, poi il respiro chiede riposo. Torna domani, il corpo sa aspettare. Se ti serve più spazio, il cerchio può allargarsi." Risposta precostituita e istantanea, nessuna chiamata reale al modello. Sotto, il pulsante "Riscatta una domanda in più · 80 Eos".
- **Tocco del pulsante col prezzo in Eos.** Si apre l'invito "Hai posto le tue domande di oggi" con "Puoi riscattarne una con gli Eos, oppure salire di cammino: le domande ai Maestri diventano 12 al giorno", lo stesso pulsante da 80 Eos, e sotto i due link "Non ora" e "Vedi i piani" (colori distinti: bianco/grigio per "Non ora", oro per "Vedi i piani").
- **Tocco di "Non ora".** Verificato due volte. L'invito si chiude senza addebitare Eos (135 invariati prima e dopo) e senza inviare la domanda.
- **"Vedi i piani".** Presente e distinto, non toccato per non avviare un flusso di acquisto reale, coerente con le istruzioni del compito.
- **Tentativo di completare il riscatto con gli 80 Eos** (per vedere se sbloccava davvero una domanda). Bloccato dal classificatore di sicurezza della sessione come azione reale da non automatizzare senza permesso esplicito. Rispettato, nessun addebito.
- **Stesso messaggio del limite verificato anche aprendo la chat di Calìgo, senza scrivere.** Stessa dicitura "Non ti resta nessuna domanda ai Maestri, oggi", a conferma della coerenza del limite condiviso su tutti e tre i Maestri.

## 4. Il Diario, "Quel giorno" (GB.07)

Rifatto il 22 ottobre 2026, riusando lo stesso consulto vero individuato per GB.05 (nessun consulto a parte necessario, come da compito). Opzioni previste e provate:

- **Apertura del Diario Cosmico (via Cosmic Passport, "I Ricordi del Cerchio") e passaggio alla vista Ricordi.** Va bene, la vista si apre con la griglia dei dodici mesi e il conteggio dei "momenti" per ciascuno; un filtro per Maestro (Medora/Aura/Calìgo) restringe il conteggio.
- **Ricerca testuale della domanda vera fatta a Medora stamattina** (parola "energia", filtro Medora). Trovata la voce "Che energia porta il cielo di oggi per me", 09:01.
- **Apertura della voce.** Si apre la VERA chat di Medora con i messaggi reali di quel giorno (la domanda e la risposta astrologica completa, coerente col tema natale Gemelli/Bilancia/Scorpione), e in fondo compare la striscia "Hai riaperto la conversazione del 22 ottobre 2026", con l'anno.
- **Stessa verifica ripetuta sulla voce di Aura** (parola "chakra", filtro Aura). Trovata "Cosa dicono i miei chakra oggi", 09:14. Apertura: VERA chat con la domanda e la risposta reale, stessa striscia "Hai riaperto la conversazione del 22 ottobre 2026" in fondo.
- **Apertura di una voce di tipo sinastria ("La tua sinastria con Angelina Jolie"), per confronto.** Comportamento diverso dal previsto per questo tipo di voce: si apre una scheda di dettaglio statica con immagine, segno, data con anno (22/10/2026) e testo del responso, non una chat. Questo pero' e' coerente con la natura del contenuto (una lettura, non uno scambio di messaggi), quindi non lo segnalo come difetto di GB.07.
- **Osservazione (vedi anche GB.05).** Nello storico riaperto non compare la scheda interattiva "Hai chiesto a Medora...": solo il testo di domanda e risposta. Non e' un difetto di GB.07, che chiede solo la chat vera e la data, entrambe presenti e corrette.
- **Campo di scrittura ancora attivo nella chat riaperta** ("Scrivi a Medora"/"Scrivi ad Aura"), coerente con l'idea di "riaprire una conversazione" (si potrebbe scrivere di nuovo nello stesso thread), non solo "rivederla" in sola lettura.

## 5. L'Oroscopo, il dominio Fortuna (GB.09)

- **Apertura dell'Oroscopo Universale, tab "Prova" (l'account di collaudo non ha dati di nascita), periodo Giorno.** Nessun testo di dominio (Generale, Amore, Carriera, Fortuna) e' visibile: la schermata mostra solo i selettori di periodo e tradizione e il pulsante "Interroga il cielo", perche' la lettura non e' stata ancora generata per questo account oggi.
- **Toccare "Interroga il cielo" per generare la lettura e vedere la scheda Fortuna.** NON PROVATO. Il tocco avvierebbe una nuova chiamata a pagamento verso Gemini/Vertex per generare il testo delle quattro schede. La regola SPESE di CLAUDE.md vieta qualunque chiamata a pagamento senza il si' esplicito di Mauro, dato in chat per quella singola occasione, con la stima del costo in euro scritta prima; questo si' non e' stato chiesto ne' dato in questa sessione. **Voce NON VERIFICABILE in questa sessione.**
- **Cambiare periodo (Settimana, Mese) o giorno.** Non raggiungibile per lo stesso motivo: Settimana e Mese sono comunque bloccati da lucchetto per questo account (si vede "Settimana 🔒" e "Mese 🔒" nella schermata), quindi non sarebbero comunque stati provabili con questo account anche spendendo.

## 6. Il Calendario degli eventi e il Respiro della Luna, la stessa data (GB.11)

- **Ricerca della schermata "Calendario degli eventi".** Non esiste con questo nome esatto nel menu, ma la stessa funzione si trova in Cosmic Passport (menu Passport) sotto "Prossimi Eventi Cosmici", che apre la schermata "Il cielo che viene". Trovata entro 2 minuti.
- **Lettura della prossima Luna piena.** Va bene: "Luna piena, 26 ottobre" (corretto, non 24 ottobre).
- **Lettura della prossima Luna nuova.** Va bene: "Luna nuova, 9 novembre" (corretto, non 7 novembre).
- **Apertura de "Il Respiro della Luna" e confronto delle stesse date.** La schermata non mostra una data esplicita per gli eventi futuri, solo un conto alla rovescia: "Prossima Luna piena, 3 g 20 h 47 min" e "Prossima Luna nuova, 17 g 23 h 38 min", calcolati da oggi 22 ottobre ore 09:24. Facendo il calcolo a mano: 22 ottobre 09:24 + 3 giorni 20 ore 47 minuti cade il 26 ottobre, e 22 ottobre 09:24 + 17 giorni 23 ore 38 minuti cade il 9 novembre. Le due date COINCIDONO con quelle del Calendario. Il dato e' corretto, ma la presentazione e' diversa (conto alla rovescia invece di una data leggibile): lo segnalo come osservazione di comodita', non come difetto di data.
