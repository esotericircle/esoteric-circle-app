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

## Come si compongono le quattro schede

- **Generale**: una frase della Chandra Bala (sezione 1), una della Tara Bala
  (sezione 2), la riga del pianeta del giorno (sezione 3) e la riga del Rahu
  Kalam (sezione 7).
- **Amore**, **Lavoro**, **Fortuna**: una frase del caso della scheda
  (sezioni 4, 5 e 6), scelto con la tabella della sezione 6.3 di
  `specifiche.md`.

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

1. Oggi la Luna torna {segno_luna}, dove stava alla tua nascita. Nella
   tradizione indiana è un giorno di agio: mangia bene, riposa bene, prenditi
   cura del corpo.
2. La Luna è di nuovo nel tuo segno di nascita. È una giornata che ti somiglia:
   fai le cose al tuo ritmo e concediti una comodità vera.
3. Con la Luna nel tuo segno i testi antichi parlano di benessere semplice,
   tavola buona e letto comodo. Non cercare imprese: goditi quello che hai.

### Casa 2: la Luna sulla casa dei beni
Fonte: Brihat Samhita 104.8, "perdita di beni e ostacoli"; Phaladeepika 26.12,
"perdita di ricchezza"; Drik: di attenzione (Puja Needed).

1. Oggi la Luna passa sulla tua seconda casa, quella dei beni. La tradizione
   invita alla prudenza col denaro: rimanda gli acquisti che non ti servono.
2. La Luna è nella seconda casa dalla tua Luna di nascita. È un giorno da
   portafoglio chiuso e parole misurate: controlla prima di spendere.
3. Con la Luna in seconda casa i testi parlano di beni che scivolano via. Non è
   una condanna: è un invito a tenere il conto delle spese di oggi.

### Casa 3: la Luna del coraggio
Fonte: Brihat Samhita 104.8, "vesti, affetti e beni in abbondanza";
Phaladeepika 26.12, "successo".

1. Oggi la Luna sta nella tua terza casa: per la tradizione indiana è un
   giorno di riuscita. Fai quella telefonata che rimandi da una settimana.
2. La Luna in terza casa dà slancio alle iniziative piccole. Scrivi, proponi,
   muoviti: oggi il passo corto arriva lontano.
3. Con la Luna nella terza casa i testi antichi parlano di successo e di cose
   belle che arrivano. Approfittane per cominciare qualcosa di concreto.

### Casa 4: la Luna inquieta
Fonte: Brihat Samhita 104.8 (il nativo è "crudele come un serpente", cioè
irrequieto e pungente); Phaladeepika 26.12, "paura".

1. Oggi la Luna passa sulla tua quarta casa, che la tradizione legge come un
   giorno di inquietudine. Se senti i nervi scoperti, non è colpa di nessuno: rallenta.
2. La Luna in quarta casa rende la pelle sottile. Evita le discussioni in
   famiglia e rimanda le decisioni sulla casa.
3. Con la Luna nella quarta casa i testi antichi parlano di timori. Tieniti
   stretto ciò che ti dà sicurezza e lascia le novità a domani.

### Casa 5: la Luna stanca
Fonte: Brihat Samhita 104.9, "umiliazione, malanni e ostacoli"; Phaladeepika
26.12, "dolore"; Drik: di attenzione.

1. Oggi la Luna è nella tua quinta casa: la tradizione indiana la legge come
   una giornata in salita. Non chiederti troppo.
2. La Luna in quinta casa porta un po' di malinconia. Fai meno cose e falle
   bene; il resto può aspettare.
3. Con la Luna nella quinta casa i testi parlano di ostacoli. Non metterti alla
   prova oggi: proteggi l'energia per i giorni migliori.

### Casa 6: la Luna che vince
Fonte: Brihat Samhita 104.9, "ricchezza, agio e rovina dei nemici";
Phaladeepika 26.12, "libertà dalla malattia".

1. Oggi la Luna passa sulla tua sesta casa: per la tradizione è il giorno in
   cui si superano gli intoppi. Affronta la pratica che ti pesa.
