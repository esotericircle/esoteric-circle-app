# ORDINE FE, IL CRASH DEL REDMI, LE VOCI DEL LIVE, IL FILO DEL CONSULTO E IL DIARIO COSMICO

**Sigla:** FE, libera sul ramo canonico. **Data dell'ordine:** 5 ottobre 2026,
con le aggiunte e le precisazioni del 5 e del 6 ottobre. **Ramo:**
`claude/esoteric-circle-master-order-e798aj`, nessun altro. **Partenza:**
commit `a75436ab`; i commit dell'ordine sono `git log a75436ab..HEAD`. Il
testo del fondatore alla lettera sta in `docs/ordini/ORDINE_FE_TESTO.md`, e
ogni DOMANDA qui sotto viene da li'.

**Regole in primo piano.** R1 ogni voce dichiara la sua fonte; R2 le premesse
si abbattono con la misura; R3 si enumera, non si campiona; R4 e R5 le
Regole A e B (gli innesti in `docs/collaudo/FE/regola_a_fe.txt`); R6 ogni
affermazione visiva o sonora e' una cattura, una registrazione o una misura;
R7 nessun rosso si consegna e i tre numeri delle prove coincidono; R8 niente
dati di produzione; R9 il manifesto coi quattro marcatori; R10 nessuna
credenziale chiesta in chat; R11 prima di scrivere una riga nuova si misura
cosa esiste gia'. La build 2299 l'ha ordinata il fondatore.

**Le aggiunte.** L'aggiunta FE.21 del 5 ottobre (dove si riproduce il crash,
Test Lab) porta cinque sottovoci; l'aggiunta FE.22 del 6 ottobre (i nomi del
menu' e il Diario Cosmico) ne porta diciotto; la precisazione del fondatore
del 5 ottobre alle 23:48 sul filo conduttore fra i Maestri ("in alto la
domanda dell'utente venga ripetuta") e' la voce FE.23. Il commit `d1798d05`
che la realizza porta per errore la sigla "FE.22" nel messaggio: e' la FE.23,
e qui si dichiara. Le voci sono quarantaquattro.

VOCI_TOTALI: 44
VOCI_CHIUSE: 43
VOCI_APERTE: 1
VOCI_DA_FARE: 0

La voce aperta, FE.22.13, e' `APERTA IN ATTESA DI VERIFICA`: col Realme e la
build 2299 il Diario ha mostrato settembre a 0 per un guasto del telefono,
riparato per la build 2300; si chiude con la verifica sulla 2300, nelle
righe in coda.

## LE SCELTE DEL FONDATORE

Chieste perche' necessarie, il 5 e il 6 ottobre 2026, con lo strumento delle
domande. Le parole fra virgolette sono le risposte del fondatore.

- *"Taglia l'istruzione di base"* (FE.20, 6 ottobre 02:55, testo dell'ordine
  riga 576): il costo del filo si paga togliendo il ripetuto dall'istruzione
  di base, mai la qualita' (commit `d7e025b0`).
- *"Tre giri insieme"* (FE.10, FE.16, FE.17): la soglia di chiusura si legge
  su tre giri del banco del filo insieme, 180 giudizi, e non su un giro solo,
  perche' il rumore fra un giro e l'altro va da 0 a 5 contraddizioni: al piu'
  una contraddizione su 180 e almeno nove su dieci di media per percorso
  (`lib/core/chat/la_rete_della_coerenza.dart`, righe 38-46). Nessuna forma
  ci e' arrivata; da qui la scelta *"Tengo la migliore e chiudo"*. La
  risposta sta nella trascrizione della sessione, non in un file del repo.
- *"Tienila, recupero il costo"* (FE.10, FE.17, FE.20): la rete della
  coerenza resta, ma parte solo quando nel consulto ha gia' parlato un altro
  Maestro (commit `6dc17dcc`, `la_rete_della_coerenza.dart` riga 78).
- *"Punti fermi strutturati"*: la forma coi punti fermi estratti e
  confrontati campo con campo, misurata in tre giri (9 contraddizioni su 180,
  l'11 per cento di costo in piu') e scartata
  (`la_rete_della_coerenza.dart` righe 38-46). La risposta sta nella
  trascrizione della sessione, non in un file del repo.
- *"Tengo la migliore e chiudo"* (FE.10, FE.16, FE.17): dopo ventotto giri
  nessuna forma arrivava a zero contraddizioni; si tiene la forma migliore e
  si dichiara il livello misurato invece della soglia dell'ordine.
- *"Correzione su Flash-Lite e filo più corto"* (FE.20, commit `ee15afe4`):
  la correzione chiesta dalla rete si scrive con Flash-Lite, e la legge della
  coerenza perde due frasi ripetute.
- *"Domande e minuti insieme"* (FE.20, commit `a2da1bb9`): i limiti
  dell'annuale scendono nelle domande e nei minuti insieme, per stare sotto
  il tetto del 30 per cento.
- *"Una domanda in meno"* (FE.20, commit `b5be4b03`): i mensili dell'Adepto e
  dell'Illuminato passano da 18 e 22 a 17 e 21 domande al giorno.

La regola del fondatore *"Tre cose su FE.05 e FE.06"* (6 ottobre 02:20, testo
righe 536-570) chiude quelle due voci su una misura sul dispositivo piu' lento
e non sulla prova del tester, che resta a Mauro come collaudo sulla 2299.

## VOCE FE.01, IL LOG, POI LA CAUSA, POI LA CURA

**CHIUSA.** Strada a): l'app raccoglie gia' i crash. La build 2297 non ha
eventi in Crashlytics, la 2298 ne ha quattro: l'ANR del Redmi Note 14 Pro 5G
(24090RA29G, Android 16, evento 227171118570) e tre non fatali del Realme
(`docs/collaudo/FE/i_crash_delle_build_2297_e_2298.txt`). Lo stack intero sta
in `docs/collaudo/FE/lo_stack_del_redmi.txt`, tradotto in file e riga coi
simboli della stessa build rifatta da `d251c4c2` in
`docs/collaudo/FE/lo_stack_del_redmi_tradotto.txt`. La causa: alla chiusura
del LIVE (`schermata_live.dart:327`, `dispose`) la chat prepara il seguito
(`maestro_chat_controller.dart:1555`) e compone l'istruzione del Maestro
(`maestro_persona.dart:526`), dove `_cioCheArriva` (`:358`) calcolava due
volte col motore di Meeus gli eventi in arrivo di 400 giorni sul filo
dell'interfaccia, dentro `cos`. La cura (`bf65c2b2`): una porta sola,
`IlCieloCheArriva`, li calcola in un isolate una volta per giorno e persona;
il cielo di un periodo chiesto dal modello gira anche lui fuori dal filo
(`c6db92f3`). Regola C: `_cioCheArriva` entra con `225cff9a` (ordine CQ2,
voci 15-16), la sua chiamata alla chiusura del LIVE con `8ec2bbf2` (ordine EX,
Aggiunta 4, voce EX.04).

DOMANDA: "Dichiara nel rapporto la causa esatta, con il file e la riga dove l'app cade. Poi curala. Non dichiarare chiusa la voce senza lo stack scritto nel rapporto."
PROVA: test/il_cielo_che_arriva_non_ferma_l_interfaccia_test.dart
MISURA: istruzione del Maestro con una nascita sul PC prima 2920, 2893 e 2828 ms (Medora, Aura, Caligo), dopo 16 ms; innesto A6 col calcolo rimesso 1410 ms e prova rossa; eventi Crashlytics build 2297 0, build 2298 4 (1 ANR)
ACCETTAZIONE: apro lo stack tradotto e leggo la riga dove l'app cadeva, e so che la guardia diventa rossa se qualcuno rimette quel calcolo sul filo

## VOCE FE.02, PERCHE' CALIGO NO

**CHIUSA.** Premessa abbattuta con la misura
(`docs/collaudo/FE/fe02_perche_caligo_no.md`): sul percorso dell'ANR, letto
passo per passo sulla 2298 (`d251c4c2`) e su HEAD, nessuna riga sceglie una
strada diversa per Caligo alla chiusura o all'apertura del LIVE; Caligo ha il
seguito, gli stessi strumenti del cielo e la stessa istruzione, e il calcolo
pesava uguale sui tre. Perche' il tester non sia caduto con Caligo non e'
misurabile: un evento solo, e lo stack non dice il Maestro. Il commento di
`lib/services/ai/le_funzioni_del_cielo.dart` che diceva "Caligo no" e' stato
corretto (Regola C: padre `c6db92f3`, FE.01, prima ipotesi). La cura che
rende impossibile la configurazione incompleta e' la FE.03.

