# ORDINE EW, QUANTO COSTA UN UTENTE

**Sigla:** EW, verificata sul ramo sul commit `55d3a267`: in `docs/ordini`
l'ultimo manifesto era `ORDINE_EV_MANIFESTO.md` e non esisteva `ORDINE_EW`; in
`docs/collaudo` non esisteva la cartella EW. **Data dell'ordine:** 2 ottobre
2026, tre pezzi. **Ramo:** `claude/esoteric-circle-master-order-e798aj`,
nessun altro. **Partenza:** commit `55d3a267`, col segno
`refs/verde/55d3a267...` presente.

**Questo ordine non consegna niente**: nessuna build. **Nessun comportamento
dell'app cambia**, salvo l'etichetta della voce EW.03. Google Cloud solo in
lettura; Firestore di produzione ne' letto ne' scritto. **Code non ha scritto,
riscritto o riformulato nessun testo di responso, titolo di scheda o riga di
"Da dove viene".**

**La stima dichiarata prima di cominciare**: da 14 a 16 ore, e da 12 a 18
dollari di prove col modello vero, piu' pochi minuti di Protoface e LiveKit.
**Le prove sono costate al massimo 2,03 dollari** (1.125 chiamate a Gemini,
1,94 dollari al massimo, e 9 crediti Protoface): la prova e'
`docs/collaudo/EW/il_costo_delle_prove.txt`.

VOCI_TOTALI: 7
VOCI_CHIUSE: 5
VOCI_APERTE: 2
VOCI_DA_FARE: 0

Le prove stanno in `docs/costi/` (i sette documenti dell'ordine) e in
`docs/collaudo/EW/`. Il banco del costo e' `tool/il_banco_del_costo.dart` con
`tool/il_banco_del_costo_comune.dart`; i conti `tool/i_conti_del_costo_ew.py`.

## VOCE EW.01, OGNI CHIAMATA AL MODELLO

**CHIUSA.** Due tabelle, A (Tarocchi, chat dei Maestri e LIVE) e B (tutte le
altre), con per ogni punto il file, il modello, la regione, l'ordine e la voce
che l'hanno introdotto (con le parole del fondatore quando ci sono), le
chiamate per uso, cosa succede senza il modello, la cache o lo scheletro, il
flusso, il ragionamento e il tetto. **18 punti**: 12 nella tabella A, 6 nella
B; 15 modelli Google che girano davvero (il distillato della memoria non ha
piu' chiamanti dall'ordine CG.09; i due punti di Protoface sono il volto, non
un modello Google). Fra i fatti trovati: la penna dei Ricordi senza regione,
cioe' da us-central1 (padre CG.11, commit `e69c13e3`); la consulta Profonda
che nessuna strada dell'app chiede; `CLAUDE.md` che diceva Flash-Lite per la
risposta Breve mentre la chat usa Flash.

DOMANDA: "Tuttavia non avevo idea che il viaggio toccasse la AI..."
PROVA: docs/costi/le_chiamate_al_modello.md
MISURA: punti del codice che chiamano un modello documentati, prima 0 su 18, dopo 18 su 18; fuori da Tarocchi, chat e LIVE 6 punti (Rune, Sigillo, Viaggio segno, Viaggio domanda, Viaggio scena, Ricordi del mese)

## VOCE EW.02, IL VIAGGIO E IL MODELLO

**CHIUSA.** Le discese del piano sono 1 al giorno per tutti prima della
rivelazione (quattro giorni) e 1, 1, 1 e 2 al giorno dopo; i segni 1 e 3 a
settimana, 1 e 5 al giorno; nutrire sempre, senza modello; "curare" non esiste
come gesto con un limite. **Dieci e' il tetto tecnico invisibile sopra il
piano**: le parole sono dell'ordine DI voce 15 del 12 settembre (*"dieci
chiamate al modello al giorno per utente, contando discese e segni
insieme"*), l'unita' cambiata dall'ordine DL voce 09 del 14 settembre (dieci
discese e dieci segni). Nessuno dei due ordini dice perche' dieci. Il Viaggio
tocca il modello in tre punti dal 12 e 13 settembre (DI.02, DI.03, DI.14). Una
discesa fa 3,8 chiamate e costa 0,0035 dollari; l'Illuminato che usa tutto il
Viaggio costa 0,23 dollari al mese.

