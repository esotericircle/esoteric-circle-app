/// Le prime domande contestuali con cui si apre la chat di un Maestro quando si
/// arriva da un pulsante "Parlane con il Maestro" dal responso di un'arte.
///
/// Regola trasversale: la chat si apre gia' con una domanda scritta e inviata
/// dall'utente sulla fonte da cui arriva, cosi' il Maestro risponde subito su
/// quel tema. Il testo si adatta alla sorgente e al suo risultato. Deterministico,
/// nessuna AI: qui si compone solo la stringa.
class ChatOpeners {
  const ChatOpeners._();

  /// Articolo dell'animale, per una frase che suona bene.
  static const Map<String, String> _articoloAnimale = {
    'Falco': 'il',
    'Orso': 'l\'',
    'Volpe': 'la',
    'Lupo': 'il',
    'Aquila': 'l\'',
    'Gufo': 'il',
    'Cervo': 'il',
    'Serpente': 'il',
    'Cavallo': 'il',
    'Tartaruga': 'la',
    'Corvo': 'il',
    'Lince': 'la',
  };

  /// Articolo del tratto del volto, dalla categoria, per l'accordo.
  static const Map<String, String> _articoloTratto = {
    'formaVolto': 'il',
    'fronte': 'la',
    'sopracciglia': 'le',
    'distanzaOcchi': 'gli',
    'grandezzaOcchi': 'gli',
    'naso': 'il',
    'labbra': 'le',
    'bocca': 'la',
    'mento': 'il',
    'mascella': 'la',
    'zigomi': 'gli',
  };

  /// Dall'Animale Guida verso Caligo, col nome vero dell'animale.
  static String animale(String nome) {
    final art = _articoloAnimale[nome] ?? 'il';
    final sep = art.endsWith('\'') ? '' : ' ';
    return 'Il mio animale guida è $art$sep$nome, cosa vuole dirmi?';
  }

  /// Dalla Runa del Tramonto verso Caligo, con la runa della sera e il suo verso.
  static String runaTramonto(String nome, String verso) =>
      'La mia runa del tramonto è $nome $verso. Cosa devo lasciare fuori '
      'stanotte?';

  /// Dall'Estrazione Rune verso Caligo, con la gettata e le rune uscite.
  static String runa(String gettata, List<String> rune) {
    final elenco = _elenco(rune);
    return 'Ho consultato le rune con $gettata: $elenco. Cosa vogliono dirmi?';
  }

  /// Elenco naturale dei nomi: "a", "a e b", "a, b e c", senza virgola prima
  /// della congiunzione, per la regola di lingua.
  static String _elenco(List<String> nomi) {
    if (nomi.isEmpty) return 'le rune';
    if (nomi.length == 1) return nomi.first;
    final testa = nomi.sublist(0, nomi.length - 1).join(', ');
    return '$testa e ${nomi.last}';
  }

  /// Dal Test Archetipo verso Aura, col nome con l'articolo dell'archetipo.
  static String archetipo(String conArticolo) =>
      'Il mio archetipo è $conArticolo, aiutami a capirlo meglio.';

  /// Dalla Costellazione del Viso verso Aura, col tratto dominante vero.
  /// [categoria] e' il nome della categoria del tratto, per l'articolo.
  static String viso(String categoria, String nome) {
    final art = _articoloTratto[categoria] ?? 'il';
    return 'Il mio tratto dominante è $art ${nome.toLowerCase()}, cosa racconta di me?';
  }
}
