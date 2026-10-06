import 'la_voce_che_tace.dart';

/// **DOVE SI ROMPE LA VOCE, MISURATO DOVE LA PERSONA LA SENTE. Ordine FE
/// voce 05, 6 ottobre 2026.**
///
/// Il primo strumento ascoltava la stanza col microfono del PC, e quella
/// notte il microfono sentiva la voce del Maestro appena 1-3 dB sopra il
/// fondo (`docs/collaudo/FE/voci/`): cieco. Qui si legge la traccia che il
/// telefono riceve dal volto e suona, con le statistiche di WebRTC lette ogni
/// [passo]: la potenza di ogni intervallo (energia su durata, la stessa
/// misura di [LaVoceCheTace]) e i campioni che il ricevitore ha dovuto
/// inventare perche' l'audio non arrivava (`concealedSamples` meno quelli
/// del silenzio).
///
/// **Una rottura** e' un tratto senza voce lungo almeno [LaVoceCheTace.quiete]
/// (piu' della pausa fra due frasi della voce sintetica) fra la prima e
/// l'ultima voce di una risposta. Solo misura: non cambia cosa fa il LIVE.
class LaVoceRicevuta {
  /// Ogni quanto si leggono le statistiche.
  static const Duration passo = Duration(milliseconds: 100);

  /// Il tasso dei campioni del ricevitore audio di WebRTC.
  static const int campioniAlSecondo = 48000;

  final List<_Punto> _punti = [];

  /// Un punto delle statistiche cumulative, a [tempo] dall'inizio.
  void punto(
    Duration tempo, {
    num? durata,
    num? energia,
    num? nascosti,
    num? nascostiMuti,
  }) {
    if (durata == null || energia == null) return;
    _punti.add(_Punto(tempo, durata.toDouble(), energia.toDouble(),
        (nascosti ?? 0).toDouble(), (nascostiMuti ?? 0).toDouble()));
  }

  /// Gli intervalli con voce e senza, nell'ordine: (inizio, fine, voce).
  List<(Duration, Duration, bool)> get _tratti {
    final t = <(Duration, Duration, bool)>[];
    for (var i = 1; i < _punti.length; i++) {
      final a = _punti[i - 1], b = _punti[i];
      final d = b.durata - a.durata;
      final voce = d > 0 && (b.energia - a.energia) / d > LaVoceCheTace.soglia;
      t.add((a.tempo, b.tempo, voce));
    }
    return t;
  }

  /// Le rotture: (dove comincia, quanto dura).
  List<(Duration, Duration)> get rotture {
    final t = _tratti;
    final primo = t.indexWhere((x) => x.$3);
    final ultimo = t.lastIndexWhere((x) => x.$3);
    if (primo < 0 || ultimo <= primo) return const [];
    final r = <(Duration, Duration)>[];
    Duration? da;
    for (var i = primo; i <= ultimo; i++) {
      final (inizio, fine, voce) = t[i];
      if (!voce) {
        da ??= inizio;
      } else if (da != null) {
        final lungo = inizio - da;
        if (lungo >= LaVoceCheTace.quiete) r.add((da, lungo));
        da = null;
      }
    }
    return r;
  }

  /// I secondi di voce sentita.
  double get secondiDiVoce => _tratti
      .where((x) => x.$3)
      .fold(0.0, (s, x) => s + (x.$2 - x.$1).inMilliseconds / 1000);

  /// I millisecondi che il ricevitore ha inventato mentre doveva esserci
  /// voce: l'audio del volto non arrivava in tempo.
  int get millisecondiNascosti {
    if (_punti.length < 2) return 0;
    final a = _punti.first, b = _punti.last;
    final c = (b.nascosti - a.nascosti) - (b.nascostiMuti - a.nascostiMuti);
    return (c * 1000 / campioniAlSecondo).round();
  }

  /// La riga del registro.
  String riga(String quale) {
    final r = rotture;
    return 'LIVE VOCE RICEVUTA: $quale, ${secondiDiVoce.toStringAsFixed(1)} '
        's di voce, ${r.length} rotture'
        '${r.isEmpty ? '' : ': ${[
            for (final (da, quanto) in r)
              '${quanto.inMilliseconds} ms al secondo '
                  '${(da.inMilliseconds / 1000).toStringAsFixed(1)}'
          ].join(', ')}'}'
        ', $millisecondiNascosti ms nascosti dal ricevitore';
  }
}

class _Punto {
  _Punto(
      this.tempo, this.durata, this.energia, this.nascosti, this.nascostiMuti);
  final Duration tempo;
  final double durata;
  final double energia;
  final double nascosti;
  final double nascostiMuti;
}
