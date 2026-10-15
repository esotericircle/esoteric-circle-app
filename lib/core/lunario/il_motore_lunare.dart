import 'dart:math' as math;

import '../astro/meeus/il_cielo_di_meeus.dart';
import '../astro/zodiac.dart';
import 'il_giorno_lunare.dart';

/// **IL MOTORE LUNARE, IN UN PUNTO SOLO.** Ordine FV voce FV.04, 15 ottobre
/// 2026 (Master V13 sezioni 41 e 43; Briefing Progetto V13 sezione 38).
///
/// Per ogni giorno, nell'ora locale del telefono: fase ed elongazione, segno
/// della Luna e ingressi, Luna fuori corso, giorno lunare, tipo biodinamico.
/// Le posizioni vengono tutte da `IlCieloDiMeeus`, nessun secondo motore. Il
/// Respiro della Luna, quando sara' costruito, chiedera' a questo file.
///
/// **STATO DI QUESTA PRIMA STESURA**: fase, elongazione, illuminazione,
/// segno e giorno lunare sono calcolati; Luna fuori corso, ingressi e tipo
/// biodinamico li completa la voce FV.04 col suo lavoro e la sua prova.
abstract final class IlMotoreLunare {
  /// Il giorno lunare di un giorno del calendario, in ora locale.
  static GiornoLunare delGiorno(DateTime giorno) {
    final mezzanotte = DateTime(giorno.year, giorno.month, giorno.day);
    final mezzogiorno = mezzanotte.add(const Duration(hours: 12));
    final e = elongazione(mezzogiorno);
    final lunaLon =
        IlCieloDiMeeus.longitudineAllIstante(CorpoCeleste.luna, mezzogiorno);
    return GiornoLunare(
      giorno: mezzanotte,
      elongazione: e,
      illuminazione: (1 - math.cos(e * math.pi / 180)) / 2,
      crescente: e < 180,
      fase: faseDi(e),
      segno: Zodiac.values[(lunaLon ~/ 30) % 12],
      cambiDiSegno: const [],
      fuoriCorso: const [],
      giornoLunare: (e / (360 / 30)).floor() % 30 + 1,
      tipoBiodinamico: null,
      lunaNuova: false,
      lunaPiena: false,
    );
  }

  /// I giorni di un mese del calendario.
  static List<GiornoLunare> delMese(int anno, int mese) {
    final giorni = DateTime(anno, mese + 1, 0).day;
    return [
      for (var g = 1; g <= giorni; g++) delGiorno(DateTime(anno, mese, g)),
    ];
  }

  /// L'elongazione della Luna dal Sole, da 0 a 360 gradi.
  static double elongazione(DateTime istante) {
    final luna =
        IlCieloDiMeeus.longitudineAllIstante(CorpoCeleste.luna, istante);
    final sole =
        IlCieloDiMeeus.longitudineAllIstante(CorpoCeleste.sole, istante);
    return (luna - sole) % 360;
  }

  /// La fase da un'elongazione: otto settori di 45 gradi centrati sulle
  /// quattro fasi principali.
  static FaseLunare faseDi(double elongazione) {
    final i = (((elongazione + 22.5) % 360) ~/ 45);
    return FaseLunare.values[i];
  }
}
