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
    return 'Il mio animale guida e\' $art$sep$nome, cosa vuole dirmi?';
  }

  /// Dal Test Archetipo verso Aura, col nome con l'articolo dell'archetipo.
  static String archetipo(String conArticolo) =>
      'Il mio archetipo e\' $conArticolo, aiutami a capirlo meglio.';

  /// Dalla Costellazione del Viso verso Aura, col tratto dominante vero.
  /// [categoria] e' il nome della categoria del tratto, per l'articolo.
  static String viso(String categoria, String nome) {
    final art = _articoloTratto[categoria] ?? 'il';
    return 'Il mio tratto dominante e\' $art ${nome.toLowerCase()}, cosa racconta di me?';
  }
}
