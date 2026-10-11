# LA POSIZIONE: CARTA SOLA

La carta sola della stesa a una carta.

**Fonte da riempire.** Per ogni carta e per ogni verso tre varianti dello
stesso scheletro, `- 1:`, `- 2:`, `- 3:`, scritte dall'Architetto (ordine FI,
aggiunta A1 e A4). Una riga vuota e' un testo che non c'e' ancora. Una
variante e' piena in tutte le 156 carte-verso o vuota in tutte: a meta', il
tool si ferma e nomina le righe che mancano.

**Regole dei testi** (voce FI.23, le stesse del corpus del 27 settembre):
una o due frasi fra 110 e 280 caratteri, rivolte alla persona col tu. Ne' il
nome della carta ne' il suo verso. Nessuna parola che dia un genere a chi
legge, oppure la marca intera `[maschile|femminile|neutra]`. Niente cifre,
niente la parola voce, niente trattino lungo, mai una virgola seguita da "e"
o "ed", accenti veri. Nessuna previsione certa, solo tendenze; nessuna
promessa su salute, denaro, leggi o morte. Le tre varianti di una carta
cominciano con parole diverse; nessun doppione e nessuna coppia con
somiglianza di Jaccard sopra 0,6.

**Come si tocca.** Si riempie qui, poi si rilancia
`python tool/genera_carte_nella_posizione.py`, che controlla e scrive
`lib/core/tarot/le_carte_nella_posizione_dati.dart`.

**Le tre varianti vengono dal corpus dell'11 ottobre 2026**, scritte
dall'Architetto con sei scrittori che hanno lavorato separati, ciascuno su
tredici carte. La posizione nasce con la specifica
`posizione_carta_sola.md`, che decide tre cose che la fonte non decide,
dichiarandole nostre: che la carta sola **risponda** invece di ritrarre,
dato che l'unico uso documentato della carta singola e' il Significatore;
che **non tenga il registro di consiglio** della fonte dei significati, pur
recuperandone la materia voltata in forza, perche' un consiglio su una carta
sola e' la cosa piu' vicina a una promessa che il Cerchio vieta; e che non
abbia nessuna collocazione nel tempo.

**Lo stampo e' stato prevenuto invece di corretto, e qui c'e' una misura.**
La specifica porta un repertorio di otto vie scritto **prima** che gli
scrittori lavorassero, perche' la misura dell'11 ottobre ha stabilito che
uno stampo nasce dove una specifica vieta qualcosa senza dare
l'alternativa. Il risultato: l'apertura piu' frequente di questa posizione
compare in **quindici testi su quattrocentosessantotto**, mentre nella
posizione ESITO, scritta senza repertorio, l'apertura piu' frequente ne
occupava quaranta e quattro parole di cornice stavano fra il ventidue e il
quarantanove per cento dei testi. Qui nessuna parola di cornice supera il
quindici per cento e le quattro che lo superano sono parole funzionali.

**Il livello misurato, col disegno con cui e' stato ottenuto**, come la sezione
21.4 del metro prescrive. Prova cieca appaiata contro la posizione LATO, dodici
lettori che non sapevano quale testo venisse da quale posizione, 936 testi nello
stesso giro: **questa posizione sta al 93,8 per cento di carte riconosciute, il
LATO al 95,3**. Divario meno uno virgola cinque punti con errore standard due
virgola uno, cinque lettori a favore dell'una e sei dell'altra: **le due
posizioni non si distinguono**. Il tiro a caso vale l'1,3 per cento.

**Che cosa dice questo numero, ed e' il motivo per cui vale la pena scriverlo
qui.** Il LATO ha raggiunto il suo livello **in tre stesure e tre prove cieche**,
con un rifacimento di novantatre testi dal cardine differenziale. Questa posizione
lo raggiunge **in un giro solo**, perche' gli scrittori avevano in mano dall'inizio
cio' che al LATO e' stato scoperto per tentativi: la mappa delle gemelle con il peso
di ogni scambio, l'elenco delle carte che la fonte non distingue, il cardine da
scrivere in positivo e il repertorio contro lo stampo.

Dei centocinquantasei gruppi, **centoquarantotto sono sani** e **nessuno e'
sbagliato da entrambe le posizioni della prova**, cioe' nessuna carta risulta
irriconoscibile per un difetto della fonte. Sei gruppi di questa posizione restano
sotto soglia e vanno rifatti: Il Mago capovolta, Asso di Denari capovolta, Gli
Amanti capovolta, Dieci di Spade capovolta, Nove di Denari capovolta, Otto di Coppe
capovolta.

## Il Matto

### dritta

- 1: Un inizio ti chiama con le mani vuote, senza preparativi da sbrigare prima e senza pesi addosso. Vedi soltanto il primo passo e il resto si mostra mentre cammini.
- 2: La mano vuota basta a questa apertura e la meta resta invisibile: il coraggio ha la faccia della leggerezza e ti muove prima che tu veda dove finisce.
- 3: Hai davanti un principio senza corredo: nessun piano stilato, nessuna garanzia in tasca, nessuna veduta fino in fondo. Ti muove la fiducia nel movimento iniziale.

### capovolta

- 1: Il piede è sull'orlo e sotto non c'è terra: la spinta che senti non porta ancora un nome, coraggio oppure fuga da una cosa non guardata. Nessuna rotta è stata scelta.
- 2: Resta senza nome la provenienza di questa spinta: il volo ti attira e l'orlo ti trattiene, con nessuna direzione presa e il fondo che non si vede.
- 3: Sotto il piede non c'è fondo e la spinta che ti porta là manca di un'origine riconosciuta: può nascere dal coraggio oppure da una fuga. La partenza resta aperta in entrambi i casi.

## Il Mago

### dritta

- 1: Il tavolo davanti a te è già apparecchiato con tutto l'occorrente e nessun mezzo arriva da fuori: una facoltà tua converte sul posto l'idea in parola detta e in cosa esistente.
- 2: Quello che hai pensato trova una mano capace di eseguirlo senza aspettare nessuno. La volontà e l'abilità stanno in te e un'intenzione esce dalla testa come oggetto.
- 3: Hai davanti tutti i mezzi e dietro nessuna attesa. Fra l'idea e l'atto non resta niente da procurarsi e il potere che ti riguarda è reale, non promesso da una condizione.

### capovolta

- 1: Un talento compiuto riposa dentro un cassetto chiuso, oppure l'annuncio che fai copre una misura che le mani non raggiungono. Il dono è tuo per intero e lo scarto sta fra il dire e il fare.
- 2: Le parole che pronunci promettono più di quanto le tue mani portino a termine, mentre la capacità che possiedi resta piegata in un cassetto come una cosa mai messa in uso.
- 3: Fra l'intenzione che dichiari e l'atto che segue si è aperto uno spazio vuoto. Il dono che lo riempirebbe sta dove lo hai posato, chiuso e senza un graffio.

## La Papessa

### dritta

- 1: Il silenzio che tieni fa il lavoro da sé: un sapere tuo privo di parole si compone per conto suo e matura proprio nel tempo in cui resta non detto.
- 2: Quello che sai di questa cosa precede le parole: la sostanza ti è chiara mentre i motivi restano in penombra e si schiariscono soltanto nella mente quieta.
- 3: Lenta e muta, un'intuizione tua ti informa della sostanza di una cosa molto prima che tu sappia dirne il motivo. Nel buio cresce senza bisogno di traduzione.

### capovolta

- 1: La ragione e il rumore ti servono da coperta su un intuito che sa già: lo spieghi, lo discuti, lo riempi di suoni e intanto quello che sentiresti fermandoti resta sotto.
- 2: Argomenti solidi e giorni pieni di rumore fanno due cose insieme: tengono in ordine i tuoi pensieri e coprono una percezione tua che sa, quella che temi di sentire se ti fermi.
- 3: Un sapere tuo ti aspetta sotto il frastuono e sotto le spiegazioni che gli metti davanti. Quello che temi di sentirgli dire è la ragione per cui il rumore ti resta comodo.

## L'Imperatrice

### dritta

- 1: Abbondanza che nutre: lavora su una cosa già viva dentro di te, un progetto avviato, un legame che respira. La porta a maturazione con un passo lento che non si lascia accorciare.
- 2: La cura delle cose vive si allarga e si fa fertile: la pianta già partita trova calore, nutrimento e il tempo pieno che le serve per venire a frutto.
- 3: Fiorisce la semina già fatta, al ritmo della terra buona: morbidezza nel trattare, dolcezza nei modi e una pazienza larga che lascia alla maturazione la sua misura.

### capovolta

- 1: La fertilità si è ritirata dentro: quello che avevi cominciato a far crescere si è fermato, perché il nutrimento che gli serviva è uscito tutto verso l'esterno. La radice ne riceve l'ultima parte.
- 2: Creatività ferma e radice asciutta: la cura esce puntuale verso tutto il resto, mentre il punto da cui nascono le tue cose riceve l'ultima parte, quando ne avanza.
- 3: Manca linfa proprio dove nasce il nuovo: fuori niente sboccia, perché la pianta non riceve dalla propria radice la parte che la radice ha dato via.

## L'Imperatore

### dritta

- 1: La disciplina fa da cornice e regge i bordi dell'opera mentre dentro cresce quello che stai costruendo. A tenerla ferma c'è una responsabilità firmata col tuo nome.
- 2: Il fondamento viene prima di ogni altra cosa. Pilastri fissati, misure decise, una forma che l'opera non può più perdere. Questa fermezza risponde di quello che regge e sul progetto sta scritto il tuo nome.
- 3: Qui le responsabilità hanno un titolare e la costruzione sta in piedi anche quando nessuno la guarda. Sostiene chi ci abita dentro. Il rigore sta tutto nella regola.

### capovolta

- 1: Le regole sono il materiale in gioco. Troppe e troppo strette stringono il respiro di chi ci sta dentro, oppure mancano del tutto e l'impalcatura oscilla a ogni passo.
- 2: Un'autorità comanda l'orario, i turni, le misure, la tua oppure quella di qualcun altro. L'edificio che ne nasce o schiaccia le persone che ci vivono o sta su senza fondamenta.
- 3: L'ossatura conta, non l'arredo: il regolamento, la gerarchia, quello che si può ancora decidere e quello che è già deciso. Dove è troppo fitta toglie aria, dove è assente lascia tutto in bilico.

## Il Papa

### dritta

- 1: Chi insegna da una scuola vecchia di secoli ti istruisce con parole che altri hanno già ricevuto e l'autorità di quelle parole non viene da lui ma dalla fila di chi le ha ripetute prima di lui.
- 2: Un sapere che molti hanno ricevuto prima di te sta in piedi senza il tuo consenso e intanto si offre al tuo esame: appartenere a qualcosa di più antico ti dà fondamento e ti lascia la testa libera.
- 3: La tradizione lavora sulla tua capacità di imparare da qualcuno in carne: mette davanti a te chi ne sa più di te, gli concede autorità sulle parole e non sul tuo giudizio, poi ti porta al punto in cui sai stare senza di lui.

### capovolta

- 1: Un precetto imparato a memoria continua a ripetersi e non spiega più quello che vivi. Non è rivolta: è una statura tua che ha superato quella di chi te lo ha insegnato.
- 2: La dottrina ricevuta resta in piedi dove l'hai trovata mentre il tuo senso proprio si sposta altrove e si riconosce dal respiro che ti lascia, non dall'autorità di chi lo ha pronunciato.
- 3: Il dover essere che ti è stato insegnato lavora ancora sulla tua obbedienza e non più sul tuo discernimento: quello che davvero ti appartiene si cerca anche fuori dalla scuola che te lo ha consegnato.

## Gli Amanti

### dritta

