# LA POSIZIONE: CORONA

Cio' che corona, nella Croce Celtica.

**Fonte da riempire.** Per ogni carta e per ogni verso tre varianti dello
stesso scheletro, `- 1:`, `- 2:`, `- 3:`, scritte dall'Architetto (ordine FI,
aggiunta A1 e A4). Una riga vuota e' un testo che non c'e' ancora. Una
variante e' piena in tutte le 156 carte-verso o vuota in tutte: a meta', il
tool si ferma e nomina le righe che mancano.

**Le tre varianti vengono dal corpus dell'11 ottobre 2026**, scritte
dall'Architetto con dodici scrittori e consegnate col commit 394e9c5, pulite
sulle dieci regole del metro. La posizione **non ha un numero**: scritta,
pulita e non provata in prova cieca. Provenienza scritta da Code con l'ordine
FK, aggiunta 2 voce A11, dal messaggio del commit 394e9c5, perche' la regola
FJ.4 vuole che ogni posizione con testi dica da dove vengono.

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

- 1: Il punto più alto di questa spinta è il passo mosso con le mani libere: sulla tua questione l'altezza sta nel partire senza bagaglio; si ferma dove comincia una strada disegnata dalla mano di altri.
- 2: Al rendimento pieno questa libertà dà alla tua domanda un piede che si stacca da terra senza aver chiesto garanzie: il meglio che sa offrire è un avvio pulito, senza debiti con quello che è stato.
- 3: Fra la prudenza in cui la tua questione sta adesso e lo slancio di chi parte senza sapere dove dorme la sera corre un margine larghissimo: quel margine misura il massimo di questa forza.

### capovolta

- 1: Se nulla si sprecasse, questa esitazione darebbe alla tua questione un movente messo a nudo: la spinta guardata in faccia prima che il piede si stacchi, col nome giusto sopra.
- 2: Il massimo qui è fatto di due materie sole: l'orlo riconosciuto per quello che è, insieme alla domanda onesta su che cosa muove il tuo passo, coraggio oppure fretta di andarsene.
- 3: Questa sospensione sul bordo, al suo meglio, dà alla tua questione il nome vero della spinta; non arriva a dare il piede posato dall'altra parte, perché riconoscere e muoversi sono due mestieri.

## Il Mago

### dritta

- 1: Il punto più alto di questa forza sulla tua questione è l'idea che diventa gesto eseguito: oltre l'atto compiuto non sale, perché il suo mestiere è la messa in opera e non il premio che ne viene.
- 2: Al suo pieno rendimento questa forza mette in opera ogni strumento che la tua questione ha a portata: niente resta chiuso in un cassetto per mancanza di una mano che lo prenda.
- 3: Fra come sta adesso la tua domanda e quanto vale la dotazione che la tocca resta aperta una distanza grande quanto l'intero passaggio dal progetto all'atto eseguito.

### capovolta

- 1: Se nulla si sprecasse, lo scarto fra quello che la tua questione promette e quello che le mani mantengono sarebbe misurato per intero, con il talento riconosciuto intatto e la distanza detta in chiaro.
- 2: Il massimo che questa forza porta alla tua domanda è fatto di due pezzi: un dono che resta pieno e una parola più larga dell'opera che la segue. Tanto il dono quanto lo scarto si lasciano pesare.
- 3: Nemmeno al suo meglio questa forza mette in opera il dono: arriva a nominare per intero la distanza fra la parola data e la mano che la mantiene nella tua questione; oltre quella misura non va.

## La Papessa

### dritta

- 1: Il punto più alto che questa forza può dare alla tua domanda è un sapere che arriva prima delle parole ed è esatto senza prove: oltre non sale, perché dimostrandosi smetterebbe di esserlo.
- 2: Al suo pieno rendimento la tua questione avrebbe una custode interna che riconosce il vero prima di saperlo spiegare: nessun parere raccolto in fretta, una quiete che tiene fermo quello che ha visto.
- 3: Questa forza porta alla tua domanda una comprensione che matura nel silenzio e vale una prova; non ti dà la parola pronta da mettere sul tavolo: quel sapere resta intero finché non si traduce.

### capovolta

- 1: Il meglio che questa forza sa dare alla tua questione è il rumore che si riconosce come rumore: smette di spacciarsi per ragionamento e lascia emergere il sapere coperto.
- 2: Di che cosa è fatto questo massimo, nel tuo caso: una sola ammissione, che la ragione messa davanti fa da copertura; nient'altro, nessuna rivelazione, nessun chiarimento prestato da fuori.
- 3: Quello che al suo meglio questa forza lascia intero nella tua questione è il sapere coperto: soffocarlo non lo cancella, non lo consuma; resta intatto e disponibile nel momento in cui il frastuono cala.

## L'Imperatrice

### dritta

- 1: Il punto più alto di questa forza sulla tua questione è una cosa viva che matura col suo tempo e arriva intera: oltre quella maturazione non sale, perché la fertilità non fabbrica, fa nascere.
- 2: Al suo pieno rendimento questa forza darebbe alla tua domanda un frutto nato senza forzature, maturo nei tempi suoi, con la cura spesa nel nutrire e non nel sorvegliare.
- 3: La fecondità in gioco sulla tua questione può portare a compimento quello che è stato seminato, con radici capaci di tenere; quello che non dà, nemmeno al meglio, è un frutto prima del suo tempo.

### capovolta

- 1: Il meglio che questa forza sa dare alla tua questione è una cura che torna alla sorgente: la radice nutrita prima dei rami, così che quello che fiorisce fuori abbia da dove venire.
- 2: Di questo massimo fanno parte la sorgente della tua questione riconosciuta come tale, la cura che le arriva prima che agli altri rami e il tempo lento in cui una radice si rifà.
- 3: Quello che questa forza al suo meglio tiene intero è la capacità generativa della tua questione, la fonte da cui qualcosa può ancora nascere anche quando fuori niente sta fiorendo.

## L'Imperatore

### dritta

- 1: Il punto in cui questa forza smette di salire è una forma che tiene anche quando nessuno la sorveglia: alla tua questione può dare durata, mai calore.
- 2: Al suo pieno rendimento questa fermezza dà alla tua questione un impianto che si regge da sé, con la misura applicata prima di tutto a chi la impone: un ordine senza guardiani.
- 3: Fra come la tua questione sta adesso e quanto potrebbe valere ferma su una regola scritta, la distanza ancora aperta è quella che separa un patto rinegoziato ogni volta da uno stabilito una volta sola.

### capovolta

- 1: Se nulla la sprecasse, questa stretta diventerebbe misura: la parte della norma che porta carico starebbe in piedi, il resto cadrebbe. Al tuo impianto darebbe l'essenziale ridotto all'osso.
- 2: Il meglio possibile qui è fatto di tre cose contate: quali muri della tua costruzione reggono il peso, quali sono decorazione, quale vincolo serviva soltanto a chi lo imponeva.
- 3: Una norma allentata può restituire respiro al tuo progetto e nominare gli appoggi che mancavano sotto; fuori dal suo massimo resta la fiducia di chi quella stretta l'ha subita fin qui.

## Il Papa

### dritta

- 1: Il tetto di questa carta è un insegnamento che la tua domanda riceve per intero da chi l'ha attraversata prima: oltre la dottrina trasmessa questa spinta non sale: di suo non fabbrica nulla di nuovo.
- 2: Al suo pieno rendimento questa linea antica dà alla tua questione una guida in carne e ossa: un sapere provato da altri, consegnato come si consegna un mestiere, con la mano sopra la tua.
- 3: Fra l'opinione che la tua questione si è fatta da sé e una dottrina che dura da secoli corre tutta la distanza che questa carta può coprire: il margine qui è l'autorità di chi insegna.

### capovolta

- 1: Se nulla la trattenesse, questa spinta restituirebbe al mittente un credo ricevuto in prestito e lascerebbe in piedi solo le regole di cui la tua questione sa rendere conto da sé.
- 2: Questo massimo è fatto di un congedo cortese: il maestro ringraziato, la formula imparata a memoria lasciata andare, la tua questione che cerca il proprio senso fuori dal sentiero tracciato.
- 3: Un congedo questa spinta lo sa dare per intero, una regola nuova no: la tua domanda ne esce libera dalla formula vecchia, senza averne ancora una propria da mettere al suo posto.

## Gli Amanti

### dritta

- 1: Al suo meglio questa forza tiene in piedi l'accordo fra quello in cui credi e quello che ti muove: il massimo in gioco è una decisione che non lascia fuori nessuna delle due parti.
- 2: Il genere di bene che questa forza dà alla tua questione è interezza, non intesa: il tetto qui è una scelta in cui la testa e il sentimento firmano la stessa riga.
- 3: Più in alto di così non arriva: il metro della decisione diventa quello che hai di più tuo, i valori che reggono la tua vita invece del gusto di un pomeriggio.

### capovolta

- 1: Portata al rendimento pieno, questa frattura dà alla tua questione i due termini riconosciuti come tuoi entrambi: nessuno dei due è arrivato da fuori, nessuno dei due parla per conto d'altri.
- 2: Fra il silenzio in cui una delle tue due ragioni sta e la parola che le toccherebbe corre tutto il margine di questa forza: il massimo è la metà muta che torna a dire la sua.
- 3: Al suo meglio avrebbe la forma di due ragioni sedute allo stesso tavolo, con pari diritto di parola sulla tua questione: nessuna delle due messa a tacere per far prima.

## Il Carro

### dritta

- 1: Al suo meglio questa forza lascia intere entrambe le spinte che tirano la tua questione: nessuna delle due viene sacrificata all'altra e tutte e due restano aggiogate allo stesso avanzamento.
- 2: Il genere di bene che sta in cima è padronanza e non fortuna: il più che la tua domanda riceve è una mano ferma sulle redini, non un terreno che si fa più comodo.
- 3: Più in alto del governo non si sale: questa forza arriva a tenere insieme contrari che tirano sulla tua questione e si ferma dove comincia il terreno, che nessuna presa governa.

### capovolta

- 1: Al suo pieno rendimento questa forza mostra lo sbandamento per quello che è: una presa lasciata andare su spinte che restano attaccate alla tua questione, dentro un mezzo che non ha nulla di rotto.
- 2: Fra come corre adesso la tua questione e quanto porterebbe la stessa energia tenuta in mano resta aperto un margine: la presa, che è l'unica cosa in gioco.
- 3: Se nulla andasse sprecato, le forze che fanno sbandare il tuo caso tirerebbero tutte dallo stesso lato e lo sbando resterebbe un segno da leggere invece di un danno da contare.

## La Giustizia

### dritta

- 1: Fra come la tua questione sta e quanto potrebbe valere c'è la distanza di un conto fatto fino in fondo: ogni effetto riportato alla sua causa, niente arrotondato per comodità, nessuna parte lasciata fuori dal peso.
- 2: La misura piena di questa forza mette sulla bilancia della tua domanda tutto quello che le appartiene; quello che non arriva a darti è l'assoluzione, perché una bilancia pesa e non perdona.
- 3: Il genere di bene che questa forza porta alla tua questione è esattezza e non clemenza: un peso che torna giusto, non un peso più leggero; un conto corretto, non un conto cancellato.

### capovolta

