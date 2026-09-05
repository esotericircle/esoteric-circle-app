# ORDINE CI, CORREZIONE DELLE CHAT CON I MAESTRI

Manifesto dell'ordine CI del 1 settembre 2026. Guardie: `test/screenshot_capture_test.dart` per CI.01 e CI.04, `test/il_censimento_dei_grigi_test.dart` per CI.02 e CI.08, `test/il_microfono_della_chat_test.dart` per CI.05, `test/le_push_sono_montate_test.dart` per CI.07, `test/una_conversazione_nuova_non_cancella_test.dart` per CI.06.

**La regola zero vale anche qui**, e ha reso: **tre premesse su cinque sono cadute**, e in due casi il difetto vero era diverso e peggiore di quello descritto.

## Le otto voci

- **CI.01** I testi sovrapposti all'apertura. **CHIUSA.**
- **CI.02** La scritta blu del primo giorno. **CHIUSA.**
- **CI.03** La striscia di scrittura resta a meta' schermo. **CHIUSA.**
- **CI.04** La scritta gialla ESPLORA non scompare mai. **CHIUSA.**
- **CI.05** La dettatura vocale del messaggio. **CHIUSA.**
- **CI.06** Iniziare una conversazione nuova. **CHIUSA.**
- **CI.07** Le notifiche push non possono arrivare. **CHIUSA** per la parte che vive sul telefono; la prova da capo a fondo resta impossibile finche' il fondatore non distribuisce.
- **CI.08** La riga I GIORNI PRIMA e' illeggibile. **CHIUSA.**

VOCI_TOTALI: 8
VOCI_CHIUSE: 8
VOCI_APERTE: 0
VOCI_FERMATE_SU_PREMESSA_FALSA: 0
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0
VOCI_FERMATE_SU_DECISIONE_DEL_FONDATORE: 0

## LE PREMESSE, VERIFICATE UNA PER UNA

| premessa | esito | la misura |
| --- | --- | --- |
| P1 | **FALSA** | Non sono due gruppi di widget montati insieme, e non e' impaginazione. Sono il benvenuto e il **COMPOSITORE**, e solo col testo al massimo consentito, 1,3: il saluto va a tre righe, finiva a 599, il compositore comincia a 571. **Ventotto punti di testo dietro i pulsanti**, misurati e identici sui tre Maestri. A scala uno non si vede niente, ed e' il motivo per cui nessuna prova lo ha mai preso |
| P2 | **FALSA come alternativa** | E' tutte e due le cose, e la seconda e' la causa: il colore viene dal tema, ma non da quello sbagliato, da **nessuno**. Un `TextButton` nudo prende il primario dello schema Material, che e' quello della tavolozza NEUTRA, e infatti il viola era identico su Medora, Aura e Caligo. Contrasto misurato da **2,33 a 2,56** |
| P3 | **VERA** | `CustodeDellePush` cercato in tutto `lib`: l'unico posto che lo nominava era il file che lo dichiara. Non era montato da nessuna parte |
| P4 | **FALSA** | Il censimento guardava gia' gli ori e le tinte dei tre Maestri, che colori pieni sono. La cecita' e' un'altra e peggiore: **legge i sorgenti cercando `color:`**, quindi vede solo i colori che qualcuno ha SCRITTO, e un widget che se lo prende dal tema per lui non esiste |
| P5 | **VERA** | `git log -S "_IGiorniPrima"`: nasce col commit `4315ef85`, che e' CG.01 |

## LE DECISIONI PRESE PER DELEGA, E PERCHE'

### CI.01, a cedere e' il busto e non il testo

Lo spazio del compositore c'era gia', ma stava come **riempimento in fondo al contenuto**: serve solo quando il contenuto va scorso, perche' allora tiene l'ultima riga sopra i pulsanti. Quando invece ci sta, la colonna si appoggia in cima, quel riempimento diventa vuoto sotto di lei e la coda del testo cade dove ci sono i pulsanti. Adesso si toglie dalla **viewport**.

