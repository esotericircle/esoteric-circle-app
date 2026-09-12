// GENERATO da tool/_gen_oroscopo.py a partire da docs/corpus/oroscopo.md.
// Fonte di verita': il corpus. Non modificare a mano: rigenerare dal corpus.
//
// I dati su dispositivo dell'Oroscopo a quattro schede di Medora: le aperture
// personalizzate, le ancore dei dodici segni per i quattro domini, i pool della
// corrente del giorno, le palette del colore del giorno e la riga di disclaimer.

/// Dati dell'Oroscopo, trascritti dal corpus. Chiavi per id del segno
/// (`Zodiac.id`) e per indice del dominio (Generale 0, Amore 1, Carriera 2,
/// Fortuna 3).
class HoroscopeData {
  const HoroscopeData._();

  /// Le aperture personalizzate. Il segnaposto `[Nome]` si sostituisce col
  /// vocativo completo (Caro o Cara piu' il nome, altrimenti Ciao piu' il nome).
  static const String namePlaceholder = '[Nome]';

  static const List<String> openings = [
    '[Nome], oggi il cielo ha qualcosa da dirti.',
    '[Nome], le stelle di oggi ti guardano con favore.',
    '[Nome], oggi Medora ti accompagna passo dopo passo.',
    '[Nome], c\'è un buon vento nelle stelle di oggi.',
    '[Nome], oggi il tuo cielo si accende.',
    '[Nome], lascia che il cielo di oggi ti sorprenda.',
  ];

