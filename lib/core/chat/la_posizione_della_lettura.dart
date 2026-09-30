import '../maestro/maestro.dart';

/// Che cosa chiede una domanda, per la forma della prima frase.
enum TipoDellaDomanda {
  /// Un si' o un no: "Lui mi ama davvero?", "Riuscirò a comprare casa?".
  siONo,

  /// Una scelta fra due strade: "Devo scrivergli io o aspettare?".
  scelta,

  /// Un quando: "Quando cambierà la mia fortuna?".
  quando,

  /// Una domanda aperta: perche', come, che cosa, quale, chi.
  aperta,
}

/// **LA POSIZIONE E' UNA LETTURA, E SI PRENDE SEMPRE.** Ordine ET voce 01, 28
/// settembre 2026.
///
/// Il fondatore: *"Le persone vogliono risposte dirette, Senza tanti giochi di
/// parole"*; e l'ordine: la posizione si dice *"come lettura del Maestro, mai
/// come un fatto certo su ciò che nessuno può sapere"*. Nel banco delle trenta
/// domande, sul commit di partenza, le prime frasi che rispondevano erano 79
/// su 360: Calìgo apriva con le massime ("Non X, ma Y"), Aura girava intorno
/// ("Il futuro non è mio da svelare"), Medora diceva i sentimenti degli altri
/// come fatti ("Lui è legato a te da un amore profondo"). La sola regola
/// nell'istruzione non e' bastata: il primo giro l'ha misurato.
///
/// Qui l'app riconosce che cosa chiede la domanda e dice al modello, per
/// questo turno, con quali parole del suo Maestro comincia la prima frase e
/// che posizione prende; e controlla la prima frase che torna.
abstract final class LaPosizioneDellaLettura {
  /// Con quali parole comincia la lettura di ciascun Maestro: la sua arte,
  /// non un fatto sul mondo.
  ///
  /// **E NON SEMPRE LE STESSE.** Nel secondo giro del banco, con una sola
  /// apertura per Maestro, tutte le trenta risposte di Calìgo cominciavano
  /// con "Le rune dicono" e tutte quelle di Medora con "Le carte e il tuo
  /// cielo dicono": prendevano posizione, e suonavano come una macchina.
  /// L'apertura gira col numero delle risposte gia' date nella
  /// conversazione.
  static List<String> aperture(Maestro maestro) => switch (maestro) {
        Maestro.medora => const [
            'Le carte e il tuo cielo dicono',
            'Nelle carte leggo',
            'Il tuo cielo dice',
            'Le carte rispondono',
          ],
        Maestro.aura => const [
            'I tuoi centri dicono',
            'Nel tuo corpo leggo',
            'La tua energia dice',
            'I tuoi centri rispondono',
          ],
        Maestro.caligo => const [
            'Le rune dicono',
            'Nelle rune leggo',
            'Le pietre rispondono',
            'Il segno che cade dice',
          ],
      };

  /// L'apertura del Maestro dopo [giro] risposte gia' date.
  static String inizio(Maestro maestro, {int giro = 0}) {
    final tutte = aperture(maestro);
    return tutte[giro % tutte.length];
  }

  /// **I CONFINI DI PAROLA SONO SULLE LETTERE UNICODE.** In Dart `\b` conosce
  /// solo le lettere ASCII: dopo "perché" o "sì" non vede un confine, e la
  /// prima stesura non riconosceva ne' "Perché..." ne' "dicono di sì".
  static const String _prima = r'(?<!\p{L})';
  static const String _dopo = r'(?!\p{L})';

  static RegExp _parole(String alternative, {bool inizio = false}) =>
      RegExp('${inizio ? r'^\s*' : _prima}($alternative)$_dopo',
          caseSensitive: false, unicode: true);

  static final RegExp _siONo = _parole('o|oppure');

