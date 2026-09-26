# ORDINE EA, LE CORREZIONI DOPO LA 2272: CHAT, TUTORIAL, ACCESSO, RUNE, PASSPORT, MENU' UTENTE, PAGINA LEGALE E CANCELLO

**Sigla:** EA, la prima libera dopo DZ: verificato sul ramo, in `docs/ordini`
non c'e' nessun `ORDINE_EA_*`. **Data:** 19 settembre 2026. **Ramo:**
`claude/esoteric-circle-master-order-e798aj`. Parte dal commit `007b360f`
(build 2272).

**Decisioni del fondatore del 19 settembre 2026, prese all'avvio**: i tre
lotti di fila e poi una sola build; la Ronda dei motori legge i rossi
accettati come lo sbarramento, e i due rossi voluti restano dichiarati.

VOCI_TOTALI: 22
VOCI_CHIUSE: 21
VOCI_APERTE: 0
VOCI_FERMATE_IN_ATTESA_DELLE_MANI_DEL_FONDATORE: 1

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
  **RIPRODOTTO SUL REALME, 20 settembre 2026**, e non dedotto: col telefono
  anonimo, *Il tuo account* > *Custodisci il tuo cielo* > *Continua con
  Google* apre il selettore, e il primo tentativo **non entra**: a video
  compare *"Quell'identita' vive gia' in un altro Cerchio. Puoi entrarci qui
  sotto, oppure provare con un'altra via"*, col pulsante *Continua come
  maobatta@gmail...*. Il registro del telefono non stampa il codice, ma la
  frase e' quella di `EsitoDellaCustodia.giaDiUnAltroCerchio`, cioe'
  `credential-already-in-use`: e' giusto, perche' quell'identita' e' davvero
  gia' di un altro Cerchio.
  **Fatto**: adesso quel secondo tocco entra **senza riaprire il selettore**
  (vedi EA.11), quindi la registrazione si compie con una scelta
  dell'account sola.
  **UNA COSA NON L'HO TOLTA, e la dichiaro**: il tocco di conferma
  *"Continua come"* resta. Entrare in quel Cerchio **sostituisce Eos e
  ricordi di questo telefono**, e il foglio lo dice prima di farlo: togliere
  quella conferma per risparmiare un tocco vorrebbe dire cambiare i dati di
  qualcuno senza dirglielo. Se il fondatore vuole l'ingresso automatico, e'
  una riga, e va deciso da lui.
  **Prodotto e agganciato; a video con la build dell'ordine.** **CHIUSA.**
- **EA.11**, la scelta dell'account Google si fa una volta sola, in ogni
  punto di accesso.
  **La causa, misurata.** Il *"Continua come"* rifaceva tutta la strada:
  dimenticava il client di Google e chiedeva una credenziale nuova, quindi
  **il selettore si riapriva**. Quella scelta era stata presa con l'ordine AX
  voce 01 per un motivo vero, cioe' che il gettone gia' speso da noi non
  entra piu'; la credenziale che Firebase mette **dentro l'errore** pero' non
  e' quella spesa, e con quella si entra.
  **Fatto**: `IdentitaRiconosciuta` dichiara se la credenziale viene dal
  rifiuto (`dallErrore`), e `entraComeRiconosciuto` la prova per prima. **La
  strada di prima resta come rete**: se quella credenziale non entra, il giro
  si rifa' come faceva. Misurato al banco: selettore aperto **una volta**
  contro le due di prima, e due quando la rete deve intervenire.
  **I punti di accesso censiti**, che passano tutti da qui: il Risveglio
  (`custodia_del_cielo_step.dart`), la registrazione dopo l'onboarding e il
  menu' utente (`account_screen.dart`), piu' il rientro con email gia'
  registrata (`custodia_del_cielo.dart`). Nessuno di loro chiama il flusso di
  Google da se': l'unica chiamata a `signIn()` sta in
  `account_del_cerchio.dart`, dentro la porta.
  Guardia `test/il_selettore_di_google_si_apre_una_volta_test.dart`, vista
  rossa togliendo il ramo nuovo. **Prodotto e agganciato; a video con la
  build dell'ordine.** **CHIUSA.**
