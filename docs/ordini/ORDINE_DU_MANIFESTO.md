# ORDINE DU, L'ARCANO DELL'ALBA DIVENTA UNA SCENA

**Sigla:** DU. **Data:** 17 settembre 2026. **Ramo:**
`claude/esoteric-circle-master-order-e798aj`. Parte dal commit `a6d684c2`.

**Il fatto, dalle parole del fondatore**: l'Arcano dell'Alba consegnato con la
2266 e la 2267 e' *"un compitino"*: tre carte coperte su un fondo nero, nessuna
animazione, e riaprendo si vede solo la carta scelta. **Ha ragione, ed e' mio**:
l'ordine DT non chiedeva una scena e io non l'ho proposta.

VOCI_TOTALI: 14
VOCI_CHIUSE: 14
VOCI_APERTE: 0
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0

Il rapporto sta in `docs/ordini/RAPPORTO_ORDINE_DU.md`.

---

## I FATTI, RISCONTRATI SUL CODICE PRIMA DI USARLI

| cosa dice l'ordine | il riscontro | esito |
|---|---|---|
| si sceglie fra tre carte | **vero**: `ArcanoDellAlbaScreen.carteCoperte = 3`, riga 75 | **VERO** |
| lo sfondo e' nero | **vero**: la schermata non monta `CosmosBackground`, al contrario della Stesa (`stesa_tre_carte_screen.dart`, riga 1063) | **VERO** |
| non c'e' nessuna animazione | **quasi**: c'e' il solo giro della carta, `_giro`, 700 ms. Non c'e' ingresso, non c'e' respiro, non c'e' Medora | **VERO NELLA SOSTANZA** |
| riaprendo si vede solo la carta scelta | **vero**: `_riprendi` porta `_giro.value = 1`, riga 136 | **VERO** |
| l'Arcano dell'Alba non consuma il budget dei tarocchi | **gia' cosi'**, e una prova lo misura: `l_arcano_dell_alba_si_gira_test.dart`, *il limite delle stese non si tocca* | **GIA' VERO** |
| zero disclaimer | **gia' cosi'**: nessun disclaimer nella schermata ne' nei suoi testi | **GIA' VERO** |
| i dorsi sono simmetrici perche' il verso non si sappia | **gia' cosi'**, misurato: il dorso ruotato di mezzo giro scarta in media 5,37 su 255 | **GIA' VERO** |

**E IL FATTO PIU' IMPORTANTE, che cambia la forma di quest'ordine**: la scena
che l'ordine descrive **esiste gia' e gira**, nella Stesa dei Tarocchi.
`StesaScene.ingresso` e' documentata cosi', parola per parola: *"Le carte
nascono dal fondo stellato, orbitano Medora e scendono a ventaglio"*
(`lib/features/tarot/stesa_choreography.dart`, riga 15). Ci sono
`MedoraStage`, `StesaFan` con l'arco sfogliabile su tutto il mazzo e il numero
di carte gia' parametrico (`carte`, riga 61), la posa a spirale, il respiro del
ventaglio e il volo della carta scelta. **Non si scrive una seconda scena: si
usa questa con ventidue dorsi.**

**Questo fatto e' stato superato dal fondatore il 17 settembre 2026**, e resta
scritto qui perche' spiega perche' la prima stesura era un ventaglio. Il
riscontro sul codice era giusto, la conclusione no: riusare il ventaglio della
Stesa dava all'Alba la stessa scena della Stesa, e l'Alba ha ventidue carte
mentre la Stesa ne ha settantotto. La correzione sta qui sotto.

---

## LE DECISIONI DI MAURO, CHIESTE PRIMA DI COMINCIARE

1. **La forma del dono**: ogni arcano da' la sua **parola**, legata alla carta,
   piu' l'azione. Nessuna carta resta senza parola.
2. **La scena**: ventaglio davanti a Medora, ingresso a vortice. **Revocata
   dal fondatore il 17 settembre 2026**, vedi la correzione di rotta.
