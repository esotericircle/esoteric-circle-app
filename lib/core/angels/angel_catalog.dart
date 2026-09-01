/// I settantadue Angeli dello Shemhamphorash, con i nove cori che li reggono.
///
/// Tradizione cabalistica: dal versetto triplice dell'Esodo si ricavano
/// settantadue nomi di tre lettere, a ciascuno dei quali si aggiunge il
/// suffisso divino, IAH oppure EL. I settantadue si dispongono in nove cori da
/// otto, ognuno retto da un arcangelo e legato a un dominio.
///
/// Cosa c'e' qui dentro e cosa no. Ci sono il numero d'ordine, il nome, il coro,
/// l'arcangelo che lo regge e il dominio del coro: tutto verificato sulla
/// tradizione. NON ci sono virtu' e salmo del singolo angelo, che vanno presi da
/// fonte e non inventati: quando il Corpus arrivera' in `docs/corpus/angeli.md`
/// si aggiungono qui, e le schermate li mostreranno senza altre modifiche.
/// Finche' mancano, le schermate lo dichiarano invece di lasciare un vuoto.
///
/// I nomi coincidono con gli stem degli asset in `assets/img/angeli/`, prodotti
/// dallo stesso Corpus: nome e immagine non possono divergere per costruzione,
/// perche' il percorso si ricava dal numero e dallo slug.
library;

import 'angel_lore.dart';

/// Un coro angelico: otto angeli, un arcangelo che li regge, un dominio.
class AngelChoir {
  const AngelChoir({
    required this.name,
    required this.archangel,
    required this.domain,
  });

  final String name;
  final String archangel;

  /// Il dominio del coro, cioe' su che cosa quel coro veglia. E' del coro, non
  /// del singolo angelo: il dettaglio per angelo arrivera' dal Corpus.
  final String domain;
}

/// Un angelo dei settantadue.
class Angel {
  const Angel({
    required this.number,
    required this.seedName,
    required this.slug,
    required this.choir,
  });

  /// Da 1 a 72, nell'ordine della tradizione.
  final int number;

  /// Nome di riserva, dagli stem delle immagini. A schermo vale [name], che
  /// preferisce la grafia del Corpus quando c'e': Ieliel e Jeliel sono lo
  /// stesso angelo, ma la fonte verificata dice Ieliel.
  final String seedName;

  /// Parte del nome nel percorso dell'asset, in minuscolo.
  final String slug;
  final AngelChoir choir;

  /// L'arte piena dell'angelo. Il numero e' sempre a due cifre.
  String get artStem => 'ang_${number.toString().padLeft(2, '0')}_${slug}_v1';

  /// Il contenuto documentato dal Corpus, quando c'e'.
  AngelLore? get lore => kAngelLore[number];

  /// Il nome mostrato: quello del Corpus se c'e', altrimenti il seme.
  String get name => lore?.name ?? seedName;

  /// Il grado zodiacale da cui questo angelo comincia, contando dal primo
  /// grado dell'Ariete. Ogni angelo governa cinque gradi.
  double get startDegree => (number - 1) * 5.0;
}

/// I nove cori e i settantadue angeli.
class AngelCatalog {
  const AngelCatalog._();

  static const AngelChoir serafini = AngelChoir(
    name: 'Serafini',
    archangel: 'Metatron',
    domain: 'l\'amore che arde e la volontà che accende',
  );
  static const AngelChoir cherubini = AngelChoir(
    name: 'Cherubini',
    archangel: 'Raziel',
    domain: 'la sapienza e la luce che mette ordine',
  );
  static const AngelChoir troni = AngelChoir(
    name: 'Troni',
    archangel: 'Tsaphkiel',
    domain: 'la comprensione profonda e la fermezza',
  );
  static const AngelChoir dominazioni = AngelChoir(
    name: 'Dominazioni',
    archangel: 'Tsadkiel',
    domain: 'la misericordia e l\'abbondanza che si apre',
  );
  static const AngelChoir potenze = AngelChoir(
    name: 'Potenze',
    archangel: 'Camael',
    domain: 'la forza e il rigore che pone confini',
  );
  static const AngelChoir virtu = AngelChoir(
    name: 'Virtu\'',
    archangel: 'Raphael',
    domain: 'la bellezza e l\'armonia che guarisce',
  );
  static const AngelChoir principati = AngelChoir(
    name: 'Principati',
    archangel: 'Haniel',
    domain: 'la vittoria e lo slancio che persiste',
  );
  static const AngelChoir arcangeli = AngelChoir(
    name: 'Arcangeli',
    archangel: 'Michael',
    domain: 'la gloria e la parola che annuncia',
  );
  static const AngelChoir angeli = AngelChoir(
    name: 'Angeli',
    archangel: 'Gabriel',
    domain: 'il fondamento e la materia che si compie',
  );

