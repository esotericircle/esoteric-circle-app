# Corpus dell'Oroscopo a quattro schede, Medora, Esoteric Circle

La headline di Medora nella Demo. Quattro schede per segno, Generale, Amore, Carriera, Fortuna, ognuna col suo indicatore visivo. Contenuto curato, deterministico, su dispositivo: si accende senza backend e senza Gemini. A runtime, quando Vertex e Gemini sono accesi, questo stesso impianto diventa il fallback e Gemini ci ricama la personalizzazione sul cielo reale del giorno. Voce di Medora, elegante e calda, seconda persona, registro conciso. Astrologia tropicale reale nella cornice di consapevolezza, mai fatalismo, mai giudizio su chi legge. Livello visivo prima del testo. Disclaimer una sola volta.

## Come si compone una scheda

Ogni scheda si monta da tre strati, concatenati in questo ordine:

1. Ancora del segno. Una frase stabile che dice la natura vera del segno in quel dominio, elemento e pianeta e tema. Non cambia mai. È lo strato identitario.
2. Corrente del giorno. Una frase pescata dal pool del dominio, scelta con un seme deterministico da segno e giorno. Cambia ogni giorno ed è diversa da segno a segno, ma è riproducibile: stesso segno stesso giorno, stesso testo.
3. Indicatore visivo. Un valore da due a cinque, calcolato in modo deterministico da segno e giorno e dominio. Il pavimento è due, così nessuna scheda appare mai desolante.

Testo finale di una scheda uguale a: ancora del segno, spazio, corrente del giorno. Le due frasi sono entrambe autonome e concatenabili con qualunque segno, così la composizione non sbaglia mai la grammatica.

## Regole deterministiche, per Code

- Indice del segno, da 0 Ariete a 11 Pesci. Giorno, l'ordinale del giorno nell'anno. Dominio, un intero fisso da 0 a 3, Generale 0, Amore 1, Carriera 2, Fortuna 3.
- Seme di base: una funzione hash stabile e riproducibile su (indiceSegno, giorno, anno, dominio). Niente Random di sistema, niente ora, niente fuso. Stesso ingresso, stessa uscita, sempre.
- Indice della corrente del giorno: seme modulo lunghezza del pool del dominio.
- Valore dell'indicatore: due piu' (secondo seme modulo quattro), quindi sempre nell'intervallo da due a cinque unita' piene su cinque.
- Numero fortunato della scheda Fortuna: uno piu' (terzo seme modulo novanta), quindi da uno a novanta.
- Colore del giorno della scheda Fortuna: quarto seme modulo lunghezza della palette del segno, che pesca uno dei colori elencati sotto per quel segno.

Gli indicatori sono quattro icone diverse per dominio, riempite da due a cinque: Generale l'energia, Amore i cuori, Carriera la spinta che sale, Fortuna il quadrifoglio. Sotto le icone, la scheda Fortuna mostra anche numero fortunato e colore del giorno.

## Disclaimer, una sola volta nella schermata

Il cielo inclina, non obbliga: nessun destino è scritto, la scelta resta tua.

## Aperture personalizzate

L'oroscopo e' personalizzato: il primo testo apre col nome della persona e sta prima del testo della Generale. Il vocativo lo decide la forma di cortesia scelta all'onboarding: Caro o Cara piu' il nome quando il genere e' noto, altrimenti Ciao piu' il nome. Il segnaposto [Nome] si sostituisce con quel vocativo completo.

Il seme e' lo stesso del giorno, quindi l'apertura e' deterministica e riproducibile. A runtime, quando Gemini e' acceso, l'apertura la personalizza lui sul cielo reale e sulla memoria della persona: questo resta il fallback su dispositivo.

1. [Nome], oggi il cielo ha qualcosa da dirti.
2. [Nome], le stelle di oggi ti guardano con favore.
3. [Nome], oggi Medora ti accompagna passo dopo passo.
4. [Nome], c'è un buon vento nelle stelle di oggi.
5. [Nome], oggi il tuo cielo si accende.
6. [Nome], lascia che il cielo di oggi ti sorprenda.

## Le ancore dei dodici segni

### Ariete, fuoco cardinale, Marte
- Generale, "Il fuoco che apre": Sei l'inizio fatto persona, la scintilla che accende prima che gli altri abbiano finito di decidere. Il coraggio del primo passo è la tua misura e ogni giorno gli sceglie una direzione diversa.
- Amore, "Cuore in avanti": In amore vai diretto, come vuole la tua natura di fuoco e la tua sincerità disarma perché chi ti ama sceglie proprio il tuo slancio. Dove quello slancio serva davvero, cambia col cielo.
- Carriera, "Slancio da guidare": Sul lavoro apri varchi dove altri vedono muri e la tua spinta è un dono che chiede una direzione più che un freno. La direzione la porta il giorno.
- Fortuna, "L'audacia premiata": La sorte, con te, ama chi osa e un rischio calcolato ti rende più di mille attese prudenti. Quale rischio valga la pena, lo mostra il giorno.

