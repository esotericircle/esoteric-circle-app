# LA POSIZIONE: COPRE

Cio' che copre, la prima della Croce Celtica.

**Fonte da riempire.** Per ogni carta e per ogni verso tre varianti dello
stesso scheletro, `- 1:`, `- 2:`, `- 3:`, scritte dall'Architetto (ordine FI,
aggiunta A1 e A4). Una riga vuota e' un testo che non c'e' ancora. Una
variante e' piena in tutte le 156 carte-verso o vuota in tutte: a meta', il
tool si ferma e nomina le righe che mancano.

**Le tre varianti vengono dal corpus dell'11 ottobre 2026**, scritte
dall'Architetto con dodici scrittori e consegnate col commit 394e9c5, pulite
sulle dieci regole del metro. La posizione sta al **59,4 per cento** in prova
cieca appaiata con dodici lettori e 936 testi nello stesso giro; contro la
carta sola, stesso giro, 59,4 contro 85,9, e dodici lettori su dodici
preferiscono la carta sola. I lettori nominano la causa: i testi che descrivono
un principio invece della figura della carta. Provenienza scritta da Code con
l'ordine FK, aggiunta 2 voce A11, dal messaggio del commit 394e9c5, perche' la
regola FJ.4 vuole che ogni posizione con testi dica da dove vengono.

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

## Il Matto

### dritta

- 1: Nella tua domanda circola un'aria di primo mattino, leggera perché dentro non c'è ancora niente di apparecchiato: la cosa respira come chi parte con le mani libere e un passo solo da vedere.
- 2: La forza che lavora sulla tua domanda ti chiede di non portarti dietro garanzie né piani completi: per andare avanti ti basta vedere il primo movimento da fare.
- 3: Cade sulla cosa che hai in mano una luce stretta: accende il tratto sotto il piede e lascia buio il resto della strada, perché di tutto si vede quanto basta a muoverla di un passo.

### capovolta

- 1: Attraversa la tua domanda una spinta che corre verso l'orlo senza dichiarare la propria origine: può nascere dal coraggio oppure da qualcosa che nessuno ha guardato. Il verso del movimento resta identico.
- 2: Sulla tua domanda pesa un clima che premia chi parte subito e non chiede da dove nasca la fretta: così l'impulso passa avanti alla riflessione.
- 3: In questa faccenda conta di più muoversi presto che sapere perché ci si muove: nessuno ti chiede se è slancio vero o voglia di scappare.

## Il Mago

### dritta

- 1: L'aria intorno alla tua domanda è quella di un banco già apparecchiato: ogni strumento che serve sta a distanza di braccio e la temperatura che la cosa trova è quella del fare.
- 2: Una pretesa precisa lavora sulla tua domanda: che l'intenzione passi in atto adesso, con la mano e la parola nello stesso gesto. La forza non ammette che la materia resti pensiero.
- 3: Sotto questa forza la tua domanda mostra soprattutto i mezzi a disposizione: tutto quello che serve per muoverla è già pronto, mentre rimandare perde ormai ogni giustificazione.

### capovolta

- 1: Dentro la tua domanda passa una corrente che si ferma a metà strada: parte dalla parola detta e si esaurisce prima del gesto che la manterrebbe. Il dono resta intero per tutto il tragitto.
- 2: La regola non scritta che la tua domanda sta seguendo premia quello che viene annunciato: il credito va alla promessa, mentre il talento aspetta il suo turno nel cassetto chiuso.
- 3: Il criterio che assegna valore dentro la tua domanda misura l'annuncio e non la consegna: quanto si dichiara pesa molto, quanto le mani mantengono pesa poco, anche quando il talento c'è.

## La Papessa

### dritta

- 1: Attorno alla cosa che chiedi lavora un silenzio spesso: in quell'aria quieta quello che non è detto si sente comunque; la tua domanda respira dentro un sapere che le parole non hanno ancora raggiunto.
- 2: Una luce bassa governa la tua domanda: mostra i contorni e lascia il resto dietro un velo. Ti basta per orientarti, mentre il grosso della faccenda non si illumina a parole.
- 3: Sulla tua domanda lavora una riserva: una conoscenza intera resta chiusa e non si fa frase, mentre il tempo della quiete compie il lavoro che le spiegazioni non compiono.

### capovolta

- 1: Questa faccenda avrebbe bisogno di quiete ma intorno c'è troppo rumore: al posto di ciò che sai già arrivano argomenti che non bastano, così la verità resta sotto.
- 2: Sulla tua domanda vale una regola non scritta che dà spazio solo a ciò che si può dimostrare: quello che senti senza prove resta coperto dal rumore delle discussioni.
- 3: Il tono sulla tua faccenda è alzato: si parla per prove e per risposte pronte. Sotto quel registro una parte sa in un sussurro che il clamore ricopre senza riuscire a spegnerlo.

## L'Imperatrice

### dritta

- 1: Un tepore fertile lavora sulla tua questione: quello che vi sta dentro trova terra grassa, acqua, tempo lento; ingrossa prima di prendere una forma riconoscibile.
- 2: Questa forza pretende dalla tua questione i tempi della gestazione: ammette nutrimento, ammette attesa lunga, non ammette strappi. Quello che vive là dentro cresce alla velocità che ha.
- 3: Sotto questa forza la tua questione mostra soprattutto ciò che è vivo e concreto: risalta quanto sta crescendo, mentre date e confini precisi restano in secondo piano.

### capovolta

- 1: La linfa della tua questione corre tutta verso fuori: alimenta i rami fino alla punta e lascia asciutto il punto da cui i rami partono. Il generare continua a spese della sorgente.
- 2: Dentro la tua questione vale adesso una regola muta: si nutre quello che si vede, non quello che fa crescere. Il fuori riceve la sua razione piena; la radice non è compresa nel conto.
- 3: In questa faccenda conta solo ciò che si vede fiorire: la tua attenzione va tutta ai risultati esterni, mentre ciò che li alimenta non viene nemmeno considerato.

## L'Imperatore

### dritta

- 1: Sulla tua questione tira un'aria di norma dichiarata: niente di quello che la riguarda si muove fuori da una forma stabilita; ogni parte risponde al medesimo ordinamento.
- 2: Una corrente dall'alto verso il basso attraversa la tua domanda: quello che conta al centro scende ai bordi senza cambiare per strada, cosicché ogni parte della cosa riceve la stessa regola.
- 3: Dentro la tua questione prende valore quello che ha una forma dichiarata: un confine scritto conta più di un accordo a parole, mentre una cosa senza titolo non entra nel conto.

### capovolta

- 1: Questa forza pretende dalla tua domanda un ordine già scritto prima di ammettere qualunque cosa: dove il comando esiste non concede eccezioni, dove non esiste non riconosce nessuna parola data.
- 2: La regola a cui la tua questione obbedisce adesso premia la lettera sopra lo scopo: trova strada quello che è conforme, resta fermo quello che sarebbe utile e non ha una casella dove stare.
- 3: Un comando sta stringendo le giunture della tua questione fino a togliere gioco, oppure quelle giunture stanno senza vincolo nessuno: in entrambi i casi la forma decide al posto della sostanza.

## Il Papa

### dritta

- 1: Sulla tua domanda lavora una dottrina che altri hanno già formulato: la cosa sta obbedendo a un insegnamento ricevuto, dove ogni passo ha un precedente e una formula imparata che lo accompagna.
- 2: In questa tua faccenda prende valore quello che ha una scuola dietro: la trasmissione decide; quello che nessuno ha insegnato prima di adesso conta poco, anche se funziona.
- 3: Una sapienza antica chiede alla tua domanda di riconoscere una paternità: pretende un maestro, un testo, una catena di mani che l'abbiano custodita prima di arrivare qui.

### capovolta

- 1: Una formula tramandata illumina sempre meno la tua domanda: quello che nel sentiero già tracciato stava in piena luce adesso resta in ombra, mentre il resto non viene nominato da nessuna regola.
- 2: Un sapere consegnato si sta scollando dalla faccenda mentre la guardi: la spinta che lavora qui apre uno scarto fra la regola imparata e la cosa concreta che hai davanti.
- 3: Nell'aria di questa tua domanda si sente una convenzione che non combacia più: il senso comune a cui tutti si richiamano gira a vuoto su quello che chiedi.

## Gli Amanti

### dritta

- 1: Al cuore della tua domanda c'è una scelta d'amore o di valori: non basta che ti attiri, deve anche somigliarti, perché qui testa e cuore devono dire la stessa cosa.
- 2: Sulla tua questione grava un impegno serio, di quelli che non si ritirano: l'attrazione da sola non basta a decidere, serve che anche ciò in cui credi sia d'accordo.
- 3: Questa situazione ti chiede di esporti per intero: desiderio e convinzioni devono uscire allo scoperto insieme, perché una decisione presa a metà qui non regge.

### capovolta

- 1: Al cuore della tua domanda c'è un disaccordo interiore: il desiderio parla forte, ciò in cui credi tace, così nessuna delle due parti riesce a convincere l'altra.
- 2: Sulla tua questione vedi bene solo metà del bivio: la parte che desidera è in piena vista, quella che crede resta in disparte, eppure appartengono entrambe a te.
- 3: Dentro la tua domanda oscilli fra ciò che credi e ciò che vuoi: sono due spinte tue, nessuna arriva da fuori, ma finché non si accordano il movimento non si ferma.

## Il Carro

### dritta

- 1: Al cuore della tua domanda c'è una volontà che governa: due spinte contrarie lavorano per la stessa meta, perché la direzione da prendere l'hai già decisa tu con chiarezza.
- 2: Su questa questione prevale in questo periodo la tua padronanza: un andamento fermo e continuo, senza strappi, dove conta molto più la mano che guida che la fortuna del momento.
- 3: La tua domanda ha il clima di una corsa ben condotta: affronti le difficoltà di petto, mentre le forze opposte che senti procedono allo stesso ritmo sotto il tuo controllo.

### capovolta

- 1: Al cuore della tua domanda c'è un problema di guida: le due spinte che senti sono entrambe tue, ma tirano ciascuna per sé finché non le prendi in mano con decisione.
- 2: Sulla tua questione si vedono bene le spinte che tirano in versi opposti, mentre resta fuori vista la direzione comune verso cui dovresti portarle con decisione.
- 3: La tua domanda procede a zig zag: l'energia c'è tutta, ma cambia verso a ogni scossa perché ti manca una decisione chiara su dove andare.

## La Giustizia

### dritta

- 1: Al cuore della tua domanda c'è una regola semplice: ogni effetto torna a chi lo ha causato, senza sconti né aggiunte, quindi ciò che metti è ciò che ritorna.
- 2: Nella tua questione conta ciò che le azioni producono davvero, non quanto erano buone le intenzioni: davanti a questa misura anche le tue giustificazioni migliori valgono poco.
- 3: Sulla tua domanda c'è un'aria limpida: ogni fatto ha un nome e una misura, quindi anche gli aspetti più scomodi vengono fuori invece di restare nascosti alla vista.

### capovolta

