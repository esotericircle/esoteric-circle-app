# ORDINE CH, IL RAMO TORNA UNO E L'ARCHIVIO DICE IL VERO

Manifesto dell'ordine CH del 31 agosto 2026. Guardia:
`test/ordine_ch_guard_test.dart`.

**La regola zero vale anche qui.** Ogni affermazione dell'ordine e' stata
verificata sul ramo prima di lavorarci, comprese quelle che l'ordine
attribuiva a Code stesso: un rapporto non e' una misura di adesso, e una di
quelle si e' rivelata sbagliata proprio perche' veniva da un mio rapporto.

## Le dodici voci

- **CH.01** I tre commit tornano sul ramo canonico. **CHIUSA.**
- **CH.02** Il ramo laterale non resta come seconda verita'. **CHIUSA.**
- **CH.03** Il manifesto CG dichiara il fatto del ramo. **CHIUSA.**
- **CH.04** La riga dei rossi accettati non sopravvive alla sua ragione. **CHIUSA.**
- **CH.05** La regola del ramo unico, scritta dove Code la legge. **CHIUSA.**
- **CH.06** L'architettura a 32 bit esce del tutto. **CHIUSA.**
- **CH.07** La guardia della consegna: l'archivio contiene cio' che promette. **CHIUSA.**
- **CH.08** Il comando di build entra nel registro. **CHIUSA.**
- **CH.09** Il peso lo scrive la consegna, e il codice morto esce. **CHIUSA.**
- **CH.10** Il peso della 2215 nel registro si corregge. **CHIUSA.**
- **CH.11** La build nuova, e la 2216 non si consegna piu' a nessuno. **CHIUSA.**
- **CH.12** Un solo foglio di istruzioni per il fondatore. **CHIUSA.**

VOCI_TOTALI: 12
VOCI_CHIUSE: 12
VOCI_APERTE: 0
VOCI_FERMATE_SU_PREMESSA_FALSA: 0
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0
VOCI_FERMATE_SU_DECISIONE_DEL_FONDATORE: 0

## LA COSA CHE VALE PIU' DELLE ALTRE

**Una build e' uscita senza motore per meta' dei telefoni possibili, ha
superato 4.175 prove e lo sbarramento, e a trovarla e' stato il fondatore
guardando due numeri su App Tester.**

La 2216 e' stata consegnata senza `libflutter.so` e senza `libapp.so` per ARM
a 32 bit, mentre la cartella `lib/armeabi-v7a/` e' rimasta dentro l'archivio
con cinque librerie di plugin. Un'app Flutter senza il suo motore non ha
niente da avviare. Nessuna prova lo ha visto, e nessuna prova POTEVA vederlo:
il cancello guarda il codice, e fra il codice che passa le prove e l'archivio
che parte ci sono Gradle, gli AAR dei plugin, i filtri degli ABI e le
esclusioni del confezionamento.

E' la stessa famiglia della guardia col bersaglio finto e della cattura presa
nell'istante sbagliato: **la prova era verde e la cosa non c'era.** La
differenza e' dove: qui il buco non stava dentro una guardia, stava nel fatto
che nessuna guardia guardasse quel posto.

## LE PREMESSE, VERIFICATE UNA PER UNA

| premessa | esito | la misura |
| --- | --- | --- |
| P01 | **vera** | `git ls-remote` sul canonico: `078d24b4`, esatto |
| P02 | **vera** | `git ls-remote` sul laterale: `f8b70d50`, esatto |
| P03 | **vera** | `git log 078d24b4..f8b70d50` da tre commit, e `merge-base --is-ancestor` conferma che il canonico e' antenato |
| P04 | **vera nella sostanza, sbagliata di un giorno nella data** | i tre file non ci sono nella copia del fondatore, `.git/HEAD` punta al canonico; ma la sua data e' **15 agosto 2026 alle 00:54**, non il 14 |
| P05 | **vera** | i marcatori del manifesto CG: 16, 15 chiuse, 1 aperta, e l'aperta e' CG.15 |
| P06 | **vera** | il registro ha due righe non commento, e una nomina la guardia CG |
| P07 | **vera** | cercata la parola ramo nei due manifesti e nel riallineamento: le sole occorrenze dicono di VERIFICARE sul ramo e parlano del puntatore della testa, nessuna di dove si spinge |
| P08 | **vera** | blocco `assets:` piu' `fonts:` fra `e646f06f` e `f8b70d50`: 77 righe, identiche |
| P09 | **vera** | `git log e646f06f..f8b70d50 -- assets brand_assets`: nessun commit |
| P10 | **vera** | 195.596.827 e 174.780.993 byte, differenza 20.815.834 |
| P11 | **vera** | `libflutter.so` 8.453.804 e `libapp.so` 12.583.500 compressi, assenti nel 2216, presenti nel 2215 |
| P12 | **vera** | 7 librerie in `arm64-v8a`, 5 in `armeabi-v7a`, e le cinque sono quelle dei plugin, nominate una per una |
| P13 | **vera** | `assets/models_bundled/` 3.842.813 byte compressi in tutti e due, e le 22 voci del volto sono identiche |
| P14 | **vera** | cercato nel corpo di `e646f06f`, in `versione_distribuita.json` e in `STATO_VIVO.md` a quella testa: il comando non c'e' |
| P15 | **vera** | riga 243 il calcolo, righe 320-322 la scrittura, nessun `def` in mezzo |
| P16 | **FALSA nel numero, vera nella sostanza** | il codice morto c'e' ed e' uno solo, ma sta alla **riga 310**, non alla 313. L'errore veniva da un mio rapporto |
| P17 | **vera** | `git log -p` sul registro: 173.822.285 dalla 2208 alla 2213, poi 195.580.347 per la 2214 e per la 2215, mentre l'archivio vero della 2215 pesa 195.596.827 |