- 1: Un affetto ti mette davanti a una decisione che chiama in causa quello in cui credi, non il desiderio di passaggio. Sentimento e giudizio lavorano sullo stesso atto e nessuno dei due lo chiude da solo.
- 2: Davanti ti sta una scelta che mette alla prova i tuoi valori e non soltanto quello che ti attira: il desiderio solleva la domanda, il credere porta il criterio. La decisione si prende a occhi aperti.
- 3: Nessuna metà di te decide da sola: l'attrazione dice che cosa vuoi e i tuoi valori dicono che cosa regge. L'accordo fra le due è la cosa che questa scelta mette in gioco.

### capovolta

- 1: Il disaccordo è interno e i due che si fronteggiano ti appartengono entrambi, quello in cui credi e quello che desideri. Uno dei due è stato messo a tacere, perciò l'altro non riesce a convincerti.
- 2: Due cose tue si contendono la stessa decisione, nessuna venuta da fuori: il credere e il volere. Una delle due è muta e per questo l'altra non persuade, nemmeno quando la ripeti.
- 3: Nel bivio che ti blocca entrambi i termini portano la tua firma: uno è un valore e l'altro un desiderio, mentre la trattativa da aprire non riguarda un'altra persona ma loro due.

## Il Carro

### dritta

- 1: Le redini stanno in una mano sola e le due spinte che tirano da parti contrarie restano opposte, aggiogate allo stesso carico. La vittoria che ti riguarda è un'opera di governo.
- 2: Tirano in direzioni contrarie e avanzano insieme: il traino tiene perché il tuo sguardo non si stacca dalla mira e le cinghie restano corte nella mano che le regge.
- 3: Sotto un comando unico due energie avverse lavorano per te e lo slancio che ne esce è governato. La mano che tiene le redini decide quanto quel tiro corre.

### capovolta

- 1: Allentate le redini, il tiro continua a muoversi. Due spinte contrarie ti portano fuori linea, oppure la corsa prosegue senza una mira scelta.
- 2: Il centro che teneva insieme le spinte si è spostato e il tiro sbanda sotto le tue mani. La guida torna da una sosta breve e rallentare non è debolezza in chi conduce.
- 3: Corri con lo slancio pieno mentre il governo vacilla e le spinte che andavano insieme tirano ognuna per sé, col tiro che va dove nessuna mira lo manda.

## La Giustizia

### dritta

- 1: Quello che hai messo nel piatto torna misurato sullo stesso piatto: l'effetto che raccogli ha esattamente la tua misura, né alleggerito da uno sconto né gonfiato da una colpa che non è tua.
- 2: Una bilancia tiene il conto dei tuoi atti e li pesa uno per uno: ti attribuisce quello che hai fatto davvero e lascia fuori quello che altri ti mettono addosso.
- 3: Causa ed effetto lavorano nei due sensi: la responsabilità che è tua ti resta attaccata e il merito che è tuo ti viene riconosciuto, con la stessa esattezza di misura.

### capovolta

- 1: Una conseguenza delle tue scelte gira senza padrone perché l'hai intestata al caso o a qualcun altro: il tuo nome ci resta sopra comunque e l'equilibrio aspetta che tu lo rilegga.
- 2: Quello che resta in sospeso non è l'effetto ma il nome di chi l'ha prodotto: una tua mossa ti somiglia e tu la attribuisci al caso oppure a qualcun altro.
- 3: Senza accusarti di niente, una cosa che hai causato resta appesa al tuo nome e tu la cerchi altrove, nel caso oppure negli altri: l'equilibrio si rimette dove la cosa torna a chi l'ha fatta.

## L'Eremita

### dritta

- 1: Un sapere raccolto in lunga strada si restringe al cerchio di un passo illuminato: la ricerca procede nel silenzio e quel poco di chiaro basta per muovere il piede che segue.
- 2: Il silenzio diventa materia di lavoro: toglie il rumore di fuori, apre lo spazio in cui una domanda vecchia trova risposta e tiene il chiarore corto per scelta.
- 3: Dall'alto di una salita già fatta l'attenzione si gira verso dentro: lenta, voluta, con una lampada che schiarisce un tratto breve e la calma di chi ha imparato a camminare poco per volta.

### capovolta

- 1: Un ritiro che serviva resta aperto oltre la sua utilità: la luce continua a scendere dentro e il tratto di strada che riporta verso gli altri non riceve più niente di chiaro.
- 2: La distanza cercata per capire si è fatta muro di casa: quello che hai raccolto nel silenzio si ferma lì dentro, perché la porta che lo farebbe uscire è coperta dal silenzio stesso.
- 3: Dura più del lavoro che doveva fare, questa solitudine: schiarisce sempre meno, allontana sempre più e il cerchio di luce si stringe su chi lo porta.

## La Ruota della Fortuna

### dritta

- 1: Il cambiamento in corso non ha un autore. Nessun merito lo chiama e nessuna colpa lo spiega, gira per conto proprio e sposta l'altezza da cui guardi le cose. Il tempismo è quanto passa fra te e la sua curva.
- 2: Una rotazione comanda il momento e viene quando non la aspetti, poi scende quando sembrava salita per sempre. Tu stai su un bordo in movimento e il tuo passo pesa soltanto nel seguirne la direzione.
- 3: Sopra e sotto scambiano di posto senza preavviso. La spinta che ti ha portato in basso continua a girare nello stesso senso. Il perno regge tutto il movimento e la curva passa per il punto dove stai.

### capovolta

- 1: La sosta è un tratto della rotazione. Il movimento sta tutto nel perno e nel peso che cresce da una parte, anche se la circonferenza non avanza di un dito.
- 2: Un ciclo gira storto, con la spinta che esce dal punto sbagliato e la stessa curva sempre davanti. Il carico accumulato in questa pausa è la parte che spinge.
- 3: Il freno sta dentro lo stesso meccanismo che spinge. Una rotazione lenta carica il contrappeso. Il tempo della pausa appartiene al ciclo dove il peso aumenta mentre niente sembra muoversi.

## La Forza

### dritta

- 1: Una mano senza armi si posa sul muso di un animale che potrebbe mordere e l'animale si acquieta perché nessuno lo sfida: la dolcezza che non cede nulla governa l'istinto meglio della stretta.
- 2: Il ruggito che senti dentro si placa sotto una carezza ferma. La mitezza pesa più dei muscoli e il coraggio che ti riguarda è quello di chi ammansisce un animale senza ferirlo.
- 3: Ciò che ringhia dentro di te obbedisce a una calma e non a una minaccia: la tua pazienza fa il lavoro che la violenza non farebbe, con la lentezza di chi si accosta a una bestia a mani nude.

### capovolta

- 1: La mano si è chiusa a pugno su qualcosa di vivo e quel qualcosa scappa proprio perché stretto: l'istinto che vorresti domare risponde alla durezza con uno scarto e la tua tenuta ti sembra una questione di muscoli.
- 2: Scambi il vigore con lo sforzo e la mitezza per debolezza, così la bestia che hai dentro viene trattata da nemica e ogni serrata di dita le regala una ragione per ringhiare.
- 3: Dubiti di tenere e ti applichi una severità che non riserveresti a nessun altro. Sotto quelle dita l'animale che si placa con la carezza si agita e il dominio si allontana quanto più la mano si chiude.

## L'Appeso

### dritta

- 1: Una sosta rovescia il tuo punto di vista e l'attesa che sembra vuota è proprio la parte che lavora. Il bisogno di agire scende, mentre quello che vedi arriva dal rovescio.
- 2: Da testa in giù la scena mostra i pesi invertiti, sopra quello che stava sotto e minimo quello che sembrava enorme. La sosta accettata opera al posto delle tue mani.
- 3: Nessuna delle tue mosse aggiunge niente a questo stare: la sospensione stessa è l'operazione e la scena si rivela guardata dalla parte opposta.

### capovolta

- 1: L'attesa non insegna più niente e sa di stallo: la sospensione che apriva il tuo sguardo gira a vuoto, con la testa ancora in giù e nessuna vista nuova in arrivo.
- 2: Paghi una rinuncia che nessuno ti ha chiesto, con l'aria della nobiltà addosso: il sacrificio non arriva a nessun destinatario e la paura di scendere ne prende il nome.
- 3: Il tempo fermo ha finito di insegnare, oppure una privazione decisa da te occupa il posto della vista nuova. L'albero regge ancora il tuo peso e non restituisce più niente.

## La Morte

### dritta

- 1: Una cosa arrivata alla sua scadenza si sta chiudendo da sola e nel posto che lascia libero nasce qualcos'altro, senza che il mutamento che ti prende chieda nessuna risposta.
- 2: La falce passa alla radice di quello che era maturo e lascia in piedi il resto. Lo spazio che si libera è esattamente dove una cosa nuova attecchisce e tu lo vedi aprirsi.
- 3: Mentre una cosa compie il suo termine e ti lascia, nel punto esatto della chiusura entra l'aria che una nascita respira. Mutamento e non rovina.

### capovolta

- 1: Il mutamento è avvenuto e le tue mani restano chiuse su una cosa che ha finito di esserci. Trattenere costa più del lasciare e quello che si apre cambia natura al dolore.
- 2: Resistere è il gesto in corso mentre il cambiamento è già compiuto. La cosa che stringi ha smesso di esserci e il male che senti nasce dalla stretta.
- 3: Lo strappo che senti è fatto di trattenere: il mutamento ha girato, la cosa che reggi è finita e nella mano che si allarga il dolore si volta in attraversamento.

## La Temperanza

### dritta

- 1: Due cose che non stavano insieme passano l'una nell'altra a filo lento e nella dose esatta, finché diventano una terza cosa sola e quello che era rotto in te torna d'un pezzo.
- 2: A filo sottile e con pazienza da artigiano, in te si mescolano materie che sembravano incompatibili: la dose piccola fa il lavoro e quello che esce è un pezzo nuovo che tiene.
- 3: La calma lavora in due sensi insieme: tiene fermi i due opposti che ti dividono e scioglie il confine fra loro, finché l'uno prende il gusto dell'altro e il contrasto si fa una pasta sola.

### capovolta

- 1: La dose è la cosa che si è guastata: ti muovi troppo o troppo poco e due parti di te hanno smesso di parlarsi. Il ritorno non sta in una decisione sola, sta in gesti piccoli ripetuti.
- 2: Troppo e troppo poco si alternano senza centro mentre due pezzi di te finiscono in stanze separate: una cosa così si rimette per gradi minimi, perché la dose non obbedisce a una decisione in blocco.
- 3: Lo strappo sta nella proporzione: da una parte troppo e dall'altra niente, mentre i tuoi due versanti hanno smesso di scambiarsi qualcosa. Si rimette per piccoli ritorni somiglianti, mai in un colpo.

## Il Diavolo

### dritta

- 1: Un piacere vero fa da collante al vincolo: la catena tiene perché restituisce qualcosa in cambio, puntuale, ogni volta che la stringi.
- 2: L'attaccamento lavora in pieno giorno e con il tuo consenso: nutre un gusto preciso, chiede indietro una libertà alla volta e il patto regge fino a quando il gusto vale il prezzo.
- 3: Scende nel buio il nome dell'abitudine che ti tiene: una fame vecchia, un gesto che conosce esattamente la tua misura, un legame che hai alimentato tu.

### capovolta

- 1: Perde forza il gusto che teneva fermo il legame e il nodo torna lavorabile: si scioglie un giro per volta, al prezzo di una rinuncia a qualcosa che piaceva davvero.
- 2: Il patto si mostra con il suo prezzo scritto accanto: da lì lo scioglimento diventa manuale e lento, mentre la libertà si guadagna lasciando andare qualcosa di amato.
- 3: Quello che ti tratteneva aveva il suo tornaconto e riconoscerlo lo sposta: la catena si allenta di un giro, la stretta che la teneva comincia a cedere.

## La Torre

### dritta

