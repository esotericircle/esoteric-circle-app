# ORDINE CF, DICIOTTO VOCI

Ordine del fondatore del 30 agosto 2026, arrivato in tre pezzi. Guardia
`test/ordine_cf_guard_test.dart`.

**Da dove nasce.** Il fondatore ha disinstallato e reinstallato l'app sulla
build 2215, quella che contiene gli ordini CC, CD e CE, e ha trovato questi
difetti usandola davvero. **Tre voci nascono da lavoro dichiarato chiuso che sul
suo telefono non ha retto**: CF.09, CF.10 e CF.11.

Porta le tre regole degli ordini precedenti:

- **REGOLA ZERO.** Il testo dell'ordine non e' affidabile e l'Architetto che lo
  ha scritto non e' affidabile: ogni affermazione si verifica sul ramo prima di
  lavorarci. **E una misura scritta in un rapporto precedente non e' una misura
  di adesso**: nell'ordine CE tre premesse false su sette erano state EREDITATE
  dal rapporto dell'ordine CC invece di essere rimisurate.
- **REGOLA UNO.** Code non si ferma davanti a un ostacolo, risolve.
- **REGOLA DUE.** Le decisioni delegate si prendono e si motivano per iscritto;
  quelle non delegate si riportano come fatti.

## Le diciotto voci

- **CF.01** La barra sottile piu' alta, con l'anello del livello. **CHIUSA.**
- **CF.02** La striscia dei Doni piu' bassa. **CHIUSA.**
- **CF.03** La barra Esplora piu' bassa. **CHIUSA.**
- **CF.04** Le notifiche dei Doni, e le push. **APERTA.**
- **CF.05** "Bentornata Mauro", al femminile. **CHIUSA.**
- **CF.06** Rimasto sul Risveglio invece che in home. **CHIUSA.**
- **CF.07** I dati di nascita non erano rimasti memorizzati. **CHIUSA.**
- **CF.08** La ricerca della citta' non funziona nel popup. **CHIUSA.**
- **CF.09** Il lampo nero non c'e' ovunque. **APERTA.**
- **CF.10** Caratteri troppo piccoli nei Doni e altrove. **APERTA.**
- **CF.11** Il conteggio delle sinastrie. **APERTA.**
- **CF.12** La carta del VIP ingrandita e' schiacciata. **APERTA.**
- **CF.13** Le mappe calcolano sulla citta' natale. **APERTA.**
- **CF.14** Il Gemello astrale non e' appagante. **APERTA.**
- **CF.15** La riga della privacy policy manca a chi rientra. **APERTA.**
- **CF.16** Due porte quasi identiche, e ne resta una sola. **APERTA.**
- **CF.17** Le due lapidi vecchie, scritte col sale vuoto. **APERTA.**
- **CF.18** Il secondo cancello. **APERTA.**

VOCI_TOTALI: 18
VOCI_CHIUSE: 7
VOCI_APERTE: 11
VOCI_FERMATE_SU_PREMESSA_FALSA: 0
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0
VOCI_FERMATE_SU_DECISIONE_DEL_FONDATORE: 0

## LE AFFERMAZIONI DI QUESTO ORDINE CHE HO TROVATO FALSE

**Nessuna. Diciotto premesse su diciotto sono vere**, e va detto perche' e' il
contrario esatto dell'ordine CE, dove sette su diciassette erano false e tre di
quelle erano state ereditate da un rapporto vecchio invece che rimisurate.
Questa volta l'Architetto ha misurato prima di scrivere.

Verificate tutte sulla testa `88e587ee`, prima di toccare una riga.

