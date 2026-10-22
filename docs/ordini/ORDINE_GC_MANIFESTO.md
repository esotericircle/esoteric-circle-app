# MANIFESTO DELL'ORDINE GC, I CINQUE DIFETTI DELLA STESA DI TAROCCHI, LE CORREZIONI DELL'ORACOLO DEGLI ANGELI, IL LIVELLO VISIVO DEI DUE RESPONSI E LA PROFONDITÀ LUNGA

Testo dell'ordine, parola per parola: `docs/ordini/ORDINE_GC_TESTO.md` (copia
di `D:\Clienti Roogly\Rituali Cartomanzia\App\ORDINE_GC_Esoteric_Circle.md`),
con l'aggiunta del filmato v2 dell'Oracolo data in chat il 22 ottobre 2026.
Rapporto: `docs/ordini/RAPPORTO_ORDINE_GC.md`. Una voce CHIUSA porta sotto di
se' DOMANDA, PROVA e MISURA; una voce APERTA dice che cosa aspetta e porta le
sue prove. La simulazione da persona (FZ.09) e quella del bambino (GA.09) sul
Realme sono in `docs/collaudo/GC/le_opzioni.md` e
`docs/collaudo/GC/simulazioni/`. La Regola A di ogni guardia nuova sta in
`docs/collaudo/GC/regola_a.txt`: ventitré innesti, uno alla volta, tutti
rossi.

GC.01 e' chiusa con la misura del banco per decisione del fondatore (22
ottobre 2026, in chat: "Chiudi col banco") e poi misurata anche sull'app
vera, col piano Illuminato attivato in demo come il fondatore ha suggerito.
GC.12 e GC.14 sono state viste sul Realme la stessa sera. Resta aperta una
voce. Prima della correzione serale restavano aperte GC.12 e GC.14 aspettano di essere viste
sul Realme con una consultazione nuova, dopo le cure trovate nella
simulazione; GC.20, la consegna, si chiude col verde di GitHub sul commit
finale.

VOCI_TOTALI: 32
VOCI_CHIUSE: 31
VOCI_APERTE: 1
VOCI_DA_FARE: 0
VOCI_PREMESSA_CADUTA: 0
VOCI_DIVIETO: 0

## VOCE GC.01

**CHIUSA.** Chiusa con la misura del banco in rilascio sul Realme per
decisione del fondatore, 22 ottobre 2026, alla domanda se dare un account
Adepto al telefono di collaudo: *"Chiudi col banco"*. Due cause trovate con la misura sul Realme
e curate alla radice. Prima: ogni carta dei Tarocchi si decodificava
dall'arte piena (853 per 1280) anche larga cinquanta punti; ora si decodifica
alla misura in cui si vede, in tre gradini (`TarotCardArt.gradinoPer`). PADRE:
ordine FL voce 05 e ordine CO voce 06. Seconda: la girata, la fioritura e
l'alzata ricostruivano l'intera schermata col responso sotto, un fotogramma
da 130 a 190 millisecondi di costruzione per carta; ora cambiano solo il
tavolo (`_ilTavoloCambia`). PADRE: ordine FL voce 05, aggravato da GA.03. La
chiusura dell'app non si e' riprodotta sul banco in nessuna misura.

DOMANDA: "La stesa a 10 carte, al click su pulsante \"leggi le carte\" rallenta tantissimo, va a scatti e poi manda in crash l'app che si chiude da sola."
PROVA: `docs/collaudo/GC/gc01_la_croce_celtica.md`
MISURA: stesa a dieci, PSS di picco da 280 a 220 MB, memoria grafica da 140 a 96 MB, fotogrammi oltre 100 ms da 16 a 3, il piu' lungo da 300 a 200 ms, fotogrammi disegnati nelle finestre della girata da 51-61 a 98-106 ogni due secondi; ricostruzioni della schermata intera mentre le dieci carte si girano da 13 a 1 (`test/gc_la_stesa_di_tarocchi_test.dart`, soglia 3); stese da una, tre e quattro carte, nessuna delle quattro grandezze peggiora

Il fondatore poi, in chat: *"perché non passi tu ad illuminato e così sei a
posto?"*. Con l'Illuminato attivato in demo la Croce Celtica e' stata letta
sull'app vera (build 2316): processo vivo, nessuna chiusura, memoria da 474 a
490 MB, 2 fotogrammi oltre 100 ms, il piu' lungo 200
(`docs/collaudo/GC/gc01_app_vera.txt`, cattura
`docs/collaudo/GC/simulazioni/catture/r3_05_croce_celtica_app_vera.jpg`). Una
sola volta e non cinque: la stesa a dieci e' una al giorno e non si
ricompra.

## VOCE GC.02

