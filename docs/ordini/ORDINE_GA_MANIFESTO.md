# MANIFESTO DELL'ORDINE GA, RESPONSI DIRETTI, STESE CONTATE PER STESA E CACCIA AI DIFETTI ANCHE SU IPHONE

Testo dell'ordine, parola per parola: `docs/ordini/ORDINE_GA_TESTO.md`. Rapporto:
`docs/ordini/RAPPORTO_ORDINE_GA.md`. Una voce CHIUSA porta sotto di se' DOMANDA,
PROVA e MISURA; una voce aperta dice che cosa aspetta e porta le sue prove; una
voce DA FARE non e' ancora cominciata o non e' ancora a prova. **In quest'ordine
le voci CHIUSE sono due e le altre quattordici sono APERTE IN ATTESA DI
VERIFICA**: la regola del 24 settembre 2026 dice che una voce prodotta e
agganciata ma non ancora guardata a video sul codice finale non e' chiusa, e
il fondatore ha detto che non vuole piu' una chiusura che non sia vera. Le
simulazioni sul Realme dell'ordine sono state fatte su una build di poco
anteriore alle ultime cure delle risposte (il commit `8ba00294`): vale per
quello che hanno visto, non per il testo dei responsi d'oggi.

VOCI_TOTALI: 16
VOCI_CHIUSE: 2
VOCI_APERTE: 14
VOCI_DA_FARE: 0

## VOCE GA.01

**APERTA IN ATTESA DI VERIFICA.** Il limite torna a contare le stese. La riga
dei piani conta le stese e non le carte, in app e sul server: stese al giorno
Viandante 1, Iniziato 3, Adepto 3, Illuminato 5; stesa a dieci carte solo per
Adepto e Illuminato, una al giorno (`functions/src/budget.ts`: `stese: [1, 3,
3, 5]`, `steseDaDieci: [0, 0, 1, 1]`). **I numeri dell'Adepto e
dell'Illuminato non sono 6 e 10 del testo dell'ordine**: il fondatore aveva
scritto "deve rientrare nel 30% dopo provvigioni 15% store e 22% iva,
altrimenti Code le puo' modificare", e col caso peggiore misurato 6 e 10 non
rientravano (vedi GA.02). Le stese per giorno si spendono con il budget del
server, non con le carte. Sul Realme (gruppo E) le card dei piani dicono 1,
3, 3 e 5 e la stesa a dieci e' detta solo per Adepto e Illuminato.

DOMANDA: "nei tarocchi, per quanto riguarda i limiti per free e gli
abbonamenti, bisogna tornare a conteggio per stesa e non per numero di carte
scelte ed estratte"
PROVA: `test/il_gating_della_stesa_test.dart`
MISURA: unita' che si spendono per una stesa a tre carte, da 3 carte a 1
stesa; stese al giorno dell'Adepto da 4 (mensile) e 3 (annuale) a 3 e 3;
card dei piani lette sul Realme: 1, 3, 3, 5 su 4

ASPETTA: la pubblicazione delle funzioni del server per la Croce Celtica (il comando lo lancia il fondatore) e una stesa vera sul Realme che consumi per stesa contro il server nuovo.

## VOCE GA.02

**APERTA IN ATTESA DI VERIFICA.** I numeri dentro il 30 per cento. Il caso
peggiore di ogni piano, mensile e annuale, rifatto con la stesa piu' cara in
Lunga e con le carte singole prese dal corpus (decisione del fondatore del 20
ottobre: il modello scrive solo il responso principale): Adepto mensile al
29,4 per cento, tutti i cicli sotto il tetto del 30 per cento, con le stese
al giorno di GA.01. Il tetto e' calcolato dopo provvigione dello store (15) e
IVA (22), come ha confermato il fondatore. La misura sta nello strumento
`tool/i_limiti_degli_annuali.py` e in `docs/costi/i_limiti_degli_annuali.txt`.

DOMANDA: "volendo mantenere il costo massimo al 30% (dopo provvigioni store
15% e iva 22%), dovremo rifare la simulazione di spesa massima per utente"
PROVA: `test/i_limiti_degli_annuali_test.dart`
MISURA: caso peggiore dell'Adepto mensile, con i numeri del testo (6 stese)
oltre il 39 per cento, con i numeri curati (3 stese) al 29,4 per cento; tutti
i cicli sotto il tetto