- **EA.12**, il conteggio e' sempre attivo, anonimo e senza selettore; la
  privacy policy lo descrive.

  **COSA RACCOGLIEVA IL CONTEGGIO PRIMA DI QUEST'ORDINE.**

  | cosa | dove | c'era un identificativo? |
  |---|---|---|
  | cinque nomi di evento, elenco chiuso | `lib/core/misura/misura_del_ritorno.dart:34-59` | no |
  | una parola di contesto da elenco chiuso (nome del rito, del dono, canale della condivisione) | `porta_del_cerchio.dart:430-433`, tagliata a 40 caratteri in `functions/src/ritorno.ts:82-84` | no |
  | contatore per giorno **sotto l'utente**, `users/{uid}/ritorno/{giorno}` | `functions/src/ritorno.ts:90-92, 97` | **si', l'uid** |
  | contatore per giorno aggregato, `ritorno/{giorno}` | `functions/src/ritorno.ts:93, 98-101` | no |
  | la chiamata pretende un account, anche anonimo | `functions/src/ritorno.ts:68-74` | l'uid serve a entrare |
  | l'indirizzo IP | non lo scrive nessuna riga del Cerchio; compare nei registri tecnici del fornitore, come in ogni collegamento a internet | fuori dai conti |

  **Lo scarto era uno**, ed e' riparato: il documento sotto l'utente. Adesso
  si scrive **solo** `ritorno/{giorno}`
  (`functions/src/ritorno.ts`), e l'uid non finisce in nessun documento e in
  nessun registro del Cerchio. La chiamata continua a pretendere un account,
  anche anonimo, perche' senza quel cancello la porta sarebbe aperta al mondo
  e chiunque potrebbe gonfiare i contatori dall'esterno: l'uid serve a
  entrare e non viene scritto.

  **Fatto sul telefono**: la riga *"Conta i gesti, non me"* e il suo
  interruttore sono usciti dalla registrazione
  (`consensi_della_registrazione.dart`); l'interruttore *"Conta i gesti, non
  te"* e' uscito da Privacy e permessi, dove resta il racconto di cosa si
  conta (`privacy_e_permessi_screen.dart`, chiave `cosa_contiamo`); i due
  file `interruttore_della_misura.dart` e `consenso_alla_misura.dart` sono
  stati cancellati, il secondo era gia' orfano; il consenso e' uscito dal
  codice (`misura_del_ritorno.dart`, `registro_del_ritorno.dart`) e con lui
  la chiave `permesso.misuraDelRitorno`. **Il conteggio adesso vale anche per
  chi non si registra**, e prima no.

  **La policy** descrive il conteggio nella sezione *La misura di come va
  l'app* (`lib/core/legal/privacy_policy.dart`) e dice cio' che accade
  davvero: numeri aggregati per giorno, anonimi, nessun identificativo,
  guardati solo dal titolare, non incrociati e non ceduti. **Due frasi
  dicevano il falso e sono riparate**: *"la risposta si cambia dalle
  Impostazioni"*, che era falsa da quando l'interruttore e' passato nel menu'
  utente (ordine CF voce 16), e *"I conti restano 24 mesi"*, che nessuna
  scadenza manteneva. Adesso la scadenza c'e': voce `ritorno` a 730 giorni in
  `functions/src/scadenze.ts`, eseguita dal giro di pulizia.

  Guardia `la_misura_del_ritorno`, vista rossa due volte. **Prodotto e
  agganciato; il lato server vale dopo che Mauro pubblica le funzioni.**
  **CHIUSA.**
