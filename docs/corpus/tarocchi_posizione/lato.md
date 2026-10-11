# LA POSIZIONE: LATO

Il lato della croce di Dora: che cosa la carta mette sulla strada, senza chiamarla consiglio ne' ostacolo (voce FI.21).

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
dall'Architetto e scelte con la prova appaiata: i testi dei corpus candidati
messi nello stesso giro davanti a dodici lettori che non sapevano quale testo
venisse da quale corpus. La posizione sta all'81,2 per cento di carte
riconosciute da un lettore che legge il testo senza il nome della carta, contro
il 75,9 del corpus da cui parte, con novantatre testi su quattrocentosessantotto
riscritti dal cardine differenziale, cioe' dal tratto che la fonte da' alla carta
e non alla carta con cui i lettori la scambiavano. Il metodo, i numeri e le
cinque carte che restano irriconoscibili per un difetto della fonte dei
significati stanno in `claude/Prova_Appaiata_Corpus_Tarocchi_2026-10-11.md`.

## Il Matto

### dritta

- 1: Ti chiama un inizio che non ti mostra il suo esito e la leggerezza con cui ne afferri il primo passo vale il coraggio che sembra mancarti.
- 2: La fiducia che ti muove adesso non nasce da una mappa completa ma dalla voglia di partire con poco addosso e senza garanzie.
- 3: Una partenza che nessuna garanzia sostiene ti pesa meno di quanto credi e la libertà di cominciare non si misura in bagagli.

### capovolta

- 1: Lo slancio che ti spinge non ha una direzione e il timore ti trattiene sull'orlo proprio mentre vorresti spiccare il volo.
- 2: Un impulso di cui non conosci la sorgente ti muove i piedi prima che tu abbia guardato da dove nasce: coraggio e fuga si somigliano molto, da fuori.
- 3: Partire senza sapere perché è un modo di restare fedele all'impulso, oppure di scappare da qualcosa che non hai guardato in faccia.

## Il Mago

### dritta

- 1: Gli strumenti li hai già addosso e la volontà di usarli ti appartiene, perciò un'intenzione può farsi gesto, parola detta, passo compiuto, senza aspettare condizioni perfette.
- 2: Sai fare la cosa che pensi e la tua mano risponde al pensiero senza ritardo. Un progetto tenuto nella testa può scendere nelle dita e diventare oggetto, frase pronunciata, inizio.
- 3: Quel che tieni fermo nella volontà può passare al mondo visibile adesso, perché hai la capacità e il materiale. Nulla ti trattiene tranne l'attesa di un segnale esterno.

### capovolta

- 1: Hai annunciato una cosa e la mano non l'ha ancora consegnata: il dire è corso avanti, il fare è rimasto indietro. Gli strumenti stanno sul tavolo, il talento dentro il cassetto.
- 2: La distanza tra quello che prometti e quello che le mani portano a termine. Il dono sta dove l'hai lasciato, in un cassetto, mentre la parola data annuncia una misura che il gesto non raggiunge.
- 3: Mentre la tua parola dichiara, le dita restano ferme sugli attrezzi già pronti: il talento c'è per intero e il tratto che va dall'annuncio al gesto si è allargato.

## La Papessa

### dritta

- 1: Il sapere che porti dentro non passa dalle parole: lo riconosci prima di poterlo spiegare, come acqua ferma che lascia vedere il fondo quando la tua mente tace.
- 2: Dentro di te una conoscenza quieta sa già e la scopri soltanto nei momenti in cui smetti di interrogarla, come un segreto che si apre al primo istante di quiete.
- 3: Un velo sottile tiene distante ciò che intuisci dalla parola che lo direbbe. Senza fretta, nell'attesa, trovi la risposta che le tue domande rumorose coprivano.

### capovolta

- 1: Copri con le tue ragioni, o col frastuono, un intuito che aveva già risposto; il timore di sentire la risposta tiene la mente occupata.
- 2: Un fiuto esatto resta sotto le spiegazioni che ti dai. Il segreto che cerchi non scappa, aspetta soltanto di venire accolto senza fretta.
- 3: Le parole ordinate pesano sopra una certezza muta. Fermarti ad ascoltarla ti spaventa un poco, eppure è lì dentro che il sapere dorme.

## L'Imperatrice

### dritta

- 1: La fertilità che ti attraversa nutre qualcosa di vivo senza affrettarne la crescita: un'idea, un legame, un seme interrato che matura col ritmo suo.
- 2: Dare abbondanza ti riesce senza sforzo e la dolcezza con cui tocchi le cose le fa aprire, perché nelle tue mani la vita trova il modo di moltiplicarsi.
- 3: Una generosità che non misura nulla scorre dalle tue dita e ciò che sfiori cresce perché lo lasci crescere con il tempo suo, senza strattoni.

### capovolta

- 1: La radice da cui nasce ciò che generi resta senz'acqua mentre tutto quello che hai piantato fuori la riceve, così la tua fecondità si ferma per fame alla sorgente.
- 2: Hai nutrito ogni cosa cresciuta attorno a te e hai saltato la radice tua: adesso il generare non arriva al frutto, non perché manchi il seme, ma perché manca il nutrimento a monte.
- 3: Qualcosa di vivo in te non arriva a forma. La terra da cui dovrebbe venire è rimasta asciutta mentre l'acqua andava tutta al giardino intorno. Senza radice nutrita, niente fiore.

## L'Imperatore

### dritta

- 1: La solidità che ti circonda ha fondamenta vere, non apparenze. Regge il peso delle tue decisioni e tiene insieme pezzi che da soli si sfalderebbero.
- 2: Dentro la tua domanda agisce un principio d'ordine: dà forma, fissa confini, stabilisce chi risponde di cosa. Non ti stringe per capriccio, ti costruisce un riparo.
- 3: Un'autorità ferma tiene il tuo quadro con regole, misure, responsabilità definite. La forza che la sostiene resiste perfino nei giorni in cui tu vacilli.

### capovolta

- 1: Quando la regola si stringe oltre il suo compito ti toglie respiro; se le fondamenta mancano, il tuo peso oscilla senza appoggio.
- 2: Una rigidità che non piega più nulla, oppure un vuoto sotto i piedi. La stessa forza ti tocca serrata fino all'eccesso o del tutto assente.
- 3: Ordine e disordine fanno un nodo solo. Una norma che fissa ogni dettaglio ti blocca il movimento; la sua assenza ti lascia sopra un terreno che cede.

## Il Papa

### dritta

- 1: Hai accanto un sapere più antico della tua domanda, tramandato di mano in mano prima che tu nascessi. Il maestro che te lo consegna non si mette al tuo posto.
- 2: La fiducia in un maestro ti lega a una catena più lunga della tua vita. Non perdi la testa affidandola a chi insegna, impari a usarla.
- 3: Un ordine che non hai inventato ti sostiene e il maestro onesto ti istruisce perché tu possa fare a meno di lui.

### capovolta

- 1: Il dover essere che hai imparato ti sta addosso come un abito cucito per un altro corpo. Non lo stai tradendo se lo misuri con il tuo respiro.
- 2: Una regola ricevuta senza discussione smette di tenerti e accorgersene non è ribellione ma crescita: il senso tuo lo cerchi anche fuori da chi te l'ha insegnato.
- 3: Dentro di te un dover essere imparato da altri perde autorità e il tuo senso proprio lo riconosci dal respiro che ti lascia.

## Gli Amanti

### dritta

- 1: Una decisione d'amore tocca i tuoi valori di fondo e al bivio tiene la scelta in cui l'affetto e chi sei combaciano.
- 2: A un bivio i valori a cui tieni contano più del desiderio di un momento e l'amore tiene quando ti somiglia fino alla radice.
- 3: Il bivio dell'amore poggia sui valori che riconosci tuoi e dal loro accordo con l'affetto dipende la scelta che fai.

### capovolta

- 1: Il disaccordo con chi ami ripete una divisione che hai dentro: due valori reclamano entrambi di essere i tuoi e a uno dei due stai dando una risposta che non è sincera. Per questo la scelta resta sospesa.
- 2: Due cose che per te contano davvero si contendono il campo: finché non dichiari quale delle due regge, nessun accordo con la persona che ami tiene, perché manca prima quello con te.
- 3: Sotto il dubbio su quel legame sta una bugia piccola che racconti a te. Finché la tieni, il rinvio tiene: due valori restano in lotta e nessuna decisione presa in due sta in piedi.

## Il Carro

### dritta

- 1: Tieni le redini di due forze che tirano in versi opposti e le fai andare insieme verso una meta. La padronanza, non la fortuna, è ciò che ti fa avanzare.
- 2: Lo slancio ce l'hai e la direzione pure: due tensioni che si contrastano diventano un unico traino sotto la tua guida.
- 3: Due tiri che vanno in direzioni avverse stanno nelle tue mani come un attacco solo e il governo del movimento vale come vittoria senza bisogno di fortuna.

### capovolta

- 1: Le redini si allentano tra le tue dita e il tiro si disunisce, oppure la corsa prosegue senza una meta scelta. Rallentare rimette il centro al suo posto.
- 2: Spinte che tirano in versi opposti ti fanno sbandare, oppure acceleri senza avere scelto la meta. Il governo del movimento ti sfugge, non la forza di tenerlo.
- 3: Corri con slancio intatto mentre la guida vacilla e il centro da cui parti si è spostato. Una sosta breve ti rimette le cinghie in mano senza togliere nulla alla spinta.

## La Giustizia

### dritta

- 1: Una bilancia pesa senza sconti: ciò che hai messo in moto torna a te con la misura esatta con cui lo hai mandato.
- 2: La verità non si negozia, la responsabilità resta in mano a te. Guardare in faccia il peso delle tue azioni rimette d'accordo i due piatti.
- 3: Pesare senza indulgenza ciò che hai fatto ti rende la misura esatta delle cose, perché causa ed effetto reggono lo stesso filo.

### capovolta