**CHIUSA.** Nella Stesa la scena parte dal bordo alto dello schermo e passa
sotto la barra del titolo semitrasparente (`IlTavoloDiMedora.cieloSopra`). Lo
stesso nella Sinastria Evolutiva. Controllate le altre funzioni con scena:
nell'Oracolo provvede GC.10; il Calendario Lunare e il Respiro della Luna non
hanno un'immagine dipinta sopra la scena da far scorrere sotto la barra
(premessa parziale, nel rapporto) e non sono cambiati. Lo scorrimento del
testo sotto la barra non si tocca.

DOMANDA: "La barra in alto del titolo deve essere semitrasparente in modo da fare vedere il video animazione sotto"
PROVA: `docs/collaudo/GC/simulazioni/catture/s_01_filmato_e_salto.jpg`
MISURA: fascia di cosmo fra la barra e la scena, da 76,9 punti (innesto del codice di prima) a 0 a 360 e a 390 punti (`test/nessuna_fascia_sotto_la_barra_della_stesa_test.dart`); funzioni con la scena sotto la barra sul Realme 2 su 2 cambiate (Stesa e Sinastria Evolutiva, `docs/collaudo/GC/simulazioni/catture/r2_03_sinastria_dal_bordo_alto.jpg`)

## VOCE GC.03

**CHIUSA.** Il salto e la fine naturale arrivano allo stesso fotogramma: il
fotogramma 189 del filmato del mazzo (`stesa_ultimo_fotogramma_v1.webp`),
Medora con una mano al cuore e l'altra verso il tavolo, mostrato nello stesso
riquadro del filmato al posto della posa scontornata. PADRE: ordine FS
aggiunta (la frenata sulla posa scontornata).

DOMANDA: "Quando faccio click per skippare il video introduttivo, la scena si deve fermare allo stesso frame con Medora che ha una mano al cuore e l'altra che indica il tavolo."
PROVA: `docs/collaudo/GC/simulazioni/catture/r2_02_stesa_salto_e_fine_naturale.jpg`
MISURA: differenza media di luminanza fra la cattura dopo il salto e quella dopo la fine naturale, sul Realme, 2,1 su 255 (le stelle e la candela); dopo il salto, al posto della posa scontornata il fotogramma 189 del filmato, nello stesso riquadro (`test/la_scena_della_stesa_e_un_filmato_test.dart`)

## VOCE GC.04

**CHIUSA.** Vale l'ultima via usata: scritta una domanda, la scelta si
annulla e la tendina dice "Nessuna, tocca per sceglierne una", in corsivo e
senza spunta nell'elenco; scelta una domanda, il testo scritto si cancella;
cancellato il testo, torna la domanda scelta. Nel responso entra solo quella
rimasta. L'Oracolo ha un campo solo, che le domande proposte riempiono: non
ha due vie da allineare.

DOMANDA: "se scelgo una domanda da quelle suggerite e scrivo anche la domanda, l'ultima è quella che conta e l'altra deve essere annullata tornando vuoto il campo, così da non confondere."
PROVA: `docs/collaudo/GC/simulazioni/catture/s_02_scelgo_poi_scrivo.jpg`
MISURA: sequenze provate 4 su 4 a video (`test/gc_la_stesa_di_tarocchi_test.dart`) e 3 su 3 sul Realme (scelgo poi scrivo, scrivo poi scelgo, scrivo e cancello); domande insieme nel riepilogo da 2 a 1

## VOCE GC.05

**CHIUSA.** La singola carta dei Tarocchi e' titolo e un paragrafo, senza
riquadro: la forma si scrive in un punto solo (`ResponsoInterpretato.comeSingola`)
e `IlResponsoInterpretato` non disegna il riquadro per la singola. Il
responso principale tiene la forma di GA.03. Regola in CLAUDE.md.

DOMANDA: "la singola Carta ha titolo e non ha il secondo paragrafo con riquadro"
PROVA: `docs/collaudo/GC/anteprime/stesa_tre_carte.jpg`
MISURA: singole carte con un riquadro, in ogni stesa, da 1 per carta a 0 (`test/gc_la_stesa_di_tarocchi_test.dart`, gruppo GC.05); prima e dopo: `docs/collaudo/GC/catture_del_fondatore/05_singola_carta_con_riquadro.jpg` e l'anteprima; stesa a una carta sul Realme, blocchi per la stessa carta 1 (`docs/collaudo/GC/simulazioni/catture/s_08_responso.jpg`)

## VOCE GC.06

**CHIUSA.** Sopra il titolo del responso principale le quattro piste dei
semi (fuoco, acqua, aria, terra, Golden Dawn) si riempiono con le carte
uscite, piu' il segno degli Arcani Maggiori (`LeBarreDeiSemi`); i simboli
sono i cinque dipinti del fondatore. Ogni carta ha la sua parola chiave
grande dal corpus e il paragrafo chiuso, che si apre al tocco
(`LaSingolaCheSiApre`). Con Riduci Movimento le piste sono gia' piene.

