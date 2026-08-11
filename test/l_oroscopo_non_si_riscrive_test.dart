import 'package:esoteric_circle/core/astro/birth_details.dart';
import 'package:esoteric_circle/core/astro/birth_place.dart' as astro;
import 'package:esoteric_circle/core/astro/natal_chart.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/horoscope/cielo_di_oggi.dart';
import 'package:esoteric_circle/core/horoscope/horoscope.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/design_system/typography/paragrafi_di_lettura.dart';
import 'package:esoteric_circle/features/horoscope/oroscopo_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// L'OROSCOPO NON SI RISCRIVE, ordine L voce 1.
///
/// La macchina da scrivere scrive UNA VOLTA SOLA per ogni testo. Il difetto:
/// lo stato "gia' scritto" viveva negli State dei widget della scheda
/// (`_ResponsoCheSiScriveState`, `TestoCheSiScriveState`), e la lista
/// dell'Oroscopo e' una ListView che smonta gli elementi fuori dalla finestra
/// di cache: al ritorno la scheda rinasceva vergine e si riscriveva da capo.
/// Adesso il "gia' scritto" vive ACCANTO ALLA RISPOSTA, nella schermata, con
/// la chiave scheda piu' profondita' piu' giorno: chi rinasce trova il testo
/// gia' finito.
void main() {
  final carta = NatalChart(
    sunSign: Zodiac.leo,
    planets: const [
      PlanetPosition(
          id: 'sun', name: 'Sole', glyph: '☉', longitude: 128.4, sign: Zodiac.leo),
      PlanetPosition(
          id: 'moon', name: 'Luna', glyph: '☽', longitude: 12.7, sign: Zodiac.leo),
      PlanetPosition(
          id: 'venus', name: 'Venere', glyph: '♀', longitude: 150.2, sign: Zodiac.leo),
      PlanetPosition(
          id: 'mars', name: 'Marte', glyph: '♂', longitude: 61.9, sign: Zodiac.leo),
      PlanetPosition(
          id: 'saturn', name: 'Saturno', glyph: '♄', longitude: 300.5, sign: Zodiac.leo),
    ],
    ascendantLongitude: 205.0,
    midheavenLongitude: 115.0,
    houses: [
      for (var n = 1; n <= 12; n++)
        HouseCusp(number: n, longitude: (205.0 + (n - 1) * 30.0) % 360.0),
    ],
    hasTime: true,
  );
  final adesso = DateTime.utc(2026, 8, 5, 12);

  testWidgets('scorrendo giu' ' e tornando su, il testo resta intero e fermo',
      (tester) async {
    // Una finestra BASSA, cosi' lo scorrimento butta davvero le schede fuori
    // dalla cache della lista: e' la condizione del difetto.
    tester.view.physicalSize = const Size(420, 700);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final nascita = BirthIdentityController();
    nascita.setBirth(
      BirthDetails(
        date: DateTime(1990, 8, 10),
        time: const TimeOfDay(hour: 12, minute: 0),
        place: const astro.BirthPlace(
            label: 'Roma',
            latitude: 41.9,
            longitude: 12.5,
            timezone: 'Europe/Rome'),
      ),
      carta,
    );
    // Animazioni ACCESE: la macchina da scrivere e' il soggetto della prova.
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(
            create: (_) => EntitlementService(initial: Tier.tier1)),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider<BirthIdentityController>.value(value: nascita),
      ],
      child: MaterialApp(
        builder: (ctx, child) => MaestroScope(child: child!),
        home: OroscopoScreen(userSign: Zodiac.leo, now: adesso),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    await tester.tap(find.byKey(const Key('oroscopo_interroga')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    // La scrittura finisce per intero: il budget e' 2600 ms, se ne danno di
    // piu'.
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }

    // Il testo della Generale come sta a video, PRIMA dello scorrimento.
    final atteso = Horoscope.cardFor(
      sign: Zodiac.leo,
      dayOfYear: Horoscope.dayOfYear(adesso),
      year: adesso.year,
      domain: HoroscopeDomain.generale,
      cielo: CieloDiOggi.perIlGiorno(adesso: adesso, carta: carta),
      profonda: false,
    );
    final blocchi = spezzaInParagrafi(atteso.text, stile: stileDelResponso);
    for (final b in blocchi) {
      expect(find.text(b, findRichText: true), findsOneWidget,
          reason: 'Prima dello scorrimento manca un blocco della Generale: '
              'la prova non sta guardando la scena giusta.');
    }

    // GIU' fino in fondo, cosi' la Generale esce dalla cache e viene smontata.
    final lista = find.byType(Scrollable).first;
    for (var i = 0; i < 6; i++) {
      await tester.drag(lista, const Offset(0, -600));
      await tester.pump(const Duration(milliseconds: 150));
    }
    // E SU di nuovo.
    for (var i = 0; i < 6; i++) {
      await tester.drag(lista, const Offset(0, 600));
      await tester.pump(const Duration(milliseconds: 150));
    }
    // NESSUNA ATTESA LUNGA APPOSTA: il testo deve essere gia' li', intero e
    // fermo, non in riscrittura. Due fotogrammi per assestare lo scroll.
    await tester.pump(const Duration(milliseconds: 120));

    for (final b in blocchi) {
      expect(find.text(b, findRichText: true), findsOneWidget,
          reason: 'Dopo lo scorrimento e il ritorno questo blocco non e\' '
              'intero a video: la scheda e\' rinata vergine e la macchina da '
              'scrivere e\' ripartita.\n"${b.substring(0, 40)}..."');
    }
  });
}
