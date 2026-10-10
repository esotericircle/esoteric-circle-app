# Real Time Cosmo, estratto della specifica per Code

Estratto dell'8 ottobre 2026 da `claude/Specifica_Real_Time_Cosmo_Esoteric_Circle.md`,
che vive nel Project e che Code non puo' leggere. Contiene le sezioni chieste da Code
nel rapporto di fermata dell'ordine FG, 1-bis, 1-ter, 4, 5, 6 e 14, piu' la 4-bis
scritta dopo quel rapporto. Le altre sezioni non sono qui.

Questa versione dell'estratto **e' posteriore alle tre misure di Code sulla testa
`2a7b6864`**: le righe che quelle misure hanno smentito sono corrette dentro le
sezioni, con la riga vecchia lasciata al suo posto e la correzione accanto.

**Avvertenza aggiunta da Code alla copia nel repository, approvata dal fondatore
l'8 ottobre 2026 (ordine FG, aggiunta A2).** La sezione 4 dice ancora che "il
cielo di oggi e' quindi un bel disegno, non il cielo". Quella riga vale per
`lib/core/astro/sky_catalog.dart`, le figure disegnate a mano nel riquadro da 0
a 1, e NON per il Cielo esistente: `SkyOverviewScreen` legge
`assets/data/bright_stars.json` attraverso `SkyCatalog`, cioe' 106 stelle vere
J2000 da Hipparcos. La sezione 4-bis lo spiega per intero. Questa copia, in
`docs/Specifica_Real_Time_Cosmo.md`, e' quella che Code legge da qui in avanti;
l'originale e' `Specifica_Real_Time_Cosmo_estratto_v2.md` (26.001 byte) nella
cartella principale.

---

## 1-bis. LA SCENA DEL RITORNO, ideata da Mauro il 18 agosto 2026

E' la sequenza con cui la persona entra nel proprio cielo di nascita. Nelle
parole di Mauro suona cosi': al centro compare **la sua eta'**, poi il testo
**"STO TORNANDO INDIETRO NEL TEMPO"** mentre il numero dell'eta' **torna
velocemente a zero**; poi **"QUESTO ERA IL CIELO SOPRA DI TE QUANDO SEI
NATO"**; poi **"alza il telefono al cielo e inquadra la Luna"**. Da li' si
costruisce il disegno del cielo con la Luna e le costellazioni.

### La sequenza, atto per atto

1. **L'eta' al centro.** Il numero degli anni compiuti, grande, sul cielo di
   adesso gia' vivo intorno alla persona.
2. **Il ritorno.** "STO TORNANDO INDIETRO NEL TEMPO" mentre il numero scende
   accelerando fino a zero.
3. **L'arrivo.** "QUESTO ERA IL CIELO SOPRA DI TE QUANDO SEI NATO", col cielo
   fermo sul suo istante.
4. **Il gesto.** L'invito ad alzare il telefono e inquadrare la Luna.
5. **La costruzione.** Il cielo si compone attorno a lei: la Luna, poi le
   stelle, poi le figure delle costellazioni.

### Aggiunta dell'Architetto numero uno: a tornare indietro e' IL CIELO, non il numero

Un contatore che scende su uno sfondo fermo e' un'animazione qualunque. Ma una
volta che il catalogo esiste, **cambiare la data non costa niente**: il motore
sa gia' calcolare il cielo per qualunque istante. Quindi mentre l'eta' scende,
**il cielo intorno gira all'indietro davvero**: le stelle ruotano al contrario
accelerando, la Luna attraversa a ritroso le sue fasi decine di volte, i
pianeti tornano sui loro passi, mentre le stagioni si vedono passare nella
posizione delle costellazioni. Poi tutto rallenta e si ferma **sull'istante
suo**. Il numero al centro racconta, il cielo che riavvolge e' la cosa che fa
gridare, senza essere un effetto finto: e' il vero cielo, calcolato.

**Nota tecnica da non dimenticare quando si costruira'**: su decenni le stelle
fisse quasi non si spostano, quindi **il senso del movimento non lo danno
loro**: lo danno la rotazione diurna accelerata, le fasi della Luna e il moto
dei pianeti. Se la scena venisse costruita facendo scorrere solo gli anni senza
la rotazione veloce, sembrerebbe immobile.

