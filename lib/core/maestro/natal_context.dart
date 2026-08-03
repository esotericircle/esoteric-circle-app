import '../astro/celestial.dart';
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
    this.moonIllumination,
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
      moonIllumination: facts?.moonPhase,
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

  /// LA FASE LUNARE DI NASCITA, come dato e non come parola.
  ///
  /// Qui c'era il solo NOME, una stringa. Il nome poteva quindi esistere senza
  /// il dato da cui nasce, ed e' esattamente cio' che e' successo: la scena del
  /// consulto mostrava un disco a mezza luce scritto a mano, con accanto la
  /// parola "crescente" che veniva da un'altra strada. Due fonti per la stessa
  /// Luna, e una diceva il falso.
  ///
  /// Adesso il campo e' la frazione illuminata vera, e il nome si RICAVA. Non
  /// esiste piu' modo di dichiarare una fase senza portarne la misura.
  final MoonIllumination? moonIllumination;

  /// Il nome italiano della fase, DERIVATO dalla misura qui sopra.
  ///
  /// Non e' un campo: se lo fosse, qualcuno potrebbe scrivere "Luna crescente"
  /// accanto a una Luna piena, e nessuna prova se ne accorgerebbe.
  String? get moonPhase {
    final luce = moonIllumination;
    return luce == null ? null : phaseNameOf(luce);
  }

  /// Vero quando non c'e' alcun dato da passare: il prompt non riceve nulla e la
  /// risposta resta sul solo tema, senza personalizzazione.
  bool get isEmpty =>
      (sunSign == null || sunSign!.trim().isEmpty) &&
      (moonSign == null || moonSign!.trim().isEmpty) &&
      (ascendant == null || ascendant!.trim().isEmpty) &&
      lifeNumber == null &&
      (lifeNumberTitle == null || lifeNumberTitle!.trim().isEmpty) &&
      moonIllumination == null;
}
