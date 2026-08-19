# ORDINE AP. IL CERCHIO TI RICONOSCE, E TI RESTITUISCE IL TUO CAMMINO

Nove voci, da AP.01 ad AP.09. Ramo `claude/esoteric-circle-master-order-e798aj`,
premesse verificate sulla testa `4336e1ee` il 19 agosto 2026.

## Come si legge questo file

Una riga per voce, con lo stato in fondo. Stati ammessi: APERTA, CHIUSA,
FERMATA SU PREMESSA FALSA, FERMATA IN ATTESA DI DECISIONE. Finche' una riga
e' APERTA la guardia `test/ordine_ap_guard_test.dart` resta rossa. Le voci
che si vedono o si provano sul telefono (AP.02, AP.04, AP.05, AP.06, AP.07) a
cura fatta e guardia verde vanno in FERMATA IN ATTESA DI DECISIONE: le chiude
il collaudo di Mauro sulla build di AP.09. Un commit per voce; prove mirate
durante le voci, prove del server con npm test, suite intera UNA volta ad
AP.09.

## Perche' quest'ordine esiste

Un fatto misurato da Mauro sul telefono vero, sulla 2183: ha disinstallato e
reinstallato l'app, si e' registrato con lo stesso account Google, e il
borsellino e' tornato SOLO dopo aver visitato il Passport, mentre i traguardi
accesi nei sentieri non sono tornati affatto.

La radice e' una sola e riguarda l'architettura, non una schermata: **il
Cerchio ricorda il denaro ma non ricorda il cammino ne' chi sei**. Da qui
discende la domanda di Mauro, cioe' che rifare l'onboarding da registrati non
ha senso; e da qui discende la cosa piu' grave, che la voce della custodia
promette testualmente di non far perdere nulla, e oggi quella frase e' falsa.

## Le decisioni di Mauro del 18 agosto, dentro quest'ordine

- La barra sottile NON compare durante l'onboarding, compare dalla home in poi
  e resta visibile in ogni schermata come adesso.
- Nessun muro di accesso alla prima apertura: la prima schermata resta il
  risveglio, e la via per chi torna e' una porta piccola, non un modulo.
- La riga di quella porta e' "Faccio gia' parte del Cerchio", con sotto la
  riga di servizio smorzata "Accedi e ritrova il tuo cammino".

## Il vincolo permanente, riportato come vuole l'ordine AO

**LA SCRITTA ESPLORA E IL SUO MENU' A SCOMPARSA NON SI TOCCANO**, ed e'
normale che a volte si sovrappongano ad altro. Decisione di Mauro del 17
agosto 2026.

## Le premesse, verificate una per una il 19 agosto 2026

1. **P1 VERA.** Il cammino vive solo sul telefono: `SharedPreferences` compare
   in `lib/core/sigilli/diario_del_cammino.dart`,
   `lib/core/sigilli/libro_degli_accrediti.dart` e
   `lib/core/sigilli/coda_delle_feste.dart`, due occorrenze per file, import e
   uso. Fuori dal telefono i traguardi accesi non esistono da nessuna parte.
2. **P2 VERA.** Anche il profilo vive sul telefono:
   `lib/core/identity/profile_store.dart` usa SharedPreferences in otto punti.
3. **P3 VERA A META', e la meta' falsa cambia la diagnosi.** I due soli
   posti da cui parte `porta.stato()` sono confermati per enumerazione,
   `regia_del_cammino.dart` riga 353 e `question_allowance.dart` riga 381.
   Ma **la chiamata all'avvio C'ERA**: `lib/app.dart` costruiva il
   borsellino con la cascata `..load()..sincronizza()`, e montando l'app
   senza toccare niente lo stato risultava gia' chiesto UNA volta, misurato.
   Cio' che mancava davvero e' l'altra meta' della premessa, ed e'
   esattamente il caso di Mauro: **nessuno rifaceva la chiamata DOPO il
   riconoscimento**, cioe' nel momento in cui l'identita' cambia e il Cerchio
   diventa un altro. Chi entrava col proprio account restava con lo stato di
   prima, che era vuoto.
