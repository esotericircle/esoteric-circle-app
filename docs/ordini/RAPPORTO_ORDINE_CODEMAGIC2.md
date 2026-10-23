# RAPPORTO DELL'ORDINE CODEMAGIC2, LA BUILD IOS VA IN TIMEOUT

**Data:** 17 settembre 2026. **Ramo:** `claude/esoteric-circle-master-order-e798aj`.
**Manifesto:** `docs/ordini/ORDINE_CODEMAGIC2_MANIFESTO.md`. **Otto voci, otto
chiuse. Nessuna build lanciata.**

---

## 1. LA CAUSA DEL TIMEOUT

Il tetto era `max_build_duration: 60` (`codemagic.yaml`, riga 26 a
`65bd5811`). Sui tempi della schermata, che da qui non posso leggere nel
registro:

| parte | tempo |
|---|---:|
| i dodici passi prima delle prove | 3 minuti e 28 secondi, piu' il recupero del codice non leggibile |
| **lo sbarramento** | **46 minuti e 23 secondi** |
| l'archivio, interrotto | 8 minuti e 2 secondi |
| **somma leggibile** | **57 minuti e 53 secondi** |

Il recupero del codice, nella build 2264, era durato 43 secondi: con quello
la somma arriva al tetto durante l'archivio, come la schermata dice. **La
causa e' lo sbarramento rifatto sul Mac: da solo e' il 77 per cento del
tetto.** Lo stesso sbarramento su GitHub, sul commit `65bd5811`, ha girato in
22 minuti e 24 secondi: il Mac mini ci mette piu' del doppio.

## 2. COSA E' SUCCESSO A CODEMAGIC1 SUL WORKFLOW IOS

**CODEMAGIC1 ha toccato il workflow iOS e ha tenuto lo sbarramento di
proposito.** La premessa dell'ordine, che CODEMAGIC1 dovesse togliere il lavoro
a Codemagic, non corrisponde a quello che CODEMAGIC1 ha deciso:

- la voce CODEMAGIC1.02 dice *"il cancello gratis diventa lo stesso del
  cancello a pagamento"*: lo scopo era far fare **la stessa domanda** alle due
  macchine, non farla una volta sola;
- la sua guardia **pretendeva** il comando in tutti e due i file:
  `test/ordine_codemagic1_guard_test.dart`, righe 96-100 a `65bd5811`,
  `expect(c.contains(comando), isTrue, reason: 'codemagic.yaml non esegue piu
  lo sbarramento...')`;
- sul workflow iOS ha **aggiunto** le dipendenze del server, `npm ci`
  (`codemagic.yaml`, righe 289-306), proprio perche' lo sbarramento del Mac
  facesse anche la seconda suite; lo sbarramento stava gia' alle righe 308-326.

Quindi: non e' che non l'ha toccato, non e' rientrato, i due workflow non
divergono. **Sono uguali e ripetuti, per scelta.** Allora la build durava 29
minuti e il costo del doppio non si vedeva; il 17 settembre la suite e'
cresciuta e il doppio e' arrivato al tetto.

## 3. LO STATO DEL CANCELLO GITHUB SUL RAMO

`verde.yml` gira **a ogni spinta** sul ramo canonico (`on: push: branches:
claude/esoteric-circle-master-order-e798aj`), con Flutter 3.44.5 come il Mac,
`npm ci`, `flutter analyze` e `bash tool/sbarramento.sh`. Letti dall'API
pubblica di GitHub:

| commit | esito | durata |
|---|---|---:|
| `65bd5811`, la 2265 consegnata | **verde** | 24 min 47 s, sbarramento 22 min 24 s |
| `3cf58e32` | **verde** | 28 min 53 s |
| `eac1e559` | rosso | 2 min 31 s |
| `ea3f11cb` | rosso | 27 min 31 s |
| `c383e6ae` | verde | 24 min 56 s |