2. La Luna in sesta casa dà forza al corpo e alla testa. È una buona giornata
   per la salute: muoviti, cura le abitudini.
3. Con la Luna nella sesta casa i testi antichi parlano di avversari che
   perdono terreno. Se hai un conto in sospeso, oggi puoi chiuderlo con calma.

### Casa 7: la Luna dell'incontro
Fonte: Brihat Samhita 104.9, "ricchezza e rispetto"; Phaladeepika 26.12,
"felicità".

1. Oggi la Luna è nella tua settima casa, quella dell'altro. La tradizione
   indiana la dà favorevole: è un buon giorno per incontrare, accordarsi, stare
   in compagnia.
2. La Luna in settima casa porta rispetto e buona accoglienza. Cerca le persone:
   oggi ti ascoltano.
3. Con la Luna nella settima casa i testi parlano di felicità condivisa.
   Organizza qualcosa con chi ami o con chi lavori.

### Casa 8: Chandrashtama, la Luna in ottava
Fonte: Brihat Samhita 104.9, "paura dei mali"; Phaladeepika 26.12, "eventi
avversi"; Raman, *Muhurtha* cap. III, fra le case da evitare. Il nome proprio
è Chandrashtama, "la Luna nell'ottava".

1. Oggi la Luna passa sull'ottava casa dalla tua Luna di nascita. In India
   questo giorno ha un nome, Chandrashtama: si dedica alla calma, niente
   decisioni grandi, niente firme importanti.
2. È il tuo giorno di Chandrashtama, la Luna nell'ottava casa. Non è un giorno
   cattivo: è un giorno da non forzare. Fai l'ordinario e fallo con cura.
3. La Luna in ottava casa è, per la tradizione indiana, il momento più delicato
   del suo giro. Proteggiti: dormi, mangia leggero, rimanda i confronti.

### Casa 9: la Luna lontana
Fonte: Brihat Samhita 104.10, "prigionia e dolore"; Phaladeepika 26.12,
"malattia"; Drik: di attenzione.

1. Oggi la Luna è nella tua nona casa: la tradizione la legge come un giorno
   un po' stretto. Se qualcosa ti trattiene, non strattonare: aspetta che passi.
2. La Luna in nona casa chiede riguardo per la salute. Non stancarti e non
   partire per viaggi che puoi spostare.
3. Con la Luna nella nona casa i testi antichi parlano di impedimenti. Oggi
   conviene tenere i piani semplici.

### Casa 10: la Luna che fa
Fonte: Brihat Samhita 104.10, "gli ordini saranno eseguiti, successo nel
lavoro"; Phaladeepika 26.12, "desideri realizzati".

1. Oggi la Luna passa sulla tua decima casa, quella dell'azione. Per la
   tradizione indiana le cose che chiedi vengono fatte: chiedile.
2. La Luna in decima casa sostiene il lavoro e la reputazione. Porta avanti il
   progetto che conta di più.
3. Con la Luna nella decima casa i testi parlano di desideri che trovano
   strada. Scegline uno concreto e dagli la giornata.

### Casa 11: la Luna dei guadagni
Fonte: Brihat Samhita 104.10, "prosperità e amicizie nuove"; Phaladeepika
26.12, "gioia".

1. Oggi la Luna è nella tua undicesima casa, quella dei frutti. La tradizione
   indiana la dà tra le migliori: raccogli quello che hai seminato.
2. La Luna in undicesima casa porta amicizie e buone notizie. Rispondi ai
   messaggi, accetta gli inviti.
3. Con la Luna nell'undicesima casa i testi antichi parlano di prosperità e di
   gioia. È un giorno da vivere con le porte aperte.

### Casa 12: la Luna che spende
Fonte: Brihat Samhita 104.10 (ferite); Phaladeepika 26.12, "spesa".

1. Oggi la Luna passa sulla tua dodicesima casa, quella delle uscite. La
   tradizione invita a non disperdere: tempo, soldi, forze.
2. La Luna in dodicesima casa porta stanchezza e spese. Ritirati un po' e
   ricaricati: domani la Luna cambia segno.
