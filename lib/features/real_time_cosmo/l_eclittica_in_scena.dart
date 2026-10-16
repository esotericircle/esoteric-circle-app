/// L'ECLITTICA IN SCENA. Ordine FH parte 13.
///
/// L'eclittica e' la strada apparente del Sole fra le stelle, e vicino a lei
/// corrono anche la Luna e i pianeti. Si disegna come un filo sottile, acceso
/// appena (voce 13.1): settantatre punti, uno ogni cinque gradi di
/// longitudine eclittica a latitudine zero, portati in coordinate equatoriali
/// UNA volta con la porta del cielo, `IlCieloDiMeeus.equatoriali`, all'epoca
/// J2000 delle stelle, cosi' il filo passa fra le stelle giuste. A ogni
/// fotogramma i punti si girano con gli assi del cielo dell'istante e si
/// proiettano; il filo e' un nastro di triangoli come le linee delle figure.
///
/// L'etichetta sta sopra il punto del filo piu' vicino al centro del
/// riquadro, ed e' la [kScrittaDellEclittica]. Si spegne dal menu della
/// funzione (voce 13.2) e nasce accesa.
///
/// **L'etichetta non copre niente.** Visto sul Realme il 10 ottobre 2026: la
/// Luna corre sull'eclittica e la camera la mette al centro, quindi il punto
/// del filo piu' vicino al centro e' quasi sempre sotto la Luna, e la
/// scritta le passava sopra; all'apertura copriva anche l'indicatore della
/// costellazione. Ora la scritta va sul punto piu' vicino al centro la cui
/// scatola non tocca nessuno degli [ostacoli] (la Luna, i pianeti coi loro
/// nomi, l'indicatore); se non c'e', tace.
library;

import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' show Rect;

import '../../core/astro/meeus/il_cielo_di_meeus.dart';
import '../../core/astro/real_time_cosmo/la_camera_del_cielo.dart';

/// L'etichetta del filo (voce 13.1).
const String kScrittaDellEclittica =
    "L'eclittica, la strada del Sole, della Luna e dei pianeti";

/// QUANTO PARLA IL NOME DEL FILO. Il fondatore, 10 ottobre 2026: "e'
/// proprio necessario tenere sempre visibile la scritta? Si sovrappone a
/// tutto e crea confusione". Il nome si accende solo quando la persona accende
/// l'eclittica dal menu, per questo tempo, e poi resta il filo soltanto; la
/// riga del menu dice gia' che cos'e'.
const Duration kDurataDelNomeDellEclittica = Duration(seconds: 5);

/// Il filo: spessore e luce. Acceso appena, piu' tenue delle linee delle
/// figure.
const double kSpessoreDellEclittica = 1.0;
const double kLuceDellEclittica = 0.32;

/// Il passo dei punti in longitudine eclittica, in gradi.
const double _passo = 5;

/// Il giorno giuliano dell'epoca J2000.
const double _j2000 = 2451545.0;

class EclitticaInScena {
  EclitticaInScena() {
    const g = math.pi / 180;
    for (var k = 0; k < _punti; k++) {
      final e = IlCieloDiMeeus.equatoriali(k * _passo, 0, _j2000);
      final cd = math.cos(e.declinazione * g);
      _equatoriali[k * 3] = cd * math.cos(e.ascensioneRetta * g);
      _equatoriali[k * 3 + 1] = cd * math.sin(e.ascensioneRetta * g);
      _equatoriali[k * 3 + 2] = math.sin(e.declinazione * g);
    }
  }

  static final int _punti = (360 / _passo).round() + 1;

  final Float64List _equatoriali =
      Float64List(((360 / _passo).round() + 1) * 3);

  /// I punti proiettati, e se si proiettano.
  final Float32List _x = Float32List((360 / _passo).round() + 1);
  final Float32List _y = Float32List((360 / _passo).round() + 1);
  final Uint8List _dentro = Uint8List((360 / _passo).round() + 1);

  /// Il nastro: sei vertici per tratto.
  final Float32List posizioni = Float32List((360 / _passo).round() * 6 * 2);
  final Int32List colori = Int32List((360 / _passo).round() * 6);
  int vertici = 0;

  /// Dove va l'etichetta, e se c'e' un punto del filo nel riquadro.
  double scrittaX = 0, scrittaY = 0;
  bool scrittaVisibile = false;

  final List<double> _p = [0, 0];

  /// I versori equatoriali dei punti: le prove li leggono.
  Float64List get versoriEquatoriali => _equatoriali;

