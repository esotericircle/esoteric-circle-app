import '../domande/domande_del_cerchio.dart';
import '../responsi/la_forma_del_responso.dart';
import 'il_presagio_dal_corpus.dart';
import 'rune_cast.dart';

/// **LA RISPOSTA DIRETTA DELLA GETTATA. Ordine GA voce GA.06, la cura delle
/// Rune di Caligo, 21 ottobre 2026.**
///
/// Il fondatore, 19 ottobre 2026 alle 23:08: *"IMPORTANTE: risposte dirette
/// immediatamente, l'utente deve avere subito e sempre risposte senza
/// fronzoli o criptiche o includenti o sibilline. L'utente deve avere una
/// risposta o una guida, deve sapere cosa fare o non fare [...] E ogni
/// risposta deve essere coerente con i simboli o carte o segni altro da
/// interpretare e coerente con la domanda posta dall'utente."*
///
/// **IL DIFETTO, MISURATO DAI LETTORI CIECHI** (docs/collaudo/GA/
/// lettori_ciechi/esiti/esito_tre_domande_rune.md, sul commit 1804c7d7): la
/// prima frase rispondeva alla domanda in 6 responsi su 40, il "Cosa fare"
/// era pertinente in 7 su 40, il responso coerente con pietre e domanda in
/// 13 su 40. La causa e' di sistema, non di un testo: il paragrafo della
/// risposta era RISPOSTA (per la sola pietra che decide) piu' VERDETTO (per
/// il tono e la famiglia), il riquadro era GESTO (per la sola pietra): **nessun
/// pezzo dipendeva dalla domanda**, salvo lo spazio `{cosa}`. Il VERDETTO,
/// scritto per una famiglia di otto rune, parlava di rune che non c'erano
/// ("la gettata intera parla di maturazione" con la sola Eihwaz) e contava
/// pietre sbagliate ("la gettata e' tutta dritta" con una pietra sola, "le
/// pietre rovesciate" con una sola in ombra). Le domande a trabocchetto
/// (salute, legge, denaro, i pensieri di un altro, le domande doppie)
/// ricevevano lo stesso testo di tutte le altre.
///
/// **LA CURA.** Qui la domanda si LEGGE ([LaDomandaLetta]: che tipo di
/// domanda e', di che cosa parla, se tocca salute, legge o denaro, se e'
/// doppia) e le pietre si leggono nella loro posizione e nel loro verso
/// ([LaPietraLetta], una per runa e verso, dai significati di
/// `lib/core/rituals/runes.dart` e dei poemi runici). Da tutte e due nasce:
/// - la PRIMA FRASE, che risponde: un verdetto ("Si'", "Non ancora", "Non
///   adesso", "Non cosi'") per chi chiede se fare una cosa, un criterio per
///   chi sceglie fra due strade, un modo per chi chiede come, e il limite
///   delle rune detto per primo per chi chiede l'esito, una data, i pensieri
///   di un altro, o tocca salute, legge e denaro;
/// - la frase sul TONO della gettata, contata sulle pietre vere e nelle loro
///   posizioni, al posto del VERDETTO;
/// - il riquadro "Cosa fare adesso", scritto per la domanda e per il modo
///   della pietra che decide, al posto del GESTO (che resta per chi getta
///   senza domanda: li' il gesto della giornata e' la risposta giusta);
/// - il TITOLO della scheda di ogni pietra, che legge la sua posizione (una
///   pietra nell'Ostacolo si legge dal suo lato difficile, mai come favore).
///
/// Il resto resta del corpus: la RISPOSTA della pietra che decide segue la
/// prima frase e la spiega, il LEGAME approfondisce nella Lunga, PIETRA e
/// CONSIGLIO fanno le schede. Nessun testo e' troncato (voce GA.07): ogni
/// paragrafo si compone scegliendo fra forme intere quella che sta fra 40 e
/// 50 parole, e la prova `la_risposta_della_gettata_test.dart` le misura
/// tutte.

/// Che domanda e', per come si risponde.
enum TipoDiDomanda {
  /// Nessuna domanda: la lettura parla della giornata.
  giornata,

  /// "Devo...?", "Posso...?", "Ha senso...?": si risponde si', no o non
  /// ancora.
  decisione,

  /// "X o Y?", "Quale fra le due?": si risponde con un criterio di scelta.
  scelta,

  /// "Come...?", "Quale passo...?": si risponde con un modo.
  come,

  /// "Quando...?": le rune non danno date.
  quando,

  /// "Passero'...?", "Andra' bene...?", "Verra' approvato?": le rune non
  /// predicono l'esito.
  previsione,

  /// "Che cosa prova lui?", "Tornera' da me?": le rune non leggono il cuore
  /// di un altro.
  altrui,

  /// "Andra' tutto bene?": le rune non promettono che vada tutto bene.
  tuttoBene,

  /// "Che cosa mi aspetta?": le rune non mostrano un futuro gia' scritto.
  futuro,

  /// Tutte le altre: "Cosa devo sapere sul mio momento?", "Dimmi qualcosa".
  aperta,
}

/// I tre ambiti in cui le rune non consigliano (ordine S voce 17) e il
/// responso rimanda a chi e' competente.
enum AmbitoDelicato { salute, legge, denaro }

/// **LA DOMANDA LETTA.** Il tipo, il tema (con l'articolo, lo stesso valore
/// di `{cosa}`), l'ambito delicato, la cosa da fare ripresa dalle parole di
/// chi chiede quando la domanda e' "Devo + infinito", le due strade quando
/// e' "Devo X o Y", il tema della seconda domanda quando sono due.
class LaDomandaLetta {
  const LaDomandaLetta({
    required this.tipo,
    required this.tema,
    this.delicato,
    this.azione,
    this.strade,
    this.seconda,
    this.chiude = false,
  });

  final TipoDiDomanda tipo;
  final String tema;
  final AmbitoDelicato? delicato;

  /// Vero quando la decisione e' di chiudere, lasciare, smettere: una pietra
  /// del legame (Gebo, Wunjo, Ehwaz, Mannaz, Othala dritte) a "Devo chiudere
  /// l'amicizia?" non risponde si'. I lettori ciechi: *"Gebo dritta
  /// risponde di sì" alla domanda "Devo chiudere l'amicizia con Giulia?"*.
  final bool chiude;

  /// "accettare l'offerta della nuova azienda", con le persone girate
  /// ("mio" diventa "tuo"): solo per le decisioni, solo quando si legge bene.
  final String? azione;

  /// Le due strade di una scelta, girate come [azione].
  final List<String>? strade;

  /// Il tema della seconda domanda, quando la domanda e' doppia.
  final String? seconda;

  bool get doppia => seconda != null;

  /// **IL LETTORE.** Le regole sono scritte sulle forme della lingua, non su
  /// un elenco di domande: le domande dei lettori ciechi sono una prova, non
  /// la misura (`test/la_risposta_della_gettata_test.dart` ne porta altre,
  /// scritte diversamente).
  static LaDomandaLetta di(String domanda) {
    final originale = domanda.trim();
    final d = normalizza(originale);
    if (d.isEmpty) {
      return const LaDomandaLetta(
          tipo: TipoDiDomanda.giornata, tema: 'la tua giornata');
    }
    final tema = IlPresagioDalCorpus.cosaDellaDomanda(originale);
    final delicato = ambitoDelicato(d);
    // Le domande del Cerchio hanno il loro tipo, scritto qui: sono dodici e
    // non cambiano senza che cambi questo file (la prova lo controlla).
    final delCerchio = _tipoDelCerchio[d];
    if (delCerchio != null) {
      return LaDomandaLetta(tipo: delCerchio, tema: tema, delicato: delicato);
    }
    final parti = _dividi(originale);
    if (parti != null) {
      final prima = di(parti.$1);
      final seconda = IlPresagioDalCorpus.cosaDellaDomanda(parti.$2);
      return LaDomandaLetta(
        tipo: prima.tipo == TipoDiDomanda.giornata
            ? TipoDiDomanda.aperta
            : prima.tipo,
        // "Devo lasciarlo, e lui soffrirà?": la prima parte non dice di
        // che cosa parla, la domanda intera si'.
        tema: prima.tema == 'ciò che hai chiesto' ? tema : prima.tema,
        delicato: delicato ?? prima.delicato,
        azione: prima.azione,
        strade: prima.strade,
        seconda: seconda,
        chiude: prima.chiude,
      );
    }
    final tipo = _tipo(d);
    return LaDomandaLetta(
      tipo: tipo,
      tema: tema,
      delicato: delicato,
      azione: tipo == TipoDiDomanda.decisione ? _azione(originale) : null,
      strade: tipo == TipoDiDomanda.scelta ? _strade(originale) : null,
      chiude: tipo == TipoDiDomanda.decisione && _chiusura.hasMatch(d),
    );
  }

  static final RegExp _chiusura = RegExp(
      r"^(devo|dovrei|posso|potrei|conviene|mi conviene|è giusto|e' giusto|"
      r'ha senso|vale la pena( di)?|è il momento (giusto )?(per|di)|è ora di)'
      r' (chiudere|lasciare|smettere|rompere|interrompere|troncare|mollare|'
      r'abbandonare|andarmene|licenziarmi|separarmi|divorziare|tagliare|'
      r'rinunciare|dimettermi|allontanarmi|staccarmi|chiuderla|chiuderlo|'
      r'lasciarlo|lasciarla)(?![a-zà-ÿ])');

  /// Minuscole, apostrofi dritti, spazi semplici, senza la punteggiatura in
  /// fondo.
  static String normalizza(String testo) => testo
      .toLowerCase()
      .replaceAll('’', "'")
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim()
      .replaceAll(RegExp(r'[?.!…]+$'), '')
      .trim();

