import 'package:esoteric_circle/core/astro/birth_details.dart';
import 'package:esoteric_circle/core/astro/birth_place.dart';
import 'package:esoteric_circle/core/astro/natal_chart.dart';
import 'package:esoteric_circle/core/astro/natal_chart_controller.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/passport/specchio_dei_dati.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// LO SPECCHIO DEI DATI DICE IL VERO, in tutti e quattro i casi.
///
/// Ordine 2169, voce 8. **Non possiamo ispezionare l'iPhone di una
/// fondatrice.** Serviva un punto nell'app che dica in chiaro cosa risulta
/// memorizzato: senza, ogni prossima segnalazione e' un'altra caccia al buio.
///
/// Uno specchio che mente e' peggio di nessuno specchio, perche' chiude la
/// strada anche a chi stava guardando nel posto giusto. Queste prove misurano
/// che dica il vero nei casi che contano, compreso quello che ha originato
/// tutto: data e ora ci sono, il luogo no.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  final completa = BirthDetails(
    date: DateTime(1975, 7, 6),
    time: const TimeOfDay(hour: 9, minute: 30),
    place: const BirthPlace(
      latitude: 45.07,
      longitude: 7.69,
      timezone: 'Europe/Rome',
      label: 'Torino',
    ),
  );

  final senzaLuogo = BirthDetails(
    date: DateTime(1975, 7, 6),
    time: const TimeOfDay(hour: 9, minute: 30),
  );

  NatalChart cartaVera() => const NatalChart(
        sunSign: Zodiac.cancer,
        moonSign: Zodiac.pisces,
        ascendant: Zodiac.leo,
        ascendantLongitude: 130.0,
        hasTime: true,
        planets: [
          PlanetPosition(
              id: 'sun',
              name: 'Sole',
              glyph: '☉',
              longitude: 104.0,
              sign: Zodiac.cancer),
        ],
      );

  Future<void> apri(
    WidgetTester tester, {
    required BirthDetails? dettagli,
    NatalChart? carta,
  }) async {
    final porta = BirthIdentityController();
    if (dettagli != null) porta.setBirth(dettagli, carta);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider(create: (_) => NatalChartController()),
        ChangeNotifierProvider<BirthIdentityController>.value(value: porta),
      ],
      child: MaterialApp(
        home: MaestroScope(
          child: const Scaffold(body: SpecchioDeiDati()),
        ),
      ),
    ));
    await tester.pump();
  }

  String riga(WidgetTester tester, String chiave) {
    final testi = find
        .descendant(
            of: find.byKey(Key('specchio_$chiave')), matching: find.byType(Text))
        .evaluate()
        .map((e) => (e.widget as Text).data)
        .whereType<String>()
        .toList();
    return testi.join(' | ');
  }

  testWidgets('con tutto al suo posto, lo specchio lo conferma',
      (tester) async {
    await apri(tester, dettagli: completa, carta: cartaVera());

    expect(riga(tester, 'data'), contains('6/7/1975'));
    expect(riga(tester, 'ora'), contains('09:30'));
    expect(riga(tester, 'luogo'), contains('Torino'));
    expect(riga(tester, 'cielo'), contains('Completo'));
    // ignore: avoid_print
    print('SPECCHIO pieno: ${riga(tester, 'luogo')} / '
        '${riga(tester, 'cielo')}');
    expect(find.byKey(const Key('specchio_completa_luogo')), findsNothing,
        reason: 'si offre di aggiungere un luogo che c\'e\' gia\'');
  });

  testWidgets('SENZA il luogo lo dice, e offre di darlo', (tester) async {
    // **E' il caso della fondatrice.** Data e ora ci sono, il luogo no, e
    // lei era convinta di averlo dato: da nessuna parte l'app le diceva il
    // contrario.
    await apri(tester, dettagli: senzaLuogo);

    final luogo = riga(tester, 'luogo');
    // ignore: avoid_print
    print('SPECCHIO senza luogo: $luogo');
    expect(luogo.toLowerCase(), contains('non l\'hai dato'),
        reason: 'lo specchio non dichiara che il luogo manca: e\' l\'unica '
            'cosa per cui esiste');
    expect(luogo, contains('Ascendente'),
        reason: 'non si dice cosa si perde: "manca un dato" non aiuta '
            'nessuno a decidere se valga la pena darlo');
    expect(find.byKey(const Key('specchio_completa_luogo')), findsOneWidget,
        reason: 'si dichiara la mancanza senza offrire il modo di colmarla');
  });

  testWidgets('col RIPIEGO in mano, lo specchio non lo chiama cielo completo',
      (tester) async {
    await apri(tester,
        dettagli: completa,
        carta: NatalChart.essential(sunSign: Zodiac.cancer, hasTime: true));

    final cielo = riga(tester, 'cielo');
    // ignore: avoid_print
    print('SPECCHIO col ripiego: $cielo');
    expect(cielo, contains('Essenziale'),
        reason: 'lo specchio dichiara completo un cielo che ha un astro solo: '
            'e\' esattamente la bugia che ha reso invisibile il problema per '
            'mesi');
    expect(cielo.contains('Completo'), isFalse);
  });

  testWidgets('senza NESSUNA carta, non dice ne\' completo ne\' essenziale',
      (tester) async {
    // Tre stati, non due: chi non ha ancora un cielo non ha un ripiego, ha
    // un cielo che nessuno ha tracciato.
    await apri(tester, dettagli: completa);

    final cielo = riga(tester, 'cielo');
    // ignore: avoid_print
    print('SPECCHIO senza carta: $cielo');
    expect(cielo, contains('Non ancora tracciato'));
  });

  testWidgets('senza nessun dato lo specchio non inventa', (tester) async {
    await apri(tester, dettagli: null);

    expect(riga(tester, 'data').toLowerCase(), contains('non l\'hai'),
        reason: 'con la porta vuota lo specchio mostra una data che nessuno '
            'ha dato');
    expect(riga(tester, 'ora').toLowerCase(), contains('non l\'hai'));
    expect(riga(tester, 'luogo').toLowerCase(), contains('non l\'hai'));
  });
}
