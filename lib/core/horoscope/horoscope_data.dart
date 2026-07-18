// GENERATO da tool/_gen_oroscopo.py a partire da docs/corpus/oroscopo.md.
// Fonte di verita': il corpus. Non modificare a mano: rigenerare dal corpus.
//
// I dati su dispositivo dell'Oroscopo a quattro schede di Medora: le ancore dei
// dodici segni per i quattro domini, i pool della corrente del giorno, le
// palette del colore del giorno e la riga di disclaimer.

/// Dati dell'Oroscopo, trascritti dal corpus. Chiavi per id del segno
/// (`Zodiac.id`) e per indice del dominio (Generale 0, Amore 1, Carriera 2,
/// Fortuna 3).
class HoroscopeData {
  const HoroscopeData._();

  /// Per ogni segno, quattro ancore in ordine di dominio: ognuna [titolo, testo].
  static const Map<String, List<List<String>>> anchors = {
    'aries': [
      ['Il fuoco che apre', 'Sei l\'inizio fatto persona, la scintilla che accende e oggi il coraggio di muovere il primo passo conta più del piano perfetto.'],
      ['Cuore in avanti', 'In amore vai diretto, come è nella tua natura di fuoco, la tua sincerità disarma e chi ti ama apprezza lo slancio più della prudenza.'],
      ['Slancio da guidare', 'Sul lavoro apri varchi dove altri vedono muri, la tua spinta è un dono, basta darle una direzione oltre alla velocità.'],
      ['L\'audacia premiata', 'La sorte, con te, ama chi osa, un rischio calcolato oggi vale più di mille attese prudenti.'],
    ],
    'taurus': [
      ['La forza della calma', 'La tua natura di terra cerca stabilità e bellezza concreta, oggi costruisci con calma, un passo solido vale più di dieci affrettati.'],
      ['Tenerezza che dura', 'Ami coi sensi e con la fedeltà, attraverso i gesti più che le parole, la tua dolcezza paziente è ciò che fa sentire l\'altro a casa.'],
      ['Il valore che resta', 'Sul lavoro ottieni per costanza ciò che altri inseguono per foga, la tua tenacia è la tua firma, non avere fretta di raccoglierne i frutti.'],
      ['L\'abbondanza concreta', 'La tua fortuna ha radici, non ali, premia ciò che curi con pazienza e oggi qualcosa di seminato inizia a fruttare.'],
    ],
    'gemini': [
      ['La mente che collega', 'Vivi di scambi, parole e idee che rimbalzano, oggi la tua curiosità è la bussola, segui il filo che ti accende senza disperderti.'],
      ['Il gioco della parola', 'Ti innamori delle menti vivaci e delle conversazioni che non finiscono, oggi una parola leggera può accendere più di un gesto solenne.'],
      ['Idee in movimento', 'Sul lavoro brilli collegando ciò che gli altri tengono separato, la tua versatilità è forza, scegli una pista e portala fino in fondo.'],
      ['Il caso curioso', 'La tua fortuna passa dagli incontri e dall\'informazione giusta al momento giusto, oggi tieni occhi e orecchie ben aperti.'],
    ],
    'cancer': [
      ['Il cuore che protegge', 'Senti tutto e ricordi tutto, la tua forza è la cura, oggi concediti dolcezza, un gesto gentile verso te o chi ami cambia il tono del giorno.'],
      ['Il nido degli affetti', 'Ami con tenerezza e dedizione e hai bisogno di sentirti al sicuro per aprirti, oggi un piccolo rifugio condiviso vale più di ogni promessa.'],
      ['La cura che costruisce', 'Sul lavoro proteggi e nutri ciò che ti sta a cuore, la tua sensibilità legge le persone, usala come vantaggio e non come peso.'],
      ['La marea gentile', 'La tua fortuna segue le maree dell\'intuito, oggi fidati di ciò che senti sotto la superficie, ti sta indicando la direzione.'],
    ],
    'leo': [
      ['La gioia di brillare', 'Sei calore, creatività e generosità che scalda, oggi esprimi ciò che sei senza chiedere permesso, la tua luce fa spazio anche agli altri.'],
      ['Il cuore generoso', 'Ami con slancio e teatro, doni tanto e chiedi di essere visto, oggi la tua lealtà calorosa è irresistibile, mostrala senza timore.'],
      ['Il palco è tuo', 'Sul lavoro convinci con la passione più che con la logica fredda, oggi metti la tua idea al centro, il tuo entusiasmo è contagioso.'],
      ['Il favore del Sole', 'La tua fortuna risponde al tuo calore, più doni e crei più ricevi e oggi la vita sembra rispondere al tuo sorriso.'],
    ],
    'virgo': [
      ['La cura del dettaglio', 'Osservi, distingui e migliori, trovi il sacro nelle piccole cose fatte bene, oggi un gesto ordinato rimette in pace anche la mente.'],
      ['L\'amore nei piccoli gesti', 'Ami rendendoti utile, con attenzione e discrezione, oggi lascia che qualcuno si prenda cura di te, non solo il contrario.'],
      ['La maestria del metodo', 'Sul lavoro cogli il dettaglio che sfugge a tutti, oggi la tua precisione fa la differenza, senza scambiare un difetto per il tutto.'],
      ['Il frutto del lavoro', 'La tua fortuna nasce dal fare bene ciò che tocchi, oggi un piccolo miglioramento apre una porta più grande.'],
    ],
    'libra': [
      ['L\'arte dell\'equilibrio', 'Cerchi armonia, bellezza e giustizia, fiorisci nell\'incontro, oggi rimetti al centro ciò che ti dà pace, senza temere di scegliere.'],
      ['Il piacere di stare in due', 'Qui l\'amore è la tua arte, cerchi eleganza e sintonia, oggi un piccolo gesto di grazia riporta dolcezza in un legame.'],
      ['La forza della misura', 'Sul lavoro la tua diplomazia è un talento raro, oggi medi dove altri litigano e questo ti fa avanzare senza rumore.'],
      ['L\'incontro giusto', 'La tua fortuna arriva dalle persone giuste e dalla bellezza condivisa, oggi un incontro può valere più di mille sforzi solitari.'],
    ],
    'scorpio': [
      ['La forza di rinascere', 'Vivi tutto in profondità, senza mezze misure, oggi lascia andare ciò che pesa, la tua forza cresce attraversando e non evitando.'],
      ['L\'intensità vera', 'Ami senza vie di mezzo, vuoi verità e profondità, oggi la tua sfida è fidarti e proprio lì si nasconde la tenerezza più grande.'],
      ['La strategia paziente', 'Sul lavoro agisci sotto controllo fino al momento giusto, oggi la tua determinazione silenziosa vale più di ogni proclama.'],
      ['Il tesoro nascosto', 'La tua fortuna sta dove altri non osano guardare, oggi un dettaglio sottovalutato può rivelarsi il tuo vantaggio.'],
    ],
    'sagittarius': [
      ['La fame di orizzonte', 'Cerchi senso, libertà e avventura, la mente e i piedi vogliono lontano, oggi allarga lo sguardo, una prospettiva nuova scioglie un nodo vecchio.'],
      ['Il volo condiviso', 'Ti innamori dell\'avventura e della crescita a due, oggi cerca leggerezza e complicità, l\'amore che ti somiglia non è mai una gabbia.'],
      ['La spinta verso l\'alto', 'Sul lavoro il tuo entusiasmo è contagioso e apre porte, oggi punta in grande, curando anche il passo dopo il passo.'],
      ['Il favore di Giove', 'La tua fortuna ama l\'ottimismo e il movimento, oggi un sì detto con fiducia può portarti più lontano del previsto.'],
    ],
    'capricorn': [
      ['La pazienza che scala', 'Costruisci nel tempo, con disciplina e responsabilità, le vette non ti spaventano, oggi un passo concreto ti avvicina a ciò che conta.'],
      ['La fedeltà che dura', 'Sotto il riserbo custodisci una fedeltà profonda, oggi concediti tenerezza, mostrare un lato morbido non toglie nulla alla tua forza.'],
      ['La vetta un passo alla volta', 'Sul lavoro nessuno costruisce per i propri obiettivi come te, oggi la tua serietà viene notata, i risultati parlano al posto tuo.'],
      ['Il merito premiato', 'La tua fortuna si costruisce mattone su mattone, oggi qualcosa di guadagnato con fatica inizia a darti ragione.'],
    ],
    'aquarius': [
      ['La visione del futuro', 'Pensi diverso e guardi avanti, ami la libertà e le persone, oggi un\'idea fuori dagli schemi merita spazio, non la trattenere.'],
      ['Il legame che libera', 'Ami in modo originale e paritario, l\'amante è anche un complice, oggi la tua autenticità attira più di ogni convenzione.'],
      ['L\'idea che apre strade', 'Sul lavoro vedi ciò che gli altri non osano immaginare, oggi la tua originalità è una risorsa, condividila senza timore del giudizio.'],
      ['La sorpresa geniale', 'La tua fortuna arriva quando pensi in grande e per tutti, oggi una via inattesa può rivelarsi la più giusta.'],
    ],
    'pisces': [
      ['L\'anima senza confini', 'Senti l\'invisibile, sogni e ti fondi col tutto, empatia e immaginazione sono il tuo dono, oggi ascolta l\'intuito e poi dagli dei confini.'],
      ['La dolcezza che avvolge', 'Ami in modo tenero e avvolgente, quasi senza riserve, oggi ricordati di chiedere e non solo di dare, la tua dolcezza merita di essere ricambiata.'],
      ['L\'ispirazione che guida', 'Sul lavoro la tua sensibilità coglie ciò che sfugge ai numeri, oggi un\'intuizione vale un piano, mettila a terra con un piccolo gesto pratico.'],
      ['Il dono dell\'intuito', 'La tua fortuna passa dai segni sottili e dalle coincidenze, oggi fidati della prima sensazione, ti sta guidando bene.'],
    ],
  };

