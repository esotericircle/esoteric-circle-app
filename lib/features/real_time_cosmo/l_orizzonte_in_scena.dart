/// L'ORIZZONTE CHE SI ATTRAVERSA. Ordine FH parte 7.
///
/// L'asset `assets/img/cosmo/orizzonte.webp` e' una sagoma nera di 4.096 per
/// 256 pixel, trasparente in alto, coi bordi che combaciano (scarto medio
/// 0,38 fra la prima e l'ultima colonna, misurato il 10 ottobre 2026). Si
/// avvolge sui 360 gradi dell'azimut (voce 7.1): 4.096 pixel per 360 gradi,
/// cioe' 11,38 pixel per grado, e la stessa scala in verticale, perche' la
/// sagoma non si deformi. L'altezza zero sta sulla riga 118, il punto piu'
/// basso della sagoma: cosi' nessuna valle scende sotto l'orizzonte vero e
/// colline e alberi si alzano sopra, fino a 3,6 gradi. Sotto la fascia, una
/// calotta nera piena fino al nadir.
///
/// **Il terreno non e' un muro, e' un velo** (voce 7.2): la sua opacita' e'
/// 1,00 quando lo sguardo e' all'orizzonte o sopra, scende in modo continuo a
/// 0,55 mentre lo sguardo passa da zero a meno venti gradi, e sotto resta
/// 0,55. Attraverso il velo si vede il cielo dall'altra parte della Terra,
/// disegnato per intero e smorzato da questa stessa opacita' (voce 7.3).
///
/// Le due maglie (la fascia con la sagoma, la calotta) sono direzioni
/// dell'orizzonte calcolate UNA volta; a ogni fotogramma si proiettano nei
/// loro buffer, e i triangoli che non si possono proiettare si schiacciano in
/// un punto invece di sparire dalla lista: nessuna lista rigenerata.
library;

import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import '../../core/astro/real_time_cosmo/la_camera_del_cielo.dart';

const double kPixelPerGrado = 4096 / 360;

/// La riga dell'asset che sta all'altezza zero.
const double kRigaDellOrizzonte = 118;

/// L'opacita' del terreno per l'altezza dello sguardo (voce 7.2).
const double kOpacitaDelTerrenoAlMinimo = 0.55;
const double kAltezzaDelVeloPieno = -20;

double opacitaDelTerreno(double altezzaDelloSguardo) {
  if (altezzaDelloSguardo >= 0) return 1.0;
  if (altezzaDelloSguardo <= kAltezzaDelVeloPieno) {
    return kOpacitaDelTerrenoAlMinimo;
  }
  final t = altezzaDelloSguardo / kAltezzaDelVeloPieno;
  return 1.0 + (kOpacitaDelTerrenoAlMinimo - 1.0) * t;
}

/// Il passo dell'azimut delle maglie, in gradi.
const double _passoAzimut = 5;

class OrizzonteInScena {
  OrizzonteInScena(this.sagoma)
      : _fasciaAlt = _altezzeDellaFascia(sagoma.height.toDouble()),
        _calottaAlt = _altezzeDellaCalotta(sagoma.height.toDouble()) {
    final colonne = (360 / _passoAzimut).round();
    _colonne = colonne;
    final vf = colonne * (_fasciaAlt.length - 1) * 6;
    final vc = colonne * (_calottaAlt.length - 1) * 6;
    fasciaPosizioni = Float32List(vf * 2);
    fasciaTessitura = Float32List(vf * 2);
    calottaPosizioni = Float32List(vc * 2);
    calottaColori = Int32List(vc);
    _fasciaDir = Float32List(vf * 3);
    _calottaDir = Float32List(vc * 3);
    _riempi(_fasciaAlt, _fasciaDir, fasciaTessitura);
    _riempi(_calottaAlt, _calottaDir, null);
    for (var i = 0; i < vc; i++) {
      calottaColori[i] = 0xFF000000;
    }
    pennelloDellaSagoma = ui.Paint()
      ..shader = ui.ImageShader(
          sagoma,
          ui.TileMode.repeated,
          ui.TileMode.clamp,
          Float64List.fromList(
              const [1.0, 0, 0, 0, 0, 1.0, 0, 0, 0, 0, 1.0, 0, 0, 0, 0, 1.0]))
      ..filterQuality = ui.FilterQuality.medium;
  }

