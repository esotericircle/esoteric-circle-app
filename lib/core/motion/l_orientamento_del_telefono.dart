/// L'ORIENTAMENTO ASSOLUTO DEL TELEFONO, per il Real Time Cosmo. Ordine FG
/// parte 2, voce 2.9.
///
/// **Verificato e dichiarato: sensors_plus non espone il vettore di rotazione
/// fuso.** Nel pacchetto risolto dal lock (6.1.2, il pubspec chiede ^6.1.1) il
/// plugin Android registra solo accelerometro, accelerazione lineare,
/// giroscopio, campo magnetico e pressione; su iOS legge il magnetometro
/// grezzo. Niente TYPE_ROTATION_VECTOR, niente CMAttitude. L'ordine vieta di
/// aggiungere dipendenze, quindi l'orientamento si ricava qui dalle due
/// letture che ci sono, come fa `SensorManager.getRotationMatrix` di Android:
/// la gravita' dice dov'e' l'alto, il campo magnetico dov'e' il nord
/// magnetico, il prodotto vettoriale dei due dov'e' l'est. Poi la
/// declinazione del World Magnetic Model sposta il nord magnetico sul nord
/// vero.
///
/// **I limiti, dichiarati.** Il magnetometro sente il ferro vicino e su iPhone
/// arriva grezzo, senza la taratura di sistema: il nord puo' sbagliare di
/// parecchi gradi. Per questo esiste la riga che invita a puntare la Luna o
/// un pianeta (voce 6.4): [correggiSu] rimette in bolla l'azimut su un
/// oggetto vero. E il trascinamento col dito non e' una via di scarto: resta
/// sempre, anche col sensore acceso (voce 2.10).
///
/// La gravita' arriva da `ParallaxController.gravitaGrezza`, perche'
/// l'accelerometro ha una porta sola nell'app. Il magnetometro lo apre e lo
/// chiude questa classe, e lo chiude davvero quando la schermata esce di
/// scena (voce 7.8).
library;

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../astro/real_time_cosmo/la_camera_del_cielo.dart';

class OrientamentoDelTelefono {
  OrientamentoDelTelefono({
    required this.gravita,
    Stream<MagnetometerEvent> Function()? bussola,
  }) : _bussola = bussola ??
            (() => magnetometerEventStream(
                samplingPeriod: SensorInterval.gameInterval));

  /// Chi da' l'ultima gravita' letta (di solito il ParallaxController).
  final ({double x, double y, double z})? Function() gravita;
  final Stream<MagnetometerEvent> Function() _bussola;

  StreamSubscription<MagnetometerEvent>? _ascolto;
  ({double x, double y, double z})? _campo;
  bool _guasto = false;

  // Le due letture filtrate.
  double _gx = 0, _gy = 0, _gz = 0;
  double _mx = 0, _my = 0, _mz = 0;
  bool _primo = true;

  /// La declinazione magnetica del luogo, in gradi, positiva a est.
  double declinazioneGradi = 0;

  /// La correzione dell'azimut presa puntando un oggetto vero, in gradi.
  double correzioneGradi = 0;

  /// Vero se la bussola ha risposto e la gravita' c'e'.
  bool get pronto => !_guasto && _campo != null && gravita() != null;

  /// Vero se il magnetometro ha dato errore o non esiste.
  bool get guasto => _guasto;

  bool get acceso => _ascolto != null;

  void accendi() {
    if (_ascolto != null) return;
    try {
      _ascolto = _bussola().listen(
        (e) => _campo = (x: e.x, y: e.y, z: e.z),
        onError: (_) => _guasto = true,
        cancelOnError: false,
      );
    } catch (errore) {
      // Il telefono senza magnetometro: non e' un guasto dell'app, e' un
      // telefono senza bussola. Si dice a schermo (il ripiego col dito) e
      // nel registro, e non si riprova.
      debugPrint('Real Time Cosmo: la bussola non si apre ($errore)');
      _guasto = true;
    }
  }

  void spegni() {
    _ascolto?.cancel();
    _ascolto = null;
    _primo = true;
  }

  /// Un passo del filtro: [dt] secondi dall'ultimo, [costanteDiTempo] in
  /// secondi (dal campo visivo, `costanteDiTempoPerCampo`). Restituisce
  /// l'orientamento della camera posteriore, o nullo se le letture mancano o
  /// sono degeneri (il telefono in caduta, il campo parallelo alla gravita').
  OrientamentoDellaCamera? passo(double dt, double costanteDiTempo) {
    final g = gravita();
    final c = _campo;
    if (g == null || c == null || _guasto) return null;
    if (_primo) {
      _gx = g.x;
      _gy = g.y;
      _gz = g.z;
      _mx = c.x;
      _my = c.y;
      _mz = c.z;
      _primo = false;
    } else {
      final a = 1 - math.exp(-dt / math.max(0.001, costanteDiTempo));
      _gx += (g.x - _gx) * a;
      _gy += (g.y - _gy) * a;
      _gz += (g.z - _gz) * a;
      _mx += (c.x - _mx) * a;
      _my += (c.y - _my) * a;
      _mz += (c.z - _mz) * a;
    }
    return orientamentoDa(
      gx: _gx, gy: _gy, gz: _gz,
      mx: _mx, my: _my, mz: _mz,
      declinazioneGradi: declinazioneGradi + correzioneGradi,
    );
  }

  /// Rimette in bolla l'azimut: la camera che il sensore dice puntata a
  /// [azimutMisurato] guarda in realta' l'oggetto all'azimut [azimutVero].
  void correggiSu({required double azimutMisurato, required double azimutVero}) {
    var d = azimutVero - azimutMisurato;
    d = (d + 540) % 360 - 180;
    correzioneGradi += d;
  }

  /// L'orientamento dalla gravita' (alto) e dal campo magnetico (nord
  /// magnetico) negli assi del telefono. Pura: la provano le prove.
  static OrientamentoDellaCamera? orientamentoDa({
    required double gx,
    required double gy,
    required double gz,
    required double mx,
    required double my,
    required double mz,
    double declinazioneGradi = 0,
  }) {
    // Est = campo x alto.
    var hx = my * gz - mz * gy;
    var hy = mz * gx - mx * gz;
    var hz = mx * gy - my * gx;
    final nh = math.sqrt(hx * hx + hy * hy + hz * hz);
    final ng = math.sqrt(gx * gx + gy * gy + gz * gz);
    if (nh < 0.1 || ng < 0.1) return null;
    hx /= nh;
    hy /= nh;
    hz /= nh;
    final ax = gx / ng, ay = gy / ng, az = gz / ng;
    // Nord = alto x est.
    final nx = ay * hz - az * hy;
    final ny = az * hx - ax * hz;
    final nz = ax * hy - ay * hx;
    // La matrice [est; nord; alto] porta un asse del telefono nel mondo:
    // l'asse x del telefono e' (hx, nx, ax), e cosi' via.
    final d = declinazioneGradi * math.pi / 180;
    final cd = math.cos(d), sd = math.sin(d);
    // Dal nord magnetico al nord vero: ogni vettore ruota di +D attorno
    // all'alto (un vettore all'azimut magnetico a sta all'azimut vero a + D).
    List<double> vero(double e, double n, double u) =>
        [e * cd + n * sd, -e * sd + n * cd, u];
    final destra = vero(hx, nx, ax);
    final su = vero(hy, ny, ay);
    // La camera posteriore guarda lungo -z del telefono.
    final avanti = vero(-hz, -nz, -az);
    return OrientamentoDellaCamera([...destra, ...su, ...avanti]);
  }
}
