/// **CIO' CHE NESSUNO PUO' SAPERE NON SI DICE COME UN FATTO.** Ordine ET
/// voce 01, 28 settembre 2026.
///
/// L'ordine: la posizione si dice *"come lettura del Maestro, mai come un
/// fatto certo su ciò che nessuno può sapere"*, e le certezze devono essere
/// zero. Al secondo giro del banco delle trenta domande, con la posizione
/// finalmente presa, i giudici alla cieca hanno contato trentasette risposte
/// su trecentosessanta con una certezza (erano diciotto sul codice di
/// partenza): la posizione detta come lettura e subito dopo ridetta come
/// fatto, *"I tuoi centri dicono di sì, avrai la promozione quest'anno"*;
/// il futuro dato per certo, *"Il tuo lavoro e la tua costanza saranno
/// premiati"*; i sentimenti di un'altra persona detti come fatti, *"Il suo
/// silenzio non è indifferenza, ma attesa"*.
///
/// Qui si riconoscono. Il controller toglie la frase che ridice la posizione
/// come fatto (`senzaIlFattoDopoLaPosizione`) e chiede di nuovo, una volta,
/// la risposta che ne porta ancora (`inQuesteFrasi`).
abstract final class LeCertezzeDelMaestro {
  static const String _l = r'\p{L}';
  static const String _prima = '(?<!$_l)';
  static const String _dopo = '(?!$_l)';

  static RegExp _re(String s) => RegExp(s, caseSensitive: false, unicode: true);

  /// Il futuro indicativo: *avrai*, *riuscirai*, *arriverà*, *troveranno*.
  static final RegExp _futuro =
      _re('$_prima($_l{2,}(?:rò|rai|rà|ranno|remo)|sarete|avrete|vedrete|'
          'costruirete)$_dopo');

  /// Le parole che finiscono come un futuro e non lo sono, e *sarà* e
  /// *avrà*, che contano solo quando dicono un esito (`_esito`).
  static const Set<String> _nonFuturi = {
    'estremo',
    'supremo',
    'però',
    'perciò',
    'sarà',
    'avrà',
    // **"POTRAI" E' UNA POSSIBILITA', NON UNA CERTEZZA.** Ordine ES voce 19:
    // al giro 6 del banco la rete scartava "potrai comunicare", e il
    // giudizio dato a mano la chiama uno scarto inutile.
    'potrò',
    'potrai',
    'potrà',
    'potremo',
    'potrete',
    'potranno',
  };

  /// **IL FUTURO DETTO DENTRO LA LETTURA NON E' UN FATTO.** Ordine ES voce
  /// 19: al giro 6 nove scarti su ventisei inutili avevano il futuro sotto
  /// *"le rune dicono che"*, *"leggo che"*, *"indica che"*: e' la forma che
  /// la regola della posizione chiede. Il verbo della lettura seguito da
  /// "che" davanti al futuro, nella stessa proposizione, lo fa lettura.
  static final RegExp _letturaChe =
      _re('$_prima(?:dicono|dice|leggo|leggono|mostrano|mostra|indicano|indica|'
          'rispondono|risponde|vedo)$_dopo[^,;:]*?${_prima}che$_dopo');

  /// **IL FUTURO CHE SEGUE UN CONSIGLIO E' LA SUA CONSEGUENZA**, non una
  /// previsione: *"Concentra il tuo intento e le risorse seguiranno il tuo
  /// passo"*. Ordine ES voce 19, dal giro 6. Si riconosce l'imperativo in
  /// testa alla proposizione e la "e" che lega il futuro.
  static final RegExp _consiglioEFuturo = _re(
      r'^\s*(?:concentra|ascolta|apri|cerca|lascia|segui|scegli|scrivi|parla|'
      r'esci|fai|prendi|dai|guarda|affida|coltiva|nutri|proteggi|accogli|'
      r'respira|chiudi|appoggia|accendi|tieni|porta|ricorda|osserva|sii|abbi|'
      r'resta|torna|chiedi|dedica|offri|trova|costruisci|lavora|credi)'
      '$_dopo.*${_prima}e$_dopo');

  static final RegExp _esito =
      _re('$_prima(?:sarà|saranno|avrà|avranno)$_dopo');

  /// Una proposizione che comincia da una condizione o da un tempo: il
  /// futuro li' dentro non e' una previsione (*"se ti presenterai"*,
  /// *"quando sarai pronta"*).
  static final RegExp _condizione =
      _re(r'^\s*(?:(?:e|ma|o)\s+)?(?:se|quando|finché|purché|appena|non appena|'
          r'che|perché|dove|come|mentre|prima che|dopo che|solo se|a patto che|'
          'qualora|ogni volta che)$_dopo');

  /// Le parole che, davanti al futuro nella stessa proposizione, lo fanno
  /// condizione o relativa: *"il giorno in cui sarai"*, *"una lettera che
  /// non invierai"*.
  static final RegExp _davantiAlFuturo =
      _re('$_prima(?:se|quando|finché|purché|appena|prima|dopo|in cui|'
          'nel quale|nella quale|che)$_dopo');

