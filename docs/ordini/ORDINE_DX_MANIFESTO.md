# ORDINE DX, LA CHAT DI APPROFONDIMENTO NON PARTE DA SOLA E LA DETTATURA SCRIVE QUELLO CHE SI DICE

**Sigla:** DX, la prima libera dopo DW: verificato sul ramo, in `docs/ordini`
non c'e' nessun `ORDINE_DX_*` e in `test` nessun `ordine_dx_*`. **Data:** 18
settembre 2026. **Ramo:** `claude/esoteric-circle-master-order-e798aj`. Parte
dal commit `d5e28237` (build 2270).

**Il fatto, dal fondatore**, con una cattura da iPhone: dalla Costellazione del
Viso di Aura, *Parlane con Aura* apre la chat e la domanda preimpostata
(*"Il mio tratto dominante è la fronte verticale, cosa racconta di me?"*) parte
e riceve risposta da sola. Poi la frase dettata *"quindi, cosa devo fare della
mia lettura?"* arriva nel campo come *"Indicate"*, parte e riceve risposta.
In cima: *"Ti resta 1 domanda ai Maestri su 3, oggi"*. Dopo l'invio
*"Indicate"* resta anche nel campo. Il testo di Aura si legge attraverso la
barra in basso.

VOCI_TOTALI: 6
VOCI_CHIUSE: 6
VOCI_APERTE: 0
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0

Il rapporto sta in `docs/ordini/RAPPORTO_ORDINE_DX.md`.

---

## I FATTI, RISCONTRATI SUL CODICE PRIMA DI USARLI

| cosa dice l'ordine | il riscontro sul ramo | esito |
|---|---|---|
| la domanda preimpostata parte da sola | **vero**: `MaestroChatScreen._maybeSendInitial` (`lib/features/maestri/chat/maestro_chat_screen.dart:481-491`) chiama `controller.send(testo)` appena la chat ha caricato, chiamata da `build` alla riga 514. Nato come comportamento voluto: il commento del parametro `initialUserMessage` (riga 88-91) dice *"gia' inviata come turno dell'utente appena la chat e' pronta"* | **VERO** |
| la dettatura scrive "Indicate" | **causa trovata**: `DettaturaVera.ascolta` (`lib/services/voce/dettatura_vera.dart:82-96`) non passa nessuna lingua al riconoscitore. Il plugin iOS allora usa `Locale.current` (`speech_to_text-7.4.0/darwin/.../SpeechToTextPlugin.swift:376-378`), e per un'app `Locale.current` e' la lingua fra quelle che l'app DICHIARA: il progetto iOS dichiara solo l'inglese (`ios/Runner.xcodeproj/project.pbxproj:202-207`, `developmentRegion = en`, `knownRegions` = en e Base; in `ios/Runner/Info.plist` nessun `CFBundleLocalizations`). Su un iPhone in italiano la dettatura ascolta con il riconoscitore inglese, che sente "quindi" e scrive "Indicate". Su Android il plugin usa la lingua del sistema (`SpeechToTextPlugin.kt:135`), per questo al banco del Realme non si vedeva | **VERO, CAUSA NEL CODICE** |
| "Indicate" resta nel campo dopo l'invio | **causa trovata**: `_submit` (`lib/features/maestri/chat/widgets/chat_composer.dart:148-154`) svuota il campo ma non ferma la dettatura, e la callback `parole` (riga 125-133) continua a scrivere nel campo ogni risultato che arriva dopo. Con `partialResults: true` il risultato finale arriva DOPO il tocco di invio, e riscrive nel campo la stessa parola appena mandata | **VERO** |
| le due domande consumate | **vero**: tutte e due passano da `MaestroChatController.send` e generano, e il consumo avviene in `lib/features/maestri/chat/maestro_chat_controller.dart:531-533` (`contatore.record(piano)` se `CostoDelTurno.consuma(esito)`). Tre del piano gratuito meno due: uno | **VERO** |
| il testo si legge sotto la barra | **vero, ed e' una decisione del fondatore**: `maestro_chat_screen.dart:604-609`, ordine 2161, *"i messaggi scorrono sotto il compositore e sotto la barra, il vetro della barra si legge perche' sotto c'e' contenuto"*. Chiesto al fondatore il 18 settembre 2026: **resta il 2161** | **VOLUTO** |

---

## LE VOCI

