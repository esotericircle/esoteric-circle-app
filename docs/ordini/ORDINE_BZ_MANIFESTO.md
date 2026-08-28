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
- **BZ.04** Le notifiche non arrivano. **APERTA.**
- **BZ.05** Gli effetti sonori nascono spenti. **CHIUSA.** Su un telefono appena
  installato suonano zero responsi su otto; l'interruttore resta dov'era.
- **BZ.06** L'animazione di riflessione dell'Oroscopo. **APERTA.**
- **BZ.07** Medora da sola prima della riflessione. **CHIUSA.** Erano sedici
  fotogrammi su sessanta, cioe' un secondo e sei decimi. Adesso sono zero.
- **BZ.08** La carta chiave. **CHIUSA.** La cornice azzurra non c'e' piu': sopra
  la carta c'e' scritto Carta Chiave e le altre due sono piu' piccole.
- **BZ.09** La Sinastria VIP parte dal confronto. **APERTA.**

VOCI_TOTALI: 9
VOCI_APERTE: 3
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0
VOCI_FERMATE_IN_ATTESA_DELLE_MANI_DEL_FONDATORE: 1
VOCI_FERMATE_SU_PREMESSA_FALSA: 0
VOCI_FERMATE_SU_DECISIONE_DEL_FONDATORE: 1
VOCI_CHIUSE: 4

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
