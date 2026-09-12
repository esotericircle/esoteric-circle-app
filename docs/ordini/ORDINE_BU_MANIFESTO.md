# ORDINE BU, LA RESA DELLA STESA E LE FESTE CHE SI ACCAVALLANO

Ordine del fondatore del 27 agosto 2026. Ramo
`claude/esoteric-circle-master-order-e798aj`, guardia
`test/ordine_bu_guard_test.dart`. **Testa di partenza `b800a521`**, verificata
sul ramo: e' la testa che l'ordine BT ha lasciato dopo la consegna della 2208.

**Parole del fondatore, sulla build 2208**: "perche' la carta chiave ha ancora
una sovrapposizione di Giallo? non voglio nessuna sovrapposizione che peggiora
la visualizzazione della carta, ho chiesto la cornice"; "perche' se faccio click
su una carta il testo e' chiaro sottolineato di giallo?"; "quando parte il
calcolo con l'animazione di riflessione, se c'e' una festa la riflessione non si
vede perche' sopra c'e' la festa"; "il viandante ha una stesa al giorno"; "le
feste ce ne sono ancora attaccate". E dal messaggio del 26 agosto, mai eseguito
finora: "il testo nella bolla del consiglio di Medora e' monotono, tutto giallo e
senza paragrafi. inoltre e' scritto piccolo. anche le altre bolle hanno il font
piccolo"; "nel menu' a tendina delle opzioni di stesa, in alto deve esserci
scegli la tua domanda, non argomento"; "anziche' nel momento che vivi, carta per
carta scrivi ma in grande LE CARTE, UNA ALLA VOLTA".

## Le premesse, tutte e sei verificate sul ramo prima di scrivere una riga

- **P1 VERA.** `carta_ingrandita.dart` usava
  `barrierColor: Colors.black.withValues(alpha: 0.72)`, riga 39.
- **P2 VERA.** La bolla della carta chiave aveva fondo
  `palette.primary.withValues(alpha: 0.62)`, bordo oro a 0.95 di larghezza 2 e
  un `boxShadow` oro a 0.28. **In piu', e la premessa non lo diceva**: anche il
  segno SULLA CARTA portava un `boxShadow` oro a 0.45 con diciotto di sfocatura,
  ed e' quello che il fondatore vedeva come sovrapposizione gialla.
- **P3 VERA.** `tarot_selectors.dart` scriveva `titolo: 'Scegli argomento'`,
  riga 268.
- **P4 VERA.** `functions/src/budget.ts` portava `stese: [0, 0, 5, null]`.
- **P5 VERA.** `attesa_di_medora.dart` ha una durata di 2.600 millesimi.
- **P6 VERA, verificata sul server e non sulla parola.** `gcloud functions list`
  dice `statoDelCerchio`, `consumaDelGiorno` e `muoviGliEos` tutte **ACTIVE**,
  aggiornate il 27 agosto 2026 alle 16:15 UTC.

## Le cinque voci

- **BU.01** La stesa si legge. **CHIUSA.** Il velo della carta ingrandita e'
  opaco pieno; il consiglio di Medora sale alla misura di lettura, lascia l'oro
  e tiene i paragrafi separati; le altre bolle e le didascalie di contenuto
  salgono anche loro; il selettore chiede "Scegli la tua domanda"; l'intestazione
  della lista dice "LE CARTE, UNA ALLA VOLTA" in grande. Nessun contenuto di
  responso e' stato toccato.
- **BU.02** La carta chiave porta una cornice e niente altro. **CHIUSA.** Sopra
  la carta non si disegna piu' niente: via l'alone, resta la sola linea, e passa
  dall'oro all'azzurro della palette. La bolla chiave perde il fondo colorato e
  l'alone e tiene la stessa cornice azzurra col fondo delle altre.
- **BU.03** La festa non copre mai un'animazione in corso. **CHIUSA.** Finche'
  una riflessione va, la festa non si apre; appena la scena e' libera si apre.
  Vale per le tre riflessioni dell'app: la stesa, l'Oroscopo e la Sinastria.
- **BU.04** Il Viandante ha una stesa al giorno. **CHIUSA.** Limiti `stese` da
  `[0, 0, 5, null]` a **`[1, 0, 5, null]`**, sul server e sulla matrice.
- **BU.05** Le feste attaccate, misurate. **CHIUSA**, e la risposta e' che la
  legge dell'ordine BS regge: **zero coppie nate dallo stesso gesto**.

