# Le chiamate al modello, una per una

Ordine EW, voce EW.01, 2 ottobre 2026. Letto nel codice del ramo
`claude/esoteric-circle-master-order-e798aj` (commit `55d3a267` e il lavoro
dell'ordine EW), in sola lettura: nessuna chiamata è stata tolta o cambiata.
Quali tenere lo decide il fondatore.

**La domanda del fondatore**: *"non avevo idea che il viaggio toccasse la AI.
Pensavo che le uniche funzionalità che usassero la AI fossero tarocchi, chat e
live chat. Tutto il resto, attualmente z dovrebbe essere deterministico, o
sbaglio?"*

**La risposta in una riga**: oltre a Tarocchi, chat e LIVE il modello lo
usano anche **le Rune, il Sigillo dell'Intenzione, il Viaggio dello Sciamano
(tre chiamate diverse), la lettura del mese dei Ricordi e i titoli delle
conversazioni**. Ognuna ha una riserva senza modello, quindi l'app funziona
anche senza; ma quando il modello risponde, si paga.

## Il conto

| | Punti del codice |
| --- | --- |
| Punti che chiamano un modello o un servizio di AI | **18** |
| Tabella A: Tarocchi, chat dei Maestri e LIVE | 12 |
| Tabella B: tutte le altre | **6** (Rune, Sigillo, Viaggio segno, Viaggio domanda, Viaggio scena, Ricordi del mese) |
| Di cui modelli Google che girano davvero | 15 (il distillato della memoria non ha più chiamanti; i due punti di Protoface sono il volto, non un modello Google) |
| Nel telefono (`generativeModel(` in `lib`) | 13, tutti con l'etichetta della voce EW.03 |
| Nelle funzioni del server | 3 chiamate di sintesi (Gemini TTS a flusso, Gemini TTS intero, Chirp 3 HD) e 2 a Protoface |

**Tre cose da sapere, trovate leggendo:**

1. **La lettura del mese dei Ricordi esce dall'Europa.** `penna_vera_del_mese.dart`
   crea il modello con `FirebaseAI.vertexAI()` senza la regione, e la
   libreria usa allora `us-central1` (firebase_ai 3.13.1, `firebase_ai.dart:26`).
   È la regola dei modelli nella regione dei dati, non rispettata: la stima dei
   30 giorni ha visto proprio 4 chiamate di Flash-Lite in us-central1. Non ha
   nemmeno un tetto delle uscite né il ragionamento dichiarato. Padre: ordine
   CG voce 11 (commit `e69c13e3`, 31 agosto 2026); la guardia
   `i_modelli_stanno_nella_regione_dei_dati` controlla i nomi dei modelli, non
   la regione di ogni chiamata, e non l'ha vista. **Non corretta**: quest'ordine
   cambia solo le etichette; la correzione (una parola, `location:`) è una
   leva da scegliere, in `docs/costi/le_leve_del_costo.md`.
2. **Il distillato della memoria non parte più**: la funzione esiste ma
   nessuno la chiama dall'ordine CG voce 09 (commit `7492c113`), che l'ha
   sostituita con la sintesi del server.
3. **La risposta Profonda non parte mai**: "Interroga i Maestri" chiede sempre
   la Breve (`ask_maestri_screen.dart:294`), e la chat scritta usa sempre
   Flash con il ragionamento spento. Il ragionamento (512 token) c'è solo in
   quel ramo che non si raggiunge. **CLAUDE.md dice "gemini-2.5-flash-lite per
   la risposta Breve e per il piano Free"**: nel codice la chat di ogni piano
   usa Flash; Flash-Lite lo usano la lente Breve di "Interroga i Maestri", il
   Viaggio (domanda e segno), i titoli e i Ricordi del mese.
4. **Il context caching di Gemini non c'è**: nessun `cachedContent` in `lib` o
   nel server. Le cache dell'app sono sue (la stessa domanda nello stesso
   giorno, il titolo una volta per conversazione, la lettura del mese).

