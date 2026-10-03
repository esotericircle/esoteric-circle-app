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
| `tamburo_discesa.mp3` | Per tutta la discesa del Viaggio, in ciclo | 2,286 s, anello senza cucitura | 250 KB |

Le misure che servono perche' suoni giusto:

- **Un tamburo a cornice sciamanico**, battuto con la mazza imbottita: colpi
  pieni e bassi, senza campane, senza voci, senza altri strumenti.
- **Tre battiti e mezzo al secondo**, regolari, cioe' 210 battiti al minuto:
  e' la cadenza del file consegnato dal fondatore con l'ordine DQ, misurata
  sull'onda decodificata, otto colpi forti in 2,286 secondi, e sta dentro la
  forbice della cadenza sciamanica documentata da Michael Harner, *The Way of
  the Shaman*, 1980, da 205 a 220 al minuto. E' la cadenza dell'alone che
  pulsa sotto il dito: se il file cambia cadenza, si cambia un numero solo,
  `IlTamburoDellaDiscesa.battitiAlSecondo`. I 270 al minuto scritti qui prima
  non avevano fonte.
- **Un anello che si chiude su se stesso**: l'ultimo colpo porta al primo
  senza pausa e senza scatto. Durata esatta multipla di un battito: il file
  consegnato dura 2,286 secondi per 8 colpi.
- **Niente dissolvenza in entrata ne' in uscita** nel file: lo spegnimento lo
  fa l'app, in mezzo secondo, insieme alla dissolvenza verso la nebbia.
- MP3, 128 kbps, 44,1 kHz, mono, **normalizzato come gli effetti**: l'app lo
  suona al volume degli effetti, non a quello della musica, e sotto
  l'interruttore degli effetti sonori.

## I due file sono arrivati, ordine DQ voce 10

Il 15 settembre 2026 il fondatore ha consegnato `tamburo_discesa.mp3` e
`tamburo_colpo.mp3` col pacco dei cinquanta asset del Viaggio, copiati senza
ricodifica ne rinomina e con l'impronta SHA-256 verificata. Il fondatore
aveva misurato il battito a 2,325 secondi e 214 colpi al minuto; l'onda
decodificata dice 2,286 secondi e 210, e il fondatore ha scelto il numero del
file: 3,5 battiti al secondo. Il colpo decodificato dura 0,700 secondi.

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
| `tamburo_colpo.mp3` | A ogni tocco del nutrimento | da 0,2 a 0,8 s; il file consegnato dura 0,700 s | 30 KB |

- **Lo stesso tamburo a cornice** del battito, un colpo solo, pieno e basso.
- **Attacco immediato**, niente silenzio in testa: il suono deve partire nello
  stesso istante del dito. Coda naturale, senza riverbero lungo.
- **Il colpo di prima si ferma quando parte il nuovo**: lo fa l'app, quindi il
  file puo' avere la sua coda intera.
- MP3, 128 kbps, 44,1 kHz, mono, **normalizzato come gli effetti**: suona al
  volume degli effetti e sotto il loro interruttore.

Finche' manca, il nutrimento vibra soltanto: nessun errore a schermo e nessuna
riga nel registro dei guasti.