- 1: Al cuore della tua domanda c'è una responsabilità da chiamare per nome: finché attribuisci al caso ciò che è rimasto in sospeso, la questione non può tornare in pari.
- 2: Nella tua questione c'è un conto aperto a tuo nome, mentre la causa viene cercata altrove: resta lì, ben visibile, finché non riconosci l'atto come tuo.
- 3: Sulla tua domanda la chiarezza cade proprio dove la responsabilità viene spostata su altri: mostra da dove la cosa è partita e toglie forza alle spiegazioni comode.

## L'Eremita

### dritta

- 1: Al cuore della tua domanda c'è un bisogno di silenzio: meno rumore intorno ti permette di vedere bene un tratto alla volta, così ciò che resta in vista diventa più chiaro di prima.
- 2: La tua questione si muove adesso a bassa intensità: si parla poco, si procede piano, mentre il silenzio fa per te il lavoro che altrove fanno le parole.
- 3: Sulla tua domanda c'è un clima raccolto e appartato: pochi stimoli, tempi lunghi, un'attenzione che arriva fin dove ti serve per il prossimo gesto e non oltre.

### capovolta

- 1: Al cuore della tua questione c'è una chiusura che si stringe: lasci entrare solo ciò che passa dai tuoi pensieri, così il raccoglimento diventa la condizione di tutto il resto.
- 2: La lanterna, dentro la tua questione, illumina soltanto l'interno: si vedono i pensieri messi in fila, resta nel buio il tratto di strada che riporta verso gli altri.
- 3: Nella tua questione tutto si raccoglie verso l'interno: le cose entrano e nessuna esce, così la chiusura si fa più fitta mentre la via verso gli altri ti si restringe.

## La Ruota della Fortuna

### dritta

- 1: Al cuore della tua questione c'è un giro in corso che cambia ciò che vedi: alcuni aspetti tornano in primo piano, altri passano in secondo, senza che nessuno lo decida.
- 2: Nella tua domanda conta molto il momento del ciclo: la stessa cosa vale molto quando la situazione sale e poco quando scende, anche se il suo valore non cambia.
- 3: Sulla tua questione torna un ritmo che conosci già: non dipende da chi decide, ma da ciò che ricomincia da sé quando arriva il suo momento, come le stagioni.

### capovolta

- 1: Al cuore della tua domanda c'è un movimento circolare che ti riporta sempre allo stesso punto: l'energia si spende tutta, ma la situazione resta quella di prima.
- 2: Nella tua questione si ripete lo stesso schema: ogni giro ricalca il precedente e ti consuma sempre nello stesso punto, senza mai farti avanzare di un tratto.
- 3: Sulla tua questione manca un appiglio: ciò che si muove non ti offre niente da afferrare, così la spinta ti passa accanto senza che tu riesca a sfruttarla.

## La Forza

### dritta

- 1: Al cuore della tua domanda c'è una dolcezza che non cede: tratta ciò che si agita nella situazione con calma ferma, come chi avvicina un animale grande senza paura.
- 2: Il tono della tua questione è mite e deciso insieme: niente scatti né grida, perché ciò che si agita si calma proprio quando nessuno lo sfida.
- 3: Nella tua domanda agisce una spinta paziente che non costringe niente: muove le cose con lentezza, piegando con la calma ciò che la violenza avrebbe spezzato.

### capovolta

- 1: Nell'aria di questa faccenda c'è un irrigidimento: la tua questione viene affrontata a denti stretti, come se governare quello che si agita volesse muscoli al posto della pazienza.
- 2: Nella tua domanda sembra valere solo ciò che si impone di prepotenza: la mitezza non viene considerata efficace e la tua calma viene scambiata per resa.
- 3: Questa situazione vuole tutto domato a colpi di braccio: pretende da te prove di tenuta a ogni momento e non riconosce la calma come un modo di guidare.

## L'Appeso

### dritta

- 1: Sulla tua domanda pesa adesso un tempo di attesa: le cose non si muovono e forzarle serve a poco, mentre guardarle da un'altra angolazione ti mostra ciò che prima non vedevi.
- 2: Il clima della tua questione premia chi sa fermarsi: in questa fase conta più capire che agire e una pausa accettata vale più di un gesto fatto per sentirti in movimento.
- 3: Una sospensione avvolge la faccenda che hai in mano: niente si conclude per ora, ma proprio questa pausa te la fa vedere da un lato che prima ti sfuggiva.

### capovolta

- 1: Sulla tua domanda grava un'attesa che non insegna più nulla: si continua a rinunciare in nome di qualcosa di nobile, ma quel sacrificio non serve a nessuno.
- 2: Il clima della tua questione è immobile: la pausa ha smesso di portare frutti, eppure viene ancora chiamata pazienza, mentre somiglia sempre di più a uno stallo.
- 3: Ciò che domina la faccenda è una rinuncia senza destinatario: chiediti a chi serve davvero il tuo sacrificio, perché se non serve a nessuno è solo un modo per non muoverti.

## La Morte

### dritta

- 1: Sulla tua domanda agisce adesso una chiusura necessaria: ciò che ha esaurito il suo tempo lascia il campo e ciò che deve nascere trova finalmente spazio libero.
- 2: Il clima della tua questione è quello di un cambio di stagione: le cose arrivate alla fine contano ogni giorno meno, mentre ciò che comincia conta ogni giorno di più.
- 3: Ciò che domina la tua faccenda è un taglio netto: quello che è finito viene tolto di mezzo senza chiedere il permesso, non per distruggere ma per fare posto.

### capovolta

- 1: Sulla tua domanda grava una tensione fra due forze: da una parte il cambiamento che va avanti comunque, dall'altra una stretta che non vuole aprirsi su ciò che è finito.
- 2: Nella tua questione c'è l'aria ferma di una stanza chiusa mentre fuori la stagione cambia: dentro tutto resta come prima e il nuovo bussa senza poter entrare.
- 3: Ciò che domina la tua faccenda è la fatica di trattenere: il cambiamento è già in atto e ti consuma soprattutto la stretta su una cosa che ha finito il suo tempo.

## La Temperanza

### dritta

- 1: Sulla tua domanda agisce adesso la misura: le parti che sembravano inconciliabili si avvicinano piano e con calma, a patto che nessuna venga forzata o messa da parte.
- 2: Nella tua questione vale la regola della dose giusta: fare il doppio non porta il doppio e ciò che arriva fuori misura rovina l'equilibrio invece di rafforzarlo.
- 3: Ciò che domina la tua faccenda in questi giorni è la proporzione: conta di più la piccola correzione fatta al momento giusto che il grande sforzo fatto tutto insieme.

### capovolta

- 1: Sulla tua domanda agisce uno scambio a senso unico: una parte dà tutto e l'altra non restituisce niente, così le due esigenze stanno vicine senza riuscire ad accordarsi.
- 2: Nella tua questione il tono salta da un estremo all'altro, prima tutto insieme e poi niente: fra uno scatto e l'altro la misura si perde e la cosa procede a strappi.
- 3: Ciò che domina la tua faccenda è la fretta: le arriva tutto in una volta, mentre per comporsi avrebbe bisogno di un ritmo lento e di dosi piccole.

## Il Diavolo

### dritta

- 1: Sulla tua domanda agisce un patto non detto: ciò che dà piacere subito passa davanti a tutto, mentre il prezzo viene rimandato o non viene mai nominato.
- 2: Nella tua questione conta soprattutto l'intensità in questo periodo: vale molto ciò che accende subito il desiderio e quasi niente ciò che chiede tempo, pazienza o rinuncia.
- 3: Ciò che domina la tua faccenda è un legame che non riconosci come tale, perché è intrecciato a qualcosa che desideri: la presa si stringe proprio nei momenti di piacere.

### capovolta

- 1: Sulla tua domanda cambia il tono: ciò che si diceva a mezza bocca adesso viene chiamato per nome e un patto, una volta nominato, comanda molto meno di prima.
- 2: Nella tua questione l'aria si fa più libera: il segreto di cui quel legame aveva bisogno si dirada e ciò che desideri resta desiderabile senza più dettare le condizioni.
- 3: Ciò che domina la tua faccenda è il bisogno di chiarezza, non di rinuncia: serve vedere il patto per intero, con il suo prezzo scritto accanto a ciò che vale la pena volere.

## La Torre

### dritta

- 1: Sulla tua domanda agisce adesso una regola severa: ciò che era costruito senza fondamenta crolla di colpo, mentre ciò che ha basi vere resta in piedi.
- 2: Nella tua questione arriva un colpo secco che interrompe tutto a metà: non è il momento dei lunghi discorsi, ma di una verità che entra in un istante.
- 3: Ciò che domina la tua faccenda è la richiesta di basi vere: niente può reggere solo per apparenza e ciò che non ha fondamento si rivela nel momento in cui cede.

### capovolta

- 1: Sulla tua domanda agisce l'apparenza: una facciata senza segni conta più di una crepa dichiarata, mentre la crepa continua il suo lavoro senza che nessuno la nomini.
- 2: Nella tua questione c'è un'aria sospesa, come un temporale che non scoppia: la tensione resta tutta dentro e il momento del chiarimento slitta di giorno in giorno.
- 3: Ciò che domina la tua faccenda è lo sguardo che si ferma alla superficie: si vede ciò che è stato rifinito, non il punto in cui le cose stanno cedendo.

## La Stella

### dritta

- 1: Sulla tua domanda scende una chiarezza calma, che arriva da lontano: non risolve tutto, ma rende visibili i contorni di ciò che prima restava nel buio.
- 2: Nella tua questione si respira l'aria limpida che viene dopo un temporale: la tensione cala, le cose tornano nitide e affrontarle costa meno fatica di prima.
- 3: Ciò che domina la tua faccenda è una fiducia quieta, senza grida né entusiasmi: un sostegno costante e discreto che mantiene viva la speranza giorno dopo giorno.

### capovolta

- 1: Sulla tua domanda si stende un velo: la fonte di speranza resta accesa, ma ciò che arriva fino a te è un chiarore debole, senza una direzione precisa.
- 2: Nella tua questione la fiducia scorre più sottile del solito: non si interrompe, ma arriva appena quanto basta per andare avanti, senza dare vero slancio.
- 3: Ciò che domina la tua faccenda è il risparmio: l'ispirazione arriva a piccoli sorsi e ciò che chiederebbe uno slancio pieno si accontenta di meno.

## La Luna

### dritta

- 1: Sulla tua domanda sta una luce notturna che sbaglia le misure: quello che accende lo mostra più grande del vero; quello che lascia in ombra sembra non esistere affatto.
- 2: Dentro la tua domanda salgono vecchie paure insieme a impressioni nuove senza nome, mescolate così bene che non riesci a distinguere quali vengono dai fatti e quali dal timore.
- 3: Vale adesso sulla tua domanda una regola semplice: avanza chi procede con cautela e intuito, mentre chi pretende di vedere tutto chiaro prima di muoversi resta fermo.

### capovolta