### Aggiunta dell'Architetto numero due: la Luna non e' quella, il che e' un bene

**Il problema.** La Luna di stanotte non e' la Luna della nascita: quella stava
in un'altra posizione, in un'altra fase e magari sotto l'orizzonte. Dire
"inquadra la Luna" e poi mostrare il cielo di nascita fa suonare una stonatura
a chiunque ci faccia caso, contro la regola della promessa mantenuta.

**La soluzione, che vale piu' del problema.** La Luna di stanotte serve a
**calibrare**. Il telefono da solo sbaglia il nord di parecchi gradi col
magnetometro, mentre inquadrare un oggetto vero e' il modo migliore per rimettere
in bolla la bussola. Quindi la frase diventa, nella sostanza, **"punta la Luna
di stanotte: ti riporto a quella della tua nascita"**: la persona compie un
gesto sul cielo VERO, l'app si allinea con precisione, poi il cielo di
adesso si dissolve in quello del suo primo istante. Il gesto acquista un senso,
la calibrazione diventa rito invece che impostazione, la precisione ci
guadagna sul serio. **I testi finali sono di Mauro**, questa e' la sostanza da
dire.

**Se la Luna di nascita era sotto l'orizzonte**, non si finge: si dice, indicando in basso. E' un momento bello e vero, coerente con cio' che l'app
gia' fa altrove, cioe' dichiarare un corpo sotto l'orizzonte con l'ora in cui
sorge invece di nasconderlo.

### Correzione dell'8 ottobre 2026 all'aggiunta numero due: la calibrazione scende da obbligo a offerta

La regola scritta sopra nasceva pensando a una persona in piedi in giardino.
Mauro ha fatto notare un fatto che la supera: **l'app non ha bisogno di essere
all'aperto**, mentre la maggior parte della gente la userà in casa o a letto, dove
la Luna non c'è. Quindi la calibrazione sull'oggetto vero **scende da passaggio
obbligato a scorciatoia opzionale**, mentre il caso normale diventa quello senza.

**Nessuna domanda all'ingresso.** È stata valutata e scartata l'ipotesi di
chiedere alla persona "sei all'aperto o al chiuso?" prima del cielo: una
domanda in quel punto è un pedaggio nel momento in cui l'utente vuole solo
vedere, perciò viola la regola del primo sguardo, che vuole una sola azione
protagonista per schermata. La decisione è stata lasciata all'Architetto da
Mauro. La via scelta è questa: **il motore sa già** se in questo istante, da
dove si trova la persona, c'è la Luna o un pianeta brillante sopra l'orizzonte.
Se non c'è, non si propone niente. Se c'è, compare una riga discreta e
ignorabile del tipo "la Luna è lassù, puntala per essere preciso". Chi è al
chiuso non la vede nemmeno, chi è fuori guadagna precisione. Se in futuro si
vorrà la domanda esplicita, va messa come interruttore dentro il menu della
funzione, mai all'ingresso.

### Aggiunta dell'Architetto numero tre: le vie di scampo, perche' e' il primo minuto

**La Luna puo' non esserci**: di giorno, sotto l'orizzonte, con le nuvole, o se
la persona e' in casa. Servono due vie che non spezzano la magia:

- **Un altro punto d'aggancio**: il Sole di giorno, oppure un pianeta brillante
  la sera. Il motore sa gia' quale e' visibile adesso e da che parte sta.
- **Il dito**: se non c'e' niente da inquadrare, si esplora trascinando e la
  calibrazione si salta **dichiarandolo**, senza far sembrare rotta la scena.
  E' la regola di casa dei sensori col fallback tattile, che qui vale doppio
  perche' e' il primo minuto di vita dell'utente.

**Chi non ha dato l'ora di nascita** e' l'altro caso da gestire. Senza ora il
cielo del suo istante e' approssimato, quindi l'app oggi ripiega su mezzogiorno
saltando l'Ascendente con grazia. **Quella scena e' il momento perfetto per
dirglielo e chiedergliela**: li' la persona ha una ragione emotiva per andare a
cercarla sui documenti, cosa che davanti a un modulo di registrazione non
farebbe mai. Si dice la verita' ("senza l'ora posso portarti al giorno, non
all'istante") e si offre la via per completarla.