  /// I pool della corrente del giorno, dieci frasi per dominio, per tutti i segni.
  static const Map<int, List<String>> dayPools = {
    0: [
      'Oggi parti dal primo passo, il resto si chiarisce strada facendo.',
      'Una piccola scelta di oggi vale più di un grande piano rimandato.',
      'Il ritmo giusto lo detti tu, non chi ti corre intorno.',
      'Ascolta cosa ti chiede il corpo prima di riempire l\'agenda.',
      'Un imprevisto può rivelarsi la parte migliore della giornata.',
      'Concediti una pausa vera, la lucidità torna nel silenzio.',
      'Di\' un sì convinto o un no chiaro, i forse oggi ti pesano.',
      'La giornata premia chi resta presente, non chi anticipa tutto.',
      'Rimetti al centro una cosa che conta, lascia cadere il rumore.',
      'Fidati di ciò che senti, oggi la tua intuizione ci vede lungo.',
    ],
    1: [
      'Oggi la sincerità apre più porte di qualsiasi strategia.',
      'Un gesto piccolo dice più di mille parole rimandate.',
      'Chi ti sta vicino aspetta un tuo passo, fallo senza timore.',
      'Lascia respirare l\'altro, la giusta distanza avvicina.',
      'Una conversazione sospesa oggi può ritrovare il suo filo.',
      'Mostra il lato che di solito proteggi, verrà accolto.',
      'Se sei in coppia, la tenerezza conta più della ragione.',
      'Se sei da solo, un incontro leggero merita attenzione.',
      'Perdona una piccola ruvidezza, non tutto va discusso.',
      'Ascolta davvero, prima di rispondere fai un respiro.',
    ],
    2: [
      'Un\'idea proposta al momento giusto oggi trova ascolto.',
      'Concentra le forze su una cosa sola e portala a termine.',
      'Chiedi ciò che ti spetta con calma, la fermezza paga.',
      'Un collega può diventare un alleato, apri uno spiraglio.',
      'Rimanda la mossa rischiosa, oggi la pazienza rende di più.',
      'Il dettaglio che curi adesso ti evita un problema domani.',
      'Fatti notare per come risolvi, non per quanto corri.',
      'Una porta che sembrava chiusa merita un secondo bussare.',
      'Metti ordine prima di aggiungere, la chiarezza sblocca.',
      'Il tuo valore si vede nei fatti, lascia che parlino.',
    ],
    3: [
      'La sorte oggi premia chi osa un piccolo passo in più.',
      'Tieni gli occhi aperti, un\'occasione arriva travestita da caso.',
      'Un incontro inatteso porta con sé una buona notizia.',
      'Segui la coincidenza, oggi non è affatto casuale.',
      'La fortuna gira dalla tua parte nel pomeriggio, fatti trovare pronto.',
      'Un no di ieri libera lo spazio per un sì migliore.',
      'Rischia con misura, il cielo accompagna chi si fida.',
      'Una parola detta al momento giusto ti apre una via.',
      'Cerca il bello nelle piccole cose, oggi si moltiplica.',
      'Un vecchio contatto può tornare utile, non stupirti.',
    ],
  };

