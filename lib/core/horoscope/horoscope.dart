import '../astro/zodiac.dart';
import '../chat/user_profile.dart';
import 'horoscope_data.dart';

/// I quattro domini dell'Oroscopo, nell'ordine di layout. L'indice enum e' anche
/// l'intero fisso del dominio: Generale 0, Amore 1, Carriera 2, Fortuna 3.
enum HoroscopeDomain {
  generale('Generale'),
  amore('Amore'),
  carriera('Carriera'),
  fortuna('Fortuna');

  const HoroscopeDomain(this.label);

  final String label;
}

/// Una scheda dell'Oroscopo, gia' composta e deterministica: titolo del dominio
/// per quel segno, testo (ancora del segno piu' corrente del giorno), indicatore
/// da due a cinque. Solo la scheda Fortuna porta numero fortunato e colore.
class HoroscopeCard {
  const HoroscopeCard({
    required this.domain,
    required this.title,
    required this.text,
    required this.synthesis,
    required this.indicator,
    this.opening,
    this.luckyNumber,
    this.dayColor,
  });

  final HoroscopeDomain domain;
  final String title;
  final String text;

  /// La sola sintesi del segno, senza la corrente del giorno.
  ///
  /// **Esiste per chiudere una porta.** La card da condividere mostrava questa
  /// frase rileggendosela da `HoroscopeData.anchors` per conto suo, cioe' alle
  /// spalle di `Horoscope`: chi avesse sostituito la composizione avrebbe
  /// cambiato lo schermo e lasciato l'immagine condivisa col testo vecchio,
  /// che e' l'angolo peggiore in cui restare indietro, perche' e' quello che
  /// la gente manda agli altri. Adesso la frase esce da qui, e chi cambia la
  /// composizione la cambia in tutti e due i posti.
  final String synthesis;

  /// L'apertura personalizzata col nome, solo sulla scheda Generale: si mostra
  /// prima del testo. Null sulle altre schede.
  final String? opening;

  /// Unita' piene dell'indicatore, sempre da 2 a 5.
  final int indicator;

  /// Numero fortunato da 1 a 90, solo per la scheda Fortuna.
  final int? luckyNumber;

  /// Colore del giorno, dalla palette del segno, solo per la scheda Fortuna.
  final String? dayColor;
}

/// La composizione deterministica dell'Oroscopo a quattro schede.
///
/// Tutto nasce da interi (indice del segno, giorno ordinale, anno, dominio) via
/// una hash stabile FNV-1a: stesso ingresso, stessa uscita, su ogni piattaforma
/// e a ogni apertura. Niente Random, niente ora, niente fuso, niente
/// [DateTime.now] dentro l'hash. Il giorno si legge una sola volta a livello di
/// schermata e si passa come intero.
class Horoscope {
  const Horoscope._();

  /// Unita' massime dell'indicatore.
  static const int indicatorMax = 5;

  /// Giorno ordinale nell'anno (0 il primo gennaio), come i riti del giorno.
  static int dayOfYear(DateTime date) =>
      date.difference(DateTime(date.year)).inDays;

  // Moltiplicazione a 32 bit esatta anche dove gli interi sono a doppia
  // precisione (web): si divide l'operando in due meta' da 16 bit cosi' nessun
  // prodotto intermedio supera i 2^53 bit sicuri. Su mobile gli interi sono a 64
  // bit e il risultato coincide.
  static int _mul32(int a, int b) {
    final aLo = a & 0xFFFF;
    final aHi = (a >> 16) & 0xFFFF;
    final lo = aLo * b;
    final hi = ((aHi * b) & 0xFFFF) << 16;
    return (lo + hi) & 0xFFFFFFFF;
  }