DOMANDA: "Dichiara la differenza misurata fra la configurazione di Caligo e quella di Medora e di Aura: quale risorsa i due hanno in meno o diversa."
PROVA: docs/collaudo/FE/fe02_perche_caligo_no.md
MISURA: righe del percorso dell'ANR che dipendono dal Maestro 0 su 6 passi; peso del calcolo 2920, 2893 e 2828 ms per Medora, Aura e Caligo; commenti che dicevano "Caligo no" prima 1, dopo 0
ACCETTAZIONE: leggo nel documento che i tre Maestri fanno la stessa strada, e che la differenza che l'ordine supponeva non esiste

## VOCE FE.03, LA GUARDIA DELLA CONFIGURAZIONE COMPLETA

**CHIUSA.** La guardia `il_maestro_del_live_ha_tutto` enumera i tre Maestri e
per ciascuno il busto, il saluto e le cinque tabelle del server; il server
rifiuta con `failed-precondition` un Maestro a cui manca un pezzo
(`leMancanzeDelMaestro`, `functions/src/live.ts`), il telefono non apre una
sessione senza url, gettone, sessione o avatar, e la persona legge la frase
dell'ordine alla lettera, con "Continua per iscritto" (commit `f187b974`,
`29c72490`, `81e5af4c`). Rossa con A3, A4, A5 e A64. Anteprima in
`docs/preview/FE/fe03_maestro_non_raggiungibile.png`. Il deploy delle
funzioni l'ha fatto il fondatore il 6 ottobre: 13 funzioni ACTIVE alle
11:50-11:51 UTC.

DOMANDA: "Nessun percorso dell'app può aprire un collegamento vocale con un Maestro la cui configurazione è incompleta: in quel caso compare un messaggio e non un crash. Testo del messaggio, carattere per carattere: Questo Maestro non è raggiungibile adesso. Riprova fra poco."
PROVA: test/il_maestro_del_live_ha_tutto_test.dart
MISURA: risorse mancanti per Maestro senza innesto 0, 0, 0; tolto l'avatar a Caligo 1 e prova rossa (A3); Maestri enumerati 3 su 3; sessioni aperte con configurazione incompleta prima possibili, dopo 0
ACCETTAZIONE: se a un Maestro manca un pezzo leggo "Questo Maestro non è raggiungibile adesso. Riprova fra poco." e l'app non si chiude

## VOCE FE.04, LA RACCOLTA DEI CRASH DEGLI UTENTI

**CHIUSA.** Android: la raccolta c'era gia'
(Crashlytics dal 7 agosto 2026, `pubspec.yaml` riga 89), e un evento vero e'
stato letto con `tool/i_crash_degli_utenti.py` (l'ANR 227171118570 della
2298); `test/crashlytics_ha_gli_occhi_test.dart` tiene i dati della persona
fuori dai canali. iOS: Crashlytics e' inizializzato senza ramo per
piattaforma (`lib/main.dart` righe 67-100) e la fase dei dSYM sta in
`codemagic.yaml` (righe 363-409); lo strumento legge anche l'app iOS con
`--ios` (commit `88db5c54`). iOS ha zero eventi in 88 giorni, e zero eventi
da soli non distinguono "nessun crash" da "canale muto": il 6 ottobre alle
19:55, sull'iPhone 13 di collaudo con la build 2298 di TestFlight, il registro
di sistema mostra il kit Crashlytics 12.15.0 che si avvia e tiene aperta la
sua sessione dei rapporti (`docs/collaudo/FE/fe04_crashlytics_su_ios.txt`):
il canale e' acceso, e zero eventi vuol dire che l'app su iOS non e' caduta.
Un evento iOS vero non e' mai stato letto, perche' non c'e' stato. Come si
leggono: API `firebasecrashlytics.googleapis.com/v1alpha`, app Android
`1:425821975933:android:1b1ca4db8d4df69b940814`, iOS
`1:425821975933:ios:02367eef4fafaaf0940814`, oppure la console Firebase.

DOMANDA: "Misura se l'app raccoglie già i crash in produzione. Se non lo fa, accendila su Android e su iOS, con la regola che nessun dato personale dell'utente finisce nel rapporto del crash. Dichiara nel rapporto come si leggono i crash e dove."
PROVA: docs/collaudo/FE/fe04_crashlytics_su_ios.txt
MISURA: eventi Android letti dallo strumento 4 sulla build 2298 (0 sulla 2297); app lette dallo strumento prima 1, dopo 2; kit Crashlytics avviato sull'iPhone 1 su 1 avvii (versione 12.15.0); eventi iOS 0 in 88 giorni, nessuna caduta
ACCETTAZIONE: lancio lo strumento con --ios e leggo i crash dell'iPhone, e so che sull'iPhone la raccolta e' accesa

## VOCE FE.05, MISURA PRIMA DI CURARE

**CHIUSA.** Chiusa sulla regola del fondatore "Tre cose su FE.05 e FE.06": il
difetto della voce viene dal Redmi, e la misura va fatta sul dispositivo piu'
lento del catalogo di Test Lab con hardware uguale o inferiore. Scelto il
Galaxy A16 5G: Geekbench 6 single 975 contro 1024 del Redmi, entrambi da
GSMArena (`docs/collaudo/FE/test_lab/geekbench/`); il Galaxy A35 5G e'
uguale al Redmi. I numeri Geekbench scritti nel commit `0ddac0c2` (965,
1003, 1021-1031) non avevano fonte, e qui si dichiara. Col percorso vero
(apertura della chat, saluto, tre turni di LIVE) il filo principale restava
fermo 5100-6365 ms col calcolo della 2298, e dopo la cura 19, 54 e 70 ms
sull'A16 (`giro_4_a16x-36-it`, `-en`, `-fr`). La prova sul telefono vive in
`docs/collaudo/FE/test_lab/sorgenti/`, perche' l'impalcatura di Test Lab
rompeva la build di rilascio (`ab8d1604`); nel ramo la guarda la prova sul
PC, rossa con A6. L'innesto su dispositivo e' stato fatto sull'A35 (uguale al
Redmi), non sull'A16: 1950 ms e prova rossa. Le registrazioni del Realme in
`docs/collaudo/FE/voci/` restano come misura di controllo (0 rotture), non
come prova della cura; `LaVoceRicevuta` scrive le rotture al decimo di
secondo nel registro, cosi' i secondi del tester arrivano dalla 2299.

DOMANDA: "durante un turno di LIVE il filo principale non resta mai fermo oltre 100 millisecondi, sul dispositivo più lento scelto al punto 2, e una prova lo verifica e diventa rossa se qualcuno rimette un calcolo pesante su quel filo."
PROVA: test/il_cielo_che_arriva_non_ferma_l_interfaccia_test.dart
MISURA: blocco massimo del filo principale in un turno di LIVE sul Galaxy A16 5G prima 5100-6365 ms, dopo 19, 54 e 70 ms; sul Galaxy A35 5G prima 3755 ms, dopo 8 ms; innesto sull'A35 1950 ms e rosso; rotture sul Realme 0
ACCETTAZIONE: leggo nel registro di Test Lab che sul telefono piu' lento il filo non si ferma oltre 100 millisecondi in un turno di LIVE

## VOCE FE.06, LA CURA

**CHIUSA.** La cura tocca la causa misurata: il calcolo degli eventi in
arrivo esce dal filo dell'interfaccia (`IlCieloCheArriva`, `bf65c2b2`), e la
chat prepara il cielo quando si apre (`d7e025b0`), cosi' il primo turno del
LIVE non lo calcola dentro il turno: sull'A16 il primo turno arrivava fino a
102-111 ms, adesso sta sotto i 100 (`giro_tappe_a16x`, `giro_4_a16x-36-*`).
Chiusa sulla stessa regola del fondatore della FE.05; le registrazioni prima
e dopo sul Realme stanno in `docs/collaudo/FE/voci/` come misura di
controllo, con 0 rotture prima e dopo. La prova del tester sulla 2299 resta a
Mauro.