- **DX.01**, il testo preimpostato non parte da solo: resta nel campo, la
  risposta parte solo quando la persona invia, niente si consuma prima,
  il testo si modifica, si cancella, si sostituisce scrivendo o dettando.
  **Fatto**: tolto `_maybeSendInitial` da `maestro_chat_screen.dart`, e
  `initialUserMessage` arriva al campo come `initialText` (riga 829); il
  campo si apre con la domanda anche se con quel Maestro c'e' gia' una
  conversazione. Prove in `test/chat_initial_message_test.dart`: la domanda
  e' nel campo, il modello non riceve niente e il contatore resta a zero
  per un secondo e mezzo; mandata dalla persona parte, risponde e consuma
  una; cambiata, parte quella nuova. Viste rosse con l'invio automatico
  rimesso. **Prodotto e agganciato; a video da vedere sul telefono.**
  **CHIUSA.**
- **DX.02**, la dettatura scrive quello che si dice: la causa col file e la
  riga, e la cura.
  **Causa**: `lib/services/voce/dettatura_vera.dart:82-96` nella build 2270,
  `listen` senza lingua; il plugin iOS ricade su `Locale.current`
  (`SpeechToTextPlugin.swift:376-378`), che per quest'app e' l'inglese
  perche' il progetto iOS dichiara solo `en`
  (`ios/Runner.xcodeproj/project.pbxproj:202-207`). **Fatto**: la dettatura
  ascolta nella lingua dell'app (`localeId`, riga 151), scelta fra le voci
  che la piattaforma dichiara da `voceDellaLingua` (riga 58) e costruita per
  nome se la piattaforma non ne elenca; la lingua arriva dalla chat
  (`maestro_chat_screen.dart:233`). La dichiarazione delle lingue nel
  progetto iOS **non si tocca**: cambierebbe la lingua dei dialoghi di
  sistema di tutta l'app, fuori perimetro. Prove in
  `test/il_microfono_della_chat_test.dart`, con un riconoscitore finto
  dietro la dettatura vera; vista rossa togliendo la lingua. **Prodotto e
  agganciato; la verifica vera e' solo su iPhone, con la build di Codemagic.**
  **CHIUSA.**
- **DX.03**, tutte le porte di approfondimento: il censimento qui sotto, con
  l'esito di ogni voce per ciascuna.
  **Fatto**: tredici porte, tutte nel censimento; guardia
  `test/le_porte_di_approfondimento_non_mandano_da_sole_test.dart`, vista
  rossa con una tredicesima porta innestata e con la chat che rimanda la
  domanda. **CHIUSA.**
- **DX.04**, dopo l'invio il campo e' vuoto, anche se la dettatura stava
  ancora ascoltando.
  **Causa**: la seconda delle due ipotesi dell'ordine. Il campo si svuotava
  (`_submit`, `chat_composer.dart:148-154` nella 2270), e la dettatura, che
  nessuno fermava, ci riscriveva il risultato finale arrivato dopo il tocco.
  **Fatto**: l'invio chiude il giro della dettatura e la ferma
  (`chat_composer.dart:169-173`); ogni risultato di un giro chiuso si
  scarta. Prova in `il_microfono_della_chat_test.dart`, vista rossa con
  l'invio che non chiude il giro. **Prodotto e agganciato; a video da
  vedere dettando sul telefono.** **CHIUSA.**
- **DX.05**, le domande consumate: quali invii hanno consumato e dove.
  **Risposta**: tutti e due. La domanda preimpostata e *"Indicate"* sono
  passate da `MaestroChatController.send` e hanno generato una risposta
  vera, e il consumo avviene in
  `lib/features/maestri/chat/maestro_chat_controller.dart:531-533`
  (`contatore.record(piano)` quando `CostoDelTurno.consuma(esito)`); tre del
  piano gratuito meno due fa uno, come nella cattura. Con DX.01 la domanda
  preimpostata non consuma piu' finche' non si manda; il consumo resta
  solo sugli invii veri, misurato nelle prove di DX.01. **CHIUSA.**
- **DX.06**, il testo della chat sotto la barra in basso.
  **Decisione del fondatore, 18 settembre 2026**: interrogato sullo scarto
  con l'ordine 2161 (`maestro_chat_screen.dart:604-609`), ha scelto *"Resta
  il 2161"*: i messaggi continuano a scorrere sotto la barra e il vetro li
  lascia vedere. Il campo di scrittura e' gia' opaco dall'ordine 2163.
  Nessun codice toccato. **CHIUSA.**

---

## IL CENSIMENTO, VOCE DX.03

Tutte le porte verso la chat dei Maestri, cercate con
`grep -rn 'MaestroChatScreen.route' lib` e `grep -rn 'AzioniDelResponso(' lib`.
Le porte di approfondimento sono quelle che portano una domanda preimpostata
(`initialUserMessage`). **Tredici**, come dichiara `ChatOpeners`
(`lib/features/maestri/chat/chat_openers.dart:94-95`, *"tredici su tredici"*):
dodici passano dal pulsante comune *Parlane con* di `AzioniDelResponso`
(`lib/features/ricordi/azioni_del_responso.dart:338`, che apre la chat alla
riga 252), una dal *Continua con* del Consiglio.