  /// Hash FNV-1a a 32 bit su una sequenza di interi, byte per byte.
  static int _fnv1a(List<int> values) {
    var hash = 0x811c9dc5;
    for (final v in values) {
      final x = v & 0xFFFFFFFF;
      for (var i = 0; i < 4; i++) {
        final byte = (x >> (8 * i)) & 0xFF;
        hash = (hash ^ byte) & 0xFFFFFFFF;
        hash = _mul32(hash, 0x01000193);
      }
    }
    return hash & 0xFFFFFFFF;
  }

  /// Il seme di base per (segno, giorno, anno, dominio).
  static int baseSeed(
          int signIndex, int dayOfYear, int year, int domainIndex) =>
      _fnv1a([signIndex, dayOfYear, year, domainIndex]);

  /// Il vocativo con cui aprire l'oroscopo: Caro o Cara piu' il nome quando il
  /// genere e' noto dall'onboarding, altrimenti Ciao piu' il nome.
  static String vocativeFor(String name, CourtesyForm courtesy) =>
      courtesy.agree(
        masculine: 'Caro $name',
        feminine: 'Cara $name',
        neutral: 'Ciao $name',
      );

  /// L'apertura personalizzata del giorno, pescata dal pool del corpus con lo
  /// stesso seme del giorno: deterministica e riproducibile. Quando Gemini e'
  /// acceso l'apertura la personalizza lui, questa resta il fallback.
  static String openingFor({
    required Zodiac sign,
    required int dayOfYear,
    required int year,
    required String vocative,
  }) {
    final base = baseSeed(sign.index, dayOfYear, year, 0);
    final seed = _fnv1a([base, 0x55]);
    final template =
        HoroscopeData.openings[seed % HoroscopeData.openings.length];
    return template.replaceAll(HoroscopeData.namePlaceholder, vocative);
  }

  /// Compone la scheda di un dominio per il segno e il giorno dati.
  static HoroscopeCard cardFor({
    required Zodiac sign,
    required int dayOfYear,
    required int year,
    required HoroscopeDomain domain,
    String? opening,
  }) {
    final d = domain.index;
    final base = baseSeed(sign.index, dayOfYear, year, d);

    // Semi derivati distinti, per non correlare i quattro valori.
    final seedCurrent = _fnv1a([base, 0x11]);
    final seedIndicator = _fnv1a([base, 0x22]);
    final seedLucky = _fnv1a([base, 0x33]);
    final seedColor = _fnv1a([base, 0x44]);

    final anchor = HoroscopeData.anchors[sign.id]![d];
    final pool = HoroscopeData.dayPools[d]!;
    final current = pool[seedCurrent % pool.length];

    final title = anchor[0];
    final text = '${anchor[1]} $current';
    final indicator = 2 + (seedIndicator % 4); // pavimento a 2, mai sotto

    // L'apertura personalizzata vive solo sulla scheda Generale.
    final cardOpening = domain == HoroscopeDomain.generale ? opening : null;

    if (domain == HoroscopeDomain.fortuna) {
      final palette = HoroscopeData.palettes[sign.id]!;
      return HoroscopeCard(
        domain: domain,
        title: title,
        text: text,
        synthesis: anchor[1],
        indicator: indicator,
        luckyNumber: 1 + (seedLucky % 90), // da 1 a 90
        dayColor: palette[seedColor % palette.length],
      );
    }
    return HoroscopeCard(
      domain: domain,
      title: title,
      text: text,
      synthesis: anchor[1],
      indicator: indicator,
      opening: cardOpening,
    );
  }

  /// Le quattro schede del segno per il giorno dato, nell'ordine di layout. Con
  /// [opening] la scheda Generale porta l'apertura personalizzata col nome.
  static List<HoroscopeCard> forSign({
    required Zodiac sign,
    required int dayOfYear,
    required int year,
    String? opening,
  }) =>
      [
        for (final domain in HoroscopeDomain.values)
          cardFor(
              sign: sign,
              dayOfYear: dayOfYear,
              year: year,
              domain: domain,
              opening: opening),
      ];

  /// La riga di disclaimer, una sola volta nella schermata.
  static String get disclaimer => HoroscopeData.disclaimer;
}
