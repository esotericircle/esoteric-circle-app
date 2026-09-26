# ESITO dell'ORDINE DELL'ONBOARDING VERO

## Dichiarazione, scritta prima di toccare il codice

Otto voci. Le ho guardate nel codice prima di stimare, ed ecco cosa mi
aspetto.

**Correzioni, dove il bersaglio esiste gia'** (cinque voci):

- **A1**, spostare due fasi nell'ordine giusto. E' una riscrittura
  dell'enumerazione delle tappe piu' i due passaggi: piccola, con un rischio
  solo, cioe' che la carta natale legga qualcosa che prima era gia' calcolato
  e adesso non lo e' ancora.
- **A3**, tre cose. Il nome minuscolo l'ho gia' trovato: la normalizzazione
  vive in `IdentityController.setName`, mentre la home legge
  `ProfileController.profile.displayName`, che passa da `setProfile` e non
  normalizza niente. Sono due strade e ne ho coperta una sola, che e'
  esattamente quello che l'ordine dice. La bolla e il genere vanno guardati
  prima di toccarli.
- **A6**, togliere la preselezione. Una riga di stato piu' i due selettori che
  devono dire cosa sono.
- **A7**, alzare la scena sopra il riquadro. Numeri gia' noti: gli slot dei
  corpi stanno a 0,46 0,38 e 0,56, mentre la scheda occupa il terzo basso.
- **A8**, l'Antartide. Un poligono su diciassette.

**Visivi nuovi, da disegnare** (tre voci), in ordine di rischio crescente:

- **A2**, la schermata dei tre Angeli. Quattro cose in una: i titoli giusti,
  le etichette che non si spezzano dentro una parola, l'ingrandimento al tocco
  e la condivisione di quell'ingrandimento con la carta natale. La materia
  buona c'e' gia': `AngelsScreen` mostra coro, arcangelo, arco di gradi, salmo
  e tradizione, quindi l'ingrandimento nasce estraendo da li' invece che
  scrivendo una seconda implementazione, che l'ordine vieta.
- **A5**, le onde della voce. Painter nuovo, piu' tre palette per genere. La
  frase declinata esiste gia': va capito perche' a schermo non si vede, e
  quello e' un pezzo di A3.
- **A4**, l'astrolabio che si costruisce. E' il piu' ricco: anelli che si
  tracciano, poi ruotano a velocita' diverse, la stella che pulsa, i punti di
  luce che percorrono gli anelli. Tutto procedurale.

**La stima: tutte e otto in versione piena.** Se una dovesse scendere alla
versione semplice sara' **A4**, l'ultima della lista: la sua versione
semplice sarebbe gli anelli che si tracciano e ruotano senza i punti di luce
che li percorrono.

**Il costo che questo ordine aggiunge, in numeri.** La regola nuova raddoppia
le verifiche: ogni anteprima toccata va catturata a 2532 e a 2392, quindi
dalle otto catture che prevedo se ne fanno sedici. E' il prezzo giusto: la
bolla di Medora era verde a 2532 e rotta a 2392, quindi una sola altezza non
era una verifica, era una fotografia fortunata.

## Stato voce per voce

Otto voci, otto esiti, tutte in versione piena.

### A1, il trionfo prima della carta: PIENA

Sequenza nuova: dati, cielo di nascita, trionfo dell'Animale, trionfo degli
Angeli, carta natale, Risonanza. Messi dopo la carta, i due trionfi rivelavano
una cosa gia' vista, perche' la carta contiene la tessera del lupo e quella
dei tre angeli. Un test percorre il Risveglio dall'inizio e verifica che dopo
il cielo ci sia l'Animale, non la carta. Prova del rosso superata: riportando
l'ordine di prima, il test cade.

### A2, la schermata dei tre Angeli: PIENA

**I titoli.** Erano Custode, Del cuore, Dell'intelletto: il primo
contraddiceva perfino il sottotitolo della schermata, che chiamava custodi
tutti e tre. Ora sono Fisico, Del cuore, Dell'intelletto, ciascuno con scritto
da quale dato della nascita viene, con un test che vieta che la parola "custode"
torni fra i tre.

**La spezzatura.** "Dell'intelletto" si rompeva a meta' parola su due righe.
Adesso ogni etichetta sta su una riga sola e si rimpicciolisce se non ci sta,
invece di spezzarsi.

**L'ingrandimento.** Al tocco su una carta si apre l'angelo in grande: arte
intera, nome, coro, arcangelo, arco di gradi col segno, salmo e chiave di
lettura, tutto dal corpus e tutto dentro la politica di pubblicazione. Il
sottotitolo adesso invita a toccare, cosi' il gesto si scopre.

**UN solo componente.** Lo stesso ingrandimento si apre dalla tessera della
carta natale. Il test della carta natale, che prima si aspettava la schermata
elenco, ora si aspetta l'ingrandimento del singolo angelo.

Una cosa imparata scrivendolo: un foglio modale nasce sotto il Navigator, non
sotto il MaestroScope della schermata che lo apre, quindi li' la palette non
arriva. Va letta prima e passata, quindi ora viaggia col widget.

### A3, tre cose dichiarate chiuse: PIENA

**Il nome, con la causa vera.** La normalizzazione stava in
`IdentityController.setName`, che sembrava il posto giusto perche' li' il nome
entra. Solo che il nome entra da DUE porte: l'altra e' `UserProfile` dentro
`ProfileController.setProfile`, che e' quella letta dalla home. Sette test verdi su
una porta sola.

