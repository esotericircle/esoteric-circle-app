# Oroscopo cinese del giorno, bozza del corpus (ordine ES, voce 08)

Voce di Medora: calda, diretta, concreta. Non promette, non inventa, non attribuisce caratteri agli animali. Ogni frase dice che cosa suggerisce la regola della tradizione e che cosa farne oggi.

Segnaposti (li riempie l'app):

- `{animale_giorno}`, `{animale_tuo}`: col proprio articolo, per esempio "il Cavallo", "la Capra" (tabella `ISegniDelleTradizioni.animali`).
- `{guardiano}`: il nome italiano del guardiano del giorno (Stabilire, Togliere, Pieno, ...).
- `{colore}`, `{elemento}`, `{numeri}`, `{direzione_gioia}`, `{direzione_ricchezza}`.

Scelta delle varianti: la variante segue il ritorno del caso, non il giorno. Ogni volta che lo stesso caso torna (il ramo del giorno ogni dodici giorni, il dio ogni dieci, il Dio della Gioia nello stesso posto ogni cinque, l'elemento e il Dio della Ricchezza per due tronchi di fila ogni dieci giorni, il guardiano alla sua prossima volta, contando anche il giorno del jie che lo ripete) la persona legge la variante successiva del gruppo. Prima la variante era il giorno giuliano modulo il numero delle varianti: il ramo torna ogni dodici giorni, dodici è multiplo di tre, e la stessa persona leggeva la stessa frase ogni volta che tornava lo stesso animale (ordine ES voce 08, docs/collaudo/ES/regola_a_lettura_cinese.txt; la lezione della EE.04 nel CLAUDE.md).

Composizione delle schede, dal 30 settembre 2026. Generale: nella Breve il testo del rapporto fra i due animali (sezione 1) e quello del guardiano (sezione 2); la Lunga aggiunge "Adatto a" e "Meglio evitare" del guardiano e il testo del Dio della Gioia (sezione 4.2). Amore, Lavoro, Fortuna: nella Breve il testo del dio del giorno (sezione 3); la Lunga aggiunge la variante seguente dello stesso dio e, nella Fortuna, il testo del Dio della Ricchezza. Il TESTO va nella lettura, il DA DOVE VIENE nella riga "Da dove viene" sotto la lettura, e i titoli delle schede sono le righe `Titolo:` dei casi. La riga del colore e dei numeri (sezione 4.1) resta in fondo alla Fortuna, come la riga del numero e del colore delle altre tradizioni.

Le regole e le fonti richiamate qui sono spiegate per intero in `specifiche.md`, paragrafi 2, 3 e 4.

---

## Le tre parti di ogni frase (dal 30 settembre 2026)

Il fondatore, davanti alle letture: *"all'utente non gliene frega un cazzo dei transiti, quante volte devo scriverlo e chiederlo? Vuole sapere come andrà in generale, in amore, in lavoro, ecc. Se vuoi inserire i transiti, li inserisci dopo giusto per motivare da dove arriva la risposta."* E le Linee Guida, sezione 2: la risposta, che cosa puoi fare, da dove viene; *"il simbolo non apre mai"*.

Ogni frase numerata sta su una riga sola e ha due pezzi, separati da ` || `:

```
N. TESTO || DA DOVE VIENE
```

- **TESTO**: la risposta (come va, in parole di tutti i giorni) e che cosa puoi fare (un gesto concreto). Nessun simbolo e nessun termine del metodo.
- **DA DOVE VIENE**: il simbolo e la regola della tradizione. È la sola parte in cui compaiono.

L'app mette il TESTO nella lettura della scheda e il DA DOVE VIENE nella riga "Da dove viene", sotto la lettura. Dove c'è, la riga `Titolo:` di un caso è il nome in parole della scheda. Le frasi di prima, che aprivano col simbolo, stanno nella storia del repository (commit precedenti a questo).

## 1. Scheda Generale: il rapporto fra l'animale del giorno e il tuo

Regola: si confronta il ramo del giorno col ramo dell'anno di nascita; se i rapporti sono due vale il primo nell'ordine scontro, punizione, danno, armonia, tripla armonia, stesso animale, nessuno; la coppia Serpente e Scimmia ha un gruppo suo. Fonte: 三命通会 (Sanming Tonghui, 1578), libro II, capitoli sui sei accordi, le tre armonie, i tre castighi, i sei danni, gli scontri; 五行大义 (Wuxing Dayi), capitoli sugli accordi, gli scontri, i castighi e i danni.

### 1.1 Armonia (六合 Liu He)

Regola: sei coppie di rami si "accordano" (子丑, 寅亥, 卯戌, 辰酉, 巳申, 午未): nel 三命通会 l'accordo è l'unione di yin e yang che si completano.
Titolo: Una giornata d'intesa

1. Oggi le cose fatte in due riescono meglio di quelle fatte in solitudine. Fai la telefonata che rimandi, chiudi un accordo o chiedi l'aiuto che ti serve. || Oggi è il giorno di {animale_giorno}, che nella tradizione cinese si accorda con {animale_tuo}: è una delle sei coppie in armonia.
2. Oggi la giornata rende di più accanto a chi ti completa che per conto tuo. Scegli una cosa che stai portando avanti senza aiuto e proponi a una persona precisa di farne metà. || Il giorno lo guida {animale_giorno}: il suo ramo e quello del tuo animale formano una delle sei armonie, due metà che si completano.
3. Oggi collaborare ti costa meno fatica del solito, anche se niente si muove senza che ti muova tu. Siediti un quarto d'ora con chi condivide un impegno con te e decidete insieme il prossimo passo. || Il ramo di oggi e quello del tuo anno di nascita sono una coppia che la tradizione cinese chiama "accordo": è una giornata in armonia col tuo animale.

### 1.2 Tripla armonia (三合 San He)

Regola: quattro terne di rami formano un elemento insieme (申子辰 acqua, 亥卯未 legno, 寅午戌 fuoco, 巳酉丑 metallo); due rami della stessa terna sono in "mezza armonia" (半合).
Titolo: La forza del gruppo

1. Oggi funziona ciò che coinvolge più persone: un gruppo, una squadra, la famiglia. Proponi un pranzo o una riunione breve per decidere insieme una cosa che riguarda tutti. || Il ramo di {animale_giorno} e quello di {animale_tuo} appartengono alla stessa terna, il gruppo che la tradizione cinese lega a {elemento_terna}: un'intesa più larga di una coppia.
2. Oggi è una giornata buona per ricucire: le persone si ritrovano più volentieri. Rimetti in contatto due persone che da tempo non si parlano, con un messaggio a entrambe o un invito allo stesso tavolo. || Oggi guida {animale_giorno}, che sta nella stessa terna del tuo animale: nell'almanacco cinese le terne sono alleanze.
3. Oggi è un buon giorno per coinvolgere gli altri in ciò che non dipende solo da te. Se hai un progetto fermo in attesa di qualcuno, scrivi adesso a quella persona e dille con precisione che cosa ti serve. || Il giorno di {animale_giorno} è alleato del tuo anno: i vostri sono due dei tre rami che insieme fanno {elemento_terna}.

(`{elemento_terna}`: "l'acqua", "il legno", "il fuoco", "il metallo".)

### 1.3 Scontro (六冲 Chong)

Regola: i rami opposti (distanza sei) si urtano. Gli almanacchi scrivono ogni giorno "冲" seguito dall'animale che si scontra col giorno: è l'avvertimento più letto del 黄历.
Titolo: Una giornata controvento

1. Oggi le spinte vanno in direzioni opposte: non vuol dire che vada male, solo che serve più pazienza. Rimanda a domani la decisione che stavi per prendere di corsa. || Oggi è il giorno di {animale_giorno}, che sta di fronte al tuo animale: l'almanacco cinese lo chiama scontro.
2. Oggi è facile trovarsi su fronti opposti, anche per poco. Tieni le cose semplici: fai una cosa alla volta e lascia cadere la discussione che non ti serve vincere. || Il ramo di oggi è l'opposto del tuo. Gli almanacchi cinesi lo scrivono in chiaro: oggi si scontra con {animale_tuo}.
3. Oggi ciò che era fermo si muove, anche a strattoni. Se qualcosa si rompe guarda se non era già incrinato; se qualcosa si sblocca lascialo andare senza trattenerlo. || È un giorno di scontro col tuo animale: nella tradizione cinese il ramo di oggi sta di fronte a quello del tuo anno.

### 1.4 Punizione (三刑 Xing)

Regola: tre gruppi di rami si "puniscono" (寅巳申, 丑戌未, 子卯) più quattro rami che puniscono se stessi (辰, 午, 酉, 亥). Il 三命通会 le chiama punizione dell'ingratitudine, dell'arroganza, della scortesia.
Titolo: Misura le parole

1. Oggi una parola in più pesa più del solito. Misura il tono: rileggi il messaggio prima di inviarlo e cancella la frase che hai scritto solo per avere l'ultima parola. || Il ramo di oggi e il tuo sono legati da ciò che la tradizione cinese chiama punizione: non un castigo, un attrito che nasce da un eccesso.
2. Oggi forzare i tempi porta più attrito che risultati. Se qualcuno non ti ha ancora risposto, aspetta a sollecitare. Concedi anche a te una pausa vera fra un impegno e l'altro. || Oggi {animale_giorno} e {animale_tuo} formano una delle tre punizioni, i gruppi di rami che nella tradizione cinese si puniscono a vicenda.
3. Oggi la fretta è la parte che si paga. Controlla due volte ciò che firmi o spedisci: un nome, una cifra, un allegato. Se puoi, lascia passare dieci minuti prima di premere invio. || È una giornata di attrito col tuo animale, secondo l'almanacco cinese: il ramo di oggi e quello del tuo anno stanno in uno dei gruppi che si puniscono.

### 1.5 Punizione di sé (自刑)

Regola: Drago, Cavallo, Gallo e Maiale puniscono se stessi: quando il giorno ha il tuo stesso ramo e il tuo è uno di questi quattro.
Titolo: Non farti la guerra

1. Oggi il rischio sei tu contro di te: tendi a pretendere troppo e a perdonarti poco. Non chiederti più di quanto chiederesti a una persona cara. Scrivi ciò che pretendi da te entro stasera e dimezzalo. || Oggi è il giorno del tuo stesso animale: la tradizione cinese dice che {animale_tuo} con se stesso si punisce.
2. Oggi i pensieri tendono a girare a vuoto più del solito. Se ti accorgi di rimuginare, fermati e fai una cosa con le mani: lava i piatti, riordina un cassetto, cucina qualcosa. || È il giorno del tuo animale, nella forma che l'almanacco cinese chiama punizione di sé: Drago, Cavallo, Gallo e Maiale puniscono se stessi quando il giorno ha il loro ramo.
3. Oggi è facile inciampare per conto proprio, soprattutto con troppe cose in fila. Scegli tre impegni soltanto e portali fino in fondo prima di cominciarne un quarto. || Il ramo di oggi è il tuo. Per {animale_tuo} la tradizione cinese lo legge come un giorno in cui ci si inciampa da soli.

### 1.6 Danno (六害 Hai)

Regola: sei coppie si danneggiano (子未, 丑午, 寅巳, 卯辰, 申亥, 酉戌); nel 三命通会 il danno nasce perché ognuno dei due rompe l'accordo dell'altro.
Titolo: Piccoli intoppi

1. Oggi la giornata porta fastidi più che urti, soprattutto dove conti sugli altri. Prima di fare affidamento su una promessa, verificala: chiedi conferma dell'orario, della consegna, della cifra. || Il giorno è di {animale_giorno}, che disturba l'accordo del tuo animale: la tradizione cinese lo chiama danno.
2. Oggi sono possibili piccoli intoppi, un ritardo, un messaggio frainteso: niente di grave, se non lo ingrandisci. Parti dieci minuti prima. Se una risposta ti suona male, chiedi che cosa voleva dire prima di reagire. || Il ramo di oggi e quello del tuo anno sono una delle sei coppie del danno: nella tradizione cinese ognuno dei due rompe l'accordo dell'altro.
3. Oggi ciò che funziona va lasciato in pace: toccarlo rischia di guastarlo. Rimanda la modifica o il cambio di programma che avevi in mente e lascia tutto com'è fino a domani. || È un giorno di danno per {animale_tuo}, dice l'almanacco cinese: il ramo di oggi e il suo stanno in una delle sei coppie che si danneggiano.

### 1.7 Armonia che punisce (巳申, Serpente e Scimmia)

Regola: Serpente e Scimmia sono insieme una delle sei armonie e una delle punizioni; i testi la chiamano 刑合, accordo con attrito.
Titolo: Intesa con qualche spina

1. Oggi con gli altri ci si intende e ci si punzecchia nello stesso momento. Fidati dell'intesa, ma metti per iscritto i patti: due righe di riepilogo dopo la telefonata bastano. || Oggi {animale_giorno} e {animale_tuo} si accordano e si puniscono insieme: la tradizione cinese conosce questa coppia doppia e la chiama accordo con attrito.
2. Oggi chi ti somiglia è un buon alleato, anche se non ti capisce al volo come credi. Lavora con quella persona e spiega per intero ciò che ti aspetti, invece di lasciarlo sottinteso. || È una coppia doppia: Serpente e Scimmia sono insieme una delle sei armonie e una delle punizioni, armonia e attrito nello stesso legame.
3. Oggi la vicinanza fa bene, la confidenza cieca meno. Stai volentieri con chi ti cerca. Tieni però per te la cosa delicata che non hai ancora deciso di raccontare. || Il ramo di oggi e il tuo si cercano e si urtano: nei testi cinesi questa coppia è un accordo che porta con sé un attrito.

### 1.8 Stesso animale

Regola: il giorno ha il ramo del tuo anno (e il tuo non è fra i quattro che puniscono se stessi). Nella tradizione i rami uguali si rafforzano (比 "stare fianco a fianco"); non è uno dei rapporti classificati. Fonte (ordine EV, verifica dell'Architetto, C-G-070): i rapporti classificati fra i rami (armonia, tripla armonia, scontro, punizione, danno) sono quelli del Sanming Tonghui di Wan Minying (1578).
Titolo: A modo tuo

1. Oggi non è un giorno di favore né di sfida: ciò che fai porta più del solito la tua impronta. Fai a modo tuo una cosa che di solito fai come viene: un lavoro, un messaggio, un piatto. || Oggi è il giorno di {animale_giorno}, il tuo stesso animale: ritorna ogni dodici giorni.
2. Oggi rendi di più quando fai le cose nel tuo modo che quando ti adatti a quello degli altri. Prenditi il compito che solo tu sai fare così e lascia a qualcun altro quello che chiunque può sbrigare. || Il ramo di oggi è il tuo: torna ogni dodici giorni; per il tuo animale non è uno dei rapporti che la tradizione classifica.
3. Oggi la giornata pesa quanto decidi tu, né di più né di meno. Scegli una cosa a cui tieni e mettila per prima, davanti ai messaggi e alle commissioni. || È il giorno del tuo animale: la tradizione cinese non gli dà un peso particolare, perché non è uno dei rapporti classificati.

### 1.9 Nessun rapporto

Regola: fra il ramo del giorno e il tuo non c'è accordo, terna, scontro, punizione o danno. È il caso più frequente (66 celle su 144): servono più varianti.
Titolo: Campo libero

1. Oggi la giornata non ti spinge e non ti frena: va come la porti tu. Per sapere che cosa conviene fare, leggi le righe che seguono e scegli da lì una cosa sola da fare bene. || Oggi guida {animale_giorno}, che col tuo animale non ha legami nella tradizione cinese: né accordo né urto. Il giorno si legge meglio dal suo guardiano.
2. Oggi è una giornata neutra: quello che ne esce dipende da ciò che ci metti. Decidi adesso una cosa che vuoi vedere fatta entro sera e dedicale la prima ora libera. || Fra {animale_giorno} e {animale_tuo} oggi non c'è un rapporto classico: né accordo, né terna, né scontro, né punizione, né danno.
3. Oggi è una buona occasione per le cose ordinarie fatte con cura, senza colpi di scena. Prendi una faccenda di tutti i giorni e falla meglio del solito: la spesa, una risposta da scrivere, la scrivania da riordinare. || Fra il ramo del giorno e quello del tuo anno non c'è nessun accordo e nessuno scontro: è il caso più frequente nelle tabelle della tradizione cinese.
4. Oggi niente ti viene incontro e niente ti sbarra la strada: la giornata è libera. Regolati sul consiglio pratico che leggi subito dopo e tieni l'agenda leggera, con un'ora vuota da usare come viene. || Il ramo di oggi e il tuo non si cercano e non si respingono: dal lato degli animali la giornata è libera e a parlare resta il guardiano del giorno.
5. Oggi da fuori non arriva nessuna spinta: il ritmo lo decidi tu. Scegli a che ora cominci e a che ora stacchi, scrivilo e rispettalo come un appuntamento preso con qualcuno. || Oggi {animale_giorno} passa accanto al tuo animale senza toccarlo, dice la tradizione cinese: fra i due rami non c'è nessun legame.

---

## 2. Scheda Generale: il guardiano del giorno

Regola: il guardiano è la distanza fra il ramo del giorno e il ramo del mese solare (建 il giorno che ha il ramo del mese, poi gli altri in ordine; il giorno del jie ripete). Fonte: 淮南子·天文训 per la successione; 钦定协纪辨方书 (1739) per la regola degli almanacchi; adatto e sconsigliato dalla sintesi degli almanacchi in https://www.sohu.com/a/727671351_121819358 riscontrata su huangli999.com e huangli888.com (vedi `specifiche.md`, paragrafo 2). Il consiglio viene dal solo guardiano, non dall'almanacco intero: la nota del metodo lo dice.

Formato proposto: una frase, poi due righe brevi "Adatto a" e "Meglio evitare" prese dalla tabella delle specifiche e dette in italiano quotidiano.

### 2.1 Stabilire (建 Jian)

Adatto a: cominciare un percorso, partire, prendere un incarico. Meglio evitare: lavori di scavo, grandi spostamenti di cose.

1. È il momento di mettere in piedi qualcosa di nuovo. Comincia il corso, l'abitudine o il progetto che rimandi: basta il primo passo, un'iscrizione o la prima mezz'ora. || Il guardiano di oggi è Stabilire, il primo dei dodici: nel calendario cinese è il giorno in cui qualcosa si mette in piedi.
2. Vanno bene gli inizi e le partenze, meno il rivoltare ciò che è già al suo posto. Prenota il viaggio o scegli la data in cui parti. Se avevi in mente uno scavo in giardino, rimandalo. || Oggi veglia Stabilire: la tradizione cinese lo vuole per gli inizi e per mettersi in viaggio, lo sconsiglia per i lavori di scavo.
3. È un buon momento per prendere un impegno nuovo e dirlo a voce alta. Accetta l'incarico o annuncia a qualcuno ciò che hai deciso di fare. Lascia per un altro giorno i traslochi di cose pesanti. || Stabilire guida il giorno: fra i dodici guardiani è quello adatto a prendere un incarico, non ai grandi spostamenti di cose.

### 2.2 Togliere (除 Chu)

Adatto a: pulire, curarsi, liberarsi del vecchio, piccoli affari. Meglio evitare: partenze, traslochi, candidature a un incarico.

1. La giornata è adatta a portare via ciò che ingombra. Svuota un armadio, salda un piccolo debito o prenota il controllo che rimandi da mesi: una sola di queste cose basta. || Oggi il guardiano è Togliere: la tradizione cinese lo dedica a ciò che si porta via, dal pulire al curarsi al liberarsi del vecchio.
2. Conviene fare spazio prima di aggiungere: una cosa tolta vale più di tre cose nuove. Butta dieci oggetti che non usi, disdici un abbonamento inutile o libera la scrivania prima di prendere altro. || Togliere veglia sul giorno: è il guardiano che il calendario cinese lega al pulire e al liberarsi del vecchio.
3. Vanno bene la cura di te e i conti in sospeso da sistemare, meno le partenze. Prenditi un'ora per un bagno lungo o per rispondere a chi aspetta da te una risposta. Se puoi, sposta il viaggio a un altro giorno. || È una giornata di Togliere, dice l'almanacco cinese: buona per curarsi e per liberarsi del vecchio, sconsigliata per partenze e traslochi.

### 2.3 Pieno (满 Man)

Adatto a: celebrare, incontri di famiglia, aprire un'attività, cercare un guadagno. Meglio evitare: traslochi, lavori di terra, prendere un nuovo incarico.

1. È un giorno per festeggiare ciò che c'è già, più che per inseguire altro. Organizza una cena con i tuoi o di' un grazie per bene, a voce, alla persona che se lo merita da tempo. || Oggi veglia Pieno, il guardiano del raccolto: il calendario cinese lo lega alle celebrazioni e agli incontri di famiglia.
2. La giornata parla di abbondanza, non di avidità: va bene incassare e fare il punto, non caricarti di impegni nuovi. Chiedi un pagamento che ti spetta e rimanda la risposta a chi ti propone un incarico. || Il guardiano Pieno dice abbondanza: è adatto a cercare un guadagno, non a prendere un nuovo incarico.
3. Meglio restare dove sei e goderti ciò che hai raccolto. Brinda a un risultato, anche piccolo, con chi ti ha dato una mano. Scatoloni, traslochi e lavori in giardino possono aspettare. || È un giorno di Pieno: la tradizione cinese lo vuole per le celebrazioni e i guadagni, non per i traslochi né per i lavori di terra.

### 2.4 Livellare (平 Ping)

Adatto a: riparare, sistemare, abbellire. Meglio evitare: aprire strade nuove (la tradizione dice "scavare canali").

1. La giornata è piana, né favorevole né contraria: perfetta per aggiustare ciò che è storto. Ripara la cosa rotta che hai in casa da settimane: la lampadina, la cerniera, il rubinetto che gocciola. || Il guardiano di oggi è Livellare: nel calendario cinese è il giorno adatto a riparare, sistemare e abbellire.
2. Non è una giornata da svolte: conviene rimettere in pari ciò che è rimasto indietro. Riordina una stanza, aggiorna l'agenda o ricambia il favore a chi ultimamente ha dato più di te. || Oggi veglia Livellare: la tradizione cinese lo vuole per sistemare e lo sconsiglia per ciò che chiama "scavare canali", cioè aprire strade nuove.
3. Le cose ordinarie vanno bene, le deviazioni meno. Finisci di sistemare quello che c'è prima di avviare altro: completa la pratica a metà, rispondi ai messaggi arretrati, poi pensa al resto. || Livellare guida il giorno: fra i dodici guardiani è quello che vuole sistemare ciò che c'è, non aprire strade nuove.

### 2.5 Fissare (定 Ding)

Adatto a: pianificare, decisioni che devono durare, cerimonie. Meglio evitare: liti, cause, partenze.

1. Riescono meglio le cose che devono durare. Metti per iscritto un piano in cinque righe e scegli una data precisa per il primo passo: scrivila in agenda. || Oggi veglia Fissare: la tradizione cinese lo lega a ciò che deve restare, dai piani alle decisioni che devono durare.
2. Serve stabilità: si decide bene a mente fredda, si discute male. Prendi con calma la decisione che aspetta da giorni. Se una lite si affaccia, di' che ne riparlate domani. || Il guardiano Fissare chiede stabilità: l'almanacco cinese lo dà adatto alle decisioni che devono durare e sconsigliato per liti e cause.
3. Conviene restare, costruire e programmare più che muoversi. Prepara il programma della settimana o del mese. Il viaggio e il confronto duro spostali a un giorno più adatto. || È un giorno di Fissare: nel calendario cinese va bene per pianificare, mentre partenze e liti hanno giorni migliori.

### 2.6 Tenere (执 Zhi)

Adatto a: tenere fermo ciò che hai, costruire, piantare, portare a termine. Meglio evitare: aprire un'attività, commerciare, traslocare, partire.

1. È una giornata per trattenere e concludere, non per lasciare andare. Riprendi una cosa iniziata e portala a termine prima di sera: il lavoro a metà, il libro all'ultimo capitolo, la pratica in sospeso. || Il guardiano di oggi è Tenere: la tradizione cinese lo vuole per trattenere, non per lasciare andare.
2. Meglio custodire ciò che hai costruito che cercare altrove. Fai manutenzione a una cosa tua: una copia delle carte importanti, un controllo alla bici, una telefonata a chi ti è vicino da anni. Compravendite e partenze, un altro giorno. || Oggi veglia Tenere: per compravendite e partenze l'almanacco cinese consiglia altri giorni.
3. Presa salda e pochi movimenti: è così che la giornata rende. Pianta qualcosa, anche solo un vaso sul balcone. Se ti chiedono una firma in fretta, prenditi un giorno per rileggere. || Tenere guida il giorno: nel calendario cinese è adatto a costruire, piantare e portare a termine, non a commerciare.

### 2.7 Rompere (破 Po)

Adatto a: demolire il vecchio, cercare cure. Meglio evitare: ogni cosa importante di buon augurio (gli almanacchi scrivono "诸事不宜", nessuna impresa conviene).

1. Non è il momento di cominciare cose importanti: la giornata serve piuttosto a farla finita con ciò che non regge più. Smonta il mobile rotto, svuota la cantina, butta ciò che tieni solo per abitudine. || Oggi il guardiano è Rompere, il più severo dei dodici: gli almanacchi cinesi sconsigliano di cominciare cose importanti.
2. Niente firme e niente inizi: la giornata è fatta per tagliare. Di' un no chiaro a una richiesta che ti pesa e disdici un impegno che hai preso controvoglia. || Rompere veglia sul giorno: gli almanacchi cinesi ne scrivono "nessuna impresa conviene" e lo tengono buono per demolire il vecchio.
3. I programmi vanno tenuti leggeri: le cose nuove possono aspettare. Sposta a domani l'avvio di ciò che conta. Usa il tempo che si libera per te: una camminata, una dormita, un'ora senza telefono. || È un giorno di Rompere: la tradizione cinese lo vuole solo per demolire il vecchio e per cercare cure.

### 2.8 Pericolo (危 Wei)

Adatto a: cerimonie, raccoglimento. Meglio evitare: salire in alto, andare per mare, traslocare.

1. Serve prudenza, senza rischi fisici inutili. Guida con calma e parti qualche minuto prima. Se dovevi salire su una scala o su un tetto, fallo un altro giorno o fatti aiutare. || Il guardiano di oggi è Pericolo: la tradizione cinese chiede prudenza con l'altezza e con l'acqua, sconsiglia di salire in alto e di andare per mare.
2. Nessun presagio, solo un invito alla cautela: la giornata è buona per raccoglierti, meno per spostarti. Resta in zona e ritagliati mezz'ora di silenzio, a casa o in un posto tranquillo. || Oggi veglia Pericolo: il calendario cinese lo dà adatto alle cerimonie e al raccoglimento, non ai traslochi.
3. Tutto va meglio se fai con calma ciò che di solito fai in fretta. Scendi le scale senza telefono in mano, attraversa guardando due volte. In cantiere o su una scala a pioli, un occhio in più. || Pericolo guida il giorno: fra i dodici guardiani è quello che vuole cautela, soprattutto dove si sale in alto.

### 2.9 Compiere (成 Cheng)

Adatto a: aprire, firmare accordi, cominciare un'unione, partire, traslocare, curarsi. Meglio evitare: liti e cause.

1. Poche giornate sono così favorevoli a ciò che deve arrivare in fondo. Consegna il lavoro pronto, conferma l'appuntamento, firma l'accordo che avete già discusso. || Oggi veglia Compiere, uno dei guardiani più favorevoli: la tradizione cinese lo vuole per ciò che deve arrivare in fondo.
2. Le cose rimaste a metà hanno una buona occasione per concludersi. Se hai un sì da dare o da chiedere, fallo entro sera con una telefonata. Lascia fuori le discussioni. || Il guardiano Compiere porta a termine: nel calendario cinese è adatto agli accordi, sconsigliato per liti e cause.
3. Vanno bene gli accordi, le partenze e gli inizi di coppia. Scegli il giorno della partenza, proponi l'uscita a chi ti piace o stringi la mano su un'intesa. Evita solo di trascinare qualcuno in una lite. || È un giorno di Compiere: accordi, partenze e inizi di coppia vanno bene secondo l'almanacco cinese, liti e cause no.

### 2.10 Raccogliere (收 Shou)

Adatto a: incassare, raccogliere i frutti, studiare. Meglio evitare: partire, i riti funebri.

1. Si tirano le somme più che avviare cose nuove. Incassa ciò che ti devono, archivia le carte sparse, fai il bilancio del mese in una pagina. || Il guardiano di oggi è Raccogliere: la tradizione cinese lo lega al raccolto e ai frutti da incassare.
2. Non è il momento di seminare ma di prendere ciò che è maturo. Chiedi il compenso che ti spetta, con un messaggio cortese e la cifra scritta. Poi rimetti in ordine ciò che hai guadagnato. || Oggi veglia Raccogliere: fra i dodici guardiani è quello adatto a incassare e a raccogliere i frutti.
3. Rendono bene lo studio e il mettere da parte, meno le partenze. Dedica un'ora a imparare una cosa che ti serve e metti via qualcosa, anche una piccola somma. Il viaggio può slittare. || Raccogliere guida il giorno: il calendario cinese lo dà buono per studiare e per mettere da parte, mentre le partenze le rimanda.

### 2.11 Aprire (开 Kai)

Adatto a: aprire un'attività, inizi di coppia, entrare in casa nuova, chiedere. Meglio evitare: lavori di terra, i riti funebri.

1. Le porte si aprono più volentieri a chi bussa. Presentati a una persona che vuoi conoscere o fai la richiesta che tieni in sospeso: un aumento, un favore, un appuntamento. || Oggi veglia Aprire, il guardiano delle porte che si aprono: la tradizione cinese lo vuole per inaugurare, presentarsi, chiedere.
2. Rende di più farti vedere che aspettare che ti cerchino. Manda la candidatura, fai la proposta, rispondi a chi aspetta da te un cenno e invitalo a entrare. || Il guardiano Aprire invita a farsi vedere: nel calendario cinese è il giorno adatto a chiedere e a cominciare.
3. Gli inizi vanno bene quasi tutti. Avvia la cosa nuova a cui pensi: il primo giorno di un'attività, il primo invito a una persona, la prima sera nella casa nuova. Lascia stare soltanto gli scavi e i lavori in giardino. || È un giorno di Aprire: buono per gli inizi, secondo l'almanacco cinese, che lascia fuori solo i lavori di terra e i riti funebri.

### 2.12 Chiudere (闭 Bi)

Adatto a: riposo, mettere al sicuro, chiudere falle. Meglio evitare: aprire un'attività, sposarsi, partire, cercare guadagni.

1. È una giornata buona per rientrare in te e mettere al sicuro ciò che conta. Stasera spegni il telefono un'ora prima del solito e vai a letto presto: il riposo è la cosa più utile che puoi fare. || Il guardiano di oggi è Chiudere: la tradizione cinese lo lega al riposo e a ciò che si mette al sicuro.
2. Niente inaugurazioni e niente grandi richieste: conviene tappare le falle. Salva una copia di ogni file importante, ripara la serratura che non tiene, controlla che porte e finestre siano a posto. || Oggi veglia Chiudere: l'almanacco cinese lo sconsiglia per le inaugurazioni e per cercare guadagni, lo vuole per mettere al sicuro.
3. È il caso di tenerti stretto ciò che hai, senza avviare altro né metterti in viaggio. Metti in ordine i documenti e le chiavi, riponi ciò che è in giro. Tutto il resto lo riprendi domani. || Chiudere guida il giorno: l'almanacco cinese lo sconsiglia per aprire un'attività e per partire.

---

## 3. I Dieci Dei nelle schede Fortuna, Lavoro, Amore

Regola: il tronco di oggi confrontato col tronco del tuo giorno di nascita dà uno dei Dieci Dei (十神). Fonte: 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲"), vedi `specifiche.md`, paragrafo 4.

Presentazione del dio nella scheda, una volta sola, per esempio: "Oggi il giorno ti porta la Ricchezza diretta (正财): nel BaZi è ciò che il tuo elemento governa con le sue forze."

Spiegazioni brevi da mostrare col punto interrogativo:

| dio | nome italiano | spiegazione di una riga |
|---|---|---|
| 比肩 | il Compagno | il giorno ha il tuo stesso elemento con la tua stessa polarità |
| 劫财 | il Rivale | il tuo stesso elemento, con polarità opposta: contende ciò che hai |
| 食神 | il Nutrimento | il tuo elemento lo genera, stessa polarità: ciò che produci con calma |
| 伤官 | l'Ufficiale Ferito | il tuo elemento lo genera, polarità opposta: espressione che rompe le regole |
| 偏财 | la Ricchezza indiretta | il tuo elemento lo governa, stessa polarità: guadagni che arrivano di lato |
| 正财 | la Ricchezza diretta | il tuo elemento lo governa, polarità opposta: il guadagno regolare |
| 七杀 | le Sette Uccisioni | governa il tuo elemento, stessa polarità: pressione, sfida |
| 正官 | l'Ufficiale diretto | governa il tuo elemento, polarità opposta: regola, responsabilità, riconoscimento |
| 偏印 | il Sigillo indiretto | genera il tuo elemento, stessa polarità: sostegno insolito, intuizione |
| 正印 | il Sigillo diretto | genera il tuo elemento, polarità opposta: protezione, studio, cura |

### 3.1 Fortuna (guarda alla Ricchezza)

Regola generale: la Ricchezza è ciò che il tuo elemento controlla. Il Nutrimento e l'Ufficiale Ferito la generano (食伤生财), il Compagno e il Rivale la contendono (比劫夺财), l'Ufficiale e le Sette Uccisioni la consumano (财生官), i Sigilli non la toccano.

**比肩, il Compagno**
Regola: stesso elemento, contende la Ricchezza (比劫夺财), in forma leggera.
Titolo: Spese da dividere
1. Oggi il denaro si muove meglio nelle spese fatte insieme che nei guadagni personali. Se c'è un conto da dividere, una cena o una bolletta, dividilo subito e alla pari. || Il dio di oggi nel BaZi è il Compagno: il giorno ha il tuo stesso elemento con la tua stessa polarità e divide con te ciò che c'è.
2. Oggi quello che entra non è solo tuo: entra per più persone. Prima di incassare o di spendere chiarisci a voce chi mette quanto e chi prende quanto, così nessuno resta col dubbio. || Il Compagno è di turno: nel BaZi chi ha il tuo stesso elemento contende la Ricchezza in forma leggera. Ciò che c'è si spartisce fra pari.
3. Oggi sul denaro non ci sono colpi di fortuna, c'è qualche spesa in compagnia. Stasera segna quello che hai speso, voce per voce, per sapere a che punto sei. || È la giornata del Compagno, il dio che ha il tuo stesso elemento: nel BaZi contende la Ricchezza, ma senza strappi.

**劫财, il Rivale**
Regola: stesso elemento, polarità opposta: la tradizione lo chiama letteralmente "rapina della ricchezza".
Titolo: Il portafoglio chiuso
1. Oggi il denaro tende a scivolare via più facilmente del solito. Tieni fermo il portafoglio davanti a prestiti, acquisti d'impulso e offerte troppo belle. || Il dio di oggi nel BaZi è il Rivale, che la tradizione chiama "chi prende la ricchezza".
2. Oggi non è giornata da spese importanti: i soldi escono senza che tu te ne accorga. Rimanda a un altro giorno la spesa grande che hai in mente, anche se l'occasione sembra buona. || Il Rivale è di turno: ha il tuo stesso elemento con polarità opposta. Non annuncia un furto, dice che oggi il denaro tende a uscire.
3. Oggi qualcuno può chiederti più soldi o più favori di quanto ti conviene dare. Rispondi con un no gentile; se proprio vuoi aiutare, fissa prima una cifra che non ti pesa. || È la giornata del Rivale, che nel BaZi contende ciò che hai: il suo nome cinese vuol dire alla lettera "rapina della ricchezza".

**食神, il Nutrimento**
Regola: il tuo elemento lo genera; nel BaZi il Nutrimento a sua volta genera la Ricchezza (食伤生财): il guadagno viene da ciò che sai fare.
Titolo: Il tuo saper fare
1. Oggi il denaro passa da quello che sai fare bene, non dalla sorte. Scegli il lavoro che ti riesce meglio e curalo fino in fondo: è quello che oggi ha più valore. || Il dio di oggi nel BaZi è il Nutrimento: il tuo elemento lo genera e lui a sua volta genera la Ricchezza. È la vena da cui nasce il guadagno.
2. Oggi è un buon giorno per far pagare il giusto ciò che crei. Proponi il tuo lavoro a una persona che può volerlo e di' il prezzo con calma, senza abbassarlo prima che te lo chiedano. || Il Nutrimento è di turno: nel BaZi è ciò che produci con calma. La regola dice che genera la Ricchezza: il guadagno viene da ciò che sai fare.
3. Oggi il guadagno è lento ma pulito. Avvia una cosa piccola che rende nel tempo: un preventivo mandato, un contatto ripreso, una tua capacità messa in vetrina. || È la giornata del Nutrimento: il tuo elemento lo genera con la stessa polarità. Nel BaZi alimenta la Ricchezza senza fretta.

**伤官, l'Ufficiale Ferito**
Regola: il tuo elemento lo genera con polarità opposta; genera la Ricchezza (食伤生财) ma con impeto.
Titolo: Un'idea che rende
1. Oggi un'idea originale può trasformarsi in guadagno, a patto di rispettare gli accordi già presi. Scrivila in tre righe e falla vedere a chi potrebbe pagarla. || Il dio di oggi nel BaZi è l'Ufficiale Ferito: il tuo elemento lo genera con polarità opposta. È talento che corre e genera la Ricchezza, ma con impeto.
2. Oggi i soldi passano da un'iniziativa tua, fuori dagli schemi. Prima di muoverti rileggi il contratto o il patto che hai in corso: le clausole oggi non si saltano. || L'Ufficiale Ferito è di turno: nel BaZi genera la Ricchezza come il Nutrimento, però è l'espressione che rompe le regole.
3. Oggi sul denaro sei brillante e impaziente insieme. Metti la fantasia in un progetto e lascia fermo il conto: nessuna spesa decisa in meno di un'ora. || È la giornata dell'Ufficiale Ferito: nel BaZi la sua forza è creare ciò che porta guadagno, il suo rischio è l'impeto con cui lo fa.

**偏财, la Ricchezza indiretta**
Regola: il tuo elemento la governa, stessa polarità: guadagni che arrivano di lato, occasioni, denaro che circola.
Titolo: Il denaro che gira
1. Oggi una proposta di guadagno può arrivare da una strada insolita. Ascoltala fino in fondo, fatti dire cifre e tempi, poi prenditi una notte prima di rispondere. || Il dio di oggi nel BaZi è la Ricchezza indiretta: il tuo elemento la governa con la stessa polarità. È il denaro delle occasioni, che arriva di lato.
2. Oggi il denaro si muove: entra ed esce con facilità. È un buon giorno per trattare un prezzo o un compenso, non per affidarti al caso: niente scommesse. || La Ricchezza indiretta è di turno: nel BaZi è il denaro che circola, quello che non viene dal guadagno regolare.
3. Oggi può capitare un'entrata fuori dal solito, ma anche una spesa fuori dal solito. Sta a te quale lasciar passare: fissa adesso un tetto per le spese non previste di oggi. || È la giornata della Ricchezza indiretta: il tuo elemento la governa. Nel BaZi sono occasioni e denaro che circola, in entrata come in uscita.

**正财, la Ricchezza diretta**
Regola: il tuo elemento la governa con polarità opposta: il guadagno regolare, frutto del lavoro.
Titolo: Conti in ordine
1. Oggi il denaro premia il metodo più dell'inventiva. Prendi mezz'ora per mettere in fila ricevute, scadenze e pagamenti del mese: sapere a che punto sei vale già qualcosa. || Il dio di oggi nel BaZi è la Ricchezza diretta: il tuo elemento la governa con polarità opposta. È il denaro guadagnato con metodo.
2. Oggi non ci sono colpi di scena: le entrate vengono da dove devono venire. Approfittane per mettere da parte una cifra, anche piccola, prima di spendere il resto. || La Ricchezza diretta è di turno: nel BaZi è il guadagno regolare, frutto del lavoro, quello che non sorprende.
3. Oggi si può raccogliere ciò che hai seminato col tuo lavoro. Manda la fattura rimasta nel cassetto o ricorda a chi ti deve del denaro la data che avevate concordato. || È la giornata della Ricchezza diretta: nel BaZi è ciò che il tuo elemento governa con le sue forze, il frutto che gli spetta.

**七杀, le Sette Uccisioni**
Regola: governa il tuo elemento; la Ricchezza lo nutre (财生官): il denaro va verso obblighi e pressioni.
Titolo: Prima le scadenze
1. Oggi il denaro va verso spese che non hai scelto: scadenze, obblighi, conti da saldare. Paga quelle per prime, poi concediti una pausa senza pensarci più. || Il dio di oggi nel BaZi sono le Sette Uccisioni, la pressione: governano il tuo elemento. La regola dice che la Ricchezza le nutre, cioè va verso gli obblighi.
2. Oggi i soldi servono a difenderti, non a crescere. Lascia stare ogni rischio e controlla di avere coperto gli impegni di questa settimana: affitto, rate, bollette. || Le Sette Uccisioni sono di turno: nel BaZi governano il tuo elemento con la stessa polarità. La Ricchezza si consuma per farvi fronte.
3. Oggi qualcuno può pretendere soldi o metterti fretta su un pagamento. Rispondi con i numeri alla mano: date, importi, ricevute. Se serve, chiedi un giorno per verificare. || È la giornata delle Sette Uccisioni: nel BaZi sono pressione e sfida. Sul denaro prendono la forma di richieste che vengono da fuori.

**正官, l'Ufficiale diretto**
Regola: governa il tuo elemento con polarità opposta; la Ricchezza lo nutre (财生官): il denaro va verso posizione e doveri.
Titolo: Mettersi in regola
1. Oggi il denaro va dove c'è una regola da rispettare. Paga una tassa o una bolletta in sospeso, oppure affronta una spesa che serve al tuo buon nome. || Il dio di oggi nel BaZi è l'Ufficiale diretto: governa il tuo elemento con polarità opposta. La Ricchezza lo nutre, quindi il denaro va verso posizione e doveri.
2. Oggi spendere per ciò che ti rende affidabile è un buon uso del denaro. Salda un piccolo debito o rinnova ciò che ti serve per lavorare in regola; gli sfizi possono aspettare. || L'Ufficiale diretto è di turno: nel BaZi è regola, responsabilità, riconoscimento. La Ricchezza lo alimenta.
3. Oggi sul denaro viene prima l'ordine. Riprendi una cosa rimasta indietro, un modulo da consegnare o una ricevuta da archiviare: mettila a posto entro sera. || È la giornata dell'Ufficiale diretto: nella lettura dei Dieci Dei consuma la Ricchezza, che si spende per i doveri prima che per i desideri.

**偏印, il Sigillo indiretto**
Regola: genera il tuo elemento, stessa polarità; non tocca la Ricchezza: il sostegno arriva in forma insolita.
Titolo: Vale ciò che impari
1. Oggi sul fronte del denaro la cosa preziosa è un'informazione o un'intuizione, non un'entrata. Tieni le orecchie aperte e verifica la notizia che ti colpisce prima di contarci. || Il dio di oggi nel BaZi è il Sigillo indiretto: genera il tuo elemento con la stessa polarità e non tocca la Ricchezza. Il suo sostegno ha una forma insolita.
2. Oggi c'è poco movimento sul conto e molto nella testa. Quando ti viene un'idea su come guadagnare o risparmiare scrivila subito su un foglio, per valutarla con calma un altro giorno. || Il Sigillo indiretto è di turno: nel BaZi è sostegno insolito e intuizione. Con la Ricchezza non ha legami, né per darla né per toglierla.
3. Oggi il denaro non è il tema della giornata. Dedica un'ora a imparare una cosa che ti serve nel lavoro o nella gestione di casa: una lezione, un capitolo, una guida pratica. || È la giornata del Sigillo indiretto: nella lettura dei Dieci Dei i Sigilli generano il tuo elemento e lasciano ferma la Ricchezza.

**正印, il Sigillo diretto**
Regola: genera il tuo elemento con polarità opposta; la protezione, non il guadagno.
Titolo: Soldi al sicuro
1. Oggi il denaro è protetto più che in crescita. È un buon giorno per chiedere un consiglio a chi ne sa più di te su un dubbio di soldi che ti porti dietro da tempo. || Il dio di oggi nel BaZi è il Sigillo diretto: genera il tuo elemento con polarità opposta. Protegge più che arricchire.
2. Oggi la buona sorte ha la forma di un sostegno, da una persona o da un'istituzione. Se qualcuno ti offre un aiuto accettalo con un grazie, senza sentirti in debito. || Il Sigillo diretto è di turno: nel BaZi è protezione, studio, cura. Porta sostegno, non guadagno.
3. Oggi sul fronte del denaro la giornata è tranquilla. Metti al sicuro ciò che hai: controlla che risparmi e documenti importanti siano al loro posto, poi lascia stare ogni azzardo. || È la giornata del Sigillo diretto: nella lettura dei Dieci Dei i Sigilli non toccano la Ricchezza, la lasciano dov'è.

### 3.2 Lavoro (guarda all'Ufficiale)

Regola generale: l'Ufficiale (正官, 七杀) è ciò che controlla il tuo elemento: la regola, l'autorità, la carriera. La Ricchezza lo nutre (财生官), i Sigilli lo trasformano in sostegno (官印相生), l'Ufficiale Ferito lo attacca (伤官见官), il Nutrimento doma le Sette Uccisioni (食神制杀), il Compagno e il Rivale portano la concorrenza fra pari.

**比肩, il Compagno**
Titolo: Lavoro di squadra
1. Oggi al lavoro si va meglio in squadra che in solitaria; farsi notare da chi decide è più difficile. Prendi un compito da fare a quattro mani e portalo avanti con un collega. || Il dio di oggi nel BaZi è il Compagno: il giorno ha il tuo stesso elemento con la tua stessa polarità. Sul lavoro sono i pari grado, le persone come te.
2. Oggi il lavoro scorre in orizzontale, fra colleghi più che verso i capi. Chiedi una mano a chi ha già risolto il tuo problema; in cambio offri la tua su una cosa che sai fare. || Il Compagno è di turno: nel BaZi chi ha il tuo stesso elemento sta al tuo fianco, non sopra di te. Per il lavoro vuol dire collaborazione orizzontale.
3. Oggi sul lavoro conta la rete delle persone al tuo livello. Coltivala senza metterti a confronto: un caffè con una collega, un grazie a chi ti ha dato una mano la settimana scorsa. || È la giornata del Compagno: nella scheda del lavoro il BaZi guarda all'Ufficiale, l'autorità, mentre il Compagno porta il confronto fra pari.

**劫财, il Rivale**
Titolo: Lascia parlare i fatti
1. Oggi al lavoro c'è concorrenza: qualcuno punta al tuo stesso posto o al tuo stesso risultato. Resta sui fatti e lascia traccia scritta di ciò che fai, con un messaggio di riepilogo. || Il dio di oggi nel BaZi è il Rivale: ha il tuo stesso elemento con polarità opposta e contende ciò che hai. Sul lavoro è la concorrenza fra pari.
2. Oggi sul lavoro non tutti giocano a carte scoperte. L'idea a cui tieni raccontala solo a chi conosci bene; con gli altri aspetta che sia pronta. || Il Rivale è di turno: nel BaZi ha il tuo stesso elemento, quindi ti somiglia, ma contende ciò che hai.
3. Oggi sul lavoro la competizione si sente. Rispondi col lavoro finito, non con le parole: consegna una cosa completa prima di sera e lascia cadere le frecciate. || È la giornata del Rivale: nella lettura dei Dieci Dei lui e il Compagno portano sul lavoro la gara fra chi sta allo stesso livello.

**食神, il Nutrimento**
Regola in più: il Nutrimento doma le Sette Uccisioni (食神制杀): il talento tiene a bada la pressione.
Titolo: Il lavoro ben fatto
1. Oggi il lavoro ti viene con naturalezza, specie dove hai mano. Dedica le ore migliori al compito che ti riesce meglio e consegnalo senza presentazioni: si spiega da solo. || Il dio di oggi nel BaZi è il Nutrimento: il tuo elemento lo genera con la stessa polarità. È ciò che produci con calma, il talento che lavora senza sforzo.
2. Oggi al lavoro la qualità conta più della velocità. Se qualcuno ti mette fretta, rispondi con una cosa fatta bene e con una data di consegna realistica: la pressione la regge la competenza. || Il Nutrimento è di turno: la regola del BaZi dice che doma le Sette Uccisioni, cioè che il talento tiene a bada la pressione.
3. Oggi è un buon giorno per creare, scrivere, insegnare: i risultati vengono senza forzare. Spiega a un collega una cosa che sai fare, oppure butta giù la prima stesura di un testo. || È la giornata del Nutrimento: nella lettura dei Dieci Dei è la vena che produce, quella che il tuo elemento genera da sé.

**伤官, l'Ufficiale Ferito**
Regola in più: 伤官见官, l'Ufficiale Ferito urta l'Ufficiale: attrito con i superiori e con le regole.
Titolo: Pesa le parole
1. Oggi al lavoro hai idee brillanti e pazienza corta. Con i capi scegli le parole prima di parlare: una critica giusta detta male oggi diventa un problema tuo. || Il dio di oggi nel BaZi è l'Ufficiale Ferito: il tuo elemento lo genera con polarità opposta. La regola dice che urta l'Ufficiale, cioè i superiori e le regole.
2. Oggi la voglia di cambiare le regole del lavoro è forte. Metti la proposta per iscritto, con un esempio e con i costi, invece di lanciarla a caldo in riunione. || L'Ufficiale Ferito è di turno: nel BaZi è l'espressione che rompe le regole. Quando incontra l'Ufficiale, che è l'autorità, nasce attrito.
3. Oggi sul lavoro la creatività paga, la sfida a chi comanda no. Usa l'inventiva per risolvere un problema concreto del tuo gruppo e tieni per te la battuta sul capo. || È la giornata dell'Ufficiale Ferito: nella lettura dei Dieci Dei è il dio che attacca l'Ufficiale, cioè la regola, l'autorità, la carriera.

**偏财, la Ricchezza indiretta**
Regola in più: la Ricchezza nutre l'Ufficiale (财生官).
Titolo: Un contatto nuovo
1. Oggi al lavoro può presentarsi un'occasione laterale: un contatto nuovo, un progetto che non era previsto. Ascolta tutta la proposta e fai due domande prima di dire no. || Il dio di oggi nel BaZi è la Ricchezza indiretta: il tuo elemento la governa con la stessa polarità. Sono le occasioni che arrivano di lato.
2. Oggi il lavoro cresce attraverso le relazioni. Telefona a una persona del tuo giro che non senti da tempo, anche solo per chiedere come va: può aprire qualcosa. || La Ricchezza indiretta è di turno: la regola del BaZi dice che la Ricchezza nutre l'Ufficiale, cioè che le risorse alimentano la carriera.
3. Oggi le risorse che sostengono il tuo lavoro vengono da fuori: un aiuto, uno strumento, una segnalazione. Accoglile con metodo: segna chi ti ha dato cosa e per quando. || È la giornata della Ricchezza indiretta: nel BaZi è ciò che circola e arriva di lato. Letta sul lavoro, nutre l'Ufficiale, cioè la carriera.

**正财, la Ricchezza diretta**
Regola in più: la Ricchezza nutre l'Ufficiale (财生官).
Titolo: Ordine e consegne
1. Oggi al lavoro le risorse ci sono: sta a te usarle bene. Prendi un'ora per organizzare budget, tempi e strumenti della settimana, con una lista scritta. || Il dio di oggi nel BaZi è la Ricchezza diretta: il tuo elemento la governa con polarità opposta. Sono le risorse regolari, frutto del lavoro.
2. Oggi è il lavoro concreto a tenere salda la tua posizione. Chiudi le pratiche aperte e consegna ciò che è quasi finito, invece di cominciare altro. || La Ricchezza diretta è di turno: la regola del BaZi dice che la Ricchezza nutre l'Ufficiale, cioè che il frutto del lavoro sostiene la posizione.
3. Oggi il lavoro fatto con ordine si nota. Scrivi i compiti dal più urgente al meno urgente e procedi uno alla volta, spuntandoli man mano che li chiudi. || È la giornata della Ricchezza diretta: nel BaZi è il guadagno regolare, frutto del lavoro. Letta sul lavoro, dà peso a chi procede con ordine.

**七杀, le Sette Uccisioni**
Titolo: Una prova da reggere
1. Oggi al lavoro c'è pressione: richieste dure, una sfida che ti mette alla prova. Si regge con la disciplina: fissa un orario per ogni compito e rispettalo. || Il dio di oggi nel BaZi sono le Sette Uccisioni: governano il tuo elemento con la stessa polarità. Sono una forza che mette alla prova.
2. Oggi sul lavoro qualcuno può alzare la voce o la posta. Rispondi con calma e con un piano: tre punti scritti, chi fa cosa, entro quando. || Le Sette Uccisioni sono di turno: nel BaZi stanno con l'Ufficiale diretto fra ciò che controlla il tuo elemento, cioè la regola e l'autorità.
3. Oggi il lavoro chiede coraggio. Affronta la cosa più difficile per prima, al mattino, finché hai energie; le faccende leggere lasciale al pomeriggio. || È la giornata delle Sette Uccisioni: nella lettura dei Dieci Dei governano il tuo elemento. Sul lavoro vogliono dire pressione e sfida.

**正官, l'Ufficiale diretto**
Titolo: Parla con chi decide
1. Oggi al lavoro è più facile farsi riconoscere per la serietà. È un buon giorno per parlare con chi decide: chiedi un colloquio e porta una richiesta precisa. || Il dio di oggi nel BaZi è l'Ufficiale diretto: governa il tuo elemento con polarità opposta. È regola, responsabilità, riconoscimento.
2. Oggi sul lavoro correttezza e puntualità contano più del solito. Arriva cinque minuti prima, con i documenti già pronti e le risposte alle domande che puoi prevedere. || L'Ufficiale diretto è di turno: nel BaZi è ciò che controlla il tuo elemento, cioè la regola, l'autorità, la carriera.
3. Oggi la tua affidabilità è sotto gli occhi di tutti. Mantieni la parola data: se hai promesso una risposta o una consegna, falla avere oggi, anche in due righe. || È la giornata dell'Ufficiale diretto: nella lettura dei Dieci Dei è il dio a cui la scheda del lavoro guarda per primo.

**偏印, il Sigillo indiretto**
Regola in più: i Sigilli trasformano l'Ufficiale in sostegno (官印相生).
Titolo: Tempo per concentrarti
1. Oggi al lavoro ti vengono soluzioni non convenzionali. Ritagliati un paio d'ore senza interruzioni per il compito che chiede più concentrazione, col telefono in silenzio. || Il dio di oggi nel BaZi è il Sigillo indiretto: genera il tuo elemento con la stessa polarità. È intuizione, sostegno insolito, studio personale.
2. Oggi sul lavoro capisci le cose di traverso, per intuito più che per ragionamento. Annota quello che ti sembra di aver capito e rimanda a domani la verifica, prima di agire. || Il Sigillo indiretto è di turno: la regola del BaZi dice che i Sigilli trasformano l'Ufficiale in sostegno. Qui il sostegno passa dall'intuizione.
3. Oggi al lavoro rende di più pensare che discutere. Sposta una riunione che non serve e usa quel tempo per imparare una competenza nuova, anche una sola funzione di uno strumento. || È la giornata del Sigillo indiretto: nella lettura dei Dieci Dei genera il tuo elemento e ti sostiene in una forma insolita.

**正印, il Sigillo diretto**
Regola in più: 官印相生, l'Ufficiale genera il Sigillo che sostiene te: protezione dall'alto.
Titolo: Le spalle coperte
1. Oggi al lavoro puoi contare su un sostegno: un superiore, un maestro, un'istituzione. Chiedi una guida a una di queste figure su un passaggio che non ti è chiaro. || Il dio di oggi nel BaZi è il Sigillo diretto: genera il tuo elemento con polarità opposta. È protezione, studio, cura, che vengono dall'alto.
2. Oggi è un buon giorno per formarti sul lavoro. Iscriviti a un corso, informati su una certificazione o chiedi a chi ha più esperienza di mostrarti come fa. || Il Sigillo diretto è di turno: la regola del BaZi dice che l'Ufficiale genera il Sigillo che sostiene te. L'autorità diventa insegnamento.
3. Oggi sul lavoro qualcuno ti copre le spalle. Ringrazia quella persona a voce e ricambia nel modo più semplice: fai bene la tua parte, fino all'ultimo dettaglio. || È la giornata del Sigillo diretto: nel BaZi l'Ufficiale genera il Sigillo e il Sigillo sostiene te. Per questo si parla di protezione dall'alto.

### 3.3 Amore, per una donna (guarda all'Ufficiale)

Regola: nel 子平 l'Ufficiale (正官) è il marito, le Sette Uccisioni (七杀) l'amante o un legame intenso; l'Ufficiale Ferito urta l'Ufficiale (伤官见官), la Ricchezza lo nutre (财生官), i Sigilli lo addolciscono, il Compagno e il Rivale portano altre persone nel quadro. Fonte: 渊海子平, "论六亲"; 子平真诠, "论六亲".

**比肩, il Compagno**
Titolo: Complici prima di tutto
1. Oggi il cuore sta bene fra le persone che ti somigliano, più che nei momenti a due. Organizza una serata con gli amici di sempre: ti rimette in contatto con quello che sei. || Il dio di oggi nel BaZi è il Compagno: ha il tuo stesso elemento e la tua stessa polarità. Nell'amore di una donna porta altre persone nel quadro.
2. Fra te e chi ami oggi la complicità viene prima della passione. Parla alla pari con chi ami, come in un'amicizia fidata: racconta una cosa della tua giornata che di solito tieni per te. || Oggi è di turno il Compagno, fra i Dieci Dei del BaZi: ha il tuo stesso elemento e la tua stessa polarità. Nell'amore di una donna porta altre persone nel quadro.
3. Il legame oggi somiglia più a un'amicizia che a un desiderio. Va bene così: proponi una cosa da fare fianco a fianco, una passeggiata o un film, senza chiederti che cosa manca. || Nel BaZi il giorno di oggi ti porta il Compagno: ha il tuo stesso elemento e la tua stessa polarità. Nell'amore di una donna porta altre persone nel quadro.

**劫财, il Rivale**
Titolo: Chiedi, non immaginare
1. Oggi in amore può sembrarti che qualcuno si metta in mezzo. Prima di costruirci sopra un film fai una domanda chiara a chi ami, poi giudica da ciò che ti risponde. || Il dio di oggi nel BaZi è il Rivale: ha il tuo stesso elemento con polarità opposta, contende ciò che hai. Nell'amore di una donna porta altre persone nel quadro.
2. La gelosia oggi scatta per poco. Se un dettaglio ti punge lascialo riposare fino a sera, senza controllare telefoni né profili: un'ombra non è ancora una storia. || Oggi è di turno il Rivale, fra i Dieci Dei del BaZi: ha il tuo stesso elemento con polarità opposta, contende ciò che hai. Nell'amore di una donna porta altre persone nel quadro.
3. In amore oggi è facile metterti a confronto con altre persone, o con l'idea che hai di te. Lascia stare i paragoni: ripensa a un fatto concreto che ti ha dato fiducia in questo legame. || Nel BaZi il giorno di oggi ti porta il Rivale: ha il tuo stesso elemento con polarità opposta, contende ciò che hai. Nell'amore di una donna porta altre persone nel quadro.

**食神, il Nutrimento**
Titolo: Tenerezza senza fretta
1. Oggi l'amore è dolce, fatto di piaceri semplici. Cucina per qualcuno a cui tieni oppure lascia che qualcuno cucini per te: a tavola ci si avvicina. || Il dio di oggi nel BaZi è il Nutrimento: il tuo elemento lo genera con la stessa polarità, è ciò che produci con calma. Nella scheda dell'amore è dolcezza, piacere semplice.
2. Il legame oggi cresce con i gesti piccoli, più che con le dichiarazioni. Porta un caffè, manda un messaggio a metà giornata, tieni un posto libero accanto a te. || Oggi è di turno il Nutrimento, fra i Dieci Dei del BaZi: il tuo elemento lo genera con la stessa polarità, è ciò che produci con calma. Nella scheda dell'amore è dolcezza, piacere semplice.
3. Fra voi oggi c'è tenerezza, con un passo lento. Rimanda i bilanci di coppia a un altro giorno: stasera scegli una cosa piacevole da fare insieme, senza discuterne. || Nel BaZi il giorno di oggi ti porta il Nutrimento: il tuo elemento lo genera con la stessa polarità, è ciò che produci con calma. Nella scheda dell'amore è dolcezza, piacere semplice.

**伤官, l'Ufficiale Ferito**
Regola: 伤官见官, per una donna è il segno classico dell'attrito col partner.
Titolo: Misura le parole
1. Oggi in amore la lingua corre più del cuore, una critica di troppo pesa più del previsto. Prima di parlare conta fino a dieci, poi tieni solo l'osservazione che serve davvero. || Il dio di oggi nel BaZi è l'Ufficiale Ferito: il tuo elemento lo genera con polarità opposta, è l'espressione che rompe le regole. Urta l'Ufficiale, la figura del partner: per una donna è il segno classico dell'attrito.
2. Con chi ami oggi senti il bisogno di dire tutto. Dillo con dolcezza, una cosa alla volta; poi fermati, ascolta la risposta fino in fondo senza preparare la replica. || Oggi è di turno l'Ufficiale Ferito, fra i Dieci Dei del BaZi: il tuo elemento lo genera con polarità opposta, è l'espressione che rompe le regole. Urta l'Ufficiale, la figura del partner: per una donna è il segno classico dell'attrito.
3. In amore oggi hai fascino e insofferenza nello stesso momento. Decidi prima quale dei due mostrare: se uscite insieme lascia fuori dalla serata il punto che ti irrita da giorni. || Nel BaZi il giorno di oggi ti porta l'Ufficiale Ferito: il tuo elemento lo genera con polarità opposta, è l'espressione che rompe le regole. Urta l'Ufficiale, la figura del partner: per una donna è il segno classico dell'attrito.

**偏财, la Ricchezza indiretta**
Regola: la Ricchezza nutre l'Ufficiale (财生官).
Titolo: Un gesto a sorpresa
1. Oggi in amore paga la generosità. Fai un gesto che non era in programma: offri tu la cena oppure proponi un'uscita decisa all'ultimo momento. || Il dio di oggi nel BaZi è la Ricchezza indiretta: il tuo elemento la governa con la stessa polarità. La Ricchezza nutre l'Ufficiale, che per una donna è la figura del partner.
2. Il legame oggi si scalda con una sorpresa. Libera due ore in agenda, porta chi ami in un posto dove non siete mai stati: basta un quartiere diverso dal solito. || Oggi è di turno la Ricchezza indiretta, fra i Dieci Dei del BaZi: il tuo elemento la governa con la stessa polarità. La Ricchezza nutre l'Ufficiale, che per una donna è la figura del partner.
3. L'amore oggi chiede di dare senza tenere il conto. Regala qualcosa al rapporto, anche piccolo: un favore, un pensiero preso per strada, il tuo tempo senza guardare l'orologio. || Nel BaZi il giorno di oggi ti porta la Ricchezza indiretta: il tuo elemento la governa con la stessa polarità. La Ricchezza nutre l'Ufficiale, che per una donna è la figura del partner.

**正财, la Ricchezza diretta**
Regola: la Ricchezza nutre l'Ufficiale (财生官).
Titolo: Costruire in due
1. Oggi in amore si costruisce. È un buon giorno per parlare di progetti concreti: scegliete un argomento solo, le vacanze o le spese comuni, mettetelo nero su bianco. || Il dio di oggi nel BaZi è la Ricchezza diretta: il tuo elemento la governa con polarità opposta. La Ricchezza nutre l'Ufficiale, che per una donna è la figura del partner.
2. In coppia oggi la cura pratica vale quanto una carezza. Fai per chi ami una cosa utile che aspetta da tempo: una commissione, una telefonata noiosa, una riparazione. || Oggi è di turno la Ricchezza diretta, fra i Dieci Dei del BaZi: il tuo elemento la governa con polarità opposta. La Ricchezza nutre l'Ufficiale, che per una donna è la figura del partner.
3. È la stabilità, oggi, a fare bene al legame. Pianifica qualcosa per due: prenota un tavolo, blocca una data in agenda, decidi dove passare il prossimo fine settimana. || Nel BaZi il giorno di oggi ti porta la Ricchezza diretta: il tuo elemento la governa con polarità opposta. La Ricchezza nutre l'Ufficiale, che per una donna è la figura del partner.

**七杀, le Sette Uccisioni**
Regola: per una donna è l'amante o il legame intenso, che mette alla prova.
Titolo: Passione a mente fredda
1. Oggi in amore l'attrazione è forte, a tratti scomoda. Senti tutto quello che c'è da sentire, ma rimanda a domani ogni decisione: niente messaggi definitivi scritti di notte. || Il dio di oggi nel BaZi sono le Sette Uccisioni: governano il tuo elemento con la stessa polarità, sono pressione e sfida. Per una donna sono l'amante o il legame intenso, che mette alla prova.
2. Passione e tensione oggi stanno nello stesso respiro. Se la conversazione diventa una prova di forza lascia la stanza per dieci minuti: non c'è niente da vincere. || Oggi sono di turno le Sette Uccisioni, fra i Dieci Dei del BaZi: governano il tuo elemento con la stessa polarità, sono pressione e sfida. Per una donna sono l'amante o il legame intenso, che mette alla prova.
3. Un incontro oggi può colpirti più del solito. Guarda chi hai davanti per quello che fa, non per quello che promette: aspetta un gesto concreto prima di aprirti. || Nel BaZi il giorno di oggi ti porta le Sette Uccisioni: governano il tuo elemento con la stessa polarità, sono pressione e sfida. Per una donna sono l'amante o il legame intenso, che mette alla prova.

**正官, l'Ufficiale diretto**
Regola: per una donna è il partner, la figura dell'unione.
Titolo: Una parola seria
1. Oggi è un buon giorno per la coppia stabile. Se c'è una parola seria che aspetta dilla adesso: una proposta, una data, un sì che hai già deciso dentro di te. || Il dio di oggi nel BaZi è l'Ufficiale diretto: governa il tuo elemento con polarità opposta, è regola e responsabilità. Per una donna è il partner, la figura dell'unione.
2. In coppia oggi contano il rispetto e le parole mantenute: fai la cosa che avevi promesso. Se non hai un legame dai il tuo tempo a una conoscenza seria prima che a una leggera. || Oggi è di turno l'Ufficiale diretto, fra i Dieci Dei del BaZi: governa il tuo elemento con polarità opposta, è regola e responsabilità. Per una donna è il partner, la figura dell'unione.
3. In amore oggi pesano l'impegno e la fiducia. Fatti trovare: arriva puntuale, rispondi alla chiamata, resta fino alla fine anche se hai altro da fare. || Nel BaZi il giorno di oggi ti porta l'Ufficiale diretto: governa il tuo elemento con polarità opposta, è regola e responsabilità. Per una donna è il partner, la figura dell'unione.

**偏印, il Sigillo indiretto**
Titolo: Uno spazio tuo
1. Oggi in amore hai bisogno di uno spazio tutto tuo. Non è distanza, è ricarica: prenditi mezz'ora senza telefono, avvisa chi ami che dopo ci sei. || Il dio di oggi nel BaZi è il Sigillo indiretto: genera il tuo elemento con la stessa polarità, è sostegno insolito e intuizione. Nell'amore di una donna i Sigilli addolciscono l'Ufficiale, la figura del partner.
2. Ti sembra, oggi, di capire chi ami senza bisogno di parole. Può essere vero oppure no: prima di muoverti su un'impressione fai una domanda semplice, poi aspetta la risposta. || Oggi è di turno il Sigillo indiretto, fra i Dieci Dei del BaZi: genera il tuo elemento con la stessa polarità, è sostegno insolito e intuizione. Nell'amore di una donna i Sigilli addolciscono l'Ufficiale, la figura del partner.
3. Il cuore oggi si capisce meglio in silenzio. Ritagliati un'ora per conto tuo, una camminata o un bagno caldo: dopo è più facile essere presente con chi ami. || Nel BaZi il giorno di oggi ti porta il Sigillo indiretto: genera il tuo elemento con la stessa polarità, è sostegno insolito e intuizione. Nell'amore di una donna i Sigilli addolciscono l'Ufficiale, la figura del partner.

**正印, il Sigillo diretto**
Titolo: Lasciati accudire
1. Oggi in amore c'è aria di protezione, di famiglia. Lasciati accudire: accetta il passaggio, la cena pronta, l'aiuto che di solito rifiuti per abitudine. || Il dio di oggi nel BaZi è il Sigillo diretto: genera il tuo elemento con polarità opposta, è protezione e cura. Nell'amore di una donna i Sigilli addolciscono l'Ufficiale, la figura del partner.
2. Il legame oggi è un rifugio. Chiedi un abbraccio senza spiegare perché ti serve: bastano due parole, poi resta lì un minuto in più. || Oggi è di turno il Sigillo diretto, fra i Dieci Dei del BaZi: genera il tuo elemento con polarità opposta, è protezione e cura. Nell'amore di una donna i Sigilli addolciscono l'Ufficiale, la figura del partner.
3. Stai bene, oggi, fra gli affetti sicuri di sempre. Chiama chi ti vuole bene da una vita, un genitore o un'amicizia storica: dieci minuti di voce, non un messaggio. || Nel BaZi il giorno di oggi ti porta il Sigillo diretto: genera il tuo elemento con polarità opposta, è protezione e cura. Nell'amore di una donna i Sigilli addolciscono l'Ufficiale, la figura del partner.

### 3.4 Amore, per un uomo (guarda alla Ricchezza)

Regola: nel 子平 la Ricchezza diretta (正财) è la moglie, la Ricchezza indiretta (偏财) la compagna occasionale o l'incontro; il Compagno e soprattutto il Rivale la contendono (比劫夺财), il Nutrimento e l'Ufficiale Ferito la generano (食伤生财), l'Ufficiale la consuma. Fonte: 渊海子平, "论六亲"; 子平真诠, "论六亲".

**比肩, il Compagno**
Titolo: Attenzione da dividere
1. Oggi in amore gli amici e i fratelli tirano dalla loro parte. Stai pure con loro, ma non trascurare chi ami: prima di uscire di' a che ora torni, poi rispetta l'orario. || Il dio di oggi nel BaZi è il Compagno: ha il tuo stesso elemento e la tua stessa polarità. Per un uomo contende la Ricchezza, che è la figura della partner.
2. La tua attenzione oggi è divisa fra chi ami e la tua cerchia. Invece di tenere le due cose separate uniscile: porta chi ami alla serata con gli amici e presenta qualcuno a cui tieni. || Oggi è di turno il Compagno, fra i Dieci Dei del BaZi: ha il tuo stesso elemento e la tua stessa polarità. Per un uomo contende la Ricchezza, che è la figura della partner.
3. Fra voi oggi c'è più amicizia che corteggiamento. Va bene, se lo sai: non pretendere la serata perfetta, proponi una cosa semplice da fare insieme, come fra vecchi amici. || Nel BaZi il giorno di oggi ti porta il Compagno: ha il tuo stesso elemento e la tua stessa polarità. Per un uomo contende la Ricchezza, che è la figura della partner.

**劫财, il Rivale**
Regola: 比劫夺财, il Rivale contende la figura della partner.
Titolo: Rassicura, non competere
1. Oggi in amore girano gelosie, confronti, il nome di un terzo nei discorsi. Invece di competere rassicura: spiega con parole semplici che cosa conta per te in questo legame. || Il dio di oggi nel BaZi è il Rivale: ha il tuo stesso elemento con polarità opposta, contende ciò che hai. Per un uomo la contesa riguarda la Ricchezza, che è la figura della partner.
2. Viene la tentazione, oggi, di metterti in gara per chi ami. Lascia perdere: niente prove di bravura, niente regali per battere qualcuno. Un legame si regge su una scelta, non su una vittoria. || Oggi è di turno il Rivale, fra i Dieci Dei del BaZi: ha il tuo stesso elemento con polarità opposta, contende ciò che hai. Per un uomo la contesa riguarda la Ricchezza, che è la figura della partner.
3. In amore oggi le parole sulle storie passate e sugli altri pesano il doppio. Tienile fuori dalla conversazione: se il discorso ci finisce cambia argomento con una domanda su chi hai davanti. || Nel BaZi il giorno di oggi ti porta il Rivale: ha il tuo stesso elemento con polarità opposta, contende ciò che hai. Per un uomo la contesa riguarda la Ricchezza, che è la figura della partner.

**食神, il Nutrimento**
Regola: il Nutrimento genera la Ricchezza (食伤生财).
Titolo: La calma che conquista
1. Oggi in amore va bene a chi è gentile: il legame cresce da ciò che offri. Fai a chi ami un'attenzione inattesa, il dolce preferito o un passaggio al lavoro. || Il dio di oggi nel BaZi è il Nutrimento: il tuo elemento lo genera con la stessa polarità, è ciò che produci con calma. Genera la Ricchezza, che per un uomo è la figura della partner.
2. Il tuo fascino oggi è la calma. Cucina per chi ami oppure proponi di uscire, poi lascia parlare: fai due domande, ascolta le risposte senza guardare il telefono. || Oggi è di turno il Nutrimento, fra i Dieci Dei del BaZi: il tuo elemento lo genera con la stessa polarità, è ciò che produci con calma. Genera la Ricchezza, che per un uomo è la figura della partner.
3. L'amore oggi è dolcezza semplice, senza grandi discorsi. Scegli un gesto concreto al posto delle parole: ripara una cosa che serve in due, apparecchia tu, prepara la colazione. || Nel BaZi il giorno di oggi ti porta il Nutrimento: il tuo elemento lo genera con la stessa polarità, è ciò che produci con calma. Genera la Ricchezza, che per un uomo è la figura della partner.

**伤官, l'Ufficiale Ferito**
Regola: genera la Ricchezza con impeto.
Titolo: Ironia, non sarcasmo
1. Oggi in amore hai brillantezza e fascino, ma poca pazienza. Usa l'ironia, mai il sarcasmo: se una battuta punge invece di far ridere chiedi scusa subito. || Il dio di oggi nel BaZi è l'Ufficiale Ferito: il tuo elemento lo genera con polarità opposta, è l'espressione che rompe le regole. Genera con impeto la Ricchezza, che per un uomo è la figura della partner.
2. Hai voglia, oggi, di stupire chi ami. Fallo con un'idea: un posto nuovo, un biglietto scritto a mano, un programma deciso da te. La provocazione lasciala stare. || Oggi è di turno l'Ufficiale Ferito, fra i Dieci Dei del BaZi: il tuo elemento lo genera con polarità opposta, è l'espressione che rompe le regole. Genera con impeto la Ricchezza, che per un uomo è la figura della partner.
3. Quello che senti oggi esce con forza. Dillo pure, in poche frasi; poi taci, lascia a chi ami lo spazio per rispondere anche se la risposta tarda ad arrivare. || Nel BaZi il giorno di oggi ti porta l'Ufficiale Ferito: il tuo elemento lo genera con polarità opposta, è l'espressione che rompe le regole. Genera con impeto la Ricchezza, che per un uomo è la figura della partner.

**偏财, la Ricchezza indiretta**
Regola: per un uomo è la figura della compagna non ufficiale, l'incontro.
Titolo: Leggerezza e onestà
1. Oggi in amore c'è aria leggera. Se non hai un legame accetta un invito, parla con chi non conosci; se sei in coppia porta quella leggerezza nel legame con un'uscita improvvisata. || Il dio di oggi nel BaZi è la Ricchezza indiretta: il tuo elemento la governa con la stessa polarità. Per un uomo è la figura della compagna non ufficiale, l'incontro.
2. Le occasioni sociali oggi portano sguardi e attenzioni. Vivile con onestà verso di te e verso chi hai accanto: non fare niente che stasera non potresti raccontare. || Oggi è di turno la Ricchezza indiretta, fra i Dieci Dei del BaZi: il tuo elemento la governa con la stessa polarità. Per un uomo è la figura della compagna non ufficiale, l'incontro.
3. Il cuore oggi si muove, in più direzioni. Tocca a te scegliere dove fermarlo: prima di rispondere a un messaggio che ti lusinga decidi fin dove vuoi arrivare. || Nel BaZi il giorno di oggi ti porta la Ricchezza indiretta: il tuo elemento la governa con la stessa polarità. Per un uomo è la figura della compagna non ufficiale, l'incontro.

**正财, la Ricchezza diretta**
Regola: per un uomo è la figura della moglie, la compagna stabile.
Titolo: Esserci basta
1. Oggi è un buon giorno per la coppia. Mettete mano a un progetto comune: scegliete insieme una cosa da fare entro il mese, poi dividetevi i compiti. || Il dio di oggi nel BaZi è la Ricchezza diretta: il tuo elemento la governa con polarità opposta. Per un uomo è la figura della moglie, la compagna stabile.
2. Il legame oggi chiede presenza costante, non gesti che fanno scena. Esserci basta: torna all'ora detta, sedetevi a tavola insieme, chiedi com'è andata. || Oggi è di turno la Ricchezza diretta, fra i Dieci Dei del BaZi: il tuo elemento la governa con polarità opposta. Per un uomo è la figura della moglie, la compagna stabile.
3. In amore oggi conta la serietà più della quantità. Se non hai un legame dai il tuo tempo a una persona sola, con un invito vero: un incontro serio vale più di dieci leggeri. || Nel BaZi il giorno di oggi ti porta la Ricchezza diretta: il tuo elemento la governa con polarità opposta. Per un uomo è la figura della moglie, la compagna stabile.

**七杀, le Sette Uccisioni**
Regola: governano te; la Ricchezza si consuma verso di loro.
Titolo: Un'ora solo per voi
1. Oggi le pressioni di fuori tolgono spazio all'amore. Proteggi un'ora solo per voi due: telefono in un'altra stanza, nessun discorso di scadenze. || Il dio di oggi nel BaZi sono le Sette Uccisioni: governano il tuo elemento con la stessa polarità, sono pressione e sfida. La Ricchezza, la figura della partner, si consuma verso di loro.
2. Hai i nervi tesi, oggi: in amore rischia di farne le spese chi ti sta vicino. Non portare a tavola la battaglia del giorno, prima di rientrare fai due passi per lasciare lì la rabbia. || Oggi sono di turno le Sette Uccisioni, fra i Dieci Dei del BaZi: governano il tuo elemento con la stessa polarità, sono pressione e sfida. La Ricchezza, la figura della partner, si consuma verso di loro.
3. In amore oggi si sente la fatica che porti addosso. Invece di chiuderti dilla: bastano due frasi su che cosa ti pesa, senza chiedere a chi ami di risolverlo. || Nel BaZi il giorno di oggi ti porta le Sette Uccisioni: governano il tuo elemento con la stessa polarità, sono pressione e sfida. La Ricchezza, la figura della partner, si consuma verso di loro.

**正官, l'Ufficiale diretto**
Titolo: La promessa mantenuta
1. Oggi doveri e impegni passano davanti all'amore. Non lasciarlo sparire dalla giornata: manda un messaggio a metà pomeriggio, tieni libera la cena. || Il dio di oggi nel BaZi è l'Ufficiale diretto: governa il tuo elemento con polarità opposta, è regola e responsabilità. L'Ufficiale consuma la Ricchezza, che per un uomo è la figura della partner.
2. Anche in coppia oggi valgono la correttezza e la parola data. Mantieni ciò che hai promesso: la telefonata, la commissione, quel sabato che avevi detto di tenere per voi. || Oggi è di turno l'Ufficiale diretto, fra i Dieci Dei del BaZi: governa il tuo elemento con polarità opposta, è regola e responsabilità. L'Ufficiale consuma la Ricchezza, che per un uomo è la figura della partner.
3. In amore oggi rassicura più l'affidabilità dei gesti teneri. Al posto del fiore scegli un gesto che si può contare: arriva in orario, sbriga tu la pratica rimasta indietro. || Nel BaZi il giorno di oggi ti porta l'Ufficiale diretto: governa il tuo elemento con polarità opposta, è regola e responsabilità. L'Ufficiale consuma la Ricchezza, che per un uomo è la figura della partner.

**偏印, il Sigillo indiretto**
Titolo: Silenzio condiviso
1. Oggi in amore hai bisogno di pensare, con del tempo per conto tuo. Dillo chiaramente a chi ami, con un orario di rientro: così non sembra distanza. || Il dio di oggi nel BaZi è il Sigillo indiretto: genera il tuo elemento con la stessa polarità, è sostegno insolito e intuizione. Nella scheda dell'amore è il bisogno di pensare.
2. Ti vengono, oggi, intuizioni su chi ami, non tutte esatte. Prima di agire chiedi conferma: una domanda aperta, poi credi a quello che ti viene risposto. || Oggi è di turno il Sigillo indiretto, fra i Dieci Dei del BaZi: genera il tuo elemento con la stessa polarità, è sostegno insolito e intuizione. Nella scheda dell'amore è il bisogno di pensare.
3. Il legame oggi sta bene nel silenzio condiviso. Stare accanto senza parlare vale: leggete nella stessa stanza, guidate senza musica, camminate senza riempire i vuoti. || Nel BaZi il giorno di oggi ti porta il Sigillo indiretto: genera il tuo elemento con la stessa polarità, è sostegno insolito e intuizione. Nella scheda dell'amore è il bisogno di pensare.

**正印, il Sigillo diretto**
Titolo: Cura e radici
1. Oggi in amore contano la cura, la famiglia, le radici. Passa a trovare i tuoi oppure cucina tu stasera per chi ami, senza programmi fuori. || Il dio di oggi nel BaZi è il Sigillo diretto: genera il tuo elemento con polarità opposta, è protezione e cura. Nella scheda dell'amore è cura, famiglia, radici.
2. In amore oggi fa bene ricevere. Lasciati accudire senza orgoglio: se chi ami ti offre un aiuto o ti prepara qualcosa, ringrazia invece di rispondere che ce la fai. || Oggi è di turno il Sigillo diretto, fra i Dieci Dei del BaZi: genera il tuo elemento con polarità opposta, è protezione e cura. Nella scheda dell'amore è cura, famiglia, radici.
3. Il legame oggi è protezione che va in due direzioni. Chiedi una mano su una cosa precisa a chi ami, poi offri la tua su qualcosa che pesa a quella persona. || Nel BaZi il giorno di oggi ti porta il Sigillo diretto: genera il tuo elemento con polarità opposta, è protezione e cura. Nella scheda dell'amore è cura, famiglia, radici.

### 3.5 Amore, serie neutra (genere non dichiarato)

Regola: scelta dell'app, non della tradizione. La serie legge il dio del giorno sul legame in generale: Ricchezza e Ufficiale sono entrambi "la figura dell'altro", i Sigilli la cura, il Compagno e il Rivale le persone intorno, il Nutrimento e l'Ufficiale Ferito l'espressione. La nota del metodo lo dichiara. Fonte delle definizioni (ordine EV, verifica dell'Architetto, da C-G-232 a C-G-261): per il Compagno e il Rivale come fratelli, amici e pari, la Ricchezza diretta come la moglie per un uomo e l'Ufficiale diretto come il marito per una donna, Shen Xiaozhan, Ziping Zhenquan (XVIII secolo), i capitoli sui dieci dei e sui sei parenti; Xu Dasheng, Yuanhai Ziping (dinastia Song).

**比肩, il Compagno**
Titolo: Un legame alla pari
1. Oggi in amore vincono l'amicizia e la complicità. Parla alla pari con chi ami: chiedi un parere su una cosa tua, poi dai il tuo su una cosa sua. || Il dio di oggi nel BaZi è il Compagno: ha il tuo stesso elemento e la tua stessa polarità. La scheda dell'amore lo legge come le persone che hai intorno.
2. L'affetto oggi passa anche dagli amici, non solo dalla coppia. Dai loro del tempo: chiama una persona amica che non senti da settimane, fissate un caffè. || Oggi è di turno il Compagno, fra i Dieci Dei del BaZi: ha il tuo stesso elemento e la tua stessa polarità. La scheda dell'amore lo legge come le persone che hai intorno.
3. Il legame oggi è prima di tutto un'alleanza. Trova una cosa da affrontare in due, un problema pratico o una decisione: mettetevi dalla stessa parte del tavolo. || Nel BaZi il giorno di oggi ti porta il Compagno: ha il tuo stesso elemento e la tua stessa polarità. La scheda dell'amore lo legge come le persone che hai intorno.

**劫财, il Rivale**
Titolo: Scegli la fiducia
1. Oggi in amore è facile sentirsi in competizione con qualcuno. Prima di immaginare chiedi: una domanda sola, fatta con calma, vale più di una sera di sospetti. || Il dio di oggi nel BaZi è il Rivale: ha il tuo stesso elemento con polarità opposta, contende ciò che hai. La scheda dell'amore lo legge come le persone che hai intorno.
2. La gelosia oggi è a portata di mano. Scegli la fiducia con un gesto: non controllare orari né telefoni, chiedi invece a chi ami di raccontarti la sua giornata. || Oggi è di turno il Rivale, fra i Dieci Dei del BaZi: ha il tuo stesso elemento con polarità opposta, contende ciò che hai. La scheda dell'amore lo legge come le persone che hai intorno.
3. Viene voglia, oggi, di mettersi in gara per chi ami. Non farlo: niente confronti con altre persone, niente dimostrazioni. Passate un'ora insieme senza parlare di nessun altro. || Nel BaZi il giorno di oggi ti porta il Rivale: ha il tuo stesso elemento con polarità opposta, contende ciò che hai. La scheda dell'amore lo legge come le persone che hai intorno.

**食神, il Nutrimento**
Titolo: Gesti semplici
1. Oggi l'amore è fatto di dolcezza, con gesti semplici. Cucina qualcosa, invita chi ti piace o chi ami, poi ascolta più di quanto parli. || Il dio di oggi nel BaZi è il Nutrimento: il tuo elemento lo genera con la stessa polarità, è ciò che produci con calma. La scheda dell'amore lo legge come il tuo modo di esprimerti.
2. Il legame oggi cresce da ciò che offri con calma. Regala un'attenzione senza aspettare niente in cambio: un passaggio, una tazza di tè, dieci minuti di ascolto vero. || Oggi è di turno il Nutrimento, fra i Dieci Dei del BaZi: il tuo elemento lo genera con la stessa polarità, è ciò che produci con calma. La scheda dell'amore lo legge come il tuo modo di esprimerti.
3. In amore oggi sta bene chi si gode il piacere semplice. Lascia stare i bilanci: una passeggiata, un gelato, un film scelto insieme bastano a fare la giornata. || Nel BaZi il giorno di oggi ti porta il Nutrimento: il tuo elemento lo genera con la stessa polarità, è ciò che produci con calma. La scheda dell'amore lo legge come il tuo modo di esprimerti.

**伤官, l'Ufficiale Ferito**
Titolo: Una parola dolce
1. Oggi in amore le parole escono prima dei pensieri. Una frase dolce vale più di una frase giusta: se devi correggere chi ami comincia da ciò che apprezzi. || Il dio di oggi nel BaZi è l'Ufficiale Ferito: il tuo elemento lo genera con polarità opposta, è l'espressione che rompe le regole. La scheda dell'amore lo legge come il tuo modo di esprimerti.
2. Hai bisogno, oggi, di dire tutto a chi ami. Dillo in modo chiaro, senza alzare la voce; poi fai silenzio, lascia all'altra persona tutto il tempo per rispondere. || Oggi è di turno l'Ufficiale Ferito, fra i Dieci Dei del BaZi: il tuo elemento lo genera con polarità opposta, è l'espressione che rompe le regole. La scheda dell'amore lo legge come il tuo modo di esprimerti.
3. In amore oggi porti fascino e insofferenza insieme. Scegli quale mostrare: tieni la battuta brillante, rimanda a domani il rimprovero che hai sulla punta della lingua. || Nel BaZi il giorno di oggi ti porta l'Ufficiale Ferito: il tuo elemento lo genera con polarità opposta, è l'espressione che rompe le regole. La scheda dell'amore lo legge come il tuo modo di esprimerti.

**偏财, la Ricchezza indiretta**
Titolo: Fuori programma
1. Oggi in amore c'è movimento: incontri, sorprese, uscite fuori programma. Rispondi di sì a un invito dell'ultimo momento oppure proponine uno tu. || Il dio di oggi nel BaZi è la Ricchezza indiretta: il tuo elemento la governa con la stessa polarità. La scheda dell'amore la legge come la figura dell'altro.
2. Il cuore oggi si muove, a volte verso più di una persona. Mantieni l'onestà con te e con chi hai accanto: non promettere a nessuno ciò che non intendi mantenere. || Oggi è di turno la Ricchezza indiretta, fra i Dieci Dei del BaZi: il tuo elemento la governa con la stessa polarità. La scheda dell'amore la legge come la figura dell'altro.
3. L'amore oggi chiede generosità. Dai qualcosa al legame senza fare conti: un'ora in più, un piccolo regalo, un favore che nessuno ti ha chiesto. || Nel BaZi il giorno di oggi ti porta la Ricchezza indiretta: il tuo elemento la governa con la stessa polarità. La scheda dell'amore la legge come la figura dell'altro.

**正财, la Ricchezza diretta**
Titolo: Progetti concreti
1. Oggi in amore si costruisce. Parla di progetti concreti con chi ami: un viaggio, un trasloco, una spesa da fare in due. Uscitene con una data. || Il dio di oggi nel BaZi è la Ricchezza diretta: il tuo elemento la governa con polarità opposta. La scheda dell'amore la legge come la figura dell'altro.
2. La cura pratica oggi vale quanto una carezza. Fai una cosa utile per chi ami: ritira un pacco, sbriga una commissione, sistema ciò che si è rotto. || Oggi è di turno la Ricchezza diretta, fra i Dieci Dei del BaZi: il tuo elemento la governa con polarità opposta. La scheda dell'amore la legge come la figura dell'altro.
3. È la stabilità, oggi, a fare bene al legame. Tieni fermo un appuntamento fisso, la cena di metà settimana o la telefonata della sera: non spostarlo. || Nel BaZi il giorno di oggi ti porta la Ricchezza diretta: il tuo elemento la governa con polarità opposta. La scheda dell'amore la legge come la figura dell'altro.

**七杀, le Sette Uccisioni**
Titolo: Senti, poi decidi
1. Oggi in amore c'è un'attrazione forte oppure una tensione forte. Senti tutto, ma decidi con calma: dormici sopra prima di dire una cosa che cambia i rapporti. || Il dio di oggi nel BaZi sono le Sette Uccisioni: governano il tuo elemento con la stessa polarità, sono pressione e sfida. La scheda dell'amore le legge come la figura dell'altro.
2. Il legame oggi rischia di diventare una prova di forza. Cedi tu su una cosa piccola, il ristorante o l'orario: mostra che non stai tenendo il punteggio. || Oggi sono di turno le Sette Uccisioni, fra i Dieci Dei del BaZi: governano il tuo elemento con la stessa polarità, sono pressione e sfida. La scheda dell'amore le legge come la figura dell'altro.
3. In amore oggi le promesse contano poco, i fatti molto. Guarda chi hai davanti per quello che fa: ripassa che cosa è successo nell'ultima settimana, non le parole di ieri sera. || Nel BaZi il giorno di oggi ti porta le Sette Uccisioni: governano il tuo elemento con la stessa polarità, sono pressione e sfida. La scheda dell'amore le legge come la figura dell'altro.

**正官, l'Ufficiale diretto**
Titolo: La parola data
1. Oggi in amore contano l'impegno e la fiducia. Dai una parola, poi mantienila entro sera: l'orario di un appuntamento, una chiamata, una risposta che devi da giorni. || Il dio di oggi nel BaZi è l'Ufficiale diretto: governa il tuo elemento con polarità opposta, è regola e responsabilità. La scheda dell'amore lo legge come la figura dell'altro.
2. Esserci oggi vale più di qualunque gesto. Fatti trovare dove hai detto, per tutto il tempo: metti via il telefono, resta fino alla fine. || Oggi è di turno l'Ufficiale diretto, fra i Dieci Dei del BaZi: governa il tuo elemento con polarità opposta, è regola e responsabilità. La scheda dell'amore lo legge come la figura dell'altro.
3. L'amore oggi è una cosa seria, fatta di poche parole mantenute. Prometti una sola cosa a chi ami, piccola e precisa, poi falla prima di parlare d'altro. || Nel BaZi il giorno di oggi ti porta l'Ufficiale diretto: governa il tuo elemento con polarità opposta, è regola e responsabilità. La scheda dell'amore lo legge come la figura dell'altro.

**偏印, il Sigillo indiretto**
Titolo: Spazio per respirare
1. Oggi in amore hai bisogno di uno spazio tuo. Dillo a chi ami con parole chiare, aggiungi quando torni: così non sembra distanza. || Il dio di oggi nel BaZi è il Sigillo indiretto: genera il tuo elemento con la stessa polarità, è sostegno insolito e intuizione. La scheda dell'amore legge i Sigilli come la cura.
2. Ti pare, oggi, di intuire che cosa passa per la testa di chi ami. Verifica con una domanda prima di darlo per buono: chiedi, non dedurre. || Oggi è di turno il Sigillo indiretto, fra i Dieci Dei del BaZi: genera il tuo elemento con la stessa polarità, è sostegno insolito e intuizione. La scheda dell'amore legge i Sigilli come la cura.
3. Anche il silenzio condiviso oggi è vicinanza. Passate del tempo nella stessa stanza facendo ognuno la sua cosa: non serve riempire ogni pausa di parole. || Nel BaZi il giorno di oggi ti porta il Sigillo indiretto: genera il tuo elemento con la stessa polarità, è sostegno insolito e intuizione. La scheda dell'amore legge i Sigilli come la cura.

**正印, il Sigillo diretto**
Titolo: Un rifugio sicuro
1. Oggi in amore contano la cura e la famiglia. Lasciati accudire: accetta il piatto caldo, la coperta, l'aiuto offerto, senza dire che non ce n'è bisogno. || Il dio di oggi nel BaZi è il Sigillo diretto: genera il tuo elemento con polarità opposta, è protezione e cura. La scheda dell'amore legge i Sigilli come la cura.
2. Il legame oggi è un rifugio. Chiedi un abbraccio a voce, senza aspettare che l'altra persona indovini: poi restaci dentro qualche secondo in più. || Oggi è di turno il Sigillo diretto, fra i Dieci Dei del BaZi: genera il tuo elemento con polarità opposta, è protezione e cura. La scheda dell'amore legge i Sigilli come la cura.
3. L'affetto che conta oggi è quello di lunga data. Chiama chi ti vuole bene da sempre, un genitore o un'amicizia storica: una telefonata vera, non un messaggio. || Nel BaZi il giorno di oggi ti porta il Sigillo diretto: genera il tuo elemento con polarità opposta, è protezione e cura. La scheda dell'amore legge i Sigilli come la cura.

---

## 4. Righe fisse delle schede

### 4.1 Colore e numeri (tutte le schede, riga in fondo)

Regola: elemento del tronco del giorno; colore dal 礼记·月令; numeri dallo He Tu (河图) come li dà il 周易·系辞上 (vedi `specifiche.md`, paragrafo 5).

1. Il giorno è di {elemento}: il suo colore nella tradizione è il {colore}, i suoi numeri {numeri}.
2. Elemento del giorno: {elemento}. Colore {colore}, numeri {numeri}, secondo la figura dello He Tu.
3. Oggi governa {elemento}. Nella tradizione cinese gli appartengono il {colore} e i numeri {numeri}.

(Per il legno "il verde-azzurro", per l'acqua "il nero".)

### 4.2 Direzione (Generale: Dio della Gioia; Fortuna: Dio della Ricchezza)

Regola: dal tronco del giorno, tabella degli almanacchi (协纪辨方书), vedi `specifiche.md`, paragrafo 6.

Generale:
1. Per l'incontro a cui tieni di più, oggi conta anche dove lo metti. Se puoi, fissa l'appuntamento che conta in un posto a {direzione_gioia} rispetto a casa tua. || Gli almanacchi cinesi mettono oggi il Dio della Gioia a {direzione_gioia}: il posto viene dal tronco del giorno.
2. La direzione buona della giornata è una sola, per le cose che fanno piacere. Se esci per una passeggiata o per vedere qualcuno, scegli una meta a {direzione_gioia} del punto da cui parti. || La direzione del giorno è {direzione_gioia}, dove l'almanacco cinese colloca il Dio della Gioia.
3. Quando oggi hai qualcosa da decidere, puoi aiutarti con un gesto simbolico. Siediti con lo sguardo a {direzione_gioia}, fai un respiro lungo e solo dopo di' il tuo sì o il tuo no. || Il Dio della Gioia oggi sta a {direzione_gioia}, secondo il calendario cinese, che ne dà il posto giorno per giorno.

Fortuna:
1. Per le faccende di denaro, oggi c'è un lato da cui conviene passare. Se hai una commissione che riguarda i soldi, scegli lo sportello, il negozio o l'ufficio che sta a {direzione_ricchezza} rispetto a casa tua. || L'almanacco cinese pone oggi il Dio della Ricchezza a {direzione_ricchezza}: il posto viene dal tronco del giorno.
2. Quando oggi ti occupi di soldi, puoi farlo con un piccolo gesto simbolico. Siediti al tavolo con lo sguardo a {direzione_ricchezza} mentre controlli le spese, prepari una richiesta o fai il punto del mese. || La direzione della ricchezza oggi è {direzione_ricchezza}, secondo il calendario cinese e la tabella degli almanacchi.
3. Sul denaro la giornata indica una direzione, non una cifra. Tieni il portafoglio e le carte da sistemare sul lato della stanza che sta a {direzione_ricchezza}: è da lì che oggi conviene fare i conti. || Il Dio della Ricchezza, dicono gli almanacchi cinesi, oggi sta a {direzione_ricchezza}.

### 4.3 Nota del metodo (una per scheda, col punto interrogativo)

- Generale: "L'animale del giorno è il ramo del giorno nel ciclo dei sessanta; il rapporto col tuo animale viene dalle tabelle del Sanming Tonghui (1578). Il guardiano del giorno è uno dei dodici del calendario, contato dal mese solare."
- Fortuna, Lavoro, Amore: "Il tuo giorno di nascita ha un tronco celeste, il giorno di oggi un altro: il loro rapporto fra i cinque elementi dà uno dei Dieci Dei del BaZi. La scheda prende il livello da quel dio come lo leggono lo Yuanhai Ziping e il Ziping Zhenquan; il testo è scelto per quel livello."
- Tutte: "Colore e numeri sono quelli dell'elemento del giorno nella tradizione, non colori o numeri portafortuna."
