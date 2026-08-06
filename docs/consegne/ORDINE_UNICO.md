# ORDINE UNICO, quattro voci. Dove sono arrivato

Scritto il 6 agosto 2026, a sessione ancora aperta, perche' l'ordine lo chiede
a chi si ferma. **Non e' un riassunto di comodo: e' il punto esatto in cui
lasciare il lavoro, con quello che ho verificato e quello che non ho toccato.**

Ramo: `claude/ordine-unico-b1e463`, nato dal canonico aggiornato a distanza zero
nei due sensi da `6a40e2d`, e gia' spinto sul canonico a ogni voce chiusa.

## Cosa e' fatto e spinto

- **Voce 4, l'intro video.** Chiusa prima di questo ordine e consegnata come
  build 2150, commit `83e8617`. Poi l'aggiunta col video nuovo, commit
  `5cb1885`: `Intro-Test-3` convertito dal SORGENTE e non dal convertito
  precedente, il secondo tolto dal pacchetto, la prova che conta i file nella
  cartella dell'intro invece di nominarli.
- **Voce 1, l'emblema dell'archetipo.** Commit `b3dec34`. La voce dedicata in
  `STATO_VIVO.md` la racconta per intero, ma **tre cose vanno ripetute qui,
  perche' nessuno le ritroverebbe da solo**:
  1. **Le copie del dato erano TRE, non due.** Oltre alla schermata del Test,
     anche quella dell'Animale Guida si costruiva il proprio `ArchetypeHistory`.
     Chi va a caccia della seconda copia si ferma prima di trovare la terza: la
     prova che le conta enumera tutti i file di `lib`, e va lasciata li'.
  2. **Sotto la doppia copia c'era una CORSA.** `carica()` parte all'avvio e la
     lettura del disco impiega qualche istante: chi in quegli istanti finiva il
     Test vedeva il proprio esito entrare in memoria e poi sparire, sostituito
     dalla lista vuota che la lettura riportava. Non si vede leggendo il codice,
     si e' vista solo strumentandolo. E' corretta contando le scritture avvenute
     durante la lettura.
  3. **Il disco non ha MAI registrato la figura rieletta dai transiti.** Il
     blocco che registra e' identico byte per byte dal 22 luglio 2026 e nessun
     commit ha mai scritto il profilo modulato: quindi non c'e' e non c'e' mai
     stato nessun dato da riparare. **Mentiva la scena, non il dato.** Chi
     riprende non deve andare a caccia di storici da correggere.

## Voce 2, cosa e' fatto

Fatto e spinto, dopo la ripresa del 6 agosto:

- **Le etichette invisibili**, causa trovata e chiusa: alpha a uno su 255. Vedi
  la voce in `STATO_VIVO.md`, e la nota qui sotto sulla premessa 2b, che resta
  perche' racconta come ci si e' arrivati.
- **"In arrivo" tolto** dalla parola del giorno.
- **La lingua della Luna** e la coda in cifre del respiro.
- **Il respiro guidato**, con la figura che si espande e si contrae, il
  conteggio dei giri, e il conteggio che resta anche con Riduci Movimento.

## Cosa NON e' fatto

- **Voce 2, LE DUE ANTEPRIME.** Servono a 1080x2391: la scheda intera senza
  vuoti e il simbolo al culmine dell'espansione. Nessuna delle due esiste.
- **Voce 3, la striscia Sentieri.** Non cominciata, premesse non enumerate.
- **La build e la consegna delle voci 2 e 3.** La ordina Mauro, non chi lavora.

## Voce 2, il resto che e' stato chiuso il 6 agosto

