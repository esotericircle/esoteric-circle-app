# MANIFESTO DELL'ORDINE FJ, IL LATO, I MAZZI, LA FONTE DEI SIGNIFICATI

Testo dell'ordine: `docs/ordini/ORDINE_FJ_TESTO.md`. Rapporto: `docs/ordini/RAPPORTO_ORDINE_FJ.md`.

Le voci da FJ.01 a FJ.29 sono quelle dell'ordine; le otto dell'aggiunta, da FJ.A1 a FJ.A8, sono qui FJ.30-FJ.37, perche' il sigillo dei manifesti legge solo nomi con un numero. Dove l'aggiunta corregge l'ordine, vince l'aggiunta. Una voce CHIUSA porta sotto di se' DOMANDA, PROVA e MISURA.

VOCI_TOTALI: 37
VOCI_CHIUSE: 14
VOCI_APERTE: 8
VOCI_DA_FARE: 15

## VOCE FJ.01

**CHIUSA.** Il file del lato e' arrivato dritto (dal ramo, commit 65fceaae, aggiunta A2).

DOMANDA: "Prima di sostituire, verifica che il file che ricevi abbia esattamente: 78 righe che iniziano con `## `; 156 righe `### dritta` oppure `### capovolta`; 468 righe `- 1: `, `- 2: `, `- 3: ` non vuote; zero righe `- 1:`, `- 2:`, `- 3:` vuote."
PROVA: docs/collaudo/FJ/il_lato_e_il_tool.txt
MISURA: righe di carta 78 su 78, righe di verso 156 su 156, testi pieni da 0 a 468, righe vuote da 468 a 0

## VOCE FJ.02

**CHIUSA.** Il tool non si ferma sul lato, e le quattro correzioni dell'Architetto ci sono.

DOMANDA: "Non prendere per buono questo elenco: rilancia il tool e guarda che non si fermi."
PROVA: docs/collaudo/FJ/il_lato_e_il_tool.txt
MISURA: uscita del tool 0; scheletri da 468 a 936 su 7.956; posizioni con tre varianti da 0 a 1; la parola voce nelle quattro varianti corrette 0 su 4, "sentenza" 0

## VOCE FJ.03

**DA FARE.** La suite intera col lato dentro: si scrive l'esito al commit della Parte 1.

## VOCE FJ.04

**CHIUSA.** Il paragrafo di provenienza non si perde.

DOMANDA: "Verifica che `prepara`, quando rigenera i file della fonte, non lo cancelli. Se lo cancella, lo preserva come fa per quello di `passato.md`, e se quel meccanismo non esiste lo aggiungi."
PROVA: docs/collaudo/FJ/fj_parte1_regola_a.txt
MISURA: file della fonte riscritti da `prepara` quando esistono 0 (crea solo i mancanti); posizioni con testi senza paragrafo di provenienza 0 su 4, e la prova FJ.4 nuova cade togliendolo dal lato e dal passato, 2 innesti su 2

## VOCE FJ.05