  /// Che cosa chiede [domanda].
  ///
  /// **LA FRASE CHE CHIEDE, E OGNI SUA PROPOSIZIONE.** Si guarda la frase
  /// che finisce con l'ultimo punto interrogativo, e ciascuna delle sue
  /// proposizioni: *"Sono innamorata di due persone: chi devo scegliere?"*,
  /// *"Vorrei cambiare lavoro, cosa faccio?"*, *"Nella mia stesa sono uscite
  /// tre carte. Come si legge?"*. La prima stesura guardava l'inizio del
  /// testo intero, e la suite l'ha presa: tre domande aperte lette come un
  /// si' o un no, e chieste di nuovo. Una domanda su un fatto (*"Ricordi il
  /// nome del mio cane?"*) e' aperta: non chiede una lettura.
  static TipoDellaDomanda tipo(String domanda) {
    final d = domanda.toLowerCase().trim();
    final fine = d.lastIndexOf('?');
    if (fine < 0) return TipoDellaDomanda.aperta;
    final primaDellaFine = d.substring(0, fine);
    final inizioDellaFrase = RegExp(r'[.!?]')
        .allMatches(primaDellaFine)
        .fold<int>(0, (_, m) => m.end);
    final frase = primaDellaFine.substring(inizioDellaFrase);
    final proposizioni = [
      for (final p in frase.split(RegExp(r'[,:;]')))
        p.replaceFirst(RegExp(r'^\s*(ma|e|allora|e allora)\s+'), '').trim(),
    ];
    bool comincia(String alternative) =>
        proposizioni.any((p) => _parole(alternative, inizio: true).hasMatch(p));
    if (comincia('quando')) return TipoDellaDomanda.quando;
    if (comincia('perch[eé]|come|che cosa|cosa|qual[ei]?|quali|chi|dove|'
        'quanto|quanta|quanti|in che modo|ricordi|ti ricordi|sai|conosci|'
        'mi hai detto')) {
      return TipoDellaDomanda.aperta;
    }
    if (_siONo.hasMatch(frase)) return TipoDellaDomanda.scelta;
    return TipoDellaDomanda.siONo;
  }

  /// **LA DOMANDA DETTA A VOCE ARRIVA SENZA PUNTO INTERROGATIVO.** Ordine ET,
  /// 28 settembre 2026, visto sul Realme: nel LIVE la trascrizione ha scritto
  /// "Il mio ex tornerà" e "Mi prenderanno al colloquio di giovedì." in
  /// tredici domande su diciassette, e senza "?" [tipo] la leggeva aperta: la
  /// regola del sì o del no non arrivava al modello e la rete della prima
  /// frase taceva. Padre: la prima stesura di questa regola, ordine ET voce
  /// 01. Il controller, nel solo LIVE, rimette il punto interrogativo alla
  /// frase detta, se l'ultima frase ha almeno tre parole e non e' una
  /// richiesta o un saluto. Nella chat scritta no: "Lettura generale energia
  /// oggi" e' una richiesta, e la prima stesura, che valeva ovunque, la
  /// trattava da domanda del sì o del no.
  static String comeDomandaDetta(String testo) {
    if (testo.contains('?')) return testo;
    final base = testo.replaceFirst(RegExp(r'[\s.!…]+$'), '');
    final inizio =
        RegExp(r'[.!…]').allMatches(base).fold<int>(0, (_, m) => m.end);
    final ultima = base.substring(inizio).trim();
    final parole = RegExp(r'\p{L}+', unicode: true).allMatches(ultima).length;
    if (parole < 3 || _richiesta.hasMatch(ultima.toLowerCase())) return testo;
    return '$base?';
  }

  static final RegExp _richiesta = RegExp(
      r'^(?:dimmi|parlami|raccontami|spiegami|aiutami|dammi|fammi|mostrami|'
      r'leggimi|leggi|guarda|grazie|ciao|buongiorno|buonasera|salve)(?!\p{L})',
      unicode: true);

