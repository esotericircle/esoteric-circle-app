import '../astro/celestial.dart';
import '../astro/il_segno_del_cielo.dart';
import '../astro/meeus/il_cielo_di_meeus.dart';
import '../astro/natal_chart.dart';
import '../astro/zodiac.dart';
import '../identity/birth_identity.dart';
import '../synastry/cielo_della_sinastria.dart' show AspettiDiSinastria;

/// I PUNTI DELLA SINASTRIA APPROFONDITA. Ordine FT voce FT.05, 14 ottobre
/// 2026.
///
/// **La premessa P5 dell'ordine dice "dieci punti... compreso il Nodo
/// Nord"**: presa alla lettera farebbe nove pianeti piu' il nodo, e
/// toglierebbe un pianeta ai dieci che [CorpoCeleste] gia' calcola (REGOLA
/// ZERO: il testo dell'ordine non e' affidabile, si verifica). Togliere un
/// pianeta a caso (quale?) sarebbe arbitrario e peggiore che usarli tutti:
/// qui i punti sono gli stessi dieci di [CorpoCeleste] (Sole fino a Plutone)
/// **piu'** il Nodo Nord, undici in tutto. La scelta e la sua ragione stanno
/// nel rapporto dell'ordine FT.
///
/// Non e' lo stesso elenco di `PuntoDelCielo` (Sinastria VIP, sei punti,
/// Sole/Luna/Mercurio/Venere/Marte/Ascendente): quella rimane com'e' (R9),
/// questa e' una lista sua, piu' ampia e senza Ascendente (l'approfondita
/// confronta due cieli di nascita, non chiede l'ora per forza: vedi
/// [CieloApprofondito.oraNota]).
enum PuntoDelCieloApprofondito {
  sole('Sole', '☉', CorpoCeleste.sole, femminile: false),
  luna('Luna', '☽', CorpoCeleste.luna, femminile: true),
  mercurio('Mercurio', '☿', CorpoCeleste.mercurio, femminile: false),
  venere('Venere', '♀', CorpoCeleste.venere, femminile: true),
  marte('Marte', '♂', CorpoCeleste.marte, femminile: false),
  giove('Giove', '♃', CorpoCeleste.giove, femminile: false),
  saturno('Saturno', '♄', CorpoCeleste.saturno, femminile: false),
  urano('Urano', '♅', CorpoCeleste.urano, femminile: false),
  nettuno('Nettuno', '♆', CorpoCeleste.nettuno, femminile: false),
  plutone('Plutone', '♇', CorpoCeleste.plutone, femminile: false),

  /// Non e' un [CorpoCeleste]: non ha una posizione VSOP87, solo la
  /// longitudine media (Meeus cap. 22), calcolata a parte in
  /// [CieloApprofondito._longitudineDi].
  nodoNord('Nodo Nord', '☊', null, femminile: false);

  const PuntoDelCieloApprofondito(this.nome, this.glifo, this.corpo,
      {required this.femminile});

  final String nome;
  final String glifo;

  /// Il corpo delle effemeridi, oppure nullo per il Nodo Nord.
  final CorpoCeleste? corpo;

  /// Stessa ragione di `PuntoDelCielo.femminile`: la lingua si accorda da
  /// sola solo se il genere e' dichiarato, non indovinato riga per riga.
  final bool femminile;

  String get ilSuo => femminile ? 'la sua' : 'il suo';
  String get alTuo => femminile ? 'alla tua' : 'al tuo';
  String get ilTuo => femminile ? 'la tua' : 'il tuo';
  String get alSuo => femminile ? 'alla sua' : 'al suo';
}

/// IL CIELO DI UNA PERSONA per la Sinastria approfondita: le longitudini
/// degli undici punti, e niente altro. Sempre offline, sempre deterministico
/// (R2 dell'ordine FT: nessuna chiamata a pagamento, nessuna rete).
class CieloApprofondito {
  const CieloApprofondito({
    required this.longitudini,
    required this.segnoSolare,
    required this.oraNota,
    this.nome = '',
  });

  final Map<PuntoDelCieloApprofondito, double> longitudini;
  final Zodiac segnoSolare;

  /// Qui l'ora di nascita NON condiziona nessun punto (niente Ascendente:
  /// la Sinastria approfondita non lo calcola, FT.05 non lo chiede): resta
  /// per dire alla lettura se l'ora e' nota, perche' il cielo composito
  /// (FT.07) e il momento giusto (FT.10) possono volerlo dichiarare.
  final bool oraNota;

  final String nome;

  /// Il cielo dalla sua identita' di nascita. Stessa conversione a tempo
  /// universale di `CieloDiSinastria.perIdentita`: il momento e' locale, si
  /// porta a UT con l'offset del luogo quando c'e'.
  factory CieloApprofondito.perIdentita(BirthIdentity identita,
      {String nome = ''}) {
    final luogo = identita.birthPlace;
    final momento = luogo == null
        ? DateTime.utc(
            identita.birthMoment.year,
            identita.birthMoment.month,
            identita.birthMoment.day,
            identita.birthMoment.hour,
            identita.birthMoment.minute,
          )
        : DateTime.utc(
            identita.birthMoment.year,
            identita.birthMoment.month,
            identita.birthMoment.day,
            identita.birthMoment.hour,
            identita.birthMoment.minute,
          ).subtract(Duration(minutes: luogo.utcOffsetMinutes));
    return CieloApprofondito.perNascita(
      momentoUtc: momento,
      oraNota: identita.hasBirthTime,
      nome: nome,
    );
  }