DOMANDA: "Cura la causa misurata in FE.05, non il sintomo. Dopo la cura, rifai le tre registrazioni e dichiara le rotture rimaste."
PROVA: test/la_chat_prepara_il_cielo_test.dart
MISURA: primo turno di LIVE sul Galaxy A16 5G prima 102-111 ms, dopo 19-70 ms; rotture rimaste sul Realme 0 su 3 registrazioni prima e 0 dopo; innesto A32 senza la preparazione all'apertura rosso
ACCETTAZIONE: apro la chat e poi il LIVE e il primo turno non fa un calcolo pesante, e la prova diventa rossa se qualcuno lo rimette li'

## VOCE FE.07, QUANDO LA VOCE NON PARTE

**CHIUSA.** Quando il volto non entra, la stanza non si collega o il saluto
non esce, la sessione si chiude col segno `senzaVoce` e la persona legge la
frase dell'ordine alla lettera, con la strada per la chat scritta; a meta'
consulto si continua per iscritto (`ba5812cf`, `81e5af4c`). Anteprima in
`docs/preview/FE/fe07_la_voce_non_parte.png`. Il server non somma i secondi
di una sessione senza voce durata al piu' 90 secondi (`SECONDI_SENZA_VOCE`):
il tetto esiste perche' oltre si conta, difesa contro chi tiene aperta una
sessione segnata senza voce. Regola C: il conto dei minuti si scriveva con
`merge` e le sessioni gia' contate si sommavano di nuovo, padre ordine EX
voce 01, curato con `mergeFields`. Il deploy di `apriUnaSessioneLive` e
`chiudiLaSessioneLive` e' fatto.

DOMANDA: "La voce non riesce a raggiungerti. Continuo a scriverti. Il tempo consumato mentre la voce non funziona non viene scalato dai minuti dell'utente, e lo dimostri con la misura del borsellino prima e dopo."
PROVA: functions/src/live.test.ts
MISURA: secondi usati del borsellino prima 300, dopo una sessione senza voce di 60 s ancora 300 (60 in secondiSenzaVoce); una sessione senza voce di 91 s si conta (tetto 90 s); innesti A20-A24 rossi
ACCETTAZIONE: se la voce non parte leggo "La voce non riesce a raggiungerti. Continuo a scriverti." e i miei minuti non scendono

## VOCE FE.08, DOVE LA MEMORIA GIA' ARRIVA

