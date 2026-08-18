import '../sigilli/eventi_del_cielo.dart';
import 'prossimi_eventi.dart';

/// COME IL CERCHIO CHIAMA GLI EVENTI DEL CIELO, in un punto solo.
///
/// I nomi tecnici (`luna_piena`, `mercurio_diretto`) vivono nei file di dati
/// dei sentieri e non si toccano; qui c'e' come si dicono a una persona, e
/// la riga di significato che il Calendario mostra sotto la data.
///
/// **Le righe di significato poggiano su tradizioni reali e non promettono
/// niente.** Nessun imperativo, nessuna divinazione: si dice cosa succede in
/// cielo e cosa quella cosa ha significato per chi la guardava, che e' la
/// regola dei briefing. Chi legge decide da solo.
class LinguaDegliEventi {
  const LinguaDegliEventi._();

  static const Map<String, String> _nomi = {
    EventiDelCielo.lunaPiena: 'Luna piena',
    EventiDelCielo.lunaNuova: 'Luna nuova',
    EventiDelCielo.primoQuarto: 'Primo quarto',
    EventiDelCielo.ultimoQuarto: 'Ultimo quarto',
    EventiDelCielo.lunaCrescente: 'Luna crescente',
    EventiDelCielo.lunaCalante: 'Luna calante',
    EventiDelCielo.lunaNelTuoSegno: 'La Luna nel tuo segno',
    EventiDelCielo.lunaNelSegnoOpposto: 'La Luna nel segno opposto',
    EventiDelCielo.soleNelTuoSegno: 'Il Sole nel tuo segno',
    EventiDelCielo.ritornoSolare: 'Il tuo ritorno solare',
    EventiDelCielo.solstizio: 'Solstizio',
    EventiDelCielo.equinozio: 'Equinozio',
    EventiDelCielo.mercurioRetrogrado: 'Mercurio retrogrado',
    EventiDelCielo.mercurioDiretto: 'Mercurio torna diretto',
    EventiDelCielo.venereRetrograda: 'Venere retrograda',
    EventiDelCielo.venereDiretta: 'Venere torna diretta',
    EventiDelCielo.marteRetrogrado: 'Marte retrogrado',
    EventiDelCielo.marteDiretto: 'Marte torna diretto',
    EventiDelCielo.gioveRetrogrado: 'Giove retrogrado',
    EventiDelCielo.gioveDiretto: 'Giove torna diretto',
    EventiDelCielo.saturnoRetrogrado: 'Saturno retrogrado',
    EventiDelCielo.saturnoDiretto: 'Saturno torna diretto',
    EventiDelCielo.transitoSullAscendente: 'Un transito sul tuo Ascendente',
    EventiDelCielo.transitoSulSole: 'Un transito sul tuo Sole',
    EventiDelCielo.transitoSullaLuna: 'Un transito sulla tua Luna',
    EventiDelCielo.transitoSuVenere: 'Un transito sulla tua Venere',
    EventiDelCielo.transitoSuMarte: 'Un transito sul tuo Marte',
    EventiDelCielo.lunaPienaNelTuoSegno: 'Luna piena nel tuo segno',
    EventiDelCielo.lunaNuovaNelTuoSegno: 'Luna nuova nel tuo segno',
    EventiDelCielo.treTransitiInsieme: 'Tre transiti insieme',
  };