- 1: Senza annuncio, un colpo secco cade e fa una cernita. Quello che stava su una bugia viene giù in un istante, quello che era vero regge ancora fra i calcinacci.
- 2: La scossa non distingue per affetto, distingue per fondamenta. Dove c'era sostanza il muro tiene, dove c'era apparenza il piano viene giù tutto insieme.
- 3: Cade il falso che portava un peso. La pena sta nell'istante e la cernita invece rimane. Sulle macerie si vede il fondo vero, quello che prima stava coperto dall'intonaco.

### capovolta

- 1: Una crepa sta sotto i puntelli e i puntelli reggono. Il colpo che butterebbe giù l'edificio è stato spostato in avanti, oppure è già passato e la polvere non ha ancora finito di scendere.
- 2: Il falso tiene in apparenza, con la facciata lisciata e le crepe dietro l'intonaco. Il cedimento che gli spettava sta in sospeso e intanto il peso continua a scendere sugli stessi muri.
- 3: Dalle macerie si esce a fatica, un passo per volta fra i calcinacci. L'altra faccia della stessa forza è il rinvio: un muro che va giù tenuto su a mano mentre il momento viene rimandato.

## La Stella

### dritta

- 1: Un lume alto e lontano sta fermo sopra un cielo che ha smesso di scaricare e la quiete che viene da quell'altezza ti rassicura a bassa luce, senza chiedere niente in cambio.
- 2: La calma scende dall'alto e si posa dove la pioggia aveva battuto: la fiducia si riaccende sul posto, mentre la stanchezza resta dov'era e il cielo si sgombra senza fretta.
- 3: Dall'alto una luce ferma rischiara appena e tanto basta: la speranza si rimette in piedi senza clamore, nel posto esatto in cui le forze si erano fermate.

### capovolta

- 1: Sperare è diventato faticoso come un lavoro e l'ispirazione si è fatta muta: il riferimento lontano nel buio sta dov'era, mentre la capacità di fidarsi di quello che non si vede ancora è la prima a cedere.
- 2: Credere che qualcosa di meglio sia possibile pesa più di ogni altro pensiero: la notte è lunga, il riferimento lontano non si fa sentire e l'ispirazione resta senza parole.
- 3: Dentro il buio la speranza funziona a intermittenza: il lume che serviva a orientarsi è coperto da un velo sottile e la fiducia in quello che non si vede ancora si consuma più delle forze.

## La Luna

### dritta

- 1: Al buio i contorni cambiano e la prima occhiata sbaglia: la luce bassa ingrandisce una cosa e ne cancella un'altra. L'intuito è lo strumento che lavora dove i tuoi occhi non arrivano.
- 2: Una luce indiretta deforma le misure delle cose vicine e le forme restano doppie, con le paure notturne che si affacciano. Il tatto prende il posto della vista e il tuo passo si fida di sé.
- 3: Niente di visibile regge un secondo sguardo, perché la notte sposta le proporzioni di tutto. Il sapere che ti muove non passa dagli occhi e il buio si attraversa fidando del piede.

### capovolta

- 1: La luce restituisce alle cose la misura che hanno: quello che al buio prendeva tutto il tuo spazio si ferma dentro i suoi contorni e l'ombra era la parte più estesa.
- 2: Rientra nelle sue proporzioni la sagoma che sembrava enorme e la tua paura cala con lei, un contorno alla volta, senza bisogno di nessuna parola.
- 3: Guardi con occhi nuovi una cosa che ti spaventava e trovi meno materia di quanta l'ombra prometteva: la luce non ha aggiunto niente, ha soltanto smesso di mancare.

## Il Sole

### dritta

- 1: La luce cade dall'alto su ogni cosa e non lascia un angolo coperto. Il tuo ridere non ha più niente da mettere al riparo e quello che sei si legge in chiaro.
- 2: Niente di te resta in ombra sotto una luce che cade piena: le cose fioriscono allo scoperto, la riuscita si vede a occhio nudo e il calore che ti prende passa agli altri senza perdersi.
- 3: Ridere senza coprirti è il permesso che questa luce ti dà. Viene dall'alto, cade su tutto quanto e non chiede a nessuna parte di te di restare segreta.

### capovolta

- 1: Il calore sta dove è sempre stato e sulla tua pelle non ci arriva. Davanti sta un pensiero vecchio che fa da coperchio e l'entusiasmo resta trattenuto sotto.
- 2: Un pensiero vecchio si trova fra te e una gioia che continua a essere disponibile, che vedi bene e senti poco, col tepore fermo appena fuori.
- 3: Quello che ti scalda non si è spento e sta sotto una copertura sottile. L'entusiasmo si tiene a mezz'aria, la luce entra negli occhi e non nella pelle.

## Il Giudizio

### dritta

- 1: Una tromba ti nomina e pretende una risposta. Il prezzo che mette sul tavolo è la persona che eri fino a quel suono e nessun oggetto tuo serve a pagarlo.
- 2: Un richiamo mette in chiaro quale vita sia davvero tua e lascia in ombra quello che ti occupava fino a ieri. Il suo modo è la scossa che apre gli occhi, mai il rimprovero.
- 3: Dall'alto una chiamata ti solleva e insieme ti spoglia: ti rende una vita più tua e si prende la persona che eri, senza versione intermedia fra le due.

### capovolta

- 1: Due uffici tuoi stanno nella stessa persona, chi accusa e chi ascolta. Il primo prende la parola per primo, così il bilancio che senti necessario resta rimandato oppure esce già in forma di condanna.
- 2: L'ordine delle operazioni ti si è invertito: la durezza verso di te parla prima dell'ascolto. Quella rinascita lavora nell'altro ordine, il perdono per primo e il peso dopo.
- 3: La comprensione da te verso te arriva per ultima, quando invece è il primo appoggio di una rinascita: ascolto e perdono sono la sostanza di cui è fatta e la durezza le resta estranea.

## Il Mondo

### dritta

- 1: Un giro largo si chiude senza lasciare pezzi fuori: quello che hai attraversato smette di essere strada e diventa misura tua, il compimento si sente addosso prima del prossimo inizio.
- 2: La pienezza tiene insieme tutto il percorso in una cosa sola: nessun pezzo chiede di essere recuperato, nessun tratto sta ancora fuori e il cerchio si chiude da dentro.
- 3: Arriva al punto di saldatura un cammino lungo: il guadagno è la larghezza del passo e la capacità di stare in ogni angolo del disegno senza più sentirsi fuori posto.

### capovolta

- 1: Quasi tutto il quadro sta al suo posto e un pezzo solo resta scollato: quel dettaglio tiene il cerchio aperto e la pienezza aspetta lì, a distanza di un tratto corto.
- 2: La completezza si misura sul residuo: un nodo minuscolo, una faccenda lasciata a metà e finché quel punto resta fuori l'armonia del tutto non si compone.
- 3: Resta scoperto un angolo del cerchio quasi finito: il lavoro grosso sta fatto e in piedi, il poco che manca è preciso, piccolo e proprio nel punto da cui dipende la chiusura.

## Asso di Bastoni

### dritta

- 1: Un'accensione sta all'origine di tutto il resto. Calore grezzo, nessuna forma ancora, la prima cosa che esiste di un'opera che non ha neppure un nome.
- 2: La fiamma è appena nata e brucia al massimo adesso. Il suo compito è accendere e non durare. Da questo primo calore vengono il piano, gli strumenti e il mestiere; nell'ordine viene prima lui.
- 3: Il fuoco cresce da sé e scalda la mano che gli sta vicino. Il desiderio viene prima di qualunque idea su che cosa farne. È la materia di cui è fatto un inizio, spinta pura e nessuna istruzione.

### capovolta

- 1: Il combustibile è tutto lì sotto e l'aria no. Il fuoco esiste sotto un coperchio che lo soffoca e il primo innesco non trova dove attaccarsi. Quello che slitta è il momento in cui tutto parte.
- 2: Una partenza resta in sospeso senza che manchi niente al motore. Il desiderio sta sotto, coperto dal timore di sbagliare il primo colpo. Tutto il resto aspetta quel colpo.
- 3: A essere fermo è il momento dell'innesco, una fiamma sola da far nascere, sempre quella, con un fiato sopra che la spegne appena cresce.

## Due di Bastoni

### dritta

- 1: Un'ambizione larga lavora sulla tua capacità di scegliere una direzione prima di muovere qualunque cosa: il globo sta nella tua mano, il confine del conosciuto è lì davanti e la rotta è ancora tutta da dire.
- 2: Il progetto esiste come disegno e non ancora come partenza. L'ambizione misura dall'alto di un muro terre che non hai visto e sceglie fra loro con la calma di chi non ha ancora salpato.
- 3: Con il mondo piccolo fra le dita una volontà di andare lontano pesa le direzioni possibili e l'ampiezza del disegno conta molto più del primo movimento.

### capovolta

- 1: L'ambizione è grande e la rotta resta senza una linea: la vista da quassù arriva lontano mentre osare costa più che immaginare, così il globo gira fra le dita senza che una terra venga indicata.
- 2: Scegliere una direzione fa più paura che pensarne molte, così il disegno grande resta sulla carta: dall'alto del muro il mare è tutto uguale e la mano che tiene il mondo non si decide.
- 3: Osare quanto l'ambizione pretende è il punto in cui la volontà si inceppa: il confine del conosciuto sta ancora davanti, la terra nuova non ha un nome e la rotta aspetta una linea che nessuno traccia.

## Tre di Bastoni

### dritta

- 1: Quello che hai mandato fuori viaggia lontano dalle tue mani e rientra da sé: resta soltanto la distanza da consumare e nessun gesto da questa parte la accorcia.
- 2: Hai messo in moto una cosa che sta già oltre il tuo raggio di braccio: matura senza di te e fa ritorno carica. Ti riguarda lo sguardo lungo verso il punto da cui rientra.
- 3: Un'espansione avviata lavora dove non arrivi e la sua misura è la lontananza: il carico cresce altrove e rientra per mare quando ha compiuto il giro.

### capovolta

- 1: Il ritorno è avvenuto e il contenuto non corrisponde: la cosa è rientrata al porto, con dentro un'altra materia rispetto a quella che avevi immaginato.
- 2: È tornato puntuale e irriconoscibile quello che hai spedito lontano: la forma immaginata e quella arrivata non combaciano e la previsione è la parte da rifare.
- 3: Rientra la merce mandata per mare e dentro trovi qualcosa che non avevi ordinato: il viaggio si è compiuto per intero mentre la previsione resta da riscrivere.

## Quattro di Bastoni

### dritta

- 1: Le fondamenta hanno passato la prova del peso e sopra di esse si sta in piedi in compagnia. La gioia che ti riguarda è divisa con altri e la corsa al prossimo resta ferma.
- 2: Una base che regge si festeggia all'aperto, sotto i rami intrecciati che fanno tetto. L'opera che hai messo in piedi tiene il carico e la festa si prende con chi c'era.
- 3: La costruzione che hai alzato regge sulle sue radici, la celebrazione sta sopra di esse e il bello già presente si riconosce prima che un altro lavoro cominci.

### capovolta

- 1: Il risultato che hai raggiunto non ha nessun pezzo in meno. La celebrazione non si è ancora posata sopra di esso e le stanze restano pronte dietro una porta che nessuno ha aperto.
- 2: A metà si ferma la festa mentre il traguardo è intatto. Il lavoro ha finito, il giorno che lo segna resta da scegliere e la tua riuscita non ha ancora avuto il suo momento.
- 3: Dietro la porta chiusa sta una cosa riuscita per intero: al lavoro che hai fatto non è mancato nessun pezzo e manca soltanto entrare e dirlo agli altri.

## Cinque di Bastoni

### dritta

- 1: La materia dello scontro sono le idee e si discute tutti insieme senza abbassare il tono: il calore che si alza ti serve da paragone e dalla zuffa nessuno esce perdente.
- 2: Più mani alzate insieme e un ribollire che non cerca un vinto: l'attrito ti mette alla prova fra pari e quello che ne ricavi dipende dal modo in cui lo giochi.
- 3: Un confronto acceso ti tiene in esercizio e la sua resa dipende da come lo maneggi: fra pari che si misurano rende forza a tutti, mentre spinto fino a schiacciare lascia soltanto graffi.