## Tabella A, Tarocchi, chat dei Maestri e LIVE

"×3 trasporto": `VoceSorvegliata` ritenta fino a 3 volte sugli errori
temporanei (429, 503, 504), con attese di 300 e 900 ms
(`ritentativi_della_voce.dart`).

| # | Funzione e gesto | File, modello, regione | Ordine e voce che l'hanno introdotta | Chiamate per uso | Senza il modello | Cache o scheletro | Flusso, ragionamento, tetto |
| --- | --- | --- | --- | --- | --- | --- | --- |
| A1 | **Risposta del Maestro**: la chat scritta (invio, Riprova, l'altra voce nella conversazione), "Approfondisci" e **il LIVE** (la frase trascritta passa da `chat.send`) | `firebase_maestro_ai_provider.dart:162` (`startChat`, `sendMessage` o `sendMessageStream`, solleciti del cielo e dei responsi); `gemini-2.5-flash` in chat e nel LIVE; europe-west1; con le funzioni del cielo | Nasce col checkpoint C3 (commit `91d0718b`, 11 luglio 2026). Il flusso nel LIVE con EO.14, *"nelle chat live bisogna ridurre il tempo in cui la risposta viene scritta [...]"*; Flash nel LIVE con EQ.03; funzioni del cielo e solleciti con EV.03 (*"Medora in chat deve sapere qual è la situazione astrale oggi e di ogni giorno [...]"*) ed EV.04 | **Minimo 1.** Per turno la domanda può ripartire fino a 10 volte in chat e 9 nel LIVE (troncatura, posizione, certezze, ancoraggio, programma, attesa, ripetuta, riga d'oro, vuota: `maestro_chat_controller.dart:1295-1730`); ogni `reply` manda fino a 3 messaggi (il primo e due solleciti) e ogni messaggio fino a 5 richieste per le funzioni del cielo. Massimo teorico molto alto: la misura vera è in `costo_per_funzione.md` | `LetturaDiRipiego.componi` se la risposta resta tronca o vuota; `RipiegoDelMaestro` se il modello manca | **La stessa domanda nello stesso giorno non richiama il modello** (`LaLetturaDelGiorno.giaData`, DS.08); storia limitata a 20 turni | Flusso solo nel LIVE; ragionamento 0; tetto 400 (chat e LIVE), 600 (Approfondisci) |
| A2 | **La lente di un Maestro in "Interroga i Maestri"** | `firebase_maestro_ai_provider.dart:289`; `gemini-2.5-flash-lite` (Breve); europe-west1 | Commit `c61c6c9f`, 21 luglio 2026, senza sigla | 1 per Maestro, al massimo 3; ×3 trasporto | `MaestroOracle` | Scheletro `MaestroOracle` | Ragionamento 0, tetto 400, JSON |
| A3 | **La sintesi dei Maestri** in "Interroga i Maestri", quando ci sono almeno due lenti | `firebase_maestro_ai_provider.dart:341`; `gemini-2.5-flash`; europe-west1 | Commit `3df0b03f`, 21 luglio 2026, senza sigla; la richiesta di nuovo se non nomina nessuno con EE.10 | Fino a 2 sintesi con tre lenti, ognuna con al più una richiesta di nuovo | `MaestroOracle.synthesisFor` | Sintesi di ripiego | Ragionamento 0, tetto 400 |
| A4 | **Il distillato della memoria**: nessun chiamante | `firebase_maestro_ai_provider.dart:388`; `gemini-2.5-flash` | C3; spento da CG.09 (commit `7492c113`): *"la distillazione a ogni tre turni e' stata TOLTA"* | 0 | | Si rilegge la sintesi del server | Ragionamento 0, tetto 500 |
| A5 | **Tarocchi, la lettura della stesa**: tocco su "Leggi le Carte" | `la_lettura_dal_modello.dart:620`; `gemini-2.5-flash`; europe-west1 | EQ.04 (commit `7c7596d6`): *"LE RISPOSTE SONO TROPPO CRIPTICHE, SONO QUASI SENZA SENSO. SCRIVE QUALCOSA, MA NON DICE NULLA."* | Fino a 3 tentativi; oltre 4,5 s parte anche una richiesta di riserva in parallelo, più una riscrittura del genere per tentativo: massimo 9, entro 10 s | Lettura di casa `TarotReading.of` | Lettura di casa deterministica | Ragionamento 0, tetto 1.400, JSON con schema |
| A6 | **Il titolo della conversazione**, dopo la prima risposta | `titoli_da_gemini.dart:57`; `gemini-2.5-flash-lite`; europe-west1 | DZ.04 (commit `55fb10ba`): decisione del fondatore del 18 settembre, *"il titolo lo scrive Gemini"* | 1 per conversazione | Titolo di ripiego (la prima domanda accorciata) | Una volta sola per conversazione | Ragionamento 0, tetto 24 |
| A7 | **L'ascolto del LIVE** (la trascrizione della persona) | `l_orecchio_del_live.dart:643`; `gemini-2.5-flash` con l'audio; europe-west1 | EJ.01 (commit `5b160747`): *"Quando il maestro sta per finire di parlare, il microfono si riattiva [...]"*; Flash con EK.03 (*"è Calìgo e non Càligo"*) | Per frase: 1, più 1 anticipata a ogni pausa, più 1 per ogni controllo del sottofondo continuo, più 1 se torna vuota: **nessun tetto** | La frase vale silenzio | Nessuna | Ragionamento 0, tetto 600 |
| A8 | **La voce del Maestro nel LIVE** (Gemini TTS): saluto, prima frase anticipata, ogni pezzo della risposta | `functions/src/live.ts`, `laVoceDelMaestro`, `streamGenerateContent`; `gemini-2.5-flash-tts` (o `gemini-2.5-pro-tts` se scelto); europe-west1 | EG.01 (commit `3687c223`): *"compare la figura intera di Medora ma è fissa e muta [...]"* | Per turno: un pezzo per frase (la prima da sola, poi pezzi da 220 caratteri), più la prima frase anticipata che può andare persa, più il saluto | La voce tace, il testo resta | Nessuna per l'audio | Flusso |
| A9 | **La voce Chirp 3 HD**, se il fondatore la sceglie | `live.ts`, `streamingSynthesize`; endpoint `eu-texttospeech` (l'eccezione EM.02) | EM.02 (commit `f80e2ced`) | Come A8 | Errore "La voce e' tornata vuota" | Nessuna | Flusso |
| A10 | **L'ascolto di prova di una voce** nel selettore, solo fondatori | `live.ts`, `laVoceIntera`, `generateContent`; europe-west1 | EJ.02 ed EJ.03 (commit `06dcd389`) | 1 per tocco | Errore | Nessuna | |
| A11 | **Il volto Protoface** del LIVE (servizio esterno, non un modello Google) | `live.ts:312`, `POST api.protoface.com/v1/sessions` | EG.01 (commit `77327a2c`) | 1 sessione per LIVE, a tempo | "Il LIVE non si apre" | | |
| A12 | **La creazione di un avatar Protoface**, strumento dei fondatori | `live.ts:554`, `POST /avatars` | EK.04 (commit `a936c133`) | 1 per richiesta | Risposta 502 | | |

## Tabella B, tutte le altre

| # | Funzione e gesto | File, modello, regione | Ordine e voce | Chiamate per uso | Senza il modello | Cache o scheletro | Flusso, ragionamento, tetto |
| --- | --- | --- | --- | --- | --- | --- | --- |
| B1 | **Rune, il presagio della gettata**: Getta o Getta ancora | `firebase_maestro_ai_provider.dart:456`; `gemini-2.5-flash`; europe-west1 | S.19 (commit `3d07c946`, decisione D5 di Mauro); Flash con ER.01, *"Adesso ho il dubbio che anche le estrazioni rune non abbiano l'interpretazione come i tarocchi."* | Fino a 3 tentativi, ×3 trasporto | `RunePresagio.componiIlResponso` dal corpus | Scheletro: le righe del corpus | Ragionamento 0, tetto 800, JSON |
| B2 | **Sigillo dell'Intenzione**: titolo e responso al "Traccia il sigillo"; la riformulazione ("Chiedi a Calìgo di riscriverla", o da sola per un'intenzione su un'altra persona); il compimento ("Si è compiuto") | `il_sigillo_dal_modello.dart:640`; `gemini-2.5-flash`; europe-west1 | Ordine DO (commit `de03a1ea`, DO.05, DO.09, DO.10) | Titolo e responso fino a 2; riformulazione 1 per tocco, al più 3 per sigillo; compimento 1 | Voce di casa `LaVoceDelSigillo` | Testi di casa deterministici | Ragionamento 0, tetto 320 |
| B3 | **Viaggio, il segno dell'animale**: la domanda all'animale | `il_segno_dell_animale.dart:330`; `gemini-2.5-flash-lite`; europe-west1 | DI.14 (commit `5df1bfe6`) | 1, entro 3 s; tetto tecnico 10 al giorno | `diRiserva` | Repertorio chiuso dei gesti | Ragionamento 0, tetto 256 |
| B4 | **Viaggio, la domanda capita**: Scendi con una domanda scritta | `la_domanda_capita.dart:539`; `gemini-2.5-flash-lite`; europe-west1 | DI.02 (commit `50cedbce`), oggetto con DL.08 | 1, entro 2 s | Tabella delle parole `IlTemaDellaDomandaLibera` | Tabella deterministica | Ragionamento 0, tetto 96 |
| B5 | **Viaggio, la scena e i tre testi**: ogni discesa | `la_scena_dal_modello.dart:1041`; `gemini-2.5-flash`; europe-west1 | DI.03 (commit `54687752`) | Da 1 a 3, entro 6 s, su un posto del tetto tecnico delle discese | La riserva compone la scena e parla la voce di casa | Riserva deterministica | Ragionamento 0, tetto 640 |
| B6 | **Ricordi, la lettura del mese**: all'apertura dei Ricordi, dall'Iniziato in su | `penna_vera_del_mese.dart:75`; `gemini-2.5-flash-lite`; **nessuna regione: us-central1** | CG.11 (commit `e69c13e3`) | 1 al mese | La riga non compare | Cache della lettura del mese | **Nessun tetto e nessun ragionamento dichiarati** |

**Non contati**: `functions/src/sfocatura.ts:81` nomina `gemini-2.5-flash-lite`
ma non chiama niente (la penna passata è vuota); LiveKit firma solo un
gettone; gli altri accessi a Protoface (elenco degli avatar, stato, fine, uso)
non generano niente; la dettatura usa il riconoscitore del telefono.
Nessuna strada di `lib` chiama un modello solo in Demo o in collaudo.

## Come rifare il conto

```
rg -n "generativeModel\(|FirebaseAI\.|generateContent|startChat|sendMessage\(|countTokens" lib
rg -in "generateContent|texttospeech|Chirp|gemini-|aiplatform|googleapis\.com|protoface|fetch\(" functions/src
rg -n "\.(reply|consult|synthesize|distill|presagioDelleRune)\(" lib
rg -in "cachedContent|contextCach" lib functions/src
git log -S"<pezzo>" --reverse --format="%h %ad %s" --date=short -- <file>
```

La guardia `test/ogni_chiamata_al_modello_porta_l_etichetta_test.dart` conta
i `generativeModel(` di `lib` (13) e pretende l'etichetta su ognuno.
