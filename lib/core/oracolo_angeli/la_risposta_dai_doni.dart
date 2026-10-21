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

  static final RegExp _denaro = _re(r'investi\w*|borsa|risparmi\w*|cripto\w*|'
      r'bitcoin|mutuo|prestit\w*|debit\w*|soldi|denaro|finanz\w*|'
      r'patrimoni\w*|azioni in');
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
      })> _cose = [
    _cosa(r"esame di stato", (m) => "l'esame di stato"),
    _cosa(r'esame|esami(?! del sangue)', (m) => "l'esame"),
    _cosa(r'colloquio(?: di [\p{L}]+)?', (m) => 'il $m'),
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
  }) _cosa(String re, String Function(String m) frase,
          {String Function(String o)? attacco,
          bool evento = false,
          bool relazione = false}) =>
      (
        re: _re(re),
        frase: frase,
        attacco: attacco,
        evento: evento,
        relazione: relazione
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

  static ({String frase, String? attacco, bool evento})? _oggetto(
      String d, String? persona) {
    ({
      int pos,
      String frase,
      String? attacco,
      bool evento,
      bool relazione
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
    return (frase: frase, attacco: migliore.attacco, evento: migliore.evento);
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
      persona: persona,
      clausola: clausola,
      alternative: alternative,
      gruppo: gruppo,
      infinito: infinito,
      tuttoBene: tuttoBene,
    );
  }
}

/// **LA RISPOSTA DAI DONI.** Ordine GA voce GA.06, 20 ottobre 2026: il
/// responso principale senza modello, cioe' l'assaggio del Viandante e il
/// ripiego quando il modello non risponde.
///
/// **LAPIDE.** Fino a questa voce il responso senza modello era la carta del
/// Custode copiata (ordine GA voce GA.05, `LaLetturaDellOracolo.delCorpus`):
/// il lettore cieco l'ha trovata uguale alla carta singola 40 volte su 40,
/// con il Cuore e l'Intelletto mai nominati, la prima frase che rispondeva
/// alla domanda 6 volte su 40 e lo stesso testo sotto domande diverse (D1,
/// D2). Adesso il responso si compone qui:
/// - la PRIMA FRASE risponde alla forma della domanda
///   ([LaDomandaDellOracolo]) e nomina l'angelo del Custode col suo dono o
///   la sua via;
/// - la frase dei RUOLI porta il dono dell'angelo del Cuore (che cosa
///   sentire) e la via di quello dell'Intelletto (che cosa capire);
/// - il riquadro "Cosa fare adesso" da' un gesto pertinente alla domanda,
///   legato al dono del Custode;
/// - dove la domanda tocca salute, legge o denaro, la prima frase lo dice e
///   rimanda a chi e' competente.
/// Il dono e la via di ogni angelo vengono dal corpus (`doni.md`, generato
/// da `tool/il_corpus_dell_oracolo.py`), scritti dal nucleo dello schedario.
/// Ogni paragrafo si sceglie fra alternative di frasi intere finche' sta fra
/// 40 e 50 parole: nessun testo si tronca (GA.07).
abstract final class LaRispostaDaiDoni {
  /// Il dono di un angelo dal corpus. Senza la cella, il dominio del coro.
  static String dono(Map<String, List<String>> corpus, Angel a) {
    final v = corpus['doni|${a.number.toString().padLeft(2, '0')}|dono'];
    return (v == null || v.isEmpty) ? a.choir.domain : v.first;
  }

  /// La via di un angelo dal corpus. Senza la cella, una via neutra.
  static String via(Map<String, List<String>> corpus, Angel a) {
    final v = corpus['doni|${a.number.toString().padLeft(2, '0')}|via'];
    return (v == null || v.isEmpty)
        ? 'restare fedele a ciò che conta per te'
        : v.first;
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
    final custode = carte.firstWhere((c) => c.ruolo == RuoloDellAngelo.custode,
        orElse: () => carte.first);
    final cuore = carte.where((c) => c.ruolo == RuoloDellAngelo.cuore);
    final intelletto =
        carte.where((c) => c.ruolo == RuoloDellAngelo.intelletto);
    final c = custode.angelo.name;
    final dC = dono(corpus, custode.angelo);
    final vC = via(corpus, custode.angelo);

    final prima = _primaFrase(q, c, dC, vC);
    final secondaFrase = _secondaFrase(q);
    final List<String> ruoli;
    if (soloIlCustode || cuore.isEmpty) {
      ruoli = prima.usaIlDono
          ? [
              'La sua via è $vC: è da lì che conviene partire oggi.',
              'La sua via è $vC.',
              '',
            ]
          : [
              'Il dono di $c è $dC: tienilo presente in ciò che fai oggi.',
              'Il dono di $c è $dC.',
              '',
            ];
    } else {
      final h = cuore.first.angelo;
      final dH = dono(corpus, h);
      final i = intelletto.isEmpty ? null : intelletto.first;
      if (i == null || i.coperta) {
        ruoli = [
          'Nel Cuore ${h.name} ti fa sentire $dH; la carta dell\'Intelletto '
              'resta coperta finché non aggiungi la tua ora di nascita.',
          'Nel Cuore ${h.name} ti porta $dH; l\'Intelletto resta coperto '
              'senza la tua ora di nascita.',
          'Nel Cuore ${h.name} porta $dH.',
        ];
      } else {
        final dI = dono(corpus, i.angelo);
        final vI = via(corpus, i.angelo);
        ruoli = [
          'Nel Cuore ${h.name} ti porta $dH; nell\'Intelletto '
              '${i.angelo.name} ti fa capire che la chiave è $vI.',
          'Nel Cuore ${h.name} ti porta $dH; nell\'Intelletto '
              '${i.angelo.name} ti porta $dI.',
          'Nel Cuore ${h.name} porta $dH, nell\'Intelletto ${i.angelo.name} '
              '$dI.',
        ];
      }
    }
    final risposta = aMisura([
      prima.frasi,
      secondaFrase,
      ruoli,
      _riempitivi,
    ]);
    final cosaFare = aMisura([
      _gesto(q),
      _legame(q, c, dC, vC),
      _riempitiviDelGesto,
    ]);
    return ResponsoInterpretato(
      arte: ArteInterpretata.oracolo,
      titolo: _titolo(q, c, dC, vC),
      risposta: risposta,
      cosaFare: cosaFare,
    );
  }

  // --- la prima frase ---------------------------------------------------------

  static ({List<String> frasi, bool usaIlDono}) _primaFrase(
      LaDomandaDellOracolo q, String c, String dC, String vC) {
    final o = q.oggetto;
    final p = q.persona ?? 'l\'altra persona';
    final p2 = q.persona ?? 'lei';
    switch (q.limite) {
      case LimiteDellaDomanda.salute:
        final su = o == null
            ? 'Su questa questione medica'
            : 'Sull\'esito ${con('di', o)}';
        return (
          frasi: [
            '$su $c non risponde e nessuna carta può farlo: è una domanda '
                'per il tuo medico.',
            '$su $c non risponde: chiedilo al tuo medico.',
          ],
          usaIlDono: false,
        );
      case LimiteDellaDomanda.legge:
        final su = o == null
            ? 'Su questa questione legale'
            : 'Sull\'esito ${con('di', o)}';
        return (
          frasi: [
            '$su $c non risponde e nessuna carta può farlo: è una questione '
                'per il tuo avvocato.',
            '$su $c non risponde: chiedilo al tuo avvocato.',
          ],
          usaIlDono: false,
        );
      case LimiteDellaDomanda.denaro:
        final cosa = o ?? 'il tuo denaro';
        return (
          frasi: [
            'Su come usare $cosa $c non dà consigli e nessuna carta può '
                'darli: è una scelta da fare con un consulente finanziario di '
                'fiducia.',
            'Sul denaro $c non dà consigli: decidi con un consulente '
                'finanziario di fiducia.',
          ],
          usaIlDono: false,
        );
      case null:
        break;
    }
    switch (q.forma) {
      case FormaDellaDomanda.aperta:
        return (
          frasi: [
            'Alla tua domanda aperta $c risponde con il suo dono, $dC: oggi '
                'conviene partire da lì.',
            'Alla tua domanda aperta $c risponde con $dC.',
          ],
          usaIlDono: true,
        );
      case FormaDellaDomanda.futuro:
        final testa = q.tuttoBene
            ? 'Nessuna carta può prometterti che tutto vada bene'
            : 'Ciò che ti aspetta non è scritto nelle carte';
        return (
          frasi: [
            '$testa, perché il futuro non si legge come una cosa già decisa: '
                '$c ti risponde con ciò che dipende da te oggi, cioè $vC.',
            '$testa: $c ti indica ciò che dipende da te, cioè $vC.',
          ],
          usaIlDono: false,
        );
      case FormaDellaDomanda.esito:
        final testa = q.attacco ??
            (o == null ? 'L\'esito che speri' : 'L\'esito ${con('di', o)}');
        return (
          frasi: [
            '$testa non è scritto nelle carte e nessun angelo lo decide al '
                'posto tuo: $c ti risponde che adesso conta $vC.',
            '$testa non è scritto nelle carte: $c ti risponde che adesso '
                'conta $vC.',
            '$testa non è scritto: per $c conta $vC.',
          ],
          usaIlDono: false,
        );
      case FormaDellaDomanda.sentimenti:
        return (
          frasi: [
            'Ciò che $p sente per te può dirtelo solo $p2, non le carte: $c '
                'ti riporta a ciò che è tuo, $dC.',
            'Ciò che $p sente per te può dirtelo solo $p2: $c ti riporta a '
                '$dC.',
          ],
          usaIlDono: true,
        );
      case FormaDellaDomanda.fiducia:
        final di = q.persona == null ? 'di questa persona' : con('di', p);
        return (
          frasi: [
            'Se puoi fidarti $di lo dicono i suoi gesti nel tempo, non le '
                'carte: $c ti risponde che per te conta $vC.',
            'Se puoi fidarti $di lo dicono i suoi gesti, non le carte: per $c '
                'conta $vC.',
          ],
          usaIlDono: false,
        );
      case FormaDellaDomanda.ritorno:
        return (
          frasi: [
            'Un suo ritorno non si legge nelle carte e dipende da una scelta '
                'sua, non tua: $c ti riporta a ciò che è tuo, $dC.',
            'Un suo ritorno non si legge nelle carte: $c ti riporta a ciò che '
                'è tuo, $dC.',
          ],
          usaIlDono: true,
        );
      case FormaDellaDomanda.quando:
        final per = o == null ? '' : ' per $o';
        return (
          frasi: [
            'Nessuna carta dà una data$per: $c ti risponde che conta ciò che '
                'fai adesso, cioè $vC.',
            'Nessuna carta dà una data$per: $c ti risponde che conta $vC.',
            'Le carte non danno date: $c ti risponde che conta $vC.',
          ],
          usaIlDono: false,
        );
      case FormaDellaDomanda.scelta:
        final fra = q.alternative != null
            ? 'Fra ${q.alternative!.$1} e ${q.alternative!.$2}'
            : q.gruppo != null
                ? 'Fra ${q.gruppo}'
                : 'Fra le due strade';
        final quale = q.gruppo != null && q.alternative == null
            ? (q.gruppo!.startsWith('le ') ? 'quella' : 'quello')
            : 'la strada';
        return (
          frasi: [
            '$fra scegli $quale che ti permette meglio di $vC: è il criterio '
                'che ti dà $c.',
            'Fra le due strade scegli quella che ti permette di $vC: è il '
                'criterio di $c.',
          ],
          usaIlDono: false,
        );
      case FormaDellaDomanda.decisione:
        // La risposta e' un sì con la condizione che l'angelo del Custode
        // pone, e il no detto subito dopo: chi legge sa che cosa fare e
        // quando non farlo.
        final cl = q.clausola ?? 'la tua scelta';
        return (
          frasi: [
            'Sì, $cl va bene a una condizione che $c ti pone: $vC. Se la '
                'scelta ti costringe a fare il contrario, per adesso la '
                'risposta è no.',
            'Sì, $cl va bene a una condizione che $c ti pone: $vC. '
                'Altrimenti, per adesso, no.',
            'Sì, a una condizione che $c ti pone: $vC. Altrimenti, per '
                'adesso, no.',
          ],
          usaIlDono: false,
        );
      case FormaDellaDomanda.come:
        final per = q.infinito != null
            ? 'Per ${q.infinito}, la via'
            : o != null
                ? 'Per $o, la via'
                : 'La via';
        return (
          frasi: [
            '$per che $c ti indica è $vC.',
            'La via che $c ti indica è $vC.',
          ],
          usaIlDono: false,
        );
      case FormaDellaDomanda.generica:
        return (
          frasi: [
            'Alla tua domanda $c risponde così: adesso, per te, conta $vC.',
            'Alla tua domanda $c risponde: adesso conta $vC.',
          ],
          usaIlDono: false,
        );
    }
  }

  /// La seconda frase della risposta: il no della forma, il limite detto per
  /// intero, la seconda domanda rimandata.
  static List<String> _secondaFrase(LaDomandaDellOracolo q) {
    if (q.doppia) {
      final s = q.seconda!;
      final cosa = s.oggetto ?? s.persona;
      return [
        cosa == null
            ? 'Le domande però sono due: per la seconda fai un\'altra '
                'consultazione, perché le carte ne leggono una alla volta.'
            : 'Le domande però sono due: ${LaRispostaDaiDoni.con('su', cosa)} '
                'fai un\'altra consultazione, perché le carte ne leggono una '
                'alla volta.',
        'Per la seconda domanda fai un\'altra consultazione.',
      ];
    }
    switch (q.limite) {
      case LimiteDellaDomanda.salute:
        return [
          'Le carte non sostituiscono chi ti cura e non promettono un esito.',
          '',
        ];
      case LimiteDellaDomanda.legge:
        return [
          'Le carte non sostituiscono chi ti assiste e non promettono un '
              'esito.',
          '',
        ];
      case LimiteDellaDomanda.denaro:
        return [
          'Le carte non sostituiscono chi conosce i mercati e non promettono '
              'rendimenti.',
          '',
        ];
      case null:
        break;
    }
    return switch (q.forma) {
      FormaDellaDomanda.aperta || FormaDellaDomanda.futuro => [
          '',
          'Una domanda precisa riceve una risposta più precisa.',
        ],
      FormaDellaDomanda.esito => [
          '',
          'Ciò che prepari tu pesa più di qualunque presagio.',
        ],
      FormaDellaDomanda.sentimenti || FormaDellaDomanda.fiducia => [
          '',
          'Le carte non leggono il cuore degli altri.',
        ],
      FormaDellaDomanda.ritorno => [
          '',
          'Le carte non leggono la volontà degli altri.',
        ],
      _ => const [''],
    };
  }

  static const List<String> _riempitivi = [
    '',
    'Il passo resta tuo.',
    'Il resto viene un passo alla volta.',
    'Le carte indicano una direzione, non un destino.',
    'Le carte indicano una direzione, non un destino già scritto.',
    'Le carte indicano una direzione, non un destino già scritto: il passo '
        'resta tuo.',
  ];

  // --- il riquadro "Cosa fare adesso" -----------------------------------------

  static List<String> _gesto(LaDomandaDellOracolo q) {
    final o = q.oggetto;
    final p = q.persona;
    switch (q.limite) {
      case LimiteDellaDomanda.salute:
        return [
          'Scrivi le domande che vuoi fare al tuo medico e portale alla '
              'prossima visita: su questo è lui o lei a poterti rispondere.',
          'Scrivi le domande per il tuo medico e portale alla prossima '
              'visita.',
        ];
      case LimiteDellaDomanda.legge:
        final che =
            o != null && o.startsWith('la causa') ? 'la causa' : 'la questione';
        return [
          'Metti in ordine documenti e date, poi porta le tue domande al tuo '
              'avvocato: è la persona giusta per valutare $che. Non decidere '
              'nulla per impulso.',
          'Porta documenti, date e domande al tuo avvocato e non decidere '
              'nulla per impulso.',
        ];
      case LimiteDellaDomanda.denaro:
        final cosa = o ?? 'il tuo denaro';
        return [
          'Prima di muovere $cosa chiedi un parere a un consulente '
              'finanziario indipendente e fatti spiegare i rischi per '
              'iscritto. Non decidere sotto la spinta del momento.',
          'Chiedi un parere a un consulente finanziario indipendente prima '
              'di muovere $cosa.',
        ];
      case null:
        break;
    }
    switch (q.forma) {
      case FormaDellaDomanda.aperta:
      case FormaDellaDomanda.futuro:
        return [
          'Scegli una situazione precisa della tua vita e rifai la domanda '
              'su quella sola: più è chiara, più la risposta ti serve.',
          'Rifai la domanda su una situazione precisa: più è chiara, più la '
              'risposta ti serve.',
        ];
      case FormaDellaDomanda.esito:
        final per =
            o == null ? '' : ' per ${o.replaceFirst('la fine di ', '')}';
        return [
          'Scrivi su un foglio che cosa dipende da te$per e che cosa no. Oggi '
              'fai la cosa più piccola della prima colonna, senza aspettare '
              'segnali.',
          'Scrivi che cosa dipende da te$per e fanne oggi la parte più '
              'piccola.',
        ];
      case FormaDellaDomanda.quando:
        return [
          'Smetti di contare i giorni: scegli una cosa ferma che dipende da '
              'te e falla muovere oggi di un passo, anche minimo.',
          'Scegli una cosa ferma che dipende da te e muovila oggi di un '
              'passo.',
        ];
      case FormaDellaDomanda.sentimenti:
        final chi = p ?? 'l\'altra persona';
        return [
          'Per una settimana guarda i gesti ${con('di', chi)} più delle '
              'parole e annota ciò che vedi, senza interpretarlo. Se hai una '
              'domanda, falla direttamente ${con('a', chi)}, con calma.',
          'Guarda i gesti ${con('di', chi)} più delle parole e, se hai una '
              'domanda, falla ${con('a', chi)} con calma.',
        ];
      case FormaDellaDomanda.fiducia:
        final chi = p ?? 'questa persona';
        return [
          'Per una settimana annota ciò che $chi dice e ciò che poi fa, senza '
              'commentarlo. Alla fine confronta le due colonne: la fiducia si '
              'costruisce lì, non nelle carte.',
          'Annota per una settimana ciò che $chi dice e ciò che fa, poi '
              'confronta le due colonne.',
        ];
      case FormaDellaDomanda.ritorno:
        return [
          'Non scrivere per ottenere una risposta e non cercare segni nei '
              'suoi silenzi. Oggi scrivi per te, su un foglio che tieni, che '
              'cosa è accaduto e che cosa vuoi adesso per la tua vita.',
          'Non cercare segni nei suoi silenzi: scrivi per te, su un foglio '
              'che tieni, che cosa vuoi adesso.',
        ];
      case FormaDellaDomanda.scelta:
        // Il gesto nomina le due strade della domanda: due domande diverse
        // non ricevono lo stesso "Cosa fare" (difetto D2).
        final strade = q.alternative != null
            ? 'Scrivi su due colonne ${q.alternative!.$1} e '
                '${q.alternative!.$2}'
            : q.gruppo != null
                ? 'Scrivi su due colonne ${q.gruppo}'
                : 'Scrivi le due strade su due colonne';
        return [
          '$strade: sotto ciascuna metti che cosa ti costa e che cosa ti dà. '
              'Decidi domani, a mente fresca, non stasera.',
          '$strade, con costi e vantaggi: decidi domani.',
          'Metti le due strade su due colonne con costi e vantaggi: decidi '
              'domani.',
        ];
      case FormaDellaDomanda.decisione:
        // Il gesto nomina l'azione che la persona sta pesando (D2).
        final se = q.clausola == null ? '' : ' se ${q.clausola}';
        return [
          'Prima di decidere$se scrivi tre fatti a favore e tre contro, senza '
              'supposizioni. Domani rileggili: se la condizione resta vera, '
              'muovi un primo passo piccolo che puoi ancora correggere.',
          'Prima di decidere$se scrivi tre fatti a favore e tre contro: '
              'domani rileggili e muovi solo un passo che puoi correggere.',
          'Scrivi tre fatti a favore e tre contro, rileggili domani e muovi '
              'solo un primo passo che puoi ancora correggere.',
        ];
      case FormaDellaDomanda.come:
        if (q.evento && o != null) {
          return [
            'Prepara per iscritto come vuoi stare ${con('a', o)}: che cosa '
                'porti, quali argomenti eviti e dove ti fermi se la tensione '
                'sale.',
            'Prepara per iscritto come vuoi stare ${con('a', o)} e dove ti '
                'fermi se la tensione sale.',
          ];
        }
        if (p != null) {
          return [
            'Scegli un momento tranquillo e di\' ${con('a', p)} una cosa '
                'sola, vera e senza rimprovero. Poi ascolta la risposta fino '
                'in fondo, senza interrompere.',
            'Di\' ${con('a', p)} una cosa sola, vera e senza rimprovero, poi '
                'ascolta fino in fondo.',
          ];
        }
        final per = q.infinito == null ? '' : ' per ${q.infinito}';
        return [
          'Scegli oggi un primo gesto concreto$per: scrivilo, decidi quando '
              'farlo e fallo entro la settimana. Poi guarda che cosa è '
              'cambiato e scegli il passo seguente.',
          'Scegli oggi un primo gesto concreto$per: scrivilo, decidi quando '
              'farlo e fallo entro la settimana.',
          'Scegli un primo gesto concreto e fallo entro la settimana.',
        ];
      case FormaDellaDomanda.generica:
        return [
          'Scegli oggi un gesto concreto che risponda alla tua domanda: '
              'scrivilo su un foglio, decidi quando farlo e fallo prima di '
              'sera. Se dopo il gesto la domanda resta aperta, rifalla più '
              'precisa.',
          'Scegli oggi un gesto concreto che risponda alla tua domanda: '
              'scrivilo e fallo prima di sera.',
          'Scegli un gesto concreto e fallo prima di sera.',
        ];
    }
  }

  /// Il legame fra il gesto e l'angelo del Custode: il suo dono dove la prima
  /// frase ha detto la via, la via dove ha detto il dono, perche' i due
  /// paragrafi non ripetano la stessa cosa.
  static List<String> _legame(
      LaDomandaDellOracolo q, String c, String dC, String vC) {
    if (q.limite != null) {
      return [
        'Su ciò che è tuo $c ti accompagna con $dC.',
        '$c ti accompagna con $dC.',
        '',
      ];
    }
    switch (q.forma) {
      case FormaDellaDomanda.aperta:
        return [
          'Intanto, per oggi, $c ti indica una via: $vC.',
          'Intanto la via di $c è $vC.',
          '',
        ];
      case FormaDellaDomanda.futuro:
        return [
          'Intanto porta nella tua giornata $dC, il dono di $c.',
          'Intanto tieni con te $dC.',
          '',
        ];
      case FormaDellaDomanda.fiducia:
        return [
          'Su ciò che dipende da te, $c ti porta $dC.',
          '$c ti porta $dC.',
          '',
        ];
      case FormaDellaDomanda.sentimenti:
        return [
          'Su ciò che dipende da te, la via di $c è $vC.',
          'La via di $c, per te, è $vC.',
          '',
        ];
      case FormaDellaDomanda.ritorno:
        // Niente via del Custode qui: sotto "tornerà?" una via sui legami
        // si leggerebbe come un invito a cercare l'altra persona (difetto D8
        // del lettore cieco).
        return [
          'Il resto appartiene alla sua scelta, non alla tua.',
          'La sua scelta è sua.',
          '',
        ];
      case FormaDellaDomanda.generica:
      case FormaDellaDomanda.esito:
      case FormaDellaDomanda.quando:
      case FormaDellaDomanda.scelta:
      case FormaDellaDomanda.decisione:
      case FormaDellaDomanda.come:
        return [
          'È il gesto che $c lega ${con('a', dC)}.',
          'Fallo con $dC, il dono di $c.',
          '',
        ];
    }
  }

  static const List<String> _riempitiviDelGesto = [
    '',
    'Basta un passo.',
    'Non serve fare tutto oggi.',
    'Un passo piccolo vale più di un grande proposito.',
    'Un passo piccolo e fatto vale più di un grande proposito rimandato.',
  ];

  // --- il titolo ------------------------------------------------------------

  static String _titolo(
      LaDomandaDellOracolo q, String c, String dC, String vC) {
    final o = q.oggetto;
    final p = q.persona;
    String t;
    switch (q.limite) {
      case LimiteDellaDomanda.salute:
        t = 'Sull\'esito ti risponde il medico, non le carte';
      case LimiteDellaDomanda.legge:
        t = 'Sulla questione legale ti guida l\'avvocato, non le carte';
      case LimiteDellaDomanda.denaro:
        t = 'Sul denaro decidi con un consulente, non con le carte';
      case null:
        t = switch (q.forma) {
          FormaDellaDomanda.aperta => '$c risponde con $dC',
          FormaDellaDomanda.futuro => q.tuttoBene
              ? 'Nessuna carta lo promette: conta il passo che fai oggi'
              : 'Ciò che ti aspetta non è scritto: oggi conta un tuo passo',
          FormaDellaDomanda.esito => o == null
              ? 'L\'esito non è scritto: conta ciò che fai tu'
              : '${_maiuscola(o)}: l\'esito non è scritto, conta ciò che fai '
                  'tu',
          FormaDellaDomanda.sentimenti => p == null || p.contains(' ')
              ? 'Ciò che prova un\'altra persona non si legge nelle carte'
              : 'Ciò che sente $p lo dice $p, non le carte',
          FormaDellaDomanda.fiducia =>
            'La fiducia si misura sui gesti, non sulle carte',
          FormaDellaDomanda.ritorno =>
            'Un ritorno non si legge: torna a ciò che vuoi tu',
          FormaDellaDomanda.quando =>
            'Nessuna data: conta il passo che fai adesso',
          FormaDellaDomanda.scelta => q.alternative != null
              ? 'Fra ${q.alternative!.$1} e ${q.alternative!.$2}: la strada '
                  'la indica $c'
              : q.gruppo != null
                  ? 'Fra ${q.gruppo}: la strada la indica $c'
                  : 'La strada giusta è quella che ti indica $c',
          // Il titolo nomina l'azione pesata, quando la domanda la dice:
          // due decisioni diverse non hanno lo stesso titolo.
          FormaDellaDomanda.decisione =>
            q.clausola != null && q.clausola!.length + c.length < 52
                ? '${_maiuscola(q.clausola!)}: sì, a una condizione di $c'
                : 'Sì, a una condizione che ti pone $c',
          // Il titolo nomina che cosa la persona vuole fare: due "come"
          // diversi non hanno lo stesso titolo.
          FormaDellaDomanda.come => [
              if (q.infinito != null) 'Per ${q.infinito}: $vC',
              if (q.infinito != null) 'Per ${q.infinito}: la via di $c',
              if (q.oggetto != null) 'Per ${q.oggetto}: la via di $c',
              'La via di $c: $vC',
            ].firstWhere((x) => x.length <= 80,
                orElse: () => 'La via te la indica $c'),
          FormaDellaDomanda.generica => '$c ti indica $dC',
        };
    }
    // Le due domande in una: il titolo risponde alla prima, e la risposta
    // dice subito dopo la prima frase che la seconda chiede un'altra
    // consultazione.
    if (t.length > 80) {
      t = switch (q.forma) {
        FormaDellaDomanda.come => 'La via te la indica $c',
        FormaDellaDomanda.scelta =>
          'La strada giusta è quella che ti indica $c',
        FormaDellaDomanda.decisione => 'Sì, a una condizione che ti pone $c',
        FormaDellaDomanda.sentimenti =>
          'Ciò che prova un\'altra persona non si legge nelle carte',
        FormaDellaDomanda.aperta ||
        FormaDellaDomanda.generica =>
          '$c risponde con il suo dono',
        _ => 'L\'esito non è scritto: conta ciò che fai tu',
      };
    }
    return _maiuscola(t);
  }
}
