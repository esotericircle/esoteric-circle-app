# FE.08, le strade per cui una domanda arriva a un Maestro

Enumerate il 6 ottobre 2026 sul commit `5966b2b8`, con ogni numero di riga verificato aprendo il file. Le abbreviazioni sono:
- **P**: `lib/services/ai/firebase_maestro_ai_provider.dart`
- **C**: `lib/features/maestri/chat/maestro_chat_controller.dart`
- **MP**: `lib/services/ai/maestro_persona.dart`

**Riferimenti comuni**
- **Storia nel provider:** `startChat(history: _toHistory(history))` P:310.
  - La finestra è di **8 messaggi** in `_toHistory` (P:726-737, `kHistoryWindow = 8` P:165, ordine EX voce 09). La premessa dell'ordine diceva venti: oggi sono otto.
  - Prima della finestra c'è il riassunto `scrittoPrima` (P:229-231).
- **Blocco del filo:** `IlFiloDelConsulto.bloccoPer(maestro, storia: ..., fraseRipresa: ...)` P:235, che entra nell'istruzione a MP:552.
- **Filo di prima:** `_filoDiPrima` tiene al massimo 20 battute (`_battuteDelFilo = 20`, C:136), solo se l'ultima battuta ha meno di un'ora (C:719-727). Viene anteposto alla storia a C:813.