- 1: Sulla tua domanda tornano le proporzioni giuste: quello che nella confusione sembrava decisivo riprende la sua misura reale e le altre cose tornano a contare per quello che valgono.
- 2: Una luce che sale sta misurando a una a una le sagome dentro la tua domanda e restituisce a ciascuna la dimensione vera: l'enorme diventa piccolo, il minaccioso diventa un contorno.
- 3: Intorno alla tua domanda i toni si calmano: quello che prima veniva detto con ansia ora si può dire con calma e le parole tornano a descrivere le cose per come sono.

## Il Sole

### dritta

- 1: A mezzogiorno pieno la tua domanda si vede in ogni sua parte: il chiarore arriva dall'alto, cade dentro gli angoli e lascia fuori le zone grigie. Quello che c'è risulta per quello che è.
- 2: Una corrente calda passa dentro la tua domanda e fa fiorire quanto tocca: le cose si aprono verso l'alto, come un campo a stagione piena. Il calore viene da fuori e scalda tutta la faccenda.
- 3: Sulla tua domanda vale una regola chiara: cresce ciò che mostri apertamente, mentre ciò che tieni nascosto non trova spazio. Qui la trasparenza è la condizione di tutto.

### capovolta

- 1: Sulla tua domanda conta quanto senti, non quanto c'è: le cose buone sono tutte presenti ma ti arrivano filtrate, così una situazione piena ti sembra valere la metà.
- 2: Lavora sulla tua domanda una nube sottile che non spegne la luce ma la separa dalla pelle: il bagliore resta intatto sopra la faccenda e quello che manca è il passaggio del tepore.
- 3: La tua domanda suona in sordina: la situazione è serena ma la vivi col volume abbassato. La gioia c'è sulla carta, non ancora in quello che provi.

## Il Giudizio

### dritta

- 1: Una luce di richiamo passa su tutta la tua faccenda in una volta e non lascia angoli al buio: ciò che stava sotto coperta si alza visibile, chiamato per nome con il resto.
- 2: Uno squillo attraversa questa tua faccenda e fa l'appello: chiama in piedi quello che la riguarda, dal primo pezzo all'ultimo; la risposta la pretende nello stesso momento in cui chiama.
- 3: Sopra questo c'è l'aria di una resa dei conti generale: tutta la tua faccenda viene contata nella stessa ora, i pezzi vecchi insieme a quelli nuovi; il richiamo non distingue fra loro.

### capovolta

- 1: La regola non detta nella tua faccenda rinvia ogni risposta al momento impeccabile che non si presenta; al posto dell'appello lavora una severità che condanna prima di ascoltare.
- 2: Il valore della tua faccenda si calcola per difetto: ogni pezzo pesa per ciò che gli manca. Con questo metro il bilancio esce più basso del vero e il richiamo passa inascoltato.
- 3: Dentro questa tua faccenda il registro è quello di un'accusa senza difesa: la misura della colpa sale a ogni frase, mentre lo squillo che chiama resta fuori dal discorso.

## Il Mondo

### dritta

- 1: Una luce circolare gira sulla tua questione e la mostra per intero: ogni pezzo del giro si vede insieme agli altri, compresi quelli che da vicino sembrano estranei.
- 2: Gira in tondo la corrente che muove la tua questione: passa sul punto di partenza e lo riconosce, mentre ogni tratto percorso entra nel cerchio alla pari con gli altri.
- 3: Vale adesso una regola di interezza: dentro la tua questione trova strada quello che si lascia comporre col resto, mentre il pezzo tenuto da parte non trova dove stare.

### capovolta

- 1: Il valore, dentro la tua questione, si decide su un pezzo piccolo: quello che combacia conta poco adesso, mentre il solo segmento che non entra al suo posto si prende l'attenzione intera.
- 2: Questa forza insiste sul punto in cui due parti della tua questione non combaciano ancora, mentre il resto, già sistemato, non le interessa più.
- 3: Ha il tono di una cosa sospesa su un dettaglio: dentro la tua questione tutto suona compiuto tranne una nota; quella sola nota decide come si sente il resto.

## Asso di Bastoni

### dritta

- 1: Un calore ancora senza forma sta accendendo il primo punto della tua questione: non dispone mezzi né traccia rotte, scalda il principio e basta; tutto il resto viene dopo di lui.
- 2: Questa spinta funziona dove la tua domanda è ancora aperta e senza forma: ha bisogno di qualcosa di nuovo da avviare, mentre su ciò che è già deciso non trova presa.
- 3: Attraversa la tua domanda una spinta verticale e corta, del tipo che parte prima di sapere dove va: la direzione conta meno dell'accendersi; il movimento nasce in questo istante.

### capovolta

- 1: Sulla tua questione suona un registro sordo, quello del fiammifero che striscia più volte senza prendere: la materia da accendere c'è tutta, mentre il crepitio della fiamma manca.
- 2: La luce sulla tua questione non raggiunge il punto di partenza: si vede bene quello che è già in piedi, mentre il principio nuovo resta in una zona dove nessun chiarore entra.
- 3: Dentro la tua questione trova strada soltanto quello che è già avviato: ogni principio nuovo paga un dazio di esitazione prima di muoversi, mentre il calore resta chiuso là dentro.

## Due di Bastoni

### dritta

- 1: Cade sulla cosa che hai in mano uno sguardo che arriva fino al bordo della mappa: quello che sta dentro il recinto conosciuto si vede piccolo, quello che sta oltre prende rilievo.
- 2: Questa spinta vuole dalla tua domanda una rotta dichiarata prima di ogni passo: ammette i piani larghi e non ammette che la cosa resti dove sta senza un nome di destinazione.
- 3: Dentro la tua faccenda conta la distanza: una misura corta vale niente, mentre quello che guarda lontano prende subito prezzo, anche se è appena disegnato a matita.

### capovolta

- 1: In questa faccenda vale una regola non detta: finché nessuna rotta viene nominata, tutte restano disegnabili sul foglio, così la tua domanda conserva ogni direzione e nessuna.
- 2: Sulla tua faccenda c'è un'aria di attesa: tutto è predisposto per partire, eppure non ti muovi mentre guardi un orizzonte a cui nessuno dà un nome.
- 3: Questa spinta mantiene la tua faccenda affacciata sul bordo: le apre la mappa davanti, non le mette il dito sopra nessuna strada e lascia il globo a mezz'aria.

## Tre di Bastoni

### dritta

- 1: Il cuore della tua questione è un'attesa fiduciosa: hai già fatto la tua parte e ciò che hai avviato sta lavorando lontano da te, verso un risultato che si avvicina.
- 2: Adesso la situazione dipende meno dalle tue mani e più dal tempo: quello che conta è già partito e chiede soltanto di essere seguito con pazienza e sguardo lungo.
- 3: Su tutta la tua domanda domina un clima di espansione: le iniziative che hai lanciato si allargano oltre il tuo raggio e tornano indietro con i loro tempi, non con i tuoi.

### capovolta

- 1: Ciò che domina la tua questione è un ritorno diverso dall'attesa: qualcosa che avevi avviato rientra, ma con un contenuto che non corrisponde a quello che immaginavi.
- 2: Adesso conta ciò che è arrivato davvero, non ciò che avevi previsto: la tua domanda si decide guardando il risultato concreto invece del piano scritto all'inizio.
- 3: Sulla situazione pesa il confronto fra attese e realtà: la risposta è arrivata e va valutata per quello che contiene, non per la distanza dal tuo progetto iniziale.

## Quattro di Bastoni

### dritta

- 1: Il cuore della tua questione è una stabilità raggiunta: ciò che hai costruito regge e il momento chiede di riconoscerlo e di festeggiarlo con chi ti sta vicino.
- 2: Su tutta la situazione domina un clima sereno, di festa condivisa: le fondamenta tengono e ti viene chiesto di godere del risultato prima di pensare al prossimo.
- 3: Adesso conta riconoscere ciò che c'è: una base solida, un obiettivo raggiunto, persone con cui condividerlo, invece di guardare subito a quanto ti resta da fare.

### capovolta

- 1: Il cuore della tua questione è una festa rimandata: il risultato c'è ed è completo, ma continui a non concederti il momento per riconoscerlo e viverlo davvero.
- 2: Su tutta la situazione domina l'abitudine di passare subito al compito successivo: ciò che hai raggiunto resta in sospeso e la soddisfazione non arriva mai del tutto.
- 3: Adesso tutto sembra pronto tranne il momento di celebrarlo: come una casa nuova in cui non hai ancora messo piede, ciò che hai costruito aspetta che tu lo abiti.

## Cinque di Bastoni

### dritta

- 1: Il cuore della tua questione è un confronto acceso: posizioni diverse si scontrano con la stessa forza e nessuna prevale, ma proprio questo ti costringe a chiarire le tue ragioni.
- 2: Su tutta la situazione domina un clima di competizione vivace: ognuno vuole dire la sua e il confronto, se resta leale, ti aiuta a capire quanto valgono le tue idee.
- 3: Adesso tutte le parti in gioco chiedono spazio nello stesso momento: è una gara fra pari, rumorosa ma senza cattiveria, in cui ti misuri e cresci.

### capovolta

- 1: Il cuore della tua questione è un attrito che stanca: tante piccole tensioni ti consumano energia, mentre il conflitto che conta davvero resta coperto e non viene mai affrontato.
- 2: Su tutta la situazione domina una confusione di polemiche minori: le questioni importanti e quelle inutili sembrano uguali e tu fatichi a distinguerle.
- 3: Adesso nessun fronte viene chiuso, nemmeno quelli che non contano più: la contesa si alimenta da sola e ti toglie forze senza portarti da nessuna parte.

## Sei di Bastoni

### dritta

- 1: Il cuore della tua questione è un riconoscimento meritato: ciò che hai fatto esce dall'ombra e viene visto e apprezzato apertamente da chi ti sta intorno.
- 2: Su tutta la situazione domina un clima di stima pubblica: il tuo valore non resta più sottinteso, qualcuno lo dice apertamente davanti agli altri nella misura giusta rispetto al lavoro fatto.
- 3: Adesso conta che ciò che hai costruito stia sotto gli occhi di tutti: il merito si compie nel momento in cui qualcuno lo nomina e lo onora.

### capovolta

- 1: Il cuore della tua questione è un merito che nessuno nomina: hai fatto la tua parte, ma il riconoscimento tarda e nel silenzio nasce il dubbio su quanto vali.
- 2: Su tutta la situazione domina l'idea che valga soltanto ciò che gli altri dichiarano: il tuo contributo resta intero, ma senza nessuno che lo confermi.
- 3: Adesso il giudizio sul tuo valore sembra dipendere da fuori: ciò che hai fatto è buono per conto suo, ma senza un testimone ti pare che non conti.

## Sette di Bastoni

### dritta

- 1: Il cuore della tua questione è una posizione da difendere: hai qualcosa che vale, altri lo contestano o lo vogliono: il vantaggio resta comunque dalla tua parte.
- 2: Su tutta la situazione domina una pressione che arriva da più lati: richieste, critiche, obiezioni. Tu però parti da una posizione più solida di chi ti contesta.
- 3: Adesso conta tenere il punto: chi spinge contro di te è più numeroso ma non più forte, ciò che dici con calma pesa più di ciò che altri gridano.

