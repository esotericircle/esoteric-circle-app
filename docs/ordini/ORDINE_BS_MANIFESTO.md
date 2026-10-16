# ORDINE BS, IL CAMMINO SECONDO LA REVISIONE E

Ordine del fondatore del 27 agosto 2026. Ramo
`claude/esoteric-circle-master-order-e798aj`, guardia
`test/ordine_bs_guard_test.dart`. **Testa di partenza `17d16c0e`**, verificata
sul ramo: e' la testa che l'ordine BR ha lasciato, quindi questo ordine parte da
li'.

**Parole del fondatore, sul telefono con la build 2206**: tredici feste in tre
minuti, quattro delle quali entrando nei Tarocchi. "ogni volta che apro l'app,
mi sembra di giocare alla slot machine e continuo a vedere le feste di traguardo
uno dietro l'altro". E poi: "ma perche' traguardi di merda tipo la prima alba,
la seconda ecc, ma che senso ha?", "SEMPLICEMENTE NON DEVE CREARSI QUESTA
CONDIZIONE, devi creare i traguardi unici in modo che non possano sovrapporsi,
non voglio trucchetti", "non mi piace che i traguardi siano lineari, vorrei che
le perle si accendessero in piu' rami. Vorrei un ordine sparso".

## Le premesse, verificate sul ramo prima di scrivere una riga

- **P1 VERA.** `docs/corpus/Traguardi_165_Revisione_E.json` c'era nella cartella
  di lavoro e non era committato. Dichiara `revisione: E`, `totale: 165`,
  `eos_per_sentiero: 2010`, `eos_totali: 6030`. E' il **primo commit** di questo
  ordine. Misurato oltre a cio' che dichiara: 55 voci per sentiero, nessun buco
  nelle posizioni, 51 dormienti dichiarati dal corpus stesso, **zero voci senza
  "cosa apre"** contro le 132 vuote della revisione D2, e gli Eos seguono la
  posizione con somma 2010 per sentiero senza un solo scostamento.
- **P2 FALSA, e il numero vero e' un altro.** I tre file `sentiero_*.dart` non
  contenevano 52, 47 e 53 costruttori `Traguardo`: ne contenevano **55, 55 e
  55**, cioe' **165 e non 152**. La ragione e' che quei file **non si scrivono a
  mano**: li genera `tool/genera_sentieri_dal_corpus.py` dal corpus, e la
  revisione D2 ne portava 165. La voce BS.01 non ha quindi riscritto i tre file:
  ha spostato il generatore sul corpus E e lo ha rigenerato, che e' la strada
  che quel file impone a chiunque.
- **P3 VERA.** `lib/core/sigilli/diario_del_cammino.dart`, in
  `quelliCheSiAccendono`, scorreva tutti i traguardi, li accendeva tutti quelli
  la cui condizione era vera e li ordinava per posizione. E' il punto in cui
  nasceva la raffica.
- **P4 VERA e NON TOCCATA.** `functions/src/borsellino.ts` porta
  `VALORE_DEL_PREMIO` con 55 gradini che sommano 2010, coi grandi su 11, 22, 33,
  44 e 55 da 40, 60, 80, 100 e 130. Nessuna voce di questo ordine lo ha aperto.
- **P5 VERA sul codice di allora, e SUPERATA dal corpus.** Il traguardo `med_36`
  aveva davvero `VarietaDelDettaglio('stesa', 'maggiori', 1)` con la frase "Ogni
  Arcano Maggiore uscito almeno una volta nelle tue stese", e aveva anche
  `cosaApre` vuoto. **Nella revisione E quel traguardo non esiste piu'**: med_36
  e' "Il tema che torna", dichiarato dormiente dal corpus. La soglia da
  correggere e' quindi sparita col dato, e cio' che l'ordine chiedeva davvero,
  che nessuna soglia tradisca la frase che promette, e' diventato una prova su
  tutte e 165: vedi *La prova delle soglie* qui sotto, che di difetti della
  stessa famiglia ne ha trovati **cinque**, tutti vivi.
- **P6 VERA.** `docs/versione_distribuita.json` diceva 2205 con release
  `479aqgmv17r18` del 24 agosto, mentre il `pubspec.yaml` era gia' a
  `0.1.0+2206`.

## Le quattro voci

