// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/astro/natal_chart.dart';
import 'package:esoteric_circle/core/astro/transiti_nelle_case.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/horoscope/cielo_di_oggi.dart';
import 'package:esoteric_circle/core/horoscope/corrente_del_cielo.dart';
import 'package:esoteric_circle/core/horoscope/horoscope.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/features/horoscope/la_ruota_del_passaggio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';

import 'cardinale_minimo.dart';

/// **IL CIELO CHE SI ACCENDE SULLA FRASE.** Ordine ES voce 33, 29 settembre
/// 2026.
///
/// Per ogni passaggio che una scheda nomina per primo, la ruota deve mostrare
/// lo stesso pianeta, nella stessa casa, con lo stesso aspetto al punto
/// natale: si rifanno qui la casa del pianeta di oggi sulle cuspidi della
/// carta e l'angolo fra il pianeta e il punto natale. Poi un tocco apre la
/// ruota e un altro la chiude.
void main() {
  final carta = NatalChart(
    sunSign: Zodiac.pisces,
    planets: const [
      PlanetPosition(
          id: 'sun',
          name: 'Sole',
          glyph: '☉',
          longitude: 354.4,
          sign: Zodiac.pisces),
      PlanetPosition(
          id: 'moon',
          name: 'Luna',
          glyph: '☽',
          longitude: 217.5,
          sign: Zodiac.scorpio),
      PlanetPosition(
          id: 'venus',
          name: 'Venere',
          glyph: '♀',
          longitude: 330.2,
          sign: Zodiac.pisces),
      PlanetPosition(
          id: 'mars',
          name: 'Marte',
          glyph: '♂',
          longitude: 280.9,
          sign: Zodiac.capricorn),
    ],
    ascendantLongitude: 45.5,
    midheavenLongitude: 315.0,
    houses: [
      for (var n = 1; n <= 12; n++)
        HouseCusp(number: n, longitude: (45.5 + (n - 1) * 30.0) % 360.0),
    ],
    hasTime: true,
  );

  test('la ruota mostra pianeta, casa e aspetto della frase', () {
    final diverse = <String>[];
    var guardate = 0;
    for (var g = 0; g < 20; g++) {
      final adesso = DateTime.utc(2026, 9, 20, 12).add(Duration(days: g));
      final cielo = CieloDiOggi.perIlGiorno(adesso: adesso, carta: carta);
      if (!cielo.ceCieloVero) continue;
      for (final d in HoroscopeDomain.values) {
        final v = CorrenteDelCielo.vociPer(cielo, d).firstOrNull;
        if (v == null) continue;
        guardate++;
        final oggi = LaRigaDelPassaggio.longitudineDiOggi(v, adesso);
        final natale = LaRigaDelPassaggio.longitudineNatale(v, carta);
        final casa = TransitiNelleCase.casaDi(oggi, carta.houses);
        var angolo = (oggi - (natale ?? 0)).abs() % 360;
        if (angolo > 180) angolo = 360 - angolo;
        final scarto = (angolo - v.aspetto.angoloEsatto).abs();
        if (natale == null ||
            (v.casa != null && casa != v.casa) ||
            scarto > 2.0 + 1e-6) {
          diverse.add('$adesso ${d.name}: frase "${LaRigaDelPassaggio.riga(v)}"'
              ', ruota casa $casa, angolo ${angolo.toStringAsFixed(2)}');
        }
      }
    }
    cardinaleMinimo(guardate, 20, cosa: 'passaggi guardati');
    print('ORDINE ES VOCE 33: ruote diverse dalla frase ${diverse.length} su '
        '$guardate');
    expect(diverse, isEmpty, reason: diverse.take(5).join('\n'));
  });

  testWidgets('un tocco apre la ruota, un altro la chiude', (tester) async {
    final adesso = DateTime.utc(2026, 9, 29, 12);
    final cielo = CieloDiOggi.perIlGiorno(adesso: adesso, carta: carta);
    final v = cielo.voci.first;
    await tester.pumpWidget(ChangeNotifierProvider(
        create: (_) => MaestroController(),
        child: MaterialApp(
          builder: (ctx, child) => MaestroScope(child: child!),
          home: Scaffold(
            body: SingleChildScrollView(
              child: LaRigaDelPassaggio(
                voce: v,
                carta: carta,
                adesso: adesso,
                palette:
                    MaestroPalette.forKey(const ThemeKey.of(Maestro.medora)),
              ),
            ),
          ),
        )));
    final ruota = find.byKey(const Key('oroscopo_ruota_del_passaggio'));
    expect(ruota, findsNothing);
    await tester.tap(find.byKey(const Key('oroscopo_riga_del_passaggio')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(ruota, findsOneWidget);
    await tester.tap(find.byKey(const Key('oroscopo_riga_del_passaggio')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(ruota, findsNothing);
    print('ORDINE ES VOCE 33: ${LaRigaDelPassaggio.riga(v)}');
  });
}
