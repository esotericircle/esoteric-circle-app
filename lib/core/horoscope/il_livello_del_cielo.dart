import '../astro/effemeridi.dart';
import '../astro/natal_chart.dart';
import '../astro/zodiac.dart';
import 'cielo_di_oggi.dart';
import 'corrente_del_cielo.dart';
import 'horoscope.dart';
import 'il_cielo_del_segno.dart';

/// **IL LIVELLO DI OGNI SCHEDA DAL CIELO VERO, ordine ES voce 28.**
///
/// Il fatto dell'Architetto: l'indicatore era `2 + (seed % 4)`, una hash su
/// segno, giorno, anno e dominio, uguale per tutto il segno anche con la
/// carta natale. Il briefing (sezione 40) lo chiama "anello di
/// favorevolezza": qui nasce dal cielo, con una regola scritta.
///
/// **Con la carta natale**: ogni passaggio del giorno che parla al dominio
/// ([CorrenteDelCielo.vociPer]) pesa +1 se armonico (trigono, sestile), -1
/// se teso (quadratura, opposizione); la congiunzione pesa +1 coi benefici
/// della tradizione (Venere, Giove), -1 coi malefici (Marte, Saturno), +0,5
/// con gli altri. Ogni peso si moltiplica per quanto il passaggio e' stretto:
/// 1 a orbita zero, 0 al limite dei due gradi.
///
/// **Senza carta**: la Luna di oggi e il segno solare. Il segno in cui sta la
/// Luna, contato dal segno della persona, fa l'aspetto fra i due segni:
/// trigono (quinta e nona casa solare) +1, sestile (terza e undicesima)
/// +0,5, congiunzione (prima) +0,5, quadratura (quarta e decima) -1,
/// opposizione (settima) -1, le altre 0. Se la casa solare e' una di quelle
/// del dominio (quinta, settima e ottava per l'Amore; seconda, sesta e decima
/// per la Carriera; seconda, quinta e undicesima per la Fortuna) si aggiunge
/// +0,5.
///
/// Senza carta pesa anche il corpo del dominio (il Sole per il Generale,
/// Venere per l'Amore, Marte per la Carriera, Giove per la Fortuna): la
/// meta' del peso della sua casa solare, piu' 0,5 se e' una casa del
/// dominio.
///
/// **La scala resta quella di prima**, da due a cinque: il livello e'
/// `3 + somma` arrotondato e tenuto fra 2 e 5; il giorno neutro e' 3.
abstract final class IlLivelloDelCielo {
  static const double orbitaMassima = 2.0;

  static const Set<CorpoCeleste> benefici = {
    CorpoCeleste.venere,
    CorpoCeleste.giove,
  };
  static const Set<CorpoCeleste> malefici = {
    CorpoCeleste.marte,
    CorpoCeleste.saturno,
  };

  /// Il peso di un passaggio, prima dell'orbita.
  static double pesoDi(VoceDelCielo v) {
    switch (v.aspetto.harmony) {
      case AspectHarmony.soft:
        return 1;
      case AspectHarmony.hard:
        return -1;
      case AspectHarmony.neutral:
        if (benefici.contains(v.transito)) return 1;
        if (malefici.contains(v.transito)) return -1;
        return 0.5;
    }
  }

  /// Il peso dell'aspetto fra due segni, dalla casa solare [casa] (1-12).
  static double pesoDellaCasaSolare(int casa) => switch (casa) {
        5 || 9 => 1,
        3 || 11 => 0.5,
        1 => 0.5,
        4 || 10 => -1,
        7 => -1,
        _ => 0,
      };

  static const Map<int, String> _aspettoDellaCasa = {
    1: 'nel tuo segno',
    3: 'in sestile al tuo segno',
    11: 'in sestile al tuo segno',
    5: 'in trigono al tuo segno',
    9: 'in trigono al tuo segno',
    4: 'in quadratura al tuo segno',
    10: 'in quadratura al tuo segno',
    7: 'in opposizione al tuo segno',
  };

