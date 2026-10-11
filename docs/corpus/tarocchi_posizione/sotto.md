# LA POSIZIONE: SOTTO

Il fondamento della Croce Celtica.

**Fonte da riempire.** Per ogni carta e per ogni verso tre varianti dello
stesso scheletro, `- 1:`, `- 2:`, `- 3:`, scritte dall'Architetto (ordine FI,
aggiunta A1 e A4). Una riga vuota e' un testo che non c'e' ancora. Una
variante e' piena in tutte le 156 carte-verso o vuota in tutte: a meta', il
tool si ferma e nomina le righe che mancano.

**Le tre varianti vengono dal corpus dell'11 ottobre 2026**, scritte
dall'Architetto con dodici scrittori e consegnate col commit 394e9c5, pulite
sulle dieci regole del metro. La posizione **non ha un numero** in prova cieca:
i sei scrittori riportano 78 testi su 78 con una figura concreta della carta,
ma e' una misura degli scrittori su se stessi, non una prova appaiata.
Provenienza scritta da Code con l'ordine FK, aggiunta 2 voce A11, dal messaggio
del commit 394e9c5, perche' la regola FJ.4 vuole che ogni posizione con testi
dica da dove vengono.

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

- 1: Una partenza già scelta sta sotto la tua questione: il piede fuori dalla soglia ha chiuso le altre porte; quella porta chiusa è quello su cui tutto poggia adesso.
- 2: Il fardello ridotto a una bisaccia sola regge quello che hai davanti: quel poco caricato sul bastone è l'appoggio della tua questione, non un suo ornamento.
- 3: Fra tutto quello che si muove, la leggerezza del passo non si rimette in gioco: è diventata il punto fermo su cui la tua domanda si appoggia, da quando il bagaglio pesante è rimasto a terra.

### capovolta

- 1: Uno scatto partito senza misura ha già pagato il suo conto; è quella spesa, non il dirupo davanti, a tenere su la tua questione adesso.
- 2: Il materiale della tua domanda è un entusiasmo impastato senza rotta: la pasta è stata scelta sull'orlo, prima del passo; su quella sostanza la cosa sta in piedi oggi.
- 3: Resta un deposito di partenze accennate e mai portate oltre il primo passo: quella scorta di slanci interrotti è sotto la tua questione e la porta su di sé.

## Il Mago

### dritta

- 1: Un banco già apparecchiato, con la bacchetta e la coppa e la lama e la moneta a portata di mano, sta sotto la tua domanda: quello che hai davanti poggia su una capacità di eseguire che è tua da prima.
- 2: Gli attrezzi disposti sul tavolo sono stati pagati prima che la tua domanda nascesse: è quella spesa chiusa a tenere su quello che hai davanti, mentre la mano sa dove prenderli senza guardare.
- 3: Rose e gigli cresciuti ai piedi del tavolo hanno messo radice nel terreno della tua questione: da lì il gesto prende alimento e su quelle radici quello che hai davanti continua a stare.

### capovolta

- 1: Parole dette che non sono ancora passate per le mani: di questa materia è impastato quello che hai davanti; il banco resta apparecchiato e nessuno degli attrezzi porta un segno d'uso.
- 2: Il cassetto richiuso sopra un talento sta ancora sotto la tua questione: quella porta serrata non si riapre da sé e quello che hai davanti poggia su di essa come su una tavola.
- 3: Una destrezza già imparata lavora da sé mentre la bacchetta resta alzata: è quel mestiere, appreso una volta per sempre, a reggere la tua questione dal basso senza chiedere nulla.

## La Papessa

### dritta

- 1: Sotto la tua domanda sta un sapere arrivato senza parole, di quelli che si sono posati prima che tu potessi spiegarli: quel libro mezzo nascosto nel manto regge tutto il resto.
- 2: Un silenzio che hai già pagato in attese lunghe e in risposte trattenute tiene su quello che oggi hai davanti: la quiete fra le due colonne fa da appoggio alla tua questione.
- 3: La tua questione è piantata in un terreno che ha già bevuto a lungo: quello che hai saputo prima di ogni ragionamento, al riparo del velo, resta la radice e tiene in piedi il resto.

### capovolta

- 1: Quello che hai davanti è impastato di una cosa saputa e tenuta zitta: il sapere messo sotto il manto, coperto dal ragionare, è la stoffa stessa della tua questione e la regge da dentro.
- 2: Hai preferito una volta la spiegazione al presentimento. Quella porta resta chiusa e su quella scelta, col libro serrato in grembo, poggia oggi la tua questione.
- 3: Una pratica imparata da tempo lavora da sé sotto la tua questione: tirare il velo sopra quello che sapevi senza parole ti riesce senza sforzo. Quell'abilità acquisita fa da base al resto.

## L'Imperatrice

### dritta

- 1: Un raccolto già maturato nel grano tiene su la tua questione: quello che hai davanti è cresciuto per intero prima di arrivarti; il suo peso di cosa viva sta sotto tutto il resto.
- 2: La terra che ha già bevuto nutre dal basso quello che la tua domanda mette in gioco: una radice presa in profondità sostiene il frutto senza che le foglie debbano saperlo.
- 3: Una cura imparata sulle cose vive regge la tua questione: il gesto che fa aprire un fiore senza strappargli i tempi è stato acquisito e ora lavora da sé sotto quello che hai in mano.

### capovolta

- 1: Di generosità già spesa per intero sul giardino di fuori è impastata la tua questione: quella materia la regge; il terreno da cui è stata tratta sta sotto senza la sua parte d'acqua.
- 2: Un'abitudine a far crescere le cose altrui, acquisita fino a riuscire senza pensarci, sta sotto la tua domanda: la mano che annaffia il giardino ha imparato a non passare dalla propria aiuola.
- 3: Quello che hai davanti poggia su un rigoglio già prodotto: le foglie aperte verso la luce tengono su la scena; la radice che le ha fatte è rimasta all'asciutto.

## L'Imperatore

### dritta

- 1: Sotto la tua questione sta un seggio di pietra: una regola già posata porta tutto il carico, cosicché quanto le poggia sopra non deve essere tenuto a mano da nessuno.
- 2: Una libertà ceduta in cambio di un confine netto è il conto chiuso su cui la tua questione sta: lo scettro pesa in mano a chi l'ha preso, dunque quel peso tiene ferma la cosa.
- 3: Nel terreno della tua faccenda hanno già messo radice una misura e un limite dichiarati una volta sola: da lì la cosa beve l'ordine che oggi la tiene su.

### capovolta

- 1: La tua questione è impastata di comando: una corazza serrata al punto di togliere il respiro è la materia stessa su cui sta, non un involucro messo attorno più tardi.
- 2: Un ordine imposto una volta sola ha chiuso le altre vie di governo: quella porta sbarrata regge la tua questione adesso, con un trono a cui manca una gamba sotto.
- 3: Quello che hai già imparato sul tenere fermo sostiene la tua domanda da sotto: la mano sul bracciolo non chiede più attenzione, cosicché la stretta prosegue oltre il punto in cui serviva.

## Il Papa

### dritta

- 1: Sotto la tua domanda c'è un insegnamento ricevuto da chi sedeva lì prima di te: una dottrina già consegnata, come due chiavi passate di mano, che ancora regge il peso di quello che hai davanti.
- 2: Una fedeltà già pagata fa da base alla tua questione: il prezzo versato per inginocchiarsi dentro una regola comune, davanti a una mano alzata a benedire, tiene su quello che oggi è in gioco.
- 3: La tua questione affonda in un terreno dissodato da altri: una sapienza tramandata ha già bagnato quel suolo e quello che ne sale sostiene ciò che hai per le mani.

### capovolta

- 1: Della tua questione è impastato un precetto imparato a memoria da bocca d'altri: la stoffa è quella, un dover essere cucito addosso tempo fa, che sta ancora sotto quello che hai davanti.
- 2: Una formula accettata senza discuterla ha chiuso a suo tempo le altre letture possibili: quella porta rimasta serrata è il piano su cui la tua questione poggia ancora.
- 3: Hai imparato a ripetere una lezione che allora misurava bene le cose: quella capacità acquisita lavora ancora da sé sotto la tua domanda, con un metro che è rimasto quello di prima.

## Gli Amanti

### dritta

- 1: Una preferenza già dichiarata fra due valori tuoi sta sotto la tua domanda: la figura in alto ha visto la mano alzarsi; quella mano alzata è l'appoggio che regge il resto.
- 2: Sotto la tua questione c'è una radice di valori già messa a dimora: l'albero fiorito dietro le due figure affonda in quel suolo e ne beve da prima che la domanda nascesse.
- 3: Quello che hai già imparato a distinguere, il tuo bene dal bene dell'altro, non si conquista più: le due figure nude sotto la benedizione stanno su quella competenza; è lei che regge la tua domanda.

### capovolta

- 1: Un credo messo a tacere è il punto che non si rimette in gioco: la benedizione è andata a una metà sola della tua scelta; su quel silenzio la questione sta in piedi oggi.
- 2: Di due desideri tuoi, che hanno già chiesto cose diverse, è impastata la questione: non due persone venute da fuori, ma le due metà nude sotto la stessa benedizione. Quella stoffa doppia la porta.
- 3: Sotto la tua domanda sta un accordo interiore mai firmato: la mano alzata fra le due figure si è fermata a metà strada e quel gesto incompiuto continua a fare da appoggio a tutto il resto.

## Il Carro

### dritta

- 1: Una riserva di spinta accumulata prima che tu chiedessi sta sotto la tua questione: il mezzo pesca da quella scorta a ogni giro di ruota e non deve chiedere permesso a nessuno.
- 2: Il giogo che tiene insieme due bestie contrarie è l'unico pezzo della tua questione che non si rimette in gioco: è diventato fermo e tutto il resto si muove sopra di lui.
- 3: Due animali di colore opposto, già aggiogati allo stesso timone, fanno da appoggio a quello che hai davanti: la tua questione va avanti perché quel traino regge il peso di entrambi.

### capovolta

- 1: Il prezzo di una corsa già compiuta tiene su quello che hai davanti: lo slancio è stato speso prima di questa domanda e il mezzo resta attaccato a due tiri che vanno ciascuno per sé.
- 2: Sotto le ruote il suolo battuto da una partenza già data nutre ancora la tua questione: quel fondo regge il mezzo mentre i due tiri strappano verso punti diversi del campo.
- 3: Lamiera addosso e stelle cucite sopra il capo: di questa materia è impastato quello che hai davanti; un telo già teso resta teso anche nel momento in cui il passo sbanda.

## La Giustizia

### dritta

- 1: Si è accumulato sotto la tua domanda un conto esatto: ogni atto ha lasciato il suo peso sul piatto. Quel deposito di cause ed effetti non si disperde e la tua questione pesca da lì.
- 2: Una cosa nella tua questione resta fuori discussione: la misura è stata presa e la bilancia sta ferma su quel numero. Il resto si muove, quel peso accertato tiene.
- 3: Quello che hai seminato è già scritto nel piatto basso e da lì tiene su tutto: non la persona che ha agito, ma l'effetto posato dall'atto fa da appoggio a quello che oggi ti riguarda.

### capovolta

