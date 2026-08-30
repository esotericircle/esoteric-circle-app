import 'listino_degli_eos.dart';
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

  /// **I TRE PREZZI ANNUALI SONO CAMBIATI. Ordine CE voce 07.**
  ///
  /// Decisione del fondatore del 29 agosto 2026: l'Iniziato passa da 89,90 a
  /// **99,90**, l'Adepto da 179,90 a **189,90**, l'Illuminato da 269,90 a
  /// **279,90**. La sua ragione, verbatim: "gli abbonamenti annuali avranno
  /// una sconto minore rispetto adesso".
  ///
  /// **Settimanale e mensile non si toccano**, ed e' un fatto misurato: i
  /// numeri che il fondatore ha indicato come nuovi per l'Iniziato, 2,90 alla
  /// settimana e 9,90 al mese, erano gia' esattamente quelli in vigore.
  ///
  /// **Gli sconti sono RICALCOLATI dal prezzo e non lasciati scritti a mano.**
  /// Erano 24, 25 e 25 per cento e adesso sono **16, 21 e 22**, cioe'
  /// esattamente lo sconto minore che il fondatore ha chiesto. Il conto e'
  /// `1 - annuale / (mensile * 12)`, arrotondato all'intero: 99,90 contro
  /// 118,80 fa il 15,9; 189,90 contro 238,80 fa il 20,5; 279,90 contro 358,80
  /// fa il 22,0. Anche il per-mese e' rifatto: annuale diviso dodici.
  static const List<Plan> plans = [
    Plan(
      tier: Tier.free,
      name: 'Viandante',
      identity: 'Esplora la soglia.',
      highlights: [
        'Accesso al Cerchio con i tre Maestri',
        'I quattro elementi giornalieri: Rito dell\'Alba, Soffio del Destino, Arcano del Giorno, Runa del Tramonto',
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
        yearly: '99,90 €',
        yearlyPerMonth: '8,33 € al mese',
        yearlyDiscountPercent: 16,
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
        yearly: '189,90 €',
        yearlyPerMonth: '15,83 € al mese',
        yearlyDiscountPercent: 21,
      ),
      highlights: [
        'Tutto di Iniziato',
        'Voce AI dei tre Maestri, esclusiva',
        '10 domande al giorno ai Maestri',
        'Tarocchi carta singola, 30 al giorno',
        '5 stese complete di tarocchi al giorno',
        'Sinastria VIP fino a 5 al giorno',
        'Rune, I-Ching e Pendolo inclusi',
        'Oroscopo mensile',
        'Oracoli secondari, meditazioni e frequenze, 30 al giorno',
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
        yearly: '279,90 €',
        yearlyPerMonth: '23,32 € al mese',
        yearlyDiscountPercent: 22,
      ),
      highlights: [
        'Tutto di Adepto, coi tetti piu\' alti del Cerchio',
        '50 domande ai Maestri al giorno',
        '50 stese di tarocchi al giorno',
        '25 sinastrie VIP al giorno',
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
    // **L'ILLIMITATO NON ESISTE PIU', E NON C'E' PIU' LA STRADA PER
    // RIAPRIRLO.** Ordine CE voce 08.
    //
    // **Le parole del fondatore:** "illimitato mi espone all'abuso o uso
    // incontrollato o bot, quindi e' da eliminare e da sostituire con un
    // numero abbastanza ampio da essere piu' che sufficiente per l'utente".
    //
    // Qui c'era `if (cella.contains('illimitat')) return null`, e il nullo
    // ogni chiamante lo legge come "nessun tetto": togliere la parola dalle
    // celle senza togliere questa riga avrebbe lasciato la porta aperta al
    // primo che la riscrive. **Adesso una cella che dicesse "Illimitato"
    // cadrebbe in fondo a questa funzione e varrebbe ZERO**, cioe' si
    // chiuderebbe invece di aprirsi: nel dubbio si sbaglia dalla parte del
    // tetto, non dell'abuso. E una prova enumera ogni cella della matrice.
    // **UNA CELLA CHE DICE EOS NON REGALA NIENTE: VALE ZERO USI GRATIS.**
    //
    // Ordine BN voce 09, ed e' la stessa forma del difetto che il commento
    // qui sotto racconta per il "No". Le righe dei tarocchi e degli oracoli
    // promettono "Eos pieno", "Eos scontati", "Eos": vuol dire che quella
    // cosa si COMPRA, non che si ha senza limite. Prima di questa riga
    // "Eos pieno" cadeva in fondo alla funzione e tornava null, cioe' la
    // stessa risposta di "Illimitate": il Viandante avrebbe avuto le stese
    // complete gratis e infinite proprio dove il listino dice che le paga.
    // Zero usi gratis non e' un vicolo cieco: e' il presupposto della strada
    // degli Eos, che il gating a due strade apre subito.
    if (cella.toLowerCase().contains('eos')) return 0;
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

  /// SE QUEL PIANO PORTA EOS OGNI MESE, e con quale parola lo promette.
  ///
  /// Nullo per chi non ne ha nessuno. **La matrice promette un livello e non un
  /// numero** (No, Medio, Alto, Massimo), e questa funzione restituisce quella
  /// parola senza tradurla in una cifra: il portafoglio dice alla persona che
  /// il piano porta un bonus, non quanto, perche' un numero inventato nel
  /// borsellino e' peggio di un numero assente.
  /// LA DOTE DELLA PRIMA SOTTOSCRIZIONE, ordine AN voce 07.
  ///
  /// Chi sottoscrive un piano riceve una dote in Eos: 500 all'Iniziato,
  /// 1.500 all'Adepto, 3.000 all'Illuminato. **Il dato e' pronto e la pagina
  /// lo mostra come valore del piano; l'accredito vero scattera' quando gli
  /// abbonamenti saranno acquistabili**, e fino ad allora non si promette
  /// nessuna data, perche' una data promessa e non mantenuta vale meno di un
  /// silenzio onesto.
  static const Map<Tier, int> doteDellaSottoscrizione = {
    Tier.free: 0,
    Tier.tier1: 500,
    Tier.tier2: 1500,
    Tier.tier3: 3000,
  };

  /// La dote scritta come si legge, col numero e la moneta, oppure nulla
  /// per il piano
  /// gratuito, che non ne ha una.
  static String? doteScritta(Tier tier) {
    final quanti = doteDellaSottoscrizione[tier] ?? 0;
    if (quanti <= 0) return null;
    final crudo = quanti.toString();
    final testo = StringBuffer();
    for (var i = 0; i < crudo.length; i++) {
      if (i > 0 && (crudo.length - i) % 3 == 0) testo.write('.');
      testo.write(crudo[i]);
    }
    // La parola si compone, non si scrive accanto al numero: un prezzo
    // scritto a mano fuori dal listino e' esattamente cio' che la guardia
    // dell'ordine AN voce 05 vieta, e questa e' la stessa famiglia.
    return '$testo ${ListinoDegliEos.moneta}';
  }

  static String? eosOgniMese(Tier tier) {
    final riga = matrix.where((r) => r.label == 'Eos bonus mensili');
    if (riga.isEmpty) return null;
    const ordine = [Tier.free, Tier.tier1, Tier.tier2, Tier.tier3];
    final valore = riga.first.values[ordine.indexOf(tier)];
    return valore.toLowerCase() == 'no' ? null : valore;
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
  /// Quanti confronti nel Consiglio dei Maestri al giorno.
  ///
  /// **E' una riga a se', accanto alle domande e agli approfondimenti.** Il
  /// confronto non consuma domande in piu' di quella gia' pagata nella chat,
  /// ed e' misurato: le altre due letture arrivano senza contare. Senza un
  /// tetto suo, pero', il gesto sarebbe gratuito e ripetibile all'infinito, e
  /// ogni tocco sono due chiamate al modello.
  static const String rigaConfronti = 'Confronti nel Cerchio';
  static const String rigaSinastria = 'Sinastria VIP';
  static const String rigaCartaSingola = 'Tarocchi carta singola';

  /// Quante STESE COMPLETE di tarocchi al giorno, che e' una riga diversa da
  /// [rigaCartaSingola] e non un suo sinonimo.
  ///
  /// **LA DISTINZIONE E' DEL BRIEFING E NON DI QUESTO FILE.** Il Briefing
  /// Progetto, alla sezione della cartomanzia, dice "carta singola quotidiana
  /// e stese complete, dalla tre carte alla Croce Celtica": la stesa a tre
  /// carte e' la piu' piccola delle stese COMPLETE, non una carta singola.
  /// Percio' la schermata della stesa legge questa riga, dove il Viandante
  /// paga in Eos pieni e l'Iniziato in Eos scontati, e non quella della carta
  /// singola, dove il Viandante ha il suo gesto gratis del giorno.
  static const String rigaStese = 'Stese complete tarocchi';

  /// Quante gettate di rune al giorno. IL NUMERO VIVE QUI, ordine I voce 3:
  /// UNA per il Viandante (cosi' dice la matrice qui sotto, che e' sovrana),
  /// illimitate dall'Iniziato in su. Il commento diceva "tre" mentre la
  /// matrice diceva una: trovato dall'ordine BF guardando la cattura, e vale
  /// la matrice. La schermata delle rune legge da qui e non riscrive.
  static const String rigaGettate = 'Gettate di rune';

  static const List<FeatureRow> matrix = [
    FeatureRow('Pubblicità banner inferiore', ['Sì', 'No', 'No', 'No']),
    FeatureRow('Carta natale occidentale',
        ['Base lettura', 'Completa + transiti', 'Completa + transiti', 'Completa + transiti']),
    FeatureRow('Arcano del Giorno', ['Sì', 'Sì', 'Sì', 'Sì']),
    FeatureRow('Soffio del Destino', ['Sì', 'Sì', 'Sì', 'Sì']),
    FeatureRow('Rito dell\'Alba', ['Sì', 'Sì', 'Sì', 'Sì']),
    FeatureRow('La Runa del Tramonto', ['Sì', 'Sì', 'Sì', 'Sì']),
    FeatureRow('Oroscopo settimanale',
        ['Base', 'Dettagliato', 'Dettagliato', 'Dettagliato']),
    FeatureRow('Oroscopo mensile', ['No', 'No', 'Sì', 'Sì']),
    FeatureRow('Memoria AI dei Maestri', ['No', 'Esclusiva', 'Sì', 'Sì']),
    // I CONFRONTI DEL GIORNO, decisi dal fondatore il 4 agosto 2026: il
    // Viandante non ce l'ha, l'Iniziato tre, l'Adepto cinque, l'Illuminato
    // senza limite col tetto di correttezza.
    FeatureRow('Confronti nel Cerchio', ['No', '3', '5', '20 al giorno']),
    // TRE per il Viandante, che e' il numero deciso e approvato dal fondatore.
    // Diceva UNO, e l'app non mentiva: leggeva questo dato e lo ripeteva
    // fedelmente. A mentire era il dato. Era finito qui il 31 luglio, quando
    // una divergenza fra matrice e codice e' stata risolta facendo vincere la
    // matrice: la correzione era giusta nel metodo, sbagliata nel valore.
    FeatureRow('Domande a un Maestro',
        ['3 al giorno', '5 al giorno', '10 al giorno', '50 al giorno']),
    FeatureRow('Vai più a fondo',
        ['No', '3 al giorno', '10 al giorno', '30 al giorno']),
    FeatureRow('Sintesi comparativa dei Maestri', ['No', 'Sì', 'Sì', 'Sì']),
    FeatureRow('Voce AI dei Maestri', ['No', 'No', 'Esclusiva', 'Sì']),
    FeatureRow('Tarocchi carta singola',
        ['1 al giorno', '3 al giorno', '30 al giorno', '50 al giorno']),
    // **UNA STESA AL GIORNO AL VIANDANTE, ordine BU voce 04, e la decisione
    // e' del fondatore: "il viandante ha una stesa al giorno".** La cella
    // diceva "Eos pieno", che questa classe legge come zero usi gratis: era
    // la lettura del listino fatta dall'ordine BN voce 09, e il fondatore la
    // supera. **La parola Eos non puo' restare nella cella**: chi legge i
    // limiti guarda prima se c'e' scritto Eos e in quel caso risponde zero,
    // quindi "1 al giorno, poi Eos" avrebbe continuato a valere zero. La
    // strada degli Eos resta dopo la stesa del giorno, dove il gating la
    // apre a 150 Eos: e' il cancello, non il listino.
    // **UNO, QUATTRO, SETTE E VENTI, ordine BV voce 03, e supera i numeri
    // dell'ordine BU.** Decisione del fondatore sulla 2209: "le stese devono
    // essere gratis 1, tier 1 4 stese, tier 2 7 stese e tier 3 20 stese. tu mi
    // hai insegnato di non fare nulla di illimitato". **L'illimitato sparisce
    // anche dall'ultimo livello**, ed e' un principio, non un numero.
    FeatureRow('Stese complete tarocchi',
        ['1 al giorno', '4 al giorno', '7 al giorno', '20 al giorno']),
    FeatureRow('Rune, I-Ching, Pendolo',
        ['Eos', 'Eos scontati', 'Inclusi', 'Inclusi']),
    // UNA GETTATA AL GIORNO PER IL VIANDANTE, deciso da Mauro con l'ordine O
    // del 12 agosto 2026. Erano tre dall'ordine I: il numero e' sceso perche'
    // la gettata e' il gesto che porta indietro domani, e tre al giorno lo
    // consumavano in un pomeriggio. Dal Tier 1 in su restano illimitate.
    FeatureRow('Gettate di rune',
        ['1 al giorno', '20 al giorno', '30 al giorno', '50 al giorno']),
    FeatureRow('Sinastria VIP',
        ['3 al giorno', '5 al giorno', '5 al giorno', '25 al giorno']),
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
    // LA DOTE DI BENVENUTO DEL PIANO, ordine AN voce 07: si mostra come
    // valore del piano, e la riga dice che arriva alla sottoscrizione.
    FeatureRow('Eos in dono alla sottoscrizione',
        ['No', '500', '1.500', '3.000']),
    FeatureRow('Domanda al Maestro reale', ['No', 'No', 'No', '1 al mese']),
    FeatureRow('Accesso anticipato nuove funzioni', ['No', 'No', 'No', 'Sì']),
    FeatureRow('Eos bonus mensili', ['No', 'Medio', 'Alto', 'Massimo']),
  ];

  static Plan forTier(Tier tier) =>
      plans.firstWhere((p) => p.tier == tier, orElse: () => plans.first);
}
