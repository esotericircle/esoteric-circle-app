/// **DOVE STA LA LUNA ADESSO, PER LA BUSSOLA.** Ordine FX voce 3 (FX.06),
/// 16 ottobre 2026 ("Il Respiro della Luna").
///
/// Azimut e altezza della Luna sull'orizzonte di un luogo, a un istante
/// qualunque: la domanda della bussola, "da che parte guardo e quanto in
/// alto". Parte dalle due porte uniche del cielo, `Celestial.moonEquatorial`
/// (ascensione retta e declinazione GEOCENTRICHE della Luna, dalla porta
/// `IlCieloDiMeeus`) e `Celestial.equatorialToHorizontal` (la proiezione
/// sull'orizzonte), come gia' fa `_altezza` in
/// `lib/core/astro/real_time_cosmo/i_bersagli_del_cielo.dart` per lo stesso
/// corpo.
///
/// **La correzione in piu', e perche' serve qui e non altrove.** La Luna e'
/// vicina: vista dalla superficie della Terra invece che dal suo centro,
/// l'altezza appare piu' bassa fino a circa un grado, la PARALLASSE
/// diurna (Meeus, *Astronomical Algorithms*, 2a ed. 1998, cap. 40). Il primo
/// collaudo di questa funzione, contro timeanddate.com, lo ha misurato:
/// 0,78 gradi di scarto a Piacenza su un'altezza geocentrica di -30,6 gradi,
/// lo stesso numero che la formula della parallasse predice
/// (parallasse orizzontale 0,90 gradi a quella distanza, per il coseno
/// dell'altezza). Qui si corregge: altezza topocentrica = altezza
/// geocentrica - parallasse-in-altezza, con parallasse-in-altezza = asin(sin
/// (parallasse orizzontale) * cos(altezza geocentrica)) e la parallasse
/// orizzontale dalla distanza VERA (`IlCieloDiMeeus.distanzaInKm`, ordine FX
/// voce 1, stesso ordine) invece che da un valore medio fisso.
/// L'approssimazione e' di Terra sferica e osservatore al livello del mare
/// (si trascura lo schiacciamento terrestre): sull'azimut lo spostamento,
/// nella stessa approssimazione, e' nullo (la parallasse sposta la Luna
/// lungo il cerchio verticale verso il nadir, non di lato), e la misura lo
/// conferma: a Piacenza l'azimut scartava gia' di 0,01 gradi prima di questa
/// correzione.
///
/// **Nessuna rifrazione atmosferica**: quella e' un effetto diverso (la luce
/// che piega nell'aria, non la parallasse) e non si applica qui, la stessa
/// convenzione di `Celestial.equatorialToHorizontal` in tutto il resto
/// dell'app: conta solo vicino all'orizzonte, dove sposta l'altezza
/// apparente fino a circa mezzo grado.
///
/// **Verifica**: contro l'azimut e l'altezza "adesso" pubblicati da
/// timeanddate.com per tre citta' (Piacenza, New York, Sydney), lo scarto
/// massimo in gradi e' dichiarato in
/// `docs/collaudo/FX/fx03_bussola_regola_a.txt` e misurato da
/// `test/la_posizione_orizzontale_della_luna_test.dart`.
library;

import 'dart:math' as math;

import '../astro/celestial.dart';
import '../astro/meeus/il_cielo_di_meeus.dart';

/// Il raggio equatoriale della Terra, in km (lo stesso valore standard della
/// parallasse equatoriale di Meeus, appendice II; lo stesso numero di
/// `il_sorgere_della_luna.dart`, qui non importato per non legare due file
/// che rispondono a domande diverse a una sola costante privata).
const double _raggioEquatorialeTerraKm = 6378.14;

const double _gradi = math.pi / 180.0;

/// Azimut (da nord verso est) e altezza TOPOCENTRICA (corretta per la
/// parallasse diurna) della Luna, in gradi, all'istante [istante] (qualunque
/// fuso, convertito internamente a UTC), per il luogo a latitudine [lat] e
/// longitudine [lonEst] (est positiva).
({double azimutGradi, double altezzaGradi}) posizioneOrizzontaleDellaLuna(
  DateTime istante,
  double lat,
  double lonEst,
) {
  final jd = Celestial.julianDay(istante.toUtc());
  final equatoriale = Celestial.moonEquatorial(jd);
  final orizzontale = Celestial.equatorialToHorizontal(
    raDeg: equatoriale.raDeg,
    decDeg: equatoriale.decDeg,
    latDeg: lat,
    lstDeg: Celestial.localSiderealDegrees(jd, lonEst),
  );
  final distanzaKm = IlCieloDiMeeus.distanzaInKm(jd);
  final parallasseOrizzontale = math.asin(_raggioEquatorialeTerraKm / distanzaKm);
  final parallasseInAltezza = math.asin(
      math.sin(parallasseOrizzontale) * math.cos(orizzontale.altDeg * _gradi));
  return (
    azimutGradi: orizzontale.azDeg,
    altezzaGradi: orizzontale.altDeg - parallasseInAltezza / _gradi,
  );
}