- **EA.13**, i dati dopo il login: cio' che Mauro ha visto e' il
  comportamento previsto, o si ripara.

  **LA SEQUENZA, passo per passo, letta sul ramo.**

  | passo | cosa fa il codice | file |
  |---|---|---|
  | *Cancella i tuoi dati* | `azzeraIDatiDelCerchio` cancella a fondo `users/{uid}` e lascia vivo l'account | `functions/src/cerchio.ts` |
  | *Esci* | si esce verso un anonimo NUOVO, perche' l'app senza identita' non sta in piedi | `account_del_cerchio.dart` |
  | onboarding da anonimo | il nuovo anonimo riceve i suoi 20 Eos del giorno piu' 10 | `functions/src/cerchio.ts` |
  | login con lo stesso Google | si rientra nel Cerchio di prima, che e' stato svuotato: **zero eventi e zero ricordi sono il comportamento previsto**, perche' la cancellazione ha tolto i dati dal server e rientrare non li resuscita | |
  | i 250 Eos del benvenuto non tornano | e' l'antifrode voluto: la **lapide del benvenuto** ricorda che quel Cerchio il dono l'ha gia' avuto, e serve a impedire che ci si cancelli e si torni per incassarlo di nuovo | `functions/src/cerchio.ts` |

  **Quindi cio' che il fondatore ha visto e' il comportamento previsto**, e
  nasce dalla sua stessa cancellazione.

  **MA SUL RAMO C'ERA ANCHE UN DIFETTO VERO, e non e' quello.** Il registro
  della memoria (`FirestoreMaestroMemoryRepository`) nasce una volta sola
  all'avvio e si teneva **l'uid di allora**: chi entra nel proprio Cerchio
  DOPO l'avvio cambia identita', e la memoria continuava a leggere e a
  scrivere sotto quella anonima di prima. I propri turni non comparivano, e
  quelli nuovi finivano nel posto sbagliato, finche' l'app non veniva
  riavviata. **Padre: PROVENIENZA IGNOTA** per esteso, perche' l'uid e' nato
  fisso col repository e nessun ordine risulta averlo reso fisso.
  **Fatto**: il repository chiede **chi e' adesso** (`uidVivo`), e l'app
  gliela passa dalla porta dell'identita'; se la risposta e' nulla vale
  quella di partenza, perche' un nullo vuol dire *non lo so*, non *nessuno*.
  Guardia `test/la_memoria_segue_chi_entra_test.dart`, vista rossa tornando
  all'uid fisso. **Prodotto e agganciato; a video con la build dell'ordine.**
  **CHIUSA.**
- **EA.14**, registrazione e login su iPhone con Google, Apple ed email.
  **Non si puo' chiudere da qui, e non e' una scelta**: non c'e' nessun
  iPhone collegato a questa macchina e nessun simulatore parte. Il codice
  delle tre vie e' lo stesso per i due sistemi, e cio' che su iPhone si
  comporta diversamente e' dichiarato: Apple e' l'unica via che passa da
  `signInWithProvider` (`account_del_cerchio.dart`), il link d'ingresso porta
  il dominio nei diritti dell'app (`ios/Runner/Runner.entitlements`), e App
  Check userebbe App Attest. Le voci 10, 11, 12, 13 e 19 sono applicate al
  codice condiviso, quindi valgono anche li'. **La prova la fa il fondatore**
  con la build iOS di Codemagic, dopo i passi in console del rapporto.
  **FERMATA IN ATTESA DELLE MANI DEL FONDATORE.**
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

  **DOVE VIVEVANO I TRE TESTI.**

  | testo | dove stava | dove sta adesso |
  |---|---|---|
  | privacy policy | `lib/core/legal/privacy_policy.dart`, undici sezioni, montate da `privacy_policy_screen.dart` | prima parte della pagina unica, ancora `#privacy` |
  | condizioni d'uso | **non esistevano**: zero testo, zero schermata, e il codice lo dichiarava per iscritto (*"il Cerchio non ha termini di servizio"*, ordine CF) | `lib/core/legal/condizioni_uso.dart`, undici sezioni scritte per quest'ordine, ancora `#condizioni` |
  | disclaimer | `ArtCatalog.disclaimerCornice`, due frasi, stampate dentro Privacy e permessi | terza parte, ancora `#disclaimer`, **col testo delle arti e non una copia** |

  **Le condizioni d'uso le ho scritte io, per decisione del fondatore del 20
  settembre 2026**, e dentro il file c'e' scritto che vanno lette da lui o da
  un legale prima della pubblicazione: sono scritte per essere oneste e
  chiare, non sono un parere legale.

  **Dove vive la pagina unica.** I tre testi si compongono in
  `lib/core/legal/pagina_legale.dart` e li monta `PrivacyPolicyScreen`, che
  si apre sulla parte chiesta e tiene in cima le tre porte. **Sul web**, per
  l'indirizzo che Apple e Google chiedono nelle schede, la stessa pagina
  nasce dagli stessi dati in `hosting/index.html`, e Firebase Hosting la
  pubblica con gli indirizzi diretti `/privacy`, `/condizioni` e
  `/disclaimer` (`firebase.json`). **Non e' uno strumento in `tool/` e il
  perche' e' scritto**: `dart run` non compila questo progetto, il
  compilatore cade sulla trasformazione FFI di un plugin; la pagina nasce da
  una prova, con `AGGIORNA_PAGINA_LEGALE=1`, che e' anche la guardia.

  **I LINK, uno per uno.**

  | dove | file e riga | dove porta adesso |
  |---|---|---|
  | menu' utente, Privacy e dati, voce *Privacy policy* | `account_screen.dart:1377` | pagina unica, parte privacy |
  | foglio dei consensi, *"Continuando accetti la privacy policy"* | `consensi_della_registrazione.dart` | pagina unica, parte privacy |
  | foglio dei consensi, *condizioni d'uso* (**nuovo**) | `consensi_della_registrazione.dart` | pagina unica, parte condizioni |
  | foglio dei consensi, *Leggi il disclaimer* (**nuovo**) | `consensi_della_registrazione.dart` | pagina unica, parte disclaimer |
  | Privacy e permessi, *Leggi il disclaimer per esteso* (**nuovo**) | `privacy_e_permessi_screen.dart` | pagina unica, parte disclaimer |

  **Il disclaimer all'ingresso, come vuole CLAUDE.md.** Non si mostrava piu'
  da nessuna parte: adesso si dice **alla fine del Risveglio**, nell'ultimo
  passo del Sigillo (`sigillo_step.dart`, chiave `risveglio_disclaimer`), e
  **nel foglio della registrazione**, col rimando alla sua sezione. Mai su
  ogni carta: i file che lo nominano sono cinque, e la guardia li conta.

  Guardie `test/i_tre_testi_in_una_pagina_test.dart` e
  `test/la_pagina_legale_sul_web_test.dart`, viste rosse con tre innesti.
  **Prodotto e agganciato; la pagina web e' scritta e va pubblicata da Mauro
  (passo per passo nel rapporto); a video con la build dell'ordine.**
  **CHIUSA.**
