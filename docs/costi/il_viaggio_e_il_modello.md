# Il Viaggio dello Sciamano e il modello

Ordine EW, voce EW.02, 2 ottobre 2026.

> *"Ma perché 10 discese del viaggio? Le discese sono 4 per rivelare l'animale
> e poi l'utente può rientrare per nutrire l'animale e "curarlo" e fargli altre
> domande. Tuttavia non avevo idea che il viaggio toccasse la AI..."*

## In breve

- **Le discese del piano non sono dieci.** Prima della rivelazione la discesa
  e' **una al giorno per tutti**, quattro giorni per le quattro discese che
  rivelano l'animale. Dopo il riconoscimento le discese sono **1, 1, 1 e 2 al
  giorno** (Viandante, Iniziato, Adepto, Illuminato), i segni chiesti
  all'animale **1 a settimana, 3 a settimana, 1 al giorno e 5 al giorno**,
  nutrire **sempre**.
- **Dieci e' un'altra cosa: un tetto tecnico che la persona non vede**,
  sopra il piano, "per la sola difesa dai costi". Oggi vale **dieci discese e
  dieci segni al giorno** che arrivano al modello; oltre, il Viaggio continua a
  rispondere con le vie di riserva. Nessun piano ci arriva: il massimo del piano
  e' 2 discese e 5 segni.
- **Il Viaggio tocca il modello in tre punti dal 12 e 13 settembre 2026**: la
  domanda scritta capita (Flash-Lite), la scena e i tre testi della discesa
  (Flash), il segno dell'animale (Flash-Lite). **Nutrire non chiama nessun
  modello**, e "curare" come gesto con un limite non esiste nel codice.
- **Costa poco**: una discesa 0,0035 dollari, un segno 0,0001. Un Illuminato
  che usa tutto il Viaggio ogni giorno costa **0,23 dollari al mese**.

## Discese, rientri e segni per piano, dal codice

Fonte: la matrice dei piani, `lib/core/entitlement/plan_catalog.dart`, righe
"Discese nel Mondo di Sotto", "Segni chiesti all'animale guida" e "Nutrire
l'animale guida"; la regola della rivelazione in
`lib/core/viaggio/tetti_del_viaggio.dart`
(`TettiDelViaggio.discesePrimaDellaRivelazione = 1`).

| | Viandante | Iniziato | Adepto | Illuminato |
|---|---|---|---|---|
| Discese prima della rivelazione | 1 al giorno | 1 al giorno | 1 al giorno | 1 al giorno |
| Discese dopo il riconoscimento (i rientri) | 1 al giorno | 1 al giorno | 1 al giorno | 2 al giorno |
| Segni chiesti all'animale | 1 a settimana | 3 a settimana | 1 al giorno | 5 al giorno |
| Nutrire l'animale | Sempre | Sempre | Sempre | Sempre |
| **Tetto tecnico al modello** (invisibile) | 10 discese e 10 segni al giorno | uguale | uguale | uguale |

**In Demo** (la build del fondatore) i limiti del piano cadono, il tetto
tecnico no: per le prove lunghe c'e' il comando di collaudo che lo alza, solo
in Demo (`IlTettoDelleChiamate.alzatoPerIlCollaudo`).

**Dove si conta il tetto tecnico**: nel telefono, nelle preferenze locali
(`SharedPreferences`, chiavi `viaggio.tetto.discese` e `viaggio.tetto.segni`).
Se l'archivio non risponde, il Viaggio chiama lo stesso: e' una difesa dai
costi, non una regola del metodo. Reinstallare l'app azzera il conto del
giorno.

## Il tetto di dieci: da quale ordine, e perche' dieci

**Il numero dieci e' nelle parole dell'ordine DI, voce DI.15, del 12 settembre
2026** (il testo dell'ordine come arrivato a Code, trascrizione della sessione
`410c8eda`):

> *"Tetto tecnico oltre il piano, per la sola difesa dai costi: dieci chiamate
> al modello al giorno per utente, contando discese e segni insieme."*

