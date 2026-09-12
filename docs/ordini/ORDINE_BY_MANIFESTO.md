# ORDINE BY, LA BUILD DA PRESENTARE

Ordine del fondatore del 28 agosto 2026, parole sue: "non mi interessa come ma
sistema tutto che devo presentare una build in grazia". Valgono la REGOLA ZERO
(il testo dell'ordine non e' affidabile e ogni fatto si verifica sul ramo) e la
REGOLA UNO (non ci si ferma: si risolve e si riporta). Guardia
`test/ordine_by_guard_test.dart`.

## Le cinque voci

- **BY.01** Il server in vigore. **CHIUSA.** I comandi li ho eseguiti io: le
  dieci funzioni sono state distribuite e `riscattaLInvito` esiste sul server
  dalle 15:58:40 del 28 agosto 2026, verificata con `gcloud functions
  describe`, non sulla parola.
- **BY.02** La build. **CHIUSA.** Numero, identificativo della consegna e ora
  sono qui sotto, letti dalla consegna vera.
- **BY.03** Il giro di grazia. **CHIUSA.** Quattro cose sistemate su cinque
  schermate, elencate qui sotto con quello che si vedeva prima.
- **BY.04** Il rosso che resta. **CHIUSA.** La voce resta rossa e dichiarata,
  come l'ordine chiede, e qui sotto c'e' quale voce sbaglia di piu' e su quali
  frasi.
- **BY.05** Cio' che resta dichiarato. **CHIUSA.** La sezione e' l'ultima di
  questo manifesto.

## BY.01, il server in vigore

Il rapporto dell'ordine BX diceva che due cose non erano in vigore, e **era
vero**: chiesto l'elenco delle funzioni prima di toccare niente, il server ne
aveva **nove**, e `riscattaLInvito` non c'era.

Il comando l'ho eseguito io, dal PC del fondatore, con la sua sessione
`firebase` gia' attiva. **Non ho mai chiesto ne' visto una credenziale.**

| passo | esito |
| --- | --- |
| `firebase deploy --only functions --project esoteric-circle` | dieci funzioni: nove aggiornate, `riscattaLInvito` **creata** |
| `firebase deploy --only firestore:rules --project esoteric-circle` | regole gia' allineate, rilasciate di nuovo senza modifiche |

**La prova, sul server e non sulla parola**, chiesta a `gcloud functions
describe` alle 15:59:23 del 28 agosto 2026:

| funzione | stato | aggiornata |
| --- | --- | --- |
| `riscattaLInvito` | **ACTIVE**, revisione `riscattalinvito-00001-suj` | 2026-08-28T13:58:40Z, cioe' le 15:58:40 a Roma |
| `statoDelCerchio` | **ACTIVE** | 2026-08-28T13:58:40Z |

Da questo momento il premio dell'invito si paga davvero a chi porta qualcuno,
le tre voci del cammino che lo aspettavano possono maturare, e lo stato in vita
di un VIP si puo' correggere dal documento `catalogo/vip` senza pubblicare
l'app.

**Una nota tecnica che vale per la prossima volta**: il primo tentativo e'
morto su `User code failed to load. Cannot determine backend specification.
Timeout after 10000`. Non era il codice, che si carica in mezzo secondo: e' il
tempo che la CLI si da' per analizzare le funzioni, dieci secondi, troppo pochi
su questa macchina. Con `FUNCTIONS_DISCOVERY_TIMEOUT=120` il deploy passa.

## BY.02, la build

Consegnata dove il fondatore la scarica di solito, cioe' Firebase App
Distribution, all'indirizzo del progetto. **I numeri sono letti dalla consegna
vera, non dichiarati a memoria.**

