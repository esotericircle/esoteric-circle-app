# ORDINE BT, IL CARATTERE SCELTO E LA TESTATA CHE COPRE IL MAESTRO

Ordine del fondatore del 27 agosto 2026. Ramo
`claude/esoteric-circle-master-order-e798aj`, guardia
`test/ordine_bt_guard_test.dart`. **Testa di partenza `4f76c04b`**, verificata
sul ramo: e' la testa che l'ordine BS ha lasciato dopo la consegna della 2207.

**Parole del fondatore, sulla build 2207**: "ok per la (b), chiudiamo BM.02". E
poi: "nei video di rivelazione di Caligo e Aura, in entrambi il titolo in alto
copre proprio la testa. basterebbe mettere il titolo il tuo Maestro a capo il
nome del maestro in basso al posto di benvenuto nel cerchio, e quest'ultimo
inserirlo come titolo della bolla subito sotto. cosi' in alto non ci sono
titoli".

## Le premesse, tutte e sei verificate sul ramo prima di scrivere una riga

- **P1 VERA.** `sigillo_intenzione_screen.dart` scriveva le ventuno lettere della
  ruota con `fontFamily: 'CormorantGaramond'` e `fontSize:
  TypographyTokens.pavimento`, alla riga 604. Il pavimento vale **12**,
  dichiarato in `typography_tokens.dart` riga 58.
- **P2 VERA.** `i_caratteri_dichiarati_esistono_test.dart` portava **una** sola
  eccezione dichiarata, `CormorantGaramond`, con la sua ragione scritta accanto
  e la sua scadenza: "in attesa della decisione del fondatore sulle tre
  anteprime del Sigillo d'Intenzione".
- **P3 VERA.** `CormorantGaramond` non compariva fra i `fonts` del
  `pubspec.yaml`; `EBGaramond` c'era, con
  `assets/fonts/EBGaramond-variable.ttf`.
- **P4 VERA.** La `Column` di `maestro_reveal_screen.dart` si apriva con due
  `Text` che cambiavano su `_revealed`: l'etichetta diceva "La rivelazione"
  oppure "Il tuo Maestro", e sotto veniva l'invito a soffiare oppure il nome del
  Maestro.
- **P5 VERA.** `_RevealedFooter` cominciava con `Text(identity.welcome())` in
  stile `titoloSezione`, poi la bolla con `ParagrafiDiLettura` dentro un
  `Container`, poi il pulsante "Entra nel Cerchio".
- **P6 VERA.** `ORDINE_BQ_MANIFESTO.md` dichiarava i pesi dei tre video come
  presi dall'ordine e non da una misura propria, e portava i marcatori a due
  voci fermate su premessa falsa e quattro chiuse.

## Le tre voci

- **BT.01** Il carattere delle ventuno lettere. **CHIUSA.** La ruota del Sigillo
  dell'Intenzione scrive in **EBGaramond**, che il `pubspec.yaml` dichiara gia' e
  che l'app carica gia': non entra un byte di asset in piu' e il pubspec non e'
  stato toccato. **L'eccezione nella guardia e' stata TOLTA, non aggiornata**:
  era li' in attesa di questa decisione, la decisione e' arrivata, e una deroga
  che sopravvive alla propria ragione e' il modo con cui i caratteri fantasma
  tornano.
- **BT.02** A Maestro rivelato la testata sparisce. **CHIUSA.** I due testi in
  cima non si disegnano piu' quando il Maestro e' rivelato, e il filmato arriva
  pulito fino al bordo alto. **Prima della rivelazione restano tutti e due**, ed
  e' la meta' che non si puo' sbagliare: li' dicono "La rivelazione" e cosa fare
  per svelare il Maestro. Il piede porta adesso l'etichetta, il nome, la bolla
  col saluto come proprio titolo e il pulsante, in quest'ordine.
- **BT.03** Le misure vere dei video nel manifesto BQ. **CHIUSA.** I tre file
  sono stati misurati sul disco di questo PC, non copiati da nessuno, e i numeri
  sono entrati in BQ.01 e BQ.04 al posto delle righe che dichiaravano un conto.
  **BQ.01 e BQ.05 passano a CHIUSA**, i marcatori del manifesto BQ da due
  fermate e quattro chiuse a **zero fermate e sei chiuse**, e la storia di come
  si erano fermate e' conservata verbatim in un capitolo suo.

