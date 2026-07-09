import 'dart:async';
import 'dart:ui' show Offset;

import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// Sorgente del moto per la parallasse multistrato.
///
/// Combina due segnali:
/// - lo scorrimento della schermata attiva ([updateScroll]);
/// - una leggera inclinazione del dispositivo letta dall'accelerometro.
///
/// Se il sensore manca o non e' disponibile (device senza accelerometro,
/// permesso negato, anteprima web headless), la parallasse resta guidata dal
/// solo scorrimento e da uno stato statico: nessun blocco, coerente con la
/// regola d'oro dei sensori con fallback tattile o statico.
class ParallaxController extends ChangeNotifier {
  ParallaxController() {
    _tryListenTilt();
  }

  // Inclinazione normalizzata in [-1, 1] su entrambi gli assi, filtrata.
  double _tiltX = 0;
  double _tiltY = 0;

  // Scorrimento normalizzato (0 in cima, cresce scendendo).
  double _scroll = 0;

  StreamSubscription<AccelerometerEvent>? _sub;
  bool _sensorActive = false;

  /// Vero se l'inclinazione dal sensore sta contribuendo al moto.
  bool get sensorActive => _sensorActive;

  double get tiltX => _tiltX;
  double get tiltY => _tiltY;
  double get scroll => _scroll;

  /// Offset di un piano in base alla sua profondita' (0 lontano, 1 vicino).
  /// I piani lontani si muovono poco, quelli vicini di piu'.
  Offset layerOffset(double depth, {double tiltRange = 18}) {
    final dx = _tiltX * tiltRange * depth;
    final dy = _tiltY * tiltRange * depth - _scroll * 40 * depth;
    return Offset(dx, dy);
  }

  /// Aggiornato dallo scorrimento della schermata (pixel).
  void updateScroll(double pixels) {
    // Normalizza su una finestra ampia, con saturazione morbida.
    final next = (pixels / 600).clamp(-1.0, 3.0);
    if ((next - _scroll).abs() < 0.001) return;
    _scroll = next;
    notifyListeners();
  }

  void _tryListenTilt() {
    try {
      _sub = accelerometerEventStream(
        samplingPeriod: const Duration(milliseconds: 66),
      ).listen(
        _onAccel,
        onError: (_) => _sensorActive = false,
        cancelOnError: false,
      );
    } catch (_) {
      // Nessun sensore disponibile: si resta sullo scorrimento.
      _sensorActive = false;
    }
  }

  void _onAccel(AccelerometerEvent e) {
    // x e y della gravita' danno l'inclinazione; normalizziamo su g (9.8) e
    // filtriamo passa-basso per un moto dolce e senza scatti.
    final targetX = (-e.x / 9.8).clamp(-1.0, 1.0);
    final targetY = (e.y / 9.8).clamp(-1.0, 1.0);
    const alpha = 0.12;
    _tiltX += (targetX - _tiltX) * alpha;
    _tiltY += (targetY - _tiltY) * alpha;
    _sensorActive = true;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
