/// LA VIA LATTEA IN SCENA. Ordine FH parte 9.
///
/// Una maglia fissa in coordinate galattiche, ogni cinque gradi di
/// longitudine e di latitudine fra -50 e +50 (73 colonne per 21 righe,
/// 1.533 vertici), ruotata UNA volta nelle coordinate equatoriali J2000 con
/// [galatticheInEquatoriali] (voce 9.1). A ogni fotogramma ogni vertice si
/// gira sull'orizzonte con la rotazione del cielo di quell'istante
/// ([CieloInUnIstante.assi], che viene dalla porta unica della conversione)
/// e si proietta: nove moltiplicazioni, una radice, nessuna trigonometria e
/// nessuna lista nuova. Nel riavvolgimento la rotazione si interpola fra i
/// due istanti calcolati, come i versori delle stelle.
///
/// **Il taglio dell'asset.** Il contenuto dell'immagine finisce di netto a
/// 45,5 gradi sopra e sotto il piano galattico, e in cielo il taglio
/// diventerebbe una linea. Il colore dei vertici, che moltiplica la tessitura,
/// scende da pieno a 30 gradi fino a nero a 45: con la composizione luminosa
/// della voce 9.2 il nero non aggiunge niente.
///
/// **La cucitura.** La colonna di longitudine 360 e' la stessa della
/// longitudine 0, ma la sua coordinata di tessitura sta una larghezza
/// d'immagine piu' a sinistra, e il pennello ripete l'immagine: nessun salto
/// fra l'ultima colonna e la prima (voce 9.3).
library;

import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import '../../core/astro/real_time_cosmo/la_camera_del_cielo.dart';
import '../../core/astro/real_time_cosmo/la_via_lattea.dart';
import 'lo_stile_del_cielo.dart';

/// L'opacita' della Via Lattea, in composizione luminosa (voce 9.2).
const double kOpacitaDellaViaLattea = 0.55;

/// **LA COMPOSIZIONE LUMINOSA SENZA LEGGERE LO SCHERMO.** Misurato sul Realme
/// il 10 ottobre 2026 (ordine FH, voce C5 dell'aggiunta): la corsa della
/// Macchina del tempo faceva 44 fotogrammi al secondo, e il peso era la Via
/// Lattea in modalita' `screen`, che su questo motore grafico e' una fusione
/// avanzata e legge lo schermo sotto di se': disegno medio 14,7 ms, 242
/// fotogrammi su 638 oltre i 16,7. In modalita' `plus`, che somma soltanto,
/// 7,8 ms e 13 su 369. Il risultato e' lo STESSO, non uno simile: sotto la
/// Via Lattea c'e' solo il fondo F (si disegna subito dopo di lui), e
/// screen(s, F) = s + F - s F = s (1 - F) + F, cioe' `plus` con la sorgente
/// moltiplicata per (1 - F), canale per canale. Il fattore sta nei colori dei
/// vertici, che gia' moltiplicano la tessitura.
const ui.BlendMode kComposizioneDellaViaLattea = ui.BlendMode.plus;

/// Il colore di un vertice con luce [luce] (0-255), gia' moltiplicato per
/// (1 - F): con la composizione `plus` da' lo stesso cielo di `screen`.
int coloreDelVertice(int luce) {
  int canale(int f) => (luce * (255 - f) / 255).round();
  const f = kFondoDelCielo;
  final r = (f.r * 255).round(),
      g = (f.g * 255).round(),
      b = (f.b * 255).round();
  return 0xFF000000 | (canale(r) << 16) | (canale(g) << 8) | canale(b);
}

/// Il passo della maglia in gradi, e la latitudine galattica dove finisce.
const double _passo = 5;
const double _bordo = 50;

/// La latitudine galattica dove la luce comincia a scendere, e quella dove
/// e' gia' nera: il contenuto dell'asset finisce a 45,5.
const double _pienaFinoA = 30;
const double _neraDa = 45;

/// Quanto della tessitura passa alla latitudine galattica [b]: 1 fino a 30
/// gradi dal piano, 0 da 45 in su.
double luceDellaFascia(double b) {
  final a = b.abs();
  if (a <= _pienaFinoA) return 1;
  if (a >= _neraDa) return 0;
  return 1 - (a - _pienaFinoA) / (_neraDa - _pienaFinoA);
}

