# LA POSIZIONE: CONSULTANTE

Il consultante della croce di Dora: la situazione reale, il punto in cui si trova chi chiede, non il futuro (voce FI.22).

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
dall'Architetto e scelte con la prova appaiata, cioe' mettendo i corpus
candidati nello stesso giro davanti a dodici lettori che non sapevano quale
testo venisse da quale corpus. La posizione sta al **79,0 per cento di carte
riconosciute** da un lettore che legge il testo senza il nome della carta,
misurato nella prova piu' severa che abbiamo, quella in cui i testi di due
posizioni diverse sono mescolati. Ventisei gruppi su centocinquantasei sono
stati riscritti dal cardine differenziale, cioe' dal tratto che la fonte da'
alla carta e non alla carta con cui i lettori la scambiavano, e il
rifacimento vale dodici punti sui gruppi toccati. Dodici carte restano sotto
per un difetto della fonte dei significati e non del testo: sono elencate in
`docs/corpus/tarocchi_posizione/collisioni_della_fonte.md`, insieme ai trentatre

**Riallineamento alla fonte dell'11 ottobre 2026, sera.** Ventidue voci della fonte
dei significati sono state riscritte su questo ramo, e sette di esse erano carte che
il reperto `collisioni_della_fonte.md` segnalava come prive di cardine. I testi di
questa posizione erano stati scritti sulla fonte precedente, quindi **sessantasei
testi dicevano cose che la voce nuova non dice piu'**: il Tre di Bastoni capovolta,
per esempio, diceva «l'attesa che pesa, arrivano ritardi» e la fonte dice ora «il
ritorno diverso dall'atteso». Quei ventidue gruppi sono stati **riscritti**, non
ritoccati, perche' un ritocco lascia sotto il significato vecchio. Il valore di
riconoscibilita' qui sopra e' quello misurato sulla stesura precedente e andra'
rimisurato: il riallineamento tocca il quattordici per cento dei gruppi, e in sette
di essi la voce nuova da' un cardine che prima non esisteva.
scambi che si ripetono identici su tutte e tre le posizioni provate.

## Il Matto

### dritta

- 1: Sei al principio di qualcosa e la strada non si vede intera: davanti hai soltanto il primo passo. Nessun peso ti tira indietro, nessuna garanzia ti copre. Questa leggerezza, adesso, è la tua forma di coraggio.
- 2: C'è uno slancio nuovo che ti attraversa e nessun bagaglio a trattenerti. Guardi un inizio senza conoscerne la fine e questo ti basta. Chi ti osserva può chiamarla incoscienza: è fiducia nel primo passo.
- 3: La tua condizione è quella di chi non ha ancora nulla da perdere: nessun piano completo, nessun peso sulle spalle, un piede già sul bordo. La tua libertà è reale e somiglia a un azzardo.

### capovolta

- 1: Hai addosso una spinta che non sa dove andare, oppure stai sull'orlo col volo già immaginato e il piede fermo. Coraggio o fuga: ancora non lo sai.
- 2: C'è energia e manca la direzione. Somiglia al coraggio; dietro può stare la fretta di uscire da qualcosa che non hai guardato: il passo che hai in mente lo subisci, non lo scegli.
- 3: Il punto in cui ti trovi è un orlo: lo slancio c'è, la rotta no. Un timore ti trattiene mentre vorresti saltare, oppure corri senza sapere verso cosa.

## Il Mago

### dritta

- 1: Hai gli strumenti sul tavolo e la mano ferma per usarli: quello che finora era soltanto un'idea sta chiedendo di diventare gesto concreto. Il potere che ti serve non lo stai aspettando da fuori, è già tuo.
- 2: Ti trovi nel punto in cui sai già fare ciò che hai pensato: la volontà e il mestiere sono entrambi a portata di mano. Niente ti manca dall'esterno, manca soltanto il passaggio dall'intenzione all'atto.
- 3: Quello che pensi e quello che sai fare coincidono adesso: è questo il punto in cui ti trovi. Hai in mano il mezzo oltre al desiderio ed è una condizione che non capita spesso.

### capovolta

- 1: Prometti con la bocca quello che poi la mano non consegna. Il talento non ti manca, sta chiuso in un cassetto: le tue parole corrono avanti ai fatti di parecchi passi.
- 2: Sai fare una cosa bene e non la stai facendo. Fra la tua intenzione e il gesto si è aperto uno scarto: chi ti ascolta aspetta ancora la prova delle tue frasi.
- 3: Hai gli strumenti tutti sul tavolo e le mani a mezz'aria. Il dono è intero e l'impiego quasi nessuno. Una capacità compiuta resta dove l'hai posata, oppure vive solo nelle cose che annunci.

## La Papessa

### dritta

- 1: Dentro di te c'è una conoscenza che non ha trovato parole: la senti nel corpo prima di poterla spiegare. Il tuo punto di partenza è una mente quieta, che custodisce un mistero ancora intatto.
- 2: Ti trovi in un silenzio abitato, non vuoto. Qualcosa in te sa già la risposta e la tiene al riparo, perché non è ancora matura per essere detta a nessuno.
- 3: Sai, senza poterlo dimostrare. La parte di te che intuisce lavora al buio mentre la ragione resta ferma sulla soglia, in attesa che il mistero si lasci avvicinare.

### capovolta

- 1: Stai coprendo con ragionamenti e rumore un sapere che in te parla ancora. Il punto in cui sei è quello di chi teme il silenzio, per quello che sentirebbe fermandosi.
- 2: Dentro di te qualcosa sa, ma non lo lasci parlare: lo soffochi con spiegazioni, con la fretta, con mille suoni addosso. L'intuito è lì, messo a tacere e ancora intero.
- 3: La tua parte che intuisce è finita in disparte e decidi tutto con la testa. Quello che hai adesso è una sordità scelta, che ti tiene al riparo da ciò che sapresti nel silenzio.

## L'Imperatrice

### dritta

- 1: Qualcosa di vivo ha già attecchito nelle tue mani e cresce con i propri tempi: non amministri un bene che c'era prima, lo stai generando e lo nutri con dolcezza.
- 2: Sei terra fertile in questo momento. Un progetto, un legame, un'idea prendono forma da te senza che tu li tiri per farli crescere: l'abbondanza qui non viene da fuori, nasce da dentro.
- 3: La cura che hai addosso non è ordine domestico e non è un'occasione da cogliere: è generazione. Dentro di te matura una cosa che chiede tempo e non spinta. Glielo stai dando.

### capovolta

- 1: Quello che tenevi in crescita non fiorisce perché la terra da cui veniva su sei tu e l'acqua che spargi su ogni altra cosa dalla tua parte viva non passa.
- 2: La tua capacità di far nascere sta ferma e i semi che hai messo non si aprono: la gentilezza che spendi fuori non passa da te e senza quel passaggio niente esce.
- 3: Dentro di te una pianta non apre: l'acqua la porti a tutto tranne che alla tua radice, così la parte che genera è a secco e niente sboccia.

## L'Imperatore

### dritta

- 1: Stai dentro una cornice di regole che hai posto tu e invece di stringerti ti tiene su: le fondamenta di quello che costruisci reggono perché la responsabilità la porti fino in fondo.
- 2: Il punto in cui ti trovi ha la forma di una regola tua: dai misura a quello che edifichi, non ti limiti a custodire ciò che possiedi. Chi ti sta intorno lo riconosce.
- 3: Porti un'autorità che nessuno ti ha regalato: decidi i limiti, fissi i tempi, rispondi delle conseguenze. La disciplina non ti chiude, ti fa da impalcatura mentre quello che hai avviato prende forma.

### capovolta

- 1: L'ordine che hai scelto è diventato una morsa: orari, doveri, verifiche pesano addosso e il respiro è corto. Oppure di regole non ce n'è nessuna e tutto oscilla.
- 2: Tutto passa dalla tua presa e la presa è troppo rigida: persone, dettagli, tempi. La stessa disciplina che ti teneva in piedi adesso [ti tiene fermo|ti tiene ferma|ti blocca].
- 3: Manca la base, oppure ti stringe i polsi: la cornice che dovrebbe sostenerti nel punto in cui sei non fa il suo lavoro, così ogni decisione ti pesa il doppio di quanto dovrebbe.

## Il Papa

### dritta

- 1: Ti trovi dentro un insegnamento che non hai inventato: qualcuno lo ha trasmesso prima di te e tu ci stai dentro con rispetto. L'appartenenza a qualcosa di antico è la forza su cui poggi adesso.
- 2: C'è una figura più grande di te nella tua situazione: un maestro, un consiglio ascoltato, un sapere condiviso che in questo momento ti regge. Non cammini a mani vuote, hai una tradizione alle spalle.
- 3: La tua posizione è quella di chi sta imparando da altri. Una regola ricevuta, un sentiero già tracciato, una sapienza che viene da lontano tengono in piedi il punto in cui stai.

### capovolta

- 1: Una regola ricevuta ti sta addosso ormai senza aderirti: la rispetti per abitudine, non perché la riconosci tua. Quello che senti non è ribellione, è una misura diventata troppo piccola.
- 2: Ciò che ti era stato insegnato come dover essere non ti contiene più. Il sentiero già tracciato continua a chiederti obbedienza, però il tuo respiro sta da un'altra parte.
- 3: Senti stretta una convenzione che un tempo ti stava bene. Il distacco che provi non ha niente di capriccioso: è il punto in cui un sapere tramandato smette di essere il tuo.

## Gli Amanti

### dritta

- 1: C'è un amore vero nella tua vita e con lui un bivio: la decisione non si gioca sul desiderio di adesso, ma sui valori in cui ti riconosci.
- 2: Ti trovi davanti a una decisione sola, dentro la quale c'è qualcuno che ami: la domanda che ti tiene è se quel che desideri sta insieme a quel che sei.
- 3: L'amore c'è ed è lui a metterti davanti a un bivio che pesa quanto te: un desiderio tira da una parte, l'idea che hai di te resta dall'altra.

### capovolta

- 1: Vivi fra cose tue che non stanno insieme, quella in cui credi e quella che desideri. A una delle due hai tolto la parola, perciò l'altra non ti convince e chi ti aspetta resta senza risposta.
- 2: Dentro di te il disaccordo non riguarda nessuno di fuori: a contendersi il campo sono valori tuoi, uno dichiarato e uno tenuto in silenzio. Il legame aspetta mentre la contesa resta pari.
- 3: Tiri in lungo con chi ti aspetta e la contesa vera è tutta interna: credere una cosa, volerne un'altra, con il secondo termine mai pronunciato. Finché resta fuori dal conto, il primo non basta a decidere.

## Il Carro

### dritta

- 1: Hai in mano le redini di due forze che tirano in versi opposti e le porti dove hai deciso: non stai progettando la rotta, sei già in movimento con la meta a vista.
- 2: Avanzi con le spinte contrarie aggiogate sotto di te: quella che altri chiamerebbero fortuna, nel tuo caso è padronanza. Lo sguardo resta fermo sulla meta ed è il tuo sguardo a tenere insieme il resto.
- 3: La direzione ce l'hai e lo slancio pure, con la mano salda sul comando. Qui non c'è nulla di casuale: ciò che ti regge è la capacità di dominare insieme energie che si contraddicono.

### capovolta

- 1: Le spinte che prima governavi ora tirano ognuna per conto suo e il mezzo sbanda. Non ti manca l'energia, ti è sfuggito il comando: le redini sono ancora nelle tue mani, soltanto allentate.
- 2: Stai correndo senza sapere bene verso dove, perché il centro da cui tenevi insieme le tue forze contrarie si è spostato. Il problema non è troppa foga, è una guida che ha perso la presa.
- 3: Avanzi a scatti, in mezzo a parti di te che non si accordano più. Qui lo slancio c'è tutto: quello che è venuto meno è la mano che lo teneva su una linea sola.

