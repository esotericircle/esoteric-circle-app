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
VOCI_APERTE: 7
VOCI_DA_FARE: 5

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

**DA FARE.** La via e' scelta e cominciata: una chiamata sola a Flash per la
lettura intera (`LaLetturaDellaStesa`), ancorata ai significati tradizionali
e ai 468 testi delle carte nella loro posizione, generati una volta sola.

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

**DA FARE.** Un fatto e' gia' misurato. Sul Realme di prova, con la stessa
build 2284 delle catture, il contatore delle domande scende: 50, poi 49
dopo una domanda in chat, poi 48 dopo la seconda restando nella chat
(`docs/collaudo/EQ/realme/`). Le quattro risposte delle catture hanno la
forma del LIVE, due frasi brevi, e i turni del LIVE non consumano domande
per la decisione dell'ordine EG voce 06: e' la domanda per il fondatore.
Resta da fare: la bolla "Chiedi anche agli altri" dice "Oggi te ne restano
20 su 20" senza dire di che cosa, e accanto alla testata si legge come una
contraddizione.

## VOCE EQ.08, I MESSAGGI SOTTO LA CASELLA E SOTTO IL MENU'

La conversazione si ritaglia sopra il bordo alto della casella di
scrittura, seguendo la barra del Cerchio quando scende e sale
(`_TaglioSopraLaCasella` nella chat).

**APERTA IN ATTESA DI VERIFICA**: le catture dal Realme con la chat piena,
a riposo e durante lo scorrimento.
DOMANDA: "Unisci tutto all'ordine prossimo credo EQ", dopo l'elenco dell'Architetto che nominava il testo sotto la casella.
PROVA: test/i_messaggi_stanno_fra_i_contatori_e_la_casella_test.dart
MISURA: punti di conversazione visibili sotto il bordo alto della casella, a 360 e 402 punti, da 74 a 0

## VOCE EQ.09, IL FONDO DEI CONTATORI

**DA FARE.**

## VOCE EQ.10, LA PILLOLA BIANCA DELLA DETTATURA

**DA FARE.**

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
