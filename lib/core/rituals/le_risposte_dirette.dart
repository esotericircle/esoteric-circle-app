import '../chat/user_profile.dart';
import '../responsi/la_forma_del_responso.dart';
import 'il_presagio_dal_corpus.dart';
import 'l_oggetto_della_domanda.dart';
import 'la_risposta_della_gettata.dart';

/// **LE RISPOSTE DIRETTE DELLE RUNE, SCRITTE PER PIETRA E PER TIPO DI
/// DOMANDA.** Ordine GA voce GA.06, il secondo giro della cura delle Rune di
/// Caligo, 21 ottobre 2026.
///
/// Il corpus sta in `docs/corpus/rune/diretta.md` (il paragrafo della
/// risposta) e `azione.md` (il riquadro "Cosa fare adesso"), un gruppo per
/// runa, verso e tipo di domanda; lo controlla e lo porta nel codice
/// `tool/controlla_le_risposte_dirette_delle_rune.py` (le regole) e
/// `tool/genera_le_risposte_dirette_delle_rune.py` (il generato
/// `le_risposte_dirette.g.dart`). Ogni voce ha uno spazio solo: `{azione}`
/// nelle decisioni ("prima di {azione}"), `{cosa}` negli altri tipi ("per
/// {cosa}"). Qui si decide quale tipo del corpus serve a una domanda e con
/// che cosa si riempie lo spazio.
///
/// **LA VOCE N DI DIRETTA E LA VOCE N DI AZIONE SONO UNA COPPIA**: gli
/// scrittori le hanno scritte insieme, l'azione che segue il paragrafo. Il
/// compositore le sceglie insieme (riapertura della voce GA.06: il lettore
/// cieco ha contato un cosa fare che non seguiva il suo paragrafo).
abstract final class LeRisposteDirette {
  /// I sette tipi del corpus.
  static const List<String> tipi = [
    'decisione', 'scelta', 'come', 'quando', 'previsione', 'altrui', 'vaga', //
  ];

  /// Il tipo del corpus per una domanda letta; null quando la domanda ha un
  /// altro responso: salute, legge e denaro (il limite composto), la
  /// giornata senza domanda e le domande aperte del Cerchio.
  static String? tipoDelCorpus(LaDomandaLetta q, String domanda) {
    if (q.delicato != null) return null;
    return switch (q.tipo) {
      TipoDiDomanda.decisione => 'decisione',
      TipoDiDomanda.scelta => 'scelta',
      TipoDiDomanda.come => 'come',
      TipoDiDomanda.quando => 'quando',
      TipoDiDomanda.previsione => 'previsione',
      TipoDiDomanda.altrui => 'altrui',
      TipoDiDomanda.tuttoBene || TipoDiDomanda.futuro => 'vaga',
      TipoDiDomanda.aperta =>
        LaDomandaLetta.eVaga(LaDomandaLetta.normalizza(domanda))
            ? 'vaga'
            : null,
      TipoDiDomanda.giornata => null,
    };
  }

  /// I valori dello spazio, dal piu' fedele alle parole di chi chiede al
  /// tema: il compositore prende il primo che fa stare il paragrafo fra 40
  /// e 50 parole.
  static List<String> valori(LaDomandaLetta q, String domanda, String tipo) {
    if (tipo == 'decisione') return LOggettoDellaDomanda.azioni(q.azione);
    // Le vaghe non nominano una cosa: "questo momento" si legge dentro ogni
    // voce ("A una domanda aperta, per questo momento, le pietre non danno
    // un verdetto"); "ciò che ti sta a cuore" era un complemento vuoto
    // (lettore cieco, riapertura della voce GA.06).
    if (tipo == 'vaga') {
      return const ['questo momento', 'il tuo momento'];
    }
    final fuori = <String>[];
    for (final v in [
      ...LOggettoDellaDomanda.di(domanda, q.tipo, strade: q.strade),
      q.tema,
    ]) {
      if (!fuori.contains(v)) fuori.add(v);
    }
    return fuori;
  }

  /// **IL TIPO CON CUI SI LEGGE LA SCHEDA DI UNA PIETRA.** Il responso
  /// principale ha un tipo (decisione, previsione...), le schede ne usano
  /// uno che non contraddica il suo verdetto e regga con la cosa della
  /// domanda:
  /// - "come" per decisione, scelta, come e altrui: dice il modo della pietra
  ///   per quella cosa, senza un verdetto che potrebbe contraddire quello
  ///   della pietra che decide;
  /// - lo stesso tipo per previsione e quando: le voci "come" sono scritte per
  ///   i legami e dicevano "dilla alla persona coinvolta" a chi aspettava un
  ///   esame (lettura severa, riapertura della voce GA.06);
  /// - nessuno per le vaghe, la giornata e le domande aperte del Cerchio: la
  ///   scheda e' la coppia PIETRA/CONSIGLIO neutra della pietra.
  static String? tipoDelleSchede(String? tipoDelPrincipale) =>
      switch (tipoDelPrincipale) {
        'decisione' || 'scelta' || 'come' || 'altrui' => 'come',
        'previsione' || 'quando' => tipoDelPrincipale,
        _ => null,
      };

