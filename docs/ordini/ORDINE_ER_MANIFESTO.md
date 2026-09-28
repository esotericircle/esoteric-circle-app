# ORDINE ER, LE ARTI CHE RISPONDONO, LA SINASTRIA VIP, IL GEMELLO ASTRALE, LA HOME CON TUTTE LE ARTI E IL LIVE

**Sigla:** ER, verificata sul ramo il 27 settembre 2026: in `docs/ordini`
l'ultimo manifesto era `ORDINE_EQ_MANIFESTO.md`, in `docs/collaudo` l'ultima
cartella EQ; nessun `ORDINE_ER_*`, nessuna `docs/collaudo/ER`.
**Data dell'ordine:** 27 settembre 2026, arrivato in tre pezzi, piu'
l'aggiunta del fondatore "ER Aggiunta" (voce ER.20); il 28 settembre
"ER Aggiunta 2", le risposte del fondatore al resoconto di fine lavoro:
la qualita' lite gia' accesa (ER.11), la guardia della decisione grave che
leggeva "puoi" come un ordine e le discese finite sulla riserva (ER.02), il
conto di prima del "perche' proprio lui" (ER.18). E poi: *"Finisci tutto
Senza fermarti e poi consegna nuova build pronta anche per codemagic"*.
**Ramo:** `claude/esoteric-circle-master-order-e798aj`.
**Partenza:** commit `3a2c12d3` dell'ordine EQ, col cancello di GitHub verde
su quel commit (dodici controlli su dodici). Le voci ancora aperte dell'ordine
EQ restano dell'EQ. Le build le ordina il fondatore: le due build di prova,
2285 e 2286, sono state installate sul telefono di collaudo e non
consegnate; il 28 settembre il fondatore ha ordinato la consegna (*"consegna
nuova build pronta anche per codemagic"*), e la build 2287 e' nella sezione
LA CONSEGNA del rapporto.

Il testo intero dell'ordine e' quello del fondatore, in sei parti: le rune
(ER.01), il Viaggio dello Sciamano (ER.02, ER.03), la Sinastria VIP e il
Gemello Astrale (ER.04, ER.05, ER.06), la home e le schede (ER.07, ER.08,
ER.09, ER.10), il LIVE (ER.11, ER.12, ER.13), i difetti trovati
dall'Architetto (ER.14 fino a ER.19); e l'aggiunta, il Segreto dell'Iride
(ER.20). Le catture del fondatore stanno in `Catture fondatore/ER` sul PC,
fuori dal repository.

VOCI_TOTALI: 20
VOCI_CHIUSE: 16
VOCI_APERTE: 4
VOCI_DA_FARE: 0

Le prove stanno in `docs/collaudo/ER/`; quelle viste sul telefono di prova
(Realme 767f596c, 360 per 800 punti) in `docs/collaudo/ER/realme/`, con
l'indice voce per voce in `docs/collaudo/ER/realme/LEGGIMI.txt`. **Una voce che
si vede a schermo e' chiusa solo con la sua cattura dal Realme**: la misura in
prova dice che il codice fa la cosa, la cattura dice che la persona la vede.

**Quello che il telefono non puo' mostrare, detto una volta per tutte.** Le
scale delle animazioni di sistema del Realme sono a zero (lette, mai
cambiate): la corsa del nastro del Gemello non si fotografa. "Condividi" apre
subito il foglio di Android senza un'anteprima, e dal telefono di collaudo non
si manda niente a nessuno: la card da condividere non si cattura.

**I difetti visti sul telefono e corretti dentro l'ordine**, ognuno col suo
padre, sono nel rapporto e in `docs/collaudo/ER/realme_regola_b.txt`: otto,
di cui quattro miei (ER.01, ER.04, ER.14, ER.19). Le tredici rosse della
suite finale, tutte venute da voci di quest'ordine, stanno col loro padre in
`docs/collaudo/ER/suite_finale_rosse.txt`.

---

## PARTE 1, LE RUNE

## VOCE ER.01, L'ESTRAZIONE RUNE INTERPRETA DAVVERO

**APERTA IN ATTESA DI VERIFICA**: le misure salgono molto ma non arrivano al
risultato dell'ordine (20 su 20, tutte le pietre, zero errori). La via, le
misure e cio' che manca sono qui sotto; la decisione su cosa fare del resto e'
del fondatore.

**La via scelta, ed e' di Code.** La stessa della Stesa dei Tarocchi (ordine
EQ voce 04): una chiamata a `gemini-2.5-flash` in europe-west1 con lo schema
dei campi obbligatori (`lib/core/rituals/la_lettura_delle_rune.dart`,
`FirebaseMaestroAiProvider.presagioDelleRune`): la posizione scelta prima di
scrivere (si', no, si' a una condizione, un passo da fare, com'e' la
situazione), la risposta, per ogni pietra la sua lettura nella posizione e una
frase sulla domanda, il legame, il consiglio. La richiesta porta ogni pietra
con la sua riga del corpus (`docs/corpus/rune.md`) nel verso uscito, la
posizione e la sua glossa, e la cornice dell'allegato B quando la domanda e'
una delle sedici. **Il sistema a scheletri resta**: il corpus e' lo scheletro,
il modello interpreta. Le guardie a valle scartano la lettura che non nomina
le pietre, che apre per immagini o con una formula, che sceglie una posizione
e non la dice, che ricopia la cornice, che ha due pietre con la stessa frase,
che nomina astri o supera il confine; riparano i nomi delle rune fuori dalla
terza parte e tagliano dal consiglio le parti che parlano delle pietre. Se due
chiamate non reggono, parla la lettura di casa, come prima. Era Flash-Lite:
alla lettura alla cieca del secondo giro non reggeva (dirette 9 e 11 su 20).