- **EA.19**, la registrazione con email con un link senza password, e App
  Check.

  **LO STATO DI PARTENZA, letto sul ramo.** La via dell'email chiedeva
  **indirizzo e parola** (`custodia_del_cielo.dart`, il foglio
  `_FoglioDellEmail`), collegava l'identita' con
  `linkWithCredential(EmailAuthProvider.credential(...))`
  (`account_del_cerchio.dart`) e mandava subito la verifica dell'indirizzo;
  chi dimenticava la parola passava da *parola persa*
  (`sendPasswordResetEmail`). **Di link d'ingresso non c'era niente**: zero
  `sendSignInLinkToEmail`, zero `isSignInWithEmailLink`, nessun filtro per i
  link nel manifesto di Android, nessun dominio dichiarato su iPhone.

  **Fatto, e la parola non si inventa piu'.** Si scrive l'indirizzo, arriva
  un messaggio, si tocca il link e si e' dentro:
  `mandaIlLinkDIngresso`, `eUnLinkDIngresso` ed `entraColLink` nella porta
  dell'identita'; le impostazioni del link in un punto solo
  (`lib/core/identity/link_di_ingresso.dart`), con il ritorno su
  `https://esotericircle.app/entra`; l'indirizzo a cui il link e' stato
  mandato resta sul telefono sotto la chiave `ingresso.`, che la
  cancellazione dei dati porta via; il link in arrivo lo raccoglie
  `lib/services/link_in_arrivo.dart` e lo usa `app.dart`, **in tutti e due i
  momenti**, cioe' sia quando il link apre l'app sia quando arriva mentre
  l'app e' viva.
  **Chi entra da anonimo non perde niente**: l'identita' si ATTACCA al
  Cerchio di questo telefono, e solo se quell'indirizzo ha gia' un Cerchio
  suo si entra in quello.
  **Android e iPhone dichiarano il dominio**: filtro `autoVerify` per
  `https://esotericircle.app/entra` nel manifesto, `applinks:` nei diritti di
  iPhone.
  **Il foglio con la parola e' uscito**, e con lui la via per la parola persa
  *che stava dentro quel foglio* (`custodia_parola_campo`,
  `custodia_occhiolino`, `custodia_parola_persa`): dove nessuna parola si
  inventa piu', non c'e' niente da recuperare. Chi una parola ce l'ha gia'
  entra lo stesso col link, perche' il link vale per l'indirizzo e non per il
  modo in cui quel Cerchio era nato.
  **MA LA PORTA DI CHI TORNA LA PAROLA LA CHIEDE ANCORA, ed e' giusto cosi'.**
  Quando la sonda scopre che quell'indirizzo ha gia' un Cerchio nato con una
  parola, mostra il suo campo (`sonda_parola_campo`), il suo occhiolino
  (`sonda_occhiolino`) e la sua via per la parola persa
  (`sonda_parola_persa`), che continua a passare da `sendPasswordResetEmail`.
  **Questo capoverso corregge quello che c'era scritto prima**, cioe' che la
  parola persa fosse uscita del tutto: era vero per il foglio della
  registrazione, non per la porta di chi torna, e la prova
  `la_porta_sonda_e_la_password` adesso misura tutte e due le meta'.

  **APP CHECK: c'e', e resta spento in release per una ragione datata.**
  `lib/services/firebase/attestazione.dart` lo installa fuori dalla release e
  lo tiene spento in release **dal 2 agosto 2026**, perche' le build arrivano
  da App Distribution e Play Integrity non attesta un'app installata fuori
  dal Play Store: accenderlo oggi fermerebbe ogni chiamata **delle build di
  prova del fondatore**. L'interruttore e' uno solo,
  `Attestazione.installaSempre`, e si gira il giorno in cui l'app sta su una
  traccia di test interno del Play Store. **Sul server l'imposizione e'
  spenta** (`enforceAppCheck: false`), e si accende dopo, quando i telefoni
  mandano il gettone: accenderla prima chiuderebbe fuori tutti.

  **COSA SERVE DA MAURO, nella console, passo per passo.** Sta nel rapporto
  `docs/ordini/RAPPORTO_ORDINE_EA.md`, sezione *I passi di Mauro*.

  Guardia `test/il_link_entra_senza_parola_test.dart`, vista rossa con tre
  innesti; `il_foglio_dell_email_dice_cosa_non_va` riscritta sulla legge
  nuova e rimasta a guardia della stessa cosa di sempre, cioe' che il foglio
  parli. **Prodotto e agganciato; il viaggio vero del link si vede solo dopo
  i passi in console, e lo prova il fondatore con la build.** **CHIUSA.**
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
- **EA.22**, la pietra di Ingwaz portava il segno di Othala. Aggiunta dal
  fondatore il 20 settembre 2026 mentre l'ordine era in corso, dalla
  segnalazione di un fondatore: *"quella nello screenshot e' la runa othala e
  non ingwaz"*, con la richiesta di un controllo su tutte le rune
  nell'Estrazione Rune e nella Runa del Tramonto.
  **Il censimento, fatto a occhio su tutte e ventiquattro le pietre**: il
  difetto era in una sola, `rune_bone_22_ingwaz_v1`, che portava il rombo con
  le gambe, cioe' Othala. Le altre ventitre sono giuste, comprese quelle che
  ho riguardato da vicino perche' somigliano ad altre (nauthiz, jera, eihwaz,
  perthro). **I dati erano in ordine**: nome, glifo e nome del file di tutte e
  ventiquattro coincidono e seguono l'ordine dell'Elder Futhark. Anche il
  ripiego a tratti (`rune_strokes.dart`) disegnava Ingwaz come rombo chiuso.
  **La Runa del Tramonto usa le stesse pietre** (`sunset_rune_screen.dart`
  monta `fullPath` e la miniatura), quindi mostrava lo stesso segno sbagliato:
  la correzione vale per tutte e due le arti.
  **Fatto**: `tool/ingwaz_non_e_othala.py`. La pietra non si rigenera col
  modello, perche' a parita' di seme un prompt diverso restituisce un altro
  sasso, e in una gettata a tre si vedrebbe. **Othala e' Ingwaz piu' due
  gambe**: si tiene l'incisione fino alla riga in cui il rombo si chiude,
  misurata e non decisa a occhio (la larghezza del solco cala fino a 139
  pixel, i due tratti si toccano, poi si riaprono fino a 300), e sotto
  tornano i pixel della pietra vergine della stessa runa, nata da questa
  immagine togliendole l'incisione. La miniatura nasce dalla pietra corretta.
  **Un primo tentativo e' stato buttato**: richiudere il solco col
  riempimento delle pietre vergini lasciava una chiazza piatta e chiara,
  perche' quel riempimento serve a solchi sottili, non a mezza pietra.
  **La guardia non misura la forma, e il perche' e' scritto dentro**: il
  confronto fra il solco inciso e il disegno a tratti, provato, dava dal 7 per
  cento di Uruz al 92 di Berkano su pietre tutte giuste, perche' i sassi sono
  fotografati storti; qualunque soglia li' dentro sarebbe stata scelta per far
  passare la prova. `test/ogni_pietra_porta_la_sua_runa_test.dart` tiene
  invece i nomi dei file legati al nome e al posto della runa, l'esistenza di
  arte e miniatura, e **l'impronta di ogni immagine** dopo la revisione a
  occhio; la tavola che l'occhio guarda sta in
  `docs/anteprime/rune_incise.png` e la genera `tool/tavola_delle_rune.py`.
  Vista rossa rimettendo al posto di Ingwaz la pietra di Othala.
  **Prodotto e agganciato; a video con la build dell'ordine.** **CHIUSA.**

