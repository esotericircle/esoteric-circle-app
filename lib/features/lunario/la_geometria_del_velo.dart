import 'package:flutter/widgets.dart';

/// **LA GEOMETRIA DEL VELO**, ordine FV voce FV.02, 15 ottobre 2026: il velo
/// che Medora regge a braccia alzate sull'ultimo fotogramma
/// dell'Almanacco di luce, dove si posa il mese di trenta lune.
///
/// **IL VELO MISURATO**, voce FV.02. Il velo e' chiuso a sinistra e a destra
/// da due fili di luce verticali, e sono loro la misura: la colonna del
/// filo e le righe in cui e' acceso, trovate da
/// tool/gli_asset_dell_ordine_fv.py sul file
/// lunario_ultimo_fotogramma_v1.jpg (1080 per 1920). Filo sinistro colonna
/// 239, acceso dalla riga 307 alla 1086; filo destro colonna 836, dalla 240
/// alla 1094. Il velo e' cio' che chiudono tutti e due insieme: da 239 a
/// 837 in larghezza (dal 22,1 al 77,5 per cento), da 307 a 1087 in altezza
/// (dal 16,0 al 56,6 per cento). Il tratto del filo destro piu' in alto
/// passa davanti al viso di Medora e non e' velo.
///
/// L'Architetto aveva stimato dal 21 al 78 per cento della larghezza e dal
/// 19 al 64 dell'altezza: in larghezza coincide entro 13 pixel per lato; in
/// altezza il suo rettangolo scende fino al vortice di luce sopra il libro,
/// sotto la fine dei fili. La cattura di controllo disegna i due
/// rettangoli: docs/collaudo/FV/fv02_il_velo_misurato.png (oro il velo
/// misurato, rosso quello dell'Architetto); i numeri in
/// docs/collaudo/FV/fv01_asset.txt.
abstract final class GeometriaDelVelo {
  static const String primoFotogramma =
      'assets/img/calendario_lunare/lunario_primo_fotogramma_v1.webp';
  static const String ultimoFotogramma =
      'assets/img/calendario_lunare/lunario_ultimo_fotogramma_v1.webp';
  static const String filmato =
      'brand_assets/calendario_lunare/medora_almanacco_di_luce_v1.mp4';

  /// Il fotogramma del video, in pixel.
  static const Size fotogramma = Size(1080, 1920);

  /// Il velo sul fotogramma, in pixel.
  static const Rect velo = Rect.fromLTRB(239, 307, 837, 1087);

  /// Il velo sullo schermo, col taglio `BoxFit.cover` centrato del
  /// fotogramma su una finestra di misura [schermo].
  static Rect veloSulloSchermo(Size schermo) {
    final s = (schermo.width / fotogramma.width) >
            (schermo.height / fotogramma.height)
        ? schermo.width / fotogramma.width
        : schermo.height / fotogramma.height;
    final dx = (schermo.width - fotogramma.width * s) / 2;
    final dy = (schermo.height - fotogramma.height * s) / 2;
    return Rect.fromLTRB(velo.left * s + dx, velo.top * s + dy,
        velo.right * s + dx, velo.bottom * s + dy);
  }
}