**Sul telefono.** Alla build 2285 il presagio del modello cadeva sempre sulla
lettura di casa: la guardia della posizione scartava *"Accetta l'offerta di
lavoro, ma poni una condizione chiara sul tuo tempo"*, cioe' proprio la
risposta diretta (padre ER.01, mio; al banco, sulla stessa gettata, tre scarti
su tre). Corretta; alla 2286 il presagio e' del modello: *"Accetta il nuovo
lavoro a Torino, ma prima di partire, fissa i tuoi confini."*
(`docs/collaudo/ER/realme/er01_2286_rune_01.jpg`). La lettura di casa
scriveva *"Ciò che fu. qualcosa"* (padre DF.05): corretta.

**Costo e attesa.** Una gettata costa una chiamata a Flash (due quando la
prima si scarta): circa 5.900 token in entrata e circa 400 in uscita, misurati
sulla gettata del telefono (`tool/sonda_schema_rune.dart`, `usageMetadata`).
Il tempo della chiamata, al banco, ha mediana 3.809 e 3.744 ms (era 1.212 con
Flash-Lite senza schema, `docs/collaudo/ER/rune/prima.txt`). **L'attesa sul
telefono, dal lancio al testo, non e' misurata a parte**: l'ordine la chiede,
e resta da fare con un registro della tappa. Nessuna cache delle letture: gettate diverse danno letture
diverse, e la cache implicita di Vertex tiene l'istruzione.

DOMANDA: "Adesso ho il dubbio che anche le estrazioni rune non abbiano l'interpretazione come i tarocchi. Tu puoi verifcarlo?"; "Le persone vogliono risposte dirette, Senza tanti giochi di parole e cercano consigli e guide anche su domande generiche."
PROVA: docs/collaudo/ER/ciechi/conti.txt
MISURA: alla cieca sul codice che va in build (giro 8, due esecuzioni), letture con domanda che rispondono in modo diretto nelle prime due frasi da 5 su 20 a 12 e 17 su 20; letture con tutte le pietre lette nella loro posizione e sulla domanda da 0 su 24 a 14 e 14 su 24; errori di italiano da 4 a 9 e 4; letture uguali su cento con la stessa domanda 0, cadute sulla lettura di casa 3 su 100

## PARTE 2, IL VIAGGIO DELLO SCIAMANO

## VOCE ER.02, IL VIAGGIO RISPONDE ALLA DOMANDA

**APERTA IN ATTESA DI VERIFICA**: la prima frase prende posizione in 15 e 16
discese su 20 al giro 8, e l'ordine chiede 20 su 20. Come ha scritto il
fondatore con l'aggiunta 2, la voce si chiude solo a 20 su 20.

**L'aggiunta 2 del fondatore, 28 settembre.** *Punto 1*: la guardia della
decisione grave leggeva *"Puoi trasferirti a Berlino per lavoro"* come un
ordine, e scartava due risposte dirette del giro 7. La regola della DN.04
resta com'e': adesso, prima di cercare l'ordine, si tolgono dal testo i
"puoi" seguiti da una decisione grave (`_puoiConLaDecisione`); "non puoi"
resta, e *"trasferisciti"*, *"devi trasferirti"*, *"lascia il lavoro"*
restano scartati, come *"Non lasciare nulla al caso, ma segui quello che
senti"*, che su una domanda grave dice come scegliere (il caso della build
2259). Prova nuova `la_decisione_grave_legge_il_puoi`, rossa sul codice di
prima con le frasi vere del banco. *Punto 2*: la riserva conta fra le
risposte che non prendono posizione, e i conti giro per giro dicono quante
discese ci sono finite e dopo quali scarti
(`docs/collaudo/ER/viaggio/riserva.txt`): nel giro 8 due e tre su venti, dopo
scarti di previsione certa, genere, stato di un terzo e domanda non nominata;
il giudice alla cieca non ha mai dato "posizione" a una riserva, quindi i
conti di prima non cambiano. A Berlino, al giro 8, la riserva ha risposto
*"Una delle due la stai già facendo, in piccolo, da settimane."* in tutte e
due le esecuzioni, dopo tre risposte scartate per previsione certa: parla di
due strade che la domanda non ha. Resta la proposta della riserva che prende
posizione, nel rapporto.