DOMANDA: "Ma perché 10 discese del viaggio? Le discese sono 4 per rivelare l'animale e poi l'utente può rientrare per nutrire l'animale e "curarlo" e fargli altre domande."
PROVA: docs/costi/il_viaggio_e_il_modello.md
MISURA: discese al giorno del piano 1 o 2 contro un tetto tecnico di 10; chiamate per discesa 3,80 su 20 discese misurate; costo per discesa 0,00345 dollari, per segno 0,00012; Illuminato al massimo 0,23 dollari al mese

## VOCE EW.03, L'ETICHETTA DELLA FUNZIONE

**APERTA IN ATTESA DI VERIFICA**. Ogni chiamata al modello del telefono porta
adesso `labels: {funzione: ...}` nel corpo, con 16 etichette
(`lib/services/ai/l_etichetta_della_funzione.dart`, 13 punti su 13); le due
chiamate di sintesi del server le portano nel codice (`functions/src/live.ts`,
2 su 2). Chirp 3 HD non accetta etichette. La guardia nuova
`ogni_chiamata_al_modello_porta_l_etichetta_test.dart` e' rossa su tre
innesti.

Cosa manca, in tre punti: (1) **le etichette si vedono solo nel report
Fatturazione**, con un giorno di ritardo: Monitoring non le porta e
l'esportazione in BigQuery non e' attiva; le serie di prova `prova_ew_passaggio`
e `prova_ew_diretto` dicono domani se il passaggio di Firebase le fa arrivare;
(2) **le due funzioni del server con l'etichetta sono pubblicate** (il 2
ottobre alle 06:22 UTC, col si' del fondatore, dal commit `8e798a60`): la
prima chiamata vera della voce del Maestro e' da leggere nel report; (3) le
etichette del telefono arrivano con la prima build dopo quest'ordine. Misurato
anche: un'etichetta non valida passa con HTTP 200 sia dal passaggio di Firebase
sia da Vertex, quindi il codice di risposta non prova niente.

DOMANDA: "La fattura è di 40 euro circa. Ma a settembre sono scaduti i crediti free..."
PROVA: docs/collaudo/EW/etichette.txt
MISURA: chiamate al modello con l'etichetta della funzione, prima 0 su 15, dopo 15 su 15 nel codice (13 del telefono, 2 del server); chiamate di prova etichettate per funzione 621 del banco piu' 16 delle due serie riconoscibili, divise per funzione nel report Fatturazione: da leggere il 3 ottobre

## VOCE EW.04, IL COSTO DI OGNI FUNZIONE

**CHIUSA.** Il banco del costo fa girare il codice vero dell'app con Gemini in
europe-west1 e legge `usageMetadata` da ogni risposta: 621 chiamate in 17 casi,
almeno 20 usi per caso. Costo per uso medio e massimo, con la cache misurata e
senza. Il ragionamento e' spento ovunque tranne la Profonda (426 token a uso,
il 65 per cento dell'uscita pagata), che nessuna strada dell'app chiede; **la
metrica `token_count` di Monitoring conta il ragionamento**, verificato al
token (`docs/collaudo/EW/token_count_conta_il_ragionamento.txt`). Breve e Lunga
sono la profondita' dell'oroscopo, che esce dal corpus e non chiama il
modello; la "Lunga" del modello e' la Profonda, misurata. La memoria vuota e
piena: piena alla finestra di 14 giorni, uguale per tutti i piani che hanno la
memoria; il Viandante non ce l'ha. Le domande sul cielo costano circa il
doppio delle altre.

DOMANDA: "Ho creato un sistema di scheletri e uso cache... Devo capire se devo intervenire..."
PROVA: docs/costi/costo_per_funzione.md
MISURA: casi misurati col modello vero 17 su 17, prima 0; usi per caso da 20 a 30; chiamate lette 621; costo per uso da 0,00002 dollari (il titolo) a 0,0078 (la voce di una risposta del LIVE); una domanda in chat 0,0069 dollari senza cache, 0,0043 con la cache misurata

## VOCE EW.05, QUANTO COSTA UN UTENTE AL MASSIMO

