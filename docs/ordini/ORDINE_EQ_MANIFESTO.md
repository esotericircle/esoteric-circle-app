# ORDINE EQ, LE CHAT CHE RISPONDONO E LA STESA DI TAROCCHI CHE INTERPRETA

**Sigla:** EQ, verificata sul ramo il 27 settembre 2026: in `docs/collaudo`
l'ultima cartella era EP, nessun `ORDINE_EQ_*`, nessuna `docs/collaudo/EQ`.
**Data dell'ordine:** 27 settembre 2026.
**Ramo:** `claude/esoteric-circle-master-order-e798aj`.

**Le consegne del fondatore, a ordine aperto**: alla domanda su come
procedere, *"Tutto, a parti"*: prima le chat (EQ.01-03), poi i tarocchi
(EQ.04-06), poi i difetti delle catture (EQ.07-12), con un commit per voce;
e *"Lascia stare i riferimenti a iPhone 17, non è collegato e non posso
usarlo ancora. Solo gli screenshot sono corretti e appartengono a iPhone
17"*: le voci grafiche si provano alla misura dell'iPhone 17 Pro, 402 per
874 punti con la piattaforma iOS nelle prove, e si guardano sul Realme.
**Questo ordine non consegna niente**: le build le ordina il fondatore.

VOCI_TOTALI: 12
VOCI_CHIUSE: 0
VOCI_APERTE: 10
VOCI_DA_FARE: 2

Le prove stanno in `docs/collaudo/EQ/`; quelle viste sul telefono di prova
(Realme 767f596c, 360 per 800 punti) in `docs/collaudo/EQ/realme/`. Una
voce prodotta ma non ancora guardata sul Realme e' APERTA IN ATTESA DI
VERIFICA: le catture si fanno con una build sola, a voci finite.

---

## PARTE 1, LA CHAT

## VOCE EQ.01, LA RIGA D'ORO NON SI RIPETE

Nelle catture la stessa riga d'oro, *"Scrivi su un foglio di carta bianca
tre cose che vorresti realizzare"*, chiudeva la presentazione, la risposta
sui tre desideri, *"Ok, gli ho scritto adesso."* nel LIVE e *"Ok, le ho
scritte e adesso cosa faccio?"*: quattro righe, tre ripetute, una sotto la
presentazione, due dopo un passo gia' fatto.

- **L'esempio esce dall'istruzione** (`ConsiglioFinale.istruzione`): il
  modello lo ricopiava, e nel collaudo "prima" Medora nel LIVE ha scritto
  proprio *"Stasera scrivi su un foglio le tre cose che vuoi dirgli"*.
  L'eccezione si allarga a chi saluta o chiede che cosa fa il Maestro o come
  puo' aiutarlo; e un passo appena fatto non si chiede di rifare.
- **A valle, `IlPassoDaNonDare`** (lib/core/chat): la riga si toglie sotto
  una presentazione, quando e' uguale o simile a una gia' data (la misura di
  casa, 0,32, piu' due parole piene in comune, tarata su 1.202 coppie vere
  dei collaudi EJ, EK ed EN) e quando chiede di rifare il verbo del passo
  appena detto fatto (*"le ho scritte"* e *"Scrivi..."*). Vale anche nel LIVE.
- **La bolla** non mostra la riga, ne' l'invito a tornare, sotto la risposta
  a una presentazione, anche nelle conversazioni gia' salvate.
- **Il LIVE, mentre il testo arriva**, si ferma alla stella: una riga che le
  reti tolgono non passa a video nemmeno per un istante.
- **Un difetto trovato dal collaudo e curato** (padre: questa voce, prima
  stesura): nel LIVE Flash-Lite ha risposto con la sola riga d'oro della
  risposta prima; la regola la lasciava per non consegnare una bolla vuota.
  Adesso una risposta fatta della sola riga da togliere si chiede di nuovo,
  una volta, e se torna uguale arriva la lettura di ripiego, mai la riga.

