# RAPPORTO DELL'ORDINE GC, I CINQUE DIFETTI DELLA STESA DI TAROCCHI, LE CORREZIONI DELL'ORACOLO DEGLI ANGELI, IL LIVELLO VISIVO DEI DUE RESPONSI E LA PROFONDITÀ LUNGA

22 ottobre 2026. Ramo `claude/esoteric-circle-master-order-e798aj`.
Manifesto: `docs/ordini/ORDINE_GC_MANIFESTO.md`, 20 voci: **16 chiuse, 4
aperte in attesa di verifica, 0 da fare, 0 premesse cadute, 0 divieti**.
Testo dell'ordine: `docs/ordini/ORDINE_GC_TESTO.md`.

## La testa del ramo e le premesse

- **Testa del ramo all'inizio dell'ordine: `553234224f5a372b8e4843d45ec63025118254d7`**
  (verde di GitHub, `refs/verde/553234224f5a372b8e4843d45ec63025118254d7`).
  L'ordine nominava `f1712ca3`: esiste e la testa vera sta due commit dopo
  (le chiusure di GB.13 e GB.09).
- **Nessun manifesto GC esisteva** in `docs/ordini`: la sigla era libera.
- **Nessuna voce dell'ordine GB aggiunta (GBA) era stata eseguita**: le voci
  da GC.01 a GC.05 sono state eseguite in quest'ordine.
- **Premessa caduta in corso d'opera, poi risolta dal fondatore**: per GC.07
  e GC.08 il filmato v1 aveva le carte che restavano sul tavolo, quindi
  "durare per intero" e "aprire senza carte" non potevano stare insieme.
  Il fondatore: *"GC.07: tieni il taglio attuale finché non genero io il
  nuovo filmato senza carte"*; poi ha consegnato il filmato v2 (GC
  aggiunta), col tavolo vuoto alla fine. Verificato il file: 10,000 secondi,
  240 fotogrammi, 1080 per 1920, 24 al secondo, audio AAC 48 kHz stereo,
  17.265.367 byte (SHA-256 `46685e36…4eb4a889e`); nel ramo ricompresso a
  2.892.584 byte (`brand_assets/oracolo_angeli/medora_scala_di_luce_v2.mp4`),
  l'ultimo fotogramma sul tavolo dista dal primo 13,2 livelli di luminanza
  contro i 28,1 del v1 (`docs/collaudo/GC/gc_asset.txt`). Il v1 e i suoi
  fotogrammi sono tolti dal ramo.
- **Premessa parziale di GC.02**: il Calendario Lunare e il Respiro della
  Luna non hanno un'immagine dipinta sopra la scena da far passare sotto la
  barra (nel Calendario la testa di Medora sta alla riga 100, nel Respiro la
  Luna e' gia' sotto la barra): non sono cambiati.