Fatto: la regola che impediva di rispondere (*"Non dire se la cosa accadrà
[...] Parla di ciò che la persona può guardare o fare adesso"*) e' riscritta
in `lib/core/viaggio/la_scena_dal_modello.dart`: la posizione si sceglie nello
schema prima della risposta, e la prima frase la dice; il futuro certo resta
vietato. **Le guardie che fermavano una risposta diretta**, come l'ordine
chiede di dire: la guardia sui terzi scartava *"Chiama tuo fratello questa
settimana"* (il gesto che l'istruzione stessa dava per esempio), *"Chiedile di
pranzare insieme"*, *"Non puoi sapere cosa pensa la tua collega"*, *"Non la
forzare se non accetta"*; la guardia della certezza scartava *"Non puoi sapere
che cosa farà lui"*; la guardia del genere scartava *"non sei sola"* a chi non
ha detto il suo genere. Le prime quattro sono corrette (l'imperativo di chi
legge, cio' che chi legge non puo' sapere, l'imperativo negativo col pronome,
il dubbio con "che cosa"); per il genere il modello riceve la regola della
Stesa. **Restano ferme**, e devono: il futuro dato per certo (*"supererai il
concorso"*), lo stato dell'altro detto come fatto (*"Tuo fratello ti vuole
bene"*). **Cosa resta sotto il 20 su 20**: circa tre discese su venti finiscono
sulla riserva dopo tre scarti, e la riserva non prende posizione; le altre
sono risposte del modello ancora vaghe (*"Ascolta il tuo sentire"*). La
strada, se il fondatore la vuole: una riserva che dica la posizione scelta
dal modello sull'oggetto della domanda.

Sul telefono, build 2285: *"I segni del viaggio dicono di sì, puoi chiamare
tuo fratello"* e *"I segni del viaggio dicono di sì, a condizione che tu veda
cosa ti blocca davvero"* (`docs/collaudo/ER/realme/er02_viaggio_03_responso.jpg`,
`er02_viaggio_05_seconda_discesa.jpg`).

DOMANDA: "Le persone vogliono risposte dirette, Senza tanti giochi di parole e cercano consigli e guide anche su domande generiche."
PROVA: docs/collaudo/ER/ciechi/conti.txt
MISURA: alla cieca, con la riserva contata fra le risposte che non prendono posizione, prima frase che prende posizione sulla domanda da 0 su 20 (commit 3a2c12d3) a 12 e 12 su 20 (giro 7) e a 15 e 16 su 20 (giro 8, dopo la guardia del puoi); discese finite sulla riserva da 6 su 20 a 2 e 3 su 20 (docs/collaudo/ER/viaggio/riserva.txt); scarti per decisione grave di frasi che dicono "puoi" senza ordinare da 1 e 1 (giro 7) a 0 e 0 (giro 8, docs/collaudo/ER/decisione_grave_puoi.txt), ordini su una decisione grave che passano la guardia 0 su 7; frasi vuote da 44 a 30 e 24; sul Realme 2 discese su 2

## VOCE ER.03, IL TITOLO DEL VIAGGIO SCRITTO COME GLI ALTRI

**CHIUSA.** Sul Realme la card "Il Viaggio dello Sciamano" in home, fra
"Stesa di Tarocchi" e "Oracolo dei Cristalli", e nel dominio di Calìgo, e'
scritta come le altre.

Fatto (commit `5a70fc73`): la card del Viaggio non ha piu' il titolo scritto a
parte. `righeDelTitolo` e' uscito da `lib/core/arts/art_catalog.dart` (con la
lapide in `la_promessa_del_viaggio.dart`), e la scheda disegna "Il Viaggio
dello Sciamano" con lo stile e le regole di andata a capo comuni a tutte le
arti (`IlTitoloColTrattino`, voce ER.09). La descrizione che cambia dopo la
quarta discesa resta.

DOMANDA: "Aggiungi all'ordine: "Viaggiò dello sciamano" deve tornare ad essere scritto come gli altri."
PROVA: docs/collaudo/ER/realme/er03_viaggio_in_home.jpg
MISURA: card d'arte col titolo scritto in modo diverso dalle altre, da 1 (il Viaggio, in tre righe "VIAGGIO", "dello", "SCIAMANO") a 0 su 67 (docs/collaudo/ER/titoli.txt); il Viaggio si legge "Il Viaggio dello / Sciamano" in due righe nei tre formati di home; sul Realme in home e nel dominio di Calìgo (er10_dominio_caligo_03.jpg)

## PARTE 3, LA SINASTRIA VIP E IL GEMELLO ASTRALE

## VOCE ER.04, LA MIA CARTA: AVATAR O FOTO, NON UN VIP

**CHIUSA.** Sul Realme il tocco sulla carta "Tu" apre fotocamera, galleria e
avatar, nessun VIP; la foto scelta arriva nella carta, nell'avatar del
profilo in alto e nel responso. La card da condividere non si cattura (vedi
in cima): che la foto ci arrivi lo dice la prova
`test/la_carta_tu_apre_il_tuo_volto_test.dart`, non una cattura.

Fatto (commit `156e86bd`): la carta "Tu" della porta della sinastria apre il
foglio del volto (`lib/features/synastry/il_foglio_del_tuo_volto.dart`):
fotocamera, galleria o avatar. La scelta si scrive nel profilo
(`ProfileController.setAvatarPhoto`) e da li' arriva nella porta, nel
responso e nella card. Il confronto fra due VIP (ordine BO voce 13) resta,
dalla scelta "Confronta 2 VIP": solo li' la prima carta e' un VIP e il suo
tocco lo cambia. La prova CA.02 di `la_porta_della_sinastria_test.dart` e'
riscritta con la lapide.

DOMANDA: "Nella sinistria vip c'è una regressione: in "sinastria con un vip" se faccio click sulla mia carta, mi fa scegliere un vip anziché farmi scegliere un avatar o di inserire una mia foto o immagine."
PROVA: docs/collaudo/ER/realme/er04_tocco_carta_tu.jpg
MISURA: tocchi sulla propria carta che aprono la scelta di un VIP, da 1 su 1 a 0 (docs/collaudo/ER/la_carta_tu.txt); sul Realme la foto scelta nella porta, nel profilo e nel responso, 3 su 3 (er04_porta_con_la_foto.jpg, er05_responso_01.jpg); riga sotto "Tu" tagliata coi puntini da 1 (2285) a 0 (2286, er04_2286_porta_riga_sotto_tu.jpg)

## VOCE ER.05, LA POSSIBILITÀ DI INCONTRO DICE LA REALTÀ

**CHIUSA.** Sul Realme, a 360 punti, la barra dell'incontro con Beyoncé e'
lunga quanto il suo 3,8 per cento, e l'etichetta sta su una riga.

Fatto (commit `e393f4e7`): la barra dell'incontro era l'indice sulla scala
di chi guarda (la percentuale divisa per 3,6 punti), con una parola a destra
("Alla vostra portata") che andava a capo. Adesso la barra e' la percentuale
vera, sulla stessa scala delle altre barre, e a destra c'e' il numero.