**APERTA IN ATTESA DI VERIFICA**: la cattura dal Realme della conversazione
delle catture rifatta.
DOMANDA: "C'è un grosso problema con le chat e sono incazzato nero!"; "Unisci tutto all'ordine prossimo credo EQ"
PROVA: docs/collaudo/EQ/eq01_righe_d_oro.txt
MISURA: a schermo, due giri con dati diversi per ciascun Maestro: righe d'oro uguali o simili a una gia' data da 3 su 30 a 0 su 22 (catture: 3 su 4); presentazioni con la riga d'oro da 6 su 12 a 0 su 12 (catture: 1); righe che chiedono di rifare il passo appena fatto da 2 su 12 a 0 su 12; quattro giri di fila puliti sull'istruzione definitiva

## VOCE EQ.02, IL MAESTRO RISPONDE CON LA SUA ARTE

La regola del cerchio dell'ordine EN, *"la tua prima frase lo dice e lo
chiama per nome"*, e' sostituita: il Maestro risponde sempre nel merito con
la sua arte, a ogni parte della domanda; l'altro Maestro si nomina solo in
fondo, in una frase, come consiglio in piu'. Restano le parole di firma, le
arti degli altri due che non si usano e chi di dovere.

- **L'istruzione**: il blocco del cerchio (`VoceDelMaestro.ilCerchio`), le
  due righe del dominio (`MaestroPersona`), la risposta nel merito con le
  domande a piu' parti e col si' o il no in prima frase
  (`LaRispostaNelMerito`), e il controllo prima di scrivere in fondo
  all'istruzione.
- **A valle, `IlRimandoInFondo`**: la prima frase che nomina un altro Maestro
  si sposta in fondo al corpo, prima della riga d'oro. Nel collaudo, con la
  regola gia' scritta, Medora ha aperto ancora con *"Non posso indicarti un
  rito... perché i riti sono l'arte di Calìgo"*.
- **L'attribuzione cieca e' rifatta**: 96,7, 98,3 e 95,0 per cento, media
  96,7 (174 su 180), contro l'89,1 dell'ordine EO.

**APERTA IN ATTESA DI VERIFICA**, e non solo per la cattura dal Realme: le
parti della domanda senza risposta scendono da 15 a 8 su 28, non a 0.
Calìgo resta il piu' debole: alla domanda delle catture risponde a volte in
generale, per sentenze.
DOMANDA: domanda girata al fondatore: "Chat: quando la domanda tocca l'arte di un altro Maestro (es. l'amore chiesto a Calìgo), come deve rispondere?", risposta: "Prima la sua arte" ("Risponde sempre nel merito con la sua arte (Calìgo: un rito per l'amore). L'altro Maestro lo nomina solo in fondo, come consiglio in più. Cambia la regola dell'ordine EN.")
PROVA: docs/collaudo/EQ/eq02_domande_di_confine.txt
MISURA: su diciotto domande di confine per giro (sei per Maestro, fra cui quella delle catture), prime frasi che rimandano a un altro Maestro da 9 a 0; parti della domanda senza risposta, stesso giudice, da 15 a 8 su 28; attribuzione cieca da 89,1 a 96,7 per cento

## VOCE EQ.03, LE RISPOSTE NEL MERITO, ANCHE NEL LIVE

**DA FARE.** Il collaudo e' scritto (`tool/collaudo_eq03.dart`, dodici
domande di seguito per Maestro, nel LIVE con Flash-Lite e con Flash e in
chat, due giri per modo).

## PARTE 2, LA STESA DI TAROCCHI

## VOCE EQ.04, LA STESA INTERPRETA DAVVERO

