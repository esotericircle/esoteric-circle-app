# MANIFESTO DELL'ORDINE FJ, IL LATO, I MAZZI, LA FONTE DEI SIGNIFICATI

Testo dell'ordine: `docs/ordini/ORDINE_FJ_TESTO.md`. Rapporto: `docs/ordini/RAPPORTO_ORDINE_FJ.md`.

Le voci da FJ.01 a FJ.29 sono quelle dell'ordine; le otto dell'aggiunta, da FJ.A1 a FJ.A8, sono qui FJ.30-FJ.37; le sei dell'aggiunta 2, da FJ.B1 a FJ.B6, sono FJ.38-FJ.43. Il sigillo dei manifesti legge solo nomi con un numero. Dove un'aggiunta corregge l'ordine, vince l'aggiunta. Una voce CHIUSA porta sotto di se' DOMANDA, PROVA e MISURA.

VOCI_TOTALI: 43
VOCI_CHIUSE: 40
VOCI_APERTE: 3
VOCI_DA_FARE: 0

## VOCE FJ.01

**CHIUSA.** Il file del lato e' arrivato dritto (dal ramo, commit 65fceaae, aggiunta A2).

DOMANDA: "Prima di sostituire, verifica che il file che ricevi abbia esattamente: 78 righe che iniziano con `## `; 156 righe `### dritta` oppure `### capovolta`; 468 righe `- 1: `, `- 2: `, `- 3: ` non vuote; zero righe `- 1:`, `- 2:`, `- 3:` vuote."
PROVA: docs/collaudo/FJ/il_lato_e_il_tool.txt
MISURA: righe di carta 78 su 78, righe di verso 156 su 156, testi pieni da 0 a 468, righe vuote da 468 a 0

## VOCE FJ.02

**CHIUSA.** Il tool non si ferma sul lato, e le quattro correzioni dell'Architetto ci sono.

DOMANDA: "Non prendere per buono questo elenco: rilancia il tool e guarda che non si fermi."
PROVA: docs/collaudo/FJ/il_lato_e_il_tool.txt
MISURA: uscita del tool 0; scheletri da 468 a 936; posizioni con tre varianti da 0 a 1; la parola voce nelle quattro varianti corrette 0 su 4, "sentenza" 0

## VOCE FJ.03

**CHIUSA.** La suite intera col lato dentro.

DOMANDA: "Poi la suite intera, non solo le guardie del corpus: la posizione LATO entra in `lib/core/tarot/le_carte_nella_posizione_dati.dart` e quel file e' letto anche dalla rotazione e dalla lettura di casa."
PROVA: docs/collaudo/FJ/la_suite_finale.txt
MISURA: rossi da 2 (giro 1, due falsi positivi sui testi del lato) e 10 (giro 2, guardie di casa sul codice nuovo) a 1 (giro 3, la registrazione del rapporto, fatta alla consegna); prove passate 7.098

## VOCE FJ.04

**CHIUSA.** Il paragrafo di provenienza non si perde.

DOMANDA: "Verifica che `prepara`, quando rigenera i file della fonte, non lo cancelli. Se lo cancella, lo preserva come fa per quello di `passato.md`, e se quel meccanismo non esiste lo aggiungi."
PROVA: docs/collaudo/FJ/fj_parte1_regola_a.txt
MISURA: file della fonte riscritti da `prepara` quando esistono 0 (crea solo i mancanti); posizioni con testi senza paragrafo di provenienza 0 su 4, e la prova FJ.4 nuova cade togliendolo dal lato e dal passato, 2 innesti su 2

## VOCE FJ.05

**APERTA IN ATTESA DI VERIFICA.** La rotazione sulle tre varianti vere del lato e' provata nella catena dell'app (docs/collaudo/FJ/rotazione_del_lato.txt). **Dall'ordine FK la ragione e' cambiata**: la croce a quattro ha nel Dart la fonte di tutte e tre le sue posizioni (consultante, lato, esito, docs/collaudo/FK/il_dart_e_la_fonte.txt) e le manca soltanto la schermata che la stende (`costruita` falso). A video si vede quando la croce ha il suo tavolo, o quando passato, presente e futuro hanno le varianti 2 e 3.

## VOCE FJ.06

**CHIUSA.** FI.17 aggiornata e lasciata aperta.