  /// **I VALORI PER LE SCHEDE DELLE SINGOLE PIETRE.** Il responso principale
  /// ha gia' detto la cosa per intero ("la decisione di accettare l'offerta
  /// della nuova azienda"); in ogni scheda ripeterla era una cucitura in
  /// apertura (lettore cieco, riapertura della voce GA.06), quindi qui sta
  /// corta: "questa decisione", "questa scelta", "questo legame", o il nome
  /// della persona o della cosa se sta in tre parole ("tuo figlio", "il tuo
  /// esame"); altrimenti "questa situazione". Il lettore cieco del terzo giro
  /// ha contato il complemento d'ambito incollato in apertura a ogni scheda
  /// ("per il conflitto con il tuo capo" cinque volte): la persona resta nel
  /// "chi e' coinvolto" delle voci ([conLaPersona]), la cosa lunga sta nel
  /// responso principale.
  static List<String> valoriPerLeSchede(
      LaDomandaLetta q, String domanda, String? tipo) {
    if (tipo == null) return [q.tema];
    switch (tipo) {
      case 'decisione':
        // La scelta con le parole di chi chiede, quando e' corta ("la scelta
        // di lasciare Roma"): le schede pari la nominano, le dispari dicono
        // "questa decisione" (lettore cieco dell'ultimo giro: nessuna scheda
        // nominava la cosa della domanda).
        final a = q.azione;
        return [
          // "per lasciare Roma", "per accettare l'offerta": ogni spazio delle
          // voci sta dopo "per", e l'infinito ci sta.
          if (a != null && a.split(' ').length <= 5) a,
          'questa decisione',
        ];
      case 'scelta':
        return const ['questa scelta'];
      case 'vaga':
        return valori(q, domanda, tipo);
      default:
        final corti = [
          for (final v in valori(q, domanda, tipo))
            // Il tema ("il lavoro" sotto un conflitto con il capo) e' una
            // cosa piu' larga di quella chiesta: meglio "questa situazione".
            if (v.split(' ').length <= 3 && v != q.tema) v,
        ];
        if (tipo == 'altrui') {
          corti
            ..remove('questo legame')
            ..insert(0, 'questo legame');
        }
        return corti.isEmpty ? const ['questa situazione'] : corti;
    }
  }

  // -------------------------------------------------------------------------
  // LA PERSONA DELLA DOMANDA AL POSTO DI "CHI E' COINVOLTO"
  // -------------------------------------------------------------------------

  /// **LA PERSONA DI CUI SI CHIEDE**, se la domanda ne nomina una sola, al
  /// singolare, nelle parole di chi chiede ("Marco", "tuo figlio", "il tuo
  /// capo", "lui"). Ordine GA voce GA.06, terzo giro: il lettore cieco ha
  /// letto "a chi e' coinvolto" sotto "il conflitto con il mio capo"
  /// (*"vago quando l'interlocutore e' il capo"*) e "l'altra persona" sotto
  /// "Cosa prova davvero Marco per me?". Null quando la domanda non ne
  /// nomina una che si legga bene: allora le voci restano come sono.
  static String? laPersona(LaDomandaLetta q, String domanda, String? tipo) {
    if (tipo == null) return null;
    // Mai il tema ("la tua famiglia" sotto "il pranzo di Natale con la
    // famiglia di lui": la famiglia e' di lui, non tua) ne' un collettivo: i
    // verbi delle voci sono al singolare.
    final candidati = [
      for (final v in tipo == 'decisione'
          ? LOggettoDellaDomanda.azioni(q.azione)
          : valori(q, domanda, tipo))
        if (v != q.tema) v
    ];
    final collettivo = RegExp(r'famigli|genitori|amici|colleghi|figli\b');
    // Un nome o "il tuo capo" dopo "con"; "lui" e "lei" anche dopo "di" e "a"
    // ("dirle che sono innamorato di lei"). Mai un nome dopo "a" o "di": e'
    // una citta' ("trasferirmi a Milano").
    // "La tua relazione" o "il tuo lavoro" sono cose, non persone: solo i
    // nomi di chi si puo' avere davanti.
    const chi = r'(?:figli[oa]|sorella|fratello|madre|padre|mamma|papà|marito|'
        r'moglie|compagn[oa]|ragazz[oa]|fidanzat[oa]|amic[oa]|amica|capo|'
        r'capa|collega|ex|nonn[oa]|zi[oa]|cugin[oa]|suocer[oa]|genero|'
        r'nuora|socio|socia|insegnante|professor[ea]|medico|datore)';
    final nome = RegExp(r'(?:^|\s)(?:con ((?:il |la |lo |l’)?tu[oa] ' +
        chi +
        r'|[A-ZÀ-Ý][a-zà-ÿ]+)|(?:di|a|con) (lui|lei))$');
    final propria = RegExp(r'^((?:il |la |lo )?tu[oa] ' + chi + r')$');
    for (final v in candidati) {
      final m = nome.firstMatch(v.replaceAll("'", '’').trim()) ??
          propria.firstMatch(v.trim());
      if (m == null) continue;
      final persona =
          m.groupCount >= 2 ? (m.group(1) ?? m.group(2)!) : m.group(1)!;
      // Mai un plurale: i verbi delle voci sono al singolare.
      if (RegExp(r'^(i |le |gli )|tuoi|tue').hasMatch(persona) ||
          collettivo.hasMatch(persona)) {
        continue;
      }
      return persona;
    }
    return null;
  }

