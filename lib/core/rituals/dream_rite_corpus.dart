import '../astro/night_sky.dart';
import '../astro/zodiac.dart';
import '../identity/birth_moon.dart';
import '../maestro/maestro.dart';
import 'daily_elements.dart';
import 'relazione_lunare.dart';
import '../../core/chat/user_profile.dart';

/// La voce del Sigillo del Sogno per un segno della Luna: una parola calmante e le
/// righe che guardano al giorno appena concluso.
///
/// Non e' tradizione nuova: ogni voce riscrive in chiave riflessiva il
/// significato del segno lunare gia' nel repo (`BirthMoon.meaningFor`, il
/// sentire nel segno, nella voce di Medora). Il rito guarda al passato e al
/// presente della giornata, mai al futuro.
class VoceDelSogno {
  const VoceDelSogno({
    required String parola,
    required String immagine,
    required String giorno,
    required String riconoscimento,
    required String posa,
    List<String> altriGiorni = const [],
    List<String> altriRiconoscimenti = const [],
  })  : _parola = parola,
        _immagine = immagine,
        _giorno = giorno,
        _riconoscimento = riconoscimento,
        _posa = posa,
        _altriGiorni = altriGiorni,
        _altriRiconoscimenti = altriRiconoscimenti;

  /// **LE VARIANTI, E PERCHE' ESISTONO.** Ordine EH voce 01, 24 settembre
  /// 2026.
  ///
  /// **Il fatto del fondatore**, due sere a confronto sul suo Realme: *"sto
  /// facendo dei test sul dono sigillo del sogno e mi sembra il testo uguale a
  /// ieri"*. Aveva ragione, e la colpa e' di una cura mia.
  ///
  /// **L'ordine EE voce 04 ha curato "generico" con "sempre uguale".** Prima
  /// queste due frasi venivano dal segno della Luna di STANOTTE, cioe' da un
  /// dato uguale per chiunque aprisse l'app quella sera: il rito diceva a
  /// tutti che quel giorno avevano pensato in largo. La cura le ha portate
  /// sulla **Luna di nascita**, che e' davvero il segno sotto cui quella
  /// persona guarda il proprio giorno. Ma la Luna di nascita **non cambia
  /// mai**: da allora quelle due frasi sono identiche ogni notte, per sempre,
  /// per ciascuno. Misurato su quattro notti di fila: identiche tutte e
  /// quattro.
  ///
  /// **La cura non torna indietro, aggiunge.** Il segno natale dice **come**
  /// quella persona attraversa una giornata, e resta la sorgente giusta: ma
  /// di quel come si possono dire piu' cose vere, e la notte sceglie quale.
  /// Non e' astrologia inventata, e' **quale delle cose vere si dice
  /// stasera**, che e' la stessa liberta' che questo corpus si prende gia'
  /// scegliendo una parola invece di un'altra.
  final List<String> _altriGiorni;
  final List<String> _altriRiconoscimenti;

  /// Quante cose diverse questa voce sa dire della giornata.
  int get quantiGiorni => 1 + _altriGiorni.length;

  /// Il [quale]esimo modo di dire la giornata, risolto con la forma.
  String giornoNumero(int quale) {
    final tutti = [_giorno, ..._altriGiorni];
    return LaMarcaDelGenere.risolvi(tutti[quale.abs() % tutti.length]);
  }

  /// Il [quale]esimo riconoscimento, risolto con la forma.
  String riconoscimentoNumero(int quale) {
    final tutti = [_riconoscimento, ..._altriRiconoscimenti];
    return LaMarcaDelGenere.risolvi(tutti[quale.abs() % tutti.length]);
  }

  /// Una parola sola, calmante, per la carta della notte.
  final String _parola;

  /// Risolto con la forma della persona, ordine DL voce 02.
  String get parola => LaMarcaDelGenere.risolvi(_parola);

  /// L'immagine del segno, in poche parole.
  final String _immagine;

  /// Risolto con la forma della persona, ordine DL voce 02.
  String get immagine => LaMarcaDelGenere.risolvi(_immagine);

  /// Cosa hai fatto oggi, al passato.
  final String _giorno;

  /// Risolto con la forma della persona, ordine DL voce 02.
  String get giorno => LaMarcaDelGenere.risolvi(_giorno);

