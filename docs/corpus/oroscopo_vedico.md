# Oroscopo vedico del giorno, bozza del corpus (ordine ES, voce 09)

Bozza del 29 settembre 2026, entrata nell'app con l'ordine ES voce 09 e da
rileggere con Mauro: le correzioni si fanno qui e si rigenera con
`python tool/_gen_oroscopo_vedico.py`.
Le regole e le fonti per esteso stanno in `specifiche.md`; qui accanto a ogni
gruppo c'è la regola in una riga e la fonte breve.

## Come si legge questo corpus

- La voce è quella di **Medora**: calda, diretta, concreta. Dice che cosa
  indica il cielo di oggi secondo la tradizione indiana e che cosa conviene
  fare; non promette, non annuncia eventi, non inventa. I verbi sono "conviene",
  "è il giorno adatto per", "prenditi", mai "succederà".
- Si parla sempre a "tu", senza aggettivi che dicano il genere di chi legge.
- I termini sanscriti sono pochi e ogni volta hanno accanto la spiegazione.
  Il glossario è in fondo.
- Fra parentesi graffe i segnaposto che l'app riempie:
  - `{segno_luna}`: il segno in cui transita oggi la Luna, col nome italiano
    (per esempio "nel Cancro");
  - `{casa}`: la casa contata dalla Luna di nascita, in lettere ("quarta");
  - `{nakshatra_oggi}` e `{nakshatra_nascita}`: il nome del nakshatra con la
    traduzione alla prima occorrenza (per esempio "Pushya, il nutrimento");
  - `{pianeta}`, `{colore}`, `{numero}`: il pianeta del giorno, il suo colore e
    il suo numero;
  - `{inizio}` e `{fine}`: gli estremi del Rahu Kalam, ora e minuti;
  - `{luogo}`: la città scelta.
- Per ogni caso ci sono almeno tre varianti. **La variante segue il ritorno
  del caso**, come nell'oroscopo cinese (ordine ES voce 08): ogni volta che la
  stessa casa, la stessa tara o lo stesso giorno della settimana tornano per la
  stessa persona, si legge la variante successiva del gruppo. Una variante
  scelta col solo giorno ripete la stessa frase quando il caso torna con un
  passo multiplo del numero delle varianti (lo ha misurato la Regola A della
  voce ES.08).

## Le tre parti di ogni frase (dal 30 settembre 2026)

Il fondatore, davanti alle letture: *"all'utente non gliene frega un cazzo dei transiti, quante volte devo scriverlo e chiederlo? Vuole sapere come andrà in generale, in amore, in lavoro, ecc. Se vuoi inserire i transiti, li inserisci dopo giusto per motivare da dove arriva la risposta."* E le Linee Guida, sezione 2: la risposta, che cosa puoi fare, da dove viene; *"il simbolo non apre mai"*.

Ogni frase numerata sta su una riga sola e ha due pezzi, separati da ` || `:

```
N. TESTO || DA DOVE VIENE
```

- **TESTO**: la risposta (come va, in parole di tutti i giorni) e che cosa puoi fare (un gesto concreto). Nessun simbolo e nessun termine del metodo.
- **DA DOVE VIENE**: il simbolo e la regola della tradizione. È la sola parte in cui compaiono.

L'app mette il TESTO nella lettura della scheda e il DA DOVE VIENE nella riga "Da dove viene", sotto la lettura. Dove c'è, la riga `Titolo:` di un caso è il nome in parole della scheda. Le frasi di prima, che aprivano col simbolo, stanno nella storia del repository (commit precedenti a questo).

## Come si compongono le quattro schede

- **Generale**: una frase della Chandra Bala (sezione 1), una della Tara Bala
  (sezione 2), la riga del pianeta del giorno (sezione 3) e la riga del Rahu
  Kalam (sezione 7). Dal 30 settembre 2026 la Breve legge la Chandra Bala, la
  Tara Bala e il Rahu Kalam; la Lunga aggiunge la riga del pianeta del giorno.
  Senza l'ora di nascita la Tara Bala non si legge, e lo dice il "da dove
  viene".
- **Amore**, **Lavoro**, **Fortuna**: una frase del caso della scheda
  (sezioni 4, 5 e 6), scelto con la tabella della sezione 6.3 di
  `specifiche.md`. La Lunga aggiunge la variante seguente dello stesso caso
  (un altro gesto) e, nella Fortuna, la riga del pianeta del giorno.
- Il TESTO di ogni frase va nella lettura, il DA DOVE VIENE nella riga "Da
  dove viene" sotto la lettura, insieme alla riga che dice da dove viene il
  livello. I titoli delle schede sono le righe `Titolo:` dei casi.

---

## 1. Chandra Bala: la Luna di oggi contata dalla tua Luna di nascita

Regola: si conta dal segno della Luna di nascita (rashi) a quello della Luna di
oggi, il primo compreso. Favorevoli 1, 3, 6, 7, 10 e 11; di attenzione 2, 5 e 9;
sfavorevoli 4, 8 e 12.
Fonti: Varahamihira, *Brihat Samhita* 104.4 e 104.8-10; Mantreshvara,
*Phaladeepika* 26.2 e 26.12; Drik Panchang, Chandrabalam (60 esiti su 60
verificati).

### Casa 1: la Luna torna nel tuo segno
Fonte: Brihat Samhita 104.8, "pasti, letti e vesti eccellenti"; Phaladeepika
26.12, "nascita di fortuna".
Titolo: Una giornata comoda

1. Oggi è una giornata di agio, in cui stare bene viene facile. Siediti a tavola con calma, vai a letto presto e dedica mezz'ora alla cura del corpo. || Oggi la Luna torna {segno_luna}, dove stava alla tua nascita: nella tradizione indiana è un giorno di pasti, letti e vesti eccellenti.
2. Oggi la giornata ti somiglia: le cose vanno meglio se le fai a modo tuo. Tieni il tuo ritmo senza rincorrere quello degli altri e concediti una comodità vera, anche piccola. || La Luna è di nuovo nel tuo segno di nascita: è la prima casa della Chandra Bala, che la tradizione indiana conta fra le favorevoli.
3. Oggi il benessere sta nelle cose semplici che hai già. Non cercare imprese: cucina un piatto che ti piace e goditi la serata senza aggiungere impegni. || Con la Luna nel tuo segno i testi antichi parlano di benessere semplice, di tavola buona e letto comodo; la Phaladeepika la chiama "nascita di fortuna".

### Casa 2: la Luna sulla casa dei beni
Fonte: Brihat Samhita 104.8, "perdita di beni e ostacoli"; Phaladeepika 26.12,
"perdita di ricchezza"; Drik: di attenzione (Puja Needed).
Titolo: Conta prima di spendere

1. Oggi col denaro conviene andare piano. Rimanda gli acquisti che non ti servono davvero e lascia nel carrello quello che puoi prendere un altro giorno. || Oggi la Luna passa sulla seconda casa dalla tua Luna di nascita, quella dei beni: la tradizione indiana la legge come un giorno di attenzione.
2. Oggi è una giornata da portafoglio chiuso e parole misurate. Prima di pagare controlla il prezzo due volte; prima di rispondere a una provocazione conta fino a tre. || La Luna è nella seconda casa dalla tua Luna di nascita, che la Chandra Bala mette fra le case di attenzione: la Brihat Samhita parla di ostacoli.
3. Oggi i soldi escono più facilmente di come entrano. Non è una condanna: stasera scrivi su un foglio quello che hai speso, voce per voce, per tenere il conto. || Con la Luna in seconda casa la Brihat Samhita parla di beni che scivolano via; la Phaladeepika di perdita di ricchezza.

### Casa 3: la Luna del coraggio
Fonte: Brihat Samhita 104.8, "vesti, affetti e beni in abbondanza";
Phaladeepika 26.12, "successo".
Titolo: Un passo avanti