### Perche' questa scena vale anche in termini di crescita

E' **la cosa piu' condivisibile che l'app possa produrre**: un video di venti
secondi in cui gli anni si riavvolgono e il cielo torna indietro fino alla
notte in cui sei nato gira da solo sui social. E' nostro, non copiabile
senza il motore. Va quindi progettata fin dall'inizio come qualcosa che **si
puo' rivedere e mandare a qualcuno**, non solo come un'apertura che si vede una
volta sola. Si collega alla voce dell'attribuzione degli inviti in
`claude/Coda_Aperta`, perche' e' esattamente il tipo di contenuto che porta
installazioni vere.

### Dove vive nel piano

La scena appartiene alla **fase C** (sezione 7), perche' richiede il catalogo
della fase A e l'orientamento della fase B. Il pezzo del **riavvolgimento** si
puo' pero' provare gia' in fase A, appena il cielo si disegna, perche' non
dipende dai sensori: e' solo la data che cambia.

### Decisione dell'8 ottobre 2026: dove sta il riavvolgimento

L'Architetto aveva proposto di togliere il riavvolgimento dall'onboarding e di
farne la transizione fra i due cieli dentro la funzione, per non rallentare il
primo ingresso. **Mauro ha deciso diversamente. La sua soluzione è migliore**
perché non aggiunge niente di nuovo e usa un posto che esiste già:

- **il riavvolgimento resta nell'onboarding**, dove è l'effetto wow del primo
  minuto;
- **si rivede dal Passport**, dentro la voce che c'è già, "il tuo cielo di
  nascita", dove il countdown viene inserito.

Resta un rilievo tecnico dell'Architetto, dichiarato perché cambia il lavoro:
il riavvolgimento è **la scena più cara della funzione**, perché ricalcola il
cielo molte volte al secondo mentre gli anni scorrono. Nell'onboarding capita
nel minuto in cui l'app è appena installata. Va misurata sul telefono lento con
un tetto dichiarato. Se sul telefono lento non regge, si riduce il numero di
istanti calcolati e non la fluidità. Per chi ha attivo Riduci Movimento la
corsa diventa un passaggio secco, come già prevede la sezione 6.

## 1-ter. IL CAMPO VISIVO E LE FRECCE DI GUIDA

**Sezione nuova dell'8 ottobre 2026**, nata dalla clip registrata da Mauro e
dalle sue due richieste.

### Il campo di partenza è largo, non stretto

Richiesta di Mauro: meno zoom, partire da una specie di panoramica e poi avere
la possibilità di zoomare, perché con la panoramica si guadagna stabilità e
campo visivo.

**Il motivo tecnico, che la conferma.** Il tremolio della mano è di un grado o
due e non cambia mai. Quanti pixel valgono quei due gradi dipende però dallo
zoom: a campo stretto diventano mezzo schermo, a campo largo diventano un
centimetro. Partire panoramico non è quindi solo una scelta estetica, è la cosa
che rende il cielo fermo. Vale doppio per chi usa l'app sdraiato.

**Come si fa.** Campo di partenza intorno ai settanta gradi, che è più o meno
quello che abbraccia un occhio. Il pizzico stringe fino al dettaglio e allarga
fino alla panoramica. **Il filtro del movimento si fa più severo man mano che
si stringe**, in automatico, così anche da vicino l'immagine non balla.

### Le frecce sanno chi sei

Richiesta di Mauro: delle frecce laterali che aiutino a trovare l'obiettivo,
per esempio la costellazione del proprio segno.

**La forma che propone l'Architetto, approvata l'8 ottobre 2026.** Non una
freccia generica che indica una direzione, ma un indicatore che sa chi è la
persona: "il tuo Leone è da questa parte, a trentadue gradi", con la distanza
che scende mentre ci si avvicina, il nome che si accende e la freccia che
sparisce quando il bersaglio entra in quadro. Lo stesso meccanismo serve per la
Luna piena di stanotte, per un pianeta della propria carta natale e per
qualunque appuntamento del Calendario degli Eventi.

È una delle differenze che si sentono al primo uso: le app di astronomia ti
fanno cercare, noi ti accompagniamo, perché sappiamo che cosa stai cercando.

## 4. Cosa manca, misurato