## BT.01, il carattere

**LA MISURA CHE CONTA E' IL CONTO DELLE ECCEZIONI, ed e' la prova stessa a
stamparlo**: `i_caratteri_dichiarati_esistono_test` dice adesso **eccezioni
dichiarate 0, famiglie citate dal codice 3**, e tutte e tre stanno nel pacchetto.
Prima erano quattro famiglie citate con una in deroga. **Il peso degli asset
dichiarati non cambia di un byte**, perche' `EBGaramond` era gia' dentro: il
`pubspec.yaml` non e' stato aperto.

**Cosa succedeva prima, e non era visibile a nessuno.** `CormorantGaramond` non
e' mai stata nel pacchetto: Flutter non fallisce quando un carattere manca,
ripiega in silenzio su quello di sistema. Le ventuno lettere della ruota si
disegnavano quindi con un carattere diverso su ogni telefono, e sul telefono del
fondatore con quello che c'era li'.

## BT.02, la testata

**COSA E' STATO SPOSTATO, e non riscritto.** L'etichetta "Il tuo Maestro" e il
nome del Maestro sono scesi dalla cima al piede, **con lo stesso testo e lo
stesso stile** che avevano: `etichetta()` con `letterSpacing` 3 e il colore
`goldSoft` la prima, `cerimoniale()` centrato il secondo. Il saluto di
`identity.welcome()` non e' rimasto dov'era: **si e' spostato dentro la bolla**
come suo titolo, e sotto resta il testo del primo momento che la bolla gia'
conteneva.

**LA BOLLA ADESSO C'E' ANCHE SENZA IL PRIMO MOMENTO**, ed e' una conseguenza che
andava vista: il primo momento nasce dalla carta natale, e prima la bolla intera
stava dentro un `if (first != null)`. Lasciandola cosi', chi fosse arrivato alla
rivelazione senza carta avrebbe perso il saluto insieme alla bolla. Ora la bolla
si disegna sempre, col saluto, e il primo momento si aggiunge quando c'e'.

**MISURE, sullo schermo di riferimento 360x797 punti**, dove il terzo alto sono i
primi 265:

| misura | esito | preteso |
|---|---|---|
| testi nel terzo alto, a Maestro rivelato | **0** | zero |
| testi nel terzo alto, prima della rivelazione | **2**, "La rivelazione" e l'invito a soffiare | due |
| ordine nel piede | etichetta figlio **1**, nome **4**, saluto **11**, pulsante **53** | crescente |
| il saluto in tutta la schermata | **1 volta** | una sola |
| altezza del piede | **228,0 punti, il 28,6 per cento** | al massimo il 38 |

Il piede era il 17,1 per cento prima di questo ordine: le due righe scese dalla
cima lo portano al 28,6, dentro il tetto dell'ordine BR con undici punti di
margine.

## BT.03, le misure vere dei tre video

**MISURATI SUL DISCO DI QUESTO PC, uno per uno, e non copiati da nessuno**,
nemmeno dall'ordine che li nominava:

| file | byte | video | risoluzione | audio |
|---|---|---|---|---|
| `medora_rivelazione.mp4` | **2.422.069** | H.264 High, `yuv420p` | 720x1280 | nessuno |
| `caligo_rivelazione.mp4` | **1.995.875** | H.264 High, `yuv420p` | 720x1280 | nessuno |
| `aura_rivelazione.mp4` | **2.831.474** | H.264 High, `yuv420p` | 1080x1920 | nessuno |

In tutto **7.249.418 byte**. Tutti e tre a **24 fotogrammi al secondo, 241
fotogrammi, 10,041667 secondi**; le velocita' sono 1.929.615, 1.590.074 e
2.255.780 bit al secondo; il rapporto e' 9 a 16 esatto per tutti e tre. `ffprobe`
risponde su questa macchina, quindi non c'e' nessuna misura da dichiarare
mancante.

**IL PESO DEGLI ASSET DICHIARATI, rimisurato**: **129.264.184 byte, cioe' 123,28
MiB**, contati come li conta Flutter, cioe' prendendo i file dentro ogni cartella
dichiarata e non le sue sottocartelle. Erano 122.002.668 prima che i video
arrivassero: **piu' 5,95 per cento**. La cartella `brand_assets/maestri/` ne
porta 7.251.097, cioe' i tre filmati piu' i 1.679 byte del suo LEGGIMI.