1. Oggi è un giorno di riuscita, in cui le iniziative vanno in porto. Fai subito quella telefonata che rimandi da una settimana, prima di pranzo. || Oggi la Luna sta nella terza casa dalla tua Luna di nascita: per la tradizione indiana è una delle case favorevoli, quella del successo.
2. Oggi le iniziative piccole hanno slancio: il passo corto arriva lontano. Scrivi quel messaggio, fai la tua proposta, muoviti di persona invece di aspettare. || La Luna in terza casa, contata dalla tua Luna di nascita, dà forza alle iniziative: la Phaladeepika la riassume in una parola, "successo".
3. Oggi è un giorno in cui le cose belle sono a portata di mano. Approfittane per cominciare qualcosa di concreto: il primo foglio di un progetto, il primo giorno di un'abitudine. || Con la Luna nella terza casa i testi antichi parlano di successo e di vesti, affetti e beni in abbondanza.

### Casa 4: la Luna inquieta
Fonte: Brihat Samhita 104.8 (il nativo è "crudele come un serpente", cioè
irrequieto e pungente); Phaladeepika 26.12, "paura".
Titolo: Nervi scoperti

1. Oggi è una giornata inquieta, coi nervi più scoperti del solito. Non è colpa di nessuno: rallenta, togli un impegno dall'agenda e prenditi dieci minuti di silenzio. || Oggi la Luna passa sulla quarta casa dalla tua Luna di nascita, che la tradizione indiana legge come un giorno di inquietudine.
2. Oggi basta poco per irritarti o per pungere chi ti sta vicino. Evita le discussioni in famiglia e rimanda le decisioni che riguardano il posto dove abiti. || La Luna in quarta casa dalla tua Luna di nascita è fra le sfavorevoli: la Brihat Samhita dice che rende irrequieti e pungenti come un serpente.
3. Oggi qualche timore si fa sentire più del dovuto. Tieniti stretto ciò che ti dà sicurezza, una persona o un'abitudine, lasciando le novità a domani. || Con la Luna nella quarta casa i testi antichi parlano di timori: la Phaladeepika la riassume nella parola "paura".

### Casa 5: la Luna stanca
Fonte: Brihat Samhita 104.9, "umiliazione, malanni e ostacoli"; Phaladeepika
26.12, "dolore"; Drik: di attenzione.
Titolo: Chiediti di meno

1. Oggi la giornata è in salita: tutto costa un po' più fatica. Non chiederti troppo: scegli le due cose che contano e cancella la terza dalla lista. || Oggi la Luna è nella quinta casa dalla tua Luna di nascita: la tradizione indiana la legge come una casa di attenzione, fatta di ostacoli.
2. Oggi può farsi sentire un po' di malinconia. Fai meno cose e falle bene: quello che resta può aspettare fino a domani. Stasera fermati prima del solito. || La Luna in quinta casa dalla tua Luna di nascita porta, secondo la Phaladeepika, "dolore"; il Drik Panchang la segna come giorno di attenzione.
3. Oggi gli ostacoli sono più facili da incontrare che da saltare. Non metterti alla prova: rimanda la gara o il confronto che puoi spostare e tieni le forze per i giorni migliori. || Con la Luna nella quinta casa dalla tua Luna di nascita la Brihat Samhita parla di umiliazione e di ostacoli.

### Casa 6: la Luna che vince
Fonte: Brihat Samhita 104.9, "ricchezza, agio e rovina dei nemici";
Phaladeepika 26.12, "libertà dalla malattia".
Titolo: Gli intoppi si sciolgono

1. Oggi gli intoppi si superano più facilmente del solito. Affronta la pratica che ti pesa: apri quel modulo, fai quella fila, chiudi la faccenda entro sera. || Oggi la Luna passa sulla sesta casa dalla tua Luna di nascita: per la tradizione indiana è il giorno in cui si superano gli intoppi.
2. Oggi hai più forza del solito, nel corpo e nella testa. Usala per muoverti: una camminata lunga, le scale a piedi, l'abitudine buona che avevi lasciato a metà. || La Luna in sesta casa dalla tua Luna di nascita è fra le favorevoli: la tradizione indiana dice che dà forza al corpo e alla testa.
3. Oggi chi ti sta contro ha meno presa e tu hai più calma. Se hai un conto in sospeso con qualcuno, chiudilo oggi con due righe scritte senza rabbia. || Con la Luna nella sesta casa i testi antichi parlano di avversari che perdono terreno: la Brihat Samhita dice "rovina dei nemici".

### Casa 7: la Luna dell'incontro
Fonte: Brihat Samhita 104.9, "ricchezza e rispetto"; Phaladeepika 26.12,
"felicità".
Titolo: In buona compagnia

1. Oggi è un buon giorno per stare con gli altri: incontrare, accordarsi, fare compagnia. Fissa l'appuntamento che tieni in sospeso o invita qualcuno a pranzo. || Oggi la Luna è nella settima casa dalla tua Luna di nascita, quella dell'altro: la tradizione indiana la dà favorevole.
2. Oggi trovi rispetto e buona accoglienza in chi hai davanti. Cerca le persone invece di scrivere da lontano: parla a voce della cosa che ti preme, oggi ti ascoltano. || La Luna in settima casa dalla tua Luna di nascita porta, secondo la Brihat Samhita, "ricchezza e rispetto".
3. Oggi la contentezza è più grande se la dividi con qualcuno. Organizza qualcosa con chi ami o con chi lavori: una cena, una pausa insieme, un progetto a quattro mani. || Con la Luna nella settima casa i testi parlano di felicità condivisa: "felicità" è la parola che la Phaladeepika usa per questo giorno.

### Casa 8: Chandrashtama, la Luna in ottava
Fonte: Brihat Samhita 104.9, "paura dei mali"; Phaladeepika 26.12, "eventi
avversi"; Raman, *Muhurtha* cap. III, fra le case da evitare. Il nome proprio
è Chandrashtama, "la Luna nell'ottava".
Titolo: Senza forzare niente

1. Oggi è una giornata da dedicare alla calma. Niente decisioni grandi e niente firme importanti: sposta a un altro giorno quello che può aspettare e tieni l'agenda leggera. || Oggi la Luna passa sull'ottava casa dalla tua Luna di nascita. In India questo giorno ha un nome, Chandrashtama, "la Luna nell'ottava".
2. Oggi non è un giorno cattivo: è un giorno da non forzare. Fai le cose ordinarie e falle con cura, una alla volta, senza aggiungere niente di nuovo alla lista. || È il tuo giorno di Chandrashtama, la Luna nell'ottava casa dalla tua Luna di nascita, che il Muhurtha di Raman mette fra le case da evitare.
3. Oggi è una giornata delicata, da attraversare piano. Vai a dormire presto, mangia leggero e rimanda a un altro giorno i confronti che possono aspettare. || La Luna in ottava casa è, per la tradizione indiana, il momento più delicato del suo giro intorno alla tua Luna di nascita.

### Casa 9: la Luna lontana
Fonte: Brihat Samhita 104.10, "prigionia e dolore"; Phaladeepika 26.12,
"malattia"; Drik: di attenzione.
Titolo: Piani semplici

1. Oggi la giornata è un po' stretta: qualcosa può trattenerti. Non strattonare: se una risposta tarda o una porta non si apre, aspetta che passi e riprova domani. || Oggi la Luna è nella nona casa dalla tua Luna di nascita: la tradizione indiana la legge come un giorno di attenzione, in cui ci si sente trattenuti.
2. Oggi le forze sono più corte del solito e vanno risparmiate. Non stancarti: togli un impegno dalla giornata e sposta il viaggio che può essere spostato. || La Luna in nona casa dalla tua Luna di nascita chiede riguardo per il corpo: il Drik Panchang la segna fra i giorni di attenzione.
3. Oggi è più facile trovare un impedimento sulla strada. Tieni i piani semplici: una cosa al mattino, una al pomeriggio, niente incastri stretti fra un impegno e l'altro. || Con la Luna nella nona casa dalla tua Luna di nascita i testi antichi parlano di impedimenti; la Brihat Samhita usa la parola "prigionia".

