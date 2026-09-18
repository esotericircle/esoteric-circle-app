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

VOCI_TOTALI: 12
VOCI_CHIUSE: 8
VOCI_APERTE: 4
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0

Il rapporto sta in `docs/ordini/RAPPORTO_ORDINE_DV.md`.

---

## I FATTI, RISCONTRATI SUL CODICE PRIMA DI USARLI

| cosa dice l'ordine | il riscontro | esito |
|---|---|---|
| sono tutte domande suggerite | **non tutte.** *"Estrai una runa per me"* e *"Quale rito sostiene un mio traguardo?"* sono del pannello (`domande_del_cerchio.dart`), la domanda del soffio e' l'apertura del Dono (`ChatOpeners.soffio`). **Ma *"Carta del giorno"* l'ho scritta io** sul telefono del fondatore, con `adb input text`, nella prova a video dell'ordine DS del 17 settembre (catture 08a, 08b, 08c); e *"Lettura generale energia oggi"* non compare in nessuna versione del codice, su nessun ramo | **IN PARTE FALSO** |
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
  tre i Maestri. **Causa trovata e curata**: la coda che porta al server le
  scritture della memoria si svuotava in due corse insieme, e ognuna mandava
  la stessa domanda. Adesso la coda corre una volta sola
  (`FirestoreMaestroMemoryRepository._svuotaLaCoda`). Sul codice di prima le
  cinque domande delle catture, sui tre Maestri, arrivavano al server due
  volte ciascuna; adesso una.
  **CHIUSA.**
- **DV.02**, i contatori. **I doppioni non hanno chiamato il modello e non
  hanno consumato niente**: nascevano dopo l'invio, nella coda verso il
  server, e non passavano ne' dalla generazione ne' dal contatore. Delle
  quattro domande delle catture, *"Carta del giorno"* ed *"Estrai una runa per
  me"* sono instradamenti, e per costruzione non chiamano il modello e non
  consumano; *"Lettura generale energia oggi"* e *"Quale rito sostiene un mio
  traguardo?"* vanno al modello, lo chiamano una volta e consumano una
  domanda ciascuna. Misurato col contatore vero. **Che sul telefono il
  contatore sia rimasto pieno dopo quelle due non si spiega dal codice della
  chat**: il conto locale sale, e alla sincronizzazione il telefono prende il
  numero del server (`QuestionAllowance.sincronizza`, `_count =
  stato.spesi['domande']`). Si verifica sul telefono o sul server, vedi il
  rapporto.
  **CHIUSA.**
- **DV.03**, nessun messaggio dell'utente compare senza un suo gesto, e
  nessuno compare due volte. La coda curata vale per ogni scrittura, quindi
  per ogni strada; in piu' l'invio accetta una chiamata sola alla volta su
  tutte le strade, anche quelle che non generano, dove un doppio tocco sul
  pannello diventava due domande. **E una scoperta da dire per intero**:
  *"Carta del giorno"* non e' una domanda dell'app. L'ho scritta io sul
  telefono del fondatore durante la prova a video dell'ordine DS, il 17
  settembre (catture 08a, 08b e 08c di quel rapporto). *"Lettura generale
  energia oggi"* non compare in nessuna versione del codice.
  **CHIUSA.**
- **DV.04**, dove nasce il difetto: **nel salvataggio**. I doppioni esistono
  davvero nei dati, perche' il server scrive ogni messaggio con un documento
  nuovo. Non nel caricamento e non nella presentazione.
  **CHIUSA.**
- **DV.05**, dopo aver chiuso e riaperto l'app **il difetto restava**, perche'
  la chat riaperta rilegge dal server. Adesso la chat riaperta non ha
  doppioni, e quelli gia' scritti si leggono una volta sola.
  **CHIUSA.**
- **DV.06**, i doppioni gia' finiti nelle cronologie. **Il telefono li nasconde
  gia'** (`CronologiaSenzaDoppioni`), sia a schermo sia nel contesto che torna
  al modello. Per toglierli dai dati c'e' lo strumento
  `functions/src/pulisci_doppioni.ts`, con la stessa regola del telefono e
  le sue prove: per default conta e basta, cancella solo con `--davvero`. Va
  lanciato dal PC con le credenziali di progetto.
  **CHIUSA.**
- **DV.07**, le prove: `nessun_messaggio_si_scrive_due_volte_test.dart`,
  `la_chat_non_raddoppia_le_domande_test.dart` e `functions/src/doppioni.test.ts`.
  Viste rosse con tre innesti: la coda di prima, l'invio senza guardia, la
  lettura senza pulizia.
  **CHIUSA.**
- **DV.08**, le catture: dodici, in `docs/collaudo/DV/`, tre Maestri per
  quattro momenti. **Sono catture del banco e non del telefono**: l'ordine
  vieta la build, e senza una build il codice corretto non arriva sul
  telefono. Le catture del telefono vengono con la prossima build.
  **CHIUSA.**


**LE CORREZIONI DEL FONDATORE DOPO LA CONSEGNA**, 18 settembre 2026. Mauro,
letto il rapporto: *"ok per la seconda difesa e per tutti i consigli che
ritieni utili"*. E sull'Arcano dell'Alba, con due catture dal telefono: il
testo del pannello e' attaccato ai bordi a destra e a sinistra; e *"il gesto
di oggi"* non e' un gesto: *"l'utente deve sapere che gesto fare e deve
essere chiaro e diretto e deve sapere lo scopo, il perche'"*, e il gesto col
suo titolo va in un riquadro che lo stacchi dal resto. Alla domanda su quanto
del corpus riscrivere ha scelto **tutti i 528**.

- **DV.09**, la seconda difesa: **il server non scrive due volte lo stesso
  messaggio**, anche se il telefono glielo manda due volte. Il telefono
  decide l'identificativo del messaggio prima di accodarlo, e il server lo
  crea con quell'identificativo: un secondo invio trova il documento gia'
  scritto e non ne aggiunge un altro. Vale per il reinvio dopo una rete
  caduta, che la coda curata non puo' escludere. Va distribuita dal PC del
  fondatore.
  **APERTA**
- **DV.10**, l'errore inghiottito. Il difetto della coda e' rimasto un mese
  senza che nessuno lo vedesse perche' la cronologia che non si scrive viene
  ignorata in silenzio. Un salvataggio che fallisce deve lasciare una traccia
  leggibile, senza fermare la chat.
  **APERTA**
- **DV.11**, il pannello dell'Arcano dell'Alba: il testo ha un margine
  interno a destra e a sinistra, e il gesto sta in un riquadro col suo
  titolo, staccato dal resto.
  **APERTA**
- **DV.12**, il gesto e' un gesto: tutti i 528 del corpus
  (`docs/corpus/tarocchi.md`) dicono un'azione concreta che si puo' fare
  oggi, e ognuno porta il suo **perche'**, mostrato nel riquadro.
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
| 09 | lo stesso messaggio mandato due volte al server, con lo stesso identificativo, e' un documento solo |
| 10 | un salvataggio che fallisce lascia una riga di diagnosi, e la chat continua |
| 11 | il margine fra il bordo del pannello e il testo, misurato a schermo, e il riquadro del gesto |
| 12 | ogni lettura del corpus ha il suo perche', e nessun gesto comincia con un verbo d'atteggiamento |
