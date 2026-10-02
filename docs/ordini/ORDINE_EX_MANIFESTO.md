# ORDINE EX, IL COSTO AI SOTTO IL 30 PER CENTO SENZA PERDERE QUALITA'

**Sigla:** EX. **Data dell'ordine:** 2 ottobre 2026, tre pezzi, piu' l'EX
Aggiunta (la specifica delle rune per prima) e l'EX Aggiunta 2 (il corpus delle
rune e' arrivato). **Ramo:** `claude/esoteric-circle-master-order-e798aj`,
nessun altro. **Partenza:** commit `666d0745`, col segno verde.

**Questo ordine non consegna niente**: nessuna build consegnata. Sul Realme e'
stata installata una build di collaudo con le catture permesse
(`--dart-define=CATTURE_PERMESSE=true`), solo per guardare a video.
**Code non ha scritto, riscritto o riformulato nessun testo di responso,
titolo di scheda o riga di "Da dove viene"**: i testi delle rune sono
dell'Architetto, copiati identici al byte; le righe nuove che Code ha scritto
sono istruzioni al modello e frasi dell'interfaccia (l'invito quando finiscono
le domande, quando finiscono le carte).

**La regola dell'ordine, NESSUNA RISPOSTA PEGGIORA**, si e' misurata col banco
della qualita' (`tool/il_banco_della_qualita.dart`, 30 casi col codice vero e
Gemini in europe-west1) e due giudici alla cieca per ogni confronto (il
secondo legge all'indietro), con la regola scritta in
`docs/collaudo/EX/qualita/regola_della_lettura.md`. Il rumore fra due giri
dello stesso codice e' di circa 2 o 3 punti per misura
(`docs/collaudo/EX/qualita/rumore/`).

**Le prove col modello vero**: dichiarate, in europe-west1, al massimo 3,19
dollari (`docs/collaudo/EX/il_costo_delle_prove.txt`).

VOCI_TOTALI: 11
VOCI_CHIUSE: 4
VOCI_APERTE: 7
VOCI_DA_FARE: 0

## VOCE EX.01, I MINUTI DEL LIVE SCENDONO DAVVERO

**APERTA IN ATTESA DI VERIFICA.** Il codice e' fatto e provato
(`functions/src/live.ts`, commit `da7f7957`): i minuti si contano coi secondi
veri di Protoface all'apertura e alla chiusura di ogni sessione, una sessione
dura al massimo i secondi rimasti, i tetti sono 60 e 120 minuti al mese.
`functions/src/live.test.ts`: 5 prove nuove, nate rosse (A1 in
`docs/collaudo/EX/regola_a_ex.txt`). **Manca la pubblicazione delle funzioni**:
il fondatore l'ha autorizzata in chat, ma il controllo dei permessi della
sessione di Code l'ha bloccata. Finche' non e' pubblicata, in produzione i
minuti non scendono. Dopo la pubblicazione: tre sessioni sul Realme e
un'apertura coi minuti finiti, nel "dopo" di
`docs/collaudo/EX/minuti_del_live.txt`.

## VOCE EX.02, LA MATRICE NUOVA

**APERTA IN ATTESA DI VERIFICA.** Telefono e server portano la matrice
dell'ordine (commit `7a6bf8ba`): domande 3/6/10/13, Vai piu' a fondo
0/2/2/3, confronti 0/1/2/3, carte estratte 3/6/10/15 contate a carte anche sul
server, stesa da 10 solo per Adepto e Illuminato, gettate 1/2/3/3, minuti LIVE
0/0/60/120; discese, segni e sigilli come prima. Le card dei piani portavano 8
numeri diversi dalla matrice nuova, adesso nessuno. La frase "col Cerchio le
domande ai Maestri sono senza limiti" (falsa per ogni piano, PROVENIENZA
IGNOTA) dice adesso il numero del cammino dopo. Il listino degli Eos
(`listino_degli_eos.dart`) e' disallineato, PROVENIENZA IGNOTA, e non e' montato
da nessuna schermata. Cosa succede quando finisce ogni limite: in
`docs/collaudo/EX/la_matrice_nuova.txt`. **Il server pubblicato ha ancora i
limiti di prima** (stessa pubblicazione dell'EX.01): fino ad allora un
Iniziato si ferma a 5 domande sul server invece di 6. Le catture del Realme
stanno in `docs/collaudo/EX/realme/`. Difetto trovato dalla suite intera e curato: il Consiglio dei Maestri
mostrava solo il Maestro di partenza all'Iniziato col suo unico confronto
pagato (padre EX.02; A11).

## VOCE EX.03, LE RUNE DAL CORPUS, SENZA RIPETIZIONI PER 60 GIORNI

**CHIUSA.** La specifica e' stata spinta prima di ogni altra voce (commit
`44004806`, 4.929 voci in 140 gruppi). Il corpus dell'Architetto (5.411 voci)
e' entrato identico al byte, il generatore l'ha portato nel codice, la
schermata compone il presagio senza modello (commit `386b9e57`). Le prove della
specifica, sezione 7: forma 0 difetti su 5.411 voci, 0 gruppi sotto il numero
su 140, 0 voci ripetute su 359.931 gettate simulate per 2.000 persone in due
scenari, 0 file del codice diversi da quelli dell'Architetto su 5, 0 chiamate
al modello per una gettata sulla schermata vera
(`test/il_corpus_delle_rune_test.dart`,
`test/le_rune_non_chiamano_il_modello_test.dart`), tutte nate rosse (A8, A9,
A10). La gettata col corpus guardata a video sul Realme:
`docs/collaudo/EX/realme/`. Due voci dicono a chi legge di essere un uomo (PIETRA Uruz dritta 56,
Mannaz in ombra 38): riportate all'Architetto, il codice non le sceglie
finche' non arrivano corrette (A13).

