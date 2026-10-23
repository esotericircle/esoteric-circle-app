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

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
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

/// Il lato del velo e' 1,05 volte il riquadro delle principali. Ordine FH
/// voce 2.2: era 1,25 nell'ordine FG, quando i veli dovevano sbordare per
/// stare su un altro piano accanto ad altri veli; adesso il velo e' uno solo
/// e non spartisce lo spazio con nessuno.
const double kAbbondanzaDelVelo = 1.05;

// ---------------------------------------------------------------------------
// ORDINE FH PARTE 1, UN VELO ALLA VOLTA
// ---------------------------------------------------------------------------

/// L'isteresi fra due veli, in gradi (voce 1.3): il velo nuovo subentra solo
/// se il centro della sua costellazione e' piu' vicino al centro del quadro di
/// almeno cinque gradi rispetto a quella che ha il velo adesso. Senza, sul
/// confine fra due segni i veli si alternerebbero a ogni tremolio della mano.
const double kIsteresiDelVelo = 5;

/// Quale velo deve stare acceso: l'indice della costellazione il cui centro
/// e' piu' vicino al centro del quadro, fra quelle col centro dentro il campo
/// (voce 1.1), tenuto conto dell'isteresi rispetto all'[attuale] (voce 1.3).
/// [distanze] porta per ogni costellazione la distanza in gradi del suo
/// centro dall'asse della camera, `double.infinity` se il centro e' fuori dal
/// quadro. Nullo se nessuna costellazione ha il centro in quadro (voce 1.4).
int? veloAlCentro(List<double> distanze, int? attuale,
    {double isteresi = kIsteresiDelVelo}) {
  int? migliore;
  var dMigliore = double.infinity;
  for (var i = 0; i < distanze.length; i++) {
    if (distanze[i] < dMigliore) {
      dMigliore = distanze[i];
      migliore = i;
    }
  }
  if (migliore == null) return null;
  if (attuale != null &&
      attuale != migliore &&
      distanze[attuale].isFinite &&
      dMigliore > distanze[attuale] - isteresi) {
    return attuale;
  }
  return migliore;
}

/// La luce dei veli in un passo di [passo] (frazione della dissolvenza di 400
/// millesimi, voce 1.2), quando deve stare acceso [scelto]. **Mai due veli
/// accesi nello stesso fotogramma** (guardia 15.1): il velo che deve
/// scomparire si spegne del tutto prima che quello nuovo cominci ad
/// accendersi, cosi' il cambio dura due dissolvenze invece di una incrociata.
void aggiornaLaLuceDeiVeli(List<double> luci, int? scelto, double passo) {
  var altroAcceso = false;
  for (var i = 0; i < luci.length; i++) {
    if (i == scelto) continue;
    luci[i] = (luci[i] - passo).clamp(0.0, 1.0);
    if (luci[i] > 0) altroAcceso = true;
  }
  if (scelto != null && !altroAcceso) {
    luci[scelto] = (luci[scelto] + passo).clamp(0.0, 1.0);
  }
}

// ---------------------------------------------------------------------------
// ORDINE FH PARTE 2, IL VELO SI ALLEGGERISCE
// ---------------------------------------------------------------------------

/// La taratura cotta nell'asset dall'Architetto (ordine FG, specifica
/// sezione 14): alfa del pixel per 0,62 e per (0,38 + 0,62 L).
const double kVelaturaCotta = 0.62;
const double kPavimentoCotto = 0.38;

/// La taratura nuova (voce 2.1): fattore 0,42 e pavimento 0,26, cioe' alfa
/// per 0,42 e per (0,26 + 0,74 L). Si applica a runtime sull'asset, che non
/// si rigenera.
const double kVelaturaNuova = 0.42;
const double kPavimentoNuovo = 0.26;

