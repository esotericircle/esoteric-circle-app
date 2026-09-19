import 'package:esoteric_circle/core/astro/aspetti_di_oggi.dart';
import 'package:esoteric_circle/core/astro/birth_details.dart';
import 'package:esoteric_circle/core/astro/birth_place.dart' as astro;
import 'package:esoteric_circle/core/astro/natal_chart.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/horoscope/cielo_di_oggi.dart';
import 'package:esoteric_circle/core/horoscope/corrente_del_cielo.dart';
import 'package:esoteric_circle/core/horoscope/horoscope.dart';
import 'package:esoteric_circle/core/horoscope/riflessione_del_cielo.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/account/dati_di_nascita_screen.dart';
import 'package:esoteric_circle/features/horoscope/oroscopo_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// IL RIPIEGO DEL CIELO NON E' UN VICOLO CIECO. Ordine CS, voce S1.
///
/// **Il difetto.** Sotto il responso dell'Oroscopo, a chi non ha la carta
/// natale completa comparivano le parole "Completa i dati di nascita", e li'
/// finiva. La schermata che accoglie quei dati esiste da sempre, e ci si
/// arriva dal Calendario e dall'Account, ma da sotto il responso no: il
/// ripiego diceva cosa manca senza dare il gesto per colmarlo.
///
/// **Cio' che si misura qui non e' il testo, e' l'arrivo.** Una prova che
/// cercasse l'etichetta sarebbe verde anche con un pulsante che non porta da
/// nessuna parte. Queste prove toccano e guardano su quale schermata si sono
/// trovate dopo.
void main() {
  const pianeti = [
    PlanetPosition(
        id: 'sun',
        name: 'Sole',
        glyph: 'O',
        longitude: 128.4,
        sign: Zodiac.leo),
    PlanetPosition(
        id: 'moon',
        name: 'Luna',
        glyph: 'D',
        longitude: 12.7,
        sign: Zodiac.leo),
    PlanetPosition(
        id: 'venus',
        name: 'Venere',
        glyph: 'V',
        longitude: 44.2,
        sign: Zodiac.leo),
    PlanetPosition(
        id: 'mars',
        name: 'Marte',
        glyph: 'M',
        longitude: 61.9,
        sign: Zodiac.leo),
    PlanetPosition(
        id: 'saturn',
        name: 'Saturno',
        glyph: 'S',
        longitude: 300.5,
        sign: Zodiac.leo),
  ];

  final completa = NatalChart(
    sunSign: Zodiac.leo,
    planets: pianeti,
    ascendantLongitude: 205.0,
    midheavenLongitude: 115.0,
    houses: [
      for (var n = 1; n <= 12; n++)
        HouseCusp(number: n, longitude: (205.0 + (n - 1) * 30.0) % 360.0),
    ],
    hasTime: true,
  );

  /// La carta di chi ha detto "l'ora non la so": i pianeti ci sono, le case
  /// no, perche' senza ora non si possono calcolare.
  const senzaOra = NatalChart(
    sunSign: Zodiac.leo,
    planets: pianeti,
    hasTime: false,
  );

  Future<void> monta(WidgetTester tester, {NatalChart? conCarta}) async {
    tester.view.physicalSize = const Size(440, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final nascita = BirthIdentityController();
    if (conCarta != null) {
      nascita.setBirth(
        BirthDetails(
          date: DateTime(1990, 8, 10),
          time:
              conCarta.hasTime ? const TimeOfDay(hour: 12, minute: 0) : null,
          place: const astro.BirthPlace(
              label: 'Roma',
              latitude: 41.9,
              longitude: 12.5,
              timezone: 'Europe/Rome'),
        ),
        conCarta,
      );
    }
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(
            create: (_) => EntitlementService(initial: Tier.tier2)),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider<BirthIdentityController>.value(value: nascita),
      ],
      child: MaterialApp(
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
          child: MaestroScope(child: child!),
        ),
        home: OroscopoScreen(
            userSign: Zodiac.leo, now: DateTime.utc(2026, 8, 5, 12)),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.tap(find.byKey(const Key('oroscopo_interroga')));
    await tester.pump();
    await tester.pump(RiflessioneDelCielo.finoAllUltimaScheda(
        HoroscopeDomain.values.length,
        piena: true));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(milliseconds: 600));
  }

  final porta = find.byKey(const Key('oroscopo_completa_la_nascita'));

  CieloDiOggi cieloDi(NatalChart? carta) => CieloDiOggi.perIlGiorno(
      adesso: DateTime.utc(2026, 8, 5, 12), carta: carta);

  testWidgets('Senza carta natale il ripiego porta ai dati di nascita',
      (tester) async {
    await monta(tester);
    expect(find.byKey(const Key('oroscopo_nota_del_cielo')), findsOneWidget,
        reason: 'senza carta la nota del ripiego non compare affatto, quindi '
            'la lettura al segno si legge come lettura al cielo');
    expect(porta, findsOneWidget,
        reason: 'la nota dice cosa manca e non da\' il gesto per colmarlo: '
            'e\' un vicolo cieco con le buone maniere');

    await tester.ensureVisible(porta);
    await tester.tap(porta);
    await tester.pumpAndSettle();
    expect(find.byType(DatiDiNascitaScreen), findsOneWidget,
        reason: 'la porta si tocca e non porta ai dati di nascita: un '
            'pulsante che non arriva da nessuna parte e\' peggio '
            'dell\'assenza del pulsante');
  });

  testWidgets('A chi manca solo l\'ora si chiede solo l\'ora', (tester) async {
    await monta(tester, conCarta: senzaOra);
    expect(porta, findsOneWidget,
        reason: 'chi ha dato luogo e data ma non l\'ora resta senza porta');

    final etichetta = tester.widget<Text>(
        find.descendant(of: porta, matching: find.byType(Text)));
    final testoDellaPorta = etichetta.data ?? '';
    final invitoPieno = CorrenteDelCielo.invitoDelLivello(cieloDi(null));
    expect(testoDellaPorta, isNot(invitoPieno),
        reason: 'a chi ha gia\' dato luogo e data si richiede tutto da capo: '
            'l\'invito e\' lo stesso di chi non ha dato niente');
    expect(testoDellaPorta.toLowerCase(), contains('ora'),
        reason: 'l\'invito di chi ha la carta senza ora non nomina l\'ora, '
            'cioe\' non dice cosa manca davvero');

    await tester.ensureVisible(porta);
    await tester.tap(porta);
    await tester.pumpAndSettle();
    expect(find.byType(DatiDiNascitaScreen), findsOneWidget,
        reason: 'la porta di chi non ha l\'ora non arriva ai dati di nascita');
  });

  testWidgets('Con la carta completa non c\'e\' nessuna porta da offrire',
      (tester) async {
    await monta(tester, conCarta: completa);
    expect(porta, findsNothing,
        reason: 'a cielo completo si invita comunque a completare qualcosa, '
            'cioe\' si dichiara una mancanza che non esiste');
    expect(CorrenteDelCielo.invitoDelLivello(cieloDi(completa)), isNull,
        reason: 'il livello completo produce un invito');
  });

  test('I tre livelli hanno tre inviti, e uno solo e\' nullo', () {
    final inviti = <LivelloPersonalizzazione, String?>{
      for (final carta in <NatalChart?>[null, senzaOra, completa])
        AspettiDiOggi.livello(carta):
            CorrenteDelCielo.invitoDelLivello(cieloDi(carta)),
    };
    expect(inviti.length, LivelloPersonalizzazione.values.length,
        reason: 'le tre carte di prova non coprono i tre livelli, quindi '
            'questa prova sta misurando meno di quel che dichiara');
    final detti = inviti.values.whereType<String>().toList();
    expect(detti.length, 2,
        reason: 'gli inviti non nulli sono ${detti.length} invece di due');
    expect(detti.toSet().length, 2,
        reason: 'i due livelli incompleti mostrano lo stesso invito, quindi '
            'l\'etichetta non dice cosa manca a chi la legge');
  });
}
