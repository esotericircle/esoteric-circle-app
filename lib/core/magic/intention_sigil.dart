import 'dart:math' as math;

import 'dart:ui' show Offset;

/// Il Sigillo dell'Intenzione: da una frase scritta a un glifo unico.
///
/// Il metodo e' reale e va dichiarato a chi lo usa.
///
/// 1. **Le lettere uniche.** Dalla frase si tolgono le lettere ripetute e
///    restano le lettere distinte, nell'ordine in cui compaiono. E' il metodo
///    che Austin Osman Spare descrive nel primo Novecento in "The Book of
///    Pleasure": la frase perde la propria leggibilita' e diventa forma.
/// 2. **Il cammino sulla ruota.** Quelle lettere si cercano sulla Rosa dei
///    Petali della Golden Dawn, la ruota su cui le lettere stanno disposte in
///    cerchio, e si uniscono in ordine con un tratto continuo. Il percorso che
///    ne esce e' il sigillo.
/// 3. **Deterministico.** Nessun numero casuale in tutto il file: la stessa
///    frase da' lo stesso sigillo per sempre, su qualunque dispositivo.
///
/// La nostra parte, dichiarata come tale, e' la resa grafica e i testi. Il
/// metodo e' della tradizione, e a Spare non si attribuisce cio' che non ha
/// scritto.
class IntentionSigil {
  const IntentionSigil._();

  /// La Rosa dei Petali nella forma che usiamo: ventidue posizioni in cerchio,
  /// una per lettera dell'alfabeto italiano esteso alle straniere.
  ///
  /// La rosa storica della Golden Dawn e' costruita sull'alfabeto ebraico, in
  /// tre cerchi concentrici da tre, sette e dodici petali. Qui la si adatta
  /// alle lettere latine mantenendo l'idea che conta, cioe' lettere disposte in
  /// cerchio e unite da un tratto: e' un adattamento nostro, e lo diciamo
  /// invece di spacciarlo per la rosa originale.
  static const String alfabeto = 'ABCDEFGHILMNOPQRSTUVZ';

  /// Quante lettere stanno sulla ruota.
  static int get petali => alfabeto.length;

  /// Dove sta una lettera sulla ruota, in coordinate normalizzate attorno al
  /// centro (0,5 , 0,5). L'angolo parte dall'alto e gira in senso orario.
  static Offset posizioneDi(String lettera) {
    final i = alfabeto.indexOf(lettera.toUpperCase());
    if (i < 0) return const Offset(0.5, 0.5);
    final a = -math.pi / 2 + i * 2 * math.pi / petali;
    // Raggio 0,38: lascia il margine per i pallini e per il nome sotto.
    return Offset(0.5 + math.cos(a) * 0.38, 0.5 + math.sin(a) * 0.38);
  }

  /// Le lettere uniche di una frase, nell'ordine di prima comparsa.
  ///
  /// Si tengono solo le lettere: spazi, cifre e punteggiatura non stanno sulla
  /// ruota. Gli accenti si riducono alla lettera base, perche' la ruota ha una
  /// sola E e chi scrive "perché" intende quella.
  static List<String> lettereUniche(String frase) {
    const accenti = {
      'À': 'A', 'Á': 'A', 'Â': 'A', 'Ä': 'A',
      'È': 'E', 'É': 'E', 'Ê': 'E', 'Ë': 'E',
      'Ì': 'I', 'Í': 'I', 'Î': 'I', 'Ï': 'I',
      'Ò': 'O', 'Ó': 'O', 'Ô': 'O', 'Ö': 'O',
      'Ù': 'U', 'Ú': 'U', 'Û': 'U', 'Ü': 'U',
      'J': 'I', 'K': 'C', 'W': 'V', 'X': 'S', 'Y': 'I',
    };
    final viste = <String>{};
    final out = <String>[];
    for (final ch in frase.toUpperCase().split('')) {
      final c = accenti[ch] ?? ch;
      if (!alfabeto.contains(c)) continue;
      if (viste.add(c)) out.add(c);
    }
    return out;
  }

