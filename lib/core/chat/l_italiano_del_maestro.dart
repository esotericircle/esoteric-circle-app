/// **GLI ERRORI CHE SI RIPETONO SI RIPARANO A MACCHINA.** Ordine ET voce
/// 01, 28 settembre 2026.
///
/// L'ordine chiede zero errori di italiano. Al secondo giro del banco delle
/// trenta domande i giudici alla cieca ne hanno citati sessantanove su
/// trecentosessanta risposte, e gran parte erano della stessa famiglia,
/// alcune figlie di regole nostre:
///
/// - l'inciso dopo la "e" senza la virgola che lo apre: *"cerca intensità e
///   quando questa manca, il desiderio può ritirarsi"*; la regola di casa
///   vieta la virgola **prima** della "e", e il modello toglieva anche
///   quella dopo;
/// - *"non prima di quando avrai chiarito"*, nato dall'esempio del blocco
///   del turno (`LaPosizioneDellaLettura`), che diceva "non prima di ...";
/// - *"Le rune dicono non ancora"*, senza i due punti;
/// - *"la tua madre"*, l'articolo davanti al parente;
/// - la virgola che attacca il cielo al momento del gesto: *"sul suo tavolo
///   lunedì, la Luna crescente in Capricorno ti donerà"*, nata dalla regola
///   di Medora che vuole il momento dentro la frase.
///
/// Ognuna si ripara senza cambiare il senso; il resto lo chiede
/// l'istruzione.
abstract final class LItalianoDelMaestro {
  static RegExp _re(String s) => RegExp(s, caseSensitive: false, unicode: true);

  static const String _l = r'\p{L}';

  static final RegExp _incisoDopoLaE =
      _re('(?<!$_l)e (quando|se|anche se|mentre|appena|dove|finché|perché) '
          r'([^,.;:!?\n]{2,80}),');

  static final RegExp _nonPrimaDiQuando = _re('non prima di quando');

  /// **L'IMPERATIVO DOPO UN INCISO DIVENTA UNA FRASE NUOVA**, dal quarto giro
  /// del banco: *"Porta le mani sulla pancia, una sopra l'altra e senti il
  /// calore"*. La regola di casa vieta la virgola prima della "e", e il
  /// giudice alla cieca voleva l'inciso chiuso: la frase nuova accontenta
  /// tutti e due.
  static final RegExp _imperativoDopoLInciso = _re(
      r',\s([^,.;:!?\n]{2,45}?)\se\s(senti|visualizza|osserva|chiediti|respira|'
      r'scrivi|abbraccia|riempi|aspetta|portagli\p{L}*|espira|guarda|ascolta|'
      r'lascia|accendi|porta|poni|metti|chiedi|prendi|annota|leggi|rileggi|'
      r'cammina|immagina|ripeti|tieni|appoggia|bevi|manda\p{L}*|chiama\p{L}*|'
      r'parla\p{L}*|sussurra|pronuncia|nota|segna)(?!\p{L})');

  /// **L'APPOSIZIONE DEL CENTRO FRA PARENTESI**: *"la tua radice, il primo
  /// centro e con la tua energia"*.
  static final RegExp _apposizioneDelCentro =
      _re(r',\s((?:il|la) (?:primo|secondo|terzo|quarto|quinto|sesto|settimo) '
          r'(?:centro|chakra)|quell[oa] \p{L}+)\se\s');

  static final RegExp _eDavantiAllaE = _re(r'(?<!\p{L})e (e\p{L}+)');

  static final RegExp _laPosizioneSenzaIDuePunti =
      _re(r'((?:dicono|dice|rispondono|risponde|indicano|mostrano))\s+'
          '(non ancora|non prima|non adesso|non ora|presto)(?!$_l)');

  static final RegExp _siSenzaDi = _re(
      r'((?:dicono|dice|rispondono|risponde|indicano))\s+(sì|no)(?=[,.;:!?\s])');

  static final RegExp _ilCieloAttaccato =
      _re('((?:lunedì|martedì|mercoledì|giovedì|venerdì|sabato|domenica|domani|'
          'mattina|sera|stasera|oggi|giorni|settimana|notte)), '
          '((?:la Luna|il Sole|Venere|Marte|Mercurio|Giove|Saturno)(?!$_l))');

  static final RegExp _parente = _re(
      '(?<!$_l)(la|alla|della|dalla|nella|sulla|con la|il|al|del|dal|nel|'
      'sul|col|con il) ((?:tua|tuo|sua|suo) (?:madre|padre|sorella|fratello|'
      'moglie|marito|figlia|figlio|nonna|nonno|zia|zio|cugina|cugino|'
      'suocera|suocero))(?!$_l)');

  static const Map<String, String> _semplici = {
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

  /// [testo] con gli errori ricorrenti riparati.
  static String ripara(String testo) {
    var t = testo.replaceAllMapped(_incisoDopoLaE,
        (m) => '${_come(m.group(0)!, 'e')}, ${m.group(1)} ${m.group(2)},');
    t = t.replaceAllMapped(_imperativoDopoLInciso,
        (m) => ', ${m.group(1)}. ${_maiuscola(m.group(2)!)}');
    t = t.replaceAllMapped(_apposizioneDelCentro, (m) => ' (${m.group(1)}) e ');
    t = t.replaceAllMapped(_eDavantiAllaE, (m) => 'ed ${m.group(1)}');
    t = t.replaceAllMapped(_nonPrimaDiQuando,
        (m) => _come(m.group(0)!, 'non prima del momento in cui'));
    t = t.replaceAllMapped(
        _laPosizioneSenzaIDuePunti, (m) => '${m.group(1)}: ${m.group(2)}');
    t = t.replaceAllMapped(_siSenzaDi, (m) => '${m.group(1)} di ${m.group(2)}');
    t = t.replaceAllMapped(
        _ilCieloAttaccato, (m) => '${m.group(1)}: ${m.group(2)}');
    t = t.replaceAllMapped(_parente, (m) {
      final prima = m.group(1)!;
      final r = '${_semplici[prima.toLowerCase()]!}${m.group(2)}';
      return prima[0] != prima[0].toLowerCase()
          ? '${r[0].toUpperCase()}${r.substring(1)}'
          : r;
    });
    return t;
  }

  static String _maiuscola(String s) =>
      '${s[0].toUpperCase()}${s.substring(1)}';

  /// [nuovo] con la maiuscola iniziale di [vecchio].
  static String _come(String vecchio, String nuovo) =>
      vecchio[0] != vecchio[0].toLowerCase()
          ? '${nuovo[0].toUpperCase()}${nuovo.substring(1)}'
          : nuovo;
}
