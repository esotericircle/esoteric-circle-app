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