- 1: Al suo pieno rendimento questa forza riporterebbe sotto il tuo nome la sola parte del conto che è davvero tua: non tutte le colpe del mondo, soltanto la riga che ti appartiene.
- 2: Quello che questa forza, al suo meglio, salva nella tua questione è la possibilità di un pareggio: finché il conto resta attribuito al caso nessuno lo può leggere; riconosciuto, almeno torna sul tavolo come cifra.
- 3: Il punto oltre il quale questa forza non sale, nella tua faccenda, è il nome esatto messo sopra una conseguenza: la riconduce a chi la produce e non la alleggerisce di un grammo.

## L'Eremita

### dritta

- 1: Fra come la tua questione sta adesso e quanto potrebbe chiarirsi resta aperto un margine: è lo spazio che un silenzio cercato sa riempire, un passo illuminato per volta.
- 2: Il genere di bene al suo massimo qui è lucidità, non conforto: una comprensione guadagnata nel tuo raccoglimento, di quelle che nessuno può consegnarti da fuori.
- 3: La lanterna di questa forza, al suo meglio, può mostrare alla tua questione un passo chiaro per volta; quello che non arriva a dare è la mappa intera in una sola occhiata.

### capovolta

- 1: Al suo pieno rendimento questa forza darebbe alla tua questione la differenza vista con chiarezza fra un raccoglimento che insegna e un ritiro che tiene lontano, con la lanterna puntata anche sul rientro.
- 2: Quello che questa forza al suo meglio lascia intero nella tua questione è il filo con gli altri: assottigliato dalla distanza, mai reciso, percorribile ancora nei due sensi.
- 3: Il punto oltre il quale questa forza non sale è il rientro: può illuminare la via di casa della tua questione, mai attraversarla al tuo posto né accorciare il buio che resta in mezzo.

## La Ruota della Fortuna

### dritta

- 1: Al suo meglio questo girare lascia intero il fatto che niente nella tua questione sia fissato per sempre: quello che salva è la mobilità, cioè la possibilità che un assetto duro si sciolga da sé.
- 2: Di che genere è il bene più alto qui: movimento e non comodità. Il massimo della tua domanda è una rotazione che rimette in gioco quello che pareva assegnato, mai una sistemazione migliore in cui fermarsi.
- 3: Il tetto di questa forza è il cambiamento stesso: può rovesciare un assetto della tua questione e non può scegliere dove arrestarlo. L'altezza qui è il moto, il suo limite è il non avere mano.

### capovolta

- 1: Al suo pieno rendimento un giro che si ripete sa dare una cosa sola e intera: la forma esatta del cerchio che la tua questione ripercorre, misurata sul punto da cui riparte.
- 2: Fra il punto dove la tua questione gira adesso e quanto varrebbe lo stesso moto con una presa sopra, la distanza ancora aperta misura quello che manca: un appiglio, non più spinta.
- 3: Se nulla lo sprecasse, questo meccanismo scomposto mostrerebbe quale dei suoi denti salta: il tuo problema apparirebbe nella sua misura, un giro guasto in un punto preciso invece di una sorte contraria.

## La Forza

### dritta

- 1: Al suo meglio questa mitezza salva l'istinto invece di spegnerlo: la belva che riguarda la tua questione resta viva, calda, intera, con una mano posata sul collo che non stringe mai.
- 2: Di genere, il massimo qui è docilità e non vittoria: alla tua domanda spetta un ardore che obbedisce di buon grado; la differenza si sente tutta nella mano che lo tiene.
- 3: Il punto oltre il quale questa dolcezza non sale è il consenso: alla tua questione può toccare un istinto che segue perché acconsente, non uno piegato con la stretta.

### capovolta

- 1: Il meglio che questa carta sa dare quando cede è una mano che si apre: la durezza puntata contro la tua stessa tenuta può allentarsi; il governo torna dove la stretta lo perdeva.
- 2: Lo spazio fra una presa serrata sul proprio ardore e un palmo aperto è tutto quello che questa carta può recuperare alla tua questione; la misura è in mitezza invece che in disciplina.
- 3: Se niente la sprecasse, questa pazienza in affanno mostrerebbe la tua tenuta intatta sotto la fatica di dimostrarla; la fermezza tornerebbe mite come era prima dello sforzo.

## L'Appeso

### dritta

- 1: Il massimo qui è fatto di una sola materia: lo sguardo girato sottosopra, che della tua questione mostra la faccia tenuta nascosta finché la guardavi dall'angolo comodo.
- 2: Questa immobilità, al suo meglio, dà alla tua domanda una comprensione che l'agitazione non produce; non arriva a dare la mossa successiva, perché capire da rovescio è un mestiere a sé.
- 3: Tenuta a pieno, questa pausa salva intatta la cosa che la fretta consuma per prima: il tempo in cui una comprensione matura da sé, senza che tu la tiri per le foglie.

### capovolta

- 1: Il bene che questa forza dà alla tua questione è di specie amara: chiarezza sul conto invece di conforto. Il tetto qui è vedere che quella rinuncia non nutre nessuno, nemmeno chi la fa.
- 2: Più su di questo non sale: l'altezza in gioco è il riconoscimento esatto di un'attesa che ha smesso di insegnare qualcosa alla tua questione.
- 3: Al rendimento pieno questa sospensione vuota dà un conto onesto: quanto ti costa restare immobile, a fronte di quanto di quel costo arriva davvero a qualcuno.

## La Morte

### dritta

- 1: Il massimo per la tua questione è fatto di due cose: un taglio netto dove il tempo di una forma è esaurito e uno spazio vuoto e pulito dietro quel taglio.
- 2: Al suo meglio questa forza libera il posto nel tuo caso e non lo arreda: arriva a chiudere senza residui quello che è esaurito, mentre quello che nasce dopo non è materia sua.
- 3: Quello che resta intero, quando questa forza dà tutto, è ciò che nella tua domanda era vivo davvero: il taglio prende soltanto ciò che non ha più tempo.

### capovolta

- 1: Il genere di bene che questa forza porta al massimo è lucidità e non sollievo: la tua presa si lascia vedere come presa, invece di passare per fedeltà a quello che non ha più tempo.
- 2: Più su di una presa riconosciuta questa forza non arriva: nel tuo caso il punto più alto è la mano che si sa chiusa, mentre l'apertura della mano resta un'altra materia.
- 3: Al suo pieno rendimento il trattenere ti rende un servizio solo: dice con esattezza quanto costa; quel conto è tutto ciò che questa forza sa consegnare alla tua questione.

## La Temperanza

### dritta

- 1: Di che cosa è fatto il massimo che questa forza porta alla tua questione: una proporzione sola, trovata a mano, fra due materie che non sembrano stare nello stesso recipiente. Nient'altro, nessuna aggiunta.
- 2: Il bene in gioco per la tua domanda è di specie lenta: non quantità di equilibrio ma qualità della mescola, la calma di due parti opposte che stanno insieme senza sopraffarsi.
- 3: Portata al suo meglio, questa forza dà alla tua questione una sola dose giusta: non la somma delle due spinte, nemmeno la vittoria di una, piuttosto un terzo stato che regge perché le contiene entrambe.

### capovolta

- 1: Questa forza, nella tua questione, sa indicare con precisione quale dose sta fuori misura e di quanto; quello che non arriva a darti è la mescola rifatta, perché separare le due parti non significa comporle.
- 2: Il punto più alto di questa forza, per la tua domanda, è l'eccesso guardato come eccesso e misurato: oltre quella misura non va, perché nominare uno squilibrio non è lo stesso che ridosarlo.
- 3: Fra il ritmo rotto che la tua questione tiene adesso e la proporzione che potrebbe valerle c'è lo spazio di due parti che tornano a parlarsi come due, ciascuna con il proprio nome, senza fondersi per fretta.

## Il Diavolo

### dritta

- 1: Di questo massimo fanno parte il nome esatto dell'attaccamento che lavora nella tua questione, il tornaconto che lo tiene in piedi e la mano che ha stretto il patto senza accorgersene.
- 2: Il bene possibile qui è di specie aspra, lucidità e non sollievo: la verità sul legame che la tua questione alimenta, guardato nella sua convenienza prima che nella sua vergogna.
- 3: Quanto questa forza sa dare alla tua questione, al pieno, è una presa riconosciuta per quello che è: un patto con un vantaggio dentro, che smette di comandare nel buio quando viene chiamato per nome.

### capovolta

- 1: Il più alto che questa forza dà alla tua questione è un nodo slacciato dalle stesse mani che lo avevano stretto: oltre lo scioglimento non va, perché non cancella la stagione in cui il patto conveniva.
- 2: Fra la presa di adesso sulla tua questione e la presa che resterebbe dopo lo scioglimento c'è tutta la distanza che questa forza può coprire, misurabile nel peso che si perde.
- 3: Una catena vera si allenta quando chi l'ha chiusa ne riconosce il meccanismo: questo è il massimo in gioco sulla tua questione; quello che non dà, nemmeno al meglio, è l'innocenza di chi non l'ha mai indossata.

## La Torre

### dritta

- 1: Il massimo qui è ciò che resta quando una facciata viene giù: i muri portanti, il nome vero delle cose dette male, il conto di quanto la tua costruzione poggiava sul falso.
- 2: Un cedimento improvviso può togliere alla tua questione ogni appoggio finto e lasciare materia solida su cui ricominciare; fuori dalla sua portata, anche al meglio, sta un passaggio indolore.
- 3: Al suo meglio questa scossa lascia intatto il vero: quello che viene giù è la parte della tua costruzione che reggeva per convenzione; il solido non lo tocca il colpo.

### capovolta

- 1: Di che specie è il bene possibile qui: lucidità sul rimando e non quiete. Il più alto che questo rinvio sa dare alla tua questione è il nome dell'impalcatura che tiene su una cosa sfiatata.
- 2: Il tetto di questa forza è il tempo guadagnato: può rimandare lo smontaggio della tua costruzione e non può rendere vero quello che il rimando mantiene in piedi.
- 3: A pieno rendimento una scossa trattenuta sa dare una resa per gradi invece di un colpo unico: il peso del tuo impianto può venire levato un pezzo alla volta, con le travi numerate.

## La Stella

### dritta

- 1: Questo massimo è fatto di acqua versata senza fretta, di un cielo illuminato tutta la notte e di una fiducia che alla tua questione torna in silenzio, senza chiedere entusiasmo.
- 2: Una quiete luminosa questa carta la sa dare per intero; il calore sulla pelle no, perché la sua luce rassicura da lontano e la tua domanda ne ricava respiro invece di ardore.
- 3: Al suo meglio questa luce lascia intera la tua ispirazione dopo il maltempo: il danno resta visibile; insieme a lui resta aperta la sorgente a cui la tua questione attinge.

### capovolta

- 1: Fiducia al minimo e mai spenta: è questo il genere di bene che la speranza ormai stanca porta alla tua questione, una tenacia senza allegria che basta a reggere una notte lunga.
- 2: Il tetto di questa luce in affanno è una nube che si dirada, non un cielo pulito: alla tua domanda può tornare la luce di prima, velata quel tanto che la stanchezza impone.
- 3: Quello che questa carta sa dare quando è stanca è la prova che la sorgente regge anche senza che tu la senta: l'ispirazione della tua questione cala di intensità e non si interrompe.

## La Luna

### dritta

- 1: Fra quello che la tua questione sembra alla prima occhiata e quello che è davvero resta un margine di buio: il massimo di questa forza sta nel camminare dentro quel margine senza inciampare.
- 2: Se nulla andasse sprecato, questo buio darebbe alla tua domanda un passo che tiene anche senza vedere: il piede che sente il terreno dove l'occhio non arriva più.
- 3: Il massimo è fatto d'intuito e di prudenza insieme, due cose che lavorano di notte: le certezze pretese in anticipo non reggono il peso della tua questione.