- 1: Un prezzo è già stato messo sul piatto e il conto resta aperto al tuo nome: hai attribuito quel costo al caso, la cifra però sta sotto la tua questione e la tiene ferma.
- 2: La tua questione è piantata su un effetto che una tua scelta ha prodotto e che porta il tuo nome: quella radice beve ancora sotto la bilancia inclinata e da lì viene quello che oggi vedi.
- 3: Quello che oggi ti pesa è impastato di una conseguenza tua, tenuta a nome di altri. La spada resta sguainata sopra un piatto carico; di quella materia la tua questione è fatta e su quella sta.

## L'Eremita

### dritta

- 1: Una riserva di silenzio messa da parte e non dispersa sta sotto la tua domanda: la lampada pesca là il lume che basta a un passo per volta, senza chiedere permesso a nessuno.
- 2: Il peso che tiene su la tua questione è un ritiro già fatto: dal monte è stata portata giù una cosa sola, il cerchio di luce che un bastone e una lampada fanno sul sentiero.
- 3: Di conoscenza raccolta stando in disparte è impastato quello che hai in mano: quel materiale la tiene su, piccolo come il chiarore che una lanterna apre sulla neve.

### capovolta

- 1: Un prezzo versato in giornate di porta chiusa sta sotto la tua questione: il conto è stato saldato in compagnia non fatta; la lampada che doveva fare strada resta girata verso il muro.
- 2: Della stessa stoffa del raccoglimento è fatto il guscio indurito che tiene su quello che hai davanti: quella materia, provata al freddo, regge bene una lampada tenuta bassa e male una porta aperta.
- 3: Quello che la tua domanda ha sotto è un deposito di ore passate in disparte: si è accumulato senza disperdersi; adesso quella scorta tiene su il muro meglio di quanto illumini il sentiero.

## La Ruota della Fortuna

### dritta

- 1: Sotto la tua domanda sta quello che molti giri hanno già depositato: il cerchio ha alzato la cosa e l'ha riabbassata senza mano che lo spingesse, cosicché quel sedimento di rotazioni la tiene su.
- 2: L'unico elemento che nella tua questione non si rimette più in gioco è il mozzo del cerchio: attorno a quello tutto ha già girato una volta, mentre il perno fermo regge il movimento.
- 3: Il carico della tua faccenda poggia su un cerchio che si è già voltato da sé: nessuna mano l'ha spinto, dunque quanto sta sotto è la rotazione dei raggi che ha portato qui le cose.

### capovolta

- 1: Una scommessa già versata al banco del caso è la spesa su cui la tua questione poggia: il cerchio ha preso quella posta, poi ha riportato tutto al punto da cui era partito.
- 2: Nel suolo della tua questione è piantato un movimento che si è ripetuto da sé: il cerchio ha girato storto per un dente saltato, dunque quella radice di ritorni tiene su quanto hai davanti.
- 3: Di un moto che si è ripetuto senza presa per chi sta sul bordo è fatta la tua questione: quella sostanza girevole, già impastata di ritorni, la porta ancora adesso.

## La Forza

### dritta

- 1: Una riserva di mansuetudine messa da parte un poco alla volta sta sotto la tua questione: la mano che ha già posato il palmo sul muso della bestia pesca da quel deposito senza chiedere permesso.
- 2: Il punto che resta fuori discussione è la calma: la belva è stata domata con la carezza invece che col pugno; quel fatto compiuto siede sotto quello che hai per le mani.
- 3: Sotto quello che ti preme c'è un appoggio curioso: il peso dell'istinto è già stato retto a mani nude, senza laccio né catena, così quella tenuta fa da base alla tua domanda.

### capovolta

- 1: Un prezzo è già stato pagato in durezza: la carezza sul muso si è chiusa in stretta e quella presa, costata molto, tiene su la tua questione come un appoggio che schiaccia invece di sostenere.
- 2: La tua domanda affonda in un terreno indurito: la mitezza esercitata una volta si è fatta pugno e da quella radice secca la cosa prende ancora quello che le serve per stare in piedi.
- 3: Di che cosa è fatto quello che hai davanti: di una tenuta ottenuta a denti stretti, materia buona lavorata male; la questione continua a posare su quella stessa stoffa.

## L'Appeso

### dritta

- 1: Un tempo fermo già speso sta sotto la tua questione: la caviglia legata al legno ha pagato la vista che adesso ti serve; quella spesa non si riprende più.
- 2: Lo sguardo invertito, con la testa in basso e l'aureola accesa, è diventato una capacità acquisita: non si riconquista a ogni giro e fa da base alla tua questione.
- 3: Si è accumulata una riserva di quiete nei giorni senza movimento: quella scorta, raccolta mentre le mani stavano dietro la schiena, è sotto la tua domanda e la porta.

### capovolta

- 1: Una rinuncia già offerta a nessuno ha chiuso le altre vie: resta quella sola, con la corda ferma alla caviglia; su quella chiusura la tua questione sta in piedi adesso.
- 2: La tua questione pesca in un terreno di attesa che ha smesso di dare frutto: quel suolo è stato scelto quando il legno ha preso su di sé il corpo appeso e sotto la cosa ci sta comunque, ne regge il peso.
- 3: Quel che sta sotto la tua domanda è una sosta diventata stallo: il corpo a testa in giù ha dato tutto quello che aveva; quel residuo fa da appoggio a quello che hai davanti.

## La Morte

### dritta

- 1: Un taglio dato una volta sola fa da piano a quello che hai davanti: il campo è stato sgombrato e la tua questione sta su quello spazio aperto che nessuno rimette al suo posto.
- 2: Passare il fiume davanti alle due torri è un mestiere che la tua questione ha già appreso: quella traversata compiuta lavora da sé e tutto quello che hai davanti si appoggia a lei.
- 3: Resta una scorta nel campo mietuto: petali bianchi su uno stendardo portato fin qui; da quella riserva la tua questione attinge e su di essa continua a stare senza chiedere permesso.

### capovolta

- 1: Il colpo di falce è già andato e questa è la sola parte della tua questione che non torna in discussione: la mano chiusa sopra quel taglio tiene su quello che hai davanti.
- 2: Una corona caduta per terra, che nessuno ha raccolto, fa da appoggio a quello che hai davanti: la tua questione pesa tutta su quel metallo rimasto dov'era allora.
- 3: Versato prima di questa domanda, il pedaggio della traversata non si riprende: su quella moneta consegnata poggia quello che la tua questione tiene fermo adesso, a riva.

## La Temperanza

### dritta

- 1: Una dose trovata una volta per tutte sta sotto la tua questione: il travaso fra le due coppe è stato avviato e quel gesto non si disfa, il resto poggia sul suo ritmo lento.
- 2: Mescolare con calma quello che sembrava inconciliabile ti riesce da prima di questa domanda. È una pratica già acquisita, un piede nell'acqua e uno sulla riva, che porta la tua questione.
- 3: Si è depositata nel fondo una pazienza che non hai speso tutta: quella riserva, travasata a lungo da una coppa all'altra, non si è dispersa e sorregge quello che oggi ti sta davanti.

### capovolta

- 1: Una quantità nella tua questione resta fuori discussione: di una parte è stato versato troppo, dell'altra quasi niente. Quella proporzione già fissata è quello che tiene su il resto.
- 2: Sotto quello che hai davanti sta una mistura fatta in fretta e già bevuta: il filo d'acqua fra le due coppe si era rotto. Quel miscuglio sostiene adesso la tua questione per intera.
- 3: Hai pagato in fretta e in eccessi una dose sbagliata: quel prezzo già versato tiene su la tua questione come un appoggio storto che non cede, con le due coppe ancora nelle mani.

## Il Diavolo

### dritta

- 1: Una comodità scelta una volta e mai disfatta sta sotto la tua questione: quel sì ha chiuso le altre porte e il collare appoggiato al collo, con la catena larga, continua a reggere quello che hai davanti.
- 2: Il gusto che hai già preso non si è disperso: è rimasto come una scorta a cui la tua questione pesca senza chiedere permesso; il piedistallo di pietra sotto la figura cornuta sta fermo da prima.
- 3: Qualcosa è stato pagato in cambio di quel piacere e il conto è chiuso: la tua questione poggia su quella moneta versata, come i due ai piedi del trono poggiano sulla catena che li tiene allacciati.

### capovolta

- 1: Un patto guardato in faccia non torna in discussione: il nome che hai dato a quel legame regge da solo quello che resta in gioco, mentre il collare sollevato pesa ancora nelle mani.
- 2: Il conto del tempo passato con quel collare addosso è stato saldato per intero: la tua questione sta su quella spesa e la catena che pende vuota pesa meno della moneta già contata.
- 3: Sciogliere quel nodo è stato un atto compiuto una volta sola: adesso quella scelta tiene su quello che hai davanti e la torcia rivolta al basso scalda il pavimento più del trono.

## La Torre

### dritta

- 1: Una costruzione colpita in cima ha tolto dal tavolo ogni ritorno alla versione precedente: la tua questione poggia su quel crollo, perché le pietre venute giù non si rimettono in fila.
- 2: Quello che il colpo dall'alto ha insegnato non si deve più conquistare: sotto la tua questione sta la capacità acquisita di distinguere la pietra viva dall'intonaco caduto.
- 3: Dalle macerie è rimasto un deposito di pietre sane: quanto il colpo dall'alto non ha potuto portare giù sta ancora sotto la tua faccenda, scorta su cui la cosa pesca senza chiedere permesso.

### capovolta

- 1: L'unica cosa non più in discussione nella tua questione è un rinvio già deciso: la scossa che avrebbe smontato l'impianto sta posticipata, dunque il muro incrinato porta ancora il tetto.
- 2: Il peso della tua faccenda sta su un muro che ha preso la crepa senza venire giù: quello che sostiene la cosa adesso è una parete puntellata, non una parete intera.
- 3: Una spesa in puntelli e sostegni provvisori è stata versata una volta per tutte: su quel pagamento la tua questione poggia, con l'edificio in piedi per via del rinforzo comprato.

## La Stella

### dritta

- 1: Una scelta fatta nel buio peggiore ha chiuso le altre strade: quella di sperare comunque. Il passo compiuto allora è il piano su cui la tua questione poggia adesso, sotto un cielo tornato chiaro.
- 2: Hai già attraversato una tempesta e quello che ne hai imparato lavora ora da sé: la quiete che ne è rimasta non si conquista due volte e sostiene la tua domanda senza fare rumore.
- 3: Sotto la tua questione c'è acqua già versata: due brocche inclinate sulla terra e nello stagno hanno riempito un deposito di fiducia da cui quello che hai davanti pesca ancora.

### capovolta

- 1: Il punto fermo della tua questione è una promessa fatta e mai ritirata: l'astro a otto punte è coperto da una nube, però il versamento d'acqua è già avvenuto e tiene su il resto.
- 2: Sostiene quello che hai davanti una fiducia stanca e intatta: ha già portato peso prima di questa domanda, lo porta anche adesso, col cielo velato sopra e meno chiarore sulla pelle.
- 3: Una quiete pagata cara, brocca per brocca, fa da fondo alla tua domanda: la nube che copre adesso non riporta indietro quello che è già stato versato sulla terra.

## La Luna

### dritta

- 1: Sotto la tua questione c'è un'acqua già bevuta al buio: dallo stagno dove il gambero si muove è venuta su una conoscenza non spiegabile; quel suolo umido la tiene in piedi.
- 2: Di materia notturna è impastato quello che hai davanti: il sentiero pallido fra le due torri è stato tracciato prima della tua domanda e la sostiene com'è, senza schiarirsi.
- 3: Una cosa non si rimette in gioco: il buio su cui i due cani hanno già ululato resta dov'è. Mentre il resto della tua questione si muove, quel tratto non illuminato fa da appoggio.