**LA STORIA NON E' STATA RISCRITTA.** Le due righe con cui BQ.01 e BQ.05 si erano
fermate stanno **verbatim** dentro il nuovo capitolo *Come BQ.01 e BQ.05 si erano
fermate, e come si sono chiuse*, citate e non cancellate. **Una cosa l'ho dovuta
spostare per forza**: quel testo nomina la formula "FERMATA SU PREMESSA FALSA", e
la guardia del manifesto legge la riga della voce e ci cerca la prima parola di
stato che riconosce. Lasciando la storia sulla riga della voce, una voce chiusa
sarebbe stata contata fra le fermate. Per questo la storia sta in un capitolo suo
e la riga della voce porta solo il rimando.

**La misura di chiusura**: nel manifesto BQ non resta **nessuna riga viva** che
dichiari un numero come proveniente dall'ordine invece che da una misura. Le
righe citate nel capitolo della storia lo dicono ancora, ed e' giusto cosi':
sono la fotografia di come stavano le cose allora.

## La prova del rosso

Per ognuna il difetto e' stato rimesso nel sorgente, **l'iniezione e' stata
verificata dentro il file con un `grep` prima di leggere l'esito**, e il numero
qui sotto e' quello che la prova ha stampato da rossa. Nessuna soglia e' stata
toccata.

- **BT.01.** Rimesso `CormorantGaramond` nella ruota. Verifica: trovato a riga
  612. La guardia e' caduta stampando **famiglie citate 4** invece di 3 e
  nominando file e riga: `CormorantGaramond
  (lib/features/maestri/caligo/sigillo/sigillo_intenzione_screen.dart:612)`.
- **BT.02, prima iniezione.** I due testi rimessi in cima anche a Maestro
  rivelato, `if (true)` al posto di `if (!_revealed)`. Verifica: trovato a riga
  281. La prova e' caduta dicendo **2 testi nel terzo alto**, e li ha nominati:
  "La rivelazione" e "Soffia per spegnere la candela".
- **BT.02, seconda iniezione, e serve.** I due testi tolti **anche** a Maestro
  non rivelato, `if (false)`. Verifica: trovato a riga 281. La seconda prova e'
  caduta dicendo **0 testi invece di due** prima della rivelazione. **Senza
  questa seconda prova la prima si sarebbe accontentata di una testata sempre
  assente**, e la scena del rito sarebbe rimasta muta senza che nessuno se ne
  accorgesse.

## Cio' che questo ordine non ha toccato

La forma del segno sulla carta chiave della stesa, voce BN.05, che aspetta lo
sguardo del fondatore sulla 2207. I tre video, che restano provvisori e due col
watermark. Il corpus dei traguardi e la regia delle feste, chiusi dall'ordine BS.
Il listino degli Eos e le funzioni del server.

## La suite, alla chiusura dell'ordine

**3.690 prove verdi e 2 rosse**, con `TZ=Europe/Rome`, **ad albero davvero
fermo**: l'impronta `sha1` di tutti i sorgenti sotto `lib`, `test`, `docs`,
`tool` e del `pubspec.yaml`, presa prima del primo test e dopo l'ultimo, e' la
stessa, `0cf9cec9`. I due rossi sono i due dichiarati: l'attribuzione cieca,
rossa per dichiarazione dall'ordine BP, e `niente_lavoro_non_spinto`, che si
chiude col commit e con la spinta. `flutter analyze`: **zero avvisi**. Nessuna
guardia di casa e' caduta su questo ordine, ed e' la prima volta in quattro:
le nove prove che l'ordine BR e l'ordine BQ hanno lasciato sulla schermata
della rivelazione hanno retto lo spostamento della testata senza una riga di
modifica.

MARCATORI, per la guardia:
VOCI_TOTALI: 3
VOCI_APERTE: 0
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0
VOCI_FERMATE_SU_PREMESSA_FALSA: 0
VOCI_FERMATE_SU_DECISIONE_DEL_FONDATORE: 0
VOCI_CHIUSE: 3
