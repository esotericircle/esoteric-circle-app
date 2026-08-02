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
        'Accesso al Cerchio con i tre Maestri',
        'I quattro elementi giornalieri: Rito dell\'Alba, Soffio del Destino, Oracolo del Giorno, Runa del Tramonto',
        'Carta natale occidentale in lettura base',
        'Tre domande al giorno a un Maestro, senza memoria',
        'Una carta di tarocchi al giorno',
        'Sinastria VIP fino a 3 al giorno',
        'Oroscopo settimanale base',
        'Angel Numbers e Angelo Custode una tantum',
        'Mood Tracker base, senza correlazione transiti',
        'Con piccolo banner inferiore e video reward opzionali',
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
        'Tutto di Viandante, senza pubblicità',
        'Memoria AI dei Maestri, esclusiva e persistente',
        'Carta natale completa con transiti dinamici',
        'Oroscopo settimanale dettagliato',
        '5 domande al giorno ai Maestri',
        '3 carte di tarocchi al giorno, stese complete a Eos scontati',
        'Sinastria VIP fino a 5 al giorno',
        'Sintesi comparativa dei tre Maestri',
        'Correlazione mood-transiti attiva',
        'Cosmic Journal completo, obiettivi e traguardi per Maestro',
        'Scelta della profondità di risposta: Breve, Media, Approfondita',
        'Rune, I-Ching e Pendolo a Eos scontati',
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
        'Tutto di Iniziato',
        'Voce AI dei tre Maestri, esclusiva',
        '10 domande al giorno ai Maestri',
        'Tarocchi carta singola illimitati',
        '5 stese complete di tarocchi al giorno',
        'Sinastria VIP fino a 5 al giorno',
        'Rune, I-Ching e Pendolo inclusi',
        'Oroscopo mensile',
        'Oracoli secondari, meditazioni e frequenze illimitati',
        'Transit tracker con alert',
        'Cosmic Journal con AI',
        'Memoria AI profonda, riconosce pattern e cicli',
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
        'Tutto di Adepto, davvero illimitato',
        'Domande ai Maestri illimitate',
        'Stese di tarocchi illimitate',
        'Sinastria VIP illimitata',
        'Una domanda al mese al Maestro reale, risposta entro 48 ore',
        'Compatibilità a tre livelli, esclusiva',
        'Albero della Vita dinamico, esclusivo',
        'Memoria anima, sintesi evolutiva',
        'Cosmic Journal completo con AI e report PDF esportabili',
        'Accesso anticipato alle nuove funzioni',
        'Eos bonus mensili al massimo, card dal design premium',
      ],
    ),
  ];

  /// La mappa funzioni per tier, riga per riga, nell'ordine delle colonne.
  /// Il limite giornaliero promesso da una riga della matrice, per un piano.
  ///
  /// LA MATRICE E' LA FONTE. Il contatore delle domande portava scritto 3 per
  /// il Viandante mentre la matrice prometteva 1: due numeri per la stessa
  /// cosa, in due file diversi, e quello sbagliato era quello che contava
  /// davvero. Adesso il numero esiste in un posto solo, qui, e chi deve
  /// imporlo lo legge invece di ricopiarlo.
  ///
  /// Restituisce null quando la promessa e' "illimitate", che e' cosa diversa
  /// da zero.
  static int? limiteGiornaliero(String etichettaRiga, Tier tier) {
    final riga = matrix.where((r) => r.label == etichettaRiga);
    if (riga.isEmpty) return null;
    const ordine = [Tier.free, Tier.tier1, Tier.tier2, Tier.tier3];
    final cella = riga.first.values[ordine.indexOf(tier)];
    if (cella.toLowerCase().contains('illimitat')) return null;
    final numero = RegExp(r'(\d+)').firstMatch(cella);
    if (numero != null) return int.parse(numero.group(1)!);
    // UNA CELLA CHE NON PROMETTE NIENTE VALE ZERO, NON "SENZA LIMITE".
    //
    // Prima qui si tornava null, che ogni chiamante legge come illimitato:
    // quindi "No" e "Illimitate" davano la stessa risposta, e una riga nuova
    // scritta con "No" avrebbe regalato la funzione a chi non la ha nel piano.
    // Non era ancora successo solo perche' nessuna riga interrogata per un
    // limite conteneva un "No".
    final pulita = cella.trim().toLowerCase();
    if (pulita == 'no' || pulita.isEmpty) return 0;
    return null;
  }

  /// Se quel piano ha diritto alla memoria dei Maestri.
  ///
  /// Letto dalla matrice, non deciso qui: la riga dice No per il Viandante ed
  /// Esclusiva dall'Iniziato in su, quindi la matrice sa gia' la risposta.
  static bool haMemoria(Tier tier) {
    final riga = matrix.where((r) => r.label == 'Memoria AI dei Maestri');
    if (riga.isEmpty) return true;
    const ordine = [Tier.free, Tier.tier1, Tier.tier2, Tier.tier3];
    return riga.first.values[ordine.indexOf(tier)].toLowerCase() != 'no';
  }

  /// Se quel piano ha diritto alla profondita' Profonda dell'oroscopo.
  ///
  /// Letto dalla matrice: la riga dell'oroscopo settimanale dice Base per il
  /// Viandante e Dettagliato dall'Iniziato in su. Prima nessuno lo leggeva, e
  /// la Profonda restava col lucchetto anche per chi l'aveva comprata.
  static bool haProfondita(Tier tier) {
    final riga = matrix.where((r) => r.label == 'Oroscopo settimanale');
    if (riga.isEmpty) return false;
    const ordine = [Tier.free, Tier.tier1, Tier.tier2, Tier.tier3];
    return riga.first.values[ordine.indexOf(tier)].toLowerCase() != 'base';
  }

  /// Cosa promettere a chi sale a quel piano, riguardo alle domande.
  ///
  /// Il testo diceva "senza limiti" per QUALUNQUE piano di destinazione,
  /// mentre solo l'Illuminato le ha davvero illimitate: chi saliva
  /// all'Iniziato per averle senza limiti ne trovava cinque. Adesso la frase
  /// nasce dal numero vero di quel piano.
  static String promessaDomande(Tier tier) {
    final limite = limiteGiornaliero(rigaDomande, tier);
    if (limite == null) {
      return 'Con questo cammino le domande ai Maestri sono senza limiti. '
          'Gli sguardi si possono anche mettere a confronto.';
    }
    final quante = limite == 1 ? 'una domanda' : '$limite domande';
    return 'Con questo cammino hai $quante al giorno ai Maestri, con gli '
        'sguardi che si possono mettere a confronto.';
  }

  /// Le etichette delle righe che portano un limite giornaliero, cosi' chi le
  /// usa non le scrive a mano e un refuso non passa inosservato.
  static const String rigaDomande = 'Domande a un Maestro';

  /// Quante volte al giorno si puo' chiedere a un Maestro di andare piu' a
  /// fondo sulla stessa risposta. E' una riga a se' perche' l'approfondimento
  /// NON consuma una domanda: se la consumasse, la persona esiterebbe prima di
  /// toccarlo, e l'esitazione uccide l'intimita'.
  static const String rigaApprofondimenti = 'Vai più a fondo';
  static const String rigaSinastria = 'Sinastria VIP';
  static const String rigaCartaSingola = 'Tarocchi carta singola';

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
    // TRE per il Viandante, che e' il numero deciso e approvato dal fondatore.
    // Diceva UNO, e l'app non mentiva: leggeva questo dato e lo ripeteva
    // fedelmente. A mentire era il dato. Era finito qui il 31 luglio, quando
    // una divergenza fra matrice e codice e' stata risolta facendo vincere la
    // matrice: la correzione era giusta nel metodo, sbagliata nel valore.
    FeatureRow('Domande a un Maestro',
        ['3 al giorno', '5 al giorno', '10 al giorno', 'Illimitate']),
    FeatureRow('Vai più a fondo',
        ['No', '3 al giorno', '10 al giorno', 'Illimitati']),
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