### capovolta

- 1: Riconoscere una forma gonfiata dal buio è una competenza che non si riconquista: si è formata quando il sentiero fra le due torri si è visto per intero; oggi tiene su la tua questione.
- 2: Resta il sedimento di una nebbia già attraversata: la misura vera delle cose, raccolta mentre i cani tacevano, è il deposito su cui quello che hai davanti si appoggia.
- 3: Il conto di quelle notti è stato versato fino in fondo; quella moneta non si riprende e la tua domanda sta su di essa, non sullo stagno che si è calmato.

## Il Sole

### dritta

- 1: Girasoli piantati dietro un muro hanno già bevuto l'acqua che serviva: le loro radici tengono su la tua questione da sotto e la testa gialla resta girata dove il calore sta.
- 2: Di luce già salita in cima è fatto quello che hai davanti: una chiarezza versata su ogni cosa è la materia su cui la tua questione posa; lo stendardo rosso si vede per intero.
- 3: Il muro alle spalle del bambino è stato tirato su una volta e nessuno lo rimette in discussione: quella scelta di pietra fa da base a quello che hai davanti, a mezza altezza.

### capovolta

- 1: Una pelle che sa riconoscere il caldo l'ha imparato tempo fa e quel mestiere lavora da sé: la tua questione sta su quel sapere anche col velo teso fra te e i raggi.
- 2: Nei mattoni scaldati da un mezzogiorno già compiuto è rimasta una riserva di tepore: da quella la tua questione attinge e su quella posa, mentre una nube sta ferma in mezzo.
- 3: Il disco in cima al cielo è fuori discussione: è salito e da lì tiene su quello che hai davanti; dentro la tua questione si muove soltanto lo spessore del velo.

## Il Giudizio

### dritta

- 1: La tua questione è piantata in un richiamo già squillato: la tromba è passata una volta sopra quello che tenevi chiuso. Da quella radice sale tutto quello che adesso sta in piedi.
- 2: Quello che hai davanti è impastato di un bilancio già fatto: il coperchio si è alzato su quello che eri e la tua questione è fatta di quella materia, nient'altro la tiene su.
- 3: Hai risposto una volta a un richiamo e da quella risposta non si torna. Chi si è rialzato in piedi non si ricorica più e su quel passo compiuto la tua questione poggia tutta.

### capovolta

- 1: Rimandare il bilancio ti riesce senza sforzo da prima di questa domanda: è un mestiere già imparato, il coperchio richiuso sopra la tromba, che tiene su la tua questione per intera.
- 2: Si è accumulata una severità che hai rivolto solo a te: quel sedimento di conti fatti con la misura più dura, davanti al sepolcro rimasto chiuso, sostiene adesso la tua questione.
- 3: Una condanna che hai pronunciato su di te resta fuori discussione mentre il resto si muove: quel verdetto fermo, col coperchio tenuto giù, fa da base alla tua questione.

## Il Mondo

### dritta

- 1: La tua questione sta su un terreno percorso fino in fondo: ogni tratto attraversato ha messo radice là dove passava e la corona di foglie chiusa in cerchio tiene su quello che hai adesso.
- 2: Un cerchio chiuso non si riapre: il giro che hai compiuto per intero regge quello che è in gioco, con le figure dei quattro angoli ferme ognuna al suo posto.
- 3: Quello che è stato attraversato non si rimette in gioco: resta il punto fermo sotto la tua domanda, mentre tutto il resto si muove dentro la ghirlanda d'alloro che lo circonda.

### capovolta

- 1: Quasi tutto il giro è stato imparato sulla propria pelle: quella pratica tiene su la tua questione e la corona di foglie regge con una maglia ancora da intrecciare.
- 2: Il tratto percorso non si rimette in discussione ed è l'unica cosa ferma sotto quello che hai davanti: la danza dentro il cerchio continua su quel pezzo già fatto.
- 3: Dove il cammino ha già messo radice la tua domanda trova appoggio: il terreno regge il peso di quasi tutto il cerchio e un palmo di suolo resta senza il suo filo d'alloro.

## Asso di Bastoni

### dritta

- 1: Nel suolo della tua questione sta un ramo verde appena piantato che ha già messo foglia: la cosa beve da quella linfa, cioè da un primo fuoco acceso e non ancora speso.
- 2: La materia della tua questione è legno vivo: la sostanza grezza di una partenza che ha preso fuoco una volta porta ancora il calore dentro le fibre, dunque su quel legno la cosa sta.
- 3: Un fiammifero acceso ha chiuso la stagione dell'attesa: quella scintilla già data è l'atto che non si disfa, dunque la tua faccenda si appoggia su di essa.

### capovolta

- 1: Quello che le dita hanno appreso sul far scoccare un fuoco non si riconquista: sotto la tua faccenda sta quell'abilità intatta, col ramo verde appoggiato al muro che nessuno ha acceso.
- 2: Sotto la tua questione si è raccolta una riserva di slancio non speso: il fuoco coperto di cenere non si è disperso, dunque la cosa pesca da quel calore tenuto al coperto.
- 3: L'elemento che nella tua domanda resta fuori dal gioco è il desiderio: è stato acceso una volta sola, sta sotto la cenere e tiene su la cosa mentre il resto si muove.

## Due di Bastoni

### dritta

- 1: La tua questione è piantata su un muro che altri hanno alzato: da quel parapetto il mondo sta già in una mano e la pietra sotto i piedi è quella che regge lo sguardo lungo.
- 2: Di una cosa già ottenuta è impastato quello che hai davanti: il globo chiuso nel palmo. Quel possesso acquisito porta adesso la tua questione, mentre un piede resta dentro le mura.
- 3: Una delle due aste è stata fissata alla pietra e non si stacca: quell'atto compiuto ha chiuso la strada del restare fermi, così la tua domanda poggia oggi su quel punto saldo.

### capovolta

- 1: Hai imparato a guardare lontano e quella capacità lavora ancora da sé sotto la tua questione: si è fermata però allo sguardo, perché il parapetto è diventato il posto dove si abita.
- 2: Sotto quello che ti riguarda si è accumulata una scorta di piani mai aperti: il globo è in mano da prima di questa domanda e la cosa continua a stare su quel mucchio di rotte non scelte.
- 3: L'unica cosa fuori discussione è che il mondo ti sta in una mano: il fatto si è compiuto, la rotta è rimasta scritta a metà e proprio quel misto fa da appoggio alla tua questione.

## Tre di Bastoni

### dritta

- 1: Una spedizione già pagata sta sotto la tua questione: il carico è partito dal porto e il conto è chiuso; su quella spesa fatta la cosa si tiene, mentre l'orizzonte resta vuoto.
- 2: Mandare quel carico lontano è stata una scelta che ha chiuso le altre: dal promontorio non si richiama una nave; quella porta chiusa è l'appoggio della tua domanda adesso.
- 3: Sotto quello che hai davanti sta un lavoro già consegnato al mare: il peso di quella consegna, non l'attesa di oggi, è quello che tiene su la tua questione.

### capovolta

- 1: Di aspettative scritte prima della partenza è fatta la tua questione: quella misura, fissata dal promontorio, sta sotto la merce rientrata e la regge anche se il carico è un altro.
- 2: Si è depositato un elenco di previsioni mai riviste: quella riserva di attese, compilata quando le vele erano all'orizzonte, porta su di sé quello che hai davanti oggi.
- 3: Il carico rientrato c'è e non si discute più: quello che il mare ha riportato è il punto fermo della tua domanda, mentre il conto fra l'atteso e il ricevuto resta aperto.

## Quattro di Bastoni

### dritta

- 1: Pali piantati nel terreno con una ghirlanda legata in cima: quel portale regge da sé e sta sotto la tua questione, che da prima di questa domanda ci passa in mezzo.
- 2: La spesa del raccolto è già stata fatta: fiori e frutti intrecciati sopra la soglia sono stati pagati col lavoro di una stagione; su quel conto chiuso poggia quello che hai davanti.
- 3: Il prato davanti al castello ha nutrito la ghirlanda prima che tu chiedessi: quelle radici stanno sotto la tua questione e la tengono su mentre la gente arriva fino al ponte.

### capovolta

- 1: Di fiori già recisi e legati insieme è fatta la soglia su cui la tua questione posa: la materia c'è tutta e l'ora di passarci sotto non è ancora stata battuta.
- 2: Alzare quel portale è stata una scelta che non si disfa: i pali sono fermi nel terreno e quello che hai davanti poggia su di loro, anche senza nessuno che li attraversi.
- 3: Costruire una soglia è un mestiere che le mani hanno già appreso: quel sapere lavora da sé sotto la tua questione; la ghirlanda legata in cima sta dove le mani l'hanno messa.

## Cinque di Bastoni

### dritta

- 1: Sotto la tua questione sta una mischia alla pari già ingaggiata: pali incrociati in aria senza nessuno che comandi. Quell'attrito avvenuto la tiene su invece di buttarla giù.
- 2: Hai speso fiato e muscoli in un confronto aperto dove nessuno aveva il grado per decidere: quella fatica versata nella zuffa non si riprende e adesso regge quello che hai davanti.
- 3: La tua questione affonda in un terreno battuto da molti bastoni insieme: quel campo dove la prova è avvenuta alla pari ha già bevuto lo scontro e da quella radice tiene il resto.

### capovolta

- 1: Quello che hai davanti è impastato di molte beghe minute, tutte lasciate aperte: bastoni alzati in aria che nessuno ha calato. Di quella materia la tua questione è fatta e su quella sta.
- 2: Hai tenuto aperti tutti i fronti invece di chiuderne uno. Quella scelta non si disfa e la mischia continuata a oltranza fa da base a quello che oggi ti riguarda.
- 3: Stare in attrito senza mai arrivare alla resa ti riesce da sé: è una pratica acquisita nella zuffa fra pari, che porta la tua questione senza chiedere permesso a nessuno.

## Sei di Bastoni

### dritta

- 1: Un lavoro portato a termine fa da base a quello che hai davanti: l'alloro legato in cima all'asta è stato messo lì da mani che non sono le tue e il cavallo cammina sopra quel peso.
- 2: La tua questione pesca in un terreno già lavorato: un'opera finita ha messo radice lì sotto e il suolo tiene su l'alloro che il corteo è venuto a guardare.
- 3: Una misura imparata nel reggere l'applauso sta sotto quello che hai in mano: il modo di stare in sella senza montarsi la testa è stato acquisito e lavora da sé.

### capovolta

- 1: Di lavoro finito è impastata la tua questione: quella materia, provata nel farla, la tiene su; l'alloro resta legato all'asta senza nessuno che cammini intorno.
- 2: Un mestiere acquisito regge quello che hai davanti anche a strada vuota: la mano che ha stretto l'asta sa già il peso del carico e il verdetto di chi guarda non entra in quel conto.
- 3: Quello che hai portato a termine fa da peso sotto la tua domanda: il cavallo cammina lo stesso, con l'alloro in cima all'asta e nessun corteo ai lati.

## Sette di Bastoni

### dritta

- 1: Sotto la tua questione sta un'altura già presa: il carico lo porta quel terreno conquistato, su cui una sola asta in mano basta a tenere a distanza le altre.
- 2: Un piede rimasto scalzo nella fretta della salita è il prezzo che la tua faccenda non si riprende: la cosa sta su quella scomodità pagata per arrivare in cima prima degli altri.
- 3: Nel terreno della tua questione la pendenza ha messo radice: il vantaggio sta dove il punto alto è stato preso per primo, dunque la cosa beve da quella posizione già occupata.