**Il catalogo stellare vero.** `lib/core/astro/sky_catalog.dart` lo dichiara
nel proprio commento, testualmente: nel repo non c'e' un catalogo J2000
completo con le coordinate equatoriali, quindi le costellazioni sono
**disegnate a mano** nelle loro forme classiche, in un riquadro locale
normalizzato da 0 a 1. L'Ariete sono quattro `Offset` messi a occhio con una
luminosita' relativa inventata. Il cielo di oggi e' quindi un bel disegno, non
il cielo. Serve un catalogo con **ascensione retta, declinazione, magnitudine
e indice di colore**, piu' le **linee degli asterismi** e, se si vuole
l'evidenziazione per area, i **confini IAU**.

**L'orientamento assoluto del telefono.** Per stare dentro la sfera serve
l'orientamento fuso, cioe' il vettore di rotazione che combina giroscopio,
accelerometro e magnetometro, non il solo tilt che la parallasse usa oggi. Va
verificato se `sensors_plus` 6.1.1 lo espone gia' o se serve un'aggiunta. Serve poi la **declinazione magnetica** per passare dal nord magnetico al nord
vero, che si ricava dalla posizione. **La calibrazione sulla Luna della
sezione 1-bis nasce proprio per correggere l'errore residuo di questa catena.**

**Il disegno a lotto unico.** Sono le chiamate che mandano migliaia di elementi
alla scheda grafica in una volta sola, cioe' la strada obbligata per un cielo
popolato e fluido. Al 18 agosto 2026 questa scheda dichiarava che nessun punto
del progetto le usasse. **Correzione dell'8 ottobre 2026, misurata da Code sulla
testa `2a7b6864`: `drawAtlas` e' gia' chiamato una volta**, in
`lib/features/sigilli/spirale_di_stelle.dart`, una sola chiamata per fotogramma,
con circa 2.600 stelle. `drawRawPoints` e `drawVertices` non compaiono da nessuna
parte. Quella chiamata e' il precedente da copiare, perche' e' lo stesso metodo
che serve al cielo e porta con se' misure gia' prese.

## 4-bis. IL CIELO ESISTENTE HA GIÀ UN CATALOGO VERO, con due cataloghi destinati a convivere

**Sezione nuova dell'8 ottobre 2026**, da una misura di Code sulla testa
`2a7b6864` che ha smentito una premessa dell'ordine FG.

**Il fatto.** Un cielo disegnato da un catalogo vero esiste già nell'app ed è
proprio il Cielo esistente. `SkyOverviewScreen`, in
`lib/features/santuario/sky_overview_screen.dart`, legge
`assets/data/bright_stars.json` attraverso `SkyCatalog` in
`lib/core/astro/sky.dart`. Quel file contiene **20 costellazioni e 106 stelle**
con coordinate J2000 da **Hipparcos, ESA 1997**, più le linee degli asterismi.

**Cosa resta vero della sezione 4.** Le figure disegnate a mano in un riquadro
normalizzato esistono davvero, ma stanno in `sky_catalog.dart` e non sono
l'unico cielo dell'app.

**Un'altra precisazione sulla stessa classe.** Il Cielo di nascita e il Cielo
sopra di te adesso non sono due schermate: sono **una classe sola con due
rotte**, `route()` per il cielo di adesso e `birthRoute()` per quello di
nascita. Il divieto di non toccarle si scrive quindi sulla classe e sulle due
rotte, non su due file.

**La conseguenza, che è un debito e va dichiarata come tale.** Finché la
sostituzione non è decisa, il Cielo esistente non si tocca, quindi nell'app
vivranno **due cataloghi per le stesse stelle**, HYG per il Real Time Cosmo e
Hipparcos per il Cielo esistente. È la famiglia delle due porte, che in questo
progetto è la più numerosa. Qui è ammessa solo perché è temporanea e
dichiarata.

**La data di chiusura del debito è la decisione di Mauro sulla sostituzione.**
Se decide di sostituire, esce Hipparcos insieme alle due rotte vecchie. Se
decide di non sostituire, esce HYG. Non esiste il terzo caso in cui restano
tutti e due, perché due cataloghi che descrivono le stesse stelle divergono
sempre. È esattamente il difetto che questo progetto ha già pagato diciannove
volte.

