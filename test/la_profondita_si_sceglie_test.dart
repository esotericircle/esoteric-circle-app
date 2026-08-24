import 'package:esoteric_circle/core/astro/birth_details.dart';
import 'package:esoteric_circle/core/astro/birth_place.dart' as astro;
import 'package:esoteric_circle/core/astro/natal_chart.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/horoscope/corrente_del_cielo.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/horoscope/answer_depth.dart';
import 'package:esoteric_circle/features/horoscope/oroscopo_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// LA PROFONDITA' SI SCEGLIE, E QUELLO CHE SI LEGGE CAMBIA.
///
/// **Una funzione venduta e non consegnata, due volte di fila.** La prima
/// volta il lucchetto restava chiuso anche a chi aveva pagato, perche'
/// `premiumUnlocked` non veniva passato da nessuno. Corretto quello, ne
/// restava un secondo, piu' silenzioso: il selettore riceveva `current` e
/// `onLockedTap` ma NON `onSelect`, quindi un abbonato apriva il menu,
/// toccava Profonda, e non succedeva niente. Non c'era nessun errore, nessun
/// avviso: la scelta semplicemente non aveva un posto dove andare.
///
/// Le prove sulla composizione non lo prendevano, perche' la composizione
/// funzionava: era il filo fra il menu e la composizione a essere staccato.
/// Questa prova guarda lo schermo.
void main() {
  // Una carta completa, altrimenti la corrente del giorno viene dalla hash e
  // la Profonda non ha fatti veri da aggiungere.
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

  Future<void> monta(WidgetTester tester,
      {required Tier piano, NatalChart? conCarta}) async {
    tester.view.physicalSize = const Size(440, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final nascita = BirthIdentityController();
    if (conCarta != null) {
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
        conCarta,
      );
    }
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => EntitlementService(initial: piano)),
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

    // **SI APRE IL CONSULTO PRIMA DI GUARDARE.** Dall'ordine 2171, voce 5,
    // l'oroscopo non si da' piu' da solo all'apertura: lo si chiede col gesto
    // Interroga il cielo. Con Riduci Movimento, che qui e' acceso, il responso
    // compare subito e per intero, quindi non c'e' nessuna attesa da simulare.
    // La prova continua a misurare la stessa cosa di prima, la profondita' che
    // cambia il testo a video: cambia solo il modo in cui quel testo arriva
    // sullo schermo.
    await tester.tap(find.byKey(const Key('oroscopo_interroga')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
  }

  /// Il testo della scheda Generale come sta a video.
  String testoDellaGenerale(WidgetTester tester) {
    final dentro = find.descendant(
      of: find.byKey(const Key('oroscopo_card_generale')),
      matching: find.byType(Text),
    );
    final testi = tester
        .widgetList<Text>(dentro)
        .map((t) => t.data)
        .whereType<String>()
        .where((s) => s.contains('casa') || s.length > 80)
        .toList();
    expect(testi, isNotEmpty,
        reason: 'a video non c\'e\' nessun testo della scheda Generale');
    return testi.join(' ');
  }

  testWidgets('Da abbonato, scegliere Profonda CAMBIA il testo a video',
      (tester) async {
    await monta(tester, piano: Tier.tier2, conCarta: carta);
    final prima = testoDellaGenerale(tester);
    expect(prima, contains('casa'),
        reason: 'il testo di partenza non viene dal cielo, quindi la Profonda '
            'non ha fatti veri da aggiungere e questa prova non misura niente');

    await tester.tap(find.byKey(const Key('oroscopo_depth_generale')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text(AnswerDepth.profonda.label), findsWidgets,
        reason: 'il menu della profondita\' non si e\' aperto');
    await tester.tap(find.text(AnswerDepth.profonda.label).last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final dopo = testoDellaGenerale(tester);
    expect(dopo, isNot(prima),
        reason: 'SI E\' SCELTO PROFONDA E A VIDEO NON E\' CAMBIATO NIENTE: la '
            'scelta non arriva alla composizione, cioe\' si paga per '
            'un\'etichetta');
    expect(dopo.length, greaterThan(prima.length),
        reason: 'la Profonda a video e\' lunga ${dopo.length} contro i '
            '${prima.length} della Breve');
  });

  testWidgets('Da Viandante la Profonda resta chiusa, e lo dice',
      (tester) async {
    await monta(tester, piano: Tier.free, conCarta: carta);
    final prima = testoDellaGenerale(tester);
    await tester.tap(find.byKey(const Key('oroscopo_depth_generale')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text(AnswerDepth.profonda.label).last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(testoDellaGenerale(tester), prima,
        reason: 'il Viandante ha letto la Profonda senza pagarla');
    // E non e' un vicolo cieco muto: c'e' l'invito.
    expect(find.textContaining('Cerchio Premium'), findsWidgets,
        reason: 'la voce bloccata non dice niente, quindi sembra rotta invece '
            'che a pagamento');
  });

  testWidgets('Senza carta natale la schermata DICHIARA il ripiego',
      (tester) async {
    await monta(tester, piano: Tier.tier2);
    expect(find.byKey(const Key('oroscopo_nota_del_cielo')), findsOneWidget,
        reason: 'la lettura viene dalla hash e la schermata non lo dice: una '
            'riga generica scritta come una vera si legge come vera');
    expect(find.textContaining('Completa i dati di nascita'), findsOneWidget);
  });

  testWidgets('Con la carta completa non c\'e\' niente da dichiarare',
      (tester) async {
    await monta(tester, piano: Tier.tier2, conCarta: carta);
    expect(find.byKey(const Key('oroscopo_nota_del_cielo')), findsNothing,
        reason: 'la nota del ripiego compare anche quando il cielo c\'e\': '
            'dichiarare una mancanza che non c\'e\' e\' dire il falso');
    expect(CorrenteDelCielo.notaDelLivello, isNotNull);
  });
}
