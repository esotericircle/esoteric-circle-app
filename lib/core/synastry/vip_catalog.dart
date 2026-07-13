import '../astro/zodiac.dart';

/// Un VIP del cerchio per la Sinastria VIP. Personaggi d'esempio, precaricati
/// per la Demo: nome, segno solare e una riga. Nessun dato privato, nessuna
/// arte, solo il segno per calcolare l'affinita'. L'anagrafica reale e gli
/// asset arriveranno dal bucket e dai dati definitivi.
class Vip {
  const Vip({required this.name, required this.sign, required this.note});

  final String name;
  final Zodiac sign;
  final String note;
}

/// Il catalogo dei VIP precaricati. Almeno uno c'e' sempre, cosi' la Demo puo'
/// aprirsi da qui.
class VipCatalog {
  const VipCatalog._();

  static const List<Vip> vips = [
    Vip(name: 'Aurora Vega', sign: Zodiac.leo, note: 'Icona del grande schermo, cuore di fuoco.'),
    Vip(name: 'Dario Notte', sign: Zodiac.scorpio, note: 'Voce rock dal magnetismo profondo.'),
    Vip(name: 'Sole Marin', sign: Zodiac.aries, note: 'Campionessa dallo slancio inarrestabile.'),
    Vip(name: 'Livia Cielo', sign: Zodiac.pisces, note: 'Poetessa fatta di sogno.'),
    Vip(name: 'Nadir Costa', sign: Zodiac.capricorn, note: 'Architetto di visioni solide.'),
  ];

  static Vip get first => vips.first;
}
