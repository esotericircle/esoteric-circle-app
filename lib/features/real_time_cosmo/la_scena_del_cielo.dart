/// LA SCENA DEL CIELO DEL REAL TIME COSMO. Ordine FG parte 2.
///
/// Prepara, per un fotogramma, i numeri che il pittore consegna alla scheda
/// grafica in UNA chiamata (voce 2.1): per ogni stella in quadro una
/// trasformazione (scala e posizione dello sprite) e un colore. **I buffer
/// nascono una volta sola**, quando nasce la scena, alla misura del catalogo
/// intero; a ogni fotogramma si riscrivono, mai si rigenerano. Il pittore ne
/// passa la parte piena come vista (`sublistView`), che non copia niente.
///
/// Il precedente e' la spirale dei sigilli
/// (`lib/features/sigilli/spirale_di_stelle.dart`), che chiama `drawAtlas` con
/// le liste di `RSTransform` costruite a ogni fotogramma: andava bene per
/// duemilaseicento stelle tutte uguali e d'oro, coi colori dentro l'immagine.
/// Qui le stelle sono cinquemila, ognuna col suo colore dall'indice B-V, e il
/// cammino per fotogramma non deve creare liste (voce 2.1): per questo la
/// scena usa la forma grezza della stessa chiamata, `drawRawAtlas`, con array
/// tipizzati riusati e un array di colori. Il modo e' lo stesso, la forma
/// cambia per la ragione detta (voce 2.2).
///
/// La scena e' fuori dal pittore anche perche' le prove la misurano senza
/// disegnare: quante stelle sono in quadro, dove cade un corpo.
library;

import 'dart:math' as math;
import 'dart:typed_data';

import '../../core/astro/real_time_cosmo/catalogo_delle_stelle.dart';
import '../../core/astro/real_time_cosmo/il_cielo_in_un_istante.dart';
import '../../core/astro/real_time_cosmo/la_camera_del_cielo.dart';
import '../../core/astro/real_time_cosmo/la_griglia_del_tocco.dart';
import 'lo_stile_del_cielo.dart';

/// Il lato dello sprite della stella, in pixel dell'immagine.
const double kLatoDelloSprite = 64;

/// Il raggio della stella dentro lo sprite: lo sprite e' tutto alone, e il
/// suo bordo vale il raggio della voce 2.4.
const double kRaggioNelloSprite = kLatoDelloSprite / 2;

/// Oltre questo margine fuori dallo schermo una stella non si disegna.
const double kMargineDelQuadro = 24;

class ScenaDelCielo {
  ScenaDelCielo(this.catalogo)
      : trasformazioni = Float32List(catalogo.numeroDiStelle * 4),
        rettangoli = Float32List(catalogo.numeroDiStelle * 4),
        colori = Int32List(catalogo.numeroDiStelle),
        xSchermo = Float32List(catalogo.numeroDiStelle),
        ySchermo = Float32List(catalogo.numeroDiStelle),
        inQuadro = Int32List(catalogo.numeroDiStelle),
        _coloriPieni = Int32List(catalogo.numeroDiStelle),
        _raggi = Float32List(catalogo.numeroDiStelle) {
    // Il rettangolo dello sprite e' lo stesso per tutte: si scrive una volta.
    for (var i = 0; i < catalogo.numeroDiStelle; i++) {
      rettangoli[i * 4 + 2] = kLatoDelloSprite;
      rettangoli[i * 4 + 3] = kLatoDelloSprite;
      _coloriPieni[i] =
          coloreDellaStella(catalogo.indiceDiColore[i]).toARGB32() & 0x00FFFFFF;
      _raggi[i] = raggioDellaStella(catalogo.magnitudine[i]);
    }
  }

  final CatalogoDelleStelle catalogo;

  /// Quattro numeri per stella disegnata: scos, ssin, tx, ty.
  final Float32List trasformazioni;
  final Float32List rettangoli;
  final Int32List colori;

  /// La posizione a schermo di ogni stella in quadro, per il tocco.
  final Float32List xSchermo;
  final Float32List ySchermo;

  /// Gli indici del catalogo delle stelle in quadro, nell'ordine disegnato.
  final Int32List inQuadro;

  /// Il colore senza alfa di ogni stella, calcolato una volta.
  final Int32List _coloriPieni;
  final Float32List _raggi;

  /// Quante stelle ha disegnato l'ultimo fotogramma.
  int quante = 0;

  /// Quante di quelle hanno luce piena o quasi (oltre meta'): i "punti
  /// luminosi" della densita' della voce 2.5.
  int luminose = 0;

  final List<double> _punto = [0, 0];