3. Con la Luna nella dodicesima casa i testi parlano di ciò che se ne va.
   Lascia andare il superfluo e trattieni l'essenziale.

---

## 2. Tara Bala: la stella di oggi contata dalla tua stella di nascita

Regola: si conta dal nakshatra di nascita a quello di oggi, il primo compreso,
e si divide per nove; il resto (col nove al posto dello zero) dà la tara.
Fonti: B. V. Raman, *Muhurtha*, cap. III; Drik Panchang, Tarabalam (216 esiti
su 216 verificati).

### Tara 1, Janma: la tua stessa stella
Raman: "danger to body"; Drik: Not Good. Raman aggiunge che è buona per
seminare, comprare terre e cominciare a studiare.

1. Oggi la Luna è nella tua stella di nascita, {nakshatra_nascita}. La
   tradizione la chiama Janma, "la nascita": giorno per il corpo, non per le
   sfide. Riguardati.
2. La Luna torna sulla tua stella, {nakshatra_nascita}. È un giorno per
   seminare e imparare, meno per viaggiare o affrontare cure e contese.
3. È il tuo giorno di Janma, la Luna sulla stella della tua nascita. Resta
   in ascolto di te: è un buon giorno per cominciare uno studio, non per litigare.

### Tara 2, Sampat: la ricchezza
Raman: "wealth and prosperity"; Drik: Very Good.

1. La stella di oggi, {nakshatra_oggi}, è per te Sampat, "la ricchezza". È un
   buon giorno per occuparti dei tuoi beni e delle tue entrate.
2. Oggi la stella della Luna ti è amica: Sampat, la seconda dalla tua. Muovi
   i soldi con giudizio: la tradizione la dà propizia.
3. Con Sampat, la stella della prosperità, conviene fare i passi che fanno
   crescere: un'offerta, una trattativa, un investimento di tempo.

### Tara 3, Vipat: il pericolo
Raman: "dangers, losses and accidents"; Drik: Bad.

1. La stella di oggi, {nakshatra_oggi}, è per te Vipat, "il pericolo". Non
   spaventarti: significa attenzione in strada, sulle scale, con gli oggetti
   di valore.
2. Oggi la tradizione ti dà Vipat, la stella delle perdite. Controlla due volte
   chiavi, documenti, pagamenti.
3. Con Vipat conviene muoversi piano. Rimanda i viaggi lunghi e gli impegni
   rischiosi: Raman consiglia di evitarla per le cose importanti.

### Tara 4, Kshema: il benessere
Raman: "prosperity"; Drik: Good.

1. La stella di oggi, {nakshatra_oggi}, è per te Kshema, "il benessere". È una
   giornata che sostiene: usala per le cose che ti fanno stare bene.
2. Oggi hai Kshema, la stella della prosperità tranquilla. Buon giorno per
   partire, per sistemare, per stare bene con gli altri.
3. Con Kshema la tradizione indiana vede un giorno sereno. Non serve strafare:
   basta fare bene quello che hai davanti.

### Tara 5, Pratyak: l'ostacolo
Raman: "obstacles"; Drik: Not Good (la chiama Pratyari).

1. La stella di oggi, {nakshatra_oggi}, è per te Pratyak, "l'ostacolo".
   Metti in conto qualche intoppo e lascia margine nei tuoi orari.
2. Oggi hai Pratyak: le cose chiedono più tempo del previsto. Non è un no, è
   un "non ancora".
3. Con Pratyak conviene non incaponirsi. Se una porta resta chiusa, prova
   domani.

### Tara 6, Sadhana: la riuscita
Raman: "realisation of ambitions"; Drik: Very Good (la chiama Sadhaka).

1. La stella di oggi, {nakshatra_oggi}, è per te Sadhana, "la riuscita". Per
   la tradizione indiana è un giorno in cui gli sforzi arrivano a segno.
2. Oggi hai Sadhana: è il giorno adatto per lavorare al tuo obiettivo più caro.
   Dagli almeno un'ora vera.
3. Con Sadhana i propositi trovano strada. Scegli una cosa sola e portala a
   termine.

