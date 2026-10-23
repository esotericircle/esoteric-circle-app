// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/lunario/il_sorgere_della_luna.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **IL SORGERE, IL TRAMONTO E LA CULMINAZIONE DELLA LUNA.** Ordine FX voce
/// 2, 16 ottobre 2026.
///
/// Tre citta' a latitudini ed emisferi diversi (Piacenza, nell'emisfero nord
/// a media latitudine; New York, nell'emisfero nord; Sydney, nell'emisfero
/// sud), tutte per il 16 ottobre 2026, contro due fonti ufficiali
/// indipendenti dal calcolo che si verifica: l'API dell'US Naval Observatory
/// (https://aa.usno.navy.mil/api/rstt/oneday) e la tabella mensile di
/// timeanddate.com (https://www.timeanddate.com/moon/@lat,lon), che
/// concordano al minuto.
void main() {
  test('sorgere, tramonto e culminazione contro USNO e timeanddate.com', () {
    final righe = <
        ({
          String nome,
          double lat,
          double lon,
          DateTime rise,
          DateTime set,
          DateTime culmine,
        })>[
      (
        nome: 'Piacenza',
        lat: 45.0526,
        lon: 9.6930,
        rise: DateTime.utc(2026, 10, 16, 11, 46),
        set: DateTime.utc(2026, 10, 16, 19, 48),
        culmine: DateTime.utc(2026, 10, 16, 15, 46),
      ),
      (
        nome: 'New York',
        lat: 40.7128,
        lon: -74.0060,
        rise: DateTime.utc(2026, 10, 16, 17, 12),
        set: DateTime.utc(2026, 10, 17, 1, 56),
        culmine: DateTime.utc(2026, 10, 16, 21, 33),
      ),
      (
        nome: 'Sydney',
        lat: -33.8688,
        lon: 151.2093,
        rise: DateTime.utc(2026, 10, 15, 22, 22),
        set: DateTime.utc(2026, 10, 16, 13, 38),
        culmine: DateTime.utc(2026, 10, 16, 6, 0),
      ),
    ];
    cardinaleMinimo(righe.length, 3, cosa: 'citta\' di riferimento');
    var peggiore = 0;
    for (final r in righe) {
      final sorgere = prossimoSorgere(_treOrePrima(r.rise), r.lat, r.lon)!;
      final scartoSorgere = sorgere.difference(r.rise).inSeconds.abs() / 60.0;

      final tramonto = prossimoTramonto(_treOrePrima(r.set), r.lat, r.lon)!;
      final scartoTramonto = tramonto.difference(r.set).inSeconds.abs() / 60.0;

      final culminazione =
          prossimaCulminazione(_treOrePrima(r.culmine), r.lat, r.lon)!;
      final scartoCulminazione =
          culminazione.difference(r.culmine).inSeconds.abs() / 60.0;

      final peggioreDiQuesta = [scartoSorgere, scartoTramonto, scartoCulminazione]
          .reduce((a, b) => a > b ? a : b)
          .ceil();
      if (peggioreDiQuesta > peggiore) peggiore = peggioreDiQuesta;

      print('ORDINE FX: ${r.nome}, sorgere calcolato $sorgere, pubblicato '
          '${r.rise}, scarto ${scartoSorgere.toStringAsFixed(1)} minuti; '
          'tramonto calcolato $tramonto, pubblicato ${r.set}, scarto '
          '${scartoTramonto.toStringAsFixed(1)} minuti; culminazione '
          'calcolata $culminazione, pubblicata ${r.culmine}, scarto '
          '${scartoCulminazione.toStringAsFixed(1)} minuti');

      // Un minuto di soglia: la ricerca affina al minuto (il passo fine di
      // `primoIstanteSopraInFinestra`), e le due fonti pubblicate concordano
      // fra loro al minuto.
      expect(scartoSorgere, lessThan(2.0), reason: '${r.nome}: sorgere');
      expect(scartoTramonto, lessThan(2.0), reason: '${r.nome}: tramonto');
      expect(scartoCulminazione, lessThan(2.0),
          reason: '${r.nome}: culminazione');
    }
    print('ORDINE FX: scarto massimo sulle tre citta\' $peggiore minuti');
  });
}

/// Tre ore prima di [evento]: abbastanza presto perche' la ricerca non parta
/// gia' dentro l'evento, abbastanza vicino perche' resti dentro la finestra
/// di ventisette ore.
DateTime _treOrePrima(DateTime evento) =>
    evento.subtract(const Duration(hours: 3));
