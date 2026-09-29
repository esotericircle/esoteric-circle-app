import '../astro/aspetti_di_oggi.dart';
import 'horoscope.dart';

/// **IL METODO DI OGNI RESPONSO DELL'OROSCOPO, ordine ES voce 30.**
///
/// Il briefing, sezione 48, "Tooltip di trasparenza metodologica": ogni
/// responso dice con quale tecnica e con quali dati e' fatto. La nota e'
/// breve e fissa, e **dice il vero su come il testo nasce oggi**, anche
/// quando la risposta e' modesta: se il livello del dominio non viene ancora
/// dal cielo, la nota non lo fa credere.
///
/// Chi cambia il modo in cui un responso nasce (per esempio la voce ES.28,
/// il livello dal cielo vero) cambia anche questa nota: la prova
/// `la_tradizione_scelta_sta_in_cima_test.dart` legge le frasi del codice.
abstract final class IlMetodoDelResponso {
  /// La nota della scheda [dominio] del giorno, nella tradizione occidentale,
  /// al [livello] di dati che la persona ha dato.
  static String delGiorno(
      HoroscopeDomain dominio, LivelloPersonalizzazione livello) {
    const prima = 'La prima frase viene dalla Luna di oggi: il segno in cui '
        'si trova, contato dal tuo segno solare, dice in quale casa solare '
        'passa.';
    final seconda = switch (livello) {
      LivelloPersonalizzazione.cartaCompleta =>
        'Il resto viene dai transiti di oggi sulla tua carta natale, '
            'calcolati sul telefono dalle effemeridi: i pianeti che passano '
            'sui tuoi pianeti di nascita e nelle tue case.',
      LivelloPersonalizzazione.cartaSenzaOra =>
        'Il resto viene dai transiti di oggi sui tuoi pianeti di nascita, '
            'calcolati sul telefono dalle effemeridi. Senza l\'ora di nascita '
            'le case non si calcolano.',
      LivelloPersonalizzazione.soloSegno =>
        'Il resto è scelto per il tuo segno e per il giorno fra le frasi di '
            'Medora: senza ora e luogo di nascita non c\'è una carta su cui '
            'calcolare i transiti.',
    };
    const livelloDelDominio = 'Il livello da uno a cinque è scelto dal tuo '
        'segno e dalla data.';
    final fortuna = dominio == HoroscopeDomain.fortuna
        ? ' Anche il numero e il colore del giorno vengono dal tuo segno e '
            'dalla data; il colore è uno di quelli del tuo segno.'
        : '';
    return '$prima $seconda $livelloDelDominio$fortuna';
  }
}