/// Il fattore che porta l'alfa di un pixel dalla taratura cotta a quella
/// nuova, data la luminanza [l] del pixel nella taratura (da 0 a 1).
double fattoreDellaVelatura(double l) {
  final cotta = kVelaturaCotta * (kPavimentoCotto + (1 - kPavimentoCotto) * l);
  final nuova = kVelaturaNuova * (kPavimentoNuovo + (1 - kPavimentoNuovo) * l);
  return nuova / cotta;
}

/// Alleggerisce i pixel di un velo, RGBA a alfa diritta, e restituisce i
/// byte nuovi. La luminanza della taratura si rilegge dal rosso, che la
/// taratura porta da 170 a 255 linearmente (specifica, sezione 14: "oro:
/// rosso da 170 a 255"); i pixel del bordo sotto 170 valgono luminanza zero.
/// Funzione pura, da lanciare in un isolato: per un velo da 786 per 820 sono
/// 644.520 pixel, e sul fotogramma bloccherebbero lo schermo.
///
/// **I byte che escono sono PREMOLTIPLICATI**, perche' `decodeImageFromPixels`
/// li legge cosi': misurato il 10 ottobre 2026, il pixel 200, 100, 40 con
/// alfa 128 consegnato a alfa diritta tornava 255, 199, 80, cioe' il velo
/// usciva piu' luminoso e piu' pieno, il contrario della voce 2.1.
Uint8List alleggerisciIPixel(Uint8List rgba) {
  final fuori = Uint8List.fromList(rgba);
  for (var i = 0; i + 3 < fuori.length; i += 4) {
    final a = fuori[i + 3];
    if (a == 0) {
      fuori[i] = 0;
      fuori[i + 1] = 0;
      fuori[i + 2] = 0;
      continue;
    }
    final l = ((fuori[i] - 170) / 85).clamp(0.0, 1.0);
    final nuova = (a * fattoreDellaVelatura(l)).round().clamp(0, 255);
    fuori[i] = (fuori[i] * nuova / 255).round();
    fuori[i + 1] = (fuori[i + 1] * nuova / 255).round();
    fuori[i + 2] = (fuori[i + 2] * nuova / 255).round();
    fuori[i + 3] = nuova;
  }
  return fuori;
}

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

  /// L'immagine che si disegna: l'asset cotto finche' [alleggerisci] non ha
  /// finito, poi la sua versione alleggerita (ordine FH voce 2.1).
  ui.Image immagine;
  final List<int> principali;

  /// Vero quando l'immagine e' gia' quella alleggerita: prima il velo non
  /// si accende, cosi' non compare mai con la taratura vecchia.
  bool leggero = false;

  /// La distanza in gradi del centro della costellazione dall'asse della
  /// camera, nell'ultimo fotogramma; infinita se il centro e' fuori quadro.
  double distanza = double.infinity;

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

  /// Porta l'immagine alla taratura nuova (ordine FH voce 2.1): legge i
  /// pixel, li alleggerisce in un isolato con [alleggerisciIPixel] e rifa'
  /// l'immagine. Una volta sola per velo.
  Future<void> alleggerisci() => _inCorso ??= _alleggerisci();
  Future<void>? _inCorso;

  Future<void> _alleggerisci() async {
    if (leggero) return;
    final dati =
        await immagine.toByteData(format: ui.ImageByteFormat.rawStraightRgba);
    if (dati == null) return;
    final nuovi = await compute(alleggerisciIPixel, dati.buffer.asUint8List());
    final pronta = Completer<ui.Image>();
    ui.decodeImageFromPixels(nuovi, immagine.width, immagine.height,
        ui.PixelFormat.rgba8888, pronta.complete);
    final leggera = await pronta.future;
    final vecchia = immagine;
    immagine = leggera;
    vecchia.dispose();
    alone?.dispose();
    alone = null;
    leggero = true;
  }

  void libera() {
    alone?.dispose();
    alone = null;
    immagine.dispose();
  }
}
