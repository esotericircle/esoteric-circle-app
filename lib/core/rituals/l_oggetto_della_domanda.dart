import 'la_risposta_della_gettata.dart';

/// **L'OGGETTO DELLA DOMANDA, CON LE PAROLE DI CHI CHIEDE.** Ordine GA voce
/// GA.06, la cura delle Rune di Caligo, 21 ottobre 2026.
///
/// Il lettore cieco dell'ordine GA, dopo la prima cura: *"la persona della
/// domanda (il capo, il figlio, la sorella, la famiglia di lui, il marito)
/// sparisce dietro un ambito generico ("per il lavoro", "per la tua
/// famiglia")"*. Le risposte dirette del corpus (`diretta.md`, `azione.md`)
/// hanno uno spazio, `per {cosa}`: qui si legge dalla domanda il sintagma che
/// lo riempie, con le persone girate a "tu" ("il conflitto con il tuo capo",
/// "tuo figlio", "l’esame di stato a dicembre", "il legame con Marco"), da
/// una a sei parole. Quando la domanda non lo lascia leggere bene, si torna
/// al tema (`IlPresagioDalCorpus.cosaDellaDomanda`): un oggetto sbagliato e'
/// peggio di un tema giusto.
abstract final class LOggettoDellaDomanda {
  /// Il massimo delle parole di uno spazio: i testi del corpus sono scritti
  /// fra 39 e 44 parole fuori dallo spazio, quindi lo spazio sta fra una e
  /// sei perche' il paragrafo resti fra 40 e 50.
  static const int massimo = 6;

  static const Map<String, String> _persone = {
    'mio': 'tuo', 'mia': 'tua', 'miei': 'tuoi', 'mie': 'tue', //
    'me': 'te', 'mi': 'ti', 'io': 'tu', 'sono': 'sei', 'ho': 'hai',
    'faccio': 'fai', 'posso': 'puoi', 'devo': 'devi', 'voglio': 'vuoi',
  };

  static const Map<String, String> _articolate = {
    'del': 'il', 'dello': 'lo', 'della': 'la', 'dei': 'i', 'degli': 'gli',
    'delle': 'le', 'al': 'il', 'allo': 'lo', 'alla': 'la', 'ai': 'i', //
    'agli': 'gli', 'alle': 'le', 'dal': 'il', 'dalla': 'la', 'dai': 'i',
    'col': 'il', 'nel': 'il', 'nella': 'la',
  };

  static const Set<String> _determinanti = {
    'il', 'lo', 'la', 'i', 'gli', 'le', 'un', 'una', 'uno', 'questo', //
    'questa', 'questi', 'queste', 'quel', 'quella', 'tuo', 'tua', 'tuoi',
    'tue',
  };

  /// Le parole che chiudono l'oggetto della domanda: da qui comincia un'altra
  /// cosa (una congiunzione, un tempo). Un'espressione sola e non un elenco di
  /// parole fra apostrofi: non sono testo mostrato.
  static final RegExp _confine = RegExp(
      r'^(o|oppure|nonostante|dopo|entro|come|quando|perché|se|ancora|davvero|presto|adesso|ora|oggi)$');

  static final RegExp _verbo = RegExp(
      r"^([a-zà-ÿ]+(rò|rà|remo|ranno)|può|possono|è|sono|sei|sta|stanno|va|"
      r'vanno|ha|hanno|finisce|arriva|torna|durerà|serve)$');

  /// Le parole della domanda, con le persone girate e gli apostrofi divisi
  /// ("l'esame" diventa "l’" + "esame" per contare come chi legge).
  static List<String> _parole(String domanda) {
    final t = domanda
        .trim()
        .replaceAll('’', "'")
        .replaceAll(RegExp(r'[?!.…]+$'), '')
        .replaceAll(RegExp(r'\s+'), ' ');
    final fuori = <String>[];
    final crude = t.split(' ');
    for (var i = 0; i < crude.length; i++) {
      var p = crude[i];
      final basso = p.toLowerCase();
      final girata = _persone[basso];
      if (girata != null) {
        p = girata;
      } else if (i > 0 &&
          crude[i - 1].toLowerCase() == 'che' &&
          RegExp(r'^(aspett|sent|cerc|vogli|desider|amo$|temo$|pens)')
              .hasMatch(basso) &&
          basso.endsWith('o')) {
        // "la risposta che aspetto" diventa "che aspetti".
        p = '${p.substring(0, p.length - 1)}i';
      }
      fuori.add(p);
    }
    return fuori;
  }