  /// Il verbo della lettura: *"le carte dicono che"*, *"nelle rune leggo"*.
  static final RegExp _lettura =
      _re('$_prima(?:dicono|dice|leggo|leggono|mostrano|mostra|indicano|indica|'
          'rispondono|risponde|vedo|sento|parlano|parla)$_dopo');

  /// I sentimenti o i pensieri di un'altra persona detti come fatti.
  static final RegExp _sentimentiDegliAltri = _re(
      '$_prima(?:ti ama|gli piaci|le piaci|ti apprezza|ti vuole|ti desidera|'
      'ti pensa|ti tradisce|riconosce il tuo valore|'
      'il tuo capo (?:ti )?apprezza)$_dopo');

  /// Una proposizione che ha per soggetto l'altra persona o una cosa sua:
  /// *"il suo silenzio non è indifferenza"*, *"tua madre proietta"*. Non
  /// quando dice cio' che puo' essere (*"il suo silenzio può essere
  /// timidezza"*) ne' la regola della volonta' altrui (*"la sua scelta è
  /// sua"*).
  static final RegExp _soggettoAltro =
      _re(r'^\s*(?:(?:e|ma|però)\s+)?(?:il suo|la sua|i suoi|le sue|lui|lei|'
          r'tua madre|tuo padre|il tuo capo|il tuo compagno)\s');

  /// **L'ALTRA PERSONA ANCHE DENTRO LA PROPOSIZIONE**, dal quarto giro del
  /// banco: *"c'è un velo di incertezza che lo frena"*, *"Non è rifiuto, ma
  /// un impedimento che oscura il suo sentire"*, *"Il suo amore è un fuoco
  /// che il passato non ha spento"*. Le cose sue che nessuno vede, e i verbi
  /// che dicono che cosa lo muove.
  static final RegExp _dellAltro =
      _re('$_prima(?:il suo|la sua|i suoi|le sue) (?:cuore|amore|sentire|'
          'silenzio|sguardo|apprezzamento|stima|volontà|esitazione|reticenza|'
          'cautela|lealtà|desiderio|sentimento|sentimenti|occhi|anima|natura|'
          'fiamma|interesse)$_dopo|'
          '$_prima(?:lo|la|gli|le) (?:frena|tiene|spinge|blocca|trattiene|'
          'impedisce|rende|trattengono|frenano|spingono|bloccano)$_dopo');

  static final RegExp _cioChePuoEssere =
      _re('$_prima(?:potrebbe|può|potrebbero|possono|forse|tende|è su[ao]|'
          'dipende)$_dopo');

  static List<String> _frasi(String testo) => testo
      .replaceAll('\n', ' ')
      .split(RegExp(r'(?<=[.!?])\s+'))
      .where((f) => f.trim().isNotEmpty)
      .toList();

  static List<String> _proposizioni(String frase) => frase
      .split(RegExp(r'[,;:]\s*'))
      .where((p) => p.trim().isNotEmpty)
      .toList();

  /// Vero se la proposizione [p] da' per certo cio' che nessuno sa.
  static bool _certa(String p, {required bool letta}) {
    if (_condizione.hasMatch(p)) return false;
    for (final m in _futuro.allMatches(p)) {
      if (_nonFuturi.contains(m.group(1)!.toLowerCase())) continue;
      final davanti = p.substring(0, m.start);
      if (_davantiAlFuturo.hasMatch(davanti)) continue;
      if (_letturaChe.hasMatch(davanti)) continue;
      if (_consiglioEFuturo.hasMatch(davanti)) continue;
      return true;
    }
    for (final m in _esito.allMatches(p)) {
      final davanti = p.substring(0, m.start);
      if (_davantiAlFuturo.hasMatch(davanti)) continue;
      if (_letturaChe.hasMatch(davanti)) continue;
      return true;
    }
    if (letta || _cioChePuoEssere.hasMatch(p)) return false;
    return _sentimentiDegliAltri.hasMatch(p) ||
        _soggettoAltro.hasMatch(p) ||
        _dellAltro.hasMatch(p);
  }

  /// Le proposizioni di [testo] che danno per certo cio' che nessuno sa;
  /// vuoto se non ce ne sono.
  static List<String> inQuesteFrasi(String testo) {
    final fuori = <String>[];
    for (final frase in _frasi(testo)) {
      // La lettura vale nella proposizione dove sta: *"I tuoi centri
      // rispondono di sì, il tuo capo apprezza il tuo lavoro"* dice il fatto
      // dopo la virgola.
      // **E LA CONDIZIONE VALE ANCHE PER LA PROPOSIZIONE CHE LA SEGUE**,
      // ordine ES voce 19: *"Solo quando sentirai di valere, attirerai
      // persone che..."* e' un futuro condizionato, e al giro 6 la rete lo
      // prendeva per certo.
      var dopoUnaCondizione = false;
      for (final p in _proposizioni(frase)) {
        if (!dopoUnaCondizione && _certa(p, letta: _lettura.hasMatch(p))) {
          fuori.add(p.trim());
        }
        dopoUnaCondizione = _condizione.hasMatch(p);
      }
    }
    return fuori;
  }

