import '../astro/meeus/il_cielo_di_meeus.dart';
import '../astro/natal_chart.dart';
import '../chat/la_marca_del_genere.dart';
import '../synastry/cielo_del_giorno_sulla_coppia.dart';
import 'cielo_evolutivo.dart';
import 'la_lettura_evolutiva.dart';
import 'legame_e_eta.dart';

/// I contatti di una coppia nella forma della porta sola del cielo del
/// giorno (`MoltiplicatoreCeleste.accensione`), coi capitoli a cui
/// appartengono.
List<({AspettoEvolutivo aspetto, Capitolo capitolo})> _contattiDeiCapitoli(
    CieloEvolutivo tuo, CieloEvolutivo suo, Set<Capitolo> capitoli) {
  final fuori = <({AspettoEvolutivo aspetto, Capitolo capitolo})>[];
  for (final a in AspettiEvolutivi.fra(tuo, suo)) {
    for (final c in capitoli) {
      if (c.tocca(a)) {
        fuori.add((aspetto: a, capitolo: c));
        break;
      }
    }
  }
  return fuori;
}

List<({double peso, List<double> gradi})> _perLaPorta(
        List<({AspettoEvolutivo aspetto, Capitolo capitolo})> contatti,
        CieloEvolutivo tuo,
        CieloEvolutivo suo) =>
    [
      for (final x in contatti)
        (
          peso: x.aspetto.forzaCon(AspettiEvolutivi.orbo[x.aspetto.tipo]!),
          gradi: [
            tuo.longitudini[x.aspetto.tuo]!,
            suo.longitudini[x.aspetto.suo]!,
          ],
        ),
    ];

CorpoCeleste? _corpo(String nome) {
  for (final c in CorpoCeleste.values) {
    if (c.name == nome) return c;
  }
  return null;
}

String _pulito(String testo, String nomeSuo) =>
    LaMarcaDelGenere.risolvi(testo.replaceAll('{nome}', nomeSuo));

/// **OGGI FRA VOI.** Ordine FT voce FT.09 (Briefing di Progetto V13 sezione
/// 57.2: "da' a tutti e due una ragione per tornare ogni giorno").
///
/// **NESSUNA SECONDA PORTA**: il calcolo e' quello della Sinastria VIP
/// (`MoltiplicatoreCeleste.accensione`, il cielo del giorno sulla coppia,
/// ordine BO voce 12), usato coi contatti dei cinque capitoli: oggi, quale
/// pianeta passa sui gradi dove i vostri cieli si toccano, e in quale
/// capitolo. I transiti che si guardano sono quelli che cambiano da un
/// giorno all'altro abbastanza da dire qualcosa di oggi: dal Sole a Saturno.
/// Il testo ruota col giorno, senza modello.
class OggiFraVoi {
  const OggiFraVoi({
    required this.transito,
    required this.capitolo,
    required this.testo,
  });

  /// Il corpo che oggi accende di piu'; nullo in un giorno quieto.
  final CorpoCeleste? transito;
  final Capitolo? capitolo;
  final String testo;

  static const List<CorpoCeleste> transitiGuardati = [
    CorpoCeleste.sole,
    CorpoCeleste.luna,
    CorpoCeleste.mercurio,
    CorpoCeleste.venere,
    CorpoCeleste.marte,
    CorpoCeleste.giove,
    CorpoCeleste.saturno,
  ];

  static OggiFraVoi per({
    required CieloEvolutivo tuo,
    required CieloEvolutivo suo,
    required String nomeSuo,
    required DateTime giorno,
    required CorpusDellaSinastria corpus,
  }) {
    final contatti = _contattiDeiCapitoli(tuo, suo, Capitolo.values.toSet());
    final esito = MoltiplicatoreCeleste.accensione(
      contatti: _perLaPorta(contatti, tuo, suo),
      giorno: giorno,
      transiti: transitiGuardati.toSet(),
    );
    final indice = _giornoDellAnno(giorno);
    if (esito.transito == null || esito.contatto == null) {
      final v = corpus['keplero_oggi_momento|oggi nessuno|testo']!;
      return OggiFraVoi(
          transito: null,
          capitolo: null,
          testo: _pulito(v[indice % v.length], nomeSuo));
    }
    final capitolo = contatti[esito.contatto!].capitolo;
    final v = corpus[
        'keplero_oggi_momento|oggi ${esito.transito!.name} ${capitolo.name}|testo']!;
    return OggiFraVoi(
      transito: esito.transito,
      capitolo: capitolo,
      testo: _pulito(v[indice % v.length], nomeSuo),
    );
  }

  static int _giornoDellAnno(DateTime g) => DateTime.utc(g.year, g.month, g.day)
      .difference(DateTime.utc(g.year))
      .inDays;
}

/// Un giorno favorevole del Momento giusto.
class GiornoFavorevole {
  const GiornoFavorevole({
    required this.giorno,
    required this.transito,
    required this.testo,
  });

  final DateTime giorno;
  final CorpoCeleste transito;
  final String testo;
}

