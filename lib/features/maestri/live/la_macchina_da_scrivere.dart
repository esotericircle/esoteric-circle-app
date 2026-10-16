/// **LA DOMANDA E LA RISPOSTA SI SCRIVONO COME A MACCHINA.** Ordine ER voce
/// 13, 27 settembre 2026.
///
/// Il fondatore: *"Un conto è aspettare Senza fare nulla e un'altro è leggere
/// mentre si compone la domanda fatta e la risposta ricevuta. La voce partirà
/// appena possibile in ogni caso."* Prima la domanda trascritta compariva
/// tutta insieme e la risposta a blocchi, come arrivava dal modello.
///
/// Qui c'e' solo il conto di quante lettere si vedono in un istante, fuori
/// dal widget perche' una prova lo raggiunga:
/// - la domanda si scrive dal momento in cui e' trascritta, a
///   [letterePerSecondoDellaDomanda];
/// - la risposta comincia quando la domanda e' scritta per intero e va a
///   [letterePerSecondoDellaRisposta], ma non oltre cio' che e' arrivato;
/// - **mai indietro rispetto alla voce**: la risposta si scrive a
///   [letterePerSecondoDellaRisposta], piu' del doppio di quante lettere una
///   voce italiana dica in un secondo ([letterePerSecondoDellaVoce]); e se il
///   Maestro comincia a parlare mentre la domanda si sta ancora scrivendo, la
///   domanda si completa subito e la risposta parte con la voce. La voce non
///   aspetta la scrittura e la scrittura non aspetta la voce.
class LaMacchinaDaScrivere {
  /// Abbastanza svelta da non far aspettare, abbastanza lenta da vedersi.
  static const double letterePerSecondoDellaDomanda = 60;
  static const double letterePerSecondoDellaRisposta = 40;

  /// Una voce italiana dice fra 12 e 16 caratteri al secondo: la risposta
  /// scritta deve andare piu' svelta, cosi' la parola detta e' gia' scritta.
  static const double letterePerSecondoDellaVoce = 16;

  String _domanda = '';
  String _risposta = '';
  DateTime? _daQuando;
  DateTime? _voce;

  /// Una domanda nuova: si comincia a scriverla adesso.
  void nuovaDomanda(String domanda, DateTime ora) {
    _domanda = domanda;
    _risposta = '';
    _daQuando = ora;
    _voce = null;
    _gia = 0;
    _giaAl = ora;
  }

  /// La risposta arrivata finora, gia' ridotta a cio' che si dice.
  ///
  /// Se la risposta nuova non comincia con cio' che si e' gia' scritto (le
  /// reti del controller l'hanno cambiata), la scrittura riparte dal pezzo
  /// comune: niente di cio' che resta a video e' una parola che il Maestro
  /// non dira'.
  void risposta(String risposta, DateTime ora) {
    final scritte = _scritteDellaRisposta(ora);
    var comune = 0;
    while (comune < scritte &&
        comune < risposta.length &&
        comune < _risposta.length &&
        risposta.codeUnitAt(comune) == _risposta.codeUnitAt(comune)) {
      comune++;
    }
    _gia = comune;
    _giaAl = ora;
    _risposta = risposta;
  }

  /// Il Maestro comincia a parlare adesso.
  void voceIniziata(DateTime ora) => _voce ??= ora;

  // Quante lettere della risposta erano gia' scritte a [_giaAl]: la
  // scrittura riprende da li' quando la risposta cambia.
  int _gia = 0;
  DateTime? _giaAl;

  double _secondi(DateTime? da, DateTime a) =>
      da == null ? 0 : a.difference(da).inMicroseconds / 1e6;

  /// Le lettere della domanda che si vedono a [ora].
  int scritteDellaDomanda(DateTime ora) {
    final fine = _fineDellaDomanda;
    if (fine != null && !ora.isBefore(fine)) return _domanda.length;
    final n =
        (_secondi(_daQuando, ora) * letterePerSecondoDellaDomanda).floor();
    return n.clamp(0, _domanda.length);
  }

  /// L'istante in cui la domanda e' scritta per intero: alla sua velocita',
  /// oppure subito, se il Maestro comincia a parlare prima. La risposta non
  /// aspetta una domanda lunga.
  DateTime? get _fineDellaDomanda {
    final daSola = _daQuando?.add(Duration(
        microseconds:
            (_domanda.length / letterePerSecondoDellaDomanda * 1e6).round()));
    final voce = _voce;
    if (daSola == null || voce == null) return daSola;
    return voce.isBefore(daSola) ? voce : daSola;
  }

  int _scritteDellaRisposta(DateTime ora) {
    final inizio = _fineDellaDomanda;
    if (inizio == null || ora.isBefore(inizio)) return 0;
    final daQui = _giaAl == null || _giaAl!.isBefore(inizio) ? inizio : _giaAl!;
    final n =
        _gia + (_secondi(daQui, ora) * letterePerSecondoDellaRisposta).floor();
    return n.clamp(0, _risposta.length);
  }

  /// Le lettere della risposta che si vedono a [ora].
  int scritteDellaRisposta(DateTime ora) => _scritteDellaRisposta(ora);

  /// La domanda e la risposta come si vedono a [ora].
  ({String domanda, String risposta}) aVideo(DateTime ora) => (
        domanda: _domanda.substring(0, scritteDellaDomanda(ora)),
        risposta: _risposta.substring(0, scritteDellaRisposta(ora)),
      );

  /// Vero finche' la domanda non e' scritta per intero.
  bool staScrivendoLaDomanda(DateTime ora) =>
      scritteDellaDomanda(ora) < _domanda.length;

  /// Vero finche' c'e' ancora qualcosa da scrivere di cio' che e' arrivato.
  bool staScrivendo(DateTime ora) =>
      scritteDellaDomanda(ora) < _domanda.length ||
      scritteDellaRisposta(ora) < _risposta.length;
}
