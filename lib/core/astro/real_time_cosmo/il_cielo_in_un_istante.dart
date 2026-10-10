/// IL CIELO IN UN ISTANTE, il motore del Real Time Cosmo. Ordine FG parti 2 e 3.
///
/// **Un motore solo per i tre cieli** (voce 3.1): il cielo di adesso, il cielo
/// della nascita e ogni istante del riavvolgimento sono la stessa funzione,
/// [CieloInUnIstante.calcola], con un altro istante e un altro luogo.
///
/// **Le due porte che usa, e che non duplica.** Le stelle passano da
/// `Celestial.equatorialToHorizontal` (voce 2.7), i corpi del sistema solare da
/// `IlCieloDiMeeus` (voce 2.8): longitudine e latitudine eclittiche, poi
/// `IlCieloDiMeeus.equatoriali`, poi la stessa `equatorialToHorizontal`. La
/// Luna da `Celestial.moonEquatorial` e la sua fase da
/// `Celestial.moonIllumination`, che a loro volta chiedono a Meeus.
///
/// **Le stelle sono alle coordinate J2000 del catalogo, senza precessione.**
/// Nel 2026 la precessione le ha spostate di circa 0,36 gradi, per una nascita
/// del 1960 di circa 0,9: a settanta gradi di campo sono due e quattro punti
/// sullo schermo. La precessione vive in Meeus e non e' esposta; scriverla qui
/// sarebbe una seconda porta. Lo dichiara il pannello Fonti e metodo.
///
/// Il risultato e' fatto di versori nell'orizzonte locale: x verso est, y
/// verso nord, z verso lo zenit. La camera (`la_camera_del_cielo.dart`) li
/// proietta; nessuno li riconverte.
library;

import 'dart:math' as math;
import 'dart:typed_data';

import '../celestial.dart';
import '../meeus/il_cielo_di_meeus.dart';
import '../zodiac.dart';
import 'catalogo_delle_stelle.dart';

/// Un corpo del sistema solare a un istante.
class CorpoNelCielo {
  const CorpoNelCielo({
    required this.corpo,
    required this.x,
    required this.y,
    required this.z,
    required this.magnitudine,
  });

  final CorpoCeleste corpo;
  final double x, y, z;

  /// Magnitudine TIPICA del corpo, non calcolata: serve solo a dare al punto
  /// la sua grandezza. La magnitudine vera di un pianeta cambia con la
  /// distanza e la fase (Marte va da -2,9 a +1,8); qui e' un ripiego
  /// dichiarato, perche' a schermo conta l'ordine di grandezza.
  final double magnitudine;

  double get altezzaGradi => math.asin(z.clamp(-1.0, 1.0)) * 180 / math.pi;
  double get azimutGradi {
    final a = math.atan2(x, y) * 180 / math.pi;
    return a < 0 ? a + 360 : a;
  }

  bool get sopraLOrizzonte => z > 0;
}

/// Le magnitudini tipiche dei corpi disegnati (vedi [CorpoNelCielo]).
const Map<CorpoCeleste, double> kMagnitudineTipica = {
  CorpoCeleste.sole: -26.7,
  CorpoCeleste.luna: -12.0,
  CorpoCeleste.mercurio: 0.0,
  CorpoCeleste.venere: -4.2,
  CorpoCeleste.marte: 0.5,
  CorpoCeleste.giove: -2.3,
  CorpoCeleste.saturno: 0.6,
};

/// I pianeti "brillanti" della riga che invita a puntarli (voce 6.4): quelli
/// che a occhio nudo si vedono anche in citta'.
const Set<CorpoCeleste> kPianetiBrillanti = {
  CorpoCeleste.venere,
  CorpoCeleste.marte,
  CorpoCeleste.giove,
  CorpoCeleste.saturno,
};

/// La costellazione IAU di ogni segno e il nome del suo velo.
extension CostellazioneDelSegno on Zodiac {
  String get sigleIau => switch (this) {
        Zodiac.aries => 'Ari',
        Zodiac.taurus => 'Tau',
        Zodiac.gemini => 'Gem',
        Zodiac.cancer => 'Cnc',
        Zodiac.leo => 'Leo',
        Zodiac.virgo => 'Vir',
        Zodiac.libra => 'Lib',
        Zodiac.scorpio => 'Sco',
        Zodiac.sagittarius => 'Sgr',
        Zodiac.capricorn => 'Cap',
        Zodiac.aquarius => 'Aqr',
        Zodiac.pisces => 'Psc',
      };

  /// Il segno con l'aggettivo possessivo: "Il tuo Leone", ma "I tuoi
  /// Gemelli" e "I tuoi Pesci", che sono plurali. Visto sul Realme l'8
  /// ottobre 2026: la freccia diceva "Il tuo Gemelli".
  String get ilTuo => this == Zodiac.gemini || this == Zodiac.pisces
      ? 'I tuoi $italianName'
      : 'Il tuo $italianName';

  /// Il file del velo, `assets/img/zodiac_velo/velo_<segno>.webp`.
  String get assetDelVelo =>
      'assets/img/zodiac_velo/velo_${italianName.toLowerCase()}.webp';
}

