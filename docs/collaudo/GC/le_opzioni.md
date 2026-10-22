# Ordine GC, le opzioni provate sul Realme

Simulazione da persona (FZ.09) e del bambino (GA.09), 22 ottobre 2026, dalle
20:56 alle 21:40. Telefono di collaudo Realme 767f596c, app vera in rilascio
costruita dal commit `19bf1f36` (prima giro) e poi con le cure trovate qui
(secondo giro), account di collaudo sul piano Viandante. Le catture stanno in
`docs/collaudo/GC/simulazioni/catture/`, il piano scritto prima di cominciare
in `docs/collaudo/GC/simulazioni/piano.md`.

**Spese.** Una sola lettura vera di Gemini, la Stesa a una carta, col si' del
fondatore in chat (stima 0,002 euro). L'Oracolo del Viandante legge dal corpus
e non chiama il modello. Nessuna domanda ai Maestri.

**Dati dell'account di collaudo.** Usare l'app scrive sul server cio' che ogni
persona scrive usandola: la consultazione dell'Oracolo del giorno, la stesa
del giorno e il traguardo "Le tre carte" che si e' aperto da se' dopo la
Stesa e ha accreditato 10 Eos (da 145 a 155). Nessun Eos speso, nessun piano
cambiato: il riscatto della consultazione in piu' (100 Eos) e' stato visto e
non toccato.

## Il bambino: le tre domande appena aperta la funzione

| Funzione | Che cos'e'? | Che cosa devo fare adesso? | Che cosa otterro'? |
|---|---|---|---|
| Oracolo degli Angeli | "Oracolo degli Angeli" nella barra, Medora davanti a una scala di luce, un tavolo vuoto: gli angeli rispondono a una domanda | Il riquadro "La tua domanda" dice "Scrivi la tua domanda agli angeli", sotto i temi Amore, Lavoro, Famiglia; il mazzo grigio dice "Il mazzo si apre quando affidi la tua domanda" | Le carte degli angeli sul tavolo e una risposta: lo dice la riga di guida del mazzo ("Scegli la prima carta, cosa fare: la porta il tuo Angelo Custode") e il pulsante "Avvia la lettura" |
| Stesa di Tarocchi | "Stesa di Tarocchi" nella barra, Medora con le carte, il tappeto | "Scegli la tua stesa" in un riquadro e "Scegli tre carte dal ventaglio" sopra il ventaglio; "Oggi hai 1 stesa" | "Scegli una carta dal ventaglio, poi premi qui" sotto "Leggi le carte": le carte lette |

Nessuna risposta manca. Il bambino che tocca il ventaglio grigio dell'Oracolo
prima della domanda non ottiene niente e legge perche' (la riga sopra il
mazzo).

## Oracolo degli Angeli

