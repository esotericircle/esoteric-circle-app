# ORDINE EI, LE DODICI VOCI CHE TORNANO APERTE

**Sigla:** EI, riverificata libera sul ramo il 23 settembre 2026: in
`docs/ordini` non c'e' nessun `ORDINE_EI_*`, in `test/` nessuna
`ordine_ei_guard`, e nessun file del repo nomina un ordine EI. Le sigle in
coda sono EA, EB, EC, ED, EE, EF, EG, EH. **Data:** 23 settembre 2026.
**Ramo:** `claude/esoteric-circle-master-order-e798aj`.

**Viene prima dell'ordine EG**, il LIVE dei Maestri, che riparte quando questo
e' chiuso e verificato.

VOCI_TOTALI: 10
VOCI_CHIUSE: 7
VOCI_APERTE: 3

---

## DA DOVE NASCE

L'ordine EH ha elencato dodici voci dichiarate chiuse che **non portavano una
prova apribile**, e cinquantasette in una forma vecchia che nessun conto
automatico rilegge. Messo davanti all'elenco, il fondatore ha deciso:
**"Riaprirle tutte"** per le dodici, **"Restano chiuse"** per le
cinquantasette, **"Prima le 12 voci"** per la precedenza sull'ordine EG.

Le dodici riaperte sono EB.01, EB.06, EC.01, EC.02, EC.03, ED.02, EE.03,
EE.10, EE.12, EF.01, EF.02, EF.04, raccolte qui in dieci voci perche' le tre
dell'ordine EC sono un lavoro solo.

**Che cosa e' questo ordine, detto chiaro.** Il censimento sul ramo dice che
**per dieci voci su dodici il codice c'e' gia', ed e' gia' sorvegliato da
guardie vive**. Quello che mancava era la **prova apribile**: il file che il
fondatore puo' aprire per vedere coi suoi occhi che la cosa funziona. Questo
ordine produce quelle prove, e dove il codice manca davvero lo scrive.

---

## GLI SCARTI FRA L'ORDINE E IL RAMO, TROVATI PRIMA DI TOCCARE NIENTE

L'ordine dichiara che il suo testo non e' affidabile e che ogni cosa va
verificata sul ramo. Verificata. Tre scarti, col file e la riga.

### Scarto 1, la voce EI.09 chiedeva di disfare una decisione del fondatore

L'ordine chiede *"il respiro e' cinque tempi dentro e cinque fuori per otto
volte"*. Sul ramo **non e' cosi', e non per dimenticanza**: i numeri vengono
dal rito del giorno, `breath_destiny_screen.dart:1273` legge
`_gift!.rito!.giri`, e `lib/core/rituals/rito_alba_corpus.dart` contiene
trentasei riti con cadenze diverse, per esempio `tempi: 5, giri: 3` alla riga
203 e `tempi: 4, giri: 8` alla riga 422. Lo scarto era gia' dichiarato in
`ORDINE_EF_MANIFESTO.md:190-216` con la parola del fondatore, che va tenuta su
una riga sola perche' una guardia la cerca per intero:
**"Lascio come sta, decide il rito"**.

**Chiesto di nuovo al fondatore il 23 settembre 2026, ha confermato: resta
come aveva deciso.** La voce EI.09 quindi **non riscrive niente**: prova che
la scritta e il conteggio leggono sempre gli stessi numeri del rito, che e' la
cosa vera da provare.

### Scarto 2, la voce chiamata EE.12 sul ramo e' EA voce 12

Il codice che toglie *"Conta i gesti, non me"* dichiara **ordine EA voce 12**,
non EE.12: `privacy_e_permessi_screen.dart:127-131` e
`consensi_della_registrazione.dart:44-50`. La cosa da provare e' la stessa; il
padre no.

### Scarto 3, la voce EB.06 e' stata rovesciata dall'ordine EE.07

