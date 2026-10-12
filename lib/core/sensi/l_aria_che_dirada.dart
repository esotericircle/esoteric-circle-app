import 'dart:math' as math;
import 'dart:typed_data';

import '../rituals/forma_del_soffio.dart';

/// **L'ARIA CHE DIRADA LA NEBBIA DEL SIGILLO DEL SOGNO.** Richiesta del
/// fondatore del 12 ottobre 2026: *"nei doni del giorno, il microfono del
/// sigillo della notte e' troppo sensibile e 'diradare la nebbia' si sblocca
/// con solo la musica di sottofondo o un leggero rumore di fondo"*, e *"usa
/// lo stesso parametro per il sigillo del sogno"*.
///
/// **Il difetto era una soglia di volume nuda**: il livello del microfono
/// sopra un decimo apriva la nebbia, e la musica in sottofondo lo supera.
/// Qui decide la stessa misura del Soffio del Destino, [FormaDelSoffio], con
/// gli stessi numeri: l'energia, la planarita' dello spettro e le finestre
/// di fila. La voce e la musica hanno una nota dentro e non passano.
///
/// **E IL FONDO DELLA STANZA.** Un ventilatore o un frigorifero sono rumore
/// largo come l'aria, e la forma da sola non li separa da un fiato. Il fiato
/// pero' sta a pochi centimetri dal microfono ed e' molto piu' forte: qui si
/// impara il fondo, l'energia piu' bassa delle ultime [finestreDelFondo]
/// finestre (tre secondi), e conta solo l'aria almeno [quanteVolteIlFondo]
/// volte piu' forte.
class LAriaCheDirada {
  /// Le finestre su cui si impara il fondo: novantaquattro da trentadue
  /// millisecondi, circa tre secondi.
  static const int finestreDelFondo = 94;

  /// Quante volte l'aria deve superare il fondo della stanza.
  static const double quanteVolteIlFondo = 4;

  final FormaDelSoffio _forma = FormaDelSoffio();
  final List<int> _coda = <int>[];
  final List<double> _energie = <double>[];
  int _diFila = 0;

  /// Il livello dopo questi byte del microfono, PCM a sedici bit: uno se in
  /// questo momento passa aria, zero altrimenti.
  double livello(Uint8List byte) {
    final dati = ByteData.sublistView(byte);
    final campioni = <int>[
      for (var i = 0; i + 1 < byte.length; i += 2)
        dati.getInt16(i, Endian.little),
    ];
    return livelloDegliInteri(campioni);
  }

  /// La stessa cosa per chi ha gia' i campioni, che e' il caso della guardia.
  double livelloDegliInteri(List<int> campioni) {
    _coda.addAll(campioni);
    const n = FormaDelSoffio.campioniPerFinestra;
    while (_coda.length >= n) {
      final finestra = _coda.sublist(0, n);
      _coda.removeRange(0, n);
      _guarda(finestra);
    }
    return _diFila >= FormaDelSoffio.fotogrammiRichiesti ? 1 : 0;
  }

  void _guarda(List<int> finestra) {
    final prima = _forma.catenaInCorso;
    _forma.aggiungiInteri(finestra);
    final energia = _forma.energia;
    final fondo = _energie.isEmpty ? 0.0 : _energie.reduce(math.min);
    _energie.add(energia);
    if (_energie.length > finestreDelFondo) _energie.removeAt(0);
    // All'avvio il fondo vale zero per una finestra sola: dalla seconda e'
    // gia' il rumore della stanza, e un ventilatore acceso non fa mai cinque
    // finestre di fila quattro volte sopra se stesso (provato e rimasto
    // verde, un ascolto iniziale qui non servirebbe a niente).
    final eAria =
        _forma.catenaInCorso > prima && energia >= fondo * quanteVolteIlFondo;
    _diFila = eAria ? _diFila + 1 : 0;
  }

  void ricomincia() {
    _forma.ricomincia();
    _coda.clear();
    _energie.clear();
    _diFila = 0;
  }
}
