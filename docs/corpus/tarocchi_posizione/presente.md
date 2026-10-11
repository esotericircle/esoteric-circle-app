# LA POSIZIONE: PRESENTE

Il presente della stesa a tre carte.

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

**La variante 1 viene dal corpus del 27 settembre 2026** (ordine EQ voce 04,
`docs/corpus/tarocchi_nella_posizione.md` fino all'ordine FI): generata da
Gemini 2.5 Flash su Vertex AI in `europe-west1` coi controlli qui sopra, poi
riletta uno per uno, con 45 testi corretti a mano nella fonte. E' l'unica
parte del corpus dei tarocchi scritta da un modello; le varianti 2 e 3 le
scrive l'Architetto.

## Il Matto

### dritta

- 1: Un nuovo inizio ti chiama ora e senti la spinta a partire senza pesi, con la libertà di chi non ha bisogno di vedere tutta la strada.
- 2:
- 3:

### capovolta

- 1: Senti l'impulso di agire in modo sconsiderato o, al contrario, un blocco ti frena dal fare un passo importante. È il momento di capire se la tua spinta è coraggio o una fuga da qualcosa che non hai voluto vedere.
- 2:
- 3:

## Il Mago

### dritta

- 1: Senti il potere di creare, hai tra le mani tutti gli strumenti e la volontà per usarli. Il momento chiede di manifestare ciò che finora era solo idea.
- 2:
- 3:

### capovolta

- 1: Non stai mettendo a frutto le tue doti, oppure le tue intenzioni non si traducono in azioni concrete. C'è uno scollamento tra il dire e il fare che ti impedisce di realizzare i tuoi obiettivi.
- 2:
- 3:

## La Papessa

### dritta

- 1: Ti affidi al tuo sapere silenzioso, quello che non ha bisogno di spiegazioni. Accogli un mistero che si rivela solo alla mente quieta, senza fretta di decidere.
- 2:
- 3:

### capovolta

- 1: Stai attivamente mettendo a tacere un sapere che viene da dentro, forse per paura di ciò che ti rivelerebbe. Questa chiusura rischia di impedirti di riconoscere una conoscenza fondamentale, se solo ti concedessi di accoglierla.
- 2:
- 3:

## L'Imperatrice

### dritta

- 1: Sei al centro di un processo creativo dove la tua energia generatrice permette a qualcosa di nuovo di svilupparsi in modo naturale e abbondante.
- 2:
- 3:

### capovolta

- 1: La tua energia creativa è bloccata e non stai nutrendo la tua radice. Ti senti distante da ciò che ti fa fiorire dentro.
- 2:
- 3:

## L'Imperatore

### dritta

- 1: Definisci regole chiare e ti muovi con fermezza per sostenere le tue scelte. Stai consolidando e dando struttura a quanto vivi, assumendoti le tue responsabilità.
- 2:
- 3:

### capovolta

- 1: La mancanza di basi solide o un sistema troppo rigido ti impediscono di avanzare, creando incertezza. Cerchi stabilità, ma trovi solo vincoli che ti bloccano.
- 2:
- 3:

## Il Papa

### dritta

- 1: Ti confronti con la necessità di integrare gli insegnamenti ricevuti, di farli tuoi per costruire la tua saggezza. Puoi diventare una fonte di ispirazione, consolidando la tua sapienza interiore.
- 2:
- 3:

### capovolta

- 1: Senti che un sapere ricevuto non è più adeguato. Questo ti spinge a rivedere le tue regole e a cercare un senso che ti faccia respirare.
- 2:
- 3:

## Gli Amanti

### dritta

- 1: Senti la necessità di fare una scelta che coinvolge i tuoi valori profondi, integrando la ragione e il sentimento per allinearti a ciò che sei.
- 2:
- 3:

### capovolta

- 1: Stai vivendo un conflitto interiore che ti impedisce di fare una scelta sincera. I tuoi valori attuali sono in contrasto e ti rendono difficile trovare un equilibrio.
- 2:
- 3:

## Il Carro

### dritta

- 1: Prendi saldamente le redini della tua vita, armonizzando spinte opposte. Hai la forza e la direzione per avanzare con decisione.
- 2:
- 3:

### capovolta

- 1: Senti una notevole dispersione delle energie, come se forze contrastanti tirassero in direzioni diverse. Hai difficoltà a mantenere una rotta definita e rischi di procedere senza una chiara meta.
- 2:
- 3:

## La Giustizia

### dritta

- 1: È tempo di verità e di scelte: senti il bisogno di prendere una posizione chiara, senza scorciatoie o giustificazioni.
- 2:
- 3:

### capovolta

- 1: Il tuo equilibrio dipende dal riconoscimento di una verità che stai ignorando. Fino a quando non la guardi in faccia, non puoi trovare serenità.
- 2:
- 3:

## L'Eremita

### dritta

- 1: Senti il bisogno di isolarti per trovare la tua direzione. La tua ricerca interiore ti guida un passo alla volta verso una verità personale.
- 2:
- 3:

### capovolta

- 1: Il tuo ritiro rischia di isolarti. La tua ricerca di chiarezza, che dovrebbe guidarti, ti sta portando lontano dagli altri invece di mostrarti la strada per ricongiungerti.
- 2:
- 3:

## La Ruota della Fortuna

### dritta

- 1: Il destino sta girando e ti porta verso una svolta inaspettata; è un'occasione per accogliere il nuovo senza aggrapparti a ciò che conosci. Muovi i tuoi passi con il flusso degli eventi.
- 2:
- 3:

### capovolta

- 1: Senti che un ciclo vitale è bloccato e non riesci a trovare il modo di farlo ripartire. La situazione attuale ti sembra sfuggire di mano e ti senti senza controllo.
- 2:
- 3:

## La Forza

### dritta

- 1: Senti la necessità di un approccio delicato per addomesticare le situazioni difficili, usando la pazienza e la persuasione anziché lo scontro diretto per raggiungere i tuoi obiettivi.
- 2:
- 3:

### capovolta

- 1: Ti stai trattando con eccessiva durezza, criticandoti aspramente e mettendo in discussione la tua tenuta e il tuo valore.
- 2:
- 3:

## L'Appeso

### dritta

- 1: Senti il bisogno di mettere in pausa ogni azione, di attendere. Questa sosta ti porta a una comprensione profonda che ti rivela nuove visioni sulla situazione.
- 2:
- 3:

### capovolta

- 1: Senti che la tua attesa non sta producendo alcun risultato, ti trovi in uno stallo. Il sacrificio che stai affrontando non porta beneficio a nessuno e non ti permette di agire.
- 2:
- 3:

## La Morte

### dritta

- 1: Senti che è il momento di un cambiamento profondo, una trasformazione che ti invita a liberarti di ciò che non ti serve più per evolvere.
- 2:
- 3:

### capovolta

- 1: Il tuo aggrapparti a ciò che non c'è più ti impedisce di avanzare, prolungando una sofferenza inutile e impedendoti di procedere oltre.
- 2:
- 3:

## La Temperanza

### dritta

- 1: Stai unendo con maestria elementi che sembravano incompatibili, dosando ogni cosa con calma e misura per raggiungere un punto di equilibrio stabile.
- 2:
- 3:

### capovolta

- 1: Stai vivendo una disconnessione tra diverse parti di te, come se non riuscissero a comunicare in armonia. Senti una tendenza a non trovare un centro.
- 2:
- 3:

## Il Diavolo

### dritta

- 1: Senti il peso di attaccamenti che limitano le tue scelte, un'ombra ti sfida a riconoscerla. Adesso è il momento di affrontare questa verità per sciogliere i nodi.
- 2:
- 3:

### capovolta

- 1: Stai scoprendo un vincolo che ti teneva con il suo potere, ora lo vedi chiaramente. Questa consapevolezza ti permette di agire e di sciogliere ciò che ti imprigionava, recuperando la tua libertà.
- 2:
- 3:

## La Torre

### dritta

- 1: Stai vivendo il momento in cui le strutture fragili crollano, rivelando ciò che è autentico. Questo ti permette di ricostruire su fondamenta più vere e resistenti.
- 2:
- 3:

### capovolta

- 1: Stai ancora tentando di scongiurare una trasformazione, forse per il timore di ciò che ne può conseguire. Ciò che ritieni stabile può rivelarsi precario e non affrontare il problema può aumentare la tensione.
- 2:
- 3:

## La Stella

### dritta

- 1: Senti che il peggio è ormai alle spalle e ti stai affidando a una guida interiore che ti rassicura. Sei su una strada che porta a un benessere più profondo e duraturo.
- 2:
- 3:

### capovolta

- 1: Senti che l'ispirazione e la speranza ti abbandonano, rendendo difficile credere in un miglioramento. Sei in una fase in cui la motivazione è scarsa e fatichi a trovare un senso di direzione.
- 2:
- 3:

## La Luna

### dritta

- 1: Senti che qualcosa non ti è pienamente rivelato, le percezioni sono confuse e le tue paure interiori possono rendere sfocato ciò che ti circonda. Hai bisogno di pazienza per capire.
- 2:
- 3:

### capovolta

- 1: Una confusione che ti avvolgeva si sta chiarendo, le paure perdono il loro peso. Stai uscendo dalla nebbia, vedi con maggiore lucidità ciò che prima ti turbava.
- 2:
- 3:

## Il Sole

### dritta

- 1: Questo è un momento di pieno successo, dove ogni cosa fiorisce e il tuo cuore è colmo di allegria. La tua presenza illumina l'ambiente circostante e le persone si sentono bene con te.
- 2:
- 3:

### capovolta

- 1: Senti che l'entusiasmo è trattenuto e la luce non ti raggiunge pienamente. C'è qualcosa che ostacola la tua gioia di manifestarsi con chiarezza, un impedimento che ti frena dal brillare.
- 2:
- 3:

## Il Giudizio

### dritta

- 1: Senti forte l'esigenza di dare una svolta decisiva alla tua esistenza, riconsiderando ciò che conta davvero per te. Questo è il momento di ascoltare quella parte di te che ti chiede di evolvere e di abbracciare un nuovo modo di essere.
- 2:
- 3:

### capovolta

- 1: Ti critichi con eccessiva severità, una durezza che non ti permette di perdonare e avanzare. Ascolta le tue esigenze con comprensione, prima di condannare il tuo agire.
- 2:
- 3:

## Il Mondo

### dritta

- 1: Sperimenti un momento di pienezza, un traguardo significativo che porta armonia. La tua integrazione è massima, ogni cosa è al proprio posto.
- 2:
- 3:

### capovolta

- 1: Ti avvicini alla conclusione di una fase importante e percepisci che un dettaglio è ancora da definire per una piena realizzazione. Questa prossimità tende a generare una sorta di esitazione finale.
- 2:
- 3:

## Asso di Bastoni

### dritta

- 1: Senti un'energia prorompente che ti invita all'azione, un'ispirazione ardente che ti attraversa e ti spinge a dare il via a qualcosa di nuovo. È il momento di cogliere l'attimo e di non rimandare le tue iniziative.
- 2:
- 3:

### capovolta

- 1: Il tuo slancio iniziale è bloccato, una forza interna o esterna soffoca l'entusiasmo. Non ti manca il desiderio di agire, ma il fuoco stenta a divampare.
- 2:
- 3:

## Due di Bastoni

### dritta

- 1: Senti il bisogno di pianificare con attenzione, scegliendo la strada migliore per il tuo progetto. Hai la possibilità di definire il cammino, è il momento di decidere con visione.
- 2:
- 3:

### capovolta

- 1: Senti la paura di procedere e non ti muovi, perché non hai ancora chiarezza su cosa vuoi davvero. Questa esitazione ti impedisce di prendere una direzione definita e ti tiene in stallo.
- 2:
- 3:

## Tre di Bastoni

### dritta

- 1: Stai attendendo con fiducia che i tuoi sforzi portino i frutti desiderati. Le azioni intraprese in passato cominciano a manifestarsi e ti prepari ad accogliere ciò che sta arrivando.
- 2:
- 3:

### capovolta

- 1: Stai affrontando dei ritardi che ti mettono alla prova, o le tue previsioni non si stanno concretizzando come speravi. È un momento per valutare se attendere ancora o cambiare strategia.
- 2:
- 3:

## Quattro di Bastoni

### dritta

- 1: Stai vivendo un momento di stabilità, riconoscendo il valore di ciò che hai raggiunto. È un tempo per festeggiare le solide fondamenta che hai creato.
- 2:
- 3:

### capovolta

- 1: Senti che l'armonia è difficile da raggiungere, o che le tue fondamenta non sono ancora abbastanza salde. È un momento in cui la gioia piena ti sfugge perché le condizioni ideali non sono ancora presenti.
- 2:
- 3:

## Cinque di Bastoni

### dritta

- 1: Una vivace competizione anima il tuo contesto attuale. Questa dinamica ti invita a confrontarti attivamente, mettendo in gioco le tue capacità per far valere le tue posizioni con determinazione.
- 2:
- 3:

### capovolta

- 1: Gestisci attriti che non meritano la tua energia. Scegli quali battaglie affrontare e lascia andare ciò che non contribuisce al tuo benessere.
- 2:
- 3:

## Sei di Bastoni

### dritta

- 1: Stai vivendo un momento di meritato successo e visibilità, senti l'onore per i risultati raggiunti. Accetta i complimenti e il plauso senza esagerare, ma anche senza sminuire il tuo valore.
- 2:
- 3:

### capovolta

- 1: Il tuo operato non riceve l'attenzione che merita e ciò ti spinge a sminuire le tue capacità. Questa situazione ti invita a riconoscere la tua importanza indipendentemente dall'approvazione altrui.
- 2:
- 3:

## Sette di Bastoni

### dritta

- 1: Stai vivendo un momento in cui è necessario mantenere ferma la tua posizione. Hai il coraggio per sostenere ciò in cui credi, anche se ti senti sotto assedio.
- 2:
- 3:

### capovolta

- 1: Senti il peso delle richieste o degli eventi che ti travolgono. Stai opponendo resistenza anche dove non è necessario: valuta bene cosa proteggere e cosa no.
- 2:
- 3:

## Otto di Bastoni

### dritta

- 1: Gli eventi si stanno muovendo in fretta e senti che le cose stanno accelerando. È il momento di assecondare il flusso, senza frenare l'energia in atto.
- 2:
- 3:

### capovolta

- 1: Stai vivendo una fase di rallentamento forzato, o la tua eccessiva velocità crea ostacoli. È il momento di fermarti per riorganizzare le tue priorità.
- 2:
- 3:

## Nove di Bastoni

### dritta

- 1: Senti il peso della stanchezza, eppure sei a un passo dalla meta. Ora è fondamentale mantenere la determinazione per completare ciò che hai iniziato.
- 2:
- 3:

### capovolta

- 1: Senti il peso di una stanchezza che ti porta a irrigidire le tue difese, impedendoti di aprirti a nuove esperienze. Questa diffidenza rischia di isolarti.
- 2:
- 3:

## Dieci di Bastoni

### dritta

- 1: Senti il peso delle responsabilità che gravano su di te. È il momento di valutare cosa è essenziale mantenere e cosa puoi lasciare andare per alleggerirti.
- 2:
- 3:

### capovolta

- 1: Senti il peso di responsabilità che non ti appartengono più o che non ti servono. Ora è il momento di riconoscere ciò che puoi eliminare per respirare con maggiore leggerezza.
- 2:
- 3:

## Fante di Bastoni

### dritta

- 1: Senti un'energia vivace che ti invita a guardare oltre l'ordinario, un impulso a sperimentare e a metterti alla prova. È il momento di accogliere questa curiosità e di agire con slancio.
- 2:
- 3:

### capovolta

- 1: La tua energia è frammentata, si accende e si spegne senza un obiettivo chiaro. Stai disperdendo il tuo potenziale in troppe direzioni, senza una focalizzazione.
- 2:
- 3:

## Cavaliere di Bastoni

### dritta

- 1: Senti un forte desiderio di muoverti e una gran voglia di agire. Ti muovi con determinazione verso un nuovo inizio, senza esitazione.
- 2:
- 3:

### capovolta

- 1: La foga incauta ti fa procedere con impulsività e senza un piano definito. Rischi di bruciare le tappe e di perdere di vista i tuoi obiettivi.
- 2:
- 3:

## Regina di Bastoni

### dritta

- 1: Il tuo magnetismo personale ti rende un punto di riferimento. Ti senti a tuo agio nell'esprimere chi sei veramente e questo attrae chi ti sta intorno.
- 2:
- 3:

### capovolta

- 1: Il dubbio su di te è forte in questo momento e ti porta a non riconoscere le tue capacità, il che rischia di bloccare la tua iniziativa. Percepisci che il tuo potenziale viene messo in discussione.
- 2:
- 3:

## Re di Bastoni

### dritta

- 1: La tua leadership è ora richiesta per tracciare una direzione precisa. La tua generosità indica agli altri il cammino, sii un esempio per tutti.
- 2:
- 3:

### capovolta

- 1: Gestisci una situazione in cui l'autorità si manifesta con rigidità, senza dare spazio al confronto. Il tuo modo di condurre le cose rischia di non coinvolgere, ma di imporre la tua volontà.
- 2:
- 3:

## Asso di Coppe

### dritta

- 1: Senti un'emozione pura sgorgare, un nuovo inizio che ti invita ad aprire il cuore e a lasciarti andare. È un tempo propizio per l'accoglienza e la dolcezza, senza paure o resistenze.
- 2:
- 3:

### capovolta

- 1: Senti una chiusura emotiva che ti impedisce di esprimere i tuoi sentimenti più profondi. C'è una resistenza a lasciarti andare, anche se desideri una connessione autentica.
- 2:
- 3:

## Due di Coppe

### dritta

- 1: Sperimenti un'unione armoniosa, un patto che ti nutre e ti dà forza. Coltiva questa intesa, perché il riconoscimento reciproco moltiplica il tuo benessere.
- 2:
- 3:

### capovolta

- 1: Un malinteso sta creando distanza in una relazione. Ti è chiesto di parlare con il cuore aperto e cercare un nuovo equilibrio.
- 2:
- 3:

## Tre di Coppe

### dritta

- 1: Senti il bisogno di condividere con chi ti è accanto, festeggiando i traguardi o semplicemente l'unione. Ti dedichi con piacere a stare in compagnia e a celebrare la vita insieme agli altri.
- 2:
- 3:

### capovolta

- 1: È il momento di riconsiderare le tue relazioni, riducendo il cerchio per dare spazio a chi ti supporta davvero. Ritorna alle amicizie autentiche, quelle che ti fanno stare bene.
- 2:
- 3:

## Quattro di Coppe

### dritta

- 1: Provi noia e insoddisfazione, tanto da non notare un dono significativo che si manifesta vicino a te. Alza lo sguardo, un'opportunità tende a mostrarsi proprio accanto a te.
- 2:
- 3:

### capovolta

- 1: Senti un risveglio interiore che ti spinge ad aprire il tuo cuore a nuove esperienze. Una curiosità inattesa ti invita a esplorare ciò che prima non consideravi.
- 2:
- 3:

## Cinque di Coppe

### dritta

- 1: Senti il rammarico per qualcosa che ti è sfuggito e questo sentimento ti impedisce di guardare oltre. Non riesci a vedere le risorse che ancora possiedi.
- 2:
- 3:

### capovolta

- 1: Stai accettando il passato e ti stai perdonando per ciò che è successo. Questo ti permette di vedere le opportunità che hai ancora a disposizione.
- 2:
- 3:

## Sei di Coppe

### dritta

- 1: Sperimenti un forte richiamo al passato, un affetto sincero che riemerge e ti invita a rivivere o a onorare vecchi legami e ricordi preziosi. Questa tenerezza ti nutre e ti guida nelle tue interazioni attuali.
- 2:
- 3:

### capovolta

- 1: Corri il rischio di non vivere appieno questo momento, perché ti aggrappi a un tempo che non esiste più. La vita ti chiama adesso, ma la tua attenzione è rivolta al ricordo di ciò che è stato.
- 2:
- 3:

## Sette di Coppe

### dritta

- 1: Molte opzioni affascinanti ti si presentano, rischiando di perderti in fantasie che potrebbero non concretizzarsi e questo crea confusione.
- 2:
- 3:

### capovolta

- 1: Stai mettendo a fuoco un desiderio autentico tra le diverse possibilità che si presentano. La scelta di una direzione ti libera dal peso di dover considerare troppe alternative.
- 2:
- 3:

## Otto di Coppe

### dritta

- 1: Senti il bisogno di abbandonare ciò che non ti nutre. Il tuo cuore ti guida verso la ricerca di un senso più elevato, anche se la ragione non ha ancora risposte chiare.
- 2:
- 3:

### capovolta

- 1: Senti un'indecisione profonda che ti blocca, non riesci a capire se ciò che hai è abbastanza o se devi lasciarlo per cercare altro. È un momento di stallo, dove la scelta di restare o partire ti pesa.
- 2:
- 3:

## Nove di Coppe

### dritta

- 1: Assapori un momento di piena soddisfazione e benessere, un desiderio che si è concretizzato. Il tuo cuore è contento, senti che hai raggiunto la felicità.
- 2:
- 3:

### capovolta

- 1: Stai vivendo una soddisfazione apparente che non ti nutre realmente. Rischi di accontentarti di piaceri effimeri e di non trovare la gioia vera.
- 2:
- 3:

## Dieci di Coppe

### dritta

- 1: Senti una profonda gratitudine per i legami che ti circondano e la loro armonia ti riempie, trovando nella pienezza condivisa la tua vera ricchezza attuale.
- 2:
- 3:

### capovolta

- 1: Senti che l'equilibrio nei tuoi affetti è precario, come se ci fosse una frattura da sanare. C'è bisogno di ricostruire il dialogo e la vicinanza con chi ti sta attorno.
- 2:
- 3:

## Fante di Coppe

### dritta

- 1: Senti nascere in te una creatività inaspettata, un'emozione gentile che chiede espressione. Questo momento ti offre spunti preziosi grazie alla tua sensibilità.
- 2:
- 3:

### capovolta

- 1: Senti il bisogno di proteggere la tua emotività, ma questa chiusura rischia di impedirti di vivere appieno le esperienze e di esprimere i tuoi sentimenti più profondi.
- 2:
- 3:

## Cavaliere di Coppe

### dritta

- 1: Senti un forte desiderio di esprimere affetto e di fare una proposta. È il momento di lasciarti corteggiare e di offrire il tuo cuore con grazia.
- 2:
- 3:

### capovolta

- 1: Stai vivendo una situazione in cui le parole non corrispondono ai fatti, o le tue intenzioni non trovano riscontro nelle azioni. Verifica la concretezza di ciò che senti o ti viene detto.
- 2:
- 3:

## Regina di Coppe

### dritta

- 1: Senti un forte bisogno di ascoltare il tuo intuito, di comprendere le situazioni con il cuore e di agire con tenerezza, affidandoti alla tua empatia per guidarti nelle relazioni e nelle scelte.
- 2:
- 3:

### capovolta

- 1: Senti il peso delle emozioni e delle esigenze altrui e questo rischia di farti perdere il contatto con la tua identità. Puoi riportare l'attenzione su di te.
- 2:
- 3:

## Re di Coppe

### dritta

- 1: La tua padronanza emotiva ti rende un punto di forza, capace di affrontare le sfide con calma profonda. La tua presenza offre stabilità e comprensione, sia a te che agli altri.
- 2:
- 3:

### capovolta

- 1: Sperimenti un'instabilità emotiva che ti impedisce di gestire le situazioni con chiarezza. È essenziale che tu manifesti ciò che senti, superando ogni paura di mostrarti pienamente.
- 2:
- 3:

## Asso di Denari

### dritta

- 1: Una solida opportunità si presenta a te, è il momento giusto per piantare un nuovo seme. Hai a disposizione un terreno fertile per iniziare qualcosa di concreto.
- 2:
- 3:

### capovolta

- 1: Una possibilità rischia di sfuggirti. Guardi la situazione con poca attenzione e questo ti impedisce di cogliere ciò che è prezioso per te.
- 2:
- 3:

## Due di Denari

### dritta

- 1: Stai mantenendo un equilibrio precario tra le diverse richieste, alternando i tuoi impegni con leggerezza. La tua flessibilità è fondamentale per gestire questo momento di costante movimento.
- 2:
- 3:

### capovolta

- 1: Gestisci troppi impegni e rischi di far cadere tutto per non aver stabilito delle priorità. Scegliere ora ciò che è essenziale ti aiuta a non perdere il controllo.
- 2:
- 3:

## Tre di Denari

### dritta

- 1: Costruisci insieme agli altri e il tuo lavoro è visto e apprezzato; questo è solo l'inizio di un percorso dove la collaborazione porta risultati importanti.
- 2:
- 3:

### capovolta

- 1: La mancanza di chiarezza nella comunicazione sta rallentando un'opera comune. Le tue aspettative non sono allineate a quelle degli altri e questo crea attrito.
- 2:
- 3:

## Quattro di Denari

### dritta

- 1: Ti concentri sulla sicurezza, stringendo ciò che hai. Questa prudenza ti protegge, ma al contempo rischia di impedire nuovi apporti o la crescita.
- 2:
- 3:

### capovolta

- 1: La tua rigidità impedisce il fluire delle energie e delle opportunità. Stai stringendo troppo qualcosa e questo ti sta soffocando, limitando la tua libertà di movimento.
- 2:
- 3:

## Cinque di Denari

### dritta

- 1: Percepisci una carenza o un senso di isolamento, come se ti mancasse un elemento fondamentale. Puoi cercare supporto e superare questo stato, senza esitazioni.
- 2:
- 3:

### capovolta

- 1: Stai avvertendo una ripresa, un supporto che ti aiuta a uscire da una situazione difficile. La fiducia sta rientrando: il peggio è passato e l'isolamento pesa meno.
- 2:
- 3:

## Sei di Denari

### dritta

- 1: Sperimenti uno scambio equo, dove l'aiuto reciproco crea armonia. Dai e ricevi in un flusso costante, mantenendo l'equilibrio essenziale per la tua serenità.
- 2:
- 3:

### capovolta

- 1: Stai vivendo una situazione in cui il dare e l'avere non sono bilanciati. Questo comporta un peso che ti impedisce di avanzare senza difficoltà.
- 2:
- 3:

## Sette di Denari

### dritta

- 1: È il momento di valutare i progressi fatti e di attendere con fiducia che i tuoi sforzi diano i frutti sperati. Non affrettare i tempi, perché ciò che sta maturando richiede il giusto compimento.
- 2:
- 3:

### capovolta

- 1: Senti che i tuoi sforzi non vengono ripagati e che l'attesa si fa lunga. Rivedi con calma le tue priorità per non scoraggiarti e non disperdere le tue forze.
- 2:
- 3:

## Otto di Denari

### dritta

- 1: Stai perfezionando le tue competenze con attenzione e meticolosità, un passo alla volta. Questa pratica costante affina il tuo valore e la tua abilità.
- 2:
- 3:

### capovolta

- 1: Senti il peso di un'attività che ti ha svuotato, un mestiere che percepisci come una gabbia. Rischi di non trovare più il senso profondo in ciò che porti avanti.
- 2:
- 3:

## Nove di Denari

### dritta

- 1: Ti godi pienamente ciò che hai costruito, senti di abitare un luogo di indipendenza serena. Sperimenti la piena autonomia e benessere.
- 2:
- 3:

### capovolta

- 1: Un'insicurezza ti assilla, o ti trovi in una situazione di eccessi che minano la tua pace. È il momento di curare la tua indipendenza e riconoscere che il tuo valore va oltre i beni materiali.
- 2:
- 3:

## Dieci di Denari

### dritta

- 1: Stai edificando qualcosa che tende a durare nel tempo, con una visione che include il benessere futuro. Puoi rafforzare legami e progetti con solidità e lungimiranza.
- 2:
- 3:

### capovolta

- 1: Stai vivendo un momento di instabilità che mette in discussione le tue radici e i tuoi valori. Le fondamenta della tua vita sono sotto esame e necessitano di attenzione profonda.
- 2:
- 3:

## Fante di Denari

### dritta

- 1: Stai mettendo in pratica un'idea che richiede la tua attenzione e dedizione. Questo è il momento di concretizzare i tuoi sogni pratici con passi studiati e mirati.
- 2:
- 3:

### capovolta

- 1: Un'iniziativa è ferma a metà, bloccata da una mancanza di attenzione iniziale. Puoi riprendere in mano la situazione, procedendo con calma e metodo.
- 2:
- 3:

## Cavaliere di Denari

### dritta

- 1: Avanzi con passo fermo e paziente, senza fretta, verso un obiettivo che persegui con dedizione. La tua forza risiede nella costanza, non nella velocità.
- 2:
- 3:

### capovolta

- 1: Il passo è bloccato, l'eccessiva prudenza ti frena dal prendere iniziative. Superare l'immobilità e agire è necessario per sbloccare la situazione.
- 2:
- 3:

## Regina di Denari

### dritta

- 1: Stai vivendo un momento in cui la tua capacità di accogliere e la tua praticità sono fondamentali. Trovi equilibrio tra affetto e gestione delle questioni quotidiane, facendo fiorire il tuo mondo con impegno e dedizione.
- 2:
- 3:

### capovolta

- 1: Senti uno squilibrio tra quanto dai e quanto ricevi. Ti scordi di te e la tua generosità rischia di portarti via tutte le risorse.
- 2:
- 3:

## Re di Denari

### dritta

- 1: La tua capacità di gestire le risorse con abbondanza e misura ti pone in una posizione di successo concreto. Sai condividere ciò che hai creato.
- 2:
- 3:

### capovolta

- 1: Un possesso ti sta irrigidendo, impedendoti di agire con libertà. La ricchezza che hai rischia di non circolare, ostacolando il tuo movimento.
- 2:
- 3:

## Asso di Spade

### dritta

- 1: Questo è il momento di fare chiarezza e di esprimere la tua verità con decisione. Hai un'idea netta e sai distinguere tra ciò che è reale e ciò che non lo è.
- 2:
- 3:

### capovolta

- 1: Le tue idee sono confuse e rischi di comunicare in modo inefficace, ferendo chi ti ascolta o complicando la situazione. È il momento di riflettere bene prima di esprimere i tuoi pensieri o di prendere una posizione.
- 2:
- 3:

## Due di Spade

### dritta

- 1: Eviti di prendere una posizione netta, mantenendo una condizione di equilibrio instabile. Evitare di affrontare la situazione per intero rischia di frenarti.
- 2:
- 3:

### capovolta

- 1: Il blocco che ti ha impedito di muoverti si sta sciogliendo e una scelta rimandata ora ti chiede attenzione. Puoi vedere chiaramente ciò che prima tenevi nascosto.
- 2:
- 3:

## Tre di Spade

### dritta

- 1: Provi una sofferenza che ti trapassa, una delusione che ti ha ferito profondamente. Riconosci questo stato d'animo, accoglilo, è il primo passo per andare oltre.
- 2:
- 3:

### capovolta

- 1: Stai vivendo un momento di perdono e ripresa, la tempesta è passata e il tuo cuore si sta alleggerendo. Ti stai concedendo il tempo di riprenderti e di respirare di nuovo.
- 2:
- 3:

## Quattro di Spade

### dritta

- 1: Sospendi ogni azione e ti ritiri in un periodo di riflessione, un momento di quiete per ascoltare la tua mente. Questa pausa non è un'interruzione, ma un modo per ricostruire la tua forza interiore.
- 2:
- 3:

### capovolta

- 1: È il momento di risvegliarti e riprendere le tue attività con una nuova consapevolezza. Agisci con calma, senza fretta, per consolidare i benefici della tua recente quiete.
- 2:
- 3:

## Cinque di Spade

### dritta

- 1: Stai vivendo una situazione in cui senti l'orgoglio prevalere, rischiando di perseguire un successo che potrebbe rivelarsi più dannoso che gratificante. È il momento di valutare con attenzione se ciò che desideri ottenere vale davvero ciò che potresti sacrificare.
- 2:
- 3:

### capovolta

- 1: Senti il desiderio di superare le ostilità e di riallacciare i legami, anche se ciò richiede un passo indietro. Stai valutando l'importanza della comprensione reciproca per ritrovare la serenità.
- 2:
- 3:

## Sei di Spade

### dritta

- 1: Stai attraversando una fase di transizione, allontanandoti da ciò che ha causato inquietudine. Il viaggio verso una maggiore serenità è in corso e ti conduce verso acque più calme.
- 2:
- 3:

### capovolta

- 1: Fatichi a compiere il passo decisivo per allontanarti da ciò che ti lega. Il tuo animo è combattuto, senti la necessità di andare avanti ma il cuore non è ancora pronto.
- 2:
- 3:

## Sette di Spade

### dritta

- 1: Ti senti in una fase dove usare l'ingegno è necessario, ma devi fare attenzione a non scivolare nell'inganno. Stai navigando con furbizia, ponderando ogni passo con cautela.
- 2:
- 3:

### capovolta

- 1: Stai affrontando le conseguenze di un inganno, tuo o di altri, che sta emergendo. È il momento di riportare la verità e liberare la tua coscienza.
- 2:
- 3:

## Otto di Spade

### dritta

- 1: Percepisci di non avere margini di azione, ma questa sensazione deriva più dai tuoi pensieri che da reali impedimenti.
- 2:
- 3:

### capovolta

- 1: Stai scoprendo che le limitazioni che percepivi non sono reali come credevi e questo ti permette di agire con maggiore libertà. Questo momento ti offre l'opportunità di muoverti oltre le barriere che prima ti sembravano insormontabili.
- 2:
- 3:

## Nove di Spade

### dritta

- 1: Senti la mente ingigantire ogni preoccupazione e questo ti impedisce di riposare. I tuoi pensieri creano scenari che non corrispondono alla realtà, fatichi a distinguerli.
- 2:
- 3:

### capovolta

- 1: Il peggio dell'angoscia sta finendo: trovi il coraggio di affrontare le tue apprensioni. Ti liberi gradualmente da pensieri negativi che ti limitavano.
- 2:
- 3:

## Dieci di Spade

### dritta

- 1: Stai vivendo la conclusione di un ciclo molto impegnativo, toccando il punto più basso. Questa chiusura libera lo spazio per ripartire.
- 2:
- 3:

### capovolta

- 1: Senti che il peggio è ormai alle spalle e stai ritrovando un sollievo che ti permette di riprendere le forze con calma.
- 2:
- 3:

## Fante di Spade

### dritta

- 1: La tua mente è acuta e ti porta a osservare con vigilanza ogni dettaglio. Stai cercando di capire a fondo una situazione, ma è importante che tu scelga con cura le tue espressioni per evitare incomprensioni.
- 2:
- 3:

### capovolta

- 1: Affronti le conseguenze di una comunicazione poco ponderata. Le tue affermazioni generano pettegolezzi o malintesi, impedendoti di esprimerti con chiarezza e autenticità.
- 2:
- 3:

## Cavaliere di Spade

### dritta

- 1: La tua rapidità mentale ti porta a prendere decisioni immediate, ma ricorda che la fretta può farti perdere la visione d'insieme. La prontezza d'azione è utile, ma richiede equilibrio per non travolgere.
- 2:
- 3:

### capovolta

- 1: La tendenza a reagire con fretta ti porta a esprimere pensieri pungenti o a compiere azioni sconsiderate. Rallentare ti permette di valutare meglio la situazione e le sue conseguenze.
- 2:
- 3:

## Regina di Spade

### dritta

- 1: La tua intelligenza e la tua onestà ti guidano a stabilire confini precisi. Pensi in modo nitido e la tua chiarezza di espressione ti protegge.
- 2:
- 3:

### capovolta

- 1: Stai vivendo le conseguenze di una durezza che hai costruito intorno a te, un isolamento che ti impedisce di agire pienamente. Ammorbidire il tuo giudizio, a cominciare da quello verso di te, è essenziale per superare questo momento.
- 2:
- 3:

## Re di Spade

### dritta

- 1: Metti la tua mente al servizio del bene, usando la ragione per raggiungere l'equità in ogni situazione. Sei un punto di riferimento per chi cerca chiarezza e giustizia.
- 2:
- 3:

### capovolta

- 1: La tua tendenza è di usare un'autorità dura che non tiene conto dei sentimenti. Questo rischia di compromettere i legami importanti e ti porta a vincere discussioni ma perdere affetto.
- 2:
- 3:
