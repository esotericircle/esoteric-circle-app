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

## Le ancore dei dodici segni

### Ariete, fuoco cardinale, Marte
- Generale, "Il fuoco che apre": Sei l'inizio fatto persona, la scintilla che accende e oggi il coraggio di muovere il primo passo conta più del piano perfetto.
- Amore, "Cuore in avanti": In amore vai diretto, come è nella tua natura di fuoco, la tua sincerità disarma e chi ti ama apprezza lo slancio più della prudenza.
- Carriera, "Slancio da guidare": Sul lavoro apri varchi dove altri vedono muri, la tua spinta è un dono, basta darle una direzione oltre alla velocità.
- Fortuna, "L'audacia premiata": La sorte, con te, ama chi osa, un rischio calcolato oggi vale più di mille attese prudenti.

### Toro, terra fisso, Venere
- Generale, "La forza della calma": La tua natura di terra cerca stabilità e bellezza concreta, oggi costruisci con calma, un passo solido vale più di dieci affrettati.
- Amore, "Tenerezza che dura": Ami coi sensi e con la fedeltà, attraverso i gesti più che le parole, la tua dolcezza paziente è ciò che fa sentire l'altro a casa.
- Carriera, "Il valore che resta": Sul lavoro ottieni per costanza ciò che altri inseguono per foga, la tua tenacia è la tua firma, non avere fretta di raccoglierne i frutti.
- Fortuna, "L'abbondanza concreta": La tua fortuna ha radici, non ali, premia ciò che curi con pazienza e oggi qualcosa di seminato inizia a fruttare.

### Gemelli, aria mobile, Mercurio
- Generale, "La mente che collega": Vivi di scambi, parole e idee che rimbalzano, oggi la tua curiosità è la bussola, segui il filo che ti accende senza disperderti.
- Amore, "Il gioco della parola": Ti innamori delle menti vivaci e delle conversazioni che non finiscono, oggi una parola leggera può accendere più di un gesto solenne.
- Carriera, "Idee in movimento": Sul lavoro brilli collegando ciò che gli altri tengono separato, la tua versatilità è forza, scegli una pista e portala fino in fondo.
- Fortuna, "Il caso curioso": La tua fortuna passa dagli incontri e dall'informazione giusta al momento giusto, oggi tieni occhi e orecchie ben aperti.

### Cancro, acqua cardinale, Luna
- Generale, "Il cuore che protegge": Senti tutto e ricordi tutto, la tua forza è la cura, oggi concediti dolcezza, un gesto gentile verso te o chi ami cambia il tono del giorno.
- Amore, "Il nido degli affetti": Ami con tenerezza e dedizione e hai bisogno di sentirti al sicuro per aprirti, oggi un piccolo rifugio condiviso vale più di ogni promessa.
- Carriera, "La cura che costruisce": Sul lavoro proteggi e nutri ciò che ti sta a cuore, la tua sensibilità legge le persone, usala come vantaggio e non come peso.
- Fortuna, "La marea gentile": La tua fortuna segue le maree dell'intuito, oggi fidati di ciò che senti sotto la superficie, ti sta indicando la direzione.

### Leone, fuoco fisso, Sole
- Generale, "La gioia di brillare": Sei calore, creatività e generosità che scalda, oggi esprimi ciò che sei senza chiedere permesso, la tua luce fa spazio anche agli altri.
- Amore, "Il cuore generoso": Ami con slancio e teatro, doni tanto e chiedi di essere visto, oggi la tua lealtà calorosa è irresistibile, mostrala senza timore.
- Carriera, "Il palco è tuo": Sul lavoro convinci con la passione più che con la logica fredda, oggi metti la tua idea al centro, il tuo entusiasmo è contagioso.
- Fortuna, "Il favore del Sole": La tua fortuna risponde al tuo calore, più doni e crei più ricevi e oggi la vita sembra rispondere al tuo sorriso.

### Vergine, terra mobile, Mercurio
- Generale, "La cura del dettaglio": Osservi, distingui e migliori, trovi il sacro nelle piccole cose fatte bene, oggi un gesto ordinato rimette in pace anche la mente.
- Amore, "L'amore nei piccoli gesti": Ami rendendoti utile, con attenzione e discrezione, oggi lascia che qualcuno si prenda cura di te, non solo il contrario.
- Carriera, "La maestria del metodo": Sul lavoro cogli il dettaglio che sfugge a tutti, oggi la tua precisione fa la differenza, senza scambiare un difetto per il tutto.
- Fortuna, "Il frutto del lavoro": La tua fortuna nasce dal fare bene ciò che tocchi, oggi un piccolo miglioramento apre una porta più grande.