| # | esito | cosa ho misurato |
| --- | --- | --- |
| P01 | **vera, stato superato** | la testa non e' `e646f06f` ma `88e587ee`, cioe' un commit piu' avanti, e coincide col remoto |
| P02 | **vera** | `altezzaChiusa = 30`, `PortaDellAccount(misura: 22)`, `Positioned(top: 0)`, e dentro volto, "Eventi Cosmici" in `Expanded` e borsellino |
| P03 | **vera** | `_heightLarga` e `_heightStretta` valgono tutte e due 122, la striscia e' montata solo da `santuario_screen.dart`, il tetto della guardia e' 126 |
| P04 | **vera** | `SantuarioBottomBar.altezzaResa = 134`, `BarraDelCerchio.altezza` la legge da li' e `corsa = altezza` |
| P05 | **vera** | cinque chiamate locali con `zonedSchedule` e `AndroidScheduleMode.inexactAllowWhileIdle`, programmate da `RegiaDelleChiamate` |
| P06 | **vera** | zero occorrenze di `firebase_messaging` in `lib/`, in `pubspec.yaml` e in `functions/src/` |
| P07 | **vera** | una sola riga, chiave `consenso_informativa`, testo "Continuando accetti la privacy policy del Cerchio.", montata solo dentro `VieDellaCustodia` |
| P08 | **vera** | il ramo dell'email trovata costruisce i suoi `_PulsanteDellaVia` da solo, senza passare da `VieDellaCustodia`: la riga non c'e' |
| P09 | **vera** | Impostazioni ha "Privacy e dati" con dentro "Privacy e permessi" e "Cancella i miei dati" |
| P10 | **vera, e peggio** | il menu' utente ha "Privacy e dati" con le quattro voci, **e le due porte usano la stessa identica icona, `Icons.shield_outlined`** |
| P11 | **vera** | `RigaDelResiduo` e' il primo figlio della lista del verdetto, e la scelta del VIP avviene in un'altra schermata |
| P12 | **vera** | montata in quattro punti: confronti, domande, approfondimenti, sinastrie. Gettate e stese non ne hanno |
| P13 | **vera, ai numeri esatti** | 43 `PassaggioDelCerchio.rotta`, 36 `showModalBottomSheet`, 16 `showDialog`, 3 `showGeneralDialog` |
| P14 | **vera** | tutti e cinque i Doni usano `lettura()` sui testi lunghi e **nessuno dei cinque file ha un solo `fontSize` esplicito** |
| P15 | **vera, e il numero coincide** | `height: larga / 0.78` con `StackFit.expand` sopra un `AspectRatio` a 2 su 3 e `BoxFit.fill`: compressione verticale **14,53 per cento** |
| P16 | **vera** | `luogo.attuale` e' scritta solo da `dove_sei_adesso.dart`, montato solo nel Rito dell'Alba, e il profilo ha un solo campo, "Luogo di nascita" |
| P17 | **vera** | sfilata di 1600 millesimi, una miniatura da 120, una frase in due varianti, dentro `sinastria_gallery_screen.dart` |
| P18 | **vera** | `BENVENUTO_PEPPER` versione 1 montato da `statoDelCerchio`, revisione `statodelcerchio-00018-vat` |

### La domanda a parte, e la sua premessa e' falsa

L'ordine chiede: la prova nata nell'ordine CC per misurare la grandezza vera a
cui ogni titolo viene dipinto usava `getTransformTo`, ed e' stata cieca per due
ordini?

**Quella prova non e' mai esistita.** La prova dell'ordine CC voce 05,
`le_descrizioni_hanno_una_misura_sola_test.dart`, **contava** i titoli con la
misura scritta a mano e non misurava niente di dipinto: e' proprio per questo
che il difetto e' rimasto nascosto. La prova che misura la grandezza dipinta e'
nata nell'ordine CE voce 11, e **nella sua prima stesura usava davvero
`getTransformTo`**: e' stata cieca per il tempo della sua scrittura, il difetto
e' stato trovato dalla prova del rosso che non scattava, ed e' stato corretto
dentro lo stesso ordine prima della consegna. La ragione sta scritta nel file.

**Ma la ricerca ha trovato altro, e vale piu' della domanda.** `getTransformTo`
e' usato in altri due punti del progetto, tutti e due nella stessa forma cieca
`MatrixUtils.transformRect(getTransformTo(...), Offset.zero & size)`:

- `test/la_chiave_e_il_consiglio_si_vedono_test.dart`, in tre punti, per misurare
  l'altezza dipinta delle carte della Stesa;
- `lib/features/onboarding/primo_approdo.dart`, per calcolare il riquadro del
  faro del tutorial attorno a un'ancora.

**Oggi nessuno dei due e' cieco davvero**, perche' misurato: non c'e' nessun
`FittedBox` nei file della Stesa, e le quattro ancore del tutorial non stanno
sotto un ramo che scala. **Ma lo diventerebbero in silenzio** il giorno che
qualcuno ne aggiunge uno, e nella voce CF.01 si tocca proprio
`barra_dell_identita.dart`, che porta una di quelle ancore.

## LE SCELTE CHE HO PRESO IO E PERCHE'

### CF.01, la barra sottile sale da 30 a 38 punti

**Otto punti, e non sono scelti a occhio.** Il volto misura ventidue.
L'anello gli gira attorno con due punti di stacco e due e mezzo di tratto per
parte, quindi il suo diametro esterno e' trentuno. A trenta la riga lo
schiacciava a ventinove e a video diventava un'ellisse tagliata sopra e sotto,
misurato. Trentotto gli lascia tre punti e mezzo per parte: abbastanza perche'
l'oro non tocchi il filo del bordo, poco perche' la barra resti sottile come il
fondatore la vuole.

