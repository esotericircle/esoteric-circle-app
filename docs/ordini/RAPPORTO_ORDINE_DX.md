# RAPPORTO DELL'ORDINE DX, LA CHAT DI APPROFONDIMENTO NON PARTE DA SOLA E LA DETTATURA SCRIVE QUELLO CHE SI DICE

**Data:** 18 settembre 2026. **Ramo:** `claude/esoteric-circle-master-order-e798aj`.
**Manifesto:** `docs/ordini/ORDINE_DX_MANIFESTO.md`, col censimento completo
delle porte. **Sigla:** DX, la prima libera dopo DW, verificata sul ramo.

**Sei voci, sei chiuse.** Cinque con codice e prove; la sesta chiusa per
decisione del fondatore, senza codice. La consegna Android e la build iOS
sono nella sezione 7.

---

## 1. COSA NON ANDAVA, E PERCHE'

Dalla Costellazione del Viso, *Parlane con Aura* ha aperto la chat e la
domanda preimpostata e' partita da sola. Poi la frase dettata e' diventata
*"Indicate"*, e' partita anche lei, ed e' rimasta nel campo. In cima il
contatore diceva *1 domanda su 3*.

- **La domanda partiva da sola** perche' era stata scritta per partire:
  `_maybeSendInitial` (`maestro_chat_screen.dart:481-491` nella 2270) la
  mandava appena la chat era pronta.
- **"Indicate"**: la dettatura non diceva al riconoscitore in che lingua
  ascoltare (`dettatura_vera.dart:82-96`). Su iPhone il plugin ricade allora
  sulla lingua che l'app dichiara, e il progetto iOS dichiara solo l'inglese
  (`project.pbxproj:202-207`). Un riconoscitore inglese sente *"quindi"* e
  scrive *"Indicate"*. Su Android il plugin usa la lingua del telefono, ed e'
  per questo che il Realme non l'aveva mai mostrato.
- **"Indicate" nel campo dopo l'invio**: l'invio svuotava il campo ma non
  fermava la dettatura (`chat_composer.dart:148-154`), e il risultato finale
  del riconoscitore, che arriva dopo i parziali, lo riscriveva.
- **Le due domande consumate**: la preimpostata e *"Indicate"*, tutte e due
  con una risposta vera. Il consumo e' in
  `maestro_chat_controller.dart:531-533`.

## 2. COSA E' CAMBIATO, VOCE PER VOCE

| voce | prodotto | agganciato al codice | verificato a video |
|---|---|---|---|
| DX.01 la domanda aspetta nel campo | si' | si', tutte e tredici le porte passano dalla stessa chat | **da vedere**, sezione 7 |
| DX.02 la dettatura ascolta in italiano | si' | si' | **solo su iPhone**, con la build di Codemagic: su Android il difetto non c'era |
| DX.03 il censimento | si', tredici porte nel manifesto | la guardia confronta il codice col censimento | non serve |
| DX.04 il campo vuoto dopo l'invio | si' | si' | **da vedere dettando**: nessuna prova da banco parla al telefono |
| DX.05 dove si consuma | risposta, senza codice | il consumo resta solo sugli invii veri | con DX.01 |
| DX.06 il testo sotto la barra | nessun codice: resta il 2161, per decisione | | |

**La cura della DX.02 non tocca la dichiarazione delle lingue iOS.**
Aggiungere l'italiano al progetto iOS cambierebbe anche la lingua dei
dialoghi di sistema in tutta l'app, e questo esce dal perimetro. La
dettatura adesso chiede la lingua per nome: l'italiano dell'app, scelto fra
le voci che la piattaforma elenca (`it-IT` prima di `it-CH`), oppure chiesto
come `it_IT` se la piattaforma non elenca niente.

## 3. LE DECISIONI DEL FONDATORE

- **DX.06, resta il 2161.** Gli ho chiesto se tagliare la chat sopra la barra
  o lasciare il vetro che mostra i messaggi, come aveva deciso con l'ordine
  2161 (`maestro_chat_screen.dart:604-609`). Ha scelto di lasciarlo.
- **Build**: autorizzata in corsa d'ordine, *"quando hai finito crea nuova
  Build anche per codemagic e consegna su AppTester"*.

## 4. GLI SCARTI FRA L'ORDINE E IL RAMO

- **Voce 04**, l'ordine lascia aperte due possibilita': il campo restava
  pieno, oppure la dettatura ci ha scritto una seconda volta. **E' la
  seconda.** Il campo si svuotava davvero (`chat_composer.dart:152` nella
  2270), e la dettatura ci riscriveva.
- **Voce 06**, l'ordine lo chiama difetto. **E' una decisione del fondatore**,
  l'ordine 2161, scritta nel codice alle righe 604-609 di
  `maestro_chat_screen.dart`. Chiesta conferma, resta.
- **Voce 02**, l'ordine dice *"la dettatura non funziona"*. Sul ramo funziona
  su Android e sbaglia la lingua su iPhone: il difetto e' di una piattaforma
  sola.