### Bilancia, aria cardinale, Venere
- Generale, "L'arte dell'equilibrio": Cerchi armonia, bellezza e giustizia, fiorisci nell'incontro, oggi rimetti al centro ciò che ti dà pace, senza temere di scegliere.
- Amore, "Il piacere di stare in due": Qui l'amore è la tua arte, cerchi eleganza e sintonia, oggi un piccolo gesto di grazia riporta dolcezza in un legame.
- Carriera, "La forza della misura": Sul lavoro la tua diplomazia è un talento raro, oggi medi dove altri litigano e questo ti fa avanzare senza rumore.
- Fortuna, "L'incontro giusto": La tua fortuna arriva dalle persone giuste e dalla bellezza condivisa, oggi un incontro può valere più di mille sforzi solitari.

### Scorpione, acqua fisso, Marte e Plutone
- Generale, "La forza di rinascere": Vivi tutto in profondità, senza mezze misure, oggi lascia andare ciò che pesa, la tua forza cresce attraversando e non evitando.
- Amore, "L'intensità vera": Ami senza vie di mezzo, vuoi verità e profondità, oggi la tua sfida è fidarti e proprio lì si nasconde la tenerezza più grande.
- Carriera, "La strategia paziente": Sul lavoro agisci sotto controllo fino al momento giusto, oggi la tua determinazione silenziosa vale più di ogni proclama.
- Fortuna, "Il tesoro nascosto": La tua fortuna sta dove altri non osano guardare, oggi un dettaglio sottovalutato può rivelarsi il tuo vantaggio.

### Sagittario, fuoco mobile, Giove
- Generale, "La fame di orizzonte": Cerchi senso, libertà e avventura, la mente e i piedi vogliono lontano, oggi allarga lo sguardo, una prospettiva nuova scioglie un nodo vecchio.
- Amore, "Il volo condiviso": Ti innamori dell'avventura e della crescita a due, oggi cerca leggerezza e complicità, l'amore che ti somiglia non è mai una gabbia.
- Carriera, "La spinta verso l'alto": Sul lavoro il tuo entusiasmo è contagioso e apre porte, oggi punta in grande, curando anche il passo dopo il passo.
- Fortuna, "Il favore di Giove": La tua fortuna ama l'ottimismo e il movimento, oggi un sì detto con fiducia può portarti più lontano del previsto.

### Capricorno, terra cardinale, Saturno
- Generale, "La pazienza che scala": Costruisci nel tempo, con disciplina e responsabilità, le vette non ti spaventano, oggi un passo concreto ti avvicina a ciò che conta.
- Amore, "La fedeltà che dura": Sotto il riserbo custodisci una fedeltà profonda, oggi concediti tenerezza, mostrare un lato morbido non toglie nulla alla tua forza.
- Carriera, "La vetta un passo alla volta": Sul lavoro nessuno costruisce per i propri obiettivi come te, oggi la tua serietà viene notata, i risultati parlano al posto tuo.
- Fortuna, "Il merito premiato": La tua fortuna si costruisce mattone su mattone, oggi qualcosa di guadagnato con fatica inizia a darti ragione.

### Acquario, aria fisso, Saturno e Urano
- Generale, "La visione del futuro": Pensi diverso e guardi avanti, ami la libertà e le persone, oggi un'idea fuori dagli schemi merita spazio, non la trattenere.
- Amore, "Il legame che libera": Ami in modo originale e paritario, l'amante è anche un complice, oggi la tua autenticità attira più di ogni convenzione.
- Carriera, "L'idea che apre strade": Sul lavoro vedi ciò che gli altri non osano immaginare, oggi la tua originalità è una risorsa, condividila senza timore del giudizio.
- Fortuna, "La sorpresa geniale": La tua fortuna arriva quando pensi in grande e per tutti, oggi una via inattesa può rivelarsi la più giusta.

### Pesci, acqua mobile, Giove e Nettuno
- Generale, "L'anima senza confini": Senti l'invisibile, sogni e ti fondi col tutto, empatia e immaginazione sono il tuo dono, oggi ascolta l'intuito e poi dagli dei confini.
- Amore, "La dolcezza che avvolge": Ami in modo tenero e avvolgente, quasi senza riserve, oggi ricordati di chiedere e non solo di dare, la tua dolcezza merita di essere ricambiata.
- Carriera, "L'ispirazione che guida": Sul lavoro la tua sensibilità coglie ciò che sfugge ai numeri, oggi un'intuizione vale un piano, mettila a terra con un piccolo gesto pratico.
- Fortuna, "Il dono dell'intuito": La tua fortuna passa dai segni sottili e dalle coincidenze, oggi fidati della prima sensazione, ti sta guidando bene.

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