### Casa 10: la Luna che fa
Fonte: Brihat Samhita 104.10, "gli ordini saranno eseguiti, successo nel
lavoro"; Phaladeepika 26.12, "desideri realizzati".
Titolo: Il giorno del fare

1. Oggi quello che chiedi ha buone probabilità di essere fatto. Allora chiedilo: scrivi adesso la richiesta che tieni in sospeso, con parole chiare e una data. || Oggi la Luna passa sulla decima casa dalla tua Luna di nascita, quella dell'azione: la Brihat Samhita dice che "gli ordini saranno eseguiti".
2. Oggi il lavoro e il tuo buon nome hanno un sostegno in più. Porta avanti il progetto che conta di più: dagli le ore migliori della mattina, prima di tutto il resto. || La Luna in decima casa dalla tua Luna di nascita sostiene il lavoro e la reputazione: la tradizione indiana la conta fra le case favorevoli.
3. Oggi i desideri trovano strada più facilmente, se li tratti da cose da fare. Scegline uno concreto, scrivilo su un foglio e dagli la giornata intera. || Con la Luna nella decima casa la Phaladeepika parla di "desideri realizzati"; la Brihat Samhita di successo nel lavoro.

### Casa 11: la Luna dei guadagni
Fonte: Brihat Samhita 104.10, "prosperità e amicizie nuove"; Phaladeepika
26.12, "gioia".
Titolo: Tempo di raccolto

1. Oggi è una delle giornate migliori: si raccoglie quello che si è seminato. Vai a prendere ciò che ti spetta: un grazie, una risposta, un lavoro finito da consegnare. || Oggi la Luna è nell'undicesima casa dalla tua Luna di nascita, quella dei frutti: la tradizione indiana la dà tra le migliori.
2. Oggi è una giornata buona per le amicizie e per le notizie. Rispondi ai messaggi rimasti in sospeso e accetta l'invito che ti fanno, anche se avevi altri programmi. || La Luna in undicesima casa dalla tua Luna di nascita porta, secondo la Brihat Samhita, "prosperità e amicizie nuove".
3. Oggi è un giorno pieno e allegro, da vivere con le porte aperte. Esci, fatti trovare e rispondi di sì a chi ti propone qualcosa da fare insieme. || Con la Luna nell'undicesima casa i testi antichi parlano di prosperità e di gioia: "gioia" è la parola della Phaladeepika.

### Casa 12: la Luna che spende
Fonte: Brihat Samhita 104.10 (ferite); Phaladeepika 26.12, "spesa".
Titolo: Non disperdere le forze

1. Oggi è facile disperdere: tempo, soldi, forze. Scegli una cosa sola da portare a termine e lascia chiuso il resto, portafoglio compreso. || Oggi la Luna passa sulla dodicesima casa dalla tua Luna di nascita, quella delle uscite: la tradizione indiana la conta fra le sfavorevoli.
2. Oggi pesano la stanchezza e le spese. Ritirati un po': salta l'uscita che non ti va, spegni il telefono per un'ora e ricaricati. È una stanchezza che passa presto. || La Luna in dodicesima casa dalla tua Luna di nascita porta stanchezza e spese: "spesa" è la parola della Phaladeepika.
3. Oggi qualcosa se ne va: meglio scegliere tu che cosa. Lascia andare il superfluo, un impegno inutile o una spesa di troppo, tenendo stretto l'essenziale. || Con la Luna nella dodicesima casa dalla tua Luna di nascita i testi parlano di ciò che se ne va.

---

## 2. Tara Bala: la stella di oggi contata dalla tua stella di nascita

Regola: si conta dal nakshatra di nascita a quello di oggi, il primo compreso,
e si divide per nove; il resto (col nove al posto dello zero) dà la tara.
Fonti: B. V. Raman, *Muhurtha*, cap. III; Drik Panchang, Tarabalam (216 esiti
su 216 verificati).

### Tara 1, Janma: la tua stessa stella
Raman: "danger to body"; Drik: Not Good. Raman aggiunge che è buona per
seminare, comprare terre e cominciare a studiare.

1. È una giornata per il corpo, non per le sfide. Riguardati: vai piano, mangia a orari regolari e lascia a un altro giorno le prove di forza. || Oggi la Luna è nella tua stella di nascita, {nakshatra_nascita}: la tradizione indiana chiama questo giorno Janma, "la nascita".
2. È un giorno per seminare e per imparare, meno per mettersi in viaggio o in una contesa. Pianta qualcosa, apri un libro nuovo e rimanda la partenza che può aspettare. || La Luna torna sulla tua stella, {nakshatra_nascita}: è la tara Janma, che Raman dà buona per seminare e cominciare a studiare, non per il resto.
3. Conviene tenere la giornata per te e per la testa. Comincia uno studio, anche solo con la prima pagina di un corso. Se qualcuno vuole aprire una discussione, lasciala cadere. || È il tuo giorno di Janma, la Luna sulla stella della tua nascita: nella Tara Bala è la prima delle nove, buona per cominciare a studiare.

### Tara 2, Sampat: la ricchezza
Raman: "wealth and prosperity"; Drik: Very Good.

1. È un buon giorno per occuparti dei tuoi beni e delle tue entrate. Metti in ordine i conti del mese o manda la richiesta di un pagamento che ti spetta. || La stella di oggi, {nakshatra_oggi}, è per te Sampat, "la ricchezza": è la seconda contata dalla tua, che il Drik Panchang dà molto buona.
2. Col denaro puoi fare i tuoi passi, purché con giudizio. Sistema una spesa che avevi già deciso con calma e tieni nota di quanto esce. || Oggi la stella della Luna ti è amica: è Sampat, la seconda dalla tua stella di nascita, che la tradizione indiana dà propizia.
3. Conviene fare i passi che fanno crescere quello che hai. Presenta un'offerta, apri una trattativa o dedica un'ora piena a un progetto che può rendere. || Sampat è la stella della prosperità: nella Tara Bala di Raman e del Drik Panchang è uno dei giorni più propizi dei nove.

### Tara 3, Vipat: il pericolo
Raman: "dangers, losses and accidents"; Drik: Bad.

1. Non c'è da spaventarsi, basta un po' di attenzione in più. Guarda dove metti i piedi, in strada come sulle scale; tieni vicino a te gli oggetti di valore. || La stella di oggi, {nakshatra_oggi}, è per te Vipat, "il pericolo": la terza contata dalla tua, che la tradizione indiana chiede di attraversare con attenzione.
2. Conviene controllare due volte le cose che si perdono o si sbagliano in fretta. Prima di uscire guarda chiavi e documenti; prima di pagare rileggi la cifra e il destinatario. || Oggi la tradizione indiana ti dà Vipat, la stella delle perdite: nella Tara Bala è la terza delle nove.
3. Meglio muoversi piano e senza fretta. Rimanda il viaggio lungo e l'impegno rischioso che puoi spostare, tenendo per oggi solo i tragitti di sempre. || Con Vipat, la terza tara, Raman consiglia di evitare le cose importanti; il Drik Panchang la segna fra i giorni sfavorevoli.

### Tara 4, Kshema: il benessere
Raman: "prosperity"; Drik: Good.