DOMANDA: "io noto che c'è troppo testo e infografica zero e ci sono delle regole per le risposte o responsi che indicano di inserire sempre un impatto visivo grafico pe rnon appensantire di testo e annoiare l'utente."
PROVA: `docs/collaudo/GC/simulazioni/catture/s_08_responso.jpg`
MISURA: responsi delle stese col colpo d'occhio sopra il titolo da 0 a 4 su 4 (`test/ogni_responso_apre_col_colpo_d_occhio_test.dart`); stesa a una carta sul Realme, Arcani Maggiori 1 su 1 e semi 0 su 1; simboli dipinti nel ramo 14 su 14 (`assets/img/simboli/`)

## VOCE GC.07

**CHIUSA.** Col filmato v2 (10,0 secondi, 1080 per 1920, 24 fotogrammi al
secondo, il tavolo vuoto alla fine) il lettore suona il filmato intero e si
ferma sull'ultimo fotogramma; nessun istante di arresto scritto nel codice.
PADRE: ordine GA voce GA.08 (il taglio a un istante fisso del v1). Il tocco e
lo scorrimento lo saltano e sfumano sullo stesso fotogramma finale.

DOMANDA: "1 il video introduttivo dura meno di un secondo."
PROVA: `docs/collaudo/GC/gc07_cinque_aperture.txt`
MISURA: durata del filmato a video sul Realme, cinque aperture, da meno di un secondo a 10,41, 9,52, 9,39, 9,46 e 9,57 secondi (file 10,0); eventi dell'app che lo chiudono prima della fine senza un tocco 0 (`test/l_oracolo_si_apre_senza_carte_test.dart`)

## VOCE GC.08

**CHIUSA.** All'apertura nessuna carta e nessun messaggio: l'angelo dell'ora
e il messaggio di oggi compaiono solo dopo la lettura, in fondo. Il v2 non
lascia carte sul tavolo.

DOMANDA: "2 all'apertura non si deve vedere la carta o messaggio del momento."
PROVA: `docs/collaudo/GC/simulazioni/catture/o_02_sotto_il_tavolo.jpg`
MISURA: pezzi di carta o di messaggio a Oracolo appena aperto da 2 (la carta del momento e il messaggio del giorno) a 0 (`test/gc_l_oracolo_degli_angeli_test.dart`, gruppo GC.08); sul Realme, dopo la lettura 1 riquadro con l'angelo dell'ora (`docs/collaudo/GC/simulazioni/catture/o_13_angelo_dell_ora.jpg`)

## VOCE GC.09

**CHIUSA.** Sotto il tavolo, dall'alto: la domanda, Quante carte con la
Profondita', il ventaglio grigio coi gesti Taglia, Mischia e Suono della
Stesa (`GestoDelMazzo`), il pulsante "Avvia la lettura". Il ventaglio si
accende quando la domanda e' affidata; il pulsante quando la domanda e'
affidata e le carte sono tutte scelte. Il cambio di numero a meta' scelta
azzera le carte e lo dice. Su richiesta del fondatore delle 21:30 la scena
si taglia sul bordo del piano e gli spazi sono piu' stretti, perche' il
tavolo resti in vista mentre si scelgono le carte.

DOMANDA: "3 all'apertura si deve vedere subito sotto il tavolo il riquadro delle domande che adesso è in alto. Subito Sotto la scelta tra 1 carta e 3 carte. Subito Sotto il riquadro (ancora non attivo, in grigio) con le carte da scegliere con i pulsanti mischia, taglia, suono. Subito sotto il pulsante \"avvia la lettura\" ancora non attivo"
PROVA: `docs/collaudo/GC/simulazioni/catture/r2_01_oracolo_compatto_e_tavolo_in_vista.jpg`
MISURA: elementi nell'ordine giusto 4 su 4, spenti all'apertura 2 su 2 (`test/gc_l_oracolo_degli_angeli_test.dart`, gruppo GC.09); a 360 per 690 punti, scelte le carte, il posto sul tavolo da sotto la barra (16 punti, barra a 56) a 194 punti, il ventaglio dentro la finestra (gruppo "il tavolo resta in vista")

## VOCE GC.10

**CHIUSA.** La scena sale di dieci pixel fisici, convertiti in punti col
rapporto di pixel del dispositivo: 3,33 punti sul Realme. La barra resta
semitrasparente e la scena passa sotto.

DOMANDA: "4 alza il video di 10 pixel, c'è troppo spazio tra la testa di Medora e la barra del titolo."
PROVA: `test/gc_l_oracolo_degli_angeli_test.dart`
MISURA: bordo alto della scena da 0 a -10 punti a densita' 1 e da 0 a -3,33 a densita' 3; la prima stesura della prova era cieca (leggeva la costante) ed e' stata rifatta sui dieci pixel del fondatore (`docs/collaudo/GC/regola_a.txt`)

## VOCE GC.11

**CHIUSA.** Scelta una domanda la tendina delle proposte si chiude; il
pulsante rotondo ha la freccia di invio della tastiera
(`Icons.keyboard_return_rounded`). Regola in CLAUDE.md.