## BU.01, i numeri della resa

| misura | esito | preteso |
|---|---|---|
| opacita' del velo della carta ingrandita, letta dalla rotta viva | **1,0** | 1,0 |
| testi di contenuto enumerati | **9** | tutti |
| il piu' piccolo fra loro | **18,0** | almeno 18, la misura di lettura |
| paragrafi del consiglio | **4** | almeno 2 |
| colore del consiglio | il colore del testo, **non l'oro** | non oro |
| le due etichette | "LE CARTE, UNA ALLA VOLTA" e "Scegli la tua domanda" | quelle |

**COSA SI E' ALZATO, uno per uno**: la frase di chiusura della stesa, le tre
sintesi sotto le carte, i tre testi delle bolle di posizione, la marcatura della
carta chiave e il consiglio di Medora. **Cosa NON si e' alzato, ed e' voluto**:
il conto delle stese, l'etichetta "Rovesciata" e le targhette col simbolo. Sono
testi di servizio, non cose da leggere: alzarli avrebbe fatto gridare le
didascalie.

## BU.02, la cornice e niente altro

| misura | esito |
|---|---|
| fondo del segno sulla carta | **nessuno** |
| ombre del segno | **zero** |
| colore della cornice | l'azzurro della palette, `glow` |
| pixel scuri dentro la carta chiave | **1.913**, contro 1.045 e 1.671 delle altre due |
| fondi delle tre bolle | **tutti e tre uguali** |
| ombre delle tre bolle | **zero, zero, zero** |

**LA MISURA DELL'ORDINE BN VOCE 05 E' STATA RIFATTA SULLA FORMA NUOVA, e i
numeri vecchi e nuovi vanno detti tutti e due.** Contava l'ORO in una cornice di
sei punti attorno a ogni carta, col predicato "il rosso domina sul blu di 25", e
pretendeva che attorno alla chiave ce ne fosse almeno una volta e mezza che
attorno alle altre. Adesso la cornice e' azzurra, quindi il predicato conta
l'AZZURRO **chiaro**: blu maggiore di 150 **e** blu che domina il rosso di 60. Il
predicato e' piu' stretto di quello dell'oro per una ragione precisa: lo sfondo
dell'app e' gia' blu scuro (18, 32, 74), e la sola dominanza del blu avrebbe
contato tutte e tre le carte allo stesso modo. **I numeri nuovi**: attorno alla
chiave **887, 889 e 891** sui tre semi provati, attorno alle altre **zero**. La
soglia di una volta e mezza non e' stata toccata.

## BU.03, la festa aspetta che la scena sia libera

**NON E' UN TIMER E NON E' UNA CODA A FREDDO**, e la differenza e' tutta qui: la
festa non viene rimandata di un TEMPO, viene rimandata di una CONDIZIONE.
Finche' la scena sta raccontando qualcosa la festa aspetta; appena quella
finisce, si apre. Se la riflessione dura mezzo secondo la festa arriva mezzo
secondo dopo, e se non c'e' nessuna riflessione arriva nell'istante del gesto.
**L'ordine BS resta intatto.**

La forma e' quella di `FesteInCorso`, ed e' voluta: un elenco di domande a cui si
sa rispondere, non un contatore. Con un contatore, una scena buttata via senza
chiudere lascerebbe il conto a uno per sempre e da quel momento **nessuna festa
si aprirebbe piu'**.

| misura | esito |
|---|---|
| fotogrammi con la riflessione in corso in cui la festa e' comparsa | **0 su 30** |
| la festa passa appena la scena e' libera | **si'** |
| riflessioni dichiarate | **3 su 3**: la stesa, l'Oroscopo, la Sinastria |

Gli Eos e il Sigillo restano accreditati nell'istante del gesto: la festa che
aspetta va in coda, e la coda riparte da sola appena la riflessione finisce.

## BU.04, una stesa al giorno al Viandante

I limiti passano a **`[1, 0, 5, null]`**. **Solo la prima cella cambia, e la
ragione e' scritta nell'ordine**: per l'Iniziato l'ordine proponeva 3, ma quel
numero non e' dichiarato da nessuna parte, il listino dice "Eos scontati", e la
regola di casa dice di tenere quello di oggi. L'Adepto era gia' a cinque.