### Toro, terra fisso, Venere
- Generale, "La forza della calma": La tua natura di terra cerca stabilità e bellezza concreta e costruisci meglio di chiunque quando nessuno ti mette fretta. Dove posare il prossimo mattone, lo indica il giorno.
- Amore, "Tenerezza che dura": Ami coi sensi e con la fedeltà, attraverso i gesti più che le parole e la tua dolcezza paziente è ciò che fa sentire l'altro a casa. Quale gesto conti adesso, cambia col cielo.
- Carriera, "Il valore che resta": Sul lavoro ottieni per costanza ciò che altri inseguono per foga e la tua tenacia è la tua firma. Quanto sia vicino il raccolto, lo dice il giorno.
- Fortuna, "L'abbondanza concreta": La tua fortuna ha radici e non ali e premia ciò che curi con pazienza. Quale seme sia pronto a fruttare lo scrive il giorno.

### Gemelli, aria mobile, Mercurio
- Generale, "La mente che collega": Vivi di scambi, di parole e di idee che rimbalzano e la curiosità ti fa da bussola meglio di qualunque piano. Quale filo seguire, te lo indica il giorno.
- Amore, "Il gioco della parola": Ti innamori delle menti vivaci e delle conversazioni che non finiscono e una frase leggera può accendere più di un gesto solenne. Con chi vada spesa, cambia col cielo.
- Carriera, "Idee in movimento": Sul lavoro brilli collegando ciò che gli altri tengono separato e la versatilità è forza finché una pista la porti fino in fondo. Quale sia la tua pista, lo indica il cielo.
- Fortuna, "Il caso curioso": La tua fortuna passa dagli incontri e dall'informazione giusta al momento giusto ed è un dono che si presenta senza bussare. Da che parte stia arrivando lo racconta il giorno.

### Cancro, acqua cardinale, Luna
- Generale, "Il cuore che protegge": Senti tutto e ricordi tutto e la tua forza si chiama cura, non durezza. Verso chi rivolgerla lo suggerisce il giorno.
- Amore, "Il nido degli affetti": Ami con tenerezza e dedizione e hai bisogno di sentirti al sicuro prima di aprirti del tutto. Quanto sicuro sia il terreno, cambia col cielo.
- Carriera, "La cura che costruisce": Sul lavoro proteggi e nutri ciò che ti sta a cuore e la tua sensibilità legge le persone prima che parlino. Cosa stia chiedendo di essere letto, lo scrive il giorno.
- Fortuna, "La marea gentile": La tua fortuna segue le maree dell'intuito e sotto la superficie sai già dove guardare. Quale marea stia salendo, lo segna il cielo.

### Leone, fuoco fisso, Sole
- Generale, "La gioia di brillare": Sei calore, creatività e generosità che scalda e la tua luce fa spazio agli altri invece di toglierlo. Dove accenderla, lo indica il giorno.
- Amore, "Il cuore generoso": Ami con slancio e con teatro, doni molto e chiedi di essere visto e la tua lealtà calorosa è irresistibile quando non la trattieni. A chi stia arrivando, cambia col cielo.
- Carriera, "Il palco è tuo": Sul lavoro convinci con la passione più che con la logica fredda e il tuo entusiasmo diventa contagioso quando ha un'idea al centro. Quale idea mettere al centro, te lo suggerisce il cielo.
- Fortuna, "Il favore del Sole": La tua fortuna risponde al tuo calore e più doni e più crei, più la vita ti risponde. Da dove ti risponda lo racconta il giorno.

### Vergine, terra mobile, Mercurio
- Generale, "La cura del dettaglio": Osservi, distingui e migliori e trovi il sacro nelle piccole cose fatte bene. Quale piccola cosa rimetta in pace anche la mente, lo indica il giorno.
- Amore, "L'amore nei piccoli gesti": Ami rendendoti utile, con attenzione e discrezione e ti riesce più facile dare che ricevere. Da dove possa arrivare la cura per te, cambia col cielo.
- Carriera, "La maestria del metodo": Sul lavoro cogli il dettaglio che sfugge a tutti e la precisione è il tuo vantaggio finché non scambi un difetto per il tutto. Dove metterla, lo segna il giorno.
- Fortuna, "Il frutto del lavoro": La tua fortuna nasce dal fare bene ciò che tocchi e un miglioramento minimo ti apre porte grandi. Quale porta sia socchiusa lo scrive il giorno.

