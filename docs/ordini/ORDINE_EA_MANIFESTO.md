# ORDINE EA, LE CORREZIONI DOPO LA 2272: CHAT, TUTORIAL, ACCESSO, RUNE, PASSPORT, MENU' UTENTE, PAGINA LEGALE E CANCELLO

**Sigla:** EA, la prima libera dopo DZ: verificato sul ramo, in `docs/ordini`
non c'e' nessun `ORDINE_EA_*`. **Data:** 19 settembre 2026. **Ramo:**
`claude/esoteric-circle-master-order-e798aj`. Parte dal commit `007b360f`
(build 2272).

**Decisioni del fondatore del 19 settembre 2026, prese all'avvio**: i tre
lotti di fila e poi una sola build; la Ronda dei motori legge i rossi
accettati come lo sbarramento, e i due rossi voluti restano dichiarati.

VOCI_TOTALI: 21
VOCI_CHIUSE: 14
VOCI_APERTE: 7
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0

Il rapporto sta in `docs/ordini/RAPPORTO_ORDINE_EA.md`.

---

## LE VOCI

- **EA.01**, a chat vuota il menu' della chat non comincia con una riga
  divisoria.
  **Fatto**: in `maestro_chat_screen.dart` la riga in cima si disegna solo
  se sopra c'e' *Ricomincia* e sotto c'e' almeno una conversazione, e quella
  prima de *I giorni prima* solo se sopra c'e' qualcosa. Prova in
  `test/chat_initial_message_test.dart`. Commit `72700674`. **Prodotto e
  agganciato; a video con la build dell'ordine.** **CHIUSA.**
- **EA.02**, il tutorial compare solo quando si e' arrivati alla home, mai
  sopra un foglio o una schermata.
  **Fatto**: `PrimoApprodo` riceve `sullaHome` e `cambiDellaPila` da
  `lib/app.dart`, che li legge dall'`OsservatoreDellaPila`: il velo si
  disegna solo quando nella pila c'e' la sola home, e torna quando il foglio
  o la schermata si chiude. Il foglio della registrazione e' una rotta della
  pila, quindi lo copre la stessa regola. Prova in
  `test/il_primo_approdo_test.dart`. Commit `72700674`. **Prodotto e
  agganciato; a video con la build dell'ordine.** **CHIUSA.**
- **EA.03**, la Ronda dei motori e' verde: legge i rossi accettati, e i
  rossi che non lo sono si riparano.
  **Fatto**: in `.github/workflows/ronda.yml` la suite intera non si lancia
  piu' con `flutter test` nudo, che il registro dei rossi accettati non lo
  conosce: passa da `tool/sbarramento.sh`, lo stesso comando del cancello e
  di Codemagic, che sui rossi elencati passa stampandoli col loro nome e la
  loro ragione e si ferma su qualunque rosso non dichiarato. La Ronda
  pubblica anche il verdetto leggibile senza credenziali, come il cancello.
  **I rossi non accettati non c'erano**, ed e' misurato e non dedotto: sul
  commit `007b360f` la Ronda dava *5568 passate, 4 cadute*, e sullo stesso
  commit il cancello `verde.yml`, che gia' passa dallo sbarramento, era
  **verde** (giro 35403654414). Quattro cadute che lo sbarramento lascia
  passare sono quattro rossi dichiarati. La Ronda dei motori vera e propria,
  cioe' il passo che prova i motori, non e' mai caduta in nessuno dei tre
  giri guardati. Guardia `test/la_ronda_legge_i_rossi_accettati_test.dart`,
  vista rossa rimettendo il `flutter test` nudo. **Prodotto e agganciato; si
  vedra' verde al primo giro notturno dopo la spinta.** **CHIUSA.**
- **EA.04**, due decisioni registrate: DX.06 non si corregge; il tutorial
  finito fino in fondo torna all'apertura dopo.
  **Fatto**: in `docs/ordini/ORDINE_DX_MANIFESTO.md` (la voce, la riga 34 e
  le tredici celle della colonna DX.06), in `RAPPORTO_ORDINE_DX.md` e in
  `docs/STATO_VIVO.md` la ragione di DX.06 e' la decisione del 19 settembre
  2026 al posto del rimando al 2161. **Il rimando sul ramo c'e'**: il
  commento *"L'ECCEZIONE SULLA CHAT E' REVOCATA DA MAURO, ordine 2161"* in
  `lib/features/maestri/chat/maestro_chat_screen.dart`, riga 612 al commit
  `007b360f`, 617 oggi; le righe 604-609 citate in DX erano spostate di otto
  righe. Il tutorial finito come *Salta* e' registrato come decisione del 19
  settembre in `ORDINE_DY_MANIFESTO.md`, `RAPPORTO_ORDINE_DY.md` e
  `STATO_VIVO.md`. Nessun codice. **CHIUSA.**