  /// Cosa ti riconosci, guardando indietro.
  final String _riconoscimento;

  /// Risolto con la forma della persona, ordine DL voce 02.
  String get riconoscimento => LaMarcaDelGenere.risolvi(_riconoscimento);

  /// L'invito al presente, per posare il giorno.
  final String _posa;

  /// Risolto con la forma della persona, ordine DL voce 02.
  String get posa => LaMarcaDelGenere.risolvi(_posa);
}

/// Il Sigillo del Sogno, ex Rito della Buonanotte: il messaggio della notte, la
/// parola e la trasparenza, tutti deterministici dal cielo reale di adesso.
///
/// La Luna arriva da `NightSky.moonSign` per il segno e da `MoonPhase.forDate`
/// per la fase, tramite `BirthMoon.forDate`. Nessuna AI a runtime.
class DreamRiteCorpus {
  const DreamRiteCorpus._();

  static const Map<Zodiac, VoceDelSogno> _voci = {
    Zodiac.aries: VoceDelSogno(
      parola: 'Calma',
      immagine: 'il fuoco che parte per primo',
      giorno: 'hai acceso in fretta, forse più di una volta',
      riconoscimento: 'hai avuto coraggio quando serviva',
      altriGiorni: [
        'hai spinto per primo, dove altri aspettavano',
        'hai detto la tua prima di pensarci troppo',
      ],
      altriRiconoscimenti: [
        'hai aperto una strada che era chiusa',
        'non hai lasciato che una cosa marcisse in attesa',
      ],
      posa:
          "lascia che la scintilla si abbassi, la notte non chiede slancio, chiede riposo",
    ),
    Zodiac.taurus: VoceDelSogno(
      parola: 'Terra',
      immagine: 'la terra che tiene',
      giorno: 'hai retto il peso senza fare rumore',
      riconoscimento: 'hai dato stabilità a chi ti sta intorno',
      altriGiorni: [
        'hai tenuto il passo che sai tenere, senza affrettarlo',
        'hai messo mano a qualcosa di concreto',
      ],
      altriRiconoscimenti: [
        'hai fatto durare quello che tocchi',
        'hai fatto da punto fermo a qualcuno',
      ],
      posa: 'posa il carico, la notte non chiede solidità, chiede riposo',
    ),
    Zodiac.gemini: VoceDelSogno(
      parola: 'Silenzio',
      immagine: 'le due voci che si rincorrono',
      giorno: 'hai parlato molto, hai ascoltato altrettanto',
      riconoscimento: 'hai tenuto vivi i fili con gli altri',
      altriGiorni: [
        'hai tenuto insieme due cose che non stavano insieme',
        'hai cambiato idea senza che fosse un tradimento',
      ],
      altriRiconoscimenti: [
        'hai fatto arrivare una parola dove serviva',
        'hai tenuto la mente sveglia fino a sera',
      ],
      posa:
          'lascia posare le parole, la notte non chiede risposte, chiede riposo',
    ),
    Zodiac.cancer: VoceDelSogno(
      parola: 'Rifugio',
      immagine: 'la conchiglia che custodisce',
      giorno: 'hai protetto qualcuno, forse senza dirlo',
      riconoscimento: 'hai dato a qualcuno un posto dove stare',
      altriGiorni: [
        'hai badato a una casa, anche se non era la tua',
        'hai sentito prima di capire, come fai sempre',
      ],
      altriRiconoscimenti: [
        'hai fatto sentire qualcuno al sicuro',
        'hai ricordato una cosa che gli altri avevano scordato',
      ],
      posa: 'chiudi il guscio, la notte non chiede cura, chiede riposo',
    ),
    Zodiac.leo: VoceDelSogno(
      parola: 'Calore',
      immagine: 'il sole che scalda gli altri',
      giorno: 'hai dato luce, [ti sei speso|ti sei spesa|hai dato tanto]',
      riconoscimento: 'hai illuminato una stanza senza accorgertene',
      altriGiorni: [
        'hai tenuto il centro, anche quando pesava',
        'hai dato calore a una cosa che ne aveva bisogno',
      ],
      altriRiconoscimenti: [
        'hai fatto sentire visto qualcuno',
        'non hai lasciato che la giornata fosse grigia',
      ],
      posa: 'abbassa la fiamma, la notte non chiede di brillare, chiede riposo',
    ),
    Zodiac.virgo: VoceDelSogno(
      parola: 'Ordine',
      immagine: 'le mani che mettono a posto',
      giorno: 'hai curato i dettagli, uno dopo l\'altro',
      riconoscimento: 'hai reso semplice qualcosa di complicato',
      altriGiorni: [
        'hai rimesso in ordine qualcosa che non era tuo',
        'hai visto l\'errore che nessuno vedeva',
      ],
      altriRiconoscimenti: [
        'hai tolto un peso a qualcuno senza dirlo',
        'hai fatto funzionare una cosa e basta',
      ],
      posa:
          'lascia il resto per domani, la notte non chiede precisione, chiede riposo',
    ),
    Zodiac.libra: VoceDelSogno(
      parola: 'Equilibrio',
      immagine: 'la bilancia che pesa',
      giorno: 'hai misurato molto, chi accontentare e cosa lasciare andare',
      riconoscimento: 'hai tenuto insieme più di quanto credi',
      altriGiorni: [
        'hai ceduto un poco per tenere la pace',
        'hai cercato la parola giusta, non la prima',
      ],
      altriRiconoscimenti: [
        'hai evitato una frattura che stava arrivando',
        'hai dato a due ragioni lo stesso ascolto',
      ],
      posa: 'posa i piatti, la notte non chiede equilibrio, chiede riposo',
    ),
    Zodiac.scorpio: VoceDelSogno(
      parola: 'Profondità',
      immagine: "l'acqua che scava",
      giorno: 'hai sentito tutto fino in fondo',
      riconoscimento: 'hai guardato una verità senza voltarti',
      altriGiorni: [
        'hai guardato sotto la superficie di una cosa',
        'hai tenuto un silenzio che pesava',
      ],
      altriRiconoscimenti: [
        'non ti è bastata una spiegazione comoda',
        'hai retto un\'intensità che altri avrebbero schivato',
      ],
      posa:
          'lascia scendere il fondo, la notte non chiede intensità, chiede riposo',
    ),
    Zodiac.sagittarius: VoceDelSogno(
      parola: 'Sosta',
      immagine: 'la freccia che cerca lontano',
      giorno: 'hai guardato avanti, forse troppo avanti',
      riconoscimento: 'hai tenuto viva la fiducia',
      altriGiorni: [
        'hai cercato il senso, non solo il risultato',
        'hai allargato il discorso quando si stringeva',
      ],
      altriRiconoscimenti: [
        'hai dato una ragione per andare avanti',
        'non hai lasciato che diventasse tutto piccolo',
      ],
      posa: "abbassa l'arco, la notte non chiede orizzonti, chiede riposo",
    ),
    Zodiac.capricorn: VoceDelSogno(
      parola: 'Tregua',
      immagine: 'la roccia che sale piano',
      giorno: 'hai portato responsabilità che nessuno ha visto',
      riconoscimento: 'hai retto quello che dovevi reggere',
      altriGiorni: [
        'hai fatto la parte difficile senza cercarla',
        'hai guardato a lungo termine mentre gli altri guardavano a oggi',
      ],
      altriRiconoscimenti: [
        'hai portato a casa una cosa che andava portata',
        'hai tenuto una promessa che nessuno controllava',
      ],
      posa:
          'lascia la salita a domani, la notte non chiede disciplina, chiede riposo',
    ),
    Zodiac.aquarius: VoceDelSogno(
      parola: 'Spazio',
      immagine: "l'aria che non si lascia stringere",
      giorno: 'hai pensato in largo, per tutti',
      riconoscimento: 'hai tenuto uno sguardo libero',
      altriGiorni: [
        'hai visto la cosa da un lato che non guardava nessuno',
        'hai tenuto la tua distanza perché ti serviva',
      ],
      altriRiconoscimenti: [
        'hai difeso una idea che non conveniva',
        'non hai fatto una cosa solo perché si fa così',
      ],
      posa:
          'lascia andare il pensiero, la notte non chiede visione, chiede riposo',
    ),
    Zodiac.pisces: VoceDelSogno(
      parola: 'Sogno',
      immagine: "l'acqua che confonde i bordi",
      giorno: 'hai assorbito molto, anche ciò che non era tuo',
      riconoscimento: 'hai avuto compassione, anche quando costava',
      altriGiorni: [
        'hai lasciato che le cose ti attraversassero',
        'hai dato tempo a una persona che ne aveva bisogno',
      ],
      altriRiconoscimenti: [
        'hai capito senza che te lo spiegassero',
        'hai tenuto morbido un momento che stava indurendo',
      ],
      posa:
          'lascia sciogliere i confini, la notte non chiede empatia, chiede riposo',
    ),
  };

