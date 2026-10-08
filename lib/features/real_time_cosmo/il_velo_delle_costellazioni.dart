/// IL VELO DELLE COSTELLAZIONI, ordine FG parti 4 e 5.
///
/// I dodici veli dorati sono cotti dall'Architetto in
/// `assets/img/zodiac_velo/velo_<segno>.webp` con la taratura dentro l'asset
/// (docs/Specifica_Real_Time_Cosmo.md sezione 14). **A runtime il velo si
/// disegna cosi' e basta** (voce 4.2): l'immagine come sta, con
/// `BlendMode.screen` sopra il cielo, piu' un alone che e' la stessa immagine
/// sfocata a 26 punti e miscelata al 40 per cento, dipinto UNA volta in cache.
///
/// **Le sfocature si leggono come le ha scritte l'Architetto**: 26, 3,2 e 40
/// punti sono il raggio della `GaussianBlur` di Pillow con cui ha provato la
/// taratura, che in Pillow e' la deviazione standard. Qui diventano il sigma
/// di `ImageFilter.blur`, nella stessa unita'.
///
/// Le linee degli asterismi non si disegnano (voce 1.8): il velo le
/// sostituisce.
library;

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

import '../../core/astro/real_time_cosmo/catalogo_delle_stelle.dart';
import '../../core/astro/zodiac.dart';

// ---------------------------------------------------------------------------
// PARTE 4, LA POSA
// ---------------------------------------------------------------------------

/// Le stelle principali di una costellazione: le piu' luminose, da un minimo
/// di cinque a un massimo di dodici (voce 4.4). Quante, fra cinque e dodici,
/// lo decide la soglia: tutte quelle fino a [kMagnitudineDellePrincipali],
/// che e' la magnitudine a cui una figura zodiacale si riconosce a occhio
/// nudo in un cielo di periferia.
const int kMinimoDellePrincipali = 5;
const int kMassimoDellePrincipali = 12;
const double kMagnitudineDellePrincipali = 4.5;

/// Il lato del velo e' 1,25 volte il riquadro delle principali (voce 4.4).
const double kAbbondanzaDelVelo = 1.25;

/// La dissolvenza d'entrata e d'uscita (voce 4.6).
const Duration kDissolvenzaDelVelo = Duration(milliseconds: 400);

/// Il velo del segno della persona e' piu' presente del venti per cento
/// (voce 4.7).
const double kPresenzaDelSegno = 1.2;

/// L'alone (voce 4.2).
const double kSfocaturaDellAlone = 26;
const double kMisturaDellAlone = 0.40;

/// Gli indici del catalogo delle stelle principali di [iau], gia' in ordine
/// di magnitudine crescente (il catalogo le elenca cosi').
List<int> stellePrincipali(CatalogoDelleStelle catalogo, String iau) {
  final tutte = catalogo.costellazioni[iau] ?? const <int>[];
  var quante = 0;
  while (quante < tutte.length &&
      catalogo.magnitudine[tutte[quante]] <= kMagnitudineDellePrincipali) {
    quante++;
  }
  quante = quante.clamp(kMinimoDellePrincipali, kMassimoDellePrincipali);
  return List.unmodifiable(tutte.take(math.min(quante, tutte.length)));
}

/// Dove e quanto grande si posa un velo.
class PosaDelVelo {
  const PosaDelVelo(this.centro, this.scala);
  final Offset centro;

  /// Il fattore che porta l'asset alla misura a schermo.
  final double scala;
}

/// La posa del velo dalle posizioni a schermo delle stelle principali
/// ([xs], [ys]) e dalle loro magnitudini ([mags]); [n] quante sono.
///
/// La scala e' la media geometrica di larghezza e altezza del loro
/// riquadro, per 1,25, divisa per la media geometrica delle misure
/// dell'asset (voce 4.4). Il centro e' il baricentro pesato per luminosita',
/// peso 10 alla (meno 0,4 per la magnitudine), NON il centro del riquadro
/// (voce 4.5): misurato dall'Architetto su Vergine, Capricorno ed Ariete, il
/// centro del riquadro sbilancia la figura quando una stella sta lontana
/// dalle altre.
PosaDelVelo? posaDelVelo({
  required List<double> xs,
  required List<double> ys,
  required List<double> mags,
  required int n,
  required double larghezzaAsset,
  required double altezzaAsset,
}) {
  if (n < 2) return null;
  var minX = double.infinity, maxX = -double.infinity;
  var minY = double.infinity, maxY = -double.infinity;
  var sx = 0.0, sy = 0.0, sp = 0.0;
  for (var i = 0; i < n; i++) {
    final x = xs[i], y = ys[i];
    if (x < minX) minX = x;
    if (x > maxX) maxX = x;
    if (y < minY) minY = y;
    if (y > maxY) maxY = y;
    final p = math.pow(10, -0.4 * mags[i]).toDouble();
    sx += x * p;
    sy += y * p;
    sp += p;
  }
  final lato = math.sqrt(math.max(1.0, (maxX - minX) * (maxY - minY))) *
      kAbbondanzaDelVelo;
  final scala = lato / math.sqrt(larghezzaAsset * altezzaAsset);
  return PosaDelVelo(Offset(sx / sp, sy / sp), scala);
}

