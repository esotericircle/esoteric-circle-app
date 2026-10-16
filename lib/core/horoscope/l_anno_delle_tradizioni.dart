import '../astro/meeus/il_cielo_di_meeus.dart';
import '../chat/user_profile.dart';
import 'horoscope.dart';
import 'i_segni_delle_tradizioni.dart';
import 'i_testi_eu.dart';
import 'il_capodanno_lunare.dart';
import 'l_almanacco_cinese.dart';
import 'la_lettura_cinese.dart';
import 'la_lettura_vedica.dart';
import '../astro/il_segno_del_cielo.dart';

/// L'anno di una persona in una tradizione: da quando a quando, il numero
/// dell'anno, i livelli dei quattro domini e da dove vengono.
class AnnoDellaTradizione {
  const AnnoDellaTradizione({
    required this.da,
    required this.a,
    required this.numero,
    required this.livelli,
    required this.daDove,
    required this.metodo,
  });

  /// Il primo giorno dell'anno e il primo del successivo (date civili).
  final DateTime da;
  final DateTime a;

  /// Il numero dell'anno della persona, per la scelta della voce.
  final int numero;

  /// I livelli di Generale, Amore, Carriera e Fortuna, da 2 a 5.
  final List<int> livelli;

  /// La riga "Da dove viene" di ogni dominio, dal calcolo.
  final List<String> daDove;

  /// La nota del metodo, per il punto interrogativo.
  final String metodo;
}

/// **L'ANNO DELLA CINESE E DELLA VEDICA, ordine EU voce 02.** Il fondatore:
/// *"manca l'oroscopo settimanale, mensile e annuale per vedica e cinese,
/// attualmente c'è solo quello giornaliero."*; sul metodo dell'Architetto,
/// *"Proposta Architetto"*.
///
/// **L'anno cinese** va da Capodanno lunare a Capodanno lunare
/// ([IlCapodannoLunare]). Il suo animale e' il ramo dell'anno; il rapporto
/// con l'animale della persona e' quello delle tabelle del Sanming Tonghui
/// gia' usate dal Giorno ([LAlmanaccoCinese.rapporto]: armonia, tripla
/// armonia, scontro, punizione, danno), col suo livello
/// ([LaLetturaCinese.livelloDelRapporto]). **Il Tai Sui** e' il signore
/// dell'anno, il suo ramo: lo offende chi ha lo stesso animale, chi gli si
/// oppone, chi lo punisce, chi lo danneggia e chi lo rompe (le cinque
/// relazioni degli almanacchi). Lo stesso animale e la rottura, che il
/// rapporto del Giorno non abbassa, abbassano l'anno di un gradino.
///
/// **L'anno vedico** va da compleanno a compleanno. Giove e Saturno siderali
/// (ayanamsa di Lahiri) al compleanno, contati dalla Luna di nascita: e' il
/// gochara. Le case favorevoli sono quelle della Phaladeepika, cap. 26:
/// Giove in 2, 5, 7, 9 e 11; Saturno in 3, 6 e 11. **La Sade Sati** e'
/// Saturno nella dodicesima, nella prima o nella seconda dalla Luna di
/// nascita: la tradizione la legge come sette anni e mezzo di prova. La
/// regola dei livelli, scritta qui: G vale 1 se Giove e' favorevole; S vale
/// 1 se Saturno e' favorevole e -1 nella Sade Sati. Generale 3 + G + S,
/// Amore 3 + G, meno uno nella Sade Sati, Carriera 3 + S, Fortuna 3 + G;
/// tutti fra 2 e 5.
abstract final class LAnnoDelleTradizioni {
  /// Le cinque relazioni che offendono il Tai Sui, per l'animale [tuo] e
  /// quello dell'anno [anno]; null se non lo offendi.
  static String? taiSui(int tuo, int anno) {
    if (tuo == anno) return 'hai lo stesso animale dell\'anno';
    if ((tuo - anno).abs() == 6) return 'il tuo animale gli si oppone';
    final r = LAlmanaccoCinese.rapporto(tuo, anno);
    if (r == RapportoFraAnimali.punizione ||
        r == RapportoFraAnimali.armoniaChePunisce) {
      return 'il tuo animale e quello dell\'anno si puniscono';
    }
    if (r == RapportoFraAnimali.danno) {
      return 'il tuo animale e quello dell\'anno si danneggiano';
    }
    if (_rotture.any((c) =>
        (c.$1 == tuo && c.$2 == anno) || (c.$1 == anno && c.$2 == tuo))) {
      return 'il tuo animale e quello dell\'anno si rompono';
    }
    return null;
  }