### capovolta

- 1: Il cuore della tua questione è una difesa allargata a troppi fronti: tieni la guardia su ogni lato, anche dove nessuno si avvicina, così le forze si disperdono.
- 2: Su tutta la situazione domina la sensazione di essere sotto attacco: ogni richiesta ti sembra una minaccia e anche chi arriva con buone intenzioni trova la porta chiusa.
- 3: Adesso il tuo sforzo è distribuito in parti uguali su ogni lato, sia dove la pressione è reale sia dove non succede niente: così l'energia si esaurisce in fretta.

## Otto di Bastoni

### dritta

- 1: Il cuore della tua questione è un'accelerazione: molte cose si muovono insieme e in fretta, notizie e risposte si susseguono e il tempo per pensare si accorcia.
- 2: Su tutta la situazione domina un ritmo rapido che non ammette rinvii: ciò che parte subito trova spazio, ciò che aspetti di decidere rischia di restare indietro.
- 3: Adesso tutto parla in fretta: messaggi, chiamate, occasioni che arrivano insieme. La tua domanda non concede lunghe pause e ti chiede prontezza.

### capovolta

- 1: Il cuore della tua questione è un ritmo scomposto: le cose corrono ancora, ma ognuna per conto suo, così ciò che dovrebbe arrivare insieme arriva a pezzi.
- 2: Su tutta la situazione domina una fretta disordinata: ogni cosa si muove veloce, ma nessuna rispetta il suo turno e l'ordine ti sfugge.
- 3: Adesso la tua faccenda somiglia a un ingorgo: tutto spinge insieme verso la stessa uscita e più aumenta la fretta, più ti blocchi.

## Nove di Bastoni

### dritta

- 1: Sulla tua domanda agisce una stanchezza accumulata nel tempo, ma insieme c'è la vicinanza della fine: le forze calano proprio mentre manca sempre meno.
- 2: Il clima della tua questione è quello di chi ha resistito a lungo: poche energie, molta determinazione e la sensazione di aver già dato quasi tutto.
- 3: Questa forza ti chiede di reggere ancora un poco: la tua domanda è vicina a una conclusione, ma la fatica accumulata rende pesante anche l'ultimo sforzo.

### capovolta

- 1: Sulla tua domanda agisce una forza che chiede prove a chiunque si avvicini: anche una mano tesa viene esaminata come una minaccia, perché comandano le ferite di prima.
- 2: Vecchie cicatrici colorano il clima della tua questione: chiunque entri viene visto come un possibile nemico e si nota l'arma, mai la mano che bussa.
- 3: Dentro la tua domanda passa una corrente che viene dai colpi di ieri e ricade su chi si fa avanti oggi: il passato dà il suo colore a ogni arrivo nuovo.

## Dieci di Bastoni

### dritta

- 1: Una forza che accumula lavora sulla tua domanda: aggiunge un impegno alla volta sulle stesse spalle, finché la fatica diventa il tono di ogni giornata.
- 2: Respiro corto e giornate piene: il clima della tua questione è quello di chi porta troppo e non trova spazio per guardare più avanti.
- 3: Ogni parte della faccenda chiede di essere portata da te: sulla tua domanda pesa il numero delle cose da reggere più di ciascuna presa da sola.

### capovolta

- 1: La forza in azione esige una cernita dentro la tua domanda: pretende che ogni fascio dichiari il proprietario, perché buona parte di quanto viaggia sulle tue spalle ha un altro nome scritto sopra.
- 2: Questa forza mostra con chiarezza, dentro quello che chiedi, quali pesi sono di altri e viaggiano con te solo per abitudine: il tuo carico vero è più piccolo di quanto sembrava.
- 3: Sulla tua domanda grava una pressione che non è tutta tua: buona parte del carico arriva da fuori per consuetudine e il senso del dovere te lo tiene addosso.

## Fante di Bastoni

### dritta

- 1: Il valore dentro questa tua faccenda lo decide la novità: quello che si guarda per la prima volta vale molto, quello che si conosce già perde prezzo in fretta, anche quando è solido.
- 2: Sulla tua domanda agisce l'entusiasmo di chi ha appena scoperto qualcosa: si parla in fretta e la voglia di raccontare arriva prima della verifica.
- 3: Una curiosità giovane muove la tua domanda: va a vedere, torna a raccontare, riparte verso la novità successiva senza seguire un piano preciso.

### capovolta

- 1: Sulla tua domanda agisce un interesse che cerca sempre un obiettivo nuovo: non manca l'entusiasmo, manca la costanza di restare sulla stessa cosa abbastanza a lungo.
- 2: Questa forza accende e sposta: appena una parte della tua faccenda prende calore, l'attenzione passa subito alla successiva, così nessuna riceve la cura che servirebbe.
- 3: Il clima della tua questione è quello di un primo giorno che si ripete: tutto sa di avvio, niente arriva al momento in cui si continua e si costruisce.

## Cavaliere di Bastoni

### dritta

- 1: Mette in sella la tua questione e la lancia al galoppo verso la cosa che vuole: questa forza scalda il corpo prima di consultare la testa, poi parte senza chiedere il permesso.
- 2: Sulla tua questione agisce un'impazienza calda, come quella di chi è già partito da un pezzo: tutto suona urgente e il desiderio corre più veloce del calcolo.
- 3: Il clima della tua questione è quello di una partenza imminente: il desiderio fa da sprone al posto del ragionamento e la voglia di muoverti è più forte di ogni dubbio.

### capovolta

- 1: Sulla tua questione agisce una spinta che chiede soltanto di correre: accetta qualunque direzione, anche tutte insieme, purché ci si muova subito e senza pause.
- 2: Nella luce di questa corsa si vedono bene gli scatti e male i confini: la tua questione mostra tutta l'energia disponibile, mentre il punto verso cui si spende resta illeggibile.
- 3: Il clima della tua questione procede a strappi: ogni iniziativa parte forte e cambia verso prima di arrivare, così l'energia si consuma tutta durante il tragitto.

## Regina di Bastoni

### dritta

- 1: Sulla tua questione agisce un calore che viene da una presenza precisa: scalda chi si avvicina, mentre chi resta lontano lo vede senza riceverne.
- 2: Dentro la tua questione prende valore la presenza intera di chi parla: una parola detta senza riserve conta più di una dimostrazione impeccabile, mentre la tiepidezza non conta niente.
- 3: Il clima della tua domanda è sicuro e caldo, senza bisogno di alzare il tono: chi ascolta si avvicina da sé, attirato dalla calma più che dalla forza.

### capovolta

- 1: Una corrente verso l'esterno attraversa la tua domanda: lo sguardo corre a un altro fuoco per vedere quanto scalda, mentre il centro da cui partiva il calore resta senza nessuno che lo guardi.
- 2: Sulla tua questione agisce un confronto in corso: due persone vengono messe una accanto all'altra e la stima si sposta dall'una all'altra, mentre il tuo valore resta lo stesso.
- 3: Il clima della tua domanda è fatto di paragoni: ogni qualità viene misurata accanto a quella di un altro prima di valere qualcosa, così il tuo valore lo vedi solo di riflesso.

## Re di Bastoni

### dritta

- 1: Sulla tua domanda lavora un comando adulto: apre il varco per primo, lo lascia aperto dietro di sé, poi permette alla cosa di percorrerlo con le proprie gambe.
- 2: Questa autorità pretende che la tua faccenda abbia qualcuno che ne risponde: ammette decisioni prese apertamente, non che le cose vadano avanti senza una guida.
- 3: Il clima della tua domanda è generoso e maturo: chi guida conosce il mestiere e indica una direzione sola con calma e senza imporsi a nessuno.

### capovolta

- 1: Un'aria di ordine impartito riempie la tua faccenda: dentro la cosa che chiedi si parla in una direzione sola, dall'alto verso il basso; il ritorno non viene raccolto da nessuno.
- 2: In questa situazione decide uno solo: ciò che viene stabilito vale subito e la tua domanda non prevede un secondo momento di confronto prima di andare avanti.
- 3: Questa autorità decide in solitudine dentro la tua domanda: sceglie in fretta, impartisce, passa alla cosa seguente senza fermarsi a sentire l'effetto della prima.

## Asso di Coppe

### dritta

- 1: Al cuore della tua domanda c'è un sentimento nuovo che nasce spontaneamente: qui conta ciò che lasci arrivare, non ciò che calcoli prima di aprirti.
- 2: Sulla tua questione prevale un clima di apertura e di dolcezza: ciò che senti è più grande di quanto riesci a contenere e cerca di uscire.
- 3: Questa situazione ti chiede di accogliere un'emozione sincera senza difenderti: il valore sta in ciò che lasci scorrere verso gli altri, non in ciò che trattieni.

### capovolta

- 1: Al cuore della tua domanda c'è un sentimento che provi davvero e tieni chiuso dentro: la forza c'è tutta, ma sei tu a non lasciarla uscire.
- 2: Sulla tua questione pesa un'aria trattenuta, come prima di un temporale che non scoppia: le emozioni ci sono ma nessuno le dice, a cominciare da te.
- 3: Questa situazione chiede uno sbocco a ciò che senti e lo trova chiuso dall'interno: è la paura di soffrire a impedirti di aprire davvero il cuore.

## Due di Coppe

### dritta

- 1: Al cuore della tua domanda c'è uno scambio alla pari: va avanti ciò che viene dato e ricevuto da entrambe le parti, non ciò che una sola decide.
- 2: Sulla tua questione prevale la reciprocità: conta ciò che viene riconosciuto da tutte e due le parti, mentre quello che afferma una parte soltanto vale poco.
- 3: Questa situazione ti mette davanti a un riconoscimento reciproco: tu e l'altra parte vi scegliete alla pari, così nasce un patto che dà forza a tutte e due.

### capovolta

- 1: Al cuore della tua domanda c'è un malinteso: il legame regge come prima, ma le parole arrivano storte e ciascuno capisce una cosa diversa da quella detta.
- 2: Sulla tua questione si è raffreddato il clima fra due parti: la stima sotto resta intera, mentre fra ciò che si dice e ciò che si intende passa un equivoco.
- 3: Questa situazione chiede ascolto da entrambi i lati: il problema non è il sentimento, è la distanza fra quello che tu intendi e quello che l'altra parte sente.

## Tre di Coppe

### dritta

- 1: Al cuore della tua domanda c'è una gioia da condividere: ciò che fai insieme agli altri prende forza, mentre ciò che tieni per te resta piccolo.
- 2: Sulla tua questione prevale un clima di festa e di amicizia: quello che passa di mano in mano cresce, perché la contentezza divisa con altri raddoppia.
- 3: Questa situazione ti invita a contare sulle persone vicine: qui vale più con chi festeggi che il motivo della festa, perché il sostegno reciproco fa la differenza.

### capovolta

