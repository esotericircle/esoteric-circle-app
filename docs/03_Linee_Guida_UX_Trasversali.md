Linee Guida UX Trasversali

*Esoteric Circle, documento di bussola per lo sviluppo in autonomia*

Quarto documento guida, complementare al Briefing Progetto, al Master Tecnico e al Briefing Operativo MVP e Demo. Definisce le convenzioni comuni a tutte le funzionalita: come l utente interagisce, come si presenta ogni responso, come funziona il livello visivo, la condivisione e i fallback. Giugno 2026.

# 1. Scopo e principio guida

Questo documento non descrive le singole funzionalita una per una, ma le regole trasversali che valgono per tutte. Serve come bussola per lo sviluppo in autonomia: dove una funzione non ha una UX dettagliata propria, si applicano queste convenzioni come default. Il principio guida e uno solo: ogni esperienza deve sembrare un incontro con un Maestro, non l uso di uno strumento. Coerenza, calma, senso di destino personale, e sempre un livello visivo prima del testo.

# 2. Anatomia di un responso (vale per ogni funzione)

Ogni responso dell app, qualunque sia la funzione che lo genera, segue la stessa struttura a quattro strati, sempre nello stesso ordine. Questo garantisce coerenza percepita e riconoscibilita.

Strato 1, il colpo d occhio visivo. Prima di qualsiasi testo compare il dato in forma grafica: percentuale grande che sale, anello di favorevolezza che si riempie, barre per categoria, onde, radar, calendario. Si costruisce con micro-animazione (riempimento progressivo, conteggio che sale, icone che pulsano). E la regola del livello visivo immediato gia approvata: il visivo invoglia alla lettura.

Strato 2, la sintesi in una frase. Una riga forte e memorabile che riassume il responso, nel tono del Maestro competente. E la frase che l utente vorrebbe condividere.

Strato 3, il testo narrato. L interpretazione estesa, prodotta dal sistema ibrido, nel tono e con la voce Gemini-TTS del Maestro. Espandibile: si mostra un estratto e si apre il resto al tocco, per non spaventare chi non ama leggere.

Strato 4, l azione. Sempre presenti in fondo: pulsante Condividi (genera la card brandizzata del Maestro), eventuale Salva nel Cosmic Journal o nel profilo, ed eventuale rimando a una funzione collegata. Il disclaimer per intrattenimento e crescita personale e sempre a pie di card.

# 3. La card condivisibile (formato unico)

La card e l unita virale del prodotto e ha un formato coerente ovunque. Contiene: sfondo nella palette del Maestro che la genera (blu chiaro e oro Medora, verde smeraldo e oro Aura, rosso e oro Caligo), il visivo principale del responso, la frase sintesi, l avatar o il sigillo del Maestro, il watermark e il logo dell app, e un deep link nativo. Rapporto adatto alle storie social in verticale. Ogni card condivisa apre l app se installata, altrimenti porta allo store con contesto pre-compilato.

# 4. I tre stati di ogni funzione

Coerente con il modello a feature flag dell app nativa unica. Ogni funzione si trova sempre in uno di tre stati visivi, gestiti centralmente.

Attiva: pienamente funzionante e rifinita.

Coming soon: visibile ma in grigio o semitrasparenza, con badge, per mostrare la ricchezza dell ecosistema senza svilupparla ora. Il tocco mostra un anticipo elegante, non un errore.

Premium bloccata: visibile, con lucchetto e invito all upgrade del tier corretto, mai un vicolo cieco.

# 5. Il modello dei dati: stabile piu variabile

Regola gia adottata ovunque e da rispettare per ogni nuova funzione. Si distinguono due nature di contenuto.

Identitario e fisso: calcolato una volta in modo deterministico e immutabile per la persona. Esempi: carta natale, Angelo Custode, archetipo, Animale Guida. Si rivela una volta con cerimonia, poi si consulta on-demand dal profilo.