3. **Riaprendo**: si torna al responso, come oggi. La scena si rivede domani.
4. **Il corpus**: **dodici letture per stato, 528 testi.**

---

## LA CORREZIONE DI ROTTA DEL 17 SETTEMBRE

La prima stesura della scena e' stata mostrata a Mauro e respinta, con due
messaggi che cambiano due voci e nessun'altra.

**Il primo, sul ventaglio**: *"non mi piace il ventaglio, e' identico alla
funzionalita' stesa dei tarocchi e vorrei qualcosa di originale. Essendo solo
22 carte, queste potrebbero entrare in scena con animazione Wow e posizionarsi
tutte sulla schermata magari su 2 righe da 11 carte leggermente sovrapposte, o
3 righe, valuta tu mentre continuano a fluttuare. Puoi lasciare i pulsanti
mischia e taglia, ma crea animazioni originali con stelline e scia di stelline
che seguono la carta selezionata mentre gira per rivelarsi. Il responso va
bene."*

**Il secondo, su Medora**: *"togli anche la figura avatar di Medora."*

Cosa cambia, e cosa no:

| voce | prima | dopo |
|---|---|---|
| DU.04 | Medora in scena, le carte le orbitano intorno | **nessun avatar**: il tavolo e' la scena |
| DU.05 | il ventaglio della Stesa con ventidue carte | **il tavolo dei ventidue**: tutte le carte in vista su piu' righe sovrapposte, mischia e taglia, stelline |
| le altre dodici | | **invariate** |

## LA SECONDA CORREZIONE, SULLA SCENA GIA' RIFATTA

Il tavolo e' stato mostrato a Mauro e approvato, con quattro richieste:

1. *"preferirei che le 3 file di carte siano disposte a ventaglio, formano una
   curva e contemporaneamente fluttuano, respirano"*;
2. *"usa anche il suono della carta che si gira che hai usato nella stesa dei
   tarocchi se non l'hai gia' usato"*;
3. *"Mischia e taglia all'interno di 2 bolle, come pulsanti"*;
4. *"il testo in alto che invita a scegliere la carta e' un po' anonimo, serve
   un titolo in giallo oro evocativo tipo 'la carta del destino di oggi' o
   qualcosa del genere. E sotto il testo che c'e' gia'"*.

Cosa e' cambiato, in numeri:

| richiesta | cosa fa adesso |
|---|---|
| il ventaglio | ogni riga e' un arco: la carta centrale sta 11,1 punti piu' in alto dei bordi, e i bordi si inclinano di 0,13 radianti in versi opposti. Il respiro si somma alla posa, non la sostituisce |
| il suono | il mezzo giro passa da `SensiDellaStesa`, la stessa porta della Stesa, e fa uscire `carta.mp3` dalla porta unica del Cerchio |
| le bolle | Mischia e Taglia sono due cerchi da 92 punti, con l'alone del Maestro dentro e il bordo d'oro, e restano `TextButton` perche' la guardia dei comandi li conta |
| il titolo | *"La carta del destino di oggi"*, nell'oro del Cerchio, sopra l'invito che resta dov'era |

## LA TERZA CORREZIONE, SULLA CARTA E SUL RESPONSO

Guardando le anteprime il fondatore ha visto altre due cose, e tutte e due
erano vere e misurabili.

**La carta rivelata era piccola**: *"c'e' molto spazio intorno e sembra una
schermata vuota"*. Un tetto di 2,6 sulla scala la fermava a 140 punti su 360,
cioe' il 39 per cento della larghezza. Adesso la carta arriva al **60 per
cento**, e il titolo, mentre si spegne, **chiude anche il suo spazio** invece
di lasciare il buco. Riparando il primo difetto e' venuto fuori il secondo: la
pila del tavolo tagliava la carta ingrandita di trentasette punti, perche' la
scatola cresceva ma il punto d'arrivo restava il centro della scatola di prima.
I due conti adesso sono uno solo.