| Opzione | Esito | Cattura |
|---|---|---|
| Filmato d'ingresso lasciato finire | 10 s interi: carte alate a 3 s, scala che si accende a 7 s, tavolo vuoto alla fine; fermo sull'ultimo fotogramma | `o_01_filmato_3s_7s_fermo.jpg` |
| Riquadro della domanda durante il filmato | compare a filmato finito, in dissolvenza (regola permanente FXA.08, "sopra il video solo il video") | `o_01_filmato_3s_7s_fermo.jpg` |
| Ordine sotto il tavolo | domanda, Quante carte e Profondita', mazzo grigio coi gesti, pulsante: in quest'ordine | `o_02_sotto_il_tavolo.jpg` |
| Tema Lavoro, dieci domande, scelta di una | la tendina si chiude alla scelta, la domanda scelta resta nel campo, la freccia di invio si accende | `o_03_tendina_aperta_e_chiusa.jpg` |
| Freccia di invio | domanda affidata, il mazzo si accende con la guida della prima carta | `o_04_affidata.jpg` |
| Carta toccata dal ventaglio | vola al posto del Custode; **difetto D1** (sotto) | `o_05_prima_carta.jpg` |
| Seconda e terza carta | al Cuore e all'Intelletto, la guida cambia a ogni carta, poi "Le tre carte sono sull'altare. Quando vuoi, avvia la lettura." | `o_06_tre_carte.jpg` |
| Avvia la lettura | la domanda sale, Medora riflette, suono, la carta del Custode si gira (le altre due restano coperte nell'assaggio), le carte si alzano con Fare, Sentire, Capire; **difetti D3 e D5** (sotto) | `o_07_lettura.jpg`, `o_08_alzata.jpg` |
| Responso | Stesa a tre carte, le carte uscite, la scala col gradino del Custode acceso, titolo, paragrafo, Cosa fare adesso, la riga dell'assaggio | `o_09_responso.jpg` |
| Bolla della carta | medaglione, carta, segno dipinto del coro con la parola chiave, Chi e', dalla tradizione, "Il suo messaggio per te" chiuso | `o_10_bolla.jpg` |
| Leggi il suo messaggio | il paragrafo si apre, alla stessa misura del paragrafo principale (misurato: stesso corpo, 20 punti) | `o_11_messaggio_aperto.jpg` |
| Tocco su una carta alzata | si apre il foglio della carta: ruolo, carta, numero e nome, coro, tradizione, messaggio; **difetto D4** (sotto) | `o_12_foglio.jpg` |
| Chiudere il foglio | col tasto indietro e col pulsante "Chiudi" in fondo; tirato su occupa lo schermo intero e non resta spazio fuori da toccare | `o_12_foglio.jpg` |
| L'angelo dell'ora e il messaggio di oggi | solo dopo la lettura, in fondo | `o_13_angelo_dell_ora.jpg` |
| Affida una nuova domanda | torna alla domanda vuota, il filmato non riparte | |
| Profondita' Lunga sul Viandante | lucchetto "Dall'Iniziato" nella tendina; il tocco apre l'invito "La risposta lunga e' dell'Iniziato" con "Non ora" e "Vedi i piani" | `o_14_lunga_col_lucchetto.jpg` |
| Vedi i piani | apre la pagina dei piani; il tasto indietro torna all'Oracolo con tutto com'era | |
| Quante carte, Una carta | la tendina passa a "Una carta" | `o_15_una_carta.jpg` |
| Domanda scritta a mano e affidata, seconda consultazione del giorno | l'invito "Le consultazioni di oggi sono finite" con il riscatto a Eos e i piani: la stesa a tre carte ha contato come consultazione (GC.17). La stesa a una carta sul telefono resta da vedere: il giorno lo decide il server, spostare la data del telefono non basta | `o_16_limite.jpg` |

## Stesa di Tarocchi

| Opzione | Esito | Cattura |
|---|---|---|
| Filmato saltato col tocco | Medora ferma con la mano al cuore e l'altra verso il tavolo; la scena parte dal bordo alto, sotto la barra semitrasparente | `s_01_filmato_e_salto.jpg` |
| Scelgo poi scrivo | la tendina torna "Nessuna, tocca per sceglierne una", in corsivo | `s_02_scelgo_poi_scrivo.jpg` |
| Scrivo poi scelgo | il testo scritto si cancella, resta "Una scelta o un bivio"; nell'elenco nessuna spunta finche' la tendina e' vuota | `s_03_scrivo_poi_scelgo.jpg` |
| Scrivo e cancello | torna la domanda scelta di prima, mai due insieme | `s_04_scrivo_e_cancello.jpg` |
| Tipo di stesa | Quattro carte col lucchetto "Dall'Iniziato", Dieci carte "Dall'Adepto" | `s_05_tipo_di_stesa.jpg` |
| Una carta, scelta dal ventaglio | la carta va sul tavolo, "Leggi le carte" si accende | `s_06_una_carta.jpg` |
| Leggi le carte | Medora riflette; **difetto D2** (sotto); poi il traguardo "Le tre carte" si apre da se' sopra il responso | `s_07_lettura.jpg` |
| Responso a una carta | la carta uscita, il colpo d'occhio con i soli Arcani Maggiori accesi (1 su 1), il titolo con la domanda, il consiglio, Cosa fare adesso; nessun secondo blocco per la stessa carta | `s_08_responso.jpg` |

## I difetti trovati e la loro cura

| | Difetto | Padre | Cura |
|---|---|---|---|
| D1 | Oracolo: dopo l'affido la pagina scende fino al mazzo e il tavolo esce dallo schermo; la carta toccata vola dove la persona non la vede | ordine GC voce GC.09 (il mazzo coi gesti sotto le opzioni, scorrimento sul riquadro intero) | lo scorrimento porta in fondo alla finestra il solo ventaglio: il tavolo resta in vista sopra |
| D2 | Riflessione di Medora: "il filo che lega le tre carte" e "la carta del Presente contro le altre due" sopra la stesa a una carta e nell'Oracolo, che non ha una carta del Presente | ordine P sezione B (commit `d45e7d66`, le righe nate per tre carte), aggravato da GA.01 (le stese a una, quattro, dieci carte) e da GC.13 (la stessa attesa nell'Oracolo) | le righe dipendono dalle carte sul tavolo e dall'arte (`AttesaDiMedora.righePer`); prova nuova vista rossa |
| D3 | Oracolo: le carte alzate con Fare, Sentire, Capire restano in vista meno di mezzo secondo prima che la pagina scenda al responso | ordine GC voce GC.14 | sosta di due secondi e mezzo sulle carte alzate prima dello scorrimento |
| D4 | Il foglio della carta mostra la carta grande coi cartigli vuoti: niente numero, niente nome | ordine GC voce GC.14 | il foglio usa la stessa carta del tavolo, coi cartigli scritti in Flutter |
| D5 | Il rilievo azzurro del Maestro su "Quante carte", che non e' la scelta che cambia il responso | ordine GC voce GC.09 | tolto: il rilievo resta alla domanda (ordine BV voce 05) |
| D6 | Nel paragrafo dell'assaggio dell'Oracolo per Nithhaiah la stessa idea due volte ("le intuizioni arrivano quando smetti di inseguirle", poi "l'intuizione arriva quando smetti di inseguirla") | ordine GA voce GA.06 (commit `9d53677a`, le frasi del corpus per angelo e famiglia) | non curato in quest'ordine: e' il corpus, che rompe lontano; proposto fra le migliorie del rapporto |