  /// **Il blocco del turno**, in fondo all'istruzione: la forma della prima
  /// frase per questa domanda.
  static String perIlTurno(Maestro maestro, String domanda,
      {int giro = 0, DateTime? oggi}) {
    final comincia = inizio(maestro, giro: giro);
    // **LA DOMANDA APERTA NON HA UN'APERTURA OBBLIGATA.** Al secondo giro
    // del banco "Le rune dicono che la solitudine non è assenza, ma un vuoto"
    // aveva la formula davanti e la massima dietro: al perché e al come si
    // risponde con la cosa.
    // **CON PAROLE DI TUTTI I GIORNI, E L'ARTE DALLA SECONDA FRASE.** Ordine
    // ES voce 19, quarto giro: alla lettura alla cieca le prime frasi alle
    // domande aperte erano bocciate 20 volte su 36 per Aura e per Calìgo
    // (*"porta consapevolezza al tuo centro del plesso solare"*, *"il tuo
    // richiamo è un sigillo antico"*) e 9 su 36 per Medora. *"Detta come la
    // legge la tua arte"* invitava a rispondere coi centri e coi sigilli.
    // **Solo a chi ha fatto una domanda**: *"Lettura generale energia oggi"*
    // e *"Ok, gli ho scritto adesso"* non hanno un punto interrogativo, e
    // li' la lettura comincia dall'arte come prima.
    if (tipo(domanda) == TipoDellaDomanda.aperta && !domanda.contains('?')) {
      return 'LA TUA PRIMA FRASE, PER QUESTA DOMANDA ("$domanda"): risponde '
          'a quello che la persona chiede, in concreto: il perché, il come, '
          'la cosa, detta come la legge la tua arte. Non è una massima: mai '
          '"non è X, ma Y", mai una definizione di che cosa sia l\'amore, la '
          'solitudine o la felicità.';
    }
    if (tipo(domanda) == TipoDellaDomanda.aperta) {
      return 'LA TUA PRIMA FRASE, PER QUESTA DOMANDA ("$domanda"): risponde '
          'a quello che la persona chiede con parole di tutti i giorni: la '
          'causa, se chiede perché; il passo da fare, con chi o quando, se '
          'chiede come o che cosa fare; la cosa, se chiede quale o che cosa. '
          'È una frase che la persona può verificare o fare nella sua vita. '
          'La tua arte entra dalla seconda frase, a dire da dove lo leggi, a '
          'meno che la domanda chieda proprio della tua arte. '
          'Non è una massima: mai "non è X, ma Y", mai una definizione di '
          'che cosa sia l\'amore, la solitudine o la felicità.';
    }
    final che = switch (tipo(domanda)) {
      TipoDellaDomanda.siONo =>
        'e prende posizione: sì, no, non ancora, o sì a una condizione che '
            'nomini. Per esempio: "$comincia di sì, se ..." oppure '
            '"$comincia di no, per ora: ...".',
      TipoDellaDomanda.scelta =>
        'e sceglie una delle strade della domanda, nominandola. Per esempio: '
            '"$comincia: scrivigli tu, ..." .',
      // **UN TEMPO, O UN FATTO CHE SI VEDE ACCADERE.** Ordine ES voce 19,
      // quarto giro: al "quando" i tre Maestri erano bocciati da 4 a 6 volte
      // su 8, perche' l'esempio di prima (*"non prima che tu abbia..."*)
      // portava a una condizione dell'animo, *"non prima che tu abbia
      // riconosciuto il tuo valore"*, che i giudici chiamano una massima.
      // **SENZA UNA STAGIONE DA RICOPIARE, E CON LA DATA DI OGGI.** Visto sul
      // Realme il 30 settembre 2026, nel LIVE di Medora: a *"Quando incontrerò
      // la persona giusta?"* e a *"Quando cambierà la mia fortuna?"* la stessa
      // risposta, *"non prima dell'autunno"*, detta quando l'autunno era
      // cominciato da una settimana. Era l'esempio di questa riga, ricopiato:
      // al banco sta nella prima frase di 12 risposte al quando su 24 nel
      // quarto giro e di 11 nel quinto, per tutti e tre i Maestri. Padre:
      // questa voce, quarto giro, commit 9e48605d. Gli esempi adesso hanno i
      // puntini al posto del tempo, e al modello si dice che giorno e' oggi.
      TipoDellaDomanda.quando =>
        'e nomina un tempo che viene dopo oggi${_oggiDetto(oggi)}, preso da '
            'ciò che la tua arte legge per questa persona: un passaggio o una '
            'data fra gli eventi in arrivo che conosci, oppure fra quante '
            'settimane o quanti mesi. Se prima deve accadere un fatto, lo '
            'dici dopo il tempo, con chi o che cosa. Il tempo lo scegli '
            'tu per questa domanda, e lo dici come lettura, non come data '
            'certa. Per esempio: "$comincia: entro ..." oppure "$comincia: '
            'non prima di ... e dopo che avrai ...".',
      TipoDellaDomanda.aperta =>
        'e risponde a quello che la persona chiede, in concreto: il perché, '
            'il come, la cosa.',
    };
    return 'LA TUA PRIMA FRASE, PER QUESTA DOMANDA ("$domanda"): comincia con '
        '"$comincia" $che È la tua lettura, non un fatto: non dire mai che '
        'cosa prova o farà un\'altra persona come una certezza. Non '
        'cominciare dicendo che nessuno può saperlo, che la tua arte non se ne '
        'occupa o che la volontà dell\'altro è sua: se serve, lo dici dopo.';
  }

