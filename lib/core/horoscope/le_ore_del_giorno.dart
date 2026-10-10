import '../astro/meeus/il_cielo_di_meeus.dart';
import '../astro/meeus/l_alba_e_il_tramonto.dart';
import '../chat/user_profile.dart';
import 'horoscope.dart';
import 'l_almanacco_cinese.dart';
import 'la_lettura_cinese.dart';

/// Un'ora del giorno, coi livelli dei quattro domini.
class OraDelGiorno {
  const OraDelGiorno({
    required this.da,
    required this.a,
    required this.livelli,
    this.signore,
    this.ramo,
    this.rahu = false,
  });

  /// L'inizio e la fine dell'ora, nell'ora del telefono.
  final DateTime da;
  final DateTime a;

  /// Il livello (1-5) di ogni dominio in quest'ora.
  final List<int> livelli;

  /// Il pianeta dell'ora planetaria (Occidentale e Vedica).
  final CorpoCeleste? signore;

  /// Il ramo dell'ora doppia cinese (0 Topo ... 11 Maiale).
  final int? ramo;

  /// Vero quando l'ora tocca il Rahu Kalam (Vedica).
  final bool rahu;
}

/// **LE ORE DEL GIORNO**, il fondatore il 1 ottobre 2026: *"vorrei
/// infografica a colori anche per oroscopo giornaliero come per
/// settimanale, mensile e annuale, se possibile. Magari inserendo le 24h e
/// indicando le ore migliori oppure una tua idea se migliore e più
/// esplicativa e adatta."*
///
/// Ogni tradizione ha le sue ore, e qui si usano quelle:
/// - **l'Occidentale, le ore planetarie**: dodici ore dall'alba al tramonto
///   e dodici dal tramonto all'alba dopo, ognuna governata da un pianeta
///   nell'ordine caldeo (Saturno, Giove, Marte, Sole, Venere, Mercurio,
///   Luna), cominciando dal signore del giorno (la domenica il Sole). William
///   Lilly, Christian Astrology (1647), libro I, la tavola delle ore
///   planetarie;
/// - **la Vedica, le hora**, le stesse ore planetarie della tradizione
///   indiana, e il Rahu Kalam, l'ottavo del giorno che la tradizione lascia a
///   Rahu (Drik Panchang);
/// - **la Cinese, le dodici ore doppie** (shichen), ognuna col suo ramo: il
///   rapporto fra il tuo animale e quello dell'ora, e il dio che il tronco
///   dell'ora e' per il tuo tronco di nascita (il tronco dell'ora si conta
///   dal tronco del giorno con la regola dei cinque topi).
///
/// Il livello dell'ora parte dal livello della scheda del Giorno e si sposta
/// di un gradino: in su nell'ora del pianeta del dominio (il Sole per la
/// Generale, Venere per l'Amore, Marte per la Carriera, Giove per la
/// Fortuna, gli stessi del livello del giorno) e nelle ore dei due benefici,
/// Giove e Venere; in giu' nell'ora di Saturno e in quella di Marte fuori
/// dalla Carriera. Nella Vedica il Rahu Kalam porta l'ora a 2.
class LeOreDelGiorno {
  const LeOreDelGiorno._();

  /// L'ordine caldeo dei pianeti delle ore.
  static const List<CorpoCeleste> caldeo = [
    CorpoCeleste.saturno,
    CorpoCeleste.giove,
    CorpoCeleste.marte,
    CorpoCeleste.sole,
    CorpoCeleste.venere,
    CorpoCeleste.mercurio,
    CorpoCeleste.luna,
  ];

  /// Il signore del giorno, dal lunedi' (1) alla domenica (7).
  static const Map<int, CorpoCeleste> signoreDelGiorno = {
    DateTime.monday: CorpoCeleste.luna,
    DateTime.tuesday: CorpoCeleste.marte,
    DateTime.wednesday: CorpoCeleste.mercurio,
    DateTime.thursday: CorpoCeleste.giove,
    DateTime.friday: CorpoCeleste.venere,
    DateTime.saturday: CorpoCeleste.saturno,
    DateTime.sunday: CorpoCeleste.sole,
  };

  /// Il pianeta di ogni dominio, come nel livello del giorno.
  static const Map<HoroscopeDomain, CorpoCeleste> pianetaDelDominio = {
    HoroscopeDomain.generale: CorpoCeleste.sole,
    HoroscopeDomain.amore: CorpoCeleste.venere,
    HoroscopeDomain.carriera: CorpoCeleste.marte,
    HoroscopeDomain.fortuna: CorpoCeleste.giove,
  };

  /// Di quanto l'ora del pianeta [p] sposta il dominio [d].
  static int spostamento(CorpoCeleste p, HoroscopeDomain d) {
    if (p == pianetaDelDominio[d] ||
        p == CorpoCeleste.giove ||
        p == CorpoCeleste.venere) {
      return 1;
    }
    if (p == CorpoCeleste.saturno ||
        (p == CorpoCeleste.marte && d != HoroscopeDomain.carriera)) {
      return -1;
    }
    return 0;
  }