DOMANDA: "5 nel selettore della domanda, quando la domanda viene scelta, la tendina con le domande sparisce. Cambia il simbolo del pulsante rotondo con il simbolo di \"invio\" ovvero la freccia che curva di enter della tastiera."
PROVA: `docs/collaudo/GC/simulazioni/catture/o_03_tendina_aperta_e_chiusa.jpg`
MISURA: tendine aperte dopo la scelta da 1 a 0, sul Realme e a video; simbolo del pulsante da stellina a freccia di invio

## VOCE GC.12

**CHIUSA.** La carta toccata vola dal suo posto nel
ventaglio al suo posto sul tavolo, col suono `carta.mp3` della Stesa, una
volta per volo. Sul Realme la carta arriva al suo posto, ma nel primo giro
il tavolo usciva dallo schermo mentre si sceglieva (difetto D1, padre GC.09):
curato portando in fondo alla finestra il solo ventaglio.

DOMANDA: "La stessa Carta che tocco deve volare dal mazzo alla sua posizione sul tavolo e ci deve essere il suo suono, quello usato dalla stesa dei tarocchi."
PROVA: `docs/collaudo/GC/simulazioni/catture/r3_01_volo_della_carta.jpg`
MISURA: carta in volo che parte dal dorso toccato e arriva al suo posto 3 su 3 a video (innesto senza suono: rossa); sul Realme il volo dura 0,63 secondi (da 4,10 a 4,73 nella registrazione) e il tavolo resta a schermo per tutto il volo, dove prima della cura D1 usciva dallo schermo

## VOCE GC.13

**CHIUSA.** Al tocco di "Avvia la lettura" la domanda sale, poi Medora
riflette con l'attesa della Stesa (`AttesaDiMedora`) e alla fine suona la
rivelazione (`rivelazione.mp3`), una volta. La riflessione nomina le carte
vere: nella simulazione diceva "le tre carte" e "la carta del Presente"
anche nell'Oracolo e sopra la stesa a una carta (difetto D2, padre ordine P
sezione B), curato.

DOMANDA: "7 dopo l'invio con il tap sul pulsante voglio un'animazione di riflessione come per la stesa di tarocchi e dopo effetto sonoro come per la stesa di tarocchi"
PROVA: `docs/collaudo/GC/simulazioni/catture/o_07_lettura.jpg`
MISURA: sequenza invio, riflessione, suono, girata nell'ordine; suoni della rivelazione per lettura 1 (innesto senza suono: rossa); righe della riflessione sbagliate sopra la stesa a una carta da 4 su 5 a 0 (`test/gc_la_stesa_di_tarocchi_test.dart`)

## VOCE GC.14

**CHIUSA.** Le carte si girano una alla volta col loro
suono, poi si alzano ingrandite con "Fare", "Sentire", "Capire" o "La carta
del momento"; il tocco su una carta in piedi apre il foglio della carta
(`LaCartaDellAngeloAperta`). Due difetti visti sul Realme e curati: le carte
in piedi restavano in vista meno di mezzo secondo (D3) e il foglio mostrava
la carta coi cartigli vuoti (D4), padre GC.14 di quest'ordine.

DOMANDA: "le carte si girano sul tavolo una alla volta con effetto sonoro e subito dopo si alzano in verticale ingrandendosi. Per la stesa a 3 sopra ogni carta c'è scritto \"fare\", \"sentire\", \"capire\", mentre per la stesa a 1 carta \"la carta del momento\". Se faccio click su una carta in verticale ottengo una schermata popup con la descrizione della carta angelo."
PROVA: `docs/collaudo/GC/simulazioni/catture/r3_04_carta_in_piedi_e_foglio.jpg`
MISURA: scritte giuste 3 su 3 e 1 su 1 (`test/gc_l_oracolo_degli_angeli_test.dart`); sosta sulle carte in piedi da meno di 0,5 a circa 3 secondi sul Realme (`docs/collaudo/GC/simulazioni/catture/r3_03_lettura_a_una_carta.jpg`, un fotogramma al secondo); cartigli scritti nel foglio da 0 a 2 (il numero 19 e il nome Leuviah)

## VOCE GC.15

**CHIUSA.** Il responso si apre come quello della Stesa: "Stesa a tre carte"
o "Stesa a una carta", le carte uscite, il colpo d'occhio, il titolo, il
paragrafo e il riquadro "Cosa fare adesso". Ogni bolla ha la carta, il
medaglione del ruolo e il titolo e un paragrafo, "Il suo messaggio per te",
senza riquadro. Nella stesa a una carta il simbolo e' quello dell'Oracolo
(`Icons.auto_stories_rounded`) e la bolla non ripete il messaggio.