**Le linee degli asterismi del Cielo esistente non violano la regola sulle
licenze.** Quella regola riguarda il lavoro nuovo: dal Real Time Cosmo non si
prende niente da Stellarium. Le linee che il Cielo esistente ha già vengono da
un'altra fonte e restano dove sono.

## 5. Le licenze dei dati, verificate il 18 agosto 2026

**Questa e' la sezione che va letta prima di scrivere una riga di codice.** La
lezione e' gia' pagata con Swiss Ephemeris, dove una licenza scoperta a lavoro
fatto avrebbe buttato via settimane.

**HYG Database (Hipparcos, Yale, Gliese), la scorciatoia piu' comoda:
`CC BY-SA 4.0`.** Letto dal file di licenza del progetto. Attribuzione
obbligatoria e **ShareAlike**: ogni adattamento va distribuito con la stessa
licenza. Lo stesso vale per ATHYG, la sua versione con tutto Tycho-2.

**VizieR e CDS, da cui si scaricano i cataloghi originali: uso libero in
contesto scientifico, uso commerciale NON garantito in blocco.** Testualmente,
le regole dicono che i dati sono liberi in un contesto scientifico e che l'uso
commerciale e' soggetto a regole **che dipendono dall'origine del singolo
catalogo**, quindi va guardato il file ReadMe di ciascuno. Non e' un semaforo
verde e non e' un semaforo rosso: e' un obbligo di verifica per catalogo.

**ESA, che pubblica Hipparcos, Tycho e Gaia: `CC BY-SA 3.0 IGO` come
impostazione dichiarata**, con ShareAlike sulle opere derivate e la possibilita'
di chiedere una deroga per modifiche sostanziali che non si possano ripubblicare
con quella licenza.

**Le linee delle costellazioni di Stellarium: `GPLv2+`.** Nella discussione
ufficiale del progetto viene detto che il tema occidentale standard sta sotto
GPLv2+ perche' i file di dati non hanno una licenza separata. L'autore delle
linee ha concesso una **rilicenza individuale** a chi gliel'aveva chiesta, il
che **non e' un permesso pubblico**: servirebbe un permesso nostro. L'arte
delle costellazioni di Stellarium ha una licenza ancora diversa, la Free Art
License. **Da qui non si prende niente senza permesso scritto.**

### Cosa se ne ricava, che non e' una condanna

- **I fatti astronomici non sono opera d'ingegno.** Ascensione retta,
  declinazione e magnitudine di una stella sono misure, che non si
  possono possedere. Cio' che si protegge e' **la raccolta**: in Europa esiste
  il diritto sui generis sulle banche dati, che tutela l'investimento di chi ha
  compilato. Quindi copiare HYG in blocco e' una questione di licenza, mentre
  **costruire il nostro sottoinsieme dalle fonti primarie** e' una strada piu'
  pulita, oltre che tecnicamente migliore.
- **Il ShareAlike non contagia l'app.** Le licenze Creative Commons non sono
  virali come la GPL sul programma intero: cio' che deve restare con la stessa
  licenza e' **il file di dati derivato**, non il codice di Esoteric Circle.
  Pubblicare il nostro file di stelle sotto BY-SA non regala nulla di
  prezioso, perche' contiene coordinate di stelle, senza toccare il sorgente
  chiuso dell'app. **Va comunque deciso da Mauro**, perche' e' una scelta di
  postura e non solo tecnica.
- **Le linee degli asterismi sono il punto piu' delicato**, perche' li' c'e'
  davvero un lavoro creativo di qualcuno. Tre strade: chiedere il permesso
  scritto all'autore; usare una fonte con licenza permissiva verificata; oppure
  **disegnarle noi**, che per i soli dodici segni piu' cinque figure celebri e'
  un lavoro d'arte alla portata di Mauro e ha il vantaggio di essere nostro per
  sempre.
- **L'arte in semitrasparenza dei dodici segni e' gia' nostra**, il pezzo
  che vale di piu': gli emblemi in `assets/img/zodiac` sono stati fatti e
  scontornati per questo progetto.