### capovolta

- 1: Molti fronti piccoli ti prendono energia a un attrito per volta, mentre quello che conterebbe davvero sta sotto la cenere e cova senza che nessuno lo apra.
- 2: Tiepido e continuo, il tuo logoramento passa per una fila di battibecchi che non pesano nulla mentre la lite che peserebbe davvero resta coperta e cova.
- 3: Quello che si vede sono scaramucce senza posta in gioco. Quello che resta in penombra è l'attrito che ti riguarda davvero: coperto fa fumo e ti stanca più di quanto costerebbe aperto.

## Sei di Bastoni

### dritta

- 1: Il merito esce dal chiuso e passa davanti a chi guarda: un lavoro che era privato prende nome pubblico e il consenso arriva da fuori, detto apertamente.
- 2: Una stima prima sottintesa diventa dichiarata: altri la dicono per primi davanti a terzi, mentre la misura dell'onore combacia con quella del lavoro che lo ha prodotto.
- 3: Sfila bene, l'opera che hai costruito: la gente ai lati del passaggio fa parte del fatto, perché il valore si compie nel momento in cui qualcuno di fuori lo nomina.

### capovolta

- 1: Un lavoro compiuto resta senza il suo atto pubblico: la stima di fuori tarda e nel ritardo si insinua la domanda se valga quanto pensavi.
- 2: Il valore sta fermo dove lo hai messo mentre il verdetto degli altri viaggia lento: fra il fatto e il giudizio corre una distanza che lavora addosso a chi aspetta l'applauso.
- 3: Manca la parte vista del merito: il fatto sta in piedi da sé, il riconoscimento resta in sospeso e il dubbio che nasce lì riguarda la lentezza di fuori più del lavoro.

## Sette di Bastoni

### dritta

- 1: Il vantaggio sta nel terreno. Altri vogliono il tuo posto e lo attaccano da sotto, in salita, mentre tu lo tieni dall'alto col fiato ancora pieno.
- 2: Molti davanti e una sola persona in piedi al centro. Qui si tiene un posto già conquistato, contro la pressione che sale da ogni parte. Il terreno regge e il respiro basta.
- 3: Quello che difendi è già tuo e il vantaggio viene prima dell'attacco. L'altezza sta dalla tua parte mentre il numero sta da quella di fronte. La pressione che senti addosso misura quanto il tuo posto valga.

### capovolta

- 1: I fronti aperti sono troppi e li copre un solo turno. Ogni punto ha un presidio sottile e la forza che basterebbe per un posto solo finisce divisa fra tutti quanti.
- 2: Una difesa larga e bassa, con collinette presidiate una per una, comprese quelle che nessuno sta salendo. Il dispendio sta nel numero dei posti tenuti e al terreno che conta ne resta una parte sola.
- 3: La stanchezza viene dal conto dei punti da reggere, tutti insieme e tutti uguali. Una scorta divisa fra molte posizioni, con lo sguardo su ogni direzione e il peso su nessuna.

## Otto di Bastoni

### dritta

- 1: Molte cose attraversano l'aria nello stesso senso e nello stesso momento, senza nessuno che le spinga: la rapidità con cui si susseguono accorcia il tempo che avresti per pensarle una per una.
- 2: L'aria è attraversata da linee parallele che corrono insieme e nessuna di loro ha bisogno di te: le notizie si sovrappongono, i fatti si accavallano e il ritmo ti passa davanti senza rallentare.
- 3: Tutto si mette in corsa nello stesso istante e il ritmo non appartiene a nessuno: l'intervallo fra una cosa e la successiva si riduce a niente e quello che era lontano è già addosso.

### capovolta

- 1: Arriva per ultimo quello che doveva venire per primo, la fretta anticipa il momento giusto e le linee che correvano parallele adesso si incrociano fra loro.
- 2: Di quello che era in volo una parte si è fermata per aria e il resto ha anticipato tutti: l'ordine fra le cose si è rotto e la rapidità su cui avevi contato inciampa nei propri piedi.
- 3: L'allineamento fra una cosa e l'altra si è perso: i ritardi si alternano agli scatti, i tempi si allungano a misure diverse e la fretta scompiglia quello che il ritmo teneva in fila.

## Nove di Bastoni

### dritta

- 1: La stanchezza che porti viene dalle prove già superate: ogni segno addosso è di un turno precedente e la guardia che resta da fare è l'ultima.
- 2: Stai reggendo un ultimo turno con il corpo già segnato dai precedenti: la tenacia lavora sul fondo delle riserve e lo scudo può scendere appena questa prova passa.
- 3: Il grosso lo hai già fatto e davanti resta un solo assalto. Le forze sono quelle che avanzano dopo le altre volte e la vicinanza del termine tiene in piedi la guardia.

### capovolta

- 1: Le ferite vecchie leggono i gesti al posto tuo: chi si avvicina per bussare riceve il trattamento di un assalto, con la guardia alzata contro una mano che arriva aperta.
- 2: Una diffidenza di troppo copre anche l'avvicinamento gentile: i tuoi segni di prima decidono chi tenere fuori e la porta resta chiusa a una persona che voleva soltanto entrare.
- 3: Resta alzato uno scudo rivolto a chi non combatte: il colpo che aspetti è quello di una volta, mentre la mano davanti a te sta soltanto cercando un contatto.

## Dieci di Bastoni

### dritta

- 1: Le responsabilità sono vere tutte quante e stanno in un fascio unico che ti curva la schiena: quali di esse siano davvero tue da portare è una cernita che nessuno ha ancora fatto.
- 2: Un carico fatto di cose dovute ti grava sulle spalle senza che una sia finta. La curvatura viene dal loro numero e il tuo si mescola all'altrui.
- 3: Hai addosso impegni accettati uno dopo l'altro e il corpo li sente tutti nello stesso punto. Il dovuto e il superfluo stanno nel medesimo fascio, senza un segno che li divida.

### capovolta

- 1: Sulle tue spalle viaggia un fardello intestato a qualcun altro e quello che lo tiene su non è la necessità. È l'abitudine, oppure un senso del dovere mai discusso.
- 2: L'abitudine fa da cinghia a un peso che non ti riguarda. Le spalle lo reggono per inerzia, il proprietario è un altro e metterlo a terra lascia tutti al loro posto.
- 3: Senza necessità è stato caricato il peso che porti e sopra non c'è il tuo nome, così posarlo alleggerisce le spalle senza che nessuno ci perda niente.

## Fante di Bastoni

### dritta

- 1: Giovane e senza pretese, una curiosità ti prende per il gusto di provarla: si esplora e si tenta, mentre la sproporzione fra la sua piccolezza e quello che può diventare è tutta la sua ricchezza.
- 2: Un'idea appena nata ti tira fuori a provarla senza sapere dove arriva: l'età di questo entusiasmo è il suo diritto, perché a quell'età si tenta e nessuno chiede un frutto.
- 3: La tua capacità messa in esercizio è quella di esplorare: apri, provi, domandi senza sapere dove sbuchi. Quello che impari vale pure quando non serve a nulla.

### capovolta

- 1: Gli inizi si accumulano uno sopra l'altro: l'idea nuova si mette davanti a quella di prima che aveva appena messo radici. Ti resta una fila di cose avviate e lasciate a metà.
- 2: A intermittenza il fuoco c'è tutto e cambia oggetto appena ne compare un altro: la sostituzione è continua e nessuno dei tuoi inizi arriva al punto in cui darebbe qualcosa.
- 3: La stessa prontezza che ti accende ti porta anche via: la seconda idea nasce mentre la prima è un germoglio. A ciascuna manca il tempo, mai lo slancio.

## Cavaliere di Bastoni

### dritta

- 1: Un desiderio preciso si mette in viaggio con tutto il corpo: si parte di persona verso la cosa voluta, al galoppo, col calore della partenza che regge il primo tratto.
- 2: La passione prende la forma di un tragitto fatto in prima persona: chi vuole una cosa la va a prendere, con lo slancio che scalda il passaggio e poca attrezzatura dietro.
- 3: Verso la cosa che desideri il movimento comincia subito, senza istruttoria: il coraggio sta nel mettersi in strada a cavallo prima che il piano sia completo.

### capovolta

- 1: Troppa corsa e nessuna rotta: la forza c'è tutta e si consuma per strada, perché la partenza è già avvenuta mentre la direzione resta da scegliere.
- 2: L'ardore gira a vuoto ad alta velocità: si spende in partenze che si accavallano e ogni scatto nuovo porta via combustibile al tratto precedente.
- 3: Brucia in strada la riserva che doveva portare lontano: il passo è già di galoppo, la rotta cambia sotto e la fretta costa più di quanto il viaggio renda.

## Regina di Bastoni

### dritta

- 1: Il calore attrae e gli altri vengono verso il fuoco perché scalda. La stanza si riempie attorno al punto dove stai.
- 2: Una fiamma ferma, come quella di un focolare, resta al suo posto e tutti le stanno intorno. La sicurezza che la tiene accesa è la stessa cosa che la rende attraente.
- 3: Magnetismo per materia: calore, colore, un modo di stare che si vede da lontano. Scalda la stanza intorno a te e quello che dà agli altri non lo sottrae a sé.

### capovolta

- 1: Un altro fuoco brucia nello stesso campo e il paragone con quello abbassa il tuo calore. Il magnetismo cala e la luce resta accesa, soltanto rivolta verso il fuoco di qualcun altro.
- 2: La gelosia fa da specchio storto. Misura quello che hai sul metro di un'altra persona e il risultato esce sempre corto. Il calore diventa cauto e la stanza se ne accorge.
- 3: Il dubbio riguarda il tuo valore accanto a quello di un altro, con una luce messa di fronte all'altra. La prima a perdere luce è quella che fa il confronto.

## Re di Bastoni

### dritta

- 1: Una volontà che ha già bruciato a lungo apre il campo e dietro di lei camminano altri: il comando passa per l'esempio e il fuoco più vecchio mostra a chi è venuto dopo dove mettere i piedi.
- 2: Il seggio è occupato da chi ci è passato prima e la generosità di quella fiamma scalda senza pretendere obbedienza: le direzioni che indica, gli altri le prendono per conto proprio.
- 3: Dietro una fiamma tenuta viva a lungo cammina gente che nessuno ha costretto: le direzioni si aprono per esempio e la generosità di chi guida conta quanto la sua volontà.

### capovolta

- 1: L'autorità spinge e non sente: le persone che dovrebbero seguire restano indietro oppure si scansano, perché il fuoco di chi comanda scalda da vicino quanto brucia.
- 2: Comandare prende il posto dell'accendere e la fiamma che aveva fatto camminare gli altri adesso li travolge: quello che viene preteso dall'alto non lascia spazio a quello che potrebbe essere detto dal basso.
- 3: Dalla cima la generosità si è irrigidita in pretesa: l'impulso di chi comanda anticipa ogni parola di chi sta sotto e la guida che apriva il campo adesso ci passa sopra.

## Asso di Coppe

### dritta

- 1: Una sorgente si apre dentro e dà più acqua di quanta ne serva: il sentire arriva al principio, senza un destinatario già scelto e senza nessuno che te lo porti.
- 2: Il traboccare nasce alla fonte: l'emozione sta al suo primo stato, pura e abbondante, pronta a correre fuori per conto proprio senza bisogno di un tuo gesto.
- 3: Hai dentro un principio di sentimento ancora senza nome e senza direzione: l'acqua sale fino all'orlo e la dolcezza di questo stato sta nell'abbondanza che non hai prodotto.

### capovolta