**La via scelta.** Una chiamata a Flash per la lettura intera
(`lib/core/tarot/la_lettura_dal_modello.dart`), col ragionamento spento e la
risposta in sei campi: la risposta, le tre carte, il legame, il consiglio.
Riceve la domanda, l'argomento, la carta chiave della schermata e per ogni
carta il significato tradizionale. Le guardie guardano a valle: tetti, il nome
di ogni carta, niente cifre, il confine del responso, nessun genere dato a chi
legge contro la sua forma; il trattino lungo e la virgola con la "e" si
correggono. Fino a tre richieste in dieci secondi, col motivo dello scarto
scritto; se il solo difetto e' il genere, una richiesta breve riscrive le
frasi colpevoli nominando la parola; finiti i tentativi, quelle frasi si
tolgono, mai dalla risposta. **Senza modello** la lettura di casa ha sotto
ogni carta il testo della sua posizione, uno dei 468 scritti una volta sola
(`docs/corpus/tarocchi_nella_posizione.md`). **Nessuna cache**: 58 milioni di
chiavi fra stese ordinate, versi e argomenti, la quota servita dalla cache e'
0. La schermata aspetta la lettura dentro la scena di Medora e ne scrive il
tempo nel registro (`STESA TEMPI`).

**Misure, coi giudici tarati su undici casi noti**
(`docs/collaudo/EQ/tarocchi/taratura_dei_giudici.txt`): prima, la lettura di
casa, risposte dirette 1 su 20 e carte lette sulla domanda 0 su 60; dopo, due
giri con dati diversi dello stesso codice, 19 e 17 su 20 e 53 e 43 su 60;
letture uguali su cento 0 in tutti e tre. Costo medio di una stesa 0,00177 e
0,00191 dollari; tempo dal PC mediano 3,7 secondi in tutti e due i giri.

**APERTA IN ATTESA DI VERIFICA**: le misure non arrivano a 20 su 20 e 60 su
60, e manca l'attesa sul Realme dal tocco su "Leggi le Carte" al testo.
DOMANDA: "Il fondatore si lamenta che facendo una stesa tarocchi con domanda generica, ma anche con domanda specifica e personale LE RISPOSTE SONO TROPPO CRIPTICHE, SONO QUASI SENZA SENSO. SCRIVE QUALCOSA ,MA NON DICE NULLA."; "Ma una interpretazione la fa veramente o sono testi buttati lì tanto per accontentare?"
PROVA: docs/collaudo/EQ/tarocchi/dopo_giro_1/letture.md
MISURA: risposte dirette nelle prime due frasi da 1 su 20 a 19 e 17 su 20 (due giri); carte lette nella posizione e sulla domanda da 0 su 60 a 53 e 43 su 60; errori di concordanza, contati a mano, da 3 su 20 letture ("c'e' stata Quattro di Coppe") a 0 su 40; letture uguali su cento 0 prima e dopo

## VOCE EQ.05, LA SCRITTA SOTTO LA CARTA CHIAVE

La carta chiave era ingrandita col solo disegno attorno al suo centro:
debordava sotto di un ventesimo della sua altezza e copriva "PRESENTE",
mentre le vicine si ritiravano di sette centesimi. Adesso le tre carte
crescono e si ritirano dal loro bordo basso, e ogni scritta sta a sedici
punti dalla sua carta; lo spazio delle parole "Carta Chiave" si misura sulla
larghezza della carta, che ora sale tutta verso l'alto.

**APERTA IN ATTESA DI VERIFICA**: la cattura dal Realme.
DOMANDA: "Inoltre, esteticamente, la parola "passato, presente o passato" sotto alla carta chiave ingrandita e attaccata alla carta grande."; "Ti segnalo che gli screenshot sono di un iPhone 17 pro."
PROVA: test/la_stesa_si_legge_intera_test.dart
MISURA: distanza fra la carta chiave e la sua scritta da circa -6 punti (la carta la copriva) a 16,0, uguale alle altre due (16,0 e 16,0), a 402 punti con iOS e a 360; scritte allineate, scarto 0,0 punti

## VOCE EQ.06, IL RIEPILOGO SOTTO LE CARTE E LA CARD DA CONDIVIDERE

