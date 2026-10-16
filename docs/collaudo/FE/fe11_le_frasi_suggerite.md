# FE.11, i punti dove l'app suggerisce una frase o una domanda

Enumerati il 6 ottobre 2026 sul commit `5966b2b8`, con ogni riga verificata aprendo il file.

## Come funziona il filo oggi

- **Dove nasce la marcatura.** In un punto solo, `lib/services/ai/firebase_maestro_ai_provider.dart:240-248`:
  - `fraseRipresa = LaFraseRipresa.trova(laDomanda, testo dell'ultimo messaggio del Maestro)`;
  - vale nulla quando c'è `rispostaGiaData`, cioè nel seguito.
- **Come si riconosce la frase.** `LaFraseRipresa.trova` (`lib/core/chat/il_filo_del_consulto.dart:362-382`) confronta la domanda con le frasi della sola **ultima** risposta del Maestro, tolta la stella (366). Le soglie sono tre:
  - almeno 3 radici nella domanda (365);
  - almeno 4 radici nella frase (372);
  - almeno metà della frase ritrovata, e almeno sei decimi della domanda (376).
- **Come arriva al modello.** Col blocco del filo: `bloccoPer` (283-286) e `laFraseRipresa` (342-344), che entrano nell'istruzione a `lib/services/ai/maestro_persona.dart:552`.
- **Cosa vede il modello della storia.** Solo `m.text` (`firebase_maestro_ai_provider.dart:735`). Il seguito di "Vai più a fondo" vive in un campo a parte, `ChatMessage.seguito` (`lib/core/chat/chat_message.dart:106`).
- **Il Consiglio dei Maestri** riceve `bloccoPer(maestro)` senza `fraseRipresa` (`firebase_maestro_ai_provider.dart:486`).

**Il percorso comune, "via chat" nella tabella:**
`ChatComposer` (`lib/features/maestri/chat/widgets/chat_composer.dart:174`) → `MaestroChatController.send` (`maestro_chat_controller.dart:1134`) → `_generate` (1295) → `_chiediAlMaestro` (809-817) → `firebase_maestro_ai_provider.dart:235-248`.

**Le frasi dei "Parlane con"** entrano come testo del campo: `azioni_del_responso.dart:297-301` → `maestro_chat_screen.dart:191` e 936 (`initialText`) → `chat_composer.dart:84` → via chat.

## Tabella

