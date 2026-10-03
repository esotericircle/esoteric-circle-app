# ESITO dell'ORDINE: LE QUATTRO VOCI DEL CERCHIO

## La stima, scritta prima di toccare il codice

Letto `RIPRESA.md`: non rifaccio le tre diagnosi gia' escluse su V1 ne' le voci
chiuse negli ordini precedenti.

- **V1 piena, e la misura differenziale ha un dettaglio che decide tutto.** Se
  rendo la schermata senza la bolla, il layout CAMBIA: l'altezza della zona
  d'ingresso si misura a runtime, quindi togliendo la bolla il carosello scende e
  le due immagini differiscono per intero, non per l'occlusione. La bolla deve
  restare nel layout e sparire solo dal disegno, con `Visibility` che mantiene
  l'ingombro. Senza questo accorgimento la misura differenziale darebbe
  differenze enormi e sempre, che e' un altro modo di essere cieca.
- **V2 piena, col rischio piu' alto.** Quattro bocciature. La prima cosa che
  verifico e' il colore: nel painter c'e' `Colors.white` e a schermo esce oro,
  quindi con ogni probabilita' la mano che si vede non e' quella che ho
  corretto, e allora il difetto e' un altro disegno da qualche altra parte.
- **V3 piena.** Un componente solo, portato in ogni punto, col test che conta chi
  lo usa e denuncia chi adatta al riempimento fuori da esso.
- **V4 piena nel codice, col giudizio a Mauro.** Sfaso, allungo e abbasso
  l'opacita' iniziale, senza toccare l'ampiezza. Se sul telefono resta
  impercettibile lo puo' dire solo lui.

**Ogni test nuovo passa la prova di vista**, e se resta verde col difetto dentro
lo dichiaro invece di chiudere la voce.

## Stato voce per voce

Si compila mentre il lavoro procede.