| funzione | file e riga della porta | apertura | DX.01 | DX.02 | DX.04 | DX.05 | DX.06 |
|---|---|---|---|---|---|---|---|
| Oroscopo | `lib/features/horoscope/oroscopo_screen.dart:1671` | `ChatOpeners.oroscopo` | nel campo, non parte | lingua dell'app | campo vuoto | consuma solo all'invio | resta il 2161 |
| Test dell'Archetipo | `lib/features/maestri/aura/archetype/archetype_test_screen.dart:975` | `ChatOpeners.archetipo` | nel campo, non parte | lingua dell'app | campo vuoto | consuma solo all'invio | resta il 2161 |
| Costellazione del Viso | `lib/features/maestri/aura/face/face_constellation_screen.dart:1790` | `ChatOpeners.viso` | nel campo, non parte | lingua dell'app | campo vuoto | consuma solo all'invio | resta il 2161 |
| Animale Guida | `lib/features/maestri/caligo/animal/guide_animal_screen.dart:765` | `ChatOpeners.animale` | nel campo, non parte | lingua dell'app | campo vuoto | consuma solo all'invio | resta il 2161 |
| Estrazione delle Rune | `lib/features/maestri/caligo/rune/rune_draw_screen.dart:1614` | `ChatOpeners.runa` | nel campo, non parte | lingua dell'app | campo vuoto | consuma solo all'invio | resta il 2161 |
| Sigillo dell'Intenzione | `lib/features/maestri/caligo/sigillo/sigillo_intenzione_screen.dart:790` | `ChatOpeners.sigillo` | nel campo, non parte | lingua dell'app | campo vuoto | consuma solo all'invio | resta il 2161 |
| Arcano dell'Alba | `lib/features/rituals/arcano_dell_alba_screen.dart:168` | `ChatOpeners.arcanoAlba` | nel campo, non parte | lingua dell'app | campo vuoto | consuma solo all'invio | resta il 2161 |
| Soffio del Destino | `lib/features/rituals/breath_destiny_screen.dart:824` | `ChatOpeners.soffio` | nel campo, non parte | lingua dell'app | campo vuoto | consuma solo all'invio | resta il 2161 |
| Rito del Sogno | `lib/features/rituals/dream_rite_screen.dart:1071` | `ChatOpeners.sogno` | nel campo, non parte | lingua dell'app | campo vuoto | consuma solo all'invio | resta il 2161 |
| Runa del Tramonto | `lib/features/rituals/sunset_rune_screen.dart:2359` | `ChatOpeners.runaTramonto` | nel campo, non parte | lingua dell'app | campo vuoto | consuma solo all'invio | resta il 2161 |
| Sinastria VIP | `lib/features/synastry/sinastria_vip_screen.dart:1102` | `ChatOpeners.sinastria` | nel campo, non parte | lingua dell'app | campo vuoto | consuma solo all'invio | resta il 2161 |
| Stesa delle Tre Carte | `lib/features/tarot/stesa_tre_carte_screen.dart:1725` | `ChatOpeners.stesa` | nel campo, non parte | lingua dell'app | campo vuoto | consuma solo all'invio | resta il 2161 |
| Consiglio dei Maestri, *Continua con* | `lib/features/maestri/ask/ask_maestri_screen.dart:421` (pulsante alla riga 659) | `ChatOpeners.consiglio` | nel campo, non parte | lingua dell'app | campo vuoto | consuma solo all'invio | resta il 2161 |

**Le due porte che NON sono di approfondimento**, e restano fuori perimetro:
*Consulta* dall'arte in arrivo (`lib/features/maestri/art_intro_screen.dart:114`)
e la chat dal Santuario (`lib/features/maestri/maestro_screen.dart:655`): tutte e
due aprono la chat senza domanda.

**Una porta sola per tutte e tredici.** Nessuna funzione manda la domanda da
se': tutte passano `initialUserMessage` a `MaestroChatScreen.route`, e l'invio
automatico stava soltanto in `_maybeSendInitial`. Lo stesso per la dettatura,
il campo e il consumo: vivono nella chat, non nelle funzioni. L'esito di ogni
voce e' quindi lo stesso per tutte e tredici, **verificato al banco** nella
chat, che e' la stessa per tutte, e con la guardia sulle porte; le prove
delle arti (132, verdi) dicono solo che niente si e' rotto nelle funzioni.
**Da vedere a video** sul telefono, e la guardia lo pretende contando
le porte: una porta nuova che apre la chat in un altro modo la fa cadere.