DOMANDA: "il responso all'inizio scrive le carte uscite e poi i riquadri delle risposte. Subito mostra titolo del responso resoconto dell'estrazione seguita da descrizione in 2 paragrafi di cui il secondo in riquadro con titolo \"cosa fare adesso\" come da regole dei responsi. I riquadri delle singole carte riportano carta, simbolo e titolo e 1 paragrafo intitolato come adesso \"il suo messaggio per te\"."
PROVA: `docs/collaudo/GC/simulazioni/catture/o_09_responso.jpg`
MISURA: singole carte dell'Oracolo con un secondo paragrafo o un riquadro da 3 a 0 (`test/gc_l_oracolo_degli_angeli_test.dart`, gruppo GC.15); paragrafi del principale da 3 a 2; stesa a una carta, `docs/collaudo/GC/anteprime/oracolo_una_carta_breve.jpg`

## VOCE GC.16

**CHIUSA.** Dietro tutta la schermata dell'Oracolo il cosmo della Stesa
(`CosmosBackground`), fermo con Riduci Movimento. PADRE dello sfondo piatto:
ordine FU voce FU.02 (commit `e17fe576`, `backgroundColor: palette.deepest`,
la tinta piena della schermata).

DOMANDA: "10 lo sfondo è cosmico."
PROVA: `docs/collaudo/GC/simulazioni/catture/o_09_responso.jpg`
MISURA: schermate dell'Oracolo col cosmo dietro da 0 a 1 (`test/gc_l_oracolo_degli_angeli_test.dart`, gruppo GC.16); catture sul Realme col cosmo all'apertura, nella scelta e nel responso 3 su 3

## VOCE GC.17

**CHIUSA.** La stesa a una carta e' un angelo qualunque scelto dal ventaglio,
senza ruolo, al centro del tavolo e conta come una consultazione con lo
stesso contatore e gli stessi limiti di FU.10. Costo: una chiamata a Gemini
2.5 Flash-Lite con meno carte nella richiesta, quindi non oltre quello della
stesa a tre (0,00020 dollari in Breve, `tool/i_limiti_degli_annuali.py`).

DOMANDA: "3 la Carta singola corrisponde a una stesa a 1 carta e la sceglie l'utente. 4 conta come consultazione."
PROVA: `test/gc_l_oracolo_degli_angeli_test.dart`
MISURA: consultazioni contate per una stesa a una carta da 0 a 1 (innesto che conta solo la stesa a tre: rossa); ruoli assegnati alla carta del momento 0; sul Realme, dopo una consultazione del Viandante, invito del limite 1 (`docs/collaudo/GC/simulazioni/catture/o_16_limite.jpg`)

## VOCE GC.18

**CHIUSA.** Sopra il titolo la scala di luce dipinta della scena, coi gradini
che si accendono uno per carta nel colore del ruolo; nella stesa a una carta
il gradino di mezzo (`LaScalaDelResponso`). Nella bolla il segno dipinto del
coro con la parola chiave dei doni. I nove segni dei cori sono nel ramo.

DOMANDA: "io noto che c'è troppo testo e infografica zero"
PROVA: `docs/collaudo/GC/simulazioni/catture/o_10_bolla.jpg`
MISURA: responso dell'Oracolo col colpo d'occhio sopra il titolo da 0 a 1 (`test/ogni_responso_apre_col_colpo_d_occhio_test.dart`); gradini accesi uguali alle carte scoperte (innesto di un gradino solo: rossa); segni dei cori dipinti nel ramo 9 su 9

## VOCE GC.19

