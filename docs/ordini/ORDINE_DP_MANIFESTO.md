# ORDINE DP, L'ONBOARDING SMETTE DI STONARE

**Sigla:** DP. **Data:** 15 settembre 2026. **Ramo:**
`claude/esoteric-circle-master-order-e798aj`. Segue l'ordine DN, commit
`6ad6349e`, build 2261.

Tre correzioni chieste dal fondatore dopo la prova della build 2261: la
Carta di Nascita, il lampo prima del video del Maestro, l'audio che finisce
di colpo. **Tocca l'onboarding**; per un guasto trovato sul telefono anche
il calcolo della Carta di Nascita in `lib/core/rituals/`: sta scritto alla
voce DP.04. L'ordine DO, il Sigillo, gira dopo, con la sua build.

**Il fondatore ha scelto l'ordine dei lavori**: prima il DP con la sua build,
poi il DO con la sua. Le stime dichiarate prima di partire: il DP cinque o sei
ore, il DO sedici o diciannove.

VOCI_TOTALI: 6
VOCI_CHIUSE: 6
VOCI_SBLOCCATE_E_APERTE: 0

Le schermate della prova a video stanno in `docs/collaudo/DP/`.

---

## LE PREMESSE

Verificate prima di toccare il codice.

| premessa | esito |
|---|---|
| P1, in `assets/img/mazzo-tarocchi/` 79 file, le 78 carte e il dorso `tar_rw_dorso_medora_v1.webp` | **vera**; accanto ci sono anche le 79 miniature |
| P2, `rivelazione_carta_di_nascita.dart` lungo 315 righe, nessun asset, tutto in un `CustomPainter` coi numeri romani | **vera** |
| P3, `velo_di_rivelazione.dart` con `setVolume(1)` e `play()`, fine alla durata, nessuna dissolvenza ne' rallentamento | **vera** |

---

## DP.00, IL FATTO. CHIUSA

La misura conferma le parole del fondatore: le settantotto arti e il dorso
esistevano tutte: la schermata non ne apriva nessuna.

---

## DP.01, LA CARTA DI NASCITA CON LE CARTE VERE. CHIUSA

- **Il mazzo che gira e' tutto il mazzo**, settantotto carte col dorso vero,
  in un anello visto di scorcio che le sovrappone in profondita'. L'anello
  rallenta con una curva continua e si ferma con davanti la carta del
  calcolo; quella viene avanti e si gira: e' la sua arte a piena
  risoluzione con i cartigli del mazzo, `TarotCardArt`.
- **Il numero si spiega**: sotto il numero grande le cifre della data, che si
  accendono man mano che entrano nella somma; nella riduzione le cifre del
  totale; sotto ancora la riga dell'ordine, *"La tua data si somma e si
  riduce. Il numero che resta e' la tua carta."* Il romano sta solo sulla
  carta.
- **La fluidita', misurata sul Realme in profilo** col fondo cosmico vero:
  **60,1 e 60,2 fotogrammi costruiti al secondo con tutte e settantotto le
  carte visibili**, su un telefono che a scena vuota ne consegna 60,3 (lo
  schermo va a 61 Hz). Nessuna carta tolta. **La prima stesura ne faceva fra
  38 e 43**: un `Flow` con settantotto figli, ognuno un'immagine dentro un
  ritaglio arrotondato. Adesso le settantotto si dipingono da una sola
  immagine decodificata, ognuna nel suo rettangolo.