1. È una giornata che sostiene. Usala per ciò che ti fa stare bene: una passeggiata, un pranzo fatto con calma, un'ora per la cosa che ti piace di più. || La stella di oggi, {nakshatra_oggi}, è per te Kshema, "il benessere": la quarta contata dalla tua, che la tradizione indiana dà buona.
2. Buon giorno per partire, per sistemare e per stare bene con gli altri. Mettiti in viaggio se devi, ripara quello che aspetta da tempo o passa a salutare qualcuno. || Oggi hai Kshema, la stella della prosperità tranquilla: nella Tara Bala è la quarta delle nove, fra quelle favorevoli.
3. Non serve strafare: basta fare bene quello che hai davanti. Prendi il primo compito della lista e finiscilo con cura prima di passare al secondo. || Con Kshema, la quarta tara, la tradizione indiana vede un giorno sereno; Raman la lega alla prosperità.

### Tara 5, Pratyak: l'ostacolo
Raman: "obstacles"; Drik: Not Good (la chiama Pratyari).

1. Metti in conto qualche intoppo e lascia margine nei tuoi orari. Parti un quarto d'ora prima e non fissare due appuntamenti uno attaccato all'altro. || La stella di oggi, {nakshatra_oggi}, è per te Pratyak, "l'ostacolo": la quinta contata dalla tua, che la tradizione indiana non dà favorevole.
2. Le cose chiedono più tempo del previsto: non è un no, è un "non ancora". Se una risposta tarda non sollecitare oggi, segna sul calendario di richiederla fra due giorni. || Oggi hai Pratyak, la quinta delle nove tare: nella Tara Bala è la stella che rallenta, quella che Raman chiama degli ostacoli.
3. Conviene non incaponirsi. Se una porta resta chiusa dopo due tentativi, lascia stare, passa a un'altra faccenda e riprova domani a mente fresca. || Con Pratyak, la stella dell'ostacolo, la Tara Bala segna un giorno poco favorevole: è la quinta contata dalla tua stella di nascita.

### Tara 6, Sadhana: la riuscita
Raman: "realisation of ambitions"; Drik: Very Good (la chiama Sadhaka).

1. È un giorno in cui gli sforzi vanno a buon fine. Riprendi il lavoro che ti costa più fatica e spingilo fino al punto in cui si vede il risultato. || La stella di oggi, {nakshatra_oggi}, è per te Sadhana, "la riuscita": la sesta contata dalla tua, per la tradizione indiana fra le più favorevoli.
2. È il giorno adatto per lavorare al tuo obiettivo più caro. Dagli almeno un'ora vera, col telefono lontano e senza fare altro nel frattempo. || Oggi hai Sadhana, la sesta delle nove tare: Raman la lega alla realizzazione delle ambizioni, il Drik Panchang la dà molto buona.
3. I propositi trovano strada, se non li disperdi. Scegli una cosa sola e portala a termine prima di sera, anche piccola, senza cominciarne una seconda. || Con Sadhana, la stella della riuscita, la Tara Bala segna uno dei giorni migliori dei nove: è la sesta contata dalla tua stella di nascita.

### Tara 7, Naidhana: la fine
Raman: "dangers", da evitare per le imprese importanti; Drik: Totally Bad.

1. Non è il giorno per cominciare qualcosa di grande: custodisci quello che c'è. Fai la manutenzione di una cosa che hai già: un lavoro, un rapporto, un oggetto da riparare. || La stella di oggi, {nakshatra_oggi}, è per te Naidhana, la settima contata dalla tua: la tradizione indiana la considera la più delicata delle nove.
2. Meglio non aprire cose nuove e chiudere bene quelle vecchie. Finisci un lavoro lasciato a metà, rispondi a una lettera in sospeso, riordina un cassetto. || Oggi hai Naidhana, "la fine". Non è un presagio: nella Tara Bala è il giorno che la tradizione indiana lascia alle chiusure, non agli inizi.
3. Conviene la prudenza piena. Rimanda di qualche giorno le firme, i viaggi e le decisioni che non hanno fretta; tieni per oggi solo gli impegni di sempre. || Con Naidhana, la settima tara, Raman sconsiglia le imprese importanti; il Drik Panchang la segna come il giorno meno adatto dei nove.

### Tara 8, Mitra: l'amico
Raman: "good"; Drik: Good.

1. È un buon giorno per chiedere aiuto e per darne. Chiama la persona che può darti una mano e offri tu un favore a chi te lo ha chiesto da tempo. || La stella di oggi, {nakshatra_oggi}, è per te Mitra, "l'amico": l'ottava contata dalla tua, che la tradizione indiana dà buona.
2. Le persone ti vengono incontro più volentieri. Cerca un alleato per quello che non riesci a fare senza aiuto: spiegagli il problema in due righe e chiedigli un parere. || Oggi hai Mitra, l'ottava delle nove tare: nella Tara Bala è la stella amica, che Raman e il Drik Panchang danno buona.
3. Conviene dedicare tempo alle amicizie che trascuri. Scrivi a chi non senti da mesi e proponi un caffè in settimana, con un giorno e un'ora precisi. || Con Mitra, la stella dell'amico, la tradizione indiana vede un cielo amico: è l'ottava contata dalla tua stella di nascita.

### Tara 9, Parama Mitra: il grande amico
Raman: "very favourable"; Drik: Good.

1. È una giornata che ti dà una mano in quasi tutto. Non sprecarla in faccende minori: sbriga per prima la cosa più difficile che hai in lista. || La stella di oggi, {nakshatra_oggi}, è per te Parama Mitra, "il grande amico": per Raman è la più favorevole delle nove.
2. Buon giorno per le cose a cui tieni davvero. Scegline una, quella che rimandi per paura di rovinarla: dedicale il pomeriggio senza farti interrompere. || Oggi hai Parama Mitra, la nona contata dalla tua stella di nascita: nella Tara Bala il cielo ti è amico fino in fondo.
3. Conviene osare un poco. Fai la richiesta che rimandi, a voce e senza giri di parole: un sì da chiedere, un incontro da proporre, un permesso da ottenere. || Con Parama Mitra, la nona e ultima tara, la tradizione indiana dà la giornata per propizia: Raman la dice molto favorevole.

---

## 3. Il pianeta del giorno (vara)

Regola: il giorno della settimana prende il nome dal pianeta che lo governa.
Colori: Varahamihira, *Brihat Jataka* 2.5. Numeri: numerologia indiana
moderna (Cheiro 1926, con Rahu e Ketu al posto di Urano e Nettuno). Da dire
nella nota del metodo: il numero non viene dai testi antichi.

### Una riga per ogni giorno

- **Domenica**: Oggi è un buon giorno per farti vedere. Proponi la tua idea, presenta un lavoro finito o prendi la parola dove di solito taci. || Oggi è Ravivara, il giorno del Sole. Il suo colore è il rosso, il suo numero l'uno.
- **Lunedì**: Oggi conviene ascoltare più che parlare. Chiama una persona cara e lasciala raccontare fino in fondo, senza interromperla. || Oggi è Somavara, il giorno della Luna. Il suo colore è il bianco, il suo numero il due.
- **Martedì**: Oggi è un giorno per agire con decisione. Prendi la cosa che rimandi da giorni e chiudila entro stasera, senza ripensarci. || Oggi è Mangalavara, il giorno di Marte. Il suo colore è il rosso, il suo numero il nove.
- **Mercoledì**: Oggi vanno bene le parole: parlare, scrivere, trattare. Manda il messaggio che tieni in sospeso o discuti un prezzo che ti sembra alto. || Oggi è Budhavara, il giorno di Mercurio. Il suo colore è il verde, il suo numero il cinque.
- **Giovedì**: Oggi è un giorno per imparare e per consigliare. Leggi qualche pagina su ciò che vuoi capire o dai il tuo parere a chi te lo chiede. || Oggi è Guruvara, il giorno di Giove. Il suo colore è il giallo, il suo numero il tre.
- **Venerdì**: Oggi è un giorno per la bellezza e per gli affetti. Metti un fiore in casa, cura un dettaglio del tuo aspetto o invita a cena chi ami. || Oggi è Shukravara, il giorno di Venere. Il suo colore è lo screziato, il suo numero il sei.
- **Sabato**: Oggi è un giorno per la pazienza e per il lavoro lento. Scegli un compito lungo, come riordinare le carte di casa: portalo avanti senza fretta. || Oggi è Shanivara, il giorno di Saturno. Il suo colore è il nero, il suo numero l'otto.

