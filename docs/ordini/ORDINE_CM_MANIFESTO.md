# ORDINE CM, MANIFESTO

Il registro che non chiudeva, e il testo che si rompe. 1 settembre 2026, ramo
`claude/esoteric-circle-master-order-e798aj`.

Undici voci. Nessuna build, nessuna consegna: la 2217 resta ferma.

## LE PREMESSE, verificate prima di toccare una riga

REGOLA ZERO: il testo dell'ordine non fa fede. Ogni premessa e' stata
verificata sul ramo, e cio' che era falso sta scritto qui invece di essere
eseguito.

**P1. "Il registro da' tre numeri che non sommano al totale." VERA.** Il
registro nato dall'ordine CL dichiarava 242 guardie, 108 che scorrevano i
sorgenti, 14 sulla porta comune. Le categorie non erano esaustive e la somma
non era scritta da nessuna parte, quindi nessuno poteva accorgersi che non
chiudeva.

**P2. "Il 79 e il 17 sono in contraddizione." FALSA nella forma, VERA nella
sostanza.** Non erano in contraddizione: contavano insiemi diversi. Il 17 era
sulle guardie censite, il 79 su tutti i file di prova. **Nessuno dei due
diceva su quale insieme fosse contato**, ed e' quello il difetto: la stessa
malattia delle due porte, arrivata dentro i documenti invece che nel codice.

**P3. "Le guardie che scoprono un insieme a esecuzione sono 94." FALSA.** Il
numero dipende da cosa si chiama scoperta. Contando chi **elenca** una
cartella, e distinguendo la chiamata dalla citazione, il 1 settembre 2026 sono
**122**. Il 94 nasceva da un riconoscimento che guardava soltanto `lib`.

**P4. "Il Protocollo Operativo." FALSA come nome.** Non esiste nessun file con
quel nome nel repository. Il protocollo operativo di questo progetto vive in
`CLAUDE.md`, che e' il file letto per primo a ogni apertura. **Le tre regole
sono state scritte li'**, piu' in cima a `docs/ordini/RIPRESA.md`.

**P5. "1,3 e' il massimo consentito dal sistema."** Era scritto cosi' dentro
`test/screenshot_capture_test.dart`, ed **e' FALSO**: 1,3 e' il tetto che
questa app si e' data. I massimi veri dei sistemi stanno alla voce 08.

## VOCE 01, LA QUADRATURA

Le categorie ora sommano al totale, e la somma e' scritta.

| categoria | quante |
| --- | ---: |
| Guardie che passano da una porta comune | 92 |
| Guardie con un cardinale proprio dichiarato | 28 |
| Guardie che non scoprono nessun insieme dentro `lib` | 123 |
| **Somma** | **243** |
| **Guardie secondo la definizione** | **243** |

La terza categoria **non e' un debito**: sono guardie che sorvegliano
un'assenza, una fotografia, un elenco che non vive in `lib`, e per loro un
cardinale sui file Dart non vorrebbe dire niente.

**E la quadratura non e' solo scritta, e' sorvegliata.** La guardia nuova
`test/il_registro_delle_guardie_quadra_test.dart` pretende tre cose: che le
categorie sommino, che la somma sia il numero di righe che il registro elenca
davvero, e che **nessuna riga menta** sul cardinale della guardia che nomina.
La seconda pretesa e' quella che conta: **un registro puo' quadrare
benissimo su numeri inventati**, e le cifre in cima le riscrive chiunque
mentre le duecentoquarantatre righe no.

## VOCE 02, IL CARDINALE A CHI SCOPRE UN INSIEME

**Bersaglio dell'ordine: zero guardie che scoprono un insieme a esecuzione
senza cardinale. RAGGIUNTO, e su una popolazione piu' larga di quella
chiesta.**

| | quante |
| --- | ---: |
| Prove che scoprono un insieme di file a esecuzione | 122 |
| Con cardinale da una porta comune o da `cardinaleMinimo` | 103 |
| Con cardinale proprio forte, numero esatto o minimo maggiore di uno | 13 |
| Con cardinale **debole**, cioe' basta un elemento | 6 |
| **Senza nessun cardinale** | **0** |

**Cosa e' cambiato nella definizione, e perche' e' piu' vera.** L'ordine CL
guardava chi scorreva `lib`. Ma la cecita' non e' una proprieta' di quella
cartella, **e' una proprieta' del gesto**: chiunque chieda al disco cosa c'e'
dentro una cartella puo' ricevere una risposta vuota e dirsi verde. Le
guardie che guardano gli asset e le anteprime sono anzi **le piu' esposte**,
perche' quelle cartelle cambiano molto piu' spesso dei sorgenti e si
rigenerano con strumenti che possono fallire a meta'.

**Le tre porte comuni**, tutte in `test/sorgenti_di_lib.dart`:

- `sorgentiDiLib()`, i sorgenti Dart di `lib`, minimo 400 su 525 contati.
- `sorgentiDiCartelle()`, per le cinque guardie che guardano anche `test` e
  `tool`, col minimo dichiarato da chi chiama.
- `fileScoperti()`, qualunque cartella, con estensione e ricorsione a scelta
  e **il minimo obbligatorio**.

**I sei cardinali deboli restano dichiarati e non nascosti.** `expect(x,
isNotEmpty)` e `expect(x, greaterThan(0))` sono cardinali veri ma il piu'
debole possibile: un insieme di **un solo elemento** li soddisfa. Non sono
stati irrobustiti in quest'ordine perche' il bersaglio era l'assenza di
cardinale, non la sua forza. Sono: `corredo_anteprime`,
`i_caratteri_dichiarati_esistono`, `la_runa_cade_e_non_e_gia_li`,
`ogni_freccia_mantiene`, `scena_unica`, `una_prova_dichiara_il_suo_istante`.