L'ordine EB.06 diceva che una domanda del Maestro **consuma**; l'ordine EE.07
ha deciso il contrario, e lo scarto sta scritto in
`esito_del_turno.dart:52-56`. **L'ordine EI dice "quel turno non fa scendere
nessun contatore", che e' la forma nuova**: nessun conflitto, ma il padre
della regola in vigore e' EE.07.

---

## COSA IL CENSIMENTO HA TROVATO GIA' IN CASA

Verificato sul ramo prima di scrivere una riga, con file e riga. Serve a non
rifare cio' che c'e' e a sapere dove sta davvero il buco.

| voce | il codice c'e'? | dove | la guardia c'e'? |
|---|---|---|---|
| EB.01 | SI, e le porte sono **tredici** | `chat_openers.dart`, 13 compositori | `la_chat_sa_a_cosa_rispondono_le_carte` |
| EB.06 | SI, nella forma di EE.07 | `esito_del_turno.dart:57`, `la_risposta_che_chiede.dart:38` | `il_chiarimento_non_costa` |
| EC.01/02/03 | SI | `tool/collaudo_dei_maestri.dart`, 16 mosse per 3 Maestri | `il_catalogo_delle_mosse_e_eseguito` |
| ED.02 | SI, ma vive **solo nel referto** | `collaudo_dei_maestri.dart:505` e `:511` | **nessuna prova in `test/`** |
| EE.03 | SI, tutte e tre le parti | `sunset_rune_memory.dart:83`, `sunset_rune_screen.dart:1616` | `sette_sere_di_fila`, **ma non il Ricordo** |
| EE.10 | SI, la regola in un punto solo | `la_lingua_del_modello.dart:65` | `il_genere_delle_carte_arriva_ai_maestri` |
| EE.12 | SI, la frase non esiste piu' in `lib` | solo due commenti che lo dichiarano | `la_misura_del_ritorno` |
| EF.01 | SI | `breath_destiny_screen.dart:116-131` e `:185` | `il_riquadro_non_copre_la_figura` |
| EF.02 | **scarto dichiarato**, vedi sopra | `tempi_del_respiro.dart:136` | `il_respiro_si_guida` |
| EF.04 | SI | `breath_destiny_screen.dart:488-563` | `il_soffio_si_riconosce_dalla_forma` |

**Le tre lacune di prova vere**, che questo ordine deve chiudere: il Ricordo
della settima sera non e' toccato da nessun test; il conto del lessico prima e
dopo la rete non e' misurato in `test/`; e nessuna guardia impedisce a una
porta futura con domanda di nascere senza portarla.

---

## LE DECISIONI DEL FONDATORE DEL 23 SETTEMBRE 2026

Tre domande girate prima di cominciare, e tre risposte.

1. **EF.02**: *"Resta come hai deciso tu"*, il rito decide la cadenza.
2. **La build**: *"Si, fai la build quando servono"*, per le catture sul
   Realme delle voci EI.08, EI.09 e EI.10.
3. **Le chiamate a Gemini**: *"Senza limite finche' e' verde"*, col conto
   esatto delle chiamate riportato nel rapporto.

---

## LE DIECI VOCI

## VOCE EI.01, EB.01 RIAPERTA: LA DOMANDA PREIMPOSTATA PORTA ANCHE LA DOMANDA

Per ciascuna delle tredici porte di approfondimento, il testo che apre la chat
come lo vede una persona, catturato da un'esecuzione vera.

### Cosa e' stato fatto

**Il codice c'era e non era il problema.** La guardia che gia' copriva la zona,
`la_chat_sa_a_cosa_rispondono_le_carte`, e' stata vista rossa prima di toccare
niente (Regola B), rinominando il parametro di `ChatOpeners.consiglio`: cade
sulla misura giusta, non in compilazione. La prima prova del rosso **non
valeva** e va detto: aveva rotto la compilazione, e una prova che non compila
non misura la guardia, misura un errore di chi l'ha innestata.