4. **P4 VERA.** `firestore.rules` righe 29 e 30: `allow read: if
   proprietario(uid)` e `allow write: if false`. Il telefono legge il proprio
   documento e non lo scrive mai; ogni scrittura passa dalle callable, e
   questo vincolo non si tocca.
5. **P5 VERA.** Le callable sono sei: cinque in
   `functions/src/cerchio.ts` (`statoDelCerchio`, `consumaDelGiorno`,
   `muoviGliEos`, `scriviLaMemoria`, `cancellaIlCerchio`) piu' `natalChart` in
   `functions/src/index.ts`.
6. **P6 VERA, ed e' la frase che quest'ordine deve rendere vera.**
   `lib/features/account/account_screen.dart` righe 98 e 99: "Salva carta
   natale, ricordi e Eos: se cambi telefono non perdi nulla".
7. **P7 VERA.** `ContinuaComeRiconosciuto` vive in
   `lib/features/account/custodia_del_cielo.dart` riga 241 ed e' montato in
   due scene, il foglio dell'account (riga 421) e il passo del Risveglio
   (`lib/features/onboarding/custodia_del_cielo_step.dart` riga 130);
   `signInWithCredential` sta in `lib/core/identity/account_del_cerchio.dart`
   riga 280.
8. **P8 VERA, con la misura precisa.** La barra sottile ha gia' tre soglie
   dove non si vede (`OnboardingScreen`, `MaestroRevealScreen`,
   `ArtIntroScreen`), e alla prima apertura infatti NON c'e': misurato
   montando l'app senza onboarding fatto. Ma il Risveglio prosegue in
   `RisveglioJourney`, che e' una rotta spinta con `pushReplacement`
   (`onboarding_screen.dart` riga 213) e NON sta fra le soglie: da li' in poi,
   e quindi per la carta natale, la custodia e il sigillo, la barra si vede.
   L'elenco vive dentro `barra_dell_identita.dart` e non nell'elenco unico
   `dove_si_vede_la_barra.dart`, che governa la barra STORICA del guscio.
9. **P9 VERA per dichiarazione di Mauro**: il fatto del 18 agosto sul telefono
   e' un collaudo, non una supposizione, e non si rimisura da qui.

## Le voci

- **AP.01** Il Cerchio custodisce il cammino e l'identita'. Stato: CHIUSA
  (nasce `functions/src/cammino.ts`, la casa del cammino custodito:
  identita' di nascita, conti dei gesti, giorni con gesto, gesti nell'ora
  giusta, serie, Sigilli accesi CON LA DATA, archetipo con la data del test e
  arti preferite. **NESSUNA CALLABLE NUOVA**, e la guardia lo conta: restano
  sei. Il cammino viaggia dentro `statoDelCerchio`, che il client chiede gia'
  a ogni apertura, e il documento vive in `users/{uid}/stato/cammino`, sotto
  lo stesso ramo che le regole proteggono dalla scrittura del client, quindi
  la premessa P4 resta intatta.
  **Cosa NON si custodisce, ed e' una scelta**: la carta natale, che nasce
  dai dati di nascita ogni volta uguale. Custodirla sarebbe una seconda
  verita' sullo stesso cielo.
  **La fusione vive sul SERVER e solo li'**: il telefono manda cio' che ha e
  adotta cio' che torna. Se la regola vivesse anche in Dart sarebbero due
  regole, e il giorno che una cambia il cammino di qualcuno si spezzerebbe a
  meta'. Lato telefono nasce `lib/core/cammino/cammino_da_custodire.dart`,
  che e' solo la forma e non decide niente.
  La forma porta una VERSIONE e ogni campo e' opzionale, cosi' si estende
  senza rompere chi legge una versione vecchia; la lettura non si fida di
  niente, perche' cio' che entra nel Cerchio ci resta. Prove del server
  `functions/src/cammino.test.ts`, nove prove dentro `npm test` che ora conta
  34 verdi; guardia del telefono
  `test/il_cerchio_custodisce_il_cammino_test.dart` con otto prove, fra cui
  l'enumerazione delle callable e il viaggio di andata e ritorno senza
  perdite)
