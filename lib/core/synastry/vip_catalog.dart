import '../assets/family_image.dart';
import '../astro/zodiac.dart';

/// Un VIP del cerchio per la Sinastria VIP. Personaggi d'esempio, precaricati
/// per la Demo: nome, segno solare e una riga. Nessun dato privato, solo il
/// segno per calcolare l'affinita'.
///
/// Il ritratto illustrato del VIP e' ora bundlato in WebP a due misure nella
/// famiglia `ritratti-vip`: si indica con [stem], il nome del file senza
/// estensione (per esempio `vip_angelina-jolie_v1`), e i percorsi si risolvono
/// da [FamilyImage] (miniatura per il picker e la card, piena a fuoco). Resta
/// null finche' la voce non porta il suo stem reale: in quel caso la card mostra
/// un ritratto segnaposto curato, non un vuoto. Valorizzando [stem] la card si
/// accende senza altre modifiche.
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

  /// Categoria del VIP, per il banner basso della card, ad esempio Cinema,
  /// Musica, Sport. Vuota finche' il dato reale non c'e'.
  final String category;

  /// Nome del file bundlato senza estensione, in minuscolo, oppure null se
  /// l'arte reale non e' ancora agganciata a questa voce.
  final String? stem;

  /// Percorso della miniatura del ritratto, per il picker e la card. Null se
  /// non c'e' ancora arte.
  String? get thumbPath =>
      stem == null ? null : FamilyImage.thumb(AssetFamily.vip, stem!);

  /// Percorso del ritratto pieno, per la vista a fuoco o ingrandita.
  String? get fullPath =>
      stem == null ? null : FamilyImage.full(AssetFamily.vip, stem!);

  /// Vero se il VIP ha un ritratto reale caricabile.
  bool get hasImage => stem != null;

  /// Vero se il VIP ha una categoria da mostrare nel banner basso.
  bool get hasCategory => category.isNotEmpty;
}

/// Il catalogo dei VIP precaricati. Almeno uno c'e' sempre, cosi' la Demo puo'
/// aprirsi da qui.
///
/// I 50 ritratti reali sono ora bundlati nella famiglia `ritratti-vip`
/// (assets/img e assets/img_thumb, vedi `docs/stato_asset.json`). Qui restano
/// cinque voci d'esempio dichiarate, con [Vip.stem] nullo, perche' i nomi e i
/// segni reali dei VIP sono contenuto ancora da compilare. Dando a una voce il
/// suo stem (il nome del file senza estensione, per esempio
/// `vip_angelina-jolie_v1`) la Sinastria VIP mostra il ritratto senza altre
/// modifiche al codice: i percorsi si risolvono da `FamilyImage`.
class VipCatalog {
  const VipCatalog._();

  static const List<Vip> vips = [
    Vip(name: 'Aurora Vega', sign: Zodiac.leo, category: 'Cinema', note: 'Icona del grande schermo, cuore di fuoco.'),
    Vip(name: 'Dario Notte', sign: Zodiac.scorpio, category: 'Musica', note: 'Voce rock dal magnetismo profondo.'),
    Vip(name: 'Sole Marin', sign: Zodiac.aries, category: 'Sport', note: 'Campionessa dallo slancio inarrestabile.'),
    Vip(name: 'Livia Cielo', sign: Zodiac.pisces, category: 'Poesia', note: 'Poetessa fatta di sogno.'),
    Vip(name: 'Nadir Costa', sign: Zodiac.capricorn, category: 'Design', note: 'Architetto di visioni solide.'),
  ];

  static Vip get first => vips.first;
}
