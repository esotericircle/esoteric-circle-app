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