Tolta la sovrapposizione, il saluto usciva **TAGLIATO**: un difetto scambiato per un altro, ed e' il motivo per cui questa voce ha due meta'. La scelta era fra rimpicciolire una figura e nascondere una frase: si rimpicciolisce la figura, perche' la frase e' la prima cosa che il Maestro dice e la figura si vede comunque. Busto da 300 a **248** punti, con un minimo dichiarato di 160 e il saluto misurato col `TextPainter` allo stesso scaler con cui verra' dipinto.

**Misura finale**: saluto fino a 547, compositore da 571, **24 punti di margine**, uguale sui tre Maestri.

### CI.03, il campo segue la barra dipingendosi altrove

La misura che l'ordine chiedeva: il campo **non e' ancorato a ESPLORA**, e' ancorato al fondo del contenitore con uno scarto costante pari all'altezza della barra. Quindi non si muove mai, ed e' proprio quello il difetto: quando la barra si ritira, sotto il campo resta una fascia vuota alta 112 punti.

Quella fascia era voluta, regola del 6 agosto 2026: lo spazio riservato e' costante perche' commutarlo vuol dire **rilayare**, misurato a 123 punti di salto in chat. Il compromesso fu dichiarato allora con le parole "se non piacera' si decidera' guardandola": il fondatore l'ha guardata.

**La decisione**: lo spazio riservato non si tocca, quindi nessun rilayout e la regola del 6 agosto resta intera; cambia solo **dove il campo si dipinge**, che segue la corsa della barra con una traslazione, in fase di disegno. Cosi' valgono tutte e due le cose che l'ordine chiede, il campo sta in fondo e l'apertura o la chiusura della barra non sposta nulla di cio' che sta sotto, perche' sotto non c'e' piu' niente da spostare.

### CI.04, il residuo non era un residuo: era una transizione senza fine

La linguetta legittima **qui non esiste**: `BarraDelCerchio.corsa` e' l'altezza intera e il file lo dichiara, "qui non resta nessuna linguetta". Quindi il residuo non era la linguetta.

La causa vera: la barra reagiva a `ScrollUpdateNotification` e `OverscrollNotification`, e **non a `ScrollEndNotification`**. Non esisteva nessuno stato finale: la barra restava dove il dito la lasciava, quindi uno scorrimento breve la fermava a meta' e mezza ESPLORA ci restava fino allo scorrimento dopo. **Misurato**: a meta' gesto se ne vedevano 52 punti, a dito alzato 52. Adesso a dito alzato va all'estremo piu' vicino: 52 prima, **2** dopo.

### CI.05, la dettatura, e un errore mio corretto in corsa

I sei vincoli sono rispettati. Quello che ho sbagliato e che vale la pena scrivere: `initialize` del riconoscitore **chiede il permesso del microfono da se'**, e lo chiamavo dentro `disponibile()`, cioe' all'apertura della chat. Sarebbe stato esattamente il dialogo di sistema che la sezione 25 vieta. Adesso `disponibile()` guarda solo la piattaforma, e l'accensione, col permesso, avviene al primo tocco.

**La richiesta vera passa dalla porta di casa**: `PortaDelPermesso.chiedi` riceve l'accensione del riconoscitore come richiesta di sistema, non un si' di comodo, altrimenti la riga del no non sarebbe mai comparsa.

**E la forma del compositore**, chiesta dal fondatore mentre l'ordine era in corso: Suggerimenti sopra, "Scrivi a nome" sotto, le due bolle larghe uguali, la bolla della freccia accanto a tutte e due. Il microfono sta **dentro** il campo, perche' dettare e' un modo di scrivere, mentre la freccia manda ed e' un'altra cosa.

### CI.06, la conversazione e' una MARCATURA, e il numero

**Aprire la chat costa 40 letture in tutti e due i modi**, perche' il limite e' `limit(40)` e non cambia. La differenza sta altrove.

- **Marcatura nella stessa collana**: cominciare una conversazione nuova costa **0 letture e 0 scritture**. La marcatura viaggia col prossimo messaggio, e i messaggi vecchi restano senza marcatura, che vuol dire "la prima conversazione". **Nessuna migrazione.**
- **Documento a parte**: a un milione di persone con quaranta messaggi ciascuna, la migrazione sono **40 milioni di scritture** per un beneficio che nessuno vede. E l'indice dei Ricordi dovrebbe imparare un secondo indirizzo per lo stesso messaggio.