Oracolare e variabile: esito diverso a ogni estrazione, con vera casualita. Esempi: tarocchi, rune, I-Ching, pendolo, fondi di caffe. Qui ogni consultazione e un evento nuovo.

Ibrido stabile piu variabile: una base stabile della persona piu una sfumatura quotidiana data dai transiti. Esempi: Costellazione del Viso, chiromanzia, grafologia esoterica, e il Messaggio da [nome animale]. La base e coerente nel tempo, il messaggio del giorno cambia col cielo.

Regola di coerenza dei responsi: a parita di domanda nello stesso giorno il responso resta valido per la giornata, per evitare l effetto slot-machine e sostenere il claim diversa per tutti e differente per ognuno.

# 6. Interazione e sensori: la scala dei gesti

Ogni esperienza sceglie il gesto piu immersivo possibile, ma con fallback obbligatorio a gesto tattile, secondo la regola d oro del progetto. La scala, dal piu ricco al piu universale.

Sensori avanzati come esperienza premium: giroscopio (oroscopo col telefono alzato al cielo), microfono (rivelazione del Maestro col soffio), accelerometro e scuotimento (lancio rune, mescolata carte), videocamera (Costellazione del Viso, in futuro chiromanzia).

Gesto tattile come fallback universale, mai una versione di serie B: tap, swipe, sfregata stile gratta e vinci, tracciatura col dito. Chi non ha il sensore o nega il permesso vive comunque l esperienza con dignita piena.

Caso speciale gia risolto: le funzioni che si basano sulla scrittura o sul disegno col dito (grafologia esoterica, Sigillo magico) usano il tocco come gesto nativo, quindi non hanno bisogno di alcun fallback.

# 7. Convenzioni della cartomanzia e degli oracoli a carte

Sezione dedicata perche la cartomanzia e la funzione principale voluta dai fondatori e merita regole esplicite, valide per tutte le stese e per tutti gli oracoli a carte.

## 7.1 Mazzi multipli (gia previsto, qui formalizzato)

L app prevede piu mazzi disponibili, gia indicato nel dominio di Medora e nella sezione Oracoli. Convenzione di prodotto: ogni stesa parte da un selettore di mazzo, con un mazzo di default attivo subito e gli altri sbloccabili. Mazzi previsti: Rider-Waite (default ideale), Marsiglia, Thoth. La scelta del mazzo cambia solo l artwork, non la logica ne i significati. Asset generati tramite il modello di generazione immagini di Vertex AI con immagine pilota di riferimento per la coerenza dell intero set; rifinitura manuale solo eventuale e posticipata. Stile del mazzo definito in Fase B: Total Metal multicolore inciso in rilievo, con carta pilota master Il Sole e cornice madre fissa oro e blu Medora (nel cartiglio cambiano solo nome carta e numero romano). Il dorso del mazzo e un asset dedicato (luna e onde in metallo inciso, simmetrico, uguale dritto e capovolto), declinabile sul colore del Maestro attivo. Gli altri mazzi (Marsiglia, Thoth) restano nello stesso stile metallo e si distinguono per iconografia. Flusso: esplorazione dello stile su NEXOS e Nano Banana 2, consolidamento e batch su Vertex AI con immagine pilota di riferimento. Localizzazione dei nomi carta: l artwork si genera con entrambi i cartigli, superiore e inferiore, vuoti: sia il numerale o valore sia il nome carta sono stringhe sovrapposte a runtime nel font dorato, coerente col fatto che l app parte in italiano e poi si apre agli altri mercati; un solo set di artwork per tutte le lingue, aggiungere una lingua = aggiungere traduzioni. In alternativa, solo per un eventuale effetto premium, il nome puo essere inciso per lingua in fase di consolidamento.

## 7.2 Carte dritte e rovesciate (decisione da confermare)

