# RAPPORTO DELL'ORDINE DZ, LA CHAT DI APPROFONDIMENTO E' PULITA, E LE CONVERSAZIONI HANNO UN TITOLO

**Data:** 18 settembre 2026. **Ramo:** `claude/esoteric-circle-master-order-e798aj`.
**Manifesto:** `docs/ordini/ORDINE_DZ_MANIFESTO.md`. **Sigla:** DZ, la prima
libera dopo DY, verificata sul ramo.

**Quattro voci, quattro chiuse.** Il fondatore ha deciso due cose: il titolo
lo scrive Gemini, e una build sola, la 2272, con dentro DY e DZ.

---

## 1. COSA HO TROVATO, SUL CODICE E SUL REALME

- **La chat dall'approfondimento mostrava la conversazione di prima** perche'
  la chat, all'apertura, riprende sempre la conversazione dell'ultimo
  messaggio (ordine CI voce 06), da qualunque porta si arrivi.
- **Le chat si memorizzavano gia'**: sul server, in
  `users/{uid}/maestri/{id}/messages`, ciascuna col suo segno di
  conversazione, e nei Ricordi del Cerchio. **A mentire era il Cosmic
  Journal**: aperto da *I giorni prima* col filtro Medora, sul Realme diceva
  0 in ogni mese; spento e riacceso il filtro, settembre diceva 5, e dentro
  il mese la settimana dal 14 al 20 contava 5 momenti. La griglia ascoltava
  la vista e non il registro: cio' che arrivava dopo il primo disegno restava
  fuori finche' nessuno toccava un filtro.
- **Il menu' non aveva conversazioni**: solo *Nuova conversazione* e *I
  giorni prima*, e nessuna conversazione aveva un titolo.

## 2. VOCE PER VOCE

| voce | prodotto | agganciato al codice | verificato a video |
|---|---|---|---|
| DZ.01 chat pulita dall'approfondimento | si' | si', dalla rotta | con la 2272 |
| DZ.02 il Journal vede i turni | si' | si', la vista inoltra il registro | con la 2272 |
| DZ.03 le ultime cinque nel menu' | si' | si', raccolte dai messaggi salvati | con la 2272 |
| DZ.04 il titolo scritto da Gemini | si' | si', dopo la prima risposta vera | sonda vera nella regione, a video con la 2272 |

**Come si usa adesso.** Il menu' in alto a destra della chat ha *Nuova
conversazione*, poi le ultime cinque conversazioni con quel Maestro, dalla
piu' recente, col titolo e *Oggi*, *Ieri* o la data, poi *I giorni prima*,
che porta al Cosmic Journal. Toccando un titolo la chat torna a quella
conversazione e da li' si continua.

**Il titolo.** Dopo la prima risposta vera di una conversazione, una
chiamata breve a `gemini-2.5-flash-lite` in europe-west1 scrive tre-sei
parole. Sonda con tre casi veri e tre stesure dell'istruzione, sei chiamate
ciascuna: quella scelta da' *Oroscopo di oggi e cielo*, *Energia nelle
relazioni questa settimana*, *Fronte verticale e natura ricercatrice*. Il
titolo e' coperto dalla cancellazione dei dati (`chat.titoli.` in
`CioCheETuo`).
Finche' non c'e', o se il modello non risponde, il titolo e' la prima domanda
accorciata. Costo: una chiamata del modello leggero per conversazione.
**Letture**: centocinquanta messaggi al massimo, una volta per apertura della
chat, per comporre il menu'.

**Un limite dichiarato.** I titoli restano sul telefono che li ha scritti.
Su un altro telefono le stesse conversazioni compaiono col titolo di ripiego.
Portarli sul server chiede di cambiare `scriviLaMemoria` e distribuirla dal
PC del fondatore: se lo vuole, e' un ordine a se'.

## 3. GLI SCARTI FRA L'ORDINE E IL RAMO

- *"Non mi sembra che vengano memorizzate"*: sul ramo **si memorizzano**, sul
  server e nei Ricordi. Il difetto era la griglia del Journal, che mostrava
  zero: file e riga nella voce DZ.02 del manifesto.
- *"Storico delle chat indicato con 1 giorno prima"*: la voce si chiama *I
  giorni prima* e apre il Cosmic Journal, non uno storico delle chat. Resta,
  e sopra di lei adesso ci sono le conversazioni.

## 4. I PADRI

- **La conversazione di prima sotto la domanda**: ordine **CI voce 06**,
  che ha fatto nascere le conversazioni con la regola "si riprende l'ultima";
  l'ordine DX, che ha lasciato la domanda nel campo, non l'aveva toccata.
- **Il Journal fermo**: ordine **CG voce 02**, commit `4315ef85` del 31
  agosto 2026, dove la griglia dei Ricordi e' nata ascoltando la sola vista.

## 5. LE PROVE

- **Regola A**: cinque innesti, cinque rossi, ogni file ripristinato e
  verificato con lo sha1: la cura della chat pulita spenta, il menu' senza
  conversazioni, la riapertura spenta, il titolo mai chiesto, la vista che
  non ascolta il registro. La prova del Journal e' rossa anche sul codice
  della 2271: *"Set 0"* con cinque turni di Medora nel registro.
- **Regola B**: `una_conversazione_nuova_non_cancella` rossa con la
  conversazione nuova che non svuota la chat; `la_timeline_dei_ricordi`
  rossa col filtro per Maestro spento. Ripristinate con lo sha1.
- **Registro delle guardie**: nessuna guardia nuova nel conto, le tre prove
  nuove sono prove di valore. Resta 442.
- **Sigillo aggregato**: `'DZ': 4`.
- **Due difetti miei, presi dallo sbarramento prima della build**:
  `niente_resta_di_te` ha trovato la chiave `chat.titoli.` fuori da
  `CioCheETuo` (chi cancella i suoi dati si sarebbe lasciato dietro i
  titoli), e `ogni_prompt_di_prosa_dichiara_la_forma` ha trovato il prompt
  del titolo non dichiarato. Padre: questo ordine, voce DZ.04. Curati tutti e
  due; per il secondo il prompt e' dichiarato fuori dalla prosa, perche'
  nomina un tema e non si rivolge alla persona.

## 6. LA BUILD

La 2272, con DY e DZ, si costruisce dopo lo sbarramento su questo commit.
