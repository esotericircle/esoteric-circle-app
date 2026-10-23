/// **NOMINARE UN'ARTE NON E' CHIEDERLA.** Ordine EB voce 03, 21 settembre
/// 2026.
///
/// **La decisione del fondatore, verbatim**, alla domanda su quando possa
/// comparire un pulsante verso una funzione: *"Solo se l'utente lo chiede"*.
///
/// **Il difetto che questo file toglie.** L'instradamento della chat cercava
/// la parola dell'arte dentro il testo e bastava quella. Misurato sulle frasi
/// vere delle due catture del 21 settembre 2026: *"non voglio una stesa"*
/// apriva la Stesa esattamente come *"fammi una stesa"*. **La negazione pesava
/// zero**, e la domanda preimpostata, che conteneva essa stessa la parola
/// *stesa*, si autodistruggeva: il testo che portava le carte da interpretare
/// veniva letto come richiesta di estrarne altre.
///
/// **PERCHE' IL CANCELLO PUO' ESSERE STRETTO, ed e' il cuore della cura.**
/// Prima, un cancello che non scattava voleva dire **nessuna risposta**:
/// l'instradamento tornava prima di chiamare il modello, e chi non veniva
/// riconosciuto restava senza niente. Per questo era largo. Adesso un cancello
/// che non scatta vuol dire **una risposta vera**, perche' il Maestro risponde
/// sempre (voce 02). **Il rischio si e' spostato dalla parte in cui l'errore
/// non si vede**, e un cancello stretto e' diventato la scelta giusta: chi
/// chiede l'arte e non viene riconosciuto riceve una risposta, che e' sempre
/// accettabile; chi non la chiede e viene riconosciuto riceve un pulsante al
/// posto della risposta, che e' il difetto.
///
/// **Non e' un modello, e' una lettura di forme.** Deterministica, misurabile,
/// e senza una chiamata in piu' a Gemini: il giorno che si volesse chiedere
/// al modello, questo file resterebbe come la prima rete.
library;

/// In che modo una frase nomina un'arte.
enum ModoDiNominareUnArte {
  /// La persona chiede di farla adesso. E' il solo modo che apre il pulsante.
  richiesta,

  /// La persona la nomina parlando d'altro, o di un responso che ha gia'.
  menzione,

  /// La persona dice di non volerla. Oltre a non aprire niente, **chiude
  /// quell'arte per il resto della conversazione** (voce 05).
  rifiuto,
}

abstract final class LaRichiestaDiUnArte {
  /// **I SEGNI DELLA RICHIESTA**: le forme con cui in italiano si chiede di
  /// fare una cosa adesso. Non ci sono sinonimi generici come *"parlami di"*,
  /// che e' una richiesta di parole e non di un'esperienza.
  static const List<String> segniDiRichiesta = [
    'fammi', 'fammene', 'facciamo', 'facciamone', 'fai', 'falla', 'fallo',
    'puoi fare', 'puoi farmi', 'mi puoi fare', 'mi fai', 'possiamo fare',
    'posso avere', 'mi serve', 'ho bisogno',
    'voglio', 'vorrei', 'desidero', 'mi piacerebbe',
    'apri', 'apriamo', 'aprimi', 'aprila', 'aprilo',
    'stendi', 'stendiamo', 'stendimi', 'stendile', 'stendiamole',
    'tira', 'tirami', 'tiriamo', 'tirale',
    'lancia', 'lanciamo', 'lanciami', 'lanciale',
    'getta', 'gettiamo', 'gettami', 'gettale',
    'pesca', 'peschiamo', 'pescami',
    'dammi', 'dammela', 'mostrami', 'iniziamo', 'cominciamo', 'partiamo',
    'procedi',
    // **Chi chiede di essere accompagnato dentro un'esperienza la chiede.**
    // Diverso da *parlami* e *dimmi*, che chiedono parole: a quelli il
    // Maestro risponde, ed e' la voce 02.
    'guidami', 'accompagnami', 'portami',
    'consulta', 'consultiamo', 'consultiamolo', 'consultiamola',
    'interroga', 'interroghiamo',
    // Le forme interrogative con cui si chiede una cosa che l'app da'.
    'qual è', 'quale è', 'quali sono',
  ];