  /// I confini di parola scritti a mano: in Dart `\b` non vede le lettere
  /// accentate (memoria "Dart: \b non vede gli accenti").
  /// Anche `\w` in Dart vede le sole lettere ASCII: "tornerà" non e'
  /// "torner\w*". Qui `\w` diventa la classe con le accentate.
  static RegExp parola(String alternative) =>
      RegExp('(?<![a-zà-ÿ])(?:${alternative.replaceAll(r'\w', '[a-zà-ÿ]')})'
          '(?![a-zà-ÿ])');

  static final RegExp _salute = parola(
      r"operazion\w*|operar\w*|intervent[oi] (chirurgic\w*|al|alla|allo|agli|"
      r'alle)|chirurg\w*|medic[oi]|medicin\w*|'
      r'malatt\w*|'
      r'salute|terapi\w*|diagnos\w*|ospedal\w*|guari\w*|sintom\w*|farmac\w*|'
      r'gravidanz\w*|incinta|tumor\w*|dottor\w*|ginocchi\w*|'
      r'esami (del sangue|clinici)|analisi del sangue|visita medica');
  static final RegExp _legge = parola(
      r'causa|cause legali|tribunal\w*|avvocat\w*|giudice|giudici|processo|'
      r'denunc\w*|querel\w*|sentenz\w*|ricors[oi]|divorzi\w*|separazione|'
      r'affidamento|risarciment\w*');
  static final RegExp _denaro = parola(
      r'soldi|denaro|risparmi\w*|investi\w*|borsa|azioni|cripto\w*|bitcoin|'
      r'mutu[oi]|prestit\w*|debit\w*|finanz\w*|stipend\w*|eredit\w*|'
      r'compr\w* (casa|una casa|la casa|un appartamento)|'
      r'acquist\w* (casa|una casa|la casa|un appartamento)');

  /// L'ambito delicato di una domanda gia' normalizzata. Il denaro prima
  /// della salute: "un'operazione in borsa" e' denaro. "Causa" vale solo
  /// come sostantivo della legge, non in "a causa di".
  static AmbitoDelicato? ambitoDelicato(String d) {
    if (_denaro.hasMatch(d)) return AmbitoDelicato.denaro;
    final senzaACausa = d.replaceAll(parola(r'a causa d\w*'), ' ');
    if (_legge.hasMatch(senzaACausa)) return AmbitoDelicato.legge;
    if (_salute.hasMatch(d)) return AmbitoDelicato.salute;
    return null;
  }

  static final Map<String, TipoDiDomanda> _tipoDelCerchio = () {
    final come = {
      'nel lavoro, quale passo fare',
      'una scelta mi blocca: cosa la scioglie',
      'il mio archetipo: quale passo mi somiglia',
    };
    return {
      for (final q in [
        ...DomandeDelCerchio.generichePerLaGettata,
        ...DomandeDelCerchio.personaliPerLaGettata,
      ])
        normalizza(q.testo): come.contains(normalizza(q.testo))
            ? TipoDiDomanda.come
            : TipoDiDomanda.aperta,
    };
  }();

  static final RegExp _altrui =
      parola(r"(che )?cosa (prova|pensa|sente|vuole|provi)|"
          r'mi (ama|pensa|vuole|tradisce|cerca|ha dimenticat\w*)|'
          r'(ri)?torner\w* da me|fidarmi|mi è fedele|è sincer\w*|mi mente|'
          r'prova per me|pensa di me');
  static final RegExp _futuroVerbo =
      RegExp(r"(?<![a-zà-ÿ])[a-zà-ÿ]{2,}(rò|rà|remo|ranno)(?![a-zà-ÿ])|"
          r'(?<![a-zà-ÿ])può (durare|funzionare|andare|cambiare)(?![a-zà-ÿ])');
  static final RegExp _decisione = RegExp(
      r"^(devo|dovrei|posso|potrei|conviene|mi conviene|è giusto|e' giusto|"
      r"è il momento|e' il momento|è ora|ha senso|vale la pena|faccio bene|"
      r'è meglio|sarebbe meglio|meglio|accetto|lascio|cambio|dico|provo|'
      r'torno|resto|chiudo|chiamo|scrivo)(?![a-zà-ÿ])');

  static final RegExp _tuttoBene =
      RegExp(r'^andr[àa] (tutto |tutto quanto )?bene$');
  static final RegExp _futuro =
      RegExp(r"^((che )?cosa mi (aspetta|riserva|succederà|accadrà)|"
          r'che ne sarà di me|cosa succederà|cosa accadrà)');
  static final RegExp _dimmi =
      RegExp(r'^(dimmi|parlami|cosa vedi|che cosa vedi|che mi dici)');

  /// Vero per le domande che non dicono di che cosa parlano: "Andrà tutto
  /// bene?", "Che cosa mi aspetta?", "Dimmi qualcosa". Il loro tema e' "il
  /// tuo momento".
  static bool eVaga(String d) =>
      _tuttoBene.hasMatch(d) || _futuro.hasMatch(d) || _dimmi.hasMatch(d);

  /// Vero per le domande sui pensieri o sui passi di un'altra persona.
  static bool parlaDiUnAltro(String d) => _altrui.hasMatch(d);

  static TipoDiDomanda _tipo(String d) {
    if (_tuttoBene.hasMatch(d)) return TipoDiDomanda.tuttoBene;
    if (_futuro.hasMatch(d)) return TipoDiDomanda.futuro;
    if (_altrui.hasMatch(d)) return TipoDiDomanda.altrui;
    if (d.startsWith('quando ')) return TipoDiDomanda.quando;
    final scelta = RegExp(r'^quale .*(tra|fra) ').hasMatch(d) ||
        parola(r'(tra|fra) (i|le) due').hasMatch(d) ||
        (parola('o|oppure').hasMatch(d) &&
            (_decisione.hasMatch(d) || RegExp(r'^[a-zà-ÿ]+o ').hasMatch(d)));
    if (scelta) return TipoDiDomanda.scelta;
    if (RegExp(r'(^|[,:;] ?)come ').hasMatch(d) &&
        !RegExp(r'(^|[,:;] ?)come (andr[àa]|finir[àa])').hasMatch(d)) {
      return TipoDiDomanda.come;
    }
    if (_decisione.hasMatch(d)) return TipoDiDomanda.decisione;
    if (_futuroVerbo.hasMatch(d)) return TipoDiDomanda.previsione;
    return TipoDiDomanda.aperta;
  }

  /// **LA DOMANDA DOPPIA**: due punti interrogativi, "e se...", "e" davanti
  /// a un verbo al futuro o a un nuovo soggetto. La prima parte e' quella a
  /// cui la gettata risponde.
  static (String, String)? _dividi(String originale) {
    final t = originale.trim();
    final domande = t.indexOf('?');
    if (domande > 0 && domande < t.length - 1) {
      final resto = t.substring(domande + 1).trim();
      if (resto.replaceAll(RegExp(r'[?.!\s]'), '').length > 3) {
        return (t.substring(0, domande + 1), resto);
      }
    }
    final regole = [
      RegExp(r',?\s+e\s+se\s+', caseSensitive: false),
      RegExp(r',?\s+e\s+(?=\S+(rò|rà|ranno|remo)(?![a-zà-ÿ]))',
          caseSensitive: false),
      RegExp(r',\s+e\s+(?=(devo|posso|lui|lei|mi|la mia|il mio)\s)',
          caseSensitive: false),
    ];
    for (final r in regole) {
      final m = r.firstMatch(t);
      if (m != null && m.start > 6) {
        final prima = t.substring(0, m.start).trim();
        final seconda = t.substring(m.end).trim();
        if (prima.split(' ').length >= 2 && seconda.split(' ').length >= 2) {
          return ('$prima?', seconda);
        }
      }
    }
    return null;
  }

  static final RegExp _apertura = RegExp(
      r"^(devo|dovrei|posso|potrei|conviene|mi conviene|è giusto|e' giusto|"
      r"ha senso|vale la pena( di)?|è il momento giusto (per|di)|"
      r"è il momento (per|di)|è ora di)\s+(.+)$",
      caseSensitive: false);

  static final RegExp _infinito = RegExp(
      r"^[a-zà-ÿ]+((are|ere|ire|rre)|(ar|er|ir|rr)(mi|ti|si|ci|vi|lo|la|li|le|"
      r'gli|glielo|gliela|ne))$',
      caseSensitive: false);

  /// Le persone girate: chi chiede diventa "tu".
  static const Map<String, String> _persone = {
    'mio': 'tuo', 'mia': 'tua', 'miei': 'tuoi', 'mie': 'tue', //
    'me': 'te', 'mi': 'ti', 'io': 'tu', 'sono': 'sei', 'ho': 'hai',
    'faccio': 'fai', 'posso': 'puoi', 'devo': 'devi', 'voglio': 'vuoi',
    'so': 'sai', 'sto': 'stai', 'vado': 'vai', 'lo faccio': 'lo fai',
  };

  static String? _gira(String testo) {
    final parole =
        testo.replaceAll(RegExp(r'[?.!]+$'), '').trim().split(RegExp(r'\s+'));
    if (parole.isEmpty || parole.length > 9) return null;
    if (!_infinito.hasMatch(parole.first)) return null;
    final fuori = <String>[];
    for (var i = 0; i < parole.length; i++) {
      var p = parole[i];
      final basso = p.toLowerCase();
      final girata = _persone[basso];
      if (girata != null) {
        p = p[0] == p[0].toUpperCase() && p[0] != p[0].toLowerCase()
            ? '${girata[0].toUpperCase()}${girata.substring(1)}'
            : girata;
      } else if (i == 0 && RegExp(r'(ar|er|ir|rr)mi$').hasMatch(basso)) {
        p = '${p.substring(0, p.length - 2)}ti';
      }
      fuori.add(p);
    }
    final testoGirato = fuori.join(' ');
    // Una prima persona rimasta (un verbo che il giro non conosce) e' un
    // testo che si leggerebbe male: allora si risponde col tema.
    if (RegExp(r'(?<![a-zà-ÿ])(io|mio|mia|miei|mie)(?![a-zà-ÿ])')
        .hasMatch(testoGirato.toLowerCase())) {
      return null;
    }
    return testoGirato;
  }

