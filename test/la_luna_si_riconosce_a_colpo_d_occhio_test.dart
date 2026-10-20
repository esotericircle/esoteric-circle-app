import 'package:esoteric_circle/core/astro/real_time_cosmo/la_camera_del_cielo.dart';
import 'package:esoteric_circle/features/maestri/widgets/foglio_delle_fonti.dart';
import 'package:esoteric_circle/features/real_time_cosmo/la_misura_della_luna.dart';
import 'package:flutter_test/flutter_test.dart';

/// **LA LUNA SI RICONOSCE A COLPO D'OCCHIO.** Ordine GA voce 13. Il
/// fondatore, 20 ottobre 2026: *"quando alzo lo sguardo al cielo notturno, io
/// vedo sempre la luna bella grande e tutto il resto sono puntini"*.
///
/// **Il fatto**: il raggio della Luna era un grado di cielo e mai sotto nove
/// punti, cioe' un disco di circa diciotto punti a settanta gradi di campo.
/// Padre: ordine FG (il cielo reale), che la disegnava "come in ogni carta del
/// cielo".
///
/// **Cosa misura**: al campo di partenza il disco e' fra 55 e 60 punti, su
/// uno schermo stretto e su uno largo; a cento gradi non scende sotto 40; a
/// diciotto cresce in proporzione al campo; il pannello delle fonti dice di
/// quanto e' ingrandita, e il numero e' quello vero. Il disco sul fotogramma
/// vero lo misura la prova della Macchina del tempo (I11), che legge
/// `lunaLato`.
void main() {
  double ppg(double larghezza, double campo) =>
      ProiezioneDelCielo(larghezza: larghezza, altezza: 1, campoGradi: campo)
          .puntiPerGrado;

  test('AL CAMPO DI PARTENZA IL DISCO E\' FRA 55 E 60 PUNTI', () {
    for (final larghezza in [360.0, 393.0, 411.0, 430.0]) {
      final d = LaMisuraDellaLuna.diametro(
          larghezza: larghezza, campo: kCampoDiPartenza);
      expect(d, inInclusiveRange(55, 60),
          reason: 'a $larghezza punti di larghezza la Luna e\' larga '
              '${d.toStringAsFixed(1)} punti: non si riconosce');
    }
  });

  test('A CENTO GRADI NON SCENDE SOTTO 40, A DICIOTTO CRESCE COL CAMPO', () {
    const larghezza = 360.0;
    expect(LaMisuraDellaLuna.diametro(larghezza: larghezza, campo: 100),
        greaterThanOrEqualTo(40));
    final a70 = LaMisuraDellaLuna.diametro(
        larghezza: larghezza, campo: kCampoDiPartenza);
    final a18 = LaMisuraDellaLuna.diametro(larghezza: larghezza, campo: 18);
    expect(a18 / a70, closeTo(ppg(larghezza, 18) / ppg(larghezza, 70), 0.01),
        reason: 'col pizzico la Luna non cresce in proporzione al campo');
  });

  test(
      'IL PANNELLO DELLE FONTI DICE DI QUANTO E\' INGRANDITA, E IL NUMERO '
      'E\' QUELLO VERO', () {
    final volte = LaMisuraDellaLuna.quanteVolteIngrandita();
    expect(volte, inInclusiveRange(19, 22));
    expect(TestiDelleFonti.realTimeCosmo, contains('circa venti volte'));
    expect(TestiDelleFonti.macchinaDelTempo, contains('venti volte'),
        reason: 'la macchina del tempo dice ancora che a riposo la Luna ha '
            'la misura del cielo vero');
  });
}
