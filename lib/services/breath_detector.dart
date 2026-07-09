import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:record/record.dart';

/// Rileva il soffio dal microfono, come livello sonoro normalizzato.
///
/// E' pensato per fallire con grazia: se il permesso manca, il microfono non
/// e' disponibile o la piattaforma non lo supporta (per esempio l'anteprima
/// web headless), `start` restituisce false e l'esperienza prosegue con il
/// solo gesto tattile. Nessuna eccezione risale al chiamante.
class BreathDetector {
  final AudioRecorder _recorder = AudioRecorder();
  final StreamController<double> _levels = StreamController<double>.broadcast();
  StreamSubscription<Uint8List>? _sub;
  bool _active = false;

  /// Livello sonoro istantaneo, normalizzato in [0, 1].
  Stream<double> get level => _levels.stream;
  bool get isActive => _active;

  /// Avvia l'ascolto. Ritorna true se il microfono e' realmente disponibile.
  Future<bool> start() async {
    try {
      if (!await _recorder.hasPermission()) return false;
      final stream = await _recorder.startStream(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: 16000,
          numChannels: 1,
        ),
      );
      _sub = stream.listen(
        (bytes) => _levels.add(_rms(bytes)),
        onError: (_) {},
        cancelOnError: false,
      );
      _active = true;
      return true;
    } catch (_) {
      _active = false;
      return false;
    }
  }

  double _rms(Uint8List bytes) {
    final count = bytes.length ~/ 2;
    if (count == 0) return 0;
    final data = ByteData.sublistView(bytes);
    var sum = 0.0;
    for (var i = 0; i < count; i++) {
      final s = data.getInt16(i * 2, Endian.little) / 32768.0;
      sum += s * s;
    }
    // La radice quadratica media, amplificata un poco per rendere il soffio
    // leggibile, e' saturata a 1.
    return (math.sqrt(sum / count) * 2.2).clamp(0.0, 1.0);
  }

  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
    try {
      await _recorder.stop();
    } catch (_) {}
    _active = false;
  }

  Future<void> dispose() async {
    await stop();
    await _levels.close();
    await _recorder.dispose();
  }
}