DOMANDA: "Voglio corpus grandi, non voglio ripetizioni per almeno 60gg e voglio tenere alta l'esperienza utente e non voglio critiche per le risposte, mi raccomando."
PROVA: docs/collaudo/EX/rune_senza_ripetizioni.txt
MISURA: file del codice diversi da quelli dell'Architetto 0 su 5; gruppi sotto il numero che serve 0 su 140; voci ripetute alla stessa persona in 60 giorni al massimo dell'Illuminato, due scenari, 2.000 persone, 359.931 gettate: 0; chiamate al modello per gettata da 1,85 a 0

## VOCE EX.04, IL "VAI PIU' A FONDO" SCRITTO INSIEME ALLA RISPOSTA

**APERTA IN ATTESA DI VERIFICA.** Per i piani col secondo strato il Maestro
scrive il seguito nella stessa risposta, dopo il segno `[[SEGUITO]]`; il
telefono lo tiene nascosto e lo scopre al tocco senza chiamare (commit
`431f7b4c`). Al banco: tocchi senza chiamata da 0 su 24 a 20 su 24, chiamate
al tocco da 1,46 a 0,17 (la voce chiedeva 0), un tocco a freddo da 0,00390 a
0,00046 dollari. Difetto trovato e curato dentro la voce: al primo giro il
seguito arrivava in 6 risposte su 24 (padre: EX.04, l'istruzione in fondo
contro la regola dell'ultima riga dell'ordine EQ voce 01). Confronto alla
cieca del seguito al giro finale: 14 contro 16 e 13 contro 14 su 24, dentro il
rumore; al giro prima della cura era 9 contro 13 e 7 contro 11, e la voce
sarebbe restata aperta. Resta aperta perche' 0,17 non e' 0 e il tocco non e'
ancora stato guardato a video. Prova: `docs/collaudo/EX/vai_piu_a_fondo.txt`.

## VOCE EX.05, LA CACHE DEL CONTESTO GARANTITA

**APERTA.** L'istruzione ha adesso la parte comune in testa: due persone
diverse condividono circa l'80 per cento dell'istruzione (guardia nuova
`test/la_parte_comune_viene_prima_test.dart`, nata rossa, A5); quando la cache
implicita prende, prende 4.820 token invece di 3.854. Ma la cache implicita
non e' garantita: a dieci minuti la quota media e' stata 34 per cento prima e
16 dopo, con sei richieste su otto a zero. La cache esplicita costerebbe circa
31 dollari al mese e conviene sopra circa 33 richieste all'ora: oggi non si
accende. Attribuzione alla cieca dei Maestri dopo il riordino: 56 su 60, ogni
Maestro sopra l'85 per cento (`docs/collaudo/EX/attribuzione_dopo_ex05.txt`).
Prova: `docs/collaudo/EX/la_cache.txt`.

## VOCE EX.06, I RICORDI NELLA REGIONE DEI DATI

**CHIUSA.** La penna della lettura del mese chiamava us-central1 dall'ordine
CG voce 11; adesso europe-west1 (commit `8db4fa43`). La guardia della regione
pretende `location:` in ogni `FirebaseAI.vertexAI` del telefono, nata rossa sul
difetto vero.

