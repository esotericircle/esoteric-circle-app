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

/// Sotto questo scarto fra la lettura e il filtrato, in gradi, il telefono e'
/// fermo e cio' che cambia e' rumore: il filtro rallenta.
const double kMotoDellaQuiete = 2.5;

/// La costante di tempo del filtro col telefono fermo, in secondi.
const double kCostanteDellaQuiete = 1.5;

/// Per quanto il filtro resta pronto dopo un moto vero, in secondi.
const double kMemoriaDelMoto = 1.0;

/// La mezza larghezza della scatola, in gradi: a settanta gradi di campo e'
/// poco piu' di un punto.
const double kSogliaDellaQuiete = 0.2;

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

  /// L'ultimo orientamento dato alla schermata: sotto [kSogliaDellaQuiete]
  /// resta quello (vedi [passo]).
  OrientamentoDellaCamera? _dato;

  /// Quanto il telefono si e' mosso da poco, fra 0 (fermo) e 1: un giro vero
  /// tiene il filtro pronto fino in fondo, anche quando l'ultimo tratto e'
  /// piccolo (senza, gli ultimi cinque gradi si seguivano col filtro lento).
  double _agitazione = 0;

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
    _dato = null;
    _agitazione = 0;
  }

  /// Un passo del filtro: [dt] secondi dall'ultimo, [costanteDiTempo] in
  /// secondi (dal campo visivo, `costanteDiTempoPerCampo`). Restituisce
  /// l'orientamento della camera posteriore, o nullo se le letture mancano o
  /// sono degeneri (il telefono in caduta, il campo parallelo alla gravita').
  ///
  /// [orizzontale] dice che la schermata e' girata in orizzontale: allora
  /// "destra" e "su" della vista sono i lati lunghi del telefono, non quelli
  /// della posa verticale (vedi [orientamentoDa]).
  OrientamentoDellaCamera? passo(double dt, double costanteDiTempo,
      {bool orizzontale = false}) {
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
      // IL FILTRO SI ADATTA AL MOTO (segnalazione del fondatore del 10
      // ottobre 2026: col telefono fermo, anche appoggiato, il cielo tremava).
      // Il rumore del magnetometro e' di un grado circa a lettura: con la
      // costante del campo (fra 0,08 e 0,45 secondi) passava quasi intero, e
      // la vista percorreva 358 punti in dieci secondi senza che il telefono
      // si muovesse. Quando le letture si scostano dal filtrato di meno di
      // [kMotoDellaQuiete] gradi il filtro rallenta fino a
      // [kCostanteDellaQuiete]; oltre il doppio torna quello del campo, e un
      // giro vero si segue come prima.
      final moto = math.max(
        _scarto(g.x, g.y, g.z, _gx, _gy, _gz),
        _scarto(c.x, c.y, c.z, _mx, _my, _mz),
      );
      final adesso =
          ((moto - kMotoDellaQuiete) / kMotoDellaQuiete).clamp(0.0, 1.0);
      _agitazione =
          math.max(adesso, _agitazione * math.exp(-dt / kMemoriaDelMoto));
      // Al quadrato: un'agitazione a meta' tiene il filtro quasi pronto.
      final quiete = (1 - _agitazione) * (1 - _agitazione);
      final costante = costanteDiTempo +
          (math.max(costanteDiTempo, kCostanteDellaQuiete) - costanteDiTempo) *
              quiete;
      final a = 1 - math.exp(-dt / math.max(0.001, costante));
      _gx += (g.x - _gx) * a;
      _gy += (g.y - _gy) * a;
      _gz += (g.z - _gz) * a;
      _mx += (c.x - _mx) * a;
      _my += (c.y - _my) * a;
      _mz += (c.z - _mz) * a;
    }
    final nuovo = orientamentoDa(
      gx: _gx,
      gy: _gy,
      gz: _gz,
      mx: _mx,
      my: _my,
      mz: _mz,
      declinazioneGradi: declinazioneGradi + correzioneGradi,
      orizzontale: orizzontale,
    );
    // LA SCATOLA: finche' il filtrato resta entro [kSogliaDellaQuiete] dalla
    // vista, la vista resta dov'e' (il residuo del rumore si vedeva come un
    // brulichio delle stelle); quando esce, la vista lo segue di quanto e'
    // uscito, senza scatti. Una soglia secca faceva salti di quasi un punto.
    final dato = _dato;
    if (nuovo == null || dato == null) {
      _dato = nuovo;
      return nuovo;
    }
    final r = _rotazioneGradi(dato, nuovo);
    if (r <= kSogliaDellaQuiete) return dato;
    return _dato = _verso(dato, nuovo, (r - kSogliaDellaQuiete) / r);
  }

  /// Da [a] verso [b] per la frazione [t], tenendo la matrice una rotazione:
  /// "avanti" e "su" interpolati e rimessi ortogonali, "destra" dal loro
  /// prodotto (destra = avanti x su, come in [orientamentoDa]).
  static OrientamentoDellaCamera _verso(
      OrientamentoDellaCamera a, OrientamentoDellaCamera b, double t) {
    var fx = a.m[6] + (b.m[6] - a.m[6]) * t;
    var fy = a.m[7] + (b.m[7] - a.m[7]) * t;
    var fz = a.m[8] + (b.m[8] - a.m[8]) * t;
    final nf = math.sqrt(fx * fx + fy * fy + fz * fz);
    fx /= nf;
    fy /= nf;
    fz /= nf;
    var ux = a.m[3] + (b.m[3] - a.m[3]) * t;
    var uy = a.m[4] + (b.m[4] - a.m[4]) * t;
    var uz = a.m[5] + (b.m[5] - a.m[5]) * t;
    final p = ux * fx + uy * fy + uz * fz;
    ux -= p * fx;
    uy -= p * fy;
    uz -= p * fz;
    final nu = math.sqrt(ux * ux + uy * uy + uz * uz);
    ux /= nu;
    uy /= nu;
    uz /= nu;
    final rx = fy * uz - fz * uy;
    final ry = fz * ux - fx * uz;
    final rz = fx * uy - fy * ux;
    return OrientamentoDellaCamera([rx, ry, rz, ux, uy, uz, fx, fy, fz]);
  }

  /// L'angolo in gradi fra due letture (gia' filtrata e nuova).
  static double _scarto(
      double ax, double ay, double az, double bx, double by, double bz) {
    final na = math.sqrt(ax * ax + ay * ay + az * az);
    final nb = math.sqrt(bx * bx + by * by + bz * bz);
    if (na < 1e-9 || nb < 1e-9) return 180;
    final c = ((ax * bx + ay * by + az * bz) / (na * nb)).clamp(-1.0, 1.0);
    return math.acos(c) * 180 / math.pi;
  }

  /// Quanto ha girato la camera fra due orientamenti, in gradi: il piu'
  /// grande fra lo scarto della direzione "avanti" e quello del "su".
  static double _rotazioneGradi(
      OrientamentoDellaCamera a, OrientamentoDellaCamera b) {
    double angolo(int i) {
      final d =
          a.m[i] * b.m[i] + a.m[i + 1] * b.m[i + 1] + a.m[i + 2] * b.m[i + 2];
      return math.acos(d.clamp(-1.0, 1.0)) * 180 / math.pi;
    }

    return math.max(angolo(6), angolo(3));
  }

  /// Rimette in bolla l'azimut: la camera che il sensore dice puntata a
  /// [azimutMisurato] guarda in realta' l'oggetto all'azimut [azimutVero].
  void correggiSu(
      {required double azimutMisurato, required double azimutVero}) {
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
    bool orizzontale = false,
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
    final x = vero(hx, nx, ax);
    final y = vero(hy, ny, ay);
    // IL TELEFONO ORIZZONTALE (segnalato dal fondatore il 10 ottobre 2026: la
    // schermata girava in orizzontale e il cielo della bussola restava
    // verticale). Con la schermata girata la destra e il su della vista sono
    // gli assi del telefono girati di un quarto, come fa
    // `SensorManager.remapCoordinateSystem` di Android; quale dei due versi
    // lo dice la gravita': il lato destro del telefono in alto (gx > 0) e' la
    // cima a sinistra.
    final List<double> destra, su;
    if (!orizzontale) {
      destra = x;
      su = y;
    } else if (gx >= 0) {
      destra = [-y[0], -y[1], -y[2]];
      su = x;
    } else {
      destra = y;
      su = [-x[0], -x[1], -x[2]];
    }
    // La camera posteriore guarda lungo -z del telefono.
    final avanti = vero(-hz, -nz, -az);
    return OrientamentoDellaCamera([...destra, ...su, ...avanti]);
  }
}