  static const List<String> _mesi = [
    'gennaio', 'febbraio', 'marzo', 'aprile', 'maggio', 'giugno', //
    'luglio', 'agosto', 'settembre', 'ottobre', 'novembre', 'dicembre'
  ];

  /// ", che è il 30 settembre 2026", o niente se il giorno non si sa.
  static String _oggiDetto(DateTime? oggi) => oggi == null
      ? ''
      : ', che è il ${oggi.day} ${_mesi[oggi.month - 1]} ${oggi.year}';

  /// **La correzione nominata**, quando la prima frase che torna non rispetta
  /// la forma: il turno si chiede di nuovo una volta.
  ///
  /// **CON LA DOMANDA E CON LE PAROLE DA SCRIVERE.** Ordine ES voce 19,
  /// quarto giro: la correzione di prima non ripeteva la domanda e non
  /// diceva che forma prendere, e la seconda risposta restava senza
  /// posizione in 25 casi su 34 per Aura, e circa una volta su due per Medora
  /// e Calìgo. Adesso nomina la domanda e, per il sì o il no, le parole che
  /// vengono subito dopo l'apertura.
  static String correzione(Maestro maestro, String primaFrase,
      {String domanda = '', int giro = 0}) {
    final comincia = inizio(maestro, giro: giro);
    final testa = 'LA TUA PRIMA FRASE NON HA PRESO POSIZIONE: "$primaFrase". '
        '${domanda.trim().isEmpty ? '' : 'La persona ha chiesto: "${domanda.trim()}". '}'
        'Riscrivi la risposta.';
    return switch (tipo(domanda)) {
      TipoDellaDomanda.siONo =>
        '$testa La prima frase comincia con una di queste tre forme, che '
            'completi: "$comincia di sì, se ...", "$comincia di no, per ora: '
            '...", "$comincia: non ancora, ...". Subito dopo "$comincia" '
            'vengono le parole "di sì", "di no" o "non ancora": niente "che" '
            'e nessuna descrizione al loro posto. È la tua lettura, non un '
            'fatto.',
      TipoDellaDomanda.scelta =>
        '$testa La prima frase comincia con "$comincia:" e subito dopo '
            'nomina una delle strade della domanda, con le sue parole.',
      TipoDellaDomanda.quando =>
        '$testa La prima frase comincia con "$comincia:" e subito dopo '
            'nomina un tempo che viene dopo oggi: fra quante settimane o '
            'quanti mesi, o un passaggio in arrivo che conosci. Una '
            'condizione dell\'animo non è un tempo: se c\'è, viene dopo il '
            'tempo. È la tua lettura, non una data certa.',
      TipoDellaDomanda.aperta =>
        '$testa La prima frase comincia con "$comincia" e dice la tua '
            'posizione sulla domanda, come lettura della tua arte, con '
            'parole di tutti i giorni.',
    };
  }

  /// La prima frase di un testo: fino al primo punto, esclamativo o
  /// interrogativo, o fino alla fine della prima riga.
  static String primaFraseDi(String testo) {
    final riga = testo.trimLeft().split('\n').first;
    final m = RegExp(r'^.*?[.!?](?=\s|$)').firstMatch(riga);
    return (m?.group(0) ?? riga).trim();
  }

  static final RegExp _lettura = _parole(
      'carte|carta|cielo|stelle|astri|arcano|arcani|centri|centro|chakra|'
      'energia|corpo|rune|runa|pietre|pietra|segni|segno|lettura|leggo|'
      // Ordine ES voce 19: "Il presagio dice", di Calìgo, e "le lame" di
      // Medora non erano riconosciuti come lettura.
      'presagio|presagi|lame|lama');

