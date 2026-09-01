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

**P5. "1,3 e' il massimo consentito dal sistema." FALSA.** Era scritto cosi' dentro
`test/screenshot_capture_test.dart`: 1,3 e' il tetto che
questa app si e' data. I massimi veri dei sistemi stanno alla voce 08.

## VOCE 01, LA QUADRATURA

Le categorie ora sommano al totale, e la somma e' scritta.

| categoria | quante |
| --- | ---: |
| Guardie che passano da una porta comune | 105 |
| Guardie con un cardinale proprio dichiarato | 28 |
| Guardie che non scoprono nessun insieme di file | 111 |
| **Somma** | **244** |
| **Guardie secondo la definizione** | **244** |

La terza categoria **non e' un debito**: sono guardie che sorvegliano
un'assenza, una fotografia, un elenco che non vive in `lib`, e per loro un
cardinale sui file Dart non vorrebbe dire niente.

**E la quadratura non e' solo scritta, e' sorvegliata.** La guardia nuova
`test/il_registro_delle_guardie_quadra_test.dart` pretende tre cose: che le
categorie sommino, che la somma sia il numero di righe che il registro elenca
davvero, e che **nessuna riga menta** sul cardinale della guardia che nomina.
La seconda pretesa e' quella che conta: **un registro puo' quadrare
benissimo su numeri inventati**, e le cifre in cima le riscrive chiunque
mentre le duecentoquarantaquattro righe no.

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

## VOCE 04, VOCE 05, VOCE 06 E VOCE 07: LE TRE REGOLE

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


## VOCE 08, LA SCALA DEL TESTO, DICHIARATA E DECISA

**Quello che l'app fa oggi.** `lib/app.dart` stringe la scala del testo fra
**0,9 e 1,3**, sopra il Navigator, quindi vale anche per le rotte spinte sopra
il guscio.

**Quello che fanno i sistemi.** Android porta la misura del testo fino al
doppio dalle impostazioni di accessibilita'; iOS, con le misure di
accessibilita', arriva a circa il triplo. **Questi due numeri non si leggono in
questo repository e vanno riverificati sul dispositivo**: li scrivo perche' la
decisione ha bisogno di un ordine di grandezza, non perche' li abbia misurati
qui.

**La premessa falsa, corretta dove stava scritta.** Dentro
`test/screenshot_capture_test.dart` c'era la frase "al massimo consentito dal
sistema, che e' 1,3". **1,3 non e' il massimo di nessun sistema**: e' il tetto
che questa app si e' data. **Chiamare "massimo del sistema" il proprio tetto e'
il modo in cui una scelta si traveste da vincolo, e smette di essere
discussa.**

**La decisione, presa e motivata: si tiene un tetto, e si alza a 1,6.**

- *Perche' un tetto e non l'intera scala di sistema.* A tre volte il testo la
  ruota dello zodiaco, le cornici delle carte e i busti dentro il loro cerchio
  non si allargano: non e' un problema di impaginazione, e' direzione
  artistica, e la regola del mezzobusto del 6 agosto 2026 cadrebbe su ogni
  ritratto tondo.
- *Perche' 1,6 e non 1,4.* Copre per intero la scala standard di iOS e il suo
  primo passo di accessibilita', e il passo piu' grande della misura standard
  di Android con margine. **Il pubblico di quest'app il testo grande lo imposta
  davvero**, quindi il tetto va tenuto alto, come chiedeva l'ordine.
- *Quando sale.* **Solo quando il corredo e' pulito a 1,6, non prima.** Alzarlo
  su schermate che si rompono non ripara niente: sposta il guasto dagli occhi
  di chi prova a quelli di chi usa. Finche' resta a 1,3, quel numero e' il
  debito, non la scelta, e la ragione sta scritta accanto al numero.

## VOCE 09, LE QUARANTADUE SCHERMATE, PER FAMIGLIA DI CAUSA

**Il numero della premessa e' esatto: 42 catture su 182 si rompevano a 1,3.**
Poco meno di una su quattro, come diceva l'ordine.

