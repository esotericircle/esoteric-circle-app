# GLI ASSET DEL MONDO DI SOTTO, DA GENERARE

**10 settembre 2026.** Ordine DC, coda della voce 21.

**DA DOVE NASCE.** Il fondatore, guardando la soglia del Viaggio:
*"la mia idea e' sostituire le immagini vettoriali procedurali che fanno
schifo con quelle piu' realistiche create da Nano Banana"*.

**COME E' MONTATO OGGI, e perche' non blocca nessuno.** Ogni scena del Viaggio
ha uno **slot**: la schermata chiede l'immagine e non sa come sia fatta.
Finche' il file non c'e', un pittore dipinge la stessa scena; il giorno che il
file arriva, si vede il file. **Nessuna misura, nessun riquadro e nessuna
guardia cambiano**, perche' lo slot ha la stessa forma nei due casi. Lo slot
si chiama `SfondoDelMondoDiSotto` e sta accanto ai pittori.

**QUINDI QUESTO ELENCO NON E' UN DEBITO: e' un miglioramento pronto a
entrare.** L'app non e' mai brutta in attesa di un asset, perche' il ripiego
non e' un fondo generico ma la scena giusta dipinta a mano.

---

## Regole che valgono per tutti

- **Stile di casa**: Total Metal inciso, la stessa famiglia dei dodici totem
  degli animali. Bronzo, oro caldo e rosso di Caligo su blu profondo.
- **Mai testo dentro l'immagine.** I titoli, i nomi e i numeri li scrive
  Flutter a runtime, e vale per tutte le lingue: e' la legge del progetto dai
  cartigli dei tarocchi.
- **Mai un volto umano, mai una figura riconoscibile come persona.**
- **WebP**, alpha vero dove serve, e il nome finisce con `_v1`.
- **Il file va in `assets/img/mondo_di_sotto/`** e il nome e' esattamente
  quello scritto qui: e' il codice a cercarlo, non una persona a collegarlo.
- **Si guarda a schermo prima di dire che e' fatto**, e la regola e' quella di
  casa: un asset generato non e' un asset verificato.

---

## 1. `soglia_bosco_v1.webp`, il piu' importante

**Dove va.** E' il colpo d'occhio della soglia, la prima cosa che si vede
aprendo il Viaggio. Occupa tutta la larghezza in un rapporto **1,24 a 1**.

**Misura consigliata**: 1240 per 1000, che sul telefono di collaudo copre il
riquadro con margine.

**Cosa deve contenere.** Un bosco al crepuscolo visto da dentro. Tre piani di
tronchi, i vicini quasi neri ai lati che fanno da cornice, i lontani piu'
chiari. **In mezzo, in basso, un'apertura nella terra** da cui esce una luce
calda: e' il punto piu' chiaro dell'immagine e il posto dove l'occhio deve
andare per primo. Nebbia bassa fra i tronchi. Il cielo fra i rami vira dal
**blu profondo `#0B1436`** in alto al **bruno delle radici `#4A2E1A`** in
basso: sono gli stessi due colori della galleria che si vedra' scendendo,
quindi la soglia anticipa la scena vera invece di decorarla.

**Cosa NON deve contenere.** Nessun animale (i dodici totem ci passano davanti
a runtime e si sovrapporrebbero), nessuna figura umana, nessuna scala, nessuna
porta costruita: e' un'apertura nella terra, non un ingresso.

**La meta' bassa dell'immagine va tenuta scura e povera di dettaglio**: sopra
ci cade un velo e ci si legge la promessa in due righe.

**Traccia per il prompt**: *dense twilight forest seen from within, three
depths of dark tree trunks framing the sides, a warm glowing opening in the
earth at the lower centre, low ground mist, deep midnight blue sky fading to
root brown at the bottom, engraved metal art style, bronze and warm gold and
deep red accents, no people, no animals, no text.*

## 2. Le dodici ombre degli animali, `ani_ombra_<nome>_v1.webp`

**E' il guadagno visivo piu' grande di tutto l'ordine, e non e' uno sfondo.**

**Dove vanno.** Nell'incontro, dove si sceglie fra tre ombre, e nella casella
dell'Animale nel Passaporto. Oggi quelle sagome le **dipinge una formula** da
un seme: un quadrupede generico con corpo, quattro zampe, collo, testa,
orecchie e coda. Funziona, si legge come un animale, e **non e' l'animale che
poi ti tocca**: la lince e l'orso hanno la stessa sagoma con proporzioni
diverse.