DOMANDA: "Diventa: una posizione su diciassette ha tutte e tre le varianti, il LATO; tre hanno la variante 1; tredici aspettano. La voce resta APERTA."
PROVA: docs/ordini/ORDINE_FI_MANIFESTO.md
MISURA: posizioni con tre varianti da 0 a 1, con la sola variante 1 3, in attesa da 14 a 13 e poi a 10 col ferro di cavallo tolto (aggiunta 2); FI.17 resta DA FARE

## VOCE FJ.07

**CHIUSA.** Le posizioni che mancano a ogni stesa; la croce a quattro resta chiusa.

DOMANDA: "Scrivi nel manifesto, nella voce che governa l'apertura delle stese nuove, quali posizioni mancano a ciascuna stesa e quante ne ha ciascuna."
PROVA: docs/ordini/ORDINE_FI_MANIFESTO.md
MISURA: stese con l'elenco scritto 4 su 4; stese nuove aperte 0 su 3, la croce a quattro compresa

Una stesa si apre quando tutte le sue posizioni hanno la fonte (`TarotSpreadType.disponibile`, aggiunta A6 dell'ordine FI) **e** la schermata la sa stendere (`costruita`, oggi vero solo per la stesa a tre carte). Dall'aggiunta 2 le stese sono quattro e le posizioni quattordici:

| stesa | carte | posizioni distinte | con la fonte | mancano |
|---|---|---|---|---|
| a una carta | 1 | 1 | nessuna | `cartaSola` |
| a tre carte | 3 | 3 | tutte (variante 1) | nessuna, aperta |
| croce a quattro | 4 | 3 | `lato` | `consultante`, `esito` |
| Croce Celtica | 10 | 10 | `passato`, `futuro` | `copre`, `attraversa`, `corona`, `sotto`, `seStesso`, `laCasa`, `speranzeOTimori`, `esito` |

**Un fatto per l'ordine delle ondate**: la stesa nuova che si apre col minor numero di testi e' quella a una carta, con una sola ondata (`cartaSola`); la croce a quattro ne vuole due (`consultante` ed `esito`). E nessuna si apre con le sole ondate: ognuna vuole anche la sua schermata, `costruita` oggi e' falso per tutte e tre.

## VOCE FJ.08

**CHIUSA.** Vincolo rispettato fino alla consegna, chiuso dall'ordine FK voce 26.

DOMANDA: "La stesa a tre carte resta aperta e intatta. Le altre stese nuove restano chiuse e non mostrano il testo del verso al posto di quello della posizione. Nessuna delle tredici posizioni ancora vuote va riempita da un modello."
PROVA: docs/ordini/RAPPORTO_ORDINE_FJ.md
MISURA: stese nuove aperte 0 su 3; testi scritti da un modello 0; la stesa a tre carte disponibile prima e dopo

## VOCE FJ.09

**CHIUSA.** Il predefinito nel binario, gli altri mazzi sul bucket.

DOMANDA: "Il mazzo predefinito dentro l'app. Gli altri mazzi sul bucket dietro CDN, con cache permanente sul dispositivo."
PROVA: docs/collaudo/FJ/il_bucket_dei_mazzi.txt
MISURA: mazzi nel binario 1 (il Rider-Waite, gia' c'era); mazzi sul bucket da 0 a 2 (Marsiglia 158 file, Thoth 158 file, piu' il manifest), letti dal manifest pubblicato; Cloud CDN davanti al bucket: non c'e' (domanda girata, vedi il rapporto)

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

**APERTA IN ATTESA DI VERIFICA.** Prodotto e agganciato (servizio, manifest e file sul bucket, dialogo, carta col suo mazzo). Manca lo sguardo sul telefono, e dall'ordine FK il fondatore ha detto quando: "la Build quando ci saranno tutti i corpus di ogni posizione" (FK.33). I due punti da guardare restano: il download vero di un mazzo e i nomi lunghi del Marsiglia su due righe nella targa stretta (docs/preview/prima_dopo/fj_i_tre_mazzi_dopo.png). Il fondatore ha deciso anche di tenere i due mazzi fuori dall'APK (FK.31) e di non mettere Cloud CDN ne' R2 per ora (FK.32).

## VOCE FJ.13

**CHIUSA.** Il blocco per piano dei mazzi resta quello della matrice, per decisione del fondatore (ordine FK voce 30).

DOMANDA: "1 va bene la matrice attuale con limitazioni."
PROVA: docs/ordini/ORDINE_FK_TESTO.md
MISURA: mazzi con il blocco della matrice FI voce 32 2 su 2 (Marsiglia dall'Iniziato, Thoth dall'Adepto), prima e dopo; prezzo in Eos per chi non ha il piano: non deciso, nessuno inventato

## VOCE FJ.14

**CHIUSA.** La ragione della Parte 3, misurata sulla fonte di casa.

DOMANDA: "nessun testo puo' aggirare il difetto, perche' il difetto e' nel significato. Si corregge `carte.json`."
PROVA: docs/collaudo/FJ/correzioni_della_fonte.md
MISURA: voci corrette in `lib/core/tarot/tarot_card.dart` (la fonte vera, aggiunta A3) da 0 a 26 su 22 carte-verso e 20 carte (il "21" di prima era un errore di conto, ordine FK voce 25); nomi di carte toccati 0

## VOCE FJ.15

**CHIUSA.** La regola fissa: ogni modifica verificata contro le gemelle, e scritta.

DOMANDA: "Ogni modifica va scritta nel rapporto con: la carta, il verso, la frase prima, la frase dopo, la gemella contro cui l'hai verificata."
PROVA: docs/collaudo/FJ/correzioni_della_fonte.md
MISURA: modifiche con carta, verso, prima, dopo e gemelle scritte 26 su 26; frasi tolte sostituite con una parafrasi 0

## VOCE FJ.16

**APERTA IN ATTESA DI VERIFICA.** Le tredici collisioni di FJ.16 sono corrette nella fonte, e dall'ordine FK anche le nuove di FK.17 e FK.18 (L'Imperatrice e la Regina di Denari, il Sole e la Regina di Bastoni) e le tre voci senza cardine di FK.19 (docs/collaudo/FK/correzioni_della_fonte.md). La ragione resta la stessa: le collisioni di sinonimi le verifica solo un lettore che riconosce la carta senza il nome, cioe' la prossima prova appaiata dell'Architetto.

## VOCE FJ.17

**CHIUSA.** Le sei frasi che giudicano o comandano.

DOMANDA: "Si riscrivono come constatazione, non come consiglio."
PROVA: docs/collaudo/FJ/correzioni_della_fonte.md
MISURA: frasi di giudizio o di comando nominate dalla voce ancora nella fonte da 6 a 0 (due tolte, tre riscritte come constatazione, una tolta con la sua voce riscritta, la Giustizia capovolta)

## VOCE FJ.18

**CHIUSA.** I cinque confini porosi fra i due versi.

DOMANDA: "I cinque confini porosi fra i due versi della stessa carta"
PROVA: docs/collaudo/FJ/la_fonte_prima_e_dopo.txt
MISURA: coppie dritto e capovolto della stessa carta sopra 5,0 sulle radici rare in comune da 4 su 5 (massimo 17,47) a 0 su 5 (massimo 4,36)

## VOCE FJ.19

**CHIUSA.** Delle due massime cade quella del Tre di Bastoni capovolta.

DOMANDA: "Una delle due massime cade: scegli quale e dichiara la ragione."
PROVA: docs/collaudo/FJ/correzioni_della_fonte.md
MISURA: massime in contraddizione nella fonte da 2 a 1; resta quella del Sette di Denari capovolta, che dice il suo tratto (il raccolto valutato), mentre quella del Tre era proprio il "ritardo" che lo confondeva con l'Otto di Bastoni

## VOCE FJ.20

**CHIUSA.** I due punti vuoti riempiti.

DOMANDA: "Nove di Denari capovolta: \"eccessi\" senza dire di che cosa [...] Fante di Denari dritta: [...] Va riformulata in modo che il tratto resti e la formula no."
PROVA: docs/collaudo/FJ/correzioni_della_fonte.md
MISURA: punti vuoti da 2 a 0 (gli eccessi diventano "spese oltre misura, o il bisogno di mostrare cio' che possiedi"; "un passo studiato dopo l'altro" diventa "cio' che impari diventa concreto man mano che lo metti in pratica")

## VOCE FJ.21

**CHIUSA.** Ritirata dall'aggiunta (FJ.A5): non ha una fonte che esista.

DOMANDA: "Non cercare quelle nove collisioni e non ricostruirle."
PROVA: docs/ordini/ORDINE_FJ_TESTO.md
MISURA: collisioni cercate o ricostruite 0 su 9

## VOCE FJ.22

**CHIUSA.** Toccate solo le carte nominate, nessun testo del lato riscritto.

DOMANDA: "Non si toccano le voci delle carte che non sono nominate qui. [...] Non si riscrivono i 468 testi del LATO"
PROVA: docs/collaudo/FJ/correzioni_della_fonte.md
MISURA: carte-verso toccate fuori da quelle nominate da FJ.16-FJ.20 0; testi del lato riscritti 0 su 468

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

**CHIUSA.** Vincolo rispettato per tutto l'ordine FJ, chiuso a ordine finito dall'ordine FK voce 26.

DOMANDA: "controlla3.py e' il mio metro, non il tuo tool, e non sta nel ramo."
PROVA: docs/ordini/RAPPORTO_ORDINE_FJ.md
MISURA: violazioni del vincolo durante l'ordine FJ 0

## VOCE FJ.27

**CHIUSA.** Vincolo rispettato per tutto l'ordine FJ, chiuso a ordine finito dall'ordine FK voce 26.

DOMANDA: "Prima si corregge la fonte, poi si riscrive."
PROVA: docs/ordini/RAPPORTO_ORDINE_FJ.md
MISURA: violazioni del vincolo durante l'ordine FJ 0

## VOCE FJ.28

**CHIUSA.** Vincolo rispettato per tutto l'ordine FJ, chiuso a ordine finito dall'ordine FK voce 26.

DOMANDA: "Le tredici posizioni ancora vuote e le varianti 2 e 3 di passato, presente e futuro aspettano me. Nessuna di esse va generata."
PROVA: docs/ordini/RAPPORTO_ORDINE_FJ.md
MISURA: violazioni del vincolo durante l'ordine FJ 0

## VOCE FJ.29

**CHIUSA.** Vincolo rispettato per tutto l'ordine FJ, chiuso a ordine finito dall'ordine FK voce 26.

DOMANDA: "La build la ordina lui."
PROVA: docs/ordini/RAPPORTO_ORDINE_FJ.md
MISURA: violazioni del vincolo durante l'ordine FJ 0

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

**CHIUSA.** (FJ.A3) La fonte e' il Dart, e i nomi non si toccano.

DOMANDA: "I nomi non si toccano, solo le quattro voci di significato."
PROVA: docs/collaudo/FJ/correzioni_della_fonte.md
MISURA: nomi di carte cambiati 0 su 78; campi toccati solo fra uprightSummary, upright, reversedSummary e reversed 26 su 26; marche del genere rotte 0 (quella della Giustizia capovolta cade con la frase che la portava, e la voce nuova non da' genere); tool del corpus rilanciato dopo le correzioni, uscita 0

## VOCE FJ.33

**CHIUSA.** (FJ.A4) La Parte 3 eseguita senza il documento, dalle voci dell'ordine.

DOMANDA: "Se una voce ti sembra incompleta senza il documento, fermati su quella voce e nominala"
PROVA: docs/collaudo/FJ/correzioni_della_fonte.md
MISURA: voci della Parte 3 eseguite 5 su 5 (FJ.16-FJ.20); voci incomplete 0; premesse dell'ordine sbagliate sul testo della fonte e segnalate 2 (FJ.16 punto 13, la frase gemella sta nella Regina di Coppe dritta; punto 7, la frase non e' parola per parola)

## VOCE FJ.34

**CHIUSA.** (FJ.A5) FJ.21 ritirata.

DOMANDA: "La voce FJ.21 dell'ordine FJ, \"le nove collisioni gia' in coda\", si cancella"
PROVA: docs/ordini/ORDINE_FJ_TESTO.md
MISURA: voci ritirate 1 (FJ.21), collisioni ricostruite 0

## VOCE FJ.35

**CHIUSA.** (FJ.A6) La grandezza della guardia sulla fonte l'ha decisa Code, ordine FK voce 10.

DOMANDA: "La scelta della grandezza è dell'Architetto: i numeri nel rapporto"
PROVA: test/la_fonte_dei_significati_non_si_confonde_test.dart
MISURA: regole della guardia 3 (radici rare per le coppie note, frase di sei parole, tetto delle altre coppie); coppie note da 28 a 37, con le nove trovate leggendo dall'ordine FK; coppie note sopra 5,0: 0

## VOCE FJ.36

**CHIUSA.** (FJ.A7) L'ordine di esecuzione rispettato fino alla consegna, chiuso dall'ordine FK voce 26.

DOMANDA: "viene prima quello che sblocca il lavoro di altri, poi quello che e' soltanto lungo."
PROVA: docs/ordini/RAPPORTO_ORDINE_FJ.md
MISURA: parti eseguite nell'ordine dell'aggiunta 5 su 5 (Parte 1, FJ.10, FJ.23, Parte 3 con la guardia, Parte 2)

## VOCE FJ.37

**CHIUSA.** (FJ.A8) Il rapporto, coi punti da 1 a 17.

DOMANDA: "Oltre alle tredici voci del rapporto dell'ordine FJ"
PROVA: docs/ordini/RAPPORTO_ORDINE_FJ.md
MISURA: punti del rapporto scritti da 0 a 17 su 17, registrato con tool/i_rapporti_consegnati.py

## VOCE FJ.38

**CHIUSA.** (FJ.B1) Il ferro di cavallo tolto: restano quattro stese.

DOMANDA: "Restano quattro stese: una carta, tre carte, la croce a quattro della cartomante del Cerchio, la Croce Celtica."
PROVA: lib/core/tarot/tarot_spread_type.dart
MISURA: stese da 5 a 4; la prova le_stese_del_cerchio pretende le carte [1, 3, 4, 10]

## VOCE FJ.39

**CHIUSA.** (FJ.B2) La ragione per intero, dove chi cerca la trova.

DOMANDA: "Questa voce esiste perche' fra sei mesi qualcuno chiedera' perche' la stesa e' sparita, e deve trovare la ragione per intero invece di una mezza ragione."
PROVA: lib/core/tarot/tarot_spread_type.dart
MISURA: ragioni scritte nella lapide al posto della stesa 2 su 2 (nessuna fonte per le sette posizioni; Papus documentato ma scartato per la meccanica, con le tre posizioni che vorrebbe)

## VOCE FJ.40

**CHIUSA.** (FJ.B3) Le quattro cose tolte, piu' la riga della matrice dei piani.

DOMANDA: "Prima di togliere le tre posizioni, verifica di persona che nessuna delle quattro stese rimaste le usi."
PROVA: lib/core/tarot/tarot_spread.dart
MISURA: occorrenze di `consiglio`, `ambiente`, `ostacolo` fuori dal ferro di cavallo nel codice 0 (grep su lib, test e tool); posizioni da 17 a 14; file della fonte da 18 a 15; righe della matrice dei piani da 51 a 50 (la riga "Ferro di cavallo, 7 carte", che l'aggiunta non nominava)

## VOCE FJ.41

**CHIUSA.** (FJ.B4) Niente perso.

DOMANDA: "Nessun testo gia' scritto va perso"
PROVA: docs/corpus/tarocchi_posizione/lato.md
MISURA: testi pieni nei tre file tolti 0 su 0 (grep prima di toglierli); scheletri prima e dopo 936 e 936; `esito`, `passato`, `presente`, `futuro` intatte

## VOCE FJ.42

**CHIUSA.** (FJ.B5) Il conto nel manifesto.

DOMANDA: "Le posizioni passano da diciassette a quattordici."
PROVA: docs/ordini/ORDINE_FJ_MANIFESTO.md
MISURA: posizioni 14 (una piena, tre con la variante 1, dieci vuote), scheletri 936 su 6.552; tabella delle stese in FJ.07 e in FI.17 a quattro righe

## VOCE FJ.43

**CHIUSA.** (FJ.B6) Il rapporto dell'aggiunta 2, dentro quello dell'ordine.

DOMANDA: "Se `consiglio`, `ambiente` e `ostacolo` comparivano davvero solo nel ferro di cavallo, e dove le hai trovate."
PROVA: docs/ordini/RAPPORTO_ORDINE_FJ.md
MISURA: punti del rapporto dell'aggiunta 2 scritti da 0 a 4 su 4