### capovolta

- 1: Al suo meglio, questo schiarirsi restituisce alla tua questione la misura esatta di ciò che al buio pareva enorme; non la sistema, perché la proporzione è un dono a parte.
- 2: Portato al rendimento pieno, questo dissolversi della nebbia lascia intero quello che la paura stava per far cedere nella tua questione: in alto resta quanto era soltanto ombra gonfiata.
- 3: Il genere di bene qui è proporzione, non quiete: il tetto che questa forza tocca sulla tua domanda è la misura giusta delle cose, non il silenzio dei pensieri.

## Il Sole

### dritta

- 1: Fra la luce che c'è sulla tua questione e quella che ci sarebbe senza un angolo in ombra resta un margine stretto: è la parte di campo che nessuno ha voluto illuminare.
- 2: Se nulla si sprecasse, la tua domanda starebbe sotto una luce piena, senza un lato tenuto al riparo: tutto quello che sta nel campo si lascerebbe vedere e scaldare nello stesso momento.
- 3: Il massimo in gioco è fatto di due cose e non di tre: una chiarezza che non lascia penombra su quello che hai davanti e un calore che arriva sulla pelle. Riparo non ne offre.

### capovolta

- 1: Al suo pieno rendimento questa forza dice che la pienezza sulla tua questione è intatta e che la nube sopra è sottile: a togliere quella nube non arriva; il limite sta lì.
- 2: Quello che questa forza salva, al suo meglio, è il bene stesso della tua questione: la luce non si consuma dietro il velo e resta intera, mentre il sentirla sulla pelle è un'altra partita.
- 3: Il genere di massimo che tocca al tuo caso è una certezza e non un conforto: il calore c'è per intero; quanto ne passa attraverso il velo questa forza non lo stabilisce.

## Il Giudizio

### dritta

- 1: Quello che questa forza, al suo meglio, lascia intero nella tua questione è tutto: il richiamo convoca ogni parte della vita nello stesso momento e non scarta niente, perché un bilancio parziale non sarebbe un bilancio.
- 2: Il meglio che questo richiamo sa dare alla tua domanda è un risveglio senza condanna: solleva ciò che dorme e non emette verdetti, perché la sua forza è chiamare in piedi, non accusare.
- 3: Se nulla la sprecasse, la tua questione avrebbe la forma di un conto generale chiuso e di una vita ripresa su misura diversa: nessun pezzo lasciato fuori, nessuna parte vecchia trascinata dentro per abitudine.

### capovolta

- 1: Il bene possibile per la tua questione è mite: il giusto peso al posto della severità; la durezza con cui ti tratti si rivela un modo di non rispondere al richiamo.
- 2: Fra il rinvio in cui resta la tua domanda e il suo meglio c'è la distanza fra un conto immaginato in grande e uno aperto sul tavolo: vale la misura vera.
- 3: Composto di una cosa sola, questo massimo porta alla tua faccenda un'ammissione detta senza processo e il bilancio ridotto alla sua grandezza reale: nessun risarcimento, nessuna assoluzione in anticipo.

## Il Mondo

### dritta

- 1: Quello che questa forza tiene intero, al suo meglio, è tutto l'attraversato della tua questione: nessun pezzo buttato, ognuno al posto che gli tocca dentro un giro che si chiude.
- 2: Il meglio che questa forza sa dare alla tua domanda è un compimento che comprende anche le parti scomode del percorso, riconosciute come tue invece che tollerate.
- 3: A pieno rendimento la tua questione prenderebbe la forma di un cerchio chiuso, con la fine che tocca l'inizio e niente lasciato fuori dal conto, nemmeno quello che è costato.

### capovolta

- 1: Fra il disegno quasi completo della tua questione e il disegno intero resta il posto di un pezzo solo: quel margine è esattamente quanto questa forza può valere.
- 2: Di questo massimo fanno parte il pezzo mancante chiamato per nome, la sua misura esatta e la tolleranza per un disegno della tua questione che resta scoperto in un punto.
- 3: Il bene in gioco qui è di specie precisa, completezza e non sollievo: il valore che questa forza porta alla tua questione si misura sull'intero, mai sulla quiete di fermarsi vicino.

## Asso di Bastoni

### dritta

- 1: Fra il punto da cui la tua questione parte e quanto potrebbe valere con la spinta al massimo, la distanza ancora aperta è quella di un primo gesto: il calore non manca, manca l'oggetto su cui posarlo.
- 2: Se nulla la disperdesse, questa accensione darebbe alla tua domanda un avvio pieno: tutto il fuoco in un punto solo, senza una seconda fiamma accesa accanto a reclamare le medesime mani.
- 3: Il massimo possibile qui è fatto di calore puro e di nient'altro: nessun piano, nessuna misura, soltanto la forza che mette in moto il tuo lavoro da fermo.

### capovolta

- 1: Una partenza rimandata può conservare intatto il desiderio che la muove e restituirlo pieno al tuo progetto; quello a cui non arriva, nemmeno al suo meglio, è il tempo trascorso sotto il coperchio.
- 2: Al suo meglio questo soffocamento salva il combustibile: quello che si ferma è l'avvio e non la voglia; la tua questione conserva per intero la materia che accende.
- 3: Di che genere di bene si tratta qui: integrità e non slancio. Il tetto di questa forza trattenuta per la tua domanda è un fuoco conservato interamente, mai un fuoco grande.

## Due di Bastoni

### dritta

- 1: Fra il pezzo di mondo che la tua questione conosce a memoria e quello che si vede soltanto dalla cima corre la distanza che questa carta può aprire: il margine è l'ampiezza del piano.
- 2: Se nulla la riducesse, questa carta disegnerebbe per la tua domanda un progetto a misura del globo che hai in mano: una rotta scelta dall'alto, col tempo di studiarla prima di muovere.
- 3: Questo massimo è fatto di mappe aperte, di un'ambizione dichiarata senza pudore e di un confine guardato da dentro casa: la tua questione ha tutto quello che serve per scegliere dove puntare.

### capovolta

- 1: Un disegno largo questa carta quando esita lo tiene in piedi; il coraggio di sceglierlo non lo fornisce: alla tua questione spetta il piano intero, col timore della sua ampiezza accanto.
- 2: Al suo meglio questa carta salva l'ambizione che il dubbio ha messo in dispensa: la misura grande della tua domanda resta intera, nelle proporzioni in cui è stata pensata.
- 3: Chiarezza più che audacia: il bene che questa ambizione in dubbio porta alla tua questione è un piano leggibile fino in fondo, con ogni ramo nominato e ogni costo scritto in chiaro.

## Tre di Bastoni

### dritta

- 1: Più in alto questa forza non arriva: l'altezza in gioco è l'ampiezza che la tua questione prende lontano da te, nei posti dove il lavoro continua senza il tuo occhio sopra.
- 2: Al rendimento pieno questa espansione dà alla tua domanda una portata più larga del punto da cui è partita: il meglio che sa offrire è distanza coperta da quello che hai messo in mare.
- 3: Fra il confine da cui la tua questione si è mossa e il punto più lontano che quello che hai spedito arriva a toccare resta un margine aperto: quel margine è il massimo in gioco.

### capovolta

- 1: Se niente si sprecasse, questo rientro darebbe alla tua questione un inventario onesto: quello che è tornato pesato per quello che è, fuori dal confronto con la figura che avevi in testa.
- 2: Il massimo è fatto di due pezzi: il carico che rientra davvero, insieme alla rilettura delle attese che la tua domanda gli aveva messo addosso prima di vederlo.
- 3: Questa differenza fra atteso e arrivato, al suo meglio, dà alla tua domanda il conto vero di quello che è rientrato; non arriva a dare la forma immaginata, perché nel carico non c'era.

## Quattro di Bastoni

### dritta

- 1: Il punto più alto per la tua questione è una base provata e riconosciuta da chi ti sta attorno: oltre la tenuta festeggiata insieme questa forza non sale.
- 2: Al suo pieno rendimento questa forza mette alla prova le fondamenta del tuo caso e le fa vedere a tutti nello stesso giorno: una stabilità che nessuno discute più.
- 3: Fra l'opera che sta in piedi nella tua questione e il giorno in cui chi sta attorno la saluta resta aperta una distanza: quella distanza è la misura intera di questa forza.

### capovolta

- 1: Se nulla si sprecasse, la casa pronta della tua questione avrebbe anche il suo ingresso: la tenuta starebbe in piedi e il riconoscimento le arriverebbe addosso nello stesso giorno.
- 2: Il massimo in gioco è fatto di una cosa intera e di una mancante: fondamenta che tengono senza incrinature nel tuo caso e un rito d'ingresso che nessuno celebra.
- 3: Al suo meglio questa forza tiene in piedi quello che regge la tua domanda e non procura la festa: la solidità resta sua, il saluto di chi guarda non è cosa che sappia dare.

## Cinque di Bastoni

### dritta

- 1: Il punto più alto di questa forza, nella tua questione, è la mischia che misura: tutti spingono allo scoperto e da quello spintonare si capisce quanto pesa ciascuno.
- 2: A pieno rendimento la tua domanda avrebbe un attrito pulito: nessun nemico scelto, nessun premio da dividere, soltanto energie di pari grado che si urtano e si misurano a viso aperto.
- 3: Questa forza porta alla tua questione il vantaggio del confronto acceso, dove le idee si provano l'una contro l'altra; non arriva a darti chi prevale, perché una mischia misura e non assegna.

### capovolta

- 1: Il meglio che questa forza sa dare alla tua questione è un conteggio: quanto costa ogni attrito tenuto in vita per abitudine. La stanchezza, misurata, smette di sembrare inevitabile.
- 2: Fatto di sottrazioni, il massimo in gioco nella tua domanda contiene soltanto questo: gli attriti che covano portati alla luce con il loro prezzo; nessuna riconciliazione entra nel conto.
- 3: Al suo meglio questa forza salva, nella tua questione, l'energia non ancora bruciata: una contesa senza posta in gioco, riconosciuta, si spegne da sé; quello che non viene speso resta intero.

## Sei di Bastoni

### dritta

- 1: Il tetto di questa forza sulla tua questione è un merito riconosciuto in pubblico, con il tuo nome accanto: più in alto non sale, perché l'onore conferma il lavoro e non lo raddoppia.
- 2: A pieno rendimento questa forza darebbe alla tua domanda un riconoscimento proporzionato a quello che è stato fatto, consegnato davanti a chi conta per te, senza sconti né gonfiature.
- 3: Quanto questa forza può offrire alla tua questione è l'applauso che arriva al merito giusto; quello che non arriva a dare, nemmeno al meglio, è il valore interiore che nessun applauso assegna.

### capovolta

- 1: Il meglio che questa forza sa dare alla tua questione è un valore che si regge senza testimoni: la stima che non dipende da chi la pronuncia, misurata sul fatto invece che sull'eco.
- 2: Di questo massimo fanno parte il merito contato per quello che è, la pazienza dentro un'attesa che si allunga e un giudizio su di te che non passa per le mani degli altri.
- 3: Quello che questa forza, al suo meglio, lascia in piedi nella tua questione è il merito stesso: intatto anche quando nessuno lo nomina, disponibile per il momento in cui qualcuno lo nomina.

## Sette di Bastoni

### dritta

