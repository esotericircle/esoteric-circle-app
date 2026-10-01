# RAPPORTO DELL'ORDINE EU

L'Oroscopo dopo il collaudo del fondatore sulla 2289, e i testi
dell'Architetto. Ordine del 1 ottobre 2026 in due pezzi, diciannove voci, piu'
la **EU Aggiunta, i testi dell'Architetto** (dodici corpora nuovi). Ramo
`claude/esoteric-circle-master-order-e798aj`, partenza dal commit `902ef8e5`.
Manifesto `docs/ordini/ORDINE_EU_MANIFESTO.md`, prove in `docs/collaudo/EU/`,
quelle del telefono in `docs/collaudo/EU/realme/`. **Questo ordine non
consegna niente**: le build fatte per il Realme (dai commit `8b9a581a`,
`cd31e52f`, `ece93edc`, `d4ecae35`, `ab7e2cb9` e `d17db7af`) portano il
numero 2289 e non sono consegne.

**Il conto** (manifesto riletto dal file): **16 voci chiuse, 3 aperte in attesa di verifica (EU.03, EU.13, EU.14), 0 da fare.** Le chiuse qui sotto, ognuna con la domanda del fondatore alla lettera, la prova (un file che si apre) e la misura; poi le aperte con cio' che manca e chi lo fa; poi le richieste della sera, con la stessa forma.

## LE VOCI CHIUSE, CON LA LORO PROVA

- **EU.01, breve due paragrafi, lunga due in piu', il cielo solo in "da dove viene"**
  DOMANDA: "QUANTE VOLTE DEVO SCRIVERLO: ALL'UTENTE NON GLIENE FREGA UN CAZZO DEI TRANSITI: VUOLE RISPOSTE O UNA GUIDA. CI SONO APPOSTA DELLE REGOLE PER LE RISPOSTE!"; "In generale per breve sono sufficienti 2 paragrafi e per lunga aggiungere altri 2 paragrafi mai di transiti o tecnicismi perché sotto c'è già sempre "da dove arriva"."; "i testi sono importantissimi e devono seguire le regole per le risposte es evitare ripetizioni".
  PROVA: `docs/collaudo/EU/paragrafi_misura.txt`
  MISURA: paragrafi in Breve, prima 3 o 4 con i transiti dentro, dopo 2 su 864 schede in prova; in Lunga 4; parole del cielo nei paragrafi, dopo 0; cielo detto due volte, dopo 0; sul Realme 2 paragrafi in Breve e 4 in Lunga nelle tre tradizioni (eu01_occidentale_giorno_lunga_1..3.jpg, eu01_vedica_giorno_lunga_1..3.jpg, eu01_cinese_giorno_lunga_1..3.jpg)

- **EU.02, settimana, mese e anno della vedica e della cinese**
  DOMANDA: "manca l'oroscopo settimanale, mensile e annuale per vedica e cinese, attualmente c'è solo quello giornaliero."; domanda girata al fondatore: il metodo dell'Architetto (Settimana e Mese col metodo del Giorno giorno per giorno; Anno Cinese con l'animale dell'anno e il Tai Sui; Anno Vedico coi transiti di Giove e Saturno dalla Luna di nascita e il Sade Sati), risposta: "Proposta Architetto".
  PROVA: `docs/collaudo/EU/vedica_cinese_periodi.txt`
  MISURA: periodi della Vedica e della Cinese, prima 1 su 4 (solo il Giorno), dopo 4 su 4; giorni dei periodi col livello o il titolo diversi dal Giorno della stessa data 0 su 888; anni cinesi con animale, Capodanno o Tai Sui diversi dalla fonte 0 su 10; persone con Giove o Saturno contati diversi dal JPL 0 su 10; "Da dove viene" ripetuto nella Lunga dei periodi vedici e cinesi, dal Realme prima 2 volte, dopo 1

- **EU.04, la testata: "oroscopo del giorno" e la data**
  DOMANDA: "Sotto l'emblema del segno non c'è bisogno di scrivere "personalizzato", è sufficiente "Oroscopo del giorno o settimana o mese o anno" e sotto la data o date corrispondenti, in questo modo guadagniamo una interlinea".
  PROVA: `docs/collaudo/EU/realme/eu04_cinese_anno_testata_dopo.jpg`
  MISURA: parola "Personalizzato" nella testata, prima 1, dopo 0 nei 4 periodi; righe della testata, prima 3 (titolo, Personalizzato, date), dopo 2; testate dell'Anno con le date di un'altra tradizione, dal Realme prima 1 su 3 (Cinese), dopo 0 su 3

- **EU.05, il selettore "oroscopo per"**
  DOMANDA: "voglio un selettore proprio sopra il selettore di giorno, settimana, mese, anno) in cui l'utente può scegliere se vuole consultare l'oroscopo per se stesso o un amico/a. Quindi un testo "oroscopo per" + pulsante [nome utente] predefinito + pulsante [amico/a]. Se fai click su [amico/a] compare la schermata "i tuoi amici". Così scompare il pulsante in alto che è poco visibile."
  PROVA: `docs/collaudo/EU/realme/eu05_oroscopo_di_lucia.jpg`
  MISURA: pulsanti dell'amico nella barra in alto, prima 1, dopo 0; righe "Oroscopo per" sopra i periodi, prima 0, dopo 1 in ognuno dei 4 periodi alle scale 1,0 e 1,3 (8 su 8, docs/collaudo/EU/regola_a_oroscopo_per.txt); tocchi dal telefono per arrivare all'oroscopo dell'amico, 2

- **EU.06, le immagini delle tradizioni in arrivo**
  DOMANDA: "Se seleziono un oroscopo non sbloccato, ad esempio maya, mi compare il mio segno calcolato, ma l'icona in alto che compare non c'entra nulla, code ha rubato l'asset da altre grafiche, se non sbaglio."
  PROVA: `docs/collaudo/EU/immagini_tradizioni.txt`
  MISURA: tradizioni non sbloccate con un'immagine con lo sfondo, prima 4, dopo 0; webp nel ramo uguali a quelli del PC (sha256), 4 su 4; immagini di prima prese da un'altra funzione, 0 su 4

- **EU.07, il piano viandante per le prove**
  DOMANDA: "Per ora è necessario rendere disponibile il cambio di abbonamento in "viandante" per fare le prove."
  PROVA: `docs/collaudo/EU/realme/eu07_viandante_nome_intero.jpg`
  MISURA: piani raggiungibili dal telefono nella demo, prima 3 su 4, dopo 4 su 4; pulsanti del Viandante fuori dalla demo 0; nomi di piano spezzati dentro la parola, dal Realme prima 1, dopo 0 su 4 alle scale 1,0 e 1,3

