import 'listino_degli_eos.dart';
import 'tier.dart';
import '../l10n/numero_del_cerchio.dart';

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
  const FeatureRow(this.label, this.values, {this.chiave});
  final String label;
  final List<String> values;

  /// **LA CHIAVE STABILE, per le righe che il codice legge.** Ordine DI voce
  /// 01, 12 settembre 2026. Nulla per le righe che si leggono solo nella
  /// tabella dei piani.
  ///
  /// **Prima le righe si cercavano per [label]**, cioe' col testo che la
  /// persona legge: ritoccare una parola della tabella bastava a far
  /// ripiegare in silenzio ogni ricerca, e i ripieghi erano la memoria gratis
  /// a tutti, i limiti giornalieri illimitati, la Profonda tolta a chi l'aveva
  /// pagata. L'etichetta si puo' riscrivere quando si vuole; la chiave no.
  final RigaDelPiano? chiave;
}

/// **LE RIGHE DELLA MATRICE CHE IL CODICE LEGGE**, come tipo e non come testo.
/// Ordine DI voce 01, 12 settembre 2026.
///
/// E' la stessa cura del tema della domanda del Viaggio, trovata censendo la
/// stessa famiglia: un'etichetta per persone usata come identificatore. Una
/// guardia pretende che ognuna compaia **una volta sola** nella matrice, cosi'
/// una riga non puo' sparire senza che la prova lo dica.
enum RigaDelPiano {
  domande,
  approfondimenti,
  confronti,
  sinastria,

  /// **LE CARTE ESTRATTE NELLE STESE, ordine EX voce 02.** La chiave resta
  /// `stese`, come il budget del server, ma l'unita' e' la carta: chi
  /// stende tre carte ne spende tre. La carta singola e' una stesa da una
  /// carta, e conta qui.
  stese,

  /// La stesa da dieci carte, solo dall'Adepto. Ordine EX voce 02.
  stesaDaDieci,

  /// I minuti del LIVE al mese. Ordine EX voce 02; il server li conta in
  /// `functions/src/live.ts`, `MINUTI_DEL_MESE`.
  minutiLive,
  gettate,
  memoria,
  oroscopoSettimanale,

  /// **LA PROFONDITA' DELL'OROSCOPO**, ordine ES voce 06: Breve per il
  /// Viandante, Breve o Lunga dall'Iniziato. Prima si leggeva dalla
  /// riga del settimanale ("Base"), che adesso dice solo se il settimanale
  /// c'e'.
  profondita,
  eosMensili,

  /// **LE TRE RIGHE DEL VIAGGIO DELLO SCIAMANO**, ordine DI voce 15.
  discese,
  segni,
  nutrimento,

  /// **I SIGILLI DELL'INTENZIONE VIVI INSIEME**, ordine DO voce 11.
  sigilliVivi,

  /// **LA CARICA DEL SIGILLO**, sempre: non chiama nessun modello.
  caricaDelSigillo,

  /// **GLI AMICI OFFLINE**, ordine ES voce 12: quanti amici tiene il piano.
  amici,

  /// **I POSTI DEL LEGAME FRA ACCOUNT**, ordine EY voce 07: cosa diversa
  /// dagli amici offline. Il server li impone con `POSTI_DEL_LEGAME` in
  /// `functions/src/sociale.ts`, e una prova pretende che siano questi.
  legami,

  /// **I SEGNI DEL CERCHIO AL GIORNO**, ordine EY voce 10. Il server:
  /// `SEGNI_AL_GIORNO` in `functions/src/sociale.ts`.
  segniDelCerchio,

  /// **I CONFRONTI DEL CIELO CON UN AMICO AL GIORNO**, ordine EY voce 13. Il
  /// server: il budget `cieli` in `functions/src/budget.ts`.
  cieli,

