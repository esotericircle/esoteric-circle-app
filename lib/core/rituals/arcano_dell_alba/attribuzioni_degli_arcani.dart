import '../../astro/zodiac.dart';

/// La famiglia di un arcano maggiore, dalla lettera ebraica che la Golden Dawn
/// gli attribuisce sulla divisione del Sefer Yetzirah.
enum FamigliaDellArcano {
  /// Le tre lettere madri: un elemento. Il responso e' un respiro.
  elementale('elementale', 'lettera madre'),

  /// Le sette lettere doppie: un pianeta. Il responso e' un'azione.
  planetaria('planetaria', 'lettera doppia'),

  /// Le dodici lettere semplici: un segno. Il responso e' una parola.
  zodiacale('zodiacale', 'lettera semplice');

  const FamigliaDellArcano(this.nome, this.lettera);

  final String nome;
  final String lettera;
}

/// I sette pianeti della tradizione.
enum PianetaDellArcano {
  mercurio('Mercurio'),
  luna('Luna'),
  venere('Venere'),
  giove('Giove'),
  marte('Marte'),
  sole('Sole'),
  saturno('Saturno');

  const PianetaDellArcano(this.nome);

  final String nome;

  /// **I SEGNI CHE IL PIANETA GOVERNA**, per domicilio, secondo la tradizione
  /// tolemaica che la Golden Dawn eredita: e' la relazione che la voce DT.10
  /// chiama *"il pianeta di oggi governa il segno di ieri"*.
  Set<Zodiac> get governa => switch (this) {
        mercurio => {Zodiac.gemini, Zodiac.virgo},
        luna => {Zodiac.cancer},
        venere => {Zodiac.taurus, Zodiac.libra},
        giove => {Zodiac.sagittarius, Zodiac.pisces},
        marte => {Zodiac.aries, Zodiac.scorpio},
        sole => {Zodiac.leo},
        saturno => {Zodiac.capricorn, Zodiac.aquarius},
      };
}

/// **L'ATTRIBUZIONE DI UN ARCANO MAGGIORE.** Ordine DT voce 06, 17 settembre
/// 2026.
///
/// Fissa e permanente, non dipende dal giorno in cui la carta esce: e'
/// l'anatomia del mazzo, non un transito. **Il sistema e' quello della Golden
/// Dawn**, ripreso dal mazzo Waite Smith: tre lettere madri agli elementi,
/// sette doppie ai pianeti, dodici semplici ai segni.
///
/// **La carta si riconosce dal NOME del corpus**, non dal numero: il corpus
/// numera La Giustizia VIII e La Forza XI, e l'attribuzione segue la carta.
class AttribuzioneDellArcano {
  const AttribuzioneDellArcano._elemento(this.nomeDellaCarta, this.elemento)
      : famiglia = FamigliaDellArcano.elementale,
        pianeta = null,
        segno = null;

  const AttribuzioneDellArcano._pianeta(this.nomeDellaCarta, this.pianeta)
      : famiglia = FamigliaDellArcano.planetaria,
        elemento = null,
        segno = null;

  const AttribuzioneDellArcano._segno(this.nomeDellaCarta, this.segno)
      : famiglia = FamigliaDellArcano.zodiacale,
        elemento = null,
        pianeta = null;

  /// Il nome della carta come lo scrive il corpus dei tarocchi.
  final String nomeDellaCarta;
  final FamigliaDellArcano famiglia;
  final ZodiacElement? elemento;
  final PianetaDellArcano? pianeta;
  final Zodiac? segno;

  /// L'elemento a cui la carta appartiene, quando ne ha uno: il suo, se e' una
  /// lettera madre; quello del suo segno, se e' una semplice. I pianeti non
  /// hanno un elemento proprio.
  ZodiacElement? get elementoDiAppartenenza => elemento ?? segno?.element;

  /// Il nome dell'attribuzione, come si dice: *"Aria"*, *"Mercurio"*,
  /// *"Ariete"*.
  String get nome =>
      segno?.italianName ?? pianeta?.nome ?? nomeDellElemento(elemento!);

  static String nomeDellElemento(ZodiacElement e) => switch (e) {
        ZodiacElement.air => 'Aria',
        ZodiacElement.water => 'Acqua',
        ZodiacElement.fire => 'Fuoco',
        ZodiacElement.earth => 'Terra',
      };