// ---------------------------------------------------------------------------
// PARTE 5, LA PARALLASSE
// ---------------------------------------------------------------------------

/// Sulla stessa escursione il cielo si sposta di 3 punti e il velo di 26:
/// rapporto 1 a 8,7 (voce 5.1). L'escursione e' l'inclinazione del telefono
/// dal suo riposo, la stessa che muove i piani del cosmo in tutta l'app
/// (`ParallaxController.tiltX` e `tiltY`, fra -1 e 1).
const double kCorsaDelCielo = 3;
const double kCorsaDelVelo = 26;

/// Lo scostamento verticale e' il 35 per cento dell'orizzontale (voce 5.2).
const double kVerticaleDellaParallasse = 0.35;

/// La profondita' di campo (voce 5.3): il cielo dietro il velo e' sfocato a
/// 3,2 punti, con la maschera presa dall'alfa del velo, sfocata a 40 punti e
/// portata al 70 per cento. Si dipinge in cache quando il velo entra o esce.
const double kSfocaturaDelCielo = 3.2;
const double kSfocaturaDellaMaschera = 40;
const double kForzaDellaMaschera = 0.70;

/// La foschia in cache si rifa' anche quando il cielo sotto si e' spostato
/// di piu' di questo, in punti: oltre, la sfocatura non starebbe piu' sulle
/// stelle giuste. Non e' un rifacimento per fotogramma: col telefono fermo
/// non scatta mai.
const double kDerivaDellaFoschia = 48;

/// Lo spostamento di parallasse di un piano con corsa [corsa] per
/// l'inclinazione (tx, ty).
Offset spostamentoDiParallasse(double corsa, double tx, double ty) =>
    Offset(corsa * tx, corsa * kVerticaleDellaParallasse * ty);

// ---------------------------------------------------------------------------
// IL VELO VIVO
// ---------------------------------------------------------------------------

/// Un velo caricato: l'immagine, l'alone in cache, le principali, la luce.
class VeloDiCostellazione {
  VeloDiCostellazione({
    required this.segno,
    required this.immagine,
    required this.principali,
  })  : xs = List<double>.filled(kMassimoDellePrincipali, 0),
        ys = List<double>.filled(kMassimoDellePrincipali, 0),
        mags = List<double>.filled(kMassimoDellePrincipali, 0);

  final Zodiac segno;
  final ui.Image immagine;
  final List<int> principali;

  /// Le posizioni a schermo delle principali dell'ultimo fotogramma:
  /// riscritte, mai rigenerate.
  final List<double> xs, ys, mags;

  /// L'alone, cotto la prima volta che il velo si vede.
  ui.Image? alone;

  /// Il margine dell'alone attorno all'immagine, in pixel dell'asset.
  double margineDellAlone = 0;

  /// La luce della dissolvenza, da 0 a 1.
  double luce = 0;

  /// Vero se nell'ultimo fotogramma la costellazione era in quadro.
  bool inQuadro = false;

  /// La posa dell'ultimo fotogramma, senza parallasse.
  PosaDelVelo? posa;

  /// Cuoce l'alone UNA volta: la stessa immagine sfocata a 26 punti alla
  /// scala [scala] a cui il velo si sta mostrando (il sigma si porta nei
  /// pixel dell'asset dividendo per la scala).
  void cuociAlone(double scala) {
    if (alone != null) return;
    final sigma = kSfocaturaDellAlone / math.max(0.05, scala);
    margineDellAlone = sigma * 3;
    final w = immagine.width + 2 * margineDellAlone;
    final h = immagine.height + 2 * margineDellAlone;
    final registratore = ui.PictureRecorder();
    final tela = Canvas(registratore);
    tela.drawImage(
      immagine,
      Offset(margineDellAlone, margineDellAlone),
      Paint()..imageFilter = ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
    );
    alone = registratore.endRecording().toImageSync(w.ceil(), h.ceil());
  }

  void libera() {
    alone?.dispose();
    alone = null;
    immagine.dispose();
  }
}