**APERTA IN ATTESA DI VERIFICA.** La rotazione sulle tre varianti vere del lato e' provata nella catena dell'app (docs/collaudo/FJ/rotazione_del_lato.txt: La Torre dritta e capovolta, tre uscite e tre testi diversi, alla quarta il primo) e la stesa riaperta nello stesso giorno non conta (la prova FI.18 dall'avvio vero). **A video non si puo' vedere**: il lato sta solo nella croce di Dora, che resta chiusa (FJ.07). Si guarda quando la croce si apre, o quando passato, presente e futuro hanno le varianti 2 e 3.

## VOCE FJ.06

**CHIUSA.** FI.17 aggiornata e lasciata aperta.

DOMANDA: "Diventa: una posizione su diciassette ha tutte e tre le varianti, il LATO; tre hanno la variante 1; tredici aspettano. La voce resta APERTA."
PROVA: docs/ordini/ORDINE_FI_MANIFESTO.md
MISURA: posizioni con tre varianti da 0 a 1, con la sola variante 1 3, in attesa da 14 a 13; FI.17 resta DA FARE

## VOCE FJ.07

**CHIUSA.** Le posizioni che mancano a ogni stesa; la croce di Dora resta chiusa.

DOMANDA: "Scrivi nel manifesto, nella voce che governa l'apertura delle stese nuove, quali posizioni mancano a ciascuna stesa e quante ne ha ciascuna."
PROVA: docs/ordini/ORDINE_FI_MANIFESTO.md
MISURA: stese con l'elenco scritto 5 su 5; stese nuove aperte 0 su 4, la croce di Dora compresa

Una stesa si apre quando tutte le sue posizioni hanno la fonte (`TarotSpreadType.disponibile`, aggiunta A6 dell'ordine FI) **e** la schermata la sa stendere (`costruita`, oggi vero solo per la stesa a tre carte). L'elenco sta nella voce FI.17 del manifesto FI ed e' ricopiato qui:

| stesa | carte | posizioni distinte | con la fonte | mancano |
|---|---|---|---|---|
| a una carta | 1 | 1 | nessuna | `cartaSola` |
| a tre carte | 3 | 3 | tutte (variante 1) | nessuna, aperta |
| croce di Dora | 4 | 3 | `lato` | `consultante`, `esito` |
| ferro di cavallo | 7 | 7 | `passato`, `presente`, `futuro` | `consiglio`, `ambiente`, `ostacolo`, `esito` |
| Croce Celtica | 10 | 10 | `passato`, `futuro` | `copre`, `attraversa`, `corona`, `sotto`, `seStesso`, `laCasa`, `speranzeOTimori`, `esito` |

**Un fatto per l'ordine delle ondate**: la prima stesa nuova che si apre col minor numero di testi e' quella a una carta, con una sola ondata (`cartaSola`); la croce di Dora ne vuole due (`consultante` ed `esito`). E nessuna delle quattro si apre con le sole ondate: ognuna vuole anche la sua schermata.

## VOCE FJ.08

**APERTA IN ATTESA DI VERIFICA.** Vincolo rispettato da tutto cio' che quest'ordine ha toccato fin qui (la stesa a tre carte intatta, le stese nuove chiuse e senza ripiego sul verso, nessuna posizione scritta da un modello); si chiude a ordine finito.

## VOCE FJ.09

**DA FARE.** Parte 2, per ultima (aggiunta A7).

## VOCE FJ.10

**CHIUSA.** Le tre misure dei mazzi; il predefinito sta sotto i 40 MB.

DOMANDA: "Se il mazzo predefinito convertito supera i 40 MB, fermati e dimmelo prima di proseguire"
PROVA: docs/collaudo/FJ/peso_dei_mazzi.txt
MISURA: Marsiglia 23.486.770 byte (296.058 per carta), Thoth 24.695.910 (309.128 per carta); il predefinito alla dimensione massima dei master 26.292.806 byte, con le miniature 30,8 MB su 40; l'archivio da 260.267.304 byte a 260.267.304, perche' il predefinito c'e' gia'

## VOCE FJ.11

**CHIUSA.** Il predefinito e' gia' negli asset dell'app, in WebP.

DOMANDA: "Il predefinito e' il mazzo su cui e' costruito tutto il corpus dei tarocchi [...] Va negli asset dell'app, in WebP, alle dimensioni di cui sopra."
PROVA: docs/collaudo/FJ/peso_dei_mazzi.txt
MISURA: carte del Rider-Waite nel binario 79 su 79 (78 e il dorso), in WebP a 853x1280, la dimensione massima dei master; per la carta ingrandita a densita' 3 servirebbero 960x1440, che nessuna sorgente porta

## VOCE FJ.12

**DA FARE.** Parte 2, per ultima (aggiunta A7).

## VOCE FJ.13

**DA FARE.** Parte 2, per ultima. Un fatto da girare all'Architetto: il blocco per piano dei due mazzi esiste gia', voluto dal fondatore con la matrice dell'ordine FI voce 32 (Marsiglia dall'Iniziato, Thoth dall'Adepto); la voce chiede di lasciarli aperti.

## VOCE FJ.14

**DA FARE.** Parte 3.

## VOCE FJ.15

**DA FARE.** Parte 3: la regola fissa di ogni modifica.

## VOCE FJ.16

**DA FARE.** Parte 3.

## VOCE FJ.17

**DA FARE.** Parte 3.

## VOCE FJ.18

**DA FARE.** Parte 3.

## VOCE FJ.19

**DA FARE.** Parte 3.

## VOCE FJ.20

**DA FARE.** Parte 3.

## VOCE FJ.21

**CHIUSA.** Ritirata dall'aggiunta (FJ.A5): non ha una fonte che esista.

DOMANDA: "Non cercare quelle nove collisioni e non ricostruirle."
PROVA: docs/ordini/ORDINE_FJ_TESTO.md
MISURA: collisioni cercate o ricostruite 0 su 9

## VOCE FJ.22

**APERTA IN ATTESA DI VERIFICA.** Vincolo della Parte 3: si chiude quando la Parte 3 e' finita.

## VOCE FJ.23

**CHIUSA.** Il testo della posizione resta fuori dalla richiesta al modello, scritto dove sta la regola.

DOMANDA: "Il testo della posizione resta fuori dalla richiesta al modello. Al modello va il registro dell'argomento, come fai adesso."
PROVA: lib/core/tarot/la_lettura_dal_modello.dart
MISURA: righe di decisione nella sezione della regola (`richiesta`) da 0 a 1, col rimando a FJ.24; testi della posizione nella richiesta 0, e la prova la_stesa_interpreta_davvero cade se entra

## VOCE FJ.24

**CHIUSA.** La condizione per rimisurarla e' scritta accanto alla decisione.

DOMANDA: "La decisione si rivede solo con una misura [...] Si fa col disegno appaiato"
PROVA: lib/core/tarot/la_lettura_dal_modello.dart
MISURA: condizioni di revisione scritte accanto alla regola da 0 a 1 (stesso giro, stesse domande, alla cieca, bilanciate; i nove punti dei giri separati)

## VOCE FJ.25

**CHIUSA.** Nella sezione che governa la regola, non in un addendum.

DOMANDA: "La decisione FJ.23 va dove sta la regola di che cosa entra nella richiesta al modello, con la ragione in una riga e il rimando a FJ.24"
PROVA: lib/core/tarot/la_lettura_dal_modello.dart
MISURA: punti dove sta la decisione 1, il commento che accompagna la riga del registro dentro `LaLetturaDellaStesa.richiesta`; addendum 0

## VOCE FJ.26

**APERTA IN ATTESA DI VERIFICA.** Vincolo: controlla3.py non e' nel ramo e non e' usato; si chiude a ordine finito.

## VOCE FJ.27

**APERTA IN ATTESA DI VERIFICA.** Vincolo: nessun gruppo riscritto prima della fonte; si chiude a ordine finito.

## VOCE FJ.28

**APERTA IN ATTESA DI VERIFICA.** Vincolo: nessuna posizione scritta da un modello; si chiude a ordine finito.

## VOCE FJ.29

**APERTA IN ATTESA DI VERIFICA.** Vincolo: nessuna build ordinata; si chiude a ordine finito.

## VOCE FJ.30

**CHIUSA.** (FJ.A1) I tre errori dell'ordine, riscontrati sul ramo.

DOMANDA: "Li dichiaro prima delle correzioni, perche' servono a non fidarti delle fonti che cito senza verificarle."
PROVA: docs/ordini/ORDINE_FJ_TESTO.md
MISURA: fonti citate assenti dal ramo, verificate con git ls-files e git log --all: 3 su 3 (il documento della prova appaiata, carte.json, fonti_delle_stese.md)

## VOCE FJ.31

**CHIUSA.** (FJ.A2) Preso il commit del lato, rilanciato il tool.

DOMANDA: "`python tool/genera_carte_nella_posizione.py`. Non deve fermarsi. Se si ferma, il difetto e' mio: fermati e dichiara la riga esatta che il tool nomina."
PROVA: docs/collaudo/FJ/il_lato_e_il_tool.txt
MISURA: uscita del tool 0, righe nominate 0; conflitti col lavoro non spinto 0

## VOCE FJ.32

**DA FARE.** (FJ.A3) Parte 3, in `lib/core/tarot/tarot_card.dart`, coi nomi intatti.

## VOCE FJ.33

**DA FARE.** (FJ.A4) Parte 3.

## VOCE FJ.34

**CHIUSA.** (FJ.A5) FJ.21 ritirata.

DOMANDA: "La voce FJ.21 dell'ordine FJ, \"le nove collisioni gia' in coda\", si cancella"
PROVA: docs/ordini/ORDINE_FJ_TESTO.md
MISURA: voci ritirate 1 (FJ.21), collisioni ricostruite 0

## VOCE FJ.35

**DA FARE.** (FJ.A6) La guardia sulla fonte dei significati.

## VOCE FJ.36

**APERTA IN ATTESA DI VERIFICA.** (FJ.A7) L'ordine di esecuzione: Parte 1, FJ.10, FJ.23 fatte; poi Parte 3 con la guardia, poi Parte 2. Si chiude a ordine finito.

## VOCE FJ.37

**DA FARE.** (FJ.A8) Il rapporto, coi punti da 1 a 17.