  /// **LA MASSIMA "NON X, MA Y"**, separata dal resto dall'ordine ES voce 19:
  /// al giro 6 del banco ha scartato quattro risposte dirette su cinque,
  /// perche' la stessa forma dice anche un passo (*"Non cercare di
  /// dimenticare, ma di trasformare"*, *"Non puoi controllare l'accettazione
  /// altrui, ma puoi custodire il tuo legame"*). E' una massima quando il Y
  /// e' una cosa (*"non è una condanna, ma un invito"*), e' un passo quando e'
  /// un'azione ([_maUnGesto]).
  static final RegExp _nonXmaY = RegExp(
      r"^non [^,.;:]+, ma(?!\p{L})|"
      // La massima anche dietro la formula, dal secondo giro del banco:
      // "Le rune dicono che la sorgente della sofferenza non è negli altri,
      // ma nella soglia che non hai ancora varcato."
      r"(?<!\p{L})non (è|e|sono) [^,.;:]+, ma(?!\p{L})",
      caseSensitive: false,
      unicode: true);

  /// Il Y della massima che e' un'azione: un infinito, anche dopo "di", "a",
  /// "puoi" o "devi".
  static final RegExp _maUnGesto = RegExp(
      r", ma (?:di |a )?(?:puoi |devi )?\p{L}+(?:are|ere|ire)(?:l[aoei]|"
      r"gli|ne)?(?!\p{L})",
      caseSensitive: false,
      unicode: true);

  /// **LE PRIME FRASI CHE GIRANO INTORNO**, dal banco delle trenta domande.
  static final RegExp _giraIntorno = RegExp(
      r"^(non posso|non ti posso|nessun[oa]? (gesto|rito|rituale|lettura|"
      r"può|puo)|la mia arte non|il futuro (è|e|non)|non (è|e) (mio|a me)|"
      r"non chiedere a me|solo (lui|lei) può|nessuno può|non spetta)|"
      r"(?<!\p{L})(un mistero|un velo)(?!\p{L})|"
      r"(?<!\p{L})è qui\.$|"
      // **LA MASSIMA COME DEFINIZIONE**, dal secondo giro: "Le rune dicono
      // che la fiducia è un ponte", "la percezione di mancanza è un
      // sigillo", "la fiamma interiore ha bisogno di nutrimento". Non "la
      // tua fortuna è legata a un cambiamento", che dice una cosa.
      r"(?:che |^)(?:l'|la |il |lo )(?:tua |tuo )?(?:amore|fiducia|desiderio|"
      r"fortuna|felicità|solitudine|sofferenza|dimenticanza|memoria|scelta|"
      r"volontà|vita|risposta|verità|fiamma|percezione|chiave|via|direzione|"
      r"attrazione|strada|forza|sentiero|soglia)(?:\s+(?:di\s+)?\p{L}+){0,2}"
      r"\s+(?:(?:è|non è)\s+(?:un|una|un'|nel|nella|dove|già)|si manifesta|"
      r"ha bisogno|vive|risiede|appare|si trasforma|non ammette|"
      r"non si cancella)(?!\p{L})",
      caseSensitive: false,
      unicode: true);

  /// **IL SI' O IL NO SUBITO DOPO LA LETTURA.** Al secondo giro la regola
  /// cercava un "sì" o un "se" in tutta la prima frase, e passavano *"I tuoi
  /// centri dicono che la risposta non è in un sì o in un no definitivo"* e
  /// *"Il tuo cielo dice che è possibile un ritorno, ma a patto che..."*.
  /// Adesso il sì, il no o il "non ancora" sta subito dopo il verbo della
  /// lettura, o in testa alla frase. Sulle trecentosessanta risposte del
  /// secondo giro la regola stretta ferma 60 delle 99 prime frasi che il
  /// giudice alla cieca dava senza posizione, e 12 delle 261 buone, quasi
  /// tutte posizioni dette come fatto (*"dicono che il tuo capo ti
  /// apprezza"*, *"dicono che andrà bene"*).
  static final RegExp _posizioneDetta = RegExp(
      r'(?:^|(?<!\p{L})(?:dicono|dice|leggo|leggono|rispondono|risponde|'
      r'indicano|indica|mostrano|pende|pendono)(?:\s+che)?\s*:?\s*'
      r'(?:di\s+|verso il\s+)?)(sì|no|non ancora|non adesso|non ora|'
      r'non prima)(?!\p{L})',
      caseSensitive: false,
      unicode: true);