### capovolta

- 1: La sostanza di quello che hai davanti è un fronte allargato: chi tiene l'altura ha voluto coprire ogni lato della collina con due braccia sole, dunque la cosa poggia su quella larghezza.
- 2: Una guardia montata su ogni lato ha sbarrato la via del riposo: quella scelta già fatta regge la tua faccenda adesso, con le aste tenute tutte insieme da una presa sola.
- 3: Quello che il braccio sa fare con un'asta sola è un mestiere vecchio: parare è diventato riflesso, cosicché la tua questione si regge su una veglia che nessuno deve più ordinare.

## Otto di Bastoni

### dritta

- 1: Sotto la tua domanda c'è una spinta già data: le aste sono partite tutte nello stesso istante e la loro traiettoria porta adesso il peso di quello che hai davanti.
- 2: Un solo lancio è già stato pagato con tutta la mira di prima: quel colpo speso non si riprende e il volo parallelo delle aste regge quello che ti sta a cuore.
- 3: Le radici di quello che hai per le mani stanno in un braccio che si è già mosso: le aste viaggiano in aria senza essere spinte di nuovo e il terreno sorvolato fa da suolo alla tua questione.

### capovolta

- 1: Di un lancio dato troppo presto è impastato quello che hai davanti: le aste si sono incrociate a mezz'aria e quel groviglio compiuto porta adesso la tua questione.
- 2: Una partenza anticipata ha chiuso la possibilità di mirare meglio: quel gesto è andato e la tua domanda poggia su una rotta già storta, con il volo che continua comunque.
- 3: Hai preso l'abitudine alla fretta e quell'abitudine acquisita lavora da sé: sta sotto quello che hai davanti come un braccio che parte prima dell'occhio.

## Nove di Bastoni

### dritta

- 1: Reggere sotto pressione è una capacità che la tua questione ha già acquisito: la benda sulla testa ha insegnato la guardia; quella guardia lavora da sé e fa da appoggio al resto.
- 2: La tua domanda affonda in una fila di pali già piantati: ogni palo è entrato nel terreno con un colpo incassato; quel suolo ripetuto è quello che tiene su la cosa adesso.
- 3: Un prezzo in forze è stato versato prima di questo tratto: la fasciatura sulla fronte è la ricevuta di quella spesa; su di essa, non sulla stanchezza di oggi, la tua questione poggia.

### capovolta

- 1: Si è accumulata una riserva di colpi vecchi: quel deposito di cicatrici, messo da parte palo dopo palo, sta sotto la tua questione e le fa da appoggio quando qualcuno bussa.
- 2: Il peso che tiene su quello che hai davanti è una palizzata già chiusa: è stata alzata contro assalti veri; oggi la tua questione sta tutta su quel legno, chi bussa compreso.
- 3: Chiudere il varco è stata una scelta che non si disfa: da quando il paletto è calato, chi arriva passa dalla stessa fessura; su quella fessura la tua domanda si regge.

## Dieci di Bastoni

### dritta

- 1: Nelle braccia si è accumulata, un viaggio alla volta, una forza che non si è dispersa: su quella riserva la tua questione sta e da quella prende, col fascio stretto contro il petto.
- 2: Il fascio è stato legato stretto e quel nodo non torna in discussione: il resto della tua questione si muove, mentre quel peso sta fermo sotto e porta tutto il resto.
- 3: Un fascio di pali sollevato da terra e portato fin qui fa da appoggio a quello che hai davanti: la tua questione sta su quel carico, col paese in fondo che si vede già.

### capovolta

- 1: Il prezzo di questo trasporto è stato versato in passi, uno dietro l'altro: quella spesa chiusa tiene su la tua questione, mentre le braccia restano chiuse intorno a tutto il fascio.
- 2: Battuto fin qui, il sentiero è il suolo in cui questo carico ha messo radice: da quel terreno la tua questione beve ancora e su quelle radici posa, a pochi passi dalle case.
- 3: Di abitudine e di legno è impastato quello che hai davanti: la materia è quella che le braccia hanno già stretto; su quel legame di corda la tua questione poggia tutta.

## Fante di Bastoni

### dritta

- 1: Si è messa da parte una scorta di curiosità mai spesa: quel ramo con le foglie nuove, tenuto in mano prima di partire, non si è disperso e sostiene quello che oggi hai davanti.
- 2: Una partenza resta fuori discussione nella tua questione: il piede è già a terra e lo sguardo è andato in cima al ramo. Quel punto fissato tiene su tutto quello che si muove intorno.
- 3: Sotto la tua domanda sta una notizia portata fin qui da chi ancora imparava a portarla: quel messaggio consegnato con slancio fa da appoggio a quello che adesso ti sta davanti.

### capovolta

- 1: Hai pagato molte partenze in slancio e in attenzione, una dopo l'altra, senza arrivare al frutto: quel conto di rami lasciati a metà non si riprende e tiene su la tua questione.
- 2: La tua questione è piantata in un terreno dove ogni germoglio è stato scalzato dal successivo: quella radice corta ha già bevuto quello che c'era e regge comunque il resto.
- 3: Quello che oggi hai davanti è impastato di cose cominciate: una pila di inizi accesi, poi posati prima del tempo. La tua questione è fatta di quella stoffa e non poggia su altro.

## Cavaliere di Bastoni

### dritta

- 1: Uno slancio è già stato speso per salire in sella: quella spesa sta sotto la tua questione e il cavallo impennato porta avanti il moto che ha ricevuto una volta.
- 2: Di fuoco già messo in moto è fatta la tua questione: la stoffa è quella delle salamandre cucite sulla tunica, provata al galoppo; quel materiale tiene su quello che hai davanti.
- 3: L'ardore accumulato da prima della tua domanda non si è disperso: resta una scorta da cui la cosa attinge senza permesso; il deserto davanti al cavallo è largo e la riserva tiene.

### capovolta

- 1: Una corsa lanciata senza rotta è un atto compiuto che non si riavvolge: la tua questione sta su quel terreno percorso in fretta e il cavallo tiene l'andatura che gli è stata data.
- 2: Quello che resta sotto la tua domanda è un fondo di ardore bruciato a briglia sciolta: la riserva si è assottigliata nella corsa e il poco accumulato regge ancora la sella.
- 3: Il prezzo di una partenza data prima della mappa è stato pagato in strada sbagliata: la tua questione poggia su quella spesa e la piuma sull'elmo è ancora al suo posto.

## Regina di Bastoni

### dritta

- 1: Sotto la tua domanda sta un calore che nessuno ha disperso: il girasole tenuto in mano ha raccolto sole per stagioni, cosicché la cosa attinge a quella provvista senza dover domandare nulla.
- 2: L'elemento che nella tua questione nessuno rimette in discussione è un modo di stare al mondo: il seggio coi leoni è stato preso una volta, dunque quel posto regge quanto hai davanti.
- 3: Il peso di quello che hai davanti lo porta una presenza riconosciuta da tutti: il gatto nero seduto ai piedi del seggio non si è mosso di lì, dunque quel posto regge la cosa.

### capovolta

- 1: Un confronto pagato con la luce di qualcun altro è la spesa chiusa su cui la tua questione si appoggia: il girasole si è voltato verso un fuoco non suo, dunque quel costo regge la cosa.
- 2: Nel suolo della tua faccenda ha messo radice un paragone: il seggio coi leoni è rimasto occupato, mentre la pianta beve da un dubbio piantato sul proprio valore.
- 3: La tua questione è impastata di calore trattenuto: una fiamma coperta dalla mano di chi l'ha portata fin qui regge la cosa, perché quel riparo non è stato ancora aperto.

## Re di Bastoni

### dritta

- 1: Sotto la tua questione sta un deposito di fuochi accesi altrove: la mano che regge l'asta fiorita piantata a terra pesca da quella riserva di cose portate a termine.
- 2: Il punto che non torna in discussione è l'autorità già riconosciuta: il seggio con le salamandre è stato occupato per meriti veri e regge quello che hai per le mani.
- 3: L'autorevolezza di chi ha acceso altri fuochi prima di questo porta quello che ti riguarda: la mantella con le salamandre è già addosso e quel peso indossato fa da appoggio.

### capovolta

- 1: Un conto è già stato chiuso in fretta: ordini dati dal seggio senza aspettare risposta. Quel prezzo, versato in ascolto mancato, tiene su quello che hai davanti.
- 2: La tua questione è piantata in un suolo scaldato troppo: l'asta fiorita è stata usata per spingere invece che per indicare e quella radice bruciata la sostiene ancora.
- 3: Di impazienza d'alto rango è impastato quello che hai per le mani: una volontà già messa in opera, buona a partire e scarsa ad attendere; su quella materia la cosa posa.

## Asso di Coppe

### dritta

- 1: Sotto la tua questione c'è una sorgente che ha già cominciato a versare: i rivoli caduti nello stagno hanno bagnato il terreno e da quell'acqua la cosa prende quello che la tiene su.
- 2: Che il sentimento ci sia non è più in discussione: la coppa si è riempita fino al bordo prima della tua domanda; quel pieno è il punto fermo su cui tutto il resto si appoggia.
- 3: Di acqua viva è impastato quello che hai davanti: la materia della tua questione è stata versata dall'alto dalla nube, non costruita a mano; su quella sostanza la cosa sta in piedi.

### capovolta

- 1: Un coperchio posato sulla sorgente è il peso che sta sotto la tua questione: è andato al suo posto prima della domanda; quello che hai davanti si tiene su quel silenzio d'acqua.
- 2: Il prezzo di non sentire è già stato versato per intero: quella moneta, pagata goccia a goccia fuori dal bordo, non si riprende; su di essa la tua questione poggia adesso.
- 3: Trattenere l'acqua è diventata una pratica che non chiede più fatica: si è imparata prima di questa domanda e lavora da sé; la tua questione sta su quella mano chiusa sopra la coppa.

## Due di Coppe

### dritta

- 1: Un patto siglato alla pari ha chiuso le altre vie: quelle due mani allungate insieme una volta stanno sotto la tua questione e quello che hai davanti poggia su quel sigillo.
- 2: Reggere un calice e porgerlo alla stessa altezza è cosa che le due mani hanno già imparato: quel mestiere lavora da sé e tiene su la tua questione dal basso.
- 3: Nelle due palme è rimasto il credito di uno scambio già fatto alla pari: la tua questione attinge da quella riserva e su di essa continua a stare, col leone alato sopra.

### capovolta

- 1: Dato una volta, il sigillo non torna in discussione: dentro la tua questione si muove l'altezza dei due calici, mentre quel patto sta fermo sotto e sorregge il resto.
- 2: Due vasi tenuti da mani diverse stanno sotto quello che hai davanti: la tua questione pesa su quello scambio avvenuto, anche quando i polsi non sono alla stessa quota.
- 3: Il pegno è stato dato dalle due parti e nessuna lo riprende: su quel doppio impegno posa quello che hai davanti, coi calici tenuti a due altezze che non coincidono.

## Tre di Coppe

### dritta