  /// Il cammino del sigillo: i punti da unire, in ordine.
  ///
  /// Con meno di due lettere non c'e' un cammino, quindi si restituisce una
  /// lista vuota e la schermata chiede una frase piu' lunga invece di
  /// disegnare un punto solo.
  static List<Offset> cammino(String frase) {
    final lettere = lettereUniche(frase);
    if (lettere.length < 2) return const [];
    return [for (final l in lettere) posizioneDi(l)];
  }

  /// Quanto sono simili due sigilli, da 0 (nulla in comune) a 1 (identici).
  ///
  /// Serve a dire che frasi vicine danno sigilli vicini: si confrontano gli
  /// insiemi di lettere, che sono cio' da cui il disegno nasce.
  static double somiglianza(String a, String b) {
    final sa = lettereUniche(a).toSet();
    final sb = lettereUniche(b).toSet();
    if (sa.isEmpty && sb.isEmpty) return 1;
    final comuni = sa.intersection(sb).length;
    final tutte = sa.union(sb).length;
    return tutte == 0 ? 0 : comuni / tutte;
  }
}

/// Le tre vie in cui un'intenzione si riconosce.
///
/// I nomi sono PROVVISORI e vivono qui, in un punto solo: dipendono dal
/// confronto di Mauro con Gaetano Daguraz, il praticante reale, quindi
/// cambiarli domani costa una riga e non una caccia nel codice.
enum ViaMagica {
  rossa('Via Rossa', 'il cuore e il desiderio'),
  bianca('Via Bianca', 'protezione e chiarezza'),
  verde('Via Verde', 'erbe e natura');

  const ViaMagica(this.nome, this.dominio);

  /// Il nome mostrato a schermo.
  final String nome;

  /// Di cosa si occupa, in tre parole.
  final String dominio;
}

/// A quale via appartiene un'intenzione, e perche'.
class LetturaIntenzione {
  const LetturaIntenzione({
    required this.via,
    required this.parolaChiave,
    required this.riconosciuta,
    required this.riformulata,
    this.originale,
  });

  final ViaMagica via;

  /// La parola della frase che ha deciso la via. Vuota se nessuna.
  final String parolaChiave;

  /// Falso quando nessuna parola e' stata riconosciuta: la schermata lo dice,
  /// invece di far finta di aver capito.
  final bool riconosciuta;

  /// Il testo dell'intenzione come va usato: di solito quello scritto, ma
  /// riformulato se chiedeva di agire sulla volonta' di qualcun altro.
  final String riformulata;

  /// Il testo originale, presente solo quando e' stato riformulato.
  final String? originale;

  bool get eStataRiformulata => originale != null;
}

/// Legge un'intenzione: la via, e il filtro su cio' che non si puo' chiedere.
///
/// Il filtro sta QUI, dove il testo nasce, non nella schermata: cosi' vale per
/// chiunque usi questo motore, oggi e domani.
class LettoreIntenzione {
  const LettoreIntenzione._();

  /// Le parole che portano alla Via Rossa: il cuore, il desiderio, il coraggio
  /// di esporsi. Sempre riferite a chi scrive, mai a un terzo.
  static const List<String> _rosse = [
    'amore', 'amare', 'amata', 'amato', 'cuore', 'passione', 'desiderio',
    'desidero', 'coraggio', 'audacia', 'fuoco', 'slancio', 'incontro',
    'legame', 'affetto', 'attrazione', 'vitalità', 'ardore',
  ];

  /// Le parole della Via Bianca: protezione, chiarezza, quiete, confini.
  static const List<String> _bianche = [
    'protezione', 'proteggere', 'protetto', 'protetta', 'chiarezza',
    'chiaro', 'chiara', 'pace', 'quiete', 'calma', 'lucidità',
    'confine', 'confini', 'difesa', 'serenità', 'silenzio',
    'purezza', 'discernimento', 'verità',
  ];

