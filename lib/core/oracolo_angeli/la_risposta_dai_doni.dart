import '../angels/angel_catalog.dart';
import '../chat/chi_di_dovere.dart';
import '../responsi/la_forma_del_responso.dart';
import 'i_ruoli_e_l_estrazione.dart';

/// **LA FORMA DI UNA DOMANDA ALL'ORACOLO**, ordine GA voce GA.06, 20 ottobre
/// 2026. Che cosa chiede la persona, letto sul telefono senza modello: e' cio'
/// che decide la prima frase del responso, perche' la prima frase risponde
/// (il fondatore, 19 ottobre 2026: *"l'utente deve avere una risposta o una
/// guida, deve sapere cosa fare o non fare"*).
enum FormaDellaDomanda {
  /// "Dimmi qualcosa.": una domanda aperta, senza un tema.
  aperta,

  /// "Andrà tutto bene?", "Che cosa mi aspetta?": il futuro senza un tema.
  futuro,

  /// "Il colloquio andrà bene?": l'esito di una cosa precisa.
  esito,

  /// "Cosa prova Marco per me?": i sentimenti di un'altra persona.
  sentimenti,

  /// "Posso fidarmi del mio compagno?".
  fiducia,

  /// "Lui tornerà da me?".
  ritorno,

  /// "Quando finirà questo periodo?".
  quando,

  /// "Milano o Bari?": una scelta fra due strade.
  scelta,

  /// "Devo accettare l'offerta?": un sì o un no su un'azione.
  decisione,

  /// "Come posso fare pace con mia sorella?": la via.
  come,

  /// Tutto il resto.
  generica,
}

/// **IL LIMITE**, ordine S voce 17 e ordine GA voce GA.06: dove la domanda
/// tocca la salute, la legge o il denaro, il responso lo dice e rimanda a chi
/// e' competente, senza promettere l'esito.
enum LimiteDellaDomanda { salute, legge, denaro }

/// **LA DOMANDA LETTA.** Ordine GA voce GA.06 (difetti D2, D3, D4 e D6 dei
/// lettori ciechi, `docs/collaudo/GA/lettori_ciechi/esiti/
/// esito_tre_domande_oracolo.md`): prima il responso senza modello copiava la
/// carta del Custode e non leggeva la domanda, cosi' lo stesso testo stava
/// sotto domande diverse e nessuna domanda a trabocchetto veniva
/// riconosciuta. Qui la domanda si legge: la forma, il limite, la cosa di cui
/// parla, la persona, l'azione che la persona sta pesando. Tutto e' un dato
/// dichiarato (radici ed elenchi), non un modello: a parita' di domanda la
/// lettura e' la stessa, e una prova la misura.
class LaDomandaDellOracolo {
  const LaDomandaDellOracolo._({
    required this.testo,
    required this.forma,
    this.limite,
    this.oggetto,
    this.attacco,
    this.evento = false,
    this.prova = false,
    this.persona,
    this.clausola,
    this.alternative,
    this.gruppo,
    this.infinito,
    this.seconda,
    this.tuttoBene = false,
  });

  /// La domanda com'e' stata scritta.
  final String testo;
  final FormaDellaDomanda forma;
  final LimiteDellaDomanda? limite;

  /// La cosa di cui parla, detta a te: "il colloquio di giovedì".
  final String? oggetto;

  /// Come comincia la frase dell'esito per quella cosa: "Se e quando arriva
  /// la risposta che aspetti". Nullo: "L'esito di ...".
  final String? attacco;

  /// Vero se la cosa e' un momento da preparare (un pranzo, una cena).
  final bool evento;

  /// Vero se la cosa e' una prova da preparare (un esame, un colloquio, un
  /// concorso): la lettura e' quella di chi si prepara, non di chi aspetta.
  final bool prova;

  /// La persona di cui parla, detta a te: "tuo marito", "Marco", "lui".
  final String? persona;

  /// L'azione che si sta pesando, all'infinito e detta a te: "accettare
  /// l'offerta della nuova azienda".
  final String? clausola;

  /// Le due strade di una scelta, all'infinito.
  final (String, String)? alternative;

  /// Le due cose fra cui si sceglie, se la domanda le nomina insieme: "i due
  /// corsi di laurea".
  final String? gruppo;

  /// La via chiesta da un "come", all'infinito: "fare pace con tua sorella".
  final String? infinito;

  /// La seconda domanda, quando ne sono state scritte due in una.
  final LaDomandaDellOracolo? seconda;

  /// "Andrà tutto bene?".
  final bool tuttoBene;

  bool get doppia => seconda != null;

  // --- le radici -----------------------------------------------------------

  static RegExp _re(String corpo) =>
      RegExp('(?<![\\p{L}])(?:$corpo)', caseSensitive: false, unicode: true);

  // Ordine GA voce GA.06, seconda lettura cieca: comprare casa e aprire
  // un'attivita' sono scelte di denaro anche quando la domanda non lo dice
  // (oracolo-27 e oracolo-30 non dicevano il limite).
  static final RegExp _denaro = _re(r'investi\w*|borsa|risparmi\w*|cripto\w*|'
      r'bitcoin|mutuo|prestit\w*|debit\w*|soldi|denaro|finanz\w*|'
      r'patrimoni\w*|azioni in|'
      r'compr\w* (?:una |la |)casa|acquist\w* (?:una |la |)casa|'
      r'aprire (?:la mia |una |un |)(?:attività|negozio|impresa|azienda)');
  static final RegExp _legge = _re(r'avvocat\w*|tribunal\w*|giudice|'
      r'denunc\w*|querel\w*|sentenz\w*|processo|vinc\w* la causa|'
      r'perd\w* la causa|causa (?:contro|legale|civile|penale|di lavoro)|'
      r'separazion\w*|divorzi\w*|affidament\w*|legal\w*|ricorso');
  static final RegExp _salute = _re(r'operazion\w*|intervent\w* chirurg\w*|'
      r'chirurg\w*|malatt\w*|medic\w*|ospedal\w*|diagnos\w*|terapi\w*|'
      r'analisi del sangue|esami del sangue|visita medica|tumor\w*|cancro|'
      r'febbre|farmac\w*|guari\w*|salute|gravidan\w*|incint\w*|sintom\w*|'
      r'ginocchi\w*|schiena');

  static final RegExp _aperta = RegExp(
      r'^(dimmi qualcosa|dimmi|parlami|che cosa mi dici|cosa mi dici|'
      r'dammi un consiglio|un consiglio|consigliami)\W*$',
      caseSensitive: false);
  static final RegExp _tuttoBene = _re(r'andrà tutto bene|va tutto bene|'
      r'tutto andrà bene|andrà bene tutto');
  static final RegExp _futuro = _re(r'mi aspetta|mi riserva|il mio futuro|'
      r'succederà|accadrà');
  static final RegExp _ritorno = _re(r'tornerà|ritornerà|torni da me|'
      r'torna da me|tornare da me|ritorno da me');
  static final RegExp _sentimenti = _re(r'cosa prova|che cosa prova|'
      r'cosa sente per me|cosa pensa di me|pensa a me|mi pensa|mi ama|'
      r'mi vuole bene|mi desidera|è innamorat\w* di me|prova qualcosa|'
      r'gli piaccio|le piaccio|ci tiene a me');
  static final RegExp _fiducia =
      _re(r'fidarmi|fiducia (?:in|di|nel|nella)|è sincer\w*|mi mente|'
          r'mi tradisce|mi nasconde');
  static final RegExp _decisione = RegExp(
      r'^(?:devo|dovrei|posso|potrei|faccio bene a|è giusto|ha senso|'
      r'(?:mi |ti )?conviene|vale la pena(?: di)?|è il momento giusto per|'
      r'è il momento di|è il momento per|è ora di|sarebbe meglio|'
      r'è meglio|meglio)\s+(.+)$',
      caseSensitive: false);
  static final RegExp _futuroVerbo = RegExp(
      r'[\p{L}]{2,}(?:rà|rò|ranno|rai)(?![\p{L}])|'
      r'(?<![\p{L}])può (?:durare|funzionare|andare)',
      caseSensitive: false,
      unicode: true);

  /// Le persone che una domanda nomina col possessivo.
  static const Set<String> _persone = {
    'marito',
    'moglie',
    'compagno',
    'compagna',
    'fidanzato',
    'fidanzata',
    'ragazzo',
    'ragazza',
    'ex',
    'partner',
    'figlio',
    'figlia',
    'figli',
    'madre',
    'padre',
    'mamma',
    'papà',
    'fratello',
    'sorella',
    'genitori',
    'nonno',
    'nonna',
    'nonni',
    'capo',
    'collega',
    'colleghi',
    'amico',
    'amica',
    'amici',
    'socio',
    'socia',
    'suocera',
    'suocero',
    'famiglia',
    'cugino',
    'cugina',
    'zio',
    'zia',
    'datore',
  };

