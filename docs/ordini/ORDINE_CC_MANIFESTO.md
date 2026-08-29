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
- **CC.06** La Sinastria VIP, nove rilievi. **APERTA.**
- **CC.07** Il catalogo delle citta' fuori dall'Italia. **APERTA.**
- **CC.08** L'attribuzione vera degli inviti. **APERTA.**
- **CC.09** La misura del ritorno delle persone. **APERTA.**

VOCI_TOTALI: 9
VOCI_CHIUSE: 4
VOCI_APERTE: 4
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

## LE SCELTE CHE HO PRESO IO E PERCHE'

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
