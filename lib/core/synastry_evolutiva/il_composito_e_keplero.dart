import '../astro/natal_chart.dart';
import 'cielo_evolutivo.dart';
import 'la_lettura_evolutiva.dart';

/// **IL TEMA COMPOSITO.** Ordine FT voce FT.07 (Briefing Operativo V13
/// sezione 58.4, Master V13 sezione 72.5): il cielo della relazione stessa,
/// coi punti medi dei pianeti delle due nascite, secondo Robert Hand
/// (*Planets in Composite*, 1975). Esclusiva del piano Adepto (FT.13).
///
/// **IL PUNTO MEDIO** e' quello dell'arco piu' corto fra le due posizioni,
/// come in Hand: Sole a 10 gradi e Sole a 350 hanno il punto medio a 0, non a
/// 180.
///
/// **QUALE ASPETTO PARLA.** Fra i dieci aspetti possibili dei cinque punti
/// medi (Sole, Luna, Mercurio, Venere, Marte) parla il piu' stretto, con
/// gli orbi gia' approvati per la sinastria. **Scelta dichiarata di Code**:
/// le congiunzioni fra Sole, Mercurio e Venere composti non si contano,
/// perche' Mercurio e Venere non si allontanano mai molto dal Sole (al piu'
/// ventotto e quarantasette gradi) e i loro punti medi restano vicini per
/// forza: contarle farebbe parlare quasi ogni coppia della stessa cosa.
class IlComposito {
  const IlComposito({required this.punti, required this.aspetto});

  final Map<PuntoDelCieloEvolutivo, double> punti;

  /// L'aspetto che parla; nullo se nessuno dei dieci e' nell'orbo.
  final ({
    PuntoDelCieloEvolutivo a,
    PuntoDelCieloEvolutivo b,
    AspectType tipo,
    double orbo,
  })? aspetto;

  static const List<PuntoDelCieloEvolutivo> deiPunti = [
    PuntoDelCieloEvolutivo.sole,
    PuntoDelCieloEvolutivo.luna,
    PuntoDelCieloEvolutivo.mercurio,
    PuntoDelCieloEvolutivo.venere,
    PuntoDelCieloEvolutivo.marte,
  ];

  /// Il punto medio dell'arco piu' corto fra [a] e [b], in gradi [0, 360).
  static double puntoMedio(double a, double b) {
    final d = ((b - a + 540) % 360) - 180;
    final m = (a + d / 2) % 360;
    return m < 0 ? m + 360 : m;
  }

  static bool _obbligata(
      PuntoDelCieloEvolutivo a, PuntoDelCieloEvolutivo b, AspectType tipo) {
    const vicini = {
      PuntoDelCieloEvolutivo.sole,
      PuntoDelCieloEvolutivo.mercurio,
      PuntoDelCieloEvolutivo.venere,
    };
    return tipo == AspectType.conjunction &&
        vicini.contains(a) &&
        vicini.contains(b);
  }

  static IlComposito fra(CieloEvolutivo tuo, CieloEvolutivo suo) {
    // Un punto che tace in uno dei due cieli (la Luna con l'ora di nascita
    // non nota, FT.03) non ha un punto medio: resta fuori.
    final punti = {
      for (final p in deiPunti)
        if (tuo.longitudini[p] != null && suo.longitudini[p] != null)
          p: puntoMedio(tuo.longitudini[p]!, suo.longitudini[p]!),
    };
    ({
      PuntoDelCieloEvolutivo a,
      PuntoDelCieloEvolutivo b,
      AspectType tipo,
      double orbo,
    })? migliore;
    for (var i = 0; i < deiPunti.length; i++) {
      for (var j = i + 1; j < deiPunti.length; j++) {
        final a = deiPunti[i];
        final b = deiPunti[j];
        if (punti[a] == null || punti[b] == null) continue;
        for (final tipo in AspectType.values) {
          final c = ChartAspect(
              aLongitude: punti[a]!, bLongitude: punti[b]!, type: tipo);
          if (c.orbe > AspettiEvolutivi.orbo[tipo]!) continue;
          if (_obbligata(a, b, tipo)) break;
          if (migliore == null || c.orbe < migliore.orbo) {
            migliore = (a: a, b: b, tipo: tipo, orbo: c.orbe);
          }
          break;
        }
      }
    }
    return IlComposito(punti: punti, aspetto: migliore);
  }

  /// La cella del corpus: "<punto>-<punto> <famiglia>", oppure "nessuno".
  String get cella {
    final x = aspetto;
    if (x == null) return 'nessuno';
    final famiglia = switch (Tono.di(x.tipo)) {
      Tono.fuso => 'fuso',
      Tono.armonico => 'armonico',
      _ => 'teso',
    };
    return '${nomeNelCorpus(x.a)}-${nomeNelCorpus(x.b)} $famiglia';
  }