- **AP.02** Il saldo e il cammino si chiedono all'avvio. Stato: FERMATA IN ATTESA DI DECISIONE
  (nasce `lib/core/cammino/custode_del_cammino.dart`, che raccoglie il
  cammino dalle porte uniche che gia' esistono, lo manda e adotta cio' che
  torna. **UNA CHIAMATA SOLA**: la cascata `..sincronizza()` nel provider e'
  stata TOLTA, perche' con l'aggiunta del custode le richieste erano
  diventate due nello stesso momento, misurate, e la seconda sarebbe partita
  senza cammino.
  **Il custode aspetta che il diario abbia letto il disco** prima di
  raccogliere, altrimenti manderebbe al Cerchio un telefono che sembra vuoto
  e la fusione non avrebbe due parti: e' la stessa famiglia delle voci AN.04
  e AO.04.
  `QuestionAllowance.sincronizza` porta il cammino e restituisce quello
  fuso; il diario impara ad ADOTTARLO prendendo il massimo e unendo i
  Sigilli, cioe' difendendosi comunque da una risposta storta. Senza rete non
  cambia niente e non si cancella niente, provato leggendo il disco dopo.
  Il diario impara anche a ricordare QUANDO ogni Sigillo si e' acceso, che
  prima non sapeva e che la fusione difende come primato.
  Guardia `test/lo_stato_si_chiede_all_avvio_test.dart` con tre prove e rosso
  provato togliendo il custode. Chiude il collaudo di Mauro sulla 2184)
- **AP.03** La fusione, mai la sostituzione cieca. Stato: CHIUSA
  (`fondiCammini` in `functions/src/cammino.ts`, e vive SOLO li': per ogni
  contatore vince il PIU' ALTO chiave per chiave, perche' un conto piu' basso
  e' sempre un conto piu' vecchio o piu' povero e mai piu' vero; i Sigilli si
  UNISCONO e per quelli in comune resta la data PIU' VECCHIA, perche' un
  Sigillo si accende una volta sola e quel giorno e' un primato; il primo
  giorno di cammino e la data del test dell'archetipo seguono la stessa
  regola, e per l'archetipo vince il DOMINANTE di quella data, non l'altro.
  **Le arti preferite non si uniscono**, e la ragione e' scritta accanto:
  sono un ORDINE scelto dalla persona, e un'unione inventerebbe un ordine che
  nessuno ha scelto.
  I tre casi dell'ordine sono provati coi loro nomi, telefono pieno e server
  vuoto, telefono vuoto e server pieno (il caso di Mauro), e i due diversi;
  piu' una prova generale che NESSUNA CHIAVE SPARISCE e nessun valore scende,
  che e' la lezione della voce AO.04 scritta come prova. **Rosso provato in
  tre modi diversi**, cioe' sostituendo invece di fondere (due prove rosse),
  non unendo i Sigilli (tre rosse) e facendo vincere la data piu' recente
  (due rosse); ripristinato, `npm test` conta 34 verdi)