**CHIUSA.** Le strade enumerate con file e riga sono diciassette
(`docs/collaudo/FE/fe08_le_strade_verso_un_maestro.md`), e per ognuna se
passa la storia, il blocco del filo e se annota. Premessa abbattuta: la
finestra di storia al modello e' di 8 messaggi dall'ordine EX voce 09
(`kHistoryWindow = 8`), non di 20. La memoria del consulto e' una sola,
`IlFiloDelConsulto`; "Continua con" non scrive piu' la seconda memoria
(`b0d56ffb`). La cura del commit `6dc17dcc` porta il filo a ogni strada: la
lettura dei tarocchi, il presagio, l'animale guida, la riga del consiglio,
"Parlane col Maestro", il benvenuto e "Vai più a fondo"; le quattro che
restano fuori hanno la ragione scritta (correzione corta, sintesi del
Consiglio, Sigillo dell'intenzione, scena del Viaggio).

DOMANDA: "Prima di scrivere una riga, enumera tutte le strade per cui una domanda arriva a un Maestro ... Per ciascuna dichiara, con percorso del file e riga, se la storia della conversazione viene passata al modello oppure no. La memoria del consulto resta una sola, quella che già esiste: non ne nasce una seconda accanto."
PROVA: test/il_filo_arriva_a_ogni_strada_test.dart
MISURA: strade enumerate 17; strade senza filo o col filo a meta' prima 7, dopo 0 senza ragione scritta (4 fuori con la ragione); memorie del consulto prima 2 (la seconda di Continua con), dopo 1; innesti A65-A69 rossi
ACCETTAZIONE: apro l'elenco delle diciassette strade e per ognuna trovo il file, la riga e se il Maestro riceve il filo

## VOCE FE.09, LA SCHEDA DEI PUNTI FERMI

**CHIUSA.** La scheda la scrive il codice, mai il modello (`946a51ed`,
`b0d56ffb`): il tema della domanda iniziale, il dato da cui parte, la prima
frase e la riga del consiglio di ogni Maestro. Pesa circa 394-405 token
(1572-1619 caratteri, `docs/collaudo/FE/regola_a_fe.txt` righe 47-67), non
295 come diceva il primo commit: la scheda e' cresciuta con la prima frase e
la riga del consiglio. Regola C: due catch muti del filo e la prima chat muta
se l'archivio non rispondeva, padre `946a51ed` (FE.09), curati in `d7e025b0`
e `81e5af4c`.

DOMANDA: "La scheda è strutturata e breve. Dichiara nel rapporto quanti token pesa."
PROVA: test/il_filo_del_consulto_test.dart
MISURA: peso della scheda con due pareri e la frase ripresa al primo commit 1180 caratteri, circa 295 token; oggi 1572-1619 caratteri, circa 394-405 token; schede prima dell'ordine 0, dopo 1
ACCETTAZIONE: leggo quanti token pesa la scheda e so che la scrive l'app, non il modello

## VOCE FE.10, LA LEGGE DELLA COERENZA

**CHIUSA.** La legge vive in un punto solo, nell'istruzione composta da
`IlFiloDelConsulto`, e ogni strada la riceve col filo (FE.08). Sopra la
legge c'e' la rete della coerenza (`lib/core/chat/la_rete_della_coerenza.dart`),
che giudica con Flash-Lite la risposta nuova contro i punti fermi e la
corregge corta, solo quando nel consulto ha gia' parlato un altro Maestro
(scelta "Tienila, recupero il costo"). La soglia dell'ordine, zero
contraddizioni, non e' raggiunta: per la scelta del fondatore "Tengo la
migliore e chiudo" e poi "Correzione su Flash-Lite e filo più corto" si
dichiara il livello misurato, tre giri del banco del filo (16:42, 16:52,
16:58), 4 contraddizioni su 180 giudizi (3, 0, 1). Prima dell'ordine non
c'era nessuna rete.

DOMANDA: "Un Maestro non contraddice quello che ha già detto dentro lo stesso consulto. ... La legge vive in un punto solo del codice, nominata, e tutte le strade la applicano."
PROVA: test/la_rete_della_coerenza_test.dart
MISURA: reti della coerenza prima dell'ordine 0, dopo 1; contraddizioni con la sola legge 6 su 180 giudizi (giri 08:19, 08:33, 08:39), con la forma scelta 4 su 180 (giri 16:42, 16:52, 16:58); innesti A70-A73 rossi
ACCETTAZIONE: so che il livello misurato e' 4 contraddizioni su 180 giudizi, e che la soglia zero non e' stata raggiunta per mia scelta di chiudere

## VOCE FE.11, LA FRASE RIPRESA E' UNA CONTINUAZIONE

**CHIUSA.** I ventisei punti dove l'app suggerisce una frase o una domanda
sono enumerati con file e riga in `docs/collaudo/FE/fe11_le_frasi_suggerite.md`,
con otto guasti veri (la frase ripresa non si riconosceva). La cura del
commit `6dc17dcc`: la frase ripresa si riconosce fra tutte le risposte del
consulto (`LaFraseRipresa.fraTutte`), non solo l'ultima, anche nel seguito di
"Vai più a fondo" e nel Consiglio. Rossa con A65, A66, A67.

DOMANDA: "Se l'utente rimanda al Maestro una frase o una domanda che il Maestro stesso gli ha suggerito, quella non è una domanda nuova: è la continuazione di quel punto. ... Enumera tutti i punti dove l'app suggerisce una frase o una domanda all'utente, e collegali al filo."
PROVA: docs/collaudo/FE/fe11_le_frasi_suggerite.md
MISURA: punti enumerati 26; risposte in cui si riconosce la frase ripresa prima 1 (l'ultima), dopo tutte quelle del consulto; percorso C del banco, porta avanti 10, 10 e 10 su 10 negli ultimi tre giri, contraddizioni 0
ACCETTAZIONE: rimando al Maestro la frase che mi ha suggerito e lui approfondisce quel punto invece di aprirne un altro

## VOCE FE.12, IL FILO VIVE QUANTO IL CONSULTO

**CHIUSA.** Lo schermo si apre vuoto come vuole l'ordine EA voce 06, ma chi
torna sullo stesso Maestro entro un'ora ritrova il suo filo: il Maestro
riceve le ultime venti battute della conversazione di prima davanti alla
storia, con la scheda; oltre l'ora il consulto e' nuovo (`b3dbc1d5`). Rossa
con A14, A15, A16.

DOMANDA: "Il filo tiene le ultime venti battute e la scheda dei punti fermi. Se l'utente torna sullo stesso Maestro entro un'ora, ritrova il suo filo. Oltre l'ora il consulto è nuovo e il Maestro non finge di ricordare."
PROVA: test/il_filo_vive_quanto_il_consulto_test.dart
MISURA: battute riprese tornando entro l'ora prima 0, dopo al piu' 20; vita del filo 60 minuti, oltre 0 battute; percorso F del banco (ripreso dopo dieci minuti) porta avanti 9, 10 e 10 su 10 negli ultimi tre giri
ACCETTAZIONE: torno da Medora dopo dieci minuti e lei riprende il discorso; dopo due ore ricomincia da capo

## VOCE FE.13, IL FILO PASSA DA UN MAESTRO ALL'ALTRO

**CHIUSA.** Il secondo Maestro riceve la scheda dei punti fermi del primo e
non le battute per intero (`946a51ed`); i pareri del Consiglio entrano nel
filo (`c5cac77a`, rossa con A17 e A18). Misurato con tre Maestri di fila su
cinque temi (`docs/collaudo/FE/costo/i_tre_maestri_2026-10-06T1556.txt`):
l'ingresso cresce con la scheda, circa 170-480 token a Maestro, e non con le
battute.

DOMANDA: "Quando l'utente porta lo stesso tema a un altro Maestro, il secondo riceve la scheda dei punti fermi del primo. Non riceve le battute per intero: riceve la scheda, così il costo non cresce con il numero di Maestri interpellati."
PROVA: docs/collaudo/FE/costo/i_tre_maestri_2026-10-06T1556.txt
MISURA: token di ingresso col primo Maestro 5394-5399, col secondo 5879-5906, col terzo 6059-6077; blocco del filo 0, 1313-1414 e 1530-1619 caratteri
ACCETTAZIONE: porto la stessa domanda a tre Maestri e il costo cresce della scheda, non di tutta la conversazione

## VOCE FE.14, IL SECONDO MAESTRO LO DICHIARA

**CHIUSA.** La regola porta i nomi di chi ha parlato prima e chiede di aprire
con la propria lettura e poi una riga che comincia col nome, riportando il
consiglio, il gesto o il tempo, e non le parole dell'arte altrui
(`48620ecb`). Il secondo Maestro nomina chi ha parlato prima in 6-10 risposte
su 10 nei giri del banco B, non sempre, e si dichiara; per questo il filo in
cima alla chat lo dice sempre alla persona (FE.23). Anteprima in
`docs/preview/FE/fe14_il_secondo_maestro_nomina_il_primo.png`. Rossa con A11
e A19.

DOMANDA: "Il maestro che riceve una domanda fatta precedentemente a un altro maestro deve sapere da chi arriva e deve sapere che risposta ha dato e deve informare l'utente di questo."
PROVA: test/il_filo_del_consulto_test.dart
MISURA: risposte del percorso B che nominano tutti i Maestri di prima negli ultimi tre giri 7, 8 e 8 su 10 (6-10 nei giri del giorno); filo in cima alla chat che lo dice alla persona prima 0, dopo 1 su 1 consulti con due Maestri
ACCETTAZIONE: apro Caligo dopo Medora e in cima leggo cosa ho chiesto a Medora e cosa mi ha risposto, anche quando Caligo non la nomina

## VOCE FE.15, LE TRE VOCI RESTANO DISTINTE

**CHIUSA.** L'attribuzione cieca gia' esistente (`tool/attribuzione_cieca.dart`)
lanciata prima e dopo, Maestro per Maestro, anche col filo di un altro
Maestro (`ATTRIBUZIONE_COL_FILO=1`, il giudice giudica chi scrive e non chi
e' citato). Prima, senza filo: Medora 100, Aura 100, Caligo 95 per cento
(`docs/collaudo/FE/attribuzione/fe15_senza_filo.txt`). Dopo il taglio
dell'istruzione, quattro giri (`*_dopo_il_taglio_1` e `_2`, senza filo e col
filo, commit `b8b78ad5`): 229 su 239, ogni Maestro a 85 o sopra in ogni giro.
Caligo scende a 85 in due giri su quattro (scambiato per Aura), dentro la
soglia.

DOMANDA: "lancia la misura dell'attribuzione cieca già esistente e dichiara nel rapporto il risultato prima e dopo, Maestro per Maestro. Se il passaggio del filo abbassa l'attribuzione, la causa si cura dentro questo ordine."
PROVA: docs/collaudo/FE/attribuzione/fe15_col_filo_dopo_il_taglio_1.txt
MISURA: attribuzione prima 59 su 60 (Medora 100, Aura 100, Caligo 95); dopo 229 su 239, 95,8 per cento (senza filo 56/59 e 58/60, col filo 56/60 e 59/60); minimo per Maestro dopo Medora 95, Aura 100, Caligo 85
ACCETTAZIONE: leggo Maestro per Maestro quante risposte il giudice cieco riconosce, prima e dopo, e nessuno scende sotto 85

## VOCE FE.16, SEI PERCORSI, COL MODELLO VERO

**CHIUSA.** I sei banchi del filo, A-F come l'ordine, col modello vero
Gemini in europe-west1, stanno nel comando unico
`tool/banchi_col_modello/i_banchi_col_modello.py` e scrivono un giro per
cartella in `docs/collaudo/banchi_col_modello/filo/` (34 giri il 6 ottobre).
Per le scelte "Tengo la migliore e chiudo" e "Correzione su Flash-Lite e filo
più corto" si dichiara il livello misurato degli ultimi tre giri (16:42,
16:52, 16:58): porta avanti A 87, B 87, C 100, D 97, E 90, F 97 per cento, 4
contraddizioni su 180 giudizi.

DOMANDA: "Costruisci sei banchi dentro tool/banchi_col_modello/, col modello vero e non con risposte finte, uno per percorso"
PROVA: docs/collaudo/banchi_col_modello/filo/2026-10-06T1658/percorso_b.txt
MISURA: banchi dei percorsi prima 0, dopo 6; giri registrati 34; ultimi tre giri porta avanti A 87, B 87, C 100, D 97, E 90, F 97 per cento, contraddizioni 4 su 180
ACCETTAZIONE: apro la cartella di un giro e trovo i sei percorsi con le risposte vere dei Maestri e il giudizio di ognuna

## VOCE FE.17, IL GIUDICE DELLA COERENZA

**CHIUSA.** Il giudice riceve le risposte in sequenza senza sapere cosa si
misura e dice se la nuova contraddice, ignora o porta avanti il punto fermo,
con la seconda lettura delle contraddizioni; e' tarato con due lettori alla
cieca (`docs/collaudo/FE/taratura_del_giudice/`). La soglia dell'ordine,
nessuna contraddizione e nove su dieci che portano avanti, non e' raggiunta
in ogni percorso: per la scelta "Tengo la migliore e chiudo" la soglia del
banco e' il livello dichiarato (al piu' due contraddizioni e almeno otto su
dieci per percorso), e il banco resta la rete che a ogni consegna prende un
peggioramento.

DOMANDA: "Soglia: nessuna contraddizione ammessa sui punti fermi della scheda, e almeno nove risposte su dieci che portano avanti il punto invece di aprirne uno nuovo."
PROVA: docs/collaudo/FE/taratura_del_giudice/regola_della_coerenza.md
MISURA: accordi dei due lettori col giudice 110 e 107 su 120; contraddizioni con la forma scelta 4 su 180 giudizi (3, 0, 1); percorsi sopra nove su dieci 4 su 6 (C, D, E, F), sotto A 87 e B 87 per cento
ACCETTAZIONE: so che il giudice e' stato controllato da due lettori, e conosco il livello a cui ho scelto di chiudere

## VOCE FE.18, I BANCHI RESTANO

**CHIUSA.** I sei banchi entrano nel comando unico, che adesso porta undici
casi; la consegna legge quanti sono dal comando (`--elenco`) invece del
cinque scritto a mano, e il risultato si legge a due cifre (`074b818d`).
Regola C: la rinomina da `i_cinque_banchi.py` e' entrata per errore nel
commit `ba5812cf` della FE.07. Il costo dei sei banchi del filo e' misurato
a ogni giro; un giro completo degli undici banchi con data del 6 ottobre sera
non c'e' in `docs/collaudo/banchi_col_modello/` (l'ultimo intero e' del 5
ottobre, a cinque): il suo costo si dichiara nelle righe in coda, col giro
della consegna della 2299.