  static String? _azione(String originale) {
    final m = _apertura.firstMatch(originale.trim().replaceAll('’', "'"));
    if (m == null) return null;
    return _gira(m.group(m.groupCount)!);
  }

  static List<String>? _strade(String originale) {
    var t = originale
        .trim()
        .replaceAll('’', "'")
        .replaceAll(RegExp(r'[?.!]+$'), '');
    t = t.replaceFirst(
        RegExp(r'^(devo|dovrei|posso|meglio|è meglio)\s+',
            caseSensitive: false),
        '');
    final pezzi = t.split(RegExp(r'\s+(o|oppure)\s+'));
    if (pezzi.length != 2) return null;
    final a = _gira(pezzi[0]);
    final b = _gira(pezzi[1]);
    if (a == null || b == null) return null;
    return [a, b];
  }
}

/// La classe del verdetto di una pietra, dal suo significato nel suo verso.
enum ClasseDellaPietra {
  /// La via e' aperta: si'.
  via,

  /// Si', con cautela e con le tutele.
  prudenza,

  /// Non ancora: il tempo matura.
  attesa,

  /// Non adesso: fermarsi, non forzare.
  sosta,

  /// Non cosi': prima va corretto qualcosa.
  correggi,
}

/// **UNA PIETRA LETTA**, per runa e verso. I testi vengono dal significato
/// documentato della runa nel suo verso (`kElderFuthark` in
/// `lib/core/rituals/runes.dart`: la parola chiave, il significato, la riga
/// dritta e la riga d'ombra, scritte dai poemi runici di `docs/corpus/
/// rune.md`), e ne dicono cinque usi:
/// - [senso], cio' che la pietra indica, con l'articolo;
/// - [modo], come si agisce, al gerundio o con "con";
/// - [criterio], il corpo di una relativa ("la strada che ..."), per le
///   scelte;
/// - [nonFare], la frase intera di cio' che non si fa;
/// - [animo], l'atteggiamento interiore, l'unico che si legge quando la
///   domanda tocca salute, legge o denaro: non dice niente dell'esito.
/// [lato] e' il lato difficile di una runa simmetrica, quando cade
/// nell'Ostacolo (le altre ci cadono col senso del loro verso d'ombra).
class LaPietraLetta {
  const LaPietraLetta({
    required this.classe,
    required this.senso,
    required this.modo,
    required this.criterio,
    required this.nonFare,
    required this.animo,
    this.verdetto,
    this.lato,
    this.seChiudi,
    this.verdettoSeChiudi,
  });

  /// Come risponde la pietra a chi chiede se chiudere o lasciare, quando non
  /// risponde come a tutte le altre decisioni: le pietre del legame
  /// trattengono, quelle che sciolgono (Hagalaz, Fehu e Othala in ombra)
  /// lasciano andare.
  final ClasseDellaPietra? seChiudi;
  final String? verdettoSeChiudi;

  final ClasseDellaPietra classe;
  final String senso;
  final String modo;
  final String criterio;
  final String nonFare;
  final String animo;

  /// Un verdetto proprio della runa, quando quello della classe direbbe meno
  /// ("Si', se tieni duro" per Eihwaz).
  final String? verdetto;
  final String? lato;

  static String chiave(String runa, bool inOmbra) =>
      '$runa/${inOmbra ? 'ombra' : 'dritta'}';

  static LaPietraLetta di(RunaGettata p) =>
      tutte[chiave(p.rune.name, p.inOmbra)]!;

  /// **IL LATO DIFFICILE DI UNA PIETRA**, come si legge nell'Ostacolo: il
  /// senso del suo verso d'ombra, o il lato scritto per le simmetriche, o il
  /// senso stesso se e' gia' in ombra.
  static String latoDifficile(RunaGettata p) {
    if (p.inOmbra) return di(p).senso;
    final propria = di(p).lato;
    if (propria != null) return propria;
    return tutte[chiave(p.rune.name, true)]!.senso;
  }

