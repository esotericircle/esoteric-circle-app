// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/astro/birth_details.dart';
import 'package:esoteric_circle/core/astro/birth_place.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/horoscope/astro_tradition.dart';
import 'package:esoteric_circle/core/horoscope/horoscope.dart';
import 'package:esoteric_circle/core/horoscope/l_almanacco_cinese.dart';
import 'package:esoteric_circle/core/horoscope/la_lettura_cinese.dart';
import 'package:esoteric_circle/core/horoscope/oroscopo_cinese_data.dart';
import 'package:esoteric_circle/core/horoscope/riflessione_del_cielo.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/horoscope/oroscopo_screen.dart';
import 'package:esoteric_circle/features/horoscope/titolo_della_scheda_del_giorno.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'cardinale_minimo.dart';

/// **LA TRADIZIONE CINESE, APERTA. Ordine ES voce 08, 29 settembre 2026.**
///
/// Il fondatore: *"Se sceglie oroscopo cinese significa che è selezionabile e
/// sbloccato"*; *"il responso avverrà con la stessa animazione e con la
/// stessa divisione in generica, amore, lavoro e fortuna?"*; e dalla voce
/// ES.06: *"I free potranno solo chiedere oroscopo del giorno e solo
/// occidentale o solo vedere il proprio segno di vedica o cinese senza
/// lettura"*.
///
/// Cosa si pretende:
/// - le quattro schede vengono dall'almanacco del giorno (il guardiano dei
///   trenta giorni verificati sull'almanacco pubblicato) e dai Dieci Dei, con
///   le frasi del gruppo giusto e il livello della regola dichiarata;
/// - **due esecuzioni con dati diversi danno testi diversi** (la regola della
///   EE.04 nel CLAUDE.md): la stessa persona in due giorni di fila;
/// - nessun segnaposto, nessuna quadra, nessuna preposizione non fusa;
/// - la schermata: dal primo piano a pagamento "Apri l'almanacco", la stessa
///   riflessione, le quattro schede; il piano gratuito vede il segno e
///   l'invito al piano; senza data di nascita la riga che la chiede; ogni
///   tradizione ha il suo consulto.
void main() {
  // Le tre forme, per le tre serie dell'Amore.
  const forme = [
    CourtesyForm.feminine,
    CourtesyForm.masculine,
    CourtesyForm.unknown,
  ];
  final tutteApprofondite = {
    for (final d in HoroscopeDomain.values) d: true,
  };

  /// Le varianti di un gruppo come espressioni: le marche risolte con la
  /// forma, i segnaposti al posto di qualunque testo.
  List<RegExp> gruppo(List<String> varianti, CourtesyForm forma) => [
        for (final v in varianti)
          RegExp(
              '^${RegExp.escape(LaMarcaDelGenere.risolvi(v, forma: forma)).replaceAll(RegExp(r'(?:[Dd]i |[Aa] )?\\\{\w+\\\}'), '.+?')}'),
      ];

  bool nelGruppo(String testo, List<RegExp> g) =>
      g.any((r) => r.hasMatch(testo));

  test('il guardiano dei trenta giorni e\' quello dell\'almanacco pubblicato',
      () {
    const guardiani = '建除满平定执破危成收开闭';
    final giorni = File('docs/collaudo/ES/cinese_verifica.csv')
        .readAsLinesSync()
        .skip(1)
        .takeWhile((r) => r.trim().isNotEmpty)
        .map((r) => r.split(','))
        .toList();
    cardinaleMinimo(giorni.length, 30, cosa: 'giorni dell\'almanacco');
    final diversi = <String>[];
    for (final c in giorni) {
      final g = DateTime.parse(c[0]);
      final atteso = LAlmanaccoCinese.guardiani[guardiani.indexOf(c[10])];
      final generale = LaLetturaCinese.schede(
              oggi: g, nascita: DateTime(1990, 3, 15), animale: 6)!
          .first;
      if (!generale.text.contains(atteso)) {
        diversi.add('${c[0]}: atteso $atteso, "${generale.text}"');
      }
    }
    print('ORDINE ES VOCE 08: Generali col guardiano diverso dall\'almanacco '
        'pubblicato ${diversi.length} su ${giorni.length}');
    expect(diversi, isEmpty, reason: diversi.join('\n'));
  });

  test('ogni scheda dice la frase del suo gruppo, col livello della regola',
      () {
    final fuori = <String>[];
    var schede = 0;
    for (var a = 0; a < 12; a++) {
      for (final f in forme) {
        for (var k = 0; k < 30; k++) {
          final g = DateTime(2026, 10, 1 + k);
          final nascita = DateTime(1960 + a * 3, 1 + a, 1 + k % 28);
          final s = LaLetturaCinese.schede(
              oggi: g, nascita: nascita, animale: a, forma: f)!;
          final ramo = LAlmanaccoCinese.ramo(g);
          final r = LAlmanaccoCinese.rapporto(a, ramo);
          final dio = LAlmanaccoCinese.dio(
              LAlmanaccoCinese.tronco(nascita), LAlmanaccoCinese.tronco(g));
          final attesiGenerale = gruppo(
              OroscopoCineseData
                  .rapporti[LaLetturaCinese.chiaveDelRapporto(r, a == ramo)]!,
              f);
          if (!nelGruppo(s[0].text, attesiGenerale)) {
            fuori.add('generale $a $g: ${s[0].text}');
          }
          if (s[0].indicator != LaLetturaCinese.livelloDelRapporto(r)) {
            fuori.add('livello generale $a $g');
          }
          final serie = {
            HoroscopeDomain.amore: switch (f) {
              CourtesyForm.feminine => 'amoreDonna',
              CourtesyForm.masculine => 'amoreUomo',
              _ => 'amoreNeutro',
            },
            HoroscopeDomain.carriera: 'lavoro',
            HoroscopeDomain.fortuna: 'fortuna',
          };
          for (final c in s.skip(1)) {
            schede++;
            final atteso =
                gruppo(OroscopoCineseData.dei[serie[c.domain]]![dio.name]!, f);
            if (!nelGruppo(c.text, atteso)) {
              fuori.add('${c.domain.name} $a $f $g: ${c.text}');
            }
            if (c.indicator !=
                LaLetturaCinese.livelloDelDio(c.domain, dio, forma: f)) {
              fuori.add('livello ${c.domain.name} $a $g');
            }
            if (!c.rigaDelLivello!.contains(dio.nome)) {
              fuori.add('riga del livello senza il dio: ${c.rigaDelLivello}');
            }
          }
          schede++;
        }
      }
    }
    // **LA TABELLA DELLA REGOLA, scritta qui e non riletta dal codice**: il
    // confronto con la funzione dell'app, da solo, sarebbe l'app che si
    // guarda allo specchio.
    const livelliDeiRapporti = {
      RapportoFraAnimali.armonia: 5,
      RapportoFraAnimali.triplaArmonia: 4,
      RapportoFraAnimali.stessoAnimale: 3,
      RapportoFraAnimali.nessuno: 3,
      RapportoFraAnimali.armoniaChePunisce: 3,
      RapportoFraAnimali.scontro: 2,
      RapportoFraAnimali.punizione: 2,
      RapportoFraAnimali.danno: 2,
    };
    for (final e in livelliDeiRapporti.entries) {
      if (LaLetturaCinese.livelloDelRapporto(e.key) != e.value) {
        fuori.add('livello del rapporto ${e.key.name}');
      }
    }
    // La Fortuna guarda alla Ricchezza, il Lavoro all'Ufficiale.
    const fortuna = {
      DioDelGiorno.ricchezzaDiretta: 5,
      DioDelGiorno.ricchezzaIndiretta: 4,
      DioDelGiorno.nutrimento: 4,
      DioDelGiorno.rivale: 2,
      DioDelGiorno.setteUccisioni: 2,
      DioDelGiorno.sigilloDiretto: 3,
    };
    const lavoro = {
      DioDelGiorno.ufficialeDiretto: 5,
      DioDelGiorno.ricchezzaDiretta: 4,
      DioDelGiorno.sigilloIndiretto: 4,
      DioDelGiorno.ufficialeFerito: 2,
      DioDelGiorno.rivale: 2,
      DioDelGiorno.compagno: 3,
    };
    for (final (d, tabella) in [
      (HoroscopeDomain.fortuna, fortuna),
      (HoroscopeDomain.carriera, lavoro),
    ]) {
      for (final e in tabella.entries) {
        if (LaLetturaCinese.livelloDelDio(d, e.key) != e.value) {
          fuori.add('livello di ${e.key.name} per ${d.name}');
        }
      }
    }
    cardinaleMinimo(schede, 4320, cosa: 'schede cinesi');
    print('ORDINE ES VOCE 08: schede fuori dal loro gruppo o dal loro '
        'livello ${fuori.length} su $schede');
    expect(fuori, isEmpty, reason: fuori.take(8).join('\n'));
    // La punizione di se': lo stesso animale del giorno fra i quattro che
    // puniscono se stessi ha le sue frasi (il Cavallo nel giorno del
    // Cavallo, 29 settembre 2026).
    final g = DateTime(2026, 9, 29);
    expect(LAlmanaccoCinese.ramo(g), 6);
    final s = LaLetturaCinese.schede(
        oggi: g, nascita: DateTime(1990, 3, 15), animale: 6)!;
    expect(
        nelGruppo(
            s[0].text,
            gruppo(OroscopoCineseData.rapporti['punizioneDiSe']!,
                CourtesyForm.unknown)),
        isTrue,
        reason: s[0].text);
    expect(s[0].rigaDelLivello, contains('punizione di sé'));
  });

  test('due giorni di fila, due testi diversi; Breve e Approfondita diverse',
      () {
    var coppie = 0;
    var uguali = 0;
    var breviUguali = 0;
    for (var a = 0; a < 12; a++) {
      final nascita = DateTime(1970 + a, 2 + a % 10, 3 + a);
      List<HoroscopeCard> del(DateTime g, {bool prof = false}) =>
          LaLetturaCinese.schede(
              oggi: g,
              nascita: nascita,
              animale: a,
              approfondite: prof ? tutteApprofondite : const {})!;
      for (var k = 0; k < 30; k++) {
        final oggi = del(DateTime(2026, 10, 1 + k));
        final domani = del(DateTime(2026, 10, 2 + k));
        final profonde = del(DateTime(2026, 10, 1 + k), prof: true);
        for (var i = 0; i < 4; i++) {
          coppie++;
          if (oggi[i].text == domani[i].text) uguali++;
          if (oggi[i].text == profonde[i].text) breviUguali++;
        }
      }
    }
    print('ORDINE ES VOCE 08: schede uguali fra un giorno e il seguente '
        '$uguali su $coppie; Breve uguale all\'Approfondita $breviUguali su '
        '$coppie');
    expect(uguali, 0);
    expect(breviUguali, 0);
  });

  /// **QUANDO LO STESSO CASO TORNA, LA FRASE E' UN'ALTRA.**
  ///
  /// La misura di prima, due giorni di fila, restava verde anche con la
  /// variante fissa: fra un giorno e il seguente cambiano l'animale e il dio,
  /// e il testo cambia per conto suo. Il fondatore non ha chiesto che due
  /// giorni siano diversi: ha trovato le stesse parole nella stessa persona
  /// (EE.04). Qui si misura proprio quello: il giorno del Cavallo torna ogni
  /// dodici giorni, il dio del giorno ogni dieci, il guardiano quando torna, e
  /// ogni volta la persona legge l'altra variante del suo gruppo.
  test('quando lo stesso caso torna, la frase e\' un\'altra', () {
    int? quale(String testo, List<String> varianti, CourtesyForm f) {
      for (var i = 0; i < varianti.length; i++) {
        final r = RegExp(
            RegExp.escape(LaMarcaDelGenere.risolvi(varianti[i], forma: f))
                .replaceAll(RegExp(r'(?:[Dd]i |[Aa] )?\\\{\w+\\\}'), '.+?'));
        if (r.hasMatch(testo)) return i;
      }
      return null;
    }

    final coppie = <String, int>{};
    final uguali = <String, int>{};
    void conta(String cosa, int? a, int? b) {
      expect(a, isNotNull, reason: cosa);
      expect(b, isNotNull, reason: cosa);
      coppie[cosa] = (coppie[cosa] ?? 0) + 1;
      if (a == b) uguali[cosa] = (uguali[cosa] ?? 0) + 1;
    }

    const f = CourtesyForm.unknown;
    for (var a = 0; a < 12; a += 5) {
      final nascita = DateTime(1971 + a, 4, 9 + a);
      List<HoroscopeCard> del(DateTime g) => LaLetturaCinese.schede(
          oggi: g,
          nascita: nascita,
          animale: a,
          forma: f,
          approfondite: tutteApprofondite)!;
      for (var k = 0; k < 400; k++) {
        final d = DateTime(2026, 1, 1 + k);
        final oggi = del(d);
        final r = LaLetturaCinese.chiaveDelRapporto(
            LAlmanaccoCinese.rapporto(a, LAlmanaccoCinese.ramo(d)),
            a == LAlmanaccoCinese.ramo(d));
        final gruppoR = OroscopoCineseData.rapporti[r]!;
        // Il giorno dello stesso animale, dodici giorni dopo.
        final fra12 = del(DateTime(2026, 1, 13 + k));
        conta('rapporto', quale(oggi[0].text, gruppoR, f),
            quale(fra12[0].text, gruppoR, f));
        // Il dio, dieci giorni dopo.
        final dio = LAlmanaccoCinese.dio(
            LAlmanaccoCinese.tronco(nascita), LAlmanaccoCinese.tronco(d));
        final fra10 = del(DateTime(2026, 1, 11 + k));
        final gruppoD = OroscopoCineseData.dei['lavoro']![dio.name]!;
        conta('dio', quale(oggi[2].text, gruppoD, f),
            quale(fra10[2].text, gruppoD, f));
        // La direzione del Dio della Gioia, cinque giorni dopo.
        conta(
            'direzione',
            quale(oggi[0].text, OroscopoCineseData.direzioneGioia, f),
            quale(del(DateTime(2026, 1, 6 + k))[0].text,
                OroscopoCineseData.direzioneGioia, f));
        // Il guardiano, alla sua prossima volta.
        final g = LAlmanaccoCinese.guardiano(d)!;
        var e = 1;
        while (LAlmanaccoCinese.guardiano(DateTime(2026, 1, 1 + k + e)) != g) {
          e++;
        }
        final gruppoG = OroscopoCineseData.guardiani[g];
        conta('guardiano', quale(oggi[0].text, gruppoG, f),
            quale(del(DateTime(2026, 1, 1 + k + e))[0].text, gruppoG, f));
        // L'elemento del giorno, alla sua prossima volta.
        final el =
            LAlmanaccoCinese.elementoDelTronco(LAlmanaccoCinese.tronco(d));
        var h = 1;
        while (LAlmanaccoCinese.elementoDelTronco(
                LAlmanaccoCinese.tronco(DateTime(2026, 1, 1 + k + h))) !=
            el) {
          h++;
        }
        conta(
            'colore',
            quale(
                oggi[3].rigaDellaFortuna!, OroscopoCineseData.coloreENumeri, f),
            quale(del(DateTime(2026, 1, 1 + k + h))[3].rigaDellaFortuna!,
                OroscopoCineseData.coloreENumeri, f));
      }
    }
    final righe = [
      for (final c in coppie.keys) '$c ${uguali[c] ?? 0} su ${coppie[c]}',
    ];
    print('ORDINE ES VOCE 08: stessa frase al ritorno dello stesso caso: '
        '${righe.join('; ')}');
    cardinaleMinimo(coppie['rapporto']!, 1200, cosa: 'ritorni del rapporto');
    expect(uguali.values.fold<int>(0, (s, v) => s + v), 0,
        reason: righe.join('\n'));
  });

  test('le frasi del codice sono quelle del corpus, nello stesso ordine', () {
    final dalCorpus = RegExp(r'^\d+\.\s+(.+)$', multiLine: true)
        .allMatches(File('docs/corpus/oroscopo_cinese.md')
            .readAsStringSync()
            .replaceAll('\r\n', '\n'))
        .map((m) => m.group(1)!.trim())
        .toList();
    final dalCodice = [
      for (final v in OroscopoCineseData.rapporti.values) ...v,
      for (final v in OroscopoCineseData.guardiani) ...v,
      for (final serie in OroscopoCineseData.dei.values)
        for (final v in serie.values) ...v,
      ...OroscopoCineseData.coloreENumeri,
      ...OroscopoCineseData.direzioneGioia,
      ...OroscopoCineseData.direzioneRicchezza,
    ];
    cardinaleMinimo(dalCorpus.length, 224, cosa: 'frasi del corpus cinese');
    print('ORDINE ES VOCE 08: frasi del corpus ${dalCorpus.length}, del '
        'codice ${dalCodice.length}');
    expect(dalCodice, dalCorpus,
        reason: 'rigenerare con python tool/_gen_oroscopo_cinese.py');
  });

  test('nessun segnaposto, nessuna quadra, preposizioni fuse', () {
    final difetti = <String>[];
    var schede = 0;
    final diverse = <String>{};
    for (var a = 0; a < 12; a++) {
      for (final f in forme) {
        for (var k = 0; k < 40; k++) {
          for (final prof in [false, true]) {
            final s = LaLetturaCinese.schede(
                oggi: DateTime(2026, 10, 1 + k),
                nascita: DateTime(1960 + a * 3, 1 + a, 1 + k % 28),
                animale: a,
                forma: f,
                approfondite: prof ? tutteApprofondite : const {})!;
            for (final c in s) {
              schede++;
              for (final t in [
                c.text,
                c.title,
                c.synthesis,
                c.rigaDelLivello!,
                c.rigaDellaFortuna ?? '',
              ]) {
                diverse.add(t);
                if (RegExp(
                        r"[{}\[\]]|, e |  | \.|\.\.|—|\b[Dd]i (il|la|lo|l')\b|\b[Aa] (il|la|lo|l')\b")
                    .hasMatch(t)) {
                  difetti.add(t);
                }
              }
            }
          }
        }
      }
    }
    cardinaleMinimo(schede, 11520, cosa: 'schede cinesi');
    print('ORDINE ES VOCE 08: testi con un difetto di scrittura '
        '${difetti.length} su $schede schede; testi diversi ${diverse.length}');
    expect(difetti, isEmpty, reason: difetti.take(5).join('\n'));
    // La fusione, su un caso noto: "Il giorno è di {elemento}".
    expect(
        LaLetturaCinese.riempi(
            'Il giorno è di {elemento}.', {'elemento': 'l\'acqua'}),
        'Il giorno è dell\'acqua.');
    expect(
        LaLetturaCinese.riempi(
            '{animale_giorno} guida il giorno.', {'animale_giorno': 'il Topo'}),
        'Il Topo guida il giorno.');
  });

  // ---------------------------------------------------------------------------
  // LA SCHERMATA
  // ---------------------------------------------------------------------------

  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  // Roma, 15 marzo 1990: il Cavallo.
  final nascita = BirthDetails(
    date: DateTime(1990, 3, 15),
    time: const TimeOfDay(hour: 8, minute: 30),
    place: const BirthPlace(
        label: 'Roma',
        latitude: 41.9,
        longitude: 12.5,
        timezone: 'Europe/Rome'),
  );
  final oggi = DateTime(2026, 7, 10);

  Future<void> monta(WidgetTester tester,
      {Tier tier = Tier.tier1, bool conNascita = true}) async {
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
  }

  String titolo(WidgetTester tester, HoroscopeDomain d) => tester
      .widget<TitoloDellaSchedaDelGiorno>(
          find.byKey(Key('oroscopo_titolo_${d.name}')))
      .testo;

  testWidgets('dal primo piano: Apri l\'almanacco e le quattro schede cinesi',
      (tester) async {
    await monta(tester);
    // **OGNI TRADIZIONE HA IL SUO CONSULTO.** Prima l'Occidentale.
    await consulta(tester);
    expect(find.byKey(const Key('oroscopo_card_generale')), findsOneWidget);
    await toccaLaTradizione(tester, AstroTradition.cinese);
    expect(find.byKey(const Key('oroscopo_card_generale')), findsNothing,
        reason: 'le schede della tradizione di prima restano sotto la Cinese');
    final gesto = find.byKey(const Key('oroscopo_interroga'));
    expect(gesto, findsOneWidget);
    expect(find.text('Apri l\'almanacco'), findsOneWidget);
    await consulta(tester);
    final animale =
        LaLetturaCinese.conArticolo(LAlmanaccoCinese.ramo(oggi)).split(' ')[1];
    expect(titolo(tester, HoroscopeDomain.generale), contains(animale));
    final attese = LaLetturaCinese.schede(
        oggi: oggi,
        nascita: DateTime(1990, 3, 15, 8, 30),
        animale: 6,
        forma: CourtesyForm.unknown)!;
    final diverse = <String>[];
    for (var i = 0; i < 4; i++) {
      final d = HoroscopeDomain.values[i];
      final t = find.byKey(Key('oroscopo_titolo_${d.name}'));
      if (t.evaluate().isEmpty) {
        await tester.dragUntilVisible(
            t, find.byKey(const Key('oroscopo_list')), const Offset(0, -300));
      }
      if (titolo(tester, d) != attese[i].title) diverse.add(d.name);
    }
    print('ORDINE ES VOCE 08: schede a video diverse dalla lettura cinese '
        '${diverse.length} su 4');
    expect(diverse, isEmpty);
    // Il metodo della scheda e' quello dell'almanacco.
    final metodo = find.byKey(const Key('oroscopo_metodo_generale'));
    await tester.dragUntilVisible(
        metodo, find.byKey(const Key('oroscopo_list')), const Offset(0, 300));
    await tester.ensureVisible(metodo);
    await tester.tap(metodo);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text(OroscopoCineseData.notaGenerale), findsOneWidget);
    await tester.tap(find.text('Chiudi'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    // La Fortuna: i due numeri dell'elemento.
    final elemento =
        LAlmanaccoCinese.elementoDelTronco(LAlmanaccoCinese.tronco(oggi));
    final numeri = find.text(elemento.numeri.join(' · '));
    await tester.dragUntilVisible(
        numeri, find.byKey(const Key('oroscopo_list')), const Offset(0, -300));
    expect(numeri, findsOneWidget);
    // Domani, dall'almanacco.
    final domani = find.byKey(const Key('oroscopo_domani'));
    await tester.dragUntilVisible(
        domani, find.byKey(const Key('oroscopo_list')), const Offset(0, -300));
    expect(
        find.descendant(
            of: domani, matching: find.text(LaLetturaCinese.domani(oggi, 6)!)),
        findsOneWidget);
    // Tornando all'Occidentale il suo consulto e' gia' scritto.
    await tester.dragUntilVisible(
        find.byKey(const Key('oroscopo_tradition_tabs')),
        find.byKey(const Key('oroscopo_list')),
        const Offset(0, 300));
    await toccaLaTradizione(tester, AstroTradition.occidentale);
    expect(find.byKey(const Key('oroscopo_interroga')), findsNothing);
    expect(find.text('Apri l\'almanacco'), findsNothing);
  });

  testWidgets(
      'il piano gratuito vede il segno cinese e l\'invito, non la '
      'lettura', (tester) async {
    await monta(tester, tier: Tier.free);
    await toccaLaTradizione(tester, AstroTradition.cinese);
    final invito = find.byKey(const Key('oroscopo_cinese_invito_al_piano'));
    await tester.dragUntilVisible(
        invito, find.byKey(const Key('oroscopo_list')), const Offset(0, -300));
    expect(invito, findsOneWidget);
    expect(find.byKey(const Key('oroscopo_interroga')), findsNothing,
        reason: 'il piano gratuito legge la Cinese');
    final gesto = find.byKey(const Key('oroscopo_cinese_scopri_il_piano'));
    await tester.ensureVisible(gesto);
    await tester.tap(gesto);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.textContaining('La lettura cinese del giorno si apre'),
        findsOneWidget);
  });

  testWidgets('senza la data di nascita, la riga che la chiede',
      (tester) async {
    await monta(tester, conNascita: false);
    await toccaLaTradizione(tester, AstroTradition.cinese);
    expect(find.byKey(const Key('oroscopo_interroga')), findsNothing);
    expect(find.textContaining('Per la lettura cinese serve la tua data'),
        findsOneWidget);
  });

  testWidgets('la settimana cinese dice che e\' in arrivo e riporta al giorno',
      (tester) async {
    await monta(tester, tier: Tier.tier2);
    await tester.tap(find.byKey(const Key('oroscopo_period_settimana')));
    await tester.pump();
    await toccaLaTradizione(tester, AstroTradition.cinese);
    final avviso = find.byKey(const Key('oroscopo_cinese_periodo'));
    await tester.dragUntilVisible(
        avviso, find.byKey(const Key('oroscopo_list')), const Offset(0, -300));
    expect(avviso, findsOneWidget);
    final torna = find.byKey(const Key('oroscopo_cinese_torna_al_giorno'));
    await tester.ensureVisible(torna);
    await tester.tap(torna);
    await tester.pump();
    expect(find.text('Apri l\'almanacco'), findsOneWidget);
  });
}