class ViaLatteaInScena {
  ViaLatteaInScena(this.immagine) {
    final colonne = (360 / _passo).round() + 1;
    final righe = (2 * _bordo / _passo).round() + 1;
    final n = colonne * righe;
    _n = n;
    _equatoriali = Float32List(n * 3);
    posizioni = Float32List(n * 2);
    tessitura = Float32List(n * 2);
    colori = Int32List(n);
    _proiettato = Uint8List(n);
    final w = immagine.width.toDouble(), h = immagine.height.toDouble();
    const g = math.pi / 180;
    for (var r = 0; r < righe; r++) {
      final b = -_bordo + r * _passo;
      final luce = (luceDellaFascia(b) * 255).round();
      for (var c = 0; c < colonne; c++) {
        final l = c * _passo;
        final i = r * colonne + c;
        final e = galatticheInEquatoriali(l, b);
        final cd = math.cos(e.dec * g);
        _equatoriali[i * 3] = cd * math.cos(e.ra * g);
        _equatoriali[i * 3 + 1] = cd * math.sin(e.ra * g);
        _equatoriali[i * 3 + 2] = math.sin(e.dec * g);
        final punto = puntoDellAsset(l, b, w, h);
        tessitura[i * 2] = punto.u;
        tessitura[i * 2 + 1] = punto.v;
        colori[i] = coloreDelVertice(luce);
      }
    }
    final triangoli = (colonne - 1) * (righe - 1) * 2;
    _indiciDellaMaglia = Uint16List(triangoli * 3);
    indici = Uint16List(triangoli * 3);
    var k = 0;
    for (var r = 0; r < righe - 1; r++) {
      for (var c = 0; c < colonne - 1; c++) {
        final a = r * colonne + c, b = a + 1;
        final d = a + colonne, e = d + 1;
        for (final v in [a, b, d, b, e, d]) {
          _indiciDellaMaglia[k++] = v;
        }
      }
    }
    pennello = ui.Paint()
      ..shader = ui.ImageShader(
          immagine,
          ui.TileMode.repeated,
          ui.TileMode.clamp,
          Float64List.fromList(
              const [1.0, 0, 0, 0, 0, 1.0, 0, 0, 0, 0, 1.0, 0, 0, 0, 0, 1.0]))
      ..filterQuality = ui.FilterQuality.medium
      ..blendMode = kComposizioneDellaViaLattea
      ..color = const ui.Color.fromRGBO(255, 255, 255, kOpacitaDellaViaLattea);
  }

  /// L'asset della Via Lattea.
  final ui.Image immagine;

  /// Il pennello: lo shader nasce qui, una volta.
  late final ui.Paint pennello;

  late final int _n;
  late final Float32List _equatoriali;
  late final Float32List posizioni, tessitura;
  late final Int32List colori;
  late final Uint16List indici;
  late final Uint16List _indiciDellaMaglia;
  late final Uint8List _proiettato;
  final List<double> _p = [0, 0];

  /// Quanti vertici si sono proiettati nell'ultimo fotogramma: zero vuol
  /// dire che non c'e' niente da disegnare.
  int proiettati = 0;

  /// Gira la maglia sull'orizzonte con gli [assi] di un istante (e, nel
  /// riavvolgimento, verso quelli di [poi] per la frazione [t]) e la
  /// proietta. I triangoli con un vertice che non si proietta si schiacciano
  /// in un punto.
  void prepara(OrientamentoDellaCamera o, ProiezioneDelCielo p,
      Float64List assi, Float64List? poi, double t,
      {double spostamentoX = 0, double spostamentoY = 0}) {
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
    var quanti = 0;
    for (var i = 0; i < _n; i++) {
      final ex = _equatoriali[i * 3],
          ey = _equatoriali[i * 3 + 1],
          ez = _equatoriali[i * 3 + 2];
      var x = ex * m0 + ey * m3 + ez * m6;
      var y = ex * m1 + ey * m4 + ez * m7;
      var z = ex * m2 + ey * m5 + ez * m8;
      final l = math.sqrt(x * x + y * y + z * z);
      x /= l;
      y /= l;
      z /= l;
      if (p.proietta(o, x, y, z, _p)) {
        posizioni[i * 2] = _p[0] + spostamentoX;
        posizioni[i * 2 + 1] = _p[1] + spostamentoY;
        _proiettato[i] = 1;
        quanti++;
      } else {
        _proiettato[i] = 0;
      }
    }
    proiettati = quanti;
    for (var k = 0; k < indici.length; k += 3) {
      final a = _indiciDellaMaglia[k],
          b = _indiciDellaMaglia[k + 1],
          c = _indiciDellaMaglia[k + 2];
      if (_proiettato[a] == 1 && _proiettato[b] == 1 && _proiettato[c] == 1) {
        indici[k] = a;
        indici[k + 1] = b;
        indici[k + 2] = c;
      } else {
        indici[k] = a;
        indici[k + 1] = a;
        indici[k + 2] = a;
      }
    }
  }
}