  /// **LA POSIZIONE NON SI RIDICE COME FATTO.** *"I tuoi centri dicono di
  /// sì, avrai la promozione quest'anno, se..."* diventa *"I tuoi centri
  /// dicono di sì, se..."*: la proposizione subito dopo il sì o il no, se
  /// da' per certo, si toglie, e con lei le proposizioni che la seguivano
  /// senza essere una condizione. **La prima stesura toglieva solo la
  /// prima**, e al quarto giro ha lasciato *"I tuoi centri rispondono di
  /// sì, qualità che risuonano con la tua essenza"*, una frase spezzata.
  ///
  /// **E UNA FRASE INTERA DOPO IL SI' PRENDE I DUE PUNTI**: *"Le carte
  /// rispondono di no, questa settimana le stelle non favoriscono il gioco"*
  /// era, per il giudice alla cieca, una virgola che unisce due frasi.
  static String senzaIlFattoDopoLaPosizione(String testo) =>
      testo.replaceAllMapped(
          _re(r'((?:dicono|dice|leggo|rispondono|risponde|indicano|mostrano)'
              r'(?:\s+di)?\s+(?:sì|no)),\s+([^.;:!?\n]*)([.;:!?]|(?=\n)|$)'),
          (m) {
        final testa = m.group(1)!;
        final pezzi = m.group(2)!.split(RegExp(r',\s*'));
        final segno = m.group(3)!;
        if (_certa(pezzi.first, letta: false)) {
          final resto =
              pezzi.skip(1).skipWhile((p) => !_laCondizione.hasMatch(p));
          return resto.isEmpty
              ? '$testa${segno.isEmpty ? '.' : segno}'
              : '$testa, ${resto.join(', ')}$segno';
        }
        if (!_laCondizione.hasMatch(pezzi.first) &&
            _unaFraseIntera.hasMatch(pezzi.first)) {
          return '$testa: ${pezzi.join(', ')}$segno';
        }
        return m.group(0)!;
      });

  /// Le parole con cui comincia una condizione o un limite della posizione.
  static final RegExp _laCondizione =
      _re(r'^\s*(?:se|purché|a patto|a condizione|quando|finché|ma|però|perché|'
          r'solo|non ancora|per ora|per adesso|almeno|anche|con|senza|prima|'
          'dopo)$_dopo');

  /// Una proposizione che sta in piedi da sola: un soggetto con l'articolo e
  /// un verbo al presente (*"questa settimana le stelle non favoriscono"*,
  /// *"il sentiero dell'amore si apre"*).
  static final RegExp _unaFraseIntera =
      _re(r"^\s*(?:questa|questo|oggi|il|la|lo|l'|i|le|gli)\s+[^,]{2,60}?"
          r'\s(?:è|sono|non|si|ha|hanno|\p{L}+(?:a|e|ono))\s');

  /// **LE FRASI CERTE CHE RESTANO SI TOLGONO.** Ordine ET voce 01, dal quarto
  /// giro del banco: con la richiesta ripetuta le certezze scendevano da 37
  /// a 33 su 360, perche' il modello riscriveva la stessa cosa con altre
  /// parole. Una frase che da' per certo cio' che nessuno sa si toglie, se
  /// non e' la prima (che porta la posizione) e non e' la riga col segno
  /// (il consiglio). Se togliendo restasse la sola prima frase, il testo
  /// resta com'e'.
  static String senzaLeFrasiCerte(String testo) {
    final righe = testo.split('\n');
    final fuori = <String>[];
    var tolte = 0;
    var prima = true;
    for (final riga in righe) {
      if (riga.trimLeft().startsWith('✦') || riga.trim().isEmpty) {
        fuori.add(riga);
        continue;
      }
      final frasi = riga.split(RegExp(r'(?<=[.!?])\s+'));
      final tenute = <String>[];
      for (final f in frasi) {
        if (!prima && inQuesteFrasi(f).isNotEmpty) {
          tolte++;
          continue;
        }
        prima = false;
        tenute.add(f);
      }
      if (tenute.isNotEmpty) fuori.add(tenute.join(' '));
    }
    if (tolte == 0) return testo;
    final corpo = fuori.where((r) => !r.trimLeft().startsWith('✦')).join(' ');
    if (corpo
            .split(RegExp(r'(?<=[.!?])\s+'))
            .where((f) => f.trim().isNotEmpty)
            .length <
        2) {
      return testo;
    }
    return fuori.join('\n');
  }

  /// **La correzione nominata** per la seconda richiesta.
  static String correzione(List<String> certe) =>
      'QUESTE FRASI DANNO PER CERTO CIÒ CHE NESSUNO PUÒ SAPERE: '
      '${certe.map((c) => '"$c"').join(', ')}. Riscrivi la risposta: la '
      'posizione resta, detta come lettura della tua arte ("le carte '
      'dicono", "leggo"); il futuro non è mai un fatto (non "avrai", '
      '"riuscirai", "arriverà", "andrà bene", "sarà"), scrivi "tende a", '
      '"può", "la tua arte lo legge"; di un\'altra persona dici solo ciò che '
      'la tua arte legge, mai che cosa prova o pensa come un fatto.';
}
