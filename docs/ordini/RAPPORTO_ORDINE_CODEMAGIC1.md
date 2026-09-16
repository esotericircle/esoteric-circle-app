# RAPPORTO DELL'ORDINE CODEMAGIC1

**La build arriva sugli iPhone, e un rifiuto da Codemagic non deve piu'
accadere.** 16 settembre 2026, ramo
`claude/esoteric-circle-master-order-e798aj`. Parte dal commit `bc81dcde`,
quello su cui la build 2264 e' caduta al passo dodici.

---

## 1. CHE COSA HA FERMATO LA BUILD, LETTO NEL REGISTRO

Il fondatore ha mandato il registro del passo dodici, 1.521.031 byte. Non e'
una ricostruzione: sono le righe.

| dove | cosa dice |
|---|---:|
| riga 705 | `corredo_anteprime_test.dart: Nessuna cattura ha un rapporto di pixel implicito [E]` |
| riga 11.657 | la suite intera chiude a **5.287 prove, 6 saltate, 3 cadute** |
| righe 11.663-11.665 | *"LE PROVE DEL SERVER NON SONO STATE ESEGUITE: manca functions/node_modules"* |
| righe 11.954-13.593 | il corredo a scala 1,3: **quindici catture cadute**, da `Cattura il dono col colore del Maestro, giorno 0` a `Cattura la chat con la barra fuori` |
| riga 13.679 | *"IL CORREDO A SCALA MASSIMA HA MONTATO 182 SCHERMATE"* |
| righe 13.710-13.712 | **ROSSI NUOVI, NON ACCETTATI DA NESSUNO: una riga sola**, e *"L'ARCHIVIO NON SI PRODUCE"* |

**Delle tre prove cadute nella suite intera, due erano gia' accettate dal
fondatore**: l'attribuzione cieca e le soglie delle quattro pose. **La terza
era nuova, ed era mia.**

**E le quindici del corredo a scala 1,3 sono tutte accettate**: i quindici
nomi del registro coincidono uno per uno con le quindici righe `SCALA 1,3:`
di `tool/rossi_accettati.txt`. Il cancello ha fatto esattamente il suo
mestiere: ha lasciato passare cio' che il fondatore aveva accettato e si e'
fermato sulla riga che nessuno aveva mai visto.

---

## 2. LA RIGA CHE HA FERMATO TUTTO, E COME L'HO CHIUSA

**Che cosa era.** `test/anteprima_card_della_rivelazione_test.dart`, scritto
da me nell'ordine DQ voce 14 per far vedere al fondatore la card della
rivelazione, dichiarava `tester.view.devicePixelRatio = 2.0` e scriveva un
PNG. La regola di casa sta in `test/corredo_anteprime_test.dart` riga 28,
`rapportoDichiarato = 3.0`, e vale **per chiunque scriva un'immagine che
qualcuno guardera'**: un'anteprima a rapporto due, messa accanto alle altre,
e' visibilmente meno nitida.

**Come l'ho chiusa.** Rapporto tre, e schermo allargato di conseguenza da 760
per 1200 a 1140 per 1800 pixel, perche' la stessa scatola di punti logici a
rapporto tre vuole piu' pixel veri. L'immagine e' stata rigenerata: adesso e'
**960 per 1304 pixel** invece di 640 per 869.

**Cosa NON ho fatto, ed e' la parte che conta**: nessuna soglia abbassata,
nessuna eccezione aggiunta alla tavola `eccezioniDelRapporto`, nessuna riga
scritta in `tool/rossi_accettati.txt`. La guardia e' rimasta esattamente come
era: si e' spostato il testo che la violava.

---

## 3. PERCHE' QUEL ROSSO E' ARRIVATO FINO AL MAC MINI

**E' la domanda vera, e la risposta non e' tecnica.**

