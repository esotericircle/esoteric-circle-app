import '../../design_system/components/zodiac_glyph.dart';
import '../archetypes/archetype.dart';
import '../astro/zodiac.dart';
import '../identity/birth_identity.dart';
import '../rituals/animal_catalog.dart';
import '../rituals/carta_di_nascita_dei_tarocchi.dart';
import '../sigilli/diario_del_cammino.dart';
import '../tarot/tarot_card.dart';

/// **L'ICONA DEL PROFILO, ordine EY voce 03.** Si sceglie fra i quattro set
/// che il progetto ha gia' disegnati: i dodici emblemi dei segni, i dodici
/// animali guida, i ventidue Arcani con l'Arcano personale, le dodici statue
/// degli archetipi. **Nessuna foto.**
///
/// La forma dell'icona e' `famiglia:indice`, la stessa del server
/// (`iconaValida` in `functions/src/sociale.ts`, con `QUANTE_ICONE`).
enum FamigliaDelleIcone {
  segno('I segni', 12),
  animale('Gli animali guida', 12),
  arcano('Gli Arcani', 22),
  archetipo('Gli archetipi', 12);

  const FamigliaDelleIcone(this.titolo, this.quante);
  final String titolo;
  final int quante;
}

class IconaDelProfilo {
  const IconaDelProfilo._(this.famiglia, this.indice);

  final FamigliaDelleIcone famiglia;
  final int indice;

  String get codice => '${famiglia.name}:$indice';

  static IconaDelProfilo da(String? codice) {
    final pezzi = (codice ?? '').split(':');
    for (final f in FamigliaDelleIcone.values) {
      if (pezzi.isNotEmpty && f.name == pezzi.first) {
        final i = pezzi.length > 1 ? int.tryParse(pezzi[1]) : null;
        if (i != null && i >= 0 && i < f.quante) return IconaDelProfilo._(f, i);
      }
    }
    return const IconaDelProfilo._(FamigliaDelleIcone.segno, 0);
  }

  static List<IconaDelProfilo> di(FamigliaDelleIcone f) =>
      [for (var i = 0; i < f.quante; i++) IconaDelProfilo._(f, i)];

  static List<TarotCard> get _maggiori => [
        for (var n = 0; n < 22; n++)
          TarotDeck.cards.firstWhere((c) => c.majorNumber == n),
      ];

  /// L'arte dell'icona, dai set gia' disegnati.
  String get asset => switch (famiglia) {
        FamigliaDelleIcone.segno => ZodiacArt.emblemPath(Zodiac.values[indice]),
        FamigliaDelleIcone.animale => AnimalCatalog.animals[indice].thumbPath,
        FamigliaDelleIcone.arcano => _maggiori[indice].thumbPath,
        FamigliaDelleIcone.archetipo => Archetype.values[indice].arteThumb,
      };

  /// Le carte dei Tarocchi sono alte: l'icona tonda ne prende il cuore.
  bool get eUnaCarta => famiglia == FamigliaDelleIcone.arcano;

  String get nome => switch (famiglia) {
        FamigliaDelleIcone.segno => Zodiac.values[indice].italianName,
        FamigliaDelleIcone.animale => AnimalCatalog.animals[indice].name,
        FamigliaDelleIcone.arcano => _maggiori[indice].name,
        FamigliaDelleIcone.archetipo => Archetype.values[indice].nome,
      };

  /// **LA VETRINA, NON IL LUCCHETTO.** Le icone che la persona non ha ancora
  /// incontrato nel Cammino si vedono spente, con la riga che dice da dove
  /// si aprono. I segni sono tutti aperti: sono il cielo di tutti.
  bool incontrata({
    required DiarioDelCammino? diario,
    required BirthIdentity? identita,
    required Set<int> archetipiIncontrati,
  }) {
    switch (famiglia) {
      case FamigliaDelleIcone.segno:
        return true;
      case FamigliaDelleIcone.animale:
        final nome = AnimalCatalog.animals[indice].name;
        return (diario?.quanteVolteIlValore('animale_guida', 'animale', nome) ??
                0) >
            0;
      case FamigliaDelleIcone.arcano:
        if (identita != null &&
            !identita.isExample &&
            CartaDiNascitaDeiTarocchi.cartaDi(identita.birthDate).majorNumber ==
                indice) {
          // L'Arcano personale e' aperto dal primo giorno.
          return true;
        }
        final stem = _maggiori[indice].stem;
        return (diario?.quanteVolteIlValore('oracolo', 'arcano', stem) ?? 0) >
                0 ||
            (diario?.quanteVolteIlValore('stesa', 'maggiori', stem) ?? 0) > 0;
      case FamigliaDelleIcone.archetipo:
        return archetipiIncontrati.contains(indice);
    }
  }

  /// Da dove si apre un'icona spenta.
  String get daDoveSiApre => switch (famiglia) {
        FamigliaDelleIcone.segno => '',
        FamigliaDelleIcone.animale =>
          'Si apre quando incontri questo animale nel Viaggio dello Sciamano.',
        FamigliaDelleIcone.arcano =>
          'Si apre quando questo Arcano esce all’Alba o in una stesa.',
        FamigliaDelleIcone.archetipo =>
          'Si apre quando questo archetipo guida il tuo Test degli archetipi.',
      };
}
