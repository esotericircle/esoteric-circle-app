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
VOCI_CHIUSE: 7
VOCI_APERTE: 4
VOCI_DA_FARE: 0

## VOCE EX.01, I MINUTI DEL LIVE SCENDONO DAVVERO

**CHIUSA.** I minuti si contano coi secondi veri di Protoface all'apertura e
alla chiusura di ogni sessione, una sessione dura al massimo i secondi
rimasti, i tetti sono 60 e 120 minuti al mese (`functions/src/live.ts`).
Pubblicate dal fondatore alle 14:03 UTC dal commit `1a076c42`. Al collaudo sul
Realme (sola lettura del registro del server): minuti rimasti all'apertura
120, 119, 118, 117; coi minuti finiti il telefono dice "Per questo mese ho
finito il fiato" e nessuna sessione si apre. Difetto trovato dal collaudo e
curato (padre EX.01): una sessione chiusa prima che Protoface scrivesse i suoi
secondi si contava zero (28 secondi, fatturati 29); adesso resta da contare
(prova nata rossa, A14). Ripubblicate dal fondatore alle 15:15 UTC dal commit
`2a811596`; dopo la cura una sessione chiusa dopo 8 secondi si conta 8, e il
consumo del mese di Protoface sale di 8. Per la prova dei minuti finiti Code
aveva scritto per un momento sui dati del telefono di collaudo: il fondatore
ha vietato ogni scrittura sui dati di produzione, e la regola sta nelle note
di lavoro.

DOMANDA: "Il difetto dei minuti che non scendono va assolutamente sistemato."
PROVA: docs/collaudo/EX/minuti_del_live.txt
MISURA: minuti rimasti all'apertura dopo tre sessioni, prima 250 e 250 (fermi), dopo 120, 119, 118, 117; sessione aperta coi minuti finiti, prima si', dopo no; secondi contati contro fatturati da Protoface, uguali al secondo in 5 sessioni su 6 verificate (41, 79, 27, 20 e, dopo la cura, 8); la sesta contata 0 invece di 29, difetto curato

## VOCE EX.02, LA MATRICE NUOVA

**CHIUSA.** Telefono e server portano la matrice dell'ordine (commit
`7a6bf8ba`), con le domande alzate dall'EX Aggiunta 3: domande 3/12/18/22
(con l'EX.02 erano 3/6/10/13), Vai piu' a fondo 0/2/2/3, confronti 0/1/2/3,
carte estratte 3/6/10/15 contate a carte anche sul server, stesa da 10 solo
per Adepto e Illuminato, gettate 1/2/3/3, minuti LIVE 0/0/60/120; discese,
segni e sigilli come prima. Server pubblicato dal fondatore (14:03 e 15:15
UTC). La frase "col Cerchio le domande ai Maestri sono senza limiti" (falsa
per ogni piano, PROVENIENZA IGNOTA) dice adesso il numero del cammino dopo. Il
listino degli Eos (`listino_degli_eos.dart`) e' disallineato, PROVENIENZA
IGNOTA, e non e' montato da nessuna schermata. Cosa succede quando finisce
ogni limite: in `docs/collaudo/EX/la_matrice_nuova.txt`. Difetto trovato dalla
suite intera e curato: il Consiglio dei Maestri mostrava solo il Maestro di
partenza all'Iniziato col suo unico confronto pagato (padre EX.02; A11).
Guardato sul Realme con la build 2293: le card dell'Iniziato, dell'Adepto e
dell'Illuminato dicono 12, 18 e 22 domande, 6, 10 e 15 carte, 2 e 3 gettate,
60 e 120 minuti; la chat legge dal server "Ti restano 17 domande ai Maestri
su 22".

DOMANDA: "Cmq, partiamo da qui, come dici tu e mettiamo limite delle carte estratte e la stesa a 10 solo dal tier 2 19,99."
PROVA: docs/collaudo/EX/la_matrice_nuova.txt
MISURA: numeri delle card dei piani diversi dalla matrice, prima 8, dopo 0 (catture docs/collaudo/EX/realme/piani_aggiunta3_*.png); tetti del server diversi dalla matrice, dopo 0 (test/i_limiti_del_server_sono_quelli_promessi_test.dart); domande al giorno sul server, prima 3/5/10/50, dopo 3/12/18/22

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

**EX Aggiunta 4, 2 ottobre 2026 sera.** Le chiamate al tocco nascevano dal
modello che saltava il seguito (3 o 4 risposte su 24) e dalla correzione corta
che non lo chiedeva. Adesso la correzione corta chiede anche il seguito, e se
la risposta arriva senza, l'app lo prepara subito in sottofondo
(`MaestroChatController._preparaIlSeguitoSeManca`): il tocco lo trova pronto,
o aspetta quello in preparazione, senza chiamare. Al banco: chiamate al tocco
da 0,17 a 0 in sei giri su sei (144 tocchi); risposte senza seguito da 1 a 6
su 24, col seguito preparato dopo la risposta. Seguito alla lettura alla cieca,
giro finale contro fine4: 20 contro 14 e 21 contro 18 su 24. Difetto della
prima stesura curato dentro la voce: la preparazione partiva anche
all'apertura della chat, una chiamata a ogni apertura (padre: questa voce).
Prova nuova nata rossa (A15). Resta in attesa del tocco guardato a video sul
Realme con la build nuova. Prova: `docs/collaudo/EX/vai_piu_a_fondo.txt` e
`docs/collaudo/EX/le_quattro_voci_sistemate.txt`.

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

**EX Aggiunta 4, 2 ottobre 2026 sera.** La cache garantita e' scritta e
provata: la funzione `laCacheDelContesto` che ogni dieci minuti conta le
richieste dell'ultima ora e accende o lascia scadere le cache su Vertex, il
telefono che chiede la risposta al template di Firebase con la cache, i
prefissi con la loro guardia (nata rossa, A24). La soglia calcolata e
dichiarata: pareggio a 22,2 richieste all'ora, accensione a 23, spegnimento
sotto 18 (sei varianti; il "circa 33" era il conto con nove). Traffico simulato
2 casi su 2; a 50 richieste all'ora l'inizio dell'istruzione costa il 50 per
cento in meno, a 200 l'80. **Ma la via della cache non regge la lettura alla
cieca**: il merito e' pari, il seguito scende (18 e 12 contro 22 e 18) e il
cielo sbaglia (7 contro 10 su 10 con tutti e due i giudici), perche' i
template di Firebase non portano ne' la conversazione ne' le funzioni e il
cielo di oggi si confonde con quello del giorno chiesto. Per la regola NESSUNA
RISPOSTA PEGGIORA resta spenta in tre punti (l'interruttore dell'app, la
funzione non esportata, la regola di Firestore fuori dal repository) e non c'e'
niente da pubblicare. Prova: `docs/collaudo/EX/la_cache_garantita.txt`.

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

**EX Aggiunta 4, 2 ottobre 2026 sera.** Contati gli scarti della prima
risposta: la rete della posizione (37 su 62) e quella delle certezze (25 su
62), piu' tre cause che nessun contatore diceva (la rete del lessico, le
funzioni del cielo per i giorni nominati, le domande "Da dove...?" lette da si'
o no). Il primo turno adesso dice cio' che diceva solo la correzione (le tre
forme del si' o del no, la condizione che e' una cosa da fare, il futuro con
la sua condizione), il cielo dei giorni nominati arriva gia' calcolato, e due
falsi positivi delle reti sono curati (il cielo calcolato preso per una
certezza, la parola della persona presa per la firma di un altro Maestro).
Prove nuove nate rosse (A16-A20). Chiamate per risposta da 1,71 a 1,29 di
media sui sette giri; domande sul cielo di altre date da 2,75 a 1,00; alla
lettura alla cieca, giro finale contro fine4, merito 27 e 27 contro 27 e 25,
regole 30 e 30 contro 28 e 28, cielo 10 e 10 contro 9 e 9, seguito 20 e 21
contro 14 e 18; attribuzione cieca dei Maestri 58 su 60. **Resta aperta**: sul
codice finale due giri danno 1,33 e 1,38, sopra l'1,3; restano 5 risposte su
24 rifatte dalla rete del lessico ("sentire" in bocca a Medora, "ascendente"
in bocca ad Aura e a Calìgo), che Code non toglie dal testo. Prova:
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

