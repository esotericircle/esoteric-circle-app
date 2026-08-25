import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/synastry/cielo_della_sinastria.dart';
import 'package:esoteric_circle/core/synastry/synastry_report.dart';
import 'package:esoteric_circle/core/synastry/tempi_della_chiamata.dart';
import 'package:esoteric_circle/core/synastry/vip_catalog.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/synastry/chiamata_del_vip.dart';
import 'package:esoteric_circle/features/synastry/sinastria_vip_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// LA CHIAMATA, LA SOVRAPPOSIZIONE E IL VERDETTO. Ordine BO voci 06 e 07.
///
/// **Parole del fondatore, che aprono tutta la revisione**: "questa
/// funzionalita' che dovrebbe essere quella piu' virale non mi convince: prima
/// di tutto per le animazioni che non ci sono".
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  void silenzia() {
    final m = binding.defaultBinaryMessenger;
    m.setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
        (call) async => null);
    for (final nome in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      m.setMockStreamHandler(
          EventChannel(nome), MockStreamHandler.inline(onListen: (a, e) {}));
    }
  }

  final tuo = CieloDiSinastria.perIdentita(
      BirthIdentity.fromParts(birthDate: DateTime(1988, 3, 14)));

  Widget attorno(Widget scena, {bool riduciMovimento = false}) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => ZodiacController()),
        ],
        child: MediaQuery(
          data: MediaQueryData(disableAnimations: riduciMovimento),
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            home: MaestroScope(child: scena),
          ),
        ),
      );

  // --- BO.06, I TEMPI E I FILI ---

  test('la sequenza intera sta dentro i sei secondi del vincolo V1', () {
    final durata = TempiDellaChiamata.alPeggio;
    // ignore: avoid_print
    print('ORDINE BO VOCE 06: dal tocco al verdetto '
        '${durata.inMilliseconds} millesimi, tetto '
        '${TempiDellaChiamata.tetto.inMilliseconds}');
    expect(durata, lessThan(TempiDellaChiamata.tetto),
        reason: 'la scena sfonda il tetto dei sei secondi: chi ne fa dieci di '
            'seguito viene punito');
    // E anche col conteggio del verdetto attaccato dietro resta sotto: il
    // numero finisce di comporsi prima che i sei secondi siano passati.
    expect(durata + TempiDelVerdetto.ilConteggio,
        lessThan(TempiDellaChiamata.tetto),
        reason: 'il numero finisce di salire dopo il tetto');
  });

  test('il salto sta molto sotto i trecento millesimi', () {
    expect(TempiDellaChiamata.ilSalto.inMilliseconds, lessThan(300));
  });

  test('con Riduci Movimento nessun momento si salta', () {
    // Vincolo V2: ogni momento resta, fermo e dichiarato.
    final ferma = TempiDellaChiamata.interaFerma(quantiAspetti: 3);
    expect(ferma.inMilliseconds, greaterThan(0));
    // Sono cinque momenti piu' i fili: nessuno vale zero, quindi nessuno
    // sparisce.
    expect(ferma.inMilliseconds,
        TempiDellaChiamata.passoFermo.inMilliseconds * 7);
    expect(MomentoDellaChiamata.values, hasLength(5));
  });

  testWidgets('i fili accesi sono gli aspetti veri, e mai uno di piu\'',
      (tester) async {
    silenzia();
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final vip in VipCatalog.vips.take(12)) {
      final report = SynastryReport.perCieli(tuo: tuo, vip: vip);
      final chiave = GlobalKey<ChiamataDelVipState>();
      await tester.pumpWidget(attorno(Material(
        child: ChiamataDelVip(
          key: chiave,
          vip: vip,
          tuo: tuo,
          aspetti: report.aspetti,
          palette: MaestroPalette.medora,
          onFinita: () {},
        ),
      )));
      await tester.pump();
      await tester.pump(TempiDellaChiamata.alPeggio);

      final quanti = ChiamataDelVip.filiPer(report.aspetti);
      expect(quanti, lessThanOrEqualTo(TempiDellaChiamata.aspettiAccesi),
          reason: vip.name);
      expect(quanti, lessThanOrEqualTo(report.aspetti.length),
          reason: '${vip.name}: si accendono più fili di quanti aspetti il '
              'motore abbia prodotto');
      // Ogni filo acceso corrisponde a un aspetto VERO, cioe' uno che sta
      // dentro il suo orbo: e' la definizione di aspetto.
      for (final a in report.aspetti.take(quanti)) {
        expect(a.orbo, lessThanOrEqualTo(AspettiDiSinastria.orbo[a.tipo]!),
            reason: '${vip.name}: ${a.titolo} è oltre il suo orbo');
      }
      // E il nome mostrato e' quello di uno di quegli aspetti.
      if (quanti > 0) {
        final nome = find.byKey(const Key('sinastria_nome_aspetto'));
        if (nome.evaluate().isNotEmpty) {
          final testo = tester.widget<Text>(nome).data;
          expect(report.aspetti.take(quanti).map((a) => a.titolo),
              contains(testo),
              reason: '${vip.name}: il nome mostrato "$testo" non è di '
                  'nessuno degli aspetti accesi');
        }
      }
      await tester.pumpWidget(const SizedBox());
    }
  });

  testWidgets('nessun filo senza il suo aspetto', (tester) async {
    // Il verso che conta davvero: con ZERO aspetti non si accende niente.
    silenzia();
    await tester.pumpWidget(attorno(Material(
      child: ChiamataDelVip(
        vip: VipCatalog.first,
        tuo: tuo,
        aspetti: const [],
        palette: MaestroPalette.medora,
        onFinita: () {},
      ),
    )));
    await tester.pump();
    await tester.pump(TempiDellaChiamata.alPeggio);
    expect(find.byKey(const Key('sinastria_fili')), findsNothing,
        reason: 'si accendono fili senza nessun aspetto da mostrare: '
            'sarebbe un\'animazione che dimostra un calcolo che non c\'è');
    expect(find.byKey(const Key('sinastria_nome_aspetto')), findsNothing);
  });

  testWidgets('il tocco salta al verdetto', (tester) async {
    silenzia();
    var finita = false;
    await tester.pumpWidget(attorno(Material(
      child: ChiamataDelVip(
        vip: VipCatalog.first,
        tuo: tuo,
        aspetti: SynastryReport.perCieli(tuo: tuo, vip: VipCatalog.first)
            .aspetti,
        palette: MaestroPalette.medora,
        onFinita: () => finita = true,
      ),
    )));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(finita, isFalse, reason: 'la scena è finita da sola troppo presto');
    await tester.tap(find.byKey(const Key('sinastria_chiamata')));
    await tester.pump();
    expect(finita, isTrue,
        reason: 'il tocco non porta al risultato: chi ne fa dieci di seguito '
            'viene punito');
    await tester.pumpWidget(const SizedBox());
  });

  // --- BO.07, IL VERDETTO CHE SI COMPONE ---

  test('il conteggio dura quanto l\'ordine concede', () {
    expect(TempiDelVerdetto.ilConteggio,
        greaterThanOrEqualTo(TempiDelVerdetto.conteggioMinimo));
    expect(TempiDelVerdetto.ilConteggio,
        lessThanOrEqualTo(TempiDelVerdetto.conteggioMassimo));
  });

  testWidgets('il numero sale e finisce sul numero esatto, mai su un altro',
      (tester) async {
    silenzia();
    tester.view.physicalSize = const Size(440, 1700);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final vip = VipCatalog.conNome('Zendaya')!;
    await tester.pumpWidget(attorno(SinastriaVipScreen(
        vip: vip, saltaLaChiamata: true, userName: 'Tu')));
    await tester.pump();

    final atteso = SynastryReport.perCieli(
            tuo: SinastriaVipScreenState.cieloDiRipiego(
                BirthIdentity.example.birthMoment, null, 'Tu'),
            vip: vip)
        .overall;

    int aVideo() {
      final t = tester.widget<Text>(find.byKey(const Key('sinastria_numero')));
      return int.parse(t.data!.replaceAll('%', ''));
    }

    var precedente = -1;
    var campioni = 0;
    for (var ms = 0; ms <= 1200; ms += 40) {
      final v = aVideo();
      expect(v, lessThanOrEqualTo(atteso),
          reason: 'a $ms millesimi il numero mostrato è $v, sopra il numero '
              'del calcolo $atteso: per un fotogramma la persona legge un '
              'numero che non è il suo');
      expect(v, greaterThanOrEqualTo(precedente),
          reason: 'a $ms millesimi il numero è sceso da $precedente a $v');
      precedente = v;
      campioni++;
      await tester.pump(const Duration(milliseconds: 40));
    }
    expect(campioni, greaterThan(20));
    await tester.pump(const Duration(seconds: 3));
    expect(aVideo(), atteso,
        reason: 'il conteggio non finisce sul numero del calcolo');
  });

  testWidgets('le quattro barre partono sfalsate, non insieme',
      (tester) async {
    silenzia();
    tester.view.physicalSize = const Size(440, 1700);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(attorno(SinastriaVipScreen(
        vip: VipCatalog.conNome('Zendaya')!,
        saltaLaChiamata: true,
        userName: 'Tu')));
    await tester.pump();
    final stato = tester.state<SinastriaVipScreenState>(
        find.byType(SinastriaVipScreen));
    // A conteggio appena finito la prima barra e' gia' partita e l'ultima no.
    await tester.pump(TempiDelVerdetto.ilConteggio +
        TempiDelVerdetto.fraUnaBarraELaltra ~/ 2);
    final quanti = [for (var i = 0; i < 4; i++) stato.quantoDellaBarraPerLaProva(i)];
    // ignore: avoid_print
    print('ORDINE BO VOCE 07: le quattro barre a metà del primo sfalsamento '
        '$quanti');
    expect(quanti.first, greaterThan(0),
        reason: 'la prima barra non è ancora partita');
    expect(quanti.last, 0,
        reason: 'l\'ultima barra è già partita: le quattro partono insieme');
    for (var i = 1; i < quanti.length; i++) {
      expect(quanti[i], lessThanOrEqualTo(quanti[i - 1]),
          reason: 'la barra $i è più avanti della ${i - 1}');
    }
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('con Riduci Movimento il numero appare già scritto',
      (tester) async {
    silenzia();
    tester.view.physicalSize = const Size(440, 1700);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final vip = VipCatalog.conNome('Zendaya')!;
    await tester.pumpWidget(attorno(
        SinastriaVipScreen(
            vip: vip, saltaLaChiamata: true, userName: 'Tu'),
        riduciMovimento: true));
    await tester.pump();
    final atteso = SynastryReport.perCieli(
            tuo: SinastriaVipScreenState.cieloDiRipiego(
                BirthIdentity.example.birthMoment, null, 'Tu'),
            vip: vip)
        .overall;
    final t = tester.widget<Text>(find.byKey(const Key('sinastria_numero')));
    expect(t.data, '$atteso%',
        reason: 'al primo fotogramma il numero non è ancora quello: chi ha '
            'tolto le animazioni sta guardando un conteggio');
    // E la fascia c'e' gia', non arriva dopo.
    final fascia =
        tester.widget<Opacity>(find.ancestor(
            of: find.byKey(const Key('sinastria_fascia')),
            matching: find.byType(Opacity)));
    expect(fascia.opacity, 1.0);
  });
}
