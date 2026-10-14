// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/synastry_approfondita/cielo_approfondito.dart';
import 'package:flutter_test/flutter_test.dart';

/// **LA SINASTRIA APPROFONDITA CONTRO UNA FONTE TERZA.** Ordine FT voce
/// FT.05: "Prova del calcolo contro una fonte terza su almeno dieci coppie,
/// con gli scarti dichiarati".
///
/// Dieci coppie, venti nascite dal 1905 al 2088. Il riferimento sono le
/// longitudini di Swiss Ephemeris (`pyswisseph`, serie Moshier), scritte da
/// `tool/riferimenti_della_sinastria_approfondita.py` in
/// `docs/collaudo/FT/riferimenti_della_sinastria_approfondita.csv`. Due cose
/// si confrontano: gli undici punti di ogni nascita, e gli aspetti di ogni
/// coppia, rifatti con la stessa regola (`AspettiApprofonditi.fra`) una
/// volta dai cieli di Meeus e una volta da quelli svizzeri.
///
/// **LO SCARTO DICHIARATO** sui punti e' un centesimo di grado: Meeus
/// contro il JPL sta sotto i quattro millesimi (Luna) e il Nodo medio sotto
/// i sei; la serie Moshier aggiunge qualche secondo d'arco. Un aspetto puo'
/// cambiare fra i due cieli solo se il riferimento lo mette a meno di un
/// centesimo dal limite del suo orbo: ogni altra differenza fa cadere la
/// prova.
void main() {
  const scartoDichiarato = 0.01;
  final righe =
      File('docs/collaudo/FT/riferimenti_della_sinastria_approfondita.csv')
          .readAsLinesSync()
          .where((r) => r.isNotEmpty && !r.startsWith('#'))
          .toList();
  final intestazione = righe.first.split(',');
  final dati = righe.skip(1).map((r) => r.split(',')).toList();

  PuntoDelCieloApprofondito punto(String nome) =>
      PuntoDelCieloApprofondito.values.firstWhere((p) => p.name == nome);

  CieloApprofondito diMeeus(List<String> r) => CieloApprofondito.perNascita(
      momentoUtc: DateTime.parse('${r[2]}Z'), nome: r[1]);

  CieloApprofondito svizzero(List<String> r) => CieloApprofondito(
        longitudini: {
          for (var i = 3; i < intestazione.length; i++)
            punto(intestazione[i]): double.parse(r[i]),
        },
        segnoSolare: Zodiac.aries,
        oraNota: true,
        giornoDiNascita: DateTime.parse(r[2]),
        nome: r[1],
      );

  double distanza(double a, double b) {
    final d = (a - b).abs() % 360;
    return d > 180 ? 360 - d : d;
  }

  test('venti nascite, undici punti: ogni scarto sotto il centesimo', () {
    expect(dati.length, 20, reason: 'dieci coppie, venti nascite');
    var peggiore = 0.0;
    var dove = '';
    for (final r in dati) {
      final m = diMeeus(r);
      final s = svizzero(r);
      for (final p in PuntoDelCieloApprofondito.values) {
        final d = distanza(m.longitudini[p]!, s.longitudini[p]!);
        if (d > peggiore) {
          peggiore = d;
          dove = '${r[2]} ${p.name}';
        }
      }
    }
    print('FT.05 SCARTO MASSIMO SUI PUNTI: '
        '${peggiore.toStringAsFixed(6)} gradi ($dove)');
    expect(peggiore, lessThan(scartoDichiarato));
  });

  test('dieci coppie: gli stessi aspetti dai due cieli', () {
    var aspetti = 0;
    var alLimite = 0;
    final diversi = <String>[];
    for (var c = 0; c < dati.length; c += 2) {
      final tuo = dati[c], suo = dati[c + 1];
      String firma(AspettoApprofondito a) =>
          '${a.tuo.name}-${a.suo.name} ${a.tipo.name}';
      final m = {
        for (final a in AspettiApprofonditi.fra(diMeeus(tuo), diMeeus(suo)))
          firma(a): a
      };
      final s = {
        for (final a in AspettiApprofonditi.fra(svizzero(tuo), svizzero(suo)))
          firma(a): a
      };
      aspetti += s.length;
      for (final k in {...m.keys, ...s.keys}) {
        if (m.containsKey(k) && s.containsKey(k)) {
          expect(
              (m[k]!.orbo - s[k]!.orbo).abs(), lessThan(2 * scartoDichiarato),
              reason: 'coppia ${tuo[0]}, $k: orbo diverso');
          continue;
        }
        final a = (m[k] ?? s[k])!;
        final limite = AspettiApprofonditi.orbo[a.tipo]!;
        if ((a.orbo - limite).abs() < 2 * scartoDichiarato) {
          alLimite++;
        } else {
          diversi.add('coppia ${tuo[0]}: $k '
              '(${m.containsKey(k) ? "solo Meeus" : "solo svizzero"})');
        }
      }
    }
    print('FT.05 ASPETTI DELLE DIECI COPPIE: $aspetti dal riferimento, '
        'diversi ${diversi.length}, al limite dell\'orbo $alLimite');
    expect(aspetti, greaterThan(100),
        reason: 'troppo pochi aspetti per dire qualcosa');
    expect(diversi, isEmpty, reason: diversi.join('\n'));
  });
}