  /// Le ventiquattro ore planetarie del giorno civile [giorno] al luogo
  /// [lat], [lon], dai livelli del giorno [livelliDelGiorno] (uno per
  /// dominio). Senza un luogo, o dove il Sole non sorge, le ore sono uguali
  /// dalle 6 alle 6. [rahu] e' il Rahu Kalam, per la Vedica.
  static List<OraDelGiorno> planetarie({
    required DateTime giorno,
    required List<int> livelliDelGiorno,
    double? lat,
    double? lon,
    (DateTime, DateTime)? rahu,
  }) {
    final g = DateTime(giorno.year, giorno.month, giorno.day);
    final domani = DateTime(g.year, g.month, g.day + 1);
    DateTime alba = DateTime(g.year, g.month, g.day, 6);
    DateTime tramonto = DateTime(g.year, g.month, g.day, 18);
    DateTime albaDomani = DateTime(domani.year, domani.month, domani.day, 6);
    if (lat != null && lon != null) {
      final oggi = LAlbaEIlTramonto.delGiorno(g,
          lat: lat,
          lon: lon,
          offset: g.add(const Duration(hours: 12)).timeZoneOffset);
      final poi = LAlbaEIlTramonto.delGiorno(domani,
          lat: lat,
          lon: lon,
          offset: domani.add(const Duration(hours: 12)).timeZoneOffset);
      if (oggi != null && poi != null) {
        alba = oggi.alba.toLocal();
        tramonto = oggi.tramonto.toLocal();
        albaDomani = poi.alba.toLocal();
      }
    }
    final diGiorno = tramonto.difference(alba) ~/ 12;
    final diNotte = albaDomani.difference(tramonto) ~/ 12;
    final primo = caldeo.indexOf(signoreDelGiorno[g.weekday]!);
    return [
      for (var i = 0; i < 24; i++)
        () {
          final da = i < 12
              ? alba.add(diGiorno * i)
              : tramonto.add(diNotte * (i - 12));
          final a = i < 11
              ? alba.add(diGiorno * (i + 1))
              : i == 11
                  ? tramonto
                  : i < 23
                      ? tramonto.add(diNotte * (i - 11))
                      : albaDomani;
          final signore = caldeo[(primo + i) % 7];
          final nelRahu = rahu != null &&
              da.isBefore(rahu.$2.toLocal()) &&
              a.isAfter(rahu.$1.toLocal());
          return OraDelGiorno(
            da: da,
            a: a,
            signore: signore,
            rahu: nelRahu,
            livelli: [
              for (final d in HoroscopeDomain.values)
                nelRahu
                    ? 2
                    : (livelliDelGiorno[d.index] + spostamento(signore, d))
                        .clamp(1, 5),
            ],
          );
        }(),
    ];
  }

  /// Le dodici ore doppie cinesi del giorno civile [giorno], dalle 23 del
  /// giorno prima (il Topo) alle 23 (il Maiale finisce), per chi ha
  /// l'animale [animale] e il tronco di nascita [signore].
  static List<OraDelGiorno> cinesi({
    required DateTime giorno,
    required int animale,
    required int signore,
    CourtesyForm forma = CourtesyForm.unknown,
  }) {
    final g = DateTime(giorno.year, giorno.month, giorno.day);
    final troncoDelGiorno = LAlmanaccoCinese.tronco(g);
    final troncoDelTopo = (troncoDelGiorno % 5) * 2;
    return [
      for (var k = 0; k < 12; k++)
        () {
          final da = DateTime(g.year, g.month, g.day, -1 + 2 * k);
          final a = DateTime(g.year, g.month, g.day, 1 + 2 * k);
          final rapporto = LAlmanaccoCinese.rapporto(animale, k);
          final dio = LAlmanaccoCinese.dio(signore, (troncoDelTopo + k) % 10);
          return OraDelGiorno(
            da: da,
            a: a,
            ramo: k,
            livelli: [
              LaLetturaCinese.livelloDelRapporto(rapporto),
              for (final d in HoroscopeDomain.values.skip(1))
                LaLetturaCinese.livelloDelDio(d, dio, forma: forma),
            ],
          );
        }(),
    ];
  }

  /// Le ore della veglia: una fascia migliore alle tre di notte non serve a
  /// nessuno, quindi prima si scelgono quelle che toccano le ore fra le 7 e
  /// le 23.
  static bool _nellaVeglia((DateTime, DateTime) f) {
    final g = f.$1;
    final sette = DateTime(g.year, g.month, g.day, 7);
    final ventitre = DateTime(g.year, g.month, g.day, 23);
    return f.$1.isBefore(ventitre) && f.$2.isAfter(sette);
  }

  /// Le ore migliori nel dominio [d]: le ore col livello piu' alto, unite
  /// quando si toccano, al massimo [quante] fasce, prima quelle della
  /// veglia, poi nell'ordine del giorno. **Con [adesso] si guardano solo le
  /// ore che devono ancora finire** (visto sul Realme il 1 ottobre 2026 alle
  /// 9:33: "dalle 07:06 alle 08:05" era gia' passata); se sono finite tutte,
  /// si dicono quelle del giorno intero.
  static List<(DateTime, DateTime)> migliori(
      List<OraDelGiorno> ore, HoroscopeDomain d,
      {int quante = 2, DateTime? adesso}) {
    if (adesso != null) {
      final ancora = [
        for (final o in ore)
          if (o.a.isAfter(adesso)) o,
      ];
      if (ancora.isNotEmpty) return migliori(ancora, d, quante: quante);
    }
    final massimo =
        ore.map((o) => o.livelli[d.index]).reduce((a, b) => a > b ? a : b);
    final fasce = <(DateTime, DateTime)>[];
    for (final o in ore) {
      if (o.livelli[d.index] != massimo) continue;
      if (fasce.isNotEmpty && fasce.last.$2 == o.da) {
        fasce[fasce.length - 1] = (fasce.last.$1, o.a);
      } else {
        fasce.add((o.da, o.a));
      }
    }
    final scelte = [
      ...fasce.where(_nellaVeglia),
      ...fasce.where((f) => !_nellaVeglia(f)),
    ].take(quante).toList()
      ..sort((x, y) => x.$1.compareTo(y.$1));
    return scelte;
  }
}
