// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/astro/birth_details.dart';
import 'package:esoteric_circle/core/astro/birth_place.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/horoscope/astro_tradition.dart';
import 'package:esoteric_circle/core/horoscope/horoscope.dart';
import 'package:esoteric_circle/core/horoscope/i_segni_delle_tradizioni.dart';
import 'package:esoteric_circle/core/horoscope/i_tre_cieli.dart';
import 'package:esoteric_circle/core/horoscope/il_sigillo_dei_tre_cieli.dart';
import 'package:esoteric_circle/core/horoscope/la_lettura_cinese.dart';
import 'package:esoteric_circle/core/horoscope/la_lettura_vedica.dart';
import 'package:esoteric_circle/core/horoscope/riflessione_del_cielo.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/horoscope/oroscopo_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cardinale_minimo.dart';

/// **TRE TRADIZIONI SU TRE, IL SIGILLO DEI TRE CIELI E LA RIVELAZIONE DEL
/// SEGNO. Ordine ES voci 36, 37 e 35, 29 settembre 2026.**
///
/// Le righe dell'Architetto, approvate dal fondatore con l'ordine:
/// *"Quando occidentale, cinese e vedica danno lo stesso esito su un dominio,
/// lo si dice: "Oggi tre tradizioni su tre vedono il lavoro favorevole". Se
/// non sono d'accordo, si dice anche questo."*; *"un Sigillo "Tre Cieli" per
/// chi legge tutte e tre le tradizioni nello stesso giorno."*; *"La prima
/// volta che la persona sceglie Cinese o Vedica, la figura in bronzo appare
/// con la sua animazione e la frase "Il tuo segno cinese è il Cavallo". È il
/// momento da condividere."*
void main() {
  HoroscopeCard scheda(HoroscopeDomain d, int livello) => HoroscopeCard(
      domain: d, title: d.label, text: 'x', synthesis: 'x', indicator: livello);
  List<HoroscopeCard> tutte(int livello, {int? lavoro}) => [
        for (final d in HoroscopeDomain.values)
          scheda(
              d,
              d == HoroscopeDomain.carriera && lavoro != null
                  ? lavoro
                  : livello),
      ];

  test('la regola: l\'esito dal livello, e le due frasi', () {
    // La soglia scritta a mano, non letta dal codice.
    for (final (livello, atteso) in const [
      (5, 'favorevole'),
      (4, 'favorevole'),
      (3, 'in equilibrio'),
      (2, 'in salita'),
    ]) {
      expect(EsitoDelCielo.di(livello).parola, atteso);
    }
    final accordo =
        ITreCieli.di(occidentale: tutte(4), cinese: tutte(5), vedica: tutte(4));
    expect(accordo, hasLength(4));
    expect(
        accordo.firstWhere((a) => a.dominio == HoroscopeDomain.carriera).frase,
        'Oggi tre tradizioni su tre vedono il lavoro favorevole.');
    expect(accordo.first.frase,
        'Oggi tre tradizioni su tre vedono la giornata favorevole.');
    final disaccordo = ITreCieli.di(
        occidentale: tutte(4, lavoro: 5),
        cinese: tutte(4, lavoro: 4),
        vedica: tutte(4, lavoro: 2));
    expect(
        disaccordo
            .firstWhere((a) => a.dominio == HoroscopeDomain.carriera)
            .frase,
        'Sul lavoro le tre tradizioni non sono d\'accordo: favorevole per '
        'l\'occidentale e la cinese, in salita per la vedica.');
    final treModi = ITreCieli.di(
        occidentale: tutte(3, lavoro: 5),
        cinese: tutte(3, lavoro: 3),
        vedica: tutte(3, lavoro: 2));
    expect(
        treModi.firstWhere((a) => a.dominio == HoroscopeDomain.carriera).frase,
        'Sul lavoro le tre tradizioni non sono d\'accordo: favorevole per '
        'l\'occidentale, in equilibrio per la cinese, in salita per la '
        'vedica.');
    // Senza una delle tre letture non si dice "tre su tre".
    expect(ITreCieli.di(occidentale: tutte(4), cinese: null, vedica: tutte(4)),
        isEmpty);
  });

  test('sessanta giorni veri: l\'accordo e il disaccordo tutti e due', () {
    final nascita = NascitaDeiSegni(
        locale: DateTime(1990, 3, 15, 8, 30),
        oraNota: true,
        fuso: 'Europe/Rome');
    const roma = LuogoDelGiorno(lat: 41.9, lon: 12.5, citta: 'Roma');
    final animale =
        ISegniDelleTradizioni.per(AstroTradition.cinese, nascita).animale!;
    var concordi = 0;
    var discordi = 0;
    final sbagliati = <String>[];
    for (var g = 0; g < 60; g++) {
      final giorno = DateTime(2026, 9, 1 + g);
      final o = Horoscope.forSign(
          sign: Zodiac.pisces,
          dayOfYear: Horoscope.dayOfYear(giorno),
          year: giorno.year);
      final c = LaLetturaCinese.schede(
          oggi: giorno,
          nascita: nascita.locale,
          animale: animale,
          forma: CourtesyForm.unknown)!;
      final v = LaLetturaVedica.schede(
          adesso: giorno,
          nascita: nascita,
          luogo: roma,
          forma: CourtesyForm.unknown)!;
      final accordi = ITreCieli.di(occidentale: o, cinese: c, vedica: v);
      for (final a in accordi) {
        String atteso(List<HoroscopeCard> s) {
          final l = s.firstWhere((x) => x.domain == a.dominio).indicator;
          return l >= 4
              ? 'favorevole'
              : (l == 3 ? 'in equilibrio' : 'in salita');
        }

        final tre = [atteso(o), atteso(c), atteso(v)];
        final lette = [
          for (final t in ITreCieli.tradizioni) a.esiti[t]!.parola,
        ];
        if (tre.join() != lette.join()) {
          sbagliati.add('$giorno ${a.dominio.name}: $lette invece di $tre');
        }
        final uguali = tre.toSet().length == 1;
        if (uguali != a.frase.startsWith('Oggi tre tradizioni su tre')) {
          sbagliati.add('$giorno ${a.dominio.name}: "${a.frase}" con $tre');
        }
        uguali ? concordi++ : discordi++;
      }
    }
    print('ORDINE ES VOCE 36: in sessanta giorni, domini in cui le tre '
        'tradizioni concordano $concordi, discordano $discordi; esiti o '
        'frasi sbagliati ${sbagliati.length}');
    cardinaleMinimo(concordi + discordi, 240, cosa: 'domini confrontati');
    expect(sbagliati, isEmpty);
    expect(concordi, greaterThan(0), reason: 'l\'accordo non si dice mai');
    expect(discordi, greaterThan(0), reason: 'il disaccordo non si dice mai');
  });

  // ---------------------------------------------------------------------------
  // A VIDEO: la rivelazione, i tre cieli, il Sigillo
  // ---------------------------------------------------------------------------

  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  final nascita = BirthDetails(
    date: DateTime(1990, 3, 15),
    time: const TimeOfDay(hour: 8, minute: 30),
    place: const BirthPlace(
        label: 'Roma',
        latitude: 41.9,
        longitude: 12.5,
        timezone: 'Europe/Rome'),
  );
  final oggi = DateTime(2026, 7, 10, 12);

  Future<void> monta(WidgetTester tester, {Tier tier = Tier.tier1}) async {
    final messenger = binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
        (call) async => null);
    for (final name in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      messenger.setMockStreamHandler(EventChannel(name),
          MockStreamHandler.inline(onListen: (args, events) {}));
    }
    SharedPreferences.setMockInitialValues(const {});
    tester.view.physicalSize = const Size(390, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final nascite = BirthIdentityController()..setBirth(nascita, null);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(
            create: (_) => EntitlementService(initial: tier)),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider.value(value: nascite),
      ],
      child: MaterialApp(
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
          child: MaestroScope(child: child!),
        ),
        home: OroscopoScreen(userSign: Zodiac.pisces, now: oggi),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
  }

  Future<void> toccaLaTradizione(WidgetTester tester, AstroTradition t) async {
    final riga = find.byKey(const Key('oroscopo_tradition_tabs'));
    await tester.ensureVisible(riga);
    await tester.pump();
    await tester.drag(riga, const Offset(2000, 0));
    await tester.pump(const Duration(milliseconds: 300));
    final chip = find.byKey(Key('oroscopo_tradition_${t.name}'));
    await tester.dragUntilVisible(chip, riga, const Offset(-80, 0));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(chip);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    // La rivelazione arriva dopo il frame, e legge il disco.
    await tester
        .runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pump(const Duration(milliseconds: 600));
  }

  Future<void> consulta(WidgetTester tester) async {
    final gesto = find.byKey(const Key('oroscopo_interroga'));
    await tester.ensureVisible(gesto);
    await tester.tap(gesto);
    await tester.pump();
    await tester.pump(RiflessioneDelCielo.finoAllUltimaScheda(
        HoroscopeDomain.values.length,
        piena: true));
    await tester.pump(const Duration(milliseconds: 800));
    await tester
        .runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pump(const Duration(milliseconds: 300));
  }

  // La riga sta sotto le quattro schede: con le letture nelle tre parti
  // (ordine ES, 30 settembre 2026) le schede cinesi sono piu' alte e la lista
  // pigra non la costruisce senza scorrere fin li'.
  Future<String> riga(WidgetTester tester) async {
    final chiave = find.byKey(const Key('oroscopo_sigillo_tre_cieli_riga'));
    await tester.scrollUntilVisible(chiave, 400,
        scrollable: find.byType(Scrollable).first);
    return tester.widget<Text>(chiave).data!;
  }

  testWidgets(
      'dal primo piano: la rivelazione del segno, i tre cieli e il Sigillo',
      (tester) async {
    await monta(tester);
    await consulta(tester);
    final cieli = find.byKey(const Key('oroscopo_tre_cieli'));
    expect(cieli, findsOneWidget,
        reason: 'sotto le schede non ci sono i tre cieli di oggi');
    final frasi = [
      for (final d in HoroscopeDomain.values)
        tester
            .widget<Text>(find.byKey(Key('oroscopo_tre_cieli_${d.name}')))
            .data!,
    ];
    final primaRiga = await riga(tester);

    // La prima volta della Cinese: la rivelazione.
    await toccaLaTradizione(tester, AstroTradition.cinese);
    final nascitaDeiSegni = NascitaDeiSegni(
        locale: DateTime(1990, 3, 15, 8, 30),
        oraNota: true,
        fuso: 'Europe/Rome');
    final cinese =
        ISegniDelleTradizioni.per(AstroTradition.cinese, nascitaDeiSegni);
    expect(find.byKey(const Key('rivelazione_del_segno')), findsOneWidget,
        reason: 'la prima scelta della Cinese non rivela il segno');
    final fraseCinese =
        tester.widget<Text>(find.byKey(const Key('rivelazione_frase'))).data;
    expect(fraseCinese, cinese.frase);
    expect(find.byKey(const Key('rivelazione_figura')), findsOneWidget);
    expect(find.byKey(const Key('rivelazione_condividi')), findsOneWidget);
    await tester.tap(find.byKey(const Key('rivelazione_continua')));
    await tester.pump(const Duration(milliseconds: 600));
    await consulta(tester);
    final secondaRiga = await riga(tester);

    // La seconda volta della Cinese non rivela piu' niente.
    await toccaLaTradizione(tester, AstroTradition.occidentale);
    await toccaLaTradizione(tester, AstroTradition.cinese);
    final rivelataDiNuovo =
        find.byKey(const Key('rivelazione_del_segno')).evaluate().isNotEmpty;

    // La Vedica: la sua rivelazione, poi il Sigillo si accende.
    await toccaLaTradizione(tester, AstroTradition.vedica);
    final fraseVedica =
        tester.widget<Text>(find.byKey(const Key('rivelazione_frase'))).data;
    await tester.tap(find.byKey(const Key('rivelazione_continua')));
    await tester.pump(const Duration(milliseconds: 600));
    await consulta(tester);
    final terzaRiga = await riga(tester);
    late StatoDeiTreCieli stato;
    await tester.runAsync(() async {
      stato = await IlSigilloDeiTreCieli.di(oggi);
    });
    print('ORDINE ES VOCE 36: i tre cieli a video $frasi');
    print('ORDINE ES VOCE 35: rivelato "$fraseCinese" e "$fraseVedica"; la '
        'seconda volta di nuovo: $rivelataDiNuovo');
    print('ORDINE ES VOCE 37: "$primaRiga" / "$secondaRiga" / "$terzaRiga"; '
        'sul disco acceso ${stato.accesoOggi}, giorni ${stato.giorni}');
    for (final f in frasi) {
      expect(
          f.startsWith('Oggi tre tradizioni su tre vedono ') ||
              f.contains(' le tre tradizioni non sono d\'accordo: '),
          isTrue,
          reason: 'riga dei tre cieli fuori regola: "$f"');
    }
    expect(rivelataDiNuovo, isFalse,
        reason: 'la rivelazione torna alla seconda scelta');
    expect(
        fraseVedica,
        ISegniDelleTradizioni.per(AstroTradition.vedica, nascitaDeiSegni)
            .frase);
    expect(
        primaRiga,
        'Il Sigillo dei Tre Cieli si accende leggendo oggi anche la cinese e '
        'la vedica.');
    expect(secondaRiga,
        'Il Sigillo dei Tre Cieli si accende leggendo oggi anche la vedica.');
    expect(
        terzaRiga,
        'Il Sigillo dei Tre Cieli è acceso: oggi hai letto il cielo in tutte '
        'e tre le tradizioni.');
    expect(stato.accesoOggi, isTrue);
    expect(stato.giorni, 1);
  });

  testWidgets('al Viandante i tre cieli non si dicono', (tester) async {
    await monta(tester, tier: Tier.free);
    await consulta(tester);
    expect(find.byKey(const Key('oroscopo_tre_cieli')), findsNothing,
        reason: 'al Viandante i tre cieli dicono cio\' che vedono la Cinese '
            'e la Vedica, che non sono sue');
  });
}
