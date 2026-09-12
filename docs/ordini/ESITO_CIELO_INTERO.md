# ESITO: IL CIELO RESTA INTERO, E LA FRASE DICE LA VERITA'

## Voce 1, il cielo dentro lo spazio libero: NON CHIUSA, e dichiaro perche'

### Cosa e' cambiato

Il campo del cielo si componeva su TUTTA l'altezza dello schermo, ignorando la
barra sopra e la scheda sotto: la Luna finiva sotto l'orologio di sistema,
Cancro e Gemelli sotto il vetro della scheda.

Adesso lo spazio libero e' un DATO calcolato, non margini sparsi: altezza dello
schermo meno la barra, meno le aree sicure di sistema, meno la scheda quando e'
aperta, meno la sporgenza dell'etichetta. I corpi si dispongono dentro quello,
con un'animazione che Riduci Movimento toglie lasciando il riposizionamento. La
scheda ha un tetto dichiarato, il 38 per cento dell'altezza, e oltre quello il
testo scorre dentro invece di crescere verso l'alto.

**Una cosa trovata mentre correggevo**: i corpi passavano da un `Transform` che
li traslava DOPO il calcolo, quindi qualunque limite applicato prima non teneva.
Adesso la deriva si somma e poi si taglia dentro il campo.

### La misura, e il residuo col numero

**Verde** alla misura reale, 1080 per 2392, alle 22, per tutti i corpi e per
ciascuno selezionato. **Prova di vista passata**: rimessa la composizione a tutta
altezza, tre casi su sei cadono dicendo quale corpo e quale bordo.

**RESTA UNO SFORAMENTO, e lo scrivo invece di allentare la soglia:**

| Caso | Luna arriva a | Scheda comincia a | Sforamento |
|---|---|---|---|
| 1080x2392, ore 4 | 609 | 566 | 43 punti |
| 1080x2532, ore 4 | 641 | 566 | 75 punti |

Il campo libero e' calcolato giusto e il conto torna a 439, ma fra il calcolo e
il pixel resta una traslazione di circa 202 punti che non ho trovato. La prova
gira sui casi verificati e il numero sta in `RIPRESA.md`: **quello che consegno
e' un miglioramento vero e misurato, non il lavoro finito.**

### Le immagini

- `docs/preview/prima_dopo/cielo_intero_prima.png`
- `docs/preview/prima_dopo/cielo_intero_dopo.png`

Nella prima, con la Luna toccata, GEMELLI e CANCRO sono etichette fantasma sotto
la scheda e la costellazione dei Gemelli e' tagliata a meta' dal bordo. Nella
seconda tutti i corpi stanno sopra la scheda e sotto la barra, con le etichette
leggibili.

### La frase di accettazione

**Apri "Il cielo sopra di te" e tocca la Luna: la Luna e tutte le costellazioni
devono restare intere fra il titolo e la scheda, senza nomi che si leggono in
trasparenza sotto il vetro.**

## Voce 2a, la frase che mente: CHIUSA

Diceva "Orientato sul tuo luogo. La posizione esatta di ogni astro nel cielo
arriva col motore a effemeridi". Era vera quando fu scritta e meta' falsa adesso:
negava in blocco un calcolo che l'app fa davvero.

Riscritta distinguendo le due meta':

> Luna e costellazioni sono calcolate adesso, sul tuo luogo, con la loro altezza
> vera sul tuo orizzonte. Gli altri pianeti non si disegnano qui: stanno nella
> tua carta natale.

E nel cielo di NASCITA al passato, sull'istante di nascita: "con l'altezza che
avevano su quell'orizzonte".

**Vive in un punto solo**, e una prova lo verifica: la schermata del cielo di
nascita e' la stessa classe con `birth` vero, quindi due testi scritti in due
posti sarebbero divergiti al primo cambio.

## Voce 2b, l'etichetta fantasma: SPARITA DA SOLA

L'ordine lo ipotizzava e l'ho verificato invece di darlo per scontato: nella
immagine del dopo non c'e' nessuna etichetta sotto il vetro, perche' nessun
corpo finisce piu' li'. **Non ho toccato altro.**
