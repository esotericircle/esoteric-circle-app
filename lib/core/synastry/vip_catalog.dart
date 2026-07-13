import '../astro/zodiac.dart';

/// Un VIP del cerchio per la Sinastria VIP. Personaggi d'esempio, precaricati
/// per la Demo: nome, segno solare e una riga. Nessun dato privato, solo il
/// segno per calcolare l'affinita'.
///
/// [imagePath] e' il ritratto illustrato del VIP in `brand_assets/vip`, scritto
/// come da manifesto degli asset. Resta null finche' l'arte non e' importata: in
/// quel caso la card mostra un ritratto segnaposto curato, non un vuoto. Quando i
/// file reali arrivano basta valorizzare qui il percorso e la card si accende.
class Vip {
  const Vip({
    required this.name,
    required this.sign,
    required this.note,
    this.category = '',
    this.imagePath,
  });

  final String name;
  final Zodiac sign;
  final String note;

  /// Categoria del VIP, per il banner basso della card, ad esempio Cinema,
  /// Musica, Sport. Vuota finche' il dato reale non c'e'.
  final String category;

  /// Percorso del ritratto illustrato, oppure null se l'asset non c'e' ancora.
  final String? imagePath;

  /// Vero se il VIP ha un ritratto reale caricabile.
  bool get hasImage => imagePath != null && imagePath!.isNotEmpty;

  /// Vero se il VIP ha una categoria da mostrare nel banner basso.
  bool get hasCategory => category.isNotEmpty;
}

/// Il catalogo dei VIP precaricati. Almeno uno c'e' sempre, cosi' la Demo puo'
/// aprirsi da qui.
///
/// Nomi e ritratti reali attendono gli asset in `brand_assets/vip` (vedi
/// `docs/STATO_ASSET.md`): la cartella `output/ritratti-vip` non e' presente nel
/// repo, percio' qui restano cinque voci d'esempio dichiarate, con `imagePath`
/// nullo. Valorizzando `imagePath` (e sostituendo le voci con quelle reali) la
/// Sinastria VIP mostra i ritratti senza altre modifiche al codice.
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
