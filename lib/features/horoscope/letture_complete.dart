import '../../core/entitlement/plan_catalog.dart';
import '../../core/entitlement/tier.dart';
import '../../core/horoscope/horoscope.dart';
import '../../core/horoscope/i_testi_eu.dart';

/// **CHE COSA DA' L'OROSCOPO COMPLETO, DETTO A CHI NON CE L'HA.** Il
/// fondatore, 1 ottobre 2026 sera, sul foglio che diceva "due paragrafi in
/// più": *"Ma dai, elimina che aggiungiamo 2 paragrafi, ma pensi prima di
/// scrivere? Io penserei: "ma devo spendere soldi per solo 2 paragrafi di
/// merda?"*.
///
/// Non si vende una quantita' di testo: si dice che cosa la lettura completa
/// fa per chi legge (il perche' di cio' che succede proprio a lui e come
/// muoversi, passo per passo), se ne fa leggere l'inizio vero, e si dice in
/// una riga che cosa porta l'abbonamento, col prezzo letto dal listino dei
/// piani. Le parole stanno qui, una volta sola, per il foglio dell'Occidentale
/// del giorno e per l'invito delle altre schede.
abstract final class LettureComplete {
  /// La promessa della lettura completa, in una frase.
  static const String promessa = 'La lettura breve ti dice che cosa succede. '
      'Quella completa ti dice perché succede proprio a te e come muoverti, '
      'passo per passo.';

  /// Il piano piu' leggero che apre la lettura completa.
  static Tier get pianoCheLaApre =>
      [Tier.tier1, Tier.tier2, Tier.tier3].firstWhere(PlanCatalog.haProfondita);

  /// Il prezzo settimanale del piano che apre la lettura completa.
  static String? get _prezzo =>
      PlanCatalog.forTier(pianoCheLaApre).price?.weekly;

  /// Che cosa porta l'abbonamento, col prezzo settimanale del piano che apre
  /// la lettura completa. Ogni cosa detta e' fra quelle del piano
  /// ([PlanCatalog]): la scelta della profondita', l'oroscopo settimanale,
  /// il cinese e il vedico del giorno, la memoria dei Maestri.
  static String conLAbbonamento() {
    final prezzo = _prezzo;
    return 'Con l\'abbonamento'
        '${prezzo == null ? '' : ', da $prezzo a settimana'}: l\'oroscopo '
        'completo ogni giorno su tutte le schede, la settimana coi suoi '
        'giorni migliori, il cielo cinese e quello vedico. E i Maestri si '
        'ricordano di te.';
  }

  /// Il messaggio dell'invito sulle schede che gli Eos non aprono: la
  /// Settimana e il Mese dicono anche i loro tre giorni migliori.
  static String invito({bool conIGiorni = false}) {
    final prezzo = _prezzo;
    return '$promessa'
        '${conIGiorni ? ' E ti dice i tre giorni migliori, uno per uno.' : ''}'
        ' Con l\'abbonamento la leggi su ogni scheda, ogni giorno'
        '${prezzo == null ? '' : ', da $prezzo a settimana'}.';
  }

  /// L'inizio della parte che la lettura breve non mostra: il terzo
  /// paragrafo della scheda completa, o null se la scheda non ce l'ha.
  static String? anteprima(HoroscopeCard completa) {
    final paragrafi = completa.text.split(ITestiEu.fraIParagrafi);
    return paragrafi.length > 2 && paragrafi[2].trim().isNotEmpty
        ? paragrafi[2].trim()
        : null;
  }
}