## La Giustizia

### dritta

- 1: Sei nel punto in cui le tue azioni tornano indietro misurate: né uno sconto né un peso in più. Quello che raccogli adesso porta la tua firma e lo guardi con lucidità.
- 2: La tua condizione è quella di un conto in pari: hai davanti la conseguenza limpida di ciò che hai scelto. Niente colpe aggiunte, niente attenuanti comode, solo il peso vero.
- 3: Guardi le cose come stanno, senza trucco: la causa da una parte, l'effetto dall'altra, la tua parte di responsabilità al centro. È un tempo di verità, non di racconti.

### capovolta

- 1: Hai davanti un risultato che viene da una tua scelta e lo stai attribuendo alla sfortuna. Non porti un peso di qualcun altro: ne hai posato uno tuo che resta aperto al tuo nome.
- 2: Il punto in cui sei è questo: una conseguenza che hai prodotto decidendo la stai intestando al caso mentre lo squilibrio che senti addosso nasce da quello spostamento, non dal fatto.
- 3: Ti riguarda un conto che hai aperto tu con una decisione precisa, ma nel racconto che ne fai l'ha aperto la sorte: finché la firma resta su un altro nome, lo sbilancio rimane.

## L'Eremita

### dritta

- 1: Sei in un tempo di ritiro cercato, con il passo rallentato e lo sguardo rivolto dentro invece che fuori. La luce che porti basta per un passo alla volta, non per la strada intera.
- 2: Il silenzio in cui stai non è vuoto: è lo spazio che fa venire le risposte vere. Cerchi dentro, con calma, mentre una lanterna piccola ti mostra soltanto il tratto che hai sotto i piedi.
- 3: Cammini piano e in disparte, per scelta tua. La ricerca che porti avanti adesso è rivolta all'interno. La poca luce che ti guida illumina un passo e non il percorso intero.

### capovolta

- 1: La solitudine che doveva chiarirti si è fatta peso e ti tiene a distanza invece di darti lucidità. Non è più un raccogliersi, è un nascondersi. La differenza la senti bene.
- 2: Sei nel punto in cui il ritiro non chiarisce più nulla. La porta chiusa serviva a vedere meglio e adesso tiene fuori anche la strada che riporterebbe verso gli altri.
- 3: Il distacco che avevi scelto adesso ti costa. La lanterna illumina ancora, però la tieni rivolta dentro una stanza da cui non esci. Questo isola invece di chiarire.

## La Ruota della Fortuna

### dritta

- 1: Sei nel mezzo di un giro che non hai avviato tu: qualcosa si sposta per conto suo e il momento scelto non è il tuo. Quello che tenevi fermo si muove mentre guardi altrove.
- 2: La tua posizione cambia quota senza che tu abbia toccato niente: in alto o in basso, nessuno dei due punti è il tuo posto fisso. Il movimento adesso conta più della tua spinta.
- 3: Un ciclo si chiude e un altro parte proprio dove stai: vicende vecchie tornano con un'altra faccia e la fase che vivi dura quanto decide il giro, non quanto decidi tu.

### capovolta

- 1: Sei in una fase che non avanza: le stesse situazioni tornano con la stessa faccia e la presa ti sfugge, perché la leva di questo giro non sta nelle tue mani.
- 2: Il ciclo in cui ti trovi è fermo a metà, oppure gira per il verso storto: spingi e la posizione resta quella, come una sosta imposta da fuori.
- 3: Qualcosa si è incagliato nel tempo delle cose, non nel tuo passo: aspetti un cambio che non scatta e il punto in cui stai somiglia a una pausa senza data.

## La Forza

### dritta

- 1: Tieni a bada ciò che ti ruggisce dentro senza alzare la mano: la fermezza che usi adesso è mite e tiene proprio per questo, perché non ha niente di violento.
- 2: C'è un istinto grosso dentro di te e non lo stai combattendo: lo stai addomesticando con la calma, giorno per giorno, come si fa con un animale che impara a fidarsi.
- 3: Il tuo coraggio in questo momento ha la mano ferma e il tocco gentile. Nessuna lotta in corso: quello che ti agita si placa perché lo tratti con dolcezza paziente.

### capovolta

- 1: Dubiti della tua tenuta. Per reggere hai cominciato a stringere invece di calmare, così ti tratti con una durezza che non ti somiglia e il controllo ti sembra scappato via.
- 2: La mitezza con cui tenevi a bada il tuo istinto si è trasformata in stretta. Ti giudichi senza pietà per restare in piedi, però il vigore che credi perduto è soltanto irrigidito.
- 3: Ciò che ti agita dentro ti sembra più grosso di te in questo momento. La risposta che dai è il pugno chiuso: nessuna carezza verso [te stesso|te stessa|te], solo una stretta che ti sfinisce.

## L'Appeso

### dritta

- 1: Sei in sospensione e non ti muovi, però dentro qualcosa si è girato: vedi la stessa situazione a testa in giù e da quell'angolo torna un senso che prima ti sfuggiva.
- 2: L'attesa in cui stai sembra tempo perso e non lo è: hai lasciato la presa sul fare e in quel vuoto ciò che sembrava ovvio si mostra al contrario e regge meglio.
- 3: Nessuna azione ti è possibile adesso e non ti manca nulla: guardi il mondo da un punto mai occupato e il tempo fermo ti insegna ciò che il movimento nascondeva.

### capovolta

- 1: Stai a testa in giù da tanto che il mondo non ti sembra più nuovo: l'attesa non insegna più e tu la chiami pazienza perché il nome vero costa caro.
- 2: Il sacrificio che porti nessuno te l'ha chiesto e nessuno lo incassa: il nodo alla caviglia l'hai stretto tu, in nome di una cosa nobile, ma quella rinuncia non serve a nessuno.
- 3: Da fuori la tua immobilità sembra virtù, dentro è altro: ti fermi per non scendere, perché scendere vuol dire rimettere i piedi a terra e rispondere delle cose. Lo stallo è tuo.

## La Morte

### dritta

- 1: Qualcosa nella tua vita è arrivato al termine e si chiude mentre lo guardi: non ti si chiede un bilancio, è un ciclo finito e lo spazio nasce da quella fine.
- 2: Sei nel punto in cui una cosa finisce perché un'altra possa nascere. Non è una condanna né un appello a cui rispondere, è una trasformazione già cominciata dentro di te.
- 3: Una porta si chiude dietro di te mentre sei ancora sulla soglia: ciò che hai lasciato non torna com'era. Non devi meritare una rinascita, è una fine compiuta.

### capovolta

- 1: Un cambiamento è già entrato nella tua vita e tu lo tieni fermo con tutte le mani. Non stai piangendo una cosa perduta: stai facendo forza contro una fine che si compie comunque.
- 2: Stai resistendo a ciò che sta finendo e la fatica che senti viene da quella presa, non dalla perdita. Il dolore qui nasce dal trattenere, mentre la cosa si chiude anche senza il tuo consenso.
- 3: La tua mano è serrata su qualcosa che ha già smesso di esistere come lo conoscevi. Quello che pesa non è un carico sulle spalle, è lo sforzo di tenere in piedi una forma finita.

## La Temperanza

### dritta

- 1: In te due parti che sembravano incompatibili stanno trovando la loro proporzione. Non accade per forza di volontà, accade per dosaggio, un poco alla volta, con pazienza.
- 2: Ti trovi nel tempo lento della mescolanza: niente da spingere, nessuna meta da raggiungere, solo la misura giusta fra ciò che in te tirava in versi opposti.
- 3: La tua condizione adesso è un equilibrio paziente, fatto di piccole quantità. Quello che pareva inconciliabile sta insieme perché nessuna delle due parti è stata forzata.

### capovolta

- 1: Il dosaggio è saltato: di una cosa ne hai troppa, dell'altra niente. Due parti di te hanno smesso di parlarsi e ognuna tira per conto proprio, dentro la stessa giornata.
- 2: Eccessi e scatti ti governano le giornate, senza una misura che tenga. Non è la direzione a mancarti, è la quantità giusta di ogni cosa, quella che avevi e hai perduto.
- 3: Qualcosa in te è fuori proporzione, troppo pieno da un lato e vuoto dall'altro. Il ritmo che tenevi si è rotto e adesso le ore ti passano addosso a strappi.

## Il Diavolo

### dritta

- 1: Un attaccamento ti tiene più di quanto ammetti: una cosa che chiami abitudine e che invece comanda. L'ombra c'è. Finché resta senza nome, decide al posto tuo.
- 2: Ti trovi dentro una presa che conosci a metà. Tentazione, dipendenza, un legame che ti sembra scelto: la catena è reale e la parte che non guardi è proprio quella che tiene.
- 3: Sai benissimo qual è il nodo e continui a non nominarlo. Qui non c'è nessuna vergogna da coprire, solo una verità che agisce nel buio perché non l'hai ancora chiamata per nome.

### capovolta

- 1: Ti accorgi del legame che ti tratteneva e il solo accorgerti ha già cambiato la presa. Il nodo è ancora lì, però adesso lo vedi: quello che si vede non comanda come prima.
- 2: Qualcosa che ti teneva ha perso il suo nascondiglio. Non era più forte di te, era solo invisibile. Ora sei nel punto in cui metà della libertà è già fatta.
- 3: La catena si sta allentando perché l'hai guardata in faccia. Resta il nodo da sciogliere con calma, però la parte più dura, quella di riconoscerlo, è alle tue spalle.

## La Torre

### dritta

- 1: Qualcosa è crollato di colpo e tu sei in mezzo alle macerie: quello che è caduto stava in piedi su una finzione e l'urto l'hai sentito tutto addosso.
- 2: Ti trovi dopo lo schianto, con la polvere ancora sospesa: una certezza si è sbriciolata in un istante e il colpo brucia, però quello che era vero è rimasto dove stava.
- 3: Sotto i tuoi piedi è venuto giù un impianto intero, senza preavviso: il falso che lo teneva su si è visto soltanto quando si è spaccato. Resta la terra nuda, che almeno non mente.

### capovolta

- 1: Abiti una costruzione con la crepa già nel muro portante e passi le giornate a intonacarla: nessuno ti attacca, sei tu a tenere su la facciata di una cosa che dentro non è più vera.
- 2: Stai rinviando la scossa che rimetterebbe tutto al vero: il fulmine resta fuori perché lo tieni fuori con i puntelli e ogni giorno di rinvio alza di un piano ciò che poggia sul falso.
- 3: La tua fatica è quella di chi puntella: non porti il peso di un altro, tieni insieme un impianto che sai già finto e il tuo sollievo è che non sia ancora caduto.

## La Stella

### dritta

- 1: La tempesta è già passata e quello che senti adesso è una luce bassa che non urla: fiducia che rientra piano, ispirazione che torna, stanchezza ancora nelle ossa.
- 2: Sei nel momento quieto che viene dopo il peggio. Niente clamore, nessun colpo di scena: soltanto una rassicurazione dolce che ti dice che la strada presa era quella giusta.
- 3: Dentro di te la fiducia si è riaccesa a luce dolce, dopo giorni che ti hanno tolto le forze. La fatica resta addosso, intanto la quiete ha ripreso il suo posto.

### capovolta

- 1: La fiducia ti si è stancata addosso. Non riesci più a credere che le cose migliorino. Immaginarlo ti costa fatica, come se la luce ci fosse ancora però dietro una nube.
- 2: Sei nel punto in cui l'ispirazione sembra lontanissima e la speranza ti pare una cosa da ingenui. Non è spenta, è velata: da qui però tu vedi soltanto il grigio.
- 3: Credere al meglio ti riesce male in questo periodo. Non ti manca lo slancio per iniziare qualcosa, ti manca la convinzione che valga la pena sperarci ancora.