  /// L'articolo dentro ogni preposizione articolata che puo' stare davanti a
  /// un possessivo ("del mio compagno").
  static const Map<String, String> _articoloDi = {
    'il': 'il',
    'lo': 'lo',
    'la': 'la',
    'i': 'i',
    'gli': 'gli',
    'le': 'le',
    'del': 'il',
    'dello': 'lo',
    'della': 'la',
    'dei': 'i',
    'degli': 'gli',
    'delle': 'le',
    'al': 'il',
    'allo': 'lo',
    'alla': 'la',
    'ai': 'i',
    'agli': 'gli',
    'alle': 'le',
    'dal': 'il',
    'dallo': 'lo',
    'dalla': 'la',
    'dai': 'i',
    'dagli': 'gli',
    'dalle': 'le',
    'nel': 'il',
    'nella': 'la',
    'nei': 'i',
    'sul': 'il',
    'sulla': 'la',
    'sui': 'i',
    'col': 'il',
    'coi': 'i',
  };

  /// Le parole con la maiuscola che non sono nomi di persona.
  static const Set<String> _nonNomi = {
    'Natale',
    'Pasqua',
    'Capodanno',
    'Dio',
    'Io',
    'Lui',
    'Lei',
  };

  // --- le cose di cui parla una domanda -------------------------------------

  static final List<
      ({
        RegExp re,
        String Function(String m) frase,
        String Function(String o)? attacco,
        bool evento,
        bool relazione,
        bool prova,
      })> _cose = [
    _cosa(r"esame di stato", (m) => "l'esame di stato", prova: true),
    _cosa(r'esame|esami(?! del sangue)', (m) => "l'esame", prova: true),
    _cosa(r'colloquio(?: di [\p{L}]+)?', (m) => 'il $m', prova: true),
    _cosa(r'concorso', (m) => 'il concorso', prova: true),
    _cosa(
        r"operazione(?: (?:al|alla|allo|ai|agli|alle) [\p{L}]+|"
        r" all'[\p{L}]+)?",
        (m) => "l'$m"),
    _cosa(r'intervento(?: (?:al|alla|allo|ai|agli|alle) [\p{L}]+)?',
        (m) => "l'$m"),
    _cosa(
        r"(?<!(?:^|\s)a )causa(?: contro (?:(?:il|la|lo|i|gli|le) )?"
        r"(?:(?:mio|mia|miei|mie) )?(?:ex )?[\p{L}]+)?",
        (m) => 'la $m'),
    _cosa(r'risparmi', (m) => 'i tuoi risparmi'),
    _cosa(r'borsa|investiment\w*', (m) => 'il tuo denaro'),
    _cosa(r'promozione', (m) => 'la promozione'),
    _cosa(r'progetto', (m) => 'il tuo progetto'),
    _cosa(
        r"offerta(?: (?:della|del|dello) (?:[\p{L}]+ )?[\p{L}]+|"
        r" dell'[\p{L}]+)?",
        (m) => "l'$m"),
    _cosa(r'attività', (m) => 'la tua attività'),
    _cosa(r'relazione', (m) => 'la tua relazione',
        attacco: (o) => 'Se $o può durare'),
    _cosa(r'periodo di stallo|stallo', (m) => 'questo periodo di stallo'),
    _cosa(r'periodo difficile', (m) => 'questo periodo difficile'),
    _cosa(r'cambiamento', (m) => 'il cambiamento'),
    _cosa(r'risposta', (m) => 'la risposta che aspetti',
        attacco: (o) => 'Se e quando arriva $o'),
    _cosa(r'incontr\w*|qualcuno di importante', (m) => 'un incontro importante',
        attacco: (o) => 'Se arriva $o'),
    _cosa(r'pranzo di natale', (m) => 'il pranzo di Natale', evento: true),
    _cosa(r'pranzo', (m) => 'il pranzo', evento: true),
    _cosa(r'cena', (m) => 'la cena', evento: true),
    _cosa(r'festa', (m) => 'la festa', evento: true),
    _cosa(r'matrimonio', (m) => 'il matrimonio', evento: true),
    _cosa(r'conflitto', (m) => 'il conflitto', relazione: true),
    _cosa(r'intesa', (m) => "l'intesa", relazione: true),
    _cosa(r'pace', (m) => 'la pace', relazione: true),
    _cosa(r'amicizia', (m) => "l'amicizia", relazione: true),
    _cosa(r'rapporto', (m) => 'il rapporto', relazione: true),
    _cosa(r'laurea|università|corsi', (m) => 'la scelta degli studi'),
    _cosa(r'lavoro', (m) => 'il lavoro'),
    _cosa(r'studi\w*', (m) => 'lo studio'),
    _cosa(r'casa', (m) => 'la casa'),
    _cosa(r'trasferi\w*|trasloc\w*', (m) => 'il trasferimento'),
    _cosa(r'viaggio', (m) => 'il viaggio'),
    _cosa(r'distanza', (m) => 'la distanza'),
  ];

  static ({
    RegExp re,
    String Function(String m) frase,
    String Function(String o)? attacco,
    bool evento,
    bool relazione,
    bool prova,
  }) _cosa(String re, String Function(String m) frase,
          {String Function(String o)? attacco,
          bool evento = false,
          bool relazione = false,
          bool prova = false}) =>
      (
        re: _re(re),
        frase: frase,
        attacco: attacco,
        evento: evento,
        relazione: relazione,
        prova: prova
      );

  // --- dalla prima persona a te ----------------------------------------------

  static const Map<String, String> _possessivi = {
    'mio': 'tuo',
    'mia': 'tua',
    'miei': 'tuoi',
    'mie': 'tue',
    'me': 'te',
    'mi': 'ti',
  };

  /// Le parole in "-rmi" che non sono un infinito col "mi": "i miei
  /// risparmi" non diventa "i tuoi risparti".
  static const Set<String> _nonVerbiInRmi = {
    'risparmi',
    'allarmi',
    'armi',
    'germi',
    'vermi',
    'fermi',
    'inermi',
    'enormi',
    'deformi',
    'conformi',
    'uniformi',
    'termi',
    'carmi',
  };

  /// **A TE**: i possessivi e i pronomi della prima persona passano alla
  /// seconda ("mia sorella" diventa "tua sorella", "trasferirmi" diventa
  /// "trasferirti").
  static String aTe(String s) {
    final parole = s.split(' ');
    for (var i = 0; i < parole.length; i++) {
      final p = parole[i];
      final basso = p.toLowerCase();
      if (_possessivi.containsKey(basso)) {
        parole[i] = _possessivi[basso]!;
      } else if (RegExp(r'^[\p{L}]+rmi$', unicode: true).hasMatch(basso) &&
          !_nonVerbiInRmi.contains(basso)) {
        parole[i] = '${p.substring(0, p.length - 3)}rti';
      } else if (RegExp(r'^[\p{L}]+rmene$', unicode: true).hasMatch(basso)) {
        parole[i] = '${p.substring(0, p.length - 5)}rtene';
      }
    }
    return parole.join(' ');
  }

  static final RegExp _infinito = RegExp(
      r'^[\p{L}]+(?:are|ere|ire|rre)$|'
      r'^[\p{L}]+(?:ar|er|ir|r)(?:mi|ti|ci|si|vi|lo|la|li|le|ne|gli|tene|'
      r'mene)$',
      caseSensitive: false,
      unicode: true);

  static const Map<String, String> _irregolari = {
    'faccio': 'fare',
    'vado': 'andare',
    'dico': 'dire',
    'scelgo': 'scegliere',
    'tengo': 'tenere',
    'vengo': 'venire',
    'esco': 'uscire',
    'so': 'sapere',
    'sto': 'stare',
    'metto': 'mettere',
    'prendo': 'prendere',
    'chiedo': 'chiedere',
    'rispondo': 'rispondere',
    'leggo': 'leggere',
    'vivo': 'vivere',
    'scrivo': 'scrivere',
    'credo': 'credere',
    'perdo': 'perdere',
    'risolvo': 'risolvere',
    'riesco': 'riuscire',
    'convinco': 'convincere',
    'smetto': 'smettere',
    'ricevo': 'ricevere',
    'tolgo': 'togliere',
    'rimango': 'rimanere',
    'affronto': 'affrontare',
    'aiuto': 'aiutare',
    'compro': 'comprare',
    'aspetto': 'aspettare',
    'resto': 'restare',
  };

  /// Le forme della prima persona che non si sanno girare a te: se restano
  /// nella frase, la frase non si usa.
  static const Set<String> _primaPersona = {
    'amo',
    'ho',
    'sono',
    'faccio',
    'vado',
    'voglio',
    'posso',
    'devo',
    'so',
    'sto',
    'sento',
    'penso',
    'credo',
    'vivo',
    'conosco',
    'vedo',
    'provo',
    'io',
  };

  /// I pronomi atoni che stanno davanti al verbo ("lo aiuto", "mi
  /// comporto"). Sono chiavi di confronto e non testo a video: si scrivono
  /// come classi di lettere, cosi' le guardie degli accenti non li leggono
  /// come le parole "lì" e "né".
  static final RegExp _clitico =
      RegExp(r'^(?:l[oaie]|gli|n[e]|[mtcs]i)$', caseSensitive: false);