**Una sola premessa falsa su diciassette, ed e' P16.** Non ferma nessuna voce,
perche' e' un numero di riga: la cosa che descriveva esisteva davvero. Vale la
pena dire da dove veniva l'errore: **da un mio rapporto**, quello della misura
del 31 agosto, non dall'Architetto. E' esattamente la ragione per cui la regola
zero dice di riverificare anche le misure attribuite a Code.

**E una premessa imprecisa, P04**: la data di `.git/HEAD` e' il 15 agosto 2026
alle 00:54, non il 14. Non cambia niente della voce, e si scrive perche' una
data riportata a memoria e una letta dal disco non sono la stessa cosa.

## LE DECISIONI PRESE PER DELEGA, E PERCHE'

### CH.01, come i tre commit tornano: avanzamento veloce

**I vincoli erano due**, e li dettava l'ordine: nessuna riga di lavoro si
perde, e nessuno sha gia' citato nei manifesti CF o CG smette di esistere.

`git merge-base --is-ancestor 078d24b4 f8b70d50` risponde di si': la testa del
canonico era gia' un antenato della testa laterale. Quindi il canonico si puo'
far avanzare senza toccare niente, che e' la sola strada che non riscrive
nessuno sha. Una fusione avrebbe aggiunto uno sha nuovo senza portare niente,
e un rebase avrebbe riscritto i tre, cioe' proprio cio' che il vincolo vieta.

**Le tre misure dopo il lavoro**: commit del ramo laterale assenti dal
canonico **0**; file che differiscono fra le due teste **0**; sha citati nei
manifesti CF e CG che non esistono piu' **0**.

Sull'ultima serve una nota di metodo. Cercando le stringhe esadecimali di otto
caratteri nei due manifesti se ne trovano sette, e tre non sono commit: sono le
impronte delle lapidi del benvenuto lette da Firestore, scritte troncate coi
puntini. Quattro sono sha, e tutti e quattro esistono. **Un conto che non
distingue le due cose direbbe che tre sha sono spariti**, e sarebbe falso.

### CH.06, dove vive la scelta dell'architettura: in due posti, non in uno

L'ordine chiedeva che la scelta valesse qualunque comando qualcuno lanci.
`abiFilters` in `defaultConfig` e' il posto naturale, e ci e' andata.

**Ma una serratura sola non basta, ed e' misurato in questo stesso file.** Il
commento accanto alle esclusioni del confezionamento dice, da prima di
quest'ordine: *"abiFilters non basta: le librerie dei plugin arrivano gia'
compilate dentro gli AAR, e quel filtro governa cio' che si compila, non cio'
che si copia. Verificato aprendo l'archivio: x86_64 c'era ancora"*. E' la
stessa identica ragione per cui nella 2216 armeabi-v7a e' rimasta dentro con
cinque librerie. Quindi `"lib/armeabi-v7a/**"` e' entrata anche fra le
esclusioni, accanto a `lib/x86` e `lib/x86_64`. **Due serrature, perche' una
sola era gia' stata misurata insufficiente.**

### CH.08, il comando si dichiara invece di misurarlo, e perche'

L'ordine chiede che il comando lo scriva la consegna e non una persona. **Il
comando non e' dentro l'archivio**: un file non conserva la riga che lo ha
prodotto, e dedurlo dall'inventario e' un indizio, non una lettura. E' quello
che ho dovuto fare per la 2215, e infatti nel rapporto l'ho dichiarato come
deduzione.