  /// Le quaranta pietre: ventiquattro dritte e sedici in ombra (le otto
  /// simmetriche non escono mai in ombra).
  static const Map<String, LaPietraLetta> tutte = {
    // Fehu: "Fai muovere ciò che hai: fermo si consuma." / "Apri la mano:
    // ciò che trattieni troppo si perde."
    'Fehu/dritta': LaPietraLetta(
        classe: ClasseDellaPietra.via,
        senso: 'un bene che cresce quando circola',
        modo: 'mettendo in circolo ciò che hai già',
        criterio: 'fa fruttare ciò che hai già',
        nonFare: 'Non tenere fermo per paura ciò che può circolare.',
        animo: 'conta sulle risorse che hai già e falle lavorare'),
    'Fehu/ombra': LaPietraLetta(
        classe: ClasseDellaPietra.correggi,
        senso: 'un bene che si disperde',
        modo: 'chiudendo prima le perdite che non vedi',
        criterio: 'non ti fa disperdere ciò che hai',
        nonFare: 'Non stringere ciò che hai fino a perderlo.',
        animo:
            'allenta la presa sulle preoccupazioni e tieni solo ciò che serve',
        seChiudi: ClasseDellaPietra.via),
    // Uruz: "Hai la forza per rialzarti: usala adesso." / "Ritrova il ritmo
    // prima di caricare di nuovo."
    'Uruz/dritta': LaPietraLetta(
        classe: ClasseDellaPietra.via,
        senso: 'la forza che hai già',
        modo: 'usando adesso la forza che hai',
        criterio: 'chiede la tua forza invece della tua paura',
        nonFare: 'Non aspettare di sentirti all’altezza per muoverti.',
        animo: 'riconosci la forza che hai e usala con misura'),
    'Uruz/ombra': LaPietraLetta(
        classe: ClasseDellaPietra.attesa,
        senso: 'una forza da ritrovare prima di caricare',
        modo: 'ritrovando il ritmo prima di caricare',
        criterio: 'non ti costringe a forzare',
        nonFare: 'Non caricare a testa bassa prima di aver ritrovato il ritmo.',
        animo: 'ritrova il tuo ritmo prima di ogni sforzo'),
    // Thurisaz: "Dirigi la forza con misura, senza temerla." / "Fermati un
    // istante: qui la fretta ferisce."
    'Thurisaz/dritta': LaPietraLetta(
        classe: ClasseDellaPietra.prudenza,
        verdetto: 'Sì, ma con misura',
        senso: 'una forza che difende il confine',
        modo: 'difendendo il tuo confine con misura',
        criterio: 'ti lascia difendere ciò che conta senza ferire',
        nonFare: 'Non reagire d’impulso a chi ti mette alla prova.',
        animo: 'difendi la tua calma con misura, senza irrigidirti'),
    'Thurisaz/ombra': LaPietraLetta(
        classe: ClasseDellaPietra.sosta,
        senso: 'una fretta che ferisce',
        modo: 'fermandoti un istante prima di reagire',
        criterio: 'non ti chiede risposte di fretta',
        nonFare: 'Non rispondere a caldo: qui la fretta ferisce.',
        animo: 'fermati un istante prima di ogni reazione'),
    // Ansuz: "Ascolta il segno: una voce ti raggiunge." / "Ascolta meglio
    // prima di dar peso a ciò che senti."
    'Ansuz/dritta': LaPietraLetta(
        classe: ClasseDellaPietra.via,
        senso: 'una parola che chiarisce',
        modo: 'con una parola chiara, detta a voce',
        criterio: 'ti permette di parlare chiaro',
        nonFare: 'Non lasciare che il silenzio parli al posto tuo.',
        animo: 'chiedi spiegazioni chiare e annota le risposte',
        seChiudi: ClasseDellaPietra.correggi,
        verdettoSeChiudi: 'Non prima di averne parlato'),
    'Ansuz/ombra': LaPietraLetta(
        classe: ClasseDellaPietra.attesa,
        verdetto: 'Non prima di una verifica',
        senso: 'parole che possono confondere',
        modo: 'verificando ciò che senti prima di crederci',
        criterio: 'poggia su fatti e non su voci',
        nonFare: 'Non dare peso a voci e mezze frasi.',
        animo: 'verifica ciò che senti prima di dargli peso'),
    // Raidho: "Muoviti con la tua cadenza, dentro e fuori." / "Rallenta:
    // ritrovata la cadenza, la strada si spiana."
    'Raidho/dritta': LaPietraLetta(
        classe: ClasseDellaPietra.via,
        senso: 'il passo giusto, con la tua cadenza',
        modo: 'un passo alla volta, con la tua cadenza',
        criterio: 'ti permette di tenere il tuo passo',
        nonFare: 'Non correre per stare al passo degli altri.',
        animo: 'procedi con la tua cadenza, senza fretta'),
    'Raidho/ombra': LaPietraLetta(
        classe: ClasseDellaPietra.correggi,
        senso: 'un cammino che ha perso la cadenza',
        modo: 'rallentando finché ritrovi la cadenza',
        criterio: 'non ti costringe a correre',
        nonFare: 'Non forzare la tabella di marcia.',
        animo: 'rallenta e ritrova la tua cadenza'),
    // Kenaz: "Una luce si accende dove prima era buio." / "La fiamma c'è:
    // dalle tempo di prendere."
    'Kenaz/dritta': LaPietraLetta(
        classe: ClasseDellaPietra.via,
        senso: 'una luce che rischiara ciò che era buio',
        modo: 'portando luce su ciò che non è chiaro',
        criterio: 'ti accende di più',
        nonFare: 'Non spegnere un’idea per timore del giudizio.',
        animo: 'cerca la chiarezza e fai domande precise'),
    'Kenaz/ombra': LaPietraLetta(
        classe: ClasseDellaPietra.attesa,
        senso: 'una fiamma che deve ancora prendere',
        modo: 'dando tempo alla fiamma di prendere',
        criterio: 'ti lascia il tempo di capire',
        nonFare: 'Non giudicare la fiamma dal primo fumo.',
        animo: 'concediti tempo prima di giudicare'),
    // Gebo: "Tieni in equilibrio ciò che dai con ciò che ricevi."
    'Gebo/dritta': LaPietraLetta(
        classe: ClasseDellaPietra.via,
        verdetto: 'Sì, se lo scambio resta pari',
        senso: 'uno scambio alla pari',
        modo: 'con uno scambio alla pari, dando e ricevendo',
        criterio: 'tiene in equilibrio ciò che dai e ciò che ricevi',
        nonFare: 'Non dare tutto senza chiedere niente in cambio.',
        animo: 'accetta l’aiuto che ti offrono e ricambialo con gratitudine',
        lato: 'uno scambio che pende da un lato',
        seChiudi: ClasseDellaPietra.correggi,
        verdettoSeChiudi: 'Non prima di aver riequilibrato lo scambio'),
    // Wunjo: "Un momento di pienezza vera: prendilo." / "Cura il legame: la
    // pienezza torna."
    'Wunjo/dritta': LaPietraLetta(
        classe: ClasseDellaPietra.via,
        senso: 'una gioia da condividere',
        modo: 'cercando ciò che unisce invece di ciò che divide',
        criterio: 'ti fa stare bene con le persone che contano',
        nonFare: 'Non rimandare la gioia a quando tutto sembrerà perfetto.',
        animo: 'cerca le persone che ti fanno stare bene',
        seChiudi: ClasseDellaPietra.sosta,
        verdettoSeChiudi: 'No, non adesso'),
    'Wunjo/ombra': LaPietraLetta(
        classe: ClasseDellaPietra.correggi,
        senso: 'una gioia che manca',
        modo: 'curando il legame che si è raffreddato',
        criterio: 'cura i legami invece di lasciarli raffreddare',
        nonFare: 'Non chiuderti nel malumore.',
        animo: 'cura i legami che ti sostengono',
        seChiudi: ClasseDellaPietra.correggi,
        verdettoSeChiudi: 'Non prima di aver curato il legame'),
    // Hagalaz: "Ciò che crolla libera spazio per il nuovo."
    'Hagalaz/dritta': LaPietraLetta(
        classe: ClasseDellaPietra.correggi,
        verdetto: 'Non su queste basi',
        senso: 'una rottura che libera spazio',
        modo: 'lasciando andare ciò che non regge più',
        criterio: 'ti libera di ciò che non regge più',
        nonFare: 'Non puntellare ciò che si è già incrinato.',
        animo: 'lascia passare l’agitazione senza trattenerla',
        lato: 'una scossa che ancora spaventa',
        seChiudi: ClasseDellaPietra.via,
        verdettoSeChiudi: 'Sì'),
    // Nauthiz: "Qui la pazienza è potere: aspetta con metodo." / "La prova
    // insegna: la pazienza è la chiave."
    'Nauthiz/dritta': LaPietraLetta(
        classe: ClasseDellaPietra.attesa,
        verdetto: 'Sì, ma con pazienza',
        senso: 'un bisogno che chiede pazienza',
        modo: 'con pazienza e con metodo',
        criterio: 'regge anche nei giorni di fatica',
        nonFare: 'Non cercare scorciatoie.',
        animo: 'affronta l’attesa con pazienza e con metodo'),
    'Nauthiz/ombra': LaPietraLetta(
        classe: ClasseDellaPietra.sosta,
        senso: 'una mancanza che spinge a forzare',
        modo: 'senza forzare ciò che manca',
        criterio: 'non ti chiede di forzare',
        nonFare: 'Non agire sotto la spinta della mancanza.',
        animo: 'non lasciare che la paura ti spinga a forzare'),
    // Isa: "Tempo di attesa e di chiarezza: non forzare."
    'Isa/dritta': LaPietraLetta(
        classe: ClasseDellaPietra.sosta,
        senso: 'una sosta che non va forzata',
        modo: 'fermandoti finché la situazione non si scioglie',
        criterio: 'non ti obbliga a decidere adesso',
        nonFare: 'Non forzare ciò che adesso è fermo.',
        animo: 'concediti una sosta e respira prima di ogni scelta',
        lato: 'un blocco che a forza non si scioglie'),
    // Jera: "Ciò che hai seminato matura a suo tempo."
    // Il raccolto che arriva al suo tempo: le RISPOSTE del corpus per Jera
    // dicono quasi tutte che il frutto e' maturo e va colto, quindi la
    // classe e' la via, col verdetto che porta il tempo giusto.
    'Jera/dritta': LaPietraLetta(
        classe: ClasseDellaPietra.via,
        verdetto: 'Sì, a suo tempo',
        senso: 'un raccolto che matura a suo tempo',
        modo: 'seguendo i tempi della stagione',
        criterio: 'rispetta i tempi giusti',
        nonFare: 'Non anticipare il raccolto e non rimandarlo per paura.',
        animo: 'rispetta i tempi e non anticipare niente',
        lato: 'l’impazienza di raccogliere'),
    // Eihwaz: "Reggi: ciò che sembra piegarti non ti spezza."
    'Eihwaz/dritta': LaPietraLetta(
        classe: ClasseDellaPietra.prudenza,
        verdetto: 'Sì, se tieni duro',
        senso: 'una tenuta che regge il vento',
        modo: 'tenendo duro senza irrigidirti',
        criterio: 'regge alla prova del tempo',
        nonFare: 'Non mollare al primo vento contrario.',
        animo: 'tieni duro senza irrigidirti',
        lato: 'una rigidità che non sa piegarsi',
        seChiudi: ClasseDellaPietra.attesa,
        verdettoSeChiudi: 'Non ancora, prima tieni duro'),
    // Perthro: "Qualcosa si muove sotto, non ancora visibile." / "Non
    // forzare la sorte: lasciala maturare."
    'Perthro/dritta': LaPietraLetta(
        classe: ClasseDellaPietra.attesa,
        senso: 'qualcosa che si muove ma non si vede ancora',
        modo: 'osservando prima di muoverti',
        criterio: 'lascia spazio a ciò che non conosci ancora',
        nonFare: 'Non pretendere di sapere già come va a finire.',
        animo: 'accetta di non sapere ancora tutto'),
    'Perthro/ombra': LaPietraLetta(
        classe: ClasseDellaPietra.sosta,
        senso: 'una sorte da non forzare',
        modo: 'senza forzare la sorte',
        criterio: 'non dipende dall’azzardo',
        nonFare: 'Non giocarti tutto in una volta.',
        animo: 'non forzare la sorte e lascia maturare le cose'),
    // Algiz: "Hai più difese di quanto pensi." / "Rialza la guardia e
    // riascolta ciò che senti."
    'Algiz/dritta': LaPietraLetta(
        classe: ClasseDellaPietra.prudenza,
        verdetto: 'Sì, con le giuste tutele',
        senso: 'un riparo che protegge',
        modo: 'proteggendo prima ciò che conta',
        criterio: 'ti lascia più protezioni',
        nonFare: 'Non abbassare la guardia per stanchezza.',
        animo: 'circondati di persone fidate'),
    'Algiz/ombra': LaPietraLetta(
        classe: ClasseDellaPietra.correggi,
        senso: 'una guardia abbassata',
        modo: 'rialzando la guardia',
        criterio: 'ti espone meno',
        nonFare: 'Non fidarti a occhi chiusi.',
        animo: 'rialza la guardia e chiedi conferme'),
    // Sowilo: "Energia piena: tieni la rotta che hai scelto."
    'Sowilo/dritta': LaPietraLetta(
        classe: ClasseDellaPietra.via,
        senso: 'una luce che mostra la rotta',
        modo: 'tenendo la rotta che hai scelto',
        criterio: 'ti somiglia di più',
        nonFare: 'Non disperdere l’energia in troppe direzioni.',
        animo: 'tieni lo sguardo sulla tua meta',
        lato: 'un’energia dispersa in troppe direzioni'),
    // Tiwaz: "Prendi ciò che ti spetta, non ciò che si strappa." /
    // "Ritrova il tuo giusto: la mira torna ferma."
    'Tiwaz/dritta': LaPietraLetta(
        classe: ClasseDellaPietra.via,
        senso: 'il coraggio di ciò che è giusto',
        modo: 'a viso aperto, con onestà',
        criterio: 'puoi difendere a testa alta',
        nonFare: 'Non prendere scorciatoie che non potresti spiegare.',
        animo: 'agisci con onestà e con coraggio'),
    'Tiwaz/ombra': LaPietraLetta(
        classe: ClasseDellaPietra.correggi,
        senso: 'una mira che trema',
        modo: 'ritrovando prima che cosa è giusto per te',
        criterio: 'rispetta ciò che ritieni giusto',
        nonFare: 'Non agire per ripicca.',
        animo: 'ritrova ciò che ritieni giusto e tienilo fermo'),
    // Berkano: "Qualcosa di nuovo germoglia: dagli cura." / "Nutri la
    // radice: il germoglio riparte."
    'Berkano/dritta': LaPietraLetta(
        classe: ClasseDellaPietra.via,
        senso: 'qualcosa di nuovo che germoglia',
        modo: 'curando ogni giorno ciò che nasce',
        criterio: 'ti fa crescere',
        nonFare: 'Non pretendere frutti subito.',
        animo: 'prenditi cura di te con piccoli gesti ogni giorno'),
    'Berkano/ombra': LaPietraLetta(
        classe: ClasseDellaPietra.attesa,
        senso: 'una crescita che si è fermata',
        modo: 'nutrendo prima la radice',
        criterio: 'ti lascia rafforzare le basi',
        nonFare: 'Non abbandonare ciò che sembra fermo.',
        animo: 'nutri ciò che ti sostiene e abbi pazienza'),
    // Ehwaz: "Si va lontano solo in armonia con l'altro." / "Ritrova il
    // ritmo comune, poi riprendete la corsa."
    'Ehwaz/dritta': LaPietraLetta(
        classe: ClasseDellaPietra.via,
        senso: 'un’alleanza in cammino',
        modo: 'insieme a qualcuno di cui ti fidi',
        criterio: 'ti mette accanto a persone affidabili',
        nonFare: 'Non fare tutto senza nessuno accanto.',
        animo: 'appoggiati a chi ti è vicino',
        seChiudi: ClasseDellaPietra.sosta,
        verdettoSeChiudi: 'No, non adesso'),
    'Ehwaz/ombra': LaPietraLetta(
        classe: ClasseDellaPietra.correggi,
        verdetto: 'Non senza un accordo',
        senso: 'un passo che non trova il ritmo comune',
        modo: 'ritrovando un ritmo comune con chi ti affianca',
        criterio: 'non ti lascia senza compagni di strada',
        nonFare: 'Non strattonare chi cammina con te.',
        animo: 'accordati con chi ti è vicino'),
    // Mannaz: "Conosci chi sei." / "Torna al legame: negli altri ti
    // riconosci meglio."
    'Mannaz/dritta': LaPietraLetta(
        classe: ClasseDellaPietra.via,
        senso: 'la conoscenza di te e l’aiuto degli altri',
        modo: 'confrontandoti con una persona saggia',
        criterio: 'rispetta chi sei davvero',
        nonFare: 'Non decidere senza confrontarti.',
        animo: 'parla con una persona che ti conosce bene',
        seChiudi: ClasseDellaPietra.correggi,
        verdettoSeChiudi: 'Non senza un confronto'),
    'Mannaz/ombra': LaPietraLetta(
        classe: ClasseDellaPietra.correggi,
        verdetto: 'Non senza confronto',
        senso: 'un isolamento che pesa',
        modo: 'tornando fra le persone',
        criterio: 'ti tiene vicino agli altri',
        nonFare: 'Non isolarti.',
        animo: 'cerca la compagnia di chi ti vuole bene'),
    // Laguz: "Fidati di ciò che senti sotto la superficie." / "Lascia
    // posare la corrente: il fondo si vede."
    'Laguz/dritta': LaPietraLetta(
        classe: ClasseDellaPietra.via,
        verdetto: 'Sì, se lo senti giusto',
        senso: 'un intuito che scorre',
        modo: 'fidandoti di ciò che senti',
        criterio: 'ti lascia più pace dentro',
        nonFare: 'Non zittire l’intuito con troppi ragionamenti.',
        animo: 'accogli ciò che senti senza giudicarlo'),
    'Laguz/ombra': LaPietraLetta(
        classe: ClasseDellaPietra.sosta,
        senso: 'acque torbide che devono posarsi',
        modo: 'aspettando che le acque si posino',
        criterio: 'ti lascia vedere più chiaramente',
        nonFare: 'Non decidere nell’agitazione.',
        animo: 'lascia posare l’agitazione prima di decidere'),
    // Ingwaz: "Un lavoro interiore si compie prima di mostrarsi."
    'Ingwaz/dritta': LaPietraLetta(
        classe: ClasseDellaPietra.attesa,
        senso: 'un compimento che matura dentro',
        modo: 'preparando in silenzio',
        criterio: 'ti lascia completare ciò che hai avviato',
        nonFare: 'Non annunciare prima del tempo.',
        animo: 'custodisci le forze e preparati in silenzio',
        lato: 'un lavoro interiore non ancora compiuto'),
    // Dagaz: "Un nuovo giorno: cambia stato con lui."
    'Dagaz/dritta': LaPietraLetta(
        classe: ClasseDellaPietra.via,
        senso: 'una svolta chiara',
        modo: 'cambiando passo adesso',
        criterio: 'segna un cambiamento vero',
        nonFare: 'Non restare sulla soglia.',
        animo: 'accogli il cambiamento con fiducia',
        lato: 'la paura di cambiare stato'),
    // Othala: "Ciò che viene da lontano ti sostiene: appoggiati." / "Tieni
    // ciò che sostiene, lascia ciò che trattiene."
    'Othala/dritta': LaPietraLetta(
        classe: ClasseDellaPietra.via,
        senso: 'ciò che è tuo per radice',
        modo: 'partendo da ciò che hai già costruito',
        criterio: 'ti tiene vicino alle tue radici',
        nonFare: 'Non svendere ciò che hai costruito.',
        animo: 'appoggiati a ciò che ti sostiene da sempre',
        seChiudi: ClasseDellaPietra.sosta,
        verdettoSeChiudi: 'Non adesso'),
    'Othala/ombra': LaPietraLetta(
        classe: ClasseDellaPietra.correggi,
        verdetto: 'Non per abitudine',
        senso: 'un’abitudine ereditata che trattiene',
        modo: 'lasciando le abitudini che ti trattengono',
        criterio: 'non ti lega a vecchi schemi',
        nonFare: 'Non restare per sola abitudine.',
        animo: 'tieni ciò che ti sostiene e lascia ciò che ti trattiene',
        seChiudi: ClasseDellaPietra.via,
        verdettoSeChiudi: 'Sì'),
  };
}