### Tara 7, Naidhana: la fine
Raman: "dangers", da evitare per le imprese importanti; Drik: Totally Bad.

1. La stella di oggi, {nakshatra_oggi}, è per te Naidhana, la più delicata delle
   nove. Oggi non cominciare nulla di grande: custodisci quello che c'è.
2. Oggi hai Naidhana, "la fine". Non è un presagio: è l'invito della
   tradizione a non aprire cose nuove e a chiudere bene le vecchie.
3. Con Naidhana conviene la prudenza piena. Rimanda firme, viaggi e decisioni
   che non hanno fretta.

### Tara 8, Mitra: l'amico
Raman: "good"; Drik: Good.

1. La stella di oggi, {nakshatra_oggi}, è per te Mitra, "l'amico". È un buon
   giorno per chiedere aiuto e per darne.
2. Oggi hai Mitra: le persone ti vengono incontro. Cerca un alleato per quello
   che non riesci a fare senza aiuto.
3. Con Mitra la tradizione vede un cielo amico. Dedica tempo alle amicizie che
   trascuri.

### Tara 9, Parama Mitra: il grande amico
Raman: "very favourable"; Drik: Good.

1. La stella di oggi, {nakshatra_oggi}, è per te Parama Mitra, "il grande
   amico". Per Raman è la più favorevole delle nove.
2. Oggi hai Parama Mitra: il cielo ti è amico fino in fondo. Buon giorno per
   le cose a cui tieni.
3. Con Parama Mitra conviene osare un poco. Fai la richiesta che rimandi: la
   tradizione la dà propizia.

---

## 3. Il pianeta del giorno (vara)

Regola: il giorno della settimana prende il nome dal pianeta che lo governa.
Colori: Varahamihira, *Brihat Jataka* 2.5. Numeri: numerologia indiana
moderna (Cheiro 1926, con Rahu e Ketu al posto di Urano e Nettuno). Da dire
nella nota del metodo: il numero non viene dai testi antichi.

### Una riga per ogni giorno

- **Domenica**: Oggi è Ravivara, il giorno del Sole. Il suo colore è il rosso,
  il suo numero l'uno: un giorno per mostrarti.
- **Lunedì**: Oggi è Somavara, il giorno della Luna. Il suo colore è il
  bianco, il suo numero il due: un giorno per ascoltare.
- **Martedì**: Oggi è Mangalavara, il giorno di Marte. Il suo colore è il
  rosso, il suo numero il nove: un giorno per agire con decisione.
- **Mercoledì**: Oggi è Budhavara, il giorno di Mercurio. Il suo colore è il
  verde, il suo numero il cinque: un giorno per parlare, scrivere, trattare.
- **Giovedì**: Oggi è Guruvara, il giorno di Giove. Il suo colore è il giallo,
  il suo numero il tre: un giorno per imparare e consigliare.
- **Venerdì**: Oggi è Shukravara, il giorno di Venere. Il suo colore è lo
  screziato, il suo numero il sei: un giorno per la bellezza e gli affetti.
- **Sabato**: Oggi è Shanivara, il giorno di Saturno. Il suo colore è il nero,
  il suo numero l'otto: un giorno per la pazienza e il lavoro lento.

(I colori di venerdì e sabato sono quelli del testo; se Mauro sceglie il
bianco e il blu della pratica popolare, cambiano qui e nella nota del metodo.)

### Varianti generiche della stessa riga

1. Oggi governa {pianeta}: colore {colore}, numero {numero}.
2. Il giorno è di {pianeta}. Se vuoi un segno da portare con te, scegli il
   {colore}; il numero del giorno è il {numero}.
3. Nella settimana indiana oggi è il giorno di {pianeta}, col suo {colore} e
   il suo {numero}.

---

## 4. Scheda Amore (settima e quinta casa dalla Luna di nascita)

Regola: la settima è la casa dell'unione e del coniuge (BPHS 11.8, "Wife");
la quinta è letta qui come il cuore che si apre (lettura moderna: nel BPHS 11.6
è la casa dei figli e del sapere). Caso scelto con la tabella di
`specifiche.md` 6.3.