**Cio' che mancava era il file apribile.** La guardia vecchia misura la cosa
giusta **dentro il codice**, per nome di funzione e presenza di parametro: per
controllarla il fondatore doveva leggere il codice. Adesso
`docs/collaudo/EI/tredici_porte.txt` porta tutte e tredici le aperture **come
le legge una persona**, una sotto l'altra, e nasce dentro la prova che le
misura, quindi si rigenera a ogni giro o cade con lei.

**E il censimento ha chiarito una cosa che l'ordine dava per scontata.** Delle
tredici porte, **soltanto due possono portare una domanda della persona**, la
Stesa e il Consiglio, perche' sono le uniche due arti in cui una domanda la
persona la pone. Le altre undici nascono da un gesto o da un dato: l'Oroscopo
dal segno, la Runa dalla gettata, il Viso dal tratto. Pretendere che portino
una domanda che non esiste vorrebbe dire pretendere che se la inventino.

### Il finto difetto che il file apribile ha mostrato, e che era mio

Letto il file, la porta del Viso diceva *"Il mio tratto dominante e' gli alti e
larghi"*, che sembrava un difetto della lingua. **Non lo era**: avevo scritto a
mano un esempio inventato. I nomi veri dei tratti stanno in `FaceTrait` e sono
`Zigomi morbidi`, `Sopracciglia folte`, e l'articolo li accorda bene. La prova
adesso prende il dato dall'enum, e il testo dice *"gli zigomi morbidi"*.
**Un esempio inventato fa vedere difetti che non esistono e nasconde quelli
veri.**

**CHIUSA.**
DOMANDA: "la chat con una domanda preimpostata che secondo me e' incompleta perche' dovrebbe contenere anche la domanda oltre che le carte estratte, giusto? le carte rispondono a una domanda"
PROVA: docs/collaudo/EI/tredici_porte.txt
MISURA: 13 porte su 13 scritte nella prova col testo che legge una persona; 2 nascono da una domanda della persona e tutte e 2 la portano per intero; la guardia della zona vista rossa prima di toccarla

## VOCE EI.02, EB.06 RIAPERTA: IL MAESTRO CHIEDE CIO' CHE GLI MANCA

Conversazioni vere con i tre Maestri in cui i dati mancano, con la risposta per
intero e il valore dei contatori prima e dopo.

### IL DIFETTO ERA DOPPIO, E LE DUE META' SI COPRIVANO A VICENDA

**Prima meta': l'app faceva pagare un malinteso.** Al collaudo del 23 settembre
2026, mossa 8, tutti e tre i Maestri hanno chiesto di riformulare e **tutti e
tre hanno fatto scendere il contatore di uno**. La regola della voce EE.07 dice
il contrario. La causa: `eUnaDomanda` guardava la fine del testo, e ogni
risposta si chiude con la riga del gesto, che **non e' mai una domanda**.
Quindi guardava sempre il gesto, e il chiarimento non scattava mai su una
risposta vera.

**E la prova che avrebbe dovuto prenderlo prometteva piu' di quanto
misurasse**: si chiamava *"e la chiusura col gesto non nasconde la domanda"* e
**non metteva nessun gesto**, provava uno spazio in coda e una virgoletta.

**Seconda meta', ed e' quella che lo teneva invisibile: il collaudo pretendeva
che quel turno costasse 1.** Era la regola dell'ordine EB voce 06, *"una
domanda del Maestro e' una risposta vera, quindi consuma"*. **L'ordine EE voce
07 l'ha rovesciata e il catalogo non e' stato aggiornato.** L'app dava 1, il
collaudo ne pretendeva 1, il giro restava verde: **due punti che si danno
ragione a vicenda mentre la regola in vigore dice un'altra cosa**, e un verde
cosi' e' peggio di un rosso, perche' diventa una conferma. **Padre: ordine EE
voce 07**, che ha cambiato la regola senza aggiornare la misura che la
sorvegliava.