**Ne restano DICIOTTO alla chiusura di quest'ordine, quattordici dopo l'ordine CN. Ventiquattro sono riparate qui**, e non una per una: le
famiglie di causa erano quattro, e ognuna si e' chiusa in pochi punti.

| famiglia | cos'era | quante ne ha chiuse |
| --- | --- | ---: |
| A, il testo in una `Row` che non puo' cedere | icona o busto di misura fissa accanto a un testo che cresce, senza `Flexible` | 12 |
| B, il contenitore di misura fissa | colonna dentro un'altezza decisa a monte | in corso |
| C, chi misura senza la scala | `TextPainter` che misura alla scala uno un testo dipinto a 1,3 | 8 |
| D, la riga di comandi | tre gesti affiancati che non ci stanno piu' | 6 |

**L'ipotesi dell'ordine era mezza giusta, e vale la pena dire quale meta'.**
L'ordine diceva "un contenitore di misura fissa che contiene testo". Vero per
la famiglia B. **La famiglia piu' numerosa era pero' orizzontale**: un testo
dentro una `Row`, accanto a un'icona che non si stringe, senza nessun modo di
andare a capo. E' lo stesso difetto girato di novanta gradi, e cercarlo solo in
verticale ne avrebbe lasciata fuori piu' di meta'.

### La famiglia C, che e' la scoperta di quest'ordine

Un `TextPainter` senza `textScaler` misura il testo **alla scala uno,
sempre**. Se quella misura serve a decidere uno spazio, una riserva o un corpo
di carattere, **il numero che ne esce descrive un testo che nessuno vedra'
mai**.

Trovata in un pomeriggio in cinque punti che non si conoscono fra loro: la
riserva del Consulto del Cielo, il corpo del titolo che non si spezza, il metro
delle cifre del borsellino, lo scarto del bersaglio dell'aiuto nella striscia
del giorno, e due nella barra del Santuario. **Quando lo stesso errore compare
in cinque posti lontanissimi, non e' distrazione: e' che mancava la regola.**

Adesso la regola c'e', e ha la sua guardia:
`test/chi_misura_il_testo_usa_la_scala_test.dart`. Ogni `TextPainter` di `lib`
passa la scala, **oppure sta in un elenco di quindici deroghe, ognuna col suo
perche' scritto per esteso**: chi disegna su una tela a geometria fissa, una
ruota, un sigillo, una cartolina da condividere, deve tenere il testo dentro la
figura, e li' la scala di sistema romperebbe il disegno.

Una di quelle deroghe merita di essere letta: la barra del Santuario misura
**pesi relativi** fra voci che hanno tutte lo stesso stile, quindi la scala le
moltiplica tutte per lo stesso numero e le proporzioni restano quelle. **E' una
misura senza scala che e' giusta**, e distinguerla dalle altre quattro e' cio'
che separa una regola da un divieto.

### Il vincolo del mezzobusto, e cosa deve guardare il fondatore

Nessuna delle correzioni tocca un busto o un ritratto tondo: sono tutte
`Flexible` su testi, un `Wrap` su tre tasti, e cinque misure che ora ricevono
la scala. **La regola del 6 agosto 2026 non e' stata avvicinata.**

**Queste tre vanno guardate da Mauro sul telefono, col testo grande**, perche'
sono le uniche dove la cura cambia cio' che si vede e non solo dove sta:

1. **La bolla della chat, "Chiedi anche agli altri"**: a testo grande la frase
   ora va a capo sotto i due busti invece di uscire dal bordo.
2. **La stesa dei tarocchi, i tre gesti**: a testo grande "Taglia", "Mischia" e
   "Suono" scendono su due righe invece di stare affiancati.
3. **Il Consulto del Cielo**: l'emblema ora e' piu' piccolo a testo grande,
   perche' la riserva della riga sotto e' calcolata sul testo vero.

## VOCE 10, IL CORREDO A SCALA MASSIMA DENTRO LO SBARRAMENTO