- **AP.04** La porta piccola per chi torna. Stato: FERMATA IN ATTESA DI DECISIONE
  (sulla prima schermata del Risveglio, sotto "Inizia il rito", compare
  `_PortaPerChiTorna` coi testi di Mauro: "Faccio gia' parte del Cerchio" e,
  smorzata, "Accedi e ritrova il tuo cammino". I due testi vivono in due
  costanti, cosi' si cambiano senza toccare altro.
  **Non e' una seconda porta sull'accesso**: il foglio che si apre e'
  `mostraLaPortaPerChiTorna`, che dentro monta le stesse `VieDellaCustodia`
  del foglio della custodia, Google, Apple dove le regole dell'App Store lo
  pretendono, ed email. Cambia la frase, non la strada.
  **E non e' un muro, misurato e non presunto**: la guardia confronta le
  QUOTE a schermo e pretende che il rito stia sopra e la porta sotto, che la
  riga di servizio non sia piu' grande del richiamo principale, e che chi
  tocca "Inizia il rito" prosegua senza incontrarla piu'. A riconoscimento
  avvenuto si va al giro del Custode, che e' lo stesso della voce 06, e si
  esce dal rito SOLO se non resta niente da chiedere: con un'identita'
  parziale il rito prosegue dai passi che mancano.
  Guardia `test/la_porta_per_chi_torna_test.dart` con tre prove e rosso
  provato. Chiude il collaudo di Mauro sulla 2184)
- **AP.05** L'onboarding si salta, e il ritrovamento si vede. Stato: FERMATA IN ATTESA DI DECISIONE
  (nasce `lib/core/cammino/ritrovamento.dart`, che decide in UN punto solo
  quali passi restano da chiedere: la stessa domanda arriva da due strade,
  la porta piccola della voce 04 e il "Continua come" della voce 06, e se
  ognuna decidesse per conto suo un giorno una delle due richiederebbe la
  nascita a chi l'aveva gia' data. Con l'identita' completa il rito non si
  monta affatto; con l'ora mancante si chiede SOLO l'ora, e l'onboarding si
  apre gia' su quel passo coi dati noti compilati, provato a schermo.
  **Perche' l'ora non si salta mai per comodita'**: e' la distinzione che
  decide se l'Ascendente esiste, quindi darla per persa chiuderebbe una
  porta per sempre.
  Nasce `lib/features/onboarding/scena_del_ritrovamento.dart`, la prova A
  SCHERMO che la promessa della custodia sia mantenuta: carta natale,
  Sigilli accesi ed Eos, coi NUMERI VERI. Se non c'e' niente da mostrare la
  scena non compare, perche' celebrare il ritrovamento di zero cose sarebbe
  la bugia peggiore, nel momento in cui una persona sta verificando se puo'
  fidarsi. **All'avvio la scena non si mostra**, e' voluto: il ritrovamento
  e' una notizia solo dopo un riconoscimento, non ogni mattina.
  Guardia `test/l_onboarding_non_si_rifa_test.dart` con otto prove. Chiude il
  collaudo di Mauro sulla 2184)
- **AP.06** Il "Continua come" restituisce il cammino. Stato: CHIUSA
  (le strade che riconoscono una persona erano TRE, non una: l'ultimo passo
  del Risveglio, l'invito successivo a chi aveva rimandato, e la porta
  piccola della voce 04. La prima e la seconda facevano entrare e basta.
  Ora tutte e tre passano da `CustodeDelCammino.dopoIlRiconoscimento`, che
  fa il giro intero in un punto solo: fusione della voce 03, rito che si
  salta secondo la voce 05, scena del ritrovamento. Nella strada del foglio
  d'invito il foglio si chiude PRIMA del giro, perche' il ritrovamento e'
  una rotta e non deve aprirsi dietro un foglio che sta sparendo.
  Guardia `test/il_continua_come_restituisce_il_cammino_test.dart` con tre
  prove: ENUMERA le strade invece di montarne una, perche' una prova su una
  schermata sola resterebbe verde il giorno in cui nasce la quarta strada e
  nessuno la collega. Rosso provato togliendo una sola chiamata: la guardia
  ha nominato il file colpevole)