**LA CELLA DELLA MATRICE E' CAMBIATA, e non poteva restare com'era**: chi legge i
limiti guarda prima se nella cella c'e' scritto "Eos" e in quel caso risponde
zero. "Eos pieno" valeva zero, e anche "1 al giorno, poi Eos" sarebbe valso zero.
La cella dice adesso "1 al giorno", e la strada degli Eos resta dopo la stesa
del giorno, a 150 Eos, dove il gating la apre.

| misura | esito |
|---|---|
| la prima stesa del giorno da Viandante | **passa senza chiedere Eos** |
| la seconda | **apre l'invito**, col prezzo di 150 Eos |
| il conto a video da Viandante | **"Stese di oggi: 1 di 1"** |
| server e matrice | **concordano** sul numero nuovo |

## BU.05, le feste attaccate: i numeri

**LA LEGGE DELL'ORDINE BS REGGE.** Sul percorso vero del fondatore, simulato nel
suo ordine (onboarding, primo soffio, prima alba, primo oroscopo, prima stesa,
prima gettata):

| gesto | traguardi soddisfatti | feste |
|---|---|---|
| onboarding | 2 | **1** (med_1) |
| soffio | 2 | **1** (aur_1) |
| alba | 3 | **1** (aur_2) |
| oroscopo | 3 | **1** (med_6) |
| stesa | 3 | **1** (med_3) |
| gettata | 3 | **1** (cal_1) |

**Sei feste da sei gesti distinti, e zero coppie nate dallo stesso gesto.** Ogni
volta c'erano due o tre traguardi soddisfatti e ne e' stato acceso uno.

**QUINDI IL DIFETTO NON E' LA LEGGE, E NON SI CURA QUI.** Cio' che il fondatore
vede come "feste attaccate" e' che i primi gesti dell'app maturano un traguardo
ciascuno, uno dietro l'altro: sei gesti in tre minuti fanno sei feste, ognuna
legittima e ognuna da un gesto diverso. **Si cura nel catalogo, decidendo quali
gradini dei primi giorni valgono una festa piena, e quella decisione e' del
fondatore.** Qui si dicono i numeri e non si tocca niente.

**IL REGISTRO, perche' la prossima volta non si discuta.** Ogni festa che va a
schermo lascia scritto il gesto che l'ha generata e l'istante, in
`RegistroDelleFeste`: non si vede a video, non tocca il disco, e sa dire quante
coppie consecutive sono nate dallo stesso gesto. Le feste che arrivano dalla coda
si segnano come "dalla coda", perche' il gesto che le ha generate e' un altro e
scrivere quello di adesso farebbe sembrare che due feste nascano insieme.

## La prova del rosso

Per ognuna il difetto e' stato rimesso nel sorgente, **l'iniezione e' stata
verificata dentro il file con un `grep` prima di leggere l'esito**, e il numero
qui sotto e' quello che la prova ha stampato da rossa.

- **BU.01.** Velo rimesso a 0,72, trovato a riga 45. La prova e' caduta stampando
  **opacita' [0.72] invece di 1**.
- **BU.02.** Fondo colorato rimesso sopra la carta chiave, trovato a riga 1462.
  La prova e' caduta dicendo **0 pixel scuri dentro la carta chiave contro
  10.890 e 10.754 delle altre due**: la copertura aveva schiarito tutte le ombre
  della figura.
- **BU.03.** Tolta la condizione sulla riflessione, trovata a riga 122. La prova
  e' caduta dicendo che la festa e' comparsa **al fotogramma 0** dei trenta
  dell'animazione.
- **BU.04.** Limiti rimessi a `[0, 0, 5, null]`, trovati a riga 70. La prova dei
  limiti allineati e' caduta: **"per stese col piano free la matrice promette 1 e
  il server impone 0: una delle due parti sta mentendo, e non si sa quale"**.

**DUE GRANDEZZE MISURATE SONO CAMBIATE, e le ragioni vanno lette prima dei
numeri.** Nessuna soglia e' stata abbassata.

1. **Il velo.** La prima stesura contava l'oro del contenuto dentro il riquadro
   del testo della carta ingrandita: col velo rimesso a 0,72 quel numero restava
   **zero**, perche' dietro quel riquadro, in quella scena, non capita nessun
   titolo oro. La seconda contava i pixel non neri in una fascia fuori dalla
   carta: ma la carta ingrandita dipinge una sua fioritura su tutto lo schermo,
   quindi quella fascia non e' mai velo puro e il numero non cambiava col velo
   (570.568 in tutti e due i casi). La terza misura l'**opacita' della barriera
   letta dalla rotta viva**, che e' cio' che decide davvero se sotto passa
   qualcosa, e scatta.