**CHIUSA.** La giornata al massimo di ogni piano coi limiti del codice, trenta
giorni contro il prezzo. **Iniziato 5,66 dollari al mese** (50 per cento dei
9,99 euro lordi; 11,56 se ogni uso cade al suo massimo misurato), Adepto 11,90
col LIVE, Illuminato 31,72 col LIVE, Viandante 0,84. **95 dollari al mese sono
17 Iniziati che usano tutto** (8 al caso peggiore). Le gettate di rune sono
quasi due terzi del costo dell'Iniziato. Le differenze fra i limiti del codice
e il Briefing §22 elencate e non corrette; i tetti dell'Illuminato; voce e LIVE
per Adepto e Illuminato; le funzioni pagate con gli Eos a parte.

DOMANDA: "Il tier 1 spende 9,99 euro al mese, hai già calcolato il suo consumo medio o massimo? ... a quante persone tier 1 corrispondono 95 dollari o quanto mi costa un utente che sfrutta tutto al massimo?"
PROVA: docs/costi/costo_per_utente.md
MISURA: Iniziato al massimo 5,66 dollari in 30 giorni contro 11,29 di prezzo (50 per cento); Iniziati al massimo per 95 dollari 17; Adepto 11,90 contro 22,58; Illuminato 31,72 contro 33,88; righe del Briefing §22 diverse dal codice 7

## VOCE EW.06, LE LEVE DEL COSTO

**CHIUSA.** Dodici leve in ordine di risparmio per l'Iniziato al massimo, con
l'effetto per la persona, il risparmio al mese per piano e cosa toccano
(testi, regole del responso, decisioni del fondatore). **Nessuna applicata.**
Le tre piu' forti: meno gettate di rune al giorno (2,70 dollari, 48 per
cento), la lettura delle rune su Flash-Lite (2,64, 47 per cento, ma torna
indietro sull'ordine ER), la cache del contesto garantita (fino a 1,78, 31 per
cento, senza toccare niente di cio' che la persona vede).

DOMANDA: "Devo capire se devo intervenire..."
PROVA: docs/costi/le_leve_del_costo.md
MISURA: leve 12, applicate 0; risparmio dell'Iniziato al massimo con la leva piu' forte 2,70 dollari su 5,66 (48 per cento); con la sola leva che non tocca testi ne' decisioni fino a 1,78 (31 per cento)

## VOCE EW.07, IL MINUTO DEL LIVE

**APERTA IN ATTESA DI VERIFICA**. Una sessione LIVE vera col Realme, 4
domande, 7 minuti: telefono 7:04, contatore dell'app 6:58, Protoface 423
secondi fatturabili e 8 crediti. **Il minuto in conversazione costa 0,0213
dollari**: Protoface 0,0113, voce 0,0040, risposte 0,0034, ascolto 0,0025,
LiveKit 0 dentro i compresi. Il minuto senza conversazione 0,0125. Coi minuti
del codice il LIVE costa al massimo 2,13 dollari al mese all'Adepto e 5,32
all'Illuminato, **ma i minuti non scendono mai** (`"rimasti": 250` dopo tre
sessioni; padre EG voce 06). Il piano Protoface e' almeno il Launch (una
sessione del 30 settembre e' durata 14:45, oltre i 10 minuti dello Starter).

Cosa manca: **il piano Protoface** (Launch o Scale) e **il piano e i minuti di
LiveKit** della sessione, che stanno nei pannelli del fondatore; la lettura
della quota di Protoface con la chiave dell'app e' stata negata dal controllo
dei permessi di Code. I 725 crediti di Protoface del 28-30 settembre che non
vengono dal LIVE dell'app sono un video extra del fondatore (sua risposta del 2
ottobre).

DOMANDA: "Vorrei anche essere sicuro del costo di Protoface e del costo al minuto per la chat live attraverso Protoface."
PROVA: docs/costi/il_minuto_del_live.md
MISURA: costo al minuto misurato 0,0213 dollari contro 0,0205 stimati dall'ordine EK; minuti della sessione telefono 7:04, app 6:58, Protoface 7:03 (8 crediti); minuti del mese scalati dal server 0 su 3 sessioni
