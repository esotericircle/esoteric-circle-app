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
    // O-M-001, testo dell'Architetto, ordine EV voce EV.08.
    const prima =
        'Il titolo e il testo sono scelti fra le letture di Medora per '
        'il livello di oggi: favorevole, in equilibrio o in salita.';
    final seconda = switch (livello) {
      LivelloPersonalizzazione.cartaCompleta =>
        // O-M-002, testo dell'Architetto (ordine EV voce EV.08).
        'Il livello viene dai transiti di oggi sulla tua carta natale, '
            'calcolati sul telefono dalle effemeridi: i pianeti che passano '
            'sui tuoi pianeti di nascita e nelle tue case.',
      LivelloPersonalizzazione.cartaSenzaOra =>
        // O-M-003, testo dell'Architetto (ordine EV voce EV.08).
        'Il livello viene dai transiti di oggi sui tuoi pianeti di '
            'nascita, calcolati sul telefono dalle effemeridi. Senza l\'ora '
            'di nascita le case non si calcolano.',
      LivelloPersonalizzazione.soloSegno =>
        // O-M-004, testo dell'Architetto (ordine EV voce EV.08).
        'Senza ora e luogo di nascita non c\'è una carta: il livello '
            'viene dalla Luna di oggi e dal pianeta di questo campo, con le '
            'case solari contate dal tuo segno, come fa l\'astrologia '
            'moderna per chi non ha l\'ora di nascita.',
    };
    // Dall'ordine ES voce 28 il livello viene dal cielo (IlLivelloDelCielo).
    final livelloDelDominio = livello == LivelloPersonalizzazione.soloSegno
        // O-M-005, testo dell'Architetto (ordine EV voce EV.08): la regola
        // degli aspetti fra segni e' di Tolomeo, Tetrabiblos, libro I, cap. 13.
        ? 'Il livello da due a cinque viene dalla Luna di oggi e dal '
            'pianeta di questo campo: dal segno in cui si trovano rispetto '
            'al tuo e dalle case solari che attraversano. Tre vuol dire un '
            'giorno neutro. È una regola dell\'app costruita sugli aspetti '
            'fra segni di Tolomeo.'
        // O-M-006, testo dell'Architetto (ordine EV voce EV.08): la soglia
        // dei due gradi e' una scelta dell'app, gli aspetti sono di Tolomeo.
        // Il testo riscritto dall'Architetto il 2 ottobre 2026 senza la
        // virgola prima della "e" (EV Aggiunta): qui c'era l'adattamento di
        // Code ". Contano".
        : 'Il livello da due a cinque viene dai passaggi di oggi che '
            'parlano a questo campo, entro due gradi: quelli armonici lo '
            'alzano e quelli tesi lo abbassano; contano di più quanto sono '
            'stretti. È una regola dell\'app costruita sugli aspetti di '
            'Tolomeo.';
    // Dall'ordine ES voce 29 numero e colore hanno una regola
    // (IlNumeroEIlColore), scritta anche sotto la scheda.
    final fortuna = dominio == HoroscopeDomain.fortuna
        // O-M-007, testo dell'Architetto (ordine EV voce EV.08): il giorno
        // personale e' di Florence Campbell, Your Days Are Numbered (1931).
        ? ' Il numero è il giorno personale della numerologia moderna, '
            'dalla tua data di nascita e da quella di oggi. Il colore è '
            'quello tradizionale del pianeta che oggi pesa di più per te, dai colori di William '
            'Lilly.'
        : '';
    return '$prima $seconda $livelloDelDominio$fortuna';
  }
}
