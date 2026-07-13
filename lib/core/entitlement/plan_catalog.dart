import 'tier.dart';

/// I cicli di prezzo di un piano.
enum PriceCycle {
  weekly('Settimana', 'a settimana'),
  monthly('Mese', 'al mese'),
  yearly('Anno', "all'anno");

  const PriceCycle(this.label, this.per);

  /// L'etichetta breve del riquadro ciclo.
  final String label;

  /// La forma per il pulsante, ad esempio "89,90 all'anno".
  final String per;
}

/// I tre prezzi di un piano, piu' l'equivalenza mensile e lo sconto dell'anno.
/// I valori sono stringhe gia' formattate in euro, cosi' non dipendono da
/// arrotondamenti a runtime.
class PlanPrice {
  const PlanPrice({
    required this.weekly,
    required this.monthly,
    required this.yearly,
    required this.yearlyPerMonth,
    required this.yearlyDiscountPercent,
  });

  final String weekly;
  final String monthly;
  final String yearly;

  /// Quanto costa all'anno diviso per dodici, per mostrare il vantaggio.
  final String yearlyPerMonth;

  /// Lo sconto dell'annuale rispetto al mensile, in percentuale.
  final int yearlyDiscountPercent;

  String amount(PriceCycle cycle) {
    switch (cycle) {
      case PriceCycle.weekly:
        return weekly;
      case PriceCycle.monthly:
        return monthly;
      case PriceCycle.yearly:
        return yearly;
    }
  }
}

/// Un piano del cerchio: tier, nome e identita' nel mondo di Esoteric Circle, i
/// prezzi (assenti per il gratuito) e i vantaggi in evidenza sulla card.
class Plan {
  const Plan({
    required this.tier,
    required this.name,
    required this.identity,
    required this.highlights,
    this.price,
    this.highlighted = false,
  });

  final Tier tier;
  final String name;

  /// La riga di identita' del livello.
  final String identity;

  /// I prezzi nei tre cicli. Nullo per il Viandante gratuito.
  final PlanPrice? price;

  /// I vantaggi in evidenza sulla card, il primo e' la leva principale.
  final List<String> highlights;

  /// Il piano consigliato, messo in risalto.
  final bool highlighted;

  bool get isFree => tier == Tier.free;
}

/// Una riga della tabella comparativa: l'etichetta e i quattro valori, uno per
/// livello, nell'ordine Viandante, Iniziato, Adepto, Illuminato.
class FeatureRow {
  const FeatureRow(this.label, this.values);
  final String label;
  final List<String> values;
}

/// I quattro livelli canonici del briefing, con i prezzi e la mappa funzioni.
class PlanCatalog {
  const PlanCatalog._();

  /// Le intestazioni di colonna della tabella comparativa.
  static const List<String> columns = [
    'Viandante',
    'Iniziato',
    'Adepto',
    'Illuminato',
  ];

  static const List<Plan> plans = [
    Plan(
      tier: Tier.free,
      name: 'Viandante',
      identity: 'Esplora la soglia.',
      highlights: [
        'Una domanda al giorno a un Maestro',
        'I quattro rituali del giorno',
        'Carta natale, lettura base',
      ],
    ),
    Plan(
      tier: Tier.tier1,
      name: 'L\'Iniziato',
      identity: 'I Maestri ti conoscono e ti ricordano.',
      highlighted: true,
      price: PlanPrice(
        weekly: '2,90 €',
        monthly: '9,90 €',
        yearly: '89,90 €',
        yearlyPerMonth: '7,49 € al mese',
        yearlyDiscountPercent: 24,
      ),
      highlights: [
        // La Memoria AI e' la prima leva di conversione dal gratuito.
        'Memoria AI dei Maestri',
        'Cinque domande al giorno a un Maestro',
        'Sintesi comparativa dei Maestri',
        'Carta natale completa con i transiti',
      ],
    ),
    Plan(
      tier: Tier.tier2,
      name: 'L\'Adepto',
      identity: 'I Maestri ti parlano, anche con la voce.',
      price: PlanPrice(
        weekly: '4,90 €',
        monthly: '19,90 €',
        yearly: '179,90 €',
        yearlyPerMonth: '14,99 € al mese',
        yearlyDiscountPercent: 25,
      ),
      highlights: [
        'Voce AI dei Maestri, esclusiva',
        'Dieci domande al giorno a un Maestro',
        'Oroscopo mensile',
        'Tarocchi a carta singola illimitati',
      ],
    ),
    Plan(
      tier: Tier.tier3,
      name: 'L\'Illuminato',
      identity: 'Sei oltre il velo.',
      price: PlanPrice(
        weekly: '6,90 €',
        monthly: '29,90 €',
        yearly: '269,90 €',
        yearlyPerMonth: '22,49 € al mese',
        yearlyDiscountPercent: 25,
      ),
      highlights: [
        'Domande illimitate ai Maestri',
        'Una domanda al Maestro reale al mese',
        'Compatibilità a tre livelli, esclusiva',
        'Accesso anticipato alle nuove funzioni',
      ],
    ),
  ];