- **LA RISPOSTA.** `lib/core/rituals/risposta_del_soffio.dart`. Due righe, cosa
  si apre e cosa oggi non si lascia forzare, dai transiti veri attraverso
  `CieloDiOggi.perIlGiorno`, che e' la porta gia' usata da Oroscopo e Rito
  dell'Alba: nessuna seconda porta, e una prova trasversale lo sorveglia
  cercando nel sorgente i nomi dei motori che NON deve chiamare. La riga di
  cio' che si apre nasce dall'aspetto morbido piu' stretto, quella di cio' che
  non cede dall'aspetto teso piu' stretto: **quando una delle due famiglie non
  c'e' nel cielo di quel giorno, la riga non compare e non ne compare una al
  posto suo**, e la prova pretende che il caso capiti davvero almeno una volta
  in centoventi giorni, altrimenti non avrebbe mai misurato l'assenza.
  Una prova vieta la forma dell'Alba, cioe' l'imperativo, elencando i verbi con
  cui l'Alba apre le sue frasi: **ha preso due mie voci**, "ti fai riconoscere"
  e "ti fai capire", perche' in italiano `fai` e' insieme indicativo e
  imperativo. Le ho riscritte invece di ammorbidire la prova.
- **LA MISURA DEL PRATO**, che l'ordine chiedeva di misurare e non di decidere.
  I due livelli pesano 1.617.444 byte in tutto, `breath_meadow.png` 833.961 e
  `breath_dandelion.png` 783.483. Il prato e' nominato in **un solo punto** di
  `lib`. Ma **non e' un widget di sfondo**: e' un livello dentro un pittore di
  **236 righe** che nella stessa tela disegna anche il soffione e i semi che
  volano al soffio, cioe' il gesto del rito. Togliere il prato obbliga a
  decidere cosa succede al soffione, e quella e' una riscrittura del pittore.
  **Non e' un'ora.** La destinazione pero' esiste gia' ed e' precedentata:
  `CosmosBackground` e' il cosmo condiviso, e il Rito del Sogno lo usa gia'.

**La build col video nuovo invece e' stata fatta subito**, per decisione di
Mauro e saltando l'ordine delle voci: l'intro e' la prima cosa che si vede e
sul telefono c'era ancora il video secondo. E' la **2151**, e i suoi numeri
stanno in `STATO_VIVO.md`.

## Voce 2, le premesse come le ho verificate

**2a. Vera in parte, e la forma esatta conta.** L'etichetta `PAROLA DEL GIORNO`
esce da `lib/features/rituals/ritual_gift_card.dart:168`, dentro `RitualGiftCard`,
che e' la stessa scheda usata dal Soffio (`breath_destiny_screen.dart:326`) e dal
Rito dell'Alba (`dawn_rite_screen.dart:450`). Sotto l'etichetta **non c'e' il
vuoto**: quando `word` e' nullo compare la scritta `In arrivo`. E' peggio del
vuoto, non meglio, perche' e' esattamente il campo che dice alla persona di
aspettare qualcosa, che le regole dell'ordine vietano. La parola arriva da
`DawnGift.word`, riempita da `rito?.parola` in `dawn_gift.dart:178`: quando il
rito del giorno non porta una parola, il campo resta nullo.

**E NON E' LA PRIMA DELLA SUA FAMIGLIA.** Il Rito dell'Alba diceva la stessa
cosa con altre parole, `In attesa dei contenuti astrologici verificati`, ed e'
gia' stata chiusa. E' esattamente lo stesso difetto: un campo che PROMETTE
qualcosa alla persona invece di darglielo o di sparire. Chi riprende deve
saperlo, perche' la soluzione buona esiste gia' nel progetto e non va
reinventata: o il campo si riempie, o il campo non c'e'. Mai una terza cosa che
dice di aspettare.