| # | Punto | Dove nasce la frase | Dove arriva al Maestro | Collegato come ripresa |
|---|---|---|---|---|
| 1 | Pannello dei suggerimenti, domande frequenti e personali | `lib/core/domande/domande_del_cerchio.dart:142` e 403; pannello `lib/features/maestri/chat/widgets/chat_suggestions.dart:258-260`, invio 167-168; aggancio `maestro_chat_screen.dart:942-950` | via chat (`maestro_chat_screen.dart:947`) | No. Sono frasi dell'app e non del Maestro: domanda nuova, ed è giusto così |
| 2 | "Vai più a fondo" (il seguito) | `lib/core/maestro/seguito_della_lettura.dart:39-40`; `lib/core/maestro/il_seguito_nascosto.dart:26-40`, separato in `maestro_chat_controller.dart:820`; pulsante `chat_bubble.dart:454-472` | `maestro_chat_controller.dart:1447-1466`, oppure 1553-1564 con `rispostaGiaData` → `firebase_maestro_ai_provider.dart:213` → `maestro_persona.dart:630-632` | Sì, per un'altra via: `rispostaGiaData` e `SeguitoDellaLettura.istruzione`; `fraseRipresa` spenta di proposito (`firebase_maestro_ai_provider.dart:240-241`) |
| 3 | Frase presa dal seguito e rimandata | `chat_bubble.dart:375-386` (`message.seguito`) | via chat | **No**: il seguito non sta in `m.text`, quindi né nella storia né in `trova` (`firebase_maestro_ai_provider.dart:244-248` e 735) |
| 4 | Riga d'oro del consiglio (✦) riscritta o detta | `lib/core/maestro/consiglio_finale.dart:148-185`; a video `lib/design_system/components/riga_del_consiglio.dart:71-104` (solo testo, nessun tocco) | via chat | Sì se sta nell'ultima risposta (`il_filo_del_consulto.dart:366`, 283-286, 342-344). **No** per l'invito a tornare, composto dall'app fuori dal testo (`consiglio_finale.dart:251`), e **no** se la riga è in una risposta precedente |
| 5 | Frasi o domande dentro il corpo della risposta | testo del modello | via chat | Sì, solo per l'ultima risposta e sopra le soglie; **no** per le riprese corte |
| 6 | Frase del Maestro ripresa a voce nel LIVE | `maestro_chat_controller.dart:1191` | `lib/features/maestri/live/schermata_live.dart:957` → via chat | Sì, coi limiti del punto 5. Nel LIVE non c'è nessuna domanda proposta |
| 7 | Riprova | ultimo testo della persona | `maestro_chat_controller.dart:1672-1686` | Sì, come il punto 5 |
| 8 | Parlane, Oroscopo | `chat_openers.dart:101-103`; `lib/features/horoscope/oroscopo_screen.dart:4270-4272` | via chat | No: frase dell'app, conversazione nuova; il responso arriva come contesto (`azioni_del_responso.dart:289`, `sorgente_natale.dart:41`, scheda `il_filo_del_consulto.dart:212-218`) |
| 9 | Parlane, Oroscopo di un amico | `chat_openers.dart:107-109`; `oroscopo_screen.dart:4271` | via chat | No, come il punto 8 |
| 10 | Parlane, Stesa di Tarocchi | `chat_openers.dart:125-134`; `lib/features/tarot/stesa_tre_carte_screen.dart:1846-1849` | via chat | No, come il punto 8 |
| 11 | Parlane, Sinastria | `chat_openers.dart:138-140`; `lib/features/synastry/sinastria_vip_screen.dart:1116` | via chat | No, come il punto 8 |
| 12 | Parlane, Arcano dell'Alba (cita il gesto di Medora) | `chat_openers.dart:156-161`; `lib/features/rituals/arcano_dell_alba_screen.dart:205-207` | via chat | **No**: cita una frase dell'arte che non è nella storia della chat |
| 13 | Parlane, Soffio del Destino (cita il responso) | `chat_openers.dart:147-149`; `lib/features/rituals/breath_destiny_screen.dart:1363-1365` | via chat | **No**, come il punto 12 |
| 14 | Parlane, Rito della Notte (cita il saluto) | `chat_openers.dart:163-164`; `lib/features/rituals/dream_rite_screen.dart:1096` | via chat | **No**, come il punto 12 |
| 15 | Parlane, Runa del Tramonto | `chat_openers.dart:59-61`; `lib/features/rituals/sunset_rune_screen.dart:2434-2438` | via chat | No, come il punto 8 |
| 16 | Parlane, Estrazione Rune | `chat_openers.dart:64-67`; `lib/features/maestri/caligo/rune/rune_draw_screen.dart:1700-1701` | via chat | No, come il punto 8 |
| 17 | Parlane, Animale Guida | `chat_openers.dart:31-42`; `lib/features/maestri/caligo/animal/guide_animal_screen.dart:775` | via chat | No, come il punto 8 |
| 18 | Parlane, Sigillo dell'Intenzione (riscrittura proposta da Calìgo) | `chat_openers.dart:143-144`; `sigillo_intenzione_screen.dart:854`; proposta `lib/core/magic/il_sigillo_dal_modello.dart:195`, accettata in `sigillo_intenzione_screen.dart:216-224` | via chat | **No**: la frase di Calìgo torna a Calìgo senza marcatura |
| 19 | Parlane, Test Archetipo | `chat_openers.dart:79-80`; `archetype_test_screen.dart:985` | via chat | No, come il punto 8 |
| 20 | Parlane, Costellazione del Viso | `chat_openers.dart:84-87`; `face_constellation_screen.dart:1799-1800` | via chat | No, come il punto 8 |
| 21 | "Continua con" dal Consiglio | `chat_openers.dart:52-56`; `ask_maestri_screen.dart:458` (pulsante 718) | `ask_maestri_screen.dart:455-459` → via chat | No come ripresa: cita la domanda della persona; i pareri del Consiglio stanno nella scheda (`ask_maestri_screen.dart:366-372` → `il_filo_del_consulto.dart:262-270`) |
| 22 | "Chiedi anche agli altri" → Consiglio | `maestro_chat_controller.dart:1329-1336`; `chat_bubble.dart:500`; `maestro_chat_screen.dart:441`, 458-462 | `ask_maestri_screen.dart:318-324` → `firebase_maestro_ai_provider.dart:458-502` | **No**: `consult` riceve il filo senza `fraseRipresa` |
| 23 | Invito finale del benvenuto | `lib/core/maestro/maestro_welcome.dart:52-54`; `voce_del_maestro.dart:385`, 468; a video `maestro_chat_screen.dart:992-995` | via chat | **No**: il benvenuto non è un messaggio della storia |
| 24 | "Scegli una domanda" della gettata di rune | `domande_del_cerchio.dart:83`, 117; `rune_draw_screen.dart:698-701`, 2443-2453 | Non arriva a un Maestro: va al presagio deterministico | No, perché non arriva a un Maestro |
| 25 | "Scegli la tua domanda" della Stesa | `tarot_topic.dart:73`; `tarot_selectors.dart:290-299` | Motore deterministico; in chat solo dentro il punto 10 | No, come il punto 24 |
| 26 | `initialTheme` | `maestro_chat_screen.dart:91`, 937 | via chat | No: nessun chiamante lo passa (codice morto) |

