# ORDINE CN, MANIFESTO

Il suono entra nell'app. 1 settembre 2026, ramo
`claude/esoteric-circle-master-order-e798aj`.

Sedici voci, piu' una correzione del fondatore che precede l'ordine dove le due
si contraddicono.

## LA CORREZIONE DEL FONDATORE, che viene prima

Arrivata a ordine gia' cominciato, e applicata per intero.

1. **Nessuna delle tre tracce della Meditazione entra nell'app**, nemmeno
   Theta Waves.
2. **La voce CN.05 e' ANNULLATA.** La Meditazione resta com'e': il battito
   binaurale a 7 Hz resta, resta la prescrizione del volume ZERO della musica
   li' dentro, resta la prova che lo misura, e nessun riferimento al battito
   va tolto da nessun punto. **Nessuna decisione approvata cade e nessun
   superamento si scrive.**
3. **CN.03 si precisa**: gli anelli restano quattro, e `ambiente_aura` suona
   nel dominio di Aura ma NON nella Meditazione.
4. **CN.10 si riduce**: sparisce la traccia Theta e con essa la decisione
   delegata sul suo scaricamento.
5. **La premessa R5 decade.** R2 resta e va verificata lo stesso.

**Un conflitto fra la correzione e l'ordine, risolto a favore della
correzione.** La voce CN.06 chiedeva il respiro sincronizzato "nella
Meditazione e nei Doni del Giorno"; la correzione dice che la Meditazione non
si tocca. **Ha vinto la correzione**: i due respiri entrano nel catalogo e
servono i Doni del Giorno, e la Meditazione non e' stata sfiorata.

## LE PREMESSE

REGOLA ZERO: ogni misura di questo ordine e' stata rifatta sul posto.

**R1. "rivelazione.mp3 e rito_compiuto.mp3 sono lo stesso file salvato due
volte." FALSA.** Pesavano tutti e due 25.121 byte, ma:

| | rivelazione | rito_compiuto |
| --- | --- | --- |
| impronta sha1 | `9cbd9dce62c07df3` | `05e639d99b0a71e6` |
| impronta del suono decodificato | `79c81742a0197516` | `a06e273465d34619` |
| volume medio | -20,5 dB | -19,9 dB |
| picco | -5,0 dB | -5,7 dB |

**Pesano uguale perche' durano uguale allo stesso bitrate**, 1,5 secondi a 128
kbps mono: e' un'aritmetica, non un doppione. **Non serve procurare niente.**

**R2. "Il battito binaurale a 7 Hz esiste davvero." VERA, e generato a
esecuzione.** `MeditationPreset.thetaBeat` porta `leftHz: 210` e
`rightHz: 217`, e `beatHz` e' la loro differenza, cioe' **7 esatti**.
`tone_generator.dart` scrive i due canali con `sin(2 pi leftHz t)` e
`sin(2 pi rightHz t)`: e' sintesi vera, non una promessa scritta.

**R3. "Il catalogo dichiara sette voci e pietra.mp3 non esiste." VERA.** Sette
voci contate, e `pietra.mp3` mancava da `assets/audio/` dal 7 agosto 2026:
**per venticinque giorni la gettata delle rune ha vibrato senza suonare**, col
ripiego silenzioso che teneva viva l'app e muta la pietra. Adesso c'e'.

**R4. "Nessuno dei tre video ha traccia audio." VERA.** Tutti e tre portano il
solo flusso h264. Pesavano insieme 7.249.418 byte, cioe' i 7,25 MB dichiarati.

**R5. Decaduta** con la correzione del fondatore.

**E una premessa dell'ordine che e' caduta per strada, voce CN.09.**
L'ordine avverte che `rivelazione.mp3` suona sopra i tre video e va tolto solo
li'. **Non suona affatto sopra i video**: la schermata della rivelazione
(`maestro_reveal_screen.dart:206`) esegue solo lo schema aptico, e nessun suono.
E non suona nemmeno per l'animale guida, per gli angeli e per il sigillo, che
passano dalla voce per Maestro dell'ordine BX voce 05. **`rivelazione.mp3`
suona in due punti soli**: il responso dell'Oroscopo e la rivelazione della
stesa. **Nessuna modifica era necessaria, e il danno che l'ordine temeva non
era possibile.**

