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

Restano aperte quattro voci: GC.01 aspetta la prova sull'app vera con un
account che apra la stesa a dieci; GC.12 e GC.14 aspettano di essere viste
sul Realme con una consultazione nuova, dopo le cure trovate nella
simulazione; GC.20, la consegna, si chiude col verde di GitHub sul commit
finale.

VOCI_TOTALI: 20
VOCI_CHIUSE: 16
VOCI_APERTE: 4
VOCI_DA_FARE: 0
VOCI_PREMESSA_CADUTA: 0
VOCI_DIVIETO: 0

## VOCE GC.01

**APERTA IN ATTESA DI VERIFICA.** Due cause trovate con la misura sul Realme
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

ASPETTA: la prova sull'app vera, cinque volte di fila, con un account Adepto o Illuminato sul telefono di collaudo (passo manuale 1 del rapporto): il banco sostituisce la schermata di partenza, non il resto dell'app in memoria.

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

**APERTA IN ATTESA DI VERIFICA.** La carta toccata vola dal suo posto nel
ventaglio al suo posto sul tavolo, col suono `carta.mp3` della Stesa, una
volta per volo. Sul Realme la carta arriva al suo posto, ma nel primo giro
il tavolo usciva dallo schermo mentre si sceglieva (difetto D1, padre GC.09):
curato portando in fondo alla finestra il solo ventaglio.

DOMANDA: "La stessa Carta che tocco deve volare dal mazzo alla sua posizione sul tavolo e ci deve essere il suo suono, quello usato dalla stesa dei tarocchi."
PROVA: `test/gc_l_oracolo_degli_angeli_test.dart`
MISURA: carta in volo che parte dal dorso toccato e arriva al suo posto 3 su 3, suoni per volo 1 (innesto senza suono: 0, rossa)

ASPETTA: la registrazione del volo sul Realme con una consultazione nuova (passo manuale 2 del rapporto): il Viandante aveva gia' usato quella del giorno e il giorno lo decide il server.

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

**APERTA IN ATTESA DI VERIFICA.** Le carte si girano una alla volta col loro
suono, poi si alzano ingrandite con "Fare", "Sentire", "Capire" o "La carta
del momento"; il tocco su una carta in piedi apre il foglio della carta
(`LaCartaDellAngeloAperta`). Due difetti visti sul Realme e curati: le carte
in piedi restavano in vista meno di mezzo secondo (D3) e il foglio mostrava
la carta coi cartigli vuoti (D4), padre GC.14 di quest'ordine.

DOMANDA: "le carte si girano sul tavolo una alla volta con effetto sonoro e subito dopo si alzano in verticale ingrandendosi. Per la stesa a 3 sopra ogni carta c'è scritto \"fare\", \"sentire\", \"capire\", mentre per la stesa a 1 carta \"la carta del momento\". Se faccio click su una carta in verticale ottengo una schermata popup con la descrizione della carta angelo."
PROVA: `docs/collaudo/GC/simulazioni/catture/o_08_alzata.jpg`
MISURA: scritte giuste 3 su 3 e 1 su 1, suoni della girata uno per carta girata, foglio che si apre sull'angelo toccato (`test/gc_l_oracolo_degli_angeli_test.dart`); sosta sulle carte in piedi da meno di 0,5 a 2,5 secondi

ASPETTA: vedere sul Realme, con una consultazione nuova, la sosta sulle carte in piedi e il foglio col numero e il nome (passo manuale 2 del rapporto).

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

ASPETTA: il verde di GitHub sul commit consegnato.