  /// La voce del segno lunare. C'e' sempre, per tutti e dodici.
  static VoceDelSogno voce(Zodiac sign) => _voci[sign]!;

  /// La parola sola della notte, per la carta.
  static String parola(Zodiac sign) => _voci[sign]!.parola;

  /// **LA RISPOSTA DELLA NOTTE IN UNA FRASE.** Ordine CO voce 17, 3 settembre
  /// 2026.
  ///
  /// La gerarchia dettata dal fondatore vuole al primo posto un titolo diretto
  /// che sia già una risposta. Il Sigillo del Sogno apriva con "Il saluto di
  /// Caligo", che è un'etichetta, e poi con una parola sola, che è una parola:
  /// la risposta arrivava terza.
  ///
  /// **La frase c'era già ed è [VoceDelSogno.posa]**, l'invito al presente per
  /// posare il giorno, una per segno lunare, dodici in tutto. Non c'era niente
  /// da scrivere: c'era da mostrarla per prima.
  ///
  /// Qui si limita a diventare una frase compiuta. Nel corpus è scritta in
  /// minuscolo e senza punto perché nasceva per stare dentro un periodo più
  /// lungo, e continua a starci: **il saluto per intero non cambia di una
  /// virgola**, e questa è la stessa frase vista da sola.
  static String rispostaDellaNotte(Zodiac sign) {
    final p = _voci[sign]!.posa.trim();
    if (p.isEmpty) return p;
    return '${p[0].toUpperCase()}${p.substring(1)}.';
  }

