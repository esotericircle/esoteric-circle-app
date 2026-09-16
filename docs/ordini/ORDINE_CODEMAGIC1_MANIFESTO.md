# ORDINE CODEMAGIC1, LA BUILD ARRIVA SUGLI IPHONE

**Sigla:** CODEMAGIC1. **Data:** 16 settembre 2026. **Ramo:**
`claude/esoteric-circle-master-order-e798aj`. Parte dal commit `bc81dcde`,
quello su cui la build 2264 e' caduta.

**Urgente, e sospende l'ordine DR**: i fondatori hanno solo iPhone, e l'unica
strada che li raggiunge e' TestFlight, che passa da Codemagic. Le voci DQ.11 e
DQ.12 restano aperte finche' un archivio non e' stato validato.

VOCI_TOTALI: 5
VOCI_CHIUSE: 5
VOCI_APERTE: 0
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0
VOCI_FERMATE_SU_PREMESSA_FALSA: 0

Il rapporto sta in `docs/ordini/RAPPORTO_ORDINE_CODEMAGIC1.md`.

---

## I FATTI, RIMISURATI

Regola di verifica: rimisurato sul ramo a `bc81dcde`.

| cosa dice l'ordine | la mia misura | esito |
|---|---|---|
| il registro dichiara un rosso nuovo, `anteprima_card_della_rivelazione_test.dart` cattura a rapporto 2.0 invece di 3.0 | **vera, ed e' mia**: il file dichiara `tester.view.devicePixelRatio = 2.0` e scrive un PNG, quindi `corredo_anteprime` lo prende. La regola sta in `test/corredo_anteprime_test.dart` riga 28, `rapportoDichiarato = 3.0`, e vale per **chi scrive un'anteprima**, cioe' per chi chiama `writeAsBytes` | **VERA** |
| il corredo a scala 1,3 e' rosso con quindici catture cadute | **vera**: in `tool/rossi_accettati.txt` ci sono **quindici** righe col prefisso `SCALA 1,3:`, tutte accettate dal fondatore, e lo sbarramento le lascia passare | **VERA** |
| le prove del server non sono state eseguite, mancava `functions/node_modules` | **vera, e so perche'**: in `codemagic.yaml` **non c'e' nessun comando npm**, quindi quella cartella su quella macchina non esiste mai. Lo sbarramento lo dice e va avanti, righe 108-112 | **VERA** |
| i rossi di CR.13 e dell'attribuzione cieca sono accettati e passano | **vera**: sono le due righe senza prefisso in `tool/rossi_accettati.txt` | **VERA** |
| `verde.yml` gira gratis a ogni push ed esegue `flutter test`; `codemagic.yaml` esegue `bash tool/sbarramento.sh`; non sono la stessa cosa | **vera, ed e' il buco da cui e' passato il rosso**: `flutter test` non fa girare ne' le prove del server, ne' il corredo a scala 1,3, ne' il controllo dei rossi accettati | **VERA** |
| il repository e' pubblico | **vera** | **VERA** |
| la build 2264 e' caduta al passo 12 dopo 29 minuti e 11 secondi | **non verificabile da me**: il registro della build sta su Codemagic e da qui non lo vedo. Il passo 12 del file e' *"Le prove, prima di costruire, E SONO UNO SBARRAMENTO"*, riga 289, che e' coerente con un rosso nuovo | **CREDUTA SULLA PAROLA** |

**IL FATTO CHE NON SAPEVA NESSUNO, misurato dopo la spinta del 16 settembre**:
il cancello gratuito non era solo piu' debole, **era rosso da quarantotto
giorni**. Il registro pubblico delle azioni di GitHub conserva **1.055 giri di
`verde.yml`**: 130 verdi, 924 rossi, e l'ultimo verde e' del **29 luglio 2026**.
Da allora **920 giri rossi di fila**, compreso quello del commit `bc81dcde`,
caduto alle 03:39 UTC, **tre ore prima di Codemagic**. La ragione strutturale
sta nella voce 02: `flutter test` nudo non conosce `rossi_accettati.txt`, e i
due rossi che il fondatore ha voluto lo facevano cadere a ogni spinta. **Una
spia rossa comunque non e' una spia.** Il dettaglio, e il PROVENIENZA IGNOTA
dello scivolamento di luglio, stanno nella sezione 3 del rapporto.

