# LA POSIZIONE: PRESENTE

Il presente della stesa a tre carte.

**Fonte da riempire.** Per ogni carta e per ogni verso tre varianti dello
stesso scheletro, `- 1:`, `- 2:`, `- 3:`, scritte da Code dall'ordine FM del 12 ottobre 2026
(prima dall'Architetto, ordine FI, aggiunta A1 e A4), seguendo
`schedario_presente.md`. Una riga vuota e' un testo che non c'e' ancora. Una
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
- 2: Hai il piede già oltre la soglia e la bisaccia leggera sulla spalla: in questi giorni ti muovi verso qualcosa che non vedi per intero, col passo di chi si fida del primo metro di strada.
- 3: Adesso il tuo bagaglio pesa poco perché hai lasciato a terra il superfluo; davanti c'è il vuoto del non saputo e tu ci cammini incontro col cuore aperto, senza mappa in tasca.

### capovolta

- 1: Senti l'impulso di agire in modo sconsiderato o, al contrario, un blocco ti frena dal fare un passo importante. È il momento di capire se la tua spinta è coraggio o una fuga da qualcosa che non hai voluto vedere.
- 2: Sull'orlo del dirupo il tuo piede oscilla: oggi una spinta ti porta avanti senza rotta, oppure una paura ti inchioda al bordo proprio mentre vorresti saltare: non sai quale delle due ti muove.
- 3: Corri in queste ore dietro a un impulso di cui non conosci l'origine, o non muovi un passo dall'ultimo sasso prima del vuoto; in entrambi i casi eviti di guardare da che cosa nasce lo slancio.

## Il Mago

### dritta

- 1: Senti il potere di creare, hai tra le mani tutti gli strumenti e la volontà per usarli. Il momento chiede di manifestare ciò che finora era solo idea.
- 2: Sul tuo banco adesso c'è tutto: la bacchetta, la coppa, la lama e la moneta stanno a portata di mano; l'idea che coltivavi passa già nelle dita e diventa gesto, parola detta, passo fatto.
- 3: Con un braccio verso l'alto e l'altro verso terra, in questo momento fai da tramite: ciò che pensi prende corpo appena lo tocchi, perché la volontà e i mezzi ti stanno finalmente nelle stesse mani.

### capovolta

- 1: Non stai mettendo a frutto le tue doti, oppure le tue intenzioni non si traducono in azioni concrete. C'è uno scollamento tra il dire e il fare che ti impedisce di realizzare i tuoi obiettivi.
- 2: In questi giorni un dono tuo resta nel cassetto, oppure le tue parole corrono più avanti delle mani: prometti un gesto che il banco apparecchiato davanti a te non vede ancora compiere.
- 3: Gli attrezzi sono tutti lì, intatti, eppure oggi nessuno porta il segno del tuo uso; dici molto di ciò che faresti mentre l'intenzione si ferma un passo prima di diventare azione.

## La Papessa

### dritta

- 1: Ti affidi al tuo sapere silenzioso, quello che non ha bisogno di spiegazioni. Accogli un mistero che si rivela solo alla mente quieta, senza fretta di decidere.
- 2: Dentro di te in questi giorni c'è un sapere che non passa dalle parole: lo senti con chiarezza eppure non riesci a spiegarlo, come un rotolo tenuto socchiuso in grembo dietro un velo.
- 3: Abiti adesso il silenzio come una stanza tua: la mente quieta sente ciò che il rumore copriva, così ascolti l'intuito prima ancora di dare un nome a quello che sai.

### capovolta

- 1: Stai attivamente mettendo a tacere un sapere che viene da dentro, forse per paura di ciò che ti rivelerebbe. Questa chiusura rischia di impedirti di riconoscere una conoscenza fondamentale, se solo ti concedessi di accoglierla.
- 2: Riempi le giornate di ragionamenti e di rumore per non sentire una cosa che dentro sai già; il velo fra le colonne resta tirato perché, se ti fermassi ad ascoltare, quella conoscenza parlerebbe chiaro.
- 3: Una parte di te sa e tu le parli sopra: oggi la logica fa da coperchio all'intuito, forse per timore di ciò che sentiresti in silenzio, così il rotolo resta chiuso sulle tue ginocchia.

## L'Imperatrice

### dritta

- 1: Sei al centro di un processo creativo dove la tua energia generatrice permette a qualcosa di nuovo di svilupparsi in modo naturale e abbondante.
- 2: Tra le tue mani qualcosa di vivo sta crescendo, un progetto, un legame o un'idea, mentre tu lo nutri con pazienza come si cura un campo di grano, senza tirare gli steli per farli salire.
- 3: Intorno a te in questa stagione tutto germoglia: la tua cura è il terreno grasso su cui ciò che ami prende forma coi suoi tempi lenti, mentre tu lasci che sbocci invece di affrettarlo.

### capovolta

- 1: La tua energia creativa è bloccata e non stai nutrendo la tua radice. Ti senti distante da ciò che ti fa fiorire dentro.
- 2: Ciò che vuoi far nascere oggi non prende forma: il terreno è fertile eppure il seme resta fermo, oppure lo spingi fuori prima che sia pronto e lo vedi arrestarsi a metà della crescita.
- 3: Adesso la tua creatività sta come un giardino d'inverno: la vita c'è sotto la terra ma non germoglia, perché la stai forzando oppure hai smesso di nutrire ciò che volevi far fiorire.

## L'Imperatore

### dritta

- 1: Definisci regole chiare e ti muovi con fermezza per sostenere le tue scelte. Stai consolidando e dando struttura a quanto vivi, assumendoti le tue responsabilità.
- 2: Sul trono di pietra tieni lo scettro con mano ferma: in queste settimane stai dando ordine e regole a ciò che costruisci, sostieni la struttura e ti prendi la responsabilità di comandare.
- 3: Oggi sei tu a porre i confini e le leggi: la tua situazione ha preso la forma di un edificio con le sue mura, dove la disciplina che eserciti fa da cornice e tiene in piedi ciò che cresce.

### capovolta

- 1: La mancanza di basi solide o un sistema troppo rigido ti impediscono di avanzare, creando incertezza. Cerchi stabilità, ma trovi solo vincoli che ti bloccano.
- 2: In questo momento l'ordine ti toglie il respiro oppure manca del tutto: o tieni le redini così strette da soffocare ciò che governi, o le fondamenta sotto i tuoi piedi cedono e ogni cosa vacilla.
- 3: Regole troppo rigide o nessuna regola: oggi la tua situazione oscilla fra questi due estremi, con uno scettro che comanda senza ascoltare o con un trono vuoto che non sostiene ciò che costruisci.

## Il Papa

### dritta

- 1: Ti confronti con la necessità di integrare gli insegnamenti ricevuti, di farli tuoi per costruire la tua saggezza. Puoi diventare una fonte di ispirazione, consolidando la tua sapienza interiore.
- 2: Adesso cammini dentro una tradizione: un maestro, una scuola o un rito condiviso ti tengono per mano e ti offrono parole che vengono da lontano, mentre tu ascolti per capire da dove arrivano.
- 3: Davanti a te c'è chi insegna e tu stai fra coloro che ricevono la benedizione: in questi giorni impari da una sapienza più grande di te, dentro una comunità che ti dà senso e appartenenza.

### capovolta

- 1: Senti che un sapere ricevuto non è più adeguato. Questo ti spinge a rivedere le tue regole e a cercare un senso che ti faccia respirare.
- 2: Una regola che ti hanno consegnato oggi ti stringe come un abito vecchio: ripeti formule e doveri che non riconosci più come tuoi e cerchi il tuo senso fuori dal sentiero già tracciato.
- 3: In questo momento la dottrina ricevuta e la tua coscienza parlano lingue diverse: ascolti il maestro mentre qualcosa in te dice di no, perché respiri meglio lontano dal recinto delle convenzioni.

## Gli Amanti

### dritta

- 1: Senti la necessità di fare una scelta che coinvolge i tuoi valori profondi, integrando la ragione e il sentimento per allinearti a ciò che sei.
- 2: Sotto lo sguardo dell'angelo stai davanti a un bivio vero: la scelta che hai in mano tocca i tuoi valori e non solo il desiderio del momento, così testa e cuore devono dirsi d'accordo.
- 3: Oggi hai due strade davanti e un amore in mezzo: ciò che scegli dice chi sei, perciò stai pesando il sentimento accanto ai principi che ti stanno a cuore, cercando un sì detto da tutto il tuo essere.

### capovolta

- 1: Stai vivendo un conflitto interiore che ti impedisce di fare una scelta sincera. I tuoi valori attuali sono in contrasto e ti rendono difficile trovare un equilibrio.
- 2: Dentro di te in questi giorni ciò in cui credi e ciò che desideri si contraddicono: finché uno dei due resta zitto l'altro non ti convince, così la scelta pende fra due fedeltà che sono entrambe tue.
- 3: Il disaccordo che vivi adesso non viene da fuori: un tuo valore e un tuo desiderio tirano in direzioni diverse, quindi prima ancora di accordarti con l'altro devi metterti d'accordo con te.

## Il Carro

### dritta

- 1: Prendi saldamente le redini della tua vita, armonizzando spinte opposte. Hai la forza e la direzione per avanzare con decisione.
- 2: Sul tuo carro adesso tieni ferme le redini mentre due forze opposte, una chiara e una scura, avanzano insieme: la direzione è tua e la padronanza con cui guidi tiene unito ciò che tirerebbe da parti diverse.
- 3: In questa fase avanzi: lo sguardo è fisso davanti, le spinte contrarie lavorano per te sotto la tua mano e la corsa che stai facendo nasce dalla volontà, non dalla fortuna del momento.

### capovolta

- 1: Senti una notevole dispersione delle energie, come se forze contrastanti tirassero in direzioni diverse. Hai difficoltà a mantenere una rotta definita e rischi di procedere senza una chiara meta.
- 2: Le due sfingi davanti al tuo carro oggi tirano ciascuna per conto suo: sbandi da un lato all'altro, oppure corri a gran velocità senza sapere bene verso dove, con le redini lente fra le dita.
- 3: In questo momento la tua corsa ha perso il centro: le energie si disperdono in versi opposti, la meta non è chiara e il movimento che fai somiglia più a uno sbandare che a un avanzare.

## La Giustizia

### dritta

- 1: È tempo di verità e di scelte: senti il bisogno di prendere una posizione chiara, senza scorciatoie o giustificazioni.
- 2: Davanti a te la bilancia è alzata e la spada dritta: in questi giorni stai pesando con lucidità ciò che hai seminato, senza sconti né colpe inutili, per prendere la posizione che ti sembra giusta.
- 3: Adesso ogni causa mostra il suo effetto sul tuo tavolo: guardi i fatti per quello che sono, ti assumi la parte che ti spetta e scegli secondo onestà, con l'equilibrio di chi misura prima di agire.

### capovolta

- 1: Il tuo equilibrio dipende dal riconoscimento di una verità che stai ignorando. Fino a quando non la guardi in faccia, non puoi trovare serenità.
- 2: Un conto resta aperto a tuo nome e oggi lo attribuisci agli altri o al caso: la conseguenza di una tua scelta sta lì sul piatto della bilancia, ma tu guardi altrove e l'equilibrio non torna.
- 3: In questo momento la bilancia pende e tu fai finta di non vederlo: una responsabilità che è tua aspetta che tu la riconosca, mentre cerchi fuori di te la ragione di uno squilibrio che porti dentro.

## L'Eremita

### dritta

- 1: Senti il bisogno di isolarti per trovare la tua direzione. La tua ricerca interiore ti guida un passo alla volta verso una verità personale.
- 2: Con la lanterna alzata stai salendo un sentiero in disparte: in questi giorni ti ritiri dal rumore, rallenti e cerchi dentro ciò che fuori non trovi, vedendo un passo alla volta.
- 3: Adesso la tua solitudine è una scelta che illumina: ti allontani dalla folla per ascoltarti, la piccola luce che porti basta a mostrarti il prossimo passo e tanto ti è sufficiente.

### capovolta

- 1: Il tuo ritiro rischia di isolarti. La tua ricerca di chiarezza, che dovrebbe guidarti, ti sta portando lontano dagli altri invece di mostrarti la strada per ricongiungerti.
- 2: In questi giorni la lanterna che dovrebbe guidarti ti tiene a distanza dagli altri: la ricerca si è fatta chiusura, ti nascondi dietro il ritiro e il silenzio ti pesa invece di chiarirti.
- 3: Oggi la cima che hai scelto per pensare è diventata un rifugio da cui non scendi: raccogliersi e nascondersi si confondono, così la solitudine non illumina più e ti separa da chi ti cerca.

## La Ruota della Fortuna

### dritta

- 1: Il destino sta girando e ti porta verso una svolta inaspettata; è un'occasione per accogliere il nuovo senza aggrapparti a ciò che conosci. Muovi i tuoi passi con il flusso degli eventi.
- 2: Sotto i tuoi piedi la ruota sta girando: in questo periodo qualcosa cambia giro, spesso dove non guardavi, mentre tu impari a muoverti col movimento invece di aggrapparti a com'era prima.
- 3: Adesso ti trovi dentro una svolta: la situazione che vivi gira come un ciclo che non resta fermo, ciò che era in alto scende e ciò che era in basso sale, mentre tu cerchi di assecondare il giro.

### capovolta

- 1: Senti che un ciclo vitale è bloccato e non riesci a trovare il modo di farlo ripartire. La situazione attuale ti sembra sfuggire di mano e ti senti senza controllo.
- 2: La ruota in questo momento sembra inceppata oppure gira storta: non hai presa su ciò che cambia, ogni tuo sforzo pare scivolare sul cerchio e il ciclo che vivi resta fermo in un punto scomodo.
- 3: Oggi stai nella parte del giro che non ti piace: il movimento si è bloccato o va contro di te, così ti sembra che le cose girino per conto loro mentre tu raccogli le forze in attesa.

## La Forza

### dritta

- 1: Senti la necessità di un approccio delicato per addomesticare le situazioni difficili, usando la pazienza e la persuasione anziché lo scontro diretto per raggiungere i tuoi obiettivi.
- 2: Con la mano posata sulla bocca del leone, in questi giorni tieni a bada ciò che ti agita senza lottare: la calma e la fermezza tenera sono il modo in cui governi l'istinto, non lo strappo né il grido.
- 3: Adesso dentro di te c'è una belva che scalpita e tu la addomestichi con dolcezza: il coraggio che metti in campo è paziente, ti permette di stare in mezzo al difficile senza alzare le mani.

### capovolta

- 1: Ti stai trattando con eccessiva durezza, criticandoti aspramente e mettendo in discussione la tua tenuta e il tuo valore.
- 2: In questo periodo la mano che dovrebbe accarezzare il leone stringe: dubiti della tua tenuta, oppure tratti i tuoi istinti e le tue fragilità con una severità che li rende ancora più selvatici.
- 3: Oggi il tuo coraggio ha perso la mitezza: con te usi la frusta invece della carezza, così la belva interiore che vorresti calmare si agita di più e ti sembra di aver perso il controllo.

## L'Appeso

### dritta

- 1: Senti il bisogno di mettere in pausa ogni azione, di attendere. Questa sosta ti porta a una comprensione profonda che ti rivela nuove visioni sulla situazione.
- 2: Con la testa in giù e un piede legato al ramo vivo, in questi giorni hai sospeso ogni azione: la pausa che vivi ti obbliga a guardare le cose da un'angolazione che prima ti sfuggiva.
- 3: Adesso non agisci e non è pigrizia: hai lasciato andare il bisogno di fare, accetti la sospensione come un modo di vedere e intorno al tuo capo l'attesa accende una luce nuova.

### capovolta

- 1: Senti che la tua attesa non sta producendo alcun risultato, ti trovi in uno stallo. Il sacrificio che stai affrontando non porta beneficio a nessuno e non ti permette di agire.
- 2: La tua attesa oggi sa di stallo: non insegna più niente, eppure continui a sacrificare tempo e desideri a una sosta che non serve a nessuno, nemmeno a te.
- 3: In questo momento ti imponi una rinuncia che ha l'aria di una virtù e somiglia invece alla paura: il ramo da cui pendi ti tiene immobile mentre potresti cambiare sguardo o scendere a terra.

## La Morte

### dritta

- 1: Senti che è il momento di un cambiamento profondo, una trasformazione che ti invita a liberarti di ciò che non ti serve più per evolvere.
- 2: Qualcosa nella tua vita si sta chiudendo adesso: la falce passa su ciò che ha esaurito il suo tempo, un ruolo, un legame o un'abitudine, mentre tu senti lo spazio vuoto che lascia dietro di sé.
- 3: In questi giorni attraversi una fine vera: il cavaliere nero avanza e ciò che conoscevi cade come foglie in autunno, perché la trasformazione che stai vivendo chiede di lasciare andare un ciclo intero.

### capovolta

- 1: Il tuo aggrapparti a ciò che non c'è più ti impedisce di avanzare, prolungando una sofferenza inutile e impedendoti di procedere oltre.
- 2: Stringi fra le dita qualcosa che sta già finendo: oggi resisti a un cambiamento arrivato da tempo e il trattenere ti fa più male del lasciare, come chi tiene chiusa una porta contro il vento.
- 3: Adesso la fine c'è già stata, ma tu non la riconosci: ti aggrappi a un ruolo o a un legame esaurito, così la trasformazione che preme resta ferma alle tue spalle senza poter passare.

## La Temperanza

### dritta

- 1: Stai unendo con maestria elementi che sembravano incompatibili, dosando ogni cosa con calma e misura per raggiungere un punto di equilibrio stabile.
- 2: Versi l'acqua da una coppa all'altra con pazienza: in questi giorni stai mescolando due parti della tua vita che sembravano inconciliabili, dosando con calma finché trovano il loro accordo.
- 3: Adesso il tuo passo è misurato: un piede nell'acqua e uno sulla terra, tieni insieme gli opposti senza fretta e la giusta proporzione che cerchi nasce da piccoli aggiustamenti quotidiani.

### capovolta

- 1: Stai vivendo una disconnessione tra diverse parti di te, come se non riuscissero a comunicare in armonia. Senti una tendenza a non trovare un centro.
- 2: Oggi le due coppe non si passano più l'acqua: c'è troppo da una parte e niente dall'altra, la fretta ti spinge agli eccessi e due parti di te non riescono più a parlarsi.
- 3: In questo periodo il dosaggio è saltato: aggiungi, togli, corri, poi ti blocchi, così il ritmo che ti teneva in equilibrio si è spezzato e ogni gesto ti sembra fuori misura.

## Il Diavolo

### dritta

- 1: Senti il peso di attaccamenti che limitano le tue scelte, un'ombra ti sfida a riconoscerla. Adesso è il momento di affrontare questa verità per sciogliere i nodi.
- 2: Una catena ti gira intorno al collo in questo periodo: un attaccamento, un'abitudine o un desiderio ti tengono più di quanto ammetti, eppure il collare è largo abbastanza da sfilarlo.
- 3: Adesso un'ombra comanda nel buio della tua situazione: un legame che ti trattiene e che non hai ancora nominato, come una dipendenza che ti piace e ti stringe nello stesso istante.

### capovolta

- 1: Stai scoprendo un vincolo che ti teneva con il suo potere, ora lo vedi chiaramente. Questa consapevolezza ti permette di agire e di sciogliere ciò che ti imprigionava, recuperando la tua libertà.
- 2: Ti accorgi in questi giorni della catena che portavi al collo: un desiderio o una dipendenza che ti teneva al buio adesso ha un nome, così il nodo che ti stringeva comincia ad allentarsi.
- 3: Ora vedi l'attaccamento per quello che è: la tentazione che ti comandava ha perso il suo fascino oscuro, la catena è ancora lì ma la stai sfilando con le tue mani, con dolcezza.

## La Torre

### dritta

- 1: Stai vivendo il momento in cui le strutture fragili crollano, rivelando ciò che è autentico. Questo ti permette di ricostruire su fondamenta più vere e resistenti.
- 2: Un fulmine colpisce in questi giorni ciò che avevi costruito sul falso: le mura cadono all'improvviso sotto i tuoi occhi, fa male, eppure resta in piedi soltanto ciò che è vero.
- 3: Adesso tutto trema: una certezza che credevi solida si spacca senza preavviso, le pietre volano e tu guardi crollare l'illusione mentre sotto le macerie affiora la parte su cui puoi contare.

### capovolta

- 1: Stai ancora tentando di scongiurare una trasformazione, forse per il timore di ciò che ne può conseguire. Ciò che ritieni stabile può rivelarsi precario e non affrontare il problema può aumentare la tensione.
- 2: Sotto la tua mano il muro è crepato e tu lo puntelli: oggi rimandi una scossa necessaria, oppure stai uscendo a fatica da un crollo, con la polvere ancora nell'aria.
- 3: In questo periodo l'edificio vacilla ma regge in apparenza: senti il fulmine nell'aria e cerchi di evitarlo, tenendo in piedi a forza qualcosa di falso che chiede soltanto di cadere.

## La Stella

### dritta

- 1: Senti che il peggio è ormai alle spalle e ti stai affidando a una guida interiore che ti rassicura. Sei su una strada che porta a un benessere più profondo e duraturo.
- 2: Dopo la tempesta una luce dolce ti raggiunge: in questi giorni versi acqua sulla terra e nel fiume senza più difese, mentre la fiducia ti torna piano come un respiro.
- 3: Adesso il cielo sopra di te si è rischiarato: la speranza che senti è quieta e non urla, ti dice che il peggio è passato anche se la fatica ti resta addosso.

### capovolta

- 1: Senti che l'ispirazione e la speranza ti abbandonano, rendendo difficile credere in un miglioramento. Sei in una fase in cui la motivazione è scarsa e fatichi a trovare un senso di direzione.
- 2: In questo momento la luce che ti guidava è velata da una nube: la fiducia è stanca, fatichi a credere che le cose possano migliorare, eppure quella luce non si è spenta, sta solo dietro il cielo grigio.
- 3: Oggi l'acqua delle tue brocche cade sulla pietra invece che nel fiume: l'ispirazione sembra lontana e la speranza si è assottigliata, come un cielo notturno senza astri visibili.

## La Luna

### dritta

- 1: Senti che qualcosa non ti è pienamente rivelato, le percezioni sono confuse e le tue paure interiori possono rendere sfocato ciò che ti circonda. Hai bisogno di pazienza per capire.
- 2: Cammini adesso su un sentiero rischiarato a metà: fra il cane e il lupo che ululano, le cose non sono come sembrano, le paure notturne parlano e tu procedi a tentoni fidandoti dell'intuito.
- 3: In questi giorni la penombra avvolge la tua situazione: ciò che vedi può ingannarti, dal fondo dell'acqua salgono timori antichi e ogni certezza ti scivola via, come riflessi sullo stagno.

### capovolta

- 1: Una confusione che ti avvolgeva si sta chiarendo, le paure perdono il loro peso. Stai uscendo dalla nebbia, vedi con maggiore lucidità ciò che prima ti turbava.
- 2: La nebbia si sta alzando proprio adesso: ciò che al buio ti sembrava enorme mostra contorni più piccoli e le ombre che ti spaventavano rivelano di essere fatte più d'ombra che di sostanza.
- 3: Oggi distingui di nuovo il sentiero dalla palude: gli inganni della notte perdono presa, le illusioni si sciolgono e torni a riconoscere ciò che è reale fra i riflessi che ti confondevano.

## Il Sole

### dritta

- 1: Questo è un momento di pieno successo, dove ogni cosa fiorisce e il tuo cuore è colmo di allegria. La tua presenza illumina l'ambiente circostante e le persone si sentono bene con te.
- 2: Una luce piena cade adesso sulla tua situazione: le cose riescono, non restano zone d'ombra e il cuore ti ride senza bisogno di nascondersi, come un bambino a cavallo sotto un cielo aperto.
- 3: In questi giorni tutto è chiaro e caldo: ciò che fai si vede, ciò che sei si mostra senza paura e la gioia che provi è semplice, allo scoperto, sotto gli occhi di chiunque ti stia vicino.

### capovolta

- 1: Senti che l'entusiasmo è trattenuto e la luce non ti raggiunge pienamente. C'è qualcosa che ostacola la tua gioia di manifestarsi con chiarezza, un impedimento che ti frena dal brillare.
- 2: Oggi la luce c'è ma la senti poco sulla pelle: qualcosa copre la tua gioia, spesso un pensiero vecchio, così l'entusiasmo resta trattenuto come un giorno d'estate dietro una nube.
- 3: In questo momento la riuscita è vicina eppure non ti scalda: sorridi a metà, la contentezza ti resta in gola e il calore che pure ti circonda non arriva fino al cuore.

## Il Giudizio

### dritta

- 1: Senti forte l'esigenza di dare una svolta decisiva alla tua esistenza, riconsiderando ciò che conta davvero per te. Questo è il momento di ascoltare quella parte di te che ti chiede di evolvere e di abbracciare un nuovo modo di essere.
- 2: Una tromba suona per te in questi giorni: ti stai svegliando a una vita più vera, fai il bilancio di ciò che hai vissuto e ti alzi per rispondere alla chiamata.
- 3: Adesso è tempo di rendiconto: ti guardi indietro con onestà, ascolti un richiamo che ti chiede di lasciare la persona che eri e senti già in te quella che stai diventando.

### capovolta

- 1: Ti critichi con eccessiva severità, una durezza che non ti permette di perdonare e avanzare. Ascolta le tue esigenze con comprensione, prima di condannare il tuo agire.
- 2: In questo periodo rimandi un bilancio che senti necessario: la tromba suona e tu ti copri le orecchie, oppure ti condanni con una durezza che non lascia spazio a nessuna rinascita.
- 3: Oggi davanti alla tua coscienza manca il perdono: ti processi per ciò che è stato invece di ascoltarlo, così la chiamata al risveglio si perde sotto il peso della condanna.

## Il Mondo

### dritta

- 1: Sperimenti un momento di pienezza, un traguardo significativo che porta armonia. La tua integrazione è massima, ogni cosa è al proprio posto.
- 2: Un cerchio si chiude adesso: ciò che hai attraversato trova il suo compimento e ogni pezzo è al suo posto, come una danza dentro una ghirlanda d'alloro che si completa proprio intorno a te.
- 3: In questi giorni tocchi il traguardo: il ciclo che hai percorso è intero, lo senti parte di te e puoi goderne la pienezza prima di aprire qualunque altra porta.

### capovolta

- 1: Ti avvicini alla conclusione di una fase importante e percepisci che un dettaglio è ancora da definire per una piena realizzazione. Questa prossimità tende a generare una sorta di esitazione finale.
- 2: Il traguardo ti sta a un passo e non l'hai ancora toccato: oggi manca un ultimo pezzo da integrare, un dettaglio da sciogliere, mentre la ghirlanda resta aperta proprio dove dovrebbe chiudersi.
- 3: Adesso stai nell'ultimo tratto e qualcosa ti trattiene: la pienezza è vicina, la vedi, ma esiti a completare il cerchio così il compimento resta sospeso a un soffio dalla fine.

## Asso di Bastoni

### dritta

- 1: Senti un'energia prorompente che ti invita all'azione, un'ispirazione ardente che ti attraversa e ti spinge a dare il via a qualcosa di nuovo. È il momento di cogliere l'attimo e di non rimandare le tue iniziative.
- 2: Un ramo verde germoglia adesso nella tua mano: un'ispirazione ardente ti attraversa e la voglia di cominciare è così viva che senti la fiamma prima ancora di sapere dove la porterai.
- 3: In questi giorni una scintilla si è accesa: l'idea nuova ti scalda le mani, ti chiede di partire finché il fuoco è vivo e di non lasciarlo raffreddare nei ripensamenti.

### capovolta

- 1: Il tuo slancio iniziale è bloccato, una forza interna o esterna soffoca l'entusiasmo. Non ti manca il desiderio di agire, ma il fuoco stenta a divampare.
- 2: Stringi un ramo che dovrebbe germogliare e resta secco: oggi una partenza viene rimandata ancora, il desiderio c'è ma la paura di sbagliare soffoca la scintilla prima che prenda.
- 3: Adesso il fuoco del primo gesto non riesce ad accendersi: ogni volta che stai per cominciare qualcosa lo spegne, così l'avvio che aspetti resta un fiammifero in mano mai sfregato.

## Due di Bastoni

### dritta

- 1: Senti il bisogno di pianificare con attenzione, scegliendo la strada migliore per il tuo progetto. Hai la possibilità di definire il cammino, è il momento di decidere con visione.
- 2: Dall'alto delle mura guardi lontano con un piccolo globo in mano: in questi giorni il tuo progetto prende forma e stai decidendo quale rotta seguire, oltre il confine di ciò che conosci.
- 3: Adesso tieni fra le dita la mappa delle possibilità: pianifichi con ambizione, pesi le direzioni e ti prepari a lasciare il castello sicuro per una strada più larga.

### capovolta

- 1: Senti la paura di procedere e non ti muovi, perché non hai ancora chiarezza su cosa vuoi davvero. Questa esitazione ti impedisce di prendere una direzione definita e ti tiene in stallo.
- 2: Sulla soglia del castello oggi esiti: la direzione è ancora confusa, la paura di osare ti tiene dentro le mura e il globo che hai in mano non ti indica nessuna strada.
- 3: In questo periodo non sai bene che cosa vuoi e questo ti impedisce di partire: guardi oltre il parapetto, immagini viaggi, poi resti dietro le pietre a rimuginare.

## Tre di Bastoni

### dritta

- 1: Stai attendendo con fiducia che i tuoi sforzi portino i frutti desiderati. Le azioni intraprese in passato cominciano a manifestarsi e ti prepari ad accogliere ciò che sta arrivando.
- 2: Sul promontorio guardi il mare dove le tue navi sono partite: in questi giorni ciò che hai avviato è in viaggio e tu, appoggiandoti al bastone, segui con lo sguardo l'espansione che hai messo in moto.
- 3: Adesso il seminato è fatto e il tempo dell'attesa è cominciato: osservi l'orizzonte con fiducia, mentre le iniziative che hai lanciato lontano proseguono la loro rotta sul mare.

### capovolta

- 1: Stai affrontando dei ritardi che ti mettono alla prova, o le tue previsioni non si stanno concretizzando come speravi. È un momento per valutare se attendere ancora o cambiare strategia.
- 2: Le navi che avevi mandato lontano rientrano oggi con un carico diverso da quello atteso: guardi dal promontorio ciò che arriva davvero e lo confronti con ciò che avevi immaginato.
- 3: In questo momento le tue aspettative non combaciano con ciò che torna a riva: rileggi i piani alla luce di quello che hai davanti, perché l'impresa ha preso una forma che non prevedevi.

## Quattro di Bastoni

### dritta

- 1: Stai vivendo un momento di stabilità, riconoscendo il valore di ciò che hai raggiunto. È un tempo per festeggiare le solide fondamenta che hai creato.
- 2: Sotto un arco di fiori e ghirlande in questi giorni festeggi: ciò che hai costruito regge, le fondamenta tengono e c'è gente intorno a te che alza le mani in segno di gioia.
- 3: Adesso è tempo di celebrare un traguardo raggiunto: la casa è in piedi, i pali sono saldi e ti concedi di riconoscere il bello che c'è, insieme a chi lo ha condiviso con te.

### capovolta

- 1: Senti che l'armonia è difficile da raggiungere, o che le tue fondamenta non sono ancora abbastanza salde. È un momento in cui la gioia piena ti sfugge perché le condizioni ideali non sono ancora presenti.
- 2: La festa oggi resta a metà: il traguardo che hai raggiunto non trova il momento di essere celebrato, come una casa nuova con le ghirlande appese in cui non hai ancora fatto ingresso.
- 3: In questo momento la gioia c'è ma si vive a mezzo: rimandi i festeggiamenti, oppure la celebrazione intorno a te ha qualcosa di incompleto che non ti lascia godere ciò che hai costruito.

## Cinque di Bastoni

### dritta

- 1: Una vivace competizione anima il tuo contesto attuale. Questa dinamica ti invita a confrontarti attivamente, mettendo in gioco le tue capacità per far valere le tue posizioni con determinazione.
- 2: Intorno a te in questi giorni i bastoni si incrociano: un confronto acceso di idee, una competizione vivace in cui ciascuno alza il suo legno mentre tu misuri la tua forza contro quella degli altri.
- 3: Adesso l'energia ribolle e si scontra: discuti, ti opponi, difendi il tuo punto in una mischia più rumorosa che cattiva, dove la sfida ti mette alla prova senza che nessuno voglia ferire.

### capovolta

- 1: Gestisci attriti che non meritano la tua energia. Scegli quali battaglie affrontare e lascia andare ciò che non contribuisce al tuo benessere.
- 2: Tensioni sottili attraversano oggi il tuo ambiente: invece di dire ciò che ti irrita lo lasci covare, oppure ti fai trascinare in piccole zuffe che consumano energia senza portare a niente.
- 3: In questo periodo i bastoni restano alzati ma nessuno colpisce davvero: eviti i confronti necessari mentre ti spendi in attriti inutili, così la tensione gira a vuoto e ti stanca.

## Sei di Bastoni

### dritta

- 1: Stai vivendo un momento di meritato successo e visibilità, senti l'onore per i risultati raggiunti. Accetta i complimenti e il plauso senza esagerare, ma anche senza sminuire il tuo valore.
- 2: A cavallo con la corona d'alloro, in questi giorni attraversi la folla che ti applaude: il successo che hai meritato è finalmente visibile e tu accogli l'onore senza montarti la testa.
- 3: Adesso gli altri vedono il tuo lavoro: il riconoscimento ti raggiunge in pubblico, intorno a te si alzano i bastoni in festa e tu lo ricevi con misura, sapendo quanto ti è costato.

### capovolta

- 1: Il tuo operato non riceve l'attenzione che merita e ciò ti spinge a sminuire le tue capacità. Questa situazione ti invita a riconoscere la tua importanza indipendentemente dall'approvazione altrui.
- 2: Oggi l'applauso tarda: aspetti un riconoscimento che non viene e intanto un dubbio su di te si insinua, come se il valore dipendesse soltanto da chi te lo conferma.
- 3: In questo momento la corona d'alloro sembra posata sulla testa di qualcun altro: il tuo merito passa inosservato e la mancanza di plauso ti fa dubitare di ciò che hai fatto.

## Sette di Bastoni

### dritta

- 1: Stai vivendo un momento in cui è necessario mantenere ferma la tua posizione. Hai il coraggio per sostenere ciò in cui credi, anche se ti senti sotto assedio.
- 2: Dall'altura respingi i bastoni che salgono verso di te: in questi giorni difendi ciò in cui credi sotto pressione, con coraggio, perché la posizione che tieni è ancora un vantaggio.
- 3: Adesso ti tocca tenere il punto: le pressioni arrivano da più lati, ti senti sotto assedio, ma il terreno più alto è tuo e la tua determinazione regge l'urto.

### capovolta

- 1: Senti il peso delle richieste o degli eventi che ti travolgono. Stai opponendo resistenza anche dove non è necessario: valuta bene cosa proteggere e cosa no.
- 2: Oggi ti difendi anche da chi non attacca: la pressione ti sovrasta, alzi il bastone in ogni direzione e l'energia che spendi a proteggere ogni collina ti lascia senza fiato.
- 3: In questo periodo le richieste ti travolgono e tu reagisci stando sempre sulla difensiva: non distingui più dove vale la pena resistere e dove potresti lasciare, così ogni scontro ti pesa.

## Otto di Bastoni

### dritta

- 1: Gli eventi si stanno muovendo in fretta e senti che le cose stanno accelerando. È il momento di assecondare il flusso, senza frenare l'energia in atto.
- 2: Nell'aria della tua situazione volano adesso molti bastoni insieme: notizie, messaggi, eventi che accelerano tutti nello stesso istante, mentre tu cerchi di tenere il ritmo della corsa.
- 3: In questi giorni le cose si muovono in fretta: una risposta tira l'altra, le distanze si accorciano e ti ritrovi dentro un movimento veloce che ti chiede prontezza più che riflessione.

### capovolta

- 1: Stai vivendo una fase di rallentamento forzato, o la tua eccessiva velocità crea ostacoli. È il momento di fermarti per riorganizzare le tue priorità.
- 2: Oggi i bastoni in volo si impigliano a mezz'aria: i messaggi tardano, le risposte non arrivano, oppure corri così in fretta che inciampi e devi rifare il tratto due volte.
- 3: In questo momento il ritmo è sbagliato: o tutto ristagna in ritardi che ti innervosiscono, o ti precipiti senza sapere dove vai e la velocità ti fa perdere l'ordine delle cose.

## Nove di Bastoni

### dritta

- 1: Senti il peso della stanchezza, eppure sei a un passo dalla meta. Ora è fondamentale mantenere la determinazione per completare ciò che hai iniziato.
- 2: Con la fronte fasciata e appoggiandoti al bastone, in questi giorni tieni duro: la stanchezza ti pesa addosso, ma il traguardo è a pochi passi e la tenacia è tutto ciò che ti serve.
- 3: Adesso la fatica è tanta e le ferite si vedono: hai già fatto il più del cammino, la guardia è alta e stringi il tuo bastone come chi non intende mollare proprio sul finale.

### capovolta

- 1: Senti il peso di una stanchezza che ti porta a irrigidire le tue difese, impedendoti di aprirti a nuove esperienze. Questa diffidenza rischia di isolarti.
- 2: Oggi la tua guardia è alzata contro chi viene in pace: le ferite del passato ti fanno vedere un attacco in ogni gesto, così tieni a distanza anche chi vorrebbe solo avvicinarsi.
- 3: In questo momento proteggi con troppo zelo un posto che nessuno assedia: la diffidenza ha preso il posto della prudenza e la palizzata che hai costruito lascia fuori anche l'affetto.

## Dieci di Bastoni

### dritta

- 1: Senti il peso delle responsabilità che gravano su di te. È il momento di valutare cosa è essenziale mantenere e cosa puoi lasciare andare per alleggerirti.
- 2: Porti in braccio un fascio di bastoni che ti curva la schiena: in questi giorni le responsabilità si sono ammucchiate fino a coprirti la vista della strada che stai percorrendo.
- 3: Adesso il carico è tanto: ogni impegno si è aggiunto all'altro, cammini piegando le spalle verso casa e ti chiedi quale di questi pesi sia davvero tuo da portare.

### capovolta

- 1: Senti il peso di responsabilità che non ti appartengono più o che non ti servono. Ora è il momento di riconoscere ciò che puoi eliminare per respirare con maggiore leggerezza.
- 2: Oggi ti carichi di pesi che non ti appartengono: per abitudine o per senso del dovere stringi fra le braccia bastoni di altri e la fatica che senti nasce da un fardello preso senza necessità.
- 3: In questo periodo porti più di quanto ti spetta: dici di sì a ogni richiesta, raccogli ciò che gli altri lasciano a terra e il fascio che ti piega la schiena è fatto anche di doveri presi in prestito.

## Fante di Bastoni

### dritta

- 1: Senti un'energia vivace che ti invita a guardare oltre l'ordinario, un impulso a sperimentare e a metterti alla prova. È il momento di accogliere questa curiosità e di agire con slancio.
- 2: Un'idea giovane ti bussa alla porta in questi giorni: la osservi come si guarda il germoglio spuntato in cima a un bastone, con curiosità fresca e la voglia di provarla subito.
- 3: Adesso ti accende la voglia di esplorare: ogni cosa nuova ti incuriosisce, fai domande, provi strade mai battute e la tua energia ha il calore di un primo viaggio.

### capovolta

- 1: La tua energia è frammentata, si accende e si spegne senza un obiettivo chiaro. Stai disperdendo il tuo potenziale in troppe direzioni, senza una focalizzazione.
- 2: Oggi le idee ti si accendono una dopo l'altra e nessuna dura: appena una comincia a crescere la successiva la scalza, così ti ritrovi con tanti inizi e nessun frutto.
- 3: In questo momento il tuo entusiasmo è un fuoco di paglia: divampa, ti esalta per un giorno, poi si spegne mentre già guardi altrove, lasciando dietro di te progetti appena abbozzati.

## Cavaliere di Bastoni

### dritta

- 1: Senti un forte desiderio di muoverti e una gran voglia di agire. Ti muovi con determinazione verso un nuovo inizio, senza esitazione.
- 2: In sella a un cavallo che s'impenna, in questi giorni parti all'avventura: la passione ti spinge avanti, hai fretta di arrivare dove desideri e il fuoco che ti muove si vede da lontano.
- 3: Adesso galoppi: l'ardore ti porta verso ciò che vuoi con un coraggio che non conosce esitazioni, mentre il paesaggio ti scorre accanto e la meta brilla all'orizzonte.

### capovolta

- 1: La foga incauta ti fa procedere con impulsività e senza un piano definito. Rischi di bruciare le tappe e di perdere di vista i tuoi obiettivi.
- 2: Oggi il tuo cavallo corre ma non sai dove: l'impazienza ti lancia al galoppo in mille direzioni, così l'ardore si consuma per strada prima di portarti in un posto qualunque.
- 3: In questo periodo sproni troppo forte: vuoi tutto e subito, cambi rotta a ogni curva e la tua passione, senza una meta che la incanali, ti brucia come un fuoco lasciato senza argini.

## Regina di Bastoni

### dritta

- 1: Il tuo magnetismo personale ti rende un punto di riferimento. Ti senti a tuo agio nell'esprimere chi sei veramente e questo attrae chi ti sta intorno.
- 2: Col girasole in mano e il gatto nero ai piedi, in questi giorni la tua presenza scalda chi ti sta intorno: sicurezza e generosità ti danno un fascino che attira senza togliere spazio a nessuno.
- 3: Adesso irradii calore: sai chi sei, lo mostri senza paura e la tua fiamma accoglie gli altri invece di bruciarli, come un focolare acceso al centro della stanza.

### capovolta

- 1: Il dubbio su di te è forte in questo momento e ti porta a non riconoscere le tue capacità, il che rischia di bloccare la tua iniziativa. Percepisci che il tuo potenziale viene messo in discussione.
- 2: Oggi una gelosia ti morde: vivi chi ti sta accanto come un rivale da superare e il bisogno di brillare più degli altri ti fa perdere il calore che di solito offri senza calcolo.
- 3: In questo momento la tua fiamma si fa competitiva: ogni successo altrui ti sembra tolto a te, così ti agiti per farti notare e la gara che hai in testa ti allontana dal tuo centro.

## Re di Bastoni

### dritta

- 1: La tua leadership è ora richiesta per tracciare una direzione precisa. La tua generosità indica agli altri il cammino, sii un esempio per tutti.
- 2: Dal tuo trono decorato di salamandre, in questi giorni guidi gli altri con l'esempio: la tua volontà apre strade, chi ti segue prende fuoco dalla tua visione e tu indichi la direzione con generosità.
- 3: Adesso sei tu a tenere in mano la rotta di un gruppo o di un progetto: il tuo fuoco è maturo, non corre ma accende, così gli altri si muovono ispirati da ciò che fai più che da ciò che dici.

### capovolta

- 1: Gestisci una situazione in cui l'autorità si manifesta con rigidità, senza dare spazio al confronto. Il tuo modo di condurre le cose rischia di non coinvolgere, ma di imporre la tua volontà.
- 2: Oggi la tua autorità spinge senza ascoltare: decidi d'impulso, imponi la tua visione con troppa foga e chi ti sta intorno, invece di accendersi, si lascia travolgere dalla tua volontà.
- 3: In questo periodo il comando ti si irrigidisce in mano: pretendi che gli altri seguano il tuo passo, alzi il tono quando qualcuno obietta e il fuoco che dovrebbe ispirare finisce per bruciare.

## Asso di Coppe

### dritta

- 1: Senti un'emozione pura sgorgare, un nuovo inizio che ti invita ad aprire il cuore e a lasciarti andare. È un tempo propizio per l'accoglienza e la dolcezza, senza paure o resistenze.
- 2: Una coppa trabocca adesso fra le tue mani: un'emozione nuova sgorga come una fonte, forse un amore o una tenerezza appena nata che lasci scorrere senza difenderti.
- 3: In questi giorni il cuore ti si apre: da una sorgente che non conoscevi l'acqua scende in cinque rivoli, la grazia di ciò che senti è pura e la stai accogliendo senza paura.

### capovolta

- 1: Senti una chiusura emotiva che ti impedisce di esprimere i tuoi sentimenti più profondi. C'è una resistenza a lasciarti andare, anche se desideri una connessione autentica.
- 2: Tieni chiusa la sorgente in questo momento: un'emozione nuova preme dentro di te e la trattieni per timore di soffrire, così l'acqua che vorrebbe scorrere ristagna nella coppa.
- 3: Oggi il tuo cuore rimanda un affetto che sente già: lo copri, lo rinvii, ne hai paura, mentre la coppa che hai in mano resta piena e ferma senza versare una goccia.

## Due di Coppe

### dritta

- 1: Sperimenti un'unione armoniosa, un patto che ti nutre e ti dà forza. Coltiva questa intesa, perché il riconoscimento reciproco moltiplica il tuo benessere.
- 2: Due coppe si incontrano in questi giorni: tu e un'altra persona vi guardate negli occhi e sigillate un'intesa, un patto d'affetto in cui ciascuno riconosce l'altro con lo stesso calore.
- 3: Adesso vivi un'armonia a due: il legame che hai davanti nasce dal riconoscimento reciproco, vi scambiate promesse leggere mentre sopra di voi il caduceo alato unisce ciò che era separato.

### capovolta

- 1: Un malinteso sta creando distanza in una relazione. Ti è chiesto di parlare con il cuore aperto e cercare un nuovo equilibrio.
- 2: Fra te e una persona a cui vuoi bene oggi si è insinuata una distanza: un malinteso, una parola presa male, così le due coppe restano a mezz'aria senza toccarsi.
- 3: In questo momento il dialogo con chi ti sta accanto si è inceppato: vi volete bene eppure non vi capite, ciascuno aspetta che l'altro faccia il primo passo e l'equilibrio fra voi si è spostato.

## Tre di Coppe

### dritta

- 1: Senti il bisogno di condividere con chi ti è accanto, festeggiando i traguardi o semplicemente l'unione. Ti dedichi con piacere a stare in compagnia e a celebrare la vita insieme agli altri.
- 2: Le coppe si alzano in compagnia in questi giorni: amiche, amici e persone care brindano con te, la gioia condivisa raddoppia e c'è qualcosa da festeggiare insieme.
- 3: Adesso intorno a te danza un cerchio di affetti: la comunità ti accoglie, si ride, si celebra un raccolto o una buona notizia e ti senti a casa fra chi ti vuole bene.

### capovolta

- 1: È il momento di riconsiderare le tue relazioni, riducendo il cerchio per dare spazio a chi ti supporta davvero. Ritorna alle amicizie autentiche, quelle che ti fanno stare bene.
- 2: Oggi il tuo cerchio di amicizie ha bisogno di cura: troppe feste, troppi brindisi di facciata, oppure legami che ti disperdono invece di nutrirti mentre le persone vere restano in disparte.
- 3: In questo periodo la compagnia ti stanca più che rallegrarti: ti muovi fra tante persone e pochi legami sinceri, con l'eccesso che prende il posto della gioia di stare insieme.

## Quattro di Coppe

### dritta

- 1: Provi noia e insoddisfazione, tanto da non notare un dono significativo che si manifesta vicino a te. Alza lo sguardo, un'opportunità tende a mostrarsi proprio accanto a te.
- 2: Sotto l'albero, a braccia conserte, in questi giorni guardi le coppe che conosci e non vedi quella che una mano ti porge: hai già abbastanza, o così ti sembra: niente ti tocca.
- 3: Adesso ti prende una sazietà che somiglia alla noia: ciò che arriva ti lascia indifferente, rifiuti un'offerta senza guardarla e il tuo sguardo resta chiuso su ciò che già possiedi.

### capovolta

- 1: Senti un risveglio interiore che ti spinge ad aprire il tuo cuore a nuove esperienze. Una curiosità inattesa ti invita a esplorare ciò che prima non consideravi.
- 2: Esci dal torpore in questi giorni: le braccia si sciolgono, alzi gli occhi dalle coppe di sempre e ti accorgi della mano che ti offriva qualcosa, con una curiosità nuova che si risveglia.
- 3: Oggi la noia ti lascia andare: torni a sentire sapore nelle cose, l'apatia che ti teneva sotto l'albero si scioglie e il cuore ricomincia a muoversi verso ciò che gli si offre.

## Cinque di Coppe

### dritta

- 1: Senti il rammarico per qualcosa che ti è sfuggito e questo sentimento ti impedisce di guardare oltre. Non riesci a vedere le risorse che ancora possiedi.
- 2: Col mantello nero sulle spalle, in questi giorni fissi le coppe versate a terra: il dolore per ciò che è andato ti prende tutto lo sguardo e non vedi le due ancora in piedi dietro di te.
- 3: Adesso il rimpianto occupa il centro della tua giornata: ciò che si è perso ti pesa davvero, eppure ciò che ti resta è ancora lì, alle spalle, ad aspettare che tu ti volti.

### capovolta

- 1: Stai accettando il passato e ti stai perdonando per ciò che è successo. Questo ti permette di vedere le opportunità che hai ancora a disposizione.
- 2: Ti stai voltando in questi giorni: dopo aver pianto le coppe versate guardi finalmente le due ancora piene mentre il dolore, piano, lascia spazio all'accettazione e a una speranza discreta.
- 3: Oggi raccogli ciò che resta: il lutto si fa più leggero, perdoni ciò che è andato e cammini verso il ponte con le coppe superstiti fra le mani.

## Sei di Coppe

### dritta

- 1: Sperimenti un forte richiamo al passato, un affetto sincero che riemerge e ti invita a rivivere o a onorare vecchi legami e ricordi preziosi. Questa tenerezza ti nutre e ti guida nelle tue interazioni attuali.
- 2: Un ricordo d'infanzia ti torna in questi giorni come un fiore offerto in una coppa: un affetto antico, una persona del passato o un luogo caro ti scaldano con la loro tenerezza semplice.
- 3: Adesso la nostalgia è dolce: ripensi a un tempo in cui le cose erano innocenti, ritrovi qualcuno che ti conosceva da prima e lasci che quella bontà ti nutra.

### capovolta

- 1: Corri il rischio di non vivere appieno questo momento, perché ti aggrappi a un tempo che non esiste più. La vita ti chiama adesso, ma la tua attenzione è rivolta al ricordo di ciò che è stato.
- 2: Oggi vivi più nei ricordi che nelle giornate: la memoria di un tempo che non c'è più occupa il posto di ciò che hai davanti e ti aggrappi a un'infanzia o a un legame come a un rifugio.
- 3: In questo momento lo sguardo è rivolto indietro: confronti tutto con com'era, rimpiangi una dolcezza perduta e le tue giornate ti sembrano sbiadite accanto al giardino dei ricordi.

## Sette di Coppe

### dritta

- 1: Molte opzioni affascinanti ti si presentano, rischiando di perderti in fantasie che potrebbero non concretizzarsi e questo crea confusione.
- 2: Davanti a te fluttuano coppe fra le nuvole: in questi giorni le possibilità si affollano, ognuna con un tesoro, un drago o un castello dentro, mentre la fantasia ti promette più di quanto puoi tenere.
- 3: Adesso sogni a occhi aperti: tante strade ti incantano insieme, le illusioni si mescolano ai desideri veri e non riesci ancora a distinguere quale coppa contiene ciò che promette.

### capovolta

- 1: Stai mettendo a fuoco un desiderio autentico tra le diverse possibilità che si presentano. La scelta di una direzione ti libera dal peso di dover considerare troppe alternative.
- 2: Fra le tante coppe sospese oggi ne metti a fuoco una: la nebbia delle fantasie si dirada, sai quale desiderio è tuo davvero e rinunciare agli altri ti sembra finalmente un sollievo.
- 3: In questo periodo le illusioni si sgonfiano: smetti di inseguire ogni miraggio, i piedi tornano a terra e fra mille possibilità ne scegli una che ti somiglia.

## Otto di Coppe

### dritta

- 1: Senti il bisogno di abbandonare ciò che non ti nutre. Il tuo cuore ti guida verso la ricerca di un senso più elevato, anche se la ragione non ha ancora risposte chiare.
- 2: Volti le spalle in questi giorni a una fila di coppe ben allineate: ciò che hai costruito non ti nutre più, così parti in silenzio di notte verso le montagne, cercando un senso più alto.
- 3: Adesso stai lasciando qualcosa che non ti basta più: un luogo, un legame o un ruolo pieni ma vuoti di senso, mentre il cuore ti porta altrove anche se la mente non ha ancora tutte le risposte.

### capovolta

- 1: Senti un'indecisione profonda che ti blocca, non riesci a capire se ciò che hai è abbastanza o se devi lasciarlo per cercare altro. È un momento di stallo, dove la scelta di restare o partire ti pesa.
- 2: Oggi stai sulla porta con la sacca in spalla e non decidi: restare ti pesa, partire ti spaventa, così fai un passo verso le montagne e uno indietro verso le coppe che conosci.
- 3: In questo periodo l'indecisione fra andare e rimanere ti consuma: ti chiedi se ciò che hai sia abbastanza, torni sui tuoi passi e rimandi una partenza che il cuore forse ha già scelto.

## Nove di Coppe

### dritta

- 1: Assapori un momento di piena soddisfazione e benessere, un desiderio che si è concretizzato. Il tuo cuore è contento, senti che hai raggiunto la felicità.
- 2: A braccia incrociate davanti alle tue coppe in fila, in questi giorni hai il cuore contento: un desiderio si è avverato e ti godi la soddisfazione senza sentirti in colpa.
- 3: Adesso il benessere ti appartiene: ciò che avevi desiderato è qui, sulla tavola, mentre tu sorridi di una felicità piena che non ha bisogno di giustificarsi.

### capovolta

- 1: Stai vivendo una soddisfazione apparente che non ti nutre realmente. Rischi di accontentarti di piaceri effimeri e di non trovare la gioia vera.
- 2: Oggi le coppe sono tutte in fila eppure il cuore non è sazio: ti concedi piaceri che riempiono la giornata e lasciano vuoto il profondo, come una tavola imbandita di cibi senza sapore.
- 3: In questo momento la tua contentezza è di facciata: mostri di avere ciò che volevi, ti distrai con gratificazioni rapide e intanto la gioia vera resta lontana dal tuo sorriso.

## Dieci di Coppe

### dritta

- 1: Senti una profonda gratitudine per i legami che ti circondano e la loro armonia ti riempie, trovando nella pienezza condivisa la tua vera ricchezza attuale.
- 2: Un arcobaleno di coppe si apre sopra la tua casa in questi giorni: le persone che ami ti stanno intorno, i bambini giocano, gli affetti sono in armonia e la felicità che vivi è condivisa.
- 3: Adesso la tua ricchezza sono i legami: in casa c'è pace, ci si tiene per mano, la gratitudine ti scalda e senti che ciò che conta è già qui, intorno a te.

### capovolta

- 1: Senti che l'equilibrio nei tuoi affetti è precario, come se ci fosse una frattura da sanare. C'è bisogno di ricostruire il dialogo e la vicinanza con chi ti sta attorno.
- 2: Sotto il tuo tetto oggi ognuno tira dalla sua parte: gli affetti di casa si sono raffreddati, l'arcobaleno si è spezzato e la serenità del gruppo risente di distanze non dette.
- 3: In questo periodo la famiglia o il gruppo a cui appartieni attraversa tensioni: fra le persone di casa c'è più silenzio che dialogo e tu senti il peso di un'armonia incrinata.

## Fante di Coppe

### dritta

- 1: Senti nascere in te una creatività inaspettata, un'emozione gentile che chiede espressione. Questo momento ti offre spunti preziosi grazie alla tua sensibilità.
- 2: Un pesciolino spunta in questi giorni dalla tua coppa e ti guarda: un'emozione fragile e poetica affiora, un messaggio d'affetto, un'ispirazione tenera che ti sorprende e chiede spazio.
- 3: Adesso la tua sensibilità è a fior di pelle: senti nascere sentimenti nuovi, scrivi, sogni, ti commuovi per poco e c'è un'ingenuità dolce nel modo in cui ti apri.

### capovolta

- 1: Senti il bisogno di proteggere la tua emotività, ma questa chiusura rischia di impedirti di vivere appieno le esperienze e di esprimere i tuoi sentimenti più profondi.
- 2: Oggi il tuo cuore si è chiuso come un guscio: un'emozione giovane è stata ferita e la proteggi murandola, così la coppa che prima ti sorprendeva resta coperta dalla tua mano.
- 3: In questo periodo la tua emotività è fragile: ti offendi per poco, ti ritiri appena senti un'ombra e la sensibilità che ti nutriva si nasconde dietro un muro di difesa.

## Cavaliere di Coppe

### dritta

- 1: Senti un forte desiderio di esprimere affetto e di fare una proposta. È il momento di lasciarti corteggiare e di offrire il tuo cuore con grazia.
- 2: Al passo lento di un cavallo bianco ti viene incontro in questi giorni un invito: qualcuno ti porge una coppa con grazia, oppure sei tu a offrirla, in un gesto romantico che apre il cuore.
- 3: Adesso il sentimento ti muove: segui l'impulso di corteggiare o di lasciarti corteggiare, una proposta affettuosa ti attraversa i giorni e la bellezza di questo slancio ti ammorbidisce.

### capovolta

- 1: Stai vivendo una situazione in cui le parole non corrispondono ai fatti, o le tue intenzioni non trovano riscontro nelle azioni. Verifica la concretezza di ciò che senti o ti viene detto.
- 2: Oggi le promesse d'affetto restano vaghe: parole belle ti raggiungono o le pronunci tu, ma ai gesti non seguono passi e la coppa offerta resta sospesa fra due mani senza essere presa.
- 3: In questo momento un romanticismo di superficie ti seduce: il cavaliere della tua storia parla molto e agisce poco, così ti muovi fra illusioni dolci che non mettono radici.

## Regina di Coppe

### dritta

- 1: Senti un forte bisogno di ascoltare il tuo intuito, di comprendere le situazioni con il cuore e di agire con tenerezza, affidandoti alla tua empatia per guidarti nelle relazioni e nelle scelte.
- 2: Con lo sguardo sulla coppa chiusa che tieni in grembo, in questi giorni accogli e comprendi: leggi gli altri in profondità, senti ciò che non dicono e la tua empatia diventa una forza.
- 3: Adesso il tuo intuito lavora come la marea: capisci con il cuore prima che con la testa, offri tenerezza a chi ti sta intorno e sai ascoltare anche ciò che sta sotto la superficie.

### capovolta

- 1: Senti il peso delle emozioni e delle esigenze altrui e questo rischia di farti perdere il contatto con la tua identità. Puoi riportare l'attenzione su di te.
- 2: Oggi ti perdi negli stati d'animo altrui: assorbi la tristezza, l'ansia, le gioie degli altri fino a non riconoscere più le tue, come chi entra in mare e non tocca più il fondo.
- 3: In questo periodo la tua sensibilità non ha argini: ogni emozione intorno a te ti attraversa e ti trascina, così curi tutti col cuore e dimentichi di mettere un poco di cura anche nella tua coppa.

## Re di Coppe

### dritta

- 1: La tua padronanza emotiva ti rende un punto di forza, capace di affrontare le sfide con calma profonda. La tua presenza offre stabilità e comprensione, sia a te che agli altri.
- 2: Sul trono che galleggia in mezzo alle onde, in questi giorni tieni la calma: i sentimenti si muovono intorno a te, ma tu li governi con serenità matura e fai da porto a chi cerca riparo.
- 3: Adesso la tua padronanza emotiva si vede: non ti lasci trascinare dalle correnti, ascolti, consigli e tieni la coppa ben dritta mentre il mare intorno continua ad agitarsi.

### capovolta

- 1: Sperimenti un'instabilità emotiva che ti impedisce di gestire le situazioni con chiarezza. È essenziale che tu manifesti ciò che senti, superando ogni paura di mostrarti pienamente.
- 2: Oggi gli umori prendono il posto della guida: chi si aspetta calma da te riceve sbalzi improvvisi e il trono sulle onde oscilla, perché lasci che siano le tue emozioni a decidere.
- 3: In questo momento usi i sentimenti come leve: ti chiudi, ti offendi, poi ti sciogli per ottenere ciò che vuoi, mentre la maturità affettiva che possiedi resta ai margini senza governare.

## Asso di Denari

### dritta

- 1: Una solida opportunità si presenta a te, è il momento giusto per piantare un nuovo seme. Hai a disposizione un terreno fertile per iniziare qualcosa di concreto.
- 2: Da una nuvola una mano ti porge adesso una moneta d'oro: davanti a te c'è un'occasione concreta, un lavoro, una base o un progetto solido, con un giardino curato che si apre oltre il cancello.
- 3: In questi giorni hai fra le dita un seme materiale: qualcosa di tangibile comincia, il terreno sotto i tuoi piedi è fertile e senti che ciò che avvii poggia su buone radici.

### capovolta

- 1: Una possibilità rischia di sfuggirti. Guardi la situazione con poca attenzione e questo ti impedisce di cogliere ciò che è prezioso per te.
- 2: Oggi un'occasione concreta ti scivola davanti senza che tu la guardi davvero: la moneta tesa dalla nuvola resta sospesa mentre tu valuti male il rischio o guardi altrove.
- 3: In questo momento un'apertura pratica ti sta sfumando davanti: un'offerta di lavoro, un accordo o una base solida che sottovaluti, così il cancello del giardino si richiude piano mentre esiti.

## Due di Denari

### dritta

- 1: Stai mantenendo un equilibrio precario tra le diverse richieste, alternando i tuoi impegni con leggerezza. La tua flessibilità è fondamentale per gestire questo momento di costante movimento.
- 2: Con due monete legate da un nastro infinito, in questi giorni ti destreggi fra impegni diversi: alzi l'una, abbassi l'altra, tieni il ritmo con leggerezza come un giocoliere sul molo mentre le navi ballano sulle onde.
- 3: Adesso la tua giornata è una danza di priorità: passi da un compito all'altro, ti adatti ai cambi senza irrigidirti e la flessibilità ti permette di tenere tutto in movimento.

### capovolta

- 1: Gestisci troppi impegni e rischi di far cadere tutto per non aver stabilito delle priorità. Scegliere ora ciò che è essenziale ti aiuta a non perdere il controllo.
- 2: Oggi il nastro fra le due monete si è aggrovigliato: il ritmo si è rotto, qualcosa ti sta già scivolando dalle mani e i tuoi impegni cadono uno dopo l'altro come palline sfuggite al giocoliere.
- 3: In questo momento tieni in aria troppe cose insieme: corri da un fronte all'altro senza scegliere, così il gioco che prima ti divertiva si è fatto affanno e la confusione ti toglie presa.

## Tre di Denari

### dritta

- 1: Costruisci insieme agli altri e il tuo lavoro è visto e apprezzato; questo è solo l'inizio di un percorso dove la collaborazione porta risultati importanti.
- 2: Dentro la cattedrale in costruzione, in questi giorni lavori accanto ad altri a un'opera comune: la tua competenza è vista, chi progetta e chi esegue si confrontano e i primi risultati concreti prendono forma.
- 3: Adesso il tuo mestiere entra in squadra: metti le mani nel progetto, ascolti chi ti mostra il disegno e la collaborazione fa crescere un lavoro che senza gli altri non avresti alzato così in alto.

### capovolta

- 1: La mancanza di chiarezza nella comunicazione sta rallentando un'opera comune. Le tue aspettative non sono allineate a quelle degli altri e questo crea attrito.
- 2: Oggi il lavoro comune non ingrana: i ruoli sono confusi, nessuno sa chi deve fare cosa e tu ti ritrovi sul cantiere con l'arco a metà, fra aspettative che non combaciano.
- 3: In questo periodo la squadra di cui fai parte procede a strappi: ciascuno segue il suo disegno, i compiti si sovrappongono e la tua competenza si perde in una cattiva intesa sul da farsi.

## Quattro di Denari

### dritta

- 1: Ti concentri sulla sicurezza, stringendo ciò che hai. Questa prudenza ti protegge, ma al contempo rischia di impedire nuovi apporti o la crescita.
- 2: Stringi al petto una moneta e ne tieni altre sotto i piedi: in questi giorni proteggi ciò che possiedi, conti, risparmi, metti da parte con cura e la sicurezza materiale è la tua priorità.
- 3: Adesso conservare è il tuo mestiere: tieni le risorse ben chiuse, controlli ogni spesa e preferisci la tranquillità di ciò che hai al rischio di qualcosa di nuovo.

### capovolta

- 1: La tua rigidità impedisce il fluire delle energie e delle opportunità. Stai stringendo troppo qualcosa e questo ti sta soffocando, limitando la tua libertà di movimento.
- 2: Oggi la paura di restare senza ti fa stringere anche il poco: le dita sono serrate sulla moneta fino a far male e ogni spesa, ogni dono, ti sembra una perdita da evitare.
- 3: In questo periodo trattieni tutto per timore della mancanza: denaro, tempo, energie ti restano chiusi in pugno e ciò che stringi così forte finisce per stringere anche te.

## Cinque di Denari

### dritta

- 1: Percepisci una carenza o un senso di isolamento, come se ti mancasse un elemento fondamentale. Puoi cercare supporto e superare questo stato, senza esitazioni.
- 2: Cammini nella neve davanti a una finestra illuminata: in questi giorni senti la mancanza, il freddo dell'esclusione, mentre il calore di una casa è a pochi passi e non ti decidi a bussare.
- 3: Adesso attraversi un inverno: le risorse scarseggiano, ti senti fuori dal giro e la vergogna di chiedere aiuto ti tiene sulla strada, accanto a qualcuno che soffre come te.

### capovolta

- 1: Stai avvertendo una ripresa, un supporto che ti aiuta a uscire da una situazione difficile. La fiducia sta rientrando: il peggio è passato e l'isolamento pesa meno.
- 2: Il freddo comincia ad allentarsi in questi giorni: qualcuno ti apre la porta, un sostegno ritrovato ti scalda le mani e lasci la neve dietro di te un passo alla volta.
- 3: Oggi il periodo duro mostra le prime crepe: torna la fiducia, accetti l'aiuto che prima non chiedevi e la finestra illuminata non è più soltanto qualcosa da guardare da fuori.

## Sei di Denari

### dritta

- 1: Sperimenti uno scambio equo, dove l'aiuto reciproco crea armonia. Dai e ricevi in un flusso costante, mantenendo l'equilibrio essenziale per la tua serenità.
- 2: Con la bilancia in una mano, in questi giorni dai e ricevi con giustizia: un aiuto passa dalle tue mani a quelle di chi ne ha bisogno, oppure lo ricevi tu, in uno scambio che resta in equilibrio.
- 3: Adesso le risorse intorno a te circolano: offri ciò che puoi, accetti ciò che ti viene dato e la generosità che vivi ha la misura giusta, senza debiti né umiliazioni.

### capovolta

- 1: Stai vivendo una situazione in cui il dare e l'avere non sono bilanciati. Questo comporta un peso che ti impedisce di avanzare senza difficoltà.
- 2: Oggi la bilancia dello scambio pende da una parte: dai a chi non ricambia, oppure ricevi con un debito che ti pesa, così la generosità che vivi ti svuota invece di circolare.
- 3: In questo periodo il dare e l'avere smettono di corrispondere: concedi aiuto a chi ne approfitta o lo ricevi a condizioni che ti mettono in debito, così la tua mano tesa si stanca.

## Sette di Denari

### dritta

- 1: È il momento di valutare i progressi fatti e di attendere con fiducia che i tuoi sforzi diano i frutti sperati. Non affrettare i tempi, perché ciò che sta maturando richiede il giusto compimento.
- 2: Appoggiandoti alla zappa, in questi giorni guardi la pianta carica di monete che hai coltivato: valuti ciò che è cresciuto, misuri il lavoro fatto e aspetti il tempo giusto per il raccolto.
- 3: Adesso ti fermi a osservare: il campo è curato, i frutti maturano piano e tu soppesi con pazienza se l'investimento di tempo e fatica stia rendendo come speravi.

### capovolta

- 1: Senti che i tuoi sforzi non vengono ripagati e che l'attesa si fa lunga. Rivedi con calma le tue priorità per non scoraggiarti e non disperdere le tue forze.
- 2: Oggi davanti alla tua pianta ti assale l'impazienza: il raccolto sembra scarso rispetto alla fatica e ti chiedi se hai seminato nel posto giusto, con la zappa che ti pesa fra le mani.
- 3: In questo momento lo sforzo ti pare mal ripagato: guardi i frutti che tardano, ti scoraggi e ti viene voglia di strappare tutto, mentre forse è il seme a dover cambiare, non il tempo.

## Otto di Denari

### dritta

- 1: Stai perfezionando le tue competenze con attenzione e meticolosità, un passo alla volta. Questa pratica costante affina il tuo valore e la tua abilità.
- 2: Al banco da lavoro, in questi giorni incidi una moneta dopo l'altra: il mestiere si affina nella ripetizione paziente e ogni dettaglio curato ti insegna qualcosa, aggiungendo valore a ciò che produci.
- 3: Adesso ti dedichi alla pratica: lavori con concentrazione, impari dagli errori e la maestria che cresce fra le tue mani nasce proprio da questa fatica quotidiana e silenziosa.

### capovolta

- 1: Senti il peso di un'attività che ti ha svuotato, un mestiere che percepisci come una gabbia. Rischi di non trovare più il senso profondo in ciò che porti avanti.
- 2: Oggi le monete escono dal tuo banco tutte uguali e senza cura: il mestiere ripetuto ha perso senso, lavori per abitudine e la passione che ti faceva incidere ogni dettaglio si è spenta.
- 3: In questo periodo la routine ti chiude in una gabbia: fai le cose in fretta o senza amore mentre il lavoro che una volta ti dava orgoglio adesso ti svuota le giornate.

## Nove di Denari

### dritta

- 1: Ti godi pienamente ciò che hai costruito, senti di abitare un luogo di indipendenza serena. Sperimenti la piena autonomia e benessere.
- 2: Nel tuo giardino di viti cariche, con un falco sul guanto, in questi giorni ti godi l'agio costruito con le tue mani: l'indipendenza è serena e lo spazio che abiti è tuo per merito.
- 3: Adesso raccogli i frutti della tua autonomia: non dipendi da nessuno, ti concedi piccoli piaceri raffinati e cammini fra le cose che hai guadagnato con una calma piena di gusto.

### capovolta

- 1: Un'insicurezza ti assilla, o ti trovi in una situazione di eccessi che minano la tua pace. È il momento di curare la tua indipendenza e riconoscere che il tuo valore va oltre i beni materiali.
- 2: Oggi la libertà che hai costruito col tuo lavoro vacilla: spendi oltre misura o senti il bisogno di mostrare ciò che possiedi, così il giardino che ti dava pace comincia a costarti più di quanto rende.
- 3: In questo momento l'agio che avevi conquistato si sta consumando: compri per apparire, ti misuri sugli oggetti e l'indipendenza diventa una facciata che ti tiene in ansia.

## Dieci di Denari

### dritta

- 1: Stai edificando qualcosa che tende a durare nel tempo, con una visione che include il benessere futuro. Puoi rafforzare legami e progetti con solidità e lungimiranza.
- 2: Sotto l'arco della casa di famiglia, in questi giorni ti ritrovi fra generazioni diverse: anziani, adulti, bambini e cani condividono radici solide e ciò che hai costruito dura nel tempo.
- 3: Adesso la tua stabilità ha il sapore delle cose che restano: la casa, le tradizioni di famiglia, un benessere che nutre anche chi viene dopo di te, piantato con pazienza oltre la tua stagione.

### capovolta

- 1: Stai vivendo un momento di instabilità che mette in discussione le tue radici e i tuoi valori. Le fondamenta della tua vita sono sotto esame e necessitano di attenzione profonda.
- 2: Oggi in famiglia c'è attrito su ciò che appartiene a più persone: una casa, dei beni, un patrimonio comune diventano terreno di contesa fra chi dovrebbe condividerli e tu ti trovi in mezzo.
- 3: In questo periodo le radici di casa tirano da parti diverse: discussioni su soldi, proprietà o tradizioni dividono chi ti sta intorno e ciò che era di tutti diventa motivo di distanza.

## Fante di Denari

### dritta

- 1: Stai mettendo in pratica un'idea che richiede la tua attenzione e dedizione. Questo è il momento di concretizzare i tuoi sogni pratici con passi studiati e mirati.
- 2: Con una moneta sollevata davanti agli occhi, in questi giorni la studi come un libro: impari qualcosa di concreto, ti applichi con serietà e ogni lezione la trasformi subito in pratica.
- 3: Adesso ti metti a scuola del mondo pratico: segui un corso, un apprendistato o un progetto nuovo con pazienza, perché ciò che impari prende forma solo quando lo eserciti.

### capovolta

- 1: Un'iniziativa è ferma a metà, bloccata da una mancanza di attenzione iniziale. Puoi riprendere in mano la situazione, procedendo con calma e metodo.
- 2: Oggi lo studio che avevi promesso è fermo a metà: la moneta che dovevi osservare ti scivola dalle mani mentre ti distrai e l'impegno preso aspetta ancora di diventare pratica.
- 3: In questo periodo rimandi i compiti che avevi scelto: apri il libro e lo richiudi, cominci un corso e lo trascuri, così la promessa di imparare resta sospesa senza passi concreti.

## Cavaliere di Denari

### dritta

- 1: Avanzi con passo fermo e paziente, senza fretta, verso un obiettivo che persegui con dedizione. La tua forza risiede nella costanza, non nella velocità.
- 2: Al passo lento del tuo cavallo da lavoro, in questi giorni procedi con metodo: un passo dopo l'altro, senza fretta, tieni la moneta davanti agli occhi e la costanza è la tua forza.
- 3: Adesso il tuo lavoro avanza come un aratro: lento, regolare, affidabile, mentre ogni giorno aggiungi un solco al precedente e la meta si avvicina proprio perché non ti fermi.

### capovolta

- 1: Il passo è bloccato, l'eccessiva prudenza ti frena dal prendere iniziative. Superare l'immobilità e agire è necessario per sbloccare la situazione.
- 2: Oggi la strada è quella giusta e la meta resta in vista, eppure i tuoi passi si sono fermati: la prudenza rimanda ogni tappa e la costanza si è trasformata in immobilità.
- 3: In questo momento il tuo cavallo da lavoro non si muove più: aspetti condizioni perfette, controlli e ricontrolli, così il cammino che percorrevi con metodo si è inceppato a metà del campo.

## Regina di Denari

### dritta

- 1: Stai vivendo un momento in cui la tua capacità di accogliere e la tua praticità sono fondamentali. Trovi equilibrio tra affetto e gestione delle questioni quotidiane, facendo fiorire il tuo mondo con impegno e dedizione.
- 2: Con una moneta in grembo e un coniglio nel giardino, in questi giorni ti prendi cura di chi ami con le mani: la casa, i conti, la tavola apparecchiata parlano di una generosità concreta.
- 3: Adesso unisci il cuore e la praticità: sai cosa serve a ciascuno, lo procuri con i piedi a terra e il tuo affetto si vede nelle cose fatte, non nelle parole.

### capovolta

- 1: Senti uno squilibrio tra quanto dai e quanto ricevi. Ti scordi di te e la tua generosità rischia di portarti via tutte le risorse.
- 2: Oggi ti occupi della casa, dei conti, dei bisogni di tutti: nell'elenco delle cose da curare il tuo nome non compare e il giardino che annaffi per gli altri ti lascia a secco.
- 3: In questo periodo la tua generosità pratica ti consuma: risolvi, procuri, sistemi per chiunque ti stia intorno e trascuri il tuo riposo come se la cura fosse un dovere che vale per tutti tranne te.

## Re di Denari

### dritta

- 1: La tua capacità di gestire le risorse con abbondanza e misura ti pone in una posizione di successo concreto. Sai condividere ciò che hai creato.
- 2: Sul trono ornato di grappoli e tori, in questi giorni governi le tue risorse con abbondanza e misura: ciò che hai costruito è solido e sai condividerlo senza sprechi.
- 3: Adesso tieni in mano un regno concreto: lavoro, beni, persone che dipendono dalle tue decisioni, mentre la ricchezza che amministri si accompagna alla saggezza di usarla bene.

### capovolta

- 1: Un possesso ti sta irrigidendo, impedendoti di agire con libertà. La ricchezza che hai rischia di non circolare, ostacolando il tuo movimento.
- 2: Oggi ciò che possiedi ti si irrigidisce fra le mani: il governo dei tuoi beni è diventato controllo, le risorse restano ferme invece di dare frutto e la proprietà comincia a possedere te.
- 3: In questo momento la prosperità che amministri si chiude su sé stessa: misuri tutto in guadagno, decidi pensando al patrimonio più che alle persone e la tua autorità si fa pesante come l'oro che custodisci.

## Asso di Spade

### dritta

- 1: Questo è il momento di fare chiarezza e di esprimere la tua verità con decisione. Hai un'idea netta e sai distinguere tra ciò che è reale e ciò che non lo è.
- 2: Una spada dritta esce adesso dalla nuvola e ti mette in mano una corona: vedi con lucidità, distingui il vero dal falso e hai il coraggio di dire le cose come stanno.
- 3: In questi giorni la tua mente taglia netto: un'idea chiara si impone sulla confusione, capisci ciò che prima ti sfuggiva e la verità che hai davanti apre più di quanto ferisca.

### capovolta

- 1: Le tue idee sono confuse e rischi di comunicare in modo inefficace, ferendo chi ti ascolta o complicando la situazione. È il momento di riflettere bene prima di esprimere i tuoi pensieri o di prendere una posizione.
- 2: Oggi la lama che tieni in mano è annebbiata: pensieri confusi ti impediscono di vedere netto e quando parli il taglio cade nel punto sbagliato, ferendo invece di chiarire.
- 3: In questo momento un'idea ti si ritorce contro: la impugni male, la dici troppo presto o con troppa durezza, così la stessa chiarezza che potrebbe liberarti diventa una ferita.

## Due di Spade

### dritta

- 1: Eviti di prendere una posizione netta, mantenendo una condizione di equilibrio instabile. Evitare di affrontare la situazione per intero rischia di frenarti.
- 2: Con la benda sugli occhi e due spade incrociate sul petto, in questi giorni tieni in sospeso una decisione: alle tue spalle il mare si muove, ma tu resti a braccia serrate pur di non guardare.
- 3: Adesso ti ostini in un equilibrio precario: rimandi una scelta che conosci, ti chiudi in una tregua interiore e la quiete apparente che mantieni ti costa la fatica di non vedere.

### capovolta

- 1: Il blocco che ti ha impedito di muoverti si sta sciogliendo e una scelta rimandata ora ti chiede attenzione. Puoi vedere chiaramente ciò che prima tenevi nascosto.
- 2: Oggi la benda ti scivola dagli occhi: la scelta che avevi rimandato torna a chiederti una risposta, le braccia si sciolgono e vedi finalmente ciò che prima coprivi.
- 3: In questo momento lo stallo si rompe: la tregua che tenevi con fatica non regge più e la decisione a cui giravi intorno ti si mette davanti, impossibile da ignorare.

## Tre di Spade

### dritta

- 1: Provi una sofferenza che ti trapassa, una delusione che ti ha ferito profondamente. Riconosci questo stato d'animo, accoglilo, è il primo passo per andare oltre.
- 2: Un cuore trafitto da tre spade sotto la pioggia: in questi giorni porti una delusione che ti attraversa il petto, il dolore è vivo e le lacrime cercano di uscire.
- 3: Adesso la ferita è aperta: una parola, una separazione o un tradimento ti hanno colpito dove sei più vulnerabile e il cielo intorno a te è grigio di pioggia.

### capovolta

- 1: Stai vivendo un momento di perdono e ripresa, la tempesta è passata e il tuo cuore si sta alleggerendo. Ti stai concedendo il tempo di riprenderti e di respirare di nuovo.
- 2: La pioggia sta passando in questi giorni: le spade si sfilano piano dal tuo petto, il dolore che ti trafiggeva comincia a sfumare e il cuore torna a respirare, anche se la cicatrice resta.
- 3: Oggi la tua ferita smette di sanguinare: non dimentichi ciò che ti ha fatto male, ma lo porti con meno peso, mentre il perdono si fa strada dentro di te un poco alla volta.

## Quattro di Spade

### dritta

- 1: Sospendi ogni azione e ti ritiri in un periodo di riflessione, un momento di quiete per ascoltare la tua mente. Questa pausa non è un'interruzione, ma un modo per ricostruire la tua forza interiore.
- 2: Nel silenzio di una cappella, con le mani giunte e una spada sotto di te, in questi giorni riposi: la mente si ferma dopo la fatica e la quiete ti restituisce forza.
- 3: Adesso è il tempo della tregua: ti ritiri dal rumore, chiudi gli occhi sulle battaglie appena passate e lasci che il corpo e i pensieri recuperino in pace.

### capovolta

- 1: È il momento di risvegliarti e riprendere le tue attività con una nuova consapevolezza. Agisci con calma, senza fretta, per consolidare i benefici della tua recente quiete.
- 2: Ti alzi in questi giorni dal giaciglio di pietra: il riposo ha fatto il suo lavoro, riapri gli occhi sulle cose da fare e ricominci a muoverti con calma, senza strafare al primo passo.
- 3: Oggi la pausa finisce: le forze sono tornate, riprendi in mano la spada che avevi deposto e senti il desiderio di agire che la quiete aveva tenuto a dormire.

## Cinque di Spade

### dritta

- 1: Stai vivendo una situazione in cui senti l'orgoglio prevalere, rischiando di perseguire un successo che potrebbe rivelarsi più dannoso che gratificante. È il momento di valutare con attenzione se ciò che desideri ottenere vale davvero ciò che potresti sacrificare.
- 2: Raccogli adesso le spade lasciate a terra dagli altri, che si allontanano a capo chino: hai vinto una lite, ma il cielo è tagliato dal vento e il prezzo dell'orgoglio comincia a farsi sentire.
- 3: In questi giorni un conflitto ti mette davanti a una vittoria amara: tieni il punto per non perdere la faccia, guadagni la ragione e intanto perdi qualcosa di più prezioso.

### capovolta

- 1: Senti il desiderio di superare le ostilità e di riallacciare i legami, anche se ciò richiede un passo indietro. Stai valutando l'importanza della comprensione reciproca per ritrovare la serenità.
- 2: Oggi deponi le armi: dopo uno scontro che ha lasciato ferite, la voglia di riconciliarti è più forte del bisogno di avere ragione e fai il primo passo verso chi avevi allontanato.
- 3: In questo momento l'orgoglio si allenta: ripensi alla lite con meno rabbia, ti accorgi che la vittoria non valeva l'umiliazione e cerchi parole per ricucire ciò che si è strappato.

## Sei di Spade

### dritta

- 1: Stai attraversando una fase di transizione, allontanandoti da ciò che ha causato inquietudine. Il viaggio verso una maggiore serenità è in corso e ti conduce verso acque più calme.
- 2: Sulla barca guidata da un traghettatore, in questi giorni ti allontani dalle acque agitate: le spade sono a bordo con te, il viaggio è silenzioso e la sponda davanti ha un'aria più serena.
- 3: Adesso stai cambiando riva: lasci alle spalle una fase turbolenta, il mare si calma un poco alla volta e la transizione che vivi ha il passo lento di chi rema verso la quiete.

### capovolta

- 1: Fatichi a compiere il passo decisivo per allontanarti da ciò che ti lega. Il tuo animo è combattuto, senti la necessità di andare avanti ma il cuore non è ancora pronto.
- 2: Oggi il distacco ti pesa più del previsto: la barca si muove, ma il cuore resta sulla riva che lasci e il bagaglio delle spade che porti con te rende ogni colpo di remo più faticoso.
- 3: In questo momento parti trascinando i piedi: sai che devi andare, eppure qualcosa ti trattiene alle acque di prima e la traversata va avanti a fatica, con lo sguardo rivolto indietro.

## Sette di Spade

### dritta

- 1: Ti senti in una fase dove usare l'ingegno è necessario, ma devi fare attenzione a non scivolare nell'inganno. Stai navigando con furbizia, ponderando ogni passo con cautela.
- 2: In punta di piedi porti via le spade dall'accampamento: in questi giorni ti muovi d'astuzia, con tatto e strategia, preferendo l'ingegno allo scontro aperto mentre gli altri guardano altrove.
- 3: Adesso ti muovi con prudenza calcolata: scegli cosa dire e cosa tacere, aggiri gli ostacoli invece di affrontarli di petto e ti chiedi fin dove la furbizia resta un'arte e dove comincia a somigliare all'inganno.

### capovolta

- 1: Stai affrontando le conseguenze di un inganno, tuo o di altri, che sta emergendo. È il momento di riportare la verità e liberare la tua coscienza.
- 2: Oggi un inganno sta venendo a galla: una bugia detta o subita ti pesa sulla coscienza e le spade rubate nella notte tornano alla luce, chiedendo di essere restituite.
- 3: In questo momento la verità bussa: ciò che è stato nascosto, da te o da altri, non regge più e mantenere il segreto ti costa più fatica di quanta ne costerebbe la trasparenza.

## Otto di Spade

### dritta

- 1: Percepisci di non avere margini di azione, ma questa sensazione deriva più dai tuoi pensieri che da reali impedimenti.
- 2: Con gli occhi coperti e le braccia legate fra le spade piantate nel fango, in questi giorni credi di non avere vie d'uscita, ma le corde sono larghe e il cerchio intorno a te è aperto.
- 3: Adesso la prigione è soprattutto nei tuoi pensieri: ti dici che non puoi muoverti, ti racconti limiti che nessuno ti impone e intanto la benda potresti toglierla con le tue mani.

### capovolta

- 1: Stai scoprendo che le limitazioni che percepivi non sono reali come credevi e questo ti permette di agire con maggiore libertà. Questo momento ti offre l'opportunità di muoverti oltre le barriere che prima ti sembravano insormontabili.
- 2: Oggi le corde si allentano: la benda ti scivola via, vedi che il cerchio di spade aveva un varco e fai il primo passo fuori da una trappola costruita più dalla paura che dai fatti.
- 3: In questo momento la mente si libera: le convinzioni che ti bloccavano perdono presa, riconosci di avere più margine di quanto temevi e cominci a muoverti fuori dal fango.

## Nove di Spade

### dritta

- 1: Senti la mente ingigantire ogni preoccupazione e questo ti impedisce di riposare. I tuoi pensieri creano scenari che non corrispondono alla realtà, fatichi a distinguerli.
- 2: Nel cuore della notte ti svegli e ti siedi sul letto col volto fra le mani: in questi giorni l'ansia cresce al buio, i pensieri cupi si moltiplicano come spade appese alla parete.
- 3: Adesso la mente non ti lascia dormire: rimugini, immagini il peggio, ingigantisci ogni timore e quello che ti racconti alle tre di notte ti sembra più vero della luce del giorno.

### capovolta

- 1: Il peggio dell'angoscia sta finendo: trovi il coraggio di affrontare le tue apprensioni. Ti liberi gradualmente da pensieri negativi che ti limitavano.
- 2: L'angoscia allenta la presa in questi giorni: dopo notti difficili riesci a parlarne con qualcuno, il peso si dimezza e le spade appese sopra il letto ti sembrano meno minacciose.
- 3: Oggi le paure notturne perdono forza: dici a parole ciò che rimuginavi in silenzio e scopri che, condiviso, l'incubo si riduce a una preoccupazione che puoi affrontare.

## Dieci di Spade

### dritta

- 1: Stai vivendo la conclusione di un ciclo molto impegnativo, toccando il punto più basso. Questa chiusura libera lo spazio per ripartire.
- 2: Sotto un cielo nero che all'orizzonte comincia a schiarire, in questi giorni tocchi il fondo: un ciclo doloroso si chiude del tutto e più in basso di così non puoi scendere.
- 3: Adesso una battaglia è finita davvero: hai dato tutto, le spade sono a terra e arrenderti a questa fine non è debolezza, è riconoscere che quel capitolo non chiede altro.

### capovolta

- 1: Senti che il peggio è ormai alle spalle e stai ritrovando un sollievo che ti permette di riprendere le forze con calma.
- 2: Ti rialzi da terra in questi giorni: di ciò che c'era prima non resta niente da salvare, così ricominci da zero con gesti lenti, mentre ogni movimento rimette in piedi qualcosa di tuo.
- 3: Oggi le spade si sfilano una a una dalla schiena: dopo la chiusura completa provi a muoverti, a fatica, con l'orizzonte che si rischiara e una ripresa che appartiene soltanto a te.

## Fante di Spade

### dritta

- 1: La tua mente è acuta e ti porta a osservare con vigilanza ogni dettaglio. Stai cercando di capire a fondo una situazione, ma è importante che tu scelga con cura le tue espressioni per evitare incomprensioni.
- 2: Sulla collina battuta dal vento, con la spada alzata, in questi giorni vigili: osservi ogni dettaglio con occhi acuti, raccogli informazioni e cerchi una verità prima che altri la nascondano.
- 3: Adesso la curiosità ti tiene all'erta: fai domande, ascolti ciò che si dice in giro e la tua lingua affilata vorrebbe già riferire ciò che hai scoperto.

### capovolta

- 1: Affronti le conseguenze di una comunicazione poco ponderata. Le tue affermazioni generano pettegolezzi o malintesi, impedendoti di esprimerti con chiarezza e autenticità.
- 2: Oggi le parole ti scappano più veloci dei pensieri: un pettegolezzo, una battuta tagliente, una notizia riferita senza verificarla e ciò che dici ferisce senza costruire niente.
- 3: In questo momento la tua mente è sparsa: raccogli dicerie, le ripeti, ti lasci prendere dalla smania di sapere tutto e la spada che porti si muove a vanvera.

## Cavaliere di Spade

### dritta

- 1: La tua rapidità mentale ti porta a prendere decisioni immediate, ma ricorda che la fretta può farti perdere la visione d'insieme. La prontezza d'azione è utile, ma richiede equilibrio per non travolgere.
- 2: Al galoppo contro il vento, con la spada levata, in questi giorni corri dritto allo scopo: decidi in fretta, agisci senza esitare e la tua mente rapida ti porta avanti più veloce di tutti.
- 3: Adesso ti lanci sulle tue idee come in una carica: sai cosa vuoi, lo dici senza giri e travolgi gli ostacoli, a volte anche le persone che ti stanno accanto.

### capovolta

- 1: La tendenza a reagire con fretta ti porta a esprimere pensieri pungenti o a compiere azioni sconsiderate. Rallentare ti permette di valutare meglio la situazione e le sue conseguenze.
- 2: Oggi la fretta ti fa perdere la testa: lanci parole affilate senza pensare, sproni il cavallo contro il vento e lasci dietro di te una scia di frasi che non volevi dire.
- 3: In questo momento corri senza guardare: la tua impazienza mentale ti spinge a reagire prima di capire, così ogni decisione presa al galoppo ti costringe poi a tornare sui tuoi passi.

## Regina di Spade

### dritta

- 1: La tua intelligenza e la tua onestà ti guidano a stabilire confini precisi. Pensi in modo nitido e la tua chiarezza di espressione ti protegge.
- 2: Con la spada dritta e una mano tesa verso l'orizzonte, in questi giorni pensi con nitore: dici il vero senza giri, tracci confini chiari e la tua franchezza ti protegge.
- 3: Adesso il tuo sguardo distingue: separi ciò che è giusto da ciò che è comodo, rispondi con onestà anche quando costa e il cielo limpido sopra di te somiglia alla tua mente.

### capovolta

- 1: Stai vivendo le conseguenze di una durezza che hai costruito intorno a te, un isolamento che ti impedisce di agire pienamente. Ammorbidire il tuo giudizio, a cominciare da quello verso di te, è essenziale per superare questo momento.
- 2: Oggi la tua lama si è fatta corazza: giudichi con durezza, a cominciare da te, mentre la solitudine in cui ti chiudi ti protegge da tutti, anche da chi vorrebbe consolarti.
- 3: In questo momento la tua franchezza ferisce: ogni parola è un taglio, tieni gli altri a distanza con l'ironia e intanto la spada che impugni si rivolge anche contro di te.

## Re di Spade

### dritta

- 1: Metti la tua mente al servizio del bene, usando la ragione per raggiungere l'equità in ogni situazione. Sei un punto di riferimento per chi cerca chiarezza e giustizia.
- 2: Con la spada dritta sul trono di pietra, in questi giorni decidi con equità: la ragione è al servizio del cuore e la tua parola chiara è un punto di riferimento per chi ti chiede consiglio.
- 3: Adesso sei tu a stabilire ciò che è giusto: valuti i fatti con logica, ascolti tutte le parti e la tua autorità mentale si fonda sull'etica più che sul potere.

### capovolta

- 1: La tua tendenza è di usare un'autorità dura che non tiene conto dei sentimenti. Questo rischia di compromettere i legami importanti e ti porta a vincere discussioni ma perdere affetto.
- 2: Oggi la tua logica dimentica le persone: decidi freddamente, imponi regole senza ascoltare e la ragione che ti dà forza vince le discussioni mentre perde i legami.
- 3: In questo momento la tua autorità si è fatta gelida: usi l'intelligenza come una lama per dominare, ti chiudi nel giudizio e chi ti sta intorno sente la durezza di chi comanda senza cuore.
