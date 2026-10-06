# Mappa delle ripetizioni nell'istruzione di base dei tre Maestri

6 ottobre 2026. Lavoro in sola lettura: nessun file del codice è stato toccato.

**Sorgenti lette:** `docs/collaudo/FE/costo/istruzione_prima_del_taglio_{medora,aura,caligo}.txt` (21.192, 20.878 e 21.160 caratteri, contati con Python sul file), `lib/services/ai/maestro_persona.dart`, `lib/core/maestro/voce_del_maestro.dart`, `lib/core/chat/la_risposta_nel_merito.dart`, `lib/core/maestro/consiglio_finale.dart`, `lib/core/responsi/confine_del_responso.dart`, `lib/core/responsi/legge_del_responso.dart` e `lib/core/chat/testo_del_responso.dart`.

**Come sono contati i caratteri:** ogni pezzo citato qui sotto è stato cercato alla lettera nei tre file dell'istruzione con uno script Python. Ognuno compare una volta sola in ciascun file in cui è indicato. Il conto comprende lo spazio iniziale o l'a capo finale, quando cadono insieme al pezzo. "Riga N" è la riga del file `istruzione_prima_del_taglio_medora.txt`. Nelle altre due istruzioni le righe sono le stesse, con un solo spostamento: in Calìgo ci sono due righe in più dopo la riga 28 e una in più dopo la riga 34.

**Da sapere prima di toccare qualunque riga:**
- Tutte le frasi qui sotto stanno anche in `functions/src/la_cache_prefissi.json`. Dopo il taglio quel file va rigenerato, altrimenti il prefisso della cache non corrisponde più.
- Dove una prova cita la frase alla lettera, lo trovate scritto nella proposta.

---

## A. Rischio basso

