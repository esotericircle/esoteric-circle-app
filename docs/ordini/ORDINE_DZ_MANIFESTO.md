# ORDINE DZ, LA CHAT DI APPROFONDIMENTO E' PULITA, E LE CONVERSAZIONI HANNO UN TITOLO

**Sigla:** DZ, la prima libera dopo DY: verificato sul ramo, in `docs/ordini`
non c'e' nessun `ORDINE_DZ_*`. **Data:** 18 settembre 2026. **Ramo:**
`claude/esoteric-circle-master-order-e798aj`. Parte dal commit `16ee08da`
(versione 2272, non ancora costruita).

**Il fatto, dal fondatore**, con la cattura della 2271 sul Realme:
*"quando si e' aperta la chat dal pulsante dell'oroscopo, con click su
parlane con Medora, la chat che si e' aperta sotto mostra un'altra
conversazione [...] e' confusionaria e credo sia meglio che si apra una chat
pulita. inoltre, verifica che le chat vengano memorizzate, proprio come una
chatbot [...] non mi sembra che vengano memorizzate e, inoltre, forse sarebbe
meglio che nel menu' a tendina comparissero le ultime 5 conversazioni con il
loro titolo. questo significa che ad ogni nuova conversazione, il sistema deve
creare un titolo indicativo, esattamente come una chatbot."*

**Decisioni del fondatore, 18 settembre 2026**: il titolo lo scrive Gemini;
una build sola, la 2272, dopo questo ordine, con dentro DY e DZ.

VOCI_TOTALI: 4
VOCI_CHIUSE: 4
VOCI_APERTE: 0
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0

Il rapporto sta in `docs/ordini/RAPPORTO_ORDINE_DZ.md`.

---

## I FATTI, RISCONTRATI SUL CODICE E SUL TELEFONO PRIMA DI USARLI

| cosa dice il fondatore | il riscontro | esito |
|---|---|---|
| la chat dall'approfondimento mostra un'altra conversazione | **vero, ed e' scritto cosi'**: all'apertura la chat riprende la conversazione del messaggio piu' recente (`maestro_chat_controller.dart:349-356`, ordine CI voce 06), qualunque sia la porta da cui si arriva | **VERO** |
| le chat non vengono memorizzate | **falso sul server, vero a video**. I messaggi si salvano in `users/{uid}/maestri/{id}/messages`, ciascuno con la sua conversazione, e i turni entrano nei Ricordi del Cerchio: sul Realme, senza filtri, settembre conta 6 momenti, 5 con Medora, e dentro il mese col filtro Medora la settimana dal 14 al 20 ne conta 5. **Ma da "I giorni prima" il Cosmic Journal si apre col filtro Medora e la griglia dell'anno dice 0 in tutti i mesi, settembre compreso**: chi guarda da li' vede che niente e' stato tenuto | **VERO A VIDEO, DA MISURARE** |
| nel menu' a tendina le ultime 5 conversazioni col titolo | **manca**: il menu' ha *Nuova conversazione* e *I giorni prima*, e nessuna conversazione ha un titolo | **MANCA** |

---

## LE VOCI

- **DZ.01**, dal pulsante di approfondimento la chat si apre su una
  conversazione nuova e pulita, con la domanda nel campo; la conversazione
  di prima non si perde.
  **Fatto**: la rotta passa `conversazioneNuova` quando porta una domanda di
  approfondimento (`maestro_chat_screen.dart:123`), e il controllore, letta
  la cronologia, apre una marcatura nuova e svuota la chat
  (`maestro_chat_controller.dart:475`); la conversazione di prima resta
  nell'archivio e quindi nel menu'. Prova in `chat_initial_message_test`,
  vista rossa con la cura spenta. **Prodotto e agganciato; a video con la
  2272.** **CHIUSA.**
- **DZ.02**, il Cosmic Journal aperto dalla chat mostra le conversazioni di
  quel Maestro: la griglia dell'anno non dice zero dove ci sono momenti.
  **Causa misurata**: la griglia ascoltava la vista e non il registro dei
  Ricordi (`ricordi_screen.dart:264`), quindi cio' che il registro riceveva
  dopo il primo disegno non arrivava a video finche' nessuno toccava un
  filtro. Sul Realme: 0 in ogni mese all'apertura, 5 a settembre appena
  toccato un filtro. **Fatto**: la vista inoltra le novita' del registro
  (`vista_dei_ricordi.dart:47`). Prova
  `il_journal_vede_i_turni_appena_arrivano_test`, rossa sul codice della
  2271 (*"Set 0"*) e con la cura spenta. **Le chat si memorizzavano
  gia'**: sul server e nei Ricordi; a mentire era la griglia. **Prodotto e
  agganciato; a video con la 2272.** **CHIUSA.**
- **DZ.03**, nel menu' in alto a destra della chat compaiono le ultime
  cinque conversazioni con quel Maestro, col loro titolo e il giorno; il
  tocco riapre quella conversazione.
  **Fatto**: `LeConversazioniPassate` (`lib/core/chat/le_conversazioni_passate.dart`)
  raccoglie le conversazioni dai messaggi gia' salvati sul server, letti una
  volta dopo l'apertura (150 al massimo), le ordina dall'ultima parola e
  toglie quella aperta; il menu' (`maestro_chat_screen.dart:1381`) le mette
  fra *Nuova conversazione* e *I giorni prima*, col titolo e *Oggi*, *Ieri*
  o la data; il tocco le riapre (`apriLaConversazione`, controllore riga
  298) senza nessuna lettura in piu'. Prove in `chat_initial_message_test` e
  `le_conversazioni_hanno_un_titolo_test`, rosse col menu' vuoto e con la
  riapertura spenta. **Prodotto e agganciato; a video con la 2272.**
  **CHIUSA.**
- **DZ.04**, ogni conversazione nuova riceve un titolo breve e indicativo,
  scritto da Gemini dopo la prima risposta, con un modello verificato nella
  regione dei dati; se il modello non risponde il titolo e' la prima domanda
  accorciata.
  **Fatto**: `TitoliDaGemini` (`lib/services/ai/titoli_da_gemini.dart`) su
  `gemini-2.5-flash-lite`, fra i modelli verificati in europe-west1, senza
  ragionamento e con ventiquattro token; il controllore lo chiama una volta
  per conversazione dopo la prima risposta vera, mai sulla strada del turno,
  e lo ripulisce (riga 363). Il titolo si tiene sul telefono, un archivio
  per Maestro. **Sonda vera nella regione, tre chiamate REST con la stessa
  istruzione**: *Dubbi sull'oroscopo di oggi*, *Energia nelle relazioni
  questa settimana*, *La fronte verticale e la sua natura*. Prova in
  `chat_initial_message_test` con uno scrittore finto, rossa col titolo
  spento. **Un limite dichiarato**: i titoli stanno sul telefono che li ha
  scritti; su un altro telefono le stesse conversazioni hanno il titolo di
  ripiego finche' non ne nasce uno. Portarli sul server vuol dire cambiare
  `scriviLaMemoria` e distribuirla dal PC del fondatore. **Prodotto e
  agganciato; a video con la 2272.** **CHIUSA.**