- 1: L'acqua resta ferma dentro un recipiente chiuso a mandata: il tuo sentire non arriva a nessuno perché non è ancora uscito, con il timore di soffrire che tiene girata la chiave.
- 2: Tappata alla fonte, l'acqua fa ristagno sul posto e il sentimento invecchia nel punto dove è nato: la chiusura sta a monte di ogni incontro e riguarda te con quello che provi.
- 3: Resta chiuso a chiave un sentimento rimandato, oppure un'emozione tenuta a bada per paura del dolore. L'acqua ha pressione e nessuna uscita, con il ristagno tutto dalla tua parte.

## Due di Coppe

### dritta

- 1: Lo stesso gesto muove da te e dall'altra parte insieme e si incontra a mezza distanza. Il riconoscimento va e torna e si chiude in un patto che nessuno ha dovuto chiedere.
- 2: Un patto fra pari si sigilla senza che uno guidi e l'altro segua: chi hai di fronte dà quanto prende e la forza che ne viene moltiplica quella delle parti separate.
- 3: Alla pari e l'uno in faccia all'altro. Tu metti la tua misura esatta, l'altro mette la sua e quello che si sigilla tiene perché sta su appoggi uguali.

### capovolta

- 1: Fra te e una persona che ti vuole bene si è aperta una distanza che nasce da parole lette male, con l'affetto fermo sotto e il solo accordo fra le parti spostato.
- 2: Una coppia si allontana per un fraintendimento mentre il bene fra loro sta dov'era. Lo spazio che le frasi storte hanno aperto si richiude dall'ascolto vero, il tuo e quello dell'altra parte.
- 3: Parole prese per un senso che non avevano hanno messo uno scarto fra te e una persona a cui tieni. Il bene regge e quello che si è spostato torna a posto dal sentirsi davvero.

## Tre di Coppe

### dritta

- 1: La gioia è la materia che raddoppia passando di mano: messa fra le mani di chi ti vuole bene cresce, mentre tenuta addosso resta grande quanto una persona sola.
- 2: Un brindisi ti mette in cerchio con chi ti tiene caro e il tuo motivo di allegria diventa anche il loro: la cosa che la scatena esiste già e la compagnia la moltiplica.
- 3: Allegro e corale, il modo di questa tua contentezza vuole più di una persona: si alza insieme, si racconta e torna indietro cresciuta da chi l'ha sentita.

### capovolta

- 1: Lo spessore dei legami è la cosa in questione: i molti sottili ti prendono l'attenzione mentre i pochi che ti tengono su restano senza un turno. Forse è un eccesso, forse una cerchia curata male.
- 2: Largo e tiepido, il giro si è allargato più di quanto tu riesca a nutrire: ti saluti con molti e ti racconti con pochissimi, mentre la cura si spalma fino a non arrivare.
- 3: La stessa presenza distribuita su molte compagnie scalda poco e raccolta su poche scalda parecchio: il numero decide quanto ti nutre quello che dai e quello che ricevi.

## Quattro di Coppe

### dritta

- 1: Una sazietà piena spegne l'interesse: l'offerta tesa di fianco si vede bene senza riuscire a entrare, perché il gusto per il nuovo si è messo a riposo.
- 2: La noia ha abbondanza alle spalle: hai già il necessario e una mano porge di lato, senza che lo sguardo si giri a guardarla.
- 3: Accanto a te sta un dono buono mentre lo sguardo guarda altrove: il disinteresse non nasce da mancanza, nasce da una pienezza che ha smesso di sentire fame.

### capovolta

- 1: Torna l'appetito dopo un tempo di sazietà: una proposta che prima lasciava indifferente comincia a sembrare interessante e il dono fermo di lato entra nel campo dello sguardo.
- 2: La curiosità si riaccende dal basso e senza annunci: il gusto per le cose intorno riprende a circolare e il torpore cede terreno un poco per volta.
- 3: Si muove qualcosa dove c'era soltanto noia: l'interesse rientra, la mano si gira verso quello che era là da tempo e sentire torna a essere facile.

## Cinque di Coppe

### dritta

- 1: Il rimpianto tiene lo sguardo in una direzione sola, su quello che è andato. Alle spalle resta in piedi qualcosa che il conto non registra, fuori dal campo di chi guarda quel vuoto.
- 2: La perdita è già avvenuta e la pena ha per metro il posto vuoto. Il resto della scena esiste e sta dietro, fermo, nella parte che lo sguardo fisso lascia in penombra.
- 3: Un conto doppio sta aperto, quello che è stato perso e quello che è rimasto. Il primo prende tutto lo sguardo mentre il secondo aspetta dietro le spalle. La pena del primo è vera quanto la presenza del secondo.

### capovolta

- 1: La testa gira e trova quello che era già in piedi. Niente di nuovo entra nella scena, cambia la direzione da cui la guardi. Il lutto resta vero e smette di prendere tutto il campo.
- 2: L'accettazione ha la misura di un movimento del collo, con la parte perduta che esce dalla vista e la parte rimasta che ci entra. Il perdono vale verso chi ha mancato e anche verso il tuo rimpianto.
- 3: Il peso passa da quello che manca a quello che c'è, senza che nessuno riporti indietro la cosa perduta. Il dolore attraversato lascia posto piano, alla velocità con cui la testa gira.

## Sei di Coppe

### dritta

- 1: Un affetto nato nell'infanzia torna indietro senza una sola ammaccatura: fiori offerti da mani piccole, bontà senza secondi fini, una dolcezza che scalda perché allora nessuno chiedeva niente in cambio.
- 2: La tenerezza che muove adesso ha l'età dell'infanzia: profuma di una stanza di allora, di giochi e di innocenza, mentre nutre più del presente proprio perché nel ricordo resta pulita.
- 3: Riemerge dall'infanzia un dono gratuito e la sua innocenza si riconosce subito: è bontà offerta da chi voleva bene senza sapere di farlo, dolce ancora adesso.

### capovolta

- 1: Trattiene più di una catena la dolcezza degli anni dell'infanzia e nessuno la scioglie proprio perché è dolce: quello che fu offerto da mani piccole continua a bastare e il presente resta in sala d'attesa.
- 2: Gli anni dell'infanzia continuano a essere abitati: la tenerezza di allora occupa la stanza, la memoria dei giochi vale più di quello che accade adesso e l'innocenza di prima diventa il luogo in cui si sta.
- 3: Più caldo del presente, il ricordo dell'infanzia offre ospitalità senza chiedere niente e la bontà di quel tempo diventa la ragione per non uscirne.

## Sette di Coppe

### dritta

- 1: Molte offerte stanno allineate davanti a te insieme, una più invitante dell'altra, con il contenuto di ciascuna sconosciuto fino a quando non guardi dentro.
- 2: Il numero delle promesse è la cosa che conta: ognuna mostra una vita diversa e nessuna ha ancora dichiarato che cosa tiene dentro. Il sogno lavora a pieno regime e i tuoi piedi restano in aria.
- 3: Davanti a te si affollano immagini che promettono ciascuna un'altra cosa: la fantasia lavora a pieno ritmo mentre la verifica non è ancora cominciata e nessuno dei recipienti è stato scoperto.

### capovolta

- 1: Una sola delle molte offerte prende contorno e il resto rimane dove sta: il tuo desiderio vero si distingue fra i simili e la libertà viene dal lasciare le altre intatte.
- 2: Sai quale desiderio è tuo fra i molti che si somigliavano: la nebbia delle promesse cala e la cosa scelta porta con sé la perdita delle altre, che è esattamente la parte che libera.
- 3: Resta una fra le molte e il vantaggio sta nella rinuncia: l'immagine a fuoco si separa dalle altre dipinte e il tuo volere torna a essere uno solo.

## Otto di Coppe

### dritta

- 1: Una cosa ancora in piedi ha smesso di nutrirti e tu te ne vai in silenzio, senza spiegazioni da lasciare. Il sapere che ti muove sta nel cuore, la mente non ha le ragioni.
- 2: Il silenzio è il modo di questa partenza, senza porte sbattute e senza chiarimenti pretesi. Quello verso cui ti muovi ti è chiaro nel petto e non in testa.
- 3: Andarsene è l'atto più onesto che questa forza porta con sé: lasci una cosa che ti ha dato quanto poteva per cercare un senso più alto e nessuno ti chiama da fuori.

### capovolta

- 1: Restare e andare ti stanno davanti a occhi aperti, nitide tutte e due. Quello che resta sospeso è il momento giusto per una delle due e tu non ti muovi dalla porta.
- 2: Un'indecisione fra cose chiare ti tiene sulla porta: la scelta è guardata in faccia e manca soltanto il quando, perché il contenuto delle parti lo conosci bene.
- 3: Sulla porta, dentro e fuori nello stesso tempo. Le possibilità sono nitide e tu le guardi in faccia, mentre a restare sospesa è la data del lasciare.

## Nove di Coppe

### dritta

- 1: La facoltà sotto esame è il permettersi: un desiderio tuo è stato esaudito alla lettera e la contentezza ti sta davanti già servita, mentre il pudore ti trattiene dal prenderla.
- 2: Un desiderio ti è stato esaudito nella forma esatta in cui lo chiedevi. L'unica cosa che ti separa dal gustarlo è il pudore di ammettere che ti fa piacere.
- 3: Quello che si vede è una fila di cose ottenute una per una come le avevi chieste. Quello che resta in penombra è il senso di colpa che ti fa abbassare gli occhi mentre le guardi.

### capovolta

- 1: Il piacere l'hai già avuto e il vuoto viene dopo: quello che hai preso era buono senza riempire, così il sospetto si sposta su quello che ne volevi.
- 2: Sotto esame non c'è quello che hai ottenuto ma la tua facoltà di desiderare: il gusto si consuma e lascia la fame di prima, così la domanda cade su che cosa cercavi.
- 3: Una soddisfazione di facciata fa due cose insieme: ti copre il vuoto e lo tiene intatto. Il desiderio che l'ha chiesta cercava una distrazione più che una pienezza.

## Dieci di Coppe

### dritta

- 1: Gli affetti di casa stanno bene tutti nello stesso momento: il bene che gira fra le persone con cui dividi i giorni diventa la parte più ricca della giornata.
- 2: Una pace domestica regge il peso dei giorni comuni: i legami vicini tengono, si scambiano calore senza che nessuno lo chieda e la soddisfazione sta nella compagnia sotto il tetto.
- 3: Sopra la casa il tempo si è fatto sereno per tutti quelli che la abitano: la ricchezza si misura in affetto presente, scambiato di persona, dentro le mura che dividi.

### capovolta

- 1: Sotto un tetto solo le direzioni si moltiplicano: ciascuno dei vicini tira per conto proprio e la temperatura comune scende senza che nessuno abbia litigato davvero.
- 2: La famiglia resta insieme e smette di andare insieme: lo stesso spazio tiene più intenzioni che persone e l'armonia del gruppo paga la somma delle distanze.
- 3: Fra le persone di casa si è aperto spazio vuoto: nessuna rottura precisa, piuttosto una serie di scarti piccoli che sommati raffreddano le stanze.

## Fante di Coppe

### dritta

- 1: Una sensibilità giovane alle prime prove sente molto e dice poco, con lo stupore di chi non ha ancora un nome per quello che sente passare dentro.
- 2: L'emozione nuova ha la forma di un messaggio scritto a mano, breve, un poco goffa, vera. Sta nel suo foglio e porta immaginazione in quantità, esperienza nessuna.
- 3: Il sentire è alle prime armi e proprio per questo inventa, con una poesia, un disegno, una frase detta male e sincera. La fragilità fa parte del materiale e niente è ancora rigido.

### capovolta

- 1: Un sentire alle prime esperienze prende un colpo e si tappa, con la porta chiusa dall'interno e dentro tutto quello che non ha ancora trovato parole.
- 2: Il sentire giovane alza un mattone per volta, timido davanti a un'emozione che non sa ancora misurare. Scrive e non consegna, pensa la frase e la tiene in tasca.
- 3: Fragilità senza mestiere. Ogni cosa entra con la stessa forza e il riparo che trova è il muro. Quello che sta dentro continua a essere tenero, soltanto non lo mostra a nessuno.