  /// **IL GIORNO NEUTRO VALE TRE**, vista sul Realme il 29 settembre: col
  /// centro a 3,5 un giorno senza niente usciva 4 su 5, cioe' sembrava buono.
  /// Adesso il neutro e' 3, gli armonici salgono fino a 5, i tesi scendono
  /// fino a 2, il pavimento di sempre.
  static int _scala(double somma) => (3 + somma).round().clamp(2, 5);

  /// Il livello (2-5) e la riga che dice da dove viene.
  static (int, String) per({
    required HoroscopeDomain dominio,
    required Zodiac segno,
    required CieloDiOggi cielo,
    required DateTime quando,
    bool oggi = true,
  }) {
    // **LA RIGA DI UN GIORNO CHE NON E' OGGI NON DICE "OGGI".** Visto sul
    // Realme il 30 settembre 2026: nella Settimana e nel Mese ogni giorno,
    // anche sabato prossimo, portava "Dal cielo di oggi" o "Dalla Luna di
    // oggi". Padre: ordine ES voci 02 e 03, che riusano questa riga per i
    // giorni del periodo. Con [oggi] falso la riga sta sotto la data del suo
    // giorno e dice "del giorno".
    if (cielo.ceCieloVero) {
      final voci = CorrenteDelCielo.vociPer(cielo, dominio);
      var somma = 0.0;
      final pesate = <(double, VoceDelCielo)>[];
      for (final v in voci) {
        final stretto =
            (1 - v.orbe.abs() / orbitaMassima).clamp(0.0, 1.0).toDouble();
        final p = pesoDi(v) * stretto;
        somma += p;
        pesate.add((p.abs(), v));
      }
      pesate.sort((a, b) => b.$1.compareTo(a.$1));
      final nomi = [
        for (final (_, v) in pesate.take(2))
          '${CorrenteDelCielo.colSuoArticolo(v.transito, maiuscola: false)} in '
              '${v.aspetto.italianName.toLowerCase()} '
              '${CorrenteDelCielo.alBersaglio(v)}',
      ];
      final elenco = nomi.join('; ');
      final riga = nomi.isEmpty
          ? (oggi
              ? 'Oggi nessun passaggio stretto parla a questo campo.'
              : 'Quel giorno nessun passaggio stretto parla a questo campo.')
          : 'Dal cielo ${oggi ? 'di oggi' : 'del giorno'}: $elenco.';
      return (_scala(somma), riga);
    }
    final luna = IlCieloDelSegno.segnoDi(CorpoCeleste.luna, quando);
    final casa = IlCieloDelSegno.casaSolare(segno, luna);
    final caseDelDominio = CorrenteDelCielo.caseDi[dominio] ?? const <int>{};
    var somma = pesoDellaCasaSolare(casa);
    if (caseDelDominio.contains(casa)) somma += 0.5;
    // **E IL CORPO DEL DOMINIO**, vista sul Realme il 29 settembre: con la
    // sola Luna le quattro schede avevano lo stesso livello e la stessa riga,
    // e chi legge si chiede perche'. Il corpo del dominio (il Sole, Venere,
    // Marte, Giove) pesa la meta' della Luna, dalla sua casa solare, e la riga
    // lo nomina.
    final corpo = IlCieloDelSegno.corpoDi[dominio]!;
    final suo = IlCieloDelSegno.segnoDi(corpo, quando);
    final casaSua = IlCieloDelSegno.casaSolare(segno, suo);
    somma += 0.5 * pesoDellaCasaSolare(casaSua);
    if (caseDelDominio.contains(casaSua)) somma += 0.5;
    final aspetto = _aspettoDellaCasa[casa];
    final riga = 'Dalla Luna ${oggi ? 'di oggi' : 'del giorno'} in '
        '${luna.italianName}, nella tua '
        '${CorrenteDelCielo.ordinaliDelleCase[casa - 1]} casa solare'
        '${aspetto == null ? '' : ', $aspetto'}; '
        '${CorrenteDelCielo.colSuoArticolo(corpo, maiuscola: false)} è in '
        '${suo.italianName}, nella tua '
        '${CorrenteDelCielo.ordinaliDelleCase[casaSua - 1]}.';
    return (_scala(somma), riga);
  }
}