### La Luna nella settima (h = 7)
Chandra Bala favorevole; la Luna attraversa la casa dell'unione.

1. Oggi la Luna attraversa la tua settima casa, quella dell'unione. È il
   giorno adatto per stare vicino a chi ami e dirgli una cosa vera.
2. La Luna è nella casa del legame. Se sei in coppia, fate qualcosa insieme;
   se non sei in coppia, esci: oggi gli incontri hanno un buon cielo.
3. Con la Luna nella settima casa la tradizione vede rispetto e felicità
   condivisa. Ascolta l'altro prima di rispondere.

### La Luna nella quinta (h = 5)
Casa del cuore, ma la Chandra Bala è di attenzione: emozioni forti e un po'
di stanchezza.

1. Oggi la Luna passa sulla tua quinta casa, quella del cuore. Le emozioni
   sono vive ma fragili: trattale con dolcezza, anche le tue.
2. La Luna è nella casa dei sentimenti, in un giorno che la tradizione dà
   faticoso. Un gesto tenero vale più di un grande discorso.
3. Con la Luna in quinta casa il cuore si apre, ma si stanca in fretta. Scegli
   la leggerezza: un gioco, una passeggiata, una risata.

### La Luna nel tuo segno guarda la settima (h = 1)
La Luna guarda per intero la settima casa da sé (BPHS 26.2-5).

1. Oggi la Luna è nel tuo segno e guarda dritta la casa dell'unione. Sei tu a
   dare il tono: se porti calma, la ricevi.
2. La Luna sta con te e guarda la tua settima casa. Buon giorno per farti
   avanti, con semplicità.
3. Con la Luna nel tuo segno l'attenzione degli altri ti cerca. Lasciati
   trovare.

### La Luna nell'undicesima guarda la quinta (h = 11)
La Luna in una casa favorevole guarda la casa del cuore.

1. Oggi la Luna, dalla casa delle amicizie, guarda la casa del cuore. Un
   affetto può nascere o rinascere fra gli amici.
2. La Luna guarda la tua quinta casa da un posto favorevole. È un buon giorno
   per un invito, anche piccolo.
3. Con la Luna nell'undicesima casa la tradizione vede gioia. Condividila con
   chi ti fa battere il cuore.

### Favorevole (h = 3, 6, 10)

1. Oggi la Luna non tocca le case dell'amore, ma sta in un posto favorevole:
   il cuore è sereno. Coltiva quello che c'è.
2. Per l'amore è una giornata tranquilla e buona. Un messaggio affettuoso
   basta a renderla migliore.
3. Il cielo di oggi sostiene: non ci sono segnali forti per il cuore, solo un
   clima buono. Approfittane per stare bene insieme.

### Di attenzione (h = 2, 9)

1. Oggi la Luna sta in una casa che la tradizione chiede di trattare con cura.
   In amore evita le parole taglienti.
2. Per il cuore è un giorno da maneggiare piano. Se nasce una discussione,
   rimandala a domani.
3. Il cielo di oggi non favorisce i chiarimenti. Meglio un abbraccio che una
   spiegazione.

### Sfavorevole (h = 4, 12)

1. Oggi la Luna è in una casa sfavorevole: potresti sentire distanza o
   poca comprensione. Non decidere nulla sulla coppia sotto questo cielo.
2. In amore è un giorno di pelle sottile. Chiedi quello che ti serve senza
   pretendere risposte subito.
3. Il cielo di oggi rende tutto più pesante. Prenditi un momento per te prima
   di cercare l'altro.

### Chandrashtama, la Luna in ottava (h = 8)

1. Oggi è il tuo giorno di Chandrashtama, la Luna nell'ottava casa. In amore
   non è il momento delle prove né delle domande grandi.
2. Con la Luna in ottava la tradizione indiana consiglia calma. Se qualcosa ti
   ferisce, aspetta domani per rispondere.
3. È un giorno delicato per il cuore. Stai con chi ti fa sentire al sicuro e
   lascia fuori il resto.