  /// Le preposizioni articolate, una riga per preposizione: davanti a il, a
  /// lo, a la, a l'. Sono scritte per intero e non per chiave perche' una
  /// preposizione isolata fra virgolette nel codice e' una parola che la
  /// guardia degli accenti legge come un verbo.
  static const String _fuseA = 'al|allo|alla|all’';
  static const String _fuseDa = 'dal|dallo|dalla|dall’';
  static const String _fuseDi = 'del|dello|della|dell’';

  /// [fuse] e' una delle tre righe qui sopra, oppure 'con' (che non si fonde).
  static String _conPreposizione(String fuse, String persona) {
    final semplice = fuse.startsWith('del')
        ? 'di'
        : fuse.startsWith('con')
            ? 'con'
            : fuse.substring(0, fuse.indexOf('l'));
    final m = RegExp(r'^(?:(il|la|lo) |(l’))(.*)$').firstMatch(persona);
    if (m == null || fuse == 'con') {
      return '$semplice $persona';
    }
    final articolo = m.group(1) ?? m.group(2)!;
    final resto = m.group(3)!;
    final forme = fuse.split('|');
    final fusa = switch (articolo) {
      'il' => forme[0],
      'lo' => forme[1],
      'la' => forme[2],
      _ => forme[3],
    };
    return articolo == 'l’' ? '$fusa$resto' : '$fusa $resto';
  }

  /// Le voci con la [persona] al posto di "chi e' coinvolto", "la persona
  /// coinvolta" e "l'altra persona".
  static String conLaPersona(String testo, String persona) {
    var t = testo.replaceAll("'", '’');
    String maiuscola(String s) =>
        s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
    t = t.replaceAllMapped(
        RegExp(r'(?<![a-zà-ÿ])(A|a|Da|da|Di|di|Con|con) chi è coinvolt[oa]'),
        (m) => _maiuscolaSeServe(
            m.group(1)!,
            _conPreposizione(
                switch (m.group(1)!.toLowerCase()) {
                  'con' => 'con',
                  'di' => _fuseDi,
                  'a' => _fuseA,
                  _ => _fuseDa,
                },
                persona)));
    t = t.replaceAllMapped(
        RegExp(
            r'(?<![a-zà-ÿ])(Alla|alla|Dalla|dalla|Della|della|Con la|con la) '
            r'persona coinvolta'), (m) {
      final p = m.group(1)!.toLowerCase();
      final prep = p.startsWith('alla')
          ? _fuseA
          : p.startsWith('dalla')
              ? _fuseDa
              : p.startsWith('della')
                  ? _fuseDi
                  : 'con';
      return _maiuscolaSeServe(m.group(1)!, _conPreposizione(prep, persona));
    });
    t = t.replaceAllMapped(
        RegExp(r'(?<![a-zà-ÿ])(All’|all’|Dall’|dall’|Dell’|dell’|Con l’|con l’)'
            r'altra persona'), (m) {
      final p = m.group(1)!.toLowerCase();
      final prep = p.startsWith('all')
          ? _fuseA
          : p.startsWith('dall')
              ? _fuseDa
              : p.startsWith('dell')
                  ? _fuseDi
                  : 'con';
      return _maiuscolaSeServe(m.group(1)!, _conPreposizione(prep, persona));
    });
    t = t.replaceAllMapped(
        RegExp(r'(?<![a-zà-ÿ])(All’|all’|Dall’|dall’|Dell’|dell’)altra parte'),
        (m) {
      final p = m.group(1)!.toLowerCase();
      final prep = p.startsWith('all')
          ? _fuseA
          : p.startsWith('dall')
              ? _fuseDa
              : _fuseDi;
      return _maiuscolaSeServe(m.group(1)!, _conPreposizione(prep, persona));
    });
    t = t.replaceAllMapped(RegExp(r'(?<![a-zà-ÿ])(L’|l’)altra parte'),
        (m) => m.group(1)! == 'L’' ? maiuscola(persona) : persona);
    t = t.replaceAllMapped(RegExp(r'(?<![a-zà-ÿ])(L’|l’)altra persona'),
        (m) => m.group(1)! == 'L’' ? maiuscola(persona) : persona);
    t = t.replaceAllMapped(RegExp(r'(?<![a-zà-ÿ])(Chi|chi) è coinvolt[oa]'),
        (m) => m.group(1)! == 'Chi' ? maiuscola(persona) : persona);
    // La persona coinvolta senza preposizione articolata: "ascoltare la
    // persona coinvolta", "per la persona coinvolta", "come vede la cosa la
    // persona coinvolta".
    t = t.replaceAllMapped(RegExp(r'(?<![a-zà-ÿ])(La|la) persona coinvolta'),
        (m) => m.group(1)! == 'La' ? maiuscola(persona) : persona);
    return t;
  }

  static String _maiuscolaSeServe(String originale, String nuovo) =>
      originale.isNotEmpty && originale[0] == originale[0].toUpperCase()
          ? nuovo[0].toUpperCase() + nuovo.substring(1)
          : nuovo;

