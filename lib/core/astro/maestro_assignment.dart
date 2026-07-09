import '../maestro/maestro.dart';
import 'zodiac.dart';

/// Assegnazione provvisoria del Maestro a partire dal segno solare.
///
/// E' una logica semplice e temporanea, come richiesto per questo checkpoint:
/// mappa l'elemento del segno su un Maestro. L'assegnazione definitiva del
/// Briefing (carta natale piu' archetipo emerso) arrivera' con il modulo
/// spirituale nei checkpoint successivi.
///
/// Mappa attuale:
/// - Fuoco (Ariete, Leone, Sagittario) -> Caligo, il custode del rito e del fuoco;
/// - Acqua (Cancro, Scorpione, Pesci) e Terra (Toro, Vergine, Capricorno) -> Aura,
///   energia, corpo ed equilibrio;
/// - Aria (Gemelli, Bilancia, Acquario) -> Medora, mente, stelle e destino.
Maestro assignMaestro(Zodiac sunSign) {
  switch (sunSign.element) {
    case ZodiacElement.fire:
      return Maestro.caligo;
    case ZodiacElement.air:
      return Maestro.medora;
    case ZodiacElement.water:
    case ZodiacElement.earth:
      return Maestro.aura;
  }
}