  /// Riempie i buffer per il cielo [cielo] (o, nel riavvolgimento, per il
  /// punto [t] fra [cielo] e [poi]) visto con [orientamento] e [proiezione].
  /// [spostamento] e' lo scostamento di parallasse del piano del cielo (parte
  /// 5), in punti.
  void prepara({
    required CieloInUnIstante cielo,
    CieloInUnIstante? poi,
    double t = 0,
    required OrientamentoDellaCamera orientamento,
    required ProiezioneDelCielo proiezione,
    double spostamentoX = 0,
    double spostamentoY = 0,
  }) {
    final limite = magnitudineLimite(proiezione.campoGradi);
    final w = proiezione.larghezza, h = proiezione.altezza;
    final mag = catalogo.magnitudine;
    final ax = cielo.x, ay = cielo.y, az = cielo.z;
    final b = poi;
    var n = 0;
    var forti = 0;
    for (var i = 0; i < catalogo.numeroDiStelle; i++) {
      // Le stelle sono in ordine di magnitudine: oltre il limite non ce ne
      // sono piu' di accese, e il giro si ferma.
      final m = mag[i];
      if (m > limite) break;
      double x = ax[i], y = ay[i], z = az[i];
      if (b != null && t > 0) {
        x += (b.x[i] - x) * t;
        y += (b.y[i] - y) * t;
        z += (b.z[i] - z) * t;
        final l = math.sqrt(x * x + y * y + z * z);
        if (l > 0) {
          x /= l;
          y /= l;
          z /= l;
        }
      }
      if (!proiezione.proietta(orientamento, x, y, z, _punto)) continue;
      final px = _punto[0] + spostamentoX, py = _punto[1] + spostamentoY;
      if (px < -kMargineDelQuadro ||
          py < -kMargineDelQuadro ||
          px > w + kMargineDelQuadro ||
          py > h + kMargineDelQuadro) {
        continue;
      }
      var luce = luceDellaStella(m, limite);
      if (z < 0) luce *= kLuceSottoLOrizzonte;
      if (luce <= 0) continue;
      final scala = _raggi[i] / kRaggioNelloSprite;
      final o = n * 4;
      trasformazioni[o] = scala;
      trasformazioni[o + 1] = 0;
      trasformazioni[o + 2] = px - kRaggioNelloSprite * scala;
      trasformazioni[o + 3] = py - kRaggioNelloSprite * scala;
      colori[n] = ((luce * 255).round() << 24) | _coloriPieni[i];
      xSchermo[n] = px;
      ySchermo[n] = py;
      inQuadro[n] = i;
      if (luce > 0.5 && px >= 0 && py >= 0 && px <= w && py <= h) forti++;
      n++;
    }
    quante = n;
    luminose = forti;
  }

  /// La stella accesa piu' vicina al punto (sx, sy) dello schermo, entro
  /// [raggio] punti; -1 se nessuna (voce 2.12). Non ricalcola il cielo: chiede
  /// alla [griglia] le poche stelle della regione di cielo sotto il dito e
  /// proietta soltanto quelle.
  int piuVicina({
    required double sx,
    required double sy,
    required double raggio,
    required GrigliaDelTocco griglia,
    required CieloInUnIstante cielo,
    required OrientamentoDellaCamera orientamento,
    required ProiezioneDelCielo proiezione,
    double spostamentoX = 0,
    double spostamentoY = 0,
  }) {
    final dir = proiezione.direzione(
        orientamento, sx - spostamentoX, sy - spostamentoY);
    if (dir == null) return -1;
    final limite = magnitudineLimite(proiezione.campoGradi);
    final raggioGradi = raggio / proiezione.puntiPerGrado + 1;
    var migliore = -1;
    var d2Migliore = raggio * raggio;
    ultimiCandidati = 0;
    for (final i in griglia.vicine(dir.x, dir.y, dir.z, raggioGradi)) {
      ultimiCandidati++;
      if (catalogo.magnitudine[i] > limite) continue;
      if (!proiezione.proietta(
          orientamento, cielo.x[i], cielo.y[i], cielo.z[i], _punto)) {
        continue;
      }
      final dx = _punto[0] + spostamentoX - sx;
      final dy = _punto[1] + spostamentoY - sy;
      final d2 = dx * dx + dy * dy;
      if (d2 <= d2Migliore) {
        d2Migliore = d2;
        migliore = i;
      }
    }
    return migliore;
  }

  /// Quante stelle ha guardato l'ultimo tocco: la misura che la griglia
  /// serve (poche decine contro cinquemila).
  int ultimiCandidati = 0;
}