  static const Map<String, String> _significati = {
    EventiDelCielo.lunaPiena:
        'Il disco e\' interamente illuminato. Nelle tradizioni agricole e '
            'rituali era il momento del raccolto e del bilancio.',
    EventiDelCielo.lunaNuova:
        'La Luna sparisce dal cielo. I calendari lunari fanno cominciare da '
            'qui il mese, e con lui cio\' che si semina.',
    EventiDelCielo.primoQuarto:
        'Meta\' disco illuminato, in crescita. Il punto in cui l\'intenzione '
            'incontra il primo ostacolo.',
    EventiDelCielo.ultimoQuarto:
        'Meta\' disco illuminato, in calo. Nelle tradizioni e\' il tempo di '
            'lasciare andare cio\' che ha finito il suo giro.',
    EventiDelCielo.lunaNelTuoSegno:
        'La Luna attraversa il tuo segno solare. Succede ogni mese e dura '
            'circa due giorni.',
    EventiDelCielo.lunaNelSegnoOpposto:
        'La Luna sta nel segno opposto al tuo: l\'astrologia lo chiama il '
            'punto della relazione, dove ci si vede dall\'altra parte.',
    EventiDelCielo.soleNelTuoSegno:
        'Il Sole percorre il tuo segno per circa trenta giorni. E\' la '
            'stagione in cui cade il tuo compleanno.',
    EventiDelCielo.ritornoSolare:
        'Il Sole torna esattamente dov\'era quando sei nato. E\' il '
            'compleanno astronomico, che non sempre cade nel giorno civile.',
    EventiDelCielo.solstizio:
        'Il Sole raggiunge la sua massima distanza dall\'equatore celeste: '
            'il giorno piu\' lungo o piu\' corto dell\'anno.',
    EventiDelCielo.equinozio:
        'Il giorno e la notte durano uguale su tutta la Terra. Da qui '
            'cominciavano molti anni antichi.',
    EventiDelCielo.mercurioRetrogrado:
        'Visto dalla Terra, Mercurio sembra tornare indietro. E\' un effetto '
            'prospettico, e la tradizione lo lega ai malintesi e alle cose da '
            'rivedere.',
    EventiDelCielo.mercurioDiretto:
        'Mercurio riprende il moto in avanti. La tradizione lo legge come il '
            'momento in cui i discorsi rimasti sospesi ripartono.',
    EventiDelCielo.venereRetrograda:
        'Venere sembra tornare indietro. La tradizione la lega ai legami che '
            'chiedono di essere riconsiderati.',
    EventiDelCielo.venereDiretta:
        'Venere riprende il moto diretto. Nella tradizione i legami tornano a '
            'muoversi in avanti.',
    EventiDelCielo.marteRetrogrado:
        'Marte sembra tornare indietro. La tradizione lo lega alla forza che '
            'si volge verso l\'interno invece che verso l\'azione.',
    EventiDelCielo.marteDiretto:
        'Marte riprende il moto diretto: nella tradizione la spinta ritrova '
            'la sua direzione.',
    EventiDelCielo.gioveRetrogrado:
        'Giove sembra tornare indietro. La tradizione lo lega alla crescita '
            'che si consolida invece di espandersi.',
    EventiDelCielo.gioveDiretto:
        'Giove riprende il moto diretto: la tradizione lo legge come '
            'l\'apertura che torna a estendersi.',
    EventiDelCielo.saturnoRetrogrado:
        'Saturno sembra tornare indietro. La tradizione lo lega alle '
            'strutture che chiedono di essere riviste.',
    EventiDelCielo.saturnoDiretto:
        'Saturno riprende il moto diretto: nella tradizione cio\' che era '
            'sospeso trova la sua forma.',
    EventiDelCielo.transitoSullAscendente:
        'Un pianeta passa sul grado che sorgeva alla tua nascita: '
            'l\'astrologia lo considera il punto piu\' personale della carta.',
    EventiDelCielo.transitoSulSole:
        'Un pianeta passa sulla posizione del tuo Sole natale.',
    EventiDelCielo.transitoSullaLuna:
        'Un pianeta passa sulla posizione della tua Luna natale.',
    EventiDelCielo.transitoSuVenere:
        'Un pianeta passa sulla posizione della tua Venere natale.',
    EventiDelCielo.transitoSuMarte:
        'Un pianeta passa sulla posizione del tuo Marte natale.',
    EventiDelCielo.lunaPienaNelTuoSegno:
        'La Luna e\' piena proprio nel tuo segno: succede una volta l\'anno.',
    EventiDelCielo.lunaNuovaNelTuoSegno:
        'La Luna nuova cade nel tuo segno: una volta l\'anno, all\'inizio '
            'della tua stagione.',
    EventiDelCielo.treTransitiInsieme:
        'Tre pianeti toccano insieme punti della tua carta: una '
            'coincidenza rara nel tuo cielo.',
    EventiDelCielo.lunaCrescente:
        'La luce della Luna sta aumentando verso la piena.',
    EventiDelCielo.lunaCalante:
        'La luce della Luna sta calando verso la nuova.',
  };

  /// Come si chiama, per una persona. Se un evento nuovo entrasse senza
  /// nome, si mostra il nome tecnico invece di sparire: meglio una parola
  /// brutta di un buco.
  static String nomeDi(String evento) => _nomi[evento] ?? evento;

  /// La riga di significato, oppure nulla se non ne ha una.
  static String? significatoDi(String evento) => _significati[evento];

  /// IL CONTO ALLA ROVESCIA, in lingua del Cerchio.
  ///
  /// Oggi si dice "oggi"; il giorno dopo "domani"; poi i giorni. Sopra la
  /// settimana si passa alle settimane, e sopra il mese ai mesi: "fra 87
  /// giorni" e' un numero che nessuno traduce in un'attesa.
  static String fraQuanto(int giorni) {
    if (giorni <= 0) return 'oggi';
    if (giorni == 1) return 'domani';
    if (giorni < 7) return 'fra $giorni giorni';
    if (giorni < 14) return 'fra una settimana';
    if (giorni < 31) return 'fra ${(giorni / 7).round()} settimane';
    if (giorni < 60) return 'fra un mese';
    return 'fra ${(giorni / 30).round()} mesi';
  }

  /// La riga intera che la barra mostra: il nome e quanto manca.
  static String rigaDellaBarra(EventoInArrivo evento) =>
      '${nomeDi(evento.evento)}, ${fraQuanto(evento.fraQuantiGiorni)}';

  /// La data per esteso, come la scrive il Cerchio: "27 agosto".
  static String dataBreve(DateTime quando) =>
      '${quando.day} ${_mesi[quando.month - 1]}';

  static const List<String> _mesi = [
    'gennaio',
    'febbraio',
    'marzo',
    'aprile',
    'maggio',
    'giugno',
    'luglio',
    'agosto',
    'settembre',
    'ottobre',
    'novembre',
    'dicembre',
  ];
}
