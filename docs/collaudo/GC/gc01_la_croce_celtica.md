# GC.01, la stesa a dieci carte: la misura sul Realme

Ordine GC voce GC.01, 22 ottobre 2026. Il fondatore: *"La stesa a 10 carte, al
click su pulsante \"leggi le carte\" rallenta tantissimo, va a scatti e poi
manda in crash l'app che si chiude da sola."*

## Come si misura

- Telefono: Realme 767f596c, Android 13, 7,6 GB di RAM, schermo a 60 Hz.
- L'account di collaudo e' sul Viandante e la Croce Celtica si apre
  dall'Adepto; il piano lo decide il server e cambiarlo vorrebbe dire scrivere
  dati di produzione (R4). La misura si prende quindi con un banco
  (`tool/la_croce_celtica_dal_tocco.dart`), costruito in rilascio, che apre una
  scelta fra le quattro stese e monta la schermata vera della stesa con le
  carte coperte. Si scelgono le carte dal ventaglio e si tocca "Leggi le
  Carte": lo stesso percorso della persona. La chiamata al modello e' finta e
  torna un errore, quindi parla la lettura di casa (R2, nessuna spesa).
- Il banco e' costruito due volte con la stessa scelta: sul codice di prima
  (commit `55323422`, la testa del ramo all'inizio dell'ordine) e sul codice
  di dopo. Le quattro stese si misurano nello stesso ordine e nello stesso
  processo, prima tre, poi quattro, poi dieci, poi una carta.
- Dal tocco di "Leggi le Carte", per 25 secondi: la memoria del processo ogni
  0,4 secondi (`dumpsys meminfo`: PSS totale e memoria grafica), i fotogrammi
  del livello di Flutter (`dumpsys SurfaceFlinger --timestats`, istogramma
  present2present), il registro di sistema (`logcat`, cercando FATAL, ANR,
  lowmemorykiller).
- Strumenti: `misura_stesa.sh`, `fasi_stesa.sh` e `leggi_misura.py` nella
  cartella di lavoro della sessione; i numeri qui sotto sono quelli che hanno
  stampato.

## La causa trovata con la misura

Ogni carta dei Tarocchi si decodificava dall'arte piena, 853 per 1280 pixel,
anche quando a schermo era larga cinquanta punti (le bolle) o settanta (il
tavolo). Sulla stesa a dieci, fra le carte in piedi sul tavolo e le dieci
bolle, la memoria grafica saliva di 54 MB al tocco. PADRE: ordine FL voce 05
(le carte sul tavolo e in piedi, `Image.asset` della piena) e ordine CO voce
06 (la carta dentro la bolla con l'arte piena).

La cura (`TarotCardArt.gradinoPer`): la carta si decodifica alla misura in cui
si vede, in tre gradini e mai a ogni fotogramma: la miniatura del bundle (333
per 500) fino a 333 pixel veri, l'arte piena decodificata a 640 fino a quella
misura, l'arte piena intera oltre. La stessa regola vale per le carte degli
Angeli nell'Oracolo.

## Le misure, prima e dopo

| Stesa | PSS di picco, prima | PSS di picco, dopo | Grafica di picco, prima | Grafica di picco, dopo | Fotogrammi oltre 100 ms, prima | dopo | Il piu' lungo, prima | dopo |
|---|---|---|---|---|---|---|---|---|
| tre carte | 222 MB | 217 MB | 94 MB | 89 MB | 0 | 1 | 98 ms | 102 ms |
| quattro carte | 246 MB | 220 MB | 107 MB | 92 MB | 1 | 1 | 200 ms | 118 ms |
| dieci carte | 280 MB | 233 MB | 140 MB | 97 MB | 16 | 14 | 300 ms | 250 ms |
| una carta | 267 MB | 226 MB | 140 MB | 97 MB | 0 | 0 | 82 ms | 82 ms |

La prima misura della stesa a dieci, col banco che apriva subito la stesa (un
processo fresco): PSS da 184 a 264 MB, grafica da 73 a 127 MB, 14 fotogrammi
oltre 100 millisecondi, il piu' lungo 300.

In nessuna delle misure, prima o dopo, l'app si e' chiusa: il Realme ha 7,6 GB
di RAM, e la chiusura che il fondatore ha visto non si riproduce sul banco
(che non ha in memoria il resto dell'app, la casa, la musica, le schermate
aperte prima). La memoria grafica della stesa a dieci scende di 43 MB al
picco e di 57 MB rispetto al processo di prima.

## Gli scatti, finestra per finestra

Banco di dopo, stesa a dieci, fotogrammi a finestre di due secondi dal tocco:

| Finestra | Fotogrammi | Lunghi (66 ms e oltre) |
|---|---|---|
| 0-2 s | 123 | nessuno |
| 2-4 s | 112 | nessuno |
| 4-6 s | 51 | 200 ms, 250 ms per tre |
| 6-8 s | 56 | 66, 150, 200 ms per due |
| 8-10 s | 55 | 200 ms per due |
| 10-12 s | 61 | 66, 82, 200 ms per due |
| 12-14 s | 111 | 300 ms |
| 14-24 s | 128-130 ogni due secondi | nessuno |

Gli scatti stanno tutti nei dieci secondi in cui le dieci carte si girano una
alla volta e poi si alzano: circa un fotogramma da 200 millisecondi per carta.