**Questione aperta che decide Mauro, non l'Architetto**: se si accetta di
pubblicare il file di dati derivato sotto ShareAlike, oppure se si costruisce
tutto da fonti primarie con verifica per catalogo. La prima e' piu' rapida di
settimane, la seconda e' piu' libera.

## 6. La strada tecnica proposta

**Le stelle si disegnano con un atlante, non con una sfocatura.** Un solo
sprite di stella preparato una volta, disegnato per tutte le stelle con
`drawAtlas`: una chiamata per fotogramma, colore e dimensione per stella dalla
magnitudine e dall'indice di colore. L'alone viene **dalla texture**, non da un
`MaskFilter` calcolato ogni volta. E' esattamente la lezione dell'ordine AF
sulle lampadine e dell'ordine AJ sui pittori: **niente sfocature per
fotogramma**, che e' anche cio' che tiene la funzione al riparo dalle sorprese
di Impeller.

**Il peso e' minuscolo.** Un sottoinsieme fino alla sesta magnitudine sono
**5.071 stelle**; impacchettate in binario con quattro campi valgono circa
sessanta kilobyte. Il vincolo non e' lo spazio, e' la licenza.

**Il numero viene da una misura, non da una stima.** Correzione dell'8 ottobre
2026: fino al 7 ottobre questa riga diceva circa novemila stelle, che era una
cifra andata a occhio. Il catalogo HYG v4.1 è stato scaricato e contato: il
file intero ha **119.626 righe**, fino alla sesta magnitudine ci sono **5.071
stelle**, fino alla nona ce ne sono **83.480**. Quelle con un nome proprio
riconosciuto sono **465**. Dove in questa scheda compariva novemila adesso c'è
il numero vero.

**La sfera.** La persona sta al centro, la camera ha un orientamento preso dal
vettore di rotazione, filtrato per non tremare, mentre le stelle si proiettano dalla
loro altezza e azimut, che vengono da `equatorialToHorizontal`. Il campo visivo
si stringe e si allarga col pizzico.

**Aggiornamento dell'8 ottobre 2026 sul campo visivo**: il valore di partenza è
largo, intorno ai settanta gradi. Il filtro si fa più severo man mano che si
stringe. Il perché sta nella sezione 1-ter.

**Il fallback e' obbligatorio** per regola di casa: senza sensore, o con
sensore rifiutato, si esplora **trascinando il dito**, cosi' la funzione resta
intera. Con Riduci Movimento l'inseguimento e' fermo e si naviga a tocco, mentre
**il riavvolgimento della scena del ritorno diventa un passaggio secco invece
di una corsa**.

**La selezione.** Il tocco cerca l'oggetto piu' vicino in coordinate di
schermo, non ricalcolando tutto il cielo: si tiene una griglia grossolana per
regione di cielo, cosi' la ricerca guarda poche decine di stelle invece di
cinquemila.

**Le informazioni.** Una scheda in tono di Maestro, con la parte astronomica
vera (nome, magnitudine, distanza, quando culmina) e la parte simbolica sulle
tradizioni reali, col disclaimer una volta sola come ovunque nell'app.

**Aggiornamento dell'8 ottobre 2026 sui testi delle schede**: si scrivono da un
corpus dell'Architetto, come è stato fatto per le rune, mai dal modello. Così
la funzione **costa zero in intelligenza artificiale**, che è un fatto che pesa
sul tetto del trenta per cento già raggiunto.

## 14. IL VELO DELLE COSTELLAZIONI, metodo deciso l'8 ottobre 2026

**Sezione nuova dell'8 ottobre 2026.** Riguarda il modo in cui la figura della
costellazione compare sopra le sue stelle, cioè la leva numero uno della
sezione 2 e la fase C della sezione 7.

### Le due strade provate, col perché la prima è stata scartata

**La deformazione, scartata da Mauro.** L'Architetto aveva provato a deformare
la figura del Leone sulle sue stelle vere con una thin plate spline, agganciando
sette punti del disegno a sette stelle. Il giudizio di Mauro: il leone deformato
è semplicemente inguardabile. Il motivo è che le stelle di una costellazione non
stanno dove sta l'anatomia della figura, quindi la precisione geometrica
distrugge il disegno invece di sposarlo.

