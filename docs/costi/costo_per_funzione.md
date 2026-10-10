# Il costo di ogni funzione, misurato

Ordine EW, voce EW.04, 2 ottobre 2026. Prova di partenza delle voci EW.05,
EW.06 ed EW.07.

## Come si e' misurato

**Il codice vero dell'app, non una copia.** Il banco
`tool/il_banco_del_costo.dart` fa girare sul PC le stesse classi che girano sul
telefono: il controller della chat (`MaestroChatController`, con le sue
rigenerazioni, i solleciti e le funzioni del cielo), il provider dei Maestri,
la lettura dei Tarocchi, il presagio delle Rune, il Sigillo, il Viaggio, i
titoli, la penna dei Ricordi e l'ascolto del LIVE. Sotto l'etichetta della voce
EW.03 un client prende la richiesta che `firebase_ai` avrebbe mandato al
passaggio di Firebase e la manda a Vertex AI in **europe-west1**, uguale, con
la sua etichetta (`tool/il_banco_del_costo_comune.dart`). Da ogni risposta si
legge `usageMetadata`: token in ingresso, in uscita, di ragionamento e presi
dalla cache.

**La voce del Maestro** parte dal server: il banco la chiama col corpo di
`laVoceDelMaestro` (`functions/src/live.ts`), un pezzo per frase come nel LIVE.
**L'ascolto** riceve frasi dette da Gemini TTS e portate a 16 kHz, come il
microfono del telefono.

**Almeno venti usi per caso**, tutti i 17 casi (la chat con la memoria piena
trenta), in tre giri dello stesso banco: il primo coi casi tutti, il secondo
per l'ascolto (il primo aveva avuto solo 13 frasi valide: vale il secondo) e la
Profonda, il terzo per portare a venti i casi che il primo aveva fatto dieci
volte (il "Vai piu' a fondo", la riformulazione e il compimento del Sigillo).
Ogni chiamata e' una riga di `docs/costi/costo_per_funzione_chiamate.jsonl`
(621 righe col giro, il caso, l'etichetta, il modello e i consumi letti dalla
risposta); i conti li rifa' `tool/i_conti_del_costo_ew.py`, uscita in
`docs/costi/i_conti_del_costo.txt`.

**I prezzi** (Vertex AI, livello standard, letti il 2 ottobre 2026), in
dollari per milione di token: `gemini-2.5-flash` 0,30 ingresso testo, 1,00
ingresso audio, 2,50 uscita; `gemini-2.5-flash-lite` 0,10 e 0,40;
`gemini-2.5-flash-tts` 0,50 ingresso e 10,00 audio in uscita (25 token al
secondo). **Il ragionamento si paga come l'uscita.** I token presi dalla cache
implicita costano il 10 per cento dell'ingresso: *"Implicit caching provides a
90% discount on cached tokens compared to standard input tokens"* (pagina del
context cache di Vertex, letta il 2 ottobre 2026).

**Due colonne di costo, e perche'.** Il banco ha fatto venti usi di fila, e
Vertex ha ritrovato in cache meta' dell'ingresso della chat (le istruzioni del
Maestro sono le stesse a ogni domanda). Con poche persone che scrivono a
distanza di minuti la cache scade, e l'ingresso si paga intero. Per questo ogni
caso ha **il costo con la cache misurata** e **il costo senza cache**, che e'
quello da usare per il conto del caso peggiore. I conti di EW.05 usano il
secondo.

## La tabella

Costi in dollari **per uso** (un uso e' un gesto della persona: una domanda,
una stesa, una gettata, una discesa).

