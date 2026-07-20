/// Dati natali dell'utente gia' pronti per il prompt di una consultazione.
///
/// Modello snello e opzionale: porta solo i fatti deterministici che il motore
/// dell'app ha gia' calcolato (posizioni dalle effemeridi, numero della vita),
/// mai un dato inventato. Serve a personalizzare la risposta di un Maestro senza
/// che il confine AI debba conoscere astrologia o numerologia: riceve fatti,
/// non li ricava. In questa fetta resta null e viaggia inerte; quando arrivera'
/// la personalizzazione natale bastera' passarlo pieno, senza cambiare firma.
class NatalContext {
  const NatalContext({
    this.sunSign,
    this.moonSign,
    this.ascendant,
    this.lifeNumber,
    this.lifeNumberTitle,
    this.moonPhase,
  });

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

  /// Fase lunare del giorno, per esempio "Luna crescente".
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