- **AP.07** La barra sottile fuori dall'onboarding. Stato: FERMATA IN ATTESA DI DECISIONE
  (la premessa P8 aveva ragione e la misura ha detto DOVE: alla prima
  apertura la barra gia' non si vedeva, perche' `OnboardingScreen` era fra le
  soglie, ma il Risveglio prosegue in `RisveglioJourney`, che e' una rotta a
  se' e NON c'era: da li' in poi, cioe' per la carta natale, la custodia del
  cielo e il Sigillo, la barra compariva addosso al rito d'ingresso.
  **L'elenco si e' trasferito nella casa unica** `dove_si_vede_la_barra.dart`,
  dove gia' viveva quello della barra storica: le due barre hanno regole
  diverse, la storica si vede in cinque schermate e la sottile quasi ovunque,
  ma la domanda che si fanno e' la stessa, e prima aveva due case in due
  file. Guardia `test/la_barra_sottile_non_entra_nel_risveglio_test.dart` con
  quattro prove, che guardano tutti e due i versi, cioe' anche che dalla home
  in poi la barra ci sia, e con rosso provato su entrambe le pretese. Una
  prova nata sbagliata e corretta: usava nomi di classe inventati, e un nome
  inventato interroga una schermata che non esiste e passa sempre. Chiude il
  collaudo di Mauro sulla 2184)