Code lo ha messo nel codice col commit `326176c1` del 13 settembre
(`IlTettoDelleChiamate`), e il manifesto DI ha misurato che l'Illuminato che
usa tutto arrivava a **9,5 chiamate al giorno**, cioe' a filo del tetto.

**Due giorni dopo l'unita' e' cambiata, sempre per ordine.** Ordine DL, voce
DL.09, 14 settembre 2026:

> *"Il tetto tecnico deve contare le DISCESE, non le chiamate, perche' il
> piano concede discese e una discesa costa due chiamate. Dieci chiamate
> valgono cinque discese, e nessuno se ne era accorto. Il numero resta dieci
> ma cambia l'unita': dieci discese e dieci segni al giorno, contati
> separatamente, e le chiamate seguono."*

Commit `a3e80896`. **Perche' dieci, nessuno dei due ordini lo dice**: e'
scritto come un numero di difesa, non derivato da un conto. Il conto che oggi
si puo' fare e' questo: col piano piu' alto una persona fa al massimo 2 discese
e 5 segni al giorno, quindi il tetto scatta solo se qualcosa scavalca il piano
(la Demo, o un difetto). In quel caso il tetto costa al massimo
10 × 0,0035 + 10 × 0,0001 = **0,036 dollari al giorno**, 1,09 al mese.

## Quante chiamate e quanto costa una discesa

Misurato dal banco del costo (voce EW.04, `docs/costi/costo_per_funzione.md`),
venti discese con la domanda scritta e venti segni, col codice vero:

| Gesto | Chiamate al modello | Modelli | Costo medio | Costo massimo |
|---|---|---|---|---|
| Una discesa con la domanda scritta | 3,80 in media (1 domanda capita + 2,85 scene) | Flash-Lite e Flash | 0,00345 $ | 0,00393 $ |
| Un segno chiesto all'animale | 1,05 | Flash-Lite | 0,00012 $ | 0,00127 $ |
| Nutrire l'animale | 0 | nessuno | 0 | 0 |

**La scena e' chiesta in media quasi tre volte per discesa**: le guardie del
responso del Viaggio scartano le scene che non reggono e la chiedono di nuovo,
fino a tre volte entro sei secondi. La domanda capita si chiama solo alla
prima discesa di un cammino con la domanda scritta a mano: dentro un cammino il
tema e' gia' capito (ordine DQ, voce DQ.01), e le discese dopo costano solo la
scena: 0,00338 delle 0,00345 di una discesa sono la scena, la domanda capita
ne costa 0,00007.

## Il Viaggio al mese, per piano, usando tutto

| Piano | Discese al mese | Segni al mese | Dollari al mese |
|---|---|---|---|
| Viandante | 30 | 4,3 | 0,105 |
| Iniziato | 30 | 12,9 | 0,107 |
| Adepto | 30 | 30 | 0,108 |
| Illuminato | 60 | 150 | 0,228 |

(30 discese × 0,0035 + segni × 0,00012; il primo mese le quattro discese
della rivelazione sono comprese nelle trenta.)

## Le tre chiamate, dal codice

| Punto | File | Modello | Ordine che l'ha introdotto |
|---|---|---|---|
| La domanda capita (Scendi con una domanda scritta) | `lib/core/viaggio/la_domanda_capita.dart` | `gemini-2.5-flash-lite`, europe-west1 | DI.02, commit `50cedbce` |
| La scena e i tre testi della discesa | `lib/core/viaggio/la_scena_dal_modello.dart` | `gemini-2.5-flash`, europe-west1 | DI.03, commit `54687752` |
| Il segno dell'animale | `lib/core/viaggio/il_segno_dell_animale.dart` | `gemini-2.5-flash-lite`, europe-west1 | DI.14, commit `5df1bfe6` |

L'ordine DI stimava il segno *"circa 0,0004 dollari a segno con Gemini 3.5
Flash Lite"*: col modello che l'app chiama davvero, `gemini-2.5-flash-lite`, il
segno misurato costa 0,00012.
