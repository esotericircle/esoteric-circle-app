import '../entitlement/tier.dart';

/// Quanti Test Archetipo si possono fare in un giorno, per livello.
///
/// Funzione pura: riceve quanti ne sono gia' stati fatti nel giorno LOCALE e il
/// livello, e dice si' o no. Il conteggio e la persistenza stanno fuori, cosi'
/// la regola resta una cosa sola da leggere e da provare.
///
/// Superato il limite non si lascia un vicolo cieco: la schermata mostrera'
/// l'ultimo risultato salvato e l'invito all'abbonamento.
class ArchetypeAllowance {
  const ArchetypeAllowance._();

  /// Il limite giornaliero per livello, oppure null se illimitato.
  ///
  /// Viandante uno al giorno, Iniziato fino a tre, Adepto e Illuminato senza
  /// limite: il test e' un momento di conoscenza di se', non una slot machine,
  /// quindi anche il gratuito ne ha uno vero al giorno invece di zero.
  static int? limite(Tier tier) {
    switch (tier) {
      case Tier.free:
        return 1;
      case Tier.tier1:
        return 3;
      case Tier.tier2:
      case Tier.tier3:
        return null;
    }
  }

  /// Se si puo' fare un altro test oggi.
  ///
  /// [fattiOggi] e' il numero di test gia' completati nel giorno locale. Un
  /// valore negativo vale zero, cosi' un contatore sporco non regala tentativi.
  static bool consentito({required int fattiOggi, required Tier tier}) {
    final max = limite(tier);
    if (max == null) return true;
    return (fattiOggi < 0 ? 0 : fattiOggi) < max;
  }

  /// Quanti ne restano oggi, oppure null se sono illimitati.
  static int? rimanenti({required int fattiOggi, required Tier tier}) {
    final max = limite(tier);
    if (max == null) return null;
    final fatti = fattiOggi < 0 ? 0 : fattiOggi;
    return fatti >= max ? 0 : max - fatti;
  }
}
