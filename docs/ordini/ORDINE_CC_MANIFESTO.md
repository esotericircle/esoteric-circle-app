# ORDINE CC, IL GIRO DEL FONDATORE SUL TELEFONO

Ordine del fondatore del 29 agosto 2026, nove voci, arrivato in due pezzi. Le
prime sei sono i rilievi che ha dato guardando l'app dal telefono la sera del 29
agosto, le ultime tre sono i debiti in coda che ha approvato nello stesso
scambio. Guardia `test/ordine_cc_guard_test.dart`.

Porta le tre regole degli ordini precedenti, irrigidite:

- **REGOLA ZERO.** Il testo di quest'ordine non e' affidabile e l'Architetto non
  e' affidabile: ogni affermazione si verifica sul ramo prima di usarla,
  compresi i nomi dei file e i numeri.
- **REGOLA UNO.** Non ci si ferma, si risolve, e ogni scelta si motiva.
- **REGOLA DUE.** Qui dentro non c'e' nessuna opinione dell'Architetto: le
  parole del fondatore sono verbatim, i fatti sono misurati con la fonte
  dichiarata.

## Le nove voci

- **CC.01** I cinque testi del tutorial si sostituiscono. **CHIUSA.** Quattro testi su cinque sono suoi e sono a video; il quinto resta quello di prima per sua decisione, perche' aspetta il lavoro sui doni. La macro categoria Cabala di Caligo e' diventata Numerologia.
- **CC.02** La freccia dei fumetti e' poco visibile. **CHIUSA.** Il contrasto della freccia sul velo passa da 1,24 a 9,33, contro una soglia dichiarata di 3,0.
- **CC.03** L'animazione di riflessione dell'Oroscopo si rifa' da capo. **CHIUSA.** I dodici segni corrono grandi, la corsa rallenta e si ferma sul tuo, il segno cresce e la scena si dissolve sul responso.
- **CC.04** Il lampo fra le schermate diventa nero, e vale ovunque. **CHIUSA.** Quarantadue rotte sotto una legge sola, due veli trasparenti dichiarati fuori, e il lampo dei Tarocchi non e' piu' bianco.
- **CC.05** Censimento globale delle dimensioni dei caratteri. **CHIUSA.** Ventidue arti censite: sei mostravano il responso a 16 punti e adesso tutte lo mostrano a 18, la misura del responso dei Tarocchi.
- **CC.06** La Sinastria VIP, nove rilievi. **CHIUSA.** Tutti e nove: le mappe dicono dove sei, i fili sono corde, la bolla e' tecnica per il 17 per cento invece che per il 36, e i transiti dicono di chi sono.
- **CC.07** Il catalogo delle citta' fuori dall'Italia. **CHIUSA.** I luoghi fuori dall'Italia passano da 3.108 a 32.408 e i paesi con una sola citta' da 116 a 49, senza nessuna fonte nuova: la potatura stava in casa nostra.
- **CC.08** L'attribuzione vera degli inviti. **CHIUSA.** Il Cerchio chiede a chi arriva se lo ha invitato qualcuno, e il codice entra con un tocco dagli appunti; le tre difese del server sono ancora tutte e tre in piedi.
- **CC.09** La misura del ritorno delle persone. **CHIUSA.** Cinque gesti contati per giorno, zero profili, zero pacchetti nuovi, il consenso chiesto una volta con due pulsanti uguali e la policy allineata nella stessa voce.

VOCI_TOTALI: 9
VOCI_CHIUSE: 9
VOCI_APERTE: 0
VOCI_FERMATE_SU_PREMESSA_FALSA: 0
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0
VOCI_FERMATE_SU_DECISIONE_DEL_FONDATORE: 0

## LE AFFERMAZIONI DI QUESTO ORDINE CHE HO TROVATO FALSE

Dieci premesse verificate sulla testa del ramo, commit `20879fa6`, prima di
toccare una riga. **Otto vere, due vere a meta', e una affermazione di CC.08
superata dai fatti.**

| # | l'ordine dice | esito | cosa ho trovato davvero, e come |
| --- | --- | --- | --- |
| P1 | la lettera libera e' CC | **vera** | in `docs/ordini/` ci sono solo CA e CB; CB ha 5 voci su 5 chiuse e zero aperte; `ORDINE_CC_MANIFESTO.md` non esisteva |
| P2 | i cinque testi vivono in `cinqueFumetti` | **vera** | `lib/features/onboarding/primo_approdo.dart:77` |
| P3 | cerchi gialli e responso senza transizione | **VERA A META'** | il responso compare di botto, confermato: `setState(() => _fase = _FaseDelConsulto.responso)` senza dissolvenza. **Ma i cerchi non sono piu' nudi dall'ordine BZ voce 06**: ogni disco porta il glifo del suo pianeta. Restano dischi dorati, e il rilievo del fondatore resta valido sull'effetto |
| P4 | entrando nei Tarocchi il lampo e' BIANCO | **vera** | `lib/features/tarot/stesa_handoff.dart:29`, `Colors.white`, montato da `stesa_tre_carte_screen.dart:947`. **Nasce dall'intro cinematografica**, che finisce in bianco pieno: il velo copriva il taglio fra il video e l'app |
| P5 | le dimensioni delle descrizioni non sono uniformi | **vera** | il responso dei Tarocchi usa `lettura()`, 18 punti. Contro 43 usi di `lettura` in tutta `lib/`, ce ne sono 227 di `corpo()` e `didascalia()`, tutti e due a 16: l'Account ne ha 34 e zero `lettura`, la Sinastria 29 contro 2, l'Oroscopo 10 contro 3 |
| P6 | esiste il testo "non si finge di sapere" | **vera** | `lib/core/synastry/testi_della_sinastria.dart:369`, `notaOraIgnota` |
| P7 | i transiti dicono "il suo Mercurio" senza il nome | **vera** | `AspettoDiSinastria.fatto` in `cielo_della_sinastria.dart:253` compone `${suo.ilSuo} ${suo.nome} in ... ${tuo.alTuo} ${tuo.nome}`: nessun nome di persona, in nessun punto |
| P8 | 11.546 luoghi, 3.108 fuori, 241 paesi, 116 con una citta' | **vera, al numero** | contati su `assets/data/luoghi.csv`: 11.546 righe, 8.438 italiane, 3.108 estere, 241 paesi, 116 con una sola citta'. Francia 13, Svizzera 3, Albania 1, esattamente come dichiarato |
| P9 | nessuna attribuzione dell'installazione | **vera** | zero Install Referrer, zero Dynamic Links. **Lo dichiara il codice stesso**, in `bonus_della_condivisione.dart:78` |
| P10 | nessuno strumento misura il ritorno | **vera** | zero `firebase_analytics`, zero `logEvent`, in `lib/` e in `pubspec.yaml` |
| CC.08 | `riscattaLInvito` e' scritta ma NON distribuita | **SUPERATA DAI FATTI** | e' distribuita dal 28 agosto 2026, ordine BY: ACTIVE, revisione `riscattalinvito-00001-suj`. Il manifesto di BX diceva il vero quando fu scritto, poi la callable e' stata distribuita dal PC del fondatore |

## CC.01, i cinque testi del tutorial

**CHIUSA.** La voce e' stata ferma il tempo che serviva, ed e' l'ordine stesso
ad averlo chiesto: "se il testo mente, FERMATI e riportalo al fondatore invece
di riscriverlo da solo: questi testi sono suoi". Il fondatore ha deciso il 29
agosto 2026, e le sue decisioni sono qui sotto insieme alle misure che le hanno
provocate.

### LE TRE DECISIONI DEL FONDATORE, e cosa hanno cambiato

**1. Il fumetto 2 si allinea, in tutte e due le direzioni.** Le sue parole
diventano "Medora: Astrologia, Cartomanzia, Destino. Caligo: Rune, Rituali,
Numerologia. Aura: Chakra, Energia, Archetipi", che e' l'app per Medora e per
Aura, e l'app che si muove per Caligo. **I tre pilastri di Aura non si sono
toccati**: restano Chakra, Energia e Archetipi, e l'arte Meditazione resta
dentro Energia col suo nome.

**2. La macro categoria di Caligo passa da Cabala a Numerologia.** Parole sue:
"la macro categoria di Caligo Cabala diventera' Numerologia e all'interno ci
sara' anche la Cabala, questo per una richiesta dei fondatori e credo abbiano
ragione."

**3. Il fumetto 5 perde la parola "arti".** Diventa "IL CAMMINO E GLI EOS",
"Qui in alto: il tuo profilo, gli eventi cosmici speciali e IL TUO BORSELLINO:
guadagna e spendi EOS ogni giorno per acquistare nuove esperienze". I maiuscoli
sono suoi e non si normalizzano.

**E il fumetto 4 resta quello di prima, per sua decisione e non per
indecisione.** La sua frase, "creati incrociando il Cielo di oggi e la tua
Carta natale", resta come la vuole, e **nel prossimo ordine si costruisce
l'incrocio nei doni che oggi non ce l'hanno**. Fino ad allora a video resta il
testo attuale, perche' metterla oggi sarebbe una promessa falsa, e la guardia
che sorveglia quel fumetto resta al suo posto.

### IL CAMBIO DI NOME, punto per punto

**Otto punti toccati in tutto**, tre nel codice che l'app esegue e cinque nelle
prove:

| dove | cosa era | cosa e' |
| --- | --- | --- |
| `lib/core/maestro/maestro.dart`, `domainArts` di Caligo | `Rune, Rituali, Cabala` | `Rune, Rituali, Numerologia` |
| `lib/core/arts/art_catalog.dart`, il titolo della sezione | `Cabala` | `Numerologia` |
| `lib/features/onboarding/primo_approdo.dart`, il fumetto 2 | Runologia, Simbologia, Ritualistica | Rune, Rituali, Numerologia |
| `test/art_catalog_test.dart` | 19 nomi e 4 chiavi di widget | rinominati |
| `test/consulta_header_test.dart` | la frase del dominio | rinominata |
| `test/proprietario_delle_arti_test.dart` | il commento che elenca le sezioni | rinominato |
| `test/screenshot_capture_test.dart` | la chiave della sezione nella cattura | rinominata |
| `lib/features/maestri/widgets/domain_pillars.dart` | il commento dei tre pilastri | rinominato |

**Cosa il titolo tocca davvero, verificato e non supposto.** Nessuna memoria
sul telefono, nessun feature flag e nessuna condizione del cammino usano quel
nome per riconoscere qualcosa, quindi **non c'e' niente da migrare**: lo stato
aperto o chiuso di una sezione vive in una mappa che nasce e muore con la
schermata. **Ma il titolo genera lo slug delle chiavi dei widget**,
`art_section_$slug` e le sue sorelle in `maestro_screen.dart`, e quelle chiavi
le usano cinque punti nelle prove: sono cambiate con lui.

### DUE FATTI CHE RIPORTO INVECE DI RISOLVERE, come l'ordine chiede

**1. Un'arte chiamata Numerologia esiste gia', e sta proprio li' dentro.**
E' `numerology`, "Numerologia del Destino", e viveva nella sezione Cabala fin
da prima di questa decisione. Dal 29 agosto **la sezione e l'arte portano lo
stesso nome**: uno e' il ripiano, l'altra e' una delle quattro arti che ci
stanno sopra. Non sono due nomi per la stessa cosa, ma e' una cosa che devi
vedere, perche' a video si legge "Numerologia" due volte, come titolo di
sezione e dentro il titolo di una card.

**2. Nella sezione non c'era nessuna Cabala da mettere dentro, e il fondatore
ha deciso che ce ne fosse una.** Riportato il fatto: le quattro arti li' dentro
erano Numeri Ricorrenti, Numerologia del Destino, Human Design e Cosmic
Wrapped, perche' **l'Albero della Vita e i settantadue nomi dello Shem erano
usciti dalla Demo per una sua decisione precedente**, e con loro era uscito
tutto cio' che si chiamava Cabala.

**La sua risposta, il 30 agosto 2026:** "la Cabala diventa un'arte di Caligo
nella categoria Numerologia". Fatto: la sezione porta adesso **cinque arti** e
non quattro, e la nuova si chiama Cabala, `kabbalah`, in arrivo alla Fase 2.

**Non e' il ritorno dell'Albero della Vita ne' dei settantadue nomi**, che
restano fuori dalla Demo per la sua decisione precedente: e' una card sola che
nomina la tradizione. La fase e' la Fase 2 perche' e' quella che quella stessa
decisione aveva nominato per il Journal. **Il numero della sezione segue il
dato**: due prove che contavano quattro adesso contano cinque, in tutte e due
le viste, quella della Demo e quella della persona.


### LE QUATTRO VERIFICHE, una per una

**1. Fumetto 1, "solo arti, pratiche e tradizioni accreditate". VERO, e il
numero e' sette.** Sette schermate portano il pannello **"Fonti e metodo"**, che
dichiara alla persona la tradizione e i suoi limiti: Angeli custodi, Test
Archetipo, Costellazione del viso, Animale guida, Gettata di rune, Runa del
tramonto, Cielo di stanotte. Quattro arti non ce l'hanno: Oroscopo, Stesa a tre
carte, Sinastria VIP e Carta natale, che pero' dichiara a video "Calcolata sulle
effemeridi", cioe' il metodo senza il pannello. **Il testo non mente**: dice che
nulla e' inventato, e infatti ogni arte poggia su una tradizione documentata.
Resta un debito, quattro pannelli mancanti, che non e' oggetto di questa voce.

**2. Fumetto 2, "risponde a te, con la tua data e la tua ora". VERO.** La chat
riceve un `NatalContext` a ogni turno, e dentro ci sono il segno solare, il
segno lunare, **l'Ascendente**, il numero della vita e la fase lunare di
nascita. L'Ascendente esiste solo per chi ha dato l'ora: e' la prova che l'ora
entra davvero nella risposta. Il Maestro non riceve la data e l'ora in cifre, ma
cio' che quelle due cose producono, ed e' la stessa cosa detta bene.

**IN PIU', e non me lo aveva chiesto nessuno: le tre terne di arti del fumetto
2 NON coincidono con quelle che l'app mostra altrove.** L'ha trovato una
guardia che esisteva gia', quella che vieta di scrivere a mano il dominio di un
Maestro.

| Maestro | il fumetto del fondatore dice | l'app dice, in `Maestro.domainArts` |
| --- | --- | --- |
| Medora | Astrologia, Cartomanzia, **Divinazione** | Astrologia, Cartomanzia, **Destino** |
| Caligo | **Runologia, Simbologia, Ritualistica** | **Rune, Rituali, Cabala** |
| Aura | **Energia, Meditazione, Equilibrio** | **Chakra, Energia, Archetipi** |

Il testo resta il suo, come l'ordine impone, e la guardia porta l'eccezione
scritta col suo perche'. **Allineare l'app alle sue parole, o le sue parole
all'app, e' una decisione sua**: finche' non la prende, il tutorial dice le sue
e il resto dell'app dice quelle del codice.

**3. Fumetto 4, "cinque doni creati incrociando il Cielo di oggi e la tua Carta
natale". FALSO PER TRE DONI SU CINQUE.**

| dono | da cosa nasce davvero |
| --- | --- |
| Alba | **Cielo di oggi per Carta natale**, come dice il testo |
| Soffio | **Cielo di oggi per Carta natale**, transiti veri sulla carta |
| Arcano | **da nessuno dei due**: `ArcanoDelGiorno.di(DateTime giorno)` prende un Arcano Maggiore dal solo giorno, ed e' la STESSA carta per tutti |
| Runa del tramonto | fase lunare e segno solare: cielo si, carta natale no |
| Sigillo del sogno | segno della Luna di stanotte e Luna di nascita: cielo si, carta natale no |

**4. Fumetto 5, "guadagna e spendi EOS ogni giorno per acquistare nuove
esperienze e arti". FALSO SULLA PAROLA "ARTI", e questo e' il punto che l'ordine
mi ha chiesto di misurare di nuovo.**

Il listino del server, `PREZZI_DEL_RISCATTO` in `functions/src/borsellino.ts`,
permette di comprare **cinque cose sole**, e sono tutte una dose in piu' di
un'arte che la persona ha gia':

| cosa si compra | quanti Eos |
| --- | --- |
| una domanda in piu' a un Maestro | 80 |
| un approfondimento in piu' | 60 |
| una gettata di rune in piu' | 60 |
| un confronto di Sinastria in piu' | 150 |
| una stesa completa | 250 |

**Nessuna arte dormiente si apre con gli Eos**, e nessuna funzione Coming soon
si sblocca pagando: quelle si accendono con i feature flag, non col borsellino.
**Il fatto non e' cambiato dal giro precedente**, dove l'avevo gia' misurato per
l'ordine CB voce 02.

**La parola "esperienze" e' vera**, perche' una stesa completa o un confronto in
piu' sono esattamente esperienze. **La parola "arti" no.**

### COSA E' A VIDEO ADESSO

**Quattro testi su cinque sono suoi**, e una prova li custodisce carattere per
carattere. Il quinto, cioe' il quarto fumetto, resta quello dell'ordine CB
finche' i doni non nascono davvero dall'incrocio.

**L'eccezione della guardia dei domini non e' piu' una scappatoia, e' pagata.**
Il file del tutorial esce dalla regola "un dominio non si scrive a mano"
perche' quel testo e' del fondatore e non si compone da `domainArts`: comporlo
vorrebbe dire che domani un cambio nel codice riscrive le sue parole senza che
lui lo sappia. In cambio **una prova nuova pretende che il fumetto contenga i
tre domini carattere per carattere**, e se uno dei due cambia senza l'altro
cade.

### UNA CONSEGUENZA CHE NON AVEVO PREVISTO, misurata e non taciuta

**Cambiare il dominio di Caligo ha cambiato l'istruzione di sistema di tutti e
tre i Maestri.** Se ne e' accorta la guardia delle impronte, che era li'
apposta: `l'impronta dell'istruzione coincide con quella registrata` e' andata
rossa nella suite intera.

**Perche' tutti e tre e non solo Caligo**, misurato e non supposto: ogni
Maestro porta dentro la propria istruzione **le arti degli altri due**, nella
riga "Le arti degli altri due Maestri del cerchio", quindi il dominio di uno
vive dentro l'istruzione di tutti. Le stringhe passano da 7.250, 7.398 e 7.723
caratteri a 7.256, 7.404 e 7.726.

**Le impronte nuove sono registrate e le vecchie sono scese nello storico**, con
la data e con cio' che e' successo, che e' esattamente cio' che quella guardia
pretende: "non e' vietato cambiarla, e' vietato cambiarla in silenzio".

**L'attribuzione cieca NON e' stata rifatta**, e si consegna dichiarandolo. Era
gia' dichiarata non valida su questa istruzione per decisione del fondatore
dell'ordine BY voce 04, quindi resta rossa e accettata nel registro dei rossi;
ma da oggi lo e' anche per una seconda ragione, cioe' che la stringa su cui i
sei giri furono misurati non esiste piu'. Rifarla vuole il provider AI a
runtime, e le frasi dei Maestri sono materia dell'Architetto per l'ordine BZ
voce 03.