Nella tradizione dei tarocchi una carta puo presentarsi dritta o rovesciata, e l orientamento ne modifica o sfuma il significato. E un elemento di profondita e autenticita molto apprezzato dagli utenti esperti, e a costo praticamente nullo: e solo una rotazione di 180 gradi dell artwork piu una seconda riga di significato nel database. Proposta di convenzione: ogni carta ha una probabilita di uscire rovesciata, l artwork ruota di 180 gradi nell animazione del flip, e il significato base nel database ha due varianti, dritto e rovesciato, da cui il sistema ibrido attinge per il testo. Per non penalizzare chi e alle prime armi, si prevede un interruttore nelle impostazioni della cartomanzia, Includi carte rovesciate, attivo di default ma disattivabile. Questa funzione vale per tutte le stese e per la carta singola quotidiana. Nota: questa convenzione e proposta in questo documento ma va confermata e poi integrata anche nei tre briefing nelle sezioni cartomanzia e Master Tecnico (database significati a due varianti).

## 7.3 Meccanica comune della stesa

Indipendentemente dal numero di carte, la sequenza e sempre questa: il Maestro apre il mazzo a ventaglio con effetto finto-3D, invita a scegliere con l istinto, l utente puo mescolare scuotendo il telefono (fallback tap), tocca le carte necessarie che si staccano e volano in posizione, le carte si girano una a una col flip animato (con eventuale rovesciamento), il Maestro narra prima ogni posizione poi la sintesi con voce Gemini-TTS, infine si genera la card condivisibile. Numeri di carte fissi della tradizione: 1 carta singola, 3 Passato Presente Futuro, 7 Relazione, 10 Croce Celtica. La Croce Celtica e stesa premium. La stessa meccanica di stesa vale per l Oracolo degli Angeli (Fase 2, dominio Medora): estrazione e stesa dal mazzo dei 72 Angeli con la medesima sequenza (ventaglio, scelta, flip, narrazione, card), esito oracolare variabile, distinto dall Angelo Custode identitario fisso.

## 7.4 Tre chiavi di lettura della cartomanzia

Prima di ogni stesa l utente sceglie la chiave di lettura, oltre alla profondita della risposta. Le tre chiavi: predittiva e divinatoria nel tono di Medora (risposte su eventi della vita); riflessione personale ispirata alla Tarologia di Alejandro Jodorowsky (le carte come strumento di crescita e consapevolezza, senza finalita predittiva, Tarocco di Marsiglia di preferenza); esoterica e iniziatica nel tono di Caligo (le carte come simboli di verita spirituali, archetipi e Albero della Vita). La selezione della chiave appare nella stessa schermata del selettore di mazzo e della profondita, in modo coerente. Convenzione: il riferimento a Jodorowsky e una citazione di ispirazione dichiarata, mai un marchio della funzione, con disclaimer divulgativo. Le tre chiavi sono attive dall MVP e accessibili a tutti i tier, perche il controllo dei costi e gia dato dai limiti di stese giornaliere per tier.

# 8. Tono di voce e linguaggio dei Maestri

Ogni testo rispetta il tono del Maestro che lo pronuncia. Medora: elegante, melodico, evocativo, con pause. Aura: caldo, accogliente, contemplativo, con respiri. Caligo: profondo, solenne, autorevole, da saggio potente e custode, mai oscuro o minaccioso. Regole comuni a tutti: linguaggio inclusivo, mai diagnosi mediche, psicologiche, finanziarie o legali; mai promesse deterministiche sul futuro; sempre la cornice di crescita personale. I rituali e i contenuti esoterici attingono solo a tradizioni reali e documentate, mai inventate.

# 9. Cerimonia di rivelazione delle feature identitarie

Le feature identitarie e fisse condividono lo stesso schema cerimoniale, per dare peso emotivo al momento. Una rivelazione una tantum con animazione dedicata (la nebbia che si dirada per l Animale Guida di Caligo, l apparizione luminosa per l Angelo Custode, eccetera), poi l oggetto entra stabilmente nel profilo identitario dell utente, il Cosmic Passport, accanto agli altri. Da li si consulta on-demand quando l utente vuole, ed eventualmente espone una card di messaggio del giorno variabile sui transiti. Vale per Angelo Custode, archetipo e Animale Guida con il suo Messaggio da [nome animale].