  /// La Luna reale di adesso: segno da `NightSky.moonSign`, fase da `MoonPhase`.
  static BirthMoon lunaDi(DateTime quando) => BirthMoon.forDate(quando);

  /// L'apertura sulla Luna, dalla sua fase reale.
  static String aperturaLuna(BirthMoon luna) {
    final segno = luna.sign.italianName;
    switch (luna.phase.italianName) {
      case 'Luna piena':
        return 'Stanotte la Luna è piena in $segno';
      case 'Luna nuova':
        return 'Stanotte la Luna è nuova in $segno';
      default:
        return luna.phase.waxing
            ? 'Stanotte la Luna cresce in $segno'
            : 'Stanotte la Luna cala in $segno';
    }
  }

  /// **PER QUANTE NOTTI ANCORA LA LUNA RESTA IN QUESTO SEGNO.** Ordine EH
  /// voce 01, decisione del fondatore del 24 settembre 2026.
  ///
  /// **Il fatto, e la scelta che ne e' seguita.** La costellazione a schermo
  /// e' quella del segno in cui sta la Luna, e la Luna in un segno ci resta
  /// **circa due giorni e mezzo**: due sere di fila la figura e' la stessa, e
  /// il fondatore l'ha notato. Messo davanti alla scelta ha deciso di **non**
  /// cambiarla: *"la figura del segno lunare e' la cosa piu' vera che il cielo
  /// di stanotte offre"*.
  ///
  /// **Allora lo si dice.** Parole sue: *"l'utente deve sapere perche' in 2
  /// righe dichiarate subito sotto... L'utente si rendera' conto cosi' che non
  /// si tratta di un errore o un refuso"*. Una ripetizione spiegata **non e'
  /// piu' una ripetizione, e' un fatto del cielo**: la Luna ci mette due
  /// giorni e mezzo ad attraversare un segno, e chi torna la sera dopo trova
  /// la stessa figura perche' la Luna non si e' ancora mossa.
  ///
  /// Si conta in avanti di giorno in giorno finche' il segno cambia. Non e'
  /// un'approssimazione: e' lo stesso `NightSky.moonSign` che disegna la
  /// figura, interrogato sulle notti che vengono.
  static int notteInCuiLaLunaCambiaSegno(DateTime quando, {int tetto = 4}) {
    final adesso = NightSky.moonSign(quando);
    for (var n = 1; n <= tetto; n++) {
      if (NightSky.moonSign(quando.add(Duration(days: n))) != adesso) return n;
    }
    return tetto;
  }