### La cecita' viva trovata per strada

`test/nessuna_azione_committa_da_sola_test.dart` cominciava ogni prova con
`if (!cartella.existsSync()) return;`. Il giorno che `.github/workflows` fosse
sparita, o che le prove fossero girate da un'altra cartella, **quelle guardie
sarebbero uscite verdi senza aver letto un solo file**, e il divieto di
committare da soli sarebbe rimasto scritto senza essere sorvegliato. Tolto.

### La meta-guardia colta mentre si degradava

**E' il fatto piu' importante di quest'ordine.** La guardia che sorveglia le
altre le riconosceva dal fatto che nominassero `Directory('lib')`. Portate
sessantasei guardie alla porta comune, quel nome e' sparito dai loro sorgenti,
e lei ne ha viste **32 invece di 98**.

Non e' diventata muta: **e' caduta subito**, perche' il suo cardinale
pretendeva almeno novanta. E' caduta **dentro lo stesso lavoro che l'ha
degradata**, che e' il solo momento in cui riparare costa poco. E' la specie 4
presa in flagrante, ed e' esattamente cio' che la voce CL.04 prometteva.

Da quel guasto sono nate tre correzioni che valgono piu' della migrazione:

1. **Si riconosce chi scopre dal GESTO, non dall'idioma.** Elencare una
   cartella, o passare da una porta comune.
2. **Si guarda cio' che un sorgente CHIAMA, non cio' che NOMINA.** Due prove
   citano `Directory('lib')` dentro una stringa perche' il loro mestiere e'
   cercarlo nelle altre: contarle fra chi scorre le classificava male, **e il
   conto restava coerente con se stesso**. Un conto sbagliato che quadra e'
   peggio di uno che non quadra, perche' non chiede di essere guardato. La
   porta nuova e' `test/codice_senza_testo.dart`.
3. **Le forme legittime di cardinale sono quattro, non una.** Il
   riconoscimento vecchio accusava di essere nude due guardie che il cardinale
   ce l'avevano da sempre, una perfino piu' forte del minimo:
   `expect(misure.length, 24)` dice quante cose devono esserci, non quante
   almeno. **Riconoscere una forma sola non e' rigore, e' un'accusa
   sbagliata**, e le accuse sbagliate insegnano a non credere alla guardia che
   le fa.

### Il difetto che ho introdotto io, e come e' venuto fuori

`cardinaleMinimo` usava `expect`. Due guardie chiamano la porta comune al
livello di `main()`, per calcolare il corpus una volta sola prima dei loro
`test()`, **che e' un modo legittimo di scrivere una prova**, e sono morte al
caricamento con un `OutsideTestException` **senza messaggio**: `expect` vive
solo dentro il corpo di una prova.

Un cardinale che funziona in un posto e muore muto nell'altro non e' un
cardinale. Ora si solleva `InsiemeSvuotato`, che ha un `toString` proprio e
**porta il suo messaggio con se' in tutti e due i posti**. Provato rosso al
caricamento, che e' dove il messaggio si perdeva.

## VOCE 03, LE DUE POPOLAZIONI

Scritta dentro `docs/guardie.md`, sezione "LE DUE POPOLAZIONI". Il 17
contava le guardie censite che scorrevano i sorgenti e avevano gia' un
cardinale; il 79 contava, su tutti i 704 file di prova, quelli che
scorrevano senza cardinale. Denominatori diversi, 243 contro 704.

**Come si evita che ricapiti**: ogni numero scritto nel registro dice su
quale insieme e' contato, nella stessa riga. Un numero senza il suo
denominatore non entra piu' in quel documento.

## VOCI 04, 05, 06 E 07, LE TRE REGOLE

Scritte in `CLAUDE.md`, sezione "Protocollo delle guardie", e in cima a
`docs/ordini/RIPRESA.md`.

- **Regola A**: una guardia nasce rossa. La prova del rosso e' parte dello
  scrivere la guardia, e l'innesto si verifica col grep **prima** di leggere
  l'esito. Quando il rosso non scatta, si cambia la grandezza misurata, mai la
  soglia.
- **Regola B**: chi tocca una zona coperta da una guardia la vede rossa PRIMA
  di metterci mano, e aggiorna la data nel registro. Se non diventa rossa,
  quella guardia non copre piu' la zona, e la prima cosa da riparare e' lei.
- **Regola C**: ogni difetto nominato in un rapporto e' attribuito alla voce
  che l'ha causato, oppure porta scritto **PROVENIENZA IGNOTA** per esteso.

### Le prove del rosso di quest'ordine

| guardia | innesto | esito |
| --- | --- | --- |
| `ogni_guardia_dichiara_quanto_guarda` | una guardia nuova che scorre `lib` senza cardinale | rossa, la nomina |
| `ogni_guardia_dichiara_quanto_guarda`, cardinale proprio | la migrazione stessa, 32 su 90 pretese | rossa, per davvero |
| `ogni_guardia_dichiara_quanto_guarda`, elenco deroghe | un nome rimesso nell'elenco vuoto | rossa |
| `sorgentiDiCartelle` | filtro portato a `.dartVUOTO` | rossa, chi ci passa cade |
| `cardinaleMinimo` fuori dal corpo di una prova | insieme svuotato, guardia che chiama da `main()` | rossa **col messaggio**, che prima si perdeva |

Ogni innesto e' stato verificato col grep **prima** di leggere l'esito.