class CieloInUnIstante {
  CieloInUnIstante._({
    required this.jd,
    required this.latitudine,
    required this.longitudine,
    required this.x,
    required this.y,
    required this.z,
    required this.corpi,
    required this.illuminazioneDellaLuna,
    required this.lunaCrescente,
    required this.elongazioneDellaLuna,
    required this.tempoSideraleLocale,
    required this.assi,
  });

  final double jd;
  final double latitudine;
  final double longitudine;

  /// Versori delle stelle, nell'ordine del catalogo.
  final Float32List x, y, z;

  /// Sole, Luna e i cinque pianeti a occhio nudo.
  final List<CorpoNelCielo> corpi;

  final double illuminazioneDellaLuna;
  final bool lunaCrescente;
  final double elongazioneDellaLuna;
  final double tempoSideraleLocale;

  /// I tre assi equatoriali J2000 visti dall'orizzonte (ordine FH parte 9):
  /// i versori orizzontali dell'asse verso ascensione retta 0, di quello
  /// verso 90 gradi e del polo nord celeste, nove numeri in fila. La
  /// conversione da equatoriali a orizzontali e' una rotazione, e queste sono
  /// le sue tre colonne: chi deve girare molti punti fissi del cielo, come la
  /// maglia della Via Lattea, moltiplica invece di chiamare la porta per
  /// ognuno. Vengono dalla porta stessa, `Celestial.equatorialToHorizontal`.
  final Float64List assi;

  CorpoNelCielo corpo(CorpoCeleste c) => corpi.firstWhere((k) => k.corpo == c);

  static const List<CorpoCeleste> _disegnati = [
    CorpoCeleste.sole,
    CorpoCeleste.luna,
    CorpoCeleste.mercurio,
    CorpoCeleste.venere,
    CorpoCeleste.marte,
    CorpoCeleste.giove,
    CorpoCeleste.saturno,
  ];

  static ({double x, double y, double z}) _versore(HorizontalCoord h) {
    final alt = h.altDeg * math.pi / 180;
    final az = h.azDeg * math.pi / 180;
    final c = math.cos(alt);
    return (x: c * math.sin(az), y: c * math.cos(az), z: math.sin(alt));
  }

  /// Il cielo vero per il giorno giuliano [jd] (tempo universale), visto dalla
  /// latitudine e longitudine (est positiva) in gradi.
  static CieloInUnIstante calcola(
    CatalogoDelleStelle catalogo, {
    required double jd,
    required double latitudine,
    required double longitudine,
  }) {
    final lst = Celestial.localSiderealDegrees(jd, longitudine);
    final n = catalogo.numeroDiStelle;
    final x = Float32List(n), y = Float32List(n), z = Float32List(n);
    for (var i = 0; i < n; i++) {
      final v = _versore(Celestial.equatorialToHorizontal(
        raDeg: catalogo.raGradi[i],
        decDeg: catalogo.decGradi[i],
        latDeg: latitudine,
        lstDeg: lst,
      ));
      x[i] = v.x;
      y[i] = v.y;
      z[i] = v.z;
    }

    final corpi = <CorpoNelCielo>[];
    for (final c in _disegnati) {
      final double ra, dec;
      if (c == CorpoCeleste.luna) {
        final e = Celestial.moonEquatorial(jd);
        ra = e.raDeg;
        dec = e.decDeg;
      } else {
        final e = IlCieloDiMeeus.equatoriali(
          IlCieloDiMeeus.longitudine(c, jd),
          IlCieloDiMeeus.latitudine(c, jd),
          jd,
        );
        ra = e.ascensioneRetta;
        dec = e.declinazione;
      }
      final v = _versore(Celestial.equatorialToHorizontal(
          raDeg: ra, decDeg: dec, latDeg: latitudine, lstDeg: lst));
      corpi.add(CorpoNelCielo(
          corpo: c,
          x: v.x,
          y: v.y,
          z: v.z,
          magnitudine: kMagnitudineTipica[c]!));
    }

    final assi = Float64List(9);
    const versi = [(0.0, 0.0), (90.0, 0.0), (0.0, 90.0)];
    for (var k = 0; k < 3; k++) {
      final v = _versore(Celestial.equatorialToHorizontal(
          raDeg: versi[k].$1,
          decDeg: versi[k].$2,
          latDeg: latitudine,
          lstDeg: lst));
      assi[k * 3] = v.x;
      assi[k * 3 + 1] = v.y;
      assi[k * 3 + 2] = v.z;
    }

    final luna = Celestial.moonIllumination(jd);
    return CieloInUnIstante._(
      jd: jd,
      latitudine: latitudine,
      longitudine: longitudine,
      x: x,
      y: y,
      z: z,
      corpi: List.unmodifiable(corpi),
      illuminazioneDellaLuna: luna.fraction,
      lunaCrescente: luna.waxing,
      elongazioneDellaLuna: luna.elongationDeg,
      tempoSideraleLocale: lst,
      assi: assi,
    );
  }
}