**Il cancello e' attivo e sulla punta del ramo e' verde.** I due rossi sono su
commit intermedi dell'ordine DS, riparati fino al verde di `3cf58e32`. Sul commit
`65bd5811` lo sbarramento e' un passo **eseguito e riuscito**, non saltato:
passo 8, dalle 05:20:21 alle 05:42:45.

## 4. LA SCELTA, E COSA FA GUADAGNARE

**Applicato il primo rimedio, non il secondo.**

**Lo sbarramento esce dal workflow iOS**, e con lui `npm ci`, che serviva solo
a lui. Al loro posto, **come primo passo**, `bash
tool/il_cancello_ha_detto_verde.sh`: chiede a GitHub, senza credenziali, il
verdetto di `verde.yml` su **esattamente** il commit che Codemagic costruisce
(`CM_COMMIT`), e lascia proseguire solo se e' verde. Si ferma, dicendolo, se il
cancello e' rosso, annullato, ancora in corso, mai partito, verde solo su un
altro commit, se GitHub rifiuta o risponde male tre volte, o se il ramo non e'
quello canonico. L'unico scavalco resta `SPEDISCO_SU_ROSSO`, e si stampa.

| opzione | minuti di Mac per build | rischio |
|---|---:|---|
| com'era | circa 60, e muore | nessun archivio |
| **alzare solo il tetto a 120** | oltre 60, **nessun risparmio** | ogni build brucia 46 minuti di doppio; 500 minuti al mese fanno 7 build; una build piantata ne brucia 120 |
| **togliere lo sbarramento** (applicata) | circa 20 stimati, **46 min 28 s in meno** | la build si fida del verdetto di GitHub, vedi sotto |
| tutti e due | come la precedente | alzare il tetto non serve a niente e raddoppia il costo di una build piantata |

**Il tetto resta 60**: senza lo sbarramento lascia all'archivio piu' di
cinquanta minuti, e alzarlo aumenterebbe solo il danno di una build che si
pianta.

**Il rischio, e perche' nessuna prova resta scoperta.** Lo sbarramento che il
Mac faceva e' lo **stesso comando**, sullo **stesso commit**, con la **stessa
versione di Flutter** (3.44.5, pretesa uguale da
`test/la_versione_di_flutter_e_una_sola_test.dart` e dalla guardia nuova), le
**stesse dipendenze del server** (`npm ci` dal lock) e lo stesso registro dei
rossi accettati. Il fuso lo fissa lo sbarramento stesso,
`export TZ="${TZ:-Europe/Rome}"` (`tool/sbarramento.sh`, riga 45), quindi
GitHub gira le prove all'ora di Roma come il Mac. Le prove non scoperte sono
quelle che **dipendono dal sistema operativo**: su GitHub girano su Linux, sul
Mac giravano su macOS. **Nessuna prova della suite costruisce per iOS o
chiama strumenti di macOS**, e le cause che dipendono dal Mac (firma, pod,
Xcode, archivio, manifesto della privacy, simboli) restano tutte nei passi
successivi di Codemagic, che non sono cambiati. Un verde per coincidenza di
commit non puo' passare: il controllo confronta l'hash intero.

**Android.** In `codemagic.yaml` **non esiste un workflow Android**, e
`.github/workflows/android-build.yml` costruisce l'APK di debug senza eseguire
prove (passi: checkout, Java, Flutter, `google-services.json`, `pub get`,
`analyze`, `build apk`). Le build Android consegnate le fa `tool/consegna.py`
sul PC, dopo lo sbarramento locale. **Lo sbarramento non girava due volte per
Android**, e non c'era niente da togliere.

## 5. IL TETTO DI DURATA

**60 minuti, invariato.** Il massimo consentito e' **120 minuti su tutti i
piani**, verificato su due fonti pubbliche il 17 settembre 2026: la pagina
dei prezzi di Codemagic (limite di durata *"120 min"* per Free, Pay as you go,
Fixed price ed Enterprise) e la documentazione della configurazione YAML
(`max_build_duration`, *"min 1, max 120"*). Il piano in uso, dal commento di
`codemagic.yaml`, e' quello gratuito con 500 minuti al mese sul Mac mini M2.
La guardia nuova pretende un valore fra 1 e 120.