### Il rosso, dimostrato due volte

**Primo, sull'allineamento.** Rimesso `domainArts: 'Rune, Rituali, Cabala'` in
`maestro.dart`, verificato col grep che nel file non restasse nessun
`Rituali, Numerologia` **prima** di leggere l'esito: la prova nuova e' diventata
rossa dicendo "il tutorial e il codice dicono domini diversi, e chi legge trova
due Cerchi: [Caligo: Rune, Rituali, Cabala]". Rimesso, verde.

**Secondo, sulle parole del fondatore.** Tolta la parola "speciali" dal quinto
fumetto, verificato col grep che non ci fosse piu' **prima** di leggere
l'esito: la guardia dei testi e' diventata rossa dicendo "il testo del fumetto
5 e' stato riscritto: queste parole sono del fondatore e si usano come sono".
Rimessa, verde.

### Le anteprime

`docs/preview/primo-approdo-2.png` e `primo-approdo-5.png`, rigenerate a 360
punti e guardate. Il secondo fumetto entra nella carta senza sfondare, il
quinto punta la barra in alto dove stanno davvero il profilo, gli eventi
cosmici e il borsellino con il suo conto. Rigenerate anche
`dominio-caligo.png` e `dominio-caligo-aperto.png`, dove la sezione adesso si
legge Numerologia.

### DUE DIFETTI CHE HA TROVATO IL FONDATORE GUARDANDO LE ANTEPRIME

**1. "Il titolo della categoria Numerologia e' molto piu' piccolo degli altri
titoli di categoria."** Vero, e la causa non era la lunghezza della parola. Il
titolo vive dentro un `FittedBox` che lo rimpicciolisce invece di spezzarlo a
meta' parola, e nella riga di una sottocategoria senza arti vive c'era anche
uno `Spacer`: **i due si dividevano lo spazio libero a meta'**, e il titolo
veniva scalato giu' mentre accanto restava vuoto. Adesso il gruppo di sinistra
sta dentro un `Expanded` e la freccetta gli sta dopo, e i due stacchi passano
da 8 punti a 4.

**Misurato prima e dopo, sui dodici titoli dei tre domini**: prima **quattro
erano rimpiccioliti**, il peggiore a **12,4 punti su 21,0**, cioe' il 41 per
cento in meno; adesso **zero**, tutti e dodici a 21,0. Il difetto non era di
Numerologia: era di ogni sottocategoria senza arti vive, e con "Cabala", sette
lettere, non si vedeva. **Una prova nuova misura la grandezza vera a cui ogni
titolo viene dipinto**, `FittedBox` compreso, e cade se uno si rimpicciolisce
mentre gli altri no.

**2. "La bolla taglia la testa ai Maestri che stanno sotto."** Vero, e
guardato: il fumetto dei Maestri li tagliava tutti e tre al collo. Il corpus
chiede quel fumetto SOTTO il carosello; a 360 punti non ci sta ne' sotto ne'
sopra, e la vecchia regola sceglieva **il lato con piu' spazio**, cioe' sopra,
scendendo sulla parte alta delle carte, che e' dove stanno le facce.

**Adesso, quando non ci sta da nessuna parte, vince il lato che il corpus
chiede.** Un ritratto si riconosce dalla faccia: se la carta deve sovrapporsi
per forza, che si sovrapponga sulle vesti e non sulle teste. Misurato a 360x797:
il bersaglio va da 262 a 536, la carta comincia a **531**, cioe' cinque punti
sopra il bordo basso del bersaglio.

**La guardia che avrebbe dovuto vederlo guardava un francobollo.** La finestra
era gia' quella di un telefono, ma il bersaglio era un riquadro di 200 per 60
messo al centro: con un bersaglio basso la carta ci sta comodamente sotto e la
prova diceva verde. Adesso il bersaglio della prova e' alto **274**, come il
carosello vero a 360 punti, e la prova pretende che la carta non copra la meta'
alta di cio' di cui parla.

### La frase di accettazione della voce CC.01

**Rivedi il tutorial dal menu' utente: il secondo fumetto dice i domini
esattamente come li dice l'app, e il quinto non promette piu' di comprare arti.
Entra nel Dominio di Caligo: la macro categoria si chiama Numerologia.**
## CC.02, la freccia dei fumetti

**Rilievo del fondatore, verbatim:** "la freccia delle bolle sono poco
visibili".

**LA GRANDEZZA CHE DESCRIVE LA VISIBILITA', dichiarata: il rapporto di
contrasto fra il colore della freccia e cio' che le sta dietro.** Non e' un
numero inventato per l'occasione: e' la misura che le linee guida di
accessibilita' usano per gli oggetti grafici necessari a capire una scena, e la
**soglia dichiarata e' 3,0 a 1**, quella che quelle linee guida pretendono per
un oggetto non testuale.

**Perche' il contrasto e non l'area.** Una freccia grande e scura resta
invisibile, una piccola e chiara si vede. Il difetto era esattamente questo: il
triangolo era dipinto col colore della CARTA, un viola scuro, sopra un velo
quasi nero.

| misura | prima | dopo | soglia |
| --- | --- | --- | --- |
| contrasto sulla palette di Medora | **1,24** | **9,33** | 3,0 |
| contrasto sulla palette di Aura | 1,24 | 8,99 | 3,0 |
| contrasto sulla palette di Caligo | 1,24 | 9,39 | 3,0 |
| altezza della freccia | 12 punti | 16 punti | |

**Cosa e' cambiato**: la freccia e' oro pieno, lo stesso oro del bordo della
carta, con un alone scuro sotto che la stacca anche sopra la parte chiara di
una scena illuminata.

**Il rosso, dimostrato**: rimesso `colore: palette.surface`, verificato col grep
che l'iniezione fosse avvenuta, la prova e' diventata rossa dicendo "la freccia
non e' piu' dipinta in oro pieno".

### La frase di accettazione della voce CC.02

**Riapri il tutorial dal menu' utente: dal secondo fumetto in poi la freccia
d'oro punta la cosa di cui parla, e si vede da lontano.**

## CC.03, la corsa dello zodiaco

**Rilievo del fondatore, verbatim:** "in Oroscopo, L'ANIMAZIONE DI RIFLESSIONE
FA SCHIFO, tutti quei cerchietti gialli non si capisce cosa siano e cmq poi i
risultati compaiono di botto".

**I sei tempi che ha chiesto, e dove stanno nel codice:**

| # | cosa ha chiesto | dove |
| --- | --- | --- |
| 1 | una schermata nuova sopra tutto | `CorsaDelloZodiaco`, montata FUORI dallo `Scaffold` |
| 2 | i simboli dello zodiaco grandi che si succedono | l'emblema prende il 52 per cento della larghezza, e i dodici passano tutti |
| 3 | la corsa si ferma sul segno dell'utente | il segno arriva dalla schermata, che lo ha gia' in mano |
| 4 | una frase evocativa, tipo "Medora sta..." | `FrasiDellaCorsa`, **PROVVISORIE e marcate come tali** |
| 5 | il segno si ingrandisce | da 1,00 a 1,35, con l'alone che cresce con lui |
| 6 | dissolvenza, e si torna al responso | la scena resta 700 millesimi SOPRA il responso e si dissolve |

**LE MISURE, prese sul movimento e non sulla presenza:** segni diversi visti
**12**, cambi di segno **16**, la corsa si ferma dopo **2,2 secondi**, il segno
cresce **da 1,00 a 1,16** nei primi 400 millesimi, e l'opacita' della scena a
fine dissolvenza e' **0,00**.

**I due arricchimenti che mi sono preso**, e il fondatore mi autorizza a
prendermeli:
- **la corsa DECELERA invece di fermarsi di colpo**: il passo cresce da 70 a 260
  millesimi. Una ruota che si ferma secca sembra rotta, una che rallenta dice
  che si e' fermata li' per una ragione;
- **il segno che cresce porta un alone che cresce con lui**: senza, e' solo
  un'immagine piu' grande; con l'alone e' il segno che si accende.

### TRE DIFETTI TROVATI DALLE ANTEPRIME, che nessuna prova cercava

1. **La scena stava dentro la colonna dell'eroe**, dove un `Positioned.fill` non
   ha significato: Flutter lo ha detto con un errore di dati di genitore.
2. **Poi stava dentro il corpo dello `Scaffold`**, e restavano scoperte la
   freccia Indietro, il cuore delle preferite e mezza schermata sotto un velo
   al 94 per cento. Adesso e' opaca e sta sopra lo `Scaffold`; il cuore, che
   fluttua in uno strato ancora piu' alto, si ritira da se' per la via che la
   barra delle arti usa gia'.
3. **La festa di un traguardo copriva la dissolvenza.** La festa e' una rotta
   spinta sopra tutto e partiva nell'istante in cui il responso nasce: chi
   leggeva il suo primo oroscopo vedeva la scena sparire sotto una festa invece
   che scoprire il responso. Adesso la festa aspetta che la scena se ne sia
   andata.

Le tre anteprime sono in `docs/preview/corsa-zodiaco-1-gira.png`,
`-2-si-ferma.png` e `-3-dissolvenza.png`.

### La frase di accettazione della voce CC.03

**Apri l'Oroscopo e tocca Interroga il cielo: i dodici segni corrono grandi
sopra tutto, rallentano, si fermano sul tuo, lui cresce, e la scena si dissolve
scoprendo il responso. Niente compare di botto.**

## CC.04, il lampo nero a ogni cambio di schermata

