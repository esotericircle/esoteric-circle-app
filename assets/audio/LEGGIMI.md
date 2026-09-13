# I cinque suoni del Cerchio

Questa cartella e' vuota apposta: gli asset li sceglie Mauro su Envato Elements.

Gli slot sono gia' predisposti nel codice, in `lib/core/sensi/catalogo_suoni.dart`.
Appena i file arrivano qui con questi nomi esatti, suonano senza che si debba
toccare una riga.

| File | Quando suona | Durata | Peso massimo |
|---|---|---|---|
| `firma.mp3` | Apertura dell'app, una volta per sessione | 2,0 s | 120 KB |
| `rivelazione.mp3` | Risonanza, animale, angeli, sigillo | 1,5 s | 100 KB |
| `rito_compiuto.mp3` | Chiusura di un rito o di una lettura | 1,5 s | 100 KB |
| `soglia.mp3` | Ingresso nel dominio di un Maestro | 0,5 s | 60 KB |
| `rifiuto.mp3` | Un limite raggiunto | 0,3 s | 40 KB |

Formato: MP3, 128 kbps, 44,1 kHz, mono. Sono segnali, non musica: il mono
dimezza il peso senza togliere niente. Totale sotto i 420 KB.

Finche' i file non ci sono, l'app resta silenziosa e non si rompe: e' il ripiego
dichiarato nel motore audio.

## Il tamburo della discesa, ordine DI voce 09

**Dall'ordine DJ voce 10 sta in una cartella sua**, `assets/audio/mondo_di_sotto/`,
col nome `tamburo_discesa.mp3`, e le sue misure stanno nel LEGGIMI di quella
cartella. Qui resta la storia.

Il Viaggio dello Sciamano scende dentro un filmato muto: il suono della scena e'
un tamburo, in un livello suo, che batte per tutta la discesa e **continua a
battere anche quando il dito si alza**. E' il contrasto che l'ordine chiede:
l'immagine si ferma, il tamburo no, e la persona capisce che si e' fermata lei
e non il Mondo di Sotto.

Lo slot e' gia' nel codice, in `lib/core/sensi/catalogo_suoni.dart`, classe
`IlTamburoDellaDiscesa`. Appena il file arriva qui con questo nome esatto,
suona senza toccare una riga; finche' manca, la discesa resta muta e la musica
non si abbassa sotto un silenzio.

| File | Quando suona | Durata | Peso massimo |
|---|---|---|---|
| `tamburo_della_discesa.mp3` | Per tutta la discesa del Viaggio, in ciclo | da 4 a 12 s, anello senza cucitura | 250 KB |

Le misure che servono perche' suoni giusto:

- **Un tamburo a cornice sciamanico**, battuto con la mazza imbottita: colpi
  pieni e bassi, senza campane, senza voci, senza altri strumenti.
- **Quattro battiti e mezzo al secondo**, regolari, cioe' 270 battiti al
  minuto. E' la cadenza dell'alone che pulsa sotto il dito, e i due devono
  andare insieme. Se il file vero battesse a un'altra cadenza, si cambia un
  numero solo, `IlTamburoDellaDiscesa.battitiAlSecondo`.
- **Un anello che si chiude su se stesso**: l'ultimo colpo deve portare al primo
  senza pausa e senza scatto, perche' il lettore lo ripete finche' dura la
  discesa. Durata esatta multipla di un battito, per esempio 8,000 secondi per
  36 colpi.
- **Niente dissolvenza in entrata ne' in uscita** nel file: lo spegnimento lo
  fa l'app, in mezzo secondo, insieme alla dissolvenza verso la nebbia.
- MP3, 128 kbps, 44,1 kHz, mono, normalizzato come gli effetti. Il volume
  dell'app lo porta all'80 per cento: e' il battito della scena, non un colpo
  che chiede attenzione.