- **EU.08, un titolo su ogni scheda della settimana**
  DOMANDA: "Nell'oroscopo settimanale occidentale, le risposte vanno bene: breve ok e lunga con i singoli giorni,a ogni scheda dovrebbe avere un titolo come per oroscopo giornaliero."
  PROVA: `docs/collaudo/EU/realme/eu04_eu08_eu09_settimana_barre.jpg`
  MISURA: schede della Settimana col titolo, prima 0 su 4, dopo 4 su 4 a video; righe dei giorni migliori col titolo del Giorno, dopo 3 su 3 per scheda

- **EU.09, le barre della settimana**
  DOMANDA: "le barre di cui una gialla in evidenza sembrano tutte uguali, dovrebbe cambiare anche l'altezza e magari inserire una percentuale, ma cambiano pochissimo. Magari si potrebbero colorare in modo diverso anche da meno intenso a più intenso, da giallo opaco a rosso fuoco per il giorno migliore. Cmq puoi proporre altro di meglio."; domanda girata al fondatore: la proposta dell'Architetto (altezza proporzionale, cinque gradini dal giallo opaco al rosso fuoco, la percentuale sul giorno migliore, il Mese a griglia), risposta: "Altezza e colore (Consigliata)".
  PROVA: `docs/collaudo/EU/livelli_dei_giorni.txt`
  MISURA: domini-settimana coi sette giorni allo stesso livello, prima 4 su 64, dopo 2 su 64 (Venere stazionaria il 3 ottobre, una settimana quieta senza carta); altezze delle barre in proporzione al livello 7 su 7 alle scale 1,0 e 2,0; colori uguali al gradino 7 su 7; contrasto peggiore di un gradino sul fondo 3,22

- **EU.10, il numero fortunato grande e al centro**
  DOMANDA: "Il numero fortunato deve essere grande e al centro del suo riquadro."
  PROVA: `docs/collaudo/EU/realme/eu_sera_numero_e_colore_riempiono.jpg`
  MISURA: altezza della cifra rispetto all'etichetta, prima 1,05 (21 su 20), dopo il richiamo della sera la cifra tocca lo spazio del riquadro in 9 coppie di riquadri su 9 (una cifra, due cifre, i due numeri cinesi, al carattere 1,0 e 1,3); disegno della cifra fuori centro dal centro del riquadro, misurato sui pixel, 1,8 per cento col "6", 1,2 col "7", 1,6 col "22" (prima del margine 3,6); scarto d'altezza fra il riquadro del numero e quello del colore 0,0 punti

- **EU.11, il mese a griglia**
  DOMANDA: "L'oroscopo mensile ha lo stesso problema dell'infografica poco chiara e molto simile tra loro."; domanda girata al fondatore: "Il Mese diventa un calendario a griglia di 5 settimane con le caselle colorate", risposta: "Altezza e colore (Consigliata)".
  PROVA: `docs/collaudo/EU/regola_a_barre_e_griglia.txt`
  MISURA: caselle del Mese, prima 0 (barre), dopo 30 su 30 col colore del loro gradino; caselle senza il numero del giorno, 0 su 30; percentuali sulla migliore 1

- **EU.12, il pdf dell'anno**
  DOMANDA: "Oroscopo annuale va bene, ma il PDF alla fine mostra una ripetizione "del tuo lavoro"."
  PROVA: `docs/collaudo/EU/pdf/da_dove_veniva_la_ripetizione.txt`
  MISURA: titoli ripetuti in fondo in Acrobat Liquida, prima 3, dopo 0; PDF dell'anno su due pagine, prima 12 su 12, dopo 0 su 12; schede spezzate fra due pagine, prima 9 su 12, dopo 0

- **EU.15, la lunga per chi non ha il piano: 50 eos**
  DOMANDA: tabella della voce ES.06, approvata dal fondatore: "Approvo tutto."; domanda girata al fondatore il 30 settembre: "Chi può scegliere la profondità Lunga?", risposta: "Premium più Eos".
  PROVA: `docs/collaudo/EU/realme/eu15_viandante_lunga_aperta_2150_eos.jpg`
  MISURA: strade per la Lunga al Viandante, prima 1 (il piano), dopo 2 (50 Eos o abbonamento); Eos dal Realme, prima 2.200, dopo 2.150; paragrafi dopo l'acquisto, 4 su ognuna delle 4 schede; parole che chi legge non conosce nel foglio ("Lunga", nomi dei piani), prima 2, dopo 0

- **EU.16, la stessa frase in giorno, settimana e mese**
  DOMANDA: dall'Architetto, sulle catture del fondatore; rilievo del fondatore "evitare ripetizioni".
  PROVA: `docs/collaudo/EU/regola_a_frasi_fra_i_periodi.txt`
  MISURA: frasi uguali fra periodi dello stesso giorno, dopo 0 su 306 coppie di periodi (rossa con 1.170 frasi uguali col Mese che prende la voce della Settimana); frasi uguali fra il Giorno e un altro periodo in novanta giorni, 0

- **EU.17, il livello e il testo dicono la stessa cosa**
  DOMANDA: dall'Architetto, sulle catture del fondatore.
  PROVA: `docs/collaudo/EU/livello_e_testo.txt`
  MISURA: schede con un paragrafo di una fascia diversa dal livello, dopo 0 su 1.476; schede del Giorno fuori fascia in novanta giorni, 0 su 12.240

- **EU.18, il titolo anche sulle schede del mese**
  DOMANDA: dall'Architetto, sulle catture del fondatore; estende il rilievo del fondatore della voce EU.08.
  PROVA: `docs/collaudo/EU/realme/eu11_eu18_mese_griglia_1.jpg`
  MISURA: schede del Mese col titolo, prima 0 su 4, dopo 4 su 4 a video

- **EU.19, il nome del segno sotto i contatori**
  DOMANDA: dall'Architetto, sulle catture del fondatore.
  PROVA: `docs/collaudo/EU/regola_a_contatori.txt`
  MISURA: velo della barra, prima 72 per cento, dopo 92; contrasto peggiore dei contatori sul colore piu' chiaro che puo' scorrere sotto, prima 4,6, dopo 9,3 su 24 coppie

## LE VOCI APERTE IN ATTESA DI VERIFICA

- **EU.03, il suono all'invio**: **APERTA IN ATTESA DI VERIFICA**: alla pressione di "Interroga il cielo", "Interroga la Luna" e "Apri l'almanacco" e dell'avvio della stesa non suona piu' niente (`docs/collaudo/EU/suono_invio.txt`), e sul sistema audio del Realme la prima e la seconda tradizione del giorno non hanno tracce al tocco (`docs/collaudo/EU/realme/eu03_suono_invio_realme.txt`). Lo stesso registro ha trovato un suono alla pressione che la voce non aveva visto: la terza tradizione letta nel giorno accende il Sigillo dei Tre Cieli (padre ES.37) e suonava la rivelazione mezzo secondo dopo il tocco. Curato (il Sigillo si accende con la sola vibrazione) e provato rosso e verde in `la_soglia_e_la_rivelazione_dell_oroscopo_test.dart`. **Manca la misura dal telefono del Sigillo curato**: il Sigillo si accende una volta al giorno, e sul Realme si era gia' acceso alle 06:58 del 1 ottobre con la build di prima; il telefono non e' debuggabile e la data del sistema non si cambia. Si chiude con la prima terza tradizione del 2 ottobre sul Realme, col registro di `tool/ascolta_il_realme.py`: nessuna traccia nel primo secondo dopo il tocco.