- 1: Hai scelto una volta chi tenere vicino e quella porta non si riapre su tutti gli altri: i tre calici toccati in cerchio restano l'appoggio della tua questione.
- 2: Alzare il bicchiere con chi ti vuole bene ti riesce senza che sia da imparare di nuovo: quella capacità acquisita nel cerchio delle amicizie porta oggi la tua questione.
- 3: Si è accumulata una riserva di compagnia che non hai dato via: brindisi ricambiati, mani toccate in cerchio. Quella scorta non si disperde e sostiene quello che oggi ti riguarda.

### capovolta

- 1: Non si rimette in gioco, nella tua questione, l'ampiezza del cerchio: è stato allargato a molti e i bicchieri sono stati contati. Quel dato già fermo tiene su il resto.
- 2: Sotto quello che hai davanti sta un cerchio cresciuto più delle mani che lo reggono: molti bicchieri sono stati alzati per cortesia. Quel peso fa da appoggio alla tua questione.
- 3: Hai pagato in tempo e in presenza una compagnia larga che non ricambia alla pari: quel prezzo versato ai brindisi di facciata tiene su adesso la tua questione.

## Quattro di Coppe

### dritta

- 1: Una sazietà raggiunta non si rimette in gioco: resta il punto fermo sotto la tua questione, con i calici posati a terra accanto alle braccia incrociate e l'albero che fa ombra sopra.
- 2: Pienezza bevuta fino in fondo: il conto di quel sorso è stato chiuso e la tua questione sta su di esso, mentre la mano che tende un altro calice resta al margine dello sguardo.
- 3: Il rifiuto dato una volta ha chiuso la porta a quello che arrivava: quella scelta compiuta tiene su la tua questione e le braccia restano incrociate sotto l'albero.

### capovolta

- 1: La tua domanda pesca in un torpore attraversato fino al fondo: quel fondo toccato ha messo radice e tiene su la curiosità di adesso, come un albero che ha bevuto anche nella stagione secca.
- 2: Aprire le braccia è stato un gesto fatto una volta e quella porta non si richiude: la tua questione poggia su quell'apertura, col calice teso finalmente preso in mano.
- 3: Quello che hai già sentito tornare non è più in discussione: fa da punto fermo sotto la cosa, mentre i calici a terra restano dove erano e l'albero fa la stessa ombra.

## Cinque di Coppe

### dritta

- 1: Un mantello nero indossato ha tolto dal tavolo le altre maniere di guardare: la tua questione poggia su quello sguardo scelto, rivolto alle coppe per terra invece che al ponte.
- 2: Quello che l'occhio ha appreso guardando il terreno bagnato è un sapere acquisito: contare le coppe versate non costa più nulla, dunque la tua faccenda si appoggia su questa esattezza.
- 3: Dietro le spalle è rimasto un deposito che nessuno ha versato: due coppe piene stanno ancora in piedi, dunque la tua questione attinge a quella riserva mai toccata.

### capovolta

- 1: L'unico elemento fuori discussione nella tua domanda è il conto del rimasto: le coppe ancora in piedi sono state contate, dunque quel numero tiene fermo mentre il resto si muove.
- 2: Il carico della tua faccenda lo porta un collo che si è già girato: lo sguardo spostato dal terreno bagnato al ponte è il gesto compiuto che oggi sostiene quanto hai davanti.
- 3: Una fatica spesa nel voltarsi è il versamento che non si riprende: la tua questione sta su quel movimento pagato, perché girare il capo verso il ponte è costato più che restare fermi.

## Sei di Coppe

### dritta

- 1: Una tenerezza data senza contare ha chiuso la strada del calcolo: il fiore bianco porto da una mano piccola nel cortile è già passato di mano e quel dono regge la tua questione.
- 2: Hai imparato presto a offrire senza chiedere in cambio e quella capacità acquisita lavora da sé sotto la tua domanda, come un gesto da bambini che nessuno ha corretto.
- 3: Sotto quello che ti riguarda si è depositato un affetto antico: i vasi pieni di fiori bianchi nel cortile del borgo sono stati riempiti tempo fa e la cosa pesca ancora da quella scorta.

### capovolta

- 1: Il punto che resta fuori discussione è un indirizzo vecchio: il cortile dei primi anni è stato tenuto come residenza attuale e quel fatto compiuto sta sotto la tua questione.
- 2: Sostiene quello che hai davanti un peso dolce: fiori secchi conservati nei vasi, un ricordo scelto a suo tempo come appoggio che quel servizio continua a svolgere.
- 3: Un prezzo è stato pagato al passato con moneta di adesso: la tenerezza di allora è stata ricomprata e la tua domanda poggia su quella spesa, fatta in buona fede.

## Sette di Coppe

### dritta

- 1: Di immagini sospese è fatta la tua questione: le coppe nella nuvola sono state riempite dal desiderio, non dal mondo; quella materia leggera porta su di sé quello che hai davanti.
- 2: Guardare la nuvola invece del terreno è stata una scelta già fatta: da quel momento una via sola è rimasta aperta; su quella via la tua domanda si tiene in piedi.
- 3: Si è accumulata una scorta di possibilità mai aperte: quel deposito, cresciuto coppa dopo coppa davanti alla figura di spalle, sta sotto la tua questione e la regge intera.

### capovolta

- 1: Una coppa fra le tante non si rimette più in gioco: è stata presa dalla nuvola prima della tua domanda; mentre il resto galleggia, quel pieno scelto fa da punto fermo.
- 2: Distinguere una promessa vera da un drappo lucido è una capacità già acquisita: è venuta dalle coppe guardate una per una e oggi tiene su quello che hai davanti senza sforzo.
- 3: La tua questione affonda in un terreno scelto: il piede è sceso dalla nuvola e si è piantato in un suolo solo; quella terra bevuta è quello che regge la cosa adesso.

## Otto di Coppe

### dritta

- 1: L'altura dove il piede è salito ha un terreno che la tua questione ha già bevuto: su quelle radici quello che hai davanti sta, mentre una fila ordinata resta in basso.
- 2: Di una rinuncia compiuta è impastato quello che hai davanti: quella è la materia su cui la tua questione posa, coi vasi pieni ordinati alle spalle e il passo rivolto in alto.
- 3: Voltare le spalle a una fila ordinata è stata una scelta che non si disfa: quel gesto compiuto sta sotto la tua questione e la tiene su, con la luna sopra il crinale.

### capovolta

- 1: Stare su una soglia con un piede fuori è cosa che il corpo ha già appreso: quel sapere lavora da sé sotto la tua questione, coi vasi pieni rimasti alla stessa distanza.
- 2: Nei calici rimasti dietro c'è una riserva che nessuno ha versato: da quel deposito la tua questione attinge ancora e su di esso posa, col piede fermo sullo stipite.
- 3: Il primo passo è già stato dato e questo non torna in discussione: dentro la tua questione si muove tutto tranne quello, che sta fermo sotto come appoggio.

## Nove di Coppe

### dritta

- 1: La tua questione è piantata in un desiderio detto e già esaudito: le coppe allineate sulla panca hanno bevuto quel voto e da quella radice regge tutto il resto.
- 2: Quello che hai davanti è impastato di una sazietà raggiunta: le braccia conserte, la tavola ripulita fino in fondo. Quella sostanza piena sorregge adesso la tua questione per intera.
- 3: Hai chiesto una cosa sola e l'hai avuta alla lettera. Quella scelta non si disfa e il contento già servito sulla panca poggia sotto la tua questione come un appoggio pieno.

### capovolta

- 1: Riempire le coppe fino all'orlo ti riesce da prima di questa domanda: è un mestiere imparato bene. La tua questione sta su quella bravura acquisita, non sulla sete rimasta sotto.
- 2: Si è accumulato un deposito di piaceri già bevuti che non ti ha lasciato niente da parte: quelle coppe svuotate sulla panca non si disperdono e sorreggono quello che hai davanti.
- 3: Una cosa nella tua questione non torna in discussione: il conto del banchetto è stato pagato e l'ordine è stato servito. Quel fatto fermo tiene su quello che ancora si muove.

## Dieci di Coppe

### dritta

- 1: Un modo di stare insieme imparato giorno per giorno sta sotto la tua questione: non si deve più conquistare e lavora da sé, come l'arco di calici che resta acceso sopra il tetto.
- 2: Il legame tenuto fin qui non si rimette in gioco: resta l'elemento fermo sotto quello che hai davanti, mentre i bambini ballano nel prato e i due adulti guardano l'arco in cielo.
- 3: La casa poggia su una radice d'affetto già bevuta a lungo: quel suolo tiene su la tua questione e il fiume che passa accanto al tetto non ha dovuto cambiare letto.

### capovolta

- 1: Di un'armonia data per fatta è impastata la tua questione: quella materia tiene su il tetto; sotto lo stesso arco di calici ognuno ha preso una direzione sua.
- 2: Un galateo di famiglia imparato da prima regge quello che hai in mano: i gesti sanno andare avanti da sé e la distanza fra le persone di casa sta sotto l'arco intatto.
- 3: Quello che tiene su la tua questione è un tetto costruito e abitato: il peso della casa sta sotto, coi calici in cielo e ognuno che ha scelto la sua stanza.

## Fante di Coppe

### dritta

- 1: Nel fondo della tua questione ha messo radice una cosa viva già affiorata: dalla coppa tenuta in mano è spuntato un pesce, dunque quanto hai davanti beve da quell'acqua.
- 2: La materia della tua faccenda è una sensibilità giovane: ha portato fin qui il calice senza sapere cosa ci fosse dentro, dunque l'acqua dolce raccolta regge quanto hai davanti.
- 3: Una coppa accettata dalle mani di qualcuno ha chiuso la via del non sapere: su quel gesto compiuto la tua questione poggia, col pesce fuori dall'acqua a fissare chi lo tiene.

### capovolta

- 1: Quello che le dita hanno appreso sul coprire l'apertura di un calice è diventato abitudine: su quel riparo automatico la tua domanda si appoggia, col pesce rimasto giù nel fondo.
- 2: Sotto la tua questione si è raccolta acqua che nessuno ha versato fuori: il calice messo giù a bocca in su ha preso dentro senza mai offrire, dunque la cosa pesca da quel pieno fermo.
- 3: L'elemento della tua domanda che non si discute più è il pesce rimasto nel fondo: guardato una volta sola, quel riserbo sostiene la cosa mentre tutto intorno a lui cambia posto.

## Cavaliere di Coppe

### dritta

- 1: La tua questione affonda in un terreno di cortesia: un calice è stato portato a mano fino a destinazione, il cavallo al passo ha già coperto la strada e quel suolo la nutre da sotto.
- 2: Di che materia è quello che hai per le mani: di un'offerta consegnata di persona. Chi aveva le ali sull'elmo si è mosso per primo e quella stoffa gentile fa da base alla cosa.
- 3: Una proposta avanzata a braccio teso ha chiuso la strada del tenersi al coperto: quel gesto compiuto non si disfa e la tua domanda sta su quella esposizione.

### capovolta

- 1: Hai imparato a dire bene le cose e quella bravura lavora da sé sotto la tua questione: il calice è rimasto teso in mano mentre il cavallo non ha mosso un passo.
- 2: Sotto quello che ti riguarda si è accumulato un magazzino di promesse belle: ognuna detta con grazia dal dorso del cavallo, nessuna scesa fino a destinazione; la cosa posa su quel mucchio.
- 3: Il punto che non si rimette in gioco è la grazia del modo: il calice è stato teso con bellezza e quel gesto compiuto tiene su la tua domanda, mentre il passo che doveva seguirlo resta sospeso.

## Regina di Coppe

### dritta

