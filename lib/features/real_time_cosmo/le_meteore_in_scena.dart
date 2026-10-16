/// LE STELLE CADENTI IN SCENA. Ordine FH parte 12.
///
/// Nelle notti degli sciami veri le meteore partono dal radiante vero (voce
/// 12.1): ogni scia corre su un cerchio massimo che si allontana dal
/// radiante. La frequenza e' quella dello sciame (voce 12.2): la frequenza
/// oraria zenitale per il seno dell'altezza del radiante, per la parte di
/// cielo che il riquadro mostra ([kParteDiCieloInQuadro]). Fuori dagli sciami
/// compaiono soltanto le sporadiche, con direzioni a caso.
///
/// Una meteora dura meno di un secondo e si spegne (voce 12.3): e' un nastro
/// di triangoli, chiaro in testa e trasparente in coda, disegnato con la
/// stessa chiamata delle linee delle figure e senza sfocature. Al piu'
/// [kMeteoreInsieme] insieme, nei buffer nati una volta. Con Riduci Movimento
/// non compaiono (voce 12.4): la schermata non chiama [prepara].
library;

import 'dart:math' as math;
import 'dart:typed_data';

import '../../core/astro/real_time_cosmo/la_camera_del_cielo.dart';

/// Quante meteore possono stare in cielo nello stesso momento.
const int kMeteoreInsieme = 4;

/// I tratti del nastro di ogni meteora.
const int kTrattiDellaMeteora = 8;

/// La parte del cielo che il riquadro mostra, a settanta gradi di campo:
/// circa un quarto della volta.
const double kParteDiCieloInQuadro = 0.25;

class MeteoreInScena {
  MeteoreInScena({int seme = 2026}) : _caso = math.Random(seme);

  final math.Random _caso;

  /// Il nastro di tutte le meteore, triangoli e colori.
  final Float32List posizioni =
      Float32List(kMeteoreInsieme * kTrattiDellaMeteora * 6 * 2);
  final Int32List colori = Int32List(kMeteoreInsieme * kTrattiDellaMeteora * 6);

  /// Quanti vertici valgono nell'ultimo fotogramma.
  int vertici = 0;

  /// Le meteore vive: inizio S, direzione D, arco, durata, eta'.
  final Float64List _s = Float64List(kMeteoreInsieme * 3);
  final Float64List _d = Float64List(kMeteoreInsieme * 3);
  final Float64List _arco = Float64List(kMeteoreInsieme);
  final Float64List _durata = Float64List(kMeteoreInsieme);
  final Float64List _eta = Float64List(kMeteoreInsieme);
  final Uint8List _viva = Uint8List(kMeteoreInsieme);

  /// Il radiante J2000 dello sciame del giorno come versore equatoriale, o
  /// niente fuori dagli sciami; la frequenza oraria zenitale di quel giorno.
  final Float64List _radiante = Float64List(3);
  bool _conRadiante = false;
  double _frequenza = 0;

  /// Le meteore nate finora: le prove lo leggono.
  int nate = 0;

  /// Per le prove: la prossima meteora nasce al prossimo fotogramma.
  bool prossimaSubito = false;

  final List<double> _p = [0, 0];

  /// Dice lo sciame del giorno: il radiante (gradi J2000) o nessuno, e la
  /// frequenza oraria zenitale. Si chiama quando cambia il giorno, non a
  /// ogni fotogramma.
  void configura(
      {double? raGradi, double? decGradi, required double frequenza}) {
    _frequenza = frequenza;
    _conRadiante = raGradi != null && decGradi != null;
    if (_conRadiante) {
      const g = math.pi / 180;
      final cd = math.cos(decGradi! * g);
      _radiante[0] = cd * math.cos(raGradi! * g);
      _radiante[1] = cd * math.sin(raGradi * g);
      _radiante[2] = math.sin(decGradi * g);
    }
  }