  // Le sei rotture (po): Topo e Gallo, Bue e Drago, Tigre e Maiale, Coniglio
  // e Cavallo, Serpente e Scimmia, Capra e Cane.
  static const List<(int, int)> _rotture = [
    (0, 9),
    (1, 4),
    (2, 11),
    (3, 6),
    (5, 8),
    (7, 10),
  ];

  /// L'anno cinese che contiene [oggi], per chi e' nato nell'anno
  /// dell'animale [animale]. Null fuori dalla tabella dei Capodanni.
  static AnnoDellaTradizione? cinese(DateTime oggi, int animale,
      {int? annoDiNascita}) {
    final anno = IlCapodannoLunare.annoCinese(oggi);
    if (anno == null) return null;
    final da = IlCapodannoLunare.di(anno);
    final a = IlCapodannoLunare.di(anno + 1);
    if (da == null || a == null) return null;
    final ramo = (anno - 4) % 12;
    final rapporto = LAlmanaccoCinese.rapporto(animale, ramo);
    final offeso = taiSui(animale, ramo);
    var livello = LaLetturaCinese.livelloDelRapporto(rapporto);
    if (livello >= 3 &&
        (animale == ramo ||
            (offeso != null && offeso.contains('si rompono')))) {
      livello -= 1;
    }
    final (nome, articolo) = ISegniDelleTradizioni.animali[ramo];
    final riga = 'L\'anno ${articolo == 'la' ? 'della' : 'del'} $nome va dal '
        '${_data(da)} al ${_data(a)}. Con ${LaLetturaCinese.conArticolo(animale)}'
        ', il tuo animale: ${LaLetturaCinese.rapportoDetto(rapporto, animale == ramo)}. '
        'Tai Sui, il signore dell\'anno: '
        '${offeso == null ? 'non lo offendi' : 'lo offendi, $offeso'}.';
    return AnnoDellaTradizione(
      da: da,
      a: a,
      numero: annoDiNascita == null ? anno : anno - annoDiNascita,
      livelli: [livello, livello, livello, livello],
      daDove: [riga, riga, riga, riga],
      // C-M-006 e C-M-008, testi dell'Architetto (ordine EV voce EV.08). Il
      // Tai Sui e le relazioni che lo offendono: gli almanacchi annuali
      // cinesi, il Tong Shu (C-A-003, C-A-004).
      metodo: 'L\'anno cinese va da Capodanno lunare a Capodanno lunare, '
          'come nello zodiaco popolare; il BaZi lo fa cominciare invece a '
          'Lichun, l\'inizio della primavera. Il rapporto fra il tuo animale '
          'e quello dell\'anno viene dalle tabelle del Sanming Tonghui; il '
          'Tai Sui e le cinque relazioni che lo offendono (stesso animale, '
          'scontro, punizione, danno, rottura) vengono dagli almanacchi '
          'annuali cinesi, il Tong Shu.',
    );
  }

  /// La longitudine siderale (Lahiri) di [corpo] all'istante [utc].
  static double siderale(CorpoCeleste corpo, DateTime utc) =>
      IlCieloDiMeeus.siderale(corpo, IlCieloDiMeeus.giornoGiuliano(utc));

  /// Le case favorevoli del gochara, Phaladeepika cap. 26.
  static const Set<int> caseBuoneDiGiove = {2, 5, 7, 9, 11};
  static const Set<int> caseBuoneDiSaturno = {3, 6, 11};
  static const Set<int> caseDellaSadeSati = {12, 1, 2};

