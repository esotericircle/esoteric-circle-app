# I banchi col modello

Ordine FD voce 03. Cinque casi che **chiamano Gemini davvero**: costano, e
misurano il modello, non il codice. Per questo stanno fuori dal cancello di
GitHub, che non ha il gettone di Vertex, e girano **a ogni consegna di una
build, prima della consegna**: `tool/consegna.py` non consegna se l'ultimo
giro non e' passato tutto sullo stesso codice (`lib`, `test` e questa
cartella) che si consegna.

## Il comando

Dalla radice del progetto, con `gcloud` gia' autenticato:

```
python tool/banchi_col_modello/i_cinque_banchi.py --costo
```

Lancia i cinque casi uno dopo l'altro, legge l'esito di ciascuno e scrive
`docs/collaudo/banchi_col_modello/<data>.txt` con:

- il commit su cui hanno girato (l'albero di `lib`, `test` e dei banchi deve
  essere pulito, o il comando si ferma);
- una riga `RISULTATO` per ognuno dei cinque, PASSATO, ROSSO o SALTATO;
- le misure che ogni banco stampa;
- con `--costo`, il costo del giro letto da Cloud Monitoring sulla finestra
  del giro (`token_count`, ingresso e uscita per modello, l'uscita comprende
  il ragionamento) e portato in euro col cambio BCE del giorno.

Accanto scrive `<data>.uscite`, l'uscita intera dei banchi senza le righe del
contatore: se un banco cade, il motivo si legge li' senza rifare il giro.
Le chiamate a Vertex dei banchi riprovano fino a cinque volte, con attese
che crescono da due a trentadue secondi, quando Vertex risponde 429 (quota
esaurita) o 503: nel primo giro dell'ordine FD il segno, che parte subito
dopo le cento discese, era caduto cosi'
(`docs/collaudo/banchi_col_modello/2026-10-05.giro_rosso_429`).

Il gettone di Vertex lo chiede a `gcloud` e lo passa ai banchi
nell'ambiente: non si stampa e non si scrive. `--elenco` stampa i cinque
casi senza lanciare niente.

## I cinque banchi

| # | File | Caso | Cosa misura |
|---|---|---|---|
| 1 | `il_banco_delle_domande_libere_col_modello_test.dart` | CON RETE: il classificatore vero sul banco | il classificatore delle domande libere del Viaggio dello Sciamano, col modello vero, sul banco delle domande di prova: quante ne riconosce giuste, quante decide il modello e quante la tabella da sola |
| 2 | `la_prova_a_cento_discese_col_modello_test.dart` | CON RETE: le cinque misure su cento discese, col modello vero | cento discese del Viaggio col modello vero, una alla volta come per una persona: le cinque misure della ripetizione e il costo di una discesa |
| 3 | `la_prova_a_cento_discese_col_modello_test.dart` | CON RETE: G, venti cammini col modello vero | venti cammini interi: quanti strati del racconto si ripetono e la somiglianza peggiore |
| 4 | `la_prova_a_cento_discese_col_modello_test.dart` | CON RETE: il segno col modello vero, dodici domande | il gesto del segno dell'animale scelto dal modello su dodici domande, e quante risposte vanno scartate |
| 5 | `la_sonda_del_sigillo_test.dart` | Tre chiamate vere per ogni sigillo, lette tutte | i testi del Sigillo dell'Intenzione: tre chiamate per sigillo, ogni testo letto, accettato o scartato col motivo, e il costo di un sigillo completo |

## Quanto costa un giro

**3,22 euro**, misurato una volta il 5 ottobre 2026 sul giro passato del
commit `5710ea75` (`docs/collaudo/banchi_col_modello/2026-10-05.txt`): 3,60
dollari da Cloud Monitoring in 83 minuti, quasi tutti di gemini-2.5-flash
nelle cento discese, al cambio BCE del giorno (1 euro = 1,1204 dollari). E'
un massimo: nella stessa finestra possono esserci chiamate dell'app di altre
persone, che Monitoring non separa. Il giro caduto sul 429 dello stesso
giorno era costato 6,55 euro: lo si conta, perche' un giro rosso si paga
intero e si rifa'.
