import 'dart:async';
import 'dart:math' as math;
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

  /// Quanto si sposta al massimo il piano di riferimento del cielo quando il
  /// telefono si inclina fino in fondo.
  ///
  /// Prima valeva 18, e sul campo stellare, che ha profondita' 0,16, faceva
  /// **2,88 pixel**: inclinando il telefono non si vedeva niente, quindi "si
  /// sposta di due millimetri" era una misura esatta, non uno sfogo.
  static const double tiltRangeDefault = 150;

  /// La profondita' del piano che fa da riferimento, cioe' il campo stellare:
  /// e' quello che l'occhio segue, quindi e' su quello che si misura.
  static const double depthPianoPrincipale = 0.16;

  /// Spostamento massimo da sensore del piano di riferimento, in pixel logici.
  /// E' il numero che l'utente sente in mano.
  static double get spostamentoPianoPrincipale =>
      tiltRangeDefault * profonditaEfficace(depthPianoPrincipale);

  /// Spostamento massimo che il dito puo' dare allo stesso piano: lo
  /// scorrimento satura a tre schermate e pesa quaranta pixel per unita' di
  /// profondita'.
  static double get spostamentoDitoPianoPrincipale =>
      3 * 40 * depthPianoPrincipale;

  /// Comprime la profondita' oltre il piano di riferimento.
  ///
  /// Senza questa compressione, alzando l'ampiezza perche' il campo stellare si
  /// muova davvero, il piano piu' vicino (profondita' 1,3) si sposterebbe di
  /// quasi duecento pixel e uscirebbe di scena. Fino al piano di riferimento la
  /// scala resta uno a uno, oltre cresce di un quarto: il vicino si muove
  /// ancora piu' del lontano, che e' il senso della parallasse, ma resta dentro
  /// la quinta.
  static double profonditaEfficace(double depth) {
    if (depth <= depthPianoPrincipale) return depth;
    return depthPianoPrincipale + (depth - depthPianoPrincipale) * 0.25;
  }

  /// Offset di un piano in base alla sua profondita' (0 lontano, 1 vicino).
  /// I piani lontani si muovono poco, quelli vicini di piu'.
  Offset layerOffset(double depth, {double tiltRange = tiltRangeDefault}) {
    final d = profonditaEfficace(depth);
    final dx = _tiltX * tiltRange * d;
    final dy = _tiltY * tiltRange * d - _scroll * 40 * depth;
    return Offset(dx, dy);
  }

  /// Deriva automatica di ripiego, quando il giroscopio non contribuisce: un
  /// moto lento e continuo, cosi' il cosmo resta vivo anche senza sensore. [t]
  /// e' una fase in 0..1 fornita da un'animazione; i piani vicini derivano piu'
  /// di quelli lontani, come per l'inclinazione.
  Offset autoDrift(double depth, double t, {double range = 12}) {
    final a = 2 * math.pi * t;
    final dx = math.cos(a) * range * depth;
    final dy = math.sin(a * 0.7) * range * 0.7 * depth;
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
