/// Le tradizioni astrologiche dell'Oroscopo Personalizzato.
///
/// Non sono funzioni a se': non hanno una card nel dominio ne' una schermata
/// propria, e vivono soltanto come scelta dentro l'Oroscopo. Cosi' il cielo di
/// un'altra tradizione si legge dove si legge il proprio, senza moltiplicare le
/// voci in Home.
///
/// Per la Demo e' aperta la sola Occidentale, che e' anche quella di partenza.
/// Le altre restano visibili, leggibili e col lucchetto: mai un vicolo cieco.
enum AstroTradition {
  occidentale(
    'Occidentale',
    unlocked: true,
    invito: 'Il cielo che leggo per te ogni giorno, tropicale e occidentale.',
  ),
  vedica(
    'Vedica',
    phase: 'Fase 3',
    invito:
        'L\'astrologia vedica ti attende, Adepto. Presto ti guiderò fra i suoi nakshatra.',
  ),
  cinese(
    'Cinese',
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
      {this.unlocked = false, this.phase, required this.invito});

  final String label;

  /// Se si puo' scegliere adesso. Solo l'Occidentale, per ora.
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