| Strada | Partenza della chiamata | Storia passata | Blocco del filo | Annota nel filo |
|---|---|---|---|---|
| 1. Chat scritta (`send`, `_ricevi`, `_generate`, `_chiediAlMaestro`) | `_ai.reply` C:809 (da C:1777, avvio C:1295) | Sì: `[..._filoDiPrima, ...storia]` C:813; il modello ne vede 8 (P:310, P:726), più il riassunto P:229 | Sì, P:235, MP:552 | Sì, C:2281 |
| 2. Chat con la cache del contesto (prima risposta scritta, a cache viva) | `_conLaCache` P:271, generazione P:693 e P:700 | Sì: `_finestra(history)` P:680, 8 messaggi | Sì: l'istruzione già composta (P:235) entra in `parteDellaPersona` | Sì, C:2281 |
| 3. LIVE, a voce o per iscritto nel LIVE (`_turno`) | `chat.send(testo)` `lib/features/maestri/live/schermata_live.dart:957` (da :778 e :1303), poi strada 1 | Sì, come la strada 1 | Sì, P:235 | Sì, C:2281 |
| 4. Domande suggerite (pannello dei suggerimenti) | `widget.onSend(question)` `lib/features/maestri/chat/widgets/chat_suggestions.dart:168`, cioè `controller.send` `maestro_chat_screen.dart:947`, poi strada 1 | Sì, come la strada 1 | Sì, P:235 | Sì, C:2281 |
| 5. "Parlane con" dalle dodici arti (`AzioniDelResponso` con `aperturaDellaChat`) | `MaestroChatScreen.route(initialUserMessage:)` `lib/features/ricordi/azioni_del_responso.dart:297-300`; la domanda va nel campo (`maestro_chat_screen.dart:936`) e parte con la strada 1 | Sì, a conversazione nuova (`maestro_chat_screen.dart:131`): arriva il filo di prima entro l'ora, C:713-727 | Sì, P:235. Il responso di partenza entra nella scheda via `IResponsiDiOggi.partenza` (`il_filo_del_consulto.dart:212`) e nel contesto natale (`sorgente_natale.dart:41`) | Sì, C:2281 |
| 6. "Consulta" dall'introduzione dell'arte, dal Santuario, dalla scheda del Maestro | `art_intro_screen.dart:114`, `santuario_screen.dart:478`, `maestro_screen.dart:425`, poi strada 1 | Come la strada 5 | Sì | Sì, C:2281 |
| 7. "Vai più a fondo" (il seguito) | `_ai.reply` C:1553 (da C:1501 e C:1621) | Sì, ma **senza `_filoDiPrima`**: `[..._messages.sublist(0, indice), prima]` C:1557 | Sì, P:235 (`fraseRipresa` resta nulla perché c'è `rispostaGiaData`) | **No** |
| 8. Riprova (`retryLast`) | `_generate` C:1684, poi strada 1 | Sì, C:1683 più il filo di prima | Sì, P:235 | Sì, C:2281 |
| 9. Correzione corta delle reti (`correggi`) | C:877, provider P:411 e P:445 | **No**: solo domanda e risposta, P:445-448 | **No**: `istruzioneDellaCorrezione` (MP:659) non ha il filo | Indiretto: il testo corretto si annota dopo, C:2281 |
| 10. Consiglio dei Maestri, la lente di ciascuno (`consult`) | `lib/features/maestri/ask/ask_maestri_screen.dart:318`, provider P:473 e P:499 | **No**: domanda singola, P:499 (scelta dichiarata, `maestro_ai_provider.dart:57-58`) | Sì, P:486, MP:1072 | Sì, `ask_maestri_screen.dart:367` (non per il ripiego) |
| 11. Consiglio dei Maestri, la sintesi (`synthesize`) | `ask_maestri_screen.dart:393`, provider P:530 e P:556 | **No** | **No**: `synthesisInstruction` (MP:1115) non riceve il filo | **No** |
| 12. Consiglio, "Continua con" un altro Maestro | `ask_maestri_screen.dart:455` con `ChatOpeners.consiglio(theme)` :458, poi strada 1 | Come la strada 5 | Sì, P:235; i pareri del Consiglio sono già nella scheda | Sì, C:2281 |
| 13. Presagio delle Rune (`presagioDelleRune`) | `lib/features/maestri/caligo/rune/rune_draw_screen.dart:378`, provider P:751 e P:809 | **No** | **No**: `presagioInstruction` (MP:783) con `MaestroMemory.empty` e senza filo | **No** |
| 14. Stesa dei tarocchi col modello | `lib/features/tarot/stesa_tre_carte_screen.dart:802`, modello `lib/core/tarot/la_lettura_dal_modello.dart:637` | **No** | **No** | **No** |
| 15. Sigillo dell'intenzione (scrive, riformula, compie) | `sigillo_intenzione_screen.dart:305` e :199, `libro_dei_sigilli_screen.dart:397`; modello `lib/core/magic/il_sigillo_dal_modello.dart:653` | **No** | **No** | **No** |
| 16. Viaggio dello Sciamano, la scena | `viaggio_dello_sciamano_screen.dart:612`; modello `lib/core/viaggio/la_scena_dal_modello.dart:1238` | **No**: solo gli strati del viaggio, :610 | **No** | **No** |
| 17. Viaggio, il segno dell'animale guida | `viaggio_dello_sciamano_screen.dart:2004`; modello `lib/core/viaggio/il_segno_dell_animale.dart:350` | **No** | **No** | **No** |

## Chiamate che non portano una domanda a un Maestro

Restano fuori dalla tabella:
- `distill` (P:578), il riassunto per la memoria;
- `LaDomandaCapita` (`la_domanda_capita.dart:560`), un classificatore;
- `penna_vera_del_mese.dart:87`, la lettura del mese;
- `laVoceDelMaestro` (`functions/src/live.ts:1459`), solo la sintesi vocale di un testo già scritto: il server non genera risposte;
- `sfocaLeConversazioni` (`functions/src/sfocatura.ts:207`), il riassunto programmato.

## Strade che non usano il filo

**Senza filo, senza storia, senza annotazione**
- La sintesi comparativa del Consiglio (11).
- Il presagio delle Rune (13).
- La stesa dei tarocchi col modello (14).
- Il Sigillo dell'intenzione (15).
- Il Viaggio dello Sciamano, scena e segno dell'animale (16, 17).

Le ultime tre passano da una chiamata propria a Vertex, fuori da `MaestroAiProvider`.

**Senza filo e senza storia, ma annotata dopo dalla chat**
- La correzione corta (9).

**Uso parziale**
- "Vai più a fondo" (7): legge il filo ma non annota il seguito, e non riceve `_filoDiPrima`.
- Il Consiglio, `consult` (10): legge e annota il filo, ma non riceve la storia della chat.

## Le cure, 6 ottobre 2026

Ogni strada che porta una domanda a un Maestro adesso legge il filo del consulto, ci scrive, oppure ha la ragione scritta per cui non lo fa. Le misure stanno in `test/il_filo_arriva_a_ogni_strada_test.dart`, viste rosse con gli innesti A65-A69.

| Strada | Cura |
|---|---|
| 7. "Vai più a fondo" | Riceve il filo di prima (`history: [..._filoDiPrima, ...]`), e il seguito entra fra le frasi del consulto |
| 10. Consiglio, `consult` | Riceve anche la frase ripresa (`LaFraseRipresa.fraTutte` sulle frasi del consulto) |
| 13. Presagio delle Rune | Legge il filo (`presagioInstruction(filo: ...)`) e ci scrive il parere di Calìgo |
| 14. Stesa dei tarocchi col modello | Legge il filo (`IlFiloDelConsulto.conIlFilo`) e ci scrive il parere di Medora |
| 17. Segno dell'animale guida | Ci scrive il segno come parere di Calìgo. Non lo legge: è una riga scelta da un repertorio di gesti, e la legge della coerenza non ha niente da guidare lì |

## Strade che restano fuori, con la ragione

| Strada | Ragione |
|---|---|
| 9. Correzione corta | Riscrive la forma di una risposta che il filo l'ha già letta. Il testo corretto entra nel filo dalla chat (C:2281) |
| 11. Sintesi del Consiglio | Non è un Maestro ma "la voce del cerchio": compone le lenti dei tre Maestri, che il filo l'hanno già letto e annotato |
| 15. Sigillo dell'intenzione | Non risponde a una domanda: riscrive l'intenzione della persona. Un filo che ci entrasse spingerebbe un consulto di prima dentro le sue parole |
| 16. Scena del Viaggio | È il racconto di un'esperienza guidata, a strati, non una risposta. Il suo esito, il segno, entra nel filo (strada 17) |