## VOCE 01, I SETTE EFFETTI, MISURATI UNO PER UNO

| destinazione | durata dichiarata | durata VERA | peso | note |
| --- | ---: | ---: | ---: | --- |
| pietra | 1,70 s | 1,70 s | 21.046 | |
| festa | 3,61 s | 3,60 s | 43.946 | intera, per decisione |
| carta | 0,73 s | 0,73 s | 10.243 | il flusso mjpeg tolto |
| eos | 2,04 s | **2,00 s** | 24.808 | intera, per decisione |
| custodisci | 0,47 s | **0,42 s** | 5.999 | |
| respiro_dentro | 7,16 s | **4,94 s** | 60.247 | silenzi tolti |
| respiro_fuori | 8,21 s | **6,85 s** | 83.130 | silenzi tolti |

**Due durate dell'ordine erano diverse dal vero** e sono in grassetto: eos
2,00 contro 2,04, custodisci 0,42 contro 0,47. Vale la misura fatta qui.

**Il WAV della carta portava davvero un flusso mjpeg**, cioe' un'immagine di
copertina: si prende la sola prima traccia audio con `-map 0:a:0`, e
l'immagine non entra nell'MP3.

**Tutti in mono, e la differenza fra i canali era gia' trascurabile**: fra -16,7
e -39,7 dB sotto il segnale. Nessuno perde niente, e nessuno resta stereo.

**Il catalogo passa da SETTE voci a TREDICI**, e la guardia che vieta i suoni
nati fuori dal catalogo non e' stata toccata per farli entrare.

## VOCE 02, LA NORMALIZZAZIONE, E LA GRANDEZZA CHE HO DOVUTO CAMBIARE

**Prima strada, scartata coi numeri.** Sonorita' integrata EBU R128 a due
passaggi, che e' la misura con cui si pubblica la musica. Applicata ai nostri
file lasciava **6,7 LU di scarto**, e in volume medio 9,3 dB.

**Perche' non funzionava.** La sonorita' integrata ha un cancello che scarta i
blocchi piu' quieti di venti decibel sotto la media, perche' e' pensata per un
brano lungo dove il silenzio fra le note non deve contare. **I nostri effetti
durano da 0,42 a 8,2 secondi e sono per un terzo silenzio**: il cancello
scartava quasi tutto il file.

**Seconda strada, adottata: la MASSIMA SONORITA' MOMENTANEA.** Stessa scala
EBU, finestra scorrevole di 400 millisecondi, presa nel massimo. E' il momento
piu' forte del suono, che e' cio' che l'orecchio giudica su un effetto breve, e
vale allo stesso modo su un respiro di sette secondi.

**Si e' cambiata la grandezza misurata, non la soglia.**

**Il numero: -16 LUFS-M, picco vero a -1,5 dBTP.** La musica a **-23 LUFS-M**,
sette decibel sotto: e' il gradino oltre il quale un effetto si sente sopra il
tappeto senza che nessuno alzi niente. Il rapporto e' giusto **prima** che i
cursori intervengano, come l'ordine chiede.

### Il risultato, misurato

| | prima | dopo |
| --- | ---: | ---: |
| effetto piu' forte | -13,9 dB medio | -16,3 LUFS-M |
| effetto piu' debole | -29,2 dB medio | -19,4 LUFS-M |
| **scarto** | **15,3 dB** | **3,0 LU** |

I due che non arrivano a -16 sono `carta` a -18,0 e `custodisci` a -19,4: sono
clic gia' al limite del picco, e alzarli oltre vorrebbe dire tagliarli in cima.