---

## 5. Scheda Lavoro (decima casa dalla Luna di nascita)

Regola: la decima è la casa della professione e dell'autorità (BPHS 11.11,
"profession (livelihood), honour"); con la Luna in decima "gli ordini saranno
eseguiti, successo nel lavoro" (Brihat Samhita 104.10).

### La Luna nella decima (h = 10)

1. Oggi la Luna attraversa la tua decima casa, quella del lavoro. È il giorno
   adatto per presentare, chiedere, decidere.
2. La Luna è nella casa della professione: per la tradizione indiana le
   richieste vengono accolte. Fai quella proposta.
3. Con la Luna in decima casa il tuo lavoro si vede. Metti il meglio dove
   guardano gli altri.

### La Luna nella quarta guarda la decima (h = 4)
La Luna guarda la casa del lavoro da una casa sfavorevole.

1. Oggi la Luna guarda il tuo lavoro dalla casa delle radici. La testa torna a
   casa: sbriga le cose ordinarie e rimanda quelle nuove.
2. La Luna ti tiene lo sguardo sul lavoro, ma da un posto inquieto. Evita gli
   scontri con i superiori.
3. Con la Luna in quarta casa il lavoro chiede ordine più che slancio. Riordina
   la scrivania e l'agenda.

### Favorevole (h = 1, 3, 6, 7, 11)

1. Per il lavoro il cielo di oggi è buono. Porta avanti le pratiche aperte:
   scorrono meglio del solito.
2. La Luna sta in un posto favorevole: buon giorno per collaborare e chiudere
   accordi.
3. Oggi il lavoro trova una strada liscia. Non sprecarla: scegli la cosa più
   importante e falla.

### Di attenzione (h = 2, 5, 9)

1. Oggi al lavoro conviene ricontrollare: cifre, date, destinatari.
2. Il cielo di oggi chiede cura nei dettagli. Meglio un'ora in più che un
   errore da rifare.
3. Non è il giorno delle grandi mosse professionali. Consolida quello che hai.

### Sfavorevole (h = 12)

1. Oggi la Luna è nella casa delle uscite: al lavoro puoi sentirti [poco visto|poco vista|in ombra].
   Lavora in silenzio e non cercare conferme.
2. È un giorno di energie basse per la professione. Fai il necessario e
   riposati bene stasera.
3. Il cielo di oggi disperde. Rimanda le riunioni che puoi spostare.

### Chandrashtama, la Luna in ottava (h = 8)

1. Oggi è Chandrashtama: la tradizione indiana sconsiglia di firmare
   contratti o cambiare lavoro. Rimanda di un giorno o due.
2. Con la Luna in ottava casa conviene non esporsi. Fai bene il lavoro di
   sempre e lascia le novità.
3. Giornata delicata per la professione. Se qualcuno ti provoca, non
   rispondere a caldo.

---

## 6. Scheda Fortuna (seconda e undicesima casa dalla Luna di nascita)

Regola: la seconda è la casa dei beni (BPHS 11.3, "Wealth, grains (food
etc.), family"), l'undicesima quella dei guadagni (BPHS 11.12, "income,
prosperity").

### La Luna nella seconda (h = 2)
Casa dei beni, ma la Chandra Bala è di attenzione.

1. Oggi la Luna passa sulla casa dei tuoi beni, ma la tradizione chiede
   prudenza: guarda il conto prima di spendere.
2. La Luna è nella seconda casa: il denaro è al centro della giornata. Tienilo
   stretto e fai i conti di famiglia.
3. Con la Luna in seconda casa conviene custodire più che investire. Rimanda
   gli acquisti grossi.

### La Luna nell'undicesima (h = 11)

1. Oggi la Luna attraversa la tua casa dei guadagni. Per la tradizione indiana
   è un giorno di frutti: raccogli quello che ti spetta.
2. La Luna è nell'undicesima casa: buon giorno per chiedere un pagamento, un
   aumento, un favore.
3. Con la Luna nella casa dei guadagni la fortuna passa anche dalle amicizie.
   Dai retta a un buon consiglio.