## Cavaliere di Coppe

### dritta

- 1: Un'offerta viene portata con cerimonia da chi si avvicina, oppure la tendi tu con la stessa grazia: i modi valgono quanto il contenuto e la risposta non è stata data.
- 2: Il corteggiamento è un mestiere di avvicinamento: qualcuno si muove verso qualcun altro senza fretta, porge quello che ha e aspetta. Il sentimento precede la ragione e si vede nelle maniere.
- 3: Chi si avvicina mette la grazia davanti a tutto: il romanticismo lavora sulla cerimonia, sul tempo concesso all'altro e sulla cura con cui una cosa viene tesa senza essere imposta.

### capovolta

- 1: Belle parole vengono dette da chi si avvicina, oppure le dici tu, mentre il corteggiamento continua e i fatti stanno fermi senza che nessuno li muova.
- 2: L'incostanza è il modo di questo sentimento: si accosta con grazia, si allontana senza spiegazioni e torna con lo stesso garbo di prima, mentre quello che resta detto non diventa niente.
- 3: Dalle promesse non nasce un gesto e la grazia delle maniere fa tutto il lavoro: chi si avvicina incanta e quello che dichiara non attecchisce in nessuna terra.

## Regina di Coppe

### dritta

- 1: Una facoltà che legge dentro le persone lavora senza sforzo: senti quello che un'altra non dice e lo accogli invece di soppesarlo, con la stessa sensibilità che può rivolgersi a te.
- 2: Il tuo sentire fa da organo di conoscenza: arriva al fondo di un'altra persona per via di empatia e tenerezza, con una pratica adulta che non ha bisogno di parole per capire.
- 3: Hai in esercizio una tenerezza esperta che accoglie e intanto capisce, capace di stare in quello che un'altra persona prova senza correggerlo, mentre la stessa cura può tornare verso di te.

### capovolta

- 1: L'umore che hai addosso appartiene a un'altra persona: la facoltà che leggeva in profondità incamera tutto e del tuo sentire resta un posto occupato da quello di qualcun altro.
- 2: Senti per due e la misura del tuo stato si perde: quello di chi hai davanti entra senza filtro e occupa lo spazio, mentre la cura che distribuisci non passa da te.
- 3: L'acqua prende la forma di ogni recipiente che incontra: l'empatia continua a funzionare in entrata senza trovare un argine e quello che provi è il riflesso di un'altra persona.

## Re di Coppe

### dritta

- 1: L'acqua si agita e il seggio che la domina non cede: senti tutto quanto per intero e nulla ti rovescia, così la tua calma diventa un posto fermo per gli altri.
- 2: Una padronanza matura tiene il tuo sentimento senza spegnerlo. Arriva per quello che è, resta per quanto dura e gli altri vengono ad appoggiarsi su quella stabilità come su una riva.
- 3: Porto fermo prima di tutto per te. Il sentire lo attraversi senza annegarci, lo chiami per nome mentre lo vivi e la calma che ne resta è profonda, non gelida.

### capovolta

- 1: Gli sbalzi del tuo umore passano al comando e la calma che gli altri vengono a cercare da te non la regge nessuno. La maturità affettiva c'è e non è lei a condurre.
- 2: Un'emozione tua diventa lo strumento con cui ottieni qualcosa dagli altri, concedendo la tenerezza oppure ritirandola secondo quello che ti serve, con il comando passato all'umore che sale.
- 3: Chi dovrebbe dare quiete la sta chiedendo. L'umore che hai dentro detta le condizioni agli altri e la saggezza affettiva resta a bordo senza la mano sul timone.

## Asso di Denari

### dritta

- 1: Il terreno è pronto prima di te e sta già nelle condizioni che servono: quello che metti sotto mette radici da sé, perché la parte difficile l'hanno fatta le circostanze.
- 2: Una mano ti porge un seme e le circostanze intorno sono tutte dalla sua parte: la cosa è materiale e solida e la terra fa il resto senza che tu la convinca.
- 3: Concreto e solido, questo inizio lavora per radici: ha il modo delle cose che si piantano una volta e poi tengono, mentre le circostanze che hai intorno sono già favorevoli.

### capovolta

- 1: Un'apertura concreta si stringe mentre la guardi da lontano, oppure il calcolo che ne hai fatto era storto in un punto. La cosa sta ferma dove l'hai lasciata intanto che il suo tempo utile si accorcia.
- 2: Senza rumore e senza avvertirti, una porta nella siepe si chiude di un dito per volta. Nella stessa faccenda c'è anche un rischio che hai pesato male e resta da ripesare.
- 3: Due cose stanno dentro la stessa occasione: una si chiude da sé col passare del tempo e l'altra è una stima che hai preso di traverso. La materia in gioco resta solida nei due casi.

## Due di Denari

### dritta

- 1: Più impegni restano in aria nello stesso momento e nessuno si posa: il carico si regge sul ritmo, cioè alternando la mano, mentre la leggerezza lavora meglio della stretta.
- 2: La bravura sta nel passaggio: ogni cosa riceve attenzione a turno, breve, poi torna su quando il giro lo richiede, senza che il movimento si interrompa.
- 3: Si tiene tutto in movimento e nel movimento sta anche il tuo equilibrio: fermare un pezzo lo farebbe cadere, mentre la cadenza lo porta avanti senza fatica visibile.

### capovolta

- 1: Il tempo fra un passaggio e l'altro si è accorciato troppo: i pezzi in aria superano quelli che la mano riesce a raccogliere e uno sta già scendendo fuori dal giro.
- 2: La cadenza si è rotta a metà giro: ogni cosa chiede attenzione nello stesso istante e l'equilibrio che prima nasceva dal movimento viene consumato dallo stesso movimento.
- 3: Scivola per prima la cosa a cui tocca il turno più lontano: tutto sta ancora su per inerzia, mentre il ritmo che lo teneva in alto ha perso il passo.

## Tre di Denari

### dritta

- 1: Il cantiere è aperto e le mani che ci lavorano sono più di una, ognuna col suo mestiere. Quello che stai facendo passa sotto gli occhi di un committente e la competenza viene riconosciuta.
- 2: Ruoli distinti lavorano sullo stesso disegno con un pezzo per uno. Il lavoro sta su perché i pezzi combaciano e la competenza di ogni mano si vede nel suo.
- 3: Un risultato concreto esce dal cantiere a più mani, piccolo e già visibile, già in piedi. Il merito porta più nomi e la parte col tuo si legge bene.

### capovolta

- 1: I compiti non hanno un titolare. Più mani stanno sullo stesso pezzo e nessuna su quello accanto, con la stessa buona volontà da ogni parte. Il lavoro resta fermo dove i pezzi non combaciano.
- 2: Il disegno è stato letto in modi diversi e nessuno lo ha detto chiaramente. Ognuno lavora bene sul proprio pezzo e l'insieme non ingrana. La buona fede c'è tutta, le istruzioni no.
- 3: Quello che manca è la parola sui ruoli: aspettative mai dichiarate, consegne una sopra l'altra, un lavoro condiviso che gira a vuoto mentre tutti spingono.

## Quattro di Denari

### dritta

- 1: Quello che possiedi sta fermo e contato addosso a chi lo tiene: niente esce, niente di nuovo entra e la sicurezza che ne viene è vera quanto le dita che la mantengono chiusa.
- 2: Conservare diventa un mestiere: si conta, si serra, si tiene addosso. Il bene non circola e proprio per questo resta dov'è, al sicuro come un peso stretto contro il petto.
- 3: Stretto fra le braccia, il possesso esercita la tua capacità di non lasciare andare: quello che hai è al riparo e le mani che lo tengono non hanno altro da fare.

### capovolta

- 1: Il timore di restare senza chiude le dita intorno a quello che hai e quello che hai le tiene chiuse a sua volta: la stretta funziona in entrambi i sensi e costa a chi la esercita.
- 2: L'attaccamento lavora contro la tua capacità di lasciare circolare: quanto più una cosa viene serrata tanto più tiene stretto chi la trattiene fra le mani.
- 3: Dentro il pugno chiuso stanno poche cose e un timore grande: quello che hai non si muove perché la paura trova più sicuro il fermo, mentre le mani occupate a trattenere non possono fare altro.

## Cinque di Denari

### dritta

- 1: Il freddo sta da questa parte del muro e la luce calda dall'altra, a pochi passi: la mancanza ha una porta accanto e la tua vergogna tiene la mano lontana dal battente.
- 2: Una esclusione concreta ti riguarda: da fuori la soglia manca il necessario mentre dentro una stanza è già accesa e nessuno di là sa che stai passando.
- 3: Resti fuori mentre il riparo esiste a qualche metro di distanza: la solitudine ha la forma di un muro, con il tepore di là e la richiesta di aiuto ancora non fatta.

### capovolta

- 1: La porta si apre dall'interno e il tuo rientro al caldo comincia: una mano arriva verso fuori, tesa a te che non hai niente da mettere al suo posto.
- 2: Arriva un sostegno mentre stai ancora sulla soglia: il freddo allenta e il necessario torna un pezzo alla volta, da una parte che non avevi guardato.
- 3: Rientra quello che mancava e il muro ha una porta: la solitudine si assottiglia a partire dall'esterno, con qualcuno che si è accorto del tuo passaggio.

## Sei di Denari

### dritta

- 1: Ogni sostegno che esce dalle tue mani è pesato prima e rientra nella misura con cui è uscito, dentro uno scambio che va e torna e resta pari da una parte come dall'altra.
- 2: Un aiuto va e viene fra te e un'altra parte senza che il piatto si inclini. La ricchezza che ti attraversa aumenta dal circolare e da ferma non rende niente.
- 3: La tua mano che dà è la stessa che prende e i piatti restano pari, perché l'aiuto che si muove fra le parti non si ferma mai in una.

### capovolta

- 1: Il dare va in un senso solo. Esce dalle tue mani verso una parte precisa che non restituisce e dalla direzione opposta non rientra niente, così la generosità si svuota alla misura di quanto passa.
- 2: Una generosità mal riposta ti prosciuga perché la controparte riceve e tiene: l'andata è piena, il ritorno non c'è e lo squilibrio sta tutto da una parte.
- 3: Dare molto a una parte che non ricambia svuota chi porta. Del movimento manca proprio la metà che dovrebbe rientrare verso di te ed è squilibrio, non bontà.

## Sette di Denari

### dritta

- 1: Ferma e sul posto, questa maturazione non chiede altro lavoro: quello che hai piantato pende già sul ramo a mezzo peso e il tempo di dentro è l'unico che gli manca.
- 2: Un frutto duro ti ferma la mano a mezz'aria: la fatica l'hai già fatta tutta e quello che resta appartiene al legno, che lavora coi suoi tempi e senza di te.
- 3: La capacità in esercizio è valutare da fermo: giri intorno a quello che hai coltivato e lo soppesi senza staccarlo, perché la sua dolcezza dipende da quanto resta attaccato.

### capovolta

- 1: Il sospetto cade sul seme più che sul ritardo: hai zappato bene e la zolla non rende, così la cosa da riguardare è la scelta fatta quando hai piantato.
- 2: Quello che va riguardato è la destinazione della tua energia: la fretta ti morde le mani mentre il raccolto tarda. La domanda riguarda quello che hai messo sotto, non quanto aspetti.
- 3: Due spiegazioni stanno davanti alla stessa zolla magra: la tua impazienza e il seme scelto male. La seconda ti riporta alla mano che ha scelto, mentre la prima ti tiene a guardare il cielo.

## Otto di Denari

### dritta