**Il velo sovrapposto, scelto da Mauro.** Le sue parole: creiamo una forma flat
piena dorata cesellata e la si sovrappone con dissolvenza; quando viene
inquadrata dall'utente, la costellazione si illumina e compare in
semitrasparenza l'immagine. E la precisazione che è venuta dopo e che completa
il metodo: visto che non combaciano, vale la pena che l'immagine sovrapposta sia
staccata dal cielo e dalle stelle per un effetto parallasse e di distanziamento.

**Perché la seconda regge dove la prima cadeva.** Se il velo sta su un piano
davanti al cielo, non deve combaciare: lo scarto fra la figura e le stelle
smette di essere un difetto e diventa profondità. È la stessa ragione per cui
funziona su un atlante antico, dove nessuno si aspetta che il braccio della
Vergine passi per una stella.

### I dodici asset esistono già e sono cotti

I dodici emblemi di `assets/img/zodiac` sono stati trasformati in dodici veli
dorati pre-tarati, consegnati dall'Architetto l'8 ottobre 2026 in
`assets/img/zodiac_velo`, dodici file `velo_<segno>.webp` per 2,5 MB in tutto.
**Code non li genera e non li ritocca**: li usa come sono.

**La taratura è cotta nell'asset e non si rifà sul telefono**, perché usa
percentili sull'immagine e quel calcolo non si fa a ogni fotogramma. La ricetta
è scritta qui per poter cuocere con gli stessi numeri le altre figure il giorno
in cui si faranno:

- luminanza stirata fra il percentile 2 e il percentile 98 dei soli pixel con
  alfa maggiore di 24;
- contrasto 1,70 centrato sulla mediana della stessa popolazione;
- gamma 0,76;
- oro: rosso da 170 a 255, verde da 108 a 200, blu da 28 a 98, cioè verde su
  rosso 0,78 e blu su rosso 0,38 nelle luci;
- alfa del pixel moltiplicata per 0,62 e per (0,38 più 0,62 per la luminanza).

**Perché l'alfa segue il cesello.** È la richiesta di Mauro dell'8 ottobre,
cioè farle più trasparenti aumentando giallo e contrasto, visto che la doratura
si perde con la trasparenza. La via che la realizza non è il colore ma la
trasparenza stessa: le ombre del cesello diventano quasi trasparenti e lasciano
passare le stelle, le luci restano opache. Alleggerire e aumentare il contrasto
sono così la stessa mossa. La taratura approvata da Mauro è quella con fattore
di velatura 0,62 e pavimento 0,38.

### Come si posa il velo sulle stelle

- **La scala.** Si prendono le stelle principali della costellazione, cioè le
  più luminose, da un minimo di cinque a un massimo di dodici, ordinate per
  magnitudine crescente. Il lato del velo è la media geometrica di larghezza e
  altezza del loro riquadro a schermo, moltiplicata per 1,25 e divisa per la
  media geometrica delle misure dell'asset.
- **Il centro è il baricentro, non il riquadro.** Il centro del velo è il
  baricentro delle stelle principali pesato per luminosità, con peso pari a 10
  elevato a meno 0,4 per la magnitudine. Il centro del riquadro sbilancia la
  figura quando una stella sta lontana dalle altre, misurato su Vergine,
  Capricorno ed Ariete.
- **A runtime il velo si disegna così e basta**: l'immagine come sta, con
  modalità luminosa sopra il cielo, più un alone che è la stessa immagine
  sfocata a 26 punti logici e miscelata al 40 per cento, dipinta una volta in
  cache.
- **La parallasse.** Il velo sta su un piano davanti al cielo: quando
  l'orientamento cambia, il cielo si sposta poco e il velo molto, con rapporto
  1 a 8,7. Lo scostamento verticale è il 35 per cento di quello orizzontale.
  Il cielo dietro il velo è sfocato a 3,2 punti logici, con la maschera presa
  dall'alfa del velo.
- **Il velo sborda dal riquadro delle stelle ed è giusto così**: è il segno che
  sta su un altro piano. Chi lo ritaglia sul riquadro ha tolto l'effetto.

### Le linee degli asterismi non si disegnano

Per la ragione di licenza della sezione 5: da Stellarium non si prende niente
senza permesso scritto. Il velo sostituisce la linea. Le dodici figure non
zodiacali si cuoceranno con la stessa ricetta quando Mauro deciderà di farle.