DOMANDA: "Inoltre, nei risultato, la infografica di "possibilità di incontro" è scritto male, va a capo e la percentuale bassissima mostra una barra colorata altissima che è assolutamente non coerente con le altre infografiche barre. Rimettiamo la realtà."
PROVA: docs/collaudo/ER/realme/er05_responso_03.jpg
MISURA: barre dell'incontro piu' lunghe della loro percentuale vera, da 20 su 20 (Billie Eilish al 3,8 per cento con la barra piena) a 0 su 20 (docs/collaudo/ER/incontro.txt); etichette spezzate dentro una parola, da 1 (la cattura, a 70 punti) a 0; sul Realme 3,8 per cento con la barra a 3,8

## VOCE ER.06, IL GEMELLO ASTRALE IN UNA SCHERMATA SOLA

**CHIUSA.** Sul Realme alla 2286: una schermata sola, il nastro delle carte
poco sovrapposte sul cielo e il pulsante "Cerca il tuo gemello VIP"; dal
pulsante al podio e al responso intero senza altri tocchi. La corsa di 3,4
secondi non si fotografa su questo telefono (vedi in cima): la misura la
prova `test/il_gemello_in_una_schermata_sola_test.dart`.

Fatto (commit `5bae25bc`): `schermata_del_gemello.dart` e' una schermata sola
in tre tempi. Il nastro delle carte dei VIP poco sovrapposte, il pulsante
"Cerca il tuo gemello VIP", la corsa che rallenta (3,4 secondi) e si ferma coi
tre gemelli, il piu' vicino al centro; il podio con le percentuali, e sotto il
responso intero, senza toccare niente. La galleria non porta piu' al Gemello
(lapide), `rivelazione_del_gemello.dart` e' cancellato.

**Difetti visti sul telefono alla 2285**:
il fondo nero (il fondatore: *"Dovrebbe essere cosmico"*; padre CF.14,
ereditato da ER.06) e i nomi del podio spezzati dentro la parola, *"Damian /
o David"*, con la seconda riga sotto il gradino (padre il podio del 31 agosto,
commit d24b7308). Corretti: il Gemello sta sul cielo, i nomi vanno in due
righe di parole intere e il palco cresce col nome.

DOMANDA: "Inoltre, nel gemello astrale, quando lo apro calcola immediatamente il gemello Vip, ma sopra mostra "scegli il tuo vip" e sotto c'è l'elenco delle carte del vip che in questa funzione non hanno senso. [...] La prima e unica schermata che si deve aprire è una schermata semplice con le carte dei vip in orizzontale poco sovrapposte. Al click su un pulsante nuovo "cerca il tuo gemello VIP" le carte iniziano a scorrere velocemente, poi rallentando vengono estratte le 3 carte dei gemelli vip con al centro il gemello più vicino [...] Ma tutto nella stessa schermata Senza bisognondi cliccare sull'immagine della carta del gemello."; "La schermata del nastro delle carte ha sfondo nero, perché? Dovrebbe essere cosmico"
PROVA: docs/collaudo/ER/realme/er06_2286_gemello_02_podio.jpg
MISURA: elementi della galleria nella schermata del Gemello (titolo "Scegli il tuo VIP", ricerca, categoria, elenco), da 4 a 0; gesti fra il pulsante e il responso intero, da 1 (il tocco sulla carta) a 0; parti del responso che mancano, 0 su 11; percentuali sul podio, 3 su 3; sul Realme alla 2286 schermate col fondo nero da 1 a 0 e nomi del podio spezzati dentro la parola da 2 su 3 a 0 su 3 (docs/collaudo/ER/gemello_una_schermata.txt)

## PARTE 4, LA HOME E LE SCHEDE

## VOCE ER.07, L'ORO DELL'OROSCOPO

**CHIUSA.** Sul Realme la scheda dell'Oroscopo, in cima alla riga delle
preferite, ha l'emblema in oro.

Fatto (commit `798055fd`): i tre webp dell'Oroscopo in `assets/schede` sono
quelli corretti del PC del fondatore. Guardia `l_oro_dell_oroscopo`.

DOMANDA: "la scheda dell'oroscopo, l'emblema sembra più bronzo che oro. Sistema le schede oroscopo o poi falla aggiornare a Code."; domanda girata al fondatore: "L'oro dell'Oroscopo corretto va bene?", risposta: "Sì, salvalo".
PROVA: docs/collaudo/ER/oro_dell_oroscopo.txt
MISURA: webp dell'Oroscopo in assets/schede uguali byte per byte a quelli del PC, da 0 su 3 a 3 su 3; sul Realme docs/collaudo/ER/realme/er03_viaggio_in_home.jpg

## VOCE ER.08, LE RIGHE DELLA HOME: UNDICI CATEGORIE SCELTE DAL FONDATORE

**CHIUSA.** Sul Realme la home dall'alto in basso: undici righe, forme
alternate, due schede e mezza in vista.