  static bool _maiuscola(String p) =>
      p.isNotEmpty && p[0] != p[0].toLowerCase() && p[0] == p[0].toUpperCase();

  static String _testo(List<String> parole) =>
      parole.join(' ').replaceAll("'", '’').replaceAll('’ ', '’');

  static int _conta(String t) => t.split(RegExp(r'\s+')).length;

  /// Il sintagma che parte dalla parola [da] (un determinante, un
  /// possessivo, una preposizione articolata) e si ferma davanti a un verbo,
  /// a una virgola, a "o", "nonostante", "dopo", "entro" o alla fine.
  static List<String>? _sintagma(List<String> p, int da) {
    if (da >= p.length) return null;
    var primo = p[da].toLowerCase().replaceAll(',', '');
    final apostrofo = primo.contains("'");
    final testa =
        apostrofo ? primo.substring(0, primo.indexOf("'") + 1) : primo;
    String? articolo;
    if (_articolate.containsKey(testa)) {
      articolo = _articolate[testa];
    } else if (testa == "dell'" ||
        testa == "all'" ||
        testa == "dall'" ||
        testa == "nell'") {
      articolo = "l'";
    }
    final fuori = <String>[];
    if (articolo != null) {
      if (apostrofo) {
        fuori.add("l'${p[da].substring(p[da].indexOf("'") + 1)}");
      } else {
        fuori.add(articolo);
      }
    } else if (_determinanti.contains(testa) ||
        testa == "l'" ||
        primo.startsWith("l'") ||
        primo.startsWith("un'") ||
        primo.startsWith("quest'")) {
      fuori.add(p[da]);
    } else {
      return null;
    }
    for (var i = da + 1; i < p.length; i++) {
      final w = p[i];
      final basso = w.toLowerCase().replaceAll(',', '');
      if (_verbo.hasMatch(basso) || _confine.hasMatch(basso)) {
        break;
      }
      fuori.add(w.replaceAll(',', ''));
      if (w.endsWith(',')) break;
    }
    return fuori;
  }

  /// Le forme di un sintagma, dalla piu' fedele alla piu' corta: intero (fino
  /// a [tetto] parole), poi accorciato solo dove resta vero ("il pranzo di
  /// Natale con la famiglia di lui" diventa "il pranzo con la famiglia di
  /// lui": la testa e cio' che viene dopo "con"). Il compositore prende la
  /// prima che fa stare il paragrafo fra 40 e 50 parole.
  static const int tetto = 9;

  static List<String> _misura(List<String>? s) {
    if (s == null || s.isEmpty) return const [];
    final fuori = <String>[];
    var t = _testo(s);
    if (t.isNotEmpty &&
        t[0] != t[0].toLowerCase() &&
        !_maiuscola(s.length > 1 ? s[1] : '')) {
      t = '${t[0].toLowerCase()}${t.substring(1)}';
    }
    if (_conta(t) <= tetto) fuori.add(t);
    final con = s.indexOf('con');
    if (con > 1) {
      var c = _testo([...s.take(2), ...s.sublist(con)]);
      c = '${c[0].toLowerCase()}${c.substring(1)}';
      if (_conta(c) <= tetto && !fuori.contains(c)) fuori.add(c);
      // La testa sola, quando dice ancora la cosa ("il pranzo di Natale"),
      // prima del tema: il tema generalizza ("la tua famiglia" per "la
      // famiglia di lui") e fa sparire la persona della domanda, che e'
      // proprio il difetto letto dal lettore cieco indipendente.
      if (con >= 3) {
        var h = _testo(s.take(con).toList());
        h = '${h[0].toLowerCase()}${h.substring(1)}';
        if (!fuori.contains(h)) fuori.add(h);
      }
    }
    return fuori;
  }

  /// **L'OGGETTO PER TIPO DI DOMANDA.** Null quando non si legge bene: allora
  /// lo spazio prende il tema.
  static List<String> di(String domanda, TipoDiDomanda tipo,
      {List<String>? strade}) {
    final p = _parole(domanda);
    final basso = [for (final w in p) w.toLowerCase()];
    switch (tipo) {
      case TipoDiDomanda.come:
        // "Mio figlio sta attraversando un periodo difficile, come lo
        // aiuto?": la persona sta prima di ", come".
        final virgola = basso.indexWhere((w) => w.endsWith(','));
        final come = basso.indexOf('come');
        if (virgola >= 0 && come == virgola + 1 && virgola >= 1) {
          if (const {'tuo', 'tua', 'tuoi', 'tue'}.contains(basso[0])) {
            return [_testo(p.take(2).toList()).toLowerCase()];
          }
          return _misura(_sintagma(p, 0));
        }
        if (come < 0) return const [];
        // Dopo "come": il verbo, e un servile con l'infinito ("posso
        // ritrovare", "faccio a"), poi l'oggetto.
        var i = come + 1;
        if (i < p.length) i++;
        if (i < p.length &&
            (basso[i] == 'a' || RegExp(r'(are|ere|ire)$').hasMatch(basso[i]))) {
          i++;
          if (i < p.length && RegExp(r'(are|ere|ire)$').hasMatch(basso[i])) {
            i++;
          }
        }
        final s = _sintagma(p, i);
        if (s != null) return _misura(s);
        // "fare pace con tua sorella": il nome senza articolo prende il suo.
        if (i < p.length && basso[i] == 'pace') {
          return _misura(['la', ...p.sublist(i)]);
        }
        return const [];
      case TipoDiDomanda.previsione:
        if (_sintagma(p, 0) != null) return _misura(_sintagma(p, 0));
        var i = basso.indexWhere((w) => _verbo.hasMatch(w));
        if (i < 0) return const [];
        i++;
        while (i < p.length &&
            const {'presto', 'davvero', 'ancora', 'mai', 'a', 'bene'}
                .contains(basso[i])) {
          i++;
          if (i < p.length && RegExp(r'(are|ere|ire)$').hasMatch(basso[i])) {
            i++;
          }
        }
        return _misura(_sintagma(p, i));
      case TipoDiDomanda.quando:
        final i = basso.indexWhere((w) => _verbo.hasMatch(w));
        if (i < 0) return const [];
        return _misura(_sintagma(p, i + 1));
      case TipoDiDomanda.altrui:
        for (var i = 1; i < p.length; i++) {
          final w = p[i].replaceAll(',', '');
          if (_maiuscola(w) && !const {'Natale', 'Pasqua'}.contains(w)) {
            return ['il legame con $w'];
          }
        }
        for (var i = 0; i < p.length; i++) {
          if (const {'tuo', 'tua'}.contains(basso[i]) ||
              (i + 1 < p.length &&
                  const {'tuo', 'tua'}.contains(basso[i + 1]))) {
            final s = _sintagma(p, i);
            if (s != null && s.length <= 3) {
              return _misura(['il', 'legame', 'con', ...s]);
            }
          }
        }
        if (basso.contains('lui')) return const ['il legame con lui'];
        if (basso.contains('lei')) return const ['il legame con lei'];
        return const [];
      case TipoDiDomanda.scelta:
        final s = strade;
        if (s != null) {
          final a = s[0].split(' ').where(_maiuscola).toList();
          final b = s[1].split(' ').where(_maiuscola).toList();
          if (a.length == 1 && b.length == 1) {
            return ['la scelta fra ${a.first} e ${b.first}'];
          }
          // "Lascio il mio ragazzo o ci riprovo?": la persona della prima
          // strada.
          final i = basso.indexWhere((w) => w == 'tuo' || w == 'tua');
          if (i > 0) {
            final t = _sintagma(p, i - 1) ?? _sintagma(p, i);
            if (t != null && t.length <= 3) {
              return _misura(['il', 'legame', 'con', ...t]);
            }
          }
        }
        final fra = basso.indexWhere((w) => w == 'fra' || w == 'tra');
        if (fra >= 0) return _misura(_sintagma(p, fra + 1));
        return const [];
      default:
        return const [];
    }
  }

  /// Le forme dello spazio `{azione}`, dalla piu' fedele: l'infinito della
  /// domanda intero (fino a [tetto] parole), la sua parte principale prima
  /// di "per" o della virgola ("lasciare il lavoro per tornare a studiare"
  /// diventa "lasciare il lavoro"), e in fondo "prendere questa decisione".
  static List<String> azioni(String? azione) {
    const riserva = 'prendere questa decisione';
    if (azione == null || azione.trim().isEmpty) return const [riserva];
    final a = azione.trim().replaceAll("'", '’');
    final fuori = <String>[];
    if (_conta(a) <= tetto) fuori.add(a);
    final m = RegExp(r'^(.+?)(\s+per\s+|,\s+|\s+perché\s+)').firstMatch(a);
    if (m != null && _conta(m[1]!) >= 2) fuori.add(m[1]!);
    fuori.add(riserva);
    return fuori;
  }
}
