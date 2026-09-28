import '../domande/cornici_del_presagio.dart';
import '../responsi/anatomia_del_responso.dart';
import '../responsi/confine_del_responso.dart';
import 'rune_cast.dart';

/// **LA GETTATA CHE INTERPRETA DAVVERO.** Ordine ER voce 01, 27 settembre
/// 2026.
///
/// Il fondatore: *"Adesso ho il dubbio che anche le estrazioni rune non
/// abbiano l'interpretazione come i tarocchi"*, e *"Le persone vogliono
/// risposte dirette, Senza tanti giochi di parole e cercano consigli e guide
/// anche su domande generiche."*
///
/// **Cosa c'era, verificato.** Il presagio passava gia' dal modello
/// dall'ordine S voce 19, ma il modello riceveva di ogni pietra il solo
/// significato generale e l'ordine di non nominarla fuori dalla terza parte,
/// in una o due righe: le pietre non si leggevano nella loro posizione ne'
/// rispetto alla domanda. Nessuno schema, nessuna guardia a valle. Quando il
/// modello mancava, la lettura di casa cuciva la riga fissa di ogni runa con
/// una delle sedici forme della posizione, uguale per ogni domanda.
///
/// **LA VIA SCELTA, ed e' di Code come chiede l'ordine.** La stessa della
/// Stesa dei Tarocchi (ordine EQ voce 04), che ha retto al collaudo: una
/// chiamata sola, con i campi obbligatori, che riceve per ogni pietra la sua
/// riga del corpus nel verso uscito, la posizione e la glossa della
/// posizione, e la cornice dell'allegato B quando la domanda e' una delle
/// sedici. Il modello scrive la risposta diretta, una lettura per pietra, il
/// legame fra le pietre e il consiglio. Le guardie guardano a valle; se la
/// lettura non regge parla la lettura di casa, come prima. **Il sistema a
/// scheletri del progetto resta**: le righe del corpus sono lo scheletro, e
/// il modello le interpreta sulla domanda, non le inventa.
///
/// La lettura arriva a schermo nelle tre parti dell'anatomia: la risposta, il
/// consiglio, e nella terza (da dove viene) le pietre e il loro legame, che
/// e' il solo posto dove le rune si nominano.
abstract final class LaLetturaDelleRune {
  /// I campi della risposta, nell'ordine in cui il modello li scrive.
  static const List<String> campi = [
    'posizione',
    'inBreve',
    'risposta',
    'pietre',
    'legame',
    'cosaPuoiFare',
  ];

  /// **LA POSIZIONE SI SCEGLIE PRIMA DI SCRIVERE**, come nel Viaggio
  /// (ordine ER voce 02). Alla lettura alla cieca del secondo banco di Flash
  /// le risposte dirette erano quattordici e tredici su venti: le altre
  /// aprivano per immagini, *"un movimento sotterraneo"*. Lo schema chiede
  /// la posizione per prima, e la prima frase la dice.
  static const List<String> posizioni = [
    'sì',
    'no',
    'sì a una condizione',
    'un passo da fare',
    'com\'è la situazione',
    'nessuna domanda',
  ];

  /// La temperatura della lettura, per il provider e per il banco. Era 0,9:
  /// al banco il modello scriveva *"Riaascolta"*. Gettate diverse danno
  /// letture diverse anche a 0,7, perche' la richiesta cambia con le pietre.
  static const double temperatura = 0.7;

  /// **TRE CHIAMATE, E LA LETTURA DI CASA SOLO SE IL MODELLO NON RISPONDE.**
  /// Ordine ET voce 07: le cadute sulla lettura di casa si ammettono *"solo
  /// dove il modello non risponde"*. All'ordine ER la lettura di casa
  /// parlava dopo due scarti, anche quando la lettura del modello aveva solo
  /// una prima frase debole. Adesso le chiamate sono tre; dopo la terza, una
  /// lettura scartata per un motivo di forma ([siMostraComunque]) si
  /// mostra, e la lettura di casa resta per cio' che non si puo' mostrare:
  /// un pezzo che manca, una pietra senza nome, gli astri, il confine.
  static const int tentativi = 3;

