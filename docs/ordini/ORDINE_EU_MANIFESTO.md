# ORDINE EU, L'OROSCOPO DOPO IL COLLAUDO DEL FONDATORE SULLA 2289

**Sigla:** EU, verificata sul ramo il 1 ottobre 2026 sul commit `902ef8e5`: in
`docs/ordini` l'ultimo manifesto era `ORDINE_ET_MANIFESTO.md` (in ordine di
sigla) e non esisteva `ORDINE_EU`; in `docs/collaudo` non esisteva la cartella
EU. **Data dell'ordine:** 1 ottobre 2026, in due pezzi.
**Ramo:** `claude/esoteric-circle-master-order-e798aj`, nessun altro.
**Partenza:** commit `902ef8e5`, col cancello di GitHub verde su quel commit
(il segno `refs/verde/902ef8e5...` c'e'). **Questo ordine non consegna niente**:
le build le ordina il fondatore.

**La stima dichiarata al fondatore prima di cominciare**: 30-40 ore di
lavoro, 3-4 giorni, piu' le catture sul Realme. Le voci che dipendono dai
testi dell'Architetto (la "EU Aggiunta") si chiudono quando i testi arrivano:
fino ad allora Code costruisce i posti e le prove (regola fissa 11).

Le 31 voci aperte dell'ordine ES restano nel manifesto ES; dove una voce EU le
tocca, la voce ES ha la riga che lo dice.

VOCI_TOTALI: 19
VOCI_CHIUSE: 16
VOCI_APERTE: 3
VOCI_DA_FARE: 0

Le prove stanno in `docs/collaudo/EU/`, quelle del telefono di prova (Realme
767f596c) in `docs/collaudo/EU/realme/`, le trenta catture del fondatore sulla
2289 in `docs/collaudo/EU/catture_fondatore/`. **Una voce che si vede a schermo
e' chiusa solo con la sua cattura dal Realme**, le animazioni con la loro
registrazione dello schermo.

**Le regole fisse dell'ordine**, riportate per intero perche' valgono per
ogni voce: lo stato vivo letto all'apertura e aggiornato alla fine senza
condensare; il protocollo delle guardie (Regola A, B e C); il protocollo
della chiusura (DOMANDA, PROVA, MISURA; prodotta ma non guardata e' APERTA IN
ATTESA DI VERIFICA); nessuna build consegnata; nessuna credenziale in chat; i
modelli nella regione dei dati; `flutter analyze lib test`, la suite e le
prove sui flussi di lavoro prima di ogni spinta; Viandante e' il piano
gratuito, i piani a pagamento sono Iniziato, Adepto e Illuminato; **i testi
dei responsi sono materiale dell'Architetto** (Linee Guida, sezione 8): in
quest'ordine Code non scrive, non riscrive e non riformula nessun testo di
responso, titolo di scheda o riga di "Da dove viene"; le regole dei responsi
sono le Linee Guida, sezioni 2, 5, 8, 11, 15 e 16, nella versione del 30
settembre 2026.

---

## PARTE 1, I RILIEVI DEL FONDATORE SULLA 2289

## VOCE EU.01, BREVE DUE PARAGRAFI, LUNGA DUE IN PIU', IL CIELO SOLO IN "DA DOVE VIENE"

**CHIUSA.** Vista sul Realme il 1 ottobre 2026, build di prova dal commit `8b9a581a`: il Giorno in Breve e in Lunga nell'Occidentale, nella Vedica e nella Cinese (`docs/collaudo/EU/realme/eu01_*.jpg`), e la Settimana, il Mese e l'Anno con la stessa forma. La Breve ha la risposta e che cosa fare, la Lunga altri due paragrafi, e il cielo sta solo nella riga "Da dove viene": i testi sono quelli dei dodici corpora dell'Architetto (EU Aggiunta, commit `67ca80b7`), portati carattere per carattere (`i_testi_eu_sono_quelli_dell_architetto_test.dart`, 623). La guardia `i_paragrafi_dicono_risposte_test.dart` (624) conta le schede.

