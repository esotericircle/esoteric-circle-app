library;

/// IL RITMO DI UNA VOCE, misurato sulle sue risposte vere. Ordine BP voce 3.
///
/// **Un registro scritto non e' un registro ottenuto.** L'ordine BP riscrive i
/// tre registri e chiede a Caligo frasi brevi e ferme, nessuna domanda e
/// nessuna parola che ammorbidisce: tutte e tre le cose si possono chiedere in
/// un prompt e non succedere. Questa classe le CONTA, sulle sessanta risposte
/// che l'attribuzione cieca raccoglie a ogni giro.
///
/// **Non e' una prova che passa o cade, e' uno strumento di misura.** Non
/// esiste una soglia giusta per la lunghezza mediana di una frase, e inventarne
/// una sarebbe un numero indovinato. Serve a vedere se il registro nuovo ha
/// morso davvero, confrontando i nove numeri di un giro con quelli del giro
/// prima.
///
/// **Funzione pura, quindi si prova senza rete**: lo strumento che la usa ha
/// bisogno di gcloud, questa no, e a pretendere che i numeri nascano dal testo
/// e non da valori fissi c'e' una prova nella suite.
class RitmoDellaVoce {
  const RitmoDellaVoce({
    required this.lunghezzaMedianaInParole,
    required this.domande,
    required this.ammorbidenti,
    required this.frasi,
  });

  /// La lunghezza MEDIANA di una frase, in parole. Mediana e non media: una
  /// sola frase lunghissima sposta la media di parecchio e la mediana quasi
  /// niente, e cio' che si vuole sapere e' come suona la frase tipica.
  final double lunghezzaMedianaInParole;

  /// Quante domande contiene, cioe' quante frasi chiudono con un punto
  /// interrogativo.
  final int domande;

  /// Quante parole che ammorbidiscono contiene, dall'elenco dichiarato in
  /// [paroleCheAmmorbidiscono].
  final int ammorbidenti;

  /// Quante frasi sono state contate. Si porta dietro perche' i tre numeri
  /// sopra senza questo non si possono confrontare fra due giri.
  final int frasi;

  /// LE PAROLE CHE AMMORBIDISCONO, elenco dichiarato e non generico.
  ///
  /// Sono le parole con cui una voce toglie peso a cio' che sta dicendo. Il
  /// registro di Caligo le vieta per nome, quindi contarle dice se il divieto
  /// e' arrivato. **Si enumerano invece di descriverle**: "linguaggio incerto"
  /// lo interpreta chi legge, un elenco no.
  static const List<String> paroleCheAmmorbidiscono = [
    'forse',
    'magari',
    'un po\'',
    'probabilmente',
    'potrebbe',
    'potrebbero',
    'sembra',
    'sembrano',
    'quasi',
    'a volte',
    'in qualche modo',
    'più o meno',
    'diciamo',
    'tutto sommato',
    'se vuoi',
    'prova a',
  ];

  /// Il ritmo di un insieme di testi, di solito le venti risposte di un
  /// Maestro dentro un giro di attribuzione cieca.
  static RitmoDellaVoce di(Iterable<String> testi) {
    final lunghezze = <int>[];
    var domande = 0;
    var ammorbidenti = 0;
    for (final testo in testi) {
      for (final frase in _frasiDi(testo)) {
        final parole = _paroleDi(frase);
        if (parole.isEmpty) continue;
        lunghezze.add(parole.length);
        if (frase.trimRight().endsWith('?')) domande++;
      }
      final minuscolo = testo.toLowerCase();
      for (final morbida in paroleCheAmmorbidiscono) {
        ammorbidenti += _quanteVolte(minuscolo, morbida.toLowerCase());
      }
    }
    lunghezze.sort();
    return RitmoDellaVoce(
      lunghezzaMedianaInParole: _mediana(lunghezze),
      domande: domande,
      ammorbidenti: ammorbidenti,
      frasi: lunghezze.length,
    );
  }

  /// Le frasi di un testo. Si taglia sui tre segni di chiusura E sull'a capo,
  /// perche' un elenco puntato non porta il punto e sarebbe contato come una
  /// frase sola lunghissima.
  static List<String> _frasiDi(String testo) {
    final pezzi = <String>[];
    final buffer = StringBuffer();
    for (final carattere in testo.split('')) {
      buffer.write(carattere);
      if (carattere == '.' ||
          carattere == '!' ||
          carattere == '?' ||
          carattere == '\n') {
        pezzi.add(buffer.toString());
        buffer.clear();
      }
    }
    if (buffer.isNotEmpty) pezzi.add(buffer.toString());
    return pezzi;
  }

  /// Le parole di una frase. Si tengono gli apostrofi dentro la parola, cosi'
  /// "un po'" resta due parole invece di tre.
  static List<String> _paroleDi(String frase) => frase
      .split(RegExp(r"[^A-Za-zÀ-ÿ']+"))
      .map((p) => p.replaceAll(RegExp(r"^'+|'+$"), ''))
      .where((p) => p.isNotEmpty)
      .toList();

  /// Quante volte [ago] compare in [pagliaio] come parola intera. Il confine si
  /// controlla a mano invece che con una espressione regolare perche' due voci
  /// dell'elenco contengono uno spazio e una un apostrofo, e una \b davanti a
  /// un apostrofo non si comporta come sembra.
  static int _quanteVolte(String pagliaio, String ago) {
    var quante = 0;
    var da = 0;
    while (true) {
      final trovato = pagliaio.indexOf(ago, da);
      if (trovato < 0) return quante;
      final primaOk = trovato == 0 || !_eLettera(pagliaio[trovato - 1]);
      final dopo = trovato + ago.length;
      final dopoOk = dopo >= pagliaio.length || !_eLettera(pagliaio[dopo]);
      if (primaOk && dopoOk) quante++;
      da = trovato + ago.length;
    }
  }

  static bool _eLettera(String c) => RegExp(r'[A-Za-zÀ-ÿ]').hasMatch(c);

  static double _mediana(List<int> ordinati) {
    if (ordinati.isEmpty) return 0;
    final meta = ordinati.length ~/ 2;
    if (ordinati.length.isOdd) return ordinati[meta].toDouble();
    return (ordinati[meta - 1] + ordinati[meta]) / 2;
  }

  /// Una riga sola, per la stampa accanto alla matrice di confusione.
  String get riga => 'frasi contate $frasi, frase mediana '
      '${lunghezzaMedianaInParole.toStringAsFixed(1)} parole, '
      'domande $domande, parole che ammorbidiscono $ammorbidenti';
}
