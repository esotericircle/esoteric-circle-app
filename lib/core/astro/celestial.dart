import 'meeus/il_cielo_di_meeus.dart';
import 'dart:math' as math;

/// Motore astronomico leggero per il cielo reale della nascita.
///
/// Nessuna rete, nessun LLM: sono formule di posizione classiche (tempo
/// siderale, proiezione di ascensione retta e declinazione sull'orizzonte
/// dell'osservatore, posizione e fase della Luna a bassa precisione). La
/// precisione basta a mostrare le costellazioni nelle loro posizioni vere viste
/// da quel luogo, non un cielo decorativo.
class Celestial {
  Celestial._();

  static const double _deg = math.pi / 180.0;

  static double _norm360(double x) {
    var v = x % 360.0;
    if (v < 0) v += 360.0;
    return v;
  }

  /// Giorno giuliano da un istante UTC, dalla porta del cielo (ordine FD
  /// voce 02: qui stava una seconda formula del giorno giuliano).
  static double julianDay(DateTime utc) => IlCieloDiMeeus.giornoGiuliano(utc);

  /// L'OBLIQUITA' DELL'ECLITTICA in gradi, quella vera della porta del cielo.
  /// Ordine FD voce 02: qui stava una formula lineare propria.
  static double obliquitaEclittica(double jd) =>
      IlCieloDiMeeus.obliquitaVera(jd);

  /// Tempo siderale apparente di Greenwich in gradi, dalla porta del cielo.
  static double gmstDegrees(double jd) => IlCieloDiMeeus.tempoSiderale(jd);

  /// Tempo siderale locale in gradi (longitudine est positiva).
  static double localSiderealDegrees(double jd, double longitudeEast) =>
      _norm360(gmstDegrees(jd) + longitudeEast);

  /// Proietta ascensione retta e declinazione (gradi) sull'orizzonte
  /// dell'osservatore, restituendo altezza e azimut in gradi. Azimut da nord
  /// verso est.
  static HorizontalCoord equatorialToHorizontal({
    required double raDeg,
    required double decDeg,
    required double latDeg,
    required double lstDeg,
  }) {
    final ha = (lstDeg - raDeg) * _deg; // angolo orario
    final dec = decDeg * _deg;
    final lat = latDeg * _deg;
    final sinAlt = math.sin(dec) * math.sin(lat) +
        math.cos(dec) * math.cos(lat) * math.cos(ha);
    final alt = math.asin(sinAlt.clamp(-1.0, 1.0));
    final cosAz = (math.sin(dec) - math.sin(alt) * math.sin(lat)) /
        (math.cos(alt) * math.cos(lat));
    var az = math.acos(cosAz.clamp(-1.0, 1.0));
    if (math.sin(ha) > 0) az = 2 * math.pi - az;
    return HorizontalCoord(altDeg: alt / _deg, azDeg: az / _deg);
  }

  /// Longitudine eclittica del Sole in gradi.
  ///
  /// **La firma resta, il calcolo no.** Il corpo di questa funzione era una
  /// delle DUE copie della stessa formula, l'altra in `NightSky`. Adesso
  /// entrambe chiedono a `Effemeridi`, che e' la porta sola. La formula la'
  /// dentro e' identica a quella che stava qui, quindi i valori verificati il
  /// 1 agosto 2026 non si sono mossi di un millesimo.
  static double sunEclipticLongitude(double jd) =>
      IlCieloDiMeeus.longitudine(CorpoCeleste.sole, jd);

  /// Posizione equatoriale della Luna: longitudine e latitudine dalla porta
  /// del cielo (Meeus cap. 47, tabelle 47.A e 47.B intere), e la conversione
  /// con l'obliquita' vera. Ordine FD voce 02: la latitudine stava qui, con
  /// quattro termini, ed era l'unica del progetto.
  static EquatorialCoord moonEquatorial(double jd) {
    final e = IlCieloDiMeeus.equatoriali(
      IlCieloDiMeeus.longitudine(CorpoCeleste.luna, jd),
      IlCieloDiMeeus.latitudineDellaLuna(jd),
      jd,
    );
    return EquatorialCoord(raDeg: e.ascensioneRetta, decDeg: e.declinazione);
  }

