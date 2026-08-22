# ORDINE AZ, il manifesto

**L'ACCOUNT, TUTTO.** Sul ramo `claude/esoteric-circle-master-order-e798aj`.

**Nasce dal collaudo del fondatore sulla 2192** e dal suo mandato: *"Code deve
sistemare tutto ma proprio tutto quello che riguarda l'account prevedendo ogni
mossa volontaria o involontaria dell'utente."*

**Questo ordine e' scritto in un modo nuovo, e vale da qui in avanti.** Il
fondatore porta i FATTI MISURATI e il MANDATO. Cause, cure, ordine di lavoro e
misure di accettazione le decide chi sviluppa. Questo manifesto e' quindi il
posto dove quelle decisioni vengono scritte, e dove si risponde.

## Due premesse dell'ordine, e una e' falsa

**L'ordine AY non e' mai arrivato.** L'ordine AZ dice "L'ordine AY, consegnato
poco fa, e' SUPERATO da questo. Cosa salvarne e cosa buttare lo decidi tu."
**Non c'e' niente da salvare perche' non c'e' niente**: nessun ordine AY e'
stato ricevuto, `docs/ordini/` non contiene un `ORDINE_AY_MANIFESTO.md`, e
nessun file di `docs/`, `lib/` o `test/` nomina un ordine AY. Verificato con
`ls docs/ordini/` e `grep -rln "ordine AY" docs/ lib/ test/`.

**Il fatto F7 e' esatto**, riverificato riga per riga prima di lavorarci:
`OnboardingController.load()` decide su `prefs.getBool('onboarding.done')` e su
nient'altro. La costante si chiama `_kDone` e vale esattamente quella stringa.

## Come si legge questo file

Ogni voce porta uno stato fra cinque: CHIUSA, APERTA, FERMATA SU PREMESSA
FALSA, FERMATA IN ATTESA DI DECISIONE, FERMATA SU DECISIONE DEL FONDATORE. In
fondo ci sono i marcatori, che la guardia `test/ordine_az_guard_test.dart`
conta sulle righe.

## IL CENSIMENTO, trentasette situazioni

**Il numero: 37 situazioni censite.** Enumerate, non campionate. Per ciascuna
c'e' cosa fa l'app OGGI, verificato sul codice del ramo e non a memoria, e la
voce di lavoro che la prende in carico. Dove la colonna dice "non esiste", vuol
dire che la ricerca sul codice ha dato zero occorrenze, ed e' scritto quale.

### A. Ingresso e registrazione

| # | Situazione | Cosa fa l'app oggi | Voce |
|---|---|---|---|
| S01 | Prima apertura, nessuna identita' | Entra un anonimo di Firebase, e funziona | nessuna |
| S02 | Custodire il cielo con Google | `linkWithCredential` sull'anonimo, funziona | nessuna |
| S03 | Custodire con Apple | `linkWithProvider`, mai provato su dispositivo | AZ.14 |
| S04 | Custodire con email e parola | `EmailAuthProvider` su `linkWithCredential` | AZ.10 |
| S05 | Rientrare con Google | Entra sul serio (AX.01), ma **dopo l'ingresso puo' non succedere niente e non dirlo** | AZ.01 |
| S06 | Rientrare con Apple | Come S05 | AZ.01 |
| S07 | Rientrare con email | Come S05 | AZ.01 |
| S08 | Identita' gia' di un altro Cerchio, in custodia | Lo dice, e offre di entrarci | nessuna |
| S09 | Account sbagliato scelto per errore | **Nessuna via di ritorno**: non si esce | AZ.07 |
| S10 | Reinstallare con lo stesso account | Il server riconosce (F10), ma **il rito si rifa' lo stesso** | AZ.02 |

### B. Piu' telefoni

| # | Situazione | Cosa fa l'app oggi | Voce |
|---|---|---|---|
| S11 | Cambio telefono | La fusione sul server difende: `functions/lib/cammino.js` riga 189, vince il server campo per campo | nessuna |
| S12 | Due telefoni insieme | Idem: la fusione prende il piu' alto dei contatori | nessuna |
| S13 | Due persone sullo stesso telefono | **Non previsto**: senza uscita, il secondo eredita il Cerchio del primo | AZ.07 |

### C. Parola d'accesso ed email

