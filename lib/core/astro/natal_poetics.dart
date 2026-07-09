import '../identity/identity_controller.dart';
import '../maestro/maestro.dart';
import 'natal_chart.dart';
import 'zodiac.dart';

/// Forza di un pianeta nel suo segno (dignita' essenziale semplificata).
enum Dignity { strong, neutral, weak }

/// Testi e sintesi poetiche derivati dalla carta natale. Nessun LLM: sono
/// contenuti curati, deterministici, coerenti col principio del livello visivo
/// prima del testo (qui il testo che accompagna gli emblemi).
class NatalPoetics {
  NatalPoetics._();

  /// Significato breve di ciascun pianeta o punto.
  static const Map<String, String> meaning = {
    'sun': 'la tua essenza e la volonta\'',
    'moon': 'l\'emotivita\' e i bisogni',
    'mercury': 'la mente e la parola',
    'venus': 'l\'amore e il piacere',
    'mars': 'l\'azione e il desiderio',
    'jupiter': 'l\'espansione e la fortuna',
    'saturn': 'la disciplina e il limite',
    'uranus': 'il cambiamento e la liberta\'',
    'neptune': 'il sogno e la spiritualita\'',
    'pluto': 'la trasformazione profonda',
    'north_node': 'la direzione dell\'anima',
    'chiron': 'la ferita che guarisce',
    'lilith': 'l\'ombra e l\'istinto',
  };

  static String meaningOf(String planetId) =>
      meaning[planetId] ?? 'un filo del tuo cielo';

  // Domicilio ed esaltazione (forza), detrimento e caduta (debolezza).
  static const Map<String, Set<Zodiac>> _strong = {
    'sun': {Zodiac.leo, Zodiac.aries},
    'moon': {Zodiac.cancer, Zodiac.taurus},
    'mercury': {Zodiac.gemini, Zodiac.virgo},
    'venus': {Zodiac.taurus, Zodiac.libra, Zodiac.pisces},
    'mars': {Zodiac.aries, Zodiac.scorpio, Zodiac.capricorn},
    'jupiter': {Zodiac.sagittarius, Zodiac.pisces, Zodiac.cancer},
    'saturn': {Zodiac.capricorn, Zodiac.aquarius, Zodiac.libra},
  };
  static const Map<String, Set<Zodiac>> _weak = {
    'sun': {Zodiac.aquarius, Zodiac.libra},
    'moon': {Zodiac.capricorn, Zodiac.scorpio},
    'mercury': {Zodiac.sagittarius, Zodiac.pisces},
    'venus': {Zodiac.aries, Zodiac.scorpio, Zodiac.virgo},
    'mars': {Zodiac.taurus, Zodiac.libra, Zodiac.cancer},
    'jupiter': {Zodiac.gemini, Zodiac.virgo, Zodiac.capricorn},
    'saturn': {Zodiac.cancer, Zodiac.leo, Zodiac.aries},
  };

  static Dignity dignityOf(String planetId, Zodiac sign) {
    if (_strong[planetId]?.contains(sign) ?? false) return Dignity.strong;
    if (_weak[planetId]?.contains(sign) ?? false) return Dignity.weak;
    return Dignity.neutral;
  }

  /// Frase poetica di colpo d'occhio su Sole, Luna e Ascendente.
  static String glanceSummary(NatalChart chart) {
    final sun = chart.sunSign.italianName;
    final moon = chart.moonSign?.italianName;
    final asc = chart.ascendant?.italianName;
    if (moon != null && asc != null) {
      return 'Il tuo fuoco arde in $sun, la tua marea scorre in $moon, e ti affacci al mondo con lo sguardo di $asc.';
    }
    if (moon != null) {
      return 'Il tuo fuoco arde in $sun e la tua marea scorre in $moon.';
    }
    return 'Il tuo fuoco arde in $sun: da qui parte il tuo cammino.';
  }

  /// Primo momento personale offerto dal Maestro, basato sul cielo. Logica
  /// semplice per ora, personalizzata con nome e forma di cortesia.
  static String firstMoment({
    required NatalChart chart,
    required Maestro maestro,
    required IdentityController identity,
  }) {
    final sun = chart.sunSign.italianName;
    final greetingName = identity.hasName ? ', ${identity.name}' : '';
    switch (maestro) {
      case Maestro.medora:
        return 'Ti leggo negli astri$greetingName. Con il Sole in $sun, oggi le stelle ti invitano a fidarti del primo passo: una carta gia\' ti attende quando vorrai.';
      case Maestro.aura:
        return 'Respira con me$greetingName. Il tuo cielo, acceso in $sun, chiede equilibrio: posa una mano sul petto e lascia che il respiro trovi il suo ritmo.';
      case Maestro.caligo:
        return 'Ascolta il silenzio$greetingName. Con il Sole in $sun, una runa vibra gia\' per te: la lanceremo insieme quando la notte chiamera\'.';
    }
  }
}