  /// Per ogni segno, quattro ancore in ordine di dominio: ognuna [titolo, testo].
  static const Map<String, List<List<String>>> anchors = {
    'aries': [
      [
        'Il fuoco che apre',
        'Sei l\'inizio fatto persona, la scintilla che accende prima che gli altri abbiano finito di decidere. Il coraggio del primo passo è la tua misura e ogni giorno gli sceglie una direzione diversa.'
      ],
      [
        'Cuore in avanti',
        'In amore vai diretto, come vuole la tua natura di fuoco e la tua sincerità disarma perché chi ti ama sceglie proprio il tuo slancio. Dove quello slancio serva davvero, cambia col cielo.'
      ],
      [
        'Slancio da guidare',
        'Sul lavoro apri varchi dove altri vedono muri e la tua spinta è un dono che chiede una direzione più che un freno. La direzione la porta il giorno.'
      ],
      [
        'L\'audacia premiata',
        'La sorte, con te, ama chi osa e un rischio calcolato ti rende più di mille attese prudenti. Quale rischio valga la pena, lo mostra il giorno.'
      ],
    ],
    'taurus': [
      [
        'La forza della calma',
        'La tua natura di terra cerca stabilità e bellezza concreta e costruisci meglio di chiunque quando nessuno ti mette fretta. Dove posare il prossimo mattone, lo indica il giorno.'
      ],
      [
        'Tenerezza che dura',
        'Ami coi sensi e con la fedeltà, attraverso i gesti più che le parole e la tua dolcezza paziente è ciò che fa sentire l\'altro a casa. Quale gesto conti adesso, cambia col cielo.'
      ],
      [
        'Il valore che resta',
        'Sul lavoro ottieni per costanza ciò che altri inseguono per foga e la tua tenacia è la tua firma. Quanto sia vicino il raccolto, lo dice il giorno.'
      ],
      [
        'L\'abbondanza concreta',
        'La tua fortuna ha radici e non ali e premia ciò che curi con pazienza. Quale seme sia pronto a fruttare lo scrive il giorno.'
      ],
    ],
    'gemini': [
      [
        'La mente che collega',
        'Vivi di scambi, di parole e di idee che rimbalzano e la curiosità ti fa da bussola meglio di qualunque piano. Quale filo seguire, te lo indica il giorno.'
      ],
      [
        'Il gioco della parola',
        'Ti innamori delle menti vivaci e delle conversazioni che non finiscono e una frase leggera può accendere più di un gesto solenne. Con chi vada spesa, cambia col cielo.'
      ],
      [
        'Idee in movimento',
        'Sul lavoro brilli collegando ciò che gli altri tengono separato e la versatilità è forza finché una pista la porti fino in fondo. Quale sia la tua pista, lo indica il cielo.'
      ],
      [
        'Il caso curioso',
        'La tua fortuna passa dagli incontri e dall\'informazione giusta al momento giusto ed è un dono che si presenta senza bussare. Da che parte stia arrivando lo racconta il giorno.'
      ],
    ],
    'cancer': [
      [
        'Il cuore che protegge',
        'Senti tutto e ricordi tutto e la tua forza si chiama cura, non durezza. Verso chi rivolgerla lo suggerisce il giorno.'
      ],
      [
        'Il nido degli affetti',
        'Ami con tenerezza e dedizione e hai bisogno di sentirti al sicuro prima di aprirti del tutto. Quanto sicuro sia il terreno, cambia col cielo.'
      ],
      [
        'La cura che costruisce',
        'Sul lavoro proteggi e nutri ciò che ti sta a cuore e la tua sensibilità legge le persone prima che parlino. Cosa stia chiedendo di essere letto, lo scrive il giorno.'
      ],
      [
        'La marea gentile',
        'La tua fortuna segue le maree dell\'intuito e sotto la superficie sai già dove guardare. Quale marea stia salendo, lo segna il cielo.'
      ],
    ],
    'leo': [
      [
        'La gioia di brillare',
        'Sei calore, creatività e generosità che scalda e la tua luce fa spazio agli altri invece di toglierlo. Dove accenderla, lo indica il giorno.'
      ],
      [
        'Il cuore generoso',
        'Ami con slancio e con teatro, doni molto e chiedi di essere visto e la tua lealtà calorosa è irresistibile quando non la trattieni. A chi stia arrivando, cambia col cielo.'
      ],
      [
        'Il palco è tuo',
        'Sul lavoro convinci con la passione più che con la logica fredda e il tuo entusiasmo diventa contagioso quando ha un\'idea al centro. Quale idea mettere al centro, te lo suggerisce il cielo.'
      ],
      [
        'Il favore del Sole',
        'La tua fortuna risponde al tuo calore e più doni e più crei, più la vita ti risponde. Da dove ti risponda lo racconta il giorno.'
      ],
    ],
    'virgo': [
      [
        'La cura del dettaglio',
        'Osservi, distingui e migliori e trovi il sacro nelle piccole cose fatte bene. Quale piccola cosa rimetta in pace anche la mente, lo indica il giorno.'
      ],
      [
        'L\'amore nei piccoli gesti',
        'Ami rendendoti utile, con attenzione e discrezione e ti riesce più facile dare che ricevere. Da dove possa arrivare la cura per te, cambia col cielo.'
      ],
      [
        'La maestria del metodo',
        'Sul lavoro cogli il dettaglio che sfugge a tutti e la precisione è il tuo vantaggio finché non scambi un difetto per il tutto. Dove metterla, lo segna il giorno.'
      ],
      [
        'Il frutto del lavoro',
        'La tua fortuna nasce dal fare bene ciò che tocchi e un miglioramento minimo ti apre porte grandi. Quale porta sia socchiusa lo scrive il giorno.'
      ],
    ],
    'libra': [
      [
        'L\'arte dell\'equilibrio',
        'Cerchi armonia, bellezza e giustizia e fiorisci nell\'incontro più che nella solitudine. Cosa rimettere al centro per ritrovare la pace, lo suggerisce il giorno.'
      ],
      [
        'Il piacere di stare in due',
        'Qui l\'amore è la tua arte, cerchi eleganza e sintonia e un gesto di grazia ti vale più di una discussione vinta. Dove quel gesto serva, cambia col cielo.'
      ],
      [
        'La forza della misura',
        'Sul lavoro la tua diplomazia è un talento raro e medi dove gli altri litigano avanzando senza rumore. Quale tavolo ci sia da ricomporre, lo mostra il cielo.'
      ],
      [
        'L\'incontro giusto',
        'La tua fortuna arriva dalle persone giuste e dalla bellezza condivisa e un incontro ti vale più di mille sforzi solitari. Da che parte arrivi lo racconta il giorno.'
      ],
    ],
    'scorpio': [
      [
        'La forza di rinascere',
        'Vivi tutto in profondità, senza mezze misure e la tua forza cresce attraversando invece di evitare. Cosa ci sia da attraversare lo indica il giorno.'
      ],
      [
        'L\'intensità vera',
        'Ami senza vie di mezzo e vuoi verità e la tua sfida non è sentire ma fidarti. Dove il terreno regga la fiducia, cambia col cielo.'
      ],
      [
        'La strategia paziente',
        'Sul lavoro ti muovi sotto controllo fino al momento giusto e la determinazione silenziosa ti vale più di ogni proclama. Se il momento sia arrivato, lo dice il cielo.'
      ],
      [
        'Il tesoro nascosto',
        'La tua fortuna sta dove gli altri non osano guardare e un dettaglio sottovalutato diventa il tuo vantaggio. Quale dettaglio sia, lo scrive il giorno.'
      ],
    ],
    'sagittarius': [
      [
        'La fame di orizzonte',
        'Cerchi senso, libertà e avventura e la mente ti porta lontano prima dei piedi. Verso quale orizzonte guardare, lo indica il giorno.'
      ],
      [
        'Il volo condiviso',
        'Ti innamori dell\'avventura e della crescita a due e l\'amore che ti somiglia non è mai una gabbia. Dove trovare quella leggerezza, cambia col cielo.'
      ],
      [
        'La spinta verso l\'alto',
        'Sul lavoro il tuo entusiasmo apre porte e puntare in grande ti riesce naturale quando curi anche il passo dopo il passo. Quale passo venga per primo, lo decide il giorno.'
      ],
      [
        'Il favore di Giove',
        'La tua fortuna ama l\'ottimismo e il movimento e un sì detto con fiducia ti porta più lontano del previsto. A cosa dirlo lo racconta il giorno.'
      ],
    ],
    'capricorn': [
      [
        'La pazienza che scala',
        'Costruisci nel tempo, con disciplina e responsabilità e le vette non ti hanno mai spaventato. Quale passo concreto ti avvicini davvero, lo indica il giorno.'
      ],
      [
        'La fedeltà che dura',
        'Sotto il riserbo custodisci una fedeltà profonda e mostrare un lato morbido non toglie niente alla tua forza. Quando valga la pena mostrarlo, cambia col cielo.'
      ],
      [
        'La vetta un passo alla volta',
        'Sul lavoro nessuno costruisce per i propri obiettivi come te e i tuoi risultati parlano al posto tuo prima che tu apra bocca. Quanto siano stati notati, te lo racconta il cielo.'
      ],
      [
        'Il merito premiato',
        'La tua fortuna si costruisce mattone su mattone e ciò che hai guadagnato con fatica prima o poi ti dà ragione. Quando cominci a vederlo lo scrive il giorno.'
      ],
    ],
    'aquarius': [
      [
        'La visione del futuro',
        'Pensi diverso e guardi avanti e ami la libertà quanto le persone. Quale idea fuori dagli schemi meriti spazio, lo indica il giorno.'
      ],
      [
        'Il legame che libera',
        'Ami in modo originale e paritario e per te l\'amante è anche un complice. Dove la tua autenticità venga accolta, cambia col cielo.'
      ],
      [
        'L\'idea che apre strade',
        'Sul lavoro vedi ciò che gli altri non osano immaginare e la tua originalità è una risorsa quando smette di temere il giudizio. Con chi condividerla, lo apre il giorno.'
      ],
      [
        'La sorpresa geniale',
        'La tua fortuna arriva quando pensi in grande e per tutti e la via inattesa è quasi sempre la tua. Quale via si stia aprendo lo racconta il giorno.'
      ],
    ],
    'pisces': [
      [
        'L\'anima senza confini',
        'Senti l\'invisibile, sogni e ti fondi col tutto e l\'intuito ti serve meglio quando gli dai dei confini. Dove tracciarli, lo indica il giorno.'
      ],
      [
        'La dolcezza che avvolge',
        'Ami in modo tenero e avvolgente, quasi senza riserve e la tua dolcezza merita di essere ricambiata quanto è donata. Da chi possa tornarti, cambia col cielo.'
      ],
      [
        'L\'ispirazione che guida',
        'Sul lavoro la tua sensibilità coglie ciò che sfugge ai numeri e un\'intuizione ti vale un piano quando la metti a terra. Su cosa metterla, te lo indica il cielo.'
      ],
      [
        'Il dono dell\'intuito',
        'La tua fortuna passa dai segni sottili e dalle coincidenze e la prima sensazione ti guida bene più spesso di quanto ammetti. Verso dove ti stia guidando lo scrive il giorno.'
      ],
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
  static const String disclaimer =
      'Il cielo inclina, non obbliga: nessun destino è scritto, la scelta resta tua.';
}
