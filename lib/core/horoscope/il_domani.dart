import '../astro/celestial.dart';
import '../astro/effemeridi.dart';
import '../astro/natal_chart.dart';
import '../astro/transiti_nelle_case.dart';
import '../astro/zodiac.dart';
import 'corrente_del_cielo.dart';
import 'il_cielo_del_segno.dart';

/// **LA RAGIONE PER TORNARE DOMANI, ordine ES voce 34.**
///
/// Linee Guida, sezione 12.1: una schermata non si chiude senza una ragione
/// dichiarata per tornare. In fondo all'Oroscopo una riga calcolata dice
/// dove sara' la Luna domani: con la carta natale e l'ora, nella casa
/// natale; senza, nella casa solare del segno. E' un fatto del giorno dopo,
/// calcolato oggi, e la prova lo confronta col giorno dopo per trenta
/// giorni.
abstract final class IlDomani {
  /// La casa (1-12) in cui sta la Luna a [quando]: natale se [carta] ha le
  /// case, altrimenti solare dal [segno]. Il secondo valore dice se e'
  /// natale.
  static (int, bool) casaDellaLuna(
      Zodiac segno, NatalChart? carta, DateTime quando) {
    final l = Effemeridi.longitudineEclittica(
        CorpoCeleste.luna, Celestial.julianDay(quando.toUtc()));
    if (carta != null && carta.hasTime && carta.houses.length == 12) {
      final casa = TransitiNelleCase.casaDi(l, carta.houses);
      if (casa != null) return (casa, true);
    }
    final dove = Zodiac.values[(l ~/ 30) % 12];
    return (IlCieloDelSegno.casaSolare(segno, dove), false);
  }

  /// La riga di domani, per chi guarda [oggi].
  static String riga(Zodiac segno, NatalChart? carta, DateTime oggi) {
    final mezzogiorno = DateTime.utc(oggi.year, oggi.month, oggi.day, 12);
    final (casaOggi, _) = casaDellaLuna(segno, carta, mezzogiorno);
    final (casaDomani, natale) = casaDellaLuna(
        segno, carta, mezzogiorno.add(const Duration(days: 1)));
    final ordinale = CorrenteDelCielo.ordinaliDelleCase[casaDomani - 1];
    final materia = CorrenteDelCielo.materiaDelleCase[casaDomani - 1];
    final tipo = natale ? 'casa' : 'casa solare';
    // La materia della casa dice di che cosa parlera' il cielo: "se ne
    // parlera' domani" lasciava chi legge a chiedersi di che cosa.
    if (casaDomani == casaOggi) {
      return 'Domani la Luna resta nella tua $ordinale $tipo: il cielo '
          'continua a parlare $materia.';
    }
    return 'Domani la Luna entra nella tua $ordinale $tipo: il cielo di '
        'domani parlerà $materia.';
  }
}
