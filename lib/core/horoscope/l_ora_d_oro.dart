import '../astro/la_luna_intera.dart';
import '../astro/natal_chart.dart';

/// Un'ora d'oro: quando, quale aspetto e a quale punto natale.
class OraDOro {
  const OraDOro({
    required this.istante,
    required this.aspetto,
    required this.punto,
  });

  /// L'istante esatto, in tempo universale.
  final DateTime istante;
  final AspectType aspetto;

  /// 'sun', 'venus' o 'jupiter'.
  final String punto;

  static const Map<String, String> _alPunto = {
    'sun': 'al tuo Sole',
    'venus': 'alla tua Venere',
    'jupiter': 'al tuo Giove',
  };

  static const Map<AspectType, String> _conArticolo = {
    AspectType.conjunction: 'una congiunzione',
    AspectType.sextile: 'un sestile',
    AspectType.trine: 'un trigono',
  };

  /// "Oggi alle 15:40 la Luna forma un trigono alla tua Venere." L'ora e'
  /// quella del telefono.
  String get frase {
    final l = istante.toLocal();
    final hh = l.hour.toString().padLeft(2, '0');
    final mm = l.minute.toString().padLeft(2, '0');
    return 'Oggi alle $hh:$mm la Luna forma ${_conArticolo[aspetto]} '
        '${_alPunto[punto]} di nascita: è la tua ora d\'oro.';
  }
}

/// **L'ORA D'ORO DI OGGI, ordine ES voce 32.**
///
/// Per chi ha la carta natale, il momento del giorno in cui la Luna forma
/// l'aspetto esatto piu' favorevole al Sole, a Venere o a Giove di nascita:
/// trigono, poi sestile, poi congiunzione; a parita' di aspetto Giove, poi
/// Venere, poi il Sole; a parita' anche di questo, il primo del giorno. **Un
/// giorno senza un aspetto cosi' non ha un'ora d'oro, e non se ne inventa
/// una.**
///
/// La Luna e' quella intera di Meeus ([LaLunaIntera], un centesimo di grado
/// dal JPL): la Luna fa mezzo grado all'ora, e la Luna troncata dei transiti,
/// con i suoi quindici centesimi di scarto, sbaglierebbe l'ora di un quarto
/// d'ora. L'istante si trova col passo di un'ora e poi per bisezione, fino a
/// meno di un minuto.
abstract final class LOraDOro {
  static const List<AspectType> _ordineDegliAspetti = [
    AspectType.trine,
    AspectType.sextile,
    AspectType.conjunction,
  ];
  static const List<String> _ordineDeiPunti = ['jupiter', 'venus', 'sun'];

  static const Map<AspectType, List<double>> _angoli = {
    AspectType.trine: [120, 240],
    AspectType.sextile: [60, 300],
    AspectType.conjunction: [0],
  };

  static double _luna(DateTime utc) =>
      LaLunaIntera.longitudine(LaLunaIntera.giornoGiuliano(utc));

  /// Di quanti gradi la Luna manca (o ha passato) l'angolo [bersaglio], in
  /// (-180, 180].
  static double _scarto(DateTime utc, double bersaglio) {
    var d = (_luna(utc) - bersaglio) % 360.0;
    if (d > 180) d -= 360;
    return d;
  }

  /// Gli istanti in [da, a) in cui la Luna passa esatta su [bersaglio]. La
  /// usa anche la settimana del cielo (ordine ES voce 02).
  static List<DateTime> passaggi(DateTime da, DateTime a, double bersaglio) {
    final trovati = <DateTime>[];
    var t0 = da;
    var s0 = _scarto(t0, bersaglio);
    while (t0.isBefore(a)) {
      final t1 = t0.add(const Duration(hours: 1));
      final s1 = _scarto(t1, bersaglio);
      // La Luna va sempre avanti: il passaggio e' da negativo a positivo, e
      // uno scarto che salta da +180 a -180 non e' un passaggio.
      if (s0 <= 0 && s1 > 0 && (s1 - s0) < 10) {
        var lo = t0;
        var hi = t1;
        while (hi.difference(lo).inSeconds > 30) {
          final mid = lo.add(hi.difference(lo) ~/ 2);
          if (_scarto(mid, bersaglio) <= 0) {
            lo = mid;
          } else {
            hi = mid;
          }
        }
        final t = lo.add(hi.difference(lo) ~/ 2);
        if (!t.isBefore(da) && t.isBefore(a)) trovati.add(t);
      }
      t0 = t1;
      s0 = s1;
    }
    return trovati;
  }

  /// L'ora d'oro del giorno civile locale [giorno] per la [carta], o null.
  /// Un [giorno] in tempo universale vale come l'istante in cui il giorno
  /// comincia: serve alle prove, che girano anche su macchine in UTC.
  static OraDOro? di(NatalChart? carta, DateTime giorno) {
    if (carta == null) return null;
    final punti = {
      for (final p in carta.planets)
        if (_ordineDeiPunti.contains(p.id)) p.id: p.longitude,
    };
    if (punti.isEmpty) return null;
    final da = giorno.isUtc
        ? giorno
        : DateTime(giorno.year, giorno.month, giorno.day).toUtc();
    final a = da.add(const Duration(days: 1));
    for (final aspetto in _ordineDegliAspetti) {
      for (final id in _ordineDeiPunti) {
        final natale = punti[id];
        if (natale == null) continue;
        final istanti = <DateTime>[
          for (final ang in _angoli[aspetto]!)
            ...passaggi(da, a, (natale + ang) % 360.0),
        ]..sort();
        if (istanti.isNotEmpty) {
          return OraDOro(istante: istanti.first, aspetto: aspetto, punto: id);
        }
      }
    }
    return null;
  }
}