- **EU.13, la rivelazione del segno**: **APERTA IN ATTESA DI VERIFICA**: prodotta e agganciata (commit `8b9a581a`), la prova `il_segno_si_rivela_la_prima_volta_test.dart` (629) misura la prima apertura delle sei tradizioni (figura quasi trasparente al primo fotogramma, piena dopo 1,7 secondi) e la seconda gia' al suo posto. **Sul Realme l'animazione non si vede**: le tre scale delle animazioni del sistema sono a 0 (impostazione del telefono che non si cambia), Flutter lo legge come Riduci Movimento e la testa compare intera, come la voce vuole per chi ha tolto il movimento (`eu13_vedica_testa_riduci_movimento.jpg`, `eu13_rivelazione_vedica_prima_volta.mp4`, fotogrammi tutti uguali). La vede chi ha le animazioni accese: il fondatore sul suo telefono.

- **EU.14, l'interpretazione vera e non ripetitiva: le prove**: **APERTA IN ATTESA DI VERIFICA**: misurata e scritta, aspetta l'Architetto. Le ripetizioni in novanta giorni sono zero (`docs/collaudo/EU/ripetizioni_90_giorni.txt`: voci del Giorno tornate entro trenta giorni 0, con e senza carta; voci della Settimana, del Mese e dell'Anno 0; frasi uguali fra periodi 0; fasce diverse dal livello 0, su 12.240 schede), il linguaggio di ogni tipologia e' quello dei dodici corpora. **La verita' delle interpretazioni no**: delle 759 affermazioni dei "Da dove viene" e delle note del metodo, 671 hanno una fonte dichiarata e **88 no** (`docs/collaudo/EU/affermazioni.md`, una per una). Si chiude quando l'Architetto le ha verificate o tolte.

## LE RICHIESTE DEL FONDATORE DELLA SERA, CON LA LORO PROVA

Arrivate durante il collaudo, fuori dalle diciannove voci. Ognuna con la
sua domanda alla lettera, la prova che si puo' aprire e la misura. Le
catture sono del Realme con le build di prova dei commit `cd31e52f`,
`ece93edc` e `d4ecae35` (nessuna e' una consegna).

- **Il foglio dell'oroscopo completo: abbonarsi, e gli Eos solo per oggi**
  DOMANDA: "Non chiamarla "la lunga di oggi con l'iniziato", ma "abbonati per avere sempre l'oroscopo completo". L'utente non sa cos'è l'iniziato e "la lunga" ha poco senso, poco comprensibile. Anche il titolo, sistema tutto quel riquadro, bisogna invitare l'utente ad abbonarsi principalmente oppure a spendere eos solo per l'occasione."
  PROVA: `test/la_lunga_si_apre_con_gli_eos_test.dart`; sul Realme l'invito delle altre schede `docs/collaudo/EU/realme/eu_sera_viandante_invito_abbonati.jpg`
  MISURA: parole che chi legge non conosce nel foglio ("Lunga", i nomi dei piani), prima 2, dopo 0; pulsante pieno dell'abbonamento sopra, Eos col bordo sotto; nella pagina dei piani la riga "Profondità dell'oroscopo: Breve o Lunga" diventa "Oroscopo completo: Sempre". Il foglio dell'Occidentale del giorno sul Realme non si apre il 1 ottobre, perche' l'oroscopo completo di oggi e' gia' comprato: e' disegnato dalla prova (stesso foglio, 4 schede).
- **Non vendere "due paragrafi"**
  DOMANDA: "Ma dai, elimina che aggiungiamo 2 paragrafi, ma pensi prima di scrivere? Io penserei: "ma devo spendere soldi per solo 2 paragrafi di merda?". E dai cazzo, impegnati un po'! Rispondi sempre alle domande "quadro è il massimo" e "come posso ottenere di più?" e "cosa penserebbe l'utente" e *come posso aumentare l'esperienza utente?"
  PROVA: `test/la_lunga_si_apre_con_gli_eos_test.dart` e `test/la_profondita_sta_su_ogni_scheda_test.dart`; le parole in `lib/features/horoscope/letture_complete.dart`
  MISURA: scritte del foglio e dell'invito che parlano di paragrafi, prima 1 e 1, dopo 0 e 0; anteprima vera della parte chiusa di oggi, prima 0 caratteri, dopo 195 (l'inizio del terzo paragrafo, che sfuma); prezzo dell'abbonamento detto, prima no, dopo "da 2,99 € a settimana" letto dal listino dei piani.
  Le quattro domande, per questo foglio. *Qual è il massimo?* Far leggere a chi non ha l'abbonamento l'inizio vero di cio' che gli manca, oggi, sulla sua scheda: non una promessa generica. *Come posso ottenere di più?* Dire in una riga che cosa porta l'abbonamento, solo cose vere del piano (l'oroscopo completo ogni giorno, la settimana coi suoi giorni migliori, il cinese e il vedico, i Maestri che ricordano), col prezzo piu' basso. *Cosa penserebbe l'utente?* "Che cosa ci guadagno?": la prima frase risponde ("ti dice perché succede proprio a te e come muoverti, passo per passo"). *Come aumento l'esperienza?* Una sola scelta principale (abbonarsi), la scorciatoia di un giorno sotto, e nessuna parola tecnica.
- **I dodici mesi sull'Anno**
  DOMANDA: "Hai messo infografica anche per oroscopo annuale? Magari per i 12 mesi indicando i migliori o quello che ritieni migliore."
  PROVA: `docs/collaudo/EU/realme/eu_sera_dodici_mesi_cinese.jpg`
  MISURA: barre dei mesi sulle schede dell'Anno, prima 0, dopo 12 per scheda nelle tre tradizioni, col mese migliore detto; 360 schede del Giorno confrontate coi giorni favorevoli dei mesi occidentali, 0 differenze; domini con dodici mesi uguali nella Vedica e nella Cinese, 0 su 6 anni.
- **Il numero e il colore che riempiono il riquadro**
  DOMANDA: "Il colore del giorno e il numero del giorno più grandi in modo da riempire il riquadro e centrati verticalmente e orizzontalmente."
  PROVA: `docs/collaudo/EU/realme/eu_sera_numero_e_colore_riempiono.jpg`
  MISURA: coppie di riquadri in cui la cifra o il colore non riempiono lo spazio, col contenuto centrato e non esteso 6 su 6, dopo 0 su 9; disegno della cifra fuori centro, prima 3,6 per cento, dopo 1,8 ("6"), 1,2 ("7"), 1,6 ("22").
- **"In arrivo" senza la fase**
  DOMANDA: "Per le altre tipologie di oroscopo non sbloccati, ad esempio maya, egizio, ecc, scrivi solo "in arrivo" Senza indicare la fase"
  PROVA: `docs/collaudo/EU/realme/eu_sera_foglio_chiuso_col_dito.jpg`
  MISURA: chip delle tradizioni in arrivo con la fase, prima 4 su 4, dopo 0 su 4.
- **Ogni foglio si chiude**
  DOMANDA: "Quando clicco sul punto di domanda fianco all'emblema del segno, si apre dal basso un pannello bolla informativa, ma poi non posso più chiuderla: inserisci in basso una scritta "fatto" per chiudere oppure utilizzando il gesto del dito dall'alto al basso per chiudere la scheda infirmativa. Controlla che sia così dappertutto"
  PROVA: `docs/collaudo/EU/realme/eu_sera_nota_con_fatto.jpg`
  MISURA: fogli che si leggono soltanto senza "Fatto", dopo 0 su 9 (contati sui 41 punti che aprono un foglio; "Fatto" e' nato in questo ordine, e con la nota tolta la prova misura 1 su 9); il foglio che scorre col dito che scende dalla cima, prima resta aperto, dopo si chiude (anche sul Realme, `eu_sera_foglio_chiuso_col_dito.jpg`).
- **Il nome lungo in testa**
  DOMANDA: "La scritta che ho cerchiato in alto è illeggibile"
  PROVA: `docs/collaudo/EU/realme/eu_sera_foglio_chiuso_col_dito.jpg`
  MISURA: il nome in testa dell'Araba a video alla scala 0,29 prima, 0,92 dopo (il nome prima della virgola, "al-Fargh al-Mu'akhkhar", su due righe).
- **Le ore del giorno sul Giorno**
  DOMANDA: "vorrei infografica a colori anche per oroscopo giornaliero come per settimanale, mensile e annuale, se possibile. Magari inserendo le 24h e indicando le ore migliori oppure una tua idea se migliore e più esplicativa e adatta."
  PROVA: `docs/collaudo/EU/realme/eu_sera_ore_migliori_ancora_da_venire.jpg` (e `eu_sera_ore_cinese.jpg`, `eu_sera_ore_vedica_prima.jpg`)
  MISURA: barre delle ore sulle schede del Giorno, prima 0, dopo 24 nell'Occidentale e nella Vedica (le ore planetarie, con Lilly) e 12 nella Cinese (le ore doppie); ore migliori gia' passate dette, sul Realme alle 10:00 una, dopo 0 in 868 momenti di una settimana; sopra ogni ora migliore un punto d'oro e l'ora di adesso col bordo chiaro e una freccia sotto (punti 2 su 2 ore migliori nella prova, una barra col bordo; sul Realme `eu_sera_ore_sulle_barre.jpg`); nella Vedica la riga dice da che ora a che ora c'e' il Rahu Kalam.
- **Il terzo paragrafo in un riquadro**
  DOMANDA: "Per ogni risposta, quando c'è la profondità lunga il terzo paragrafo inseriscilo in un riquadro, così da sembrare in evidenza e staccare dalla monotonia del testo."
  PROVA: `docs/collaudo/EU/realme/eu_sera_terzo_paragrafo_lunga.jpg`
  MISURA: schede Lunghe col terzo paragrafo nel riquadro, prima 0, dopo 36 su 36 nella prova, anche nell'oroscopo dell'amico.
- **I luoghi del mondo nel foglio dell'amico**
  DOMANDA: "Quando inserisco i dati di un amico nella scheda "aggiungi un amico", il campo di ricerca del luogo di nascita funziona male e non ci sono tutte le città, paesi, villaggi, borgo del mondo. [...] Fai la prova con la città di residenza dei fondatori "Borgo di Rivalta" in provinc5di Piacenza."
  PROVA: `docs/collaudo/EU/realme/eu_sera_amico_borgo_di_rivalta.jpg`
  MISURA: campi del luogo senza la domanda al mondo, prima 1 su 3 (il foglio dell'amico), dopo 0 su 3; "Borgo di Rivalta" trovato nel foglio dell'amico sul Realme, prima no, dopo si' ("Loc. Borgo di Rivalta, Piacenza"). Nessun amico salvato sul telefono.
- **Gli emblemi senza sfondo (EU Aggiunta 2)**: nella voce EU.06 qui sopra.

- **I prezzi in novantanove**
  DOMANDA: "Gli abbonamenti e quindi foni riferimento sono cambiati in 2,99 - 9,99 - 19,99 - 29,99"
  PROVA: `test/entitlement_test.dart` e `test/pricing_test.dart`; i prezzi in `lib/core/entitlement/plan_catalog.dart`
  MISURA: l'Iniziato da 2,90 a 2,99 alla settimana e da 9,90 a 9,99 al mese, l'Adepto da 19,90 a 19,99 al mese, l'Illuminato da 29,90 a 29,99 al mese; lo sconto annuale ricalcolato dell'Iniziato da 16 a 17 per cento (99,90 contro 119,88), Adepto e Illuminato restano 21 e 22. **Scelta presa con la risposta consigliata**: il settimanale dell'Adepto (4,90) e dell'Illuminato (6,90) e i tre annuali (99,90, 189,90, 279,90) non sono nominati nel messaggio e restano come sono; se vanno anche loro in novantanove, e' una riga per prezzo. Il foglio dell'oroscopo completo dice "da 2,99 € a settimana", letto dal listino.
- **La card da condividere, per l'utente e per l'amico**
  DOMANDA: "Mi raccomando di curare e ottimizzare la scheda di condivisione sia per l'utente sia per l'amico/a"
  PROVA: `test/la_card_da_condividere_e_per_chi_la_riceve_test.dart`
  MISURA: immagini vuote nella fotografia della card (l'emblema del periodo e la figura del segno), con la fotografia di prima a ottanta millesimi 2 su 2 nella prova, dopo 0 su 2: adesso si aspetta che siano pronte (`aspettaLeImmaginiDellaCard`), padre la fotografia a ottanta millesimi dalla nascita della card (`96aacd16`, 19 luglio 2026) e le immagini grandi dell'ordine ES voce 05 (`a9e52f66`); il titolo dice di chi e', "IL MIO OROSCOPO DEL GIORNO" o, per l'amico, "IL TUO OROSCOPO DEL GIORNO" con "Te lo manda" e il nome di chi la manda, su una riga sola (prima "OROSCOPO DEL GIORNO", e per l'amico la stessa card dell'utente); la figura del segno da 92 a 120 punti; il numero e il colore grandi come nella scheda; le ore migliori di oggi sulla card dell'utente; in fondo l'invito ("Scopri il tuo oroscopo", per l'amico "Il tuo cielo ogni giorno") e l'indirizzo in oro su una riga sua; il testo che accompagna l'immagine porta il link (`https://esotericircle.app`), per l'amico anche chi la manda. Le quattro domande: *qual e' il massimo?* che chi la riceve capisca in un secondo di chi e' e da chi viene; *come ottenere di piu'?* le ore migliori, la cosa che puo' usare oggi, e il link per avere il suo; *cosa penserebbe chi la riceve?* "e' per me?": "Il tuo oroscopo, te lo manda Mauro"; *come aumentare l'esperienza?* niente immagini vuote, niente parole a capo. Sul Realme la card non si vede senza mandarla a qualcuno: e' misurata in prova.
- **Il contatore di chi e' online**
  DOMANDA: "Controlla anche che l'indicatore online con numero di utenti on-line funzioni veramente."
  PROVA: `functions/src/presenza.ts` (la finestra) e la lettura delle presenze in Firestore del 1 ottobre 2026, descritta qui
  MISURA: il Realme, riacceso alle 13:04 ora italiana, ha scritto la sua presenza al server dopo meno di 20 secondi (11:04:48 UTC), e la barra dice "ONLINE 1": la domanda va e torna. Nel database ci sono due presenze in tutto, il telefono del fondatore (ultima alle 08:48 ora italiana) e il Realme: il conto conta i telefoni che hanno chiesto negli ultimi due minuti e mezzo, quindi con due telefoni aperti insieme dice 2 entro due minuti. **Non visto con due telefoni**: l'iPhone di collaudo ha la build 2288, che al centro della barra dice ancora "Eventi Cosmici" e non chiede la presenza, e il telefono del fondatore non era aperto; la prova a due si fa aprendo l'app sul telefono del fondatore col Realme acceso.
- **La riga delle tradizioni invita a scorrere**
  DOMANDA: "Nella riga di selezione della tipologia di oroscopo, non si capisce che dopo "cinese" ci sono altre tipologie e l'utente non viene automaticamente invitato a scorrere per vedere gli altri. Trova soluzione, magari allungando leggermente le bolle o altra soluzione migliore"
  PROVA: `test/le_tradizioni_invitano_a_scorrere_test.dart`; sul Realme `docs/collaudo/EU/realme/eu_sera_tradizioni_da_scorrere.jpg`
  MISURA: tre cose insieme. Le bolle si allungano finche' l'ultima in vista resta tagliata dal bordo (a 390 punti la Cinese si vede per il 70 per cento, prima per intero con la Maya che cominciava proprio sul bordo, 0 per cento); il bordo da cui la riga continua sfuma (pixel chiari sull'ultima colonna, senza la sfumatura fino a 6, dopo 0); a destra una freccia che a un tocco fa scorrere la riga di 188-208 punti, e in fondo la freccia passa a sinistra.

E tre difetti visti sul Realme dopo, curati con la loro prova nata rossa
(`docs/collaudo/EU/regola_a_richieste_della_sera.txt`, A20-A26bis):

- **I titoli col trattino accanto al selettore** ("RICOMIN- / CIARE DAL- /
  LE STANZE", "IL / CANTIERE / SOSPESO"): il titolo va sopra il selettore
  quando accanto andrebbe a capo col trattino o su tre righe. Titoli che
  si leggono male a video sui 1.548 dei dodici corpora, a 360 punti, da 830
  a 0 al carattere normale e da 1.535 a 5 al massimo. PROVA:
  `docs/collaudo/EU/realme/eu_sera_titolo_sopra.jpg`. PROVENIENZA: la voce
  ER.14 (la regola del trattino) incontrata coi titoli dei corpora della EU
  Aggiunta, piu' lunghi.
- **La barra dell'Oroscopo trasparente** col testo che le scorreva sotto: si
  vela quando qualcosa le passa sotto, opacita' da 0 a 92 per cento. PROVA:
  `docs/collaudo/EU/realme/eu_sera_barra_velata.jpg`. PROVENIENZA IGNOTA: la
  barra e' trasparente da prima dell'ordine ES.
- **Le tradizioni dell'amico in un altro ordine** (Occidentale, Cinese,
  Vedica): adesso Occidentale, Vedica, Cinese come nell'oroscopo della
  persona. PROVENIENZA IGNOTA: l'ordine e' quello del foglio dell'amico dalla
  sua nascita.

## I DIFETTI, COL LORO PADRE (Regola C)

Trovati dalle guardie prima dei commit, dalla suite intera del 1 ottobre e
dal Realme.

- **La storia delle fasce vedica leggeva la Luna dell'ultimo giorno
  calcolato** invece di quella del giorno chiesto, e la stessa voce tornava
  il giorno dopo (1.999 ritorni in novanta giorni). Padre: EU Aggiunta, prima
  del commit. Preso da `i_testi_non_tornano` (627).
- **Le righe della Settimana e del Mese della Vedica e della Cinese dicevano
  "oggi"** per giorni che non erano oggi. Padre: EU.02, prima del commit.
  Preso dall'agente che ha scritto `docs/collaudo/EU/affermazioni.md`,
  leggendo il codice.
- **Il compleanno del 29 febbraio** negli anni senza 29 febbraio diventava il
  1 marzo. Padre: EU.02, prima del commit. Preso dal confronto col JPL.
- **La prova `l_oroscopo_non_si_riscrive` toccava un tasto sotto il bordo**
  della finestra dopo la riga "Oroscopo per". Padre: EU.05 (`ae2d9370`).
- **Il PDF dell'anno su due pagine**, che Acrobat in Modalita' Liquida
  ricompone ripetendo in fondo i titoli della prima pagina. Padre: ordine ES
  voce 04 (`50747b54`).
- **I livelli dei giorni piatti** per settimane (i pianeti lenti senza tetto).
  Padre: ordine ES voce 28 (`b6106fb7`).
- **Dalla suite intera del 1 ottobre** (commit `8b9a581a`, 6.365 verdi, 11
  saltate, 20 rosse, di cui 7 accettate in `tool/rossi_accettati.txt`):
  - `corredo_anteprime`: la guardia del PDF dell'anno scrive file con
    `writeAsBytes` e il corredo la prendeva per una cattura senza rapporto di
    pixel. Padre: EU.12 (`ea18ad72`). Cura: la riga di eccezione con la
    ragione (scrive PDF, non catture).
  - `language_rule`, la regola della virgola: la nota del metodo dell'anno
    vedico ("al tuo compleanno, e si contano"). Padre: EU.02 (`67ca80b7`).
    Cura: la frase senza la virgola davanti a "e".
  - `ogni_decimale_a_video_passa_dalla_lingua`: la chiave della memoria delle
    storie del Giorno con `toStringAsFixed(3)`. Padre: EU Aggiunta
    (`67ca80b7`). Cura: la chiave in millesimi di grado interi.
  - `la_profondita_si_sceglie`, `la_profondita_sta_su_ogni_scheda`,
    `oroscopo_widget`: pretendevano l'invito al "Cerchio Premium" sul
    lucchetto della Lunga. Padre: EU.15 (`8b9a581a`), che ha messo le due
    strade e il piano chiamato per nome. Riscritte con la lapide.
  - `tipografia_nel_dato`: il censimento dei vuoti verticali era a 159, le
    viste nuove ne hanno 161. Padre: EU.09 ed EU.11 (`9b3e7aff`). Rigenerato.
  - `il_genere_non_si_indovina`, `la_carta_natale_sopravvive`,
    `la_parola_voce_resta_allaudio`, `testo_a_video`: falsi positivi sui
    corpora dell'Architetto ("una stanchezza che ha bisogno di essere
    riconosciuta", "gli altri scelgono ora e luogo", "tre voci brevi", "a
    quattr'occhi", "un vago 'se serve'"). PROVENIENZA: EU Aggiunta, i testi
    sono giusti e le guardie li leggevano male. Cura: le frasi dichiarate una
    per una con la loro ragione (non i file interi), le elisioni "quattr'" e
    "ventiquattr'", e la guardia dell'apostrofo che toglie le citazioni fra
    apici prima di cercare (misura cambiata, mai la soglia). Viste rosse dopo
    su sei difetti veri innestati (`docs/collaudo/EU/regola_a_guardie_di_casa.txt`).
  - `niente_vocativo_a_schermo`: "amico/a" sul pulsante della riga "Oroscopo
    per". E' la parola del fondatore (*"pulsante [amico/a]"*): dichiarata con
    la sua frase.
  - `il_cancello_aspetta_il_limite`: rossa nella suite mentre girava la build
    di release, verde da sola. PROVENIENZA IGNOTA nel senso stretto: nessuna
    voce EU tocca il cancello, e la prova misura un tempo sotto il carico di
    due lavori.
- **Dal Realme** (build di prova dal commit `8b9a581a`), sette difetti, ognuno
  con la sua prova nata rossa sul codice di allora
  (`docs/collaudo/EU/regola_a_dopo_il_realme.txt`):
  - **un suono alla pressione dell'invio**, la terza tradizione letta nel
    giorno: il Sigillo dei Tre Cieli suonava la rivelazione 0,5 secondi dopo
    il tocco. Padre: ordine ES voce 37 (il suono del Sigillo); la voce EU.03
    non l'aveva trovato perche' parte da un'altra porta e solo la terza volta.
  - **"Da dove viene" due volte di fila** nella Lunga della Settimana e del
    Mese della Vedica e della Cinese (il giorno migliore fra i tre giorni
    migliori e di nuovo in fondo, con "Il" maiuscolo dopo i due punti). Padre:
    EU.02 (`67ca80b7`).
  - **la testata dell'Anno della Cinese con le date dell'anno del ritorno del
    Sole**. Padre: EU.04 (`26b98680`), scritta prima che la EU.02 desse alla
    Cinese e alla Vedica il loro anno.
  - **"Il colore è quello di Il Sole"** sotto il numero fortunato. Padre:
    ordine ES voce 29 (`b6106fb7`).
  - **"VIANDA / NTE"** nella schermata dei piani col Viandante attivo. Padre:
    EU.07 (`eadaf701`), che ha portato il badge sul Viandante.
  - **"Lunga" col lucchetto sopra il testo della Breve** per chi scende al
    Viandante con la Lunga scelta. Padre: EU.07 ed EU.15: la discesa di piano
    dal telefono prima non esisteva.
  - **"La Lunga ogni giorno con l'Iniziato" su due righe allineate a
    sinistra** nel pulsante delle due strade. Padre: EU.15 (`8b9a581a`).
- **Dal Realme, dopo le richieste della sera** (build di prova dal commit
  `cd31e52f`), tre difetti, ognuno con la sua prova vista rossa sul difetto
  rimesso (`docs/collaudo/EU/regola_a_richieste_della_sera.txt`, A15, A16,
  A19):
  - **le ore migliori gia' passate**: alle 10:00 la Vedica diceva "dalle
    07:06 alle 08:05". Padre: richiesta della sera delle ore del giorno
    (`cd31e52f`). Adesso le ore migliori si dicono fra quelle che devono
    ancora finire (fasce gia' finite dette, con il difetto rimesso 1.248,
    dopo 0 in 868 momenti di una settimana a Roma).
  - **"col Rahu Kalam" senza dire quando**: nessuna barra diceva quale fosse.
    Padre: la stessa richiesta. Adesso la riga dice "Dalle 14:27 alle 15:56
    c'è il Rahu Kalam" (Roma, 1 ottobre).
  - **la cifra del numero fortunato alta nel riquadro**: il disegno delle
    cifre sta piu' in alto della sua riga. Padre: richiesta della sera del
    numero e del colore (`cd31e52f`). Misurato sui pixel: il disegno del "6"
    fuori centro del 3,6 per cento dell'altezza del riquadro prima, dell'1,8
    dopo (il "7" 1,2, il "22" 1,6; la soglia della prova e' 3).
- **Dalla suite intera del commit `cd31e52f`** (6.425 verdi, 11 saltate, 17
  rosse, di cui 7 accettate in `tool/rossi_accettati.txt`): dieci rosse nuove,
  tutte delle richieste della sera.
  - `accenti_veri` (tre prove): l'esenzione di "Coordinate da" in
    `sky_overview_screen.dart` non trovava piu' la sua riga, andata a capo
    quando il foglio ha preso "Fatto" in fondo. Padre: richiesta della sera
    "ogni foglio si chiude" (`cd31e52f`). Cura: l'esenzione segue la riga.
  - `etichette_e_lettura`: "Abbonati per avere sempre l'oroscopo completo" in
    maiuscoletto su due righe. Padre: richiesta della sera del foglio della
    Lunga (`cd31e52f`). Cura: il pulsante in corpo, una frase.
  - `oroscopo_tipografia`, "Un solo blocco in oro per scheda": la riga delle
    ore migliori in oro accanto all'apertura. Padre: richiesta della sera
    delle ore del giorno (`cd31e52f`); la riga dei mesi migliori dell'Anno
    aveva lo stesso oro (stessa sera). Cura: tutte e due in bianco.
  - `i_difetti_visti_sul_realme_alla_2285`: la Fortuna, quarta scheda, non
    nasceva piu' nella finestra di 3.200 punti, piu' lunga di 140 punti per
    scheda con le ore. Padre: la stessa richiesta. Cura: la finestra a 4.400,
    dichiarata.
  - `la_lunga_si_apre_con_gli_eos` e `la_profondita_sta_su_ogni_scheda`:
    pretendevano "per la giornata e le quattro schede" e "si apre con
    l'Iniziato". Padre: richiesta della sera del foglio della Lunga
    (`cd31e52f`), che ha tolto quelle parole. Riscritte con la lapide: il nome
    dice "di oggi" e "quattro le schede" e non dice "Lunga"; l'invito dice
    "Abbonati" e non il nome del piano.
  - `la_tradizione_scelta_sta_in_cima`: pretendeva "al-Iklil, la corona" in
    testa e lo sfondo `Tradizione-Araba-Square-1`. Padri: la richiesta della
    sera del nome leggibile e l'EU Aggiunta 2 (`cd31e52f`). Riscritta con la
    lapide.
  - `numero_e_colore_hanno_la_stessa_altezza`: cercava l'etichetta "COLORE
    DEL GIORNO", diventata "COLORE". Padre: richiesta della sera del numero e
    del colore (`cd31e52f`). Cura: il riquadro cercato per chiave; scarto fra
    le due bolle 0,0 punti.

## PER L'ARCHITETTO

Code non ha cambiato una virgola dei dodici corpora (regola fissa 11). Le
cose che ho visto e che tocca a lui decidere:

1. **Tre frasi col futuro di un gesto scelto**: "decidi già adesso a che
   ora tornerai a casa" (`oroscopo_eu_occidentale_giorno.md`, riga 870),
   "Alla prossima richiesta partirai da lì" (riga 1300), e "domani
   indosserai" (riga 470). Il confine del responso (`confine_del_responso.dart`) le
   leggeva come previsioni e le avrebbe tagliate. **Scelta consigliata**:
   il confine non legge piu' come previsione il futuro di un gesto che la
   persona sceglie in una relativa ("a che ora", "in cui", "ciò che",
   "quello che"); i testi restano interi. Se l'Architetto preferisce
   un'altra forma, si torna indietro.
2. **"Almanacco" 16 volte nei corpora cinesi** (Settimana 7, Giorno 5,
   Mese 2, Anno 2): e' un tecnicismo per chi legge le Linee Guida, sezione
   5? Da decidere.
3. **Un'ellissi "io sono..."** nel corpus cinese del Giorno (riga 679).
4. **Il Rahu Kalam**: prima l'orario stava nel testo; adesso sta solo nel
   "Da dove viene", e una delle tre varianti ("Siamo dentro il Rahu Kalam di
   oggi") non dice l'ora.
5. **88 affermazioni senza fonte** su 759 (Occidentale 31, Vedica 15,
   Cinese 42): l'elenco intero, una per una, sta in
   `docs/collaudo/EU/affermazioni.md`. E' la risposta alla domanda della
   EU.14 *"verifica che l'interpretazione sia reale e non inventata"*: 671
   hanno una fonte dichiarata, 88 no, e quelle le verifica l'Architetto.
6. **Note del metodo superate dai testi nuovi**: O-M-001 e O-M-002 ("La
   prima frase viene dalla Luna di oggi...") descrivono il testo di prima;
   C-M-002 ("il consiglio viene dal solo guardiano") parla di consigli che
   nessuna schermata legge piu'; C-M-004 dice che la scheda legge il dio come
   lo Yuanhai Ziping, e adesso il testo viene dal corpus e il dio resta nel
   "Da dove viene". Padre: EU Aggiunta (il testo e' cambiato, le note no).
   Sono righe dell'Architetto: le riscrive lui.
7. **"Bianco screziato" e "lo screziato"**: per il venerdi' il corpus vedico
   dice "lo screziato" e il codice "bianco screziato". PROVENIENZA IGNOTA fra
   le voci ES.09 ed ES.29.
8. **Righe scritte da Code in quest'ordine, che l'Architetto deve rileggere**:
   le righe dell'anno vedico ("Al tuo compleanno del ... Giove era in ...,
   nella tua ... casa dalla Luna di nascita: una casa favorevole") e
   dell'anno cinese ("L'anno del Cavallo va dal ... Tai Sui, il signore
   dell'anno: lo offendi, hai lo stesso animale dell'anno"), le due note del
   metodo dell'anno (`l_anno_delle_tradizioni.dart`), la riga "il giorno
   migliore, ...:" della Settimana e del Mese vedici e cinesi, e la riga
   "Il colore è quello del Sole" corretta dal Realme. La regola fissa 11 dice
   che queste righe non le scrive Code: le ho scritte perche' senza la
   Settimana, il Mese e l'Anno della Vedica e della Cinese non esistevano
   (EU.02, scelta "Proposta Architetto"), e le metto qui perche' le sostituisca.
9. **La riga della ruota (ordine ES voce 33) ripete il primo passaggio del
   "Da dove viene"** aggiungendo solo la casa: "Dal cielo di oggi: il Sole in
   quadratura al tuo Urano di nascita; ..." e subito sotto "Il Sole di oggi in
   quadratura al tuo Urano di nascita, nella tua terza casa" (Realme,
   `eu01_occidentale_giorno_breve_2.jpg`). Il fondatore ha chiesto di evitare
   le ripetizioni; la riga e' del "Da dove viene", quindi la forma la decide
   l'Architetto (proposta: la riga della ruota dice solo "Guardalo sulla tua
   carta, nella tua terza casa").
10. **Due giorni migliori di fila con lo stesso "Da dove viene"**: senza carta
    natale la Luna resta due giorni e mezzo nello stesso segno, e nella Lunga
    della Settimana due dei tre giorni migliori possono portare la stessa
    riga (la prova `il_da_dove_non_si_ripete_nel_periodo` l'ha trovato
    misurando: e' una verita' del cielo, non un difetto del codice). Come
    dirlo senza ripetere lo decide l'Architetto.

## LE SCELTE PRESE CON LA RISPOSTA CONSIGLIATA

Il fondatore: *"usa la risposta consigliata senza disturbarmi, non lasciare
niente in coda"*.

1. **Il PDF dell'anno su un foglio solo** largo quanto un A4 e alto quanto
   serve, invece di due pagine A4: con due pagine Acrobat in Modalita' Liquida
   ripete i titoli, con una no (EU.12).
2. **Il Mese a calendario** allineato ai giorni della settimana, con cinque
   righe, o sei quando il periodo comincia di domenica (EU.11).
3. **Cinque colori** dal giallo opaco al rosso fuoco (`FF5233`), uno per
   gradino del livello (EU.09).
4. **La percentuale** sulla barra migliore e' il livello per venti (5 = 100%).
5. **La Lunga della Settimana e del Mese**: i tre giorni migliori, ognuno col
   titolo della sua scheda del Giorno e il suo "Da dove viene" (prima la
   Settimana Lunga ne mostrava sette).
6. **L'anno cinese**: le quattro schede col livello del rapporto fra il tuo
   animale e quello dell'anno; il Tai Sui abbassa di un gradino quando l'anno
   ha il tuo stesso animale o ti "rompe".
7. **L'anno vedico**: il livello dalle case di Giove e Saturno contate dalla
   Luna di nascita (Phaladeepika, cap. 26), con la Sade Sati che abbassa;
   la regola e' scritta nella nota del metodo.
8. **Il confine del responso**: il futuro di un gesto scelto in una relativa
   non e' una previsione (vedi "Per l'Architetto", punto 1).
9. **La profondita' del Viandante nella tabella dei piani**: "Breve; la Lunga
   del giorno con gli Eos".
10. **Il carattere massimo** misurato nelle prove a scala 2,0, non sul
    telefono: la scala del sistema del Realme non si cambia.
11. **La rivelazione del segno con Riduci Movimento**: la figura compare
    intera, senza salire. Sul Realme le animazioni del sistema sono spente
    (le tre scale a 0), quindi a video si vede la figura intera, e
    l'animazione la vede chi ha le animazioni accese (EU.13 aperta per
    questo).
12. **Le frasi dei corpora che le guardie di casa leggevano male** si
    dichiarano una per una, con la loro ragione, e non si esclude il file:
    cosi' le 1.548 voci restano guardate.
13. **Il Sigillo dei Tre Cieli si accende senza suono** alla pressione
    dell'invio, con la sola vibrazione: il fondatore ha chiesto che alla
    pressione non suoni niente.
14. **Il nome del piano intero, il badge sotto se non c'e' posto**, invece di
    rimpicciolire il nome.
15. **Chi scende al Viandante con la Lunga scelta legge "Breve"** nel
    selettore: la voce mostrata e' quella che si legge.
16. **La cache delle storie del Giorno con la chiave in millesimi di grado**
    invece di tre decimali col punto.
17. **La scritta del piano al centro del suo pulsante** nelle due strade della
    Lunga, anche su due righe (visto sul Realme, la EU.15 l'aveva a sinistra).

## VISTE SUL REALME FUORI DALLE VOCI

Cose viste guardando il telefono, fuori dalle diciannove voci. La prima
stesura di questo rapporto le lasciava al fondatore; la sua regola e'
decidere con la risposta consigliata e non lasciare niente in coda, quindi:

1. **La barra dell'Oroscopo trasparente** col testo che le scorre sotto:
   **curata**, si vela quando qualcosa le passa sotto (vedi le richieste
   della sera, guardia 642).
2. **I titoli delle schede col trattino accanto al selettore**: **curati**, il
   titolo va sopra quando accanto si spezzerebbe o andrebbe su tre righe
   (guardia 641).
3. **L'ordine delle tradizioni dell'amico**: **curato**, Occidentale, Vedica,
   Cinese come quello della persona (guardia 643).
4. **Il Mese e' di trenta giorni da oggi** ("dal 1 ottobre al 30 ottobre
   2026"), non il mese del calendario. **Scelta consigliata: resta cosi'.**
   E' la regola approvata dal fondatore con l'ordine ES (voce ES.03), e i
   corpora dell'Architetto contano il Mese su quella base
   (`ITestiEu.indiceDelMese`): cambiarla cambierebbe quale voce legge ogni
   persona. Se il fondatore preferisce il mese del calendario, e' una voce
   d'ordine sua.

## I COMMIT

In ordine, dal primo all'ultimo, sul ramo `claude/esoteric-circle-master-order-e798aj` (il messaggio intero di ognuno si legge con `git log`):

- `b4e9d0dc` EU, avvio: il manifesto con le diciannove voci dei due pezzi e la domanda del fondatore di ciascuna, la guardia dell'ordine (617) rossa su due innesti, le otto voci aperte [...]
- `0260d6c3` EU.03: alla pressione dei tasti di invio non suona piu' niente (la soglia di BK.04 su Interroga il cielo e di CO.07 sull'avvio della stesa), resta la vibrazione e il suono [...]
- `26b98680` EU.04: la testata dell'Oroscopo dice "Oroscopo del giorno", "della settimana", "del mese", "dell'anno" su una riga, senza "Personalizzato", e sotto le date; per l'Anno le date [...]
- `ae2d9370` EU.05: la riga "Oroscopo per" sopra i periodi, col nome della persona scelto e "amico/a"; il tocco su amico/a apre "I tuoi amici" per scegliere, la lettura dell'amico porta la [...]
- `eadaf701` EU.06 ed EU.07: le immagini di Maya, Egizia, Celtica e Araba sono gli sfondi Tradizione-* della cartella del fondatore, portati dalla ES.11 (a9e52f66), usati da nessun'altra [...]
- `d9831989` EU.10: il numero fortunato grande e al centro del suo riquadro, col ruolo tipografico nuovo del numero del giorno (40 punti, 52 al carattere massimo, il doppio dell'etichetta) e [...]
- `7bcf84fe` EU.19: i contatori della barra in alto si leggono sempre: il velo della barra passa dal 72 al 92 per cento, il contrasto peggiore dei contatori sul colore piu' chiaro che puo' [...]
- `ea18ad72` EU.12: il PDF dell'anno su un foglio solo, largo quanto un A4 e alto quanto serve, con ogni scheda intera; la ripetizione della cattura del fondatore era la Modalita' Liquida di [...]
- `39b6d820` EU.12: la guardia del PDF scrive i tre esempi in docs solo con SCRIVI_I_PDF=1, perche' ogni PDF porta data e identificativo e riscriverlo a ogni giro sporcava l'albero.
- `9b3e7aff` EU.09 ed EU.11: il livello dei giorni col clima dei lenti tenuto a un gradino (Hand, Planets in Transit) e la Luna del giorno al corpo natale del dominio entro sei gradi (Lilly, [...]
- `67ca80b7` EU Aggiunta, EU.01, EU.02, EU.08, EU.14, EU.16, EU.17, EU.18: i testi dell'Architetto a video. I dodici corpora di docs/corpus/eu entrano uguali byte per byte e il codice li porta [...]
- `8b9a581a` EU.13 ed EU.15: la prima apertura di Vedica, Cinese, Maya, Egizia, Celtica e Araba, e di una tradizione dell'amico, rivela il segno in testa (la figura sale con la sua luce, poi [...]
- `cd31e52f` EU dal Realme e le richieste del fondatore della sera del 1 ottobre: sul Realme sette difetti curati con la loro prova nata rossa (il Sigillo dei Tre Cieli suonava alla pressione [...]
- `ece93edc` EU, il secondo giro sul Realme delle richieste della sera e la suite intera del commit cd31e52f: le ore migliori del giorno si dicono fra quelle che devono ancora finire (alle [...]
- `d4ecae35` EU, l'oroscopo completo detto con le parole di chi legge e i tre difetti del Realme che restavano: il foglio dell'oroscopo completo non vende piu' "due paragrafi" (il fondatore: [...]
- `ab7e2cb9` EU, le ore migliori segnate sulle barre (un punto d'oro sopra ogni ora migliore, un segno sotto l'ora di adesso: "come posso aumentare l'esperienza utente?") e il titolo sopra il [...]
- `d17db7af` EU, l'ora di adesso col bordo chiaro sulla sua barra: sul Realme la freccia da sola era piccola. Guardia 639 rossa togliendo il bordo (A29).
- e il commit dei documenti finali (questo rapporto con l'elenco dei commit, la cattura delle ore sulle barre), il cui numero sta nel messaggio al fondatore, letto da `git ls-remote`.
