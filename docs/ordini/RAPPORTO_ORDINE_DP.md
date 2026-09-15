# RAPPORTO DELL'ORDINE DP, L'ONBOARDING SMETTE DI STONARE

**15 settembre 2026.** Ramo `claude/esoteric-circle-master-order-e798aj`.
Build **2262**. Le sezioni sono nell'ordine chiesto dalla voce DP.05; il
manifesto voce per voce sta in `docs/ordini/ORDINE_DP_MANIFESTO.md`, le
schermate in `docs/collaudo/DP/`.

---

## 1. LE TRE PREMESSE

| premessa | esito |
|---|---|
| P1, 79 file in `assets/img/mazzo-tarocchi/`, le 78 carte e il dorso | **vera**; ci sono anche le 79 miniature |
| P2, la rivelazione in 315 righe, nessun asset, tutto dipinto in codice | **vera** |
| P3, il video con `setVolume(1)` e `play()`, nessuna dissolvenza ne' rallentamento | **vera** |

---

## 2. I FOTOGRAMMI AL SECONDO SUL GIRO DELLE SETTANTOTTO

Misurati sul Realme di collaudo, in profilo, con la stessa scena e lo stesso
fondo cosmico dell'onboarding, contando ogni fotogramma costruito per tutti i
sette secondi e mezzo della rivelazione.

| cosa | fotogrammi al secondo |
|---|---:|
| scena vuota, un quadrato che ruota: il massimo del telefono | 60,3 e 60,5 |
| **78 carte visibili, tre giri** | **60,1, 60,2, 60,1** |
| 56 carte visibili | 60,1 |
| 40 carte visibili | 60,0 |

**Sopra i cinquanta, al massimo dello schermo: nessuna carta tolta.** La
prima stesura ne faceva fra 38 e 43, con settantotto figli ognuno dentro un
ritaglio arrotondato; adesso le carte si dipingono da una sola immagine
decodificata, ognuna nel suo rettangolo. In un giro su tre i fotogrammi che
superano i 16,7 millesimi di latenza sono stati molti, 294, ma nessuno e'
saltato: il ritmo e' restato 60.

---

## 3. I PULSANTI DELL'ONBOARDING FUORI STANDARD, E CORRETTI

Lo standard e' quello indicato dal fondatore, *"Chi altro ti accompagna"* e
*"La tua Carta di Nascita"*: fondo oro, testo scuro, pillola, il corpo a peso
600. Adesso e' un componente solo, `PulsanteDelRisveglio`, usato nove volte.

| schermata | com'era |
|---|---|
| Carta di Nascita, *"Guarda il cielo..."* | il viola del tema col testo scuro: il pulsante che il fondatore non leggeva |
| Ritrovamento, *"Entra nel Cerchio"* | il viola del tema, il carattere dell'etichetta |
| Invito, *"Riconosci chi ti ha invitato"* | il carattere dell'etichetta, nessuna pillola |
| Primo Approdo, *"Avanti"* e *"Entra nel Cerchio"* | il carattere dell'etichetta, nessuna pillola |
| Carta del Cielo, *"Scopri chi risuona con te"* | il carattere della lettura |
| Risonanza, *"Rivela il tuo Maestro"* | il carattere della lettura |

Resta com'e' la porta per chi torna, nella prima schermata: e' secondaria per
scelta scritta accanto a lei. Una guardia conta ogni pulsante scritto a mano
nell'onboarding: con quella porta sola si ferma.

---

## 4. LA PROVA A VIDEO, I SEI PUNTI

**Il telefono di collaudo ha le animazioni di sistema spente**: li' la Carta
di Nascita salta all'ultimo momento e il video del Maestro non nasce, come
vuole Riduci Movimento. Rifare l'onboarding avrebbe cancellato i dati
dell'app del fondatore; cambiare le animazioni avrebbe toccato le
impostazioni del telefono. La prova e' fatta con `tool/banco_del_risveglio.dart`,
che monta le stesse schermate vere col movimento acceso, in una build di
profilo installata sopra senza cancellare niente. Poi la release 2262 e'
tornata al suo posto.

| punto | esito | schermata |
|---|---|---|
| il mazzo gira mostrando il dorso vero | **si'** | `01_il_mazzo_che_gira_col_dorso_vero.jpg` |
| la carta rivelata e' l'artwork vero | **si'**: La Forza, VIII, con i cartigli del mazzo | `03_la_carta_vera_e_il_pulsante_oro.jpg` |
| la riga che spiega il numero | **si'**, sotto le cifre della data che si accendono; nella riduzione *"3 + 5"* | `02_il_calcolo_si_spiega.jpg` |
| il pulsante oro, accanto a un'altra schermata | **si'**, identico a *"Entra nel Cerchio"* della rivelazione del Maestro | `04_il_pulsante_oro_accanto_a_entra_nel_cerchio.jpg` |
| il passaggio al video senza il lampo | **si'** nelle dodici catture, nessuna col ritratto. **Il limite**: una cattura ogni mezzo secondo circa, contro un passaggio che dura meno. La guardia prova la struttura: sotto al filmato c'e' il suo fotogramma zero, il ritratto non e' in albero | `05_il_passaggio_al_video_senza_lampo.jpg` |
| la fine del video, guardata e ascoltata | **guardata**: l'ultimo fotogramma resta. **Misurata, non ascoltata**: il volume della traccia letto dal mixer del telefono scende 0, -1,7, -7,4, -13, -18, -24, -29, -32, -38, -45 dB e poi il silenzio, in 1,8 secondi, con la fine del video. La durata vera del filmato e' fra 10,43 e 10,59 secondi contro i suoi 10,04: il rallentamento c'e'; il numero comprende la coda del buffer audio, che dall'esterno non si separa | `06_l_ultimo_fotogramma_resta.jpg` |

**La prova ha trovato tre guasti prima della build**, curati con la loro riga
vista rossa:

1. **L'anello girava spostato di mezza scena a destra** e si centrava solo
   da fermo: la scena usciva larga zero finche' la carta finale non entrava.
   Padre: questa voce, la prima stesura.
2. **La prima cura del punto 1 era sbagliata**: l'ho attribuito al disegno
   ad atlante e l'ho cambiato: il difetto e' rimasto uguale. Solo la
   cattura al banco a tre istanti ha mostrato la causa.
3. **Il calcolo diceva 8 e si girava La Giustizia col suo XI**
   (`07_trovato_sul_telefono_8_e_poi_XI.jpg`). La carta si prendeva per
   posizione nell'elenco del corpus, dove la Giustizia e' l'ottava; le arti
   portano la numerazione Rider-Waite, quella del metodo di Arrien e Greer,
   dove l'VIII e' La Forza. **Adesso la carta e' quella che porta il
   numero**, verificato su un secolo di date. Cambia soltanto per chi fa 8 o
   11, anche nel Passaporto. Padre: ordine CE voce 13.

**Una cosa da guardare, non un guasto**: l'anello delle settantotto,
sovrapposte in profondita' come chiede l'ordine, da vicino ha l'aspetto di
un bracciale di carte: il dorso intero si legge solo sulla carta davanti.
Allargarlo e' una scelta di gusto: la lascio al fondatore
(`08_la_rivelazione_intera.jpg`).

---

**I TRE DIFETTI SONO CHIUSI.**
