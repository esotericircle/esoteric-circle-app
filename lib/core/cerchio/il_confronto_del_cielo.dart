import '../astro/night_sky.dart';
import '../astro/zodiac.dart';
import '../synastry/altre_affinita.dart';
import '../synastry/cielo_della_sinastria.dart';

/// **IL CONFRONTO DEL CIELO FRA DUE AMICI, ordine EY voce 13.**
///
/// Deterministico e senza modello. Il fondatore: "l'oroscopo e segno vanno
/// bene per iniziare". Il confronto e' sul SEGNO e non sulla carta intera:
/// il profilo pubblico di un amico porta il segno, mai la data ne' l'ora, e
/// nessun numero finge una precisione che non c'e'.
///
/// **Le quattro barre.**
/// - **Terra comune** e **Ritmo** sono le stesse funzioni che calcolano le
///   barre della Sinastria VIP (`AltreAffinita.terraComune` e `.ritmo`):
///   l'elemento e la modalita' dei due segni. Non riscritte, usate.
/// - **L'aspetto dei segni**: la distanza fra i due segni sulla ruota, cioe'
///   l'aspetto tolemaico fra i loro gradi medi (congiunzione, sestile,
///   quadrato, trigono, opposizione, e i due minori).
/// - **Il cielo di oggi**: dove sta la Luna oggi (`NightSky.moonSign`, il
///   cielo che l'app calcola gia') e l'aspetto che fa con ciascuno dei due
///   segni, in media. **Non l'elemento**: per due segni di elementi opposti
///   (un Leone e un Pesci) la media dell'accordo d'elemento con la Luna vale
///   sempre 60, qualunque sia la Luna, e il cielo del giorno non avrebbe
///   contato niente. L'ha trovato la prova che fa scorrere trenta giorni.
///
/// **LA SIMMETRIA E' UNA PROVA, NON UNA SPERANZA.** Ogni barra e' simmetrica
/// per costruzione, e l'affinita' e' una loro media pesata: da A verso B e da
/// B verso A esce lo stesso numero. Una prova enumera le 78 coppie di segni
/// in piu' giorni e lo pretende.
class IlConfrontoDelCielo {
  const IlConfrontoDelCielo._({
    required this.affinita,
    required this.terraComune,
    required this.ritmo,
    required this.aspetto,
    required this.cieloDiOggi,
    required this.lunaDiOggi,
    required this.nomeDellAspetto,
  });

  /// L'affinita' del giorno, da 0 a 100.
  final int affinita;
  final int terraComune;
  final int ritmo;
  final int aspetto;
  final int cieloDiOggi;
  final Zodiac lunaDiOggi;
  final String nomeDellAspetto;

  /// I pesi della media, dichiarati: elemento e aspetto pesano di piu',
  /// perche' sono le due relazioni che la tradizione mette davanti.
  static const double pesoTerra = 0.3;
  static const double pesoRitmo = 0.2;
  static const double pesoAspetto = 0.3;
  static const double pesoGiorno = 0.2;

  static CieloDiSinastria _cielo(Zodiac s) =>
      CieloDiSinastria(longitudini: const {}, segnoSolare: s, oraNota: false);

  /// L'aspetto fra due segni dalla loro distanza sulla ruota, e quanto vale.
  static (int, String) aspettoFra(Zodiac a, Zodiac b) {
    final d = (a.index - b.index).abs();
    final passi = d > 6 ? 12 - d : d;
    return switch (passi) {
      0 => (85, 'congiunzione'),
      1 => (50, 'semisestile'),
      2 => (78, 'sestile'),
      3 => (38, 'quadrato'),
      4 => (92, 'trigono'),
      5 => (42, 'quinconce'),
      _ => (55, 'opposizione'),
    };
  }

  static IlConfrontoDelCielo fra(Zodiac a, Zodiac b, DateTime giorno) {
    final terra = AltreAffinita.terraComune(_cielo(a), _cielo(b));
    final ritmo = AltreAffinita.ritmo(_cielo(a), _cielo(b));
    final (aspetto, nome) = aspettoFra(a, b);
    // A mezzogiorno del giorno: la Luna del giorno e' una per tutti e due.
    final luna = NightSky.moonSign(
        DateTime.utc(giorno.year, giorno.month, giorno.day, 12));
    final (giornoA, _) = aspettoFra(luna, a);
    final (giornoB, _) = aspettoFra(luna, b);
    // La somma prima della divisione: l'ordine dei due non cambia niente.
    final cieloDiOggi = ((giornoA + giornoB) / 2).round();
    final totale = pesoTerra * terra +
        pesoRitmo * ritmo +
        pesoAspetto * aspetto +
        pesoGiorno * cieloDiOggi;
    return IlConfrontoDelCielo._(
      affinita: totale.round().clamp(0, 100),
      terraComune: terra,
      ritmo: ritmo,
      aspetto: aspetto,
      cieloDiOggi: cieloDiOggi,
      lunaDiOggi: luna,
      nomeDellAspetto: nome,
    );
  }

  /// Le quattro barre nell'ordine in cui si riempiono.
  List<(String, int)> get barre => [
        ('Terra comune', terraComune),
        ('Ritmo', ritmo),
        ('L’aspetto dei segni', aspetto),
        ('Il cielo di oggi', cieloDiOggi),
      ];

  /// La riga che dice come stanno insieme i due cieli di oggi.
  String rigaDelGiorno(Zodiac a, Zodiac b) {
    final insieme = cieloDiOggi >= 70
        ? 'li accorda tutti e due'
        : cieloDiOggi >= 50
            ? 'li tocca con garbo'
            : 'chiede a tutti e due un passo di pazienza';
    return 'Oggi la Luna in ${lunaDiOggi.italianName} $insieme: '
        '${a.italianName} e ${b.italianName} in $nomeDellAspetto.';
  }

  /// IL PANNELLO FONTI E METODO, come su ogni arte.
  static const String fontiEMetodo =
      'Da dove viene la percentuale. È la media pesata di quattro misure, '
      'tutte sui due segni solari: l’elemento (Terra comune, 30 per cento), '
      'la modalità cardinale, fissa o mobile (Ritmo, 20 per cento), l’aspetto '
      'fra i due segni sulla ruota (30 per cento) e l’aspetto che la Luna di '
      'oggi fa con tutti e due (20 per cento). Elementi, modalità e aspetti '
      'tolemaici sono della tradizione astrologica, la stessa da cui nascono '
      'le barre della Sinastria VIP.\n\n'
      'Cosa confronta. Il segno e non la carta intera: del cielo di un amico '
      'il Cerchio conosce il segno, mai la data, l’ora o il luogo. Per questo '
      'il numero non finge la precisione di una sinastria completa.\n\n'
      'La lettura è una chiave di lettura del Maestro e non una dottrina '
      'tradizionale: la tradizione dà gli elementi, le modalità e gli '
      'aspetti, il modo di pesarli insieme è del Cerchio.';

  /// La riga che dichiara su cosa poggia il numero.
  static const String sulSegno =
      'Il confronto è sul segno e non sulla carta intera.';
}