  /// L'anno vedico che contiene [oggi], da compleanno a compleanno, per chi
  /// e' nato il giorno civile [nascita] con la Luna di nascita nel rashi
  /// [rashiNascita] (0 Mesha ... 11 Mina).
  static AnnoDellaTradizione vedico(
      DateTime oggi, DateTime nascita, int rashiNascita) {
    // Il compleanno di un anno: chi e' nato il 29 febbraio, negli anni che
    // non lo hanno, lo festeggia il 28.
    DateTime compleanno(int anno) {
      final ultimo = DateTime(anno, nascita.month + 1, 0).day;
      return DateTime(
          anno, nascita.month, nascita.day > ultimo ? ultimo : nascita.day);
    }

    var da = compleanno(oggi.year);
    if (DateTime(oggi.year, oggi.month, oggi.day).isBefore(da)) {
      da = compleanno(oggi.year - 1);
    }
    final a = compleanno(da.year + 1);
    final istante = DateTime.utc(da.year, da.month, da.day, 12);
    int casaDi(CorpoCeleste c) => LaLetturaVedica.casa(rashiNascita,
        IlSegnoDelCielo.dellaLongitudine(siderale(c, istante)).index);
    final giove = casaDi(CorpoCeleste.giove);
    final saturno = casaDi(CorpoCeleste.saturno);
    final g = caseBuoneDiGiove.contains(giove) ? 1 : 0;
    final sadeSati = caseDellaSadeSati.contains(saturno);
    final s = caseBuoneDiSaturno.contains(saturno) ? 1 : (sadeSati ? -1 : 0);
    int tra(int x) => x.clamp(2, 5);
    String segno(CorpoCeleste c) => ISegniDelleTradizioni
        .rashi[IlSegnoDelCielo.dellaLongitudine(siderale(c, istante)).index];
    const ordinali = LaLetturaVedica.ordinali;
    final diGiove = 'Al tuo compleanno del ${_data(da)} Giove era in '
        '${segno(CorpoCeleste.giove)}, nella tua ${ordinali[giove - 1]} casa '
        'dalla Luna di nascita: ${g == 1 ? 'una casa favorevole' : 'non una delle sue case favorevoli'}.';
    final diSaturno = 'Saturno era in ${segno(CorpoCeleste.saturno)}, nella '
        'tua ${ordinali[saturno - 1]} casa dalla Luna di nascita: '
        '${s == 1 ? 'una casa favorevole' : sadeSati ? 'è la Sade Sati' : 'non una delle sue case favorevoli'}.';
    return AnnoDellaTradizione(
      da: da,
      a: a,
      numero: da.year - nascita.year,
      livelli: [
        tra(3 + g + s),
        tra(3 + g - (sadeSati ? 1 : 0)),
        tra(3 + s),
        tra(3 + g),
      ],
      daDove: [
        '$diGiove $diSaturno',
        '$diGiove${sadeSati ? ' $diSaturno' : ''}',
        diSaturno,
        diGiove,
      ],
      // V-M-009 e V-M-011, testi dell'Architetto (ordine EV voce EV.08).
      // La Sade Sati (V-A-005): una lettura della tradizione indiana
      // costruita sul gochara; Phaladeepika, cap. 26, Saturno buono solo in
      // 3, 6 e 11.
      metodo: 'L\'anno va da compleanno a compleanno: è una scelta '
          'dell\'app, che guarda Giove e Saturno nel giorno del tuo '
          'compleanno. Giove e Saturno '
          'sono siderali (ayanamsa di Lahiri) e presi al tuo compleanno; si '
          'contano dalla Luna di nascita (gochara): le case favorevoli sono '
          'quelle della Phaladeepika, cap. 26, Giove in 2, 5, 7, 9 e 11, '
          'Saturno in 3, 6 e 11. La Sade Sati, i sette anni e mezzo di '
          'Saturno nella dodicesima, nella prima e nella seconda casa dalla '
          'Luna di nascita, è una lettura della tradizione indiana costruita '
          'sul gochara: per la Phaladeepika, cap. 26, Saturno dà frutti buoni '
          'solo in 3, 6 e 11.',
    );
  }

  /// Le quattro schede dell'anno, coi testi del corpus dell'Anno della
  /// tradizione [t] nella fascia del livello (EU Aggiunta).
  static List<HoroscopeCard> schede(
    TradizioneEu t,
    AnnoDellaTradizione anno, {
    required int scarto,
    Map<HoroscopeDomain, bool>? approfondite,
  }) =>
      [
        for (final d in HoroscopeDomain.values)
          () {
            final livello = anno.livelli[d.index];
            final voce = ITestiEu.voce(
                t,
                PeriodoEu.anno,
                d,
                FasciaEu.di(livello),
                ITestiEu.indiceDellAnno(anno.numero, scarto));
            final lunga = approfondite == null || (approfondite[d] ?? false);
            return HoroscopeCard(
              domain: d,
              title: voce.titolo,
              synthesis: voce.risposta,
              text: voce.testo(lunga: lunga),
              indicator: livello,
              rigaDelLivello: anno.daDove[d.index],
              metodo: anno.metodo,
            );
          }(),
      ];

