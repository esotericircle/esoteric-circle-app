import 'dart:async';

import 'il_parlato_del_maestro.dart';

/// **LA VOCE DELLA PRIMA FRASE, COMPOSTA MENTRE IL MODELLO SCRIVE ANCORA.**
/// Ordine EQ voce 03, dopo la risposta del fondatore del 27 settembre 2026:
/// *"L'attesa deve diminuire, non aumentare."*
///
/// Sul Realme, dalla fine della risposta del modello al primo audio mandato
/// al volto passavano circa 0,7 secondi, ogni volta: la voce della prima
/// frase si chiedeva al server solo a risposta intera. Ma la prima frase e'
/// scritta molto prima della fine, e il testo arriva a flusso: qui la sua
/// voce si comincia a comporre appena la frase e' chiusa, e si tiene da
/// parte.
///
/// **La voce parte ancora solo dalla risposta intera, con le sue reti**, come
/// ha deciso il fondatore con l'ordine EM: se la risposta passata dalle reti
/// comincia con un'altra frase, la voce anticipata si butta e si chiede
/// quella giusta. Nessuna parola non controllata arriva al volto.
class LaVoceAnticipata<T> {
  LaVoceAnticipata(this.testo, Stream<T> sorgente) {
    _abbonamento = sorgente.listen(
      (pezzo) {
        _pezzi.add(pezzo);
        if (!_primo.isCompleted) _primo.complete(pezzo);
        _sveglia();
      },
      onError: (Object errore) {
        _errore = errore;
        _finita = true;
        if (!_primo.isCompleted) _primo.complete(null);
        _sveglia();
      },
      onDone: () {
        _finita = true;
        if (!_primo.isCompleted) _primo.complete(null);
        _sveglia();
      },
      cancelOnError: true,
    );
  }

  /// La frase di cui questa e' la voce.
  final String testo;

  late final StreamSubscription<T> _abbonamento;
  final _pezzi = <T>[];
  final _primo = Completer<T?>();

  /// Il primo pezzo di voce, quando arriva; nullo se la voce non nasce. Serve
  /// ad aprire in anticipo il flusso verso il volto, che vuole il tasso.
  Future<T?> get primoPezzo => _primo.future;
  bool _finita = false;
  Object? _errore;
  Completer<void>? _attesa;

  void _sveglia() {
    final a = _attesa;
    _attesa = null;
    if (a != null && !a.isCompleted) a.complete();
  }

  /// Vero se la composizione e' fallita prima di dare un solo pezzo: allora
  /// la voce si chiede di nuovo, come se l'anticipo non ci fosse stato.
  bool get fallitaSenzaVoce => _errore != null && _pezzi.isEmpty;

  /// **LA PRIMA FRASE CHIUSA DI UN TESTO CHE ARRIVA A FLUSSO**, come si dira'
  /// a voce; nulla finche' dopo la prima frase non e' cominciata la seconda,
  /// perche' solo allora si sa che la prima e' finita.
  static String? primaFraseChiusa(String scrittoFinora) {
    final pezzi =
        IlParlatoDelMaestro.pezzi(scrittoFinora, primaFraseSola: true);
    return pezzi.length >= 2 ? pezzi.first : null;
  }

  /// La voce dall'inizio: prima i pezzi gia' arrivati, poi quelli che
  /// arrivano.
  Stream<T> riascolta() async* {
    var i = 0;
    while (true) {
      while (i < _pezzi.length) {
        yield _pezzi[i++];
      }
      if (_finita) {
        final e = _errore;
        if (e != null) throw e;
        return;
      }
      await (_attesa ??= Completer<void>()).future;
    }
  }

  /// La voce non serve piu'.
  void lascia() {
    unawaited(_abbonamento.cancel());
    _finita = true;
    if (!_primo.isCompleted) _primo.complete(null);
    _sveglia();
  }
}