  /// La riga che spiega perche' la figura e' quella di ieri.
  ///
  /// Torna null quando la Luna cambia segno stanotte stessa: li' non c'e'
  /// niente da spiegare, e una spiegazione che non serve e' rumore.
  static String? perchePosaLaStessaFigura(DateTime quando) {
    final notti = notteInCuiLaLunaCambiaSegno(quando);
    if (notti <= 1) return null;
    final segno = NightSky.moonSign(quando).italianName;
    return notti == 2
        ? 'La Luna resta in $segno ancora una notte: fino a domani la figura '
            'del cielo è questa.'
        : 'La Luna resta in $segno ancora $notti notti: per tutte queste sere '
            'la figura del cielo è questa.';
  }

  /// L'attacco nella voce del Maestro di turno, che apre lo sguardo indietro.
  ///
  /// **NON E' PIU' UNA FRASE SOLA PER MAESTRO. Ordine EH voce 01, 24
  /// settembre 2026.**
  ///
  /// Qui c'era uno `switch` sul solo Maestro: per Medora tornava **sempre**
  /// *"Il cielo ha girato una carta sola, oggi."*, ogni notte, per sempre. Era
  /// la prima delle quattro parti che il fondatore ha visto identiche in due
  /// sere, e l'unica delle quattro a non dipendere **da nessun dato**.
  ///
  /// Adesso ogni Maestro ha quattro attacchi e la notte ne sceglie uno. Restano
  /// frasi d'atmosfera, che non affermano niente sul cielo: la varieta' qui non
  /// costa nessuna verita'.
  static const Map<Maestro, List<String>> _attacchi = {
    Maestro.medora: [
      'Il cielo ha girato una carta sola, oggi.',
      'Il giorno si chiude e il cielo lo sa prima di te.',
      'Una carta si posa e la notte la lascia riposare.',
      'Il cielo ha finito di parlare, per oggi.',
    ],
    Maestro.aura: [
      'Il corpo ha portato il giorno fin qui.',
      'Il respiro ha tenuto il tempo, dal mattino a adesso.',
      'Il giorno si è fermato nelle spalle e adesso può andare.',
      'Il corpo chiede quello che chiede ogni sera.',
    ],
    Maestro.caligo: [
      'Il giorno ha lasciato la sua ombra lunga.',
      'Le ore si sono fatte segno e il segno resta.',
      'Il giorno si ritira e lascia scritto qualcosa.',
      'Quello che è passato oggi ha inciso la sua riga.',
    ],
  };

  static String aperturaMaestro(Maestro maestro, [int variante = 0]) {
    final attacchi = _attacchi[maestro]!;
    return attacchi[variante.abs() % attacchi.length];
  }

  /// L'invito nella nebbia, all'apertura del rito, nella voce del Maestro.
  static String invitoNebbia(Maestro maestro) =>
      'Hai vissuto un giorno intero. Prima di lasciarlo andare, dirada la '
      'nebbia e guarda il cielo che ti sta sopra.';