DOMANDA: "QUANTE VOLTE DEVO SCRIVERLO: ALL'UTENTE NON GLIENE FREGA UN CAZZO DEI TRANSITI: VUOLE RISPOSTE O UNA GUIDA. CI SONO APPOSTA DELLE REGOLE PER LE RISPOSTE!"; "In generale per breve sono sufficienti 2 paragrafi e per lunga aggiungere altri 2 paragrafi mai di transiti o tecnicismi perché sotto c'è già sempre "da dove arriva"."; "i testi sono importantissimi e devono seguire le regole per le risposte es evitare ripetizioni".
PROVA: docs/collaudo/EU/paragrafi_misura.txt
MISURA: paragrafi in Breve, prima 3 o 4 con i transiti dentro, dopo 2 su 864 schede in prova; in Lunga 4; parole del cielo nei paragrafi, dopo 0; cielo detto due volte, dopo 0; sul Realme 2 paragrafi in Breve e 4 in Lunga nelle tre tradizioni (eu01_occidentale_giorno_lunga_1..3.jpg, eu01_vedica_giorno_lunga_1..3.jpg, eu01_cinese_giorno_lunga_1..3.jpg)

## VOCE EU.02, SETTIMANA, MESE E ANNO DELLA VEDICA E DELLA CINESE

**CHIUSA.** Vista sul Realme il 1 ottobre 2026: la Settimana, il Mese e l'Anno della Vedica e della Cinese ci sono (`docs/collaudo/EU/realme/eu02_*.jpg`), col metodo dell'Architetto che il fondatore ha scelto ("Proposta Architetto"): ogni giorno del periodo e' la scheda del Giorno di quella data; l'anno cinese da Capodanno lunare col Tai Sui e le cinque relazioni; l'anno vedico da compleanno col gochara di Giove e Saturno dalla Luna di nascita e la Sade Sati. Sul Realme la Lunga della Settimana vedica diceva "Da dove viene" due volte: difetto di questa voce, curato con la sua prova nata rossa (`il_da_dove_non_si_ripete_nel_periodo_test.dart`, 631), vista dopo in `eu02_vedica_settimana_lunga_senza_ripetizione.jpg`.

DOMANDA: "manca l'oroscopo settimanale, mensile e annuale per vedica e cinese, attualmente c'è solo quello giornaliero."; domanda girata al fondatore: il metodo dell'Architetto (Settimana e Mese col metodo del Giorno giorno per giorno; Anno Cinese con l'animale dell'anno e il Tai Sui; Anno Vedico coi transiti di Giove e Saturno dalla Luna di nascita e il Sade Sati), risposta: "Proposta Architetto".
PROVA: docs/collaudo/EU/vedica_cinese_periodi.txt
MISURA: periodi della Vedica e della Cinese, prima 1 su 4 (solo il Giorno), dopo 4 su 4; giorni dei periodi col livello o il titolo diversi dal Giorno della stessa data 0 su 888; anni cinesi con animale, Capodanno o Tai Sui diversi dalla fonte 0 su 10; persone con Giove o Saturno contati diversi dal JPL 0 su 10; "Da dove viene" ripetuto nella Lunga dei periodi vedici e cinesi, dal Realme prima 2 volte, dopo 1

## VOCE EU.03, IL SUONO ALL'INVIO

**APERTA IN ATTESA DI VERIFICA**: alla pressione di "Interroga il cielo", "Interroga la Luna" e "Apri l'almanacco" e dell'avvio della stesa non suona piu' niente (`docs/collaudo/EU/suono_invio.txt`), e sul sistema audio del Realme la prima e la seconda tradizione del giorno non hanno tracce al tocco (`docs/collaudo/EU/realme/eu03_suono_invio_realme.txt`). Lo stesso registro ha trovato un suono alla pressione che la voce non aveva visto: la terza tradizione letta nel giorno accende il Sigillo dei Tre Cieli (padre ES.37) e suonava la rivelazione mezzo secondo dopo il tocco. Curato (il Sigillo si accende con la sola vibrazione) e provato rosso e verde in `la_soglia_e_la_rivelazione_dell_oroscopo_test.dart`. **Manca la misura dal telefono del Sigillo curato**: il Sigillo si accende una volta al giorno, e sul Realme si era gia' acceso alle 06:58 del 1 ottobre con la build di prima; il telefono non e' debuggabile e la data del sistema non si cambia. Si chiude con la prima terza tradizione del 2 ottobre sul Realme, col registro di `tool/ascolta_il_realme.py`: nessuna traccia nel primo secondo dopo il tocco.