  /// I pronomi oggetto che la persona nominata puo' sostituire ("lo aiuto"
  /// diventa "aiutare tuo figlio").
  static final RegExp _cliticoOggetto =
      RegExp(r'^l[oaie]$', caseSensitive: false);

  static String? _verbo(String parola) {
    final p = parola.toLowerCase();
    if (_irregolari.containsKey(p)) return _irregolari[p];
    if (p.endsWith('isco') && p.length > 5) {
      return '${p.substring(0, p.length - 4)}ire';
    }
    if (p.endsWith('o') && p.length > 3) {
      return '${p.substring(0, p.length - 1)}are';
    }
    return null;
  }

  /// **ALL'INFINITO E A TE**: "lo aiuto" diventa "aiutarlo" (o "aiutare tuo
  /// figlio" se la domanda nomina la persona), "gestisco il conflitto con il
  /// mio capo" diventa "gestire il conflitto con il tuo capo". Nullo se la
  /// frase non si sa girare senza sbagliare.
  static String? allInfinito(String frase, {String? persona}) {
    var parole = frase.trim().split(RegExp(r'\s+'));
    const modali = {
      'posso',
      'devo',
      'dovrei',
      'potrei',
      'voglio',
      'vorrei',
      'riesco',
      'faccio'
    };
    if (parole.length > 1 && modali.contains(parole.first.toLowerCase())) {
      final dopo = parole.sublist(1);
      if (dopo.isNotEmpty && dopo.first.toLowerCase() == 'a') {
        dopo.removeAt(0);
      }
      if (dopo.isNotEmpty) parole = dopo;
    }
    if (parole.isEmpty) return null;
    String testa;
    var resto = parole.sublist(1);
    final primo = parole.first.toLowerCase();
    if (_clitico.hasMatch(primo) && parole.length > 1) {
      final v = _infinito.hasMatch(parole[1]) ? parole[1] : _verbo(parole[1]);
      if (v == null) return null;
      resto = parole.sublist(2);
      if (persona != null && _cliticoOggetto.hasMatch(primo)) {
        testa = '$v $persona';
      } else {
        final clitico = _possessivi[primo] ?? primo;
        testa = '${v.substring(0, v.length - 1)}$clitico';
      }
    } else if (_infinito.hasMatch(primo)) {
      testa = parole.first;
    } else {
      final v = _verbo(primo);
      if (v == null) return null;
      testa = v;
    }
    if (resto.any((p) => _primaPersona.contains(p.toLowerCase()))) {
      return null;
    }
    return aTe([testa, ...resto].join(' ')).trim();
  }

  // --- la lettura ------------------------------------------------------------

  static String _pulita(String d) => d
      .replaceAll('’', "'")
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim()
      .replaceAll(RegExp(r'[?!.\s]+$'), '');

  /// **LE DUE DOMANDE IN UNA**: due punti di domanda, ", e se", o una "e"
  /// seguita da un verbo coniugato ("Lui mi ama ancora e troverò lavoro?").
  static (String, String)? _dueDomande(String d) {
    final q = d.trim();
    final punto = q.indexOf('?');
    if (punto > 0 &&
        punto < q.length - 1 &&
        q
            .substring(punto + 1)
            .trim()
            .replaceAll(RegExp(r'[?!.\s]'), '')
            .isNotEmpty) {
      return (q.substring(0, punto), q.substring(punto + 1));
    }
    final basso = q.toLowerCase();
    final eSe = RegExp(r',?\s+e\s+(?=se\s)').firstMatch(basso);
    if (eSe != null && eSe.start > 3) {
      return (q.substring(0, eSe.start), q.substring(eSe.end));
    }
    for (final m in RegExp(r',? e ').allMatches(basso)) {
      final dopo = basso.substring(m.end).trim().split(' ');
      if (m.start > 3 &&
          dopo.isNotEmpty &&
          RegExp(r'[\p{L}]{3,}[òà]$', unicode: true).hasMatch(dopo.first)) {
        return (q.substring(0, m.start), q.substring(m.end));
      }
    }
    return null;
  }

  static LimiteDellaDomanda? limiteDi(String d) {
    if (_denaro.hasMatch(d)) return LimiteDellaDomanda.denaro;
    if (_legge.hasMatch(d)) return LimiteDellaDomanda.legge;
    if (_salute.hasMatch(d)) return LimiteDellaDomanda.salute;
    return switch (ChiDiDovere.temaDi(d)?.chi) {
      'avvocato' => LimiteDellaDomanda.legge,
      'medico' => LimiteDellaDomanda.salute,
      'consulente' => LimiteDellaDomanda.denaro,
      _ => null,
    };
  }

  static String? _persona(String originale) {
    final d = originale;
    final famiglia = RegExp(
            r'(la famiglia|i genitori|la madre|il padre|la sorella|'
            r'il fratello) di (lui|lei)',
            caseSensitive: false)
        .firstMatch(d);
    if (famiglia != null) return famiglia[0]!.toLowerCase();
    for (final m in RegExp(
            "(?<![\\p{L}])(?:(${_articoloDi.keys.join('|')}) )?"
            "(mio|mia|miei|mie) ((?:ex )?[\\p{L}]+)",
            caseSensitive: false,
            unicode: true)
        .allMatches(d)) {
      final nome = m[3]!.toLowerCase();
      final ultimo = nome.split(' ').last;
      if (_persone.contains(ultimo) || nome.startsWith('ex')) {
        // "del mio compagno" diventa "il tuo compagno": la preposizione la
        // rimette chi compone la frase.
        final articolo =
            m[1] == null ? '' : '${_articoloDi[m[1]!.toLowerCase()]} ';
        return '$articolo${_possessivi[m[2]!.toLowerCase()]} $nome';
      }
    }
    final nomi = RegExp(r'(?<=\s)([A-ZÀ-Ý][a-zà-ÿ]{2,})', unicode: true);
    for (final m in nomi.allMatches(d)) {
      final prima = d.substring(0, m.start).trimRight();
      // Dopo una preposizione di luogo la maiuscola e' una citta' ("a
      // Milano", "di Bari"), non una persona.
      if (RegExp(r'\s(?:a|d[ai]|in)$').hasMatch(prima)) continue;
      if (_nonNomi.contains(m[1])) continue;
      return m[1];
    }
    final pronome = RegExp(r'(?<![\p{L}])(lui|lei)(?![\p{L}])',
            caseSensitive: false, unicode: true)
        .firstMatch(d);
    return pronome?[1]?.toLowerCase();
  }

  static ({String frase, String? attacco, bool evento, bool prova})? _oggetto(
      String d, String? persona) {
    ({
      int pos,
      String frase,
      String? attacco,
      bool evento,
      bool relazione,
      bool prova
    })? migliore;
    for (final c in _cose) {
      final m = c.re.firstMatch(d);
      if (m == null) continue;
      if (migliore != null && m.start >= migliore.pos) continue;
      final testo = d.substring(m.start, m.end);
      final frase =
          aTe(c.frase(testo.toLowerCase())).replaceAll('natale', 'Natale');
      migliore = (
        pos: m.start,
        frase: frase,
        attacco: c.attacco?.call(frase),
        evento: c.evento,
        relazione: c.relazione,
        prova: c.prova,
      );
    }
    if (migliore == null) return null;
    var frase = migliore.frase;
    if (migliore.relazione &&
        persona != null &&
        d.toLowerCase().contains(' con ') &&
        !frase.contains(' con ')) {
      frase = '$frase con $persona';
    }
    return (
      frase: frase,
      attacco: migliore.attacco,
      evento: migliore.evento,
      prova: migliore.prova
    );
  }

  static String? _clausola(String d) {
    final m = _decisione.firstMatch(d);
    if (m == null) return null;
    var c = m[1]!.trim();
    final che = c.toLowerCase().indexOf(' che ');
    if (che > 0) {
      final prima = c.substring(0, che);
      if (RegExp(r'^(dir\w*|confess\w*|ammett\w*|rivel\w*)$',
              caseSensitive: false)
          .hasMatch(prima)) {
        c = '$prima come stanno le cose';
      } else {
        return null;
      }
    }
    return allInfinito(c);
  }

  static (String, String)? _alternative(String d) {
    final i = d.toLowerCase().indexOf(' o ');
    if (i < 0) return null;
    var sinistra = d.substring(0, i);
    final destra = d.substring(i + 3).trim();
    if (const {'no', 'meno', 'non', 'forse'}.contains(destra.toLowerCase())) {
      return null;
    }
    sinistra = sinistra.replaceFirst(
        RegExp(r'^(?:devo|dovrei|è meglio|meglio|posso|potrei)\s+',
            caseSensitive: false),
        '');
    final a = allInfinito(sinistra);
    final b = allInfinito(destra);
    if (a == null || b == null) return null;
    return (a, b);
  }