### CF.01, il valore dell'anello viene dai Sigilli del Cammino

**Il livello XP non esiste e questa voce non lo ha inventato**, come l'ordine
chiedeva. Cercato prima di decidere: in tutto `lib/` la parola livello compare
solo come piano di abbonamento e come livello di personalizzazione
dell'oroscopo, mai come esperienza accumulata. **L'unica grandezza di
progressione che il progetto possiede sono i Sigilli**, e l'anello si riempie
su quelli.

**La porta e' una sola, e questa e' la parte che conta.** Il fondatore ha
scritto nell'ordine che due conteggi diversi della stessa cosa sono la famiglia
di difetti piu' numerosa del progetto: percio' il numeratore e il denominatore
escono INSIEME da `DiarioDelCammino.progressoDelCammino`, e chi disegna
l'anello, chi scrive il numero accanto al volto e chiunque domani mostri la
stessa progressione altrove legge quella riga e nessun'altra.

### CF.01, il denominatore sono 114 e non 165

**Misurato: dei centosessantacinque traguardi scritti, cinquantuno sono
dormienti**, cioe' presenti nel corpus e non ancora agganciati a un gesto vivo.
Un anello sui 165 non potrebbe chiudersi nemmeno giocando per anni, e sarebbe
una promessa falsa disegnata addosso al volto della persona. `Sentieri.raggiungibili`
legge il corpus e non una costante, quindi il giorno che un dormiente si sveglia
il denominatore cresce da solo.

### CF.01, il numero accanto al volto e' provvisorio e va dichiarato

Il fondatore ha chiesto "il livello di esperienza" accanto al volto. Finche' il
livello XP non esiste, li' c'e' il numero dei Sigilli accesi, che e' lo stesso
numero che riempie l'anello. **E' un testo provvisorio, marcato come tale nel
codice**: i testi definitivi li approva lui.

### CF.02, la striscia dei Doni scende da 122 a 108

**Quattordici punti, e stavano vuoti.** Misurata a 360, 390 e 412 prima di
toccarla: fascia 122, composta da quattro stacchi da 4, la riga del titolo alta
17, la fila delle caselle alta 85, la barra di scorrimento alta 3 e il filo
d'oro sotto. **Dentro gli 85 della fila, il contenuto di una casella ne usa
sessantotto**: cerchio dell'icona 46, stacco 4, etichetta 18. La colonna e'
centrata, quindi diciassette punti restavano vuoti sopra e sotto senza disegnare
niente. Se ne prendono quattordici e tre restano di respiro, che e' il margine
perche' un arrotondamento del testo fra due versioni di Flutter non faccia
traboccare la casella.

**Niente viene dall'area di tocco**, di nuovo: il cerchio resta 46 e il
bersaglio del punto interrogativo resta 44 per 44, che non pesa sul calcolo
perche' sborda dalla riga invece di occuparla. **E niente viene dall'etichetta**:
il `FittedBox` attorno al nome oggi non riduce niente, padre e figlio misurano
tutti e due 18, e deve restare cosi' perche' la voce CF.10 dice che i caratteri
dei Doni sono gia' troppo piccoli.

**Il tetto della guardia scende da 126 a 112**, quattro sopra il misurato come
la volta scorsa. A 126 sarebbe rimasta una soglia che lasciava tornare
all'altezza vecchia in silenzio.

### CF.03, l'alone della scritta ESPLORA e' stato allargato

**Non era in programma, ed e' un difetto vecchio che si e' visto adesso.**
Abbassando la barra, la scritta ESPLORA e' scesa di sedici punti e la prova del
contrasto ha misurato **4,28 contro il 4,5** che la legge chiede. La causa,
misurata: il raggio di un `RadialGradient` e' una frazione del **lato piu' corto**
del riquadro, e quel riquadro e' alto ventisette punti e largo piu' di cento.
Con 0,85 il fondo pieno arrivava a ventitre punti dal centro, cioe' copriva solo
la meta' di mezzo della parola e lasciava le due estremita' su un alone gia'
quasi trasparente. Finche' la barra era alta 134 dietro quelle estremita'
passava roba scura e nessuno se ne accorgeva.