- 1: Leggere quello che un altro non dice è una competenza che non si riconquista più: si è formata guardando a lungo dentro la coppa chiusa; lavora da sé e tiene su la tua questione.
- 2: Si è depositata una riserva di tenerezza raccolta sulla riva, ciottolo per ciottolo: quella scorta non si è dispersa e sta sotto quello che hai davanti, portandone il peso.
- 3: Il peso sotto la tua domanda è una sensibilità già esercitata: il trono posato dove l'acqua arriva è rimasto lì; su quella pietra bagnata la questione sta in piedi oggi.

### capovolta

- 1: Un prezzo in sentire è già stato versato per gli altri: quella spesa, fatta a coppa aperta sulla riva, non si riprende; la tua questione sta su di essa come su un conto chiuso.
- 2: Di acqua d'altri è fatta la materia che hai davanti: è entrata nella coppa aperta prima di questa domanda e non è stata separata; su quella mescolanza la cosa si tiene.
- 3: Tenere la coppa aperta a chiunque è stata una scelta che ha chiuso le altre: da allora il proprio stato d'animo passa per ultimo; su quella porta chiusa la tua questione poggia.

## Re di Coppe

### dritta

- 1: Un trono di pietra posato dentro l'acqua mossa sta sotto quello che hai davanti: la tua questione sta su quel blocco già fermo, col calice tenuto saldo nel palmo.
- 2: Il prezzo della calma è stato pagato in mareggiate attraversate: quel conto chiuso tiene su la tua questione e la mano che porge il bicchiere non trema per questo.
- 3: Sotto il trono il fondale è stato scelto una volta e tiene: da quella pietra sommersa la tua questione prende appoggio, col pesce che salta a filo d'acqua.

### capovolta

- 1: Di acqua e di pietra insieme è impastato quello che hai davanti: la materia è quella di un governo già costruito; il livello dentro il calice lo decide l'onda.
- 2: Mettere un trono in mezzo al mare è stata una scelta che non si rifà: quella pietra posata sta sotto la tua questione mentre lo scettro resta in mano e l'umore detta la misura.
- 3: Una maturità affettiva appresa da tempo lavora da sé sotto quello che hai davanti: quel mestiere tiene su la tua questione nel giorno in cui a dare la misura è l'umore e non lo scranno di pietra.

## Asso di Denari

### dritta

- 1: Sotto la tua questione sta una cosa concreta già consegnata: una moneta intera, posata nella mano sopra il giardino murato. Quel peso d'oro la tiene su per intera, da solo.
- 2: Hai versato una somma vera per avere questo in mano, non una promessa: quel pagamento fatto una volta non si riprende e sorregge adesso la tua questione come un fondo pieno.
- 3: La tua questione è piantata in un terreno preparato prima della domanda: il seme d'oro è stato messo sotto nell'orto chiuso e quella radice nutre tutto quello che sta su.

### capovolta

- 1: Quello che hai davanti è impastato di un valore ricevuto e tenuto fermo: una moneta chiusa nel pugno, mai piantata nell'orto. Quella materia sola sostiene la tua questione.
- 2: Hai deciso una volta di non muovere quel pezzo d'oro e da quella decisione non si torna: il cancello del giardino resta dove è stato lasciato e la tua questione poggia lì.
- 3: Guardare una moneta senza spenderla ti riesce senza fatica da prima di questa domanda: quella pratica acquisita lavora da sé sotto la tua questione e la tiene dove sta.

## Due di Denari

### dritta

- 1: Un allenamento è già stato speso per tenere due pesi in aria insieme: quella spesa sta sotto la tua questione e il nastro che li lega continua a girare sopra il mare mosso.
- 2: Di flessibilità messa alla prova è fatta la tua questione: quella materia ha già tenuto il beccheggio delle due navi e adesso regge quello che hai davanti.
- 3: Una riserva di prontezza accumulata senza sprecarla sta sotto quello che hai in mano: la cosa attinge là il ritmo con cui i due dischi continuano a girare nel nastro.

### capovolta

- 1: Un numero di cose preso in mano una volta non si disfa da sé: quella scelta tiene su la tua questione e il nastro fra i due dischi gira adesso a tempo rotto.
- 2: Quello che resta sotto la tua domanda è una scorta di destrezza assottigliata nel reggere troppo insieme: quel fondo tiene ancora e le due navi beccheggiano più alte del solito.
- 3: Il prezzo di aver detto sì a tutto è stato pagato in attenzione divisa: la tua questione sta su quella spesa e un disco gira ancora mentre l'altro pende dalla mano.

## Tre di Denari

### dritta

- 1: Sotto la tua questione sta un arco già montato: il peso lo portano tre mestieri diversi che si sono messi d'accordo sopra una panca, non una spalla sola.
- 2: Una competenza pagata con anni di scalpello è il conto chiuso su cui la tua faccenda si appoggia: la mano che ha imparato a tagliare la pietra tiene su il lavoro comune adesso.
- 3: Nel terreno della tua questione ha messo radice un disegno già approvato: il foglio mostrato sulla panca regge la cosa, perché da quel tracciato ogni mano beve la sua parte.

### capovolta

- 1: La sostanza della tua questione è un cantiere aperto: l'arco è montato a metà e nessuno ha scritto chi taglia la pietra e chi tiene il foglio, dunque la cosa poggia su quel vuoto.
- 2: Un ruolo mai assegnato ha sbarrato la via della consegna: su quella casella rimasta vuota la tua faccenda poggia, con l'arco sopra la panca fermo in attesa della mano giusta.
- 3: Quello che le spalle hanno appreso sul coprire il compito di un altro non si disimpara: su quel supplire silenzioso la tua questione si appoggia, mentre l'arco sopra la panca attende.

## Quattro di Denari

### dritta

- 1: Sotto la tua questione c'è una riserva messa al sicuro: le braccia si sono chiuse attorno a un disco di metallo e i piedi stanno posati su altri due. Quel blocco regge il resto.
- 2: Un risparmio già fatto non si riprende da sé: quello che hai messo al sicuro è stato sottratto a qualcos'altro e quella sottrazione, pesante come una corona di metallo sul capo, tiene su la tua domanda.
- 3: Le radici di quello che hai davanti stanno dentro le mura di una città che era già in piedi: il disco stretto al petto è stato guadagnato là e quel suolo murato sostiene la cosa.

### capovolta

- 1: Di paura di perdere è impastata la tua questione: le dita si sono chiuse sul metallo fino a diventare postura e quella materia rigida tiene ancora sotto quello che hai davanti.
- 2: Una decisione presa tempo fa ha chiuso le porte del dare: trattenere. Quell'atto compiuto non si disfa e la tua domanda poggia su di esso come su un muro senza finestre.
- 3: Hai imparato a misurare ogni cosa in quello che si può perdere e quella competenza lavora da sé: sta sotto la tua questione come un conto che nessuno ti ha chiesto.

## Cinque di Denari

### dritta

- 1: Un conto è già stato pagato in freddo davanti alla vetrata accesa: quella spesa non si riprende; su di essa, non sulla neve di stasera, la tua questione sta in piedi.
- 2: Sotto la tua domanda c'è un terreno gelato in cui la cosa è stata piantata: la neve battuta davanti alla porta chiusa è il suolo da cui prende tutto quello che la regge.
- 3: Che la porta sia rimasta chiusa non è più in discussione: le monete illuminate stanno dentro il vetro da prima di questa domanda; quel vetro fa da punto fermo a quello che hai davanti.

### capovolta

- 1: Si è messo da parte un sostegno trovato nel gelo: quel deposito di mani tese, raccolto fuori dalla vetrata, sta sotto la tua questione e la porta adesso che il vetro è dietro.
- 2: Il peso che tiene su quello che hai davanti è una soglia già attraversata: il passo dentro il tiepido è stato fatto prima della domanda; su quella pietra d'ingresso la cosa sta.
- 3: Chiedere senza vergogna è diventata una capacità acquisita nel freddo: non si riconquista a ogni inverno, lavora da sé e fa da appoggio alla tua questione.

## Sei di Denari

### dritta

- 1: Nel palmo che distribuisce è rimasta una riserva messa da parte prima di questa domanda: la tua questione attinge da quel fondo e su di esso posa, con la bilancia tenuta alta.
- 2: Il braccio della bilancia è stato pareggiato e quella misura non torna in discussione: nella tua questione si muovono le monete, mentre il peso giusto sta fermo e regge dal basso.
- 3: Due ginocchia già a terra e una mano che conta sopra di loro: quello scambio avvenuto sta sotto la tua questione e la tiene su, con la misura decisa prima del dono.

### capovolta

- 1: Il dono è stato versato per intero e non rientra: su quella spesa fatta poggia quello che hai davanti, col braccio della bilancia rimasto basso da un lato solo.
- 2: Sotto lo scambio c'è un terreno di crediti aperti, concimato da monete già passate di mano: da quelle radici la tua questione beve e su quelle sta in piedi.
- 3: Di promesse e di metallo è fatta la tua questione: quella materia è stata impastata prima della domanda e regge ancora, mentre una delle ciotole tese resta più vuota dell'altra.

## Sette di Denari

### dritta

- 1: Si è accumulato nel cespuglio quello che le tue mani hanno zappato: una riserva di frutti non ancora staccati, che non si disperde e sorregge quello che oggi ti riguarda.
- 2: Una sola cosa non si rimette in gioco nella tua questione: la semina è stata fatta e il manico della zappa riposa. Quel punto già fissato tiene su l'attesa di tutto il resto.
- 3: Sotto quello che hai davanti sta un lavoro già fatto e visibile: il pollone cresciuto di una mano, i denari sospesi fra le foglie. Quel peso maturato tiene su la tua questione.

### capovolta

- 1: Hai pagato in giornate di zappa un raccolto staccato prima del tempo: quel prezzo versato nel campo non si riprende e tiene su adesso la tua questione.
- 2: La tua questione è piantata su un seme scelto in fretta: il terreno ha già bevuto quella scelta e la radice venuta su regge tutto quello che adesso guardi dal manico.
- 3: Quello che hai davanti è impastato di impazienza e di frutti toccati verdi: la tua questione è fatta di quella materia e sta sul conto fra lo sforzo messo e quello che il ramo ha reso.

## Otto di Denari

### dritta

- 1: Una pila di pezzi incisi uno dopo l'altro resta appesa al muro del banco: quel deposito sta sotto la tua questione e la cosa pesca là la mano ferma di cui ha bisogno.
- 2: Il peso sotto la tua domanda è un mestiere già fatto col martello: le ore passate al banco tengono su quello che hai davanti senza chiedere di essere rifatte.
- 3: Di gesti ripetuti fino a venire bene è impastato quello che hai in mano: quella materia, provata su un disco per volta, regge la tua questione come il legno regge lo scalpello.

### capovolta

- 1: Un peso di colpi uguali, battuti uno dopo l'altro, sta sotto la tua questione: il banco tiene su il lavoro e i pezzi identici restano appesi al muro dove sono stati messi.
- 2: Della stessa materia di un gesto ripetuto è fatto quello che hai davanti: quella stoffa tiene su il lavoro; il senso che aveva messo in mano lo scalpello non è dentro il colpo.
- 3: Quello che la tua questione ha sotto è una scorta di abitudine accumulata al banco: il gesto si è depositato nella mano e continua a incidere lo stesso disco senza che nessuno glielo chieda.

## Nove di Denari

### dritta