  /// Illuminazione della Luna a una data: frazione illuminata [0,1] e se e' in
  /// fase crescente (lembo luminoso a destra nell'emisfero nord).
  static MoonIllumination moonIllumination(double jd) {
    // Prima queste due righe erano la TERZA copia della longitudine lunare, e
    // la piu' povera: tre termini contro i sei di `moonEquatorial` e i dieci di
    // `NightSky`. Tre troncature diverse della stessa serie davano tre Lune
    // leggermente diverse nella stessa app.
    final sun = IlCieloDiMeeus.longitudine(CorpoCeleste.sole, jd);
    final moonLon = IlCieloDiMeeus.longitudine(CorpoCeleste.luna, jd);
    final elong = _norm360(moonLon - sun); // 0 novilunio, 180 plenilunio
    final fraction = (1 - math.cos(elong * _deg)) / 2;
    final waxing = elong < 180;
    return MoonIllumination(
        fraction: fraction,
        waxing: waxing,
        elongationDeg: elong,
        frazionePerIlNome: _frazioneNelTempo(elong / 360.0, jd));
  }

  /// **LA FINESTRA DI DODICI ORE, IN ORE VERE.** Ordine FD voce 02.
  ///
  /// `MoonPhase.nomeItaliano` misura la distanza dalla fase principale in
  /// frazione del ciclo, e la soglia traduce dodici ore col moto MEDIO della
  /// Luna. Ma la Luna va da 11,8 a 15,4 gradi al giorno rispetto al Sole:
  /// alla Luna piena del 24 dicembre 2026, alle 01:28 UTC con la Luna
  /// veloce, a mezzogiorno del 24 l'elongazione era gia' oltre la soglia, e
  /// il 23 non ancora dentro: in quel mese la Luna piena non cadeva in
  /// nessun giorno. Col motore di prima, piu' grossolano, l'errore la teneva
  /// dentro per caso. Padre: commit `4f349ceb`, che ha messo la finestra di
  /// dodici ore sul ciclo medio.
  ///
  /// Qui la distanza dalla fase principale piu' vicina si riporta in tempo
  /// con la velocita' vera di quel momento, e poi in frazione del ciclo
  /// medio: la soglia del nome, letta su questa frazione, vale dodici ore
  /// vere. Serve al solo nome: la frazione e la luce restano quelle vere.
  static double _frazioneNelTempo(double f, double jd) {
    final principale = (f * 4).round() / 4;
    final scarto = f - principale; // in frazione del ciclo
    if (scarto.abs() > 0.125) return f;
    final relativa = IlCieloDiMeeus.velocitaGiornaliera(CorpoCeleste.luna, jd) -
        IlCieloDiMeeus.velocitaGiornaliera(CorpoCeleste.sole, jd);
    if (relativa <= 0) return f;
    const media = 360.0 / 29.53;
    final g = principale + scarto * media / relativa;
    return g < 0 ? g + 1 : (g >= 1 ? g - 1 : g);
  }
}

class EquatorialCoord {
  const EquatorialCoord({required this.raDeg, required this.decDeg});
  final double raDeg;
  final double decDeg;
}

class HorizontalCoord {
  const HorizontalCoord({required this.altDeg, required this.azDeg});

  /// Altezza sull'orizzonte in gradi (negativa sotto l'orizzonte).
  final double altDeg;

  /// Azimut in gradi, da nord (0) verso est (90).
  final double azDeg;
}

class MoonIllumination {
  const MoonIllumination({
    required this.fraction,
    required this.waxing,
    required this.elongationDeg,
    double? frazionePerIlNome,
  }) : _frazionePerIlNome = frazionePerIlNome;

  final double? _frazionePerIlNome;

  /// La posizione nel ciclo da cui si legge il NOME della fase: quella vera,
  /// riportata in tempo con la velocita' vera della Luna (ordine FD voce 02).
  /// Chi costruisce una luce senza saperla ha la posizione vera.
  double get frazionePerIlNome => _frazionePerIlNome ?? elongationDeg / 360.0;

  /// Frazione illuminata del disco, da 0 (nuova) a 1 (piena).
  final double fraction;

  /// Vero in fase crescente.
  final bool waxing;

  /// L'elongazione Luna meno Sole in gradi: 0 al novilunio, 180 al plenilunio.
  ///
  /// Serve a chi deve sapere DOVE si e' nel ciclo e non solo quanta luce c'e':
  /// l'illuminazione da sola non distingue una crescente da una calante, e
  /// nemmeno dice quanto manca alla sizigia. La posizione nel ciclo e'
  /// `elongationDeg / 360`.
  final double elongationDeg;
}
