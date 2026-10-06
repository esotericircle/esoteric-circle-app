# La regola del giudice della coerenza, ordine FE voce 17

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