Quindi il comando si dichiara, in una variabile d'ambiente, e **la consegna si
rifiuta di partire senza**, esattamente come gia' fa col numero letto
dall'archivio. Cio' che cambia rispetto a prima e' il punto che contava: prima
era facoltativo e non lo scriveva nessuno, adesso e' obbligatorio e nel
registro lo scrive la procedura.

### CH.10, cosa si e' potuto correggere davvero

**La premessa dell'ordine era vera il 30 agosto e non lo e' piu' oggi**, e la
ragione sono io: consegnando la 2216 il campo `peso_archivio_byte` e' passato
al peso della 2216, quindi il registro non dichiara piu' nessun peso per la
2215. Il numero sbagliato vive ormai solo nella storia di git, dentro
`e646f06f`, che non si riscrive.

Cio' che si e' fatto: il campo obsoleto che descriveva la correzione a mano e'
uscito, e al suo posto c'e' una riga che dichiara il peso vero della 2215,
**195.596.827 byte**, con scritto da dove viene, cioe' dalla dimensione
dell'archivio scaricato da App Distribution dalla release `7c1gvmgbdfilo`. Il
numero coincide con quello scritto nel corpo del commit di quella consegna:
erano due posti che dicevano la stessa cosa in modo diverso, e adesso il file
porta quello giusto.

### CH.07, cosa si controlla dentro l'archivio

Cinque controlli, e i primi due sono quelli che avrebbero fermato la 2216:

1. **`assets/flutter_assets/` c'e' e non e' vuota.** Un archivio senza di lei
   e' un guscio Android che non porta l'app.
2. **Nessuna cartella di architettura e' un guscio**: ognuna deve avere
   `libflutter.so` e `libapp.so`. E' il difetto della 2216, testuale.
3. **Le architetture dentro sono esattamente quelle che il progetto
   dichiara**, lette dal `build.gradle.kts`, togliendo quelle che le
   esclusioni del confezionamento buttano fuori: sono due serrature diverse e
   guardarne una sola direbbe una cosa non vera.
4. **Le famiglie dell'arte ci sono coi loro conteggi**, e non si ricontano a
   mano: si passa da `tool/verifica_apk.py`, che quella misura la sa gia'
   fare. Due conti della stessa cosa un giorno divergono.
5. **Il numero letto con aapt2 supera l'ultimo consegnato.** Android rifiuta
   di installare un versionCode piu' basso sopra uno piu' alto, e una build
   che non supera il registro non si installa senza dirlo a nessuno.

**E la lettura del numero con aapt2 e' diventata una porta sola**: viveva in
`consegna.py` e serviva anche all'ispezione, e due modi di leggere lo stesso
numero sono due numeri che un giorno divergono.

## L'INVENTARIO DELL'ARCHIVIO, PRIMA E DOPO

L'inventario sara' completato col numero della 2217 alla consegna. Quello
della 2216, misurato aprendo i due archivi come zip:

| gruppo | 2215 | 2216 | differenza |
| --- | ---: | ---: | ---: |
| `lib/armeabi-v7a/` | 26.534.668 | 5.497.364 | **-21.037.304** |
| `lib/arm64-v8a/` | 31.610.752 | 31.807.360 | +196.608 |
| `classes*.dex` | 3.277.303 | 3.320.911 | +43.608 |
| `assets/flutter_assets/` | 129.194.764 | 129.200.420 | +5.656 |
| `assets/models_bundled/` | 3.842.813 | 3.842.813 | 0 |

Byte compressi, cioe' quelli che pesano davvero dentro il file che il telefono
scarica. I due file interi pesano 195.596.827 e 174.780.993 byte.

## LE GUARDIE CIECHE TROVATE

**Una, e non era cieca per come guardava: era cieca per QUANDO guardava.**

Lo sbarramento un controllo sulle righe di troppo del registro dei rossi
accettati **ce l'aveva gia'**. Ma stampava `AVVISO`, e la build usciva lo
stesso; e soprattutto viveva solo nel ramo rosso, dopo il bivio: **con la
suite tutta verde non veniva eseguito affatto**, cioe' proprio nel caso in cui
una riga sopravvissuta alla sua ragione si riconosce meglio, perche' nessuna
delle prove che nomina cade piu'.

Adesso il controllo sta prima del bivio, gira in tutti e due i rami, e ferma
la build nominando la riga di troppo. La prova del rosso: rimesso l'`exit 0` e
l'avviso, le due prove nuove cadono tutte e due.