- **Nella card da condividere** la colonna delle posizioni era di 74 punti
  fissi e "PRESENTE" andava a capo in "PRESENT" ed "E". Adesso e' larga
  quanto la posizione piu' lunga misurata col carattere vero, piu' otto
  punti, e nessuna va a capo.
- **Nel riepilogo sotto le carte** il segno del verso stava in un `Wrap`
  unico e andava dove c'era posto. Adesso posizione e nome stanno sulla prima
  riga, il segno e la sintesi sulla seconda: il segno comincia la seconda
  riga in tutte e tre.

**APERTA IN ATTESA DI VERIFICA**: la cattura dal Realme.
DOMANDA: "Il riepilogo delle estrazioni subito sotto le 3 carte ci sono difetti come la parola "presente" con la "e" finale a capo."; "Ti segnalo che gli screenshot sono di un iPhone 17 pro."
PROVA: test/la_stesa_si_legge_intera_test.dart
MISURA: parole spezzate nella card da condividere da 1 a 0 ("PRESENTE" larga 79,4 nella colonna di 88,0); righe del riepilogo col segno del verso fuori posto da 1 a 0 (bordo sinistro dei segni 24,0 e 24,0, a 402 con iOS e a 360)

## PARTE 3, I DIFETTI DELLE CATTURE

## VOCE EQ.07, I CONTATORI DELLA CHAT

Un fatto e' misurato. Sul Realme di prova, con la stessa build 2284 delle
catture, il contatore delle domande scende: 50, poi 49 dopo una domanda in
chat, poi 48 dopo la seconda restando nella chat (`docs/collaudo/EQ/realme/`).
Le quattro risposte delle catture hanno la forma del LIVE, due frasi brevi, e
i turni del LIVE non consumano domande per la decisione dell'ordine EG voce
06: e' la domanda per il fondatore, nel rapporto.

**La bolla dice di che cosa e' il residuo.** "Chiedi anche agli altri" conta
i confronti fra i Maestri, un tetto diverso dalle domande, e diceva soltanto
*"Oggi te ne restano 20 su 20"*: adesso *"Oggi hai 20 confronti fra i
Maestri"*, con la forma di ogni altro residuo dell'app
(`QuestionAllowance.residuoDiCosa`) e le parole del suo budget, le stesse in
"Chiedi ai Maestri".

**APERTA IN ATTESA DI VERIFICA**: la cattura dal Realme.
DOMANDA: "Unisci tutto all'ordine prossimo credo EQ", dopo l'elenco dell'Architetto che nominava i contatori.
PROVA: test/il_confronto_ha_il_suo_tetto_test.dart
MISURA: righe dei residui che non dicono di che cosa, da 1 a 0; contatori che scendono quando si usano, 2 su 2 in chat (50, 49, 48 sul Realme); i turni del LIVE non contano, per decisione dell'ordine EG

## VOCE EQ.08, I MESSAGGI SOTTO LA CASELLA E SOTTO IL MENU'

La conversazione si ritaglia sopra il bordo alto della casella di
scrittura, seguendo la barra del Cerchio quando scende e sale
(`_TaglioSopraLaCasella` nella chat).

Le catture "prima", sul Realme con la build 2284:
`realme/eq08_build_2284_prima_testo_sotto_la_casella_e_la_barra.png` (con la
barra aperta, *"necessità della struttura. Non agire d'impulso"* si legge
sotto la casella e dietro "ESPLORA") e
`realme/eq08_build_2284_prima_la_bolla_finisce_dietro_la_barra.png` (la fine
della bolla, "Vai più a fondo" e "Chiedi anche agli altri", resta dietro la
casella e non risale).