  /// **LA SCINTILLA E IL SIGILLO DA DONARE**, ordine EY voce 12: dall'Adepto
  /// in su. Il cenno e' di tutti e non sta in questa riga.
  doni,
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
  ///
  /// **I PREZZI IN NOVANTANOVE, 1 ottobre 2026.** Il fondatore: *"Gli
  /// abbonamenti e quindi foni riferimento sono cambiati in 2,99 - 9,99 -
  /// 19,99 - 29,99"*: l'Iniziato 2,99 alla settimana e 9,99 al mese,
  /// l'Adepto 19,99 al mese, l'Illuminato 29,99 al mese. Gli altri prezzi
  /// (il settimanale dell'Adepto e dell'Illuminato, i tre annuali) non li ha
  /// nominati e restano. Lo sconto annuale ricalcolato con la regola qui
  /// sopra: 99,90 contro 119,88 fa il 16,7, quindi **17**; 189,90 contro
  /// 239,88 fa il 20,8, quindi 21; 279,90 contro 359,88 fa il 22,2, quindi 22.
  ///
  /// **TUTTO A 99, ordine EV voce 01, 2 ottobre 2026.** Alla domanda se
  /// portare a ,99 anche gli altri il fondatore ha risposto *"Si, tutto a
  /// 99"*: l'Adepto 4,99 alla settimana e 189,99 all'anno, l'Illuminato 6,99
  /// alla settimana e 279,99 all'anno, l'Iniziato 99,99 all'anno. Gli sconti
  /// col conto di sopra restano 17, 21 e 22 (99,99 contro 119,88 fa il 16,6;
  /// 189,99 contro 239,88 il 20,8; 279,99 contro 359,88 il 22,2), e il prezzo
  /// al mese dell'annuale e' l'annuale diviso dodici arrotondato al
  /// centesimo: 8,33, 15,83 e 23,33. La prova `entitlement_test` rifà i conti.
  static const List<Plan> plans = [
    Plan(
      tier: Tier.free,
      name: 'Viandante',
      identity: 'Esplora la soglia.',
      highlights: [
        'Accesso al Cerchio con i tre Maestri',
        'I Doni del giorno: Arcano dell\'Alba, Soffio del Destino, Runa del Tramonto e Sigillo del Sogno',
        'Carta natale occidentale in lettura base',
        'Tre domande al giorno a un Maestro, senza memoria',
        'Tre carte di tarocchi al giorno, da stendere come vuoi',
        'Sinastria VIP fino a 3 al giorno',
        'Oroscopo del giorno occidentale; il tuo segno cinese e vedico',
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
        weekly: '2,99 €',
        monthly: '9,99 €',
        yearly: '99,99 €',
        yearlyPerMonth: '8,33 € al mese',
        yearlyDiscountPercent: 17,
      ),
      highlights: [
        'Tutto di Viandante, senza pubblicità',
        'Memoria AI dei Maestri, esclusiva e persistente',
        'Carta natale completa con transiti dinamici',
        'Oroscopo settimanale',
        '12 domande al giorno ai Maestri',
        '6 carte di tarocchi al giorno, da stendere come vuoi',
        'Sinastria VIP fino a 5 al giorno',
        'Sintesi comparativa dei tre Maestri',
        'Correlazione mood-transiti attiva',
        'Cosmic Journal completo, obiettivi e traguardi per Maestro',
        'L\'oroscopo completo, su ogni scheda e ogni giorno',
        'Oroscopo cinese del giorno, dall\'almanacco e dai Dieci Dei',
        'Oroscopo vedico del giorno, dalla Luna siderale e dal Rahu Kalam',
        'L’oroscopo per gli amici, fino a tre',
        '2 gettate di rune al giorno; I-Ching e Pendolo a Eos scontati',
      ],
    ),
    Plan(
      tier: Tier.tier2,
      name: 'L\'Adepto',
      identity: 'I Maestri ti parlano, anche con la voce.',
      price: PlanPrice(
        weekly: '4,99 €',
        monthly: '19,99 €',
        yearly: '189,99 €',
        yearlyPerMonth: '15,83 € al mese',
        yearlyDiscountPercent: 21,
      ),
      highlights: [
        'Tutto di Iniziato',
        'Voce AI dei tre Maestri nel LIVE, 80 minuti al mese',
        '18 domande al giorno ai Maestri',
        '10 carte di tarocchi al giorno, da stendere come vuoi',
        'La stesa a dieci carte, appena arriva nel Cerchio',
        'Sinastria VIP fino a 5 al giorno',
        '3 gettate di rune al giorno; I-Ching e Pendolo inclusi',
        'Oroscopo mensile',
        'Oroscopo dell’anno dal compleanno, con la Rivoluzione Solare',
        'L’oroscopo per gli amici, fino a dieci',
        'Oracoli secondari, meditazioni e frequenze',
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
        weekly: '6,99 €',
        monthly: '29,99 €',
        yearly: '279,99 €',
        yearlyPerMonth: '23,33 € al mese',
        yearlyDiscountPercent: 22,
      ),
      highlights: [
        'Tutto di Adepto, coi tetti più alti del Cerchio',
        '22 domande ai Maestri al giorno',
        '15 carte di tarocchi al giorno, anche nella stesa a dieci carte',
        'Voce AI dei tre Maestri nel LIVE, 150 minuti al mese',
        '25 sinastrie VIP al giorno',
        // **QUI C'ERA LA DOMANDA AL MAESTRO REALE**, una al mese con risposta
        // entro quarantotto ore. Uscita con l'ordine DJ voce 09: nessuna
        // parte dell'app la esegue, e se reale vuol dire una persona non e'
        // codice che manca, e' un operatore da ingaggiare. Non si offre e non
        // si conta fra cio' che il piano da'.
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
  static int? limiteGiornaliero(RigaDelPiano chiave, Tier tier) {
    final riga = matrix.where((r) => r.chiave == chiave);
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

  /// **UN LIMITE CHE PUO' ESSERE AL GIORNO O ALLA SETTIMANA.** Ordine DI voce
  /// 15: i segni chiesti all'animale sono *"Viandante 1 a settimana, Iniziato
  /// 3 a settimana, Adepto 1 al giorno, Illuminato 5 al giorno"*.
  ///
  /// **Perche' non basta [limiteGiornaliero].** Legge il primo numero della
  /// cella, e *"1 a settimana"* per lui e' uno al giorno: il Viandante avrebbe
  /// avuto sette segni dove il listino ne promette uno. Qui il periodo si
  /// legge dalla cella, e la stessa legge dello zero vale: una cella senza
  /// numero non apre niente.
  static ({int quanti, bool allaSettimana}) limiteDelPeriodo(
      RigaDelPiano chiave, Tier tier) {
    final riga = matrix.where((r) => r.chiave == chiave);
    if (riga.isEmpty) return (quanti: 0, allaSettimana: false);
    const ordine = [Tier.free, Tier.tier1, Tier.tier2, Tier.tier3];
    final cella = riga.first.values[ordine.indexOf(tier)].toLowerCase();
    final numero = RegExp(r'(\d+)').firstMatch(cella);
    return (
      quanti: numero == null ? 0 : int.parse(numero.group(1)!),
      allaSettimana: cella.contains('settiman'),
    );
  }

  /// **SE QUEL PIANO APRE LA STESA DA DIECI CARTE.** Ordine EX voce 02: solo
  /// dall'Adepto, *"la stesa a 10 solo dal tier 2 19,99"*.
  static bool haLaStesaDaDieci(Tier tier) {
    final riga = matrix.where((r) => r.chiave == RigaDelPiano.stesaDaDieci);
    if (riga.isEmpty) return false;
    const ordine = [Tier.free, Tier.tier1, Tier.tier2, Tier.tier3];
    return riga.first.values[ordine.indexOf(tier)] == 'Sì';
  }

  /// I minuti di LIVE al mese di quel piano. Ordine EX voce 02. La cella dice
  /// "al mese": [limiteGiornaliero] non va chiesto per questa riga.
  static int minutiDelLiveAlMese(Tier tier) {
    final riga = matrix.where((r) => r.chiave == RigaDelPiano.minutiLive);
    if (riga.isEmpty) return 0;
    const ordine = [Tier.free, Tier.tier1, Tier.tier2, Tier.tier3];
    final numero =
        RegExp(r'(\d+)').firstMatch(riga.first.values[ordine.indexOf(tier)]);
    return numero == null ? 0 : int.parse(numero.group(1)!);
  }

  /// Se quel piano ha diritto alla memoria dei Maestri.
  ///
  /// Letto dalla matrice, non deciso qui: la riga dice No per il Viandante ed
  /// Esclusiva dall'Iniziato in su, quindi la matrice sa gia' la risposta.
  static bool haMemoria(Tier tier) {
    final riga = matrix.where((r) => r.chiave == RigaDelPiano.memoria);
    if (riga.isEmpty) return true;
    const ordine = [Tier.free, Tier.tier1, Tier.tier2, Tier.tier3];
    return riga.first.values[ordine.indexOf(tier)].toLowerCase() != 'no';
  }

  /// Se quel piano ha diritto alla profondita' Profonda dell'oroscopo.
  ///
  /// Letto dalla matrice: la riga della profondita' dice Breve per il
  /// Viandante e Breve o Lunga dall'Iniziato in su. Prima nessuno lo
  /// leggeva, e la Profonda restava col lucchetto anche per chi l'aveva
  /// comprata; poi si leggeva dalla riga del settimanale, che dall'ordine ES
  /// voce 06 dice solo se il settimanale c'e'.
  static bool haProfondita(Tier tier) {
    final riga = matrix.where((r) => r.chiave == RigaDelPiano.profondita);
    if (riga.isEmpty) return false;
    const ordine = [Tier.free, Tier.tier1, Tier.tier2, Tier.tier3];
    // Dall'ordine EU voce 15 la cella del Viandante dice anche gli Eos per
    // un giorno; dalla sera del 1 ottobre 2026 la riga parla con le parole di
    // chi legge ("Oroscopo completo": "Sempre"), e il piano ce l'ha quando
    // la sua cella dice "Sempre".
    return riga.first.values[ordine.indexOf(tier)].toLowerCase() == 'sempre';
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
    // **IL SEPARATORE LO METTE LA LINGUA. Ordine DM, coda del fondatore.**
    // Qui c'era la stessa identica funzione del borsellino, copiata parola
    // per parola: tre copie della stessa regola in tre file, e in inglese
    // tutte e tre avrebbero scritto il punto dove ci vuole la virgola.
    final testo = StringBuffer(NumeroDelCerchio.interi(quanti));
    // La parola si compone, non si scrive accanto al numero: un prezzo
    // scritto a mano fuori dal listino e' esattamente cio' che la guardia
    // dell'ordine AN voce 05 vieta, e questa e' la stessa famiglia.
    return '$testo ${ListinoDegliEos.moneta}';
  }

  static String? eosOgniMese(Tier tier) {
    final riga = matrix.where((r) => r.chiave == RigaDelPiano.eosMensili);
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

  /// Le righe che portano un limite giornaliero, cosi' chi le usa non le
  /// scrive a mano.
  ///
  /// **Erano l'etichetta della tabella, scritta una seconda volta.** Ordine DI
  /// voce 01: adesso sono la chiave della riga, e l'etichetta vive solo nella
  /// matrice. I nomi di queste costanti non sono cambiati, e' cambiato il loro
  /// tipo.
  static const RigaDelPiano rigaDomande = RigaDelPiano.domande;

  /// Quante volte al giorno si puo' chiedere a un Maestro di andare piu' a
  /// fondo sulla stessa risposta. E' una riga a se' perche' l'approfondimento
  /// NON consuma una domanda: se la consumasse, la persona esiterebbe prima di
  /// toccarlo, e l'esitazione uccide l'intimita'.
  static const RigaDelPiano rigaApprofondimenti = RigaDelPiano.approfondimenti;

  /// Quanti confronti nel Consiglio dei Maestri al giorno.
  ///
  /// **E' una riga a se', accanto alle domande e agli approfondimenti.** Il
  /// confronto non consuma domande in piu' di quella gia' pagata nella chat,
  /// ed e' misurato: le altre due letture arrivano senza contare. Senza un
  /// tetto suo, pero', il gesto sarebbe gratuito e ripetibile all'infinito, e
  /// ogni tocco sono due chiamate al modello.
  static const RigaDelPiano rigaConfronti = RigaDelPiano.confronti;
  static const RigaDelPiano rigaSinastria = RigaDelPiano.sinastria;

  /// La carta singola e' una stesa da una carta: conta fra le carte
  /// estratte. Ordine EX voce 02.
  static const RigaDelPiano rigaCartaSingola = RigaDelPiano.stese;

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
  static const RigaDelPiano rigaStese = RigaDelPiano.stese;

  /// Quante gettate di rune al giorno. IL NUMERO VIVE QUI, ordine I voce 3:
  /// UNA per il Viandante (cosi' dice la matrice qui sotto, che e' sovrana),
  /// illimitate dall'Iniziato in su. Il commento diceva "tre" mentre la
  /// matrice diceva una: trovato dall'ordine BF guardando la cattura, e vale
  /// la matrice. La schermata delle rune legge da qui e non riscrive.
  static const RigaDelPiano rigaGettate = RigaDelPiano.gettate;

  /// I confronti del cielo con un amico al giorno, ordine EY voce 13.
  static const RigaDelPiano rigaCieli = RigaDelPiano.cieli;

  static const List<FeatureRow> matrix = [
    FeatureRow('Pubblicità banner inferiore', ['Sì', 'No', 'No', 'No']),
    FeatureRow('Carta natale occidentale', [
      'Base lettura',
      'Completa + transiti',
      'Completa + transiti',
      'Completa + transiti'
    ]),
    FeatureRow('Soffio del Destino', ['Sì', 'Sì', 'Sì', 'Sì']),
    FeatureRow('Arcano dell\'Alba', ['Sì', 'Sì', 'Sì', 'Sì']),
    FeatureRow('La Runa del Tramonto', ['Sì', 'Sì', 'Sì', 'Sì']),
    // IL SETTIMANALE NON E' DEL VIANDANTE, ordine ES voce 06. Il fondatore:
    // "vorrei che l'utente free non avesse accesso al settimanale".
    FeatureRow('Oroscopo settimanale', ['No', 'Sì', 'Sì', 'Sì'],
        chiave: RigaDelPiano.oroscopoSettimanale),
    // LA LUNGA DEL GIORNO CON GLI EOS, ordine EU voce 15: il Viandante la
    // apre per la giornata con 50 Eos (tabella ES.06).
    // **CON LE PAROLE DI CHI LEGGE**, il fondatore il 1 ottobre 2026 sera:
    // "la Lunga" chi legge non la capisce, e l'oroscopo completo si', che
    // cosa sia e quando ce l'ha.
    FeatureRow('Oroscopo completo',
        ['Con gli Eos, per un giorno', 'Sempre', 'Sempre', 'Sempre'],
        chiave: RigaDelPiano.profondita),
    FeatureRow('Oroscopo mensile', ['No', 'No', 'Sì', 'Sì']),
    // L'ANNO DAL COMPLEANNO, ordine ES voce 04: "dall'Adepto in su, 300 Eos,
    // PDF all'Illuminato".
    FeatureRow('Oroscopo dell’anno',
        ['Con gli Eos', 'Con gli Eos', 'Sì', 'Sì, col PDF']),
    // LA TRADIZIONE CINESE, ordine ES voce 08: il Viandante ne vede il
    // segno, la lettura del giorno e' dall'Iniziato in su.
    FeatureRow(
        'Oroscopo cinese del giorno', ['Solo il segno', 'Sì', 'Sì', 'Sì']),
    // LA TRADIZIONE VEDICA, ordine ES voce 09: come la Cinese.
    FeatureRow(
        'Oroscopo vedico del giorno', ['Solo il segno', 'Sì', 'Sì', 'Sì']),
    FeatureRow('Memoria AI dei Maestri', ['No', 'Esclusiva', 'Sì', 'Sì'],
        chiave: RigaDelPiano.memoria),
    // I CONFRONTI DEL GIORNO, decisi dal fondatore il 4 agosto 2026: il
    // Viandante non ce l'ha, l'Iniziato tre, l'Adepto cinque, l'Illuminato
    // senza limite col tetto di correttezza.
    // GLI AMICI OFFLINE, ordine ES voce 12. Il fondatore: "3 per
    // l'Iniziato, 10 per l'Adepto, nessun limite per l'Illuminato [...] 100
    // Eos per un posto in più", "ok , approvato". Un elenco sul telefono,
    // non un consumo del modello.
    FeatureRow('Oroscopo per gli amici', ['No', '3', '10', 'Senza limite'],
        chiave: RigaDelPiano.amici),
    // **IL MOTORE SOCIALE DEL CERCHIO, ordine EY, 4 ottobre 2026**: la
    // tabella del punto 8 approvata dal fondatore. I posti del legame fra
    // account sono cosa diversa dagli amici offline qui sopra. **NESSUN
    // SENZA LIMITE, nemmeno all'Illuminato**: l'illimitato e' stato eliminato
    // ovunque per decisione del fondatore del 29 agosto 2026, e qui l'abuso
    // sarebbe raccogliere migliaia di persone.
    FeatureRow('Amici nel Cerchio', ['3', '15', '50', '150'],
        chiave: RigaDelPiano.legami),
    FeatureRow('Segni agli amici',
        ['5 al giorno', '20 al giorno', '40 al giorno', '60 al giorno'],
        chiave: RigaDelPiano.segniDelCerchio),
    FeatureRow('Confronti del cielo con gli amici',
        ['1 al giorno', '5 al giorno', '15 al giorno', '30 al giorno'],
        chiave: RigaDelPiano.cieli),
    FeatureRow('Scintilla e Sigillo da donare', ['No', 'No', 'Sì', 'Sì'],
        chiave: RigaDelPiano.doni),
    // **LA MATRICE DELL'ORDINE EX, voce EX.02, 2 ottobre 2026**: la tabella
    // dell'Architetto approvata dal fondatore, "Si ok, approvo.", e "mettiamo
    // limite delle carte estratte e la stesa a 10 solo dal tier 2 19,99".
    FeatureRow('Confronti nel Cerchio',
        ['No', '1 al giorno', '2 al giorno', '3 al giorno'],
        chiave: RigaDelPiano.confronti),
    // TRE per il Viandante, che e' il numero deciso e approvato dal fondatore.
    // Diceva UNO, e l'app non mentiva: leggeva questo dato e lo ripeteva
    // fedelmente. A mentire era il dato. Era finito qui il 31 luglio, quando
    // una divergenza fra matrice e codice e' stata risolta facendo vincere la
    // matrice: la correzione era giusta nel metodo, sbagliata nel valore.
    FeatureRow(
        'Domande a un Maestro',
        // Ordine EX Aggiunta 3: erano 3, 6, 10, 13.
        ['3 al giorno', '12 al giorno', '18 al giorno', '22 al giorno'],
        chiave: RigaDelPiano.domande),
    FeatureRow(
        'Vai più a fondo', ['No', '2 al giorno', '2 al giorno', '3 al giorno'],
        chiave: RigaDelPiano.approfondimenti),
    FeatureRow('Sintesi comparativa dei Maestri', ['No', 'Sì', 'Sì', 'Sì']),
    FeatureRow('Voce AI dei Maestri', ['No', 'No', 'Esclusiva', 'Sì']),
    // **LA MATRICE DELL'ORDINE EX, voce EX.02, 2 ottobre 2026**: la tabella
    // dell'Architetto approvata dal fondatore, "Si ok, approvo.", e "mettiamo
    // limite delle carte estratte e la stesa a 10 solo dal tier 2 19,99".
    // I minuti dall'ordine EX Aggiunta 6, 3 ottobre 2026: 80 e 150 (erano 60
    // e 120), "Si fammi aggiunta ordine con aumento limiti di minuti".
    FeatureRow('Minuti di LIVE', ['No', 'No', '80 al mese', '150 al mese'],
        chiave: RigaDelPiano.minutiLive),
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
    // **LE CARTE, NON LE STESE, ordine EX voce 02**, e supera i numeri
    // dell'ordine BV: la persona spende le carte del giorno come vuole (per
    // l'Iniziato due stese da tre, oppure una da cinque e una da una).
    // Contano le carte di una stesa letta dal modello; i rituali
    // deterministici (l'Arcano dell'Alba, la carta di nascita) no. La
    // carta singola e la riga "Tarocchi carta singola" (1, 3, 30, 50, mai
    // applicata: `RitualAllowance` non aveva chiamanti) stanno qui dentro.
    // **LA MATRICE DELL'ORDINE EX, voce EX.02, 2 ottobre 2026**: la tabella
    // dell'Architetto approvata dal fondatore, "Si ok, approvo.", e "mettiamo
    // limite delle carte estratte e la stesa a 10 solo dal tier 2 19,99".
    FeatureRow('Carte estratte nelle stese',
        ['3 al giorno', '6 al giorno', '10 al giorno', '15 al giorno'],
        chiave: RigaDelPiano.stese),
    FeatureRow('Stesa da 10 carte', ['No', 'No', 'Sì', 'Sì'],
        chiave: RigaDelPiano.stesaDaDieci),
    FeatureRow('Rune, I-Ching, Pendolo',
        ['Eos', 'Eos scontati', 'Inclusi', 'Inclusi']),
    // UNA GETTATA AL GIORNO PER IL VIANDANTE, deciso da Mauro con l'ordine O
    // del 12 agosto 2026. Erano tre dall'ordine I: il numero e' sceso perche'
    // la gettata e' il gesto che porta indietro domani, e tre al giorno lo
    // consumavano in un pomeriggio. Dal Tier 1 in su restano illimitate.
    // **LA MATRICE DELL'ORDINE EX, voce EX.02, 2 ottobre 2026**: la tabella
    // dell'Architetto approvata dal fondatore, "Si ok, approvo.", e "mettiamo
    // limite delle carte estratte e la stesa a 10 solo dal tier 2 19,99".
    FeatureRow('Gettate di rune',
        ['1 al giorno', '2 al giorno', '3 al giorno', '3 al giorno'],
        chiave: RigaDelPiano.gettate),
    // **IL VIAGGIO DELLO SCIAMANO, ordine DI voce 15, 12 settembre 2026.** I
    // valori sono dell'ordine, parola per parola. **Prima del riconoscimento
    // la discesa resta una al giorno per tutti**, anche per l'Illuminato: e'
    // il metodo, quattro discese in quattro giorni, e lo tiene
    // `TettiDelViaggio`. Queste celle valgono dopo.
    FeatureRow('Discese nel Mondo di Sotto',
        ['1 al giorno', '1 al giorno', '1 al giorno', '2 al giorno'],
        chiave: RigaDelPiano.discese),
    FeatureRow('Segni chiesti all\'animale guida',
        ['1 a settimana', '3 a settimana', '1 al giorno', '5 al giorno'],
        chiave: RigaDelPiano.segni),
    // **SEMPRE, E NON "ILLIMITATO".** L'ordine dice *"nutrimento: illimitato
    // in tutti i piani"*, e la ragione e' che il nutrimento non chiama nessun
    // modello e non costa niente. La parola non si scrive: il fondatore l'ha
    // tolta dal listino con l'ordine CE voce 08, e una guardia enumera ogni
    // cella. *Sempre* dice la stessa cosa senza promettere l'illimitato dove
    // ci sarebbe un costo.
    FeatureRow(
        'Nutrire l\'animale guida', ['Sempre', 'Sempre', 'Sempre', 'Sempre'],
        chiave: RigaDelPiano.nutrimento),
    // **I SIGILLI DELL'INTENZIONE: IL LIMITE E' LO SPAZIO E NON IL TEMPO.**
    // Ordine DO voce 11, deciso dal fondatore: *"quanti sigilli vivi insieme,
    // non quanti al mese"*. Prima di quest'ordine la funzione era aperta senza
    // tetti anche al Viandante. Per tracciarne uno nuovo a spazio pieno si
    // chiude uno di quelli vivi, nel Libro dei Sigilli.
    FeatureRow('Sigilli dell\'Intenzione vivi insieme', ['1', '2', '3', '5'],
        chiave: RigaDelPiano.sigilliVivi),
    // **LA CARICA E' SEMPRE APERTA**, perche' non chiama nessun modello e non
    // costa niente: la stessa ragione del nutrimento dell'animale.
    FeatureRow(
        'Caricare i propri sigilli', ['Sempre', 'Sempre', 'Sempre', 'Sempre'],
        chiave: RigaDelPiano.caricaDelSigillo),
    FeatureRow('Sinastria VIP',
        ['3 al giorno', '5 al giorno', '5 al giorno', '25 al giorno'],
        chiave: RigaDelPiano.sinastria),
    FeatureRow('Correlazione mood-transiti', ['No', 'Sì', 'Sì', 'Sì']),
    // **LA RIGA E' RISCRITTA, ordine CG voce 11, e supera quella di prima.**
    //
    // Diceva `['Base', 'Completo', 'Completo + AI', 'Completo + AI + report']`,
    // cioe' la lettura AI dal Tier 2. Decisione del fondatore del 31 agosto
    // 2026, parole sue: "per la 6 la lettura e' a partire dall'abbonamento a
    // 9,90". L'abbonamento a 9,90 al mese e' l'Iniziato, cioe' il TIER 1.
    //
    // **Il Tier 1 e il Tier 2 dicono la stessa cosa su questa riga, ed e'
    // onesto**: la lettura del mese scende al Tier 1, quindi su questa riga
    // l'Adepto non aggiunge niente. Scrivere una differenza che non c'e'
    // sarebbe una promessa falsa; le ragioni per salire all'Adepto stanno
    // nelle altre righe della matrice.
    //
    // **Testo provvisorio**: il fondatore lo corregge con una riga.
    FeatureRow('Cosmic Journal', [
      'Cammino e Ricordi',
      'Con la lettura del mese',
      'Con la lettura del mese',
      'Con la lettura del mese e il report',
    ]),
    // **LA RIGA DELLE NOTIFICHE PUSH. Ordine CG voce 16 punto 6.**
    //
    // Premium dal primo piano a pagamento in su, con UN MESE di prova per chi
    // non paga, una sola volta nella vita del Cerchio. Chi finisce la prova
    // torna alle notifiche locali, che restano accese e gratuite per tutti:
    // per questo la prima cella non dice "No".
    //
    // **Testo provvisorio**: il fondatore lo corregge con una riga.
    FeatureRow('Notifiche del Cerchio', [
      'Un mese di prova, poi gli avvisi del telefono',
      'Sempre, anche a Cerchio chiuso',
      'Sempre, anche a Cerchio chiuso',
      'Sempre, anche a Cerchio chiuso',
    ]),
    FeatureRow('Compatibilità a tre livelli', ['No', 'No', 'No', 'Esclusiva']),
    FeatureRow('Albero della Vita dinamico', [
      'Contemplativo',
      'Contemplativo',
      'Contemplativo',
      'Dinamico esclusivo'
    ]),
    // LA DOTE DI BENVENUTO DEL PIANO, ordine AN voce 07: si mostra come
    // valore del piano, e la riga dice che arriva alla sottoscrizione.
    FeatureRow(
        'Eos in dono alla sottoscrizione', ['No', '500', '1.500', '3.000']),
    // **Qui c'era la riga della Domanda al Maestro reale**: uscita con
    // l'ordine DJ voce 09, vedi i vantaggi dell'Illuminato.
    FeatureRow('Accesso anticipato nuove funzioni', ['No', 'No', 'No', 'Sì']),
    FeatureRow('Eos bonus mensili', ['No', 'Medio', 'Alto', 'Massimo'],
        chiave: RigaDelPiano.eosMensili),
  ];

  static Plan forTier(Tier tier) =>
      plans.firstWhere((p) => p.tier == tier, orElse: () => plans.first);
}
