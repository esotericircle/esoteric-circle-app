# Oracolo degli Angeli, autoverifica dopo la cura (ordine GA voce GA.06)

Fonte riletta: `docs/collaudo/GA/lettori_ciechi/oracolo.json`, rigenerato con `GA06_SCRIVI=1 flutter test test/ga06_campioni_per_i_lettori_ciechi_test.dart` (seme 606, 40 responsi senza modello, stesse domande, stesse nascite e stesse carte del campione letto dal lettore cieco). Rilettura di Code, che ha scritto la cura: non vale come lettura cieca, che resta da rifare con un lettore indipendente.

Le tre domande: (1) la prima frase risponde alla domanda? (2) il "Cosa fare" dice un'azione concreta pertinente alla domanda? (3) e' coerente con gli angeli usciti e con la domanda?

## Che cosa e' cambiato, in breve

Il responso principale senza modello (assaggio del Viandante e ripiego) non e' piu' la carta del Custode copiata: lo compone `LaRispostaDaiDoni` (`lib/core/oracolo_angeli/la_risposta_dai_doni.dart`). La domanda si legge (forma, limite su salute, legge e denaro, la cosa e la persona di cui parla, l'azione pesata); la prima frase risponde alla forma della domanda e nomina l'angelo del Custode con la sua via o il suo dono; la seconda frase porta il Cuore e l'Intelletto coi loro doni documentati (dal nucleo dello schedario, `docs/corpus/oracolo_angeli/doni.md`); il "Cosa fare" e' un gesto scritto per quella forma di domanda e nomina la cosa o la persona della domanda.

## Un responso per riga

| id | domanda | 1 | 2 | 3 | note |
|---|---|---|---|---|---|
| 1 | Dimmi qualcosa. | si | si | si | domanda aperta riconosciuta; invito a precisare |
| 2 | Posso fidarmi del mio compagno? | si | si | debole | la fiducia si misura sui gesti; la via di Ieiaiel (costruire qualcosa che regga) sta larga sulla fiducia |
| 3 | Come posso ritrovare l'intesa con mio marito? | si | si | si | via del perdono di Haziel |
| 4 | Devo lasciare il lavoro per tornare a studiare? | si | si | debole | sì con la condizione di Lecabel (curare i dettagli senza perdere l'insieme): pertinente ma generica |
| 5 | Arriverà presto la risposta che aspetto? | si | si | si | "se e quando arriva non è scritto"; sopportare di non capire subito |
| 6 | Devo chiudere l'amicizia con Giulia? | si | si | si | condizione di Mikael: guardare le cose come stanno |
| 7 | Andrà tutto bene? | si | si | si | trabocchetto riconosciuto: nessuna carta lo promette |
| 8 | Devo dirle che sono innamorato di lei? | si | si | si | "dirle come stanno le cose" con la condizione del confine chiaro |
| 9 | Passerò l'esame di stato a dicembre? | si | si | si | esito non scritto; gesto sull'esame di stato |
| 10 | Cosa prova davvero Marco per me? | si | si | si | lo può dire solo Marco; gesto: guardare i gesti, chiedere a lui |
| 11 | Incontrerò qualcuno di importante quest'anno? | si | si | debole | la via di Cahethel (la fatica dietro ciò che hai) sta larga sull'incontro |
| 12 | Devo lasciare Roma, e se lo faccio la mia famiglia capirà? | si | si | si | doppia riconosciuta: risponde alla prima, rimanda la seconda |
| 13 | Devo trasferirmi a Milano o restare a Bari? | si | si | si | nomina le due strade; criterio di Veualiah |
| 14 | Ha senso riprovarci con la mia ex? | si | si | si | condizione di Habuhiah: dare senza aspettare riconoscimento |
| 15 | Devo accettare l'offerta della nuova azienda? | si | si | si | condizione di Mikael; gesto che nomina l'offerta |
| 16 | Che cosa mi aspetta? | si | si | si | trabocchetto riconosciuto: non è scritto |
| 17 | Lui mi ama ancora e troverò lavoro entro Natale? | si | si | si | doppia riconosciuta |
| 18 | Come posso fare pace con mia sorella? | si | si | si | gesto verso la sorella, non più il "no gentile" (D7) |
| 19 | L'operazione al ginocchio andrà bene? | si | si | si | limite di salute nella prima frase, rimando al medico |
| 20 | Vincerò la causa contro il mio ex socio? | si | si | si | limite legale nella prima frase, rimando all'avvocato |
| 21 | Conviene investire i miei risparmi in borsa adesso? | si | si | si | limite del denaro, rimando al consulente finanziario |
| 22 | Il colloquio di giovedì andrà bene? | si | si | si | esito non scritto; gesto sul colloquio |
| 23 | Il progetto che ho presentato verrà approvato? | si | si | si | |
| 24 | Quando finirà questo periodo di stallo? | si | si | si | nessuna data; gesto sul passo che dipende da te |
| 25 | Come affronto il pranzo di Natale con la famiglia di lui? | si | si | si | gesto: preparare il pranzo per iscritto |
| 26 | Mio figlio sta attraversando un periodo difficile, come lo aiuto? | si | si | si | "Per aiutare tuo figlio" |
| 27 | È il momento giusto per aprire la mia attività? | si | si | si | |
| 28 | È giusto andare a vivere lontano dai miei genitori? | si | si | si | |
| 29 | Lui tornerà da me dopo quello che è successo? | si | si | si | non si legge, dipende da lui; gesto: scrivere per sé, non a lui (D8) |
| 30 | Compro casa adesso o aspetto un anno? | si | si | debole | nomina le due strade; il criterio di Habuhiah (dare senza contare) sta largo sulla casa |
| 31 | Riuscirò a ottenere la promozione che aspetto? | si | si | si | |
| 32 | Quale strada scelgo tra i due corsi di laurea? | si | si | si | criterio di Caliel: fatti e opinioni |
| 33 | Come gestisco il conflitto con il mio capo? | si | si | si | |
| 34 | Il cambiamento che sento arrivare sarà positivo? | si | si | si | |
| 35 | La mia relazione può durare nonostante la distanza? | si | si | si | |
| 36 | Dimmi qualcosa. | si | si | si | |
| 37 | Posso fidarmi del mio compagno? | si | si | si | via di Mitzrael: riparare con pazienza |
| 38 | Come posso ritrovare l'intesa con mio marito? | si | si | si | |
| 39 | Devo lasciare il lavoro per tornare a studiare? | si | si | si | |
| 40 | Arriverà presto la risposta che aspetto? | si | si | si | |

"Debole" vuol dire: il dono o la via dell'angelo uscito e' applicato alla domanda come criterio, ma il legame si sente largo. Senza modello l'angelo e' quello che esce, e la cura non lo cambia: il responso lo dice come criterio o condizione, non come un fatto.

## Conti, prima e dopo

| misura | prima (lettore cieco) | dopo (questa rilettura e il file) |
|---|---|---|
| (1) la prima frase risponde | 6 su 40 | 40 su 40 |
| (2) il "Cosa fare" e' un'azione concreta | 40 su 40 | 40 su 40, scritto per la forma della domanda; nomina la cosa, la persona o le strade dove la domanda le dice |
| (3) coerente con gli angeli e la domanda | 6 su 40 | 36 su 40 (4 deboli: 2, 4, 11, 30) |
| principale uguale alla carta del Custode (D1) | 40 su 40 | 0 su 40 |
| Cuore e Intelletto nel principale (D1) | 0 su 40 | Cuore 40 su 40, Intelletto 35 su 35 scoperte (le 5 coperte non hanno un angelo da nominare) |
| testi principali distinti (D2) | 29 su 40 (8 gruppi uguali) | 40 su 40; "Cosa fare" 40 su 40 distinti |
| titoli diversi (D3) | 6 titoli fissi per 40 responsi | 38 titoli su 40 (i due ripetuti stanno sotto la stessa domanda: 2 e 37, 5 e 40) |
| angelo nominato nella prima frase (D5) | 22 su 40 | 40 su 40 |
| "Nella mia lettura" in apertura (D5) | 15 | 0 |
| trabocchetti riconosciuti (D6) | 2 su 9 | 9 su 9 (vaghe 4, doppie 2, salute, legge, denaro col loro rimando) |
| consiglio contrario alla domanda (D7) | 1 | 0 |
| consiglio rischioso nel contesto (D8) | 1 | 0 |
| carte singole con "la tua domanda" (D9) | 2 nel campione, 5 nel corpus | 0 e 0 |
| carte singole con "dove pesa / dove scalda" (D9) | 5 nel campione, 41 testi nel corpus | 0 nel campione, 7 nel corpus (tetto 8) |

## Fuori dal campione

Le guardie leggono anche 23 domande che il campione non contiene (`fuoriCampione` in `test/l_oracolo_risponde_dai_doni_test.dart`): 23 su 23 lette nella forma e col limite attesi. Sulla misura: 48.720 responsi composti (tutte le domande, tutti i 72 custodi, i doni piu' lunghi e piu' corti, tre carte, carta coperta, assaggio) hanno 0 difetti di forma, di confine, di genere, di parole vietate.

## Che cosa resta, e perche'

- Il legame fra il dono dell'angelo e la domanda e' a volte largo (4 su 40): senza modello non si sceglie l'angelo, si sceglie solo come dirlo. Col modello (l'Iniziato in su) la risposta la scrive Medora sulle tre carte.
- La frase dei ruoli ha sempre la stessa struttura ("Nel Cuore ... ; nell'Intelletto ..."): e' una scelta di chiarezza, ma un lettore attento la sente ripetersi da un responso all'altro.
- Le carte singole hanno ancora messaggi legati al nucleo dell'angelo e non alla domanda: e' il loro disegno (la carta vale sotto ogni domanda); ne sono stati riscritti 50 (i legami finti, la formula, i testi criptici, il futuro dato per certo, Menadel e Iehuiah che davano per scontato un lavoro).

## Seconda cura, ultimo giro, 21 ottobre 2026: APERTA IN ATTESA DI LETTURA INDIPENDENTE

Fonte riletta: lo stesso `oracolo.json`, rigenerato dopo la seconda cura (seme 606, stesse domande, nascite e carte). Rilettura di Code, che ha scritto la cura: non vale come lettura cieca. La lettura indipendente la fa il coordinatore.

Che cosa e' cambiato dalla prima cura:

- Il responso non incolla piu' il dono sulla domanda: porta frasi SCRITTE per ogni angelo e ogni famiglia di domanda (`docs/corpus/oracolo_angeli/letture.md`, 1656 testi, 23 campi per angelo: otto del Custode, cinque gruppi per il Cuore, l'Intelletto e il gesto), guardate dallo strumento `tool/il_corpus_dell_oracolo.py` (nome dell'angelo in testa, misure, tetto degli attacchi, cuciture, decisione col sì e col no, decisione che non gira in tondo).
- La frase dei ruoli si apre con la situazione della domanda ("Mentre aspetti, nel Cuore, ...", "Davanti a questa scelta, ...", "In questo rapporto, ...", "Per riuscirci, ...", "Mentre ti prepari, ...", "In questa situazione, ..."): 34 responsi su 40 nel campione, 3695 su 4176 (88,5 per cento) nella guardia.
- Gli esiti hanno passi propri per esame e concorso, colloquio, progetto, relazione a distanza, promozione, incontro; le domande vaghe invitano a rifare la domanda nominando la situazione; il rimando della seconda domanda sta sempre in testa al "Cosa fare"; casa e attività sono riconosciute come denaro; il "Da dove viene" non nomina piu' la data di nascita fra le fonti dell'Intelletto.
- Le quattro decisioni che giravano in tondo (Caliel, Lecabel, Mikael, Mebahiah) hanno una condizione verificabile.

| misura | lettore indipendente sul campione precedente | questa rilettura di Code |
|---|---|---|
| (1) la prima frase risponde | 35 su 40 | 40 su 40 |
| (2) il "Cosa fare" e' un'azione concreta pertinente | 30 su 40 | 37 su 40 (deboli: 7, 9 e 22, dove il gesto dell'angelo sta largo sulla domanda) |
| (3) coerente con gli angeli e la domanda | 14 su 40 | 32 su 40 (deboli: 2, 9, 12, 14, 15, 22, 26, 29) |
| trabocchetti riconosciuti | 9 su 9 | 9 su 9 |
| testi principali distinti (D2) | | 40 su 40 |

Il lettore indipendente aveva letto il campione prima delle ultime cure del compositore e della cornice: i due numeri non stanno sullo stesso file. La rilettura di Code e' quella di chi ha scritto, e per questo la voce resta APERTA IN ATTESA DI LETTURA INDIPENDENTE.

Che cosa resta, e perche':

- Le frasi del Cuore e dell'Intelletto sono scritte per gruppo di domande, non per la singola domanda: la cornice le dice sulla situazione, ma il dono resta quello dell'angelo uscito, e a volte sta largo (Menadel e la "fierezza di crescere impegnandoti" sotto un'ex, Habuhiah e la "gioia di dare senza conti" sotto "Lui tornerà?").
- Il sì condizionato della decisione ha sempre la stessa forma ("sì se ...; altrimenti aspetta"): e' la forma dichiarata della risposta senza modello, che non sceglie al posto della persona.
- Il gesto dell'angelo sotto le domande d'esito di una prova a volte non riguarda la prova (la pausa prima di rispondere a un messaggio, sotto l'esame di stato).

## Riapertura di GA.06 per l'Oracolo, 21 ottobre 2026: APERTA IN ATTESA DI LETTURA INDIPENDENTE

Il fondatore: "Le risposte vanno curate, sono la parte più importante e criticata dell'app." Ultima lettura cieca indipendente (12 consultazioni): D1 10 su 12, D2 11 su 12, D3 9 su 12, tre sì 7 su 12. Sul Realme (gruppo A, D2, gravità 3) una domanda di sintomi con una scelta di vita, senza la parola salute, riceveva un orientamento generico senza il medico.

Che cosa è cambiato, difetto per difetto e col suo padre (docs/collaudo/GA/ga06_cure_oracolo_regola_a_e_b.txt):

- **Domande miste** (sintomo più scelta). La lettura riconosce "e poi non so se", ", devo", la chiusa "Che cosa devo fare?"; il sintomo è nominato ("Sul mal di testa risponde il tuo medico"); il rimando della scelta dice di parlarne con una persona di fiducia e di fare un'altra consultazione, dopo il medico; nessun testo dice di fare da soli o di nascosto (guardia A11). Padre: 312a2f1d (il vocabolario della salute), 8ba00294 (i sintomi di tutti i giorni).
- **Il verdetto sibillino (oracolo-28, 32).** Sotto una decisione o una scelta le carte dichiarano di dare un criterio ("le carte danno un criterio, non un nome") e la frase dell'angelo è quel criterio; sei condizioni vaghe sono riscritte con una cosa che la persona può verificare (Mebahiah, Nithael, Poyel, Reiiel, Mebahel, Vasariah). Padre: la seconda cura (letture scritte, 21 ottobre).
- **Il conflitto inventato (oracolo-2, 17, 37).** Le domande su che cosa prova, se torna, se ci si può fidare di un'altra persona hanno il loro gruppo di frasi (altrui, 216 testi: i due terzi portati dal gruppo dei legami, una cinquantina riscritte) senza disaccordi, paci, rancori, torti, colpe (guardia A9). Padre: la seconda cura, gruppo legami scritto per tutte le domande sull'altra persona.
- **La cornice "nel Cuore ... nell'Intelletto" uguale** in 9-10 consultazioni su 12: tre forme che ruotano con la domanda e con gli angeli, e la situazione della domanda davanti (87,4 per cento sulle domande senza limite).
- **Frasi ripetute**: tre aperture e titoli per ogni forma, quattro passi per la fiducia e i sentimenti, chiuse che non ripetono una parola già detta (il filtro dell'eco); la stessa domanda su carte vicine ha titolo, primo passo e chiusa uguali in 2 coppie su 2130 (0,1 per cento; prima 33).
- **Un "come" senza tensione** (aiutare, stare vicino, smettere di pensare a lui, ritrovare serenità) non legge più le frasi del conflitto.
- **Le prove da preparare** (esame, concorso, colloquio) leggono le frasi dell'attesa: sotto l'esame di stato non c'è più "prima di rispondere al prossimo messaggio che ti agita".
- **Le carte singole**: 11 testi che dicevano la vita di chi legge come un fatto ("Nostalgia di volti, di serate", "la stessa severità che un tempo hai ricevuto", "la contabilità dei torti: lo conosci bene", "Non raccontare il piano a chi potrebbe frenarti") sono riscritti con un "se" (guardia A10).
- **Frasi pulite**: "con chi riguarda" diventa "con la persona interessata"; "riconosci in te la fatica che è costato" diventa "a ciò che ti ha fatto sentire"; "Ieliel ti insegna: un disaccordo..." e le altre 21 frasi coi due punti passano a "che"; "Per oggi, l'orientamento è questo." è tolto.

Rilettura severa di Code, una per una, delle 40 consultazioni del campione rigenerato e di 18 domande nuove con carte diverse (mal di schiena, madre malata, ansia e lavoro, Luca, Roma e Torino, ...). Sulle 12 del lettore:

| id | domanda | 1 | 2 | 3 | note |
|---|---|---|---|---|---|
| 1 | Dimmi qualcosa. | sì | sì | sì | |
| 2 | Posso fidarmi del mio compagno? | sì | sì | sì | Habuhiah ("dare senza conti") largo sulla fiducia |
| 5 | Arriverà presto la risposta che aspetto? | sì | sì | sì | |
| 10 | Cosa prova davvero Marco per me? | sì | sì | sì | |
| 12 | Devo lasciare Roma, e se lo faccio la mia famiglia capirà? | sì | sì | sì | |
| 15 | Devo accettare l'offerta della nuova azienda? | sì | sì | sì | |
| 17 | Lui mi ama ancora e troverò lavoro entro Natale? | sì | sì | sì | il rimando dice "senza aspettarti una data" |
| 20 | Vincerò la causa contro il mio ex socio? | sì | sì | sì | |
| 24 | Quando finirà questo periodo di stallo? | sì | sì | sì | |
| 28 | È giusto andare a vivere lontano dai miei genitori? | sì | sì | sì | criterio: immaginare i giorni ordinari dopo la scelta |
| 32 | Quale strada scelgo tra i due corsi di laurea? | sì | sì | sì | "le carte danno un criterio, non un nome" |
| 37 | Posso fidarmi del mio compagno? | sì | sì | sì | titolo, passo e chiusa diversi da oracolo-2 |

12 su 12 su ciascuna delle tre domande secondo la mia rilettura: **non vale come lettura cieca**, e le mie autoverifiche sono sempre state più indulgenti dei lettori. La voce resta APERTA IN ATTESA DI LETTURA INDIPENDENTE.

Che cosa resta debole, dichiarato:
- Le frasi del Cuore e dell'Intelletto sono scritte per gruppo di domande, non per la singola domanda: la cornice le dice sulla situazione, ma il dono resta quello dell'angelo uscito (Habuhiah sotto la fiducia, Menadel sotto la scelta, Anauel sotto un figlio in difficoltà).
- Le carte singole restano testi per angelo (216 carte, 1296 testi): la lettura cieca le ha trovate generiche e fuori tema rispetto alla domanda, e nessuna cura senza il modello può farle rispondere alla domanda; ne ho tolto solo i fatti inventati sulla vita di chi legge.
- Il criterio in apertura ("le carte danno un criterio, non un nome") entra nel 25,5 per cento dei responsi di scelta: la frase dell'angelo, lunga fino a 18 parole, lascia posto solo se il paragrafo resta fra 40 e 50 parole; negli altri casi il criterio sta nel titolo e nel "Cosa fare".
- Una domanda con più di due parti, o con un sintomo detto in modo che il vocabolario non conosce, torna all'orientamento generico.
