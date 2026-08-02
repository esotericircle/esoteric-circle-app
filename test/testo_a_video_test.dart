import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// IL TESTO CHE LA PERSONA LEGGE E' TESTO, non codice e non ripieghi.
///
/// Due difetti segnalati dal fondatore sulla 2111, in una riga sola della scheda
/// della Luna: "Adesso adesso sta a ${alt.toStringAsFixed(0)} gradi sopra il
/// suolo". Il dollaro era escapato, quindi a video si leggeva il codice invece
/// del numero, e la parola era raddoppiata perche' il frammento diceva gia'
/// "adesso" e la frase lo rimetteva davanti.
///
/// La prova che c'era non li prendeva perche' controllava solo che ci fosse una
/// cifra. Queste due cadono su entrambi, e su chiunque li rifaccia altrove.
void main() {
  /// Tutte le stringhe letterali di `lib`, riga per riga, saltando i commenti.
  List<(String file, int riga, String testo)> stringheDiLib() {
    final trovate = <(String, int, String)>[];
    final esp = RegExp(r"'((?:[^'\\]|\\.)*)'");
    for (final f in Directory('lib').listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      final p = f.path.replaceAll(Platform.pathSeparator, '/');
      final righe = f.readAsLinesSync();
      for (var i = 0; i < righe.length; i++) {
        final r = righe[i];
        if (r.trimLeft().startsWith('//')) continue;
        for (final m in esp.allMatches(r)) {
          trovate.add((p, i + 1, m.group(1) ?? ''));
        }
      }
    }
    return trovate;
  }

  test('Nessuna stringa mostra codice invece del suo valore', () {
    // Un dollaro escapato dentro una stringa che contiene anche una chiamata a
    // metodo non e' mai voluto: e' un'interpolazione che non interpola, e a
    // video si legge il sorgente.
    final colpevoli = <String>[];
    for (final (file, riga, testo) in stringheDiLib()) {
      if (testo.contains(r'\$') && testo.contains('(')) {
        colpevoli.add('$file riga $riga: $testo');
      }
    }
    expect(colpevoli, isEmpty,
        reason: 'queste stringhe mostrano il codice invece del valore: '
            '$colpevoli');
  });

  test('Nessuna frase mostrata ripete una parola due volte di fila', () {
    final colpevoli = <String>[];
    final doppia = RegExp(r'\b(\w{3,})\s+\1\b', caseSensitive: false);
    for (final (file, riga, testo) in stringheDiLib()) {
      // Solo frasi, non identificatori: un id come "aura_aura" non e' un difetto
      // di lettura, e le chiavi non le legge nessuno.
      if (!testo.contains(' ')) continue;
      final m = doppia.firstMatch(testo);
      if (m == null) continue;
      // Alcune ripetizioni sono italiano voluto, non sviste: "passo passo" e'
      // una locuzione, e una prova che la denuncia insegna a ignorarla.
      const volute = {'passo passo', 'piano piano', 'appena appena'};
      if (volute.contains(m.group(0)!.toLowerCase())) continue;
      colpevoli.add('$file riga $riga: "${m.group(0)}"');
    }
    expect(colpevoli, isEmpty,
        reason: 'queste frasi ripetono una parola due volte di fila, di solito '
            'perche\' un frammento porta gia\' la parola che la cornice '
            'rimette davanti: $colpevoli');
  });

  test('Nessuna frase mostrata usa l\'apostrofo al posto dell\'accento', () {
    // GLI ACCENTI A SCHERMO, chiusi il 1 agosto 2026 dopo essere rimasti
    // aperti: il fondatore aveva letto "la lettura si fara' piu' precisa" nella
    // Risonanza, e la ricerca di allora dichiaro' dieci punti in sette file.
    // Erano CENTOCINQUANTADUE in diciassette: la prima misura non aveva
    // trovato niente perche' cercava fara' mentre nel sorgente c'e' fara',
    // con la barra dell'escape in mezzo. Una ricerca che torna a zero e' una
    // ricerca da rifare, non una buona notizia.
    //
    // LA DIFFICOLTA' VERA era distinguere le frasi mostrate dai COMMENTI, dove
    // l'apostrofo al posto dell'accento e' la convenzione voluta di questo
    // progetto, e dalle ELISIONI, dove l'apostrofo e' giusto: "l'anno",
    // "un'ora", "po'". Questa prova guarda le sole stringhe con uno spazio
    // dentro, cioe' le frasi, e conosce l'elenco delle elisioni.
    const elisioni = {
      'l', 'un', 'c', 'd', 'dell', 'all', 'nell', 'sull', 'dall', 'quest',
      'sant', 'm', 't', 's', 'v', 'gl', 'gli', 'anch', 'nessun', 'ciascun',
      'buon', 'grand', 'bell', 'tutt', 'qual', 'po', 'di', 'fa', 'va', 'sta',
      'da', 'mo', 'be', 'to', 'n', 'senz', 'sopr', 'contr', 'dentr', 'sott',
      'quell', 'part', 'com', 'or', 'ver', 'tal', 'altr', 'nostr', 'vostr',
      // Le decine elise davanti agli anni e il "qualcos'altro": trovate da
      // questa prova al primo giro, che e' il motivo per cui esiste.
      'vent', 'trent', 'quarant', 'cinquant', 'sessant', 'settant', 'ottant',
      'novant', 'qualcos',
    };
    final parola = RegExp(r"([A-Za-zÀ-ÿ]+)'");
    final colpevoli = <String>[];
    for (final (file, riga, testo) in stringheDiLib()) {
      if (!testo.contains(' ')) continue;
      // Nel sorgente l'apostrofo dentro una stringa a apici singoli porta
      // davanti la barra dell'escape, quindi si normalizza prima di cercare:
      // e' il passo che mancava alla misura di allora, quella che trovo' zero.
      for (final m in parola.allMatches(testo.replaceAll(r"\'", "'"))) {
        final p = m.group(1)!.toLowerCase();
        if (elisioni.contains(p)) continue;
        colpevoli.add('$file riga $riga: "${m.group(0)}"');
      }
    }
    expect(colpevoli, isEmpty,
        reason: 'queste frasi mostrate usano l\'apostrofo al posto '
            'dell\'accento, e la persona lo legge: $colpevoli');
  });

  test('Nessuna frase mostrata perde l\'accento del tutto', () {
    // IL BUCO CHE QUESTA PROVA CHIUDE, trovato il 2 agosto 2026.
    //
    // La prova qui sopra cerca `parola'`, cioe' una parola SEGUITA DA UN
    // APOSTROFO, e prende "piu'", "perche'", "gia'". NON prende "piu" nudo.
    // Nel messaggio del limite c'era scritto "per averne di piu.": nessun
    // apostrofo, solo una parola a cui manca l'accento. Una classe intera di
    // errori passava da sempre, e il fondatore l'ha letta a schermo.
    //
    // Si ENUMERANO le parole che in italiano non esistono senza accento, e si
    // lasciano fuori quelle ambigue, dove la forma senza accento e' una parola
    // vera: "e" contro "è", "si" contro "sì", "la" contro "là", "da" contro
    // "dà", "meta" contro "metà". Colpirle darebbe falsi allarmi, e una prova
    // che grida al lupo si finisce per allentarla.
    const vietate = {
      'piu', 'perche', 'poiche', 'benche', 'finche', 'nonche', 'affinche',
      'gia', 'cosi', 'puo', 'cioe', 'percio',
      'sara', 'fara', 'dara', 'potra', 'verra', 'andra', 'avra',
      'citta', 'liberta', 'verita', 'qualita', 'quantita', 'possibilita',
      'responsabilita', 'identita', 'realta', 'novita', 'universita',
      'virtu', 'gioventu', 'tribu',
      'lunedi', 'martedi', 'mercoledi', 'giovedi', 'venerdi',
    };
    final parole = RegExp(r'[A-Za-zÀ-ÿ]+');
    final colpevoli = <String>[];
    for (final (file, riga, testo) in stringheDiLib()) {
      if (!testo.contains(' ')) continue;
      final pulito = testo.replaceAll(r"\'", "'");
      for (final m in parole.allMatches(pulito)) {
        final p = m.group(0)!.toLowerCase();
        if (!vietate.contains(p)) continue;
        // Se subito dopo c'e' un apostrofo la prende gia' l'altra prova.
        final dopo = m.end < pulito.length ? pulito[m.end] : '';
        if (dopo == "'") continue;
        colpevoli.add('$file riga $riga: "$p" senza accento');
      }
    }
    expect(colpevoli, isEmpty,
        reason: 'queste frasi mostrate hanno perso l\'accento del tutto, e '
            'nessuna prova le prendeva: $colpevoli');
  });
}