  /// La sagoma, l'asset dell'orizzonte.
  final ui.Image sagoma;

  /// Il pennello con la sagoma: lo shader nasce QUI, una volta, e nel
  /// fotogramma cambia solo l'alfa del pennello.
  late final ui.Paint pennelloDellaSagoma;
  final ui.Paint pennelloDellaCalotta = ui.Paint();

  late final Float32List fasciaPosizioni, fasciaTessitura;
  late final Float32List calottaPosizioni;
  late final Int32List calottaColori;
  late final Float32List _fasciaDir, _calottaDir;
  final List<double> _fasciaAlt, _calottaAlt;
  late final int _colonne;

  /// L'opacita' dell'ultimo fotogramma (voce 7.2).
  double opacita = 1;

  final List<double> _p = [0, 0];

  /// Le altezze delle righe della fascia: dalla cima dell'asset al fondo.
  static List<double> _altezzeDellaFascia(double righe) {
    const cima = kRigaDellOrizzonte / kPixelPerGrado;
    final fondo = (kRigaDellOrizzonte - righe) / kPixelPerGrado;
    const passi = 8;
    return [for (var k = 0; k <= passi; k++) cima + (fondo - cima) * k / passi];
  }

  /// Le altezze della calotta: dal fondo della fascia al nadir, con righe
  /// fitte vicino all'orizzonte e larghe verso il basso.
  static List<double> _altezzeDellaCalotta(double righe) {
    final fondo = (kRigaDellOrizzonte - righe) / kPixelPerGrado;
    return [fondo, -16, -22, -30, -40, -52, -65, -78, -89.5];
  }

  double get _vDiZero => kRigaDellOrizzonte;

  void _riempi(List<double> alt, Float32List dir, Float32List? tex) {
    var v = 0;
    void vertice(double az, double h) {
      final a = az * math.pi / 180, e = h * math.pi / 180;
      dir[v * 3] = math.cos(e) * math.sin(a);
      dir[v * 3 + 1] = math.cos(e) * math.cos(a);
      dir[v * 3 + 2] = math.sin(e);
      if (tex != null) {
        tex[v * 2] = az * kPixelPerGrado;
        tex[v * 2 + 1] = _vDiZero - h * kPixelPerGrado;
      }
      v++;
    }

    for (var c = 0; c < _colonne; c++) {
      final az0 = c * _passoAzimut, az1 = az0 + _passoAzimut;
      for (var r = 0; r < alt.length - 1; r++) {
        final h0 = alt[r], h1 = alt[r + 1];
        vertice(az0, h0);
        vertice(az1, h0);
        vertice(az0, h1);
        vertice(az1, h0);
        vertice(az1, h1);
        vertice(az0, h1);
      }
    }
  }

  void _proietta(Float32List dir, Float32List pos, OrientamentoDellaCamera o,
      ProiezioneDelCielo p, double dx, double dy) {
    final n = dir.length ~/ 3;
    for (var t = 0; t < n; t += 3) {
      var ok = true;
      for (var k = 0; k < 3 && ok; k++) {
        final i = t + k;
        ok = p.proietta(o, dir[i * 3], dir[i * 3 + 1], dir[i * 3 + 2], _p);
        if (ok) {
          pos[i * 2] = _p[0] + dx;
          pos[i * 2 + 1] = _p[1] + dy;
        }
      }
      if (!ok) {
        // Il triangolo non si proietta: si schiaccia in un punto.
        for (var k = 0; k < 3; k++) {
          pos[(t + k) * 2] = -10000;
          pos[(t + k) * 2 + 1] = -10000;
        }
      }
    }
  }

  /// Proietta le due maglie e decide l'opacita' del velo del terreno.
  void prepara(OrientamentoDellaCamera o, ProiezioneDelCielo p,
      {double spostamentoX = 0, double spostamentoY = 0}) {
    _proietta(_fasciaDir, fasciaPosizioni, o, p, spostamentoX, spostamentoY);
    _proietta(_calottaDir, calottaPosizioni, o, p, spostamentoX, spostamentoY);
    opacita = opacitaDelTerreno(o.altezzaGradi);
    final colore = ((opacita * 255).round() << 24) & 0xFF000000;
    for (var i = 0; i < calottaColori.length; i++) {
      calottaColori[i] = colore;
    }
  }
}