- **EA.05**, la Runa del Tramonto e l'Estrazione Rune senza astrologia; la
  fase lunare della sera resta.

  **IL CENSIMENTO DEI LEGAMI, e cosa ne e' stato.**

  *La Runa del Tramonto:*

  | posto | dove stava | cosa ne e' stato |
  |---|---|---|
  | il calcolo | `sunset_rune.dart`, il segno derivato dalla nascita dentro la chiave della runa | tolto; la chiave tiene il suffisso `nessuno`, cosi' chi non aveva dato la nascita ritrova la sua runa di sempre |
  | il responso | `sunset_rune_corpus.dart`, dodici clausole di segno nella Voce B | tolte tutte e dodici |
  | il responso | `sunset_rune_corpus.dart`, `trasparenza` chiudeva con *"sotto il segno X"* | chiude sulla fase lunare |
  | i testi a video | `sunset_rune_screen.dart`, *"col tuo segno"* e *"il tuo segno solare"* nelle Fonti | riscritti: tre fattori, la runa, il verso e la fase lunare della sera |
  | l'apertura | `sunset_rune_screen.dart`, il parametro `segno` nella schermata e nella rotta | tolto; nessun chiamante lo passava |
  | l'invito di Caligo | `consiglio_finale.dart`, annunciava la runa di domani sera calcolata col segno | senza segno: la runa annunciata e' quella che l'arte dara' |
  | i prompt | nessuno: il Tramonto non chiama Gemini | niente da fare |
  | il Cammino | il Sigillo `cal_55` chiedeva *la Luna piena nel tuo segno* col Tramonto | **decisione del fondatore del 19 settembre 2026, *"legalo solo alla luna piena"***: adesso chiede dodici Lune piene col Tramonto, vedi sotto |

  *L'Estrazione Rune:*

  | posto | dove stava | cosa ne e' stato |
  |---|---|---|
  | il calcolo | la scelta delle rune e' caso vero, il segno non la toccava | niente |
  | i semi | `rune_draw_screen.dart`, senza nascita la persona era `userSign.name` nel seme della caduta e della dizione | identita' comune `cerchio` |
  | il responso | `rune_voce.dart`, *"col Sole in Vergine e la Luna crescente"* | resta la sola Luna: *"con la Luna crescente"*; un ponte e' stato riscritto perche' reggesse quella coda |
  | le domande | `domande_del_cerchio.dart`, quattro personali astrologiche (Sole, Luna, Ascendente, segno) su otto | tolte; le personali della gettata sono quattro |
  | le cornici | `cornici_del_presagio.dart`, le quattro cornici di quelle domande | tolte; le cornici sono dodici, ed erano sedici |
  | la fonte delle cornici | `docs/responsi/cornici.md`, sezioni P1, P2, P3 e P6 | restano nel documento, marcate RITIRATA: il testo dell'Architetto non si taglia, e il lettore del codice non le prende piu' |
  | le Fonti e metodo | `rune_voce.dart`, *"agganciata al cielo calcolato del giorno"* | *"con la fase della Luna di quel giorno. Nessun segno zodiacale entra nella lettura"* |
  | i prompt | `maestro_persona.dart` e `firebase_maestro_ai_provider.dart`, il presagio portava il contesto natale (segno solare, lunare, Ascendente), oggi sempre vuoto | la porta e' chiusa, e al modello si dice per iscritto di non nominare segni, pianeti, Ascendente ne' carta natale |
  | l'apertura | `art_navigation.dart`, senza data di nascita l'arte non si apriva e mandava a darla | si apre sempre |
  | il pulsante *influenza del cielo* | **non esiste**: a video non c'e', e *"Il cielo con la domanda"* e' un commento nel codice | niente |

  **La fase lunare della sera resta**, per decisione del fondatore del 19
  settembre 2026: nel Tramonto e' il registro lunare della Voce A e la riga
  della trasparenza, nelle Rune e' la Luna del giorno nella frase del cielo.

  **Cosa cambia per chi usa l'app**: chi ha dato la data di nascita vedra' la
  sua Runa del Tramonto cambiare **una volta**, il giorno in cui arriva questa
  versione. E' il prezzo dichiarato di togliere il segno dal calcolo.

  **Il Sigillo delle dodici Lune.** La sola Luna piena torna ogni mese, e
  `cal_55` e' l'ultimo gradino dell'anno di Caligo, da centotrenta Eos:
  chiederne una lo avrebbe reso il gradino piu' facile in cima alla scala.
  Adesso ne chiede **dodici**, e costa 345 giorni, l'attesa della prima piu'
  undici ritorni della Luna; il gradino prima ne costa 340, quindi la scala
  non scende. Il corpus e' stato toccato **alla fonte**
  (`tool/corpus_traguardi_dati.py` e `tool/corpus_traguardi.py`) e rigenerato.
  La memoria delle sere passate vive nei dettagli del gesto, dove la Runa del
  Tramonto scrive la Luna piena quando c'e' davvero.

  Guardie: `il_tramonto_delle_dodici_lune` (nuova, vista rossa con due
  innesti) e, in zona, `sunset_rune` con la prova nuova *nessun segno
  zodiacale in nessuna riga, per un anno di sere*, `corpus_rune_attestato` e
  `la_scheda_della_runa_non_si_ripete`, tutte viste rosse rimettendo il segno.
  **Prodotto e agganciato; a video con la build dell'ordine.** **CHIUSA.**