Lo sbarramento locale, sullo stesso albero, era stato girato e aveva scritto
il suo gettone: *"GETTONE SCRITTO: numero 2264, 5288 prove"*. Ma quel giro e'
finito **prima** che l'anteprima della card esistesse: il file e' nato dopo,
nel commit `bc81dcde`, insieme al rapporto dell'ordine DQ, ed e' stato spinto
**senza rigirare il cancello**.

**La regola di casa esisteva gia'**, si chiama *"suite intera prima di
spingere"* e sta scritta fra le lezioni del progetto. L'ho violata io, alle
cinque del mattino, alla fine di una notte di lavoro. **Nessun automatismo
l'avrebbe fermata**: il cancello che avrebbe visto quel rosso era proprio
quello che non ho rigirato.

Per questo il secondo risultato dell'ordine non si ottiene ricordandosi di
girare il cancello: si ottiene **togliendo a chi lavora la possibilita' di
saltarlo**.

---

## 4. LA STRADA SCELTA, E PERCHE' REGGE

**Il cancello gratuito diventa lo stesso cancello a pagamento.**

`.github/workflows/verde.yml` gira a ogni push sul ramo, su macchina GitHub,
e finora eseguiva `flutter test`. Adesso esegue **`bash tool/sbarramento.sh`**,
che e' parola per parola il comando del passo dodici di `codemagic.yaml`.

**Perche' regge, e la ragione e' una sola**: prima le due macchine facevano
**due domande diverse**. `flutter test` non fa girare le prove del server, non
fa il corredo a scala 1,3 e non guarda il registro dei rossi accettati; lo
sbarramento fa tutte e tre le cose e in piu' distingue un rosso accettato da
un rosso nuovo. **Un cancello a valle piu' severo di quello a monte e' un
cancello che scopre i guasti dove si paga.** Adesso la domanda e' la stessa:
perche' Codemagic cada su una prova rossa, quella prova deve essere rossa
prima su GitHub, dove costa zero e si vede in minuti.

**E una guardia lo tiene fermo nel tempo**:
`test/ordine_codemagic1_guard_test.dart` pretende che **tutti e due i file
contengano lo stesso comando** e che `verde.yml` non torni a eseguire
`flutter test` come passo a se'. Se qualcuno li fa divergere di nuovo, cade
una prova, non una build.

**Le cause che non sono le prove, e qui l'ordine chiede onesta'.** Questa
strada non copre: la firma e i profili, i pod, lo spazio sul disco della
macchina, la versione di Xcode, e la validazione dell'archivio da parte di
Apple. **Nessuna macchina Linux gratuita costruisce un archivio iOS firmato**,
quindi su quelle cause un cancello gratuito non puo' dire niente. Cio' che si
puo' dire e' che nel registro della 2264 quelle undici fasi erano **tutte
verdi**, e sono costate in tutto meno di tre minuti: `Preparing build machine`
19 secondi, `Fetching app sources` 43, `Installing SDKs` 48, i pod 15, il
portachiavi meno di un secondo, certificato e profili 3 e 3. **La famiglia di
cadute che questa strada toglie e' quella che e' costata i ventinove minuti.**

---

## 5. LA SECONDA SUITE, CHE NON AVEVA MAI GIRATO

Il registro dice che le prove del server non sono state eseguite perche'
mancava `functions/node_modules`. **Non era un caso di quella build**: in
`codemagic.yaml` non c'era **nessun comando npm**, quindi quella cartella su
quella macchina non e' mai esistita, e la seconda suite non e' mai stata
guardata in nessuna build. Lo sbarramento lo diceva a voce alta e andava
avanti, che e' il comportamento giusto per un cancello che non vuole mentire.

**Adesso tutte e due le macchine installano le dipendenze con `npm ci`**, che
installa esattamente cio' che `functions/package-lock.json` dichiara: due
macchine che installassero versioni diverse sarebbero di nuovo due cancelli
diversi.

**Girata qui per la prima volta, la seconda suite dice: 83 prove, zero
cadute.** Non c'era niente di rotto dietro quella porta chiusa, e adesso si
sa invece di sperarlo.