**Il terzo cancello esiste.** Dopo le prove e dopo la suite del server,
`tool/sbarramento.sh` gira il corredo con `SCALA_DEL_TESTO=1.3`.

- **Le cadute portano il prefisso `SCALA 1,3:`.** Senza, una riga fra i rossi
  accettati metterebbe a tacere quella stessa cattura **anche alla scala uno**,
  e la deroga per chi ha il testo grande diventerebbe una deroga per tutti.
- **Il corredo ha il suo cardinale**: se il giro monta meno di centocinquanta
  schermate, l'archivio non si produce. Un giro che non monta niente non trova
  difetti, e passerebbe per verde.
- **Le diciotto righe stanno in `tool/rossi_accettati.txt`, una per
  schermata**, ognuna col percorso e il numero di punti che sfora.
- **Quell'elenco puo' solo accorciarsi**: il controllo delle righe di troppo fa
  cadere l'archivio se un nome resta scritto mentre quella cattura ha smesso di
  rompersi.

Tre prove nuove dentro `test/lo_sbarramento_distingue_i_rossi_test.dart`, e
tutte e tre viste rosse con l'innesto verificato prima:

| prova | innesto | esito |
| --- | --- | --- |
| una rottura a scala massima ferma l'archivio | il prefisso tolto dallo sbarramento | rossa |
| il prefisso non vale anche alla scala uno | lo stesso innesto | rossa |
| un corredo che non monta niente non passa | il cardinale tolto | rossa |

## VOCE 11, QUANTE NE RESTANO E IN QUANTI ORDINI SI CHIUDONO

**RESTANO QUATTORDICI SCHERMATE ROTTE AL TESTO MASSIMO, su centottantadue.**

**Erano diciotto quando quest'ordine si e' chiuso, e sono diventate quattordici la
sera stessa**, poi quattordici, quando l'ordine CN voce 12 ha portato la decisione
sulla card da condividere. **Il numero di stamattina non si cancella**: era
vero quando e' stato scritto, e toglierlo toglierebbe la misura del cammino.
Una su dodici, contro una su quattro di stamattina.

**Si chiudono in DUE ordini, e non in uno, perche' due delle cause non sono
questioni di impaginazione ma decisioni di prodotto.**

**Ordine prossimo, quindici schermate.** Sono quattro punti di famiglia B, e la
cura e' la stessa gia' usata oggi: far cedere l'altezza dove e' decisa a monte.

| punto | schermate | quanto sfora |
| --- | ---: | --- |
| `onboarding_screen.dart:1760` | 6 | 10 punti a destra |
| `app_permission.dart:165` | 2 | 134 punti in basso |
| `oroscopo_screen.dart:1202` | 2 | 5 punti in basso |
| `sinastria_gallery_screen.dart:694` | 1 | 6 punti in basso |
| `custodia_del_cielo_step.dart:123` | 1 | 2 punti in basso |
| tre catture che pretendono una posizione in punti | 3 | non traboccano: la pretesa va rifatta in proporzione |

**~~Ordine successivo, tre schermate.~~ GIA' CHIUSO, la sera stessa.** La
domanda era: una card che esce dal telefono e va guardata altrove deve seguire
la misura del testo di chi la crea? **Il fondatore ha risposto no**, ordine CN
voce 12 del 1 settembre 2026: la card si disegna alla scala uno, sempre,
perche' e' un'immagine guardata da altri sui loro schermi, e cuocerci dentro
un'impostazione personale di accessibilita' produrrebbe card di proporzioni
diverse per ogni utente. Le tre schermate sono chiuse.

**E poi c'e' il tetto.** Le quattordici di oggi si contano a 1,3, che e' il tetto
di adesso. **Alla decisione della voce 08, cioe' a 1,6, il conto va rifatto da
capo**: quello che a 1,3 sfora di 2 punti, a 1,6 ne sfora molti di piu', e
schermate che oggi passano potrebbero non passare. Il numero delle schermate
rotte a 1,6 **non e' noto**, e sara' il primo lavoro dell'ordine che alza il
tetto.