  /// **IL MESE DELLA CINESE, col suo pilastro** (i dodici mesi dell'anno, il
  /// fondatore il 1 ottobre 2026). Il mese solare cinese ha un ramo (aperto
  /// dal suo jie) e un tronco, che si conta dal tronco dell'anno con la
  /// regola delle cinque tigri (il primo mese, la Tigre, ha il tronco
  /// `(anno % 5) * 2 + 2`). Si leggono come il giorno: la Generale dal
  /// rapporto fra il tuo animale e quello del mese, gli altri domini dal dio
  /// che il tronco del mese e' per il tuo tronco di nascita. Il mese si
  /// prende a meta' della finestra fra [da] e [a].
  /// Il ramo e il tronco del mese solare cinese del giorno [g]: il ramo dal
  /// suo jie, il tronco con la regola delle cinque tigri dal tronco
  /// dell'anno solare (che comincia col mese della Tigre).
  static (int, int) pilastroDelMese(DateTime g) {
    final ramo = LAlmanaccoCinese.ramoDelMese(g) ?? LAlmanaccoCinese.ramo(g);
    // Il Topo e il Bue di gennaio sono ancora dell'anno solare di prima.
    final anno = g.year - (ramo <= 1 && g.month <= 2 ? 1 : 0);
    final troncoDellAnno = (anno - 4) % 10;
    final k = (ramo - 2) % 12;
    return (ramo, ((troncoDellAnno % 5) * 2 + 2 + k) % 10);
  }

  static List<int> livelliDelMeseCinese(
      DateTime da, DateTime a, int animale, int signore, CourtesyForm forma) {
    final meta = da.add(Duration(days: a.difference(da).inDays ~/ 2));
    final (ramo, tronco) = pilastroDelMese(meta);
    final rapporto = LAlmanaccoCinese.rapporto(animale, ramo);
    final dio = LAlmanaccoCinese.dio(signore, tronco);
    return [
      LaLetturaCinese.livelloDelRapporto(rapporto),
      for (final d in HoroscopeDomain.values.skip(1))
        LaLetturaCinese.livelloDelDio(d, dio, forma: forma),
    ];
  }

  /// I pianeti del mese vedico per dominio e le loro case favorevoli dalla
  /// Luna di nascita, Phaladeepika cap. 26: il Sole per la Generale (il mese
  /// solare e' il suo passaggio in un segno), Venere per l'Amore, Marte per
  /// la Carriera, Mercurio per la Fortuna.
  static const Map<HoroscopeDomain, (CorpoCeleste, Set<int>)> pianetiDelMese = {
    HoroscopeDomain.generale: (CorpoCeleste.sole, {3, 6, 10, 11}),
    HoroscopeDomain.amore: (CorpoCeleste.venere, {1, 2, 3, 4, 5, 8, 9, 11, 12}),
    HoroscopeDomain.carriera: (CorpoCeleste.marte, {3, 6, 11}),
    HoroscopeDomain.fortuna: (CorpoCeleste.mercurio, {2, 4, 6, 8, 10, 11}),
  };

  /// **IL MESE DELLA VEDICA, col gochara del mese**: la casa del pianeta del
  /// dominio contata dalla Luna di nascita, a meta' della finestra; 4 se e'
  /// una delle sue case favorevoli, 2 se non lo e'.
  static List<int> livelliDelMeseVedico(
      DateTime da, DateTime a, int rashiNascita) {
    final meta = da.add(Duration(days: a.difference(da).inDays ~/ 2));
    final istante = DateTime.utc(meta.year, meta.month, meta.day, 12);
    return [
      for (final d in HoroscopeDomain.values)
        () {
          final (corpo, buone) = pianetiDelMese[d]!;
          final h = LaLetturaVedica.casa(rashiNascita,
              IlSegnoDelCielo.dellaLongitudine(siderale(corpo, istante)).index);
          return buone.contains(h) ? 4 : 2;
        }(),
    ];
  }

  static const List<String> _mesi = [
    'gennaio', 'febbraio', 'marzo', 'aprile', 'maggio', 'giugno', //
    'luglio', 'agosto', 'settembre', 'ottobre', 'novembre', 'dicembre',
  ];

  static String _data(DateTime d) => '${d.day} ${_mesi[d.month - 1]} ${d.year}';
}