  /// **LA COSA GENERICA DELLE SCHEDE**, per le schede dispari: la cosa
  /// della domanda detta per intero a ogni scheda era la cucitura che il
  /// lettore cieco ha contato ("per la tua relazione" cinque volte). Le
  /// schede pari la nominano, le dispari dicono "questa situazione".
  static String genericoPerLeSchede(String tipo) => switch (tipo) {
        'decisione' => 'questa decisione',
        'scelta' => 'questa scelta',
        'altrui' => 'questo legame',
        _ => 'questa situazione',
      };

  /// I valori in ordine, prima quelli la cui ultima parola la voce non dice
  /// gia' da sola.
  static List<String> senzaRipetizioni(String voce, List<String> valori) {
    final minuscola = voce.toLowerCase();
    bool ripete(String v) {
      final ultima = v.toLowerCase().split(' ').last;
      return ultima.length > 3 &&
          LaDomandaLetta.parola(RegExp.escape(ultima)).hasMatch(minuscola);
    }

    return [...valori.where((v) => !ripete(v)), ...valori.where(ripete)];
  }

  /// La voce con lo spazio riempito (e la nota della domanda doppia, se
  /// c'e'), fra 40 e 50 parole; null se nessun valore la fa stare.
  ///
  /// **Il riquadro (comeAzione)**: "per questo momento" detto due volte, nel
  /// paragrafo e nel riquadro di una domanda vaga, e' una cucitura (lettore
  /// cieco dell'ultimo giro: "per questo momento infilato a forza"); nel
  /// riquadro diventa "per adesso".
  ///
  /// **Una cosa generica non apre il testo**: "Per questa situazione procedi"
  /// apriva quindici testi di dodici gettate (stesso lettore). Con "questa
  /// situazione", "questa decisione", "questa scelta" o "questo legame" una
  /// voce che comincia con "Per {cosa}" comincia dal verbo, se il testo resta
  /// a misura.
  static const Set<String> _cosaGenerica = {
    'questa situazione',
    'questa decisione',
    'questa scelta',
    'questo legame',
  };

  static const List<String> _aperture = [
    'In questo caso',
    'Su questo punto',
    'In questa fase',
  ];

  static String? riempi(String voce, List<String> valori,
      {List<String> note = const [''], bool comeAzione = false}) {
    final spazio = voce.contains('{azione}') ? '{azione}' : '{cosa}';
    // Prima i valori che la voce non ripete gia' con parole sue ("Restringi
    // la domanda a ciò che ti sta più a cuore" con "per ciò che ti sta a
    // cuore" dentro), poi, se nessuno sta nella misura, anche quelli.
    final ordinati = senzaRipetizioni(voce, valori);
    for (final n in note) {
      for (final v0 in ordinati) {
        final v =
            comeAzione && (v0 == 'questo momento' || v0 == 'il tuo momento')
                ? 'adesso'
                : v0;
        if (spazio == '{cosa}' &&
            _cosaGenerica.contains(v) &&
            voce.startsWith('Per {cosa}')) {
          var resto = voce.substring('Per {cosa}'.length);
          if (resto.startsWith(',')) resto = resto.substring(1);
          resto = resto.trimLeft();
          if (resto.isNotEmpty) {
            final aperta = resto[0].toUpperCase() + resto.substring(1);
            final t = [aperta.replaceAll(spazio, v), n]
                .where((x) => x.isNotEmpty)
                .join(' ');
            if (LaFormaDelResponso.aMisura(t)) return t;
          }
          // Se senza l'apertura il testo scende sotto le quaranta parole,
          // l'apertura cambia a parita' di parole: tre modi, uno per voce.
          final apertura = _aperture[voce.length % _aperture.length];
          final t = [
            voce.replaceFirst('Per {cosa}', apertura).replaceAll(spazio, v),
            n
          ].where((x) => x.isNotEmpty).join(' ');
          if (LaFormaDelResponso.aMisura(t) &&
              t.split(' ').length ==
                  voce.replaceAll(spazio, v).split(' ').length &&
              apertura.split(' ').length == 3 &&
              v.split(' ').length == 2) {
            return t;
          }
        }
        final t = [voce.replaceAll(spazio, v), n]
            .where((x) => x.isNotEmpty)
            .join(' ');
        if (LaFormaDelResponso.aMisura(t)) return t;
      }
    }
    return null;
  }

  // -------------------------------------------------------------------------
  // CHE COSA UNA VOCE DICE, PER QUANTO RIGUARDA LA DOMANDA
  // -------------------------------------------------------------------------

  /// Una voce che chiede o aspetta un tempo lungo: dopo due settimane, per un
  /// mese, ogni domenica, tutti i giorni per... Non "da anni" ne' "un anno
  /// fa": quelli sono il passato, e non fanno una durata da qui in avanti.
  static final RegExp _tempoLungo = LaDomandaLetta.parola(
      r'(dopo|fra|tra|per|entro|in) (una|due|tre|quattro|cinque|sei|sette|'
      r'otto|dieci|quindici|venti|trenta) (settimane|settimana|mesi|mese)|'
      r'(dopo|fra|tra|per|entro|in) (sette|otto|dieci|quindici|venti|'
      r'trenta) giorni|settimana (prossima|dopo|successiva)|'
      r'ogni (domenica|lunedì|martedì|mercoledì|giovedì|venerdì|sabato|'
      r'settimana|mese)|un mese|due mesi|per un anno|tutti i giorni per|'
      r'ogni giorno per|con regolarità|ogni sera per|per tre sere|'
      r'(due|tre|quattro|cinque|sei|sette|otto) (settimane|mesi)|'
      r'(prossim|ultim)[ei] (due|tre|quattro)');