- 1: Il tetto di questa forza è il mantenimento: può conservare al tuo lavoro il vantaggio che ha in mano contro più fronti insieme, non allargarlo di un passo.
- 2: A pieno rendimento una tenuta come questa sa dare la differenza fra molti che spingono e uno che non arretra: alla tua questione lascia il terreno intero, con le forze ancora fresche.
- 3: Fra quanto il tuo punto regge adesso e quanto reggerebbe difeso da una sola mano senza cedere un metro, la distanza ancora aperta misura il numero dei fronti, non il coraggio.

### capovolta

- 1: Se nulla la sprecasse, questa guardia stanca diventerebbe un conto: i fronti che attaccano davvero da una parte, quelli rimasti aperti per abitudine dall'altra, il tuo sforzo distribuito su misura.
- 2: Il meglio in gioco è fatto di una lista: quali difese del tuo progetto hanno ancora qualcuno davanti, quali stanno su da sole, quante mani servirebbero per tenerle tutte insieme.
- 3: Una difesa portata al limite può dire quanto pesa ogni fronte della tua questione e quale di essi era vuoto; quello a cui non arriva, al suo meglio, è un avversario in meno.

## Otto di Bastoni

### dritta

- 1: Il tetto di questa carta è la simultaneità: molte cose che riguardano la tua domanda possono muoversi nello stesso istante; nessuna di esse cambia natura per il fatto di correre.
- 2: A pieno rendimento questa spinta dà alla tua questione risposte che non fanno anticamera: le frecce partono insieme, il messaggio è in aria prima che tu abbia finito di formularlo.
- 3: Fra una pratica che dorme e un fascio di notizie in volo corre tutto quello che questa carta può recuperare alla tua questione: il margine si misura in attese risparmiate.

### capovolta

- 1: Se niente la sprecasse, questa forza rimetterebbe in fila le molte cose che la tua questione tiene in volo: un ordine di partenza, invece di un grappolo che si ostacola.
- 2: Questo massimo è fatto di tempi ricuciti: ogni cosa che riguarda la tua domanda ritrova il proprio turno; la fretta che faceva inciampare diventa ritmo tenuto da una mano sola.
- 3: Un ritmo si può rimettere in sesto, il tempo perduto no: alla tua questione questa forza offre l'ordine di quello che resta in volo, non ciò che è già caduto.

## Nove di Bastoni

### dritta

- 1: Al suo meglio questa tenacia tiene in piedi quello che le prove precedenti hanno lasciato intero: la tua questione regge sulle forze residue di chi porta i segni addosso.
- 2: Il bene in gioco è resistenza, non freschezza: il più alto che questa forza dà alla tua domanda è la tenuta di chi ha speso quasi tutto e trova ancora un fondo.
- 3: Più su di questa riserva non si va: l'altezza è l'ultimo tratto tenuto con le ferite addosso, dove la tua questione sta in piedi per pura testardaggine.

### capovolta

- 1: Al rendimento pieno questa diffidenza dà alla tua questione la distinzione che le serve: chi bussa riconosciuto per quello che è, separato da chi ha fatto male prima.
- 2: Fra la guardia alzata contro tutti e la guardia alzata contro i soli che l'hanno meritata corre il margine di questa forza: il massimo è quella cernita sulla tua domanda.
- 3: Se nulla fosse sprecato, questa difesa avrebbe la forma di una porta che si apre a chi batte piano: sulla tua questione il massimo sarebbe un confine scelto uno per uno.

## Dieci di Bastoni

### dritta

- 1: Quello che questa forza salva, dando tutto, è la consegna: il fascio che pesa sulla tua questione arriva intero dove deve; le braccia che lo tengono non lo lasciano cadere per strada.
- 2: Il genere di bene al massimo è tenuta e non respiro: il tuo carico resta portato fino all'ultimo passo, mentre la vista corta che viene dalle braccia piene non si allarga.
- 3: Più in alto del peso portato fino in fondo questa forza non arriva: nella tua questione il tetto è la fatica che tiene, non la scelta di quali fasci posare.

### capovolta

- 1: Al suo pieno rendimento questa forza separa con esattezza il peso che nella tua questione è tuo da portare da quello che resta addosso per abitudine o per un dovere preso in prestito.
- 2: Fra il carico che grava sul tuo caso e quello che ne resterebbe tolta ogni parte non tua corre un margine largo: questa forza sa misurarlo tutto.
- 3: Se nulla andasse sprecato, ogni filo del fascio che pesa sulla tua domanda avrebbe un nome e un proprietario; i fili senza nome resterebbero a terra.

## Fante di Bastoni

### dritta

- 1: Fra l'idea appena affacciata nella tua questione e quanto potrebbe valere resta aperto tutto lo spazio della prova: un annuncio giovane, portato in giro e sperimentato, senza un impegno preso che lo chiuda.
- 2: La corsa di questa forza porta alla tua domanda la notizia fresca e la voglia di provarla; non ti dà il mestiere, perché un annuncio indica la strada senza percorrerla.
- 3: Il genere di bene che questa forza porta alla tua questione è freschezza e non competenza: conta l'età dell'idea, non la sua riuscita; la prima curiosità, non l'apprendistato che verrebbe dopo.

### capovolta

- 1: Senza sprechi, la tua questione avrebbe la serie delle accensioni messa in fila e leggibile: non un inizio solo, molti, ciascuno con il punto esatto in cui l'interesse passa altrove.
- 2: Quello che questa forza, al suo meglio, lascia intero nella tua domanda è il ripetersi: tante partenze diverse mostrano una figura sola; quella figura è l'unica cosa che le molte scintille consegnano.
- 3: Il tetto di questa forza, per la tua questione, è riconoscere il proprio ritmo: quante volte si accende, quanto dura ogni fiamma. Nominare la cadenza è il suo limite, non il rimedio.

## Cavaliere di Bastoni

### dritta

- 1: Fra la tua questione ferma e la tua questione messa in sella c'è tutto il margine che questo ardore può coprire, misurato in audacia spesa di persona.
- 2: Il genere di bene al massimo per la tua questione è slancio, non prudenza: un'avventura affrontata col corpo e col fegato, che vale per come viene corsa più che per il conto che lascia.
- 3: Un'audacia di questo genere può dare alla tua questione la partenza presa in prima persona, col rischio accettato; quello che non dà, nemmeno al meglio, è la misura di chi resta a calcolare.

### capovolta

- 1: A pieno rendimento questa foga darebbe alla tua questione un solo fronte su cui bruciare per intero, con la stessa quantità di fuoco che oggi si divide fra troppe partenze.
- 2: Quello che questa forza al suo meglio tiene in piedi nella tua questione è la quantità di ardore: niente spento, niente raffreddato, tutto intero e sparso su più fronti.
- 3: Il punto oltre il quale questa corsa non sale è la potenza stessa: alla tua questione può darne in abbondanza, mai il capo a cui quella potenza torna.

## Regina di Bastoni

### dritta

- 1: Al suo meglio questo calore lascia intero lo spazio degli altri: la tua presenza attira senza chiedere obbedienza; quello che si salva è l'autonomia di chi si avvicina.
- 2: Calore e non comando è la specie di questo massimo: alla tua questione la fiamma sa dare una presenza che scalda chi le sta accanto, mai una strada imposta.
- 3: Il punto in cui questa forza smette di crescere è l'attrazione: può rendere la tua presenza magnetica fin dentro una stanza chiusa; autorità su nessuno.

### capovolta

- 1: A pieno rendimento un dubbio su di sé sa dare una misura presa dentro: alla tua questione restituisce il metro del proprio calore, sottratto al confronto con la luce di un'altra persona.
- 2: Fra quanto la tua fiamma vale agli occhi di chi la porta e quanto vale di fatto, la distanza ancora aperta sta tutta nel paragone: il calore è intero, il riconoscimento no.
- 3: Se niente lo consumasse, questo offuscamento diventerebbe riconoscimento: la tua luce apparirebbe per quanto è, senza la gelosia che le mette davanti il vetro di qualcun altro.

## Re di Bastoni

### dritta

- 1: Al suo meglio questo comando lascia in piedi l'ardore di chi lo segue: la tua questione può avere una guida che apre strade con l'esempio e non consuma nessuno dei suoi.
- 2: Il bene qui è di specie regale: alla tua domanda spetta un'autorità matura che accende il lavoro degli altri; la visione di uno diventa impresa di molti.
- 3: Oltre l'esempio questa spinta non sale: alla tua questione può toccare una fiamma che indica, con mani che la seguono per convinzione invece che per obbligo.

### capovolta

- 1: Quello che questa carta sa dare quando frena è l'ascolto che rientra in un comando: il passo di chi segue la tua questione torna a contare quanto l'impazienza di chi la guida.
- 2: Fra un ordine lanciato di corsa e lo stesso ordine dato dopo aver sentito la squadra c'è lo spazio che questa forza può recuperare alla tua domanda: si misura in persone che restano.
- 3: Se nulla lo sprecasse, questo fuoco ora chino scalderebbe senza bruciare: la tua questione avrebbe un capo che accende gli altri alla misura del loro respiro, con l'autorità intatta.

## Asso di Coppe

### dritta

- 1: Il massimo è fatto d'acqua che sale da sé: sulla tua questione questa forza mette un sentire nuovo che eccede il recipiente, con la grazia di quello che nessuno ha dovuto chiedere.
- 2: Questa sorgente, al suo meglio, dà alla tua domanda la piena del sentire alla prima ora; non arriva a dare la durata, perché una fonte riempie e il reggere nel tempo è un altro lavoro.
- 3: Al suo meglio questa apertura tiene intero il primo zampillo: la tua questione conserva la facoltà di essere toccata, quella che l'abitudine consuma per prima.

### capovolta

- 1: Il bene qui è di specie onesta: riconoscere la mano che ha girato la chiave. Sulla tua questione il tetto è sapere che l'acqua c'è, ferma perché il timore l'ha fermata.
- 2: Più in alto di questo non sale: il punto massimo è la piena riconosciuta dentro, col tappo visto per quello che è sulla tua domanda, messo lì da te e non dalla sorte.
- 3: Al rendimento pieno questo trattenersi dà alla tua questione la misura di quanto sentire sta dietro la chiusura: il meglio che sa offrire è il peso dell'acqua ferma, contato.

## Due di Coppe

### dritta

- 1: Il massimo in gioco è fatto di due metà uguali: quello che dai e quello che ti viene dato nella stessa misura, con un patto che porta due firme invece di una.
- 2: Al suo meglio questa forza sigilla il legame a due che riguarda la tua domanda e non si allarga oltre: più di quei due che si riconoscono non tiene; il limite è questo.
- 3: Quello che resta intero, quando questa forza rende tutto, è la parità: nessuno dei due nella tua questione dà più di quanto riceve; nessuno meno.

### capovolta

- 1: Il genere di massimo che tocca alla tua questione è intesa e non pace: due persone che si vogliono bene mettono in chiaro lo stesso malinteso, ciascuna dalla propria parte.
- 2: Più in alto di un fraintendimento detto da entrambe le parti questa forza non sale: l'affetto sotto la tua domanda resta intatto, mentre la ricucitura è opera di due e non di una sola.
- 3: Al suo pieno rendimento questa forza misura la distanza esatta che si apre fra due persone nel tuo caso: una distanza di parole, dentro un bene che non si è incrinato.

## Tre di Coppe

### dritta

