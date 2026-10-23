# I TRATTI DEL VOLTO, MISURA PER MISURA

Ordine CR voce 05, 6 settembre 2026.

**L'ordine chiedeva questo**: *"Nel referto scrivi, per ogni tratto letto: quali
landmark lo compongono, quale rapporto viene calcolato, e le soglie che separano
una lettura dall'altra. Un tratto che non sai scrivere in questa forma non
entra."*

## LA CORREZIONE ALL'ORDINE, ACCETTATA DAL FONDATORE

La voce CR.12 lo dice per esteso: **CR.05 era in gran parte gia' rispettato**, e
l'Architetto non lo aveva misurato prima di scriverlo. `FaceClassifier.leggi`
calcolava gia' rapporti veri su misure vere. Il difetto stava tutto nel **dato in
ingresso**: davanti a un muro arrivava una sagoma disegnata a mano, e su quella
la geometria funzionava benissimo. Era giusta la formula, era falso il volto.

Chiuso quello con CR.01, questa voce si riduce a due cose: **scrivere i numeri**
e **provare la ripetibilita'**.

## COSA E' CAMBIATO NEL DATO IN INGRESSO

| | prima, ML Kit | adesso, MediaPipe |
|---|---|---|
| punti disponibili | contorni, poche decine per parte | **478 landmark 3D** |
| iride | assente | inclusa |
| angoli della testa | assenti | yaw, pitch, roll |
| espressione | assente | 52 coefficienti |
| iOS | face mesh non disponibile | disponibile |

Le formule qui sotto **non sono cambiate**: cambia la precisione dei punti su cui
girano.

## LA TAVOLA

Tutte le misure sono **rapporti**, mai valori assoluti: un volto vicino alla
fotocamera e uno lontano danno pixel diversi e rapporti uguali. `w` e `h` sono
larghezza e altezza del riquadro che contiene l'ovale.

| Tratto | Punti che lo compongono | Rapporto calcolato | Soglie |
|---|---|---|---|
| **Forma del volto** | ovale, a tre altezze: fronte 5-30%, zigomi 40-60%, mascella 68-90% | `w/h`, `mascella/fronte`, `mascella/zigomi` | triangolare se `mascella/fronte < 0.80`; ovale se `w/h < 0.74`; quadrato se `mascella/zigomi > 0.90` e `w/h >= 0.80`; altrimenti tondo |
| **Fronte** | sopracciglia (punto piu' alto) contro il bordo alto dell'ovale | `(y sopracciglia − y fronte) / h` | verticale se `>= 0.33`, altrimenti sfuggente |
| **Sopracciglia** | i due contorni, 10 punti ciascuno | salita dell'apice sulla base, e angolo all'apice in radianti | dritte se salita `< 0.06`; angolate se apice `< 2.75 rad` (circa 158 gradi); altrimenti curve |
| **Distanza fra gli occhi** | centri dei due occhi, larghezza media di un occhio | `distanza fra i centri / larghezza di un occhio` | la soglia separa occhi ravvicinati da distanti attorno al rapporto due |
| **Grandezza degli occhi** | altezza media dei due contorni | `altezza occhio / h` | grandi se `>= 0.085`, altrimenti raccolti |
| **Naso** | ponte (radice) e base (narici) | `(y base − y radice) / h` | lungo se `>= 0.33`, altrimenti corto |
| **Labbra** | bordo alto del labbro superiore, bordo basso dell'inferiore | `spessore / larghezza della bocca` | piene se `>= 0.34`, altrimenti sottili |
| **Bocca** | i due angoli | `larghezza bocca / w` | larga se `>= 0.42`, altrimenti piccola |
| **Mento** | ovale a 88-100% contro 68-90% | `larghezza mento / larghezza mascella` | ampio se `>= 0.62`, altrimenti a punta |
| **Mascella** | ovale a 68-90% | `larghezza mascella / w` | la soglia separa mascella marcata da morbida |
| **Zigomi** | i due punti di guancia, o l'ovale a meta' altezza | `larghezza zigomi / larghezza mascella` | alti se `>= 1.04`, altrimenti morbidi |

## LA MARCATEZZA, CHE NON E' UN GIUDIZIO

Ogni tratto porta con se' un numero da zero a uno che dice **quanto quel tratto
si stacca dal volto neutro**: non quanto e' bello, non quanto e' buono. Serve a
scegliere quale tratto guida la lettura, perche' un volto ha undici tratti e un
responso che li elenca tutti non e' un responso, e' un inventario.

Il neutro di riferimento e' `w/h = 0.82` per la forma e `mascella/fronte = 0.92`.

## COSA QUESTA TAVOLA NON DICE

**Non dice se una soglia e' quella giusta.** I numeri vengono dal lavoro
precedente e non sono stati tarati su un campione di volti: separano, ma dove
cada esattamente il confine fra un naso lungo e uno corto e' una scelta, non una
misura. Dichiararlo qui vale piu' che nasconderlo, ed e' la stessa onesta' con
cui le soglie della scansione sono marcate provvisorie.

**Non dice niente sulla persona.** Il rapporto e' un numero geometrico; il
significato che la tradizione gli attribuisce e' un'altra cosa, sta in
`mian_xiang.md`, e non si mescola con questa tavola.