## La richiesta del fondatore durante il collaudo

Alle 21:30, guardando la cattura della prima carta sul tavolo: *"Devi alzare
il selettore delle Domande subito sotto il piano dove atterrano le carte,
diminuire lo spazio tra i selettori di domanda, carte e profondità e
riquadro delle carte da scegliere e possibilmente ridurre l'altezza di ogni
selettore bolla in modo che quando l'utente sceglie le carte, sia visibile
anche il piano dove vanno a poggiare le carte scelte."* Fatto: la scena
dell'Oracolo si taglia sul bordo d'oro del piano (riga 1725 del fotogramma,
misurata), gli spazi fra domanda, opzioni e mazzo scendono da 12 a 8 punti,
le bolle di Quante carte e Profondità perdono 10 punti d'aria (da 7 a 3 sopra e sotto, da 2 a 0 fra titolo e voce). Prova:
`test/gc_l_oracolo_degli_angeli_test.dart`, gruppo "il tavolo resta in vista
mentre si scelgono le carte", sulla finestra vera del Realme: a 360 per 690
punti il posto delle carte sta fra 194 e 244 punti (la barra finisce a 56) e
il ventaglio arriva a 690; col layout di prima il posto stava fra 16 e 66,
sotto la barra (Regola A, `docs/collaudo/GC/regola_a.txt`, riga 23).

## Il secondo giro, con le cure (22:00)

Build con le cure D1-D5 e la richiesta delle 21:30. Il Viandante aveva gia'
usato la consultazione e la stesa del giorno (il giorno lo decide il server):
in questo giro si e' visto cio' che non chiede una lettura. Il volo della
carta, la sosta sulle carte alzate e il foglio coi cartigli sono provati
dalle prove a video; sul telefono restano da vedere con una consultazione
nuova (passo manuale nel rapporto).

