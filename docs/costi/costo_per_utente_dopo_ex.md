# Quanto costa un utente che usa tutto, dopo l'ordine EX

Ordine EX, voce EX.11, 2 ottobre 2026.

> *"30% Dopo iva e Store, 2,36$."*

## In breve

Il mese di una persona che usa **ogni limite del suo piano ogni giorno per
trenta giorni**, LIVE compreso coi minuti del piano, **senza la cache** (ogni
domanda paga l'ingresso intero: e' il caso peggiore, come nell'ordine EW).

| Piano | Prima dell'ordine EX | Dopo l'ordine EX | Tetto (30 per cento dopo IVA e store) | Sotto il tetto? | Domande in piu' al giorno che starebbero sotto il tetto |
|---|---|---|---|---|---|
| Viandante | 0,84 $ | **0,53 $** | (gratuito) | | |
| Iniziato | 5,66 $ | **1,28 $** | 2,36 $ | si', 54 per cento del tetto | **7** |
| Adepto | 11,90 $ (LIVE 2,13) | **3,34 $** (LIVE 1,28) | 4,72 $ | si', 71 per cento del tetto | **9** |
| Illuminato | 31,73 $ (LIVE 5,33) | **5,42 $** (LIVE 2,56) | 7,08 $ | si', 77 per cento del tetto | **11** |

Il calcolo e' `tool/i_conti_del_costo_ex.py`, l'uscita
`docs/costi/i_conti_del_costo_ex.txt`. Con la cache misurata i numeri sono
vicini (Iniziato 1,34, Adepto 3,44, Illuminato 5,55): al banco della qualita'
la quota presa dalla cache cambia molto da un giro all'altro (fra il 43 e il
73 per cento), e la cache implicita non e' garantita (`docs/collaudo/EX/la_cache.txt`),
quindi il conto che vale e' quello senza cache.

## Dopo l'EX Aggiunta 3: le domande si alzano

> *"Cmq, alziamo subito il limite e poi chiediamo nuova build per android e
> pronta per codemagic"*; *"Poco sotto il margine (Consigliata)"*.

Domande ai Maestri al giorno 3, 12, 18 e 22 (erano 3, 6, 10 e 13), tutto il
resto uguale. Stesso conto, senza cache, LIVE compreso, rune dal corpus:

| Piano | Con 3, 6, 10, 13 domande | Con 3, 12, 18, 22 domande | Tetto | Margine che resta |
|---|---|---|---|---|
| Iniziato | 1,28 $ | **2,18 $** | 2,36 $ | 0,18 $, circa una domanda al giorno |
| Adepto | 3,34 $ | **4,54 $** | 4,72 $ | 0,18 $, circa una domanda al giorno |
| Illuminato | 5,42 $ | **6,77 $** | 7,08 $ | 0,31 $, circa due domande al giorno |

Tutti e tre i piani restano sotto il tetto. Le domande in piu' costano 0,005 $
l'una a freddo (il costo misurato al giro finale del banco della qualita').

## Dopo l'EX Aggiunta 4: meno risposte rifatte

> *"Voglio tutto sistemato."*

Stesso conto, senza cache, LIVE compreso, rune dal corpus; le domande e i
tocchi del "Vai piu' a fondo" dal giro finale del banco della qualita' dopo le
voci EX.04 ed EX.07 (`ex07j`, `GIRO_DOPO` di `tool/i_conti_del_costo_ex.py`):
una domanda a freddo da 0,00495 $ a 0,00419 $, 1,33 chiamate per risposta
invece di 1,71. Le discese del Viaggio restano al costo dell'EW: la scena
misurata dopo l'EX.10 costa 0,00310 $ su 1,8 chiamate, perche' le due riserve
allungano l'uscita.

| Piano | Prima dell'Aggiunta 4 | Dopo l'Aggiunta 4 | Tetto | Margine che resta |
|---|---|---|---|---|
| Iniziato | 2,18 $ | **1,88 $** | 2,36 $ | 0,48 $ |
| Adepto | 4,54 $ | **4,10 $** | 4,72 $ | 0,62 $ |
| Illuminato | 6,77 $ | **6,23 $** | 7,08 $ | 0,85 $ |

Tutti e tre i piani restano sotto il tetto, con piu' margine di prima. La cache
esplicita (EX.05) non e' in questo conto: si accende solo sopra 23 richieste
all'ora sull'insieme della chat, e a quel traffico il conto e' quello di
`docs/collaudo/EX/la_cache_garantita.txt`.

## Dopo le EX Aggiunte 5 e 6: i minuti nuovi e il lessico corretto corto

> *"Si fammi aggiunta ordine con aumento limiti di minuti. Ci saranno da
> cambiare anche le descrizione degli abbonamenti"*

Stesso conto, senza cache, LIVE compreso, rune dal corpus, con due cose
cambiate: i minuti del LIVE dell'Adepto e dell'Illuminato salgono da 60 e 120
a **80 e 150** al mese (EX Aggiunta 6), e le domande e i tocchi vengono dal
giro piu' caro dei tre giri finali del banco della qualita' col codice
consegnato (`ag5_finale1`, `GIRO_DOPO` di `tool/i_conti_del_costo_ex.py`):
una domanda a freddo 0,00428 $, 1,38 chiamate per risposta (gli altri due
giri 1,29 e 1,25). Il LIVE costa 0,0213 $ al minuto (EW.07): i 20 minuti in
piu' dell'Adepto valgono 0,43 $, i 30 dell'Illuminato 0,64 $.

| Piano | Dopo l'Aggiunta 4 | Dopo le Aggiunte 5 e 6 | Tetto | Margine che resta |
|---|---|---|---|---|
| Iniziato | 1,88 $ | **1,91 $** | 2,36 $ | 0,45 $ |
| Adepto | 4,10 $ | **4,58 $** | 4,72 $ | 0,14 $ |
| Illuminato | 6,23 $ | **6,93 $** | 7,08 $ | 0,15 $ |

