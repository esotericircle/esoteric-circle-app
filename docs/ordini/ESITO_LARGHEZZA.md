# ESITO dell'ORDINE: LA LARGHEZZA GIUSTA, POI LE QUATTRO VOCI

## La stima, scritta prima di toccare il codice

### La misura reale, e da dove la ricavo

Il telefono di Mauro riporta **1080 per 2392 pixel fisici**. Il rapporto di
pixel di quella classe di dispositivi e' **3**, quindi la dimensione logica e'

    1080 / 3 = 360 punti di larghezza
    2392 / 3 = 797,33 punti di altezza

**Uso 360 per 797.** Il numero che conta e' il primo: le anteprime finora sono
state generate a **390** punti di larghezza, cioe' trenta punti logici in piu',
novanta pixel fisici. Verificato sul file delle catture: `schermoAlto` vale
`Size(390, 844)` e `schermoBasso` vale `Size(390, 797)`. La variante che
chiamavo "2392" aveva quindi l'altezza giusta e la larghezza sbagliata, ed e'
esattamente quello che l'ordine contesta.

Su trenta punti in meno il testo va a capo prima, i titoli si spezzano, le
etichette si troncano e le bolle crescono in altezza perche' occupano due righe
invece di una. E' l'elenco dei difetti segnalati.

**L'ipotesi della scala 1,6 e' archiviata come sbagliata.** Le impostazioni di
Mauro sono testo Predefinito e visualizzazione Standard, entrambi di fabbrica.
Il difetto che nel giro precedente avevo riprodotto ingrandendo il testo era
reale, ma la sua causa nel mondo vero e' un'altra, ed era la larghezza.

### La stima voce per voce

- **W1 piena, e viene per prima.** Trecentosessanta diventa la prima delle tre
  misure obbligatorie del corredo, non un'aggiunta. Mi aspetto fra i cinque e i
  dieci punti da correggere, e quattro li conosciamo gia'.
- **W2 piena.** La misura differenziale a tre rese esiste gia' e funziona: va
  rifatta alla larghezza reale. Se il difetto si riproduce li' senza toccare la
  scala del testo, la questione delle cinque segnalazioni irriproducibili si
  chiude, e lo diro' chiaramente.
- **W3 piena.** Una transizione sola, l'Hero sulla carta centrale.
- **W4 piena, col rischio piu' alto.** Quarta stesura dopo quattro bocciature.
- **W5 piena.** Un componente solo, portato ovunque.
- **W6 piena nel codice, col giudizio a Mauro**, che e' l'unico ad avere un
  telefono.

**Se il tempo stringe** riduco W6 e W3, mai W1 e W2. La consegna si fa in ogni
caso, perche' Mauro non vede una build nuova da due giri.

## Stato voce per voce

Si compila mentre il lavoro procede.