/// **LA COMPOSIZIONE DELLA RISPOSTA DIRETTA.**
abstract final class LaRispostaDellaGettata {
  static int parole(String t) => LaFormaDelResponso.parole(t);

  static String maiuscola(String t) =>
      t.isEmpty ? t : '${t[0].toUpperCase()}${t.substring(1)}';

  /// La prima che sta fra [minimo] e [massimo] parole; null se nessuna.
  static String? primaCheSta(
      Iterable<String> candidati, int minimo, int massimo) {
    for (final c in candidati) {
      final n = parole(c);
      if (n >= minimo && n <= massimo) return c;
    }
    return null;
  }

  /// La classe con cui la pietra che decide risponde, col peso del resto
  /// della gettata: una via aperta in una gettata in ombra diventa una via
  /// da prendere con cautela.
  ///
  /// [chiude]: la domanda chiede se chiudere o lasciare qualcosa, e le
  /// pietre che hanno una risposta propria a questo ([LaPietraLetta.seChiudi])
  /// la danno.
  static ClasseDellaPietra classe(EsitoGettata esito, {bool chiude = false}) {
    final decide = IlPresagioDalCorpus.pietraCheDecide(esito);
    final pietra = LaPietraLetta.di(decide);
    final c = (chiude ? pietra.seChiudi : null) ?? pietra.classe;
    if (c == ClasseDellaPietra.via &&
        IlPresagioDalCorpus.tono(esito.rune) == 'ombra') {
      return ClasseDellaPietra.prudenza;
    }
    return c;
  }

  static String verdetto(EsitoGettata esito, {bool chiude = false}) {
    final decide = IlPresagioDalCorpus.pietraCheDecide(esito);
    final pietra = LaPietraLetta.di(decide);
    final c = classe(esito, chiude: chiude);
    if (chiude && pietra.seChiudi != null) {
      if (c == pietra.seChiudi && pietra.verdettoSeChiudi != null) {
        return pietra.verdettoSeChiudi!;
      }
    } else if (pietra.verdetto != null && c == pietra.classe) {
      return pietra.verdetto!;
    }
    return switch (c) {
      ClasseDellaPietra.via => 'Sì',
      ClasseDellaPietra.prudenza => 'Sì, ma con cautela',
      ClasseDellaPietra.attesa => 'Non ancora',
      ClasseDellaPietra.sosta => 'Non adesso',
      ClasseDellaPietra.correggi => 'Non così',
    };
  }

  static String _conseguenza(ClasseDellaPietra c) => switch (c) {
        ClasseDellaPietra.via => 'quindi puoi muoverti adesso',
        ClasseDellaPietra.prudenza => 'quindi muoviti, ma con cautela',
        ClasseDellaPietra.attesa =>
          'quindi il momento di raccogliere non è ancora arrivato',
        ClasseDellaPietra.sosta => 'quindi adesso conviene fermarsi',
        ClasseDellaPietra.correggi => 'quindi prima va corretto qualcosa',
      };

  static String _imperativo(ClasseDellaPietra c) => switch (c) {
        ClasseDellaPietra.via => 'è il momento di muoverti',
        ClasseDellaPietra.prudenza => 'muoviti, ma con cautela',
        ClasseDellaPietra.attesa => 'non è ancora il tempo di raccogliere',
        ClasseDellaPietra.sosta => 'adesso fermati e non forzare',
        ClasseDellaPietra.correggi => 'prima correggi ciò che non funziona',
      };

  static String _esito(ClasseDellaPietra c) => switch (c) {
        ClasseDellaPietra.via => 'la strada è aperta se fai la tua parte',
        ClasseDellaPietra.prudenza =>
          'la strada c’è, ma va percorsa con cautela',
        ClasseDellaPietra.attesa => 'servono ancora tempo e preparazione',
        ClasseDellaPietra.sosta => 'adesso non è il momento di forzare',
        ClasseDellaPietra.correggi => 'prima va corretto qualcosa',
      };