**Sono stati normalizzati anche i SEI che c'erano gia'**, e non era facoltativo:
stavano fra -12,9 e -16,9 LUFS-M, cioe' **piu' forti dei sette appena
convertiti**. Portare solo i nuovi avrebbe spostato il problema.

**Il rifiuto e' l'unico che non si misura, ed e' un fatto fisico**: dura 0,30
secondi, meno della finestra di 400 millisecondi. Per lui vale il picco, portato
a -12,4 dB, cioe' volutamente sotto gli altri, che e' cio' che il catalogo
scrive di lui da sempre: "il rifiuto non merita teatro".

**Il budget.** I tredici effetti pesano **352.813 byte**, sotto il mezzo
megabyte dichiarato. La musica si conta a parte.

## VOCE 03, I QUATTRO ANELLI

| anello | durata origine | durata anello | peso |
| --- | ---: | ---: | ---: |
| ambiente_home | 152,1 s | 149,1 s | 1.793.493 |
| ambiente_medora | 154,3 s | 151,3 s | 1.816.285 |
| ambiente_caligo | 134,5 s | 131,5 s | 1.578.362 |
| ambiente_aura | 192,0 s | 189,0 s | 2.268.935 |

Totale **7.457.075 byte**, dentro la stima di 7,6 MB. A 96 kbps stereo: sono
tappeti d'ambiente, e a 128 kbps avrebbero sfondato la stima di due megabyte e
mezzo senza che un pad si distingua.

**Lo Shaman: riconvertito, e dichiaro perche'.** Arrivava gia' in MP3 a 128
kbps e ricomprimerlo e' una perdita sopra una perdita. **Ma chiudere l'anello
richiede di decodificare e ricodificare comunque**, e la sua giunta saltava di
30,2 dB, cioe' un buco di silenzio a ogni giro. **Un anello che si sente
ripartire e' un difetto piu' grande di un decimo di decibel di dettaglio.**

Lo Shaman copre il Risveglio e la home **con la stessa traccia**, quindi fra
quelle schermate non c'e' nessuna dissolvenza: continua e basta. E continua
anche sui Doni del Giorno, perche' nessun Dono dichiara una musica sua.

## VOCE 04, GLI ANELLI ORA GIRANO

**Metodo.** Si prende la testa del brano, lunga tre secondi, e la si dissolve
incrociata sulla coda del resto. Il risultato dura L meno N, comincia dove
c'era il secondo tre, e finisce con lo stesso materiale con cui comincia: **il
punto di giunta smette di esistere.**

| anello | scarto alla giunta PRIMA | DOPO |
| --- | ---: | ---: |
| ambiente_medora | 65,0 dB | **2,6 dB** |
| ambiente_caligo | 63,3 dB | **0,3 dB** |
| ambiente_home | 30,2 dB | **2,1 dB** |
| ambiente_aura | 5,2 dB | **3,9 dB** |

La misura dell'ordine e' confermata: Aura girava gia', gli altri tre no.

## VOCE 05, ANNULLATA DAL FONDATORE

Nessuna traccia della Meditazione entra. La Meditazione non e' stata toccata:
nessuna riga di `meditation_screen.dart`, `meditation_audio.dart` o
`tone_generator.dart` e' cambiata in quest'ordine.

## VOCE 06, I RESPIRI

**L'osservazione del fondatore e' confermata, misurata con `silencedetect` a
-45 dB:**

| file | respiro vero | silenzio |
| --- | --- | ---: |
| Breath Sub 1 | da 0,168 a 5,109 s | 2,05 s in coda |
| Breath Sub 2 | da 0,464 a 7,311 s | 0,89 s in coda |

**Decisione: si tagliano i silenzi, e la velocita' di riproduzione accorda il
respiro alla fase.**

*Perche' non il contrario.* La cadenza e' scritta a schermo: "Quattro tempi
mentre entra, quattro mentre esce". **Adattare i tempi dell'app ai file
farebbe mentire quel testo**, ed e' esattamente il difetto gia' corretto nel
Soffio del Destino, dove il testo diceva sei tempi e il simbolo ne faceva
altri. Il corpus dichiara fasi di 3, 4, 5, 6 o 7 secondi: **un file solo non
puo' durare tutte**, quindi e' il file ad adattarsi, non la parola.