- 1: Questo massimo, nella tua questione, è fatto di un cerchio piccolo di pari, scelti e non ricevuti in dote, riuniti per il piacere del raduno: niente altro, nessun traguardo da inaugurare.
- 2: Il bene in gioco per la tua domanda è di specie condivisa: non più allegria, piuttosto allegria in più persone; conta con chi si brinda, non quanto si brinda.
- 3: Portata al suo meglio, questa forza dà alla tua questione una moltiplicazione: la stessa cosa buona, passata fra più mani, torna più grande di quanto una sola persona possa tenerne.

### capovolta

- 1: Questa forza, nella tua questione, sa distinguere nel cerchio allargato chi nutre da chi occupa un posto; quello che non arriva a darti è il legame nuovo, perché una selezione taglia e non presenta nessuno.
- 2: L'altezza massima di questa forza, per la tua domanda, è un elenco onesto delle presenze: pochi nomi veri separati dai molti di facciata. Oltre quella lista non sale, perché contare non è rifondare una compagnia.
- 3: Fra il cerchio gonfio che la tua questione porta adesso e quanto potrebbe valerle c'è la differenza di una sottrazione: meno presenze nella stanza, la stessa quantità di affetto concentrata su chi la ricambia.

## Quattro di Coppe

### dritta

- 1: Di questo massimo fa parte una cosa precisa: la sazietà della tua questione chiamata per quello che è, con la coppa tesa di lato contata fra i dati invece che fra i fastidi.
- 2: Il bene possibile qui è di specie sobria, consapevolezza e non appetito: l'indifferenza che avvolge la tua questione misurata senza scuse, con quello che hai davanti ancora in campo.
- 3: Quanto questa forza sa dare, al pieno, è una sazietà onesta: la tua questione che ammette di avere abbastanza, con l'offerta accanto lasciata dove sta senza biasimarla.

### capovolta

- 1: Il più alto che questa forza può dare alla tua questione è l'appetito che torna: oltre il ridestarsi non va, perché restituisce la fame e non il pasto.
- 2: Fra il torpore in cui la tua questione sta e la curiosità di cui è capace c'è un margine stretto, che si copre nel momento in cui qualcosa riesce a interessarti.
- 3: Una curiosità che si riaccende da sola è il massimo in gioco sulla tua questione; quello che non dà, nemmeno al suo meglio, è il nome della cosa che la riaccende.

## Cinque di Coppe

### dritta

- 1: Il massimo qui è fatto di un conto esatto: quanto la tua questione ha perso davvero, quanto resta in piedi alle spalle di chi guarda, quale parte del vuoto lo fa sembrare intero.
- 2: Una perdita guardata fino in fondo può dare alla tua domanda la sua misura vera e il numero di quello che non è andato; fuori dal suo massimo resta qualunque restituzione.
- 3: Al suo meglio questo rimpianto lascia intere le coppe rimaste: il dolore prende la sua parte e non la parte di tutto, cosicché il residuo della tua questione resta disponibile.

### capovolta

- 1: Di che genere di bene si tratta qui: attenzione spostata e non riparazione. Il tetto di questa forza per la tua questione è uno sguardo che si gira; il versato resta versato.
- 2: Il punto oltre il quale questa ripresa non sale è il girarsi: può restituire alla tua questione quello che è rimasto in piedi, mai quello che è caduto a terra.
- 3: A pieno rendimento un'accettazione come questa sa dare l'inventario del residuo: alla tua domanda consegna le cose vive che il lutto teneva fuori campo, nella quantità in cui stanno.

## Sei di Coppe

### dritta

- 1: Questo massimo è fatto di un fiore porto da una mano piccola: un affetto di molti anni indietro che alla tua questione torna intatto, con l'innocenza che aveva allora.
- 2: Una tenerezza antica questa carta la sa restituire per intero, il tempo in cui nacque no: alla tua domanda tocca il calore di quel dono, portato dentro la vita che hai adesso.
- 3: Al suo meglio questa carta salva la bontà delle origini della tua questione: quel bene resta a disposizione come un oggetto di casa, col ricordo che lo tiene lucido.

### capovolta

- 1: Gratitudine più che nostalgia: il bene che questa memoria che sfuma porta alla tua questione è un ricordo onorato una volta per tutte, che smette di chiedere la giornata intera.
- 2: Il tetto di questa nostalgia quando cala è un congedo affettuoso: la tua domanda può mettere il tempo buono dove sta bene, senza che quel tempo perda un grammo del suo valore.
- 3: Quello che questa spinta sa dare quando cede è una dolcezza che smette di pretendere: le origini della tua questione restano buone, col presente che riprende il suo posto.

## Sette di Coppe

### dritta

- 1: Fra le molte figure che ti si affollano davanti e le poche che contengono quello che mostrano corre il margine di questa forza: il massimo sulla tua questione è quella distanza vista.
- 2: Se niente andasse sprecato, questa abbondanza di immagini darebbe alla tua domanda un banco in chiaro: ogni offerta col proprio contenuto accanto, nessuna creduta sulla parola.
- 3: Il massimo è fatto d'immaginazione larga e di mano che tasta: due cose che sulla tua questione lavorano insieme, la prima per vedere tanto, la seconda per pesare quel tanto.

### capovolta

- 1: Questa messa a fuoco, al suo meglio, dà alla tua questione una cosa sola riconosciuta fra le molte; non arriva a tenerti aperte anche le altre, perché la cernita si paga con quelle.
- 2: Al suo meglio questa scelta salva intera la libertà che nasce dal lasciare: sulla tua domanda resta in piedi quello su cui hai messo la mano, alleggerito di tutto il resto.
- 3: Il bene in gioco è nitidezza, non ricchezza: il tetto di questa forza sulla tua questione è una cosa messa a fuoco, con le altre lasciate cadere senza rimpianti.

## Otto di Coppe

### dritta

- 1: Fra il posto che la tua questione occupa adesso e quello che un congedo pulito renderebbe libero resta un margine: la distanza di una partenza fatta senza rumore e senza accuse.
- 2: Se nulla si sprecasse, quello che la tua questione lascia dietro resterebbe intero: nessuna porta sbattuta, nessuna spiegazione dovuta a chi rimane dentro, nessun rancore portato in viaggio.
- 3: Il massimo è fatto di due pezzi: un addio silenzioso che non rompe nulla dietro di te e una fame di senso che regge il passo lontano da quello che non nutre più.

### capovolta

- 1: Al suo meglio questa forza tiene l'uscio aperto su entrambi i lati della tua questione e non lo attraversa: a dire quale lato pesi di più arriva, a fare il passo no.
- 2: Quello che resta salvo, quando questa forza dà tutto, è il tempo della tua domanda: nulla si rompe mentre un piede sta dentro e uno fuori; lo stipite regge l'attesa.
- 3: Il genere di bene al massimo è onestà e non quiete: i due lati del tuo caso si lasciano pesare per quello che sono, con l'inquietudine di stare in mezzo che non si placa.

## Nove di Coppe

### dritta

- 1: Al suo meglio questa forza tiene in piedi, nella tua questione, il contentamento senza scuse: un appagamento preciso, goduto da una persona sola, che non chiede permesso a nessuno per essere pieno.
- 2: Il meglio che questa forza sa dare alla tua domanda è una soddisfazione nominata: non un benessere vago, una cosa precisa che risulta piena e si lascia godere senza pedaggio di colpa.
- 3: Se nulla lo sprecasse, il massimo della tua questione avrebbe la forma di una sedia, una tavola apparecchiata per uno e nessuna fretta: la pienezza che non ha bisogno di testimoni per contare.

### capovolta

- 1: Il bene che questa forza può portare alla tua questione è di specie amara: non una gioia più grande, la misura esatta di un piacere consumato che lascia la fame al suo posto.
- 2: Tra la facciata che la tua domanda tiene e quanto potrebbe valerle c'è un assaggio portato a termine: il vuoto che si sente dopo non è un errore di misura, è la misura.
- 3: Fatto di un solo ingrediente, questo massimo dà alla tua questione il nome giusto del piacere che non colma; nessun risarcimento lo accompagna, nessuna gioia sostitutiva messa accanto per consolare.

## Dieci di Coppe

### dritta

- 1: Il meglio che questa forza sa dare alla tua questione è un'armonia fra le persone che ti riguardano, sentita da tutte nello stesso momento e non soltanto da te.
- 2: A pieno rendimento la tua questione avrebbe la forma di una pace fra affetti: nessuno dei vicini fuori posto, la contentezza di uno non pagata dalla rinuncia di un altro.
- 3: Quello che questa forza al suo meglio tiene intero è il legame fra i tuoi: la ricchezza che la tua questione può contare si misura in persone presenti e in gratitudine reciproca.

### capovolta

- 1: Fra la casa divisa della tua questione e una casa in cui ognuno sta al suo posto resta un margine fatto di conversazioni mai avute: è lo spazio che questa forza può valere.
- 2: Di questo massimo fanno parte i nomi di chi tira dalla sua parte, il motivo di ciascuno preso per buono e un tetto comune che regge la tua questione pur senza accordo.
- 3: Il bene possibile qui è di specie modesta, chiarezza e non concordia: la tua questione può sapere con precisione chi sta dove dentro la famiglia, con le distanze contate una per una.

## Fante di Coppe

### dritta

- 1: Fra quanto il tuo sentire esprime adesso e quanto esprimerebbe con tutta la sua freschezza, la distanza ancora aperta è quella del mestiere: la materia è viva, la mano che la porta è nuova.
- 2: Se nulla la intimidisse, questa tenerezza appena nata darebbe alla tua questione la sua prima parola intera: goffa nella forma, esatta nel contenuto, offerta senza calcolo di ritorno.
- 3: Il massimo possibile è fatto di materia giovane: un'emozione che non ha ancora un nome, il coraggio di dirla male, la disponibilità a sbagliarla davanti a chi ti riguarda.

### capovolta

- 1: Una chiusura messa su per proteggersi può conservare al tuo sentire la parte più tenera, fuori dai colpi; quello a cui non arriva, nemmeno al suo meglio, è lo scambio con qualcuno.
- 2: Al suo meglio questa fragilità salva la facoltà di sentire: il muro è sottile e provvisorio; quello che resta intero sotto la tua corazza è esattamente la cosa che la corazza ripara.
- 3: Di che specie è il bene qui: custodia e non apertura. Il massimo che questa chiusura sa dare alla tua domanda è un sentire conservato intero dentro, non condiviso fuori.

## Cavaliere di Coppe

### dritta

- 1: Fra un sentimento tenuto per sé e lo stesso sentimento offerto con grazia corre tutto quello che questa carta può aggiungere alla tua questione: il margine è il gesto, non l'emozione.
- 2: Se niente la raffreddasse, questa carta porterebbe alla tua domanda un'offerta fatta bene: la proposta recapitata a mano, con la cortesia di chi si muove per primo e accetta qualunque risposta.
- 3: Questo massimo è fatto di un invito consegnato: una cortesia che non chiede garanzie, un cuore messo in mano a un altro, più il coraggio del primo passo per la tua questione.

### capovolta

- 1: Una parola affettuosa si lascia riportare ai fatti, la sua leggerezza no: alla tua questione questa forza dà la misura esatta fra quello che viene detto e quello che viene fatto.
- 2: Al suo meglio questa carta salva il sentimento dentro una promessa vaga: l'affetto che riguarda la tua domanda resta vero anche quando i gesti che lo seguono arrivano scuciti.
- 3: Onestà più che trasporto: il bene che questa promessa in bilico porta alla tua questione è la corrispondenza fra il detto e il fatto, pesata sulla mano di chi la porta.

## Regina di Coppe

### dritta