  static String _tempo(ClasseDellaPietra c) => switch (c) {
        ClasseDellaPietra.via => 'il tempo dipende da quando ti muovi tu',
        ClasseDellaPietra.prudenza =>
          'il tempo dipende anche dalla tua cautela',
        ClasseDellaPietra.attesa => 'serve ancora pazienza',
        ClasseDellaPietra.sosta => 'per ora la situazione resta ferma',
        ClasseDellaPietra.correggi =>
          'l’attesa si accorcia solo se cambi qualcosa',
      };

  /// **LE PRIME FRASI**, nell'ordine in cui si preferiscono: quella che
  /// riprende le parole di chi chiede, poi quella col tema. Ognuna e' una
  /// frase sola, e la prima frase del responso.
  static List<String> primeFrasi(LaDomandaLetta q, EsitoGettata esito) {
    final decide = IlPresagioDalCorpus.pietraCheDecide(esito);
    final p = LaPietraLetta.di(decide);
    final c = classe(esito, chiude: q.chiude);
    final v = verdetto(esito, chiude: q.chiude);
    final tema = q.tema;
    final fuori = <String>[];
    switch (q.tipo) {
      case TipoDiDomanda.decisione:
        final a = q.azione;
        if (a != null) {
          fuori.add(switch (c) {
            ClasseDellaPietra.via ||
            ClasseDellaPietra.prudenza =>
              '$v: la gettata dice di $a, perché indica ${p.senso}.',
            ClasseDellaPietra.attesa =>
              '$v: prima di $a serve altro tempo, perché la gettata indica '
                  '${p.senso}.',
            ClasseDellaPietra.sosta =>
              '$v: per ora la gettata dice di non $a, perché indica '
                  '${p.senso}.',
            ClasseDellaPietra.correggi =>
              '$v: prima di $a va corretto qualcosa, perché la gettata '
                  'indica ${p.senso}.',
          });
        }
        fuori.addAll([
          '$v: per $tema la gettata indica ${p.senso}, ${_conseguenza(c)}.',
          '$v: per $tema la gettata indica ${p.senso}.',
          '$v, per $tema.',
        ]);
      case TipoDiDomanda.scelta:
        final s = q.strade;
        if (s != null) {
          fuori.addAll([
            'Fra ${s[0]} e ${s[1]} scegli la strada che ${p.criterio}: la '
                'gettata indica ${p.senso}.',
            'Fra ${s[0]} e ${s[1]} scegli la strada che ${p.criterio}.',
          ]);
        }
        fuori.addAll([
          'Fra le due strade scegli quella che ${p.criterio}: per $tema la '
              'gettata indica ${p.senso}.',
          'Scegli la strada che ${p.criterio}: per $tema la gettata indica '
              '${p.senso}.',
          'Per $tema scegli la strada che ${p.criterio}.',
        ]);
      case TipoDiDomanda.come:
        fuori.addAll([
          '${maiuscola(p.modo)}: è questa la via per $tema, perché la '
              'gettata indica ${p.senso}.',
          '${maiuscola(p.modo)}: è questa la via che la gettata indica per '
              '$tema.',
          '${maiuscola(p.modo)}: è la via per $tema.',
        ]);
      case TipoDiDomanda.quando:
        fuori.addAll([
          'Le rune non danno date per $tema: indicano ${p.senso}, quindi '
              '${_tempo(c)}.',
          'Le rune non danno date: per $tema indicano ${p.senso}.',
          'Le rune non danno date per $tema.',
        ]);
      case TipoDiDomanda.previsione:
        fuori.addAll([
          'Le rune non predicono l’esito per $tema: indicano ${p.senso}, '
              'quindi ${_esito(c)}.',
          'Le rune non predicono l’esito: per $tema indicano ${p.senso}.',
          'Le rune non predicono l’esito per $tema.',
        ]);
      case TipoDiDomanda.altrui:
        fuori.addAll([
          'Le rune non leggono il cuore di un’altra persona: per $tema '
              'indicano ${p.senso}, cioè ciò che dipende da te.',
          'Le rune non leggono il cuore di un’altra persona: per $tema '
              'indicano ${p.senso}.',
          'Le rune non leggono il cuore di un’altra persona: per $tema '
              'parlano di te.',
        ]);
      case TipoDiDomanda.tuttoBene:
        fuori.addAll([
          'Le rune non promettono che vada tutto bene: per $tema indicano '
              '${p.senso}, ${_conseguenza(c)}.',
          'Le rune non promettono che vada tutto bene: per $tema indicano '
              '${p.senso}.',
          'Le rune non promettono che vada tutto bene per $tema.',
        ]);
      case TipoDiDomanda.futuro:
        fuori.addAll([
          'Le rune non mostrano un futuro già scritto: per $tema indicano '
              '${p.senso}, ${_conseguenza(c)}.',
          'Le rune non mostrano un futuro già scritto: per $tema indicano '
              '${p.senso}.',
          'Le rune non mostrano un futuro già scritto per $tema.',
        ]);
      case TipoDiDomanda.giornata:
        fuori.addAll([
          'La tua giornata porta ${p.senso}: ${_imperativo(c)}.',
          'La tua giornata porta ${p.senso}, ${_conseguenza(c)}.',
          'La tua giornata porta ${p.senso}.',
        ]);
      case TipoDiDomanda.aperta:
        fuori.addAll([
          'Per $tema la gettata indica ${p.senso}: ${_imperativo(c)}.',
          'Per $tema la gettata indica ${p.senso}, ${_conseguenza(c)}.',
          'Per $tema la gettata indica ${p.senso}.',
        ]);
    }
    return fuori;
  }

  // -------------------------------------------------------------------------
  // IL TONO DELLA GETTATA, CONTATO SULLE PIETRE VERE
  // -------------------------------------------------------------------------

  static const List<String> _numeri = [
    'nessuna', 'una', 'due', 'tre', 'quattro', 'cinque', 'sei', 'sette', //
  ];

  /// Dove sta una pietra, detto per una frase ("a Urdhr", "nell’Ostacolo").
  static String dove(PosizioneGettata p) => switch (p.titolo) {
        'Urdhr' => 'a Urdhr',
        'Verdhandi' => 'a Verdhandi',
        'Skuld' => 'a Skuld',
        'Cuore' => 'nel Cuore',
        'Radice' => 'nella Radice',
        'Ostacolo' => 'nell’Ostacolo',
        'Consiglio' => 'nel Consiglio',
        'Esito' => 'nell’Esito',
        'Al centro' => 'al centro',
        'Presso il centro' => 'presso il centro',
        'Ai margini' => 'ai margini',
        _ => 'nella gettata',
      };

  static String _elenco(List<String> voci) => voci.length < 2
      ? voci.join()
      : '${voci.sublist(0, voci.length - 1).join(', ')} e ${voci.last}';

  /// **LA FRASE SUL TONO**, dalla piu' lunga alla piu' corta. Il numero
  /// delle pietre, quante sono in ombra e dove: tutto contato sulla gettata,
  /// mai scritto per una famiglia di rune.
  static List<String> frasiDelTono(EsitoGettata esito) {
    final pietre = esito.rune;
    final n = pietre.length;
    final ombre = [
      for (final p in pietre)
        if (p.inOmbra) p
    ];
    final k = ombre.length;
    if (n == 1) {
      return k == 0
          ? [
              'La pietra è una sola e dritta: il suo consiglio vale per '
                  'intero.',
              'La pietra è una sola ed è dritta.',
            ]
          : [
              'La pietra è una sola ed è in ombra: il suo consiglio chiede '
                  'prudenza.',
              'La pietra è una sola ed è in ombra.',
            ];
    }
    final luoghi = <String>[];
    for (final p in ombre) {
      final d = dove(p.posizione);
      if (!luoghi.contains(d)) luoghi.add(d);
    }
    final doveSono = _elenco(luoghi);
    if (k == 0) {
      return [
        'Le ${_numeri[n]} pietre sono tutte dritte e sostengono questa '
            'lettura.',
        'Le ${_numeri[n]} pietre sono tutte dritte.',
      ];
    }
    if (k == n) {
      return [
        'Tutte e ${_numeri[n]} le pietre sono in ombra: è tempo di prudenza.',
        'Tutte e ${_numeri[n]} le pietre sono in ombra.',
      ];
    }
    if (k == 1) {
      return [
        'Una sola pietra su ${_numeri[n]} è in ombra, $doveSono: lì serve '
            'più attenzione.',
        'Una sola pietra su ${_numeri[n]} è in ombra, $doveSono.',
        'Una sola pietra su ${_numeri[n]} è in ombra.',
      ];
    }
    final quante = maiuscola(_numeri[k]);
    return [
      '$quante pietre su ${_numeri[n]} sono in ombra, $doveSono: lì serve '
          'più attenzione.',
      '$quante pietre su ${_numeri[n]} sono in ombra, $doveSono.',
      '$quante pietre su ${_numeri[n]} sono in ombra.',
    ];
  }

  /// Nella Croce delle Cinque, che cosa frena: la pietra dell'Ostacolo dal
  /// suo lato difficile.
  static String? frenoDellaCroce(EsitoGettata esito) {
    for (final p in esito.rune) {
      if (p.posizione.titolo == 'Ostacolo') {
        return 'Ciò che ti frena, nell’Ostacolo, è '
            '${LaPietraLetta.latoDifficile(p)}.';
      }
    }
    return null;
  }