---

## IL DIFETTO DELLA 2273, TROVATO GUARDANDO LO SCHERMO

Non e' una voce dell'ordine: e' un guasto che l'ordine stesso ha prodotto, e
che si ripara qui invece di rimandarlo a un ordine nuovo.

**Il fatto.** Consegnata la 2273 e aperta sul Realme 767f596c, toccato
*Preferisco un'email* e poi il campo: **appena la tastiera e' salita, i due
pulsanti si sono disegnati SOPRA il testo e sopra il campo**. *Mandami il
link* copriva l'indirizzo appena scritto. Ricontrollato tre minuti dopo, per
escludere che fosse un fotogramma di passaggio: c'era ancora.

**Padre: EA voce 19**, che ha scritto quel foglio con tre righe di
spiegazione sopra il campo, dove prima c'erano due campi e nessun discorso.

**La causa, misurata e non immaginata.** `AlertDialog` tiene titolo,
contenuto e pulsanti in tre scomparti, e quando lo spazio non basta **non li
accorcia in proporzione: il titolo e i pulsanti si servono per primi**. Al
banco, con i numeri del telefono, lo scomparto del contenuto risultava alto
**zero punti**, e il testo e il campo continuavano a disegnarsi fuori da lui.
Lo spazio e' poco perche' se lo prendono in tre: la barra dell'identita'
dichiara la sua altezza nel bordo di sopra, la barra del Cerchio in quello di
sotto, e la tastiera si prende 306 punti degli 800 dello schermo.