DOMANDA: "Quando premo sul tasto di invio per avere la risposta (interroga la luna, ecc) parte immediatamente un suono fastidioso che deve essere eliminato, invece il suono orchestrale che gli ho caricato va bene."

## VOCE EU.04, LA TESTATA: "OROSCOPO DEL GIORNO" E LA DATA

**CHIUSA.** Vista sul Realme il 1 ottobre 2026: sotto l'emblema "Oroscopo del giorno", "della settimana", "del mese", "dell'anno" su una riga e sotto le date, senza "Personalizzato" (`eu04_eu05_testata_giorno.jpg`, `eu04_mese_testata.jpg`, `eu04_anno_testata.jpg`, `eu04_vedica_settimana_testata.jpg`). Sul Realme la testata dell'Anno cinese diceva le date del ritorno del Sole invece di quelle dell'anno cinese: difetto di questa voce, curato con la sua prova nata rossa (`le_date_dell_anno_sono_della_tradizione_test.dart`, 632), vista dopo in `eu04_cinese_anno_testata_dopo.jpg`.

DOMANDA: "Sotto l'emblema del segno non c'è bisogno di scrivere "personalizzato", è sufficiente "Oroscopo del giorno o settimana o mese o anno" e sotto la data o date corrispondenti, in questo modo guadagniamo una interlinea".
PROVA: docs/collaudo/EU/realme/eu04_cinese_anno_testata_dopo.jpg
MISURA: parola "Personalizzato" nella testata, prima 1, dopo 0 nei 4 periodi; righe della testata, prima 3 (titolo, Personalizzato, date), dopo 2; testate dell'Anno con le date di un'altra tradizione, dal Realme prima 1 su 3 (Cinese), dopo 0 su 3

## VOCE EU.05, IL SELETTORE "OROSCOPO PER"

**CHIUSA.** Vista sul Realme il 1 ottobre 2026, build di prova dal commit `8b9a581a`: la riga "Oroscopo per" sopra i periodi col nome della persona ("Collaudo") e "amico/a"; il tocco su amico/a apre "I tuoi amici" (`eu05_amici_dopo_il_tocco.jpg`), la scelta di Lucia apre il suo oroscopo con la stessa riga (`eu05_oroscopo_di_lucia.jpg`), il nome della persona riporta alla sua lettura (`eu05_ritorno_a_collaudo.jpg`). Il pulsante in alto non c'e' piu' (commit `ae2d9370`).

DOMANDA: "voglio un selettore proprio sopra il selettore di giorno, settimana, mese, anno) in cui l'utente può scegliere se vuole consultare l'oroscopo per se stesso o un amico/a. Quindi un testo "oroscopo per" + pulsante [nome utente] predefinito + pulsante [amico/a]. Se fai click su [amico/a] compare la schermata "i tuoi amici". Così scompare il pulsante in alto che è poco visibile."
PROVA: docs/collaudo/EU/realme/eu05_oroscopo_di_lucia.jpg
MISURA: pulsanti dell'amico nella barra in alto, prima 1, dopo 0; righe "Oroscopo per" sopra i periodi, prima 0, dopo 1 in ognuno dei 4 periodi alle scale 1,0 e 1,3 (8 su 8, docs/collaudo/EU/regola_a_oroscopo_per.txt); tocchi dal telefono per arrivare all'oroscopo dell'amico, 2

## VOCE EU.06, LE IMMAGINI DELLE TRADIZIONI IN ARRIVO

**CHIUSA.** Con l'EU Aggiunta 2. La domanda era se Code avesse preso l'immagine da altre grafiche: **no**. Le immagini di prima erano gli sfondi `Tradizione-*-Square-1.webp` della cartella del fondatore (`assets/Sfondi Schede`), uguali byte per byte, portati dalla voce ES.11 (`a9e52f66`) dopo il suo "Si inseriscili nell'ordine", usati da nessun'altra funzione e copie di nessun altro sfondo. Adesso Maya, Egizia, Celtica e Araba mostrano l'emblema senza sfondo ritagliato dall'Architetto, gli stessi file del PC (`assets/Segni Zodiacali/Tradizioni`) entrati in `assets/img/zodiac/` con lo stesso nome, alla misura delle figure dei segni, anche nell'oroscopo dell'amico (guardia `le_tradizioni_in_arrivo_hanno_l_emblema_senza_sfondo_test.dart`, 637). Viste sul Realme le quattro (`eu06_{maya,egizia,celtica,araba}_emblema_senza_sfondo.jpg`).