  /// **LEGGE UNA DOMANDA.**
  static LaDomandaDellOracolo leggi(String domanda) {
    final due = _dueDomande(domanda);
    if (due != null) {
      final prima = _leggiUna(due.$1);
      final seconda = _leggiUna(due.$2);
      return LaDomandaDellOracolo._(
        testo: domanda,
        forma: prima.forma,
        limite: prima.limite ?? seconda.limite,
        oggetto: prima.oggetto,
        attacco: prima.attacco,
        evento: prima.evento,
        prova: prima.prova,
        persona: prima.persona,
        clausola: prima.clausola,
        alternative: prima.alternative,
        gruppo: prima.gruppo,
        infinito: prima.infinito,
        tuttoBene: prima.tuttoBene,
        seconda: seconda,
      );
    }
    return _leggiUna(domanda);
  }

  static LaDomandaDellOracolo _leggiUna(String domanda) {
    final d = _pulita(domanda);
    final basso = d.toLowerCase();
    final limite = limiteDi(d);
    final persona = _persona(d);
    final cosa = _oggetto(d, persona);
    FormaDellaDomanda forma;
    String? clausola;
    (String, String)? alternative;
    String? gruppo;
    String? infinito;
    var tuttoBene = false;
    if (_aperta.hasMatch(d) ||
        d.split(' ').where((p) => p.isNotEmpty).length < 2) {
      forma = FormaDellaDomanda.aperta;
    } else if (_tuttoBene.hasMatch(d)) {
      forma = FormaDellaDomanda.futuro;
      tuttoBene = true;
    } else if (_futuro.hasMatch(d) && cosa == null) {
      forma = FormaDellaDomanda.futuro;
    } else if (_ritorno.hasMatch(d)) {
      forma = FormaDellaDomanda.ritorno;
    } else if (_sentimenti.hasMatch(d)) {
      forma = FormaDellaDomanda.sentimenti;
    } else if (_fiducia.hasMatch(d)) {
      forma = FormaDellaDomanda.fiducia;
    } else if (basso.startsWith('quando ')) {
      forma = FormaDellaDomanda.quando;
    } else if ((alternative = _alternative(d)) != null ||
        RegExp(r'(?:tra|fra) (?:i|le|gli) due ', caseSensitive: false)
            .hasMatch(d)) {
      forma = FormaDellaDomanda.scelta;
      final g = RegExp(
              r'(?:tra|fra) ((?:i|le|gli) due [\p{L}]+(?: di [\p{L}]+)?)',
              caseSensitive: false,
              unicode: true)
          .firstMatch(d);
      gruppo = g?[1]?.toLowerCase();
    } else if (_decisione.hasMatch(d)) {
      forma = FormaDellaDomanda.decisione;
      clausola = _clausola(d);
    } else if (_futuroVerbo.hasMatch(d)) {
      forma = FormaDellaDomanda.esito;
    } else if (basso.startsWith('come ') || basso.contains(', come ')) {
      forma = FormaDellaDomanda.come;
      final i = basso.startsWith('come ') ? 5 : basso.indexOf(', come ') + 7;
      infinito = allInfinito(d.substring(i), persona: persona);
    } else {
      forma = FormaDellaDomanda.generica;
    }
    var oggetto = cosa?.frase;
    if (forma == FormaDellaDomanda.quando &&
        oggetto != null &&
        RegExp(r'finir|finisc|termin', caseSensitive: false).hasMatch(d)) {
      oggetto = 'la fine ${LaRispostaDaiDoni.con('di', oggetto)}';
    }
    return LaDomandaDellOracolo._(
      testo: domanda,
      forma: forma,
      limite: limite,
      oggetto: oggetto,
      attacco: forma == FormaDellaDomanda.quando ? null : cosa?.attacco,
      evento: cosa?.evento ?? false,
      prova: cosa?.prova ?? false,
      persona: persona,
      clausola: clausola,
      alternative: alternative,
      gruppo: gruppo,
      infinito: infinito,
      tuttoBene: tuttoBene,
    );
  }
}

/// **LA FAMIGLIA DI UNA DOMANDA**, ordine GA voce GA.06, seconda cura: il
/// gruppo di domande per cui ogni angelo ha la sua lettura scritta nel corpus
/// (`docs/corpus/oracolo_angeli/letture.md`). La frase del Custode ha otto
/// famiglie; le frasi del Cuore e dell'Intelletto e il gesto ne hanno cinque.
enum FamigliaDellaDomanda {
  aperta('aperta', 'orienta'),
  futuro('futuro', 'orienta'),
  esito('esito', 'attesa'),
  altrui('altrui', 'legami'),
  decisione('decisione', 'scelta'),
  scelta('scelta', 'scelta'),
  come('come', 'legami'),
  limite('limite', 'limite');

  const FamigliaDellaDomanda(this.custode, this.gruppo);

  /// Il campo della frase del Custode.
  final String custode;

  /// Il gruppo delle frasi del Cuore, dell'Intelletto e del gesto.
  final String gruppo;

  static FamigliaDellaDomanda di(LaDomandaDellOracolo q) {
    if (q.limite != null) return FamigliaDellaDomanda.limite;
    return switch (q.forma) {
      FormaDellaDomanda.aperta ||
      FormaDellaDomanda.generica =>
        FamigliaDellaDomanda.aperta,
      FormaDellaDomanda.futuro => FamigliaDellaDomanda.futuro,
      // Una prova da preparare legge le frasi di chi punta su cio' che
      // dipende da se', non quelle di chi aspetta un esito deciso da altri.
      FormaDellaDomanda.esito when q.prova => FamigliaDellaDomanda.futuro,
      FormaDellaDomanda.esito ||
      FormaDellaDomanda.quando =>
        FamigliaDellaDomanda.esito,
      FormaDellaDomanda.sentimenti ||
      FormaDellaDomanda.fiducia ||
      FormaDellaDomanda.ritorno =>
        FamigliaDellaDomanda.altrui,
      FormaDellaDomanda.decisione => FamigliaDellaDomanda.decisione,
      FormaDellaDomanda.scelta => FamigliaDellaDomanda.scelta,
      FormaDellaDomanda.come => FamigliaDellaDomanda.come,
    };
  }
}

/// **LA RISPOSTA DALLE LETTURE.** Ordine GA voce GA.06: il responso
/// principale senza modello, cioe' l'assaggio del Viandante e il ripiego
/// quando il modello non risponde.
///
/// **LAPIDE, prima cura (20 ottobre 2026).** Il responso era la carta del
/// Custode copiata (ordine GA voce GA.05): il lettore cieco l'ha trovata
/// uguale alla carta singola 40 volte su 40. La prima cura lo componeva da
/// frammenti: il dono e la via dell'angelo (`doni.md`) incollati dentro frasi
/// fisse. Il secondo lettore cieco (21 ottobre 2026) ha sentito le cuciture:
/// la prima frase rispondeva 30 volte su 40 ma la coerenza era 14 su 40 ("per
/// l'esame di stato conta ritirarti un momento prima di rispondere", "È il
/// gesto che X lega a" in 28 responsi, Cuore e Intelletto come etichette).
///
/// **ADESSO, seconda cura.** Le frasi degli angeli sono SCRITTE: per ogni
/// angelo e per ogni famiglia di domanda ([FamigliaDellaDomanda]) il corpus
/// porta la frase del Custode, quella del Cuore, quella dell'Intelletto e il
/// gesto, scritti apposta per applicare quel dono a quel genere di domanda
/// (`letture.md`, sotto lo strumento `tool/il_corpus_dell_oracolo.py`). Qui
/// si scrive soltanto cio' che dipende dalla domanda: l'apertura che risponde
/// alla sua forma e nomina la cosa o la persona, il passo concreto del "Cosa
/// fare", i limiti su salute, legge e denaro. Ogni paragrafo si sceglie fra
/// alternative di frasi intere finche' sta fra 40 e 50 parole: nessun testo
/// si tronca (GA.07).
abstract final class LaRispostaDaiDoni {
  /// Il dono di un angelo dal corpus (`doni.md`). Senza la cella, il dominio
  /// del coro.
  static String dono(Map<String, List<String>> corpus, Angel a) {
    final v = corpus['doni|${_nn(a)}|dono'];
    return (v == null || v.isEmpty) ? a.choir.domain : v.first;
  }

  /// La via di un angelo dal corpus. Senza la cella, una via neutra.
  static String via(Map<String, List<String>> corpus, Angel a) {
    final v = corpus['doni|${_nn(a)}|via'];
    return (v == null || v.isEmpty)
        ? 'restare fedele a ciò che conta per te'
        : v.first;
  }

  static String _nn(Angel a) => a.number.toString().padLeft(2, '0');

  /// **UNA LETTURA DEL CORPUS**: il campo [campo] dell'angelo [a]. Nulla se
  /// la cella manca (un corpus di prova senza le letture).
  static String? lettura(
      Map<String, List<String>> corpus, Angel a, String campo) {
    final v = corpus['letture|${_nn(a)}|$campo'];
    return (v == null || v.isEmpty || v.first.trim().isEmpty) ? null : v.first;
  }

  // --- le preposizioni con l'articolo ------------------------------------------