# 10. Il livello visivo per tipo di dato (libreria data-viz)

Per coerenza, ogni tipo di responso usa sempre lo stesso componente visivo. Questa e la libreria di riferimento.

Favorevolezza o intensita di una giornata o di un area: anello che si riempie con percentuale al centro (oroscopo 4 versioni, consigli lunari).

Confronto tra piu voci o aspetti: barre orizzontali animate (sinastria per aspetto, tratti del volto, parametri grafologici).

Punteggio unico di compatibilita o affinita: numero grande che sale piu eventuale cuore o aura pulsante (Sinastria Celeb, compatibilita a tre livelli).

Cicli e andamenti nel tempo: onde animate (bioritmo, fasi lunari).

Mappe e posizioni: ruota natale 2.5D, cielo stellato dinamico, Albero della Vita 2.5D, costellazione di punti collegati (volto).

Estrazioni: animazione dedicata dell oggetto (carte col flip, rune che cadono, pendolo che oscilla, esagramma che si compone).

# 11. Stati vuoti, errori e attese

Anche i momenti tecnici restano in personaggio, mai messaggi di sistema freddi. Caricamento: animazione a tema (stelle che ruotano, fumo, nebbia) con micro-frase del Maestro. Errore o rete assente: messaggio gentile in tono di Maestro, con possibilita di riprovare, mai uno stack tecnico. Permesso sensore negato: passaggio automatico e silenzioso al fallback tattile, senza colpevolizzare l utente. Contenuto non ancora disponibile: anticipo elegante invece di un vuoto.

# 12. Coerenza con economia, tier e gamification

Ogni funzione tiene conto del sistema gia definito senza reinventarlo. La valuta interna e Eos, con reset giornaliero su tutto. La memoria dei Maestri e esclusiva del tier a pagamento e non acquistabile con Eos. La voce e esclusiva del tier superiore. I limiti d uso delle funzioni costose sono per tier e con reset giornaliero. Il banner pubblicitario compare solo nel tier gratuito, mai nei tier a pagamento. I traguardi diventano badge collezionabili e card condivisibili che alimentano il Cosmic Journal e la salita dell Albero della Vita.

# 13. Come uso questo documento in autonomia

In fase di sviluppo, per ogni funzione senza una UX dettagliata propria applico queste convenzioni come default e procedo, senza bloccarmi. Le quattro funzioni a UX complessa (stesa col ventaglio, Cosmic Journal collegato all Albero, Chiedi ai Maestri con sintesi a tre voci, esperienze giroscopio e soffio) le sviluppo con una prima versione fondata e poi le porto in priorita ai checkpoint per la tua revisione su device. Tutto il resto segue questo documento. Eventuali nuove convenzioni che emergono durante lo sviluppo vanno consolidate qui, mai sparse, e mai come addendum nei tre briefing principali.

# 14. Gating visivo universale e tooltip di sblocco

Convenzione valida in tutte le versioni dell app. Ogni funzione non accessibile al tier o esaurita per la giornata resta sempre visibile ma in grigio o non attiva. Al tap non si mostra mai un errore o un vicolo cieco, ma un tooltip che spiega come ottenerla: disponibile con l abbonamento e il nome del livello per le funzioni di tier; per gli esaurimenti giornalieri, un tooltip che offre due strade, acquistare una richiesta aggiuntiva con gli Eos oppure salire di livello. Lo stato e governato dai feature flag piu il controllo dell entitlement. Mostrare cio che si sta perdendo e una leva di conversione costante e rispettosa.

# 15. Tooltip di trasparenza metodologica