DOMANDA: "Se seleziono un oroscopo non sbloccato, ad esempio maya, mi compare il mio segno calcolato, ma l'icona in alto che compare non c'entra nulla, code ha rubato l'asset da altre grafiche, se non sbaglio."
PROVA: docs/collaudo/EU/immagini_tradizioni.txt
MISURA: tradizioni non sbloccate con un'immagine con lo sfondo, prima 4, dopo 0; webp nel ramo uguali a quelli del PC (sha256), 4 su 4; immagini di prima prese da un'altra funzione, 0 su 4

## VOCE EU.07, IL PIANO VIANDANTE PER LE PROVE

**CHIUSA.** Visto sul Realme il 1 ottobre 2026: nella demo, dal Mio account, il Viandante si sceglie col suo pulsante come gli altri piani, e diventa il piano attuale (`eu07_viandante_attivo.jpg`, `eu07_viandante_piano_attuale.jpg`); fuori dalla demo il pulsante non c'e' (`AppFlags.isDemo`). Sul Realme il nome del piano si spezzava dentro la parola ("VIANDA / NTE"): difetto di questa voce, curato con la sua prova nata rossa (`il_nome_del_piano_non_si_spezza_test.dart`, 633), visto dopo in `eu07_viandante_nome_intero.jpg`.

DOMANDA: "Per ora è necessario rendere disponibile il cambio di abbonamento in "viandante" per fare le prove."
PROVA: docs/collaudo/EU/realme/eu07_viandante_nome_intero.jpg
MISURA: piani raggiungibili dal telefono nella demo, prima 3 su 4, dopo 4 su 4; pulsanti del Viandante fuori dalla demo 0; nomi di piano spezzati dentro la parola, dal Realme prima 1, dopo 0 su 4 alle scale 1,0 e 1,3

## VOCE EU.08, UN TITOLO SU OGNI SCHEDA DELLA SETTIMANA

**CHIUSA.** Vista sul Realme il 1 ottobre 2026: ogni scheda della Settimana ha il suo titolo sopra il dominio ("Lo stesso sabato", "Il gesto restituito", "L'aria dopo il riassetto"), dal corpus della Settimana dell'Architetto, e nella Lunga i tre giorni migliori col titolo della loro scheda del Giorno (`eu08_settimana_lunga_1..4.jpg`).

DOMANDA: "Nell'oroscopo settimanale occidentale, le risposte vanno bene: breve ok e lunga con i singoli giorni,a ogni scheda dovrebbe avere un titolo come per oroscopo giornaliero."
PROVA: docs/collaudo/EU/realme/eu04_eu08_eu09_settimana_barre.jpg
MISURA: schede della Settimana col titolo, prima 0 su 4, dopo 4 su 4 a video; righe dei giorni migliori col titolo del Giorno, dopo 3 su 3 per scheda

## VOCE EU.09, LE BARRE DELLA SETTIMANA

**CHIUSA.** Vista sul Realme il 1 ottobre 2026: le barre della Settimana alte in proporzione al livello, nei cinque gradini dal giallo opaco al rosso fuoco, con la percentuale sulla migliore ("100%" sul martedi' della Generale, "80%" sul giovedi' dell'Amore, "60%" sul lunedi' della Carriera), e la scala "più quieto ... più favorevole" (`eu04_eu08_eu09_settimana_barre.jpg`). Il livello dei giorni tiene i lenti a un gradino e aggiunge la Luna del giorno (commit `9b3e7aff`).