  /// Un valore che sta a pochi giorni: un colloquio di giovedi', domani.
  static final RegExp _tempoBreve = LaDomandaLetta.parola(
      r'domani|dopodomani|stasera|oggi|lunedì|martedì|mercoledì|giovedì|'
      r'venerdì|sabato|domenica|questa settimana');

  /// Le voci che presuppongono un conflitto o una paura.
  static final RegExp _vociDiConflitto = LaDomandaLetta.parola(
      r'ripicc\w*|rimprover\w*|litig\w*|conflitt\w*|rancor\w*|torto|torti|'
      r'scontr\w*|discussion\w*|offes\w*|risentiment\w*|provoc\w*|'
      r'ultimatum|accus\w*|rival\w*|'
      r'rabbia|arrabbiat\w*');
  static final RegExp _vociDiPaura = LaDomandaLetta.parola(
      r'paur\w*|timor\w*|ansi\w*|panic\w*|angosc\w*|terror\w*|'
      r'spavent\w*');

  static final Map<String, bool> _paure = {};
  static final Map<String, bool> _conflitti = {};
  static final Map<String, bool> _lunghi = {};

  static bool haLaPaura(String testo) => _paure.putIfAbsent(
      testo, () => _vociDiPaura.hasMatch(testo.toLowerCase()));
  static bool haIlConflitto(String testo) => _conflitti.putIfAbsent(
      testo, () => _vociDiConflitto.hasMatch(testo.toLowerCase()));
  static bool haUnTempoLungo(String testo) => _lunghi.putIfAbsent(
      testo, () => _tempoLungo.hasMatch(testo.toLowerCase()));

  /// Che cosa la domanda dice di conflitto e di paura: le parole che
  /// licenziano le voci che li presuppongono.
  static final RegExp _domandaDiConflitto = LaDomandaLetta.parola(
      r'conflitt\w*|litig\w*|lite|liti|discut\w*|discussion\w*|scontr\w*|'
      r'pace|riconcili\w*|rabbia|rival\w*|'
      r'rancor\w*|torto|offes\w*|arrabbiat\w*|perdon\w*|tension\w*|'
      r'problem\w*|difficil\w*|crisi|silenzio|freddezza|distanz\w*|'
      r'tradit\w*|bugi\w*|delus\w*|ferit\w*|gelos\w*');
  static final RegExp _domandaDiPaura = LaDomandaLetta.parola(
      r'paur\w*|timor\w*|ansi\w*|agit\w*|preoccup\w*|teng\w*|nervos\w*|'
      r'stress\w*|spavent\w*|panic\w*|angosc\w*|dubb\w*|insicur\w*');

  /// Le voci che danno la persona per vicina: un'uscita insieme, un
  /// confronto a quattr'occhi, "digli". Sotto "Lui tornerà da me?" il lettore
  /// severo del terzo giro ha letto "una colazione insieme a lui".
  static final RegExp _vociDiPresenza = LaDomandaLetta.parola(
      r"a quattr['’]occhi|insieme a (lui|lei|chi è coinvolt[oa]|"
      r"l['’]altra persona|la persona coinvolta)|"
      r"(passeggiata|colazione|caffè|cena|pranzo|serata|uscita) "
      r"(insieme|con (lui|lei|chi è coinvolt[oa]|l['’]altra persona))|"
      r"momento (sereno |piacevole |tranquillo )?(da condividere|da passare)|"
      r"insieme all['’]altra persona|guardando (in faccia|negli occhi)|"
      r"incontra (chi è coinvolt[oa]|l['’]altra persona|lui|lei)|"
      r"un caffè");

  /// Le voci che danno per presente una controparte ("a chi e' coinvolto",
  /// "l'altra persona"): sotto "Devo accettare l'offerta della nuova
  /// azienda?" o "Devo trasferirmi a Milano o restare a Bari?" nessuno e'
  /// nominato, e il lettore cieco del terzo giro ha letto "chi e' coinvolto"
  /// come vago ("a chi e' coinvolto e' vago quando l'interlocutore e' il
  /// capo"). Una domanda che nomina o fa pensare a una persona le licenzia.
  static final RegExp _vociConControparte = LaDomandaLetta.parola(
      r"chi è coinvolt[oa]|l['’]altra persona|persona coinvolta|"
      r"persone coinvolte|all['’]altra persona|dell['’]altra persona|"
      r"dall['’]altra persona|l['’]altra parte|voce bassa|prima di "
      r"rispondere|replicare|alza i toni|conversazione importante|"
      r"tono pacato|tono calmo|che cosa intendevi|che cosa intendi|"
      r"credi di aver sentito|una frase che ti pesa");
  static final RegExp _domandaConControparte = LaDomandaLetta.parola(
      r'lui|lei|loro|capo|capa|collega|colleghi|marito|moglie|figli\w*|'
      r'madre|padre|mamma|papà|fratell\w*|sorell\w*|amic\w*|ex|partner|'
      r'compagn\w*|famigli\w*|genitor\w*|suocer\w*|socio|ragazz[oa]|'
      r'fidanzat\w*|nonn\w*|zi[oa]|cugin\w*|vicin[oa]|'
      r'relazione|coppia|matrimonio|persona');

