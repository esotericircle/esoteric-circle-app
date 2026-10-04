import '../../design_system/components/zodiac_glyph.dart';
import '../archetypes/archetype.dart';
import '../astro/zodiac.dart';
import '../identity/birth_identity.dart';
import '../rituals/animal_catalog.dart';
import '../sigilli/diario_del_cammino.dart';

/// **L'ICONA DEL PROFILO, ordine EY voce 03.** Si sceglie fra i set che il
/// progetto ha gia' disegnati: i dodici emblemi dei segni, i dodici animali
/// guida, le dodici statue degli archetipi. Trentasei icone. **Nessuna foto.**
///
/// **GLI ARCANI SONO USCITI DALLE ICONE, ordine FA voce 01, 4 ottobre 2026.**
/// Il fondatore: "Io eviterei gli arcani e qualunque carta come profilo
/// utente, starebbero irriconoscibili. Usa emblemi, segni, archetipi, animali
/// che sono in 3d e ben riconoscibili". Una carta intera dentro il tondo
/// diventa un francobollo verticale. **L'Arcano personale NON si e' mosso**:
/// resta calcolato dalla nascita (`CartaDiNascitaDeiTarocchi`) e resta nel
/// Cosmic Passport. Esce soltanto da qui: chi lo cerca fra le icone del
/// profilo non lo trovera' piu', ed e' voluto.
///
/// La forma dell'icona e' `famiglia:indice`, la stessa del server
/// (`iconaValida` in `functions/src/sociale.ts`, con `QUANTE_ICONE`).
enum FamigliaDelleIcone {
  segno('I segni', 12),
  animale('Gli animali guida', 12),
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

  /// Se il codice e' un'icona che esiste ancora.
  static bool eValida(String? codice) {
    final pezzi = (codice ?? '').split(':');
    if (pezzi.length != 2) return false;
    for (final f in FamigliaDelleIcone.values) {
      if (f.name == pezzi.first) {
        final i = int.tryParse(pezzi[1]);
        return i != null && i >= 0 && i < f.quante;
      }
    }
    return false;
  }

  /// **IL RIPIEGO E' IL SEGNO DELLA PERSONA, ordine FA voce 01.** Un codice
  /// che non vale piu' (un Arcano scelto prima dell'ordine FA) diventa
  /// l'emblema del SUO segno solare, non l'Ariete per chiunque; solo se il
  /// segno non si conosce, il primo della lista. Lo stesso ripiego del
  /// server (`iconaDelSegno` in `functions/src/il_cerchio_sociale.ts`).
  static String valida(String? codice, {Zodiac? segno}) => eValida(codice)
      ? codice!
      : '${FamigliaDelleIcone.segno.name}:${segno?.index ?? 0}';

  static List<IconaDelProfilo> di(FamigliaDelleIcone f) =>
      [for (var i = 0; i < f.quante; i++) IconaDelProfilo._(f, i)];

  /// L'arte dell'icona, dai set gia' disegnati.
  String get asset => switch (famiglia) {
        FamigliaDelleIcone.segno => ZodiacArt.emblemPath(Zodiac.values[indice]),
        FamigliaDelleIcone.animale => AnimalCatalog.animals[indice].thumbPath,
        FamigliaDelleIcone.archetipo => Archetype.values[indice].arteThumb,
      };

  String get nome => switch (famiglia) {
        FamigliaDelleIcone.segno => Zodiac.values[indice].italianName,
        FamigliaDelleIcone.animale => AnimalCatalog.animals[indice].name,
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
      case FamigliaDelleIcone.archetipo:
        return archetipiIncontrati.contains(indice);
    }
  }

  /// Da dove si apre un'icona spenta.
  String get daDoveSiApre => switch (famiglia) {
        FamigliaDelleIcone.segno => '',
        FamigliaDelleIcone.animale =>
          'Si apre quando incontri questo animale nel Viaggio dello Sciamano.',
        FamigliaDelleIcone.archetipo =>
          'Si apre quando questo archetipo guida il tuo Test degli archetipi.',
      };
}