DOMANDA: "le barre di cui una gialla in evidenza sembrano tutte uguali, dovrebbe cambiare anche l'altezza e magari inserire una percentuale, ma cambiano pochissimo. Magari si potrebbero colorare in modo diverso anche da meno intenso a più intenso, da giallo opaco a rosso fuoco per il giorno migliore. Cmq puoi proporre altro di meglio."; domanda girata al fondatore: la proposta dell'Architetto (altezza proporzionale, cinque gradini dal giallo opaco al rosso fuoco, la percentuale sul giorno migliore, il Mese a griglia), risposta: "Altezza e colore (Consigliata)".
PROVA: docs/collaudo/EU/livelli_dei_giorni.txt
MISURA: domini-settimana coi sette giorni allo stesso livello, prima 4 su 64, dopo 2 su 64 (Venere stazionaria il 3 ottobre, una settimana quieta senza carta); altezze delle barre in proporzione al livello 7 su 7 alle scale 1,0 e 2,0; colori uguali al gradino 7 su 7; contrasto peggiore di un gradino sul fondo 3,22

## VOCE EU.10, IL NUMERO FORTUNATO GRANDE E AL CENTRO

**CHIUSA.** Visto sul Realme il 1 ottobre 2026: il numero fortunato "6" grande e al centro del suo riquadro (`eu10_numero_fortunato_prima_della_riga_del_colore.jpg`), commit `d9831989`. Sotto, la riga del colore diceva "quello di Il Sole": difetto della voce ES.29, curato in questo ordine ("del Sole") con la sua prova. La sera il fondatore ha chiesto di piu': *"Il colore del giorno e il numero del giorno più grandi in modo da riempire il riquadro e centrati verticalmente e orizzontalmente."* Adesso il numero e il colore stanno in due riquadri gemelli alti 112 punti, e la cifra e il cerchio col nome crescono fino allo spazio del riquadro (`LaFortunaDelGiorno`, guardia `il_numero_e_il_colore_riempiono_il_riquadro_test.dart`, 634); visti sul Realme con la build di prova del commit `ece93edc` (`eu_sera_numero_e_colore_riempiono.jpg`).

DOMANDA: "Il numero fortunato deve essere grande e al centro del suo riquadro."
PROVA: docs/collaudo/EU/realme/eu_sera_numero_e_colore_riempiono.jpg
MISURA: altezza della cifra rispetto all'etichetta, prima 1,05 (21 su 20), dopo il richiamo della sera la cifra tocca lo spazio del riquadro in 9 coppie di riquadri su 9 (una cifra, due cifre, i due numeri cinesi, al carattere 1,0 e 1,3); disegno della cifra fuori centro dal centro del riquadro, misurato sui pixel, 1,8 per cento col "6", 1,2 col "7", 1,6 col "22" (prima del margine 3,6); scarto d'altezza fra il riquadro del numero e quello del colore 0,0 punti

## VOCE EU.11, IL MESE A GRIGLIA

**CHIUSA.** Visto sul Realme il 1 ottobre 2026: il Mese e' un calendario con una casella per giorno, allineato ai giorni della settimana, ogni casella nel colore del suo gradino e la percentuale sulla migliore (`eu11_eu18_mese_griglia_1..3.jpg`), commit `9b3e7aff`.

DOMANDA: "L'oroscopo mensile ha lo stesso problema dell'infografica poco chiara e molto simile tra loro."; domanda girata al fondatore: "Il Mese diventa un calendario a griglia di 5 settimane con le caselle colorate", risposta: "Altezza e colore (Consigliata)".
PROVA: docs/collaudo/EU/regola_a_barre_e_griglia.txt
MISURA: caselle del Mese, prima 0 (barre), dopo 30 su 30 col colore del loro gradino; caselle senza il numero del giorno, 0 su 30; percentuali sulla migliore 1

## VOCE EU.12, IL PDF DELL'ANNO

**CHIUSA.** Visto sul Realme il 1 ottobre 2026 nello stesso lettore del fondatore, Adobe Acrobat in Modalita' Liquida: col PDF di prima i titoli "Il tono del tuo anno", "L'amore nel tuo anno", "Il lavoro nel tuo anno" tornavano in fondo senza testo (`eu12_prima_acrobat_fine.png`); col PDF su un foglio solo no (`eu12_dopo_acrobat_liquida_1..5.png`). Commit `ea18ad72` e `39b6d820`.

