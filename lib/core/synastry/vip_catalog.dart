import '../assets/family_image.dart';
import '../astro/zodiac.dart';

/// Un VIP del cerchio per la Sinastria VIP: nome, segno solare, una riga e il
/// ritratto bundlato.
///
/// Il segno deriva dalla data di nascita reale del personaggio (fonte
/// verificabile), e serve solo a calcolare l'affinita' col cielo della persona.
/// Il ritratto e' bundlato nella famiglia `ritratti-vip`: [stem] e' il nome del
/// file senza estensione, e i percorsi si risolvono da [FamilyImage]. Funzione
/// di intrattenimento, nessun dato privato.
class Vip {
  const Vip({
    required this.name,
    required this.sign,
    required this.note,
    this.category = '',
    this.stem,
  });

  final String name;
  final Zodiac sign;
  final String note;

  /// Categoria del VIP, per il banner basso della card. Vuota se non nota.
  final String category;

  /// Nome del file del ritratto senza estensione, oppure null se non agganciato.
  final String? stem;

  /// Percorso della miniatura del ritratto, per il picker e la card.
  String? get thumbPath =>
      stem == null ? null : FamilyImage.thumb(AssetFamily.vip, stem!);

  /// Percorso del ritratto pieno, per la vista a fuoco o ingrandita.
  String? get fullPath =>
      stem == null ? null : FamilyImage.full(AssetFamily.vip, stem!);

  bool get hasImage => stem != null;
  bool get hasCategory => category.isNotEmpty;
}

/// I 50 VIP precaricati per la Sinastria, dal corpus `docs/corpus/vip.json`,
/// ognuno col ritratto bundlato e il segno solare dalla data reale.
class VipCatalog {
  const VipCatalog._();

