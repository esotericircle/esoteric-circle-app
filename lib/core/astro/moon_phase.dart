import 'celestial.dart';

/// Fase lunare reale, calcolata sull'elongazione vera fra Luna e Sole.
///
/// **Un motore solo.** Questa classe conteneva un secondo motore lunare: partiva
/// dalla luna nuova del 6 gennaio 2000 e dal mese sinodico MEDIO, cioe' da una
/// durata costante di 29,53 giorni. L'orbita pero' non e' un cerchio percorso a
/// velocita' costante, quindi il mese medio sbaglia l'istante della sizigia fino
/// a mezza giornata. Nel frattempo `Celestial.moonIllumination` calcolava la
/// stessa cosa sull'elongazione vera, e i due non concordavano.
///
/// Adesso il calcolo viene da `Celestial` e da nessun altro posto: questa classe
/// resta come forma comoda, con la posizione nel ciclo e il nome italiano, ma non
/// calcola piu' niente per conto proprio. E' la sostituzione che la vecchia
/// docstring prometteva.
///
/// **Il difetto che si vedeva era nel nome.** La soglia delle fasi principali
/// valeva 0,035 di ciclo, cioe' circa un giorno intero da ogni lato: il nome
/// "Luna piena" restava a schermo per **quarantanove ore**, quindi lo si leggeva
/// anche tutto il giorno dopo la sizigia. Chi controllava con un'effemeride
/// vedeva che la Luna piena era stata il giorno prima.
class MoonPhase {
  const MoonPhase({
    required this.fraction,
    required this.illumination,
    required this.waxing,
    required this.italianName,
  });

  /// Posizione nel ciclo, da 0 (luna nuova) a 1: 0,5 e' la luna piena.
  ///
  /// Nasce dall'elongazione, cioe' `elongazione / 360`.
  final double fraction;

  /// Frazione illuminata del disco, da 0 (nuova) a 1 (piena).
  final double illumination;

  /// Vero in fase crescente, falso in fase calante.
  final bool waxing;

  final String italianName;

  /// Il giorno giuliano, delegato al motore unico.
  ///
  /// Resta esposto qui perche' diversi chiamanti lo usavano da questa classe, ma
  /// il calcolo e' quello di `Celestial`: due formule per il giorno giuliano
  /// sarebbero due motori, di nuovo.
  static double julianDay(DateTime date) => Celestial.julianDay(date);

  /// Quanto dura, da ogni lato della sizigia, il nome di una fase principale.
  ///
  /// Dodici ore: cosi' "Luna piena" copre il giorno della sizigia e non quello
  /// dopo. Prima la finestra valeva circa ventiquattro ore per lato, cioe'
  /// quarantanove ore in tutto, ed e' il motivo per cui l'app dichiarava la Luna
  /// piena anche il giorno seguente.
  static const Duration finestraFasePrincipale = Duration(hours: 12);

  /// La durata media del ciclo, usata SOLO per convertire la finestra in
  /// frazione di ciclo.
  ///
  /// Non entra nel calcolo della fase, che viene dall'elongazione vera: qui
  /// serve a dire quanto vale mezza giornata in frazione di ciclo, e per quello
  /// un valore medio e' esatto quanto serve.
  static const double _cicloMedioOre = 29.53 * 24;

  /// La soglia in frazione di ciclo che corrisponde a [finestraFasePrincipale].
  static double get soglia =>
      finestraFasePrincipale.inMinutes / 60.0 / _cicloMedioOre;

  /// Calcola la fase per una data.
  factory MoonPhase.forDate(DateTime date) {
    final luce = Celestial.moonIllumination(Celestial.julianDay(date));
    final fraction = luce.elongationDeg / 360.0;
    return MoonPhase(
      fraction: fraction,
      illumination: luce.fraction,
      waxing: luce.waxing,
      italianName: nomeItaliano(fraction),
    );
  }

  /// Il nome italiano della fase, da una posizione nel ciclo.
  ///
  /// Pubblico e unico: la nomenclatura viveva in due posti con soglie diverse,
  /// quindi la stessa Luna poteva prendere due nomi a seconda di chi la
  /// chiedeva.
  /// COME SI DICE LA FASE DOPO "La Luna e'", che non e' il suo nome.
  ///
  /// **Il difetto che questa funzione chiude.** I riti del giorno compongono
  /// tredici frasi della forma `La Luna e' {fase}.`, e al posto del segnaposto
  /// arrivava il NOME della fase. Ne uscivano due rotture diverse, tutte e due
  /// viste a video: `La Luna e' Luna calante`, che ripete la parola Luna, e
  /// `La Luna e' Ultimo quarto`, che a un quarto non mette la preposizione.
  ///
  /// Il nome serve dove la fase si annuncia da sola, per esempio in una
  /// tessera del Passaporto, e li' resta giusto. Qui serve un PREDICATO, cioe'
  /// la forma che sta bene dopo il verbo, e sono due cose diverse: tenerle
  /// separate e' l'unico modo perche' nessuna delle due debba essere un
  /// compromesso.
  static String comeSiDice(String nome) => switch (nome) {
        'Luna nuova' => 'nuova',
        'Luna piena' => 'piena',
        'Luna crescente' => 'crescente',
        'Luna calante' => 'calante',
        'Gibbosa crescente' => 'gibbosa crescente',
        'Gibbosa calante' => 'gibbosa calante',
        'Primo quarto' => 'al primo quarto',
        'Ultimo quarto' => "all'ultimo quarto",
        // Un nome che non conosco NON si travestre da predicato: si lascia
        // com'e'. Meglio una frase un po' rigida di una frase inventata.
        _ => nome,
      };

  static String nomeItaliano(double f) {
    final e = soglia;
    if (f < e || f > 1 - e) return 'Luna nuova';
    if ((f - 0.25).abs() < e) return 'Primo quarto';
    if ((f - 0.5).abs() < e) return 'Luna piena';
    if ((f - 0.75).abs() < e) return 'Ultimo quarto';
    if (f < 0.25) return 'Luna crescente';
    if (f < 0.5) return 'Gibbosa crescente';
    if (f < 0.75) return 'Gibbosa calante';
    return 'Luna calante';
  }
}