- 1: Lo stesso gesto torna sul pezzo seguente e a ogni ritorno viene via un errore: lavora qui la mano di bottega, che conosce il mestiere e lo sta portando a punto fino.
- 2: La pazienza del banco tiene il centro: un pezzo per volta, tutti simili, rifiniti l'uno dietro l'altro, con la qualità che sale per ripetizione più che per idee nuove.
- 3: Cresce la perizia dentro il gesto ripetuto: c'è una serie da finire e ogni dettaglio chiuso bene lascia dietro di sé un pezzo di mestiere in più di prima.

### capovolta

- 1: Il gesto esce ancora preciso e dentro non porta più niente: la serie continua a chiudersi nei tempi, mentre l'interesse che la rendeva mestiere è rimasto indietro.
- 2: Monotonia al banco: il lavoro si fa, si consegna e ritorna uguale, con la cura dei dettagli ridotta alla misura minima che basta a farli passare.
- 3: Resta la mano e manca il motivo: la pratica ripetuta tiene in piedi la produzione, mentre la gabbia si stringe proprio dove prima stava il gusto di fare bene.

## Nove di Denari

### dritta

- 1: Il frutto è già in tavola e nessuna firma esterna serve per prenderlo. Lo spazio in cui stai è stato pagato col tuo lavoro e la sua misura basta a vivere con agio.
- 2: L'autonomia è la sostanza del raccolto: tempo tuo, spese che non devi giustificare, un posto dove entri senza chiedere permesso. Il godimento tranquillo ne fa parte.
- 3: Quello che hai costruito regge da sé e lascia spazio all'ozio, con un orto cresciuto a forza di cure, un piacere lento, la compagnia di quello che hai fatto con le mani.

### capovolta

- 1: Ogni spesa fatta per essere guardati compra uno sguardo e la paga con un pezzo della libertà che il tuo lavoro ha costruito.
- 2: La mano resta aperta verso fuori e quello che esce serve a mostrare. La vitrina mangia l'orto e l'autonomia diventa più sottile a ogni uscita, senza che nessuno la porti via.
- 3: Quello che vacilla è lo spazio tuo, quello costruito col lavoro. Sta in piedi finché le uscite restano dentro la misura e la misura è stata lasciata agli occhi degli altri.

## Dieci di Denari

### dritta

- 1: Le radici affondano sotto il tempo di una sola vita: quello che metti su sta in piedi anche quando la mano che lo ha fatto non c'è più e nutre chi abita lo stesso tetto dopo.
- 2: Sotto un tetto stanno insieme generazioni diverse grazie a una ricchezza lenta: i vecchi, i figli, i bambini e il cane sulla soglia, con beni che portano un nome di famiglia e non quello di una persona.
- 3: Dopo di te qualcosa resta in piedi: il bene passa di mano dentro la stessa famiglia, il nome sopravvive a chi lo portava e la tua parte in tutto questo è quella di chi ha piantato.

### capovolta

- 1: Un bene tenuto insieme dai parenti diventa il motivo per cui si litiga fra loro: l'abbondanza non scarseggia; manca l'accordo su chi decide e su quanto spetta a ciascuno.
- 2: La proprietà è plurale e l'attrito nasce da questo: più mani stanno sulla stessa cosa, ciascuna conta la propria parte in modo diverso e quello che una generazione aveva unito si spezza in rivendicazioni.
- 3: Fra chi porta lo stesso nome corre una contesa su cose che nessuno possiede da solo: il tetto regge, i beni restano e ognuno sotto quel tetto tira dalla sua parte.

## Fante di Denari

### dritta

- 1: Una materia nuova sta davanti a te nello stato dell'apprendistato: niente è ancora fatto e tutto passa dall'imparare, con la pazienza che il principio richiede.
- 2: Il sapere entra prima della pratica e diventa solido soltanto mentre lo applichi: una promessa presa impegna a un esercizio lungo, con la mano ancora inesperta sopra una cosa concreta.
- 3: Hai per le mani un progetto allo stato di esercizio: la materia è già concreta mentre la perizia manca e l'impegno preso lavora al posto del talento.

### capovolta

- 1: L'impegno che hai preso resta allo stato di parola: la promessa esiste, la prima applicazione no e il progetto si è fermato appena dopo il principio.
- 2: Tiene a mezzo l'apprendistato una distrazione, oppure il lavoro cominciato è rimasto a metà: dall'imparare alla pratica il passaggio non è avvenuto e la materia aspetta ancora la tua prima mano.
- 3: Resta scoperto il tratto fra la promessa e il primo esercizio: niente di fatto da mostrare, l'intenzione intatta, la materia nello stesso stato in cui l'hai trovata.

## Cavaliere di Denari

### dritta

- 1: Il ritmo con cui ti muovi non cambia e non si interrompe mai. La lentezza ti porta al posto di limitarti e a tenere è la regolarità, non la spinta.
- 2: Una regolarità senza strappi ti porta avanti di poco per volta e la cosa che conta è che non si fermi, con un'affidabilità fatta di gesti uguali e non di scatti.
- 3: Con metodo e pazienza procedi sempre allo stesso modo, senza accelerare e senza soste, perché a portarti in fondo è una costanza che non conosce interruzioni.

### capovolta

- 1: La costanza che ti portava avanti si è fatta immobilità: la direzione resta giusta e visibile e la prudenza trattiene ogni partenza per non sbagliarla.
- 2: Ogni tappa slitta per un dubbio di troppo mentre la cautela che prima era metodo tiene fermo il tuo avanzare. La mira resta in vista e il terreno non è cambiato.
- 3: Immobilità al posto del movimento, con la direzione intatta. Niente da correggere nella tua mira e un rinvio continuo nel partire, perché la prudenza chiede una garanzia prima di ogni tappa.

## Regina di Denari

### dritta

- 1: La stessa mano porta da mangiare a chi ti è caro e concime a quello che stai costruendo: i mezzi restano concreti e arrivano a tutti i fronti, perché cuore e praticità in te lavorano insieme.
- 2: Abbondante e coi piedi per terra, la tua cura non fa discorsi: compra, cucina, sistema, innaffia. Con lo stesso gesto raggiunge le persone e le cose che tieni in piedi.
- 3: Due cose fioriscono nelle tue mani per lo stesso motivo: quello che abiti e quello che stai facendo crescere. Il concime è lo stesso nei due casi, attenzione pratica e mezzi che si toccano.

### capovolta

- 1: Un elenco di cose da curare funziona bene: ogni nome che ci sta sopra riceve quello che gli serve, dalla spesa alle cose da pagare. Il tuo nome su quel foglio nessuno lo ha scritto.
- 2: Pratico e puntuale, il tuo dare arriva dove serve: paghi, provvedi, ricordi al posto degli altri le cose loro. La stessa precisione rivolta a te sta su una riga rimasta vuota.
- 3: Lo stesso giardino che innaffi per tutti ha un'aiuola che l'acqua non raggiunge ed è la tua. La generosità lavora bene verso fuori mentre verso dentro resta in attesa di un turno.

## Re di Denari

### dritta

- 1: Un patrimonio costruito di persona rende bene nelle mani che lo hanno fatto: si spende con larghezza, torna su per buon governo e la competenza vale quanto la somma.
- 2: La sicurezza ha radice in anni di beni maneggiati: distribuisce senza paura, calcola senza strettezza e il denaro che passa da quelle mani cresce invece di assottigliarsi.
- 3: Siede larga, la prosperità maturata a lungo: dà ospitalità, paga il dovuto, fa girare i beni e tiene il conto con la calma di una mano che non teme di aprirsi.

### capovolta

- 1: Il metro del possesso si allarga a tutto: le persone intorno vengono valutate sul loro rendimento e il governo di una ricchezza larga si fa duro dove potrebbe distribuire.
- 2: L'abbondanza si è irrigidita in autorità: ordina, trattiene le decisioni e il valore di chi la porta si è saldato ai beni che possiede fino a non distinguersi più.
- 3: Sta al centro di ogni scelta il bisogno di tenere i beni al primo posto: il patrimonio decide al posto di chi lo amministra e il comando segue la convenienza.

## Asso di Spade

### dritta

- 1: Basta un taglio solo a separare il vero dal falso e dopo di lui la linea resta visibile. La cosa ha un nome esatto e il nome esatto è tutta la forza in gioco.
- 2: La lucidità ha la forma di una prima definizione. Dove stava un mucchio indistinto rimane una frase che si può ripetere parola per parola.
- 3: Nasce il principio di un pensiero, nudo e senza ornamenti, un'idea sola detta come sta, affilata quanto basta per dividere una cosa dall'altra.

### capovolta

- 1: Il filo è smussato e il taglio esce storto. L'idea che dovrebbe dividere resta appiccicata alla cosa e la parola scelta nomina qualcosa di diverso da quello che intendi.
- 2: Qui l'arnese stesso è in questione. La stessa chiarezza che apre una strada, impugnata male, incide dalla parte sbagliata. Al pensiero manca il contorno e senza contorno ogni frase esce larga.
- 3: Una nebbia sta sul vetro e le forme dietro sembrano altre. Le definizioni perdono i contorni, i nomi scambiano posto e la frase che ne nasce incide una cosa che non era quella.

## Due di Spade

### dritta

- 1: Lo stallo non è fermo per caso: viene mantenuto con le braccia incrociate e con una stoffa sugli occhi, perché i lati della questione pesano uguale e guardarne uno darebbe ragione a lui.
- 2: Tenere l'equilibrio richiede che gli occhi restino coperti: i lati della questione sono simmetrici, la scelta rimandata sta dietro la stoffa e nessuno dei pesi si abbassa.
- 3: Sotto la stoffa che copre gli occhi la questione resta identica a se stessa: nessun peso cresce, nessuno cala e l'immobilità regge solo perché le lame stanno incrociate davanti al petto.

### capovolta

- 1: Le braccia si aprono e la stoffa scende: quello che era stato coperto da te sta di nuovo davanti agli occhi e la questione tenuta in sospeso smette di pesare uguale da tutte le parti.
- 2: La simmetria si rompe e il blocco cede: uno dei lati comincia a valere più dell'altro, la vista torna sulla cosa evitata e girarci intorno costa più che guardarla.
- 3: Cade la copertura che era stata messa a mano e la questione sospesa riemerge con la sua domanda: lo stallo si scioglie perché gli occhi tornano a lavorare.

## Tre di Spade

### dritta

- 1: Una lama ti trapassa il petto con un taglio netto: il dolore ha un punto preciso e una causa venuta da fuori, con l'acqua che scorre sopra senza chiedere permesso.
- 2: Il colpo è arrivato con un bersaglio esatto: la trafittura sta dove respiri e la pioggia batte sopra, mentre le lacrime hanno una direzione sola, fuori.
- 3: Passa una ferita attraverso il tuo petto e il resto sta in piedi: il taglio è aperto, il pianto scorre libero, la pioggia più fitta cade sopra tutto questo.

### capovolta

- 1: La lama esce e il foro comincia a chiudersi: il tuo respiro torna pieno nel petto, con il perdono rivolto a chi ha portato il colpo.
- 2: Smette di piovere sul punto trafitto e il dolore sfuma sul posto: la ferita resta dove era e perde la sua punta, mentre il tuo petto si riempie di nuovo.
- 3: Tiene il segno il taglio e ha finito di aprirsi: il perdono prende il posto del colpo e la tua aria rientra fino in fondo, con la pioggia che cade altrove.

## Quattro di Spade

### dritta

- 1: Il silenzio che viene dopo la fatica rende in forza quello che prende in tempo. La tua mente ne ha bisogno nella stessa misura del corpo e il recupero lavora anche se non si vede.
- 2: Una pausa senza compiti dentro ti scarica la stanchezza mentre non fai niente: la quiete è la materia di questa forza e il tempo che toglie al movimento lo rende in energia.
- 3: La testa trova la calma che il corpo reclama, la stanchezza esce dalle spalle e il tempo che passi senza muoverti ti torna sotto forma di forza.