- 1: Una cosa che ti spetta è rimasta da fare e ogni volta l'hai spostata alla prossima occasione. Il conto non si chiude da solo: resta aperto a tuo nome e pesa senza farsi vedere.
- 2: La responsabilità che tocca a te, rimandata una volta di più, è il peso che non riesci a posare. Finché non la riconosci come tua, l'assetto non torna.
- 3: Un conto a tuo nome resta da saldare e lo sposti avanti da tempo. La bilancia tiene un piatto più basso e si rimette in pari solo quando ti dici com'è andata davvero.

## L'Eremita

### dritta

- 1: Il silenzio ti serve più della compagnia e la lampada che porti rischiara soltanto lo spazio accanto ai piedi tuoi, abbastanza per scegliere il prossimo appoggio.
- 2: Rallenti e porti la domanda dentro, lontano dal rumore degli altri; una lanterna piccola in mano tua vale la luce del giorno quando ti fidi del buio intorno.
- 3: Una ricerca solitaria ti chiama e il poco chiarore che tieni alto basta a mostrarti il gradino successivo, non l'intero disegno.

### capovolta

- 1: La solitudine che doveva schiarirti le idee ti pesa addosso e la lampada girata contro il muro non mostra più il volto di nessuno.
- 2: Chiuderti a chiave ha smesso di darti chiarezza e il raccoglimento somiglia a un nascondiglio, con la lanterna spenta fra le dita tue.
- 3: C'è un buio attorno che non rischiari più e il ritiro tuo tiene lontane anche le mani tese verso di te, mentre la fiamma resta girata all'interno.

## La Ruota della Fortuna

### dritta

- 1: Un giro largo tocca la tua domanda. Ciò che sta in alto scende, ciò che sta in basso risale; il momento dello scatto non lo decidi tu.
- 2: Gira il destino e porta in cima ciò che stava sotto. La tua vicenda non ha una forma stabile ma una fase; nessuna fase dura.
- 3: C'è una rotazione in corso che non attende il tuo permesso: alza, abbassa, rimescola. La sorte che ti riguarda adesso somiglia a un ingranaggio in moto.

### capovolta

- 1: Niente gira come dovrebbe. La rotazione si è impuntata e il tempo che passa non ti restituisce nulla, oppure ti rende il contrario di ciò che avevi messo.
- 2: Un ciclo resta appeso a metà, oppure prosegue di sbieco. La presa ti sfugge, non è forza che manca, è il momento a non combaciare con la tua spinta.
- 3: La sosta fa parte del giro, pure quando sembra un guasto. Adesso l'ingranaggio della tua domanda trattiene lo scatto e non ti manda segnali.

## La Forza

### dritta

- 1: Una mitezza che non cede nulla addomestica in te l'istinto scalpitante e il tuo nervo più selvatico si calma perché nessuno lo aggredisce.
- 2: Ti bastano una mano calma e un cuore mite per tenere l'istinto che si agita. Il vigore che non chiude il pugno è il tuo.
- 3: Il coraggio che ti riguarda ora è dolce. Domini la belva che hai dentro accarezzandola e non colpendola, con fermezza tenera.

### capovolta

- 1: Dubiti della tua tenuta, oppure usi con te la durezza che eviteresti con un altro. Il vigore stretto a pugno ti sfugge.
- 2: La mano che stringe per domare non doma. Quando la tua mitezza viene a mancare anche l'istinto ti sembra ingovernabile.
- 3: Una severità puntata contro di te ti indurisce il coraggio e il nervo che ti pare fuori controllo perde la dolcezza che lo teneva.

## L'Appeso

### dritta

- 1: La resa volontaria ha un suo frutto. Quando smetti di spingere, l'attesa che pare ferma ti apre un'angolazione che il movimento teneva nascosta.
- 2: Tenere le mani ferme diventa un modo di vedere: il tempo che non riempi ti mostra la questione da un punto che l'azione ti negava.
- 3: Fermarti non spegne la tua forza, rallenta la fretta che la consumava. Da questa pausa nasce uno sguardo che prima non avevi.

### capovolta

- 1: Un'attesa che ha smesso di insegnare ti trattiene nello stallo e la rinuncia in cui ti tieni somiglia al timore travestito da nobiltà.
- 2: Da questa pausa non ti torna più nulla e il sacrificio che ti imponi non riscatta nessuno. Lo stallo si regge sul timore di scendere.
- 3: L'attesa ha esaurito la sua lezione e ciò che chiami pazienza ti trattiene senza darti nulla in cambio. Il nodo sta nel timore di muoverti.

## La Morte

### dritta

- 1: Una cosa è giunta al suo termine e il suo chiudersi apre il posto a ciò che nasce. Non c'è distruzione in questo, c'è mutamento: la mano che si apre ti libera le dita.
- 2: Ciò che finisce lo fa perché un seme possa aprirsi al posto suo e la trasformazione non ti toglie nulla, sostituisce. Lascia cadere la foglia che ha compiuto il suo tempo.
- 3: Un ciclo chiude i suoi battenti e nello stesso istante qualcosa di non nato trova aria. Il taglio netto che ti attraversa non distrugge niente, sgombera il terreno.

### capovolta

- 1: Tieni per il bordo una cosa che ha già finito di esistere e le tue dita si stringono sopra un guscio vuoto. La fine è avvenuta, il riconoscerla no.
- 2: Il mutamento è accaduto fuori di te mentre la tua presa resiste ancora. Il peso sta nelle mani che stringono, non nella cosa che se ne sta andando.
- 3: A mani chiuse reggi il coperchio di qualcosa che ha già smesso. Allarga le tue dita e il dolore cambia natura, da strappo diventa respiro.

## La Temperanza

### dritta

- 1: Il dosaggio paziente unisce due cose che sembravano incompatibili. Mescoli poco per volta e misuri senza fretta, finché ciò che hai in pezzi ritrova forma.
- 2: Un travaso lento fra due vasi tiene insieme il caldo e il freddo mentre tu non ne scegli nessuno. L'armonia nasce dalla calma con cui dosi.
- 3: Andando piano accordi fra loro le parti di te che non si parlavano. La tua pazienza è un'arte di misura, non una rinuncia.

### capovolta

- 1: Un ingrediente copre tutti gli altri e il ritmo ti salta fra scatti e pause, mentre due parti di te hanno smesso di parlarsi.
- 2: Corri su una cosa sola e lasci l'altra a secco. Dentro di te due metà non si accordano, perché l'armonia nasce da una pratica di ogni giorno.
- 3: La misura ti sfugge fra uno slancio e un rinvio, mentre due spinte interne tirano in direzioni opposte senza accordarsi.

## Il Diavolo

### dritta

- 1: Ti tiene qualcosa che ammetti a metà, una catena fatta di desiderio e di abitudine, mentre il suo potere dura fino al momento in cui la chiami per nome.
- 2: Il legame che ti incatena nasce da un piacere vero e proprio per questo regge, finché non lo guardi in faccia e lo chiami col suo nome esatto.
- 3: Una presa che ti piace tenere addosso ti lega più di quanto riesci ad ammettere; nell'ombra non abita colpa, soltanto materia da guardare.

### capovolta

- 1: Vedi il nodo che ti tratteneva e la catena perde di colpo metà del peso suo, perché senza il buio attorno non ha la forza che sembrava avere.
- 2: Un anello si apre fra le dita tue e il desiderio che ti comandava dal buio adesso sta davanti, sciolto a metà solo perché lo hai riconosciuto.
- 3: Qualcosa che ti legava ha smesso di essere invisibile e scioglierlo diventa un gesto lento, fatto con dolcezza, non uno strappo.

## La Torre

### dritta

- 1: Il colpo dall'alto non discute: abbatte in un istante ciò che stava su basi finte. Dopo, in piedi ti resta soltanto il materiale sano.
- 2: Cade adesso la costruzione che reggeva su un'apparenza. Il frastuono è grande; fra le macerie trovi intatto soltanto ciò che ti appartiene.
- 3: Una scossa improvvisa smonta l'impalcatura e lascia nudo il nucleo. Non intacca il solido ma elimina il finto, mostrandoti su cosa poggia la tua domanda.

### capovolta

- 1: Rimandi una caduta che si annuncia, oppure la stai attraversando con le ossa ancora dolenti. In ogni caso il falso regge in apparenza e ti costa fatica tenerlo su.
- 2: La scossa resta sospesa. Qualcosa nel tuo quadro vacilla da sotto e tiene ancora, puntellato da sforzi che fai senza nominarli.
- 3: Trattenere il crollo assorbe energia. Tu lo senti nel fiato corto, nella stanchezza di reggere una cosa che da sé starebbe già a terra.

## La Stella

### dritta

- 1: La speranza che credevi finita ti bagna di nuovo e l'ispirazione che ti arriva ora non fa rumore ma ti versa addosso una calma chiara.
- 2: Una quiete luminosa ti rassicura senza gridare e l'ispirazione che ti torna addosso somiglia a un cielo lavato dalla pioggia.
- 3: Dopo la tempesta ti resta una luce piccola e ferma. La fiducia torna senza clamore, come acqua versata nella sete.

### capovolta

- 1: Un'acqua che non scorre più ti rende difficile sperare e la luce che cercavi non si è spenta: una nube sottile te la copre.
- 2: Fatichi a credere che le cose si rimettano a posto, la tua fiducia si è fatta stanca e l'ispirazione tace. Non è luce spenta, è luce velata da una nube.
- 3: Le tue sorgenti di speranza sembrano asciutte e l'ispirazione non ti parla, mentre la luce resta dietro un velo che non hai ancora attraversato.

## La Luna

### dritta

- 1: Non tutto ti è chiaro e il buio non si schiarisce a comando. L'intuito ti parla nella lingua dei sogni mentre le cose mostrano un profilo diverso dal vero.
- 2: Le apparenze non combaciano con la sostanza e di notte il tuo timore si allarga, perché l'inconscio ti parla per immagini e non per ragioni.
- 3: Una luce incerta ti lascia riconoscere le forme a metà. Fidarti del passo, nel dubbio, ti porta oltre il bisogno di vedere subito tutto il resto.

