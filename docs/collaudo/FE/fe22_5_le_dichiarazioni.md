# FE.22.5, le tre dichiarazioni con file e riga

Verificate con `git show <commit>:<percorso>`. PRIMA = `ab61ca83` (prima del Diario sul telefono), DOPO = `bd64f246`.

## 1. Cosa faceva "Custodisci", poi "Segna nel Diario"

### PRIMA (`ab61ca83`)

- **Il pulsante.** È l'`OutlinedButton.icon` con chiave `responso_custodisci` in `AzioniDelResponso`.
  - Riferimento: `lib/features/ricordi/azioni_del_responso.dart:357-375`.
  - Chiama `onPressed: _custodito ? null : _custodisci` (:368).
  - L'etichetta era già "Segna nel Diario" (:374, FE.22.3).
- **`_custodisci`** (:261-277) chiama `_tieni(ComeENato.gesto)` (:262).
- **`_tieni` scriveva due volte** (:212-242):
  - `ScrignoDeiCustoditi.custodisci(ricordo)` (:216-217);
  - poi `RegistroDeiRicordi.segna(VoceDelRicordo(... tipo: responso))` (:226, :229-237).
- **`ScrignoDeiCustoditi.custodisci`** (`lib/core/ricordi/scrigno_dei_custoditi.dart:140-147`):
  - sul telefono salvava in SharedPreferences, chiave `ricordi.custoditi` (:68, :178-182);
  - verso il server chiamava `custodisciIlResponso` (`lib/services/ricordi/porta_vera_dello_scrigno.dart:29-32`);
  - lato server la funzione è `functions/src/ricordi.ts:229` e scrive `users/{uid}/custoditi/{chiave}` (:215).
- **La condivisione avvenuta custodiva da sola**: `_condividi` chiamava `_tieni(ComeENato.condivisione)` (`azioni_del_responso.dart:252-253`).

### DOPO (`bd64f246`)

- **Lo scrigno è cancellato.** I due file non esistono più.
- **Il pulsante**, stessa chiave, chiama `_segna` (`azioni_del_responso.dart:375`).
- **`_segna`** (:249-272) mette e toglie la stella con `RegistroDeiRicordi.mettiLaStella`:
  - riferimento: `lib/core/ricordi/registro_dei_ricordi.dart:515-532`;
  - verso il server chiama `stellaNelDiario` (`lib/services/ricordi/porta_vera_dei_ricordi.dart:151-156`; server `functions/src/diario.ts:312`).
- **Il responso entra nel Diario da sé**, appena si mostra (FE.22.6):
  - `_annota` (`azioni_del_responso.dart:187`, :201-217) chiama `annotaIlResponso` (`registro_dei_ricordi.dart:537-570`);
  - verso il server chiama `annotaNelDiario` (`functions/src/diario.ts:274`).
- **Condividere non segna più niente** (`azioni_del_responso.dart:274-284`).

## 2. "Il Cammino" e "I Ricordi"

- **La schermata.** `enum VistaDelJournal { cammino, ricordi }`: `lib/features/ricordi/ricordi_screen.dart:57` (PRIMA), :56 (DOPO).
- **"Il Cammino"**, uguale PRIMA e DOPO:
  - è `_IlCammino` (PRIMA `ricordi_screen.dart:217-247`), un elenco statico dei sentieri (`Sentieri.tutti`, `lib/core/sigilli/sentieri.dart:17`);
  - i dati della persona li legge `SentieroScreen` da `DiarioDelCammino` (`lib/features/sigilli/sentiero_screen.dart:143`, :196);
  - non legge il registro dei Ricordi.
- **"I Ricordi", PRIMA:**
  - la fonte era `RegistroDeiRicordi.tutte`, cioè le chiavi `ricordi.voci.AAAA-MM` in SharedPreferences del telefono (`registro_dei_ricordi.dart:123`, :167-195);
  - le scrivevano due chiamanti: i responsi custoditi (`azioni_del_responso.dart:230`) e la chat a ogni domanda (`maestro_chat_screen.dart:142`, callback `segnaNeiRicordi`);
  - la pastiglia delle carte leggeva l'altro magazzino, `ScrignoDeiCustoditi.tutti` (`ricordi_screen.dart:987-988`).
- **"I Ricordi", DOPO:**
  - `registro.apri()` fa due letture (`registro_dei_ricordi.dart:422-427`);
  - legge `users/{uid}/diario/{AAAA}` e `.../mesi/{MM}` (`porta_vera_dei_ricordi.dart:76-114`);
  - questi documenti li scrive il server:
    - `annotaLaConversazione` insieme al messaggio (`functions/src/diario.ts:193-216`, da `functions/src/cerchio.ts:1012`);
    - `annotaNelDiario` (:274), `stellaNelDiario` (:312);
    - `riempiIlDiario` (:388) per le voci di prima.

## 3. Perché le conversazioni di settembre con Medora mancavano dal Diario

1. **Il menu della chat leggeva il server.**
   - `_caricaLePassate` → `recentMessages(limit: 150)` → `LeConversazioniPassate.raccogli`.
   - Riferimenti: `maestro_chat_controller.dart:524-540`; `firestore_maestro_memory_repository.dart:278-290`.
2. **Il Diario leggeva solo il telefono** (`registro_dei_ricordi.dart:123`, :183-187).
   - Una conversazione entrava solo con `segnaNeiRicordi`, solo sul telefono dove si chattava.
   - `ripesca` non aveva chiamanti: un mese non si rileggeva mai dal server.
3. **Per tutto settembre le righe non salivano al server.**
   - `sincronizza` non ha avuto chiamanti fino a EV.58, commit `b2263a0f` del 1° ottobre (lo dice il commento a :317-319).
   - EV.58 l'ha collegata a `riprendiDalCerchio` (:323-348). Quella rilettura parte una volta sola per installazione, per la chiave `ricordi.ripresiDalCerchio` (`lib/core/cammino/custode_del_cammino.dart:449`, :454).
4. **Il risultato.** Una conversazione fatta su un'altra installazione, o prima di una reinstallazione, stava nei messaggi sul server, e quindi nel menu, ma non nel Diario.
   - Nessun meccanismo ricostruiva le righe del Diario dai messaggi.
   - Lo fa adesso `riempiIlDiario` (`functions/src/diario.ts:388-398`).
5. **Due ipotesi escluse.**
   - La potatura dei mesi non c'entra: tiene 12 mesi e non pota i mesi non saliti (`registro_dei_ricordi.dart:226-237`).
   - CI.06, che ha fatto nascere `segnaNeiRicordi` il 1° settembre (commit `4333c23a`), precede il 26, 28 e 29.

**Non verificabile dal codice:**

- su quale installazione sono state fatte quelle conversazioni;
- se e quando c'è stata una reinstallazione.

C'è un solo indizio, ed è un commento: `custode_del_cammino.dart:542-543` (PRIMA) parla di un'app reinstallata dal fondatore.