- 1: Al cuore della tua domanda c'è una compagnia rumorosa ma poco profonda: le occasioni sociali sono molte, mentre i legami che ti sostengono davvero ricevono poca cura.
- 2: Sulla tua questione gira molta gente ma resta poca sostanza: la tua attenzione si disperde su tante presenze e finisce per non scaldare davvero nessuna di loro.
- 3: Questa situazione ti chiede di scegliere la qualità dei legami invece del numero: applausi e cerchi larghi riempiono le giornate, ma ti lasciano ben poco nutrimento.

## Quattro di Coppe

### dritta

- 1: Al cuore della tua domanda c'è una sazietà che spegne l'interesse: ti sembra di avere già abbastanza, così quello che ti viene offerto passa accanto senza che tu lo guardi.
- 2: Sulla tua questione prevale la noia: conta solo ciò che desideri già, mentre una proposta buona, se non trova appetito, sembra non valere niente per te.
- 3: Questa situazione ti chiede di ritrovare la curiosità: le occasioni continuano ad arrivare, ma il punto è la tua voglia di guardarle, che adesso si è spenta.

### capovolta

- 1: Al cuore della tua domanda c'è una curiosità che si riaccende: dove tutto sembrava piatto tornano interesse e voglia di fare, mentre il torpore perde forza.
- 2: Sulla tua questione l'aria torna a muoversi: ciò che ti stava accanto senza che lo notassi entra finalmente nel tuo campo visivo e comincia a interessarti.
- 3: Questa situazione ti chiede di riaprire l'appetito più che di cercare cose nuove: ciò che ti viene offerto è già lì e aspetta solo il tuo sguardo.

## Cinque di Coppe

### dritta

- 1: Al cuore della tua domanda c'è una perdita che occupa tutta l'attenzione: conti ciò che è andato perduto, mentre ciò che è rimasto in piedi non trova spazio.
- 2: Sulla tua questione prevale un tono basso di rimpianto: non un dolore acuto, ma uno sguardo rivolto indietro che colora ogni cosa che accade adesso.
- 3: Questa situazione ti chiede di dare un nome preciso a ciò che hai perso prima di ogni altra cosa: il dolore è vero e va riconosciuto, senza consolazioni affrettate.

### capovolta

- 1: Al cuore della tua domanda c'è un'attenzione che si sposta: ciò che hai perso conserva il suo valore, ma ciò che è rimasto comincia a contare altrettanto.
- 2: Sulla tua questione si respira l'aria che viene dopo la pioggia: la tristezza non è sparita del tutto, però il respiro torna lungo e regolare.
- 3: Questa situazione ti porta a voltarti verso ciò che non hai perso: le risorse rimaste tornano visibili, mentre il dolore passato smette di occupare tutto lo spazio.

## Sei di Coppe

### dritta

- 1: Al cuore della tua domanda c'è un calore antico, quello delle prime amicizie: qui si dà senza contare e la gentilezza non viene scambiata per ingenuità.
- 2: Sulla tua questione prevale un tono semplice e affettuoso: gesti piccoli, parole sincere, la generosità di chi offre qualcosa senza chiedere quanto valga.
- 3: Questa situazione ti chiede di dare valore all'affetto gratuito: conta ciò che qualcuno offre senza secondi fini, mentre il calcolo di quanto spetta a ciascuno resta fuori.

### capovolta

- 1: Al cuore della tua domanda c'è un richiamo verso il passato: ogni scelta tende a guardare indietro, a una stagione dolce che ti sembra migliore di adesso.
- 2: Sulla tua questione il passato si vede nitido e il presente resta velato: i ricordi di un tempo lontano occupano più posto di ciò che accade oggi.
- 3: Questa situazione ti mette davanti a una nostalgia che vuole tutto come allora: accetti ciò che ha il sapore di un tempo e rifiuti le soluzioni nuove, anche quando sarebbero migliori.

## Sette di Coppe

### dritta

- 1: Al cuore della tua domanda ci sono molte possibilità che brillano tutte allo stesso modo: nessuna ha ancora mostrato che cosa contiene davvero, così rischi di scegliere per l'apparenza.
- 2: Sulla tua questione domina la fantasia: appena un'ipotesi prende forma ne compare un'altra più attraente, così le promesse si moltiplicano senza che nessuna venga messa alla prova.
- 3: Questa situazione premia ciò che si mostra bene più di ciò che vale: le offerte ti sembrano tutte buone finché non le apri una per una per vedere che cosa c'è dentro.

### capovolta

- 1: Al cuore della tua domanda c'è una scelta: fra molte possibilità ne riconosci una come tua, mentre le altre perdono valore senza rumore e smettono di distrarti.
- 2: Sulla tua questione domina la chiarezza: metti a fuoco ciò che vuoi davvero e accetti che rinunciare al resto sia il prezzo di questa nitidezza.
- 3: Questa situazione ha smesso di fare elenchi di possibilità: ti parla con la sobrietà di chi ha scelto, con una cosa sola chiamata per nome e il resto lasciato da parte.

## Otto di Coppe

### dritta

- 1: Al cuore della tua domanda c'è il bisogno di andare oltre: ciò che hai intorno è ancora in ordine ma non ti nutre più e il tuo sguardo è già rivolto altrove.
- 2: Sulla tua questione domina una spinta lenta e silenziosa verso l'uscita: ti allontana da ciò che non ti dà più senso, senza litigi, perché il cuore conosce la direzione prima della testa.
- 3: Questa situazione ti mostra una regola semplice: va avanti ciò che porta verso un senso più vero, mentre perde forza ciò che pretende spiegazioni o giustificazioni per restare.

### capovolta

- 1: Al cuore della tua domanda c'è un equilibrio fermo: ciò che ti chiama fuori vale quanto ciò che ti trattiene, così la decisione resta aperta e tu non ti muovi.
- 2: Sulla tua questione domina l'esitazione: apri una possibilità di andare e subito la richiudi, restando a metà fra ciò che conosci e ciò che ti attira.
- 3: Questa situazione ha il tono di un addio che hai pensato molte volte senza mai dirlo: le parole sono pronte da tempo, ma la decisione non arriva.

## Nove di Coppe

### dritta

- 1: Al cuore della tua domanda c'è un appagamento reale: ciò che desideravi è qui davanti a te e per ora nulla manca, quindi puoi goderlo senza bisogno di giustificarti.
- 2: Sulla tua questione domina una contentezza piena: non chiede altro e non promette altro, ti fa godere ciò che hai ottenuto con la serenità di chi sa apprezzarlo.
- 3: Questa situazione mette in risalto ciò che hai e non ciò che manca: come quando guardi i risultati raggiunti messi in fila e ne riconosci il valore.

### capovolta

- 1: Al cuore della tua domanda c'è una preferenza per ciò che piace subito: i piaceri rapidi trovano spazio, mentre ciò che ti nutre davvero resta in disparte.
- 2: Sulla tua questione domina la misura dell'istante: una cosa sembra valere quanto ti piace nel momento in cui la ottieni, mentre ciò che darebbe di più non entra nel conto.
- 3: Questa situazione ti somiglia a un brindisi ripetuto senza motivo: riempie la superficie di allegria, ma sotto manca la sostanza e va rinnovato di continuo.

## Dieci di Coppe

### dritta

- 1: Al cuore della tua domanda c'è ciò che si vive insieme: in primo piano stanno gli affetti che condividi, mentre ciò che riguarda una persona sola passa in secondo piano.
- 2: Sulla tua questione domina un affetto che rende solidali le persone coinvolte: ciò che tocca una tocca anche le altre, così il tuo bene diventa il bene di tutti.
- 3: Questa situazione ti chiede di sentirti parte di qualcosa: va avanti ciò che si può condividere con chi ti è vicino, mentre ciò che si gode in solitudine perde sapore.

### capovolta

- 1: Al cuore della tua domanda c'è una divisione: ciascuna delle persone coinvolte valuta il bene a modo suo, così nessuno trova più una misura comune con te o con gli altri.
- 2: Sulla tua questione domina una spinta che porta ciascuno in una direzione diversa: il tuo gruppo resta unito sulla carta, ma nei fatti ognuno va per conto suo.
- 3: Questa situazione ha il suono di discorsi fatti in disparte: intorno a te ciascuno dice la sua sottovoce e quei discorsi, messi insieme, non si incontrano mai.

## Fante di Coppe

### dritta

- 1: Al cuore della tua domanda c'è qualcosa di nuovo e delicato che sta emergendo: non riempie ancora tutto lo spazio, ma porta una presenza viva che ti chiede attenzione.
- 2: Sulla tua questione domina una sensibilità giovane che chiede tempo: prima di diventare una proposta ha bisogno di crescere e non va giudicata come se fosse già matura.
- 3: Questa situazione ti porta qualcosa che sale dal profondo verso la superficie, piano: un'emozione si fa avanti con la timidezza delle cose appena nate e cerca il modo di farsi vedere.

### capovolta

- 1: Al cuore della tua domanda c'è una sensibilità che si incrina al primo urto: la tua emozione è sincera, ma non ha ancora l'esperienza per reggere senza ferirsi.
- 2: Sulla tua questione domina un modo di vedere che ingrandisce ogni offesa: un gesto distratto ti sembra enorme, perché manca l'esperienza per dargli la giusta misura.
- 3: Questa situazione segue una regola di ritiro: ciò che mostri rischia di essere colpito, così ogni tuo gesto di apertura si ferma a metà e il cuore resta chiuso.

## Cavaliere di Coppe

### dritta

- 1: Al cuore della tua domanda c'è una gentilezza in movimento: la questione viene trattata con calma e garbo, come chi porge qualcosa senza fretta di sapere la risposta.
- 2: Sulla tua questione domina un tono di offerta più che di pretesa: le cose si chiedono con grazia e si porgono con cura, come chi tende una coppa colma.
- 3: Questa situazione ti chiede di trattare le cose con riguardo: funziona il gesto fatto bene, la parola scelta, il tempo concesso; non funzionano i modi sbrigativi.

### capovolta

- 1: Al cuore della tua domanda c'è il bel parlare: ciò che viene dichiarato sembra bastare da solo e nessuno chiede che alle parole seguano i fatti.
- 2: Sulla tua questione domina la parola elegante: una frase ben costruita conta più del gesto che dovrebbe seguirla, mentre ciò che dura non riceve attenzione.
- 3: Questa situazione ti avvolge in un'aria piacevole ma inconsistente: tutto suona gentile, niente si concretizza e le promesse si moltiplicano senza lasciare traccia.

## Regina di Coppe

### dritta

- 1: Nella tua domanda circola un'aria di acqua ferma e profonda: quello che vi entra viene accolto prima di essere giudicato; il fondo si vede anche sotto la superficie.
- 2: Pretende che la cosa venga sentita prima di essere spiegata la forza che lavora sulla tua domanda: esige una ricezione lunga e non ammette letture rapide fatte dal bordo.
- 3: Una luce bassa e calda sta sulla tua domanda e illumina il fondo che sta sotto le parole. Si vede il movente; l'apparenza perde di nitidezza e passa in secondo piano.

### capovolta

