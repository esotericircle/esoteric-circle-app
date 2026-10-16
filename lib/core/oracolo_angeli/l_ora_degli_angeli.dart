import '../angels/angel_catalog.dart';
import '../angels/guardian_angels.dart';
import 'i_ruoli_e_l_estrazione.dart';

/// **L'ORA DEGLI ANGELI, IN UN PUNTO SOLO.** Ordine FU voci FU.07 e FU.08,
/// 15 ottobre 2026.
///
/// La regola e' quella dell'Angelo dell'Intelletto
/// (`GuardianAngels.intellectFor`, P3 dell'ordine): il giorno si divide in
/// settantadue parti di venti minuti (`GuardianAngels.minutesPerAngel`), e
/// l'angelo N governa i minuti da (N-1)*20 a N*20 dalla mezzanotte. Qui la
/// stessa regola dice l'angelo dell'ora presente (FU.08) e il momento del
/// rito di un angelo (FU.07), in ora locale.
abstract final class LOraDegliAngeli {
  static int get _passo => GuardianAngels.minutesPerAngel;

  /// L'angelo che governa i venti minuti presenti, dall'ora locale del
  /// telefono. Cambia da se' ogni venti minuti, senza modello.
  static Angel dellOra(DateTime adessoLocale) {
    final minuti = adessoLocale.hour * 60 + adessoLocale.minute;
    return AngelCatalog.byNumber(minuti ~/ _passo + 1);
  }

  /// Quando finiscono i venti minuti dell'angelo presente: la schermata si
  /// ridisegna a quell'istante.
  static DateTime prossimoCambio(DateTime adessoLocale) {
    final minuti = adessoLocale.hour * 60 + adessoLocale.minute;
    final fine = (minuti ~/ _passo + 1) * _passo;
    final mezzanotte =
        DateTime(adessoLocale.year, adessoLocale.month, adessoLocale.day);
    return mezzanotte.add(Duration(minutes: fine));
  }

  /// **IL MOMENTO DEL RITO**: i venti minuti del giorno governati
  /// dall'angelo, scritti in ora locale, "dalle 00:20 alle 00:40".
  static String momentoDelRito(Angel angelo) {
    final inizio = (angelo.number - 1) * _passo;
    final fine = angelo.number * _passo;
    return 'dalle ${_ora(inizio)} alle ${_ora(fine)}';
  }

  static String _ora(int minuti) {
    final m = minuti % (24 * 60);
    final h = (m ~/ 60).toString().padLeft(2, '0');
    final mm = (m % 60).toString().padLeft(2, '0');
    return '$h:$mm';
  }

  /// **IL MESSAGGIO DEL GIORNO**, dai tre angeli della persona (FU.08): un
  /// testo al giorno dal corpus dei messaggi, senza modello. L'angelo e il
  /// ruolo cambiano col giorno (il Custode, il Cuore, l'Intelletto se l'ora
  /// e' nota, a turno) e cosi' la variante, che ruota sulle tre del corpus.
  /// Nullo se il corpus non ha la cella: la schermata allora non lo mostra.
  static ({RuoloDellAngelo ruolo, Angel angelo, String testo})?
      messaggioDelGiorno({
    required AngelTriad triade,
    required DateTime giorno,
    required Map<String, List<String>> corpus,
  }) {
    final ruoli = [
      RuoloDellAngelo.custode,
      RuoloDellAngelo.cuore,
      if (triade.intellect != null) RuoloDellAngelo.intelletto,
    ];
    final n = DateTime.utc(giorno.year, giorno.month, giorno.day)
            .millisecondsSinceEpoch ~/
        Duration.millisecondsPerDay;
    final ruolo = ruoli[n % ruoli.length];
    final angelo = ruolo.dellaPersona(triade)!;
    final varianti = corpus[chiave(ruolo, angelo)];
    if (varianti == null || varianti.isEmpty) return null;
    final testo = varianti[(n ~/ ruoli.length) % varianti.length];
    return (ruolo: ruolo, angelo: angelo, testo: testo);
  }

  /// La chiave del corpus del messaggio di un angelo in un ruolo:
  /// "custode|07|messaggio".
  static String chiave(RuoloDellAngelo ruolo, Angel angelo) =>
      '${ruolo.corpus}|${angelo.number.toString().padLeft(2, '0')}|messaggio';

  /// La chiave del corpus del rito di Caligo per un angelo: "rito|07|rito".
  static String chiaveDelRito(Angel angelo) =>
      'rito|${angelo.number.toString().padLeft(2, '0')}|rito';
}
