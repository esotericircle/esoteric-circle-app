# MANIFESTO DELL'ORDINE FI, LA STESA DI TAROCCHI

Testo dell'ordine: `docs/ordini/ORDINE_FI_TESTO.md`. Rapporto: `docs/ordini/RAPPORTO_ORDINE_FI.md`. Da dove si riparte: `docs/ordini/RIPRESA.md`.

Una voce CHIUSA porta sotto di se' DOMANDA, PROVA e MISURA. Le voci aperte e quelle da fare dicono perche' lo sono. La segnalazione del fondatore su taglio e mescolamento dell'11 ottobre non e' una voce dell'ordine: sta nel rapporto, con la sua prova.

VOCI_TOTALI: 50
VOCI_CHIUSE: 16
VOCI_APERTE: 12
VOCI_DA_FARE: 22

## VOCE FI.01

**CHIUSA.** Le cinque stese, con le posizioni di ciascuna come dato.

DOMANDA: "bisogna inserire la stesa a 1 carta e quelle delle tradizioni piu' popolari"
PROVA: test/le_stese_del_cerchio_test.dart
MISURA: stese nel catalogo da 3 a 5 (1, 3, 4, 7 e 10 carte), ognuna con posizioni, posto sul tavolo e fonte; aperta resta solo quella a tre carte

## VOCE FI.02

**CHIUSA.** La geometria e' un dato accanto alle posizioni.

DOMANDA: "la croce di Dora e' una croce: la prima in basso, la seconda a sinistra, la terza a destra, l'ultima in alto"
PROVA: test/le_stese_del_cerchio_test.dart
MISURA: posti sul tavolo dichiarati da 0 a 25 (1, 3, 4, 7 e 10); la Croce Celtica con 1 carta di traverso sulla prima e 4 nel bastone dal basso in alto

## VOCE FI.03