### Bilancia, aria cardinale, Venere
- Generale, "L'arte dell'equilibrio": Cerchi armonia, bellezza e giustizia e fiorisci nell'incontro più che nella solitudine. Cosa rimettere al centro per ritrovare la pace, lo suggerisce il giorno.
- Amore, "Il piacere di stare in due": Qui l'amore è la tua arte, cerchi eleganza e sintonia e un gesto di grazia ti vale più di una discussione vinta. Dove quel gesto serva, cambia col cielo.
- Carriera, "La forza della misura": Sul lavoro la tua diplomazia è un talento raro e medi dove gli altri litigano avanzando senza rumore. Quale tavolo ci sia da ricomporre, lo mostra il cielo.
- Fortuna, "L'incontro giusto": La tua fortuna arriva dalle persone giuste e dalla bellezza condivisa e un incontro ti vale più di mille sforzi solitari. Da che parte arrivi lo racconta il giorno.

### Scorpione, acqua fisso, Marte e Plutone
- Generale, "La forza di rinascere": Vivi tutto in profondità, senza mezze misure e la tua forza cresce attraversando invece di evitare. Cosa ci sia da attraversare lo indica il giorno.
- Amore, "L'intensità vera": Ami senza vie di mezzo e vuoi verità e la tua sfida non è sentire ma fidarti. Dove il terreno regga la fiducia, cambia col cielo.
- Carriera, "La strategia paziente": Sul lavoro ti muovi sotto controllo fino al momento giusto e la determinazione silenziosa ti vale più di ogni proclama. Se il momento sia arrivato, lo dice il cielo.
- Fortuna, "Il tesoro nascosto": La tua fortuna sta dove gli altri non osano guardare e un dettaglio sottovalutato diventa il tuo vantaggio. Quale dettaglio sia, lo scrive il giorno.

### Sagittario, fuoco mobile, Giove
- Generale, "La fame di orizzonte": Cerchi senso, libertà e avventura e la mente ti porta lontano prima dei piedi. Verso quale orizzonte guardare, lo indica il giorno.
- Amore, "Il volo condiviso": Ti innamori dell'avventura e della crescita a due e l'amore che ti somiglia non è mai una gabbia. Dove trovare quella leggerezza, cambia col cielo.
- Carriera, "La spinta verso l'alto": Sul lavoro il tuo entusiasmo apre porte e puntare in grande ti riesce naturale quando curi anche il passo dopo il passo. Quale passo venga per primo, lo decide il giorno.
- Fortuna, "Il favore di Giove": La tua fortuna ama l'ottimismo e il movimento e un sì detto con fiducia ti porta più lontano del previsto. A cosa dirlo lo racconta il giorno.

### Capricorno, terra cardinale, Saturno
- Generale, "La pazienza che scala": Costruisci nel tempo, con disciplina e responsabilità e le vette non ti hanno mai spaventato. Quale passo concreto ti avvicini davvero, lo indica il giorno.
- Amore, "La fedeltà che dura": Sotto il riserbo custodisci una fedeltà profonda e mostrare un lato morbido non toglie niente alla tua forza. Quando valga la pena mostrarlo, cambia col cielo.
- Carriera, "La vetta un passo alla volta": Sul lavoro nessuno costruisce per i propri obiettivi come te e i tuoi risultati parlano al posto tuo prima che tu apra bocca. Quanto siano stati notati, te lo racconta il cielo.
- Fortuna, "Il merito premiato": La tua fortuna si costruisce mattone su mattone e ciò che hai guadagnato con fatica prima o poi ti dà ragione. Quando cominci a vederlo lo scrive il giorno.

### Acquario, aria fisso, Saturno e Urano
- Generale, "La visione del futuro": Pensi diverso e guardi avanti e ami la libertà quanto le persone. Quale idea fuori dagli schemi meriti spazio, lo indica il giorno.
- Amore, "Il legame che libera": Ami in modo originale e paritario e per te l'amante è anche un complice. Dove la tua autenticità venga accolta, cambia col cielo.
- Carriera, "L'idea che apre strade": Sul lavoro vedi ciò che gli altri non osano immaginare e la tua originalità è una risorsa quando smette di temere il giudizio. Con chi condividerla, lo apre il giorno.
- Fortuna, "La sorpresa geniale": La tua fortuna arriva quando pensi in grande e per tutti e la via inattesa è quasi sempre la tua. Quale via si stia aprendo lo racconta il giorno.

### Pesci, acqua mobile, Giove e Nettuno
- Generale, "L'anima senza confini": Senti l'invisibile, sogni e ti fondi col tutto e l'intuito ti serve meglio quando gli dai dei confini. Dove tracciarli, lo indica il giorno.
- Amore, "La dolcezza che avvolge": Ami in modo tenero e avvolgente, quasi senza riserve e la tua dolcezza merita di essere ricambiata quanto è donata. Da chi possa tornarti, cambia col cielo.
- Carriera, "L'ispirazione che guida": Sul lavoro la tua sensibilità coglie ciò che sfugge ai numeri e un'intuizione ti vale un piano quando la metti a terra. Su cosa metterla, te lo indica il cielo.
- Fortuna, "Il dono dell'intuito": La tua fortuna passa dai segni sottili e dalle coincidenze e la prima sensazione ti guida bene più spesso di quanto ammetti. Verso dove ti stia guidando lo scrive il giorno.