---

## 6. IL CANCELLO, RIGIRATO QUI PRIMA DI SPINGERE

**Girato intero sull'albero di questo lavoro**, 16 settembre 2026, quaranta
minuti di macchina. Le tre parti, coi numeri che ha stampato:

| parte | esito |
|---|---|
| la suite intera di Flutter | **5.292 prove, 6 saltate, 3 cadute** |
| le prove del server, `npm test` in `functions/` | **83 prove, zero cadute** |
| il corredo a scala 1,3 | **182 schermate montate, 15 catture cadute** |

**Le quindici catture sono le quindici accettate**, una per una le stesse
righe `SCALA 1,3:` di `tool/rossi_accettati.txt`. **Due delle tre cadute della
suite sono le due accettate**, l'attribuzione cieca e le soglie delle quattro
pose. **La terza non c'e' piu'**: `corredo_anteprime_test.dart` non trova piu'
nessuna cattura a rapporto due, che e' la voce 01 chiusa e misurata invece che
raccontata.

**Il cancello si e' fermato lo stesso, e su una riga sola**:

```
ROSSI NUOVI, NON ACCETTATI DA NESSUNO:
    l'albero di lavoro non tiene lavoro che nessun commit contiene
```

**Quella riga e' la casa che dice l'ordine giusto.** I file di quest'ordine
erano ancora sull'albero e in nessun commit, e la guardia
`niente_lavoro_non_spinto` vuole l'albero pulito su una macchina di chi
sviluppa. Su Codemagic
e su GitHub torna verde da se', perche' li' il codice **arriva** dal remoto:
la guardia si esenta da sola leggendo `CM_BUILD_ID` e `GITHUB_ACTIONS`, e lo
dichiara nel suo commento invece di tacerlo.

**Cosa vuol dire, detto senza girarci intorno**: sull'albero di questo lavoro
non esiste nessun rosso nuovo oltre a quello che chiede di committare. Il giro
vero, sull'albero pulito, e' quello che gira **da solo su GitHub al push**, ed
e' la prima volta che il cancello gratuito fa la stessa domanda del cancello a
pagamento. **La sua spunta e' il semaforo per Codemagic.**

---

## 7. LA BUILD, I TENTATIVI E LA RELEASE

@@CONSEGNA@@

---

## 8. DOVE L'ORDINE SBAGLIAVA

**L'elenco e' corto, e i fatti misurabili erano tutti veri.**

- **Il nome del rosso.** L'ordine lo chiama
  *"anteprima_card_della_rivelazione_test.dart cattura a rapporto 2.0 invece
  di 3.0"*: e' il **messaggio** dell'errore, e nomina il file colpevole. Il
  nome della **prova caduta**, quello che il registro stampa e che lo
  sbarramento confronta con `rossi_accettati.txt`, e' un altro: *"Nessuna
  cattura ha un rapporto di pixel implicito"*, e vive in
  `corredo_anteprime_test.dart`. **La differenza non e' accademica**: se un
  giorno il fondatore volesse accettare quel rosso, la riga da scrivere
  porterebbe il nome della prova, non quello del file.
- **Il passo 12 e i 29 minuti e 11 secondi**: non li ho potuti verificare dal
  ramo, perche' il registro della build vive su Codemagic. Il fondatore li ha
  poi confermati con le schermate, e il tempo del passo rosso si legge nella
  sua cartolina: **29m 11s**. Nel manifesto erano scritti come creduti sulla
  parola, adesso sono visti.
- **"I fondatori hanno solo iPhone"**: non e' verificabile da qui, e resta
  creduto sulla parola. Cambia la fretta dell'ordine, non il lavoro.

**Tutto il resto tornava**: le quindici catture a scala 1,3, i due rossi
accettati, il `functions/node_modules` mancante, i due workflow che eseguono
comandi diversi, il repository pubblico.