(I colori di venerdì e sabato sono quelli del testo; se Mauro sceglie il
bianco e il blu della pratica popolare, cambiano qui e nella nota del metodo.)

### Varianti generiche della stessa riga

1. Oggi hai un colore e un numero che ti accompagnano. Indossa un capo che porti il {colore}; quando ti serve una cifra da scegliere, prendi il {numero}. || Oggi governa {pianeta}: nella settimana indiana ogni giorno ha il suo pianeta, che dà alla giornata un colore e un numero.
2. Se vuoi un segno da portare con te oggi, scegli il {colore}: basta un oggetto piccolo da tenere in tasca o in borsa. Il numero della giornata è il {numero}. || Il giorno è di {pianeta}: nella settimana indiana il colore e il numero di oggi sono i suoi.
3. Oggi il {colore} è il colore da tenere sotto gli occhi: mettilo sulla tavola o sulla scrivania. Se ti serve un numero per decidere, usa il {numero}. || Nella settimana indiana oggi è il giorno di {pianeta}, che ha un colore e un numero suoi.

---

## 4. Scheda Amore (settima e quinta casa dalla Luna di nascita)

Regola: la settima è la casa dell'unione e del coniuge (BPHS 11.8, "Wife");
la quinta è letta qui come il cuore che si apre (lettura moderna: nel BPHS 11.6
è la casa dei figli e del sapere). Caso scelto con la tabella di
`specifiche.md` 6.3.

### La Luna nella settima (h = 7)
Chandra Bala favorevole; la Luna attraversa la casa dell'unione.
Titolo: Vicino a chi ami

1. Oggi in amore la vicinanza viene facile. Passa del tempo accanto a chi ami e confida una cosa vera, anche piccola, che di solito tieni per te. || Oggi la Luna attraversa la settima casa dalla tua Luna di nascita, quella dell'unione: per la tradizione indiana è un passaggio favorevole.
2. È un buon giorno per i legami, quelli che hai e quelli che possono nascere. Se sei in coppia proponi una cosa da fare in due stasera; se non lo sei esci e accetta un invito. || La Luna è nella settima casa contata dalla tua Luna di nascita, che i testi indiani chiamano la casa del legame e del coniuge.
3. In amore oggi c'è più rispetto del solito e stare insieme viene naturale. Lascia finire di parlare chi hai davanti, poi fai una domanda in più prima di dire la tua. || Con la Luna nella settima casa, quella dell'unione, la tradizione indiana vede rispetto e felicità condivisa: è una Chandra Bala favorevole.