Il raggio passa a 3,0 e il riquadro non cambia di un punto, quindi **nessuna
altezza torna indietro**. Misurato dopo: **5,64**, sopra il 5,48 che la stessa
prova leggeva prima di questa voce. Guardata l'anteprima: la scritta non ha
nessuna fascia dietro.

### CF.03, la barra Esplora scende da 134 a 112

**Ventidue punti, e la parte che il fondatore ha indicato ne valeva due.**
Misurato prima di toccare: lo spazio fra la scritta ESPLORA e le icone valeva
DUE punti, piu' i cinque dell'alone sotto il testo. **Ridurre solo quello non
poteva bastare**, e va detto perche' e' esattamente la parte dell'ordine che
non reggeva. I ventidue vengono da dove c'era margine vero: dodici dal margine
esterno della barra, otto dall'aria attorno alle cinque voci, due dallo spazio
che lui ha nominato.

**Nessuno viene dal bersaglio del dito**, che resta un cerchio da quarantaquattro
dentro un'area da cinquantadue, sopra il minimo di quarantotto. **E nessuno
dall'alone del titolo**, che l'ordine A aveva alzato da tre a cinque per una
ragione di contrasto misurata, 4,31 contro il 4,5 richiesto.

### CF.05, il genere non si indovina piu'

**La causa, misurata.** `ProfileController` nasceva con un profilo d'esempio
che dichiarava `CourtesyForm.feminine`, e quel profilo non e' solo quello della
Demo: e' lo stato INIZIALE del controller in tutta l'app, perche' `app.dart` lo
costruisce senza argomenti e poi chiama `load()`. Su un telefono appena
reinstallato non c'e' niente da caricare, quindi la forma restava femminile e il
riconoscimento rimetteva il nome vero senza toccarla. **"Bentornata Mauro" nasce
da quella riga**, e la prova del rosso la riproduce parola per parola.

**Il nome resta, il genere no.** Un nome d'esempio e' una didascalia che
l'onboarding sostituisce; un genere e' un'affermazione su una persona vera.

**Il censimento chiesto dall'ordine, coi numeri.** Stringhe che dichiarano un
genere rivolgendosi alla persona: **undici prima, dieci adesso**. Vivono in
cinque file, e quattro di quelli SONO le porte del genere, cioe' scelgono la
forma guardando la persona. **Una sola era fuori**: nel registro degli Eos il
motivo del dono si chiamava "Benvenuto nel Cerchio", quindi a chi aveva scelto
il femminile il Cerchio diceva comunque "Benvenuto". Adesso si chiama **"Dono di
benvenuto"**, che non ha genere e non ne serve uno. **Testo provvisorio**: le
parole che la persona legge le approva il fondatore.

**Due guardie e non una.** La prima pretende che nessuna stringa dichiari un
genere fuori dalle porte; la seconda pretende che ogni porta porti ANCORA tutte
e due le declinazioni, perche' senza di lei la prima si potrebbe far passare
cancellando meta' di una coppia, e allora il Cerchio smetterebbe di parlare a
chi ha scelto quella forma.

### CF.06, l'ora non trattiene piu' nessuno dentro il rito

**La causa, misurata.** L'uscita dal rito passa da `Ritrovamento.siSalta`, vero
solo quando `passiDaChiedere` e' vuoto. In quell'elenco c'era l'ORA. Ma l'ora nel
Cerchio e' FACOLTATIVA per costruzione: l'Ascendente si calcola quando c'e' e si
dichiara assente quando non c'e', e il rito stesso offre "non la so". **Chi
aveva risposto cosi' aveva `ora` nulla per sempre**, quindi non esisteva nessuna
risposta capace di liberarlo: a ogni reinstallazione rifaceva il rito intero.

**All'obiezione dell'ordine AP si e' risposto, non l'ho ignorata.** La guardia
dell'ordine AP voce 05 pretendeva `siSalta` falso con la ragione che altrimenti
l'Ascendente sarebbe restato fuori per sempre, e la ragione era giusta. Lo
Specchio dei dati dichiarava gia' l'ora mancante e la sua conseguenza, **ma non
offriva nessun gesto per darla**, mentre per il luogo il gesto c'era. Adesso c'e'
anche per l'ora, e porta alla stessa schermata dei dati di nascita. **Tre prove
degli ordini AP e AZ sono state cambiate, e ognuna dichiara nel proprio testo
quale decisione supera e perche'.**

### CF.07, cosa la custodia prometteva e cosa non manteneva

**Misurato voce per voce, prima di curare.** La custodia dichiara nove campi
dell'identita': nome, giorno, ora, luogo, latitudine, longitudine, fuso, scarto,
e adesso forma. Il giro fra `aMappa` e `daMappa` non ne perdeva nessuno. **Le
perdite erano tre, e stavano tutte fuori dalla mappa:**

