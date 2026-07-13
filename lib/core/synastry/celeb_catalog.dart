import '../astro/zodiac.dart';

/// Un VIP del cerchio per la Sinastria Celeb. Personaggi d'esempio, precaricati
/// per la Demo: nome, segno solare e una riga. Nessun dato privato, nessuna
/// arte, solo il segno per calcolare l'affinita'. L'anagrafica reale e gli
/// asset arriveranno dal bucket e dai dati definitivi.
class Celeb {
  const Celeb({required this.name, required this.sign, required this.note});

  final String name;
  final Zodiac sign;
  final String note;
}

/// Il catalogo dei VIP precaricati. Almeno uno c'e' sempre, cosi' la Demo puo'
/// aprirsi da qui.
class CelebCatalog {
  const CelebCatalog._();

  static const List<Celeb> vips = [
    Celeb(name: 'Aurora Vega', sign: Zodiac.leo, note: 'Icona del grande schermo, cuore di fuoco.'),
    Celeb(name: 'Dario Notte', sign: Zodiac.scorpio, note: 'Voce rock dal magnetismo profondo.'),
    Celeb(name: 'Sole Marin', sign: Zodiac.aries, note: 'Campionessa dallo slancio inarrestabile.'),
    Celeb(name: 'Livia Cielo', sign: Zodiac.pisces, note: 'Poetessa fatta di sogno.'),
    Celeb(name: 'Nadir Costa', sign: Zodiac.capricorn, note: 'Architetto di visioni solide.'),
  ];

  static Celeb get first => vips.first;
}
