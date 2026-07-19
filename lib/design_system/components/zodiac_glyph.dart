import 'package:flutter/material.dart';

import '../../core/astro/zodiac.dart';

/// Le due arti zodiacali brandizzate, due asset distinti per segno.
///
/// - [emblem]: l'emblema grande del segno in 3D metallico multicolore, per il
///   colpo d'occhio in testa alla schermata. Sta in `assets/img/zodiac/`.
/// - [symbol]: il simbolo in miniatura, per i chip del selettore. Sta in
///   `assets/img_thumb/zodiac/`.
///
/// Sono due immagini sorgenti diverse fornite da Mauro, gia' scontornate: la
/// miniatura NON si ricava riducendo l'emblema, si carica il suo asset.
enum ZodiacEmblemArt { emblem, symbol }

/// L'arte dei dodici segni zodiacali brandizzati.
///
/// Due asset per segno, stesso stem `zod_<segno>` ma file diversi: l'emblema 3D
/// in `assets/img/zodiac/` ([emblemPath]) e il simbolo in miniatura in
/// `assets/img_thumb/zodiac/` ([symbolPath]). Ventiquattro file in tutto, tutti
/// presenti nel bundle: non c'e' piu' ripiego dipinto, si mostra sempre l'arte
/// vera, mai il carattere di sistema.
class ZodiacArt {
  const ZodiacArt._();

  static String stem(Zodiac z) => 'zod_${z.italianName.toLowerCase()}';

  /// L'emblema grande 3D metallico, per la testa della schermata.
  static String emblemPath(Zodiac z) => 'assets/img/zodiac/${stem(z)}.webp';

  /// Il simbolo in miniatura, per i chip del selettore.
  static String symbolPath(Zodiac z) =>
      'assets/img_thumb/zodiac/${stem(z)}.webp';

  static String pathFor(Zodiac z, ZodiacEmblemArt art) =>
      art == ZodiacEmblemArt.emblem ? emblemPath(z) : symbolPath(z);
}

/// L'arte di un segno: l'emblema 3D oppure il simbolo in miniatura, secondo
/// [art]. Gli asset ci sono tutti, quindi si mostra sempre l'immagine vera.
class ZodiacEmblem extends StatelessWidget {
  const ZodiacEmblem({
    super.key,
    required this.sign,
    required this.size,
    this.art = ZodiacEmblemArt.emblem,
    this.assetPath,
  });

  final Zodiac sign;
  final double size;

  /// Quale delle due arti del segno mostrare (emblema o simbolo).
  final ZodiacEmblemArt art;

  /// Percorso dell'asset, per i test. Se nullo si risolve da [ZodiacArt].
  final String? assetPath;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        assetPath ?? ZodiacArt.pathFor(sign, art),
        width: size,
        height: size,
        fit: BoxFit.contain,
        // Gli asset sono tutti nel bundle: se mai uno mancasse si lascia il
        // posto vuoto invece di schiantare, senza ripieghi disegnati.
        errorBuilder: (_, __, ___) => SizedBox(width: size, height: size),
      ),
    );
  }
}