### LA PRIMA CURA E' CADUTA IN UN GIRO, E LA LEZIONE ERA GIA' IN CASA

Il primo tentativo cercava le parole del chiarimento in **un elenco chiuso**.
Riconosceva le tre risposte del primo giro; al secondo il modello ne ha usate
di nuove, *"Ti invito a formulare una richiesta chiara"*, e la cura non l'ha
visto.

**Era scritto a un file di distanza**, nel collaudo stesso: *"le prime due
stesure cercavano le parole del chiarimento in un elenco chiuso [...] Caligo
chiedeva chiarimento ogni volta con parole nuove [...] allungarlo ancora
sarebbe stato inseguire la lingua di ieri"*. Il collaudo lo aveva risolto
**chiedendolo al modello**, ma lui puo' permettersi una chiamata in piu' e il
runtime no.

**La cura vera: il Maestro lo dichiara.** Mette `[[CHIEDO]]` in cima quando
chiede invece di rispondere; si decide il costo sul testo col marcatore e si
mostra quello senza. Non si indovina piu' niente, non costa una chiamata in
piu', e non dipende dalle parole che il modello sceglie domani.

**E una guardia nuova impedisce ai due punti di tornare a contraddirsi**: nel
catalogo, un turno che si aspetta una richiesta di chiarimento non puo'
aspettarsi anche di pagarla.

**CHIUSA.**
DOMANDA: "l'utente paga per ogni risposta e le risposte devono essere corrette e coerenti"
PROVA: docs/collaudo/EI/il_chiarimento_non_costa.txt
MISURA: sul giro vero con Gemini, il contatore della mossa 8 scende da 1 a 0 per tutti e tre i Maestri; 3 chiarimenti veri riconosciuti su 3 e 2 letture vere che continuano a pagare su 2; 1 turno del catalogo che chiede, 0 a pagamento

## VOCE EI.03, EC.01, EC.02 ED EC.03 RIAPERTE: IL COLLAUDO CON GEMINI VERO

Le sedici mosse sui tre Maestri attraverso il servizio Gemini vero, con tutti i
controlli. Le trascrizioni restano nel ramo.

### SCARTO 4, SUL CRITERIO DI CHIUSURA, E IL FONDATORE HA DECISO

L'ordine diceva *"il giro si rilancia finche' non ne resta nessuna"*. **Nove
giri dicono che quel criterio non e' raggiungibile**, e il dato che lo dimostra
e' il piu' scomodo possibile: **il primo giro e' uscito a zero cadute avendo
dentro il difetto dei contatori della voce EI.02**, quello che faceva pagare un
malinteso a tutti e tre i Maestri.

Le cadute per giro sono state **0, 2, 4, 1, 5, 3, 3, 2, 2**. Si spostano ogni
volta: un giro verde non dice che non ci sono difetti, e un giro rosso non dice
che ce ne sia uno nuovo.

Messo davanti al dato, il fondatore ha scelto **la misura a frequenza**, che e'
gia' quella in uso in questa casa per l'attribuzione cieca: si dichiarano N
giri con la percentuale e l'escursione, e si riparano le cadute che tornano.

### LA MISURA, SU NOVE GIRI

| | |
|---|---|
| giri | **9** |
| conversazioni | **405**, cioe' 45 per giro, 16 mosse per 3 Maestri |
| chiamate a Gemini | **47 per giro, 423 in tutto** |
| cadute | **22, il 5,4 per cento** |
| escursione | da **0** a **5** cadute per giro |
| la caduta piu' frequente | **3 volte su 9** |
| mosse che non cadono mai | **11 su 16**: la 1, 2, 4, 5, 7, 9, 10, 11, 13, 15, 16 |

**Nessun difetto e' sistematico.** Quattordici casi distinti, e il piu'
ostinato torna tre volte su nove: e' la firma della variabilita' del modello,
non di un guasto del codice.