**APERTA IN ATTESA DI VERIFICA.** La regola di Dora (l'esito passa attraverso i due lati) si aggancia quando la croce avra' il corpus delle sue posizioni e la sua lettura a video: prima nessuno la puo' vedere.

## VOCE FI.04

**CHIUSA.** Le diciassette posizioni.

DOMANDA: "Porta SpreadPosition da tre a diciassette voci. Tre esistono gia' e non si toccano."
PROVA: test/le_stese_del_cerchio_test.dart
MISURA: posizioni da 3 a 17; la stesa a tre carte legge ancora le sue 3 (26 usi nel codice e 34 nelle prove portati su SpreadPosition.treCarte)

## VOCE FI.05

**CHIUSA.** "Te stesso" passa dalla marca del genere.

DOMANDA: "L'etichetta "Te stesso" cade sotto la guardia del genere"
PROVA: test/le_stese_del_cerchio_test.dart
MISURA: forme a video da 1 a 3: Te stesso, Te stessa, Tu

## VOCE FI.06

**CHIUSA.** Le quattro chiavi con la loro tradizione.

DOMANDA: "eliminerei quella di Caligo e inserirei tradizione e fonti reali" e "confermo che voglio la quarta"
PROVA: test/le_chiavi_e_la_matrice_dei_tarocchi_test.dart
MISURA: chiavi da 3 a 4, etichette col nome di una persona o di un Maestro da 2 a 0, chiavi con la fonte dichiarata da 0 a 4

## VOCE FI.07

**CHIUSA.** La chiave arriva al modello come voce.

DOMANDA: "Nel prompt la chiave entra come istruzione di voce."
PROVA: test/la_stesa_interpreta_davvero_test.dart
MISURA: chiavi che cambiano l'istruzione da 0 a 3 (la Predittiva la lascia identica a prima)

## VOCE FI.08

**CHIUSA.** La lettura di casa dice la sua chiave.

DOMANDA: "lo DICHIARA a chi legge, invece di spacciare un ripiego per la chiave scelta"
PROVA: test/la_stesa_interpreta_davvero_test.dart
MISURA: righe che dichiarano la lettura di casa da 0 a 1, solo quando il modello non risponde e la chiave non e' la Predittiva

## VOCE FI.09

**DA FARE.** Parte 4, i mazzi: aspetta la decisione del fondatore sulla FI.13 (nell'app o sul bucket con CDN).

## VOCE FI.10

**DA FARE.** Parte 4, i mazzi: aspetta la decisione del fondatore sulla FI.13 (nell'app o sul bucket con CDN).

## VOCE FI.11

**DA FARE.** Parte 4, i mazzi: aspetta la decisione del fondatore sulla FI.13 (nell'app o sul bucket con CDN).

## VOCE FI.12

**DA FARE.** Parte 4, i mazzi: aspetta la decisione del fondatore sulla FI.13 (nell'app o sul bucket con CDN).

## VOCE FI.13

**APERTA IN ATTESA DI VERIFICA.** La misura e' fatta (54.871.350 byte, 54,9 MB in base 1000, 52,3 MiB in base 1024, archivio da 260.267.304 byte a circa 315 MB) e la domanda e' girata al fondatore: i due mazzi nell'app o sul bucket con CDN.

## VOCE FI.14

**DA FARE.** Parte 4, i mazzi: aspetta la decisione del fondatore sulla FI.13 (nell'app o sul bucket con CDN).

## VOCE FI.15

**DA FARE.** Parte 4, i mazzi: aspetta la decisione del fondatore sulla FI.13 (nell'app o sul bucket con CDN).

## VOCE FI.16

**CHIUSA.** I cartigli delle due cartelle sono vuoti.

DOMANDA: "Misura la fascia dei due cartigli su TUTTE le definitive dei due mazzi"
PROVA: docs/collaudo/FI/cartigli.txt
MISURA: carte misurate da 4 (le quattro dell'Architetto) a 156; carte con testo nei cartigli: 0; un testo inciso a mano su una copia ne fa scostare da 263 a 1630 pixel

## VOCE FI.17

**DA FARE.** Aspetta i testi dell'Architetto (aggiunta A1). Pronto cio' che non ha bisogno dei testi: la fonte di ogni posizione ha le tre varianti `- 1:`, `- 2:`, `- 3:` (docs/corpus/tarocchi_posizione/), il tool le legge e il Dart le porta, la rotazione le sceglie (FI.18). Dall'ordine FJ (11 ottobre 2026, la prima ondata dell'Architetto, commit 65fceaae) una posizione ha tutte e tre le varianti, il lato; tre hanno la variante 1, passato, presente e futuro; le altre aspettano: tredici su diciassette, poi dieci su quattordici dall'aggiunta 2 dell'ordine FJ, che ha tolto il ferro di cavallo con le sue tre posizioni orfane (consiglio, ambiente, ostacolo).

**Le posizioni che mancano a ogni stesa** (ordine FJ voce 7). Una stesa si apre quando tutte le sue posizioni hanno la fonte (`TarotSpreadType.disponibile`, aggiunta A6) e la schermata la sa stendere (`costruita`, oggi vero solo per la stesa a tre carte):

| stesa | carte | posizioni distinte | con la fonte | mancano |
|---|---|---|---|---|
| a una carta | 1 | 1 | nessuna | `cartaSola` |
| a tre carte | 3 | 3 | tutte (variante 1) | nessuna, aperta |
| croce di Dora | 4 | 3 | `lato` | `consultante`, `esito` |
| Croce Celtica | 10 | 10 | `passato`, `futuro` | `copre`, `attraversa`, `corona`, `sotto`, `seStesso`, `laCasa`, `speranzeOTimori`, `esito` |

La croce di Dora resta chiusa col solo lato. La stesa che si apre col minor numero di testi e' quella a una carta, con un'ondata sola.

## VOCE FI.18

**APERTA IN ATTESA DI VERIFICA.** La rotazione c'e' ed e' agganciata: `LeUsciteDelleCarte` conta quante volte una carta, in quel verso e in quella posizione, e' gia' uscita a questa persona, la schermata la conta una volta sola quando il responso si apre e la conserva con la stesa, e la lettura di casa sceglie la variante con quel numero. Con la prima ondata (il lato, ordine FJ) la rotazione e' provata sulle tre varianti vere nella catena dell'app (docs/collaudo/FJ/rotazione_del_lato.txt), **ma a video non si vede ancora**: il lato sta solo nella croce di Dora, che resta chiusa, e le tre posizioni della stesa aperta hanno una variante sola. Si guarda quando la croce si apre o quando passato, presente e futuro hanno le varianti 2 e 3.

## VOCE FI.19

**DA FARE.** Il ritorno della carta si dice: il dato c'e' gia' (le uscite della FI.18, chiave `tarot.uscite_delle_carte`), manca la riga che la lettura mostra, "questa carta ti era gia' uscita, allora era capovolta", che vuole anche il verso dell'uscita di prima e la sua prova a video.

## VOCE FI.20

**DA FARE.** Aspetta i testi dell'Architetto (aggiunta A1). Pronto il resto: la fonte dei registri con le 78 carte, i due versi e i tre gruppi (docs/corpus/tarocchi_posizione/registri.md), il tool che li legge tutti o nessuno, e il montaggio: il registro del gruppo dell'argomento segue lo scheletro nella lettura di casa e arriva al modello come riga "In amore e sentimenti parla di" sotto il significato di ogni carta.

## VOCE FI.21

**DA FARE.** E' una regola della scrittura degli scheletri, quindi dell'Architetto (aggiunta A1): scritta in testa al file della fonte del lato (docs/corpus/tarocchi_posizione/lato.md).

## VOCE FI.22

**DA FARE.** E' una regola della scrittura degli scheletri, quindi dell'Architetto (aggiunta A1): scritta in testa al file della fonte del consultante (docs/corpus/tarocchi_posizione/consultante.md).

## VOCE FI.23

**DA FARE.** La generazione e' annullata dall'aggiunta A1: nessun testo generato col modello, quindi niente da spostare in docs/corpus/scartati_FI/ (aggiunta A2). Il tool e' esteso alle diciassette posizioni, alle tre varianti e ai tre registri coi controlli della voce (genere, lunghezza, promesse, certezze, doppioni, Jaccard sopra 0,6, prime parole della terna). Il conto: 468 scheletri su 7.956 e 0 registri su 468.

## VOCE FI.24

**CHIUSA.** Il corpus si tocca alla fonte, divisa in file leggibili.

DOMANDA: "Il markdown in docs/corpus/ resta la fonte e il Dart si rigenera, mai il contrario. La fonte si divide in file leggibili invece di diventare un unico markdown da mezzo megabyte."
PROVA: docs/corpus/tarocchi_posizione/passato.md
MISURA: file della fonte da 1 a 18 (diciassette posizioni e i registri); il piu' grande da 90.642 byte a 34.874; testi rigenerati uguali a quelli di prima 468 su 468; la guardia il_corpus_delle_posizioni cade se il Dart non e' la fonte (docs/collaudo/FI/fi39_fi40_regola_a.txt)

## VOCE FI.25

**DA FARE.** La rilettura resta dell'Architetto; la parte che mi assegnava la generazione e il conto delle rigenerazioni e' annullata dall'aggiunta A1. A ogni ondata il tool controlla e, se un testo non passa, si ferma e lo nomina: non lo correggo a mano.

## VOCE FI.26

**CHIUSA.** Il seme della stesa non decide piu' la stesa compiuta.

DOMANDA: "il tuo suggerimento", cioe' la via che conserva
PROVA: test/la_stesa_si_conserva_test.dart
MISURA: rientri con la stessa domanda che ritrovano le stesse carte da 0 a 1 su 1 nella guardia

## VOCE FI.27

**CHIUSA.** La stesa si conserva per la giornata, e la schermata lo dice.

DOMANDA: "chi riapre la stessa stesa con la stessa domanda ritrova le sue carte"
PROVA: test/la_stesa_si_conserva_test.dart
MISURA: righe di Medora al rientro da 0 a 1; carte spese per rileggere la stesa conservata da 3 a 0

## VOCE FI.28

**CHIUSA.** Taglio e mescolamento restano vivi dentro la stesa in corso.

DOMANDA: "Taglio, mescolamento e scuotimento continuano a funzionare DENTRO la stesa in corso"
PROVA: test/la_carta_estratta_non_cambia_test.dart
MISURA: righe del motore del mescolamento cambiate: 0 su 0; prove della stesa in corso verdi da 911 a 911

## VOCE FI.29

**DA FARE.** Parte 7, la card: dopo i mazzi e il tavolo delle stese nuove.

## VOCE FI.30

**DA FARE.** Parte 7, la card: dopo i mazzi e il tavolo delle stese nuove.

## VOCE FI.31

**DA FARE.** Parte 7, la card: dopo i mazzi e il tavolo delle stese nuove.

## VOCE FI.32

**CHIUSA.** La matrice dei tarocchi nel catalogo dei piani.

DOMANDA: "tabella ok"
PROVA: test/le_chiavi_e_la_matrice_dei_tarocchi_test.dart
MISURA: righe della matrice da 41 a 51; righe toccate fra quelle esistenti (carte al giorno e stesa da dieci): 0

## VOCE FI.33

**DA FARE.** La carta sola pesa una carta, detto prima di scegliere: vive a video con la stesa a una carta, dopo il suo corpus.

## VOCE FI.34

**APERTA IN ATTESA DI VERIFICA.** Vincolo rispettato da tutto cio' che quest'ordine ha toccato (nessun prezzo in Eos; la stesa a tre carte, il budget, il Confine e il blocco di cortesia, il determinismo intatti); si chiude a ordine finito.

## VOCE FI.35

**CHIUSA.** Scritto nel rapporto: la matrice supera i briefing sulle chiavi.

DOMANDA: "Questa matrice supera i quattro briefing in un punto, e va scritto nel rapporto"
PROVA: docs/ordini/RAPPORTO_ORDINE_FI.md
MISURA: punti in cui la matrice supera i briefing scritti nel rapporto: da 0 a 1 su 1

## VOCE FI.36

**DA FARE.** Parte 4, i mazzi: aspetta la decisione del fondatore sulla FI.13 (nell'app o sul bucket con CDN).

## VOCE FI.37

**DA FARE.** Parte 4, i mazzi: aspetta la decisione del fondatore sulla FI.13 (nell'app o sul bucket con CDN).

## VOCE FI.38

**DA FARE.** Parte 4, i mazzi: aspetta la decisione del fondatore sulla FI.13 (nell'app o sul bucket con CDN).

## VOCE FI.39

**APERTA IN ATTESA DI VERIFICA.** La guardia c'e' (test/il_corpus_delle_posizioni_test.dart), vista rossa con sette innesti (docs/collaudo/FI/fi39_fi40_regola_a.txt). Il suo cardinale sale con lo stato dichiarato: 468 oggi, 7.956 quando l'ultima ondata dell'Architetto e' entrata; allora si chiude.

## VOCE FI.40

**APERTA IN ATTESA DI VERIFICA.** La guardia c'e' (nello stesso file della FI.39), rossa con un registro solo innestato nel Dart. Oggi pretende la forma della fonte (468 righe) e i registri vuoti; si chiude quando `registri.md` arriva e i registri sono 468.

## VOCE FI.41

**CHIUSA.** La guardia della stesa conservata, dall'avvio vero.

DOMANDA: "Monta l'app dall'avvio vero, fa una stesa su una domanda, esce dalla schermata, rientra con la stessa domanda e pretende le stesse carte."
PROVA: test/la_stesa_si_conserva_test.dart
MISURA: innesti che la fanno cadere da 0 a 2 su 2 (ricerca spenta, conservazione spenta)

## VOCE FI.42

**CHIUSA.** La guardia della rotazione, con la schermata dall'avvio vero.

DOMANDA: "Pretende che la stessa carta nella stessa posizione mostri tre testi diversi alla prima, alla seconda e alla terza uscita, e che alla quarta ricominci dalla prima."
PROVA: test/la_rotazione_delle_varianti_test.dart
MISURA: innesti che la fanno cadere da 4 su 5 a 5 su 5 (al primo giro la stesa conservata contata di nuovo restava verde: la prova ora riapre il responso dopo il rientro; docs/collaudo/FI/fi42_regola_a.txt)

## VOCE FI.43

**DA FARE.** Prova di vista su ogni guardia nuova: fatta per le guardie nuove di quest'ordine (la stesa conservata, il mazzo nel riquadro, il manifesto, il corpus delle posizioni coi registri e la rotazione, vedi il rapporto); resta per quella dei cartigli della parte 4.

## VOCE FI.44

**DA FARE.** I token di una stesa a tre e a dieci carte, quando la lettura dal modello sapra' leggere dieci carte.

## VOCE FI.45

**APERTA IN ATTESA DI VERIFICA.** Fatte le anteprime della schermata dei selettori (docs/preview/prima_dopo/fi_selettori_tipo_prima.png e le altre tre); quelle della croce, del ferro di cavallo, della Croce Celtica e della card aspettano che quelle stese abbiano il loro tavolo e il loro corpus.

## VOCE FI.46

**APERTA IN ATTESA DI VERIFICA.** Vincolo rispettato da tutto cio' che quest'ordine ha toccato (nessun prezzo in Eos; la stesa a tre carte, il budget, il Confine e il blocco di cortesia, il determinismo intatti); si chiude a ordine finito.

## VOCE FI.47

**APERTA IN ATTESA DI VERIFICA.** L'Arcano dell'Alba non e' toccato; la riga che lo distingue dalla carta sola si scrive con la stesa a una carta.

## VOCE FI.48

**APERTA IN ATTESA DI VERIFICA.** Vincolo rispettato da tutto cio' che quest'ordine ha toccato (nessun prezzo in Eos; la stesa a tre carte, il budget, il Confine e il blocco di cortesia, il determinismo intatti); si chiude a ordine finito.

## VOCE FI.49

**APERTA IN ATTESA DI VERIFICA.** Vincolo rispettato da tutto cio' che quest'ordine ha toccato (nessun prezzo in Eos; la stesa a tre carte, il budget, il Confine e il blocco di cortesia, il determinismo intatti); si chiude a ordine finito.

## VOCE FI.50

**APERTA IN ATTESA DI VERIFICA.** Vincolo rispettato da tutto cio' che quest'ordine ha toccato (nessun prezzo in Eos; la stesa a tre carte, il budget, il Confine e il blocco di cortesia, il determinismo intatti); si chiude a ordine finito.