- 1: Sotto la tua domanda sta la provvista di molte stagioni: la vigna cresciuta dietro il muro ha dato raccolti che nessuno ha disperso, dunque la cosa attinge a quella scorta propria.
- 2: L'unico elemento che nella tua questione non torna in discussione è il recinto: il muro del giardino è stato tirato su una volta sola, dunque quel confine regge quanto hai davanti.
- 3: Il peso della tua faccenda lo porta un guanto cucito tempo addietro: il falcone si posa lì senza catena, dunque sotto la cosa sta una pazienza tenuta per anni dentro un giardino chiuso.

### capovolta

- 1: Una spesa fatta per mostrare il giardino è il versamento che non torna indietro: la tua questione sta su quel pagamento, perché la veste è costata più di quanto la vigna abbia reso.
- 2: Nel suolo della tua faccenda ha messo radice una solitudine scelta: il muro alzato attorno alla vigna regge la cosa, mentre il falcone incappucciato sta fermo sul guanto.
- 3: La tua questione è impastata di indipendenza: la materia non è la mancanza, è una libertà costruita a mano che oggi poggia sulle stesse spalle che l'hanno tirata su.

## Dieci di Denari

### dritta

- 1: Sotto la tua questione si è depositato il lavoro di chi c'era prima: le monete disposte sull'arco di casa sono state contate da altre mani e la cosa pesca ancora da quella scorta.
- 2: Il punto che non torna in discussione è la casa: lo stemma sul muro è stato dipinto prima della tua domanda, i cani stanno ai piedi del vecchio sotto l'arco e quel nome regge il resto.
- 3: Sostiene quello che hai davanti un patrimonio di famiglia già formato: muri alzati, vigne piantate, un cortile dove si passa senza chiedere permesso. Quel peso antico tiene su la tua questione.

### capovolta

- 1: Un conto di famiglia è già stato aperto e nessuno lo ha chiuso: beni comuni contati una moneta per volta sotto lo stesso stemma. Quella contabilità regge la tua questione.
- 2: La tua domanda affonda in un terreno diviso per quote: la vigna è stata piantata da uno solo e raccolta da molti; da quella radice contesa la cosa prende quello che la tiene in piedi.
- 3: Di roba che appartiene a più di uno è fatta la tua questione: un bene già diventato comune, con l'attrito cucito dentro; su quella stoffa tutto posa.

## Fante di Denari

### dritta

- 1: Quello che hai già imparato su questa cosa non si deve più conquistare: la moneta è stata girata fra le dita fino a conoscerla; quella conoscenza regge la tua domanda.
- 2: Di materia concreta è fatta la tua questione: non un'idea, ma un oggetto preso in mano sopra un campo già arato; quella sostanza porta su di sé quello che hai davanti.
- 3: Mettere le due mani su una cosa sola è stata una scelta che ha chiuso le altre: da allora gli occhi stanno lì; su quella porta chiusa la tua domanda si tiene in piedi.

### capovolta

- 1: La tua questione affonda in un campo arato e mai seminato: il solco è stato aperto prima di questa domanda e la terra è rimasta scoperta; su quel suolo la cosa si tiene.
- 2: Un impegno preso resta fuori discussione: la parola è stata data con la moneta ancora fra le mani e nessuno la rimette in gioco; su quella parola ferma quello che hai davanti poggia.
- 3: Il tempo già speso a rigirare la moneta fra le dita è una spesa chiusa: non torna indietro; la tua questione sta su quel conto, non sul solco che attende il seme.

## Cavaliere di Denari

### dritta

- 1: Scegliere un solco e non cambiarlo è un atto che non si disfa: quel tracciato sta sotto la tua questione e la tiene su, col palmo aperto che porta una moneta sola.
- 2: Un passo misurato, imparato una volta per sempre, lavora da sé: la tua questione poggia su quel mestiere, con l'animale pesante che mette un piede davanti all'altro senza fretta.
- 3: Nel campo arato dietro le zampe è rimasto tutto il lavoro di una stagione: da quel deposito la tua questione attinge e su di esso sta, con l'armatura opaca di polvere.

### capovolta

- 1: Il solco è stato tracciato e quello non torna in discussione: dentro la tua questione si muove l'ora del passo, mentre la linea sul campo sta ferma e porta il resto.
- 2: Quattro zampe ferme a terra reggono tutto il peso di quello che hai davanti: la tua questione sta su un animale già bardato, con la moneta tenuta sul palmo come allora.
- 3: La prudenza è stata pagata in tappe rimandate e quel conto è chiuso: su quella spesa poggia la tua questione, con la strada tracciata che resta sotto gli zoccoli.

## Regina di Denari

### dritta

- 1: Hai messo una volta la cura al posto dell'ambizione e quella porta non si riapre: su quella scelta, con la moneta tenuta in grembo come una cosa viva, la tua questione poggia.
- 2: Tenere insieme i conti di casa e la tavola apparecchiata ti riesce senza pensarci: quel mestiere acquisito fra le rose del pergolato porta oggi la tua questione sulle spalle.
- 3: Si è riempita una dispensa, cosa per cosa, con le mani nella terra e nei conti di casa: quella provvista già messa da parte fa da base a tutto quello che adesso ti riguarda.

### capovolta

- 1: Una cosa è fissata e non torna in discussione: la lista dei bisogni da coprire è stata fatta senza il tuo nome dentro. Quel dato fermo sorregge la tua questione per intera.
- 2: Sotto la tua questione sta una provvista distribuita a tutti e già finita: la dispensa aperta per gli altri, il giardino annaffiato fino all'ultimo filare. Quel peso la tiene su.
- 3: Hai pagato in pasti, in conti e in bisogni coperti una cura che non è tornata indietro: quel prezzo materiale versato per intero fa da appoggio a quello che oggi ti sta davanti.

## Re di Denari

### dritta

- 1: Una via scelta e tenuta fino al raccolto ha chiuso le altre: quella decisione compiuta regge la tua questione e il grappolo maturo pende sul trono dove sono scolpiti i tori.
- 2: Il raccolto accumulato nel giardino murato non si è disperso: la tua questione pesca là senza chiedere permesso e il castello sulla collina resta in piedi sopra quella riserva.
- 3: Potature e vendemmie sono già state pagate in fatica: la tua questione sta su quella spesa e la mano che tiene il disco inciso sa quanto è costata la vigna attorno al trono.

### capovolta

- 1: Un raccolto già chiuso nel magazzino non si rimette in gioco: resta il pezzo fermo sotto la tua questione, mentre la mano sul grappolo si è fatta più stretta del muro del giardino.
- 2: Il prezzo della vigna è stato pagato per intero e il titolo è in mano: la tua questione poggia su quel possesso, col cancello del giardino chiuso sopra il raccolto.
- 3: Tenere tutto dentro il muro è stata una scelta compiuta e quella porta non si riapre da sé: la tua questione sta su di essa e i tori scolpiti reggono il trono senza muoversi.

## Asso di Spade

### dritta

- 1: Un taglio già fatto ha tolto dal tavolo le altre letture possibili: la tua questione poggia su quella separazione netta, col filo passato una volta sola fra il vero e il resto.
- 2: Quello che il polso ha appreso sul tenere il filo diritto è ormai un possesso: tagliare il vero dal resto non richiede più sforzo, cosicché la tua faccenda si appoggia su quella fermezza.
- 3: Sotto la tua domanda si è sedimentata una chiarezza intatta: la corona infilata sulla punta è rimasta lì, dunque la cosa attinge a un giudizio formulato una volta per tutte.

### capovolta

- 1: L'unica cosa fuori discussione nella tua domanda è che un taglio è stato fatto: il colpo è partito e quel fatto tiene, mentre resta in gioco da quale lato cadeva il filo.
- 2: Il carico della tua faccenda sta su una lama impugnata dalla parte del filo: la presa è stata chiusa così tempo addietro, dunque la cosa poggia su una mano che sanguina.
- 3: Una parola detta col filo in avanti è il prezzo già versato su cui la tua questione poggia: quel colpo non si ritira, dunque la cosa sta su una chiarezza che è costata un legame.

## Due di Spade

### dritta

- 1: Una scelta è già stata fatta, quella di non guardare: la benda è stata annodata da te e le due lame restano in pari sul petto. Quell'equilibrio comprato sostiene la tua questione.
- 2: Hai imparato a tenere in pari due pesi senza aprire gli occhi e quella bravura lavora da sé: sta sotto la tua domanda come due braccia che hanno preso la posizione e la mantengono.
- 3: Sotto quello che ti riguarda si è accumulato tutto quello che non è stato guardato: un deposito di rinvii, fermo come il mare dietro le rocce, su cui la cosa sta ancora.

### capovolta

- 1: Il punto che non si rimette in gioco è che le braccia si sono stancate: la benda è stata sciolta, le lame sono già scese dal petto e quel cedimento tiene su la tua questione.
- 2: Sostiene quello che hai davanti un peso tolto dagli occhi: la stoffa che copriva è stata levata e quello che stava coperto fa adesso da appoggio, visibile come il mare dietro la pietra.
- 3: Un prezzo in stanchezza è già stato versato per tenere ferme due lame: quella spesa non si riprende e la tua domanda poggia su braccia che hanno smesso di fingere la calma.

## Tre di Spade

### dritta

- 1: Sotto la tua questione sta un colpo già entrato: le tre lame ferme nel petto sono rimaste dove erano; quel ferro piantato è il peso che tiene su quello che hai davanti.
- 2: Si è raccolta sotto la pioggia una riserva di dolore nominato: quel deposito non si è disperso con le nubi e sta sotto la tua domanda, portandone tutto il peso.
- 3: Di un materiale duro è fatta la tua questione: il ferro entrato nel petto è già dentro, non attorno; su quella sostanza la cosa sta in piedi, mentre sopra le nubi versano.

### capovolta

- 1: Perdonare è stata una scelta che ha chiuso le altre vie: da quando il ferro è fuori dal petto, il conto non si riapre; su quella chiusura la tua questione sta in piedi.
- 2: Portare un dolore nominato è diventata una capacità acquisita: la cicatrice sul petto è la prova che non si deve più imparare; quella competenza tiene su quello che hai davanti.
- 3: Che il ferro sia fuori non si rimette in gioco: è avvenuto prima della tua domanda; mentre il resto si muove, quella cicatrice chiusa fa da punto fermo alla questione.

## Quattro di Spade

### dritta

- 1: La pietra della cappella ha preso in sé tutta la stanchezza di una marcia già fatta: su quelle radici di silenzio la tua questione posa, con tre lame appese al muro sopra il capo.
- 2: Di quiete presa e di pietra fredda è impastato quello che hai davanti: quella materia tiene su la tua questione, con le mani giunte che stanno come le ha messe il sonno.
- 3: Stendersi è stato un atto compiuto che non si rifà: quel corpo posato sulla lastra sta sotto la tua questione e la regge, con una lama sola rimasta sotto il fianco.

### capovolta

- 1: Riposare a fondo è cosa che il corpo ha già imparato e quel sapere lavora da sé: la tua questione sta su quella sosta compiuta, mentre le dita si sciolgono sopra la pietra.
- 2: Nel petto è rimasta la riserva che il silenzio ha messo da parte: da quel fondo la tua questione attinge e su di esso si appoggia, con le tre lame ferme al loro chiodo.
- 3: Il recupero è già avvenuto e questo non torna in discussione: dentro la tua questione si muove il modo di rialzarsi, mentre sotto la vetrata quella sosta compiuta sostiene il resto.