**Rilievo del fondatore, verbatim:** "quando entro nella funzionalita' dei
tarocchi c'e' un flash bianco che introduce la schermata, voglio che questo
flash sia nero e che ci sia sempre ad ogni cambio schermata. niente deve
apparire di botto."

**IL CENSIMENTO DELLE TRANSIZIONI, coi numeri:**

| | quante |
| --- | --- |
| rotte trovate in `lib/` | **44** |
| gia' sotto una transizione dichiarata | **0** |
| portate sotto la legge unica | **42** |
| veli trasparenti lasciati fuori, dichiarati | **2** |

**Nessuna rotta era sotto una transizione dichiarata**: quarantadue prendevano
quella di sistema, che su Android e' una salita dal basso e su iOS uno
scorrimento laterale. Due comportamenti diversi, nessuno dei due scelto.

**I due veli lasciati fuori, col perche'**: la festa del benvenuto e la
celebrazione di un traguardo non sono cambi di schermata, sono veli
TRASPARENTI che si posano sopra la scena che resta a video sotto di loro. Farli
passare dal nero spegnerebbe la schermata che stanno decorando. **La prova non
si fida della dichiarazione**: verifica che tutti e due portino ancora
`opaque: false`, e il giorno che uno diventa opaco cade.

**Il lampo dei Tarocchi**, `HandoffVeil`: era `Colors.white` perche' l'intro
cinematografica finisce in bianco pieno e il velo copriva il taglio fra il video
e l'app. **Ma l'intro si vede una volta sola all'avvio, mentre quel velo si
vede a OGNI ingresso nella stesa**: nove volte su dieci copriva un taglio che
non c'era. Adesso e' lo stesso nero del Passaggio del Cerchio.

**Riduci Movimento**: la dissolvenza resta, sparisce il respiro. Chi ha tolto il
movimento non ha chiesto che le schermate compaiano di botto.

**Il rosso, dimostrato**: rimesso un `MaterialPageRoute` nel Rito dell'Alba,
verificato col grep, la prova e' diventata rossa nominando il file.

### La frase di accettazione della voce CC.04

**Entra e esci da qualunque schermata: si passa sempre da un nero breve, e in
nessun punto dell'app compare piu' un lampo bianco.**

## CC.05, il censimento delle dimensioni

**Rilievo del fondatore, verbatim:** "volgio un censimento globale per la
dimensione dei caratteri delle descrizioni di tutto tranne della home [...]
prendi come base le dimensioni dei caratteri del responso dei tarocchi. non
posso avere un app dove ogni funzionalita' ha font con dimensioni diverse, dove
alcuni responsi sono piccoli e poco leggibili ed altri ok."

**LA MISURA DI RIFERIMENTO NON SI SCEGLIE, SI PRENDE.** E' quella del responso
dei Tarocchi: `TypographyTokens.lettura()`, **18 punti, interlinea 1,55**. La
prova la legge dal token invece di scriverne il numero, cosi' il giorno che il
responso dei Tarocchi cambia misura cambiano anche tutte le altre.

### IL CENSIMENTO, arte per arte

Ventidue arti censite, la home e il Santuario fuori per ordine del fondatore.
**Sedici erano gia' alla misura del responso, sei no.**

| arte | punto del codice | prima | dopo |
| --- | --- | --- | --- |
| Calendario del cielo | `calendario_degli_eventi_screen.dart` riga 121 | corpo, 16 | **lettura, 18** |
| Carta natale | `cosmic_passport_screen.dart` riga 602, il significato di ogni fatto | corpo, 16 | **lettura, 18** |
| Consiglio dei Maestri | `ask_maestri_screen.dart` riga 721, la sintesi | corpo, 16 | **lettura, 18** |
| Consiglio dei Maestri | `ask_maestri_screen.dart` riga 890, il colpo d'occhio di ogni Maestro | corpo, 16 | **lettura, 18** |
| Gemello astrale | `rivelazione_del_gemello.dart` riga 134, l'annuncio | corpo, 16 | **lettura, 18** |
| Meditazione | `meditation_screen.dart` riga 257, il responso | corpo, 16 | **lettura, 18** |
| Sigillo di intenzione | `sigillo_intenzione_screen.dart` riga 356, l'intenzione riformulata | body(16) a mano | **lettura, 18** |
| Sigillo di intenzione | `sigillo_intenzione_screen.dart` riga 371, il perche' della via | corpo, 16 | **lettura, 18** |
| Chi ti ha invitato | `riscatta_l_invito.dart` riga 64 | didascalia, 16 | **lettura, 18** |

**E tutte e nove sono passate dalla porta unica del testo narrato**,
`ParagrafiDiLettura`: un `Text` diretto nel ruolo lettura e' una seconda porta,
e la regola dei paragrafi non lo raggiunge. Lo dice una guardia che esisteva
gia', ed e' diventata rossa appena ho cambiato la misura senza cambiare la
porta: **l'ha trovato lei, non io**.

**I titoli gialli: contati, non toccati.** Il fondatore ha detto che "vanno bene
in generale, ma controllali": sono **119** i punti che scrivono la misura di un
titolo a mano. Restano come sono, e una prova tiene quel numero perche' non
cresca.

**Le misure finali:** 22 arti censite, **zero** senza la misura del responso;
45 testi da leggere per intero, **zero** fuori misura.

**Il rosso, dimostrato**: rimesso `corpo()` sull'annuncio del Gemello astrale,
verificato col grep che nel file non restasse nessuna `lettura()`, la prova e'
diventata rossa nominando l'arte.

### La frase di accettazione della voce CC.05

**Apri il Consiglio dei Maestri, la Carta natale, la Meditazione e il Sigillo:
i loro testi si leggono grandi come il responso dei Tarocchi, non piu' piccoli.**

## CC.06, i nove rilievi della Sinastria

Tutti e nove vengono dallo stesso messaggio del 29 agosto 2026, dato guardando
l'app sul telefono con otto schermate a corredo. **Nessuno e' stato escluso.**

### a) LE MAPPE DELLE DISTANZE

**Verbatim:** "quando sono vicini, non si capisce visivamente dove si trovano,
nemmeno la nazione e magari inserisci i nomi delle capitali o capoluoghi o
citta' piu' grandi come riferimento, ma anche le citta' dove vivono".

**Cosa c'era**: i contorni delle nazioni, due pallini e una linea. **Zero
nomi.** Due pallini su una linea non dicono dove sei.

**Cosa c'e' adesso**: il nome della tua citta' e quello della sua sui due
punti, piu' fino a **sei citta' di riferimento** dentro l'inquadratura. I nomi
vengono dal catalogo che l'app ha gia' nel bundle, `assets/data/luoghi.csv`,
**ordinato per popolazione decrescente**: le prime che cadono nell'inquadratura
sono le piu' grandi che si vedono. Nessuna rete, nessuna chiave, nessun
riquadro grigio offline.

**Le due cure che l'occhio chiede**: un riferimento troppo vicino a uno dei due
punti non si scrive, perche' i nomi si sovrapporrebbero; e nessun nome esce dal
riquadro, perche' sulla mappa stretta meta' dei nomi cadrebbe fuori.

### b) LE LINEE DELL'ANIMAZIONE

**Verbatim:** "le linee tracciate devono partire da un punto del cerchio e
finire in un altro punto del cerchio, mentre adesso arrivano a meta' e sembrano
troncarsi Senza motivo".

**Aveva ragione, e la causa era una riga.** I due capi stavano su due cerchi
CONCENTRICI: il suo sul bordo, il tuo su un cerchio interno largo il **62 per
cento**. Il filo finiva nel vuoto a meta' strada, e nessuno poteva sapere che
quel punto interno fosse un punto. Adesso e' una corda: parte da un punto del
cerchio e arriva a un altro punto dello stesso cerchio.

### c) LA BOLLA ERA TROPPO TECNICA

**Verbatim:** "parla per 3/4 di transiti e il resto lo dedica alla risposta
vera e propria che interessa all'utente, ma deve essere il contrario".

**Misurato sul testo vero, prima e dopo:**

| | prima | dopo |
| --- | --- | --- |
| corpo della bolla | 366 caratteri | 349 |
| di cui tecnici | **131, il 36 per cento** | **58, il 17 per cento** |

**Cosa e' uscito**: i gradi di scarto dall'angolo esatto, che erano la parte
piu' tecnica di tutta la bolla. **Non sono spariti**: vivono nella pastiglia
toccabile sotto il responso, dove chi vuole quell'aspetto lo tocca. **Il nome
dell'aspetto resta**, breve e fra parentesi, perche' e' la prova che il numero
non e' inventato.

**E due difetti di punteggiatura, trovati misurando:** si leggeva "vi accorgete
l'uno dell'altro.: il suo Marte", con un punto prima dei due punti, e "mezzo
mondo da salvare..", con due punti di fila.

### d) IL PARAGRAFO DELL'ATTUALITA'

**Verbatim:** "vorrei un paragrafo in piu' di testo che riguardi l'attualita'
del vip".

L'attualita' era una subordinata dentro la frase di presentazione. Adesso e' un
paragrafo suo, cucito da **quattro frasi PROVVISORIE** dichiarate come tali in
`TestiDellaSinastria.attualitaProvvisorie`: il corpus e' materia del fondatore,
e le riscrivera' come ha fatto coi cinque fumetti.

**Il vincolo del 28 agosto vale dentro quelle frasi**: girano attorno alla
cronaca pubblica e professionale e non aggiungono niente di loro. **Per chi non
c'e' piu' il paragrafo non esiste**, e una prova lo pretende: non si fa cronaca
su chi non puo' smentirla.