- **Il pulsante e' uno solo in tutto l'onboarding**, `PulsanteDelRisveglio`:
  fondo oro, testo scuro, pillola, il corpo a peso 600, lo stesso di *"Chi
  altro ti accompagna"* e *"La tua Carta di Nascita"*. Fuori standard ne
  sono stati trovati **sei**, tutti portati al componente: la Carta di
  Nascita (il viola del tema), il Ritrovamento (il viola del tema), l'Invito
  e il Primo Approdo (il carattere dell'etichetta, nessuna pillola), la
  Carta del Cielo e la Risonanza (il carattere della lettura). Resta sua la
  porta per chi torna nella prima schermata, secondaria per scelta scritta
  accanto a lei. Una guardia conta ogni `FilledButton` scritto a mano.
- **La lingua visiva delle altre**: lo stesso fondo cosmico, i margini del
  Trionfo, l'etichetta *"La tua Carta di Nascita"* col trattamento di *"Chi
  ti accompagna"*, il pulsante nella colonna.

---

## DP.02, IL LAMPO PRIMA DEL VIDEO. CHIUSA

**La causa, trovata**: sotto al filmato il velo teneva il ritratto fermo del
Maestro, la rete dell'ordine BQ contro il rettangolo nero; e dichiarava il
filmato pronto appena chiamato `play()`. Nell'istante fra la carta che se ne
va e il primo quadro della texture si vedeva lui, *"la grafica precedente
dello stesso Maestro"*; subito dopo, il filmato che parte dal nero.

**La cura**: sotto al filmato adesso sta il suo fotogramma zero, estratto
senza toccare i tre mp4 e decodificato prima di servire. I tre filmati
partono dal nero, quindi sotto c'e' il nero del filmato stesso. Un solo ramo
di codice per tutti e tre i Maestri. **L'intro non ha il lampo**: sotto il
suo video c'e' gia' il nero, che e' il colore da cui il video parte.

---

## DP.03, LA DISSOLVENZA E IL RALLENTAMENTO. CHIUSA

Negli ultimi due secondi la velocita' scende da uno a 0,75 con una curva
senza spigoli; nell'ultimo secondo e mezzo il volume scende a zero **in
decibel a passo costante**, fino a meno sessanta, perche' una discesa
lineare dell'ampiezza l'orecchio la sente ferma e poi precipitare. Finiscono
insieme; l'ultimo fotogramma resta finche' la persona non tocca *"Entra nel
Cerchio"*. Scritto una volta nel velo, per tutti e tre i Maestri. I due
limiti sono dichiarati nel codice: la velocita' la applica la piattaforma;
il conto del filmato passato e' una stima col tempo del telefono.

---

## DP.04, LA PROVA A VIDEO. CHIUSA

**Perche' un banco.** Il Realme di collaudo ha le tre scale d'animazione a
zero: li' la Carta di Nascita salta all'ultimo momento e il video del
Maestro non nasce, come vuole Riduci Movimento. Rifare l'onboarding avrebbe
cancellato i dati dell'app del fondatore, cambiare le animazioni avrebbe
toccato le impostazioni del telefono. `tool/banco_del_risveglio.dart` monta
**le stesse schermate vere** col movimento acceso, in una build di profilo
firmata come la release e installata sopra senza cancellare niente; poi la
release e' tornata al suo posto.

| punto | esito | schermata |
|---|---|---|
| il mazzo gira col dorso vero | **si'** | `01_il_mazzo_che_gira_col_dorso_vero.jpg` |
| la riga che spiega il numero | **si'**, con le cifre accese e poi *"3 + 5"* nella riduzione | `02_il_calcolo_si_spiega.jpg` |
| la carta rivelata e' l'artwork vero | **si'** | `03_la_carta_vera_e_il_pulsante_oro.jpg` |
| il pulsante oro, accanto a un'altra schermata | **si'**, identico a *"Entra nel Cerchio"* | `04_il_pulsante_oro_accanto_a_entra_nel_cerchio.jpg` |
| il passaggio al video senza il lampo | **si'** in dodici catture, nessuna col ritratto; **il limite**: una cattura ogni mezzo secondo circa, contro un passaggio che dura meno. Lo prova la guardia: sotto al filmato c'e' il fotogramma zero, il ritratto non e' in albero | `05_il_passaggio_al_video_senza_lampo.jpg` |
| la fine del video, guardata e ascoltata | **misurata**: il volume della traccia letto dal mixer del telefono scende 0, -1,7, -7,4, -13, -18, -24, -29, -32, -38, -45 dB e poi il silenzio, in 1,8 secondi, con la fine del video; la durata vera del filmato e' 10,43 a 10,59 secondi contro i suoi 10,04, cioe' il rallentamento c'e' (il numero comprende la coda del buffer audio, che dall'esterno non si separa). **Ascoltata no**: da qui non si ascolta, si misura | `06_l_ultimo_fotogramma_resta.jpg` |

**La prova ha trovato tre guasti prima della build**, tutti curati con la
loro riga vista rossa:

1. **L'anello girava spostato di mezza scena a destra**; si centrava solo
   da fermo. La `Stack` della scena, prima del momento finale, aveva come
   unico figlio non posizionato un vuoto e usciva larga zero. Padre: questa
   voce, la prima stesura. Le prove al banco non guardavano la misura della
   tela: il difetto si e' visto solo nelle catture.
2. **La prima cura del punto 1 era sbagliata**: l'avevo attribuito al
   `drawAtlas` e l'ho tolto; il difetto e' rimasto uguale. Solo la cattura
   al banco a tre istanti ha mostrato la causa vera.
3. **Il calcolo diceva 8 e si girava La Giustizia col suo XI.** Il calcolo
   della carta sceglieva per posizione nell'elenco del corpus, dove la
   Giustizia e' l'ottava; le arti portano la numerazione Rider-Waite, quella
   di Arrien e di Greer, dove l'VIII e' La Forza. Adesso la carta e' quella
   che porta il numero. **Cambia soltanto per chi fa 8 o 11**, anche nel
   Passaporto. Padre: ordine CE voce 13, con la prova che lo fissava.

---

## DP.05, IL RAPPORTO. CHIUSA

In `docs/ordini/RAPPORTO_ORDINE_DP.md`.

---

## LE GUARDIE

`la_carta_di_nascita_e_una_carta_vera` e' nuova: tutto il mazzo e il suo
dorso, la carta davanti al centro, la tela larga quanto la scena, la carta
vera e il suo settanta per cento, il numero spiegato, il pulsante oro, un solo
pulsante nell'onboarding, il numero uguale al numerale. `il_video_del_maestro
_si_rivela` porta il fotogramma zero e le curve del congedo;
`la_rivelazione_non_mente_sul_calcolo` segue la regia nuova. **Quattordici rossi
visti**, ognuno con l'innesto verificato e il ripristino controllato.