**LA PRIMA STESURA DELLA GUARDIA ERA VERDE SU UN DIFETTO CHE SI VEDEVA A
OCCHIO**, e vale piu' della cura. Girava a 390 per 844 punti, una finestra
comoda, e li' i rettangoli non si toccavano. E' diventata rossa solo dopo
aver pinnato i numeri letti sul telefono: `wm size` 1080x2400, `wm density`
480, quindi 360 per 800 punti, la tastiera a 306 da
`dumpsys window displays`, e i due bordi delle barre ricavati dai pixel della
cattura. **Una guardia che misura geometria vale quanto la finestra in cui
gira.**

**La cura.** Il foglio non e' piu' un `AlertDialog` a tre scomparti: e' un
`Dialog` con **una colonna sola dentro un solo scorrimento**. Nessuno si
serve per primo, e quando non ci sta tutto si scorre. I due pulsanti stanno
l'uno sotto l'altro a larghezza intera, come ovunque nell'app.

Guardia `test/il_foglio_del_link_regge_la_tastiera_test.dart`, **nata rossa
sul difetto vero**, non su un innesto: misura che il pulsante non tocchi il
campo, che il campo resti sopra la tastiera, **e che il pulsante si
raggiunga davvero scorrendo**, perche' un pulsante fuori dal foglio non
sarebbe una cura. **Riparato nella build 2274.**