I due file portano quindi la durata **vera** del respiro, 4,94 e 6,85 secondi,
ed e' scritta nel catalogo perche' e' il numero con cui si calcola la velocita'.
Una prova la sorveglia: se il catalogo mentisse, suono e figura direbbero due
cose diverse nello stesso istante.

## VOCE 07, I VOLUMI E IL SOTTOMENU'

**Il sottomenu' del suono** nelle Impostazioni: interruttore degli effetti,
interruttore della musica, un cursore per ognuno con la percentuale scritta
accanto. I due interruttori restano sotto il governo unico Suono e Vibrazione,
e quando quello e' spento qui dentro non si tocca niente.

**La lista delle Impostazioni non si allunga**: la riga degli effetti sonori
esce e la riga "Suono" entra al suo posto. E' voluto, perche' una voce in piu'
in quella schermata spinge sotto la piega tutto cio' che sta sotto.

**Volumi di partenza**: musica 60, effetti 100, come deciso.

**La musica nasce ACCESA. Decisione delegata, motivata.** Gli effetti nascono
spenti dall'ordine BZ per una ragione scritta e precisa, cioe' che quelli di
allora "sembravano un giochino anni 80": **quella ragione non riguarda la
musica**, che e' nuova e l'hai scelta tu una per una. E c'e' una ragione di
disegno: l'ordine CN vuole che lo Shaman parta con la prima schermata del
Risveglio e prosegua fino alla home. **Nascerla spenta cancellerebbe proprio
quel disegno**, cioe' la prima impressione che qualcuno ha scelto.

### Le regole del volume, e da dove viene ogni numero

- **Sotto un effetto la musica scende al 35 per cento in 220 ms e risale in
  600.** La discesa e' rapida perche' deve aver finito prima dell'attacco
  dell'effetto, che e' la parte che si riconosce; la risalita e' lenta perche'
  un tappeto che torna di colpo si nota, e un tappeto che si nota non e' piu'
  un tappeto. Si contano gli effetti in corso: due ravvicinati non fanno
  risalire il tappeto in mezzo.
- **Il passaggio fra tracce e' una dissolvenza di 1200 ms**, mai un taglio.
- **La musica si sospende in secondo piano e riprende dov'era**, non da capo.
- **Nessuna musica dedicata ai Doni**, e chi non dichiara niente lascia
  continuare quel che suona.

**L'abbassamento sta dentro la porta unica dei suoni**, non nelle schermate: se
ognuna dovesse ricordarsene, la prima che se ne dimentica ha un effetto coperto
dalla musica e nessuno sa dove cercare.

## VOCE 08, I TRE VIDEO

| video | prima | dopo | audio |
| --- | ---: | ---: | --- |
| aura_rivelazione | 18,82 MB | **1,72 MB** | -15,8 a -16,0 LUFS-M |
| caligo_rivelazione | 18,27 MB | **2,25 MB** | -9,8 a -16,1 LUFS-M |
| medora_rivelazione | 17,53 MB | **2,56 MB** | -15,8 a -16,0 LUFS-M |

Da 57,26 MB a **6,84 MB**, tutti 1080 per 1920 a 24 fotogrammi, con la traccia
AAC. **Sono piu' LEGGERI dei tre che sostituiscono**, che pesavano 7,25 MB
senza audio: il peso dei video non cresce di 2,8 MB come stimato, **cala di
0,4 MB**.

**Il fattore, guardato e non solo contato.** Qualita' costante a 26 invece di
un bitrate fisso, perche' un bitrate fisso spende gli stessi bit su un
fotogramma fermo e su uno pieno di movimento. Un fotogramma estratto al secondo
cinque e' stato guardato: il campo stellato, i ricami d'oro e il volto reggono,
niente scalettature. **Nessuna filigrana**, verificata ingrandendo l'angolo in
basso a destra.