  /// Il cielo dai pezzi nudi: il momento in tempo universale, e nient'altro.
  /// Stessa scelta di `CieloDiSinastria.perNascita` (ordine BO): prende
  /// numeri, non una delle classi del luogo di nascita che convivono nel
  /// progetto.
  factory CieloApprofondito.perNascita({
    required DateTime momentoUtc,
    Zodiac? segnoDichiarato,
    String nome = '',
    bool oraNota = false,
  }) {
    final jd = Celestial.julianDay(momentoUtc);
    final tutte = IlCieloDiMeeus.tutte(jd);
    final punti = <PuntoDelCieloApprofondito, double>{};
    for (final p in PuntoDelCieloApprofondito.values) {
      final corpo = p.corpo;
      if (corpo != null) {
        final lon = tutte[corpo];
        if (lon != null) punti[p] = lon;
      }
    }
    punti[PuntoDelCieloApprofondito.nodoNord] =
        IlCieloDiMeeus.longitudineDelNodoNord(jd);
    final sole = punti[PuntoDelCieloApprofondito.sole] ?? 0;
    return CieloApprofondito(
      longitudini: punti,
      segnoSolare: segnoDichiarato ?? IlSegnoDelCielo.dellaLongitudine(sole),
      oraNota: oraNota,
      nome: nome,
    );
  }

  /// Il cielo come carta, per la stessa ruota che la Sinastria VIP gia' usa
  /// (`NatalWheel`/`NatalChart`): undici punti invece di sei, nessun
  /// Ascendente.
  NatalChart get comeCarta => NatalChart(
        sunSign: segnoSolare,
        hasTime: false,
        planets: [
          for (final p in PuntoDelCieloApprofondito.values)
            if (longitudini[p] != null)
              PlanetPosition(
                id: p.corpo?.id ?? 'north_node',
                name: p.nome,
                glyph: p.glifo,
                longitude: longitudini[p]!,
                sign: IlSegnoDelCielo.dellaLongitudine(longitudini[p]!),
              ),
        ],
      );
}

/// Un aspetto fra un punto del tuo cielo e un punto del suo, nella Sinastria
/// approfondita. Stessa forma di `AspettoDiSinastria` (Sinastria VIP), con
/// l'elenco dei punti piu' ampio: undici invece di sei.
class AspettoApprofondito {
  const AspettoApprofondito({
    required this.tuo,
    required this.suo,
    required this.tipo,
    required this.orbo,
  });

  final PuntoDelCieloApprofondito tuo;
  final PuntoDelCieloApprofondito suo;
  final AspectType tipo;

  /// Di quanto l'aspetto e' lontano dall'angolo esatto, in gradi.
  final double orbo;

  /// Quanto e' forte: uno all'angolo esatto, zero al limite dell'orbo.
  double forzaCon(double orboAmmesso) =>
      orboAmmesso <= 0 ? 0 : (1 - orbo / orboAmmesso).clamp(0.0, 1.0);

  /// "la tua Venere in trigono alla sua Luna": stesso impianto del
  /// `laFrase` della Sinastria VIP, ma qui nessuno dei due lati e' mai un
  /// VIP con un nome pubblico: sono sempre le due persone vere, "tu" e
  /// "lei/lui" (il nome arriva da chi monta la frase, non da qui).
  String frase(String nomeTuo, String nomeSuo) =>
      '${tuo.femminile ? "la" : "il"} $nomeTuo ${tuo.ilTuo.split(' ').last} '
      'è in ${tipo.italianName.toLowerCase()} '
      '${suo.femminile ? "alla" : "al"} $nomeSuo ${suo.nome}';
}

/// GLI ASPETTI FRA DUE CIELI, Sinastria approfondita.
///
/// **Gli orbi sono quelli gia' dichiarati e approvati per la sinastria**
/// (`AspettiDiSinastria.orbo`, ordine BO/CC): sei gradi sugli aspetti
/// maggiori, quattro sul sestile. Qui non nasce una seconda tavola di orbi:
/// la Sinastria approfondita e' la stessa tradizione, su piu' punti.
class AspettiApprofonditi {
  const AspettiApprofonditi._();

  static Map<AspectType, double> get orbo => AspettiDiSinastria.orbo;

  /// Gli aspetti fra i due cieli, dal piu' stretto al piu' largo.
  /// Deterministico: stessa coppia di cieli, stesso elenco, sempre.
  static List<AspettoApprofondito> fra(
      CieloApprofondito tuo, CieloApprofondito suo) {
    final trovati = <AspettoApprofondito>[];
    for (final a in PuntoDelCieloApprofondito.values) {
      final la = tuo.longitudini[a];
      if (la == null) continue;
      for (final b in PuntoDelCieloApprofondito.values) {
        final lb = suo.longitudini[b];
        if (lb == null) continue;
        for (final tipo in AspectType.values) {
          final candidato =
              ChartAspect(aLongitude: la, bLongitude: lb, type: tipo);
          if (candidato.orbe <= orbo[tipo]!) {
            trovati.add(AspettoApprofondito(
                tuo: a, suo: b, tipo: tipo, orbo: candidato.orbe));
            break;
          }
        }
      }
    }
    trovati.sort((x, y) {
      final perOrbo = x.orbo.compareTo(y.orbo);
      if (perOrbo != 0) return perOrbo;
      final perSuo = x.suo.index.compareTo(y.suo.index);
      if (perSuo != 0) return perSuo;
      return x.tuo.index.compareTo(y.tuo.index);
    });
    return trovati;
  }
}
