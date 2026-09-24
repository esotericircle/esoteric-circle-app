# ORDINE EM, IL LIVE CHE ASCOLTA GIUSTO, LE VOCI SCELTE E TRE DECISIONI SU EK

**Sigla:** EM, riverificata sul ramo il 25 settembre 2026 prima di
cominciare: in `docs/ordini` nessun `ORDINE_EM_*`, in `test/` nessuna
`ordine_em_guard`; il ramo remoto era a `8a44fa3f`. **Data dell'ordine:** 25
settembre 2026. **Ramo:** `claude/esoteric-circle-master-order-e798aj`.

**Le due scelte del fondatore prima di cominciare**, a una domanda con la
stima dichiarata di circa 18-20 ore di lavoro:

- *"Tutto, una build"*: tutte le dodici voci, le prove sul telefono e una
  build sola alla fine;
- per il respiro vero, che nessuno al PC puo' dare al Realme,
  *"Sintetico, poi il mio"*: si lavora e si misura col rumore vero della stanza e un
  respiro sintetico suonato dalle casse del PC, e le voci EM.04 ed EM.05
  restano in attesa della sua prova col respiro vero sul suo telefono.

**E una frase del fondatore arrivata durante il lavoro, che alza la misura
della voce EM.04**: *"Non è solo il respiro, ma potrebbe sempre esserci un
rumore di fondo in qualunque ambiente. Io uso "Ok Google" giornalmente con TV
accesa e gemini riconosce la mia voce Senza problemi. Ho bisogno dello stesso
livello di accuratezza e tolleranza"*.

VOCI_TOTALI: 12
VOCI_CHIUSE: 1
VOCI_APERTE: 11

Le prove stanno in `docs/collaudo/EM/`.

---

## I FATTI VERIFICATI SUL RAMO PRIMA DI TOCCARE IL CODICE

### 1. Il microfono decide solo sul volume

