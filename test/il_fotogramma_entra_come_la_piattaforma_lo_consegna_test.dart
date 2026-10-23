import 'package:esoteric_circle/core/face/ingresso_del_fotogramma.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// **IL FOTOGRAMMA ENTRA COME LA PIATTAFORMA LO CONSEGNA.** Ordine DS voce 06.
///
/// Su iPhone la Costellazione del Viso non rilevava nessun volto: formato,
/// rotazione e specchio erano quelli di Android per tutti. Questa prova tiene
/// ferme **tutte e due** le strade: quella nuova di iOS, e quella di Android
/// identica a com'era prima dell'ordine, perche' li' la funzione andava.
void main() {
  test('iOS: BGRA, la rotazione del dispositivo, nessuno specchio', () {
    final ios = IngressoDelFotogramma.per(TargetPlatform.iOS);
    expect(ios.formato, FormatoDelFotogramma.bgra,
        reason: 'su iOS la fotocamera consegna BGRA: leggerlo come NV21 non '
            'trova nessun volto');
    // Il sensore frontale di un iPhone dichiara novanta gradi: se arrivasse
    // al modello, il volto gia' in piedi girerebbe di lato.
    expect(
        ios.rotazione(sensore: 90, dispositivo: DeviceOrientation.portraitUp),
        0,
        reason: 'su iOS il plugin gira gia il fotogramma come il dispositivo');
    expect(
        ios.rotazione(
            sensore: 90, dispositivo: DeviceOrientation.landscapeLeft),
        90);
    expect(ios.specchiata(frontale: true), isFalse,
        reason: 'su iOS la frontale e gia specchiata dal plugin: '
            'specchiarla ancora la raddrizza al contrario');
  });

  test(
      'Android: NV21, la rotazione del sensore, la frontale specchiata, '
      'come prima dell\'ordine DS', () {
    final android = IngressoDelFotogramma.per(TargetPlatform.android);
    expect(android.formato, FormatoDelFotogramma.nv21);
    for (final dispositivo in DeviceOrientation.values) {
      expect(android.rotazione(sensore: 270, dispositivo: dispositivo), 270,
          reason: 'su Android la rotazione e sempre stata quella del sensore, '
              'e li la funzione rilevava: non deve cambiare');
    }
    expect(android.specchiata(frontale: true), isTrue);
    expect(android.specchiata(frontale: false), isFalse);
  });
}
