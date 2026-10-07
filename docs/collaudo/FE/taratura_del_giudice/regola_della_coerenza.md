# La regola del giudice della coerenza, ordini FE voce 17 e FF voce 08

## La regola in vigore, ordine FF voce 08, 7 ottobre 2026

La stessa che riceve il giudice di Gemini nel banco
`tool/banchi_col_modello/il_filo_del_consulto_col_modello_test.dart`, che la
prende da `tool/banchi_col_modello/i_verdetti_del_filo.dart`. Il giudice ha
quattro verdetti e riceve solo le definizioni: non sa che cosa si misura.

```
Leggi un consulto fra una persona e una o più guide spirituali. Le risposte
sono numerate. Per ogni risposta segnata [DA GIUDICARE] dichiari una sola
delle quattro parole, guardando SOLO le risposte delle guide che vengono prima.

CONTRADDICE: afferma il contrario di un consiglio, di un tempo o di un fatto
già dato in una risposta precedente, senza dire apertamente che cambia
parere e perché. Esempio: prima "aspetta la fine del mese", poi "muoviti
subito" senza spiegare il cambio.

CAMBIA_DICHIARANDO: afferma il contrario di un consiglio, di un tempo o di
un fatto già dato, ma lo dice apertamente: dichiara che cambia parere, o che
legge diversamente da un'altra guida, e dice perché. Esempio: "io leggo
diversamente da Medora: non aspettare la fine del mese, perché il tuo
transito è adesso".

IGNORA: la risposta non contraddice, ma risponde come se le risposte
precedenti non esistessero: apre un consiglio nuovo e scollegato, senza
riprendere né sviluppare il punto già dato, anche se la persona sta
continuando lo stesso discorso.

PORTA_AVANTI: riprende il consiglio o il punto già dato (anche con parole
diverse, anche in un solo inciso) e lo sviluppa, lo precisa, lo applica alla
nuova domanda o dice in che cosa concorda, senza affermarne il contrario.

Se la persona cambia discorso di proposito, la risposta su un tema nuovo non
si giudica. Quando la persona torna al primo tema, la risposta si giudica
rispetto alle risposte sul primo tema.

Rispondi SOLO con un array JSON, un oggetto per risposta giudicata:
[{"n": 2, "verdetto": "PORTA_AVANTI", "perche": "una frase"}]
```

## La soglia, ordine FF voce 08.3

**Al piu' due contraddizioni A TRADIMENTO (verdetto CONTRADDICE) per percorso
su dieci risposte giudicate.** Le contraddizioni dichiarate (verdetto
CAMBIA_DICHIARANDO) non sono un difetto: non contano nella soglia e contano
fra le risposte senza difetto nella quota di otto su dieci, che resta.

Il perche': la legge della coerenza (FE.10) dice che un Maestro che cambia
parere lo dichiara e dice perche'. Una contraddizione dichiarata e' un
ripensamento onesto, una a tradimento e' il difetto che la persona sente; il
giudice le contava insieme. La soglia di prima, zero contraddizioni per
percorso, non e' stata mai raggiunta nei 61 giri del filo dell'ordine FE
senza chiamate in piu' (circa due contraddizioni ogni sessanta risposte, qualunque
cura del testo; il rapporto dell'ordine FE, voce 17).

La misura sui giri gia' giudicati, senza chiamare il modello (regola 12
dell'ordine FF): `python tool/le_contraddizioni_dichiarate.py`, uscita in
`docs/collaudo/FF/le_contraddizioni_dichiarate.txt`. Classificazione
deterministica: una CONTRADDICE e' dichiarata se il testo ha una formula di
cambio ("leggo diversamente", "cambio parere", ...) e un perche'. Su 61 giri,
356 percorsi, 3560 risposte giudicate: 137 contraddizioni, 0 dichiarate col
perche', 7 col solo annuncio "Io leggo diversamente da Medora" (tutte frasi
della rete della coerenza, che il giudice di prima gia' doveva contare come
divergenza dichiarata e ha contato come contraddizione perche' non dicevano
il perche'); percorsi oltre due: 4 su 356 con qualunque dei due conti.

## La regola di prima, ordine FE voce 17

Tre verdetti; la divergenza dichiarata contava come PORTA_AVANTI e la soglia
era zero contraddizioni per percorso.

La stessa che riceve il giudice di Gemini nel banco
`tool/banchi_col_modello/il_filo_del_consulto_col_modello_test.dart`.

```
Leggi un consulto fra una persona e una o più guide spirituali. Le risposte
sono numerate. Per ogni risposta segnata [DA GIUDICARE] dichiari una sola
delle tre parole, guardando SOLO le risposte delle guide che vengono prima.

CONTRADDICE: afferma il contrario di un consiglio, di un tempo o di un fatto
già dato in una risposta precedente, senza dire apertamente che cambia
parere e perché. Esempio: prima "aspetta la fine del mese", poi "muoviti
subito" senza spiegare il cambio. Una guida diversa che dice di vedere le
cose in un altro modo e lo dichiara apertamente ("io leggo diversamente")
NON contraddice: diverge dichiarandolo, e conta come PORTA_AVANTI se
riprende il punto prima di divergere.

IGNORA: la risposta non contraddice, ma risponde come se le risposte
precedenti non esistessero: apre un consiglio nuovo e scollegato, senza
riprendere né sviluppare il punto già dato, anche se la persona sta
continuando lo stesso discorso.

PORTA_AVANTI: riprende il consiglio o il punto già dato (anche con parole
diverse, anche in un solo inciso) e lo sviluppa, lo precisa, lo applica alla
nuova domanda o dice in che cosa concorda o diverge.

Se la persona cambia discorso di proposito, la risposta su un tema nuovo non
si giudica. Quando la persona torna al primo tema, la risposta si giudica
rispetto alle risposte sul primo tema.

Rispondi SOLO con un array JSON, un oggetto per risposta giudicata:
[{"n": 2, "verdetto": "PORTA_AVANTI", "perche": "una frase"}]
```
