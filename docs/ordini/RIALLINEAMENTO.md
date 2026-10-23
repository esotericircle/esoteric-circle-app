# RIALLINEAMENTO PER UNA SESSIONE NUOVA

Scritto il 31 agosto 2026, a fine ordine CF. Serve a chi apre una sessione da
zero: dice dove siamo, cosa aspetta una parola del fondatore, e quali trappole
hanno morso in questo giro.

## DOVE SIAMO

- **Ramo**: `claude/esoteric-circle-master-order-e798aj`, testa `0de87da3`,
  verificata sul remoto con `git ls-remote`.
- **Ultimo ordine chiuso**: CF, diciotto voci. Il manifesto è
  `docs/ordini/ORDINE_CF_MANIFESTO.md` e porta i numeri prima e dopo di ogni
  voce, le premesse cadute e le decisioni motivate.
- **Cancello passato**: `bash tool/sbarramento.sh`, uscita 0, archivio
  prodotto. **4.088 prove Flutter passate e una caduta**, che è quella
  accettata; **50 prove del server passate e zero cadute**; `flutter analyze` a
  zero avvisi.
- **Nessuna build in circolazione da questo ordine**: le build le ordina il
  fondatore, e in CF non le ha ordinate. L'ultima consegnata è la 2215.

## COSA ASPETTA UNA PAROLA DEL FONDATORE

Tre voci di CF sono ferme e non sono lavoro rimandato.

**CF.10, i caratteri piccoli.** Il censimento sta in
`docs/tipografia/caratteri_piccoli.md`: quattordici testi sotto i sedici punti,
e **sette sono la striscia dei Doni, tutta a dodici punti**, cioè al pavimento
tipografico. **Il numero era otto e l'ho corretto rimisurando il censimento**:
i cinque cerchietti "?" sono lo stesso testo e il censimento li raccoglie in
una riga sola, quindi la striscia porta sette righe e non otto. I quattordici
si dividono in quattro inviti al gesto, sette della striscia e tre fuori scala. Il fondatore ha già deciso che l'uniformazione tocca i soli testi
da leggere: alzare i testi brevi è materia sua. **Non si esegue, si riporta.**

**CF.17, le lapidi del benvenuto.** Sono **tre e non due**, contro la premessa
dell'ordine. Una è `cloud@esotericircle.app`, di prova; una è
`maobatta@gmail.com`, cioè l'account personale del fondatore; la terza è del 30
agosto alle 20:39 e col sale vuoto non si riconosce, quindi è già scritta col
pepe. L'ordine dice di fermarsi se una delle due non è un indirizzo di prova, e
non lo è. **E comunque l'impronta col pepe dal lato di chi lavora non si
calcola**: il pepe non si legge mai, quindi l'unico posto che può ricalcolarla
è la funzione stessa.

**CF.04, le push.** Parte uno fatta: nella pagina delle notifiche c'è un blocco
che dice quante chiamate il telefono ha davvero in coda e un gesto che ne manda
una subito. Serve a distinguere due difetti che da fuori si vedono uguali, il
Cerchio che non programma e il telefono che non esegue. **Le push vere sono
dichiarate e non scritte**, coi quattro pezzi che servirebbero, perché la
registrazione del token non si esercita in nessuna prova.

## LE REGOLE CHE GOVERNANO IL LAVORO

- **Regola zero.** Il testo di un ordine non è affidabile e chi lo ha scritto
  non è affidabile: ogni affermazione si verifica sul ramo prima di lavorarci,
  **comprese le misure**. Una misura scritta in un rapporto precedente non è
  una misura di adesso. **E vale anche sulle proprie**: in CF una premessa
  caduta su due era mia.
- **Regola uno.** Non ci si ferma davanti a un ostacolo, si risolve.
- **Regola due.** Le decisioni delegate si prendono e si motivano per iscritto.
  Le decisioni di prodotto che il fondatore non ha delegato non si prendono: si
  riportano come fatti.
- **Prova del rosso.** Ogni prova nuova si dimostra rossa reintroducendo il
  difetto, e **l'iniezione si verifica prima di leggere l'esito**. Quando il
  rosso non scatta si cambia la grandezza misurata, mai la soglia.