- **EA.06**, la chat con un Maestro si apre sempre nuova e vuota; le
  precedenti stanno nel menu'.
  **Il censimento dei punti di apertura.** Sul ramo la chat si apre da una
  porta sola, `MaestroChatScreen.route`
  (`lib/features/maestri/chat/maestro_chat_screen.dart:104`), che adesso
  crea il controllore con `conversazioneNuova: true` (riga 126). La
  chiamano quattro file:

  | punto di apertura | file e riga |
  |---|---|
  | la schermata del Maestro, *Parla con* | `lib/features/maestri/maestro_screen.dart:655` |
  | l'intro dell'arte, *Chiedi al Maestro* | `lib/features/maestri/art_intro_screen.dart:114` |
  | il Consiglio dei Maestri, *Continua con* | `lib/features/maestri/ask/ask_maestri_screen.dart:421` |
  | gli approfondimenti dei responsi (Oroscopo e le altre tredici arti del censimento DX) | `lib/features/ricordi/azioni_del_responso.dart:252` |

  Nessuno costruisce `MaestroChatScreen(` fuori dalla rotta: l'unico
  costruttore e' alla riga 164 dello stesso file, dentro la rotta. Le
  conversazioni di prima si riaprono dal menu' della chat. Prova in
  `test/chat_initial_message_test.dart`. Commit `72700674`. **Prodotto e
  agganciato; a video con la build dell'ordine.** **CHIUSA.**
- **EA.07**, dal menu' della chat si cancella ciascuna conversazione
  precedente.
  **Fatto**: un cestino accanto a ogni conversazione del menu', con una
  domanda di conferma. Il telefono la toglie subito (`chat.cancellate.<id>`
  nelle preferenze, dichiarata in `CioCheETuo` e nello scarico dei dati) e
  chiede al server di cancellarne i messaggi con la funzione nuova
  `cancellaLaConversazione` (`functions/src/cerchio.ts`), perche' le regole
  di Firestore vietano le scritture dal telefono. Prova in
  `test/chat_initial_message_test.dart`. Commit `72700674`. **Prodotto e
  agganciato; la cancellazione sul server vale dopo che Mauro pubblica le
  funzioni; a video con la build dell'ordine.** **CHIUSA.**
- **EA.08**, il menu' della chat e' compatto, come quelli dei chatbot.
  **Fatto**: voci alte 44 punti, icona e titolo su una riga, la data a
  destra, divisori da 9 punti. Prova in `test/chat_initial_message_test.dart`.
  Commit `72700674`. **Prodotto e agganciato; a video con la build
  dell'ordine.** **CHIUSA.**
- **EA.09**, i due contatori in cima alla chat piu' vicini.
  **Fatto**: `RigaDelResiduo(stretta: true)` in cima alla chat, senza
  margine e con l'interlinea a 1,15 (`riga_del_residuo.dart`). Prova in
  `test/chat_initial_message_test.dart`: fra le due righe nessuna aria.
  Commit `72700674`. **Prodotto e agganciato; a video con la build
  dell'ordine.** **CHIUSA.**
- **EA.10**, il login con Google dal menu' utente riesce al primo tentativo.
  **APERTA**
- **EA.11**, la scelta dell'account Google si fa una volta sola, in ogni
  punto di accesso.
  **APERTA**
- **EA.12**, il conteggio e' sempre attivo, anonimo e senza selettore; la
  privacy policy lo descrive.
  **APERTA**
