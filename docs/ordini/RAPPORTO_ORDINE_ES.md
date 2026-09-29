# RAPPORTO DELL'ORDINE ES

L'Oroscopo completo, il Sigillo del Sogno e le voci aperte dell'ordine ET.
Ordine del 28 settembre 2026 in quattro pezzi, trentasette voci; lavoro dal
28 settembre. Ramo `claude/esoteric-circle-master-order-e798aj`. Manifesto
`docs/ordini/ORDINE_ES_MANIFESTO.md`, prove in `docs/collaudo/ES/`, quelle
del telefono in `docs/collaudo/ES/realme/`. **Questo ordine non consegna
niente**: le build di prova si installano sul Realme per le catture e non si
consegnano.

**STESURA IN CORSO.** Il rapporto si aggiorna blocco per blocco; il conto qui
sotto e' quello del manifesto al commit indicato, riletto dal file.

**Il conto** (manifesto al commit `7e1db15d`): 37 voci, **2 chiuse**, **18
aperte in attesa di verifica**, **17 da fare**.

## LE VOCI CHIUSE, CON LA LORO PROVA

- **ES.26, il retro delle schede a 402 punti.** `docs/collaudo/ES/retro_402.txt`.
  Schede col testo del retro rimpicciolito in home a 402 punti, 0 su 67; il
  testo in home e' quello dei domini (15,9, 15,2 e 13,0 punti nei tre
  formati). Quattro catture dal Realme a 402 punti. Lo schermo del Realme:
  prima densita' 480 e 360 punti, durante "Larghezza minima" 402 (densita'
  429), dopo di nuovo 480 e 360, riletto da adb.
- **ES.27, l'intro registrata sul Realme.** `docs/collaudo/ES/intro_realme.txt`.
  Durata dell'intro registrata 14,0 secondi contro i 14 del sorgente,
  correlazione 0,994; le scale delle animazioni del Realme prima 0,0,
  durante 1,0, dopo 0,0.

## LE VOCI APERTE, E CHE COSA MANCA A CIASCUNA

Tutte le voci aperte sono prodotte e agganciate, misurate in prova, e
aspettano la verifica a video sul Realme (e la ES.17 tre sere di
osservazione). Per ciascuna il manifesto porta la prova e la misura.

- **ES.01** Breve e Approfondita: senza carta, Approfondite identiche alla
  Breve da 48 su 48 a 0 (`docs/collaudo/ES/profondita.txt`).
- **ES.02** il settimanale: 0 righe su 112 senza un fatto del cielo; fasi
  della Luna entro 0,47 minuti dal JPL (`docs/collaudo/ES/settimana.txt`).
  Manca la lettura una tantum con gli Eos (ES.06).
- **ES.03** il mensile: 0 righe su 120 senza un fatto del cielo, le due
  eclissi di febbraio 2027 trovate (`docs/collaudo/ES/mese.txt`).
- **ES.05** gli emblemi dei periodi: 9 su 9 uguali byte per byte; la card
  di ogni periodo si vedra' quando i periodi avranno la loro card.
- **ES.07** il segno della tradizione in cima: 0 su 6 tradizioni lasciano
  l'occidentale; 14 figure su 14 uguali byte per byte.
- **ES.10** le note delle sette tradizioni, 62 affermazioni con la fonte
  (`docs/collaudo/ES/tooltip.txt`).
- **ES.11** le quattro tradizioni in arrivo: clessidra, emblema, segno
  calcolato, 0 su 40 segni diversi dalla fonte. **Otto nomi dei decani**
  egizi vanno riscontrati sull'edizione Pingree di Efestione.
- **ES.13** la card con nome senza cognome e nascita.
- **ES.14** il numero al centro del suo riquadro.
- **ES.16** il Sigillo del Sogno di Medora senza rune.
- **ES.17** una sola notifica per Dono (da schierare con le funzioni).
- **ES.28** il livello dal cielo: 0 su 48 livelli che non ne dipendono.
- **ES.29** numero e colore con una regola: da 30 su 30 senza regola a 0.
- **ES.30** il metodo sulle quattro schede del giorno.
- **ES.31** l'invito ai dati di nascita sotto "Interroga il cielo".
- **ES.32** l'ora d'oro: scarto medio dal JPL 0,18 minuti; mancano le
  notifiche.
- **ES.33** la ruota del passaggio: 0 su 80 ruote diverse dalla frase.
- **ES.34** la ragione per tornare domani: 0 su 30 diverse dal giorno dopo.

## LE VOCI DA FARE

ES.04 (l'annuale), ES.06 (piani ed Eos), ES.08 (Cinese), ES.09 (Vedica),
ES.12 (amici), ES.15 (online), ES.18 (il Sigillo del Sogno da cima a fondo),
ES.19-ES.25 (le voci dell'ordine ET), ES.35, ES.36, ES.37.

## I DIFETTI TROVATI, OGNUNO COL SUO PADRE

- Il numero fortunato attaccato a sinistra: padre DD.09, commit `b6188d20`.
- La riga della Runa del Tramonto nel Sigillo di Medora: padre P.18, portata
  dalla DD.04.
- Tre notifiche per un Dono: padre CG.16 (il tag `dono_1104` non sostituiva la
  locale 1104) e il giro del server non allineato all'orologio.
- Le chiavi `avviso_dono_` che non si cancellavano e poi non si scaricavano:
  padre ES.17 (`c9bdfc06`, e la riparazione `dd53d8f1`), mio.
- "Interroga il cielo" spinto sotto la piega dall'invito della ES.31, il
  pulsante in maiuscoletto su due righe, foglio e dialogo fuori dalla porta
  del velo, InkWell senza l'interruttore del silenzio, un `fontSize` scritto a
  mano, il Sole di nascita preso dal motore dei transiti, un TextPainter
  senza la scala, due ", e", una freccia non dichiarata: padre il blocco 1 e 2
  di quest'ordine (`a9e52f66`, `b6106fb7`), miei, presi dalla suite intera
  prima di spingere.
- La Luna di `Effemeridi` sbaglia fino a 0,27 gradi: non e' un difetto nuovo
  (e' dichiarato nel file), ma per i segni vedici e arabi non basta; per loro
  c'e' la Luna di Meeus intera, `lib/core/astro/la_luna_intera.dart`.

## LE COSE CHE ASPETTANO TE

1. **La nascita italiana la sera della vigilia del Capodanno cinese**, quando
   a Pechino e' gia' il giorno dopo: l'app usa la data civile del luogo di
   nascita. Se preferisci la data di Pechino, si cambia in un punto.
2. **La tavolozza dei colori per segno del corpus** (`docs/corpus/oroscopo.md`)
   non la chiama piu' nessuno dalla ES.29: il corpus e' tuo, e senza il tuo si'
   non la tolgo.
3. **La Settimana e il Mese si aprono gia' col piano**; le letture una tantum
   con gli Eos arrivano con la ES.06.
