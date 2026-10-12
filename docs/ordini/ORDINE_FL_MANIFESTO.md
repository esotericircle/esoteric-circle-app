# MANIFESTO DELL'ORDINE FL, LO SFONDO DEL TAVOLO E LA STESA SUL PIANO

Testo dell'ordine: `docs/ordini/ORDINE_FL_TESTO.md`. Rapporto: `docs/ordini/RAPPORTO_ORDINE_FL.md`.

Una voce per ciascuna delle dieci voci dell'ordine, piu' le cinque richieste che il fondatore ha scritto in chat mentre guardava le anteprime, il 12 ottobre 2026: FL.11 le carte coperte prima della stesa, FL.12 la testa di Medora che sfiora la barra, FL.13 il bagliore della carta chiave, FL.14 le altre stese e gli altri due mazzi, FL.15 il tappetino blu. Una voce CHIUSA porta sotto di se' DOMANDA, PROVA e MISURA. Le decisioni di merito sono di Code (FL.09), con la ragione nel rapporto. Le voci a video sono state guardate nelle anteprime del motore delle prove a 1080 per 2391, non sul telefono: la build la ordina il fondatore (FL.10).

VOCI_TOTALI: 15
VOCI_CHIUSE: 15
VOCI_APERTE: 0
VOCI_DA_FARE: 0

## VOCE FL.01

**CHIUSA.** Lo sfondo nuovo con Medora tagliata alla vita dietro il tavolo, la testa intera sotto la barra.

DOMANDA: "SFONDO NUOVO con sovrapposta Medora tagliata alla vita come se fosse dietro il tavolo" e "L'immagine va tagliata in alto in modo che la testa di Medora sia visibile e non tagliata dalla barra del titolo superiore"
PROVA: test/il_tavolo_di_medora_test.dart
MISURA: sfondi a immagine da 0 (CosmosBackground) a 1; la vita di Medora sul bordo lontano del velluto entro 1 punto a 360, 390 e 430 di larghezza; la cima della testa da 0 a 12 punti sotto la barra, mai tagliata; MedoraStage montato in lib da 1 a 0

## VOCE FL.02

**CHIUSA.** Dall'alto: la barra, la scena, il selettore, il riquadro delle 78 carte coi suoi pulsanti, il pulsante.

DOMANDA: "Subito sotto il tavolo il selettore delle opzioni di stesa. Subito sotto il riquadro con la scelta delle 78 carte con i pulsanti mischia e taglia, tutto com'e' adesso in app. Sotto il riquadro il pulsante. Tutta la meccanica resta com'e' adesso."
PROVA: test/il_tavolo_di_medora_test.dart
MISURA: a 360 punti Medora a 63, il ventaglio a 609,8 e il pulsante a 871,5, nell'ordine; selettore, ventaglio, Mischia, Taglia, Suono, scuoti e pulsante ridisegnati 0 (le loro prove di sempre verdi)

## VOCE FL.03

**CHIUSA.** Le carte scelte si posano sul piano del tavolo, inclinate come il velluto, ai posti che la stesa dichiara.