| cosa | valore |
| --- | --- |
| numero di build | **2211**, letto con `aapt2 dump badging` dall'archivio costruito, mai dal pubspec |
| identificativo della consegna | **`28vocfcn871i0`** |
| ora della creazione sul server | 2026-08-28T14:45:14Z, cioe' le **16:45:14** a Roma |
| peso dell'archivio | 194.811.055 byte |
| destinatario | `cloud@esotericircle.app`, inviti accettati **1** |
| registro `docs/versione_distribuita.json` | aggiornato da 2210 a 2211 dentro la procedura, dopo la conferma del server |

**Verificato sul server e non sulla parola**, chiedendo ad App Distribution
l'elenco delle release alle 16:45:32: la 2211 c'e', ed e' la piu' recente.

**QUESTA BUILD NON E' STATA ACCESA SU UN TELEFONO PRIMA DI PARTIRE, e si
dichiara a voce alta.** La procedura di consegna pretende che l'APK si
installi e disegni il primo fotogramma su un dispositivo vero prima di caricare
qualunque cosa: e' la regola nata dalla 2161, che arrivo' a Mauro con duemila
prove verdi e moriva all'avvio. **Su questa macchina non c'e' nessun
dispositivo**: `adb devices` non ne elenca nessuno e `flutter devices` trova
solo Chrome ed Edge, e nessun emulatore parte qui. Il salto e' stato dichiarato
nella variabile che la procedura pretende per ammetterlo, e la ragione e'
scritta anche nelle note della release. **La prima cosa da fare aprendo questa
build e' guardarla accendersi.**

## BY.03, il giro di grazia

Ho guardato le schermate come le guarderebbe una persona che apre l'app per la
prima volta davanti a chi decide: il primo avvio, la home, le tre porte dei
Maestri, l'Oroscopo, i Tarocchi, la Sinastria VIP e la festa di un traguardo.
**Quattro cose sistemate, e nessuna era scritta in un ordine.**

| dove | cosa si vedeva | cosa si vede adesso |
| --- | --- | --- |
| Stesa di Tarocchi | "Stese di oggi: 1 di 1", che si legge in due modi opposti: davanti a chi guarda per la prima volta il modo sbagliato e' "le hai gia' usate tutte" | "Ti resta 1 stesa di 1, oggi" |
| Le tre chat dei Maestri | la risposta troncata a meta' frase e un vuoto grande dentro la bolla, perche' l'immagine coglieva la scrittura a meta' corsa | la risposta intera, senza vuoti |
| Oroscopo | l'anteprima mostrava una festa invece dell'Oroscopo: leggere fino in fondo fa maturare "Il primo oroscopo letto intero" e la celebrazione copre tutto | l'Oroscopo, con la festa congedata |
| Il bosco del Cerchio | dodici rettangoli vuoti al posto dei simboli dello zodiaco: il carattere del display non ha quei glifi | i dodici simboli, col carattere che li disegna |
| Il primo avvio | non aveva un'anteprima, cioe' la prima schermata dell'app non era mai stata guardata da nessuna immagine | ce l'ha, ed e' `docs/preview/primo-avvio.png` |

**Due cose viste e non toccate, e si dichiarano invece di lasciarle passare in
silenzio.**

La prima: nella home, scorrendo in fondo, una nebulosa del cosmo passa dietro
le due schede semitrasparenti e sotto il titolo "Le altre arti del Cerchio",
che perde un po' di contrasto. **Non e' un difetto di sovrapposizione**: le
schede sono di vetro per scelta e il cosmo si vede attraverso, che e' l'aspetto
dell'app. Toglierlo vorrebbe dire togliere atmosfera a tutta la scena, e il
censimento del contrasto sorveglia gia' che nessun testo scenda sotto la sua
soglia.

La seconda: nella Sinastria VIP, per un VIP senza citta' nota, la barra della
possibilita' di incontro resta un filo. **E' la verita' del calcolo**, non un
difetto della barra: senza sapere dove vive l'altra persona la distanza non
entra nel conto, e la riga sotto lo dice a parole. Gonfiarla per farla vedere
sarebbe una bugia a schermo.

## BY.04, il rosso che resta