  /// Fa nascere, invecchiare e proiettare le meteore per un fotogramma di
  /// [dt] secondi, col cielo girato dagli [assi] dell'istante.
  void prepara(OrientamentoDellaCamera o, ProiezioneDelCielo p,
      Float64List assi, double dt,
      {double spostamentoX = 0, double spostamentoY = 0}) {
    // Il radiante sull'orizzonte di adesso.
    var rx = 0.0, ry = 0.0, rz = 0.0;
    if (_conRadiante) {
      rx = _radiante[0] * assi[0] +
          _radiante[1] * assi[3] +
          _radiante[2] * assi[6];
      ry = _radiante[0] * assi[1] +
          _radiante[1] * assi[4] +
          _radiante[2] * assi[7];
      rz = _radiante[0] * assi[2] +
          _radiante[1] * assi[5] +
          _radiante[2] * assi[8];
    }
    // La nascita: un processo di Poisson con la frequenza vera.
    final altezzaDelRadiante = _conRadiante ? math.max(0.0, rz) : 1.0;
    final perSecondo =
        _frequenza * altezzaDelRadiante * kParteDiCieloInQuadro / 3600;
    if (prossimaSubito || _caso.nextDouble() < perSecondo * dt) {
      prossimaSubito = false;
      _nasci(o, rx, ry, rz);
    }
    var v = 0;
    for (var m = 0; m < kMeteoreInsieme; m++) {
      if (_viva[m] == 0) continue;
      _eta[m] += dt;
      final t = _eta[m] / _durata[m];
      if (t >= 1) {
        _viva[m] = 0;
        continue;
      }
      // La testa corre lungo l'arco; la coda e' un terzo dell'arco dietro.
      // La luce sale nel primo quinto e si spegne nell'ultimo terzo.
      final luce = math.min(1.0, t / 0.2) * math.min(1.0, (1 - t) / 0.35);
      final testa = t, coda = math.max(0.0, t - 0.35);
      for (var k = 0; k < kTrattiDellaMeteora; k++) {
        final u0 = coda + (testa - coda) * k / kTrattiDellaMeteora;
        final u1 = coda + (testa - coda) * (k + 1) / kTrattiDellaMeteora;
        if (!_punto(m, u0, o, p)) continue;
        final x0 = _p[0] + spostamentoX, y0 = _p[1] + spostamentoY;
        if (!_punto(m, u1, o, p)) continue;
        final x1 = _p[0] + spostamentoX, y1 = _p[1] + spostamentoY;
        final f0 = k / kTrattiDellaMeteora, f1 = (k + 1) / kTrattiDellaMeteora;
        var nx = -(y1 - y0), ny = x1 - x0;
        final l = math.sqrt(nx * nx + ny * ny);
        if (l < 1e-6) continue;
        nx /= l;
        ny /= l;
        final w0 = 0.4 + 1.4 * f0, w1 = 0.4 + 1.4 * f1;
        final a0 = ((luce * f0 * f0) * 255).round();
        final a1 = ((luce * f1 * f1) * 255).round();
        final c0 = (a0 << 24) | 0x00FFF4DC, c1 = (a1 << 24) | 0x00FFF4DC;
        v = _vertice(v, x0 + nx * w0, y0 + ny * w0, c0);
        v = _vertice(v, x0 - nx * w0, y0 - ny * w0, c0);
        v = _vertice(v, x1 + nx * w1, y1 + ny * w1, c1);
        v = _vertice(v, x0 - nx * w0, y0 - ny * w0, c0);
        v = _vertice(v, x1 - nx * w1, y1 - ny * w1, c1);
        v = _vertice(v, x1 + nx * w1, y1 + ny * w1, c1);
      }
    }
    vertici = v;
  }

  int _vertice(int v, double x, double y, int c) {
    posizioni[v * 2] = x;
    posizioni[v * 2 + 1] = y;
    colori[v] = c;
    return v + 1;
  }

  /// Il punto [u] dell'arco della meteora [m], proiettato in [_p].
  bool _punto(
      int m, double u, OrientamentoDellaCamera o, ProiezioneDelCielo p) {
    final a = _arco[m] * u;
    final c = math.cos(a), s = math.sin(a);
    final x = c * _s[m * 3] + s * _d[m * 3];
    final y = c * _s[m * 3 + 1] + s * _d[m * 3 + 1];
    final z = c * _s[m * 3 + 2] + s * _d[m * 3 + 2];
    return p.proietta(o, x, y, z, _p);
  }

  void _nasci(OrientamentoDellaCamera o, double rx, double ry, double rz) {
    var m = -1;
    for (var k = 0; k < kMeteoreInsieme; k++) {
      if (_viva[k] == 0) {
        m = k;
        break;
      }
    }
    if (m < 0) return;
    const g = math.pi / 180;
    final az = o.azimutGradi * g, alt = o.altezzaGradi * g;
    final fx = math.cos(alt) * math.sin(az);
    final fy = math.cos(alt) * math.cos(az);
    final fz = math.sin(alt);
    for (var prova = 0; prova < 10; prova++) {
      // Un punto nel riquadro, sopra l'orizzonte.
      var sx = fx + (_caso.nextDouble() - 0.5) * 0.9;
      var sy = fy + (_caso.nextDouble() - 0.5) * 0.9;
      var sz = fz + (_caso.nextDouble() - 0.5) * 0.9;
      final ls = math.sqrt(sx * sx + sy * sy + sz * sz);
      sx /= ls;
      sy /= ls;
      sz /= ls;
      if (sz < 0.05) continue;
      double dx, dy, dz;
      if (_conRadiante) {
        // Lontano dal radiante fra 10 e 120 gradi, e in fuga da lui: le
        // meteore di uno sciame compaiono in tutto il cielo.
        final coseno = sx * rx + sy * ry + sz * rz;
        if (coseno > math.cos(10 * g) || coseno < math.cos(120 * g)) continue;
        dx = sx * coseno - rx;
        dy = sy * coseno - ry;
        dz = sz * coseno - rz;
      } else {
        // Una sporadica: una direzione a caso nel piano tangente.
        final ax = _caso.nextDouble() - 0.5, ay = _caso.nextDouble() - 0.5;
        final az2 = _caso.nextDouble() - 0.5;
        final dentro = ax * sx + ay * sy + az2 * sz;
        dx = ax - sx * dentro;
        dy = ay - sy * dentro;
        dz = az2 - sz * dentro;
      }
      final ld = math.sqrt(dx * dx + dy * dy + dz * dz);
      if (ld < 1e-6) continue;
      _s[m * 3] = sx;
      _s[m * 3 + 1] = sy;
      _s[m * 3 + 2] = sz;
      _d[m * 3] = dx / ld;
      _d[m * 3 + 1] = dy / ld;
      _d[m * 3 + 2] = dz / ld;
      _arco[m] = (5 + _caso.nextDouble() * 10) * g;
      _durata[m] = 0.4 + _caso.nextDouble() * 0.5;
      _eta[m] = 0;
      _viva[m] = 1;
      nate++;
      return;
    }
  }
}
