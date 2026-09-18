# ORDINE DV, MESSAGGI MAI SCRITTI E DOMANDE DOPPIE NELLE CHAT DEI MAESTRI

**Sigla:** DV. **Data:** 18 settembre 2026. **Ramo:**
`claude/esoteric-circle-master-order-e798aj`. Parte dal commit `c84a2bc1`.
**Nessuna build**: l'ordine la vieta.

**Il fatto, dalle catture del fondatore**: aprendo le chat dei tre Maestri
compaiono domande che non ha mai scritto, e compaiono in coppia. In Medora
*"Carta del giorno"* quattro volte in due coppie e *"Lettura generale energia
oggi"* due volte di fila; in Caligo *"Estrai una runa per me"* e *"Quale rito
sostiene un mio traguardo?"* due volte di fila; in Aura la domanda che cita il
soffio del giorno, due volte di fila. Tutte domande suggerite dall'app.

VOCI_TOTALI: 8
VOCI_CHIUSE: 0
VOCI_APERTE: 8
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0

Il rapporto sta in `docs/ordini/RAPPORTO_ORDINE_DV.md`.

---

## I FATTI, RISCONTRATI SUL CODICE PRIMA DI USARLI

| cosa dice l'ordine | il riscontro | esito |
|---|---|---|
| sono tutte domande suggerite | **vero**: vengono dal pannello dei suggerimenti (`chat_suggestions.dart`, `_send`) o dal testo con cui un Dono apre la chat (`maestro_chat_screen.dart`, `_maybeSendInitial`) | **VERO** |
| compaiono in coppia | **vero, e la causa e' nel salvataggio**: vedi sotto | **VERO** |
| i contatori restano pieni | **da misurare**: due di quelle domande sono instradamenti, e per costruzione non consumano; le altre due vanno al modello | **IN PARTE ATTESO** |

**LA CAUSA, misurata al banco prima di toccare il codice.** Nell'app vera ogni
scrittura della memoria passa dal server: si accoda in
`FirestoreMaestroMemoryRepository._daMandare` e parte da `_svuotaLaCoda`. La
chat salva la domanda **senza aspettare** e subito dopo salva la risposta, o
il turno in attesa, o l'invito di un instradamento. Le due scritture
svuotavano la coda **insieme**: ognuna leggeva il primo elemento, cioe' la
stessa domanda, e la mandava al server. Misurato con un server finto che
risponde con un ritardo, come la rete:

    scritti = [messaggio:Carta del giorno, messaggio:Carta del giorno,
               messaggio:La tua carta]
    errore  = RangeError (length): Invalid value: Valid value range is empty: 0

**La domanda arriva due volte, e la seconda corsa prova poi a togliere un
elemento da una coda gia' vuota.** L'errore l'app lo inghiotte in silenzio,
perche' la cronologia e' un di piu' e non deve fermare la chat: e' per questo
che nessuno lo vedeva.

**Al banco il difetto non esisteva**, perche' le prove della chat usano il
repository in memoria, che non ha coda.

---

## LE VOCI

- **DV.01**, il fatto: le domande suggerite compaiono due volte, in tutti e
  tre i Maestri. **APERTA**
- **DV.02**, i contatori: se i messaggi doppi hanno chiamato il modello, se
  hanno consumato, se il contatore avrebbe dovuto muoversi, coi punti del
  codice. **APERTA**
- **DV.03**, nessun messaggio dell'utente compare senza un suo gesto, e
  nessuno compare due volte: su tutti e tre i Maestri, dalle domande
  suggerite, dai Doni del Giorno e da ogni altro percorso che apre una chat
  con un testo pronto. **APERTA**
- **DV.04**, dove nasce il difetto: nel salvataggio, nel caricamento o nella
  presentazione. **APERTA**
- **DV.05**, se resta dopo aver chiuso e riaperto l'app. **APERTA**
- **DV.06**, i messaggi doppi gia' finiti nelle cronologie: se vanno puliti e
  cosa serve per farlo. **APERTA**
- **DV.07**, le prove che fanno cadere il difetto se torna. **APERTA**
- **DV.08**, le catture delle tre chat dopo la correzione, da una domanda
  suggerita, da un Dono del Giorno e da app riaperta, in `docs/collaudo/DV/`.
  **APERTA**

---

## COME SI MISURA, VOCE PER VOCE

| voce | la grandezza misurata |
|---|---|
| 01 | col repository vero e una porta viva, la domanda e la risposta arrivano al server una volta sola e tutte e due |
| 02 | per ogni domanda delle catture: quante chiamate al modello, quante domande consumate, e da quale riga |
| 03 | un doppio tocco sul pannello e un doppio invio dallo stesso testo pronto producono un messaggio solo |
| 04 | cio' che il server riceve, non cio' che lo schermo disegna |
| 05 | la cronologia riletta dal repository dopo la sessione non ha doppioni |
| 06 | lo strumento che trova i doppioni gia' scritti, provato su una cronologia finta |
| 07 | le prove sopra, viste rosse sul codice di prima |
| 08 | le catture in `docs/collaudo/DV/` |
