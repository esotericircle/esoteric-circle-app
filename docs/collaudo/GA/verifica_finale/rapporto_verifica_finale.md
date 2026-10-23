# Verifica indipendente finale, ordine GA, build di rilascio da HEAD (commit 9a77eca1)

Dispositivo: Realme, serial 767f596c. App verificata: `com.esotericircle.esoteric_circle`, confermata in primo piano con adb prima di ogni tocco (mai un'altra app toccata). Account di collaudo gia' loggato (utente "4").

Nota di metodo importante: all'apertura della verifica, quasi tutte le funzioni che generano testo con i Maestri (Oracolo degli Angeli, Stesa di Tarocchi, Estrazione Rune, chat diretta con un Maestro) risultavano gia' al limite giornaliero gratuito sull'account di collaudo ("Non ti resta nessuna domanda/stesa/gettata, oggi"), molto probabilmente per l'uso fatto in sessioni precedenti dello stesso giorno. Non ho forzato il limite: non ho speso Eos (115 disponibili, mai toccati), non ho cambiato piano, non ho cambiato la data del telefono (il dispositivo non e' rootato: `date: cannot set date: Operation not permitted`, verificato e poi lasciato invariato). Risultato: **0 chiamate a pagamento ai Maestri generate in questa verifica**, ben sotto il tetto di circa 25 concesso. Dove non potevo generare testo nuovo ho verificato comunque la struttura dell'interfaccia e il comportamento del limite stesso (schermata di paywall, non vicolo cieco).

## Esito per voce

**1. Oracolo degli Angeli, domanda di salute.**
Scritta la domanda "Ho mal di testa, cosa significa?" nel campo "Scrivi la tua domanda agli angeli". Alla conferma e' comparsa la schermata "Le consultazioni di oggi sono finite" con invito a riscattare una consultazione (100 Eos) o vedere i piani, mai un vicolo cieco silenzioso. Non ho generato la risposta (limite giornaliero gia' esaurito, nessuna spesa fatta). **Non verificabile nel merito oggi**: non posso confermare se il testo generato rimanda a "parlane col tuo medico" ne la struttura esatta della domanda doppia nella risposta finale. Verificata solo la schermata di invio: campo domanda singolo, non doppio, con chip Amore/Lavoro/Famiglia come scorciatoie. Catture: `vf_38_angeli_question.png`, `vf_42_angeli_submit.png`.

**2. Oracolo degli Angeli, nessuna carta prima della scelta.** Fatto. Aperta la funzione da zero: prima di scrivere o scegliere, in scena c'e' solo Medora con le mani sul tavolo e il pannello "L'angelo di quest'ora", nessuna carta visibile. Cattura: `vf_36_angeli_open.png`.

**3. Tarocchi, mazzo/profondita' bloccati: invito o vicolo cieco.** **Fatto, nessun difetto.** Prima verifica (ora corretta, vedi nota sotto): avevo toccato le opzioni bloccate con coordinate sbagliate (il punto giusto sullo schermo reale, moltiplicato per 1,2 rispetto al pixel letto sulla cattura scalata, non era quello che avevo calcolato), quindi il tocco cadeva altrove e il tendone si chiudeva senza che nulla fosse realmente toccato: sembrava un vicolo cieco silenzioso ma era un errore mio, non dell'app. Ripetuto il tocco con le coordinate corrette, verificate anche con `uiautomator dump`, su tutti e tre i selettori ("Esoterica" in Chiave di lettura, "Quattro Carte" in Tipo di stesa, "Marsiglia" in Mazzo): in tutti e tre i casi compare subito un foglio con titolo, spiegazione del piano richiesto (in un caso anche la fonte: "Arthur Edward Waite, The Pictorial Key to the Tarot, 1911") e i due pulsanti "Non ora" / "Vedi i piani". Nessun vicolo cieco. Catture corrette: `vf_124_after_tap.png` (Mazzo, Marsiglia), `vf_127_quattro_tap2.png` (Tipo di stesa, Quattro Carte), `vf_130_esoterica_tap2.png` (Chiave di lettura, Esoterica).

**4. Tarocchi, stesa breve e responso.** **Non verificabile oggi**: "Non ti resta nessuna stesa, oggi" compare sia per "Tre Carte" sia per "Una Carta" (ho provato entrambe le profondita' nel tipo di stesa). Nessuna generazione possibile senza spendere Eos. Cattura: `vf_50_tarocchi_scroll.png`.

**5. Rune, gettata e schede.** **Non verificabile oggi**: "Non ti resta nessuna gettata di rune, oggi" con pulsante "Getta le rune" bloccato da lucchetto. Cercato uno storico in "I Ricordi" del Diario Cosmico (filtrabile per Caligo): tutti i mesi, incluso ottobre, mostrano 0 voci, quindi nessuna lettura precedente consultabile da li'. Per il merito resta valido solo il dato gia' noto e documentato nel repo (commit dce10bba/10b2bdc4, ordine GA.06): ultima lettura cieca 6 su 12 sulle tre domande dirette, schede con "Cosa fare" legato davvero alla domanda in 14 casi su 35, difetto aperto e gia' segnalato come il piu' pesante dell'ordine. Nessun dato nuovo raccolto oggi su questo punto. Cattura: `vf_24_rune_norne.png`.

**6. Oroscopo, tempo della ruota.** Fatto, con numero. Toccato "Interroga il cielo": subito dopo il tocco e' comparsa la schermata di caricamento "Medora sta cercando il tuo segno fra i dodici..." (cattura a circa 1 secondo dal tocco), il contenuto completo (fasce orarie, sintesi, testo) era gia' presente alla cattura successiva a circa 12 secondi dal tocco. **Tempo misurato: circa 10-12 secondi.** Nessun blocco del tocco osservato (l'interfaccia ha risposto subito al tocco iniziale). Catture: `vf_09_wheel_t0.png` (inizio), `vf_10_wheel_t2.png` (fine).

**7. Cielo Reale, riconoscibilita' della Luna.** Fatto. Aperto "Il Cielo di Adesso" dalla Home e trascinata la vista verso la posizione indicata dalla freccia "La Luna": la Luna appare come un disco con texture lunare realistica e alone luminoso, nettamente piu' grande e distinguibile dei puntini delle stelle circostanti. Riconoscibile a colpo d'occhio. Cattura: `vf_13_cielo_pan.png`.

**8. Chat dei Maestri, nessuna contaminazione fra domande.** Fatto. Aperta la chat di Aura (saluto generico del giorno, nessuna domanda inviata per limite esaurito), poi aperta la chat di Medora: in cima compare solo il saluto proprio di Medora ("Anima del Cerchio, ogni cosa qui ha il suo tempo... Quale scelta ti pesa di piu'?"), nessuna carta "Hai chiesto a [nome]..." che citi Aura o una domanda fatta a un altro Maestro. Catture: `vf_73_aura_chat_scroll.png`, `vf_78_medora_chat_scroll.png`.

**9. Visibilita' dei testi (GA.10).** Fatto, due riscontri. Il corsivo legato al segno accanto ai tre Maestri in Home ("Chi nasce sotto Gemelli cerca quiete." / varianti con "Sotto Gemelli sale una runa di pazienza." / "La giusta ora per chi nasce sotto Gemelli.") si legge bene in bianco su sfondo notturno sfumato, anche con i Maestri vicini. Il pulsante pieno d'oro "Scrivi la tua intenzione" nel Sigillo dell'Intenzione ha testo scuro ben leggibile sul fondo oro/bronzo. Nessun problema di contrasto osservato in nessuno dei due casi. Catture: `vf_00_start.png`, `vf_88_sigillo_page2.png`.

**10. Home, riquadri rotti o vuoti.** Fatto. Nessun tutorial di primo approdo e' comparso (account gia' onboardato). Percorse tutte le sezioni della Home (Doni del giorno, Il cielo sopra di te, i tre Maestri, Conosci te stesso, Il tuo corpo, La tua serenita', La tua energia, La tua intenzione): nessun riquadro vuoto, tagliato o con altezza anomala osservato. Le card Coming soon mostrano regolarmente l'icona clessidra, senza spazi rotti. Catture: `vf_15_home_scroll3.png`, `vf_83_home_sigillo.png`, `vf_86_sigillo2.png`.

## Riepilogo difetti trovati

Nessun difetto nuovo confermato nel codice. La voce 3 era stata segnalata per errore nella prima stesura di questo rapporto (coordinate di tocco sbagliate da parte mia, non un difetto dell'app): corretta sotto, vedi **Correzione del 21 ottobre 2026** in coda a questo rapporto e il testo aggiornato della voce 3 sopra. Tutte le voci verificabili oggi (2, 3, 6, 7, 8, 9, 10) sono a posto.

## Voci non verificabili oggi (limite giornaliero sull'account di collaudo, non per scelta)

- Voce 1 (contenuto della risposta di salute dell'Oracolo degli Angeli)
- Voce 4 (responso di una stesa di Tarocchi)
- Voce 5 (gettata di Rune e schede delle pietre)

Per queste tre, la struttura dell'interfaccia e il comportamento del limite sono stati verificati e sono corretti (schermate di paywall eleganti, mai vicoli ciechi), ma il contenuto testuale generato dai Maestri non ha potuto essere generato ne' ispezionato oggi su questo account. Per le Rune resta valido solo il dato gia' documentato nel repo del giro GA.06 (6/12, difetto aperto sulle schede generiche).

## Chiamate ai Maestri usate in questa verifica

**0** (zero). Ogni tentativo di generazione (Oracolo Angeli, Stesa Tarocchi, Estrazione Rune, chat diretta) e' stato bloccato dal limite giornaliero gratuito dell'account prima di qualunque chiamata a pagamento. Nessuna spesa, nessun Eos consumato.

## Elenco catture (in `docs/collaudo/GA/verifica_finale/`)

- `vf_00_start.png`, `vf_01_medora.png`, `vf_02_medora_tab.png`, `vf_03_dominio_medora.png` — Home e italico leggibile
- `vf_09_wheel_t0.png`, `vf_10_wheel_t2.png` — tempo della ruota Oroscopo
- `vf_13_cielo_pan.png` — Luna riconoscibile nel Cielo Reale
- `vf_24_rune_norne.png` — limite giornaliero Rune
- `vf_36_angeli_open.png` — Oracolo Angeli senza carte prima della scelta
- `vf_38_angeli_question.png`, `vf_42_angeli_submit.png` — domanda di salute e paywall
- `vf_50_tarocchi_scroll.png` — limite giornaliero Tarocchi
- `vf_124_after_tap.png`, `vf_127_quattro_tap2.png`, `vf_130_esoterica_tap2.png` — invito corretto sui tre selettori bloccati (Mazzo, Tipo di stesa, Chiave di lettura), con coordinate di tocco verificate
- `vf_73_aura_chat_scroll.png`, `vf_78_medora_chat_scroll.png` — chat Maestri senza contaminazione
- `vf_83_home_sigillo.png`, `vf_84_sigillo.png`, `vf_86_sigillo2.png` — Home senza riquadri rotti
- `vf_88_sigillo_page2.png` — pulsante pieno d'oro leggibile
- `logcat_marsiglia.txt` — log Android catturato durante il secondo tocco su Marsiglia (nessuna eccezione, l'invito e' comparso regolarmente)

Le catture `vf_56`, `vf_59`, `vf_60`, `vf_64`, `vf_65`, `vf_98`, `vf_99`, `vf_105`, `vf_110` restano nella cartella come prova del tocco con coordinate sbagliate (vedi correzione sotto), non come prova di un difetto dell'app.

(altre catture intermedie di navigazione presenti nella stessa cartella, usate solo per orientarsi)

---

**Correzione del 21 ottobre 2026.** La prima stesura di questo rapporto dichiarava un difetto alla voce 3 (selettori Tarocchi bloccati senza invito all'upgrade). Il coordinatore ha investigato il percorso di codice e non ha trovato nulla di anomalo (una prova mirata sullo stesso percorso mostrava l'invito comparire regolarmente in 600 ms), e ha chiesto una riverifica sul Realme con un'attesa vera di un secondo pieno prima della cattura. Ripetuto il tocco tre volte con un'attesa di 7-8 secondi (ben oltre il secondo richiesto): l'invito non compariva mai, quindi a quel punto il difetto sembrava confermato anche con l'attesa.

A quel punto il coordinatore ha chiesto un pezzo di log Android (logcat) intorno al momento del tocco, per risalire alla causa vera (Regola C). Nel riprodurre il tocco per catturare il log mi sono accorto che le coordinate del tocco su "Marsiglia" nel menu Mazzo erano sbagliate: avevo usato direttamente il valore in pixel letto sulla cattura scalata (900x2000) invece di moltiplicarlo per 1,2 per ottenere il pixel reale del dispositivo (1080x2400), come richiesto dalla nota che accompagna ogni cattura. Il tocco cadeva quindi piu' in alto della voce "Marsiglia", probabilmente su un'area vuota del foglio, e il tendone si chiudeva senza che l'opzione bloccata fosse davvero toccata. Con le coordinate corrette (verificate anche incrociando `uiautomator dump`), ripetute su tutti e tre i selettori, l'invito compare regolarmente ogni volta.

**PROVENIENZA del falso difetto: errore dell'agente di verifica (coordinate di tocco), non un difetto del codice o di una voce d'ordine.** Non e' stato trovato nessuno stack trace o eccezione nel log catturato (`logcat_marsiglia.txt`), coerente col fatto che il ramo di codice giusto veniva eseguito correttamente anche nei tentativi con le coordinate sbagliate: semplicemente non veniva toccato l'elemento voluto.

La voce 3 nella sezione "Esito per voce" sopra e' stata aggiornata con l'esito corretto (fatto, nessun difetto), e il riepilogo dei difetti aggiornato di conseguenza. Nessuna chiamata ai Maestri usata per questa correzione.