### capovolta

- 1: C'è una nebbia che si apre e le dimensioni delle tue paure tornano a quelle vere: alla luce avevano più ombra che peso.
- 2: Alla luce del giorno la sagoma che ti spaventava si ridimensiona e l'inganno notturno perde il suo potere su di te.
- 3: La confusione si dirada e distingui di nuovo i profili. Tornare a fidarti dei tuoi occhi ti costa meno adesso che l'ombra si è ritirata.

## Il Sole

### dritta

- 1: La chiarezza ti arriva addosso come calore e niente di te resta in ombra, perché la luce che hai non ha bisogno di nascondigli. Fiorisce ciò che tocchi.
- 2: Ridi senza doverti coprire e il calore che emani raggiunge chi ti sta vicino. Una stagione luminosa illumina tutto di te, anche le parti che tenevi all'ombra.
- 3: Pieno mezzogiorno sopra di te: le cose crescono, la riuscita è visibile e la gioia non chiede scuse. Nulla di te ha bisogno di rimanere coperto.

### capovolta

- 1: La luce non è calata di un grado, soltanto non ti raggiunge la pelle: un velo sottile ti separa dal calore ed è fatto spesso di un pensiero vecchio.
- 2: Il tuo entusiasmo resta trattenuto dietro una nube e il calore, pur presente, non ti tocca la pelle. Spostala e la gioia torna addosso.
- 3: Ridere ti costa fatica mentre la giornata è chiara, perché un pensiero vecchio si è messo davanti al tuo calore. Niente si è spento, qualcosa sta in ombra.

## Il Giudizio

### dritta

- 1: Senti un richiamo che non viene da fuori e ti chiede se la storia che abiti è ancora tua. Non ti mette sotto accusa, ti sveglia.
- 2: La chiamata ti raggiunge come un suono che attraversa il sonno. Tiri le somme di ciò che hai fatto e il bilancio apre una vita più vera, più tua.
- 3: C'è un appello che ti nomina e non ti condanna: lasci indietro chi eri per fare spazio a chi stai diventando adesso.

### capovolta

- 1: Il bilancio che avverti necessario slitta ancora, oppure te lo fai addosso con una durezza che non apre niente.
- 2: Rimandi le somme che pure ti sembrano urgenti, o trasformi il richiamo in un rimprovero contro di te. Il risveglio passa dall'ascolto, non dall'asprezza.
- 3: Una durezza tutta tua copre il perdono che non ti concedi, così la rinascita resta sospesa a metà senza trovare un inizio.

## Il Mondo

### dritta

- 1: Il cerchio si chiude intero e tutto ciò che hai attraversato adesso ti appartiene, cucito dentro di te come una cosa sola, prima dell'apertura seguente.
- 2: Arrivi al compimento e nulla resta sparso: le parti tue tornano insieme in una pienezza che puoi abitare per un poco, senza corse verso il prossimo inizio.
- 3: Una pienezza senza buchi ti aspetta alla fine del giro e la gioia sta nel sostare dentro, non nel correre ad aprire il cerchio successivo.

### capovolta

- 1: Manca poco alla chiusura e un pezzo resta fuori dal cerchio, un dettaglio piccolo che tiene aperta la pienezza mentre tutto il resto tuo è a posto.
- 2: La pienezza ti sfiora già e un ultimo frammento ancora sciolto tiene il giro aperto, abbastanza vicino da sentirlo sotto le dita.
- 3: Un compimento quasi tuo resta sospeso per un dettaglio e la soglia che ti separa dall'intero è sottile, larga come un gesto rimasto da fare.

## Asso di Bastoni

### dritta

- 1: Una scintilla si apre nel tuo desiderio e vuole combustibile subito. È calore allo stato grezzo, senza disegno ancora; ha la fretta tipica delle cose appena nate.
- 2: Brucia in te un avvio, un'idea che spinge per uscire e non sopporta rinvii. L'energia non ti manca, difetta soltanto di forma.
- 3: Il fuoco iniziale ti attraversa adesso e dura quanto dura una fiammata, intenso e breve, spento se nessuno lo alimenta.

### capovolta

- 1: Sotto la cenere resta brace viva, le manca ossigeno. Il tuo slancio si avvia e ricade, trattenuto da un timore che non hai ancora nominato.
- 2: Un impulso trattenuto gira a vuoto e ti lascia addosso un'irritazione senza bersaglio. Il combustibile non difetta, manca il permesso che ti dai.
- 3: Acceso il desiderio, spento il gesto. Uno scarto ti separa dalla partenza e somiglia alla paura di non riuscire, un timore che smorza prima dell'inizio.

## Due di Bastoni

### dritta

- 1: Guardi oltre il confine di ciò che conosci e un progetto chiede una direzione, mentre il mondo ti sta in mano come una sfera piccola.
- 2: Il disegno che hai in testa supera il recinto che conosci e la scelta dell'orizzonte viene prima del passo, coi mezzi che tieni già in mano.
- 3: Un'ambizione larga ti misura il mondo da fermo: tieni la mappa, pesi due terre lontane e la direzione che preferisci non l'hai ancora detta.

### capovolta

- 1: Il mondo che tieni in mano non ti dice ancora da che parte andare e due possibilità ugualmente aperte ti fermano sul bordo.
- 2: Una paura di osare ti tiene sulla soglia e la direzione che credevi chiara ti si confonde mentre tieni la mappa in mano.
- 3: Vedi largo e non ti muovi: l'orizzonte ti attrae, il primo passo ti sfugge e il disegno resta senza bordi precisi.

## Tre di Bastoni

### dritta

- 1: Hai spinto una cosa al largo e adesso la guardi tornare: i frutti di quella semina stanno facendo strada verso di te, da una distanza che non accorci con le mani.
- 2: L'attesa di un rientro da lontano. Quello che hai lanciato viaggia fuori dal tuo campo, si allarga e torna indietro col passo delle cose che devono coprire una distanza.
- 3: Fuori dal tuo campo, in viaggio, c'è quello che hai messo in moto: rientra per la strada che ha preso e i suoi frutti arrivano da lontano, non dal solco sotto i tuoi piedi.

### capovolta

- 1: Non è solo il tempo a slittare: quello che aspettavi non torna nella forma che gli avevi dato in testa. Restano aperte due strade, pazientare ancora un poco o correggere la rotta con lucidità.
- 2: La rotta che avevi scelto si misura adesso, mentre quello che hai mandato avanti tarda e rientra in una forma che non avevi previsto. Il tempo che prende è suo, non è un rifiuto.
- 3: Aspetti un ritorno che non arriva nei termini immaginati. Su questo l'attesa pesa: o le concedi ancora un poco di tempo o cambi la direzione che avevi dato, scegliendo con lucidità e non per scoraggiamento.

## Quattro di Bastoni

### dritta

- 1: Hai raggiunto una soglia e le fondamenta sotto di te reggono il peso, perciò il momento si festeggia con chi c'era. Riconoscere il bello costruito vale come riposo.
- 2: Festeggia: ciò che hai messo in piedi ha radici e il tetto tiene. Mostrarlo agli altri non ti espone, la gioia divisa rende solida la base.
- 3: Un traguardo tocca terra sotto i tuoi piedi e intorno c'è gente che lo riconosce. Prenderti il tempo della festa non ti ruba niente al passo successivo.

### capovolta

- 1: La tua armonia si è allentata e sotto la superficie le radici non hanno ancora preso del tutto. La festa è pronta, la base no.
- 2: Prima che il brindisi parta, il terreno sotto le travi va guardato: qualcosa nelle radici tiene ma non ti sostiene del tutto.
- 3: Senti stonature nell'accordo attorno a te e il traguardo che volevi celebrare resta in sospeso finché la base non regge.

## Cinque di Bastoni

### dritta

- 1: Un attrito vivo accende i pensieri: ti scontri, ribolli, ti misuri con chi ti sta davanti senza che nessuno voglia ferire.
- 2: Giochi di braccio con chi ha idee diverse dalle tue. Il calore dello scontro ti fa crescere se lo spendi per misurarti, non per schiacciare.
- 3: La competizione scalda l'aria intorno a te, perché nessuna delle parti vuole cedere. Da un confronto tenuto bene esci con muscoli nuovi.

### capovolta

- 1: Spendi forze in scaramucce che non ti portano niente, oppure lasci covare sotto la cenere un attrito che non nomini.
- 2: Una tensione girata a vuoto ti porta via fiato, o l'urto che eviti brontola dentro la pelle senza uscire allo scoperto.
- 3: Scintille piccole ti bruciano addosso una dopo l'altra, mentre l'asprezza che non affronti resta a scaldarsi da sola, lontana dalle parole.

## Sei di Bastoni

### dritta

- 1: Gli occhi degli altri si posano su te con approvazione e il riconoscimento che ricevi poggia su lavoro vero, non su fortuna.
- 2: Ricevi applauso davanti a testimoni e il merito tuo viene nominato in pubblico, portato bene quando lo tieni alla misura esatta.
- 3: Un onore pubblico ti spetta per ciò che hai portato a termine e reggerlo senza gonfiarti né rimpicciolirti è la parte delicata della faccenda.

### capovolta

- 1: Il valore tuo regge anche quando nessuna mano batte le palme e il silenzio attorno dice poco della sostanza che porti addosso.
- 2: Aspetti un riconoscimento che tarda e il dubbio su te cresce nel vuoto lasciato dagli altri, mentre la sostanza del lavoro tuo non è diminuita di un grammo.
- 3: Nessuno nomina il risultato tuo e il valore si appoggia tutto alle spalle tue, senza mani che applaudono a confermarlo.

## Sette di Bastoni

### dritta

- 1: La difesa che ti tocca adesso è di chi sta più in alto e lo sa. Attorno premono richieste, obiezioni, pretese; il terreno sotto i tuoi piedi resta tuo.
- 2: Resistere costa fatica e in questo momento ti riesce. La pressione esterna è reale, il tuo punto non arretra di un dito.
- 3: Un assedio attorno a ciò in cui credi mette alla prova il tuo coraggio e insieme lo dimostra. Hai braccia, fiato, ragioni: il vantaggio sta dalla tua parte.

