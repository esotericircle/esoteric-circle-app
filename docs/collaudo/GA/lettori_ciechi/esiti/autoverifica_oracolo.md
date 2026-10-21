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
