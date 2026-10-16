# LO SCHEDARIO: I REGISTRI DELLE CARTE, il metodo di Dora (voce FI.20)

Ordine FM voce 05, 12 ottobre 2026. Scritto da Code prima dei testi, resta nel repo accanto al corpus: senza, le posizioni diverse ricevono testi intercambiabili.

**Che cosa chiedono.** Per ogni carta e verso, di che cosa parla la carta in
ciascuno dei tre ambiti dell'argomento: amore (Amore e sentimenti), lavoro
(Lavoro e denaro), vita (Vita e cammino). Non è una posizione e non si
rivolge alla persona: nomina la materia, cioè le cose, le persone e i gesti
di cui la carta parla quando la domanda sta in quell'ambito. Fra 60 e 220
caratteri, senza il nome della carta nè il verso.

**Le gemelle: gli altri due ambiti della stessa carta.** Un registro
dell'amore che si potrebbe leggere nel lavoro cambiando una parola e'
caduto: deve nominare cose che stanno solo in quell'ambito (il legame, la
coppia, il desiderio; il denaro, il mestiere, i colleghi; il cammino, la
salute dell'anima, le scelte di vita, senza promesse sulla salute).

## Come si usa

Prima di scrivere i testi di questa posizione si scrive qui, carta per carta e
verso per verso, una riga sola nella sezione **Le carte**:

`- <Carta>, <dritta|capovolta>: AMORE <la materia> · LAVORO <la materia> · VITA <la materia>`

I tre testi della carta nascono dalla parte QUI e non toccano la parte NON. La
materia della carta viene dalla fonte dei significati
(`lib/core/tarot/tarot_card.dart`), i confini con le carte vicine dalla mappa
delle gemelle (`mappa_delle_gemelle.md`, solo gli scambi SOLIDI e DA GUARDARE).

## Come si misura

Ordine FM voce 05, la soglia la decide Code. Su un campione di testi scelto a
caso, lettori ciechi che non hanno scritto ricevono il testo e i nomi dei
tre ambiti e dicono a quale appartiene. **La
posizione è chiusa se i lettori riconoscono l'ambito giusto fra i tre in almeno
otto testi su dieci, in due giri con campioni diversi.** Sotto, si riscrivono
i testi caduti e si rifà il giro. Il risultato sta nel rapporto dell'ordine
FM.

## Le carte