ASPETTA: le funzioni del server pubblicate (budget.ts e' nel codice, non in produzione) e un mese di consumi veri per confermare il caso peggiore con le chiamate reali.

## VOCE GA.03

**APERTA IN ATTESA DI VERIFICA.** La forma: paragrafi da 40 a 50 parole e il
riquadro "Cosa fare adesso". Le quattro arti (Oroscopo, Tarocchi, Oracolo
degli Angeli, Rune) compongono un `ResponsoInterpretato` (titolo, risposta,
cosa fare, approfondimento, rito, da dove viene) e lo mostrano col componente
comune `IlResponsoInterpretato`. Vista a video sul Realme a una build di poco
anteriore alle ultime cure (gruppi A, B e C), non sul codice finale.

DOMANDA: "tutte le risposte composte da paragrafi ognuno con tra 40 a 50 parole
ognuno. Per le risposte brevi 2 paragrafi di cui il secondo messo in evidenza in un
riquadro e questo riquadro deve intitolarsi "cosa fare adesso""
PROVA: `test/ogni_responso_parte_dal_titolo_test.dart`
MISURA: paragrafi fuori dalle 40-50 parole, da una media di circa 32 parole a
0 fuori misura su 4.644 paragrafi dell'Oroscopo, 21.060 delle carte nella
posizione e 22.464 composizioni dei Tarocchi

ASPETTA: la guardia di un responso intero sul telefono, sul codice finale, e la Lunga (dall'Iniziato) che il Viandante di collaudo non apre.

## VOCE GA.04

**APERTA IN ATTESA DI VERIFICA.** Il rito propiziatorio, un titolo per ogni
arte, con fonti reali: inni orfici, mantra dei Navagraha, gesti del Tong Shu,
salmi della Bibbia di Martini (Passigli 1842), galdr, contemplazione dei
tarocchi, generati da `tool/genera_i_riti.py`. Le virgole prima di "e" dentro i
versetti di Martini restano per citazione alla lettera, con eccezione
insegnata alle guardie: va confermato dal fondatore.

DOMANDA: "Per le rune "il galdr propiziatorio", per l'arcano "il versetto o
salmo propiziatorio" scegli tu, per i tarocchi scegli tu, scegli tu. Anzi scegli
tu su tutto"
PROVA: `test/i_riti_dell_oroscopo_seguono_il_periodo_test.dart`
MISURA: riti scritti con la loro fonte, da 0 a 476 (416 solo per
l'Oroscopo, quattro periodi per reggente e dominio); riti ripetuti fra
responsi del campione, da 4 coppie (7=15, 37=45, 39=47) a 0 nella prova

ASPETTA: il rito della risposta Lunga guardato sul telefono (e' dell'Iniziato) e la conferma del fondatore sulle virgole dei versetti di Martini.

## VOCE GA.05

**APERTA IN ATTESA DI VERIFICA.** Le singole carte, le singole rune e la
profondita'. La profondita' Lunga vale solo per il responso principale e dal
piano dell'Iniziato; le carte singole e le schede delle pietre hanno il loro
titolo e la loro forma breve. Matrice dei piani a 66 righe dopo la tolta di
"Respiriamo insieme". **Le carte singole e le schede restano il punto debole
delle risposte**: vedi GA.06.

DOMANDA: "Profondità lunga solo dal tier 1 e solo per il responso principale e
non per le singole carte"
PROVA: `test/le_rune_hanno_la_forma_nuova_test.dart`
MISURA: schede delle pietre con il Cosa fare legato alla domanda, 14 su 35
all'ultima lettura cieca indipendente (17 su 35 nella lettura prima e 0
misurate al primo giro)

ASPETTA: un piano Iniziato o superiore per provare la Lunga sul telefono, e la cura delle schede delle pietre (testi scritti per pietra e tipo di domanda).

## VOCE GA.06

**APERTA IN ATTESA DI VERIFICA.** La risposta diretta e coerente, regola
permanente: scritta in CLAUDE.md con le parole del fondatore. Lettori ciechi
(agenti di Code, mai Gemini), prima e dopo le cure, **tre sì insieme** (la
prima frase risponde, il Cosa fare dice un'azione concreta, il responso e'
coerente coi simboli e con la domanda) e scambio dei simboli. Prima delle
cure: Oroscopo 40 su 48, Tarocchi 3 su 40, Rune 3 su 40, Oracolo 6 su 40.
**Ultima lettura indipendente, 12 responsi per arte**: Tarocchi 11 su 12,
Oracolo 10 su 12, Oroscopo 9 su 12 (campione vario: tre tradizioni per
quattro periodi, quattro domini), Rune 6 su 12. Scambio dei simboli
riconosciuto: 48 su 48, 40 su 40, 40 su 40 e 40 su 40. **Le Rune sono
l'arte piu' debole** e il difetto resta aperto con il suo numero. Esiti in
`docs/collaudo/GA/lettori_ciechi/esiti/`.

DOMANDA: "IMPORTANTE: risposte dirette immediatamente, l'utente deve avere
subito e sempre risposte senza fronzoli o criptiche o includenti o sibilline."
PROVA: `docs/collaudo/GA/lettori_ciechi/esiti/giro10_esito_rune_12.md`
MISURA: tre sì insieme su 12, dal primo lettore all'ultimo: Tarocchi da 3 su 40 a 11 su 12; Oracolo da 6 su 40 a 10 su 12; Oroscopo da 40 su 48 a 9 su 12 sul campione vario (prima: 3 su 12); Rune da 3 su 40 a 6 su 12

ASPETTA: una cura delle Rune con testi scritti per pietra e tipo di domanda (le schede dei singoli sassi sono generiche in 21 su 35) e una nuova lettura indipendente di tutte e quattro le arti sul codice finale, dopo la decisione del fondatore su quante altre cure.

## VOCE GA.07

**CHIUSA.** I testi riscritti, mai troncati. I corpora dell'Oroscopo (dodici
file, 1.548 voci), delle Rune (7.380 voci), dei Tarocchi (2.340 titoli e
1.404 "cosa fare" nella posizione, 21.060 paragrafi) e dell'Oracolo (648
consigli, ora 3.240 testi) sono riscritti nella forma di GA.03 con i loro
strumenti (`tool/le_parole_dei_responsi.py`,
`tool/controlla_il_corpus_delle_rune.py`, `tool/genera_carte_nella_posizione.py`,
`tool/il_corpus_dell_oracolo.py`) a difetti 0, rigenerati alla fonte e mai
troncati; nessuna chiamata a pagamento. I testi che scrive il modello
(Gemini) restano APERTI per la regola delle spese: la voce chiude sulla parte
che si e' potuta provare senza spesa.