  static const List<Vip> vips = [
    Vip(name: 'Angelina Jolie', sign: Zodiac.gemini, note: '4 giugno 1975', stem: 'vip_angelina-jolie_v1'),
    Vip(name: 'Ariana Grande', sign: Zodiac.cancer, note: '26 giugno 1993', stem: 'vip_ariana-grande_v1'),
    Vip(name: 'Bad Bunny', sign: Zodiac.pisces, note: '10 marzo 1994', stem: 'vip_bad-bunny_v1'),
    Vip(name: 'Beyonce', sign: Zodiac.virgo, note: '4 settembre 1981', stem: 'vip_beyonce_v1'),
    Vip(name: 'Bill Gates', sign: Zodiac.scorpio, note: '28 ottobre 1955', stem: 'vip_bill-gates_v1'),
    Vip(name: 'Billie Eilish', sign: Zodiac.sagittarius, note: '18 dicembre 2001', stem: 'vip_billie-eilish_v1'),
    Vip(name: 'Brad Pitt', sign: Zodiac.sagittarius, note: '18 dicembre 1963', stem: 'vip_brad-pitt_v1'),
    Vip(name: 'Chiara Ferragni', sign: Zodiac.taurus, note: '7 maggio 1987', stem: 'vip_chiara-ferragni_v1'),
    Vip(name: 'Damiano David', sign: Zodiac.capricorn, note: '8 gennaio 1999', stem: 'vip_damiano-david_v1'),
    Vip(name: 'Leonardo DiCaprio', sign: Zodiac.scorpio, note: '11 novembre 1974', stem: 'vip_dicaprio_v1'),
    Vip(name: 'Drake', sign: Zodiac.scorpio, note: '24 ottobre 1986', stem: 'vip_drake_v1'),
    Vip(name: 'Dwayne Johnson', sign: Zodiac.taurus, note: '2 maggio 1972', stem: 'vip_dwayne-johnson_v1'),
    Vip(name: 'Elon Musk', sign: Zodiac.cancer, note: '28 giugno 1971', stem: 'vip_elon-musk_v1'),
    Vip(name: 'Emma Watson', sign: Zodiac.aries, note: '15 aprile 1990', stem: 'vip_emma-watson_v1'),
    Vip(name: 'Roger Federer', sign: Zodiac.leo, note: '8 agosto 1981', stem: 'vip_federer_v1'),
    Vip(name: 'Fedez', sign: Zodiac.libra, note: '15 ottobre 1989', stem: 'vip_fedez_v1'),
    Vip(name: 'Giorgio Armani', sign: Zodiac.cancer, note: '11 luglio 1934', stem: 'vip_giorgio-armani_v1'),
    Vip(name: 'Jeff Bezos', sign: Zodiac.capricorn, note: '12 gennaio 1964', stem: 'vip_jeff-bezos_v1'),
    Vip(name: 'Kanye West', sign: Zodiac.gemini, note: '8 giugno 1977', stem: 'vip_kanye-west_v1'),
    Vip(name: 'Keanu Reeves', sign: Zodiac.virgo, note: '2 settembre 1964', stem: 'vip_keanu-reeves_v1'),
    Vip(name: 'Kim Kardashian', sign: Zodiac.libra, note: '21 ottobre 1980', stem: 'vip_kim-kardashian_v1'),
    Vip(name: 'Kylie Jenner', sign: Zodiac.leo, note: '10 agosto 1997', stem: 'vip_kylie-jenner_v1'),
    Vip(name: 'Lady Gaga', sign: Zodiac.aries, note: '28 marzo 1986', stem: 'vip_lady-gaga_v1'),
    Vip(name: 'LeBron James', sign: Zodiac.capricorn, note: '30 dicembre 1984', stem: 'vip_lebron-james_v1'),
    Vip(name: 'Margot Robbie', sign: Zodiac.cancer, note: '2 luglio 1990', stem: 'vip_margot-robbie_v1'),
    Vip(name: 'Mark Zuckerberg', sign: Zodiac.taurus, note: '14 maggio 1984', stem: 'vip_mark-zuckerberg_v1'),
    Vip(name: 'Kylian Mbappe', sign: Zodiac.sagittarius, note: '20 dicembre 1998', stem: 'vip_mbappe_v1'),
    Vip(name: 'Lionel Messi', sign: Zodiac.cancer, note: '24 giugno 1987', stem: 'vip_messi_v1'),
    Vip(name: 'Michelle Obama', sign: Zodiac.capricorn, note: '17 gennaio 1964', stem: 'vip_michelle-obama_v1'),
    Vip(name: 'Monica Bellucci', sign: Zodiac.libra, note: '30 settembre 1964', stem: 'vip_monica-bellucci_v1'),
    Vip(name: 'Rafael Nadal', sign: Zodiac.gemini, note: '3 giugno 1986', stem: 'vip_nadal_v1'),
    Vip(name: 'Oprah Winfrey', sign: Zodiac.aquarius, note: '29 gennaio 1954', stem: 'vip_oprah-winfrey_v1'),
    Vip(name: 'Priyanka Chopra', sign: Zodiac.cancer, note: '18 luglio 1982', stem: 'vip_priyanka-chopra_v1'),
    Vip(name: 'Rihanna', sign: Zodiac.pisces, note: '20 febbraio 1988', stem: 'vip_rihanna_v1'),
    Vip(name: 'Cristiano Ronaldo', sign: Zodiac.aquarius, note: '5 febbraio 1985', stem: 'vip_ronaldo_v1'),
    Vip(name: 'Scarlett Johansson', sign: Zodiac.sagittarius, note: '22 novembre 1984', stem: 'vip_scarlett-johansson_v1'),
    Vip(name: 'Selena Gomez', sign: Zodiac.cancer, note: '22 luglio 1992', stem: 'vip_selena-gomez_v1'),
    Vip(name: 'Serena Williams', sign: Zodiac.libra, note: '26 settembre 1981', stem: 'vip_serena-williams_v1'),
    Vip(name: 'Shakira', sign: Zodiac.aquarius, note: '2 febbraio 1977', stem: 'vip_shakira_v1'),
    Vip(name: 'Jannik Sinner', sign: Zodiac.leo, note: '16 agosto 2001', stem: 'vip_sinner_v1'),
    Vip(name: 'Snoop Dogg', sign: Zodiac.libra, note: '20 ottobre 1971', stem: 'vip_snoop-dogg_v1'),
    Vip(name: 'Steve Jobs', sign: Zodiac.pisces, note: '24 febbraio 1955', stem: 'vip_steve-jobs_v1'),
    Vip(name: 'Taylor Swift', sign: Zodiac.sagittarius, note: '13 dicembre 1989', stem: 'vip_taylor-swift_v1'),
    Vip(name: 'The Weeknd', sign: Zodiac.aquarius, note: '16 febbraio 1990', stem: 'vip_the-weeknd_v1'),
    Vip(name: 'Timothee Chalamet', sign: Zodiac.capricorn, note: '27 dicembre 1995', stem: 'vip_timothee-chalamet_v1'),
    Vip(name: 'Tom Cruise', sign: Zodiac.cancer, note: '3 luglio 1962', stem: 'vip_tom-cruise_v1'),
    Vip(name: 'Usain Bolt', sign: Zodiac.leo, note: '21 agosto 1986', stem: 'vip_usain-bolt_v1'),
    Vip(name: 'Valentino Rossi', sign: Zodiac.aquarius, note: '16 febbraio 1979', stem: 'vip_valentino-rossi_v1'),
    Vip(name: 'Warren Buffett', sign: Zodiac.virgo, note: '30 agosto 1930', stem: 'vip_warren-buffett_v1'),
    Vip(name: 'Zendaya', sign: Zodiac.virgo, note: '1 settembre 1996', stem: 'vip_zendaya_v1'),
  ];

  static Vip get first => vips.first;
}