Adesso la regola sta NEL DATO: `UserProfile` normalizza il nome nel proprio
costruttore, mentre `IdentityController` chiama la stessa funzione. Il prezzo
e' che `UserProfile` non e' piu' costante, perche' un valore costante non puo'
eseguire codice: otto file di test sono stati allineati.

Il test nuovo accende l'app vera col profilo scritto in minuscolo e guarda
OGNI stringa a schermo. Prova del rosso: togliendo la normalizzazione compare
"mauro, l'energia di chi nasce sotto Gemelli cerca quiete", che e' esattamente
la riga vista sul telefono.

**La bolla.** Misurata su CINQUE altezze, da 844 a 640: non morde mai il
Maestro. La misura runtime dell'altezza della zona d'ingresso, fatta
nell'ordine precedente, regge anche dove l'anteprima non arrivava.

**Il genere.** Guardato, non dedotto: la frase c'e' e si legge, su tutte e due
le altezze. Vedi A5.

### A4, l'astrolabio: PIENA

Tre anelli che si tracciano uno dopo l'altro, con le tacche che compaiono man
mano che il tratto passa, poi ruotano a tre velocita' diverse, una delle quali
al contrario. Un punto di luce percorre ciascun anello. La stella al centro
nasce per ultima e pulsa. Tutto procedurale, nessun asset. Con Riduci
Movimento c'e' gia', finito e fermo.

Il test ha trovato un difetto mio prima che lo vedesse qualcuno: col passo che
avevo scelto, il terzo anello restava aperto al 95 per cento, cioe' un
astrolabio che non finiva mai di costruirsi. Adesso il conto e' fatto perche'
l'ultimo chiuda esattamente a fine costruzione.

### A5, le onde della voce: PIENA

Anelli concentrici che si propagano dal centro. Il colore dice la scelta prima
delle parole: blu il maschile, rosa il femminile, arcobaleno il neutro. Un
test verifica che i tre insiemi siano diversi fra loro, che il blu abbia la
componente blu maggiore della rossa, il rosa il contrario, infine che
l'arcobaleno porti sia toni caldi sia freddi.

La frase declinata esisteva gia' e funziona: catturata a fine scrittura si
legge per intero sia a 2532 sia a 2392.

### A6, l'ora non parte da "Non la so": PIENA

Nessuna delle due strade e' preselezionata: lo stato e' nullo finche' la
persona non sceglie. Prima l'ora arrivava compilata, quindi si dava per
scontato che la sapesse; poi era preselezionato "Non la so", quindi si dava
per scontato il contrario, che e' lo stesso errore ribaltato. I due selettori
dicono "Ora" e "Minuti" invece di essere pillole mute col solo triangolino.

### A7, le costellazioni dietro la bolla: PIENA

Tutta la scena sale ancora: la Luna da 0,17 a 0,13, i tre corpi da 0,46 0,38 e
0,56 a 0,36 0,29 e 0,45. I nomi restano sopra il riquadro anche a 2392.

### A8, la striscia del planisfero: PIENA

Era l'Antartide, che nella proiezione equirettangolare si stira in una riga
dritta da bordo a bordo e a occhio non si legge come un continente. Ridotta a
una calotta coi bordi rientrati: meno fedele alla mappa, molto piu' fedele a
cio' che l'occhio riconosce. Un test verifica che nessun punto di terra sotto
i sessanta gradi sud tocchi i bordi.

## Le anteprime, guardate su due altezze

La regola nuova ha aggiunto due catture al corredo: la home a 2392 e la
schermata del genere a 2392. `mount` e `mountRisveglio` accettano adesso
l'altezza, quindi la cosa costa una riga per ogni cattura futura.

Guardate una per una: `risveglio-accoglienza` (l'astrolabio coi tre anelli, le
tacche, i tre punti di luce e la stella), `risveglio-genere` piu'
`risveglio-genere-2392` (onde blu e frase leggibile su tutte e due),
`risveglio-luogo` (l'Antartide non tocca piu' i bordi), `santuario-medora-2392`
(la bolla staccata dall'avatar).

**A che istante ho catturato.** L'astrolabio a 3,6 secondi su 2,6 di
costruzione. Il genere a 2,8 secondi su 1,4 di scrittura. Tutte a fine
animazione, mai a meta': fotografare a meta' e concludere che manca qualcosa
e' l'errore gia' commesso una volta con le linee d'aspetto.

## Stima contro consegnato

Avevo dichiarato tutte e otto in versione piena, con A4 come sola candidata a
scendere. **Consegnate tutte e otto in versione piena, A4 compresa.**

La previsione sui numeri ha retto: la regola delle due altezze ha aggiunto
esattamente il lavoro che avevo detto, mentre la causa del nome era dove
pensavo, cioe' nella seconda porta.

## Segnalazioni, viste e NON toccate

- **La striscia dei Doni sfora di 2 px** col testo di sistema al 120 per
  cento, di 4 px al 130. L'ho trovata mentre misuravo la bolla: il mio test
  cadeva per quell'eccezione invece che per il suo criterio, quindi ho tolto
  quel caso e l'ho scritto nel commento del test. Il punto e'
  `daily_strip.dart:671`.
- **I glifi dei pianeti** nella ruota natale restano quadratini nelle catture
  headless. Gia' segnalato: e' il font dei simboli che non si carica li',
  presumibilmente non un difetto sul telefono.
- **Due classi `BirthPlace` omonime**, in `core/astro` e in `core/identity`.
  Gia' segnalato, non toccato.