| # | Situazione | Cosa fa l'app oggi | Voce |
|---|---|---|---|
| S14 | Parola persa | **Non esiste**: zero `sendPasswordResetEmail` in tutto `lib/` | AZ.05 |
| S15 | Parola sbagliata | Mappata su `nonRiconosciuto`, e la frase e' giusta | nessuna |
| S16 | Email non registrata | Idem | nessuna |
| S17 | Email gia' registrata | Mappata su `giaDiUnAltroCerchio`, e offre di entrarci | nessuna |
| S18 | Verifica dell'email | **Non esiste**: zero `sendEmailVerification`, zero `emailVerified` | AZ.06 |
| S19 | Cambio email | **Non esiste**: zero `updateEmail`, zero `verifyBeforeUpdateEmail` | AZ.12 |
| S20 | Cambio parola | **Non esiste**: zero `updatePassword` | AZ.12 |
| S21 | Email malformata o parola debole | Il pulsante "Custodisci" **non fa niente e non dice niente**: `if (!a.contains('@') \|\| b.length < 6) return;` | AZ.10 |
| S22 | Riautenticazione per un'operazione delicata | **Non esiste**: zero `reauthenticate` | AZ.12 |

### D. Uscita e cancellazione

| # | Situazione | Cosa fa l'app oggi | Voce |
|---|---|---|---|
| S23 | Uscire dall'account | **Non esiste**: l'unico `signOut` di tutto `lib/` e' quello di Google dentro `dimentica()`, e non tocca Firebase | AZ.07 |
| S24 | Cancellare l'account | Sul server e' fatto per intero: la callable `cancellaIlCerchio` fa `recursiveDelete` del ramo e `deleteUser` dell'account. **Manca il "qui"**: nessuno svuota le preferenze locali, quindi restano `onboarding.done`, il diario e i dati di nascita. E il client **guarda solo `datiCancellati` e ignora `accountCancellato`**, che il server distingue apposta. Dopo l'oblio non si esce e non si riparte | AZ.08 |
| S25 | Cancellare i dati restando nel Cerchio | Esiste in Impostazioni, stessa chiamata | AZ.08 |
| S26 | Rinascita del cammino | Esiste e funziona, `RinascitaDelCammino.rinasci()` | nessuna |

### E. Interruzioni, cioe' le mosse involontarie

| # | Situazione | Cosa fa l'app oggi | Voce |
|---|---|---|---|
| S27 | Rete assente a meta' del riconoscimento | `sincronizza` torna nullo, **e non lo dice a nessuno** | AZ.01 |
| S28 | Server che risponde "non autenticato" | `_chiama` **rilancia** su `unauthenticated`, `permission-denied`, `invalid-argument`, `failed-precondition`, e nessuno lo cattura lungo la via del riconoscimento | AZ.01 |
| S29 | App chiusa a meta' di un'operazione | L'anonimo resta, il cammino locale resta, la fusione ripara al ritorno | nessuna |
| S30 | Due tentativi di ingresso insieme | Il pulsante si spegne mentre uno e' in corso, e si riaccende sempre (AX.01) | nessuna |
| S31 | Token scaduto mentre si e' dentro | Non gestito in modo esplicito | AZ.13 |

### F. Coerenza fra cio' che si vede e cio' che si e'

| # | Situazione | Cosa fa l'app oggi | Voce |
|---|---|---|---|
| S32 | Il rito si decide su una preferenza locale | F7 confermato: `prefs.getBool('onboarding.done')` e nient'altro | AZ.02 |
| S33 | Dati di nascita locali contro quelli del Cerchio | Il server vince nella fusione, ma **solo se la fusione avviene**: se `sincronizza` fallisce, `adotta` non gira e i dati locali restano (F6) | AZ.04 |
| S34 | Il borsellino si aggiorna solo all'avvio | Vero e gia' scritto nel codice: `lib/app.dart` sincronizza in `initState` e al ritorno in primo piano, e da nessun'altra parte | AZ.03 |
| S35 | La voce Account nelle Impostazioni e' spenta | Vero (F9), porta "Dietro il velo" | AZ.11 |
| S36 | Sapere con che account si e' entrati | **Non c'e' nessuna riga che lo dica**, in nessuna schermata | AZ.09 |
| S37 | Permessi negati e negati per sempre | Aperto nell'ordine AX, voci 10 e 12 | AZ.14 |

## Le voci

- **AZ.00** Manifesto e censimento. Stato: CHIUSA
- **AZ.01** Chi entra arriva in home, e se non arriva lo sa. Stato: CHIUSA
- **AZ.02** Il rito non si decide su una preferenza locale. Stato: CHIUSA
- **AZ.03** Il borsellino si aggiorna quando cambia, non al riavvio. Stato: CHIUSA
- **AZ.04** I dati di nascita: chi vince, e chi lo vede. Stato: APERTA
- **AZ.05** La parola persa. Stato: APERTA
- **AZ.06** La verifica dell'email. Stato: APERTA
- **AZ.07** Uscire dall'account. Stato: APERTA
- **AZ.08** Cancellare l'account per davvero. Stato: APERTA
- **AZ.09** Sapere chi si e'. Stato: APERTA
- **AZ.10** Il foglio dell'email che non dice niente. Stato: APERTA
- **AZ.11** La voce Account nelle Impostazioni. Stato: APERTA
- **AZ.12** Cambio email, cambio parola, e la riautenticazione. Stato: APERTA
- **AZ.13** Il token che scade mentre si e' dentro. Stato: APERTA
- **AZ.14** Cio' che questo ordine NON chiude, dichiarato. Stato: APERTA