  /// Le voci che chiamano in causa altre persone oltre a chi chiede ("le tre
  /// persone che contano di piu'", "chi ti sta vicino", un gruppo): sotto
  /// "Devo dirle che sono innamorato di lei?" il lettore cieco dell'ultimo
  /// giro ha letto una condizione che non c'entra con una dichiarazione
  /// d'amore e un cosa fare che presumeva terzi. Una domanda che parla di
  /// famiglia, amici, colleghi o di un gruppo le licenzia.
  static final RegExp _vociConTerzi = LaDomandaLetta.parola(
      r'persone che contano|tre persone|persone a cui tieni|persone care|'
      r'chi ti (sta |è )?vicin[oa]|chi ti circonda|chi ti sta accanto|'
      r'tuoi cari|cerchia|comunità|gruppo|squadra|famiglia|amici|colleghi|'
      r'chi ti vuole bene|stare meglio con le persone');
  static final RegExp _domandaConTerzi = LaDomandaLetta.parola(
      r'famigli\w*|amici|amiche|colleghi|collegh[ei]|genitori|figli|fratelli|'
      r'parenti|gruppo|squadra|team|persone|gente|tutti|suoceri|nonni|'
      r'compagni di|vicini|amicizie|cerchia|comunità|soci');

  /// **LA POSTURA DI UN TESTO: ATTENDERE O AGIRE.** Ordine GA voce GA.06,
  /// ultimo giro. Il lettore cieco ha letto, nella stessa gettata, "Sospendi
  /// per tre settimane ogni discorso decisivo" sotto "chiedi entro tre giorni
  /// un momento a quattr'occhi", e un principale che dice "Rimanda di una
  /// settimana" sopra schede che dicono "dichiaralo apertamente alla persona
  /// interessata". Un testo chiede di attendere (sospendi, rimanda, non
  /// parlare, aspetta alcuni giorni) o di agire subito (dillo, chiedi,
  /// proponi entro pochi giorni, a quattr'occhi); se chiede entrambe le cose
  /// o nessuna, non ha una postura.
  static final RegExp _chiedeAttesa = LaDomandaLetta.parola(
      r"sospendi|sospendere|rimand\w*|fermati|"
      r'non (decidere|prendere|dire|scrivere|parlare|parlarne|chiedere|'
      r'riaprire|affrontare|comunicare|annunciare|agire|firmare|rispondere|'
      r'forzare|fare mosse)|'
      r'niente (ultimatum|decisioni|mosse|chiarimenti|messaggi|annunci|'
      r'iniziative|discorsi)|'
      r'(aspetta|attendi|lascia passare|concediti) (almeno )?(un|due|tre|'
      r'quattro|cinque|sette|dieci|quindici|ventiquattro|quarantotto|'
      r'qualche) (ore|giorno|giorni|settimana|settimane|mese|notte|notti)|'
      r'per (due|tre|quattro|cinque|sette|dieci|quindici) (giorni|settimane) '
      r'(non|niente)');
  static const String _scadenzaBreve =
      r"(entro|fra|tra) (oggi|domani|stasera|(due|tre|quattro|cinque) giorni|"
      r'venerdì|sabato|domenica|mercoledì|giovedì|lunedì|martedì)|oggi stesso|'
      r'domattina|domani mattina';
  static const String _gestoVersoUnAltro =
      r"di'|dillo|dilla|dille|dirgli|dirle|chiedi|chiedile|chiedigli|proponi|"
      r'proponile|proponigli|parla|parlane|manda|invia|comunica|dichiara\w*|'
      r'fissa un incontro|incontra|telefona|chiama';
  static final RegExp _chiedeAzione = LaDomandaLetta.parola(
      "(?:$_scadenzaBreve)[^.]{0,90}(?:$_gestoVersoUnAltro)|"
      "(?:$_gestoVersoUnAltro)[^.]{0,90}(?:$_scadenzaBreve)|"
      r"a quattr'occhi|dichiaralo apertamente|apertamente (alla|a|con)|"
      r'conversazione diretta|a viso aperto|parla in prima persona|'
      r"(dillo|dilla|dille) (a voce|apertamente)");

  /// 'attesa', 'azione' o null. Le voci sono le stesse migliaia di volte per
  /// presagio: il risultato si ricorda (la prova dei sessanta giorni chiama
  /// questa misura milioni di volte).
  static final Map<String, String?> _posture = {};

  static String? postura(String testo) {
    if (_posture.containsKey(testo)) return _posture[testo];
    final t = testo.toLowerCase().replaceAll('’', "'");
    final attesa = _chiedeAttesa.hasMatch(t);
    final azione = _chiedeAzione.hasMatch(t);
    return _posture[testo] =
        attesa == azione ? null : (attesa ? 'attesa' : 'azione');
  }

  /// La postura del verdetto con cui apre un paragrafo diretto.
  static String? posturaDelVerdetto(String paragrafo) {
    final p = paragrafo.trimLeft();
    if (RegExp(r'^(Non ancora|Non adesso|Non ora|Non a caldo|Non così|'
            r'Aspetta|Rimanda|Meglio rimandare|Meglio attendere|'
            r'Meglio una sosta|Ancora no|Fermati)')
        .hasMatch(p)) {
      return 'attesa';
    }
    if (RegExp(r'^Sì, (adesso|subito|ora)').hasMatch(p)) return 'azione';
    return null;
  }