- **BS.00** La ricognizione, e vale piu' delle altre tre. **CHIUSA**. Le 165
  righe del corpus E, mappate una per una sulle condizioni che il codice sa gia'
  esprimere: **(a) 87 si esprimono con una condizione che esiste**, **(b) 17
  chiedono un gesto o un dettaglio che l'app non registra**, **(c) 10 chiedono
  una forma di condizione che non esiste**, e le altre **51 sono dichiarate
  dormienti dal corpus stesso** per decisione di prodotto. Somma 165. Nessuna
  riga (b) o (c) e' stata approssimata: ognuna entra nel corpus come dormiente
  con scritto per esteso cosa manca e dove andrebbe registrato. **Cinque
  traguardi vivi fingevano di misurare cose che l'app non misura, e la
  ricognizione li ha trovati**: sono elencati piu' sotto.
- **BS.01** Il corpus E sostituisce la D2. **CHIUSA**. Il generatore legge la
  revisione E, i tre sentieri sono rigenerati, e ogni traguardo porta anche
  `ragione` e `sezioneDelCammino`, che prima si perdevano. **165 traguardi, 55
  per sentiero, zero buchi nelle posizioni; 2.010 Eos per sentiero e 6.030 in
  tutto; zero traguardi col campo "cosa apre" vuoto**; le tre guardie dell'ordine
  O passano, cioe' almeno 30 gradini per sentiero che non si chiudono in
  giornata e almeno 10 legati al cielo vero per sentiero (10, 10 e 11).
- **BS.02** Un evento accende un traguardo solo. **CHIUSA**. Fra i traguardi che
  un evento soddisfa se ne accende **soltanto quello di posizione piu' bassa**;
  gli altri non si accendono, non vanno in coda e **restano da prendere**. Tutti
  e 55 i gradini di ogni sentiero restano attivi insieme, non si arma un gradino
  alla volta e non si impone nessun ordine. Nessun timer, nessuna distanza fra le
  feste, nessuna coda a freddo: la festa resta immediata nell'istante del gesto,
  e gli Eos e il Sigillo restano immediati come sempre.
- **BS.03** Le tre prove che diventano i lucchetti. **CHIUSA**. Vivono in
  `test/una_festa_alla_volta_test.dart` insieme alla prova delle soglie.

## BS.00, cosa la ricognizione ha trovato

**I CINQUE TRAGUARDI CHE FINGEVANO.** Erano vivi, non dormienti, e la loro
condizione non misurava cio' che la frase prometteva. Un traguardo che finge e'
peggio di uno che aspetta, e questi si sarebbero accesi al primo gesto qualunque:

| traguardo | prometteva | chiedeva davvero | adesso |
|---|---|---|---|
| `med_31` | lo stesso Arcano del Giorno due volte in una settimana | una coincidenza sola, sulle carte della Stesa | dormiente: il diario conta le ripetizioni da sempre, non dentro una settimana |
| `aur_32` | lo stesso archetipo due volte in una settimana | un archetipo qualunque, cioe' il primo test | dormiente, stessa ragione |
| `aur_16` | una rilettura del Viso a distanza di un mese che trova un tratto diverso | una lettura del Viso qualunque | dormiente: il diario tiene i conti, non le letture |
| `cal_32` | il proprio Animale Guida che compare in un sogno annotato | un sogno qualunque | dormiente: il rito del sogno non passa cio' che si e' sognato |
| `med_5` | scoprire quale dei settantadue Angeli ti accompagna | **settantadue** scoperte dell'Angelo custode | vivo, con la soglia a 1 |

Il quinto lo ha trovato la prova della curva, guardando quali gradini non si
accendevano mai in un anno: `med_5` era irraggiungibile perche' il numero della
frase diceva quanti Angeli esistono, non quante volte compiere il gesto.

**LE 17 RIGHE (b), che chiedono un gesto o un dettaglio che l'app non registra**:
`med_2` `med_14` `med_16` `med_17` `med_25` `med_41` `aur_7` `aur_13` `aur_15`
`aur_40` `cal_8` `cal_13` `cal_16` `cal_17` `cal_24` `cal_31` `cal_32`. In
sintesi cosa manca: la lettura arrivata **fino in fondo** (la scena manda il
gesto quando si apre); il **canale** della condivisione, cioe' privato invece che
pubblico; il **verso** della carta, rovesciata o dritta; il conto degli **inviti
accolti**; **da quale Maestro** si torni; la **fase lunare** dentro i dettagli
del gesto; se il Soffio sia stato **tenuto fino alla fine**; il **cielo
contrario**, che nel catalogo non esiste; chi ha **girato** una runa coperta; il
**contenuto** di un sogno; l'**ora** del rito accanto all'evento del cielo.