### e) IL TONO GOLIARDICO

**Verbatim:** "in generale il testo deve essere goliardico."

**Misurato: il corpus e' gia' scritto in quel registro.** Le 287 righe che
compongono il responso sono divise in dieci famiglie, e le quattro che formano
il corpo della bolla portano gia' la battuta: le 21 aperture ("come lasciare
una finestra aperta accanto a un camino acceso"), le 32 letture del cielo ("il
che e' comodo e pericoloso insieme"), le 96 presentazioni, le 25 stoccate ("uno
dei due non sa nemmeno che esisti").

**Quello che NON era goliardico era la clausola tecnica**, "a 1,4 gradi
dall'angolo esatto", che spezzava il tono in mezzo alla battuta. **E' uscita
con la voce c).** Non ho riscritto nessuna riga del corpus: quelle sono sue.

### f) L'INFOGRAFICA SUBITO DOPO

**Verbatim:** "subito dopo questa bolla voglio la bolla della infografica con
le barre affinita', intesa, scintille, ecc."

Le barre stavano in fondo, e fra la bolla e loro c'erano **cinque blocchi**: la
nota, il cielo del giorno, il giorno piu' acceso, la mappa della distanza e le
pastiglie degli aspetti. Adesso stanno subito sotto, e una prova legge la
posizione dei tre blocchi nel sorgente invece di crederci.

### g) LE DUE RIGHE, E VIA IL "NON SI FINGE"

**Verbatim:** "eliminalo! al suo posto, ma in ogni responso inserisci 2 righe
con Ora di Nascita: e Luogo di Residenza: e se non si conosce si mette
semplicemente "SCONOSCIUTO" dopo i due punti".

Fatto alla lettera, e le due righe ci sono in OGNI responso, anche quando i due
dati si conoscono: prima il silenzio voleva dire "si sa", e nessuno poteva
esserne sicuro.

**Il testo del "non si finge" era in DUE posti, non uno.** Il secondo, dentro
la riga del cielo del giorno, lo ha trovato l'anteprima: si leggeva tre righe
sotto la riga nuova che gia' dice SCONOSCIUTO.

**Due guardie difendevano il disclaimer**, e sono state riscritte per difendere
la stessa cosa nella forma nuova: che l'app dichiari di non conoscere l'ora. Lo
fa in ogni responso, invece che in tre righe e solo quando manca.

### h) I TRANSITI DICONO DI CHI SONO

**Verbatim:** "il suo mercurio o la sua venere di Chi? deve esserci il nome:
"il mercurio di Fedez e' in sestile con la tua venere". questo difetto e'
ancora peggiore nella sinastria con 2 vip dove non si capisce a quale vip si
riferisce".

**Adesso**, con un VIP: *il Mercurio di Fedez in sestile alla tua Venere*. Fra
due VIP: *il Mercurio di Fedez in sestile alla Venere di Chiara*, che e'
esattamente il caso che ha chiamato "ancora peggiore". Nella bolla che si apre
toccando uno dei tre transiti la riga sta da sola e prende il verbo, come
l'aveva scritta lui: *il Mercurio di Fedez e' in sestile con la tua Venere*.

**Il lato di chi guarda resta "il tuo"**, e non e' una svista: e' la sua frase.

**Il rosso, dimostrato**: tolto il nome dal calcolo degli aspetti, verificato
col grep, la prova e' diventata rossa dicendo "aspetti calcolati 5, senza il
nome del personaggio 5".

### i) I CARTIGLI DELLA CARTA INGRANDITA

**Verbatim:** "quando ingrandisco la Carta del vip, i testi nei cartigli della
carta spariscono".

**Aveva ragione, e la causa e' una regola del progetto.** Gli artwork dei VIP
hanno i cartigli VUOTI, perche' il nome e la data si posano a runtime e un set
solo di immagini vale per tutte le lingue. La carta ingrandita montava
`Image.asset` nudo, cioe' l'arte senza chi la posa. Adesso monta
`VipFramedPortrait`, lo stesso componente che la porta della Sinastria e la
card da condividere usano gia': una porta sola per i cartigli.

### La frase di accettazione della voce CC.06

**Apri una Sinastria VIP: sotto la bolla leggi Ora di Nascita e Luogo di
Residenza, poi subito le barre. I tre transiti dicono il nome del personaggio,
la mappa dice in quali citta' siete, e ingrandendo la carta i cartigli portano
ancora il nome e la data.**

## CC.07, il catalogo delle citta' fuori dall'Italia

**Debito in coda, verbatim:** "che il catalogo copra il mondo abbastanza da non
costringere nessuno a dichiarare un luogo di nascita falso." **Vincolo:** "la
licenza della fonte va letta e dichiarata prima di importare qualunque dato.
L'app e' commerciale a sorgente chiuso." **Prova del rosso obbligatoria**, e
inoltre: verificare il criterio di densita' dell'ordine BB voce 12 e dichiarare
se lo riuso.

### La causa, trovata e non indovinata

Non era una fonte povera: era **una potatura sopra un file gia' potato**.
`tool/genera_luoghi.py`, in `leggi_mondo`, teneva solo i luoghi sopra i
**200.000 abitanti** piu' le capitali. Ma il file da cui legge si chiama
`cities15000.txt` e contiene gia' soltanto i luoghi sopra i **15.000**: la
soglia nostra tagliava via il 90 per cento di cio' che la fonte offriva
gratis.

### Le cinque decisioni che la voce mi ha chiesto di prendere

| cosa | decisione | perche' |
| --- | --- | --- |
| **quale fonte** | la stessa di prima, i dump GeoNames | una fonte nuova vuol dire una licenza nuova da leggere, un formato nuovo da fidarsi e un secondo elenco che puo' divergere da quello che l'app gia' usa. Qui non serviva: il dato c'era gia' e lo stavamo buttando |
| **quanti luoghi per paese** | tutti quelli che la fonte ha | **non e' una scelta nostra su chi merita di esistere**, e' la fonte per intero. Ogni numero per paese sarebbe stato arbitrario, e l'arbitrio si sarebbe visto proprio sui paesi piccoli |
| **quale criterio di densita'** | nessuno, e la soglia sparisce | la potatura era il difetto. Resta il solo filtro della fonte, 15.000 abitanti, che e' scritto nel nome del file |
| **quale peso** | da 413 KB a **1,50 MiB** | il catalogo si legge una volta all'avvio, fuori dal primo fotogramma: misurato, **79 millesimi di secondo** per leggere e indicizzare 40.846 luoghi su questa macchina. Un mega e mezzo dentro un pacchetto e' niente, e ogni luogo che non c'e' e' una carta natale sbagliata |
| **quale licenza** | CC BY 4.0, letta e **dichiarata dentro l'app** | consente l'uso commerciale e non pretende che il codice si apra, ma pretende l'attribuzione. Fino a oggi l'attribuzione viveva in un commento del generatore, cioe' in un posto che nessuno di fuori puo' leggere: **un obbligo assolto dentro casa non e' assolto** |

### Il criterio di densita' di BB.12: verificato, e NON riusato

**Esiste**, ed e' `MappaDellaNazione.densitaMinima = 8` con
`luoghiMinimi`: otto luoghi per grado quadrato, con almeno duecento luoghi.
**Ma risponde a un'altra domanda**: non "il catalogo copre il mondo", bensi'
"questa nuvola di citta' disegna il contorno del suo paese". Usarlo come
criterio di copertura avrebbe escluso il mondo intero, Italia a parte. Quindi
**non lo riuso**.

**Lo tocco pero', e per forza.** BB.12 aveva scritto la sua regola cosi': "se un
domani il catalogo si infittisse su un altro paese, quel paese entrerebbe da
solo". Quel domani e' oggi: col catalogo allargato **quattro paesi nuovi**
superavano il criterio, e la guardia di BB.12 dice di se' stessa "questa prova
non ha occhi" e pretende che chi allarga li **guardi uno per uno**.

**Li ho guardati**, e le immagini sono in `docs/preview/nazione-*.png`:

| paese | luoghi | esito guardato |
| --- | ---: | --- |
| Germania | 1.135 | si riconosce: confine ovest, sud e nord leggibili |
| Regno Unito | 860 | si riconosce: Inghilterra, Galles, cintura scozzese, Irlanda del Nord |
| Paesi Bassi | 251 | una macchia, non un paese |
| Belgio | 223 | una macchia, non un paese |

**`luoghiMinimi` passa da 200 a 500, e il numero non e' scelto per escludere il
Belgio**, che sarebbe l'elenco travestito da regola che BB.12 vieta. E' scelto
sulla geometria, e misurato: **il Belgio riempie l'82 per cento delle celle che
PUO' riempire** su una griglia abbastanza fitta da mostrare una costa, il Regno
Unito il 35, la Germania il 50. Chi riempie quasi tutto cio' che puo' non sta
disegnando una forma, **sta finendo i punti**.

**Belgio e Paesi Bassi non perdono niente**: tornano al contorno vero di
`NazioniDelMondo`, che e' esattamente la strada su cui stavano prima di
quest'ordine. Verificato sul codice, non supposto: `MappaDellaNazione.di`
restituisce per entrambi `nazionePiena`, come prima.

**Una pretesa di BB.12 e' morta col corpus nuovo, e l'ho sostituita invece di
allentarla.** Chiedeva che fra l'Italia e il secondo paese piu' denso
corressero piu' di **cinquanta volte**: era vero solo perche' il catalogo estero
era una spruzzata. Adesso i paesi densi sono tre e le densita' stanno vicine.
Quella pretesa non diceva piu' niente sul mondo, diceva che il catalogo era
povero. Al suo posto si difende **il salto fra l'ultimo che passa e il primo
che non passa**: Regno Unito 11,72 contro Francia 5,44, cioe' **2,2 volte**.

