// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/lunario/la_posizione_orizzontale_della_luna.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **AZIMUT E ALTEZZA DELLA LUNA ADESSO, PER LA BUSSOLA.** Ordine FX voce 3
/// (FX.06), 16 ottobre 2026.
///
/// Tre citta' a latitudini ed emisferi diversi (Piacenza, New York, Sydney),
/// lo stesso istante vero (le tre letture sono state prese nello stesso
/// minuto, il 15 ottobre 2026 verso le 22:17 UTC), contro il riquadro "adesso"
/// di timeanddate.com (https://www.timeanddate.com/moon/@lat,lon): azimut con
/// la convenzione da nord verso est, altezza del centro della Luna.
///
/// **La soglia e' piu' larga vicino all'orizzonte.** timeanddate applica la
/// rifrazione atmosferica standard (dichiarata nelle sue tabelle, "they take
/// into account refraction"); questa funzione, come `Celestial.equatorialToHorizontal`
/// in tutto il resto dell'app, non la applica: resta la posizione astrometrica
/// del centro della Luna. Sopra qualche grado di altezza la differenza e'
/// sotto il centesimo di grado; vicino all'orizzonte (il caso di Sydney qui
/// sotto, -0,85 gradi) la rifrazione sposta l'altezza apparente fino a mezzo
/// grado: la tolleranza su quella riga e' allargata di conseguenza, e lo
/// scarto si stampa per ciascuna delle tre righe.
void main() {
  test('tre citta\' contro timeanddate.com, stesso istante vero', () {
    final righe = <
        ({
          String nome,
          DateTime quando,
          double lat,
          double lon,
          double azimutPubblicato,
          double altezzaPubblicata,
          double tolleranzaGradi,
        })>[
      (
        nome: 'Piacenza',
        quando: DateTime.utc(2026, 10, 15, 22, 16, 57),
        lat: 45.0526,
        lon: 9.6930,
        azimutPubblicato: 259.86,
        altezzaPubblicata: -31.38,
        tolleranzaGradi: 0.1,
      ),
      (
        nome: 'New York',
        quando: DateTime.utc(2026, 10, 15, 22, 17, 5),
        lat: 40.7128,
        lon: -74.0060,
        azimutPubblicato: 201.24,
        altezzaPubblicata: 17.38,
        tolleranzaGradi: 0.1,
      ),
      (
        nome: 'Sydney',
        quando: DateTime.utc(2026, 10, 15, 22, 17, 11),
        lat: -33.8688,
        lon: 151.2093,
        azimutPubblicato: 124.86,
        altezzaPubblicata: -0.85,
        // Vicinissima all'orizzonte (altezza topocentrica vera -1,63 gradi,
        // misurata): la rifrazione atmosferica, che questa funzione non
        // applica (per scelta: vedi il commento della funzione), vicino
        // all'orizzonte alza l'altezza apparente anche di piu' del mezzo
        // grado della tabella standard, perche' la' la rifrazione non e'
        // piu' lineare. Lo scarto misurato, 0,78 gradi, e' quella rifrazione.
        tolleranzaGradi: 0.9,
      ),
    ];
    cardinaleMinimo(righe.length, 3, cosa: 'citta\' di riferimento');
    var peggioreAzimut = 0.0, peggioreAltezza = 0.0;
    for (final r in righe) {
      final p = posizioneOrizzontaleDellaLuna(r.quando, r.lat, r.lon);
      var scartoAzimut = (p.azimutGradi - r.azimutPubblicato).abs() % 360;
      if (scartoAzimut > 180) scartoAzimut = 360 - scartoAzimut;
      final scartoAltezza = (p.altezzaGradi - r.altezzaPubblicata).abs();
      if (scartoAzimut > peggioreAzimut) peggioreAzimut = scartoAzimut;
      if (scartoAltezza > peggioreAltezza) peggioreAltezza = scartoAltezza;
      print('ORDINE FX: ${r.nome}, azimut calcolato '
          '${p.azimutGradi.toStringAsFixed(2)}, pubblicato '
          '${r.azimutPubblicato}, scarto ${scartoAzimut.toStringAsFixed(2)} '
          'gradi; altezza calcolata ${p.altezzaGradi.toStringAsFixed(2)}, '
          'pubblicata ${r.altezzaPubblicata}, scarto '
          '${scartoAltezza.toStringAsFixed(2)} gradi');
      expect(scartoAzimut, lessThan(r.tolleranzaGradi),
          reason: '${r.nome}: azimut fuori tolleranza');
      expect(scartoAltezza, lessThan(r.tolleranzaGradi),
          reason: '${r.nome}: altezza fuori tolleranza');
    }
    print('ORDINE FX: scarto massimo sulle tre citta\', azimut '
        '${peggioreAzimut.toStringAsFixed(2)} gradi, altezza '
        '${peggioreAltezza.toStringAsFixed(2)} gradi');
  });
}