DOMANDA: "I sei banchi entrano nel comando unico dei banchi col modello e girano a ogni consegna di una build, come già stabilito. Dichiara il costo di un giro completo dopo l'aggiunta dei sei."
PROVA: test/i_banchi_col_modello_hanno_un_comando_test.dart
MISURA: casi nel comando unico prima 5, dopo 11; costo dei sei banchi del filo 0,284-0,297 dollari a giro; costo del giro completo a 11 VEDI RIGHE IN CODA
ACCETTAZIONE: lancio un comando solo e girano tutti gli undici banchi, e trovo il costo del giro

## VOCE FE.19, LA CACHE DEL CONTESTO SI ACCENDE

**CHIUSA.** I token di ingresso mediani su dieci consulti nei tre stati,
dallo strumento `tool/il_costo_del_filo.dart` (consulti del banco con domande
scritte, non dati di persone vere, R8). Premessa abbattuta: la cache esplicita
dei prompt di sistema (`LaCacheDelContesto`, ordine EX voce 05) resta spenta,
perche' alla lettura alla cieca sbagliava il cielo 3 volte su 10
(`tool/il_costo_del_filo.dart` righe 32-34); lavora la cache implicita di
Vertex, che legge il prefisso gia' visto al 10 per cento del prezzo.

DOMANDA: "Dichiara nel rapporto, su dieci consulti reali, i token di ingresso mediani in tre stati: prima del filo, col filo e senza cache, col filo e con la cache."
PROVA: docs/collaudo/FE/costo/il_costo_del_filo_2026-10-06T1641.txt
MISURA: token di ingresso mediani su 10 consulti, giro delle 15:55: prima del filo 5536, col filo senza cache 5949, col filo e con la cache 2115 pagati a prezzo pieno; giro delle 16:41: 5521, 5908 e 6035 (Vertex quel giro non ha dato la cache al terzo turno: la cache implicita non e' garantita); risposte col cielo sbagliato con la cache esplicita 3 su 10, quindi resta spenta
ACCETTAZIONE: leggo i tre numeri mediani e il perche' la cache esplicita resta spenta

## VOCE FE.20, IL TETTO

**CHIUSA.** Il costo a freddo per consulto sale e si dichiara: prima
dell'ordine 0,00410-0,00418 dollari, dopo 0,00447, dal 7 al 9 per cento in
piu' (`docs/collaudo/FE/costo/il_costo_a_freddo.txt`). La cura e' quella
scelta dal fondatore: "Taglia l'istruzione di base" (1204-1288 caratteri, circa
300 token a turno, `d7e025b0`), la rete solo dopo un altro Maestro, la
correzione su Flash-Lite e il filo piu' corto (`ee15afe4`): la rete con le
sue correzioni da 0,0067 a 0,0022 dollari sui dieci consulti. Qualita' alla
cieca, due giri per versione con due giudici ciascuno
(`docs/collaudo/EX/qualita/fe20_oggi_1/` e `fe20_oggi_2/`, `conto.txt`):
sommati, dopo contro prima A 98 contro 104 su 120, B 23 contro 25 su 44, C 36
contro 34, D 95 contro 99, E 86 contro 89 su 96; fra i due giri D va da -6 a
+4, il rumore e' piu' grande della differenza. Il tetto del 30 per cento e'
rispettato su ogni ciclo (`docs/costi/i_limiti_degli_annuali.txt`, "TUTTI I
CICLI SOTTO IL TETTO"): annuali Iniziato 11 domande, Adepto 14 e 55 minuti,
Illuminato 18 e 95 minuti ("Domande e minuti insieme"); mensili Adepto 17 e
Illuminato 21 ("Una domanda in meno"). I limiti dell'annuale si applicano
quando il pagamento scrivera' il ciclo: oggi il piano si attiva solo in Demo.

DOMANDA: "Il costo per consulto dopo il lavoro non supera quello di prima. Se lo supera, dichiara di quanto e cura la causa riducendo il contesto che parte, mai la qualità della risposta. Il tetto del trenta per cento sui costi dell'AI non si sfora."
PROVA: test/i_limiti_degli_annuali_test.dart
MISURA: costo a freddo per consulto prima 0,00410-0,00418 dollari, dopo 0,00447 (+7-9 per cento); rete e correzioni da 0,0067 a 0,0022 dollari su 10 consulti; caso peggiore dei mensili Adepto e Illuminato prima 30,2 e 30,3 per cento del netto, dopo 29,3 e 29,7; cicli sopra il 30 per cento prima 2, dopo 0
ACCETTAZIONE: so di quanto e' salito il costo per consulto, e leggo che nessun piano supera il 30 per cento del netto

## VOCE FE.21.1, PRIMO: L'EMULATORE COL PROFILO DEL REDMI

**CHIUSA.** Il profilo esiste e i parametri sono dichiarati
(`docs/collaudo/FE/emulatore/config_redmi_note_14_pro_5g.ini`): 1220x2712
pixel, densita' 440, android-36 (Android 16), x86_64, nome
"Redmi Note 14 Pro 5G (24090RA29G)"; lo schermo del Redmi e' di 6,67 pollici
(fonte mi.com), la densita' fisica circa 446 ppi e 440 e' il gruppo Android
piu' vicino. L'emulatore non parte su questo PC: il driver aehd e' installato
ma fermo (`sc query aehd`, uscita 0xffffffa1, eventi 7000 e 7026); la
virtualizzazione nel firmware non e' misurabile perche' il WMI del PC
risponde "Classe non valida"
(`docs/collaudo/FE/fe04_e_fe21_ios_test_lab_emulatore.md`). Il crash si e'
preso da Crashlytics (FE.01) e la riproduzione e' passata a Test Lab
(FE.21.2).

DOMANDA: "Crea un profilo di emulatore che riproduca il Redmi Note 14 Pro 5G del tester: stessa risoluzione in pixel, stessa densità, stessa versione di Android, stessa dimensione dello schermo. ... Dichiara nel rapporto i parametri esatti del profilo che hai creato, così la prova è ripetibile da chiunque."
PROVA: docs/collaudo/FE/emulatore/config_redmi_note_14_pro_5g.ini
MISURA: profili del Redmi prima 0, dopo 1 (1220x2712, densita' 440, Android 16, 6,67 pollici); avvii riusciti su questo PC 0 su 1, driver aehd fermo con 0xffffffa1
ACCETTAZIONE: apro il file del profilo e ritrovo i numeri del telefono del tester, e so perche' su questo PC l'emulatore non parte

## VOCE FE.21.2, SECONDO: IL DISPOSITIVO FISICO VERO CON FIREBASE TEST LAB

**CHIUSA.** Il catalogo di Test Lab (208 modelli) non ha il Redmi Note 14 Pro
5G; si e' partiti dallo Xiaomi 14 houji, Android 15, l'unico Xiaomi, e per la
regola del fondatore sull'hardware uguale o inferiore si e' passati al Galaxy
A16 5G e al Galaxy A35 5G, Android 16 (`docs/collaudo/FE/test_lab/LEGGIMI.md`).
Video e registri in `docs/collaudo/FE/test_lab/`. Sui dispositivi l'app non
cade e il filo resta libero (FE.05). Il LIVE non si apre su Test Lab: l'account
di prova e' anonimo e non ha diritto ai minuti (`nonEPerTe`), e dargliene
vorrebbe dire scrivere sui dati di produzione, che la R8 vieta; si dichiara.

DOMANDA: "Verifica il catalogo dei dispositivi e dichiara nel rapporto se il Redmi Note 14 Pro 5G c'è. ... Porta nel rapporto il video e il log del crash, oppure la dimostrazione che su quel dispositivo l'app non cade."
PROVA: docs/collaudo/FE/test_lab/LEGGIMI.md
MISURA: Redmi Note 14 Pro 5G nel catalogo 0 su 208 modelli; dispositivi usati 3 (Xiaomi 14, Galaxy A16 5G, Galaxy A35 5G); cadute dell'app 0; filo fermo coi Maestri sullo Xiaomi 14 al piu' 37 ms; LIVE aperti 0 (account senza minuti, R8)
ACCETTAZIONE: leggo quale telefono e' stato usato al posto del Redmi e perche', e trovo video e registri nella cartella

## VOCE FE.21.3, IL COSTO DEL GIRO

**CHIUSA.** Il costo di Test Lab giro per giro, dalla durata del registro di
ogni dispositivo nel bucket dei risultati, che e' un tetto perche' comprende
installazione e raccolta, che non si pagano
(`docs/collaudo/FE/fe04_e_fe21_ios_test_lab_emulatore.md`, tabella del
compito 2). Listino: 5 dollari l'ora per dispositivo fisico, 30 minuti gratuiti
al giorno sul piano Blaze. Un giro come quelli lanciati costa da 2 a 3 minuti
per dispositivo: uno strumento da usare quando serve, non a ogni ordine.

DOMANDA: "Dichiara quanto consuma un giro di Test Lab come quello che hai lanciato, in euro o in minuti di dispositivo secondo come viene conteggiato"
PROVA: docs/collaudo/FE/fe04_e_fe21_ios_test_lab_emulatore.md
MISURA: esecuzioni su dispositivi fisici 19, minuti 58, costo a listino 4,83 dollari; minuti gratuiti 30 al giorno; un dispositivo per giro da 2 a 3 minuti, 0,17-0,25 dollari
ACCETTAZIONE: so quanto costa un giro di Test Lab e posso decidere quando usarlo

## VOCE FE.21.4, QUELLO CHE L'EMULATORE E TEST LAB NON PROVANO

**CHIUSA.** Dichiarato nel LEGGIMI di Test Lab: un verde di Test Lab non e'
una prova sulla voce, per tre ragioni (il LIVE non si apre, nessun
microfono, nessun audio registrato). Le registrazioni con schermo e suono dal
Realme restano in `docs/collaudo/FE/voci/` come misura di controllo, e la
voce sul Redmi resta al collaudo del tester sulla 2299, coi secondi scritti
da `LaVoceRicevuta` nel registro.

DOMANDA: "Dichiaralo nel rapporto, così nessuno scambia un verde di Test Lab per una prova sulla voce."
PROVA: docs/collaudo/FE/test_lab/LEGGIMI.md
MISURA: ragioni dichiarate 3 su 3; registrazioni dal Realme 4 (tre prima, una dopo) contro 0 audio da Test Lab
ACCETTAZIONE: leggo scritto che Test Lab non prova la voce, e dove stanno le registrazioni vere

## VOCE FE.21.5, PROVE DELLA VOCE

**CHIUSA.** a) Il profilo dell'emulatore esiste coi parametri dichiarati, e il
risultato e' scritto: non parte su questo PC (FE.21.1), quindi la
riproduzione Maestro per Maestro non c'e' dall'emulatore; lo stack e' venuto
dalla strada a) della FE.01. b) Il giro di Test Lab e' stato lanciato, i
dispositivi sono dichiarati e video e registri stanno in
`docs/collaudo/FE/test_lab/` (FE.21.2). c) Lo stack del crash e' scritto per
intero e tradotto (FE.01).