DOMANDA: "...Ma la cache e gli scheletri che dovevano abbattere del 70% i costi AI funzionano?"
PROVA: docs/collaudo/EX/regione_dei_ricordi.txt
MISURA: chiamate dei Ricordi fuori da europe-west1, prima 20 nel banco EW, dopo 0 su 3; FirebaseAI.vertexAI senza regione nel telefono, prima 1 su 9, dopo 0 su 9

## VOCE EX.07, MENO RISPOSTE RIFATTE

**APERTA.** La rete della posizione non rifa' piu' le domande di fatti del
cielo; quando una rete scarta una risposta, la correzione e' corta (domanda,
risposta scartata, correzione, memoria, cielo del turno) invece della
richiesta intera. Chiamate per una risposta della chat al banco: da 2,46 a
1,71 (1,45 senza le domande sul cielo di altre date); l'obiettivo "verso 1,3"
non e' raggiunto. La correzione corta contro quella intera, sulla stessa
risposta scartata, due giri e due giudici: regole 77 contro 75, memoria 55
contro 49, merito 74 contro 74. Difetto trovato e curato dentro la voce: una
correzione ha scritto "Giove in Cancro" per il 2028 (e' in Vergine), padre
EX.07; adesso riceve il cielo del turno (prova nuova nata rossa, A7). Prova:
`docs/collaudo/EX/risposte_rifatte.txt`.

## VOCE EX.08, IL CIELO DI OGGI GIA' NELLA RICHIESTA

**CHIUSA.** Il cielo di oggi si calcola una volta al giorno e sta gia' nella
richiesta; la funzione si chiama solo per gli altri giorni. Difetto trovato e
curato dentro la voce: il blocco del cielo copiato in una risposta (padre
EX.08), curato con la riga "non copiare quel blocco".

DOMANDA: "...Ma la cache e gli scheletri che dovevano abbattere del 70% i costi AI funzionano?"
PROVA: docs/collaudo/EX/il_cielo_nella_richiesta.txt
MISURA: chiamate per una domanda sul cielo di oggi al banco della qualita', prima 2,6, dopo 1,0; domande su oggi che chiamano la funzione, prima 4 su 7, dopo 0 su 7 (due giri); fatti del cielo sbagliati sulle venti domande dell'EV.03, prima 2, dopo 0 e 0; negati prima 0, dopo 0 e 0

## VOCE EX.09, LA MEMORIA COMPATTA

**CHIUSA.** La storia al modello e' di 8 messaggi (erano 20), piu' il
riassunto breve: la sintesi e i fatti della memoria, e cio' che la persona ha
scritto prima della finestra in questa conversazione. Prova nuova
`test/la_memoria_compatta_test.dart`, nata rossa (A6). Confronto alla cieca
del banco intero, misura B: 9 contro 8 e 9 contro 10 su 11, dentro il rumore.

DOMANDA: "Inserisci tutto tranne la 5 di Protoface, è un costo fisso che si ammortizza col tempo e col numero di abbonati. Voglio corpus grandi, non voglio ripetizioni per almeno 60gg e voglio tenere alta l'esperienza utente e non voglio critiche per le risposte, mi raccomando."
PROVA: docs/collaudo/EX/memoria_compatta.txt
MISURA: dettaglio detto da 5 a 9 scambi prima usato dalla risposta, prima 4 su 10, dopo 7 su 10 con tutti e due i giudici; merito prima 7 e 5 su 10, dopo 8 e 8; ingresso medio di una richiesta della chat, prima 8.800 token, dopo 8.307

## VOCE EX.10, LA SCENA DEL VIAGGIO SENZA MODELLO

**APERTA.** Tre vie misurate, tutte peggiori nel merito oltre il rumore con
tutti e due i giudici: la scena di casa (12 contro 1 e 12 contro 0 su 20), un
tentativo solo (11 contro 3, 10 contro 6), due tentativi (10 contro 7, 9
contro 6). Il codice della scena resta quello di oggi, 2,6 chiamate di scena
per discesa. Prova: `docs/collaudo/EX/scena_del_viaggio.txt`.

## VOCE EX.11, LA MISURA FINALE

**APERTA IN ATTESA DI VERIFICA.** Col codice di questo ordine, al massimo per
trenta giorni, senza cache, LIVE compreso: Iniziato 1,28 dollari (tetto 2,36),
Adepto 3,34 (tetto 4,72), Illuminato 5,42 (tetto 7,08); prima 5,66, 11,90 e
31,73. Le stese da 1, 5 e 10 carte sono una stima dichiarata. Resta aperta
perche' il LIVE dentro il tetto vale solo quando i minuti scendono davvero
(EX.01, pubblicazione) e perche' i limiti nuovi del server non sono
pubblicati. Prova: `docs/costi/costo_per_utente_dopo_ex.md`.