L'audio dei video e' portato alla stessa sonorita' degli effetti: senza,
sarebbe stato l'unico suono dell'app deciso in un altro studio.

## VOCE 09, L'EFFETTO SOPRA I VIDEO

**Nessuna modifica, perche' la premessa e' falsa.** Vedi sopra: nessun suono
viene riprodotto sopra i tre video, e `rivelazione.mp3` vive in due punti che
non c'entrano coi Maestri.

## VOCE 10, IL PESO

Vedi la sezione della consegna in fondo, coi numeri veri dell'archivio.

## VOCE 11, LE LICENZE

**Nessuna scelta di quest'ordine costruisce un selettore di brani.** La traccia
si ricava dal luogo in cui si e', mai da una scelta: `RegiaDellaMusica.vaiA`
prende un LUOGO, non un brano, e non esiste nessun comando che dica "metti
questa". Una guardia lo sorveglia cercando il gesto e non la parola: chi scorre
`MusicaDelCerchio.values` fuori dalle due porte dichiarate fa cadere la prova,
perche' scorrere l'elenco delle tracce serve quasi sempre a costruire una lista
da cui scegliere.

## VOCE 12, LA CARD A MISURA FISSA

Sette card da condividere passano da `CardAMisuraFissa`, che tiene il testo
alla scala uno qualunque cosa la persona abbia impostato nel sistema.
`sky_postcard` non ci passa **perche' non e' un widget**: disegna direttamente
in byte, e la scala di sistema non lo tocca gia' oggi.

**Quante schermate ha chiuso, MISURATE e non stimate: UNA.** La cattura della
card dell'Estrazione Rune, che il manifesto CM aveva classificato come "una
pretesa della cattura" e invece era il difetto della card. **I rossi a testo
massimo scendono da diciotto a diciassette.**

**E qui ho sbagliato due volte prima di misurare.** Avevo attribuito alla card
delle Rune anche "la corsa dello zodiaco" e i due "dono col colore del
Maestro", e le avevo tolte dai rossi accettati dandole per chiuse. **Il
cancello me le ha rimesse davanti come rossi nuovi**, e il corredo girato a
scala massima ha detto il numero vero. Sono tornate nell'elenco con la loro
ragione corretta: la misura fissa toglie la crescita del testo, ma la cornice
resta piu' corta del contenuto.

**La lezione, ed e' la ragione per cui il cancello esiste.** Avevo dedotto
l'attribuzione da un rapporto di traboccamenti letto a occhio, invece di
rigirare il corredo. **Un'attribuzione dedotta e' un'ipotesi**, e mettere
un'ipotesi dentro il registro dei rossi accettati vuol dire spegnere una
guardia su una supposizione.

## VOCE 13, I DUE FILE CHE PESANO UGUALE

Chiusa dalla premessa R1: non sono lo stesso file, e non serve procurare
niente.

## LE PROVE DEL ROSSO, Regola A

Ogni innesto verificato **col grep prima** di leggere l'esito.

| guardia | innesto | esito |
| --- | --- | --- |
| il suono dice il vero, impronte | un'impronta falsata nel registro | rossa |
| il suono dice il vero, sonorita' | un effetto portato a -28 | rossa |
| il suono dice il vero, anelli | una giunta da 40 dB | rossa |
| il suono dice il vero, catalogo | `festa.mp3` tolta dal disco | rossa, col cardinale |
| il suono dice il vero, respiri | il respiro dichiara 6 s invece di 4,94 | rossa |
| la musica segue il luogo | la Meditazione non pretende piu' il silenzio | rossa |

## IL DIFETTO CHE HO INTRODOTTO IO, E COME E' VENUTO FUORI

La musica nasce accesa, quindi in prova tentava di suonare. `audioplayers` apre
un canale globale alla prima costruzione, e **l'errore di quel canale arriva
come eccezione di piattaforma fuori dalla catena di chiamate**: non passa da
nessun `catch`, e ha fatto cadere sette prove che col suono non c'entrano
niente, fra cui una sul campo di scrittura della chat.