  /// **LE NEGAZIONI**, che in italiano stanno prima di cio' che negano.
  static const List<String> negazioni = [
    'non',
    'no',
    'niente',
    'nessun',
    'nessuna',
    'nessuno',
    'senza',
    'mai',
    'invece di',
    'al posto di',
    'piuttosto che',
    'basta con',
    'smettila',
    'evita',
    'lascia stare',
  ];

  /// **I SEGNI DI UN RESPONSO GIA' AVUTO.** Chi parla di cio' che ha gia'
  /// ottenuto non sta chiedendo di rifarlo, e questa e' precisamente la
  /// situazione che il fondatore ha incontrato.
  static const List<String> responsiGiaAvuti = [
    'ho già',
    'già fatto',
    'già fatta',
    'già fatte',
    'già tirato',
    'sono uscite',
    'sono usciti',
    'è uscita',
    'è uscito',
    'erano uscite',
    'erano usciti',
    'mi è uscita',
    'mi è uscito',
    'nella mia',
    'nel mio',
    'che ho fatto',
    'appena fatto',
    'appena fatta',
    'ho estratto',
    'ho tirato',
    'ho gettato',
    'ho tracciato',
    'ho consultato',
    'di ieri',
    'dell\'altra volta',
    'la mia estrazione',
    'il mio responso',
    'la mia lettura',
    'quelle che ho',
    'quello che ho',
  ];