### capovolta

- 1: Fino in fondo è stato preso il riposo e la quiete ha chiuso il suo lavoro. La forza che ti mancava è rientrata e il movimento riparte con calma, senza strappi al primo gesto.
- 2: Misurata e completa, la quiete si chiude da sé. Hai riposato abbastanza, il silenzio ha reso quanto doveva e la ripresa si fa a misura e non di slancio.
- 3: Basta così per la quiete e il seguito non le appartiene più, mentre il tuo corpo lo sa prima della testa e il moto riprende piano.

## Cinque di Spade

### dritta

- 1: Una vittoria ti resta in mano e il campo attorno si svuota: raccogli le lame di tutti e quello che hai dato per averle pesa più di quanto valga tenerle.
- 2: Si vede un successo e si vedono due schiene che se ne vanno a testa bassa. La parte in penombra è quello che hai perso per arrivarci e l'orgoglio la tiene coperta.
- 3: La domanda dentro questa riuscita riguarda quanto valga: il campo è tuo e nessuno te lo contesta, mentre quello che hai lasciato sul terreno per prenderlo resta tuo da guardare.

### capovolta

- 1: La ragione è tua e resta tua anche se la lasci cadere: quello che apre la faccenda è il perdono e non la prova, perché la pace passa da chi si muove per primo.
- 2: Una spinta a posare le lame ti precede sull'altro: nasce in te mentre il torto sta dalla sua parte e quello che costa è soltanto l'orgoglio tuo.
- 3: L'orgoglio è la sola cosa che metti sul tavolo: il torto sta dalla parte dell'altro mentre il primo passo lo fai tu. La faccenda si chiude senza bisogno di un'ammissione.

## Sei di Spade

### dritta

- 1: Il tragitto è già cominciato e procede piano: l'acqua mossa arretra, qualcuno tiene la rotta e il carico che porti è ridotto al minimo trasportabile.
- 2: Una partenza silenziosa si è messa in moto senza strappi: si attraversa un tratto d'acqua calmo verso un posto diverso e il passaggio stesso raffredda la parte che scottava.
- 3: Allontana più di quanto consoli, questa traversata: il luogo agitato si fa piccolo alle spalle, la sponda nuova cresce davanti e il moto lento tiene insieme chi la fa.

### capovolta

- 1: Il viaggio va avanti con un peso che non era stato calcolato: il distacco si fa sentire in mezzo al tratto d'acqua, quando tornare costa quanto proseguire.
- 2: Una partenza decisa procede lenta per il carico: quello che hai lasciato viaggia comunque con te e la riva vecchia continua a tirare da dietro.
- 3: Pesa il bagaglio di una traversata già avviata: il corpo ha preso la direzione nuova, l'attaccamento resta ancorato dove stava e il passaggio si fa più lungo del previsto.

## Sette di Spade

### dritta

- 1: La mossa passa di lato e senza rumore, dove non c'è nessuno a guardare, prende quello che serve ed esce in punta di piedi, senza aprire la porta principale.
- 2: L'ingegno fa il lavoro che la forza farebbe sbattendo, con un calcolo prima, un passo scelto bene, nessun rumore. Il conto che la mossa porta con sé è il nome che le dai quando nessuno ascolta.
- 3: Un vantaggio si prende senza scontro, aggirando l'ostacolo, lasciando il grosso dove sta e portando via la parte che conta. L'arte sta nel silenzio, il prezzo nel sapere che cosa è stato portato via.

### capovolta

- 1: Una cosa coperta sta salendo in superficie, tua oppure di qualcun altro. Finché resta sotto va mantenuta e mantenerla costa memoria, attenzione e silenzio ogni volta che si parla.
- 2: Il peso è di manutenzione: una versione da ricordare esatta, una seconda da non confondere con la prima e la coscienza che tiene il conto di entrambe.
- 3: È la superficie a lavorare. L'acqua restituisce piano quello che è stato buttato dentro e la trasparenza non ha niente da tenere a memoria.

## Otto di Spade

### dritta

- 1: La prigione è fatta di pensiero e tiene come se fosse di pietra: i nodi intorno alle braccia sono larghi, il cerchio di lame è piantato nel fango e il blocco sta nel credito che dai al racconto.
- 2: Il limite che senti è solido quanto la convinzione che lo sostiene: la testa costruisce le pareti, le lega con corde comode e poi dichiara che non ci si può muovere.
- 3: Nella mente il recinto è completo: ogni lato sta al suo posto, i nodi sono stretti con cura e la loro misura vera resta più ampia di quella che il pensiero riferisce.

### capovolta

- 1: Le corde scivolano giù senza essere tagliate: erano larghe dall'inizio e la paura le aveva misurate male, così il cerchio di lame mostra il varco che aveva sempre avuto.
- 2: La misura sbagliata viene corretta e lo spazio risulta più ampio di quanto era stato riferito: i nodi si sfilano da soli e il terreno fuori dal cerchio si rivela calpestabile.
- 3: Il recinto si apre senza che nulla venga forzato: la stretta attorno alle braccia era allentata da prima e quello che cade adesso è il racconto che la dava per saldissima.

## Nove di Spade

### dritta

- 1: Al buio la tua mente lavora da sola e gira a vuoto: a occhi aperti nel letto le paure si gonfiano fino a una misura che la luce non conferma.
- 2: Il pensiero cupo si fabbrica nelle ore in cui tutto tace e arriva travestito da fatto: nella stanza niente si sposta mentre nella tua testa si muove ogni cosa e il buio fa da moltiplicatore.
- 3: Nelle ore senza sonno la mente monta una storia e la spaccia per cronaca: la paura cresce di notte quanto scende di giorno, con il tuo corpo fermo e il pensiero in corsa.

### capovolta

- 1: La morsa allenta e il colmo della notte sta dietro: quello che girava chiuso nella tua testa trova parole e il carico si divide con la persona che le ascolta.
- 2: Esce dalla tua testa il rimuginio e prende la forma di una frase detta a un'altra persona: il pensiero che fuori ha un suono fa meno paura di quello tenuto dentro.
- 3: Detto fuori a qualcuno, il tuo pensiero perde la taglia che aveva al buio: la paura allenta la stretta e la notte ha già passato il suo punto più alto.

## Dieci di Spade

### dritta

- 1: Il fondo è stato toccato e sotto non c'è altro da scendere: la battaglia che ti ha occupato si è chiusa davvero e posare le armi è il riconoscimento di quel fatto.
- 2: Arrendersi è il riconoscimento di un fatto. Il ciclo doloroso che hai attraversato si è chiuso, il punto più basso è raggiunto e sotto di esso non c'è nessun altro gradino.
- 3: Più in basso di così non si scende e quello che senti è il fondo. La battaglia è conclusa per davvero e riconoscerlo è l'unico atto che resta in piedi.

### capovolta

- 1: Da terra il corpo si solleva per conto suo dopo una chiusura completa. Di prima non resta niente da recuperare e ogni gesto che fai rimette in piedi un pezzo.
- 2: Una chiusura senza avanzi ha lasciato il terreno nudo: si ricomincia da nulla, con un movimento lento che è tuo e che a ogni appoggio rimette su qualcosa.
- 3: Lento e tuo, il movimento riparte dal basso. Niente di quello che c'era prima è rimasto da salvare e i gesti piccoli ti rimettono su una cosa per volta.

## Fante di Spade

### dritta

- 1: La capacità in esercizio è l'attenzione: guardi, domandi, metti insieme pezzi di vero che nessuno ti ha consegnato, mentre la lingua pronta vorrebbe ripeterli appena arrivano.
- 2: Giovane e sveglio, questo modo di sapere si procura le cose da sé, un pezzo per volta e col vento in faccia. La misura serve dopo, quando quello che hai raccolto cerca parole.
- 3: Quella prontezza che ti fa scoprire ti fa anche parlare: trova quello che gli altri non guardano e spinge a riferirlo di corsa, perché la cura nelle parole è la parte da imparare.

### capovolta

- 1: La materia sono le tue parole su chi non è presente: girano senza che nessuno le abbia verificate e tornano sul mittente col nome di chi le ha messe in giro.
- 2: Leggero e sparso, questo taglio tuo arriva senza mira: una chiacchiera detta per riempire un silenzio ferisce chi non era presente e il graffio dura più dell'intenzione che l'ha mossa.
- 3: Una lingua pronta come la tua fa due cose insieme: sparge in fretta quello che non ha verificato e riconsegna tutto a chi lo ha detto, con calma e fino all'ultima parola.

## Cavaliere di Spade

### dritta

- 1: Un'idea decisa parte in linea retta e non rallenta: taglia il tragitto, arriva sullo scopo prima degli altri e il vento che fa ai lati non entra nel calcolo.
- 2: La mente carica a testa bassa: fissa un punto, ci va contro a velocità piena e una discussione che altrove durerebbe giorni si chiude nel tempo di un affondo.
- 3: Corre il pensiero davanti a tutto il resto, armato e diretto: arriva per primo, parla per primo e lo slancio che lo porta travolge chi gli capita di fianco.

### capovolta

- 1: La fretta sceglie il bersaglio al posto del giudizio: la frase parte già lanciata, colpisce con precisione il punto sbagliato e il danno si misura lungo il tragitto.
- 2: Un assalto arriva prima della comprensione: una faccenda mezzo capita viene portata avanti a velocità piena e chi stava sulla traiettoria se ne accorge per urto.
- 3: Va più veloce della ragione, lo slancio: taglia conversazioni a metà, lascia dietro parole affilate che continuano a lavorare e ogni metro guadagnato va rifatto indietro.

## Regina di Spade

### dritta

- 1: Il no detto in faccia fa da materia, breve e senza giri. Tiene fuori quello che non deve entrare. La franchezza protegge chi la usa prima di informare chi la riceve.
- 2: L'intelligenza lavora per conto proprio e non per la stanza. Giudica quello che riguarda te e lo dice una volta sola, con una frase che non ha bisogno di essere spiegata.
- 3: Qui conta il mestiere di distinguere, che separa quello che vale da quello che somiglia a quello che vale, poi lo dice. Il costo di questa chiarezza è la scomodità e il dono è lo stesso.

### capovolta

- 1: La solitudine è una decisione e la durezza il suo materiale. Il filo del giudizio lavora verso dentro, sulla stessa persona che lo tiene.
- 2: Il taglio punta all'interno e ogni mancanza tua viene pesata col metro che useresti per un estraneo, senza sconti per nessuno e meno che mai per te.
- 3: Una severità che parte da te e prosegue verso gli altri, con parole precise, affetto tenuto a distanza, una porta chiusa per scelta. Il freddo che entra da quella porta è quello di casa.

## Re di Spade

### dritta

- 1: Un'autorità di mente decide cose che riguardano altre persone e le decide con la stessa regola per tutte: l'equità viene prima del caso, la ragione sta al servizio del bene e la parola data vincola chi l'ha pronunciata.
- 2: La lucidità diventa un incarico quando qualcuno viene a chiedere come stanno le cose: la risposta è onesta anche dove è scomoda e il suo peso ricade su chi l'ha formulata.
- 3: Chi siede in alto e usa la mente come lama misura il vero e il falso per conto di altri: l'etica tiene il banco, il bene decide l'uso della ragione e nessuna simpatia sposta il giudizio.

### capovolta

- 1: Il rigore decide con esattezza su persone che non entrano nel conto: la discussione viene vinta, la regola tiene e intorno al tavolo rimane meno gente di prima.
- 2: La durezza esercitata dall'alto riguarda sempre qualcun altro: si delibera senza contare chi riceve la decisione e il freddo con cui viene detta costa più di quello che ottiene.
- 3: In cattedra la logica taglia netto e la compassione resta in corridoio: le persone si riducono a questioni e la risposta esatta allontana proprio quelli che l'avevano chiesta.