- 1: Più in alto questa empatia non arriva: l'altezza è un altro accolto per intero, letto fin dove le parole non vanno, mentre il tuo sentire resta riconoscibile come tuo.
- 2: Al rendimento pieno questa tenerezza dà alla tua questione una comprensione governata: il meglio che sa offrire è sentire molto, con la mano ferma sopra il sentire.
- 3: Fra la sensibilità che subisce e la sensibilità che accoglie corre tutto il margine di questa forza: il massimo sulla tua domanda è quel passaggio compiuto fino in fondo.

### capovolta

- 1: Se niente si sprecasse, questo travaso darebbe alla tua questione una riga di confine: quale sentire ti appartiene, quale è entrato da un altro e sta occupando il tuo posto.
- 2: Il massimo è fatto di un'etichetta sola, messa sopra ogni emozione che ti attraversa: la provenienza. Sulla tua domanda il tetto è sapere di chi è quello che senti.
- 3: Questa permeabilità, al suo meglio, dà alla tua questione il proprietario di ogni umore; non arriva a darti una pelle più spessa, perché il filtro si impara e il sentire fino resta.

## Re di Coppe

### dritta

- 1: Il punto più alto per la tua questione è una calma che tiene sotto pressione e offre riparo a chi sta vicino: oltre il riparo non va, perché i nodi di ciascuno restano suoi.
- 2: Al suo pieno rendimento questa forza governa il proprio stato d'animo senza spegnerlo: la mano resta ferma sul timone dei sentimenti che riguardano il tuo caso, con il mare sotto che si vede tutto.
- 3: Fra l'onda che passa adesso sulla tua domanda e la quiete che la stessa maturità renderebbe corre un margine esatto: la distanza fra sentire molto e lasciarsi condurre.

### capovolta

- 1: Se nulla andasse sprecato, la maturità che tocca la tua questione starebbe al comando invece dell'umore del giorno: lo stesso cuore, con la guida in mano al posto giusto.
- 2: Il massimo in gioco è una competenza intatta e un meccanismo smontato: l'umore che fa da leva sul tuo caso si lascia riconoscere per quello che è, leva e non sentimento.
- 3: Al suo meglio questa forza nomina chi sta davvero al comando nella tua domanda e non restituisce il governo: arriva a smascherare la leva, a riprendere il timone non arriva.

## Asso di Denari

### dritta

- 1: Il punto più alto di questa forza, nella tua questione, è un'apertura materiale intera: una sola, concreta, non ancora lavorata. Sopra quel seme non sale, perché il seme è tutto quello che sa offrire.
- 2: Senza sprechi, la tua domanda avrebbe tra le mani un principio solido: terreno buono, una posta concreta, nessun bisogno di talento particolare per riconoscerne il valore.
- 3: Questa forza porta alla tua questione il primo dato concreto, pesabile e in mano; non arriva a darti il mestiere per farlo crescere, perché un principio apre il campo e non lo coltiva.

### capovolta

- 1: Il meglio che questa forza sa dare alla tua questione è una pesata rifatta: quello che hai davanti rimesso sulla bilancia al prezzo giusto, senza lo sconto della distrazione né il rincaro dell'allarme.
- 2: Questo massimo, per la tua domanda, è fatto di una stima: il valore reale di una cosa materiale che sta sul tavolo adesso, con il suo prezzo accanto e nessun secondo tentativo.
- 3: Al suo meglio questa forza lascia in piedi nella tua questione la cosa stessa: un bene concreto non si consuma se lo guardi male e una stima sbagliata non ne cambia il peso.

## Due di Denari

### dritta

- 1: Il tetto di questa forza sulla tua questione è la destrezza: più cose tenute in aria insieme senza che una cada; oltre quella tenuta non sale, perché la destrezza non riduce i pesi.
- 2: A pieno rendimento la tua questione avrebbe il passo di un giocoliere: impegni diversi alternati con leggerezza, nessuno trascurato per troppo tempo, nessuno irrigidito in regola fissa.
- 3: Una mano agile su più fronti è quanto questa forza offre alla tua questione; quello che non dà, nemmeno al meglio, è un peso in meno fra quelli che stai tenendo.

### capovolta

- 1: Il meglio che questa forza sa dare alla tua questione è il conto esatto di quante cose hai in mano insieme, con il nome di quella che la presa non regge.
- 2: Di questo massimo fanno parte il numero dei fronti aperti sulla tua questione, il peso di ciascuno e una graduatoria fra cose che sembrano tutte urgenti.
- 3: Quello che questa forza al suo meglio tiene in piedi sono le poche cose che la tua questione regge davvero, salve proprio perché poche, mentre le altre scivolano.

## Tre di Denari

### dritta

- 1: Il tetto di questa forza è la competenza riconosciuta: può dare al tuo lavoro la stima di chi ci mette le mani accanto, non il compimento dell'opera.
- 2: A pieno rendimento un'opera a più mani sa dare la prova del mestiere: alla tua questione consegna il primo pezzo finito, con il nome di ciascuno leggibile sopra la propria parte.
- 3: Fra quanto il tuo mestiere rende da solo e quanto renderebbe dentro un cantiere dove i ruoli combaciano, la distanza ancora aperta è la misura di quello che il lavoro comune aggiunge.

### capovolta

- 1: Se nulla lo sprecasse, questo disaccordo diventerebbe un verbale: gli incarichi da una parte, le pretese non dette dall'altra, il tuo cantiere ridotto a un elenco con un nome accanto a ogni riga.
- 2: Il meglio in gioco è fatto di parole dette: quale pezzo dell'opera toccava a chi, quale pretesa nessuno ha messo sul tavolo, quanto della tua fatica stava coprendo un buco di altri.
- 3: Una collaborazione che stride può mostrare il punto esatto in cui il tuo progetto si inceppa sui ruoli; quello a cui non arriva, nemmeno al suo meglio, è la sintonia fra le persone.

## Quattro di Denari

### dritta

- 1: Il tetto di questa carta è la conservazione: quello che la tua questione tiene in mano si può mettere al sicuro per intero; di suo questa presa non aumenta la somma di un centesimo.
- 2: A pieno rendimento questa stretta dà alla tua domanda una sicurezza senza falle: niente esce per distrazione, niente si consuma di nascosto; il conto torna ogni volta che lo apri.
- 3: Fra un patrimonio che perde da ogni parte e lo stesso patrimonio custodito con le due braccia corre lo spazio che questa carta può coprire per la tua questione: si misura in perdite evitate.

### capovolta

- 1: Se nulla la trattenesse, questa mano si aprirebbe quanto basta: la tua questione resterebbe custodita e insieme capace di ricevere, con le dita allentate sul bordo di quello che tiene.
- 2: Questo massimo è fatto di dita che si allentano: il timore di perdere perde il comando, la tua domanda smette di difendersi e il palmo torna libero di prendere.
- 3: Una presa la si può allentare, il timore che l'ha chiusa resta sotto: alla tua questione questa forza offre al massimo una mano capace di ricevere, con la paura seduta accanto.

## Cinque di Denari

### dritta

- 1: Al suo meglio questa mancanza tiene in piedi la cosa che il pudore stava per portarsi via: la tua questione conserva il diritto di chiedere, intatto malgrado il freddo preso.
- 2: Il bene in gioco è lucidità sul bisogno, non calore: il più alto che questa forza dà alla tua domanda è il bisogno detto chiaro, senza il pudore che lo tiene zitto.
- 3: Più su di qui non sale: l'altezza è la mano alzata su una porta illuminata a pochi passi dalla tua questione, col pudore messo da parte per il tempo di battere.

### capovolta

- 1: Al rendimento pieno questa ripresa dà alla tua questione il rientro di chi era rimasto fuori: il meglio che sa offrire è un sostegno ritrovato, col freddo alle spalle.
- 2: Fra il gelo in cui la tua questione è stata e il caldo di una stanza che si riapre resta un tragitto: il massimo è quanto di quel tragitto si compie.
- 3: Se nulla fosse sprecato, questo allentarsi avrebbe sulla tua domanda la forma di una porta riaperta a chi ha battuto i denti fuori: il sostegno accolto senza imbarazzo.

## Sei di Denari

### dritta

- 1: Quello che questa forza salva, al massimo, è il circolo: nella tua questione quello che esce rientra nella stessa misura e nessuna delle due mani resta vuota.
- 2: Il genere di bene che sta in cima è equità e non abbondanza: lo scambio che riguarda il tuo caso si chiude pari, mentre la quantità che gira non cresce per questo.
- 3: Più in alto di uno scambio pesato con esattezza questa forza non arriva: la bilancia dice la misura giusta per la tua domanda, non quanto ci sia da mettere sui piatti.

### capovolta

- 1: Al suo pieno rendimento questa forza mette in chiaro quanto sia sbilanciato lo scambio che tocca la tua questione: tanto esce da una parte, tanto poco rientra dall'altra.
- 2: Fra quello che la tua generosità consegna e quello che le torna indietro resta aperto un vuoto: questa forza lo misura fino all'ultimo centesimo, senza colmarlo.
- 3: Se nulla si sprecasse, i due piatti dello scambio che riguarda il tuo caso porterebbero lo stesso peso e chi dà non resterebbe svuotato dal proprio dono.

## Sette di Denari

### dritta

- 1: Fra il campo che la tua questione tiene adesso e quanto potrebbe valerle c'è soltanto del tempo: una maturazione che lavora da sola, mentre le mani restano ferme a guardare quanto manca.
- 2: Al suo meglio la sosta fa vedere alla tua domanda quanto vale il campo prima che sia pronto; quello che non arriva a darti è la raccolta, perché una stima conta e non stacca.
- 3: Il genere di bene in gioco nella tua questione è lentezza e non abbondanza: conta la qualità dell'attesa, non la grandezza del cesto; il frutto giusto al tempo giusto, non il frutto più grosso.

### capovolta

- 1: Se nulla la sprecasse, l'impazienza nella tua questione diventerebbe una verifica: mano nella terra, seme in mano, la distinzione fra un frutto in ritardo e un frutto che da quel seme non viene.
- 2: Al suo meglio questa forza salva nella tua domanda lo sforzo ancora recuperabile: smettere di tirare un ramo verde non ripaga niente, però lascia il ramo attaccato e la pianta in condizione di reggere.
- 3: Il tetto di questa forza, nella tua questione, è una domanda sola fatta bene: se il seme fosse quello giusto. Più in alto non arriva, perché controllare un seme non lo cambia.

## Otto di Denari

### dritta

- 1: Fra come la tua questione è fatta adesso e come sarebbe rifinita resta un margine di dettagli: è esattamente quello che una mano esercitata può chiudere.
- 2: Il bene al massimo qui è di specie artigiana, precisione e non velocità: la tua questione può valere per come è rifinita nei punti che nessuno guarda, uno alla volta.
- 3: La ripetizione del gesto porta alla tua questione una qualità che si vede da vicino; quello che non dà, nemmeno al suo meglio, è l'occhio di chi passa di fretta.

### capovolta

- 1: Il tetto di questa forza sulla tua questione è una domanda onesta sul senso di quello che fai ogni giorno: può porla con chiarezza, mai sostituire il mestiere con un'altra ragione per farlo.
- 2: A pieno rendimento la tua questione vedrebbe la differenza fra il gesto eseguito bene e il gesto abitato, con la monotonia riconosciuta per quello che è e il mestiere lasciato intatto.
- 3: Quello che questa forza al suo meglio salva nella tua questione è la competenza: resta nelle mani anche quando la cura si è spenta, pronta per il momento in cui il senso ritorna.