- 1: Scorre dentro la tua domanda una corrente a senso unico: quello che gli altri sentono entra senza dogana e prende il posto di quello che apparteneva alla cosa stessa.
- 2: Vale dentro la tua domanda una regola senza confini: trova strada ogni stato che arriva da fuori, non ne trova quello che nasce dentro e vorrebbe un nome proprio.
- 3: Prende il proprio metro dal sentire degli altri il criterio attivo dentro la tua domanda. Vale quello che provano loro; il resto non viene nemmeno registrato nel conto.

## Re di Coppe

### dritta

- 1: Intorno alla tua domanda l'aria è quella di un porto col mare mosso fuori: dentro la rada il pelo dell'acqua sta liscio e la temperatura resta la stessa a ogni ora del giorno.
- 2: La forza in azione chiede un governo dei sentimenti che non li raffreddi: pretende acqua calda con una rotta e non acqua ghiacciata. Dentro la tua domanda la fermezza è una temperatura.
- 3: Una luce bassa e ferma sta sulla tua domanda, come quella di un faro che non cerca niente: mostra il fondale insieme alla superficie e dà alla profondità un contorno riconoscibile.

### capovolta

- 1: Dentro la tua domanda la corrente cambia con la marea del giorno: a condurre sono gli umori di chi dovrebbe dare calma e il governo maturo resta in cabina, lontano dal timone.
- 2: Vale sulla tua domanda una regola che premia l'onda: trova strada quanto si impone con lo sbalzo, mentre quanto chiede quiete aspetta. La maturità è presente in tutta la scena, in disparte.
- 3: Il criterio al lavoro dentro la tua domanda conta il turbamento come moneta: più un sentimento disturba, più viene ascoltato; perfino la calma viene offerta in cambio di qualcosa.

## Asso di Denari

### dritta

- 1: Dentro la tua domanda il movimento è uno e va verso il basso: un bene compatto si deposita come una moneta che cade nel palmo, intero, senza dividersi in rivoli.
- 2: Un'aria di terra pronta sta su questa tua faccenda: pesante, umida, senza frenesia. In quella temperatura una cosa materiale prende forma intera invece di restare un progetto detto.
- 3: Questa tua faccenda pretende adesso qualcosa di solido sotto: una base che si possa toccare, non un'intenzione dichiarata. Al posto di una cosa intera non accetta la promessa di quella cosa.

### capovolta

- 1: Una forza sbaglia il prezzo dentro la tua domanda: mette su una cosa concreta e a portata un cartellino più basso del suo, così la cosa resta dov'è pur essendo disponibile.
- 2: La luce su questa tua faccenda illumina il lontano e lascia in ombra il pezzo solido a portata di mano: guardato troppe volte, smette di farsi vedere e si confonde con lo sfondo.
- 3: Vale una regola non detta: ciò che è disponibile si considera già acquisito ed esce dal calcolo. Nella tua domanda il bene a portata vale niente e il lontano prende tutto il peso.

## Due di Denari

### dritta

- 1: Sulla tua questione tira un'aria da tendone leggero: niente si ferma per più di un istante; quello che vi sta dentro passa di mano prima di diventare peso.
- 2: Chiede movimento continuo alla tua questione: ammette due cose in volo insieme, ammette il cambio di mano; non ammette che una delle due si sieda a terra.
- 3: Nella luce di questa forza si vede il passaggio e non il punto d'arrivo: della tua questione risaltano le mani che si alternano, mentre quello che è fermo quasi scompare.

### capovolta

- 1: Si accavalla il movimento dentro la tua questione: ogni oggetto in volo ricade in mano quando un altro sta partendo, cosicché la cadenza si scompone da sé.
- 2: Dentro la tua questione comanda adesso una regola d'urgenza: passa davanti quello che sta cadendo in questo istante, mentre il resto, in alto, perde il suo turno.
- 3: Il criterio qui è la vicinanza al suolo: dentro la tua questione conta tanto l'oggetto più prossimo alla caduta e non conta niente quello che gira tranquillo sopra le teste.

## Tre di Denari

### dritta

- 1: Sulla tua questione tira un'aria da lavoro condotto in più mani: ciascun mestiere presente conosce il proprio compito, cosicché nessuna istruzione viene ripetuta due volte.
- 2: Una corrente a più rami attraversa la tua questione e converge sul medesimo punto: il disegno, la mano che lavora la pietra, la borsa che paga, arrivano insieme sopra la stessa opera.
- 3: Dentro la tua questione prende valore quello che una mano sa fare davvero: la prova del mestiere conta più della buona intenzione, mentre il titolo da solo non conta niente.

### capovolta

- 1: Questa forza pretende dalla tua questione che ogni parte abbia un nome e una mano assegnata: non ammette compiti dati per sottinteso; dove il nome manca la pretesa cade su tutti e su nessuno.
- 2: Ciascuno segue la propria idea dell'opera, per la regola non scritta che il momento impone alla tua questione: il doppio lavoro sullo stesso punto trova strada, la parte che nessuno ha preso no.
- 3: Uno scollamento sta separando le mani che lavorano alla tua opera: tira ciascuna verso una lettura diversa del disegno, cosicché due tagli puntano dove non si incontrano.

## Quattro di Denari

### dritta

- 1: Due braccia si chiudono attorno alla tua domanda: la spinta che lavora qui cinge quello che la faccenda possiede già e ne sorveglia i bordi uno per uno.
- 2: Prende valore nella tua questione quello che non esce: una somma custodita conta più di una scambiata, mentre il rischio non riceve nessuna considerazione.
- 3: Comanda qui una regola di conservazione: niente lascia il perimetro della tua faccenda senza un motivo serio; quello che è dentro resta dentro e il conto non si apre.

### capovolta

- 1: Un'aria serrata occupa la tua faccenda: le finestre della cosa che chiedi sono chiuse da dentro, il poco che circola gira sempre fra le stesse due mani.
- 2: Questa spinta irrigidisce quello che resta elastico dentro la tua domanda: salda insieme le parti, cementa le posizioni, rende faticoso spostare la cosa di un dito.
- 3: Il timbro della faccenda è quello di chi conta due volte la stessa somma: ogni parola dentro la tua questione gira attorno a quello che si possiede già.

## Cinque di Denari

### dritta

- 1: Una mancanza sta lavorando la tua domanda dal lato di fuori: le dà la postura di chi passa accanto a un vetro acceso, dove il calore si vede e non arriva addosso.
- 2: Il tono dentro la tua domanda è quello di chi sta fuori e non chiama: parole poche, passo lento, la luce vicinissima che non entra nel racconto di quello che accade.
- 3: Sa d'inverno sulla soglia l'aria dentro la tua domanda: freddo da un lato e tepore dall'altro, con in mezzo una porta che nessuna delle due parti attraversa.

### capovolta

- 1: Chiede una porta aperta e la trova aperta la forza che lavora sulla tua domanda: pretende il rientro di ciò che era fuori e non lascia la cosa sul gradino.
- 2: Cambia la luce sulla tua domanda: non viene più da un chiarore che sta fuori portata, ma dal lato dove la cosa si trova adesso, così il freddo perde i suoi contorni.
- 3: Passa dentro la tua domanda una corrente calda che attraversa la soglia nel verso del rientro: quello che mancava rifà la strada al contrario e il gradino smette di dividere.

## Sei di Denari

### dritta

- 1: Una forza di circolazione lavora sulla tua domanda: fa passare di mano quello che c'è, misura la parte di ciascuno con la bilancia alzata, poi rimette in giro quanto ha appena consegnato.
- 2: Suona dentro la tua domanda la nota di un dare fatto alla luce del giorno: timbro chiaro, mani visibili, la parte di ciascuno dichiarata davanti a tutti.
- 3: Sopra la tua domanda sta l'aria di una piazza dove qualcosa passa di mano: tiepida, di scambio alla pari, con la parte che oggi dà dalla medesima parte che poi riceve.

### capovolta

- 1: La forza al lavoro esige che lo scambio dichiari le due direzioni: dentro la tua domanda un piatto scende da solo e l'altro resta alto, mentre la generosità continua a versare.
- 2: Cade sulla tua domanda una luce di taglio che mostra il piatto pendente: si vede quanto esce in continuazione, mentre quanto rientra sta in una zona grigia dove non viene contato.
- 3: Dentro la tua domanda la corrente scorre in un verso soltanto: il dare va avanti a vuotarsi e il ritorno non entra nel giro. Il movimento è reale, il circolo no.

## Sette di Denari

### dritta

- 1: Il valore nella tua domanda si conta sul tempo che una cosa ha dentro, non su quello che mostra: un frutto verde pesa quanto le sue settimane. La fretta non entra nel prezzo.
- 2: Suona bassa la nota su questa faccenda: è il registro di chi sta appoggiato alla zappa e guarda, senza parlare al posto delle piante. Il discorso dentro la tua domanda procede a frasi lunghe.
- 3: Un'aria immobile sta sopra la tua domanda: senza vento e senza strappi, con le mani tirate indietro da quello che è già piantato. In quella calma la sosta compie il lavoro di un attrezzo.

### capovolta

- 1: Questa tua faccenda pretende una resa visibile e non concede alla pianta il suo termine: vuole vedere il frutto mentre si forma, poi mette sul ramo una scadenza non sua.
- 2: Una corrente nervosa passa dentro la tua domanda: le mani vanno e tornano sul ramo, saggiano, scostano le foglie, rimettono a posto. Il moto è continuo e non aggiunge niente alla pianta.
- 3: Dentro questa tua faccenda una forza tira la riga in anticipo: somma quello che è entrato, misura quello che esce e chiude un calcolo che il tempo non ha finito.

## Otto di Denari

### dritta

- 1: Incide a colpi piccoli, questa forza, sempre nello stesso punto della tua questione: rifinisce un dettaglio per volta e lascia il resto esattamente dove si trova.
- 2: Ha il suono regolare di un banco da lavoro: dentro la tua questione il tempo è scandito dal medesimo gesto ripetuto, senza alzate di tono né pause lunghe.
- 3: Sulla tua questione sta una quiete da bottega: poca luce sparsa, molta luce su un punto solo, l'odore del materiale che cede sotto l'utensile.

### capovolta

- 1: Pretende soltanto esecuzione dalla tua questione: ammette che il gesto sia esatto, ammette che il conto torni; non chiede che la cosa abbia ancora un motivo per essere fatta.
- 2: Nella luce di questa forza si vedono le mani e non il fine: della tua questione risalta ogni gesto fatto a regola, mentre il motivo per cui lo si fa resta nel buio.
- 3: Gira su sé stessa la corrente della tua questione: entra lavoro ed esce lavoro, mentre dentro al circuito la perizia non cresce di un grammo e non se ne perde uno.

## Nove di Denari

### dritta

- 1: La luce sulla tua questione è quella che cade su un raccolto già diventato proprio: mostra insieme il frutto e la mano che lo ha cresciuto, senza nessun terzo nome accanto.
- 2: Dentro la tua domanda prende valore quello che non deve niente a nessuno: una parte guadagnata da sé conta più di una ricevuta in dono e il permesso di terzi non serve.
- 3: Suona sulla tua questione una nota quieta, di quelle che non chiamano nessuno a guardare: il registro è del piacere privato e di un addestramento lungo che adesso obbedisce alla mano.