### La Luna nella quinta guarda l'undicesima (h = 5)
La Luna guarda la casa dei guadagni da una casa di attenzione.

1. Oggi la Luna guarda la tua casa dei guadagni, da un posto faticoso. Le
   occasioni ci sono ma vanno verificate.
2. La Luna tiene d'occhio i tuoi guadagni. Niente azzardi: la fortuna di oggi
   è quella che si costruisce.
3. Con la Luna in quinta casa la tentazione del colpo fortunato è forte.
   Lasciala passare.

### Favorevole (h = 1, 3, 6, 7, 10)

1. Per la fortuna il cielo di oggi è buono. Tieni gli occhi aperti sulle
   piccole occasioni.
2. La Luna sta in un posto favorevole: è un buon giorno per sistemare le
   finanze.
3. Oggi le cose tendono a girare dalla tua parte. Aiutale con una scelta
   ragionata.

### Di attenzione (h = 9)

1. Oggi la fortuna chiede pazienza. Non forzare le trattative.
2. Il cielo di oggi non ama le spese impulsive. Aspetta domani.
3. Conviene tenere le cose come stanno: domani il cielo sarà più largo.

### Sfavorevole (h = 4, 12)

1. Oggi la Luna è in una casa sfavorevole per i beni: le spese impreviste sono
   più facili. Tieni un margine.
2. Non è il giorno per prestare o per giocare. Proteggi quello che hai.
3. Il cielo di oggi fa uscire più di quanto entra. Rimanda gli acquisti che
   non sono necessari.

### Chandrashtama, la Luna in ottava (h = 8)

1. Oggi è Chandrashtama, la Luna nell'ottava casa: la tradizione sconsiglia
   investimenti e prestiti. Aspetta un giorno o due.
2. Con la Luna in ottava la fortuna si protegge con la prudenza. Niente firme
   su denaro.
3. È un giorno delicato per i beni. Controlla gli addebiti e lascia le novità
   a dopodomani.

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

1. Oggi evita di cominciare qualcosa fra le {inizio} e le {fine}: è il Rahu
   Kalam, l'ora che la tradizione indiana lascia a Rahu.
2. A {luogo} il Rahu Kalam di oggi va dalle {inizio} alle {fine}. Le cose già
   avviate puoi continuarle; quelle nuove, spostale prima o dopo.
3. Tieni libere le {inizio}-{fine} da inizi e firme: è il Rahu Kalam, un'ora e
   mezza circa che in India si lascia passare.
4. Se devi partire, proporre o firmare, fallo fuori dal Rahu Kalam, oggi fra
   le {inizio} e le {fine}.

### Il Rahu Kalam è in corso

1. Adesso è Rahu Kalam, fino alle {fine}. Continua pure quello che stai
   facendo, ma le cose nuove aspettale.
2. Siamo dentro il Rahu Kalam di oggi: finisce alle {fine}. Usa questo tempo
   per le cose già avviate.
3. Fino alle {fine} è Rahu Kalam. Se puoi, rimanda di poco quella telefonata
   importante.

### Il Rahu Kalam è già passato

1. Il Rahu Kalam di oggi, fra le {inizio} e le {fine}, è già passato: il resto
   della giornata è libero da lui.
2. Oggi il Rahu Kalam è stato fra le {inizio} e le {fine}. Da adesso puoi
   cominciare senza pensarci.
3. Il momento di Rahu è alle spalle, era fra le {inizio} e le {fine}. Se avevi
   rimandato qualcosa, è il momento.

### Manca la città

1. Il Rahu Kalam dipende dall'alba e dal tramonto del luogo in cui sei. Dimmi
   la tua città e ti dico l'ora da evitare oggi.
2. Per calcolare il Rahu Kalam mi serve sapere dove sei: in Italia fra Milano
   e Palermo cambia di un quarto d'ora. Scegli la tua città.
3. Il Rahu Kalam, l'ora e mezza che la tradizione indiana lascia a Rahu, cambia
   ogni giorno e in ogni città. Aggiungi la tua e te lo indico.

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