DOMANDA: "c) lo stack del crash, da qualunque delle due strade arrivi, è scritto per intero nel rapporto come chiede la voce FE.01."
PROVA: docs/collaudo/FE/lo_stack_del_redmi_tradotto.txt
MISURA: prove a), b) e c) 3 su 3 con il loro file; righe dello stack grezzo 1675, tradotte in file e riga 151; cartelle di giro di Test Lab 10
ACCETTAZIONE: trovo il profilo, i giri di Test Lab e lo stack tradotto, ognuno nel suo file

## VOCE FE.22.1, IL MENU' DELLA CHAT

**CHIUSA.** Nel menu' della chat: "Nuova chat" sempre in cima, poi le ultime
cinque conversazioni col cestino, "Chat precedenti" al posto di "I giorni
prima", e "LIVE con" col nome del Maestro aperto (`IlNomeDelLive`, mai scritto
a mano) al posto di "Parlami a voce" (`ab61ca83`); nel menu' la data corta,
"29 set", perche' il titolo si legga (`81e5af4c`). Anteprima in
`docs/preview/FE/fe22_menu_della_chat.png`. Rossa con A33, A35, A50, A60.

DOMANDA: "in cima, sopra l'elenco delle conversazioni, la voce nuova, carattere per carattere: Nuova chat ... al posto di "I giorni prima", carattere per carattere: Chat precedenti ... Il nome del Maestro si legge dal Maestro della chat e non si scrive mai a mano"
PROVA: test/i_nomi_del_menu_e_del_diario_test.dart
MISURA: stringhe mostrate "I giorni prima" e "Parlami a voce" prima 2, dopo 0; "LIVE con" provato su 3 Maestri su 3; voci nuove "Nuova chat" e "Chat precedenti" prima 0, dopo 2
ACCETTAZIONE: apro il menu' della chat di Aura e leggo "Nuova chat", "Chat precedenti" e "LIVE con Aura"

## VOCE FE.22.2, IL DIARIO COSMICO

**CHIUSA.** "Cosmic Journal" diventa "Diario Cosmico" in ogni testo mostrato,
i nomi delle classi e dei file restano (`ab61ca83`). La guardia cade se la
scritta resta in un testo mostrato: rossa con A34.

DOMANDA: "Una prova diventa rossa se la scritta "Cosmic Journal" resta in un testo mostrato all'utente."
PROVA: test/i_nomi_del_menu_e_del_diario_test.dart
MISURA: "Cosmic Journal" in lib prima 12, dopo 5 tutte nei commenti e 0 nei testi mostrati; "Diario Cosmico" dopo 15; innesto A34 rosso
ACCETTAZIONE: in nessuna schermata leggo piu' "Cosmic Journal", leggo "Diario Cosmico"

## VOCE FE.22.3, SEGNA NEL DIARIO

**CHIUSA.** Il gesto "Custodisci" diventa "Segna nel Diario" con la stella
(`ab61ca83`, anche nell'informativa). Il censimento con file e riga, prima e
dopo, sta in `docs/collaudo/FE/fe22_3_e_22_6_il_censimento.md`. La prova a)
del fondatore si legge alla lettera (`4bcc2d1e`): restavano quattro testi
mostrati con "Custodisci" (la voce dell'account, una carta, l'oroscopo
cinese, un presagio), riscritti anche alla fonte in `docs/corpus`, e la
guardia cade adesso sulla parola ovunque stia. Regola C: la guardia troppo
larga ha padre `ab61ca83` (FE.22). Rossa con A34 prima del tocco, poi con A83.

DOMANDA: "Enumera tutti i punti dell'app dove compare "Custodisci", con percorso del file e riga, e cambiali tutti."
PROVA: docs/collaudo/FE/fe22_3_e_22_6_il_censimento.md
MISURA: righe con "Custodisci" in lib prima 35, dopo il primo commit 29; testi mostrati con "Custodisci" prima 7 (4 del gesto, 3 di contenuto), dopo ab61ca83 4, dopo 4bcc2d1e 0; innesto A83 rosso
ACCETTAZIONE: in fondo a un responso leggo "Segna nel Diario" con la stella, e "Custodisci" non compare in nessun testo

## VOCE FE.22.4, NUOVA CHAT

**CHIUSA.** "Nuova chat" chiude il filo del consulto, battute e scheda, e
lascia intatta la memoria della persona: nome, forma, Sole, Luna,
ascendente, cammino, ricordi (`ab61ca83`). La prova misura cosa parte verso
il modello alla domanda dopo "Nuova chat" sul tema vecchio: nessun filo, e
la memoria della persona c'e'. Rossa con A36.

DOMANDA: "Il consulto nuovo parte senza il filo del consulto precedente, cioè senza le battute e senza la scheda dei punti fermi della voce FE.09. Il consulto nuovo parte con la memoria dell'utente intatta"
PROVA: test/la_nuova_chat_chiude_il_filo_test.dart
MISURA: blocchi del filo nella chiamata dopo Nuova chat prima 1, dopo 0; dati della memoria della persona nella chiamata prima e dopo uguali; innesto A36 rosso
ACCETTAZIONE: tocco "Nuova chat", il Maestro non trascina il tema di prima, ma sa ancora chi sono

## VOCE FE.22.5, PRIMA LA MISURA

**CHIUSA.** Le tre dichiarazioni con file e riga, prima (`ab61ca83`) e dopo
(`bd64f246`), in `docs/collaudo/FE/fe22_5_le_dichiarazioni.md`: a) cosa
scriveva "Custodisci" e dove; b) cosa contengono "Il Cammino" e "I Ricordi",
voce per voce, e da quale fonte; c) premessa abbattuta: il menu' e il Diario
erano due fonti diverse, il menu' dal server e il Diario dal telefono
(`sincronizza` senza chiamanti fino a `b2263a0f`, ordine EV voce 58). Le
catture del fondatore stanno in `docs/collaudo/FE/catture_del_fondatore/`.