  /// La persona di cui si chiede non e' vicina: tornera', un'ex, la
  /// distanza, "come lo dimentico".
  static final RegExp _domandaDiAssenza = LaDomandaLetta.parola(
      r"tornerà da|tornare da|torna da|ritorn\w* (da|con)|ex|lasciat\w*|"
      r"se n['’]è andat\w*|"
      r"se ne è andat\w*|separat\w*|non (mi )?(scrive|risponde|parla|cerca|"
      r'chiama)\w*|sparit\w*|distanza|lontan\w*|dimentic\w*|superare|'
      r'archiviar\w*');

  /// Le licenze di una domanda ("conflitto", "paura", "assenza"), per
  /// [regge].
  static Set<String> licenze(String domanda) {
    final d = LaDomandaLetta.normalizza(domanda);
    // Un nome proprio a meta' frase ("Cosa prova davvero Marco per me?"), non
    // dopo "a", "in", "da"... (sono le citta': "restare a Bari").
    final nome =
        RegExp(r'(?<=[a-zà-ÿ,] )(?<!\b(?:a|in|da|di|per|fra|tra|verso|su) )'
                r'[A-ZÀ-Ý][a-zà-ÿ]+')
            .hasMatch(domanda);
    return {
      if (nome || _domandaConControparte.hasMatch(d)) 'controparte',
      if (_domandaDiConflitto.hasMatch(d)) 'conflitto',
      if (_domandaDiPaura.hasMatch(d)) 'paura',
      if (_domandaDiAssenza.hasMatch(d)) 'assenza',
      if (_tempoBreve.hasMatch(d)) 'breve',
      if (_domandaConTerzi.hasMatch(d)) 'terzi',
    };
  }

  /// Una voce che parla di chiudere un legame, rompere, separare.
  static final RegExp _chiudeUnLegame = LaDomandaLetta.parola(
      r'rompere|rompi|strappi|strappo|separ\w*|chiudere un legame|'
      r'chiude un legame|chiusura|tagliare|taglia|'
      // Le clausole sul lasciare, dette a chi chiede se riprovarci o se dirlo
      // ("Se la decisione è di lasciare, chiediti..." sotto "Ha senso
      // riprovarci con la mia ex?", lettura severa del terzo giro).
      r'si tratta di (lasciare|chiudere|smettere)|'
      r'(decisione|scelta) è di (lasciare|chiudere|smettere)|'
      r'(vuol dire|significa) (lasciare|chiudere|smettere)');

  /// **UNA VOCE REGGE CON QUESTA DOMANDA?** Ordine GA voce GA.06, riapertura:
  /// - un valore a pochi giorni ("il colloquio di giovedì") non regge con un
  ///   cosa fare che comincia dopo una settimana o dura un mese;
  /// - una decisione che non chiude niente ("dirle che sei innamorato") non
  ///   regge con la clausola sul rompere un legame, che e' di un'altra
  ///   domanda.
  ///
  /// - una voce che presuppone un conflitto ("la tentazione della ripicca",
  ///   "una lista di rimproveri") o una paura ("senza le paure della notte")
  ///   non regge con una domanda che non ne parla: [licenze] dice quali la
  ///   domanda ne porta. Il lettore cieco del terzo giro ha contato nelle
  ///   schede una paura e una ripicca che la domanda non conteneva (padre:
  ///   riapertura della voce GA.06, `diretta.md` e `azione.md` del secondo
  ///   giro, scritte per il caso difficile di ogni tipo).
  static bool regge(String voce, String valore,
      {required bool chiude, Set<String> licenze = const {}}) {
    final s = _segni(voce);
    if (!licenze.contains('conflitto') && s.conflitto) return false;
    if (!licenze.contains('paura') && s.paura) return false;
    // Una scelta di vita col suo lato di denaro: niente voci che spingono a
    // muovere, spendere o vendere beni.
    if (licenze.contains('denaro') && s.beni) return false;
    if (!licenze.contains('controparte') && s.controparte) return false;
    if (!licenze.contains('terzi') && s.terzi) return false;
    if (licenze.contains('noAzione') && s.postura == 'azione') return false;
    if (licenze.contains('noAttesa') && s.postura == 'attesa') return false;
    if (licenze.contains('assenza') && s.presenza) return false;
    // L'orizzonte breve lo dice la domanda intera, non il valore scelto per
    // lo spazio: sotto "Il colloquio di giovedi' andra' bene?" una scheda che
    // dice "questa situazione" non deve proporre di rileggere dopo sette
    // giorni (lettura severa del terzo giro).
    if (!licenze.contains('senzaBreve') &&
        (licenze.contains('breve') ||
            _tempoBreve.hasMatch(valore.toLowerCase())) &&
        s.tempoLungo) {
      return false;
    }
    if (!chiude && s.chiudeUnLegame) return false;
    return true;
  }

  /// I segni di una voce, misurati una volta sola: le voci sono le stesse
  /// migliaia di volte per presagio, e la prova dei sessanta giorni chiede
  /// "questa voce regge?" milioni di volte.
  static final Map<String, _SegniDiUnaVoce> _segniMemoria = {};