  /// Le parole della Via Verde: erbe, natura, radici, crescita, corpo inteso
  /// come radicamento. Nessuna promessa di guarigione, mai.
  static const List<String> _verdi = [
    'terra', 'natura', 'radice', 'radici', 'radicamento', 'erba', 'erbe',
    'pianta', 'piante', 'albero', 'bosco', 'crescita', 'crescere', 'seme',
    'semi', 'fiorire', 'raccolto', 'stagione', 'abbondanza', 'nutrire',
  ];

  /// Le parole che indicano una richiesta sulla volonta' di un altro. Queste
  /// non si rifiutano: si riformulano, perche' dietro c'e' quasi sempre un
  /// bisogno legittimo detto male.
  static const List<String> _suTerzi = [
    'faccia', 'facciano', 'mi ami', 'si innamori', 'innamorare', 'torni da me',
    'lasci', 'obbedisca', 'costringere', 'costringi', 'legare a me',
    'sottometti', 'convincilo', 'convincila', 'far si che lui',
    'far si che lei', 'fammi avere lui', 'fammi avere lei',
  ];

  /// Legge la frase e restituisce via, motivo e testo da usare.
  static LetturaIntenzione leggi(String frase) {
    final pulita = frase.trim();
    // Gli accenti si tolgono PRIMA del confronto: chi scrive "verita" senza
    // accento intende la stessa parola di chi lo mette, e tenere due forme
    // in elenco vorrebbe dire scrivere in elenco una parola sbagliata.
    final bassa = _senzaAccenti(pulita.toLowerCase());

    // Prima il filtro: una richiesta sulla volonta' di un altro diventa un
    // rito su di se'. Il Briefing di Progetto le esclude, e rifiutarle secche
    // lascerebbe la persona con un no e niente altro.
    for (final segnale in _suTerzi) {
      if (bassa.contains(segnale)) {
        return LetturaIntenzione(
          via: ViaMagica.rossa,
          parolaChiave: segnale,
          riconosciuta: true,
          originale: pulita,
          riformulata: 'Apro il mio cuore e mi rendo degno di un legame vero',
        );
      }
    }

    for (final entry in <ViaMagica, List<String>>{
      ViaMagica.rossa: _rosse,
      ViaMagica.verde: _verdi,
      ViaMagica.bianca: _bianche,
    }.entries) {
      for (final parola in entry.value) {
        if (_contieneParola(bassa, _senzaAccenti(parola))) {
          return LetturaIntenzione(
            via: entry.key,
            parolaChiave: parola,
            riconosciuta: true,
            riformulata: pulita,
          );
        }
      }
    }

    // Nessuna parola riconosciuta: si dichiara e si usa la Bianca, che e' la
    // via della chiarezza, quindi quella giusta quando non si e' capito.
    return LetturaIntenzione(
      via: ViaMagica.bianca,
      parolaChiave: '',
      riconosciuta: false,
      riformulata: pulita,
    );
  }

  /// Le vocali accentate ridotte alla loro base, per il confronto.
  static String _senzaAccenti(String t) {
    const m = {
      'à': 'a', 'á': 'a', 'è': 'e', 'é': 'e', 'ì': 'i', 'í': 'i',
      'ò': 'o', 'ó': 'o', 'ù': 'u', 'ú': 'u',
    };
    final b = StringBuffer();
    for (final ch in t.split('')) {
      b.write(m[ch] ?? ch);
    }
    return b.toString();
  }

  /// Parola intera, non frammento: "pace" non deve accendersi dentro
  /// "capace", che vuol dire tutt'altro.
  static bool _contieneParola(String testo, String parola) {
    if (parola.contains(' ')) return testo.contains(parola);
    final i = testo.indexOf(parola);
    if (i < 0) return false;
    final primaOk = i == 0 || !_eLettera(testo[i - 1]);
    final dopo = i + parola.length;
    final dopoOk = dopo >= testo.length || !_eLettera(testo[dopo]);
    return primaOk && dopoOk;
  }

  static bool _eLettera(String c) {
    final u = c.toUpperCase();
    return u.length == 1 &&
        (IntentionSigil.alfabeto.contains(u) || 'JKWXY'.contains(u));
  }
}