  /// I nove cori nell'ordine, dal primo all'ultimo.
  static const List<AngelChoir> choirs = [
    serafini,
    cherubini,
    troni,
    dominazioni,
    potenze,
    virtu,
    principati,
    arcangeli,
    angeli,
  ];

  /// I settantadue, in ordine. Il coro si ricava dalla posizione, otto per
  /// coro, quindi non puo' divergere dall'ordine.
  static const List<Angel> all = [
    Angel(number: 1, seedName: 'Vehuiah', slug: 'vehuiah', choir: serafini),
    Angel(number: 2, seedName: 'Jeliel', slug: 'jeliel', choir: serafini),
    Angel(number: 3, seedName: 'Sitael', slug: 'sitael', choir: serafini),
    Angel(number: 4, seedName: 'Elemiah', slug: 'elemiah', choir: serafini),
    Angel(number: 5, seedName: 'Mahasiah', slug: 'mahasiah', choir: serafini),
    Angel(number: 6, seedName: 'Lelahel', slug: 'lelahel', choir: serafini),
    Angel(number: 7, seedName: 'Achaiah', slug: 'achaiah', choir: serafini),
    Angel(number: 8, seedName: 'Cahetel', slug: 'cahetel', choir: serafini),
    Angel(number: 9, seedName: 'Haziel', slug: 'haziel', choir: cherubini),
    Angel(number: 10, seedName: 'Aladiah', slug: 'aladiah', choir: cherubini),
    Angel(number: 11, seedName: 'Lauviah', slug: 'lauviah', choir: cherubini),
    Angel(number: 12, seedName: 'Hahaiah', slug: 'hahaiah', choir: cherubini),
    Angel(number: 13, seedName: 'Iezalel', slug: 'iezalel', choir: cherubini),
    Angel(number: 14, seedName: 'Mebahel', slug: 'mebahel', choir: cherubini),
    Angel(number: 15, seedName: 'Hariel', slug: 'hariel', choir: cherubini),
    Angel(number: 16, seedName: 'Hekamiah', slug: 'hekamiah', choir: cherubini),
    Angel(number: 17, seedName: 'Lauviah II', slug: 'lauviah-ii', choir: troni),
    Angel(number: 18, seedName: 'Caliel', slug: 'caliel', choir: troni),
    Angel(number: 19, seedName: 'Leuviah', slug: 'leuviah', choir: troni),
    Angel(number: 20, seedName: 'Pahaliah', slug: 'pahaliah', choir: troni),
    Angel(number: 21, seedName: 'Nelchael', slug: 'nelchael', choir: troni),
    Angel(number: 22, seedName: 'Yeiayel', slug: 'yeiayel', choir: troni),
    Angel(number: 23, seedName: 'Melahel', slug: 'melahel', choir: troni),
    Angel(number: 24, seedName: 'Haheuiah', slug: 'haheuiah', choir: troni),
    Angel(
        number: 25,
        seedName: 'Nith-Haiah',
        slug: 'nith-haiah',
        choir: dominazioni),
    Angel(number: 26, seedName: 'Haaiah', slug: 'haaiah', choir: dominazioni),
    Angel(
        number: 27, seedName: 'Yerathel', slug: 'yerathel', choir: dominazioni),
    Angel(number: 28, seedName: 'Seheiah', slug: 'seheiah', choir: dominazioni),
    Angel(number: 29, seedName: 'Reiyel', slug: 'reiyel', choir: dominazioni),
    Angel(number: 30, seedName: 'Omael', slug: 'omael', choir: dominazioni),
    Angel(number: 31, seedName: 'Lecabel', slug: 'lecabel', choir: dominazioni),
    Angel(
        number: 32, seedName: 'Vasariah', slug: 'vasariah', choir: dominazioni),
    Angel(number: 33, seedName: 'Yehuiah', slug: 'yehuiah', choir: potenze),
    Angel(number: 34, seedName: 'Lehahiah', slug: 'lehahiah', choir: potenze),
    Angel(number: 35, seedName: 'Chavakiah', slug: 'chavakiah', choir: potenze),
    Angel(number: 36, seedName: 'Menadel', slug: 'menadel', choir: potenze),
    Angel(number: 37, seedName: 'Aniel', slug: 'aniel', choir: potenze),
    Angel(number: 38, seedName: 'Haamiah', slug: 'haamiah', choir: potenze),
    Angel(number: 39, seedName: 'Rehael', slug: 'rehael', choir: potenze),
    Angel(number: 40, seedName: 'Ieiazel', slug: 'ieiazel', choir: potenze),
    Angel(number: 41, seedName: 'Hahahel', slug: 'hahahel', choir: virtu),
    Angel(number: 42, seedName: 'Mikael', slug: 'mikael', choir: virtu),
    Angel(number: 43, seedName: 'Veuliah', slug: 'veuliah', choir: virtu),
    Angel(number: 44, seedName: 'Yelahiah', slug: 'yelahiah', choir: virtu),
    Angel(number: 45, seedName: 'Sealiah', slug: 'sealiah', choir: virtu),
    Angel(number: 46, seedName: 'Ariel', slug: 'ariel', choir: virtu),
    Angel(number: 47, seedName: 'Asaliah', slug: 'asaliah', choir: virtu),
    Angel(number: 48, seedName: 'Mihael', slug: 'mihael', choir: virtu),
    Angel(number: 49, seedName: 'Vehuel', slug: 'vehuel', choir: principati),
    Angel(number: 50, seedName: 'Daniel', slug: 'daniel', choir: principati),
    Angel(
        number: 51, seedName: 'Hahasiah', slug: 'hahasiah', choir: principati),
    Angel(number: 52, seedName: 'Imamiah', slug: 'imamiah', choir: principati),
    Angel(number: 53, seedName: 'Nanael', slug: 'nanael', choir: principati),
    Angel(number: 54, seedName: 'Nithael', slug: 'nithael', choir: principati),
    Angel(
        number: 55, seedName: 'Mebahiah', slug: 'mebahiah', choir: principati),
    Angel(number: 56, seedName: 'Poyel', slug: 'poyel', choir: principati),
    Angel(number: 57, seedName: 'Nemamiah', slug: 'nemamiah', choir: arcangeli),
    Angel(number: 58, seedName: 'Yeialel', slug: 'yeialel', choir: arcangeli),
    Angel(number: 59, seedName: 'Harahel', slug: 'harahel', choir: arcangeli),
    Angel(number: 60, seedName: 'Mitzrael', slug: 'mitzrael', choir: arcangeli),
    Angel(number: 61, seedName: 'Umabel', slug: 'umabel', choir: arcangeli),
    Angel(number: 62, seedName: 'Iah-Hel', slug: 'iah-hel', choir: arcangeli),
    Angel(number: 63, seedName: 'Anauel', slug: 'anauel', choir: arcangeli),
    Angel(number: 64, seedName: 'Mehiel', slug: 'mehiel', choir: arcangeli),
    Angel(number: 65, seedName: 'Damabiah', slug: 'damabiah', choir: angeli),
    Angel(number: 66, seedName: 'Manakel', slug: 'manakel', choir: angeli),
    Angel(number: 67, seedName: 'Eyael', slug: 'eyael', choir: angeli),
    Angel(number: 68, seedName: 'Habuhiah', slug: 'habuhiah', choir: angeli),
    Angel(number: 69, seedName: 'Rochel', slug: 'rochel', choir: angeli),
    Angel(number: 70, seedName: 'Jabamiah', slug: 'jabamiah', choir: angeli),
    Angel(number: 71, seedName: 'Haiaiel', slug: 'haiaiel', choir: angeli),
    Angel(number: 72, seedName: 'Mumiah', slug: 'mumiah', choir: angeli),
  ];

  /// L'angelo di un numero da 1 a 72. Fuori intervallo si rientra col modulo,
  /// cosi' chi calcola non deve preoccuparsi del giro.
  static Angel byNumber(int number) {
    final i = ((number - 1) % 72 + 72) % 72;
    return all[i];
  }
}
