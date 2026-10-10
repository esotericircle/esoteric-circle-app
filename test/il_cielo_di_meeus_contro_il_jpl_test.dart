import 'dart:io';

import 'package:esoteric_circle/core/astro/meeus/il_cielo_di_meeus.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// IL CIELO DI MEEUS CONTRO IL JPL. Ordine FD voce 02.
///
/// La fonte terza e' il JPL DE440s letto con skyfield
/// (`tool/riferimenti_del_cielo_jpl.py`): sessanta istanti fra il 1900 e il
/// 2099, piu' dodici fra il 1 gennaio 2100 e il 1 gennaio 2101 alle 12 UT
/// (aggiunta della Macchina del tempo all'ordine FH), la longitudine eclittica apparente della data dei dieci corpi e la
/// latitudine della Luna, in `docs/collaudo/FD/riferimenti_del_cielo.csv`.
///
/// Si misura la PORTA, `IlCieloDiMeeus`, e non i motori dietro: e' la porta
/// che l'app chiama.
///
/// **Due soglie per corpo.** La prima e' lo scarto che la porta dichiara in
/// [IlCieloDiMeeus.scartoMisurato]: se il motore peggiora, la dichiarazione
/// mente, e la prova cade. La seconda e' l'errore che decide un segno, un
/// centesimo di grado per il Sole e i pianeti e un quarantesimo per la Luna
/// (0,025 gradi, la soglia gia' dichiarata del capitolo 47).
void main() {
  final righe = File('docs/collaudo/FD/riferimenti_del_cielo.csv')
      .readAsLinesSync()
      .where((r) => r.isNotEmpty && !r.startsWith('#'))
      .toList();
  final intestazione = righe.first.split(',');
  final dati = righe
      .skip(1)
      .map((r) => r.split(',').map(double.parse).toList())
      .toList();

  double scarto(double a, double b) => ((a - b + 540) % 360 - 180).abs();

  test('ogni corpo sta entro lo scarto dichiarato dalla porta', () {
    final peggio = <CorpoCeleste, double>{};
    var misure = 0;
    for (final d in dati) {
      for (final corpo in CorpoCeleste.values) {
        final c = intestazione.indexOf(corpo.name);
        expect(c, greaterThan(0), reason: '${corpo.name} non ha riferimento');
        final e = scarto(IlCieloDiMeeus.longitudine(corpo, d[0]), d[c]);
        misure++;
        if (e > (peggio[corpo] ?? 0)) peggio[corpo] = e;
      }
    }
    cardinaleMinimo(misure, 600, cosa: 'misure contro il JPL');
    // ignore: avoid_print
    print('ORDINE FD VOCE 02, scarto massimo dal JPL in secondi d\'arco: '
        '${peggio.map((k, v) => MapEntry(k.name, (v * 3600).toStringAsFixed(1)))}');
    for (final e in peggio.entries) {
      expect(e.value, lessThanOrEqualTo(IlCieloDiMeeus.scartoMisurato[e.key]!),
          reason: '${e.key.name}: scarto ${e.value} oltre il dichiarato');
      expect(e.value, lessThan(e.key == CorpoCeleste.luna ? 0.025 : 0.01),
          reason: '${e.key.name}: scarto ${e.value} gradi');
    }
  });

  test('la latitudine della Luna sta entro un centesimo di grado', () {
    final c = intestazione.indexOf('luna_latitudine');
    var peggio = 0.0;
    for (final d in dati) {
      final e = (IlCieloDiMeeus.latitudineDellaLuna(d[0]) - d[c]).abs();
      if (e > peggio) peggio = e;
    }
    // ignore: avoid_print
    print('ORDINE FD VOCE 02, latitudine della Luna, scarto massimo '
        '${(peggio * 3600).toStringAsFixed(1)} secondi d\'arco');
    expect(peggio, lessThan(0.01));
  });

  // Ordine FG parte 2: la latitudine dei pianeti, nuova nella porta. La fonte
  // terza e' l'esempio 33.a di Meeus (Astronomical Algorithms, seconda
  // edizione): Venere il 20 dicembre 1992 a 0h TD, latitudine apparente
  // -2,08474 gradi. La porta da' la geometrica col tempo di luce, che
  // dall'apparente differisce per l'aberrazione, sotto il secondo d'arco;
  // la differenza fra 0h TD e 0h UT (circa 59 secondi) sposta Venere di
  // meno di un decimillesimo di grado.
  test('la latitudine di Venere e\' quella dell\'esempio 33.a di Meeus', () {
    final beta = IlCieloDiMeeus.latitudine(CorpoCeleste.venere, 2448976.5);
    expect((beta - -2.08474).abs(), lessThan(0.0005), reason: 'beta $beta');
    expect(IlCieloDiMeeus.latitudine(CorpoCeleste.sole, 2448976.5), 0.0);
    expect(IlCieloDiMeeus.latitudine(CorpoCeleste.luna, 2448976.5),
        IlCieloDiMeeus.latitudineDellaLuna(2448976.5));
  });

  test('c) fuori dall\'intervallo verificato la chiamata non gira', () {
    const prima = IlCieloDiMeeus.primoGiornoVerificato - 1;
    const dopo = IlCieloDiMeeus.ultimoGiornoVerificato;
    for (final jd in [prima, dopo]) {
      for (final corpo in CorpoCeleste.values) {
        expect(() => IlCieloDiMeeus.longitudine(corpo, jd),
            throwsA(isA<FuoriDalCieloVerificato>()),
            reason: '${corpo.name} al giorno $jd ha risposto un numero');
      }
      expect(() => IlCieloDiMeeus.latitudineDellaLuna(jd),
          throwsA(isA<FuoriDalCieloVerificato>()));
      expect(() => IlCieloDiMeeus.ascendente(jd, 45, 9),
          throwsA(isA<FuoriDalCieloVerificato>()));
    }
    // Dentro, ai due estremi, risponde.
    expect(
        IlCieloDiMeeus.longitudine(
            CorpoCeleste.sole, IlCieloDiMeeus.primoGiornoVerificato),
        isA<double>());
    expect(IlCieloDiMeeus.istanteVerificato(DateTime.utc(1899, 12, 30, 23)),
        isFalse);
    // Lapide: fino all'aggiunta della Macchina del tempo all'ordine FH la
    // finestra finiva il 1 gennaio 2100 alle 0 UT, e il 2100 era fuori. Ora
    // arriva al 31 dicembre 2100 di ogni fuso, cioe' fino al 1 gennaio 2101
    // alle 12 UT, misurata contro il JPL.
    expect(IlCieloDiMeeus.istanteVerificato(DateTime.utc(2099, 12, 31, 23)),
        isTrue);
    expect(IlCieloDiMeeus.istanteVerificato(DateTime.utc(2100, 12, 31, 23)),
        isTrue);
    expect(
        IlCieloDiMeeus.istanteVerificato(DateTime.utc(2101, 1, 1, 11)), isTrue);
    expect(IlCieloDiMeeus.istanteVerificato(DateTime.utc(2101, 1, 1, 12)),
        isFalse);
  });
}
