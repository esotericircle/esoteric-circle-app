import 'package:flutter/widgets.dart';

/// **LA GEOMETRIA DELLA LUNA DIPINTA**, ordine FX aggiunta, 16 ottobre 2026:
/// dove la scena del Respiro ha dipinto la sua Luna, perche' la Luna vera di
/// quest'ora (FX.03) si posi li' e non altrove.
///
/// **Il difetto, visto dal fondatore sulla build 2312**: "Perche' sul viso di
/// Medora c'e' una luna o cerchio in semitrasparenza?". La foto della NASA
/// stava centrata a meta' schermo, `Alignment(0, -0.05)`, e meta' schermo
/// nella scena e' il viso di Medora; intanto l'ultimo fotogramma mostrava la
/// Luna dipinta nel cielo, quindi a scena ferma le lune erano due. La scena
/// ha un fondo apposta, `respiro_cielo_senza_luna_v1`, identico all'ultimo
/// fotogramma ma senza la Luna: e' li' che la Luna vera prende il posto di
/// quella dipinta.
///
/// **IL DISCO MISURATO.** La differenza fra `respiro_ultimo_fotogramma_v1` e
/// `respiro_cielo_senza_luna_v1` (1080 per 1920), oltre 120 su 255 in luce:
/// righe da 128 a 621, colonne da 293 a 788, cioe' un disco di circa 495
/// pixel col centro a (540,5; 374,5). Sotto quella soglia c'e' solo l'alone
/// e il riflesso sul mare.
///
/// **IL DISCO NELLA FOTO.** Nei fotogrammi 730 per 730 del Dial-A-Moon la
/// Luna piena (fotogramma 7150) va dalla riga 26 alla 703 e dalla colonna 29
/// alla 703: il disco e' il 93 per cento del lato, centrato. La foto quindi
/// si disegna col lato del disco dipinto diviso 0,93, e un ritaglio tondo al
/// 94 per cento toglie gli angoli neri del JPEG, che sul cielo blu si
/// vedrebbero come un quadrato.
abstract final class GeometriaDellaLunaDipinta {
  /// Il fotogramma della scena, in pixel.
  static const Size fotogramma = Size(1080, 1920);

  /// Il disco della Luna dipinta sul fotogramma, in pixel.
  static const Rect disco = Rect.fromLTRB(293, 128, 788, 621);

  /// Quanta parte del lato della foto NASA occupa il disco della Luna.
  static const double discoNellaFoto = 0.93;

  /// Il ritaglio tondo della foto, in parte del suo lato.
  static const double ritaglioDellaFoto = 0.94;

  /// Il disco dipinto sullo schermo, col taglio `BoxFit.cover` centrato del
  /// fotogramma su una finestra di misura [schermo].
  static Rect discoSulloSchermo(Size schermo) {
    final s = (schermo.width / fotogramma.width) >
            (schermo.height / fotogramma.height)
        ? schermo.width / fotogramma.width
        : schermo.height / fotogramma.height;
    final dx = (schermo.width - fotogramma.width * s) / 2;
    final dy = (schermo.height - fotogramma.height * s) / 2;
    return Rect.fromLTRB(disco.left * s + dx, disco.top * s + dy,
        disco.right * s + dx, disco.bottom * s + dy);
  }

  /// Il lato della foto che fa coincidere il suo disco con quello dipinto.
  static double latoDellaFoto(Size schermo) =>
      discoSulloSchermo(schermo).width / discoNellaFoto;
}
