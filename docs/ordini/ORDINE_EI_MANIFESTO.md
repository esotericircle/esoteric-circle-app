# ORDINE EI, LE DODICI VOCI CHE TORNANO APERTE

**Sigla:** EI, riverificata libera sul ramo il 23 settembre 2026: in
`docs/ordini` non c'e' nessun `ORDINE_EI_*`, in `test/` nessuna
`ordine_ei_guard`, e nessun file del repo nomina un ordine EI. Le sigle in
coda sono EA, EB, EC, ED, EE, EF, EG, EH. **Data:** 23 settembre 2026.
**Ramo:** `claude/esoteric-circle-master-order-e798aj`.

**Viene prima dell'ordine EG**, il LIVE dei Maestri, che riparte quando questo
e' chiuso e verificato.

VOCI_TOTALI: 10
VOCI_CHIUSE: 1
VOCI_APERTE: 9

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

**APERTA IN ATTESA DI VERIFICA.**

## VOCE EI.03, EC.01, EC.02 ED EC.03 RIAPERTE: IL COLLAUDO CON GEMINI VERO

Le sedici mosse sui tre Maestri attraverso il servizio Gemini vero, con tutti i
controlli. Ogni caduta e' un difetto da riparare qui, e il giro si rilancia
finche' non ne resta nessuna. Le trascrizioni del giro finale restano nel ramo.

**APERTA IN ATTESA DI VERIFICA.**

## VOCE EI.04, ED.02 RIAPERTA: IL CONTO GREZZO DEL LESSICO

Le violazioni del lessico di firma contate sulla risposta che Gemini
restituisce **prima** della rete e di nuovo **dopo**, giro per giro e Maestro
per Maestro, con le frasi che le hanno prodotte.

**APERTA IN ATTESA DI VERIFICA.**

## VOCE EI.05, EE.03 RIAPERTA: LE SETTE SERE DELLA RUNA

L'esecuzione delle sette sere e di una serie interrotta, con la striscia a
video e la voce nata nel Cosmic Journal.

**APERTA IN ATTESA DI VERIFICA.**

## VOCE EI.06, EE.10 RIAPERTA: I TESTI DEL CONSIGLIO

Almeno una stesa vera portata fino al Consiglio e alla sintesi, con i testi per
intero. Il genere dei numeri delle carte e' giusto, e la sintesi confronta i
tre sguardi invece di ripeterli.

**APERTA IN ATTESA DI VERIFICA.**

## VOCE EI.07, EE.12 RIAPERTA: IL CONTEGGIO ANONIMO SENZA SELETTORE

La schermata della registrazione a video, l'elenco di cio' che il conteggio
spedisce davvero, e il punto della privacy policy.

**APERTA IN ATTESA DI VERIFICA.**

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