## I pool della corrente del giorno, per dominio

Validi per tutti i segni. Il seme del giorno ne pesca una. Ogni frase è autonoma e si concatena dopo l'ancora di qualunque segno.

### Generale, dieci correnti
1. Oggi parti dal primo passo, il resto si chiarisce strada facendo.
2. Una piccola scelta di oggi vale più di un grande piano rimandato.
3. Il ritmo giusto lo detti tu, non chi ti corre intorno.
4. Ascolta cosa ti chiede il corpo prima di riempire l'agenda.
5. Un imprevisto può rivelarsi la parte migliore della giornata.
6. Concediti una pausa vera, la lucidità torna nel silenzio.
7. Di' un sì convinto o un no chiaro, i forse oggi ti pesano.
8. La giornata premia chi resta presente, non chi anticipa tutto.
9. Rimetti al centro una cosa che conta, lascia cadere il rumore.
10. Fidati di ciò che senti, oggi la tua intuizione ci vede lungo.

### Amore, dieci correnti
1. Oggi la sincerità apre più porte di qualsiasi strategia.
2. Un gesto piccolo dice più di mille parole rimandate.
3. Chi ti sta vicino aspetta un tuo passo, fallo senza timore.
4. Lascia respirare l'altro, la giusta distanza avvicina.
5. Una conversazione sospesa oggi può ritrovare il suo filo.
6. Mostra il lato che di solito proteggi, verrà accolto.
7. Se sei in coppia, la tenerezza conta più della ragione.
8. Se sei da solo, un incontro leggero merita attenzione.
9. Perdona una piccola ruvidezza, non tutto va discusso.
10. Ascolta davvero, prima di rispondere fai un respiro.

### Carriera, dieci correnti
1. Un'idea proposta al momento giusto oggi trova ascolto.
2. Concentra le forze su una cosa sola e portala a termine.
3. Chiedi ciò che ti spetta con calma, la fermezza paga.
4. Un collega può diventare un alleato, apri uno spiraglio.
5. Rimanda la mossa rischiosa, oggi la pazienza rende di più.
6. Il dettaglio che curi adesso ti evita un problema domani.
7. Fatti notare per come risolvi, non per quanto corri.
8. Una porta che sembrava chiusa merita un secondo bussare.
9. Metti ordine prima di aggiungere, la chiarezza sblocca.
10. Il tuo valore si vede nei fatti, lascia che parlino.

### Fortuna, dieci correnti
1. La sorte oggi premia chi osa un piccolo passo in più.
2. Tieni gli occhi aperti, un'occasione arriva travestita da caso.
3. Un incontro inatteso porta con sé una buona notizia.
4. Segui la coincidenza, oggi non è affatto casuale.
5. La fortuna gira dalla tua parte nel pomeriggio, fatti trovare pronto.
6. Un no di ieri libera lo spazio per un sì migliore.
7. Rischia con misura, il cielo accompagna chi si fida.
8. Una parola detta al momento giusto ti apre una via.
9. Cerca il bello nelle piccole cose, oggi si moltiplica.
10. Un vecchio contatto può tornare utile, non stupirti.

## Le palette del colore del giorno, per segno

Il seme pesca uno di questi per la scheda Fortuna.

- Ariete: rosso, oro, corallo, cremisi
- Toro: verde salvia, terracotta, ottone, rosa antico
- Gemelli: giallo, azzurro, argento, lilla
- Cancro: argento, bianco perla, blu notte, glicine
- Leone: oro, ambra, arancio, porpora
- Vergine: verde bosco, beige, blu polvere, bronzo
- Bilancia: rosa cipria, verde acqua, oro rosa, celeste
- Scorpione: rosso scuro, nero, bordeaux, verde smeraldo
- Sagittario: viola, indaco, oro, turchese
- Capricorno: grigio pietra, marrone, verde scuro, antracite
- Acquario: turchese, blu elettrico, argento, blu ghiaccio
- Pesci: verde mare, lavanda, argento, blu oltremare

## Nota per il runtime

A C3, con Vertex e Gemini accesi, l'ancora resta il seme del significato e la corrente del giorno diventa il fallback. Gemini riceve segno, dominio, cielo reale del giorno e memoria della persona e restituisce una versione personalizzata nella voce di Medora, senza contraddire l'ancora del segno. Gli indicatori e il numero e il colore restano deterministici, così restano coerenti tra un'apertura e l'altra nello stesso giorno.