### capovolta

- 1: Una corrente verso l'esterno attraversa la tua questione e sposta fuori la parte che garantiva l'autonomia: quello che era riserva diventa mostra, un pezzo alla volta.
- 2: Un bisogno di mostrarsi sta trasformando in apparenza ciò che era sostanza: nella tua questione le risorse messe da parte vengono spese per apparire, non per durare.
- 3: Sulla tua domanda sta un'aria da vetrina: ogni parte viene guardata da fuori prima di essere usata, cosicché il valore proprio si conta sugli occhi che lo notano.

## Dieci di Denari

### dritta

- 1: Dentro la tua domanda conta quello che dura oltre una vita sola: una cosa utile soltanto adesso vale poco, mentre quello che passa ai nipoti prende subito il primo posto.
- 2: La tua faccenda viene guardata alla scala di una casata: sotto questa luce i mesi non si distinguono nemmeno, si distinguono i rami, i cortili, i nomi che si ripetono.
- 3: Vuole questa spinta che la cosa che hai in mano stia bene dentro un cognome: ammette quello che si scrive nel libro di famiglia, non ammette la scelta che riguarda una persona sola.

### capovolta

- 1: Questa spinta divide in quote quello che dentro la tua faccenda sta in comune: traccia confini dentro un bene solo e assegna un nome proprio a ogni parte che taglia.
- 2: Vale nella tua questione soltanto la quota: ogni cosa viene valutata per la parte che toccherebbe a ciascuno, mentre quello che resta indiviso perde credito e nessuno lo difende.
- 3: La rivendicazione comanda qui: dentro la tua domanda ogni bene comune chiede un intestatario; quello che sta a nome di tutti adesso ne vuole uno soltanto.

## Fante di Denari

### dritta

- 1: Dentro la tua domanda vale la regola della scuola: trova strada quello che viene esercitato in piccolo, non ne trova quello che pretende la taglia del mestiere compiuto.
- 2: Premia la lezione ripetuta il criterio che dà valore dentro la tua domanda. Conta il compito piccolo finito davvero; l'ampiezza del progetto dichiarato non sposta niente.
- 3: Una pazienza da principiante sta lavorando la tua domanda a misura di esercizio: la divide in compiti che stanno in una mano e traduce in gesto quello che era soltanto studiato.

### capovolta

- 1: Il tono dentro la tua domanda è quello di una promessa ancora valida e mai eseguita: la parola data continua a essere vera, mentre nessun gesto le è ancora andato dietro.
- 2: Nella tua domanda l'aria è quella di un quaderno aperto su cui nessuno scrive da giorni: il materiale non manca, manca il passaggio dalla pagina alle mani.
- 3: Chiede la prova pratica di quello che è stato studiato e non la riceve la forza che lavora sulla tua domanda: pretende un gesto, mentre l'impegno preso resta in forma di parola.

## Cavaliere di Denari

### dritta

- 1: Vale sulla tua domanda la regola del passo uguale: passa quello che si ripete ogni giorno alla medesima andatura, mentre perde strada quello che pretende uno scatto. La lentezza qui è il metodo.
- 2: Il criterio in vigore dentro la tua domanda conta la costanza: una cosa vale per quante volte viene rifatta identica, non per quanto brilla la prima volta. Il lampo non prende punti.
- 3: Una forza paziente lavora sulla tua domanda come un contadino sul campo: avanza di un solco al giorno, non salta i filari, giunge in fondo perché non si arresta.

### capovolta

- 1: Il tono dentro la tua domanda è quello di un cavallo che respira immobile sul sentiero giusto: nota bassa, zoccoli piantati, la meta visibile in fondo al viottolo.
- 2: Sulla tua domanda pesa l'aria di un mattino in cui la partenza si rinvia: la strada è segnata, la bisaccia è piena e la cautela raffredda ogni tappa.
- 3: La forza in azione chiede alla tua domanda che la cautela smetta di dettare l'orario: pretende un passo qualunque sul sentiero già tracciato, perché la costanza senza moto diventa pietra.

## Regina di Denari

### dritta

- 1: La luce sulla tua faccenda è quella di una lampada bassa sul tavolo: mostra ciò che si può usare oggi, le provviste e le mani che le dispongono, lasciando in ombra ciò che non si tocca.
- 2: Il valore dentro la tua domanda si misura in nutrimento: una cosa vale quanto sfama, scalda o rimette qualcuno in piedi. Le parole che la accompagnano non entrano nel calcolo, perché la prova sta nel piatto.
- 3: Su questa faccenda vale una regola non detta: l'affetto si consegna come provvista. Dentro la tua domanda passa ciò che si può mettere in mano a qualcuno, mentre il buon pensiero da solo non passa.

### capovolta

- 1: Su questa tua faccenda suona il tono di un elenco letto a mano a mano: la spesa, le scadenze, i bisogni di ciascuno. È un elenco ordinato, ma manca chi lo scrive.
- 2: Il criterio che decide qui dà prezzo a ogni bisogno con un altro nome sopra; quello intestato a te vale zero nello stesso calcolo, pur stando nella stessa lista.
- 3: Una corrente esce da questa tua faccenda in tutte le direzioni e verso la sorgente non ne rientra nemmeno una: l'acqua irriga ogni aiuola dell'orto, tranne quella da cui il pozzo pesca.

## Re di Denari

### dritta

- 1: Dentro la tua questione vale adesso la regola dell'abbondanza amministrata: trova strada quello che si può concedere senza intaccare il fondo; il fondo non viene messo in gioco.
- 2: Prende prezzo qui quello che resiste alla prova: dentro la tua questione il solido conta più dello splendido; la mano larga è un segno di sicurezza, non di sperpero.
- 3: Amministra, questa forza: conta quello che la tua questione contiene, ne manda una parte in circolo e lascia l'altra ferma a fare da riserva per le annate magre.

### capovolta

- 1: Ha il tono di chi parla dopo aver contato: dentro la tua questione ogni frase passa per il libro dei beni; è il libro a decidere quanta cortesia sia disponibile oggi.
- 2: L'aria della tua questione è quella di un recinto in ordine: ogni bene ha un proprietario dichiarato, nessuno esce dal perimetro; la larghezza di mano si ritira dietro la rete.
- 3: Esige garanzie, questa forza, prima di qualunque movimento: alla tua questione chiede che niente si sposti senza un titolo di proprietà addosso, nemmeno quello che si regala.

## Asso di Spade

### dritta

- 1: La regola a cui la tua questione obbedisce adesso ammette una risposta per volta: trova strada quello che si lascia nominare con esattezza, non ne trova quello che vive di doppi sensi.
- 2: Suona sulla tua questione una nota netta e metallica, senza cuscino attorno: il registro taglia la frase a metà e lascia da un lato quello che è vero, dall'altro quello che è comodo.
- 3: Questa forza pretende dalla tua domanda una linea sola fra il vero e il verosimile: non ammette la mescolanza in cui le due parti stavano insieme; chiede che la giuntura sia dichiarata.

### capovolta

- 1: Dentro la tua questione prende valore quello che suona definitivo: una frase affilata conta più di una frase esatta, mentre quello che resta in sospeso per onestà non conta niente.
- 2: Un'aria spessa sta sulla tua domanda e dentro quell'aria il taglio continua a essere dato: la mano non vede il contorno e la divisione cade dove la materia era intera.
- 3: Viene da dietro la luce in cui la tua questione si guarda e appiattisce i profili: due parti diverse appaiono come una sola, perciò il filo entra senza sapere quale delle due sta dividendo.

## Due di Spade

### dritta

- 1: Il silenzio è il timbro della tua faccenda: due ragioni della stessa misura stanno zitte una davanti all'altra e nessuna delle due alza di una nota il proprio accento.
- 2: Qui comanda il pareggio: dentro la tua domanda nessuno dei due lati prevale di un filo, così la cosa resta immobile in un equilibrio preciso e scomodo.
- 3: Una benda cala sulla tua questione: i due lati restano intatti al buio, nessuno si vede meglio dell'altro, l'equilibrio vive proprio del non guardare.

### capovolta

- 1: La benda si allenta sulla tua domanda: i due lati tornano visibili nello stesso istante, con le lame ancora incrociate e nessun dettaglio nascosto dietro il tessuto.
- 2: Scorre di nuovo quello che stava immobile dentro la tua faccenda: il nodo si allenta da sé, il movimento riprende, la domanda rimandata ritorna al centro della cosa.
- 3: Esige questa spinta una risposta sulla tua questione di prima: non ammette un secondo rinvio, pretende che la cosa venga nominata adesso con gli occhi aperti.

## Tre di Spade

### dritta

- 1: Sulla tua domanda sta una luce da temporale che non concede ombre: il taglio al centro è illuminato per intero, mentre nessun angolo della cosa resta fuori da quella chiarezza.
- 2: Passa dentro la tua domanda un colpo che va da parte a parte e non si ferma a metà: entra da un lato ed esce dall'altro, lasciando la cosa aperta esattamente al centro.
- 3: Per ora vale nella tua questione una regola semplice: si muove soltanto ciò che chiami con il suo nome, mentre resta fermo ciò che gira attorno al punto che fa male.

### capovolta

- 1: Si sposta dal sangue alla cicatrice il criterio che dà valore dentro la tua domanda: conta quello che si chiude, mentre la grandezza del colpo preso smette di fare numero.
- 2: Una chiusura sta lavorando dentro la tua domanda dal bordo verso il centro: avvicina i due lati del taglio senza cancellarne la linea, così il fiato torna prima della forma intera.
- 3: Smette di piovere il cielo dentro la tua domanda e il tono lo segue: niente trionfo, nessun ritorno all'inizio, soltanto un segno che resta su una cosa che non sanguina più.

## Quattro di Spade

### dritta

- 1: Sulla tua domanda cade la luce bassa di una cappella: schiarisce la pietra, il corpo disteso e le lame appese al muro, mentre lascia in ombra tutto quanto fuori continua a muoversi.
- 2: Dentro la tua domanda il movimento si arresta per scelta della forza: l'acqua non esce e sta nel bacino a riprendere livello. La sosta ha un termine, non è una secca.
- 3: Vale adesso sulla tua domanda una regola di silenzio: passa quello che recupera e resta fuori quello che chiama alle armi. Il tempo fermo qui conta come lavoro.

### capovolta

- 1: Dentro la tua domanda il peso si sposta dal riposo al moto: la quiete conta come cosa compiuta e prende valore il primo gesto misurato. Lo strappo qui non vale niente.
- 2: Scioglie il silenzio della cappella la forza di risveglio che lavora sulla tua domanda: stacca le lame dal muro, rimette in piedi il corpo un pezzo alla volta.
- 3: Il tono della tua domanda è quello della campana del mattino dopo una notte intera di sonno: nota chiara, non squillante, col recupero concluso dietro e il passo che si riapre.

## Cinque di Spade

### dritta