| Caso | Etichetta | Modello | Usi | Chiamate per uso (media, massimo) | Medio con la cache | Massimo con la cache | Medio senza cache | Massimo senza cache |
|---|---|---|---|---|---|---|---|---|
| Chat, memoria vuota (il Viandante) | `chat_risposta` | Flash | 20 | 2,10; 6 | 0,00252 | 0,00714 | 0,00521 | 0,01533 |
| Chat, memoria piena (20 turni, sintesi, 12 fatti) | `chat_risposta` | Flash | 30 | 2,23; 5 | 0,00431 | 0,01171 | 0,00694 | 0,01557 |
| Chat, "Vai piu' a fondo" | `chat_seguito` | Flash | 20 | 1,45; 4 | 0,00236 | 0,00531 | 0,00430 | 0,01180 |
| LIVE, la risposta del Maestro | `chat_live` | Flash | 20 | 1,90; 4 | 0,00328 | 0,00979 | 0,00596 | 0,01272 |
| LIVE, la voce di una risposta | `voce_maestro` | Flash TTS | 20 | 2,25; 3 | 0,00779 | 0,01211 | 0,00779 | 0,01211 |
| LIVE, l'ascolto di una frase | `ascolto_live` | Flash, audio | 20 | 1; 1 | 0,00027 | 0,00031 | 0,00027 | 0,00031 |
| Interroga i Maestri: tre lenti Breve e la sintesi | `interroga_breve`, `interroga_sintesi` | Flash-Lite e Flash | 20 | 4; 4 | 0,00219 | 0,00261 | 0,00250 | 0,00264 |
| Interroga, una lente Profonda (nessuna strada dell'app la chiede) | `interroga_profonda` | Flash col ragionamento | 20 | 1; 1 | 0,00302 | 0,00348 | 0,00322 | 0,00350 |
| Tarocchi, la lettura della stesa | `lettura_tarocchi` | Flash | 20 | 1,75; 3 | 0,00203 | 0,00416 | 0,00207 | 0,00416 |
| Rune, la lettura della gettata | `lettura_rune` | Flash | 20 | 1,85; 3 | 0,00405 | 0,00881 | 0,00601 | 0,01206 |
| Sigillo, titolo e responso | `sigillo` | Flash | 20 | 1,55; 2 | 0,00045 | 0,00061 | 0,00045 | 0,00061 |
| Sigillo, la riformulazione | `sigillo` | Flash | 20 | 1; 1 | 0,00012 | 0,00013 | 0,00012 | 0,00013 |
| Sigillo, il compimento | `sigillo` | Flash | 20 | 1; 1 | 0,00014 | 0,00015 | 0,00014 | 0,00015 |
| Viaggio, una discesa con la domanda scritta | `viaggio_domanda`, `viaggio_scena` | Flash-Lite e Flash | 20 | 3,80; 4 | 0,00345 | 0,00393 | 0,00350 | 0,00393 |
| Viaggio, un segno chiesto all'animale | `viaggio_segno` | Flash-Lite | 20 | 1,05; 2 | 0,00012 | 0,00127 | 0,00012 | 0,00127 |
| Il titolo della conversazione | `titoli_conversazioni` | Flash-Lite | 20 | 1; 1 | 0,00002 | 0,00002 | 0,00002 | 0,00002 |
| Ricordi, la lettura del mese | `ricordi_del_mese` | Flash-Lite | 20 | 1; 1 | 0,00010 | 0,00017 | 0,00010 | 0,00017 |

**Le funzioni del cielo nella chat.** Delle domande di ogni caso di chat, quattro su
dieci chiedono del cielo (la Luna di stasera, Saturno nel prossimo mese,
il cielo di oggi, un giorno per firmare) e fanno chiamare al Maestro le
funzioni del cielo:

| Caso | Domande sul cielo: usi; chiamate per uso; costo medio con la cache e senza | Le altre domande: usi; chiamate per uso; costo medio con la cache e senza |
|---|---|---|
| Chat, memoria vuota | 8; 3,25 (massimo 6); 0,00365 e 0,00814 | 12; 1,33 (massimo 4); 0,00176 e 0,00326 |
| Chat, memoria piena | 12; 3,17 (massimo 5); 0,00563 e 0,00987 | 18; 1,61 (massimo 3); 0,00344 e 0,00498 |
| LIVE, la risposta | 8; 2,88 (massimo 4); 0,00471 e 0,00908 | 12; 1,25 (massimo 2); 0,00232 e 0,00387 |

Una domanda sul cielo costa **circa il doppio** di una domanda qualsiasi: la
funzione del cielo e' una chiamata in piu', con tutto l'ingresso della chat
ripetuto.

## Il ragionamento

| Dove | Acceso o spento | Token di ragionamento misurati |
|---|---|---|
| Ogni chiamata dell'app tranne la Profonda | **Spento** (`thinkingBudget: 0`) | 0 su 601 chiamate, tranne 24 token in 80 chiamate di Interroga e 2 in 21 del segno: residui del modello, non un ragionamento chiesto |
| Interroga, la lente Profonda | **Acceso**, budget 512 | 8.530 token in 20 usi, 426 a uso: il **65 per cento** dell'uscita pagata di quella chiamata. Nessuna strada dell'app la chiede oggi (`ConsultDepth.profonda` non ha chiamanti che la passino), quindi oggi pesa zero |

**La metrica `token_count` di Monitoring conta il ragionamento**, verificato
al token: nei minuti del secondo giro del banco Monitoring ha contato 116.533
token in ingresso (il banco ne ha letti 116.533 dalle risposte) e 13.406 in
uscita, cioe' 4.876 di testo piu' 8.530 di ragionamento. La prova:
`docs/collaudo/EW/token_count_conta_il_ragionamento.txt`. La stima dei 30
giorni, che prezzava l'output di Monitoring al prezzo dell'uscita, il
ragionamento lo aveva gia' contato giusto.

## Cosa dicono i numeri, in parole

- **La funzione che costa di piu' per uso e' la voce del LIVE** (0,0078 a
  risposta, quasi tutta audio in uscita), poi **la chat** (da 0,0025 a 0,0069
  a domanda) e **le Rune** (0,0040 con la cache, 0,0060 senza). Tutto il
  resto sta sotto mezzo centesimo, e titoli, segni, Ricordi e Sigillo sotto il
  decimo di centesimo.
- **La chat chiama il modello in media due volte per domanda**, non una: le
  funzioni del cielo e le rigenerazioni delle reti (la risposta chiesta di
  nuovo quando non regge). Il massimo misurato e' sei chiamate per una
  domanda.
- **L'ingresso della chat pesa piu' dell'uscita.** Una chiamata della chat
  porta in media da 7.400 a 9.800 token in ingresso (le istruzioni del Maestro,
  il cielo, la memoria, la conversazione) e ne scrive circa 100. Per questo la
  cache implicita dimezza il costo quando c'e', e per questo la memoria piena
  costa solo un terzo in piu' della vuota.
- **Le Rune** chiamano in media 1,85 volte per gettata e portano 6.800 token
  in ingresso a chiamata: il presagio e' scartato e chiesto di nuovo quando non
  regge (in 2 gettate su 20 anche la terza volta non ha retto e ha risposto la
  riserva, che le chiamate le ha gia' pagate).
- **La discesa del Viaggio** fa in media 3,8 chiamate: la domanda capita (1,
  Flash-Lite) e la scena chiesta fino a tre volte (2,85 in media, Flash), perche'
  le guardie del responso scartano le scene che non reggono. Una scena chiesta
  e poi abbandonata per il tempo arriva lo stesso e si paga: una e' arrivata
  durante il caso del segno.

## Cosa non e' misurato qui, e perche'

- **Chirp 3 HD**: si sceglie solo dal selettore delle voci dei fondatori e non
  e' la voce di partenza di nessun Maestro (EO.15). Il prezzo e' per carattere:
  30 dollari al milione, il primo milione del mese gratis.
- **L'ascolto di prova delle voci** (`voce_ascolto_di_prova`): solo fondatori,
  una chiamata a tocco, come la voce del Maestro.
- **Il distillato della memoria**: nessun chiamante dall'ordine CG.09.
- **La regione della penna dei Ricordi**: nell'app parte senza regione, cioe'
  da `us-central1` (padre: ordine CG, voce CG.11, commit `e69c13e3`). Il banco
  l'ha misurata in europe-west1, perche' le prove stanno nella regione dei dati,
  e lo dichiara (20 chiamate). Il prezzo di Flash-Lite e' lo stesso nelle due
  regioni.

## Comandi

```bash
VOLTE=20 flutter test -r expanded tool/il_banco_del_costo.dart
```

```bash
python tool/i_conti_del_costo_ew.py
```