**EX Aggiunta 4, 2 ottobre 2026 sera.** Contati gli scarti per guardia (al
codice di partenza 78 righe in 20 discese, prime "chiede di scrivere" 16 e
"previsione certa" 13), l'istruzione li dice per nome; una frase scartata dopo
la prima si toglie in casa se il resto regge a tutte le guardie; il modello
scrive due riserve di ogni testo nella stessa chiamata, lette dalle stesse
guardie (prova nuova nata rossa, A21). Nessuna riga delle guardie toccata.
Chiamate di scena per discesa da 2,70 a 1,90 e 1,80, scene dal modello 20 su
20, nessun silenzio; merito alla lettura alla cieca 13 e 12 contro 13 e 13.
Con due tentativi invece di tre si scendeva a 1,65 ma il merito perdeva 1 e 2:
restano tre. Gli obiettivi (scena 1,5, discesa 2,5) non sono raggiunti: la
discesa con la domanda scritta fa circa 3,0 chiamate. Prova:
`docs/collaudo/EX/la_scena_con_meno_scarti.txt`.

## VOCE EX.11, LA MISURA FINALE

**CHIUSA.** Col codice di questo ordine e le domande dell'EX Aggiunta 3, al
massimo per trenta giorni, senza cache, LIVE compreso, rune dal corpus:
Iniziato 2,18 dollari (tetto 2,36), Adepto 4,54 (tetto 4,72), Illuminato 6,77
(tetto 7,08); prima dell'ordine 5,66, 11,90 e 31,73. Con le domande
dell'EX.02 (3/6/10/13) erano 1,28, 3,34 e 5,42: il fondatore ha scelto di
spendere quasi tutto il margine in domande. Le stese da 1, 5 e 10 carte sono
una stima dichiarata. Il LIVE dentro il tetto vale davvero: i minuti
scendono e si fermano a 60 e 120 (EX.01), e i limiti del server sono quelli
della matrice (EX.02).

DOMANDA: "30% Dopo iva e Store, 2,36$."
PROVA: docs/costi/costo_per_utente_dopo_ex.md
MISURA: costo al mese al massimo per piano, prima 5,66, 11,90 e 31,73 dollari, dopo 2,18, 4,54 e 6,77, sotto il tetto (2,36, 4,72 e 7,08) in 3 piani su 3