### LE TRE CURE CHE I GIRI HANNO TROVATO E PROVATO

1. **il contatore della mossa 8 scende da 1 a 0** per tutti e tre i Maestri,
   che e' la voce EI.02;
2. **il Maestro non chiede piu' alla persona di spiegargli il responso che le
   abbiamo dato noi**: la regola nominava carte, rune e archetipo, e non i
   centri di Aura, quindi davanti a *"cuore chiuso, gola quasi spenta"* Aura
   chiedeva alla persona cosa intendesse. Adesso vale per ogni arte;
3. **il marcatore si mette solo se in tutta la risposta non c'e' niente che
   risponda**: la prima stesura diceva *"se stai rispondendo nel merito, anche
   solo in parte, non metterlo"* e il modello la fraintendeva, regalando le
   risposte in cui diceva di no e poi chiedeva. **Dire di no e' una risposta.**

**CHIUSA.**
DOMANDA: "SERVE UN CENSIMENTO SU TUTTE LE CHAT dei maestri e devono essere previsti ogni risposta o comportamento dell'utente"
PROVA: docs/collaudo/EI/nove_giri_del_collaudo.txt
MISURA: 9 giri, 405 conversazioni, 423 chiamate a Gemini, 22 cadute pari al 5,4 per cento, escursione da 0 a 5, la piu' frequente 3 volte su 9; 11 mosse su 16 non cadono mai; 3 difetti veri trovati e curati

## VOCE EI.04, ED.02 RIAPERTA: IL CONTO GREZZO DEL LESSICO

Le violazioni del lessico di firma contate sulla risposta che Gemini
restituisce **prima** della rete e di nuovo **dopo**, giro per giro e Maestro
per Maestro, con le frasi che le hanno prodotte.

### IL CONTO C'ERA GIA', E DICE UNA COSA BUONA

Il conto grezzo esisteva nel referto del collaudo, `collaudo_dei_maestri.dart`
righe 505 e 511, e **nessuna prova di `test/` lo misurava**: viveva solo in un
file che si produce a mano. Adesso e' nella prova dell'ordine, con i numeri di
nove giri.

**Cosa dice.** Su 45 conversazioni per giro, le parole di firma di un altro
Maestro entrano **una o due volte**, e **dopo la rete sono sempre zero**. Al
primo giro era Caligo, alla mossa 11; all'ultimo Medora alla mossa 3 e Caligo
alla mossa 4. Sempre **0 dopo la rete**.

**La rete non e' una cerimonia: prende quello che passa.** E il prezzo si
conosce: **792 millisecondi in media**, su una conversazione su 45.

**CHIUSA.**
DOMANDA: "In ogni giro del collaudo si contano le violazioni del lessico di firma sulla risposta che Gemini restituisce prima della rete, e di nuovo dopo la rete"
PROVA: docs/collaudo/EI/nove_giri_del_collaudo.txt
MISURA: su 9 giri, da 0 a 2 violazioni per giro prima della rete e sempre 0 dopo; la rete ha richiesto in 1 conversazione su 45, con 792 ms aggiunti

## VOCE EI.05, EE.03 RIAPERTA: LE SETTE SERE DELLA RUNA

L'esecuzione delle sette sere e di una serie interrotta, con la striscia a
video e la voce nata nel Cosmic Journal.

### LA LACUNA VERA: UN TERZO DELLA VOCE NON ERA SORVEGLIATO

La voce EE.03 ha tre parti. La serie di sette sere e la riga che la spiega a
video erano provate. **Il riassunto che alla settima sera entra da solo nel
Cosmic Journal non era toccato da nessun file di `test/`**: ne'
`ComeENato.evento` ne' `didascaliaDellaSettimana` comparivano da nessuna parte.

