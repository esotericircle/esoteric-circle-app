# Il corpus della Sinastria approfondita

Ordine FT voce FT.12, 14 ottobre 2026. Il fondatore, alla domanda "Chi scrive il corpus": "Code". Metodo dell'ordine FM: prima gli schedari (questo file), poi i testi, scritti da agenti in parallelo, uno per file, mandati a `tool/il_corpus_della_sinastria.py riempi`, che scrive nella fonte solo ciò che passa i controlli.

**Nessun testo è generato dal modello a runtime** (Master V13 sezione 72.5): l'app sceglie fra questi testi con un calcolo deterministico, e la variante ruota col giorno.

## I numeri, fissati dal disegno

| File | Celle | Testi |
|---|---|---|
| capitolo_attrazione, capitolo_emozioni, capitolo_mente, capitolo_durata, capitolo_destino | 16 ciascuno (4 legami × 4 toni) | 144 ciascuno: titolo, apertura e fare, tre varianti |
| contatti_cuore_e_mente | 45 (9 coppie di punti × 5 aspetti) | 135 |
| contatti_durata_e_destino | 30 (6 coppie × 5 aspetti) | 90 |
| composito | 30 (10 coppie di punti medi × 3 famiglie) | 120: titolo e testo, due varianti |
| keplero_oggi_momento | 9 consonanze, 36 di Oggi fra voi, 24 del Momento giusto | 162 |
| **Totale** | | **1.227** (l'ordine diceva circa 1.100 più 144: qui 1.083 per capitoli, contatti, Composito e Keplero, 144 per Oggi fra voi e il Momento giusto) |

## Come si compone un capitolo a video

Il formato di casa (Linee Guida V13 sezione 26): il **titolo** che è già la risposta, poi tre paragrafi col secondo nel riquadro, poi il "Da dove viene" breve in corsivo.

1. **titolo**: dal file del capitolo, cella `<legame> <tono>`.
2. **apertura** (primo paragrafo): dal file del capitolo, stessa cella. Dice che cosa succede fra voi in questo campo, per questo legame.
3. **il contatto** (secondo paragrafo, nel riquadro): dal file dei contatti, cella `<punto>-<punto> <aspetto>`. Dice che cosa fa quel contatto preciso. **Vale per tutti e quattro i legami**: si scrive come energia fra due persone, senza parlare di coppia d'amore, di lavoro o di famiglia.
4. **fare** (terzo paragrafo): dal file del capitolo, stessa cella. Dice che cosa fare, in concreto.
5. **Da dove viene**: lo compone il codice, col fatto vero (quale punto di chi, con quale aspetto) e la fonte.

Il **tono** viene dal contatto più stretto fra le coppie del capitolo: **fuso** se è una congiunzione, **armonico** se trigono o sestile, **teso** se quadratura od opposizione, **silenzio** se fra quelle coppie non c'è nessun aspetto.

## Le regole di ogni testo (le controlla lo strumento)

- **Italiano con gli accenti veri**: è, più, perché, già, così, può, ciò. Mai `e'`, `piu'`, `perche'`. Va bene `po'`.
- **Mai una virgola prima di "e" o di "ed".** Se serve una pausa, punto o due punti, oppure si toglie la virgola.
- **Mai il trattino lungo.**
- **Il tu a chi legge, il voi alla coppia.** L'altra persona si chiama `{nome}` (il codice ci mette il nome vero) oppure "l'altra persona". **Mai "lui", "lei"**, mai marito, moglie, fidanzato, ragazza, compagno, padre, madre, figlio, sorella: non sappiamo chi è l'altra persona, né il suo genere né il ruolo in famiglia.
- **Nessun genere**: né di chi legge ("sei pronto" no, "sei pronta" no), né della coppia ("siete pronti" no, "vi sentite vicini" no), né di `{nome}` ("{nome} è sicuro" no). Si riscrive senza l'aggettivo che concorda: "vi sentite vicini" diventa "sentite la vicinanza". Il genere di chi legge lo controlla lo stesso criterio della guardia di casa.
- **Nessuna certezza sul futuro**: mai "sicuramente", "per sempre", "succederà", "vi sposerete". Si parla di tendenze, di inclinazioni, di cosa conviene fare.
- **Niente vita privata**: mai salute, malattia, morte, denaro, gravidanza, eredità, tradimento.
- **Mai la parola "voce"** (nell'app vuol dire l'audio). Mai gioco, sfida, punteggio, scommessa, classifica: la sinastria è una lettura esoterica, non una gara.
- **Nessuna cifra**: i numeri li dice il codice.
- **Le varianti della stessa cella** dicono la stessa cosa con parole diverse: non cominciano con la stessa parola e non si somigliano troppo.
- **Lunghezze**: titolo da 15 a 70 caratteri; apertura e fare da 160 a 340; tutti gli altri testi da 110 a 320.
- **Dire che cosa fare** (fare, momento): un gesto concreto e piccolo, che due persone possono fare questa settimana.

## Lo schedario dei capitoli

Ogni capitolo ha la sua **gemella**, cioè il capitolo che gli somiglia di più, e il **confine**: un testo che si potrebbe spostare nella gemella senza perdere senso è caduto fuori dal suo capitolo. I lettori ciechi (agenti) leggeranno testi mescolati di un capitolo e della sua gemella, e dovranno riconoscerli otto volte su dieci.

- **attrazione**. Coppie: Venere-Marte, Sole-Venere, Marte-Marte. Chiede: il magnetismo, il desiderio di avvicinarsi, la spinta a fare insieme, il gusto dell'altra persona, il ritmo dell'iniziativa. Gemella: **emozioni**. Confine: l'attrazione è il richiamo, il movimento verso; le emozioni sono come ci si sente quando si è vicini. Nei legami che non sono amore l'attrazione è ciò che vi fa cercare (amicizia), stima e simpatia istintiva (famiglia), il desiderio di lavorare insieme e l'energia che si accende (lavoro).
- **emozioni**. Coppie: Luna-Luna, Sole-Luna, Luna-Venere. Chiede: sentirsi al sicuro, la cura reciproca, l'umore che si contagia, il bisogno di tenerezza, come si consola l'altra persona. Gemella: **attrazione** (e per la parola, **mente**). Confine: niente desiderio e niente idee; qui c'è il sentire e il nutrire.
- **mente**. Coppie: Mercurio-Mercurio, Sole-Mercurio, Mercurio-Luna. Chiede: come vi parlate, come discutete, se vi capite al volo o vi fraintendete, le idee che nascono insieme, il ritmo delle parole. Gemella: **emozioni**. Confine: qui si pensa e si dice; non si sente.
- **durata**. Coppie: Saturno-Sole, Saturno-Luna, Saturno-Venere. Chiede: la tenuta nel tempo, l'impegno, le responsabilità, la pazienza, ciò che il legame regge nei giorni pesanti, i limiti e le regole che vi date. Gemella: **destino**. Confine: la durata è ciò che si costruisce con fatica e costanza, giorno per giorno; il destino è il senso, la direzione, la sensazione di un incontro che porta da qualche parte.
- **destino**. Coppie: Nodo Nord-Sole, Nodo Nord-Luna, Nodo Nord-Venere. Chiede: la direzione in cui il legame vi spinge, che cosa imparate l'uno dall'altra persona, la sensazione di riconoscersi, ciò che vi fa crescere. Gemella: **durata**. Confine: il destino non è la costanza; ed è una **direzione**, mai una sentenza: "il legame vi spinge verso", mai "è scritto", mai "dovete".

## Lo schedario dei toni

- **fuso** (congiunzione): due energie che si sommano e diventano una sola. Intensità, identificazione, riconoscersi; il rischio del troppo, del perdersi l'uno nell'altra persona. Fare: tenere uno spazio proprio.
- **armonico** (trigono, sestile): scorre senza sforzo. Facilità, naturalezza, aiuto reciproco; il rischio di darlo per scontato. Fare: coltivare, nutrire, scegliere attivamente ciò che viene facile.
- **teso** (quadratura, opposizione): un attrito. Differenze che si urtano, che chiedono di essere nominate e negoziate; l'attrito insegna e tiene sveglio il legame. Mai catastrofe, mai condanna. Fare: dare un nome alla differenza, accordarsi su una regola piccola.
- **silenzio** (nessun contatto fra le coppie del capitolo): questo campo non è dove il vostro legame si accende da solo. Né buono né cattivo: ciò che qui non viene da sé si costruisce per scelta. Fare: un gesto consapevole in quel campo.

## Lo schedario dei legami

- **amore**: coppia innamorata o che si sta scegliendo. Si apre solo dai sedici anni in su (FT.04): nessun testo d'amore parla a un bambino. Niente sesso esplicito; il desiderio si dice con eleganza.
- **amicizia**: amici e amiche, di qualunque età (anche ragazzi di scuola: sezione 57.2 del Briefing di Progetto). Niente toni romantici.
- **famiglia**: due persone della stessa famiglia, di qualunque ruolo. Non nominare mai il ruolo (genitore, figlio, fratello): non lo sappiamo. Niente toni romantici.
- **lavoro**: colleghi, soci, chi collabora a un progetto. Niente toni romantici.

## Lo schedario dei contatti

Un testo per ogni coppia di punti e ogni aspetto. Parla dell'**energia** fra i due punti, non del legame: deve andare bene per amore, amicizia, famiglia e lavoro. Il significato dei punti (tradizione):

- **Sole**: chi si è, la volontà, ciò che fa brillare. **Luna**: il sentire, il bisogno di sicurezza, le abitudini. **Mercurio**: il pensiero, le parole, lo scambio. **Venere**: il gusto, il piacere, ciò che si apprezza e come si dà affetto. **Marte**: l'iniziativa, il desiderio, la grinta, il modo di arrabbiarsi. **Saturno**: il tempo, la responsabilità, i limiti, la serietà. **Nodo Nord** (scritto `nodo` nelle celle): la direzione di crescita, ciò verso cui si va.
- **Gli aspetti**: congiunzione (si fondono), sestile (collaborano se qualcuno comincia), quadratura (attrito che spinge a fare), trigono (scorre senza sforzo), opposizione (stanno uno di fronte all'altro: specchio e complemento).
- Lo stesso punto nelle due persone (Luna-Luna, Marte-Marte, Mercurio-Mercurio): due modi della stessa cosa che si guardano.

## Il Composito (Robert Hand, *Planets in Composite*, 1975)

Il punto medio di ogni pianeta fra le due nascite fa un terzo cielo, quello della relazione stessa. Le celle sono gli aspetti fra due punti medi (Sole, Luna, Mercurio, Venere, Marte) per famiglia: fuso, armonico, teso. Il **titolo** è già la risposta su che cosa fa la relazione come cosa sua ("La vostra relazione ha un cuore caldo e una testa sveglia"); il **testo** dice come si comporta la relazione e cosa le fa bene. Si parla della relazione come di una terza presenza, "il vostro legame", "la relazione".

## Keplero (*Harmonices Mundi*, 1619, libro IV)

Keplero lega gli aspetti alle consonanze musicali: i due punti dividono il cerchio in due archi, e il rapporto dell'arco maggiore col cerchio intero è il rapporto di una corda. Le celle sono le consonanze: **unisono** (stesso grado), **ottava** (opposizione, uno a due), **quinta** (trigono, due a tre), **quarta** (quadratura, tre a quattro), **terza_minore** (sestile, cinque a sei), **terza_maggiore** (quintile, settantadue gradi, quattro a cinque), **sesta_maggiore** (biquintile, centoquarantaquattro gradi, tre a cinque), **sesta_minore** (sesquiquadrato, centotrentacinque gradi, cinque a otto), **nessuna**. Il testo dice come suona quella consonanza fra due persone, **senza affermare nulla oltre ciò che Keplero scrive** (la consonanza è un accordo; la nessuna consonanza non è una stonatura, è un intervallo che Keplero non conta fra le consonanze). Niente numeri nel testo: il rapporto lo scrive il codice.

## Oggi fra voi e Il momento giusto

- **oggi `<transito>` `<capitolo>`**: oggi il pianeta in transito passa sui gradi dove i vostri cieli si toccano, in quel capitolo. Dice che cosa si accende oggi fra voi e un gesto per oggi. Tempo presente, mai promesse. **oggi nessuno**: oggi nessun pianeta tocca i vostri punti di contatto: un giorno quieto, cosa farne.
- **momento `<transito>` `<legame>`**: perché quel giorno è favorevole per quel legame, detto dal pianeta che lo rende tale (Sole: chiarezza e presenza; Luna: intimità e ascolto; Mercurio: parlare e chiarire; Venere: piacere e riconciliazione; Giove: fiducia e progetti). Consapevolezza, mai fatalismo: nessun giorno è sbagliato o pericoloso. Dice cosa fare in quel giorno. **momento nessuno `<legame>`**: nelle settimane guardate nessun giorno spicca: ogni giorno è buono quanto un altro, e cosa fare allora.
