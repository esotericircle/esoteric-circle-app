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
  /// La misura che conta e' a trenta gradi di inclinazione, dove il tilt
  /// normalizzato vale 0,5 perche' e' la proiezione della gravita': li' il
  /// piano principale deve spostarsi di almeno il dieci per cento della
  /// larghezza dello schermo, 39 px su 390 logici. Con 500 di ampiezza il
  /// piano a profondita' 0,16 fa 40 px a trenta gradi. La storia di questo
  /// numero: 18 all'origine, cioe' 2,88 px a fondo corsa, il "si sposta di due
  /// millimetri" di Mauro; poi 150, cioe' 12 px a trenta gradi, ancora poco.
  static const double tiltRangeDefault = 500;

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
  /// Senza compressione, con l'ampiezza che serve a far muovere davvero il
  /// campo stellare, il piano piu' vicino (profondita' 1,3) volerebbe a
  /// seicentocinquanta pixel a fondo corsa. Oltre il riferimento la scala
  /// cresce di quindici centesimi: il vicino resta piu' mobile del lontano,
  /// che e' il senso della parallasse, cioe' 83 px a trenta gradi contro i 40
  /// del principale e i 15 del lontano, senza uscire di scena.
  static double profonditaEfficace(double depth) {
    if (depth <= depthPianoPrincipale) return depth;
    return depthPianoPrincipale + (depth - depthPianoPrincipale) * 0.15;
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

  /// **QUANTO DERIVA IL CIELO QUANDO IL SENSORE NON C'E'. Ordine AR voce 01.**
  ///
  /// La deriva normale vale 12 per la profondita', cioe' 1,9 punti sul piano
  /// di fondo: e' un respiro accanto a un'inclinazione che ne corre 80, e da
  /// sola e' esattamente "il si sposta di due millimetri" che Mauro descrive.
  /// Su un telefono senza accelerometro, o dove lo stream non parte, quella
  /// deriva e' TUTTO cio' che la persona vedra' per sempre.
  ///
  /// Per quel caso la deriva sale a un range di 250 e usa la stessa
  /// profondita' efficace della corsa, cosi' i piani restano in proporzione
  /// fra loro: 40 punti sul fondo (la meta' della corsa satura) e 83 sul
  /// piano vicino. **Non e' il movimento del sensore e non finge di esserlo**:
  /// e' un cielo che vive comunque, e chi lo guarda vede qualcosa muoversi.
  static const double rangeSenzaSensore = 250;

  /// La deriva da usare quando `sensorActive` e' falso.
  Offset derivaSenzaSensore(double depth, double t) {
    final d = profonditaEfficace(depth);
    final a = 2 * math.pi * t;
    final dx = math.cos(a) * rangeSenzaSensore * d;
    final dy = math.sin(a * 0.7) * rangeSenzaSensore * 0.7 * d;
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

  /// **SOLO PER LE PROVE: il tilt a comando.** La guardia dei bordi
  /// (ordine AJ voce 02) deve rendere il cielo a fondo corsa nelle quattro
  /// direzioni, e i sensori in prova non esistono: questa porta imposta il
  /// tilt saturo senza filtro, come un telefono inclinato fino in fondo.
  @visibleForTesting
  void inclinaPerLaProva(double tiltX, double tiltY) {
    _tiltX = tiltX.clamp(-1.0, 1.0);
    _tiltY = tiltY.clamp(-1.0, 1.0);
    notifyListeners();
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
