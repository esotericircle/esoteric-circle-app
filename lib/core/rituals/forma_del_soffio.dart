import 'dart:math' as math;
import 'dart:typed_data';

/// **LA FORMA DEL SOFFIO, non il suo volume.** Ordine DD voce 01,
/// 10 settembre 2026.
///
/// **Il fatto del fondatore**: il Soffio del Destino si apre da solo. Basta un
/// rumore qualunque nella stanza e i semi volano via senza che nessuno abbia
/// soffiato.
///
/// **LA CAUSA, ed era una riga sola**: `if (!_revealed && amp.current > -18)`.
/// Una **soglia di volume nuda**. Qualunque suono sopra i meno diciotto
/// decibel apriva il dono: la voce di chi parla, la musica in cucina, una
/// porta che sbatte.
///
/// **E il flusso audio vero c'era gia', e veniva buttato via**:
/// `_micStream = stream.listen((_) {})`. Il rilevatore aveva davanti i
/// campioni e guardava solo l'ampiezza aggregata. La cura non apre nessuna
/// porta nuova: raccoglie cio' che passava gia' di li'.
///
/// **COSA DISTINGUE UN SOFFIO, in una frase.** Un soffio e' **rumore
/// d'aria**: energia sparsa su tutte le frequenze, senza una nota dentro. La
/// voce e la musica hanno una **forma**: una fondamentale e le sue armoniche,
/// cioe' poche righe alte e molto silenzio intorno.
///
/// **La grandezza che li separa si chiama planarita' spettrale** (in
/// letteratura *spectral flatness*, o misura di Wiener): il rapporto fra la
/// media geometrica e la media aritmetica dello spettro di potenza. Vale
/// **uno** per il rumore bianco, dove tutte le righe sono uguali, e **tende a
/// zero** per un suono tonale, dove una riga domina tutte le altre. E' una
/// misura standard, usata dai codec audio per decidere se un blocco e'
/// rumoroso o tonale.
///
/// **TRE CONDIZIONI, non una**, e servono tutte e tre:
///
/// 1. **abbastanza forte**: sotto [energiaMinima] non e' successo niente;
/// 2. **abbastanza piatto**: sopra [planaritaMinima] e' aria, non una nota;
/// 3. **abbastanza a lungo**: [fotogrammiRichiesti] finestre di fila. Un tonfo
///    e' forte e piatto per un istante; un soffio dura.
///
/// La terza e' quella che chiude la porta ai colpi secchi, che sono l'unica
/// famiglia che le prime due da sole lascerebbero passare.
class FormaDelSoffio {
  /// Quanti campioni in una finestra. Potenza di due per la trasformata; a
  /// sedicimila campioni al secondo, 512 campioni sono trentadue millisecondi.
  static const int campioniPerFinestra = 512;

  /// **QUANTO FORTE**, in energia media per campione normalizzata a uno.
  ///
  /// Non e' una soglia di decibel travestita: e' il primo dei tre filtri, e da
  /// sola non apre niente. Serve a non far girare la trasformata sul silenzio.
  static const double energiaMinima = 0.0025;

  /// **QUANTO PIATTO.** Il rumore bianco vale circa uno, una nota pura vale
  /// quasi zero. Sopra questa soglia lo spettro non ha una nota dentro.
  ///
  /// **Il numero viene dalle misure**, non dal gusto. Sui campioni della
  /// guardia: rumore bianco **0,580**, soffio d'aria **0,260**, voce che parla
  /// **0,001**, accordo di tre note **0,000**, nota pura **0,000**. Fra il
  /// soffio e il primo dei suoni con una nota dentro ci sono **due ordini di
  /// grandezza**, e la soglia sta in mezzo con margine da tutte e due le
  /// parti.
  static const double planaritaMinima = 0.20;

  /// **QUANTO A LUNGO**, in finestre consecutive. Sei finestre da trentadue
  /// millisecondi sono circa **due decimi di secondo** di aria continua.
  static const int fotogrammiRichiesti = 6;

  final List<int> _coda = <int>[];
  int _diFila = 0;
  bool _visto = false;

  /// Vero quando le tre condizioni si sono verificate insieme per il numero di
  /// finestre richiesto. **Da qui in poi resta vero** finche' non si
  /// [ricomincia]: un soffio ha una coda che si spegne, e la coda spezza la
  /// catena delle finestre. Se questo fatto guardasse solo la catena in corso,
  /// tornerebbe falso mezzo secondo dopo che il gesto e' stato riconosciuto,
  /// e chi ha soffiato vedrebbe il dono aprirsi e richiudersi.
  bool get eSoffio => _visto;

  /// Quante finestre di fila hanno la forma dell'aria **in questo momento**.
  /// Serve alle guardie e a chi vuole mostrare che il gesto sta arrivando.
  int get catenaInCorso => _diFila;

  /// L'ultima planarita' misurata, per chi vuole mostrarla o provarla.
  double planarita = 0;

  /// L'ultima energia misurata.
  double energia = 0;

  void ricomincia() {
    _coda.clear();
    _diFila = 0;
    _visto = false;
    planarita = 0;
    energia = 0;
  }