## La Luna

### dritta

- 1: Quello che hai davanti non ha ancora la forma vera e lo sai senza poterlo dimostrare. Di notte le paure prendono un volume che di giorno non hanno: qui l'intuito vede meglio degli occhi.
- 2: C'è un velo sulla scena: nomi, parole, apparenze non combaciano con ciò che senti sotto. L'inconscio parla e parla per immagini. Ti muovi in un buio dove ogni passo si tasta invece di vedersi.
- 3: Nulla qui è falso del tutto, nulla è chiaro: il contorno delle cose cambia con l'ora in cui le guardi. Le tue paure notturne si mescolano ai fatti e non riesci a separarle.

### capovolta

- 1: La nebbia intorno a te si alza e ciò che vedi non ha la stazza che gli davi. È la stessa cosa, la guardi da vicino: aveva più contorno che corpo.
- 2: Stai uscendo da una confusione e le cose, viste adesso, non sono come sembravano a prima occhiata. Nessuna rivelazione improvvisa è arrivata. Ti si è soltanto corretta la misura della cosa che temevi.
- 3: Hai davanti una faccenda che ti sembrava enorme e adesso ha una taglia normale. Non si è ridotta lei, è caduto l'ingrandimento: con occhi nuovi trovi più ombra che sostanza.

## Il Sole

### dritta

- 1: Sei in piena luce e niente di te sta nell'ombra: ciò che senti non ha bisogno di coperture davanti a nessuno. Le cose attorno a te fioriscono, in un tempo chiaro e caldo.
- 2: La chiarezza è la tua condizione adesso: stai ridendo senza nasconderti e quello che hai costruito si vede. Il calore che porti addosso raggiunge anche chi ti sta vicino.
- 3: Nulla in te chiede di restare segreto in questo momento: stai bene e si capisce a vista. Il successo che vivi ha la qualità del mezzogiorno, senza zone grigie da spiegare a qualcuno.

### capovolta

- 1: La luce c'è attorno a te e sulla pelle non la senti. Non si è incrinato un affetto: c'è uno schermo tuo, spesso un pensiero vecchio, fra te e una gioia ancora disponibile.
- 2: Hai motivi buoni per stare bene e l'entusiasmo resta a mezz'asta. Quello che ti separa dal calore non è la paura di aprirti, è una nube tua che copre una luce ancora intera.
- 3: Tutto è al suo posto eppure la gioia ti arriva smorzata, come filtrata da un vetro. Niente se n'è andato: qualcosa sta in mezzo ed è quel qualcosa a spegnere il calore sulle tue mani.

## Il Giudizio

### dritta

- 1: Sei nel punto in cui tutto il tuo passato si presenta insieme e chiede un bilancio. Dentro di te un richiamo chiaro chiama a una vita più tua, senza che nessuno te l'abbia indicato.
- 2: Un richiamo è arrivato e non porta nessuna condanna: non viene da un libro né da un maestro, sale dalle tue ossa e sta separando chi eri da chi stai diventando.
- 3: Ti trovi sulla soglia di una rinascita, con il conto di tutta la tua storia aperto davanti. Il richiamo lo hai sentito, anche se non lo hai ancora detto a nessuno.

### capovolta

- 1: Il richiamo a un bilancio della tua vita lo senti e lo rimandi. Al suo posto arriva una severità contro di te che non risveglia niente, mentre la domanda vera resta chiusa.
- 2: Dentro di te si celebra un processo: tutte le accuse e nessun ascolto. Non è un conto aperto con qualcun altro, è il rinvio di una rinascita che hai già sentito chiamare.
- 3: Qualcosa in te chiede una svolta e tu rispondi con il rimprovero. Ti condanni invece di ascoltarti e così il bilancio resta fermo allo stesso punto da molto tempo.

## Il Mondo

### dritta

- 1: Un ciclo si chiude e [tu sei arrivato|tu sei arrivata|sei] dove dovevi. Non è un patrimonio che resta dopo di te: è un percorso che si compie dentro di te, intero, in questo momento.
- 2: Ti trovi in un compimento pieno: ciò che hai attraversato è diventato parte di te e il cerchio si tiene da sé. Non ci sono radici da lasciare, c'è una strada percorsa fino in fondo.
- 3: Sei nel punto esatto in cui il viaggio torna al suo inizio e trova senso. Niente da aggiungere, niente da difendere: quello che resta è un'armonia già raggiunta, tua, non da tramandare.

### capovolta

- 1: Il cerchio è quasi chiuso: ti manca un pezzo da integrare, non la forza per arrivarci. Non è stanchezza, è un dettaglio rimasto fuori da un disegno che hai quasi completato.
- 2: Sei a un passo dalla pienezza e quel passo non chiede resistenza ma completamento. Qualcosa di tuo è ancora da mettere al suo posto, perciò l'insieme non si tiene.
- 3: Quasi tutto è compiuto e l'incompiuto è poco. Non ti pesa nessuno scudo e non ti inganna nessuna soddisfazione di facciata: ti resta un tratto da sciogliere perché il tutto diventi intero.

## Asso di Bastoni

### dritta

- 1: Hai addosso un'idea appena accesa, ancora senza un passo fatto: il desiderio è al suo primo istante e ti scalda le mani prima che tu abbia mosso qualcosa.
- 2: Nel punto in cui stai c'è un inizio puro: nessuna strada percorsa, nessuna corsa già avviata, soltanto uno slancio nuovo che ti brucia dentro e chiede di esistere.
- 3: Ti attraversa una voglia nuova e grezza, senza forma: non è ancora un progetto né un viaggio, è la prima fiamma e la senti viva proprio adesso.

### capovolta

- 1: Hai la voglia intatta e la partenza ferma: l'inizio slitta di giorno in giorno e quello che ti trattiene è il timore dello sbaglio, non il freddo del desiderio.
- 2: Qualcosa soffoca uno slancio che dentro di te è vivo: lo senti premere e resta sotto, come un fuoco coperto che fuma senza prendere.
- 3: Stai alla vigilia di una cosa che non comincia: la rimandi, la rimandi ancora, mentre il fiato per accenderla ti sembra sempre quello di domani.

## Due di Bastoni

### dritta

- 1: Hai un progetto in mano e nessuna nave ancora in mare. Sei nel punto in cui si guarda oltre il confine di ciò che conosci, prima di partire, con la rotta da scegliere.
- 2: Il mondo ti sta in una mano e la mappa nell'altra. Niente è stato lanciato, niente aspetta frutti: davanti a te c'è la scelta della direzione, con un'ambizione che non ti manca.
- 3: Ti trovi sulla soglia di un disegno tuo, non condiviso con altri. Il passo che ti aspetta è scegliere dove puntare. Il confine del già noto lo vedi bene da qui.

### capovolta

- 1: Il piano ce l'hai, la direzione no. Resti sulla soglia perché osare ti spaventa, così tutto rimane sospeso a metà fra l'idea e il primo passo.
- 2: Non sono troppe cose a bloccarti, nemmeno un raccolto che tarda. È che non ti è chiaro dove vuoi andare. La paura di sbagliare rotta ti tiene esattamente dove sei.
- 3: Davanti a te c'è una direzione sfocata. L'ambizione non ti manca, ti manca la scelta. Ogni mossa tentata nel dubbio pesa meno di un passo solo fatto con convinzione.

## Tre di Bastoni

### dritta

- 1: Hai già mandato fuori qualcosa e adesso non è più nelle tue mani: viaggia lontano, dove non vedi. Il tuo posto è il punto alto da cui si guarda l'orizzonte, col lavoro alle spalle.
- 2: Quello che aspetti non cresce nel tuo campo: è partito, sta altrove, dipende anche da mani altrui. Stai sul bordo a scrutare la linea dove il mare finisce, col progetto fuori portata.
- 3: Il seme è fuori dal recinto. Hai aperto un fronte più largo di quanto potevi controllare e ora il tempo lavora in posti che non visiti. Sei nella posizione di chi attende ritorni da lontano.

### capovolta

- 1: Hai una risposta in mano e non è quella che avevi chiesto: ciò che avevi mandato lontano è rientrato con un contenuto suo. Ora il conto si rilegge su ciò che è tornato.
- 2: Quello che hai spedito oltre il mare è di nuovo da te, con un carico diverso dalla tua lista. Nessuna attesa resta aperta: la merce è scaricata e le tue previsioni no.
- 3: Le tue aspettative stanno davanti a te, smentite da un fatto concreto: il ritorno esiste e ha una forma sua. Il porto non è vuoto, è pieno di ciò che non avevi previsto.

## Quattro di Bastoni

### dritta

- 1: Le fondamenta che hai posato reggono e intorno a te c'è gente con cui dividere il risultato. Niente è da aspettare: il traguardo sta già in casa tua.
- 2: Ti trovi su una base solida, in un tempo di festa sotto lo stesso tetto. Non è un applauso da fuori a dirti quanto vali: è una stabilità che hai costruito tu.
- 3: Quello che hai messo in piedi tiene e le radici sono a terra. La gioia qui non aspetta nessun verdetto esterno: è il riconoscimento tuo e dei tuoi per una casa che sta su.

### capovolta

- 1: Ti trovi a traguardo raggiunto senza averlo ancora festeggiato: la cosa è compiuta per intero e il momento per celebrarla non si è presentato, così la gioia ti resta a metà.
- 2: Le chiavi di una casa nuova le hai già e l'ingresso non l'hai ancora fatto: nulla ti è venuto diverso da come lo volevi, è il passaggio della soglia a mancare.
- 3: Hai in mano un risultato completo che non ha trovato la sua festa: non è un lavoro lasciato a metà né un bene che ti contendono, è la celebrazione a restare sospesa.

## Cinque di Bastoni

### dritta

- 1: Sei in mezzo a una mischia di idee e di spinte pari alla tua. Nessuno ha vinto, nessuno è umiliato: l'energia ribolle, il confronto fa rumore e intanto ti misura.
- 2: Attorno a te si litiga di idee e tu sei dentro lo scontro, non sotto. È una gara aperta fra forze simili, dove la posta è misurarsi e dove nessuno è stato schiacciato.
- 3: La tua condizione è l'attrito: ogni giorno un confronto acceso, spinte che si incrociano senza che una prevalga. Non c'è un torto da riparare, c'è energia che si scontra.

### capovolta

- 1: Ti logori in battibecchi che non hanno nemmeno una posta: ognuno punge, nessuno vince, la stessa discussione riparte domani con le stesse parole.
- 2: Attorno a te si bisticcia su più fronti piccoli e tu stai in mezzo. Nessun avversario vero da affrontare: soltanto screzi sparsi che ti prendono le forze a sorsi.
- 3: Metà di quei dissapori li lasci covare senza nominarli, metà li tieni aperti per abitudine. Addosso senti la stanchezza di una contesa che non decide niente e ricomincia ogni giorno.

## Sei di Bastoni

### dritta

- 1: Ti arriva un riconoscimento che vedono anche gli altri, non soltanto tu. Il merito è tuo, il lavoro dietro è reale. Questo è il punto in cui stai adesso, sotto lo sguardo di chi applaude.
- 2: Sei nel momento in cui il tuo risultato viene detto in pubblico. Non è fortuna capitata: è una cosa costruita da te. Chi ti sta intorno la riconosce senza che tu debba spiegarla.
- 3: Davanti a testimoni ti viene dato credito per una cosa tua. Non c'è niente di gonfiato in quel riconoscimento: la fatica che ti è costata la conosci e adesso la conoscono anche gli altri.

### capovolta

