/// I TEMPI DEI GIOCHI DEL CERCHIO. Ordine FF voce 07, 7 ottobre 2026.
///
/// Il fondatore, sulle scadenze dei giochi: nessun gioco si ferma ad
/// aspettare che una persona apra l'app, e ogni gioco aperto mostra quanto
/// tempo gli resta. Qui stanno le scadenze, in un punto solo:
/// - la Prova finisce con la settimana: dal lunedi' al lunedi' dopo;
/// - la sfida a due dura ventiquattro ore;
/// - il Pellegrinaggio finisce con la luna piena, e la data viene dalla
///   porta unica del cielo (`MoonPhase`, che chiede a `IlCieloDiMeeus`): il
///   giorno in cui la Luna passa l'opposizione al Sole, non il primo giorno
///   dell'evento "luna piena" dei Doni, che comincia quando la luce supera il
///   96 per cento (a ottobre 2026 il 24, due giorni prima del 26);
/// - l'indovinello non scade, perche' si gioca e si chiude nello stesso
///   momento.
library;

import '../astro/moon_phase.dart';

enum GiocoDelCerchio { indovinello, prova, sfidaADue, pellegrinaggio }

abstract final class ITempiDeiGiochi {
  /// La sfida a due resta aperta ventiquattro ore.
  static const Duration duraLaSfida = Duration(hours: 24);

  /// Il Pellegrinaggio e' la settimana che porta alla luna piena.
  static const int giorniDelPellegrinaggio = 7;

  /// Il lunedi' che apre la settimana di [istante], a mezzanotte locale.
  static DateTime lunediDi(DateTime istante) {
    final giorno = DateTime(istante.year, istante.month, istante.day);
    return DateTime(giorno.year, giorno.month,
        giorno.day - (giorno.weekday - DateTime.monday));
  }

  /// La chiave della settimana, la stessa per tutti: la data del lunedi'.
  static String settimanaDi(DateTime istante) {
    final l = lunediDi(istante);
    String due(int n) => n.toString().padLeft(2, '0');
    return '${l.year}-${due(l.month)}-${due(l.day)}';
  }

  /// **LA SCADENZA DI UN GIOCO** cominciato a [inizio]. Nulla per
  /// l'indovinello, che non resta mai aperto. Per il Pellegrinaggio
  /// [lunaPiena] e' il giorno della luna piena che chiude la settimana.
  static DateTime? scadenza(
    GiocoDelCerchio gioco,
    DateTime inizio, {
    DateTime? lunaPiena,
  }) {
    switch (gioco) {
      case GiocoDelCerchio.indovinello:
        return null;
      case GiocoDelCerchio.prova:
        final l = lunediDi(inizio);
        return DateTime(l.year, l.month, l.day + 7);
      case GiocoDelCerchio.sfidaADue:
        return inizio.add(duraLaSfida);
      case GiocoDelCerchio.pellegrinaggio:
        final p = lunaPiena ?? prossimaLunaPiena(inizio);
        if (p == null) return null;
        // Fino alla fine del giorno della luna piena.
        return DateTime(p.year, p.month, p.day + 1);
    }
  }

  /// Il tempo che resta, mai negativo: zero vuol dire scaduto.
  static Duration resta(DateTime scadenza, DateTime adesso) {
    final d = scadenza.difference(adesso);
    return d.isNegative ? Duration.zero : d;
  }

  /// Vero se il gioco e' scaduto e va chiuso con quello che c'e'.
  static bool scaduto(DateTime? scadenza, DateTime adesso) =>
      scadenza != null && !adesso.isBefore(scadenza);

  /// Il giorno della prossima luna piena, oggi compreso: il giorno nel quale
  /// la Luna passa dalla meta' crescente del ciclo a quella calante, cioe'
  /// l'opposizione al Sole. Un ciclo dura meno di trenta giorni, quindi la
  /// si trova sempre entro trentuno.
  static DateTime? prossimaLunaPiena(DateTime adesso) {
    final oggi = DateTime(adesso.year, adesso.month, adesso.day);
    for (var i = 0; i <= 31; i++) {
      final giorno = DateTime(oggi.year, oggi.month, oggi.day + i);
      final dopo = DateTime(oggi.year, oggi.month, oggi.day + i + 1);
      if (MoonPhase.forDate(giorno).fraction < 0.5 &&
          MoonPhase.forDate(dopo).fraction >= 0.5) {
        return giorno;
      }
    }
    return null;
  }

  /// Vero se [adesso] cade nella settimana che porta alla luna piena.
  static bool eIlTempoDelPellegrinaggio(DateTime adesso) {
    final p = prossimaLunaPiena(adesso);
    if (p == null) return false;
    final oggi = DateTime(adesso.year, adesso.month, adesso.day);
    return p.difference(oggi).inDays < giorniDelPellegrinaggio;
  }
}