**I dodici nomi**, che sono quelli del catalogo e non si inventano: aquila,
cavallo, cervo, corvo, falco, gufo, lince, lupo, orso, serpente, tartaruga,
volpe.

**Misura**: 900 per 700, alpha vero, il soggetto centrato con un margine del
dieci per cento.

**Cosa deve contenere.** **L'animale di profilo, in controluce, quasi nero**,
riconoscibile dalla sola sagoma. Non un'illustrazione colorata: una silhouette
con un filo di luce calda sul bordo. Un occhio solo, che riflette.

**Cosa NON deve contenere.** Nessun fondo: l'app ci mette la sua luce dietro,
e un fondo dipinto la coprirebbe. Nessuna cornice. Nessun nome.

**Perche' conta piu' delle altre.** Con questi dodici file, **l'ombra che
segui nell'incontro e' davvero l'animale che ti tocchera'**, e le quattro
apparizioni di Harner diventano quattro momenti dello stesso animale invece
che quattro gradi di una figura generica. Il codice non cambia: la scala, la
luce e la sfocatura restano dell'app, che e' quello che rende le quattro
apparizioni diverse fra loro.

**Traccia per il prompt**: *side profile silhouette of a <animale>, almost
black, backlit with a thin warm gold rim light along the edge, one reflecting
eye, transparent background, engraved metal art style, no scenery, no frame,
no text.*

## 3. `fondo_nebbia_v1.webp`, il fondo della galleria

**Dove va.** Sotto la nebbia, cioe' quello che si scopre aprendo un varco con
la mano. Verticale, a schermo pieno: **1080 per 2040**.

**Cosa deve contenere.** Il fondo del Mondo di Sotto visto da dentro la
nebbia: un orizzonte basso, terra bruna, tre masse scure che sono rocce o
alberi caduti, il cielo del sotterraneo blu profondo. **Piatto e povero di
contrasto**, perche' sopra ci va la nebbia e i varchi ne scoprono solo dischi
larghi un quinto di schermo.

**Cosa NON deve contenere.** Niente al centro esatto: il primo varco si apre
dove tocca la mano, e non si puo' sapere dove.

## 4. `tunnel_parete_v1.webp`, la texture della galleria

**Non sostituisce il tunnel: lo veste.** La discesa **risponde al dito** e non
e' un'animazione che parte, quindi un'immagine ferma non puo' prenderne il
posto. Quello che si puo' fare e' dare agli anelli una parete vera invece di
un colore pieno.

**Misura**: 1024 per 1024, **piastrellabile** sui due lati.

**Cosa deve contenere.** Terra compattata, radici sottili, pietre piccole,
niente di riconoscibile che possa ripetersi visibilmente. Toni bruni, poco
contrasto: sopra ci va la luce del tunnel, che e' quella a dare la forma.

**Questa e' l'unica voce dell'elenco che chiede un lavoro di codice**, perche'
il pittore oggi riempie gli anelli con un colore e dovrebbe riempirli con uno
shader di immagine. E' mezza giornata, e va fatta dopo le prime tre.

---

## L'ordine in cui conviene farli

1. **Le dodici ombre degli animali.** Cambiano la scena piu' importante del
   Viaggio, l'incontro, e insieme la casella del Passaporto. Sono dodici file
   piccoli e senza fondo, cioe' i piu' facili da rifare se il primo giro non
   piace.
2. **Il bosco della soglia.** E' il primo sguardo, ed e' quello che il
   fondatore ha giudicato per primo.
3. **Il fondo della nebbia.** Si vede poco e per pochi secondi.
4. **La parete del tunnel**, che chiede anche codice.

## Cosa NON conviene generare

- **Il tunnel come immagine.** Risponde al dito e gira su se stesso: una
  fotografia lo ucciderebbe.
- **Le quattro apparizioni come quattro file per animale.** Sarebbero
  quarantotto file, e la differenza fra le quattro la fanno gia' la scala, la
  luce e la sfocatura dell'app.
- **Il fiore del Loto della Meditazione.** Anche quello e' dipinto, ma
  **risponde al respiro del dito**, petalo per petalo: e' interazione, non
  decorazione.
