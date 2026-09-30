// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/astro/birth_details.dart';
import 'package:esoteric_circle/core/astro/birth_place.dart';
import 'package:esoteric_circle/core/astro/natal_chart.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/horoscope/astro_tradition.dart';
import 'package:esoteric_circle/core/horoscope/l_ora_d_oro.dart';
import 'package:esoteric_circle/core/horoscope/la_settimana_del_cielo.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/horoscope/la_rivelazione_del_segno.dart';
import 'package:esoteric_circle/features/horoscope/oroscopo_screen.dart';
import 'package:esoteric_circle/features/horoscope/riquadro_del_numero.dart';
import 'package:esoteric_circle/features/maestri/live/stato_della_schermata_live.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'cardinale_minimo.dart';

/// **L'OROSCOPO COME SI VEDE SUL REALME.** Ordine ES, 30 settembre 2026.
///
/// I difetti che le prove non cercavano e che le catture dal telefono hanno
/// mostrato nella build di prova del commit 9deede23, ognuno col suo padre:
/// - "Settimana" a capo sull'ultima lettera nel selettore dei periodi (ES.04,
///   che ha portato i periodi a quattro);
/// - il titolo "Oroscopo personalizzato del giorno" e i periodi sotto una
///   tradizione in arrivo, che non ha letture (ES.11);
/// - la riga delle tradizioni rimasta scorsa in fondo dopo "Torna al tuo
///   oroscopo" (ES.11);
/// - "NUMERO 0" e "COLORE DEL GIORNO" vuoto nella Fortuna dell'anno (ES.04);
/// - "Dal cielo di oggi" sotto i giorni futuri della settimana e del mese
///   (ES.02 ed ES.03);
/// - l'ora d'oro di mezzanotte detta al presente a mezzogiorno (ES.32);
/// - le righe della pagina lette attraverso il velo, dietro "Condividi" e
///   "Continua" della rivelazione del segno (ES.35);
/// - "Il cielo di stasera" nel saluto del LIVE a mezzogiorno (EG.01).
///
/// La finestra e' quella del Realme, 360 punti, e non i 390 delle altre
/// prove: a 390 "Settimana" ci stava.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  final nascita = BirthDetails(
    date: DateTime(1990, 6, 15),
    time: const TimeOfDay(hour: 8, minute: 10),
    place: const BirthPlace(
        label: 'Roma',
        latitude: 41.9,
        longitude: 12.5,
        timezone: 'Europe/Rome'),
  );

  Future<void> monta(
    WidgetTester tester, {
    Tier tier = Tier.free,
    double scala = 1.0,
    bool conNascita = true,
  }) async {
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
    tester.view.physicalSize = const Size(360, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final nascite = BirthIdentityController();
    if (conNascita) nascite.setBirth(nascita, null);
    final piano = EntitlementService()..setTier(tier);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider.value(value: piano),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider.value(value: nascite),
      ],
      child: MaterialApp(
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(
              disableAnimations: true, textScaler: TextScaler.linear(scala)),
          child: MaestroScope(child: child!),
        ),
        home: OroscopoScreen(
            userSign: Zodiac.gemini, now: DateTime(2026, 9, 30, 12, 5)),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
  }

  Future<void> toccaLaTradizione(WidgetTester tester, AstroTradition t) async {
    final riga = find.byKey(const Key('oroscopo_tradition_tabs'));
    await tester.ensureVisible(riga);
    await tester.pump();
    final chip = find.byKey(Key('oroscopo_tradition_${t.name}'));
    await tester.dragUntilVisible(chip, riga, const Offset(-80, 0));
    await tester.pump(const Duration(milliseconds: 300));
    final r = tester.getRect(chip);
    if (r.right > 360) {
      await tester.drag(riga, Offset(360 - r.right - 8, 0));
      await tester.pump(const Duration(milliseconds: 300));
    }
    await tester.tap(chip);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('ES.04: i quattro periodi stanno ognuno su una riga, a 360 punti',
      (tester) async {
    final guasti = <String>[];
    var misurati = 0;
    for (final tier in [Tier.free, Tier.tier3]) {
      for (final scala in [1.0, 1.3]) {
        await monta(tester, tier: tier, scala: scala);
        final altezze = <double>{};
        for (final p in HoroscopePeriod.values) {
          final nome = find.byKey(Key('oroscopo_period_nome_${p.name}'));
          final scheda = find.byKey(Key('oroscopo_period_${p.name}'));
          expect(nome, findsOneWidget);
          final paragrafo = tester.renderObject<RenderParagraph>(nome);
          final testo = tester.widget<Text>(nome);
          final pittore = TextPainter(
            text: TextSpan(text: testo.data, style: testo.style),
            textDirection: TextDirection.ltr,
            textScaler: TextScaler.linear(scala),
            maxLines: 1,
          )..layout();
          final dove = tester.getRect(nome);
          final dentro = tester.getRect(scheda);
          misurati++;
          final chi = '${tier.name} scala $scala ${p.label}';
          // Una riga sola: alta meno di due righe, larga quanto il nome
          // intero.
          if (paragrafo.size.height > pittore.height * 1.5) {
            guasti.add('$chi: a capo (alto ${paragrafo.size.height} contro '
                '${pittore.height})');
          } else if (paragrafo.size.width < pittore.width - 0.5) {
            guasti.add('$chi: stretto (${paragrafo.size.width} contro '
                '${pittore.width})');
          } else if (dove.left < dentro.left - 0.5 ||
              dove.right > dentro.right + 0.5) {
            guasti.add('$chi: esce dalla pastiglia');
          }
          altezze.add((dove.height * 10).round() / 10);
          pittore.dispose();
        }
        // I quattro nomi alla stessa misura: se la riga si rimpicciolisce,
        // si rimpicciolisce intera.
        if (altezze.length != 1) {
          guasti.add('${tier.name} scala $scala: nomi di misure diverse '
              '$altezze');
        }
        await tester.pumpWidget(const SizedBox());
      }
    }
    cardinaleMinimo(misurati, 16, cosa: 'nomi dei periodi misurati');
    print('ORDINE ES VOCE 04, I PERIODI A 360 PUNTI: nomi a capo, stretti o '
        'fuori dalla pastiglia ${guasti.length} su $misurati'
        '${guasti.isEmpty ? '' : ': ${guasti.join('; ')}'}');
    expect(guasti, isEmpty);
  });

  testWidgets(
      'ES.11: una tradizione in arrivo non mostra il titolo e i '
      'periodi, e la riga torna sulla scelta', (tester) async {
    await monta(tester);
    expect(find.byKey(const Key('oroscopo_heading')), findsOneWidget);
    var conIPeriodi = 0;
    final inArrivo = AstroTradition.values.where((t) => !t.unlocked).toList();
    cardinaleMinimo(inArrivo.length, 4, cosa: 'tradizioni in arrivo');
    for (final t in inArrivo) {
      await toccaLaTradizione(tester, t);
      expect(find.byKey(Key('oroscopo_lettura_in_arrivo_${t.name}')),
          findsOneWidget);
      if (find.byKey(const Key('oroscopo_heading')).evaluate().isNotEmpty ||
          find
              .byKey(const Key('oroscopo_period_settimana'))
              .evaluate()
              .isNotEmpty) {
        conIPeriodi++;
      }
    }
    print('ORDINE ES VOCE 11, LE TRADIZIONI IN ARRIVO: col titolo del giorno '
        'o coi periodi $conIPeriodi su ${inArrivo.length}');
    expect(conIPeriodi, 0);
    // L'ultima toccata e' in fondo alla riga: si vede lei, e l'Occidentale e'
    // scorsa via. Tornando, la scelta passa all'Occidentale e la riga scorre
    // fino a mostrarla.
    final ultima = tester
        .getRect(find.byKey(Key('oroscopo_tradition_${inArrivo.last.name}')));
    expect(ultima.left, greaterThanOrEqualTo(0));
    expect(ultima.right, lessThanOrEqualTo(360));
    expect(
        tester
            .getRect(find.byKey(const Key('oroscopo_tradition_occidentale')))
            .right,
        lessThan(0),
        reason: 'la riga non e\' scorsa: la prova non misura il ritorno');
    final torna = find.byKey(const Key('oroscopo_torna_al_tuo_oroscopo'));
    await tester.ensureVisible(torna);
    await tester.tap(torna);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
    expect(find.byKey(const Key('oroscopo_heading')), findsOneWidget);
    final scelta = find.byKey(const Key('oroscopo_tradition_occidentale'));
    expect(scelta, findsOneWidget);
    final r = tester.getRect(scelta);
    print('ORDINE ES VOCE 11, LA RIGA DELLE TRADIZIONI: dopo "Torna al tuo '
        'oroscopo" la voce scelta sta fra ${r.left.round()} e '
        '${r.right.round()} punti su 360');
    expect(r.left, greaterThanOrEqualTo(0));
    expect(r.right, lessThanOrEqualTo(360));
  });

  testWidgets(
      'ES.04: la Fortuna dell\'anno non porta il numero e il colore '
      'del giorno, e il PDF sta su una riga', (tester) async {
    await monta(tester, tier: Tier.tier3);
    final anno = find.byKey(const Key('oroscopo_period_anno'));
    await tester.ensureVisible(anno);
    await tester.tap(anno);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byKey(const Key('oroscopo_anno_riga')), findsOneWidget);
    final fortuna = find.byKey(const Key('oroscopo_card_fortuna'));
    await tester.dragUntilVisible(
        fortuna, find.byKey(const Key('oroscopo_list')), const Offset(0, -300));
    final riquadri = find
        .descendant(of: fortuna, matching: find.byType(RiquadroDelNumero))
        .evaluate()
        .length;
    final colore = find
        .descendant(of: fortuna, matching: find.text('COLORE DEL GIORNO'))
        .evaluate()
        .length;
    print('ORDINE ES VOCE 04, LA FORTUNA DELL\'ANNO: riquadri del numero '
        '$riquadri, scritte "colore del giorno" $colore');
    expect(riquadri, 0);
    expect(colore, 0);
    expect(
        find.descendant(
            of: fortuna, matching: find.textContaining('Colore del giorno')),
        findsNothing);
    final etichetta = find.byKey(const Key('oroscopo_anno_pdf_etichetta'));
    await tester.dragUntilVisible(etichetta,
        find.byKey(const Key('oroscopo_list')), const Offset(0, -300));
    final paragrafo = tester.renderObject<RenderParagraph>(etichetta);
    final testo = tester.widget<Text>(etichetta);
    final pittore = TextPainter(
      text: TextSpan(text: '${testo.data} · +15 Eos', style: testo.style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    // Anche col premio dichiarato accanto, che qui non c'e' perche' la borsa
    // non e' montata, l'etichetta sta nei 264 punti del pulsante.
    print('ORDINE ES VOCE 04, IL PULSANTE DEL PDF: "${testo.data} · +15 '
        'Eos" largo ${pittore.width.round()} punti su 264');
    expect(pittore.width, lessThanOrEqualTo(264));
    expect(paragrafo.size.height, lessThan(pittore.height * 1.5));
    pittore.dispose();
  });

  test('ES.02 ed ES.03: i giorni della settimana non dicono "oggi"', () {
    var conOggi = 0;
    var righe = 0;
    // Una carta con l'ora, perche' i giorni si leggano dal cielo vero, e
    // nessuna carta, perche' si leggano dalla Luna nelle case solari.
    final conLaCarta = NatalChart(
      sunSign: Zodiac.gemini,
      planets: [
        for (final (id, nome, l) in [
          ('sun', 'Sole', 84.0),
          ('moon', 'Luna', 340.0),
          ('venus', 'Venere', 100.0),
          ('mars', 'Marte', 200.0),
          ('jupiter', 'Giove', 70.0),
        ])
          PlanetPosition(
              id: id,
              name: nome,
              glyph: '',
              longitude: l,
              sign: Zodiac.values[(l ~/ 30) % 12]),
      ],
      ascendantLongitude: 110,
      midheavenLongitude: 20,
      houses: [
        for (var n = 1; n <= 12; n++)
          HouseCusp(number: n, longitude: (110 + (n - 1) * 30.0) % 360.0),
      ],
      hasTime: true,
    );
    for (final carta in <NatalChart?>[null, conLaCarta]) {
      final periodo = LaSettimanaDelCielo.per(
          oggi: DateTime(2026, 9, 30), segno: Zodiac.gemini, carta: carta);
      for (final d in periodo.domini) {
        for (final g in d.giorni) {
          righe++;
          if (RegExp(r'\boggi\b', caseSensitive: false).hasMatch(g.motivo)) {
            conOggi++;
          }
        }
      }
    }
    cardinaleMinimo(righe, 56, cosa: 'righe dei giorni della settimana');
    print('ORDINE ES VOCI 02 E 03, I GIORNI DEL PERIODO: righe che dicono '
        '"oggi" $conOggi su $righe');
    expect(conOggi, 0);
  });

  test('ES.32: l\'ora d\'oro gia\' passata si dice al passato', () {
    final ora = OraDOro(
        istante: DateTime.utc(2026, 9, 29, 22, 3),
        aspetto: AspectType.conjunction,
        punto: 'venus');
    final prima = ora.fraseAlle(DateTime.utc(2026, 9, 29, 20));
    final dopo = ora.fraseAlle(DateTime.utc(2026, 9, 30, 10));
    expect(prima, ora.frase);
    expect(prima, contains('forma una congiunzione'));
    expect(dopo, contains('ha formato una congiunzione'));
    expect(dopo, contains('è stata la tua ora d\'oro'));
    expect(dopo, isNot(contains('è la tua ora d\'oro')));
    final fonte =
        File('lib/features/horoscope/oroscopo_screen.dart').readAsStringSync();
    expect(fonte.contains('?.fraseAlle(_date)'), isTrue,
        reason: 'la schermata dice l\'ora d\'oro senza guardare che ora e\'');
  });

  test('ES.35: il velo della rivelazione copre la pagina sotto', () {
    expect(LaRivelazioneDelSegno.opacitaDelVelo, greaterThanOrEqualTo(0.9));
    final fonte = File('lib/features/horoscope/la_rivelazione_del_segno.dart')
        .readAsStringSync();
    expect(
        fonte.contains('PassaggioDelCerchio.nero.withValues(alpha: '
            'opacitaDelVelo)'),
        isTrue);
  });

  test('EG.01: il saluto del LIVE non dice un\'ora del giorno', () {
    final ore = RegExp(
        r'(?<!\p{L})(stasera|stamattina|stanotte|stamani|oggi|domani|sera|'
        r'mattina|notte|pomeriggio)(?!\p{L})',
        unicode: true,
        caseSensitive: false);
    final conLOra = [
      for (final m in Maestro.values)
        if (ore.hasMatch(ilSalutoDellaVoceViva(m))) m.name,
    ];
    print('ORDINE ES, IL SALUTO DEL LIVE: saluti che dicono un\'ora del '
        'giorno ${conLOra.length} su ${Maestro.values.length}');
    expect(conLOra, isEmpty);
  });
}