## Nove di Denari

### dritta

- 1: Al suo meglio questa autonomia lascia intero il piacere privato: il frutto resta nelle mani che lo hanno fatto crescere; quello che si salva è il tuo diritto a goderne senza testimoni.
- 2: Di che genere di bene si tratta: indipendenza e non abbondanza. Il tetto di questa forza per la tua questione è uno spazio tutto tuo in cui stare, mai una quantità da contare.
- 3: Il punto in cui questa forza smette di salire è il bastare a sé: può dare al tuo giardino la quiete di chi non deve niente, non la compagnia di chi lo attraversa.

### capovolta

- 1: A pieno rendimento un'indipendenza che vacilla sa dare il conto di quanto costa mostrarla: alla tua questione restituisce la differenza fra il bene che serve e quello che fa da insegna.
- 2: Fra quanto la tua libertà vale adesso e quanto varrebbe senza la spesa che la esibisce, la distanza ancora aperta è precisamente il prezzo dello sguardo altrui su quello che possiedi.
- 3: Se nulla la consumasse, questa autonomia incrinata tornerebbe sobria: il bene venuto dalle tue mani starebbe in piedi senza vetrina, misurato su quello che serve invece che su chi guarda.

## Dieci di Denari

### dritta

- 1: Al suo meglio questa carta lascia in piedi la casa intera: quello che riguarda la tua questione passa di mano fra chi è venuto prima e chi viene dopo, senza che nessuno resti fuori.
- 2: Durata più che abbondanza: il bene che questa carta porta alla tua domanda è materiale e lento, un patrimonio che regge il peso di tre generazioni sotto lo stesso tetto.
- 3: Il punto più alto di questa solidità è il nome della casa: alla tua questione può toccare un bene che resta in piedi oltre chi lo ha costruito, più saldo che tenero.

### capovolta

- 1: Quello che questa carta sa dare quando vacilla è una spartizione fatta in chiaro: il bene comune che riguarda la tua questione prende un nome per ogni parte; l'attrito smette di essere muto.
- 2: Fra una contesa che nessuno nomina e un conto aperto sul tavolo di famiglia corre tutto quello che questa casa in attrito può recuperare alla tua domanda: il margine qui è la chiarezza.
- 3: Se niente lo sprecasse, questo attrito servirebbe a qualcosa: quello che appartiene a più di una persona avrebbe confini scritti; il legame fra i tuoi resterebbe in piedi dopo la divisione.

## Fante di Denari

### dritta

- 1: Il massimo è fatto di pazienza e di esercizio ripetuto: sulla tua questione questa forza mette una materia nuova che passa dal quaderno alle mani, un pezzo per volta.
- 2: Questa applicazione, al suo meglio, dà alla tua domanda una competenza che comincia a tenere; non arriva a dare la maestria, perché quella chiede anni che la buona volontà non compra.
- 3: Al suo meglio questo apprendere salva intera la serietà di chi comincia: la tua questione tiene in piedi un impegno preso, portato avanti anche quando la novità si è spenta.

### capovolta

- 1: Il bene qui è di specie scomoda: il conto esatto fra quello che hai promesso e quello che la tua mano ha fatto davvero. Il tetto è quel confronto guardato in faccia.
- 2: Più in alto questa forza non va: l'altezza è il proposito ripreso dal punto in cui si è fermato, con la distanza fra il detto e il fatto misurata sulla tua questione.
- 3: Al rendimento pieno questa interruzione dà alla tua domanda una cosa utile: il punto preciso in cui lo slancio ha lasciato il lavoro, insieme al motivo che lo ha fermato lì.

## Cavaliere di Denari

### dritta

- 1: Il massimo in gioco è fatto di una cosa ripetuta: lo stesso passo, alla stessa ora, su tutta la lunghezza della tua questione, senza un giorno saltato e senza strappi.
- 2: Al suo meglio questa forza copre tutta la distanza che la tua domanda ha davanti e non ne accorcia il tempo: la costanza regge il tratto intero, la fretta non la sa dare.
- 3: Quello che resta in piedi, quando questa forza rende tutto, è l'affidabilità: chi guarda il tuo caso sa in anticipo quale passo aspettarsi; nulla di quel passo cambia.

### capovolta

- 1: Il genere di massimo che tocca al tuo caso è conservazione e non movimento: la strada tracciata resta buona e intera, mentre il piede che non si stacca non diventa passo.
- 2: Più in alto di un piano tenuto pronto questa forza non sale: la tua questione conserva ogni tappa al suo posto, con la prudenza che rimanda e non guasta nulla.
- 3: Al suo meglio questa forza ti mostra dove si inceppa il tuo avanzare: la strada tiene e il blocco sta tutto nel piede, che rimanda ogni tappa una per una.

## Regina di Denari

### dritta

- 1: La materia di questo massimo, nella tua questione, è contabile: una tavola che basta per tutti, i conti in ordine, una casa calda e il lavoro che rende. Nessun miracolo nella dotazione.
- 2: Il bene in gioco per la tua domanda è di specie nutriente: non ricchezza da esibire, piuttosto abbondanza che passa in pasti, in stanze tiepide, in bollette pagate senza fare rumore.
- 3: Portata al suo meglio, questa forza mette insieme nella tua questione due cose che di solito stanno separate: l'affetto e l'amministrazione, la mano che accarezza e la mano che tiene il registro.

### capovolta

- 1: Questa forza sa fare l'elenco completo di ciò che curi ogni giorno nella tua questione; non arriva a darti il tempo in più, perché una riga aggiunta non allunga la giornata.
- 2: Il punto più alto di questa forza è il tuo nome scritto nel registro delle cose da curare, una riga come le altre: oltre non va, perché un registro annota e non provvede.
- 3: Fra la cura che la tua questione distribuisce adesso e quanto potrebbe valerle c'è una riga sola: la stessa praticità rivolta anche a chi la esercita, con la stessa misura e senza sconto.

## Re di Denari

### dritta

- 1: Di questo massimo fanno parte l'abbondanza concreta, il mestiere di farla rendere e una generosità misurata, che sulla tua questione pesa quanto l'abbondanza stessa.
- 2: Il bene possibile qui è di specie adulta, solidità e non slancio: la tua questione può contare su una prosperità amministrata da mani che sanno anche spendere.
- 3: Quanto questa forza sa dare, al pieno, è una ricchezza che lavora: messa a frutto sulla tua questione con la calma di chi non ha bisogno di difenderla da nessuno.

### capovolta

- 1: Il punto oltre il quale questa forza non sale è il riconoscimento: la tua questione può vedere con esattezza quanto il possesso comanda chi lo amministra, senza che vederlo allenti la stretta.
- 2: Fra una ricchezza che serve e una ricchezza che governa resta sulla tua questione un margine sottile: è tutto quello che questa forza, al suo meglio, riesce a illuminare.
- 3: La solidità costruita può offrire alla tua questione misura e credito presso gli altri; quello che non dà, nemmeno al meglio, è la leggerezza di chi lascia andare una parte.

## Asso di Spade

### dritta

- 1: Il massimo qui è fatto di un solo taglio: da una parte quello che nella tua questione è vero, dall'altra quello che la teneva comoda; nessun terzo mucchio in mezzo.
- 2: Una lucidità portata al suo limite può dare alla tua domanda una distinzione netta in un colpo solo; quello a cui non arriva, al suo meglio, è la delicatezza con cui pronunciarla.
- 3: Al suo meglio questo taglio lascia intatto il vero: cade la parte che reggeva per abitudine; il tuo giudizio resta con meno materia davanti e con materia buona.

### capovolta

- 1: Di che specie è il bene possibile: strumento integro e non vista chiara. Il più alto che questa lama appannata sa dare alla tua questione è il filo, mai la luce per vedere dove posarlo.
- 2: Il tetto di questa forza è la potenza del colpo: può dare al tuo discorso un taglio che arriva a fondo; non può mostrargli il punto in cui cade.
- 3: A pieno rendimento una lama confusa sa dare la forza senza la misura: alla tua questione mette in mano uno strumento intatto, con l'affilatura intera e la mira appannata.

## Due di Spade

### dritta

- 1: Questo massimo è fatto di due lame tenute pari: una tregua vera sulla tua questione, con le braccia ferme e gli occhi coperti per scelta, fino al momento di scoprirli.
- 2: Una tregua questa carta la sa tenere a lungo, la decisione no: alla tua domanda spetta un equilibrio onesto fra i due pesi, con la scelta che resta intera sul tavolo.
- 3: Al suo meglio questa carta salva entrambe le ragioni della tua questione: nessuna delle due viene schiacciata per fare prima; il peso di ciascuna resta misurabile quando la benda si abbassa.

### capovolta

- 1: Lucidità più che pace: il bene che questa tregua che cede porta alla tua questione è uno stallo che si scioglie a occhi aperti, con le due ragioni finalmente guardate in faccia.
- 2: Il tetto qui è la riapertura: la scelta messa da parte torna disponibile per intero alla tua domanda; questa spinta la rimette sul tavolo senza compierla al posto tuo.
- 3: Quello che questo stallo sa dare quando cede è la benda che scende: la tua questione vede quello che copriva; i due pesi tornano a pesare alla luce.

## Tre di Spade

### dritta

- 1: Fra il dolore tenuto a bocca chiusa e il dolore nominato per quello che è corre il margine di questa forza: il massimo sulla tua questione è quel passaggio, aspro quanto serve.
- 2: Se niente andasse sprecato, questa ferita avrebbe sulla tua domanda la forma di un taglio pulito: una causa riconosciuta, un punto esatto, le lacrime lasciate scorrere fino in fondo.
- 3: Il massimo è fatto di due cose dure: il nome del colpo e il permesso di sentirlo. Sulla tua questione questa forza mette in chiaro chi ha colpito e quando.

### capovolta

- 1: Questo rimarginare, al suo meglio, dà alla tua questione un petto che smette di sanguinare; non arriva a dare la memoria pulita, perché il fatto resta scritto dove è accaduto.
- 2: Al suo meglio questo perdono tiene in piedi quello che il rancore stava consumando: sulla tua domanda resta intera la facoltà di respirare accanto a chi ti ha fatto male.
- 3: Il bene in gioco è respiro, non oblio: il tetto di questa forza sulla tua questione è una cicatrice che tiene, con la pioggia passata e il ricordo al suo posto.

## Quattro di Spade

### dritta

- 1: Fra la stanchezza che grava adesso sulla tua questione e la forza che una quiete piena restituisce corre un margine preciso: è tutto il silenzio che manca.
- 2: Se nulla si sprecasse, la pausa che tocca il tuo caso sarebbe intera: nessun pensiero di battaglia dentro il silenzio e la fatica scaricata fino in fondo, senza un residuo.
- 3: Il massimo in gioco è fatto di silenzio e di tempo fermo: la tua questione riposa come riposa chi depone le armi dopo la fatica, con le armi ancora lì accanto.

### capovolta

- 1: Al suo meglio questa forza rimette in moto ciò che riguarda la tua domanda senza dire su che cosa: il rientro è suo, la scelta del lavoro da riprendere no.
- 2: Quello che resta intatto, quando questa forza rende tutto, è il vigore recuperato: il tuo caso torna al moto con le riserve piene, senza un'oncia di quiete sprecata.
- 3: Il bene al massimo è prontezza, non slancio: il passo che riprende nella tua questione è lento di proposito, perché una ripresa misurata è quanto questa forza sa dare.