DOMANDA: "Le carte scelte si stendono sul tavolo mantenendo la stessa prospettiva del tavolo."
PROVA: docs/preview/FL/fl_croce_le_carte_coperte.png
MISURA: stese disegnate nella prospettiva del piano da 0 a 4 su 4 (un'omografia dal piano piatto al trapezio del velluto); carte fuori dal campo del velluto 0 in ogni stesa; la premessa P2 non era piu' vera: dall'aggiunta 2 FK la schermata leggeva gia' PostoSulTavolo, in piano

## VOCE FL.04

**CHIUSA.** La carta chiave grande come le altre, con la luce.

DOMANDA: "La Carta chiave e' illuminata da sotto, non e' piu' grande."
PROVA: test/la_chiave_e_il_consiglio_si_vedono_test.dart
MISURA: scala della chiave e delle altre da 1,10 e 0,86 a 1,0 e 1,0; scarto di larghezza dipinta fra la chiave e le altre da oltre il 20 per cento a meno dell'1; carte chiave con la luce da 0 a 1

## VOCE FL.05

**CHIUSA.** Dopo la riflessione le carte si girano una alla volta sul tavolo; un secondo dopo l'ultima si alzano affiancate, piu' grandi.

DOMANDA: "Dopo aver premuto il pulsante e dopo l'animazione di riflessione, le carte si girano sul tavolo una alla volta e dopo un secondo dall'ultima girata, si mettono in verticale ingrandendosi per rendersi ben visibile all'utente."
PROVA: docs/collaudo/FL/fl_la_sequenza_in_cinque_fotogrammi.png
MISURA: facce sul tavolo nel tempo 0, 1, 2, 3 (una alla volta); ultima girata a 1.750 ms, alzata a 3.250 ms, 1.500 ms dopo (almeno 1.000); etichette che si toccano nella croce in piedi da 2 coppie a 0

## VOCE FL.06

**CHIUSA.** Toccare una carta alzata dal tavolo apre il suo significato generico.

DOMANDA: "Se faccio click su una carta, mi viene mostrato il suo significato generico."
PROVA: test/la_carta_si_apre_al_tocco_test.dart
MISURA: la voce era gia' eseguita nell'ordine FK (aggiunta 1 voce A4); carte in piedi che aprono il significato generico e non la lettura 3 su 3, la prova monta la stesa a responso pronto, cioe' la fila alzata dal tavolo; bersaglio di ogni carta almeno 48 per 48 punti

## VOCE FL.07

**CHIUSA.** Il responso sotto le carte e' quello di prima.

DOMANDA: "Per quanto riguarda tutto il responso resta uguale a prima."
PROVA: test/stesa_tre_carte_test.dart
MISURA: titolo, tre paragrafi col secondo nel riquadro, bolle per carta e corsivo del da dove viene cambiati 0; la fila delle carte che il responso ripeteva sotto la scena tolta (1 a 0), perche' le carte stanno in piedi nella scena sopra di lui

## VOCE FL.08

**CHIUSA.** La cartella del tavolo dichiarata nel pubspec.

DOMANDA: "La cartella assets/img/tavolo/ e' nuova: in pubspec.yaml la riga assets: alla riga 258 non e' ricorsiva, quindi la cartella va dichiarata da sola"
PROVA: pubspec.yaml
MISURA: righe di assets/img/tavolo/ nel pubspec da 0 a 1; file del tavolo letti dall'app 2 su 2 (lo sfondo, dalla FL.15 la v2; il busto)

## VOCE FL.09

**CHIUSA.** Le decisioni di merito prese da Code e dichiarate nel rapporto, compresa la misura dell'immagine.

DOMANDA: "Eventuali modifiche, adattamenti e miglioramenti li decide Code."
PROVA: docs/ordini/RAPPORTO_ORDINE_FL.md
MISURA: decisioni girate all'Architetto o al fondatore 0; decisioni dichiarate nel rapporto 6; P3: l'immagine misura 688 per 1536 e lo schermo 1080 per 2392, ingrandimento 1,57; proposta di rigenerarla ad almeno 1080 per 2400, la stessa inquadratura

## VOCE FL.10

**CHIUSA.** Nessuna build di iniziativa.

DOMANDA: "Finito il lavoro, si riferisce cosa e' pronto e si attende il suo ordine. Nessuna build di iniziativa."
PROVA: docs/ordini/RAPPORTO_ORDINE_FL.md
MISURA: build costruite 0; numero della versione nel pubspec cambiato 0

## VOCE FL.11

**CHIUSA.** Prima della stesa le carte coperte sul tavolo e la bolla delle opzioni sotto; il titolo non copre piu' i nomi delle posizioni.

DOMANDA: "Il titolo copre "passato presente futuro" sottile carte. Io vorrei vedere prima della stesa con le 3 carte coperte e la bolla delle opzioni di stesa"
PROVA: docs/preview/FL/fl_tre_carte_le_carte_coperte.png
MISURA: scritte delle posizioni coperte dal titolo da 3 a 0; carte coperte sul tavolo prima della stesa da 0 a 3; nomi delle carte scritti prima del responso da 3 a 0, che rivelerebbero le carte coperte

## VOCE FL.12

**CHIUSA.** La scena alzata finche' la testa di Medora sfiora la barra del titolo.

DOMANDA: "Devi alzare tutto fino a quando la testa di Medora sfiora il riquadro alto del titolo della schermata"
PROVA: test/il_tavolo_di_medora_test.dart
MISURA: taglio dell'immagine in alto da 290 a 418 pixel; distanza fra la cima della testa e la barra scesa di 67 punti a 360 di larghezza (128 pixel per 360/688), da 0 a 12 punti dopo

## VOCE FL.13

**CHIUSA.** Il bagliore della carta chiave stretto, uguale sui quattro lati.

DOMANDA: "Ottimo lavoro, devi solo migliorare il bagliore della carta chiave" e "Il bagliore, dovrebbe essere meno esteso e uscire dai 4 lati della carta chiave"
PROVA: docs/preview/FL/fl_sequenza_5_in_piedi.png
MISURA: luce oltre la carta, sinistra, cima, destra e fondo, da 40, 0, 40 e 46 punti (un'ellisse tenue sotto la carta, poi una pozza che copriva la scritta) a 14, 14, 14 e 14; lati da cui la luce esce da 1 a 4

## VOCE FL.14

**CHIUSA.** Le altre stese e gli altri due mazzi sul tavolo nuovo.

DOMANDA: "Ricordati che devi fare anche le altre tipologie di stese e consono da inserire anche gli altri 2 mazzi, se non lo hai già fatto"
PROVA: docs/preview/FL/fl_tre_mazzi_croce.png
MISURA: stese aperte disegnate sul tavolo nuovo 3 su 3 (una carta, tre carte, croce; la Croce Celtica resta chiusa per decisione del fondatore nell'ordine FK); mazzi disegnati sul tavolo da 1 (il Rider-Waite fisso, difetto mio) a 3 (Rider-Waite, Marsiglia, Thoth), catture 9 su 9 in docs/preview/FL/fl_mazzo_*

## VOCE FL.15

**CHIUSA.** Il tappetino blu di Medora al posto del rosso.

DOMANDA: "ho rigenerato lo sfondo con il tappetino blu di Medora anziché il rosso e te lo Allego. È da sostituire a quello attuale."
PROVA: assets/img/tavolo/tavolo_medora_v2.webp
MISURA: sfondi del tavolo da tavolo_medora_v1 (rosso) a tavolo_medora_v2 (blu), stessa misura 688 per 1536; angoli del velluto, bordo ricamato e medaglione spostati 0 pixel, quindi la geometria del tavolo cambiata 0