### La Luna nella quinta (h = 5)
Casa del cuore, ma la Chandra Bala è di attenzione: emozioni forti e un po'
di stanchezza.
Fonte (ordine EV, verifica dell'Architetto, da V-G-089 a V-G-091): la Luna
in quinta dalla Luna di nascita non è fra le posizioni buone del gochara
(Phaladeepika, cap. 26; Brihat Samhita, cap. 104); la quinta come cuore è la
lettura moderna dichiarata dalla nota del metodo.
Titolo: Un gesto tenero

1. Oggi in amore le emozioni sono vive ma fragili, le tue comprese. Trattale con dolcezza: abbassa la voce e prenditi dieci minuti di quiete prima di parlare di cose serie. || Oggi la Luna passa sulla quinta casa dalla tua Luna di nascita, letta qui come quella del cuore; la Chandra Bala però è di attenzione.
2. Per l'amore la giornata è un po' faticosa e i discorsi lunghi stancano. Scegli un gesto tenero al posto delle parole: prepara qualcosa di buono, fai una carezza, lascia un biglietto. || La Luna è nella quinta casa contata dalla tua Luna di nascita, la casa dei sentimenti, in un giorno che la tradizione indiana dà per faticoso.
3. Oggi il cuore si apre volentieri ma regge poco le cose pesanti. Punta sulla leggerezza: proponi un gioco, una passeggiata breve o una serata a ridere di niente. || Con la Luna in quinta casa, letta come il cuore che si apre, la Chandra Bala è di attenzione: emozioni forti e un po' di stanchezza.

### La Luna nel tuo segno guarda la settima (h = 1)
La Luna guarda per intero la settima casa da sé (BPHS 26.2-5).
Titolo: Dai tu il tono

1. Oggi in amore sei tu a dare il tono alla giornata. Se porti calma è più facile che ne torni indietro: comincia con un saluto gentile e una voce bassa, anche se la mattina parte storta. || Oggi la Luna è nel tuo segno di nascita e da lì guarda dritta la settima casa, quella dell'unione: nei testi indiani la Luna guarda per intero la settima da sé.
2. È un buon giorno per farti avanti in amore, senza giri di parole. Scrivi tu il primo messaggio, proponi un caffè o spiega con semplicità che ti farebbe piacere vedervi. || La Luna sta nel tuo segno di nascita e guarda la tua settima casa, la casa del legame (BPHS 26.2-5).
3. In amore oggi è più facile ricevere attenzioni che doverle inseguire. Lasciati trovare: rispondi a chi ti scrive, resta un po' di più dove c'è gente, tieni il telefono a portata di mano. || Con la Luna nel tuo segno di nascita il suo sguardo cade sulla settima casa, quella dell'altro: per la tradizione indiana l'attenzione altrui ti cerca.

### La Luna nell'undicesima guarda la quinta (h = 11)
La Luna in una casa favorevole guarda la casa del cuore.
Fonte (ordine EV, verifica dell'Architetto, da V-G-095 a V-G-097): la Luna
in undicesima è fra le posizioni buone del gochara (Phaladeepika, cap. 26);
ogni pianeta guarda per intero la settima casa da sé, quindi dall'undicesima
guarda la quinta (Brihat Parashara Hora Shastra, cap. 26).
Titolo: Un invito fra amici

1. Oggi un affetto può nascere o rinascere in mezzo alle amicizie. Passa la serata con gli amici e fai caso a chi ti fa stare bene: una chiacchierata a due vale la pena. || Oggi la Luna sta nell'undicesima casa dalla tua Luna di nascita, quella delle amicizie: da lì guarda la quinta, la casa del cuore.
2. In amore oggi le cose piccole riescono bene. Fai un invito semplice, un gelato, due passi, un film: conta più il gesto di chiedere che il programma. || La Luna guarda la tua quinta casa, letta come il cuore che si apre, da un posto favorevole della Chandra Bala.
3. Oggi l'amore ha un'aria allegra. Condividi una bella notizia o una cosa che ti ha fatto ridere con chi ti fa battere il cuore, meglio con una telefonata che con un messaggio. || Con la Luna nell'undicesima casa la tradizione indiana vede gioia; da lì il suo sguardo arriva sulla quinta, la casa del cuore.

### Favorevole (h = 3, 6, 10)
Titolo: Un cuore sereno

1. Oggi in amore non ci sono scosse: il cuore è sereno. Coltiva quello che c'è già, con una cena fatta con calma o mezz'ora senza telefono insieme a chi ti è caro. || Oggi la Luna non tocca le case dell'amore, la settima e la quinta, ma sta in un posto favorevole della Chandra Bala.
2. Per l'amore è una giornata tranquilla e buona. Basta poco per renderla migliore: manda un messaggio affettuoso a metà giornata, senza aspettare un'occasione. || La Luna transita in una casa favorevole contata dalla tua Luna di nascita, lontana dalla settima e dalla quinta che parlano d'amore.
3. In amore oggi non ci sono grandi novità, solo un clima buono. Approfittane per stare bene insieme: proponi una cosa semplice che vi piace, senza programmi complicati. || La Chandra Bala di oggi è favorevole: la Luna sostiene la giornata senza passare sulle case dell'unione e del cuore.

### Di attenzione (h = 2, 9)
Titolo: Parole morbide

1. Oggi in amore le parole pesano più del solito. Evita quelle taglienti: prima di mandare un messaggio scritto di getto rileggilo e togli la frase che punge. || Oggi la Luna sta in una casa che la tradizione indiana chiede di trattare con cura: la Chandra Bala è di attenzione.
2. Per il cuore è un giorno da maneggiare piano. Se nasce una discussione non portarla fino in fondo: proponi di riparlarne domani e cambia stanza o argomento. || La Luna transita in una delle case che la Chandra Bala dà di attenzione, contate dalla tua Luna di nascita.
3. In amore oggi i chiarimenti riescono male e spiegarsi stanca. Meglio un abbraccio che una spiegazione: resta vicino in silenzio e tieni il discorso per un altro giorno. || Il cielo di oggi non favorisce i chiarimenti: la Luna è in una casa di attenzione rispetto alla tua Luna di nascita.

### Sfavorevole (h = 4, 12)
Titolo: Prenditi un momento

1. Oggi in amore potresti sentire distanza o poca comprensione. Non decidere nulla sulla coppia in queste ore: scrivi quello che pensi su un foglio e riguardalo fra due giorni. || Oggi la Luna è in una casa sfavorevole contata dalla tua Luna di nascita, una delle tre che la Chandra Bala sconsiglia.
2. In amore oggi hai la pelle sottile e basta poco per restarci male. Chiedi con parole semplici quello che ti serve, una cosa sola, senza pretendere una risposta subito. || La Luna passa in una casa che la tradizione indiana dà per sfavorevole nel conto della Chandra Bala, fatto dalla tua Luna di nascita.
3. Per il cuore oggi tutto sembra più pesante di quello che è. Prima di cercare l'altra persona prenditi un momento per te: una doccia calda, una camminata, mezz'ora di musica. || Il cielo di oggi appesantisce: la Luna sta in una casa sfavorevole rispetto alla tua Luna di nascita.

### Chandrashtama, la Luna in ottava (h = 8)
Titolo: Niente prove oggi

1. Oggi in amore non è il momento delle prove né delle domande grandi. Tieni la giornata semplice: parla delle cose di tutti i giorni e lascia il discorso importante a un'altra sera. || Oggi è il tuo giorno di Chandrashtama: la Luna passa nell'ottava casa dalla tua Luna di nascita, il momento più delicato del suo giro.
2. In amore oggi conviene la calma, perché le reazioni a caldo escono più dure del voluto. Se qualcosa ti ferisce non rispondere subito: dormici sopra e riprendi il filo domani. || Con la Luna nell'ottava casa dalla tua Luna di nascita, che in India ha il nome di Chandrashtama, la tradizione indiana consiglia calma.
3. È un giorno delicato per il cuore, da passare al riparo. Stai con chi ti fa sentire al sicuro, anche solo per una cena tranquilla, lasciando fuori il resto fino a domani. || La Luna è in ottava rispetto alla tua Luna di nascita: è Chandrashtama, un giorno che la tradizione indiana chiede di non forzare.

---

## 5. Scheda Lavoro (decima casa dalla Luna di nascita)

Regola: la decima è la casa della professione e dell'autorità (BPHS 11.11,
"profession (livelihood), honour"); con la Luna in decima "gli ordini saranno
eseguiti, successo nel lavoro" (Brihat Samhita 104.10).

### La Luna nella decima (h = 10)
Titolo: Il giorno per chiedere

1. Oggi nel lavoro è il giorno adatto per presentare, chiedere, decidere. Prendi la decisione che tieni ferma da giorni e comunicala entro sera a chi deve saperla. || Oggi la Luna attraversa la decima casa dalla tua Luna di nascita, quella della professione e dell'autorità.
2. Al lavoro oggi è più facile che una richiesta trovi ascolto. Fai la proposta che hai in mente: scrivila in poche righe chiare e mandala a chi può dire di sì. || La Luna è nella casa della professione: con la Luna in decima la Brihat Samhita dice che gli ordini saranno eseguiti, con successo nel lavoro.
3. Oggi quello che fai al lavoro si nota. Metti il meglio dove guardano gli altri: cura la cosa che consegni, la mail che firmi, l'intervento in riunione. || Con la Luna in decima casa, quella che i testi indiani legano alla professione e all'onore, il lavoro viene in luce.

### La Luna nella quarta guarda la decima (h = 4)
La Luna guarda la casa del lavoro da una casa sfavorevole.
Titolo: Prima l'ordinario

1. Oggi al lavoro la testa va spesso alle cose di famiglia e la concentrazione viene a tratti. Sbriga le faccende ordinarie, quelle che sai fare a occhi chiusi, rimandando a domani l'avvio di quelle nuove. || Oggi la Luna guarda la decima casa, quella del lavoro, dalla quarta, la casa delle radici: una posizione che la Chandra Bala dà per sfavorevole.
2. Nel lavoro oggi c'è un po' di inquietudine e basta poco per irrigidirsi. Evita gli scontri con chi sta sopra di te: se una richiesta ti irrita prendi nota e rispondi dopo pranzo. || La Luna tiene lo sguardo sulla casa del lavoro, ma da un posto inquieto: la quarta casa dalla tua Luna di nascita.
3. Oggi il lavoro chiede ordine più che slancio. Riordina la scrivania, svuota la posta arretrata, sistema l'agenda della settimana: così domani riparti da un tavolo pulito. || Con la Luna in quarta casa lo sguardo cade sulla decima, la casa della professione, ma la posizione è fra quelle sfavorevoli della Chandra Bala.

### Favorevole (h = 1, 3, 6, 7, 11)
Titolo: Il lavoro scorre

1. Oggi il lavoro scorre meglio del solito. Porta avanti le pratiche aperte: riprendi quella ferma da più tempo e falle fare un passo, una telefonata o un invio. || Per il lavoro il cielo di oggi è buono: la Luna transita in una casa favorevole contata dalla tua Luna di nascita.
2. Al lavoro oggi è un buon giorno per fare insieme. Chiedi una mano a chi lavora con te sul punto che ti blocca oppure fissa l'incontro per chiudere l'accordo rimasto a metà. || La Luna sta in un posto favorevole della Chandra Bala, la forza della Luna contata dalla tua Luna di nascita.
3. La giornata di lavoro oggi trova una strada liscia: peccato sprecarla in cose minori. Scegli la cosa più importante della tua lista e dedicale le prime due ore, prima di aprire la posta. || La Luna di oggi è in una delle case favorevoli rispetto alla tua Luna di nascita, anche se non tocca la decima, quella della professione.

### Di attenzione (h = 2, 5, 9)
Titolo: Cura nei dettagli

1. Oggi al lavoro gli errori di distrazione sono più facili. Ricontrolla cifre, date e destinatari prima di inviare: rileggi una volta in più il documento che conta. || La Luna transita in una casa che la Chandra Bala dà di attenzione, contata dalla tua Luna di nascita.
2. Nel lavoro oggi la fretta costa cara e i dettagli contano. Meglio un'ora in più che un errore da rifare: fai una cosa alla volta e chiedi a qualcuno di rileggere con te. || Il cielo di oggi chiede cura: la Luna è in una posizione di attenzione rispetto alla tua Luna di nascita.
3. Oggi non è il giorno delle grandi mosse professionali. Consolida quello che hai: chiudi un lavoro lasciato a metà, aggiorna un cliente, metti al sicuro i file importanti. || Nella Chandra Bala la Luna di oggi cade in una delle tre case di attenzione, quelle da trattare con prudenza.

### Sfavorevole (h = 12)
Titolo: Lavora in silenzio

1. Oggi al lavoro può sembrarti che nessuno noti quello che fai. Lavora in silenzio senza cercare conferme: porta a termine il tuo compito e annota il risultato per quando serve. || Oggi la Luna è nella dodicesima casa dalla tua Luna di nascita, quella delle uscite: una posizione sfavorevole della Chandra Bala.
2. Per il lavoro oggi le energie sono basse. Fai il necessario, togli dalla lista ciò che può aspettare, stacca all'ora giusta: stasera vai a letto presto. || La Luna in dodicesima casa, per la tradizione indiana, porta stanchezza: è una delle posizioni sfavorevoli nel conto dalla tua Luna di nascita.
3. Al lavoro oggi l'attenzione si disperde in fretta. Rimanda le riunioni che puoi spostare, tenendo in agenda solo l'indispensabile con un orario di fine già deciso. || Il cielo di oggi disperde: la Luna sta nella casa delle uscite, la dodicesima dalla tua Luna di nascita.

### Chandrashtama, la Luna in ottava (h = 8)
Titolo: Il lavoro di sempre

1. Oggi nel lavoro non è il giorno delle svolte. Se hai un contratto da firmare o un cambio di lavoro da decidere rimanda di un giorno o due: nel frattempo rileggi i documenti con calma. || Oggi è Chandrashtama, la Luna nell'ottava casa dalla tua Luna di nascita: la tradizione indiana sconsiglia di firmare contratti o cambiare lavoro.
2. Al lavoro oggi conviene non esporsi. Fai bene il lavoro di sempre, quello che conosci a memoria, tenendo per la settimana prossima le idee nuove e le proposte. || Con la Luna nell'ottava casa dalla tua Luna di nascita la tradizione indiana mette il giorno fra quelli da non forzare.
3. Giornata delicata per la professione, in cui una parola di troppo resta. Se qualcuno ti provoca non rispondere a caldo: salva la mail nelle bozze e riguardala domattina. || La Luna è in ottava dalla tua Luna di nascita: in India questo giorno si chiama Chandrashtama e si dedica alla calma.

---

## 6. Scheda Fortuna (seconda e undicesima casa dalla Luna di nascita)

Regola: la seconda è la casa dei beni (BPHS 11.3, "Wealth, grains (food
etc.), family"), l'undicesima quella dei guadagni (BPHS 11.12, "income,
prosperity").

### La Luna nella seconda (h = 2)
Casa dei beni, ma la Chandra Bala è di attenzione.
Titolo: Guarda il conto

1. Oggi con il denaro serve prudenza. Guarda il saldo del conto prima di spendere e chiediti, davanti a ogni acquisto, se ti serve davvero questa settimana. || Oggi la Luna passa sulla seconda casa dalla tua Luna di nascita, quella dei beni, ma la Chandra Bala di questa posizione è di attenzione.
2. Il denaro oggi è al centro dei pensieri. Tienilo stretto e fai i conti di famiglia: metti in fila bollette, scadenze e spese fisse del mese su un foglio solo. || La Luna è nella seconda casa contata dalla tua Luna di nascita, che i testi indiani legano ai beni, al cibo e alla famiglia.
3. Per i soldi oggi conviene custodire più che muovere. Rimanda gli acquisti grossi di qualche giorno e lascia nel carrello quello che stavi per prendere. || Con la Luna in seconda casa, la casa dei beni, la tradizione indiana invita a custodire: i testi parlano di beni che scivolano via.

### La Luna nell'undicesima (h = 11)
Titolo: Raccogli i frutti

1. Oggi per il denaro è un giorno di raccolta. Fai l'elenco di ciò che ti spetta, un rimborso, una fattura, un credito fra amici, poi muovi il primo passo per riaverlo. || Oggi la Luna attraversa l'undicesima casa dalla tua Luna di nascita, quella dei guadagni: per la tradizione indiana è un giorno di frutti.
2. Quando si tratta di soldi oggi è un buon giorno per chiedere. Sollecita con garbo il pagamento in ritardo, parla dell'aumento che meriti oppure domanda il favore che ti toglierebbe un peso. || La Luna è nell'undicesima casa contata dalla tua Luna di nascita, che i testi indiani legano alle entrate e alla prosperità.
3. Oggi la fortuna passa anche dalle amicizie. Dai retta a un buon consiglio: racconta a una persona di fiducia la questione di soldi che ti preoccupa e ascolta come la vede. || Con la Luna nella casa dei guadagni, l'undicesima, la Brihat Samhita parla di prosperità e di amicizie nuove.

### La Luna nella quinta guarda l'undicesima (h = 5)
La Luna guarda la casa dei guadagni da una casa di attenzione.
Titolo: Occasioni da verificare

1. Oggi le occasioni per il denaro ci sono ma vanno verificate. Prima di dire sì a un'offerta leggi le condizioni fino in fondo e confronta almeno un'alternativa. || Oggi la Luna guarda l'undicesima casa, quella dei guadagni, dalla quinta: un posto che la tradizione indiana dà per faticoso.
2. La fortuna di oggi è quella che si costruisce, un pezzo alla volta. Niente azzardi: metti da parte una piccola cifra, anche solo il resto della spesa, oppure chiudi un lavoro da fatturare. || La Luna tiene d'occhio la tua casa dei guadagni dalla quinta casa, una posizione di attenzione nel conto dalla tua Luna di nascita.
3. Oggi con i soldi la tentazione del colpo fortunato è forte. Lasciala passare: se ti viene voglia di tentare la sorte aspetta ventiquattro ore e tieni quei soldi in tasca. || Con la Luna in quinta casa lo sguardo arriva sulla casa dei guadagni, ma da una posizione che la Chandra Bala dà di attenzione.

### Favorevole (h = 1, 3, 6, 7, 10)
Titolo: Piccole occasioni

1. Oggi per la fortuna la giornata è buona. Tieni gli occhi aperti sulle piccole occasioni: uno sconto su una cosa che ti serve, un'offerta di lavoro, una proposta arrivata per caso. || Per la fortuna il cielo di oggi è buono: la Luna transita in una casa favorevole contata dalla tua Luna di nascita.
2. È un buon giorno per mettere ordine nei soldi. Controlla gli abbonamenti che paghi senza usarli, archivia le ricevute, annota le scadenze del mese prossimo. || La Luna sta in un posto favorevole rispetto alla tua Luna di nascita, pur senza toccare le case dei beni e dei guadagni.
3. Oggi le cose tendono a girare dalla tua parte, anche sul denaro. Aiutale con una scelta ragionata: confronta due preventivi o decidi con i numeri davanti la spesa che rimandi. || Nella Chandra Bala la Luna di oggi cade in una delle case favorevoli, quelle che la tradizione indiana dà per propizie.

### Di attenzione (h = 9)
Titolo: Ci vuole pazienza

1. Oggi la fortuna chiede pazienza e i soldi si muovono piano. Non forzare le trattative: se l'altra parte prende tempo lascia passare la giornata senza rilanciare. || Oggi la Luna è nella nona casa dalla tua Luna di nascita, una posizione che la Chandra Bala dà di attenzione.
2. Con il denaro oggi le spese d'impulso lasciano il rimpianto. Aspetta domani: salva l'articolo fra i preferiti, chiudi la pagina, riguardalo a mente fresca. || Il cielo di oggi non ama le spese impulsive: con la Luna in nona casa la tradizione indiana parla di impedimenti.
3. Per i soldi oggi conviene tenere le cose come stanno. Non cambiare contratti, tariffe o accordi già presi: prendi appunti sulle alternative e riparlane nei prossimi giorni. || La Luna in nona casa rende il giorno un po' stretto per la tradizione indiana: è una delle posizioni di attenzione della Chandra Bala.

### Sfavorevole (h = 4, 12)
Titolo: Tieni un margine

1. Oggi le spese impreviste sono più facili del solito. Tieni un margine: lascia da parte una piccola somma e non arrivare a fine giornata con il portafoglio vuoto. || Oggi la Luna è in una casa sfavorevole per i beni, contata dalla tua Luna di nascita.
2. Con i soldi oggi non è il giorno per prestare né per giocare. Proteggi quello che hai: se qualcuno ti chiede un prestito prendi tempo fino alla settimana prossima. || La Luna transita in una delle case che la Chandra Bala dà per sfavorevoli, contate dalla tua Luna di nascita.
3. Oggi tende a uscire più denaro di quanto ne entra. Rimanda gli acquisti che non sono necessari: fai la spesa con la lista in mano e fermati a quella. || Il cielo di oggi fa uscire più di quanto entra: la Luna sta in una posizione sfavorevole rispetto alla tua Luna di nascita.

### Chandrashtama, la Luna in ottava (h = 8)
Titolo: Meglio aspettare

1. Oggi per il denaro è meglio non muovere cifre importanti. Se hai in mente un prestito o un impegno grosso aspetta un giorno o due: la decisione non scade. || Oggi è Chandrashtama, la Luna nell'ottava casa dalla tua Luna di nascita: la tradizione indiana sconsiglia investimenti e prestiti.
2. La fortuna oggi si protegge con la prudenza. Niente firme su questioni di denaro: prendi i documenti, leggili senza fretta, rimanda la risposta. || Con la Luna in ottava dalla tua Luna di nascita la tradizione indiana dedica il giorno alla calma, senza decisioni grandi.
3. È un giorno delicato per i beni, da passare con gli occhi aperti. Controlla gli addebiti sul conto uno per uno, tenendo per dopodomani ogni novità che riguarda i soldi. || La Luna è nell'ottava casa rispetto alla tua Luna di nascita: è il giorno che in India chiamano Chandrashtama, il più delicato del suo giro.

---

## 7. Rahu Kalam

Regola: il tempo fra alba e tramonto diviso in otto parti; la parte del Rahu
Kalam va dal lunedì alla domenica così: 2, 7, 5, 6, 4, 3, 8. Si evita di
cominciare, non di continuare. Alba e tramonto al bordo superiore del Sole con
la rifrazione, senza quota.
Fonte: Drik Panchang, pagine "Rahu Kaal" e "Hindu Sunrise" (42 estremi su 42
uguali al minuto per Roma, Milano e Palermo, 5-11 ottobre 2026). Rahu è il nodo
lunare nord, che la tradizione indiana considera un pianeta d'ombra.

### Il Rahu Kalam deve ancora venire

1. Oggi fra le {inizio} e le {fine} conviene non cominciare niente di nuovo. Se hai un inizio in programma, mettilo prima o dopo quelle ore. || È il Rahu Kalam, l'ora e mezza circa che la tradizione indiana lascia a Rahu.
2. A {luogo} oggi le ore da lasciare passare vanno dalle {inizio} alle {fine}. Le cose già avviate puoi continuarle; quelle nuove spostale a un altro momento della giornata. || È il Rahu Kalam di oggi: nella tradizione indiana in quel tempo si evita di cominciare, non di continuare.
3. Tieni libere da inizi e firme le ore fra le {inizio} e le {fine}. Se hai una firma in agenda proprio lì, chiedi di spostarla di un paio d'ore. || È il Rahu Kalam, un'ora e mezza circa che in India si lascia passare: è il tempo di Rahu, che la tradizione indiana considera un pianeta d'ombra.
4. Se oggi devi partire, fare una proposta o firmare, fallo prima delle {inizio} o dopo le {fine}. In mezzo porta avanti ciò che è già in corso. || Fra le {inizio} e le {fine} oggi cade il Rahu Kalam, l'ora e mezza che la tradizione indiana lascia a Rahu.

### Il Rahu Kalam è in corso

1. Fino alle {fine} non è il momento di cominciare cose nuove. Continua pure quello che stai facendo; il resto fallo partire dopo quell'ora. || Adesso è Rahu Kalam, l'ora e mezza che la tradizione indiana lascia a Rahu: finisce alle {fine}.
2. Fino alle {fine} questo è un tempo per le cose già avviate. Riprendi un lavoro lasciato a metà o porta a termine quello che hai sul tavolo. || Siamo dentro il Rahu Kalam di oggi, dalle {inizio} alle {fine}.
3. Fino alle {fine} conviene aspettare con le cose importanti. Se puoi, rimanda di poco quella telefonata e intanto prepara ciò che vuoi dire. || Fino alle {fine} è Rahu Kalam, l'ora e mezza in cui la tradizione indiana evita di dare inizio alle cose.

### Il Rahu Kalam è già passato

1. Le ore da lasciare passare, fra le {inizio} e le {fine}, sono già alle spalle. Il resto della giornata è libero per inizi, partenze e proposte. || Era il Rahu Kalam di oggi, l'ora e mezza che la tradizione indiana lascia a Rahu.
2. Da adesso puoi cominciare senza pensarci: le ore in cui conveniva aspettare erano fra le {inizio} e le {fine}. Manda quella richiesta o fissa quell'appuntamento. || Oggi il Rahu Kalam è stato fra le {inizio} e le {fine}: è il tempo che la tradizione indiana lascia a Rahu.
3. Se avevi rimandato qualcosa, adesso è il momento di farlo. Le ore da evitare, fra le {inizio} e le {fine}, sono passate: riprendi la telefonata o la firma che avevi spostato. || Il momento di Rahu è alle spalle: il Rahu Kalam di oggi era fra le {inizio} e le {fine}.

### Manca la città

1. Ogni giorno c'è un'ora e mezza in cui conviene non cominciare niente di importante. Dimmi la tua città e ti dico quando cade oggi. || È il Rahu Kalam: dipende dall'alba e dal tramonto del luogo in cui sei.
2. Per dirti in quali ore oggi è meglio non dare inizio alle cose importanti mi serve sapere dove sei: in Italia fra Milano e Palermo cambia di un quarto d'ora. Scegli la tua città. || È il Rahu Kalam, un ottavo del tempo fra l'alba e il tramonto: per questo cambia da un luogo all'altro.
3. C'è un tratto della giornata, un'ora e mezza circa, da tenere libero da inizi e firme: cambia ogni giorno e in ogni città. Aggiungi la tua e te lo indico. || È il Rahu Kalam, l'ora e mezza che la tradizione indiana lascia a Rahu.

---

## 8. Glossario per la nota del metodo

Termini che compaiono nel corpus, uno per riga, con la spiegazione da mostrare
alla prima occorrenza o nella nota col punto interrogativo.

- **Rashi**: il segno zodiacale siderale; qui quello della Luna di nascita.
- **Nakshatra**: una delle 27 "stelle" o dimore lunari, settori di 13 gradi e
  20 primi in cui la Luna passa circa un giorno.
- **Chandra Bala**: "forza della Luna", la casa in cui transita la Luna contata
  dalla Luna di nascita.
- **Chandrashtama**: la Luna di oggi nell'ottava casa dalla Luna di nascita,
  il giorno più delicato del mese lunare personale.
- **Tara Bala**: "forza della stella", il nakshatra di oggi contato da quello
  di nascita, a gruppi di nove.
- **Janma, Sampat, Vipat, Kshema, Pratyak, Sadhana, Naidhana, Mitra, Parama
  Mitra**: i nove esiti della Tara Bala; nascita, ricchezza, pericolo,
  benessere, ostacolo, riuscita, fine, amico, grande amico.
- **Vara**: il giorno della settimana e il pianeta che lo governa.
- **Rahu Kalam**: "il tempo di Rahu", un ottavo del giorno di luce da non usare
  per cominciare cose nuove.
- **Rahu**: il nodo lunare nord, pianeta d'ombra nella tradizione indiana.