**CHIUSA.** Nel selettore dell'Oracolo la Profondita' con Breve e Lunga, lo
stesso controllo della Stesa, col piano letto da `RigaDelPiano.oracoloLunga`
(dall'Iniziato). La Lunga aggiunge due paragrafi solo al responso
principale, il secondo nel riquadro "Il salmo propiziatorio". Costo: la Lunga
era gia' nel caso peggiore dei limiti (600 gettoni d'uscita, 0,00032
dollari): i numeri dei piani restano sotto il 30 per cento del netto
(Illuminato mensile 30,0, il piu' alto).

DOMANDA: "vorrei l'opzione \"profondità\" come nella stesa tarocchi. Ovviamente sarà esclusiva solo per gli utenti premium a pagamento e se selezionata aggiungerà 2 paragrafi solo alla risposta principale di cui il secondo in riquadro con titolo che scegli tu e contesto adatto ovviamente"
PROVA: `docs/collaudo/GC/anteprime/oracolo_una_carta_lunga.jpg`
MISURA: paragrafi del principale nella Lunga da 2 a 4, delle singole carte 1; all'apertura approfondimenti chiesti 0 (innesto della Lunga automatica dal piano: rossa); lucchetto per il Viandante 1 (`docs/collaudo/GC/simulazioni/catture/o_14_lunga_col_lucchetto.jpg`); quota del costo sul netto, Illuminato mensile, 30,0 per cento prima e dopo

## VOCE GC.20

**APERTA IN ATTESA DI VERIFICA.** Manifesto, guardia del manifesto
(`test/ordine_gc_guard_test.dart`), rapporto, STATO_VIVO, registro delle
guardie (887) e CLAUDE.md con le regole permanenti di GC.05, GC.06 e GC.18,
GC.11 e GC.19. Le voci da GC.01 a GC.05 sono state eseguite in quest'ordine:
nessuna voce dell'ordine GB aggiunta era stata eseguita. Nessuna build per i
tester.

DOMANDA: "Consegna solo col verde di GitHub (verde.yml)."
PROVA: `docs/ordini/RAPPORTO_ORDINE_GC.md`
MISURA: voci del manifesto 20 su 20; guardie nuove 4, viste rosse 4; innesti della Regola A 23, rossi 23

ASPETTA: il verde di GitHub sul commit consegnato e la build ai tester, che il fondatore ha chiesto in chat la stessa sera: *"Alla fine dell'ordine, tutte le voci nessuna eccezione, consegna nuova build"*.

## VOCE GCA.01

**CHIUSA.** Decisione: si accetta il ripiego sul corpus; i tetti non si
alzano e l'istruzione non si allarga. Il tetto di 420 caratteri misurato da
FVA.02 non esiste piu': dall'ordine GA i paragrafi si misurano in parole (da
40 a 50, `LaFormaDelResponso.minimo` e `massimo`), regola permanente del
fondatore, e una risposta fuori misura si scarta intera e parla il corpus,
mai una troncata (GA.07). Il filtro delle parole vietate resta com'e',
`guari` compreso: legge per sottostringa e scarta anche un "guarire" detto in
senso figurato, ma il caso opposto, una promessa di guarigione mostrata,
costa piu' di un responso dal corpus, che e' scritto a mano e corretto. Il
30 per cento e' stato misurato coi tetti di allora: misurarlo di nuovo con la
forma GA chiede venti consultazioni vere (circa 0,004 euro), che non partono
senza il si' del fondatore; proposto fra le migliorie, non serve alla
decisione.

DOMANDA: "FU.04, cioè alzare i tetti, allargare il prompt o accettare il ripiego sul corpus nel 30 per cento dei casi"
PROVA: `docs/collaudo/FV/fva02_venti_consultazioni.txt`
MISURA: risposte del modello mostrate 14 su 20 coi tetti in caratteri di FVA.02; tetti in caratteri nel codice di oggi da 4 (titolo, riquadro, due approfondimenti) a 1 (il titolo, 80); filtro delle parole vietate invariato, 0 parole tolte; chiamate a pagamento per questa decisione 0

## VOCE GCA.02

**CHIUSA.** Decisione: la data del picco esatto (`IlMotoreLunare`) e' la data
definitiva della Luna piena e della Luna nuova in ogni punto dell'app.
Verificati i punti che le mostrano: Calendario degli eventi, Passaporto,
Collana, Respiro, avvisi del Respiro, promemoria del Lunario e Calendario
Lunare usano gia' il picco. Restava fuori il cielo di un periodo che il
Maestro legge (`lib/core/astro/il_cielo_per_il_maestro.dart:166`), che datava
la Luna al primo giorno in cui il nome della fase cambiava, dodici ore prima
del picco: curato in questo ordine, perche' e' lo stesso difetto di GB.11 e
il Maestro non puo' dire un giorno diverso dal Calendario. PADRE: ordine EV
(commit `d2e773ec`). Restano con un motore proprio, che per costruzione da'
lo stesso istante, la settimana dell'Oroscopo
(`lib/core/horoscope/la_settimana_del_cielo.dart:330`, bisezione al mezzo
minuto), l'invito del Maestro (`lib/core/maestro/consiglio_finale.dart:111`,
un conto in giorni) e il Pellegrinaggio
(`lib/core/cerchio/i_tempi_dei_giochi.dart:80`): non mostrano una data
diversa, non si toccano. Primo e ultimo quarto restano al giorno in cui
cominciano (DS.08), come GB.11 li ha lasciati.

DOMANDA: "la data della Luna (GB.11 ha portato alla data del picco esatto)"
PROVA: `test/gca02_il_maestro_data_la_luna_al_picco_test.dart`
MISURA: in un anno di eventi del Maestro, lune piene e nuove fuori dal giorno del picco da 4 su 25 a 0 su 25 (Regola A, `docs/collaudo/GC/regola_a.txt`, riga 25)

## VOCE GCA.03

**CHIUSA.** Decisione: la carta "Hai chiesto a ..." resta com'e' dopo GB.05.
La verifica dal vivo l'ha fatta Code il 23 ottobre 2026 sul Realme, con
l'Illuminato attivato in demo, una domanda vera a Medora e il confronto con
gli altri due Maestri (eccezione permanente dell'ordine GB per la
simulazione, CLAUDE.md, SPESE punto 3). Nella chat di Medora la carta dice
"Hai chiesto a Medora: «Devo cambiare lavoro entro fine anno?» / I pareri di
Medora, Calìgo e Aura. Tocca per leggerli". GB.05 e' verificata. Nella stessa
prova un difetto trovato e curato: il riscatto del confronto diceva "Riscatta
un confronto di sinastria" sul budget dei confronti fra i Maestri (PADRE:
ordine BG voce 05, commit `36a2131a`), ora "un confronto fra i Maestri", con
una guardia nuova (`test/ogni_riscatto_dice_la_cosa_giusta_test.dart`).

