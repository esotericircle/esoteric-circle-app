# ESITO: TRE SLOT FISSI, E LA SCHEDA DICE SOLO QUELLO CHE SERVE

## Cosa ho RIMOSSO

L'ordine chiede l'elenco di cio' che esce, non solo di cio' che entra.

- **La mappatura geometrica di altezza e azimut sullo schermo**, `postoNelCielo`
  e `postoDellaCostellazione`, con il campo orizzontale dichiarato in gradi.
- **La distensione sullo spazio libero**, che rimappava le altezze presenti
  sull'intero campo.
- **La separazione dei dischi**, quella che confrontava ogni corpo con tutti i
  precedenti.
- **La scansione delle etichette** e il margine verticale che la governava.
- **Il metodo `disponi`** per intero, e con lui `conSlot` sul modello del corpo.
- **Dalla scheda**: la narrazione della costellazione, la nota lunga sul motore,
  la riga dell'assaggio, quella del dato registrato, il dato di adesso.

Tolto, non spento: cio' che resta acceso e non serve torna a mordere.

## Cosa resta vivo, e non l'ho toccato

Il calcolo vero di altezza e azimut, che alimenta i numeri della scheda, e la
selezione di quali corpi mostrare.

## I quattro slot

Un DATO dichiarato, in frazione dello spazio libero e non in pixel, uguale per
i due cieli:

| Corpo | Slot |
|---|---|
| Luna | 0,50 e 0,10, in alto al centro |
| Prima costellazione | 0,17 e 0,40, a sinistra |
| Seconda costellazione | 0,50 e 0,66, al centro piu' in basso |
| Terza costellazione | 0,83 e 0,40, a destra |

**I corpi sono anche piu' piccoli**: la Luna da 96 a 78 punti, le costellazioni
da 130 a 104. Con quattro corpi in due file le scatole grandi non stavano nel
campo e finivano una sull'altra, ed e' la stessa causa che avevo dichiarato col
conto nel giro scorso. Adesso c'era il margine per farlo, perche' la scheda si
e' ridotta.

## La scheda

Due sole cose: una riga che dice cos'e' il cielo, e le coordinate del corpo
toccato, che cambiano a ogni tocco.

**Sulla frase, e perche' non e' quella proposta.** Il fondatore aveva proposto
"questa e' la posizione esatta del cielo alla tua nascita". Con gli slot fissi
quella frase sarebbe FALSA, perche' la disposizione a schermo non e' piu' quella
reale, e la trasparenza metodologica vieta di dichiarare cio' che non si fa. La
formulazione dice il vero e non toglie niente: i corpi sono quelli veri,
l'altezza e' quella vera, la disposizione e' per la leggibilita'.

## La misura

Dodici prove, tre misure del corredo per entrambi i cieli: nessun corpo e nessuna
etichetta esce dallo spazio libero, nessun corpo copre un altro, nessuna
etichetta si sovrappone a un'altra, e ogni corpo sta nel suo slot. **Prova di
vista passata**: rimessi gli slot vecchi, quattro cadono.

## Le quattro immagini

- `docs/preview/prima_dopo/cielo_adesso_prima.png` e `cielo_adesso_dopo.png`
- `docs/preview/prima_dopo/cielo_nascita_prima.png` e `cielo_nascita_dopo.png`

## La frase di accettazione

**Apri il cielo di nascita: la Luna sta in alto al centro e le tre costellazioni
sotto, una a sinistra, una al centro piu' in basso, una a destra, tutte
leggibili e nessun nome sovrapposto. Tocca un corpo e la scheda, che e' bassa,
dice quanti gradi e' alto e in che direzione.**