1. **Il luogo non tornava nel campo.** La ripresa del rito riprendeva giorno,
   ora e nome, e il luogo no: il rito ripartiva dal primo passo mancante e poi
   proseguiva in fila, quindi arrivava al passo del luogo col campo vuoto. **E'
   il fatto del fondatore parola per parola**: "i miei dati di nascita, luogo
   ecc non sono rimasti memorizzati e ho dovuto reinserirli".
2. **Il nome e la forma non tornavano nel profilo.** L'adozione del cammino
   rimetteva l'identita' di nascita e basta: chi usciva dal rito perche' non
   c'era piu' niente da chiedere restava chiamato col nome d'esempio.
3. **Lo scarto dal tempo universale non tornava mai, ed e' il peggiore.**
   `daiDettagli` non puo' scriverlo, perche' il `BirthPlace` dell'astronomia
   porta il fuso IANA e non i minuti: al ritorno `scarto` era SEMPRE nullo, e la
   ricostruzione metteva sessanta a chiunque, cioe' **l'ora di Roma anche a chi
   e' nato a Tokyo**. Misurato dopo la cura: Tokyo torna a **540 minuti** invece
   di 60. Il catalogo dei luoghi quei minuti li aveva gia'.

**La guardia ENUMERA il sorgente invece di elencare a mano**, perche' un elenco
a mano invecchia in silenzio: e' esattamente il modo in cui `scarto` e' rimasto
per mesi un campo che nessuno riempiva.

### CF.08, due porte sulla ricerca della citta', e ne resta una

**La causa, misurata.** Il rito dell'accoglienza cercava con
`CityCatalog.unicaEsatta` e, quando il nome scritto per intero combaciava con un
solo luogo, **svuotava l'elenco dei suggerimenti** e usciva; la schermata dei
dati di nascita, quella del menu' utente, non aveva quella riga e l'elenco lo
mostrava sempre. **Stessa domanda, due risposte.** Chi scriveva "Roma" nel rito
vedeva l'elenco vuoto e concludeva che il Cerchio non conoscesse Roma. Misurato
dopo: "Roma" sceglie Roma **e mostra otto suggerimenti**, dove prima ne mostrava
zero.

**La cura e' togliere la porta, non correggerla nel chiamante.** La regola vive
in `RicercaDelLuogo` e le due schermate la chiamano; una prova sul sorgente cade
se una delle due torna a cercare per conto suo. **La scelta automatica resta**,
perche' e' una decisione precedente del fondatore e non si rovescia: cio' che
cambia e' che l'elenco non si svuota, e la riga di conferma del luogo scelto non
dipende piu' dall'elenco vuoto, altrimenti sparirebbe proprio quando qualcuno
scrive per intero il nome della sua citta'.

**Cio' che NON ho potuto verificare, e va detto.** Il fondatore chiama
"schermata popup" quella in cui la ricerca non funzionava. In `lib/` non esiste
nessun foglio ne' dialogo che chieda i dati di nascita con un campo citta': le
sole tre porte che cercano un luogo sono il rito dell'accoglienza, la schermata
dei dati di nascita e il "dove sei adesso" del Rito dell'Alba. **Ho identificato
la schermata per esclusione**, cioe' il rito ripreso dopo il riconoscimento, che
compare all'improvviso ed e' l'unica delle tre che divergeva. La divergenza era
reale e misurata; l'abbinamento alla parola "popup" e' mio.

## LE TRE COSE CHE QUEST'ORDINE PRETENDE SIANO SCRITTE

### CF.03 supera una decisione precedente del fondatore

"LA SCRITTA ESPLORA E IL SUO MENU' A SCOMPARSA NON SI TOCCANO" e' una decisione
del fondatore del 17 agosto 2026, ripetuta come vincolo permanente in cinque
manifesti d'ordine. **La richiesta del 30 agosto 2026 la supera**, e la voce
CF.03 la esegue per ordine esplicito.

### CF.09, CF.10 e CF.11 nascono da voci dichiarate chiuse

Da riempire alla chiusura di ognuna, con la ragione per cui la loro prova era
verde.

### Il debito lasciato aperto dall'ordine CE

La modifica del vincolo di copertura della spirale, sceso dal 71,4 al 59,9 per
cento con l'ordine CE voce 14, **va scritta anche nel manifesto dell'ordine AV**,
altrimenti AV continua a dichiarare un numero che non vale piu'.