**Gli effetti non avevano questo problema per caso**: nascono spenti, quindi in
prova non arrivano mai al lettore. La musica nasce accesa per decisione, e la
stessa protezione andava scritta a mano. Adesso la regia non tocca il lettore
sotto `flutter test`, **ma continua a dire quale traccia avrebbe scelto**, cosi'
una prova puo' ancora verificare cosa suonerebbe.

## VOCE 14, LA BUILD: CONSEGNATA, E SENZA LA PROVA DI ACCENSIONE

**Numero: 2218.** La 2217, costruita dall'ordine CI e mai consegnata,
decade come l'ordine dispone.

**LA BUILD C'E', IL CANCELLO E' VERDE, ED E' SU APP DISTRIBUTION.**
Release `7s8321b3mtbu0`, consegnata il 1 settembre 2026.

**Ma non e' passata dalla prova di accensione, e va detto forte.**

`tool/consegna.py` comincia con una **prova di accensione**: installa
l'archivio su un telefono vero, lo avvia, e guarda nel log se e' partito
davvero. Se non trova esattamente un dispositivo collegato si ferma con
queste parole: *"Non si consegna al buio: collega il telefono o avvia un
emulatore e riprova"*.

**Su questa macchina non c'e' nessun telefono collegato e nessun
emulatore parte.** L'ho verificato adesso, non a memoria: `adb devices`
torna un elenco vuoto.

**Prima l'ho fermata, poi il fondatore ha chiesto la build su App Tester**,
e questa e' una sua decisione, non un mio aggiramento. Il salto e' passato
dall'interruttore che esisteva gia' per questo,
`ACCENSIONE_SALTATA_PER_ORDINE`, che lo stampa a schermo con la ragione per
esteso.

**E ho chiuso un buco che ho trovato facendolo.** Quel salto si stampava a
video e **non finiva da nessuna parte**: nel registro delle consegne una
build accesa da un telefono vero e una consegnata al buio erano
indistinguibili. Adesso `tool/consegna.py` scrive `prova_di_accensione` a
ogni consegna, o con la parola "eseguita" o con la ragione del salto, e
nel registro della 2218 c'e' scritto per esteso perche' non e' stata fatta.

**Cosa vuol dire per chi la installa.** Nessun telefono ha acceso questo
archivio prima che partisse. Le note della release lo dicono a chi la
riceve, e la prima persona che la apre e' anche la prima che la prova.

**Il registro della consegna**, scritto da `tool/consegna.py` e non a mano:

| | |
| --- | --- |
| ultimo distribuito | 2218 |
| release | `7s8321b3mtbu0` |
| peso dell'archivio | 176.723.356 byte |
| comando di build | `flutter build apk --release` |
| prova di accensione | **SALTATA**, con la ragione per esteso |

Il passo 6 di `docs/ordini/DISTRIBUZIONI_DAL_TUO_PC.md` resta scritto per
la prossima volta, quando la build si potra' accendere prima di partire.

| | byte |
| --- | ---: |
| Archivio del 31 agosto 2026, la 2216 | 169.244.205 |
| **Archivio della 2218** | **176.723.356** |
| **Differenza** | **+7.479.151, cioe' +7,13 MB** |

**Meno della stima, che diceva +10,7 MB**, e il conto di dove sta la
differenza:

| | byte |
| --- | ---: |
| i quattro anelli d'ambiente | +7.457.075 |
| i tredici effetti, contro i sei di prima | +215.043 |
| i tre video ricompressi, contro i tre di prima | **-405.341** |
| somma degli asset | +7.266.777 |
| il resto e' impacchettamento | +212.374 |

**I video hanno fatto CALARE l'archivio di 405.341 byte pur avendo guadagnato
la traccia audio che prima non c'era.**

