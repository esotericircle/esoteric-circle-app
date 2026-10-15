import 'package:flutter/widgets.dart';

/// **LA GEOMETRIA DEL VELO**, ordine FV voce FV.02, 15 ottobre 2026: il velo
/// che Medora regge a braccia alzate sull'ultimo fotogramma
/// dell'Almanacco di luce, dove si posa il mese di trenta lune.
///
/// **PRIMA STESURA, coi numeri dell'Architetto** (dal 21 al 78 per cento
/// della larghezza del video, dal 19 al 64 per cento dell'altezza): la voce
/// FV.02 li rimisura sul fotogramma e li sostituisce qui, con la cattura di
/// controllo in docs/collaudo/FV/.
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
  static const Rect velo = Rect.fromLTRB(226.8, 364.8, 842.4, 1228.8);

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
