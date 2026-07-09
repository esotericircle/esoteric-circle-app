/// Livelli di abbonamento dell'utente.
///
/// L'entitlement del tier, unito ai feature flag di Remote Config, governa lo
/// stato di ogni funzione (vedi `FeatureFlagService`). In C1 il tier e' un
/// valore locale di default; il collegamento a Firebase Auth e allo stato di
/// abbonamento arrivera' nei checkpoint successivi.
///
/// Riferimento: Master Tecnico sezione 25 e Briefing Operativo sezione 41.
enum Tier {
  free(level: 0, label: 'Free'),
  tier1(level: 1, label: 'Tier 1'),
  tier2(level: 2, label: 'Tier 2'),
  tier3(level: 3, label: 'Tier 3');

  const Tier({required this.level, required this.label});

  final int level;
  final String label;

  /// Vero se questo tier soddisfa il requisito minimo richiesto.
  bool satisfies(Tier required) => level >= required.level;
}