DOMANDA: "a) cosa fa oggi il pulsante "Custodisci", cioè cosa scrive e dove; b) cosa contengono davvero le due schede "Il Cammino" e "I Ricordi", voce per voce, e da quale fonte ciascuna legge; c) perché le conversazioni di settembre di Medora non compaiono nel Diario."
PROVA: docs/collaudo/FE/fe22_5_le_dichiarazioni.md
MISURA: dichiarazioni con file e riga 3 su 3; fonti delle conversazioni prima 2 (server e telefono), dopo 1
ACCETTAZIONE: leggo perche' il mio Diario segnava zero a settembre mentre il menu' aveva tre conversazioni

## VOCE FE.22.6, IL DIARIO RACCOGLIE TUTTO DA SOLO

**CHIUSA.** Ogni responso entra nel Diario da se' coi suoi dati (`bd64f246`),
e le conversazioni le scrive il server nella stessa chiamata che salva il
messaggio (`77ad3e86`). Il censimento aveva trovato nove letture fuori: sei
senza la porta del responso (Viaggio dello Sciamano, Angelo Custode, Consiglio
dei Maestri, Oroscopo della settimana, del mese e dell'anno, Confronto del
cielo, Gemello della Sinastria) e tre con la porta in fondo a un elenco pigro
(Stesa, Sinastria, Sigillo dell'Intenzione). Curate nel commit `2ec15848` con
un punto solo, `annotaNelDiario`. Regola C: le sei hanno padre CG.06, le tre
la stessa porta montata in un `ListView`. Rossa con A77, A78, A79.

DOMANDA: "Ogni consulto, ogni responso e ogni lettura prodotta dall'app entra nel Diario da sé, senza che l'utente prema niente."
PROVA: test/ogni_lettura_entra_nel_diario_test.dart
MISURA: letture che non entravano o entravano solo scorrendo prima 9, dopo 0; voci nel Diario dopo aver solo guardato un responso 1; innesti A77-A79 rossi
ACCETTAZIONE: faccio una lettura degli Angeli senza premere niente e la ritrovo nel Diario

## VOCE FE.22.7, LA STELLA E' UNA SOLA

**CHIUSA.** C'erano due meccanismi, lo scrigno dei custoditi e il registro;
lo scrigno e' cancellato (`bd64f246`). Il pulsante "Segna nel Diario" e la
stella del Diario scrivono lo stesso campo dal registro, il filtro lo legge,
e condividere non segna. Rossa con A38, A39, A48.

DOMANDA: "Non nascono due elenchi, uno dei segnati e uno dei preferiti: è lo stesso segno, lo stesso campo, lo stesso filtro. Se nel ramo esistono già due meccanismi diversi, si unificano e il secondo si cancella."
PROVA: test/custodisci_e_parlane_test.dart
MISURA: meccanismi della stella prima 2, dopo 1; porte che scrivono la stella 1; innesti A38, A39, A48 rossi
ACCETTAZIONE: metto la stella da un responso, la tolgo dal Diario, e sparisce in tutti e due i posti

## VOCE FE.22.8, IL GIORNO EREDITA LA STELLA

**CHIUSA.** Il riassunto dell'anno porta le stelle per giorno, e il giorno
porta la stella finche' una sua voce la porta (`693a68d6`, `bd64f246`),
anche nella prova del server (`functions/src/diario.test.ts`, FE.22.8).
Anteprima in `docs/preview/FE/fe22_settimana_col_giorno_segnato.png`. A40
prima verde, la prova riscritta e poi rossa; A63 rosso.

DOMANDA: "Nel calendario del Diario un giorno porta la stella quando contiene almeno una voce con la stella. Non esiste un segno separato per il giorno"
PROVA: test/il_diario_cosmico_sul_server_test.dart
MISURA: segni separati per il giorno 0; stella del giorno con 1 voce segnata 1, tolta la stella 0; innesto A40 prima verde, poi rosso
ACCETTAZIONE: segno una voce e il suo giorno nel calendario prende la stella; la tolgo e il giorno la perde

## VOCE FE.22.9, IL FILTRO

**CHIUSA.** Accanto ai filtri per Maestro c'e' "Solo i segnati", che legge lo
stesso campo della stella (`bd64f246`). Lo guardano la prova della stella
unica (stessa porta, stesso filtro) e l'anteprima
`docs/preview/FE/fe22_diario_solo_i_segnati.png` della guardia
`test/le_anteprime_dell_ordine_fe_test.dart`. Rossa con A48.

DOMANDA: "Nel Diario c'è un filtro che mostra solo le voci con la stella, accanto ai filtri per Maestro che già esistono. Testo del filtro, carattere per carattere: Solo i segnati"
PROVA: test/custodisci_e_parlane_test.dart
MISURA: filtri dei segnati prima 0, dopo 1; voci segnate dal responso e dal Diario mostrate dal filtro 2 su 2; innesto A48 rosso
ACCETTAZIONE: tocco "Solo i segnati" e vedo le voci con la stella, quelle segnate dal responso e quelle segnate nel Diario

## VOCE FE.22.10, LA RIGA DELL'UTENTE

**CHIUSA.** Su una voce con la stella la persona scrive una riga sua, col
segnaposto dell'ordine, che resta con la voce (`bd64f246`); l'informativa lo
dice (`bc10833f`). Prova g) misurata su cio' che parte (`da92c6d8`): un turno
vero del controllore della chat con la rete della coerenza accesa, la riga
non compare in nessuna chiamata al modello. Anteprima in
`docs/preview/FE/fe22_voce_con_la_stella_e_la_riga.png`. A74 prima verde,
rossa cambiando la grandezza misurata (la riga oltre gli 80 caratteri).

DOMANDA: "Il testo è dell'utente e l'app non lo manda a nessun modello e non lo usa per generare risposte."
PROVA: test/la_riga_della_persona_non_parte_test.dart
MISURA: chiamate al modello misurate 3, caratteri partiti 45565, occorrenze della riga 0; innesto A74 prima verde, poi rosso
ACCETTAZIONE: scrivo "Perché vuoi ricordarlo?" su una voce e la ritrovo quando la riapro, e so che nessun modello la legge

## VOCE FE.22.11, IL RESPONSO SI CONSERVA COME DATI, NON COME IMMAGINE

**CHIUSA.** Del responso si conservano i dati che lo generano, nessuna
immagine della card; riaprendo la voce la card si ridisegna dalla copia di
comodo con la grafica di oggi (`bd64f246`). Il contenuto di una voce sta
sotto i mille byte, misurato sul dato vero.

DOMANDA: "Di un responso segnato si conservano i dati che lo generano ... Non si conserva nessuna immagine della card. Quando l'utente riapre quella voce, la card si ridisegna con la grafica dell'app di quel momento."
PROVA: test/custodisci_e_parlane_test.dart
MISURA: immagini della card conservate 0; peso massimo del contenuto di una voce 1000 byte; voci ridisegnate dai dati 1 su 1
ACCETTAZIONE: riapro un responso di giorni fa e la card si ridisegna, e nessuna immagine occupa spazio

## VOCE FE.22.12, LA VERSIONE DEL FORMATO

**CHIUSA.** Ogni voce porta il numero di versione del formato, sul server e
sul telefono, e chi ridisegna sa leggere le versioni vecchie: il formato 0 si
ridisegna come l'1 (`bd64f246`; `functions/src/diario.test.ts`, FE.22.12).
Rossa con A43.

DOMANDA: "Una prova ridisegna una voce scritta in una versione vecchia e cade se non ci riesce."
PROVA: test/il_diario_cosmico_sul_server_test.dart
MISURA: voci con la versione del formato prima 0, dopo tutte; voce del formato 0 ridisegnata 1 su 1; innesto A43 rosso
ACCETTAZIONE: una voce salvata col formato vecchio si apre ancora

## VOCE FE.22.13, DOVE STANNO

**APERTA IN ATTESA DI VERIFICA.** Conversazioni e voci del Diario stanno sul
server, legate all'account (`users/{uid}/diario`, `diario_voci`), con
l'indice per anno e per mese (`77ad3e86`, `693a68d6`); `riempiIlDiario`
travasa le conversazioni di prima e i custoditi, una volta per persona; il
telefono tiene una copia di comodo di al massimo 80 contenuti, e una
risposta vuota del server non la cancella (`bd64f246`; A49 prima verde, poi
rossa). Le funzioni sono pubblicate. Manca la verifica sul telefono: il
Diario che si riempie dal server, con la build 2299 sul Realme; si chiude
nelle righe in coda.