La voce resta **rossa e dichiarata**, come l'ordine chiede. Ma la misura e'
stata rifatta altre tre volte, e i numeri sono cambiati.

| giro | quando | attribuzione corretta |
| --- | --- | --- |
| primo, secondo, terzo | ordine BX | 85,0 / 80,0 / 88,3 per cento, media **84,4** |
| quarto, quinto, sesto | ordine BY | 88,3 / 88,3 / 90,0 per cento, media **88,9** |
| **tutti e sei** | 28 agosto 2026 | **86,7 per cento** (312 su 360), soglia 85 |

**Sui sei giri la misura passa la soglia; su un giro solo no.** Il giro piu'
basso resta a 80,0, dieci punti sotto il piu' alto, e finche' un giro puo'
cadere sotto la soglia le tre voci non sono distinguibili in modo affidabile.
La riga `attribuzioneValida` resta falsa, per ordine del fondatore e perche' un
minimo a 80 non e' un problema chiuso.

**QUALE VOCE SBAGLIA DI PIU', E SU QUALI FRASI.** Ordine BY voce 04: e' questa
la parte che serve all'Architetto per riscrivere. Lo strumento adesso stampa
anche le risposte che il giudice ha attribuito a un altro Maestro, con la
domanda che le ha chiamate.

**CALIGO e' la voce che si perde**, in tutti e sei i giri: 15 risposte su 60
attribuite ad altri negli ultimi tre giri, tredici verso Aura. **Tutte, senza
una sola eccezione, aprono con la stessa immagine: una nebbia o un velo che
avvolge.**

- "Una nebbia argentea avvolge la tua percezione."
- "Una nebbia argentea avvolge la tua preoccupazione."
- "Una nebbia densa avvolge il sentiero davanti a te."
- "Una nebbia densa avvolge i tuoi passi."
- "Un velo di nebbia si solleva, rivelando il sentiero."
- "Un velo di nebbia si posa tra le forme."
- "La nebbia avvolge i pensieri, il tempo non ha confini."
- "Una nebbia argentea si alza dal suolo."
- "Una nebbia argentea si solleva tra le rocce antiche."

**MEDORA e' la seconda**, 5 risposte su 60 negli ultimi tre giri, tutte verso
Aura, tutte aperte col cielo che vela, riflette o invita a guardarsi dentro.

- "Il cielo stende i suoi veli, invitando alla riflessione profonda."
- "Il cielo mostra un velo, una distanza sottile che si insinua tra due anime."
- "Il cielo, in questo momento, disegna un percorso di auto-riflessione."
- "Il cielo di questo momento riflette una biforcazione, un bivio interiore."
- "Il cielo si mostra come uno specchio d'acqua calma."

**AURA non viene mai scambiata**, in nessuno dei sei giri, come non lo era nei
cinque precedenti: sono duecentoquaranta verdetti di fila senza un errore che
parta da lei.

**La lettura, per chi riscrivera'.** Il ritmo delle tre voci e' gia' lontano:
la frase mediana di Caligo sta a otto parole con zero parole che
ammorbidiscono, quella di Aura a diciotto con venti. Non e' il registro. **E'
l'immagine di apertura**: il velo, la nebbia, la cosa che avvolge e invita a
guardarsi dentro, sono il territorio di Aura, e quando Caligo o Medora aprono
di li' il giudice sente Aura. Le frasi da riscrivere sono quelle nove di Caligo
e quelle cinque di Medora, e la regola che ne esce e' una sola: **Caligo non
avvolge, taglia; Medora non invita a guardarsi dentro, mostra il cielo che c'e'
gia'.**

## BY.05, cio' che resta dichiarato

**Le funzioni che una persona vede oggi come Coming soon.** Il catalogo porta
**cinquantasei arti**: **nove attive**, **una premium** che si apre col piano
Adepto, **quarantasei in arrivo**, cioe' visibili in grigio col badge, come il
pattern del feature flagging prescrive.

