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

  /// Tutte le altre: "che cosa devo sapere sul mio momento", "dimmi qualcosa".
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
    this.suTerapia = false,
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

  /// **LA DOMANDA CHIEDE SE SMETTERE O CAMBIARE UNA TERAPIA** ("Posso smettere
  /// le medicine che prendo?"). Il limite generico della salute dice che
  /// decidono i medici sull'esito; qui il rischio e' un altro, e piu' grave:
  /// sospendere una cura per una gettata. Lettura severa del terzo giro.
  final bool suTerapia;

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
    final terapia = delicato == AmbitoDelicato.salute && _suTerapia.hasMatch(d);
    // Le domande del Cerchio hanno il loro tipo, scritto qui: sono dodici e
    // non cambiano senza che cambi questo file (la prova lo controlla).
    final delCerchio = _tipoDelCerchio[d];
    if (delCerchio != null) {
      return LaDomandaLetta(
          tipo: delCerchio, tema: tema, delicato: delicato, suTerapia: terapia);
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
        suTerapia: terapia || prima.suTerapia,
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
      suTerapia: terapia,
    );
  }

  /// Smettere, sospendere o cambiare una medicina, una terapia, una cura.
  static final RegExp _suTerapia = RegExp(
      r'(smett|sospend|interromp|ridur|tolg|cambi|salt|dimezz|aument)[a-zà-ÿ]* '
      r'.*(medicin|farmac|terapi|cura|cure|pillol|dosagg|antibiotic|insulin|'
      r'compress|trattament)');

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
      r'acquist\w* (casa|una casa|la casa|un appartamento)|'
      // Aprire un'attivita' e lasciare il lavoro sono scelte di denaro anche
      // quando la domanda non lo dice (ordine GA voce GA.06, riapertura: il
      // lettore cieco ha letto "Sì, adesso" a lasciare il lavoro e "vai
      // avanti" ad aprire un'attivita' senza una parola sui conti).
      r'apr\w* (la mia |una |un |il mio |)(attività|negozio|impresa|azienda|'
      r'studio)|'
      r'(lasciare|mollare|abbandonare) (il|la mia|il mio) (lavoro|posto)|'
      r'licenziarmi|dimettermi|'
      // Vendere o affittare una casa, un terreno, un negozio: "Dovrei vendere
      // l'appartamento di mia madre?" prendeva un "Sì, la volonta' c'e'"
      // (lettura severa del terzo giro).
      r"vend\w* (la |il |l'|lo |un |una )?(mia |mio |tua |tuo )?"
      r'(casa|appartament\w*|immobil\w*|terren\w*|negozi\w*|aziend\w*|'
      r'auto|macchina)|affitt\w*|caparra');

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
    // La domanda del Cerchio sull'amore e la direzione chiede dove va una cosa che ha un nome:
    // le voci della previsione la leggono per l'amore (le aperte non portano
    // un tema, e il suo riquadro era un gesto che non c'entrava con l'amore).
    const previsione = {'in amore, dove sto andando'};
    return {
      for (final q in [
        ...DomandeDelCerchio.generichePerLaGettata,
        ...DomandeDelCerchio.personaliPerLaGettata,
      ])
        normalizza(q.testo): come.contains(normalizza(q.testo))
            ? TipoDiDomanda.come
            : previsione.contains(normalizza(q.testo))
                ? TipoDiDomanda.previsione
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
  ///
  /// **Una pietra dritta nell'Ostacolo non prende il senso del suo verso
  /// d'ombra**: il lettore cieco indipendente dell'ordine GA l'ha letto come
  /// un "senso rovesciato su una pietra dritta" (Raidho dritta "un cammino
  /// che ha perso la cadenza", Gebo "uno scambio che pende da un lato").
  /// Dritta, nell'Ostacolo, la pietra frena con la sua stessa qualita'
  /// portata all'eccesso o ancora da conquistare ([ostacoloDritto]).
  static String latoDifficile(RunaGettata p) {
    if (p.inOmbra) return di(p).senso;
    return di(p).lato ?? ostacoloDritto[p.rune.name]!;
  }

  /// Come frena una pietra dritta non simmetrica quando cade nell'Ostacolo.
  static const Map<String, String> ostacoloDritto = {
    'Fehu': 'la paura di perdere ciò che hai',
    'Uruz': 'una forza che spinge oltre misura',
    'Thurisaz': 'una difesa che si irrigidisce in muro',
    'Ansuz': 'parole che ancora non sono state dette',
    'Raidho': 'una strada più lunga di quanto speri',
    'Kenaz': 'un punto che non hai ancora guardato alla luce',
    'Wunjo': 'il desiderio che tutto sia già perfetto',
    'Nauthiz': 'un bisogno che stringe e chiede pazienza',
    'Perthro': 'ciò che ancora non si può sapere',
    'Algiz': 'una prudenza che rischia di chiuderti',
    'Tiwaz': 'il prezzo che la scelta giusta chiede',
    'Berkano': 'una crescita lenta che chiede cura',
    'Ehwaz': 'un passo che dipende anche da un altro',
    'Mannaz': 'lo sguardo degli altri su di te',
    'Laguz': 'un sentire che non trova ancora parole',
    'Othala': 'l’attaccamento a ciò che conosci',
  };

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
        animo: 'ricorda ciò che hai già, senza l’ansia di perderlo'),
    'Fehu/ombra': LaPietraLetta(
        classe: ClasseDellaPietra.correggi,
        senso: 'un bene che si disperde',
        modo: 'guardando dove si disperde ciò che hai',
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
        animo: 'riconosci la forza che hai e non sprecarla in timori'),
    'Uruz/ombra': LaPietraLetta(
        classe: ClasseDellaPietra.attesa,
        senso: 'una forza da ritrovare prima di caricare',
        modo: 'ritrovando il ritmo prima di caricare',
        criterio: 'non ti costringe a forzare',
        nonFare: 'Non caricare a testa bassa prima di aver ritrovato il ritmo.',
        animo: 'ritrova il tuo ritmo e non caricarti di troppo'),
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
        senso: 'un ritmo che ha perso la cadenza',
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
        lato: 'l’obbligo che nasce da un dono ricevuto',
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
        lato: 'una scossa da attraversare',
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
        lato: 'i tempi lunghi della maturazione'),
    // Eihwaz: "Reggi: ciò che sembra piegarti non ti spezza."
    'Eihwaz/dritta': LaPietraLetta(
        classe: ClasseDellaPietra.prudenza,
        verdetto: 'Sì, se tieni duro',
        senso: 'una tenuta che regge il vento',
        modo: 'tenendo duro senza irrigidirti',
        criterio: 'regge alla prova del tempo',
        nonFare: 'Non mollare al primo vento contrario.',
        animo: 'tieni duro senza irrigidirti',
        lato: 'una prova che chiede di resistere',
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
        animo: 'non forzare la sorte e accetta i suoi tempi'),
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
        animo: 'tieni lo sguardo su ciò che conta davvero',
        lato: 'una luce che abbaglia invece di guidare'),
    // Tiwaz: "Prendi ciò che ti spetta, non ciò che si strappa." /
    // "Ritrova il tuo giusto: la mira torna ferma."
    'Tiwaz/dritta': LaPietraLetta(
        classe: ClasseDellaPietra.via,
        senso: 'il coraggio di ciò che è giusto',
        modo: 'a viso aperto, con onestà',
        criterio: 'puoi difendere a testa alta',
        nonFare: 'Non prendere scorciatoie che non potresti spiegare.',
        animo: 'dì il vero con te e con gli altri'),
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
        senso: 'un’alleanza che procede insieme',
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
        modo: 'preparando con calma ciò che vuoi compiere',
        criterio: 'ti lascia completare ciò che hai avviato',
        nonFare: 'Non annunciare prima del tempo.',
        animo: 'custodisci le forze e preparati in silenzio',
        lato: 'un lavoro interiore non ancora compiuto'),
    // Dagaz: "Un nuovo giorno comincia: cambia passo con la luce."
    'Dagaz/dritta': LaPietraLetta(
        classe: ClasseDellaPietra.via,
        senso: 'una svolta chiara',
        modo: 'cambiando passo adesso',
        criterio: 'segna un cambiamento vero',
        nonFare: 'Non restare sulla soglia.',
        animo: 'tieni viva la fiducia e non decidere a caldo',
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
        animo: 'tieni ciò che ti sostiene e guarda con calma ciò che ti pesa',
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
        // Una domanda aperta ("che cosa mi sfugge di questa situazione") non
        // chiede se muoversi: "è il momento di muoverti" sopra una pietra che
        // dice "resta dove hai radici" si contraddiceva (lettura severa del
        // terzo giro). La conclusione dice come tenere conto di cio' che la
        // gettata indica.
        final conclusione = switch (c) {
          ClasseDellaPietra.via => 'tienine conto nelle tue scelte',
          ClasseDellaPietra.prudenza => 'tienine conto, ma con cautela',
          ClasseDellaPietra.attesa => 'dagli ancora tempo',
          ClasseDellaPietra.sosta => 'adesso fermati e non forzare',
          ClasseDellaPietra.correggi => 'prima correggi ciò che non funziona',
        };
        fuori.addAll([
          'Per $tema la gettata indica ${p.senso}: $conclusione.',
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
    final propria = s != q.tema &&
        s != 'ciò che hai chiesto' &&
        s != 'il tuo momento' &&
        s != 'questo momento';
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

  static List<String> _limite(AmbitoDelicato a, {bool terapia = false}) =>
      switch (a) {
        AmbitoDelicato.salute when terapia => [
            'Nessuna terapia si sospende per una gettata: decidono i medici '
                'che ti seguono, non le rune.',
            'Sulle medicine decidono i medici che ti seguono, non le rune: '
                'non sospendere né cambiare niente senza averne parlato con '
                'loro.',
          ],
        AmbitoDelicato.salute => [
            'Su come andrà decidono i medici che ti seguono, non le rune: '
                'porta a loro ogni domanda e ogni dubbio.',
            'Sull’esito decidono i medici che ti seguono, non le rune: porta '
                'a loro ogni domanda.',
          ],
        AmbitoDelicato.legge => [
            'Le rune non predicono l’esito di una vicenda legale e non sostituiscono '
                'un avvocato: ogni passo va deciso con chi ti assiste.',
            'Le rune non predicono l’esito di una vicenda legale: ogni passo va '
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

  /// Una lista ruotata di [passo] posti: la stessa persona che rifa' la stessa
  /// domanda non legge sempre la stessa forma.
  static List<T> _ruotata<T>(List<T> l, int passo) => [
        for (var i = 0; i < l.length; i++) l[(i + passo) % l.length],
      ];

  /// **LE PAROLE DELL'AMBITO DELICATO.** Ordine GA voce GA.06, riapertura: la
  /// cosa di cui si parla ("per il tuo stato d'animo" su un'operazione al
  /// ginocchio non diceva niente), chi decide davvero e che cosa la runa non
  /// sa.
  static String cosaDelicata(AmbitoDelicato a) => switch (a) {
        AmbitoDelicato.salute => 'questo periodo',
        AmbitoDelicato.legge => 'questa vicenda',
        AmbitoDelicato.denaro => 'questa decisione',
      };

  static String _cheNonSa(AmbitoDelicato a) => switch (a) {
        AmbitoDelicato.salute => 'i tuoi esami e la tua storia clinica',
        AmbitoDelicato.legge => 'le tue carte e le tue scadenze',
        AmbitoDelicato.denaro => 'i tuoi conti e i tuoi impegni',
      };

  static String _tempoDelicato(AmbitoDelicato a) => switch (a) {
        AmbitoDelicato.salute => 'il modo di attraversare questo periodo',
        AmbitoDelicato.legge => 'il modo di reggere i tempi della vicenda',
        AmbitoDelicato.denaro => 'il modo di prendere questa decisione',
      };

  /// **IL TITOLO DEL RESPONSO SU SALUTE, LEGGE O DENARO.** Era la riga della
  /// pietra che decide, scritta per ogni domanda: "Un nuovo giorno: cambia
  /// stato con lui" sopra una frase che manda dal consulente (simulazione sul
  /// Realme, gruppo C, D8), "Apri la mano" su un investimento. Qui il titolo
  /// dice il limite, nelle parole dell'ambito.
  static String titoloDelicato(AmbitoDelicato a, RunaGettata decide) {
    final titoli = switch (a) {
      AmbitoDelicato.salute => [
          'Le rune non sostituiscono chi ti cura.',
          'Prima di ogni decisione ascolta chi ti segue.',
          'Su questo parla il medico, la runa ti accompagna.',
        ],
      AmbitoDelicato.legge => [
          'Le rune non sostituiscono un avvocato.',
          'Prima di ogni mossa parla con chi ti assiste.',
          'Su questo parla chi conosce la legge.',
        ],
      AmbitoDelicato.denaro => [
          'Prima di muovere denaro, fermati.',
          'Su questo parla chi conosce i tuoi numeri.',
          'Per i tuoi soldi serve un consulente, non un presagio.',
        ],
    };
    return titoli[
        IlPresagioDalCorpus.seme('${decide.rune.name}|${decide.inOmbra}') %
            titoli.length];
  }

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
    int variante = 0,
  }) {
    final ambito = domanda.delicato!;
    final animo = animoDelicato(IlPresagioDalCorpus.pietraCheDecide(esito));
    final tempo = _tempoDelicato(ambito);
    final seconde = _ruotata([
      'Ciò che la runa uscita può darti è $tempo: $animo, un giorno '
          'alla volta, senza decidere niente sulla base di questa gettata.',
      'La runa uscita non dice come andrà: ti offre $tempo. '
          '${maiuscola(animo)}, un giorno alla volta.',
      'Dalla runa uscita puoi avere solo $tempo: $animo, senza cercare '
          'in lei ciò che spetta ad altri.',
      'Per $tempo la runa uscita ti consiglia questo: $animo.',
    ], variante);
    final toni = frasiDelTono(esito);
    final candidati = [
      for (final l
          in _ruotata(_limite(ambito, terapia: domanda.suTerapia), variante))
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
      return _riquadroDelicato(domanda.delicato!, variante,
          terapia: domanda.suTerapia);
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

  static String? _riquadroDelicato(AmbitoDelicato a, int variante,
      {bool terapia = false}) {
    final primi = switch (a) {
      AmbitoDelicato.salute when terapia => [
          'Non sospendere e non cambiare nessuna medicina prima di averne '
              'parlato con chi ti segue: scrivi i dubbi che hai e portali alla '
              'prossima visita.',
          'Se una medicina ti pesa, dillo a chi ti segue senza interromperla '
              'da solo: chiedi che cosa si può cambiare e annota la risposta '
              'che ti danno.',
          'Annota gli effetti che noti e quando compaiono e portali a chi ti '
              'segue: è chi ti cura, con i tuoi esami, a poter dire se la '
              'terapia va cambiata.',
          'Fissa con chi ti segue un momento per parlare della terapia e '
              'arrivaci con le domande già scritte: nessuna medicina si '
              'toglie per una sensazione o per un presagio.',
        ],
      AmbitoDelicato.salute => [
          'Scrivi su un foglio le domande che hai e portale a chi ti segue '
              'alla prossima visita: lì stanno le risposte sull’esito.',
          'Prima della visita elenca i dubbi che ti pesano, uno per riga e '
              'chiedi a chi ti segue di rispondere a ognuno con parole '
              'semplici.',
          'Annota che cosa senti e che cosa ti preoccupa e portalo a chi ti '
              'segue: è chi ti cura che può dirti che cosa aspettarti '
              'davvero.',
          'Fissa con chi ti segue il momento per parlare di dubbi e paure e '
              'arrivaci con le domande già scritte: ti aiuteranno a non '
              'dimenticare nulla.',
          'Chiedi a chi ti segue di spiegarti ogni passo che ti aspetta e '
              'scrivi le risposte: sapere che cosa succede toglie peso '
              'all’attesa.',
        ],
      AmbitoDelicato.legge => [
          'Raccogli in ordine carte, date e messaggi e portali a un avvocato '
              'prima di qualunque passo: è lì che si decide come muoversi.',
          'Prima di ogni mossa scrivi i fatti con le date esatte e le '
              'domande che vuoi fare e portali a un avvocato che possa '
              'leggerli per intero.',
          'Non rispondere, non firmare e non inviare niente che riguardi la '
              'vicenda senza averne parlato prima con chi ti assiste: ogni '
              'parola scritta pesa.',
          'Chiedi a un avvocato quali sono i tempi, le possibilità e i '
              'rischi reali e fatteli spiegare in parole semplici prima di '
              'decidere qualunque cosa.',
          'Tieni in un solo posto tutti i documenti che riguardano la '
              'vicenda e controlla con chi ti assiste che non manchi nulla '
              'prima della prossima scadenza.',
        ],
      AmbitoDelicato.denaro => [
          'Prima di muovere denaro fissa un incontro con un consulente '
              'finanziario e chiedi per iscritto rischi e costi di ogni '
              'strada.',
          'Scrivi quanto hai, quanto devi e quanto puoi permetterti di '
              'perdere senza intaccare ciò che ti serve per vivere e '
              'portalo a un consulente.',
          'Non firmare e non versare niente finché non hai letto per '
              'iscritto costi, rischi e scadenze insieme a chi conosce i '
              'tuoi numeri.',
          'Chiedi a un consulente di mostrarti con cifre vere lo scenario '
              'peggiore e quello migliore e decidi solo dopo averli '
              'guardati entrambi.',
          'Metti sul tavolo tutte le cifre che hanno già un impegno e fatti '
              'dire da un esperto che margine ti resta davvero prima di ogni '
              'scelta.',
        ],
    };
    // "Nei giorni che mancano" non diceva a che cosa (il lettore cieco
    // indipendente: "mancano a cosa?"): il tempo e' quello fino all'incontro
    // che la prima frase ha appena chiesto. Niente atteggiamento della
    // pietra qui: sta gia' nel paragrafo, e ripeterlo in tre punti (paragrafo,
    // riquadro, titolo) e' il difetto che il lettore ha contato sull'operazione
    // al ginocchio.
    final finoA = switch (a) {
      AmbitoDelicato.salute => 'fino alla visita',
      AmbitoDelicato.legge => 'fino all’incontro con l’avvocato',
      AmbitoDelicato.denaro =>
        'fino all’incontro con il consulente finanziario',
    };
    final secondi = [
      'Non decidere niente sulla base di questa gettata: $finoA ogni scelta '
          'aspetta chi può guardare i dati veri.',
      'Questa gettata non può sostituire i fatti: $finoA non prendere '
          'decisioni definitive e lascia che sia chi se ne intende a dire '
          'l’ultima parola.',
      'Non decidere niente sulla base di questa gettata. Il suo posto è '
          'accanto a ciò che senti, mai al posto di chi può guardare le tue '
          'carte, i tuoi numeri o i tuoi esami.',
    ];
    const code = [
      '',
      'Un giorno alla volta.',
      'Il resto non dipende da te.',
      'Tieni il foglio con le domande sempre a portata di mano.',
      'Chiedi tutto ciò che non ti è chiaro, anche due volte.',
    ];
    final candidati = [
      for (final f in _ruotata(primi, variante))
        for (final s in _ruotata(secondi, variante))
          for (final c in code) c.isEmpty ? '$f $s' : '$f $s $c',
    ];
    return primaCheSta(
        candidati, LaFormaDelResponso.minimo, LaFormaDelResponso.massimo);
  }

  // -------------------------------------------------------------------------
  // LE SCHEDE DELLE PIETRE SU SALUTE, LEGGE E DENARO
  // -------------------------------------------------------------------------

  static String _versoParola(RunaGettata p) =>
      p.inOmbra ? 'rovesciata' : 'dritta';

  /// Chi decide davvero, con la preposizione "a": tre modi per ambito, uno per
  /// scheda, perche' le schede della stessa gettata non lo ripetano uguale.
  static String _chiA(AmbitoDelicato a, [int k = 0]) {
    final l = switch (a) {
      AmbitoDelicato.salute => const [
          'ai medici che ti seguono',
          'a chi ti cura',
          'al medico che conosce il tuo caso',
        ],
      AmbitoDelicato.legge => const [
          'a chi ti assiste',
          'a un avvocato',
          'a un legale che conosca le tue carte',
        ],
      AmbitoDelicato.denaro => const [
          'a un consulente che conosca i tuoi numeri',
          'a un consulente finanziario',
          'a chi sa leggere i tuoi conti',
        ],
    };
    return l[k % l.length];
  }

  static String _chiCon(AmbitoDelicato a, [int k = 0]) {
    final l = switch (a) {
      AmbitoDelicato.salute => const [
          'con i medici che ti seguono',
          'con chi ti cura',
          'con il medico che conosce il tuo caso',
        ],
      AmbitoDelicato.legge => const [
          'con chi ti assiste',
          'con un avvocato',
          'con un legale che conosca le tue carte',
        ],
      AmbitoDelicato.denaro => const [
          'con un consulente che conosca i tuoi numeri',
          'con un consulente finanziario',
          'con chi sa leggere i tuoi conti',
        ],
    };
    return l[k % l.length];
  }

  /// **IL PARAGRAFO DI UNA PIETRA QUANDO LA DOMANDA TOCCA SALUTE, LEGGE O
  /// DENARO.** Ordine GA voce GA.06, riapertura. Il corpus PIETRA e' scritto
  /// per ogni domanda ("Offri quanto serve perche' il legame cresca", "dentro
  /// il tuo stato d'animo manca il rispetto"): sotto un'operazione o un
  /// investimento il lettore cieco ha letto schede che parlavano d'altro. Qui
  /// la pietra dice il suo senso nel suo posto e niente sull'esito, e rimanda
  /// a chi decide davvero. [indice] e' la posizione della pietra nella
  /// gettata, e sceglie la forma, perche' le schede della stessa gettata non
  /// aprano tutte allo stesso modo. Ogni forma ha una coda che la porta fra
  /// 40 e 50 parole quando il senso della pietra e' corto.
  static String schedaDelicata({
    required AmbitoDelicato ambito,
    required RunaGettata pietra,
    required int indice,
    int variante = 0,
  }) {
    final forme =
        formeSchedaDelicata(ambito: ambito, pietra: pietra, chi: indice);
    for (var k = 0; k < forme.length; k++) {
      final f = forme[(indice + variante + k) % forme.length];
      if (LaFormaDelResponso.aMisura(f)) return f;
    }
    return forme[(indice + variante) % forme.length];
  }

  /// "di" davanti a un sintagma con l'articolo, contratto: "parla del passo
  /// giusto", non "parla di il passo giusto" (lettura severa del terzo giro).
  static String _di(String s) {
    for (final (art, con) in const [
      ('il ', 'del '),
      ('lo ', 'dello '),
      ('la ', 'della '),
      ('l’', 'dell’'),
      ('i ', 'dei '),
      ('gli ', 'degli '),
      ('le ', 'delle '),
    ]) {
      if (s.startsWith(art)) return '$con${s.substring(art.length)}';
    }
    return 'di $s';
  }

  /// **IL SENSO DI UNA PIETRA SOTTO SALUTE, LEGGE O DENARO**, quando quello
  /// scritto per ogni domanda ("senso" in [LaPietraLetta.tutte]) suona come
  /// un esito o un consiglio: "un bene che cresce quando circola" sotto un
  /// investimento, "un bene che si disperde" e "una rottura che libera
  /// spazio" sotto un'operazione al ginocchio, "una crescita che si è
  /// fermata" sotto "Rimarrò incinta?". Lettura severa del terzo giro; padre:
  /// i sensi scritti per ogni domanda, ordine GA voce GA.06, riapertura.
  /// Null: vale il senso di sempre.
  static String? sensoDelicato(AmbitoDelicato ambito, RunaGettata pietra) {
    final k = '${pietra.rune.name}/${pietra.inOmbra ? 'ombra' : 'dritta'}';
    final denaro = ambito == AmbitoDelicato.denaro;
    return switch (k) {
      'Fehu/dritta' => denaro
          ? 'il valore di ciò che possiedi, da guardare con chiarezza'
          : 'ciò che hai da custodire con cura',
      'Fehu/ombra' => denaro
          ? 'un rapporto con ciò che possiedi da rivedere con calma'
          : 'una presa troppo stretta da allentare',
      'Hagalaz/dritta' => 'un passaggio che scuote e poi lascia spazio',
      'Thurisaz/ombra' => 'una fretta da evitare',
      'Berkano/dritta' => 'una cura che chiede costanza',
      'Berkano/ombra' => 'una cura da riprendere con pazienza',
      'Othala/ombra' => 'un vecchio schema che trattiene',
      'Jera/dritta' => 'un tempo che ha i suoi ritmi',
      _ => null,
    };
  }

  /// **L'ATTEGGIAMENTO DI UNA PIETRA SOTTO SALUTE, LEGGE O DENARO.** Come
  /// [sensoDelicato]: "ricorda ciò che hai, senza l'ansia di perderlo" sotto
  /// un'operazione o un investimento presume un'ansia e suona come un
  /// consiglio sui beni, e "non lasciare che la paura ti spinga a forzare"
  /// presume una paura. Null: vale l'atteggiamento di sempre.
  static String animoDelicato(RunaGettata pietra) {
    final k = '${pietra.rune.name}/${pietra.inOmbra ? 'ombra' : 'dritta'}';
    return switch (k) {
      'Fehu/dritta' => 'ricorda ciò che hai già e custodiscilo con cura',
      'Fehu/ombra' => 'allenta la presa e tieni solo ciò che serve',
      'Nauthiz/ombra' => 'non lasciare che l’urgenza ti spinga a forzare',
      _ => LaPietraLetta.di(pietra).animo,
    };
  }

  /// Le otto forme del paragrafo di una pietra su salute, legge o denaro,
  /// ognuna con la coda che la porta fra 40 e 50 parole (la prima che ci
  /// sta). Lo pretende la prova, per ogni pietra, posto e ambito.
  static List<String> formeSchedaDelicata({
    required AmbitoDelicato ambito,
    required RunaGettata pietra,
    int chi = 0,
  }) {
    final p = LaPietraLetta.di(pietra);
    final r = '${pietra.rune.name} ${_versoParola(pietra)}';
    final dov = dove(pietra.posizione);
    // Nemmeno nell'Ostacolo si dice "il lato difficile" della pietra ("la
    // paura di cambiare stato" sotto un investimento, lettura severa del
    // terzo giro): sotto salute, legge e denaro il posto non si legge come un
    // freno, e la scheda dice il senso della pietra.
    final senso = sensoDelicato(ambito, pietra) ?? p.senso;
    final cosa = cosaDelicata(ambito);
    final chiA = _chiA(ambito, chi);
    final chiCon = _chiCon(ambito, chi + 1);
    final nonSa = _cheNonSa(ambito);
    // Le code cambiano da una scheda all'altra: "un giorno alla volta" in
    // fondo a quattro schede su sette era la formula che il lettore cieco ha
    // contato (rune-31: "un giorno alla volta" tre volte).
    final code = _ruotata(const [
      '',
      ' Un giorno alla volta.',
      ' Passo dopo passo, con calma.',
      ' Senza forzare i tempi.',
      ' Senza fretta, un giorno alla volta.',
      ' Con calma e senza fretta, passo dopo passo.',
      ' Un giorno alla volta, senza cercare certezze che nessuno può dare.',
      ' Non serve altro, per ora: un giorno alla volta, senza cercare '
          'certezze che nessuno può dare.',
    ], chi);
    final nuclei = [
      '$r, $dov, indica $senso. Non dice come andrà $cosa: nessuna runa lo '
          'sa e la parola decisiva spetta $chiA. Ti dice invece con che '
          'animo attraversare questo tratto.',
      '$r $dov: $senso. Non è una previsione su $cosa e nessuna gettata '
          'può esserlo. È un invito a stare presente a ciò che senti, mentre '
          'le decisioni che contano restano $chiA.',
      'Il segno di $r $dov è $senso. Su $cosa la runa non sa niente di '
          'concreto, perché non conosce $nonSa. Per il resto rivolgiti '
          '$chiA.',
      '$r $dov parla ${_di(senso)}. Non è un verdetto su $cosa: il verdetto, '
          'se c’è, lo danno i fatti, letti $chiCon.',
      'Per $cosa, $r $dov non promette e non nega: indica $senso. Resta con '
          'questo e porta ogni dubbio concreto $chiA, perché venga guardato '
          'davvero.',
      '$r, $dov, mostra $senso. Non risponde alla tua domanda su $cosa: '
          'risponde a un’altra, più vicina, cioè come vuoi stare mentre '
          'aspetti. Per le domande pratiche rivolgiti $chiA.',
      '$r, $dov, porta $senso. Su $cosa questo non è un annuncio: è '
          'un’indicazione sul tuo modo di stare, mentre la parte concreta '
          'resta $chiA.',
      'Che cosa accadrà per $cosa, $r $dov non lo sa: lo dicono i fatti, '
          'letti $chiCon. Quello che sa dirti è $senso.',
    ];
    return [
      for (final n in nuclei)
        code.map((c) => '$n$c').firstWhere(LaFormaDelResponso.aMisura,
            orElse: () =>
                '$n${code.reduce((a, b) => a.length >= b.length ? a : b)}'),
    ];
  }

  /// Le dieci forme del "Cosa fare" di una pietra su salute, legge o denaro
  /// (la gettata sul telo ha sette pietre, due schede non hanno lo stesso
  /// testo, e nessuna ripete il riquadro del responso principale). Ognuna sta fra 40 e 50 parole (lo pretende la prova).
  static List<String> formeConsiglioDelicato(AmbitoDelicato ambito) {
    return switch (ambito) {
      AmbitoDelicato.salute => [
          'Scrivi le domande che hai e portale a chi ti segue alla prossima '
              'visita: nessuna gettata può rispondere al posto suo. Intanto '
              'non cercare presagi in ogni piccolo segnale e concediti '
              'momenti di quiete che non dipendano dall’esito, anche brevi.',
          'Chiedi a chi ti segue di spiegarti con parole semplici che cosa '
              'aspetta e che cosa è possibile e annota le risposte. Sapere '
              'come stanno le cose è più utile di qualunque lettura: porta '
              'alla visita le tue paure scritte.',
          'Prima di ogni scelta che riguarda le cure parlane con chi ti '
              'segue: la runa non sostituisce il suo parere e non lo '
              'corregge. Se un dubbio ti toglie la pace, chiamalo per nome e '
              'portalo alla prossima visita, senza vergognarti.',
          'Fatti accompagnare alla visita da una persona fidata, che ascolti '
              'con te e ricordi quello che viene detto. Poi rileggi gli '
              'appunti insieme a quella persona: due paia di orecchie '
              'capiscono più di uno solo, soprattutto quando il cuore è '
              'agitato.',
          'Tieni un quaderno con le domande che ti vengono in mente nei '
              'giorni di attesa e portalo con te alla visita. Non lasciare '
              'che sia l’ansia a decidere che cosa chiedere: scrivere ti '
              'aiuta a distinguere i dubbi veri dalle paure.',
          'Se hai bisogno di un parere in più, chiedilo a un altro medico o '
              'a chi ti segue, ma non a una gettata: le rune parlano di come '
              'stai tu, non di che cosa dicono gli esami. Concediti tempo e '
              'riposo, senza fretta di sapere.',
          'Prima della visita decidi con una persona di fiducia quali tre '
              'cose vuoi capire e chiedile di ascoltare con te. Nessuna runa '
              'conosce le tue analisi: chi le ha davanti può spiegarti che '
              'cosa significano, con calma e senza promettere più di quanto '
              'sa.',
          'Se in questi giorni ti vengono in mente sintomi o dubbi nuovi, '
              'annotali con la data e comunicali a chi ti segue senza '
              'aspettare la visita. Le rune non sono un esame: servono a '
              'stare più saldo, mentre le risposte vere vengono da chi ti '
              'cura.',
          'Dedica ogni giorno un momento a qualcosa che ti calma e non ha '
              'a che fare con l’attesa: una musica, una tazza calda, due '
              'righe su un quaderno. Quando arriva il momento di decidere, '
              'affidati alle parole di chi ti segue e non a un presagio.',
          'Di’ a una persona vicina di che cosa hai bisogno in questi '
              'giorni, anche solo di compagnia o di una telefonata. Le rune '
              'non possono sostituire chi ti cura, ma una presenza amica '
              'aiuta: lascia che qualcuno ti stia accanto mentre aspetti le '
              'risposte vere.',
        ],
      AmbitoDelicato.legge => [
          'Raccogli in un fascicolo carte, date e messaggi che riguardano la '
              'vicenda e portali a un avvocato prima di ogni mossa. Nessuna '
              'gettata conosce i fatti: chi li ha davanti può dirti che cosa '
              'è possibile e che cosa è prudente fare.',
          'Scrivi le domande che vuoi fare a chi ti assiste, una per riga e '
              'fatti spiegare i rischi in parole semplici. Non firmare e non '
              'inviare niente che riguardi la vicenda senza averne parlato '
              'con un avvocato. Poi decidi con calma, a mente fredda.',
          'Prima di rispondere a una lettera o a un messaggio che riguarda '
              'la vicenda, chiedi a un avvocato come farlo. Una frase scritta '
              'd’impulso può pesare molto: dai alla calma il tempo che serve '
              'e lascia che sia un parere competente a guidarti.',
          'Tieni un elenco delle date che contano e controlla con chi ti '
              'assiste che nessuna scadenza ti sfugga. La runa non può '
              'sapere che cosa prevede la legge nel tuo caso: per questo '
              'serve chi la conosce e può leggere le tue carte.',
          'Evita di discutere la vicenda a caldo con l’altra parte: ogni '
              'parola detta o scritta può essere ripresa più avanti, anche a '
              'distanza di mesi. Prima parlane con un avvocato, che può '
              'dirti che cosa è prudente dire e quando, senza lasciarti '
              'guidare dalla fretta.',
          'Chiedi a un avvocato quali sono i tempi e le possibilità reali '
              'nel tuo caso e quali sono i costi. Decidere con i dati veri '
              'toglie peso all’attesa; decidere sulla base di una gettata non '
              'cambia i fatti e non li conosce.',
          'Prima di dire o firmare qualcosa sulla vicenda scrivi in tre '
              'righe che cosa vuoi ottenere e che cosa temi e portale a un '
              'avvocato. Sarà l’avvocato a dirti se la strada è praticabile: '
              'una gettata non conosce le leggi né i tempi del tuo caso.',
          'Metti in ordine ricevute, contratti e messaggi in una cartella, '
              'dal più vecchio al più recente e porta tutto a chi ti '
              'assiste. Non cercare nelle rune una sentenza: il parere che '
              'conta nasce dai documenti e da chi sa leggerli, con calma e '
              'metodo.',
          'Prima di raccontare la vicenda a qualcuno, decidi con un '
              'avvocato che cosa è bene dire e che cosa tacere. Anche una '
              'conversazione amichevole può tornare utile all’altra parte: la '
              'prudenza non è sospetto, è cura di te e delle tue ragioni.',
          'Chiedi a chi ti assiste quali scadenze hai davanti e che cosa '
              'succede se non le rispetti e segnala la data sul calendario '
              'con un margine di sicurezza. Nessuna gettata sa leggere un '
              'termine di legge: un errore di data può costare più di '
              'qualunque attesa.',
        ],
      AmbitoDelicato.denaro => [
          'Prima di muovere denaro fissa un incontro con un consulente che '
              'conosca i tuoi numeri e chiedi per iscritto rischi e costi di '
              'ogni strada. Nessuna gettata sa quanto hai, quanto devi e '
              'quanto puoi permetterti di perdere, nemmeno a grandi linee.',
          'Scrivi quanto ti serve ogni mese per vivere e quanto puoi '
              'permetterti di perdere e portalo a un consulente prima di '
              'scegliere. Sono questi numeri a dire che cosa è prudente, non '
              'una runa e non un presagio. Il resto può aspettare.',
          'Non firmare e non versare niente finché non hai letto con calma, '
              'per iscritto, costi, rischi e scadenze. Se qualcuno ti mette '
              'fretta, prendi tempo: una buona occasione resiste a una '
              'settimana di verifiche fatte con chi se ne intende.',
          'Chiedi a un consulente di mostrarti con cifre vere lo scenario '
              'peggiore oltre a quello migliore e guardali entrambi prima '
              'di decidere. La runa non conosce i tuoi conti: chi li guarda '
              'con te può darti un parere che regge.',
          'Metti per iscritto gli impegni che hai già e il margine che ti '
              'resta e confrontalo con un esperto. Decidere dopo aver visto '
              'i numeri è più sereno che decidere sperando in un segno: i '
              'segni non entrano nel tuo bilancio.',
          'Dai a questa scelta il tempo che chiede e non lasciare che sia '
              'l’urgenza a decidere. Un parere competente sui tuoi conti '
              'viene prima di qualunque gettata: se non lo hai ancora, '
              'cercalo e solo dopo torna a chiederti che cosa senti.',
          'Prima di impegnare una somma parlane con un consulente e porta '
              'con te le cifre vere: entrate, spese, debiti, risparmi. '
              'Nessun segno sostituisce un conto fatto bene. Se la proposta '
              'non lascia il tempo di verificare, prendi comunque quel '
              'tempo.',
          'Immagina il caso peggiore e scrivi quanto ti costerebbe davvero; '
              'poi chiedi a un consulente se potresti sostenerlo. Una runa '
              'non sa dirti se i tuoi conti reggono e nessun presagio ti '
              'restituirebbe una somma perduta: la prudenza si fa con i '
              'numeri, prima di decidere.',
          'Se ti viene voglia di decidere subito, aspetta un giorno e '
              'riparlane con una persona di fiducia che non abbia interesse '
              'nella scelta. Poi porta i numeri a un consulente. Una runa non '
              'conosce i tuoi conti e non può dirti quando è prudente '
              'muoverti.',
          'Distingui ciò che ti serve per vivere da ciò che puoi '
              'destinare a un rischio e scrivi le due somme. Porta il foglio '
              'a un consulente prima di decidere: la runa non sa quanto pesa '
              'per te una perdita. Solo chi vede i tuoi conti può aiutarti a '
              'misurarla.',
        ],
    };
  }

  /// Il "Cosa fare" di una pietra su salute, legge o denaro: dice il limite e
  /// manda a chi e' competente, come il principale, ma con un'azione diversa
  /// per ogni posizione della gettata.
  static String consiglioDelicato({
    required AmbitoDelicato ambito,
    required int indice,
    int variante = 0,
    String? escludi,
  }) {
    // Mai la stessa cosa che il responso principale ha appena detto nel suo
    // riquadro (lettura severa del terzo giro: "Prima di muovere denaro fissa
    // un incontro con un consulente" sopra e dentro la scheda).
    final tutte = formeConsiglioDelicato(ambito);
    final altre = escludi == null
        ? tutte
        : [
            for (final f in tutte)
              if (!_simile(f, escludi)) f
          ];
    final forme = altre.length >= 7 ? altre : tutte;
    return forme[(indice + variante) % forme.length];
  }

  /// Due frasi che dicono la stessa cosa: le prime frasi condividono almeno
  /// la meta' delle parole lunghe della piu' corta.
  static bool _simile(String a, String b) {
    Set<String> parole(String s) => {
          for (final m in RegExp(r'[a-zà-ÿ]{4,}')
              .allMatches(s.split(RegExp(r'[.:;]')).first.toLowerCase()))
            m[0]!
        };
    final x = parole(a);
    final y = parole(b);
    if (x.isEmpty || y.isEmpty) return false;
    final comuni = x.intersection(y).length;
    return comuni / (x.length < y.length ? x.length : y.length) >= 0.5;
  }

  // -------------------------------------------------------------------------
  // L'APPROFONDIMENTO DELLA LUNGA
  // -------------------------------------------------------------------------

  /// **L'APPROFONDIMENTO DELLA GETTATA, COMPOSTO DALLE PIETRE USCITE.** Ordine
  /// GA voce GA.06, riapertura. Era una voce del corpus LEGAME, scelta per
  /// gettata e per tono (quante pietre in ombra), e il tono non dice la
  /// direzione del responso: "Le tre pietre in luce dicono che il tempo è
  /// maturo" sotto un responso che diceva "nessun verdetto" e con Isa, la
  /// sosta, al centro (lettore cieco indipendente, rune-2); "Attraversalo senza
  /// esitare" sotto un "Aspetta"; "Un'ombra sul Cuore" con il Cuore dritto.
  /// Una frase che dice il vero di ogni gettata e' solo quella che descrive le
  /// pietre che ci sono: qui il paragrafo dice che cosa mostra ogni pietra nel
  /// suo posto (il suo senso, quello stesso dei titoli delle schede), conta le
  /// pietre in ombra come le conta il codice, e chiude con una frase che va
  /// nella direzione del responso principale, mai in un'altra.
  ///
  /// [direzione]: la classe del verdetto del responso principale, per le
  /// decisioni e le scelte; null per le altre domande, che non hanno un
  /// verdetto. [ambito]: salute, legge o denaro: allora il paragrafo non
  /// legge nessun esito (neanche "dove tende la strada"), dice solo
  /// l'atteggiamento che ogni pietra chiede, e chiude rimandando a chi e'
  /// competente.
  static String? approfondimento({
    required EsitoGettata esito,
    ClasseDellaPietra? direzione,
    AmbitoDelicato? ambito,
    int variante = 0,
  }) {
    final pietre = esito.rune;
    if (pietre.isEmpty) return null;
    final solo = pietre.length == 1;
    String senso(RunaGettata p) => p.posizione.titolo == 'Ostacolo'
        ? LaPietraLetta.latoDifficile(p)
        : LaPietraLetta.di(p).senso;
    RunaGettata? alPosto(String titolo) {
      for (final p in pietre) {
        if (p.posizione.titolo == titolo) return p;
      }
      return null;
    }

    final decide = IlPresagioDalCorpus.pietraCheDecide(esito);
    final aperture = <String>[];
    if (ambito != null) {
      // Gli atteggiamenti, la pietra che decide per prima.
      final ordine = [decide, ...pietre.where((p) => p != decide)];
      final animi = [for (final p in ordine) animoDelicato(p)];
      if (solo) {
        // Il significato scritto per ogni domanda non si apre sotto salute,
        // legge o denaro ("Il bestiame, il bene che circola" sotto un
        // investimento): la pietra dice il suo senso delicato, nel suo verso.
        final sensoSolo =
            sensoDelicato(ambito, decide) ?? LaPietraLetta.di(decide).senso;
        aperture.add('${decide.rune.name} ${_versoParola(decide)}: '
            '$sensoSolo. La runa non dice come andrà: chiede soltanto '
            'questo: ${animi.first}.');
      } else {
        for (final quanti in [3, 2]) {
          if (animi.length < quanti) continue;
          aperture.add('Le pietre non dicono come andrà e chiedono, in '
              'ordine: ${animi.take(quanti).join('; ')}.');
        }
      }
    } else {
      switch (esito.gettata.id) {
        case 'norne':
          if (pietre.length == 3) {
            aperture.addAll([
              'Le tre Norne raccontano un cammino: alle spalle '
                  '${senso(pietre[0])}, nel presente ${senso(pietre[1])}, '
                  'davanti a te ${senso(pietre[2])}.',
              'Da dove vieni, ${senso(pietre[0])}. Dove sei adesso, '
                  '${senso(pietre[1])}. Dove tende la strada, '
                  '${senso(pietre[2])}.',
            ]);
          }
        case 'croce':
          final cuore = alPosto('Cuore');
          final radice = alPosto('Radice');
          final ostacolo = alPosto('Ostacolo');
          final esitoP = alPosto('Esito');
          if (cuore != null &&
              radice != null &&
              ostacolo != null &&
              esitoP != null) {
            aperture.addAll([
              'Nel cuore della questione, ${senso(cuore)}. Ciò che ti frena, '
                  '${senso(ostacolo)}. Dove tende la questione, '
                  '${senso(esitoP)}.',
              'Nel cuore della questione, ${senso(cuore)}. Alla radice, '
                  '${senso(radice)}. Ciò che ti frena, ${senso(ostacolo)}. '
                  'Dove tende la questione, ${senso(esitoP)}.',
              'Cuore: ${senso(cuore)}. Ostacolo: ${senso(ostacolo)}. Esito: '
                  '${senso(esitoP)}.',
            ]);
          }
        case 'telo':
          final centro = alPosto('Al centro');
          final presso = alPosto('Presso il centro');
          if (centro != null && presso != null) {
            final margini = [
              for (final p in pietre)
                if (p.posizione.titolo == 'Ai margini') p.rune.name
            ];
            final elenco = margini.isEmpty
                ? ''
                : ' Ai margini si muovono voci più lievi: '
                    '${_elenco(margini)}.';
            aperture.addAll([
              'Sul telo, al centro, ${senso(centro)}; presso il centro, '
                  '${senso(presso)}.$elenco',
              'Il centro del telo porta ${senso(centro)} e accanto a lui '
                  '${senso(presso)}.$elenco',
            ]);
          }
        default:
          final p = pietre.first;
          final l = LaPietraLetta.di(p);
          // Una pietra in ombra non si apre con il significato della dritta:
          // "La betulla, la crescita che cura: qualcosa di nuovo germoglia"
          // sopra un responso che diceva "un germoglio che stenta" (lettura
          // severa del terzo giro).
          final apre = p.inOmbra
              ? '${p.rune.name} in ombra: ${l.senso}.'
              : p.rune.meaning;
          aperture.addAll([
            '$apre La runa agisce così: ${l.modo}. ${l.nonFare}',
            '$apre ${l.nonFare} Agisce così: ${l.modo}.',
          ]);
      }
    }
    if (aperture.isEmpty) {
      aperture.add('Le pietre uscite sono '
          '${_elenco([for (final p in pietre) p.rune.name])}.');
    }
    final toni = [
      '',
      ...frasiDelTono(esito).where((f) => !f.contains('lì serve')),
    ];
    // Le chiuse: la lunga e la breve. Con una pietra sola "letti insieme"
    // non si dice.
    final insieme = solo ? 'Letta così, la pietra' : 'Letti insieme, i segni';
    final insiemeBreve = solo ? 'Da sola la pietra' : 'Insieme i segni';
    // Il verbo concorda con "la pietra" o con "i segni" ("Da sola la pietra
    // non danno un verdetto", lettura severa del terzo giro).
    final danno = solo ? 'dà' : 'danno';
    final sostengono = solo ? 'sostiene' : 'sostengono';
    final chiedono = solo ? 'chiede' : 'chiedono';
    final dicono = solo ? 'dice' : 'dicono';
    final chiuse = ambito != null
        ? switch (ambito) {
            AmbitoDelicato.salute => [
                'Ogni scelta sulla salute spetta a chi ti segue.',
                'Per tutto ciò che riguarda le cure, decidono i medici.',
              ],
            AmbitoDelicato.legge => [
                'Ogni mossa con conseguenze reali spetta a un avvocato.',
                'Le scelte sulla vicenda spettano a chi ti assiste.',
              ],
            AmbitoDelicato.denaro => [
                'Cifre e rischi si guardano con un consulente.',
                'Su numeri e scadenze decide chi conosce i tuoi conti.',
              ],
          }
        : switch (direzione) {
            ClasseDellaPietra.via || ClasseDellaPietra.prudenza => [
                '$insieme $sostengono la direzione indicata sopra; resta tua '
                    'la misura del passo.',
                '$insiemeBreve $sostengono la strada del responso, col tuo '
                    'ritmo.',
                '$insiemeBreve $sostengono il responso.',
              ],
            ClasseDellaPietra.attesa || ClasseDellaPietra.sosta => [
                '$insieme $chiedono tempo: prima di ogni mossa lascia che ciò '
                    'che è fermo trovi il suo assetto.',
                '$insiemeBreve $chiedono quiete: la mossa giusta si vede dopo '
                    'una pausa.',
                '$insiemeBreve $chiedono quiete.',
              ],
            ClasseDellaPietra.correggi => [
                '$insieme $chiedono prima di correggere ciò che non regge: la '
                    'direzione si legge dopo.',
                '$insiemeBreve $dicono di sistemare un punto prima di '
                    'andare avanti.',
                '$insiemeBreve $chiedono prima una correzione.',
              ],
            null => [
                '$insieme non $danno un verdetto: ${solo ? 'mostra' : 'mostrano'} '
                    'il clima in cui vivi la domanda.',
                '$insiemeBreve non $danno un verdetto: '
                    '${solo ? 'descrive' : 'descrivono'} il tuo modo di stare '
                    'nella domanda.',
                '$insiemeBreve non $danno un verdetto.',
              ],
          };
    final candidati = <String>[];
    for (final c in chiuse) {
      for (final t in toni) {
        for (final a in aperture) {
          candidati.add([a, t, c].where((x) => x.isNotEmpty).join(' '));
        }
      }
    }
    final bene = [
      for (final c in candidati)
        if (LaFormaDelResponso.aMisura(c)) c,
    ];
    return bene.isEmpty ? null : bene[variante % bene.length];
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
      return '${maiuscola(dove(pietra.posizione))}, per te: '
          '${animoDelicato(pietra)}.';
    }
    // Nel Consiglio il titolo e' l'atteggiamento della pietra, detto a chi
    // legge ("Il consiglio: custodisci le forze e preparati in silenzio"):
    // il modo e' un gerundio scritto per continuare una frase, e da solo
    // diceva "Il consiglio: chiudendo prima le perdite che non vedi" (lettore
    // cieco indipendente, riapertura della voce GA.06).
    final che = switch (pietra.posizione.titolo) {
      'Ostacolo' => LaPietraLetta.latoDifficile(pietra),
      'Consiglio' => p.animo,
      _ => p.senso,
    };
    return '${ruolo(pietra.posizione)}: $che.';
  }
}