**Il peso della musica si conta a parte da quello degli effetti**, come
l'ordine chiede: 7.457.075 contro 352.813, cioe' ventuno volte tanto. Un
budget solo li avrebbe nascosti tutti e due.

Il comando di costruzione e il peso finiscono nel registro delle consegne,
scritti da `tool/consegna.py` come stabilito da CH.08 e CH.09, e la guardia
della consegna apre l'archivio e ne verifica il contenuto come CH.07.

## VOCE 15, IL FOGLIO PER IL FONDATORE

`docs/ordini/DISTRIBUZIONI_DAL_TUO_PC.md`, che resta **l'unico foglio**: due
fogli per lo stesso PC sono due verita' su cosa manca. Aggiornato con la testa
nuova e col passo della distribuzione ai fondatori.

## VOCE 16, IL REFERTO

E' questo documento. La riga finale sta in fondo.

---

## QUANTE GUARDIE SONO STATE VISTE ROSSE, E LA PERCENTUALE NUOVA

**Sei prove del rosso con l'innesto verificato col grep**, su due guardie
nuove. **Il registro passa da quindici guardie viste rosse a venti su
duecentoquarantasette, cioe' dal 6,1 all'8,1 per cento.** Prima dell'ordine CL
erano nove su duecentoquarantadue, il 3,7.

**E qui devo essere preciso su cosa NON ho fatto.** La Regola B chiede di
vedere rossa una guardia **prima** di toccare la sua zona. Le nove che sono
cadute lavorando, dal conto dei suoni al contrasto dei grigi, **non le ho
provate prima: sono cadute da sole**. Il risultato e' lo stesso, cioe' sapere
che erano vive, ma il momento no: l'ho scoperto dopo aver rotto, non prima. Le
loro date sono nel registro perche' quel giorno le ho viste rosse davvero,
non perche' abbia seguito la regola alla lettera.

**E c'e' una cosa che la Regola B ha fatto senza che nessuno la cercasse.**
Toccando il suono sono cadute **nove guardie su zone che non pensavo di
toccare**: il conto dei suoni del catalogo, la durata massima, l'interruttore
degli effetti, i catch muti, il manifesto degli asset, il censimento degli
spazi, il contrasto dei grigi, la cattura delle Impostazioni e l'icona
dell'utente. **Nessuna di queste era un difetto del suono**: erano guardie che
sorvegliavano davvero, e che si sono accorte di un cambiamento prima di me.

---

## COSA IL FONDATORE SENTIRA' DI DIVERSO APRENDO QUESTA BUILD

**Per la prima volta l'app non e' muta.** Dalla prima schermata del Risveglio
parte lo Shaman e non si ferma piu': accompagna la registrazione, resta sulla
home, continua sotto i Doni del Giorno. Entrando nel dominio di un Maestro il
tappeto **cambia in dissolvenza**, senza tagli: l'atmosfera di Medora, il
deserto di Caligo, il bambu' di Aura. Nella Meditazione tace, perche' li' c'e'
il battito a 7 Hz e non deve avere niente sopra.

**Gli effetti restano spenti**, come deciso ad agosto: per sentirli si va in
Impostazioni, Suono, e si accende. Sono tredici e non piu' sei, e adesso si
sentono tutti allo stesso volume: prima il sigillo del Custodisci era quindici
decibel piu' basso delle pietre, cioe' inudibile accanto a loro.

**La gettata delle rune suona.** Per venticinque giorni ha vibrato in silenzio,
perche' il catalogo dichiarava una pietra che sul disco non c'era.

**Quando un effetto suona, la musica scende sotto e poi risale da sola**, in
due decimi di secondo giu' e sei decimi su: non si sente il gesto, si sente
solo che l'effetto sta davanti.

**Le tre rivelazioni dei Maestri hanno una voce**, e pesano meno di prima.

**E in Impostazioni c'e' una pagina nuova**, Suono, con due interruttori e due
cursori: la musica parte al sessanta, gli effetti al cento, e sotto c'e'
scritto perche' non sono pari.
