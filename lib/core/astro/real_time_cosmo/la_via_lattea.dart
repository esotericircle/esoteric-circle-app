/// LA VIA LATTEA NEL CIELO VERO. Ordine FH parte 9, voce 9.1.
///
/// L'asset `assets/img/cosmo/via_lattea.webp` e' in coordinate GALATTICHE: una
/// proiezione equirettangolare 2 a 1 col piano della galassia orizzontale al
/// centro dell'immagine. Per posarlo sul cielo si ruota nelle coordinate
/// equatoriali J2000 con le tre costanti della voce 9.1: il polo nord
/// galattico ad ascensione retta 192,85948 gradi e declinazione 27,12825, il
/// polo nord celeste a longitudine galattica 122,93192.
///
/// Come si legge l'asset, misurato il 10 ottobre 2026: il centro galattico
/// (il rigonfiamento piu' luminoso, colonna 728 di 1456) sta al centro
/// dell'immagine, e la longitudine cresce verso SINISTRA, come in tutte le
/// carte galattiche (la fenditura scura del Cigno e dell'Aquila, a
/// longitudine fra 20 e 80 gradi, sta a sinistra del centro). Le righe vanno
/// da +90 a -90 gradi di latitudine; il contenuto finisce di netto a 45,5
/// gradi sopra e sotto il piano (righe 178 e 540, salto di luce 15,5 contro
/// la mediana di 1,95 fra righe vicine), e oltre e' nero.
library;

import 'dart:math' as math;

/// Il polo nord galattico J2000, ascensione retta e declinazione in gradi.
const double kRaDelPoloGalattico = 192.85948;
const double kDecDelPoloGalattico = 27.12825;

/// La longitudine galattica del polo nord celeste, in gradi.
const double kLongitudineDelPoloCeleste = 122.93192;

const double _g = math.pi / 180;

/// Da longitudine e latitudine galattiche [l] e [b] (gradi) ad ascensione
/// retta e declinazione J2000 (gradi). La prova: il centro galattico, l = 0 e
/// b = 0, cade a 266,40 e -28,94.
({double ra, double dec}) galatticheInEquatoriali(double l, double b) {
  const polo = kDecDelPoloGalattico * _g;
  final piano = b * _g;
  final d = (kLongitudineDelPoloCeleste - l) * _g;
  final sd = math.sin(polo) * math.sin(piano) +
      math.cos(polo) * math.cos(piano) * math.cos(d);
  final dec = math.asin(sd.clamp(-1.0, 1.0));
  final ra = kRaDelPoloGalattico * _g +
      math.atan2(
          math.cos(piano) * math.sin(d),
          math.cos(polo) * math.sin(piano) -
              math.sin(polo) * math.cos(piano) * math.cos(d));
  final r = (ra / _g) % 360;
  return (ra: r < 0 ? r + 360 : r, dec: dec / _g);
}

/// La colonna e la riga dell'asset (larghe [larghezza] e alte [altezza]
/// pixel) per la longitudine e latitudine galattiche [l] e [b]. La colonna
/// puo' uscire dall'immagine: il pennello la ripete.
({double u, double v}) puntoDellAsset(
        double l, double b, double larghezza, double altezza) =>
    (
      u: larghezza / 2 - l * larghezza / 360,
      v: altezza / 2 - b * altezza / 180,
    );
