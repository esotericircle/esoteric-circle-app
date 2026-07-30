# ESITO 1: LA SUITE TORNA VERDE, E IL SUONO SI FERMA

## La stima, scritta prima di toccare il codice

### Voce 1, l'overflow della striscia

**Piena.** La diagnosi e' gia' fatta e non la rifaccio: `daily_strip.dart`
attorno alla riga 671, altezza fissa contro un'etichetta che a 360 punti occupa
due righe. Le due strade rientrate non le ripeto.

**La strada che scelgo, motivata in una riga**: l'etichetta sta su una riga
sola, perche' la striscia e' una fascia di icone e alzarla mangerebbe lo spazio
dell'eroe, che a 797 punti di altezza e' gia' stretto.

**Il rischio vero non e' l'overflow, e' la sbirciatura.** Le due cose vivono
nello stesso posto: la larghezza di ogni elemento decide sia se l'etichetta va a
capo sia quanti elementi entrano nello schermo. Stringere per far entrare
l'etichetta su una riga potrebbe far entrare anche il quarto dono per intero,
che sarebbe l'errore opposto. La quantita' visibile va fissata come dato, non
lasciata al caso.

### Voce 2, il suono che non si ferma

**Piena, e le tre cause sono davvero tre.** La piu' grave e' la B: in tutto
`lib/` non esiste un solo osservatore del ciclo di vita, quindi non e' che
l'audio si fermi male, e' che nessuno gli dice mai di fermarsi.

**Dove metto il governo**: nel guscio dell'app, in un punto solo, non nella
Meditazione. Le porte sono tutte le schermate che suonano, oggi due e domani
dieci.

**Sulla causa C dichiaro adesso quale delle due strade prendo**: rendo vera la
dichiarazione, cioe' un motore solo condiviso, invece di ammorbidire il commento.
Un commento che mente e' peggio di un difetto, perche' chi legge smette di
verificare.

**Nota che mi riguarda.** Tutte e tre nascono dalla stessa modifica, S1, quando
il lettore reale e' diventato il predefinito. La stessa modifica ha rotto in
silenzio due catture di anteprima. La lezione la scrivo qui perche' valga:
quando cambia un predefinito, si cerca chi altro passa da quella strada prima di
chiudere.

### Cosa non faccio

Non prendo altre voci. Se finisco in anticipo consegno e mi fermo.

## Stato voce per voce

Si compila mentre il lavoro procede.