  static _SegniDiUnaVoce _segni(String voce) =>
      _segniMemoria.putIfAbsent(voce, () {
        final b = voce.toLowerCase();
        return _SegniDiUnaVoce(
          conflitto: _vociDiConflitto.hasMatch(b),
          paura: _vociDiPaura.hasMatch(b),
          beni: IlPresagioDalCorpus.spintaAMuovereBeni.hasMatch(b),
          controparte: _vociConControparte.hasMatch(b),
          terzi: _vociConTerzi.hasMatch(b),
          presenza: _vociDiPresenza.hasMatch(b),
          tempoLungo: _tempoLungo.hasMatch(b),
          chiudeUnLegame: _chiudeUnLegame.hasMatch(b),
          postura: postura(voce),
        );
      });

  /// **IL VALORE E LE VOCI CHE CI STANNO.** Per il primo valore (dal piu'
  /// fedele) che fa stare nella misura almeno una coppia di voci, quali
  /// coppie ci stanno: la voce N di [dirette] e la voce N di [azioni].
  /// Restituisce anche, per una seconda scelta, i valori che non reggono con
  /// il filtro del senso ma stanno nella misura: meglio una coppia che regge
  /// per la misura che nessuna.
  static ({String valore, List<bool> stanno})? scegliValore({
    required List<String> dirette,
    required List<String>? azioni,
    required List<String> valori,
    required List<String> note,
    required bool chiude,
    CourtesyForm? forma,
    String? preferito,
    Set<String> licenze = const {},
    bool Function(int i)? occupata,
    bool soloSicuri = false,
  }) {
    final n = dirette.length;
    if (azioni != null && azioni.length != n) return null;
    String r(String v) => LaMarcaDelGenere.risolvi(v, forma: forma);
    final ordine = [
      if (preferito != null && valori.contains(preferito)) preferito,
      ...valori.where((v) => v != preferito),
    ];
    // **I LIVELLI DEL SENSO**: prima tutto cio' che la domanda non porta e'
    // escluso (conflitto, paura, persona vicina, tempo lungo); se nel gruppo
    // non resta nessuna coppia, si lascia cadere per primo il meno grave (la
    // paura, che e' un'attesa naturale prima di un esito), poi l'orizzonte
    // breve, poi la persona vicina, poi il conflitto, e in fondo nessun
    // filtro, perche' meglio una coppia che sta nella misura che nessuna.
    // La postura (attendere o agire) e' il primo filtro a cadere: fra schede
    // di una stessa gettata una contraddizione e' un difetto, ma meno di una
    // paura o di un conflitto che la domanda non porta.
    Set<String> senzaPostura(Set<String> s) =>
        {...s}..removeAll(const ['noAzione', 'noAttesa']);
    final base = senzaPostura(licenze);
    // **Le schede (soloSicuri)** non scendono mai sotto i filtri: se nel
    // gruppo non resta una coppia che non contraddice, non presuppone e non
    // porta persone care, la scheda passa alla coppia neutra della pietra. Il
    // principale invece ha sempre la sua risposta.
    final livelli = <Set<String>?>[
      licenze,
      if (soloSicuri) ...[
        {...licenze}..remove('terzi'),
      ] else ...[
        base,
        {...base, 'terzi'},
        {...base, 'terzi', 'paura'},
        {...base, 'terzi', 'paura', 'controparte'},
        {...base, 'terzi', 'paura', 'controparte', 'senzaBreve'},
        {...base, 'terzi', 'paura', 'controparte', 'senzaBreve'}
          ..remove('assenza'),
        {...base, 'terzi', 'paura', 'controparte', 'senzaBreve', 'conflitto'}
          ..remove('assenza'),
        null,
      ],
    ];
    // Che una voce stia nella misura con un valore non cambia da un livello
    // all'altro: si misura una volta sola per valore.
    final misure = <String, List<bool>>{};
    List<bool> inMisura(String v) => misure.putIfAbsent(
        v,
        () => [
              for (var i = 0; i < n; i++)
                riempi(r(dirette[i]), [v], note: note) != null &&
                    (azioni == null ||
                        riempi(r(azioni[i]), [v], comeAzione: true) != null),
            ]);
    for (final lic in livelli) {
      for (final v in ordine) {
        final misura = inMisura(v);
        final stanno = [
          for (var i = 0; i < n; i++)
            (occupata == null || !occupata(i)) &&
                misura[i] &&
                (lic == null ||
                    (regge(dirette[i], v, chiude: chiude, licenze: lic) &&
                        (azioni == null ||
                            regge(azioni[i], v,
                                chiude: chiude, licenze: lic)))),
        ];
        if (stanno.any((x) => x)) return (valore: v, stanno: stanno);
      }
    }
    return null;
  }
}

/// I segni di una voce per [LeRisposteDirette.regge].
class _SegniDiUnaVoce {
  const _SegniDiUnaVoce({
    required this.conflitto,
    required this.paura,
    required this.beni,
    required this.controparte,
    required this.terzi,
    required this.presenza,
    required this.tempoLungo,
    required this.chiudeUnLegame,
    required this.postura,
  });

  final bool conflitto;
  final bool paura;
  final bool beni;
  final bool controparte;
  final bool terzi;
  final bool presenza;
  final bool tempoLungo;
  final bool chiudeUnLegame;
  final String? postura;
}