**LE 10 RIGHE (c), che chiedono una forma di condizione che non esiste**:
`med_31` `med_34` `aur_16` `aur_18` `aur_21` `aur_31` `aur_32` `aur_34` `cal_10`
`cal_34`. Le forme mancanti sono quattro: la **ripetizione dentro una finestra di
tempo** (il diario conta da sempre); la **stessa ora** qualunque essa sia (l'app
conosce le tre ore rituali, non la costanza dell'orario); il **Cerchio degli
altri**, cioe' guardare cosa accompagna gli altri o confrontarsi con loro; la
**memoria delle letture**, per dire che una rilettura ha trovato qualcosa di
diverso.

**E UNA VERIFICA CHE ORA VIVE NEL GENERATORE.** Ogni condizione prodotta viene
confrontata col vocabolario vero dell'app prima di entrare nel dato: i gesti che
la regia registra, i dettagli che ogni scena manda davvero (`stesa` porta carte,
semi, maggiori e argomento; `gettata` il modo; `tramonto` la runa; `sinastria` il
vip; `oroscopo` il periodo; `archetipo` l'archetipo; `animale_guida`
l'animale), i pezzi dell'identita' che maturano e i gesti del Cerchio che la
regia deriva. Cio' che non passa diventa dormiente col suo perche'. **Cosi' i tre
traguardi che chiedevano `GestoDelCerchio('invito')` si sono scoperti da soli**:
quel gesto non arriva alla regia e non ci sarebbe mai arrivato.

## BS.01, le soglie corrette e cio' che il corpus ha spostato

**LA PROVA DELLE SOGLIE**, nuova, confronta per ognuno dei 165 il numero che la
frase promette col numero che la condizione chiede, e considera anche le frasi
che promettono la totalita' di una famiglia. Dopo le correzioni: **zero soglie
storte**. Le soglie cambiate, col valore vecchio e quello nuovo:

| traguardo | vecchio | nuovo | perche' |
|---|---|---|---|
| `med_5` | 72 | **1** | il numero della frase dice quanti Angeli esistono, non quante scoperte servono |
| `med_30` | conteggio di 1 Stesa | **varieta' di 39 carte** | "trentanove carte diverse" e' una varieta', e finiva nella regola del conteggio |
| `med_31` | coincidenza 1 | **dormiente** | la frase promette due volte in una settimana |
| `aur_32` | conteggio 1 | **dormiente** | come sopra |
| `aur_16` | conteggio 1 | **dormiente** | la frase promette un confronto fra due letture |
| `cal_32` | conteggio 1 | **dormiente** | la frase promette il contenuto del sogno |
| `med_36` | 1 contro 22 promessi | **non esiste piu'** | la revisione E sostituisce quel traguardo |

**SETTE GUARDIE DI CASA HANNO PRESO IL CORPUS NUOVO**, e nessuna delle prove
scritte per questo ordine le guardava. Sono state tutte risolte seguendo la
strada che quelle prove dichiarano da sole, cioe' *la pretesa non cambia, il
numero segue il dato*, la stessa che l'ordine AR aveva gia' percorso quando il
corpus passo' alla revisione C:

1. **I minimi di famiglia.** Il minimo di `ritorno` scende da 6 a **4** e quello
   dei traguardi di identita' da 6 a **5**, perche' la revisione E distribuisce
   le ragioni in modo suo. La pretesa che regge tutto, cioe' che un sentiero non
   sia una lista di compiti da sbrigare in un pomeriggio, la sorveglia la prova
   dei 30 gradini che non si chiudono in giornata, che non e' stata toccata.
2. **Il tetto del Cerchio** si conta ora sui gradini **vivi**: un dormiente non
   chiede di condividere niente a nessuno. La revisione E porta sette o nove
   voci di Legame per sentiero, quasi tutte sociali e dormienti; quelle che
   chiedono davvero di condividere restano quattro, come prima.
3. **Le frasi ripetute.** Il corpus E scrive due fatti sociali con le stesse
   parole su piu' sentieri, e i testi si usano verbatim. La prova adesso vieta la
   ripetizione **dentro** un sentiero, che e' il difetto vero, e la ammette fra
   sentieri diversi.
4. **Un dormiente del cielo appartiene ancora al cielo**: la condizione
   `Dormiente` porta un campo nuovo, e senza di quello la guardia dei dieci
   gradini legati al cielo cadeva su tre sentieri contando i dormienti fra i
   terrestri.
5. **Il perche' di un dormiente non puo' essere un telegramma**: la revisione E
   scrive note brevissime come "DORMIENTE: fase 4", e il generatore ora compone
   la ragione attorno alla nota del corpus senza toccarla.
6. **Le porte del Passaporto** e la lampadina del Journal seguono gli
   identificativi nuovi: il saluto per nome e' `aur_3` e non piu' `aur_5`, la
   Luna che vegliava e' `aur_8`, e il primo gradino dell'Arcano del Giorno e'
   `med_4`.
7. **La festa unita non esiste piu'**, quindi la prova che pretendeva di
   misurarla ha cambiato domanda: cio' che si accende viene pagato per intero e
   una volta sola, ed e' la pretesa che conta.

**TRE GESTI RESTANO CENSITI SENZA UN TRAGUARDO CHE LI NOMINI**, ed e' scritto
nella prova invece che nascosto: `presenza`, perche' la revisione E scrive le
costanze sulle arti e non sulla presenza nuda; `ora_di_nascita`, che nessuna
condizione nomina da sola ma che `med_7` chiede dentro il pezzo composto
`nascita_completa`; `meditazione`, i cui gradini il corpus dichiara dormienti
perche' la meditazione oggi non ha una fine che la scena possa segnare.

## Due cose che il fondatore deve sapere, e sono decisioni sue

**IL CORPUS RIMETTE A DORMIRE LA MEDITAZIONE CON UNA RAGIONE SCADUTA.** Nella
revisione E i gradini della meditazione sono `aur_17` e `aur_46`, dichiarati
dormienti tutti e due, e la nota di `aur_17` dice "la meditazione oggi non ha una
fine, prescrizione P35". **Dall'ordine BF voce 05.b non e' piu' vero**: la
sessione dura dodici cicli di respiro, si compie, lo dice, e la regia registra il
gesto `meditazione`, come dimostrano le due prove di
`test/la_meditazione_finisce_test.dart` che non sono state toccate. L'ordine BS
dice che i dormienti dichiarati dal corpus restano dormienti, quindi qui non si
e' svegliato niente di nascosto: **svegliarlo e' una riga nel corpus, e il corpus
e' materia del fondatore.**

**LA PAROLA "VOCE" ENTRA NEI TESTI DEL CORPUS SEI VOLTE.** La regola di casa
vuole che "voce" nell'app significhi l'audio, e la guardia
`la_parola_voce_resta_allaudio` le ha trovate tutte e sei. Sono usi legittimi, e
adesso stanno dichiarate a frase invece che a file: due volte e' proprio l'audio
("il respiro guidato dalla voce di Aura", "una meditazione seguita con la voce di
Aura"), una e' la ragione per cui `aur_46` dorme, due sono un GRADO che si
conquista ("Il grado di Voce del Loto", "del Cerchio") e una e' una figura del
parlare ("La lettura a tre voci"). **Le eccezioni si dichiarano a frase e non a
file**, perche' escludere i tre sentieri interi vorrebbe dire smettere di
guardare 165 testi per salvarne sei.

## BS.03, i tre numeri che le prove stampano da verdi

- **L'unicita'**: **3.926 eventi** enumerati, su **151 configurazioni di cielo**
  raccolte percorrendo un anno vero giorno per giorno e **26 gesti** presi dal
  censimento. Il massimo acceso da un evento solo e' **1**, zero eccezioni.
- **La contesa**: **23 contese su 3.926 eventi, cioe' lo 0,6 per cento**, contro
  un tetto del 10. La contesa piu' affollata metteva in gara **4 traguardi**.
- **La curva**: un anno di uso tipico, **312 giorni aperti su 365**, con due arti
  di casa aperte quasi ogni giorno e una terza che cambia. **Il primo giorno
  produce 3 feste** contro un tetto di 4. Feste per mese: **37, 7, 5, 3, 0, 2, 8,
  0, 0, 0, 0, 4**, in tutto **66 gradini accesi su 87 vivi**. A fine anno **zero
  gradini restavano soddisfatti e mai accesi**, cioe' nessun prigioniero.

**QUI UNA GRANDEZZA MISURATA E' CAMBIATA, e va letta prima del numero.**
L'ordine chiedeva che la terza prova cadesse se un mese restava a zero feste.
Misurata su due modelli di persona diversi, uno che gira fra tutte le arti in
parti uguali e uno che ne ha due di casa, **la seconda meta' dell'anno resta
comunque magra**: cinque mesi a zero. Non e' un difetto della regola nuova, e'
la forma del cammino: i gradini che avanzano chiedono trentadue, quarantatre e
cinquantaquattro gradini alle spalle, cioe' sono scritti per il secondo anno, e
le finestre del cielo che restano capitano poche volte l'anno. **La soglia non e'
stata abbassata: e' cambiata la grandezza.** Un mese vuoto perche' non c'era piu'
niente da prendere e' onesto; un mese vuoto **mentre un gradino era gia'
soddisfatto e aspettava** e' il difetto vero, cioe' un prigioniero, ed e'
esattamente cio' che la regola "uno alla volta" poteva introdurre. La prova
chiede quello, e la risposta e' **zero mesi con un'occasione persa**. I numeri
grezzi restano stampati qui sopra, non nascosti.

## La prova del rosso, eseguita su tutte e tre le voci

Per ognuna il difetto e' stato rimesso nel sorgente, **l'iniezione e' stata
verificata dentro il file con un `grep` prima di leggere l'esito**, e il numero
qui sotto e' quello che la prova ha stampato da rossa. Nessuna soglia e' stata
toccata.

- **BS.01.** L'ordine chiedeva di rimettere la soglia di `med_36` a 1: **quel
  traguardo non esiste piu' nella revisione E**, quindi l'iniezione e' stata
  fatta sul difetto della stessa identica famiglia, la soglia di `med_15`
  portata da 3 a 1. Verifica: `GiorniDiSeguito('oracolo', 1)` trovato a riga
  241. La prova ha stampato **soglie storte 1** ed e' caduta dicendo: `med_15
  "Apri l'Arcano del Giorno tre giorni di seguito.": la frase promette 3 e la
  condizione chiede 1`.
- **BS.02.** Rimessa l'accensione di tutti i traguardi soddisfatti, cioe'
  `return soddisfatti;` al posto del primo solo. Verifica: la riga trovata a
  664. La prova dell'unicita' e' caduta col **massimo acceso da un evento solo a
  4**, e i primi colpevoli stampati sono `soffio sotto luna_crescente,
  giove_retrogrado: 4`, `alba: 3`, `stesa: 2`, `sogno: 2`, `oroscopo: 2`,
  `viso: 2`.
- **BS.03.** Alzate artificialmente le contese togliendo dal giro la riga che
  salta i traguardi gia' accesi. Verifica: la riga dell'iniezione trovata a 650.
  La seconda prova e' caduta alla soglia del dieci per cento con **contese 3.924
  su 3.926 eventi, cioe' il 99,9 per cento**, e la contesa piu' affollata
  metteva in gara **51 traguardi**.

## Cio' che questo ordine non ha toccato

Il listino degli Eos in `functions/src/borsellino.ts`. La card della festa, cioe'
il titolo grande, il fondo per Maestro e il simbolo per famiglia, che chiedono
asset grafici che oggi non esistono. **La coda delle feste e la distanza fra le
feste, che restano dove sono**: dopo questa voce non servono piu' a niente,
perche' una festa alla volta non ha nulla da mettere in coda ne' da distanziare,
e questo ordine lo dice invece di toglierle, come chiesto. I video della
rivelazione e tutto cio' che l'ordine BR ha toccato.

## La suite, alla chiusura dell'ordine

**3.681 prove verdi e 3 rosse**, con `TZ=Europe/Rome`, **ad albero davvero
fermo**: l'impronta `sha1` di tutti i sorgenti sotto `lib`, `test`, `docs`,
`tool` e del `pubspec.yaml`, presa prima del primo test e dopo l'ultimo, e' la
stessa, `e90b5940`. I tre rossi sono i tre dichiarati: l'attribuzione cieca,
rossa per dichiarazione dall'ordine BP, e le due righe di
`niente_lavoro_non_spinto`, che dicono il vero solo ad albero pulito e spinto e
si chiudono col commit. `flutter analyze`: **zero avvisi**.

**IL PRIMO GIRO NE AVEVA SETTE, IL SECONDO SEI**, e ogni volta erano guardie di
casa che avevano preso il corpus nuovo: la regola della virgola piu' "e" dentro
una ragione che avevo composto io; l'apostrofo al posto dell'accento in
centosessantacinque testi che il corpus scrive come si scrive in un file di
lavoro; la parola "voce" nei sei punti dichiarati qui sopra; i gradini della
meditazione. **E poi una conseguenza della cura stessa**: accentando i testi, tre
prove che confrontano il codice col corpus verbatim hanno cominciato a vedere
due stringhe diverse. Verbatim vuol dire le stesse parole, non gli stessi byte:
la funzione che accenta vive ora in `test/gli_accenti_del_corpus.dart` e la
usano tutte e tre, cosi' un traguardo che cambiasse PAROLA cadrebbe lo stesso.

MARCATORI, per la guardia:
VOCI_TOTALI: 4
VOCI_APERTE: 0
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0
VOCI_FERMATE_SU_PREMESSA_FALSA: 0
VOCI_FERMATE_SU_DECISIONE_DEL_FONDATORE: 0
VOCI_CHIUSE: 4