Tutti e tre i piani restano sotto il tetto, 3 su 3; coi minuti nuovi l'Adepto
e l'Illuminato hanno un margine di circa una domanda e mezza al giorno.

## Da dove vengono i numeri

**I limiti** sono quelli della matrice nuova (EX.02): domande 3/6/10/13,
Vai piu' a fondo 0/2/2/3, confronti 0/1/2/3, carte estratte 3/6/10/15,
gettate 1/2/3/3, minuti LIVE 0/0/60/120 al mese (0/0/80/150 dall'EX
Aggiunta 6); discese, segni e sigilli
come prima.

**I costi per uso**, senza cache:

| Uso | Prima (ordine EW) | Dopo | Da dove |
|---|---|---|---|
| Una domanda a un Maestro (memoria piena) | 0,00694 $ | **0,00498 $** | EW per il rapporto fra il giro finale (fine4) e il giro prima2 del banco della qualita', 0,718; il prima2 a freddo costa come l'EW (0,00690) |
| Un tocco del Vai piu' a fondo | 0,00430 $ | **0,00046 $** | come sopra, rapporto 0,108: 20 tocchi su 24 non chiamano piu' il modello (EX.04) |
| Una gettata di rune | 0,00601 $ | **0** | il corpus dell'Architetto (EX.03): nessuna chiamata |
| Una carta estratta | 0,00069 $ | 0,00069 $ | un terzo della stesa da tre carte misurata dall'EW (0,00207). **Le stese da 1, 5 e 10 carte non esistono ancora: il loro costo e' una STIMA**, carte per 0,00069 |
| Una discesa del Viaggio | 0,00350 $ | 0,00350 $ | EX.10 aperta: la scena resta al modello |
| Un confronto, i sigilli, i segni, il titolo, i Ricordi | come l'EW | come l'EW | non toccati |
| Un minuto di LIVE in conversazione | 0,0213 $ | 0,0213 $ | EW.07, sul Realme |

**Le domande in piu'** sono lo spazio fra il mese al massimo e il tetto,
diviso per trenta giorni e per il costo di una domanda (0,00500 $ col suo
titolo). Sono un'indicazione per decidere, non una proposta: ogni domanda in
piu' alza anche il LIVE solo se la persona lo usa a voce, dove ogni turno vale
una domanda del giorno.

## La giornata al massimo, dopo (dollari, senza cache, rune dal corpus)

| Voce | Viandante | Iniziato | Adepto | Illuminato |
|---|---|---|---|---|
| Domande (col titolo) | 0,0113 | 0,0300 | 0,0500 | 0,0650 |
| Vai piu' a fondo | 0 | 0,0009 | 0,0009 | 0,0014 |
| Confronti | 0 | 0,0025 | 0,0050 | 0,0075 |
| Tarocchi (carte) | 0,0021 | 0,0041 | 0,0069 | 0,0103 |
| Gettate | 0 | 0 | 0 | 0 |
| Discese | 0,0035 | 0,0035 | 0,0035 | 0,0070 |
| Sigilli, segni, Ricordi | 0,0007 | 0,0015 | 0,0022 | 0,0041 |
| LIVE al mese | 0 | 0 | 1,28 | 2,56 |

Le cifre per voce stanno in `docs/costi/i_conti_del_costo_ex.txt` (righe
"dopo, al giorno"; la riga delle gettate li' e' quella col modello, qui a zero
perche' il corpus e' entrato).

## Che cosa ha abbassato il costo, voce per voce (Iniziato al massimo, senza cache)

- **I limiti nuovi (EX.02)**: le gettate da 20 a 2 al giorno erano quasi due
  terzi del costo dell'Iniziato (3,61 $ su 5,66); il Vai piu' a fondo da 3 a 2.
- **Le rune dal corpus (EX.03)**: le gettate che restano costano zero.
- **Meno risposte rifatte e il cielo nella richiesta (EX.07, EX.08)**: le
  chiamate per una domanda da 2,46 a 1,71 al banco della qualita'.
- **Il Vai piu' a fondo scritto insieme (EX.04)**: da 1,46 chiamate al tocco
  a 0,17.
- **La memoria compatta (EX.09)**: circa 500 token d'ingresso in meno per
  richiesta nelle conversazioni lunghe.

## Il Briefing, sezione 22, e la matrice nuova

Il Briefing non si tocca (regola dell'ordine): le differenze si elencano.

| Riga | Briefing §22 (Free, Tier 1, Tier 2, Tier 3) | Codice dopo l'EX.02 (Viandante, Iniziato, Adepto, Illuminato) |
|---|---|---|
| Domande a un Maestro | 1, 5, 10, illimitate al giorno | 3, 6, 10, 13 al giorno |
| Tarocchi carta singola | 1, 3, illimitati, illimitati | non c'e' piu' una riga a parte: carte estratte 3, 6, 10, 15 al giorno, in qualunque stesa |
| Stese complete | Eos pieno, Eos scontati, 5 al giorno, illimitate | contate a carte; la stesa da 10 solo Adepto e Illuminato |
| Rune, I-Ching, Pendolo | Eos, Eos scontati, inclusi, inclusi | gettate 1, 2, 3, 3 al giorno |
| Sinastria | 3, 5+, 5, illimitata | 3, 5, 5, 25 (non toccata dall'ordine) |
| Voce AI dei Maestri | No, No, Esclusiva, Si' | uguale, solo nel LIVE, 60 e 120 minuti al mese |
| Righe che il Briefing non ha | | Vai piu' a fondo, confronti, discese, segni, sigilli, minuti LIVE |