- Il Matto, dritta: AMORE il legame che nasce senza calcoli, l'attrazione per chi è diverso, dichiararsi senza sapere come andrà · LAVORO il mestiere cominciato da zero, il salto fuori dal posto fisso, l'apprendistato · VITA la partenza, il viaggio senza mappa, la fiducia nel primo passo
- Il Matto, capovolta: AMORE la storia presa alla leggera, la fuga davanti all'impegno, l'avventura che non guarda l'altro · LAVORO le dimissioni d'impulso, il progetto lanciato senza conti · VITA lo slancio senza direzione, l'esitazione sull'orlo, la fuga travestita da coraggio
- Il Mago, dritta: AMORE la seduzione, la parola che conquista, il primo passo fatto davvero · LAVORO gli strumenti sul tavolo, il talento messo in opera, l'avvio di un'impresa · VITA la volontà che trasforma l'idea in gesto, l'abilità di cominciare
- Il Mago, capovolta: AMORE le promesse che non diventano gesti, il fascino che manipola · LAVORO il talento nel cassetto, le parole più grandi dei fatti, il raggiro · VITA lo scollamento fra intenzione e azione
- La Papessa, dritta: AMORE il sentimento taciuto, l'intesa senza parole, la riservatezza · LAVORO lo studio, i documenti riservati, il sapere accumulato in silenzio · VITA il silenzio, l'intuizione, le risposte che maturano nell'attesa
- La Papessa, capovolta: AMORE i segreti nella coppia, il sentire ignorato, la freddezza · LAVORO le informazioni nascoste, il chiasso che copre l'intuito · VITA il sentire interiore coperto dalla ragione e dal rumore
- L'Imperatrice, dritta: AMORE la sensualità, la cura, il desiderio di casa e di figli · LAVORO i progetti creativi che fioriscono, l'abbondanza, il raccolto · VITA la natura, il corpo, la fertilità della terra e dei giorni
- L'Imperatrice, capovolta: AMORE la cura che manca o che soffoca, l'affetto trascurato · LAVORO la creatività bloccata, il progetto forzato prima del tempo · VITA la fertilità ferma, la trascuratezza di sé
- L'Imperatore, dritta: AMORE il partner che protegge, il patto stabile, la casa con le sue regole · LAVORO l'autorità, il capo, l'organizzazione, i contratti solidi · VITA l'ordine, la disciplina, le fondamenta
- L'Imperatore, capovolta: AMORE il controllo geloso, la possessività, la rigidità · LAVORO il capo autoritario, la burocrazia che soffoca o la struttura che manca · VITA la regola che imprigiona, le fondamenta assenti
- Il Papa, dritta: AMORE il matrimonio, la promessa davanti agli altri, i valori condivisi · LAVORO il maestro, l'istituzione, la formazione, il consiglio di un esperto · VITA la tradizione, la fede, l'appartenenza a una comunità
- Il Papa, capovolta: AMORE la relazione fuori dalle convenzioni, le attese della famiglia rifiutate · LAVORO le regole dell'azienda messe in discussione, il mentore che delude · VITA il dogma lasciato, il senso cercato fuori dal sentiero
- Gli Amanti, dritta: AMORE l'unione, l'attrazione profonda, la scelta di una persona · LAVORO la società fra pari, il socio, la scelta fra due offerte secondo i valori · VITA il bivio, la scelta coerente con ciò in cui si crede
- Gli Amanti, capovolta: AMORE il disaccordo, il triangolo, la scelta rimandata fra due persone · LAVORO la collaborazione incrinata, i valori che stridono col mestiere · VITA il conflitto interiore fra desiderio e convinzione
- Il Carro, dritta: AMORE la conquista, la relazione che avanza, il trasloco insieme · LAVORO la carriera che corre, la promozione, il viaggio di lavoro · VITA la direzione presa, le forze opposte tenute in pugno
- Il Carro, capovolta: AMORE la relazione che sbanda, i due che tirano in versi opposti · LAVORO l'ambizione senza controllo, i progetti che vanno in direzioni opposte · VITA la corsa senza meta, il centro perso
- La Giustizia, dritta: AMORE la reciprocità, l'equilibrio del dare e dell'avere, l'onestà nella coppia · LAVORO i contratti, gli accordi firmati, le pratiche, la valutazione equa · VITA la causa e l'effetto, le scelte responsabili
- La Giustizia, capovolta: AMORE il torto non riconosciuto, le colpe date all'altro · LAVORO l'accordo sbilanciato, il conto in sospeso, la pratica ferma · VITA la conseguenza attribuita al caso, l'equilibrio che non torna
- L'Eremita, dritta: AMORE il tempo da soli, la ricerca di un legame profondo, la pausa dagli incontri · LAVORO lo studio solitario, la competenza approfondita, il consulente · VITA il ritiro, la lanterna, la ricerca interiore
- L'Eremita, capovolta: AMORE l'isolamento, il rifiuto dei legami, la chiusura · LAVORO la distanza dai colleghi, la diffidenza, il sapere tenuto per sé · VITA la solitudine che pesa e allontana
- La Ruota della Fortuna, dritta: AMORE l'incontro casuale, la svolta inattesa nel legame · LAVORO il cambio di situazione, l'occasione che gira, il ciclo degli affari · VITA i cicli, il destino, la svolta
- La Ruota della Fortuna, capovolta: AMORE la relazione ferma o che ricade negli stessi schemi · LAVORO lo stallo, il ritardo, la stagione bassa · VITA il ciclo bloccato, la sosta dentro il movimento
- La Forza, dritta: AMORE la passione governata con tenerezza, la pazienza con l'altro · LAVORO la tenacia, la calma con le persone difficili · VITA il coraggio dolce, l'istinto domato
- La Forza, capovolta: AMORE l'insicurezza, la gelosia, la durezza con l'altro · LAVORO la paura di non farcela, la fiducia nelle proprie capacità che cede · VITA il dominio perso, la durezza con sé
- L'Appeso, dritta: AMORE l'attesa, il sacrificio per l'altro, il punto di vista dell'altro · LAVORO il progetto sospeso, la pausa forzata, la prospettiva diversa · VITA la sospensione, il mondo visto a testa in giù
- L'Appeso, capovolta: AMORE il sacrificio che nessuno chiede, l'attesa che logora · LAVORO lo stallo, il rinvio senza fine · VITA la rinuncia per paura, scendere dall'albero
- La Morte, dritta: AMORE la fine di una storia, la relazione che cambia pelle · LAVORO la chiusura di un incarico, il cambio di settore · VITA la trasformazione, il lasciare andare
- La Morte, capovolta: AMORE la storia finita trattenuta, il ritorno all'ex · LAVORO il posto che non soddisfa più e da cui non si esce · VITA la resistenza al cambiamento
- La Temperanza, dritta: AMORE l'armonia, il compromesso, il riavvicinamento · LAVORO la mediazione, la squadra ben dosata, la pazienza · VITA la misura, l'equilibrio, il ritmo quotidiano
- La Temperanza, capovolta: AMORE gli eccessi, i due che non si parlano più · LAVORO la fretta, il sovraccarico, le spese senza misura · VITA lo squilibrio, il ritmo perso
- Il Diavolo, dritta: AMORE la passione ossessiva, la dipendenza affettiva, la gelosia · LAVORO il lavoro che incatena, i soldi come trappola, l'avidità · VITA le catene, le tentazioni, le abitudini che legano
- Il Diavolo, capovolta: AMORE la liberazione da un legame che toglieva aria · LAVORO l'uscita da un debito o da un impiego che soffocava · VITA la catena che si spezza, il nodo riconosciuto
- La Torre, dritta: AMORE la rottura improvvisa, la verità che esplode · LAVORO il crollo di un progetto, la ristrutturazione, il licenziamento · VITA lo sconvolgimento, la rivelazione
- La Torre, capovolta: AMORE la crisi rimandata, la tensione che non esplode · LAVORO il crollo evitato a fatica, la crisi trascinata · VITA la scossa rimandata, l'uscita faticosa dalle macerie
- La Stella, dritta: AMORE la speranza, la tenerezza dopo una delusione · LAVORO l'ispirazione, la vocazione, il progetto che ridà fiducia · VITA la quiete, la fiducia ritrovata, la luce dopo la tempesta
- La Stella, capovolta: AMORE lo scoraggiamento, la fiducia stanca · LAVORO l'ispirazione persa, il sogno professionale accantonato · VITA la speranza offuscata dalla nube
- La Luna, dritta: AMORE i dubbi, la gelosia, l'inganno o il fraintendimento · LAVORO le situazioni poco chiare, le informazioni incomplete · VITA l'inconscio, i sogni, le paure notturne
- La Luna, capovolta: AMORE i dubbi che si chiariscono, la gelosia che si sgonfia · LAVORO la confusione che si dirada, l'imbroglio che si scopre · VITA le paure che si ridimensionano alla luce
- Il Sole, dritta: AMORE la gioia condivisa, il legame mostrato a tutti · LAVORO il successo, il riconoscimento pubblico · VITA la vitalità, la chiarezza, l'infanzia
- Il Sole, capovolta: AMORE la gioia trattenuta, la coppia che fatica a mostrarsi · LAVORO il successo rimandato, l'entusiasmo calato · VITA la luce velata da un pensiero vecchio
- Il Giudizio, dritta: AMORE il ritorno di un amore, la rinascita del legame · LAVORO la chiamata, la vocazione, il bilancio del mestiere · VITA il risveglio, la rinascita
- Il Giudizio, capovolta: AMORE il bilancio rimandato, il rimpianto, i giudizi severi sull'altro · LAVORO l'occasione non colta, l'autocritica che paralizza · VITA la chiamata inascoltata
- Il Mondo, dritta: AMORE la pienezza, l'unione compiuta · LAVORO il traguardo, il progetto concluso, l'espansione all'estero · VITA il ciclo compiuto, il viaggio
- Il Mondo, capovolta: AMORE la relazione quasi compiuta, l'ultimo passo · LAVORO il progetto incompiuto, l'ultima consegna · VITA il cerchio quasi chiuso, il pezzo da integrare
- Asso di Bastoni, dritta: AMORE il colpo di fulmine, il desiderio che si accende · LAVORO l'idea nuova, l'avvio di un'impresa, la proposta che entusiasma · VITA la scintilla, l'impulso di cominciare
- Asso di Bastoni, capovolta: AMORE il desiderio spento, l'attrazione che tarda · LAVORO la partenza rimandata, l'idea soffocata dalla paura di sbagliare · VITA lo slancio bloccato
- Due di Bastoni, dritta: AMORE il progetto di vita a due, la relazione a distanza · LAVORO la pianificazione, l'espansione, i mercati lontani · VITA lo sguardo oltre il confine, la rotta da scegliere
- Due di Bastoni, capovolta: AMORE la paura di impegnarsi, il futuro della coppia confuso · LAVORO il piano incerto, la paura di osare · VITA la soglia che non si varca
- Tre di Bastoni, dritta: AMORE l'attesa di chi è lontano, la storia che si allarga · LAVORO le spedizioni, il commercio con l'estero, i risultati in arrivo · VITA l'orizzonte, la fiducia in ciò che si è avviato
- Tre di Bastoni, capovolta: AMORE l'altro che torna diverso da come lo si aspettava · LAVORO l'esito diverso dal previsto, il carico inatteso · VITA le aspettative da rileggere
- Quattro di Bastoni, dritta: AMORE il fidanzamento, le nozze, la casa nuova insieme · LAVORO il traguardo festeggiato, l'inaugurazione · VITA la festa, le radici, il ritorno a casa
- Quattro di Bastoni, capovolta: AMORE la festa rimandata, la convivenza che non comincia · LAVORO il traguardo non celebrato, l'inaugurazione sospesa · VITA la casa in cui non si entra
- Cinque di Bastoni, dritta: AMORE i litigi vivaci, la rivalità, i corteggiatori in gara · LAVORO la concorrenza, le riunioni accese, il confronto di idee · VITA la sfida, il misurarsi con gli altri
- Cinque di Bastoni, capovolta: AMORE le tensioni che covano, i litigi evitati · LAVORO i conflitti inutili, gli attriti lasciati marcire · VITA la stanchezza delle battaglie
- Sei di Bastoni, dritta: AMORE la conquista ammirata, l'orgoglio di stare insieme · LAVORO il riconoscimento, la promozione, il premio · VITA la vittoria che sfila, la fiducia degli altri
- Sei di Bastoni, capovolta: AMORE il bisogno di conferme, l'ammirazione che manca · LAVORO il merito non visto, la promozione che tarda · VITA il valore legato all'applauso
- Sette di Bastoni, dritta: AMORE il legame difeso contro chi lo osteggia · LAVORO la posizione difesa, la concorrenza tenuta a bada · VITA il coraggio sotto pressione, tenere il punto
- Sette di Bastoni, capovolta: AMORE la difensiva continua, la sensazione di assedio · LAVORO la pressione che travolge, le troppe battaglie · VITA scegliere dove resistere
- Otto di Bastoni, dritta: AMORE i messaggi rapidi, l'innamoramento veloce · LAVORO le notizie, le trattative che accelerano, i viaggi · VITA la velocità, gli eventi in corsa
- Otto di Bastoni, capovolta: AMORE i messaggi che non arrivano, la fretta che rovina · LAVORO i ritardi, i contrattempi, le consegne in affanno · VITA la corsa frenata
- Nove di Bastoni, dritta: AMORE il legame che resiste alle prove, la fedeltà · LAVORO la tenacia nell'ultimo tratto, il progetto quasi finito · VITA la resistenza, lo scudo
- Nove di Bastoni, capovolta: AMORE la diffidenza verso chi si avvicina, le ferite vecchie · LAVORO la sospettosità coi colleghi, la guardia sempre alzata · VITA la difesa irrigidita
- Dieci di Bastoni, dritta: AMORE il peso della relazione portato da uno solo · LAVORO le troppe responsabilità, gli straordinari · VITA il carico sulle spalle
- Dieci di Bastoni, capovolta: AMORE i doveri posati, la coppia che si alleggerisce · LAVORO i compiti delegati, il carico ridistribuito · VITA il fardello lasciato
- Fante di Bastoni, dritta: AMORE il corteggiamento giocoso, il messaggio audace · LAVORO la proposta fresca, l'apprendista entusiasta · VITA la curiosità, l'esplorazione
- Fante di Bastoni, capovolta: AMORE l'entusiasmo che si spegne presto, le cotte passeggere · LAVORO le idee abbandonate a metà · VITA l'entusiasmo disperso
- Cavaliere di Bastoni, dritta: AMORE la passione travolgente, la storia avventurosa · LAVORO l'iniziativa audace, il trasferimento, il cambio rapido · VITA l'avventura, la partenza
- Cavaliere di Bastoni, capovolta: AMORE la storia bruciata in fretta, l'impazienza · LAVORO la foga che spreca energie, i progetti lasciati · VITA lo slancio senza rotta
- Regina di Bastoni, dritta: AMORE il fascino magnetico, il calore che attrae · LAVORO la sicurezza in pubblico, la leadership calda · VITA il carisma, la generosità
- Regina di Bastoni, capovolta: AMORE la gelosia, la rivalità con chi sta accanto · LAVORO la competizione coi colleghi, il bisogno di brillare · VITA la fiamma insicura
- Re di Bastoni, dritta: AMORE il partner che ispira e guida, la generosità · LAVORO l'imprenditore, la visione, il comando con l'esempio · VITA la visione che apre strade
- Re di Bastoni, capovolta: AMORE l'impazienza, l'arroganza nel legame · LAVORO il capo impulsivo che non ascolta · VITA il comando che travolge
- Asso di Coppe, dritta: AMORE l'amore nuovo, l'apertura del cuore · LAVORO il lavoro che emoziona, l'ambiente accogliente · VITA la grazia, la sorgente delle emozioni
- Asso di Coppe, capovolta: AMORE l'emozione trattenuta, l'amore rimandato per paura · LAVORO l'entusiasmo che non sgorga, l'ambiente freddo · VITA la sorgente chiusa
- Due di Coppe, dritta: AMORE l'unione, il patto d'amore, l'intesa a due · LAVORO la collaborazione armoniosa, l'accordo fra pari · VITA il riconoscersi, l'armonia
- Due di Coppe, capovolta: AMORE il malinteso, la distanza fra due che si amano · LAVORO l'accordo che si incrina, il socio distante · VITA l'equilibrio da ritrovare
- Tre di Coppe, dritta: AMORE la festa con gli amici, l'incontro in compagnia · LAVORO il brindisi di squadra, la rete di relazioni · VITA l'amicizia, la comunità
- Tre di Coppe, capovolta: AMORE il terzo incomodo, l'eccesso di svago · LAVORO le chiacchiere d'ufficio, il gruppo di facciata · VITA gli eccessi, le amicizie da curare
- Quattro di Coppe, dritta: AMORE la noia, l'offerta d'affetto non vista · LAVORO la proposta rifiutata, l'apatia · VITA la sazietà, il torpore
- Quattro di Coppe, capovolta: AMORE l'interesse che si risveglia, l'apertura a qualcuno · LAVORO la motivazione che torna, l'offerta finalmente vista · VITA il risveglio dal torpore
- Cinque di Coppe, dritta: AMORE la delusione, la rottura, il rimpianto · LAVORO l'occasione persa, la perdita che pesa · VITA il lutto, lo sguardo fisso su ciò che è andato
- Cinque di Coppe, capovolta: AMORE il perdono, la ripresa dopo la rottura · LAVORO la ripartenza dopo un fallimento · VITA l'accettazione, lo sguardo che si rialza
- Sei di Coppe, dritta: AMORE l'amore di gioventù, il ritorno di chi si è amato · LAVORO il mestiere che riporta all'infanzia, i vecchi contatti · VITA la nostalgia, i ricordi, la casa natale
- Sei di Coppe, capovolta: AMORE l'ex idealizzato, il paragone col passato · LAVORO i metodi superati, la nostalgia del vecchio posto · VITA il passato che trattiene
- Sette di Coppe, dritta: AMORE le fantasie, le illusioni, i troppi corteggiatori · LAVORO le troppe opzioni, i progetti campati in aria · VITA i sogni, le possibilità
- Sette di Coppe, capovolta: AMORE la chiarezza su chi si desidera · LAVORO la scelta fra le opzioni, la nebbia che si dirada · VITA il desiderio vero messo a fuoco
- Otto di Coppe, dritta: AMORE l'abbandono di un legame che non nutre · LAVORO le dimissioni, la ricerca di un senso più alto · VITA la partenza silenziosa, il pellegrinaggio
- Otto di Coppe, capovolta: AMORE l'indecisione fra restare e andare · LAVORO il dubbio sul lasciare il posto · VITA il piede sulla soglia
- Nove di Coppe, dritta: AMORE l'appagamento, il desiderio esaudito · LAVORO la soddisfazione, l'obiettivo raggiunto · VITA il benessere, il piacere, l'augurio avverato
- Nove di Coppe, capovolta: AMORE la relazione di facciata, i piaceri che non colmano · LAVORO il successo vuoto, la vanità · VITA l'appagamento vuoto
- Dieci di Coppe, dritta: AMORE la famiglia felice, la casa piena d'amore · LAVORO l'impresa di famiglia, l'ambiente sereno · VITA la gratitudine, l'arcobaleno
- Dieci di Coppe, capovolta: AMORE le tensioni di casa, la famiglia divisa · LAVORO i dissidi nell'impresa familiare · VITA la serenità del gruppo incrinata
- Fante di Coppe, dritta: AMORE il messaggio d'amore, la timidezza tenera · LAVORO il lavoro creativo, l'arte, l'apprendistato sensibile · VITA la poesia, la sensibilità
- Fante di Coppe, capovolta: AMORE la suscettibilità, il cuore chiuso, l'infatuazione infantile · LAVORO la permalosità, il blocco creativo · VITA la sensibilità ferita
- Cavaliere di Coppe, dritta: AMORE la proposta romantica, il corteggiamento, l'invito · LAVORO l'offerta che arriva con garbo, la professione artistica · VITA il cuore in viaggio, la bellezza seguita
- Cavaliere di Coppe, capovolta: AMORE le promesse vaghe, il seduttore incostante · LAVORO le offerte che non si concretizzano · VITA le illusioni senza radici
- Regina di Coppe, dritta: AMORE l'empatia, la tenerezza, la comprensione profonda · LAVORO le professioni di cura e di ascolto, l'intuito coi clienti · VITA l'intuito, la sensibilità come forza
- Regina di Coppe, capovolta: AMORE la dipendenza emotiva, l'annullarsi nell'altro · LAVORO l'assorbire gli umori dell'ufficio · VITA l'emozione che sommerge
- Re di Coppe, dritta: AMORE il partner maturo, il porto sicuro · LAVORO la guida diplomatica, il mediatore, il consigliere · VITA la calma del cuore, la maturità affettiva
- Re di Coppe, capovolta: AMORE gli sbalzi d'umore, il ricatto affettivo · LAVORO il capo lunatico, la manipolazione emotiva · VITA il cuore senza governo
- Asso di Denari, dritta: AMORE il legame concreto, la casa, il progetto da costruire insieme · LAVORO l'offerta di lavoro, il primo stipendio, l'investimento · VITA il seme d'oro, le basi solide
- Asso di Denari, capovolta: AMORE l'occasione trascurata, l'interesse materiale · LAVORO l'opportunità persa, l'investimento valutato male · VITA l'occasione che sfuma
- Due di Denari, dritta: AMORE la relazione da conciliare con mille impegni · LAVORO il doppio lavoro, i conti che si fanno tornare · VITA l'adattamento, la leggerezza del giocoliere
- Due di Denari, capovolta: AMORE la coppia trascurata per troppi impegni · LAVORO le scadenze accavallate, i conti che sfuggono · VITA il ritmo rotto, le priorità
- Tre di Denari, dritta: AMORE la coppia che costruisce, la ristrutturazione della casa · LAVORO la collaborazione, la competenza riconosciuta, il cantiere · VITA l'opera comune
- Tre di Denari, capovolta: AMORE i ruoli confusi in coppia, i progetti comuni che non ingranano · LAVORO la squadra stonata, i compiti poco chiari · VITA la collaborazione da ricucire
- Quattro di Denari, dritta: AMORE la possessività, la sicurezza affettiva · LAVORO il risparmio, il controllo del bilancio · VITA il bisogno di sicurezza, il conservare
- Quattro di Denari, capovolta: AMORE la gelosia del possesso, l'affetto razionato · LAVORO l'avarizia, la paura di spendere o lo sperpero · VITA la presa da allentare
- Cinque di Denari, dritta: AMORE la solitudine, il sentirsi esclusi dal calore · LAVORO la difficoltà economica, la perdita del lavoro · VITA l'inverno, il freddo fuori dalla porta
- Cinque di Denari, capovolta: AMORE il ritorno del sostegno, la coppia che si riscalda · LAVORO la ripresa economica, l'aiuto trovato · VITA il ritorno al caldo
- Sei di Denari, dritta: AMORE il dare e ricevere equilibrato · LAVORO lo stipendio giusto, il prestito, la beneficenza · VITA la generosità che circola
- Sei di Denari, capovolta: AMORE lo squilibrio, chi dà troppo a chi non ricambia · LAVORO i debiti, il pagamento ingiusto · VITA il dare sbilanciato
- Sette di Denari, dritta: AMORE la relazione che matura con pazienza · LAVORO l'investimento a lungo termine, la valutazione dei risultati · VITA il raccolto atteso
- Sette di Denari, capovolta: AMORE l'impazienza, l'impegno non ricambiato · LAVORO lo sforzo mal ripagato, il rendimento scarso · VITA la fretta del raccolto
- Otto di Denari, dritta: AMORE la cura quotidiana del legame, l'impegno · LAVORO il mestiere, la formazione, l'apprendistato, la qualità · VITA la pratica paziente
- Otto di Denari, capovolta: AMORE la routine senza slancio · LAVORO la monotonia, il lavoro fatto male · VITA il gesto ripetuto senza senso
- Nove di Denari, dritta: AMORE l'autonomia nella coppia, il bastare a sé · LAVORO l'indipendenza economica, l'agiatezza meritata · VITA il giardino, il piacere della solitudine
- Nove di Denari, capovolta: AMORE la dipendenza economica dall'altro, il lusso per apparire · LAVORO le spese eccessive, l'agiatezza che vacilla · VITA l'indipendenza da curare
- Dieci di Denari, dritta: AMORE la famiglia allargata, il matrimonio stabile · LAVORO l'azienda di famiglia, il patrimonio, gli affari duraturi · VITA le radici, le generazioni
- Dieci di Denari, capovolta: AMORE le liti di famiglia sui beni · LAVORO il patrimonio conteso, la società familiare in crisi · VITA le radici in conflitto
- Fante di Denari, dritta: AMORE il corteggiamento lento e serio · LAVORO lo studio, il tirocinio, il progetto concreto · VITA l'apprendimento
- Fante di Denari, capovolta: AMORE l'impegno promesso e non mantenuto · LAVORO lo studio interrotto, la distrazione · VITA la promessa rimandata
- Cavaliere di Denari, dritta: AMORE il partner affidabile, la costanza · LAVORO il metodo, la routine solida, il lavoratore fidato · VITA il passo costante
- Cavaliere di Denari, capovolta: AMORE la relazione ferma, la prudenza che rimanda tutto · LAVORO l'immobilismo, la carriera inceppata · VITA il passo bloccato
- Regina di Denari, dritta: AMORE la cura concreta, la casa accogliente · LAVORO la gestione pratica, l'amministrazione, la cura dei conti · VITA la concretezza generosa
- Regina di Denari, capovolta: AMORE chi cura tutti tranne sé · LAVORO la dispersione fra casa e lavoro · VITA la cura dispersa
- Re di Denari, dritta: AMORE il partner solido e generoso · LAVORO l'imprenditore di successo, il patrimonio ben gestito · VITA la prosperità saggia
- Re di Denari, capovolta: AMORE l'amore misurato coi soldi, il possesso · LAVORO l'avidità, il capitale immobile · VITA il possesso che irrigidisce
- Asso di Spade, dritta: AMORE la verità detta, la chiarezza nel legame · LAVORO l'idea brillante, la decisione netta · VITA la lucidità, il taglio deciso
- Asso di Spade, capovolta: AMORE le parole taglienti, l'incomprensione · LAVORO le idee confuse, la decisione sbagliata · VITA la mente annebbiata
- Due di Spade, dritta: AMORE l'indecisione fra due persone, il cuore bendato · LAVORO lo stallo, la scelta rimandata · VITA l'equilibrio precario, la benda sugli occhi
- Due di Spade, capovolta: AMORE la verità che riaffiora, la scelta sentimentale che si impone · LAVORO il blocco che si scioglie · VITA la benda che cade
- Tre di Spade, dritta: AMORE il cuore spezzato, il tradimento, la separazione · LAVORO la delusione professionale, la critica che ferisce · VITA il dolore, la pioggia
- Tre di Spade, capovolta: AMORE il perdono, la ferita che si chiude · LAVORO la ripresa dopo una delusione · VITA il dolore che sfuma
- Quattro di Spade, dritta: AMORE la pausa di riflessione · LAVORO le ferie, il riposo, la sospensione · VITA la quiete, il recupero
- Quattro di Spade, capovolta: AMORE la ripresa dopo la pausa · LAVORO il ritorno all'attività · VITA il risveglio dalla sosta
- Cinque di Spade, dritta: AMORE il litigio vinto che costa il legame, l'orgoglio · LAVORO la concorrenza sleale, la vittoria amara · VITA il conflitto, l'orgoglio
- Cinque di Spade, capovolta: AMORE la riconciliazione, deporre le armi · LAVORO la pace coi colleghi, il compromesso · VITA la pace da ricucire
- Sei di Spade, dritta: AMORE l'allontanamento da una storia agitata · LAVORO il trasferimento, il cambio di sede · VITA la traversata, il trasloco
- Sei di Spade, capovolta: AMORE il distacco difficile, il cuore che resta indietro · LAVORO il trasferimento faticoso · VITA la partenza difficile
- Sette di Spade, dritta: AMORE la discrezione, il segreto, la strategia · LAVORO l'astuzia, la diplomazia, la trattativa · VITA l'ingegno, la prudenza
- Sette di Spade, capovolta: AMORE l'inganno scoperto, la bugia che pesa · LAVORO il furto di idee, la frode che viene a galla · VITA la coscienza da liberare
- Otto di Spade, dritta: AMORE il legame in cui ci si sente prigionieri · LAVORO il lavoro che sembra una gabbia, la paura di cambiare · VITA i pensieri che legano
- Otto di Spade, capovolta: AMORE la liberazione da un legame che imprigionava · LAVORO la via d'uscita, la nuova possibilità · VITA le corde che cadono
- Nove di Spade, dritta: AMORE l'ansia per il legame, i pensieri gelosi notturni · LAVORO la preoccupazione, le notti insonni per il lavoro · VITA l'angoscia della notte
- Nove di Spade, capovolta: AMORE la paura che si allenta, il dialogo · LAVORO l'ansia che cala, il problema condiviso · VITA l'alba dopo l'incubo
- Dieci di Spade, dritta: AMORE la fine dolorosa, il fondo toccato · LAVORO il fallimento, la chiusura completa · VITA la resa, la fine di una battaglia
- Dieci di Spade, capovolta: AMORE il rialzarsi dopo la fine · LAVORO la ripartenza da zero · VITA la risalita
- Fante di Spade, dritta: AMORE la curiosità, il sospetto, il controllo dei messaggi · LAVORO la vigilanza, la ricerca, le informazioni · VITA la mente curiosa
- Fante di Spade, capovolta: AMORE i pettegolezzi, le parole pungenti · LAVORO le maldicenze, lo spionaggio · VITA la lingua affilata
- Cavaliere di Spade, dritta: AMORE la dichiarazione diretta, la relazione impetuosa · LAVORO l'azione rapida, la decisione netta · VITA la determinazione, la carica
- Cavaliere di Spade, capovolta: AMORE le parole lanciate senza pensare, la fretta · LAVORO la decisione affrettata, l'aggressività · VITA la foga imprudente
- Regina di Spade, dritta: AMORE la franchezza, i confini chiari · LAVORO l'analisi, il giudizio lucido, l'indipendenza professionale · VITA la lucidità sincera
- Regina di Spade, capovolta: AMORE la freddezza, la solitudine come corazza · LAVORO la critica spietata · VITA la freddezza difensiva
- Re di Spade, dritta: AMORE il partner leale e razionale · LAVORO l'autorità competente, l'avvocato, il consulente · VITA l'etica, il giudizio giusto
- Re di Spade, capovolta: AMORE la freddezza, il rigore che ferisce · LAVORO il capo duro, l'autorità senza cuore · VITA il rigore senza cuore