- **I quattordici simboli dipinti** erano tutti in `D:\Clienti Roogly\Rituali
  Cartomanzia\App\Asset GC\` all'avvio: copiati in `assets/img/simboli/` come
  WebP RGBA 512 per 512 col canale alfa intatto, registrati nel pubspec e in
  `docs/stato_asset.json`. Nessun segnaposto resta in uso.

## Le voci chiuse e la loro prova

- GC.02, `docs/collaudo/GC/simulazioni/catture/s_01_filmato_e_salto.jpg`
- GC.03, `docs/collaudo/GC/simulazioni/catture/r2_02_stesa_salto_e_fine_naturale.jpg`
- GC.04, `docs/collaudo/GC/simulazioni/catture/s_02_scelgo_poi_scrivo.jpg`
- GC.05, `docs/collaudo/GC/anteprime/stesa_tre_carte.jpg`
- GC.06, `docs/collaudo/GC/simulazioni/catture/s_08_responso.jpg`
- GC.07, `docs/collaudo/GC/gc07_cinque_aperture.txt`
- GC.08, `docs/collaudo/GC/simulazioni/catture/o_02_sotto_il_tavolo.jpg`
- GC.09, `docs/collaudo/GC/simulazioni/catture/r2_01_oracolo_compatto_e_tavolo_in_vista.jpg`
- GC.10, `test/gc_l_oracolo_degli_angeli_test.dart`
- GC.11, `docs/collaudo/GC/simulazioni/catture/o_03_tendina_aperta_e_chiusa.jpg`
- GC.13, `docs/collaudo/GC/simulazioni/catture/o_07_lettura.jpg`
- GC.15, `docs/collaudo/GC/simulazioni/catture/o_09_responso.jpg`
- GC.16, `docs/collaudo/GC/simulazioni/catture/o_09_responso.jpg`
- GC.17, `test/gc_l_oracolo_degli_angeli_test.dart`
- GC.18, `docs/collaudo/GC/simulazioni/catture/o_10_bolla.jpg`
- GC.19, `docs/collaudo/GC/anteprime/oracolo_una_carta_lunga.jpg`

Aperte: **GC.01** (la prova sull'app vera con un account che apra la stesa a
dieci), **GC.12** e **GC.14** (da vedere sul Realme con una consultazione
nuova, dopo le cure trovate nella simulazione), **GC.20** (il verde di
GitHub).

## Spese e dati

- **Una sola chiamata a pagamento**: la Stesa a una carta del collaudo, col
  si' del fondatore in chat, stima 0,002 euro. L'Oracolo del Viandante legge
  dal corpus. Nessuna domanda ai Maestri, nessun banco.
- **L'account di collaudo** ha registrato sul server cio' che registra chi
  usa l'app: la consultazione e la stesa del giorno e il traguardo "Le tre
  carte" che si e' aperto da se' dopo la stesa, con 10 Eos accreditati (da
  145 a 155). Nessun Eos speso, nessun piano cambiato.
- **Il banco della misura di GC.01** (`tool/la_croce_celtica_dal_tocco.dart`)
  aveva sostituito l'app sul Realme: sul telefono c'e' di nuovo l'app vera,
  costruita in rilascio dal codice di questo ordine (nessuna build per i
  tester).

## Voce per voce

### GC.01, la stesa a dieci carte

DOMANDA: "La stesa a 10 carte, al click su pulsante \"leggi le carte\" rallenta tantissimo, va a scatti e poi manda in crash l'app che si chiude da sola."
PROVA: `docs/collaudo/GC/gc01_la_croce_celtica.md`
MISURA: stesa a dieci, PSS di picco da 280 a 220 MB, grafica da 140 a 96 MB, fotogrammi oltre 100 ms da 16 a 3, il piu' lungo da 300 a 200 ms; ricostruzioni della schermata intera durante la girata da 13 a 1

Due cause, misurate: le carte decodificate all'arte piena (PADRE: ordine FL
voce 05 e ordine CO voce 06) e la girata che ricostruiva l'intera schermata
(PADRE: ordine FL voce 05, aggravato da GA.03). La chiusura dell'app non si
e' riprodotta sul banco: resta aperta per la prova sull'app vera.

### GC.02, la barra lascia vedere il video

DOMANDA: "La barra in alto del titolo deve essere semitrasparente in modo da fare vedere il video animazione sotto"
PROVA: `docs/collaudo/GC/simulazioni/catture/s_01_filmato_e_salto.jpg`, `docs/collaudo/GC/simulazioni/catture/r2_03_sinastria_dal_bordo_alto.jpg`
MISURA: fascia fra barra e scena da 76,9 punti a 0; funzioni cambiate 2 (Stesa, Sinastria Evolutiva), controllate e lasciate 3 (Oracolo per GC.10, Calendario Lunare, Respiro della Luna)

PADRE: ordine FS, dopo la build 2310 (la scena messa piena dal bordo basso
della barra, `docs/guardie.md`, riga di
`nessuna_fascia_sotto_la_barra_della_stesa`).

### GC.03, il salto si ferma su Medora con la mano al cuore

DOMANDA: "Quando faccio click per skippare il video introduttivo, la scena si deve fermare allo stesso frame con Medora che ha una mano al cuore e l'altra che indica il tavolo."
PROVA: `docs/collaudo/GC/simulazioni/catture/r2_02_stesa_salto_e_fine_naturale.jpg`
MISURA: differenza fra salto e fine naturale sul Realme 2,1 livelli su 255

PADRE: ordine FS aggiunta (la frenata sulla posa scontornata). Le altre
funzioni con filmato d'ingresso, lette nel codice e non misurate una per
una sul telefono: l'Oroscopo, il Calendario Lunare, la Collana delle Lune e
le Sinastrie (porta comune) hanno un fotogramma finale dipinto
(`ultimoFotogramma`) su cui sfumano sia il salto sia la fine; il Respiro
della Luna e la scena dei Maestri sfumano sulla scena ferma. Nessuna e'
cambiata in questa voce.

### GC.04, la domanda scelta e la domanda scritta

DOMANDA: "se scelgo una domanda da quelle suggerite e scrivo anche la domanda, l'ultima è quella che conta e l'altra deve essere annullata tornando vuoto il campo, così da non confondere."
PROVA: `docs/collaudo/GC/simulazioni/catture/s_02_scelgo_poi_scrivo.jpg`, `s_03_scrivo_poi_scelgo.jpg`, `s_04_scrivo_e_cancello.jpg`
MISURA: sequenze 4 su 4 a video, 3 su 3 sul Realme; domande insieme da 2 a 1

PADRE: ordine CO voci 08 e 14 (commit `7f7dc798`, il campo della domanda
scritta nato accanto alla scelta senza una regola fra i due).
L'Oracolo ha un campo solo: niente da allineare.

### GC.05, la singola carta

DOMANDA: "la singola Carta ha titolo e non ha il secondo paragrafo con riquadro"
PROVA: `docs/collaudo/GC/anteprime/stesa_tre_carte.jpg`, `docs/collaudo/GC/catture_del_fondatore/05_singola_carta_con_riquadro.jpg`
MISURA: riquadri nelle singole carte da 1 per carta a 0

PADRE: ordine GA voce GA.05 (la singola carta con titolo, paragrafo e
riquadro). La forma si riscrive in un punto solo, `ResponsoInterpretato.comeSingola`.

### GC.06, il livello visivo della Stesa

DOMANDA: "io noto che c'è troppo testo e infografica zero"
PROVA: `docs/collaudo/GC/simulazioni/catture/s_08_responso.jpg`
MISURA: responsi delle stese col colpo d'occhio sopra il titolo da 0 a 4 su 4; simboli dipinti 14 su 14

Regola di calcolo: ogni pista conta le carte uscite di quel seme (Bastoni
fuoco, Coppe acqua, Spade aria, Denari terra, l'abbinamento della Golden
Dawn gia' nelle fonti del progetto) sul totale delle carte uscite; il segno
degli Arcani Maggiori conta i Maggiori. Nessuna percentuale. Nella stesa a
una carta la pista della sua carta e' piena e le altre vuote. Tipi di
grafico che l'ordine nomina: la ruota dell'Oroscopo e la scala di luce
dell'Oracolo (GC.18); le piste dei semi con le icone dipinte sono un tipo
diverso da entrambi. Un censimento di tutti i grafici dell'app non e' stato
fatto. PADRE del difetto: ordine GA voce
GA.03 (il responso a soli paragrafi).

### GC.07, il filmato dura per intero

DOMANDA: "1 il video introduttivo dura meno di un secondo."
PROVA: `docs/collaudo/GC/gc07_cinque_aperture.txt`
MISURA: da meno di un secondo a 10,41, 9,52, 9,39, 9,46 e 9,57 secondi (file 10,0)

Causa: il lettore si fermava a un istante scritto nel codice (il taglio
prima che le carte del v1 scendessero). PADRE: ordine GA voce GA.08.
Tolleranza ricavata dalla misura: la misura parte dal cambio di schermata
(prima che il video cominci) e si ferma all'ultimo fotogramma che si muove a
vista, quindi oscilla di mezzo secondo attorno al file.

### GC.08, all'apertura nessuna carta

DOMANDA: "2 all'apertura non si deve vedere la carta o messaggio del momento."
PROVA: `docs/collaudo/GC/simulazioni/catture/o_02_sotto_il_tavolo.jpg`
MISURA: pezzi visibili all'apertura da 2 a 0

PADRE: ordine FU voce FU.08 (l'angelo dell'ora sopra la scena). Nota del v2:
le carte alate compaiono a meta' filmato (da 1 a 7 secondi) ed evaporano; il
tavolo e' vuoto alla fine.

### GC.09, l'ordine sotto il tavolo

DOMANDA: "3 all'apertura si deve vedere subito sotto il tavolo il riquadro delle domande che adesso è in alto."
PROVA: `docs/collaudo/GC/simulazioni/catture/r2_01_oracolo_compatto_e_tavolo_in_vista.jpg`
MISURA: ordine 4 su 4, spenti 2 su 2; a 360 per 690 punti il posto delle carte da 16 punti (sotto la barra) a 194

PADRE: ordine FY (la domanda in sovrimpressione in alto, il mazzo dopo).
Richiesta del fondatore delle 21:30, durante il collaudo, eseguita qui: la
scena si taglia sul bordo d'oro del piano (riga 1725 del fotogramma), spazi e
bolle piu' bassi.

### GC.10, il video sale di dieci pixel

DOMANDA: "4 alza il video di 10 pixel, c'è troppo spazio tra la testa di Medora e la barra del titolo."
PROVA: `test/gc_l_oracolo_degli_angeli_test.dart`
MISURA: bordo alto da 0 a -3,33 punti sul Realme (10 pixel a densita' 3)

PADRE: ordine FU voce FU.02 (la scena allineata sotto la barra).

### GC.11, la tendina si chiude e la freccia di invio

DOMANDA: "5 nel selettore della domanda, quando la domanda viene scelta, la tendina con le domande sparisce."
PROVA: `docs/collaudo/GC/simulazioni/catture/o_03_tendina_aperta_e_chiusa.jpg`
MISURA: tendine aperte dopo la scelta da 1 a 0

PADRE: ordine FY voce FY.13 (le dieci domande in una tendina che restava
aperta). Altre funzioni col selettore della domanda: la Stesa ha la tendina
di sistema, che si chiude da se' e nessun pulsante rotondo; non cambiata.

### GC.12, la carta vola dal mazzo

DOMANDA: "La stessa Carta che tocco deve volare dal mazzo alla sua posizione sul tavolo e ci deve essere il suo suono, quello usato dalla stesa dei tarocchi."
PROVA: `test/gc_l_oracolo_degli_angeli_test.dart`
MISURA: voli dal dorso toccato 3 su 3, suoni per volo 1

PADRE del difetto trovato sul Realme (D1, il tavolo fuori schermo): GC.09 di
quest'ordine. Aperta per la registrazione sul telefono.

### GC.13, la riflessione e il suono

DOMANDA: "7 dopo l'invio con il tap sul pulsante voglio un'animazione di riflessione come per la stesa di tarocchi e dopo effetto sonoro come per la stesa di tarocchi"
PROVA: `docs/collaudo/GC/simulazioni/catture/o_07_lettura.jpg`
MISURA: suoni della rivelazione per lettura 1; righe sbagliate della riflessione sopra la stesa a una carta da 4 su 5 a 0

PADRE del difetto D2: ordine P sezione B (commit `d45e7d66`), aggravato da
GA.01 e da GC.13.

### GC.14, le carte si girano, si alzano e si aprono

DOMANDA: "Se faccio click su una carta in verticale ottengo una schermata popup con la descrizione della carta angelo."
PROVA: `docs/collaudo/GC/simulazioni/catture/o_08_alzata.jpg`, `docs/collaudo/GC/simulazioni/catture/o_12_foglio.jpg`
MISURA: scritte giuste 4 su 4; sosta sulle carte in piedi da meno di 0,5 a 2,5 secondi

Dati del foglio: numero, nome, coro, arcangelo e "che cosa porta" con la
fonte (Lenain 1823 o il Corpus), dalle stesse righe della bolla; per i 72
nessun dato manca. PADRE dei difetti D3 e D4: GC.14 di quest'ordine.

### GC.15, il responso come nella Stesa

DOMANDA: "I riquadri delle singole carte riportano carta, simbolo e titolo e 1 paragrafo intitolato come adesso \"il suo messaggio per te\"."
PROVA: `docs/collaudo/GC/simulazioni/catture/o_09_responso.jpg`, `docs/collaudo/GC/anteprime/oracolo_una_carta_breve.jpg`
MISURA: secondi paragrafi o riquadri nelle singole da 3 a 0; paragrafi del principale da 3 a 2

PADRE: ordine FU voce FU.06 (tre paragrafi e il riquadro in ogni carta).

### GC.16, lo sfondo cosmico

DOMANDA: "10 lo sfondo è cosmico."
PROVA: `docs/collaudo/GC/simulazioni/catture/o_09_responso.jpg`
MISURA: schermate col cosmo dietro da 0 a 1

PADRE: ordine FU voce FU.02 (commit `e17fe576`, `backgroundColor: palette.deepest`).

### GC.17, la stesa a una carta conta

DOMANDA: "3 la Carta singola corrisponde a una stesa a 1 carta e la sceglie l'utente. 4 conta come consultazione."
PROVA: `test/gc_l_oracolo_degli_angeli_test.dart`
MISURA: consultazioni contate da 0 a 1; costo di una consultazione a una carta non oltre 0,00020 dollari in Breve

I limiti per piano sono quelli del ramo (`QuestionAllowance.limiteOracoli`,
dal listino del server): nessun numero scritto a mano.

### GC.18, la scala di luce

DOMANDA: "io noto che c'è troppo testo e infografica zero"
PROVA: `docs/collaudo/GC/simulazioni/catture/o_10_bolla.jpg`
MISURA: colpo d'occhio sopra il titolo da 0 a 1; segni dei cori 9 su 9

PADRE: ordine FU voce FU.06 (il responso a soli paragrafi).

### GC.19, la Lunga nell'Oracolo

DOMANDA: "se selezionata aggiungerà 2 paragrafi solo alla risposta principale di cui il secondo in riquadro con titolo che scegli tu e contesto adatto ovviamente"
PROVA: `docs/collaudo/GC/anteprime/oracolo_una_carta_lunga.jpg`, `docs/collaudo/GC/simulazioni/catture/o_14_lunga_col_lucchetto.jpg`
MISURA: paragrafi del principale da 2 a 4; nelle singole 1; quota del costo sul netto, Illuminato mensile, 30,0 per cento prima e dopo

Costo: la Lunga dell'Oracolo era gia' nel caso peggiore di
`tool/i_limiti_degli_annuali.py` per ogni piano a pagamento (804 gettoni in
ingresso, 600 in uscita, 0,00032 dollari): renderla una scelta non alza il
caso peggiore. PADRE: ordine FU voce FU.06 (la Lunga automatica dal piano).

## Le scelte di Code, con la ragione

1. **Il ventaglio dell'Oracolo si accende quando la domanda e' affidata**,
   non prima: e' la regola piu' semplice da capire e la riga sopra il mazzo
   dice perche' e' grigio.
2. **Il riquadro della domanda compare a filmato finito**, in dissolvenza:
   e' la regola permanente FXA.08 ("sopra il video solo il video").
3. **Nella stesa a una carta dell'Oracolo il simbolo e' il libro aperto**
   (`Icons.auto_stories_rounded`), lo stesso che l'app usa per i messaggi
   dell'Oracolo; nessun simbolo nuovo.
4. **Nella stesa a una carta il responso principale e' quello della carta**
   e la bolla non ripete il messaggio (GA.05, GC.05).
5. **La riflessione nomina le carte vere** (D2): righe diverse per una,
   tre, quattro e dieci carte e per gli angeli, nella voce di Medora.
6. **Sosta di due secondi e mezzo sulle carte in piedi** (D3): il tempo di
   leggere tre parole e di toccarne una, misurato sulla simulazione.
7. **Le catture che il telefono non poteva dare oggi** (stesa a tre carte,
   Oracolo a una carta, Lunga) vengono dalla schermata vera in una prova a
   video, coi caratteri veri e la lettura finta: dichiarate come anteprime.
8. **Il paragrafo ripetuto dell'assaggio (D6) non e' curato**: sono le
   frasi del corpus per angelo e famiglia (GA.06) e cambiarle rompe lontano;
   proposto fra le migliorie.

## I passi manuali del fondatore

1. **GC.01**: dare per un giorno il piano Adepto all'account di collaudo,
   dove il fondatore decide i piani (Code non scrive dati di produzione),
   cosi' Code prova la stesa a dieci sull'app vera cinque volte di fila; poi
   riportarlo al Viandante.
2. **GC.12 e GC.14**: domani (nuovo giorno del server) Code registra sul
   Realme il volo della carta, la sosta sulle carte in piedi e il foglio col
   numero e il nome, con la consultazione del giorno del Viandante. Nessun
   passo del fondatore oltre al telefono collegato.
3. **Il filmato v2** e' gia' nel ramo: nessun passo.
4. Nessuna pubblicazione delle funzioni: quest'ordine non tocca il server.

## Le migliorie proposte, non costruite

1. **D6, il paragrafo ripetuto dell'assaggio dell'Oracolo**: per Nithhaiah e
   la famiglia "lavoro" la frase del Custode e quella dell'Intelletto dicono
   la stessa cosa. Una prova sul corpus che misuri la somiglianza fra le
   frasi di uno stesso angelo e famiglia troverebbe gli altri casi.
2. **Il foglio della carta, tirato su, occupa lo schermo intero**: un margine
   in alto lascerebbe lo spazio fuori da toccare per chiuderlo.
3. **Il titolo "25. Nithhaiah" e la riga "25. Nithhaiah, del coro dei
   Dominazioni"** si ripetono nel foglio; e "del coro dei Dominazioni"
   vorrebbe "delle Dominazioni" (il testo viene da `AngelCatalog`).
4. **Il traguardo che si apre sopra il responso** subito dopo la lettura
   copre il responso appena arrivato: aprirlo dopo che la persona ha letto
   o quando torna indietro.

**Aggiunta del 22 ottobre 2026, ordine GC, dopo il primo push.** Il cancello di GitHub sul commit `ffd765b0` ha trovato sette rossi nella suite intera, tutti attribuiti all'ordine GC e curati nel commit `0049fb7f`, verde: la prova GA.06 delle singole carte cercava il "Cosa fare" nella singola, che GC.05 ha tolto (il rimando a chi e' competente sta nel principale, 360 su 360); l'etichetta del coro in maiuscoletto andava a capo (ora in didascalia); il messaggio del foglio della carta non passava da `ParagrafiDiLettura`; la carta grande del dono dell'Alba prendeva la miniatura alla densita' 1 della prova (ora sempre l'arte piena, `TarotCardArt.artePiena`); due prove cercavano la posa scontornata dove GC.03 mette il fotogramma d'arrivo; il conto delle miniature (15) e il censimento degli spazi. Padre di tutti e sette: ordine GC (GC.01, GC.03, GC.05, GC.14).

**Aggiunta del 22 ottobre 2026, ordine GC, GC.01.** Il fondatore ha deciso in chat *"Chiudi col banco"*: GC.01 e' CHIUSA con la misura del banco. Poi, su suo suggerimento (*"perché non passi tu ad illuminato e così sei a posto?"*), la Croce Celtica e' stata letta anche sull'app vera, col piano Illuminato attivato in demo: processo vivo, nessuna chiusura, memoria da 474 a 490 MB, 2 fotogrammi oltre 100 ms. Prova: `docs/collaudo/GC/gc01_app_vera.txt`. Una volta sola: la stesa a dieci e' una al giorno e non si ricompra. Il passo manuale 1 non serve piu'.

**Aggiunta del 22 ottobre 2026, ordine GC, GC.12.** Chiusa: sul Realme la carta toccata vola dal ventaglio al centro del tavolo in 0,63 secondi e il tavolo resta a schermo per tutto il volo. Prova: `docs/collaudo/GC/simulazioni/catture/r3_01_volo_della_carta.jpg`.

**Aggiunta del 22 ottobre 2026, ordine GC, GC.14.** Chiusa: sul Realme la carta del momento resta in piedi circa tre secondi con la sua scritta, e il foglio aperto al tocco porta il numero e il nome nei cartigli. Prova: `docs/collaudo/GC/simulazioni/catture/r3_04_carta_in_piedi_e_foglio.jpg`. La seconda consultazione del giorno e' stata letta dal corpus (il piano demo non era sopravvissuto alla reinstallazione), nessuna chiamata a Gemini; gli Eos non sono stati spesi.

**Aggiunta del 22 ottobre 2026, ordine GC, il contatore delle consultazioni.** Il fondatore in chat: *"Hai già pensato a inserire una frase breve con il contatore delle stese rimaste oggi?"* e *"Probabilmente è meglio inserirla sopra o sotto il pulsante di avvio della lettura"*. La Stesa la mostrava gia'; l'Oracolo no. Aggiunto il budget `BudgetDelGiorno.oracoli` e la riga `RigaDelResiduo` sotto "Avvia la lettura" (anche nel Borsellino). Guardia `ogni_budget_dichiara_il_suo_residuo` vista rossa con la riga tolta (`docs/collaudo/GC/regola_a.txt`, riga 24).

**Aggiunta del 22 ottobre 2026, ordine GC, spese.** Oltre alla stesa a una carta (0,002 euro), una Croce Celtica letta dall'Illuminato col si' del fondatore (stima complessiva 0,015 euro, tetto 0,03): circa 0,002 euro.

**Aggiunta del 23 ottobre 2026, ordine GC aggiunta (GCA), la testa e le premesse.** Testo dell'aggiunta: `docs/ordini/ORDINE_GC_AGGIUNTA_TESTO.md`. Testa del ramo all'inizio dell'aggiunta: `c1cf4b6d73597cd46befb2e89f33eb90a494bac0`, verde. La Coda Aperta (`claude/Coda_Aperta_Esoteric_Circle.md`) non e' sul disco ne' nel ramo: le diciannove decisioni lette nella sezione 59.5 del Briefing Operativo MVP Demo V14 (`D:\Clienti Roogly\Rituali Cartomanzia\App\Briefing Definitivi\V14`). Tre premesse dell'aggiunta non reggono sul codice, scritte voce per voce: GCA.04 (i limiti sono 17 e 21, non 18 e 22), GCA.09 (la riga e' gia' fuori dalla matrice dall'ordine FU), GCA.10 (il 92 per cento e' un'opacita', non una larghezza). Le otto decisioni gia' prese dal fondatore non sono state riaperte. Il fondatore poi, in chat: *"Finisci anche l'aggiunta, tutte le voci Senza eccezione e consegna nuova build"*.

**Aggiunta del 23 ottobre 2026, ordine GC aggiunta, GCA.01 (FU.04, tetti, prompt o ripiego).** Decisione: si accetta il ripiego sul corpus, i tetti non si alzano, l'istruzione non si allarga, il filtro delle parole vietate resta com'e'. Ragione: il tetto di 420 caratteri misurato da FVA.02 non esiste piu', dall'ordine GA la misura e' in parole (40-50) per regola del fondatore, e una risposta fuori misura si scarta intera (GA.07); il filtro legge per sottostringa e scarta anche "guarire" in senso figurato, ma una promessa di guarigione a schermo costa piu' di un responso scritto a mano. Nessun lavoro sul codice. Prova: `docs/collaudo/FV/fva02_venti_consultazioni.txt`.

**Aggiunta del 23 ottobre 2026, ordine GC aggiunta, GCA.02 (la data della Luna).** Decisione: il picco esatto e' la data definitiva. Lavoro eseguito dentro GC: il cielo di un periodo che il Maestro legge (`lib/core/astro/il_cielo_per_il_maestro.dart`) datava la Luna al primo giorno in cui il nome della fase cambiava, dodici ore prima del picco; ora usa `IlMotoreLunare`. Padre: ordine EV, commit `d2e773ec`. Ragione per farlo qui: e' lo stesso difetto di GB.11 e il Maestro non puo' dire un giorno diverso dal Calendario. Prova: `test/gca02_il_maestro_data_la_luna_al_picco_test.dart` (4 lune su 25 fuori dal picco prima, 0 dopo).

**Aggiunta del 23 ottobre 2026, ordine GC aggiunta, GCA.03 (la carta "Hai chiesto a ...").** Decisione: la carta resta com'e'. Verificata dal vivo da Code sul Realme con l'Illuminato attivato in demo: una domanda vera a Medora e un confronto con Calìgo e Aura, poi la carta a video nella chat di Medora coi tre pareri. **Uso dell'eccezione dell'ordine GB (CLAUDE.md, SPESE punto 3), dichiarato per intero: una domanda vera scritta a Medora ("Devo cambiare lavoro entro fine anno?") e un confronto fra i Maestri (Calìgo, Aura e la sintesi), cioe' una domanda e un consulto, necessari a vedere la carta.** Difetto trovato nella stessa prova e curato: il pulsante del riscatto del confronto diceva "un confronto di sinastria", padre ordine BG voce 05, commit `36a2131a`; guardia nuova `test/ogni_riscatto_dice_la_cosa_giusta_test.dart`. Prova: `docs/collaudo/GC/simulazioni/catture/gca03_consulto_e_carta_hai_chiesto_a.jpg`. Il passo del fondatore di GB.05 non serve piu'.

**Aggiunta del 23 ottobre 2026, ordine GC aggiunta, GCA.04 (il limite delle domande ai Maestri).** Decisione: i limiti restano 3, 12, 17 e 21 (server `functions/src/budget.ts:114`, client `plan_catalog.dart:874`), l'illimitato resta vietato, l'uscita di GB.06 resta. Al caso peggiore il mensile sta entro il 30 per cento del netto (26,8, 29,6, 30,0). Difetto trovato, padre ordine FE voce 20 (commit `a2da1bb9`): per l'annuale la card e il conto dicono 11, 14 e 18, ma il server non conosce il ciclo e darebbe 12, 17 e 21 (32,1, 33,0 e 32,1 per cento del netto). Lasciato all'ordine che integrera' il pagamento, con la ragione: il ciclo arriva al server solo col pagamento vero, oggi non integrato (nessun annuale esiste), e il server lo pubblica il fondatore. Prova: `docs/costi/i_limiti_degli_annuali.txt`.

**Aggiunta del 23 ottobre 2026, ordine GC aggiunta, GCA.05 (il Diario senza anno).** Decisione e lavoro eseguito dentro GC: l'anno scritto sopra le dodici caselle del Diario e le date delle voci in lettere con l'anno ("22 ottobre 2026", `LinguaDegliEventi.dataConAnno`). Ragione: dal primo gennaio i mesi non dicevano di quale anno fossero, e "22/10/2026" era l'unica data in cifre dell'app. Lasciata a un ordine successivo la navigazione fra gli anni, un controllo nuovo. Prova: `test/i_ricordi_hanno_una_rotta_sola_test.dart`.

**Aggiunta del 23 ottobre 2026, ordine GC aggiunta, GCA.06 (Crashlytics su iPhone).** Decisione: sul codice non resta niente (interruttore spento, invio una volta sola e solo su iPhone, guardia della consegna, dSYM su Codemagic); resta al fondatore il passo di GB.08, che chiede una build iOS (R3). Prova: `test/la_consegna_parte_senza_la_prova_di_crashlytics_test.dart`.

**Aggiunta del 23 ottobre 2026, ordine GC aggiunta, GCA.07 (i versetti di Martini).** Decisione: restano letterali, con la virgola; la deroga c'e' gia' (GA, confermata dal fondatore in GB.12) e la guardia la riconosce togliendo solo il testo fra « » delle righe `salmi_martini`. Ragione: e' una citazione di un testo del 1842, i precedenti delle 48 ancore e delle 36 frasi erano testi di casa. Nessun lavoro. Prova: `test/language_rule_test.dart`.

**Aggiunta del 23 ottobre 2026, ordine GC aggiunta, GCA.08 (il dominio Fortuna).** Decisione: niente resta da fare, voce chiusa. Nei due corpus del dominio Fortuna nessuna parola di relazione romantica; "relazioni" in senso generale alla riga 1672 del corpus del Giorno resta. Prova: `test/gb09_la_fortuna_non_parla_di_relazioni_test.dart`.

**Aggiunta del 23 ottobre 2026, ordine GC aggiunta, GCA.09 (la compatibilita' a tre livelli).** Decisione: resta tolta, non si costruisce. La premessa ("ancora nella matrice") e' superata: la riga e' uscita con FU.16 e una guardia legge ogni stringa di lib. Nessun codice realizza i tre livelli. Prova: `test/la_compatibilita_a_tre_livelli_non_si_promette_test.dart`.

**Aggiunta del 23 ottobre 2026, ordine GC aggiunta, GCA.10 (la striscia dell'identita' al 92 per cento).** Decisione: resta. E' l'opacita' del velo della striscia (`lib/features/shell/barra_dell_identita.dart:78`), voluta da EU.19 perche' i contatori si leggano (contrasto peggiore 9,3); la regola delle barre del titolo (FY.20) vale per le barre col titolo. Guardia: `test/i_contatori_si_leggono_sempre_test.dart`.

**Aggiunta del 23 ottobre 2026, ordine GC aggiunta, GCA.11 ("Continua con N Eos").** Decisione: resta "Riscatta ... · N Eos". Ragione: dice cosa si compra e che si spendono Eos, serve otto budget da un punto solo (`corredoDelRiscatto`), e "Continua con" nell'app vuol gia' dire altro; il prezzo resta letto dal server. Prova: `test/ogni_riscatto_dice_la_cosa_giusta_test.dart`.

**Aggiunta del 23 ottobre 2026, ordine GC aggiunta, GCA.12 (il rapporto).** Prova: `docs/ordini/RAPPORTO_ORDINE_GC.md`, queste righe in coda. Undici decisioni scritte qui e nel manifesto (GCA.01-GCA.12, marcatori 32 voci, 31 chiuse, 1 aperta: GC.20, la consegna). Nessuna decisione in attesa del fondatore. Migliorie proposte, non costruite: rimisurare il ripiego dell'Oracolo con la forma GA (venti consultazioni, circa 0,004 euro, col si' del fondatore); la navigazione fra gli anni del Diario; il tetto annuale delle domande nel server, con l'integrazione del pagamento.

**Aggiunta del 23 ottobre 2026, ordine GC, GC.20 (la consegna).** Chiusa. Build 2316 dal commit `c82c37209200ddb7934f145cf4e8f22f8c1b1958`, verde di GitHub (`refs/verde/c82c37209200ddb7934f145cf4e8f22f8c1b1958`), costruita in rilascio, accesa sul Realme dalla prova di `tool/consegna.py`, caricata su App Distribution (release `1ne3h8ddl2kvo`), distribuita a cloud@esotericircle.app e accettata (rilettura della release: accettati 1). Registro `docs/versione_distribuita.json` da 2315 a 2316. Ordinata dal fondatore in chat: *"Alla fine dell'ordine, tutte le voci nessuna eccezione, consegna nuova build"* e *"Finisci anche l'aggiunta, tutte le voci Senza eccezione e consegna nuova build"*. Prova: `docs/versione_distribuita.json`. Voci finali del manifesto: 32, tutte chiuse.
