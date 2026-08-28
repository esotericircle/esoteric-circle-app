# ORDINE BZ, LA CANCELLAZIONE, LA BUILD DEI FONDATORI E IL GIRO DEL FONDATORE

Ordine del fondatore del 28 agosto 2026, in tre voci, piu' le sei aggiunte dal
fondatore con parole sue ("Sono Mauro, visto che non mi fido dell'architetto, di
seguito la mia richiesta reale"), piu' l'integrazione del 28 agosto sulla voce
BZ.02. Guardia `test/ordine_bz_guard_test.dart`.

## Le nove voci

- **BZ.01** La cancellazione dei dati. **CHIUSA.** Una verita' sola su cosa se
  ne va, nessun dato di nascita nel NOME di una chiave, lo scarico che consegna
  tutto, e una prova che diventa rossa DA SOLA quando nasce una memoria che
  nessuna via cancella. L'ha gia' fatto: ha trovato la quarantaseiesima chiave
  senza che nessuno la cercasse.
- **BZ.02** La build per i fondatori. **FERMATA IN ATTESA DELLE MANI DEL FONDATORE.** L'archivio adesso si produce: le prove del cielo non dipendono
  piu' dall'ora della macchina e il rosso dichiarato non mura piu' la porta.
  Lanciare la build su Codemagic chiede credenziali che non passano da qui: i
  passi numerati sono piu' sotto, e senza quelli la build non arriva.
- **BZ.03** Le frasi dei Maestri. **FERMATA SU DECISIONE DEL FONDATORE.** Parole
  sue: "questa e' mia", cioe' dell'Architetto. Non l'ho toccata.
- **BZ.04** Le notifiche non arrivano. **CHIUSA.** Il permesso del sistema
  l'app lo chiedeva in due sole schermate, e da Android 13 le notifiche
  nascono negate: chi non ci entrava non ne riceveva nemmeno una. Adesso si
  chiede all'avvio, una volta sola.
- **BZ.05** Gli effetti sonori nascono spenti. **CHIUSA.** Su un telefono appena
  installato suonano zero responsi su otto; l'interruttore resta dov'era.
- **BZ.06** L'animazione di riflessione dell'Oroscopo. **CHIUSA.** Dura
  4.000 millesimi invece di 2.800, la breve 3.000 invece di 1.000, la corona
  resta per tutti e due i momenti e ogni corpo porta il suo glifo.
- **BZ.07** Medora da sola prima della riflessione. **CHIUSA.** Erano sedici
  fotogrammi su sessanta, cioe' un secondo e sei decimi. Adesso sono zero.
- **BZ.08** La carta chiave. **CHIUSA.** La cornice azzurra non c'e' piu': sopra
  la carta c'e' scritto Carta Chiave e le altre due sono piu' piccole.
- **BZ.09** La Sinastria VIP parte dal confronto. **CHIUSA.** In cima ci sono
  il titolo e le due carte; le due funzioni virali restano subito sotto; i
  ritratti della lista passano da 101 a 165 punti dipinti.

VOCI_TOTALI: 9
VOCI_APERTE: 0
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0
VOCI_FERMATE_IN_ATTESA_DELLE_MANI_DEL_FONDATORE: 1
VOCI_FERMATE_SU_PREMESSA_FALSA: 0
VOCI_FERMATE_SU_DECISIONE_DEL_FONDATORE: 1
VOCI_CHIUSE: 7

## BZ.02, la build per i fondatori: cosa la fermava, e da quando

L'integrazione del fondatore porta un fatto che cambia la diagnosi: **la build
2167 e' stata prodotta da Codemagic, e' salita su App Store Connect ed e' stata
installata e provata su iPhone via TestFlight l'8 agosto 2026.** Non e' una
configurazione mai riuscita: e' un regresso, e ha una data.

### Che cosa e' cambiato dall'8 agosto, verificato sul ramo

| domanda dell'ordine | risposta, e come l'ho verificata |
| --- | --- |
| lo sbarramento esisteva gia' alla 2167? | **No.** E' entrato col commit `07e31ab6` del **12 agosto 2026**. Alla 2167 il passo delle prove portava `ignore_failure: true`, letto in `git show 07e31ab6^:codemagic.yaml`: "La suite non deve fermare la build iOS se cade per una ragione che non riguarda iOS". |
| il fuso della macchina e' cambiato? | **No, e non era mai stato dichiarato.** Il Mac di Codemagic gira a UTC e il PC del fondatore a Roma: la differenza c'era anche l'8 agosto. Le prove del cielo erano gia' rosse su UTC quel giorno (`test/un_solo_istante_test.dart` esiste dal **1 agosto**, commit `04f23af2`, e nasce con l'ora da parete `DateTime(2026, 8, 1, 18, 4)`), soltanto **nessuno le stava ascoltando**. |
| da quale momento un rosso dichiarato impedisce l'archivio? | **Dal 12 agosto**, per ogni rosso; e il rosso dichiarato dell'attribuzione cieca e' acceso dal **13 agosto** (`test/i_doni_e_la_chat_davanti_all_anatomia_test.dart`, "questa prova nasce rossa ed e' giusto cosi'"). Dal 13 agosto in poi nessuna build iOS poteva piu' uscire. |

**La riga falsa dei documenti dell'Architetto** che l'integrazione segnala non
sta in questo manifesto e non e' stata usata da nessuna parte: qui iOS risulta
provato su un dispositivo reale, ed e' il fatto del fondatore a valere.

### La prima causa: due ore di cielo

Quattro prove leggevano l'orologio da parete della macchina. Due ore di
differenza fra Roma e UTC sono **due ore di cielo**: la Bilancia chiesta a 29,4
gradi ne dava 35,14, cioe' 5,74 gradi di scarto.

| prova | cosa faceva | cosa fa adesso |
| --- | --- | --- |
| `un_solo_istante_test.dart` (tre prove) | `DateTime(2026, 8, 1, 18, 4)`, un orologio da parete | `DateTime.utc(2026, 8, 1, 16, 4)`, cioe' le 18:04 di Milano scritte come istante assoluto |
| `ronda_dei_motori_test.dart` | `DateTime(2026, 7, 30, 22, 30)`: su UTC le due stelle finivano quasi alla stessa altezza e il confronto non distingueva piu' | `DateTime.utc(2026, 7, 30, 20, 30)` |
| `daily_strip_test.dart` | longitudine `-30` battuta a mano, che e' "sessanta gradi a ovest del proprio fuso" **solo a Roma** | la longitudine si calcola dal fuso che la macchina ha: sessanta gradi a ovest, ovunque giri |

Verificate verdi a `TZ=Europe/Rome` e a `TZ=UTC`, e la prova del cielo anche a
`TZ=America/New_York`. **Una nota onesta sulla misura:** su Windows la variabile
`TZ` non capisce i nomi IANA e sposta il fuso solo di un'ora invece che di due,
quindi il PC non puo' imitare davvero il Mac. Cio' che rende sicuro il risultato
non e' la simulazione: e' che quelle prove **non leggono piu'** l'orologio della
macchina. La seconda meta' della cura e' che il fuso adesso e' **dichiarato**,
in `codemagic.yaml` (`TZ: "Europe/Rome"`) e nello sbarramento
(`export TZ="${TZ:-Europe/Rome}"`): le due macchine girano nella stessa ora.

### La seconda causa: la porta murata

Lo sbarramento conosceva due stati soli, verde e rosso. Il terzo caso vero e'
un rosso **gia' visto, gia' capito, gia' dichiarato al fondatore**, che nessuno
toglie perche' toglierlo vorrebbe dire nascondere una misura che vale.

`tool/rossi_accettati.txt` elenca quei rossi, uno per riga, col nome esatto
della prova e la ragione scritta. Oggi ne porta **uno solo**:
`l'attribuzione cieca e' valida su QUESTA istruzione`.

- suite verde: l'archivio si produce;
- suite rossa **solo** su prove elencate: l'archivio si produce, e il registro
  della build stampa ogni rosso accettato con la sua ragione;
- suite rossa su una prova **nuova**, anche una sola: l'archivio non si produce.

`SPEDISCO_SU_ROSSO` resta com'era: lo scavalco cieco che passa su qualunque
rosso stampando il proprio nome. Il registro non e' uno scavalco, perche' ogni
riga ha un nome e una ragione scritti da una persona.

**La guardia non lancia la suite**, o costerebbe tremilaottocento prove per
misurare un `if`: monta cinque rapporti finti e guarda lo sbarramento decidere.
Verde passa; rosso nuovo sbarra; rosso accettato passa e stampa la ragione;
accettato **piu'** nuovo sbarra; un rosso accettato che non cade piu' viene
segnalato come riga da togliere, perche' un registro che accumula permessi
vecchi e' il modo in cui questa cura diventerebbe il difetto di prima.

### Le altre nove guardie che erano rosse, e non c'entravano il fuso

La suite intera girata come la gira il Mac ne ha trovate altre nove, tutte
lasciate dalle mie stesse voci di oggi, tutte curate: due leggevano il TESTO di
`dimenticanza_del_telefono.dart` invece della lista viva (BZ.01), il debito dei
catch muti era sceso da sette a sei, sette stringhe nuove usavano l'apostrofo al
posto dell'accento, tre prove dell'Oroscopo misuravano i suoni senza accendere
l'interruttore e una misurava il valore di partenza invece dell'obbedienza
(BZ.05), e la coreografia della stesa ha visto il ventaglio scendere di
trentadue punti (BZ.08). **Nessuna di queste sarebbe stata trovata senza girare
la suite intera**: e' la ragione per cui si gira.

### I PASSI PER TE, MAURO, E SENZA QUESTI LA BUILD NON ARRIVA

Il lancio su Codemagic chiede l'accesso al tuo account: **nessuna credenziale
passa da qui, quindi la build la fai partire tu.** Il codice e' gia' sul server,
verificato: ramo `claude/esoteric-circle-master-order-e798aj`, commit
`638c8b8e`. Sono cinque minuti.

1. Apri **codemagic.io** e fai l'accesso.
2. Entra nell'applicazione **esoteric-circle-app**.
3. In alto a destra premi **Start new build**.
4. Nella finestra che si apre scegli:
   - **Branch**: `claude/esoteric-circle-master-order-e798aj`
   - **Workflow**: **iOS, archivio e caricamento su TestFlight**
5. Premi **Start new build**.
6. Guarda scorrere i passi. Quello che ci interessa si chiama **"Le prove,
   prima di costruire, E SONO UNO SBARRAMENTO"**: adesso deve stampare
   `ROSSI ACCETTATI, E SOLO QUELLI. L'ARCHIVIO SI PRODUCE` e andare avanti. Se
   invece stampa `ROSSI NUOVI, NON ACCETTATI DA NESSUNO`, la build si ferma li'
   apposta: mandami quel pezzo di registro col nome della prova.
7. Metti in conto una ventina di minuti, e ricorda che si scalano dai
   cinquecento del mese.
8. Finita la build, la trovi su **TestFlight** come build **2212**. Arriva
   anche una email a `cloud@esotericircle.app`.

**Perche' non parte da sola**: `codemagic.yaml` non ha nessuna sezione
`triggering`, quindi nessuna push fa partire niente. Si puo' aggiungere, e
vorrebbe dire che ogni push consuma minuti del Mac: **e' una tua decisione**,
non la prendo io.

## BZ.04, le notifiche non arrivavano, e la causa era una riga

**Parole del fondatore:** "LE NOTIFICHE NON FUNZIONANO! Stamattina e oggi me ne
sarebbero dovute arrivare 3 invece nemmeno una."

**La causa, contata nel codice.** Le cinque chiamate del giorno si programmano
a ogni avvio dall'ordine BC voce 05, ma la prima riga di
`programmaLeChiamateDelGiorno` e' "senza permesso non parte niente", e il
permesso del sistema **l'app lo chiedeva in DUE SOLE schermate**: il Rito
dell'Alba e il menu' Notifiche. Da Android 13 le notifiche nascono NEGATE, e
chi non e' mai entrato li' dentro non ha mai visto il dialogo di sistema:
`permessoConcesso` rispondeva no a ogni avvio, e non veniva programmata
**nemmeno una** chiamata. L'app credeva di averle chieste; il telefono non ne
aveva in coda nessuna.

**Perche' nessuna prova lo aveva visto.** Tutte le prove degli avvisi
costruiscono il servizio finto con `permesso = true`, cioe' misurano la catena
a permesso gia' concesso. Ogni misura vera, la conclusione falsa: la catena
funziona, e non parte mai.

**La cura.** All'avvio, **una volta sola nella vita dell'installazione** e solo
a chi e' gia' dentro il Cerchio, si mostra la stessa spiegazione delle altre due
porte, che nomina i cinque Doni e le loro ore, e poi si chiede al sistema. Una
volta sola perche' su Android il dialogo compare una volta e poi il no diventa
definitivo: insistere non aggiunge una possibilita', la toglie. A chi sta
entrando nel Cerchio non si chiede niente, perche' un foglio di sistema sopra
la prima impressione dell'app e' il modo piu' rapido di farsi dire di no.

**Il rosso**, misurato su **quante chiamate il sistema del telefono ha in coda
dopo un avvio**, che e' la grandezza che l'ordine chiede per nome: **5 su 5**
con la cura e il permesso chiesto una volta, **0 su 5** e zero richieste senza.

**Cosa devi guardare tu sul telefono**, perche' una prova non puo' vederlo: al
primo avvio della build nuova deve comparire il foglio "Posso chiamarti quando
e' l'ora?". Se lo accetti, da quel momento le cinque chiamate sono in coda. Se
il foglio non compare, vuol dire che il permesso risulta gia' concesso, e
allora il difetto era altrove: dimmelo.

## BZ.06, la riflessione dell'Oroscopo

**Parole del fondatore:** "parte una animazione strana che dura una frazione di
secondo... si formano dei piccoli cerchi gialli intorno all'emblema del segno e
sotto appaiono delle parole... mi sembra cmq scarsa."

Tre cose, tutte misurate a video.

| cosa | prima | adesso |
| --- | --- | --- |
| la riflessione piena | 2.800 millesimi | **4.000** |
| la riflessione breve, dalla seconda interrogazione del giorno | 1.000, cioe' la frazione di secondo | **3.000** |
| la corona dei corpi in scena | 19 fotogrammi su 39 | **39 su 39** |
| i glifi dei corpi | nessuno, dischi dorati nudi | **dieci**, dal Sole a Plutone |
| il tempo davvero a video | 2.700 millesimi | **3.900** |

**Era la riflessione BREVE il difetto**: due momenti da mezzo secondo per chi
aveva gia' interrogato il cielo quel giorno.

**I cerchi gialli erano cerchi gialli.** I dischi non portavano nessun simbolo
perche' quando la corona nacque il font `NotoSansSymbols` non era un asset del
repository; ci e' entrato con la cura del bosco, quindi adesso ogni corpo porta
il suo glifo e i dischi crescono da 20/16/11 a 30/26/20 punti perche' il glifo
si legga. **Anteprima**: `docs/preview/oroscopo-riflessione.png`.

**I due tetti delle schede si spostano con lei**, da 3,5 e 6,0 secondi a 5,0 e
7,0: e' la stessa legge dell'ordine BK applicata a una riflessione che il
fondatore ha chiesto piu' lunga, e la finestra 2,8-3,2 secondi di quell'ordine
non vale piu' perche' questa decisione e' dopo.

## BZ.09, la Sinastria VIP parte dal confronto

**Parole del fondatore:** "LA SINASTRIA VIP DEVE PARTIRE con la schermata dove
ci sono le 2 carte in alto dove l'utente puo' scegliere il VIP a destra e a
sinistra c'e' la carta dell'utente con titolo sopra La Tua Compatibilita' con un
VIP. L'elenco delle carte adesso sono in ordine, ma andrebbero un po'
ingrandite."

**Cosa c'era.** La galleria si apriva sulla barra di ricerca e sulla tendina
delle categorie: chi entrava vedeva un catalogo e doveva capire da solo cosa ci
si facesse.

**Cosa c'e' adesso**, in cima a tutto: il titolo, e sotto le due carte, la tua a
sinistra e il segnaposto da scegliere a destra, col cuore in mezzo. Il
segnaposto **non porta nessun VIP scelto dall'app**: al tocco porta l'occhio
alla lista. Un'app che sceglie per te e' esattamente il difetto del confronto
che dava sempre Angelina Jolie.

**DOVE SONO FINITE LE DUE FUNZIONI VIRALI**, che l'ordine chiede di dichiarare:
**non si sono mosse**. Stanno subito sotto l'intestazione nuova, nello stesso
ordine di prima, e la prova pretende che ci siano tutte e due: "Trova il tuo
gemello astrale VIP" e "Confronta 2 VIP".

**Le carte della lista**: il massimo della colonna passa da 132 a 168, quindi le
colonne da tre a due, e il ritratto **dipinto** da 101 a **165 punti**. Era il
conto delle colonne a decidere la misura, non la spaziatura.

**Una guardia sorella e' stata cambiata, non abbassata**: "in scena ci sono
almeno sei ritratti" diventa quattro, perche' con due colonne in una schermata
ne entrano meno, e **al suo posto entra la larghezza minima**, che e' la
grandezza che il fondatore ha chiesto. **Anteprima**:
`docs/preview/sinastria-galleria.png`.

## BZ.05, gli effetti sonori nascono spenti

Parole del fondatore: "gli effetti sonori vanno per ora disabilitati per
default, almeno fino a quando non ne scegliero' qualcuno decente, adesso
sembrano un giochino anni 80".

L'interruttore resta dov'era e funziona come prima: cambia solo da dove parte.
**La vibrazione non e' toccata**: l'ordine chiede il silenzio dei suoni.

**Il rosso**: rimesso il valore di partenza a vero, la prova nuova stampa "su un
telefono nuovo suonano 8 responsi su 8" e cade. Con la cura ne suonano **0 su
8**.

L'idea di un set di effetti diverso per ogni Maestro resta **non decisa**, come
il fondatore l'ha lasciata ("e forse sarebbe meglio"): non l'ho costruita.

## BZ.07, Medora da sola prima della riflessione

Parole del fondatore: "prima di tutto si vede per un secondo circa Medora da
sola e poi parte l'animazione: ELIMINA LA PRIMA PARTE DOVE SI VEDE MEDORA DA
SOLA".

**Cosa c'era davvero.** Alla terza carta la stesa diventa compiuta, e da quel
momento la scena si svuotava: il pannello, il ventaglio e i tre slot sono appesi
a `!_complete`, il responso e le sue carte a `_responsoInScena`, che e' falso
finche' Medora non ha finito di pensare. Nel buco restava il solo ritratto, e
dentro il buco giravano **due animazioni che nessuno poteva vedere**: la
fioritura dell'elemento della terza carta (780 o 1100 millesimi) e il filo fra
le carte dell'ordine BN voce 08 (altri 720).

**Il filo non e' stato tolto**, perche' dice che le tre carte sono una lettura
sola: si e' rimesso in scena cio' su cui il filo corre. Adesso chi sceglie
l'ultima carta la vede fiorire e vede le tre legarsi, e poi Medora pensa.

**Il rosso, misurato sui fotogrammi**: dal tocco dell'ultima carta al responso
sono sessanta fotogrammi, e sedici non mostravano ne' le carte ne' la
riflessione, dai 700 ai 2300 millesimi. Adesso sono **zero su sessanta**, e le
carte ci sono in tutti e sessanta.

**Una cosa trovata dall'anteprima e non da una prova**: rimettendo gli slot in
un punto diverso della lista, Flutter li considerava widget nuovi, buttava lo
stato e le tre carte **rigiravano sul dorso**. Si vede in
`docs/preview/stesa-dopo-l-ultima-carta.png`, che alla prima stesura mostrava
tre dorsi. Adesso gli slot passano per una chiave globale e l'elemento trasloca
invece di rinascere.

## BZ.08, la carta chiave

Parole del fondatore: "la Carta chiave evidenziata da cornice azzurra FA ANCORA
SCHIFO: va bene la carta ingrandita, ma sopra bisogna scrivergli 'Carta Chiave'
ed e' meglio diminuire la grandezza delle altre 2 carte".

La cornice azzurra era il **terzo** tentativo di dire con un colore cio' che
adesso dicono due parole: alone d'oro (BN.05), sola linea azzurra (BU.02), linea
piu' spessa con la carta cresciuta (BV.04). Non c'e' piu'.

Le tre misure, **sui pixel dipinti** e non sui riquadri di layout, col metodo
dell'ordine BA:

| grandezza | prima | adesso |
| --- | --- | --- |
| altezza della carta chiave contro le vicine | 162,8 contro 148,0, cioe' +10,0 per cento | 162,8 contro 127,3, cioe' **+27,9 per cento** |
| azzurro sopra la carta chiave | 0 pixel (non c'era niente scritto) | **127 pixel**, contro 0 e 0 sopra le altre due |
| dove finiscono le parole | non esistevano | finiscono a 437, la carta comincia a 442,8: stanno **sopra**, non addosso |

Con venti punti di intestazione la carta, che e' scalata, saliva a coprirle di
nove: adesso l'intestazione e' trentadue punti e si riserva **solo a responso in
scena**, perche' mentre si pesca nessuna carta e' ancora la chiave e quei punti
spingevano il ventaglio fuori portata.

**Le tre carte restano dentro lo schermo anche a 320 di larghezza**, che e' il
piu' stretto in commercio, oltre ai due schermi bassi che la guardia gia'
provava.

**I due rossi**: rimesse le vicine a 1,0 lo scarto torna al 10,0 per cento e la
guardia cade; tolte le parole cadono tre guardie, con zero pixel di azzurro
sopra la chiave.