2. **La copertura della carta.** Contare l'azzurro dentro la carta non
   funzionava: le carte dei tarocchi il blu ce l'hanno dentro (ottanta pixel
   anche senza niente sopra), e un fondo blu traslucido si confonde col loro.
   **Cio' che una copertura fa sempre, qualunque colore abbia, e' schiarire le
   ombre**: un velo al 62 per cento somma il suo colore anche al nero. Si contano
   quindi i pixel SCURI, e il rapporto con le altre due carte separa i due casi
   di netto: 1.913 contro 1.045 e 1.671 senza copertura, **0 contro 10.890 e
   10.754** con la copertura.

## Cio' che questo ordine non ha toccato

La Sinastria VIP, che il fondatore non ha ancora rivisto. Il corpus dei traguardi,
chiuso dall'ordine BS. L'Oroscopo e le sue animazioni, a parte la sola riga che
dichiara la sua riflessione. La home coi tre Maestri. I tre video della
rivelazione.

## La distribuzione delle due funzioni

**FATTA, e verificata sul server.** `firebase deploy --only
functions:statoDelCerchio,functions:consumaDelGiorno` dalla cartella
`functions/`, esito **Successful update operation** per tutte e due.
`gcloud functions list` le dice **ACTIVE**, aggiornate il **27 agosto 2026
alle 21:07 UTC**, contro le 16:15 della distribuzione precedente. **Il timeout
della scoperta e' stato alzato a sessanta prima di cominciare**, come l'ordine
prescrive: il 27 agosto il fondatore aveva incontrato "Cannot determine backend
specification. Timeout after 10000" col codice sano.

## Cinque guardie di casa hanno preso questo ordine

Nessuna delle prove scritte qui le guardava, e ognuna ha trovato una
conseguenza vera del lavoro.

1. **Il testo narrato passa da `ParagrafiDiLettura`.** Quattro testi alzati alla
   misura di lettura erano `Text` diretti: e' la famiglia delle due porte, e da
   li' il muro di testo torna. Adesso passano dalla porta unica, e i paragrafi
   restano separati anche sotto le carte.
2. **La bolla chiave si distingue a pixel oltre la soglia**, prova P.07. Lo
   scarto era sceso a **15,6 livelli contro i 18 dichiarati**, perche' la
   distinzione stava nel fondo e il fondatore ha chiesto di toglierlo. **La
   soglia non e' stata abbassata: si e' spostato il punto in cui si guarda**,
   dalla fascia alta del rientro a due punti sul bordo, cioe' dove la
   distinzione adesso vive.
3. **Il ventaglio resta a portata dopo il secondo pescaggio**, prova della
   coreografia. Coi testi piu' grandi il ventaglio finiva a **861,5 punti su uno
   schermo di 844**, cioe' fuori campo proprio mentre serve. Recuperati venti
   punti di aria fra i blocchi, non di testo: lo spazio sopra il ventaglio da
   sedici a quattro, quello fra la carta e la sua etichetta da otto a quattro, e
   l'interlinea delle sintesi da 1,35 a 1,2. Adesso il ventaglio finisce dentro.
4. **Nessuna riga sotto quattro parole**, prova P.10: leggeva i testi come
   `Text` e ne trovava uno che non lo e' piu'.
5. **Il testo della carta aperta e' quello della bolla**, carattere per
   carattere: la bolla adesso porta i paragrafi separati, e il confronto si fa
   col testo intero che `ParagrafiDiLettura` custodisce nel suo campo.

## La suite, alla chiusura dell'ordine

**3.704 prove verdi e 2 rosse**, con `TZ=Europe/Rome`, **ad albero davvero
fermo**: l'impronta `sha1` di tutti i sorgenti sotto `lib`, `test`, `docs`,
`tool`, `functions/src` e del `pubspec.yaml`, presa prima del primo test e dopo
l'ultimo, e' la stessa, `fbe922ca`. I due rossi sono i due dichiarati:
l'attribuzione cieca dall'ordine BP e `niente_lavoro_non_spinto`, che si chiude
col commit e con la spinta. `flutter analyze`: **zero avvisi**.

MARCATORI, per la guardia:
VOCI_TOTALI: 5
VOCI_APERTE: 0
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0
VOCI_FERMATE_SU_PREMESSA_FALSA: 0
VOCI_FERMATE_SU_DECISIONE_DEL_FONDATORE: 0
VOCI_CHIUSE: 5