  /// **La normalizzazione, e sta qui perche' la usano in due.** Minuscolo,
  /// accenti ridotti alle vocali semplici, apostrofi resi spazio (cosi'
  /// *"nell'estrazione"* si legge come due parole e *"mi e' uscita"* combacia
  /// con la sua forma piana), spazi ridotti a uno.
  static String normalizza(String s) {
    const accenti = {
      'à': 'a',
      'è': 'e',
      'é': 'e',
      'ì': 'i',
      'í': 'i',
      'ò': 'o',
      'ó': 'o',
      'ù': 'u',
      'ú': 'u',
    };
    final buffer = StringBuffer();
    for (final ch in s.toLowerCase().split('')) {
      if (ch == '\'' || ch == '’' || ch == '`') {
        buffer.write(' ');
      } else {
        buffer.write(accenti[ch] ?? ch);
      }
    }
    return buffer.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// La parola o frase compare intera, non dentro un'altra parola: *"tira"*
  /// non scatta dentro *"tirare"*, e *"rune"* non scatta dentro *"prune"*.
  static bool contieneLaParola(String dove, String cosa) {
    var da = 0;
    while (true) {
      final i = dove.indexOf(cosa, da);
      if (i < 0) return false;
      final prima = i == 0 ? ' ' : dove[i - 1];
      final dopoIndice = i + cosa.length;
      final dopo = dopoIndice >= dove.length ? ' ' : dove[dopoIndice];
      if (!_eLettera(prima) && !_eLettera(dopo)) return true;
      da = i + 1;
    }
  }

  static bool _eLettera(String c) {
    if (c.isEmpty) return false;
    final code = c.codeUnitAt(0);
    return (code >= 48 && code <= 57) ||
        (code >= 97 && code <= 122) ||
        (code >= 65 && code <= 90);
  }

  /// **Come [testo] nomina l'arte che si riconosce da [parolaChiave].**
  ///
  /// **Si guarda la PROPOSIZIONE, non tutta la frase.** In *"fammi una stesa,
  /// non importa quale"* la negazione sta in un pezzo che non parla dell'arte,
  /// e prenderla per un rifiuto negherebbe una richiesta chiara. La
  /// proposizione e' il pezzo fra due segni di interpunzione, virgola
  /// compresa, che contiene la parola dell'arte.
  static ModoDiNominareUnArte modoDi(String testo, String parolaChiave) {
    final norm = normalizza(testo);
    final chiave = normalizza(parolaChiave);
    final pezzo = _proposizioneCon(norm, chiave);

    // **ANCHE LA PAROLA CERCATA SI NORMALIZZA.** Prima le chiavi erano
    // scritte senza accento, perche' il testo arrivava normalizzato:
    // una scorciatoia che nascondeva una trappola, visto che chi avesse
    // aggiunto una parola accentata non avrebbe mai combaciato. E sono
    // stringhe di `lib`, quindi la regola di casa vuole gli accenti veri.
    final negato = negazioni.any((n) => contieneLaParola(pezzo, normalizza(n)));
    final giaAvuto =
        responsiGiaAvuti.any((r) => contieneLaParola(pezzo, normalizza(r)));
    final chiesto =
        segniDiRichiesta.any((s) => contieneLaParola(pezzo, normalizza(s)));

    // **L'ordine conta, ed e' questo.** Una negazione vince su tutto, perche'
    // chi dice di non volere una cosa lo dice anche quando la nomina con un
    // verbo di richiesta: *"non voglio una stesa"*. Poi viene il responso gia'
    // avuto, perche' chi ne parla non sta chiedendo di rifarlo. Il segno di
    // richiesta apre solo quando non c'e' ne' l'una ne' l'altro.
    if (negato) return ModoDiNominareUnArte.rifiuto;
    if (giaAvuto) return ModoDiNominareUnArte.menzione;
    if (chiesto) return ModoDiNominareUnArte.richiesta;

    // **LA RICHIESTA NUDA, e in una chat e' la forma piu' comune.** Chi
    // scrive *"Carta del giorno"* e basta la sta chiedendo: non c'e' nessun
    // verbo perche' non ce n'e' bisogno. Si riconosce dal fatto che, tolto il
    // nome dell'arte, nella proposizione non resta nient'altro che parole di
    // servizio.
    return _restaSoloIlNome(pezzo, chiave)
        ? ModoDiNominareUnArte.richiesta
        : ModoDiNominareUnArte.menzione;
  }

  /// Le parole che non aggiungono niente: articoli, preposizioni, possessivi e
  /// gli avverbi di tempo con cui si chiede una cosa per adesso.
  static const List<String> _paroleDiServizio = [
    'il',
    'lo',
    'la',
    'i',
    'gli',
    'le',
    'un',
    'uno',
    'una',
    'del',
    'dello',
    'della',
    'dei',
    'degli',
    'delle',
    'di',
    'da',
    'a',
    'in',
    'con',
    'su',
    'per',
    'fra',
    'tra',
    'al',
    'allo',
    'alla',
    'ai',
    'agli',
    'alle',
    'e',
    'mio',
    'mia',
    'miei',
    'mie',
    'me',
    'mi',
    'oggi',
    'adesso',
    'ora',
    'subito',
    'grazie',
    'per favore',
    'ciao',
  ];

  static bool _restaSoloIlNome(String pezzo, String chiave) {
    final resto = pezzo.replaceAll(chiave, ' ');
    final parole = resto
        .split(RegExp(r'[^a-z0-9]+'))
        .where((p) => p.isNotEmpty && !_paroleDiServizio.contains(p));
    return parole.isEmpty;
  }

  /// La proposizione che contiene [chiave], o tutto il testo se non la trova.
  static String _proposizioneCon(String norm, String chiave) {
    final pezzi = norm.split(RegExp(r'[.,;:!?]'));
    for (final p in pezzi) {
      if (contieneLaParola(p.trim(), chiave)) return p.trim();
    }
    return norm;
  }
}