La scelta e' la marcatura.

## LE GUARDIE CIECHE TROVATE

**Quattro, e due le ho create io in questo stesso ordine.**

1. **Il censimento del contrasto legge i sorgenti cercando `color:`.** Vede solo i colori scritti, e un widget che se lo prende dal tema per lui non esiste: e' cosi' che il viola di "I giorni prima" e' arrivato a schermo. Adesso ci sono due prove nuove, e nessun comando di testo puo' piu' ereditare il colore in silenzio.
2. **La cattura "barra-chat-fuori" si regge su uno scorrimento**, e la voce CI.01 ha reso la chat vuota abbastanza corta da non scorrere piu': fotografava la barra **dentro** sotto quel nome. L'ho creata io, correggendo CI.01, e l'ho trovata subito perche' ho guardato l'immagine. Adesso pretende il suo stato col numero: al massimo 8 punti di barra su 112 possono restare a schermo.
3. **Le prove del custode delle push lo costruivano a mano.** Funzionava benissimo, provato, e non serviva a nessuno perche' nessuno lo montava. **Una classe con le sue prove verdi che non e' agganciata a niente e' il caso peggiore, perche' sembra fatta.**
4. **Il filtro Conversazioni dei Ricordi era vuoto per costruzione.** Esistevano il tipo e il filtro, e nessuno ci scriveva niente. Trovato solo perche' l'ordine chiedeva di **verificare che ci arrivi davvero, non che dovrebbe arrivarci**.

Le ultime due sono la stessa famiglia: qualcosa di dichiarato, provato, e non collegato. In tutti e quattro i casi la prova era verde e la cosa non c'era.

## LE TRE RIGHE CHE L'ORDINE CHIEDE IN FONDO

### Cosa NON e' verificabile senza il deploy dal PC di Mauro

**Che una notifica push arrivi.** Il telefono adesso registra il suo recapito, lo rinnova e lo toglie quando il diritto finisce, e tutto questo e' provato. Ma il giro che spinge vive in `functions/src/push.ts` e **non e' distribuito**: finche' non lo e', nessuna push parte da nessuna parte. Le istruzioni stanno in `docs/ordini/DISTRIBUZIONI_DAL_TUO_PC.md`, passo 5.

**Cosa ho potuto provare**: che il recapito si registra, che si rinnova quando il sistema lo cambia, che si toglie a chi non ha diritto, e che solo i Doni accesi nel menu' salgono. **Cosa no**: che una notifica compaia su uno schermo.

### Quante coppie di colori pieni non passano la guardia estesa

**Ventisei su ventotto.** I quattro primari delle tavolozze contro i sette fondi veri del censimento: solo `aura.primary` sul fondo piu' scuro (6,14) e sulla casa di Medora (4,91) superano la soglia dei titoli grandi. Tutte le altre stanno **fra 1,40 e 4,39**.

Non sono difetti da correggere uno per uno: i primari sono **colori di marchio**, stanno benissimo su un bordo, un riempimento o un anello, e non devono portare testo mai. La regola nuova e' quella, e la guardia la fa valere sui comandi che il colore non lo dichiarano: 76 `TextButton` censiti, **17 deroghe** dichiarate per nome, e l'elenco puo' solo accorciarsi.

### Altre voci dichiarate chiuse che chiuse non erano

**Una: CG.16.** Era **CHIUSA** nel manifesto dell'ordine CG e dichiarava chiuso cio' che non funzionava, perche' il manifesto registrava quello che era stato **costruito** e non quello che **arrivava a una persona**. Corretta il 1 settembre 2026: adesso e' **APERTA**, con la data, la ragione e il modo in cui l'errore e' stato possibile.

Una riga che dichiara il falso in un manifesto e' peggio del difetto che nasconde, perche' chi legge non va a guardare una voce chiusa.