  /// La mappa funzioni per tier, riga per riga, nell'ordine delle colonne.
  static const List<FeatureRow> matrix = [
    FeatureRow('Pubblicità banner inferiore', ['Sì', 'No', 'No', 'No']),
    FeatureRow('Carta natale occidentale',
        ['Base lettura', 'Completa + transiti', 'Completa + transiti', 'Completa + transiti']),
    FeatureRow('Oracolo del Giorno', ['Sì', 'Sì', 'Sì', 'Sì']),
    FeatureRow('Soffio del Destino', ['Sì', 'Sì', 'Sì', 'Sì']),
    FeatureRow('Rito dell\'Alba', ['Sì', 'Sì', 'Sì', 'Sì']),
    FeatureRow('La Runa del Tramonto', ['Sì', 'Sì', 'Sì', 'Sì']),
    FeatureRow('Oroscopo settimanale',
        ['Base', 'Dettagliato', 'Dettagliato', 'Dettagliato']),
    FeatureRow('Oroscopo mensile', ['No', 'No', 'Sì', 'Sì']),
    FeatureRow('Memoria AI dei Maestri', ['No', 'Esclusiva', 'Sì', 'Sì']),
    FeatureRow('Domande a un Maestro',
        ['1 al giorno', '5 al giorno', '10 al giorno', 'Illimitate']),
    FeatureRow('Sintesi comparativa dei Maestri', ['No', 'Sì', 'Sì', 'Sì']),
    FeatureRow('Voce AI dei Maestri', ['No', 'No', 'Esclusiva', 'Sì']),
    FeatureRow('Tarocchi carta singola',
        ['1 al giorno', '3 al giorno', 'Illimitati', 'Illimitati']),
    FeatureRow('Stese complete tarocchi',
        ['Eos pieno', 'Eos scontati', '5 al giorno', 'Illimitate']),
    FeatureRow('Rune, I-Ching, Pendolo',
        ['Eos', 'Eos scontati', 'Inclusi', 'Inclusi']),
    FeatureRow('Sinastria VIP',
        ['3 al giorno', '5 al giorno', '5 al giorno', 'Illimitata']),
    FeatureRow('Correlazione mood-transiti', ['No', 'Sì', 'Sì', 'Sì']),
    FeatureRow('Cosmic Journal',
        ['Base', 'Completo', 'Completo + AI', 'Completo + AI + report']),
    FeatureRow('Compatibilità a tre livelli', ['No', 'No', 'No', 'Esclusiva']),
    FeatureRow('Albero della Vita dinamico', [
      'Contemplativo',
      'Contemplativo',
      'Contemplativo',
      'Dinamico esclusivo'
    ]),
    FeatureRow('Domanda al Maestro reale', ['No', 'No', 'No', '1 al mese']),
    FeatureRow('Accesso anticipato nuove funzioni', ['No', 'No', 'No', 'Sì']),
    FeatureRow('Eos bonus mensili', ['No', 'Medio', 'Alto', 'Massimo']),
  ];

  static Plan forTier(Tier tier) =>
      plans.firstWhere((p) => p.tier == tier, orElse: () => plans.first);
}
