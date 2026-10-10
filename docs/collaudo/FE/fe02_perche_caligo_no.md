# FE.02, perche' Caligo no

Misura fatta il 6 ottobre 2026 in sola lettura sul commit della build 2298 (`d251c4c2`) e su HEAD. Il commento sbagliato di `le_funzioni_del_cielo.dart` e' stato corretto nello stesso giorno.


### La build 2298

- `pubspec.yaml:12` su HEAD: `version: 0.1.0+2298` (il numero non e' ancora salito).
- Commit della 2298: `d251c4c2` (messaggio di `96521041`: "FD, la build 2298 consegnata: cancello verde su d251c4c2"; confermato da `docs/collaudo/FE/lo_stack_del_redmi_tradotto.txt`, riga 3: "la stessa build e' stata rifatta dal commit d251c4c2").

### Il percorso dell'ANR, letto su d251c4c2, passo per passo, cercando un ramo per Maestro

| Passo dello stack | File:riga a d251c4c2 | Dipende dal Maestro? |
|---|---|---|
| 23 `_SchermataLiveState.dispose` -> 22 `nelLive=` | `maestro_chat_controller.dart:183-190`: `final finisce = _nelLive && !valore; ... if (finisce) _preparaIlSeguitoSeManca();` | No: nessun confronto col Maestro |
| 21 `_preparaIlSeguitoSeManca` | `maestro_chat_controller.dart:1516-1534`: le condizioni sono `preparaIlSeguitoDiSerie`, `!_chiuso`, `!nelLive`, messaggi non vuoti, `ilPianoComprendeIlSecondoStrato`, ultima del Maestro con `portaUnResponso` e non `approfondita`, nessun `seguitoNascosto`, la precedente della persona | No: nessuna condizione nomina il Maestro |
| 18-19 `_scriviIlSeguito` | `maestro_chat_controller.dart:1464-1475`: `_ai.reply(maestro: prima.autoreEffettivo(maestro), ...)` | Il Maestro e' solo un argomento |
| 14 `FirebaseMaestroAiProvider.reply` | `firebase_maestro_ai_provider.dart:201` (systemInstruction) e `:275` `tools: LeFunzioniDelCielo.perIlMaestro(carta: natal.carta)` | No: gli strumenti del cielo vanno a tutti, senza condizione |
| 13 `systemInstruction` | `maestro_persona.dart:526`: `if (_cioCheArriva(natal).isNotEmpty) ...['', _cioCheArriva(natal)],` (il calcolo gira DUE volte) | No: dipende solo da `natal` |
| 12 `_cioCheArriva` | `maestro_persona.dart:351-372`: `ProssimiEventi.da(adesso: DateTime.now(), segno: segno)`, `segno` dal `natal.sunSign` | No: il Maestro non e' nemmeno un parametro (`static String _cioCheArriva(NatalContext natal)`) |

`git grep -i caligo d251c4c2` sul percorso (`lib/features/maestri/live`, `functions/src/live.ts`, `firebase_maestro_ai_provider.dart`, `voce_sorvegliata.dart`, `le_funzioni_del_cielo.dart`) trova solo: l'id dell'avatar (`live.ts:119`), la voce, il genere, il ritmo e il saluto (`live.ts:912-1119`), l'accento del nome (`il_parlato_del_maestro.dart:33-38`), i colori e l'inquadratura del volto (`schermata_live.dart:1482`, `stato_della_schermata_live.dart:46-178`). **Niente cambia il percorso alla chiusura del LIVE o all'apertura**: Caligo ha il seguito, legge il cielo (stessi strumenti), passa da `_cioCheArriva`, ha la stessa istruzione a struttura uguale, il suo LIVE ha gli stessi minuti.

Nota sulla misura delle risorse: in `docs/collaudo/FE/regola_a_fe.txt:10` l'unica riga stampata "risorse mancanti per Maestro" e' quella sotto innesto (A3), e li' `caligo: [AVATAR]` e' il difetto messo a mano, non lo stato vero. La riga della misura senza innesto (tutti vuoti) non l'ho trovata scritta in `docs/` (grep "risorse mancanti per Maestro": 1 riga sola). A d251c4c2 la tabella di riserva `AVATAR` in `functions/src/live.ts:117-120` ha tutti e tre gli id; gli avatar veri arrivano da Firestore (ordine EK voce 04), che dal repo non si legge.

### Il commento di `lib/services/ai/le_funzioni_del_cielo.dart:114-115` su HEAD

Testo: *"Medora e Aura leggono il cielo, Caligo no: per questo cadevano loro."*

**FALSO su HEAD, e falso anche alla 2298.** Prove:
- `lib/services/ai/firebase_maestro_ai_provider.dart:297` (HEAD) e `:275` (d251c4c2): `tools: LeFunzioniDelCielo.perIlMaestro(carta: natal.carta),` dato a ogni turno di ogni Maestro, chat e LIVE, senza condizione sul Maestro.
- `lib/services/ai/le_funzioni_del_cielo.dart:317` `static List<Tool> perIlMaestro({NatalChart? carta, DateTime? adesso})`: non riceve il Maestro.
- La causa vera non sono nemmeno le funzioni del cielo: lo stack tradotto porta a `_cioCheArriva` (`maestro_persona.dart:358` alla 2298), che non riceve il Maestro.
- Padre (Regola C): `c6db92f3` (FE.01, prima ipotesi, 5 ottobre 22:27), da `git blame -L 115,115`; la causa e' stata corretta in `bf65c2b2` ma il commento no.

Testo proposto:

```dart
  /// **IL CALCOLO DEL CIELO NON GIRA SUL FILO DELL'INTERFACCIA. Ordine FE
  /// voce 01.** Il 5 ottobre 2026 un tester su un Redmi Note 14 Pro 5G ha
  /// visto l'app chiudersi nel LIVE di Medora e di Aura: Crashlytics ha un ANR
  /// della build 2298 col filo principale dentro `cos`, sotto 143 passi di
  /// codice Dart. Lo stack tradotto (`docs/collaudo/FE/lo_stack_del_redmi_tradotto.txt`)
  /// porta alla chiusura del LIVE, che prepara il seguito e compone
  /// l'istruzione del Maestro: gli eventi in arrivo di 400 giorni si
  /// calcolavano li', due volte, sul filo dell'interfaccia. Il percorso e il
  /// peso sono gli stessi per i tre Maestri (2920, 2893 e 2828 ms sul PC):
  /// tutti e tre ricevono queste funzioni e la stessa istruzione, e che
  /// Caligo non sia caduto non dipende dalla sua configurazione (ordine FE
  /// voce 02). Il cielo di un periodo, che il modello chiede con
  /// [cieloDelPeriodo], costa col motore di Meeus 2,3 secondi sul PC per 400
  /// giorni: per questo anche qui il calcolo gira in un isolate a parte, e il
  /// filo dell'interfaccia resta libero.
```

### Conclusione

**La premessa "Caligo ha una configurazione diversa" e' FALSA** sul percorso che ha causato l'ANR: nessuna riga, a d251c4c2 come su HEAD, sceglie una strada diversa per Caligo alla chiusura o all'apertura del LIVE, e il calcolo pesa uguale (2920 / 2893 / 2828 ms).

**Perche' il tester non e' caduto con Caligo: NON MISURABILE dal repo.** Ragioni:
1. Crashlytics ha UN evento (227171118570, `lo_stack_del_redmi.txt:2-3`): lo stack non dice di quale Maestro era il LIVE (nessun passo porta il nome), quindi non c'e' nemmeno la prova che due LIVE su tre siano caduti; "Medora e Aura" viene solo dal racconto del tester.
2. Il racconto dice "aprendo il collegamento vocale" (`ORDINE_FE_TESTO.md:18-19`), lo stack dice CHIUDENDO (`dispose` -> `nelLive=`). Il racconto e la macchina descrivono momenti diversi.
3. L'ANR scatta solo se, alla chiusura, valgono tutte insieme le condizioni di `_preparaIlSeguitoSeManca` (piano col "Vai piu' a fondo", ultima risposta del Maestro che e' un responso senza seguito, preceduta da una domanda) E la persona ha un segno solare, E Android riceve un tocco mentre il filo e' fermo da piu' di 5 s. Nel LIVE di Caligo basta non aver ottenuto una risposta (LIVE chiuso prima di parlare, o per silenzio, come nella prima registrazione di Medora scartata in `bf65c2b2`), o una risposta gia' col seguito, o nessun tocco durante il fermo, e non cade.
4. Il fermo sta a cavallo della soglia: 5.100-6.365 ms su Test Lab (A16 5G e A35 5G, commit `0ddac0c2`), 3.441-3.821 ms in un'altra misura (`f6ebfa10`). Sul Redmi un giro puo' stare sotto i 5 s e un altro sopra.
5. L'ordine in cui il tester ha aperto i Maestri non e' scritto da nessuna parte: `ORDINE_FE_TESTO.md:16-21` dice solo "chiedere consiglio a un Maestro e approfondire con gli altri"; grep su `docs/` per Redmi trova solo i file dell'ordine FE e FD, nessun feedback con l'ordine.

---