DOMANDA: "la carta 'Hai chiesto a ...'"
PROVA: `docs/collaudo/GC/simulazioni/catture/gca03_consulto_e_carta_hai_chiesto_a.jpg`
MISURA: carte "Hai chiesto a" viste dal vivo dopo un consulto vero da 0 (GB.05, tentativo fallito) a 1, coi tre pareri; domande vere scritte ai Maestri 1 (Medora) e confronti 1 (Calìgo, Aura e la sintesi)

## VOCE GCA.04

**CHIUSA.** Decisione: i limiti restano 3, 12, 17 e 21 domande al giorno
(Viandante, Iniziato, Adepto, Illuminato, `functions/src/budget.ts:114` e
`lib/core/entitlement/plan_catalog.dart:874`; non 18 e 22 come il testo
dell'aggiunta riporta dal 14 ottobre: l'ordine FE voce 20 li ha portati a 17
e 21). L'illimitato resta vietato. L'uscita di GB.06 resta. Al caso peggiore
il mensile sta sotto il 30 per cento del netto (Iniziato 26,8, Adepto 29,6,
Illuminato 30,0). Un difetto trovato: per l'annuale i piani promettono 11, 14
e 18 domande (il conto del costo e la card), ma il server non conosce il
ciclo e darebbe 12, 17 e 21, cioe' il 32,1, il 33,0 e il 32,1 per cento del
netto. PADRE: ordine FE voce 20 (commit `a2da1bb9`), che ha scritto i tetti
annuali nel conto e nella card senza un tetto annuale nel server. Non si cura
in questo ordine: il ciclo dell'abbonamento arriva al server solo col
pagamento vero, che nella demo non e' integrato (oggi nessuno ha un annuale),
e il server lo pubblica il fondatore (R3). Si scrive per l'ordine che
integra il pagamento.

DOMANDA: "il limite delle domande ai Maestri (GB.06 ha dato un'uscita)"
PROVA: `docs/costi/i_limiti_degli_annuali.txt`
MISURA: tetti giornalieri invariati 3, 12, 17, 21; quota del netto del mensile al caso peggiore 26,8, 29,6 e 30,0 per cento; dell'annuale col tetto del server 32,1, 33,0 e 32,1 per cento (conto rifatto con `tool/i_limiti_degli_annuali.py` e i tetti del server)

## VOCE GCA.05