## Cinque di Spade

### dritta

- 1: Al suo meglio questa forza tiene in piedi, nella tua questione, il conto esatto di una vittoria: il campo a chi lo prende, le armi raccolte contate, il prezzo scritto accanto alla posta.
- 2: Il meglio che questa forza sa dare alla tua domanda è una sincerità ruvida: dice quanto vale il campo conquistato e quanto costa tenerlo, senza gonfiare la posta per giustificare la spesa.
- 3: A pieno rendimento la tua questione avrebbe una resa dei conti pulita: la cosa ottenuta da una parte, il prezzo dall'altra, nessun orgoglio messo sul piatto per raddrizzare la somma.

### capovolta

- 1: Il bene che questa forza può portare alla tua questione è di specie disarmata: non una ragione più solida, piuttosto una ragione lasciata cadere da chi potrebbe ancora spenderla tutta.
- 2: Tra la ruggine che la tua domanda tiene adesso e quanto potrebbe valerle c'è un gesto piccolo: le armi messe a terra da uno solo dei due, senza accordo né garanzia di risposta.
- 3: Fatto di un gesto unilaterale, questo massimo porta alla tua questione le armi deposte prima della resa dell'altro: nessuna riconciliazione garantita, nessun torto cancellato nel frattempo.

## Sei di Spade

### dritta

- 1: Il meglio che questa forza sa dare alla tua questione è una traversata senza clamore: acque che si distendono mentre il carico resta a bordo, con la riva di partenza che si assottiglia.
- 2: A pieno rendimento la tua questione avrebbe la forma di un passaggio compiuto in silenzio, un tratto d'acqua calma per volta, con chi rema che conosce il mestiere.
- 3: Quello che questa forza al suo meglio tiene in salvo è il carico: nel passaggio la tua questione porta con sé quello che le serve, intero, senza lasciarlo sull'altra riva.

### capovolta

- 1: Fra un distacco che pesa e un distacco impossibile resta un margine praticabile sulla tua questione: la partenza con il carico vecchio ancora dentro la valigia.
- 2: Di questo massimo fanno parte il congedo detto per quello che è, il movimento che avviene comunque e un cuore della tua questione che resta indietro senza bloccare il resto.
- 3: Il bene possibile qui è di specie ruvida, onestà e non sollievo: la tua questione può muoversi portandosi appresso quello che non ha ancora deposto.

## Sette di Spade

### dritta

- 1: Fra quanto la tua questione ottiene andando di petto e quanto otterrebbe per via obliqua, la distanza ancora aperta è quella che l'ingegno copre senza spendere forza.
- 2: Se nulla la sprecasse, questa astuzia darebbe alla tua faccenda il risultato pieno a prezzo minimo: la mossa laterale fatta a occhi aperti, col conto di quanto costa tenuto in vista.
- 3: Il massimo possibile è fatto di tre parti: l'ingegno che trova la via di fianco, il tatto che la percorre senza rumore, l'onestà con cui ti dici quello che stai facendo.

### capovolta

- 1: Un gioco coperto che viene a galla può restituire al tuo nome la trasparenza e togliere il peso di una partita doppia; al suo meglio non arriva a scegliere il momento.
- 2: Al suo meglio questa emersione salva la coscienza: quello che si perde è il vantaggio tenuto nascosto; quello che resta intero nella tua questione è il poterla raccontare per intero.
- 3: Il massimo è di qualità, non di quantità: il respiro di chi non ha più niente da coprire. La tua coscienza può restare sgombra, ma ciò che la copertura ha guastato non torna.

## Otto di Spade

### dritta

- 1: Fra un recinto creduto chiuso e un recinto misurato con le mani corre tutto quello che questa carta può aprire alla tua questione: il margine è la larghezza vera delle corde.
- 2: Se nulla la sprecasse, questa carta mostrerebbe alla tua domanda il recinto per quello che è: lame piantate nel fango senza nessuno a sorvegliarle, più un nodo allacciato da mani tue.
- 3: Questo massimo è fatto di misure prese: la larghezza delle corde, la distanza fra le lame, il peso vero del timore che tiene ferma la tua questione, contato una cosa per volta.

### capovolta

- 1: Una libertà questa prigione che cede la sa riconoscere, non la sa regalare: quello che la tua questione scopre è un recinto senza custode, aperto da prima che qualcuno lo notasse.
- 2: Al suo meglio questa carta prende sul serio il timore invece di deriderlo: la paura che fermava la tua domanda resta seria, ma accanto a lei l'uscita si vede a occhi asciutti.
- 3: Sollievo più che trionfo: il bene che questa benda che scivola porta alla tua questione è la scoperta di una libertà che c'era, con le corde che cadono da sé.

## Nove di Spade

### dritta

- 1: Più in alto questa angoscia non sale: l'altezza è riconoscere l'autore di quei pensieri, cioè una mente che al buio lavora per conto proprio sulla tua questione.
- 2: Al rendimento pieno questo tormento dà alla tua domanda la differenza fra quello che è accaduto davvero e quello che le ore insonni ne hanno fatto di notte.
- 3: Fra la misura vera della tua questione e la misura che prende alle tre di notte corre tutto il margine di questa forza: il massimo è quella distanza contata una volta.

### capovolta

- 1: Se nulla si sprecasse, questo allentarsi darebbe alla tua questione il peso diviso in due: quello che gira in testa portato fuori, davanti a qualcuno che sta ad ascoltare.
- 2: Il massimo è fatto di parole dette a un altro: sulla tua domanda questa forza mette il rimuginio rotto da una frase pronunciata, che dentro il cranio da sola non si rompeva.
- 3: Questo sgonfiarsi, al suo meglio, dà alla tua questione un peso dimezzato dal racconto; non arriva a dare la notte cancellata, perché il ricordo di come è stata resta tuo.

## Dieci di Spade

### dritta

- 1: Il punto più alto è un fondo che regge come un pavimento: la discesa che riguarda la tua questione si esaurisce lì; il sollevarsi è materia di un'altra forza.
- 2: Al suo pieno rendimento questa forza chiude il conto di una battaglia persa senza lasciare un lembo aperto: nella tua domanda nessuna resistenza resta a chiedere ancora energia.
- 3: Fra il peso che schiaccia il tuo caso adesso e il peso di una resa riconosciuta corre una differenza intera: quella fra lottare per nulla e sapere conclusa la lotta.

### capovolta

- 1: Se nulla andasse sprecato, il terreno della tua questione sarebbe sgombro per intero e la risalita partirebbe da una base pulita, senza un debito con quello che stava prima.
- 2: Il massimo in gioco è fatto di due cose tue: un corpo che si rialza con le proprie mani e un suolo libero, dove nulla di vecchio resta da portare addosso.
- 3: Al suo meglio questa forza ti rimette in piedi nel tuo caso e non restituisce niente di quello che stava prima: il ritorno al movimento è suo, il recupero del perduto no.

## Fante di Spade

### dritta

- 1: Più in alto di una vigilanza pura questa forza non sale, nella tua questione: occhi aperti su tutto, niente dato per scontato, ogni notizia raccolta e riferita senza filtro.
- 2: Senza sprechi, la tua domanda avrebbe un esploratore giovane al proprio servizio: uno che va, guarda e riporta quello che vede, con la lingua rapida e nessuna tesi da difendere.
- 3: Questa forza porta alla tua questione lo sguardo che non si distrae e la prontezza di dire quello che trova; non arriva a darti il giudizio, perché un esploratore riferisce e non decide.

### capovolta

- 1: Il meglio che questa forza sa dare alla tua questione è un giro ricostruito: chi dice che cosa, da dove parte la chiacchiera, in quante mani passa prima di tornare indietro.
- 2: La materia di questo massimo, nella tua domanda, è una verifica: ogni parola riferita confrontata con la sua fonte prima di passare a un orecchio nuovo. Nient'altro, nessuna smentita pubblica.
- 3: Quello che questa forza, al suo meglio, lascia intatto nella tua questione è la reputazione non ancora toccata: una parola trattenuta in tempo non ferisce nessuno; un silenzio non si deve rettificare.

## Cavaliere di Spade

### dritta

- 1: Il tetto di questa forza sulla tua questione è la rapidità: una decisione presa e portata a termine prima che altri si muovano; più in alto non sale, perché la fretta non aggiunge ragione.
- 2: A pieno rendimento la tua questione avrebbe l'andamento di un assalto pulito: un pensiero deciso, nessun ripensamento in mezzo, il colpo dove era stato puntato.
- 3: Una mente che carica può dare alla tua questione il vantaggio di chi arriva per primo; quello che non dà, nemmeno al meglio, è il tempo di guardare chi resta indietro.

### capovolta

- 1: Il meglio che questa forza sa dare alla tua questione è il conto dei passi indietro che una fretta costa, fatto con la mente ancora lucida mentre la corsa è in atto.
- 2: Di questo massimo fanno parte un istante di sosta dentro la corsa, le parole affilate trattenute prima di partire e la tua questione che resta intatta per averle trattenute.
- 3: Quello che questa forza al suo meglio tiene in piedi nella tua questione è la lucidità: intera anche nella fretta, disponibile nel momento in cui la corsa concede un respiro.

## Regina di Spade

### dritta

- 1: Il tetto di questa forza è il confine detto chiaro: può dare alla tua questione una frontiera nominata senza scuse, non la comodità di chi la sente dire.
- 2: A pieno rendimento una lucidità come questa sa dare parole esatte sul proprio limite: al tuo rapporto consegna il perimetro, detto una volta e senza addolcirlo per renderlo accettabile.
- 3: Fra quanto la tua questione regge sui silenzi e quanto reggerebbe con ogni confine nominato per nome, la distanza ancora aperta è quella di una frase che nessuno ha pronunciato.

### capovolta

- 1: Se nulla lo sprecasse, questo rigore rivolto all'interno diventerebbe criterio: il metro severo resterebbe intatto e cambierebbe destinatario, applicato al tuo lavoro invece che a te.
- 2: Il meglio in gioco è fatto di materia fredda: la solitudine tenuta per scelta, il metro che non fa sconti, la lucidità che resta intera anche quando il tuo giudizio si volta all'interno.
- 3: Una durezza portata al limite può dare alla tua questione un criterio che non cede alle convenienze; quello a cui non arriva, nemmeno al suo meglio, è il calore di una compagnia.

## Re di Spade

### dritta

- 1: Il tetto di questa carta è un verdetto che tiene: la tua questione può avere una decisione equa, presa da chi ne risponde in pubblico; oltre questa giustizia la spinta non sale.
- 2: A pieno rendimento questa autorità dà alla tua domanda una regola detta chiara e applicata a sé per prima: la ragione messa al servizio del bene comune, col nome di chi firma.
- 3: Fra un'opinione ferma e una decisione che qualcuno è disposto a far valere corre lo spazio che questa carta può coprire per la tua questione: la misura è in responsabilità assunta.

### capovolta

- 1: Se niente la sprecasse, questa severità che s'incrina ragionerebbe con le persone dentro il conto: la tua questione avrebbe un giudizio esatto e abitabile, con la logica che lascia posto alla pietà.
- 2: Questo massimo è fatto di due misure insieme: la regola che non cede di un millimetro e la compassione per chi la subisce, cucite nella stessa decisione sulla tua questione.
- 3: Una durezza si può temperare, mentre la discussione vinta a freddo resta vinta: alla tua domanda questa carta offre un rigore che si accorge delle persone.
