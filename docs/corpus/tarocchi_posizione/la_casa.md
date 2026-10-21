# LA POSIZIONE: LA CASA

La tua casa, nella Croce Celtica.

**Fonte da riempire.** Per ogni carta e per ogni verso tre varianti dello
stesso scheletro, `- 1:`, `- 2:`, `- 3:`, scritte da Code dall'ordine FM del 12 ottobre 2026
(prima dall'Architetto, ordine FI, aggiunta A1 e A4), seguendo
`schedario_la_casa.md`. Una riga vuota e' un testo che non c'e' ancora. Una
variante e' piena in tutte le 156 carte-verso o vuota in tutte: a meta', il
tool si ferma e nomina le righe che mancano.

**Le tre varianti vengono dall'ordine FM del 12 ottobre 2026**, scritte da Code
dopo lo schedario `schedario_la_casa.md`, che dice carta per carta che cosa la
posizione chiede e che cosa appartiene alla gemella, e passate testo per testo
dai controlli dello strumento con `tool/riempi_la_posizione.py`.

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

- 1: Intorno a te la gente è in partenza: chi cambia casa, chi lascia un impiego, chi riempie una bisaccia e va. Quel passo leggero arriva alla tua porta e nessuno ti chiede di restare.
- 2: Nella tua cerchia soffia un'aria da strada aperta: amici che ridono dei programmi, parenti che improvvisano, un ambiente che non pesa e lascia libero chi ci vive accanto, compreso te.
- 3: Chi ti sta vicino vive con poco bagaglio e molta fiducia, come chi cammina guardando il cielo. La tua casa somiglia a un crocevia più che a una fortezza: si entra, si esce, si riparte.

### capovolta

- 1: Qualcuno della tua cerchia cammina verso il ciglio senza guardare dove mette i piedi: una decisione presa di slancio in famiglia o al lavoro rischia di trascinare anche te oltre l'orlo.
- 2: Nell'ambiente che frequenti si cambia idea ogni settimana: progetti lanciati e mollati, colpi di testa scambiati per coraggio. Il clima intorno a te premia l'impulso più della direzione.
- 3: Fra le persone di casa circola un'agitazione senza meta, come un cane che abbaia e corre in tondo. Ti tirano per la manica verso partenze che nessuno ha pensato fino in fondo.

## Il Mago

### dritta

- 1: Intorno a te c'è chi sa fare e mette gli attrezzi sul tavolo: un collega abile, un amico pratico, un contatto che apre porte. L'ambiente ti offre mezzi concreti, basta allungare la mano verso il banco.
- 2: Nella tua cerchia lavora una persona di talento, capace di trasformare un'idea in un gesto: la sua destrezza fa girare le cose anche per te e il posto dove vivi diventa una bottega.
- 3: Le persone che ti circondano hanno strumenti, competenze, conoscenze giuste al momento giusto. Sul tavolo comune ci sono la bacchetta, la coppa, la lama e la moneta: tocca a chi le sa usare.

### capovolta

- 1: Vicino a te parla bene qualcuno che poi non fa: promesse brillanti, progetti illustrati con grande abilità, mani che restano ferme. Nel tuo ambiente le parole valgono più dei fatti.
- 2: Nella cerchia che frequenti c'è un illusionista gentile: incanta col discorso, sposta l'attenzione, ti convince per una sera. Gli attrezzi sul suo tavolo non portano segni d'uso.
- 3: Chi ti circonda ha talento e lo lascia nel cassetto, oppure lo usa per manovrare. L'ambiente che ti sta intorno chiede di distinguere fra chi sa fare e chi sa soltanto mostrarsi capace.

## La Papessa

### dritta

- 1: Intorno a te vive una persona discreta che capisce senza domandare: una nonna, un'amica silenziosa, una collega che osserva. La sua presenza quieta tiene la casa più saggia di quanto sembri.
- 2: Nella tua cerchia le cose importanti non si gridano: si intuiscono, passano negli sguardi, restano tra le pieghe di un velo. È un ambiente riservato che ti chiede di ascoltare più che di chiedere.
- 3: Fra le persone di casa custodisce un sapere qualcuno che tiene il libro chiuso in grembo: non lo apre per tutti e aspetta che per te arrivi il momento giusto di leggerlo.

### capovolta

- 1: Nell'ambiente intorno a te c'è un segreto che tutti conoscono e nessuno nomina: il chiacchiericcio copre una verità di famiglia o d'ufficio che sta sotto il velo da troppo tempo.
- 2: Chi ti sta vicino preferisce il rumore al silenzio: discorsi, radio accese, spiegazioni che soffocano il presentimento di tutti. La tua casa fatica a sentire ciò che già sa.
- 3: Fra la gente che frequenti qualcuno trattiene un'informazione, la tiene sotto il manto per sentirsi al sicuro. Quella riservatezza è diventata reticenza e pesa sulla tua faccenda.

## L'Imperatrice

### dritta

- 1: Intorno a te c'è una figura che nutre: cucina, accoglie, fa crescere le piante sul davanzale e le persone in casa. Il tuo ambiente in questo momento è un campo di grano che matura.
- 2: Nella tua cerchia qualcosa fiorisce: una gravidanza, un giardino, un progetto comune che prende forma. La casa in cui vivi è generosa e ti offre terra buona dove seminare.
- 3: Le persone che hai vicino ti circondano di abbondanza tranquilla, senza misurare: tavole piene, abbracci, porte aperte. Un ambiente materno ti sostiene e lascia sbocciare le cose a loro tempo.

### capovolta

- 1: Vicino a te qualcuno accudisce fino a soffocare: decide cosa mangi, come ti vesti, quando riposi. La cura che arriva dalla tua casa è diventata una serra troppo calda.
- 2: Nell'ambiente che ti ospita nessuno annaffia più niente: i progetti comuni seccano, la casa ha perso il gusto di accogliere. Il terreno intorno a te resta fertile e incolto.
- 3: Fra chi ti circonda c'è fretta di raccogliere ciò che non è maturo: genitori, soci o amici che tirano le piantine per farle crescere prima. Il clima di casa tua forza i tempi.

## L'Imperatore

### dritta

- 1: Intorno a te c'è una figura che regge: un padre, un capo, un'istituzione con regole chiare. Quel trono solido fa da muro maestro alla tua casa e ti lascia costruire al riparo.
- 2: Nel tuo ambiente ogni cosa ha il suo posto e qualcuno risponde dell'insieme. Orari, ruoli, confini: la cornice che gli altri tengono salda ti protegge più di quanto pensi.
- 3: Chi ti sta accanto oggi porta autorità e la usa per proteggere: in famiglia o al lavoro c'è una mano ferma che decide. La struttura che ti circonda è di pietra, non di carta.

### capovolta

- 1: Vicino a te un'autorità stringe troppo: un capo che controlla ogni passo, un genitore che detta legge. La casa o l'ufficio in cui vivi ha più regole che respiro.
- 2: Nel tuo ambiente il trono è vuoto: nessuno si prende la responsabilità, le decisioni rimbalzano e le fondamenta comuni scricchiolano. Ti manca intorno qualcuno che regga.
- 3: Fra le persone che ti circondano il comando è diventato possesso: chi decide non protegge più, sorveglia. Le mura della tua casa tengono fermo invece di tenere in piedi.

## Il Papa

### dritta

- 1: Intorno a te c'è una comunità con le sue usanze: una famiglia che si riunisce la domenica, un gruppo, una scuola. Un consigliere più anziano ti offre la sua mano benedicente.
- 2: Nella tua cerchia c'è un maestro, qualcuno da cui andare a chiedere: un mentore, un insegnante, una persona di fede. Il suo sapere antico tiene insieme chi ti sta vicino.
- 3: Le persone di casa ti trasmettono riti, ricorrenze, regole tramandate che danno appartenenza. Fra gli altri hai un posto in una tradizione che viene da lontano e ti accoglie.

### capovolta

- 1: Nel tuo ambiente qualcuno ti spiega come si deve fare: le convenzioni di famiglia, le abitudini dell'ufficio, il si è sempre fatto così. Quelle regole condivise ti vanno strette.
- 2: Chi ti circonda ripete formule che hanno perso il senso: un gruppo, una chiesa, un club dove conta l'apparenza. La tua cerchia ti chiede obbedienza più che appartenenza.
- 3: Fra le persone vicine qualcuno fa da guida e pretende fedeltà: un consigliere che non ascolta, un'istituzione che giudica chi esce dal sentiero. Intorno a te la tradizione pesa.

## Gli Amanti

### dritta

- 1: Intorno a te c'è un legame che conta: una coppia vicina, una persona amata nella tua cerchia, un affetto che dà colore alla casa. Quell'unione ti mette davanti a ciò in cui credi davvero.
- 2: Nel tuo ambiente qualcuno ti tende la mano sotto un cielo aperto: un partner, un socio, un'amicizia che somiglia a un patto. Gli altri ti offrono un'alleanza e con lei una scelta di valori.
- 3: Le persone che ami fanno parte della faccenda più di quanto credi: la loro presenza accanto a te, sincera come in un giardino, pesa sulla direzione che prendi.

### capovolta

- 1: Nella tua cerchia due persone care non vanno d'accordo e ognuna ti vuole dalla sua parte. Le lealtà divise di casa ti tirano per le braccia come due rami dello stesso albero.
- 2: Vicino a te una coppia attraversa un momento storto: genitori, amici, soci che hanno smesso di guardarsi. Il loro disaccordo riempie le stanze che abiti e chiede a te di schierarti.
- 3: Fra chi ti circonda l'amore e la convenienza tirano in direzioni diverse: si promette una cosa e se ne vuole un'altra. Il clima affettivo del tuo ambiente manca di sincerità.

## Il Carro

### dritta

- 1: Intorno a te tutto si muove e chi ti sta vicino tira avanti con decisione: una squadra che vince, un gruppo che ha una meta. Sali sul loro carro e ti porta lontano.
- 2: Nel tuo ambiente regna la competizione sana: colleghi determinati, parenti che non si fermano davanti agli ostacoli. Le redini di molti sono in mani salde e questo ti spinge.
- 3: Chi ti circonda sa tenere insieme spinte opposte e conduce con mano ferma, come un auriga fra due sfingi. La tua cerchia in questo periodo avanza, compatta, verso un traguardo comune.

### capovolta

- 1: Nel tuo ambiente ognuno tira dalla sua parte e nessuno tiene le redini: in famiglia o al lavoro il veicolo comune sbanda e ti trascina dove non hai deciso di andare.
- 2: Intorno a te corrono tutti e nessuno sa verso dove: un ufficio in affanno, una casa piena di impegni che si scontrano. Le due sfingi davanti al carro guardano in direzioni opposte.
- 3: Fra le persone che frequenti qualcuno vuole vincere a ogni costo e travolge chi gli sta accanto. La spinta del gruppo che ti circonda non ha più un auriga che la governi.

## La Giustizia

### dritta

- 1: Intorno a te le regole valgono per tutti: chi ti sta vicino pesa con equità, i conti fra te e gli altri sono in ordine. Il tuo ambiente tiene la bilancia ferma e la spada dritta.
- 2: Nella tua cerchia c'è una persona corretta che giudica con lucidità, senza favori: un capo onesto, un parente imparziale. La sua presenza mette ognuno davanti alle proprie responsabilità.
- 3: Le persone di casa e di lavoro si comportano con chiarezza: patti scritti, promesse mantenute, meriti riconosciuti. Ti muovi in un ambiente dove ciò che dai torna con giusta misura.

### capovolta

- 1: Nel tuo ambiente i piatti della bilancia sono truccati: c'è chi riceve più del dovuto e chi paga per altri. Un trattamento ingiusto fra le persone vicine ricade anche su di te.
- 2: Intorno a te un conto resta in sospeso fra gli altri: un torto mai riparato, una spartizione mai chiarita. Quel debito comune pesa sulla tua faccenda anche se non porta il tuo nome.
- 3: Fra chi ti circonda si usano due pesi e due misure: regole severe per alcuni, indulgenti per altri. Il luogo in cui vivi o lavori ha perso il senso dell'equilibrio.

## L'Eremita

### dritta

- 1: Intorno a te c'è una persona saggia e appartata che illumina senza imporsi: un anziano, un maestro, un amico che parla poco. La sua lanterna rischiara anche il tuo pezzo di strada.
- 2: Nel tuo ambiente le persone ti lasciano spazio e silenzio: una casa tranquilla, un lavoro appartato, una cerchia piccola che non pretende. Gli altri rispettano il tuo raccoglimento.
- 3: Chi ti sta vicino in questo periodo vive in disparte, su una cima, col bastone e la luce in mano. Il luogo in cui abiti somiglia a un rifugio di montagna più che a una piazza.

### capovolta

- 1: Nella tua cerchia qualcuno si chiude e si allontana: un parente che non risponde, un amico che si è ritirato. La sua distanza raffredda le stanze che condividi con lui.
- 2: Intorno a te ognuno vive nella propria stanza con la porta chiusa: si cena in orari diversi, ci si incrocia nei corridoi. L'ambiente che abiti è diventato un insieme di solitudini.
- 3: Fra le persone che frequenti la riservatezza si è fatta isolamento: chi dovrebbe illuminare tiene la lanterna sotto il mantello. Ti manca intorno qualcuno che faccia luce.

## La Ruota della Fortuna

### dritta

- 1: Intorno a te le cose girano: un trasferimento, una riorganizzazione, qualcuno che sale e qualcun altro che scende. La sorte della tua cerchia cambia e porta con sé anche la tua faccenda.
- 2: Nel tuo ambiente sta per ruotare un ciclo: nuove persone entrano, altre escono, gli equilibri si spostano. Le circostanze esterne ti offrono una svolta che non dipende da te.
- 3: Chi ti circonda vive un giro favorevole: un parente che riprende fiato, un'azienda che cresce, una casa che si rinnova. Quella ruota che gira fuori di te spinge anche il tuo carro.

### capovolta

- 1: Nell'ambiente che ti circonda il giro si è inceppato: decisioni ferme, un'azienda che rallenta, una famiglia bloccata nello stesso punto. Le circostanze esterne frenano la tua faccenda.
- 2: Intorno a te il vento gira storto: imprevisti in casa, cambi di umore nei capi, piani altrui che saltano. Ti trovi su una ruota che altri fanno girare in senso contrario.
- 3: Fra le persone che frequenti c'è chi resiste a ogni cambiamento e tiene ferma la ruota con le mani. Il clima comune ti costringe a una sosta che non hai scelto.

## La Forza

### dritta

- 1: Intorno a te c'è una persona paziente che sa calmare chi ruggisce: con mano gentile apre e chiude la bocca del leone di casa. La sua mitezza tiene a bada le tensioni del tuo ambiente.
- 2: Nella tua cerchia gli scatti vengono accolti con dolcezza: nessuno urla, nessuno risponde col pugno. Ti muovi in un ambiente dove la fermezza tenera vince sull'aggressività.
- 3: Chi ti sta vicino ha coraggio senza durezza: un genitore, un collega, un amico che sa reggere i caratteri difficili. Il luogo in cui vivi è addomesticato da una calma che non cede.

### capovolta

- 1: Nel tuo ambiente c'è un leone lasciato libero: qualcuno che urla, prepotenze tollerate, scatti che nessuno ferma. La belva di casa morde e tu ne senti i denti.
- 2: Intorno a te chi dovrebbe calmare usa la stretta: un capo che impone, un parente che schiaccia. La mitezza ha lasciato il posto alla prepotenza fra le persone che frequenti.
- 3: Fra la gente vicina le tensioni covano senza nessuno che le domi: nervi scoperti, rabbie trattenute a fatica. Ti tocca abitare un posto dove la pazienza si è esaurita.

## L'Appeso

### dritta

- 1: Intorno a te le decisioni sono sospese: si aspetta un parere, una firma altrui. L'ambiente ti tiene in attesa e ti costringe a guardare le cose dal verso opposto.
- 2: Nella tua cerchia c'è chi ha scelto di fermarsi e la sua calma ribalta il modo in cui tutti vedono la faccenda: ti mostra un'angolazione che non avresti cercato.
- 3: Chi ti circonda in questo periodo non si muove e non ti spinge: una famiglia in attesa, un ufficio che rimanda, un tempo sospeso come una foglia ferma nell'aria. Ti lasciano guardare.

### capovolta

- 1: Nel tuo ambiente qualcuno ti chiede sacrifici che non servono a nessuno: rinunce imposte, attese senza scopo, pazienze pretese per abitudine. Gli altri ti tengono in sospeso per comodità.
- 2: Intorno a te lo stallo non insegna più niente: riunioni che non decidono, parenti che rimandano da mesi. Il ramo a cui la tua cerchia è legata ha smesso di dare frutti.
- 3: Fra le persone che frequenti c'è chi fa la vittima e appende tutti alla propria immobilità. Il clima di casa tua confonde la rinuncia con la virtù.

## La Morte

### dritta

- 1: Intorno a te un capitolo si chiude: un trasloco, un ufficio che cambia volto, persone che escono dalla tua vita per fare posto ad altre. Il tuo ambiente sta cambiando pelle.
- 2: Nella tua cerchia qualcosa finisce davvero: un assetto familiare, un gruppo di lavoro, un'abitudine collettiva. Il cavaliere scuro passa fra le case che conosci e porta via ciò che era maturo.
- 3: Chi ti sta vicino attraversa una trasformazione profonda e ne esce diverso. Lo scenario che ti circonda si sgombra come un campo dopo la mietitura, pronto per un'altra semina.

### capovolta

- 1: Nel tuo ambiente c'è chi si aggrappa a ciò che è finito: una casa che conserva stanze intatte, un ufficio che difende un sistema superato. Il cambiamento è arrivato e gli altri gli sbarrano la porta.
- 2: Intorno a te un vecchio assetto resiste oltre il suo tempo: rapporti logori tenuti in piedi, ruoli che nessuno vuole lasciare. La tua cerchia trattiene ciò che dovrebbe congedare.
- 3: Fra le persone vicine la fine di qualcosa viene negata: si fa finta che tutto sia come prima. Ti tocca vivere in un luogo dove nessuno chiude le porte che si sono già chiuse.

## La Temperanza

### dritta

- 1: Intorno a te c'è chi media con pazienza: versa acqua da una coppa all'altra finché le parti si accordano. Grazie a questa persona il tuo ambiente trova la giusta misura.
- 2: Nella tua cerchia si vive con ritmo calmo: pasti condivisi, toni pacati, differenze che si mescolano senza scontri. Ti muovi in un ambiente armonioso dove gli opposti convivono.
- 3: Chi ti sta vicino sa dosare: un collega che smussa, un parente che riconcilia, un amico che ti rallenta quando corri troppo. Il luogo in cui abiti ha il passo di un fiume tranquillo.

### capovolta

- 1: Nel tuo ambiente tutto è troppo: troppe ore di lavoro, troppe feste, troppe parole. Le persone vicine hanno perso il senso della misura e ti trascinano nei loro eccessi.
- 2: Intorno a te due gruppi non si parlano più e nessuno fa da ponte: la casa o l'ufficio sono divisi in due coppe che non si versano più l'una nell'altra.
- 3: Fra la gente che frequenti i ritmi sono sbagliati: chi corre accanto a chi dorme, chi pretende tutto subito accanto a chi rimanda. Ti manca intorno qualcuno che sappia dosare.

## Il Diavolo

### dritta

- 1: Intorno a te ci sono legami che vincolano: un ricatto affettivo, una dipendenza condivisa, un ambiente che tiene tutti con la catena al collo. Le persone vicine ti trattengono col bisogno.
- 2: Nella tua cerchia qualcuno esercita un potere che lega: un capo che ti fa sentire indispensabile, un amico che vive di eccessi e ti invita a seguirlo. Il piacere fa da catena.
- 3: Chi ti circonda ha fatto delle abitudini una prigione comune: si beve, si spende, si resta per inerzia. Il luogo che abiti in questo periodo ha l'aria pesante di una cantina chiusa.

### capovolta

- 1: Nel tuo ambiente una catena si allenta: qualcuno vicino esce da un legame malsano, una dipendenza di casa perde la presa. L'aria che ti circonda torna respirabile.
- 2: Intorno a te le persone cominciano a vedere i nodi che le tenevano: un gruppo si scioglie, un ricatto viene nominato. Chi ti sta accanto si toglie il collare e ti lascia più spazio.
- 3: Fra chi frequenti si apre una crepa nel potere che teneva tutti legati: un capo perde presa, una persona manipolatrice viene smascherata. Ti accorgi che la stanza ha di nuovo una porta.

## La Torre

### dritta

- 1: Intorno a te qualcosa crolla all'improvviso: una famiglia che si scuote, un'azienda che chiude, una struttura comune costruita sul falso. Il fulmine colpisce l'ambiente in cui vivi.
- 2: Nella tua cerchia cade un'apparenza che reggeva tutti: si scopre una bugia, salta un equilibrio. Le persone vicine vengono sbalzate fuori dalle loro finestre e tu con loro.
- 3: Chi ti circonda attraversa uno scossone che non aveva previsto e le fondamenta comuni vanno rifatte. Del posto che abiti resta in piedi solo ciò che era vero.

### capovolta

- 1: Nel tuo ambiente c'è una crepa che tutti fingono di non vedere: il muro regge per abitudine, la scossa viene rimandata. Ti muovi in un edificio comune che sta in piedi solo in apparenza.
- 2: Intorno a te le persone stanno uscendo a fatica dalle macerie di un crollo recente. La casa o l'ufficio vivono tra i calcinacci e ti chiedono di aiutare a sgombrare.
- 3: Fra la gente vicina si tengono puntelli su un edificio che dovrebbe cadere: segreti protetti, scandali soffocati. Il crollo che gli altri evitano pesa anche sul tuo soffitto.

## La Stella

### dritta

- 1: Intorno a te torna una luce calma dopo la tempesta: persone che ispirano, un amico che versa acqua fresca sulla terra arsa. Il tuo ambiente ti rimette in mano la fiducia.
- 2: Nella tua cerchia qualcuno rassicura senza parole, solo con la sua presenza limpida: grazie a questa persona la casa respira di nuovo e intorno a te si torna a sperare.
- 3: Chi ti sta vicino in questo periodo ha ritrovato serenità e la condivide: un gruppo che si riprende, una famiglia che torna a sognare. Il cielo sopra il tuo tetto è sgombro di nuvole.

### capovolta

- 1: Nel tuo ambiente la sfiducia si è diffusa: colleghi scoraggiati, parenti che non credono più a niente. Il loro cielo coperto ti toglie la voglia di guardare in alto.
- 2: Intorno a te chi di solito ispirava si è spento: un amico stanco, una guida che non ha più idee. La luce comune è velata da una nube che non è tua.
- 3: Fra le persone che frequenti circola un pessimismo sottile: si dice che tanto non cambierà niente. Ti tocca tenere accesa la speranza in un posto dove gli altri l'hanno lasciata cadere.

## La Luna

### dritta

- 1: Intorno a te le cose non sono come sembrano: mezze verità, discorsi a doppio senso, persone che dicono una cosa di giorno e un'altra di notte. Il tuo ambiente è illuminato da una luce pallida.
- 2: Nella tua cerchia girano chiacchiere e sospetti come cani che abbaiano a un chiaro notturno. Qualcuno vicino non è del tutto limpido e ti conviene muoverti fra gli altri con prudenza.
- 3: Chi ti circonda vive in un clima di incertezza: notizie confuse, ruoli ambigui, paure che passano di bocca in bocca. Il sentiero che attraversa la tua casa corre fra due torri nella nebbia.

### capovolta

- 1: Nel tuo ambiente un equivoco si chiarisce: una persona che sembrava ostile si rivela innocua, un pettegolezzo di corridoio perde forza. Intorno a te la nebbia comincia a sollevarsi.
- 2: Intorno a te chi diffondeva ansia si calma e le stanze tornano leggibili: si parla chiaro, si mostrano le carte. Ciò che di notte sembrava un lupo era il cane del vicino.
- 3: Fra le persone che frequenti un malinteso lungo si scioglie e le intenzioni tornano visibili. Ti muovi in un ambiente che esce dal crepuscolo e si lascia guardare in faccia.

## Il Sole

### dritta

- 1: Intorno a te c'è allegria: bambini che corrono in giardino, amici che ridono, una casa con le finestre spalancate. Il tuo ambiente in questo periodo è caldo come un mezzogiorno d'estate.
- 2: Nella tua cerchia le cose riescono e tutti lo vedono: un successo di famiglia, un risultato raggiunto insieme, un riconoscimento pubblico. Ti trovi in mezzo a persone che brillano.
- 3: Chi ti sta vicino porta chiarezza e calore: nessuna zona d'ombra, nessun non detto. Il luogo in cui vivi è inondato di luce e ogni girasole del cortile guarda dalla tua parte.

### capovolta

- 1: Nel tuo ambiente l'allegria è trattenuta: la festa c'è ma qualcuno ha la testa altrove, i sorrisi arrivano a metà. Sopra la tua casa passa una nube che copre il cortile.
- 2: Intorno a te le persone faticano a godersi ciò che hanno: un successo comune vissuto con ansia, un bambino che non ride. Il calore c'è, ma tu lo senti solo da lontano.
- 3: Fra la gente vicina qualcuno spegne l'entusiasmo degli altri con un pensiero vecchio, un brontolio, una critica. Ti tocca stare in un posto luminoso con le tende tirate.

## Il Giudizio

### dritta

- 1: Intorno a te qualcuno ti richiama: una famiglia che si ritrova, un vecchio gruppo che ti cerca, una tromba che suona per tutti. L'ambiente ti invita a rispondere e a rientrare fra i tuoi.
- 2: Nella tua cerchia è tempo di bilanci comuni: si riaprono questioni sepolte, si fa pace, si ricomincia insieme. Le persone vicine si alzano dalle loro casse e ti tendono le braccia.
- 3: Chi ti circonda vive una rinascita collettiva: un'azienda che si rinnova, parenti che si riconciliano dopo anni. Ti trovi dentro un risveglio che non riguarda solo te.

### capovolta

- 1: Nel tuo ambiente si giudica in fretta e si condanna senza ascoltare: verdetti da cucina, processi d'ufficio. Le persone vicine ti misurano con un metro duro che non tiene conto di chi sei.
- 2: Intorno a te una chiamata suona e nessuno si alza: una riunione di famiglia rimandata, un chiarimento che tutti evitano. La tua cerchia lascia cadere un'occasione di rinascita.
- 3: Fra la gente che frequenti si rinfacciano vecchi conti invece di chiuderli. Ti muovi in un posto dove il passato viene tirato fuori solo per accusare.

## Il Mondo

### dritta

- 1: Intorno a te le cose sono al loro posto: le persone giuste, il ruolo giusto, una casa che ti contiene per intero. L'ambiente in cui ti muovi ha la forma piena di una ghirlanda chiusa.
- 2: Nella tua cerchia c'è un orizzonte largo: persone di altri paesi, amici sparsi lontano, legami che abbracciano più culture. Ti trovi al centro di un cerchio che si è compiuto.
- 3: Chi ti sta vicino ha concluso un ciclo e lo celebra: un trasloco finito, un progetto consegnato, una famiglia che ha ritrovato il suo assetto. Ti accolgono dentro questa pienezza.

### capovolta

- 1: Nel tuo ambiente manca un pezzo per chiudere il cerchio: un parente lontano, un socio assente, una pratica comune lasciata a metà. Intorno a te la ghirlanda resta aperta.
- 2: Intorno a te un gruppo è arrivato quasi alla fine e si è fermato: lavori di casa incompiuti, una festa preparata e mai fatta. Le persone vicine ti lasciano l'ultimo tratto in sospeso.
- 3: Fra le persone che frequenti c'è chi non vuole concludere per paura di ciò che viene dopo. Ti muovi in un posto che sta sulla soglia del compimento senza varcarla.

## Asso di Bastoni

### dritta

- 1: Intorno a te qualcuno accende una scintilla: una proposta che arriva da fuori, un invito, un'idea lanciata da un amico. Dal tuo ambiente spunta una mano che ti offre un ramo in fiore.
- 2: Nella tua cerchia c'è fermento: progetti nuovi, persone piene di iniziativa, un luogo che brucia di energia. Il fuoco degli altri ti scalda e ti invita a cominciare.
- 3: Chi ti sta vicino porta entusiasmo e voglia di fare: una persona appena arrivata, un parente con un'idea ardente. Il posto in cui vivi sta germogliando come un bastone che mette foglie.

### capovolta

- 1: Nel tuo ambiente il fuoco è soffocato: iniziative ferme, proposte che nessuno raccoglie, persone che spengono ogni idea prima che prenda. Intorno a te i rami restano secchi.
- 2: Intorno a te tutti aspettano che sia qualcun altro ad accendere: si rimanda, si teme di sbagliare. La tua cerchia tiene in mano un bastone senza gemme.
- 3: Fra la gente vicina un'offerta promessa tarda ad arrivare: il contatto non richiama, l'invito resta sospeso. Ti tocca abitare un posto dove la scintilla esterna non scocca.

## Due di Bastoni

### dritta

- 1: Intorno a te c'è chi guarda lontano e ti mostra l'orizzonte: chi ha già viaggiato molto e chi progetta qualcosa oltre il confine. Il tuo ambiente ti mette in mano un globo da studiare.
- 2: Nella tua cerchia si fanno piani ambiziosi: persone che pensano in grande, una casa affacciata su paesi nuovi. Dagli spalti del tuo castello vedi il mare e le terre che gli altri ti indicano.
- 3: Chi ti circonda ti allarga lo sguardo: persone con contatti all'estero, parenti che parlano di trasferirsi. Il luogo in cui vivi è una terrazza da cui si sceglie una direzione.

### capovolta

- 1: Nel tuo ambiente i progetti comuni girano a vuoto: tutti guardano l'orizzonte e nessuno scende dalle mura. Intorno a te si discute di rotte senza mai salpare.
- 2: Intorno a te le persone esitano sulla soglia di casa: un socio indeciso, un parente che non sa se partire. La loro incertezza tiene ferma anche la tua faccenda.
- 3: Fra la gente che frequenti c'è paura di osare: chi propone viene frenato, chi sogna viene deriso. Ti muovi fra mura sicure che non lasciano vedere lontano.

## Tre di Bastoni

### dritta

- 1: Intorno a te c'è chi commercia, viaggia, manda merci e idee lontano: un socio con clienti all'estero, un amico che apre una filiale. Il tuo ambiente guarda le navi al largo insieme a te.
- 2: Nella tua cerchia le cose si allargano: contatti nuovi, una rete che cresce oltre la città. Le persone vicine aspettano con te ciò che hanno messo in mare e ti tengono il posto sulla scogliera.
- 3: Chi ti circonda ha già avviato qualcosa e ne attende il ritorno con fiducia: un'impresa di famiglia, un progetto comune spedito lontano. Ti trovi in un ambiente che vive di orizzonti.

### capovolta

- 1: Nel tuo ambiente rientrano navi con un carico diverso da quello atteso: un socio torna con altre condizioni, un parente riporta una notizia che nessuno aveva previsto. Intorno a te i conti vanno rifatti.
- 2: Intorno a te i contatti lontani rispondono in modo inatteso: un cliente cambia idea, un amico emigrato torna diverso. La tua cerchia riceve dal mare qualcosa che non aveva ordinato.
- 3: Fra le persone che frequenti le attese erano alte e ciò che arriva non coincide: chi aspettava un sì riceve un forse. Ti tocca abitare un porto dove le stive si aprono con sorpresa.

## Quattro di Bastoni

### dritta

- 1: Intorno a te si prepara una festa: una ghirlanda sulla porta, un matrimonio, un'inaugurazione, ospiti che arrivano con i fiori. La tua casa in questo periodo è un arco di rami decorati.
- 2: Nella tua cerchia si celebra un traguardo comune: un trasloco riuscito, una casa nuova, una ricorrenza di famiglia. Le persone vicine alzano le braccia in segno di gioia e ti chiamano dentro.
- 3: Chi ti sta vicino vive un momento stabile e lieto: le fondamenta reggono, il cortile è pieno di gente. Ti accoglie un ambiente che ha voglia di brindare a ciò che ha costruito.

### capovolta

- 1: Nel tuo ambiente una festa viene rinviata: la data slitta, gli inviti restano nel cassetto, qualcuno manca all'appello. Intorno a te la ghirlanda è appesa e la porta resta chiusa.
- 2: Intorno a te c'è una casa nuova in cui nessuno ha ancora fatto ingresso: scatoloni chiusi, stanze senza mobili, un trasloco a metà. La tua cerchia vive in sospeso fra due soglie.
- 3: Fra la gente vicina si festeggia senza cuore, per dovere: una cena di famiglia tesa, una ricorrenza svogliata. Ti muovi in un ambiente che celebra solo a metà.

## Cinque di Bastoni

### dritta

- 1: Intorno a te i bastoni si incrociano: colleghi che discutono, fratelli che si contendono la parola, un gruppo dove ognuno vuole dire la sua. Il tuo ambiente è una palestra rumorosa.
- 2: Nella tua cerchia c'è competizione vivace ma senza ferite: idee che si scontrano, riunioni accese, gare amichevoli. Le persone vicine ti sfidano e ti tengono in allenamento.
- 3: Chi ti circonda ama il confronto e lo cerca: un ufficio pieno di caratteri forti, una casa dove si discute a tavola. Ti trovi in mezzo a una mischia giocosa che non sta mai ferma.

### capovolta

- 1: Nel tuo ambiente le liti covano senza scoppiare: frecciate, musi lunghi, discussioni che nessuno chiude. Intorno a te i bastoni restano alzati anche quando nessuno colpisce.
- 2: Intorno a te si litiga per cose da poco e si stancano tutti: un condominio in guerra, un gruppo di lavoro che si consuma in dispetti. La tua cerchia spreca energia in scaramucce.
- 3: Fra la gente che frequenti nessuno dice le cose apertamente e i contrasti passano sottobanco. Ti tocca vivere in un posto dove ogni parola nasconde un bastone.

## Sei di Bastoni

### dritta

- 1: Intorno a te le persone riconoscono ciò che hai fatto: un applauso, una lettera di stima, un capo che ti nomina davanti a tutti. Il tuo ambiente ti fa sfilare.
- 2: Nella tua cerchia c'è una folla che ti segue e ti sostiene: amici orgogliosi, colleghi che parlano bene di te. La corona d'alloro te la porgono gli altri.
- 3: Chi ti circonda celebra un successo comune e ti mette in testa al corteo: una squadra che ha vinto, una famiglia fiera. Ti muovi fra persone che hanno voglia di festeggiarti.

### capovolta

- 1: Nel tuo ambiente il merito va ad altri: il tuo lavoro passa inosservato, gli applausi seguono chi parla più forte. Intorno a te la folla guarda dall'altra parte.
- 2: Intorno a te il riconoscimento tarda: un capo distratto, parenti che non si accorgono di quanto hai fatto. La corona resta appesa a un ramo e nessuno della tua cerchia la stacca.
- 3: Fra le persone che frequenti c'è chi si prende i tuoi allori o li sminuisce per invidia. Ti tocca sfilare in una strada dove la gente ha chiuso le finestre.

## Sette di Bastoni

### dritta

- 1: Intorno a te in molti salgono verso la tua posizione: concorrenti, colleghi ambiziosi, parenti che ti contestano. Il tuo ambiente ti mette alla prova dal basso e ti chiede di tenere il colle.
- 2: Nella tua cerchia c'è pressione: richieste, critiche, persone che vogliono il tuo posto. Dalla cima su cui ti trovi vedi i bastoni degli altri alzarsi uno dopo l'altro.
- 3: Chi ti circonda ti sfida in campo aperto: una riunione dove tutti obiettano, una famiglia che mette in dubbio una tua scelta. Il luogo in cui vivi ti spinge a difendere ciò che hai.

### capovolta

- 1: Nel tuo ambiente le pressioni arrivano da ogni lato: troppe richieste, troppi fronti aperti, una famiglia e un ufficio che pretendono insieme. Intorno a te l'assedio non dà tregua.
- 2: Intorno a te la gente sale più in fretta di quanto tu riesca a respingerla: colleghi, clienti, parenti che chiedono. La tua cerchia ti stringe contro il bordo del colle.
- 3: Fra le persone vicine c'è chi attacca anche quando non serve, per abitudine o per noia. Ti muovi in un ambiente che ti costringe a stare sempre sulla difensiva.

## Otto di Bastoni

### dritta

- 1: Intorno a te le notizie volano: messaggi, telefonate, inviti, persone che arrivano e ripartono. Il tuo ambiente in questo periodo è un cielo attraversato da otto frecce che vanno a segno.
- 2: Nella tua cerchia si va di corsa: decisioni rapide, viaggi improvvisi, un ufficio dove le risposte arrivano in giornata. Gli altri ti trascinano nel loro ritmo veloce.
- 3: Chi ti sta vicino si muove in fretta: un amico che organizza, un parente che chiama ogni giorno. Il luogo in cui vivi ha l'aria di una stazione all'ora di punta.

### capovolta

- 1: Nel tuo ambiente le comunicazioni si inceppano: messaggi che non arrivano, risposte che tardano, viaggi rinviati. Intorno a te le frecce restano sospese a mezz'aria.
- 2: Intorno a te la fretta degli altri crea disordine: decisioni prese in corsa, ordini e contrordini, telefonate a vuoto. La tua cerchia corre e inciampa nei propri bastoni.
- 3: Fra la gente vicina c'è chi rallenta tutto: una pratica ferma sulla scrivania di qualcuno, un parente che non decide. Ti tocca aspettare notizie che dipendono da altri.

## Nove di Bastoni

### dritta

- 1: Intorno a te l'ambiente ha già messo alla prova più volte la tua pazienza e chiede ancora vigilanza: regole che cambiano, rapporti spinosi, richieste continue.
- 2: Nella tua cerchia ci sono ancora prove da reggere: richieste che tornano, persone che bussano quando sei al limite. Gli altri ti tengono di guardia fino all'ultimo palo.
- 3: Chi ti circonda ti ha lasciato qualche ferita e tu ne porti ancora i segni: persone esigenti, rapporti faticosi, un clima in cui devi stare sempre in guardia.

### capovolta

- 1: Nel tuo ambiente arrivano persone con buone intenzioni e trovano la porta chiusa: chi ti offre aiuto, chi vorrebbe riavvicinarsi, chi cerca solo un contatto sincero.
- 2: Intorno a te le persone si stancano di bussare: inviti declinati, aiuti rifiutati, una porta che non si apre a nessuno. La tua cerchia si allontana da un recinto che sembra un fortino.
- 3: Fra la gente che frequenti c'è chi tende la mano oltre i pali e la ritira per paura di ferirsi. Ti muovi in un posto dove vecchie ferite comuni tengono tutti sulla difensiva.

## Dieci di Bastoni

### dritta

- 1: Intorno a te c'è chi ti carica di compiti senza chiederti se ce la fai: richieste continue, deleghe facili, persone che contano solo su di te.
- 2: Nella tua cerchia le responsabilità sono distribuite male e il peso finisce sempre nello stesso punto. Le persone vicine guardano il villaggio lontano e lasciano a te il carico da portarci.
- 3: Chi ti circonda ha bisogno di molte cose e le chiede tutte a te: nel luogo in cui vivi le richieste si accumulano più in fretta di quanto tu riesca a soddisfarle.

### capovolta

- 1: Nel tuo ambiente porti pesi che sono di altri: faccende passate a te per abitudine, problemi che nessuno vuole affrontare. Intorno a te nessuno si offre di prenderne una parte.
- 2: Intorno a te le persone si sono abituate a vederti con le braccia piene e non chiedono più se ce la fai. La tua cerchia ha dimenticato di chi erano davvero quei bastoni.
- 3: Fra la gente vicina qualcuno comincia a riprendersi i propri compiti e ti invita a fare lo stesso: c'è chi si offre di aiutarti, chi propone di dividere il lavoro.

## Fante di Bastoni

### dritta

- 1: Intorno a te c'è qualcuno appena arrivato e pieno di curiosità, che fa mille domande: la sua energia giovane porta nel tuo ambiente notizie e idee fresche.
- 2: Nella tua cerchia qualcuno ti porta un messaggio con entusiasmo: una proposta di viaggio, un invito, un progetto appena nato. Il messaggero col bastone fiorito bussa alla tua porta.
- 3: Chi ti circonda in questo periodo ha voglia di esplorare e provare cose nuove: amici che si iscrivono a corsi, persone che sperimentano. Ti trovi in un ambiente vivace e curioso.

### capovolta

- 1: Nel tuo ambiente c'è un giovane incostante che si accende e si spegne: oggi un'idea, domani un'altra. Intorno a te le sue proposte arrivano a raffica e nessuna resta in piedi.
- 2: Intorno a te i progetti degli altri vengono abbandonati a metà: corsi lasciati, iniziative dimenticate, entusiasmi di una settimana. La tua cerchia semina e non annaffia.
- 3: Fra la gente vicina girano notizie frettolose e promesse leggere, portate da chi non le verifica. Ti muovi in un posto dove i messaggi arrivano prima di essere pensati.

## Cavaliere di Bastoni

### dritta

- 1: Intorno a te arriva qualcuno pieno di passione e di fretta, che cambia il ritmo delle tue giornate: il suo entusiasmo scuote l'ambiente e ti spinge all'avventura.
- 2: Nella tua cerchia si parla di partenze: un trasloco, un viaggio, un amico che lascia la città in cerca di fortuna. Le persone vicine montano a cavallo e ti invitano a seguirle.
- 3: Chi ti circonda in questo periodo osa e si muove in fretta: persone con progetti audaci, amici che non stanno mai fermi. Intorno a te si respira voglia di partire.

### capovolta

- 1: Nel tuo ambiente c'è chi corre senza meta e brucia tutto ciò che tocca: qualcuno impaziente, una persona che cambia idea ogni giorno. Intorno a te c'è agitazione ma nessuna direzione.
- 2: Intorno a te la foga di qualcuno crea scompiglio: decisioni avventate, partenze annunciate e annullate, litigi accesi. La tua cerchia è un cavallo che scalcia nel recinto.
- 3: Fra la gente che frequenti c'è chi si lancia in imprese e poi ti lascia a raccoglierne i cocci. Ti tocca vivere accanto a un ardore che non guarda dove galoppa.

## Regina di Bastoni

### dritta

- 1: Intorno a te c'è una persona sicura e generosa che scalda l'ambiente: un'amica, un parente, qualcuno che conosci bene. La sua presenza incoraggia chi le sta vicino e dà coraggio anche a te.
- 2: Nella tua cerchia c'è un carisma caldo che attira le persone: feste ben riuscite, porte aperte, inviti a cui tutti rispondono. Il tuo ambiente gravita intorno a qualcuno che sa accogliere.
- 3: Chi ti sta vicino irradia fiducia e ti fa spazio: una persona allegra che organizza, incoraggia, presenta gli amici agli amici. Il luogo in cui vivi è un salotto pieno di sole.

### capovolta

- 1: Nel tuo ambiente qualcuno vuole brillare più degli altri e vive chi gli sta accanto come un rivale. Intorno a te circolano gelosie, piccole gare, sguardi che misurano.
- 2: Intorno a te una persona carismatica è diventata insicura e permalosa: si offende, pretende attenzione, si fa centro di ogni discorso. La tua cerchia gira intorno ai suoi umori.
- 3: Fra le persone che frequenti la generosità si è fatta possessiva: si dona per tenere legati, si accoglie per controllare. Ti muovi in una casa calda con il fuoco troppo alto.

## Re di Bastoni

### dritta

- 1: Intorno a te c'è una guida matura che apre possibilità con l'esempio: una persona che ispira, qualcuno che sa dare fiducia. Il tuo ambiente segue la sua energia e ti porta avanti.
- 2: Nella tua cerchia qualcuno sa accendere gli altri: dà visione, assegna compiti, crede nelle persone. Sul trono decorato di salamandre siede chi tiene viva l'impresa comune.
- 3: Chi ti circonda ha in mano la direzione e la esercita con generosità: persone che organizzano, decidono e si prendono responsabilità. Ti trovi in un luogo guidato da una volontà calda.

### capovolta

- 1: Nel tuo ambiente comanda qualcuno che spinge senza ascoltare: ordini urlati, decisioni prese d'impulso, nessuna pazienza per chi rallenta. Intorno a te l'autorità travolge.
- 2: Intorno a te qualcuno che ha autorità vuole tutto subito e a modo suo: scatti di rabbia, pretese, piani cambiati all'ultimo. La tua cerchia vive sotto una pressione che brucia invece di scaldare.
- 3: Fra la gente vicina chi dovrebbe guidare impone la propria visione e zittisce le altre. Ti tocca abitare un luogo dove l'impazienza di uno detta il ritmo a tutti.

## Asso di Coppe

### dritta

- 1: Intorno a te l'affetto trabocca: una nascita in famiglia, un amore nuovo nella cerchia, un gesto di tenerezza che nessuno si aspettava. Dalla tua casa sgorga una fonte che bagna chi le sta vicino.
- 2: Nella tua cerchia qualcuno ti offre il cuore con le mani aperte, come una coppa porta da una nuvola. Le persone vicine ti accolgono con un calore puro che non chiede niente in cambio.
- 3: Chi ti circonda vive un momento di grazia affettiva: riconciliazioni, abbracci, lettere d'amore. Il luogo in cui abiti è irrigato da cinque rivoli che scendono in una vasca di ninfee.

### capovolta

- 1: Nel tuo ambiente l'affetto resta chiuso nella coppa: parenti che non si abbracciano, un amico che ha paura di esporsi. Intorno a te la fonte di calore della casa non scorre.
- 2: Intorno a te qualcuno trattiene un sentimento per timore di soffrire e la sua chiusura raffredda le stanze. La tua cerchia ha acqua in abbondanza e la tiene ferma a ristagnare.
- 3: Fra la gente che frequenti le emozioni si tengono sotto il coperchio: si parla di tutto tranne che di ciò che si prova. Ti muovi in un posto dove nessuno versa per primo.

## Due di Coppe

### dritta

- 1: Intorno a te c'è un patto a due che ti sostiene: un socio leale, un partner, un'amicizia stretta come uno scambio di coppe. Il tuo ambiente ha al centro un'intesa reciproca.
- 2: Nella tua cerchia due persone si riconoscono e si alleano: quella sintonia fa bene a tutti, anche a te. Sopra di loro il caduceo col leone alato veglia sulla promessa.
- 3: Chi ti sta vicino ti propone un accordo alla pari: una collaborazione, un fidanzamento, una riconciliazione. Il luogo in cui vivi è segnato da un brindisi fra due che si guardano negli occhi.

### capovolta

- 1: Nel tuo ambiente un'intesa vicina si è incrinata: due amici che non si parlano, soci in disaccordo, una coppia di parenti che si evita. Intorno a te le coppe non si toccano più.
- 2: Intorno a te un malinteso fra due persone care si allarga e coinvolge anche te: messaggi riferiti, versioni diverse. La tua cerchia aspetta che qualcuno ricucia il patto.
- 3: Fra la gente vicina un legame che sembrava paritario pende da una parte sola: chi dà e chi prende. Ti tocca vivere accanto a un accordo che ha perso il suo equilibrio.

## Tre di Coppe

### dritta

- 1: Intorno a te ci sono amici che alzano i calici: una festa, un raccolto da celebrare, un gruppo che balla in cerchio. Il tuo ambiente adesso è un brindisi fra persone care.
- 2: Nella tua cerchia la comunità ti accoglie e ti sostiene: sorelle, amiche, colleghi che si danno una mano e ridono insieme. Non affronti la faccenda in solitudine: hai intorno chi brinda con te.
- 3: Chi ti sta vicino ama la compagnia e la condivide: tavolate, compleanni, ritrovi. Il luogo in cui vivi è un giardino d'autunno dove tre figure intrecciano le braccia.

### capovolta

- 1: Nel tuo ambiente ci sono troppi inviti e poca amicizia vera: feste di facciata, sorrisi di circostanza, gruppi che si sfaldano al primo problema. Intorno a te i calici sono pieni e i cuori distratti.
- 2: Intorno a te il cerchio degli amici è sbilanciato: qualcuno escluso, qualcuno di troppo, pettegolezzi fra un brindisi e l'altro. La tua cerchia va curata più che frequentata.
- 3: Fra la gente che frequenti si eccede: si beve, si spende, si fa tardi per non stare soli. Ti muovi in una festa che non nutre e ti lascia la sera più vuota.

## Quattro di Coppe

### dritta

- 1: Intorno a te c'è un clima sazio e annoiato: persone che hanno tutto e non apprezzano niente, offerte rifiutate senza guardarle. Una mano tesa fuori dalla nuvola resta sospesa nel tuo ambiente.
- 2: Nella tua cerchia qualcuno siede sotto un albero a braccia incrociate e respinge ogni proposta. La sua apatia appesantisce la casa e ti rende difficile portare novità.
- 3: Chi ti circonda si annoia della solita minestra e non vede la coppa nuova che gli viene offerta. Ti trovi in un posto dove le occasioni passano accanto a gente distratta.

### capovolta

- 1: Nel tuo ambiente il torpore finisce: chi era chiuso torna a interessarsi, una proposta trascurata viene ripresa. Intorno a te le persone si alzano da sotto l'albero.
- 2: Intorno a te la casa si ridesta: nuove curiosità, inviti accettati, un parente che riprende un vecchio hobby. La tua cerchia accetta finalmente la coppa che le veniva tesa.
- 3: Fra le persone che frequenti torna la voglia di fare dopo un lungo stallo: riunioni più vive, sguardi più attenti. Ti muovi in un ambiente che esce dalla noia.

## Cinque di Coppe

### dritta

- 1: Intorno a te qualcuno piange una perdita: un lutto in famiglia, un progetto andato in fumo, un amore finito. Il tuo ambiente porta un mantello nero e fissa le coppe versate a terra.
- 2: Nella tua cerchia domina il rimpianto: si parla di ciò che non c'è più. Le persone vicine non vedono le due coppe ancora in piedi e la tristezza riempie la casa.
- 3: Chi ti sta vicino si piega su un dolore e ti chiede compagnia. Il luogo in cui vivi ha un ponte verso una casa intatta oltre il fiume e nessuno lo attraversa.

### capovolta

- 1: Nel tuo ambiente ci si rialza dopo una perdita: si riaprono le finestre, si torna a invitare gente. Intorno a te le persone si voltano verso le coppe rimaste in piedi.
- 2: Intorno a te un dolore comune comincia a sciogliersi: chi era chiuso nel lutto riprende a parlare, il perdono entra in casa. La tua cerchia attraversa il ponte verso l'altra riva.
- 3: Fra la gente vicina il rimpianto lascia spazio a progetti piccoli e concreti: un pranzo, una passeggiata, una telefonata. Ti accompagna un ambiente che torna a guardare avanti.

## Sei di Coppe

### dritta

- 1: Intorno a te tornano volti del passato: un amico d'infanzia, un vecchio vicino, parenti che riportano ricordi. Il tuo ambiente in questo periodo profuma di cortile e di fiori in una coppa.
- 2: Nella tua cerchia c'è tenerezza semplice: bambini che giocano, nonni che raccontano, doni piccoli fatti col cuore. Le persone vicine ti offrono la dolcezza della casa dove hai passato l'infanzia.
- 3: Chi ti sta vicino ti fa sentire a casa come nell'infanzia: gesti familiari, piatti di una volta, parole affettuose. Il luogo in cui vivi è un giardino recintato pieno di memorie buone.

### capovolta

- 1: Nel tuo ambiente si vive di ricordi: la famiglia ripete gli stessi racconti, le abitudini di un tempo dettano le regole di oggi. Intorno a te il passato occupa troppo spazio.
- 2: Intorno a te qualcuno ti tratta come eri anni fa e non vede chi sei oggi: la tua cerchia ti rimette in mano i fiori dell'infanzia, come se il tempo non fosse passato.
- 3: Fra la gente che frequenti la nostalgia è diventata una gabbia: si rimpiange, si confronta, si dice che una volta era meglio. Ti muovi in una casa arredata con mobili di un altro tempo.

## Sette di Coppe

### dritta

- 1: Intorno a te arrivano proposte che brillano come castelli e gioielli fra le nuvole: le persone che frequenti ti promettono molto e il tuo ambiente vive di sogni a occhi aperti.
- 2: Nella tua cerchia si fantastica più che si fa: progetti mirabolanti, affari d'oro raccontati a cena, amici che cambiano sogno ogni mese. Gli altri ti mettono davanti una fila di miraggi.
- 3: Chi ti circonda offre possibilità tutte insieme e nessuna verificata: un'opportunità qui, un'altra là, un'idea velata da un drappo. Il luogo in cui vivi è una vetrina di illusioni.

### capovolta

- 1: Nel tuo ambiente le promesse gonfiate si sgonfiano: un affare rivela il suo trucco, un'offerta mostra il suo prezzo vero. Intorno a te la nebbia si dirada sulle coppe.
- 2: Intorno a te chi sognava a vuoto torna coi piedi a terra: un amico sceglie un lavoro, un parente lascia perdere i castelli. La tua cerchia mette a fuoco.
- 3: Fra la gente che frequenti le illusioni cadono e resta l'offerta vera, più piccola e più solida. Ti muovi in un posto che smette di vendere fumo.

## Otto di Coppe

### dritta

- 1: Intorno a te qualcuno se ne va in silenzio: lascia le coppe in fila e si incammina verso i monti sotto la luna calante. Il tuo ambiente si svuota di una presenza che cercava altro.
- 2: Nella tua cerchia le persone si allontanano da ciò che non le nutre più: qualcuno cambia città, qualcuno cambia vita, un gruppo si scioglie. Ti trovi in una casa che perde abitanti.
- 3: Chi ti sta vicino sente il bisogno di un senso più alto e lo cerca altrove, voltando le spalle a ciò che aveva costruito. Il luogo in cui vivi ha una porta aperta sulla notte.

### capovolta

- 1: Nel tuo ambiente c'è chi resta sulla porta senza decidere: annuncia la partenza e poi rimane, saluta e poi ritorna. Intorno a te nessuno sa se quella persona se ne andrà davvero.
- 2: Intorno a te un gruppo vive di arrivederci mai detti: rapporti che non si chiudono, persone con la valigia pronta da mesi. La tua cerchia sta con un piede dentro e uno fuori.
- 3: Fra la gente vicina chi voleva andarsene ha paura di lasciare le coppe e torna a sedersi accanto a loro. Ti tocca abitare una casa piena di partenze sospese.

## Nove di Coppe

### dritta

- 1: Intorno a te c'è contentezza: una tavola imbandita, un ospite che sorride a braccia conserte davanti alle coppe in fila. Il tuo ambiente in questo periodo soddisfa i desideri di chi ci vive.
- 2: Nella tua cerchia le cose vanno bene e ci si gode il benessere: cene in compagnia, piccoli lussi, desideri esauditi. Le persone vicine ti fanno spazio alla loro tavola.
- 3: Chi ti sta vicino è generoso e vuole vederti soddisfare un desiderio: un amico ti invita, un parente ti regala ciò che speravi. Il luogo in cui vivi ha la credenza piena.

### capovolta

- 1: Nel tuo ambiente il benessere è di facciata: sorrisi da vetrina, case perfette dove nessuno è felice. Intorno a te le coppe sono lucide e vuote.
- 2: Intorno a te qualcuno si riempie di piaceri che non colmano: acquisti, feste, distrazioni continue. La tua cerchia ostenta abbondanza e nasconde un'insoddisfazione profonda.
- 3: Fra le persone che frequenti si gareggia a chi ha di più e si gode di meno. Ti muovi in un banchetto dove l'ospite compiaciuto guarda solo le sue coppe.

## Dieci di Coppe

### dritta

- 1: Intorno a te la famiglia è unita: genitori abbracciati, bambini che ballano, una casa sotto un arcobaleno di coppe. Il tuo ambiente in questo periodo è fatto di legami che reggono.
- 2: Nella tua cerchia l'amore è la vera ricchezza: si sta insieme, ci si sostiene, ci si festeggia. Le persone di casa ti offrono un rifugio di serenità condivisa.
- 3: Chi ti sta vicino costruisce con te una felicità comune: amici che sono come fratelli, parenti che si cercano. Il luogo in cui vivi ha un tetto colorato dopo la pioggia.

### capovolta

- 1: Nel tuo ambiente la casa è divisa: sotto lo stesso tetto ognuno tira dalla sua parte, i pranzi sono silenziosi. Intorno a te l'arcobaleno si è spezzato in più colori.
- 2: Intorno a te le persone di famiglia si allontanano: una lite che non si ricompone, parenti lontani, legami che diventano freddi. La tua cerchia ha perso la sua armonia.
- 3: Fra la gente vicina l'immagine della famiglia felice viene difesa davanti agli altri e smentita fra le mura. Ti tocca vivere in una casa che sorride solo nelle foto.

## Fante di Coppe

### dritta

- 1: Intorno a te c'è una persona giovane e sensibile che porta poesia: un ragazzo sognatore, un'amica che scrive, un pesce che spunta dalla coppa e la fa sorridere. Il tuo ambiente è gentile.
- 2: Nella tua cerchia arriva un messaggio affettuoso: un biglietto, un invito timido, una dichiarazione inattesa. Le persone vicine ti offrono emozioni nuove e un po' fragili.
- 3: Chi ti circonda ha un animo delicato e creativo: musicisti, bambini, amici con la testa fra le nuvole. Il luogo in cui vivi è una riva di mare calmo dove si fantastica.

### capovolta

- 1: Nel tuo ambiente c'è qualcuno ferito che si è chiuso: un ragazzo che non parla, un'amica che si offende per poco. Intorno a te una sensibilità fragile si è murata.
- 2: Intorno a te le emozioni degli altri sono immature e capricciose: broncio, lacrime facili, dispetti. La tua cerchia vive di sentimenti piccoli e permalosi.
- 3: Fra la gente che frequenti un messaggio affettuoso è stato frainteso e ha lasciato un livido. Ti muovi accanto a cuori giovani che si difendono chiudendo la coppa.

## Cavaliere di Coppe

### dritta

- 1: Intorno a te arriva qualcuno con la coppa tesa, al passo lento di un cavallo bianco: un corteggiatore, un amico romantico, una persona che porta un invito. Il tuo ambiente si apre alla grazia.
- 2: Nella tua cerchia c'è chi ti fa una proposta affettuosa: un viaggio insieme, una collaborazione nata dal cuore, una dichiarazione gentile. Gli altri ti offrono bellezza e attenzione.
- 3: Chi ti circonda in questo periodo è incline ai gesti romantici: fiori, lettere, serate preparate con cura. Il luogo in cui vivi è attraversato da un messaggero che porta sentimenti.

### capovolta

- 1: Nel tuo ambiente c'è chi promette con dolcezza e poi sparisce: un corteggiatore incostante, un amico pieno di belle parole. Intorno a te le coppe offerte restano vuote.
- 2: Intorno a te i sentimenti cambiano col vento: chi oggi ti cerca domani non risponde, chi giura fedeltà guarda altrove. La tua cerchia è popolata di cavalieri che non arrivano.
- 3: Fra la gente che frequenti si vive di romanticismo di superficie: gesti da film, nessuna radice. Ti muovi in un ambiente dove le parole dolci non vengono seguite dai fatti.

## Regina di Coppe

### dritta

- 1: Intorno a te c'è una persona empatica che sa ascoltare: una madre, un'amica, una terapeuta seduta in riva al mare con la coppa fra le mani. Accanto a lei ti senti capire.
- 2: Nella tua cerchia si accoglie con il cuore: nessuno giudica, tutti intuiscono quando qualcosa non va. Le persone vicine leggono i tuoi stati d'animo e li proteggono.
- 3: Chi ti sta vicino ha una sensibilità profonda e la mette al servizio degli altri: cura, conforta, intuisce. Il luogo in cui vivi è un trono sulla spiaggia battuto da onde tranquille.

### capovolta

- 1: Nel tuo ambiente le emozioni degli altri ti sommergono: chi si sfoga con te ogni sera, chi riversa sulla casa i propri umori. Intorno a te l'acqua sale più del dovuto.
- 2: Intorno a te qualcuno vive di drammi e tira tutti dentro: lacrime, sensi di colpa, bisogno continuo di conforto. La tua cerchia ha smarrito i confini fra il sentire e l'annegare.
- 3: Fra le persone vicine chi dovrebbe accogliere si è perso nelle proprie onde e non vede più gli altri. Ti tocca abitare una casa dove le emozioni allagano le stanze.

## Re di Coppe

### dritta

- 1: Intorno a te c'è un porto sicuro: una persona matura e calma che governa gli affetti, seduta su un trono in mezzo al mare agitato senza bagnarsi. Il tuo ambiente si appoggia alla sua serenità.
- 2: Nella tua cerchia c'è chi sa tenere i nervi saldi quando gli altri si agitano: un padre, un medico di famiglia, un capo comprensivo. Le persone vicine ti offrono una calma profonda.
- 3: Chi ti circonda gestisce i sentimenti con saggezza: litiga poco, perdona molto, consiglia con equilibrio. Il luogo in cui vivi ha un timone in mani esperte.

### capovolta

- 1: Nel tuo ambiente chi dovrebbe dare calma si fa condurre dagli umori: un capo lunatico, un genitore imprevedibile. Intorno a te il mare si agita proprio attorno al trono.
- 2: Intorno a te qualcuno usa i sentimenti per ottenere qualcosa: affetto a condizione, silenzi punitivi, carezze che chiedono un prezzo. La tua cerchia è governata da un cuore che manovra.
- 3: Fra le persone che frequenti la maturità affettiva c'è ma non guida: ognuno si lascia trascinare dalle proprie maree. Ti muovi in un porto senza capitano.

## Asso di Denari

### dritta

- 1: Intorno a te c'è un terreno fertile: un'offerta concreta di lavoro, una casa disponibile, un sostegno materiale porto da una mano che esce dalle nuvole. Il tuo ambiente ti dà una base su cui seminare.
- 2: Nella tua cerchia qualcuno ti apre una porta pratica: un contatto, un prestito di strumenti, un posto dove cominciare. Il giardino che ti circonda ha un arco fiorito verso l'esterno.
- 3: Chi ti sta vicino ti offre risorse solide e concrete, senza giri di parole. Il luogo in cui vivi in questo periodo è una terra buona, pronta a far crescere ciò che vi pianti.

### capovolta

- 1: Nel tuo ambiente un'occasione concreta viene lasciata sfumare: un'offerta ignorata, risorse comuni trascurate, una proposta che nessuno raccoglie. Intorno a te la moneta d'oro cade a terra.
- 2: Intorno a te le persone valutano male i rischi: un investimento di famiglia fatto in fretta, un socio che sottovaluta i conti. La tua cerchia semina su un terreno che non ha guardato.
- 3: Fra la gente vicina c'è chi spreca ciò che riceve o non lo vede neppure. Ti tocca vivere in un giardino dove i frutti marciscono sui rami perché nessuno li coglie.

## Due di Denari

### dritta

- 1: Intorno a te tutto si muove a onde: impegni che si accavallano, persone che si destreggiano fra lavoro e famiglia, navi che salgono e scendono sul mare. Il tuo ambiente vive di equilibri mobili.
- 2: Nella tua cerchia c'è chi tiene più cose in aria con leggerezza: persone che reggono mille impegni insieme e danzano fra tutti gli orari. La loro flessibilità ti insegna a tenere il ritmo.
- 3: Chi ti circonda cambia piani spesso e lo fa con allegria: turni nuovi, spostamenti, scambi di favori. Il luogo in cui vivi è un nastro infinito che lega due monete in movimento.

### capovolta

- 1: Nel tuo ambiente il ritmo si è rotto: troppe cose comuni in aria, scadenze che si sovrappongono, qualcosa che cade di mano. Intorno a te il giocoliere ha perso il tempo.
- 2: Intorno a te le persone si disperdono in mille impegni e nessuno tiene il conto: bollette dimenticate, appuntamenti saltati. La tua cerchia barcolla sulle onde.
- 3: Fra la gente che frequenti c'è chi promette di occuparsi di tutto e lascia cadere metà delle cose. Ti tocca raccogliere le monete che gli altri lasciano scivolare.

## Tre di Denari

### dritta

- 1: Intorno a te c'è una squadra competente: un artigiano, un progettista e un committente che studiano insieme il disegno della cattedrale. Il tuo ambiente lavora con te e riconosce la tua mano.
- 2: Nella tua cerchia le persone collaborano con serietà: ognuno porta il suo mestiere, nessuno ruba il lavoro altrui. Gli altri ti chiamano dentro un cantiere che sta già dando frutti.
- 3: Chi ti sta vicino apprezza ciò che sai fare e te lo dice: un capo che ti consulta, colleghi che ti chiedono un parere. Intorno a te l'opera cresce in comune.

### capovolta

- 1: Nel tuo ambiente i ruoli sono confusi: nessuno sa chi deve fare cosa, il progetto comune non ingrana. Intorno a te l'arco della cattedrale resta a metà.
- 2: Intorno a te la squadra non ha sintonia: chi lavora troppo, chi non lavora affatto, chi critica senza fare. La tua cerchia costruisce su un disegno che ognuno legge a modo suo.
- 3: Fra la gente vicina manca la comunicazione: le aspettative non vengono dette, i compiti non vengono chiariti. Ti muovi in un cantiere dove si parla lingue diverse.

## Quattro di Denari

### dritta

- 1: Intorno a te si conserva con cura: una famiglia che risparmia, un ufficio prudente, persone che tengono la moneta stretta al petto. Il tuo ambiente ti offre sicurezza e mura protette.
- 2: Nella tua cerchia ognuno difende ciò che ha: proprietà ben segnate, confini chiari, conti tenuti in ordine. Le persone vicine ti insegnano a mettere da parte e a contare.
- 3: Chi ti circonda tiene i piedi sulle monete e la città alle spalle: un parente che amministra, un capo che controlla le spese. Il luogo è stabile e chiuso come una cassaforte.

### capovolta

- 1: Nel tuo ambiente regna la paura di restare senza: si stringe anche il poco, si nega un aiuto per prudenza. Intorno a te le risorse comuni sono chiuse a chiave.
- 2: Intorno a te qualcuno trattiene tutto per sé: un socio avaro, un familiare che non presta niente, un capo che taglia ogni spesa. La tua cerchia vive col fiato corto.
- 3: Fra la gente che frequenti chi possiede è posseduto dalle sue cose: controlla, conta, sospetta. Ti tocca abitare un posto dove ogni moneta stretta stringe anche le persone.

## Cinque di Denari

### dritta

- 1: Intorno a te c'è chi soffre il freddo: persone in difficoltà, un ambiente che esclude, due figure che camminano nella neve sotto una vetrata accesa. Il tuo mondo vicino conosce la mancanza.
- 2: Nella tua cerchia qualcuno si sente lasciato fuori: un collega messo da parte, un parente in ristrettezze, un gruppo che non ti fa entrare. Eppure a pochi passi c'è una finestra illuminata.
- 3: Chi ti circonda attraversa un inverno duro e fatica a chiedere aiuto per orgoglio. Il luogo in cui vivi ha una porta calda poco lontano che nessuno ha ancora bussato.

### capovolta

- 1: Nel tuo ambiente una porta si apre: qualcuno offre riparo, un gruppo ti riaccoglie, un sostegno arriva da chi non te lo aspettavi. Intorno a te il freddo comincia ad allentarsi.
- 2: Intorno a te le persone tornano a darsi una mano dopo un periodo duro: vicini solidali, amici che si fanno vivi. La tua cerchia riaccende il fuoco per chi era fuori.
- 3: Fra la gente vicina chi era rimasto escluso rientra, piano, nel calore della casa. Ti muovi in un ambiente che riapre la finestra a chi bussava nella neve.

## Sei di Denari

### dritta

- 1: Intorno a te l'aiuto circola: una persona generosa pesa con la bilancia ciò che dà e lo distribuisce a chi ne ha bisogno. Il tuo ambiente è fatto di scambi giusti.
- 2: Nella tua cerchia c'è chi sostiene senza umiliare: un parente che presta, un amico che restituisce il favore, un capo che premia con equità. Le persone vicine ti tendono la mano aperta.
- 3: Chi ti circonda sa dare e sa ricevere: si condividono pasti, strumenti, tempo. Il luogo in cui vivi è una piazza dove le monete passano di mano in mano con misura.

### capovolta

- 1: Nel tuo ambiente gli scambi sono sbilanciati: c'è chi prende senza ricambiare, chi dona per tenere gli altri in debito. Intorno a te la bilancia del mercante pende da una parte.
- 2: Intorno a te gli aiuti arrivano con le condizioni: un prestito che diventa ricatto, un favore che si paga in obbedienza. La tua cerchia confonde la generosità col potere.
- 3: Fra le persone che frequenti qualcuno ti svuota chiedendo sempre e non dando mai. Ti tocca vivere in un posto dove la mano tesa resta tesa da un lato solo.

## Sette di Denari

### dritta

- 1: Intorno a te le persone aspettano il raccolto con pazienza: un lavoro comune che matura piano, un orto di famiglia che cresce. Il tuo ambiente si appoggia alla zappa e guarda la pianta.
- 2: Nella tua cerchia si valuta con calma ciò che è stato fatto: bilanci, verifiche, conversazioni sul da farsi. Gli altri ti insegnano che le cose buone vogliono tempo.
- 3: Chi ti sta vicino ha investito con te e ora aspetta senza fretta: un socio paziente, un parente che crede nel progetto. Il tuo luogo è un campo che matura con calma.

### capovolta

- 1: Nel tuo ambiente c'è chi vuole i frutti subito: un capo che pretende risultati, un parente che si lamenta perché non vede niente. Intorno a te si strappano piante per guardare le radici.
- 2: Intorno a te uno sforzo comune sembra mal ripagato: un'impresa che non rende, un orto che non dà. La tua cerchia si scoraggia e mette in dubbio il seme.
- 3: Fra la gente che frequenti l'impazienza guasta il lavoro: si cambia strada a metà stagione, si abbandona il campo. Ti muovi in un ambiente che non sa aspettare.

## Otto di Denari

### dritta

- 1: Intorno a te c'è aria di bottega: persone che lavorano con cura, un maestro che incide le monete una alla volta. Il tuo ambiente in questo periodo premia la dedizione e il mestiere.
- 2: Nella tua cerchia qualcuno ti insegna un'arte con pazienza: un collega esperto, un artigiano, un genitore preciso. Le persone vicine ti mostrano come si affina un gesto.
- 3: Chi ti circonda è operoso e meticoloso: un ufficio dove si fa bene, una casa dove si ripara invece di buttare. Il luogo in cui vivi ha il ritmo di una bottega.

### capovolta

- 1: Nel tuo ambiente il lavoro si fa senz'anima: gesti ripetuti, ore contate, nessuno che metta cura. Intorno a te le monete escono tutte uguali e nessuno le guarda.
- 2: Intorno a te la monotonia ha preso il posto del mestiere: colleghi che timbrano e basta, un'azienda che ha perso la passione. La tua cerchia lavora per dovere.
- 3: Fra la gente vicina c'è chi lavora troppo e male, chiuso in una routine che logora. Ti tocca vivere accanto a una bottega che ha dimenticato perché esiste.

## Nove di Denari

### dritta

- 1: Intorno a te c'è un giardino curato: vigne cariche, un falco sul guanto, una casa tranquilla e agiata. Il tuo ambiente in questo periodo è un luogo tuo che gli altri rispettano.
- 2: Nella tua cerchia le persone vivono con agio e indipendenza: ciascuno ha il suo spazio, nessuno invade. Gli altri ti lasciano godere di ciò che hai costruito.
- 3: Chi ti sta vicino ti riconosce autonomia e buon gusto: un vicinato elegante, amici raffinati, un luogo dove passeggi fra i frutti. La casa che ti circonda è comoda e silenziosa.

### capovolta

- 1: Nel tuo ambiente si spende per apparire: case mostrate, acquisti fatti per farsi vedere. Intorno a te l'agio vacilla sotto il peso di chi vuole sembrare più di ciò che ha.
- 2: Intorno a te qualcuno mette a rischio l'indipendenza comune: un parente che sperpera, un socio che fa debiti. La tua cerchia vede il giardino perdere le sue vigne.
- 3: Fra la gente che frequenti l'autonomia si è fatta isolamento dorato: belle case, poche visite. Ti muovi in un ambiente elegante dove si vive ognuno nel proprio recinto.

## Dieci di Denari

### dritta

- 1: Intorno a te c'è un clima stabile con radici profonde: persone di età diverse sotto lo stesso tetto, una casa antica che passa di generazione in generazione. Il tuo ambiente è solido.
- 2: Nella tua cerchia le cose durano: un'azienda di famiglia, tradizioni tramandate, legami che resistono ai decenni. Le persone vicine ti offrono la stabilità di chi ha costruito per chi viene dopo.
- 3: Chi ti circonda appartiene a una storia lunga e ti ci fa entrare: un clan, una comunità di paese, una dinastia di mestiere, stemmi alle pareti e porte aperte ai parenti.

### capovolta

- 1: Nel tuo ambiente c'è una contesa su beni comuni: una casa di famiglia da dividere, parenti che non si parlano per un terreno, ciò che era di tutti diventato motivo di attrito.
- 2: Intorno a te la famiglia si spacca per questioni di soldi o di proprietà: telefonate gelide, pranzi disertati. La tua cerchia litiga sotto l'arco che dovrebbe unirla.
- 3: Fra la gente vicina le tradizioni pesano come catene: aspettative di casato, ruoli imposti dai vecchi. Ti tocca abitare una dimora solida che toglie aria a chi ci nasce.

## Fante di Denari

### dritta

- 1: Intorno a te c'è chi studia e impara: un apprendista, un figlio che prepara un esame, un collega che segue un corso, gente che osserva le cose con attenzione.
- 2: Nella tua cerchia c'è una persona giovane e seria che ti porta un'idea concreta: un progetto pratico, un'offerta di formazione, un piano dettagliato. Gli altri ti invitano a imparare con loro.
- 3: Chi ti circonda in questo periodo è applicato e diligente: libri sul tavolo, appunti, ore di pratica, come in un campo arato dove si studia il terreno prima di seminare.

### capovolta

- 1: Nel tuo ambiente ci sono progetti lasciati a metà da altri: corsi abbandonati, lavori iniziati e mai finiti, promesse di studio non mantenute. Intorno a te la moneta è caduta di mano.
- 2: Intorno a te un giovane distratto perde tempo e occasioni: rimanda, si annoia, cambia idea. La tua cerchia aspetta da lui un impegno che non arriva mai.
- 3: Fra la gente che frequenti si parla di formarsi e di migliorare e non si fa niente. Ti muovi in un posto pieno di buoni propositi che restano nei quaderni.

## Cavaliere di Denari

### dritta

- 1: Intorno a te ci sono persone affidabili e metodiche: un collega che non sbaglia una scadenza, un parente su cui contare sempre, un ambiente che avanza piano come un cavallo da tiro.
- 2: Nella tua cerchia il lavoro va avanti con costanza: nessuno corre, nessuno si ferma. Le persone vicine ti danno la sicurezza di chi fa ogni giorno la sua parte.
- 3: Chi ti circonda è prudente e paziente: un socio che verifica i conti due volte, un amico che mantiene la parola, gente col passo lento di chi ara un solco dritto.

### capovolta

- 1: Nel tuo ambiente la prudenza blocca tutto: pratiche ferme, riunioni rinviate, chi rimanda ogni tappa per paura di sbagliare. Intorno a te il cavallo sta immobile in mezzo al campo.
- 2: Intorno a te la costanza di qualcuno si è fatta immobilità: un ufficio fermo da anni, un parente che non si muove, una cerchia che vede la meta e non avanza.
- 3: Fra le persone che frequenti la lentezza è diventata pigrizia: si aspetta che le cose si facciano da sé. Ti tocca spingere un carro comune che nessuno vuole tirare.

## Regina di Denari

### dritta

- 1: Intorno a te c'è una persona pratica e accogliente che si occupa di tutti: tiene la casa, i conti, l'orto, con un coniglio che salta fra le rose. Il tuo ambiente è curato da mani concrete.
- 2: Nella tua cerchia c'è chi unisce cuore e concretezza: prepara da mangiare quando ne hai bisogno, ti presta ciò che manca, sa risolvere. Le persone vicine ti offrono un nido ben tenuto.
- 3: Chi ti sta vicino ha i piedi per terra e la casa in ordine: una madre di famiglia, una collega organizzata, un'amica che pensa a tutto. Il luogo in cui vivi somiglia a un giardino fertile.

### capovolta

- 1: Nel tuo ambiente qualcuno si consuma per gli altri senza che nessuno lo veda: regge la casa, i conti, i bisogni di tutti. Intorno a te chi cura non viene curato.
- 2: Intorno a te la cura si è fatta controllo pratico: chi tiene i soldi decide tutto, chi gestisce la casa pretende gratitudine. La tua cerchia vive in un ordine che soffoca.
- 3: Fra la gente vicina il giardino è stato trascurato: la casa va a rotoli, nessuno si occupa più delle cose concrete. Ti tocca vivere fra mura dove l'accoglienza si è dispersa.

## Re di Denari

### dritta

- 1: Intorno a te c'è una persona solida e prospera: un datore di lavoro generoso, un parente benestante seduto fra grappoli d'uva e torri. Il tuo ambiente si appoggia alla sua stabilità.
- 2: Nella tua cerchia le risorse sono gestite con saggezza: chi ha di più sa condividere, chi governa lo fa con misura. Le persone vicine ti offrono una base materiale sicura.
- 3: Chi ti circonda ha costruito qualcosa di concreto e lo amministra bene: un'impresa, una proprietà, una comunità organizzata. Il luogo in cui vivi ha le fondamenta di pietra.

### capovolta

- 1: Nel tuo ambiente chi governa i beni lo fa con rigidità: un capo che non investe, un padre che tiene il portafoglio chiuso, un patrimonio comune fermo nelle mani di uno.
- 2: Intorno a te il successo materiale ha indurito qualcuno: conta solo il risultato, le persone diventano cifre. La tua cerchia vive sotto un trono pesante che non sa dare frutto.
- 3: Fra le persone che frequenti il possesso è diventato un modo di comandare: chi paga decide, chi possiede detta legge. Ti muovi in un regno ricco e immobile.

## Asso di Spade

### dritta

- 1: Intorno a te qualcuno dice le cose come stanno: una verità detta chiara, un parere netto che taglia via le ambiguità. Il tuo ambiente impugna una spada dritta coronata d'alloro.
- 2: Nella tua cerchia c'è una persona lucida che fa chiarezza: un consulente, un amico sincero, un capo che decide con logica. Le persone vicine ti aiutano a distinguere il vero dal falso.
- 3: Chi ti circonda ha idee precise e le esprime con onestà: riunioni che arrivano al punto, conversazioni franche a tavola. Il luogo in cui vivi è attraversato da un'aria limpida di montagna.

### capovolta

- 1: Nel tuo ambiente le parole tagliano male: frasi crudeli, verità dette per ferire, critiche affilate. Intorno a te la lama della chiarezza è usata come un'arma.
- 2: Intorno a te le idee sono annebbiate: informazioni che si contraddicono, decisioni confuse, nessuno che faccia chiarezza. La tua cerchia agita una spada nella nebbia e rischia di colpire a caso.
- 3: Fra la gente vicina c'è chi usa l'intelligenza per avere ragione invece che per capire. Ti tocca abitare un posto dove ogni discussione diventa un duello.

## Due di Spade

### dritta

- 1: Intorno a te c'è una tregua tesa: persone che evitano di guardare una questione comune, braccia incrociate sul petto, spade alzate in equilibrio. Il tuo ambiente tiene gli occhi bendati per non scegliere.
- 2: Nella tua cerchia c'è uno stallo che nessuno vuole sciogliere: due parti che si bloccano a vicenda, un conflitto congelato. Gli altri ti chiedono di non prendere posizione.
- 3: Chi ti circonda fa finta di niente davanti all'evidenza: si cambia discorso, si rimanda la riunione. Il luogo in cui vivi somiglia a una riva notturna con il mare immobile.

### capovolta

- 1: Nel tuo ambiente la tregua si scioglie: qualcuno si toglie la benda, una questione comune torna a galla e chiede una risposta. Intorno a te le spade incrociate si abbassano.
- 2: Intorno a te le persone smettono di evitare: si parla finalmente di ciò che tutti sapevano, si prendono posizioni. La tua cerchia esce da un silenzio che durava da troppo.
- 3: Fra la gente vicina un conflitto congelato si rimette in moto e ti tira dentro. Ti tocca vivere in un posto dove una scelta rinviata da tutti torna sul tavolo.

## Tre di Spade

### dritta

- 1: Intorno a te un dolore attraversa la casa: una separazione, un tradimento, parole che hanno trafitto il cuore di qualcuno. Il tuo ambiente è sotto una pioggia fitta di nuvole grigie.
- 2: Nella tua cerchia c'è una delusione condivisa: un amico che ha ferito, un progetto comune spezzato, una notizia che fa male a tutti. Le persone vicine portano tre lame nello stesso petto.
- 3: Chi ti sta vicino soffre e il suo dolore si sente in ogni stanza: lacrime trattenute, porte chiuse, silenzi pesanti. Il luogo in cui vivi è segnato da una ferita che nessuno nasconde.

### capovolta

- 1: Nel tuo ambiente una ferita comune comincia a rimarginarsi: chi aveva offeso chiede scusa, chi era offeso ascolta. Intorno a te la pioggia si fa più leggera.
- 2: Intorno a te le persone si perdonano dopo un periodo doloroso: si torna a sedersi alla stessa tavola, si sfilano le spade dal cuore. La tua cerchia respira di nuovo.
- 3: Fra la gente vicina un dolore antico smette di sanguinare e diventa racconto. Ti muovi in un ambiente che porta ancora la cicatrice e ha smesso di riaprirla.

## Quattro di Spade

### dritta

- 1: Intorno a te c'è quiete: una casa silenziosa, un ufficio in pausa, persone che ti lasciano recuperare senza chiedere. Il tuo ambiente somiglia a una cappella dove si riposa sotto una vetrata.
- 2: Nella tua cerchia si rispetta il bisogno di sosta: nessuno ti chiama, nessuno ti cerca. Le persone vicine abbassano i toni e lasciano le spade appese al muro.
- 3: Chi ti circonda in questo periodo rallenta: ferie, domeniche lunghe, un tempo di raccoglimento comune. Il luogo in cui vivi è una stanza fresca con le tende accostate.

### capovolta

- 1: Nel tuo ambiente la pausa finisce: l'ufficio riapre, la casa si rianima, le persone tornano alle loro faccende. Intorno a te le spade vengono staccate dal muro.
- 2: Intorno a te chi riposava si alza e ti chiama: un collega che riprende il lavoro, un parente che torna attivo. La tua cerchia ti invita a uscire dal silenzio.
- 3: Fra la gente che frequenti la quiete si è fatta immobilità e ora qualcuno la scuote con decisione. Ti muovi in un posto che si risveglia dopo un lungo sonno.

## Cinque di Spade

### dritta

- 1: Intorno a te c'è chi ha vinto male: raccoglie le spade degli altri e sorride mentre i vinti se ne vanno curvi verso il mare. Il tuo ambiente porta il segno di un'umiliazione.
- 2: Nella tua cerchia l'orgoglio ha diviso le persone: chi ha avuto ragione e chi è stato schiacciato non si parlano più. Gli altri ti guardano per capire da che parte stai.
- 3: Chi ti circonda ha combattuto per vincere a ogni costo e ha perso amici per strada. Il luogo in cui vivi ha un cielo spezzato da nuvole taglienti sopra un campo di battaglia.

### capovolta

- 1: Nel tuo ambiente nasce voglia di riconciliazione: chi aveva vinto restituisce le spade, chi aveva perso torna a parlare. Intorno a te si depongono le armi.
- 2: Intorno a te le persone si stancano dello scontro: una lite di famiglia si spegne, un ufficio diviso cerca un accordo. La tua cerchia preferisce la pace alla ragione.
- 3: Fra la gente vicina qualcuno fa il primo passo dopo un conflitto amaro e tende la mano. Ti muovi in un ambiente che prova a ricucire ciò che l'orgoglio aveva strappato.

## Sei di Spade

### dritta

- 1: Intorno a te c'è un trasferimento in corso: una famiglia che cambia città, un ufficio che si sposta, una barca che porta persone verso acque calme. Il tuo ambiente sta lasciando la tempesta.
- 2: Nella tua cerchia qualcuno ti accompagna in una transizione: un traghettatore paziente, un amico che guida mentre tu guardi la riva. Le persone vicine ti portano oltre il mare agitato.
- 3: Chi ti circonda si allontana in silenzio da un periodo difficile: si cambia aria, si cambia casa. Il luogo in cui vivi è una riva più serena raggiunta remando piano.

### capovolta

- 1: Nel tuo ambiente un trasloco fatica: scatoloni mai spediti, persone che non vogliono lasciare la vecchia sponda. Intorno a te la barca è pronta e nessuno sale.
- 2: Intorno a te chi è partito porta con sé troppo peso: rimpianti, rancori, vecchie abitudini. La tua cerchia attraversa il mare con la barca carica fino all'orlo.
- 3: Fra la gente vicina c'è chi rema indietro verso la tempesta da cui stava uscendo. Ti tocca viaggiare con compagni che guardano sempre la riva lasciata.

## Sette di Spade

### dritta

- 1: Intorno a te qualcuno agisce di nascosto: porta via spade dall'accampamento in punta di piedi, guardandosi alle spalle. Il tuo ambiente in questo periodo chiede occhi aperti e tatto.
- 2: Nella tua cerchia si usano strategie e astuzie: alleanze silenziose, informazioni tenute per sé, mosse calcolate. Le persone vicine giocano una partita che non ti mostrano per intero.
- 3: Chi ti circonda preferisce l'ingegno alla forza: aggira gli ostacoli, evita i conflitti aperti. Il luogo in cui vivi è un campo di tende dove non tutto si dice.

### capovolta

- 1: Nel tuo ambiente un inganno viene a galla: una bugia di un collega, un segreto di famiglia, un furto di fiducia che si scopre. Intorno a te le spade rubate tornano alla luce.
- 2: Intorno a te chi aveva mentito comincia a sentirne il peso e confessa: una verità arriva tardi ma arriva. La tua cerchia esce da un periodo di sotterfugi.
- 3: Fra la gente che frequenti le astuzie si ritorcono contro chi le ha tramate e i giochi si chiariscono. Ti muovi in un ambiente che torna alla trasparenza.

## Otto di Spade

### dritta

- 1: Intorno a te c'è chi ti lega senza corde vere: pareri, aspettative, regole non scritte che ti bendano. Il tuo ambiente ti circonda di spade piantate nel fango, con varchi che nessuno indica.
- 2: Nella tua cerchia qualcuno ti fa credere di non avere scelta: un capo che minaccia, un parente che colpevolizza, amici che ripetono che non si può. Ti tengono in una gabbia di parole.
- 3: Chi ti circonda vive in una prigione mentale e ti contagia con la sua paura: tutto sembra vietato, rischioso, impossibile. Dove vivi c'è un castello lontano e nessuno guarda la strada.

### capovolta

- 1: Nel tuo ambiente le corde cadono: una regola assurda viene abolita, qualcuno smette di trattenerti, un parere oppressivo perde peso. Intorno a te le spade si diradano e si vede il varco.
- 2: Intorno a te le persone si accorgono che la gabbia era fatta di convinzioni e si tolgono la benda una dopo l'altra. La tua cerchia esce dal fango e cammina.
- 3: Fra la gente vicina chi ti legava con i sensi di colpa allenta la presa e ti lascia andare. Ti muovi in un ambiente che smette di trattenere.

## Nove di Spade

### dritta

- 1: Intorno a te c'è ansia diffusa: una casa che non dorme, le preoccupazioni degli altri che ti tolgono il sonno, telefonate alle tre del mattino, una camera buia piena di lame.
- 2: Nella tua cerchia qualcuno rimugina e trasmette angoscia: un genitore in pena, un amico che vede tutto nero. Le persone vicine portano nel letto le loro paure e ti chiamano per condividerle.
- 3: Chi ti circonda vive giorni tesi e notti insonni: scadenze, timori, pensieri che girano in tondo. Il luogo in cui vivi ha le mani di molti sul viso, seduti sul bordo del materasso.

### capovolta

- 1: Nel tuo ambiente qualcuno finalmente parla di ciò che lo angosciava e il peso si dimezza per tutti. Intorno a te la notte comincia a schiarire e le paure perdono forma.
- 2: Intorno a te le preoccupazioni condivise si ridimensionano: si scopre che il pericolo era più piccolo, si dorme meglio. La tua cerchia esce da un incubo comune.
- 3: Fra la gente vicina l'alba porta conforto dopo notti difficili: una telefonata rassicurante, un abbraccio. Ti muovi in una casa dove si riaccende la luce del mattino.

## Dieci di Spade

### dritta

- 1: Intorno a te una situazione comune ha toccato il fondo: un'azienda che chiude, un gruppo che si scioglie, un rapporto di famiglia finito del tutto. Il tuo ambiente giace a terra sotto un cielo nero.
- 2: Nella tua cerchia qualcuno ha subito un colpo dopo l'altro e non riesce più a rialzarsi senza aiuto. Le persone vicine ti chiedono di riconoscere che quella fase è chiusa.
- 3: Chi ti circonda ha esaurito le forze in una battaglia che è finita davvero. Il luogo in cui vivi vede l'ultima luce gialla dell'orizzonte dietro le macerie di ciò che c'era.

### capovolta

- 1: Nel tuo ambiente si ricomincia da zero dopo una caduta: si tolgono le lame, si rimette in piedi ciò che resta. Intorno a te le persone si rialzano piano, un gesto alla volta.
- 2: Intorno a te una cerchia ferita ricostruisce: un'azienda che riapre con altre persone, una famiglia che si riorganizza. La tua gente risale dal punto più basso.
- 3: Fra la gente vicina chi era a terra trova la forza di sollevarsi e ti tende la mano per fare lo stesso. Ti muovi in un luogo che rinasce sulle rovine.

## Fante di Spade

### dritta

- 1: Intorno a te ci sono persone vigili e curiose: un giovane che osserva tutto, un collega che si informa, occhi attenti dietro ogni porta. Il tuo ambiente tiene la spada alzata nel vento.
- 2: Nella tua cerchia qualcuno indaga e riferisce: fa domande, verifica, porta notizie fresche. Le persone vicine ti tengono al corrente di ciò che succede intorno.
- 3: Chi ti circonda ha la mente acuta e la lingua pronta: dibattiti vivaci, curiosità intellettuale, nessuna cosa data per scontata. Il luogo in cui vivi è una collina ventosa da cui si vede lontano.

### capovolta

- 1: Nel tuo ambiente girano pettegolezzi: chi parla a vanvera, chi riferisce male, lingue che pungono alle spalle. Intorno a te le parole volano come spade nel vento.
- 2: Intorno a te qualcuno spia e mette in giro storie: un vicino curioso, un collega che sparla. La tua cerchia vive di sospetti e di chiacchiere non verificate.
- 3: Fra la gente che frequenti si critica tutto e si costruisce poco: osservazioni pungenti, ironie taglienti. Ti muovi in un posto dove ogni frase può ferirti.

## Cavaliere di Spade

### dritta

- 1: Intorno a te arriva qualcuno di carica, con idee nette e la spada in avanti: un capo deciso, un amico che non accetta compromessi. Il tuo ambiente si muove al galoppo.
- 2: Nella tua cerchia si decide in fretta e si agisce subito: riunioni brevi, scelte nette, persone che vanno dritte allo scopo. Gli altri ti trascinano nella loro determinazione.
- 3: Chi ti circonda in questo periodo ha la mente veloce e non aspetta: propone, contesta, corre avanti. Il luogo in cui vivi è attraversato da un vento che piega gli alberi.

### capovolta

- 1: Nel tuo ambiente qualcuno lancia parole affilate senza pensare: un collega che offende di corsa, un parente che travolge con le sue certezze. Intorno a te la carica fa feriti.
- 2: Intorno a te la fretta altrui produce danni: decisioni sbagliate prese al galoppo, litigi che esplodono dal nulla. La tua cerchia corre senza guardare chi calpesta.
- 3: Fra la gente vicina c'è chi vuole avere ragione subito e non ascolta nessuno. Ti tocca vivere accanto a una mente che galoppa più veloce del buon senso.

## Regina di Spade

### dritta

- 1: Intorno a te c'è una persona franca e lucida che dice il vero senza giri, una consigliera o un'amicizia schietta, con la spada dritta. Il tuo ambiente ha confini chiari.
- 2: Nella tua cerchia si parla con sincerità anche quando è scomodo: niente lusinghe, niente sotterfugi. Le persone vicine ti offrono un giudizio limpido su cui puoi contare.
- 3: Chi ti circonda ha attraversato prove dure e ne porta la mente affilata: sa distinguere, sa proteggere. Il luogo in cui vivi ha un cielo terso sopra le nuvole basse.

### capovolta

- 1: Nel tuo ambiente regna la freddezza: giudizi duri, porte chiuse, una persona vicina chiusa in una corazza di sarcasmo. Intorno a te la lama della lucidità si è fatta ghiaccio.
- 2: Intorno a te qualcuno ferisce con le parole per non essere ferito: critiche continue, distanza calcolata. La tua cerchia vive accanto a una solitudine scelta come difesa.
- 3: Fra la gente che frequenti si giudica con severità e si perdona poco: ogni errore viene annotato. Ti muovi in un ambiente tagliente dove manca la tenerezza.

## Re di Spade

### dritta

- 1: Intorno a te c'è un'autorità equa e lucida: un esperto, un giudice saggio, un capo che decide con la ragione al servizio delle persone. Il tuo ambiente si regge su di lei.
- 2: Nella tua cerchia le decisioni si prendono con logica ed etica: si ascoltano le parti, si pesano i fatti. Le persone vicine ti offrono un riferimento solido e onesto.
- 3: Chi ti circonda ha in mano la spada della verità e la tiene dritta: regole chiare, parola data, rispetto delle competenze. Il luogo in cui vivi è governato da una mente limpida.

### capovolta

- 1: Nel tuo ambiente comanda un'autorità dura che dimentica le persone: un capo freddo, un regolamento applicato senza cuore. Intorno a te la ragione vince e i legami si spezzano.
- 2: Intorno a te qualcuno usa l'intelligenza per dominare: manipola con le parole, schiaccia con la logica. La tua cerchia vive sotto un trono di pietra fredda.
- 3: Fra la gente vicina il rigore ha preso il posto della giustizia: si applicano regole e si dimenticano i volti. Ti tocca abitare un posto dove il cuore non ha parola.