- 1: Il riconoscimento non arriva e nel silenzio hai cominciato a dubitare di quanto vali. Il valore non ti è stato tolto: manca soltanto chi lo dica. Stai misurando te su quel silenzio.
- 2: Hai fatto la tua parte e nessuno l'ha nominata. Da qui nasce il dubbio in cui ti trovi: non la mancanza di merito, ma la mancanza di uno sguardo che lo confermi.
- 3: Aspetti un applauso che non viene e l'attesa si è trasformata in un sospetto verso di te. Quello che hai fatto resta intero anche adesso che nessuno lo guarda.

## Sette di Bastoni

### dritta

- 1: Il terreno più alto è tuo e qualcuno te lo contende da sotto: la pressione ti arriva addosso, però il vantaggio resta dalla tua parte e le forze non sono finite.
- 2: Stai difendendo una cosa in cui credi contro più fronti insieme, [circondato|circondata|in mezzo all'assedio] e non in svantaggio: la posizione migliore in questo momento è la tua.
- 3: Sei sotto contestazione da chi vuole il tuo posto: il fiato è ancora pieno, il coraggio regge e chi spinge contro di te deve salire, non tu.

### capovolta

- 1: Hai più contese aperte nello stesso tempo e a ognuna dai una risposta intera: la tua forza finisce divisa in troppe parti. A sopraffarti è il numero di chi pretende qualcosa.
- 2: Da una parte ci sei tu, dall'altra sono parecchi: ognuno vuole un pezzo di quello che tieni e a tutti dici no insieme. Nessun punto riceve la tua forza intera.
- 3: Le parti che ti chiedono qualcosa si sono moltiplicate e tieni il punto su ciascuna, anche su quelle che non vogliono più niente da te. Ti schiaccia la quantità, non un avversario.

## Otto di Bastoni

### dritta

- 1: Tutto si muove insieme e in fretta intorno a te: notizie che si accavallano, risposte che rientrano, cose ferme da tempo che partono tutte nello stesso giorno.
- 2: Sei dentro un'accelerazione che non hai provocato tu. Il ritmo si è alzato da solo e quello che aspettavi si sta già muovendo verso di te.
- 3: La tua situazione ha preso velocità. Messaggi, chiamate, segnali: niente resta in sospeso a lungo e fra una domanda e la sua risposta passa pochissimo.

### capovolta

- 1: Il movimento si è impuntato. Quello che doveva muoversi tarda e quando invece tocca a te ti muovi con una fretta che ti fa inciampare.
- 2: Ci sono attese che non si chiudono e una corsa tua fuori tempo. L'ordine si è perso per strada: vai veloce senza sapere bene verso dove.
- 3: Niente arriva quando dovrebbe nella tua situazione, intanto tu acceleri. È il punto in cui la velocità non ti serve, perché la direzione non è a fuoco.

## Nove di Bastoni

### dritta

- 1: Porti addosso il conto delle prove già passate e sei in piedi con la fatica di tutte. Il traguardo è vicino: quello che resta è meno di quello che hai attraversato.
- 2: La stanchezza che senti non è pigrizia, è il peso di un percorso quasi finito. Hai ceduto terreno e lo hai ripreso più volte: ti resta un tratto breve.
- 3: Sul tuo corpo ci sono i segni di quello che hai già retto: non è la prima volta che tieni il punto. Sei all'ultimo pezzo, dove la tenacia conta più della forza.

### capovolta

- 1: Non c'è nessun assalto in corso e tu resti in guardia: le botte che hai preso tempo addietro decidono ancora chi è pericoloso, per loro lo è chiunque si avvicini di un passo.
- 2: Il tuo riflesso arriva prima del tuo giudizio: alzi la difesa e solo dopo guardi chi avevi davanti. Le ferite che portano la data di prima leggono ogni avvicinamento come un attacco.
- 3: Stai dentro un recinto che hai alzato per un pericolo finito. Il corpo ricorda i colpi e tiene il presidio da sé, così anche chi arriva in pace resta fuori.

## Dieci di Bastoni

### dritta

- 1: Porti addosso più responsabilità di quante stiano su due spalle e la schiena si è curvata per adattarsi. Nessuno ti sta attaccando: è il peso accumulato a tenerti chino, non un nemico.
- 2: Hai detto sì così tante volte che adesso il carico ti arriva al collo. Non sei a terra: cammini ancora, soltanto sotto una soma che ti toglie la vista della strada.
- 3: Le cose che tieni in piedi per gli altri sono diventate il tuo modo di stare al mondo. Il problema non è una ferita, è il numero: troppe braccia tese verso di te.

### capovolta

- 1: Il fardello che tieni sulle spalle appartiene a qualcun altro e tu lo porti per abitudine. Nessuno te l'ha chiesto di recente: è il senso del dovere a tenerlo lì, non una necessità vera.
- 2: Quasi tutto quello che [ti sei caricato|ti sei caricata|porti] non nasce da una richiesta: è rimasto attaccato a te per consuetudine. Il peso c'è e la ragione che lo giustificava non c'è più.
- 3: Senza necessità reale continui a reggere ciò che altri hanno posato su di te. Non stai resistendo a un cambiamento: stai sostenendo per inerzia qualcosa che potrebbe stare a terra.

## Fante di Bastoni

### dritta

- 1: Qualcosa di nuovo ti ha bussato alla porta e tu hai aperto: un'idea giovane, leggera, senza impegno preso, che ti riempie di domande e ti fa venire voglia di provarla.
- 2: Hai addosso un entusiasmo fresco del tipo che ti fa parlare prima di sapere. Niente è ancora in corsa: c'è una scintilla curiosa, minuscola come quelle da cui nascono le avventure grandi.
- 3: Sei in un tempo di esplorazione: ti butti su una cosa per il gusto di provarla e fai domande a chiunque incontri. Il tuo slancio è giovane e nessuno ne chiede i frutti.

### capovolta

- 1: Sei nel mezzo di una serie di partenze dove l'ultima ha scalzato la penultima. Il fuoco ti torna intero a ogni giro e intanto alle tue spalle niente è arrivato a maturare.
- 2: L'idea che ti scalda oggi ha preso il posto di quella del mese scorso, che aveva appena cominciato a prendere forma. Niente ti blocca la strada: subentra sempre la novità più fresca.
- 3: Hai la stessa fame del primo giorno e niente in mano, perché ogni slancio ti è durato fino allo slancio seguente. La parte lenta delle cose che hai aperto sta dove l'hai lasciata.

## Cavaliere di Bastoni

### dritta

- 1: Sei già in movimento verso quello che desideri, con l'ardore di chi non aspetta. Non è un'idea che bussa alla porta: è una corsa iniziata. La meta la tieni d'occhio mentre vai.
- 2: L'avventura è cominciata e ci sei dentro con tutto il corpo. Il coraggio non ti manca. La cosa che ti riguarda adesso è se la direzione regge il ritmo che hai preso.
- 3: Corri verso una cosa che vuoi e osare qui ti costa meno che esitare. Quello che hai sotto non è una curiosità fresca, è una passione lanciata al galoppo da un pezzo.

### capovolta

- 1: L'energia non ti manca e non è bloccata: ti si sparge in troppe direzioni insieme. È un fuoco che corre senza rotta e ti brucia più di quanto ti porti.
- 2: Parti prima di sapere dove e l'impazienza decide al posto della direzione. Niente ti sta trattenendo: è la foga stessa che ti consuma nel punto in cui sei.
- 3: Ti trovi con l'ardore al massimo e la meta da nessuna parte. La stessa spinta che ti fa partire ti disperde, perché nulla la raccoglie in un punto.

## Regina di Bastoni

### dritta

- 1: Chi ti sta intorno si avvicina per quello che sei: hai una sicurezza calda che si vede da fuori e non ha bisogno di indicare la strada a nessuno per farsi sentire.
- 2: Nel punto in cui ti trovi il calore parte da te: la tua presenza occupa la stanza senza spegnere nessuno e il magnetismo non viene dalla stagione buona, viene dal tuo carattere.
- 3: Sei pienamente [te stesso|te stessa|chi sei] e si vede: generosità, fuoco, fiducia addosso. La luce di adesso non è un bel momento capitato per caso, è la tua.

### capovolta

- 1: In una stanza dove prima scaldavi tu, adesso conti le teste che si girano verso un'altra persona. Non si è velata la luce del momento: abbassi la tua per non sembrare di troppo.
- 2: Hai il calore intatto e lo tieni basso. Ti misuri con qualcuno che ti sembra più luminoso e da quel confronto esci sempre sotto, così parli meno, ti offri meno, ti spegni di un tono.
- 3: Il dubbio su di te ha un nome e una faccia: qualcuno vicino che sembra avere il fuoco che era tuo. Per non competere hai tolto legna al tuo e ora ti sembra tiepido.

## Re di Bastoni

### dritta

- 1: Gli altri aspettano la tua mossa per muoversi, perché hai già percorso il tratto che a loro manca. Ciò che dici pesa per le cose portate a termine, più che per il tono.
- 2: In mano hai un bastone che ha messo foglie, segno di una guida con radici nel mestiere. Dirigi persone che fanno un lavoro che conosci da dentro, perché l'hai fatto tu prima di dirigerlo.
- 3: Chi lavora con te ti chiede da che parte andare e la tua risposta è un passo, non una spiegazione. Stai dove sta chi prende la direzione di un'impresa e ne risponde davanti a tutti.

### capovolta

- 1: Comandi con una foga che non si ferma ad ascoltare: la direzione la dai senza chiedere se chi ti sta accanto ci sta. La tua spinta travolge le persone invece di accenderle.
- 2: Chi ti segue fa fatica a starti dietro, non per mancanza di meta. La meta la dai tu, dura e di corsa, senza che resti spazio per una parola diversa dalla tua.
- 3: La tua autorità si è irrigidita nell'impazienza. Non ti manca l'energia, non ti manca la rotta: ti manca l'ascolto. Chi ti circonda subisce il tuo passo invece di scegliere il suo.

## Asso di Coppe

### dritta

- 1: Dentro di te si è aperta una sorgente: senti più di quanto sai spiegare e il sentimento esce prima di avere un nome o un destinatario. È una condizione di pienezza, non ancora un legame.
- 2: C'è una tenerezza che ti riempie fino al bordo e sborda. Non nasce da un accordo con qualcuno, nasce da te: il cuore è in piena e l'acqua passa sopra ogni argine che avevi messo.
- 3: Ti trovi all'origine di un sentimento, nel punto esatto in cui sgorga. Nessun patto, nessuna promessa scambiata: soltanto una grazia che hai addosso e che rende dolce anche ciò che tocchi per caso.

### capovolta

- 1: Senti molto e non lasci uscire niente. Il sentimento è intero dentro di te, col coperchio tenuto fermo dalla tua mano: non manca l'altro, è la tua apertura a essere chiusa a chiave.
- 2: C'è un'acqua ferma dove dovrebbe scorrere. Hai messo via un amore per non pagarne il rischio e adesso quello che non dici ristagna in te, con il sapore di qualcosa che si guasta da sé.
- 3: La sorgente è tappata dal timore di soffrire: dentro hai tutto per amare e lo razioni goccia a goccia. Nessuno ha chiuso da fuori; il tappo è tuo, la mano sopra è la tua.

## Due di Coppe

### dritta

- 1: Fra te e un'altra persona si è sigillato un patto: nessun gruppo intorno, nessuna folla, soltanto voi che vi riconoscete. Quello che hai davanti è un legame alla pari, scambiato in parti uguali.
- 2: Ti trovi dentro un'armonia a due, di quelle in cui dai quanto ricevi senza contare. Non è un'emozione che nasce soltanto in te: è un riconoscimento reciproco e per questo è prezioso.
- 3: Le vostre mani si sono incontrate a metà strada e il legame che ne nasce porta il sigillo dello scambio. Questa forza non è solo tua: cresce quando ci si sceglie a vicenda.

### capovolta

- 1: Fra te e una persona sola è passata una frase presa per un'altra. Non c'è una ferita da rimarginare: vi volete bene come prima, si è incrinato l'ascolto, non il sentimento.
- 2: Resti a un passo da qualcuno che ti vuole bene come prima. Il patto regge, ma lo scambio si è fermato per una frase detta in un modo e sentita in un altro.
- 3: Il guasto fra te e l'altra persona sta in un fraintendimento, non in ciò che provate: non hai una delusione da smaltire, ma una frase girata male che vi fa parlare senza incontrarvi.

## Tre di Coppe

### dritta

- 1: Sei in mezzo a persone che ti vogliono bene e la gioia che circola fra voi è il punto di partenza: non un traguardo da celebrare ma l'affetto di un cerchio che tiene.
- 2: Attorno a te ci sono amicizie vive, bicchieri alzati, risate condivise. Quello che senti adesso non lo senti [da solo|da sola|in solitudine]: in compagnia si moltiplica.
- 3: La tua ricchezza adesso ha nomi e volti: le persone con cui condividi. Quello che ti scalda non è ciò che possiedi, è il legame fra te e chi ti sta accanto.

### capovolta

- 1: Il tuo giro di persone è largo e poco nutriente: tanti presenti, pochi davvero vicini. Nelle compagnie ti disperdi e torni a casa con meno di quello che hai dato.
- 2: Ci sono troppe facce intorno a te e poca sostanza fra voi. Non è un peso di responsabilità, è un brindisi ripetuto con chi non ti conosce e non ti chiede come stai.
- 3: Fra eccessi e inviti, il cerchio degli affetti veri si è assottigliato. Stai spendendo tempo dove non c'è nutrimento e le amicizie che contano le vedi sempre meno.

## Quattro di Coppe

### dritta

- 1: Sei nel punto in cui ti basta quello che hai: la mano che ti porge una cosa in più la vedi e la rifiuti senza soppesarla, per sazietà e per noia.
- 2: Hai detto no a una cosa buona senza esaminarla, perché le tue coppe ti sembrano già piene. Non ti trattiene un timore e non ti confonde l'abbondanza di strade: ti ferma la sazietà.
- 3: La tua condizione è quella di chi ha abbastanza e non assaggia: l'offerta sta a un palmo dalla tua mano e la lasci lì, perché niente di nuovo ti interessa.

### capovolta

- 1: Il torpore si sta sciogliendo e torni a sentire interesse per qualcosa. Non ti stai rialzando da una perdita e nemmeno da un bilancio severo: ti stai svegliando dalla noia.
- 2: Qualcosa ti incuriosisce di nuovo dopo un tempo in cui niente ti diceva nulla: quello che si apre non è un lutto che passa, è un appetito che torna.
- 3: Sei nel momento in cui lo sguardo si alza da solo. L'indifferenza perde terreno e una curiosità nuova ti chiama. Questa volta la senti venire senza sforzo.

## Cinque di Coppe

### dritta

- 1: Hai gli occhi su una cosa che si è già versata: il rimpianto occupa tutto il campo e quello che è rimasto in piedi sta dietro di te, fuori dal tuo sguardo.
- 2: La perdita è avvenuta e tu stai ancora sopra di essa: non c'è una scelta in sospeso, c'è un conto chiuso e un dolore reale che tiene il tuo viso rivolto indietro.
- 3: Conti quello che manca con precisione, mentre quello che resta non lo nomini: la tua posizione adesso è di spalle a ciò che è ancora intero.

### capovolta

- 1: Accanto alla cosa che hai perduto ce n'è una rimasta in piedi e la stai guardando. La perdita resta vera: si è spostata soltanto la direzione dei tuoi occhi.
- 2: Hai smesso di fissare il posto vuoto. L'accettazione ha cominciato il suo lavoro e il rimpianto non è finito, mentre il poco che ti resta intorno torna a contare.
- 3: Il tuo viso si è voltato di qualche grado verso ciò che c'è ancora: non si chiude una ferita né passa un torpore, una mancanza viene ammessa e smette di occuparti lo sguardo.

## Sei di Coppe

### dritta

- 1: Un affetto antico è tornato a scaldarti: un ricordo caro, una tenerezza d'infanzia, una bontà semplice che il tempo non ha consumato.
- 2: Il passato ti sta facendo un regalo in questi giorni. Volti, odori, gesti di un tempo buono ti nutrono senza chiederti niente in cambio.
- 3: C'è innocenza in ciò che ricordi con amore e quella dolcezza è la tua condizione di adesso: un calore che non hai cercato, arrivato da molto lontano nella tua vita.

### capovolta

- 1: Vivi dentro un tempo che non c'è più: i ricordi ti fanno compagnia meglio delle giornate vere. Il presente passa accanto a te senza trovarti davvero.
- 2: Quello che è stato ti tiene per un braccio. Lo rimpiangi più di quanto lo onori, così la memoria è diventata una stanza in cui resti invece di un posto da visitare.
- 3: La tua presa è tutta su un tempo finito: confronti ogni cosa di oggi con come era allora. La vita adesso ti chiama da fuori quella stanza, intanto tu stai dentro.

## Sette di Coppe

### dritta

- 1: Hai davanti più possibilità di quante ne puoi tenere e ognuna si presenta bene. Dentro alcune c'è sostanza, dentro altre fumo: dal posto in cui stai le due cose hanno lo stesso aspetto.
- 2: Molte strade ti chiamano insieme e nessuna si è ancora fatta concreta. Vivi in un'abbondanza immaginata: i tuoi desideri si affollano davanti agli occhi, più nitidi di qualsiasi fatto verificabile.
- 3: Il tuo momento è pieno di promesse non verificate. Le vedi tutte e le vuoi quasi tutte: nessuna ti ha chiesto ancora il prezzo di scegliere lei e di lasciare cadere le altre.

### capovolta

- 1: Il campo si è svuotato e ne resta uno: fra tutti i desideri che ti affollavano, uno regge ancora dopo che gli altri si sono dissolti. Non lo hai ottenuto, lo hai riconosciuto.
- 2: Sai quale strada vuoi e sai il prezzo: le altre le hai lasciate dove stavano. La chiarezza che hai adesso non viene da un ragionamento, viene dall'avere scelto e dall'avere perso il resto.
- 3: Dopo l'affollamento ti resta un desiderio unico. Quello che prima era vapore ha preso un contorno e un nome: la libertà in cui stai è fatta di rinunce accettate, non di porte aperte.

## Otto di Coppe

### dritta

- 1: Stai voltando le spalle a una cosa che funzionava e ha smesso di nutrirti, senza litigi e senza annunci. Il tuo cuore sa dove va, la testa ancora no ed è comunque già una partenza.
- 2: Hai cominciato ad andartene in silenzio da qualcosa di pieno che non ti riempie più. Nessuna scelta fra mille possibilità ti trattiene: dietro di te resta roba buona e non più tua.
- 3: Il passo che stai facendo è un'uscita di scena senza rumore da un luogo che agli occhi di tutti era in ordine: lasci per cercare un senso più alto, non per delusione.

### capovolta

- 1: Un piede ce l'hai già fuori dalla porta e l'altro dentro: la partenza è cominciata e non è decisa. Non stai evitando di guardare, stai guardando senza spostare il peso del corpo.
- 2: Resti sulla soglia della cosa che vorresti lasciare, con la valigia pronta accanto a te. La domanda non è dove andare, è se andarsene ed è a quella che non hai risposto.
- 3: Ti fermi a metà di un addio: dentro di te una parte ha già salutato e un'altra non si alza dalla sedia. Non è paura del buio, è sospensione fra due stanze che conosci.

## Nove di Coppe

### dritta

- 1: Hai ottenuto una cosa che desideravi da tempo ed è tua, nelle mani, non più nei progetti. Il piacere di adesso è pieno e personale, senza bisogno di nessun applauso.
- 2: Il tuo desiderio si è compiuto e il corpo lo sa: stai bene e te ne accorgi. Non ci sono molte strade davanti fra cui scegliere, c'è una cosa buona già arrivata.
- 3: Sei nel punto in cui il conto dei tuoi desideri torna in attivo. Il benessere è concreto e il cuore contento; l'unica cosa che ti trattiene è un vecchio senso di colpa.

### capovolta

- 1: Hai ottenuto quello che volevi e non ti colma. Il piacere arriva e passa in superficie: quello che mostri agli altri è più pieno di quello che senti [da solo|da sola|in privato].
- 2: Ti circondi di cose piacevoli che non toccano il fondo. Non sono sogni fra cui scegliere e non è noia: è una sazietà di facciata, già arrivata, che lascia la fame dov'era.
- 3: La soddisfazione che hai in mano resta sottile. Ogni volta che ottieni qualcosa il vuoto si sposta un poco più in là e tu lo riempi con un altro piacere breve.

## Dieci di Coppe

### dritta

- 1: La tua ricchezza in questo momento sono gli affetti intorno a te, non quello che possiedi. C'è armonia nei legami che hai. La pienezza che senti riguarda tutti quelli che ne fanno parte.
- 2: Ti trovi dentro una pienezza condivisa: le persone a cui tieni stanno bene con te e tu con loro. Non è un patrimonio da tramandare, è una contentezza che accade adesso e insieme.
- 3: Gratitudine, affetti al loro posto, una casa dove il clima è buono: questo è il punto in cui sei. La gioia qui non è una conquista solitaria, sta nel legame.

### capovolta

- 1: Stai in mezzo a una casa che ha perso l'accordo: ogni persona cara spinge dalla sua parte, sulle spese, sui tempi, su che cosa conta. Nessuno se ne va e niente si decide insieme.
- 2: Dentro la tua famiglia ciascuno ha preso una rotta sua e tu le reggi tutte. Nessun addio, nessuna lite aperta: un noi che si è smontato, con te nel mezzo a tenere i fili.
- 3: Hai una famiglia intera intorno e il patto che la teneva unita si è sfilacciato: tirano da parti diverse e tu fai da cerniera, mentre la serenità che davi per scontata ti costa fatica.

## Fante di Coppe

### dritta

- 1: Dentro di te si è affacciata un'emozione piccola e nuova: non trabocca, sussurra. C'è dell'immaginazione in quello che senti e una tenerezza che sorprende prima di tutto te.
- 2: Hai l'animo aperto come chi è ai primi passi: una notizia affettuosa, un'idea che nasce, una fantasia che ti commuove. Tutto è ancora ai minimi termini e già ti riguarda.
- 3: Qualcosa di gentile ha fatto capolino nella tua vita, ancora incerto sulle gambe: senti molto, in parte lo tieni per te e la creatività ti bussa insieme al sentimento.

### capovolta

- 1: Hai una pelle troppo fine per il giro in cui ti trovi e stai dietro una porta chiusa da te. Dentro l'emozione resta viva, mentre una parola da niente ti ferisce per intero.
- 2: Il punto in cui ti trovi è un ritiro: tieni per te quello che senti e non lo consegni a nessuno. Non assorbi l'umore altrui, custodisci il tuo e lo tieni basso.
- 3: Qualcosa di gentile in te ha preso un colpo e adesso sta dietro un vetro: provi ancora tutto, soltanto non lo dici. Se qualcuno si avvicina, lo copri subito.

## Cavaliere di Coppe

### dritta

- 1: Qualcuno si sta facendo avanti con grazia, oppure quello che si fa avanti sei tu: c'è una proposta sul tavolo, un invito offerto con garbo. Nessun patto è ancora sigillato.
- 2: Il tuo momento è quello del gesto romantico: un cuore offerto, una corte fatta con delicatezza. Non è un legame già formato, è il passo di chi porta il sentimento all'altro.
- 3: C'è un'offerta d'affetto in viaggio nella tua situazione, portata con eleganza e senza fretta. Più di un'emozione dentro di te: un corteggiamento che si vede anche da fuori.

### capovolta

- 1: Le parole d'affetto non trovano seguito nei gesti. La corte che ricevi, oppure quella che fai tu, resta sospesa a promesse che nessuno mantiene.
- 2: Ti muovi dentro un sentimento dichiarato e mai dimostrato. Suona bene, intanto nulla attecchisce: di quello che era stato detto non resta un fatto.
- 3: C'è una distanza fra ciò che viene detto e ciò che viene fatto, da parte tua o dell'altra persona: non un cuore ferito, una promessa senza radici, bella da sentire.

## Regina di Coppe

### dritta

- 1: Senti quello che gli altri non dicono e riesci a tenerlo senza spaventarti. La tua sensibilità non è un germoglio fragile, è una stanza dove le persone entrano volentieri perché vi trovano posto.
- 2: Chi ti sta intorno trova in te un'accoglienza che non chiede spiegazioni. Leggi gli stati d'animo in profondità e li sostieni: è una competenza matura, esercitata su molte persone prima di questa.
- 3: La tua condizione è quella di chi cura: l'intuito ti dice da dove viene il dolore di chi hai davanti e la tenerezza non ti indebolisce, la governi come un'acqua dentro un vaso.

### capovolta

- 1: Prendi dentro ogni stato d'animo che ti passa accanto e non trovi più il tuo. La cura esce da te in una direzione sola e nel conto il tuo nome non compare.
- 2: Il confine fra te e gli altri non tiene più: l'umore di chi ti sta vicino diventa il tuo in pochi minuti. Quello che senti è pieno di persone e vuoto di te.
- 3: Ti stai sciogliendo in chi accudisci. Ascolti tutti, assorbi tutto e per [te stesso|te stessa|te] non resta né attenzione né acqua. Ami fino al punto in cui non respiri più.

## Re di Coppe

### dritta

- 1: Le emozioni ti attraversano e non ti spostano: sei il punto fermo a cui gli altri approdano quando il mare è grosso. Qui non c'è assorbimento di stati d'animo, c'è una mano salda sul timone.
- 2: Ti trovi in una calma che hai imparato, non in una sensibilità che ricevi. Le onde le percepisci tutte ed è la tua mano a decidere dove vanno, non il contrario.
- 3: Quello che senti lo tieni come si tiene l'acqua in un bacino: non ti travolge e non lo congeli. La tua maturità affettiva adesso regge il peso anche degli altri, senza inondarsi.

### capovolta

- 1: Ti si chiede calma e intanto attorno a te tutti aspettano di capire come sei oggi prima di aprire bocca. Non assorbi l'umore degli altri: è il tuo a decidere il clima.
- 2: Il tuo affetto sta diventando moneta di scambio: lo dai quando ti serve un passo dall'altra parte e lo togli quando non arriva. La maturità c'è, ma comanda l'umore.
- 3: Gli altri si appoggiano a te come a un punto fermo e quel punto oggi oscilla a ogni ora: è il tuo stato a riempire la stanza e a dare il tono.

## Asso di Denari

### dritta

- 1: Hai davanti un'apertura concreta: un lavoro, un progetto, una base che si tocca con le mani. Non è un'ispirazione da inseguire, è terreno già pronto sotto i tuoi piedi.
- 2: Il punto in cui sei ha radici: quello che avvii adesso poggia su qualcosa di solido e di misurabile. Nessuna attesa, nessun fuoco: un seme in mano e il campo aperto.
- 3: Ti arriva un'occasione materiale, piccola e vera. Non chiede entusiasmo e non chiede pazienza: sta lì con le sue basi sotto e si vede a occhio nudo quanto vale.

### capovolta

- 1: Un'apertura concreta ti sta passando accanto e guardi altrove. Oppure i conti li hai fatti male e il rischio che hai preso è più grande di quanto ammetti.
- 2: Hai fra le mani qualcosa di materiale e lo tratti con distrazione. Non è lo slancio a mancarti, è l'attenzione: una base si sta sfaldando mentre pensi ad altro.
- 3: La tua occasione è lì, non vista oppure mal pesata. Il terreno c'era, il seme è rimasto in tasca e intanto il momento buono si consuma senza fare rumore.

## Due di Denari

### dritta

- 1: Tieni insieme più cose nello stesso momento e il ritmo regge. Non è una pratica sola da affinare e non è un passo regolare: è un movimento continuo fra impegni diversi, fatto con leggerezza.
- 2: Ti stai adattando bene a un carico che cambia forma ogni giorno. Niente di fermo nelle tue mani: tutto passa da una all'altra. La flessibilità è quello che ti tiene in piedi.
- 3: Più impegni girano insieme e nessuno cade a terra. Non è equilibrio interiore, è destrezza pratica: finché non ti irrigidisci, il gioco ti viene bene e regge.

### capovolta

- 1: Girano fra le tue mani più cose di quante il tempo ne consenta e il ritmo si è spezzato. Una sta già scendendo mentre le altre restano sospese.
- 2: La tua situazione è quella di chi ha perso il tempo del giro: niente di ciò che porti pesa da solo, ma il momento di prendere una cosa arriva quando un'altra è già scesa.
- 3: Stai in un equilibrio che si è fatto rigido: il terreno si muove, gli impegni si sono moltiplicati e la leggerezza con cui li alternavi è sparita. Qualcosa è già a terra.

## Tre di Denari

### dritta

- 1: Lavori dentro un'opera che non è soltanto tua: ognuno ha il suo pezzo, i primi risultati si vedono già e la tua competenza viene riconosciuta da chi ti sta accanto.
- 2: Il punto in cui stai è un cantiere a più mani: non aspetti niente da lontano, costruisci adesso con altre persone e il materiale sotto le dita è concreto.
- 3: Qualcuno apprezza quello che fai e lo dice: sei nel mezzo di un lavoro condiviso dove le tue capacità servono davvero e quello che hai messo in piedi si tocca.

### capovolta

- 1: Nessuno sa bene chi fa cosa, nel lavoro che vi tiene insieme: non c'è una lite aperta, c'è un ingranaggio che gira a vuoto e aspettative che nessuno ha detto chiaramente.
- 2: Sei dentro un'opera comune che non ingrana: compiti sovrapposti, poca sintonia, ogni passaggio da rifare due volte. La competenza c'è, anche la tua, ma manca chi coordina le mani.
- 3: Fra te e chi lavora con te il malinteso è di ruolo, non di volontà: ognuno dà per scontato un pezzo diverso e quello che dovrebbe salire insieme resta fermo a metà.

## Quattro di Denari

### dritta

- 1: Stai nella posizione di chi custodisce: quello che è tuo lo conti, lo chiudi, lo controlli e resta intero. Il prezzo è che le mani serrate su quel bene non accolgono altro.
- 2: Il tuo punto fermo è una scorta protetta. Nessuna norma da imporre a nessuno e nessun patrimonio da amministrare, soltanto una quantità precisa tenuta addosso, da cui viene la sicurezza che senti.
- 3: La sicurezza che hai adesso è fatta di risparmio e di controllo: spendi poco, verifichi, non lasci uscire niente senza il tuo permesso. Dentro quel recinto nulla si disperde ed entra altrettanto poco.

### capovolta

- 1: La paura di perdere irrigidisce ogni presa: trattieni tutto, soldi, energie, affetti. Niente passa più, né verso di te né verso gli altri.
- 2: Quello che stringi ha cominciato a stringere te. L'attaccamento è cresciuto oltre la misura della prudenza, così la tua mano resta chiusa anche quando aprirla ti conviene.
- 3: Nel tuo momento comanda un timore preciso, perdere. Per questo il flusso si è fermato: tenere ti è diventato più urgente che usare quello che hai.

## Cinque di Denari

### dritta

- 1: Ti trovi fuori, con il freddo addosso e la luce accesa dietro un vetro che non è tuo. Manca qualcosa di concreto e manca la compagnia: nessuno nota il tuo passaggio.
- 2: C'è una mancanza che si conta: quello che hai non basta e intorno nessuno sembra accorgersene. Cammini a lato di porte chiuse, con la vergogna che ti tiene la bocca ferma.
- 3: Il punto in cui stai è un fuori. Esclusione, poco in tasca, la sensazione di non essere nella lista di nessuno: chiedere ti costa più della fame e per questo non chiedi.

### capovolta

- 1: La porta si è aperta e il freddo ti sta uscendo dalle ossa. Qualcuno ti ha fatto posto e la mancanza che contavi ogni giorno si allenta, un passo dopo l'altro.
- 2: Hai di nuovo un sostegno sotto i piedi: non stai più dalla parte esterna del vetro. Il periodo duro ha smesso di stringere e chiedere ti è costato meno del previsto.
- 3: Il freddo lascia la presa. Dopo un tratto passato fuori, qualcosa ti riprende dentro: un aiuto accettato, una mano riconosciuta, il primo pasto caldo di una ripresa che va a passi corti.

## Sei di Denari

### dritta

- 1: Fra te e gli altri qualcosa circola in due direzioni: dai aiuto e ne ricevi senza che i piatti della bilancia si inclinino. È uno scambio concreto, in corso adesso.
- 2: Ti trovi nel punto in cui quello che esce dalle tue mani e quello che vi rientra hanno lo stesso peso. La tua abbondanza si misura da quanto passa, non da quanto tieni.
- 3: Qualcuno riceve da te e qualcuno ti sostiene, nello stesso periodo. Non si tratta di meriti da pesare: si tratta di beni e di aiuti che si muovono con giustizia.

### capovolta

- 1: Dalle tue mani esce molto più di quanto rientri e la cosa ti sta svuotando. Non hai troppi impegni insieme: hai un rapporto di dare e ricevere inclinato tutto da una parte sola.
- 2: Nel dare hai perso la misura: quello che offri non torna e qualcuno conta su di te senza ricambiare. Il conto qui non è morale, è materiale ed è rimasto aperto da tempo.
- 3: Quello che regali a chi non ricambia ti pesa come un debito. Non è una verità da guardare in faccia: è un flusso che va in una direzione sola, da te verso fuori.

## Sette di Denari

### dritta

- 1: Hai già fatto la tua parte e adesso guardi crescere senza intervenire. Il lavoro è nel terreno, non nelle tue mani; il tempo che passa lavora al posto tuo.
- 2: Ti trovi in una pausa che non è inerzia: osservi quello che hai piantato, valuti, aspetti. I frutti sono ancora verdi e la pazienza ti sta riuscendo.
- 3: Sei in attesa di qualcosa che matura da sé. Niente da aggiungere, niente da togliere: guardi il raccolto che si forma e hai la calma di non toccarlo.

### capovolta

- 1: L'attesa ti si è fatta insopportabile e il tempo lo tiri con i denti. Guardi quello che hai piantato e il dubbio è sul seme, non soltanto sulla stagione.
- 2: Hai lavorato molto e il ritorno non si vede. Quello che senti adesso è impazienza mescolata a sfiducia, il sospetto di avere speso energia nel campo sbagliato.
- 3: Non riesci più ad aspettare davanti a quello che cresce. Strappi con gli occhi dei frutti ancora verdi e ogni giorno senza risultati ti pesa più del giorno prima.

## Otto di Denari

### dritta

- 1: Stai affinando una cosa alla volta, con le mani dentro il lavoro. Non c'è fretta nel modo in cui procedi: la pratica si ripete, il dettaglio si corregge, il mestiere cresce così.
- 2: Sei dentro un impegno che chiede ripetizione. Quello che fai bene oggi diventa abilità tua domani. Per ora il tuo posto è al banco, con la cura rivolta a un particolare dopo l'altro.
- 3: La tua condizione adesso è quella di chi impara facendo. Nessun colpo di genio: ore, gesti ripetuti, correzioni minime. La maestria nasce proprio da qui.

### capovolta

- 1: Fai i gesti giusti senza esserci dentro. Il mestiere che ti teneva adesso si ripete a vuoto. Quello che manca non è la capacità ma il senso di farlo.
- 2: La cura si è persa per strada e resta la ripetizione. Dove prima c'era dedizione ora c'è un'abitudine che ti chiude come una gabbia.
- 3: Lavori bene e non ti dice più niente. La monotonia ha preso il posto della passione e la domanda su dove stai andando ti gira in testa da un po'.

## Nove di Denari

### dritta

- 1: Stai in uno spazio tuo, costruito senza chiedere permesso a nessuno: quello che hai intorno viene dalle tue mani e lo usi, non lo tieni sotto chiave.
- 2: La tua indipendenza è reale: cammini nel giardino che hai piantato, hai tempo tuo, silenzio tuo e la calma di non dipendere dalle mani di altri.
- 3: Ti godi i frutti di un lavoro lungo: la posizione in cui sei la sostieni da [solo|sola|te], con serenità e senza paura di aprire la mano.

### capovolta

- 1: Hai una libertà che nessuno ti ha regalato e la stai consumando in spese fuori misura. Quello che possiedi lo tieni perché sia visto, non perché serva: il tuo stare bene dipende dagli occhi altrui.
- 2: La tua autonomia poggia sul tuo lavoro e si consuma da dentro: spendi più di quanto l'agio sopporti, soprattutto in ciò che si nota. Nessuno ti chiede di trattenere, è saltata la tua misura.
- 3: Quello che hai messo insieme da te ti ha dato una vita comoda e adesso la mantieni per mostrarla: le uscite crescono con lo sfoggio e l'indipendenza che le pagava si accorcia.

## Dieci di Denari

### dritta

- 1: Quello che hai costruito non si ferma a te: regge una casa, nutre chi ti sta intorno, tiene in piedi anche chi viene dopo di te. La tua stabilità ha radici lunghe.
- 2: Sei dentro una solidità che riguarda più persone della tua sola: famiglia, beni, radici messe giù bene. Non è il successo di uno, è il patrimonio di una stirpe.
- 3: La tua ricchezza di adesso è quella che dura: muri, terra, legami di sangue, cose che non si consumano in una stagione. Stai piantando qualcosa che vive più di te.

### capovolta

- 1: Il tuo nome sta su beni che portano anche il nome dei tuoi ed è lì che si è aperto l'attrito: casa, terreno, conto di famiglia li rivendicano in tanti, insieme a te.
- 2: Stai dentro una famiglia che discute su quello che possiede insieme. Non ti manca niente di materiale, ti manca il diritto di decidere per conto tuo su cose che appartengono anche ai tuoi.
- 3: Ti trovi in mezzo a una spartizione fra parenti: ciò che tiene in piedi la tua casa lo dividi per nascita con altri e adesso ognuno fa il conto della sua parte.

## Fante di Denari

### dritta

- 1: Sei al principio di qualcosa che non sai ancora fare e lo impari facendolo: ogni prova ti lascia in mano un pezzo di risultato, piccolo e concreto, che prima non avevi.
- 2: Il tuo è il tempo dell'apprendista: la mano sicura non ce l'hai ancora e hai davanti una promessa pratica che cresce esattamente quanto l'esercizio che le dai.
- 3: Stai imparando una cosa nuova mentre la fai: ogni esercizio lascia un segno fuori di te, in una materia che prende forma invece di restare un'intenzione.

### capovolta

- 1: Hai promesso di imparare e non hai ancora praticato: la lezione l'hai presa, il banco è lì, ma la tua testa è scivolata su un'altra curiosità prima che il gesto diventasse tuo.
- 2: Stai all'inizio di un impegno aperto con qualcuno su una cosa da fare bene. Non ti pesa la ripetizione, ti manca il saper fare: non hai ancora cominciato davvero.
- 3: Quello che hai studiato resta studio e nelle tue mani non è passato niente. Un lavoro pratico aperto da poco ti aspetta nel punto esatto dove la distrazione te lo ha fatto lasciare.

## Cavaliere di Denari

### dritta

- 1: Cammini al tuo passo, sempre lo stesso, giorno dopo giorno. Qui non stai aspettando che qualcosa maturi: ti stai muovendo ed è la costanza, non la velocità, a fare la tua forza.
- 2: Sei nel mezzo di un lavoro fatto con metodo: quello che dici lo fai nei tempi promessi, nessuna attesa ti blocca e attraversi il terreno a piedi, un solco alla volta.
- 3: Avanzi lentamente e senza salti, con l'affidabilità di chi arriva dove ha promesso. La lentezza addosso a te non è un limite: è il modo in cui copri la distanza senza perdere colpi.

### capovolta

- 1: Hai il percorso chiaro davanti e la meta non si è spostata: si è fermato soltanto il tuo avanzare, perché la regolarità è diventata una cautela che rinvia ogni tappa.
- 2: Sei dentro un cammino giusto che non procede: conosci la via e sai dove sbuca, ma ogni tappa slitta a un giorno con meno rischi e l'andatura regolare si è irrigidita.
- 3: Il tuo momento è quello di chi sta in sella senza muoversi: la meta è sotto gli occhi, ma ogni mattina la prudenza decide che non è giornata per partire.

## Regina di Denari

### dritta

- 1: Nelle tue mani le cose crescono: la casa, il lavoro, le persone che ti stanno intorno. È una cura concreta, fatta di pasti, di conti in ordine, di attenzioni quotidiane.
- 2: Hai il dono raro di unire il cuore e la praticità. Chi entra nella tua giornata trova da mangiare e un posto dove sedersi, non per fortuna ricevuta ma per mano tua.
- 3: La tua è un'abbondanza terrena e generosa, costruita a mano. Tieni insieme il bilancio e l'affetto; intorno a te la vita materiale sta in piedi senza sforzo apparente.

### capovolta

- 1: Nella tua giornata provvedi a tutti e di te non si occupa nessuno, nemmeno tu: la spesa, le bollette, gli appuntamenti degli altri. Ciò che riguarda te resta su un foglio chiuso.
- 2: Mangi in piedi fra due cose da sbrigare, rimandi la visita che riguarda te, mentre la casa gira, i conti tornano e nessuno resta senza niente. Il tuo nome manca dalla lista.
- 3: Sei come un pozzo aperto a tutti che nessuno riempie: dai tempo, soluzioni pratiche, la spesa contata al centesimo, fai le faccende degli altri al posto delle tue.

## Re di Denari

### dritta

- 1: Quello che hai costruito sta in piedi da sé e tu lo governi con misura. Non è soltanto ricchezza: è la competenza di gestirla. Intorno a te c'è chi ne ricava qualcosa.
- 2: Sei in una posizione di solidità concreta. Il successo c'è e la generosità pure. La tua autorità viene dalle cose fatte, non da quello che prometti.
- 3: Hai la mano ferma su un patrimonio che funziona. Nessun timore di perderlo, nessuna stretta: lo fai circolare perché la tua sicurezza non dipende dal trattenerlo.

### capovolta

- 1: Quello che hai costruito ha cominciato a comandarti. Non è il timore di restare senza: è l'abbondanza stessa che ti irrigidisce. Il tuo governo sulle cose si è chiuso.
- 2: Hai molto e lo tieni fermo. La misura con cui guidavi si è fatta durezza, perché quello che possiedi è diventato il modo in cui valuti te.
- 3: Governi molto e lo fai col pugno chiuso. Non è un piccolo risparmio da difendere: è la tua stessa prosperità che ha smesso di circolare e con lei anche tu.

## Asso di Spade

### dritta

- 1: Stai vedendo una cosa con una nitidezza che non lascia scampo: il falso si è separato dal vero davanti ai tuoi occhi e il taglio è netto, senza mezze misure.
- 2: Hai in testa un'idea affilata e pulita: capisci dove sta il punto, sai come si chiama e il nome giusto delle cose ti sta sulla punta della lingua.
- 3: La confusione si è aperta in due nella tua mente: distingui con precisione quello che regge da quello che non regge e questa lucidità adesso ti appartiene.

### capovolta

- 1: Hai in mano uno strumento affilato e la testa nella nebbia: davanti a una decisione da prendere non ne vedi ancora il bordo, così lo stesso filo può liberarti oppure costarti qualcuno.
- 2: Non è freddezza la tua, è foschia: giudichi con la mente velata proprio quando una scelta ti aspetta. Ciò che tieni in pugno apre un nodo oppure ferisce, secondo come lo porti.
- 3: Le idee ti arrivano velate e intanto le parole ti escono con la punta fuori: il tuo attrezzo è giusto, è la mano che lo stringe male, così tagli di traverso ciò che vorresti sciogliere.

## Due di Spade

### dritta

- 1: Tieni due cose in equilibrio senza guardarle: le pesi uguali, non scegli, resti in uno stallo che a te sembra pace. La decisione che rimandi non si è mossa di lì.
- 2: Hai gli occhi coperti su una scelta che ti riguarda. Finché non guardi, le due parti restano allo stesso peso. La quiete che senti è precaria, non vera.
- 3: Il tuo momento è di indecisione tenuta ferma a forza. Eviti di guardare quello che pesa, così niente si muove in nessuna delle due direzioni possibili.

### capovolta

- 1: La benda è caduta. Quello che coprivi adesso lo vedi, la scelta che tenevi sospesa è tornata davanti a te senza più niente che la nasconda.
- 2: Il blocco si sta sciogliendo nel tuo momento. Non ti chiama una vita nuova, non viene a galla nessun inganno: torna una decisione tua, rimandata, che adesso ha un volto.
- 3: Quello che evitavi di guardare è a fuoco. Lo stallo tenuto a occhi chiusi si è aperto. La risposta che non hai dato ti sta aspettando a viso scoperto.

## Tre di Spade

### dritta

- 1: C'è un dolore preciso al centro del petto e ha una causa che sai nominare. Non è malinconia diffusa: è un taglio netto e recente, con le lacrime ancora pronte.
- 2: Un colpo è passato attraverso il tuo petto ed è ancora caldo: una parola, una verità, un abbandono. Stai nel pieno della ferita, dove il dolore si misura a respiri.
- 3: Hai il petto aperto da un dolore che non chiede interpretazioni. Delusione, perdita, parole che hanno trovato il bersaglio: il tempo del pianto è questo, non uno successivo e più comodo.

### capovolta

- 1: Il sangue si è fermato. La ferita c'è ancora ma non si riapre a ogni movimento: il perdono ha cominciato il suo lavoro e il tuo respiro torna più profondo.
- 2: La pioggia sta passando sopra di te e il petto si richiude. Il colpo di allora ha un nome che pronunci senza piegarti: resta il segno, non il taglio.
- 3: Non hai dimenticato niente e hai smesso di sanguinare. Il dolore sfuma ai bordi come un livido che cambia colore: lo tocchi e cede meno di prima.

## Quattro di Spade

### dritta

- 1: Sei in una pausa e questa pausa ti serve: dopo la fatica il silenzio è il tuo posto. Nessuna decisione sospesa, solo un corpo e una mente che rimettono insieme le forze.
- 2: Il rumore si è spento intorno a te e il tempo che passa non è perso. Stai riprendendoti, non rimandando: qui la quiete è un lavoro che va avanti da sé.
- 3: Hai smesso di combattere per un poco ed è una sosta, non una resa. La stanchezza c'è e il silenzio attorno a te sta facendo il suo mestiere mentre tu non fai nulla.

### capovolta

- 1: Il riposo che ti serviva lo hai fatto e il bisogno di immobilità è finito. Nessun ritardo ti trattiene: la sosta ha chiuso il suo compito e tu sei già oltre.
- 2: [Ti sei ripreso|Ti sei ripresa|Hai recuperato] le forze e la quiete non ha più niente da darti. Quello che senti non è fretta, è un corpo che non ha più ragione di stare giù.
- 3: Le forze sono tornate mentre stavi in silenzio: non più stanchezza, non ancora corsa. La pausa è alle tue spalle e la stanza comincia a stare stretta.

## Cinque di Spade

### dritta

- 1: Hai vinto e il prezzo lo stai pagando adesso. Nessuno applaude, sul campo sono rimasti rapporti rotti e l'orgoglio che ti spingeva fino in fondo non ti scalda.
- 2: Sei dalla parte di chi ha avuto ragione e la ragione ti è costata più di quanto renda. Il conflitto si è chiuso con una perdita tua, intestata al tuo nome.
- 3: Il tuo guadagno porta un segno meno nascosto. Hai tenuto il punto fino a vincere, hai perso qualcuno per strada e il successo ti sta in mano come una cosa fredda.

### capovolta

- 1: Ti trovi dalla parte che ha vinto, con la ragione intera in tasca e davanti qualcuno che avevi contro. La voglia di deporre le armi ti arriva prima che all'altra parte.
- 2: Nello scontro appena finito sei la parte che non aveva torto, ma il torto riconosciuto non ti basta più: adesso il perdono ti pesa meno della ragione.
- 3: Dentro di te il perdono è già in piedi e aspetta il tuo passo. Hai in mano il torto dell'altra parte, lo tieni e non lo usi: la pace ti sembra più vicina della soddisfazione.

## Sei di Spade

### dritta

- 1: Ti stai allontanando da acque agitate e il mare, dietro di te, si fa più piatto. Non sei ancora sull'altra sponda: sei nel tragitto e questo tratto procede senza scosse.
- 2: La tempesta è alle spalle e tu sei in mezzo al passaggio. Ti muovi piano, un colpo di remo dopo l'altro. La calma intorno è la condizione in cui ti trovi adesso.
- 3: Hai lasciato il peggio dietro di te. Quello che stai attraversando non è una fuga e non è uno strappo: è una traversata tranquilla verso una riva più quieta.

### capovolta

- 1: Il distacco è in corso e ti costa più del previsto. Niente da decidere: il passo è fatto, ma ti accorgi solo adesso di quanto pesa ciò che hai lasciato dall'altra parte.
- 2: Avanzi con mezzo cuore rimasto indietro. Il corpo è già nel tragitto, l'attaccamento sta ancora dove l'hai lasciato. Abiti due luoghi insieme e tiri il secondo dietro di te.
- 3: Stai lasciando qualcosa e la fatica non nasce da un dubbio ma dal legame. La partenza non si discute più, però il tuo passo è carico del tempo che chiudi alle spalle.

## Sette di Spade

### dritta

- 1: Ti muovi in silenzio e di lato: niente carica frontale, niente domande fatte in giro, una mossa calcolata che tieni per te mentre gli altri guardano altrove.
- 2: Stai giocando d'ingegno invece che di forza: prendi la via obliqua, parli il meno possibile e il vantaggio in questo momento sta in quello che non dici.
- 3: Nella tua situazione agisci al coperto: hai una strategia in mano, la porti avanti un pezzo alla volta e nessuno intorno a te conosce il disegno intero.

### capovolta

- 1: Un inganno ti pesa addosso, tuo oppure di qualcun altro, mentre sale a galla da solo: la copertura si assottiglia e tu lo senti.
- 2: Qualcosa di nascosto sta uscendo allo scoperto nella tua situazione: una bugia da mantenere ti costa ogni giorno più fatica e la coscienza tiene il conto.
- 3: Porti il peso di una cosa non detta: il doppio gioco, da qualunque parte venga, ha cominciato a mostrare le cuciture e la quiete che ti dava se n'è andata.

## Otto di Spade

### dritta

- 1: [Ti senti bloccato|Ti senti bloccata|Ti sembra di non poterti muovere], però niente ti tiene davvero: le corde sono larghe, la benda è appena appoggiata. La prigione è fatta di pensieri tuoi.
- 2: Quello che ti ferma non è una catena né un desiderio che ti lega: è la tua testa, che ha disegnato muri dove ci sono passaggi. Non li hai ancora misurati da vicino.
- 3: La tua situazione sembra chiusa da ogni lato e lo sembra guardandola da dentro. Nessuno ti stringe, nessuna tentazione ti trattiene: ti trattiene la paura di muoverti.

### capovolta

- 1: Scopri che non c'era nessuna catena: la trappola la teneva in piedi la paura, non un legame vero. [Eri più libero|Eri più libera|Avevi più libertà] di quanto credevi.
- 2: Una via si è aperta dove vedevi muro. Non hai sciolto nessun nodo, non hai lasciato niente: hai visto che il nodo non esisteva. Adesso il primo passo fuori è a portata.
- 3: Il senso di trappola si sta sgonfiando. Le corde non erano corde, la benda l'hai tolta tu. Il coraggio che credevi di non avere era lì da sempre.

## Nove di Spade

### dritta

- 1: Di notte ti svegli e la testa comincia a lavorare contro di te. Non è accaduto niente di nuovo: sono i pensieri che si moltiplicano al buio, nell'attesa del mattino.
- 2: Le tue ore peggiori sono quelle piccole, fra il sonno che non viene e il mattino che tarda. All'ansia non servono fatti per crescere: le basta il silenzio e la tua attenzione.
- 3: Hai la mente accesa quando tutto è spento. Quello che di giorno regge, nel cuore della notte diventa enorme e la tua testa lo racconta con parole che il mattino non userebbe.

### capovolta

- 1: Il peggio della notte è passato e la mente ha smesso di girare. Quello che hai detto a qualcuno pesa meno di prima: fuori dalla tua testa l'incubo ha un contorno normale.
- 2: La paura allenta la presa e il sonno torna per qualche ora. Il pensiero che ti torturava, raccontato a un orecchio amico, ha perso il tono notturno.
- 3: Sei dalla parte giusta dell'alba. Quello che ti angosciava è stato detto e non è più soltanto tuo: resta un residuo di stanchezza, con la morsa però ormai aperta sul collo.

## Dieci di Spade

### dritta

- 1: Sei a terra dopo una contesa combattuta fino in fondo e il colpo che temevi è già caduto. Non stai trattenendo qualcosa che finisce: riconosci che quella battaglia è chiusa.
- 2: Hai le mani vuote e le armi abbassate nel punto più basso del giro. La forza che ti teneva a terra ha esaurito i suoi colpi: resistere ancora ti appare inutile.
- 3: La tua posizione è quella di chi ha perso una contesa e lo sa già. Le lame hanno finito di cadere e dentro di te la resa ha preso il posto dell'ultimo tentativo di tenere.

### capovolta

- 1: Ti stai alzando da terra e il terreno attorno a te è vuoto: della faccenda di prima non resta un pezzo utilizzabile. Il tuo movimento è lento e non te lo sta dando nessuno.
- 2: Il tuo punto di partenza è il fondo toccato per intero. Hai le mani libere perché non ti è rimasto niente da tenere: da lì rimetti su un gesto per volta.
- 3: Adesso rimetti in piedi qualcosa partendo dal nulla, dentro una faccenda che si è chiusa del tutto. Nessun carico da posare ti pesa addosso: il terreno è libero e sei tu a muoverti.

## Fante di Spade

### dritta

- 1: Sei nel mezzo di una ricerca che non hai finito e riferisci già quello che hai trovato: i pezzi passano ad altri prima che tu li abbia messi in ordine.
- 2: Interroghi chiunque capiti e ripeti la risposta appena ti arriva. Non hai in mano una verità da dire: hai un dettaglio appena pescato e la fretta di passarlo.
- 3: La tua condizione è quella dell'apprendista con gli occhi aperti: ti informi su una cosa che non ti torna e la racconti mentre la stai ancora raccogliendo, con più scoperte che conclusioni in tasca.

### capovolta

- 1: Vivi dentro un giro di chiacchiere su gente assente. Una mezza frase è passata di bocca in bocca fino a te e l'hai ripetuta senza controllarla: nessuno ci ha guadagnato, nemmeno tu.
- 2: La tua lingua corre su notizie di seconda mano. Non copri un inganno tuo e non rincorri una meta: fai il giro delle orecchie con pensieri sparsi su chi non può rispondere.
- 3: Hai sentito metà di una cosa e la racconti come intera. Spii dalla collina senza l'esperienza per leggere quello che vedi: la frase che hai in bocca punge e non costruisce niente.

## Cavaliere di Spade

### dritta

- 1: Punti allo scopo senza deviazioni, con la mente già decisa. Non è una verità appena vista né una passione che ti scalda: è un pensiero lanciato in azione, più veloce degli altri.
- 2: Ti muovi veloce perché hai già capito dove si taglia. La rapidità adesso è un tuo dono e chi ti sta accanto fa fatica a tenere il tuo passo.
- 3: Hai idee decise e il piede sull'acceleratore. Quello che ti spinge non è il desiderio, è la lucidità: a questa velocità, però, la lucidità passa sopra a qualcuno senza accorgersene.

### capovolta

- 1: Parli prima di pensare e le tue parole tagliano. Non è malignità e non è freddezza: è la corsa, perché la pausa che ti servirebbe non la stai prendendo.
- 2: Ti muovi troppo in fretta per vedere dove arrivi. La lucidità non ti manca, la usi solo dopo: intanto quello che hai detto ha già fatto il suo effetto.
- 3: Decidi di corsa e affondi con la lingua. Niente nebbia nella tua testa, solo velocità: ti fa tornare indietro sui tuoi passi più di una volta.

## Regina di Spade

### dritta

- 1: Hai confini chiari e li fai rispettare: dici il vero senza addolcirlo, anche quando costa, perché questa nettezza è quello che adesso ti tiene al sicuro.
- 2: Nella tua situazione non ti racconti storie: distingui le persone e le cose con una freddezza utile, parli senza giri di parole e nessuno può usarti per comodità.
- 3: La lucidità è la tua condizione di adesso, non un ruolo che reciti per altri: vedi dove finisci tu e dove comincia chi ti sta davanti e lo dici senza abbellirlo.

### capovolta

- 1: Hai scelto la distanza come armatura: non è riposo, è difesa. La severità che tieni per [te stesso|te stessa|te] è la più tagliente che hai in casa e non fa sconti a nessuno.
- 2: La durezza che mostri fuori è la metà di quella che tieni dentro: abiti una solitudine che chiami scelta, con la lama girata verso chi la porta.
- 3: Nessuno entra più facilmente dove sei: ogni frase la pesi prima di dirla, ogni gesto di altri passa dal tuo esame e questa corazza ti costa il calore che avevi.

## Re di Spade

### dritta

- 1: Decidi con la testa lucida e con una misura etica che non svendi: sei il punto di riferimento a cui gli altri portano le questioni difficili da sbrogliare.
- 2: La tua autorità in questo momento è mentale: pesi i fatti, dici il vero, tagli le questioni con equità. Non è una legge a giudicare al tuo posto, sei tu a farlo.
- 3: Hai lucidità e onestà nello stesso momento. La tua parola pesa per questo. Non è la calma del cuore a reggerti, è una ragione messa al servizio di ciò che è giusto.

### capovolta

- 1: Il tuo rigore sta cadendo sulle persone: hai ragione nelle discussioni, intanto i legami intorno a te si raffreddano. La logica comanda, la compassione tace.
- 2: Giudichi dall'alto in questo periodo, con una durezza rivolta verso fuori. Non eviti nessuna verità, non ti chiudi per difenderti: applichi la regola e dimentichi chi hai davanti.
- 3: C'è freddezza nel modo in cui tratti chi ti sta intorno. Nasce da un'autorità convinta di avere sempre la misura esatta: vinci i confronti, perdi le persone.
