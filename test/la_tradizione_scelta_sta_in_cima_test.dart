// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/astro/birth_details.dart';
import 'package:esoteric_circle/core/astro/birth_place.dart';
import 'package:esoteric_circle/core/astro/natal_chart.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/horoscope/astro_tradition.dart';
import 'package:esoteric_circle/core/horoscope/cielo_di_oggi.dart';
import 'package:esoteric_circle/core/horoscope/corrente_del_cielo.dart';
import 'package:esoteric_circle/core/horoscope/horoscope.dart';
import 'package:esoteric_circle/core/horoscope/il_metodo_del_responso.dart';
import 'package:esoteric_circle/core/horoscope/riflessione_del_cielo.dart';
import 'package:esoteric_circle/core/astro/aspetti_di_oggi.dart';
import 'package:esoteric_circle/core/horoscope/le_note_delle_tradizioni.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/account/dati_di_nascita_screen.dart';
import 'package:esoteric_circle/features/horoscope/oroscopo_screen.dart';
import 'package:esoteric_circle/features/horoscope/oroscopo_share_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'cardinale_minimo.dart';

/// **LA TRADIZIONE SCELTA STA IN CIMA, CON LA SUA NOTA.** Ordine ES voci 07,
/// 10, 11, 13 e 31, 29 settembre 2026.
///
/// - ES.07: scegliendo una tradizione in cima compare il segno della persona
///   in quella tradizione, non l'occidentale. Prima: due tradizioni
///   (Cinese e Vedica) lasciavano in cima l'occidentale, anzi tutte e sei.
/// - ES.11: le tradizioni non pronte portano la clessidra, non il lucchetto
///   del Premium, e in cima l'emblema, il segno calcolato e "In arrivo".
/// - ES.10: accanto al segno di ognuna delle sette il punto interrogativo
///   apre la nota, con le fonti.
/// - ES.31: a chi non ha ora e luogo di nascita, la riga che porta a darli.
/// - ES.13: la card porta il nome senza cognome e i dati di nascita.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  // Roma, 15 marzo 1990, 8:30: le fonti dicono Cavallo, Tula, 7 Akʼbʼal,
  // Frassino, Ptibiou, al-Iklil.
  final nascita = BirthDetails(
    date: DateTime(1990, 3, 15),
    time: const TimeOfDay(hour: 8, minute: 30),
    place: const BirthPlace(
        label: 'Roma',
        latitude: 41.9,
        longitude: 12.5,
        timezone: 'Europe/Rome'),
  );

  Future<BirthIdentityController> monta(WidgetTester tester,
      {bool conNascita = true}) async {
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
    tester.view.physicalSize = const Size(390, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final nascite = BirthIdentityController();
    if (conNascita) nascite.setBirth(nascita, null);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => EntitlementService()),
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
        home:
            OroscopoScreen(userSign: Zodiac.pisces, now: DateTime(2026, 7, 10)),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    return nascite;
  }

  /// Tocca il chip della tradizione [t] come fa il dito: la riga scorre e
  /// costruisce solo le voci in vista, quindi prima si riporta all'inizio e
  /// poi si scorre fino al chip.
  Future<void> toccaLaTradizione(WidgetTester tester, AstroTradition t) async {
    final riga = find.byKey(const Key('oroscopo_tradition_tabs'));
    await tester.ensureVisible(riga);
    await tester.pump();
    await tester.drag(riga, const Offset(2000, 0));
    await tester.pump(const Duration(milliseconds: 300));
    final chip = find.byKey(Key('oroscopo_tradition_${t.name}'));
    await tester.dragUntilVisible(chip, riga, const Offset(-80, 0));
    await tester.pump(const Duration(milliseconds: 300));
    // Il chip deve stare tutto dentro lo schermo, o il tocco cade fuori.
    final r = tester.getRect(chip);
    final largo = tester.view.physicalSize.width / tester.view.devicePixelRatio;
    if (r.right > largo) {
      await tester.drag(riga, Offset(largo - r.right - 8, 0));
      await tester.pump(const Duration(milliseconds: 300));
    }
    await tester.tap(chip);
    await tester.pump();
  }

  String nomeInCima(WidgetTester tester) =>
      tester.widget<Text>(find.byKey(const Key('oroscopo_sign_name'))).data!;

  testWidgets('ES.07 ed ES.11: ogni tradizione porta in cima il suo segno',
      (tester) async {
    await monta(tester);
    expect(nomeInCima(tester), 'Pesci');
    final attesi = {
      AstroTradition.cinese: 'Cavallo',
      AstroTradition.vedica: 'Tula (Bilancia)',
      AstroTradition.maya: '7 Akʼbʼal',
      AstroTradition.celtica: 'Frassino',
      AstroTradition.egizia: 'Ptibiou, terzo decano dei Pesci',
      AstroTradition.araba: 'al-Iklil, la corona',
    };
    final occidentaleInCima = <String>[];
    final righe = <String>[];
    for (final t in attesi.keys) {
      await toccaLaTradizione(tester, t);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.dragUntilVisible(find.byKey(const Key('oroscopo_sign_name')),
          find.byKey(const Key('oroscopo_list')), const Offset(0, 300));
      final nome = nomeInCima(tester);
      righe.add('${t.label}: $nome');
      if (nome == 'Pesci') occidentaleInCima.add(t.label);
      expect(nome, attesi[t], reason: t.name);
      expect(find.byKey(Key('oroscopo_testa_${t.name}')), findsOneWidget);
      expect(find.byKey(Key('oroscopo_figura_${t.name}')), findsOneWidget);
      // Nessuna delle sei e' ancora aperta: tutte dicono "In arrivo".
      expect(find.byKey(Key('oroscopo_in_arrivo_${t.name}')), findsOneWidget);
      // Sotto un segno in arrivo non si apre il consulto occidentale, che si
      // leggerebbe come suo: c'e' la riga che lo dice e il gesto per tornare.
      expect(find.byKey(const Key('oroscopo_interroga')), findsNothing,
          reason: '${t.name}: sotto il suo segno si apre il consulto '
              'occidentale');
      expect(find.byKey(Key('oroscopo_lettura_in_arrivo_${t.name}')),
          findsOneWidget);
    }
    final figura =
        tester.widget<Image>(find.byKey(const Key('oroscopo_figura_araba')));
    expect((figura.image as AssetImage).assetName,
        'assets/schede/Tradizione-Araba-Square-1.webp');
    print('ORDINE ES VOCE 07: tradizioni che lasciano in cima il segno '
        'occidentale ${occidentaleInCima.length} su 6; ${righe.join('; ')}');
    expect(occidentaleInCima, isEmpty);
    // Il gesto per tornare riporta il segno del Sole e il consulto.
    final torna = find.byKey(const Key('oroscopo_torna_al_tuo_oroscopo'));
    await tester.ensureVisible(torna);
    await tester.tap(torna);
    await tester.pump();
    expect(find.byKey(const Key('oroscopo_interroga')), findsOneWidget);
    await tester.dragUntilVisible(find.byKey(const Key('oroscopo_sign_name')),
        find.byKey(const Key('oroscopo_list')), const Offset(0, 300));
    expect(nomeInCima(tester), 'Pesci');
    // E anche il chip dell'Occidentale.
    await toccaLaTradizione(tester, AstroTradition.occidentale);
    await tester.dragUntilVisible(find.byKey(const Key('oroscopo_sign_name')),
        find.byKey(const Key('oroscopo_list')), const Offset(0, 300));
    expect(nomeInCima(tester), 'Pesci');
  });

  testWidgets('ES.11: la clessidra, non il lucchetto, sulle sei tradizioni',
      (tester) async {
    await monta(tester);
    final riga = find.byKey(const Key('oroscopo_tradition_tabs'));
    final lucchetti =
        find.descendant(of: riga, matching: find.byIcon(Icons.lock_rounded));
    final clessidre = find.descendant(
        of: riga, matching: find.byIcon(Icons.hourglass_bottom_rounded));
    // La riga scorre: le voci fuori vista non sono costruite, quindi le
    // clessidre si contano scorrendo.
    print('ORDINE ES VOCE 11: lucchetti sulle tradizioni '
        '${lucchetti.evaluate().length}, clessidre in vista '
        '${clessidre.evaluate().length}');
    expect(lucchetti, findsNothing);
    for (final t in AstroTradition.values.where((t) => !t.unlocked)) {
      await tester.dragUntilVisible(
          find.byKey(Key('oroscopo_tradition_clessidra_${t.name}')),
          riga,
          const Offset(-120, 0));
    }
  });

  testWidgets(
      'ES.10: il punto interrogativo apre la nota di ognuna delle '
      'sette', (tester) async {
    await monta(tester);
    final senzaNota = <String>[];
    for (final t in AstroTradition.values) {
      if (t != AstroTradition.occidentale) {
        await toccaLaTradizione(tester, t);
      }
      final bottone = find.byKey(Key('oroscopo_nota_${t.name}'));
      await tester.dragUntilVisible(bottone,
          find.byKey(const Key('oroscopo_list')), const Offset(0, 300));
      await tester.tap(bottone);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      final foglio = find.byKey(Key('oroscopo_foglio_nota_${t.name}'));
      if (foglio.evaluate().isEmpty) senzaNota.add(t.label);
      final nota = LeNoteDelleTradizioni.di(t);
      expect(
          find.textContaining(nota.cheCose.substring(0, 30)), findsOneWidget);
      cardinaleMinimo(nota.fonti.length, 2, cosa: 'fonti della ${t.label}');
      Navigator.of(tester.element(foglio)).pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
    }
    print('ORDINE ES VOCE 10: tradizioni senza nota ${senzaNota.length} su 7');
    expect(senzaNota, isEmpty);
  });

  testWidgets('ES.31: l\'invito porta ai dati di nascita', (tester) async {
    await monta(tester, conNascita: false);
    final invito = find.byKey(const Key('oroscopo_invito_nascita'));
    expect(invito, findsOneWidget);
    await tester.ensureVisible(invito);
    await tester.tap(invito);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(DatiDiNascitaScreen), findsOneWidget);
    print('ORDINE ES VOCE 31: dall\'invito ai dati di nascita, un tocco');
  });

  testWidgets(
      'ES.31: con l\'invito, "Interroga il cielo" resta sopra la piega sul '
      'telefono vero', (tester) async {
    await monta(tester, conNascita: false);
    // La finestra del Realme di collaudo, 1080x2391 a tre pixel per punto,
    // cioe' 360x797 punti: a 390x844 l'invito sopra il gesto lo lasciava
    // ancora dentro lo schermo, e la guardia sarebbe stata verde sul
    // difetto.
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(1080, 2391);
    await tester.pump();
    final gesto = tester.getRect(find.byKey(const Key('oroscopo_interroga')));
    final invito =
        tester.getRect(find.byKey(const Key('oroscopo_invito_nascita')));
    print('ORDINE ES VOCE 31: a 360x797 il gesto finisce a '
        '${gesto.bottom.toStringAsFixed(0)} punti, l\'invito comincia a '
        '${invito.top.toStringAsFixed(0)}');
    expect(gesto.bottom, lessThanOrEqualTo(797),
        reason: 'l\'invito spinge "Interroga il cielo" sotto la piega');
    expect(invito.top, greaterThan(gesto.top),
        reason: 'l\'invito sta sopra il gesto');
  });

  test('ES.31: con la carta completa l\'invito non c\'e\'', () {
    final completa = NatalChart(
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
      ],
      ascendantLongitude: 45.5,
      midheavenLongitude: 300.0,
      houses: [
        for (var n = 1; n <= 12; n++)
          HouseCusp(number: n, longitude: (45.5 + (n - 1) * 30.0) % 360.0),
      ],
      hasTime: true,
    );
    final adesso = DateTime.utc(2026, 7, 10, 12);
    final conCarta = CieloDiOggi.perIlGiorno(adesso: adesso, carta: completa);
    final senza = CieloDiOggi.perIlGiorno(adesso: adesso, carta: null);
    expect(CorrenteDelCielo.rigaDellInvito(conCarta), isNull,
        reason: 'l\'invito si mostra a chi ha gia\' dato i dati');
    expect(CorrenteDelCielo.rigaDellInvito(senza), isNotNull);
  });

  testWidgets(
      'ES.30: ogni scheda del giorno ha il punto interrogativo del '
      'metodo', (tester) async {
    await monta(tester, conNascita: false);
    final interroga = find.byKey(const Key('oroscopo_interroga'));
    await tester.ensureVisible(interroga);
    await tester.tap(interroga);
    await tester.pump();
    await tester.pump(RiflessioneDelCielo.finoAllUltimaScheda(
        HoroscopeDomain.values.length,
        piena: true));
    await tester.pump(const Duration(milliseconds: 800));
    final senzaNota = <String>[];
    for (final d in HoroscopeDomain.values) {
      final bottone = find.byKey(Key('oroscopo_metodo_${d.name}'));
      if (bottone.evaluate().isEmpty) {
        await tester.dragUntilVisible(bottone,
            find.byKey(const Key('oroscopo_list')), const Offset(0, -300));
      }
      await tester.ensureVisible(bottone);
      await tester.tap(bottone);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      final nota = find.byKey(Key('oroscopo_nota_metodo_${d.name}'));
      if (nota.evaluate().isEmpty) senzaNota.add(d.name);
      expect(
          find.text(IlMetodoDelResponso.delGiorno(
              d, LivelloPersonalizzazione.soloSegno)),
          findsOneWidget);
      await tester.tap(find.text('Chiudi'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
    }
    // ES.34: in fondo, dopo il consulto, la ragione per tornare domani.
    final domani = find.byKey(const Key('oroscopo_domani'));
    await tester.dragUntilVisible(
        domani, find.byKey(const Key('oroscopo_list')), const Offset(0, -300));
    expect(domani, findsOneWidget);
    print('ORDINE ES VOCE 30: schede del giorno senza nota del metodo '
        '${senzaNota.length} su ${HoroscopeDomain.values.length}');
    expect(senzaNota, isEmpty);
    // La nota cambia col livello dei dati: tre livelli, tre note.
    final note = {
      for (final l in LivelloPersonalizzazione.values)
        IlMetodoDelResponso.delGiorno(HoroscopeDomain.amore, l),
    };
    expect(note, hasLength(3));
    // Con la carta il livello viene dai passaggi, senza dalla Luna: la nota
    // lo dice (ordine ES voce 28).
    expect(
        IlMetodoDelResponso.delGiorno(
            HoroscopeDomain.amore, LivelloPersonalizzazione.cartaCompleta),
        contains('passaggi di oggi che parlano a questo campo'));
    expect(
        IlMetodoDelResponso.delGiorno(
            HoroscopeDomain.amore, LivelloPersonalizzazione.soloSegno),
        contains('viene dalla Luna di oggi'));
  });

  test('ES.13: sulla card il nome senza cognome e la nascita scritta', () {
    expect(OroscopoShareCard.soloIlNome('Mario Rossi'), 'Mario');
    expect(OroscopoShareCard.soloIlNome('  Sofia  '), 'Sofia');
    expect(OroscopoShareCard.soloIlNome(''), isNull);
    expect(OroscopoShareCard.soloIlNome(null), isNull);
    expect(
        OroscopoShareCard.laNascitaScritta(DateTime(1990, 3, 15),
            ora: 8, minuto: 30, luogo: 'Roma'),
        '15 marzo 1990, ore 08:30, Roma');
    expect(OroscopoShareCard.laNascitaScritta(DateTime(1990, 3, 15)),
        '15 marzo 1990');
    // I nove emblemi dei periodi e i diciotto delle tradizioni esistono.
    var presenti = 0;
    for (final nome in [
      for (final p in ['Settimana', 'Mese', 'Anno']) 'Oroscopo-$p',
      for (final t in [
        'Vedica',
        'Cinese',
        'Maya',
        'Celtica',
        'Egizia',
        'Araba'
      ])
        'Tradizione-$t',
    ]) {
      for (final f in ['Vert', 'Square', 'Oriz']) {
        if (File('assets/schede/$nome-$f-1.webp').existsSync()) presenti++;
      }
    }
    print('ORDINE ES VOCI 05 E 11: emblemi in assets/schede $presenti su 27');
    expect(presenti, 27);
  });
}