### Le misure, in numeri

| misura | prima | dopo |
| --- | ---: | ---: |
| luoghi in tutto | 11.546 | **40.846** |
| luoghi fuori dall'Italia | 3.108 | **32.408** |
| paesi rappresentati | 241 | 241 |
| paesi con UNA sola citta' | 116 | **49** |
| Francia | 13 | **691** |
| Svizzera | 3 | **95** |
| Albania | 1 | **25** |
| Germania | 45 | **1.135** |
| Regno Unito | 40 | **860** |
| Spagna | 37 | **731** |
| Romania | 15 | **134** |
| Argentina | 21 | **314** |
| peso dell'archivio | 413 KB | **1,50 MiB** |
| tempo di lettura all'avvio | non misurato | **79 ms** |
| fonti dichiarate dentro l'app | 0 | **3** |

### Cosa resta scoperto, detto e non taciuto

**Chi e' nato in un paese sotto i quindicimila abitanti continua a non
trovarlo**, e sceglie il centro vicino. L'unico modo per averli tutti sarebbe
il dump `allCountries` di GeoNames, che scompattato supera il gigabyte: non e'
un asset che si mette dentro un'app. I 49 paesi che restano con una citta' sola
sono microstati e isole, dove quella citta' e' spesso davvero l'unico centro
sopra i quindicimila abitanti.

### Il rosso, dimostrato

Rimessa la vecchia potatura, cioe' `SOGLIA_DEL_MONDO = 200000`, verificato col
grep che nel generatore non restasse nessun `SOGLIA_DEL_MONDO = 15000`
**prima** di leggere l'esito: la prova e' diventata rossa dicendo che "la
vecchia potatura a duecentomila abitanti e' tornata, e con lei i 116 paesi con
una citta' sola". Rimessa la soglia nuova, verde.

**E la prova tiene il conto per paese**, come la voce chiede: otto paesi
guardati uno per uno, coi pavimenti presi dal ramo dopo la rigenerazione. Se
domani qualcuno rigenera il catalogo con una potatura, quei conti scendono e la
prova cade nominando i paesi impoveriti.

### Un difetto trovato guardando, e riparato

La prima cattura del Regno Unito **mostrava il Canada**. Nel catalogo la
capitale inglese si chiama Londra, con London come nome alternativo, e `London`
secco e' quella dell'Ontario: la cattura cercava per nome e prendeva
l'omonima. Adesso cerca col nome **e col paese**. Senza guardare l'immagine
avrei giudicato buona o cattiva la mappa sbagliata.

### La frase di accettazione della voce CC.07

**Nell'onboarding cerca Basilea, Digione, Valona o il paese di tua nonna fuori
dall'Italia: adesso ci sono. E in Impostazioni, Privacy e dati, la riga "Da
dove vengono i numeri" dice chi pubblica i luoghi e con quale licenza.**

## CC.08, l'attribuzione vera degli inviti

**Debito in coda, verbatim:** "il premio piu' alto della condivisione e' quello
dell'invito che porta qualcuno dentro davvero, e vale 60 Eos. Il server sa
pagarlo, ma l'app non sa da quale invito arriva chi la installa. Firebase
Dynamic Links non e' piu' una strada." **Conseguenza scritta da lui:** "oggi
quel premio si riscuote solo se la persona invitata incolla il codice a mano."
**Vincolo:** le tre difese gia' costruite non si indeboliscono.

### Cosa ho misurato prima di scegliere

| domanda | risposta misurata |
| --- | --- |
| `riscattaLInvito` e' distribuita? | **si'**, dal 28 agosto 2026, ordine BY, revisione `riscattalinvito-00001-suj`. L'affermazione dell'ordine, che la diceva scritta ma non distribuita, e' **superata dai fatti** ed e' gia' dichiarata nella tabella delle premesse |
| esiste una gestione dei collegamenti in arrivo? | **no**. In `android/app/src/main/AndroidManifest.xml` c'e' un solo `intent-filter`, `MAIN`/`LAUNCHER`; in `pubspec.yaml` non ci sono ne `app_links`, ne `uni_links`, ne `install_referrer` |
| dove vive oggi la porta per riscattare? | **dentro il menu' Account**, `apriIlRiscattoDellInvito`, raggiunta da `account_screen.dart` e da nessun altro punto |
| il link dell'invito porta il codice? | **si'**, `${Brand.url}?invito=<uid>.<maestro>`, composto in `bonus_della_condivisione.dart` |

### La scelta, e perche' questa

**Il difetto vero non e' che il codice vada incollato: e' che nessuno lo chiede
mai.** Il lato che paga esiste e funziona, il link porta gia' il codice, e chi
arriva grazie a un invito non ha nessun motivo di andare a cercare una voce nel
menu' Account. Quindi la domanda si fa: **una volta, in casa, dopo il
tutorial**, quando il link e' ancora negli appunti del telefono di chi e'
appena arrivato. Il codice entra con **un tocco** sul pulsante Incolla.

**Perche' non prima del tutorial.** Chi apre l'app la prima volta ha davanti i
cinque fumetti del primo approdo: una domanda in mezzo a quelli e' la sesta
cosa da leggere prima di aver visto niente.

**Una domanda per apertura, e l'invito passa davanti alla misura di CC.09.**
Due fogli in fila alla prima apertura sono un pedaggio, e chi lo paga risponde
a caso al secondo. **L'invito ha la precedenza perche' scade**: il codice sta
negli appunti di chi e' appena arrivato da un link, e fra due giorni non ci
sara' piu'. La misura del ritorno non scade, e aspetta l'apertura dopo.

**Gli appunti si leggono SOLO sul tocco della persona.** Un'app che li guarda
da sola all'avvio legge tutto quello che c'e' li' dentro, che spesso e' una
password o un indirizzo, e su iOS il sistema lo dice pure a schermo. Qui si
legge dopo il tocco su Incolla, e si tiene solo cio' che ha la forma di un
codice nostro, **con i limiti del server e non con altri**: sotto gli 8
caratteri e sopra i 200 non entra niente. Se negli appunti c'e' altro, il campo
resta vuoto e a schermo compare una riga che dice solo che li' dentro non
c'era un codice: **cio' che la persona aveva copiato non viene mai rimesso a
video**.

**Il riscatto vero e' passato in un punto solo**, `riscattaIlCodiceDellInvito`:
prima viveva dentro il foglio del menu' Account, e chiunque altro avesse voluto
riscattare avrebbe dovuto ricopiare la chiamata, il rinfresco dello stato e la
frase da dire. Due copie di una regola che muove un premio in Eos divergono al
primo che ne cambia una.

**Le tre difese non sono state toccate, e sono tre controlli del SERVER.** Un
controllo sul telefono non e' una difesa, e' una cortesia. Una prova le rilegge
in `functions/src/cerchio.ts` una per una: non ci si invita da soli
(`codice === uid`), non si riscatta due volte (`gia.invitatoDa` dentro una
transazione), il premio e' idempotente (il movimento si chiama `invito-<uid>` e
se esiste non si paga).

### Cosa questa voce NON risolve, detto e non nascosto

**L'attribuzione automatica dell'installazione, quella che non chiede niente a
nessuno, resta fuori.** Su Android esiste e si chiama Play Install Referrer; su
iOS **non esiste un equivalente aperto**, e Firebase Dynamic Links e' spento da
Google dall'agosto 2025. Portare dentro l'Install Referrer vuol dire un
pacchetto nuovo, codice nativo, e una **build vera** per provarlo: le build le
ordina il fondatore, e un pezzo nativo scritto senza poterlo mai accendere
sarebbe codice creduto, non codice provato. Copre inoltre solo il lato Android,
e solo per chi installa dal Play Store.

**Il commento che diceva il vecchio stato e' stato allineato ai fatti**, in
`bonus_della_condivisione.dart`: prometteva "un ordine suo che comincera'
scegliendo la strada con l'Architetto", e adesso dice da dove il codice arriva
davvero.

### Le misure, in numeri

| misura | prima | dopo |
| --- | --- | --- |
| punti dell'app che chiedono a chi arriva se e' stato invitato | **0** | **1** |
| tocchi per riscattare, avendo il link negli appunti | 5, e bisogna sapere che il menu' esiste | **2**, Incolla e conferma |
| difese del server in piedi | 3 | **3** |
| letture degli appunti prima di un tocco della persona | non c'erano appunti letti | **0** |
| copie della strada che riscatta | 1, dentro un foglio | **1**, in una funzione riusabile |

### Il rosso, dimostrato due volte

**Primo, sul lavoro nuovo.** Tolto il filtro sulla forma del codice, cioe'
messo `if (trovato.isNotEmpty)` al posto di `if (sembraUnCodiceDInvito(trovato))`,
verificato col grep che nel file non restasse nessuna chiamata al filtro
**prima** di leggere l'esito: la prova e' diventata rossa, perche' la frase
"la mia password segreta" finiva nel campo. Rimesso, verde.

**Secondo, sul vincolo.** Sostituito `if (codice === uid)` con `if (false)` in
`functions/src/cerchio.ts`, verificato col grep che il confronto non ci fosse
piu' **prima** di leggere l'esito: la prova e' diventata rossa dicendo "difese
del server in piedi 2 su 3". Rimesso, verde.

### L'anteprima