  /// Le palette del colore del giorno, per id del segno.
  static const Map<String, List<String>> palettes = {
    'aries': ['rosso', 'oro', 'corallo', 'cremisi'],
    'taurus': ['verde salvia', 'terracotta', 'ottone', 'rosa antico'],
    'gemini': ['giallo', 'azzurro', 'argento', 'lilla'],
    'cancer': ['argento', 'bianco perla', 'blu notte', 'glicine'],
    'leo': ['oro', 'ambra', 'arancio', 'porpora'],
    'virgo': ['verde bosco', 'beige', 'blu polvere', 'bronzo'],
    'libra': ['rosa cipria', 'verde acqua', 'oro rosa', 'celeste'],
    'scorpio': ['rosso scuro', 'nero', 'bordeaux', 'verde smeraldo'],
    'sagittarius': ['viola', 'indaco', 'oro', 'turchese'],
    'capricorn': ['grigio pietra', 'marrone', 'verde scuro', 'antracite'],
    'aquarius': ['turchese', 'blu elettrico', 'argento', 'blu ghiaccio'],
    'pisces': ['verde mare', 'lavanda', 'argento', 'blu oltremare'],
  };

  /// La riga di disclaimer, mostrata una sola volta.
  static const String disclaimer = 'Il cielo inclina, non obbliga: nessun destino è scritto, la scelta resta tua.';
}