/// **IL MOMENTO GIUSTO.** Ordine FT voce FT.10, esclusiva del piano Adepto.
///
/// I giorni in cui il cielo e' piu' favorevole alla coppia per il legame
/// scelto. **Le scelte di Code, dichiarate**:
/// - **la finestra**: i prossimi sessanta giorni (abbastanza per un
///   progetto, abbastanza vicino da potersi organizzare);
/// - **i pianeti favorevoli**: Sole, Luna, Mercurio, Venere e Giove; Marte e
///   Saturno no, perche' la tradizione li legge come spinta e prova, non
///   come favore;
/// - **gli aspetti**: solo congiunzione, trigono e sestile, cioe' quelli che
///   la tradizione chiama facili;
/// - **i capitoli di ogni legame**: amore, attrazione ed emozioni; amicizia,
///   mente ed emozioni; famiglia, emozioni e durata; lavoro, mente e durata;
/// - **quanti giorni**: i tre piu' accesi, ad almeno tre giorni l'uno
///   dall'altro, in ordine di data.
///
/// **Consapevolezza, mai fatalismo**: si dice perche' un giorno e' favorevole
/// e cosa farne; nessun giorno e' detto sbagliato o pericoloso.
abstract final class IlMomentoGiusto {
  static const int giorniDaGuardare = 60;
  static const int giorniFraUnoEAltro = 3;

  static const List<CorpoCeleste> transitiFavorevoli = [
    CorpoCeleste.sole,
    CorpoCeleste.luna,
    CorpoCeleste.mercurio,
    CorpoCeleste.venere,
    CorpoCeleste.giove,
  ];

  static Set<Capitolo> capitoliDi(Legame legame) => switch (legame) {
        Legame.amore => {Capitolo.attrazione, Capitolo.emozioni},
        Legame.amicizia => {Capitolo.mente, Capitolo.emozioni},
        Legame.famiglia => {Capitolo.emozioni, Capitolo.durata},
        Legame.lavoro => {Capitolo.mente, Capitolo.durata},
      };

  /// I giorni favorevoli, oppure una lista vuota se nessuno spicca (il
  /// testo di quel caso lo da' [testoSenzaGiorni]).
  static List<GiornoFavorevole> per({
    required CieloEvolutivo tuo,
    required CieloEvolutivo suo,
    required String nomeSuo,
    required Legame legame,
    required DateTime da,
    required CorpusDellaSinastria corpus,
  }) {
    final contatti = _contattiDeiCapitoli(tuo, suo, capitoliDi(legame));
    if (contatti.isEmpty) return const [];
    final porta = _perLaPorta(contatti, tuo, suo);
    final partenza = DateTime.utc(da.year, da.month, da.day);
    final candidati = <({DateTime giorno, double somma, CorpoCeleste t})>[];
    for (var i = 0; i < giorniDaGuardare; i++) {
      final g = partenza.add(Duration(days: i));
      final e = MoltiplicatoreCeleste.accensione(
        contatti: porta,
        giorno: g,
        transiti: transitiFavorevoli.toSet(),
        tipi: const {
          AspectType.conjunction,
          AspectType.trine,
          AspectType.sextile,
        },
      );
      if (e.somma > 0 && e.transito != null) {
        candidati.add((giorno: g, somma: e.somma, t: e.transito!));
      }
    }
    // I piu' accesi per primi; a parita', il piu' vicino.
    candidati.sort((a, b) {
      final s = b.somma.compareTo(a.somma);
      return s != 0 ? s : a.giorno.compareTo(b.giorno);
    });
    final scelti = <({DateTime giorno, double somma, CorpoCeleste t})>[];
    for (final c in candidati) {
      if (scelti.length == 3) break;
      if (scelti.every((s) =>
          (s.giorno.difference(c.giorno).inDays).abs() >= giorniFraUnoEAltro)) {
        scelti.add(c);
      }
    }
    scelti.sort((a, b) => a.giorno.compareTo(b.giorno));
    return [
      for (var i = 0; i < scelti.length; i++)
        (() {
          final v = corpus[
              'keplero_oggi_momento|momento ${scelti[i].t.name} ${legame.name}|testo']!;
          return GiornoFavorevole(
            giorno: scelti[i].giorno,
            transito: scelti[i].t,
            testo: _pulito(
                v[(LetturaEvolutiva.semeDellaCoppia(tuo, suo) + i) % v.length],
                nomeSuo),
          );
        })(),
    ];
  }

  static String testoSenzaGiorni({
    required CieloEvolutivo tuo,
    required CieloEvolutivo suo,
    required String nomeSuo,
    required Legame legame,
    required CorpusDellaSinastria corpus,
  }) {
    final v =
        corpus['keplero_oggi_momento|momento nessuno ${legame.name}|testo']!;
    return _pulito(
        v[LetturaEvolutiva.semeDellaCoppia(tuo, suo) % v.length], nomeSuo);
  }

  /// Il nome del pianeta come lo scrive la lettura; serve a [_corpo] di chi
  /// rilegge un giorno salvato.
  static CorpoCeleste? corpoDi(String nome) => _corpo(nome);

  static const String daDoveViene =
      'I transiti del giorno sui gradi dove i vostri cieli si toccano, con '
      'gli stessi orbi del cielo del giorno: cinque gradi, quattro sul '
      'sestile, due per la Luna. Si contano solo gli aspetti facili della '
      'tradizione (congiunzione, trigono, sestile) del Sole, della Luna, di '
      'Mercurio, di Venere e di Giove.';
}