- **EA.13**, i dati dopo il login: cio' che Mauro ha visto e' il
  comportamento previsto, o si ripara.
  **APERTA**
- **EA.14**, registrazione e login su iPhone con Google, Apple ed email.
  **APERTA**
- **EA.15**, il cancello di Codemagic aspetta il limite di GitHub e riprova
  da solo, senza token nuovi.
  **Fatto**: in `tool/il_cancello_ha_detto_verde.sh` il rifiuto per limite
  (lo dice il messaggio, *"rate limit"*, o lo dicono le intestazioni, zero
  domande rimaste) non consuma piu' i tre tentativi. Il cancello legge la
  riapertura da `retry-after`, altrimenti da `x-ratelimit-reset`, stampa
  che sta aspettando il limite, quanti secondi e l'ora UTC in cui riprova, e
  riprova. **Il tetto**, `ATTESA_MASSIMA_DEL_LIMITE` a 1500 secondi, perche'
  la build ha sessanta minuti in tutto: se la riapertura cade oltre, si
  ferma subito e dice a che ora rilanciare. Le altre fermate (ramo, rosso,
  in corso, mai partito, illeggibile tre volte) sono identiche. Nessun token:
  niente CODEMAGIC3, niente `GITHUB_TOKEN_CANCELLO`, e la guardia lo
  pretende. Provato contro GitHub vero sul commit `007b360f`: verde.
  Guardia `test/il_cancello_aspetta_il_limite_test.dart`, vista rossa sul
  cancello di prima e con un token innestato; `ordine_codemagic2_guard`
  vista rossa prima di toccare (Regola B) e verde dopo. **Prodotto e
  agganciato; sul Mac di Codemagic si vedra' alla prima build che trova il
  limite.** **CHIUSA.**
- **EA.16**, la bolla della carta di nascita nel Passport ha solo il primo
  paragrafo; l'icona delle fonti va nella schermata della carta.
  **Fatto**: in `cosmic_passport_screen.dart` la bolla porta etichetta,
  numero e nome e la prima frase (`primaFraseDellaCarta`), che a video e' il
  primo paragrafo perche' il testo si divide frase per frase; la riga del
  valore d'esempio esce con il resto. La porta delle fonti passa nella carta
  aperta, sotto il testo (`mostraLaCartaIngrandita(inFondo:)` in
  `carta_ingrandita.dart`). Prove in `test/passport_test.dart` e
  `test/la_carta_di_nascita_si_vede_test.dart`. **Prodotto e agganciato; a
  video con la build dell'ordine.** **CHIUSA.**
- **EA.17**, il menu' utente viola su sfondo cosmico, in tutte le sue
  schermate.
  **Fatto**: un vestito solo, `VestitoDelMenuUtente`
  (`lib/features/account/vestito_del_menu_utente.dart`), che da' la
  tavolozza neutra del Cerchio, cioe' la viola, e il cosmo dietro. Le bolle
  del menu' sono viola pieno (`VestitoDelMenuUtente.bolla`,
  `account_screen.dart:1275`), il cerchietto dell'icona un tono sotto
  (riga 1285): prima erano il colore del Cerchio a meta' trasparenza sul
  nero, blu notte a video.

  **Il censimento delle schermate che si aprono dal menu' utente:**

  | schermata | si apre da | rotta vestita | prima |
  |---|---|---|---|
  | Il tuo account | la barra dell'identita' | `account_screen.dart:55` | nero pieno, bolle blu notte |
  | Profilo | `account_screen.dart:68` | `profile_screen.dart:27` | nero pieno |
  | Dati di nascita | `account_screen.dart:81` | `dati_di_nascita_screen.dart:51`, solo il colore | cosmo proprio, tavolozza blu di Medora |
  | Notifiche | `account_screen.dart:302` | `notifiche_screen.dart:53`, solo il colore | cosmo proprio, tavolozza del Maestro attivo |
  | Impostazioni | `account_screen.dart:310` | `settings_screen.dart:37`, solo il colore | cosmo proprio, tavolozza del Maestro attivo |
  | Privacy e dati | `account_screen.dart:342` | `account_screen.dart:1366` | nero pieno |
  | Informativa sulla privacy | `account_screen.dart:1377` | `privacy_policy_screen.dart:22` | fondo trasparente sul nero della rotta |
  | Privacy e permessi | `account_screen.dart:1405` | `privacy_e_permessi_screen.dart:45` | `palette.deepest` pieno |

  *Solo il colore* vuol dire che la schermata il cosmo lo disegnava gia': il
  vestito le da' la tavolozza viola e non un secondo cielo.
  **Fuori dal perimetro, dichiarato**: *I piani* (`account_screen.dart:258`)
  e *Il Cosmic Journal* (riga 294) sono schermate di altre arti con un
  vestito loro; *Invita un amico* e le voci dell'accesso aprono fogli e
  dialoghi, che hanno la superficie della porta comune dei fogli. Guardia
  `test/il_menu_utente_e_viola_su_cosmo_test.dart`, vista rossa con tre
  innesti. **Prodotto e agganciato; a video con la build dell'ordine.**
  **CHIUSA.**