DOMANDA: "Oroscopo annuale va bene, ma il PDF alla fine mostra una ripetizione "del tuo lavoro"."
PROVA: docs/collaudo/EU/pdf/da_dove_veniva_la_ripetizione.txt
MISURA: titoli ripetuti in fondo in Acrobat Liquida, prima 3, dopo 0; PDF dell'anno su due pagine, prima 12 su 12, dopo 0 su 12; schede spezzate fra due pagine, prima 9 su 12, dopo 0

## VOCE EU.13, LA RIVELAZIONE DEL SEGNO

**APERTA IN ATTESA DI VERIFICA**: prodotta e agganciata (commit `8b9a581a`), la prova `il_segno_si_rivela_la_prima_volta_test.dart` (629) misura la prima apertura delle sei tradizioni (figura quasi trasparente al primo fotogramma, piena dopo 1,7 secondi) e la seconda gia' al suo posto. **Sul Realme l'animazione non si vede**: le tre scale delle animazioni del sistema sono a 0 (impostazione del telefono che non si cambia), Flutter lo legge come Riduci Movimento e la testa compare intera, come la voce vuole per chi ha tolto il movimento (`eu13_vedica_testa_riduci_movimento.jpg`, `eu13_rivelazione_vedica_prima_volta.mp4`, fotogrammi tutti uguali). La vede chi ha le animazioni accese: il fondatore sul suo telefono.

DOMANDA: "quando l'utente fa click per la prima volta su vedica o cinese o altro, serve un'animazione di rivelazione del segno, non possono comparire di botto."

## VOCE EU.14, L'INTERPRETAZIONE VERA E NON RIPETITIVA: LE PROVE

**APERTA IN ATTESA DI VERIFICA**: misurata e scritta, aspetta l'Architetto. Le ripetizioni in novanta giorni sono zero (`docs/collaudo/EU/ripetizioni_90_giorni.txt`: voci del Giorno tornate entro trenta giorni 0, con e senza carta; voci della Settimana, del Mese e dell'Anno 0; frasi uguali fra periodi 0; fasce diverse dal livello 0, su 12.240 schede), il linguaggio di ogni tipologia e' quello dei dodici corpora. **La verita' delle interpretazioni no**: delle 759 affermazioni dei "Da dove viene" e delle note del metodo, 671 hanno una fonte dichiarata e **88 no** (`docs/collaudo/EU/affermazioni.md`, una per una). Si chiude quando l'Architetto le ha verificate o tolte.

DOMANDA: "IMPORTANTISSIMO: VERIFICA CHE L'INTERPRETAZIONE SIA REALE E NON INVENTATA E CHE NON SIA RIPETITIVA. Voglio moltissime combinazioni in modo che non cinsiano ripetizioni almeno per 3 mesi, fai i calcoli esatti e usa linguaggio adatto e consono per ogni tipologia di oroscopo."

## VOCE EU.15, LA LUNGA PER CHI NON HA IL PIANO: 50 EOS

**CHIUSA.** Vista sul Realme il 1 ottobre 2026 al Viandante: il lucchetto della Lunga apre le due strade (`eu15_viandante_le_due_strade.jpg`), i 50 Eos aprono la Lunga dell'Oroscopo occidentale del giorno per la giornata e le quattro schede (`eu15_viandante_lunga_aperta_2150_eos.jpg`, `eu15_viandante_lunga_aperta_paragrafi.jpg`: da 2.200 a 2.150 Eos, quattro paragrafi). Vedica e Cinese restano dei piani. Dopo le parole del fondatore della sera ("Non chiamarla la lunga di oggi con l'iniziato, ma abbonati per avere sempre l'oroscopo completo"), il foglio invita prima ad abbonarsi, col pulsante pieno, e sotto agli Eos solo per oggi: misurato in `la_lunga_si_apre_con_gli_eos_test.dart` (630); sul Realme quel foglio non si puo' aprire il 1 ottobre, perche' l'oroscopo completo di oggi e' gia' comprato.

