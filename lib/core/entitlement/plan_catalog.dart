import 'tier.dart';

/// Un piano del cerchio: il tier, il nome nel mondo di Esoteric Circle, una
/// riga di richiamo e i suoi benefici. I prezzi sono una decisione di business
/// e nella Demo il pagamento non e' attivo: qui vivono nome e benefici.
class Plan {
  const Plan({
    required this.tier,
    required this.name,
    required this.tagline,
    required this.benefits,
    this.highlighted = false,
  });

  final Tier tier;
  final String name;
  final String tagline;
  final List<String> benefits;

  /// Il piano consigliato, messo in evidenza.
  final bool highlighted;
}

/// I quattro piani, dal gratuito ai tre livelli del cerchio.
class PlanCatalog {
  const PlanCatalog._();

  static const List<Plan> plans = [
    Plan(
      tier: Tier.free,
      name: 'Gratuito',
      tagline: 'Per iniziare il cammino.',
      benefits: [
        'Una domanda al giorno a un Maestro',
        'Il cielo sopra di te ogni notte',
        'Cosmic Passport, i fatti dalla tua data',
      ],
    ),
    Plan(
      tier: Tier.tier1,
      name: 'Cerchio',
      tagline: 'Il dialogo senza limiti.',
      highlighted: true,
      benefits: [
        'Domande illimitate ai Maestri',
        'Chiedi a più Maestri, gli sguardi a confronto',
        'Memoria estesa del tuo cammino',
      ],
    ),
    Plan(
      tier: Tier.tier2,
      name: 'Cerchio d\'Oro',
      tagline: 'Tutti i rituali del giorno.',
      benefits: [
        'Tutto del Cerchio',
        'I quattro rituali quotidiani completi',
        'La cartolina del cielo senza limiti',
      ],
    ),
    Plan(
      tier: Tier.tier3,
      name: 'Cerchio Astrale',
      tagline: 'L\'ecosistema intero.',
      benefits: [
        'Tutto del Cerchio d\'Oro',
        'La carta natale completa sulle effemeridi',
        'Le meditazioni e le frequenze avanzate',
      ],
    ),
  ];

  static Plan forTier(Tier tier) =>
      plans.firstWhere((p) => p.tier == tier, orElse: () => plans.first);
}