DOMANDA: "Tutte le conversazioni e tutte le voci del Diario stanno sul server e sono legate all'account, non al telefono. Cambiando telefono l'utente le ritrova tutte."
PROVA: test/il_diario_cosmico_sul_server_test.dart
MISURA: contenuti sul telefono al massimo 80; copie cancellate da una risposta vuota del server prima 1, dopo 0; voci ritrovate dal server sul Realme con la 2299 VEDI RIGHE IN CODA
ACCETTAZIONE: apro il Diario sul Realme con la 2299 e ritrovo le mie conversazioni lette dal server

## VOCE FE.22.14, L'INDICE E' SEPARATO DAL CONTENUTO

**CHIUSA.** Il Diario e il menu' leggono un indice leggero, una riga per voce
con titolo, data, Maestro, tipo e stella; il contenuto sta a parte in
`diario_voci` e si carica solo all'apertura (`77ad3e86`, `bd64f246`). Il
titolo e' il tema della scheda dei punti fermi, cioe' la domanda iniziale, e
Gemini non scrive piu' titoli (lapide di `titoli_da_gemini`).

DOMANDA: "Il Diario e il menù della chat leggono un indice leggero, con una riga per voce: titolo, data, Maestro, tipo, stella sì o no. Il contenuto intero di una voce si carica solo quando l'utente apre quella voce."
PROVA: functions/src/diario.test.ts
MISURA: peso di una riga dell'indice al piu' 200 byte; contenuti caricati all'apertura del Diario 0; titoli scritti da Gemini prima tutti, dopo 0
ACCETTAZIONE: il Diario si apre subito, e il contenuto di una voce arriva solo quando la tocco

## VOCE FE.22.15, L'ARCHIVIO PIU' ECONOMICO

**CHIUSA.** Il contenuto delle voci piu' vecchie di dodici mesi passa in
Cloud Storage, classe Archive, nel bucket di Firebase del progetto, come un
oggetto per persona e per mese (`diario_archivio/{uid}/{AAAA-MM}.json`,
`bc10833f`); un oggetto per voce costava piu' di vent'anni della voce su
Firestore (Regola C: padre `693a68d6`, FE.22.15, curato in `bc10833f`).
L'indice resta dov'e', e all'apertura compare "Sto riprendendo questo
giorno." Listino letto il 6 ottobre 2026, Belgio, in
`docs/collaudo/FE/il_costo_del_diario.md`.

DOMANDA: "Dichiara nel rapporto quale archivio hai usato e quanto costa per gigabyte al mese."
PROVA: docs/collaudo/FE/il_costo_del_diario.md
MISURA: Cloud Storage Archive 0,0012 dollari per GiB al mese, 0,05 dollari ogni 1000 scritture, 365 giorni minimi; oggetti per mese di una persona prima uno per voce, dopo 1; innesti S1 e S2 rossi
ACCETTAZIONE: leggo quale archivio uso e quanto costa al gigabyte, e una voce vecchia si riapre con "Sto riprendendo questo giorno."

## VOCE FE.22.16, PORTA UNICA

**CHIUSA.** Il menu' della chat legge le conversazioni dal Diario: una fonte
sola (`bd64f246`). La guardia cade se nasce una seconda strada per leggere
le conversazioni dell'utente: rotta una volta, rossa con A46.

DOMANDA: "Il menù della chat e il Diario leggono dalla stessa fonte. Se oggi sono due, si unifica e la seconda si cancella. Una guardia diventa rossa se nasce una seconda strada per leggere le conversazioni dell'utente, e lo dimostri rompendola una volta."
PROVA: test/la_porta_delle_conversazioni_e_una_test.dart
MISURA: fonti delle conversazioni prima 2, dopo 1; assegnazioni dell'elenco da un'altra fonte 0; innesto A46 rosso
ACCETTAZIONE: la stessa conversazione la vedo nel menu' della chat e nel Diario

## VOCE FE.22.17, IL CESTINO CANCELLA DAVVERO

**CHIUSA.** Il cestino chiede conferma con le parole dell'ordine e cancella
la conversazione dall'indice e dal contenuto, sul server e sul telefono
(`77ad3e86`, `bd64f246`, `81e5af4c`), e dal commit `5966b2b8` anche dai mesi
archiviati; l'azzeramento dei dati e la cancellazione dell'account cancellano
tutto `diario_archivio/{uid}/`. Regola C: prima i messaggi archiviati
sopravvivevano, padre FE.22.15 (`693a68d6` e `bc10833f`). Anteprima in
`docs/preview/FE/fe22_conferma_del_cestino.png`. Rossa con A47, A61, S3, S4.

DOMANDA: "Il cestino accanto a una conversazione la cancella per intero, dall'indice e dal contenuto, sul server e sul telefono. Non resta nascosta da nessuna parte, perché l'utente ha diritto di farla sparire."
PROVA: functions/src/diario.test.ts
MISURA: posti da cui il cestino cancella prima 3 (indice, contenuto, telefono), dopo 4 (anche l'archivio); conversazione ritrovata dopo la cancellazione 0; prove del server 202 su 202; innesti S3 e S4 rossi
ACCETTAZIONE: tocco il cestino, leggo "Vuoi cancellare questa conversazione? Non si potrà recuperare.", tocco "Cancella" e la conversazione non c'e' piu' da nessuna parte

## VOCE FE.22.18, IL TETTO DELLE LETTURE

**CHIUSA.** Aprire il Diario costa due letture, il riassunto dell'anno e il
mese, con cento voci come con mille (`77ad3e86`, `bd64f246`). Il costo dello
spazio per una persona attiva e' meno di 0,0003 dollari al mese
(`docs/collaudo/FE/il_costo_del_diario.md`), cioe' meno di 0,000268 euro al
cambio BCE del 5 ottobre 2026, 1,1204 dollari per euro. Rossa con A44.

DOMANDA: "L'apertura del Diario non supera dieci letture, qualunque sia il numero di voci che l'utente ha dietro. Dichiara nel rapporto le letture misurate con un account che ha cento voci e con uno che ne ha mille. Il costo per utente dello spazio occupato va dichiarato in euro al mese, con il conto che hai fatto."
PROVA: test/il_diario_cosmico_sul_server_test.dart
MISURA: letture all'apertura del Diario con 100 voci 2, con 1000 voci 2 (tetto 10); costo dello spazio per persona attiva meno di 0,000268 euro al mese; innesto A44 rosso
ACCETTAZIONE: il Diario si apre con due letture anche con mille voci, e so quanto mi costa lo spazio di una persona

## VOCE FE.23, IL FILO IN CIMA ALLA CHAT

**CHIUSA.** La precisazione del fondatore del 5 ottobre alle 23:48. Quando il
consulto passa da un Maestro all'altro, in cima alla chat compare "Hai chiesto
a Medora: «...»", e al tocco il parere di ogni Maestro gia' consultato, dalla
stessa scheda che il Maestro riceve (commit `d1798d05`, che porta per errore
la sigla "FE.22"; i pareri del Consiglio entrano nel filo con `c5cac77a`).
Chiuso e' alto 94 punti su 797; non compare con un solo Maestro ne' oltre
l'ora. L'anteprima del filo aperto, coi testi veri del banco del filo, e'
del commit `9732b538`: in cima alla chat di Calìgo "Hai chiesto a Medora:
«Riceverò la promozione che aspetto al lavoro?»" e sotto il parere di Medora.
Rossa con A13.

DOMANDA: "quando si approfondisce una domanda nel consiglio dei 3 maestri o continua con un altro maestro, ad ogni nuova apertura di conversazione, in alto la domanda dell'utente venga ripetuta tipo: "hai chiesto a [nome maestro] quando riceverò una promozione" e magari aggiungere cosa ha risposto il maestro precedente ogni maestri precedenti."
PROVA: docs/preview/FE/fe23_il_filo_aperto.png
MISURA: chat aperte da un secondo Maestro con la domanda in cima prima 0, dopo 1 su 1; altezza del filo chiuso 94 punti su 797 (tetto 110); pareri dei Maestri precedenti mostrati al tocco 1 su 1 nell'anteprima
ACCETTAZIONE: apro Calìgo dopo Medora e in alto leggo "Hai chiesto a Medora" con la mia domanda, e toccando leggo cosa mi ha risposto Medora