**Il responso non diceva che cos'era.** *"La parola deve essere dichiarata tipo
'la parola di oggi:' e l'utente deve sapere cosa farsene: vuole risposte
chiare, dirette e ognuna guida"*. La parola stava da sola in maiuscolo grande.
Adesso il responso scorre cosi', e la guardia pretende quest'ordine a video:

| pezzo | cosa dice |
|---|---|
| la riga del dono | *Oggi Medora ha letto il tuo momento* |
| il primo movimento | la carta col verso e l'attribuzione |
| **La parola di oggi** | l'etichetta, poi la parola in grande |
| la riga dell'uso | *Tienila a mente quando devi scegliere: e' il filo di oggi* |
| **Il gesto di oggi** | l'etichetta, poi il dono, che e' la cosa da fare |
| la chiusa | Medora, in corsivo, col filo di ieri quando c'e' |

---

**Un difetto trovato guardando l'anteprima, non deducendo**: il titolo e
l'invito non si spegnevano mentre la carta volava. L'opacita' si calcolava
dentro la costruzione della schermata, che non ascolta il comando della
rivelazione: restavano accesi per tutto il volo e sparivano di colpo alla fine.
Adesso li avvolge un `AnimatedBuilder`, e una guardia misura l'opacita' a meta'
volo.

---

**La scelta del numero di righe e' mia, come Mauro ha chiesto**, e si misura:
sopra i 420 punti di larghezza il tavolo fa due righe da undici, sotto ne fa
tre da otto, sette e sette. Su un telefono da 360 punti undici carte per riga
lascerebbero a ogni dorso meno di trentadue punti, e un dorso di trentadue
punti non si distingue e non si tocca.

---

## LE VOCI

- **DU.01**, il fatto: l'Arcano dell'Alba non e' una scena. Adesso lo e': fondo
  stellato, ventidue dorsi che entrano a spirale, si posano e respirano, e la
  carta che sale girandosi con la scia di stelline.
  `test/ordine_du_guard_test.dart` e `test/il_tavolo_dei_ventidue_test.dart`.
  **CHIUSA.**
- **DU.02**, i ventidue dorsi: si vedono tutti e ventidue e si sceglie fra
  tutti e ventidue, tutti in vista sul tavolo. Misurato a 360 punti: ventidue
  dorsi larghi 56,3 punti, dentro lo schermo, ognuno col suo tocco.
  **CHIUSA.**
- **DU.03**, i cartigli non restano vuoti, ne' sulla carta girata ne' dove una
  carta compare. Misurato sulla carta girata: il cartiglio del numerale e
  quello del nome portano testo dipinto, a misura maggiore di zero.
  **CHIUSA.**
- **DU.04**, nessun avatar in scena: l'Arcano dell'Alba non monta Medora, per
  decisione del fondatore del 17 settembre 2026. La voce nasceva col contrario
  e resta qui col suo nuovo contenuto, perche' una voce revocata in silenzio e'
  una voce che torna. Misurata: `MedoraStage` non compare piu' nel codice della
  schermata, e la guardia e' stata vista rossa innestandolo.
  **CHIUSA.**
- **DU.05**, il tavolo dei ventidue e' dinamico: le carte entrano a spirale, si
  posano su **tre archi a ventaglio** e fluttuano ognuna col suo tempo; mischia
  e taglia, dentro due bolle, le rimettono in gioco; la carta toccata sale con
  la scia di stelline e il suono della Stesa. Misurato: a un quarto di secondo
  dall'ingresso le carte sono lontane dalla loro posa di riposo, a tavolo
  posato continuano a muoversi con scarti diversi fra loro, Mischia sposta piu'
  di quindici carte su ventidue, la carta centrale di ogni riga sta 11,1 punti
  sopra i bordi e i bordi pendono in versi opposti.
  **CHIUSA.**
- **DU.06**, nessuna voce: Medora non parla e non c'e' nessun Protoface. Ne'
  la schermata ne' il tavolo nominano `Protoface`, il parlato o una sintesi.
  **CHIUSA.**