### capovolta

- 1: Contro un'ombra tieni la guardia alta e ti consumi a difendere un terreno sgombro. L'assalto che aspetti è fermo.
- 2: Un allarme che non cala ti porta a tenere una collina che l'avversario ha già lasciato e di fronti aperti ne senti troppi.
- 3: Il fronte si è svuotato e la guardia alta ti porta via le forze. La fatica di tenere ferme le colline ti sommerge.

## Otto di Bastoni

### dritta

- 1: Una corsa già partita ti porta con sé: le cose capitano in fretta, i messaggi si accavallano e il tuo tempo di pensare si accorcia.
- 2: Tutto accelera insieme, le notizie ti raggiungono a raffica e il ritmo ti passa sotto i piedi senza chiederti il permesso.
- 3: Le risposte che attendevi ti piovono addosso in poco tempo, una dopo l'altra. La rapidità con cui accadono ti supera di un passo.

### capovolta

- 1: Corri e non sai verso che cosa, oppure aspetti e non accade niente: il ritmo ti si è scomposto e le notizie ti raggiungono fuori ordine.
- 2: I tempi si allungano oppure la tua fretta corre senza bersaglio e la rapidità che avevi ti si ingarbuglia addosso.
- 3: Ti arriva tutto in una volta e senza un bersaglio preciso, mentre le risposte che attendi restano appese dietro un ritardo.

## Nove di Bastoni

### dritta

- 1: Una stanchezza vera ti accompagna a un passo dalla fine e la tenacia che ti resta conta come tutto il lavoro già fatto.
- 2: Hai già portato il carico per quasi tutta la salita e l'ultima prova misura la tenuta, non la partenza. Resistere adesso pesa quanto tutto il resto.
- 3: La tenacia ti tiene in piedi quando le riserve sono basse e l'ultimo colpo da assorbire somiglia, per peso, a tutti i primi.

### capovolta

- 1: Nessuno sta sferrando un colpo, eppure la guardia non scende. Chi fa un passo verso di te la incontra alzata, perché la stanchezza ha reso sospetto ogni avvicinamento.
- 2: Una mano tesa senza secondi fini incontra la stessa barriera che incontrerebbe un assalto: la fatica ti ha chiuso a riccio e le punte stanno fuori verso tutto quello che arriva.
- 3: La diffidenza ha smesso di distinguere. Chi si avvicina per starti vicino resta fuori dallo scudo come il resto. Quello da cui ti stai riparando non è un attacco.

## Dieci di Bastoni

### dritta

- 1: Porti sulle spalle un fascio di carichi e la schiena si curva sotto il volume. Distinguere il peso tuo da quello preso in prestito cambia il modo di reggerlo.
- 2: Le braccia ti sono piene fino al mento e il passo si accorcia. Chiediti con onestà quale di questi fardelli ti appartiene e quali puoi posare a terra.
- 3: Hai accettato un fardello dopo l'altro e adesso il corpo lo sente tutto insieme. Tenere ogni cosa non è vigore, scegliere il carico è lucidità.

### capovolta

- 1: Un fardello che non nasce da te ti resta addosso per abitudine, oppure per un dovere che non hai scelto. Posarlo non toglie niente a chi ti sta intorno.
- 2: Reggi anche il pezzo che non ti riguarda e lo tieni su per inerzia. Mollare quella parte non ti rende sleale verso nessuno, ti restituisce il respiro.
- 3: Dentro il fascio che trasporti ci sono pesi raccolti per abitudine e non per necessità. Lasciarne cadere qualcuno ti alleggerisce le braccia senza caricare nessuno.

## Fante di Bastoni

### dritta

- 1: L'idea giovane che ti bussa in testa non ha ancora prove a suo favore, eppure ti tira per la manica e ti fa venire voglia di provarla.
- 2: Qualcosa di nuovo ti incuriosisce e hai le gambe per andarci a vedere, con una fretta allegra che non pretende di conoscere la meta.
- 3: Ti brucia una curiosità fresca e le mani ti partono prima della testa, come all'inizio di un'avventura che non sai ancora quanto lontano porta.

### capovolta

- 1: Una cosa ti prende, la cominci e si esaurisce da sé prima del frutto, poi ne arriva un'altra che rifà lo stesso giro accanto a te.
- 2: L'entusiasmo si spegne prima che il lavoro chiesto sia arrivato a maturare: parte, scalda per un poco, cade; la partenza dopo riparte da zero.
- 3: Hai acceso più di una cosa e si sono spente una a una, ciascuna a metà strada: l'energia ti torna addosso, la durata no; ciò che hai aperto resta dove l'hai lasciato.

## Cavaliere di Bastoni

### dritta

- 1: Parti di slancio verso ciò che desideri e il coraggio ti scalda prima del ragionamento, con l'occhio comunque fisso alla meta lontana.
- 2: Un fuoco ti spinge in avanti e l'avventura ti sembra più leggera del dubbio, purché la direzione resti incollata agli occhi tuoi mentre corri.
- 3: La passione ti mette in moto e osare adesso costa meno dell'esitare, con il galoppo tuo tenuto dritto su una meta visibile.

### capovolta

- 1: La fretta ti ha messo in sella prima che una rotta fosse scelta e adesso tieni aperte più strade insieme, con lo slancio spartito fra loro mentre il galoppo continua.
- 2: Una foga già lanciata, che apre una direzione dopo l'altra senza fermarsi a scegliere fra loro: accanto a te corre un ardore più veloce della sua meta.
- 3: Hai dato di sprone prima di guardare dove portava la strada: l'impazienza governa l'andatura e tratto dopo tratto la meta si moltiplica invece di avvicinarsi.

## Regina di Bastoni

### dritta

- 1: Altri ti vengono vicino per il calore che tieni acceso senza sforzo e in quella luce trovano posto anche loro.
- 2: Senza limarti per piacere attiri gli altri e il tuo calore li scalda uno a uno, poi loro coprono il resto della distanza.
- 3: Una sicurezza calma e tua attira gli altri e il tuo ardore li tiene vicini mentre non ti muovi di lì per raccoglierli.

### capovolta

- 1: Dubiti del tuo valore proprio mentre gli altri lo riconoscono. Un confronto costante ti appanna la luce e trasforma il calore in pretesa di conferme.
- 2: Una gelosia sottile offusca il tuo calore e lo piega in rivalità. Brilli a intermittenza, con un occhio fisso su chi occupa la luce accanto a te.
- 3: Fuori dal tuo centro la fiamma si agita e brucia senza scaldare. Il calore che hai si mescola al bisogno di una conferma e perde nitidezza.

## Re di Bastoni

### dritta

- 1: La tua fiamma indica una direzione agli altri senza spingerli e l'autorità che hai conquistata diventa generosa quando insegna.
- 2: Un'ispirazione che hai già collaudato ti porta alla testa di qualcosa e il calore con cui accompagni gli altri decide il tuo modo di guidare.
- 3: Guidi per esempio e non per comando: la tua fiamma scalda chi ti sta accanto e la volontà matura che porti apre un varco nel muro.

### capovolta

- 1: Un'impazienza da comandante ti fa correre avanti mentre gli altri restano indietro e l'esempio che dai pesa come una pretesa.
- 2: Spingi prima di ascoltare e la fiamma che porti brucia chi ti sta vicino senza accendere nessuno. L'autorità tua si è fatta rigida.
- 3: Il comando che hai in mano scotta e l'autorità si irrigidisce, mentre la spinta che dai agli altri va avanti senza il loro ascolto.

## Asso di Coppe

### dritta

- 1: Ti sale dentro un sentire pulito, senza calcolo, come una sorgente che trova la sua apertura. La dolcezza che provi non ti indebolisce.
- 2: La tenerezza precede le ragioni e ti riempie senza chiederti il permesso. Un inizio affettivo nuovo ha questa qualità di acqua che sale.
- 3: Un'emozione limpida ti attraversa e scorre, se la lasci andare dove vuole. La grazia di questo sentire sta nel non avere ancora nessuna forma.

### capovolta

- 1: Tieni la mano sopra la tua stessa sorgente perché aprirla fa male e l'acqua che non esce si ferma sul fondo. Non c'è un legame da ricucire: c'è un sentire che non hai fatto partire.
- 2: Il tuo sentire tenuto a chiave da dentro, prima che ci sia qualcuno a cui darlo. Il timore di soffrire rimanda un amore che non ha ancora cominciato e l'acqua ferma resta nella coppa.
- 3: Finché rimandi di sentire, la fonte spinge e non trova una via d'uscita: non c'è un malinteso da sciogliere con qualcuno, c'è l'acqua che si è fermata dove nasce.

## Due di Coppe

### dritta

- 1: Qualcuno ti riconosce e tu rispondi con la stessa misura: il patto si sigilla da sé, senza contratto. Coltivarlo adesso conta come costruirlo.
- 2: Il legame si stringe su una parità vera e chi ti sta davanti dà quanto prende. Trattalo con cura, perché ciò che nasce adesso è giovane.
- 3: Specchiarsi in qualcuno senza perdersi moltiplica la forza che hai. L'accordo che si firma adesso tiene insieme pari e pari, non chi guida e chi segue.

### capovolta

- 1: Un malinteso si è infilato nel legame e l'accordo stona, mentre l'affetto sotto resta intero. Ascoltare fino in fondo ricuce lo strappo che ti pesa.
- 2: L'accordo pende da un verso solo e il riconoscimento che c'era si è appannato. Parlare chiaro con chi ti riguarda scioglie il nodo prima che si stringa.
- 3: Qualcosa di non detto siede tra te e chi ti sta accanto e il legame tiene pur suonando stonato. Dire la frase rimasta indietro rimette l'accordo a posto.

## Tre di Coppe

### dritta