`docs/preview/domanda-dell-invito.png`, alla larghezza vera del telefono. **Il
primo giro l'ha bocciata**: i due pulsanti mostravano rettangoli al posto delle
lettere, perche' il testo delle etichette non passava da `TypographyTokens`, e
il campo del codice era stretto al punto da troncare il suo suggerimento. Le
etichette adesso portano il carattere del Cerchio, e il pulsante Incolla ha un
tetto di larghezza: ogni punto in piu' lo perderebbe il campo, che e' dove si
legge il codice.

### La frase di accettazione della voce CC.08

**Manda a qualcuno il link dell'invito, fagli installare l'app e fargli fare il
tutorial: alla schermata di casa il Cerchio gli chiede se lo ha invitato
qualcuno, lui tocca Incolla, il codice compare da solo, e tu ricevi i tuoi
sessanta Eos.**

## CC.09, la misura del ritorno delle persone

**Debito in coda, verbatim:** "non si sa quante persone tornano il giorno dopo,
quante dopo una settimana, quale notifica le riporta dentro, quanti arrivano in
fondo a un rito e quanti lo abbandonano. Che quelle grandezze si possano
leggere." **Vincoli del fondatore:** il consenso va chiesto, chi dice no usa
l'app intera, il monitoraggio di produzione vive su Google Cloud e mai sui
crediti Anthropic, e la privacy policy va allineata nella stessa voce.

**La premessa P10 e' vera, misurata:** zero `firebase_analytics` e zero
`logEvent` in `lib/` e in `pubspec.yaml`. Non c'era niente.

### Cosa si misura, e cosa NON si misura

Cinque eventi, dichiarati uno per uno e in un elenco chiuso:

| evento | risponde a | contesto che porta con se' |
| --- | --- | --- |
| `apertura` | quante persone tornano il giorno dopo, quante dopo una settimana | nessuno |
| `ritorno_da_avviso` | quale notifica le riporta dentro | il nome del Dono, dai cinque dichiarati |
| `rito_cominciato` | quanti cominciano | l'identificativo dell'arte, dal catalogo |
| `rito_compiuto` | quanti arrivano in fondo e quanti abbandonano | il nome del gesto, dalle chiavi dei responsi |
| `responso_condiviso` | quanto si usa la sola porta di crescita che l'app ha | privato o pubblico, mai il nome dell'applicazione |

**Si contano i GESTI, non le persone.** Non esiste nessuna riga per persona con
dentro cosa ha fatto: esistono contatori per giorno e per tipo, in
`users/{uid}/ritorno/{giorno}` e in `ritorno/{giorno}`. Dal secondo si legge
quante persone tornano, e non si legge chi. **Nessun testo scritto da nessuno
esce mai**: il contesto e' una parola sola, presa da un elenco chiuso, tagliata
a 40 caratteri sul server.

### Dove i cinque eventi nascono, e perche' proprio li'

| evento | punto unico | perche' quello e non un altro |
| --- | --- | --- |
| `apertura` | `lib/app.dart`, il provider del registro, dichiarato non pigro | se il registro nascesse alla prima lettura nascerebbe dentro una schermata a caso, e l'apertura non sarebbe mai contata |
| `rito_cominciato` | `SogliaArte.initState`, in `lib/features/maestri/rotta_arte.dart` | e' la soglia di **ogni** arte: ventidue schermate ci passano e nessun'altra riga le vede tutte. In `initState` e non in `build`, perche' un'arte si ricostruisce decine di volte mentre la si usa |
| `rito_compiuto` | `RegiaDelCammino.dopoUnGesto`, dentro il ramo dei responsi | i gesti sono molti piu' dei riti: contarli tutti darebbe un numero non confrontabile con i cominciati. Dentro quel ramo il nome e' per costruzione una chiave di `VoceDelResponso.deiResponsi`, cioe' un elenco chiuso |
| `responso_condiviso` | `PortaDellaCondivisione.avvenuta` | il file dichiara gia' di se' che li' passano tutte e tre le vie, e una prova esistente cade se qualcuno condivide scavalcandola. Si conta solo `success`: un foglio aperto e chiuso non e' una condivisione |
| `ritorno_da_avviso` | `AvvisiLocali`, dentro `onDidReceiveNotificationResponse` | e' la sola riga dell'app che sa che si e' entrati toccando una notifica |

**Il registro e' raggiungibile senza `BuildContext`, ed e' una scelta
dichiarata.** Due dei cinque punti non ne hanno uno: la porta della
condivisione e' una classe di soli metodi statici, e il tocco su una notifica
arriva prima di qualunque widget. In questo progetto pretendere un provider
dentro un servizio condiviso ha gia' fatto cadere quaranta prove lontane dal
punto toccato. `RegistroDelRitorno.corrente` e' **nullo di suo e nullo resta
nelle prove**: nessuna schermata montata da sola cambia comportamento perche'
questa voce esiste.

### Il consenso

**Si chiede una volta, dopo il tutorial, in casa.** Non addosso a un rito, e
non prima dei cinque fumetti del primo approdo: sei cose da leggere prima di
aver visto il Cerchio si accettano per liberarsene. La domanda ha **due
pulsanti uguali** uno accanto all'altro, `misura_si` e `misura_no`, e nessun
`FilledButton`: un pulsante pieno accanto a uno vuoto e' una spinta. Chi chiude
il foglio senza scegliere non ha risposto, e la domanda torna: un foglio
scartato non e' un no.

**Chi dice no usa l'app intera.** Niente si spegne, niente si blocca, niente si
ripropone. La risposta si cambia dalle Impostazioni, sotto "Privacy e dati",
riga `settings_misura`.

**La chiave sta sotto `permesso.`**, che e' gia' fra i 28 prefissi di
`CioCheETuo`: chi cancella tutto se ne va anche da qui, e al rientro la domanda
torna, perche' per l'app e' una persona nuova.

**Nessun credito Anthropic e nessuno strumento nuovo.** Nessun pacchetto
aggiunto, nessun identificativo pubblicitario, nessun secondo posto dove vivono
i dati di una persona: la misura passa dalla porta che il Cerchio ha gia', una
callable su Cloud Run in `europe-west1`, e i numeri si leggono da Firestore
nella console Google.

### La privacy policy, allineata nella stessa voce

Sezione nuova, "La misura di come va l'app", dentro `sezioniDellaPolicy`. Dice
i cinque gesti con le parole di chi legge, dice che non e' un profilo, dice che
la risposta si cambia dalle Impostazioni e dice che i conti restano 24 mesi.
**Una prova pretende che le tre liste coincidano**, cioe' il client, il server e
la policy: tre elenchi che divergono sono una misura che perde pezzi in
silenzio e una policy che dice il falso.

### Le misure, in numeri

| misura | numero |
| --- | --- |
| eventi dichiarati nel client | 5 |
| eventi ammessi dal server | 5 |
| eventi nominati nella policy | 5 |
| eventi dichiarati senza un punto che li manda | **0** |
| eventi partiti senza aver chiesto niente a nessuno | **0** |
| eventi partiti dopo un no | **0** |
| chiamate in una sessione impazzita, e quante ne partono | 70, ne partono **50** |
| pacchetti aggiunti | **0** |

### Il rosso, dimostrato due volte

**Primo.** Tolto `"responso_condiviso"` da `EVENTI_AMMESSI` sul server,
verificato col grep che il file ne avesse **zero** occorrenze **prima** di
leggere l'esito, e la prova e' diventata rossa dicendo che client e server non
ammettono gli stessi eventi. Rimesso, verificata **una** occorrenza, verde.

**Secondo.** Tolto l'aggancio della condivisione da
`PortaDellaCondivisione.avvenuta`, verificato col grep che nel file non
restasse nessun `responsoCondiviso` **prima** di leggere l'esito, e la prova
degli orfani e' diventata rossa: "eventi dichiarati 5, senza un punto che li
mandano 1". Rimesso, verde.

**Un rosso trovato per strada, e riparato.** La riga del transito nella carta
ingrandita, cambiata dalla voce CC.06h, era un `Text` diretto nel ruolo
lettura: la guardia `etichette_e_lettura` l'ha vista. E' passata da
`ParagrafiDiLettura`, e la pretesa della sua prova segue adesso il dato, cioe'
la frase intera col verbo invece del transito nudo.

### Il lavoro sul server, da distribuire dal PC del fondatore

`segnaLEvento` e' scritta, provata e esportata da `functions/src/index.ts`, ma
**non e' ancora sul server**: distribuirla richiede la sessione `firebase` del
fondatore, e nessuna credenziale passa da nessuna parte. Il comando, dalla
cartella del repository, e' questo, e la variabile davanti serve perche' senza
la CLI si da' dieci secondi per analizzare il codice e muore su "Cannot
determine backend specification":

```bash
FUNCTIONS_DISCOVERY_TIMEOUT=120 firebase deploy --only functions:segnaLEvento
```

Finche' non e' distribuita **non si perde niente e non si rompe niente**: la
porta risponde di no, il registro non finge di aver registrato, e i contatori
cominciano dal giorno della distribuzione.

### La frase di accettazione della voce CC.09

**Apri l'app dopo il tutorial: ti viene chiesto una volta se puoi contare i
gesti, con due pulsanti uguali. Rispondi no e non cambia niente. Vai in
Impostazioni, Privacy e dati, e trovi l'interruttore per cambiare idea, con
sotto la stessa frase che c'e' nella privacy policy.**

## I ROSSI CHE LA SUITE INTERA HA TROVATO, E CHE HO CURATO