## Cinque di Spade

### dritta

- 1: La tua questione è piantata in un campo rimasto sgombro dopo una vittoria: il terreno ha già bevuto quello scontro e la radice tiene su quello che oggi hai in mano.
- 2: Quello che hai davanti è impastato di un successo pagato caro: tre lame raccolte da terra, due schiene voltate sotto un cielo stracciato. Su quella materia la tua questione sta.
- 3: Hai scelto una volta di tenere il campo invece della compagnia e quella porta resta chiusa: su quel guadagno, con le armi degli altri in braccio, la tua questione poggia tutta.

### capovolta

- 1: Posare una lama vinta invece di stringerla ti riesce da prima di questa domanda: quella capacità acquisita sul campo sgombro lavora da sé e tiene su la tua questione.
- 2: Si è depositato quello che una vittoria è costata: un conto guardato bene, le armi rimesse a terra una per una. Quel sedimento non si disperde e sorregge quello che hai davanti.
- 3: Una cosa non torna in discussione nella tua questione: le armi sono state deposte e il campo è stato lasciato aperto a chi era andato via. Quel passo fermo tiene su il resto.

## Sei di Spade

### dritta

- 1: La tua questione sta su un fondo basso dove la pertica ha già fatto presa: quella spinta data dal fondale tiene su lo scafo e l'acqua davanti alla prua è liscia.
- 2: Un imbarco fatto una volta non si disfa: la tua questione sta su quel passo compiuto e le lame infisse nella prua viaggiano a bordo con la figura incappucciata.
- 3: Quello che hai già messo in acqua non torna in discussione: sta come punto fermo sotto la cosa, mentre il traghettatore spinge e la riva davanti resta ferma al suo posto.

### capovolta

- 1: Un modo di portare il peso imparato in traversata sta sotto la tua questione: la barca tiene lo stesso col carico sulla prua e la pertica trova il fondo a ogni colpo.
- 2: Il carico messo a bordo di proposito non si rimette in discussione: è la cosa ferma sotto la tua domanda e lo scafo regge, con la linea d'acqua più alta del solito.
- 3: Dove la pertica ha già toccato il fondo la tua questione trova appoggio: quel fondale tiene su una barca carica e l'acqua passa più lenta sotto le lame della prua.

## Sette di Spade

### dritta

- 1: Nel terreno della tua questione ha messo radice una prudenza già praticata: i passi in punta di piedi fuori dal campo reggono la cosa, perché da lì il vantaggio beve.
- 2: Di astuzia è fatta la tua faccenda: un giro largo intorno alla tenda, compiuto da chi ha preferito l'ingegno al confronto aperto, è la sostanza che oggi la porta.
- 3: Un bottino portato via per la lama ha chiuso la via del ritorno al campo: su quella mossa già compiuta la tua questione si appoggia, con due aste rimaste piantate nel terreno.

### capovolta

- 1: Quello che i piedi hanno appreso sul muoversi senza rumore è un mestiere vecchio: il passo fuori dalla tenda non chiede più concentrazione, dunque la tua domanda si regge su quell'arte.
- 2: Sotto la tua questione si è depositato il non detto: le lame portate per il filo hanno pesato a ogni passo, dunque la cosa pesca da quel silenzio messo via tempo addietro.
- 3: L'elemento della tua domanda che resta inchiodato è il campo: la tenda è ancora là dietro, dunque il luogo da cui le aste sono state prese fa da appoggio a quanto hai in mano.

## Otto di Spade

### dritta

- 1: La tua questione è piantata in un fango di pensieri: le lame sono state infilate nel terreno una per una, la corda è stata allacciata larga e quella radice la tiene su.
- 2: Di che cosa è fatto quello che hai davanti: di un limite creduto. Il recinto è stato costruito con poche lame piantate di fuori e quella materia leggera porta tutto il peso.
- 3: Una convinzione presa per vera ha chiuso le altre letture: che da lì non si passa. Quel verdetto già dato è il piano su cui la tua domanda sta, col castello in alto che resta a guardare.

### capovolta

- 1: Hai imparato quanto erano larghe quelle corde e la cosa non si disimpara: il varco fra due lame è stato visto una volta e quella competenza acquisita sostiene la tua questione.
- 2: Sotto quello che ti riguarda resta un deposito di passi non fatti, intatto e disponibile: la corda è caduta nel fango e quella riserva di movimento regge la cosa adesso.
- 3: Il punto fuori discussione è che il recinto non era mai stato sigillato: una lama è stata scavalcata, il fango porta l'impronta e su quel fatto compiuto la tua domanda poggia.

## Nove di Spade

### dritta

- 1: Sotto la tua questione c'è un terreno notturno già bagnato: dalle ore passate con le mani sul volto la cosa ha bevuto quello che la tiene su; quel suolo è stato preparato prima.
- 2: Il peso che porta la tua domanda è una parete di lame appese: sono state contate una per una nel buio; quel conto, fatto da seduti sul letto, è l'appoggio di quello che hai davanti.
- 3: Si è accumulata una scorta di pensieri ripassati di notte: quel sedimento, steso come la coperta ricamata, sta sotto la tua questione e non si è disperso con il giorno.

### capovolta

- 1: Un prezzo in notti è stato versato fino in fondo: quelle ore contate sotto la coperta ricamata sono una spesa chiusa; su di essa la tua questione sta in piedi adesso.
- 2: Dire a parole quello che il buio teneva fermo è stata una scelta che non si disfa: da allora la parete delle lame è solo una parete; su quella chiusura la tua domanda poggia.
- 3: Di materia già detta è fatto quello che hai davanti: il pensiero portato fuori dalla testa e messo in parole non è tornato sotto la coperta; su quella sostanza la tua questione si tiene.

## Dieci di Spade

### dritta

- 1: Un corpo già a terra sulla riva fa da pavimento a quello che hai davanti: più sotto di quella sabbia non si scende e la tua questione posa su quel livello, col cielo nero fermo.
- 2: Il prezzo è stato pagato per intero, lama dopo lama: quel conto chiuso tiene su la tua questione, con una striscia gialla bassa in fondo all'acqua immobile.
- 3: Nella sabbia bagnata la resa ha messo radice prima di questa domanda: da quel terreno la tua questione prende appoggio e lì sta, con la mano destra rimasta aperta.

### capovolta

- 1: Di terra e di ferro tolto è impastato quello che hai davanti: quella materia sta sotto la tua questione e la regge, col corpo che si tira su un gomito alla volta.
- 2: Rialzarsi dalla sabbia è stato un atto compiuto che non si disfa: quel primo movimento fa da base a quello che hai davanti, con le lame tolte una per una.
- 3: Toccare un fondo e averlo sentito duro sotto il piede è un sapere che non si dimentica: su quello la tua questione si appoggia, mentre il gomito regge il peso del primo gesto.

## Fante di Spade

### dritta

- 1: Sotto la tua questione sta una guardia già montata: un ragazzo in piedi sul poggio, la lama alzata a due mani nel vento. Quella veglia fatta la tiene su senza chiedere niente.
- 2: Hai speso attenzione e domande per sapere come stavano le cose: quel prezzo pagato in ore di scrutare l'orizzonte non si riprende e sostiene adesso la tua questione.
- 3: La tua questione è piantata in un terreno dissodato dalle domande: quello che hai chiesto per imparare a usare la lama ha già bevuto a lungo e da quella radice sale il resto.

### capovolta

- 1: Quello che hai davanti è impastato di mezze notizie passate di mano: una lama maneggiata da chi ancora non la sa tenere. La tua questione si regge su quel materiale e non su altro.
- 2: Hai riferito una volta quello che avevi sentito senza verificarlo e da quella parola non si torna: su quel detto, con la punta rivolta a caso, la tua questione poggia adesso.
- 3: Dire presto quello che arriva alle orecchie ti riesce da sé, senza che sia da imparare: quella pratica acquisita a lama scoperta fa da base a quello che oggi ti riguarda.

## Cavaliere di Spade

### dritta

- 1: Una prontezza acquisita nel decidere in corsa regge quello che hai davanti: il gesto di alzare la lama senza fermare il cavallo è stato imparato e adesso lavora da sé.
- 2: La decisione presa in corsa ha chiuso le altre strade: quel taglio compiuto regge quello che hai davanti e la lama resta alzata sopra un bersaglio nominato.
- 3: Quello che hai già deciso non si rimette in gioco: resta il pezzo fermo sotto la cosa, mentre il mantello teso dal vento e gli uccelli nel cielo corrono nella stessa direzione.

### capovolta

- 1: La tua questione affonda in un terreno percorso prima di essere guardato: quel suolo tiene su la corsa e gli zoccoli battono dove nessuno ha letto la mappa.
- 2: Di fretta impastata con lucidità vera è fatto quello che hai in mano: quella materia ha già tenuto un galoppo intero e regge ancora, col vento che entra nel mantello.
- 3: Una scorta di slancio messa insieme da prima della tua domanda regge adesso la sella: il fondo c'è, battuto nella corsa; la lama alzata pesa su un braccio che non si è fermato.

## Regina di Spade

### dritta

- 1: Sotto la tua questione sta un confine già dichiarato: il carico lo porta una lama tenuta diritta, con l'altra mano rimasta aperta verso chi si avvicina.
- 2: Una comodità ceduta per dire le cose come stanno è il conto chiuso su cui la tua faccenda poggia: quella franchezza è costata simpatia, dunque la lama tenuta alta sostiene quanto hai davanti.
- 3: Nel suolo della tua questione ha messo radice un dolore attraversato: quella radice sotto il seggio di nuvole regge la cosa, perché da lì viene la distinzione fra il vero e il comodo.

### capovolta

- 1: La materia della tua questione è un giudizio rivolto all'interno: una lama tenuta col filo verso chi la porta regge quanto hai davanti, da quando quella mano aperta si è chiusa.
- 2: Una porta chiusa a chi si avvicinava ha sbarrato le altre vie di compagnia: su quella scelta già fatta la tua faccenda poggia, col seggio rimasto alto sopra le nuvole.
- 3: Quello che la lingua ha appreso sul rispondere col taglio giusto è diventato automatico: su quella prontezza la tua questione si appoggia, col filo rivolto verso la mano che lo tiene.

## Re di Spade

### dritta

- 1: Sotto la tua questione c'è un criterio fissato una volta per tutte: la lama è stata alzata ritta e tenuta così senza calare, così quel metro regge quello che hai davanti.
- 2: Un prezzo in impopolarità è già stato pagato per decidere con chiarezza: quella moneta versata non torna indietro e la tua domanda poggia sul mestiere di chi ha giudicato molte volte.
- 3: Le radici di quello che hai per le mani stanno in un seggio alto: le due farfalle sullo schienale sono state intagliate da altri, il giudizio è stato esercitato e quel suolo duro sostiene tutto.

### capovolta

- 1: Di logica senza tepore è impastato quello che hai davanti: una regola è stata applicata dall'alto del seggio senza guardare in faccia nessuno e su quella materia la tua questione posa.
- 2: Una decisione già presa ha chiuso la via del ripensamento: la lama è rimasta ritta anche quando chiedeva di essere abbassata e quel punto saldo sostiene la tua questione.
- 3: Hai imparato a vincere le discussioni e quella capacità lavora ancora da sé sotto la tua domanda: resta acquisita come una lama tenuta affilata, mentre i legami intorno al seggio hanno pagato il conto.
