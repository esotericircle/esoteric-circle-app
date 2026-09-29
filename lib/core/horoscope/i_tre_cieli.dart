import 'astro_tradition.dart';
import 'horoscope.dart';

/// Come una tradizione vede un dominio oggi, dal livello della sua scheda.
enum EsitoDelCielo {
  favorevole('favorevole'),
  inEquilibrio('in equilibrio'),
  inSalita('in salita');

  const EsitoDelCielo(this.parola);

  /// La parola che si legge. **Invariabile apposta**: si accorda con "la
  /// giornata", "l'amore", "il lavoro" e "la fortuna" senza cambiare.
  final String parola;

  /// Il livello delle schede va da 2 a 5: 4 e 5 favorevole, 3 in equilibrio,
  /// 2 in salita.
  static EsitoDelCielo di(int livello) => livello >= 4
      ? favorevole
      : livello == 3
          ? inEquilibrio
          : inSalita;
}

/// Il parere delle tre tradizioni su un dominio.
class AccordoDelDominio {
  const AccordoDelDominio({required this.dominio, required this.esiti});

  final HoroscopeDomain dominio;

  /// L'esito di ogni tradizione, nell'ordine di [ITreCieli.tradizioni].
  final Map<AstroTradition, EsitoDelCielo> esiti;

  bool get concordi => esiti.values.toSet().length == 1;

  /// La frase che si legge: l'accordo, o chi vede cosa.
  String get frase {
    final (nome, preposizione) = ITreCieli.parole[dominio]!;
    if (concordi) {
      return 'Oggi tre tradizioni su tre vedono $nome '
          '${esiti.values.first.parola}.';
    }
    // Chi vede cosa, nell'ordine degli esiti: prima il favorevole.
    final gruppi = <String>[];
    for (final e in EsitoDelCielo.values) {
      final chi = [
        for (final t in ITreCieli.tradizioni)
          if (esiti[t] == e) ITreCieli.conArticolo[t]!,
      ];
      if (chi.isEmpty) continue;
      gruppi.add('${e.parola} per ${chi.join(' e ')}');
    }
    return '${preposizione[0].toUpperCase()}${preposizione.substring(1)} '
        'le tre tradizioni non sono d\'accordo: ${gruppi.join(', ')}.';
  }
}

/// **TRE TRADIZIONI SU TRE, ordine ES voce 36.**
///
/// La riga dell'Architetto, approvata dal fondatore con l'ordine: *"Quando
/// occidentale, cinese e vedica danno lo stesso esito su un dominio, lo si
/// dice: "Oggi tre tradizioni su tre vedono il lavoro favorevole". Se non
/// sono d'accordo, si dice anche questo."*
///
/// **L'esito viene dal livello che ogni scheda porta gia'**, lo stesso che la
/// persona vede nelle barre del dominio: qui non si decide niente di nuovo,
/// si mettono accanto tre decisioni gia' prese, ognuna con la sua regola
/// (i transiti per l'Occidentale, l'almanacco per la Cinese, la Chandra Bala
/// per la Vedica).
abstract final class ITreCieli {
  static const List<AstroTradition> tradizioni = [
    AstroTradition.occidentale,
    AstroTradition.cinese,
    AstroTradition.vedica,
  ];

  /// Il dominio come si nomina, e con la preposizione.
  static const Map<HoroscopeDomain, (String, String)> parole = {
    HoroscopeDomain.generale: ('la giornata', 'sulla giornata'),
    HoroscopeDomain.amore: ('l\'amore', 'sull\'amore'),
    HoroscopeDomain.carriera: ('il lavoro', 'sul lavoro'),
    HoroscopeDomain.fortuna: ('la fortuna', 'sulla fortuna'),
  };

  static const Map<AstroTradition, String> conArticolo = {
    AstroTradition.occidentale: 'l\'occidentale',
    AstroTradition.cinese: 'la cinese',
    AstroTradition.vedica: 'la vedica',
  };

  /// L'accordo dominio per dominio, nell'ordine dei domini. Vuoto se una
  /// delle tre letture manca: "tre su tre" si dice solo con tre letture.
  static List<AccordoDelDominio> di({
    required List<HoroscopeCard>? occidentale,
    required List<HoroscopeCard>? cinese,
    required List<HoroscopeCard>? vedica,
  }) {
    if (occidentale == null || cinese == null || vedica == null) {
      return const [];
    }
    int? livello(List<HoroscopeCard> schede, HoroscopeDomain d) {
      for (final s in schede) {
        if (s.domain == d) return s.indicator;
      }
      return null;
    }

    final accordi = <AccordoDelDominio>[];
    for (final d in HoroscopeDomain.values) {
      final o = livello(occidentale, d);
      final c = livello(cinese, d);
      final v = livello(vedica, d);
      if (o == null || c == null || v == null) return const [];
      accordi.add(AccordoDelDominio(dominio: d, esiti: {
        AstroTradition.occidentale: EsitoDelCielo.di(o),
        AstroTradition.cinese: EsitoDelCielo.di(c),
        AstroTradition.vedica: EsitoDelCielo.di(v),
      }));
    }
    return accordi;
  }
}