Le nove che si toccano oggi: **Oroscopo Personalizzato, Sinastria VIP, Stesa di
Tarocchi, Meditazione, Test Archetipo, Costellazione del Viso, Estrazione Rune,
Animale Guida, Sigillo dell'Intenzione.** La premium e' la **Sinastria
Approfondita**.

Le quarantasei in arrivo, per come il fondatore le vede raggruppate nei domini:
Carta Natale interattiva, Ritorni Planetari, Pet Astrology, Astrocartografia,
Compatibilita' tra Amici, Oracolo degli Angeli, Carte Angeliche Oracolari, Il
Respiro della Luna, Finestre Fertili, Affinita' Lunare, Calendario Lunare
Personale, Angelo Custode personale, Lettura Karmica, Destino Narrativo, Scan
dei Chakra, Cristalloterapia, Oracolo dei Cristalli, Sfera di Cristallo,
Purificazione Energetica, Analisi dell'Aura, Sleep Stories, Affermazioni del
Giorno, Mudra, Arte delle Convinzioni, Bioritmo, Sogni Lucidi, Mood Tracker,
Chiromanzia Ibrida, Grafologia Esoterica, Cosmic Voice Analysis, I-Ching,
Pendolo, Lettura dei Fondi di Caffe', Interpretazione dei Sogni, Messaggio
dall'Aldila', Micro-rituali, Invocazione del Giorno, Rituali Guidati
Interattivi, Magia Rossa, Magia Bianca, Magia Verde, Opera al Nero, Numeri
Ricorrenti, Numerologia del Destino, Human Design, Cosmic Wrapped.

**Gli Eos raggiungibili.** Il listino del server promette **6.030** Eos, 2.010
per sentiero. In app ne sono raggiungibili **3.735**, il **61,9 per cento**.
I 2.295 che restano stanno in **51 voci dormienti**, che sono esattamente
quelle che il corpus della revisione E dichiara dormienti: nessuna dorme
perche' l'app non sappia misurarla, dormono perche' la funzione che chiedono e'
fra le quarantasei in arrivo. L'elenco voce per voce, con la ragione scritta
dal corpus, sta nel manifesto dell'ordine BX.

**E la voce `med_43`, "Due persone famose una contro l'altra", 45 Eos.** Il
corpus la dichiara dormiente con la nota "VIP contro VIP e' la prescrizione
P33". **Quel percorso adesso esiste**: l'ordine BX voce 06 ha costruito
"Confronta 2 VIP", e l'app sa misurare quella condizione. **Non l'ho
svegliata**: cambiare una nota del corpus non e' una decisione tecnica, e
questa riga sta qui perche' il fondatore la prenda guardando. Vale 45 Eos e
porterebbe i dormienti da 51 a 50.

## LA CONSEGNA, coi numeri

| cosa | esito |
| --- | --- |
| `flutter analyze lib test` | **zero avvisi** |
| suite intera, `TZ=Europe/Rome` | **3.794 verdi, 1 rossa**, che e' l'attribuzione cieca dichiarata alla voce BY.04 |
| impronta dell'albero prima del primo test | `a0d201d9f7c07130011d48123911d227f4592982` |
| impronta dopo l'ultimo | `a0d201d9f7c07130011d48123911d227f4592982`, la stessa: **albero fermo** |
| prove del server, `npm test` in `functions/` | **44 verdi, 0 rosse** |
| tipi del server, `tsc --noEmit` | pulito |
| funzioni distribuite | **dieci**, verificate sul server |
| build consegnata | **2211**, release `28vocfcn871i0`, verificata sul server |

**L'unica cosa scritta dopo la suite e' questa tabella**, che dei numeri della
suite ha bisogno per esistere.

## Marcatori, per chi legge a macchina

VOCI_TOTALI: 5
VOCI_APERTE: 0
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0
VOCI_FERMATE_SU_PREMESSA_FALSA: 0
VOCI_FERMATE_SU_DECISIONE_DEL_FONDATORE: 0
VOCI_CHIUSE: 5