Ogni responso espone un piccolo punto interrogativo discreto che, al tap, apre una nota brevissima sulla tradizione, arte o metodo usato per quel calcolo (esempi: Nodi Lunari per il Karma, personologia di Edward Vincent Jones per la Costellazione del Viso, core shamanism per l Animale Guida, effemeridi svizzere per la carta natale, grafologia codificata per la grafologia esoterica). Rende visibile il radicamento in tradizioni reali e documentate, rafforza la credibilita, premia l utente curioso o esperto senza disturbare gli altri. Contenuto statico, scritto una volta per tipo di responso, costo zero di AI. Si lega alla Cosmic Academy.

# 16. Profondita della risposta

Per i responsi testuali, in particolare Chiedi ai Maestri, l utente puo scegliere la profondita tra Breve, Media e Approfondita. Nel livello gratuito la lunghezza e fissa, breve o media; la scelta si sblocca dal Tier 1 in su; la modalita Approfondita e riservata ai livelli superiori. E insieme leva di conversione e controllo dei costi. Anche le risposte brevi rispettano l anatomia del responso e il livello visivo immediato.

# 17. Sigilli del Cammino: convenzione di gamification

I tre sentieri del Cosmic Journal usano lo stesso sistema di traguardi, i Sigilli del Cammino, con grammatica visiva comune e identita per Maestro. Regole trasversali: ogni mini-traguardo genera una card nel formato condivisibile unico, accende sempre l icona del Sigillo al raggiungimento del traguardo (nessun utente escluso, compresi quelli senza social) e assegna un bonus Eos graduato per valore verificabile dell azione (massimo per invito amico che porta un download, alto per social pubblico, medio per condivisione privata verificabile, zero se nessuna azione ma con Sigillo comunque acceso); cinque grandi traguardi a 10, 20, 30, 40, 50 sono sempre visibili in anticipo (modello tessera punti) e crescenti. Apertura del sentiero sempre dall alto: prima si mostra il traguardo 50 in piena luce, poi l animazione scorre in verticale verso il basso e si ferma sul punto raggiunto. Identita: Albero della Vita con i Frutti dell Albero e le Sefirot Maggiori per Caligo; Costellazione personale con le Stelle del Cammino e le Costellazioni per Medora; Fiore di Loto con i Petali del Risveglio e le Fioriture per Aura. Attivazione: nel Free fino al ventesimo traguardo, journal completo dal Tier 1; gli Eos accumulati restano sempre. Tetto giornaliero sulle condivisioni premiate per evitare il farming.

Sigilli sospesi, traguardi raggiunti ma non ancora condivisi. Quando l utente raggiunge un traguardo ma non condivide subito la card, il Sigillo non si accende e il premio in Eos resta in attesa. Per non lasciare il journal con buchi muti che scoraggiano, l icona del Sigillo sospeso non resta semplicemente grigia e inerte: appare in uno stato dedicato, spento ma con un pulsazione luminosa lenta e una piccola marcatura, per segnalare che e gia stato conquistato e attende solo la condivisione. Al tap, anche a distanza di giorni o settimane, l utente riapre la card del traguardo e puo condividerla in qualsiasi momento, accendendo cosi il Sigillo e incassando l Eos in sospeso. In questo modo nessun progresso va perso, il journal non mostra lacune frustranti, e il reminder visivo trasforma ogni Sigillo sospeso in un invito permanente e gentile alla condivisione, recuperando viralita che altrimenti andrebbe persa. Si distinguono quindi due stati del Sigillo: conquistato e acceso (si accende al raggiungimento del traguardo, a prescindere dalla condivisione), e non ancora conquistato (grigio statico, in trasparenza). La condivisione non incide sull accensione ma solo sul bonus Eos graduato.

# 18. Produzione di asset e animazioni: automazione integrale