**E c'era una ragione meccanica, non una dimenticanza.** La frase viveva dentro
`_SunsetRuneScreenState`, cioe' dentro uno **State privato**: la leggevano lo
schermo e il Ricordo, ma **nessuno da fuori poteva chiamarla**. Una frase che
la persona legge nel diario e che nessuna prova puo' raggiungere non e'
sorvegliata da niente.

Spostata in `sunset_rune_memory.dart`, accanto alla logica delle sette sere che
la produce: chi cambia la finestra vede anche la frase che quella finestra
genera. Lo schermo la chiama da li', e la copia nello State non esiste piu'.

**Cosa misura la prova nuova.** Che la frase **dica il vero sulle rune di
quella settimana**: sette rune diverse ricevono *"nessuno ha insistito"*, una
runa che torna tre volte fa nominare **quella** runa, e le due frasi devono
essere **diverse** fra loro. Quest'ultima e' la grandezza che prende il difetto
del Sigillo del Sogno: una frase che dice la stessa cosa in tutti i casi non
guarda il dato. E che il Ricordo si dichiari **nato dal Cerchio e non dalla
persona**, che e' la ragione per cui `ComeENato.evento` esiste: se nascesse
come gesto, il diario direbbe una cosa falsa su chi lo rilegge.

**Regola B rispettata**: `sette_sere_di_fila` vista rossa prima di toccare la
zona, accorciando a tre la finestra dei sette giorni.

**CHIUSA.**
DOMANDA: "Il riassunto della settimana arriva soltanto dopo sette Rune del Tramonto in sette sere consecutive [...] Alla settima sera il riassunto entra da solo nel Cosmic Journal come evento speciale"
PROVA: docs/collaudo/EI/sette_sere_e_il_diario.txt
MISURA: 2 settimane misurate, con e senza ripetizioni, e le due frasi risultano diverse; il Ricordo porta ComeENato.evento, il maestro caligo e tutte e 7 le rune; la frase esce dallo State privato e diventa raggiungibile da una prova

## VOCE EI.06, EE.10 RIAPERTA: I TESTI DEL CONSIGLIO

Almeno una stesa vera portata fino al Consiglio e alla sintesi, con i testi per
intero. Il genere dei numeri delle carte e' giusto, e la sintesi confronta i
tre sguardi invece di ripeterli.

### LA SINTESI VERA, E COSA RESTA DEL FONDATORE

La sintesi sta in `docs/collaudo/EI/il_consiglio_e_la_sintesi.md`, ed e' nata
dalle **tre letture vere della cattura del fondatore del 23 settembre 2026**,
sulla domanda *"Denaro e fortuna"*. I controlli di quel giro: 104 parole, **3
Maestri chiamati per nome**, **una sola** sequenza di cinque parole ripresa
dalle letture, e nomina almeno una relazione fra gli sguardi.

**Se la sintesi confronti davvero i tre sguardi invece di riassumerli lo
giudica il fondatore leggendo quella pagina.** Qui non si da' per fatto, e la
voce lo dichiara: nessun controllo automatico sa distinguere un confronto da
un riassunto ben scritto.

### IL GENERE DELLE CARTE, MISURATO SULLE RISPOSTE E NON SULLA REGOLA

La regola vive in un punto solo, `la_lingua_del_modello.dart:65`, e tre prove
gia' verificavano **che arrivasse ai tre Maestri**. Ma **misurare che una
regola arrivi al modello non e' misurare la risposta**, ed e' il suggerimento
5 dell'Architetto accolto nell'ordine EH.

Qui si guarda cio' che Gemini ha **scritto davvero** nei nove giri: **11 nomi
di carte con numero, 0 con l'articolo femminile sbagliato**. Undici e' un
campione piccolo e va detto che lo e'; ma e' undici volte piu' di quanto
misurasse prima chiunque.

