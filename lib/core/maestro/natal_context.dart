import '../astro/natal_chart.dart';
import '../identity/natal_identity.dart';

/// Dati natali dell'utente gia' pronti per il prompt di una consultazione.
///
/// Modello snello e opzionale: porta solo i fatti deterministici che il motore
/// dell'app ha gia' calcolato (posizioni dalle effemeridi, numero della vita),
/// mai un dato inventato. Serve a personalizzare la risposta di un Maestro senza
/// che il confine AI debba conoscere astrologia o numerologia: riceve fatti,
/// non li ricava. Quando la carta manca resta [empty] e la risposta si
/// personalizza col solo nome.
class NatalContext {
  const NatalContext({
    this.sunSign,
    this.moonSign,
    this.ascendant,
    this.lifeNumber,
    this.lifeNumberTitle,
    this.moonPhase,
  });

  /// Costruisce il contesto dai fatti gia' calcolati: il segno solare, lunare e
  /// l'ascendente dalla carta (quando c'e' l'ora), il numero della vita col suo
  /// titolo e la fase lunare di nascita dai fatti identitari. Solo dati reali:
  /// dove il motore non ha calcolato nulla, il campo resta null.
  factory NatalContext.fromNatal({NatalChart? chart, NatalFacts? facts}) {
    return NatalContext(
      sunSign: chart?.sunSign.italianName,
      moonSign: chart?.moonSign?.italianName ?? facts?.moonSign?.italianName,
      ascendant: chart?.ascendant?.italianName,
      lifeNumber: facts?.lifeNumber,
      lifeNumberTitle: facts?.lifeTitle,
      moonPhase: facts?.moonPhaseName,
    );
  }

  /// Contesto vuoto, quando non ci sono dati di nascita: personalizzazione col
  /// solo nome.
  static const NatalContext none = NatalContext();

  /// Segno solare, per esempio "Bilancia".
  final String? sunSign;

  /// Segno lunare.
  final String? moonSign;

  /// Segno all'ascendente.
  final String? ascendant;

  /// Numero della vita della numerologia, da 1 a 9 (piu' i maestri 11, 22).
  final int? lifeNumber;

  /// Titolo del numero della vita, per esempio "il Costruttore".
  final String? lifeNumberTitle;

  /// Fase lunare di nascita, per esempio "Luna crescente".
  final String? moonPhase;

  /// Vero quando non c'e' alcun dato da passare: il prompt non riceve nulla e la
  /// risposta resta sul solo tema, senza personalizzazione.
  bool get isEmpty =>
      (sunSign == null || sunSign!.trim().isEmpty) &&
      (moonSign == null || moonSign!.trim().isEmpty) &&
      (ascendant == null || ascendant!.trim().isEmpty) &&
      lifeNumber == null &&
      (lifeNumberTitle == null || lifeNumberTitle!.trim().isEmpty) &&
      (moonPhase == null || moonPhase!.trim().isEmpty);
}