`lib/features/maestri/live/il_silenzio_vero.dart`, righe 76-107: un pezzo
d'audio e' parlato se il suo livello sta 12 decibel sopra il fondo imparato
per cominciare, 4 per continuare. Non guarda altro. Il respiro vicino al
microfono, un ventilatore o una televisione superano il fondo come la voce,
e finche' superano la soglia la frase non si chiude e l'orologio dei trenta
secondi non conta (`schermata_live.dart`, righe 323-330: il secondo e'
silenzio solo se `_orecchio.staParlando` e' falso).

### 2. Il registratore usa la sorgente di serie del telefono

`lib/services/voce/l_orecchio_del_live.dart`, righe 82-86: `RecordConfig`
senza `androidConfig`, cioe' `AndroidAudioSource.defaultSource`, senza
soppressione del rumore ne' dell'eco. Il pacchetto `record_android` 1.5.2
offre la sorgente `voiceCommunication` e i tre filtri del sistema
(`NoiseSuppressor`, `AcousticEchoCanceler`, `AutomaticGainControl`).

### 3. L'elenco delle voci non scorre

`lib/features/maestri/live/il_selettore_delle_voci.dart`, righe 97-151: le
candidate stanno in una `Column` con `mainAxisSize.min` dentro il foglio, e
nessuno scorrimento. Sedici voci di Calìgo non stanno nello schermo.

### 4. Domanda e risposta sono lo stesso testo, e il volto prende lo spazio che resta

`schermata_live.dart`: il volto sta in un `Expanded` (riga 666) e sotto c'e'
il sottotitolo, alto quanto il suo testo fino al venti per cento dello
schermo (righe 667-684). La domanda lo riempie in `_turno` (riga 478) e la
risposta lo sostituisce in `_dillo` (riga 526). Quando si fa una domanda il
testo lungo della risposta di prima diventa la domanda corta, e il volto si
allarga; quando comincia la risposta il testo si allunga, e il volto si
stringe. La domanda, a video, sparisce.

### 5. La voce scelta vive in memoria per servizio

`functions/src/live.ts`, righe 770-805: la scelta si legge da
`configurazione/live` al massimo una volta al minuto e resta in una
variabile del modulo. `scegliLaVoce` la azzera (riga 944), ma ogni porta del
server gira in un servizio Cloud Run suo, con la sua memoria: la porta che
parla nel LIVE, `laVoceDelMaestro`, non sa che la scelta e' cambiata finche'
il suo minuto non scade. E nel suo registro non scrive quale voce ha usato
(righe 1057-1066): che la voce sia stata applicata non si puo' leggere da
nessuna parte. **Sul registro del server**, la sera del 24 settembre 2026,
il fondatore ha scelto Despina per Medora alle 22:38:07 UTC e Orus per
Calìgo alle 22:47:04; `configurazione/live.voci` porta tutte e due, letto il
25 settembre.

---

## VOCE EM.01, "LAURA" DIVENTA "AURA" NEL LIVE DI AURA

Fonte: `docs/ordini/ORDINE_EK_MANIFESTO.md`, voce EK.03, e la risposta del
fondatore del 25 settembre 2026, *"Sì"*, alla regola solo per il LIVE di
Aura.

**APERTA.**

## VOCE EM.02, LE VOCI CHIRP 3 HD NEL LIVE, CON UN'ECCEZIONE SOLO PER LA VOCE

Fonte: `docs/ordini/ORDINE_EK_MANIFESTO.md`, sezione "Fuori dalle voci", la
frase del fondatore *"Prova ad aggiungere anche le voci Chirp nel
selettore"* e la sua risposta del 25 settembre 2026, *"Sì"*, all'eccezione
limitata alla voce sull'endpoint "eu".

**APERTA.**

## VOCE EM.03, L'ATTRIBUZIONE CIECA LA CHIUDE IL FONDATORE

Fonte: `docs/ordini/ORDINE_EK_MANIFESTO.md`, voce EK.05, e la risposta del
fondatore del 25 settembre 2026: *"Si il 96 è sufficiente per chiuderla."*

**Fatto.** `ImprontaDellIstruzione.chiusaDalFondatore`
(`lib/services/ai/impronta_dell_istruzione.dart`) passa da falso a vero, col
commento che porta le parole del fondatore, e la riga della prova *"l'attribuzione
cieca l'ha chiusa il fondatore"* esce da `tool/rossi_accettati.txt`: una riga
che non cade piu' va tolta, o lo sbarramento ferma la build. La misura non si
rifa': e' quella dell'ordine EK, media 96,1 per cento, 173 su 180, ed e' su
quella che il fondatore ha deciso.

**Le guardie.** Regola B: la prova era rossa per costruzione nello
sbarramento della 2280, la sera del 24 settembre 2026. Dopo il cambio e'
verde, uscita vera in `docs/collaudo/EM/attribuzione_chiusa.txt`.

**CHIUSA.**
DOMANDA: "Si il 96 è sufficiente per chiuderla."
PROVA: docs/collaudo/EM/attribuzione_chiusa.txt
MISURA: la prova "l'attribuzione cieca l'ha chiusa il fondatore" da rossa a verde; righe sue in tool/rossi_accettati.txt da 1 a 0

## VOCE EM.04, IL MICROFONO SENTE IL RESPIRO E LA RISPOSTA NON PARTE

Fonte: il fondatore, 25 settembre 2026: *"il microfono è troppo sensibile,
rileva anche solo il respiro, è molto grave perché fin quando il microfono
rileva il minimo rumore, la risposta non parte."* E la sua frase sulla
televisione, qui sopra.

**APERTA.**

## VOCE EM.05, DOPO 30 SECONDI IL LIVE NON SI FERMA E CONSUMA CREDITI

Fonte: il fondatore, 25 settembre 2026: *"Dopo 30 secondi non si blocca da
solo e continua a consumare crediti."*

**APERTA.**

## VOCE EM.06, LA VOCE SCELTA NEL SELETTORE NON SI APPLICA

Fonte: il fondatore, 25 settembre 2026: *"Quando seleziono la voce nel
selettore anche se scelgo una voce diversa, questa non viene applicata
realmente, funziona solo il preview della voce."*

**APERTA.**

## VOCE EM.07, L'ELENCO DELLE VOCI NON SCORRE

Fonte: il fondatore, 25 settembre 2026: *"Non posso scorrere le voci, lo
scorrimento non funziona."*

**APERTA.**

## VOCE EM.08, DOPO IL SELETTORE IL MICROFONO NON FUNZIONA PIÙ

Fonte: il fondatore, 25 settembre 2026: *"Quando torno indietro dal
selettore, il microfono non funziona più."*

**APERTA.**

## VOCE EM.09, LA DOMANDA A VIDEO SOPRA LA RISPOSTA

Fonte: il fondatore, 25 settembre 2026: *"Quando faccio una domanda, la
domanda dovrebbe comparire in grande e in giallo anche nel testo subito
sopra la risposta, invece adesso compare solo la risposta."*

**APERTA.**

## VOCE EM.10, L'IMMAGINE DEL MAESTRO CHE CAMBIA MISURA DI SCATTO

Fonte: il fondatore, 25 settembre 2026: *"Quando faccio una domanda
l'immagine del maestro s'ingrandisce di botto e poi si riduce di botto
quando inizia a rispondere."*

**APERTA.**

## VOCE EM.11, L'ATTESA PRIMA DELLA RISPOSTA

Fonte: il fondatore, 25 settembre 2026: *"Da quando faccio una domanda a
quando ottengo risposta passano diversi secondi, circa 4."*

**APERTA.**

## VOCE EM.12, LE VOCI DI CALÌGO RALLENTATE

Fonte: il fondatore, 25 settembre 2026: *"qualunque voce di Caligo è
rallentata."*

**APERTA.**