Fatto (commit `5a70fc73`, con la ER.20 in `171f9e4c`): la home ha le undici
righe della voce, con titoli, forme e ordine delle arti scritti
dall'Architetto e approvati dal fondatore (`le_righe_della_casa.dart`).
**La regola dei doppioni del 26 settembre e' uscita**, come ha detto il
fondatore ("togli regola del 26 settembre"): `senzaDoppioniInVista` ha la
lapide, e la guardia `nessun_doppione_in_vista` e' diventata
`i_doppioni_della_home_sono_voluti`, che confronta ogni riga con l'elenco
scritto (alla prima stesura confrontava la riga con se stessa ed era cieca:
vista verde con l'innesto, cambiata la grandezza, vista rossa).

GUARDIA RIMOSSA: nessun_doppione_in_vista - ordine ER, commit 5a70fc73, la regola dei doppioni l'ha tolta il fondatore; la misura vive in i_doppioni_della_home_sono_voluti

DOMANDA: "rivediamo l'ordinamento delle categorie della home in modo da avere righe con schede verticali, poi orizzontali e poi quadrate."; "Ok, togli regola del 26 settembre. Se ci sono righe ovvero categorie con lo stesso colore significa che non vanno bene [...] Non ha senso avere categorie di un solo colore, tanto vale che l'utente vada direttamente nel singolo dominio."; risposta alle undici righe: "Per ora va bene così".
PROVA: docs/collaudo/ER/righe_della_home.txt
MISURA: coppie di righe vicine con la stessa forma, da 5 su 9 a 0 su 10; righe con le arti di un solo Maestro, da 4 su 10 a 0 su 11; arti del catalogo visibili in home, da 30 a 67 (66 della voce piu' il Segreto dell'Iride della ER.20); righe diverse dall'elenco della voce, 0 su 11; arti spostate dalla regola dei doppioni, 0; sul Realme docs/collaudo/ER/realme/er08_home_01.jpg ... er08_home_07.jpg

## VOCE ER.09, LE MISURE DELLE SCHEDE IN HOME

**CHIUSA.** Sul Realme le righe verticali e quadrate a 128 punti e le
orizzontali a 137, due schede intere e mezza in vista, titoli a dodici punti.

Fatto (commit `5a70fc73`): in home le verticali e le quadrate sono larghe 128
punti, le orizzontali 137; nei domini restano 184 e 288. I titoli in home
sono a 12 punti (`misuraDelTitoloInCasa`), al massimo due righe, e vanno a
capo fra parole o, se una parola non ci sta, col trattino in sillaba
(`lib/design_system/typography/il_titolo_col_trattino.dart`). Niente freccia a
fine riga: "No, basta il taglio".

DOMANDA: "Ma così niente rimani in evidenza, hanno tutti la stessa importanza. Diminuisci ulteriormente quelle orizzontali del 10% e aumenta verticali e quadrate fino a 2 arti e mezzo."; domanda girata al fondatore: "La freccia a fine riga la mettiamo?", risposta: "No, basta il taglio"; risposta all'anteprima dell'Architetto: "La home mi convince adesso."
PROVA: docs/collaudo/ER/titoli.txt
MISURA: larghezza in home delle verticali e quadrate, da 162 a 128 punti; delle orizzontali, da 253 a 137; titoli su piu' di due righe o tagliati, 0 su 201 (67 arti nei tre formati); larghezze nei domini, 184 e 288 prima e dopo; sul Realme docs/collaudo/ER/realme/er08_home_02.jpg ... er08_home_07.jpg

## VOCE ER.10, TUTTE LE ARTI AL LORO POSTO, NELLA HOME E NEI DOMINI

**CHIUSA.** Sul Realme i domini di Medora, Aura e Calìgo hanno le sezioni
della voce, ogni arte in quella del suo Maestro, e nessuna riga "In arrivo".

Fatto (commit `5a70fc73`): dodici arti nuove del briefing nel catalogo, coi
Maestri scelti dal fondatore (Medora: Time Machine Astrologica, Cosmic Scan,
Cosmic Dating, Sinastria NFC e QR; Aura: Breathwork, Percorso di Risveglio,
Feng Shui, Specchio dell'Anima; Calìgo: Rituali Collettivi, Alchimia, Albero
della Vita, Cosmic Academy), ognuna con la fase del briefing (Breathwork,
Specchio dell'Anima e Alchimia, senza fase nel briefing, in fase successiva).
In `assets/schede` i 216 webp del PC, e ogni arte ha il suo sfondo. I domini
hanno le sezioni della voce, e la riga "In arrivo" non c'e' piu': ogni arte
sta nella sezione del suo Maestro.

DOMANDA: "Adesso inoltre ci sono tutte le arti previste dal progetto o ne manca qualcuna tipo la scansione dell'occhio? Facciamole tutte. Avendole tutte, possiamo inserirle ognuna nella giusta categoria sia in home sia nei singoli domini così da avere già una visione futura dell'app conclusa."; risposta sulle arti da creare: "Arti dei Maestri, Funzioni trasversali"; risposta sui Maestri: "Come propongo"; "Le 11 vanno bene."
PROVA: docs/collaudo/ER/sfondi_dal_pc.txt
MISURA: arti del catalogo senza sfondo, da 24 a 0; arti del briefing scelte dal fondatore presenti nel catalogo, da 0 su 12 a 12 su 12; arti nella riga "In arrivo" dei domini, da 24 a 0; webp di assets/schede diversi da quelli del PC con lo stesso nome, da 6 a 0 (elenco dei domini in docs/collaudo/ER/righe_della_home.txt); sul Realme docs/collaudo/ER/realme/er10_dominio_medora_01.jpg, er10_dominio_aura_01.jpg, er10_dominio_caligo_01.jpg e seguenti

## PARTE 5, IL LIVE

## VOCE ER.11, IL VOLTO DEL LIVE IN QUALITÀ LITE

**APERTA IN ATTESA DI VERIFICA**: le misure in standard e in lite sono
fatte; la voce, come scrive l'ordine, *"si chiude col giudizio del fondatore
sul volto"*, e il fondatore il volto lo prova lui sul telefono (*"Preferisco
provarlo io"*, 28 settembre).

Il cambio di `configurazione/live.qualita` a `lite` l'ha fatto il fondatore
il 28 settembre (la sua cattura del campo e' in `Catture fondatore/ER`, fuori
dal repository); il registro delle funzioni dice `caligo lite` per tutte e
tre le sessioni misurate. Dieci turni sul Realme alla 2286, con domande mai
fatte quel giorno, la chat sempre dal modello (da 1.408 a 3.020 ms).

| mediane dalla fine della domanda | standard (2285) | lite (2286) |
|---|---|---|
| il Maestro si sente | 5.146 ms | 5.300 ms |
| il volto parla | 5.529 ms | 5.620 ms |
| dalla risposta al primo audio al volto | 354 ms | 40 ms |

**La lite non accorcia l'attesa**: il flusso verso il volto parte quasi
subito (da 354 a 40 ms), ma il Maestro si sente 150 ms dopo, dentro lo
scarto fra un turno e l'altro. **E non cambia la risoluzione del video che
arriva al telefono**: in tutte e due le qualita' il flusso parte a 256x256
(la misura agli 8 secondi) e sale a 512x512 (ai 25); media della sessione dei
turni 502 pixel di lato. Il volto a confronto: apertura, 384 e 512 in
`docs/collaudo/ER/realme/er11_lite_volto_confronto.jpg`.

**Trovato strada facendo**: al sesto turno della prima sessione la
trascrizione e' tornata vuota due volte su una voce chiara (da -13 a -24 dB),
e il LIVE si e' chiuso per silenzio quattordici secondi dopo che la persona
aveva cominciato a parlare. La chiusura segue la regola dell'ordine EJ voce
01 (una frase trascritta senza parole non e' presenza); il difetto e' la
trascrizione vuota, PROVENIENZA IGNOTA, il servizio di trascrizione.

DOMANDA: risposta del fondatore nell'ordine EQ: "l'attesa deve diminuire ancora"; "approvo i tuoi suggerimenti"
PROVA: docs/collaudo/ER/realme/live_lite/lite.txt
MISURA: dieci turni per qualita', "il Maestro si sente" mediana 5146 ms in standard e 5300 ms in lite (build di prova EQ 5710); "il volto parla" 5529 in standard e 5620 in lite (EQ 6226); dalla risposta al primo audio al volto 354 in standard e 40 in lite; risoluzione ricevuta 256 a 8 secondi e 512 a 25 in tutte e due

## VOCE ER.12, LE RISPOSTE DEL LIVE SI FERMANO ALLA TERZA FRASE

**APERTA IN ATTESA DI VERIFICA**: le frasi dette sono tre e la voce si
accorcia, ma nel merito alla cieca il taglio perde un turno per giro, e
l'ordine chiede che il dopo non scenda sotto il prima. I due turni persi,
tutti e due "al limite": a *"Mia madre dice che è una follia partire. Cosa le
rispondo?"* il taglio toglie la terza frase del corpo, *"Parla del tuo
sentiero, non del suo"*; alla domanda coi tre desideri toglie la parte sul
lavoro. La scelta e' del fondatore: tenere tre frasi, o dire quattro frasi
quando la domanda ha piu' parti.

Fatto (commit `798055fd`): la voce e il testo a video si fermano alla terza
frase intera: due frasi del corpo e il gesto, o le prime tre
(`LeTreFrasiDelLive`). La conversazione scritta tiene la risposta intera.

DOMANDA: domanda girata al fondatore dal rapporto EQ: "Le risposte del LIVE durano da 20 a 50 secondi di voce. Le vuoi più corte, come chiedeva l'ordine EN ("tre frasi")?", risposta: "approvo i tuoi suggerimenti"
PROVA: docs/collaudo/ER/live_tre_frasi.txt
MISURA: sulle stesse 72 risposte vere del LIVE con Flash (due giri), turni con piu' di tre frasi dette da 25 e 9 su 36 a 0 su 36; frasi tagliate a meta' 0; nel merito alla cieca da 20 a 19 su 36 e da 23 a 22 su 36 (docs/collaudo/ER/ciechi/conti.txt); sul Realme la durata vera della voce da 29,0 s di mediana (LIVE di Calìgo, ordine EQ) a 13,2 s (build 2285, docs/collaudo/ER/live_macchina.txt)

## VOCE ER.13, LA DOMANDA E LA RISPOSTA SI SCRIVONO COME A MACCHINA

**CHIUSA.** Sul Realme la domanda si scrive a macchina appena trascritta, e la
risposta comincia a scriversi prima della voce, in tutti e dieci i turni.

Fatto (commit `798055fd`): `LaMacchinaDaScrivere`, la domanda a macchina e la
risposta dalla prima parola arrivata, a 40 lettere al secondo, mai indietro
rispetto alla voce; tappe nuove nel registro.

DOMANDA: "Vorrei suggerire, ma non so se può essere utile, di scrivere le domande e le risposte nella chat live con animazione da macchina da scrivere, in questo modo mentre c'è l'animazione di scrittura l'attesa sembrerà più breve per l'utente [...] La voce partirà appena possibile in ogni caso."
PROVA: docs/collaudo/ER/live_macchina.txt
MISURA: secondi a testo fermo fra la fine della domanda e la voce del Maestro, mediana, da 3,09 s (build di prova EQ, la risposta compariva al primo testo) a 2,00 s; "il Maestro si sente" mediana da 5710 a 5146 ms, non sopra il prima; turni in cui la voce dice parole non ancora scritte, 0 su 9; catture in raffica di tre turni in docs/collaudo/ER/realme/er13_macchina_turno1_raffica.jpg e seguenti

## PARTE 6, DIFETTI TROVATI DALL'ARCHITETTO

## VOCE ER.14, L'OROSCOPO CAMBIA OGNI GIORNO IN TUTTE LE SUE PARTI

**CHIUSA.** Sul Realme i Gemelli del 27 settembre leggono "Sguardo verso il
futuro", "Desideri a lungo termine", "Visione condivisa", "Desideri in
cammino"; dopo mezzanotte, il 28, "Amici e progetti", "Amicizia e
tenerezza", "La forza della rete", "Amici portafortuna": gli stessi della
prova.

Fatto (commit `84c97a81`): titolo e prima parte li sceglie la casa che la
Luna attraversa contando dal segno (`Horoscope.casaDellaLuna`, calcolata sul
telefono da `NightSky`), con la variante del giorno; il corpus nuovo sta in
`docs/corpus/oroscopo.md`, sezione "Il giorno nelle dodici case". La prima
parte e' anche la frase della card da condividere. **Difetto visto sul
telefono, mio**: *"AMICI PORT / AFORTUNA"* (padre ER.14, titoli piu' lunghi in
una colonna di 124 punti); alla 2286 il titolo va a capo col trattino sulla
sillaba, come in home.

DOMANDA: domanda girata al fondatore: "Scrivo l'ordine ER con rune e Viaggio? Ci metto anche l'Oroscopo (la prima metà delle schede, oggi uguale tutti i giorni)?", risposta: "Sì, con l'Oroscopo".
PROVA: docs/collaudo/ER/oroscopo.txt
MISURA: schede col titolo identico al giorno prima, da 48 su 48 a 0 su 48 per ognuno dei sei passaggi di giorno; schede con la prima parte identica al giorno prima, da 48 su 48 a 0 su 48 per ognuno dei sei passaggi; in un anno 0 su 17568; dodici titoli diversi per i dodici segni nello stesso giorno; sul Realme due giorni di fila (docs/collaudo/ER/realme/er14_oroscopo_giorno1_02.jpg, er14_oroscopo_giorno2_02.jpg); titoli spezzati dentro una parola da 1 (2285) a 0 su 144 (2286)

## VOCE ER.15, L'AZIONE DEL VIAGGIO NON È SEMPRE IL FOGLIO

**CHIUSA.** L'esempio del foglio e' uscito dall'istruzione, l'azione nasce
dalla domanda, il divieto del fuoco resta; le azioni gia' date alla persona
arrivano al modello e la lettura scarta quella che ne somiglia una; e
scrivere su un foglio o in una lista non passa mai, mentre scrivere a una
persona e' un gesto e passa. Sul Realme: *"domani mattina invia un messaggio a
tuo fratello"* e *"oggi pomeriggio, invece di usare i mezzi, fai a piedi il
tragitto da casa al lavoro"*.

DOMANDA: domanda girata al fondatore: "Scrivo l'ordine ER con rune e Viaggio? Ci metto anche l'Oroscopo (la prima metà delle schede, oggi uguale tutti i giorni)?", risposta: "Sì, con l'Oroscopo", dopo il messaggio dell'Architetto che nominava le azioni col foglio.
PROVA: docs/collaudo/ER/viaggio/giro7_esecuzione1.txt
MISURA: azioni che chiedono di scrivere su un foglio, da 4 su 6 (catture DN) e 12 su 20 (commit 3a2c12d3) a 1 e 1 su 20 (giro 7, due esecuzioni, giro7_esecuzione1.txt e giro7_esecuzione2.txt); azioni uguali o simili fra le dieci discese della stessa persona, da 1 a 0 e 0; sul Realme 0 su 2

## VOCE ER.16, "LE STA ADDOSSO"

**CHIUSA.** Sul Realme, alla 2286: *"Il tuo gemello astrale è Giorgio Armani,
ma Damiano David gli sta addosso"*, il pronome col genere del primo; tutte e
cinquanta le frasi nella prova.

Fatto (commit `e393f4e7`): ogni VIP del catalogo ha il suo genere
(`vip_catalog.dart`), e la riga del distacco in `gemello_astrale.dart` dice
"le sta addosso" o "gli sta addosso" secondo chi e' al primo posto. Guardia
nuova `i_vip_hanno_nome_e_genere`.

DOMANDA: domanda girata al fondatore: "Quali dei miei rilievi sulle tue catture metto in fondo all'ordine ER?", risposta: ""gli sta addosso", Distanza detta due volte, "Venere Quadratura Marte", "Beyonce" senza accento".
PROVA: docs/collaudo/ER/gemello_frasi.txt
MISURA: frasi del distacco col pronome sbagliato, da 21 su 50 a 0 su 50; sul Realme docs/collaudo/ER/realme/er06_2286_gemello_03_responso.jpg

## VOCE ER.17, LA DISTANZA SI DICE UNA VOLTA

**CHIUSA.** Sul Realme il responso con Margot Robbie, senza luogo pubblico,
dice una volta sola che la distanza non entra nel conto.

Fatto (commit `e393f4e7`): la nota del luogo ignoto sotto la barra
dell'incontro e' uscita (`possibilita_di_incontro.dart`); la cosa la dice una
volta sola la frase dell'incontro. Guardia nuova
`la_sinastria_dice_le_cose_una_volta_e_in_italiano`, che conta le volte.

DOMANDA: domanda girata al fondatore: "Quali dei miei rilievi sulle tue catture metto in fondo all'ordine ER?", risposta: ""gli sta addosso", Distanza detta due volte, "Venere Quadratura Marte", "Beyonce" senza accento".
PROVA: docs/collaudo/ER/realme/er17_responso_margot_03.jpg
MISURA: responsi che dicono piu' di una volta che la distanza non entra nel conto, sui 21 VIP senza luogo pubblico, da 21 su 21 (commit di partenza 3a2c12d3, docs/collaudo/ER/conti_di_prima_3a2c12d3.txt) a 0 su 21 (docs/collaudo/ER/sinastria_guardie.txt); sul Realme una volta sola su una

## VOCE ER.18, "VENERE QUADRATURA MARTE" DENTRO LA FRASE

**CHIUSA.** Sul Realme: *"Oggi Giove tocca i gradi dove la Luna di Beyoncé è
in opposizione con la tua Venere"* e *"Oggi Saturno tocca i gradi dove il Sole
di Margot Robbie è in quadratura con il tuo Marte"*.

Fatto (commit `e393f4e7`): `cielo_del_giorno_sulla_coppia.dart` non mette piu'
il titolo dell'aspetto dentro la frase: *"Oggi Marte tocca i gradi dove la
Venere di Margot Robbie è in quadratura con il tuo Marte"*, per le tre forme
(tocca, sfiora, nessun passaggio) e per i cinque aspetti.

**Lo stesso difetto in un'altra frase**,
visto sul telefono alla 2286: il "Perche' proprio lui" del Gemello scriveva
*"Venere Quadratura Luna, Mercurio Sestile Venere e Sole Sestile Venere"*
(padre il Gemello del 31 agosto, commit d24b7308). Corretto nel codice:
*"la sua Venere in quadratura con la tua Luna"*. **Il conto di prima**,
chiesto dal fondatore con l'aggiunta 2: misurato sul commit di partenza
`3a2c12d3`, con gli stessi 50 VIP, la stessa persona e la stessa regola della
prova di dopo, **50 su 50**; dopo **0 su 50**
(`docs/collaudo/ER/conti_di_prima_3a2c12d3.txt`).

DOMANDA: domanda girata al fondatore: "Quali dei miei rilievi sulle tue catture metto in fondo all'ordine ER?", risposta: ""gli sta addosso", Distanza detta due volte, "Venere Quadratura Marte", "Beyonce" senza accento".
PROVA: docs/collaudo/ER/cielo_del_giorno.txt
MISURA: frasi del cielo del giorno col titolo dell'aspetto in maiuscolo dentro la frase, da 15 su 15 (le tre forme mettevano tutte il titolo, commit 3a2c12d3) a 0 su 15; il perche' proprio lui del Gemello coi titoli dentro la frase da 50 su 50 VIP (3a2c12d3) a 0 su 50 (docs/collaudo/ER/conti_di_prima_3a2c12d3.txt); sul Realme docs/collaudo/ER/realme/er05_responso_04.jpg

## VOCE ER.19, BEYONCÉ

**CHIUSA.** Sul Realme la carta dice "Beyoncé". **Difetto visto sul
telefono, mio**: alla 2285 chi cercava "beyonce" non la trovava piu' (padre
ER.19); alla 2286 la ricerca toglie i segni e la trova.

Fatto (commit `e393f4e7`): i nomi del catalogo dei VIP portano i loro segni
("Beyoncé"); la ricerca li trova anche scritti senza. La guardia degli accenti
della sinastria cercava solo le vocali con l'apostrofo in fondo e non vedeva
questo difetto (PROVENIENZA IGNOTA): lo copre adesso
`i_vip_hanno_nome_e_genere`, vista rossa.

DOMANDA: domanda girata al fondatore: "Quali dei miei rilievi sulle tue catture metto in fondo all'ordine ER?", risposta: ""gli sta addosso", Distanza detta due volte, "Venere Quadratura Marte", "Beyonce" senza accento".
PROVA: docs/collaudo/ER/realme/er19_carta_beyonce.jpg
MISURA: nomi del catalogo scritti senza il loro segno, da 1 ("Beyonce") a 0; ricerche senza segni che non trovano il VIP, da 1 (2285) a 0 su 3 VIP coi segni (2286, er19_2286_ricerca_beyonce.jpg)

## PARTE 7, L'AGGIUNTA DEL FONDATORE

## VOCE ER.20, IL SEGRETO DELL'IRIDE ENTRA NEL CATALOGO, NEL DOMINIO DI AURA E NELLA HOME

**CHIUSA.** Sul Realme la scheda sta nel dominio di Aura, Fisiognomica, dopo
lo Specchio dell'Anima; in "Il tuo corpo" dopo Magia Verde e in fondo a "I più
condivisi"; il dorso dice "La tua iride, letta come una mappa di segni." e "In
arrivo, Fase 2".

Fatto (commit `171f9e4c`): "Il Segreto dell'Iride" e' nel catalogo, di Aura,
in arrivo, Fase 2, col dorso "La tua iride, letta come una mappa di segni."
e i tre webp del PC. Sta nel dominio di Aura, sezione Fisiognomica, dopo lo
Specchio dell'Anima; in home in "Il tuo corpo" dopo Magia Verde e in "I più
condivisi"; e in "La tua energia" entra Cosmic Voice Analysis.

DOMANDA: "Ci siamo dimenticati di creare asset per scansione occhio e inserirlo in home"; "Ordine già lanciato. Scrivi un mini ordine da aggiungere per l'occhio. Nome evocativo scegli tu"; decisione del fondatore sulla lettura dell'iride: di Aura, in Fase 2, fuori dalla Demo.
PROVA: docs/collaudo/ER/iride_sfondi.txt
MISURA: webp del Segreto dell'Iride in assets/schede uguali byte per byte a quelli del PC, da 0 su 3 a 3 su 3; arti del catalogo visibili in home, da 66 a 67; coppie di schede vicine dello stesso Maestro nelle righe Il tuo corpo, I più condivisi e La tua energia, 0 (docs/collaudo/ER/righe_della_home.txt); sul Realme docs/collaudo/ER/realme/er20_iride_dominio_aura.jpg, er20_iride_dorso.jpg, er20_iride_i_piu_condivisi.jpg, er20_iride_il_tuo_corpo.jpg
