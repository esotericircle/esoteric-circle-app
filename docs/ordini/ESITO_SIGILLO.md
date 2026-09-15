# ESITO dell'ORDINE DI CALIGO

## Dichiarazione, scritta prima di toccare il codice

L'ordine chiede di verificare PRIMA se un Sigillo esiste gia'. **Esiste.**

`art_catalog.dart:653` porta `magic_sigil`, "Sigillo Magico Personale", col
teaser "Trasforma la tua intenzione in un sigillo da caricare", stato in
arrivo. E' la stessa identica cosa che C1 descrive: una intenzione che diventa
un sigillo.

**Quindi unifico, non duplico.** Quella voce diventa il Sigillo
dell'Intenzione e passa ad attiva, invece di nascere una seconda voce accanto
alla prima. Due sigilli che fanno la stessa cosa con due nomi diversi sarebbero
il difetto che l'ordine vuole evitare, oltre a una promessa doppia
fatta alla stessa persona.

**La geometria, contro la regola 21.** La bindrune dell'Estrazione Rune e'
descritta nel suo file: tratti sovrapposti su un'ASTA VERTICALE centrale, alta
il settanta per cento del riquadro, con al massimo dodici rami. Il sigillo
dell'intenzione sara' un CAMMINO SPEZZATO su una ruota di lettere: nessuna
asta, nessun ramo, un percorso poligonale che tocca punti disposti in cerchio.
Le due cose non si somigliano per costruzione, non per accorgimento. Le
guardero' affiancate.

**La stima.**

- **C1 in versione piena.** Il metodo e' matematica semplice: lettere uniche,
  posizioni sulla ruota, un cammino. Il tracciamento a vista e' un
  `AnimationController` che rivela il percorso per lunghezza, cosa che ho gia'
  fatto per l'astrolabio. La classificazione della via e' un elenco di parole
  chiave, deterministico.
- **C2 in versione piena**, coi venti minuti che l'ordine gli assegna.

**Il rischio vero non e' il disegno, sono i testi.** Il filtro sulle
intenzioni che agiscono sulla volonta' di terzi va messo dove il testo nasce,
mentre la riformulazione con garbo deve suonare come Caligo, non come un
regolamento. Se qualcosa scendera' alla versione semplice sara' l'ampiezza del
vocabolario riconosciuto, mai il filtro.

## C1, il Sigillo dell'Intenzione: PIENA

### Il metodo, che e' reale

Il calcolo vive in `lib/core/magic/intention_sigil.dart`, senza un solo numero
casuale in tutto il file.

1. **Lettere uniche**, nell'ordine di prima comparsa. Gli accenti si riducono
   alla lettera base, perche' la ruota ha una sola E e chi scrive "perche'"
   intende quella. Le lettere che l'italiano non usa (J, K, W, X, Y) cadono
   sulla loro vicina.
2. **Cammino sulla ruota**: ventuno posizioni in cerchio, una per lettera,
   unite in ordine da un tratto continuo.
3. **Deterministico**: un test ripete la stessa frase cento volte e confronta.

### Le tre vie

`ViaMagica` porta i tre nomi e i tre domini, in un punto solo: sono
PROVVISORI, dipendono dal confronto di Mauro con Gaetano Daguraz, quindi
cambiarli domani costa una riga. La classificazione e' deterministica su
parole chiave, mentre la schermata dichiara quale via ha riconosciuto e da quale
parola. Se non riconosce nulla lo dice e usa la Bianca, che e' la via della
chiarezza, quindi quella giusta quando non si e' capito.

Un test verifica che la parola si riconosca INTERA: "pace" dentro "capace" non
e' la Via Bianca.

### Il filtro, dove il testo nasce

Sta in `LettoreIntenzione`, non nella schermata: cosi' vale per chiunque usi
il motore, oggi e domani. Le intenzioni che agiscono sulla volonta' di terzi
non si rifiutano, si riformulano: "Fai che lui si innamori di me" diventa
"Apro il mio cuore e mi rendo degno di un legame vero", con la schermata che spiega
perche' l'ha fatto.

**Un difetto trovato dal test, prima che lo vedesse qualcuno.** La spiegazione
della via ripeteva la parola che aveva innescato il filtro: dopo aver
riformulato "si innamori", il riquadro diceva "Ho riconosciuto la Via Rossa
dalla parola si innamori". Rimetteva sotto gli occhi proprio la cosa appena
tolta, suonando come un rimprovero. Adesso, dopo una riformulazione, la
spiegazione parla della via senza citare quella parola.

### La regola 21, guardata affiancata

**Non si somigliano.** Nell'anteprima messa a confronto: la bindrune e'
piccola, dorata, compatta attorno a un'asta verticale, dentro una card;
il sigillo e' bianco, ampio, spezzato, asimmetrico, senza nessun asse.

La differenza non e' un accorgimento grafico, e' la costruzione: due test la
misurano. Il primo verifica che i punti del cammino NON stiano quasi sulla
stessa verticale, che e' cio' che definisce una bindrune. Il secondo verifica
che ogni punto stia esattamente sulla ruota, a distanza 0,38 dal centro.

