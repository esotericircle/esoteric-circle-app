import '../astro/meeus/il_cielo_di_meeus.dart';
import '../astro/il_segno_del_cielo.dart';

/// Il tema della Rivoluzione Solare di un anno.
class TemaDellaRivoluzione {
  const TemaDellaRivoluzione({
    required this.istante,
    required this.ascendente,
    required this.medioCielo,
    required this.longitudini,
  });

  /// L'istante, in UTC, in cui il Sole torna alla longitudine della nascita.
  final DateTime istante;

  /// Ascendente e Medio Cielo del luogo, in gradi eclittici.
  final double ascendente;
  final double medioCielo;

  /// Le longitudini dei corpi della lettura, in gradi.
  final Map<CorpoCeleste, double> longitudini;

  /// Il segno (0 Ariete ... 11 Pesci) di una longitudine.

  int get segnoDellAscendente =>
      IlSegnoDelCielo.dellaLongitudine(ascendente).index;
  int get segnoDelMedioCielo =>
      IlSegnoDelCielo.dellaLongitudine(medioCielo).index;

  /// **LA CASA, a case equali dall'Ascendente**: la prima casa sono i trenta
  /// gradi che seguono l'Ascendente. E' una scelta dell'app, dichiarata nella
  /// nota del metodo: si calcola sul telefono, senza tavole delle case. Il
  /// settore di trenta gradi contato dall'Ascendente e' la stessa aritmetica
  /// del segno, e passa dalla stessa porta (ordine FC voce 10).
  int casaDi(CorpoCeleste c) =>
      IlSegnoDelCielo.dellaLongitudine(longitudini[c]! - ascendente).index + 1;
}

/// **LA RIVOLUZIONE SOLARE, ordine ES voce 04.**
///
/// L'annuale dal compleanno: il tema dell'istante in cui il Sole torna al
/// grado che aveva alla nascita, nel luogo in cui la persona si trova. Tutto
/// sul telefono.
///
/// **Il Sole viene dalla porta del cielo** ([IlCieloDiMeeus], ordine FD
/// voce 02): il VSOP87D intero della Terra, cioe' Meeus al secondo d'arco.
/// Un centesimo di grado sul Sole sono quattordici minuti sull'istante del
/// ritorno, e l'Ascendente si muove di un grado ogni quattro minuti: col Sole
/// di Meeus del capitolo 25 l'istante sbagliava fino a 638 secondi, e per
/// questo dall'ordine ES al FD il Sole veniva da polinomi sul JPL DE421.
/// L'ordine FD li ha cancellati: una sola via per una posizione del cielo.
/// Venere, Giove, Saturno e la Luna dalla stessa porta, Ascendente e Medio
/// Cielo anche (tempo siderale apparente e obliquita' vera).
abstract final class LaRivoluzioneSolare {
  static double _jd(DateTime utc) => IlCieloDiMeeus.giornoGiuliano(utc);

  /// Il Sole apparente, dalla porta del cielo.
  static double sole(double jd) =>
      IlCieloDiMeeus.longitudine(CorpoCeleste.sole, jd);

  static DateTime ritorno(double soleNatale, int anno, int mese, int giorno) {
    var t = DateTime.utc(anno, mese, giorno, 12);
    for (var i = 0; i < 12; i++) {
      var d = soleNatale - sole(_jd(t));
      d = (d + 540) % 360 - 180;
      // Il Sole fa circa 0,9856 gradi al giorno.
      final passo = d / 0.985647;
      t = t.add(Duration(microseconds: (passo * 86400e6).round()));
      if (passo.abs() * 86400 < 0.1) break;
    }
    return t;
  }

  /// La longitudine del Sole alla nascita, dall'istante [nascitaUtc].
  static double soleNatale(DateTime nascitaUtc) => sole(_jd(nascitaUtc));

  /// **L'ANNO CHE CORRE**: la Rivoluzione dell'ultimo compleanno non oltre
  /// [adesso]. Prima del compleanno di quest'anno vale quella dell'anno prima.
  static DateTime ritornoInCorso(DateTime nascitaUtc, DateTime adesso) {
    final s = soleNatale(nascitaUtc);
    final quest = ritorno(s, adesso.year, nascitaUtc.month, nascitaUtc.day);
    if (!quest.isAfter(adesso.toUtc())) return quest;
    return ritorno(s, adesso.year - 1, nascitaUtc.month, nascitaUtc.day);
  }

  /// Il prossimo compleanno solare, dopo [adesso].
  static DateTime prossimoRitorno(DateTime nascitaUtc, DateTime adesso) {
    final s = soleNatale(nascitaUtc);
    final quest = ritorno(s, adesso.year, nascitaUtc.month, nascitaUtc.day);
    if (quest.isAfter(adesso.toUtc())) return quest;
    return ritorno(s, adesso.year + 1, nascitaUtc.month, nascitaUtc.day);
  }

  /// Il tema all'istante [istante] nel luogo [lat], [lon] (est positiva).
  static TemaDellaRivoluzione tema(DateTime istante, double lat, double lon) {
    final jd = _jd(istante.toUtc());
    return TemaDellaRivoluzione(
      istante: istante.toUtc(),
      ascendente: IlCieloDiMeeus.ascendente(jd, lat, lon),
      medioCielo: IlCieloDiMeeus.medioCielo(jd, lon),
      longitudini: {
        for (final c in const [
          CorpoCeleste.sole,
          CorpoCeleste.luna,
          CorpoCeleste.venere,
          CorpoCeleste.giove,
          CorpoCeleste.saturno,
        ])
          c: IlCieloDiMeeus.longitudine(c, jd),
      },
    );
  }
}