## Punti non collegati al filo

**Guasti veri: una frase del Maestro o dell'arte torna al Maestro senza marcatura**

1. La frase presa dal seguito, perché il seguito non sta in `m.text` (punto 3).
2. Le righe di una risposta che non è l'ultima: `trova` guarda solo l'ultimo messaggio del Maestro (punti 4 e 5).
3. L'invito a tornare sotto la riga d'oro, composto fuori dal testo (punto 4).
4. Le riprese corte, sotto le soglie.
5. I Parlane che citano parole dell'arte o del Maestro: Arcano dell'Alba, Soffio, Rito della Notte, Sigillo (punti 12, 13, 14 e 18).
6. "Chiedi anche agli altri": `consult` non riceve `fraseRipresa` (punto 22).
7. L'invito del benvenuto, che non sta nella storia (punto 23).
8. L'instradamento: una frase ripresa che nomina un'arte apre l'arte senza chiamare il modello (`maestro_chat_controller.dart:1255-1290`), e il filo non c'entra.

**Scollegati per natura: frasi dell'app e non del Maestro**
- Il pannello dei suggerimenti (punto 1).
- I Parlane con dati e nomi (punti 8, 9, 10, 11, 15, 16, 17, 19 e 20).
- "Continua con", coperto dalla scheda dei punti fermi (punto 21).
- Le domande delle arti, che non arrivano a un Maestro (punti 24 e 25).
- `initialTheme`, codice morto (punto 26).

**Collegati**
- I punti 4 e 5, solo per l'ultima risposta.
- I punti 6 e 7.
- Il punto 2, per un'altra via.

## Note

- La home e le arti non suggeriscono frasi da mandare. La home apre la chat vuota.
- I suggerimenti al primo uso (`lib/core/primo_uso/suggerimenti_di_zona.dart:35-36`) sono consigli d'uso.
- Il Consiglio non propone domande: il campo è stato tolto (`ask_maestri_screen.dart:189-195`).
- `SuggestionSets.starters` (`chat_suggestions.dart:54`) non ha chiamanti.