  /// **IL SI' O IL NO DETTI CON LA COSA, ordine ES voce 19.** Al giro 6 del
  /// banco la rete ha scartato ventotto risposte dirette su quarantaquattro,
  /// e i giudizi dati a mano dicono perche': il si' detto come situazione
  /// (*"l'amore è presente"*, *"c'è ancora un legame"*, *"il fuoco
  /// dell'amore è ancora acceso"*, *"la soglia del ritorno è aperta"*),
  /// il si' con un'altra parola (*"leggo successo"*, *"avrà esito
  /// positivo"*, *"è favorevole"*), il no detto con un verbo (*"le rune non
  /// rivelano un tradimento"*, *"non è il momento di forzare"*). Qui si
  /// riconoscono, dopo il verbo della lettura. **Non "è forte"**: *"il tuo
  /// desiderio è forte"* a chi chiede se avra' un figlio non risponde, ed
  /// era giudicata vaga.
  ///
  /// **"E' POSSIBILE" SOLO CON LA SUA CONDIZIONE.** Qui due giudizi si
  /// contraddicevano: al secondo giro il giudice alla cieca dava *"è
  /// possibile un ritorno"* senza posizione, al sesto i giudizi a mano la
  /// davano diretta. Il fondatore ha approvato *"il sì detto senza sì"* e *"il
  /// sì, se"*: "è possibile, a patto che..." e' un si' a una condizione e
  /// passa; "è possibile" da solo e' una prudenza e resta scartato. Scelta
  /// presa con la risposta consigliata, ordine ES voce 19.
  static final RegExp _posizioneConLaCosa = RegExp(
      r"(?<!\p{L})(?:dicono|dice|leggo|leggono|rispondono|risponde|indicano|"
      r"indica|mostrano|mostra)(?!\p{L})[^.!?]*?(?<!\p{L})(?:"
      r"(?:è|sono|resta|restano)\s+(?:ancora\s+)?(?:presente|"
      r"apert[ao]|acces[ao]|favorevole|favorevoli|positiv[ao]|viv[ao])|"
      r"c'è ancora|ci sono ancora|arde ancora|"
      r"esito (?:positivo|favorevole)|"
      r"(?:è|sono)\s+(?:ancora\s+)?possibil[ei][^.!?]*?(?<!\p{L})"
      r"(?:se|a patto|purché|a condizione|non senza)"
      r")(?!\p{L})|"
      // "Leggo" e' insieme il verbo della lettura e la posizione: "Nelle
      // rune leggo ancora un legame forte", "leggo successo, ma solo se".
      // Sta da solo, perche' la prima stesura lo cercava dopo il verbo, cioe'
      // dopo se stesso, e non lo trovava mai.
      r"(?<!\p{L})leggo\s+(?:ancora\s+)?(?:un legame|successo|un ritorno|"
      r"possibilità[^.!?]*?(?<!\p{L})(?:se|a patto|purché|a condizione))"
      r"(?!\p{L})|"
      r"(?<!\p{L})(?:non (?:rivelano|mostrano|vedono|indicano|leggono)\s+"
      r"(?:un|una|il|la|alcun[ao]?)|non è (?:ancora )?il momento)(?!\p{L})",
      caseSensitive: false,
      unicode: true);

  /// **LA SCELTA NOMINA UNA DELLE STRADE.** *"Devo scrivergli io o
  /// aspettare?"*: la prima frase contiene la radice di una parola della
  /// domanda (*scriv-*, *aspet-*), come *"Le rune dicono: scrivigli tu"*.
  /// Al secondo giro passavano *"I tuoi centri dicono che la direzione la
  /// scegli tu"*.
  static bool _nominaUnaStrada(String domanda, String prima) {
    var d = domanda.toLowerCase();
    if (d.contains(':')) d = d.substring(d.lastIndexOf(':') + 1);
    final radici = {
      for (final m in RegExp(r'\p{L}{5,}', unicode: true).allMatches(d))
        if (!const {'devo', 'sono', 'nella', 'della', 'questa', 'quello'}
            .contains(m.group(0)))
          m.group(0)!.substring(0, 5),
    };
    final p = prima.toLowerCase();
    return radici.any(p.contains);
  }

  /// **LA PRIMA FRASE DICE UNA POSIZIONE**: un si', un no, un "non
  /// ancora" o la cosa che li dice (*"l'amore è presente"*), dopo il verbo
  /// della lettura. Ordine ES voce 19, terzo giro: la risposta chiesta di
  /// nuovo per togliere una certezza passa solo se non ha perso la
  /// posizione che la prima aveva.
  static bool diceUnaPosizione(String risposta) {
    final prima = primaFraseDi(risposta);
    return _posizioneDetta.hasMatch(prima) ||
        _posizioneConLaCosa.hasMatch(prima);
  }

