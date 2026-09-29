# Oroscopo cinese del giorno, bozza del corpus (ordine ES, voce 08)

Voce di Medora: calda, diretta, concreta. Non promette, non inventa, non attribuisce caratteri agli animali. Ogni frase dice che cosa suggerisce la regola della tradizione e che cosa farne oggi.

Segnaposti (li riempie l'app):

- `{animale_giorno}`, `{animale_tuo}`: col proprio articolo, per esempio "il Cavallo", "la Capra" (tabella `ISegniDelleTradizioni.animali`).
- `{guardiano}`: il nome italiano del guardiano del giorno (Stabilire, Togliere, Pieno, ...).
- `{colore}`, `{elemento}`, `{numeri}`, `{direzione_gioia}`, `{direzione_ricchezza}`.

Scelta delle varianti: la variante segue il ritorno del caso, non il giorno. Ogni volta che lo stesso caso torna (il ramo del giorno ogni dodici giorni, il dio ogni dieci, il Dio della Gioia nello stesso posto ogni cinque, l'elemento e il Dio della Ricchezza per due tronchi di fila ogni dieci giorni, il guardiano alla sua prossima volta, contando anche il giorno del jie che lo ripete) la persona legge la variante successiva del gruppo. Prima la variante era il giorno giuliano modulo il numero delle varianti: il ramo torna ogni dodici giorni, dodici è multiplo di tre, e la stessa persona leggeva la stessa frase ogni volta che tornava lo stesso animale (ordine ES voce 08, docs/collaudo/ES/regola_a_lettura_cinese.txt; la lezione della EE.04 nel CLAUDE.md).

Le regole e le fonti richiamate qui sono spiegate per intero in `specifiche.md`, paragrafi 2, 3 e 4.

---

## 1. Scheda Generale: il rapporto fra l'animale del giorno e il tuo

Regola: si confronta il ramo del giorno col ramo dell'anno di nascita; se i rapporti sono due vale il primo nell'ordine scontro, punizione, danno, armonia, tripla armonia, stesso animale, nessuno; la coppia Serpente e Scimmia ha un gruppo suo. Fonte: 三命通会 (Sanming Tonghui, 1578), libro II, capitoli sui sei accordi, le tre armonie, i tre castighi, i sei danni, gli scontri; 五行大义 (Wuxing Dayi), capitoli sugli accordi, gli scontri, i castighi e i danni.

### 1.1 Armonia (六合 Liu He)

Regola: sei coppie di rami si "accordano" (子丑, 寅亥, 卯戌, 辰酉, 巳申, 午未): nel 三命通会 l'accordo è l'unione di yin e yang che si completano.

1. Oggi è il giorno di {animale_giorno}, che nella tradizione cinese si accorda con {animale_tuo}: è una delle sei coppie in armonia. Usalo per ciò che si fa in due: una telefonata rimandata, un accordo da chiudere, un aiuto da chiedere.
2. {animale_giorno} guida il giorno. Il tuo animale e il suo formano una delle sei armonie: due metà che si completano. Oggi conviene cercare chi ti completa invece di [fare tutto da solo|fare tutto da sola|fare tutto senza aiuto].
3. Giornata in armonia col tuo animale: il ramo di oggi e quello del tuo anno di nascita sono una coppia che la tradizione chiama "accordo". Non ti regala nulla da sé; ti dice che oggi collaborare costa meno fatica del solito.

### 1.2 Tripla armonia (三合 San He)

Regola: quattro terne di rami formano un elemento insieme (申子辰 acqua, 亥卯未 legno, 寅午戌 fuoco, 巳酉丑 metallo); due rami della stessa terna sono in "mezza armonia" (半合).

1. {animale_giorno} e {animale_tuo} appartengono alla stessa terna, il gruppo che la tradizione lega a {elemento_terna}. È un'intesa più larga di una coppia: oggi funziona ciò che coinvolge un gruppo, una squadra, una famiglia.
2. Oggi guida {animale_giorno}, che sta nella stessa terna del tuo animale. Nell'almanacco le terne sono alleanze: vale la pena rimettere insieme persone che da tempo non si parlano.
3. Il giorno di {animale_giorno} è alleato del tuo anno: siete due dei tre rami che insieme fanno {elemento_terna}. Se hai un progetto che dipende da altri, oggi è un buon giorno per coinvolgerli.

(`{elemento_terna}`: "l'acqua", "il legno", "il fuoco", "il metallo".)

### 1.3 Scontro (六冲 Chong)

Regola: i rami opposti (distanza sei) si urtano. Gli almanacchi scrivono ogni giorno "冲" seguito dall'animale che si scontra col giorno: è l'avvertimento più letto del 黄历.

1. Oggi è il giorno di {animale_giorno}, che sta di fronte al tuo animale: l'almanacco lo chiama scontro. Non vuol dire che andrà male; vuol dire che le spinte vanno in direzioni opposte. Rimanda le decisioni prese di corsa.
2. Il ramo di oggi è l'opposto del tuo. Gli almanacchi cinesi lo scrivono in chiaro: oggi si scontra con {animale_tuo}. Tieni le cose semplici, lascia cadere la discussione che non ti serve vincere.
3. Giorno di scontro col tuo animale. Nella tradizione è il momento in cui le cose ferme si muovono, anche a strattoni. Se qualcosa si rompe, guarda se non era già incrinato; se qualcosa si sblocca, lascialo andare.

### 1.4 Punizione (三刑 Xing)

Regola: tre gruppi di rami si "puniscono" (寅巳申, 丑戌未, 子卯) più quattro rami che puniscono se stessi (辰, 午, 酉, 亥). Il 三命通会 le chiama punizione dell'ingratitudine, dell'arroganza, della scortesia.

1. Il ramo di oggi e il tuo sono legati da ciò che la tradizione chiama punizione: non un castigo, un attrito che nasce da un eccesso. Oggi misura il tono. Una parola in più pesa più del solito.
2. Oggi {animale_giorno} e {animale_tuo} formano una delle tre punizioni. Il consiglio antico è di non forzare: rispetta i tempi degli altri, rispetta anche i tuoi.
3. Giornata di attrito col tuo animale, secondo l'almanacco. Controlla due volte ciò che firmi o mandi; la fretta oggi è la parte che si paga.

### 1.5 Punizione di sé (自刑)

Regola: Drago, Cavallo, Gallo e Maiale puniscono se stessi: quando il giorno ha il tuo stesso ramo e il tuo è uno di questi quattro.

1. Oggi è il giorno del tuo stesso animale e la tradizione dice che {animale_tuo} con se stesso si punisce: il rischio sei tu contro di te. Non chiederti più di quanto chiederesti [a un amico|a un'amica|a una persona amica].
2. Giorno del tuo animale, ma nella forma che l'almanacco chiama punizione di sé. Se ti accorgi di rimuginare, fermati e fai una cosa con le mani.
3. Il ramo di oggi è il tuo. Per {animale_tuo} la tradizione lo legge come un giorno in cui ci si inciampa da soli: poche cose, finite bene.

### 1.6 Danno (六害 Hai)

Regola: sei coppie si danneggiano (子未, 丑午, 寅巳, 卯辰, 申亥, 酉戌); nel 三命通会 il danno nasce perché ognuno dei due rompe l'accordo dell'altro.

1. {animale_giorno} disturba l'accordo del tuo animale: la tradizione lo chiama danno. È un fastidio più che un urto. Occhio alle promesse degli altri, verificale prima di contarci.
2. Oggi il giorno e il tuo anno sono una delle sei coppie del danno. Piccoli intoppi, ritardi, un messaggio frainteso: niente di grave, se non lo ingrandisci.
3. Giorno di danno per {animale_tuo}, dice l'almanacco. Proteggi ciò che funziona già; non è il giorno per mettere mano a un equilibrio che regge.

### 1.7 Armonia che punisce (巳申, Serpente e Scimmia)

Regola: Serpente e Scimmia sono insieme una delle sei armonie e una delle punizioni; i testi la chiamano 刑合, accordo con attrito.

1. Oggi {animale_giorno} e {animale_tuo} si accordano e si punzecchiano insieme: la tradizione conosce questa coppia doppia. Fidati dell'intesa, ma metti per iscritto i patti.
2. Coppia doppia oggi: armonia e attrito nello stesso legame. Lavora con chi ti somiglia, senza dare per scontato che capisca al volo.
3. Il ramo di oggi e il tuo si cercano e si urtano. Vicinanza sì, confidenza cieca no.

### 1.8 Stesso animale

Regola: il giorno ha il ramo del tuo anno (e il tuo non è fra i quattro che puniscono se stessi). Nella tradizione i rami uguali si rafforzano (比 "stare fianco a fianco"); non è uno dei rapporti classificati.

1. Oggi è il giorno di {animale_giorno}, il tuo stesso animale: ritorna ogni dodici giorni. Non è un giorno di favore né di sfida; è un giorno in cui ciò che fai porta più il tuo segno.
2. Il ramo di oggi è il tuo. Fai la cosa che solo tu sai fare nel tuo modo, invece di adattarti a quello degli altri.
3. Giorno del tuo animale: la tradizione non gli dà un peso particolare. Il peso glielo dai tu: scegli una cosa a cui tieni e mettila per prima.

### 1.9 Nessun rapporto

Regola: fra il ramo del giorno e il tuo non c'è accordo, terna, scontro, punizione o danno. È il caso più frequente (66 celle su 144): servono più varianti.

1. Oggi guida {animale_giorno}, che col tuo animale non ha legami nella tradizione: né accordo né urto. Il giorno lo leggi meglio dal suo guardiano, qui sotto.
2. Fra {animale_giorno} e {animale_tuo} oggi non c'è un rapporto classico. Vuol dire giornata neutra: quello che ne esce dipende da ciò che ci metti.
3. Nessun accordo e nessuno scontro fra il giorno e il tuo anno. Buona occasione per le cose ordinarie fatte con cura.
4. Il ramo di oggi e il tuo non si cercano e non si respingono. Giornata libera dal lato degli animali: segui il consiglio del guardiano.
5. Oggi {animale_giorno} passa accanto al tuo animale senza toccarlo, dice la tradizione. Nessuna spinta da fuori: il ritmo lo decidi tu.

---

## 2. Scheda Generale: il guardiano del giorno

Regola: il guardiano è la distanza fra il ramo del giorno e il ramo del mese solare (建 il giorno che ha il ramo del mese, poi gli altri in ordine; il giorno del jie ripete). Fonte: 淮南子·天文训 per la successione; 钦定协纪辨方书 (1739) per la regola degli almanacchi; adatto e sconsigliato dalla sintesi degli almanacchi in https://www.sohu.com/a/727671351_121819358 riscontrata su huangli999.com e huangli888.com (vedi `specifiche.md`, paragrafo 2). Il consiglio viene dal solo guardiano, non dall'almanacco intero: la nota del metodo lo dice.

Formato proposto: una frase, poi due righe brevi "Adatto a" e "Meglio evitare" prese dalla tabella delle specifiche e dette in italiano quotidiano.

### 2.1 Stabilire (建 Jian)

Adatto a: cominciare un percorso, partire, prendere un incarico. Meglio evitare: lavori di scavo, grandi spostamenti di cose.

1. Il guardiano di oggi è Stabilire, il primo dei dodici: il giorno in cui qualcosa si mette in piedi. Comincia il corso, la routine, il progetto che rimandi.
2. Oggi veglia Stabilire. La tradizione lo vuole per gli inizi e per mettersi in viaggio; lo sconsiglia per rivoltare ciò che è già a terra. Pianta, non sradicare.
3. Stabilire guida il giorno: buono per prendere un impegno nuovo e dirlo a voce alta. Lascia stare i traslochi di cose pesanti.

### 2.2 Togliere (除 Chu)

Adatto a: pulire, curarsi, liberarsi del vecchio, piccoli affari. Meglio evitare: partenze, traslochi, candidature a un incarico.

1. Oggi il guardiano è Togliere: la tradizione lo dedica a ciò che si porta via. Una visita medica, un armadio da svuotare, un debito da chiudere.
2. Togliere veglia sul giorno. Fai spazio prima di aggiungere: una cosa tolta oggi vale più di tre cose nuove.
3. Giornata di Togliere, dice l'almanacco: buona per la cura di te e per chiudere conti in sospeso. Rimanda la partenza se puoi.

### 2.3 Pieno (满 Man)

Adatto a: celebrare, incontri di famiglia, aprire un'attività, cercare un guadagno. Meglio evitare: traslochi, lavori di terra, prendere un nuovo incarico.

1. Oggi veglia Pieno, il guardiano del raccolto. È un giorno per festeggiare ciò che c'è già: una cena con i tuoi, un grazie detto per bene.
2. Il guardiano Pieno dice abbondanza, non avidità. Adatto a incassare, a fare il punto; non a caricarti di impegni nuovi.
3. Giorno di Pieno: la tradizione lo vuole per le celebrazioni e i guadagni. Resta dove sei; i traslochi aspettino un altro guardiano.

### 2.4 Livellare (平 Ping)

Adatto a: riparare, sistemare, abbellire. Meglio evitare: aprire strade nuove (la tradizione dice "scavare canali").

1. Il guardiano di oggi è Livellare: un giorno piano, né favorevole né contrario. Perfetto per aggiustare ciò che è storto.
2. Oggi veglia Livellare. Non cercare svolte: rimetti in pari la casa, l'agenda, un rapporto un po' sbilanciato.
3. Livellare guida il giorno: le cose ordinarie vanno bene, le deviazioni no. Sistema quello che c'è prima di aprire altro.

### 2.5 Fissare (定 Ding)

Adatto a: pianificare, decisioni che devono durare, cerimonie. Meglio evitare: liti, cause, partenze.

1. Oggi veglia Fissare: la tradizione lo lega a ciò che deve restare. Metti per iscritto un piano, fissa una data.
2. Il guardiano Fissare chiede stabilità. Buono per decidere a mente fredda, cattivo per discutere: se una lite si affaccia, rimandala.
3. Giorno di Fissare: resta, costruisci, programma. Il viaggio e il confronto duro hanno giorni migliori.

### 2.6 Tenere (执 Zhi)

Adatto a: tenere fermo ciò che hai, costruire, piantare, portare a termine. Meglio evitare: aprire un'attività, commerciare, traslocare, partire.

1. Il guardiano di oggi è Tenere: la tradizione lo vuole per trattenere, non per lasciare andare. Porta a termine una cosa iniziata.
2. Oggi veglia Tenere. Custodisci ciò che hai costruito; per compravendite e partenze l'almanacco consiglia altri giorni.
3. Tenere guida il giorno: presa salda, pochi movimenti. Pianta un seme, finisci un lavoro, non firmare in fretta.

### 2.7 Rompere (破 Po)

Adatto a: demolire il vecchio, cercare cure. Meglio evitare: ogni cosa importante di buon augurio (gli almanacchi scrivono "诸事不宜", nessuna impresa conviene).

1. Oggi il guardiano è Rompere, il più severo dei dodici: gli almanacchi sconsigliano di cominciare cose importanti. Usalo per chiudere ciò che non regge più.
2. Rompere veglia sul giorno. Non è un giorno da firme né da inizi; è un giorno per tagliare, buttare, dire di no a ciò che ti pesa.
3. Giorno di Rompere: la tradizione lo vuole solo per demolire e per curarsi. Tieni leggeri i programmi; le cose nuove aspettino.

### 2.8 Pericolo (危 Wei)

Adatto a: cerimonie, raccoglimento. Meglio evitare: salire in alto, andare per mare, traslocare.

1. Il guardiano di oggi è Pericolo: la tradizione chiede prudenza con l'altezza e con l'acqua. Tradotto oggi: niente rischi fisici inutili, attenzione alla guida.
2. Oggi veglia Pericolo. Non è un presagio; è un invito alla cautela. Giorno buono per raccoglierti, meno per spostarti.
3. Pericolo guida il giorno: fai con calma ciò che fai di solito in fretta. Scale, strade, cantieri meritano un occhio in più.

### 2.9 Compiere (成 Cheng)

Adatto a: aprire, firmare accordi, cominciare un'unione, partire, traslocare, curarsi. Meglio evitare: liti e cause.

1. Oggi veglia Compiere, uno dei guardiani più favorevoli: la tradizione lo vuole per ciò che deve arrivare in fondo. Firma, consegna, conferma.
2. Il guardiano Compiere porta a termine. Se hai un sì da dare o da chiedere, oggi è il giorno; lascia fuori le discussioni.
3. Giorno di Compiere: accordi, partenze, inizi di coppia vanno bene secondo l'almanacco. Evita solo di trascinare qualcuno in una lite.

### 2.10 Raccogliere (收 Shou)

Adatto a: incassare, raccogliere i frutti, studiare. Meglio evitare: partire, i riti funebri.

1. Il guardiano di oggi è Raccogliere: la tradizione lo lega al raccolto. Incassa, archivia, fai il bilancio.
2. Oggi veglia Raccogliere. Non seminare: raccogli. Chiedi il compenso che ti spetta, rimetti in ordine ciò che hai guadagnato.
3. Raccogliere guida il giorno: buono per imparare e per mettere da parte. Le partenze l'almanacco le rimanda.

### 2.11 Aprire (开 Kai)

Adatto a: aprire un'attività, inizi di coppia, entrare in casa nuova, chiedere. Meglio evitare: lavori di terra, i riti funebri.

1. Oggi veglia Aprire, il guardiano delle porte che si aprono: la tradizione lo vuole per inaugurare, presentarsi, chiedere.
2. Il guardiano Aprire invita a farti vedere. Manda la candidatura, fai la proposta, apri la porta a chi aspetta.
3. Giorno di Aprire: buono per gli inizi, secondo l'almanacco. Lascia chiuso solo ciò che riguarda la terra e i lutti.

### 2.12 Chiudere (闭 Bi)

Adatto a: riposo, mettere al sicuro, chiudere falle. Meglio evitare: aprire un'attività, sposarsi, partire, cercare guadagni.

1. Il guardiano di oggi è Chiudere: la tradizione lo lega al riposo e a ciò che si mette al sicuro. Giornata buona per rientrare in te.
2. Oggi veglia Chiudere. Niente inaugurazioni, niente grandi richieste; chiudi le falle, salva i file, riposa.
3. Chiudere guida il giorno: l'almanacco lo sconsiglia per aprire e per partire. Custodisci ciò che hai, il resto domani.

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
1. Oggi il giorno ha il tuo stesso elemento: nel BaZi è il Compagno, che divide con te ciò che c'è. Buono per le spese condivise, meno per i guadagni personali.
2. Il Compagno di oggi dice: quello che entra, entra per più persone. Se c'è da dividere, dividi con chiarezza.
3. Giornata del Compagno sul fronte del denaro: niente colpi di fortuna, qualche spesa in compagnia. Tieni il conto.

**劫财, il Rivale**
Regola: stesso elemento, polarità opposta: la tradizione lo chiama letteralmente "rapina della ricchezza".
1. Oggi il giorno ti porta il Rivale, che il BaZi chiama "chi prende la ricchezza": prudenza con prestiti, acquisti d'impulso, offerte troppo belle.
2. Il Rivale è di turno. Non è un furto annunciato; è la tendenza del denaro a scivolare via. Rimanda la spesa grande.
3. Giornata del Rivale per la fortuna: qualcuno può chiederti più di quanto conviene dare. Un no gentile oggi vale oro.

**食神, il Nutrimento**
Regola: il tuo elemento lo genera; nel BaZi il Nutrimento a sua volta genera la Ricchezza (食伤生财): il guadagno viene da ciò che sai fare.
1. Oggi il giorno ti porta il Nutrimento: nel BaZi è la vena che produce la ricchezza. Il denaro passa dal tuo lavoro ben fatto, non dalla sorte.
2. Il Nutrimento è di turno: un buon giorno per vendere ciò che crei o per proporre il tuo talento. Con calma, senza svenderti.
3. Giornata del Nutrimento sul fronte della fortuna: il guadagno è lento ma pulito. Semina qualcosa che rende nel tempo.

**伤官, l'Ufficiale Ferito**
Regola: il tuo elemento lo genera con polarità opposta; genera la Ricchezza (食伤生财) ma con impeto.
1. Oggi il giorno ti porta l'Ufficiale Ferito: talento che corre e genera guadagno, a patto di non rompere gli accordi. Un'idea originale può rendere.
2. L'Ufficiale Ferito è di turno: la fortuna passa da un'iniziativa tua, fuori dagli schemi. Controlla però i contratti: le regole non si saltano.
3. Giornata dell'Ufficiale Ferito per il denaro: brillante e impaziente. Spendi la creatività, non il conto in banca.

**偏财, la Ricchezza indiretta**
Regola: il tuo elemento la governa, stessa polarità: guadagni che arrivano di lato, occasioni, denaro che circola.
1. Oggi il giorno ti porta la Ricchezza indiretta: nel BaZi è il denaro delle occasioni. Guarda le proposte che arrivano da strade insolite, con la testa lucida.
2. La Ricchezza indiretta è di turno: il denaro si muove, entra ed esce. Buon giorno per trattare, non per scommettere.
3. Giornata di Ricchezza indiretta: un'entrata fuori dal solito è possibile, una spesa fuori dal solito anche. Decidi tu quale delle due lasciare passare.

**正财, la Ricchezza diretta**
Regola: il tuo elemento la governa con polarità opposta: il guadagno regolare, frutto del lavoro.
1. Oggi il giorno ti porta la Ricchezza diretta, il denaro guadagnato con metodo. Buon giorno per sistemare i conti, chiedere un pagamento, risparmiare.
2. La Ricchezza diretta è di turno: niente colpi di scena, entrate che arrivano da dove devono. Fai il punto e metti da parte qualcosa.
3. Giornata di Ricchezza diretta sul fronte della fortuna: ciò che hai seminato si può raccogliere. Chiedi ciò che ti spetta.

**七杀, le Sette Uccisioni**
Regola: governa il tuo elemento; la Ricchezza lo nutre (财生官): il denaro va verso obblighi e pressioni.
1. Oggi il giorno ti porta le Sette Uccisioni: nel BaZi è la pressione. Sul denaro vuol dire spese imposte, scadenze. Pagale per prime, poi respira.
2. Le Sette Uccisioni sono di turno: il denaro serve a difenderti, non a crescere. Evita rischi, fai fronte agli impegni.
3. Giornata delle Sette Uccisioni per la fortuna: qualcuno può pretendere. Rispondi con i numeri alla mano, senza farti mettere fretta.

**正官, l'Ufficiale diretto**
Regola: governa il tuo elemento con polarità opposta; la Ricchezza lo nutre (财生官): il denaro va verso posizione e doveri.
1. Oggi il giorno ti porta l'Ufficiale diretto: il denaro va dove c'è una regola. Tasse, bollette, una spesa per la tua reputazione.
2. L'Ufficiale diretto è di turno: spendere per ciò che ti rende affidabile è un buon uso del denaro oggi. Il resto aspetta.
3. Giornata dell'Ufficiale diretto sul fronte della fortuna: ordine prima di tutto. Metti in regola una pratica rimasta indietro.

**偏印, il Sigillo indiretto**
Regola: genera il tuo elemento, stessa polarità; non tocca la Ricchezza: il sostegno arriva in forma insolita.
1. Oggi il giorno ti porta il Sigillo indiretto: nel BaZi non parla di denaro. La fortuna oggi è un'intuizione, un'informazione, non un'entrata.
2. Il Sigillo indiretto è di turno: poco movimento sul conto, molto nella testa. Annota l'idea che ti arriva.
3. Giornata del Sigillo indiretto: il denaro non è il tema. Investi in ciò che impari, anche solo un'ora.

**正印, il Sigillo diretto**
Regola: genera il tuo elemento con polarità opposta; la protezione, non il guadagno.
1. Oggi il giorno ti porta il Sigillo diretto, che protegge più che arricchire. Buon giorno per chiedere un consiglio a chi ne sa di più.
2. Il Sigillo diretto è di turno: fortuna come sostegno, da una persona o da un'istituzione. Accettalo senza sentirti in debito.
3. Giornata del Sigillo diretto sul fronte del denaro: tranquilla. Custodisci, non rischiare.

### 3.2 Lavoro (guarda all'Ufficiale)

Regola generale: l'Ufficiale (正官, 七杀) è ciò che controlla il tuo elemento: la regola, l'autorità, la carriera. La Ricchezza lo nutre (财生官), i Sigilli lo trasformano in sostegno (官印相生), l'Ufficiale Ferito lo attacca (伤官见官), il Nutrimento doma le Sette Uccisioni (食神制杀), il Compagno e il Rivale portano la concorrenza fra pari.

**比肩, il Compagno**
1. Oggi al lavoro c'è il Compagno: pari grado, colleghi, persone come te. Buono per lavorare in squadra, meno per farsi notare da chi decide.
2. Il Compagno di oggi dice collaborazione orizzontale. Chiedi aiuto a un collega, offri il tuo.
3. Giornata del Compagno: al lavoro conta la rete dei pari. Coltivala, senza misurarti.

**劫财, il Rivale**
1. Oggi al lavoro c'è il Rivale: concorrenza, qualcuno che punta allo stesso posto. Resta sui fatti e documenta ciò che fai.
2. Il Rivale è di turno: non tutti giocano a carte scoperte. Condividi le idee con chi conosci bene.
3. Giornata del Rivale: la competizione si sente. Rispondi col lavoro fatto, non con le parole.

**食神, il Nutrimento**
Regola in più: il Nutrimento doma le Sette Uccisioni (食神制杀): il talento tiene a bada la pressione.
1. Oggi al lavoro c'è il Nutrimento: il tuo talento lavora con naturalezza. Fai la cosa [in cui sei bravo|in cui sei brava|che ti riesce meglio] e lasciala parlare.
2. Il Nutrimento è di turno: la qualità del lavoro conta più della fretta. Se c'è una pressione, la regge la competenza.
3. Giornata del Nutrimento: buona per creare, scrivere, insegnare. I risultati arrivano senza forzare.

**伤官, l'Ufficiale Ferito**
Regola in più: 伤官见官, l'Ufficiale Ferito urta l'Ufficiale: attrito con i superiori e con le regole.
1. Oggi al lavoro c'è l'Ufficiale Ferito: idee brillanti, pazienza corta. Con i capi scegli le parole; una critica giusta detta male diventa un problema.
2. L'Ufficiale Ferito è di turno: la voglia di cambiare le regole è forte. Proponi il cambiamento per iscritto, non in riunione a caldo.
3. Giornata dell'Ufficiale Ferito: creatività sì, sfida all'autorità no. Tieni il talento dalla parte giusta del tavolo.

**偏财, la Ricchezza indiretta**
Regola in più: la Ricchezza nutre l'Ufficiale (财生官).
1. Oggi al lavoro c'è la Ricchezza indiretta: occasioni laterali, un contatto nuovo, un progetto non previsto. Ascolta prima di dire no.
2. La Ricchezza indiretta è di turno: il lavoro cresce attraverso le relazioni. Una telefonata a chi non senti da tempo può aprire qualcosa.
3. Giornata di Ricchezza indiretta: risorse che sostengono la carriera arrivano da fuori. Accoglile con metodo.

**正财, la Ricchezza diretta**
Regola in più: la Ricchezza nutre l'Ufficiale (财生官).
1. Oggi al lavoro c'è la Ricchezza diretta: le risorse ci sono, usale bene. Buon giorno per organizzare budget, tempi, strumenti.
2. La Ricchezza diretta è di turno: il lavoro concreto sostiene la tua posizione. Chiudi pratiche, consegna.
3. Giornata di Ricchezza diretta: il lavoro fatto con ordine oggi si nota. Metti in fila le cose.

**七杀, le Sette Uccisioni**
1. Oggi al lavoro ci sono le Sette Uccisioni: pressione, richieste dure, una sfida. Nel BaZi è una forza che mette alla prova; si regge con disciplina.
2. Le Sette Uccisioni sono di turno: qualcuno alza la voce o la posta. Rispondi con calma e con un piano.
3. Giornata delle Sette Uccisioni: il lavoro chiede coraggio. Affronta la cosa difficile per prima, finché hai energie.

**正官, l'Ufficiale diretto**
1. Oggi al lavoro c'è l'Ufficiale diretto: regola, responsabilità, riconoscimento. Buon giorno per parlare con chi decide.
2. L'Ufficiale diretto è di turno: correttezza e puntualità contano più del solito. [Presentati preparato|Presentati preparata|Presentati con tutto pronto].
3. Giornata dell'Ufficiale diretto: la tua affidabilità è sotto gli occhi di tutti. Mantieni la parola data.

**偏印, il Sigillo indiretto**
Regola in più: i Sigilli trasformano l'Ufficiale in sostegno (官印相生).
1. Oggi al lavoro c'è il Sigillo indiretto: intuizioni, soluzioni non convenzionali, studio personale. [Lavora da solo|Lavora da sola|Lavora in autonomia] su ciò che richiede concentrazione.
2. Il Sigillo indiretto è di turno: capisci le cose di traverso. Annota, verificherai domani.
3. Giornata del Sigillo indiretto: meno riunioni, più pensiero. Una competenza nuova vale più di un'ora di chiacchiere.

**正印, il Sigillo diretto**
Regola in più: 官印相生, l'Ufficiale genera il Sigillo che sostiene te: protezione dall'alto.
1. Oggi al lavoro c'è il Sigillo diretto: sostegno da un superiore, da un maestro, da un'istituzione. Chiedi una guida.
2. Il Sigillo diretto è di turno: buon giorno per formarti, certificarti, farti insegnare.
3. Giornata del Sigillo diretto: qualcuno ti copre le spalle. Ringrazialo e fai bene la tua parte.

### 3.3 Amore, per una donna (guarda all'Ufficiale)

Regola: nel 子平 l'Ufficiale (正官) è il marito, le Sette Uccisioni (七杀) l'amante o un legame intenso; l'Ufficiale Ferito urta l'Ufficiale (伤官见官), la Ricchezza lo nutre (财生官), i Sigilli lo addolciscono, il Compagno e il Rivale portano altre persone nel quadro. Fonte: 渊海子平, "论六亲"; 子平真诠, "论六亲".

**比肩, il Compagno**
1. Oggi in amore c'è il Compagno: [amici|amiche|persone amiche], persone come te. Una serata con loro ti restituisce [a te stesso|a te stessa|a te].
2. Il Compagno di oggi mette la complicità davanti alla passione. Parla alla pari con chi ami.
3. Giornata del Compagno: il legame è amicizia prima che desiderio. Va bene così.

**劫财, il Rivale**
1. Oggi in amore c'è il Rivale: qualcuno si mette in mezzo, o così sembra. Chiedi prima di immaginare.
2. Il Rivale è di turno: gelosie facili. Non lasciare che un'ombra diventi una storia.
3. Giornata del Rivale: occhio alla competizione, anche [con te stesso|con te stessa|con te]. Tieniti stretta la fiducia.

**食神, il Nutrimento**
1. Oggi in amore c'è il Nutrimento: dolcezza, piacere semplice. Cucina per qualcuno, fatti cucinare.
2. Il Nutrimento è di turno: il legame cresce con i gesti piccoli, non con le dichiarazioni.
3. Giornata del Nutrimento: tenerezza e calma. Lascia fuori i bilanci di coppia.

**伤官, l'Ufficiale Ferito**
Regola: 伤官见官, per una donna è il segno classico dell'attrito col partner.
1. Oggi in amore c'è l'Ufficiale Ferito, che nel BaZi urta la figura del partner: la lingua corre. Una critica di troppo può ferire più del previsto.
2. L'Ufficiale Ferito è di turno: bisogno di dire tutto. Dillo con dolcezza; poi ascolta la risposta.
3. Giornata dell'Ufficiale Ferito: fascino e insofferenza insieme. Scegli quale mostrare.

**偏财, la Ricchezza indiretta**
Regola: la Ricchezza nutre l'Ufficiale (财生官).
1. Oggi in amore c'è la Ricchezza indiretta, che nel BaZi nutre la figura del partner: un gesto generoso, un'uscita non programmata.
2. La Ricchezza indiretta è di turno: il legame si scalda con la sorpresa. Prenditi il tempo per un'uscita.
3. Giornata di Ricchezza indiretta: dai qualcosa al rapporto, anche piccolo, senza fare conti.

**正财, la Ricchezza diretta**
Regola: la Ricchezza nutre l'Ufficiale (财生官).
1. Oggi in amore c'è la Ricchezza diretta: si costruisce. Buon giorno per parlare di progetti concreti insieme.
2. La Ricchezza diretta è di turno: la cura pratica vale come una carezza. Fai una cosa utile per l'altro.
3. Giornata di Ricchezza diretta: la stabilità nutre il legame. Pianifica qualcosa per due.

**七杀, le Sette Uccisioni**
Regola: per una donna è l'amante o il legame intenso, che mette alla prova.
1. Oggi in amore ci sono le Sette Uccisioni: nel BaZi è un'attrazione forte, a volte scomoda. Senti tutto; decidi con calma.
2. Le Sette Uccisioni sono di turno: passione e tensione nello stesso respiro. Non farti trascinare in una prova di forza.
3. Giornata delle Sette Uccisioni: un incontro può colpire. Guarda chi hai davanti per quello che fa, non per quello che promette.

**正官, l'Ufficiale diretto**
Regola: per una donna è il partner, la figura dell'unione.
1. Oggi in amore c'è l'Ufficiale diretto, che nel BaZi è la figura del partner: buon giorno per la coppia stabile, per una parola seria.
2. L'Ufficiale diretto è di turno: il legame chiede rispetto e parole mantenute. [Se sei solo|Se sei sola|Se non hai un legame], l'incontro serio viene prima di quello leggero.
3. Giornata dell'Ufficiale diretto: impegno, fiducia, presenza. Esserci oggi conta.

**偏印, il Sigillo indiretto**
1. Oggi in amore c'è il Sigillo indiretto: bisogno di spazio tuo. Non è distanza; è ricarica.
2. Il Sigillo indiretto è di turno: capisci l'altro senza parole, o credi di capirlo. Verifica con una domanda.
3. Giornata del Sigillo indiretto: il cuore si ascolta in silenzio. Un'ora [da solo|da sola|per conto tuo] ti renderà più presente dopo.

**正印, il Sigillo diretto**
1. Oggi in amore c'è il Sigillo diretto: protezione, cura, famiglia. Lasciati accudire.
2. Il Sigillo diretto è di turno: il legame è un rifugio. Chiedi un abbraccio senza giustificarti.
3. Giornata del Sigillo diretto: affetti sicuri, madre, casa. Chiama chi ti vuole bene da sempre.

### 3.4 Amore, per un uomo (guarda alla Ricchezza)

Regola: nel 子平 la Ricchezza diretta (正财) è la moglie, la Ricchezza indiretta (偏财) la compagna occasionale o l'incontro; il Compagno e soprattutto il Rivale la contendono (比劫夺财), il Nutrimento e l'Ufficiale Ferito la generano (食伤生财), l'Ufficiale la consuma. Fonte: 渊海子平, "论六亲"; 子平真诠, "论六亲".

**比肩, il Compagno**
1. Oggi in amore c'è il Compagno: amici, fratelli, persone come te. Non trascurare chi ami per stare con loro.
2. Il Compagno di oggi divide l'attenzione. Porta la tua compagna dentro la tua cerchia, non accanto.
3. Giornata del Compagno: più amicizia che romanticismo. Va bene, se lo sai.

**劫财, il Rivale**
Regola: 比劫夺财, il Rivale contende la figura della partner.
1. Oggi in amore c'è il Rivale, che nel BaZi contende la figura della partner: gelosie, confronti, un terzo nel discorso. Rassicura invece di competere.
2. Il Rivale è di turno: non metterti in gara con nessuno per chi ami. Chi resta, resta per scelta.
3. Giornata del Rivale: prudenza con le parole sulle ex e sugli altri. Oggi pesano.

**食神, il Nutrimento**
Regola: il Nutrimento genera la Ricchezza (食伤生财).
1. Oggi in amore c'è il Nutrimento, che nel BaZi genera la figura della partner: gentilezza, piacere, attenzioni. Il legame cresce da ciò che offri.
2. Il Nutrimento è di turno: cucina, invita, ascolta. Il fascino di oggi è la calma.
3. Giornata del Nutrimento: dolcezza semplice. Un gesto concreto vale più di un discorso.

**伤官, l'Ufficiale Ferito**
Regola: genera la Ricchezza con impeto.
1. Oggi in amore c'è l'Ufficiale Ferito: brillante, seduttivo, impaziente. Usa l'ironia, non il sarcasmo.
2. L'Ufficiale Ferito è di turno: vuoi stupire. Stupisci con un'idea, non con una provocazione.
3. Giornata dell'Ufficiale Ferito: espressione forte. Di' ciò che senti, ma lascia spazio alla risposta.

**偏财, la Ricchezza indiretta**
Regola: per un uomo è la figura della compagna non ufficiale, l'incontro.
1. Oggi in amore c'è la Ricchezza indiretta, che nel BaZi è l'incontro: nuove conoscenze, simpatie leggere. Se sei in coppia, porta la leggerezza a casa.
2. La Ricchezza indiretta è di turno: occasioni sociali, sguardi. Vivile con onestà verso te e verso chi hai accanto.
3. Giornata di Ricchezza indiretta: il cuore si muove. Scegli dove fermarlo.

**正财, la Ricchezza diretta**
Regola: per un uomo è la figura della moglie, la compagna stabile.
1. Oggi in amore c'è la Ricchezza diretta, che nel BaZi è la compagna stabile: buon giorno per la coppia, per un progetto comune.
2. La Ricchezza diretta è di turno: il legame chiede presenza costante, non gesti eclatanti. Esserci basta.
3. Giornata di Ricchezza diretta: [se sei solo|se sei sola|se non hai un legame], un incontro serio conta più di dieci leggeri.

**七杀, le Sette Uccisioni**
Regola: governano te; la Ricchezza si consuma verso di loro.
1. Oggi in amore ci sono le Sette Uccisioni: pressioni esterne tolgono spazio al legame. Proteggi un'ora solo per voi due.
2. Le Sette Uccisioni sono di turno: nervi tesi. Non portare a casa la battaglia del giorno.
3. Giornata delle Sette Uccisioni: chi ami ti vede sotto sforzo. Dillo, invece di chiuderti.

**正官, l'Ufficiale diretto**
1. Oggi in amore c'è l'Ufficiale diretto: doveri, reputazione, impegni. Il legame passa in secondo piano; non lasciarlo sparire.
2. L'Ufficiale diretto è di turno: correttezza e parola data valgono anche in coppia. Mantieni ciò che hai promesso.
3. Giornata dell'Ufficiale diretto: amore responsabile. Un gesto di affidabilità rassicura più di un fiore.

**偏印, il Sigillo indiretto**
1. Oggi in amore c'è il Sigillo indiretto: bisogno di pensare, di [stare un po' da solo|stare un po' da sola|stare un po' per conto tuo]. Dillo, così non sembra distanza.
2. Il Sigillo indiretto è di turno: intuizioni sull'altro. Chiedi conferma prima di agire.
3. Giornata del Sigillo indiretto: il legame si nutre di silenzio condiviso. Anche stare accanto senza parlare vale.

**正印, il Sigillo diretto**
1. Oggi in amore c'è il Sigillo diretto: cura, famiglia, radici. Una visita ai tuoi o una cena a casa.
2. Il Sigillo diretto è di turno: lasciati accudire senza orgoglio.
3. Giornata del Sigillo diretto: il legame è protezione reciproca. Chiedi e offri sostegno.

### 3.5 Amore, serie neutra (genere non dichiarato)

Regola: scelta dell'app, non della tradizione. La serie legge il dio del giorno sul legame in generale: Ricchezza e Ufficiale sono entrambi "la figura dell'altro", i Sigilli la cura, il Compagno e il Rivale le persone intorno, il Nutrimento e l'Ufficiale Ferito l'espressione. La nota del metodo lo dichiara.

**比肩, il Compagno**
1. Oggi in amore c'è il Compagno: amicizia e complicità. Parla alla pari con chi ami.
2. Il Compagno di oggi ricorda che anche gli amici sono affetti. Dagli tempo.
3. Giornata del Compagno: il legame è prima di tutto alleanza.

**劫财, il Rivale**
1. Oggi in amore c'è il Rivale: facile sentirsi in competizione. Chiedi prima di immaginare.
2. Il Rivale è di turno: gelosie a portata di mano. Scegli la fiducia.
3. Giornata del Rivale: non metterti in gara per chi ami.

**食神, il Nutrimento**
1. Oggi in amore c'è il Nutrimento: dolcezza e gesti semplici. Cucina, invita, ascolta.
2. Il Nutrimento è di turno: il legame cresce da ciò che offri con calma.
3. Giornata del Nutrimento: piacere semplice, niente bilanci.

**伤官, l'Ufficiale Ferito**
1. Oggi in amore c'è l'Ufficiale Ferito: la lingua corre. Una parola dolce vale più di una giusta.
2. L'Ufficiale Ferito è di turno: bisogno di dire tutto. Dillo, poi ascolta.
3. Giornata dell'Ufficiale Ferito: fascino e insofferenza. Scegli quale mostrare.

**偏财, la Ricchezza indiretta**
1. Oggi in amore c'è la Ricchezza indiretta: incontri, sorprese, uscite fuori programma.
2. La Ricchezza indiretta è di turno: il cuore si muove. [Resta onesto|Resta onesta|Mantieni l'onestà] con te e con chi hai accanto.
3. Giornata di Ricchezza indiretta: dai qualcosa al legame, senza contare.

**正财, la Ricchezza diretta**
1. Oggi in amore c'è la Ricchezza diretta: si costruisce. Parla di progetti concreti.
2. La Ricchezza diretta è di turno: la cura pratica vale come una carezza.
3. Giornata di Ricchezza diretta: la stabilità nutre il legame.

**七杀, le Sette Uccisioni**
1. Oggi in amore ci sono le Sette Uccisioni: attrazione forte o tensione forte. Senti tutto, decidi con calma.
2. Le Sette Uccisioni sono di turno: non trasformare il legame in una prova di forza.
3. Giornata delle Sette Uccisioni: guarda chi hai davanti per quello che fa.

**正官, l'Ufficiale diretto**
1. Oggi in amore c'è l'Ufficiale diretto: impegno, parola data, fiducia.
2. L'Ufficiale diretto è di turno: esserci oggi conta più di qualunque gesto.
3. Giornata dell'Ufficiale diretto: amore serio, poche parole mantenute.

**偏印, il Sigillo indiretto**
1. Oggi in amore c'è il Sigillo indiretto: bisogno di spazio proprio. Dillo, così non sembra distanza.
2. Il Sigillo indiretto è di turno: intuisci l'altro. Verifica con una domanda.
3. Giornata del Sigillo indiretto: anche il silenzio condiviso è vicinanza.

**正印, il Sigillo diretto**
1. Oggi in amore c'è il Sigillo diretto: cura, casa, famiglia. Lasciati accudire.
2. Il Sigillo diretto è di turno: il legame è un rifugio. Chiedi un abbraccio.
3. Giornata del Sigillo diretto: chiama chi ti vuole bene da sempre.

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
1. Gli almanacchi mettono oggi il Dio della Gioia a {direzione_gioia}: se puoi, metti da quella parte l'appuntamento che conta.
2. Direzione del giorno: {direzione_gioia}, dove l'almanacco colloca il Dio della Gioia.
3. Il Dio della Gioia oggi sta a {direzione_gioia}, secondo il calendario cinese. Un gesto simbolico: [siediti rivolto da quella parte|siediti rivolta da quella parte|siediti guardando verso quella parte] quando decidi.

Fortuna:
1. L'almanacco pone oggi il Dio della Ricchezza a {direzione_ricchezza}.
2. Direzione della ricchezza oggi: {direzione_ricchezza}, secondo il calendario cinese.
3. Il Dio della Ricchezza, dicono gli almanacchi, oggi sta a {direzione_ricchezza}.

### 4.3 Nota del metodo (una per scheda, col punto interrogativo)

- Generale: "L'animale del giorno è il ramo del giorno nel ciclo dei sessanta; il rapporto col tuo animale viene dalle tabelle del Sanming Tonghui (1578). Il guardiano è uno dei dodici del calendario, contato dal mese solare; il consiglio viene dal solo guardiano, non dall'almanacco intero."
- Fortuna, Lavoro, Amore: "Il tuo giorno di nascita ha un tronco celeste, il giorno di oggi un altro: il loro rapporto fra i cinque elementi dà uno dei Dieci Dei del BaZi. La scheda legge quel dio come lo leggono lo Yuanhai Ziping e il Ziping Zhenquan."
- Tutte: "Colore e numeri sono quelli dell'elemento del giorno nella tradizione, non colori o numeri portafortuna."