  /// Il saluto della notte: guarda al passato e al presente della giornata
  /// conclusa, mai al futuro. Deterministico da Maestro di turno, segno e fase.
  /// Il saluto della notte, per chi e' nato il [nascita].
  ///
  /// **DAL 30 AGOSTO 2026 NON E' PIU' LA STESSA NOTTE PER TUTTI.** Ordine CE
  /// voce 13: il quarto fumetto del tutorial promette che i cinque Doni
  /// nascono "incrociando il Cielo di oggi e la tua Carta natale", e questo
  /// Dono, misurato, guardava soltanto la Luna di stanotte. Adesso entra anche
  /// la LUNA DI NASCITA, e il rapporto fra le due si legge come lo legge
  /// l'astrologia occidentale: dall'angolo che le separa.
  ///
  /// **Chi non ha dato la nascita non perde il Dono**: senza data il saluto e'
  /// esattamente quello di prima.
  static String saluto(DateTime quando, {DateTime? nascita}) {
    final maestro = DailyElements.maestroFor(DailyElement.night, quando);
    final luna = lunaDi(quando);
    final v = voce(luna.sign);
    // **IL SALUTO NON RIPETE IL TITOLO.** Ordine EE voce 05, 23 settembre
    // 2026.
    //
    // **Come ci si e' arrivati, ed e' una cura che ne ha lasciato meta'.**
    // Fino all'ordine CO voce 17 la `posa` viveva solo qui, in fondo al
    // saluto. Quell'ordine l'ha promossa a **titolo** della schermata,
    // perche' *"la gerarchia vuole al primo posto un titolo diretto che sia
    // gia' una risposta"*, e il suo commento dichiara che *"il saluto per
    // intero non cambia di una virgola"*: era vero, ed e' precisamente il
    // difetto. La stessa frase compariva **due volte nella stessa
    // schermata**, in cima grande e in fondo al testo.
    //
    // **Padre: ordine CO voce 17.** Adesso la posa sta dove l'ordine CO l'ha
    // messa, cioe' nel titolo, e il saluto chiude sul riconoscimento.
    final tua = nascita == null ? null : lunaDi(nascita);

    // **CIO' CHE HAI FATTO OGGI LO DICE LA TUA LUNA, NON QUELLA DI
    // STANOTTE.** Ordine EE voce 04, 23 settembre 2026.
    //
    // **Il difetto che il fondatore ha chiamato "generico".** Le due frasi
    // *"Oggi hai pensato in largo, per tutti"* e *"hai tenuto uno sguardo
    // libero"* affermano cosa ha fatto **quella persona**, e le prendevano
    // dal segno della Luna **di stanotte**: cioe' da un dato che stanotte e'
    // lo stesso per chiunque apra l'app. Il rito diceva a tutti gli utenti
    // che quel giorno avevano pensato in largo. Le altre frasi erano vere,
    // la Luna cresce davvero in Acquario e l'angolo con la Luna natale e'
    // davvero quello: **erano vere queste due, e solo queste, a essere false
    // per chi le leggeva**.
    //
    // La cura non aggiunge un dato nuovo: usa quello che c'era gia' e non
    // veniva usato, **la Luna di nascita**, che e' il segno sotto cui quella
    // persona guarda il proprio giorno. L'immagine e la posa restano della
    // Luna di stanotte, perche' quelle parlano della notte e non di lei.
    //
    // **Chi non ha dato la nascita non perde niente**: per lui il saluto
    // resta esattamente quello di prima, e dice cio' che il cielo di
    // stanotte suggerisce.
    final suo = tua == null ? v : voce(tua.sign);

    // **LA NOTTE SCEGLIE QUALE COSA VERA SI DICE. Ordine EH voce 01.**
    //
    // **Il difetto che questa riga cura, ed e' mio.** L'ordine EE voce 04 ha
    // portato `giorno` e `riconoscimento` sulla Luna di nascita, che e' la
    // sorgente giusta: e' il segno sotto cui quella persona guarda il proprio
    // giorno. Ma la Luna di nascita **non cambia mai**, quindi da allora quelle
    // due frasi erano identiche ogni notte, per sempre, per ciascuno. Misurato
    // su quattro notti di fila: identiche tutte e quattro.
    //
    // **Il numero che sceglie deve cambiare ogni notte.** Il segno lunare
    // cambia ogni due giorni e mezzo, la fase ogni tre giorni e mezzo: nessuno
    // dei due basta. Cambia ogni notte il **giorno rituale**, ed e' quello che
    // decide, mescolato con la nascita perche' due persone diverse nella stessa
    // notte non sentano la stessa frase.
    final giornoDelRito = DateTime.utc(quando.year, quando.month, quando.day)
        .difference(DateTime.utc(2000))
        .inDays;
    final semeDellaNotte =
        giornoDelRito + (nascita == null ? 0 : nascita.day * 7);

    final base = '${aperturaMaestro(maestro, giornoDelRito)} '
        '${aperturaLuna(luna)}, ${v.immagine}. '
        'Oggi ${suo.giornoNumero(semeDellaNotte)}. Se guardi indietro, '
        '${suo.riconoscimentoNumero(semeDellaNotte + 1)}.';
    if (tua == null) return '$base Buonanotte.';
    final r = RelazioneLunare.fra(luna.sign, tua.sign);
    return '$base ${r.riga} Buonanotte.';
  }