DOMANDA: tabella della voce ES.06, approvata dal fondatore: "Approvo tutto."; domanda girata al fondatore il 30 settembre: "Chi può scegliere la profondità Lunga?", risposta: "Premium più Eos".
PROVA: docs/collaudo/EU/realme/eu15_viandante_lunga_aperta_2150_eos.jpg
MISURA: strade per la Lunga al Viandante, prima 1 (il piano), dopo 2 (50 Eos o abbonamento); Eos dal Realme, prima 2.200, dopo 2.150; paragrafi dopo l'acquisto, 4 su ognuna delle 4 schede; parole che chi legge non conosce nel foglio ("Lunga", nomi dei piani), prima 2, dopo 0

## PARTE 2, LE VOCI DELL'ARCHITETTO

## VOCE EU.16, LA STESSA FRASE IN GIORNO, SETTIMANA E MESE

**CHIUSA.** I paragrafi della Settimana, del Mese e dell'Anno vengono dai loro corpora e non riprendono le frasi del Giorno (EU Aggiunta, commit `67ca80b7`); visti sul Realme il Giorno, la Settimana, il Mese e l'Anno dello stesso giorno nell'Occidentale (`eu01_occidentale_giorno_breve_1.jpg`, `eu08_settimana_lunga_1.jpg`, `eu11_eu18_mese_griglia_2.jpg`, `eu01_anno_occidentale_1.jpg`). Guardia `le_frasi_non_si_ripetono_fra_i_periodi_test.dart` (625).

DOMANDA: dall'Architetto, sulle catture del fondatore; rilievo del fondatore "evitare ripetizioni".
PROVA: docs/collaudo/EU/regola_a_frasi_fra_i_periodi.txt
MISURA: frasi uguali fra periodi dello stesso giorno, dopo 0 su 306 coppie di periodi (rossa con 1.170 frasi uguali col Mese che prende la voce della Settimana); frasi uguali fra il Giorno e un altro periodo in novanta giorni, 0

## VOCE EU.17, IL LIVELLO E IL TESTO DICONO LA STESSA COSA

**CHIUSA.** Ogni scheda viene da una voce della fascia del suo livello (Favorevole 4 e 5, In equilibrio 3, In salita 2). Visto sul Realme: la Generale del Giorno a 2 su 5 con la voce "Pelle sottile" (fascia In salita), l'Amore a 4 su 5 con "Un complimento preciso" (Favorevole), la Fortuna a 3 con "Una sola offerta" (In equilibrio). Guardia `il_livello_e_il_testo_dicono_lo_stesso_test.dart` (626).

DOMANDA: dall'Architetto, sulle catture del fondatore.
PROVA: docs/collaudo/EU/livello_e_testo.txt
MISURA: schede con un paragrafo di una fascia diversa dal livello, dopo 0 su 1.476; schede del Giorno fuori fascia in novanta giorni, 0 su 12.240

## VOCE EU.18, IL TITOLO ANCHE SULLE SCHEDE DEL MESE

**CHIUSA.** Visto sul Realme il 1 ottobre 2026: le schede del Mese hanno il titolo sopra il dominio ("Sere più corte", "Domeniche a rotazione"), dal corpus del Mese dell'Architetto (`eu11_eu18_mese_griglia_1..3.jpg`).

DOMANDA: dall'Architetto, sulle catture del fondatore; estende il rilievo del fondatore della voce EU.08.
PROVA: docs/collaudo/EU/realme/eu11_eu18_mese_griglia_1.jpg
MISURA: schede del Mese col titolo, prima 0 su 4, dopo 4 su 4 a video

## VOCE EU.19, IL NOME DEL SEGNO SOTTO I CONTATORI

**CHIUSA.** Visto sul Realme il 1 ottobre 2026: il nome grande "KUMBHA (ACQUARIO)" che scorre sotto la barra in alto quasi sparisce dietro il velo, e i contatori "12", "ONLINE 1" e "2.200" si leggono interi (`eu19_vedica_nome_sotto_i_contatori.jpg`), commit `7bcf84fe`.

DOMANDA: dall'Architetto, sulle catture del fondatore.
PROVA: docs/collaudo/EU/regola_a_contatori.txt
MISURA: velo della barra, prima 72 per cento, dopo 92; contrasto peggiore dei contatori sul colore piu' chiaro che puo' scorrere sotto, prima 4,6, dopo 9,3 su 24 coppie