  static const Map<String, Map<String, String>> _articolate = {
    'di': {
      'il': 'del',
      'lo': 'dello',
      'la': 'della',
      'i': 'dei',
      'gli': 'degli',
      'le': 'delle',
      "l'": "dell'"
    },
    'a': {
      'il': 'al',
      'lo': 'allo',
      'la': 'alla',
      'i': 'ai',
      'gli': 'agli',
      'le': 'alle',
      "l'": "all'"
    },
    'su': {
      'il': 'sul',
      'lo': 'sullo',
      'la': 'sulla',
      'i': 'sui',
      'gli': 'sugli',
      'le': 'sulle',
      "l'": "sull'"
    },
  };

  /// "di" + "il colloquio" = "del colloquio"; "a" + "tuo marito" = "a tuo
  /// marito".
  static String con(String preposizione, String gruppo) {
    final tabella = _articolate[preposizione]!;
    if (gruppo.startsWith("l'")) {
      return '${tabella["l'"]}${gruppo.substring(2)}';
    }
    final spazio = gruppo.indexOf(' ');
    if (spazio > 0) {
      final articolo = gruppo.substring(0, spazio);
      if (tabella.containsKey(articolo)) {
        return '${tabella[articolo]} ${gruppo.substring(spazio + 1)}';
      }
    }
    return '$preposizione $gruppo';
  }