  void prepara(OrientamentoDellaCamera o, ProiezioneDelCielo p,
      Float64List assi, Float64List? poi, double t,
      {double spostamentoX = 0,
      double spostamentoY = 0,
      double mezzaScritta = 40,
      double altezzaScritta = 40,
      double margineAlto = 100,
      List<Rect> ostacoli = const []}) {
    var m0 = assi[0], m1 = assi[1], m2 = assi[2];
    var m3 = assi[3], m4 = assi[4], m5 = assi[5];
    var m6 = assi[6], m7 = assi[7], m8 = assi[8];
    if (poi != null && t > 0) {
      m0 += (poi[0] - m0) * t;
      m1 += (poi[1] - m1) * t;
      m2 += (poi[2] - m2) * t;
      m3 += (poi[3] - m3) * t;
      m4 += (poi[4] - m4) * t;
      m5 += (poi[5] - m5) * t;
      m6 += (poi[6] - m6) * t;
      m7 += (poi[7] - m7) * t;
      m8 += (poi[8] - m8) * t;
    }
    final w = p.larghezza, h = p.altezza;
    var migliore = double.infinity;
    scrittaVisibile = false;
    for (var k = 0; k < _punti; k++) {
      final ex = _equatoriali[k * 3],
          ey = _equatoriali[k * 3 + 1],
          ez = _equatoriali[k * 3 + 2];
      var x = ex * m0 + ey * m3 + ez * m6;
      var y = ex * m1 + ey * m4 + ez * m7;
      var z = ex * m2 + ey * m5 + ez * m8;
      final l = math.sqrt(x * x + y * y + z * z);
      x /= l;
      y /= l;
      z /= l;
      if (p.proietta(o, x, y, z, _p)) {
        _x[k] = _p[0] + spostamentoX;
        _y[k] = _p[1] + spostamentoY;
        _dentro[k] = 1;
        // L'etichetta sopra il punto piu' vicino al centro: intera dentro il
        // riquadro, sopra l'orizzonte e sopra il pie' di pagina, che occupa
        // il terzo basso (vista nell'anteprima fh_20 della prima stesura,
        // tagliata a destra e coperta dalle righe).
        // Vicino ai bordi la scritta scorre di lato quanto basta per stare
        // intera nel riquadro, sempre sopra il filo: cosi' ha piu' posti
        // dove andare quando il centro e' occupato.
        if (z > 0.05 &&
            _x[k] > 8 &&
            _x[k] < w - 8 &&
            _y[k] > margineAlto + altezzaScritta &&
            _y[k] < h * 0.6) {
          final cx = _x[k].clamp(mezzaScritta + 8, w - mezzaScritta - 8);
          final dx = _x[k] - w / 2, dy = _y[k] - h / 2;
          final d = dx * dx + dy * dy;
          if (d < migliore &&
              _libera(
                  scatolaDellaScritta(cx, _y[k], mezzaScritta, altezzaScritta),
                  ostacoli)) {
            migliore = d;
            scrittaX = cx;
            scrittaY = _y[k];
            scrittaVisibile = true;
          }
        }
      } else {
        _dentro[k] = 0;
      }
    }
    final colore = ((kLuceDellEclittica * 255).round() << 24) | 0x00E2B256;
    var v = 0;
    for (var k = 0; k < _punti - 1; k++) {
      if (_dentro[k] == 0 || _dentro[k + 1] == 0) continue;
      final x0 = _x[k], y0 = _y[k], x1 = _x[k + 1], y1 = _y[k + 1];
      var nx = -(y1 - y0), ny = x1 - x0;
      final l = math.sqrt(nx * nx + ny * ny);
      // Un tratto lunghissimo vuol dire che il filo passa dietro la camera.
      if (l < 1e-6 || l > w) continue;
      nx = nx / l * kSpessoreDellEclittica / 2;
      ny = ny / l * kSpessoreDellEclittica / 2;
      v = _vertice(v, x0 + nx, y0 + ny, colore);
      v = _vertice(v, x0 - nx, y0 - ny, colore);
      v = _vertice(v, x1 + nx, y1 + ny, colore);
      v = _vertice(v, x0 - nx, y0 - ny, colore);
      v = _vertice(v, x1 - nx, y1 - ny, colore);
      v = _vertice(v, x1 + nx, y1 + ny, colore);
    }
    vertici = v;
  }

  /// La scatola dell'etichetta posata sopra il punto ([x], [y]) del filo: la
  /// stessa regola del pittore, che la disegna sei punti sopra.
  static Rect scatolaDellaScritta(
          double x, double y, double mezza, double altezza) =>
      Rect.fromLTWH(x - mezza, y - altezza - 6, mezza * 2, altezza);

  static bool _libera(Rect scatola, List<Rect> ostacoli) {
    for (final o in ostacoli) {
      if (o.overlaps(scatola)) return false;
    }
    return true;
  }

  int _vertice(int v, double x, double y, int c) {
    posizioni[v * 2] = x;
    posizioni[v * 2 + 1] = y;
    colori[v] = c;
    return v + 1;
  }
}