La suite intera, **3.956 prove**, ha trovato **nove rossi**. Uno solo era gia'
noto e accettato, `l'attribuzione cieca e' valida su QUESTA istruzione`, che sta
in `tool/rossi_accettati.txt` per decisione del fondatore dell'ordine BY voce
04. **Gli altri otto erano miei**, e nessuno e' stato messo a tacere allungando
quel registro.

**Cinque erano guardie che difendevano la LETTERA vecchia di un fatto che il
fondatore ha fatto cambiare.** In tutte e cinque ho spostato la pretesa sul
fatto nuovo, mai allentato la guardia:

| prova | cosa difendeva | cosa difende adesso |
| --- | --- | --- |
| `anteprime_montano_cio_che_l_app_monta` | che la rotta di un'arte dicesse `builder: (_) => conLaSoglia(`, cioe' la forma di `MaterialPageRoute` | che la rotta chiami `=> conLaSoglia(`, qualunque sia la forma della rotta. **Il velo nero di CC.04 ha cambiato la forma, non il fatto** |
| `le_chiamate_del_giorno` | apriva la rotta con `as MaterialPageRoute`, e con CC.04 quel cast lancia | accetta anche `PageRouteBuilder`, perche' il fatto e' **quale scena la rotta apre** |
| `il_cielo_del_giorno_decide_quando` | che la riga del cielo portasse la coda "non si conosce l'ora di nascita" | che quella coda **non ci sia piu'**: il fondatore in CC.06g ha scritto "eliminalo!", e al suo posto ogni responso porta ORA DI NASCITA: SCONOSCIUTO |
| `il_mondo_oltre_l_italia` | che la Liberia avesse **una** citta' sola | lo stesso fatto su Barbados. La prova diceva di se' stessa "se questo numero sale il buco si sta chiudendo": si e' chiuso, la Liberia e' passata da 1 a 16 |
| `il_luogo_di_nascita_e_la_sua_nazione` | che i luoghi fossero 11.546 e che un paese solo si disegnasse | 40.846 luoghi e tre paesi, guardati uno per uno |

**Tre erano conti da rifare, non guardie da cambiare.** Il censimento
tipografico e' sceso da 226 misure a mano a **225**, perche' la voce CC.05
aveva tolto un `Text` nudo; i vuoti verticali sono saliti da 146 a **147**, e
prima di rigenerare il documento ho convertito le due misure nuove che avevo
scritto a mano in `SpacingTokens.xxs`; e `niente_lavoro_non_spinto` cadeva
perche' il lavoro della voce CC.07 non era ancora committato.

**Due anteprime sono state tolte invece di curate.** `nazione-belgio.png` e
`nazione-paesi-bassi.png` erano sotto la soglia di luminosita' del corredo, 165
e 186 contro 200. Non era un difetto di cattura: dopo l'alzata di
`luoghiMinimi` quei due paesi non passano piu' dalle loro citta', quindi quelle
immagini **non documentavano piu' cio' per cui le avevo fatte**. Restano le due
che contano, `nazione-germania.png` e `nazione-regno-unito.png`.

## LE SCELTE CHE HO PRESO IO E PERCHE'

- **CC.07, nessuna fonte nuova.** La causa non era una fonte povera, era una
  potatura nostra sopra un file gia' potato: una fonte nuova avrebbe portato
  una licenza da leggere, un formato da fidarsi e un secondo elenco che puo'
  divergere da quello che l'app gia' usa.
- **CC.07, entrano tutti i luoghi che la fonte ha.** Qualunque numero per
  paese sarebbe stato arbitrio, e l'arbitrio si sarebbe visto proprio sui
  paesi piccoli, che sono quelli per cui la voce esiste.
- **CC.07, `luoghiMinimi` da 200 a 500, e non e' un elenco travestito.** Il
  numero e' scelto sulla geometria e misurato: chi riempie l'82 per cento delle
  celle che PUO' riempire non sta disegnando una forma, sta finendo i punti.
- **CC.07, ho guardato le quattro mappe nuove prima di tenerle.** La guardia di
  BB.12 dice di se' stessa che non ha occhi: quelle immagini sono i suoi occhi,
  e la prima mi ha mostrato il Canada al posto del Regno Unito.
- **CC.07, l'attribuzione esce dal commento e va a schermo.** La licenza
  pretende che sia raggiungibile: un obbligo assolto dentro casa non e'
  assolto.
- **CC.08, la domanda si fa a chi arriva invece di aspettarlo in un menu'.**
  Il lato che paga esisteva gia' e il link portava gia' il codice: mancava solo
  che qualcuno chiedesse, e nel momento in cui il link e' ancora negli appunti.
- **CC.08, gli appunti si leggono solo sul tocco.** Un'app che li guarda da
  sola legge tutto quello che c'e' li' dentro, che spesso e' una password.
- **CC.08, l'Install Referrer non l'ho scritto.** Vuole un pacchetto nuovo,
  codice nativo e una build vera per provarlo: le build le ordina il fondatore,
  e un pezzo nativo mai acceso sarebbe codice creduto, non provato.
- **CC.09, nessuno strumento nuovo e nessun pacchetto.** Firebase Analytics
  avrebbe portato un secondo identificativo e un secondo posto dove vivono i
  dati di una persona, proprio mentre l'ordine CB voce 05 ha appena messo una
  scadenza a ognuno.
- **CC.09, si contano i gesti e non le persone.** Da contatori per giorno si
  legge quante persone tornano, e non si legge chi.
- **CC.09, il registro e' raggiungibile senza `BuildContext`.** Due dei cinque
  punti non ne hanno uno, e pretendere un provider dentro un servizio condiviso
  in questo progetto ha gia' fatto cadere quaranta prove lontane dal punto
  toccato.
- **CC.08 prima di CC.09, una domanda per apertura.** Il codice negli appunti
  scade, la misura del ritorno no.

- **CC.06a, i riferimenti sono al massimo sei, e vengono dal catalogo per
  popolazione.** Venti nomi su una mappa piccola non dicono dove sei, dicono
  che c'e' molta gente.
- **CC.06c, il nome dell'aspetto resta e i gradi escono.** Toglierlo tutto
  farebbe di una lettura una battuta; i gradi vivono gia' nella pastiglia
  toccabile, dove li cerca chi li vuole.
- **CC.06d, le quattro frasi dell'attualita' sono PROVVISORIE e marcate.** Il
  corpus e' materia del fondatore.
- **CC.06e, non ho riscritto nessuna riga del corpus.** Misurato che il
  registro goliardico c'e' gia' in tutte e quattro le famiglie che compongono
  la bolla: quello che stonava era la clausola tecnica, ed e' uscita con la
  voce c.
- **CC.06h, il lato di chi guarda resta "il tuo".** E' la frase del fondatore,
  ed e' anche l'unica che non suona ridicola a chi legge il proprio responso.
- **CC.05, la misura di riferimento si LEGGE dal token, non si riscrive.** La
  prova prende 18 da `lettura()`: il giorno che il responso dei Tarocchi cambia
  misura, cambiano tutte le altre senza che nessuno tocchi la prova.
- **CC.05, i titoli gialli si contano e non si toccano.** Il fondatore li ha
  dichiarati buoni: il conto di 119 serve solo perche' non cresca.
- **CC.05, il testo narrato passa sempre da `ParagrafiDiLettura`.** Cambiare
  solo la misura avrebbe lasciato nove `Text` nudi nel ruolo lettura, cioe' la
  seconda porta da cui il muro di testo torna.
- **CC.02, la grandezza misurata e' il contrasto, non l'area.** Una freccia
  grande e scura resta invisibile: se il rosso non fosse scattato avrei
  cambiato la grandezza, mai la soglia.
- **CC.03, la scena sta fuori dallo `Scaffold` ma dentro la schermata.** Sopra
  lo `Scaffold` copre anche la barra dell'Oroscopo; portarla piu' in alto
  ancora, per coprire le due barre sottili dell'app, vorrebbe dire una seconda
  porta sullo stesso momento.
- **CC.03, le frasi di attesa sono PROVVISORIE e marcate nel codice.** Sono
  parole che la persona legge, quindi appartengono al fondatore.
- **CC.03, la festa aspetta la dissolvenza.** Non e' un ritardo estetico: la
  festa copriva la scena proprio mentre scopriva il responso.
- **CC.04, i due veli trasparenti restano fuori dalla legge unica**, e la prova
  verifica che siano ancora trasparenti invece di crederci.
- **CC.04, il passaggio dura 220 millesimi all'andata e 160 al ritorno.** Sotto
  i 150 si legge come uno sfarfallio, sopra i 300 si aspetta; chi torna
  indietro sa gia' dove va.
- **CC.01, i tre testi veri entrano subito e i due contesi aspettano.** Metterli
  tutti e cinque avrebbe messo a video due promesse che ho misurato false;
  tenerli tutti fuori avrebbe lasciato l'app indietro su tre testi che vanno
  bene. La sostituzione e' per fumetto, non per blocco.

## LE DECISIONI CHE NON SONO MIE

Sono quelle che toccano il listino o l'economia, cambiano una frase che la
persona legge, oppure decidono se un dato resta o sparisce.

- **CC.01, fumetto 2.** Le tre terne di arti che hai scritto non coincidono
  con quelle che l'app mostra altrove. O si allinea l'app alle tue parole, o le
  tue parole all'app.
- **CC.01, fumetto 4.** Tre doni su cinque non nascono dall'incrocio promesso.
  O cambia il testo, o cambiano i doni: la seconda e' un lavoro vero
  sull'Arcano, sulla Runa e sul Sogno, e non e' in questo ordine.
- **CC.01, fumetto 5.** Gli Eos non comprano arti. O cambia il testo, o cambia
  il listino, che e' economia e quindi tua.