### A1. La regola "prima la tua arte, l'altro Maestro solo in fondo", copia in FONDAMENTO
- **Da togliere (riga 71, l'intera riga):** `- Se una domanda tocca anche il dominio di un altro Maestro, rispondi lo stesso nel merito con la tua arte; solo in fondo, in una frase, puoi indicare per nome il Maestro giusto del cerchio: Medora, Aura o Calìgo, nessun altro.`
- **Nel codice:** `lib/services/ai/maestro_persona.dart:125-126`
- **Dove è già detta:** riga 9, nel blocco IL CERCHIO: "Rispondi sempre nel merito, con la tua arte, a ogni parte della domanda [...] Solo in fondo, in una frase sola, puoi aggiungere come consiglio in più chi dei tre ha quell'arte [...] Quella frase non è mai la prima." (`lib/core/maestro/voce_del_maestro.dart:650-658`). "Nessun altro" è già detto alla riga 8 (`voce_del_maestro.dart:638-640`) e i nomi alla riga 6.
- **Caratteri risparmiati:** 228
- **Vale per:** tutti e tre
- **Rischio: basso.** Il commento sopra la riga (`maestro_persona.dart:121-124`, ordine EQ voce 02) dice testualmente: "La regola intera sta nel blocco del cerchio, `VoceDelMaestro.ilCerchio`". Questa riga è il residuo di una stesura precedente. Nessuna prova la cita.

### A2. La stessa regola, coda di "CIÒ CHE NON DICI MAI"
- **Da togliere (fine della riga 25):** ` Se la domanda cade lì, rispondi con la tua arte e solo in fondo, in una frase, indica il Maestro giusto chiamandolo per nome.`. Resta: "- Le arti degli altri due Maestri del cerchio: [...]. Non le usi mai."
- **Nel codice:** `lib/services/ai/maestro_persona.dart:229-231`
- **Dove è già detta:** riga 9 (`voce_del_maestro.dart:650-658`) e riga 71 (A1).
- **Caratteri risparmiati:** 126
- **Vale per:** tutti e tre
- **Rischio: basso.** È la terza copia della regola, scritta prima del blocco del cerchio dell'ordine EQ, e nessun commento la dichiara voluta. Nessuna prova la cita.

### A3. La stessa regola, terza copia in "RISPONDI SEMPRE NEL MERITO"
- **Da togliere (riga 91, l'intera riga):** `- Anche quando una parte della domanda sta lontano dalla tua arte, rispondile con ciò che la tua arte sa dire. Non cominciare mai dicendo che cosa non puoi fare, che non è la tua arte o chi altro se ne occupa: se serve, dillo in UNA frase sola, in fondo.`
- **Nel codice:** `lib/core/chat/la_risposta_nel_merito.dart:73`
- **Dove è già detta:**
  - riga 9, "a ogni parte della domanda, anche quando una parte tocca l'arte di un altro [...] Quella frase non è mai la prima." (`voce_del_maestro.dart:650-658`);
  - riga 72, "Non dire mai che tutta la domanda esula dal tuo dominio quando una parte è tua." (`maestro_persona.dart:137-138`);
  - in fondo, nel controllo finale (riga 145): "La tua prima frase risponde? Non dice che cosa non puoi fare né chi altro se ne occupa?" (`la_risposta_nel_merito.dart:52`).
- **Caratteri risparmiati:** 255
- **Vale per:** tutti e tre
- **Rischio: basso.** Il commento del controllo finale (`la_risposta_nel_merito.dart:33-40`) dice che le regole scritte nel corpo erano ignorate e che funzionano ripetute per ultime. La copia che conta, quella in fondo, resta. Nessuna prova la cita.

### A4. Ciò che Medora non dice e che il CONFINE dice già
- **Da togliere (righe 27 e 28):** `- previsioni su morte o malattia.` e `- diagnosi mediche, consigli legali o finanziari.`
- **Nel codice:** `lib/core/maestro/voce_del_maestro.dart:317-318` (elenco `maiDice` di Medora)
- **Dove è già detta:** nel CONFINE (righe 66 e 67): "Non dare indicazioni mediche, legali o finanziarie." e "Non parlare di malattia, morte, gravidanza, denaro altrui o esiti giudiziari come previsioni." (`lib/core/responsi/confine_del_responso.dart:57-58`, letto da `:196-198`).
- **Caratteri risparmiati:** 84
- **Vale per:** solo Medora. Quelli di Aura e di Calìgo contengono parti che non stanno altrove (il linguaggio da guru, la frequenza come farmaco, i riti riformulati come crescita, le entità avverse), quindi restano.
- **Rischio: basso.** La terza voce, "la data di un evento futuro come se fosse certa" (riga 26), ripete anch'essa il confine ("Non annunciare un evento futuro come certo"), ma deve restare. `test/i_tre_maestri_sono_tre_test.dart:56` pretende che `maiDice` non sia vuoto, e con quella riga l'elenco di Medora resta pieno.

### A5. "La chiusura non è facoltativa"
- **Da togliere (riga 35, l'intera riga):** `- La chiusura non è facoltativa: ogni risposta la porta.`
- **Nel codice:** `lib/services/ai/maestro_persona.dart:251`
- **Dove è già detta:** nel titolo del blocco alla riga 114, "IL CONSIGLIO FINALE, SEMPRE, IN OGNI RISPOSTA:" (`lib/core/maestro/consiglio_finale.dart:149`).
- **Caratteri risparmiati:** 57
- **Vale per:** tutti e tre
- **Rischio: basso.** La riga dice "ogni risposta", e così contraddice due eccezioni:
  - riga 120, il saluto e il "chi sei" (`consiglio_finale.dart:183-185`);
  - riga 10, "chi sono gli altri Maestri", che non apre nessuna lettura.

  Nessun commento la dichiara voluta e nessuna prova la cita.

### A6. "Le prime due frasi rispondono", ridetta in "COME NON APRI MAI"
- **Da togliere (all'inizio della riga 40):** `Le tue prime due frasi rispondono alla domanda: che cosa fare e poi come o quando. Il cielo o il simbolo vengono dopo, a dire perché. `. La riga diventa: "- Mai aprire dall'emozione della persona rispecchiata a parole."
- **Nel codice:** `lib/services/ai/maestro_persona.dart:302-304`
- **Dove è già detta:**
  - sette righe sopra, nella riga 33, l'apertura di ciascun Maestro: "Le prime due frasi rispondono alla domanda: la prima dice che cosa fare, la seconda come o quando [...] Il cielo viene dopo, a dire perché." (`voce_del_maestro.dart:345-352` Medora, `:441-446` Aura, `:522-524` Calìgo);
  - di nuovo alla riga 111 (`maestro_persona.dart:933-935`).
- **Caratteri risparmiati:** 134
- **Vale per:** tutti e tre
- **Rischio: basso.** Il commento (`maestro_persona.dart:292-301`, ordini EJ.06 ed EK.02) racconta che questa riga una volta contraddiceva l'apertura e vinceva, e che è stata riallineata. Non dice che la ripetizione serve. Per Aura e Calìgo la versione generica ("il cielo o il simbolo") dice anche meno della loro apertura, che parla del respiro e dell'immagine. Nessuna prova la cita.

### A7. "Niente frasi per chiunque", in coda alla regola sulla salute
- **Da togliere (fine della riga 87):** ` Niente premesse, niente frasi di comprensione, niente frasi che andrebbero bene per chiunque: chi ti scrive vuole una risposta, non un giro di parole in cui alla fine non viene detto nulla.`. Resta "Con parole semplici, come la direbbe una persona esperta e franca."
- **Nel codice:** `lib/core/chat/la_risposta_nel_merito.dart:69`
- **Dove è già detta:**
  - le frasi di comprensione stanno nell'elenco "COME NON APRI MAI" della riga 39 ("Capisco", "Comprendo", "È normale sentirsi"...; `voce_del_maestro.dart:170-189`, scritto da `maestro_persona.dart:288-291`);
  - le premesse: "non un'introduzione" alla riga 111 e "non è mai una presentazione" alla riga 85;
  - "sono frasi che andrebbero bene per chiunque" alla riga 89 (`la_risposta_nel_merito.dart:71`);
  - "Ogni tua frase vale per lei sola?" nel controllo finale, riga 147 (`la_risposta_nel_merito.dart:54`).
- **Caratteri risparmiati:** 190
- **Vale per:** tutti e tre
- **Rischio: basso.** È una coda generica attaccata alla regola sulla salute, e la stessa idea è detta altre quattro volte, una delle quali nel controllo finale. Nessuna prova la cita.

### A8. Due code doppie nel blocco "RISPONDI SEMPRE NEL MERITO"
- **a) Da togliere (riga 79):** `; rimandare a un'altra parte dell'app non lo è`. Resta "Chiedere è una risposta."
  - **Nel codice:** `la_risposta_nel_merito.dart:61`
  - **Dove è già detta:** riga 77, "Non proporre mai di aprire una funzione dell'app al posto della risposta" (`:59`).
  - **Caratteri risparmiati:** 46
- **b) Da togliere (riga 80):** `: una persona che non ha capito dice che non ha capito`. La riga finisce con "che non ti servono."
  - **Nel codice:** `la_risposta_nel_merito.dart:62`
  - **Dove è già detta:** nella stessa riga, "dillo e chiedi che cosa intende"; e alla riga 81, "Dici che non hai capito e chiedi, in due righe" (`:63`).
  - **Caratteri risparmiati:** 54
- **Vale per:** tutti e tre
- **Rischio: basso.** La regola resta intera nella stessa riga o in quella accanto. Nessuna prova le cita.

### A9. "Niente riga con ✦" nella risposta su chi sono i Maestri
- **Da togliere (riga 10):** ` e niente riga con ✦`. Resta "niente runa, niente carta, niente gesto."
- **Nel codice:** `lib/core/maestro/voce_del_maestro.dart:662-663`
- **Dove è già detta:** riga 120, "quando la persona ti saluta o ti chiede soltanto [...] chi sono gli altri Maestri, non c'è un passo da dare e questa riga non si scrive." (`consiglio_finale.dart:183-185`)
- **Caratteri risparmiati:** 20
- **Vale per:** tutti e tre
- **Rischio: basso.** L'eccezione della riga 120 nomina proprio questo caso, ed è scritta accanto alla regola del ✦ (ordine EN voce 07, come la riga 10).

### A10. "Il livello visivo lo cura l'app"
- **Da accorciare (riga 48):** `Il livello visivo lo cura l'app: tu scrivi solo la voce, senza emoji.` diventa `Niente emoji.`
- **Nel codice:** `lib/services/ai/maestro_persona.dart:70-71`
- **Dove è già detta:**
  - riga 56, "Il primo strato, il segno grafico, lo dà l'app: tu non descriverlo." (`maestro_persona.dart:79-80`);
  - righe 106-108, il vincolo di formato, "L'app mostra il tuo testo come prosa semplice [...] li mette in risalto l'app da sola" (`lib/core/chat/testo_del_responso.dart:43-49`).
- **Caratteri risparmiati:** 56
- **Vale per:** tutti e tre
- **Rischio: basso.** L'unico dato nuovo della riga, il divieto delle emoji, resta. Il commento sopra la riga (`:62-69`) parla del Markdown tolto da qui, non di questa frase. Nessuna prova la cita.

**Totale a rischio basso:** 1.166 caratteri per ciascuno dei tre Maestri, e 1.250 per Medora (più gli 84 della A4). Sono circa 290-310 token.

---

## B. Rischio medio

### B1. La coda del divieto delle parole degli altri, in testa
- **Da togliere (fine della riga 22):** ` Se una di queste ti viene, anche in un inciso o in una metafora, riscrivi la frase con una parola tua: chi legge deve riconoscere te.`. Resta "Sono le firme degli altri due."
- **Nel codice:** `lib/services/ai/maestro_persona.dart:222-225`
- **Dove è già detta:** riga 140, "ULTIMO CONTROLLO DELLE PAROLE: [...] Se ne hai scritta una, cambiala con una parola tua: al posto di [...]" (`maestro_persona.dart:615-623`).
- **Caratteri risparmiati:** 134
- **Vale per:** tutti e tre
- **Rischio: medio.** La ripetizione in fondo è dichiarata voluta (`:606-613`, ordine EX voce 07: il divieto in testa sta "a ventimila caratteri dalla fine"), quindi si toglie la copia in testa, non quella in fondo. Su queste parole però si regge l'attribuzione cieca, e "anche in un inciso o in una metafora" è un dettaglio che in fondo non c'è. Va rimisurata l'attribuzione.

### B2. "COME SI APRE LA RISPOSTA", la prima regola
- **Da togliere (riga 111):** `- Le prime due o tre frasi devono reggere da sole: chi legge solo quelle deve avere una risposta intera, non un'introduzione.`
- **Nel codice:** `lib/services/ai/maestro_persona.dart:933-935` (`regolaDeiDueStrati`)
- **Dove è già detta:** la riga 33, l'apertura di ciascun Maestro (`voce_del_maestro.dart:345`, `:441`, `:522`), e la riga 40 (A6).
- **Caratteri risparmiati:** 126
- **Vale per:** tutti e tre
- **Rischio: medio.** Tre motivi:
  - `test/vai_piu_a_fondo_test.dart:95` cita "reggere da sole";
  - due commenti la usano come regola di riferimento (`voce_del_maestro.dart:324-327` e `maestro_persona.dart:296-301`);
  - la stessa costante va anche nell'istruzione della correzione (`maestro_persona.dart:698`), dove l'apertura per Maestro c'è comunque.

  Se si fa la A6, questa si può lasciare.

### B3. "Non chiederle di rifarlo", nel consiglio finale
- **Da togliere (riga 118):** `- Se la persona ti dice che ha appena fatto un passo, non chiederle di rifarlo: il passo nuovo comincia da ciò che ha fatto.`
- **Nel codice:** `lib/core/maestro/consiglio_finale.dart:172-173`
- **Dove è già detta:**
  - riga 89, "Se ha appena fatto il passo che le avevi indicato, dille che cosa farne adesso." (`la_risposta_nel_merito.dart:71`);
  - nel controllo finale, riga 146 (`:53`).
- **Caratteri risparmiati:** 125
- **Vale per:** tutti e tre
- **Rischio: medio.** Il commento (`consiglio_finale.dart:169-171`, ordine EQ voce 01) registra il difetto vero da cui nasce: Calìgo che chiede di riscrivere. La riga sta accanto alla regola del ✦, ed è proprio la posizione che la memoria del progetto indica come quella che funziona ("l'istruzione in conflitto vince solo accanto alla regola").

### B4. "Non X, ma Y"
- **Da togliere (fine della riga 84):** ` Non mettere una massima al posto della posizione: una frase costruita come "Non X, ma Y" non è una posizione.`
- **Nel codice:** `lib/core/chat/la_risposta_nel_merito.dart:66`
- **Dove è già detta:** riga 88, "Una massima non è una risposta. [...]" (`:70`).
- **Caratteri risparmiati:** 110
- **Vale per:** tutti e tre
- **Rischio: medio.** La forma "Non X, ma Y" è un dettaglio che la riga 88 non dice, e `test/la_posizione_e_una_lettura_test.dart` la cita alla lettera.

### B5. "Sì, no o a quali condizioni" nel corpo
- **Da togliere (riga 93, prima frase):** `Se ti chiede se una cosa accadrà o se farla, la tua prima frase risponde sì, no o a quali condizioni, secondo la tua arte. `. Resta "Se ti chiede quale, la tua prima frase lo nomina."
- **Nel codice:** `lib/core/chat/la_risposta_nel_merito.dart:75`
- **Dove è già detta:**
  - riga 144, nel controllo finale: "Se ti chiede se una cosa accadrà o se farla, la tua prima frase dice sì, no o a quali condizioni?" (`:51`);
  - riga 84, "LA TUA POSIZIONE [...] se una cosa accadrà [...] la tua prima frase prende comunque posizione" (`:66`).
- **Caratteri risparmiati:** 123
- **Vale per:** tutti e tre
- **Rischio: medio.** Il commento del controllo finale (`:33-40`) dice che corpo e fondo vanno in coppia, e che il corpo da solo veniva ignorato. Che il fondo da solo basti non è stato misurato.

### B6. "NON inventare un dato", nell'ancoraggio a profilo vuoto
- **Da togliere (riga 129):** `- NON inventare un dato per riempire il vuoto. Nessun segno immaginato, nessuna posizione supposta.`
- **Nel codice:** `lib/services/ai/maestro_persona.dart:967-968`
- **Dove è già detta:** riga 137-138, nella REGOLA DELLA MEMORIA: "Non inventare nomi, segni, fatti o ricordi. Se un dato manca, [...] non riempirlo a caso." (`maestro_persona.dart:322-323`)
- **Caratteri risparmiati:** 100, ma solo per chi non ha dati di nascita. La riga non fa parte della parte comune che sta in cache.
- **Vale per:** tutti e tre
- **Rischio: medio.** Nel caso del profilo vuoto, inventare il segno è il difetto più grave. Il titolo del blocco dice "REGOLA CHE VIENE PRIMA DEL TONO".

### B7. La spiegazione del "non hai capito"
- **Da togliere (fine della riga 81):** ` Trovare un significato dove non ce n'è è il modo peggiore di rispettare la persona, perché le fai pagare una risposta che non le serve.`
- **Nel codice:** `lib/core/chat/la_risposta_nel_merito.dart:63`
- **Dove è già detta:** nella stessa riga, "nessun significato tirato fuori da quello che hai letto. Una sequenza di lettere senza senso [...] non è materia da interpretare".
- **Caratteri risparmiati:** 136
- **Vale per:** tutti e tre
- **Rischio: medio.** La frase non aggiunge una regola, aggiunge il perché, e una motivazione a volte regge il comportamento più del divieto.

### B8. "Non ripetere una frase già detta"
- **Da togliere (riga 96):** `- Non ripetere una frase che hai già detto in questa conversazione. Se la persona torna sullo stesso punto, portaci un passo in più.`
- **Nel codice:** `lib/core/chat/la_risposta_nel_merito.dart:78`
- **Dove è già detta:**
  - riga 97, "rispondi di nuovo alla sua domanda di prima, con parole nuove e un passo in più" (`:79`);
  - riga 117, per la riga con ✦ (`consiglio_finale.dart:166-168`);
  - riga 112, "senza ripetere con altre parole ciò che hai appena detto" (`maestro_persona.dart:936-938`).
- **Caratteri risparmiati:** 133
- **Vale per:** tutti e tre
- **Rischio: medio.** Le altre copie coprono casi più stretti: il "riprova", il ✦ e la stessa risposta. Il blocco della risposta ripetuta (`maestro_persona.dart:743-748`) arriva solo dopo che la rete ha già scartato una risposta.

### B9. "Il futuro non è mai un fatto"
- **Da togliere (dentro la riga 84):** ` Il futuro non è mai un fatto: non "avrai", "riuscirai", "arriverà", "andrà bene", "sarà premiato"; scrivi "tende a", "può", "la tua arte lo legge".`
- **Nel codice:** `lib/core/chat/la_risposta_nel_merito.dart:66`
- **Dove è già detta:**
  - nella stessa riga, "Non dirla mai come un fatto certo ("ti ama", "ti tradisce", "tornerà", "avrai la promozione")";
  - nel CONFINE, riga 65, "Non annunciare un evento futuro come certo." (`confine_del_responso.dart:56`);
  - per Medora anche la riga 26.
- **Caratteri risparmiati:** 148
- **Vale per:** tutti e tre
- **Rischio: medio.** Il pezzo viene dal commit `a2d93205` (ordini ET.01 ed ET.03), misurato come pacchetto: alla cieca, prime frasi dirette da 79 a 256 su 360. Il pezzo da solo non è stato misurato, e i verbi elencati sono le parole che la rete delle certezze cerca.

### B10. "La sua volontà è sua", nella riga 86
- **Da togliere (riga 86):** `- Se la domanda tocca la volontà di un'altra persona (se tornerà, se ti scriverà, se ti sceglierà), prima dici la tua lettura, poi, se serve, che la sua volontà è sua.`
- **Nel codice:** `lib/core/chat/la_risposta_nel_merito.dart:68`
- **Dove è già detta:**
  - riga 84, "Quando la domanda riguarda ciò che nessuno può sapere (che cosa prova, pensa o farà un'altra persona [...]) la tua prima frase prende comunque posizione" (`:66`);
  - "la sua volontà è sua" nel CONFINE, riga 68 (`confine_del_responso.dart:66-67`), e alla riga 74 (`maestro_persona.dart:147-148`).
- **Caratteri risparmiati:** 168
- **Vale per:** tutti e tre
- **Rischio: medio.** Il caso del ritorno di qualcuno è quello che ha prodotto i difetti più seri: la lettera inviata con la Luna calante (ordine EN voce 08). Senza questa riga non è più scritto da nessuna parte che prima si dà la lettura e poi la volontà.

**Totale a rischio medio:** 1.303 caratteri, e la B6 conta solo quando il profilo è vuoto.

---

## C. Ripetizioni che restano, perché un commento le dichiara volute

- **PRIMA DI SCRIVERE, CONTROLLA** (righe 142-147, `la_risposta_nel_merito.dart:49-54`). Il commento alle righe 33-48 dice che le regole sono ripetute per ultime perché nel corpo venivano ignorate. Lo stesso vale per la riga 92 ("UNA DOMANDA CON PIÙ PARTI") e la riga 143 che la ripete: resta la coppia.
- **ULTIMO CONTROLLO DELLE PAROLE** (riga 140, `maestro_persona.dart:606-623`, ordine EX voce 07). Al banco, dieci risposte su trenta venivano rifatte per il lessico.
- **CONFINE e LEGGE DEL RESPONSO** (righe 50-53 e 64-69). Sono in un punto solo per scelta (`maestro_persona.dart:101-112`, `legge_del_responso.dart:47-51`), e una prova pretende che il confine compaia una volta. Le copie da togliere sono quelle fuori dal confine (A4, B9), non il confine.
- **Riga 74, chi chiede di far tornare qualcuno** (`maestro_persona.dart:141-148`, ordine EN voce 08): "Il divieto da solo non diceva che cosa rispondere al suo posto".
- **Riga 59, "Infine la TUA chiusura"** (`maestro_persona.dart:83-94`). Qui c'era una chiusura generica, e con lei Medora era scesa al 70 per cento di attribuzione.
- **Riga 36, la parola nella chiusura** (`maestro_persona.dart:252-273`, ordini EK.02 ed ES.18), e il vincolo sulla chiusura di Calìgo (`:242-249`).
- **Riga 33, gli esempi negativi dell'apertura di Medora** (`voce_del_maestro.dart:320-344`). Sono i soli esempi rimasti dopo due ordini che hanno tolto quelli da imitare.

## D. Ciò che non è una ripetizione ma va guardato

- **Le frasi di Aura.** La regola comune alla riga 47 dice "frasi brevi", mentre il registro di Aura (riga 13 della sua istruzione) dice "Frasi lunghe e morbide". Non è una ripetizione, è un conflitto, e nessun commento lo spiega.

## Totali

| | Medora | Aura | Calìgo |
|---|---|---|---|
| Rischio basso (A1-A10) | **1.250** | **1.166** | **1.166** |
| Rischio medio (B1-B10) | 1.303 | 1.303 | 1.303 |
| Tutto | 2.553 | 2.469 | 2.469 |

**Totale a rischio basso: 1.166 caratteri per Aura e per Calìgo, 1.250 per Medora** (circa 300 token).

Anche togliendo tutto, i soli testi ripetuti arrivano a circa 2.500 caratteri, non ai 3.600 richiesti. Per arrivare a 3.600 bisognerebbe toccare le ripetizioni dichiarate volute della parte C, oppure regole che compaiono una volta sola.
