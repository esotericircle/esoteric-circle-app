import 'dart:math' as math;

import '../../core/astro/real_time_cosmo/la_camera_del_cielo.dart';

/// **LA LUNA SI RICONOSCE A COLPO D'OCCHIO.** Ordine GA voce 13. Il
/// fondatore, 20 ottobre 2026: *"il riferimento solitamente per le persone e'
/// la luna e io la trovo [...] piccola e difficilmente individuabile: quando
/// alzo lo sguardo al cielo notturno, io vedo sempre la luna bella grande e
/// tutto il resto sono puntini, a parte il sole ovviamente"*; e sulla misura
/// proposta dall'Architetto, *"1 approvo"*.
///
/// **Prima**: il raggio della Luna era un grado di cielo e mai sotto nove
/// punti, cioe' un disco di circa diciotto punti a settanta gradi di campo.
/// **Adesso**: al campo di partenza il disco e' largo circa un settimo dello
/// schermo, fra 55 e 60 punti; col pizzico cresce e cala in proporzione al
/// campo, e non scende mai sotto i 40 punti, nemmeno a cento gradi. La Luna
/// vera e' mezzo grado: qui e' ingrandita, e il pannello "Fonti e metodo" lo
/// dice ([quanteVolteIngrandita]).
abstract final class LaMisuraDellaLuna {
  /// Il diametro piu' piccolo del disco, in punti, a qualunque campo.
  static const double diametroMinimo = 40;

  /// Il diametro al campo di partenza: un settimo della larghezza, dentro
  /// questi due confini.
  static const double diametroAllaPartenzaMinimo = 55;
  static const double diametroAllaPartenzaMassimo = 60;

  /// **IL DIAMETRO DEL DISCO DELLA LUNA**, in punti, per uno schermo largo
  /// [larghezza] punti col campo orizzontale di [campo] gradi.
  static double diametro({required double larghezza, required double campo}) {
    final allaPartenza = (larghezza / 7)
        .clamp(diametroAllaPartenzaMinimo, diametroAllaPartenzaMassimo);
    final ppg =
        ProiezioneDelCielo(larghezza: larghezza, altezza: 1, campoGradi: campo)
            .puntiPerGrado;
    final ppgAllaPartenza = ProiezioneDelCielo(
            larghezza: larghezza, altezza: 1, campoGradi: kCampoDiPartenza)
        .puntiPerGrado;
    // Al centesimo di punto: il rapporto dei due campi uguali non fa uno
    // esatto in virgola mobile.
    final d =
        (allaPartenza * ppg / ppgAllaPartenza * 100).roundToDouble() / 100;
    return math.max(diametroMinimo, d);
  }

  /// **DI QUANTE VOLTE LA LUNA E' INGRANDITA** rispetto al suo mezzo grado
  /// vero, al campo di partenza, arrotondato: lo dice il pannello delle
  /// fonti.
  static int quanteVolteIngrandita({double larghezza = 400}) {
    final ppg = ProiezioneDelCielo(
            larghezza: larghezza, altezza: 1, campoGradi: kCampoDiPartenza)
        .puntiPerGrado;
    return (diametro(larghezza: larghezza, campo: kCampoDiPartenza) /
            (0.5 * ppg))
        .round();
  }

  /// **IL LATO PIU' GRANDE DELL'IMMAGINE COTTA, in pixel.** La Luna si cuoce
  /// in un'immagine larga dieci raggi (l'alone arriva a 4,6 raggi); nella
  /// corsa della macchina del tempo, ingrandita cinque volte, l'immagine del
  /// disco nuovo arriverebbe a circa 4.300 pixel di lato, settanta megabyte.
  /// Oltre questo lato si cuoce piu' piccola e si posa ingrandita: nella
  /// corsa la Luna si muove, e il dettaglio in piu' non si vede.
  static const int latoCottoMassimo = 2048;

  /// **IL RAGGIO DELLO SPRITE DEL SOLE** perche' il suo disco pieno sia grande
  /// quanto quello della Luna: lo sprite comune e' pieno fino al 16 per
  /// cento del raggio, poi alone. *"Il Sole segue la stessa regola, dove il
  /// cielo lo mostra"* (ordine GA voce 13).
  static double raggioDelSole(double diametroDellaLuna) =>
      diametroDellaLuna / 2 / 0.16;
}