- **DU.07**, il verso non si sa prima: i dorsi restano simmetrici e nessun
  segno anticipa dritto o rovescio. Il dorso ruotato di mezzo giro scarta in
  media 5,37 su 255 e oltre 48 in zero punti su 121.695; toccando due dorsi
  diversi collo stesso caso esce lo stesso stato.
  **CHIUSA.**
- **DU.08**, il responso parte dalla carta: la parola e' della carta scelta, e
  il dono e la chiusa nascono da lei. Tutte e 528 le letture hanno la loro
  parola, e in tutte il dono la porta.
  **CHIUSA.**
- **DU.09**, il respiro e' di Aura: come forma del dono dell'Alba non esiste
  piu'. Due doni lo prescrivevano ancora, *"allunga il respiro quattro volte"*
  e *"rallenta il fiato"*: riscritti, e adesso una guardia guarda tutti e 528 i
  doni e non ne lascia passare nessuno col fiato.
  **CHIUSA.**
- **DU.10**, zero disclaimer. Ne' la schermata ne' il tavolo ne nominano uno.
  **CHIUSA.**
- **DU.11**, l'estrazione non ha vincoli: la stessa carta puo' uscire due
  giorni di fila, come alla roulette. Su centomila giri la stessa carta torna
  nel 4,5 per cento dei casi e lo stesso stato nel 2,2, cioe' le frequenze del
  caso; il sacchetto e' stato tolto e nessuna riga di codice dei ventidue file
  dell'Alba lo nomina piu'.
  **CHIUSA.**
- **DU.12**, zero ripetizioni nei testi: dodici letture per stato e i registri
  della persona. Le 528 letture passano la guardia su 4.193.280 combinazioni di
  apertura, clausola e filo, e su 3.300 consegne simulate i ripieghi sono 4.
  **CHIUSA.**
- **DU.13**, il budget dei tarocchi resta intatto: girare la carta non muove il
  contatore delle stese.
  **CHIUSA.**
- **DU.14**, il Soffio del Destino: via il cerchio disallineato, sono i petali
  a ingrandirsi e a ridursi. Misurato sui pixel: senza anelli la circonferenza
  piu' accesa sta al 6 per cento, coll'anello innestato al 69; le punte contate
  sono ventiquattro e fra fiato pieno e fiato vuoto i petali cambiano di 17
  punti in mediana.
  **CHIUSA.**
---

## COME SI MISURA, VOCE PER VOCE

Ogni voce ha la sua prova, e ogni prova nasce rossa.

| voce | la grandezza misurata |
|---|---|
| 02 | i dorsi montati sono ventidue distinti, tutti sullo schermo, e ognuno dei ventidue si puo' toccare |
| 03 | girata la carta, il cartiglio del numerale e quello del nome portano testo |
| 04 | nessun `MedoraStage` e nessun avatar nella schermata dell'Alba |
| 05 | senza Riduci Movimento le pose dell'ingresso non sono quelle di riposo, il tavolo respira, ogni riga e' un arco con le carte dei bordi inclinate, mischia e taglia cambiano la disposizione senza cambiare l'esito, il titolo si spegne mentre la carta vola e il mezzo giro fa uscire il suono della carta dalla porta del Cerchio |
| 06 | nessun `Protoface`, nessun widget della voce, nessuna chiamata al parlato nella schermata |
| 07 | il dorso ruotato di mezzo giro resta se stesso, e il verso non si legge da nessun dorso prima del tocco |
| 08 | ogni lettura di ogni stato ha la sua parola, e la parola compare nel dono della stessa carta |
| 09 | la parola *respiro* non e' piu' una forma del dono in nessun punto del motore |
| 10 | nessun disclaimer nella schermata |
| 11 | su diecimila giri la stessa carta esce due volte di fila con la frequenza del caso, e nessuna prova la vieta |
| 12 | in tre cicli per venticinque persone nessun testo si ripete, e i ripieghi restano a zero |
| 13 | il limite delle stese non si muove quando si gira la carta |
| 14 | nel Soffio non si disegna piu' nessun cerchio col respiro, e il raggio dei petali cambia col fiato |
