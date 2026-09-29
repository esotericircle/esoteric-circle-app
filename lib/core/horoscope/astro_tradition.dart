import '../entitlement/tier.dart';

/// Le tradizioni astrologiche dell'Oroscopo Personalizzato.
///
/// Non sono funzioni a se': non hanno una card nel dominio ne' una schermata
/// propria, e vivono soltanto come scelta dentro l'Oroscopo. Cosi' il cielo di
/// un'altra tradizione si legge dove si legge il proprio, senza moltiplicare le
/// voci in Home.
///
/// L'Occidentale e' quella di partenza. **Dall'ordine ES voce 08 e' aperta
/// anche la Cinese**, dalla voce 09 la Vedica: le sceglie chiunque e ne
/// vede il segno, la lettura del giorno e' dei piani a pagamento (il fondatore: "I free potranno solo
/// chiedere oroscopo del giorno e solo occidentale o solo vedere il proprio
/// segno di vedica o cinese senza lettura"). Le altre restano visibili, col
/// loro segno e la clessidra: mai un vicolo cieco.
enum AstroTradition {
  occidentale(
    'Occidentale',
    unlocked: true,
    invito: 'Il cielo che leggo per te ogni giorno, tropicale e occidentale.',
  ),
  vedica(
    'Vedica',
    unlocked: true,
    livelloDellaLettura: 1,
    phase: 'Fase 3',
    invito:
        'L\'astrologia vedica ti attende, Adepto. Presto ti guiderò fra i suoi nakshatra.',
  ),
  cinese(
    'Cinese',
    unlocked: true,
    livelloDellaLettura: 1,
    phase: 'Fase 3',
    invito:
        'I quattro pilastri del Ba Zi custodiscono la tua ora di nascita. Verrò a leggerli con te.',
  ),
  maya(
    'Maya',
    phase: 'Fase 4',
    invito:
        'Il conto dei giorni dei Maya ha un segno che ti riguarda. Te lo mostrerò quando sarà tempo.',
  ),
  celtica(
    'Celtica',
    phase: 'Fase 4',
    invito:
        'I Celti leggevano il cielo negli alberi. Il tuo albero ti aspetta, Adepto.',
  ),
  egizia(
    'Egizia',
    phase: 'Fase 4',
    invito:
        'Il cielo del Nilo ha un decano che porta il tuo nome. Lo aprirò per te.',
  ),
  araba(
    'Araba',
    phase: 'Fase 4',
    invito:
        'Le mansioni lunari degli arabi contano ventotto passi. Li percorreremo insieme.',
  );

  const AstroTradition(this.label,
      {this.unlocked = false,
      this.livelloDellaLettura = 0,
      this.phase,
      required this.invito});

  /// **DA QUALE PIANO SI LEGGE**, ordine ES voce 06: l'Occidentale da tutti,
  /// la Cinese dal primo piano a pagamento. Sotto, si vede il segno e
  /// l'invito al piano.
  final int livelloDellaLettura;

  /// Se chi ha il piano [tier] legge questa tradizione, oltre a vederne il
  /// segno.
  bool leggibilePer(Tier tier) => unlocked && tier.level >= livelloDellaLettura;

  final String label;

  /// Se si puo' scegliere adesso e ha una lettura: l'Occidentale e, dalla
  /// voce ES.08, la Cinese.
  final bool unlocked;

  /// La fase in cui la tradizione e' pianificata. E' un dato di piano: si mostra
  /// soltanto nella vista Demo per gli investitori, mai alla persona.
  final String? phase;

  /// Il micro messaggio del Maestro del dominio, in prima persona, che risponde
  /// al tocco su una tradizione ancora chiusa.
  final String invito;

  /// Quella di partenza, sempre aperta.
  static const AstroTradition predefinita = AstroTradition.occidentale;
}
