# FX.03, la foto vera ora per ora: verifica del Dial-A-Moon

Verifica fatta il 16 ottobre 2026, per `lib/core/lunario/il_dial_a_moon.dart`.

## Pagine visitate

- https://svs.gsfc.nasa.gov/5587/ (il Dial-A-Moon, serie "Moon Phase and
  Libration, 2026" dello Scientific Visualization Studio della NASA,
  Goddard Space Flight Center).
- https://svs.gsfc.nasa.gov/vis/a000000/a005500/a005587/frames/730x730_1x1_30p/moon.6797.jpg
  (un fotogramma vero scaricato per confermare l'indirizzo: risposta 200,
  JPEG vero, 38,7 KB).
- https://www.nasa.gov/nasa-brand-center/images-and-media/ (le condizioni
  d'uso delle immagini e dei media della NASA).

## L'indirizzo

La pagina del Dial-A-Moon dice: "Until the end of 2026, the initial
Dial-A-Moon image will be the frame from this animation for the current
hour." La serie 2026 ha un fotogramma per ogni ora dell'anno, 8760 in
tutto (365 giorni per 24 ore: il 2026 non e' bisestile), numerati da 1.

La regola che lega il numero del fotogramma all'istante e' la stessa gia'
usata da `tool/le_lune_della_nasa_scelta.dart` per scegliere le trenta lune
locali dalla stessa serie: il fotogramma N e' l'istante 1 gennaio 2026
00:00 UT piu' N meno 1 ore. Non e' scritta in una riga esplicita della
pagina come "pattern dell'URL": si ricava dai nomi dei fotogrammi mostrati
al passaggio del mouse sull'immagine (es. `moon.0283.jpg` per il
fotogramma 283) e si e' confermata scaricando davvero il fotogramma 6797,
che nel repository (`lib/core/lunario/le_lune_della_nasa.g.dart`) e' gia'
annotato come l'istante 2026-10-11T04:00:00.000Z: la differenza fra
quell'istante e il primo gennaio alle 00:00 UTC e' esattamente 6796 ore,
cioe' fotogramma 6797.

L'indirizzo verificato, con `NNNN` il numero del fotogramma su quattro
cifre a partire da `0001`:

```
https://svs.gsfc.nasa.gov/vis/a000000/a005500/a005587/frames/730x730_1x1_30p/moon.NNNN.jpg
```

## Formato e misure

- Formato: JPEG (confermato dall'intestazione JFIF del fotogramma
  scaricato).
- Misura usata: 730x730 punti, la cartella `730x730_1x1_30p`, la stessa
  misura gia' scelta per le trenta lune locali del Calendario Lunare.
- La stessa serie offre anche le misure 216, 320, 420, 640, 850, 960, 1080
  (anche in verticale 1080x1920), 1920x1080 e 3840x2160, nei formati JPG e
  TIF, e 5760x3240 in EXR (HDR) con canale alpha nelle misure HD e
  superiori. Non usate qui: 730x730 basta al castone e pesa poco.
- Fuori dal 2026 la serie ha un altro numero (il Dial-A-Moon pubblica una
  serie per ogni anno) e il suo indirizzo non e' stato verificato in questo
  giro: `IlDialAMoon.indirizzoPer` torna null fuori dal 2026, e la
  richiesta non parte nemmeno.

## Le condizioni d'uso

Dalla pagina nasa.gov/nasa-brand-center/images-and-media, verificata lo
stesso giorno:

- Attribuzione dovuta: "NASA should be acknowledged as the source of the
  material."
- L'insignia e il logotipo della NASA non sono di pubblico dominio e non
  si usano: "The NASA Insignia, Logotype, identifiers, and imagery are not
  in the public domain."
- Nessuna approvazione implicita: l'uso "must not explicitly or implicitly
  convey NASA's endorsement of commercial goods or services."
- Nei prodotti con intelligenza artificiale l'attribuzione diretta alla
  NASA non e' permessa: "attribution of the information directly to NASA
  is not permitted"; frasi come "according to NASA" sono proibite: "References
  like 'according to NASA' or similar are prohibited in AI products." La
  NASA non permette che la sua insignia appaia insieme a immagini generate
  da intelligenza artificiale.

Sono le stesse regole gia' applicate dall'ordine FV voce FV.03 per le
trenta lune locali, gia' nella citazione di
`lib/core/legal/fonti_dei_dati.dart`. `IlDialAMoon` non aggiunge una
seconda citazione: la guardia di stile nel file sorveglia solo che nessun
testo di un Maestro nomini mai la NASA e che nessun logo si disegni.