### Le fonti, dichiarate a schermo

Nella soglia e nella rivelazione: Spare per il metodo delle lettere, la Rosa
dei Petali della Golden Dawn per la ruota, con scritto che la rosa storica
porta lettere ebraiche e che **l'adattamento alle nostre e' nostro**. I testi
sono dichiarati curatela originale del Cerchio. A Spare non si attribuisce
cio' che non ha scritto.

### I test, ventitre'

Quindici sul motore, otto sulla schermata. Fra questi: determinismo su cento
ripetizioni, tre coppie di frasi molto diverse che danno sigilli molto
diversi, tre coppie quasi identiche che danno sigilli simili, cinque frasi
che non collassano mai sullo stesso cammino, il filtro sulle intenzioni verso
terzi, piu' il divieto di promesse di esito su tutti i testi del motore.

## C2, lo scaffale di Caligo: PIENA

### La domanda posta dall'ordine, con la risposta

**Il Sigillo esisteva gia'.** `magic_sigil`, "Sigillo Magico Personale", col
teaser "Trasforma la tua intenzione in un sigillo da caricare", fra i Rituali,
in arrivo. Era la stessa identica cosa che C1 descrive.

Quindi **l'ho spostato, non duplicato**: quella voce e' passata in Magia, ha
preso il nome "Sigillo dell'Intenzione" ed e' diventata attiva. I Rituali ne
hanno una in meno, la Magia ce l'ha come sua distintiva viva. Due sigilli con
due nomi per la stessa cosa sarebbero stati una promessa doppia fatta alla
stessa persona.

### La sottocategoria

Magia, quarta di Caligo, fra Rituali e Cabala:

- **Sigillo dell'Intenzione**, ATTIVO, con la sua rotta collegata
- Magia Rossa, Magia Bianca, Magia Verde, in arrivo
- **Opera al Nero**, in arrivo, MAI "Magia Nera"

Sul nome: nella lettura alchemica la nigredo e' la fase di dissoluzione che
precede la rinascita, non un maleficio, mentre Caligo nei briefing e' il custode
che la magia nera la conosce senza praticarla. Un test verifica che nessuna
voce della sezione contenga quella parola.

### La coerenza fra i quattro cataloghi

Fatto girare subito dopo l'aggiunta, come chiede l'ordine: verde. Il Sigillo
vive nel solo `art_catalog`, che e' dove vivono le arti dei domini, mentre
`function_shelf` e `stato_funzioni.json` governano lo scaffale del Santuario,
che e' un'altra cosa. Non c'era niente da aggiungere li', infatti il test di
coerenza non ha protestato.

## Le anteprime, guardate su due altezze

`sigillo-intenzione.png` e `sigillo-intenzione-2392.png`, piu' il confronto
affiancato con la bindrune.

**A che istante ho catturato.** A 3,2 secondi su un tracciamento da 2,4:
fine animazione, mai a meta'. Fotografare un sigillo a meta' vorrebbe dire
mostrare un cammino interrotto e chiamarlo glifo.

Nella cattura si legge: il cammino completo col cerchietto di partenza e la
barra di arrivo, il nome della via col suo dominio, l'intenzione fra
virgolette, la parola che ha deciso la via, le fonti.

## Stima contro consegnato

Avevo dichiarato **tutte e due in versione piena**, col rischio sui testi del
filtro invece che sul disegno. **Consegnate tutte e due in versione piena.**

La previsione sul rischio era giusta a meta': il vocabolario non ha dovuto
ridursi, ma il difetto vero e' saltato fuori proprio dai testi, cioe' dalla
spiegazione che ripeteva la parola filtrata. Il disegno non ha dato problemi.

## I numeri finali

- Suite: **952 test verdi**.
- `flutter analyze` su lib e test: pulito, zero avvisi nuovi.
- Test nuovi: **ventitre'**, in due file.
- Sottocategorie distintive di Caligo: da **due a tre**.
- Voci del catalogo aggiunte: **quattro**, piu' una spostata e accesa.

## Consegna

- Identificativo della release: **`5ltd9u5oelvmo`**
- Versione: 0.1.0, build **2107**
- Esito del caricamento: `RELEASE_CREATED`
- Integrita' dell'archivio: verificata prima di caricare
- Peso: **194,3 MB**, invariato rispetto alla consegna precedente
- Note, rilette dal server: "Il Sigillo dell Intenzione, terza arte di Caligo:
  scrivi una frase e nasce il tuo glifo. Piu la sottocategoria Magia nel suo
  dominio."
- Destinatario unico: `cloud@esotericircle.app`
- Pagina per i tester:
  `https://appdistribution.firebase.google.com/testerapps/1:425821975933:android:1b1ca4db8d4df69b940814/releases/5ltd9u5oelvmo`

Questa volta la suite era verde PRIMA di caricare, come la regola nata
nell'ordine precedente impone.