  /// **I CAMPIONI COSI' COME ARRIVANO DAL MICROFONO**, PCM a sedici bit.
  ///
  /// Il flusso arriva a pacchetti di lunghezza qualunque: qui si accumulano e
  /// si consumano a finestre intere, cosi' la trasformata lavora sempre sulla
  /// stessa misura e le soglie restano confrontabili.
  void aggiungiCampioni(Uint8List byte) {
    final dati = ByteData.sublistView(byte);
    for (var i = 0; i + 1 < byte.length; i += 2) {
      _coda.add(dati.getInt16(i, Endian.little));
    }
    while (_coda.length >= campioniPerFinestra) {
      final finestra = _coda.sublist(0, campioniPerFinestra);
      _coda.removeRange(0, campioniPerFinestra);
      _guardaLaFinestra(finestra);
    }
  }

  /// La stessa cosa per chi ha gia' i campioni, che e' il caso della guardia.
  void aggiungiInteri(List<int> campioni) {
    _coda.addAll(campioni);
    while (_coda.length >= campioniPerFinestra) {
      final finestra = _coda.sublist(0, campioniPerFinestra);
      _coda.removeRange(0, campioniPerFinestra);
      _guardaLaFinestra(finestra);
    }
  }

  void _guardaLaFinestra(List<int> campioni) {
    energia = _energiaDi(campioni);
    if (energia < energiaMinima) {
      // Silenzio: la catena si spezza. Un soffio non ha buchi dentro.
      planarita = 0;
      _diFila = 0;
      return;
    }
    planarita = planaritaSpettrale(campioni);
    if (planarita >= planaritaMinima) {
      _diFila++;
      if (_diFila >= fotogrammiRichiesti) _visto = true;
    } else {
      _diFila = 0;
    }
  }

  static double _energiaDi(List<int> campioni) {
    var somma = 0.0;
    for (final c in campioni) {
      final x = c / 32768.0;
      somma += x * x;
    }
    return somma / campioni.length;
  }

  /// **LA PLANARITA' SPETTRALE DI UNA FINESTRA**, fra zero e uno.
  ///
  /// Media geometrica diviso media aritmetica dello spettro di potenza. Si
  /// calcola in logaritmi, perche' il prodotto di duecentocinquantasei numeri
  /// piccoli va sotto zero in doppia precisione prima di arrivare in fondo.
  ///
  /// **La finestra e' quella di Hann**: senza, i due bordi tagliati di netto
  /// diventano un gradino, e un gradino nel tempo e' rumore su tutte le
  /// frequenze. Una nota pura sembrerebbe piatta per colpa del taglio, che e'
  /// esattamente l'errore che questa misura deve evitare.
  static double planaritaSpettrale(List<int> campioni) {
    final n = campioni.length;
    final re = Float64List(n);
    final im = Float64List(n);
    for (var i = 0; i < n; i++) {
      final hann = 0.5 * (1 - math.cos(2 * math.pi * i / (n - 1)));
      re[i] = campioni[i] / 32768.0 * hann;
    }
    _fft(re, im);

    // Solo la meta' utile dello spettro, e senza la componente continua: una
    // corrente continua non e' un suono e falserebbe la media.
    var sommaLog = 0.0;
    var somma = 0.0;
    var quanti = 0;
    for (var k = 1; k < n ~/ 2; k++) {
      final p = re[k] * re[k] + im[k] * im[k];
      // Un pavimento minuscolo: un logaritmo di zero manderebbe tutto a meno
      // infinito e la misura direbbe zero per una riga sola vuota.
      final sicuro = p < 1e-20 ? 1e-20 : p;
      sommaLog += math.log(sicuro);
      somma += sicuro;
      quanti++;
    }
    if (quanti == 0 || somma <= 0) return 0;
    final geometrica = math.exp(sommaLog / quanti);
    final aritmetica = somma / quanti;
    return (geometrica / aritmetica).clamp(0.0, 1.0);
  }

  /// Trasformata di Fourier veloce, radice due, in posto.
  ///
  /// **Scritta qui e non presa da un pacchetto**: sono quaranta righe, e una
  /// dipendenza nuova per quaranta righe e' una dipendenza che un giorno
  /// bisogna aggiornare. La lunghezza deve essere una potenza di due, e
  /// [campioniPerFinestra] lo garantisce.
  static void _fft(Float64List re, Float64List im) {
    final n = re.length;
    // Riordino a bit invertiti.
    for (var i = 1, j = 0; i < n; i++) {
      var bit = n >> 1;
      for (; j & bit != 0; bit >>= 1) {
        j ^= bit;
      }
      j ^= bit;
      if (i < j) {
        final tr = re[i];
        re[i] = re[j];
        re[j] = tr;
        final ti = im[i];
        im[i] = im[j];
        im[j] = ti;
      }
    }
    for (var len = 2; len <= n; len <<= 1) {
      final angolo = -2 * math.pi / len;
      final wr = math.cos(angolo);
      final wi = math.sin(angolo);
      for (var i = 0; i < n; i += len) {
        var cr = 1.0;
        var ci = 0.0;
        for (var k = 0; k < len ~/ 2; k++) {
          final ur = re[i + k];
          final ui = im[i + k];
          final vr = re[i + k + len ~/ 2] * cr - im[i + k + len ~/ 2] * ci;
          final vi = re[i + k + len ~/ 2] * ci + im[i + k + len ~/ 2] * cr;
          re[i + k] = ur + vr;
          im[i + k] = ui + vi;
          re[i + k + len ~/ 2] = ur - vr;
          im[i + k + len ~/ 2] = ui - vi;
          final nuovoCr = cr * wr - ci * wi;
          ci = cr * wi + ci * wr;
          cr = nuovoCr;
        }
      }
    }
  }
}