- 1: Un brindisi alzato insieme moltiplica la gioia, perché il bene che ti vogliono gli amici torna indietro raddoppiato quando lo festeggi con loro.
- 2: Hai motivo di stappare qualcosa e gente intorno con cui farlo. La contentezza divisa fra più bicchieri cresce, mentre chiusa addosso resta piccola.
- 3: Attorno a te si stringono persone che ti vogliono bene e tengono la stessa allegria. Una cosa buona merita un cerchio di amici, non un angolo in silenzio.

### capovolta

- 1: Il cerchio intorno a te si è allargato oltre la misura che riesci a tenere, oppure brindi molto e ti nutri poco di quelle presenze.
- 2: Una tavolata affollata ti disperde, mentre gli affetti che nutrono stanno in poche mani e aspettano la tua cura.
- 3: Festeggi con tanti e ti riconosci in pochi, così il legame sincero resta coperto dal rumore di compagnie che ti scaldano appena.

## Quattro di Coppe

### dritta

- 1: C'è una mano che ti porge qualcosa e il tuo sguardo sta altrove. Non manca l'occasione, manca la voglia: la noia ha preso il posto del desiderio e tiene gli occhi dove non succede niente.
- 2: Il dono teso proprio accanto a te resta fuori dal tuo sguardo. Non per fretta né per un calcolo sbagliato: per apatia, perché in questo momento nulla ti smuove.
- 3: Qualcuno ti ha offerto qualcosa e tu hai lasciato gli occhi altrove. La coppa sta a un palmo dalla tua mano e il torpore basta a tenerla invisibile. Quello che non desideri non lo vedi.

### capovolta

- 1: Mentre il torpore cede ritorni a sentire le persone e i fatti e una curiosità nuova ti chiama da un punto che non sai nominare.
- 2: Una curiosità piccola ti punge appena il torpore cede e il gusto di seguirla ti torna insieme a un'apertura nuova.
- 3: Dopo la noia una curiosità nuova ti prende quasi di sorpresa e il torpore si scioglie e ricominci a interessarti.

## Cinque di Coppe

### dritta

- 1: Due coppe versate ti tengono gli occhi incollati a terra. Il rimpianto occupa il primo piano e misura la tua domanda su ciò che hai perduto.
- 2: Dietro le tue spalle due coppe stanno ancora in piedi. Lo sguardo tuo sta davanti al versato: il peso di ciò che manca copre tutto il resto.
- 3: Una perdita vera pesa nella tua domanda. Il dolore ha ragione di esserci; il conteggio che ne fai lascia fuori ciò che è rimasto intatto.

### capovolta

- 1: Giri il collo verso ciò che resta e il movimento ti riesce rigido, impacciato, però avviene. Il perdono che concedi, a te o a un altro, scioglie un groppo.
- 2: Lo sguardo si stacca dal versato e trova due coppe in piedi. Non è euforia, è accettazione; il dolore smette di occupare il tuo intero campo.
- 3: C'è una ripresa lenta nel modo in cui guardi la tua perdita: il dolore resta, la mira cambia, torni a dare valore a ciò che non è andato.

## Sei di Coppe

### dritta

- 1: Ti torna addosso una tenerezza antica, un affetto sincero che il passato ti riconsegna e la dolcezza dei ricordi ti nutre come pane.
- 2: Il passato ti manda un affetto pulito con dei ricordi cari e l'innocenza che avevi allora ti scalda ancora le mani.
- 3: Una nostalgia buona ti addolcisce la giornata: qualcuno ti vuole bene da lontano nel tempo e la bontà di allora ti raggiunge intatta.

### capovolta

- 1: La dolcezza di prima ti tiene per la manica e il presente aspetta il tuo turno di guardarlo, mentre i ricordi occupano la stanza.
- 2: Un affetto di allora ti scalda ancora. Proprio per questo ti tira indietro, mentre il presente ti chiama da una stanza che non apri.
- 3: Abiti un tempo che non c'è più e la tenerezza antica ti trattiene, mentre il presente resta fuori dalla porta ad aspettare.

## Sette di Coppe

### dritta

- 1: Le possibilità si affollano davanti a te e ciascuna promette più di ciò che porta. Il piacere di immaginarle ti tiene lontano dalla scelta.
- 2: Immaginare ti costa poco e per questo le visioni si moltiplicano, mentre la verifica di ognuna sta ancora tutta da fare.
- 3: Sognare in grande ti allarga il respiro e nello stesso tempo ti confonde, perché fra tante promesse non tutte hanno un fondo.

### capovolta

- 1: Fra tanti desideri uno ti risulta vero e gli altri perdono attrattiva. Scegliere elimina il resto e proprio il vuoto che lascia ti alleggerisce.
- 2: Una sola delle tue voglie regge la prova della messa a fuoco e le altre si sgonfiano da sole. La rinuncia che segue non ti impoverisce.
- 3: C'è una chiarezza nuova nel tuo volere: fra molte immagini ne resta una che ti riguarda e lasciar cadere le altre ti restituisce forza.

## Otto di Coppe

### dritta

- 1: Volti le spalle a ciò che non ti nutre e te ne vai in silenzio, senza sbattere porte. La direzione la conosci prima di saperla spiegare.
- 2: Un posto che ti ha dato quanto poteva resta indietro e tu avanzi in silenzio verso un senso che ancora non ha nome. L'andarsene pulito è un atto intero.
- 3: Né scenate né rancore: ti allontani da ciò che hai svuotato fino in fondo, perché una fame di significato ti chiama altrove.

### capovolta

- 1: Sei ancora dentro e già sulla porta. Non è una scelta fra due strade: è una sola domanda, se andartene da qui oppure restare. La risposta viene dall'ascoltarti con sincerità.
- 2: Quello che resta in bilico è l'andare via da dove stai. Nessun passo è stato fatto, né fuori né indietro. Solo l'ascolto sincero dice se il tempo di lasciare è venuto.
- 3: La porta l'hai aperta e non l'hai attraversata. Resti sul punto in cui si decide se lasciare quello che hai, senza fretta addosso ma anche senza alibi che tengano.

## Nove di Coppe

### dritta

- 1: Tieni fra le mani una cosa che avevi chiesto al cielo e l'hai avuta, quindi puoi goderla senza sentirti in debito con nessuno.
- 2: C'è un augurio avverato che ti riguarda. Il benessere arrivato non ti obbliga a scusarti, la contentezza non chiede permesso.
- 3: Una soddisfazione piena siede con te a tavola. Riconosci la fortuna che ti è capitata e assaporala, lasciando la colpa fuori dalla porta.

### capovolta

- 1: Un piacere dopo l'altro ti attraversa senza lasciare niente, perché la contentezza che mostri fuori non tocca il fondo dentro di te.
- 2: Hai in mano una soddisfazione di facciata che ti distrae appena, quindi il desiderio vero resta sotto, senza trovare nome.
- 3: Ti riempi di cose gradevoli e rimani con la stessa fame, segno che la gioia cercata abita a una profondità che il piacere di superficie non raggiunge.

## Dieci di Coppe

### dritta

- 1: L'affetto attorno a te forma un arco intero e la tua ricchezza vive nei legami, in una gratitudine semplice per chi siede al tavolo accanto.
- 2: Condividi pienezza con chi ami e la gioia non resta chiusa dentro di te, respira nei volti attorno e torna indietro moltiplicata.
- 3: Un'armonia piena ti circonda e il bene che hai costruito con altri regge il peso di tutti, come un arcobaleno teso sopra le teste di chi ami.

### capovolta

- 1: Una distanza si è aperta dentro la casa e la sentono tutti quelli che ci vivono. Dietro non c'è un torto grosso ma una fila di parole che nessuno dice: il freddo si scioglie dove tornano a dirsi.
- 2: L'armonia di casa con un punto saltato: il cerchio degli affetti si è raffreddato senza rompersi e la crepa resta aperta quanto dura il silenzio fra chi lo abita.
- 3: Parlando si ricuce quello che il tacere ha allargato. Fra te e le persone con cui dividi la casa è passata una tensione minuta, abbastanza perché nelle stanze si parli meno di prima.

## Fante di Coppe

### dritta

- 1: Una tenerezza inesperta affiora nella tua domanda e porta immagini, sogni, parole trattenute. È piccola, è vera, non sa dirsi ancora.
- 2: Nella tua domanda affiora un messaggio obliquo, un sogno, un'intuizione, un gesto gentile da parte di chi non te lo dice in faccia.
- 3: Il sentire ti precede sul pensare. Emozione nuova, fantasia, delicatezza, un materiale poetico che si rompe se lo maneggi come una pratica da sbrigare.

### capovolta

- 1: Senti con una pelle sottile e ti chiudi per non prendere altri colpi: la delicatezza resta fragile là sotto, tenuta nascosta come una cosa da non far vedere.
- 2: Un cuore ritirato dietro una porta che hai tirato tu. Il sentire là dentro è rimasto giovane e scoperto, lo tieni al coperto come se fosse una cosa da farsi perdonare.
- 3: Quello che senti ti arriva addosso senza filtro, così lo metti via e lo tieni fuori vista. Dietro il riparo la fragilità resta quella di prima e vibra uguale, adesso al chiuso.

## Cavaliere di Coppe

### dritta

- 1: Un'apertura affettuosa ti attraversa e porgi quel che senti oppure lo ricevi, mentre il garbo del gesto pesa come il suo contenuto.
- 2: Ti viene offerto qualcosa con garbo, oppure sei tu a tendere l'offerta e lo slancio del sentimento conta nel modo in cui lo porgi.
- 3: Il sentimento ti muove prima della ragione e un invito arriva con grazia, tuo o di un altro, mentre la bellezza ti corteggia senza fretta.

### capovolta

- 1: Prometti oppure ti promettono molto e i fatti restano indietro, mentre l'emozione corre avanti da sola senza mettere radici.
- 2: Le parole dolci non hanno ancora un gesto che le regga e l'incanto che ti arriva oppure offri tu resta senza radici.
- 3: Un sentimento incostante ti gira intorno con parole belle ma pochi gesti e la bellezza di adesso non dice ancora se dura.