**E IL FATTO CHE L'ORDINE NON DICE, che e' il piu' importante di tutti**: quel
rosso non e' arrivato per caso. Lo sbarramento locale era stato girato e aveva
scritto il suo gettone **prima** che l'anteprima della card esistesse: il file
e' nato dopo, nel commit `bc81dcde`, ed e' stato spinto **senza rigirare il
cancello**. La regola di casa *"suite intera prima di spingere"* esiste da
prima di quest'ordine, e sono io ad averla violata.

---

## LE VOCI

- **CODEMAGIC1.01**, il rosso nuovo si chiude senza toccare nessuna guardia:
  l'anteprima della card cattura a rapporto tre, come tutte le altre, e
  l'immagine e' stata rigenerata a quella misura, 960 per 1304 pixel.
  Nessuna soglia abbassata, nessuna riga aggiunta a `rossi_accettati.txt`.
  **CHIUSA**
- **CODEMAGIC1.02**, il cancello gratis diventa lo stesso del cancello a
  pagamento: `verde.yml` gira `bash tool/sbarramento.sh`, non piu'
  `flutter test`, e una guardia pretende che i due comandi restino lo stesso.
  **CHIUSA**
- **CODEMAGIC1.03**, le prove del server girano davvero, su tutte e due le
  macchine: `npm ci` dentro `functions/` prima del cancello, in tutti e due i
  file. Qui in locale, appena installate, la seconda suite ha girato per la
  prima volta: **83 prove, zero cadute**. **CHIUSA**
- **CODEMAGIC1.04**, il manifesto, la guardia e il rapporto. **CHIUSA**
- **CODEMAGIC1.05**, il verdetto del cancello si legge senza credenziali.
  Nata da un fatto misurato dopo la voce 02: il cancello gratuito e' caduto al
  primo giro coi numeri giusti, e **la riga per cui si e' fermato non era
  leggibile da qui**. I registri delle azioni vogliono un accesso anche su un
  repository pubblico, provato: l'API risponde 403 e la pagina web dice *"Sign
  in to view logs"*. Le annotazioni invece sono pubbliche. Adesso
  `tool/il_verdetto_del_cancello.sh` ripubblica li' i blocchi che dicono la
  decisione, e una guardia pretende la catena intera, `pipefail` compreso.
  **CHIUSA**

---

## PERCHE' QUESTA STRADA REGGE, E DOVE NON REGGE

**Il principio**: un rifiuto a pagamento diventa impossibile solo se la stessa
identica domanda viene fatta prima dove non si paga. Oggi le due domande sono
diverse, e la differenza e' esattamente cio' che e' passato.

**Cosa copre**: tutto cio' che lo sbarramento guarda, cioe' la suite intera di
Flutter, le prove del server, il corredo a scala 1,3 e il registro dei rossi
accettati. Dopo questa voce, un rosso come quello di ieri si vede su GitHub in
pochi minuti e a costo zero, prima che qualcuno tocchi Codemagic.

**Cosa NON copre, e va detto**: le cause di caduta che non sono le prove.
Firma e profili, i pod, lo spazio sulla macchina, la versione di Xcode, la
validazione dell'archivio da parte di Apple. Su quelle il cancello gratis non
puo' dire niente, perche' nessuna macchina Linux gratuita costruisce un
archivio iOS firmato. **La sola cosa onesta e' dichiararlo**: questa strada
toglie la famiglia di cadute piu' frequente, non tutte.
