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
| S24 | Cancellare l'account | **Promette piu' di cio' che fa**: dice "spariscono la tua carta natale, la memoria dei Maestri, i tuoi Sigilli e i tuoi Eos, qui e sul server", ed esegue solo `memory.deleteAllData()`, che cancella la memoria dei Maestri. L'utente di Firebase resta, il cammino sul Cerchio resta, le preferenze locali restano | AZ.08 |
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

- **AZ.00** Manifesto e censimento. Stato: APERTA
- **AZ.01** Chi entra arriva in home, e se non arriva lo sa. Stato: APERTA
- **AZ.02** Il rito non si decide su una preferenza locale. Stato: APERTA
- **AZ.03** Il borsellino si aggiorna quando cambia, non al riavvio. Stato: APERTA
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

## I marcatori

VOCI_TOTALI: 15
VOCI_APERTE: 15
VOCI_CHIUSE: 0
SITUAZIONI_CENSITE: 37
VOCI_FERMATE_SU_PREMESSA_FALSA: 0
VOCI_FERMATE_SU_DECISIONE_DEL_FONDATORE: 0
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0