- **EA.18**, privacy policy, condizioni d'uso e disclaimer in una sola
  pagina.
  **APERTA**
- **EA.19**, la registrazione con email con un link senza password, e App
  Check.
  **APERTA**
- **EA.20**, il Soffio del Destino col microfono torna a funzionare; oggi
  va solo il gesto col dito. Aggiunta dal fondatore il 19 settembre 2026
  mentre l'ordine era in corso: *"nel soffio del destino, il soffio con
  microfono non funziona piu'. funziona solo il gesto col dito"*.
  **Il microfono si accende davvero**, verificato sul Realme con l'app
  aperta sul Soffio: `dumpsys audio` dichiara una sessione viva, sorgente
  MIC, un canale a 16 kHz, non silenziata. Il flusso arriva, ed era il
  riconoscimento a scartarlo.
  **La causa, e ha un padre**: ordine DD voce 01, 10 settembre 2026, che ha
  sostituito la soglia di volume con la planarita' spettrale. La soglia,
  0,20, era tarata su un campione sintetico solo, rumore rosa. Un fiato vero
  su un telefono e' vento, cioe' rumore con quasi tutta l'energia in basso:
  misurato, planarita' **0,003**. Anche il rumore rosa della guardia, con un
  altro seme, scendeva sotto la soglia in qualche finestra e spezzava la
  catena delle sei.
  **Fatto**: la planarita' si misura dopo la **pre-enfasi**, la differenza fra
  un campione e il precedente, che e' il passo di scuola per raddrizzare uno
  spettro inclinato. Misurato dopo: rumore bianco 0,29, rosa 0,49, vento
  0,53, voce 0,050, musica 0,000; la soglia sta a **0,15**. La doppia
  pre-enfasi e' stata provata e scartata, perche' rende piatta anche la voce.
  Le aperture false restano **zero su tre**. Guardia
  `il_soffio_si_riconosce_dalla_forma`, con due campioni nuovi (il vento e lo
  stesso fiato con un altro seme), vista rossa con la misura di prima.
  **Prodotto e agganciato; il riconoscimento vero si vede col fiato sul
  telefono, e lo prova il fondatore con la build.** **CHIUSA.**
- **EA.21**, il foglio degli Eos e dell'abbonamento aperto da *Chiedi anche
  agli altri* sta sotto la barra in basso e non si tocca. Aggiunta dal
  fondatore il 19 settembre 2026 mentre l'ordine era in corso: *"il banner
  resta sotto la barra di navigazione inferiore e non posso selezionare
  nulla"*.
  **La causa, misurata sulla cattura**: il foglio non era spinto sotto la
  barra, era TAGLIATO. `showUpgradeInvite` apriva un foglio che non puo'
  crescere, e Flutter gli da' per tetto 9/16 dell'altezza sotto le barre in
  alto; col titolo su due righe e il riscatto su tre il contenuto superava il
  tetto, e il fondo, cioe' *Non ora* e *Vedi i piani*, finiva dove disegna
  la barra. Il bordo alto del foglio nella cattura cade proprio a quel tetto.
  **Padre**: ordine BG voce 05, che ha aggiunto la riga del riscatto a un
  foglio che non poteva crescere; col titolo lungo del confronto il conto
  supera il tetto.
  **Fatto**: in `lib/features/pricing/upgrade_invite.dart` il foglio e'
  `isScrollControlled` e il contenuto scorre se non ci sta. Vale per tutti
  gli otto punti dell'app che aprono l'invito, perche' passano tutti da li'.
  Prova `test/l_invito_degli_eos_si_tocca_intero_test.dart`, rossa sul
  codice della 2272 (il contenuto sforava di 216 e 105 punti, *Vedi i piani*
  sotto la barra) e verde dopo, con il testo a 1,3 su 360x740 e 390x844.
  **Prodotto e agganciato; a video con la build dell'ordine.** **CHIUSA.**
