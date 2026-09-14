# IL TAMBURO DELLA DISCESA, ordini DI voce 09 e DJ voce 10

Qui dentro va **un file solo**: `tamburo_discesa.mp3`. Il nome esatto lo detta
il codice, `IlTamburoDellaDiscesa.percorso` in `lib/core/sensi/catalogo_suoni.dart`.

Il Viaggio dello Sciamano scende dentro un filmato muto: il suono della scena e'
questo tamburo, in un livello suo, che parte con la discesa, batte in ciclo per
tutta la sua durata e **continua a battere anche quando il dito si alza**.
L'immagine si ferma, il tamburo no: la persona capisce che si e' fermata lei e
non il Mondo di Sotto.

| File | Quando suona | Durata | Peso massimo |
|---|---|---|---|
| `tamburo_discesa.mp3` | Per tutta la discesa del Viaggio, in ciclo | da 4 a 12 s, anello senza cucitura | 250 KB |

Le misure che servono perche' suoni giusto:

- **Un tamburo a cornice sciamanico**, battuto con la mazza imbottita: colpi
  pieni e bassi, senza campane, senza voci, senza altri strumenti.
- **Quattro battiti e mezzo al secondo**, regolari, cioe' 270 battiti al
  minuto: e' la cadenza dell'alone che pulsa sotto il dito. Se il file vero
  battesse a un'altra cadenza, si cambia un numero solo,
  `IlTamburoDellaDiscesa.battitiAlSecondo`.
- **Un anello che si chiude su se stesso**: l'ultimo colpo porta al primo
  senza pausa e senza scatto. Durata esatta multipla di un battito, per esempio
  8,000 secondi per 36 colpi.
- **Niente dissolvenza in entrata ne' in uscita** nel file: lo spegnimento lo
  fa l'app, in mezzo secondo, insieme alla dissolvenza verso la nebbia.
- MP3, 128 kbps, 44,1 kHz, mono, **normalizzato come gli effetti**: l'app lo
  suona al volume degli effetti, non a quello della musica, e sotto
  l'interruttore degli effetti sonori.

## Finche' il file manca

La discesa resta muta e funziona lo stesso: nessun errore a schermo, nessuna
riga nel registro dei guasti, e la musica non si abbassa sotto un silenzio. Il
fatto si annota nel diario di sviluppo, e basta. La cartella e' dichiarata nel
`pubspec.yaml` anche da vuota: il giorno che il file arriva, suona senza toccare
una riga di codice.

## IL COLPO DEL TAMBURO CHE NUTRE, ordine DL voce 11

Accanto al battito della discesa va **un secondo file**: `tamburo_colpo.mp3`.
Il nome esatto lo detta il codice, `IlColpoDelTamburo.percorso` nello stesso
`catalogo_suoni.dart`. Sono due suoni diversi: il battito e' un anello che
accompagna la discesa, il colpo e' la risposta secca al dito quando la persona
batte per nutrire l'animale, a ogni tocco, insieme alla vibrazione.

| File | Quando suona | Durata | Peso massimo |
|---|---|---|---|
| `tamburo_colpo.mp3` | A ogni tocco del nutrimento | da 0,2 a 0,4 s | 30 KB |

- **Lo stesso tamburo a cornice** del battito, un colpo solo, pieno e basso.
- **Attacco immediato**, niente silenzio in testa: il suono deve partire nello
  stesso istante del dito. Coda naturale, senza riverbero lungo.
- **Il colpo di prima si ferma quando parte il nuovo**: lo fa l'app, quindi il
  file puo' avere la sua coda intera.
- MP3, 128 kbps, 44,1 kHz, mono, **normalizzato come gli effetti**: suona al
  volume degli effetti e sotto il loro interruttore.

Finche' manca, il nutrimento vibra soltanto: nessun errore a schermo e nessuna
riga nel registro dei guasti.