  /// **LE VENTIDUE**, nell'ordine del corpus. Tre piu' sette piu' dodici.
  static const List<AttribuzioneDellArcano> tutte = [
    AttribuzioneDellArcano._elemento('Il Matto', ZodiacElement.air),
    AttribuzioneDellArcano._pianeta('Il Mago', PianetaDellArcano.mercurio),
    AttribuzioneDellArcano._pianeta('La Papessa', PianetaDellArcano.luna),
    AttribuzioneDellArcano._pianeta('L\'Imperatrice', PianetaDellArcano.venere),
    AttribuzioneDellArcano._segno('L\'Imperatore', Zodiac.aries),
    AttribuzioneDellArcano._segno('Il Papa', Zodiac.taurus),
    AttribuzioneDellArcano._segno('Gli Amanti', Zodiac.gemini),
    AttribuzioneDellArcano._segno('Il Carro', Zodiac.cancer),
    AttribuzioneDellArcano._segno('La Giustizia', Zodiac.libra),
    AttribuzioneDellArcano._segno('L\'Eremita', Zodiac.virgo),
    AttribuzioneDellArcano._pianeta(
        'La Ruota della Fortuna', PianetaDellArcano.giove),
    AttribuzioneDellArcano._segno('La Forza', Zodiac.leo),
    AttribuzioneDellArcano._elemento('L\'Appeso', ZodiacElement.water),
    AttribuzioneDellArcano._segno('La Morte', Zodiac.scorpio),
    AttribuzioneDellArcano._segno('La Temperanza', Zodiac.sagittarius),
    AttribuzioneDellArcano._segno('Il Diavolo', Zodiac.capricorn),
    AttribuzioneDellArcano._pianeta('La Torre', PianetaDellArcano.marte),
    AttribuzioneDellArcano._segno('La Stella', Zodiac.aquarius),
    AttribuzioneDellArcano._segno('La Luna', Zodiac.pisces),
    AttribuzioneDellArcano._pianeta('Il Sole', PianetaDellArcano.sole),
    AttribuzioneDellArcano._elemento('Il Giudizio', ZodiacElement.fire),
    AttribuzioneDellArcano._pianeta('Il Mondo', PianetaDellArcano.saturno),
  ];

  /// L'attribuzione della carta di nome [nome], o null se non e' un maggiore.
  static AttribuzioneDellArcano? di(String nome) {
    for (final a in tutte) {
      if (a.nomeDellaCarta == nome) return a;
    }
    return null;
  }
}

/// Una relazione documentata fra le attribuzioni di due carte.
enum RelazioneFraArcani {
  stessoElemento,
  governo,
  opposizione,
  quadratura,
  stessaFamiglia,
}

/// **LE RELAZIONI CHE AUTORIZZANO IL FILO CON IERI.** Ordine DT voce 10.
///
/// Solo queste: stesso elemento, un pianeta che governa il segno dell'altra,
/// due segni in opposizione o in quadratura, la stessa famiglia. Fuori da qui
/// il filo non si fa.
abstract final class RelazioniFraArcani {
  static List<RelazioneFraArcani> fra(
      AttribuzioneDellArcano oggi, AttribuzioneDellArcano ieri) {
    final esito = <RelazioneFraArcani>[];
    final eOggi = oggi.elementoDiAppartenenza;
    if (eOggi != null && eOggi == ieri.elementoDiAppartenenza) {
      esito.add(RelazioneFraArcani.stessoElemento);
    }
    final governa = (oggi.pianeta != null &&
            ieri.segno != null &&
            oggi.pianeta!.governa.contains(ieri.segno)) ||
        (ieri.pianeta != null &&
            oggi.segno != null &&
            ieri.pianeta!.governa.contains(oggi.segno));
    if (governa) esito.add(RelazioneFraArcani.governo);
    if (oggi.segno != null && ieri.segno != null) {
      final distanza = (oggi.segno!.index - ieri.segno!.index).abs() % 12;
      if (distanza == 6) esito.add(RelazioneFraArcani.opposizione);
      if (distanza == 3 || distanza == 9) {
        esito.add(RelazioneFraArcani.quadratura);
      }
    }
    if (oggi.famiglia == ieri.famiglia &&
        oggi.nomeDellaCarta != ieri.nomeDellaCarta) {
      esito.add(RelazioneFraArcani.stessaFamiglia);
    }
    return esito;
  }
}