**APERTA IN ATTESA DI VERIFICA**: le catture dal Realme con la chat piena,
a riposo e durante lo scorrimento.
DOMANDA: "Unisci tutto all'ordine prossimo credo EQ", dopo l'elenco dell'Architetto che nominava il testo sotto la casella.
PROVA: test/i_messaggi_stanno_fra_i_contatori_e_la_casella_test.dart
MISURA: punti di conversazione visibili sotto il bordo alto della casella, a 360 e 402 punti, da 74 a 0

## VOCE EQ.09, IL FONDO DEI CONTATORI

Sul Realme con la 2284 il ritratto di Caligo in cima alla conversazione
passava dietro le due righe dei contatori mentre si scorreva
(`realme/eq09_build_2284_prima_il_ritratto_dietro_i_contatori.png`): il
ritaglio della voce EQ.08 fermava il fondo della conversazione e lasciava
libera la cima. **Due cure**: la conversazione si ritaglia anche al suo bordo
alto, e la fascia dei contatori ha la tinta della testata, da un punto solo
(`_ChatAppBar.fondo`), con quattro punti sotto le righe.

**APERTA IN ATTESA DI VERIFICA**: la cattura dal Realme durante lo
scorrimento.
DOMANDA: "Unisci tutto all'ordine prossimo credo EQ", dopo l'elenco dell'Architetto che nominava i messaggi dietro i contatori.
PROVA: docs/collaudo/EQ/eq09_la_fascia_e_la_cima.txt
MISURA: punti in cui la conversazione puo' dipingere dietro i contatori, a 360 e 402 punti, da 674 a 0; fascia dei contatori con la tinta della testata, da 0 a 1

## VOCE EQ.10, LA PILLOLA BIANCA DELLA DETTATURA

**DA FARE.** L'indagine e' fatta e non ha ancora trovato chi la disegna
(`docs/collaudo/EQ/eq10_indagine.txt`). Sul Realme con la 2284: in ascolto
nessuna pillola, anche in sette secondi di silenzio fotografati ogni 0,4
secondi (0 pixel bianchi su 128.000 nella sua zona, in dodici fotogrammi, e
nessuna finestra di sistema oltre alle barre); la lente del testo e la barra
di selezione di Flutter hanno un'altra forma e sono scure. Nella cattura del
fondatore la freccia d'invio e' spenta, quindi il campo era vuoto: la
pillola non viene dal testo dettato. Si fa comparire solo con la voce vera,
che da qui non si puo' produrre. Niente e' stato cambiato alla cieca.

## VOCE EQ.11, IL TITOLO DELLA STESA SU UNA RIGA

"Stesa di Tarocchi" usa il titolo che non si rompe con una riga sola: la
misura scende quanto serve, entro il minimo del titolo.

**APERTA IN ATTESA DI VERIFICA**: la cattura dal Realme.
DOMANDA: "Unisci tutto all'ordine prossimo credo EQ"; "Ti segnalo che gli screenshot sono di un iPhone 17 pro."
PROVA: test/la_stesa_si_legge_intera_test.dart
MISURA: righe del titolo da 2 a 1, a 402 punti con iOS e a 360

## VOCE EQ.12, "IL CONSIGLIO DI MEDORA" INTERO

Era un `Text` con `maxLines: 1` e il ritorno a capo acceso: "IL CONSIGLIO
DI" sulla prima riga, "MEDORA" sulla seconda buttata via. Adesso usa il
titolo che non si rompe, a una riga e allineato a sinistra. **La guardia che
lo sorvegliava era cieca**: misurava a 328 punti, piu' del riquadro vero, e
restava verde; riscritta sul paragrafo dipinto.

**APERTA IN ATTESA DI VERIFICA**: la cattura dal Realme.
DOMANDA: "Unisci tutto all'ordine prossimo credo EQ"; "Ti segnalo che gli screenshot sono di un iPhone 17 pro."
PROVA: test/la_stesa_si_legge_intera_test.dart
MISURA: titoli tagliati da 1 a 0 ("IL CONSIGLIO DI MEDORA" su una riga, non tagliato, a 402 punti con iOS e a 360)