DOMANDA: "e di conseguenza adattare il testo"
PROVA: `test/le_lunghezze_dei_responsi_test.dart`
MISURA: voci dei corpora con almeno un difetto misurabile, da 1.284 su 1.548
nell'Oroscopo e da 21.060 paragrafi fuori misura a 0 difetti su tutti i corpora; paragrafi troncati 0

## VOCE GA.08

**APERTA IN ATTESA DI VERIFICA.** L'Oracolo degli Angeli si apre senza carte in
vista: all'apertura nessuna carta e' visibile in scena; il filmato non porta
carte nei fotogrammi misurati (`docs/collaudo/GA/ga08_le_carte_nel_filmato_
misura.txt`).

DOMANDA: "L'oracolo degli angeli non mostra all'inizio, all'apertura, nessuna
Carta prima che l'utente le scelga"
PROVA: `test/l_oracolo_si_apre_senza_carte_test.dart`
MISURA: carte visibili all'apertura, da 3 a 0 (fotogrammi misurati 0, 24, 40, 52, 64, 74, 80, 84, 88, 96, 110 e 130 del filmato)

ASPETTA: l'apertura dell'Oracolo guardata sul telefono con la build finale (la simulazione sul Realme l'ha vista aprirsi con Medora e la scala di luce, su una build anteriore).

## VOCE GA.09

**APERTA IN ATTESA DI VERIFICA.** La simulazione del bambino, regola
permanente (scritta in CLAUDE.md). Fatta sul Realme in cinque gruppi, **33
funzionalita' su 33**, con cinque rapporti in `docs/collaudo/GA/simulazioni/`:
opzioni provate 63 + 55 + 60 + 59 + 49 = 286; non provate 42 + 38 + 38 + 28 +
17 = 163 (piano diverso dal Viandante, permessi di sistema, invii a terzi,
scritture sul server); difetti trovati 13 + 17 + 17 + 30 + 35 = 112, nessuno di
gravita' 3 curato lasciato aperto (le gravita' 3 trovate: l'Oracolo che
dice "comincia, senza aspettare il permesso" a una domanda di salute, curato;
la conversazione che sembra non rileggersi, verificata e ridotta a un difetto
di visibilita'). L'elenco delle opzioni e' in `docs/collaudo/GA/le_opzioni.md`.
Il rapporto dell'ordine porta i difetti aperti coi numeri.

DOMANDA: "Code nei panni dell'utente deve provare tutte le opzioni di ogni
funzionalità"
PROVA: `docs/collaudo/GA/le_opzioni.md`
MISURA: funzionalita' simulate, da 0 a 33 su 33; opzioni provate, da 0 a 286 su 449 (64 per cento)

ASPETTA: le opzioni a un piano diverso dal Viandante (cambiare piano scrive sul server di produzione: lo fa il fondatore o un account di collaudo per piano) e una nuova passata sul codice finale delle cure di GA.06 e GA.10.

## VOCE GA.10

**APERTA IN ATTESA DI VERIFICA.** La visibilita' di ogni testo. 221 testi sotto
soglia sulle catture del Realme: 36 sotto 4,5 anche sul colore di fondo piu'
frequente (curati 32, i 4 pulsanti spenti sono esenti), 185 sotto soglia solo
nel punto piu' chiaro dello sfondo (13 toccati dalla cura comune dell'ombra,
172 lasciati come segnalazione). Cure: pulsanti d'oro con testo scuro
(1,86 diventa 9), dialogo "Ricominciare da zero?" con due aspetti distinguibili,
Meditazione sul fiore con velo (1,6-2,9 diventa 6,4), ombra a tre strati nel
token di testo sulle scene. **I valori "dopo" sono calcolati, non misurati a
video.** Guardia nuova sulle coppie testo/fondo (92 coppie, 36 pulsanti d'oro).

DOMANDA: "a volte in alcune funzionalità c'è testo chiaro su sfondo chiaro e
potrebbe valutare il cambio di colore o di usare un ombreggiatura del testo o
una contorno del testo o altro per aumentare la visibilità"
PROVA: `docs/collaudo/GA/ga10_cure_del_contrasto.md`
MISURA: testi sotto soglia sul fondo piu' frequente, da 36 a 4 (pulsanti spenti, esenti); contrasto dei pulsanti d'oro da 1,86 a circa 9 su 1; Meditazione da 1,58 a 6,40

ASPETTA: una cattura sul Realme con la build finale per ogni testo curato (il "dopo" e' calcolato) e la decisione del fondatore sui 172 testi sotto soglia solo nel punto piu' chiaro del cielo.

## VOCE GA.11

**APERTA IN ATTESA DI VERIFICA.** La caccia ai difetti e alle regressioni dei
tester. Ultima build presa: **2314**, dichiarata dal fondatore come l'ultima su
Android e su iPhone (la precedente su iPhone era la 2307: cattura in
`docs/collaudo/GA/ga11_testflight_2314.jpg`). Sette difetti curati con cinque
guardie nuove (`docs/collaudo/GA/ga11_regola_a.txt`): la home e il tutorial
con altezze negative, la scena tardiva, il conto dei momenti senza rete, la
riga del premio monca. **Il Viaggio dello Sciamano**: il Gufo si volta davvero
(registrazione scrcpy, circa 2,2 secondi, nessuno scatto alla giuntura); i
sette animali di terra (Lince, Volpe, Orso, Lupo, Cavallo, Cervo, Tartaruga)
hanno il nuovo "si volta" dal video dell'Architetto sul CDN (manifesto v3),
ma **non sono provati a video** perche' servirebbe azzerare il Diario in
Demo: analizzati i sette file locali, tutti si voltano senza scatti.

DOMANDA: "nella ultima build ci sono numerosi difetti e regressioni segnalate
dai tester e Code deve trovarle e curarle"
PROVA: `docs/collaudo/GA/ga11_regola_a.txt`
MISURA: difetti curati con guardia, da 0 a 7; guardie nuove 5 (vista rossa sul difetto vero); sette animali di terra col "si volta" nuovo sul CDN, 7 su 7 analizzati e 0 su 7 provati a video

ASPETTA: i sette animali di terra visti a video, che tocca al fondatore su TestFlight (o a un account di collaudo con quegli animali riconosciuti), e il confronto fra le build 2307 e 2314 su iPhone.

## VOCE GA.12

**CHIUSA.** Ogni cura verificata anche su iPhone, **con la portata ridotta dal
fondatore il 21 ottobre 2026** ("GA.12 si chiude qui: il simulatore di iPhone
compila e apre l'app, basta cosi'. Niente Firebase Test Lab e niente catture
iPhone per ogni difetto"). Il workflow `.github/workflows/iphone-simulatore.yml`
compila l'app per il simulatore su una macchina macOS Intel di GitHub (Xcode
26.3, dopo tre tentativi caduti per Xcode 16.4, per il framework `Pods_Runner`
non costruito e per l'architettura), la installa su un iPhone 17 Pro con iOS
26.2 e la apre; la cattura a 90 secondi mostra "Il Risveglio". Le schermate da
guardare a mano su iPhone con TestFlight sono nell'elenco numerato del
rapporto.

DOMANDA: "GA.12 si chiude qui: il simulatore di iPhone compila e apre l'app, basta così."
PROVA: `docs/collaudo/GA/ios/avvio_07_dopo_90s.png`
MISURA: giri del simulatore che compilano e aprono l'app, da 0 su 3 a 1 su 1; catture dell'avvio 7 (a 3, 8, 15, 25, 40, 60 e 90 secondi), schermata "Il Risveglio" a 40, 60 e 90 secondi

## VOCE GA.13

**APERTA IN ATTESA DI VERIFICA.** La Luna si riconosce a colpo d'occhio. Disco
alla scala nuova nel cielo reale (campo di partenza 70 gradi, un settimo dello
schermo, mai sotto 40 punti), alone che cresce col disco, pannello delle fonti
aggiornato. Sul Realme il disco al campo di partenza misura circa 160 pixel su
1080 (14,8 per cento della larghezza, 53 punti su 360), al limite basso dei 55-60
punti dell'ordine; con la guida e la didascalia "La Luna adesso non c'e'"
accanto al disco.

DOMANDA: "la trovo [...] piccola e difficilmente individuabile"
PROVA: `test/la_luna_si_riconosce_a_colpo_d_occhio_test.dart`
MISURA: diametro della Luna al campo di partenza, da circa 18 punti a circa 53 punti (160 pixel su 1080)

ASPETTA: una misura precisa del diametro sul telefono (il collaudatore l'ha presa a occhio sulla cattura) e il pizzico per ingrandire, che adb non sa fare e serve un dito vero.

## VOCE GA.14

**APERTA IN ATTESA DI VERIFICA.** L'Oroscopo si apre subito. La storia delle
fasce e il conto vedico si preparano in un isolato, fuori dal tocco. **Sul
Realme l'Oroscopo mostra circa 9 secondi di filmato della ruota prima del
contenuto (11 prima di poterlo toccare)**: la voce chiede che il tocco
risponda subito e non che il filmato sia assente, ma il blocco del tocco non e'
stato misurato e la durata del filmato e' una decisione del fondatore.

DOMANDA: "l'apertura della funzionalità Oroscopo impiega qualche secondo ad
aprirsi, non è immediata come le altre"
PROVA: `test/l_oroscopo_si_apre_subito_test.dart`
MISURA: tempo del primo fotogramma dopo il tocco e fotogrammi persi: da 317 millisecondi misurati dall'ordine EO a un numero non ancora preso dopo la cura; filmato visibile prima del contenuto, circa 9 secondi

ASPETTA: la misura del tocco sul Realme (secondi al primo fotogramma, fotogrammi persi) e la decisione del fondatore sulla durata del filmato della ruota.

## VOCE GA.15

**APERTA IN ATTESA DI VERIFICA.** L'ora di nascita non si chiede a chi l'ha data.
La carta senza ora non resta e non torna dal disco; gli inviti leggono la
fonte giusta. Sul Realme l'account di collaudo non ha l'ora di nascita, quindi
la cura non e' stata vista nel caso in cui conta.

DOMANDA: "attualmente continua a chiedere l'ora di nascita anche se già impostata"
PROVA: `test/l_ora_data_non_si_chiede_piu_test.dart`
MISURA: punti dell'Oroscopo che invitano a dare l'ora quando l'ora c'e', da 8 a 0

ASPETTA: un account con l'ora di nascita data, sul telefono, e l'invito verificato a video.

## VOCE GA.16

**APERTA IN ATTESA DI VERIFICA.** La consegna: manifesto, guardia del
manifesto, rapporto, STATO_VIVO, registro delle guardie (874). Il verde di
GitHub sul commit consegnato, la pubblicazione delle funzioni del server per la
Croce Celtica e la build di collaudo (Android su App Distribution, iPhone su
TestFlight con Codemagic) sono le condizioni del fondatore del 20 ottobre
2026: la build parte solo dopo il verde e dopo le funzioni.

DOMANDA: "a fine lavoro build di collaudo per i tester, Android su App Distribution e iPhone su TestFlight tramite Codemagic, ma solo dopo il verde di GitHub, le catture iPhone di GA.12 e la pubblicazione delle funzioni"
PROVA: `docs/ordini/RAPPORTO_ORDINE_GA.md`
MISURA: voci chiuse 2 su 16, aperte 14, da fare 0; guardie nel registro da 842 a 874

ASPETTA: il verde di GitHub sul commit consegnato, il comando delle funzioni lanciato dal fondatore e la build di collaudo lanciata dopo.