Convenzione di processo: in prima battuta tutti gli asset visivi e tutte le animazioni dell app sono prodotti dall automazione, senza rifinitura manuale, per privilegiare la velocita. L unica eccezione e l intro cinematografica iniziale, fornita dall utente come video pre-renderizzato. Le regole UX di questo documento (anatomia del responso, livello visivo immediato, card condivisibile, stati delle funzioni, animazioni di apertura dei sentieri) restano pienamente valide e si applicano agli asset automatici esattamente come a quelli rifiniti a mano. La rifinitura manuale e una fase facoltativa e successiva, riservata ai soli momenti wow che non soddisfano, da valutare a posteriori. Stile degli asset di brand fissato in Fase B: le carte e gli asset collezionabili (78 tarocchi, 72 Angeli set unico Medora, cristalli, ritratti VIP col glifo zodiacale) sono in Total Metal multicolore inciso con cornice madre oro e blu Medora; le rune sono pietre di basalto a contorni irregolari in PNG con alpha, non carte, con solo il glifo d oro inciso e nome piu linea a runtime; i Cristalli sono una famiglia di 12 pietre a colore naturale reale e abito nativo distinto; i Ritratti VIP hanno cornice unica universale a finestra ad arco con glifo e nome a runtime; i 12 Animali Guida sono oggetti metallici multicolore isolati senza cornice; ogni famiglia ha la propria cornice e identita (cornice argento dedicata per i 72 Angeli); i tre sfondi Maestro sono in stile pittorico atmosferico full-bleed. La fase esplorativa dello stile si conduce su NEXOS e Nano Banana 2, il consolidamento della pilota e il batch dell intero set su Vertex AI con Nano Banana Pro (Gemini 3 Pro Image) come motore primario; alcuni dettagli precisi (glifi zodiacali, rune codificate, testi minori delle cornici) si compongono come layer tipografico o vettoriale in consolidamento, perche i modelli immagine non li riproducono fedelmente.

*Documento di bussola UX. Insieme ai tre briefing principali, completa la guida per lo sviluppo di Esoteric Circle.*

# 19. Memoria persistente e Specchio dell'Anima: convenzioni UX

La memoria e una sola, globale e condivisa: ogni responso e ogni richiamo di un ricordo parla all'utente come un cerchio unico che lo conosce, mai come tre memorie separate. Quando un Maestro richiama un ricordo, lo fa nella propria lente e nel proprio tono, ma il fatto e lo stesso per tutti. Regola di fiducia trasversale: un Maestro non inventa mai un ricordo; se il dato non e disponibile lo dichiara con garbo e propone Lo Specchio dell'Anima. Lo Specchio dell'Anima ha il formato card condiviso del prodotto (palette dei tre Maestri, tre paragrafi a tre lenti, sintesi, watermark, deep link) ed e tra le card piu condivisibili. Il Filo dei Temi compare come richiamo naturale nel dialogo quando un tema riemerge. Il Diritto all'oblio si presenta come una sezione chiara e non punitiva dove l'utente vede e cancella selettivamente i propri ricordi. Nelle transizioni di tier la comunicazione e sempre di custodia, mai di minaccia: nel Free custodisco cio che mi affidi, al downgrade i tuoi ricordi restano custoditi nel cerchio.

20. Aggiornamenti UX (asset finali e nuove meccaniche). Rune: nome e linea a runtime, lancio con scuotimento, rune che si ordinano da sinistra a destra, nome e lettura di Caligo sotto, scheda al tap. Disclaimer: mostrato una sola volta a onboarding e registrazione, mai su ogni card o responso (accessibile in info e privacy). Le card VIP non riportano disclaimer per-card. Telefono via valore: funzione di consegna WhatsApp o SMS dal Tier 1, promossa con sezione animata inline (preferita) e popup saltuario, con frequency cap, non mostrare piu, mai bloccante, mai nei flussi immersivi. La Sfera della Fortuna (dominio Aura): premio giornaliero, sfera diradata col soffio o col dito, reveal con bagliore poi premio poi card condivisibile, premio sempre dato, un tentativo gratuito al giorno, aggancio allo streak, senza gambling.
