# ORDINE DU, L'ARCANO DELL'ALBA DIVENTA UNA SCENA

**Sigla:** DU. **Data:** 17 settembre 2026. **Ramo:**
`claude/esoteric-circle-master-order-e798aj`. Parte dal commit `a6d684c2`.

**Il fatto, dalle parole del fondatore**: l'Arcano dell'Alba consegnato con la
2266 e la 2267 e' *"un compitino"*: tre carte coperte su un fondo nero, nessuna
animazione, e riaprendo si vede solo la carta scelta. **Ha ragione, ed e' mio**:
l'ordine DT non chiedeva una scena e io non l'ho proposta.

VOCI_TOTALI: 14
VOCI_CHIUSE: 0
VOCI_APERTE: 14
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

**La scelta del numero di righe e' mia, come Mauro ha chiesto**, e si misura:
sopra i 420 punti di larghezza il tavolo fa due righe da undici, sotto ne fa
tre da otto, sette e sette. Su un telefono da 360 punti undici carte per riga
lascerebbero a ogni dorso meno di trentadue punti, e un dorso di trentadue
punti non si distingue e non si tocca.

---

## LE VOCI

- **DU.01**, il fatto: l'Arcano dell'Alba non e' una scena. Quest'ordine lo
  rende tale, e ogni voce qui sotto porta la sua misura. **APERTA**
- **DU.02**, i ventidue dorsi: si vedono tutti e ventidue e si sceglie fra
  tutti e ventidue, tutti in vista sul tavolo. **APERTA**
- **DU.03**, i cartigli non restano vuoti, ne' sulla carta girata ne' dove una
  carta compare. **APERTA**
- **DU.04**, nessun avatar in scena: l'Arcano dell'Alba non monta Medora, per
  decisione del fondatore del 17 settembre 2026. La voce nasceva col contrario
  e resta qui col suo nuovo contenuto, perche' una voce revocata in silenzio e'
  una voce che torna. **APERTA**
- **DU.05**, il tavolo dei ventidue e' dinamico: le carte entrano a spirale, si
  posano su righe sovrapposte, fluttuano ognuna col suo tempo, e mischia e
  taglia le rimettono in gioco. La carta toccata sale con la scia di stelline.
  **APERTA**
- **DU.06**, nessuna voce: Medora non parla e non c'e' nessun Protoface.
  **APERTA**
- **DU.07**, il verso non si sa prima: i dorsi restano simmetrici e nessun
  segno anticipa dritto o rovescio. **APERTA**
- **DU.08**, il responso parte dalla carta: la parola e' della carta scelta, e
  il dono e la chiusa nascono da lei. **APERTA**
- **DU.09**, il respiro e' di Aura: come forma del dono dell'Alba non esiste
  piu'. **APERTA**
- **DU.10**, zero disclaimer. **APERTA**
- **DU.11**, l'estrazione non ha vincoli: la stessa carta puo' uscire due
  giorni di fila, come alla roulette. **APERTA**
- **DU.12**, zero ripetizioni nei testi: dodici letture per stato e i registri
  della persona. **APERTA**
- **DU.13**, il budget dei tarocchi resta intatto. **APERTA**
- **DU.14**, il Soffio del Destino: via il cerchio disallineato, sono i petali
  a ingrandirsi e a ridursi. **APERTA**

---

## COME SI MISURA, VOCE PER VOCE

Ogni voce ha la sua prova, e ogni prova nasce rossa.

| voce | la grandezza misurata |
|---|---|
| 02 | i dorsi montati sono ventidue distinti, tutti sullo schermo, e ognuno dei ventidue si puo' toccare |
| 03 | girata la carta, il cartiglio del numerale e quello del nome portano testo |
| 04 | nessun `MedoraStage` e nessun avatar nella schermata dell'Alba |
| 05 | senza Riduci Movimento le pose dell'ingresso non sono quelle di riposo, il tavolo respira, e mischia e taglia cambiano la disposizione senza cambiare l'esito |
| 06 | nessun `Protoface`, nessun widget della voce, nessuna chiamata al parlato nella schermata |
| 07 | il dorso ruotato di mezzo giro resta se stesso, e il verso non si legge da nessun dorso prima del tocco |
| 08 | ogni lettura di ogni stato ha la sua parola, e la parola compare nel dono della stessa carta |
| 09 | la parola *respiro* non e' piu' una forma del dono in nessun punto del motore |
| 10 | nessun disclaimer nella schermata |
| 11 | su diecimila giri la stessa carta esce due volte di fila con la frequenza del caso, e nessuna prova la vieta |
| 12 | in tre cicli per venticinque persone nessun testo si ripete, e i ripieghi restano a zero |
| 13 | il limite delle stese non si muove quando si gira la carta |
| 14 | nel Soffio non si disegna piu' nessun cerchio col respiro, e il raggio dei petali cambia col fiato |
