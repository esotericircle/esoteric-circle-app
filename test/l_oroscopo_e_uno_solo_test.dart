// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/amici/amici_offline.dart';
import 'package:esoteric_circle/core/astro/birth_details.dart';
import 'package:esoteric_circle/core/astro/birth_place.dart';
import 'package:esoteric_circle/core/astro/natal_chart.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/horoscope/gli_anni_aperti.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/sigilli/diario_del_cammino.dart';
import 'package:esoteric_circle/design_system/components/cosmos_background.dart';
import 'package:esoteric_circle/design_system/theme/app_theme.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/horoscope/horoscope_visuals.dart';
import 'package:esoteric_circle/features/horoscope/la_ruota_del_passaggio.dart';
import 'package:esoteric_circle/features/horoscope/le_ore_del_giorno_view.dart';
import 'package:esoteric_circle/features/horoscope/oroscopo_screen.dart';
import 'package:esoteric_circle/features/horoscope/riquadro_del_numero.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cardinale_minimo.dart';
import 'il_gesto_nelle_prove.dart';

/// **L'OROSCOPO E' UNO SOLO. Ordine FC voci 02, 03, 05 e 06, 4 ottobre 2026.**
///
/// L'ordine ES voce 12 aveva fatto nascere una seconda schermata
/// dell'oroscopo per gli amici, invece di far passare questa per un soggetto
/// diverso: nera, senza la scena del gesto, con una sola infografica e senza
/// i periodi. Il fondatore, 4 ottobre 2026: *"mi compare l'oroscopo di botto,
/// senza pulsante e senza animazione di riflessione"*, *"Lo sfondo è nero"*,
/// *"mancano le infografiche come negli altri"*, *"manca la scelta tra
/// giornaliero, settimanale, mensile, annuale"*.
///
/// Questa prova chiude la CLASSE, non il caso: ENUMERA le cose che
/// l'Oroscopo mostra e le pretende tutte col soggetto "io" e col soggetto
/// "amico", e cade col nome della cosa mancante.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  final amica = Amico(
      id: 'lucia',
      nome: 'Lucia',
      nascita: DateTime(1990, 1, 12),
      ora: '08:10',
      luogo: 'Roma',
      lat: 41.9,
      lon: 12.5,
      fuso: 'Europe/Rome');

  /// La carta intera di chi usa l'app: la ruota del passaggio e l'ora d'oro
  /// vogliono il cielo vero.
  final carta = NatalChart(
    sunSign: Zodiac.gemini,
    planets: [
      for (final (id, nome, l) in const [
        ('sun', 'Sole', 84.0),
        ('moon', 'Luna', 340.0),
        ('mercury', 'Mercurio', 70.0),
        ('venus', 'Venere', 47.0),
        ('mars', 'Marte', 5.0),
        ('jupiter', 'Giove', 102.0),
        ('saturn', 'Saturno', 294.0),
      ])
        PlanetPosition(
            id: id,
            name: nome,
            glyph: '',
            longitude: l,
            sign: Zodiac.values[(l ~/ 30) % 12]),
    ],
    ascendantLongitude: 110.0,
    midheavenLongitude: 20.0,
    houses: [
      for (var n = 1; n <= 12; n++)
        HouseCusp(number: n, longitude: (110.0 + (n - 1) * 30.0) % 360.0),
    ],
    hasTime: true,
  );

  Future<void> monta(WidgetTester tester,
      {Amico? amico, Tier tier = Tier.tier3, DiarioDelCammino? diario}) async {
    SharedPreferences.setMockInitialValues({
      'oroscopo_segno_rivelato': ['cinese', 'vedica'],
    });
    final messenger = binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
        (call) async => null);
    tester.view.physicalSize = const Size(360, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final nascite = BirthIdentityController()
      ..setBirth(
          BirthDetails(
            date: DateTime(1990, 6, 15),
            time: const TimeOfDay(hour: 8, minute: 10),
            place: const BirthPlace(
                label: 'Roma',
                latitude: 41.9,
                longitude: 12.5,
                timezone: 'Europe/Rome'),
          ),
          carta);
    final adesso = DateTime(2026, 10, 4, 12);
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
        ChangeNotifierProvider(create: (_) => AmiciOffline()),
        if (diario != null) ChangeNotifierProvider.value(value: diario),
      ],
      child: MaterialApp(
        theme: AppTheme.dark(),
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
          child: MaestroScope(child: child!),
        ),
        home: amico == null
            ? OroscopoScreen(userSign: Zodiac.gemini, now: adesso)
            : OroscopoScreen(
                userSign: Zodiac.fromDate(amico.nascita),
                amico: amico,
                now: adesso),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
  }

  bool ce(Finder f) => f.evaluate().isNotEmpty;

  /// **LE COSE CHE L'OROSCOPO MOSTRA**, ordine FC voce 02 punto 5: prima del
  /// tocco e dopo. Una mancante e' una differenza fra le due letture.
  Future<Map<String, bool>> leCose(WidgetTester tester) async {
    final prima = <String, bool>{
      'il fondale cosmico in parallasse': ce(find.byType(CosmosBackground)),
      'la riga "Oroscopo per"': ce(find.byKey(const Key('oroscopo_per'))),
      'il selettore dei periodi': [
        for (final p in HoroscopePeriod.values)
          ce(find.byKey(Key('oroscopo_period_${p.name}')))
      ].every((x) => x),
      'le tradizioni': ce(find.byKey(const Key('oroscopo_tradition_tabs'))),
      'il gesto': ce(find.byType(InterrogaIlCielo)),
      'nessuna scheda prima del gesto':
          !ce(find.byKey(const Key('oroscopo_card_generale'))),
    };
    await interrogaSeCe(tester);
    // La card sta in fondo, e la lista costruisce cio' che si avvicina.
    final condividi = find.byKey(const Key('responso_condividi'));
    if (!ce(condividi)) {
      await tester.scrollUntilVisible(condividi, 400,
          scrollable: find.byType(Scrollable).first, maxScrolls: 30);
    }
    final dopo = <String, bool>{
      'le quattro schede': [
        for (final d in const ['generale', 'amore', 'carriera', 'fortuna'])
          ce(find.byKey(Key('oroscopo_card_$d')))
      ].every((x) => x),
      'i selettori di profondita\'': find
              .byWidgetPredicate((w) =>
                  w.key is ValueKey<String> &&
                  (w.key! as ValueKey<String>)
                      .value
                      .startsWith('oroscopo_depth_'))
              .evaluate()
              .length >=
          4,
      'la card da condividere': ce(find.byKey(const Key('responso_condividi'))),
    };
    return {...prima, ...dopo};
  }

  /// **LE INFOGRAFICHE DELLA SCHEDA**, ordine FC voce 05: il colpo d'occhio
  /// visivo prima del testo, una per una.
  Map<String, int> leInfografiche() => {
        'il livello del dominio (DomainLevel)':
            find.byType(DomainLevel).evaluate().length,
        'le ore del giorno (LeOreDelGiornoView)':
            find.byType(LeOreDelGiornoView).evaluate().length,
        'il numero e il colore della Fortuna (RiquadroDelNumero)':
            find.byType(RiquadroDelNumero).evaluate().length,
        'la ruota del passaggio (LaRigaDelPassaggio)':
            find.byType(LaRigaDelPassaggio).evaluate().length,
        'l\'ora d\'oro':
            find.byKey(const Key('oroscopo_ora_d_oro')).evaluate().length,
      };

  /// **LE INFOGRAFICHE CHE SENZA LA CARTA NATALE NON HANNO SENSO.** Di un
  /// amico l'app non ha la carta: non si disegnano vuote, si tolgono, e qui
  /// sta il perche' (la regola del campo che sparisce invece di aspettare).
  const tolteSenzaLaCarta = {
    'la ruota del passaggio (LaRigaDelPassaggio)':
        'la ruota mostra il transito di oggi su un pianeta della carta '
            'natale: di un amico la carta non c\'e\'',
    'l\'ora d\'oro': 'l\'ora d\'oro e\' l\'ora in cui la Luna tocca un punto '
        'della carta natale: di un amico la carta non c\'e\'',
  };

  testWidgets(
      'FC.02: l\'oroscopo mostra le stesse cose a chi lo legge per se\' e '
      'per un amico', (tester) async {
    await monta(tester);
    final mie = await leCose(tester);
    final infoMie = leInfografiche();
    await tester.pumpWidget(const SizedBox());
    await monta(tester, amico: amica);
    // Il titolo dell'amico intero: nell'anteprima diceva "L'oroscopo di
    // Lu...", e non diceva di chi era. Si misura il paragrafo, non l'albero.
    final titolo = find.byKey(const Key('oroscopo_titolo_del_soggetto'));
    expect(tester.widget<Text>(titolo).data, 'L\'oroscopo di Lucia');
    final paragrafo = tester.renderObject<RenderParagraph>(
        find.descendant(of: titolo, matching: find.byType(RichText)).first);
    final dove = tester.getRect(titolo);
    print('ORDINE FC VOCE 02: il titolo dell\'amico largo '
        '${dove.width.toStringAsFixed(1)} punti, oltre il massimo '
        '${paragrafo.didExceedMaxLines}, dentro la finestra '
        '${dove.left >= 0 && dove.right <= 360}');
    expect(paragrafo.didExceedMaxLines, isFalse);
    expect(dove.left >= 0 && dove.right <= 360, isTrue);
    final sue = await leCose(tester);
    final infoSue = leInfografiche();
    final mancanti = [
      for (final e in mie.entries)
        if (!e.value) 'per se\': ${e.key}',
      for (final e in sue.entries)
        if (!e.value) 'per l\'amico: ${e.key}',
    ];
    cardinaleMinimo(mie.length, 9, cosa: 'cose che l\'oroscopo mostra');
    print('ORDINE FC VOCE 02: cose enumerate ${mie.length}, presenti per se\' '
        '${mie.values.where((x) => x).length}, per l\'amico '
        '${sue.values.where((x) => x).length}'
        '${mancanti.isEmpty ? '' : '; mancanti: ${mancanti.join(', ')}'}');
    expect(mancanti, isEmpty, reason: mancanti.join('\n'));

    // FC.05: le infografiche, una per una.
    final infoMancanti = [
      for (final e in infoMie.entries)
        if (e.value > 0 &&
            (infoSue[e.key] ?? 0) == 0 &&
            !tolteSenzaLaCarta.containsKey(e.key))
          e.key,
    ];
    final disegnateVuote = [
      for (final k in tolteSenzaLaCarta.keys)
        if ((infoSue[k] ?? 0) > 0) k,
    ];
    print('ORDINE FC VOCE 05: infografiche per se\' '
        '${infoMie.entries.where((e) => e.value > 0).map((e) => e.key).join(', ')}; '
        'per l\'amico '
        '${infoSue.entries.where((e) => e.value > 0).map((e) => e.key).join(', ')}; '
        'tolte senza la carta, col perche\', ${tolteSenzaLaCarta.length}');
    cardinaleMinimo(infoMie.values.where((x) => x > 0).length, 5,
        cosa: 'infografiche dell\'oroscopo proprio con la carta');
    expect(infoMancanti, isEmpty,
        reason: 'all\'amico mancano infografiche che non dipendono dalla '
            'carta: $infoMancanti');
    expect(disegnateVuote, isEmpty,
        reason: 'infografiche della carta disegnate per un amico senza '
            'carta: $disegnateVuote');
    expect(infoSue['il livello del dominio (DomainLevel)'], 4);
  });

  testWidgets(
      'FC.03: il responso non compare mai da solo, e arriva nello stesso '
      'tempo per se\' e per un amico', (tester) async {
    final secondi = <String, double>{};
    for (final (chi, amico) in [('io', null), ('amico', amica)]) {
      await monta(tester, amico: amico);
      final scheda = find.byKey(const Key('oroscopo_card_generale'));
      expect(scheda, findsNothing,
          reason: '$chi: le schede ci sono prima del tocco');
      final gesto = find.byType(InterrogaIlCielo);
      expect(gesto, findsOneWidget, reason: '$chi: manca il gesto');
      await tester.ensureVisible(gesto);
      await tester.pump();
      await tester.tap(gesto);
      var t = Duration.zero;
      const passo = Duration(milliseconds: 50);
      while (!ce(scheda) && t < const Duration(seconds: 15)) {
        await tester.pump(passo);
        t += passo;
      }
      expect(ce(scheda), isTrue, reason: '$chi: dopo il tocco nessuna scheda');
      secondi[chi] = t.inMilliseconds / 1000;
      await aspettaLaRiflessione(tester);
      await tester.pumpWidget(const SizedBox());
    }
    print('ORDINE FC VOCE 03: secondi dal tocco alla prima scheda, per se\' '
        '${secondi['io']}, per l\'amico ${secondi['amico']}');
    expect(secondi['io'], secondi['amico']);
    expect(secondi['io'], greaterThan(3.0),
        reason: 'la riflessione non c\'e\'');
  });

  testWidgets(
      'FC.06: i quattro periodi anche per l\'amico, coi limiti di chi guarda',
      (tester) async {
    final righe = <String>[];
    for (final (tier, aperti) in [
      (Tier.free, ['giorno', 'anno']),
      (Tier.tier1, ['giorno', 'settimana', 'anno']),
      (Tier.tier3, ['giorno', 'settimana', 'mese', 'anno']),
    ]) {
      for (final (chi, amico) in [('io', null), ('amico', amica)]) {
        await monta(tester, amico: amico, tier: tier);
        final visti = [
          for (final p in HoroscopePeriod.values)
            if (ce(find.byKey(Key('oroscopo_period_${p.name}')))) p.name,
        ];
        expect(visti, ['giorno', 'settimana', 'mese', 'anno'],
            reason: '$chi ${tier.name}: periodi a video $visti');
        final apribili = [
          for (final p in HoroscopePeriod.values)
            if (p.apertoPer(tier)) p.name,
        ];
        righe.add('${tier.name} $chi: a video ${visti.length}, apribili '
            '$apribili');
        expect(apribili, aperti);
        await tester.pumpWidget(const SizedBox());
      }
    }
    print('ORDINE FC VOCE 06: ${righe.join('; ')}');
  });

  test(
      'FC.06: l\'anno aperto con gli Eos e\' del soggetto, gli Eos sono di chi '
      'guarda', () async {
    SharedPreferences.setMockInitialValues({});
    // Aperto l'anno di Lucia, il proprio resta chiuso, e viceversa: prima
    // dell'ordine FC la schermata dell'amico non aveva l'anno affatto.
    await GliAnniAperti.apri(2026, soggetto: 'amico|lucia|anni');
    final miei = await GliAnniAperti.letti();
    final suoi = await GliAnniAperti.letti(soggetto: 'amico|lucia|anni');
    print('ORDINE FC VOCE 06: anni aperti per se\' $miei, per Lucia $suoi');
    expect(miei, isEmpty);
    expect(suoi, {2026});
    // La spesa passa da `PortaDellaSpesa`, che legge l'unica borsa dell'app,
    // quella di chi guarda: un amico non ha Eos.
    final porta = File('lib/design_system/components/porta_della_spesa.dart')
        .readAsStringSync();
    expect(porta, contains('context.read<QuestionAllowance>()'));
  });

  testWidgets(
      'FC.02: la lettura di un amico non entra nel Cammino, la propria si',
      (tester) async {
    // Il gesto del Cammino segnala al server il rito compiuto: prima
    // dell'ordine FC la lettura di un amico non ci passava, e la porta unica
    // non deve aggiungere una chiamata per ogni lettura (R14).
    final conti = <String, int>{};
    for (final (chi, amico) in [('io', null), ('amico', amica)]) {
      final diario =
          DiarioDelCammino(orologio: () => DateTime(2026, 10, 4, 12));
      await monta(tester, amico: amico, diario: diario);
      await interrogaSeCe(tester);
      conti[chi] = diario.quanteVolte('oroscopo');
      await tester.pumpWidget(const SizedBox());
    }
    print('ORDINE FC VOCE 02: gesti dell\'oroscopo nel Cammino, lettura '
        'propria ${conti['io']}, lettura di un amico ${conti['amico']}');
    expect(conti['io'], 1, reason: 'la lettura propria non entra nel Cammino');
    expect(conti['amico'], 0,
        reason: 'la lettura di un amico entra nel Cammino: una chiamata in '
            'piu\' al server per ogni lettura');
  });

  test('FC.02: la schermata non legge i dati di nascita da sola', () {
    // **TUTTO CIO' CHE CAMBIA COL SOGGETTO STA IN UN POSTO SOLO**:
    // `IlSoggettoDellOroscopo`. Se la schermata tornasse a leggere la carta,
    // la nascita o la forma dal profilo, una differenza nuova nascerebbe fuori
    // dall'elenco, e l'amico la perderebbe senza che nessuno lo sappia.
    final schermata = File('lib/features/horoscope/oroscopo_screen.dart')
        .readAsStringSync()
        .split('\n')
        .where((r) => !r.trimLeft().startsWith('//'))
        .join('\n');
    final vietate = {
      'BirthIdentityController': RegExp(r'BirthIdentityController'),
      '.identity (i dati di nascita del profilo)': RegExp(r'\.identity\b'),
      '.courtesy (la forma del profilo)': RegExp(r'\.courtesy\b'),
      'cartaCompleta': RegExp(r'cartaCompleta'),
      // Il segno con cui la schermata e' aperta entra solo nel soggetto.
      'widget.userSign fuori dal soggetto': RegExp(
          r'^(?!.*IlSoggettoDellOroscopo).*widget\.userSign',
          multiLine: true),
    };
    final trovate = [
      for (final e in vietate.entries)
        if (e.value.hasMatch(schermata)) e.key,
    ];
    final soggetto =
        File('lib/features/horoscope/il_soggetto_dell_oroscopo.dart')
            .readAsStringSync();
    final differenze =
        RegExp(r'^/// \d+\. \*\*', multiLine: true).allMatches(soggetto).length;
    print('ORDINE FC VOCE 02: letture dirette dei dati di nascita nella '
        'schermata ${trovate.length}${trovate.isEmpty ? '' : ' $trovate'}; '
        'differenze dichiarate nel soggetto $differenze');
    cardinaleMinimo(differenze, 9, cosa: 'differenze dichiarate nel soggetto');
    expect(trovate, isEmpty);
  });
}