## Regina di Coppe

### dritta

- 1: Una sensibilità che legge gli altri in profondità è la tua risorsa adesso. La stessa cura che offri intorno può volgersi anche verso te.
- 2: Capisci gli altri senza che parlino e questo intuito ti dà un potere delicato: accogliere non ti svuota, se sai anche ricevere.
- 3: La comprensione con cui accogli chi ti sta intorno non è un cedimento e regge il peso delle emozioni altrui senza spezzarsi.

### capovolta

- 1: Lo stato d'animo degli altri ti entra addosso senza filtro e il tuo si perde dentro il loro, finché non sai più quale sentire ti appartiene.
- 2: Un'empatia senza argine ti fa assorbire ogni umore che passa e la cura che dai agli altri non torna indietro verso di te.
- 3: Amare fino a sparire non è profondità, è una dimenticanza di te. L'acqua degli altri ti riempie e del tuo sentire resta poco.

## Re di Coppe

### dritta

- 1: Le onde ti passano attraverso senza ribaltarti e sai dare un nome a ogni emozione mentre la vivi. Gli altri si appoggiano alla tua quiete perché la vedono ferma.
- 2: Governi il mare interno con mano leggera e nulla di ciò che provi ti travolge. Sei un approdo per te e per chi arriva: la calma che offri non è gelo.
- 3: Una maturità affettiva ti permette di sentire tutto e di non annegare in niente. Chi ti sta vicino trova in te un posto fermo, non un muro freddo.

### capovolta

- 1: Governare ciò che senti ti costa una fatica nuova: la stessa stretta tiene l'onda sotto il coperchio oppure la lascia andare fuori misura. Non è il sentire a essersi guastato, è il comando su di esso.
- 2: L'onda tua sfugge al comando in due modi opposti: premuta giù finché non si sente oppure lasciata correre oltre misura. In mezzo resta da dire il nome di ciò che provi.
- 3: Quello che vacilla non è il cuore, è la presa su di esso: il tuo sentire esce a scatti e poi si rovescia intero, perché dirlo apertamente ti sembra più rischioso che tenerlo dentro.

## Asso di Denari

### dritta

- 1: Il terreno che hai sotto i piedi è fertile e una sola apertura concreta ti basta, perché ciò che metti giù adesso attacca con radici buone.
- 2: Davanti a te si apre una cosa solida e palpabile, non una speranza: il momento regge il peso di un inizio che poggia su basi vere.
- 3: Qualcosa di tangibile ti viene offerto e il suolo lo accoglie, così puoi mettere giù adesso una base robusta che porta frutto.

### capovolta

- 1: Sfiori senza vederla un'apertura concreta, oppure misuri il rischio soltanto a occhio mentre il seme buono ti rimane chiuso in tasca.
- 2: Un'occasione solida passa accanto a te e i tuoi occhi stanno altrove. Il terreno sta pronto, il chicco resta asciutto dentro il sacco.
- 3: La misura del rischio ti è sfuggita, oppure l'apertura davanti a te sfuma mentre aspetti il segno di una certezza che non viene.

## Due di Denari

### dritta

- 1: Tieni insieme più cose e il polso tuo le fa ruotare senza che cadano, perché il ritmo conta e la leggerezza fa il resto.
- 2: Una mano tua sale mentre l'altra scende e il peso passa da un palmo all'altro con ritmo costante, senza che nulla tocchi terra.
- 3: Passi da un impegno all'altro con agilità e il segreto sta nelle ginocchia morbide, non nella forza delle braccia tue.

### capovolta

- 1: Le cose che tieni in aria sono più di quante le mani ne passino da una all'altra: il tempo del giro si è perso, non la forza del braccio.
- 2: Il numero ha superato la mano: un impegno, preso per sé, starebbe in piedi e insieme agli altri chiede un ritmo che la rotazione non tiene più.
- 3: Hai aggiunto un pezzo al giro e l'alternanza che li teneva su ha perso il passo, perché il conto delle cose, non il carico sulle spalle, ha passato la misura delle tue mani.

## Tre di Denari

### dritta

- 1: L'opera che hai per le mani regge su più teste. La tua parte combacia con quella degli altri e i primi risultati si vedono già.
- 2: Mani diverse convergono sulla stessa opera e nessuna basta da sé. Il tuo apporto viene notato per quel che vale, non per chi lo firma.
- 3: Un sapere concreto, tuo e di chi ti sta accanto, si somma. I primi frutti ti dicono che la misura presa è buona e che l'insieme tiene.

### capovolta

- 1: Lavori con altri sopra la stessa opera e nessuno ha mai detto chi fa quale pezzo. La volontà di costruire c'è da tutte le parti, è la parola sui ruoli che non è passata.
- 2: I ruoli che nessuno ha messo in chiaro sono la stonatura di questo lavoro a più mani. Due di voi fanno lo stesso gesto e un pezzo dell'opera non lo prende in mano nessuno.
- 3: Vi siete messi insieme a costruire senza dividere i compiti e adesso il cantiere va a scatti. Nessuno rema contro: manca il modo di dirsi chi tiene cosa.

## Quattro di Denari

### dritta

- 1: La mano chiusa intorno a ciò che hai ti tiene al sicuro e il controllo su quel poco o molto che possiedi ti dà una base ferma.
- 2: Una presa salda su beni ed energie ti garantisce stabilità e la prudenza con cui conservi ti vale come una muraglia.
- 3: Tieni stretto ciò che è tuo e lo difendi da chi lo vorrebbe. Il risparmio di oggi ti costruisce un riparo che regge il vento.

### capovolta

- 1: Trattieni con le dita strette ciò che hai di prezioso. La paura di perderlo ti costa la mano libera e il respiro largo.
- 2: Stringi e la mano non si apre più, così il timore di perdere ti irrigidisce le dita e ciò che trattieni ti trattiene.
- 3: C'è un pugno chiuso intorno alle tue energie e il timore di restare senza lo serra fino a bloccare ogni scambio.

## Cinque di Denari

### dritta

- 1: Ti resta addosso la sensazione di stare fuori dalla porta. Una mancanza concreta ti pesa e il tepore sembra riservato ad altri.
- 2: La mancanza ti isola e il tepore sta più vicino di come lo immagini, a portata di una domanda che non hai ancora fatto a nessuno.
- 3: Un'esclusione silenziosa e una scarsità concreta ti lasciano al freddo nello stesso tempo, mentre il tepore resta a pochi passi da te.

### capovolta

- 1: Un sostegno viene da fuori e il freddo cede. L'abbondanza torna senza fretta e la fiducia te la riprendi come era prima.
- 2: Dopo la mancanza un sostegno è tornato da fuori e il freddo allenta. All'abbondanza e alla fiducia ti riapri lentamente.
- 3: A tornare è un sostegno che non nasce da te e il freddo scema. L'abbondanza riparte piano e alla fiducia fai di nuovo posto.

## Sei di Denari

### dritta

- 1: Dai con la mano aperta e ricevi nella stessa misura, così la bilancia resta in pari. L'abbondanza che ti passa attraverso cresce solo circolando.
- 2: Uno scambio equo ti attraversa e il peso sui piatti si pareggia da sé. Quanto doni ritorna, ciò che ricevi riparte: la ricchezza sta nel movimento.
- 3: La generosità che pratichi rientra da sola, perché il dare e il prendere stanno sullo stesso filo. Tieni i piatti in equilibrio e nulla si perde per te.

### capovolta

- 1: La bilancia pende da un piatto solo: esce da un verso e non rientra dall'altro, così la tua generosità resta senza ritorno.
- 2: Dai a chi non restituisce e il piatto dalla tua parte si alleggerisce fino a suonare vuoto. Misurare lo scambio in andata e in ritorno rimette le cose a pari.
- 3: Un debito aperto, oppure una mano tesa verso chi non la stringe, tiene la tua bilancia inclinata. Il pareggio si misura anche su ciò che entra, non soltanto su ciò che esce.

## Sette di Denari

### dritta

- 1: Una pianta che hai curato cresce con un tempo suo e non col tuo, perciò la stai guardando senza toccare mentre il frutto si fa pesante.
- 2: Guardi crescere ciò che hai piantato e tieni le mani ferme, perché un raccolto strappato in anticipo non sa di niente.
- 3: Pesi da lontano il lavoro che hai fatto e lo lasci maturare al suo ritmo, dato che una cosa solida non arriva in fretta.

### capovolta

- 1: Tiri verso di te un frutto ancora verde, oppure guardi lo sforzo speso e non vedi ritorno, mentre il tempo del raccolto resta fuori dalle tue mani.
- 2: La fretta ti porta la mano addosso al ramo, o il ritardo ti fa chiedere se la tua fatica abbia radici nel punto in cui l'hai messa.
- 3: Un'impazienza sottile ti spinge a strappare prima del tempo. Lo sforzo sembra ripagato poco, eppure il seme e la stagione pesano in modo diverso.

## Otto di Denari

### dritta

- 1: Limi un dettaglio alla volta e le mani tue imparano da sole, perché la pratica ripetuta deposita abilità dentro i gesti senza fretta.
- 2: Una dedizione paziente ti tiene al banco e ogni ripetizione aggiunge un grado di precisione alla mano tua, invisibile oggi e solida domani.
- 3: Ripeti il gesto finché diventa esatto e la cura minuta di adesso si annida nelle dita tue come una memoria del corpo.

### capovolta

- 1: Una ripetizione svuotata ti tiene le mani occupate e il senso di ciò che fai è rimasto indietro, mentre i gesti proseguono puntuali e spenti.
- 2: La precisione tua resta intatta mentre il calore dentro il gesto si è raffreddato e il giorno ripetuto somiglia a una stanza senza finestre.
- 3: Lo stesso movimento torna identico ogni giorno e la dedizione tua ha smarrito la ragione per cui era nata, ridotta a routine delle dita.

## Nove di Denari

### dritta

