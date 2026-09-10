/// **L'ONBOARDING ANNUNCIA L'ANIMALE, E NON LO CONSUMA.**
/// Ordine DC voce 02, 10 settembre 2026.
///
/// **LA REGOLA GENERALE, e vale da adesso su tutto**: *"l'onboarding rivela
/// cio' che nessuna funzione rivelera' mai; cio' che una funzione rivelera',
/// l'onboarding lo annuncia e non lo consuma"*.
///
/// **Da cui due conseguenze opposte.**
///
/// **L'Animale esce dalla rivelazione dell'onboarding.** Prima si apriva l'app
/// e il proprio animale era gia' li', nominato, prima ancora di avere una
/// ragione per volerlo sapere. **Il Viaggio dello Sciamano rivelera' quel
/// nome**, quindi l'onboarding non puo' bruciarlo: al suo posto una riga di
/// Caligo che dice che un animale aspetta nel Mondo di Sotto.
///
/// **La Carta di Nascita entra nella rivelazione**, perche' nessuna funzione
/// la scoprira' mai, e la sua rivelazione e' quella della voce DC.14.
///
/// **E NEL PASSAPORTO LA CASELLA RESTA VUOTA, con la sagoma in ombra.**
/// *"Una casella vuota nel proprio passaporto e' un motivo per tornare piu'
/// forte di una piena."*
abstract final class LAnnuncioDellAnimale {
  /// **LA RIGA DI CALIGO, al posto del nome.**
  ///
  /// Dice tre cose e nessuna di piu': che un animale c'e', che sta nel Mondo
  /// di Sotto, e che bisognera' scendere a incontrarlo. **Non promette quale
  /// sia e non promette quando**, perche' l'una e' la rivelazione del Viaggio
  /// e l'altra dipende da quante volte si scende.
  static const String laRiga =
      'Un animale ti aspetta nel Mondo di Sotto. Non te lo dico io: dovrai '
      'scendere a incontrarlo, e si mostrerà quando avrà deciso.';

  /// **COSA NON PUO' CONTENERE QUESTA RIGA**, e una guardia lo pretende.
  ///
  /// **Nessun nome di animale**: basta uno e l'annuncio diventa la
  /// rivelazione che doveva evitare.
  ///
  /// **Nessuna promessa di tempo**: *"domani"*, *"presto"*, *"fra poco"*.
  /// L'attesa dipende dai quattro viaggi in quattro giorni, e una promessa di
  /// tempo qui sarebbe una promessa che il metodo non puo' mantenere.
  static const List<String> parolePromesse = [
    'domani',
    'presto',
    'fra poco',
    'subito',
    'in pochi giorni',
  ];

  /// **LA CASELLA VUOTA DEL PASSAPORTO**, e cosa ci si legge sotto.
  ///
  /// Cambia con quante discese si sono fatte: **chi guarda vede che manca
  /// poco**, che e' la ragione per cui la casella vuota vale piu' di una
  /// piena.
  static String sottoLaSagoma(int discese, int quanteNeServono) {
    if (discese <= 0) return 'Non l\'hai ancora incontrato.';
    final restano = quanteNeServono - discese;
    if (restano <= 0) return '';
    if (restano == 1) return 'Si è mostrato tre volte. Ne manca una.';
    // **Il singolare esiste**, e una guardia che stampa la riga invece di
    // limitarsi a contarla lo fa vedere: la prima stesura diceva "1 volte".
    if (discese == 1) return 'Si è mostrato una volta su $quanteNeServono.';
    return 'Si è mostrato $discese volte su $quanteNeServono.';
  }
}