  /// Vero se la prima frase di [risposta] rispetta la forma per [domanda].
  static bool rispetta(Maestro maestro, String domanda, String risposta) {
    final prima = primaFraseDi(risposta);
    if (prima.isEmpty || _giraIntorno.hasMatch(prima)) return false;
    // La massima si guarda solo se la posizione non e' gia' detta: in "La
    // tua energia dice di sì, se il suo ritorno non è un peso, ma un nuovo
    // inizio" il "non X, ma Y" sta dentro la condizione del si'.
    if (_nonXmaY.hasMatch(prima) &&
        !_maUnGesto.hasMatch(prima) &&
        !_posizioneDetta.hasMatch(prima)) {
      return false;
    }
    return switch (tipo(domanda)) {
      TipoDellaDomanda.siONo => _lettura.hasMatch(prima) &&
          (_posizioneDetta.hasMatch(prima) ||
              _posizioneConLaCosa.hasMatch(prima)),
      TipoDellaDomanda.scelta =>
        _lettura.hasMatch(prima) && _nominaUnaStrada(domanda, prima),
      // **AL QUANDO SI RISPONDE CON UN TEMPO.** Ordine ES voce 19, sesto
      // giro: tolto l'esempio della stagione, alla lettura alla cieca le
      // prime frasi buone al quando erano 14 su 24, e le dieci bocciate
      // avevano tutte la lettura in apertura e nessun tempo (*"non prima che
      // tu abbia onorato il tuo bisogno di radicamento"*). Sulle 48 risposte
      // dei due giri giudicate dagli stessi lettori
      // (`docs/collaudo/ES/quando_giudicati.json`) le 31 buone nominano un
      // tempo, le 17 bocciate no: la rete adesso lo pretende, e la risposta
      // senza si chiede di nuovo.
      TipoDellaDomanda.quando =>
        _lettura.hasMatch(prima) && nominaUnTempo(prima),
      TipoDellaDomanda.aperta => true,
    };
  }

  /// Se [frase] nomina un tempo: un numero di giorni, settimane, mesi, anni
  /// o lune; una stagione, un mese, una festa; una fase della Luna, un
  /// solstizio; un passaggio del cielo (una retrogradazione, il ciclo di un
  /// pianeta).
  static bool nominaUnTempo(String frase) => _tempo.hasMatch(frase);

  static final RegExp _tempo = RegExp(
      r'(?<!\p{L})(?:'
      r'(?:\d+|un|uno|una|due|tre|quattro|cinque|sei|sette|otto|nove|dieci|'
      r'undici|dodici|qualche|pochi|poche|alcuni|alcune)\s+'
      r'(?:giorn[oi]|settiman[ae]|mes[ei]|ann[oi]|lun[ae]|stagion[ei])'
      r"|(?:prossim[oaie]|quest[oa']|fine)\s*(?:del(?:l[a'])?\s*)?"
      r'(?:settiman[ae]|mes[ei]|ann[oi]|stagion[ei]|luna|primavera|estate|'
      r'autunno|inverno)'
      r'|plenilunio|novilunio|luna (?:nuova|piena)|solstizio|equinozio'
      r'|primavera|estate|autunno|inverno'
      r'|gennaio|febbraio|marzo|aprile|maggio|giugno|luglio|agosto|settembre'
      r'|ottobre|novembre|dicembre|natale|pasqua|capodanno'
      r'|domani|stasera|stanotte'
      r'|retrograd\p{L}*|moto diretto'
      r'|(?:ciclo|transito|ritorno) di (?:saturno|giove|venere|marte|'
      r'mercurio|urano|nettuno|plutone)'
      // Un passaggio del cielo detto col suo verbo: "non prima che Venere
      // torni nel tuo segno".
      r'|(?:saturno|giove|venere|marte|mercurio|urano|nettuno|plutone|'
      r'la luna|il sole) (?:torn|entr|pass|riprend|lasc|raggiung|cambi)'
      r'\p{L}*'
      r')(?!\p{L})',
      unicode: true,
      caseSensitive: false);
}