  /// La relazione fra la Luna di stanotte e quella di nascita, quando la
  /// nascita si sa. Serve alla scheda "da dove nasce", che deve poterla
  /// nominare senza ricomporre il saluto.
  static RelazioneLunare? relazione(DateTime quando, DateTime? nascita) {
    if (nascita == null) return null;
    return RelazioneLunare.fra(lunaDi(quando).sign, lunaDi(nascita).sign);
  }

  /// La riga della provenienza, per la carta: segno e fase reali di stanotte.
  static String provenienza(BirthMoon luna) =>
      'Luna in ${luna.sign.italianName}, ${luna.phase.italianName.toLowerCase()}';

  /// Il testo del tooltip "Da dove nasce questo dono": dichiara il cielo reale,
  /// la Luna di stanotte e il confine onesto sull'allineamento.
  /// La stessa scheda, quando la nascita si sa: dichiara anche l'aspetto fra
  /// la Luna di stanotte e quella natale, che dal 30 agosto 2026 entra nel
  /// saluto. **Una scheda che non nominasse l'incrocio direbbe il falso su
  /// come nasce il Dono**, ed e' proprio la cosa che questa scheda esiste per
  /// non fare.
  static String daDoveNasceCon(BirthMoon luna, RelazioneLunare? relazione) {
    final base = daDoveNasce(luna);
    if (relazione == null) return base;
    return '$base La riga finale nasce dall\'angolo fra questa Luna e '
        'la Luna del tuo giorno di nascita, calcolata anche lei sul '
        'dispositivo: stanotte è un ${relazione.nome}. L\'aspetto fra '
        'un pianeta in transito e lo stesso pianeta natale è la '
        'lettura più antica che l\'astrologia occidentale fa dei '
        'transiti.';
  }

  /// **IL TOOLTIP NON CONFESSA PIU' CIO' CHE NON HA. Ordine CW voce 04**, 7
  /// settembre 2026, stessa famiglia della confessione degli Angeli che ha
  /// aperto l'ordine CS.
  ///
  /// Qui finiva con *"non è allineata alla posizione esatta sopra di te:
  /// servirebbero GPS, bussola ed effemeridi in tempo reale"*. Tre sensori
  /// nominati, e **nessuno dei tre serve al calcolo di questo rito**:
  ///
  /// - il **GPS** no: segno e fase della Luna vengono dalla sola data, e sono
  ///   grandezze geocentriche, le stesse a Milano e a Sydney nello stesso
  ///   istante;
  /// - la **bussola** no: servirebbe a orientare la scena verso il punto del
  ///   cielo dove la Luna sta davvero, che e' una proprieta' della scena e non
  ///   del rito;
  /// - le **effemeridi in tempo reale** no, e quella riga era anche
  ///   fuorviante: le effemeridi ci sono, in `lib/core/astro/effemeridi.dart`,
  ///   girano sul dispositivo senza rete, ed e' da li' che vengono il segno e
  ///   la fase. Scriverlo cosi' lasciava credere che non ci fossero.
  ///
  /// Quindi il tooltip smette di nominarli e dice cosa la scena E': il gesto
  /// di puntare il cielo, non uno strumento di puntamento.
  static String daDoveNasce(BirthMoon luna) =>
      'Il cielo che vedi è il cielo notturno reale di questo momento. Stanotte '
      'la Luna è in ${luna.sign.italianName}, in fase '
      '${luna.phase.italianName.toLowerCase()}, calcolata sul dispositivo dalla '
      'data. La costellazione che unisci è il disegno reale del segno della '
      'Luna; il messaggio nasce da segno e fase, sul sentire del segno lunare '
      '(${BirthMoon.meaningFor(luna.sign)}). Segno e fase si leggono dalla sola '
      'data e sono gli stessi in ogni punto della Terra. Il rito non ha '
      'bisogno di sapere dove sei. La scena si muove col giroscopio per darti '
      'il gesto di puntare il cielo: è un\'evocazione, non un cannocchiale.';

  /// La riga del cielo di stanotte, dalla fase reale, per la scena.
  static String cieloDiStanotte(BirthMoon luna) =>
      NightSky.describeMoon(luna.phase);
}