- 1: Un benessere costruito con le tue mani tiene da solo, senza puntelli esterni. Hai un recinto fiorito e nessuno te lo ha regalato.
- 2: Frutti maturi pendono dai rami che hai piantato tu. La tranquillità che ne viene non dipende da un permesso altrui e nessuno può ritirarla.
- 3: Il giardino è tuo, curato per stagioni intere, adesso restituisce. Dentro questa misura ti muovi con agio, senza dover chiedere licenza.

### capovolta

- 1: Quello che hai attorno l'hai messo su con le tue mani e adesso ti chiedi quanto valga chi lo abita. Il conto delle cose risponde al posto tuo, mentre gli eccessi che ti concedi limano la quiete.
- 2: Un'insicurezza dentro una casa che si regge da sé: ti misuri sul prezzo di quello che possiedi e quello che ti concedi in più assottiglia la serenità da dentro.
- 3: Dentro un'autonomia che tiene, si muove il dubbio di valere quanto le cose raccolte e ciò che ti concedi senza misura tocca la quiete prima del portafoglio.

## Dieci di Denari

### dritta

- 1: Costruisci qualcosa che dura oltre te e la stabilità profonda ti regge sotto i piedi, mentre quelli che vengono dopo trovano la tavola già apparecchiata.
- 2: Le radici che hai messo giù tengono il peso di parecchie generazioni. Ciò che costruisci resta in piedi anche senza la tua mano.
- 3: Una ricchezza lenta ti mette al sicuro e lega la tua vita a quella dei tuoi, con radici che affondano sotto il tempo di una vita.

### capovolta

- 1: Una contesa sui beni passa fra i tuoi e tocca la parte del patrimonio che stava in piedi da prima di te, non il conto di questa stagione.
- 2: Dentro la famiglia si discute di ciò che appartiene a più di uno e la discussione scende fino alle fondamenta della casa, dove le cose e i legami si tengono insieme.
- 3: Il patrimonio comune come terreno di discussione fra parenti: la tensione corre sulle cose di casa e arriva all'armonia di chi quelle cose le divide con te.

## Fante di Denari

### dritta

- 1: Quello che hai davanti ti mette in posizione di allievo: va imparato prima di essere condotto e il mestiere lo prendi con l'esercizio, una prova dopo l'altra.
- 2: Un'applicazione da scolaro accanto a te: ripeti le mosse finché tengono, prendi appunti su ciò che non sapevi fare; lo studio porta avanti la cosa.
- 3: Hai preso quella promessa concreta come si prende una materia da studiare: ci metti ore, la provi, impari a farla mentre la fai; il passo avanza quanto l'esercizio.

### capovolta

- 1: Un progetto cominciato da poco è rimasto a metà e la testa è andata altrove. Il tempo perso non si recupera in blocco: quella pretesa è esattamente ciò che lo tiene fermo un altro giorno.
- 2: La promessa dell'inizio senza il seguito: l'impegno preso con quel lavoro si è sfilato per distrazione, non per una caduta. Torna un passo per volta, non con lo scatto che vorresti.
- 3: Si è fermato a metà quello che avevi avviato, perché l'attenzione si è spostata altrove. Quando ripartirà sarà a passi piccoli: tutto l'arretrato insieme non si riprende.

## Cavaliere di Denari

### dritta

- 1: Avanzi di un passo per volta senza accelerare e il metodo tiene al posto dello slancio. La lentezza con cui procedi è la ragione per cui non ti fermi.
- 2: Mantieni la stessa andatura anche quando nulla si vede muovere e il tuo ritmo non brilla, non si spezza. La costanza è il materiale che regge.
- 3: Un impegno paziente ti porta avanti di poco ogni giorno e la meta si avvicina senza strappi. Non è un limite muoversi piano, è il motivo per cui arrivi.

### capovolta

- 1: L'andatura che avevi preso si è piantata a metà strada e una prudenza che pretende il momento perfetto la tiene ferma lì. Quel passo torna a muoversi al primo spostamento, anche piccolissimo.
- 2: C'è una fermata che non è riposo: il momento giusto non arriva mai abbastanza giusto e intanto la strada resta dove l'avevi lasciata. Una cosa qualunque messa in movimento le ridà presa.
- 3: Cercare le condizioni perfette ha fermato un passo che stava già avanzando. Resta a mezz'aria e ciò che lo rimette in moto è un movimento qualsiasi, non un piano migliore.

## Regina di Denari

### dritta

- 1: Sai nutrire e tenere in ordine con le stesse mani, perciò chi ti sta vicino mangia e i progetti tuoi crescono con i piedi per terra.
- 2: Un'abbondanza senza sfarzo esce dalle tue cure quotidiane, perché unisci la tenerezza alla praticità e il risultato si vede nelle cose.
- 3: Accogli e sfami con gesti pratici, non con promesse: la tua generosità tocca il concreto e lo fa fiorire fra le dita.

### capovolta

- 1: Tieni in ordine la casa, il lavoro e le persone che ti stanno attorno, una cosa dopo l'altra; nell'elenco di chi va nutrito il tuo nome non compare.
- 2: Una cura pratica che arriva a tutto: i pasti, i conti, le stanze, chi ti chiama. Ti occupi del giardino intero e la pianta che sei tu resta fuori dal giro dell'annaffiatoio.
- 3: Mentre mandi avanti le cose di tutti, con le mani dentro i dettagli concreti, hai smesso di contarti tra quelle di cui occuparti: ti dimentichi di te nel gesto stesso con cui curi.

## Re di Denari

### dritta

- 1: La solidità che hai costruito ti sostiene da sé e la generosità matura apre il granaio agli altri, misurando bene e senza vanto.
- 2: Un'abbondanza concreta ti sta fra le mani e saperla distribuire fa parte della ricchezza stessa, come il sapere quanto trattenerne.
- 3: Possiedi qualcosa di stabile e la mano tua resta aperta, perché la prosperità nelle dita di chi sa gestirla diventa anche saggezza.

### capovolta

- 1: Stringi forte ciò che hai costruito e le dita non si aprono più, così la ricchezza ferma nel pugno comincia a pesare sul braccio tuo.
- 2: C'è una rigidità attorno ai beni tuoi e il bisogno di trattenerli si è messo al posto della generosità, con il granaio sigillato dall'interno.
- 3: Tieni chiuso il magazzino e le cose che possiedi hanno preso le redini, mentre la mano tua si irrigidisce intorno a ciò che ha accumulato.

## Asso di Spade

### dritta

- 1: La lama del pensiero taglia netto e separa il vero dal falso senza riguardi. Nella tua domanda c'è un'idea che non ammette sfumature comode.
- 2: Vedi con nitidezza. Un taglio del pensiero divide ciò che prima sembrava un impasto unico e ti consegna una frase sola, esatta, scomoda da pronunciare.
- 3: C'è un filo tagliente nel tuo ragionamento adesso: distingue, nomina, chiude le ambiguità. La verità che ne viene fuori non è morbida e regge il peso.

### capovolta

- 1: La nebbia sta sulle idee prima che sulla lingua: il filo che tieni in mano non separa più niente e ogni frase che esce da lì taglia senza avere visto.
- 2: Un'unica lama, due usi: libera oppure ferisce secondo come la impugni. Adesso la impugni in una luce scarsa, con i pensieri confusi fra loro e una decisione che aspetta.
- 3: Quello che si è annebbiato è lo strumento stesso con cui distingui, non la tua voglia di capire. Da lì nascono parole affilate usate di sbieco, perché la mano stringe il filo prima che la mente si schiarisca.

## Due di Spade

### dritta

- 1: Un equilibrio precario ti tiene immobile fra due pesi uguali: decidere ti pare impossibile e intanto la questione resta intera.
- 2: Tieni due pesi in equilibrio a occhi chiusi e la scelta che rimandi non svanisce per questo, ti aspetta dietro la benda.
- 3: C'è uno stallo che tieni in piedi a occhi coperti e la fatica di non guardare ti pesa senza far sparire la scelta.

### capovolta

- 1: Vedi ciò che prima coprivi e la questione sospesa ti torna davanti con la sua domanda, senza la copertura che le avevi messo.
- 2: C'è un nodo che ti si scioglie e la scelta rimandata torna a chiederti una risposta, mentre la benda cade dagli occhi.
- 3: Una scelta che avevi messo da parte ti ritrova e gli occhi scoperti ti mostrano i due pesi che tenevi uguali senza guardarli.

## Tre di Spade

### dritta

- 1: Ti attraversa un dolore netto, di quelli che hanno un taglio preciso e un nome. Il pianto che lasci uscire muove la ferita, quello trattenuto la fissa.
- 2: La delusione ha fatto un taglio netto e il tuo petto se ne accorge prima della testa. Le lacrime che scorrono portano via qualcosa, le altre restano dentro.
- 3: Una ferita aperta non si lascia ragionare e il dolore che senti fino in fondo si richiude, mentre quello respinto ti resta uguale.

### capovolta

- 1: Il dolore comincia a sfumare e il perdono che concedi o che ricevi chiude la tua ferita senza cancellarne la memoria.
- 2: Un respiro più ampio ti torna nel petto mentre la ferita smette di sanguinare. Il ricordo rimane, privo della lama che aveva.
- 3: Smettere di sanguinare non significa dimenticare e la pioggia che si allontana lascia il tuo petto libero di respirare.

## Quattro di Spade

### dritta

- 1: Dopo la fatica il silenzio vale come cura e fermarti non ti sottrae niente. La quiete ricarica la mente quanto il corpo.
- 2: Una pausa aperta sopra di te ti mette a disposizione il silenzio e la stanchezza si scarica senza che tu faccia altro. Il recupero rende quanto l'azione.
- 3: Smetti di combattere per un intervallo e la mente trova la quiete che il corpo reclama. Il tempo passato immobile ti restituisce la forza intera.

### capovolta