- 1: Una forza si prende il terreno dentro la tua domanda e lascia dietro di sé il campo spoglio: raccoglie le armi di chi si allontana; quello che guadagna le costa quanto resta sparso lì.
- 2: Questa tua faccenda pretende che una parte di essa esca diminuita perché il resto stia in piedi: un pareggio non lo ammette. Il prezzo lo scrive sullo stesso foglio del guadagno, riga sotto riga.
- 3: La luce sulla tua faccenda è dura e taglia in due la scena: da un lato il pezzo portato via, dall'altro quello rimasto a terra, visibili nello stesso istante.

### capovolta

- 1: La regola non scritta di adesso dà meno peso alla ragione che alla restituzione: dentro la tua domanda il gesto che chiude appartiene a chi ha il terreno in mano, non a chi ha torto.
- 2: Suona abbassato il registro su questa tua faccenda: è il tono che viene dopo le urla, quando le frasi tornano a misura normale. Le armi scendono di peso e il discorso perde la punta.
- 3: Il prezzo delle cose nella tua faccenda si sposta: il pezzo portato via vale meno del gesto che lo riconsegna; una ragione dimostrata vale meno di una parola rimessa a posto.

## Sei di Spade

### dritta

- 1: Una luce grigia e ferma sta sulla tua questione: si vede l'acqua che si appiana davanti alla prua, mentre quello che resta dietro perde contorni a ogni colpo di pagaia.
- 2: Scorre piano la corrente che muove la tua questione: spinge in un verso solo senza strappi, mentre l'acqua agitata rimane a una distanza che aumenta da sé.
- 3: Dentro la tua questione vale adesso la regola del carico leggero: trova strada quello che entra in barca, mentre il peso di troppo rimane sulla riva senza seguito.

### capovolta

- 1: Prende valore qui quello che si lascia: dentro la tua questione la sponda che si allontana conta più della direzione presa; il conto del distacco apre ogni bilancio.
- 2: Sposta la tua questione verso l'altra riva senza sciogliere la cima annodata al molo: la traversata procede col peso intero del punto di partenza addosso.
- 3: Ha il tono basso di un saluto non finito: dentro la tua questione ogni movimento in avanti suona insieme a un richiamo che arriva da dietro le spalle.

## Sette di Spade

### dritta

- 1: Un'astuzia silenziosa sta prelevando una parte della tua questione e lascia il resto dov'è: lavora senza annunciarsi, cosicché il guadagno riguarda un pezzo scelto e non l'insieme.
- 2: Questa forza esige dalla tua domanda il silenzio sul metodo: pretende che il passo non faccia rumore; non ammette che quello che si sta facendo venga detto nello stesso momento.
- 3: Attraversa la tua questione una corrente obliqua: il movimento non punta al centro, gira attorno e passa dove la sorveglianza è distratta, con lo stesso effetto di una strada diritta.

### capovolta

- 1: Sulla tua questione il registro si sta spostando: quello che si mormorava si sente adesso per intero; la nota che copriva il resto non copre più nulla.
- 2: La luce sta entrando nell'angolo scuro della tua questione: il pezzo che manca compare insieme al nome di chi lo ha preso, perché i due non si mostrano mai separati.
- 3: Dentro la tua questione vale adesso una regola di rientro: trova strada quello che viene dichiarato, mentre il prelievo rimasto fuori dal conto continua a chiedere il suo posto.

## Otto di Spade

### dritta

- 1: In questa tua faccenda comanda una regola curiosa: nessuno prova a muoversi, così le legature sembrano strette; in verità la corda lascia un giro di gioco a ogni polso.
- 2: Appare chiuso da ogni lato il perimetro della tua domanda, mentre fra una lama piantata e l'altra passa comodamente un corpo intero: il recinto è a maglie larghe.
- 3: Il panno sugli occhi è la parte che lavora qui: quello che non viene guardato dentro la tua questione prende dimensioni enormi, mentre il nodo vero resta piccolo.

### capovolta

- 1: Una spinta allenta i giri di corda a uno a uno dentro la tua domanda: il panno scivola giù da solo, le legature cadono a terra senza che nessuna mano le tocchi.
- 2: Passa adesso un filo d'aria dentro la faccenda: il recinto si apre nel punto meno guardato, così la tua domanda ha il verso libero per muoversi fuori.
- 3: Qui prende valore il passo provato: dentro la tua faccenda conta il piede che si sposta di una spanna, mentre lo studio del nodo non aggiunge niente.

## Nove di Spade

### dritta

- 1: Nella tua domanda l'aria è quella delle ore piccole, quando ogni dettaglio suona più grosso di quanto sia: in quel clima la cosa cresce senza che si aggiunga un fatto nuovo.
- 2: Pretende attenzione continua e non la restituisce mai la forza che lavora sulla tua domanda: esige che la cosa sia ripassata ancora, mentre a ogni giro chiede un giro in più.
- 3: Allunga le ombre di tutto ciò che riguarda la tua domanda, come una lampada accesa di notte: le sagome sembrano enormi, mentre i contorni restano identici a prima.

### capovolta

- 1: Passa dentro la tua domanda una corrente che va dal chiuso al detto: quello che girava sempre nello stesso cerchio esce in parole e perde metà del proprio volume nel passaggio.
- 2: Dentro la tua domanda vale adesso la regola del mattino: trova strada quello che viene pronunciato davanti a qualcuno, non ne trova quello che resta a girare a testa bassa.
- 3: Vale di più il detto che il rimuginato, nel conto che la tua domanda fa adesso: la frase pronunciata fuori conta per quello che è, il giro interno perde l'autorità del buio.

## Dieci di Spade

### dritta

- 1: Sopra la tua domanda sta l'aria ferma del dopo battaglia: cielo nero in alto, striscia chiara in fondo all'orizzonte, terra immobile. Il clima è di cosa conclusa.
- 2: La forza in azione chiede che la fine venga chiamata col suo nome: pretende il riconoscimento di un contrasto esaurito, perché sotto questo punto la tua domanda non ha altro piano dove scendere.
- 3: Una luce radente da ultima ora cade sulla tua domanda: mostra la schiena a terra con tutte le lame piantate e la somma esatta di quanto è andato. Niente resta nel vago.

### capovolta

- 1: Dentro la tua domanda il moto gira verso l'alto partendo da sotto: la spinta è lenta, viene dal basso e di quello di prima non resta niente da recuperare.
- 2: Vale sulla tua domanda una regola di ricostruzione da zero: ha corso ogni gesto minimo che rimette in piedi qualcosa, mentre non ha corso il salvataggio di quanto è finito.
- 3: Il criterio al lavoro dentro la tua domanda azzera il prima: quanto c'era non entra più nella misura, mentre prende valore ogni minima cosa che si rialza da terra.

## Fante di Spade

### dritta

- 1: Sta sulla tua faccenda un'aria tagliente di vento aperto: apre gli occhi, drizza le orecchie, asciuga la pigrizia. In quella temperatura ogni dettaglio chiede di essere guardato prima di essere creduto.
- 2: Una corrente di perlustrazione gira dentro la tua domanda: sale a guardare, scende a riferire, risale. Il moto raccoglie notizie in fretta e le passa avanti nello stesso istante in cui le prende.
- 3: Qui lavora sulla tua faccenda una vigilanza giovane: fa domande, prende appunti, verifica un particolare alla volta senza chiudere il quadro. Quello che trova lo dice subito, con la lingua più rapida della prudenza.

### capovolta

- 1: Questa tua faccenda pretende che ogni cosa venga detta prima di essere verificata: il giro delle parole non le serve esatto, le serve rapido. Chi è nominato non viene convocato a confermare.
- 2: La luce cade su chi è assente e lascia al riparo chi parla: nella tua domanda si vede bene il nominato, male la bocca che lo nomina. Il taglio arriva da lì.
- 3: Vale adesso una regola non detta: una cosa detta passa per una cosa saputa. Nella tua faccenda nessuno chiede la prova, perciò il riferito prende il posto del verificato.

## Cavaliere di Spade

### dritta

- 1: Sulla tua questione tira un vento teso e freddo: l'aria si apre davanti a una punta sola; quello che non sta su quella linea viene sfiorato appena di passaggio.
- 2: Vuole una linea retta dalla tua questione: ammette un bersaglio per volta, ammette la fretta; non ammette deviazioni per guardare che cosa ci sia di lato.
- 3: Nella luce di questa forza il bersaglio si vede con nitidezza fredda: della tua questione risalta la linea più corta, mentre quello che le sta ai fianchi sbianca.

### capovolta

- 1: Corre più veloce del proprio disegno, la spinta dentro la tua questione: arriva al punto un istante prima che il punto sia scelto, poi riparte verso un altro.
- 2: Dentro la tua questione comanda adesso la regola della rapidità: passa quello che si decide subito, mentre quello che chiede un istante di verifica non entra in tempo.
- 3: Conta qui la velocità e non la direzione: dentro la tua questione prende credito quello che è pronto all'istante, mentre quello che è giusto senza essere immediato non figura.

## Regina di Spade

### dritta

- 1: Sulla tua questione tira un'aria limpida e fredda: niente di quello che si dice viene addolcito prima di uscire, cosicché ogni parola arriva con il suo esatto spessore.
- 2: Una corrente di separazione attraversa la tua domanda e traccia il confine fra quello che riguarda e quello che non riguarda: il bordo è netto, detto a chi lo attraversa senza mezze frasi.
- 3: Dentro la tua questione prende valore il discernimento che è costato qualcosa: una distinzione imparata su una perdita conta più di una regola letta, mentre la gentilezza di maniera non conta.

### capovolta

- 1: Questa forza pretende dalla tua questione una distanza stabilita prima di qualunque scambio: ammette quello che resta oltre il bordo, non ammette niente che chieda di entrare senza annuncio.
- 2: La regola non detta che la tua questione segue adesso tratta ogni vicinanza come un rischio: trova strada il controllo, mentre quello che chiede confidenza resta dove è arrivato.
- 3: Un filo girato all'interno sta lavorando dentro la tua questione: la stessa nettezza che separava il vero dal falso adesso stabilisce quanto lontano deve stare chiunque si affaccia.

## Re di Spade

### dritta

- 1: Sulla tua domanda lavora un'autorità che pronuncia: ascolta i due lati della cosa, taglia con una lama sola, lascia una decisione a cui dentro la faccenda tutti si attengono.
- 2: Pretende questa spinta che la tua questione venga argomentata: ammette la ragione esposta a parole chiare e non ammette il favore, il tono alzato né la simpatia come motivi.
- 3: Vale qui la prova mostrata: dentro la tua domanda conta quello che si dimostra davanti a terzi, mentre l'impressione personale non entra nel giudizio.

### capovolta

- 1: Dentro la tua faccenda conta soltanto l'esattezza: l'argomento giusto vale tutto, mentre chi lo riceve non figura nel calcolo e il legame non entra fra le ragioni.
- 2: Ogni frase dentro la tua domanda cade giusta e nessuna cade tiepida: il tono della cosa è asciutto come un verdetto letto in fretta a porte chiuse.
- 3: Un'aria asciutta circola nella tua questione: la temperatura scende di qualche grado, le ragioni restano nitide, le persone nominate dentro la faccenda perdono spessore.