- **Lingua.** Italiano, accenti veri, mai il trattino lungo, mai una
  proposizione dopo la virgola con "e".
- **Consegna.** Suite Flutter intera con `TZ=Europe/Rome`, `npm test` dentro
  `functions/`, `bash tool/sbarramento.sh`, `flutter analyze` a zero avvisi. Si
  committa e si spinge voce per voce, e il rapporto porta lo sha letto con
  `git ls-remote`.

## LE TRAPPOLE CHE HANNO MORSO IN QUESTO GIRO

**Le guardie possono essere cieche, e il segno è sempre lo stesso**: un difetto
si vede a video e la prova resta verde. Quando succede, il buco è nella
guardia, non nell'occhio. In CF ne sono state trovate quattro.

1. **La guardia dei fondi cercava i nomi del framework.** Dopo che fogli e
   dialoghi sono passati sotto la porta comune del velo, ne trovava **tre
   invece di trentaquattro** e per poco dichiarava guarita un'app che aveva
   solo cambiato parola.
2. **La guardia degli accenti era cieca due volte**: l'apostrofo protetto nel
   codice le nascondeva la parola, e l'elenco non conosceva la forma con la
   sola iniziale maiuscola. `PERCHE'` è arrivato fino all'anteprima.
3. **La regola dei cartigli non era sorvegliata da nessuno**, e il difetto lo
   ha visto il fondatore guardando l'immagine.
4. **La prova di CE.04 si accontentava di una menzione**: cercava il nome del
   budget nel file e non dove la riga fosse montata.

**Le convenzioni di casa che si pagano se si ignorano.**

- **I cartigli delle carte VIP si scrivono a runtime.** Gli artwork hanno le
  targhe vuote di proposito, così un set solo vale per tutte le lingue: chi
  monta `Image.asset` nudo monta l'arte senza chi la posa. Si passa sempre da
  `VipFramedPortrait`.
- **Nel ruolo lettura la porta è `ParagrafiDiLettura`**, mai un `Text` nudo,
  altrimenti torna il muro di testo.
- **Il prefisso `nomeDe...` è riservato** ai nomi che devono dichiarare
  singolare o plurale: usarlo per altro fa cadere la guardia che evita "I tuoi
  Stella".
- **Le misure tipografiche scritte a mano possono solo scendere.** Se una
  schermata ne ha già, non se ne aggiungono copiando: si estraggono.
- **Due censimenti vanno rigenerati quando il codice cambia**:
  `dart run tool/censimento_tipografia.dart` e
  `dart run tool/censimento_spazi.dart`.
- **Lo spazio che sembra vuoto può essere un bersaglio del dito.** Nella
  striscia dei Doni i diciassette punti "vuoti" erano la stanza del bersaglio
  dell'aiuto da quarantaquattro.
- **Una voce nuova in un menu spinge le altre sotto la piega**, e i tocchi
  delle prove smettono di arrivare: serve `ensureVisible` o
  `scrollUntilVisible`.

**Le trappole del trasporto, che non riguardano il codice.**

- **Gli heredoc di Bash mangiano apostrofi e barre.** Si scrivono script
  Python con lo strumento Write e si eseguono, e ogni sostituzione porta il suo
  `assert` sul conto delle occorrenze.
- **Mai `git checkout` per annullare**: cancella il lavoro non committato nello
  stesso file. In questa sessione è successo una volta.
- **La suite intera dura circa venticinque minuti** e sotto carico produce
  cadute che da sole non si ripetono: ogni caduta si riverifica lanciando quel
  file da solo prima di chiamarla difetto.
- **L'uscita della suite si scrive su file**, mai in pipe a `tail`: il rapporto
  tronca l'elenco finale e i nomi veri stanno nelle righe `[E]`.

## IL DEBITO ANCORA APERTO

`docs/ordini/RIPRESA.md` porta il debito dell'ordine CE voce 02, cioè
l'attribuzione automatica dell'invito, con lo studio già fatto in
`docs/studi/attribuzione_automatica_dellinvito.md`.

L'unico rosso accettato è dichiarato in `tool/rossi_accettati.txt`: torna verde
quando le frasi dei Maestri saranno riscritte e la misura rifatta.