**CHIUSA.** Decisione: il Diario dice l'anno. Sopra le dodici caselle del
livello anno c'e' l'anno scritto (era solo "Gen ... Dic", e dal 1 gennaio
non si capiva di quale anno fossero i mesi); la data della voce aperta e
delle carte custodite passa da "22/10/2026" alla forma in lettere dell'app,
"22 ottobre 2026" (`LinguaDegliEventi.dataConAnno`, la stessa di GB.07). La
navigazione fra gli anni (rivedere l'ottobre 2026 nel 2027) non c'e' ancora:
e' un controllo nuovo, proposto fra le migliorie.

DOMANDA: "il Diario senza anno"
PROVA: `test/i_ricordi_hanno_una_rotta_sola_test.dart`
MISURA: anni scritti sul livello anno da 0 a 1; date del Diario in lettere con l'anno da 0 su 3 punti a 3 su 3 (Regola A, riga 26)

## VOCE GCA.06

**CHIUSA.** Decisione: sul codice non resta niente. L'interruttore
`kProvaCrashlyticsAttiva` e' spento (`lib/core/diagnosi/prova_crashlytics.dart:28`),
l'invio di prova e' una volta sola e solo su iPhone, la guardia
`la_consegna_parte_senza_la_prova_di_crashlytics` impedisce di consegnare con
l'interruttore acceso, i simboli dSYM si caricano su Codemagic
(`codemagic.yaml:363`). Resta al fondatore il passo di GB.08: accendere
l'interruttore, fare una build iOS, installarla da TestFlight, aprire l'app,
guardare Crashlytics, spegnere. GB.08 resta aperta per quel passo.

DOMANDA: "Crashlytics su iPhone"
PROVA: `test/la_consegna_parte_senza_la_prova_di_crashlytics_test.dart`
MISURA: lavori sul codice rimasti 0; passi del fondatore 1 (quello di GB.08); interruttore acceso nel ramo 0

## VOCE GCA.07

**CHIUSA.** Decisione: i versetti di Martini restano letterali, con la loro
virgola: sono una citazione di un testo altrui del 1842, e cambiarli vuol
dire riscrivere la Scrittura. I precedenti delle 48 ancore dell'Oroscopo
(BD.07) e delle 36 frasi della Sinastria (CA) erano testi di casa. La deroga
c'e' gia' dall'ordine GA e il fondatore l'ha confermata in GB.12 (*"confermo
eccezione"*): `test/language_rule_test.dart` toglie solo il testo fra « »
delle righe `salmi_martini` di `i_riti_propiziatori_dati.dart` prima di
cercare la virgola, e guarda tutto il resto di lib come sempre. Nessun lavoro
nuovo.

DOMANDA: "i versetti di Martini con la virgola prima di 'e'"
PROVA: `test/language_rule_test.dart`
MISURA: righe della raccolta `salmi_martini` sotto la deroga almeno 72; testi di casa fuori dalla deroga con la virgola prima di "e" 0

## VOCE GCA.08

**CHIUSA.** Decisione: sul dominio Fortuna non resta niente da fare. GB.09
ha tolto la relazione dalla settima casa del corpus delle dodici case; il
corpus del percorso Giorno (`docs/corpus/eu/oroscopo_eu_occidentale_giorno.md`,
sezione Fortuna, righe 1356-1776) non nomina amore, partner, coppia o
sentimenti; l'unica parola vicina e' "relazioni" in senso generale (riga
1672, "Scegliere con misura protegge anche le relazioni"), che non parla di
coppia e resta.

DOMANDA: "il dominio Fortuna (GB.09 è chiusa)"
PROVA: `test/gb09_la_fortuna_non_parla_di_relazioni_test.dart`
MISURA: frasi del dominio Fortuna con parole di relazione romantica, nei due corpus, 0; costo 0 (l'Oroscopo non chiama il modello)

## VOCE GCA.09

**CHIUSA.** Decisione: la compatibilita' a tre livelli resta tolta e non si
costruisce. La premessa dell'aggiunta ("ancora nella matrice di
plan_catalog.dart") e' superata: la riga e' gia' uscita con FU.16 (lapidi a
`lib/core/entitlement/plan_catalog.dart:477` e `:1161`) e la guardia
`la_compatibilita_a_tre_livelli_non_si_promette` legge ogni stringa di lib.
Nessun codice realizza i tre livelli; la Sinastria evolutiva legge due cieli
veri in cinque capitoli, ed e' quella che il listino vende.

DOMANDA: "la compatibilità a tre livelli esclusiva dell'Illuminato, ancora nella matrice di plan_catalog.dart"
PROVA: `test/la_compatibilita_a_tre_livelli_non_si_promette_test.dart`
MISURA: righe della matrice con la compatibilita' a tre livelli 0 (da FU.16); promesse nelle stringhe di lib 0

## VOCE GCA.10

**CHIUSA.** Decisione: il 92 per cento resta. Non e' una larghezza: e'
l'opacita' del velo dietro la striscia dell'identita' (volto, Online, Eos),
`lib/features/shell/barra_dell_identita.dart:78`, `velo = 0.92`, voluta
dall'ordine EU voce 19 perche' i contatori si leggano sul testo che scorre
sotto (contrasto peggiore da 4,6 a 9,3). La regola delle barre del titolo
semitrasparenti (FY.20, velo 0,6) vale per le barre che portano un titolo; la
striscia non ne porta. La sorveglia `test/i_contatori_si_leggono_sempre_test.dart`
(velo almeno 0,9 e contrasto almeno 4,5 su 24 coppie).

DOMANDA: "la striscia dell'identità al 92 per cento"
PROVA: `test/i_contatori_si_leggono_sempre_test.dart`
MISURA: velo invariato a 0,92; contrasto peggiore dei contatori 9,3 su 24 coppie, soglia 4,5

## VOCE GCA.11

**CHIUSA.** Decisione: resta "Riscatta ... · N Eos". "Continua con N Eos" non
dice che cosa si compra ne' che si spendono Eos, e la stessa frase serve otto
budget (domande, confronti, approfondimenti, gettate, sinastrie, stese,
consultazioni dell'Oracolo); "Continua con" nell'app vuol dire gia' un'altra
cosa (continuare con un Maestro, con Google, con Apple). La frase nasce in un
punto solo, `corredoDelRiscatto` (`lib/features/pricing/upgrade_invite.dart:196`),
e il prezzo si legge dal server (`prezzoDelRiscatto`, legge BG.04). Curato il
nome sbagliato del confronto (GCA.03) con la guardia che lo sorveglia.

DOMANDA: "la frase letterale 'Continua con N Eos' al posto di 'Riscatta una domanda in più · N Eos'"
PROVA: `test/ogni_riscatto_dice_la_cosa_giusta_test.dart`
MISURA: punti che compongono la frase del riscatto 1; riscatti col nome di un altro budget da 1 su 6 a 0 su 6

## VOCE GCA.12

**CHIUSA.** Le undici decisioni stanno nel rapporto
(`docs/ordini/RAPPORTO_ORDINE_GC.md`, righe in coda "Aggiunta del 23 ottobre
2026") e nel manifesto come GCA.01-GCA.12, coi marcatori aggiornati. Nessuna
decisione resta in attesa del fondatore.

DOMANDA: "Le undici decisioni si scrivono nel rapporto dell'ordine GC"
PROVA: `docs/ordini/RAPPORTO_ORDINE_GC.md`
MISURA: decisioni scritte 11 su 11, in attesa 0