  /// Vero se una lettura scartata per [motivo] si mostra comunque dopo
  /// l'ultima chiamata.
  static bool siMostraComunque(String motivo) =>
      motivo.startsWith('la prima frase') ||
      motivo.startsWith('hai scelto la posizione') ||
      motivo.startsWith('la pietra ') && motivo.contains(' non dice ') ||
      motivo.startsWith('"inBreve"');

  /// **LA RICHIESTA**: la gettata, ogni pietra con la sua posizione e la sua
  /// riga del corpus nel verso uscito, e la domanda con la sua cornice.
  static String richiesta(EsitoGettata esito, String domanda,
      {DateTime? oggi}) {
    final d = domanda.trim();
    final giorno = oggi ?? DateTime.now();
    final b = StringBuffer()
      ..writeln('Gettata: ${esito.gettata.nome}.')
      ..writeln('Pietre uscite, in ordine; scrivi una lettura per ciascuna, '
          'in questo ordine:');
    for (var i = 0; i < esito.rune.length; i++) {
      final r = esito.rune[i];
      b.writeln('${i + 1}. ${r.rune.name}, '
          '${r.inOmbra ? 'in merkstave, il verso d\'ombra' : 'diritta'}, '
          'nella posizione ${_titolo(r.posizione.titolo)} '
          '(${r.posizione.glossa}). '
          'Significato: ${r.rune.meaning}. Nel suo verso: ${r.riga}');
    }
    if (d.isEmpty) {
      // **LA GIORNATA VERA. Ordine ET voce 07**: alla lettura alla cieca le
      // quattro gettate senza domanda aprivano con *"Oggi si apre un nuovo
      // ciclo"*, *"La tua giornata mostra un flusso che non è ancora
      // limpido"*: il modello non sapeva di che giorno parlava.
      b
        ..writeln('La persona non ha scelto nessuna domanda: la lettura parla '
            'alla sua giornata di oggi, ${_giorni[giorno.weekday - 1]} '
            '${giorno.day} ${_mesi[giorno.month - 1]}.')
        ..writeln('La prima frase dice una cosa concreta della giornata che le '
            'pietre mostrano: una persona da sentire, un impegno da chiudere, '
            'una spesa, la casa o il corpo, con il suo momento (la mattina, il '
            'pomeriggio, la sera). Ogni pietra dice che cosa indica per oggi.');
    } else {
      b.writeln('Domanda posta dalla persona: «$d».');
      final cornice = CorniciDelPresagio.perDomanda(d);
      if (cornice != null) {
        // **LA CORNICE NON ARRIVA PIU' AL MODELLO. Ordine ET voce 07.** Era
        // l'area della domanda nelle parole di Caligo, "da capire e non da
        // ricopiare": alla lettura alla cieca le prime frasi non dirette
        // erano quasi tutte sulle domande della cornice, e ne ripetevano
        // l'immagine (*"una direzione c'è già, ma non è ancora chiara"*),
        // come al banco della sera dell'ordine ER. Adesso la richiesta dice
        // che la domanda e' generale e che cosa vuole la prima frase.
        b.writeln('È una delle domande che l\'app propone ed è generale: '
            'la prima frase dice in concreto che cosa le pietre mostrano in '
            'quest\'area della vita della persona (che cosa si muove, con '
            'chi, entro quando) oppure il passo da fare, detto col suo verbo. '
            'Mai un\'immagine come «una direzione c\'è già», «la forza è in '
            'te», «il sentiero si apre».');
      }
    }
    return b.toString().trimRight();
  }

  static const List<String> _giorni = [
    'lunedì',
    'martedì',
    'mercoledì',
    'giovedì',
    'venerdì',
    'sabato',
    'domenica',
  ];

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

  /// Il titolo della posizione dentro la frase: *"nella posizione al
  /// centro"*, non *"Al centro"*, che il modello ricopiava con la maiuscola.
  /// I nomi propri (Urdhr, Cuore) restano.
  static String _titolo(String t) =>
      RegExp(r'^(?:Al|Ai|Alla|Presso|Nel|Nella|Sul|Sulla) ').hasMatch(t)
          ? '${t[0].toLowerCase()}${t.substring(1)}'
          : t;

  /// La richiesta della seconda chiamata, col motivo per cui la prima e'
  /// stata scartata; senza motivo, la richiesta com'e'.
  static String conLaCorrezione(String richiesta, String? motivo) =>
      motivo == null
          ? richiesta
          : '$richiesta\n\nLA LETTURA DI PRIMA È STATA SCARTATA: $motivo. '
              'Riscrivila rispettando la regola.';

  /// **OGNI PIETRA IN DUE CAMPI**, dal banco del 27 settembre sera: la
  /// "lettura" della runa nella sua posizione, e "sullaDomanda", la frase che
  /// dice che cosa quella pietra indica sulla cosa chiesta. Alla lettura alla
  /// cieca del secondo banco le pietre lette col solo significato generale
  /// erano tredici e sedici su ventiquattro; una guardia che contava le
  /// parole della domanda in ogni pietra scartava cinquantacinque letture su
  /// cento, perche' all'amore si risponde col legame e col cuore. Adesso la
  /// frase sulla domanda e' un campo che il modello deve scrivere. Una
  /// pietra scritta come testo solo resta leggibile (le risposte di prima).
  static List<String>? pietreDi(Map<dynamic, dynamic> j) {
    final pietre = j['pietre'];
    if (pietre is! List) return null;
    final lette = <String>[];
    for (final p in pietre) {
      if (p is String && p.trim().isNotEmpty) {
        lette.add(p.trim());
      } else if (p is Map) {
        final l = _conLaVirgolaDelSoggetto('${p['lettura'] ?? ''}'.trim());
        final s = '${p['sullaDomanda'] ?? ''}'.trim();
        if (l.isEmpty || s.isEmpty) return null;
        lette.add('$l $s');
      }
    }
    return lette;
  }

  /// **LA VIRGOLA FRA IL NOME E IL VERBO SI CHIUDE.** Ordine ET voce 07,
  /// dalla lettura alla cieca del giro 8 dell'ordine ER: *"Uruz in merkstave
  /// nella posizione Ostacolo, rivela"*, una virgola sola fra il soggetto e
  /// il verbo. Diventa *"Uruz, in merkstave nella posizione Ostacolo,
  /// rivela"*: l'inciso si apre dove si chiude.
  static String _conLaVirgolaDelSoggetto(String l) => l.replaceFirstMapped(
      RegExp(
          r'^(\p{Lu}\p{L}+) ((?:diritta|dritta|in \p{L}+|rovesciata|'
          r'nella posizione|nel suo verso)[^,.;:]{0,80}), ',
          unicode: true),
      (m) => '${m.group(1)}, ${m.group(2)}, ');

  /// Le frasi "sullaDomanda" delle pietre, se la lettura le porta.
  static List<String> sulleDomande(Map<dynamic, dynamic> j) => [
        for (final p in (j['pietre'] as List? ?? const []))
          if (p is Map) '${p['sullaDomanda'] ?? ''}'.trim(),
      ];

  /// La lettura nelle tre parti dell'anatomia, o null se un pezzo manca o se
  /// le pietre non sono tante quante quelle uscite.
  static Responso? daJson(Map<dynamic, dynamic>? j, EsitoGettata esito) {
    if (j == null) return null;
    String? testo(String k) {
      final v = j[k];
      if (v is! String) return null;
      final t = v.trim();
      return t.isEmpty ? null : t;
    }

    final lette = pietreDi(j);
    if (lette == null) return null;
    final risposta = _senzaNomi(testo('risposta'), esito);
    final legame = testo('legame');
    final consiglio =
        _senzaNomi(_soloIlGesto(testo('cosaPuoiFare'), esito), esito);
    if (risposta == null ||
        legame == null ||
        consiglio == null ||
        lette.length != esito.rune.length) {
      return null;
    }
    return Responso(
      risposta: _senzaArticoloDelParente(risposta),
      cosaPuoiFare: _senzaArticoloDelParente(consiglio),
      daDoveViene: _senzaArticoloDelParente([...lette, legame].join(' ')),
    );
  }

  /// **"TUA SORELLA", NON "LA TUA SORELLA".** Dalla lettura alla cieca del
  /// banco della sera: *"Chiedi un incontro alla tua sorella"*. Davanti a un
  /// parente al singolare col possessivo l'articolo non va, e la
  /// preposizione resta semplice.
  static String _senzaArticoloDelParente(String t) => t.replaceAllMapped(
          RegExp(
              '(?<![A-Za-zÀ-ÿ])(la|alla|della|dalla|nella|sulla|con la|il|al|'
              'del|dal|nel|sul|col|con il) ((?:tua|tuo|sua|suo) (?:madre|'
              'padre|sorella|fratello|moglie|marito|figlia|figlio|nonna|nonno|'
              'zia|zio|cugina|cugino|suocera|suocero))(?![A-Za-zÀ-ÿ])',
              caseSensitive: false), (m) {
        const semplici = {
          'la': '',
          'il': '',
          'alla': 'a ',
          'al': 'a ',
          'della': 'di ',
          'del': 'di ',
          'dalla': 'da ',
          'dal': 'da ',
          'nella': 'in ',
          'nel': 'in ',
          'sulla': 'su ',
          'sul': 'su ',
          'con la': 'con ',
          'con il': 'con ',
          'col': 'con ',
        };
        final prima = m.group(1)!;
        final dopo = semplici[prima.toLowerCase()]!;
        final maiuscola = prima[0] != prima[0].toLowerCase();
        final r = '$dopo${m.group(2)}';
        return maiuscola ? '${r[0].toUpperCase()}${r.substring(1)}' : r;
      });

  /// **IL NOME DELLA RUNA FUORI DALLA TERZA PARTE DIVENTA "LA RUNA".** Al
  /// banco di Flash, il 27 settembre, trentanove letture su cento cadevano
  /// perche' la risposta o il consiglio nominavano una pietra, anche con la
  /// regola detta e la correzione alla seconda chiamata: una lettura buona
  /// buttata per un nome. La regola dell'anatomia resta (il simbolo compare
  /// nella terza parte), e si fa valere cosi': *"Ansuz ti invita a parlare"*
  /// diventa *"La runa ti invita a parlare"*. La guardia a valle controlla
  /// comunque che nessun nome resti.
  ///
  /// **LE PAROLE CHE STANNO DAVANTI AL NOME**, dalla lettura alla cieca del
  /// secondo banco: la prima riparazione sostituiva il nome e basta, e
  /// scriveva *"la tua la runa"*, *"ogni la runa"*, *"alla runa la runa"*,
  /// otto errori di italiano su sedici. Adesso l'articolo, il possessivo o
  /// la preposizione davanti al nome si accordano con *runa*, e *"la runa
  /// Ansuz"* o *"la pietra Ansuz"* perdono solo il nome.
  static String? _senzaNomi(String? t, EsitoGettata esito) {
    if (t == null) return null;
    var r = t;
    for (final p in esito.rune) {
      r = r.replaceAllMapped(
          RegExp(
              '(?<![A-Za-zÀ-ÿ])(?:($_davanti)(?:(?<=\')|\\s+))?'
              '(?:(runa|rune|pietra|pietre|sigillo|segno|simbolo) )?'
              '${RegExp.escape(p.rune.name)}(?![A-Za-zÀ-ÿ])',
              caseSensitive: false), (m) {
        final davanti = m.group(1);
        final nome = m.group(2);
        if (nome != null && davanti != null) {
          return '$davanti${davanti.endsWith('\'') ? '' : ' '}$nome';
        }
        if (nome != null) return nome;
        if (davanti == null) return 'la runa';
        return '${_alFemminile[davanti.toLowerCase()] ?? davanti} runa';
      });
    }
    // La maiuscola in testa a ogni frase, dove il nome la portava.
    return r.replaceAllMapped(RegExp(r'(^|[.!?]\s+)([a-zà-ÿ])'),
        (m) => '${m.group(1)}${m.group(2)!.toUpperCase()}');
  }

  /// Le parole che possono stare davanti al nome di una runa, e come si
  /// dicono davanti a *runa*.
  static const Map<String, String> _alFemminile = {
    'di': 'della',
    'a': 'alla',
    'ad': 'alla',
    'da': 'dalla',
    'in': 'nella',
    'su': 'sulla',
    'con': 'con la',
    'per': 'per la',
    'tra': 'tra la',
    'fra': 'fra la',
    'il': 'la',
    'lo': 'la',
    'l\'': 'la',
    'un': 'una',
    'uno': 'una',
    'del': 'della',
    'dell\'': 'della',
    'al': 'alla',
    'all\'': 'alla',
    'dal': 'dalla',
    'dall\'': 'dalla',
    'nel': 'nella',
    'nell\'': 'nella',
    'sul': 'sulla',
    'sull\'': 'sulla',
    'col': 'con la',
    'il tuo': 'la tua',
    'il suo': 'la sua',
    'questo': 'questa',
    'quello': 'quella',
    'quest\'': 'questa',
    'quell\'': 'quella',
  };

  static final String _davanti = [
    // Le forme lunghe prima delle corte, perche' l'alternativa prende la
    // prima che combacia.
    'la tua', 'la sua', 'il tuo', 'il suo', 'con la', 'per la', //
    'della', 'dalla', 'nella', 'sulla', 'alla', 'una', 'ogni', 'questa',
    'quella', 'tua', 'sua', 'la',
    ..._alFemminile.keys.where((k) => !k.contains(' ')),
  ].map(RegExp.escape).join('|');

  /// **PERCHE' UNA LETTURA NON SI MOSTRA**, o null se regge. Ogni pietra
  /// nomina la sua runa; la risposta e il consiglio non ne nominano nessuna
  /// (il simbolo compare nella terza parte); niente astri; il confine della
  /// voce S.17.
  static String? scarto(Map<dynamic, dynamic>? j, EsitoGettata esito,
      {String domanda = ''}) {
    final r = daJson(j, esito);
    if (r == null) return 'un pezzo manca, o le pietre non sono tutte';
    final pietre = pietreDi(j!)!;
    for (var i = 0; i < esito.rune.length; i++) {
      if (!nomina(pietre[i], esito.rune[i].rune.name)) {
        return 'la pietra ${i + 1} non nomina ${esito.rune[i].rune.name}';
      }
    }
    // **OGNI PIETRA NOMINA LA SUA POSIZIONE. Ordine ET voce 07.** Alla
    // lettura alla cieca le pietre lette "alcune" erano quasi sempre pietre
    // senza la posizione: *"Fehu, Kenaz, Algiz senza posizione"*.
    for (var i = 0; i < esito.rune.length; i++) {
      if (!_nominaLaPosizione(pietre[i], esito.rune[i].posizione)) {
        return 'la pietra ${i + 1} non dice la sua posizione '
            '(${esito.rune[i].posizione.titolo})';
      }
    }
    // **LA PRIMA FRASE RISPONDE**, ordine ER voce 01, dalla lettura alla
    // cieca del secondo banco: la risposta che apre per immagini non
    // risponde, e con la posizione sì, no o a una condizione la prima frase
    // dice sì o no.
    final prima = r.risposta.split(RegExp(r'(?<=[.!?])\s+')).first;
    if (_perImmagini.hasMatch(prima)) {
      return 'la prima frase della risposta parla per immagini: deve dire '
          'in parole semplici sì, no, a quale condizione o il passo da fare';
    }
    // **LA CORNICE NON SI RICOPIA**: la risposta che ne ripete una frase
    // non e' una risposta, e' l'area della domanda detta a chi l'ha posta.
    final cornice = CorniciDelPresagio.perDomanda(domanda);
    if (cornice != null) {
      for (final f in cornice.apertura.split(RegExp(r'(?<=[.!?])\s+'))) {
        final pezzo = f.replaceAll(RegExp(r'[.!?,]+$'), '').trim();
        if (pezzo.length >= 15 &&
            r.risposta.toLowerCase().contains(pezzo.toLowerCase())) {
          return 'la risposta ricopia la cornice della domanda: la prima '
              'frase deve rispondere con parole tue';
        }
      }
    }
    final posizione = '${j['posizione'] ?? ''}'.trim();
    if (domanda.trim().isNotEmpty &&
        const ['sì', 'no', 'sì a una condizione'].contains(posizione) &&
        !_laPosizioneDetta.hasMatch(prima)) {
      return 'hai scelto la posizione "$posizione" ma la prima frase della '
          'risposta non la dice';
    }
    // **LA FORMULA AL POSTO DEL GESTO O DEL FATTO. Ordine ET voce 07.**
    // Alla lettura alla cieca del giro 8 dell'ordine ER le letture non
    // dirette erano quasi tutte domande aperte a cui la prima frase
    // rispondeva con un atteggiamento: *"La scelta che ti blocca si scioglie
    // riconoscendo il tuo vero valore"*, *"Rimetti in ordine le tue spese con
    // un gesto di equilibrio"*, *"La giornata ti chiede di lasciar andare"*.
    final inBreve = '${j['inBreve'] ?? ''}'.trim();
    if (!const ['sì', 'no', 'sì a una condizione'].contains(posizione)) {
      final formula = _formula.firstMatch('$prima $inBreve');
      if (formula != null) {
        return 'la prima frase della risposta dice un atteggiamento '
            '("${formula.group(0)}") e non il gesto o il fatto concreto';
      }
    }
    // **LA PRIMA FRASE DICE CIO' CHE "inBreve" HA SCELTO.** Lo schema chiede
    // la risposta in poche parole prima di scriverla, come la posizione.
    if (inBreve.isNotEmpty && !_condividonoUnaRadice(inBreve, prima)) {
      return '"inBreve" dice "$inBreve", ma la prima frase della risposta non '
          'lo dice';
    }
    // **OGNI PIETRA DICE CHE COSA INDICA SULLA DOMANDA**, nel suo campo:
    // presente, e non la stessa frase per due pietre.
    final sulle = sulleDomande(j);
    if (sulle.length != esito.rune.length || sulle.any((s) => s.isEmpty)) {
      return 'ogni pietra vuole il suo "sullaDomanda": che cosa quella pietra '
          'indica sulla cosa chiesta';
    }
    if (sulle.toSet().length != sulle.length) {
      return 'due pietre dicono la stessa frase sulla domanda';
    }
    // **E LA DICE SULLA COSA CHIESTA. Ordine ET voce 07.** Alla lettura alla
    // cieca del giro 8 le pietre lette tutte erano quattordici su
    // ventiquattro: *"Berkano suggerisce che un nuovo inizio è pronto"*, alla
    // domanda su Luca, senza Luca. La frase sulla domanda nomina la cosa
    // chiesta (o la giornata, senza domanda).
    for (var i = 0; i < sulle.length; i++) {
      if (!_nominaLaCosa(sulle[i], domanda)) {
        return 'la pietra ${i + 1} non dice che cosa indica '
            '${domanda.trim().isEmpty ? 'sulla giornata di oggi' : 'su ciò che la persona ha chiesto'}: '
            'nomina la cosa chiesta';
      }
    }
    for (final parte in [r.risposta, r.cosaPuoiFare]) {
      for (final x in esito.rune) {
        if (nomina(parte, x.rune.name)) {
          return 'la risposta o il consiglio nominano ${x.rune.name}';
        }
      }
    }
    final tutto = '${r.risposta} ${r.cosaPuoiFare} ${r.daDoveViene}';
    if (_astri.hasMatch(tutto)) return 'nomina un astro o un segno';
    if (ConfineDelResponso.violazioni(tutto).isNotEmpty) {
      return 'supera il confine del responso';
    }
    return null;
  }

  /// Vero se la lettura di una pietra nomina la sua [posizione]: l'ultima
  /// parola del titolo (Urdhr, Cuore, centro, margini) o la sua glossa.
  static bool _nominaLaPosizione(String testo, PosizioneGettata posizione) {
    final t = testo.toLowerCase();
    final ultima = posizione.titolo.toLowerCase().split(' ').last;
    return t.contains(ultima) || t.contains(posizione.glossa.toLowerCase());
  }

  /// Vero se [testo] nomina la runa [nome] come parola intera: *Isa* e *Ing*
  /// sono corti e stanno dentro altre parole.
  static bool nomina(String testo, String nome) =>
      RegExp('(?<![A-Za-zÀ-ÿ])${RegExp.escape(nome)}(?![A-Za-zÀ-ÿ])',
              caseSensitive: false)
          .hasMatch(testo);

  /// **LE IMMAGINI CHE NON RISPONDONO**, in testa alla risposta. Non ci
  /// sono *cammino* e *percorso*: alla domanda *"In amore, dove sto
  /// andando?"* dire dove va il cammino e' la risposta diretta, e al banco
  /// del 27 settembre sera la guardia che li conteneva scartava sedici
  /// letture su cento.
  /// **E LE APERTURE DI FORMULA**, dalla lettura alla cieca del banco della
  /// sera: *"La tua giornata è un invito al cambiamento"*, *"Oggi è un giorno
  /// di svolta"*, *"segui il flusso degli eventi"*: sette delle ventidue
  /// letture che il giudice dava non dirette.
  static final RegExp _perImmagini = RegExp(
      '(?<![A-Za-zÀ-ÿ])(?:velat[oaie]|nebbi[ae]|sotterrane[oaie]|'
      'dentro di te|già in te|in te stess[oa]|l.universo|il destino|'
      'le forze|è un invito|un invito a|è un tempo di|è un giorno di|'
      'il flusso|occhi nuovi)(?![A-Za-zÀ-ÿ])',
      caseSensitive: false);

  /// **LE FORMULE DELLA PRIMA FRASE**, dalla lettura alla cieca del giro 8
  /// dell'ordine ER (ordine ET voce 07): un atteggiamento al posto del
  /// gesto o del fatto.
  static final RegExp _formula = RegExp(
      r'(?<!\p{L})(?:interior[ei]|forza interiore|vero valore|'
      r'consapevolezz\p{L}*|equilibrio|lasciar andare|lascia andare|'
      r'non forzare|accogli\p{L}*|trasformazion\p{L}*|soglia|un ponte|'
      r'passaggio|la corrente|rinnovamento|nuovo inizio|crescita|'
      r'chiara visione|il tuo ritmo|tempo di attesa|con fiducia|'
      r'ciò che non si vede)(?!\p{L})',
      caseSensitive: false,
      unicode: true);

  static const Set<String> _vuote = {
    'della',
    'delle',
    'dello',
    'nella',
    'nelle',
    'sulla',
    'sulle',
    'dalla',
    'alla',
    'questa',
    'questo',
    'quella',
    'quello',
    'cosa',
    'devo',
    'sono',
    'come',
    'dove',
    'quale',
    'mentre',
    'prima',
    'dopo',
    'perché',
    'anche',
    'ancora',
    'sempre',
    'molto',
    'tutto',
    'tutti',
    'tuoi',
    'tuo',
    'tua',
    'mio',
    'mia',
    'miei',
    'rune',
    'runa',
    'pietre',
    'pietra',
    'dicono',
  };

  static Set<String> _radici(String t) => {
        for (final m
            in RegExp(r'\p{L}{4,}', unicode: true).allMatches(t.toLowerCase()))
          if (!_vuote.contains(m.group(0)))
            m.group(0)!.substring(0, m.group(0)!.length < 5 ? 4 : 5),
      };

  static bool _condividonoUnaRadice(String a, String b) {
    final dove = b.toLowerCase();
    return _radici(a).any(dove.contains);
  }

  /// Le famiglie di parole con cui si risponde a una cosa senza ripeterne
  /// il nome: all'amore col legame e col cuore, al denaro con le spese.
  static const List<Set<String>> _famiglie = [
    {'amor', 'cuore', 'legam', 'relaz', 'coppi', 'partn', 'senti', 'innam'},
    {'lavor', 'ruolo', 'capo', 'colle', 'carri', 'uffic', 'profe', 'propo'},
    {
      'spes',
      'spend',
      'soldi',
      'denar',
      'conti',
      'bilan',
      'rispa',
      'econo',
      'debit'
    },
    {'sorel', 'fratel', 'madre', 'padre', 'famig'},
    {'amic'},
    {'scelt', 'scegl', 'decis', 'strad', 'bivio', 'blocc'},
    {'citt', 'trasf', 'parti', 'rest', 'cambi'},
    {'momen', 'perio', 'fase', 'tempo', 'adess', 'oggi'},
  ];

  static final RegExp _laGiornata = RegExp(
      r'(?<!\p{L})(?:oggi|giornata|stasera|sera|mattina|pomeriggio|domani|'
      r'ore|giorno)(?!\p{L})',
      caseSensitive: false,
      unicode: true);

  /// Vero se la frase di una pietra [sulla] nomina la cosa chiesta in
  /// [domanda], o la giornata quando la domanda non c'e'.
  static bool _nominaLaCosa(String sulla, String domanda) {
    if (domanda.trim().isEmpty) return _laGiornata.hasMatch(sulla);
    final radici = _radici(domanda);
    final tutte = {
      ...radici,
      for (final f in _famiglie)
        if (f.any((x) => radici.any((r) => r.startsWith(x) || x.startsWith(r))))
          ...f,
    };
    final s = sulla.toLowerCase();
    return tutte.any(s.contains);
  }

  /// **IL CONSIGLIO E' SOLO IL GESTO**, dal banco della sera: *"decidi il
  /// passo successivo con Isa"*, *"per onorare il presagio di Gebo"*, *"un
  /// azione diretta e' il tuo sigillo"*. Scartarli mandava in riserva sei
  /// letture su ventiquattro, perche' il modello tornava a nominare le
  /// pietre anche dopo la correzione. Si tolgono le parti del consiglio,
  /// fra virgole o punti, che parlano delle pietre, del presagio o di un
  /// sigillo: resta il gesto. Se non resta niente, il consiglio manca e la
  /// lettura si scarta.
  static String? _soloIlGesto(String? t, EsitoGettata esito) {
    if (t == null) return null;
    final nomi = [for (final p in esito.rune) RegExp.escape(p.rune.name)];
    final fuori = RegExp(
        '(?<![A-Za-zÀ-ÿ])(?:runa|rune|pietra|pietre|presagio|sigillo|'
        'gettata|${nomi.join('|')})(?![A-Za-zÀ-ÿ])',
        caseSensitive: false);
    if (!fuori.hasMatch(t)) return t;
    final frasi = <String>[];
    for (final frase in t.split(RegExp(r'(?<=[.!?])\s+'))) {
      final parti = [
        for (final p in frase.split(RegExp(r',\s+')))
          if (!fuori.hasMatch(p)) p.trim(),
      ];
      if (parti.isEmpty) continue;
      var f = parti.join(', ');
      if (!RegExp(r'[.!?]$').hasMatch(f)) f = '$f.';
      frasi.add('${f[0].toUpperCase()}${f.substring(1)}');
    }
    // La congiunzione rimasta sola dove si e' tagliato: *"...alla tua citta'
    // e, prima di mezzanotte"* torna *"...alla tua citta' prima di
    // mezzanotte"*.
    final r = frasi
        .join(' ')
        .replaceAll(RegExp(r'\s+(?:e|ed|o|ma|poi),\s+'), ' ')
        .replaceAllMapped(
            RegExp(r'\s+(?:e|ed|o|ma|poi)([.!?])$'), (m) => m.group(1)!)
        .trim();
    return r.length < 20 ? null : r;
  }

  /// **LA POSIZIONE DETTA**: un sì, un no, o la condizione che la regge. Al
  /// banco la guardia cercava solo *sì* e *no*, e scartava *"Le rune indicano
  /// che l'amore cresce se..."* scelta come *"sì a una condizione"*.
  ///
  /// **E LA CONDIZIONE DETTA COL "MA"**, dal Realme alla build 2285: a *"Devo
  /// accettare il nuovo lavoro a Torino?"* il modello rispondeva *"Accetta
  /// l'offerta di lavoro, ma poni una condizione chiara sul tuo tempo"*, cioe'
  /// la risposta diretta, e la guardia la scartava due volte su due: al
  /// telefono parlava la lettura di casa, che non risponde affatto. Al banco,
  /// sulla stessa gettata, tre scarti su tre.
  static final RegExp _laPosizioneDetta = RegExp(
      '(?<![A-Za-zÀ-ÿ])(?:sì|no|non|se|a patto|purché|finché|solo quando|'
      'ma|però|condizione|prima)(?![A-Za-zÀ-ÿ])',
      caseSensitive: false);

  /// Le rune senza astrologia, ordine EA voce 05.
  static final RegExp _astri = RegExp(
      r'(?<![A-Za-zÀ-ÿ])(zodiac\w*|ascendente|oroscop\w*|pianet\w*|mercurio|'
      r'venere|giove|saturno|plutone|nettuno|carta natale)(?![A-Za-zÀ-ÿ])',
      caseSensitive: false);
}