- **AP.08** La frase della custodia diventa vera. Stato: CHIUSA
  (le frasi false erano DUE, e la seconda l'aveva resa falsa quest'ordine
  stesso. La prima e' il sottotitolo della custodia, che prometteva "non
  perdi nulla" mentre i traguardi si perdevano davvero: adesso NOMINA cio'
  che torna, "Cielo di nascita, traguardi accesi, ricordi e Eos: tornano su
  qualsiasi telefono". La seconda e' la riga onesta del "Continua come", che
  diceva che i due Cerchi non si uniscono: era vera fino alla voce 03, e da
  quando la fusione esiste era diventata una promessa IN DIFETTO, che e'
  bugia quanto una in eccesso. Ora dice che i passi si uniscono, e continua
  a dire cio' che NON si fonde, Eos e ricordi.
  **La misura sul bentornato, e cosa dice davvero.** Misurato sul pacchetto:
  `google_sign_in` 6.3.0 espone `signInSilently`, e su Android finisce in
  `GoogleSignInClient.silentSignIn()` (`google_sign_in_android` 6.2.1,
  `GoogleSignInPlugin.java` riga 276), che NON e' `getLastSignedInAccount`:
  non guarda la memoria dell'app ma chiede ai servizi Google se quel
  telefono ha gia' autorizzato questa app, ed e' per questo che PUO'
  rispondere anche dopo una reinstallazione. Se risponde un nome, sopra la
  porta piccola compare "Bentornato, [nome]"; se risponde nulla non compare
  niente e la porta resta com'e'. **Il verdetto sul telefono vero non e'
  stato misurato da qui e non si dichiara**: nessun emulatore parte su
  questa macchina, quindi lo chiude il collaudo di Mauro sulla 2184.
  Nessuno entra da solo: il saluto prende un nome, non un'identita'.
  Guardia `test/le_frasi_della_custodia_dicono_il_vero_test.dart` con cinque
  prove che LEGANO la frase al codice invece di fissarla, perche' fissare il
  testo resterebbe verde il giorno in cui il sistema cambia e la frase resta
  indietro, che e' esattamente cio' che era successo. Tre rossi provati.
  Una guardia vecchia riscritta e non allentata: `l_onboarding_riconosce_e_
  propone_test` pretendeva la frase "non si uniscono", e adesso pretende
  l'unione dei passi e il limite su Eos e ricordi)
- **AP.09** Il manifesto, la suite, il deploy e la build 2184. Stato: CHIUSA
  (prove del server 34 su 34 con `npm test` dentro `functions/`. Suite intera
  in DUE esecuzioni: la prima 2946 verdi e 14 rossi, la seconda **2947 verdi
  e 13 rossi**, dei quali SETTE di legge gia' dichiarati in AM.05
  (l'attribuzione cieca, albero e loto fuori tela in
  `i_tre_sentieri_si_disegnano`, `un_traguardo_acceso_pesa_uguale`, e le
  guardie degli ordini AC, T e U ancora aperti), la guardia di quest'ordine
  rossa apposta finche' questa riga non si chiude, il transitorio del lavoro
  non ancora spinto, e QUATTRO code vere curate, piu' una quinta curata fra
  le due corse.
  **Le cinque code, tutte nate da quest'ordine.** Una guardia cadeva per un
  A CAPO: pretendeva `MaestroScope(child: OnboardingScreen(` su una riga
  sola, e il parametro dell'identita' ritrovata l'aveva spezzata; adesso
  appiattisce gli spazi prima di guardare, perche' una guardia che cade per
  un a capo insegna a non fidarsi delle guardie. La scena del ritrovamento
  mostra Eos e non era nell'elenco di `gli_eos_hanno_un_nome`: ci e' entrata,
  e usava gia' l'icona giusta. L'ora di nascita entrava da una QUARTA porta,
  `cammino_da_custodire.dart`: guardata come la prova chiede, e' la porta del
  RITORNO, l'unica da fuori verso dentro, quindi il tetto sale a quattro con
  la ragione scritta e alla quinta la prova cade ancora. Il censimento degli
  spazi rigenerato, 140 vuoti.
  **La quarta coda ha rafforzato una rete, e la rete ha trovato un difetto
  di misura in se stessa.** `passport_carta_natale` dichiarava nuda la scena
  del ritrovamento perche' riconosceva le schermate DAL NOME, `...Screen` o
  `...Journey`: il nome italiano non passava, e per contro qualunque cosa
  chiamata Screen sarebbe passata senza scaffale. Adesso la classe montata si
  cerca nei sorgenti e si guarda se porta uno `Scaffold`, con due correzioni
  misurate: lo scaffale di una schermata con stato vive nello STATO (dodici
  schermate sane risultavano nude), e si eredita per due passi, perche'
  `DayOracleScreen` lo prende da `RitualView`. La propagazione libera invece
  rendeva la rete verde per SATURAZIONE, e il rosso non scattava piu': la
  causa era un COMMENTO di `CosmosBackground` che nomina "il nero dello
  Scaffold", quindi ora i commenti si tolgono prima di guardare. Rosso
  provato togliendo lo scaffale a una schermata vera.
  **Un'anteprima nuova, e ha trovato due difetti che nessuna prova cercava**:
  `docs/preview/ritrovamento.png`, la scena su cui si gioca la promessa di
  tutto l'ordine, non aveva nessuna immagine. Alla prima cattura il pulsante
  mostrava RETTANGOLI al posto delle lettere, perche' era l'unico testo
  dell'app senza stile dichiarato e prendeva il carattere di Material invece
  del token di casa; alla seconda si vedeva stretto e appoggiato a sinistra,
  orfano, e adesso e' a tutta larghezza come ogni altro invito.
  Build `0.1.0+2184`, letta nel `pubspec.yaml` riga 12 e riletta dall'archivio
  con aapt2, 161.110.871 byte (153,6 MB) per arm64, consegnata su Firebase App
  Distribution il 19 agosto 2026 a `cloud@esotericircle.app`, release
  `3q1igqfc5niug`, registro `docs/versione_distribuita.json` aggiornato da 2183
  a 2184 dentro la procedura e riletto. Integrita' dell'archivio verificata
  famiglia per famiglia. Prova di accensione SALTATA con
  `ACCENSIONE_SALTATA_PER_ORDINE` e la ragione scritta e stampata (nessun
  telefono collegato e nessun emulatore avviabile su questa macchina): e' il
  DECIMO salto di fila e resta un ripiego, nessun dispositivo ha acceso questo
  archivio prima del caricamento.
  **IL DEPLOY DELLE FUNCTIONS LO ESEGUE MAURO**: `firebase deploy --only
  functions`. Senza quel comando la 2184 parla a un server che NON sa ancora
  custodire il cammino, e tutto quello che quest'ordine ha costruito resta
  muto)

## I marcatori, contati sulle righe

VOCI_TOTALI: 9
VOCI_APERTE: 0
VOCI_CHIUSE: 5
VOCI_FERMATE_SU_PREMESSA_FALSA: 0
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 4