  static const String daDoveViene =
      'Il Tema Composito di Robert Hand (Planets in Composite, 1975): per '
      'ogni pianeta si prende il punto a metà strada fra le posizioni delle '
      'due nascite: quei punti medi fanno un terzo cielo, quello della '
      'relazione.';
}

/// **LE CONSONANZE DI KEPLERO.** Ordine FT voce FT.08: Giovanni Keplero,
/// *Harmonices Mundi* (1619), libro IV, lega gli aspetti alle consonanze
/// musicali. I due punti dividono il cerchio in due archi; l'arco maggiore
/// sta al cerchio intero come le due lunghezze di corda che suonano
/// l'intervallo. Ai cinque aspetti di Tolomeo Keplero aggiunge quelli che
/// nascono dalle stesse consonanze: il quintile (settantadue gradi), il
/// biquintile (centoquarantaquattro) e il sesquiquadrato (centotrentacinque).
enum Consonanza {
  unisono('Unisono', 0, '1:1'),
  terzaMinore('Terza minore', 60, '5:6'),
  terzaMaggiore('Terza maggiore', 72, '4:5'),
  quarta('Quarta', 90, '3:4'),
  quinta('Quinta', 120, '2:3'),
  sestaMinore('Sesta minore', 135, '5:8'),
  sestaMaggiore('Sesta maggiore', 144, '3:5'),
  ottava('Ottava', 180, '1:2');

  const Consonanza(this.nome, this.gradi, this.rapporto);

  final String nome;
  final double gradi;

  /// L'arco maggiore sul cerchio intero, come rapporto di corda.
  final String rapporto;

  /// La cella del corpus.
  String get cella => switch (this) {
        Consonanza.terzaMinore => 'terza_minore',
        Consonanza.terzaMaggiore => 'terza_maggiore',
        Consonanza.sestaMinore => 'sesta_minore',
        Consonanza.sestaMaggiore => 'sesta_maggiore',
        _ => name,
      };
}

/// Una corda fra un punto tuo e un punto dell'altra persona.
class Corda {
  const Corda({
    required this.tuo,
    required this.suo,
    required this.separazione,
    required this.consonanza,
  });

  final PuntoDelCieloEvolutivo tuo;
  final PuntoDelCieloEvolutivo suo;

  /// La distanza fra i due punti, da 0 a 180 gradi.
  final double separazione;

  /// La consonanza, se la distanza ci cade entro [IntervalliDiKeplero.orbo];
  /// nulla, nessuna consonanza.
  final Consonanza? consonanza;

  String get cella => consonanza?.cella ?? 'nessuna';
}

abstract final class IntervalliDiKeplero {
  /// **L'ORBO, scelta dichiarata di Code**: due gradi. Keplero non ne
  /// fissa uno per la sinastria; con le otto consonanze vicine fra loro
  /// (sessanta e settantadue gradi, centotrentacinque e centoquarantaquattro)
  /// un orbo largo come quello degli aspetti (sei) farebbe cadere la stessa
  /// distanza in due consonanze.
  static const double orbo = 2.0;

  /// Le quattro corde che si mostrano: i due Soli, le due Lune, la tua
  /// Venere col suo Marte, il tuo Marte con la sua Venere.
  static const List<(PuntoDelCieloEvolutivo, PuntoDelCieloEvolutivo)> coppie = [
    (PuntoDelCieloEvolutivo.sole, PuntoDelCieloEvolutivo.sole),
    (PuntoDelCieloEvolutivo.luna, PuntoDelCieloEvolutivo.luna),
    (PuntoDelCieloEvolutivo.venere, PuntoDelCieloEvolutivo.marte),
    (PuntoDelCieloEvolutivo.marte, PuntoDelCieloEvolutivo.venere),
  ];

  static Consonanza? consonanzaDi(double separazione) {
    for (final c in Consonanza.values) {
      if ((separazione - c.gradi).abs() <= orbo) return c;
    }
    return null;
  }

  static List<Corda> fra(CieloEvolutivo tuo, CieloEvolutivo suo) => [
        for (final (a, b) in coppie)
          // La corda di un punto che tace (FT.03) non si suona.
          if (tuo.longitudini[a] != null && suo.longitudini[b] != null)
            (() {
              final s = ChartAspect(
                      aLongitude: tuo.longitudini[a]!,
                      bLongitude: suo.longitudini[b]!,
                      type: AspectType.conjunction)
                  .separazione;
              return Corda(
                  tuo: a, suo: b, separazione: s, consonanza: consonanzaDi(s));
            })(),
      ];

  static const String daDoveViene =
      'Giovanni Keplero, Harmonices Mundi (1619), libro IV: gli aspetti come '
      'consonanze. I due punti dividono il cerchio in due archi: l\'arco '
      'maggiore sta al cerchio intero come le due corde che suonano '
      'l\'intervallo.';
}