  static String _maiuscola(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  /// **LA MISURA SENZA TAGLI**: fra le alternative di ogni posto (frasi
  /// intere, anche vuote), la prima combinazione che sta fra 40 e 50 parole.
  /// Se nessuna ci sta, la piu' vicina: la prova
  /// `l_oracolo_risponde_dai_doni_test.dart` cade se succede.
  static String? _seEntra(List<List<String>> posti) {
    final t = aMisura(posti);
    final n = LaFormaDelResponso.parole(t);
    return n >= LaFormaDelResponso.minimo && n <= LaFormaDelResponso.massimo
        ? t
        : null;
  }

  static String aMisura(List<List<String>> posti) {
    String? migliore;
    var distanza = 1 << 30;
    String? trovata;
    void prova(int i, List<String> scelte) {
      if (trovata != null) return;
      if (i == posti.length) {
        final testo = scelte.where((s) => s.isNotEmpty).join(' ');
        final n = LaFormaDelResponso.parole(testo);
        if (n >= LaFormaDelResponso.minimo && n <= LaFormaDelResponso.massimo) {
          trovata = testo;
          return;
        }
        final d = n < LaFormaDelResponso.minimo
            ? LaFormaDelResponso.minimo - n
            : n - LaFormaDelResponso.massimo;
        if (d < distanza) {
          distanza = d;
          migliore = testo;
        }
        return;
      }
      for (final s in posti[i]) {
        prova(i + 1, [...scelte, s]);
        if (trovata != null) return;
      }
    }

    prova(0, const []);
    return trovata ?? migliore!;
  }

  /// Una scelta stabile fra varianti: la stessa domanda con lo stesso angelo
  /// da' sempre la stessa, domande o angeli diversi ne pescano di diverse.
  /// Come [_ruota], ma la frase vuota resta in testa: la misura prova prima
  /// senza frase in piu', poi le frasi in un ordine che cambia con la
  /// domanda e l'angelo, cosi' la stessa chiusa non torna in ogni responso
  /// della famiglia (il secondo lettore cieco ne ha contate 18 su 40).
  static List<String> _ruotaDopoIlVuoto(
      List<String> varianti, String domanda, int n) {
    final vuota = varianti.contains('');
    final piene = [
      for (final v in varianti)
        if (v.isNotEmpty) v
    ];
    return [if (vuota) '', ..._ruota(piene, domanda, n)];
  }

  static List<String> _ruota(List<String> varianti, String domanda, int n) {
    if (varianti.length < 2) return varianti;
    var h = n;
    for (final c in domanda.codeUnits) {
      h = (h * 31 + c) & 0x3fffffff;
    }
    final k = h % varianti.length;
    return [...varianti.sublist(k), ...varianti.sublist(0, k)];
  }

  /// **IL RESPONSO**, nella forma breve di GA.03. [soloIlCustode] e' vero
  /// nell'assaggio del Viandante: il Cuore e l'Intelletto restano col
  /// lucchetto, e il responso non li nomina.
  static ResponsoInterpretato componi({
    required String domanda,
    required List<CartaDellOracolo> carte,
    required Map<String, List<String>> corpus,
    bool soloIlCustode = false,
  }) {
    final q = LaDomandaDellOracolo.leggi(domanda);
    final f = FamigliaDellaDomanda.di(q);
    final custode = carte.firstWhere((c) => c.ruolo == RuoloDellAngelo.custode,
        orElse: () => carte.first);
    final cuore = carte.where((c) => c.ruolo == RuoloDellAngelo.cuore);
    final intelletto =
        carte.where((c) => c.ruolo == RuoloDellAngelo.intelletto);
    final a = custode.angelo;
    final c = a.name;
    final fraseDelCustode =
        lettura(corpus, a, f.custode) ?? '$c ti chiede di ${via(corpus, a)}.';

    // La risposta: l'apertura che risponde alla forma, la frase scritta del
    // Custode, la frase in piu' (il no, il limite, la seconda domanda), poi
    // il Cuore e l'Intelletto con le loro frasi scritte per la famiglia.
    final aperture = _aperture(q);
    final List<String> ruoli;
    var incorniciati = const <String>[];
    if (soloIlCustode || cuore.isEmpty) {
      ruoli = _ruoliDelSoloCustode(corpus, a, f);
    } else {
      final h = cuore.first.angelo;
      final fraseDelCuore = lettura(corpus, h, 'cuore_${f.gruppo}') ??
          '${h.name} ti porta ${dono(corpus, h)}.';
      final i = intelletto.isEmpty ? null : intelletto.first;
      // La frase dei ruoli si apre con la situazione della domanda, cosi' il
      // dono del Cuore e' detto su quella ("Mentre aspetti, nel Cuore, ...").
      // Senza cornice resta come alternativa, per la misura.
      final cornice = _cornice(q, fraseDelCustode, fraseDelCuore);
      final attacchi = [
        if (cornice != null) '$cornice, nel Cuore,',
        'Nel Cuore,',
      ];
      if (i == null || i.coperta) {
        ruoli = [
          for (final at in attacchi) ...[
            '$at $fraseDelCuore La carta dell\'Intelletto resta coperta '
                'finché non aggiungi la tua ora di nascita.',
            '$at $fraseDelCuore L\'Intelletto resta coperto senza la tua '
                'ora di nascita.',
          ],
        ];
      } else {
        final fraseDellIntelletto =
            lettura(corpus, i.angelo, 'intelletto_${f.gruppo}') ??
                '${i.angelo.name} ti porta ${dono(corpus, i.angelo)}.';
        ruoli = [
          for (final at in attacchi)
            '$at $fraseDelCuore Nell\'Intelletto, $fraseDellIntelletto',
        ];
      }
      if (cornice != null) {
        incorniciati = [
          for (final r in ruoli)
            if (r.startsWith('$cornice,')) r,
        ];
      }
    }
    final custodi = [for (final ap in aperture) _unisci(ap, fraseDelCustode)];
    final inPiu = _ruotaDopoIlVuoto(_fraseInPiu(q), q.testo, a.number);
    // La cornice dei ruoli vale piu' dell'apertura piena: prima si cerca la
    // misura con la cornice e le aperture che nominano la domanda, poi tutte
    // le combinazioni. L'apertura generica ("Alla tua domanda,") resta fuori
    // dalla prima ricerca: con lei due domande diverse sulle stesse carte
    // avevano la stessa risposta (D2, provato in questo lavoro).
    final risposta = (incorniciati.isEmpty
            ? null
            : _seEntra([
                custodi.length > 2
                    ? custodi.sublist(0, custodi.length - 1)
                    : custodi,
                inPiu,
                incorniciati,
              ])) ??
        aMisura([custodi, inPiu, ruoli]);

    // Il "Cosa fare": il passo concreto sulla cosa della domanda, poi il
    // gesto scritto per l'angelo del Custode in quel gruppo di domande.
    final gesto = lettura(corpus, a, 'gesto_${f.gruppo}') ??
        'Scegli oggi un gesto piccolo che ti avvicini a ${dono(corpus, a)}.';
    // La seconda di due domande si rimanda una volta sola: nella risposta se
    // la misura lo consente, altrimenti in testa al "Cosa fare".
    final rimandoNelGesto = q.doppia;
    final cosaFare = aMisura([
      if (rimandoNelGesto)
        [
          if ((q.seconda!.oggetto ?? q.seconda!.persona) case final cosa?)
            'Le domande sono due: ${con('su', cosa)} fai un\'altra '
                'consultazione.',
          'Per la seconda domanda fai un\'altra consultazione.',
        ],
      _ruota(_passi(q), q.testo, a.number),
      [gesto],
      _ruotaDopoIlVuoto(_passiInPiu(q), q.testo, a.number + 7),
    ]);
    return ResponsoInterpretato(
      arte: ArteInterpretata.oracolo,
      titolo: _titolo(q, c),
      risposta: risposta,
      cosaFare: cosaFare,
    );
  }

  /// **LA CORNICE DEI RUOLI**, ordine GA voce GA.06, terza lettura cieca: le
  /// frasi del Cuore e dell'Intelletto erano "glosse fisse dell'angelo,
  /// incollate". La situazione della domanda le apre: l'attesa di un esito,
  /// la preparazione a una prova, il rapporto con l'altra persona, la scelta,
  /// la via, il periodo, la situazione che tocca a chi e' competente. Se la
  /// frase del Cuore nomina gia' la stessa situazione, o la frase del Custode
  /// dice gia' le stesse parole ("imparando mentre aspetti"), la cornice non
  /// si ripete. L'esito di un rapporto ("La mia relazione può durare?") si
  /// legge nel rapporto, non nell'attesa.
  static String? _cornice(
      LaDomandaDellOracolo q, String fraseDelCustode, String fraseDelCuore) {
    final rapporto = RegExp(
        r'relazione|rapporto|matrimonio|amicizia|legame|fidanzament',
        caseSensitive: false);
    final (String cornice, String gia) = switch (q) {
      _ when q.limite != null => ('In questa situazione', r'situazione'),
      _ when q.prova => ('Mentre ti prepari', r'prepar'),
      _
          when q.forma == FormaDellaDomanda.esito &&
              rapporto.hasMatch(q.oggetto ?? '') =>
        ('In questo rapporto', r'rapporto|legame|relazione'),
      _ => switch (q.forma) {
          FormaDellaDomanda.esito || FormaDellaDomanda.quando => (
              'Mentre aspetti',
              r'aspett|attes|mentre'
            ),
          FormaDellaDomanda.ritorno => ('Intanto', r'intanto|mentre'),
          FormaDellaDomanda.sentimenti || FormaDellaDomanda.fiducia => (
              'In questo rapporto',
              r'rapporto'
            ),
          FormaDellaDomanda.decisione || FormaDellaDomanda.scelta => (
              'Davanti a questa scelta',
              r'scelt|davanti'
            ),
          FormaDellaDomanda.come => ('Per riuscirci', r'riuscir'),
          _ => ('Per questo periodo', r'periodo'),
        },
    };
    if (RegExp(gia, caseSensitive: false).hasMatch(fraseDelCuore) ||
        fraseDelCustode.toLowerCase().contains(cornice.toLowerCase())) {
      return null;
    }
    return cornice;
  }

  /// L'apertura e la frase del Custode: dopo i due punti o la virgola la
  /// frase comincia col nome dell'angelo e resta com'e'; dopo un punto e'
  /// una frase nuova.
  static String _unisci(String apertura, String frase) => '$apertura $frase';

  /// Nell'assaggio il Custode e' solo: le sue frasi del Cuore e
  /// dell'Intelletto per la famiglia dicono che cosa il suo stesso dono fa
  /// sentire e capire, senza nominare le carte col lucchetto.
  static List<String> _ruoliDelSoloCustode(
      Map<String, List<String>> corpus, Angel a, FamigliaDellaDomanda f) {
    String? senzaNome(String? frase, String soggetto) {
      if (frase == null) return null;
      final nome = '${a.name} ';
      if (!frase.startsWith(nome)) return frase;
      return '$soggetto ${frase.substring(nome.length)}';
    }

    final h =
        senzaNome(lettura(corpus, a, 'cuore_${f.gruppo}'), 'Lo stesso angelo');
    final i = lettura(corpus, a, 'intelletto_${f.gruppo}');
    return [
      if (h != null && i != null) '$h $i',
      if (h != null) h,
      '',
    ];
  }

  // --- l'apertura -----------------------------------------------------------

  /// Le aperture di una domanda, dalla piu' piena alla piu' breve. Finiscono
  /// coi due punti, con la virgola o col punto: dopo viene la frase scritta
  /// del Custode, che comincia col nome dell'angelo.
  static List<String> _aperture(LaDomandaDellOracolo q) {
    final o = q.oggetto;
    final p = q.persona ?? 'l\'altra persona';
    final p2 = q.persona ?? 'lei';
    switch (q.limite) {
      case LimiteDellaDomanda.salute:
        final su = o == null
            ? 'Su questa questione medica'
            : 'Sull\'esito ${con('di', o)}';
        return [
          '$su nessun angelo risponde e nessuna carta può farlo: è una '
              'domanda per il tuo medico.',
          '$su risponde il tuo medico, non le carte.',
          if (o != null)
            '${_maiuscola(con('su', o))} risponde il tuo medico, non le carte.',
          'Su questo risponde il tuo medico, non le carte.',
        ];
      case LimiteDellaDomanda.legge:
        final su = o == null
            ? 'Su questa questione legale'
            : 'Sull\'esito ${con('di', o)}';
        return [
          '$su nessun angelo risponde e nessuna carta può farlo: è una '
              'questione per il tuo avvocato.',
          '$su ti guida il tuo avvocato, non le carte.',
          if (o != null)
            '${_maiuscola(con('su', o))} ti guida il tuo avvocato, non le '
                'carte.',
          'Su questo ti guida il tuo avvocato, non le carte.',
        ];
      case LimiteDellaDomanda.denaro:
        final su = _sceltaDiDenaro(q);
        return [
          '$su nessuna carta può darti un consiglio: è una scelta da fare con '
              'un consulente finanziario o un commercialista di fiducia.',
          '$su decidi con un consulente di fiducia, non con le carte.',
          if (q.clausola != null)
            '${_maiuscola(q.clausola!)}: decidilo con un consulente, non con '
                'le carte.',
          if (q.alternative != null)
            '${_maiuscola(q.alternative!.$1)} o ${q.alternative!.$2}: '
                'decidilo con un consulente.',
          if (q.clausola != null)
            '${_maiuscola(q.clausola!)}: decidilo con un consulente.',
          if (q.oggetto != null)
            '${_maiuscola(q.oggetto!)}: decidi con un consulente.',
          'Su questo decidi con un consulente di fiducia, non con le carte.',
        ];
      case null:
        break;
    }
    switch (q.forma) {
      case FormaDellaDomanda.aperta:
        return [
          'Una domanda aperta riceve un orientamento per oggi, non la '
              'risposta a un caso preciso:',
          'Senza una domanda precisa le carte danno un orientamento:',
        ];
      case FormaDellaDomanda.generica:
        return [
          'Alla tua domanda le carte rispondono con un orientamento per il '
              'tempo che vivi:',
          'Alla tua domanda le carte danno un orientamento:',
        ];
      case FormaDellaDomanda.futuro:
        return q.tuttoBene
            ? [
                'Nessuna carta può prometterti che tutto vada bene, perché il '
                    'futuro non è scritto:',
                'Nessuna carta può prometterti che tutto vada bene:',
              ]
            : [
                'Ciò che ti aspetta non è scritto nelle carte, perché il '
                    'futuro non è già deciso:',
                'Ciò che ti aspetta non è scritto nelle carte:',
              ];
      case FormaDellaDomanda.esito:
        final testa = q.attacco ??
            (o == null ? 'L\'esito che speri' : 'L\'esito ${con('di', o)}');
        return [
          '$testa non è scritto nelle carte e nessuno può promettertelo:',
          '$testa non è scritto nelle carte:',
          'L\'esito non è scritto nelle carte:',
        ];
      case FormaDellaDomanda.quando:
        return [
          if (o != null) 'Nessuna carta dà una data per $o:',
          'Le carte non danno date:',
        ];
      case FormaDellaDomanda.sentimenti:
        return [
          'Ciò che $p sente per te può dirtelo solo $p2, non le carte:',
          'Ciò che $p sente per te lo sa solo $p2:',
          'Ciò che prova un\'altra persona non si legge nelle carte:',
        ];
      case FormaDellaDomanda.fiducia:
        final di = q.persona == null ? 'di questa persona' : con('di', p);
        return [
          'Se puoi fidarti $di lo dicono i suoi gesti nel tempo, non le '
              'carte:',
          'Se puoi fidarti $di lo dicono i suoi gesti, non le carte:',
          'La fiducia si misura sui gesti, non sulle carte:',
        ];
      case FormaDellaDomanda.ritorno:
        return [
          'Un suo ritorno non si legge nelle carte e dipende da una scelta '
              'sua:',
          'Un suo ritorno non si legge nelle carte:',
        ];
      case FormaDellaDomanda.decisione:
        return [
          if (q.clausola != null) 'Alla domanda se ${q.clausola},',
          // La domanda ripetuta come la direbbe la persona, piu' breve:
          // "Lasciare il lavoro per tornare a studiare: Lecabel dice sì se".
          if (q.clausola != null) '${_maiuscola(q.clausola!)}:',
          'Alla tua domanda,',
        ];
      case FormaDellaDomanda.scelta:
        return [
          if (q.alternative != null)
            'Fra ${q.alternative!.$1} e ${q.alternative!.$2},',
          if (q.gruppo != null) 'Fra ${q.gruppo},',
          'Fra le due strade,',
        ];
      case FormaDellaDomanda.come:
        return [
          if (q.infinito != null) 'Per ${q.infinito},',
          if (q.infinito == null && o != null) 'Per $o,',
          'Per la via da prendere,',
        ];
    }
  }

  /// La scelta di denaro, detta con le parole della domanda.
  static String _sceltaDiDenaro(LaDomandaDellOracolo q) {
    if (q.alternative != null) {
      return 'Sulla scelta fra ${q.alternative!.$1} e ${q.alternative!.$2}';
    }
    if (q.clausola != null) return 'Sulla scelta di ${q.clausola}';
    if (q.oggetto != null) return 'Su come usare ${q.oggetto}';
    return 'Su questa scelta di denaro';
  }

  /// La frase in piu' della risposta, quando serve alla misura o al senso:
  /// la seconda domanda rimandata (sempre), il limite detto per intero, il
  /// confine della lettura detto per la forma della domanda. Piu' lunghezze,
  /// perche' la misura le scelga senza tagliare.
  static List<String> _fraseInPiu(LaDomandaDellOracolo q) {
    // Il rimando della seconda di due domande non sta qui: sta in testa al
    // "Cosa fare", sempre nello stesso posto (il secondo lettore cieco l'ha
    // trovato una volta qui e una volta nel riquadro).
    if (q.limite != null) {
      return [
        '',
        'Le carte non promettono un esito.',
        'Le carte non sostituiscono chi è competente e non promettono un '
            'esito.',
      ];
    }
    return switch (q.forma) {
      FormaDellaDomanda.aperta ||
      FormaDellaDomanda.generica ||
      FormaDellaDomanda.futuro =>
        [
          '',
          'Una domanda precisa riceve una risposta più precisa.',
          'Una domanda precisa riceve una risposta più precisa: le carte '
              'leggono ciò che nomini.',
        ],
      FormaDellaDomanda.esito || FormaDellaDomanda.quando => [
          '',
          'Ciò che prepari tu conta.',
          'Ciò che prepari tu pesa più di qualunque presagio.',
          'Ciò che prepari tu pesa più di qualunque presagio: resta tuo '
              'qualunque sia l\'esito.',
        ],
      FormaDellaDomanda.sentimenti ||
      FormaDellaDomanda.fiducia ||
      FormaDellaDomanda.ritorno =>
        [
          '',
          'La sua volontà è sua.',
          'Le carte non leggono il cuore degli altri.',
          'Le carte non leggono il cuore degli altri: leggono ciò che puoi '
              'fare tu.',
        ],
      FormaDellaDomanda.decisione || FormaDellaDomanda.scelta => [
          '',
          'La scelta resta tua.',
          'Una scelta di questo peso merita il suo tempo.',
          'Una scelta di questo peso merita il suo tempo: resta tua.',
        ],
      FormaDellaDomanda.come => [
          '',
          'Il primo passo tocca a te.',
          'Il primo passo tocca a te: può essere piccolo.',
        ],
    };
  }

  // --- il riquadro "Cosa fare adesso" -----------------------------------------

  /// Il passo concreto sulla cosa della domanda, in varianti: la stessa
  /// formula non torna in ogni responso della stessa famiglia.
  static List<String> _passi(LaDomandaDellOracolo q) {
    final o = q.oggetto;
    final p = q.persona;
    switch (q.limite) {
      case LimiteDellaDomanda.salute:
        final su = o == null ? 'Su questo' : _maiuscola(con('su', o));
        return [
          '$su porta ogni dubbio al tuo medico: è lui o lei a poterti '
              'rispondere, non una carta.',
          '$su affidati al tuo medico e chiedigli tutto ciò che non ti è '
              'chiaro.',
        ];
      case LimiteDellaDomanda.legge:
        final su = o == null ? 'Su questo' : _maiuscola(con('su', o));
        return [
          '$su non decidere nulla per impulso: ogni mossa passa prima dal tuo '
              'avvocato.',
          '$su lascia che sia il tuo avvocato a valutare le mosse, prima di '
              'agire.',
        ];
      case LimiteDellaDomanda.denaro:
        // Il passo nomina la scelta della domanda e il consulente: due
        // domande di denaro diverse non ricevono lo stesso riquadro.
        final su = _sceltaDiDenaro(q);
        return [
          '$su chiedi un parere a un consulente indipendente e fatti '
              'spiegare i rischi per iscritto.',
          '$su porta numeri e dubbi a un consulente di fiducia e non firmare '
              'nulla sotto la spinta del momento.',
        ];
      case null:
        break;
    }
    switch (q.forma) {
      case FormaDellaDomanda.aperta:
      case FormaDellaDomanda.generica:
      case FormaDellaDomanda.futuro:
        // L'invito a precisare una volta sola, in due lunghezze.
        return [
          'Se c\'è una situazione che ti sta a cuore, rifai la domanda '
              'nominandola: le carte leggono meglio ciò che nomini. Per oggi, '
              'l\'orientamento è questo.',
          'Rifai la domanda su una situazione precisa della tua vita: più è '
              'chiara, più la risposta ti serve.',
          'Se vuoi una risposta più precisa, rifai la domanda nominando la '
              'situazione che vivi.',
        ];
      case FormaDellaDomanda.esito:
        return _passiDellEsito(q);
      case FormaDellaDomanda.quando:
        return [
          'Invece di contare i giorni, scegli una cosa ferma che dipende da '
              'te e muovila di un passo.',
          'Lascia stare la data e chiediti che cosa puoi sbloccare tu questa '
              'settimana.',
        ];
      case FormaDellaDomanda.sentimenti:
        final chi = p ?? 'l\'altra persona';
        return [
          'Per capire che cosa prova $chi, guarda i suoi gesti più delle '
              'parole e, se serve, chiediglielo con calma.',
          'Su ciò che prova $chi conta ciò che fa più di ciò che immagini: '
              'osserva per qualche giorno senza tirare conclusioni.',
        ];
      case FormaDellaDomanda.fiducia:
        final chi = p ?? 'questa persona';
        return [
          'Per qualche giorno annota ciò che $chi dice e ciò che poi fa: la '
              'fiducia nasce dove le due cose coincidono.',
          'Guarda se le parole e i gesti ${con('di', chi)} vanno nella stessa '
              'direzione, senza indagare di nascosto.',
        ];
      case FormaDellaDomanda.ritorno:
        return [
          'Non scrivere per ottenere una risposta e non cercare segni nei '
              'suoi silenzi: pensa a che cosa vuoi tu, adesso.',
          'Lascia che sia una sua scelta e intanto metti al centro ciò che '
              'fa bene alla tua vita.',
        ];
      case FormaDellaDomanda.decisione:
        // Le varianti generiche solo se la domanda non dice l'azione: il
        // riquadro nomina cio' che la persona sta pesando (D2).
        final cl = q.clausola;
        if (cl != null) {
          return [
            'Prima di decidere se $cl, scrivi che cosa cambierebbe davvero e '
                'che cosa resterebbe uguale.',
            'Prima di decidere se $cl, separa i fatti dalle paure e parlane '
                'con una persona di cui ti fidi.',
          ];
        }
        return [
          'Raccogli i fatti che ti mancano e concediti il tempo che una scelta '
              'di questo peso richiede.',
          'Separa i fatti dalle paure e parlane con una persona di cui ti '
              'fidi.',
        ];
      case FormaDellaDomanda.scelta:
        final strade = q.alternative != null
            ? '${q.alternative!.$1} e ${q.alternative!.$2}'
            : q.gruppo;
        if (strade != null) {
          return [
            'Fra $strade, immagina una giornata qualunque fra un anno in '
                'ciascuna strada e annota che cosa senti.',
            'Prima di scegliere fra $strade, raccogli i fatti che ti mancano.',
          ];
        }
        return [
          'Immagina una giornata qualunque fra un anno in ciascuna strada e '
              'annota che cosa senti.',
          'Raccogli i fatti che ti mancano su entrambe le strade prima di '
              'scegliere.',
        ];
      case FormaDellaDomanda.come:
        if (q.evento && o != null) {
          return [
            'Prepara come vuoi stare ${con('a', o)}: che cosa porti, quali '
                'argomenti eviti e dove ti fermi se la tensione sale.',
            'Decidi prima ${con('di', o)} quali argomenti lasciare fuori e '
                'dove fermarti se la tensione sale.',
          ];
        }
        if (p != null) {
          return [
            'Scegli un momento tranquillo e di\' ${con('a', p)} una cosa '
                'sola, vera e senza rimprovero, poi ascolta fino in fondo.',
            'Con $p '
                'comincia da ciò che vi unisce e lascia per ultimo ciò che '
                'vi divide.',
          ];
        }
        if (q.infinito != null) {
          return [
            'Scegli un primo gesto concreto per ${q.infinito} e fallo entro '
                'la settimana.',
            'Per ${q.infinito}, comincia da un gesto piccolo e fallo entro '
                'la settimana.',
          ];
        }
        return [
          'Scegli un primo gesto concreto e fallo entro la settimana.',
        ];
    }
  }

  /// **IL PASSO DELL'ESITO**, scritto per la cosa della domanda: il secondo
  /// lettore cieco ha trovato lo stesso riquadro sotto il colloquio e sotto
  /// la relazione a distanza, e nessuna parola sullo studio sotto l'esame.
  static List<String> _passiDellEsito(LaDomandaDellOracolo q) {
    final o = q.oggetto?.replaceFirst('la fine di ', '');
    if (o == null) {
      return [
        'Separa ciò che dipende da te da ciò che non dipende da te e cura il '
            'primo, un passo al giorno.',
        'Lascia andare le ipotesi sull\'esito e torna a ciò che puoi ancora '
            'preparare.',
      ];
    }
    final per = _maiuscola(o.startsWith('un ') ? 'per $o' : 'per $o');
    if (o.contains('esame') || o.contains('concorso')) {
      return [
        '$per fissa un piano di ripasso fino alla data, una parte al giorno: '
            'segna ciò che hai fatto. Quando sale l\'ansia, torna alla parte '
            'di oggi.',
        '$per fissa un piano di ripasso fino alla data, una parte al giorno: '
            'segna ciò che hai fatto.',
      ];
    }
    if (o.contains('colloquio')) {
      return [
        '$per prepara tre esempi concreti di ciò che sai fare e una domanda da '
            'porre tu. Ripetili a voce alta una volta, non di più.',
        '$per prepara tre esempi concreti di ciò che sai fare e una domanda da '
            'porre tu.',
      ];
    }
    if (o.contains('progetto')) {
      return [
        '$per ormai consegnato, prepara con calma le risposte alle obiezioni '
            'più probabili. Poi lascialo maturare senza rimaneggiarlo mentre '
            'aspetti.',
        '$per ormai consegnato, prepara le risposte alle obiezioni più '
            'probabili e poi lascialo maturare.',
      ];
    }
    if (o.contains('relazione') || o.contains('distanza')) {
      return [
        '$per concorda con l\'altra persona un ritmo di contatto sostenibile '
            'per entrambe le parti. Contano la regolarità e la sincerità più '
            'della frequenza.',
        '$per concorda con l\'altra persona un ritmo di contatto sostenibile '
            'per entrambe le parti.',
      ];
    }
    if (o.contains('promozione')) {
      return [
        '$per chiedi a chi decide un riscontro concreto su ciò che ti manca. '
            'Poi lavora su un punto alla volta, senza aspettare la decisione.',
        '$per chiedi a chi decide un riscontro concreto su ciò che ti manca.',
      ];
    }
    if (o.contains('risposta') ||
        o.contains('cambiamento') ||
        o.contains('stallo')) {
      // La domanda non dice di che risposta o di che cambiamento si tratta:
      // si invita a nominarlo (il lettore cieco: "nessuno chiede quale").
      final che = o.contains('risposta')
          ? 'la risposta che aspetti'
          : o.contains('cambiamento')
              ? 'il cambiamento che senti arrivare'
              : 'ciò che si è fermato';
      return [
        'Se vuoi una lettura più precisa, rifai la domanda nominando $che. '
            'Intanto separa ciò che dipende da te da ciò che non dipende da te.',
        'Se vuoi una lettura più precisa, rifai la domanda nominando $che.',
      ];
    }
    if (o.contains('incontro')) {
      return [
        'Per un incontro importante, scegli questa settimana un\'occasione '
            'nuova fra persone che condividono ciò che ami. Gli incontri '
            'nascono dove vai.',
        'Per un incontro importante, scegli questa settimana un\'occasione '
            'nuova fra persone che condividono ciò che ami.',
      ];
    }
    return [
      '$per separa ciò che dipende da te da ciò che non dipende da te e cura '
          'il primo.',
      '${_maiuscola(con('su', o))} lascia andare le ipotesi e torna a ciò che '
          'puoi ancora preparare.',
    ];
  }

  /// La frase che chiude il "Cosa fare" quando la misura la chiede: detta
  /// per la famiglia, mai un riempitivo che valga per tutto. Piu' lunghezze,
  /// perche' la misura le scelga senza tagliare.
  static List<String> _passiInPiu(LaDomandaDellOracolo q) {
    if (q.limite != null) {
      return [
        '',
        'Le carte ti accompagnano, non decidono.',
        'Sul resto le carte ti accompagnano, ma non decidono al posto di chi è '
            'competente.',
      ];
    }
    return switch (q.forma) {
      FormaDellaDomanda.aperta ||
      FormaDellaDomanda.generica ||
      FormaDellaDomanda.futuro =>
        [
          '',
          'Un gesto piccolo, fatto oggi, vale più di molte previsioni.',
        ],
      FormaDellaDomanda.esito || FormaDellaDomanda.quando => [
          '',
          'Ciò che prepari adesso resta tuo, qualunque sia l\'esito.',
          'Ciò che prepari adesso resta tuo, qualunque sia l\'esito: nessuna '
              'attesa può togliertelo.',
        ],
      FormaDellaDomanda.sentimenti ||
      FormaDellaDomanda.fiducia ||
      FormaDellaDomanda.ritorno =>
        [
          '',
          'Ciò che decide l\'altra persona resta suo; ciò che fai tu resta '
              'tuo.',
          'Se qualcosa non torna, parlane con calma, a voce, con chi riguarda.',
        ],
      FormaDellaDomanda.decisione || FormaDellaDomanda.scelta => [
          '',
          'Dai a questa scelta i giorni che il suo peso richiede.',
          'Dai a questa scelta i giorni che il suo peso richiede, senza farti '
              'mettere fretta.',
        ],
      FormaDellaDomanda.come => [
          '',
          'Il resto viene dopo, quando il primo passo è stato fatto davvero.',
        ],
    };
  }

  // --- il titolo ------------------------------------------------------------

  static String _titolo(LaDomandaDellOracolo q, String c) {
    final o = q.oggetto;
    final p = q.persona;
    final candidati = <String>[];
    switch (q.limite) {
      // I titoli dei limiti nominano la cosa della domanda: due domande di
      // denaro diverse non hanno lo stesso titolo.
      case LimiteDellaDomanda.salute:
        if (o != null) {
          candidati.add('Sull\'esito ${con('di', o)} ti risponde il medico');
        }
        candidati.add('Sull\'esito ti risponde il medico, non le carte');
      case LimiteDellaDomanda.legge:
        if (o != null) {
          candidati.add('${_maiuscola(con('su', o))}: ti guida l\'avvocato');
        }
        candidati
            .add('Sulla questione legale ti guida l\'avvocato, non le carte');
      case LimiteDellaDomanda.denaro:
        if (q.alternative != null) {
          candidati.add('${_maiuscola(q.alternative!.$1)} o '
              '${q.alternative!.$2}: decidi con un consulente');
        }
        if (q.clausola != null) {
          candidati.add('${_maiuscola(q.clausola!)}: decidi con un consulente');
        }
        if (q.oggetto != null) {
          candidati.add('${_maiuscola(q.oggetto!)}: decidi con un consulente');
        }
        candidati.add('Sul denaro decidi con un consulente, non con le carte');
      case null:
        switch (q.forma) {
          case FormaDellaDomanda.aperta:
          case FormaDellaDomanda.generica:
            candidati.add('Un orientamento per oggi, da $c');
          case FormaDellaDomanda.futuro:
            candidati.add(q.tuttoBene
                ? 'Nessuna carta lo promette: conta il passo che fai oggi'
                : 'Ciò che ti aspetta non è scritto: oggi conta un tuo passo');
          case FormaDellaDomanda.esito:
            if (o != null) {
              candidati.add(
                  '${_maiuscola(o)}: l\'esito non è scritto, conta ciò che '
                  'fai tu');
            }
            candidati.add('L\'esito non è scritto: conta ciò che fai tu');
          case FormaDellaDomanda.quando:
            candidati.add('Nessuna data: conta il passo che fai adesso');
          case FormaDellaDomanda.sentimenti:
            if (p != null && !p.contains(' ')) {
              candidati.add('Ciò che sente $p lo dice $p, non le carte');
            }
            candidati.add(
                'Ciò che prova un\'altra persona non si legge nelle carte');
          case FormaDellaDomanda.fiducia:
            candidati.add('La fiducia si misura sui gesti, non sulle carte');
          case FormaDellaDomanda.ritorno:
            candidati.add('Un ritorno non si legge: torna a ciò che vuoi tu');
          case FormaDellaDomanda.decisione:
            if (q.clausola != null) {
              candidati
                  .add('${_maiuscola(q.clausola!)}: sì, alla condizione di $c');
            }
            candidati.add('Sì, alla condizione che ti pone $c');
          case FormaDellaDomanda.scelta:
            if (q.alternative != null) {
              candidati.add('Fra ${q.alternative!.$1} e '
                  '${q.alternative!.$2}: la strada la indica $c');
            }
            if (q.gruppo != null) {
              candidati.add('Fra ${q.gruppo}: la strada la indica $c');
            }
            candidati.add('La strada giusta è quella che ti indica $c');
          case FormaDellaDomanda.come:
            if (q.infinito != null) {
              candidati.add('Per ${q.infinito}: la via di $c');
            }
            if (o != null) candidati.add('Per $o: la via di $c');
            candidati.add('La via te la indica $c');
        }
    }
    final t = candidati.firstWhere((x) => x.length <= 80,
        orElse: () => 'Le carte rispondono con $c');
    return _maiuscola(t);
  }
}
