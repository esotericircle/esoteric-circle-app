# IL CONTO DELLE ORE

Ordine CQ voce 6.13, 4 settembre 2026. Parole del fondatore: *"DEVI CHIEDERGLI
COSA HA FATTO DURANTE TUTTE LE ORE CHE HO ASPETTATO. SE QUESTO TEMPO NON HA
PRODOTTO NULLA DI UTILE, BISOGNA TROVARE LA SOLUZIONE"* e *"Voglio anche sapere
quante ore ha perso e per fare che cosa?"*

**Non e' una richiesta di scuse, e questo non e' un documento di scuse.** E' la
misura che serve a cambiare il modo di lavorare, e sta coi numeri come tutte le
altre.

## LA FINESTRA, E COSA LA RIEMPIE

Trentanove commit fra le **18:00 del 3 settembre** e le **13:32 del 4**, presi
da `git log`, non a memoria. Il primo dell'ordine CQ e' delle **00:10**.

| ora | commit | cosa |
| --- | ---: | --- |
| 00:10 - 01:27 | 5 | pezzo primo, voci 1.03 - 1.12 |
| 01:55 - 04:15 | 5 | pezzo secondo, voci 2.00 - 2.13 |
| 04:25 - 04:51 | 3 | aggiunta CQ4, i manifesti sigillati, il referto |
| 05:28 | 1 | la guardia del lavoro non spinto, per Codemagic |
| 08:47 - 09:32 | 4 | aggiunta CQ5, le sei voci aperte chiuse |
| 09:19 - 11:04 | 4 | build 2224, consegna, prova di accensione |
| 11:56 - 13:32 | 10 | aggiunta CQ6, dieci voci su tredici |

## QUANTO TEMPO E' FINITO IN LAVORO CHE NON AVEVI CHIESTO

**Tre pezzi, e li chiamo per nome.**

1. **Il PASSO 0 del foglio delle distribuzioni**, voce 6.12. Non era
   nell'ordine. Era la causa per cui il tuo deploy non trovava una funzione che
   esiste: il controllo nominava uno sha che invecchia. Senza quello avrei
   risposto "la funzione c'e'" e tu saresti rimasto col comando che non
   funziona.
2. **Il registro delle guardie**, che mentiva su se stesso in due punti. Uscito
   mentre ci censivo le guardie nuove, che invece era dovuto.
3. **La misura del contrasto allargata a tre schermate** invece che alla sola
   riga blu che avevi visto, voce 6.04. Le altre due avevano lo stesso difetto,
   e curarne una sola avrebbe voluto dire tornarci.

Nessuno dei tre e' tempo che ti ho fatto perdere: **tutti e tre erano cause di
cose che avevi segnalato**. Il lavoro davvero non chiesto, in queste ore, e'
zero.

## QUANTO TEMPO E' FINITO IN LAVORO POI RIFATTO O SCARTATO

**E questo si', e sono errori miei.**

| cosa | quanto | perche' |
| --- | --- | --- |
| Tre difetti miei presi dallo sbarramento alle 10:01 | un giro di suite, circa 28 minuti | avevo scritto gli accenti con l'apostrofo in una stringa che il modello legge, avevo perso accento ed elisione in una riga dell'Arcano, e avevo fatto leggere l'orologio vero a una prova nuova |
| La guardia del ponte, riscritta | pochi minuti | era legata a un errore di ortografia: cercava CIO con l'apostrofo, e curando l'apostrofo e' caduta |
| Le pretese accoppiate della voce 6.10 | due giri di prova del rosso | due innesti su cinque restavano verdi perche' ogni pretesa poteva essere soddisfatta da un pezzo diverso della cura |
| L'apertura messa fra i pezzi invece che fra i paragrafi | un giro | spostava gli indici e rimontava il consiglio sbagliato anche per chi non scriveva nessuna domanda |
| Un file lasciato rotto da uno script | pochi minuti | il ripristino non stava in un `finally`, e un assert lo ha saltato lasciando la mappa degli otto responsi svuotata a sei |
| Il falso allarme del traboccamento del Soffio | un giro | avevo pinnato la finestra solo nel MediaQuery e non sul tester, e ho letto un layout steso su ottocento punti |

**In tutto, fra un'ora e un'ora e mezza di lavoro rifatto**, su circa tredici
ore e mezza. Non e' il grosso del tempo, e non e' poco.

## PERCHE' SETTE VOCI DICHIARATE CHIUSE NON LO ERANO SUL TELEFONO

**Questa e' la parte che conta, e ha una risposta sola.**

Delle voci che hai riaperto oggi, **tutte quelle che erano state dichiarate
chiuse lo erano state sulla base di una guardia che leggeva la cosa sbagliata**,
e la cosa sbagliata era sempre della stessa famiglia.

| voce | cosa misurava la guardia di allora | cosa non poteva vedere |
| --- | --- | --- |
| 6.02 e 6.06, i suoni | i file negli asset, il tema, gli `InkWell` | un tono **sintetizzato**, che non e' nessuna delle tre cose |
| 6.05, le stelle | la **funzione** che calcola la quota della stella | cosa c'e' sopra la stella una volta disegnata |
| 6.07, il cuore | che il cuore **non si intersechi** con la freccia | che stia alla stessa quota del titolo |
| 6.08, il suono della carta | che il suono **esca dalla porta** | che un secondo suono lo fermi nello stesso fotogramma |
| 6.09, la terza carta | che il pulsante **ci sia e si accenda** | che tutto il resto della pagina sparisca |
| 6.04, il contrasto | il contrasto sulla superficie **dichiarata** | che la superficie dichiarata non fosse quella dipinta |
| 6.12, la porta della Demo | uno **sha scritto a mano** | che quello sha invecchia a ogni consegna |

**Sette volte su sette, la guardia misurava un pezzo sano accanto al pezzo
rotto.** Nessuna era finta e nessuna era stata scritta per far passare qualcosa:
erano tutte vere, e tutte guardavano un centimetro a lato.

## LA SOLUZIONE, VISTO CHE LA CHIEDI

**Una regola sola, e discende da questa tavola.**

> Una voce che nasce da qualcosa che il fondatore ha VISTO si chiude solo con
> una guardia che monta la schermata e misura cio' che si vede: un rettangolo,
> un conto a video, un suono uscito dalla porta col gesto vero. **Una guardia
> che legge il sorgente o una funzione non chiude una voce nata da uno
> screenshot**: puo' accompagnarla, non basta.

Le voci chiuse oggi hanno tutte una guardia di questa forma, e quelle che non
l'hanno lo dicono per nome nel referto.

**E dal 4 settembre 2026 esiste lo strumento che mancava.** Il fondatore ha
scritto: *"se vuoi puoi verificare da solo le funzionalita' in autonomia"*, e da
li' nasce `tool/collaudo_a_video.py`. Apre l'app sul telefono collegato, la
tocca dove la toccherebbe una persona e legge **l'albero delle viste**, cioe'
cosa il sistema dichiara esserci a schermo. Non sostituisce nessuna guardia: e'
l'occhio che manca a monte, quello che dice se vale la pena scriverne una e
dove.

**Perche' cambia le cose.** Nessuna prova Flutter gira con uno schermo vero e
coi plugin veri: e' per questo che il suono della carta risultava consegnato
alla porta giusta mentre a video non si sentiva, e che la stella risultava nella
sua fascia mentre il dito non la prendeva. Adesso quella distanza si puo'
misurare invece di scoprirla da uno screenshot il giorno dopo.