**2b. Falsa nella forma, e il difetto vero e' PEGGIORE.** I due pulsanti hanno il
loro testo, scritto in chiaro nel codice: `Da dove nasce questo dono`
(`ritual_gift_card.dart:258`, con l'icona info e la freccetta) e `Condividi la
parola` (`ritual_gift_card.dart:407`, dentro un `TextButton.icon` col bordo).
Nessuna etichetta vuota nel sorgente.

**LA MISURA DI MAURO, che chiude la questione.** Io avevo fermato la mia
indagine a un'ipotesi: che fino al 5 agosto 2026 l'accento della scheda fosse
una costante unica e che su vetro chiaro il testo risultasse illeggibile, col
rapporto di contrasto minimo imposto in `_accentoDi(Maestro)` ed entrato solo
nella 2150. **Quell'ipotesi e' sbagliata, e non l'ha smontata un ragionamento:
l'ha smontata una misura.** Mauro ha ritagliato dallo screenshot la zona dei due
pulsanti e ha spinto il contrasto al massimo: il bordo esce **nero netto** e
dentro **non emerge nessun glifo**. Se il testo ci fosse a contrasto basso, lo
stesso trattamento che ha rivelato il bordo avrebbe rivelato anche le lettere.

Quindi: **le etichette esistono nel codice e a schermo non compaiono. Non e' un
problema di contrasto, e' testo che non arriva alla resa.** La causa e' da
TROVARE, non da indovinare, e le strade aperte sono almeno tre: il colore uguale
al fondo, il testo tagliato dal riquadro che lo contiene, oppure il pulsante
costruito senza figlio su quel ramo. Chi riprende **non deve ricominciare
dall'ipotesi del contrasto**: e' gia' stata provata e scartata con una misura.

Le due anteprime che esistono oggi, `soffio-destino-dono.png` e
`rito-alba-dono.png`, si fermano prima dei pulsanti: per guardarli serve una
cattura piu' alta della scheda, ed e' il primo passo.

**2c. Vera.** Il fondale e' `assets/ritual_backgrounds/breath_meadow.png`,
composto in `breath_destiny_screen.dart:89` insieme al soffione: prato e cielo
diurni, non il cosmo condiviso. E' un canvas dipinto a livelli, non un widget di
sfondo riusabile, quindi toglierlo non e' cambiare una riga. **Non ho misurato
quanto costa**, e l'ordine lo chiedeva: e' la prima cosa da fare riprendendo.

**2d. Il simbolo NON respira.** Ci sono due controllori, `_disperse` (la
dispersione del soffione al gesto, `easeOutCubic`) e `_ambient` (brezza e
brillio, un moto continuo di sfondo). Nessuno dei due e' legato ai tempi del
respiro dichiarati dal testo: il testo dice "sei tempi dentro e sei fuori, tre
volte" e il simbolo fa altro.

## Le rotture di lingua, viste a video e non nel sorgente

Nell'anteprima `soffio-destino-dono.png`, che e' la scheda vera a 1080x2391:

- `La Luna è Luna calante.` La frase si compone col nome della fase, e per
  alcune fasi esce ripetuta o sgrammaticata. Mauro cita `La Luna e' Ultimo
  quarto`, che e' la stessa rottura su un'altra fase.
- `(6 tempi, 3 giri)` in coda a `Sei tempi dentro e sei fuori, tre volte`: le
  cifre ripetono cio' che la frase ha appena detto in parole.

Tutte e due stanno nel corpus dei riti, non nella schermata.

## Quello che chi riprende deve sapere, e che non e' scritto altrove

- **Le anteprime si scrivono in `docs/preview` solo con `AGGIORNA_ANTEPRIME=1`
  nell'ambiente.** Senza, finiscono in `build/preview` e sembra che la cattura
  non abbia fatto niente.
- **Il precarico va fatto prima di ogni scatto che mostra arte**, e la cattura
  lo fa gia' da sola: quello che NON fa da sola e' il precarico di un'immagine
  che compare solo in quella scena, come l'emblema dell'archetipo.
- **Montare l'app intera in prova richiede `onboarding.done` a vero**, altrimenti
  il Risveglio si spinge SOPRA lo shell e niente del Santuario e' raggiungibile.
- **`CosmicPassport` ha gia' il suo scorrimento dentro**: avvolgerlo in un
  `SingleChildScrollView` lo fa esplodere in altezza non vincolata.
- **Il guardiano della lingua legge anche i nomi di variabile interpolati**
  dentro una stringa mostrata. Una variabile chiamata `identita` dentro
  `'... ${identita.qualcosa}'` viene letta come una parola italiana senza
  accento, e ha ragione lui.