- 1: La sosta ha reso tutto il suo frutto e adesso l'immobilità pesa sulle tue spalle. Rientrare in movimento con misura evita il contraccolpo.
- 2: Hai riposato a sufficienza e le gambe lo sanno prima della testa. Riprendere senza strafare al primo colpo tiene il recupero in piedi.
- 3: Basta quiete: il silenzio ha reso quanto doveva e la ripresa ti tocca adesso, a passo misurato e senza slanci da primo giorno.

## Cinque di Spade

### dritta

- 1: C'è una vittoria che ti lascia il campo e ti porta via dei pezzi, perché l'orgoglio ha parlato prima di te nello scontro.
- 2: Il sapore di avere vinto si mescola a un vuoto, dato che ottieni il punto e lasci sul terreno una cosa che ti apparteneva.
- 3: Qualcosa conquistato con le armi ti resta in mano senza gusto. Il prezzo dell'orgoglio soddisfatto si conta a cose perdute.

### capovolta

- 1: Abbassi la spada prima dell'altro in uno scontro dove la ragione sta dalla tua parte e quella ragione la lasci cadere invece di portarla fino in fondo.
- 2: La ragione ce l'hai e la deponi comunque: la voglia di riconciliare arriva con le armi ancora in mano e il perdono prende il posto che spettava alla rivendicazione.
- 3: Una resa offerta da chi non era in torto: il primo gesto verso la pace parte da te e ciò che potevi far valere contro l'altro resta senza essere usato.

## Sei di Spade

### dritta

- 1: C'è una barca che ti porta lontano dalle acque mosse e la riva davanti promette quiete, raggiunta remando piano senza strappi.
- 2: Il rumore della tempesta si allontana dietro di te e l'acqua sotto lo scafo torna liscia, mentre avanzi con un colpo di remo per volta.
- 3: Lasci dietro le onde alte e la traversata procede lenta sotto di te, con la sponda quieta che si avvicina a ogni spinta di remo.

### capovolta

- 1: Una corda invisibile ti trattiene alla riva vecchia e il distacco pesa più del previsto, mentre la barca aspetta con i remi pronti.
- 2: Qualcosa del passato sale a bordo insieme a te e la partenza costa fatica, possibile comunque anche con la valigia pesante in braccio.
- 3: C'è una riva che non lasci andare e il remo tuo affonda con fatica mentre gli occhi restano puntati indietro, verso l'acqua già attraversata.

## Sette di Spade

### dritta

- 1: Una mossa obliqua attraversa il tuo campo: silenzio, tempismo, niente clamore. L'ingegno fa il grosso del lavoro e tu resti fuori dai riflettori.
- 2: C'è astuzia al lavoro nella tua domanda e procede in punta di piedi. Ottiene senza annunciare, aggira la resistenza, lascia la tua mano invisibile.
- 3: Prudenza e calcolo al posto dell'urto diretto. L'ingegno ti riesce; il confine fra arte e imbroglio lo conosci soltanto tu.

### capovolta

- 1: Viene a galla un doppio fondo, tuo o di un altro; la coscienza lo registra prima della testa. Mantenere la finzione occupa energia che non torna.
- 2: Un inganno pesa sulla scena, non importa da quale mano arrivi. Il silenzio che lo copre ti consuma attenzione ogni giorno in cui lo tieni su.
- 3: Il gioco sotterraneo si scopre da sé. Carte sottratte, versioni diverse dello stesso fatto, un peso che la tua coscienza registra senza che tu lo dica.

## Otto di Spade

### dritta

- 1: C'è un recinto di pensieri intorno a te e il limite che senti sta soprattutto nella tua testa, mentre le corde restano più larghe di quanto credi.
- 2: Ti pare di non poterti muovere e il buio sugli occhi insieme alle braccia legate ti fa credere a una prigione con pareti di pensiero.
- 3: Senti il limite addosso e lo prendi per vero, mentre il primo movimento che ti resta sta nel vedere che un'uscita esiste.

### capovolta

- 1: Dopo il senso di trappola trovi un varco aperto e le corde non tengono. La tua capacità di muoverti era intera già prima.
- 2: C'è un varco aperto e le braccia ti si liberano, mentre il racconto della paura smette di coincidere con la tua misura.
- 3: Cadono le corde e il varco che non vedevi sta aperto davanti a te, mentre la paura che ti descriveva la prigione perde credito.

## Nove di Spade

### dritta

- 1: Di notte la tua mente monta pensieri che il giorno non confermerebbe e l'insonnia dà alle paure una taglia che non hanno.
- 2: C'è un pensiero che gira a vuoto nelle ore senza sonno e ingrandisce ogni timore fino a riempirti il petto, mentre il tuo corpo chiede riposo.
- 3: Tornano i pensieri cupi appena si spegne la luce e la tua testa li tratta come fatti compiuti, non come ipotesi da verificare.

### capovolta

- 1: Parlarne con qualcuno taglia il peso a metà e la paura che hai rigirato nel silenzio perde la sua presa quando esce dalla tua testa.
- 2: La morsa dell'angoscia si allenta e il pensiero smette di girare sullo stesso punto, abbastanza perché tu senta la differenza.
- 3: Una paura detta a qualcuno pesa meno della stessa cosa rimuginata al buio. Il tuo respiro cambia appena il silenzio si rompe.

## Dieci di Spade

### dritta

- 1: Un ciclo doloroso tira la tenda e tu senti il pavimento sotto la schiena. La discesa ha trovato il suo limite, più in basso il terreno non cede.
- 2: Tocchi il fondo con tutto il tuo peso e la resa arriva senza trattative. Non c'è margine da difendere, c'è una chiusura compiuta.
- 3: Arrivi in fondo alla discesa e non rimane altro da perdere, perché la caduta ha incontrato il suo pavimento. La resa che ti attraversa è reale, non è debolezza.

### capovolta

- 1: La parte più dura l'hai già attraversata e adesso ti rialzi dal punto in cui eri a terra: quello che è finito non riparte, ricomincia qualcos'altro, con tutta la lentezza che chiede.
- 2: Il ricominciare da capo dopo una chiusura completa: ti rimetti su piano, senza strappi, verso un inizio che non è la ripresa di quello che avevi.
- 3: Da terra ti tiri su senza strappi e la parte più dura ti resta dietro: davanti c'è un da capo, coi tempi lunghi di chi riparte da zero.

## Fante di Spade

### dritta

- 1: Stai in sentinella su una cosa che vuoi sapere e ancora non sai: fai domande, raccogli voci, metti insieme i pezzi prima di avere qualcosa da pronunciare.
- 2: Una curiosità in cerca di prove: controlli, verifichi, torni a guardare; la verità resta da trovare invece di essere già formata dentro di te.
- 3: Hai cominciato a informarti su qualcosa e non stacchi gli occhi: le tue domande vengono prima delle affermazioni e le parole pronte le pesi a una a una.

### capovolta

- 1: C'è una lingua che corre prima della verifica, o pensieri sparpagliati che pungono senza costruire niente intorno a te.
- 2: Riporti notizie non controllate, oppure spari idee acute che bucano e non tengono su nulla. Le parole buttate ti tornano indietro addosso.
- 3: La punta della lingua esce prima del controllo, mentre i pensieri sparsi colpiscono senza tenere insieme niente. Il rimbalzo ti raggiunge.

## Cavaliere di Spade

### dritta

- 1: Già deciso, il pensiero punta diritto allo scopo. La tua rapidità passa sopra chi ti sta accanto se diventa fretta cieca.
- 2: Decise le idee, la rapidità ti porta diritta allo scopo e chi hai accanto lo travolgi quando la fretta si fa cieca.
- 3: La decisione è già presa e la mira va diritta allo scopo e sotto quella spinta chi ti è vicino lo investi in pieno.

### capovolta

- 1: Parti prima di pensare e le parole tue escono affilate dalla bocca, con il cavallo già in movimento mentre le redini restano a terra.
- 2: Dalla bocca tua esce qualcosa di più veloce della testa e la fretta taglia l'aria senza guardare chi sta davanti, lasciando piccoli tagli dietro.
- 3: Vai avanti al galoppo e la lucidità tua resta indietro di un passo, mentre le frasi che lanci arrivano prima di avere trovato una forma.

## Regina di Spade

### dritta

- 1: La tua franchezza esce senza giri e disegna confini netti attorno a te. Chi ti parla sa fin dove può andare; la chiarezza ti fa da riparo.
- 2: Il pensiero taglia pulito e la tua parola lo segue. Niente eufemismi, poche curve: dici le cose per nome e il nome tiene, anche quando scomoda.
- 3: Distingui il vero dal recitato. La lucidità ti serve da scudo e l'onestà con cui la usi tiene lontano chi vive di approssimazioni.

### capovolta

- 1: Porti la durezza come una corazza: tiene lontano chi potrebbe ferirti e insieme chi potrebbe scaldarti. La lama con cui misuri tutto, per prima cosa, taglia chi la impugna.
- 2: Il giudizio che non fa sconti a nessuno comincia da te. La durezza ti fa da guscio e quello che tiene fuori non è soltanto chi ferisce, è anche chi porta calore.
- 3: La solitudine qui è un'armatura, non una sosta. Il taglio con cui tieni il mondo a distanza si gira verso dentro e il primo a riceverlo sei tu.

## Re di Spade

### dritta

- 1: Per gli altri decidi con equità e la tua ragione sta al servizio del bene. Loro ti guardano come il punto lucido e onesto.
- 2: Altri aspettano una tua parola e la dici con onestà, perché la mente che adoperi serve il bene e non comanda lei.
- 3: La tua autorità è quella della mente e delibera per gli altri e la lucidità onesta ti rende il luogo a cui vengono.

### capovolta

- 1: Hai ragione e perdi il legame, perché il freddo con cui tagli non lascia spazio alla compassione. L'autorità tua pesa senza scaldare.
- 2: Ragioni al netto delle persone che hai davanti e la logica con cui vinci una discussione ti scolla proprio i legami che tenevi.
- 3: C'è un rigore senza tenerezza nel tuo modo di pensare e le persone che contano restano fuori dal ragionamento con cui decidi.