## 6. IL RAMO DI COSTRUZIONE

**Workflow iOS `ios-testflight`**: non ha `triggering`, quindi parte solo a
mano da *Start new build*, e il ramo lo sceglie chi preme. La documentazione di
Codemagic non offre un campo che vincoli il ramo di una build manuale: **il
vincolo e' nel primo passo**, che ferma la build in pochi secondi se
`CM_BRANCH` non e' `claude/esoteric-circle-master-order-e798aj`. Provato con
`main`: si ferma. Quale ramo abbia usato la build fallita **non lo posso
vedere da qui**; la schermata riportata dall'ordine lo nomina canonico.

**Workflow Android su GitHub**, `android-build.yml`: parte a ogni spinta sul
ramo canonico, lo stesso di `verde.yml`, e non consegna niente.

## 7. IL TEMPO STIMATO DELLA PROSSIMA BUILD IOS

| parte | stima |
|---|---:|
| macchina, codice, strumenti | circa 2 min 50 s (40 s, 43 s della 2264, 1 min 24 s) |
| il controllo del cancello | pochi secondi |
| strumenti, Firebase, dipendenze, pod, firma | circa 1 min 20 s |
| **l'archivio** | **non misurato**: tagliato a 8 min 2 s, e nessun registro dice quanto dura intero |
| manifesto, simboli, pubblicazione | pochi minuti |

**Stima: fra 15 e 25 minuti**, e l'incertezza e' tutta nell'archivio. L'ordine
dice *sotto i quindici*: con un archivio che a 8 minuti non era finito, non lo
posso promettere.

## 8. LE PROVE SCOPERTE

**Nessuna prova della suite resta senza cancello**: girano tutte su GitHub,
sul commit che si costruisce, e la build non parte senza quel verde. Restano
scoperte, come prima di quest'ordine, le cause che nessuna prova guarda:
firma, pod, Xcode, validazione di Apple.

**Due cose da sapere.**

1. **Dopo ogni spinta si aspetta la spunta verde su GitHub**, circa 25 minuti,
   prima di lanciare la build. Lanciata prima, la build si ferma al primo passo
   dicendo *"IL CANCELLO NON HA ANCORA FINITO"*, e costa un paio di minuti.
2. **GitHub limita le domande senza credenziali a 60 l'ora per indirizzo.** Il
   controllo ne fa una, e ne ripete fino a tre se la risposta non si legge.
   Se la macchina di Codemagic condividesse l'indirizzo con chi ne fa molte, la
   build si fermerebbe dicendo *"GITHUB NON HA RISPOSTO"*: si rilancia.

**Le guardie.** Una nuova, `test/ordine_codemagic2_guard_test.dart`, vista
rossa su due innesti; due riscritte, perche' **dopo la modifica restavano
verdi leggendo il commento** che racconta lo sbarramento tolto: si leggono ora
le righe di codice, e sono state viste rosse togliendo il controllo. Le dieci
prove che toccano la build, il sigillo e il registro delle guardie: **80
prove, tutte verdi**. **La suite intera non e' stata girata in locale**:
l'ordine era urgente, e la gira il cancello di GitHub sul commit spinto, che e'
la stessa risposta che la build leggera'. Vedi la sezione 9.

**L'ordine DT** e' sospeso: i suoi tre commit restano sul ramo locale, non
spinti, e il suo sbarramento e' stato fermato a 3.831 prove per lasciare il
posto a questo. Si riprende sopra questo commit.

## 9. IL CANCELLO SUL COMMIT SPINTO

**L'esito del cancello su questo commit non puo' stare scritto dentro questo
commit**: nasce dopo la spinta. Lo riporto a Mauro appena GitHub lo da', con
l'hash letto da `ls-remote`. **Ed e' la regola da qui in avanti**: la build si
lancia solo sul commit la cui spunta e' verde, e ogni commit spinto dopo
chiede la sua spunta. Chi lancia prima non rompe niente: la build si ferma al
primo passo e lo dice.