**CHIUSA.**
DOMANDA: "il genere dei numeri delle carte e' giusto, il Tre di Denari e il Tre di Coppe"
PROVA: docs/collaudo/EI/il_genere_delle_carte_nelle_risposte.txt
MISURA: 11 nomi di carte con numero scritti da Gemini nei 9 giri, 0 con l'articolo sbagliato; la sintesi vera porta 104 parole, 3 Maestri per nome e 1 sola sequenza di 5 parole ripresa dalle letture

## VOCE EI.07, EE.12 RIAPERTA: IL CONTEGGIO ANONIMO SENZA SELETTORE

La schermata della registrazione a video, l'elenco di cio' che il conteggio
spedisce davvero, e il punto della privacy policy.

### COSA MANCAVA, VISTO CHE LE GUARDIE C'ERANO GIA'

`la_misura_del_ritorno` gia' provava che la frase e l'interruttore non vivono
piu' in `lib` e che il conteggio parte senza chiedere niente. **Quello che non
c'era era il file apribile**: l'elenco, in una pagina sola, di **cosa esce
davvero dal telefono**, messo accanto a cio' che la schermata promette che
esca.

Per una promessa sulla privacy la differenza non e' formale. La schermata dice
*"cinque gesti in numeri per giorno [...] senza nessun identificativo del
telefono o tuo"*: adesso quella frase sta su disco accanto ai cinque eventi
veri, `apertura`, `ritornoDaAvviso`, `ritoCominciato`, `ritoCompiuto`,
`responsoCondiviso`, e chi legge verifica in dieci secondi che **cinque** sia
cinque.

**Il cardinale e' il numero esatto e non un minimo**: se nascesse un sesto
evento senza che nessuno aggiorni quella frase, la promessa diventerebbe falsa
e la prova cade.

### IL FALSO POSITIVO CHE MI SONO TROVATO ADDOSSO

La prova sugli identificativi leggeva il sorgente intero e cadeva su `uid`, che
compare due volte in `misura_del_ritorno.dart`: **dentro due commenti che
dichiarano che quel legame e' stato tolto**. Una prova che accusa il codice per
aver spiegato cosa non fa piu' **insegna a cancellare le spiegazioni**, ed e'
il contrario di quello che serve a questo progetto. Adesso salta i commenti,
come fa gia' la prova sulla frase.

**Vista rossa** innestando un `userId` in `registro_del_ritorno.dart`,
verificato col grep prima di leggere l'esito.

**CHIUSA.**
DOMANDA: "La frase «Conta i gesti, non me» e il suo selettore non esistono piu' in nessun punto. Il conteggio e' sempre attivo e raccoglie soltanto numeri aggregati per giorno, senza identificativi"
PROVA: docs/collaudo/EI/cosa_spedisce_il_conteggio.txt
MISURA: 5 eventi nel codice e 5 promessi dalla schermata; 0 identificativi su 11 cercati; 673 file di lib guardati e 0 che nominano la frase o l'interruttore fuori dai commenti che ne dichiarano la rimozione

## VOCE EI.08, EF.01 RIAPERTA: IL SOFFIONE SI VEDE PER INTERO

Le catture dei tre momenti sul Realme, con la misura di dove comincia la bolla
e di quanto e' alta.

**APERTA IN ATTESA DI VERIFICA.**

## VOCE EI.09, EF.02 RIAPERTA: LA CADENZA DEL RESPIRO

**Riformulata per lo scarto 1**, con la conferma del fondatore: la cadenza
resta quella del rito del giorno. Si prova che la scritta e il conteggio dei
giri leggono **sempre gli stessi numeri**, su tutti i riti del corpus, e la
cattura lo mostra a video.

**APERTA IN ATTESA DI VERIFICA.**

## VOCE EI.10, EF.04 RIAPERTA: IL SOFFIO AL MICROFONO

Cio' che si puo' misurare sul segnale del microfono, dichiarato col file e la
riga. **La prova finale, il soffio vero, resta del fondatore**: si dichiara e
non si da' per fatta.

**APERTA IN ATTESA DI VERIFICA.**