## L'ordine di lavoro, deciso qui

Si lavora dal danno maggiore al minore, e dentro ogni voce prima la misura e
poi la cura.

1. **AZ.01**, perche' e' il fatto F1 e brucia la Demo esattamente come faceva
   AX.01: chi rientra tocca, non succede niente e nessuno gli dice perche'.
2. **AZ.02 e AZ.04**, perche' insieme spiegano F2, F3 e F6: il rito rifatto e i
   dati a caso che restano.
3. **AZ.03**, F5 e F8, segnalato quattro volte.
4. **AZ.07, AZ.08, AZ.09**, che sono i tre buchi grossi: non si esce, non si
   cancella davvero, non si sa chi si e'.
5. **AZ.05, AZ.06, AZ.10, AZ.12**, la parte email.
6. **AZ.11, AZ.13**, e infine **AZ.14**.

## Cosa si riapre e cosa si butta degli ordini precedenti

- **AX.13** (il menu' Account nelle Impostazioni) e' lo stesso lavoro di
  **AZ.11**: si chiude qui, e la riga di AX porta l'annotazione.
- **AX.02..AX.12, AX.14, AX.15** restano APERTE dove stanno. Non si buttano e
  non si riscrivono qui: sono lavoro di schermo, e questo ordine e' lavoro di
  account.
- **AX.01 resta CHIUSA.** La cura regge: chi rientra ENTRA davvero, ed e' il
  riconoscimento sul server (F10) a dimostrarlo. Cio' che F1 aggiunge succede
  **dopo** l'ingresso, ed e' AZ.01.
- **Il controller della parallasse non si tocca**, e questo ordine non lo
  sfiora in nessuna voce.

## Cosa e' stato fatto, voce per voce

### AZ.01, il rientro non muore in silenzio

**Il fatto F1, e la causa non era l'ingresso.** L'ingresso RIESCE, ed e' il
fatto F10 a dimostrarlo: il borsellino viene poi recuperato, quindi il server
ha riconosciuto. Cio' che si rompe viene DOPO, nel giro del Custode, e sono
**due strade diverse che finiscono nello stesso silenzio**.

**Strada uno, l'eccezione che nessuno cattura.** `PortaVeraDelCerchio._chiama`
**rilancia apposta** su `unauthenticated`, `permission-denied`,
`invalid-argument` e `failed-precondition`, per distinguere un no del server da
una rete assente. Ma `custodisciEAdotta` chiamava `borsa.sincronizza(...)`
**fuori da qualsiasi try**: quell'eccezione risaliva fino al gestore del tocco
e moriva li'. Nessun messaggio, e il tocco dopo faceva la stessa cosa. **E' il
"si puo' ripetere all'infinito con lo stesso esito" del fondatore.**

**Strada due, il nulla che valeva come risposta.** Se il server non rispondeva,
`sincronizza` tornava nullo, il giro tornava nullo, e `Ritrovamento.da(null)`
diceva che mancano tutti e quattro i passi del rito e che **non c'e' niente da
mostrare**: nessuna scena, nessun messaggio, e si resta dentro il rito.

**La causa di fondo era un nulla che voleva dire tre cose.** Il giro rispondeva
`null` quando non c'era un borsellino, quando il server non aveva risposto e
quando il server aveva detto di no. **Chi chiamava non poteva dire niente alla
persona proprio perche' non sapeva cosa fosse successo.** E i chiamanti sono
tre: il Risveglio, il passo della custodia e l'area account. Tacevano tutti e
tre.

**La cura.** Nasce `EsitoDelGiro`, che porta il motivo invece di un nulla muto;
il no del server viene catturato e registrato fra i guasti; `Ritrovamento`
guadagna `rifiutatoDalServer` e `senzaRisposta`, e la frase da dire vive **in
un punto solo** perche' uno dei tre chiamanti si dimenticherebbe. E l'avviso
porta un **Riprova**: senza, l'unica strada che resta a chi e' entrato e non ha
ritrovato niente e' rifare il rito da capo, **ed e' esattamente cio' che il
fondatore ha fatto ai punti F2 e F3**. I dati a caso di F6 nascono li'.

**Le misure**, in `test/il_rientro_non_muore_in_silenzio_test.dart`:
- col server che dice `unauthenticated`, **eccezioni scappate dal giro: prima
  una, adesso zero**, e l'esito dice `rifiutatoDalServer`;
- col server che non risponde, l'esito dice `senzaRisposta` e **non** dice
  rifiutato: le due cose restano distinte;
- **cio' che la persona legge**, che prima era niente in tutti e due i casi:
  "Sei entrato, ma il Cerchio non ha voluto aprirsi adesso..." e "Sei entrato,
  ma non siamo riusciti a raggiungere il Cerchio...", senza nessun codice
  tecnico, con il pulsante Riprova accanto;
- **la controprova**: col Cerchio che riconosce, passi da chiedere **0**, il
  rito si salta, e **avvisi a schermo 0**. Un avviso che si accende sempre
  sarebbe peggio del silenzio.

**Sul dispositivo non e' misurata e si dichiara.** Il fondatore deve ripetere
la sua sequenza: disinstalla, reinstalla, tocca "Faccio gia' parte del
Cerchio", sceglie il suo account. **Se non arriva in home, adesso deve leggere
una frase**, e quella frase dice quale dei due casi e'.

### AZ.02, a chi torna il rientro non si nasconde

**Il fatto F7 e' esatto, e non e' il difetto.** Il rito si decide su
`prefs.getBool('onboarding.done')` e su nient'altro. Ma al primo avvio dopo
una reinstallazione **non esiste ancora nessuna identita' da interrogare**:
non c'e' nient'altro su cui decidere, e cambiare quella riga non avrebbe
curato niente. Si dichiara invece di correggerla in silenzio.

**Il difetto e' un altro, ed e' a due righe di distanza.** Quando il telefono
propone gia' un account, l'app SA che chi guarda e' con ogni probabilita' di
ritorno, e gli metteva davanti "Inizia il rito" tenendo il rientro in una riga
smorzata sotto. **Chi reinstalla prende la strada grande**, rifa' il rito, e
per finirlo inventa dei dati: sono F2 e F3, **e i dati a caso di F6 nascono
li'**.

**La cura**: col bentornato la porta per chi torna diventa un richiamo pieno.

**Le misure**, in `test/a_chi_torna_il_rientro_non_si_nasconde_test.dart`:
senza bentornato la porta e' un `TextButton` **senza nessun fondo dipinto**,
col bentornato e' un `FilledButton` con fondo pieno e opaco. **La controprova
c'e'**: a chi arriva davvero nuovo la porta resta smorzata, perche' offrirgli
un accesso col risalto del rito sarebbe l'errore opposto.

**Un criterio sbagliato, dichiarato.** La prima versione della prova
pretendeva una porta piu' larga, e cadeva: misurato, la colonna e' larga 256
punti in tutti e due i casi, perche' tanto la porta quanto la chiamata
principale chiedono `width: double.infinity`. **Cadeva con ragione**, e il
criterio sbagliato era quello della prova. Il risalto vero e' il fondo.

### AZ.03, il borsellino non aspetta il riavvio

**Il difetto era gia' scritto in un commento di `lib/app.dart`, e nessuno lo
aveva letto come un difetto**: "se la sincronia dell'avvio non riesce, perche'
la rete e' lenta nel primo secondo o perche' l'autenticazione non e' ancora
pronta, il saldo resta quello locale finche' l'app non viene riavviata: e' il
caso del fondatore, zero in barra con quattrocentoquarantacinque sul server."

**E il momento della chiamata e' proprio quello sbagliato.** Parte dopo il
primo fotogramma, cioe' quando Firebase puo' non avere ancora ripristinato la
sessione: il server risponde `unauthenticated`, e **non si riprova mai piu'**
fino al riavvio o al ritorno in primo piano. Ecco perche' sembrava che a
sistemare le cose fosse il Passport: era il tempo passato, non il Passport.

**La cura**: il giro si riprova, due volte, dopo due e cinque secondi, e solo
quando l'esito dice che vale la pena. Possibile **solo grazie ad AZ.01**, che
ha dato al giro un modo di dire perche' non ha portato niente.

**Le misure**, in `test/il_borsellino_non_aspetta_il_riavvio_test.dart`: col
primo giro che cade su `unauthenticated`, **saldo in barra 0**; al secondo
giro **445**, che e' il numero vero del fondatore. **La controprova**: col
Cerchio sveglio i tentativi restano **1**, perche' una ripetizione che parte
sempre sarebbe una chiamata in piu' a ogni avvio pagata da tutti per il caso
di uno.

## I marcatori

VOCI_TOTALI: 15
VOCI_APERTE: 11
VOCI_CHIUSE: 4
SITUAZIONI_CENSITE: 37
VOCI_FERMATE_SU_PREMESSA_FALSA: 0
VOCI_FERMATE_SU_DECISIONE_DEL_FONDATORE: 0
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0
