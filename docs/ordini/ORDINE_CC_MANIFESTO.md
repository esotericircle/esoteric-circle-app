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

- **CC.01** I cinque testi del tutorial si sostituiscono. **FERMATA IN ATTESA DI DECISIONE.** Tre testi su cinque sono in vigore; due promettono cose che il codice non fa, e l'ordine stesso vieta di riscriverli.
- **CC.02** La freccia dei fumetti e' poco visibile. **CHIUSA.** Il contrasto della freccia sul velo passa da 1,24 a 9,33, contro una soglia dichiarata di 3,0.
- **CC.03** L'animazione di riflessione dell'Oroscopo si rifa' da capo. **CHIUSA.** I dodici segni corrono grandi, la corsa rallenta e si ferma sul tuo, il segno cresce e la scena si dissolve sul responso.
- **CC.04** Il lampo fra le schermate diventa nero, e vale ovunque. **CHIUSA.** Quarantadue rotte sotto una legge sola, due veli trasparenti dichiarati fuori, e il lampo dei Tarocchi non e' piu' bianco.
- **CC.05** Censimento globale delle dimensioni dei caratteri. **CHIUSA.** Ventidue arti censite: sei mostravano il responso a 16 punti e adesso tutte lo mostrano a 18, la misura del responso dei Tarocchi.
- **CC.06** La Sinastria VIP, nove rilievi. **CHIUSA.** Tutti e nove: le mappe dicono dove sei, i fili sono corde, la bolla e' tecnica per il 17 per cento invece che per il 36, e i transiti dicono di chi sono.
- **CC.07** Il catalogo delle citta' fuori dall'Italia. **APERTA.**
- **CC.08** L'attribuzione vera degli inviti. **APERTA.**
- **CC.09** La misura del ritorno delle persone. **CHIUSA.** Cinque gesti contati per giorno, zero profili, zero pacchetti nuovi, il consenso chiesto una volta con due pulsanti uguali e la policy allineata nella stessa voce.

VOCI_TOTALI: 9
VOCI_CHIUSE: 6
VOCI_APERTE: 2
VOCI_FERMATE_SU_PREMESSA_FALSA: 0
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 1
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

**FERMATA IN ATTESA DI DECISIONE**, ed e' l'ordine stesso a chiederlo: "se il
testo mente, FERMATI e riportalo al fondatore invece di riscriverlo da solo:
questi testi sono suoi".

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

### COSA E' GIA' IN VIGORE E COSA ASPETTA TE

I tre testi verificati veri sono a video. I due che promettono cose che il
codice non fa restano quelli di prima, che dicono il vero, finche' non decidi.

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

### La frase di accettazione della voce CC.09

**Apri l'app dopo il tutorial: ti viene chiesto una volta se puoi contare i
gesti, con due pulsanti uguali. Rispondi no e non cambia niente. Vai in
Impostazioni, Privacy e dati, e trovi l'interruttore per cambiare idea, con
sotto la stessa frase che c'e' nella privacy policy.**

## LE SCELTE CHE HO PRESO IO E PERCHE'

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
