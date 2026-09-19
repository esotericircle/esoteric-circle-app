# Misurare il presagio, il comando che resta a Mauro

Ordine S, voce S.19, punto 6 della decisione D5. Lo strumento e' scritto, provato e
nel repository; **il numero non esiste ancora**, perche' prenderlo richiede chiamate
vere a Gemini su Vertex e da questa macchina non c'e' una sessione Google attiva.

La voce S.19 resta **FERMATA IN ATTESA DI DECISIONE** finche' il numero non c'e'. Non
e' lavoro sospeso e non aspetta altro lavoro di Code: aspetta questa esecuzione.

Finche' non si esegue, l'app funziona: il presagio lo compone il modello quando c'e'
rete e credito, e in ripiego lo compone la cornice dell'Allegato B piu' la frase della
runa. Cio' che manca non e' una funzione, e' la misura che dice **se il modello sta
davvero rispondendo alla domanda posta** invece di raccontare la runa e ignorarla.

## Prima di tutto: accedi

```bash
gcloud auth login
```

Si apre il browser. Basta una volta sola su questa macchina. Lo strumento prende il
gettone da qui, con `gcloud auth print-access-token`: se la sessione non c'e', si
fermera' dicendolo, senza spendere niente.

Se `gcloud` non e' installato, e' la stessa installazione che serviva all'ordine N:
Google Cloud CLI, e dopo l'accesso conviene fissare il progetto.

```bash
gcloud config set project esoteric-circle
```

## Il comando

Dalla cartella del repository, cioe' quella che contiene `pubspec.yaml`:

```bash
flutter test tool/misura_del_presagio.dart
```

Sono circa **due minuti**, e le chiamate partono a gruppi di quattro per non spingere
sulla quota.

## Cosa devi vedere se e' andata

In fondo all'uscita, questo blocco:

```
=== I DUE NUMERI DELLA MISURA (a) ===
SOVRAPPOSIZIONE MEDIA fra presagi di domande diverse, a parita' di runa: XX,X per cento.
SOVRAPPOSIZIONE MASSIMA su tutte le coppie: XX,X per cento.

=== IL COSTO ===
Chiamate al modello: 48.
Chiamate senza risposta utile: 0.
```

**I due numeri sono il risultato**, e vanno riportati nel rapporto come si e' fatto
col 98,3 per cento dell'attribuzione cieca. Piu' sono BASSI, piu' la domanda conta:
se il modello rispondesse alla runa ignorando la domanda, i sedici presagi della
stessa runa si somiglierebbero quasi del tutto.

**Non c'e' una soglia dichiarata, ed e' voluto.** La decisione D5 chiede il numero, e
la soglia la fissi tu dopo averlo visto: uno strumento che si dichiarasse promosso o
bocciato da solo sarebbe la guardia che la D5 ha detto di non fare.

Prima dei due numeri, per ciascuna delle tre rune del campione, lo strumento stampa
anche la coppia di domande piu' somiglianti fra loro: e' la riga che dice **cosa
correggere**, se ci fosse da correggere, e non solo che qualcosa non va.

## Il campione, dichiarato

**Tre rune fisse per tutte e sedici le domande della gettata: quarantotto presagi.** E'
il campione proposto da Mauro, e il precedente in casa e' l'attribuzione cieca, che ha
misurato sessanta risposte.

Le tre rune non sono estratte a caso:

| Runa | Verso | Perche' sta nel campione |
|---|---|---|
| Fehu | diritta | il caso comune: sostanza, verso positivo |
| Hagalaz | diritta | significato duro: la domanda leggera dentro il simbolo severo |
| Othala | in merkstave | verso d'ombra: il caso in cui il simbolo tende a coprire la domanda |

## Il costo, e perche' e' scritto

Quarantotto chiamate, e **nessun giudice**: il confronto e' aritmetico, quindi non
serve una seconda serie di chiamate a un secondo modello. Il credito Blaze del trial
finisce il 24 settembre 2026, e ogni numero che si spende va saputo prima di
spenderlo, non dopo.

Il modello e' `gemini-2.5-flash-lite`, lo stesso che l'app usa per il presagio: le
istruzioni di sistema e i numeri di generazione (temperatura, topP, tetto, budget di
ragionamento) arrivano dal codice vero dell'app, non da una copia scritta nello
strumento. Misurare un modello diverso da quello che le persone leggono non
misurerebbe niente.

## Se qualcosa va storto

- **"Nessun gettone di accesso"**: manca `gcloud auth login`. Nessuna chiamata e'
  partita, quindi non hai speso niente.
- **`HTTP 403`**: la sessione non ha i permessi su Vertex per il progetto
  `esoteric-circle`. Le righe di errore le stampa lo strumento.
- **`HTTP 429`**: quota. Lo strumento continua e conta le chiamate senza risposta
  utile: se sono molte, il numero e' preso su un campione piu' piccolo di
  quarantotto, e lo dice.
- **"nessun presagio e' arrivato"**: lo strumento si fermera' in rosso dicendo quante
  chiamate ha comunque speso, invece di stampare un numero che non ha misurato
  niente.
