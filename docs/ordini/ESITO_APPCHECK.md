# ESITO: LA CARTA NATALE ARRIVA DAVVERO

## Il fatto, scritto nero su bianco

**La carta natale non ha mai funzionato per nessuno, in nessuna build.** App
Check respingeva la chiamata PRIMA che il corpo della funzione partisse: nei log
c'erano nove avvisi con `verifications.app: INVALID`, e nessuna riga
`natalChart: ...`, perche' quel codice non era mai stato eseguito.

Nessuna correzione ai dati di nascita poteva sbloccarla. Le voci dei giri
precedenti restano giuste e necessarie, e da sole non bastavano.

## Cosa ho fatto

`enforceAppCheck` a `false` in `functions/src/index.ts`, con sopra il commento
che dice perche', da quando e a quale condizione si riaccende. Funzione
ripubblicata.

## La dimostrazione: l'ho chiamata davvero

**Il corpo mandato**, tutti e otto i campi:

```json
{"data":{"year":1975,"month":7,"day":6,"hour":9,"minute":30,
         "lat":45.0703,"lng":7.6869,"tz_str":"Europe/Rome"}}
```

**La risposta: HTTP 200, e il motore risponde per davvero.** Tredici corpi,
dodici case, ventisette aspetti, con Ascendente e Medio Cielo:

| Corpo | Segno | Gradi | Casa |
|---|---|---|---|
| Sole | Cancro | 13,629 | 11 |
| Luna | Gemelli | 6,857 | 10 |
| Mercurio | Gemelli | 22,325 | 10 |
| Venere | Leone | 27,620 | 1 |
| Marte | Toro | 3,651 | 9 |
| Giove | Ariete | 22,261 | 9 |
| Saturno | Cancro | 21,298 | 11 |
| Urano | Bilancia | 28,358 | 3 |
| Nettuno | Sagittario | 9,552 | 4 |
| Plutone | Bilancia | 6,582 | 2 |
| Nodo Nord | Scorpione | 28,730 | 4 |
| Lilith | Pesci | 16,900 | 8 |
| Chirone | Ariete | 27,860 | 9 |

Angoli: Ascendente 145,117, Medio Cielo 46,318, Fondo Cielo 226,318,
Discendente 325,117, Vertex 288,320. Sistema delle case: Placidus. Giorno
giuliano 2442599,8125, delta T 45,969 secondi.

**Nessun 401 dal servizio a monte**: la chiave in Secret Manager e' valida.

**E il validatore fa il suo mestiere.** Con un corpo incompleto:

```
{"error":{"message":"Il campo hour manca oppure non e' un numero.",
          "status":"INVALID_ARGUMENT"}}
```

## I log dopo

`Callable request verification passed` dove prima era `INVALID`. E le righe
della funzione, che prima non esistevano:

```
2026-07-31T05:22:54.747028Z  INFO     natalChart: carta calcolata   pianeti: 13
2026-07-31T05:22:54.970317Z  WARNING  natalChart: corpo rifiutato   Il campo hour manca oppure non e' un numero.
```

**Ho dovuto aggiungerne una.** Il codice registrava solo i fallimenti, quindi una
chiamata riuscita non lasciava traccia: guardando i log non si poteva
distinguere "ha funzionato" da "non e' mai partita", ed e' proprio la
distinzione che serviva per trovare questo difetto. Adesso l'esito riuscito si
scrive, col numero dei pianeti tornati.

## Il compromesso, dichiarato

Senza imposizione chiunque conosca l'indirizzo puo' far chiamare una funzione
che consuma un servizio a pagamento. Il validatore limita il danno, e non lo
annulla: il rifiuto qui sopra e' la prova che un corpo malformato non arriva
mai al motore.

**Si riaccende** quando l'app sara' su una traccia di test interno del Play
Store, perche' da li' Play Integrity la riconosce. Il debito e' in `RIPRESA.md`.

## La frase di accettazione

**Apri il Passport e tocca la Carta natale: devi vedere i pianeti sulla ruota,
non piu' il cielo essenziale.**