  /// **IL PARAGRAFO DELLA RISPOSTA**: la prima frase, che risponde; poi,
  /// se ci stanno, il tono contato e il freno della Croce; poi [risposta]
  /// del corpus, che spiega la pietra che decide. Fra 40 e 50 parole. Null
  /// solo se nessuna forma ci sta: la prova le misura tutte perche' non
  /// succeda.
  static String? paragrafoDellaRisposta({
    required LaDomandaLetta domanda,
    required EsitoGettata esito,
    required String risposta,
  }) {
    final b = parole(risposta);
    final prime = primeFrasi(domanda, esito);
    final toni = frasiDelTono(esito);
    final freno = frenoDellaCroce(esito);
    final aggiunte = <String>[
      if (freno != null) '${toni.first} $freno',
      ...toni,
      if (freno != null) freno,
      '',
    ];
    final note = notaDellaSeconda(domanda);
    final candidati = [
      for (final a in prime)
        for (final n in note)
          for (final g in aggiunte)
            [a, n, g].where((x) => x.isNotEmpty).join(' '),
    ];
    final scelta = primaCheSta(candidati, LaFormaDelResponso.minimo - b,
        LaFormaDelResponso.massimo - b);
    return scelta == null ? null : '$scelta $risposta';
  }

  /// **LA DOMANDA DOPPIA SI SEPARA**, subito dopo la prima frase: la
  /// gettata risponde alla prima domanda e lo dice, e la seconda chiede
  /// un'altra gettata. Per una domanda sola, una nota vuota.
  static List<String> notaDellaSeconda(LaDomandaLetta q) {
    if (!q.doppia) return const [''];
    final s = q.seconda!;
    final propria =
        s != q.tema && s != 'ciò che hai chiesto' && s != 'il tuo momento';
    return [
      if (propria)
        'Questa gettata risponde alla prima domanda: la seconda, per $s, '
            'chiede un’altra gettata.',
      'Questa gettata risponde alla prima domanda: la seconda chiede '
          'un’altra gettata.',
      'La seconda domanda chiede un’altra gettata.',
    ];
  }

  // -------------------------------------------------------------------------
  // SALUTE, LEGGE, DENARO
  // -------------------------------------------------------------------------

  static List<String> _limite(AmbitoDelicato a) => switch (a) {
        AmbitoDelicato.salute => [
            'Su come andrà decidono i medici che ti seguono, non le rune: '
                'porta a loro ogni domanda e ogni dubbio.',
            'Sull’esito decidono i medici che ti seguono, non le rune: porta '
                'a loro ogni domanda.',
          ],
        AmbitoDelicato.legge => [
            'Le rune non predicono l’esito di una causa e non sostituiscono '
                'un avvocato: ogni passo va deciso con chi ti assiste.',
            'Le rune non predicono l’esito di una causa: ogni passo va '
                'deciso con un avvocato.',
          ],
        AmbitoDelicato.denaro => [
            'Le rune non danno consigli su risparmi, acquisti o investimenti: '
                'per questa scelta serve un consulente che conosca i tuoi '
                'numeri.',
            'Le rune non danno consigli di denaro: per questa scelta serve '
                'un consulente che conosca i tuoi numeri.',
          ],
      };

  /// **IL PARAGRAFO DELLA RISPOSTA QUANDO LA DOMANDA TOCCA SALUTE, LEGGE O
  /// DENARO** (ordine S voce 17, voce GA.06): il limite per primo, poi
  /// l'atteggiamento che la pietra che decide chiede, mai l'esito. La
  /// RISPOSTA del corpus qui non entra: e' scritta per spingere o fermare
  /// un'azione, e su un'operazione o un investimento direbbe cio' che le
  /// rune non possono dire (i lettori ciechi: "porta via ciò che era già
  /// incrinato" su un'operazione, "comincia oggi stesso" su un investimento).
  static String? paragrafoDelicato({
    required LaDomandaLetta domanda,
    required EsitoGettata esito,
  }) {
    final ambito = domanda.delicato!;
    final p = LaPietraLetta.di(IlPresagioDalCorpus.pietraCheDecide(esito));
    final seconde = [
      'La pietra che decide parla solo di come vivi questo tempo: '
          '${p.animo}, un giorno alla volta, senza decidere niente sulla '
          'base di questa gettata.',
      'La pietra che decide parla solo di come vivi questo tempo: '
          '${p.animo}, un giorno alla volta.',
      'La pietra che decide parla solo di come vivi questo tempo: '
          '${p.animo}.',
    ];
    final toni = frasiDelTono(esito);
    final candidati = [
      for (final l in _limite(ambito))
        for (final n in notaDellaSeconda(domanda))
          for (final s in seconde)
            for (final t in ['', ...toni.reversed])
              [l, n, s, t].where((x) => x.isNotEmpty).join(' '),
    ];
    return primaCheSta(
        candidati, LaFormaDelResponso.minimo, LaFormaDelResponso.massimo);
  }

  // -------------------------------------------------------------------------
  // IL RIQUADRO "COSA FARE ADESSO"
  // -------------------------------------------------------------------------

  static int _gruppo(ClasseDellaPietra c) => switch (c) {
        ClasseDellaPietra.via || ClasseDellaPietra.prudenza => 0,
        ClasseDellaPietra.attesa || ClasseDellaPietra.sosta => 1,
        ClasseDellaPietra.correggi => 2,
      };

  /// Le cose da fare, per tipo di domanda e per gruppo di classe (via e
  /// prudenza, attesa e sosta, correggi). `{tema}`, `{modo}` e `{criterio}`
  /// si riempiono; ogni forma porta un'azione che si puo' fare davvero e
  /// riguarda la domanda.
  static List<String> _daFare(TipoDiDomanda tipo, int g, String? azione) {
    switch (tipo) {
      case TipoDiDomanda.decisione:
        return [
          [
            if (azione != null)
              'Se scegli di $azione, fissa oggi il primo passo concreto, con '
                  'il giorno e l’ora, poi muoviti {modo}. Dillo a una persona '
                  'di fiducia.',
            'Se scegli di andare avanti per {tema}, fissa oggi il primo passo '
                'concreto, con il giorno e l’ora, poi muoviti {modo}. Dillo a '
                'una persona di fiducia.',
            'Per {tema} metti per iscritto il primo passo concreto e fissalo '
                'in agenda entro tre giorni, poi procedi {modo}. Tieni il '
                'foglio dove lo vedi ogni mattina.',
          ],
          [
            if (azione != null)
              'Prima di $azione prenditi una settimana: annota ogni sera che '
                  'cosa sai di nuovo e che cosa senti, {modo}. Decidi quando '
                  'le note smettono di cambiare.',
            'Per ora non dare una risposta definitiva per {tema}: chiedi '
                'qualche giorno e usalo per raccogliere ciò che manca, {modo}. '
                'Decidi quando il quadro resta fermo.',
            'Prima di decidere per {tema} prenditi una settimana: annota ogni '
                'sera che cosa sai di nuovo, {modo}. Decidi quando le note '
                'smettono di cambiare.',
          ],
          [
            if (azione != null)
              'Prima di $azione scrivi che cosa oggi non funziona e correggi '
                  'la cosa più piccola entro la settimana, {modo}. Solo dopo '
                  'torna alla decisione.',
            'Prima di decidere per {tema} scrivi che cosa oggi non funziona e '
                'correggi la cosa più piccola entro la settimana, {modo}. Solo '
                'dopo torna alla decisione.',
          ],
        ][g];
      case TipoDiDomanda.scelta:
        return [
          'Prendi un foglio e dividi la pagina in due, una colonna per ogni '
              'strada: sotto ciascuna scrivi se {criterio}, con un esempio '
              'concreto. Scegli la colonna più piena.',
          'Scrivi le due strade una accanto all’altra e accanto a ciascuna '
              'se {criterio}, con un fatto e non con un’impressione. Poi '
              'scegli quella che lo fa di più, {modo}.',
        ];
      case TipoDiDomanda.come:
        return [
          [
            'Per {tema} scegli oggi un gesto preciso, una telefonata, un '
                'incontro o un messaggio: fallo entro due giorni, {modo}. '
                'Prepara prima la frase con cui cominci.',
            'Per {tema} decidi oggi un gesto concreto e fallo entro due '
                'giorni, {modo}. Prepara prima, su un foglio, le parole con '
                'cui cominci.',
          ],
          [
            'Per {tema} non cercare la soluzione tutta insieme: questa '
                'settimana fai un solo gesto piccolo, {modo}, poi osserva che '
                'cosa cambia.',
            'Per {tema} fai questa settimana un solo gesto piccolo, {modo}, '
                'poi osserva per qualche giorno che cosa cambia prima di '
                'aggiungerne un altro.',
          ],
          [
            'Per {tema} individua il punto che si è inceppato e parlane con '
                'chi è coinvolto, {modo}, prima di tentare altre mosse. '
                'Scegli un momento tranquillo.',
            'Per {tema} individua il punto inceppato e parlane con chi è '
                'coinvolto, {modo}. Scegli un momento tranquillo e una frase '
                'sola per aprire.',
          ],
        ][g];
      case TipoDiDomanda.quando:
        return [
          [
            'Non aspettare un segno per {tema}: scegli tu una data vicina per '
                'il prossimo passo e preparala {modo}. Segnala sul calendario '
                'e tienila.',
          ],
          [
            'Segna sul calendario una verifica fra due settimane per {tema} e '
                'fino ad allora vai avanti {modo}, senza contare i giorni.',
          ],
          [
            'Per accorciare l’attesa cambia una cosa che dipende da te per '
                '{tema}, {modo}, poi guarda se qualcosa si sblocca entro due '
                'settimane.',
          ],
        ][g];
      case TipoDiDomanda.previsione:
        return [
          [
            'Concentra le forze su ciò che dipende da te per {tema}: scrivi i '
                'tre passi che puoi fare adesso e comincia dal primo, {modo}.',
          ],
          [
            'Per {tema} cura con costanza ciò che dipende da te, un poco ogni '
                'giorno, {modo}, senza chiedere un esito che nessuna gettata '
                'può promettere.',
            'Per {tema} cura con costanza ciò che dipende da te, un poco ogni '
                'giorno, {modo}.',
          ],
          [
            'Per {tema} individua che cosa oggi va corretto e dedicagli i '
                'prossimi giorni, {modo}, invece di rimuginare sull’esito.',
            'Per {tema} individua che cosa oggi va corretto e dedicagli i '
                'prossimi giorni, {modo}.',
          ],
        ][g];
      case TipoDiDomanda.altrui:
        return [
          [
            'Invece di indovinare che cosa pensa l’altra persona, chiediglielo '
                'con una domanda semplice e diretta nei prossimi giorni, '
                '{modo}. Poi ascolta la risposta fino in fondo.',
          ],
          [
            'Non cercare di leggere nei pensieri dell’altra persona: per '
                'qualche giorno osserva i fatti, cioè che cosa fa: solo dopo '
                'chiedi, {modo}.',
            'Per qualche giorno osserva i fatti, cioè che cosa fa l’altra '
                'persona: solo dopo chiedi, {modo}.',
          ],
          [
            'Prima di chiederti che cosa prova l’altra persona, guarda che '
                'cosa senti tu e dillo con chiarezza, {modo}. Una frase sola, '
                'detta con calma.',
          ],
        ][g];
      case TipoDiDomanda.giornata:
      case TipoDiDomanda.tuttoBene:
      case TipoDiDomanda.futuro:
      case TipoDiDomanda.aperta:
        return [
          [
            'Per {tema} scegli una cosa sola da muovere in questa settimana e '
                'dalle un giorno preciso, {modo}. Scrivila dove la vedi ogni '
                'mattina.',
            'Per {tema} individua il passo che rimandi da più tempo e fallo '
                'entro tre giorni, {modo}. Poi annota che cosa è cambiato.',
          ],
          [
            'Per {tema} questa settimana non aggiungere impegni: scegli una '
                'cosa da lasciar maturare e prenditene cura {modo}.',
            'Per {tema} rallenta questa settimana: scegli una sola cosa da '
                'curare ogni giorno, {modo}. Il resto lascialo com’è finché '
                'non matura.',
          ],
          [
            'Per {tema} scegli una cosa che non funziona e correggila questa '
                'settimana, {modo}. Comincia dalla più piccola.',
            'Per {tema} scrivi che cosa oggi non funziona e scegli una '
                'correzione piccola da fare entro la settimana, {modo}.',
          ],
        ][g];
    }
  }