| Opzione | Esito | Cattura |
|---|---|---|
| Oracolo aperto, filmato finito | la domanda comincia subito sotto il bordo del tavolo, le bolle sono basse, nessun rilievo azzurro | `r2_01_oracolo_compatto_e_tavolo_in_vista.jpg` |
| Oracolo scorso fino al mazzo | il piano del tavolo e il ventaglio stanno insieme a schermo | `r2_01_oracolo_compatto_e_tavolo_in_vista.jpg` |
| Filmato dell'Oracolo, cinque aperture | dal tocco all'ultimo movimento della scena 10,41, 9,52, 9,39, 9,46 e 9,57 secondi (il file dura 10,0; la misura parte dal cambio di schermata e si ferma all'ultimo fotogramma che si muove a vista) | `docs/collaudo/GC/gc07_cinque_aperture.txt` |
| Stesa, filmato lasciato finire | lo stesso fotogramma del salto: Medora con la mano al cuore e l'altra verso il tavolo; differenza media di luminanza 2,1 su 255 fra le due catture (le stelle e la candela) | `r2_02_stesa_salto_e_fine_naturale.jpg` |
| Sinastria Evolutiva | la scena parte dal bordo alto, sotto la barra semitrasparente, durante il filmato e a scena ferma | `r2_03_sinastria_dal_bordo_alto.jpg` |

## Le decisioni previste e non provate sul telefono

Dal piano scritto prima di cominciare (`docs/collaudo/GC/simulazioni/piano.md`)
tre decisioni non sono state provate sul Realme, perche' tutte chiedono una
consultazione o una stesa nuova e il Viandante aveva usato quelle del giorno:
la 6 (tornare indietro a meta' girata delle carte), la 9 nella parte del
cambio da una carta a tre a meta' scelta (provato a video,
`test/gc_l_oracolo_degli_angeli_test.dart`, gruppo GC.09) e la 12 nella parte
della rete spenta a meta' lettura. Restano per il giro di domani (passo
manuale 2 del rapporto).

## Le anteprime

Dove il telefono di collaudo non puo' arrivare oggi (la stesa a tre carte e
la consultazione a una carta erano gia' state usate; la Lunga si apre
dall'Iniziato e l'account e' Viandante) le catture vengono dalla schermata
vera, coi caratteri veri, in una prova a video con la lettura finta (nessuna
chiamata al modello): `docs/collaudo/GC/anteprime/stesa_tre_carte.jpg`,
`oracolo_una_carta_breve.jpg`, `oracolo_una_carta_lunga.jpg`,
`oracolo_tre_carte_lunga.jpg`. I quadratini al posto di due righe della bolla
sono il carattere che manca nell'ambiente di prova, non nell'app.

## Il terzo giro, con l'Illuminato in demo (23:30-23:55)

Il fondatore, in chat: *"perché non passi tu ad illuminato e così sei a
posto?"*. Attivato dalla pagina dei piani ("Scegli l'Illuminato", poi
"Attiva in Demo": nella demo il pagamento non e' integrato), confermato dal
Borsellino (21 domande, 5 stese, 1 stesa a dieci carte). L'attivazione in
demo non resta dopo una reinstallazione dell'app: la build 2316 l'aveva
persa, e la consultazione di questo giro e' stata letta dal corpus del
Viandante.

| Opzione | Esito | Cattura |
|---|---|---|
| Affido della domanda | il tavolo resta tutto in vista sopra il ventaglio (cura D1) | `r3_02_affido_tre_carte_e_cambio.jpg` |
| Tre carte scelte | le tre carte sul tavolo, a schermo insieme al ventaglio | `r3_02_affido_tre_carte_e_cambio.jpg` |
| Cambio da tre a una carta a meta' scelta | le carte tornano nel mazzo e la frase lo dice: "Hai cambiato stesa: le carte scelte tornano nel mazzo, sceglierne una" | `r3_02_affido_tre_carte_e_cambio.jpg` |
| Volo della carta del momento | dal ventaglio al centro del tavolo in 0,63 secondi, tavolo a schermo | `r3_01_volo_della_carta.jpg` |
| Lettura a una carta | riflessione con le righe nuove ("Medora ascolta che cosa porta l'angelo della tua carta"), girata, carta in piedi con "La carta del momento" per circa tre secondi, responso | `r3_03_lettura_a_una_carta.jpg` |
| Tocco sulla carta in piedi | il foglio col numero 19 e il nome Leuviah nei cartigli (cura D4) | `r3_04_carta_in_piedi_e_foglio.jpg` |
| Croce Celtica sull'app vera | dieci carte, lettura completa, app viva, nessuna chiusura | `r3_05_croce_celtica_app_vera.jpg`, `docs/collaudo/GC/gc01_app_vera.txt` |

Le decisioni 6 e 12 del piano (tornare indietro a meta' girata, rete spenta a
meta' lettura) restano non provate sul telefono: chiedono una lettura in
piu' e le letture del giorno erano finite.