## 5. I PADRI

- **La domanda che parte da sola, e con lei una delle due domande
  consumate**: commit `80740852` del 23 luglio 2026, *"Animale Guida: viaggio
  col tamburo, faccia nel Passport, chat contestuale"*. Era una regola
  trasversale voluta: *"la chat si apre gia' con una prima domanda scritta e
  inviata"*. E' precedente ai manifesti, quindi non ha una sigla d'ordine.
- **La dettatura senza lingua**: ordine **CI voce 05**, commit `6c21083c` del
  1 settembre 2026, che ha fatto nascere `DettaturaVera`.
- **L'invio che non ferma la dettatura**: stesso ordine, **CI voce 05**,
  stesso commit, nel compositore.
- **Fuori dal perimetro, ma bloccava la consegna**: il corredo delle
  anteprime cadeva perche' le catture delle card dell'ordine **DW** (commit
  `d5e28237`) impostavano il rapporto a mano
  (`screenshot_capture_test.dart:2644`) invece di passare da
  `montaLoSchermo`. Era gia' rosso sul cancello di GitHub per quel commit,
  quindi la build iOS da `d5e28237` non sarebbe partita. Riparato nella
  prova, con la stessa misura fisica: nessun codice dell'app toccato.
- **Due cadute dell'albero, non del codice**: le guardie dei manifesti CO e
  DT cadevano perche' questo worktree era estratto con fine riga CRLF
  (`core.autocrlf=true`); il repository e GitHub hanno LF. Riestratto in LF
  senza toccare la configurazione condivisa.

## 6. LE PROVE

- **Regola B**: `chat_initial_message_test.dart` e
  `il_microfono_della_chat_test.dart` viste verdi (14 con la guardia del
  Consiglio), poi rosse coi due innesti: invio iniziale spento (due cadute),
  dettatura che cancella invece di aggiungere (una). File rimessi e
  verificati col grep dell'innesto a zero.
- **Regola A, guardie nuove, tutte viste rosse**:
  - l'invio automatico rimesso fa cadere due prove della DX.01;
  - l'invio che non chiude il giro della dettatura fa cadere la DX.04;
  - la dettatura senza lingua fa cadere la DX.02;
  - `le_porte_di_approfondimento_non_mandano_da_sole`: una tredicesima porta
    innestata nell'arte in arrivo la fa cadere, e cosi' la chat che rimanda
    la domanda da sola. **La seconda misura era cieca al primo giro**:
    guardava solo cio' che segue il nome, e il `send` stava prima. Cambiata
    la grandezza (la riga intera), non la soglia.
- **Registro delle guardie**: 441, categorie 136, 113 e 192.
- **Sigillo aggregato**: `'DX': 6` in `i_manifesti_sono_sigillati_test.dart`.
- **Prove delle arti col Parlane**: 132, verdi.
- **flutter analyze** su tutto il progetto: nessun problema.

## 7. LA CONSEGNA

- **Commit del codice**: `b9ffd73d`, spinto sul ramo canonico e verificato
  con `git ls-remote`. **Cancello di GitHub su quel commit: "analyze e
  sbarramento" verde**, cioe' il verdetto che la build iOS legge. La "Ronda
  dei motori" e' rossa, com'era gia' sui commit precedenti.
- **Sbarramento locale**: 5542 prove, rossi accettati e solo quelli,
  gettone col numero 2271. Il primo giro era rosso per il corredo del DW e
  per due fatti dell'albero (lavoro non spinto, fine riga CRLF): sezione 5.
- **Android 2271**, release App Distribution `479lvkjv5msbg`, 204.677.187
  byte, distribuita. **Prova di accensione sul Realme 767f596c**: processo
  vivo, primo fotogramma disegnato, nessun FATAL, numero letto dal telefono
  2271.
- **Visto sul Realme con la 2271 (DX.01)**: dall'Oroscopo, *Parlane con
  Medora* apre la chat con *"Ho letto il mio oroscopo di oggi, Gemelli. Cosa
  vuole dirmi il cielo che non ho colto?"* nel campo; dopo dieci secondi
  nessuna risposta e' partita. Cattura in
  `docs/collaudo/DX/realme_2271_parlane_con_medora.png`. Non l'ho mandata.
- **Non visto a video**: la dettatura su iPhone (DX.02) e il campo vuoto
  dopo un invio dettato (DX.04); nessuna prova da banco parla a un telefono.
  **Il giudizio visivo resta del fondatore.**
- **iOS**: la build si lancia da Codemagic sul commit `b9ffd73d` o
  successivo, gia' verde su GitHub. Sulla macchina non c'e' una chiave di
  Codemagic, quindi la lancia il fondatore.
- **Per costruire da questo worktree** sono serviti `android/key.properties`,
  il keystore e `google-services.json`, copiati dall'albero principale: sono
  esclusi da Git e non sono entrati in nessun commit.