  static const List<List<String>> _chiusure = [
    [
      'Fallo prima di sera.',
      'Poi guarda che cosa si muove.',
      'Non aspettare il momento perfetto.',
      'Non serve un gesto grande, serve un gesto vero.',
      'Ricorda che conta il primo passo, non il risultato di domani.',
    ],
    [
      'Poi aspetta.',
      'Il resto lo matura il tempo.',
      'Annota ogni sera che cosa cambia.',
      'Non avere fretta di vedere i frutti.',
      'Lascia che sia il tempo a dirti quando è il momento di muoverti.',
    ],
    [
      'Poi riprova.',
      'Solo dopo torna alla domanda.',
      'Annota che cosa cambia nei giorni seguenti.',
      'Un passo corretto vale più di tre fatti in fretta.',
      'Correggere una cosa sola, ma bene, vale più che cambiare tutto.',
    ],
  ];

  /// Chi chiede questo riquadro: la pietra che decide, nel suo posto.
  static String _chiLoChiede(EsitoGettata esito) {
    if (esito.rune.length == 1) {
      return 'Lo chiede la sola pietra della gettata.';
    }
    final decide = IlPresagioDalCorpus.pietraCheDecide(esito);
    return 'Lo chiede la pietra che decide, ${dove(decide.posizione)}.';
  }

  /// **IL RIQUADRO "COSA FARE ADESSO"** per una domanda: che cosa fare, nel
  /// modo della pietra che decide, e che cosa non fare. Fra 40 e 50 parole.
  /// [variante] sceglie fra le forme equivalenti, perche' la stessa persona
  /// che rifa' la stessa domanda non legga sempre le stesse parole.
  static String? riquadro({
    required LaDomandaLetta domanda,
    required EsitoGettata esito,
    int variante = 0,
  }) {
    final p = LaPietraLetta.di(IlPresagioDalCorpus.pietraCheDecide(esito));
    final g = _gruppo(classe(esito, chiude: domanda.chiude));
    if (domanda.delicato != null) {
      return _riquadroDelicato(domanda.delicato!, p);
    }
    final forme = _daFare(domanda.tipo, g, domanda.azione);
    final ruotate = [
      for (var i = 0; i < forme.length; i++)
        forme[(i + variante) % forme.length],
    ];
    // La ripresa delle parole di chi chiede, quando c'e', resta la prima.
    if (domanda.azione != null && forme.first.contains(domanda.azione!)) {
      ruotate
        ..remove(forme.first)
        ..insert(0, forme.first);
    }
    final seconda =
        domanda.doppia ? 'Per la seconda domanda fai un’altra gettata.' : '';
    final chi = _chiLoChiede(esito);
    final code = <List<String>>[
      [p.nonFare],
      [p.nonFare, chi],
      for (final c in _chiusure[g]) [p.nonFare, c],
      for (final c in _chiusure[g]) [p.nonFare, chi, c],
      [chi],
      for (final c in _chiusure[g]) [chi, c],
      [],
      for (final c in _chiusure[g]) [c],
    ];
    final candidati = <String>[];
    for (final f in ruotate) {
      final base = f
          .replaceAll('{tema}', domanda.tema)
          .replaceAll('{modo}', p.modo)
          .replaceAll('{criterio}', p.criterio);
      for (final coda in code) {
        candidati
            .add([base, seconda, ...coda].where((x) => x.isNotEmpty).join(' '));
      }
    }
    return primaCheSta(
        candidati, LaFormaDelResponso.minimo, LaFormaDelResponso.massimo);
  }

  static String? _riquadroDelicato(AmbitoDelicato a, LaPietraLetta p) {
    final primi = switch (a) {
      AmbitoDelicato.salute => [
          'Scrivi su un foglio le domande che hai e portale a chi ti segue '
              'alla prossima visita: lì stanno le risposte sull’esito.',
          'Scrivi le domande che hai e portale a chi ti segue alla prossima '
              'visita.',
        ],
      AmbitoDelicato.legge => [
          'Raccogli in ordine carte, date e messaggi e portali a un avvocato '
              'prima di qualunque passo: è lì che si decide come muoversi.',
          'Raccogli in ordine carte, date e messaggi e portali a un avvocato '
              'prima di qualunque passo.',
        ],
      AmbitoDelicato.denaro => [
          'Prima di muovere denaro fissa un incontro con un consulente '
              'finanziario e chiedi per iscritto rischi e costi di ogni '
              'strada.',
          'Prima di muovere denaro parla con un consulente finanziario e '
              'chiedi per iscritto rischi e costi.',
        ],
    };
    final secondi = [
      'Non decidere niente sulla base di questa gettata: nei giorni che '
          'mancano ${p.animo}.',
      'Nei giorni che mancano ${p.animo}.',
    ];
    const code = [
      '',
      'Un giorno alla volta.',
      'Il resto non dipende da te.',
      'Tieni il foglio con le domande sempre a portata di mano.',
      'Chiedi tutto ciò che non ti è chiaro, anche due volte.',
    ];
    final candidati = [
      for (final f in primi)
        for (final s in secondi)
          for (final c in code) c.isEmpty ? '$f $s' : '$f $s $c',
    ];
    return primaCheSta(
        candidati, LaFormaDelResponso.minimo, LaFormaDelResponso.massimo);
  }
  // -------------------------------------------------------------------------
  // IL TITOLO DELLA SCHEDA DI UNA PIETRA
  // -------------------------------------------------------------------------

  /// Che cosa dice una posizione, come titolo della scheda.
  static String ruolo(PosizioneGettata p) => switch (p.titolo) {
        'Urdhr' => 'Da dove vieni',
        'Verdhandi' => 'Dove sei adesso',
        'Skuld' => 'Dove tende la strada',
        'Cuore' => 'Il cuore della questione',
        'Radice' => 'La radice',
        'Ostacolo' => 'Ciò che ti frena',
        'Consiglio' => 'Il consiglio',
        'Esito' => 'Dove tende la questione',
        'Al centro' => 'Ciò che pesa di più',
        'Presso il centro' => 'Ciò che accompagna',
        'Ai margini' => 'Una voce lieve',
        _ => maiuscola(p.titolo),
      };

  /// **IL TITOLO DELLA SCHEDA LEGGE LA POSIZIONE.** I lettori ciechi: *"La
  /// posizione non è mai letta [...] Una pietra in Ostacolo è letta come
  /// favorevole"*. Il titolo dice che cosa vuol dire quella pietra in quel
  /// posto: nell'Ostacolo il suo lato difficile, nel Consiglio il suo modo,
  /// altrove il suo senso nel verso in cui e' uscita.
  ///
  /// [delicata]: la domanda tocca salute, legge o denaro. Allora il titolo
  /// non dice dove tende la questione ne' che cosa la frena (sarebbe leggere
  /// l'esito di un'operazione o di una causa): dice, dal posto della pietra,
  /// l'atteggiamento che chiede a chi legge.
  static String titoloDellaScheda(RunaGettata pietra, {bool delicata = false}) {
    final p = LaPietraLetta.di(pietra);
    if (delicata) {
      return '${maiuscola(dove(pietra.posizione))}, per te: ${p.animo}.';
    }
    final che = switch (pietra.posizione.titolo) {
      'Ostacolo' => LaPietraLetta.latoDifficile(pietra),
      'Consiglio' => p.modo,
      _ => p.senso,
    };
    return '${ruolo(pietra.posizione)}: $che.';
  }
}
