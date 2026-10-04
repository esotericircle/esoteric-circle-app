import '../astro/il_segno_del_cielo.dart';
import '../astro/effemeridi.dart';
import '../astro/zodiac.dart';
import 'corrente_del_cielo.dart';
import 'horoscope.dart';

/// **IL CIELO DI OGGI SUL SEGNO, PER CHI NON HA DATO ORA E LUOGO.** Ordine ES
/// voce 01, 29 settembre 2026.
///
/// Il fatto dell'Architetto: senza carta natale l'Approfondita era identica
/// alla Breve, 48 schede su 48. La richiesta: *"senza carta natale
/// l'Approfondita dice di più della Breve con fatti veri: la Luna e i pianeti
/// veloci che attraversano il segno e le case solari quel giorno, dal motore
/// delle effemeridi dell'app"*.
///
/// **Le case solari** sono quelle contate dal segno del Sole: il segno della
/// persona e' la prima, il successivo la seconda, e cosi' via. Sono le case
/// che l'astrologia dei giornali usa per chi non ha l'ora di nascita, e sono
/// vere per ogni persona di quel segno.
///
/// Ogni frase dice un fatto calcolato: dove sta il corpo oggi a mezzogiorno di
/// Greenwich e in quale casa solare cade. Niente si inventa.
abstract final class IlCieloDelSegno {
  /// Il corpo che ogni dominio ascolta, dopo la Luna: il Sole per il
  /// Generale, Venere per l'Amore, Marte per la Carriera, Giove per la
  /// Fortuna (la "Fortuna maggiore" della tradizione).
  static const Map<HoroscopeDomain, CorpoCeleste> corpoDi = {
    HoroscopeDomain.generale: CorpoCeleste.sole,
    HoroscopeDomain.amore: CorpoCeleste.venere,
    HoroscopeDomain.carriera: CorpoCeleste.marte,
    HoroscopeDomain.fortuna: CorpoCeleste.giove,
  };

  /// La casa solare, da 1 a 12, del segno [dove] per chi e' del segno
  /// [segno].
  static int casaSolare(Zodiac segno, Zodiac dove) =>
      (dove.index - segno.index) % 12 + 1;

  /// La frase di un corpo: "Oggi la Luna è in Bilancia, nella tua settima
  /// casa solare, quella dei legami che contano."
  static String fraseDi(CorpoCeleste corpo, Zodiac segno, DateTime quando,
      {bool oggi = true}) {
    final dove = IlSegnoDelCielo.delCorpo(corpo, quando);
    final casa = casaSolare(segno, dove);
    final chi = CorrenteDelCielo.colSuoArticolo(corpo, maiuscola: !oggi);
    final inizio = oggi ? 'Oggi $chi' : chi;
    return '$inizio è in ${dove.italianName}, nella tua '
        '${CorrenteDelCielo.ordinaliDelleCase[casa - 1]} casa solare, quella '
        '${CorrenteDelCielo.materiaDelleCase[casa - 1]}.';
  }

  /// Le frasi che l'Approfondita aggiunge senza carta natale: la Luna, poi il
  /// corpo del dominio.
  static String approfondita(
      HoroscopeDomain dominio, Zodiac segno, DateTime quando) {
    final luna = fraseDi(CorpoCeleste.luna, segno, quando);
    final corpo = corpoDi[dominio]!;
    final suo = fraseDi(corpo, segno, quando, oggi: false);
    return '$luna $suo';
  }
}
